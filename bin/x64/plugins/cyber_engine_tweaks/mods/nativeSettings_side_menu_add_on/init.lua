-- Jun 5, 2025 by anygoodname
modVer='v1.5.1'
modName='Native Settings UI Side Menu Add-on'
modAuthorName='anygoodname'

--[[
	Credits: for game research and code snippets: (c)psiberx, (c)keanuWheeze
]]---

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
-- Translation support is described in the file: "..\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\nativeSettings_side_menu_add_on\language\Readme.txt"

local Ref = require("Ref")
if not Ref then return end

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

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

if cetVer < 1.26 then
	print(modName, modVer, "is not compatible with this game version. This module is disabled now.")
	return
end

local tableInsert = table.insert
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
			tableInsert(output, entry)
		end
	end
	return output
end

local userSettings = {filename = 'mod_user_settings.json', enableSidePanel = true, enableModSorting = true, textOverflowPolicy = 0, autoScrollSelectedOnly = false, hideCheckMarkIcon = false}
local deferredSettingsChange = nil
local nativeSettings, isUsingNativeSettings, nativeSettingsIgnoreAction = nil, false, false
local nativeSettingsOptions = {}
local nativeSettingsSubcategoryPaths
local n, t
local isSameInstance
local n_tintColor = "tintColor"
local n_MainColorsBlue = "MainColors.Blue"
local n_MainColorsDarkRed = "MainColors.DarkRed"
local n_MainColorsFullscreenPrimaryBackgroundDarkest = "MainColors.Fullscreen_PrimaryBackgroundDarkest"

local atlas_shapes_sync_ResRef
local fullscreen_main_colors_ResRef
local atlas_scanner_ResRef
local mappin_icons_ResRef

local menu = {
	left = {topWidget = nil, topWidgetName = "extraButtons", topWidgetPath = {'wrapper', 'extraButtons'}},
	mods = {topWidget = nil, topWidgetName = "modList", topWidgetPath = {'wrapper', 'extraButtons', 'modList'}},
	middle = {topWidget = nil, topWidgetName = "MainScrollingArea", topWidgetPath = {'wrapper', 'wrapper', 'MainScrollingArea'}},
}

local isModDisabled = false

local nativeUI = {}
nativeUI.isSelectionList = false
nativeUI.lastSelectionListReturn = {}
nativeUI.lastSelectionList = {}
nativeUI.activeInstances = {}

local lastGameCursorController = nil
local lastSettingsMainGameController = nil

local buttonDelay = 0.02
local delayedButtonActionCooldown = 0.15
local nextButtonActionAllowed = 0
local isDelayedButtonActionAllowed = true

local isLeftToRightOrder = true

function saveUserSettings()
	local jString = dumpTableToJson(userSettings, true, true)
	if not jString then return end
	local file = io.open(userSettings.filename, "w")
	if not file then return end
	file:write(jString)
	file:close()
end

local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local mathAbs = math.abs
local stringRep = string.rep
local stringLen = string.len

local function isStringValid(input)
	if type(input) ~= 'string' then return end
	if stringLen(input) < 1 then return end
	return true
end

function loadUserSettings()
	local file = io.open(userSettings.filename, "r")
	if not file then return end
	local jString = file:read("*a")
	file:close()
	if type(jString) ~= 'string' then return end
	local decodeResult, settings = pcall(function() return json.decode(jString) end)
	if not decodeResult then return end
	if type(settings) ~= 'table' then return end
	if type(settings.enableSidePanel) == 'boolean' then userSettings.enableSidePanel = settings.enableSidePanel end
	if type(settings.enableModSorting) == 'boolean' then userSettings.enableModSorting = settings.enableModSorting end
	if type(settings.textOverflowPolicy) == 'number' and settings.textOverflowPolicy >= 0 then userSettings.textOverflowPolicy = mathMin(mathFloor(settings.textOverflowPolicy), 2) end
	if type(settings.autoScrollSelectedOnly) == 'boolean' then userSettings.autoScrollSelectedOnly = settings.autoScrollSelectedOnly end
	if type(settings.hideCheckMarkIcon) == 'boolean' then userSettings.hideCheckMarkIcon = settings.hideCheckMarkIcon end
	if type(settings.lastLanguageSelected) == 'string' then userSettings.lastLanguageSelected = settings.lastLanguageSelected else userSettings.lastLanguageSelected = "en-us" end
	return true
end

local isInitialized = false
local cNameNew
registerForEvent("onInit", function()
	if isInitialized then return end

	nativeSettings = GetMod("nativeSettings")
	if not nativeSettings then print(modName, modVer..":", 'As Native Settings mod is not installed, this mod is inactive now.') return end
	print('----------------------------------------------------------------------------')
	print(modName, modVer..":", 'Native Settings UI found, version', nativeSettings.version, 'by (c)keanuWheeze')
	print(modName, modVer..":", 'CET ver:', cetVerStr)

	local isCodewareActive = Codeware and Codeware.Version
	if isCodewareActive then print('Codeware detected, version:', Codeware.Version()) end
	local isArchiveXLActive = ArchiveXL and ArchiveXL.Version
	if isArchiveXLActive then print('Archive XL detected, version:', ArchiveXL.Version()) end
	if not isCodewareActive and not isArchiveXLActive then
		printError(modName, modVer..":", 'Warning: could not find Archive XL or Codeware. The Side Menu will not be displayed.')
	end

	n = CName
	t = TweakDBID
	cNameNew = CName.new
	n_tintColor = n"tintColor"
	n_MainColorsBlue = n"MainColors.Blue"
	n_MainColorsDarkRed = n"MainColors.DarkRed"
	n_MainColorsFullscreenPrimaryBackgroundDarkest = n"MainColors.Fullscreen_PrimaryBackgroundDarkest"
	atlas_shapes_sync_ResRef = ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas')
	fullscreen_main_colors_ResRef = ResRef.FromName("base\\gameplay\\gui\\fullscreen\\fullscreen_main_colors.inkstyle")
	atlas_scanner_ResRef = ResRef.FromName('base\\gameplay\\gui\\widgets\\scanning\\scanner_tooltip\\atlas_scanner.inkatlas')
	mappin_icons_ResRef = ResRef.FromName('base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas')
	isSameInstance = Game['OperatorEqual;IScriptableIScriptable;Bool'] -- (c)keanuWheeze
	widgetDataSupportInit()
	loadUserSettings()
	local lastlanguageSelected = userSettings.lastLanguageSelected
	loadLocalizedStrings(true, true)
	if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
	setupNativeSettings()
	setupObservers()
	isInitialized = true
	print(modName, modVer, "is initialized.")
	print('----------------------------------------------------------------------------')
end)

local nativeUiDefaultUiStrings = {
	nuiUiStrings = {
		exportOrder = {'nativeUiSettingsView'},
		nativeUiSettingsView = {
			exportOrder = {'modDisplayName', 'generalSettingsHeader', 'enableSidePanel', 'enableModSorting', 'textOverflowPolicy', 'autoScrollSelectedOnly', 'hideCheckMarkIcon'},

			modDisplayName = "Native Settings UI Side Menu Add-on",

			generalSettingsHeader = 'General settings:',
			enableSidePanel = {title = "Show Mods Side Panel", tooltips = "Enable/disable vertical mods list on the left side panel."},
			enableModSorting = {title = "Sort Mods", tooltips = "Enable/disable mod lists sorting.\nNote: changes take effect on the next MODS menu visit."},
			textOverflowPolicy = {title = "Long mod names handling method", tooltips = "Choose a method to handle long mod names to fit them on the side panel list.", choices = {"None", "Dotted End", "Ping-Pong Autoscroll"}},
			autoScrollSelectedOnly = {title = "Autoscroll selected item only", tooltips = "Limit long names autoscroll to selected item only."},
			hideCheckMarkIcon = {title = "Hide check mark icon", tooltips = "Hide the leading check mark icon on the side menu list."},
		},
	},
}

local uiStrings = cloneTable(nativeUiDefaultUiStrings)
local tableSort = table.sort
local tableRemove = table.remove
local function getTableTypeWithKeysOrCount(array, sort);
	local count = #array;
	local isOrderedArray = count > 0;
	if isOrderedArray then return false, count end;
	local keys = {};
	for key, value in pairs(array) do tableInsert(keys, key) end;
	if sort then tableSort(keys) end;
	return true, keys;
end;
local function serializeTable(val, level, isCustomOrder, sortIfNoCustomOrderFound)
	local outputStr = ""
	local indentStr = stringRep("\t", level)
	local nextIndentStr = stringRep("\t", level + 1)

	if type(val) == "table" then
		local isTableWithKeys, keysOrCount = getTableTypeWithKeysOrCount(val, not isCustomOrder)
		if not isTableWithKeys then
			outputStr = outputStr .. "[\n"
			for i = 1, #val do
				value = val[i]
				local valueType = type(value)
				if valueType ~= 'table' and valueType ~= 'string' and valueType ~= 'number' and valueType ~= 'boolean' then value = tostring(value) end
				outputStr = outputStr .. nextIndentStr .. serializeTable(value, level + 1, isCustomOrder, sortIfNoCustomOrderFound)
				if i < keysOrCount then outputStr = outputStr .. ",\n" end
			end
			outputStr = outputStr .. "\n" .. indentStr .. "]"
		else
			outputStr = outputStr .. "{\n"
			local comma = false
			local keys = keysOrCount
			if isCustomOrder then
				if type(val.exportOrder) == 'table' and #val.exportOrder > 0 then keys = val.exportOrder else if sortIfNoCustomOrderFound then tableSort(keys) end
				end
			end
			for i, key in ipairs(keys) do
				local value = val[key]
				local valueType = type(value)
				if valueType ~= 'table' and valueType ~= 'string' and valueType ~= 'number' and valueType ~= 'boolean' then value = tostring(value) end
				if comma then outputStr = outputStr .. ",\n" else comma = true end
				outputStr = outputStr .. nextIndentStr .. '"' .. tostring(key) .. '": ' .. serializeTable(value, level + 1, isCustomOrder, sortIfNoCustomOrderFound)
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
function dumpTableToJson(inputTable, isCustomOrder, sortIfNoCustomOrderFound)
    return serializeTable(inputTable, 0, isCustomOrder, sortIfNoCustomOrderFound)
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
	modName = modName,
	modAuthorName = modAuthorName,
	modVer = modVer,
	_2_ = "----------------------------------------",
	translationAuthorName = "Put your name here",
	translationVer = "Put your file verison here",
	_3_ = "----------------------------------------",
}

local stringsFileSet = {nuiUiStrings = 'nuiUiStrings.json'}

local exportTable = {}
exportTable.exportOrder = {'fileHeader', 'uiStrings'}
exportTable.fileHeader = exportedStringsFileHeader
exportTable.uiStrings = nativeUiDefaultUiStrings.nuiUiStrings
pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/nuiUiStrings.json") end

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
				loadedData[tableName] = {fileHeader = fileData.fileHeader, uiStrings = fileData.uiStrings}
				isAnythingLoaded = true
			end
		end
		if isAnythingLoaded then languages[id] = loadedData print(modName, modVer..':', id, 'language files loaded.') end
	end
end

loadAllLanguageFiles()

function quickloadUserSettings()
	local file = io.open(userSettings.filename, "r")
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
		if updateUserSettings and (isModInitialized or forceSettingsUpdate) then userSettings.lastLanguageSelected = lang end
		return lang, true
	end

	local lastLanguageSelected = "en-us"
	if isModInitialized then
		if type(userSettings.lastLanguageSelected) == 'string' then lastLanguageSelected = userSettings.lastLanguageSelected end
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
	uiStrings = cloneTable(nativeUiDefaultUiStrings)

	local newStringsSet = languages[currentUiLanguage]
	if not newStringsSet then return end

	for tableName, newTableData in pairs(newStringsSet) do
		if newTableData and uiStrings[tableName] and type(newTableData.uiStrings) == 'table' then
			local replacedTableData, result = replaceTableEntries(uiStrings[tableName], newTableData.uiStrings, 'string', false)
			if result then uiStrings[tableName] = replacedTableData end
		end
	end

	if nativeUI.updateUiStrings and newStringsSet.nuiUiStrings and newStringsSet.nuiUiStrings.uiStrings then
		local replacedTableData, result = replaceTableEntries(nativeUI.uiStrings, {nuiUiStrings = newStringsSet.nuiUiStrings.uiStrings}, 'string', false)
		if result then nativeUI.updateUiStrings(replacedTableData) end
	end
