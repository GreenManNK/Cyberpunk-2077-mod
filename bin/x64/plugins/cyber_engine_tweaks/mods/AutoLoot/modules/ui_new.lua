-------------------------------------------------------------------------------------------------------------------------------
-- Mod expansion and additional coding by anygoodname by keanuWheeze consent.
-- This mod shall not be redistributed or modified/renamed/rebranded and published as a separate mod without keanuWheeze and anygoodname permission.
-- To use code snippets from this mod in other mods requires a consent and a proper credit note.

--[[ DISCLAIMER:

This mod is a non-commercial fan creation intended for personal use only.

By using the word "republish" I mean both republish and redistribute in this disclaimer:
You're not allowed to republish the mod without my consent or against the Nexusmods rules.
You're not allowed to republish parts of this mod code or files without consent. Either mine either other authors.
You can modify the mod code or files for your personal use only.
By modifying the mod code or files, you acknowledge I cannot support the modified mod code or files.
You're not allowed to publish your modifications to the mod code or files without my consent.
You're not allowed to publicly propose unauthorized changes to the mod code or files.
You're not allowed to use any part of the mod code or files for commercial purposes, advertising or promotion of any kind.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

-- DO NOT TRANSLATE THIS FILE!
-- Translation support is described in the file: "..\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\AutoLoot\language\Readme.txt"

-- Jun 20, 2026 based on the (c)keanuWheeze original script modified by (c)anygoodname by the keanuWheeze consent

function printError(...)
	local args = {...}
	if #args < 1 then return end
	local output = tostring(args[1])
	if #args > 1 then for i = 2, #args do output = output..' '..tostring(args[i]) end end
	if type(output) == 'string' and string.len(output) > 0 then
		print(output)
		spdlog.error(output)
	end
end

local n, t
local nativeSettings, isUsingNativeSettings, nativeSettingsIgnoreAction = nil, false, false
local nativeSettingsOptions = {}
local nativeSettingsSubcategoryPaths = {}
local isInitialized = false
local nativeSettingsIgnoreNextAction, nativeSettingsPlaySounds
local lastMinimapContainerController = nil
local lastShowWidget, lastIsLooting
local shouldForceMinimapMonitorUpdate
local tintColor = "tintColor"
local fontStyle = "fontStyle"
local MainColorsBlue = "MainColors.Blue"
local MainColorsActiveBlue = "MainColors.ActiveBlue"
local MainColorsMediumBlue = "MainColors.MediumBlue"
local MainColorsRed = "MainColors.Red"
local MainColorsActiveRed = "MainColors.ActiveRed"
local MainColorsBodyFontWeight = "MainColors.BodyFontWeight"
local isPreGameState = true
local GameGetSystemRequestsHandler
local isSameInstance

local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

local isGameV2 = false
if cetVer >= 1.26 then isGameV2 = true end

ui = {
		modVer = 'v3.10.3',
		moduleVer = 'v3.10.3',
		modName = 'Autoloot',
		modAuthorName = 'keanuWheeze and anygoodname',
		isInitialized = false,
		uiStrings,
		config = require("modules/config")
	}

local uiDefaultStrings = {
	exportOrder = {"cetUiStrings", "nuiUiStrings"},
	cetUiStrings = {
		exportOrder = {"cetKeyBindings", "settings", "monitor", "warnings"},
		cetKeyBindings = {
			autolootMonitorKey = "AutoLoot Monitor",
			autolootTriggerKey = "AutoLoot",
		},
		settings = {
			exportOrder = {"windowTitle", "general_settings", "tooltipsHeader", "range", "useDefaultActionKey", "enableTakedownLoot", "enableBurstTrigger", "burstTriggerCooldownTime", "monitor_settings", "showDebugMonitorWindow", "monitorType", "showMonitorWindowOnlyWhenTriggerActive", "autohideMonitorWindow"},
			windowTitle = "AutoLoot",
			general_settings = "General settings:",
			tooltipsHeader = "Hover your mouse over a menu item on the left to see its tooltip displayed here.",
			range = {title = "Range:", tooltips = "This sets the maximum range for the auto loot."},
			useDefaultActionKey = {title = "Use the game default action key.", tooltips = "This enables the autoloot on the game default action key press.\nWarning: beware of the Midas golden touch syndrome!"},
			enableTakedownLoot = {title = "Autoloot NPCs on Takedowns.", tooltips = "This option enables automatic looting of NPCs defeated by performing takedowns.\nPlease note that quest-related items and iconic weapons will not be looted."},
			enableBurstTrigger = {title = "Enable Burst mode", tooltips = "The Burst mode allows you to toggle continuous autolooting on a loot trigger double-tap for a period of time.\n\nBursts last up to the defined maximum duration and can be stopped by double-tapping again, entering combat, entering vehicles, pausing the game, or other game state changes that require breaking autolooting for some reason.\n\nFor better control of the autolooting state, please consider turning on the Looting Monitor."},
			burstTriggerCooldownTime = {title = "Max. Burst duration (mm:ss):", tooltips = "This option sets the maximum duration for a looting burst.\nNote: changes will be applied on the next burst."},
			monitor_settings = "Looting Monitor settings:",
			showDebugMonitorWindow = {title = "Show Monitor window.", tooltips = "This enables a small monitor window showing the current autolooting state.\nPlease note that the monitor window may be hidden when visiting the game Settings menu."},
			monitorType = {title = "Select Monitor type:", tooltips = "Select the type of the Looting Monitor to display.", choices = {"CET window", "Minimap indicator", "CET window and Minimap indicator"}},
			showMonitorWindowOnlyWhenTriggerActive = {title = "Show Monitor only if looting trigger active.", tooltips = "Show the monitor only when the looting trigger is active (key/button pressed or Burst mode active)."},
			autohideMonitorWindow = {title = "Autohide Monitor window.", tooltips = "When enabled, it will automatically hide and show the monitor window following the game cinematic state."},
		},
		monitor = {
			idleStr = "Idle.",
			lootingStr = "Looting ",
		},
		warnings = {
			modDisabled = "This mod is disabled due to corrupted mod files or incompatibility with the current game version."
		}
	},
	nuiUiStrings = {
		settings = {
			exportOrder = {"windowTitle", "general_settings", "range", "useDefaultActionKey", "enableTakedownLoot", "enableBurstTrigger", "burstTriggerCooldownTime", "monitor_settings", "showDebugMonitorWindow", "monitorType", "showMonitorWindowOnlyWhenTriggerActive", "autohideMonitorWindow"},
			windowTitle = "AutoLoot",
			general_settings = "General settings:",
			range = {title = "Range", tooltips = "This sets the maximum range for the auto loot."},
			useDefaultActionKey = {title = "Use the game default action key", tooltips = "This enables the auto loot on the game default action key press.\nWarning: beware of the Midas golden touch syndrome!"},
			enableTakedownLoot = {title = "Autoloot NPCs on Takedowns", tooltips = "This option enables automatic looting of NPCs defeated by performing takedowns.\nPlease note that quest-related items and iconic weapons will not be looted."},
			enableBurstTrigger = {title = "Enable Burst mode", tooltips = "The Burst mode allows you to toggle continuous autolooting on a loot trigger double-tap for a period of time.\n\nBursts last up to the defined maximum duration and can be stopped by double-tapping again, entering combat, entering vehicles, pausing the game, or other game state changes that require breaking autolooting for some reason.\n\nFor better control of the autolooting state, please consider turning on the Looting Monitor."},
			burstTriggerCooldownTime = {title = "Max. Burst duration (mm:ss)", tooltips = "This option sets the maximum duration for a looting burst.\nNote: changes will be applied on the next burst."},
			monitor_settings = "Looting Monitor settings:",
			showDebugMonitorWindow = {title = "Show Monitor window", tooltips = "This enables a small monitor window showing the current autolooting state.\nPlease note that the monitor window may be hidden when visiting the game Settings menu."},
			monitorType = {title = "Select Monitor type", tooltips = "Select the type of the Looting Monitor to display.", choices = {"CET window", "Minimap indicator", "CET window and Minimap indicator"}},
			showMonitorWindowOnlyWhenTriggerActive = {title = "Show Monitor only if looting trigger active", tooltips = "Show the monitor only when the looting trigger is active (key/button pressed or Burst mode active)."},
			autohideMonitorWindow = {title = "Autohide Monitor window", tooltips = "When enabled, it will automatically hide and show the monitor window following the game cinematic state."},
		},
		monitor = {
			idleStr = "Autoloot is idle",
			lootingStr = "Autolooting ",
		},
	}
}

function cloneTable(source)
	local output = {}
	if #source == 0 then
		for key, entry in pairs(source) do
			if type(entry) == 'table' then
				entry = cloneTable(entry)
			end
			output[key] = entry
		end
	else
		for key, entry in ipairs(source) do
			if type(entry) == 'table' then
				entry = cloneTable(entry)
			end
			table.insert(output, entry)
		end
	end
	return output
end

local uiStrings = cloneTable(uiDefaultStrings)
ui.uiStrings = uiStrings

function dumpTableToJson(inputTable, isCustomOrder, sortIfNoCustomOrderFound)
	local function getTableTypeWithKeysOrCount(array, sort);
		local count = #array;
		local isOrderedArray = count > 0;
		if isOrderedArray then return false, count end;
		local keys = {};
		for key, value in pairs(array) do;
			table.insert(keys, key);
		end;
		if sort then table.sort(keys) end;
		return true, keys;
	end;

    local function serializeTable(val, level)
        local outputStr = ""
        local indentStr = string.rep("\t", level)
        local nextIndentStr = string.rep("\t", level + 1)

        if type(val) == "table" then
			local isTableWithKeys, keysOrCount = getTableTypeWithKeysOrCount(val, not isCustomOrder)
            if not isTableWithKeys then
                outputStr = outputStr .. "[\n"
                for i = 1, #val do
					value = val[i]
					local valueType = type(value)
					if valueType ~= 'table' and valueType ~= 'string' and valueType ~= 'number' and valueType ~= 'boolean' then value = tostring(value) end
                    outputStr = outputStr .. nextIndentStr .. serializeTable(value, level + 1)
                    if i < keysOrCount then outputStr = outputStr .. ",\n" end
                end
                outputStr = outputStr .. "\n" .. indentStr .. "]"
            else
                outputStr = outputStr .. "{\n"
                local comma = false
				local keys = keysOrCount
				if isCustomOrder then
					if type(val.exportOrder) == 'table' and #val.exportOrder > 0 then
						keys = val.exportOrder
					else
						if sortIfNoCustomOrderFound then table.sort(keys) end
					end
				end
				for i, key in ipairs(keys) do
					local value = val[key]
					local valueType = type(value)
					if valueType ~= 'table' and valueType ~= 'string' and valueType ~= 'number' and valueType ~= 'boolean' then value = tostring(value) end
					if comma then outputStr = outputStr .. ",\n" else comma = true end
					outputStr = outputStr .. nextIndentStr .. '"' .. tostring(key) .. '": ' .. serializeTable(value, level + 1)
                end
                outputStr = outputStr .. "\n" .. indentStr .. "}"
            end
        elseif type(val) == "string" then
			outputStr = outputStr .. '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
        else
			outputStr = outputStr .. tostring(val)
        end

		return outputStr
    end

    return serializeTable(inputTable, 0)
end

function loadJsonTable(fileName, verbose)
	if type(fileName) ~= 'string' then return end
	local file = io.open(fileName, "r")
	if file then
		local jString = file:read("*a")
		file:close()
		if type(jString) ~= 'string' then return end
		local decodeResult, data = pcall(function() return json.decode(jString) end)
		if not decodeResult then if verbose then print(data) end return end
		if type(data) ~= 'table' then if verbose then print(fileName, 'does not seem to contain valid table data') end return end
		if verbose then print('Valid table data found in', fileName) end
		return data
	else
		if verbose then print('Cannot find fileName:', fileName) end
	end
end

function saveTextFile(text, fileName)
	if type(text) ~= 'string' then return end
	if type(fileName) ~= 'string' then return end
	local file = io.open(fileName, "w")
	if file then
		file:write(text)
		file:close()
	else
		print('Cannot save text to file', fileName)
	end
end

local exportedStringsFileHeader = {
	exportOrder = {'_1_', 'modName', 'modAuthorName', 'modVer', '_2_', 'translationAuthorName', 'translationVer', '_3_'},
	_1_ = "----------------------------------------",
	modName = ui.modName,
	modAuthorName = ui.modAuthorName,
	modVer = ui.modVer,
	_2_ = "----------------------------------------",
	translationAuthorName = "Put your name here",
	translationVer = "Put your file verison here",
	_3_ = "----------------------------------------",
}

local stringsFileSet = {uiStrings = 'uiStrings.json'}

local exportTable = {}
exportTable.exportOrder = {'fileHeader', 'uiStrings'}
exportTable.fileHeader = exportedStringsFileHeader
exportTable.uiStrings = uiDefaultStrings
pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/uiStrings.json") end

function replaceTableEntries(sourceTable, replacementTable, finalDataType, verbose)
	if type(sourceTable) ~= 'table' then return sourceTable end
	if type(replacementTable) ~= 'table' then return sourceTable end
	if finalDataType ~= 'string' then finalDataType = nil end
	local outputTable = cloneTable(sourceTable)
	local count, replacementCount = 0, 0
	local childResult = true

	for sourceKey, sourceEntry in pairs(sourceTable) do
		count = count + 1
		local replacementEntry = replacementTable[sourceKey]
		if replacementEntry then
			if type(sourceEntry) == 'table' then
				replacementEntry, childResult = replaceTableEntries(sourceEntry, replacementEntry, finalDataType, verbose)
			end
			if replacementEntry then
				local replacementEntryType = type(replacementEntry)
				if replacementEntryType == 'table' or ((not finalDataType) or (finalDataType and replacementEntryType == finalDataType)) then
					outputTable[sourceKey] = replacementEntry
					if childResult then replacementCount = replacementCount + 1 end
				else
					if verbose then printError('incorrect data type:', sourceKey, 'in the replacement table. The missing value is substituted with a default.') end
				end
			else
				if verbose then printError('missing:', sourceKey, 'in the replacement table. The missing value is substituted with a default value.') end
			end
		else
			if verbose then printError('missing:', sourceKey, 'in the replacement table. The missing value is substituted with a default value.') end
		end
	end
	return outputTable, replacementCount > 0
end

local currentUiLanguage = "en-us"
local languages = {
	['ar-ar'] = false,
	['cz-cz'] = false,
	['de-de'] = false,
	['en-us'] = false,
	['es-es'] = false,
	['es-mx'] = false,
	['fr-fr'] = false,
	['hu-hu'] = false,
	['it-it'] = false,
	['jp-jp'] = false,
	['kr-kr'] = false,
	['pl-pl'] = false,
	['pt-br'] = false,
	['ru-ru'] = false,
	['th-th'] = false,
	['tr-tr'] = false,
	['ua-ua'] = false,
	['zh-cn'] = false,
	['zh-tw'] = false,
}

function loadAllLanguageFiles()
	for id, data in pairs(languages) do
		local loadedData = {}
		local fileRoot = "language/"..id.."/"
		local isAnythingLoaded = false
		for tableName, fileName in pairs(stringsFileSet) do
			local filePath = fileRoot..fileName
			local fileData = loadJsonTable(filePath)
			if type(fileData) == 'table' then
				loadedData = {fileHeader = fileData.fileHeader, uiStrings = fileData.uiStrings}
				isAnythingLoaded = true
			end
		end
		if isAnythingLoaded then languages[id] = loadedData 
		print(ui.modName, ui.modVer..':', id, 'language files loaded.') end
	end
end

loadAllLanguageFiles()

function quickloadUserSettings()
	local file = io.open("config/config.json", "r")
	if not file then return end
	local jString = file:read("*a")
	file:close()

	if type(jString) ~= 'string' then return end
	local decodeResult, settings = pcall(function() return json.decode(jString) end)
	if not decodeResult then return end
	if type(settings) ~= 'table' then return end
	return settings
end

function getGameUILanguage(updateUserSettings, forceSettingsUpdate)
	if type(Game) == 'userdata' and type(GetPlayer) == 'function' then
		local lang = "en-us";
		local settingsSystem = Game.GetSettingsSystem();
		if settingsSystem:HasGroup("/language") and settingsSystem:HasVar("/language", "OnScreen") then lang = settingsSystem:GetVar("/language", "OnScreen"):GetValue() end;
		lang = NameToString(lang)
		if updateUserSettings and (isModInitialized or forceSettingsUpdate) then ui.settings.lastLanguageSelected = lang end
		return lang, true
	end

	local lastLanguageSelected = "en-us"
	if isModInitialized then
		if type(ui.settings.lastLanguageSelected) == 'string' then lastLanguageSelected = ui.settings.lastLanguageSelected end
	else
		local userSettings = quickloadUserSettings()
		if userSettings and type(userSettings.lastLanguageSelected) == 'string' then lastLanguageSelected = userSettings.lastLanguageSelected end
	end
	if languages[lastLanguageSelected] then return lastLanguageSelected end
	return "en-us"
end

function loadLocalizedStrings(updateUserSettings, forceSettingsUpdate)
	currentUiLanguage = getGameUILanguage(updateUserSettings, forceSettingsUpdate)

	if type(currentUiLanguage) ~= 'string' then return end
	uiStrings = cloneTable(uiDefaultStrings)
	ui.uiStrings = uiStrings

	local newStringsSet = languages[currentUiLanguage]
	if type(newStringsSet) ~= 'table' then return end

	local isAnythingChanged = false
	for tableName, newTableData in pairs(newStringsSet) do
		if type(newTableData) and tableName == "uiStrings" then
			local replacedTableData, result = replaceTableEntries(uiStrings, newTableData, 'string', false)
			if result then
				uiStrings = replacedTableData
				ui.uiStrings = uiStrings
				isAnythingChanged = true
			end
		end
	end
	if isAnythingChanged and isInitialized then setupNativeSettings(true) end
end

loadLocalizedStrings()

local function IsDefinedNS(gameObj)
	if not gameObj then return false end
	local result, val = pcall(function() return IsDefined(gameObj) end)
	if result then return val else return false end
end

function ui.onInit()
	if isInitialized then return true end

	n = CName
	t = TweakDBID

	isSameInstance = Game['OperatorEqual;IScriptableIScriptable;Bool'] -- (c)keanuWheeze
	tintColor = n"tintColor"
	fontStyle = n"fontStyle"
	MainColorsBlue = n"MainColors.Blue"
	MainColorsActiveBlue = n"MainColors.ActiveBlue"
	MainColorsMediumBlue = n"MainColors.MediumBlue"
	MainColorsRed = n"MainColors.Red"
	MainColorsActiveRed = n"MainColors.ActiveRed"
	MainColorsBodyFontWeight = n"MainColors.BodyFontWeight"

	if isGameV2 then IsDefinedNS = IsDefined end

	GameGetSystemRequestsHandler = Game.GetSystemRequestsHandler
	isPreGameState = GameGetSystemRequestsHandler():IsPreGame()

	local lastlanguageSelected = ui.settings.lastLanguageSelected
	loadLocalizedStrings(true, true)
	if ui.settings.lastLanguageSelected ~= lastlanguageSelected then ui.config.saveConfig("config/config.json", ui.settings) end

	setupNativeSettings()

	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(self)
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if self:IsReplacer() then return end
		local lastlanguageSelected = ui.settings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if ui.settings.lastLanguageSelected ~= lastlanguageSelected then ui.config.saveConfig("config/config.json", ui.settings) end
		if isPreGameState then removeMonitorWidget() end
	end)
	ObserveAfter("PlayerPuppet", "OnWorkspotFinishedEvent", function(this, evt);
		shouldForceMinimapMonitorUpdate = true
	end);
	if PlayerPuppet.OnSceneTierChange then
		ObserveAfter("PlayerPuppet", "OnSceneTierChange", function(this, newState)
			isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
			if isPreGameState then removeMonitorWidget() return end
			shouldForceMinimapMonitorUpdate = true
		end)
	else
		ObserveAfter('PlayerVisionModeController', 'OnRestrictedSceneChanged', function(self, value)
			isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
			if isPreGameState then removeMonitorWidget() return end
			shouldForceMinimapMonitorUpdate = true
		end)
	end
	ObserveBefore('inkISystemRequestsHandler', 'RequestSaveUserSettings', function(this)
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if not isPreGameState then return end
		local lastlanguageSelected = ui.settings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if ui.settings.lastLanguageSelected ~= lastlanguageSelected then ui.config.saveConfig("config/config.json", ui.settings) setupNativeSettings(true) end
	end)

	ObserveAfter("MinimapContainerController", "OnInitialize", function(this)
		lastMinimapContainerController = this;
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		local parent = this.timeDisplayWidget.widget
		if parent then parent = parent.parentWidget end
		removeMonitorWidget(parent)
		lastShowWidget = nil lastIsLooting = nil
	end)
	ObserveBefore("MinimapContainerController", "OnUnitialize", function(this)
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		local parent = this.timeDisplayWidget.widget
		if parent then parent = parent.parentWidget end
		removeMonitorWidget(parent)
		lastShowWidget = nil lastIsLooting = nil
	end)
	Observe("MinimapContainerController", "OnPlayerAttach", function(this)
		lastMinimapContainerController = this;
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		local parent = this.timeDisplayWidget.widget
		if parent then parent = parent.parentWidget end
		removeMonitorWidget(parent)
		lastShowWidget = nil lastIsLooting = nil
		if isPreGameState then return end
		if not ui.settings.showDebugMonitorWindow then return end
		addMonitorWidgetToMinimap()
	end)
	Observe("MinimapContainerController", "OnPSMCombatChanged", function(this)
		lastMinimapContainerController = this;
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if isPreGameState then
			local parent = this.timeDisplayWidget.widget
			if parent then parent = parent.parentWidget end
			removeMonitorWidget(parent)
			return
		end
		if not ui.settings.showDebugMonitorWindow then return end
		addMonitorWidgetToMinimap()
	end)
	Observe("MinimapContainerController", "OnLocationUpdated", function(this)
		lastMinimapContainerController = this;
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if isPreGameState then
			local parent = this.timeDisplayWidget.widget
			if parent then parent = parent.parentWidget end
			removeMonitorWidget(parent)
			return
		end
		if not ui.settings.showDebugMonitorWindow then return end
		addMonitorWidgetToMinimap()
	end)

	ObserveAfter("SettingsSelectorController", "OnInitialize", function(this)
		if not nativeSettings.fromMods then return end
		local burstTriggerCooldownTime = nativeSettingsOptions.burstTriggerCooldownTime
		if not burstTriggerCooldownTime then return end
		local ctl = burstTriggerCooldownTime.controller
		if not ctl then return end
		if not IsDefined(ctl) then return end
		if not ctl.ValueText.widget then return end;
		local newText = intToMinSecStr(ctl.newValue);
		if not newText then return end;
		inkTextRef.SetText(ctl.ValueText, newText);
	end)
	local n_SettingsSelectorControllerInt = n"SettingsSelectorControllerInt"
	ObserveAfter("SettingsSelectorControllerInt", "Refresh", function(this)
		if not nativeSettings.fromMods then return end
		local burstTriggerCooldownTime = nativeSettingsOptions.burstTriggerCooldownTime
		if not burstTriggerCooldownTime then return end
		if not this:IsA(n_SettingsSelectorControllerInt) then return end;
		local ctl = burstTriggerCooldownTime.controller
		if not ctl then return end
		if not IsDefined(ctl) then return end
		if not isSameInstance(this, ctl) then return end
		local newText = intToMinSecStr(ctl.newValue);
		if not newText then return end;
		inkTextRef.SetText(ctl.ValueText, newText);
	end)
	local lastNsInitTime = 0
	ObserveBefore("SettingsMainGameController", "OnInitialize", function (this)
		if not nativeSettings then return end
		if not nativeSettings.fromMods then return end
		lastNsInitTime = os.clock() + 1
	end)
	ObserveAfter("SettingsMainGameController", "PopulateHints", function (this)
		if lastNsInitTime < os.clock() then return end
		lastNsInitTime = 0
		local bhc = this.buttonHintsController
		if not IsDefined(bhc) then return end
		if bhc.horizontalHolder:GetNumChildren() < 2 then return end
		setupNativeSettings(true)
	end)
	ObserveAfter('SettingsMainGameController', 'OnUninitialize', function (this)
		setupNativeSettings(true)
	end)

	local shouldResetSettingsPanel, shouldReloadMenu, shouldRestoreDefaultSettings
	ObserveBefore("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		shouldRestoreDefaultSettings = false
		if not nativeSettings then return end
		if not nativeSettings.fromMods then return end
		if type(ui.defaultSettings) ~= 'table' then return end

		local currentOption = nativeSettings.data[nativeSettings.currentTab]
		if not currentOption then return end
		if currentOption.isRedMod then return end
		if currentOption.path ~= "AutoLoot" then return end

		shouldRestoreDefaultSettings = true
		setupNativeSettings(true, true)
	end)
	ObserveAfter("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		if not shouldRestoreDefaultSettings then return end
		shouldRestoreDefaultSettings = false
		setupNativeSettings(true)
	end)

	isInitialized = true
	return true
end

function ui.onShutdown()
	if not Game then return end
	if not GetPlayer() then return end
	removeMonitorWidget()
end

function setupNativeSettings(forceNew, showAll)
	isUsingNativeSettings = false
	nativeSettings = GetMod("nativeSettings")
	if not nativeSettings then return end

	ui.nativeSettings = nativeSettings
	if type(uiStrings) ~= 'table' then return end

	local modPath = "/AutoLoot"

	nativeSettingsSubcategoryPaths = {general_settings = modPath.."/general_settings", monitor_settings = modPath.."/monitor_settings"}

	local nativeSettingsDisplayName = uiStrings.nuiUiStrings.settings.windowTitle
	if forceNew and nativeSettings.pathExists(modPath) then
		if type(nativeSettingsSubcategoryPaths) == 'table' then
			for _, path in pairs(nativeSettingsSubcategoryPaths) do
				nativeSettings.removeSubcategory(path)
			end
		end
		local path = modPath:gsub("/", "")
		nativeSettings.data[path] = nil
		nativeSettingsIgnoreAction = false
	end

	isUsingNativeSettings = true
	if not nativeSettings.fromMods then return end
	if not nativeSettings.pathExists(modPath) then nativeSettings.addTab(modPath, uiStrings.nuiUiStrings.settings.windowTitle or "AutoLoot") end
	if nativeSettings.pathExists(modPath) then isUsingNativeSettings = true else isUsingNativeSettings = false return end

	local buttonTitle, buttonTooltips = '', ''
	local buttonsPath = nativeSettingsSubcategoryPaths.general_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.settings.general_settings or "General settings:")

	buttonTitle = uiStrings.nuiUiStrings.settings.range.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.range.tooltips
	nativeSettingsOptions.range = nativeSettings.addRangeInt(buttonsPath, buttonTitle, buttonTooltips, 1, 100, 1, ui.settings.range, ui.defaultSettings.range, function(newValue)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		ui.settings.range = newValue
		ui.config.saveConfig("config/config.json", ui.settings)
	end)

	buttonTitle = uiStrings.nuiUiStrings.settings.useDefaultActionKey.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.useDefaultActionKey.tooltips
	nativeSettingsOptions.useDefaultActionKey = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.useDefaultActionKey, ui.defaultSettings.useDefaultActionKey, function(newState)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = ui.settings.useDefaultActionKey ~= newState
		ui.settings.useDefaultActionKey = newState
		if isStateChanged then ui.config.saveConfig("config/config.json", ui.settings) end
	end)

	buttonTitle = uiStrings.nuiUiStrings.settings.enableTakedownLoot.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.enableTakedownLoot.tooltips
	nativeSettingsOptions.enableTakedownLoot = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.enableTakedownLoot, ui.defaultSettings.enableTakedownLoot, function(newState)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = ui.settings.enableTakedownLoot ~= newState
		ui.settings.enableTakedownLoot = newState
		if isStateChanged then ui.config.saveConfig("config/config.json", ui.settings) end
	end)

	buttonTitle = uiStrings.nuiUiStrings.settings.enableBurstTrigger.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.enableBurstTrigger.tooltips
	nativeSettingsOptions.enableBurstTrigger = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.enableBurstTrigger, ui.defaultSettings.enableTakedownLoot, function(newState)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = ui.settings.enableBurstTrigger ~= newState
		ui.settings.enableBurstTrigger = newState
		if isStateChanged then ui.config.saveConfig("config/config.json", ui.settings) end
	end)

	buttonTitle = uiStrings.nuiUiStrings.settings.burstTriggerCooldownTime.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.burstTriggerCooldownTime.tooltips

	local step, maxVal, defaultVal = 15, 420, ui.defaultSettings.burstTriggerCooldownTime
	if type(ui.uiBurstParams) == 'table' then
		step = ui.uiBurstParams[1] or step
		defaultVal = ui.uiBurstParams[2] or defaultVal
		maxVal = ui.uiBurstParams[3] or maxVal
	end

	local minVal = step
	nativeSettingsOptions.burstTriggerCooldownTime = nativeSettings.addRangeInt(buttonsPath, buttonTitle, buttonTooltips, minVal, maxVal, step, ui.settings.burstTriggerCooldownTime, defaultVal, function(newValue)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		ui.settings.burstTriggerCooldownTime = newValue
		ui.config.saveConfig("config/config.json", ui.settings)
	end)

	buttonsPath = nativeSettingsSubcategoryPaths.monitor_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.settings.monitor_settings or "Looting Monitor settings:")

	buttonTitle = uiStrings.nuiUiStrings.settings.showDebugMonitorWindow.title
	buttonTooltips = uiStrings.nuiUiStrings.settings.showDebugMonitorWindow.tooltips
	nativeSettingsOptions.showDebugMonitorWindow = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.showDebugMonitorWindow, ui.defaultSettings.showDebugMonitorWindow, function(newState)
		nativeSettingsPlaySounds = false
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = ui.settings.showDebugMonitorWindow ~= newState
		ui.settings.showDebugMonitorWindow = newState
		if isStateChanged then
			lastShowWidget = nil lastIsLooting = nil
			if ui.settings.showDebugMonitorWindow then addMonitorWidgetToMinimap() else removeMonitorWidget() end
			ui.config.saveConfig("config/config.json", ui.settings)
			ui.payload = function() setupNativeSettings(true) end
		end
	end)

	if showAll or ui.settings.showDebugMonitorWindow then
		buttonTitle = uiStrings.nuiUiStrings.settings.monitorType.title
		buttonTooltips = uiStrings.nuiUiStrings.settings.monitorType.tooltips
		local choices = uiStrings.nuiUiStrings.settings.monitorType.choices
		nativeSettingsOptions.monitorType = nativeSettings.addSelectorString(buttonsPath, buttonTitle, buttonTooltips, choices, ui.settings.monitorType + 1, ui.defaultSettings.monitorType + 1, function(newValue)
			nativeSettingsPlaySounds = false
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			newValue = newValue - 1
			local isStateChanged = ui.settings.monitorType ~= newValue
			ui.settings.monitorType = newValue
			if isStateChanged then
				lastShowWidget = nil lastIsLooting = nil
				ui.config.saveConfig("config/config.json", ui.settings)
			end
		end)

		buttonTitle = uiStrings.nuiUiStrings.settings.showMonitorWindowOnlyWhenTriggerActive.title
		buttonTooltips = uiStrings.nuiUiStrings.settings.showMonitorWindowOnlyWhenTriggerActive.tooltips
		nativeSettingsOptions.showMonitorWindowOnlyWhenTriggerActive = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.showMonitorWindowOnlyWhenTriggerActive, ui.defaultSettings.showMonitorWindowOnlyWhenTriggerActive, function(newState)
			nativeSettingsPlaySounds = false
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = ui.settings.showMonitorWindowOnlyWhenTriggerActive ~= newState
			ui.settings.showMonitorWindowOnlyWhenTriggerActive = newState
			if isStateChanged then
				lastShowWidget = nil lastIsLooting = nil
				ui.config.saveConfig("config/config.json", ui.settings)
			end
		end)

		buttonTitle = uiStrings.nuiUiStrings.settings.autohideMonitorWindow.title
		buttonTooltips = uiStrings.nuiUiStrings.settings.autohideMonitorWindow.tooltips
		nativeSettingsOptions.autohideMonitorWindow = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, ui.settings.autohideMonitorWindow, ui.defaultSettings.autohideMonitorWindow, function(newState)
			nativeSettingsPlaySounds = false
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = ui.settings.autohideMonitorWindow ~= newState
			ui.settings.autohideMonitorWindow = newState
			if isStateChanged then
				lastShowWidget = nil lastIsLooting = nil
				ui.config.saveConfig("config/config.json", ui.settings)
			end
		end)
	end
