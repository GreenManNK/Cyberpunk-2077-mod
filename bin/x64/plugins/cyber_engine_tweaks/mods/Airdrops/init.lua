-- Mar 26, 2026 by anygoodname
modVer='v1.3.0'
modName='Airdrops'
modAuthorName='anygoodname'

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
You can use the mod code and files to learn how to code this game mods and improve your skills.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

-- DO NOT TRANSLATE THIS FILE!
-- Translation support may be added in future releases.

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

local Ref = require("Ref")
if not Ref then
	printError(modName, modVer..":", "Ref.lua file is missing or corrupted. This mod is disabled now.")
	return
end
local refWeak = Ref.Weak

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

if cetVer < 1.26 then
	printError(modName, modVer..":", "is not compatible with this game version. This mod is disabled now.")
	return
end

local userSettings = {filename = 'mod_user_settings.json', enableModFeatures = true, showMappins = true, fixDOAairdrops = true, showHiddenAirdropDiscoveryNotifications = true}
local defaultUserSettings
local nativeSettings, isUsingNativeSettings 
local nativeSettingsOptions = {}
local nativeSettingsSubcategoryPaths = {}
local questsSystem, mappinSystem, journalManager
local n, t
local containerMappinData
local GameFindEntityByID
local GameGetSystemRequestsHandler
local isModDisabled = false
local isDebug = false
local isPacificaTyphoonModActive = false
local payload

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

defaultUserSettings = cloneTable(userSettings)

local excludeKeys = {isCheckBox = true, isButton = true, isTextWrapped = true}
local uiDefaultStrings = {
	exportOrder = {"cetUiStrings", "nuiUiStrings"},
	cetUiStrings = {
		modDisplayName = "Airdrops",
		hiddenAirdropDiscoveryNotification = "##COUNT## out of ##TOTAL## hidden Airdrops discovered.",
		settingsView = {
				exportOrder = {'questStatus', 'clickButtonHeader','enableModFeatures', 'showMappins', 'showHiddenAirdropDiscoveryNotifications', 'fixDOAairdrops'
			},
			questStatus = {titleInactive = "Airdrops quest is inactive now.", titleActive = "Airdrops quest is active now.", titlePaused = "Airdrops quest is paused now."},
			clickButtonHeader = {title = "Click a button to change settings:"},
			enableModFeatures = {isButton = true, title = "Enable Mod", titleIsEnabled = "Mod is Enabled", titleIsDisabled = "Mod is Disabled", tooltips = "Enable or disable the functionality of this mod."},
			showMappins = {isButton = true, title = "Show Markers", titleIsEnabled = "Show Markers is ON", titleIsDisabled = "Show Markers is OFF", tooltips = "Enable or disable showing navigation markers."},
			showHiddenAirdropDiscoveryNotifications = {isButton = true, title = "Show Discovery Notifications", titleIsEnabled = "Show Discovery Notifications is ON", titleIsDisabled = "Show Discovery Notifications is OFF", tooltips = "Show hidden Airdrop discovery on-screen notifications."},
			fixDOAairdrops = {isButton = true, title = "Fix DOA Airdrops", titleIsEnabled = "Fix DOA Airdrops is ON", titleIsDisabled = "Fix DOA Airdrops is OFF", tooltips = "Enable or disable DOA Airdrops fix."},
			resetAirdrops = {isButton = true, title = "Reset Airdrops", tooltips = "Reset Airdrops quest to start a new round.\nNote: this will also despawn currently spawned airdrop scene."},
		},
	},
	nuiUiStrings = {
		modDisplayName = "Airdrops",
		hiddenAirdropDiscoveryNotification = "##COUNT##/##TOTAL## hidden Airdrops discovered.",
		settingsView = {
				exportOrder = {'generalSettingsHeader', 'enableModFeatures', 'showMappins', 'showHiddenAirdropDiscoveryNotifications', 'fixDOAairdrops'
			},
			generalSettingsHeader = 'General settings:',
			enableModFeatures = {isButton = true, title = "Enable Mod", tooltips = "Enable or disable the functionality of this mod."},
			showMappins = {isButton = true, title = "Show Markers", tooltips = "Enable or disable showing navigation markers."},
			showHiddenAirdropDiscoveryNotifications =  {isButton = true, title = "Show Discovery Notifications", tooltips = "Show hidden Airdrop discovery on-screen notifications."},
			fixDOAairdrops = {isButton = true, title = "Fix DOA Airdrops", tooltips = "Enable or disable DOA Airdrops fix."},
		},
	},
}

local uiStrings = cloneTable(uiDefaultStrings)

function dumpTableToJson(inputTable, isCustomOrder, sortIfNoCustomOrderFound, excludeKeys)
	if type(excludeKeys) ~= 'table' then excludeKeys = nil end
	local function getTableTypeWithKeysOrCount(array, sort);
		local count = #array;
		local isOrderedArray = count > 0;
		if isOrderedArray then return false, count end;
		local keys = {};
		for key, value in pairs(array) do;
			local isKeyAllowed = true
			if excludeKeys then isKeyAllowed = not excludeKeys[key] end
			if isKeyAllowed then table.insert(keys, key) end
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
	modName = modName,
	modAuthorName = modAuthorName,
	modVer = modVer,
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
pcall(function() jsonDump = dumpTableToJson(exportTable, true, true, excludeKeys) end)
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
		print(modName, modVer..':', id, 'language files loaded.') end
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

local shouldUpdateCetWindow
function loadLocalizedStrings(updateUserSettings, forceSettingsUpdate)
	currentUiLanguage = getGameUILanguage(updateUserSettings, forceSettingsUpdate)

	if type(currentUiLanguage) ~= 'string' then return end
	uiStrings = cloneTable(uiDefaultStrings)
	
	local newStringsSet = languages[currentUiLanguage]
	if type(newStringsSet) ~= 'table' then return end

	local isAnythingChanged = false
	for tableName, newTableData in pairs(newStringsSet) do
		if type(newTableData) and tableName == "uiStrings" then
			local replacedTableData, result = replaceTableEntries(uiStrings, newTableData, 'string', false)
			if result then
				uiStrings = replacedTableData
				isAnythingChanged = true
			end
		end
	end
	if isAnythingChanged and isInitialized then shouldUpdateCetWindow = true setupNativeSettings(true) end
end

loadLocalizedStrings()

