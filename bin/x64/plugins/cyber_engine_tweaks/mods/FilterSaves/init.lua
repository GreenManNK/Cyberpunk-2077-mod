local settings = {
  rememberType = false,
  rememberLifepath = false,
  lastType = "All",
  lastLifepath = "All"
}

local GameUI = require('GameUI')

registerForEvent("onInit", function()
  LoadSettings()

  SetupMenuListener()
  SetupMenu()

  Override('FilterSaves.FilterSavesConfig', 'RememberType;', function()
    return settings.rememberType
  end)
  
  Override('FilterSaves.FilterSavesConfig', 'RememberLifepath;', function()
    return settings.rememberLifepath
  end)

  Override('FilterSaves.FilterSavesConfig', 'SaveTypeFilter;SaveTypeFilter', function(filter)
    settings.lastType = filter.value
    SaveSettings()
  end)

  Override('FilterSaves.FilterSavesConfig', 'SaveLifepathFilter;LifePathFilter', function(filter)
    settings.lastLifepath = filter.value
    SaveSettings()
  end)

  Override('FilterSaves.FilterSavesConfig', 'GetSavedTypeFilter;', function()
    return Enum.new('FilterSaves.SaveTypeFilter', settings.lastType)
  end)

  Override('FilterSaves.FilterSavesConfig', 'GetSavedLifepathFilter;', function()
    return Enum.new('FilterSaves.LifePathFilter', settings.lastLifepath)
  end)
end)

function SetupMenu()
  local nativeSettings = GetMod("nativeSettings")

  if not nativeSettings.pathExists("/filter_saves") then
    nativeSettings.addTab("/filter_saves", "Filter Saves")
  end

  -- Type Filter - Save
  local typeSwitchName = GetLocalizedText("LocKey#22100") .. " " .. GetLocalizedText("LocKey#15393") .. " - " .. GetLocalizedText("LocKey#83280")
  nativeSettings.addSwitch("/filter_saves", typeSwitchName, "", settings.rememberType, false, function(state)
    settings.rememberType = state
    settings.lastType = "All"
  end)

  -- Lifepath Filter - Save
  local lifepathSwitchName = GetLocalizedText("LocKey#46336") .. " " .. GetLocalizedText("LocKey#15393") .. " - " .. GetLocalizedText("LocKey#83280")
  nativeSettings.addSwitch("/filter_saves", lifepathSwitchName, "", settings.rememberLifepath, false, function(state)
    settings.rememberLifepath = state
    settings.lastLifepath = "All"
  end)

  nativeSettings.refresh()
end

function SetupMenuListener()
  GameUI.Listen("MenuNav", function(state)
		if state.lastSubmenu ~= nil and state.lastSubmenu == "Settings" then
      SaveSettings()
    end
	end)
end

function LoadSettings()
  local file = io.open('settings.json', 'r')
  if file ~= nil then
    local contents = file:read("*a")
    local validJson, savedSettings = pcall(function() return json.decode(contents) end)
    file:close()

    if validJson then
      for key, _ in pairs(settings) do
        if savedSettings[key] ~= nil then
          settings[key] = savedSettings[key]
        end
      end
    end
  end
end

function SaveSettings()
  local validJson, contents = pcall(function() return json.encode(settings) end)

  if validJson and contents ~= nil then
    local file = io.open("settings.json", "w+")
    file:write(contents)
    file:close()
  end
end
