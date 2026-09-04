local Util = require("modules/util")

local Provider = {
  id = "ms",
  registrationKey = "mcm.bridge.mod-settings",
  name = "Mod Settings",
  shortName = "MS",
  apiVersion = 2,
  pollInterval = 2.0,
  capabilities = {
    index = true,
    lazy = true,
    draft = true,
    commit = true,
    atomicApply = true,
    uiExtensionSurface = "mod_settings",
  },
}

local modHandles = {}
local settingHandles = {}
local schemaFingerprints = {}
local lastIndexFingerprint = nil

local cnameToString = Util.cnameToString
local cname = Util.cname
local localize = Util.localize

local function safeMethod(object, methodName, ...)
  if object == nil or type(object[methodName]) ~= "function" then
    return false, nil
  end

  local args = { ... }
  return pcall(function()
    return object[methodName](object, table.unpack(args))
  end)
end

local function mutationMethod(object, methodName, ...)
  local ok, result = safeMethod(object, methodName, ...)
  if not ok then
    return false, result
  end

  if result == false then
    return false, methodName .. " returned false."
  end

  return true, result
end

local function methodValue(object, methodName, fallback, ...)
  local ok, value = safeMethod(object, methodName, ...)
  if ok then
    return value
  end

  return fallback
end

local function helperCall(methodName, value)
  local helper = MCMModSettingsAdapter
  if helper ~= nil and type(helper[methodName]) == "function" then
    local ok, result = pcall(helper[methodName], value)
    if ok and type(result) == "string" then
      return result
    end
  end

  return ""
end

local function resolveName(value)
  local resolved = helperCall("ResolveName", value)
  if resolved ~= "" then
    return resolved
  end

  return localize(value)
end

local function resolveVarName(var, index)
  local resolved = helperCall("ResolveVarName", var)
  if resolved ~= "" then
    return resolved
  end

  local raw = methodValue(var, "GetVarName", nil) or methodValue(var, "GetName", nil)
  resolved = cnameToString(raw)
  if resolved ~= "" then
    return resolved
  end

  return "setting_" .. tostring(index)
end

local function resolveVarLabel(var, fallback)
  local resolved = helperCall("ResolveVarDisplayName", var)
  if resolved ~= "" then
    return resolved
  end

  resolved = localize(methodValue(var, "GetDisplayName", nil))
  if resolved ~= "" then
    return resolved
  end

  return fallback
end

local function resolveVarDescription(var)
  local resolved = helperCall("ResolveVarDescription", var)
  if resolved ~= "" then
    return resolved
  end

  return localize(methodValue(var, "GetDescription", ""))
end

local function isA(var, className)
  local ok, result = safeMethod(var, "IsA", className)
  return ok and result == true
end

local function typeContains(typeName, needle)
  return string.find(tostring(typeName), needle, 1, true) ~= nil
end

local function baseSetting(sourceId, var, varId)
  local disabled = methodValue(var, "IsDisabled", false) == true
  return {
    id = sourceId,
    key = varId,
    label = resolveVarLabel(var, varId),
    description = resolveVarDescription(var),
    rawType = tostring(methodValue(var, "GetType", "unknown")),
    capabilities = {
      read = true,
      write = not disabled,
      draft = not disabled,
      reset = false,
      canReadDefault = false,
      canResetToDefault = false,
    },
    supported = not disabled,
    disabled = disabled,
    errors = {},
  }
end

local function markUnsupported(setting, reason, value, settingType)
  setting.type = settingType or "custom"
  if value == nil then
    setting.value = ""
  else
    setting.value = value
  end
  setting.supported = false
  setting.capabilities.write = false
  setting.capabilities.draft = false
  setting.capabilities.reset = false
  setting.capabilities.canReadDefault = false
  setting.capabilities.canResetToDefault = false
  setting.defaultValue = nil
  setting.unsupportedReason = reason
  return setting
end

