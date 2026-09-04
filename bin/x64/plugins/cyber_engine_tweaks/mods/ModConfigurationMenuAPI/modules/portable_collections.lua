local Storage = require("modules/storage")

local PortableCollections = {}
PortableCollections.__index = PortableCollections

local FORMAT_ID = "mcm.collection"
local FORMAT_VERSION = 1
local EXTENSION = ".mcmcollection"
local MAX_FILE_BYTES = 16 * 1024 * 1024
local MAX_ENTRIES = 1000
local MAX_SETTINGS = 10000
local MAX_STRING_BYTES = 4096
local MAX_ELEMENTS = 512

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

local function text(value)
  if type(value) ~= "string" or value == "" then
    return nil
  end
  if #value > MAX_STRING_BYTES then
    return nil
  end
  return value
end

local function scalar(value)
  local valueType = type(value)
  if value == nil or valueType == "boolean" then
    return true
  end
  if valueType == "number" then
    return value == value and value ~= math.huge and value ~= -math.huge
  end
  return valueType == "string" and #value <= MAX_STRING_BYTES
end

local function denseArray(value)
  if type(value) ~= "table" then
    return false
  end

  local count = 0
  for key in pairs(value) do
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
      return false
    end
    count = count + 1
  end
  return count == #value
end

local function validateSetting(setting, entryIndex, settingIndex)
  local prefix =
    string.format("Entry %d setting %d", tonumber(entryIndex) or 0, tonumber(settingIndex) or 0)
  if type(setting) ~= "table" then
    return nil, prefix .. " must be an object."
  end
  if text(setting.settingId) == nil then
    return nil, prefix .. " has no valid settingId."
  end
  if text(setting.valueType) == nil then
    return nil, prefix .. " has no valid valueType."
  end
  if not scalar(setting.value) then
    return nil, prefix .. " contains an unsupported value."
  end
  if setting.revealSettingId ~= nil then
    if text(setting.revealSettingId) == nil or setting.revealSettingId == setting.settingId then
      return nil, prefix .. " has invalid dynamic controller metadata."
    end
    if setting.revealValue == nil or not scalar(setting.revealValue) then
      return nil, prefix .. " has invalid dynamic reveal metadata."
    end
  elseif setting.revealValue ~= nil then
    return nil, prefix .. " has a dynamic reveal value without a controller."
  end
  for _, field in ipairs({ "label", "categoryName", "format" }) do
    if setting[field] ~= nil and text(setting[field]) == nil then
      return nil, prefix .. " has invalid " .. field .. " metadata."
    end
  end
  if setting.step ~= nil and not scalar(setting.step) then
    return nil, prefix .. " has invalid step metadata."
  end
  if setting.isHold ~= nil and type(setting.isHold) ~= "boolean" then
    return nil, prefix .. " has invalid isHold metadata."
  end
  if setting.elements ~= nil then
    if not denseArray(setting.elements) or #setting.elements > MAX_ELEMENTS then
      return nil, prefix .. " has invalid selector metadata."
    end
    for _, element in ipairs(setting.elements) do
      if not scalar(element) then
        return nil, prefix .. " has an unsupported selector label."
      end
    end
  end
  return true, nil
end

local function validateEntry(entry, entryIndex)
  local prefix = "Entry " .. tostring(entryIndex)
  if type(entry) ~= "table" then
    return nil, prefix .. " must be an object."
  end
  if text(entry.providerId) == nil then
    return nil, prefix .. " has no valid providerId."
  end
  if text(entry.sourceModId) == nil then
    return nil, prefix .. " has no valid sourceModId."
  end
  if text(entry.sourceModKey) == nil then
    return nil, prefix .. " has no valid sourceModKey."
  end
  if not denseArray(entry.settings) then
    return nil, prefix .. " settings must be an array."
  end

  local seenSettingIds = {}
  for settingIndex, setting in ipairs(entry.settings) do
    local valid, validationError = validateSetting(setting, entryIndex, settingIndex)
    if not valid then
      return nil, validationError
    end
    if seenSettingIds[setting.settingId] then
      return nil, prefix .. " contains duplicate setting: " .. setting.settingId
    end
    seenSettingIds[setting.settingId] = true
  end
  for _, setting in ipairs(entry.settings) do
    if setting.revealSettingId ~= nil and seenSettingIds[setting.revealSettingId] ~= true then
      return nil, prefix .. " references a missing dynamic controller: " .. setting.revealSettingId
    end
  end
  return true, nil
end

local function inventoryEntry(entry)
  return {
    providerId = entry.providerId,
    sourceModId = entry.sourceModId,
    sourceModKey = entry.sourceModKey,
    sourceModName = entry.sourceModName,
    sourceModVersion = entry.sourceModVersion,
    settingCount = #(entry.settings or {}),
  }