end

loadLocalizedStrings()
local modPath = "/Native Settings UI Side Menu Add on" -- do not add dash/minus characters here as Native Settings does not tollerate it in paths.
function setupNativeSettings(forceNew, showAll)
	isUsingNativeSettings = false
	nativeSettings = GetMod("nativeSettings")
	nativeUI.nativeSettings = nativeSettings
	if not nativeSettings then return end
	if type(uiStrings) ~= 'table' then return end

	if not nativeSettingsSubcategoryPaths then nativeSettingsSubcategoryPaths = {general_settings = modPath.."/general_settings"} end

	local nativeSettingsDisplayName = uiStrings.nuiUiStrings.nativeUiSettingsView.modDisplayName
	if forceNew and nativeSettings.pathExists(modPath) then
		if type(nativeSettingsSubcategoryPaths) == 'table' then
			for _, path in pairs(nativeSettingsSubcategoryPaths) do
				nativeSettings.removeSubcategory(path)
			end
		end
		local path = modPath:gsub("/", "")
		nativeSettings.data[path] = nil
		nativeSettingsOptions = {}
		nativeSettingsIgnoreNextAction = false
	end

	isUsingNativeSettings = true
	if not nativeSettings.fromMods then return end
	if not nativeSettings.pathExists(modPath) then nativeSettings.addTab(modPath, nativeSettingsDisplayName) end
	if nativeSettings.pathExists(modPath) then isUsingNativeSettings = true else isUsingNativeSettings = false return end

	local buttonTitle, buttonTooltips = '', ''
	local buttonsPath = nativeSettingsSubcategoryPaths.general_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.generalSettingsHeader)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSidePanel.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSidePanel.tooltips
	nativeSettingsOptions.enableSidePanel = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.enableSidePanel, true, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = userSettings.enableSidePanel ~= newState
		userSettings.enableSidePanel = newState
		if isStateChanged then
			if newState then
				if nativeUI.lastSelectionList.isInitialized then
					nativeUI.lastSelectionList.setVisible(true)
				else
					createSidePanelModListWrapper(true)
				end
			else
				if nativeUI.lastSelectionList.isInitialized then
					nativeUI.lastSelectionList.setVisible(false)
				end
			end
			saveUserSettings()
		end
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableModSorting.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableModSorting.tooltips
	nativeSettingsOptions.enableModSorting = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.enableModSorting, true, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = userSettings.enableModSorting ~= newState
		deferredSettingsChange = {enableModSorting = {oldValue = userSettings.enableModSorting, newValue = newState}}
		userSettings.enableModSorting = newState
		if isStateChanged then saveUserSettings() end
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.textOverflowPolicy.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.textOverflowPolicy.tooltips
	local choices = uiStrings.nuiUiStrings.nativeUiSettingsView.textOverflowPolicy.choices
	nativeSettingsOptions.textOverflowPolicy = nativeSettings.addSelectorString(buttonsPath, buttonTitle, buttonTooltips, choices, userSettings.textOverflowPolicy + 1, 1, function(newValue)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		newValue = newValue - 1
		local isStateChanged = userSettings.textOverflowPolicy ~= newValue
		userSettings.textOverflowPolicy = newValue
		if isStateChanged then
			if nativeUI.lastSelectionList.isInitialized then
				nativeUI.lastSelectionList.setTextOverlowPolicyByUserSettings()
			end
			local payload = function() setupNativeSettings(true) end
			queueTask(payload, false, 0.01)
			saveUserSettings()
		end
	end)

	local textOverflowPolicy, isAutoscroll = getTextOverflowPolicyByUserSettings()
	if showAll or isAutoscroll then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.autoScrollSelectedOnly.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.autoScrollSelectedOnly.tooltips
		nativeSettingsOptions.autoScrollSelectedOnly = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.autoScrollSelectedOnly, false, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = userSettings.autoScrollSelectedOnly ~= newState
			userSettings.autoScrollSelectedOnly = newState
			if isStateChanged then
				if nativeUI.lastSelectionList.isInitialized then
					nativeUI.lastSelectionList.setTextOverlowPolicyByUserSettings()
				end
				saveUserSettings()
			end
		end)
	end

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.hideCheckMarkIcon.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.hideCheckMarkIcon.tooltips
	nativeSettingsOptions.hideCheckMarkIcon = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.hideCheckMarkIcon, false, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = userSettings.hideCheckMarkIcon ~= newState
		userSettings.hideCheckMarkIcon = newState
		if isStateChanged then
			createSidePanelModListWrapper(true)
			saveUserSettings()
		end
	end)

end

local osClock = os.clock
local queuedTasks = {isTaskQueued = false, resetQueue = false, lastPayloadId = 0, payloads = {}}
function queueTask(exec, cannotCoincidence, delay, repeatDelay, shouldTerminateOnCompleted)
	if type(exec) ~= 'function' then return nil end
	if type(cannotCoincidence) ~= 'boolean' then cannotCoincidence = false end
	if type(delay) ~= 'number' or delay < 0 then delay = 0.0167 end
	if type(repeatDelay) ~= 'number' or repeatDelay < 0 then repeatDelay = 0 end
	if type(shouldTerminateOnCompleted) ~= 'boolean' then shouldTerminateOnCompleted = true end

	local payload = {}
	local payloadId = queuedTasks.lastPayloadId
	if not payloadId then payloadId = 1 else payloadId = payloadId + 1 end
	payload.payloadId = payloadId
	payload.cannotCoincidence = cannotCoincidence
	payload.trigger = osClock() + delay
	payload.repeatDelay = repeatDelay
	payload.exec = exec
	payload.shouldTerminateOnCompleted = shouldTerminateOnCompleted
	tableInsert(queuedTasks.payloads, payload)
	queuedTasks.lastPayloadId = payloadId
	queuedTasks.isTaskQueued = true
	return payloadId
end
function isQueuedId(id)
	if type(id) ~= 'number' then return end
	if not queuedTasks.isTaskQueued then return end
	for i = #queuedTasks.payloads, 1, -1 do
		if queuedTasks.payloads[i].payloadId == id then return true end
	end
end
function removeQueuedTaskById(id)
	if not queuedTasks.isTaskQueued then return end
	if type(id) ~= 'number' then return end
	for i = #queuedTasks.payloads, 1, -1 do
		if type(queuedTasks.payloads[i]) == 'table' and queuedTasks.payloads[i].payloadId == id then table.remove(queuedTasks.payloads, i) return true end
	end
end
function resetQueuedTasks()
	queuedTasks = {isTaskQueued = false, resetQueue = false, lastPayloadId = 0, payloads = {}}
end
local shouldCleanup, isAnyTaskExecuted
local function runPayloadTaks(queuedTasks, i)
	local payload = queuedTasks.payloads[i]
	if payload and payload.exec then
		if not (payload.cannotCoincidence and isAnyTaskExecuted) then
			local curTime = osClock()
			if curTime > payload.trigger then
				local result = payload.exec()
				if type(result) ~= 'boolean' then result = payload.shouldTerminateOnCompleted end
				if result then
					isAnyTaskExecuted = true
					queuedTasks.payloads[i] = false
					shouldCleanup = true
				else
					local repeatDelay = payload.repeatDelay
					if repeatDelay > 0 then payload.trigger = curTime + repeatDelay end
				end
			end
		end
	else
		queuedTasks.payloads[i] = false
		shouldCleanup = true
	end
end
local executionResult, executionOutputData = nil
local function processTaskQueue()
	if queuedTasks.resetQueue then resetQueuedTasks() return end
	if not queuedTasks.isTaskQueued then return end
	local payloads = queuedTasks.payloads
	if #payloads < 1 then queuedTasks.isTaskQueued = false return end
	shouldCleanup = false
	isAnyTaskExecuted = false
	for i = 1, #payloads do
		if queuedTasks.resetQueue then return end
		executionResult, executionOutputData = pcall(runPayloadTaks, queuedTasks, i)
		if not executionResult then
			printError('Error executing payload', i)
			printError(executionOutputData)
			printError('payload', i, 'aborted.')
			payloads[i] = false
			shouldCleanup = true
		end
	end
	if not shouldCleanup then return end
	for i = #payloads, 1, -1 do
		if payloads[i] == false then tableRemove(queuedTasks.payloads, i) end
	end
	queuedTasks.isTaskQueued = #queuedTasks.payloads > 0
end

registerForEvent('onUpdate', function(delta)
	processTaskQueue()
end)

registerForEvent("onShutdown", function()
	if not Game then return end
	if not GetPlayer then return end
	destroySidePanelModListWrapper()
end)

function getTextOverflowPolicyByUserSettings()
	if userSettings.textOverflowPolicy == 1 then return textOverflowPolicy.DotsEnd end
	if userSettings.textOverflowPolicy == 2 then return textOverflowPolicy.PingPongScroll, true end
	return textOverflowPolicy.None
end

