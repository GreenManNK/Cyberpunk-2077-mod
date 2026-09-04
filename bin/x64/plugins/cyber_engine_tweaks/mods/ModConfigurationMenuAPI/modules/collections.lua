local Storage = require("modules/storage")

local Collections = {}
Collections.__index = Collections

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

local function collectionMetadata(collection)
  return {
    schemaVersion = collection.schemaVersion,
    id = collection.id,
    revision = collection.revision,
    name = collection.name,
    description = collection.description,
    createdAt = collection.createdAt,
    updatedAt = collection.updatedAt,
    entryCount = #(collection.entryIds or {}),
  }
end

function Collections.new(storage)
  return setmetatable({
    storage = storage,
    index = nil,
  }, Collections)
end

function Collections:indexPath()
  return Storage.join(self.storage.root, "collections_index.json")
end

function Collections:collectionPath(collectionId)
  return Storage.join(
    self.storage.root,
    "collection_" .. Storage.fileToken(collectionId) .. ".json"
  )
end

function Collections:entryPath(collectionId, entryId)
  return Storage.join(
    self.storage.root,
    "collection_entry_"
      .. Storage.fileToken(collectionId)
      .. "_"
      .. Storage.fileToken(entryId)
      .. ".json"
  )
end

function Collections:loadIndex()
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
    return nil, "Unsupported collection index format."
  end

  self.index = index
  return self.index, nil
end

function Collections:saveIndex()
  table.sort(self.index.items, function(left, right)
    local leftKey = tostring(left.name) .. "\0" .. tostring(left.id)
    local rightKey = tostring(right.name) .. "\0" .. tostring(right.id)
    return leftKey:lower() < rightKey:lower()
  end)
  return self.storage:writeJson(self:indexPath(), self.index)
end

function Collections:list()
  local index, err = self:loadIndex()
  if index == nil then
    return nil, err
  end
  return copy(index.items), nil
end

function Collections:findMetadata(collectionId)
  local index, err = self:loadIndex()
  if index == nil then
    return nil, err
  end

  for itemIndex, item in ipairs(index.items) do
    if item.id == collectionId then
      return item, itemIndex, nil
    end
  end
  return nil, nil, "Unknown collection: " .. tostring(collectionId)
end