end

local function portableEntry(entry)
  local settings = {}
  for _, setting in ipairs(entry.settings or {}) do
    settings[#settings + 1] = {
      settingId = setting.settingId,
      settingKey = setting.settingKey,
      categoryKey = setting.categoryKey,
      categoryName = setting.categoryName,
      label = setting.label,
      valueType = setting.valueType,
      value = copy(setting.value),
      elements = copy(setting.elements),
      step = setting.step,
      format = setting.format,
      isHold = setting.isHold == true,
      revealSettingId = setting.revealSettingId,
      revealValue = copy(setting.revealValue),
    }
  end
  return {
    providerId = entry.providerId,
    sourceModId = entry.sourceModId,
    sourceModKey = entry.sourceModKey,
    sourceModName = entry.sourceModName,
    sourceModVersion = entry.sourceModVersion,
    bindingMode = "snapshot",
    captureMode = entry.captureMode,
    capturedAt = entry.capturedAt,
    settingCount = #settings,
    skippedCount = entry.skippedCount,
    settings = settings,
  }
end

local function safeFileStem(value)
  local stem = tostring(value or "Collection")
  stem = stem:gsub('[%z\1-\31<>:"/\\|%?%*]', "_")
  stem = stem:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  stem = stem:gsub("[%. ]+$", "")
  if stem == "" then
    stem = "Collection"
  end
  if #stem > 80 then
    stem = stem:sub(1, 80):gsub("[%. ]+$", "")
  end
  return stem
end

local function defaultDirectory(path)
  if type(dir) ~= "function" then
    return nil, "CET directory listing is unavailable."
  end
  local ok, result = pcall(dir, path)
  if not ok or type(result) ~= "table" then
    return nil, tostring(result or "Could not list the portable collection directory.")
  end
  return result, nil
end

local function fileSize(path)
  local file = io.open(path, "rb")
  if file == nil then
    return nil
  end
  local size = file:seek("end")
  file:close()
  return tonumber(size)
end