local function publishDefault(setting, value)
  if setting.supported == false or setting.disabled == true or value == nil then
    return false
  end

  setting.defaultValue = value
  setting.capabilities.reset = true
  setting.capabilities.canReadDefault = true
  setting.capabilities.canResetToDefault = true
  return true
end

local function normalizeEnum(configVar, setting)
  local ok, values = safeMethod(configVar, "GetValues")
  if not ok or type(values) ~= "table" then
    return markUnsupported(setting, "Cannot read Mod Settings enum values.")
  end

  setting.type = "select"
  setting.elements = {}
  for index = 1, #values do
    local display = methodValue(configVar, "GetDisplayValue", nil, index - 1) or values[index]
    setting.elements[index] = localize(display)
  end
  setting.value = (tonumber(methodValue(configVar, "GetIndex", 0)) or 0) + 1
  local defaultOk, defaultIndex = safeMethod(configVar, "GetDefaultIndex")
  defaultIndex = tonumber(defaultIndex)
  if defaultOk and defaultIndex ~= nil then
    local normalizedDefault = math.floor(defaultIndex) + 1
    if normalizedDefault >= 1 and normalizedDefault <= #setting.elements then
      publishDefault(setting, normalizedDefault)
    end
  end
  setting.frameworkKind = "enum"
  return setting
end

local function normalizeScalar(configVar, setting, expectedKind)
  local ok, value = safeMethod(configVar, "GetValue")
  if not ok then
    return markUnsupported(setting, "Cannot read Mod Settings value.")
  end

  if expectedKind == "bool" then
    if type(value) ~= "boolean" then
      return markUnsupported(
        setting,
        "Mod Settings returned a non-boolean value for a boolean setting.",
        tostring(value)
      )
    end

    setting.type = "bool"
    setting.value = value == true
    local defaultOk, defaultValue = safeMethod(configVar, "GetDefaultValue")
    if defaultOk and type(defaultValue) == "boolean" then
      publishDefault(setting, defaultValue)
    end
    setting.frameworkKind = "bool"
    return setting
  end

  if expectedKind == "int" or expectedKind == "float" then
    local numericValue = tonumber(value)
    if numericValue == nil then
      return markUnsupported(
        setting,
        "Mod Settings returned a non-numeric value for a numeric setting.",
        tostring(value)
      )
    end

    local step = tonumber(methodValue(configVar, "GetStepValue", 1)) or 1
    local isInt = expectedKind == "int"
    if isInt then
      setting.type = "int"
      setting.format = "%d"
      setting.frameworkKind = "int"
    else
      setting.type = "float"
      setting.frameworkKind = "float"
    end

    setting.value = numericValue
    local defaultOk, defaultValue = safeMethod(configVar, "GetDefaultValue")
    defaultValue = tonumber(defaultValue)
    if defaultOk and defaultValue ~= nil then
      publishDefault(setting, defaultValue)
    end
    setting.min = tonumber(methodValue(configVar, "GetMinValue", 0)) or 0
    setting.max = tonumber(methodValue(configVar, "GetMaxValue", 100)) or 100
    setting.step = step
    return setting
  end

  return markUnsupported(setting, "Unsupported Mod Settings scalar value.", tostring(value or ""))
end

local function reserveSettingId(categoryId, varId, index, usedIds)
  local sourceId = categoryId .. ":" .. varId
  if usedIds[sourceId] then
    sourceId = sourceId .. ":" .. tostring(index)
  end

  usedIds[sourceId] = true
  return sourceId
end