end

local minimapMonitorWidget = {}
local indicator = {last = 0, max = 4, chars = {'   ', '.  ', '.. ', '...'}}
local prevTickTime = 0

local mathCeil = math.ceil
function createMinimapMonitor(skipPreCheck)
	if not skipPreCheck then
		if minimapMonitorWidget.widget and IsDefined(minimapMonitorWidget.widget) then return end
		if not lastMinimapContainerController then return end
		if not IsDefined(lastMinimapContainerController) then return end
	end

	local fontSize = 26
	local topWidget = inkFlex.new()
	topWidget:SetVisible(false)
	topWidget:SetName('minimapAutolootMonitor'); CName.add('minimapAutolootMonitor')
	local margin = inkMargin.new({left = -330, top = -19, right = 0, bottom = 0})
	topWidget:SetMargin(margin)

	label = inkText.new();
	label:SetName('minimapAutolootMonitorLabel'); CName.add('minimapAutolootMonitorLabel')
	label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily');
	label:SetFontStyle('Regular');
	label:SetFontSize(fontSize);
	label:SetStyle(ResRef.FromName("base\\gameplay\\gui\\fullscreen\\fullscreen_main_colors.inkstyle"));
	label:BindProperty(tintColor, MainColorsMediumBlue)
	label:BindProperty(fontStyle, MainColorsBodyFontWeight);
	label:SetAnchor(inkEAnchor.CenterLeft);
	label:SetAnchorPoint(Vector2.new({X = 0, Y = 0.5}))
	label:SetVerticalAlignment(textVerticalAlignment.Center)
	label:SetText("Idle.");
	label.fitToContent = false
	label:SetMargin(mathCeil(fontSize*0.5), 0, 0, 0)
	label:Reparent(topWidget, -1)

	return {widget = topWidget, label = label}