local function portableFileName(value)
  local fileName = tostring(value or "")
  if
    fileName == ""
    or fileName:find("[/\\]", 1) ~= nil
    or fileName:sub(-#EXTENSION):lower() ~= EXTENSION
  then
    return nil, "Invalid portable collection filename."
  end
  return fileName, nil
end

function PortableCollections.new(storage, options)
  options = options or {}
  return setmetatable({
    storage = storage,
    root = options.root or Storage.join(storage.root, "portable"),
    listDirectory = options.listDirectory or defaultDirectory,
    mcmVersion = tostring(options.mcmVersion or "unknown"),
  }, PortableCollections)
end

function PortableCollections:directory()
  return self.root
end

function PortableCollections:displayDirectory()
  return "<CET>/mods/ModConfigurationMenuAPI/data/portable"
end

function PortableCollections:path(fileName)
  return Storage.join(self.root, fileName)
end

function PortableCollections:validate(package)
  if type(package) ~= "table" then
    return nil, "Portable collection root must be an object."
  end
  if package.format ~= FORMAT_ID then
    return nil, "This is not an MCM portable collection."
  end
  if tonumber(package.formatVersion) ~= FORMAT_VERSION then
    return nil,
      "Unsupported portable collection format version: " .. tostring(
        package.formatVersion or "missing"
      ) .. "."
  end
  if type(package.collection) ~= "table" then
    return nil, "Portable collection metadata is missing."
  end
  if text(package.collection.name) == nil then
    return nil, "Portable collection has no valid name."
  end
  if not denseArray(package.entries) then
    return nil, "Portable collection entries must be an array."
  end
  if #package.entries > MAX_ENTRIES then
    return nil, "Portable collection exceeds the 1000-mod safety limit."
  end

  local settingCount = 0
  local seenModKeys = {}
  for entryIndex, entry in ipairs(package.entries) do
    local valid, validationError = validateEntry(entry, entryIndex)
    if not valid then
      return nil, validationError
    end
    if seenModKeys[entry.sourceModKey] then
      return nil, "Portable collection contains duplicate mod: " .. entry.sourceModKey
    end
    seenModKeys[entry.sourceModKey] = true
    settingCount = settingCount + #entry.settings
    if settingCount > MAX_SETTINGS then
      return nil, "Portable collection exceeds the 10000-setting safety limit."
    end
  end

  return {
    entryCount = #package.entries,
    settingCount = settingCount,
  }, nil
end

function PortableCollections:read(fileName)
  local normalized, nameError = portableFileName(fileName)
  if normalized == nil then
    return nil, nameError
  end
  fileName = normalized

  local path = self:path(fileName)
  local size = fileSize(path)
  if size ~= nil and size > MAX_FILE_BYTES then
    return nil, "Portable collection exceeds the 16 MB safety limit."
  end

  local package, readError = self.storage:readJson(path)
  if package == nil then
    return nil, readError or "Portable collection could not be read."
  end
  local summary, validationError = self:validate(package)
  if summary == nil then
    return nil, validationError
  end
  return package, nil, summary
end

function PortableCollections:delete(fileName)
  local normalized, nameError = portableFileName(fileName)
  if normalized == nil then
    return false, nameError
  end
  return self.storage:remove(self:path(normalized))
end

function PortableCollections:list()
  local items, listError = self.listDirectory(self.root)
  if items == nil then
    return nil, listError
  end

  local result = {}
  for _, item in ipairs(items) do
    local fileName = tostring(type(item) == "table" and item.name or item)
    local itemType = type(item) == "table" and item.type or "file"
    if itemType ~= "directory" and fileName:sub(-#EXTENSION):lower() == EXTENSION then
      local package, readError, summary = self:read(fileName)
      local row = {
        fileName = fileName,
        path = self:path(fileName),
        valid = package ~= nil,
        error = readError,
      }
      if package ~= nil then
        row.name = package.collection.name
        row.description = package.collection.description
        row.exportedAt = package.exportedAt
        row.mcmVersion = package.mcmVersion
        row.entryCount = summary.entryCount
        row.settingCount = summary.settingCount
      end
      result[#result + 1] = row
    end
  end

  table.sort(result, function(left, right)
    local leftName = tostring(left.name or left.fileName):lower()
    local rightName = tostring(right.name or right.fileName):lower()
    if leftName == rightName then
      return tostring(left.fileName):lower() < tostring(right.fileName):lower()
    end
    return leftName < rightName
  end)
  return result, nil
end

function PortableCollections:export(collection, entries)
  if type(collection) ~= "table" then
    return nil, "Collection is missing."
  end

  local exportedEntries = {}
  local inventory = {}
  for _, entry in ipairs(entries or {}) do
    local exported = portableEntry(entry)
    exportedEntries[#exportedEntries + 1] = exported
    inventory[#inventory + 1] = inventoryEntry(exported)
  end

  local package = {
    format = FORMAT_ID,
    formatVersion = FORMAT_VERSION,
    mcmVersion = self.mcmVersion,
    exportedAt = Storage.timestamp(),
    collection = {
      name = collection.name,
      description = collection.description or "",
      createdAt = collection.createdAt,
      updatedAt = collection.updatedAt,
      sourceRevision = collection.revision,
    },
    inventory = inventory,
    entries = exportedEntries,
  }
  local valid, validationError = self:validate(package)
  if valid == nil then
    return nil, validationError
  end

  local timestamp = os.date("%Y-%m-%d_%H%M%S")
  local baseName = safeFileStem(collection.name) .. " - " .. timestamp
  local fileName = baseName .. EXTENSION
  local suffix = 2
  while fileSize(self:path(fileName)) ~= nil do
    fileName = string.format("%s (%d)%s", baseName, suffix, EXTENSION)
    suffix = suffix + 1
  end

  local written, writeError = self.storage:writeJson(self:path(fileName), package)
  if not written then
    return nil, writeError
  end
  return {
    fileName = fileName,
    path = self:path(fileName),
    directory = self:displayDirectory(),
    collectionName = collection.name,
    entryCount = #exportedEntries,
  },
    nil
end

function PortableCollections:import(fileName, collections)
  local package, readError = self:read(fileName)
  if package == nil then
    return nil, readError
  end

  local existing, listError = collections:list()
  if existing == nil then
    return nil, listError
  end
  local usedNames = {}
  for _, item in ipairs(existing) do
    usedNames[tostring(item.name):lower()] = true
  end

  local baseName = package.collection.name
  local importedName = baseName
  if usedNames[importedName:lower()] then
    importedName = baseName .. " (Imported)"
    local suffix = 2
    while usedNames[importedName:lower()] do
      importedName = string.format("%s (Imported %d)", baseName, suffix)
      suffix = suffix + 1
    end
  end

  local collection, createError = collections:create({
    name = importedName,
    description = package.collection.description or "",
  })
  if collection == nil then
    return nil, createError
  end

  for _, sourceEntry in ipairs(package.entries) do
    local entry = portableEntry(sourceEntry)
    entry.id = Storage.component(entry.sourceModKey)
    local stored, storeError = collections:putEntry(collection.id, entry)
    if stored == nil then
      local deleted, deleteError = collections:delete(collection.id)
      if not deleted then
        storeError = tostring(storeError)
          .. " Import rollback also failed: "
          .. tostring(deleteError)
      end
      return nil, storeError
    end
  end

  local imported, loadError = collections:get(collection.id, true)
  if imported == nil then
    collections:delete(collection.id)
    return nil, loadError
  end
  return imported, nil
end

return PortableCollections
