local state = {
  framework = nil,
  previousValue = nil,
  active = false,
  ownsValue = false,
  initSeen = false,
  registrySnapshot = {},
  elapsed = 0,
  stableElapsed = 0,
  stableFrames = 0,
  fingerprintElapsed = 0,
  registryFingerprint = nil,
  originalMethods = {},
  wrappedMethods = {},
}

local MIN_PUBLICATION_SECONDS = 1.0
local QUIET_SECONDS = 0.25
local MIN_STABLE_FRAMES = 3
local MAX_PUBLICATION_SECONDS = 3.0
local FINGERPRINT_INTERVAL_SECONDS = 0.05
local unpackValues = table.unpack or unpack
local REGISTRATION_METHODS = {
  "addTab",
  "addSubcategory",
  "addSwitch",
  "addRangeInt",
  "addRangeFloat",
  "addSelectorString",
  "addButton",
  "addKeyBinding",
  "addCustom",
  "registerRestoreDefaultsCallback",
}

local captureRegistry
local captureTab
local installRegistrationHooks
local restoreRegistrationHooks

local function nativeSettings()
  if type(GetMod) ~= "function" then
    return nil
  end

  return GetMod("nativeSettings") or GetMod("NativeSettings")
end

local function acquire()
  if state.active then
    return true
  end

  local framework = nativeSettings()
  if type(framework) ~= "table" then
    return false
  end

  state.framework = framework
  state.previousValue = framework.fromMods
  state.ownsValue = framework.fromMods ~= true
  framework.fromMods = true
  state.active = true
  installRegistrationHooks()
  return true
end

local function cloneRegistryValue(value, seen, fieldName)
  if fieldName == "controller" then
    return nil
  end
  if type(value) ~= "table" then
    return value
  end

  seen = seen or {}
  if seen[value] ~= nil then
    return seen[value]
  end

  local copy = {}
  seen[value] = copy
  for key, item in pairs(value) do
    if key ~= "controller" then
      copy[key] = cloneRegistryValue(item, seen, key)
    end
  end
  return setmetatable(copy, getmetatable(value))
end

captureRegistry = function()
  if type(state.framework) ~= "table" or type(state.framework.data) ~= "table" then
    return
  end

  for tabPath, tab in pairs(state.framework.data) do
    if tostring(tabPath) ~= "noMod" and type(tab) == "table" then
      state.registrySnapshot[tabPath] = cloneRegistryValue(tab)
    end
  end
end

local function tabPathFromRegistrationPath(path)
  if type(path) ~= "string" then
    return nil
  end

  return path:match("^/([^/]+)") or path:gsub("/", "")
end

captureTab = function(path)
  if type(state.framework) ~= "table" or type(state.framework.data) ~= "table" then
    return
  end

  local tabPath = tabPathFromRegistrationPath(path)
  local tab = tabPath ~= nil and state.framework.data[tabPath] or nil
  if tabPath ~= "noMod" and type(tab) == "table" then
    state.registrySnapshot[tabPath] = cloneRegistryValue(tab)
  end
end

local function pack(...)
  return {
    n = select("#", ...),
    ...,
  }
end

installRegistrationHooks = function()
  local framework = state.framework
  if type(framework) ~= "table" then
    return
  end

  for _, methodName in ipairs(REGISTRATION_METHODS) do
    local original = framework[methodName]
    if type(original) == "function" and state.originalMethods[methodName] == nil then
      local wrapped = function(...)
        local path = select(1, ...)
        local result = pack(original(...))
        captureTab(path)
        state.stableElapsed = 0
        state.stableFrames = 0
        return unpackValues(result, 1, result.n)
      end

      state.originalMethods[methodName] = original
      state.wrappedMethods[methodName] = wrapped
      framework[methodName] = wrapped
    end
  end
end

restoreRegistrationHooks = function()
  local framework = state.framework
  if type(framework) == "table" then
    for methodName, original in pairs(state.originalMethods) do
      if framework[methodName] == state.wrappedMethods[methodName] then
        framework[methodName] = original
      end
    end
  end

  state.originalMethods = {}
  state.wrappedMethods = {}
end

local function registryFingerprint()
  if type(state.framework) ~= "table" or type(state.framework.data) ~= "table" then
    return ""
  end

  local parts = {}
  local seen = {}

  local function appendStructure(value, path)
    if type(value) ~= "table" or seen[value] then
      return
    end
    seen[value] = true

    local keys = {}
    for key in pairs(value) do
      if key ~= "controller" then
        keys[#keys + 1] = key
      end
    end
    table.sort(keys, function(left, right)
      return tostring(left) < tostring(right)
    end)

    for _, key in ipairs(keys) do
      local item = value[key]
      local itemPath = path .. "/" .. tostring(key)
      if type(item) == "table" then
        parts[#parts + 1] = itemPath .. ":table"
        appendStructure(item, itemPath)
      elseif key == "type" or key == "path" or key == "fullPath" or key == "label" then
        parts[#parts + 1] = itemPath .. ":" .. tostring(item)
      end
    end
  end

  appendStructure(state.framework.data, "")
  return table.concat(parts, "\n")
end

local function resetStability()
  state.elapsed = 0
  state.stableElapsed = 0
  state.stableFrames = 0
  state.fingerprintElapsed = 0
  state.registryFingerprint = nil
end

local function release()
  if not state.active then
    return
  end

  captureRegistry()
  restoreRegistrationHooks()

  if state.ownsValue and type(state.framework) == "table" and state.framework.fromMods == true then
    state.framework.fromMods = state.previousValue
  end

  state.framework = nil
  state.previousValue = nil
  state.active = false
  state.ownsValue = false
  resetStability()
end

registerForEvent("onInit", function()
  state.initSeen = true
  acquire()
  captureRegistry()
  state.registryFingerprint = registryFingerprint()
end)

registerForEvent("onUpdate", function(deltaTime)
  if not state.initSeen or not state.active then
    return
  end

  local elapsed = tonumber(deltaTime)
  if elapsed == nil or elapsed <= 0 then
    elapsed = 1 / 60
  end

  state.elapsed = state.elapsed + elapsed
  state.fingerprintElapsed = state.fingerprintElapsed + elapsed

  if state.fingerprintElapsed >= FINGERPRINT_INTERVAL_SECONDS then
    local fingerprintElapsed = state.fingerprintElapsed
    state.fingerprintElapsed = 0

    local fingerprint = registryFingerprint()
    if fingerprint ~= state.registryFingerprint then
      captureRegistry()
      state.registryFingerprint = fingerprint
      state.stableElapsed = 0
      state.stableFrames = 0
    else
      state.stableElapsed = state.stableElapsed + fingerprintElapsed
      state.stableFrames = state.stableFrames + 1
    end
  end

  local registryIsStable = state.elapsed >= MIN_PUBLICATION_SECONDS
    and state.stableElapsed >= QUIET_SECONDS
    and state.stableFrames >= MIN_STABLE_FRAMES

  if registryIsStable or state.elapsed >= MAX_PUBLICATION_SECONDS then
    release()
  end
end)

registerForEvent("onShutdown", function()
  release()
end)

return {
  isActive = function()
    return state.active
  end,
  getRegistrySnapshot = function()
    return state.registrySnapshot
  end,
}
