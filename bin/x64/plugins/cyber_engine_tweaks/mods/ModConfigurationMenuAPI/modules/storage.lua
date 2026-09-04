local Storage = {}
Storage.__index = Storage

local idCounter = 0

local function sourceDirectory()
  local source = ""
  if type(debug) == "table" and type(debug.getinfo) == "function" then
    local info = debug.getinfo(1, "S")
    source = info and tostring(info.source or "") or ""
  end
  source = source:gsub("^@", "")

  local modulesDirectory = source:match("^(.*)[/\\]modules[/\\]storage%.lua$")
  if modulesDirectory ~= nil and modulesDirectory ~= "" then
    return modulesDirectory
  end
  return "."
end

local DEFAULT_ROOT = sourceDirectory() .. "/data"

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function utf8Length(value)
  local length = 0
  for index = 1, #value do
    local byte = string.byte(value, index)
    if byte < 0x80 or byte >= 0xC0 then
      length = length + 1
    end
  end
  return length
end

local function parentPath(path)
  return tostring(path or ""):match("^(.*)[/\\][^/\\]+$")
end

local function pathExists(path)
  local file = io.open(path, "rb")
  if file == nil then
    return false
  end

  file:close()
  return true
end

local function readDecodedFile(storage, path)
  local file = io.open(path, "rb")
  if file == nil then
    return nil, nil, false
  end

  local raw = file:read("*a")
  file:close()

  local ok, decoded = pcall(function()
    return storage.json.decode(raw or "")
  end)
  if not ok or type(decoded) ~= "table" then
    return nil, "Could not decode " .. tostring(path) .. ": " .. tostring(decoded), true
  end

  return decoded, nil, true
end

local function defaultEnsureDirectory(path)
  local normalized = tostring(path or ""):gsub("/", "\\")
  if normalized == "" then
    return false, "Directory path is empty."
  end

  local probePath = normalized .. "\\.mcm-storage-probe"
  local probe = io.open(probePath, "wb")
  if probe ~= nil then
    probe:write("")
    probe:close()
    os.remove(probePath)
    return true, nil
  end

  return false,
    "Storage directory is missing or not writable: "
      .. normalized
      .. ". Reinstall MCM API so its data directory is present."
end

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

function Storage.new(options)
  options = options or {}

  return setmetatable({
    root = options.root or DEFAULT_ROOT,
    json = options.json or json,
    ensureDirectory = options.ensureDirectory or defaultEnsureDirectory,
  }, Storage)
end

function Storage.defaultRoot()
  return DEFAULT_ROOT
end

function Storage.join(...)
  local parts = { ... }
  local result = ""
  for _, part in ipairs(parts) do
    local text = tostring(part or ""):gsub("\\", "/")
    text = text:gsub("^/+", ""):gsub("/+$", "")
    if text ~= "" then
      if result ~= "" then
        result = result .. "/"
      end
      result = result .. text
    end
  end
  return result
end

function Storage.component(value)
  local text = tostring(value or "")
  local encoded = {}
  for index = 1, #text do
    encoded[#encoded + 1] = string.format("%02x", string.byte(text, index))
  end
  return table.concat(encoded)
end

function Storage.fileToken(value)
  local text = tostring(value or "")
  local first = 5381
  local second = 52711
  for index = 1, #text do
    local byte = string.byte(text, index)
    first = (first * 33 + byte) % 4294967291
    second = (second * 65599 + byte) % 4294967279
  end
  return string.format("%08x%08x", first, second)
end

function Storage.newId(prefix)
  idCounter = idCounter + 1
  local timestamp = os.date("!%Y%m%dT%H%M%SZ")
  local clock = math.floor((os.clock() or 0) * 1000000)
  return string.format("%s-%s-%06x-%04x", prefix or "item", timestamp, clock, idCounter)
end

function Storage.timestamp()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

function Storage.normalizeName(value, limit)
  local name = trim(value)
  if name == "" then
    return nil, "Name cannot be empty."
  end

  local maximum = tonumber(limit) or 96
  if utf8Length(name) > maximum then
    return nil, string.format("Name cannot exceed %d characters.", maximum)
  end

  return name, nil
end

function Storage:ensureParent(path)
  local parent = parentPath(path)
  if parent == nil or parent == "" then
    return true, nil
  end
  return self.ensureDirectory(parent)
end

function Storage:readJson(path, fallback)
  local decoded, decodeError, exists = readDecodedFile(self, path)
  if decoded ~= nil then
    return decoded, nil
  end

  local backup = path .. ".bak"
  local recovered, backupError, backupExists = readDecodedFile(self, backup)
  if recovered ~= nil then
    local corrupt = path .. ".corrupt"
    os.remove(corrupt)
    if exists then
      os.rename(path, corrupt)
    end
    if not pathExists(path) then
      os.rename(backup, path)
    end
    return recovered, nil
  end

  if exists then
    return nil, decodeError
  end
  if backupExists then
    return nil, backupError
  end
  return copy(fallback), nil
end

function Storage:writeJson(path, value)
  local ok, encoded = pcall(function()
    return self.json.encode(value)
  end)
  if not ok or type(encoded) ~= "string" then
    return false, "Could not encode " .. tostring(path) .. ": " .. tostring(encoded)
  end

  local parentOk, parentError = self:ensureParent(path)
  if not parentOk then
    return false, parentError
  end

  local temporary = path .. ".tmp"
  local backup = path .. ".bak"
  local file, openError = io.open(temporary, "wb")
  if file == nil then
    return false, "Could not open temporary file: " .. tostring(openError)
  end

  local writeOk, writeError = pcall(function()
    file:write(encoded)
    file:flush()
  end)
  file:close()
  if not writeOk then
    os.remove(temporary)
    return false, "Could not write temporary file: " .. tostring(writeError)
  end

  os.remove(backup)
  local hadOriginal = pathExists(path)
  if hadOriginal then
    local backedUp, backupError = os.rename(path, backup)
    if not backedUp then
      os.remove(temporary)
      return false, "Could not create backup: " .. tostring(backupError)
    end
  end

  local replaced, replaceError = os.rename(temporary, path)
  if not replaced then
    if hadOriginal then
      os.rename(backup, path)
    end
    os.remove(temporary)
    return false, "Could not replace data file: " .. tostring(replaceError)
  end

  return true, nil
end

function Storage:remove(path)
  local paths = {
    path,
    path .. ".tmp",
    path .. ".bak",
    path .. ".corrupt",
  }
  local errors = {}
  for _, candidate in ipairs(paths) do
    if pathExists(candidate) then
      local ok, err = os.remove(candidate)
      if not ok then
        errors[#errors + 1] = tostring(err)
      end
    end
  end

  if #errors > 0 then
    return false, table.concat(errors, "; ")
  end
  return true, nil
end

return Storage
