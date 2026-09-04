local Values = require("modules/values")

local Snapshots = {}

local function copy(value)
  if type(value) ~= "table" then
    return value
  end

  local result = {}
  for key, item in pairs(value) do
    result[key] = copy(item)
  end
  return result
end

local function canCapture(setting, useDefaults)
  if setting == nil or setting.supported ~= true or setting.type == "action" then
    return false
  end

  local capabilities = setting.capabilities or {}
  if capabilities.draft ~= true then
    return false
  end
  if useDefaults and capabilities.canReadDefault ~= true then
    return false
  end

  return true
end

function Snapshots.capture(mod, drafts, options)
  options = options or {}
  local useDefaults = options.defaults == true
  local settings = {}
  local skipped = 0

  for _, category in ipairs(mod.categories or {}) do
    for _, setting in ipairs(category.settings or {}) do
      if canCapture(setting, useDefaults) then
        local value = setting.defaultValue
        if not useDefaults then
          value = drafts.get(setting)
        end
        settings[#settings + 1] = {
          settingId = setting.id,
          settingKey = setting.key,
          categoryKey = category.key,
          categoryName = category.name,
          label = setting.label,
          valueType = setting.type,
          value = copy(value),
          elements = setting.type == "select" and copy(setting.elements) or nil,
          step = setting.step,
          format = setting.format,
          isHold = setting.isHold == true,
        }
      else
        skipped = skipped + 1
      end
    end
  end

  table.sort(settings, function(left, right)
    return tostring(left.settingId) < tostring(right.settingId)
  end)

  return {
    providerId = mod.provider,
    sourceModId = mod.sourceId,
    sourceModKey = mod.key,
    sourceModName = mod.name,
    sourceModVersion = mod.version,
    captureMode = options.captureMode or "full",
    settings = settings,
    settingCount = #settings,
    skippedCount = skipped,
  }
end

function Snapshots.preview(snapshot, catalog, drafts)
  local compareDefaults = snapshot.virtualKind == "current"
  local rows = {}
  local summary = {
    total = 0,
    matches = 0,
    changes = 0,
    missing = 0,
    readOnly = 0,
    invalid = 0,
  }

  for _, item in ipairs(snapshot.settings or {}) do
    summary.total = summary.total + 1
    local setting = catalog.findSetting(item.settingId)
    local row = {
      settingId = item.settingId,
      settingKey = item.settingKey,
      categoryKey = item.categoryKey,
      categoryName = item.categoryName,
      label = item.label,
      valueType = item.valueType,
      presetValue = copy(item.value),
      elements = copy(item.elements),
      step = item.step,
      format = item.format,
      isHold = item.isHold == true,
    }

    if setting ~= nil then
      row.label = setting.label
      row.step = setting.step
      row.format = setting.format
      row.elements = copy(setting.elements)
      row.isHold = setting.isHold == true
    end

    if setting == nil then
      row.status = "missing"
      summary.missing = summary.missing + 1
    elseif setting.supported ~= true or (setting.capabilities or {}).draft ~= true then
      row.status = "read_only"
      row.label = setting.label
      row.currentValue = drafts.get(setting)
      summary.readOnly = summary.readOnly + 1
    else
      local normalized, normalizeError = Values.normalize(setting, item.value)
      row.label = setting.label
      row.currentValue = drafts.get(setting)
      if
        compareDefaults
        and setting.defaultValue ~= nil
        and (setting.capabilities or {}).canReadDefault == true
      then
        row.currentValue = copy(setting.defaultValue)
      end
      if normalizeError ~= nil then
        row.status = "invalid"
        row.error = normalizeError
        summary.invalid = summary.invalid + 1
      else
        row.presetValue = normalized
        if Values.equal(setting, row.currentValue, normalized) then
          row.status = "matches"
          summary.matches = summary.matches + 1
        else
          row.status = "change"
          summary.changes = summary.changes + 1
        end
      end
    end

    rows[#rows + 1] = row
  end

  return {
    modKey = snapshot.sourceModKey,
    rows = rows,
    summary = summary,
    compatible = summary.missing == 0 and summary.readOnly == 0 and summary.invalid == 0,
  }
end

function Snapshots.stage(snapshot, catalog, drafts)
  local staged = {}
  local errors = {}

  for _, item in ipairs(snapshot.settings or {}) do
    local setting = catalog.findSetting(item.settingId)
    if setting == nil then
      errors[#errors + 1] = {
        settingId = item.settingId,
        status = "missing",
        error = "Setting is not available in the installed mod version.",
      }
    elseif setting.supported ~= true or (setting.capabilities or {}).draft ~= true then
      errors[#errors + 1] = {
        settingId = item.settingId,
        status = "read_only",
        error = "Setting is not writable.",
      }
    else
      local normalized, normalizeError = Values.normalize(setting, item.value)
      if normalizeError ~= nil then
        errors[#errors + 1] = {
          settingId = item.settingId,
          status = "invalid",
          error = normalizeError,
        }
      else
        staged[#staged + 1] = {
          setting = setting,
          value = normalized,
          previousValue = copy(drafts.get(setting)),
        }
      end
    end
  end

  if #errors > 0 then
    return nil, {
      ok = false,
      staged = 0,
      errors = errors,
    }
  end

  local applied = {}
  for _, item in ipairs(staged) do
    local ok, err = drafts.set(item.setting, item.value)
    if not ok then
      errors[#errors + 1] = {
        settingId = item.setting.id,
        status = "failed",
        error = err,
      }
      break
    end
    applied[#applied + 1] = item
  end

  if #errors > 0 then
    for index = #applied, 1, -1 do
      local item = applied[index]
      drafts.set(item.setting, item.previousValue)
    end
    return nil, {
      ok = false,
      staged = 0,
      errors = errors,
    }
  end

  return {
    ok = true,
    staged = #staged,
    errors = {},
  }, nil
end

return Snapshots
