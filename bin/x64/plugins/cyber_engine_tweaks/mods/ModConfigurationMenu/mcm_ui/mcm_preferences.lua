local Theme = require("mcm_ui/mcm_theme")
local Host = require("mcm_ui/mcm_host")

local Preferences = {}

local PATH = "config.json"
local TEMPORARY_PATH = PATH .. ".tmp"
local BACKUP_PATH = PATH .. ".bak"
local CORRUPT_PATH = PATH .. ".corrupt"
local JSON_INDENT = "    "
local DEFAULTS = {
  initialSetupVersion = 0,
  menuEntryLabel = "MCM",
  gameplayShortcut = "IK_Home",
  redirectFrameworkMenuEntries = true,
  providerFilter = "all",
  showModProviderPrefix = true,
  listSelectionMode = "text",
  modSortMode = "az",
  modSortWithProvider = false,
  sidebarTextScrollMode = "pingpong",
  sidebarTextScrollActivation = "hover_selected",
  sidebarTextScrollSpeed = "normal",
  favoriteUxMode = "both",
  favoriteModKeys = {},
  settingsSortMode = "file",
  defaultIndicatorMode = "colored",
  presetNonDefaultOnly = false,
  showDescriptionPanel = true,
  layoutProfile = Host.DEFAULT_PROFILE,
  uiScale = Host.DEFAULT_SCALE,
  autoApply = false,
  themeColors = Theme.defaults(),
}

local function copyDefaults()
  local result = {}
  for key, value in pairs(DEFAULTS) do
    if type(value) == "table" then
      result[key] = {}
      for itemKey, itemValue in pairs(value) do
        result[key][itemKey] = itemValue
      end
    else
      result[key] = value
    end
  end

  return result
end

local function normalizeFavoriteKeys(value)
  local result = {}
  if type(value) ~= "table" then
    return result
  end

  for key, item in pairs(value) do
    local candidate = nil
    if type(key) == "number" then
      candidate = item
    elseif item == true then
      candidate = key
    end
    if type(candidate) == "string" and candidate ~= "" then
      result[candidate] = true
    end
  end
  return result
end

local function pathExists(path)
  local file = io.open(path, "rb")
  if file == nil then
    return false
  end
  file:close()
  return true
end

local function readSaved(path)
  local file = io.open(path, "rb")
  if file == nil then
    return nil, false
  end

  local readOk, raw = pcall(function()
    return file:read("*a")
  end)
  file:close()
  if not readOk then
    return nil, true
  end

  local decodeOk, saved = pcall(function()
    return json.decode(raw or "")
  end)
  if not decodeOk or type(saved) ~= "table" then
    return nil, true
  end
  return saved, true
end

local function loadSaved()
  local saved, exists = readSaved(PATH)
  if saved ~= nil then
    return saved
  end

  local recovered = readSaved(BACKUP_PATH)
  local recoveryPath = BACKUP_PATH
  if recovered == nil then
    recovered = readSaved(TEMPORARY_PATH)
    recoveryPath = TEMPORARY_PATH
  end
  if recovered == nil then
    return nil
  end

  if exists then
    os.remove(CORRUPT_PATH)
    os.rename(PATH, CORRUPT_PATH)
  end
  if not pathExists(PATH) then
    os.rename(recoveryPath, PATH)
  end
  if recoveryPath == BACKUP_PATH then
    os.remove(TEMPORARY_PATH)
  end
  return recovered
end

