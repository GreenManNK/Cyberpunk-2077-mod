local Provider = {
  id = "rcf",
  registrationKey = "mcm.bridge.redscript-configuration-framework",
  name = "Redscript Configuration Framework",
  shortName = "RCF",
  apiVersion = 2,
  pollInterval = 0.75,
  capabilities = {
    index = true,
    lazy = true,
    draft = true,
    commit = true,
    atomicApply = false,
    action = true,
  },
}

local settingHandles = {}
local schemaFingerprints = {}
local lastIndexFingerprint = nil
local schemaRevision = 0
local lastSchemaPollAt = 0

local function helper()
  return MCMRCFAdapter
end

local function call(methodName, ...)
  local adapter = helper()
  if adapter == nil or type(adapter[methodName]) ~= "function" then
    return false, nil, "MCM RCF typed adapter is unavailable."
  end
  local ok, result = pcall(adapter[methodName], ...)
  if not ok then
    return false, nil, tostring(result)
  end

  return true, result, nil
end

local function safeText(value, fallback)
  local result = ""
  if value ~= nil and value ~= false then
    result = tostring(value)
  end
  if result ~= "" then
    return result
  end
  if fallback == nil or fallback == false then
    return ""
  end

  return tostring(fallback)
end

local function stringArray(values)
  local result = {}
  if type(values) == "table" then
    for index, value in ipairs(values) do
      result[index] = safeText(value)
    end
  end
  return result
end

local ROW_KINDS = {
  [0] = "label",
  [1] = "toggle",
  [2] = "slider",
  [3] = "button",
  [4] = "stepper",
  [5] = "dropdown",
  [6] = "image",
  [7] = "header",
  [8] = "keybind",
  [9] = "divider",
  [10] = "button_pair",
}

local function rowKind(value)
  local kind = tonumber(value) or -1
  return ROW_KINDS[kind] or "unknown"
end

local function modsFingerprint(entries, revision)
  local parts = { tostring(revision or 0) }
  for _, entry in ipairs(entries or {}) do
    parts[#parts + 1] = table.concat({
      safeText(entry.id),
      safeText(entry.name),
      safeText(entry.description),
    }, ":")
  end
  return table.concat(parts, "|")
end