end

function addMonitorWidgetToMinimap()
	if not lastMinimapContainerController then return end
	if not IsDefined(lastMinimapContainerController) then return end
	local parent = lastMinimapContainerController.timeDisplayWidget.widget
	if not parent then return end
	parent = parent.parentWidget
	if not parent then return end
	if isPreGameState then removeMonitorWidget(parent) return end

	local lookedWidget = parent:GetWidget("minimapAutolootMonitor")
	if lookedWidget and lookedWidget.name.value == "minimapAutolootMonitor" then
		if isSameInstance(lookedWidget, minimapMonitorWidget.widget) then return end
		parent:RemoveChild(lookedWidget)
		minimapMonitorWidget = {}
	end

	if (not minimapMonitorWidget.widget) or (not IsDefined(minimapMonitorWidget.widget)) then minimapMonitorWidget = createMinimapMonitor(true) end
	if not minimapMonitorWidget.widget then return end

	indicator.last = 1
	minimapMonitorWidget.widget:Reparent(parent, -1)
end

function removeMonitorWidget(parent)
	if minimapMonitorWidget.widget and IsDefined(minimapMonitorWidget.widget) then
		parent = parent or minimapMonitorWidget.widget.parentWidget
		if parent then parent:RemoveChild(minimapMonitorWidget.widget) end
		minimapMonitorWidget = {}
		indicator.last = 1
		return
	end

	if not lastMinimapContainerController then minimapMonitorWidget = {} indicator.last = 1 return end
	if not IsDefined(lastMinimapContainerController) then minimapMonitorWidget = {} indicator.last = 1 return end
	pcall(function() parent = parent or lastMinimapContainerController.timeDisplayWidget.widget.parentWidget end)
	if not parent then minimapMonitorWidget = {} indicator.last = 1 return end
	local lookedWidget = parent:GetWidget("minimapAutolootMonitor")
	if lookedWidget and lookedWidget.name.value == "minimapAutolootMonitor" then parent:RemoveChild(lookedWidget) end
	minimapMonitorWidget = {}
	indicator.last = 1