function setupNativeSettings(forceNew)
	isUsingNativeSettings = false
	nativeSettings = nativeSettings or GetMod("nativeSettings")
	if not nativeSettings then return end
	if type(uiStrings) ~= 'table' then return end
	local modPath = "/"..modName -- do not change modName!

	nativeSettingsSubcategoryPaths = {general_settings = modPath.."/general_settings"}

	local nativeSettingsDisplayName = uiStrings.nuiUiStrings.modDisplayName
	if forceNew and nativeSettings.pathExists(modPath) then
		if type(nativeSettingsSubcategoryPaths) == 'table' then
			for _, path in pairs(nativeSettingsSubcategoryPaths) do
				nativeSettings.removeSubcategory(path)
			end
		end
		local path = modPath:gsub("/", "")
		nativeSettings.data[path] = nil
	end

	isUsingNativeSettings = true
	if not nativeSettings.fromMods then return end
	if not nativeSettings.pathExists(modPath) then nativeSettings.addTab(modPath, nativeSettingsDisplayName) end
	if nativeSettings.pathExists(modPath) then isUsingNativeSettings = true else isUsingNativeSettings = false return end

	local buttonTitle, buttonTooltips = '', ''
	local buttonsPath = nativeSettingsSubcategoryPaths.general_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.settingsView.generalSettingsHeader)

	buttonTitle = uiStrings.nuiUiStrings.settingsView.enableModFeatures.title
	buttonTooltips = uiStrings.nuiUiStrings.settingsView.enableModFeatures.tooltips
	nativeSettingsOptions.enableModFeatures = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.enableModFeatures, defaultUserSettings.enableModFeatures, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		local isStateChanged = userSettings.enableModFeatures ~= newState
		userSettings.enableModFeatures = newState
		if isStateChanged then
			saveUserSettings()
			payload = function() setupNativeSettings(true) payload = nil end
		end
	end)

	if userSettings.enableModFeatures then
		buttonTitle = uiStrings.nuiUiStrings.settingsView.showMappins.title
		buttonTooltips = uiStrings.nuiUiStrings.settingsView.showMappins.tooltips
		nativeSettingsOptions.showMappins = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.showMappins, defaultUserSettings.showMappins, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = userSettings.showMappins ~= newState
			userSettings.showMappins = newState
			if isStateChanged then
				saveUserSettings()
			end
		end)

		buttonTitle = uiStrings.nuiUiStrings.settingsView.showHiddenAirdropDiscoveryNotifications.title
		buttonTooltips = uiStrings.nuiUiStrings.settingsView.showHiddenAirdropDiscoveryNotifications.tooltips
		nativeSettingsOptions.showHiddenAirdropDiscoveryNotifications = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.showHiddenAirdropDiscoveryNotifications, defaultUserSettings.showHiddenAirdropDiscoveryNotifications, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = userSettings.showHiddenAirdropDiscoveryNotifications ~= newState
			userSettings.showHiddenAirdropDiscoveryNotifications = newState
			if isStateChanged then
				saveUserSettings()
			end
		end)

		buttonTitle = uiStrings.nuiUiStrings.settingsView.fixDOAairdrops.title
		buttonTooltips = uiStrings.nuiUiStrings.settingsView.fixDOAairdrops.tooltips
		nativeSettingsOptions.fixDOAairdrops = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, userSettings.fixDOAairdrops, defaultUserSettings.fixDOAairdrops, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			local isStateChanged = userSettings.fixDOAairdrops ~= newState
			userSettings.fixDOAairdrops = newState
			if isStateChanged then
				saveUserSettings()
			end
		end)
	end
end

function isAirdropsQuestActive()
	if questsSystem:GetFactStr("codex_airdrop") > 0 then return true end
	if questsSystem:GetFactStr("sa_ep1_3_intro") > 0 then return true end
	if questsSystem:GetFactStr("mr_hands_dogtown_introduced") < 1 then return end
	if questsSystem:GetFactStr("ep1_airdrop_cooldown") > 0 then return true end
end
function isAirdropsQuestPaused()
	return questsSystem:GetFactStr("ep1_airdrop_pause") > 0
end

