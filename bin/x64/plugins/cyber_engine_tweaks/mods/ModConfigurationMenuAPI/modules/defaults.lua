local Drafts = require("modules/drafts")
local Values = require("modules/values")

local Defaults = {}

local function categoriesFor(mod)
  if type(mod) ~= "table" or type(mod.categories) ~= "table" then
    return {}
  end
  return mod.categories
end

local function capabilitiesFor(setting)
  if type(setting) ~= "table" or type(setting.capabilities) ~= "table" then
    return {}
  end
  return setting.capabilities
end

function Defaults.has(setting)
  local capabilities = capabilitiesFor(setting)
  return setting ~= nil and setting.defaultValue ~= nil and capabilities.canReadDefault == true
end

function Defaults.canReset(setting)
  local capabilities = capabilitiesFor(setting)
  return Defaults.has(setting)
    and setting.supported ~= false
    and setting.disabled ~= true
    and capabilities.draft ~= false
    and capabilities.canResetToDefault == true
end

function Defaults.isDefault(drafts, setting, value)
  if not Defaults.has(setting) then
    return nil, "No reliable default value is available for this setting."
  end

  local effective = value
  if effective == nil then
    effective = Drafts.get(drafts, setting)
  end
  return Values.equal(setting, effective, setting.defaultValue), nil
end

function Defaults.diff(drafts, mod)
  local result = {}
  for _, category in ipairs(categoriesFor(mod)) do
    for _, setting in ipairs(category.settings or {}) do
      if Defaults.has(setting) then
        local effective = Drafts.get(drafts, setting)
        if not Values.equal(setting, effective, setting.defaultValue) then
          result[#result + 1] = {
            settingId = setting.id,
            categoryId = category.id,
            value = effective,
            persistedValue = setting.value,
            defaultValue = setting.defaultValue,
            dirty = not Values.equal(setting, effective, setting.value),
            resettable = Defaults.canReset(setting),
          }
        end
      end
    end
  end
  return result
end

function Defaults.coverage(drafts, mod)
  local result = {
    total = 0,
    resettable = 0,
    nonDefault = 0,
    resettableNonDefault = 0,
    unsupported = 0,
    temporarilyUnavailable = 0,
  }

  for _, category in ipairs(categoriesFor(mod)) do
    for _, setting in ipairs(category.settings or {}) do
      result.total = result.total + 1
      local capabilities = capabilitiesFor(setting)
      if capabilities.defaultTemporarilyUnavailable == true then
        result.temporarilyUnavailable = result.temporarilyUnavailable + 1
      elseif not Defaults.has(setting) then
        result.unsupported = result.unsupported + 1
      end

      if Defaults.canReset(setting) then
        result.resettable = result.resettable + 1
      end

      local nonDefault = Defaults.has(setting)
        and not Values.equal(setting, Drafts.get(drafts, setting), setting.defaultValue)
      if nonDefault then
        result.nonDefault = result.nonDefault + 1
        if Defaults.canReset(setting) then
          result.resettableNonDefault = result.resettableNonDefault + 1
        end
      end
    end
  end

  return result
end

function Defaults.stageMod(drafts, mod)
  if type(mod) ~= "table" then
    return nil, "Unknown mod."
  end
  if drafts.dirtyModKey ~= nil and drafts.dirtyModKey ~= mod.key then
    return nil, "Another mod has pending changes. Apply or revert it first."
  end

  local result = {
    staged = 0,
    alreadyDefault = 0,
    skipped = 0,
    failed = 0,
    errors = {},
  }

  for _, category in ipairs(categoriesFor(mod)) do
    for _, setting in ipairs(category.settings or {}) do
      if not Defaults.canReset(setting) then
        result.skipped = result.skipped + 1
      elseif Values.equal(setting, Drafts.get(drafts, setting), setting.defaultValue) then
        result.alreadyDefault = result.alreadyDefault + 1
      else
        local ok, err = Drafts.set(drafts, setting, setting.defaultValue)
        if ok then
          result.staged = result.staged + 1
        else
          result.failed = result.failed + 1
          result.errors[#result.errors + 1] = {
            settingId = setting.id,
            error = tostring(err),
          }
        end
      end
    end
  end

  return result, nil
end

return Defaults