end

function ui.hideMinimapMonitorWidget()
	if isPreGameState then return end
	if not minimapMonitorWidget.widget then return end
	if not minimapMonitorWidget.widget.isVisible then return end
	minimapMonitorWidget.widget:SetVisible(false)
end

local chr = indicator.chars[1]
function ui.updateMinimapMonitorWidgetText(showWidget, isLooting, force)
	if isPreGameState then return end
	if not minimapMonitorWidget.widget then return end
	if not IsDefined(minimapMonitorWidget.widget) then return end
	if not showWidget then minimapMonitorWidget.widget:SetVisible(false) return end

	if shouldForceMinimapMonitorUpdate then force = true shouldForceMinimapMonitorUpdate = false end
	local isUpdate = force or lastShowWidget ~= showWidget or lastIsLooting ~= isLooting
	lastShowWidget = showWidget
	lastIsLooting = isLooting
	if (not isUpdate) and (not isLooting) then return end

	local labelText = ""
	if isLooting then
		labelText = uiStrings.nuiUiStrings.monitor.lootingStr or "Looting "
		if isUpdate then
			if minimapMonitorWidget.setIsLooting then minimapMonitorWidget.setIsLooting(isLooting) end
		end
		if prevTickTime ~= ui.logic.lastLootCompletedTime then
			prevTickTime = ui.logic.lastLootCompletedTime
			indicator.last = indicator.last + 1
			if indicator.last > indicator.max then indicator.last = 1 end
			chr = indicator.chars[indicator.last]
		end
		labelText = labelText..chr
	else
		labelText = uiStrings.nuiUiStrings.monitor.idleStr or "Idle."
		if minimapMonitorWidget.setIsLooting then minimapMonitorWidget.setIsLooting(isLooting) end
		indicator.last = 1
	end

	minimapMonitorWidget.label:SetText(labelText)
	minimapMonitorWidget.widget:SetVisible(true)