local selectionListNativeUITemplate = {
	title = "Generic List Title",
	selectionListAreaWidget = nil,
	isSelectionList = true,
	isEnabled = true,
	setVisible = function() end,
	isVisible = function() end,
	getScreenPosition = function() end,
	eventCatcher = nil,
	activeTextColor = "MainColors.Red",
	inactiveTextColor = "MainColors.DarkRedRed",
	highlightTextColor = "MainColors.ActiveBlue",
	selectedTextColor = "MainColors.Blue",
	activeTextOpacity = 0.8,
	inactiveTextOpacity = 1,
	listWidth = 800,
	listItemHeight = 84,
	listItemHeightWithSeparator = 84 + 6,
	listSeparatorHeight = 6,
	listTopSeparatorHeight = 4,
	listBottomSeparatorHeight = 4,
	item = {name = "item", title = "item", itemIndex = 0, isListItem = true, isSelected = false, isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = false, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end, setSelected = function() end, setAccepted = function() end, setHovered = function() end},
	items = {},
	itemCount = 0,
	itemsByName = {},
	changeTextOverflowPolicy = function() end,
	getItem = function() end,
	getItemByName = function() end,
	playerUsedPad = false,
	lastSelectedObject = nil,
	lastHoveredItemIndex = 0,
	initialSelectedItemIndex = 0,
	selectedItemIndex = 0,
	selectItem = function() end,
	getSelectedItem = function() end,
	deselectAll = function() end,
	scrollToSelectedItem = function() end,
	moveUp = function() end,
	moveDown = function() end,
	moveLeft = function() end,
	moveRight = function() end,
	getLastSelectedObject = function() end,
	useSelectedItem = function() end,
	useSelectedItemCallback = function() end,
	cleanup = function() end,
	list_separator_line = {name = "list_separator_line", title = "", isEnabled = true, type = "border", widget = nil, marginTop = 2, marginBottom = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end},
}
local inkEAnchorTopLeft
local inkEAnchorLeftFillVerticaly
local inkEAnchorTopRight
local inkEAnchorFill
local inkEAnchorCenterLeft
local inkEAnchorBottomFillHorizontaly
local enumValueToString
local cNameAdd
local n_inkTextWidget = "inkTextWidget"
function createSelectionList(inputItemList, initialSelectedItemIndex, thisList, listWidth, fontSize, isUpperCase)
	nativeUI.isSelectionList = false
	if type(inputItemList) ~= 'table' then return false end
	if #inputItemList < 1 then return false end
	if not IsDefined(menu.mods.scrollVieportArea) then return end
	if not IsDefined(menu.mods.scrollContentArea) then return end

	if type(thisList) ~= 'table' then thisList = cloneTable(selectionListNativeUITemplate) end
	if not thisList then return end

	thisList.parentWidget = menu.mods.scrollContentArea
	thisList.listScrollAreaWidget = menu.mods.scrollVieportArea

	if type(fontSize) ~= 'number' or fontSize < 10 then fontSize = 48 end
	if type(listWidth) == 'number' and listWidth > 10 then thisList.listWidth = listWidth end

	thisList.selectionListAreaWidget = inkVerticalPanelWidget.new()
	thisList.selectionListAreaWidget:SetName('selectionListAreaWidget')
	thisList.selectionListAreaWidget:SetAnchor(inkEAnchorTopLeft)
	thisList.setVisible = function(show) if type(show) ~= 'boolean' then return end thisList.selectionListAreaWidget:SetVisible(show) thisList.isEnabled = show return true end
	thisList.isVisible = function() return thisList.selectionListAreaWidget:IsVisible() end
	if not thisList.isEnabled then thisList.setVisible(false) end
	thisList.getScreenPosition = function() return GetScreenPosition(thisList.selectionListAreaWidget) end

	local activeTextColor = thisList.activeTextColor
	local inactiveTextColor = thisList.inactiveTextColor
	local selectedTextColor = thisList.selectedTextColor

	thisList.listItemHeight = RoundF(fontSize * 1.75)
	
	local buttonAnchorPoint = {0, 0}
	local buttonSize = {thisList.listWidth, thisList.listItemHeight}
	local textOverflowPolicy, isAutoscroll = getTextOverflowPolicyByUserSettings()
	thisList.items = {}
	thisList.itemsByName = {}
	local inputItemName
	for i = 1, #inputItemList do
		if type(inputItemList[i]) == 'string' then inputItemName = inputItemList[i] else inputItemName = 'Unknown Item Name' end
		local newItem = cloneTable(thisList.item)
		tableInsert(thisList.items, newItem)
		newItem.itemIndex = #thisList.items
		newItem.name = newItem.name.."_"..tostring(newItem.itemIndex)
		thisList.itemsByName[newItem.name] = newItem
		local finalLabelText = inputItemName or "New Item "..tostring(newItem.itemIndex)

		newItem.setActive = function(activate)
			if type(activate) ~= 'boolean' then return end
			if activate then
				if newItem.isInteractiveButton then newItem.widget:SetInteractive(true) end
				newItem.isActive = true
				setWidgetTextLabelColor(newItem.widgetLabel, activeTextColor)
				newItem.widgetLabel:SetOpacity(thisList.activeTextOpacity)
				return true
			end
			newItem.widget:SetInteractive(false)
			newItem.isActive = false
			setWidgetTextLabelColor(newItem.widgetLabel, inactiveTextColor)
			newItem.widgetLabel:SetOpacity(thisList.inactiveTextOpacity)
			return true
		end

		newItem.setTextLabelByTextOverflowPolicy = function(newPolicy, isAutoscroll)
			if type(newPolicy) ~= 'userdata' then return end
			local enumName
			local shouldApplyOverflowPolicy = true
			if isAutoscroll and (not newItem.isSelected) and userSettings.autoScrollSelectedOnly then
				enumName = "None"
			else
				enumName = enumValueToString("textOverflowPolicy", EnumInt(newPolicy))
			end
			if enumName and stringLen(enumName) > 0 then
				local labelName = (newItem.widgetDefaultLabelNameStr or "label").."."..enumName
				local textWidget = newItem.widget:GetWidget(labelName)
				if textWidget and textWidget.name.value == labelName and newItem.widgetLabel.name.value ~= labelName then
					local isVisible = newItem.widgetLabel:IsVisible()
					local text = newItem.widgetLabel:GetText()
					local opacity = newItem.widgetLabel:GetOpacity()
					local textColor = newItem.widgetLabel:GetTintColor()
					local colorBind
					local bindings = newItem.widgetLabel.propertyManager.bindings
					for i = 1, #bindings do
						local property = bindings[i]
						if property.propertyName.value == 'tintColor' then colorBind = property.stylePath break end
					end
					textWidget:SetText(text)
					textWidget:SetOpacity(opacity)
					textWidget:SetTintColor(textColor)
					if colorBind then textWidget:BindProperty(n_tintColor, colorBind) end
					newItem.widgetLabel:SetVisible(false)
					newItem.widgetLabel = textWidget
					newItem.widgetLabel:SetVisible(isVisible)
				end
			end
		end

		newItem.title = finalLabelText
		newItem.widget, newItem.widgetLabel = createButton(newItem.name, newItem.title, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, isUpperCase or newItem.isUpperCase)
		newItem.widgetDefaultLabelNameStr = newItem.widgetLabel.name.value
		if not newItem.isInteractiveButton then SetInteractive(false) end
		if not newItem.isActive then newItem.setActive(false) end
		local iconMargin = 0
		if userSettings.hideCheckMarkIcon then
			local checkMark = newItem.widget:GetWidget('check_mark_icon')
			if checkMark and checkMark.name.value == 'check_mark_icon' then checkMark:SetVisible(false) end
			iconMargin = mathFloor(fontSize * 0.4)
		else
			iconMargin = mathFloor(fontSize * 1.4)
		end
		for i = 0, newItem.widget:GetNumChildren() -1 do
			local child = newItem.widget:GetWidget(i)
			if child and child:IsA(n_inkTextWidget) then
				child:SetFontStyle('Medium')
				child:SetAnchor(inkEAnchorLeftFillVerticaly)
				child:SetMargin(iconMargin, 0, 0, 0)
			end
		end

		newItem.setTextLabelByTextOverflowPolicy(textOverflowPolicy, isAutoscroll)

		newItem.setText = function(text, labelOnly) if type(text) ~= 'string' then return end if not isStringValid(text) then return end newItem.widgetLabel:SetText(text) if labelOnly then return end newItem.title = text return true end

		newItem.setVisible = function(show) if type(show) ~= 'boolean' then return end newItem.widget:SetVisible(show) newItem.isEnabled = show return true end
		if not newItem.isEnabled then newItem.setVisible(false) end
		newItem.getScreenPosition = function() return GetScreenPosition(newItem.widget) end

		newItem.setSelected = function(isSelected, isInit)
			if not newItem.isActive then return end
			if type(isSelected) ~= 'boolean' then return end
			local shouldAdjustTextOverflowPolicy, textOverflowPolicy, isAutoscroll
			if (not isInit) and userSettings.autoScrollSelectedOnly then
				textOverflowPolicy, isAutoscroll = getTextOverflowPolicyByUserSettings()
				if isAutoscroll then shouldAdjustTextOverflowPolicy = true end
			end
			if isSelected then
				newItem.widget:GetWidget('fill'):SetOpacity(0.03)
				newItem.widget:GetWidget('frame'):SetOpacity(1.0)
				newItem.widget:GetWidget('bg'):SetOpacity(0.8)
				setWidgetTextLabelColor(newItem.widgetLabel, selectedTextColor)
				newItem.widgetLabel:SetOpacity(1)
				newItem.isSelected = true
				if shouldAdjustTextOverflowPolicy then newItem.setTextLabelByTextOverflowPolicy(textOverflowPolicy, isAutoscroll) end
				return true
			end
			newItem.widget:GetWidget('fill'):SetOpacity(0.0)
			newItem.widget:GetWidget('frame'):SetOpacity(0.0)
			newItem.widget:GetWidget('bg'):SetOpacity(0.0)
			newItem.isSelected = false
			if shouldAdjustTextOverflowPolicy then newItem.setTextLabelByTextOverflowPolicy(textOverflowPolicy, isAutoscroll) end
			if newItem.isActive then
				setWidgetTextLabelColor(newItem.widgetLabel, activeTextColor)
				newItem.widgetLabel:SetOpacity(thisList.activeTextOpacity)
			else
				setWidgetTextLabelColor(newItem.widgetLabel, inactiveTextColor)
				newItem.widgetLabel:SetOpacity(thisList.inactiveTextOpacity)
			end
			return true
		end
		newItem.setSelected(false, true)

		newItem.setAccepted = function(isAccepted, isThisButtonUpdate)
			local checkMark = newItem.widget:GetWidget('check_mark_icon')
			if not checkMark then return end
			if checkMark.name.value ~= 'check_mark_icon' then return end
			newItem.isAccepted = checkMark:GetOpacity() >= 1
			local shouldUpdateAllItems = isAccepted and newItem.isAccepted ~= isAccepted
			if isAccepted then
				checkMark:SetOpacity(1)
				setWidgetTextLabelColor(checkMark, selectedTextColor)
			else
				checkMark:SetOpacity(0)
				setWidgetTextLabelColor(checkMark, activeTextColor)
			end
			newItem.isAccepted = isAccepted
			if isThisButtonUpdate then return true end
			if shouldUpdateAllItems then
				for i = 1, #thisList.items do
					if i ~= newItem.itemIndex then
						thisList.items[i].setAccepted(false, true)
					end
				end
			end
			return true
		end

		newItem.setHovered = function(isHovered, force)
			if not newItem.isActive then return end
			if newItem.isSelected and not force then return end
			if isHovered then
				newItem.widget:GetWidget('fill'):SetOpacity(0)
				newItem.widget:GetWidget('frame'):SetOpacity(0.3)
				newItem.widget:GetWidget('bg'):SetOpacity(0.3)
				newItem.isHovered = true
				thisList.lastHoveredItemIndex = newItem.itemIndex
				return
			end
			newItem.widget:GetWidget('fill'):SetOpacity(0.0)
			newItem.widget:GetWidget('frame'):SetOpacity(0.0)
			newItem.widget:GetWidget('bg'):SetOpacity(0.0)
			newItem.isHovered = false
		end

		local nextClicked = 0
		local lastClicked = 0
		newItem.onReleasedOrDoubleClick = function(isMouseClick)
			if isMouseClick then lastClicked = nextClicked end
			nextClicked = os.clock()

			local oldSelectedItemIndex = thisList.selectedItemIndex
			thisList.selectItem(newItem.itemIndex, true, false)
			if oldSelectedItemIndex ~= newItem.itemIndex then return end

			if not isMouseClick then thisList.useSelectedItem() return end

			if nextClicked - lastClicked < 0.5 then
				thisList.useSelectedItem()
			end
		end

		newItem.onReleased = function(isMouseClick)
			local oldSelectedItemIndex = thisList.selectedItemIndex
			thisList.selectItem(newItem.itemIndex, true, false)
			if oldSelectedItemIndex == newItem.itemIndex then return end
			thisList.useSelectedItem()
		end

		if newItem.itemIndex == 1 then
			local listSeparator = cloneTable(thisList.list_separator_line)
			listSeparator.widget = createBottomBorderLineWithMargin(listSeparator.name.."_0", 0, listSeparator.marginBottom, thisList.listWidth, "MainColors.MildRed")
			listSeparator.setVisible = function(show) if type(show) ~= 'boolean' then return end listSeparator.widget:SetVisible(show) listSeparator.isEnabled = show return true end
			if not listSeparator.isEnabled then listSeparator.setVisible(false) end
			local size = listSeparator.widget:GetSize()
			if size.X > thisList.listWidth then size.X = thisList.listWidth listSeparator.widget:SetSize(size) end
			listSeparator.widget:Reparent(thisList.selectionListAreaWidget, -1)
		end

		newItem.widget:Reparent(thisList.selectionListAreaWidget, -1)

		local listSeparator = cloneTable(thisList.list_separator_line)
		listSeparator.widget = createBottomBorderLineWithMargin(listSeparator.name.."_"..tostring(newItem.itemIndex), listSeparator.marginTop, listSeparator.marginBottom, thisList.listWidth, "MainColors.MildRed")
		listSeparator.setVisible = function(show) if type(show) ~= 'boolean' then return end listSeparator.widget:SetVisible(show) listSeparator.isEnabled = show return true end
		if not listSeparator.isEnabled then listSeparator.setVisible(false) end
		local size = listSeparator.widget:GetSize()
		if size.X > thisList.listWidth then size.X = thisList.listWidth listSeparator.widget:SetSize(size) end
		listSeparator.widget:Reparent(thisList.selectionListAreaWidget, -1)
	end
	thisList.itemCount = #thisList.items

	thisList.setTextOverlowPolicyByUserSettings = function()
		local textOverflowPolicy, isAutoscroll = getTextOverflowPolicyByUserSettings()
		if type(textOverflowPolicy) ~= 'userdata' then return end
		for i = 1, thisList.itemCount do
			thisList.items[i].setTextLabelByTextOverflowPolicy(textOverflowPolicy, isAutoscroll)
		end
	end

	thisList.getItem = function(itemIndex)
		if type(itemIndex) ~= 'number' then return end
		if itemIndex < 1 then return end
		if itemIndex > #thisList.items then return end
		return thisList.items[itemIndex]
	end

	thisList.getItemByName = function(itemName)
		if type(itemName) ~= 'string' then return end
		return thisList.itemsByName[itemName]
	end

	thisList.selectedItemIndex = 0
	thisList.selectItem = function(itemIndex, scrollListToItem, addRowMargin, centerOnSelected)
		if type(itemIndex) ~= 'number' then return end
		if itemIndex < 1 then return end
		if itemIndex > #thisList.items then return end
		local itemToSelect = thisList.items[itemIndex]
		if type(itemToSelect) ~= 'table' then return end
		if not IsDefined(itemToSelect.widget) then return end
		if not itemToSelect.setSelected(true) then return end
		local shouldUpdateAllItems = thisList.selectedItemIndex ~= itemIndex
		thisList.selectedItemIndex = itemIndex
		thisList.lastSelectedObject = itemToSelect
		thisList.lastSelectedObject.setAccepted(true)
		if shouldUpdateAllItems then for i = 1, #thisList.items do if i ~= itemIndex then thisList.items[i].setSelected(false) end end end
		if scrollListToItem then thisList.scrollToSelectedItem(addRowMargin, centerOnSelected) end
	end

	thisList.getSelectedItem = function()
		if thisList.selectedItemIndex < 1 then return end
		return thisList.items[thisList.selectedItemIndex]
	end

	thisList.deselectAll = function()
		for i = 1, #thisList.items do thisList.items[i].setAccepted(false, true) thisList.items[i].setSelected(false) end
		thisList.lastHoveredItemIndex = 0
		thisList.lastSelectedObject = nil
		thisList.selectedItemIndex = 0
		restoreDefaulCursor()
	end

	thisList.scrollToSelectedItem = function(addRowMargin, centerOnSelected)
		if thisList.selectedItemIndex < 1 then return end
		if thisList.itemCount < 1 then return end
		local selectedItem = thisList.items[thisList.selectedItemIndex]
		if not selectedItem then return end
		local scrollAreaWidget = thisList.listScrollAreaWidget
		if not IsDefined(scrollAreaWidget) then return end
		local sliderController = menu.mods.sliderController
		if not IsDefined(sliderController) then return end
		if not sliderController:GetSlidingAreaRef():IsVisible() then return end

		local selectedItemWidgetScreenPosition = selectedItem.getScreenPosition()
		local scrollAreaWidgetScreenPosition = GetScreenPosition(scrollAreaWidget)
		local isSelectedItemWithinViewport = scrollAreaWidgetScreenPosition.Top <= selectedItemWidgetScreenPosition.Top and selectedItemWidgetScreenPosition.Bottom <= scrollAreaWidgetScreenPosition.Bottom
		if isSelectedItemWithinViewport then return end

		local alignTop = selectedItemWidgetScreenPosition.Top < scrollAreaWidgetScreenPosition.Top
		local alignBottom = selectedItemWidgetScreenPosition.Bottom > scrollAreaWidgetScreenPosition.Bottom

		if alignTop and (not alignBottom) then
			if thisList.selectedItemIndex <= 1 then
				sliderController:ChangeProgress(0)
				return true
			end
			local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
			if scrollAreaWidgetViewportHeight == 0 then return end
			local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
			if selectionListAreaWidgetHeight == 0 then return end
			local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
			local rowsPerPage = mathFloor(scrollAreaWidgetViewportHeight/itemRowHeight)
			local topRow = thisList.selectedItemIndex -1
			if centerOnSelected then
				topRow = topRow - rowsPerPage + 1
			elseif addRowMargin then topRow = topRow - 1 end
			if topRow <= 1 then
				sliderController:ChangeProgress(0)
				return
			end
			local topVisibleRowPos = itemRowHeight * topRow
			local topRowItem = thisList.getItem(topRow)
			if topRowItem and topRowItem.itemIndex == topRow then
				local heightSum = 0
				local count = thisList.selectionListAreaWidget:GetNumChildren() - 1
				local isFound = false
				for i = 1, count do
					local widget = thisList.selectionListAreaWidget:GetWidget(i)
					if widget and widget:IsVisible() then
						heightSum = heightSum + widget:GetSize().Y
						if widget.name.value == topRowItem.name then
							isFound = true
							break
						end
					end
				end
				if isFound then
					topVisibleRowPos = heightSum - itemRowHeight
				end
			end

			local scrollRatio = getScrollRatio(scrollAreaWidgetViewportHeight, selectionListAreaWidgetHeight, topVisibleRowPos)
			sliderController:ChangeProgress(scrollRatio)
			return true
		else
			if thisList.selectedItemIndex >= thisList.itemCount then
				sliderController:ChangeProgress(1)
				return true
			end
			local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
			if scrollAreaWidgetViewportHeight == 0 then return end
			local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
			if selectionListAreaWidgetHeight == 0 then return end
			local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
			local rowsPerPage = mathFloor(scrollAreaWidgetViewportHeight/itemRowHeight)
			local topRow = thisList.selectedItemIndex - rowsPerPage
			if centerOnSelected then
				topRow = topRow + rowsPerPage - 1
			elseif addRowMargin then topRow = topRow + 1 end

			if topRow >= thisList.itemCount then 
				sliderController:ChangeProgress(1)
				return
			end
			local topVisibleRowPos = itemRowHeight * topRow

			local topRowItem = thisList.getItem(topRow)
			if topRowItem and topRowItem.itemIndex == topRow then
				local heightSum = 0
				local count = thisList.selectionListAreaWidget:GetNumChildren() - 1
				local isFound = false
				for i = 1, count do
					local widget = thisList.selectionListAreaWidget:GetWidget(i)
					if widget and widget:IsVisible() then
						heightSum = heightSum + widget:GetSize().Y
						if widget.name.value == topRowItem.name then
							isFound = true
							break
						end
					end
				end
				if isFound then
					topVisibleRowPos = heightSum
				end
			end

			local scrollRatio = getScrollRatio(scrollAreaWidgetViewportHeight, selectionListAreaWidgetHeight, topVisibleRowPos)
			sliderController:ChangeProgress(scrollRatio)
			return true
		end
	end

	if initialSelectedItemIndex > 0 then
		thisList.initialSelectedItemIndex = initialSelectedItemIndex
		local payload = function()
			thisList.selectItem(initialSelectedItemIndex, true, false, true)
			if not IsDefined(thisList.listScrollAreaWidget) then return end
			local selectedItem = thisList.getSelectedItem()
			if not selectedItem then return end
		end
		queueTask(payload, false, 0.01)
	end
	local function useSelectedItemIfIndexChanged(oldIndex)
		if thisList.selectedItemIndex < 0 then return end
		if thisList.selectedItemIndex > thisList.itemCount then return end
		if oldIndex == thisList.selectedItemIndex then return end
		thisList.useSelectedItem()
	end
	thisList.moveUpOnList = function(useItem)
		if thisList.itemCount < 1 then return end
		local addRowMargin = false
		local oldIndex = thisList.selectedItemIndex
		if thisList.selectedItemIndex < 1 and thisList.lastHoveredItemIndex > 0 then thisList.selectItem(thisList.lastHoveredItemIndex, true, addRowMargin) if useItem then useSelectedItemIfIndexChanged(oldIndex) end return end
		local newItemIndex = thisList.selectedItemIndex - 1
		if newItemIndex > 0 then thisList.selectItem(newItemIndex, true, addRowMargin) if useItem then useSelectedItemIfIndexChanged(oldIndex) end return end
		local scrollAreaWidget = thisList.listScrollAreaWidget
		if not IsDefined(scrollAreaWidget) then return end
		local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
		if selectionListAreaWidgetHeight == 0 then return end
		local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
		if scrollAreaWidgetViewportHeight == 0 then return end
		local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
		local rowsPerPage = scrollAreaWidgetViewportHeight/itemRowHeight
		newItemIndex = thisList.itemCount
		local scrollAreaWidgetScreenPosition = GetScreenPosition(scrollAreaWidget)
		for i = 1, thisList.itemCount do
			local itemScreenPos = thisList.items[i].getScreenPosition()
			if itemScreenPos.Bottom > scrollAreaWidgetScreenPosition.Bottom then
				newItemIndex = i - 1
				if newItemIndex < 1 then newItemIndex = 1 end
				break
			end
		end
		thisList.selectItem(newItemIndex, true, addRowMargin)
		if useItem then useSelectedItemIfIndexChanged(oldIndex) end
	end
	thisList.moveDownOnList = function(useItem)
		if thisList.itemCount < 1 then return end
		local addRowMargin = false
		if thisList.selectedItemIndex < 1 and thisList.lastHoveredItemIndex > 0 then thisList.selectItem(thisList.lastHoveredItemIndex, true, addRowMargin) if useItem then useSelectedItemIfIndexChanged(oldIndex) end return end
		if thisList.selectedItemIndex < 1 then thisList.selectItem(1, true, addRowMargin) if useItem then useSelectedItemIfIndexChanged(oldIndex) end return end
		local newItemIndex = thisList.selectedItemIndex + 1
		if newItemIndex <= thisList.itemCount then thisList.selectItem(newItemIndex, true, addRowMargin) if useItem then useSelectedItemIfIndexChanged(oldIndex) end return end
		local scrollAreaWidget = thisList.listScrollAreaWidget
		if not IsDefined(scrollAreaWidget) then return end
		local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
		if selectionListAreaWidgetHeight == 0 then return end
		local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
		if scrollAreaWidgetViewportHeight == 0 then return end
		local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
		local rowsPerPage = scrollAreaWidgetViewportHeight/itemRowHeight
		newItemIndex = 1
		local scrollAreaWidgetScreenPosition = GetScreenPosition(scrollAreaWidget)
		for i = thisList.itemCount, 1, -1 do
			local itemScreenPos = thisList.items[i].getScreenPosition()
			if itemScreenPos.Top < scrollAreaWidgetScreenPosition.Top then
				newItemIndex = i + 1
				if newItemIndex > thisList.itemCount then newItemIndex = thisList.itemCount end
				break
			end
		end
		thisList.selectItem(newItemIndex, true, addRowMargin)
		if useItem then useSelectedItemIfIndexChanged(oldIndex) end
	end

	thisList.moveUp = function(useItem)
		thisList.moveUpOnList(useItem)
	end
	thisList.moveDown = function(useItem)
		thisList.moveDownOnList(useItem)
	end

	thisList.getLastSelectedObject = function()
		return thisList.lastSelectedObject
	end

	setupSelectionListActions(thisList)
	nativeUI.isSelectionList = true
	thisList.selectionListAreaWidget:Reparent(thisList.parentWidget, -1)

	return thisList