local function resolveConfigVarKind(configVar, rawType)
  -- List-backed enum type names contain Float/Int, so this order is part of the
  -- bridge contract and must remain more specific before more general.
  if isA(configVar, "ModConfigVarBool") or typeContains(rawType, "Bool") then
    return "bool"
  end
  if
    isA(configVar, "ModConfigVarEnum")
    or typeContains(rawType, "IntList")
    or typeContains(rawType, "FloatList")
    or typeContains(rawType, "StringList")
    or typeContains(rawType, "NameList")
  then
    return "enum"
  end
  if isA(configVar, "ModConfigVarFloat") or typeContains(rawType, "Float") then
    return "float"
  end
  if isA(configVar, "ModConfigVarInt32") or typeContains(rawType, "Int") then
    return "int"
  end
  if isA(configVar, "ModConfigVarKeyBinding") then
    return "key"
  end

  return "unsupported"
end

local function normalizeVar(sourceModId, categoryId, configVar, index, usedIds)
  local varId = resolveVarName(configVar, index)
  local sourceId = reserveSettingId(categoryId, varId, index, usedIds)

  local setting = baseSetting(sourceId, configVar, varId)
  local rawType = setting.rawType
  local kind = resolveConfigVarKind(configVar, rawType)

  if kind == "bool" then
    setting = normalizeScalar(configVar, setting, "bool")
  elseif kind == "enum" then
    setting = normalizeEnum(configVar, setting)
  elseif kind == "float" then
    setting = normalizeScalar(configVar, setting, "float")
  elseif kind == "int" then
    setting = normalizeScalar(configVar, setting, "int")
  elseif kind == "key" then
    local ok, value = safeMethod(configVar, "GetValueName")
    setting.type = "key"
    if ok then
      setting.value = cnameToString(value)
    else
      setting.value = ""
    end

    local defaultOk, defaultValue = safeMethod(configVar, "GetDefaultValueName")
    if defaultOk and defaultValue ~= nil then
      publishDefault(setting, cnameToString(defaultValue))
    end
    setting.frameworkKind = "key"
    if not ok then
      markUnsupported(setting, "Cannot read Mod Settings keybinding.", setting.value, "key")
    end
  else
    markUnsupported(setting, "Unsupported Mod Settings type: " .. rawType)
  end

  settingHandles[sourceModId][sourceId] = {
    configVar = configVar,
    setting = setting,
  }
  return setting
end

local function logNormalizationFailure(context, sourceModId, categoryId, index, err)
  if type(context) ~= "table" or type(context.log) ~= "table" then
    return
  end

  if type(context.log.warn) ~= "function" then
    return
  end

  context.log.warn(
    string.format(
      "MS bridge skipped %s/%s setting #%d: %s",
      tostring(sourceModId),
      tostring(categoryId),
      index,
      tostring(err)
    )
  )
end

