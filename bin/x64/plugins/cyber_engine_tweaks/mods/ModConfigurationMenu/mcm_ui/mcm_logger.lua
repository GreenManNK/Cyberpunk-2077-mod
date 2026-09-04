local Logger = {}

local PREFIX = "[ModConfigurationMenu]"
local LOG_NAME = "ModConfigurationMenu.log"
local MAX_LOG_BYTES = 2 * 1024 * 1024

local initialized = false
local logPath = nil
local fallbackReported = false
local pendingLines = {}

local function sourceDirectory()
  local source = ""
  if type(debug) == "table" and type(debug.getinfo) == "function" then
    local info = debug.getinfo(1, "S")
    source = info and tostring(info.source or "") or ""
  end
  source = source:gsub("^@", "")

  local rootDirectory = source:match("^(.*)[/\\]mcm_ui[/\\]mcm_logger%.lua$")
  if rootDirectory ~= nil and rootDirectory ~= "" then
    return rootDirectory
  end
  return "."
end

local function reportFileFailure(message)
  if fallbackReported then
    return
  end
  fallbackReported = true

  local line = PREFIX .. " [ERROR] " .. tostring(message)
  if type(spdlog) == "table" and type(spdlog.error) == "function" then
    spdlog.error(line)
  else
    print(line)
  end
end

local function initialize()
  if initialized then
    return logPath ~= nil
  end
  initialized = true

  if type(registerForEvent) ~= "function" then
    return false
  end

  logPath = sourceDirectory() .. "/" .. LOG_NAME

  local existing = io.open(logPath, "rb")
  local size = 0
  if existing ~= nil then
    size = existing:seek("end") or 0
    existing:close()
  end
  if size > MAX_LOG_BYTES then
    local truncated = io.open(logPath, "w")
    if truncated ~= nil then
      truncated:write("Log truncated after exceeding 2 MiB.\n")
      truncated:close()
    end
  end

  local file = io.open(logPath, "a")
  if file == nil then
    logPath = nil
    reportFileFailure("Could not open the dedicated log file.")
    return false
  end
  file:write(
    string.format("\n--- MCM UI session started at %s ---\n", os.date("%Y-%m-%d %H:%M:%S"))
  )
  file:close()
  return true
end

local function write(level, message)
  pendingLines[#pendingLines + 1] = string.format(
    "[%s] %s [%s] %s\n",
    os.date("%Y-%m-%d %H:%M:%S"),
    PREFIX,
    level,
    tostring(message)
  )
end

function Logger.initialize()
  return initialize()
end

function Logger.flush()
  if #pendingLines == 0 or not initialize() then
    return
  end

  local lines = pendingLines
  pendingLines = {}

  local file = io.open(logPath, "a")
  if file == nil then
    for _, line in ipairs(lines) do
      pendingLines[#pendingLines + 1] = line
    end
    reportFileFailure("Could not append to the dedicated log file.")
    return
  end

  file:write(table.concat(lines))
  file:close()
end

function Logger.error(message)
  write("ERROR", message)
end

return Logger