end

function setupSelectionListActions(thisList)
	thisList.cleanup = function()
		unregisterSelectionListCallbacks(thisList)
		thisList.setVisible(false)
		if IsDefined(thisList.selectionListAreaWidget.parentWidget) then thisList.selectionListAreaWidget.parentWidget:RemoveAllChildren() end
		nativeUI.isSelectionList = false
		nativeUI.lastSelectionList = {}
	end
	thisList.useSelectedItemCallback = function()
		switchToMod(lastSettingsMainGameController, thisList.getLastSelectedObject().title)
	end
	thisList.useSelectedItem = function()
		if not isDelayedButtonActionAllowed then return end
		nativeUI.lastSelectionListReturn = thisList.getSelectedItem()
		nativeUI.lastSelectionListReturn.setAccepted(true)
		local payload = function() thisList.useSelectedItemCallback() isDelayedButtonActionAllowed = true end
		isDelayedButtonActionAllowed = false
		queueTask(payload, true, buttonDelay)
	end
	thisList.isInitialized = true
end

function registerSelectionListCallbacks(thisList, isNew)
	if not IsDefined(thisList.selectionListAreaWidget) then return end
	if not thisList.isEnabled then return end
	if not IsDefined(thisList.eventCatcher) then
		thisList.eventCatcher = sampleStyleManagerGameController.new()
		tableInsert(nativeUI.activeInstances, {eventCatcher = thisList.eventCatcher, isSelectionList = true, callerData = thisList})
	end
	if not IsDefined(thisList.eventCatcher) then return end

	local isAnyCallbackRegistered = false
	for i, buttonData in ipairs(thisList.items) do
		if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
			buttonData.widget:RegisterToCallback('OnPress', thisList.eventCatcher, 'OnState1')
			buttonData.widget:RegisterToCallback('OnRelease', thisList.eventCatcher, 'OnState2')
			buttonData.widget:RegisterToCallback('OnEnter', thisList.eventCatcher, 'OnStyle1')
			buttonData.widget:RegisterToCallback('OnLeave', thisList.eventCatcher, 'OnStyle2')
			isAnyCallbackRegistered = true
		end
	end

	return isAnyCallbackRegistered
end