local airdrops = {
	sa_ep1_3 = {tr = "#sa_ep1_3_tr", sitePos = {-2258.8552, -2849.0923, 115.79335},
		facts = {},
		containers = {
			{
				entIdHash = 10931971937174384446ULL,
				pos = {-2258.8552, -2849.0923, 115.79335},
				hasCustomLootTables = true,
			},
		},
	},
	sa_ep1_30 = {tr = "#sa_ep1_30_tr", sitePos = {-2090.2036, -2785.0222, 83.5736},
		facts = {var_custom = "sa_ep1_30_var_1_custom", var_doa_fixed = "sa_ep1_30_var_1_doa_fixed"},
		containers = {
			{
				entIdHash = 16253725649607431953ULL,
				pos = {-2079.466, -2747.267, 83.7289},
			},
			{
				entIdHash = 1323092382361778613ULL,
				pos = {-2094.4841, -2790.6401, 83.52692},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 10032399511828645261ULL,
				pos = {-2069.5615, -2758.5134, 82.67775},
			},
			{
				entIdHash = 12395262258817615748,
				pos = {-2094.48413, -2790.64014, 83.5269165},
			},
		},
	},
	sa_ep1_31 = {tr = "#sa_ep1_31_tr", sitePos = {-2248.250, -2839.500, 107.950},
		facts = {},
		containers = {
			{
				entIdHash = 13265126044146694840ULL,
				pos = {-2236.5796, -2839.6216, 103.88074},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 2337762191295387104ULL,
				pos = {-2235.4253, -2857.6355, 108.00548},
			},
		},
	},
	sa_ep1_32 = {tr = "#sa_ep1_32_tr", sitePos = {-2167.4294, -2576.0014, 20.4013},
		facts = {},
		containers = {
			{
				entIdHash = 15196022487308553981ULL,
				pos = {-2181.056, -2552.9585, 23.216469},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 1510598181086198717ULL,
				pos = {-2197.1794, -2568.1616, 16.833412},
			},
			{
				entIdHash = 7791574712649971679ULL,
				pos = {-2185.6028, -2566.53, 18.954788},
			},
			{
				entIdHash = 7751071885102337184ULL,
				pos = {-2185.6028, -2566.53, 18.954788},
			},
		},
	},
	sa_ep1_33 = {tr = "#sa_ep1_33_tr", sitePos = {-1963.510, -2622.180, 48.890},
		facts = {},
		containers = {
			{
				entIdHash = 17097819274191383329ULL,
				pos = {-1973.6611, -2625.8105, 47.383606},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 4663313385132495977ULL,
				pos = {-1979.1892, -2623.4456, 48.854836},
			},
		},
	},
	sa_ep1_34 = {tr = "#sa_ep1_34_tr", sitePos = {-2095.0576, -2981.7266, 108.0117},
		facts = {var_custom = "sa_ep1_34_custom", var_doa_fixed = "sa_ep1_34_var_doa_fixed"},
		containers = {
			{
				entIdHash = 2648987305614749327ULL,
				pos = {-2086.3792, -3009.7798, 116.74643},
			},
			{
				entIdHash = 11949621142978635070ULL,
				pos = {-2097.8928, -2977.4834, 107.973145},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 3596146082904893375ULL,
				pos = {-2119.4502, -2985.11304, 107.970009},
			},
			{
				entIdHash = 17097897848168550914ULL,
				pos = {-2119.4502, -2985.11304, 107.970009},
			},
			{
				entIdHash = 2097707902067955045ULL,
				pos = {-2119.4502, -2985.11304, 107.970009},
			},
		},
	},
	sa_ep1_35 = {tr = "#sa_ep1_35_tr", sitePos = {-1862.500, -2865.720, 97.780},
		facts = {var_custom = "sa_ep1_35_custom", var_doa_fixed = "sa_ep1_35_var_doa_fixed"},
		containers = {
			{
				entIdHash = 6486150295692841312ULL,
				pos = {-1865.0718, -2861.0745, 97.668106},
			},
			{
				entIdHash = 17229285282453691305ULL,
				pos = {-1814.617, -2850.1753, 101.41374},
			},
			{
				entIdHash = 3472589734590359608ULL,
				pos = {-1847.2537, -2875.1602, 97.6664},
			},
			{
				entIdHash = 16382697483776782475ULL,
				pos = {-1847.25366, -2875.16016, 97.6663895},
			},
			{
				entIdHash = 11189395097756102866ULL,
				pos = {-1847.25366, -2875.16016, 97.6663895},
				hasCustomLootTables = true
			},
		},
	},
	sa_ep1_36 = {tr = "#sa_ep1_36_tr", sitePos = {-1396.500, -2320.500, 72.160},
		facts = {var_custom = "sa_ep1_36_var_2_custom", var_doa_fixed = "sa_ep1_36_var_2_doa_fixed"},
		containers = {
			{
				entIdHash = 14556900561449532718ULL,
				pos = {-1370.9806, -2286.108, 75.283615},
			},
			{
				entIdHash = 15745540439379084343ULL,
				pos = {-1383.0371, -2302.4119, 72.29692},
			},
			{
				entIdHash = 16797132514103417700ULL,
				pos = {-1389.96924, -2294.89429, 72.1736145},
			},
			{
				entIdHash = 3734888537922157838ULL,
				pos = {-1391.9723, -2295.2292, 72.31259},
				hasCustomLootTables = true,
			},
		},
	},
	sa_ep1_37 = {tr = "#sa_ep1_37_tr", sitePos = {-1759.9035, -2643.4169, 45.0115},
		facts = {var_custom = "sa_ep1_37_custom", var_doa_fixed = "sa_ep1_37_var_doa_fixed"},
		containers = {
			{
				entIdHash = 1636510944076367373ULL,
				pos = {-1753.7529, -2651.4395, 44.773567},
			},
			{
				entIdHash = 801478193091693422ULL,
				pos = {-1719.4899, -2637.1873, 60.539345},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 3686939281692307481ULL,
				pos = {-1719.4899, -2637.1873, 60.539345},
			},
			{
				entIdHash = 12843337945534930468ULL,
				pos = {-1782.5546, -2668.6763, 54.340797},
			},
		},
	},
	sa_ep1_38 = {tr = "#sa_ep1_38_tr", sitePos = {-1818.4071, -2628.2407, 40.006},
		facts = {},
		containers = {
			{
				entIdHash = 16956574182743301400ULL,
				pos = {-1819.5472, -2631.3271, 39.915314},
				hasCustomLootTables = true,
				isNoSmokeContainer = true,
			},
			{
				entIdHash = 1248234896555724859ULL,
				pos = {-1844.5658, -2648.7505, 39.685135},
			},
			{
				entIdHash = 12801877970709833463ULL,
				pos = {-1809.2041, -2627.8376, 44.154778},
			},
		},
	},
	sa_ep1_39 = {tr = "#sa_ep1_39_tr", sitePos = {-1811.359, -2524.0515, 48.1461},
		facts = {},
		containers = {
			{
				entIdHash = 11765091467676809224ULL,
				pos = {-1816.1954, -2522.88, 50.023926},
				hasCustomLootTables = true,
			},
			{
				entIdHash = 7982573690041864516ULL,
				pos = {-1804.6478, -2539.0588, 50.13649},
			},
			{
				entIdHash = 11030165626955445129ULL,
				pos = {-1824.5923, -2511.0845, 49.90531},
			},
		},
	},
	sa_ep1_300 = {tr = "#sa_ep1_300_tr", sitePos = {-1790.2465, -2217.8442, 56.003128},
		facts = {},
		containers = {
			{
				entIdHash = 1155472759561277690ULL,
				pos = {-1790.2465, -2217.8442, 56.003128},
			},
		},
	},
	sa_ep1_301 = {tr = "#sa_ep1_301_tr", sitePos = {-2089.25, -2577.5002, 70.31},
		facts = {last_discovered = "sa_ep1_301_last_discovered"},
		containers = {
			{
				entIdHash = 13947792384174939132ULL,
				pos = {-2089.25, -2577.5002, 70.31},
				isQuestImportantNotLootable = true,
				isNoSmokeContainer = true,
				linkedDeviceEntIdHash = 14069334285529199241ULL,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					return true
				end,
			},
		},
	},
	sa_ep1_303 = {tr = "#sa_ep1_303_tr", sitePos = {-1909.8546, -2673.5635, 68.3521},
		facts = {},
		containers = {
			{
				entIdHash = 15799503660323919511ULL,
				pos = {-1909.8546, -2673.5635, 68.3521},
				hasCustomLootTables = true,
			},
		},
	},
	sa_ep1_304 = {tr = "#sa_ep1_304_tr", sitePos = {-1668.2197, -2450.6963, 78.129011},
		facts = {},
		containers = {
			{
				entIdHash = 16953352396772128421ULL,
				pos = {-1668.2197, -2450.6963, 78.129011},
				hasCustomLootTables = true,
			},
		},
	},
	sa_ep1_306 = {tr = "#sa_ep1_306_tr", sitePos = {-2065.2622, -2655.019, 64.374054},
		facts = {},
		containers = {
			{
				entIdHash = 17305056024546858235ULL,
				pos = {-2065.2622, -2655.019, 64.374054},
				hasCustomLootTables = true,
			},
		},
	},
	hidden_gems_airdrop_01 = {sitePos = {-1691.9333, -2468.9, 83.7512},
		facts = {is_looted = "ep1_hidden_gems_airdrop_01_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_airdrop_01_is_loot_notified"},
		isHiddenGem = true,
		isHandledByPacificaTyphoonMod = true,
		containers = {
			{
				entIdHash = 3071092429664160959ULL,
				pos = {-1690.0627, -2467.3643, 84.069565},
				isUnrelatedToQuests = true,
				isAlwaysSpawned = true,
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				isHandledByPacificaTyphoonMod = true,
				shouldShowMappinByEntId = function(entId)
					if isPacificaTyphoonModActive then return end
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					return true
				end
			},
		},
	},
	hidden_gems_airdrop_02 = {sitePos = {-1505.996, -2608.2959, 108.1862},
		facts = {is_looted = "ep1_hidden_gems_airdrop_02_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_airdrop_02_is_loot_notified"},
		isHiddenGem = true,
		isHandledByPacificaTyphoonMod = true,
		containers = {
			{
				entIdHash = 11980573429743598142ULL,
				pos = {-1503.5209, -2612.701, 108.1875},
				isUnrelatedToQuests = true,
				isAlwaysSpawned = true,
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				isHandledByPacificaTyphoonMod = true,
				shouldShowMappinByEntId = function(entId)
					if isPacificaTyphoonModActive then return end
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					return true
				end
			},
		},
	},
	hidden_gems_airdrop_03 = {sitePos = {-2227.3494, -2275.6169, 8.0273},
		facts = {is_looted = "ep1_hidden_gems_airdrop_03_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_airdrop_03_is_loot_notified"},
		isHiddenGem = true,
		containers = {
			{
				entIdHash = 12303184446451961946ULL,
				pos = {-2229.5125, -2274.060, 9.1201},
				isAlwaysSpawned = true,
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if questsSystem:GetFactStr("sts_ep1_10_active") < 1 then return end
					if questsSystem:GetFactStr("sts_ep1_10_done") > 0 then return end
					if questsSystem:GetFactStr("sts_ep1_10_finished") > 0 then return end
					if questsSystem:GetFactStr("sts_ep1_10_start") < 1 then return end
					if questsSystem:GetFactStr("sts_ep1_10_informant_talk") < 1 then return end
					return true
				end
			},
		},
	},
	hidden_gems_airdrop_04 = {sitePos = {-2033.93, -2545.4594, 40.32787},
		facts = {is_looted = "ep1_hidden_gems_airdrop_04_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_airdrop_04_is_loot_notified"},
		isHiddenGem = true,
		containers = {
			{
				entIdHash = 18418903730574305677ULL,
				pos = {-2034.4435, -2544.4229, 40.437653},
				isAlwaysSpawned = true,
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					return true
				end
			},
		},
	},
	hidden_gems_custom_airdrop_101 = {sitePos = {-2105.6220, -3047.0815, 142.4616},
		facts = {is_looted = "ep1_hidden_gems_custom_airdrop_101_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_custom_airdrop_101_is_loot_notified"},
		isHiddenGem = true,
		isCustomHiddenGem = true,
		containers = {
			{
				entIdHash = 10962968347658792468ULL,
				pos = {-2103.771, -3042.208, 142.131},
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				isCustomHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					if questsSystem:GetFactStr("sa_ep1_31_active") > 0 then return end
					if questsSystem:GetFactStr("sa_ep1_34_active") > 0 then return end
					return true
				end
			},
		},
	},
	hidden_gems_custom_airdrop_102 = {sitePos = {-2279.5288, -2617.3147, 35.8912},
		facts = {is_looted = "ep1_hidden_gems_custom_airdrop_102_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_custom_airdrop_102_is_loot_notified"},
		isHiddenGem = true,
		isCustomHiddenGem = true,
		containers = {
			{
				entIdHash = 16685315569729879917ULL,
				pos = {-2278.52588, -2614.62207, 35.8310013},
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				isCustomHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					if questsSystem:GetFactStr("sa_ep1_301") > 0 then return end
					if questsSystem:GetFactStr("sa_ep1_32") > 0 then return end
					return true
				end
			},
		},
	},
	hidden_gems_custom_airdrop_103 = {sitePos = {-2804.5298, -1828.319, -0.1872},
		facts = {is_looted = "ep1_hidden_gems_custom_airdrop_103_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_custom_airdrop_103_is_loot_notified"},
		isHiddenGem = true,
		isCustomHiddenGem = true,
		containers = {
			{
				entIdHash = 17817490050621259358ULL,
				pos = {-2805.563, -1827.463, -0.187},
				isProximityRangeLimited = true,
				isShortProximityRange = true,
				isHiddenGem = true,
				isCustomHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					return true
				end
			},
		},
	},
	hidden_gems_custom_airdrop_104 = {sitePos = {-1614.0049, -2167.74853, 55.5114},
		facts = {is_looted = "ep1_hidden_gems_custom_airdrop_104_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_custom_airdrop_104_is_loot_notified"},
		isHiddenGem = true,
		isCustomHiddenGem = true,
		containers = {
			{
				entIdHash = 2077049781162796511ULL,
				pos = {-1612.5103, -2165.8687, 55.5115},
				isProximityRangeLimited = true,
				isMediumProximityRange = true,
				isHiddenGem = true,
				isCustomHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					if questsSystem:GetFactStr("sa_ep1_300_active") > 0 then return end
					if questsSystem:GetFactStr("sa_ep1_304_active") > 0 then return end
					return true
				end
			},
		},
	},
	hidden_gems_custom_airdrop_105 = {sitePos = {-1379.432, -2778.032, 38.302},
		facts = {is_looted = "ep1_hidden_gems_custom_airdrop_105_is_looted", is_hidden_airdrop_loot_notified = "ep1_hidden_gems_custom_airdrop_105_is_loot_notified"},
		isHiddenGem = true,
		isCustomHiddenGem = true,
		containers = {
			{
				entIdHash = 15108555319767007784ULL,
				pos = {-1379.432, -2778.032, 38.302},
				isProximityRangeLimited = true,
				isMediumProximityRange = true,
				isHiddenGem = true,
				isCustomHiddenGem = true,
				shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					if not isAirdropsQuestActive() then return end
					return true
				end
			},
		},
	},
}

