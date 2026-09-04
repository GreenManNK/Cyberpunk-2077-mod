local Storage = require("modules/storage")

local DynamicSnapshots = {}
DynamicSnapshots.__index = DynamicSnapshots

local SCHEMA_VERSION = 2
local MAX_MODS = 512
local MAX_SETTINGS_PER_MOD = 4096

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

local function modeFor(snapshot)
  if snapshot.captureMode == "defaults" then
    return "defaults"
  end
  return "values"
end

local function mergeSettings(previous, current)
  local byId = {}
  for _, item in ipairs(previous or {}) do
    if type(item) == "table" and type(item.settingId) == "string" then
      byId[item.settingId] = copy(item)
      byId[item.settingId].revealSettingId = nil
      byId[item.settingId].revealValue = nil
    end
  end
  for _, item in ipairs(current or {}) do
    if type(item) == "table" and type(item.settingId) == "string" then
      byId[item.settingId] = copy(item)
      byId[item.settingId].revealSettingId = nil
      byId[item.settingId].revealValue = nil
    end
  end

  local settings = {}
  for _, item in pairs(byId) do
    settings[#settings + 1] = item
  end
  table.sort(settings, function(left, right)
    return tostring(left.settingId) < tostring(right.settingId)
  end)

  while #settings > MAX_SETTINGS_PER_MOD do
    settings[#settings] = nil
  end
  return settings
end

local function settingsById(snapshot)
  local result = {}
  for _, item in ipairs((snapshot or {}).settings or {}) do
    if type(item) == "table" and type(item.settingId) == "string" then
      result[item.settingId] = item
    end
  end
  return result
end

local function annotatedSettings(settings, dependencies)
  local result = copy(settings or {})
  local settingIds = {}
  for _, item in ipairs(result) do
    settingIds[item.settingId] = true
  end
  for _, item in ipairs(result) do
    local dependency = (dependencies or {})[item.settingId]
    if
      type(dependency) == "table"
      and type(dependency.revealSettingId) == "string"
      and settingIds[dependency.revealSettingId] == true
    then
      item.revealSettingId = dependency.revealSettingId
      item.revealValue = copy(dependency.revealValue)
    end
  end
  return result
end

function DynamicSnapshots.new(storage)
  return setmetatable({
    storage = storage,
    data = nil,
  }, DynamicSnapshots)
end

function DynamicSnapshots:path()
  return Storage.join(self.storage.root, "dynamic_snapshots.json")
end

function DynamicSnapshots:load()
  if self.data ~= nil then
    return self.data, nil
  end

  local data, readError = self.storage:readJson(self:path(), {
    schemaVersion = SCHEMA_VERSION,
    mods = {},
  })
  if data == nil then
    return nil, readError
  end
  local schemaVersion = tonumber(data.schemaVersion)
  if type(data.mods) ~= "table" or (schemaVersion ~= 1 and schemaVersion ~= SCHEMA_VERSION) then
    return nil, "Unsupported dynamic snapshot cache format."
  end
  if schemaVersion == 1 then
    data.schemaVersion = SCHEMA_VERSION
    for _, record in pairs(data.mods) do
      if type(record) == "table" then
        record.dependencies = {}
      end
    end
  end

  self.data = data
  return self.data, nil
end

function DynamicSnapshots:recordFor(data, snapshot)
  local modCount = 0
  for _ in pairs(data.mods) do
    modCount = modCount + 1
  end
  local record = data.mods[snapshot.sourceModKey]
  if record == nil and modCount >= MAX_MODS then
    return nil, "Dynamic snapshot cache reached its mod limit."
  end

  if
    type(record) ~= "table"
    or record.providerId ~= snapshot.providerId
    or (
      record.sourceModVersion ~= nil
      and snapshot.sourceModVersion ~= nil
      and record.sourceModVersion ~= snapshot.sourceModVersion
    )
  then
    record = {
      providerId = snapshot.providerId,
      sourceModId = snapshot.sourceModId,
      sourceModKey = snapshot.sourceModKey,
      sourceModName = snapshot.sourceModName,
      sourceModVersion = snapshot.sourceModVersion,
      dependencies = {},
      modes = {},
    }
    data.mods[snapshot.sourceModKey] = record
  end

  record.sourceModName = snapshot.sourceModName
  record.sourceModVersion = snapshot.sourceModVersion
  record.dependencies = type(record.dependencies) == "table" and record.dependencies or {}
  record.modes = type(record.modes) == "table" and record.modes or {}
  return record, nil
end

function DynamicSnapshots:updateRecord(record, snapshot)
  local mode = modeFor(snapshot)
  local previous = record.modes[mode]
  local mergedSettings = mergeSettings(previous and previous.settings, snapshot.settings)
  record.modes[mode] = {
    updatedAt = Storage.timestamp(),
    settings = mergedSettings,
  }
  return mergedSettings
end

function DynamicSnapshots:complete(snapshot)
  if type(snapshot) ~= "table" or type(snapshot.sourceModKey) ~= "string" then
    return snapshot, "Dynamic snapshot has no stable mod key."
  end

  local data, loadError = self:load()
  if data == nil then
    return snapshot, loadError
  end

  local record, recordError = self:recordFor(data, snapshot)
  if record == nil then
    return snapshot, recordError
  end
  local mergedSettings = self:updateRecord(record, snapshot)

  local completed = copy(snapshot)
  completed.settings = annotatedSettings(mergedSettings, record.dependencies)
  completed.settingCount = #completed.settings

  local saved, saveError = self.storage:writeJson(self:path(), data)
  if not saved then
    return completed, saveError
  end
  return completed, nil
end

function DynamicSnapshots:observedValue(sourceModKey, settingId)
  local data, loadError = self:load()
  if data == nil then
    return nil, false, loadError
  end

  local record = data.mods[tostring(sourceModKey or "")]
  local values = type(record) == "table" and type(record.modes) == "table" and record.modes.values
    or nil
  for _, item in ipairs((values or {}).settings or {}) do
    if item.settingId == settingId then
      return copy(item.value), true, nil
    end
  end
  return nil, false, nil
end

function DynamicSnapshots:annotate(snapshot)
  if type(snapshot) ~= "table" or type(snapshot.sourceModKey) ~= "string" then
    return snapshot, nil
  end

  local data, loadError = self:load()
  if data == nil then
    return snapshot, loadError
  end
  local record = data.mods[snapshot.sourceModKey]
  if type(record) ~= "table" or type(record.dependencies) ~= "table" then
    return snapshot, nil
  end

  local result = copy(snapshot)
  result.settings = annotatedSettings(snapshot.settings, record.dependencies)
  result.settingCount = #result.settings
  return result, nil
end

-- Learn only from an actual one-setting transaction that changed the published schema.
-- This avoids guessing from mod names, labels, setting types, or arbitrary probing.
function DynamicSnapshots:observeTransition(beforeSnapshot, afterSnapshot, changedSettingIds)
  if
    type(beforeSnapshot) ~= "table"
    or type(afterSnapshot) ~= "table"
    or beforeSnapshot.sourceModKey ~= afterSnapshot.sourceModKey
  then
    return false, "Dynamic schema transition snapshots do not identify the same mod."
  end

  local beforeById = settingsById(beforeSnapshot)
  local afterById = settingsById(afterSnapshot)
  local data, loadError = self:load()
  if data == nil then
    return false, loadError
  end
  local record, recordError = self:recordFor(data, afterSnapshot)
  if record == nil then
    return false, recordError
  end

  local learned = false
  local changedId = nil
  local changedCount = 0
  for settingId, changed in pairs(changedSettingIds or {}) do
    if changed == true then
      changedId = settingId
      changedCount = changedCount + 1
    end
  end
  if changedCount == 1 then
    local beforeController = beforeById[changedId]
    local afterController = afterById[changedId]
    if
      beforeController ~= nil
      and afterController ~= nil
      and beforeController.value ~= afterController.value
    then
      for settingId in pairs(beforeById) do
        if settingId ~= changedId and afterById[settingId] == nil then
          record.dependencies[settingId] = {
            revealSettingId = changedId,
            revealValue = copy(beforeController.value),
          }
          learned = true
        end
      end
      for settingId in pairs(afterById) do
        if settingId ~= changedId and beforeById[settingId] == nil then
          record.dependencies[settingId] = {
            revealSettingId = changedId,
            revealValue = copy(afterController.value),
          }
          learned = true
        end
      end
    end
  end

  self:updateRecord(record, beforeSnapshot)
  self:updateRecord(record, afterSnapshot)
  local saved, saveError = self.storage:writeJson(self:path(), data)
  if not saved then
    return false, saveError
  end
  return learned, nil
end

return DynamicSnapshots
