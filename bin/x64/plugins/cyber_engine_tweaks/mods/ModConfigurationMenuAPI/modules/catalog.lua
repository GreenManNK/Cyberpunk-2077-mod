local Values = require("modules/values")

local Catalog = {}

local function text(value, fallback)
  local result = ""
  if value ~= nil and value ~= false then
    result = tostring(value)
  end

  if result == "" then
    if fallback == nil or fallback == false then
      return ""
    end

    return tostring(fallback)
  end

  return result
end

local function copyArray(source)
  local target = {}
  if type(source) ~= "table" then
    return target
  end

  for index, value in ipairs(source) do
    target[index] = value
  end
  return target
end

local function copyMap(source)
  local target = {}
  if type(source) ~= "table" then
    return target
  end

  for key, value in pairs(source) do
    target[key] = value
  end
  return target
end

local function copyCapabilities(source)
  return copyMap(source)
end

local function providerModKey(providerId, sourceId)
  return tostring(providerId) .. ":" .. tostring(sourceId)
end

local function categoriesFor(mod)
  if type(mod) ~= "table" or type(mod.categories) ~= "table" then
    return {}
  end

  return mod.categories
end

local function removeModSettings(catalog, mod)
  for _, category in ipairs(categoriesFor(mod)) do
    for _, setting in ipairs(category.settings or {}) do
      catalog.settingById[setting.id] = nil
    end
  end
end

local function recount(catalog)
  catalog.counts.mods = #catalog.mods
  catalog.counts.categories = 0
  catalog.counts.settings = 0
  catalog.settingById = {}

  for _, mod in ipairs(catalog.mods) do
    catalog.counts.categories = catalog.counts.categories + #(mod.categories or {})
    for _, category in ipairs(mod.categories or {}) do
      catalog.counts.settings = catalog.counts.settings + #(category.settings or {})
      for _, setting in ipairs(category.settings or {}) do
        catalog.settingById[setting.id] = setting
      end
    end
  end
end