local containerLookupByEntIdHashStr = {}
local mappinLookupByIdValStr = {}
local containerLookupByLinkedDeviceEntIdHashStr = {}

function saveUserSettings()
	local jString = json.encode(userSettings)
	if jString then
		local file = io.open(userSettings.filename, "w")
		if file then
			file:write(jString)
			file:close()
		end
	end
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
	for k, val in pairs(userSettings) do
		local newVal = settings[k]
		local newValType = type(newVal)
		if newValType == 'boolean' and newValType == type(val) then userSettings[k] = newVal end
	end
	return true
end

local hiddenGemAirdrops = {}
local function getAvaliableHiddenGemAirdrops(includeCustomHiddenGems)
	hiddenGemAirdrops = {}
	for k, entry in pairs(airdrops) do
		if entry.isHiddenGem then
			if (not entry.isCustomHiddenGem) or (entry.isCustomHiddenGem and includeCustomHiddenGems) then
				table.insert(hiddenGemAirdrops, entry)
			end
		end
	end
end
local function getDiscoveredHiddenGemAirdropsStats()
	local cnt = 0
	local totalHiddenGemAirdrops = #hiddenGemAirdrops
	for i = 1, totalHiddenGemAirdrops do
		local entry = hiddenGemAirdrops[i]
		if entry.facts and entry.facts.is_looted and questsSystem:GetFactStr(entry.facts.is_looted) > 0 then cnt = cnt + 1 end
	end
	return cnt, totalHiddenGemAirdrops
end