end

local mathFloor = math.floor
local mathMax = math.max
local mathMin = math.min
local stringFormat = string.format
function intToTimeStr(seconds)
	local hours = mathFloor(seconds / 3600)
	local minutes = mathFloor((seconds % 3600) / 60)
	local secs = seconds % 60
	return stringFormat("%02d:%02d:%02d", hours, minutes, secs)
end
function intToMinSecStr(seconds)
	if type(seconds) ~= 'number' then return end;
	local minutes = mathFloor((seconds % 3600) / 60)
	local secs = seconds % 60
	return stringFormat("%02d:%02d", minutes, secs)
end

ui.shouldInitWindow = false
local shouldApplyStyle = false
local leftSideWidth, rightSideWidth = 200, 100
local minWindowWidth = leftSideWidth + rightSideWidth
local rangeButtonWidth = mathFloor(rightSideWidth * 0.8)
local leftMargin = 8
local step = 15
local maxVal = 420
local minVal = step
local halfStep = step * 0.5

local rangeSliderName = "##"..ui.modName.."range_slider"
local burstTimeLeftName = "##"..ui.modName.."burstTimeLeft"
local burstTimeRightName = "##"..ui.modName.."burstTimeRight"
local burstTimeName = "##"..ui.modName.."burstTime"
local mainViewTableName = "##"..ui.modName.."mainViewTable"
local timeCounterWidth = 41
local timeCounter = {width = 41, lastVal = 0, lastStr = "00:00"}
local footer = ui.modName..' '..ui.modVer
local isFirstRun = true