function unregisterSelectionListCallbacks(thisList)
	if type(thisList) ~= 'table' then return end
	if not thisList.selectionListAreaWidget then return end
	if not IsDefined(thisList.eventCatcher) then return end

	for i, buttonData in ipairs(thisList.items) do
		if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
			buttonData.widget:UnregisterFromCallback('OnPress', thisList.eventCatcher, 'OnState1')
			buttonData.widget:UnregisterFromCallback('OnRelease', thisList.eventCatcher, 'OnState2')
			buttonData.widget:UnregisterFromCallback('OnEnter', thisList.eventCatcher, 'OnStyle1')
			buttonData.widget:UnregisterFromCallback('OnLeave', thisList.eventCatcher, 'OnStyle2')
		end
	end
	thisList.eventCatcher = nil

	for i = #nativeUI.activeInstances, 1, -1 do
		if type(nativeUI.activeInstances[i]) == 'table' and nativeUI.activeInstances[i].isSelectionList then table.remove(nativeUI.activeInstances, i) end
	end
	return true
end

function unregisterAllCallbacks()
	unregisterSelectionListCallbacks(nativeUI.lastSelectionList)
	nativeUI.activeInstances = {}
end

local function goToModTask(this, modName, timeout)
	if isModDisabled then return true end
	if not nativeSettings.fromMods then return true end
	if not IsDefined(this) then return true end
	if os.clock() > timeout then return true end
	if not nativeSettings.tabSizeCache then return false end
	local pages = #nativeSettings.tabSizeCache
	local lookedPage, lookedIndex = 0, 0
	local isFound = false
	if pages < 2 then
		lookedPage = 1
		local sourceData = this.data
		for i = 1, #sourceData do
			if sourceData[i].label.value == modName then
				lookedIndex = i isFound = true break
			end
		end
	else
		for page, modsOnPage in ipairs(nativeSettings.tabSizeCache) do
			for i = 1, #modsOnPage do
				if modsOnPage[i] == modName then
					lookedPage = page lookedIndex = i isFound = true break
				end
			end
			if isFound then break end
		end
	end
	if not isFound then return true end
	local isPageSwitched = false
	if pages > 1 and lookedPage ~= nativeSettings.currentPage then
		local pageDiff = lookedPage - nativeSettings.currentPage
		if pageDiff > 0 then for i = 1, pageDiff do nativeSettings.switchToNextPage(this, true) isPageSwitched = true end
		else for i = 1, -pageDiff do nativeSettings.switchToPreviousPage(this, true) isPageSwitched = true end end
	end
	if not lookedPage == nativeSettings.currentPage then return true end
	local currentIndex = this.selectorCtrl:GetToggledIndex()
	lookedIndex = lookedIndex - 1
	if (not isPageSwitched) and currentIndex == lookedIndex then return true end
	local task = function() this.selectorCtrl:SetToggledIndex(lookedIndex) end
	if isPageSwitched then queueTask(task, false, 0.05) else queueTask(task, false, 0.001) end
	return true
end
function switchToMod(this, modName)
	if type(modName) ~= 'string' then return end
	if stringLen(modName) < 1 then return end
	if not IsDefined(this) then return end
	local task = function() return goToModTask(this, modName, os.clock() + 1) end
	queueTask(task, false, 0.001, 0.001, false)
end
function createSidePanelModListWrapper(forceRepopulate, isInit)
	if not userSettings.enableSidePanel then return end
	if not IsDefined(menu.left.topWidget) then return end
	if not IsDefined(menu.middle.topWidget) then return end
	return createSidePanelModListWrapper_Standalone(forceRepopulate, isInit)
end
local function copyBasicWidgetProperties(source, target)
	target:SetAnchorPoint(source:GetAnchorPoint())
	target:SetAnchor(source:GetAnchor())
	target:SetFitToContent(source:GetFitToContent())
	target:SetHAlign(source:GetHAlign())
	target:SetVAlign(source:GetVAlign())
	target:SetMargin(source:GetMargin())
	target:SetPadding(source:GetPadding())
	target:SetScale(source:GetScale())
	target:SetShear(source:GetShear())
	target:SetSize(source:GetSize())
	target:SetSizeCoefficient(source:GetSizeCoefficient())
	target:SetSizeRule(source:GetSizeRule())
	target:SetLayout(source.layout)
	return target
end
local refWeak = Ref.Weak
function createSidePanelModListWrapper_Standalone(forceRepopulate, isInit)
	local lookedWidget = menu.left.topWidget:GetWidget(menu.mods.topWidgetName)
	if lookedWidget and lookedWidget.name == menu.mods.topWidgetName then
		if not forceRepopulate then return true end
		if nativeUI.lastSelectionList.isInitialized then nativeUI.lastSelectionList.cleanup() end
		if isInit then createNewModsList() else queueTask(createNewModsList, false, 0.001) end
		return true
	end

	local tempRoot = lastSettingsMainGameController:SpawnFromExternal(_, ResRef.FromName("base\\gameplay\\gui\\fullscreen\\tarot\\tarot.inkwidget"), "Root")
	if not tempRoot then return end

	tempRoot:SetVisible(false)
	local scrollAreaWrapper = tempRoot:GetWidget("wrapper")
	local parent = tempRoot.parentWidget
	scrollAreaWrapper:Reparent(parent, -1)
	parent:RemoveChild(tempRoot)
	scrollAreaWrapper:SetName(menu.mods.topWidgetName)
	for i = scrollAreaWrapper:GetNumChildren() -1, 0, -1 do
		local widget =  scrollAreaWrapper:GetWidget(i)
		local name = widget.name.value
		if name == "scroll_area" then
			widget:RemoveAllChildren()
			local settings_option_list = inkVerticalPanelWidget.new()
			settings_option_list:SetName("settings_option_list")
			settings_option_list:SetAnchor(inkEAnchorTopLeft)
			settings_option_list:SetFitToContent(true)
			settings_option_list:Reparent(widget, -1)
		elseif name ~= "slider" then scrollAreaWrapper:RemoveChild(widget) end
	end

	mainScrollAreaWrapper = menu.middle.topWidget
	scrollAreaWrapper = copyBasicWidgetProperties(mainScrollAreaWrapper, scrollAreaWrapper)

	local slider = scrollAreaWrapper:GetWidget("slider")
	local mainSlider = mainScrollAreaWrapper:GetWidget("slider")
	slider = copyBasicWidgetProperties(mainSlider, slider)
	slider:SetAnchor(inkEAnchorTopRight)
	local margin = slider:GetMargin()
	margin.top = 0
	margin.right = 0
	slider:SetMargin(margin)
	slider:SetFitToContent(true)
	slider.logicController.slidingAreaWidgetRef:SetInteractive(true)

	local slidingArea = slider:GetWidget("slidingArea")
	local mainSlidingArea = mainSlider:GetWidget("slidingArea")
	slidingArea = copyBasicWidgetProperties(mainSlidingArea, slidingArea)
	local size = slidingArea:GetSize()
	size.Y = size.Y + 28
	slidingArea:SetSize(size)
	slidingArea:GetWidget("background"):BindProperty(n_tintColor, n_MainColorsDarkRed)

	local scroll_area = scrollAreaWrapper:GetWidget("scroll_area")
	local mainScroll_area = mainScrollAreaWrapper:GetWidget("scroll_area")
	scroll_area = copyBasicWidgetProperties(mainScroll_area, scroll_area)
	scroll_area:SetUseInternalMask(true)
	local size = scroll_area:GetSize()
	size.X = RoundF(size.X * 0.3)
	scroll_area:SetSize(size)

	local mainScrollAreaWrapperSize = scrollAreaWrapper:GetSize()
	mainScrollAreaWrapperSize.Y =  scroll_area:GetSize().Y
	scrollAreaWrapper:SetSize(mainScrollAreaWrapperSize)

	local settings_option_list = scroll_area:GetWidget(0)
	local mainSettings_option_list = mainScroll_area:GetWidget(0)
	settings_option_list = copyBasicWidgetProperties(mainSettings_option_list, settings_option_list)

	menu.mods.topWidget = refWeak(scrollAreaWrapper)
	menu.mods.scrollVieportArea = refWeak(scroll_area)
	menu.mods.scrollContentArea = refWeak(settings_option_list)
	menu.mods.scrollSliderArea = refWeak(slider)
	menu.mods.areaScrollController = refWeak(scrollAreaWrapper.logicController)
	menu.mods.sliderController = refWeak(slider.logicController)

	menu.middle.areaScrollController = refWeak(menu.middle.topWidget.logicController)
	menu.middle.sliderController = refWeak(mainSlider.logicController)

	scrollAreaWrapper:Reparent(menu.left.topWidget, 0)

	if isInit then createNewModsList() else queueTask(createNewModsList, false, 0.001) end

	return true
end

function selectListItemByMenuSelector()
	if not userSettings.enableSidePanel then return end
	if not nativeUI.lastSelectionList.isInitialized then return end
	if not IsDefined(lastSettingsMainGameController) then return end
	local currentlySelectedTabName
	local selectedIndex = lastSettingsMainGameController.selectorCtrl:GetToggledIndex()
	local currentlySelectedTabWidget = lastSettingsMainGameController.selectorWidget.widget:GetWidget(selectedIndex)
	if not currentlySelectedTabWidget then return end
	for i = 0, currentlySelectedTabWidget:GetNumChildren() -1 do
		local textLabel = currentlySelectedTabWidget:GetWidget(i)
		if textLabel and type(textLabel.text) == 'string' and stringLen(textLabel.text) > 0 then
			currentlySelectedTabName = textLabel.text
			break
		end
	end
	if type(currentlySelectedTabName) ~= 'string' then return end
	local initialIndex
	for i = 1, nativeUI.lastSelectionList.itemCount do
		if nativeUI.lastSelectionList.items[i].title == currentlySelectedTabName then initialIndex = i break end
	end
	if not initialIndex then return end
	nativeUI.lastSelectionList.selectItem(initialIndex, true, false)
end
local n_SettingsSelectorControllerBool = "SettingsSelectorControllerBool"
function createNewModsList()
	local tabs = {}
	local currentlySelectedTabName = ""
	if IsDefined(lastSettingsMainGameController) then
		for i = 1, #lastSettingsMainGameController.data do
			tableInsert(tabs, lastSettingsMainGameController.data[i].label.value)
		end
		local selectedIndex = lastSettingsMainGameController.selectorCtrl:GetToggledIndex()
		local currentlySelectedTabWidget = lastSettingsMainGameController.selectorWidget.widget:GetWidget(selectedIndex)
		if currentlySelectedTabWidget then
			for i = 0, currentlySelectedTabWidget:GetNumChildren() -1 do
				local textLabel = currentlySelectedTabWidget:GetWidget(i)
				if textLabel and type(textLabel.text) == 'string' and stringLen(textLabel.text) > 0 then
					currentlySelectedTabName = textLabel.text
					break
				end
			end
		end
	end
	local initialIndex = 1
	local maxCount = #tabs
	for i = 1, maxCount do
		if not tabs[i] then tableInsert(tabs, "Text line "..tostring(i)) end
		if tabs[i] == currentlySelectedTabName then initialIndex = i end
	end

	local newSelectionList = createSelectionList(tabs, initialIndex, _, menu.mods.scrollVieportArea:GetSize().X, 48, true)
	if newSelectionList then
		registerSelectionListCallbacks(newSelectionList)
		nativeUI.lastSelectionList = newSelectionList
		nativeUI.lastSelectionList.isPopulated = true
	end
end

local function updateSidePanelModListSelectionTask()
	if isModDisabled then return end
	if not nativeSettings.fromMods then return end
	if not userSettings.enableSidePanel then return end
	if not IsDefined(lastSettingsMainGameController) then return end
	if not nativeUI.lastSelectionList.isInitialized then return end
	local selectedIndex = lastSettingsMainGameController.selectorCtrl:GetToggledIndex()
	local currentlySelectedTabWidget = lastSettingsMainGameController.selectorWidget.widget:GetWidget(selectedIndex)
	if currentlySelectedTabWidget then
		for i = 0, currentlySelectedTabWidget:GetNumChildren() -1 do
			local textLabel = currentlySelectedTabWidget:GetWidget(i)
			if textLabel and type(textLabel.text) == 'string' and stringLen(textLabel.text) > 0 then
				currentlySelectedTabName = textLabel.text
				break
			end
		end
	end
	if type(currentlySelectedTabName) ~= 'string' then return end
	local initialIndex
	for i = 1, nativeUI.lastSelectionList.itemCount do if nativeUI.lastSelectionList.items[i].title == currentlySelectedTabName then initialIndex = i break end end
	if not initialIndex then return end
	nativeUI.lastSelectionList.selectItem(initialIndex, true, false)
end