local function collectVars(
  sourceModId,
  modCName,
  categoryCName,
  categoryId,
  categoryName,
  usedIds,
  context
)
  local ok, vars = pcall(function()
    return ModSettings.GetVars(modCName, categoryCName)
  end)
  if not ok or type(vars) ~= "table" then
    return nil, tostring(vars)
  end

  local settings = {}
  for index, var in ipairs(vars) do
    if methodValue(var, "IsVisible", true) ~= false then
      local okSetting, setting = pcall(normalizeVar, sourceModId, categoryId, var, index, usedIds)
      if okSetting and type(setting) == "table" then
        settings[#settings + 1] = setting
      elseif not okSetting then
        logNormalizationFailure(context, sourceModId, categoryId, index, setting)
      end
    end
  end

  if #settings == 0 then
    return nil, nil
  end

  return {
    id = categoryId,
    name = categoryName,
    capabilities = { read = true },
    settings = settings,
  },
    nil
end

local function frameworkAvailable()
  return ModSettings ~= nil
    and type(ModSettings.GetMods) == "function"
    and type(ModSettings.GetCategories) == "function"
    and type(ModSettings.GetVars) == "function"
end

local function getModEntries()
  local ok, values = pcall(function()
    return ModSettings.GetMods()
  end)
  if not ok or type(values) ~= "table" then
    return nil, tostring(values)
  end

  local entries = {}
  for index, modCName in ipairs(values) do
    local sourceId = cnameToString(modCName)
    if sourceId == "" then
      sourceId = "mod_" .. tostring(index)
    end

    entries[#entries + 1] = {
      sourceId = sourceId,
      modCName = modCName,
      name = resolveName(modCName),
    }
  end
  return entries, nil
end

local function indexFingerprint(entries)
  local parts = {}
  for _, entry in ipairs(entries or {}) do
    parts[#parts + 1] = entry.sourceId .. "=" .. tostring(entry.name)
  end
  return table.concat(parts, "|")
end

local function schemaFingerprint(modCName)
  local parts = {}

  -- Fingerprints only drive stale-schema polling. A temporary category read
  -- failure must not make the currently loaded schema unusable.
  local function addCategory(categoryCName, categoryId)
    local ok, vars = pcall(function()
      return ModSettings.GetVars(modCName, categoryCName)
    end)
    if ok and type(vars) == "table" then
      for index, var in ipairs(vars) do
        parts[#parts + 1] = table.concat({
          categoryId,
          resolveVarName(var, index),
          tostring(methodValue(var, "IsVisible", true)),
          tostring(methodValue(var, "IsDisabled", false)),
          tostring(methodValue(var, "GetType", "unknown")),
        }, ":")
      end
    end
  end

  addCategory(cname("None"), "None")
  local ok, categories = pcall(function()
    return ModSettings.GetCategories(modCName)
  end)
  if ok and type(categories) == "table" then
    for _, categoryCName in ipairs(categories) do
      addCategory(categoryCName, cnameToString(categoryCName))
    end
  end
  return table.concat(parts, "|")
end

function Provider.probe()
  if not frameworkAvailable() then
    return {
      detected = false,
      ready = false,
      state = "absent",
      message = "Mod Settings is not loaded.",
    }
  end
  return { detected = true, ready = true, state = "ready", revision = lastIndexFingerprint }
end

function Provider.listMods()
  local entries, err = getModEntries()
  if entries == nil then
    return nil, err
  end

  modHandles = {}
  local mods = {}
  for _, entry in ipairs(entries) do
    modHandles[entry.sourceId] = entry.modCName
    local displayName = entry.name
    if displayName == "" then
      displayName = entry.sourceId
    end

    mods[#mods + 1] = {
      id = entry.sourceId,
      name = displayName,
      revision = schemaFingerprints[entry.sourceId],
      capabilities = Provider.capabilities,
    }
  end
  lastIndexFingerprint = indexFingerprint(entries)
  return { revision = lastIndexFingerprint, complete = true, mods = mods }, nil
end

function Provider.loadMod(sourceModId, context)
  local modCName = modHandles[sourceModId]
  if modCName == nil then
    return nil, "Unknown Mod Settings mod: " .. tostring(sourceModId)
  end

  settingHandles[sourceModId] = {}
  local categories = {}
  local usedIds = {}
  local general, generalError =
    collectVars(sourceModId, modCName, cname("None"), "None", "General", usedIds, context)
  if generalError ~= nil then
    return nil, generalError
  end
  if general ~= nil then
    categories[#categories + 1] = general
  end

  local ok, categoryList = pcall(function()
    return ModSettings.GetCategories(modCName)
  end)
  if not ok or type(categoryList) ~= "table" then
    return nil, tostring(categoryList)
  end

  for index, categoryCName in ipairs(categoryList) do
    local categoryId = cnameToString(categoryCName)
    if categoryId == "" then
      categoryId = "category_" .. tostring(index)
    end

    local categoryName = resolveName(categoryCName)
    if categoryName == "" then
      categoryName = categoryId
    end

    local category, categoryError =
      collectVars(sourceModId, modCName, categoryCName, categoryId, categoryName, usedIds, context)
    if categoryError ~= nil then
      return nil, categoryError
    end
    if category ~= nil then
      categories[#categories + 1] = category
    end
  end

  local fingerprint = schemaFingerprint(modCName)
  schemaFingerprints[sourceModId] = fingerprint
  return {
    name = resolveName(modCName),
    revision = fingerprint,
    categories = categories,
  },
    nil
end

local function applyOne(handle, change)
  local setting = handle.setting
  local configVar = handle.configVar
  if setting.disabled or not setting.supported then
    return false, setting.unsupportedReason or "Setting is read-only."
  end

  if
    setting.frameworkKind == "bool"
    or setting.frameworkKind == "int"
    or setting.frameworkKind == "float"
  then
    return mutationMethod(configVar, "SetValue", change.value)
  end

  if setting.frameworkKind == "enum" then
    return mutationMethod(configVar, "SetIndex", (tonumber(change.value) or 1) - 1)
  end

  if setting.frameworkKind == "key" then
    return mutationMethod(configVar, "SetValueName", cname(change.value))
  end

  return false, "Unsupported Mod Settings kind: " .. tostring(setting.frameworkKind)
end

local function ensureLiveOwner(configVar)
  local helper = MCMModSettingsAdapter
  if helper == nil or type(helper.EnsureVarOwner) ~= "function" then
    return false
  end

  local ok, result = pcall(helper.EnsureVarOwner, configVar)
  return ok and result == true
end

local function rejectChanges()
  if type(ModSettings.RejectChanges) ~= "function" then
    return false
  end

  local ok, result = pcall(function()
    return ModSettings.RejectChanges()
  end)
  return ok and result ~= false
end

function Provider.applyBatch(sourceModId, changes)
  local handles = settingHandles[sourceModId]
  local modCName = modHandles[sourceModId]
  if handles == nil or modCName == nil then
    return nil, "Mod schema is not loaded."
  end

  for _, change in ipairs(changes) do
    ensureLiveOwner(handles[change.id].configVar)
  end

  for _, change in ipairs(changes) do
    if handles[change.id] == nil then
      return nil, "Unknown setting: " .. tostring(change.id)
    end
  end

  for _, change in ipairs(changes) do
    local ok, err = applyOne(handles[change.id], change)
    if not ok then
      local rolledBack = rejectChanges()
      return {
        ok = false,
        atomic = rolledBack,
        partial = not rolledBack,
        error = tostring(err),
      },
        tostring(err)
    end
  end

  local committed, commitResult = pcall(function()
    return ModSettings.AcceptChanges()
  end)
  if not committed or commitResult == false then
    local commitError = tostring(commitResult)
    if committed then
      commitError = "ModSettings.AcceptChanges returned false."
    end
    local rolledBack = rejectChanges()
    return {
      ok = false,
      atomic = rolledBack,
      partial = not rolledBack,
      error = tostring(commitError),
    },
      tostring(commitError)
  end

  local appliedIds = {}
  for _, change in ipairs(changes) do
    appliedIds[#appliedIds + 1] = change.id
  end

  local nextFingerprint = schemaFingerprint(modCName)
  local schemaChanged = schemaFingerprints[sourceModId] ~= nextFingerprint
  schemaFingerprints[sourceModId] = nextFingerprint
  return {
    ok = true,
    atomic = true,
    partial = false,
    appliedIds = appliedIds,
    schemaChanged = schemaChanged,
  },
    nil
end

function Provider.closeMod(sourceModId)
  settingHandles[sourceModId] = nil
  schemaFingerprints[sourceModId] = nil
  return true, nil
end

function Provider.poll()
  if not frameworkAvailable() then
    if lastIndexFingerprint ~= nil then
      lastIndexFingerprint = nil
      return { changed = true }, nil
    end

    return false, nil
  end

  local entries = getModEntries()
  if entries == nil then
    return false, nil
  end

  return { changed = indexFingerprint(entries) ~= lastIndexFingerprint }, nil
end

function Provider.shutdown()
  modHandles = {}
  settingHandles = {}
  schemaFingerprints = {}
  lastIndexFingerprint = nil
end

return Provider