function initWindow(autoLoot)
	ui.shouldInitWindow = false
	shouldApplyStyle = type(autoLoot.CPS) == 'table'
	local x, y = ImGui.CalcTextSize('abcdefghijklmnoprstuwxyz /_.,ABCDEFGHIJKLMNOPRSTUWXYZ')
	local widthFactor = 17
	leftSideWidth = mathFloor(y * widthFactor)
	rightSideWidth = mathFloor(y * widthFactor / 1.3)
	minWindowWidth = leftSideWidth + rightSideWidth
	rangeButtonWidth = mathFloor(leftSideWidth * 0.85)
	leftMargin = ImGui.GetTextLineHeight() * 0.5
	timeCounter.width = ImGui.CalcTextSize("_00:00_")
	if type(autoLoot.uiBurstParams) == 'table' then
		step = autoLoot.uiBurstParams[1] or step
		maxVal = autoLoot.uiBurstParams[3] or maxVal
		minVal = step
		halfStep = step * 0.5
	end
	footer = ui.modName..' '..ui.modVer
end

function ui.draw(autoLoot)
	if ui.shouldInitWindow then initWindow(autoLoot) end
    if shouldApplyStyle then autoLoot.CPS.setThemeBegin() end
	ImGui.SetNextWindowSize(minWindowWidth , -1)
	if ImGui.Begin(uiStrings.cetUiStrings.settings.windowTitle or "AutoLoot", ImGuiWindowFlags.AlwaysAutoResize) then
		if ImGui.IsWindowCollapsed() then
			if shouldApplyStyle then autoLoot.CPS.setThemeEnd() end
			ImGui.End()
			return
		end

		if not ui.isInitialized then
			ImGui.Spacing()
			ImGui.TextWrapped(uiStrings.cetUiStrings.warnings.modDisabled)
			ImGui.Spacing()
			ImGui.Separator()
			ImGui.Text(ui.modName..' '..ui.modVer..'            ')
			if shouldApplyStyle then autoLoot.CPS.setThemeEnd() end
			ImGui.End()
			return
		end

		pcall(function()
			ImGui.Separator()

			local isTable = ImGui.BeginTable(mainViewTableName, 2)
			if isTable then
				if isFirstRun then ImGui.TableSetupColumn(mainViewTableName, 0, leftSideWidth) isFirstRun = false end
				ImGui.TableNextColumn()
			end

			ImGui.TextWrapped(uiStrings.cetUiStrings.settings.general_settings)
			ImGui.Spacing()

			local tooltips = uiStrings.cetUiStrings.settings.tooltipsHeader

			ImGui.TextWrapped(uiStrings.cetUiStrings.settings.range.title)
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.range.tooltips
			end
			if type(autoLoot.settings.range) ~= 'number' then autoLoot.settings.range = 20 end
			ImGui.SetNextItemWidth(rangeButtonWidth)
			autoLoot.settings.range, changed = ImGui.SliderInt(rangeSliderName, autoLoot.settings.range, 1, 100)
			if changed then
				if isUsingNativeSettings and nativeSettingsOptions.range then
					nativeSettingsIgnoreNextAction = true
					nativeSettingsPlaySounds = true
					nativeSettings.setOption(nativeSettingsOptions.range, autoLoot.settings.range)
				end
				autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
			end
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.range.tooltips
			end

			ImGui.Spacing()

			if type(autoLoot.settings.useDefaultActionKey) ~= 'boolean' then autoLoot.settings.useDefaultActionKey = false end
			autoLoot.settings.useDefaultActionKey, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.useDefaultActionKey.title, autoLoot.settings.useDefaultActionKey)
			if changed then
				if isUsingNativeSettings and nativeSettingsOptions.useDefaultActionKey then
					nativeSettingsIgnoreNextAction = true
					nativeSettingsPlaySounds = true
					nativeSettings.setOption(nativeSettingsOptions.useDefaultActionKey, autoLoot.settings.useDefaultActionKey)
				end
				autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
			end
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.useDefaultActionKey.tooltips
			end
			ImGui.Spacing()

			if type(autoLoot.settings.enableTakedownLoot) ~= 'boolean' then autoLoot.settings.enableTakedownLoot = false end
			autoLoot.settings.enableTakedownLoot, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.enableTakedownLoot.title, autoLoot.settings.enableTakedownLoot)
			if changed then
				if isUsingNativeSettings and nativeSettingsOptions.enableTakedownLoot then
					nativeSettingsIgnoreNextAction = true
					nativeSettingsPlaySounds = true
					nativeSettings.setOption(nativeSettingsOptions.enableTakedownLoot, autoLoot.settings.enableTakedownLoot)
				end
				autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
			end
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.enableTakedownLoot.tooltips
			end
			ImGui.Spacing()

			if type(autoLoot.settings.enableBurstTrigger) ~= 'boolean' then autoLoot.settings.enableBurstTrigger = false end
			autoLoot.settings.enableBurstTrigger, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.enableBurstTrigger.title, autoLoot.settings.enableBurstTrigger)
			if changed then
				if isUsingNativeSettings and nativeSettingsOptions.enableBurstTrigger then
					nativeSettingsIgnoreNextAction = true
					nativeSettingsPlaySounds = true
					nativeSettings.setOption(nativeSettingsOptions.enableBurstTrigger, autoLoot.settings.enableBurstTrigger)
				end
				autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
				if (not autoLoot.settings.enableBurstTrigger) and autoLoot.isBurst then GetPlayer():RemoveCooldown("autoloot_burst_trigger_cooldown") end
			end
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.enableBurstTrigger.tooltips
			end
			ImGui.Spacing()

			if type(autoLoot.settings.burstTriggerCooldownTime) == 'number' then
				local val = autoLoot.settings.burstTriggerCooldownTime
				local changed = false
				local isEnabled = autoLoot.settings.enableBurstTrigger
				if not isEnabled then ImGui.BeginDisabled() end

				ImGui.TextWrapped(uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.title)
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.tooltips
				end
				if ImGui.ArrowButton(burstTimeLeftName, ImGuiDir.Left) then
					if val > minVal then
						val = mathMax(val - step, minVal)
						val = mathFloor((val + halfStep) / step) * step
						changed = val ~= autoLoot.settings.burstTriggerCooldownTime
					end
				end
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.tooltips
				end
				ImGui.SameLine()
				if val ~= timeCounter.lastVal then
					timeCounter.lastVal = val
					timeCounter.lastStr = intToMinSecStr(val)
				end
				ImGui.SetNextItemWidth(timeCounter.width)
				ImGui.InputText(burstTimeName, timeCounter.lastStr, 5, ImGuiInputTextFlags.ReadOnly)
					if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.tooltips
				end
				ImGui.SameLine()
				if ImGui.ArrowButton(burstTimeRightName, ImGuiDir.Right) then
					if val < maxVal then
						val = mathMin(val + step, maxVal)
						val = mathFloor((val + halfStep) / step) * step
						changed = val ~= autoLoot.settings.burstTriggerCooldownTime
					end
				end
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.tooltips
				end
				if changed then
					autoLoot.settings.burstTriggerCooldownTime = val
					if isUsingNativeSettings and nativeSettingsOptions.burstTriggerCooldownTime then
						nativeSettingsIgnoreNextAction = true
						nativeSettingsPlaySounds = true
						nativeSettings.setOption(nativeSettingsOptions.burstTriggerCooldownTime, autoLoot.settings.burstTriggerCooldownTime)
					end
					autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
				end
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.burstTriggerCooldownTime.tooltips
				end
				if not isEnabled then ImGui.EndDisabled() end
				ImGui.Spacing()
			end

			ImGui.Separator()
			ImGui.TextWrapped(uiStrings.cetUiStrings.settings.monitor_settings)
			ImGui.Spacing()

			if type(autoLoot.settings.showDebugMonitorWindow) ~= 'boolean' then autoLoot.settings.showDebugMonitorWindow = false end
			autoLoot.settings.showDebugMonitorWindow, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.showDebugMonitorWindow.title, autoLoot.settings.showDebugMonitorWindow)
			if changed then
				lastShowWidget = nil lastIsLooting = nil
				if isUsingNativeSettings and nativeSettingsOptions.showDebugMonitorWindow then
					nativeSettingsIgnoreNextAction = true
					nativeSettingsPlaySounds = true
					setupNativeSettings(true)
				end
				if autoLoot.settings.showDebugMonitorWindow then addMonitorWidgetToMinimap() else removeMonitorWidget() end
				autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
			end
			if ImGui.IsItemHovered() then
				tooltips = uiStrings.cetUiStrings.settings.showDebugMonitorWindow.tooltips
			end
			ImGui.Spacing()

			if autoLoot.settings.showDebugMonitorWindow then
				if type(autoLoot.settings.monitorType) ~= 'number' then autoLoot.settings.monitorType = 0 end
				local choices = uiStrings.cetUiStrings.settings.monitorType.choices
				if type(choices) == 'table' and #choices > 0 then
					ImGui.Text(uiStrings.cetUiStrings.settings.monitorType.title)
					if ImGui.IsItemHovered() then
						tooltips = uiStrings.cetUiStrings.settings.monitorType.tooltips
					end
					ImGui.SetNextItemWidth(rangeButtonWidth)
					local oldValue = ui.settings.monitorType
					local newValue, isClicked = ImGui.Combo('##monitorType', oldValue, choices, #choices)
					if newValue ~= oldValue then
						lastShowWidget = nil lastIsLooting = nil
						autoLoot.settings.monitorType = newValue
						if isUsingNativeSettings and nativeSettingsOptions.monitorType then
							nativeSettingsIgnoreNextAction = true
							nativeSettingsPlaySounds = true
							nativeSettings.setOption(nativeSettingsOptions.monitorType, autoLoot.settings.monitorType + 1)
						end
						autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
					end
					if ImGui.IsItemHovered() then
						tooltips = uiStrings.cetUiStrings.settings.monitorType.tooltips
					end
					ImGui.Spacing()
				end

				if type(autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive) ~= 'boolean' then autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive = false end
				autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.showMonitorWindowOnlyWhenTriggerActive.title, autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive)
				if changed then
					lastShowWidget = nil lastIsLooting = nil
					if isUsingNativeSettings and nativeSettingsOptions.showMonitorWindowOnlyWhenTriggerActive then
						nativeSettingsIgnoreNextAction = true
						nativeSettingsPlaySounds = true
						nativeSettings.setOption(nativeSettingsOptions.showMonitorWindowOnlyWhenTriggerActive, autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive)
					end
					autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
				end
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.showMonitorWindowOnlyWhenTriggerActive.tooltips
				end
				ImGui.Spacing()

				if type(autoLoot.settings.autohideMonitorWindow) ~= 'boolean' then autoLoot.settings.autohideMonitorWindow = false end
				autoLoot.settings.autohideMonitorWindow, changed = ImGui.Checkbox(uiStrings.cetUiStrings.settings.autohideMonitorWindow.title, autoLoot.settings.autohideMonitorWindow)
				if changed then
					lastShowWidget = nil lastIsLooting = nil
					if isUsingNativeSettings and nativeSettingsOptions.autohideMonitorWindow then
						nativeSettingsIgnoreNextAction = true
						nativeSettingsPlaySounds = true
						nativeSettings.setOption(nativeSettingsOptions.autohideMonitorWindow, autoLoot.settings.autohideMonitorWindow)
					end
					autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
				end
				if ImGui.IsItemHovered() then
					tooltips = uiStrings.cetUiStrings.settings.autohideMonitorWindow.tooltips
				end
				ImGui.Spacing()
			end

			if isTable then
				ImGui.TableNextColumn()
				ImGui.Dummy(rightSideWidth, 0)
				if tooltips then
					if shouldApplyStyle then autoLoot.CPS.setThemeEnd() end
					ImGui.Indent(leftMargin)
					ImGui.PushStyleColor(ImGuiCol.Text, 0xffc0c8cf)
					ImGui.TextWrapped(tooltips)
					ImGui.PopStyleColor()
					ImGui.Unindent(leftMargin)
					if shouldApplyStyle then autoLoot.CPS.setThemeBegin() end
				end
			end
			if isTable then ImGui.EndTable() end

			ImGui.Separator()
			ImGui.TextWrapped(footer)
		end)
	end
	if shouldApplyStyle then autoLoot.CPS.setThemeEnd() end
    ImGui.End()
end

return ui