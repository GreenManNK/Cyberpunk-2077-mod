-- vm_config_backup.lua
-- Rotating backups for the generated car and bike specification files.

local M = {
  BACKUP_DIR = "backup",
  MAX_BACKUPS_PER_CONFIG = 10,
}

local TRACKED_FILES = {
  ["vm_config_cars.json"] = "vm_config_cars",
  ["vm_config_bikes.json"] = "vm_config_bikes",
}

local function baseName(path)
  local normalized = tostring(path or ""):gsub("\\", "/")
  return normalized:match("([^/]+)$") or normalized
end

local function trackedStem(path)
  return TRACKED_FILES[baseName(path)]
end

local function readRaw(path)
  local f, openErr = io.open(path, "rb")
  if not f then return nil, openErr end

  local data, readErr = f:read("*a")
  local closed, closeErr = f:close()

  if data == nil then return nil, readErr end
  if not closed then return nil, closeErr end
  return data
end

local function writeRaw(path, data)
  local f, openErr = io.open(path, "wb")
  if not f then return false, openErr end

  local wrote, writeErr = f:write(data or "")
  local closed, closeErr = f:close()

  if not wrote then return false, writeErr end
  if not closed then return false, closeErr end
  return true
end

local function pathExists(path)
  local f = io.open(path, "rb")
  if f then
    f:close()
    return true
  end

  if type(dir) == "function" then
    local wanted = baseName(path)
    local scanned = false

    for _, scanPath in ipairs({ ".", "./" }) do
      local ok, entries = pcall(dir, scanPath)
      if ok and type(entries) == "table" then
        scanned = true

        for _, entry in ipairs(entries) do
          local name = type(entry) == "table"
            and tostring(entry.name or "") or tostring(entry or "")
          if name == wanted then return true end
        end
      end
    end

    if scanned then return false end
  end

  if os and type(os.rename) == "function" then
    local ok, renameErr, renameCode = os.rename(path, path)
    if ok then return true end
    if renameCode == 2 then return false end
    return nil, renameErr
  end

  return nil, "could not determine whether the path exists"
end

local function testBackupDir()
  local probePath = M.BACKUP_DIR .. "/.__vm_config_backup_probe.tmp"
  local f = io.open(probePath, "wb")
  if not f then return false end

  local wrote = f:write("ok")
  local closed = f:close()

  if os and type(os.remove) == "function" then
    pcall(os.remove, probePath)
  end

  return wrote ~= nil and closed ~= nil
end

local function ensureBackupDir()
  if testBackupDir() then return true end

  if os and type(os.execute) == "function" then
    pcall(os.execute, 'mkdir "' .. M.BACKUP_DIR .. '" >nul 2>nul')
  end

  return testBackupDir()
end

local function isGeneratedBackup(stem, name)
  local prefix = "^" .. stem .. "_"
  local timestamp = "%d%d%d%d%d%d%d%d_%d%d%d%d%d%d"

  if name:match(prefix .. timestamp .. "%.json$") then
    return true
  end

  return name:match(prefix .. timestamp .. "_%d+%.json$") ~= nil
end

local function backupOrderParts(stem, name)
  local prefix = "^" .. stem .. "_"
  local timestamp = "%d%d%d%d%d%d%d%d_%d%d%d%d%d%d"
  local stamp = name:match(prefix .. "(" .. timestamp .. ")%.json$")
  if stamp then return stamp, 1 end

  local suffix
  stamp, suffix = name:match(
    prefix .. "(" .. timestamp .. ")_(%d+)%.json$"
  )
  return stamp or "", tonumber(suffix) or 1
end

local function listBackups(stem)
  if type(dir) ~= "function" then
    return nil, "CET dir() is unavailable"
  end

  local found = {}
  local seen = {}
  local scanned = false

  for _, scanPath in ipairs({ M.BACKUP_DIR, "./" .. M.BACKUP_DIR }) do
    local ok, entries = pcall(dir, scanPath)
    if ok and type(entries) == "table" then
      scanned = true

      for _, entry in ipairs(entries) do
        local name = type(entry) == "table"
          and tostring(entry.name or "") or tostring(entry or "")
        if not seen[name] and isGeneratedBackup(stem, name) then
          seen[name] = true
          found[#found + 1] = name
        end
      end
    end
  end

  if not scanned then
    return nil, "backup directory could not be listed"
  end

  table.sort(found, function(a, b)
    local stampA, suffixA = backupOrderParts(stem, a)
    local stampB, suffixB = backupOrderParts(stem, b)

    if stampA ~= stampB then return stampA < stampB end
    return suffixA < suffixB
  end)
  return found
end

local function nextBackupPath(stem, backups)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local base = stem .. "_" .. timestamp
  local seen = {}
  local maxSuffix = 0

  for _, existing in ipairs(backups or {}) do
    seen[existing] = true
    local existingStamp, existingSuffix = backupOrderParts(stem, existing)
    if existingStamp == timestamp and existingSuffix > maxSuffix then
      maxSuffix = existingSuffix
    end
  end

  local suffix = maxSuffix + 1
  local name = suffix == 1 and (base .. ".json")
    or (base .. "_" .. string.format("%09d", suffix) .. ".json")

  while seen[name] do
    suffix = suffix + 1
    name = base .. "_" .. string.format("%09d", suffix) .. ".json"
  end

  return M.BACKUP_DIR .. "/" .. name
end

local function makeRoomForBackup(stem)
  local backups, listErr = listBackups(stem)
  if not backups then return false, listErr end
  if not os or type(os.remove) ~= "function" then
    return false, "os.remove() is unavailable"
  end

  while #backups >= M.MAX_BACKUPS_PER_CONFIG do
    local path = M.BACKUP_DIR .. "/" .. backups[1]
    local callOK, removed, removeErr = pcall(os.remove, path)

    if not callOK or not removed then
      return false, removeErr or ("could not remove " .. path)
    end

    table.remove(backups, 1)
  end

  return true, backups
end

local function createBackup(stem, raw)
  if not ensureBackupDir() then
    return false, "could not create or write to the backup directory"
  end

  local roomOK, backupsOrErr = makeRoomForBackup(stem)
  if not roomOK then return false, backupsOrErr end

  local backupPath = nextBackupPath(stem, backupsOrErr)
  local ok, writeErr = writeRaw(backupPath, raw)
  if not ok then return false, writeErr end

  print("[VehicleMileage] Config backup created: " .. backupPath)
  return true, backupPath
end

function M.write(path, data)
  data = tostring(data or "")

  local stem = trackedStem(path)
  if not stem then
    return writeRaw(path, data)
  end

  local previous, readErr = readRaw(path)
  if previous == nil then
    local exists, existsErr = pathExists(path)
    if exists == nil then
      print(("[VehicleMileage] ERROR: cannot inspect %s before writing: %s")
        :format(tostring(path), tostring(existsErr or readErr)))
      return false
    end

    if exists then
      print(("[VehicleMileage] ERROR: refusing to overwrite unreadable config %s: %s")
        :format(tostring(path), tostring(readErr)))
      return false
    end
  end

  if previous == data then return true end

  if previous ~= nil then
    local backupOK, backupResult = createBackup(stem, previous)
    if not backupOK then
      print(("[VehicleMileage] ERROR: backup failed for %s: %s")
        :format(tostring(path), tostring(backupResult)))
      return false
    end
  end

  local writeOK, writeErr = writeRaw(path, data)
  if not writeOK then
    print(("[VehicleMileage] ERROR: config write failed for %s: %s")
      :format(tostring(path), tostring(writeErr)))
    return false
  end

  return true
end

return M
