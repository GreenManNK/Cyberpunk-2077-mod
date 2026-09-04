local Diagnostics = {}

local HISTORY_LIMIT = 100

local function now()
  if type(os.clock) == "function" then
    return os.clock()
  end

  return 0
end

local function copyTable(source)
  local target = {}
  if type(source) ~= "table" then
    return target
  end
  for key, value in pairs(source) do
    if type(value) == "table" then
      local nested = {}
      for nestedKey, nestedValue in pairs(value) do
        nested[nestedKey] = nestedValue
      end
      target[key] = nested
    else
      target[key] = value
    end
  end
  return target
end

function Diagnostics.new()
  local state = {
    startedAt = now(),
    providers = {},
    errors = {},
    history = {},
  }

  local api = {}

  local function push(list, value)
    list[#list + 1] = value
    if #list > HISTORY_LIMIT then
      table.remove(list, 1)
    end
  end

  function api.ensureProvider(provider)
    if provider == nil or provider.id == nil then
      return nil
    end

    local id = tostring(provider.id)
    local record = state.providers[id]
    if record == nil then
      record = {
        id = id,
        name = tostring(provider.name or id),
        shortName = tostring(provider.shortName or id),
        registered = true,
        detected = nil,
        ready = nil,
        available = nil,
        state = "registered",
        revision = nil,
        epoch = nil,
        mods = 0,
        stale = false,
        refreshCount = 0,
        lastDuration = 0,
        lastRefreshAt = nil,
        lastError = nil,
        message = nil,
      }
      state.providers[id] = record
    else
      record.registered = true
      record.name = tostring(provider.name or record.name or id)
      record.shortName = tostring(provider.shortName or record.shortName or id)
    end
    return record
  end

  function api.unregisterProvider(providerId)
    local record = state.providers[tostring(providerId or "")]
    if record ~= nil then
      record.registered = false
      record.ready = false
      record.available = false
      record.state = "absent"
      record.message = "Provider package was unregistered."
    end
  end

  function api.updateProvider(provider, values)
    local record = api.ensureProvider(provider)
    if record == nil then
      return nil
    end

    for key, value in pairs(values or {}) do
      record[key] = value
    end
    if values and values.detected ~= nil then
      record.available = values.detected == true
    end
    return record
  end

  function api.record(kind, message, details)
    push(state.history, {
      time = now(),
      kind = tostring(kind or "info"),
      message = tostring(message or ""),
      details = details,
    })
  end

  function api.error(message, providerId, details)
    local normalizedProviderId = nil
    if providerId ~= nil then
      normalizedProviderId = tostring(providerId)
    end

    local record = {
      time = now(),
      message = tostring(message or "Unknown error"),
      providerId = normalizedProviderId,
      details = details,
    }
    push(state.errors, record)
    api.record("error", record.message, details)
    return record.message
  end

  function api.snapshot()
    local providers = {}
    for id, provider in pairs(state.providers) do
      providers[id] = copyTable(provider)
    end

    local errors = {}
    for index, err in ipairs(state.errors) do
      errors[index] = copyTable(err)
    end

    local history = {}
    for index, item in ipairs(state.history) do
      history[index] = copyTable(item)
    end

    return {
      startedAt = state.startedAt,
      providers = providers,
      errors = errors,
      history = history,
    }
  end

  return api
end

return Diagnostics
