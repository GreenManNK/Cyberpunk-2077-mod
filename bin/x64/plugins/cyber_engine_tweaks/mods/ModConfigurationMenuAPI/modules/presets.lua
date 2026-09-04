local Storage = require("modules/storage")

local Presets = {}
Presets.__index = Presets

local SCHEMA_VERSION = 1

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

local function metadata(preset)
  return {
    schemaVersion = preset.schemaVersion,
    id = preset.id,
    revision = preset.revision,
    name = preset.name,
    description = preset.description,
    providerId = preset.providerId,
    sourceModId = preset.sourceModId,
    sourceModKey = preset.sourceModKey,
    sourceModName = preset.sourceModName,
    sourceModVersion = preset.sourceModVersion,
    captureMode = preset.captureMode,
    createdAt = preset.createdAt,
    updatedAt = preset.updatedAt,
    settingCount = #(preset.settings or {}),
  }
end

function Presets.new(storage)
  return setmetatable({
    storage = storage,
    index = nil,
  }, Presets)
end

function Presets:indexPath()
  return Storage.join(self.storage.root, "presets_index.json")
end

function Presets:presetPath(preset)
  return Storage.join(self.storage.root, "preset_" .. Storage.fileToken(preset.id) .. ".json")
end

function Presets:loadIndex()
  if self.index ~= nil then
    return self.index, nil
  end

  local index, err = self.storage:readJson(self:indexPath(), {
    schemaVersion = SCHEMA_VERSION,
    items = {},
  })
  if index == nil then
    return nil, err
  end
  if tonumber(index.schemaVersion) ~= SCHEMA_VERSION or type(index.items) ~= "table" then
    return nil, "Unsupported preset index format."
  end

  self.index = index
  return self.index, nil
end

function Presets:saveIndex()
  table.sort(self.index.items, function(left, right)
    local leftKey = tostring(left.sourceModKey)
      .. "\0"
      .. tostring(left.name)
      .. "\0"
      .. tostring(left.id)
    local rightKey = tostring(right.sourceModKey)
      .. "\0"
      .. tostring(right.name)
      .. "\0"
      .. tostring(right.id)
    return leftKey:lower() < rightKey:lower()
  end)
  return self.storage:writeJson(self:indexPath(), self.index)
end

function Presets:list(modKey)
  local index, err = self:loadIndex()
  if index == nil then
    return nil, err
  end

  local result = {}
  for _, item in ipairs(index.items) do
    if modKey == nil or item.sourceModKey == modKey then
      result[#result + 1] = copy(item)
    end
  end
  return result, nil
end

function Presets:findMetadata(presetId)
  local index, err = self:loadIndex()
  if index == nil then
    return nil, err
  end

  for itemIndex, item in ipairs(index.items) do
    if item.id == presetId then
      return item, itemIndex, nil
    end
  end
  return nil, nil, "Unknown preset: " .. tostring(presetId)
end

function Presets:get(presetId)
  local item, _, findError = self:findMetadata(presetId)
  if item == nil then
    return nil, findError
  end

  local preset, err = self.storage:readJson(self:presetPath(item))
  if preset == nil then
    return nil, err
  end
  if tonumber(preset.schemaVersion) ~= SCHEMA_VERSION or type(preset.settings) ~= "table" then
    return nil, "Unsupported preset format: " .. tostring(presetId)
  end

  return preset, nil
end

function Presets:create(snapshot, options)
  options = options or {}
  local name, nameError = Storage.normalizeName(options.name)
  if name == nil then
    return nil, nameError
  end

  local index, indexError = self:loadIndex()
  if index == nil then
    return nil, indexError
  end

  local createdAt = Storage.timestamp()
  local preset = copy(snapshot)
  preset.schemaVersion = SCHEMA_VERSION
  preset.id = Storage.newId("preset")
  preset.revision = 1
  preset.virtual = nil
  preset.virtualKind = nil
  preset.name = name
  preset.description = tostring(options.description or "")
  preset.createdAt = createdAt
  preset.updatedAt = createdAt

  local written, writeError = self.storage:writeJson(self:presetPath(preset), preset)
  if not written then
    return nil, writeError
  end

  local previousItems = copy(index.items)
  index.items[#index.items + 1] = metadata(preset)
  local indexed, indexSaveError = self:saveIndex()
  if not indexed then
    index.items = previousItems
    self.storage:remove(self:presetPath(preset))
    return nil, indexSaveError
  end

  return copy(preset), nil
end

function Presets:update(presetId, snapshot, options)
  options = options or {}
  local existing, itemIndex, findError = self:findMetadata(presetId)
  if existing == nil then
    return nil, findError
  end

  local current, readError = self:get(presetId)
  if current == nil then
    return nil, readError
  end
  local name = current.name
  if options.name ~= nil then
    local normalizedName, nameError = Storage.normalizeName(options.name)
    if normalizedName == nil then
      return nil, nameError
    end
    name = normalizedName
  end

  local updated = copy(snapshot or current)
  updated.schemaVersion = SCHEMA_VERSION
  updated.id = current.id
  updated.revision = (tonumber(current.revision) or 1) + 1
  updated.virtual = nil
  updated.virtualKind = nil
  updated.providerId = current.providerId
  updated.sourceModId = current.sourceModId
  updated.sourceModKey = current.sourceModKey
  updated.name = name
  updated.description = options.description ~= nil and tostring(options.description)
    or tostring(current.description or "")
  updated.createdAt = current.createdAt
  updated.updatedAt = Storage.timestamp()

  local written, writeError = self.storage:writeJson(self:presetPath(existing), updated)
  if not written then
    return nil, writeError
  end

  local previousItems = copy(self.index.items)
  self.index.items[itemIndex] = metadata(updated)
  local indexed, indexSaveError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    self.storage:writeJson(self:presetPath(existing), current)
    return nil, indexSaveError
  end
  return copy(updated), nil
end

function Presets:delete(presetId)
  local item, itemIndex, findError = self:findMetadata(presetId)
  if item == nil then
    return false, findError
  end

  local previousItems = copy(self.index.items)
  table.remove(self.index.items, itemIndex)
  local indexed, indexError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    return false, indexError
  end

  local removed, removeError = self.storage:remove(self:presetPath(item))
  if not removed then
    self.index.items = previousItems
    self:saveIndex()
    return false, removeError
  end
  return true, nil
end

return Presets
