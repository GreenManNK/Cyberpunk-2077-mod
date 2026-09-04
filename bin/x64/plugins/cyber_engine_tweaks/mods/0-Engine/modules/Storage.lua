-- Storage.lua - namespaced JSON key-value storage with atomic writes

local Logger = require('modules/Logger')

local Storage = { version = '0.2.0' }

local dataFile = "data/storage.json"
local backupFile = "data/storage.json.bak"
local tempFile = "data/storage.json.tmp"
local cache = {}
local isDirty = false

---Initializes the Storage module
function Storage.Init()
    local file = io.open(dataFile, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and content ~= "" then
            local success, data = pcall(json.decode, content)
            if success and type(data) == "table" then
                cache = data
                return
            end
        end
    end

    -- Primary file invalid, attempt backup restore
    local backup = io.open(backupFile, "r")
    if backup then
        local content = backup:read("*a")
        backup:close()
        if content and content ~= "" then
            local success, data = pcall(json.decode, content)
            if success and type(data) == "table" then
                cache = data
                Logger.Log("0-Engine", "Storage: Restored from backup", "info")
                return
            end
        end
    end

    Logger.Log("0-Engine", "Storage: Starting fresh (no valid data found)", "info")
end

---Saves the current cache to disk using atomic write pattern
function Storage.Save()
    if not isDirty then return end

    local encoded = json.encode(cache)
    if not encoded then
        Logger.Log("0-Engine", "Storage: Failed to encode data", "error")
        return
    end

    -- Write to temp file first
    local tmpFile = io.open(tempFile, "w")
    if not tmpFile then
        Logger.Log("0-Engine", "Storage: Failed to open temp file: " .. tempFile, "error")
        return
    end
    tmpFile:write(encoded)
    tmpFile:close()

    -- Backup current file before overwriting
    local current = io.open(dataFile, "r")
    if current then
        local currentContent = current:read("*a")
        current:close()
        if currentContent and currentContent ~= "" then
            local bak = io.open(backupFile, "w")
            if bak then
                bak:write(currentContent)
                bak:close()
            end
        end
    end

    -- Write to primary (os.rename unavailable in CET)
    local primary = io.open(dataFile, "w")
    if primary then
        primary:write(encoded)
        primary:close()
        isDirty = false
    else
        Logger.Log("0-Engine", "Storage: Failed to write primary file: " .. dataFile, "error")
    end

    -- Clean up temp file
    os.remove(tempFile)
end

---Sets a value for a specific mod and key
---@param modName string
---@param key string
---@param value any (must be JSON serializable)
function Storage.Set(modName, key, value)
    if not cache[modName] then
        cache[modName] = {}
    end
    cache[modName][key] = value
    isDirty = true
end

---Gets a value for a specific mod and key
---@param modName string
---@param key string
---@param defaultValue any
---@return any
function Storage.Get(modName, key, defaultValue)
    if cache[modName] and cache[modName][key] ~= nil then
        return cache[modName][key]
    end
    return defaultValue
end

---Clears all data for a specific mod
---@param modName string
function Storage.Clear(modName)
    if cache[modName] then
        cache[modName] = nil
        isDirty = true
    end
end

return Storage