local Logger = {}

local PREFIX = "[ModConfigurationMenuAPI]"
local LOG_NAME = "ModConfigurationMenuAPI.log"
local MAX_LOG_BYTES = 2 * 1024 * 1024

local initialized = false
local logPath = nil
local fallbackReported = false

local function sourceDirectory()
  local source = ""
  if type(debug) == "table" and type(debug.getinfo) == "function" then
    local info = debug.getinfo(1, "S")
    source = info and tostring(info.source or "") or ""
  end
  source = source:gsub("^@", "")

  local modulesDirectory = source:match("^(.*)[/\\]modules[/\\]logger%.lua$")
  if modulesDirectory ~= nil and modulesDirectory ~= "" then
    return modulesDirectory
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
    string.format("\n--- MCM API session started at %s ---\n", os.date("%Y-%m-%d %H:%M:%S"))
  )
  file:close()
  return true
end

local function write(level, message)
  if not initialize() then
    return
  end

  local file = io.open(logPath, "a")
  if file == nil then
    reportFileFailure("Could not append to the dedicated log file.")
    return
  end
  file:write(
    string.format(
      "[%s] %s [%s] %s\n",
      os.date("%Y-%m-%d %H:%M:%S"),
      PREFIX,
      level,
      tostring(message)
    )
  )
  file:close()
end

function Logger.info(message)
  write("INFO", message)
end

function Logger.warn(message)
  write("WARN", message)
end

function Logger.error(message)
  write("ERROR", message)
end

return Logger
