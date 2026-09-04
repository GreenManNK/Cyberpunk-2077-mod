local Storage = require("modules/storage")

local Operations = {}
Operations.__index = Operations
Operations.DEFAULT_HISTORY_LIMIT = 20
Operations.MIN_HISTORY_LIMIT = 2

local function copy(value)
  if type(value) ~= "table" then
    return value
  end

  local result = {}
  for key, item in pairs(value) do
    if type(item) ~= "function" then
      result[key] = copy(item)
    end
  end
  return result
end

local function publicOperation(operation)
  if operation == nil then
    return nil
  end

  return {
    id = operation.id,
    kind = operation.kind,
    state = operation.state,
    current = operation.current,
    total = operation.total,
    message = operation.message,
    error = operation.error,
    result = copy(operation.result),
    createdAt = operation.createdAt,
    updatedAt = operation.updatedAt,
    cancellable = operation.state == "queued" or operation.state == "running",
  }
end

local function normalizedHistoryLimit(value)
  local limit = math.floor(tonumber(value) or Operations.DEFAULT_HISTORY_LIMIT)
  return math.max(Operations.MIN_HISTORY_LIMIT, limit)
end

local function isRecoverable(operation)
  if operation == nil or operation.kind ~= "apply_collection" then
    return false
  end

  local context = operation.context or {}
  local result = operation.result or context.publicResult or {}
  if result.requiresConfirmation == true and context.continued ~= true then
    return true
  end
  return result.rollbackAvailable == true and context.rollbackStarted ~= true
end

function Operations.new(options)
  options = options or {}
  return setmetatable({
    items = {},
    order = {},
    activeId = nil,
    historyLimit = normalizedHistoryLimit(options.historyLimit),
  }, Operations)
end

function Operations:prune()
  if #self.order <= self.historyLimit then
    return
  end

  local retained = {}
  local retainedCount = 0
  local function retain(operationId)
    if operationId ~= nil and self.items[operationId] ~= nil and not retained[operationId] then
      retained[operationId] = true
      retainedCount = retainedCount + 1
    end
  end

  retain(self.activeId)
  for index = #self.order, 1, -1 do
    local operationId = self.order[index]
    if isRecoverable(self.items[operationId]) then
      retain(operationId)
      break
    end
  end
  for index = #self.order, 1, -1 do
    if retainedCount >= self.historyLimit then
      break
    end
    retain(self.order[index])
  end

  local nextOrder = {}
  for _, operationId in ipairs(self.order) do
    if retained[operationId] then
      nextOrder[#nextOrder + 1] = operationId
    else
      self.items[operationId] = nil
    end
  end
  self.order = nextOrder
end

function Operations:start(spec)
  if self.activeId ~= nil then
    local active = self.items[self.activeId]
    if active ~= nil and (active.state == "queued" or active.state == "running") then
      return nil, "Another MCM operation is already running."
    end
  end
  if type(spec) ~= "table" or type(spec.step) ~= "function" then
    return nil, "Operation requires a step callback."
  end

  local timestamp = Storage.timestamp()
  local operation = {
    id = Storage.newId("operation"),
    kind = tostring(spec.kind or "operation"),
    state = "queued",
    current = 0,
    total = math.max(0, tonumber(spec.total) or 0),
    message = tostring(spec.message or ""),
    error = nil,
    result = nil,
    createdAt = timestamp,
    updatedAt = timestamp,
    step = spec.step,
    cancel = spec.cancel,
    failed = spec.failed,
    context = spec.context or {},
  }
  self.items[operation.id] = operation
  self.order[#self.order + 1] = operation.id
  self.activeId = operation.id
  self:prune()
  return publicOperation(operation), nil
end

function Operations:get(operationId)
  local operation = self.items[operationId]
  if operation == nil then
    return nil, "Unknown operation: " .. tostring(operationId)
  end
  return publicOperation(operation), nil
end

function Operations:getInternal(operationId)
  local operation = self.items[operationId]
  if operation == nil then
    return nil, "Unknown operation: " .. tostring(operationId)
  end
  return operation, nil
end

function Operations:list()
  local result = {}
  for _, operationId in ipairs(self.order) do
    local operation = publicOperation(self.items[operationId])
    if operation ~= nil then
      result[#result + 1] = operation
    end
  end
  return result
end

function Operations:cancel(operationId)
  local operation = self.items[operationId]
  if operation == nil then
    return false, "Unknown operation: " .. tostring(operationId)
  end
  if operation.state ~= "queued" and operation.state ~= "running" then
    return false, "Operation is no longer cancellable."
  end

  if type(operation.cancel) == "function" then
    local ok, err = pcall(operation.cancel, operation.context, operation)
    if not ok then
      operation.error = tostring(err)
      if operation.result == nil and operation.context.publicResult ~= nil then
        operation.result = copy(operation.context.publicResult)
      end
      operation.state = "failed"
      operation.message = "Operation cancellation failed."
      operation.updatedAt = Storage.timestamp()
      if self.activeId == operation.id then
        self.activeId = nil
      end
      self:prune()
      return false, operation.error, true
    end
  end
  if operation.result == nil and operation.context.publicResult ~= nil then
    operation.result = copy(operation.context.publicResult)
  end
  operation.state = "cancelled"
  operation.message = "Operation cancelled."
  operation.updatedAt = Storage.timestamp()
  if self.activeId == operation.id then
    self.activeId = nil
  end
  self:prune()
  return true, nil, true
end

function Operations:update()
  if self.activeId == nil then
    return nil
  end

  local operation = self.items[self.activeId]
  if operation == nil then
    self.activeId = nil
    return nil
  end
  if operation.state == "queued" then
    operation.state = "running"
  end
  if operation.state ~= "running" then
    self.activeId = nil
    self:prune()
    return publicOperation(operation)
  end

  local ok, done, result, message = pcall(operation.step, operation.context, operation)
  operation.updatedAt = Storage.timestamp()
  if not ok then
    operation.state = "failed"
    operation.error = tostring(done)
    operation.message = "Operation failed."
    self.activeId = nil
  elseif done == true then
    operation.state = "completed"
    operation.result = result
    operation.message = tostring(message or operation.message or "Operation completed.")
    self.activeId = nil
  elseif done == false and result ~= nil then
    operation.state = "failed"
    operation.error = tostring(result)
    operation.message = tostring(message or "Operation failed.")
    self.activeId = nil
  elseif message ~= nil then
    operation.message = tostring(message)
  end

  if operation.state == "failed" and type(operation.failed) == "function" then
    local cleanupOk, cleanupError = pcall(operation.failed, operation.context, operation)
    if not cleanupOk then
      operation.error = tostring(operation.error) .. " Cleanup failed: " .. tostring(cleanupError)
    end
  end
  if
    operation.state == "failed"
    and operation.result == nil
    and operation.context.publicResult ~= nil
  then
    operation.result = copy(operation.context.publicResult)
  end

  self:prune()
  return publicOperation(operation)
end

return Operations
