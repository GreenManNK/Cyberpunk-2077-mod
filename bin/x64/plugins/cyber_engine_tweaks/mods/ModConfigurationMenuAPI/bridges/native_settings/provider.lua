local Util = require("modules/util")

local Provider = {
  id = "cet",
  registrationKey = "mcm.bridge.native-settings-ui",
  name = "Native Settings UI",
  shortName = "CET",
  apiVersion = 2,
  pollInterval = 1.0,
  capabilities = {
    index = true,
    lazy = true,
    draft = true,
    action = true,
    commit = false,
    atomicApply = false,
    dynamicSchema = true,
    uiExtensionSurface = "native_settings",
  },
}

local settingHandles = {}
local tabFingerprints = {}
local tabSnapshots = {}
local publicationFingerprints = {}
local lastRegistryFingerprint = nil
local localize = Util.localize

local function nativeSettings()
  if type(GetMod) ~= "function" then
    return nil
  end

  return GetMod("nativeSettings") or GetMod("NativeSettings")
end

local function nativeScrollPosition(framework)
  if type(framework) ~= "table" or framework.settingsMainController == nil then
    return nil
  end

  local ok, value = pcall(function()
    local root = framework.settingsMainController:GetRootWidget()
    local scrollArea = root:GetWidget(StringToName("wrapper/wrapper/MainScrollingArea/scroll_area"))
    return scrollArea:GetVerticalScrollPosition()
  end)
  if not ok then
    return nil
  end
  return tonumber(value)
end

local function setNativeScrollPosition(framework, value)
  value = tonumber(value)
  if value == nil or type(framework) ~= "table" or framework.settingsMainController == nil then
    return false
  end

  local ok = pcall(function()
    local root = framework.settingsMainController:GetRootWidget()
    local scrollingArea = root:GetWidget(StringToName("wrapper/wrapper/MainScrollingArea"))
    scrollingArea:GetController():SetScrollPosition(math.max(0, math.min(1, value)))
  end)
  return ok
end