function updateSidePanelModListSelection(skipPreCheck)
	if not nativeUI.lastSelectionList.isInitialized then return end
	if not IsDefined(lastSettingsMainGameController) then return end
	if skipPreCheck then queueTask(updateSidePanelModListSelectionTask, true, 0.01) return end
	if not userSettings.enableSidePanel then return end
	if not IsDefined(menu.left.topWidget) then return end
	if not IsDefined(menu.middle.topWidget) then return end
	if not nativeUI.lastSelectionList then return end
	if not nativeUI.lastSelectionList.isPopulated then return end
	queueTask(updateSidePanelModListSelectionTask, true, 0.01)
end

function destroySidePanelModListWrapper()	
	if nativeUI.lastSelectionList and nativeUI.lastSelectionList.cleanup then nativeUI.lastSelectionList.cleanup() end
	unregisterAllCallbacks()
	if IsDefined(menu.mods.scrollContentArea) then
		local content = menu.mods.scrollContentArea:GetWidget(0)
		if content then
			content:SetVisible(false)
			menu.mods.scrollContentArea:RemoveAllChildren()
		end
	end
	if IsDefined(menu.left.topWidget) and IsDefined(menu.mods.topWidget) then menu.left.topWidget:RemoveChild(menu.mods.topWidget) end
	menu.mods.topWidget = nil
	menu.mods.scrollVieportArea = nil
	menu.mods.scrollContentArea = nil
	menu.mods.scrollSliderArea = nil
	menu.mods.sliderHandle = nil
	menu.mods.areaScrollController = nil
	menu.mods.sliderController = nil
	nativeUI.isSelectionList = false
	nativeUI.lastSelectionList = {}
end

local function isXYInModsMenuArea(x, y, skipPreCheck)
	return isXYWithinWidgetOnScreen(x, y, menu.mods.topWidget) or isXYWithinWidgetOnScreen(x, y, menu.mods.scrollSliderArea)
end

local function switchScrollAreaFocus(evt, caller)
	if isModDisabled then return end
	if not nativeSettings.fromMods then return end
	if not nativeUI.lastSelectionList then return end
	if not nativeUI.lastSelectionList.isEnabled then return end
	if not IsDefined(evt) then return end
	if not IsDefined(menu.mods.areaScrollController) then return end
	if not IsDefined(menu.middle.areaScrollController) then return end
	if not IsDefined(menu.mods.topWidget) then return end
	local pos = evt:GetScreenSpacePosition()
	local isInModsMenuArea = isXYInModsMenuArea(pos.X, pos.Y, true)
	if isInModsMenuArea then
		menu.middle.areaScrollController:SetInputDisabled(true)
		menu.mods.areaScrollController:SetInputDisabled(false)
		return true
	end
	menu.middle.areaScrollController:SetInputDisabled(false)
	menu.mods.areaScrollController:SetInputDisabled(true)
end

local stringLower = string.lower
function setupObservers()
	for _, menuEntry in pairs(menu) do
		if type(menuEntry.topWidgetName) == 'string' then
			if not isKnownName(menuEntry.topWidgetName) then cNameAdd(menuEntry.topWidgetName) end
			menuEntry.topWidgetName = n(menuEntry.topWidgetName)
		end
		if type(menuEntry.topWidgetPath) == 'table' then menuEntry.topWidgetPath = BuildWidgetPath(menuEntry.topWidgetPath) end
	end

	local function sortTabs(this)
		local isSortingAllowed = userSettings.enableModSorting
		if deferredSettingsChange and deferredSettingsChange.enableModSorting and type(deferredSettingsChange.enableModSorting.oldValue) == 'boolean' then isSortingAllowed = deferredSettingsChange.enableModSorting.oldValue end
		if not isSortingAllowed then return end

		local sourceData = this.data
		local dataCount = #sourceData
		if dataCount < 2 then return end

		local tabs = {}
		for i = 1, dataCount do
			local data = sourceData[i]
			tableInsert(tabs, {label = data.label.value, data = data})
		end
		tableSort(tabs, function(a, b)
			return stringLower(a.label) < stringLower(b.label)
		end)
		for i = 1, #tabs do
			tabs[i] = tabs[i].data
		end
		if #tabs ~= dataCount then return end
		this.data = tabs
	end

	local isInitializing = false
	local lastNsInitTime = 0
	ObserveBefore("SettingsMainGameController", "OnInitialize", function (this)
		deferredSettingsChange = nil
		isInitializing = true
		lastSettingsMainGameController = refWeak(this)
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
	ObserveAfter("SettingsMainGameController", "PopulateSettingsData", function (this)
		lastSettingsMainGameController = refWeak(this)
		if isModDisabled then return end
		if not nativeSettings.fromMods then return end
		sortTabs(this)
		local root = this:GetRootCompoundWidget()
		if not root then return end
		for _, menuEntry in pairs(menu) do
			if type(menuEntry) == 'table' and type(menuEntry.topWidgetPath) == 'userdata' then
				lookedWidget = root:GetWidgetByPath(menuEntry.topWidgetPath)
				if lookedWidget and lookedWidget.name == menuEntry.topWidgetName then menuEntry.topWidget = refWeak(lookedWidget) end
			end
		end
		createSidePanelModListWrapper(false, isInitializing)
		updateSidePanelModListSelection(true)
	end)
	ObserveAfter("SettingsMainGameController", "OnInitialize", function (this)
		isInitializing = false
		lastSettingsMainGameController = refWeak(this)
		if isModDisabled then return end
		if not nativeSettings.fromMods then return end
		local root = this:GetRootCompoundWidget()
		if not root then return end
		for _, menuEntry in pairs(menu) do
			if type(menuEntry) == 'table' and type(menuEntry.topWidgetPath) == 'userdata' then
				lookedWidget = root:GetWidgetByPath(menuEntry.topWidgetPath)
				if lookedWidget and lookedWidget.name == menuEntry.topWidgetName then menuEntry.topWidget = refWeak(lookedWidget) end
			end
		end
		createSidePanelModListWrapper(false, isInitializing)
	end)
	ObserveBefore("SettingsMainGameController", "RequestClose", function (this)
		lastSettingsMainGameController = nil
		destroySidePanelModListWrapper()
		deferredSettingsChange = nil
	end)

	local stayInPlace = 0
	local left = 1
	local up = 2
	local right = 3
	local down = 4
	local navigateTo = -1
	function handleModsListNavigation(this, callerInstance, navigateTo, caller, actionName, actionType)
		local callerData = callerInstance.callerData
		if not callerInstance.isSelectionList then return end
		if navigateTo == up then
			callerData.moveUp(true)
			local targetObject = callerData.getLastSelectedObject()
			if not targetObject then return end
			restoreDpadCursor()
			this:SetCursorOverWidget(targetObject.widget, 0, true)
			return
		end
		if navigateTo == down then
			callerData.moveDown(true)
			local targetObject = callerData.getLastSelectedObject()
			if not targetObject then return end
			restoreDpadCursor()
			this:SetCursorOverWidget(targetObject.widget, 0, true)
			return
		end
		if navigateTo == stayInPlace then
			local targetObject = callerData.getLastSelectedObject()
			if not targetObject then return end
			restoreDpadCursor()
			this:SetCursorOverWidget(targetObject.widget, 0, true)
			return
		end
	end

	local lastkeyPressTime = 0
	local lastRepeatKeyPressTime = 0

	local a_buttonPressed = gameinputActionType.BUTTON_PRESSED
	local a_buttonReleased = gameinputActionType.BUTTON_RELEASED
	local a_buttonHoldComplete = gameinputActionType.BUTTON_HOLD_COMPLETE
	local a_buttonHoldProgress = gameinputActionType.BUTTON_HOLD_PROGRESS
	local a_repeat = gameinputActionType.REPEAT
	local n_navigate_down = n"navigate_down"
	local n_navigate_up = n"navigate_up"
	ObserveBefore('PlayerPuppet', 'OnAction', function(this, action, consumer)
		if not nativeSettings.fromMods then return end
		if not nativeUI.lastSelectionList then return end
		if not nativeUI.lastSelectionList.isEnabled then return end
		if not IsDefined(lastSettingsMainGameController) then return end
		local actionType = action:GetType(action)
		if actionType ~= a_repeat and actionType ~= a_buttonPressed and actionType ~= a_buttonReleased and actionType ~= a_buttonHoldProgress and actionType ~= a_buttonHoldProgress then return end

		local x, y = getCurrentCursorPosition()
		if not x then return end
		local isInModsMenuArea = isXYInModsMenuArea(x, y, true)
		if not isInModsMenuArea then return end

		local isUp, isDown = false, false
		if action:IsAction(n_navigate_down) then isDown = true elseif action:IsAction(n_navigate_up) then isUp = true end
		if not (isUp or isDown) then return end
		consumer.Consume(consumer)
		local currTime = os.clock()
		if currTime - lastkeyPressTime < 0.005 then return end
		lastkeyPressTime = currTime
		lastRepeatKeyPressTime = currTime
		local callerInstance = {isSelectionList = true, callerData = nativeUI.lastSelectionList}
		navigateTo = -1
		if isUp then navigateTo = up elseif isDown then navigateTo = down else return end
		if actionType == a_buttonReleased then navigateTo = stayInPlace end
		handleModsListNavigation(lastSettingsMainGameController, callerInstance, navigateTo, 'PlayerPuppet OnAction', action:GetName(action).value, action:GetType(action).value)
	end)

	local n_down_button = n"down_button"
	local n_up_button = n"up_button"
	ObserveBefore("SettingsMainGameController", "OnButtonRelease", function (this, evt)
		if not switchScrollAreaFocus(evt, "SettingsMainGameController OnButtonRelease") then return end
		local isUp, isDown, isMovingOnTheList = false, false, false
		if evt:IsAction(n_down_button) then isDown = true isMovingOnTheList = true elseif evt:IsAction(n_up_button) then isUp = true isMovingOnTheList = true end
		if not isMovingOnTheList then return end
		evt:Consume()

		local currTime = os.clock()
		if currTime - lastkeyPressTime < 0.005 then return end
		if currTime - lastRepeatKeyPressTime < 0.5 then return end
		lastkeyPressTime = currTime
		local callerInstance = {isSelectionList = true, callerData = nativeUI.lastSelectionList}
		navigateTo = 0
		if isUp then navigateTo = up elseif isDown then navigateTo = down else return end
		handleModsListNavigation(this, callerInstance, navigateTo, 'SettingsMainGameController OnButtonRelease')
	end)
	ObserveBefore("SettingsMainGameController", "OnSettingHoverOver", function (this, evt)
		switchScrollAreaFocus(evt, "SettingsMainGameController OnSettingHoverOver")
	end)
	ObserveBefore("SettingsMainGameController", "OnSettingHoverOut", function (this, evt)
		switchScrollAreaFocus(evt, "SettingsMainGameController OnSettingHoverOut")
	end)

	local shouldResetSettingsPanel, shouldReloadMenu, shouldRestoreDefaultSettings
	ObserveBefore("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		shouldRestoreDefaultSettings = false
		if not nativeSettings then return end
		if not nativeSettings.fromMods then return end

		local currentOption = nativeSettings.data[nativeSettings.currentTab]
		if not currentOption then return end
		if currentOption.isRedMod then return end
		if currentOption.path ~= "Native Settings UI Side Menu Add on" then return end

		shouldRestoreDefaultSettings = true
		setupNativeSettings(true, true)
	end)
	ObserveAfter("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		if not shouldRestoreDefaultSettings then return end
		shouldRestoreDefaultSettings = false
		setupNativeSettings(true)
	end)

	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(self)
		if self:IsReplacer() then return end
		queuedTasks.resetQueue = true
		destroySidePanelModListWrapper()
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
	end)
	ObserveBefore('inkISystemRequestsHandler', 'RequestSaveUserSettings', function(this)
		if not Game.GetSystemRequestsHandler():IsPreGame() then return end
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
	end)
	ObserveAfter('SettingsMainGameController', 'OnUninitialize', function (this)
		queuedTasks.resetQueue = true
		setupNativeSettings(true)
	end)
	Observe('CursorGameController', 'OnSetCursorVisibility', function(this) lastGameCursorController = refWeak(this) end)
	Observe('CursorGameController', 'OnSetCursorType', function(this) lastGameCursorController = refWeak(this) end)

	function getCaller(this, evt)
		if type(nativeUI.activeInstances) ~= 'table' then return end
		if #nativeUI.activeInstances < 1 then return end

		local buttonWidget = evt:GetTarget()
		if not buttonWidget then return end

		local callerInstance = nil
		for i = #nativeUI.activeInstances, 1, -1 do
			if IsDefined(nativeUI.activeInstances[i].eventCatcher) and isSameInstance(this, nativeUI.activeInstances[i].eventCatcher) then
				callerInstance = nativeUI.activeInstances[i]
				break
			end
		end
		if not callerInstance then return end
		if not callerInstance.callerData then return end
		local callerData = callerInstance.callerData

		local buttonNameStr = buttonWidget:GetName().value
		local button = nil
		if callerInstance.isSelectionList then
			button = callerData.getItemByName(buttonNameStr)
		end
		if type(button) ~= 'table' then return end
		if not IsDefined(button.widget) then return end
		return button, buttonNameStr, callerInstance.isScenePanel, callerInstance.isSelectionList, callerInstance.isMainMenu, callerData
	end