local function rebuildMerged(catalog)
  catalog.mods = {}
  local seen = {}

  for _, providerId in ipairs(catalog.providerOrder) do
    for _, modKey in ipairs(catalog.providerModKeys[providerId] or {}) do
      local mod = catalog.modByKey[modKey]
      if mod ~= nil and not seen[modKey] then
        seen[modKey] = true
        catalog.mods[#catalog.mods + 1] = mod
      end
    end
  end

  for modKey, mod in pairs(catalog.modByKey) do
    if not seen[modKey] then
      catalog.mods[#catalog.mods + 1] = mod
    end
  end

  recount(catalog)
end

local function duplicateSafeId(baseId, occurrence)
  if occurrence == 1 then
    return baseId
  end

  return baseId .. ":duplicate:" .. tostring(occurrence)
end

local function normalizeDefaultCapabilities(setting)
  local capabilities = setting.capabilities
  local hasDefaultValue = setting.defaultValue ~= nil
  local canReadDefault = capabilities.canReadDefault

  if canReadDefault == nil then
    canReadDefault = hasDefaultValue and capabilities.reset ~= false
  end
  if setting.supported == false or setting.disabled == true then
    canReadDefault = false
  end

  if canReadDefault == true and hasDefaultValue then
    local normalized, err = Values.normalize(setting, setting.defaultValue)
    if err == nil then
      setting.defaultValue = normalized
    else
      canReadDefault = false
      setting.defaultValue = nil
      setting.errors[#setting.errors + 1] = "Invalid framework default: " .. tostring(err)
    end
  else
    canReadDefault = false
    setting.defaultValue = nil
  end

  local canReset = capabilities.canResetToDefault
  if canReset == nil then
    canReset = capabilities.reset ~= false
  end
  canReset = canReadDefault
    and canReset == true
    and setting.supported ~= false
    and setting.disabled ~= true
    and capabilities.write ~= false
    and capabilities.draft ~= false

  capabilities.canReadDefault = canReadDefault == true
  capabilities.canResetToDefault = canReset == true
  capabilities.reset = capabilities.canResetToDefault
end

local function validateDenseArray(values, label)
  local numericCount = 0
  local highestIndex = 0
  for key in pairs(values) do
    if type(key) == "number" and key >= 1 and math.floor(key) == key then
      numericCount = numericCount + 1
      highestIndex = math.max(highestIndex, key)
    end
  end

  if highestIndex ~= numericCount then
    return false, label .. " must be a dense array without nil gaps."
  end

  return true, nil
end

local function publicSetting(setting)
  return {
    bridge = setting.provider,
    provider = setting.provider,
    providerName = setting.providerName,
    providerShortName = setting.providerShortName,
    modKey = setting.modKey,
    categoryKey = setting.categoryKey,
    id = setting.id,
    key = setting.key,
    label = setting.label,
    description = setting.description,
    type = setting.type,
    value = setting.value,
    defaultValue = setting.defaultValue,
    min = setting.min,
    max = setting.max,
    step = setting.step,
    format = setting.format,
    elements = copyArray(setting.elements),
    rawType = setting.rawType,
    frameworkKind = setting.frameworkKind,
    preferredTextSize = setting.preferredTextSize,
    customRenderScale = setting.customRenderScale,
    isHold = setting.isHold == true,
    capabilities = copyCapabilities(setting.capabilities),
    supported = setting.supported,
    disabled = setting.disabled,
    unsupportedReason = setting.unsupportedReason,
    errors = copyArray(setting.errors),
  }
end

local function publicCategory(category)
  local settings = {}
  for _, setting in ipairs(category.settings or {}) do
    settings[#settings + 1] = publicSetting(setting)
  end

  return {
    bridge = category.provider,
    provider = category.provider,
    providerName = category.providerName,
    providerShortName = category.providerShortName,
    modKey = category.modKey,
    id = category.id,
    key = category.key,
    name = category.name,
    description = category.description,
    capabilities = copyCapabilities(category.capabilities),
    settings = settings,
    errors = copyArray(category.errors),
  }
end

local function publicMod(mod)
  return {
    bridge = mod.provider,
    provider = mod.provider,
    providerName = mod.providerName,
    providerShortName = mod.providerShortName,
    id = mod.sourceId,
    key = mod.key,
    name = mod.name,
    description = mod.description,
    capabilities = copyCapabilities(mod.capabilities),
    lazy = not mod.loaded,
    loaded = mod.loaded,
    stale = mod.stale,
    schemaStale = mod.schemaStale,
    revision = mod.revision,
    schemaRevision = mod.schemaRevision,
    loadAttempted = mod.loadAttempted,
    loadError = mod.loadError,
    loadDuration = mod.loadDuration,
    errors = copyArray(mod.errors),
  }
end

function Catalog.new()
  return {
    providerOrder = {},
    providerModKeys = {},
    providerSnapshots = {},
    mods = {},
    modByKey = {},
    settingById = {},
    counts = {
      providers = 0,
      availableProviders = 0,
      mods = 0,
      categories = 0,
      settings = 0,
    },
  }
end

function Catalog.setProviderOrder(catalog, providerIds)
  catalog.providerOrder = copyArray(providerIds)
  catalog.counts.providers = #catalog.providerOrder
  rebuildMerged(catalog)
end

function Catalog.replaceProviderIndex(catalog, provider, snapshot)
  if type(snapshot) ~= "table" or type(snapshot.mods) ~= "table" then
    return false, "Provider index snapshot must contain a mods array."
  end

  local denseMods, denseModsError = validateDenseArray(snapshot.mods, "Provider index mods")
  if not denseMods then
    return false, denseModsError
  end

  local providerId = provider.id
  local oldKeys = catalog.providerModKeys[providerId] or {}
  local nextKeys = {}
  local seenSourceIds = {}
  local incomingMods = {}

  for index, incoming in ipairs(snapshot.mods) do
    if type(incoming) ~= "table" then
      return false, "Provider index mod " .. tostring(index) .. " must be a table."
    end

    local sourceId = text(incoming.id, "mod_" .. tostring(index))
    if seenSourceIds[sourceId] then
      return false, "Provider index contains duplicate mod ID: " .. sourceId
    end

    seenSourceIds[sourceId] = true
    incomingMods[#incomingMods + 1] = {
      sourceId = sourceId,
      value = incoming,
    }
  end

  for _, item in ipairs(incomingMods) do
    local sourceId = item.sourceId
    local incoming = item.value
    local modKey = providerModKey(providerId, sourceId)
    local mod = catalog.modByKey[modKey]
    if mod == nil then
      mod = {
        provider = providerId,
        providerName = text(provider.name, providerId),
        providerShortName = text(provider.shortName, providerId),
        sourceId = sourceId,
        key = modKey,
        name = text(incoming.name, sourceId),
        description = text(incoming.description, ""),
        capabilities = copyCapabilities(incoming.capabilities or provider.capabilities),
        categories = {},
        categoryByKey = {},
        loaded = false,
        stale = false,
        schemaStale = false,
        revision = incoming.revision,
        schemaRevision = nil,
        loadAttempted = false,
        loadError = nil,
        loadDuration = 0,
        errors = copyArray(incoming.errors),
      }
      catalog.modByKey[modKey] = mod
    else
      local previousSchemaRevision = mod.schemaRevision or mod.revision
      local nextRevision = incoming.revision
      if
        mod.loaded
        and previousSchemaRevision ~= nil
        and nextRevision ~= nil
        and tostring(previousSchemaRevision) ~= tostring(nextRevision)
      then
        mod.schemaStale = true
      end

      mod.providerName = text(provider.name, providerId)
      mod.providerShortName = text(provider.shortName, providerId)
      mod.name = text(incoming.name, mod.name)
      mod.description = text(incoming.description, mod.description)
      mod.capabilities = copyCapabilities(incoming.capabilities or mod.capabilities)
      if nextRevision ~= nil then
        mod.revision = nextRevision
      end
      mod.stale = false
      mod.errors = copyArray(incoming.errors)
    end

    nextKeys[#nextKeys + 1] = modKey
  end

  if snapshot.complete ~= false then
    for _, modKey in ipairs(oldKeys) do
      local oldMod = catalog.modByKey[modKey]
      if oldMod ~= nil and not seenSourceIds[oldMod.sourceId] then
        removeModSettings(catalog, oldMod)
        catalog.modByKey[modKey] = nil
      end
    end
  else
    for _, modKey in ipairs(oldKeys) do
      if
        catalog.modByKey[modKey] ~= nil and not seenSourceIds[catalog.modByKey[modKey].sourceId]
      then
        nextKeys[#nextKeys + 1] = modKey
      end
    end
  end

  catalog.providerModKeys[providerId] = nextKeys
  catalog.providerSnapshots[providerId] = {
    revision = snapshot.revision,
    epoch = snapshot.epoch,
    complete = snapshot.complete ~= false,
    modCount = #nextKeys,
  }
  rebuildMerged(catalog)
  return true, nil
end

function Catalog.markProviderStale(catalog, providerId, stale)
  for _, modKey in ipairs(catalog.providerModKeys[providerId] or {}) do
    local mod = catalog.modByKey[modKey]
    if mod ~= nil then
      mod.stale = stale ~= false
    end
  end
end

function Catalog.removeProvider(catalog, providerId)
  for _, modKey in ipairs(catalog.providerModKeys[providerId] or {}) do
    local mod = catalog.modByKey[modKey]
    if mod ~= nil then
      removeModSettings(catalog, mod)
      catalog.modByKey[modKey] = nil
    end
  end
  catalog.providerModKeys[providerId] = nil
  catalog.providerSnapshots[providerId] = nil
  rebuildMerged(catalog)
end

function Catalog.attachSchema(catalog, mod, schema)
  if mod == nil then
    return false, "Cannot attach a schema without a mod."
  end
  if type(schema) ~= "table" then
    return false, "Provider schema must be a table."
  end

  local categories = schema.categories or schema
  if type(categories) ~= "table" then
    return false, "Provider schema does not contain categories."
  end

  local denseCategories, denseCategoriesError =
    validateDenseArray(categories, "Provider schema categories")
  if not denseCategories then
    return false, denseCategoriesError
  end

  local nextCategories = {}
  local nextCategoryByKey = {}
  local nextSettingsById = {}
  local seenCategories = {}
  local seenSettings = {}
  for categoryIndex, incomingCategory in ipairs(categories) do
    if type(incomingCategory) ~= "table" then
      return false, "Provider schema category " .. tostring(categoryIndex) .. " must be a table."
    end
    local incomingSettings = incomingCategory.settings or {}
    if type(incomingSettings) ~= "table" then
      return false,
        "Provider schema category " .. tostring(categoryIndex) .. " has no settings array."
    end

    local denseSettings, denseSettingsError = validateDenseArray(
      incomingSettings,
      "Provider schema category " .. tostring(categoryIndex) .. " settings"
    )
    if not denseSettings then
      return false, denseSettingsError
    end

    local baseCategoryId = text(incomingCategory.id, "category_" .. tostring(categoryIndex))
    local categoryCount = (seenCategories[baseCategoryId] or 0) + 1
    seenCategories[baseCategoryId] = categoryCount
    local sourceCategoryId = duplicateSafeId(baseCategoryId, categoryCount)
    local categoryKey = mod.key .. ":" .. sourceCategoryId
    local category = {
      provider = mod.provider,
      providerName = mod.providerName,
      providerShortName = mod.providerShortName,
      modKey = mod.key,
      sourceId = sourceCategoryId,
      id = sourceCategoryId,
      key = categoryKey,
      name = text(incomingCategory.name, sourceCategoryId),
      description = text(incomingCategory.description, ""),
      capabilities = copyCapabilities(incomingCategory.capabilities),
      settings = {},
      errors = copyArray(incomingCategory.errors),
    }

    for settingIndex, incomingSetting in ipairs(incomingSettings) do
      if type(incomingSetting) ~= "table" then
        return false, "Provider schema setting " .. tostring(settingIndex) .. " must be a table."
      end
      if incomingSetting.elements ~= nil then
        if type(incomingSetting.elements) ~= "table" then
          return false,
            "Provider schema setting "
              .. tostring(settingIndex)
              .. " has an invalid elements array."
        end

        local denseElements, denseElementsError = validateDenseArray(
          incomingSetting.elements,
          "Provider schema setting " .. tostring(settingIndex) .. " elements"
        )
        if not denseElements then
          return false, denseElementsError
        end
      end

      local baseSettingId =
        text(incomingSetting.id, sourceCategoryId .. ":setting_" .. tostring(settingIndex))
      local settingCount = (seenSettings[baseSettingId] or 0) + 1
      seenSettings[baseSettingId] = settingCount
      local sourceSettingId = duplicateSafeId(baseSettingId, settingCount)
      local settingId = mod.key .. ":" .. sourceSettingId
      local disabled = incomingSetting.disabled == true
      local setting = {
        provider = mod.provider,
        providerName = mod.providerName,
        providerShortName = mod.providerShortName,
        modKey = mod.key,
        categoryKey = categoryKey,
        sourceId = sourceSettingId,
        id = settingId,
        key = text(incomingSetting.key, sourceSettingId),
        label = text(incomingSetting.label, sourceSettingId),
        description = text(incomingSetting.description, ""),
        type = text(incomingSetting.type, "custom"),
        value = incomingSetting.value,
        defaultValue = incomingSetting.defaultValue,
        min = incomingSetting.min,
        max = incomingSetting.max,
        step = incomingSetting.step,
        format = incomingSetting.format,
        elements = copyArray(incomingSetting.elements),
        rawType = incomingSetting.rawType,
        frameworkKind = incomingSetting.frameworkKind,
        preferredTextSize = incomingSetting.preferredTextSize,
        customRenderScale = incomingSetting.customRenderScale,
        isHold = incomingSetting.isHold == true,
        capabilities = copyCapabilities(incomingSetting.capabilities),
        supported = incomingSetting.supported ~= false and not disabled,
        disabled = disabled,
        unsupportedReason = incomingSetting.unsupportedReason,
        errors = copyArray(incomingSetting.errors),
      }
      normalizeDefaultCapabilities(setting)
      category.settings[#category.settings + 1] = setting
      nextSettingsById[setting.id] = setting
    end

    nextCategories[#nextCategories + 1] = category
    nextCategoryByKey[category.key] = category
    nextCategoryByKey[category.id] = category
  end

  removeModSettings(catalog, mod)
  mod.categories = nextCategories
  mod.categoryByKey = nextCategoryByKey
  for settingId, setting in pairs(nextSettingsById) do
    catalog.settingById[settingId] = setting
  end

  if schema.name ~= nil and tostring(schema.name) ~= "" then
    mod.name = tostring(schema.name)
  end
  if schema.description ~= nil then
    mod.description = tostring(schema.description)
  end

  mod.loaded = true
  mod.schemaStale = false
  mod.schemaRevision = schema.revision or mod.schemaRevision
  mod.loadAttempted = true
  mod.loadError = nil
  recount(catalog)
  return true, nil
end

function Catalog.unloadSchema(catalog, mod)
  if mod == nil then
    return
  end
  removeModSettings(catalog, mod)
  mod.categories = {}
  mod.categoryByKey = {}
  mod.loaded = false
  mod.schemaStale = false
  recount(catalog)
end

function Catalog.findMod(catalog, modKey)
  if type(modKey) == "table" then
    modKey = modKey.key
  end
  return catalog.modByKey[tostring(modKey or "")]
end

function Catalog.findSetting(catalog, settingId)
  if type(settingId) == "table" then
    settingId = settingId.id
  end
  return catalog.settingById[tostring(settingId or "")]
end

function Catalog.listMods(catalog)
  local result = {}
  for _, mod in ipairs(catalog.mods) do
    result[#result + 1] = publicMod(mod)
  end
  return result
end

function Catalog.listCategories(catalog, mod)
  local result = {}
  for _, category in ipairs(categoriesFor(mod)) do
    result[#result + 1] = publicCategory(category)
  end
  return result
end

function Catalog.listSettings(catalog, mod, categoryKey)
  local result = {}
  for _, category in ipairs(categoriesFor(mod)) do
    if categoryKey == nil or category.key == categoryKey or category.id == categoryKey then
      for _, setting in ipairs(category.settings or {}) do
        result[#result + 1] = publicSetting(setting)
      end
    end
  end
  return result
end

function Catalog.publicMod(mod)
  if mod == nil then
    return nil
  end

  return publicMod(mod)
end

function Catalog.publicSetting(setting)
  if setting == nil then
    return nil
  end

  return publicSetting(setting)
end

function Catalog.updateValues(catalog, mod, valuesBySettingId)
  for settingId, value in pairs(valuesBySettingId or {}) do
    local setting = catalog.settingById[settingId]
    if setting ~= nil and setting.modKey == mod.key then
      setting.value = value
    end
  end
end

function Catalog.snapshot(catalog)
  return {
    mods = Catalog.listMods(catalog),
    counts = copyMap(catalog.counts),
  }
end

return Catalog
