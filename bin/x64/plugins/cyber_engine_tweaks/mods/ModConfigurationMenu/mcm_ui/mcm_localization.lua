local Localization = {}

local FALLBACK_LOCALE = "en-us"
local LANGUAGE_DIR = "mcm_ui/locales/"

local currentLocale = FALLBACK_LOCALE
local strings = {}

local function readJson(path)
  local file = io.open(path, "rb")
  if file == nil then
    return nil
  end

  local raw = file:read("*a")
  file:close()
  if raw == nil or raw == "" then
    return nil
  end

  local ok, data = pcall(function()
    return json.decode(raw)
  end)
  if not ok or type(data) ~= "table" then
    return nil
  end

  return data
end

local function merge(target, source)
  if type(source) ~= "table" then
    return
  end

  for key, value in pairs(source) do
    if type(key) == "string" and type(value) == "string" then
      target[key] = value
    end
  end
end

local function detect()
  local locale = FALLBACK_LOCALE
  pcall(function()
    local settings = Game.GetSettingsSystem()
    if
      settings ~= nil
      and settings:HasGroup("/language")
      and settings:HasVar("/language", "OnScreen")
    then
      local value = settings:GetVar("/language", "OnScreen"):GetValue()
      local raw = Game.NameToString(value)

      if raw ~= nil and raw ~= "" then
        locale = tostring(raw)
      end
    end
  end)
  return locale
end

function Localization.refresh()
  currentLocale = detect()
  strings = {}
  merge(strings, readJson(LANGUAGE_DIR .. FALLBACK_LOCALE .. ".json"))
  if currentLocale ~= FALLBACK_LOCALE then
    merge(strings, readJson(LANGUAGE_DIR .. currentLocale .. ".json"))
  end
  return currentLocale
end

function Localization.getLocale()
  return currentLocale
end

function Localization.text(key, values)
  local result = strings[key] or key
  local replacements = values
  if type(replacements) ~= "table" then
    replacements = {}
  end

  for name, value in pairs(replacements) do
    local replacement = tostring(value):gsub("%%", "%%%%")
    result = result:gsub("{" .. tostring(name) .. "}", replacement)
  end
  return result
end

Localization.refresh()

return Localization