function Collections:get(collectionId, includeEntries)
  local item, _, findError = self:findMetadata(collectionId)
  if item == nil then
    return nil, findError
  end

  local collection, err = self.storage:readJson(self:collectionPath(collectionId))
  if collection == nil then
    return nil, err
  end
  if
    tonumber(collection.schemaVersion) ~= SCHEMA_VERSION or type(collection.entryIds) ~= "table"
  then
    return nil, "Unsupported collection format: " .. tostring(collectionId)
  end

  if includeEntries == true then
    collection.entries = {}
    for _, entryId in ipairs(collection.entryIds) do
      local entry, entryError = self.storage:readJson(self:entryPath(collectionId, entryId))
      if entry == nil then
        collection.entries[#collection.entries + 1] = {
          id = entryId,
          status = "invalid",
          error = entryError,
        }
      else
        collection.entries[#collection.entries + 1] = entry
      end
    end
  end

  return collection, nil
end

function Collections:create(options)
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
  local collection = {
    schemaVersion = SCHEMA_VERSION,
    id = Storage.newId("collection"),
    revision = 1,
    name = name,
    description = tostring(options.description or ""),
    createdAt = createdAt,
    updatedAt = createdAt,
    entryIds = {},
  }

  local written, writeError = self.storage:writeJson(self:collectionPath(collection.id), collection)
  if not written then
    return nil, writeError
  end

  local previousItems = copy(index.items)
  index.items[#index.items + 1] = collectionMetadata(collection)
  local indexed, indexSaveError = self:saveIndex()
  if not indexed then
    index.items = previousItems
    self.storage:remove(self:collectionPath(collection.id))
    return nil, indexSaveError
  end
  return copy(collection), nil
end

function Collections:update(collectionId, options)
  options = options or {}
  local existing, itemIndex, findError = self:findMetadata(collectionId)
  if existing == nil then
    return nil, findError
  end

  local collection, readError = self:get(collectionId, false)
  if collection == nil then
    return nil, readError
  end
  local previousCollection = copy(collection)

  if options.name ~= nil then
    local name, nameError = Storage.normalizeName(options.name)
    if name == nil then
      return nil, nameError
    end
    collection.name = name
  end
  if options.description ~= nil then
    collection.description = tostring(options.description)
  end
  collection.revision = (tonumber(collection.revision) or 1) + 1
  collection.updatedAt = Storage.timestamp()

  local written, writeError = self.storage:writeJson(self:collectionPath(collectionId), collection)
  if not written then
    return nil, writeError
  end
  local previousItems = copy(self.index.items)
  self.index.items[itemIndex] = collectionMetadata(collection)
  local indexed, indexSaveError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    self.storage:writeJson(self:collectionPath(collectionId), previousCollection)
    return nil, indexSaveError
  end
  return copy(collection), nil
end

function Collections:putEntry(collectionId, entry)
  local collection, readError = self:get(collectionId, false)
  if collection == nil then
    return nil, readError
  end

  local stored = copy(entry)
  stored.schemaVersion = SCHEMA_VERSION
  stored.id = stored.id or Storage.component(stored.sourceModKey)
  stored.capturedAt = stored.capturedAt or Storage.timestamp()
  stored.bindingMode = stored.bindingMode == "linked" and "linked" or "snapshot"

  local existing = false
  for _, entryId in ipairs(collection.entryIds) do
    if entryId == stored.id then
      existing = true
      break
    end
  end
  local previousEntry = nil
  if existing then
    local previousEntryError = nil
    previousEntry, previousEntryError =
      self.storage:readJson(self:entryPath(collectionId, stored.id))
    if previousEntry == nil then
      return nil, previousEntryError
    end
  end
  local previousCollection = copy(collection)

  local written, writeError =
    self.storage:writeJson(self:entryPath(collectionId, stored.id), stored)
  if not written then
    return nil, writeError
  end

  if not existing then
    collection.entryIds[#collection.entryIds + 1] = stored.id
    table.sort(collection.entryIds)
  end
  collection.revision = (tonumber(collection.revision) or 1) + 1
  collection.updatedAt = Storage.timestamp()

  local saved, saveError = self.storage:writeJson(self:collectionPath(collectionId), collection)
  if not saved then
    if previousEntry ~= nil then
      self.storage:writeJson(self:entryPath(collectionId, stored.id), previousEntry)
    else
      self.storage:remove(self:entryPath(collectionId, stored.id))
    end
    return nil, saveError
  end

  local _, itemIndex = self:findMetadata(collectionId)
  local previousItems = copy(self.index.items)
  self.index.items[itemIndex] = collectionMetadata(collection)
  local indexed, indexError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    self.storage:writeJson(self:collectionPath(collectionId), previousCollection)
    if previousEntry ~= nil then
      self.storage:writeJson(self:entryPath(collectionId, stored.id), previousEntry)
    else
      self.storage:remove(self:entryPath(collectionId, stored.id))
    end
    return nil, indexError
  end
  return stored, nil
end

function Collections:removeEntry(collectionId, entryId)
  local collection, readError = self:get(collectionId, false)
  if collection == nil then
    return false, readError
  end

  local foundIndex = nil
  for index, existingId in ipairs(collection.entryIds) do
    if existingId == entryId then
      foundIndex = index
      break
    end
  end
  if foundIndex == nil then
    return false, "Unknown collection entry: " .. tostring(entryId)
  end

  local previousCollection = copy(collection)
  table.remove(collection.entryIds, foundIndex)
  collection.revision = (tonumber(collection.revision) or 1) + 1
  collection.updatedAt = Storage.timestamp()
  local saved, saveError = self.storage:writeJson(self:collectionPath(collectionId), collection)
  if not saved then
    return false, saveError
  end

  local _, itemIndex = self:findMetadata(collectionId)
  local previousItems = copy(self.index.items)
  self.index.items[itemIndex] = collectionMetadata(collection)
  local indexed, indexError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    self.storage:writeJson(self:collectionPath(collectionId), previousCollection)
    return false, indexError
  end

  local removed, removeError = self.storage:remove(self:entryPath(collectionId, entryId))
  if not removed then
    self.index.items = previousItems
    self.storage:writeJson(self:collectionPath(collectionId), previousCollection)
    self:saveIndex()
    return false, removeError
  end
  return true, nil
end

function Collections:linkedPresetReferences(presetId)
  local index, indexError = self:loadIndex()
  if index == nil then
    return nil, indexError
  end

  local references = {}
  for _, item in ipairs(index.items) do
    local collection, collectionError = self:get(item.id, true)
    if collection == nil then
      return nil, collectionError
    end

    for _, entry in ipairs(collection.entries or {}) do
      if entry.bindingMode == "linked" and entry.sourcePresetId == presetId then
        references[#references + 1] = {
          collectionId = collection.id,
          collectionName = collection.name,
          entryId = entry.id,
          sourceModKey = entry.sourceModKey,
          sourceModName = entry.sourceModName,
        }
      end
    end
  end

  return references, nil
end

function Collections:detachPresetReferences(presetId)
  local references, referenceError = self:linkedPresetReferences(presetId)
  if references == nil then
    return nil, referenceError
  end

  local pending = {}
  for _, reference in ipairs(references) do
    local entry, entryError =
      self.storage:readJson(self:entryPath(reference.collectionId, reference.entryId))
    if entry == nil then
      return nil, entryError
    end

    local updated = copy(entry)
    updated.bindingMode = "snapshot"
    updated.detachedFromPresetId = updated.sourcePresetId
    updated.detachedFromPresetRevision = updated.sourcePresetRevision
    updated.detachedFromPresetName = updated.sourcePresetName
    updated.sourcePresetId = nil
    updated.sourcePresetRevision = nil
    updated.sourcePresetName = nil
    pending[#pending + 1] = {
      reference = reference,
      original = entry,
      updated = updated,
    }
  end

  local detached = {}
  for _, item in ipairs(pending) do
    local stored, storeError = self:putEntry(item.reference.collectionId, item.updated)
    if stored == nil then
      local rollbackErrors = {}
      for index = #detached, 1, -1 do
        local applied = detached[index]
        local restored, restoreError =
          self:putEntry(applied.reference.collectionId, applied.original)
        if restored == nil then
          rollbackErrors[#rollbackErrors + 1] = tostring(restoreError)
        end
      end
      if #rollbackErrors > 0 then
        storeError = tostring(storeError)
          .. " Detach rollback also failed: "
          .. table.concat(rollbackErrors, "; ")
      end
      return nil, storeError
    end
    detached[#detached + 1] = item
  end

  local result = {}
  for _, item in ipairs(detached) do
    result[#result + 1] = item.reference
  end

  return result, nil
end

function Collections:delete(collectionId)
  local item, itemIndex, findError = self:findMetadata(collectionId)
  if item == nil then
    return false, findError
  end

  local collection, readError = self:get(collectionId, false)
  if collection == nil and readError ~= nil then
    return false, readError
  end

  local previousItems = copy(self.index.items)
  table.remove(self.index.items, itemIndex)
  local indexed, indexError = self:saveIndex()
  if not indexed then
    self.index.items = previousItems
    return false, indexError
  end

  local removed, removeError = self.storage:remove(self:collectionPath(collectionId))
  if not removed then
    self.index.items = previousItems
    self:saveIndex()
    return false, removeError
  end

  for _, entryId in ipairs((collection and collection.entryIds) or {}) do
    self.storage:remove(self:entryPath(collectionId, entryId))
  end
  return true, nil
end

return Collections