-----------------------------------------------------------------------------------------------
-- This code is based on ui.lua module from Nano Drone v1.3h mod by (c)keanuWheeze
-- The original code is based on (c)psiberx game research and code snippets

	Observe('sampleStyleManagerGameController', 'OnStyle1', function(self, evt)
		if nativeUI.isModDisabled then return end
		if not nativeSettings.fromMods then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if not button.isListItem then return end
		GetPlayer():PlaySoundEvent("ui_menu_hover")
		if button.isActive then
			button.setHovered(true)
		end
	end)

	Observe('sampleStyleManagerGameController', 'OnStyle2', function(self, evt)
		if nativeUI.isModDisabled then return end
		if not nativeSettings.fromMods then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if not button.isListItem then return end
		if button.isActive then
			if not button.isSelected then
				setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor)
				button.widgetLabel:SetOpacity(callerData.activeTextOpacity)
			end
			button.setHovered(false)
		else
			setWidgetTextLabelColor(button.widgetLabel, callerData.inactiveTextColor)
			button.widgetLabel:SetOpacity(callerData.inactiveTextOpacity)
		end
	end)

	local nextKeyPressAllowedTime = 0
	Observe('sampleStyleManagerGameController', 'OnState1', function(self, evt)
		if nativeUI.isModDisabled then return end
		if not nativeSettings.fromMods then return end
		if not evt:IsAction("click") then return end
		if nextKeyPressAllowedTime > os.clock() then return end
		nextKeyPressAllowedTime = os.clock() + 0.003
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if not button.isListItem then return end
		setWidgetTextLabelColor(button.widgetLabel, callerData.highlightTextColor)
		button.widgetLabel:SetOpacity(1)
		button.onPressed()
	end)

	local isMouseClick = false
	Observe('sampleStyleManagerGameController', 'OnState2', function(self, evt)
		if nativeUI.isModDisabled then return end
		if not nativeSettings.fromMods then return end
		if evt:IsAction("click") then return end
		local currTime = os.clock()
		isMouseClick = false
		if evt:IsAction("mouse_left") then isMouseClick = true end
		if (not isMouseClick) and (not evt:IsAction("proceed")) then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if not button.isListItem then return end
		setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor)
		button.widgetLabel:SetOpacity(callerData.activeTextOpacity)
		button.onReleased(isMouseClick)
		callerData.lastSelectedObject = button
		GetPlayer():PlaySoundEvent("ui_menu_onpress")
	end)
end

function isKnownName(inputString)
	return cNameNew(inputString).value == inputString
end

function restoreDpadCursor()
	if IsDefined(lastGameCursorController) and lastGameCursorController.cursorType.value ~= 'dpad' then lastGameCursorController:OnSetCursorType("dpad") end
end

function restoreDefaulCursor()
	if IsDefined(lastGameCursorController) and lastGameCursorController.cursorType.value ~= 'default' then lastGameCursorController:OnSetCursorType("default") end
end

function setCursorOverWidgetWithCursorRestore(menuController, widget, restoreDefaultCursor)
	if not IsDefined(menuController) then return end
	if not IsDefined(lastGameCursorController) then return end
	if not IsDefined(widget) then return end
	menuController:SetCursorOverWidget(widget, 0, true)
	if not restoreDefaultCursor then return true end
	restoreDefaulCursor()
	return true
end

function getCurrentCursorPosition()
	if not IsDefined(lastGameCursorController) then return end
	local margin = lastGameCursorController.margin
	return margin.left, margin.top
end

function isGameCursorWithinWidget(widget)
	if not IsDefined(widget) then return end
	local x, y = getCurrentCursorPosition()
	if not x then return false end
	return true, isXYWithinWidgetOnScreen(x, y, widget), x, y
end

function isXYWithinWidgetOnScreen(x, y, widget)
	if not IsDefined(widget) then return end
	local aPos = GetScreenPosition(widget)
	return y >= aPos.Top and y <= aPos.Bottom and x >= aPos.Left and x <= aPos.Right
end

function isWidgetWithinWidgetOnScreen(a, b, overlap)
	local aPos = GetScreenPosition(a)
	local bPos = GetScreenPosition(b)
	if not overlap then return aPos.Top >= bPos.Top and aPos.Bottom <= bPos.Bottom and aPos.Left >= bPos.Left and aPos.Right <= bPos.Right end

	local isVerticalOverlap = false
	if aPos.Top >= bPos.Top and aPos.Top <= bPos.Bottom then isVerticalOverlap = true
	elseif aPos.Bottom >= bPos.Top and aPos.Top <= bPos.Bottom then isVerticalOverlap = true end
	if not isVerticalOverlap then return false end

	if aPos.Left >= bPos.Left and aPos.Left <= bPos.Right then return true
	elseif aPos.Right >= bPos.Left and aPos.Right <= bPos.Right then return true end

	return false
end

function getScrollRatio(vieportLength, contentLength, desiredVisibleContentStartPosition)
	if desiredVisibleContentStartPosition <= 0 then return 0 end
	local contentLengthBase = contentLength - vieportLength
	if contentLengthBase <= 0 then return 0 end
	return mathMax(0, mathMin(1, desiredVisibleContentStartPosition/contentLengthBase)) -- psiberx performance tip
end

local n_inkScrollAreaWidget = "inkScrollAreaWidget"
function getScrollAreaProgressValues(scrollVieportArea, isHorizontal, scrollContentArea)
	if not IsDefined(scrollVieportArea) then return end
	if not scrollVieportArea:IsA(n_inkScrollAreaWidget) then return end
	if not IsDefined(scrollContentArea) then scrollContentArea = scrollVieportArea:GetWidget(0) end
	if not scrollContentArea then return end

	local vieportHeight = 0
	local contentHeight = 0
	if isHorizontal then
		vieportHeight = scrollVieportArea:GetViewportSize().X
		contentHeight = scrollVieportArea:GetContentSize().X
	else
		vieportHeight = scrollVieportArea:GetViewportSize().Y
		contentHeight = scrollVieportArea:GetContentSize().Y
	end
	if vieportHeight <= 0 then return end
	if contentHeight <= 0 then return end

	local vieportToContentRatio = vieportHeight / contentHeight

	local vieportScreenPos = GetScreenPosition(scrollVieportArea)
	local contentScreenPos = GetScreenPosition(scrollContentArea)
	local visibleContentTopOffset = 0
	if isHorizontal then
		visibleContentTopOffset = mathAbs(contentScreenPos.Left - vieportScreenPos.Left)
	else
		visibleContentTopOffset = mathAbs(contentScreenPos.Top - vieportScreenPos.Top)
	end

	local contentLengthBase = contentHeight - vieportHeight
	local currentScrollRatio = 2 * visibleContentTopOffset / contentLengthBase
	
	return currentScrollRatio, vieportToContentRatio
end

local n_inkCompoundWidget = "inkCompoundWidget"
local function collectLookedWidgets(widget, lookedWidgets, className)
	if not widget then return lookedWidgets end
	if widget:IsA(className) then tableInsert(lookedWidgets, widget) end
	if widget:IsA(n_inkCompoundWidget) then
		local numChildren = widget:GetNumChildren()
		for i = 0, numChildren - 1 do collectLookedWidgets(widget:GetWidget(i), lookedWidgets, className) end
	end
	return lookedWidgets
end
function getWidgetsInWidgetByClassName(root, className)
	return collectLookedWidgets(root, {}, className)
end

local function collectLookedControllers(widget, lookedControllers, className, topCasesOnly)
	if not widget then return lookedControllers end
	local logicController = widget.logicController
	if IsDefined(logicController) and logicController:IsA(className) then
		tableInsert(lookedControllers, {widget = refWeak(widget), logicController = refWeak(logicController)})
		if topCasesOnly then return lookedControllers end
	end
	if widget:IsA(n_inkCompoundWidget) then
		local numChildren = widget:GetNumChildren()
		for i = 0, numChildren - 1 do collectLookedControllers(widget:GetWidget(i), lookedControllers, className, topCasesOnly) end
	end
	return lookedControllers
end
function getControllersInWidgetByClassName(root, className, topCasesOnly)
	return collectLookedControllers(root, {}, className, topCasesOnly)
end

function getTopWigetByName(widget, lookedWidgetName);
	if type(widget) ~= 'userdata' then return end;
	if type(lookedWidgetName) ~= 'string' then return end
	local nextTopWidget = widget;
	local loopBreaker = 50;
	while IsDefined(nextTopWidget) and widget:IsA(n_inkCompoundWidget) do;
		if nextTopWidget.name.value == lookedWidgetName then return nextTopWidget end
		loopBreaker = loopBreaker - 1
		if loopBreaker < 1 then return end;
		nextTopWidget = nextTopWidget.parentWidget;
		if nextTopWidget then widget = nextTopWidget end;
	end;
	if widget.name.value == lookedWidgetName then return widget end
end;

local getGameMainColor = {}
getGameMainColor["MainColors.White"] = function() return HDRColor.new({Red = 1, Green = 1, Blue = 1, Alpha = 1}) end
getGameMainColor["MainColors.ActiveWhite"] = function() return HDRColor.new({Red = 1.5, Green = 1.5, Blue = 1.5, Alpha = 1}) end
getGameMainColor["MainColors.Red"] = function() return HDRColor.new({Red = 1.176100, Green = 0.380900, Blue = 0.347600, Alpha = 1}) end
getGameMainColor["MainColors.ActiveRed"] = function() return HDRColor.new({Red = 1.369800, Green = 0.443700, Blue = 0.404900, Alpha = 1}) end
getGameMainColor["MainColors.MildRed"] = function() return HDRColor.new({Red = 0.682353, Green = 0.231373, Blue = 0.211765, Alpha = 1}) end
getGameMainColor["MainColors.DarkRed"] = function() return HDRColor.new({Red = 0.262745, Green = 0.086275, Blue = 0.094118, Alpha = 1}) end
getGameMainColor["MainColors.Blue"] = function() return HDRColor.new({Red = 0.368627, Green = 0.964706, Blue = 1, Alpha = 1}) end
getGameMainColor["MainColors.ActiveBlue"] = function() return HDRColor.new({Red = 0.158300, Green = 1.303300, Blue = 1.414200, Alpha = 1}) end
getGameMainColor["MainColors.MildBlue"] = function() return HDRColor.new({Red = 0.203922, Green = 0.568627, Blue = 0.592157, Alpha = 1}) end
getGameMainColor["MainColors.DarkBlue"] = function() return HDRColor.new({Red = 0.301961, Green = 0.690196, Blue = 0.647059, Alpha = 1}) end
getGameMainColor["MainColors.FaintBlue"] = function() return HDRColor.new({Red = 0.0901960805, Green = 0.172549024, Blue = 0.180392161, Alpha = 1}) end
getGameMainColor["MainColors.Neutral"] = function() return HDRColor.new({Red = 0.752941251, Green = 0.784313798, Blue = 0.811764777, Alpha = 1}) end
getGameMainColor["MainColors.Black"] = function() return HDRColor.new({Red = 0, Green = 0, Blue = 0, Alpha = 1}) end
getGameMainColor["MainColors.Fullscreen_PrimaryBackgroundDarkest"] = function() return HDRColor.new({Red = 0.054901965, Green = 0.054901965, Blue = 0.0901960805, Alpha = 1}) end

local function fetchColors()
	for k, f in pairs(getGameMainColor) do
		getGameMainColor[k] = f()
	end
end

function getGameColor(colorName)
	if type(colorName) ~= 'string' then return end
	local getColor = getGameMainColor[colorName]
	if type(getColor) == 'userdata' then return getColor end
	if type(getColor) ~= 'function' then return end
	return getColor()
end