local function categoriesFingerprint(categories)
  local parts = {}
  for _, category in ipairs(categories or {}) do
    parts[#parts + 1] = "category:" .. safeText(category.id) .. ":" .. safeText(category.name)
    for _, row in ipairs(category.rows or {}) do
      parts[#parts + 1] = table.concat({
        tostring(row.kind or -1),
        safeText(row.key),
        safeText(row.label),
        tostring(row.minValue or ""),
        tostring(row.maxValue or ""),
        tostring(row.stepValue or ""),
        tostring(row.isInt == true),
        tostring(row.localOnly == true),
        tostring(row.pad == true),
        tostring(row.anyDevice == true),
        tostring(#(row.options or {})),
      }, ":")
    end
  end
  return table.concat(parts, "|")
end

local function readMods()
  local ok, entries, err = call("GetMods")
  if not ok or type(entries) ~= "table" then
    return nil, err or tostring(entries)
  end

  return entries, nil
end

local function readRevision()
  local ok, value = call("GetRevision")
  if not ok then
    return 0
  end

  return tonumber(value) or 0
end

function Provider.probe()
  local adapter = helper()
  if adapter == nil or type(adapter.IsAvailable) ~= "function" then
    return {
      detected = false,
      ready = false,
      state = "absent",
      message = "The optional typed RCF adapter is not compiled.",
    }
  end

  local okAvailable, available = call("IsAvailable")
  if not okAvailable or available ~= true then
    return {
      detected = true,
      ready = false,
      state = "initializing",
      message = "RCF registry has not been created yet.",
      revision = readRevision(),
    }
  end

  local okPrepared, prepared, prepareError = call("PrepareRegistry")
  if not okPrepared or prepared ~= true then
    return {
      detected = true,
      ready = false,
      state = "initializing",
      message = prepareError or "RCF registry cache is not ready yet.",
      revision = readRevision(),
    }
  end

  return {
    detected = true,
    ready = true,
    state = "ready",
    revision = readRevision(),
  }
end

function Provider.listMods()
  local entries, err = readMods()
  if entries == nil then
    return nil, err
  end

  local revision = readRevision()
  local mods = {}
  for index, entry in ipairs(entries) do
    local sourceId = safeText(entry.id, "rcf_mod_" .. tostring(index))
    mods[#mods + 1] = {
      id = sourceId,
      name = safeText(entry.name, sourceId),
      description = safeText(entry.description, ""),
      revision = schemaFingerprints[sourceId],
      capabilities = Provider.capabilities,
    }
  end
  lastIndexFingerprint = modsFingerprint(entries, revision)
  return {
    revision = lastIndexFingerprint .. ":schema:" .. tostring(schemaRevision),
    epoch = revision,
    complete = true,
    mods = mods,
  },
    nil
end

local function reserveSettingId(categoryId, key, rowIndex, usedIds)
  local sourceId = categoryId .. ":" .. key
  if usedIds[sourceId] then
    sourceId = sourceId .. ":" .. tostring(rowIndex)
  end

  usedIds[sourceId] = true
  return sourceId
end

local function markReadOnly(setting, kind)
  setting.type = "custom"
  setting.value = ""
  setting.supported = false
  setting.capabilities.write = false
  setting.capabilities.draft = false
  setting.capabilities.reset = false
  setting.capabilities.canReadDefault = false
  setting.capabilities.canResetToDefault = false
  setting.unsupportedReason = "RCF " .. kind .. " rows remain framework-owned."
end

local function finalizeDefaultCapabilities(setting, row)
  local canRead = setting.supported ~= false
    and setting.capabilities.draft ~= false
    and row.hasDefault == true
    and setting.defaultValue ~= nil
  setting.capabilities.canReadDefault = canRead
  setting.capabilities.canResetToDefault = canRead
  setting.capabilities.reset = canRead
  setting.capabilities.defaultTemporarilyUnavailable = row.defaultTemporarilyUnavailable == true
end

local function normalizeRow(categoryId, row, rowIndex, usedIds)
  local kind = rowKind(row.kind)
  local key = safeText(row.key, "row_" .. tostring(rowIndex))
  local sourceId = reserveSettingId(categoryId, key, rowIndex, usedIds)
  local setting = {
    id = sourceId,
    key = key,
    label = safeText(row.label, key),
    description = safeText(row.tooltip, ""),
    rawType = kind,
    frameworkKind = kind,
    capabilities = {
      read = true,
      write = true,
      draft = true,
      reset = false,
      canReadDefault = false,
      canResetToDefault = false,
      defaultTemporarilyUnavailable = row.defaultTemporarilyUnavailable == true,
    },
    supported = true,
    errors = {},
  }

  if kind == "toggle" then
    setting.type = "bool"
    setting.value = row.boolValue == true
    if row.hasDefault == true then
      setting.defaultValue = row.defaultBoolValue == true
    end
  elseif kind == "slider" or kind == "stepper" then
    local isInteger = row.isInt == true
    if isInteger then
      setting.type = "int"
      setting.value = tonumber(row.intValue) or 0
      if row.hasDefault == true then
        setting.defaultValue = tonumber(row.defaultIntValue) or 0
      end
      setting.format = "%d"
    else
      setting.type = "float"
      setting.value = tonumber(row.floatValue) or 0
      if row.hasDefault == true then
        setting.defaultValue = tonumber(row.defaultFloatValue) or 0
      end
      setting.format = "%.2f"
    end
    setting.min = tonumber(row.minValue) or 0
    setting.max = tonumber(row.maxValue) or 100
    setting.step = tonumber(row.stepValue) or 1
  elseif kind == "dropdown" then
    setting.type = "select"
    setting.value = (tonumber(row.intValue) or 0) + 1
    setting.elements = stringArray(row.options)
    if row.hasDefault == true then
      setting.defaultValue = (tonumber(row.defaultIntValue) or 0) + 1
    end
  elseif kind == "keybind" then
    setting.type = "key"
    setting.value = safeText(row.keyValue, "IK_None")
    setting.rcfKeybind = {
      localOnly = row.localOnly == true,
      pad = row.pad == true,
      anyDevice = row.anyDevice == true,
    }
    if row.hasDefault == true then
      setting.defaultValue = safeText(row.defaultKeyValue, "IK_None")
    end
  elseif kind == "button" then
    setting.type = "action"
    setting.value = safeText(row.label, "Run")
    setting.capabilities.action = true
    setting.capabilities.write = false
    setting.capabilities.draft = false
  else
    markReadOnly(setting, kind)
  end

  finalizeDefaultCapabilities(setting, row)

  return setting, {
    key = key,
    kind = kind,
    type = setting.type,
  }
end

function Provider.loadMod(sourceModId)
  local ok, categories, err = call("GetCategories", sourceModId)
  if not ok or type(categories) ~= "table" then
    return nil, err or tostring(categories)
  end

  settingHandles[sourceModId] = {}
  local normalized = {}
  local usedIds = {}
  for categoryIndex, categoryRecord in ipairs(categories) do
    local categoryId = safeText(categoryRecord.id, "category_" .. tostring(categoryIndex))
    local category = {
      id = categoryId,
      name = safeText(categoryRecord.name, categoryId),
      capabilities = { read = true },
      settings = {},
    }

    for rowIndex, row in ipairs(categoryRecord.rows or {}) do
      local setting, handle = normalizeRow(categoryId, row, rowIndex, usedIds)
      settingHandles[sourceModId][setting.id] = handle
      category.settings[#category.settings + 1] = setting
    end

    if #category.settings > 0 then
      normalized[#normalized + 1] = category
    end
  end

  local fingerprint = categoriesFingerprint(categories)
  schemaFingerprints[sourceModId] = fingerprint
  return { revision = fingerprint, categories = normalized }, nil
end

local function setValue(sourceModId, handle, value)
  if handle.kind == "toggle" then
    return call("SetBool", sourceModId, handle.key, value == true)
  end
  if handle.kind == "dropdown" then
    return call("SetInt", sourceModId, handle.key, math.max(0, (tonumber(value) or 1) - 1))
  end
  if handle.kind == "keybind" then
    return call("SetKey", sourceModId, handle.key, safeText(value, "IK_None"))
  end
  if handle.kind == "slider" or handle.kind == "stepper" then
    if handle.type == "int" then
      return call("SetInt", sourceModId, handle.key, math.floor(tonumber(value) or 0))
    end
    return call("SetFloat", sourceModId, handle.key, tonumber(value) or 0)
  end
  return false, nil, "Unsupported RCF setting kind: " .. tostring(handle.kind)
end

local function rollback(sourceModId, applied)
  local complete = true
  for index = #applied, 1, -1 do
    local item = applied[index]
    local ok, result = setValue(sourceModId, item.handle, item.previousValue)
    complete = complete and ok == true and result == true
  end
  local committed, commitResult = call("Commit", sourceModId)
  return complete and committed == true and commitResult == true
end

function Provider.applyBatch(sourceModId, changes)
  local handles = settingHandles[sourceModId]
  if handles == nil then
    return nil, "RCF mod schema is not loaded."
  end

  for _, change in ipairs(changes) do
    if handles[change.id] == nil then
      return nil, "Unknown RCF setting: " .. tostring(change.id)
    end
  end

  local applied = {}
  for _, change in ipairs(changes) do
    local handle = handles[change.id]
    local ok, result, err = setValue(sourceModId, handle, change.value)
    if not ok or result ~= true then
      local rolledBack = rollback(sourceModId, applied)
      return {
        ok = false,
        atomic = false,
        partial = not rolledBack,
        error = err or "RCF rejected a setting value.",
      },
        err or "RCF rejected a setting value."
    end
    applied[#applied + 1] = {
      id = change.id,
      handle = handle,
      previousValue = change.previousValue,
    }
  end

  local committed, commitResult, commitError = call("Commit", sourceModId)
  if not committed or commitResult ~= true then
    local rolledBack = rollback(sourceModId, applied)
    return {
      ok = false,
      atomic = false,
      partial = not rolledBack,
      error = commitError or "RCF failed to persist the transaction.",
    },
      commitError or "RCF failed to persist the transaction."
  end

  local okSchema, categories = call("GetCategories", sourceModId)
  local nextFingerprint = schemaFingerprints[sourceModId]
  if okSchema then
    nextFingerprint = categoriesFingerprint(categories)
  end

  local schemaChanged = schemaFingerprints[sourceModId] ~= nextFingerprint
  schemaFingerprints[sourceModId] = nextFingerprint

  local appliedIds = {}
  for _, item in ipairs(applied) do
    appliedIds[#appliedIds + 1] = item.id
  end
  return {
    ok = true,
    atomic = false,
    partial = false,
    appliedIds = appliedIds,
    schemaChanged = schemaChanged,
  },
    nil
end

function Provider.invokeAction(sourceModId, settingId)
  local handles = settingHandles[sourceModId]
  local handle = nil
  if handles ~= nil then
    handle = handles[settingId]
  end

  if handle == nil or handle.kind ~= "button" then
    return nil, "Setting is not an RCF button action."
  end
  local ok, result, err = call("InvokeButton", sourceModId, handle.key)
  if not ok or result ~= true then
    return nil, err or "RCF button action failed."
  end

  return { ok = true, schemaChanged = true }, nil
end

function Provider.closeMod(sourceModId)
  settingHandles[sourceModId] = nil
  schemaFingerprints[sourceModId] = nil
  return true, nil
end

function Provider.poll()
  local adapter = helper()
  if adapter == nil then
    if lastIndexFingerprint ~= nil then
      lastIndexFingerprint = nil
      return { changed = true }, nil
    end

    return false, nil
  end

  local okAvailable, available = call("IsAvailable")
  if not okAvailable or available ~= true then
    if lastIndexFingerprint ~= nil then
      lastIndexFingerprint = nil
      return { changed = true }, nil
    end

    return false, nil
  end

  local entries = readMods()
  if entries == nil then
    return false, nil
  end

  local fingerprint = modsFingerprint(entries, readRevision())
  local changed = fingerprint ~= lastIndexFingerprint

  local currentTime = 0
  if type(os.clock) == "function" then
    currentTime = os.clock()
  end

  if currentTime - lastSchemaPollAt >= 2.0 then
    lastSchemaPollAt = currentTime
    for sourceModId, previousFingerprint in pairs(schemaFingerprints) do
      -- RCF providers may rebuild lazily. A failed poll is retried later instead
      -- of invalidating the schema that MCM already loaded successfully.
      local ok, categories = call("GetCategories", sourceModId)
      if ok and type(categories) == "table" then
        local currentFingerprint = categoriesFingerprint(categories)
        if currentFingerprint ~= previousFingerprint then
          schemaFingerprints[sourceModId] = currentFingerprint
          schemaRevision = schemaRevision + 1
          changed = true
        end
      end
    end
  end
  return { changed = changed }, nil
end

function Provider.shutdown()
  settingHandles = {}
  schemaFingerprints = {}
  schemaRevision = 0
  lastSchemaPollAt = 0
  lastIndexFingerprint = nil
end

return Provider