local is_more_hidden_gems_mod_loaded
registerForEvent('onInit', function()
	GameGetSystemRequestsHandler = Game.GetSystemRequestsHandler
	journalManager = refWeak(Game.GetJournalManager())
	if not (journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry') and TweakDB:GetRecord("Character.bella")) then
		printError(modName, modVer..":", "Phantom Liberty DLC is not found. This mod is disabled now.")
		isModDisabled = true
		return
	end
	n = CName
	t = TweakDBID
	GameFindEntityByID = Game.FindEntityByID
	questsSystem = refWeak(Game.GetQuestsSystem())
	mappinSystem = refWeak(Game.GetMappinSystem())
	containerMappinData = createContainerLocationMappinData()
	isPacificaTyphoonModActive = type(GetMod("PacificaTyphoon")) == 'table'
	local result, data = pcall(function() initAirdropsData() end)
	if not result then
		printError(data)
		printError(modName, modVer..":", "Internal data is corrupted. This mod is disabled now.")
		isModDisabled = true
		return
	end

	loadUserSettings()
	local lastlanguageSelected = userSettings.lastLanguageSelected
	loadLocalizedStrings(true, true)
	if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end

	setupNativeSettings()
	is_more_hidden_gems_mod_loaded = ModArchiveExists("airdrops_more_hidden_gems_PhL_anygoodname_mods.archive")
	getAvaliableHiddenGemAirdrops(is_more_hidden_gems_mod_loaded)
	updateAllContainerMappins()
	setObservers()
	print(modName..': '..modVer, 'is initialized.')
end)

function initAirdropsData()
	for id, airdrop in pairs(airdrops) do
		airdrop.questid = id
		if not airdrop.isHiddenGem then
			airdrop.facts.active = id.."_active" 
			airdrop.facts.bespoke_done = id.."_bespoke_done"
			airdrop.facts.finished = id.."_finished"
			airdrop.facts.ignored = id.."_ignored"
			airdrop.facts.start = id.."_start"
			airdrop.facts.used = id.."_used"
		end
		airdrop.sitePos = Vector4.new(airdrop.sitePos[1], airdrop.sitePos[2], airdrop.sitePos[3], 1)
		if isDebug then print(airdrop.questid, 'Game.GetTeleportationFacility():Teleport(GetPlayer(), '..tostring(airdrop.sitePos)..', EulerAngles.new(0, 0, 0))') end
		airdrop.isSingleContainer = #airdrop.containers == 1
		for i, container in ipairs(airdrop.containers) do
			container.pos = Vector4.new(container.pos[1], container.pos[2], container.pos[3])
			container.mappinData = containerMappinData
			container.mappinId = setMappinToPosition(container.mappinData, container.pos)
			container.mappinIdVal = container.mappinId.value
			container.mappinIdValStr = tostring(container.mappinIdVal)
			removeMappin(container.mappinId) container.mappinId = nil
			container.entIdHashStr = tostring(container.entIdHash)
			container.entId = entEntityID.new({hash = container.entIdHash})
			container.isSpawned = function() return GameFindEntityByID(container.entId) end
			if type(container.shouldShowMappinByEntId) ~= 'function' then
				container.shouldShowMappinByEntId = function(entId)
					local handle = GameFindEntityByID(entId)
					if not handle then return end
					if handle:GetWorldPosition():IsZero() then return end
					if handle:IsEmpty() then return end
					return true
				end
			end
			container.shouldShowMappin = function() return container.shouldShowMappinByEntId(container.entId) end
			container.lookupEntry = {
				questid = airdrop.questid,
				entId = container.entId,
				entIdHash = container.entIdHash,
				entIdHashStr = container.entIdHashStr,
				mappinData = container.mappinData,
				isSpawned = container.isSpawned,
				shouldShowMappin = container.shouldShowMappin,
				pos = container.pos,
				hasCustomLootTables = container.hasCustomLootTables,
				isQuestImportantNotLootable = container.isQuestImportantNotLootable,
				isAlwaysSpawned = container.isAlwaysSpawned,
				isHiddenGem = container.isHiddenGem,
				isCustomHiddenGem = container.isCustomHiddenGem,
				container = container,
				airdrop = airdrop
				}
			containerLookupByEntIdHashStr[container.entIdHashStr] = container.lookupEntry
			mappinLookupByIdValStr[container.mappinIdValStr] = container.lookupEntry
			if container.linkedDeviceEntIdHash then
				container.linkedDeviceEntId = entEntityID.new({hash = container.linkedDeviceEntIdHash})
				container.linkedDeviceEntIdHashStr = tostring(container.linkedDeviceEntIdHash)
				containerLookupByLinkedDeviceEntIdHashStr[container.linkedDeviceEntIdHashStr] = container.lookupEntry
			end
		end
		airdrop.isActive = function() return questsSystem:GetFactStr(airdrop.facts.active) > 0 end
		airdrop.isUsed = function() return questsSystem:GetFactStr(airdrop.facts.used) > 0 end
		airdrop.isAnyContainerSpawned = function()
			for i, container in ipairs(airdrop.containers) do
				if GameFindEntityByID(container.entId) then return true end
			end
			return false
		end
	end
end

if isDebug and Codeware then
	function createNodeRefFromHash(hash)
		return HashToNodeRef(hash)
	end
else
	function createNodeRefFromHash(hash)
	end
end

function createContainerLocationMappinData()
	local pinData = MappinData.new()
	pinData.mappinType = t"Mappins.DefaultStaticMappin"
	pinData.variant = gamedataMappinVariant.RetrievingVariant
	pinData.visibleThroughWalls = true
	pinData.acive = true
	return pinData
end
function setMappinToPosition(pinData, pos)
	if type(pinData) ~= 'userdata' then return end
	if type(pos) ~= 'userdata' then return end
	return mappinSystem:RegisterMappin(pinData, pos)
end
function removeMappin(id)
	if type(id) ~= 'userdata' then return end
	mappinSystem:UnregisterMappin(id)
	return true
end
function updateAllContainerMappins(forceRemoveThisEntId)
	if not userSettings.enableModFeatures then removeAllContainerMappins() return end
	if not userSettings.showMappins then removeAllContainerMappins() return end
	for i, containerEntry in pairs(containerLookupByEntIdHashStr) do
		local shouldShowThisMappin = containerEntry.shouldShowMappin()
		if forceRemoveThisEntId and forceRemoveThisEntId == containerEntry.entId then shouldShowThisMappin = false forceRemoveThisEntId = nil end
		if shouldShowThisMappin then
			containerEntry.container.mappinId = setMappinToPosition(containerEntry.mappinData, containerEntry.pos)
		elseif type(containerEntry.container.mappinId) == 'userdata' then
			removeMappin(containerEntry.container.mappinId)
			containerEntry.container.mappinId = nil
		end
	end
end
function removeAllContainerMappins()
	for i, containerEntry in pairs(containerLookupByEntIdHashStr) do
		if type(containerEntry.container.mappinId) == 'userdata' then
			removeMappin(containerEntry.container.mappinId)
			containerEntry.container.mappinId = nil
		end
	end
end

registerForEvent('onShutdown', function()
	if not GetPlayer then return end
	removeAllContainerMappins()
end)

function resetAirdrops()
	if payload then return end
	if not GetPlayer() then return end
	local systemRequetsHandler = GameGetSystemRequestsHandler()
	if systemRequetsHandler:IsGamePaused() then  return end
	if systemRequetsHandler:IsPreGame() then return end
	local triggerTime = os.clock() + 0.001
	payload = function()
		if triggerTime > os.clock() then return end
		if questsSystem:GetFactStr("ep1_airdrop_pause") > 0 then payload = nil return end
		questsSystem:SetFactStr("ep1_airdrop_pause", 1)
		pcall(function()
			for i, airdrop in pairs(airdrops) do questsSystem:SetFactStr(airdrop.facts.used, 0) end
			removeAllContainerMappins()
		end)
		triggerTime = os.clock() + 0.5
		payload = function()
			if triggerTime > os.clock() then return end
			questsSystem:SetFactStr("ep1_airdrop_pause", 0)
			payload = nil
		end
	end
end

function isResetAllowed()
	if payload then return end
	if not GetPlayer() then return end
	local systemRequetsHandler = GameGetSystemRequestsHandler()
	if systemRequetsHandler:IsGamePaused() then return end
	if systemRequetsHandler:IsPreGame() then return end
	return isAirdropsQuestActive()
end

registerForEvent('onUpdate', function()
	if not payload then return end
	if not GetPlayer() then payload = nil return end
	payload()
end)
local stringGsub = string.gsub
function setObservers()
	local function isLookedAppearance(appName)
		local appName = appName.value
		if string.match(appName, "airdrop_container") then return true end
		if string.match(appName, "gadgets_case_small") then return true end
	end
	local discoveryAchievementNotificationMsg, lastMsgTxt
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
		if this:IsReplacer() then return end
		getAvaliableHiddenGemAirdrops(is_more_hidden_gems_mod_loaded)
		discoveryAchievementNotificationMsg = nil
		lastMsgTxt = nil
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
		setupNativeSettings(true)
	end)
	ObserveBefore('inkISystemRequestsHandler', 'RequestSaveUserSettings', function(this)
		if not GameGetSystemRequestsHandler():IsPreGame() then return end
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true, true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() setupNativeSettings(true) end
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
	local n_LootContainerObjectAnimatedByTransform = n"LootContainerObjectAnimatedByTransform"
	ObserveAfter("gameLootContainerBase", "DeterminGameplayRole", function(this)
		if not userSettings.enableModFeatures then return end
		if not this:IsA(n_LootContainerObjectAnimatedByTransform) then return end;
		if not isLookedAppearance(this:GetCurrentAppearanceName()) then return end
		updateAllContainerMappins()
	end)
	local gameGetBlackboardSystem = Game.GetBlackboardSystem()
	local getAllBlackboardDefsUI_Notifications = GetAllBlackboardDefs().UI_Notifications
	local getAllBlackboardDefsUI_NotificationsOnscreenMessage = getAllBlackboardDefsUI_Notifications.OnscreenMessage
	local n_discoveryAchievementNotificationEvtName = n"mod_airdrops_onscreen_notification_request" CName.add("mod_airdrops_onscreen_notification_request")
	local notifyEvt = FactChangedEvent.new({factName = n_discoveryAchievementNotificationEvtName})
	local delaySystem = refWeak(Game.GetDelaySystem())
	local function queueAchievementNotification(containerEntry, onDetach)
		lastMsgTxt = nil
		local notifiedFactName = containerEntry.airdrop.facts.is_hidden_airdrop_loot_notified
		if type(notifiedFactName) ~= 'string' then return end
		if questsSystem:GetFactStr(notifiedFactName) > 0 then return end
		questsSystem:SetFactStr(notifiedFactName, 1)
		if not userSettings.showHiddenAirdropDiscoveryNotifications then return end
		local player = GetPlayer()
		if not player then return end
		local discovered, total = getDiscoveredHiddenGemAirdropsStats()
		lastMsgTxt = uiStrings.nuiUiStrings.hiddenAirdropDiscoveryNotification
		lastMsgTxt = stringGsub(lastMsgTxt, '##COUNT##', tostring(discovered))
		lastMsgTxt = stringGsub(lastMsgTxt, '##TOTAL##', tostring(total))
		discoveryAchievementNotificationMsg = SimpleScreenMessage.new({isShown = true, duration = 6, message = lastMsgTxt, type = SimpleMessageType.Reveal})
		if onDetach then delaySystem:DelayEvent(player, notifyEvt, 1) return end
		delaySystem:DelayEvent(player, notifyEvt, 5)
	end
	ObserveAfter('PlayerPuppet', 'OnFactChangedEvent', function(this, evt)
		if not discoveryAchievementNotificationMsg then return end
		if not userSettings.showHiddenAirdropDiscoveryNotifications then discoveryAchievementNotificationMsg = nil return end
		if evt:GetFactName() ~= n_discoveryAchievementNotificationEvtName then return end
		gameGetBlackboardSystem:Get(getAllBlackboardDefsUI_Notifications):SetVariant(getAllBlackboardDefsUI_NotificationsOnscreenMessage, ToVariant(discoveryAchievementNotificationMsg), true)
		discoveryAchievementNotificationMsg = nil
	end)
	ObserveAfter('OnscreenMessageGameController', 'OnScreenMessageUpdate', function(this, value);
		if not lastMsgTxt then return end
		local msg = FromVariant(value)
		if not msg then return end
		local thisMsgTxt = msg.message
		if not thisMsgTxt then return end
		if lastMsgTxt ~= thisMsgTxt then return end
		lastMsgTxt = nil
		local player = GetPlayer()
		if not player then return end
		player:PlaySound("ui_jingle_quest_update")
	end)
	ObserveAfter("gameLootContainerBase", "OnDetach", function(this)
		if not userSettings.enableModFeatures then return end
		if not this:IsA(n_LootContainerObjectAnimatedByTransform) then return end;
		if not isLookedAppearance(this:GetCurrentAppearanceName()) then return end
		local entId = this:GetEntityID()
		local containerEntry = containerLookupByEntIdHashStr[tostring(entId.hash)]
		if not containerEntry then return end

		updateAllContainerMappins(entId)
		if containerEntry.isHiddenGem and containerEntry.airdrop.facts.is_looted and this:IsEmpty() then
			local isKnownAsLooted = questsSystem:GetFactStr(containerEntry.airdrop.facts.is_looted) > 0
			if not isKnownAsLooted then questsSystem:SetFactStr(containerEntry.airdrop.facts.is_looted, 1) queueAchievementNotification(containerEntry, true) end
			return 
		end
		if not userSettings.fixDOAairdrops then return end
		if not containerEntry.hasCustomLootTables then return end
		if containerEntry.isQuestImportantNotLootable then return end
		if not containerEntry.airdrop.facts.var_custom then return end
		if not this:IsEmpty() then return end
		if containerEntry.airdrop.facts.var_doa_fixed and questsSystem:GetFactStr(containerEntry.airdrop.facts.var_custom) < 1 then
			local val = questsSystem:GetFactStr(containerEntry.airdrop.facts.var_doa_fixed)
			questsSystem:SetFactStr(containerEntry.airdrop.facts.var_doa_fixed, val + 1)
			print(modName, modVer..":", containerEntry.questid, "DOA airdrop fixed.")
		end
		questsSystem:SetFactStr(containerEntry.airdrop.facts.var_custom, 1)
	end)

	ObserveAfter("gameLootContainerBase", "OnInventoryEmptyEvent", function(this)
		if not userSettings.enableModFeatures then return end
		if not this:IsA(n_LootContainerObjectAnimatedByTransform) then return end;
		if not isLookedAppearance(this:GetCurrentAppearanceName()) then return end
		local entId = this:GetEntityID()
		local containerEntry = containerLookupByEntIdHashStr[tostring(entId.hash)]
		if not containerEntry then return end
		if containerEntry.isQuestImportantNotLootable then return end
		if containerEntry.isHiddenGem and containerEntry.airdrop.facts.is_looted then
			local isKnownAsLooted = questsSystem:GetFactStr(containerEntry.airdrop.facts.is_looted) > 0
			if not isKnownAsLooted then questsSystem:SetFactStr(containerEntry.airdrop.facts.is_looted, 1) queueAchievementNotification(containerEntry) end
		end
		removeMappin(containerEntry.container.mappinId) containerEntry.container.mappinId = nil
	end)
	ObserveAfter("gameLootContainerBase", "OnInventoryFilledEvent", function(this)
		if not userSettings.enableModFeatures then return end
		if not userSettings.showMappins then return end
		if not this:IsA(n_LootContainerObjectAnimatedByTransform) then return end;
		if not isAirdropsQuestActive() then return end
		if not isLookedAppearance(this:GetCurrentAppearanceName()) then return end
		local containerEntry = containerLookupByEntIdHashStr[tostring(this:GetEntityID().hash)]
		if not containerEntry then return end
		if containerEntry.shouldShowMappin() then containerEntry.container.mappinId = setMappinToPosition(containerEntry.mappinData, containerEntry.pos) return end
		if containerEntry.isQuestImportantNotLootable then return end
		removeMappin(containerEntry.container.mappinId) containerEntry.container.mappinId = nil
	end)
	local n_Computer = n"Computer"
	Observe("Computer", "OnRequestDocumentWidgetUpdate", function(this)
		if not userSettings.enableModFeatures then return end
		if not userSettings.showMappins then return end
		if not this:IsExactlyA(n_Computer) then return end
		if not isAirdropsQuestActive() then return end
		local containerEntry = containerLookupByLinkedDeviceEntIdHashStr[tostring(this:GetEntityID().hash)]
		if not containerEntry then return end
		if not containerEntry.isQuestImportantNotLootable then return end
		removeMappin(containerEntry.container.mappinId) containerEntry.container.mappinId = nil
	end)
	ObserveAfter("WorldMapMenuGameController",  "UpdateTooltip", function(this, tooltipType, controller)
		if not userSettings.enableModFeatures then return end
		if not userSettings.showMappins then return end
		if not controller then return end
		local mappin = controller:GetMappin()
		if not mappin then return end
		local id = mappin:GetNewMappinID()
		if not id then return end
		local containerEntry = mappinLookupByIdValStr[tostring(id.value)]
		if not containerEntry then return end
		local ctrl = this.tooltipController.defaultTooltipController
		ctrl.titleText:SetText(GetLocalizedText("LocKey#88188"))
		if containerEntry.isHiddenGem then ctrl.descText:SetText(GetLocalizedText("LocKey#28538")) return end
		ctrl.descText:SetText(GetLocalizedText("LocKey#93575"))
	end)

	local shouldResetSettingsPanel, shouldReloadMenu, shouldRestoreDefaultSettings
	ObserveBefore("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		shouldRestoreDefaultSettings = false
		if not nativeSettings then return end
		if not nativeSettings.fromMods then return end
		if type(defaultUserSettings) ~= 'table' then return end

		local currentOption = nativeSettings.data[nativeSettings.currentTab]
		if not currentOption then return end
		if currentOption.isRedMod then return end
		if currentOption.path ~= modName then return end
		shouldResetSettingsPanel = true
		shouldRestoreDefaultSettings = true
	end)
	ObserveAfter("SettingsMainGameController", "RequestRestoreDefaults", function(this)
		if not shouldRestoreDefaultSettings then return end
		shouldRestoreDefaultSettings = false
		userSettings = cloneTable(defaultUserSettings)
		saveUserSettings()
		if shouldResetSettingsPanel then setupNativeSettings(true) end
	end)
end

local shouldShowMainWindow, windowFlags, menuButtonlabel
local initMainWindowOnOverlayOpen = false
local windowTitle = modName
local windowSettings = {width = 316, height = 122, buttonWidth = 20}
local shouldSetFocus = 0

registerForEvent("onOverlayOpen",function()
	shouldShowMainWindow = true
	initMainWindowOnOverlayOpen = true
end)

registerForEvent("onOverlayClose",function()
	shouldShowMainWindow = false
end)

registerForEvent("onDraw", function()
	if isModDisabled then return end
	showMainWindow()
end)

function initMainWindow()
	shouldUpdateCetWindow = false
	local x, y = ImGui.CalcTextSize('abcdefghijklmnoprstuwxyz /_.,ABCDEFGHIJKLMNOPRSTUWXYZ')
	windowSettings.width = math.ceil(x * 0.75)
	windowFlags = ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.AlwaysAutoResize
	windowSettings.buttonHeight = ImGui.GetFrameHeight()
	windowTitle = uiStrings.cetUiStrings.modDisplayName
end

local lastQuestStatus = 0
local nextQuestStatusUpdate = 0
local questCooldownState = {cooldown = 0, cooldown_counter = 0}
local function updateQuestCooldownState()
	questCooldownState.cooldown = questsSystem:GetFactStr("ep1_airdrop_cooldown")
	questCooldownState.cooldown_counter = questsSystem:GetFactStr("ep1_airdrop_cooldown_counter")
end
local discovered, total = 0, 0
local function getQuestStatus()
	local curTime = os.clock()
	if nextQuestStatusUpdate > curTime then return lastQuestStatus end
	nextQuestStatusUpdate = curTime + 0.25
	if isDebug then updateQuestCooldownState() end
	if not isAirdropsQuestActive() then lastQuestStatus = 0 return 0 end
	discovered, total = getDiscoveredHiddenGemAirdropsStats()
	if isAirdropsQuestPaused() then lastQuestStatus = 2 return 2 end
	lastQuestStatus = 1
	return 1
end

function showMainWindow()
	if initMainWindowOnOverlayOpen or shouldUpdateCetWindow then initMainWindow() initMainWindowOnOverlayOpen = false end
	if not shouldShowMainWindow then return end

	local hasAnythingChanged = false
	ImGui.SetNextWindowPos(50, 50, ImGuiCond.FirstUseEver)
	ImGui.SetNextWindowSize(windowSettings.width , -1)
	if ImGui.Begin(windowTitle, true, windowFlags) then
		if ImGui.IsWindowCollapsed() then ImGui.End() return end
		local questStatus = getQuestStatus()
		local isQuestStarted
		if questStatus == 0 then
			ImGui.Separator()
			ImGui.TextWrapped(uiStrings.cetUiStrings.settingsView.questStatus.titleInactive)
		elseif questStatus == 1 then
			isQuestStarted = true
			ImGui.Separator()
			ImGui.TextWrapped(uiStrings.cetUiStrings.settingsView.questStatus.titleActive)
		elseif questStatus == 2 then
			isQuestStarted = true
			ImGui.Separator()
			ImGui.TextWrapped(uiStrings.cetUiStrings.settingsView.questStatus.titlePaused)
		end
		if isDebug then
			ImGui.Text("Counters: "..tostring(questCooldownState.cooldown_counter).."/"..tostring(questCooldownState.cooldown))
		end

		ImGui.Separator()
		ImGui.Text(uiStrings.cetUiStrings.settingsView.clickButtonHeader.title)
		ImGui.Separator()

		local oldSettingsValue = userSettings.enableModFeatures
		if userSettings.enableModFeatures then menuButtonlabel = uiStrings.cetUiStrings.settingsView.enableModFeatures.titleIsEnabled else menuButtonlabel = uiStrings.cetUiStrings.settingsView.enableModFeatures.titleIsDisabled end
		if ImGui.Button(menuButtonlabel, -1, windowSettings.buttonHeight) then
			hasAnythingChanged = true
			userSettings.enableModFeatures = not userSettings.enableModFeatures
			if isUsingNativeSettings and nativeSettingsOptions.enableModFeatures then
				nativeSettingsIgnoreNextAction = true
				nativeSettings.setOption(nativeSettingsOptions.enableModFeatures, userSettings.enableModFeatures)
				payload = function() setupNativeSettings(true) payload = nil end
			end
			if isQuestStarted then updateAllContainerMappins() end
		end
		if ImGui.IsItemHovered() then
			ImGui.SetTooltip(uiStrings.cetUiStrings.settingsView.enableModFeatures.tooltips)
		end
		local isModActivityDisabled = not userSettings.enableModFeatures
		if isModActivityDisabled then ImGui.BeginDisabled() end
		pcall(function()
			oldSettingsValue = userSettings.showMappins
			if userSettings.showMappins then menuButtonlabel = uiStrings.cetUiStrings.settingsView.showMappins.titleIsEnabled else menuButtonlabel = uiStrings.cetUiStrings.settingsView.showMappins.titleIsDisabled end
			if ImGui.Button(menuButtonlabel, -1, windowSettings.buttonHeight) then
				hasAnythingChanged = true
				userSettings.showMappins = not userSettings.showMappins
				if isUsingNativeSettings and nativeSettingsOptions.showMappins then
					nativeSettingsIgnoreNextAction = true
					nativeSettings.setOption(nativeSettingsOptions.showMappins, userSettings.showMappins)
				end
				if isQuestStarted then updateAllContainerMappins() end
			end
			if ImGui.IsItemHovered() then
				ImGui.SetTooltip(uiStrings.cetUiStrings.settingsView.showMappins.tooltips)
			end
			oldSettingsValue = userSettings.showHiddenAirdropDiscoveryNotifications
			if userSettings.showHiddenAirdropDiscoveryNotifications then menuButtonlabel = uiStrings.cetUiStrings.settingsView.showHiddenAirdropDiscoveryNotifications.titleIsEnabled else menuButtonlabel = uiStrings.cetUiStrings.settingsView.showHiddenAirdropDiscoveryNotifications.titleIsDisabled end
			if ImGui.Button(menuButtonlabel, -1, windowSettings.buttonHeight) then
				hasAnythingChanged = true
				userSettings.showHiddenAirdropDiscoveryNotifications = not userSettings.showHiddenAirdropDiscoveryNotifications
				if isUsingNativeSettings and nativeSettingsOptions.showHiddenAirdropDiscoveryNotifications then
					nativeSettingsIgnoreNextAction = true
					nativeSettings.setOption(nativeSettingsOptions.showHiddenAirdropDiscoveryNotifications, userSettings.showHiddenAirdropDiscoveryNotifications)
				end
			end
			if ImGui.IsItemHovered() then
				ImGui.SetTooltip(uiStrings.cetUiStrings.settingsView.showHiddenAirdropDiscoveryNotifications.tooltips)
			end
			oldSettingsValue = userSettings.fixDOAairdrops
			if userSettings.fixDOAairdrops then menuButtonlabel = uiStrings.cetUiStrings.settingsView.fixDOAairdrops.titleIsEnabled else menuButtonlabel = uiStrings.cetUiStrings.settingsView.fixDOAairdrops.titleIsDisabled end
			if ImGui.Button(menuButtonlabel, -1, windowSettings.buttonHeight) then
				hasAnythingChanged = true
				userSettings.fixDOAairdrops = not userSettings.fixDOAairdrops
				if isUsingNativeSettings and nativeSettingsOptions.fixDOAairdrops then
					nativeSettingsIgnoreNextAction = true
					nativeSettings.setOption(nativeSettingsOptions.fixDOAairdrops, userSettings.fixDOAairdrops)
				end
			end
			if ImGui.IsItemHovered() then
				ImGui.SetTooltip(uiStrings.cetUiStrings.settingsView.fixDOAairdrops.tooltips)
			end

			if not isQuestStarted then return end
			if total < 1 then return end
			local msgTxt = uiStrings.cetUiStrings.hiddenAirdropDiscoveryNotification
			msgTxt = stringGsub(msgTxt, '##COUNT##', tostring(discovered))
			msgTxt = stringGsub(msgTxt, '##TOTAL##', tostring(total))
			ImGui.Separator()
			ImGui.Text(msgTxt)
		end)
		if isModActivityDisabled then ImGui.EndDisabled() end
		if isDebug then
			ImGui.Separator()
			local isAirdropsResetDisabled = not isResetAllowed()
			if isAirdropsResetDisabled then ImGui.BeginDisabled() end
			pcall(function()
				menuButtonlabel = uiStrings.cetUiStrings.settingsView.resetAirdrops.title
				if ImGui.Button(menuButtonlabel, -1, windowSettings.buttonHeight) then
					resetAirdrops()
					nextQuestStatusUpdate = 0.001
				end
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.settingsView.resetAirdrops.tooltips)
				end
			end)
			if isAirdropsResetDisabled then ImGui.EndDisabled() end
		end
		ImGui.Separator()
		ImGui.Text(modVer..'                 ')
		ImGui.End()
	end

	if hasAnythingChanged then
		userSettings.lastChanged = os.time()
		saveUserSettings()
	end
end

return {modName = modName, modVer = modVer, modAuthorName = modAuthorName}