local function sortedKeys(values, predicate)
  local keys = {}
  if type(values) ~= "table" then
    return keys
  end

  for key, value in pairs(values) do
    if predicate == nil or predicate(key, value) then
      keys[#keys + 1] = key
    end
  end

  table.sort(keys, function(left, right)
    if type(left) == "number" and type(right) == "number" then
      return left < right
    end

    return tostring(left):lower() < tostring(right):lower()
  end)
  return keys
end

local function orderedOptions(options)
  local result = {}
  for _, key in
    ipairs(sortedKeys(options, function(key, value)
      return type(key) == "number" and type(value) == "table"
    end))
  do
    result[#result + 1] = {
      index = key,
      option = options[key],
    }
  end
  return result
end

local function orderedArrayValues(values)
  local result = {}
  for _, key in
    ipairs(sortedKeys(values, function(key)
      return type(key) == "number"
    end))
  do
    result[#result + 1] = values[key]
  end
  return result
end

local function orderedSubcategories(tab)
  local result = {}
  local seen = {}
  local keys = {}
  local subcategories = {}
  if type(tab) == "table" then
    keys = tab.keys
    subcategories = tab.subcategories
  end
  if type(keys) ~= "table" then
    keys = {}
  end
  if type(subcategories) ~= "table" then
    subcategories = {}
  end

  for _, value in ipairs(orderedArrayValues(keys)) do
    local subPath = tostring(value)
    local subcategory = subcategories[subPath]
    if type(subcategory) == "table" and not seen[subPath] then
      seen[subPath] = true
      result[#result + 1] = {
        path = subPath,
        value = subcategory,
      }
    end
  end

  for _, subPath in
    ipairs(sortedKeys(subcategories, function(_, value)
      return type(value) == "table"
    end))
  do
    subPath = tostring(subPath)
    if not seen[subPath] then
      seen[subPath] = true
      result[#result + 1] = {
        path = subPath,
        value = subcategories[subPath],
      }
    end
  end
  return result
end

local function optionFingerprint(categoryPath, item)
  local option = item.option
  return table.concat({
    tostring(categoryPath),
    tostring(item.index),
    tostring(option.type or "custom"),
    tostring(option.fullPath or option.path or ""),
    tostring(option.label or option.buttonText or ""),
    tostring(option.min or ""),
    tostring(option.max or ""),
    tostring(option.step or ""),
    tostring(option.isHold == true),
    tostring(#(option.elements or {})),
  }, ":")
end

local function tabFingerprint(tabPath, tab)
  local label = ""
  local options = {}
  if type(tab) == "table" then
    label = tostring(tab.label or "")
    options = tab.options
  end

  local parts = { tostring(tabPath), label }
  for _, item in ipairs(orderedOptions(options)) do
    parts[#parts + 1] = optionFingerprint("__main", item)
  end
  for _, sub in ipairs(orderedSubcategories(tab)) do
    parts[#parts + 1] = "sub:" .. sub.path .. ":" .. tostring(sub.value.label or "")
    for _, item in ipairs(orderedOptions(sub.value.options or {})) do
      parts[#parts + 1] = optionFingerprint(sub.path, item)
    end
  end
  return table.concat(parts, "|")
end

local function registryFingerprint(registry)
  local parts = {}
  for _, tabPath in
    ipairs(sortedKeys(registry, function(key, value)
      return tostring(key) ~= "noMod" and type(value) == "table"
    end))
  do
    parts[#parts + 1] = tabFingerprint(tabPath, registry[tabPath])
  end
  return table.concat(parts, "||")
end

local function tabOptionCount(tab)
  if type(tab) ~= "table" then
    return 0
  end

  local count = #orderedOptions(tab.options)
  for _, sub in ipairs(orderedSubcategories(tab)) do
    count = count + #orderedOptions(sub.value.options)
  end
  return count
end

local function cloneSnapshotValue(value, seen, fieldName)
  if fieldName == "controller" then
    return nil
  end
  if type(value) ~= "table" then
    return value
  end

  seen = seen or {}
  if seen[value] ~= nil then
    return seen[value]
  end

  local copy = {}
  seen[value] = copy
  for key, item in pairs(value) do
    if key ~= "controller" then
      copy[key] = cloneSnapshotValue(item, seen, key)
    end
  end
  return setmetatable(copy, getmetatable(value))
end

local function captureTab(tabPath, tab, force)
  local optionCount = tabOptionCount(tab)
  if optionCount == 0 then
    return nil
  end

  local id = tostring(tabPath)
  local fingerprint = tabFingerprint(id, tab)
  local existing = tabSnapshots[id]
  if
    force ~= true
    and existing ~= nil
    and existing.source == tab
    and existing.fingerprint == fingerprint
  then
    return existing.tab
  end

  local copy = cloneSnapshotValue(tab)
  tabSnapshots[id] = {
    tab = copy,
    source = tab,
    optionCount = optionCount,
    fingerprint = fingerprint,
  }
  return copy
end

local function updateCapturedTab(tabPath, tab)
  local id = tostring(tabPath)
  local snapshot = tabSnapshots[id]
  if snapshot ~= nil and snapshot.tab == tab then
    snapshot.optionCount = tabOptionCount(tab)
    snapshot.fingerprint = tabFingerprint(id, tab)
    return tab
  end
  return captureTab(id, tab, true)
end

local function captureRegistry(registry, force)
  local captured = 0
  if type(registry) ~= "table" then
    return captured
  end

  for _, tabPath in
    ipairs(sortedKeys(registry, function(key, value)
      return tostring(key) ~= "noMod" and type(value) == "table"
    end))
  do
    if captureTab(tabPath, registry[tabPath], force) ~= nil then
      captured = captured + 1
    end
  end
  return captured
end

local function publicationRegistrySnapshot()
  if type(GetMod) ~= "function" then
    return nil
  end

  local lifecycle = GetMod("00_MCMNativeSettingsLifecycle")
  if type(lifecycle) ~= "table" or type(lifecycle.getRegistrySnapshot) ~= "function" then
    return nil
  end

  local ok, registry = pcall(lifecycle.getRegistrySnapshot)
  if not ok or type(registry) ~= "table" then
    return nil
  end
  return registry
end

local function capturePublicationSnapshots()
  local registry = publicationRegistrySnapshot()
  local captured = 0
  if registry == nil then
    return captured
  end

  for _, tabPath in
    ipairs(sortedKeys(registry, function(key, value)
      return tostring(key) ~= "noMod" and type(value) == "table"
    end))
  do
    local id = tostring(tabPath)
    local tab = registry[tabPath]
    local fingerprint = tabFingerprint(id, tab)
    if fingerprint ~= publicationFingerprints[id] and captureTab(id, tab, true) ~= nil then
      publicationFingerprints[id] = fingerprint
      captured = captured + 1
    end
  end
  return captured
end

local function effectiveTab(registry, tabPath)
  capturePublicationSnapshots()

  local id = tostring(tabPath)
  local live = type(registry) == "table" and registry[id] or nil
  if tabOptionCount(live) > 0 then
    captureTab(id, live)
    return live, true
  end

  local snapshot = tabSnapshots[id]
  if snapshot ~= nil then
    return snapshot.tab, false
  end
  return live, false
end

local function effectiveRegistry(registry)
  capturePublicationSnapshots()

  local result = {}
  local seen = {}

  if type(registry) == "table" then
    for _, tabPath in
      ipairs(sortedKeys(registry, function(key, value)
        return tostring(key) ~= "noMod" and type(value) == "table"
      end))
    do
      local id = tostring(tabPath)
      local tab = effectiveTab(registry, id)
      if type(tab) == "table" then
        result[id] = tab
        seen[id] = true
      end
    end
  end

  for _, tabPath in ipairs(sortedKeys(tabSnapshots)) do
    if not seen[tabPath] then
      result[tabPath] = tabSnapshots[tabPath].tab
    end
  end
  return result
end

local function withAvailableTab(sourceModId, callback)
  local framework = nativeSettings()
  if framework == nil or type(framework.data) ~= "table" then
    return false, "Native Settings UI registry is unavailable."
  end

  local id = tostring(sourceModId)
  local registry = framework.data
  capturePublicationSnapshots()
  local live = registry[id]
  if tabOptionCount(live) > 0 then
    captureTab(id, live)
    local ok, result, message = pcall(callback, framework, live, false)
    updateCapturedTab(id, registry[id] or live)
    if not ok then
      return false, tostring(result)
    end
    return true, result, message
  end

  local snapshot = tabSnapshots[id]
  if snapshot == nil or type(snapshot.tab) ~= "table" then
    return false, "Native Settings UI has not published this mod's settings yet."
  end

  local previous = registry[id]
  registry[id] = snapshot.tab
  local ok, result, message = pcall(callback, framework, snapshot.tab, true)
  local activeTab = registry[id]
  if activeTab == snapshot.tab then
    updateCapturedTab(id, activeTab)
  elseif tabOptionCount(activeTab) > 0 then
    captureTab(id, activeTab)
  end
  registry[id] = previous

  if not ok then
    return false, tostring(result)
  end
  return true, result, message
end

local function currentValue(option)
  if option.type == "switch" then
    return option.state == true
  end
  if option.type == "rangeInt" or option.type == "rangeFloat" then
    return tonumber(option.currentValue)
  end
  if option.type == "selectorString" then
    return tonumber(option.selectedElementIndex)
  end
  if option.type == "keyBinding" then
    if option.value == nil then
      return ""
    end

    return tostring(option.value)
  end

  return option.buttonText or ""
end

local function optionCollection(tab, categoryPath)
  if type(tab) ~= "table" then
    return nil
  end
  if categoryPath == "__main" then
    return tab.options
  end
  if type(tab.subcategories) ~= "table" then
    return nil
  end

  local category = tab.subcategories[categoryPath]
  if type(category) ~= "table" then
    return nil
  end
  return category.options
end

local function optionMatchesHandle(option, handle)
  if type(option) ~= "table" or type(handle) ~= "table" then
    return false
  end
  if tostring(option.type or "unknown") ~= handle.rawType then
    return false
  end
  if handle.stablePath ~= nil then
    return tostring(option.fullPath or "") == handle.stablePath
  end

  return tostring(option.label or option.buttonText or "") == handle.labelIdentity
end

local function resolveLiveOption(tab, handle)
  local options = optionCollection(tab, handle.categoryPath)
  if type(options) ~= "table" then
    return nil
  end

  local indexed = options[handle.optionIndex]
  if optionMatchesHandle(indexed, handle) then
    return indexed
  end

  local occurrence = 0
  for _, item in ipairs(orderedOptions(options)) do
    if optionMatchesHandle(item.option, handle) then
      occurrence = occurrence + 1
      if occurrence == handle.duplicateIndex then
        return item.option
      end
    end
  end
  return nil
end

local function duplicateSafeId(baseId, occurrence)
  if occurrence == 1 then
    return baseId
  end

  return baseId .. ":duplicate:" .. tostring(occurrence)
end

local function markReadOnly(setting, reason, settingType)
  setting.type = settingType or "custom"
  setting.supported = false
  setting.capabilities.write = false
  setting.capabilities.draft = false
  setting.capabilities.reset = false
  setting.capabilities.canReadDefault = false
  setting.capabilities.canResetToDefault = false
  setting.unsupportedReason = reason
end

local function finalizeDefaultCapabilities(setting)
  local canRead = setting.supported ~= false
    and setting.capabilities.draft ~= false
    and setting.defaultValue ~= nil
  setting.capabilities.canReadDefault = canRead
  setting.capabilities.canResetToDefault = canRead
  setting.capabilities.reset = canRead
end

local function localizedElements(elements)
  local result = {}
  if type(elements) ~= "table" then
    return result
  end

  for key, value in pairs(elements) do
    result[key] = localize(value)
  end
  return result
end

local function normalizeOption(sourceModId, categoryPath, item, usedIds)
  local option = item.option
  local stablePath = option.fullPath
  if stablePath ~= nil and tostring(stablePath) == "" then
    stablePath = nil
  end

  local baseId = nil
  if stablePath ~= nil then
    baseId = tostring(stablePath)
  else
    baseId = table.concat({
      tostring(categoryPath),
      tostring(item.index),
      tostring(option.type or "custom"),
    }, ":")
  end

  local duplicateIndex = (usedIds[baseId] or 0) + 1
  usedIds[baseId] = duplicateIndex
  local sourceId = duplicateSafeId(baseId, duplicateIndex)

  local setting = {
    id = sourceId,
    key = tostring(option.fullPath or option.label or sourceId),
    label = localize(option.label or option.buttonText or sourceId),
    description = localize(option.desc or ""),
    rawType = tostring(option.type or "unknown"),
    capabilities = {
      read = true,
      write = true,
      draft = true,
      reset = false,
      canReadDefault = false,
      canResetToDefault = false,
    },
    supported = true,
    errors = {},
  }

  if option.type == "switch" then
    setting.type = "bool"
    setting.value = option.state == true
    if type(option.defaultValue) == "boolean" then
      setting.defaultValue = option.defaultValue
    end
  elseif option.type == "rangeInt" then
    setting.type = "int"
    setting.value = tonumber(option.currentValue) or 0
    if tonumber(option.defaultValue) ~= nil then
      setting.defaultValue = math.floor(tonumber(option.defaultValue))
    end
    setting.min = tonumber(option.min) or 0
    setting.max = tonumber(option.max) or 100
    setting.step = tonumber(option.step) or 1
    setting.format = "%d"
  elseif option.type == "rangeFloat" then
    setting.type = "float"
    setting.value = tonumber(option.currentValue) or 0
    setting.defaultValue = tonumber(option.defaultValue)
    setting.min = tonumber(option.min) or 0
    setting.max = tonumber(option.max) or 1
    setting.step = tonumber(option.step) or 0.01
    setting.format = option.format or "%.2f"
  elseif option.type == "selectorString" then
    setting.type = "select"
    setting.value = tonumber(option.selectedElementIndex) or 1
    setting.elements = localizedElements(option.elements)
    local defaultIndex = tonumber(option.defaultValue)
    if defaultIndex ~= nil and defaultIndex >= 1 and defaultIndex <= #setting.elements then
      setting.defaultValue = math.floor(defaultIndex)
    end
  elseif option.type == "keyBinding" then
    setting.type = "key"
    setting.value = currentValue(option)
    if option.defaultValue ~= nil then
      setting.defaultValue = tostring(option.defaultValue)
    end
    setting.isHold = option.isHold == true
  elseif option.type == "button" then
    setting.type = "action"
    setting.value = localize(option.buttonText or "Run")
    setting.preferredTextSize = tonumber(option.textSize)
    setting.capabilities.action = type(option.callback) == "function"
    setting.capabilities.write = false
    setting.capabilities.draft = false
    setting.capabilities.reset = false
    setting.capabilities.canReadDefault = false
    setting.capabilities.canResetToDefault = false
    setting.supported = setting.capabilities.action == true
    if not setting.supported then
      setting.unsupportedReason = "This Native Settings UI action does not expose a callback."
    end
  elseif option.type == "custom" then
    setting.type = "custom"
    setting.value = ""
    setting.customRenderScale = 0.49
    setting.capabilities.customRender = type(option.callback) == "function"
    setting.capabilities.write = false
    setting.capabilities.draft = false
    setting.capabilities.reset = false
    setting.capabilities.canReadDefault = false
    setting.capabilities.canResetToDefault = false
    setting.supported = setting.capabilities.customRender == true
    if not setting.supported then
      setting.unsupportedReason =
        "This Native Settings UI custom entry does not expose a render callback."
    end
  else
    setting.value = ""
    markReadOnly(
      setting,
      "This Native Settings UI entry type is not supported: " .. tostring(option.type)
    )
  end

  finalizeDefaultCapabilities(setting)

  settingHandles[sourceModId][sourceId] = {
    option = option,
    setting = setting,
    categoryPath = tostring(categoryPath),
    optionIndex = item.index,
    duplicateIndex = duplicateIndex,
    rawType = tostring(option.type or "unknown"),
    stablePath = stablePath ~= nil and tostring(stablePath) or nil,
    labelIdentity = tostring(option.label or option.buttonText or ""),
  }
  return setting
end

local function collectCategory(sourceModId, categoryPath, name, options, usedIds)
  local settings = {}
  for _, item in ipairs(orderedOptions(options)) do
    settings[#settings + 1] = normalizeOption(sourceModId, categoryPath, item, usedIds)
  end
  if #settings == 0 then
    return nil
  end
  return {
    id = tostring(categoryPath),
    name = localize(name or categoryPath),
    capabilities = { read = true },
    settings = settings,
  }
end

function Provider.probe()
  local framework = nativeSettings()
  if framework == nil then
    return {
      detected = false,
      ready = false,
      state = "absent",
      message = "Native Settings UI is not loaded.",
    }
  end
  if type(framework.data) ~= "table" then
    return {
      detected = true,
      ready = false,
      state = "initializing",
      message = "Native Settings UI registry is not ready.",
    }
  end
  return {
    detected = true,
    ready = true,
    state = "ready",
    revision = registryFingerprint(effectiveRegistry(framework.data)),
  }
end

function Provider.prepare(_, reason)
  local framework = nativeSettings()
  if framework == nil or type(framework.data) ~= "table" then
    return { captured = 0, reason = reason }, nil
  end

  local seeded = capturePublicationSnapshots()
  return {
    captured = seeded + captureRegistry(framework.data, true),
    reason = reason,
  },
    nil
end

function Provider.listMods()
  local framework = nativeSettings()
  local registry = nil
  if framework ~= nil then
    registry = framework.data
  end
  if type(registry) ~= "table" then
    return nil, "Native Settings UI registry is unavailable."
  end

  registry = effectiveRegistry(registry)

  local mods = {}
  for _, tabPath in
    ipairs(sortedKeys(registry, function(key, value)
      return tostring(key) ~= "noMod" and type(value) == "table"
    end))
  do
    local tab = registry[tabPath]
    mods[#mods + 1] = {
      id = tostring(tabPath),
      name = localize(tab.label or tabPath),
      revision = tabFingerprint(tabPath, tab),
      capabilities = Provider.capabilities,
    }
  end
  lastRegistryFingerprint = registryFingerprint(registry)
  return { revision = lastRegistryFingerprint, complete = true, mods = mods }, nil
end

function Provider.loadMod(sourceModId)
  local framework = nativeSettings()
  local tab = nil
  if framework ~= nil and type(framework.data) == "table" then
    tab = effectiveTab(framework.data, sourceModId)
  end
  if type(tab) ~= "table" then
    return nil, "Native Settings UI tab not found: " .. tostring(sourceModId)
  end

  settingHandles[sourceModId] = {}
  local usedIds = {}
  local categories = {}
  local general = collectCategory(sourceModId, "__main", "General", tab.options, usedIds)
  if general ~= nil then
    categories[#categories + 1] = general
  end

  for _, sub in ipairs(orderedSubcategories(tab)) do
    local category = collectCategory(
      sourceModId,
      sub.path,
      sub.value.label or sub.path,
      sub.value.options,
      usedIds
    )
    if category ~= nil then
      categories[#categories + 1] = category
    end
  end

  local fingerprint = tabFingerprint(sourceModId, tab)
  tabFingerprints[sourceModId] = fingerprint
  return {
    name = localize(tab.label or sourceModId),
    revision = fingerprint,
    categories = categories,
  },
    nil
end

local function valuesEqual(setting, left, right)
  if setting.type == "bool" then
    return (left == true) == (right == true)
  end

  if setting.type == "int" or setting.type == "select" then
    local leftNumber = tonumber(left)
    local rightNumber = tonumber(right)
    if leftNumber == nil or rightNumber == nil then
      return tostring(left) == tostring(right)
    end

    return math.floor(leftNumber) == math.floor(rightNumber)
  end

  if setting.type == "float" then
    local leftNumber = tonumber(left)
    local rightNumber = tonumber(right)
    if leftNumber == nil or rightNumber == nil then
      return tostring(left) == tostring(right)
    end

    return math.abs(leftNumber - rightNumber) < 0.000001
  end

  if left == nil or right == nil then
    return left == right
  end

  return tostring(left) == tostring(right)
end

function Provider.applyBatch(sourceModId, changes, context)
  local handles = settingHandles[sourceModId]
  if handles == nil then
    return nil, "Mod schema is not loaded."
  end

  for _, change in ipairs(changes) do
    local handle = handles[change.id]
    if handle == nil then
      return nil, "Unknown setting: " .. tostring(change.id)
    end
    if not handle.setting.supported then
      return nil, handle.setting.unsupportedReason or "Setting is read-only."
    end
  end

  local available, result, message = withAvailableTab(sourceModId, function(framework, tab)
    if type(framework.setOption) ~= "function" then
      return nil, "nativeSettings.setOption is unavailable."
    end

    local applied = {}
    local callbackErrors = {}
    for _, change in ipairs(changes) do
      local handle = handles[change.id]
      local option = resolveLiveOption(tab, handle)
      if option == nil then
        return nil,
          "Native Settings UI rebuilt this setting. Reopen the mod before applying it again: "
            .. tostring(handle.setting.label)
      end
      handle.option = option

      local previous = currentValue(option)
      local ok, err = pcall(framework.setOption, option, change.value)
      local observed = currentValue(option)
      local accepted = valuesEqual(handle.setting, observed, change.value)
      if not ok and accepted then
        local callbackError = {
          id = change.id,
          error = tostring(err),
        }
        callbackErrors[#callbackErrors + 1] = callbackError
        if
          type(context) == "table"
          and type(context.log) == "table"
          and type(context.log.warn) == "function"
        then
          context.log.warn(
            string.format(
              "Native Settings UI accepted %s for %s, but its callback raised afterward: %s",
              tostring(change.value),
              tostring(handle.setting.label),
              callbackError.error
            )
          )
        end
      end
      if not accepted then
        applied[#applied + 1] = { id = change.id, option = option, previous = previous }
        local remainingAppliedIds = {}
        local rollbackErrors = {}
        for index = #applied, 1, -1 do
          local item = applied[index]
          local rollbackOk, rollbackError = pcall(framework.setOption, item.option, item.previous)
          local restored =
            valuesEqual(handles[item.id].setting, currentValue(item.option), item.previous)
          if not restored then
            remainingAppliedIds[#remainingAppliedIds + 1] = item.id
          end
          if not rollbackOk then
            rollbackErrors[#rollbackErrors + 1] = {
              id = item.id,
              error = tostring(rollbackError),
              restored = restored,
            }
          end
        end
        local rejection = err
        if rejection == nil then
          rejection = string.format(
            "Native Settings UI did not accept %s for %s (current value: %s).",
            tostring(change.value),
            tostring(handle.setting.label),
            tostring(observed)
          )
        end
        return {
          ok = false,
          atomic = false,
          partial = #remainingAppliedIds > 0,
          appliedIds = remainingAppliedIds,
          rollbackErrors = rollbackErrors,
          error = tostring(rejection),
        },
          tostring(rejection)
      end
      applied[#applied + 1] = { id = change.id, option = option, previous = previous }
    end

    local appliedIds = {}
    for _, item in ipairs(applied) do
      appliedIds[#appliedIds + 1] = item.id
    end
    local nextFingerprint = tabFingerprint(sourceModId, tab)
    local schemaChanged = tabFingerprints[sourceModId] ~= nextFingerprint
    tabFingerprints[sourceModId] = nextFingerprint
    return {
      ok = true,
      atomic = false,
      partial = false,
      appliedIds = appliedIds,
      callbackErrors = callbackErrors,
      schemaChanged = schemaChanged,
    },
      nil
  end)
  if not available then
    return nil, result
  end
  return result, message
end

function Provider.invokeAction(sourceModId, settingId, context)
  local handles = settingHandles[sourceModId]
  if handles == nil then
    return nil, "Mod schema is not loaded."
  end

  local handle = handles[settingId]
  if handle == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end
  if handle.setting.type ~= "action" or handle.setting.capabilities.action ~= true then
    return nil, "Setting is not an executable action."
  end
  local requestedScroll = nil
  local interactionController = nil
  if type(context) == "table" and type(context.interaction) == "table" then
    requestedScroll = tonumber(context.interaction.contentScrollPosition)
    interactionController = context.interaction.controller
  end

  local available, result, message = withAvailableTab(sourceModId, function(framework, tab)
    local option = resolveLiveOption(tab, handle)
    if option == nil then
      return nil, "Native Settings UI rebuilt this action. Reopen the mod and try again."
    end
    if type(option.callback) ~= "function" then
      return nil, "Native Settings UI action callback is unavailable."
    end

    handle.option = option
    local previousController = framework.settingsMainController
    if interactionController ~= nil then
      framework.settingsMainController = interactionController
    end
    if requestedScroll ~= nil then
      setNativeScrollPosition(framework, requestedScroll)
    end

    local ok, err = pcall(option.callback)
    local resultingScroll = nativeScrollPosition(framework)
    framework.settingsMainController = previousController
    if not ok then
      return nil, tostring(err)
    end

    local activeTab = tab
    if type(framework.data) == "table" and type(framework.data[sourceModId]) == "table" then
      activeTab = framework.data[sourceModId]
    end
    local nextFingerprint = tabFingerprint(sourceModId, activeTab)
    local schemaChanged = tabFingerprints[sourceModId] ~= nextFingerprint
    tabFingerprints[sourceModId] = nextFingerprint
    local actionResult = { ok = true, schemaChanged = schemaChanged }
    if
      requestedScroll ~= nil
      and resultingScroll ~= nil
      and math.abs(resultingScroll - requestedScroll) > 0.0001
    then
      actionResult.effects = {
        contentScrollPosition = math.max(0, math.min(1, resultingScroll)),
      }
    end
    return actionResult, nil
  end)
  if not available then
    return nil, result
  end
  return result, message
end

function Provider.mountCustom(sourceModId, settingId, host)
  if host == nil then
    return nil, "Custom content host is unavailable."
  end

  local handles = settingHandles[sourceModId]
  if handles == nil then
    return nil, "Mod schema is not loaded."
  end

  local handle = handles[settingId]
  if handle == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end
  if handle.setting.type ~= "custom" or handle.setting.capabilities.customRender ~= true then
    return nil, "Setting is not renderable custom content."
  end

  local available, result, message = withAvailableTab(sourceModId, function(_, tab)
    local option = resolveLiveOption(tab, handle)
    if option == nil then
      return nil, "Native Settings UI rebuilt this custom entry. Reopen the mod and try again."
    end
    if type(option.callback) ~= "function" then
      return nil, "Native Settings UI custom render callback is unavailable."
    end

    handle.option = option
    local ok, err = pcall(option.callback, host, option)
    if not ok then
      return nil, tostring(err)
    end
    return { ok = true }, nil
  end)
  if not available then
    return nil, result
  end
  return result, message
end

function Provider.closeMod(sourceModId)
  local framework = nativeSettings()
  local registry = framework ~= nil and framework.data or nil
  local live = type(registry) == "table" and registry[sourceModId] or nil
  if type(live) == "table" and tabSnapshots[tostring(sourceModId)] == nil then
    if type(live.closedCallback) == "function" then
      local ok, err = pcall(live.closedCallback)
      if not ok then
        return false, tostring(err)
      end
    end
  elseif type(registry) == "table" and tabSnapshots[tostring(sourceModId)] ~= nil then
    local available, result, message = withAvailableTab(sourceModId, function(_, tab)
      if type(tab.closedCallback) == "function" then
        local ok, err = pcall(tab.closedCallback)
        if not ok then
          return nil, tostring(err)
        end
      end
      return true, nil
    end)
    if not available then
      return false, tostring(result)
    end
    if result ~= true then
      return false, tostring(message or "Native Settings UI close callback failed.")
    end
  end

  settingHandles[sourceModId] = nil
  tabFingerprints[sourceModId] = nil
  return true, nil
end

function Provider.poll()
  local framework = nativeSettings()
  if framework == nil or type(framework.data) ~= "table" then
    if lastRegistryFingerprint ~= nil then
      lastRegistryFingerprint = nil
      return { changed = true }, nil
    end

    return false, nil
  end

  return {
    changed = registryFingerprint(effectiveRegistry(framework.data)) ~= lastRegistryFingerprint,
  },
    nil
end

function Provider.shutdown()
  settingHandles = {}
  tabFingerprints = {}
  tabSnapshots = {}
  publicationFingerprints = {}
  lastRegistryFingerprint = nil
end

return Provider
