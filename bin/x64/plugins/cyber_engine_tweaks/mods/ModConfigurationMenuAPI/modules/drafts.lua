local Values = require("modules/values")

local Drafts = {}

function Drafts.new()
  return {
    bySettingId = {},
    dirtyModKey = nil,
  }
end

function Drafts.get(drafts, setting)
  local draft = drafts.bySettingId[setting.id]
  if draft ~= nil then
    return draft.value
  end
  return setting.value
end

function Drafts.set(drafts, setting, value)
  if setting == nil then
    return false, "Unknown setting."
  end
  if setting.supported == false or setting.disabled == true then
    return false, setting.unsupportedReason or "Setting is read-only."
  end
  if setting.capabilities ~= nil and setting.capabilities.draft == false then
    return false, setting.unsupportedReason or "Setting does not support drafts."
  end

  local normalized, err = Values.normalize(setting, value)
  if err ~= nil then
    return false, err
  end

  if Values.equal(setting, setting.value, normalized) then
    drafts.bySettingId[setting.id] = nil
    if not Drafts.hasForMod(drafts, setting.modKey) then
      drafts.dirtyModKey = nil
    end
    return true, nil
  end

  if drafts.dirtyModKey ~= nil and drafts.dirtyModKey ~= setting.modKey then
    return false, "Another mod has pending changes. Apply or revert it first."
  end

  drafts.bySettingId[setting.id] = {
    settingId = setting.id,
    modKey = setting.modKey,
    value = normalized,
  }
  drafts.dirtyModKey = setting.modKey
  return true, nil
end

function Drafts.reset(drafts, setting)
  if setting == nil then
    return false, "Unknown setting."
  end
  local capabilities = setting.capabilities or {}
  local canReset = capabilities.canResetToDefault
  if canReset == nil then
    canReset = capabilities.reset ~= false
  end
  if setting.defaultValue == nil or canReset ~= true then
    return false, "No default value is available for this setting."
  end
  return Drafts.set(drafts, setting, setting.defaultValue)
end

function Drafts.clearSetting(drafts, setting)
  if setting == nil then
    return false, "Unknown setting."
  end
  drafts.bySettingId[setting.id] = nil
  if not Drafts.hasForMod(drafts, setting.modKey) and drafts.dirtyModKey == setting.modKey then
    drafts.dirtyModKey = nil
  end
  return true, nil
end

function Drafts.hasForMod(drafts, modKey)
  modKey = tostring(modKey or "")
  for _, draft in pairs(drafts.bySettingId) do
    if draft.modKey == modKey then
      return true
    end
  end
  return false
end

function Drafts.countForMod(drafts, modKey)
  local count = 0
  modKey = tostring(modKey or "")
  for _, draft in pairs(drafts.bySettingId) do
    if draft.modKey == modKey then
      count = count + 1
    end
  end
  return count
end

function Drafts.changesForMod(drafts, mod)
  local changes = {}
  local valuesBySettingId = {}
  local categories = {}
  if type(mod) == "table" and type(mod.categories) == "table" then
    categories = mod.categories
  end

  for _, category in ipairs(categories) do
    for _, setting in ipairs(category.settings or {}) do
      local draft = drafts.bySettingId[setting.id]
      if draft ~= nil then
        changes[#changes + 1] = {
          id = setting.sourceId,
          value = draft.value,
          previousValue = setting.value,
          type = setting.type,
          frameworkKind = setting.frameworkKind,
        }
        valuesBySettingId[setting.id] = draft.value
      end
    end
  end

  return changes, valuesBySettingId
end

function Drafts.clearMod(drafts, modKey)
  modKey = tostring(modKey or "")
  for settingId, draft in pairs(drafts.bySettingId) do
    if draft.modKey == modKey then
      drafts.bySettingId[settingId] = nil
    end
  end
  if drafts.dirtyModKey == modKey then
    drafts.dirtyModKey = nil
  end
end

function Drafts.reconcileMod(drafts, mod, settingById)
  local removed = 0
  for settingId, draft in pairs(drafts.bySettingId) do
    if draft.modKey == mod.key then
      local setting = settingById[settingId]
      if setting == nil or Values.equal(setting, setting.value, draft.value) then
        drafts.bySettingId[settingId] = nil
        removed = removed + 1
      end
    end
  end
  if not Drafts.hasForMod(drafts, mod.key) and drafts.dirtyModKey == mod.key then
    drafts.dirtyModKey = nil
  end
  return removed
end

return Drafts