function setWidgetTintColorByStyleName(widget, styleName)
	if not widget then return end
	if not widget.style then return end
	local dataType = type(styleName)
	if dataType == 'string' then
		if not (cNameNew(styleName).value ~= "") then return end -- psiberx performance tip
	elseif dataType == 'userdata' then
		if type(styleName.value) ~= 'string' then return end
		if not isStringValid(styleName.value) then return end
	else return end

	widget:BindProperty(n_tintColor, styleName)
	return true
end

local function clampF(input, min, max)
	return mathMax(min, mathMin(max, input))
end
local function clamp(input, min, max)
	return mathMax(min, mathMin(max, mathFloor(input)))
end
function setWidgetTextLabelColor(label, labelTextColorStyle, highLight)
	if setWidgetTintColorByStyleName(label, labelTextColorStyle) then return end
	if not label then return end

	if type(labelTextColorStyle) == 'number' then
		if labelTextColorStyle == 2 then labelTextColorStyle = "MainColors.White"
		elseif labelTextColorStyle == 1 then labelTextColorStyle = "MainColors.Blue"
		else labelTextColorStyle = "MainColors.Red" end
	elseif type(labelTextColorStyle) == 'userdata' then
		labelTextColorStyle = labelTextColorStyle.value
		if type(labelTextColorStyle) ~= 'string' then return end
	end

	local labelColor = getGameColor(labelTextColorStyle)
	if not labelColor then return end

	if type(highLight) ~= 'number' then highLight = 1 else highLight = clampF(highLight, 0, 2) end
	if highLight ~= 1 then
		labelColor.Red = labelColor.Red * highLight
		labelColor.Green = labelColor.Green * highLight
		labelColor.Blue = labelColor.Blue * highLight
	end

	label:SetTintColor(labelColor)
end
local textVerticalAlignmentCenter
local textHorizontalAlignmentCenter
local textHorizontalAlignmentLeft
local enumNew, Vector2new
function createButton(name, text, fontSize, buttonSize, anchorPoint, labelTextColorStyle, isUpperCase) -- (c)psiberx
	local button = inkCanvas.new()
	button:SetName(name) cNameAdd(name)
	if type(fontSize) ~= 'number' or fontSize < 10 then fontSize = 48 end
	if type(buttonSize) == 'table' and type(buttonSize[1]) == 'number' and type(buttonSize[2]) == 'number' then
		local x = clamp(buttonSize[1], 100, 1000)
		local y = clamp(buttonSize[2], 50, 500)
		button:SetSize(x, y)
	else
		button:SetSize(400, 100)
	end
	if type(anchorPoint) == 'table' and type(anchorPoint[1]) == 'number' and type(anchorPoint[2]) == 'number' then
		local x = clampF(anchorPoint[1], 0, 1)
		local y = clampF(anchorPoint[2], 0, 1)
		button:SetAnchorPoint(Vector2new({ X = x, Y = y }))
	else
		button:SetAnchorPoint(Vector2new({ X = 0.5, Y = 0.5 }))
	end
	button:SetInteractive(true)

	local bg = inkImage.new()
	bg:SetName('bg')
	bg:SetAtlasResource(atlas_shapes_sync_ResRef)
	bg:SetTexturePart('cell_bg')
	bg:SetStyle(fullscreen_main_colors_ResRef)
	bg:BindProperty(n_tintColor, n_MainColorsFullscreenPrimaryBackgroundDarkest)
	bg:SetOpacity(0.8)
	bg:SetAnchor(inkEAnchorFill)
	bg.useNineSliceScale = true
	bg.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	bg:Reparent(button, -1)

	local fill = inkImage.new()
	fill:SetName('fill')
	fill:SetAtlasResource(atlas_shapes_sync_ResRef)
	fill:SetTexturePart('cell_bg')
	fill:SetStyle(fullscreen_main_colors_ResRef)
	fill:BindProperty(n_tintColor, n_MainColorsBlue)
	fill:SetOpacity(0.0)
	fill:SetAnchor(inkEAnchorFill)
	fill.useNineSliceScale = true
	fill.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	fill:Reparent(button, -1)

	local checkMark = inkImage.new()
	checkMark:SetName('check_mark_icon')
	checkMark:SetAtlasResource(mappin_icons_ResRef)
	checkMark:SetTexturePart('completed')
	checkMark:SetStyle(fullscreen_main_colors_ResRef)
	setWidgetTextLabelColor(checkMark, labelTextColorStyle)
	checkMark:SetOpacity(0.0)
	checkMark:SetAnchor(inkEAnchorCenterLeft)
	checkMark:SetAnchorPoint(Vector2new({ X = 0, Y = 0.5 }))
	local vsize = fontSize
	local leftMargin = mathFloor(fontSize * 0.2)
	checkMark:SetWidth(vsize)
	checkMark:SetHeight(vsize)
	checkMark:SetMargin(leftMargin , 0, leftMargin, 0)
	checkMark:Reparent(button, -1)

	local frame = inkImage.new()
	frame:SetName('frame')
	frame:SetAtlasResource(atlas_shapes_sync_ResRef)
	frame:SetTexturePart('cell_fg')
	frame:SetStyle(fullscreen_main_colors_ResRef)
	frame:BindProperty(n_tintColor, n_MainColorsBlue)
	frame:SetOpacity(0.3)
	frame:SetAnchor(inkEAnchorFill)
	frame.useNineSliceScale = true
	frame.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	frame:Reparent(button, -1)

	local label = inkText.new()
	label:SetName('label')
	label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	label:SetFontStyle('Semi-Bold')
	label:SetFontSize(fontSize)
	if isUpperCase then label:SetLetterCase(textLetterCase.UpperCase) end
	label:SetStyle(fullscreen_main_colors_ResRef)
	setWidgetTextLabelColor(label, labelTextColorStyle)
	label:SetAnchor(inkEAnchorFill)
	label:SetHorizontalAlignment(textHorizontalAlignmentCenter)
	label:SetVerticalAlignment(textVerticalAlignmentCenter)
	label:SetText(text)
	label:Reparent(button, -1)

	local newSize = button:GetSize()
	if userSettings.hideCheckMarkIcon then
		newSize.X = newSize.X - mathFloor(fontSize * 0.75)
	else
		newSize.X = newSize.X - RoundF(fontSize * 1.75)
	end
	for i = 0, 5 do
		local enumName = enumValueToString("textOverflowPolicy", i)
		if enumName and stringLen(enumName) > 0 then
			local labelName = label.name.value.."."..enumName cNameAdd(labelName)
			local label = inkText.new()
			label:SetVisible(false)
			label:SetName(labelName)
			label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
			label:SetFontStyle('Semi-Bold')
			label:SetFontSize(fontSize)
			if isUpperCase then label:SetLetterCase(textLetterCase.UpperCase) end
			label:SetStyle(fullscreen_main_colors_ResRef)
			setWidgetTextLabelColor(label, labelTextColorStyle)
			label:SetAnchor(inkEAnchorFill)
			label.textHorizontalAlignment = textHorizontalAlignmentLeft
			label:SetVerticalAlignment(textVerticalAlignmentCenter)
			label:SetText(text)
			label.fitToContent = false
			label:SetSizeRule(inkESizeRule.Fixed)
			label:SetSize(newSize)
			label.textOverflowPolicy = enumNew("textOverflowPolicy", i)
			label:Reparent(button, -1)
		end
	end
	return button, label
end

function createTextLabel(name, text, fontSize, buttonSize, anchorPoint, labelTextColorStyle, isUpperCase) -- based on psiberx snippets
	local label = inkText.new()
	label:SetName(name) cNameAdd(name)
	if type(buttonSize) == 'table' and type(buttonSize[1]) == 'number' and type(buttonSize[2]) == 'number' then
		local x = clamp(buttonSize[1], 100, 1000)
		local y = clamp(buttonSize[2], 50, 500)
		label:SetSize(x, y)
	else
		label:SetSize(400, 100)
	end
	if type(anchorPoint) == 'table' and type(anchorPoint[1]) == 'number' and type(anchorPoint[2]) == 'number' then
		local x = clampF(anchorPoint[1], 0, 1)
		local y = clampF(anchorPoint[2], 0, 1)
		label:SetAnchorPoint(Vector2new({ X = x, Y = y }))
	else
		label:SetAnchorPoint(Vector2new({ X = 0, Y = 0 }))
	end

	label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	label:SetFontStyle('Semi-Bold')
	if type(fontSize) == 'number' then
		label:SetFontSize(fontSize)
	else
		label:SetFontSize(48)
	end
	if isUpperCase then label:SetLetterCase(textLetterCase.UpperCase) end
	label:SetStyle(fullscreen_main_colors_ResRef)
	setWidgetTextLabelColor(label, labelTextColorStyle)
	label:SetAnchor(inkEAnchorFill)
	label:SetHorizontalAlignment(textHorizontalAlignmentLeft)
	label:SetVerticalAlignment(textVerticalAlignmentCenter)
	label:SetText(text)

	local newSize = button:GetSize()
	newSize.X = newSize.X - RoundF(fontSize * 1.75)
	for i = 0, 5 do
		local enumName = enumValueToString("textOverflowPolicy", i)
		if enumName and stringLen(enumName) > 0 then
			local labelName = label.name.value.."."..enumName cNameAdd(labelName)
			local label = inkText.new()
			label:SetVisible(false)
			label:SetName(labelName)
			label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
			label:SetFontStyle('Semi-Bold')
			label:SetFontSize(fontSize)
			if isUpperCase then label:SetLetterCase(textLetterCase.UpperCase) end
			label:SetStyle(fullscreen_main_colors_ResRef)
			setWidgetTextLabelColor(label, labelTextColorStyle)
			label:SetAnchor(inkEAnchorFill)
			label.textHorizontalAlignment = textHorizontalAlignmentLeft
			label:SetVerticalAlignment(textVerticalAlignmentCenter)
			label:SetText(text)
			label.fitToContent = false
			label:SetSizeRule(inkESizeRule.Fixed)
			label:SetSize(newSize)
			label.textOverflowPolicy = enumNew("textOverflowPolicy", i)
			label:Reparent(button, -1)
		end
	end

	return label
end

function createBottomBorderLineWithMargin(name, marginTop, marginBottom, width, tintColorStyle) -- based on psiberx snippets
	local border = inkBorderWidget.new()
	border:SetName(name) cNameAdd(name)

	if type(width) == 'number' and width > 0 then border:SetSize(width, 2) else border:SetSize(1000, 2) end
	border.thickness = 2
	border:SetRenderTransformPivot(Vector2new({ X = 0, Y = 0.5 }))

	border:SetOpacity(0.047)
	border:SetStyle(fullscreen_main_colors_ResRef)
	if tintColorStyle then border:BindProperty(n_tintColor, tintColorStyle) else border:BindProperty(n_tintColor, n_MainColorsBlue) end

	local layout = inkWidgetLayout.new()
	layout.anchor = inkEAnchorBottomFillHorizontaly
	if type(marginTop) ~= 'number' then marginTop = 30 end
	if type(marginBottom) ~= 'number' then marginBottom = 60 end
	layout.margin = inkMargin.new({left = 0, top = marginTop, right = 0, bottom = marginBottom})
	border:SetLayout(layout)
	return border
end

function widgetDataSupportInit()
	inkEAnchorTopLeft = inkEAnchor.TopLeft
	inkEAnchorLeftFillVerticaly = inkEAnchor.LeftFillVerticaly
	inkEAnchorTopRight = inkEAnchor.TopRight
	inkEAnchorFill = inkEAnchor.Fill
	inkEAnchorCenterLeft = inkEAnchor.CenterLeft
	inkEAnchorBottomFillHorizontaly = inkEAnchor.BottomFillHorizontaly
	enumValueToString = EnumValueToString
	textVerticalAlignmentCenter = textVerticalAlignment.Center
	textHorizontalAlignmentCenter = textHorizontalAlignment.Center
	textHorizontalAlignmentLeft = textHorizontalAlignment.Left
	enumNew = Enum.new
	Vector2new = Vector2.new
	n_inkCompoundWidget = n"inkCompoundWidget"
	n_inkTextWidget = n"inkTextWidget"
	n_inkScrollAreaWidget = n"inkScrollAreaWidget"
	cNameAdd = CName.add
	cNameAdd("selectionListAreaWidget")
	cNameAdd("check_mark_icon")
	cNameAdd("switch_icon")
	n_SettingsSelectorControllerBool = n"SettingsSelectorControllerBool"
	fetchColors()
end

return {modName = modName, modVer = modVer, modAuthorName = modAuthorName, isSortingEnabled = function() return userSettings.enableModSorting end}