local function formatJson(encoded)
  local output = {}
  local depth = 0
  local inString = false
  local escaped = false
  local length = #encoded

  local function newline()
    output[#output + 1] = "\n" .. string.rep(JSON_INDENT, depth)
  end

  for index = 1, length do
    local character = string.sub(encoded, index, index)
    if inString then
      output[#output + 1] = character
      if escaped then
        escaped = false
      elseif character == "\\" then
        escaped = true
      elseif character == '"' then
        inString = false
      end
    elseif character == '"' then
      inString = true
      output[#output + 1] = character
    elseif character == "{" or character == "[" then
      output[#output + 1] = character
      local closing = character == "{" and "}" or "]"
      if string.sub(encoded, index + 1, index + 1) ~= closing then
        depth = depth + 1
        newline()
      end
    elseif character == "}" or character == "]" then
      local opening = character == "}" and "{" or "["
      if string.sub(encoded, index - 1, index - 1) ~= opening then
        depth = math.max(0, depth - 1)
        newline()
      end
      output[#output + 1] = character
    elseif character == "," then
      output[#output + 1] = character
      newline()
    elseif character == ":" then
      output[#output + 1] = ": "
    else
      output[#output + 1] = character
    end
  end

  return table.concat(output) .. "\n"
end

function Preferences.formatJson(encoded)
  return formatJson(encoded)
end

function Preferences.encode(value)
  return Preferences.formatJson(json.encode(value))
end

function Preferences.load()
  local result = copyDefaults()
  local saved = loadSaved()
  if saved == nil then
    return result
  end

  if saved.menuEntryLabel == "MCM" or saved.menuEntryLabel == "MODS" then
    result.menuEntryLabel = saved.menuEntryLabel
  end
  if
    type(saved.gameplayShortcut) == "string"
    and string.sub(saved.gameplayShortcut, 1, 3) == "IK_"
    and saved.gameplayShortcut ~= "IK_Escape"
  then
    result.gameplayShortcut = saved.gameplayShortcut
  end
  if type(saved.redirectFrameworkMenuEntries) == "boolean" then
    result.redirectFrameworkMenuEntries = saved.redirectFrameworkMenuEntries
  end
  if tonumber(saved.initialSetupVersion) ~= nil and tonumber(saved.initialSetupVersion) >= 0 then
    result.initialSetupVersion = math.floor(tonumber(saved.initialSetupVersion))
  end
  if type(saved.providerFilter) == "string" and saved.providerFilter ~= "" then
    result.providerFilter = saved.providerFilter
  end
  if type(saved.showModProviderPrefix) == "boolean" then
    result.showModProviderPrefix = saved.showModProviderPrefix
  end
  if saved.listSelectionMode == "frame" or saved.listSelectionMode == "text" then
    result.listSelectionMode = saved.listSelectionMode
  end
  if saved.modSortMode == "az" or saved.modSortMode == "za" then
    result.modSortMode = saved.modSortMode
  end
  if type(saved.modSortWithProvider) == "boolean" then
    result.modSortWithProvider = saved.modSortWithProvider
  end
  if
    saved.sidebarTextScrollMode == "off"
    or saved.sidebarTextScrollMode == "loop"
    or saved.sidebarTextScrollMode == "pingpong"
  then
    result.sidebarTextScrollMode = saved.sidebarTextScrollMode
  end
  if
    saved.sidebarTextScrollActivation == "always"
    or saved.sidebarTextScrollActivation == "hover"
    or saved.sidebarTextScrollActivation == "hover_selected"
    or saved.sidebarTextScrollActivation == "selected"
  then
    result.sidebarTextScrollActivation = saved.sidebarTextScrollActivation
  end
  if
    saved.sidebarTextScrollSpeed == "slow"
    or saved.sidebarTextScrollSpeed == "normal"
    or saved.sidebarTextScrollSpeed == "fast"
    or saved.sidebarTextScrollSpeed == "very_fast"
  then
    result.sidebarTextScrollSpeed = saved.sidebarTextScrollSpeed
  end
  if
    saved.favoriteUxMode == "off"
    or saved.favoriteUxMode == "star"
    or saved.favoriteUxMode == "button"
    or saved.favoriteUxMode == "both"
  then
    result.favoriteUxMode = saved.favoriteUxMode
  end
  result.favoriteModKeys = normalizeFavoriteKeys(saved.favoriteModKeys)
  if
    saved.settingsSortMode == "file"
    or saved.settingsSortMode == "az"
    or saved.settingsSortMode == "za"
  then
    result.settingsSortMode = saved.settingsSortMode
  end
  if
    saved.defaultIndicatorMode == "off"
    or saved.defaultIndicatorMode == "asterisk"
    or saved.defaultIndicatorMode == "colored"
  then
    result.defaultIndicatorMode = saved.defaultIndicatorMode
  end
  if type(saved.presetNonDefaultOnly) == "boolean" then
    result.presetNonDefaultOnly = saved.presetNonDefaultOnly
  end
  if type(saved.showDescriptionPanel) == "boolean" then
    result.showDescriptionPanel = saved.showDescriptionPanel
  end
  result.layoutProfile = Host.normalizeProfile(saved.layoutProfile)
  result.uiScale = Host.normalizeScale(saved.uiScale)
  if type(saved.autoApply) == "boolean" then
    result.autoApply = saved.autoApply
  end
  result.themeColors = Theme.normalize(saved.themeColors)
  return result
end

function Preferences.save(value)
  local ok, encoded = pcall(function()
    return Preferences.encode(value)
  end)
  if not ok or type(encoded) ~= "string" then
    return false, tostring(encoded)
  end

  local file, err = io.open(TEMPORARY_PATH, "wb")
  if file == nil then
    return false, tostring(err)
  end

  local writeOk, writeError = pcall(function()
    file:write(encoded)
    file:flush()
  end)
  file:close()
  if not writeOk then
    os.remove(TEMPORARY_PATH)
    return false, "Could not write temporary preferences: " .. tostring(writeError)
  end

  local hadOriginal = pathExists(PATH)
  if hadOriginal then
    os.remove(BACKUP_PATH)
    local backedUp, backupError = os.rename(PATH, BACKUP_PATH)
    if not backedUp then
      os.remove(TEMPORARY_PATH)
      return false, "Could not back up preferences: " .. tostring(backupError)
    end
  end

  local replaced, replaceError = os.rename(TEMPORARY_PATH, PATH)
  if not replaced then
    if hadOriginal then
      os.rename(BACKUP_PATH, PATH)
    end
    os.remove(TEMPORARY_PATH)
    return false, "Could not replace preferences: " .. tostring(replaceError)
  end
  return true, nil
end

return Preferences
