-- Jul 8, 2026 by (c)anygoodname

local modVer='v5.38.1'
local modName='Hotscenes'
local modAuthorName = 'anygoodname'

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
You may use parts of the code or any original algorithms developed for this mod in your own creations only with my prior consent and proper credit.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--


Ref = require('Ref')

isHotscenesDataLoaded = false
hotscenesData = {}
rootFolder = nil
local femaleScenes, femaleScenesIndex, femaleScenesCount = {}, {}, 0
local maleScenes, maleScenesIndex, maleScenesCount = {}, {}, 0
local totalScenesCount = 0
local femalePerformers, femalePerformersCount = {}, 0
local malePerformers, malePerformersCount = {}, 0
local totalPerformersCount = 0
gvs, isGameV2, gameVer = true, false, 0
isGameV21 = false
isEp1Allowed = false
shouldKeepUpdatingEp1Performers = false
sceneProgressDefaultTimeout = 90
lastSceneSetupProgresstTimeout = 90
local lastKnownSavesCount, lastKnownSaveMetadata = 0, nil
isKeyDialogOptionSelected, keyDialogTitleLocKey = false, ''
isPaymentDone, lastQuestRelatedPaidActionStarted = false, false
local gamePlayerGendersDefaults = {
						female = {recordPathStr = 'Character.Player_Puppet_Base_inline0.gender', entityStr = '1BCD09F6F70A7818', valueStr = 'Gender.Female', valueHashInt = 1053617507},
						male = {recordPathStr = 'Character.Player_Puppet_Base_inline1.gender', valueStr = 'Gender.Male', valueHashInt = 1448364197},
						}
playerGenderSettings = {}

local clipStepRepeatCounter, maxClipStepsRepeat, newRepeat = 5, 5, true
local sceneState = {sceneTier = 0, sceneName = '', scenePerformerGender = '', isPlayerInHotscene = false, isPerformerPaid = false, isPlayerUndressed = false, lastSceneUndressPlayerRequest = 0, clipFactStr = '', stopFactStr = '', isIntro = false, isClip = false, isOutro = false, performerEntID = nil, isSpycamAllowed = false, isGenderSwitchMode = false, shouldChangeGender = false, changeGenderTime = 0}
playback = {idle = 0, cued = 1, playPending = 2, playing = 3}

sceneModeIsInteractive = 2
sceneModeIsOverride = 3
sceneModeIsFastPlayback = 4
local scenePlaybackMode = {interactive = sceneModeIsInteractive, fastPlayback = sceneModeIsFastPlayback, overrideSceneAvaliability = sceneModeIsOverride}

userSettingsFilename = 'mod_user_settings.json'
userSettings = {filename = userSettingsFilename, reuseSaves = true, extendHotscenes = true, lastKnownSaveMetadata = {}, screenScale = 1, playerGenderOnPlayback = 1, spycamOrbitPitchWithMouse = true, enableSpycamFreezeFrameToggleMode = false, defaultTimeout = 90, enable_mq055_integration = true, mq055_integration_prefer_vanilla_appearances = false, enableHotscenesButtonInHubMenu = true, enableNativeSettingsIntegration = true, invertMouseVertically = false, enableNCDelightsFeature = true, enableNCDelightsDynamicMappins = true, enableHotscenesAddon = true, enableSceneAvaliabilityOverride = true, enableNcSceneExtensions = true, restoreNpcDefaults = false, noGameReloads = true, hideNpcSpecs = false, hideNpcFishnetTights = false, hideNpcSpikedChokers = false, isPlayerPerformerDiscovered = false, sortByDisplayName = true, enablePerformerPreviewSupport = true, keepShowingPerformerPreview = false, isGenderSwitchFeatureEnabled = false}
defaultUserSettings = {}
for k, v in pairs(userSettings) do
	if type(v) ~= 'table' and k ~= "isPlayerPerformerDiscovered" and k ~= 'defaultTimeout' and k ~= 'allowUnknownCustomCharacterData' and k ~= 'isGenderSwitchFeatureEnabled' then
		defaultUserSettings[k] = v
	end
end

local idleMenuHandle, pauseMenuHandle, isSilentPauseMenuRequested = nil, nil, false
local lastGameSavesFileNames, isLookingForLastModSave, isLookingForLastModSaveTimeout = {}, false, 0
local shouldCleanupFromFileLookup, lastModSaveIndex = false, 0
local cNamePauseMenuScenario
local n_save_game = "save_game"
local lastModSaveFileName = nil
local sceneAvailabilityOverride = false
local isEnding = false
local isDebug = false
local spycam = nil
local slowMoParams = {cNameSlowMoUserReason = nil, cNameSlowMoSpycamReason = nil, cNameSlowMoEaseInCurve = nil, cNameSlowMoEaseOutCurve = nil, slowMoSpeedFactor = 0.1, slowMoDuration = 30}
local isNewGameLoad = false

local supportedCharacterDatasetVersions = {4.1}
supportedArchiveVersionsInfo = {'Hotscenes_mod_version_info_5102', 'Hotscenes_mod_version_info_5103', 'Hotscenes_mod_version_info_5350',  'Hotscenes_mod_version_info_5351'}
isArchiveDetected = false
local isModDisabled = false
isModInitialized = false
shouldAppendCustomPerformers = true
local mq055_hangouts_interaction
local is_mq055_custom_scene_playback_requested = 0
local n_NoMovement = "NoMovement"

unsupportedOverridesArchiveVersionsInfo = {
	'Hotscenes_overrides_mod_version_info_390',
	'Hotscenes_overrides_mod_version_info_391',
	'Hotscenes_overrides_mod_version_info_310',
	'Hotscenes_overrides_mod_version_info_3101',
	'Hotscenes_overrides_mod_version_info_3102',
	'Hotscenes_overrides_mod_version_info_3110',
	'Hotscenes_overrides_mod_version_info_3120',
	'Hotscenes_overrides_mod_version_info_3140',
	'Hotscenes_overrides_mod_version_info_3160',
	'Hotscenes_overrides_mod_version_info_3170',
	'Hotscenes_overrides_mod_version_info_3171',
	'Hotscenes_overrides_mod_version_info_3180',
	'Hotscenes_overrides_mod_version_info_3182',
	'Hotscenes_overrides_mod_version_info_3190',
	'Hotscenes_overrides_mod_version_info_3200',
	'Hotscenes_overrides_mod_version_info_3210',
	'Hotscenes_overrides_mod_version_info_3220',
	'Hotscenes_overrides_mod_version_info_3230',
	'Hotscenes_overrides_mod_version_info_3240',
	'Hotscenes_overrides_mod_version_info_3250',
	'Hotscenes_overrides_mod_version_info_5000',
	'Hotscenes_overrides_mod_version_info_5100',
	'Hotscenes_overrides_mod_version_info_5200',
	'Hotscenes_overrides_mod_version_info_5300',
	'Hotscenes_overrides_mod_version_info_5301',
	'Hotscenes_overrides_mod_version_info_5400',
	'Hotscenes_overrides_mod_version_info_5500',
	'Hotscenes_overrides_mod_version_info_5600',
	'Hotscenes_overrides_mod_version_info_5700',
	'Hotscenes_overrides_mod_version_info_5800',
	'Hotscenes_overrides_mod_version_info_5900',
	'Hotscenes_overrides_mod_version_info_51000',
	'Hotscenes_overrides_mod_version_info_51001',
	'Hotscenes_overrides_mod_version_info_51100',
	'Hotscenes_overrides_mod_version_info_51101',
	'Hotscenes_overrides_mod_version_info_51200',
	'Hotscenes_overrides_mod_version_info_51400',
	'Hotscenes_overrides_mod_version_info_51401',
	'Hotscenes_overrides_mod_version_info_51402',
	'Hotscenes_overrides_mod_version_info_3180',
	'Hotscenes_overrides_mod_version_info_3190',
	'Hotscenes_overrides_mod_version_info_3200',
	'Hotscenes_overrides_mod_version_info_3210',
	'Hotscenes_overrides_mod_version_info_3220',
	'Hotscenes_overrides_mod_version_info_3230',
	'Hotscenes_overrides_mod_version_info_3240',
	'Hotscenes_overrides_mod_version_info_3250',
	'Hotscenes_overrides_mod_version_info_5000',
	'Hotscenes_overrides_mod_version_info_5100',
	'Hotscenes_overrides_mod_version_info_5200',
	'Hotscenes_overrides_mod_version_info_5300',
	'Hotscenes_overrides_mod_version_info_5301',
	'Hotscenes_overrides_mod_version_info_5400',
	'Hotscenes_overrides_mod_version_info_5500',
	'Hotscenes_overrides_mod_version_info_5600',
	'Hotscenes_overrides_mod_version_info_5700',
	'Hotscenes_overrides_mod_version_info_5800',
	'Hotscenes_overrides_mod_version_info_5900',
	'Hotscenes_overrides_mod_version_info_51000',
	'Hotscenes_overrides_mod_version_info_51001',
	'Hotscenes_overrides_mod_version_info_51100',
	'Hotscenes_overrides_mod_version_info_51101',
	'Hotscenes_overrides_mod_version_info_51200',
	'Hotscenes_overrides_mod_version_info_51400',
	'Hotscenes_overrides_mod_version_info_51401',
	'Hotscenes_overrides_mod_version_info_51402',
}
supportedOverridesArchiveVersionsInfo = {
	'Hotscenes_overrides_mod_version_info_51500',
	'Hotscenes_overrides_mod_version_info_51501',
	'Hotscenes_overrides_mod_version_info_51502',
	'Hotscenes_overrides_mod_version_info_51503',
	'Hotscenes_overrides_mod_version_info_51600',
	'Hotscenes_overrides_mod_version_info_51700',
	'Hotscenes_overrides_mod_version_info_51800',
	'Hotscenes_overrides_mod_version_info_51801',
	'Hotscenes_overrides_mod_version_info_51802',
	'Hotscenes_overrides_mod_version_info_51803',
	'Hotscenes_overrides_mod_version_info_51900',
	'Hotscenes_overrides_mod_version_info_51901',
	'Hotscenes_overrides_mod_version_info_51902',
	'Hotscenes_overrides_mod_version_info_52000',
	'Hotscenes_overrides_mod_version_info_52100',
	'Hotscenes_overrides_mod_version_info_52200',
	'Hotscenes_overrides_mod_version_info_52201',
	'Hotscenes_overrides_mod_version_info_52202',
	'Hotscenes_overrides_mod_version_info_52203',
	'Hotscenes_overrides_mod_version_info_52204',
	'Hotscenes_overrides_mod_version_info_52205',
	'Hotscenes_overrides_mod_version_info_52206',
	'Hotscenes_overrides_mod_version_info_52207',
	'Hotscenes_overrides_mod_version_info_52300',
	'Hotscenes_overrides_mod_version_info_52301',
	'Hotscenes_overrides_mod_version_info_52302',
	'Hotscenes_overrides_mod_version_info_52303',
	'Hotscenes_overrides_mod_version_info_52304',
	'Hotscenes_overrides_mod_version_info_52305',
	'Hotscenes_overrides_mod_version_info_52306',
	'Hotscenes_overrides_mod_version_info_52307',
	'Hotscenes_overrides_mod_version_info_52308',
	'Hotscenes_overrides_mod_version_info_52309',
	'Hotscenes_overrides_mod_version_info_52310',
	'Hotscenes_overrides_mod_version_info_52400',
	'Hotscenes_overrides_mod_version_info_52401',
	'Hotscenes_overrides_mod_version_info_52402',
	'Hotscenes_overrides_mod_version_info_52403',
	'Hotscenes_overrides_mod_version_info_52404',
	'Hotscenes_overrides_mod_version_info_52405',
	'Hotscenes_overrides_mod_version_info_52406',
	'Hotscenes_overrides_mod_version_info_52407',
	'Hotscenes_overrides_mod_version_info_52408',
	'Hotscenes_overrides_mod_version_info_52409',
	'Hotscenes_overrides_mod_version_info_52410',
	'Hotscenes_overrides_mod_version_info_52500',
	'Hotscenes_overrides_mod_version_info_52501',
	'Hotscenes_overrides_mod_version_info_52502',
	'Hotscenes_overrides_mod_version_info_52503',
	'Hotscenes_overrides_mod_version_info_52504',
	'Hotscenes_overrides_mod_version_info_52505',
	'Hotscenes_overrides_mod_version_info_52506',
	'Hotscenes_overrides_mod_version_info_52507',
	'Hotscenes_overrides_mod_version_info_52508',
	'Hotscenes_overrides_mod_version_info_52509',
	'Hotscenes_overrides_mod_version_info_52510',
}

local isOverridesArchiveDetected = false
local isUnsupportedOverridesArchiveDetected = false
local isOverridesArchiveSupportingSceneAvailabilityOverride = false
local isPreGameState = false
local isGameLoading = false
isArchiveXLActive = false
isCodewareActive = false
isMansionDlcModActive = false
isCetNpcBodyModActive = false
local enable_mq055_hangouts_support = false
local journalManager, questsSystem, workspotSystem, transactionSystem, gameBlackBoardSystem, allBlackboardDefs, statsSystem, targetingSystem, audioSystem, autoSaveSystem, navigationSystem, statusEffectSystem
local GameGetSystemRequestsHandler, GameFindEntityByID
local HUDActorTypePUPPET
local GameGetEngineTime
local GameGetNodeTransform
local GameGetScriptableSystemsContainer
local GameGetTeleportationFacility
local GameIsSavingLocked
local EPreventionHeatStageHeat_0

local n_PreventionSystem = "PreventionSystem"
local n_FreezePlayer = "FreezePlayer"
local n_Linear = "Linear"
local n_eyes_closing_instant_open_slow = "eyes_closing_instant_open_slow"
local n_eyes_opening_05s = "eyes_opening_05s"
local n_eyes_closing_fast = "eyes_closing_fast"
local n_global_menu_phone_open = "global_menu_phone_open"
local n_global_menu_phone_close = "global_menu_phone_close"

local h1_specs = {
	"h1_001_wa_specs__wakako_okada6800",
	"h1_007_wa_specs__aviators0272",
	"h1_007_wa_specs__aviators_head5420",
	"h1_013_wa_specs__big",
	"h1_015_wa_specs__visor",
	"h1_064_wa_specs__sunglasses_02",
	"h1_069_wa_specs__round",
	"h1_007_ma_specs__aviators",
	"h1_007_ma_specs__aviators8085",
	"h1_007_ma_specs__aviators_head7041",
	"h1_052_ma_specs__tactical2176",
	"h1_052_ma_specs__tactical_027706",
	"h1_064_ma_specs__sunglasses_012612",
	"h1_038_wa_specs__classic",
}

local choker_spikes = {
	{isFemale = true, componentName = "i1_048_wa_neck__choker_spikes"},
	{isFemale = true, meshHash = 4558599161779392782ULL},
	{isFemale = true, meshHash = 10629159892677896498ULL},
	{isFemale = false, meshHash = 13173201442196667752ULL},
	{isFemale = false, meshHash = 11704776603394111231ULL},
	{isFemale = false, componentName = "i1_043_ma_neck__spiked_choker0792"},
	{isFemale = false, componentName = "i1_029_ma_neck__spiked_collar9648"},
	{isFemale = false, componentName = "i1_048_ma_neck__choker_spikes3545"},
}

local isPerformerReplacingPlayerSupported
local mainHudWindowWidget

isCetSpawnerAllowed = true
isSupportedCet = true
unsupportedCetReason = nil
cetVerStr = GetVersion()
cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

if cetVer >= 1.26 then isGameV2 = true end
if cetVer >= 1.29 then isGameV21 = true end

knownUnsupportedCetVersions = {
	{min = 1.26, max = 1.26},
	{min = 1.29, max = 1.29},
	{min = 1.30, max = 1.30},
	{min = 1.31, max = 1.3102, reason = 'exEntitySpawner'},
	{min = 1.32, max = 1.32, reason = 'exEntitySpawner'},
}

for _, unsupportedCetRec in ipairs(knownUnsupportedCetVersions) do
	if cetVer >= unsupportedCetRec.min and cetVer <= unsupportedCetRec.max then
		isSupportedCet = false
		unsupportedCetReason = unsupportedCetRec.reason
		break
	end
end

if isSupportedCet then
	local cet_version_blowup_preventer = require("cet_version_blowup_preventer")
	if type(cet_version_blowup_preventer) == 'table' and type(cet_version_blowup_preventer.isCurrentCetVersionSupported) == 'function' then
		isSupportedCet, unsupportedCetReason = cet_version_blowup_preventer.isCurrentCetVersionSupported()
	end
end

if (not isSupportedCet) and type(unsupportedCetReason) == 'string' and unsupportedCetReason == 'exEntitySpawner' then isCetSpawnerAllowed = false end

local nativeUI = {}

local stringLen = string.len
local stringMatch = string.match
local stringGsub = string.gsub
local stringRep = string.rep
local stringFind = string.find
local stringFormat = string.format
local stringLower = string.lower

local tableInsert = table.insert
local tableSort = table.sort
local tableRemove = table.remove

function printError(...)
	local args = {...}
	if #args < 1 then return end
	local output = tostring(args[1])
	if #args > 1 then for i = 2, #args do output = output..' '..tostring(args[i]) end end
	if type(output) == 'string' and stringLen(output) > 0 then
		print(output)
		spdlog.error(output)
	end
end

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

function getTableTypeWithKeysOrCount(array, sort);
	local count = #array;
	local isOrderedArray = count > 0;
	if isOrderedArray then return false, count end;
	local keys = {};
	for key, value in pairs(array) do;
		tableInsert(keys, key);
	end;
	if sort then tableSort(keys) end;
	return true, keys;
end;
function serializeTable(val, level, isCustomOrder, sortIfNoCustomOrderFound)
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
				if type(val.exportOrder) == 'table' and #val.exportOrder > 0 then
					keys = val.exportOrder
				else
					if sortIfNoCustomOrderFound then tableSort(keys) end
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

function saveJsonTable(data, fileName)
	if type(data) ~= 'table' then return end
	if type(fileName) ~= 'string' then return end
	local encodeResult, jString = pcall(function() return json.encode(data) end)
	if not encodeResult then print(jString) return end
	if type(jString) ~= 'string' then return end
	local file = io.open(fileName, "w")
	if file then
		file:write(jString)
		file:close()
	else
		print('Cannot save table to file', fileName)
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

exportedStringsFileHeader = {
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

stringsFileSet = {cetUiStrings = 'cetUiStrings.json', nuiUiStrings = 'nuiUiStrings.json', fullPerformerNames = 'performerStrings.json', destinationNames = 'destinationStrings.json'}

local uiDefaultStrings = {
	cetUiStrings = {
		exportOrder = {'cetKeyBindings', 'cetWindowName', 'cetWindowMainView', 'cetScenePanel', 'cetWindowSettingsView', 'cetWarnings'},
		cetWindowName = "Hotscenes Collection",
		cetKeyBindings = {
			exportOrder = {"openNativeUImenu", "nanoDroneSpawn", "nanoDroneW", "nanoDroneS", "nanoDroneA", "nanoDroneD", "hotscenesSlowMoToggle"},
			openNativeUImenu = "Open NativeUI Menu",
			nanoDroneSpawn = "Activate Spycam",
			nanoDroneW = "Fly Forward",
			nanoDroneS = "Fly Backwards",
			nanoDroneA = "Fly Left",
			nanoDroneD = "Fly Right",
			hotscenesSlowMoToggle = "Slow Motion Toggle",
		},
		cetWindowSettingsView = {
			exportOrder = {
				'headerLeft', 'headerRight', 'extendHotscenes', 'sortByDisplayName', 'hideNpcSpecs', 'hideNpcFishnetTights', 'hideNpcSpikedChokers', 'spycamOrbitPitchWithMouse', 'enableSpycamFreezeFrameToggleMode', 'invertMouseVertically', 'enableHotscenesButtonInHubMenu', 'enableNativeSettingsIntegration',
					'hotscenesAddOnNotDetected', 'hotscenesUnsupportedAddOnDetected', 'hotscenesAddOnSceneOverrideNotSupported', 'enableHotscenesAddon', 'addOnActivationButton', 'enableSceneAvaliabilityOverride', 'enablePerformerPreviewSupport', 'noGameReloads',
					'enableSceneAvaliabilityOverrideTriggerQuestActive', 'enable_mq055_integration', 'mq055_integration_prefer_vanilla_appearances', 'enableNCDelightsFeature', 'enableNCDelightsDynamicMappins', 'enableNcSceneExtensions', 'restoreNpcDefaults', 'underwearManagementDisabled', 'screenScale',
				},
			headerLeft = "Settings:",
			headerRight = "Back to Hotscenes collection",

			extendHotscenes = {title = "Longer hotscenes playback.", tooltips = "This option extends playback time and adds more variety to hotscenes."},
			hideNpcSpecs = {title = "Take off glasses.", tooltips = "When this option is enabled, engaged performers will take off glasses too.\nThis applies to the main menu scenes and the Night City Delights scenes\n(if Add-on is installed)."},
			hideNpcFishnetTights = {title = "Take off fishnet tights.", tooltips = "When this option is enabled, engaged performers will take off fishnet tights too.\nThis applies to the main menu scenes and the Night City Delights scenes\n(if Add-on is installed)."},
			hideNpcSpikedChokers = {title = "Take off spiked chokers.", tooltips = "When this option is enabled, engaged performers will take off spiked chokers too.\nThis applies to the main menu scenes and the Night City Delights scenes\n(if Add-on is installed)."},

			playerGenderOnPlaybackWarning = {title = "Warning: This option is no longer supported. Use at your own risk."},
			playerGenderOnPlaybackCombo = {title = "Select scenes gender-specific sequence:", tooltips = "This option allows you to influence scenes\' gender-specific logic to adjust content accordingly.\nNote:\n- These are subtle differences in the game\'s default sequences based on the Player gender.\n- It will not change the real Player gender or appearance."},
			playerGenderOnPlaybackSelectionList = {"Player gender (default)", "Female", "Male", "Player gender opposite", "Performer gender", "Performer gender opposite", "Random"},

			spycamOrbitPitchWithMouse = {title = "Spycam orbit mode uses mouse for vertical control.", tooltips = "In the Spycam orbit mode:\n-If enabled: use mouse up/down to control the spycam vertical position,\n use keyboard for forward/backward movement.\n-If disabled: use keyboard forward/backward to control the spycam vertical position,\n use mouse up/down for forward/backward movement."},
			enableSpycamFreezeFrameToggleMode = {title = "Spycam Freeze Frame button is a toggle.", tooltips = "With this option enabled, the left mouse button toggles the Freeze Frame on and off.\nIf the option is disabled, the left mouse button freezes time only while pressed.\nNote: for safety reasons, the Freeze Frame will automatically toggle back\nin 60 seconds if you forget to switch it off."},
			invertMouseVertically = {title = "Invert Spycam mouse control vertically.", tooltips = "Inverts Spycam mouse control vertically."},
			enableHotscenesButtonInHubMenu = {title = "Enable Hotscenes Button in Hub Menu.", tooltips = "This option adds the Hotscenes button to the game\'s Hub menu,\nallowing you to open the Hotscenes main menu window.\nIf disabled, the Hotscenes menu is still accessible either through the CET\noverlay or via a keyboard shortcut, if defined in the CET Bindings window."},
			enableNativeSettingsIntegration = {title = "Enable Native Settings integration.", tooltips = "This option allows to opend the mod\'s settings page\nin the Native Settings UI right from the Hotscenes Native UI menu."},

			hotscenesAddOnNotDetected = "Hotscenes Add-on is not detected.\nIf you would like to use extra features provided by the add-on, please copy this link to download it from its website:";
			hotscenesUnsupportedAddOnDetected = "Unsupported Hotscenes Add-on is detected.\nIf you would like to use extra features provided by the add-on, please copy this link to download a supported version from its website:";
			hotscenesAddOnSceneOverrideNotSupported = "The currently installed add-on version does not support scenes availability overrides. Please update the add-on plugin:";
			hotscenesAddOnWebsiteLink = "https://www.nexusmods.com/cyberpunk2077/mods/11772";

			enableHotscenesAddon = {title = "Enable Hotscenes Add-on.", tooltips = "Enables extra features provided by Hotscenes Add-on.\nPlease note that the final feature set may vary depending on game versions\nand other mods that may affect the add-on."},

			addOnActivationButton = {
				archiveXLNotActive = {title = "Archive-XL not found. The Add-on feature set is limited.\nPlease install Archive-XL to enable full functionality.", tooltips = "Add-on features require Archive-XL to work.\nPlease install it to enable full Add-on functionality."},
				statusUnavailable = {title = "The Add-on activation status is not available at the moment...", tooltips = "The Add-on activation status cannot be determined\nuntil the game is fully loaded and resumed."},
				isActive = {title = "The Add-on is activated now.", tooltips = "The Add-on quest launcher is active now, enabling the full feature set.\n\nBy clicking this button, you can request to deactivate it.\nDo this only if requested by the mod authors or if you believe it may be causing issues.\nPlease note that deactivating it will limit the Add-on's feature set.\nAdditionally, it may be automatically reactivated if you visit activation trigger locations."},
				isInactive = {title = "The Add-on is not activated. Please visit any of V\'s apartments to activate.", tooltips = "The Add-on is not active in the loaded game.\nYou can activate it by visiting any of V\'s apartments.\nPlease note that you must enter the apartment from outside."},
				deactivationPrompt = {title = "Please confirm your Add-on deactivation request:", tooltips = "Please confirm your deactivation request.\nPlease note that normally you don't need to deactivate it.\nDo it only if requested by the mod authors or if you believe it may be causing issues."},
				confirmDeactivation = {title = "Are you sure?", tooltips = "Do you really want to request Add-on deactivation?"},
				cancelDeactivation = {title = "Cancel", tooltips = "Exit without deactivating the Add-on."},
				isDeactivating = {title = "Waiting for deactivation to complete..."},
				isDeactivatingWhileGamePaused = {title = "Deactivation requested. Please unpause the game to complete deactivation...", tooltips = "The requested deactivation is pending, but it cannot continue while the game is paused.\nPlease unpause the game."},
			},

			enableSceneAvaliabilityOverride = {title = "Enable Hotscenes availability override.", tooltips = "This feature allows playing scenes that the game has not yet made available.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough."},
			enableSceneAvaliabilityOverrideTriggerQuestActive = {title = "Enable Hotscenes availability override.", tooltips = "This feature allows playing scenes that the game has not yet made available.\nThe highlight color indicates that a scene launch acceleration is active.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough."},
			enablePerformerPreviewSupport = {title = "Enable Performer Preview.", tooltips = "This option enables the Performer Preview feature in the Native UI menu.\n\nPlease note that this feature requires the Add-on to be activated."},
			noGameReloads = {title = "Prefer no game reloads.", tooltips = "This option speeds up main menu scene startups and completions\nby skipping game reloads if the add-on is activated.\nPlease note that a recovery manual save will still be created."},
			sortByDisplayName = {title = "Sort performers by custom/translated names.", tooltips = "Sort performer lists preferring custom or translated names if available.\nPlease note that results may not be accurate in non-Latin languages."},

			enable_mq055_integration = {title = "Enable Hangouts quests integration.", tooltips = "This feature allows to integrate hotscenes playback with the game Hangouts quest scenes.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough."},
			mq055_integration_prefer_vanilla_appearances = {title = "Prefer vanilla partner appearances in Hangouts.", tooltips = "If this option is enabled, the mod will try to use vanilla appearances\nfor your partner if available, instead of Hotscenes exclusive appearances.\nThis option is designed to allow other mods change your partner\'s appearance."},
			enableNCDelightsFeature = {title = "Enable Night City Delights add-on.", tooltips = "Enables Night City Delights scenes provided by the add-on."},
			enableNCDelightsDynamicMappins = {title = "Night City Delights: reveal nearby performers.", tooltips = "When this option is enabled, nearby active performers will be indicated with markers."},
			enableNcSceneExtensions = {title = "Night City Delights: enable scene extensions.", tooltips = "This option enables additional scene extensions if avaliable."},
			restoreNpcDefaults = {title = "Night City Delights: restore NPC defaults.", tooltips = "This option aims to restore NPCs handled by this feature if their internal data\nis found affected or corrupted, possibly by other mods.\nFor the best results, please reload your game after enabling it.\nPlease note that enabling this option may prevent other mods from modifying these NPCs."},

			underwearManagementDisabled = "V's underwear management in scenes is not included in this mod.\nIf you need such a feature, you can use the Underwear Removal Extended mod\n(select the link below with mouse, press Ctrl+C to copy, and paste into a web browser):",
			underwearManagementWebsiteLink = "https://www.nexusmods.com/cyberpunk2077/mods/4605",

			screenScale = {title = "UI scaling:", tooltips = "Select the mod window scaling to match your sceen size and resolution."},
		},

		cetWindowMainView = {
			exportOrder = {'headerScenesNotFound', 'headerScenesNotAvailable', 'gameIsLoading', 'headerLeft', 'headerLeftAddOnEnabled', 'headerRight', 'panelListHeaderLeft', 'panelListHeaderRight'},
			headerScenesNotFound = "Hotscenes collection is empty.",
			headerScenesNotAvailable = "Hotscenes not available at the moment.",
			gameIsLoading = "The game is loading, please hold on...",

			headerLeft = "Hotscenes Collection:",
			headerLeftAddOnEnabled = "Hotscenes Collection Plus:",
			headerRight = "Settings",

			panelListHeaderLeft = "Hotscene",
			panelListHeaderRight = "Performer",
		},

		cetScenePanel = {
			exportOrder = {'fullSceneNames', 'female', 'male', 'fastPlayback', 'sceneOverride', 'customSceneLocationCombo', 'cueButton', 'reloadButton', 'playbackButton', 'cancelButton', 'resetButton'},
			fullSceneNames = {
				female = {
					Glen = "Dark Matter Female",
					Japantown = "Jig-Jig St Female",
				},
			male = {
					Glen = "Dark Matter Male",
					Japantown = "Jig-Jig St Male",
				},
			},
			female = "Female",
			male = "Male",
			fastPlayback	= {title = "Fast playback", tooltips = "Skip introduction dialogues and automatically return to the starting point\nonce completed.\n\nNote: This feature is enabled only if you are outside the scene active area."},
			sceneOverride	= {title = "(Override mode)", tooltips = "Override mode allows you to play the scene before it\'s made available\nby the game.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough.\nIn case it failed to load it, please make sure to load the last known good save manually."},
			customSceneLocationCombo = {defaultLocationList = {"scene default"}, title = "Scene destination", tooltips = "Select custom destination for the scene playback.\nNote: this feature is only available in Fast Playback/Override modes."},
			cueButton		= {activeButtonLabel = "Cue",		inactiveButtonLabel = "Cue",	unavailableButtonLabel = "Action unavailable"},
			reloadButton	= {activeButtonLabel = "Reload",	inactiveButtonLabel = "Reload"},
			playbackButton	= {cueScene = "Cue scene", playScene = "Play scene", playOnGameResume = "Play scene on game resume", playPending = "Play pending...", reloadSave = "Reload last save"},
			cancelButton	= {activeButtonLabel = "Cancel",	inactiveButtonLabel = "Cancel"},
			resetButton		= {activeButtonLabel = "Reset",		inactiveButtonLabel = "Reset", },
		},

		cetWarnings = {
			exportOrder = {'mandatoryRefFileMissing', 'scenesFileMissingOrCorruptedOrOutdated', 'unsupportedGameVersion', 'unsupportedCetVersion', 'autosaveSystemDamaged', 'mandatoryArchiveFileMissing'},
			filler = "                                                                                                               ",
			unsupportedCetVersion = "Unsupported CET version detected: ##CET_VER##.\nPlease update your CET to a stable version.",
			autosaveSystemDamaged = "Your game\'s autosave system seems to be severely affected by other mods.\nThis mod cannot continue to function in this state.",
			mandatoryArchiveFileMissing = "The mod archive file is missing or unsupported version or corrupted.",
			mandatoryRefFileMissing = "Ref.lua file is missing or corrupted.",
			scenesFileMissingOrCorruptedOrOutdated = "Hotscenes collection file is missing or unsupported version or corrupted.",
			unsupportedGameVersion = "Unsupported game version detected.",
		},
	},
	nuiUiStrings = {
		exportOrder = {'onscreenWarnings'},
		onscreenWarnings = {
			exportOrder = {'playback'},
			playback = {
				timeout = "Hotscene playback could not be started.",
			},
		},
	},
	fullPerformerNames = nil,
	destinationNames = nil,
}

local uiStrings = cloneTable(uiDefaultStrings)

exportTable = {}
exportTable.exportOrder = {'fileHeader', 'uiStrings'}
exportTable.fileHeader = exportedStringsFileHeader
exportTable.uiStrings = uiDefaultStrings.cetUiStrings
pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/cetUiStrings.json") end

function replaceTableEntries(sourceTable, replacementTable, finalDataType, verbose)
	if type(sourceTable) ~= 'table' then return sourceTable end
	if type(replacementTable) ~= 'table' then return sourceTable end
	if finalDataType ~= 'string' then finalDataType = nil end
	local outputTable = cloneTable(sourceTable)
	local count, replacementCount = 0, 0
	local childResult = true
	local genderSuffix = '_to_female'
	if isPlayerMale then genderSuffix = '_to_male' end

	for sourceKey, sourceEntry in pairs(sourceTable) do
		count = count + 1
		local replacementEntry = replacementTable[sourceKey..genderSuffix] or replacementTable[sourceKey]
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
languages = {
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
	local file = io.open(userSettingsFilename, "r")
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
	uiStrings = cloneTable(uiDefaultStrings)
	if nativeUI.updateUiStrings then nativeUI.updateUiStrings() end

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

local function isStringValid(input)
	if type(input) ~= 'string' then return end
	return stringLen(input) > 0
end

local mathFloor = math.floor
local mathCeil = math.ceil
local mathMin = math.min
local mathMax = math.max
local mathSqrt = math.sqrt
local function vectorDistance(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    local dz = target.z - src.z;
    return mathSqrt(dx * dx + dy * dy + dz * dz);
end;
local function vectorDistance2D(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    return mathSqrt(dx * dx + dy * dy);
end;
local function vectorDistanceSquared(src, target)
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    local dz = target.z - src.z;
    return dx * dx + dy * dy + dz * dz;
end;
local function vectorDistanceSquared2D(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    return dx * dx + dy * dy;
end;

local RefWeak = Ref.Weak
local n, t
local function varSetup(inGame)
	questsSystem = RefWeak(Game.GetQuestsSystem())
	journalManager = RefWeak(Game.GetJournalManager())
	workspotSystem = RefWeak(Game.GetWorkspotSystem())
	transactionSystem = Game.GetTransactionSystem()
	gameBlackBoardSystem = RefWeak(Game.GetBlackboardSystem())
	allBlackboardDefs = RefWeak(Game.GetAllBlackboardDefs())
	statsSystem = RefWeak(Game.GetStatsSystem())
	timeSystem = RefWeak(Game.GetTimeSystem())
	targetingSystem = RefWeak(Game.GetTargetingSystem())
	audioSystem = RefWeak(Game.GetAudioSystem())
	autoSaveSystem = RefWeak(Game.GetAutoSaveSystem())
	navigationSystem = RefWeak(Game.GetNavigationSystem())
	statusEffectSystem = RefWeak(Game.GetStatusEffectSystem())

	if inGame then return end

	GameGetEngineTime = Game.GetEngineTime
	GameGetNodeTransform = Game.GetNodeTransform
	GameGetScriptableSystemsContainer = Game.GetScriptableSystemsContainer
	GameGetTeleportationFacility = Game.GetTeleportationFacility
	GameIsSavingLocked = Game.IsSavingLocked

	n_PreventionSystem = n"PreventionSystem"
	EPreventionHeatStageHeat_0 = EPreventionHeatStage.Heat_0

	GameGetSystemRequestsHandler = Game.GetSystemRequestsHandler
	GameFindEntityByID = Game.FindEntityByID
	HUDActorTypePUPPET = HUDActorType.PUPPET

	n_FreezePlayer = n"FreezePlayer"
	n_Linear = n"Linear"
	n_eyes_closing_instant_open_slow = n"eyes_closing_instant_open_slow"
	n_eyes_opening_05s = n"eyes_opening_05s"
	n_eyes_closing_fast = n"eyes_closing_fast"
	n_global_menu_phone_open = n"global_menu_phone_open"
	n_global_menu_phone_close = n"global_menu_phone_close"
	n_NoMovement = n"NoMovement"
end

local function addCharacterPerformerPreviewSupport()
	if not TweakDB:GetRecord("Character.hey_gle_prostitute_female_backup_mod_hotscenes") then TweakDB:CloneRecord("Character.hey_gle_prostitute_female_backup_mod_hotscenes", "Character.hey_gle_prostitute_female") end;
	if not TweakDB:GetRecord("Character.hey_gle_prostitute_male_backup_mod_hotscenes") then TweakDB:CloneRecord("Character.hey_gle_prostitute_male_backup_mod_hotscenes", "Character.hey_gle_prostitute_male") end;
	if not TweakDB:GetRecord("Character.wbr_jpn_prostitute_female_backup_mod_hotscenes") then TweakDB:CloneRecord("Character.wbr_jpn_prostitute_female_backup_mod_hotscenes", "Character.wbr_jpn_prostitute_female") end;
	if not TweakDB:GetRecord("Character.wbr_jpn_prostitute_male_backup_mod_hotscenes") then TweakDB:CloneRecord("Character.wbr_jpn_prostitute_male_backup_mod_hotscenes", "Character.wbr_jpn_prostitute_male") end;
	if not TweakDB:GetRecord("Character.preview_cc_prostitute_female_mod_hotscenes") then TweakDB:CloneRecord("Character.preview_cc_prostitute_female_mod_hotscenes", "Character.hey_gle_prostitute_female") end;
	if not TweakDB:GetRecord("Character.preview_cc_prostitute_male_mod_hotscenes") then TweakDB:CloneRecord("Character.preview_cc_prostitute_male_mod_hotscenes", "Character.hey_gle_prostitute_male") end;
	isPerformerPreviewSetupDone = true
end

local function IsDefinedNS(gameObj)
	if not gameObj then return false end
	local result, val = pcall(function() return IsDefined(gameObj) end)
	if result then return val else return false end
end

local nc_delights
local is_nc_delights_scene_extensions_supported

registerForEvent('onTweak', function()
	isArchiveXLActive = ArchiveXL ~= nil
	if not isArchiveXLActive then return end 
	nc_delights = GetMod("hotscenes_portable_scene_test")
	if type(nc_delights) ~= 'table' then nc_delights = require("hotscenes_nc_delights") else print("! DEBUG --> hotscenes_portable_scene_test mod loaded") end
end)

modInfoPrefix = modName.." "..modVer..":"

local isNudityCensored
registerForEvent('onInit', function()
	n = CName
	t = TweakDBID
	print("--------------------------------------------------------------------------")
	print(modName, modVer, 'is initializing. CET ver:', cetVerStr)
	pcall(function()
		if Codeware then
			print('Codeware detected:', Codeware.Version())
			isCodewareActive = true
		end
	end)

	if not isSupportedCet then
		if (not isCetSpawnerAllowed) and isCodewareActive then
			printError(modInfoPrefix, 'Unsupported CET version detected:', cetVerStr..'. Please update your CET to a stable version!')
			printError(modInfoPrefix, 'As Codeware is detected, this mod will run with a limited support.')
			isSupportedCet = true
		else
			printError(modInfoPrefix, 'Unsupported CET version detected:', cetVerStr..'. Please update your CET to a stable version. This mod is disabled now.')
			isModDisabled = true
			nativeUI.isModDisabled = true
			return
		end
	end

	varSetup()
	if not autoSaveSystem then
		printError(modInfoPrefix, "Your game\'s autosave system seems to be severely affected by other mods.\nThis mod cannot continue to function in this state and is disabled now.")
		isModDisabled = true
		nativeUI.isModDisabled = true
		return
	end

	isNudityCensored = isCensored()
	gameVer = tonumber(GameGetSystemRequestsHandler():GetGameVersion())
	isPreGameState = GameGetSystemRequestsHandler():IsPreGame()

	local isInSession = false
	if isInGameSession() then
		isInSession = true
		local isValid, playerGender = getPlayerBodyGender()
		if isValid then isPlayerMale = playerGender == "male" end
		isPerformerReplacingPlayerSupported = TweakDB:GetFlat("mod_hotscenes_next_gen_isPerformerReplacingPlayerSupported")
	end

	hotscenesLoadAndVerify()
	if isSupportedCet and Ref and isHotscenesDataLoaded then
		print(modInfoPrefix, 'hotscenes data loaded and verified.')
		isGameV2 = gameVer >= 2.0
		enable_mq055_hangouts_support = gameVer >= 2.1

		isArchiveXLActive = isArchiveXLActive or ArchiveXL ~= nil
		if isArchiveXLActive then
			pcall(function() print('ArchiveXL detected:', ArchiveXL.Version()) end)
		end

		queueTask(quickGetVersionInfo, false, 0.03)

		lastSceneSetupProgresstTimeout = sceneProgressDefaultTimeout

		setObservers()
		loadUserSettings()
		isMansionDLCModActive = GetMod("mansionDLC")
		isCetNpcBodyModActive = GetMod("CET_NPC_Body_Tweaks")

		lastKnownSaveMetadata = userSettings.lastKnownSaveMetadata

		cNamePauseMenuScenario = CName.new('MenuScenario_PauseMenu')
		n_save_game = n"save_game"

		slowMoParams.cNameSlowMoUserReason = CName.new('hotscenes_user')
		slowMoParams.cNameSlowMoSpycamReason = CName.new('hotscenes_spycam')
		slowMoParams.cNameSlowMoEaseInCurve = CName.new('Linear')
		slowMoParams.cNameSlowMoEaseOutCurve = CName.new('Linear')
		slowMoParams.slowMoSpeedFactor = 0.1
		slowMoParams.slowMoDuration = 30
		for i = 1, #h1_specs do h1_specs[i] = n(h1_specs[i]) end
		for k, v in ipairs(choker_spikes) do local val = v.componentName if type(val) == 'string' then choker_spikes[k].componentName = n(val) end end

		if isInSession then
			local player = GetPlayer()

			playerGenderSettings.playerSessionGenderName = nil
			playerGenderSettings.playerGenderOnPlaybackName = nil

			sceneState.sceneTier = player:GetSceneTier()
			if sceneState.sceneTier > 2 then
				sceneState.isPlayerUndressed = player:IsNaked()
				updateSceneState()
			else
				sceneState.isPlayerUndressed = false
				updateSceneState()
			end
		else
			sceneState.sceneTier = 0
			sceneState.isPlayerUndressed = false
			updateSceneState()
		end

		local shouldAllowSpycam = true
		if (not isCetSpawnerAllowed) and (not isCodewareActive) then shouldAllowSpycam = false end
		if shouldAllowSpycam then
			spycam = require('spycam')
			if spycam then
				spycam.input.slowMoParams = slowMoParams
				spycam.init(isInSession)
				updateSpycamParameters()
			end
		end
	else
		if not Ref then
			print(modName..' '..modVer, 'Error: Ref.lua file not found or it is corrupted. The mod is disabled now.')
			spdlog.error(modName..' '..modVer..' Error: Ref.lua file not found or it is corrupted. The mod is disabled now.')
		end
		if not isHotscenesDataLoaded then
			print(modName..' '..modVer, 'Error: hotscenes.lua file not found or unsupported version or the data is corrupted. The mod is disabled now.')
			spdlog.error(modName..' '..modVer..' Error: hotscenes.lua file not found or unsupported version or the data is corrupted. The mod is disabled now.')
		end
		return
	end

	if isGameV2 then IsDefinedNS = IsDefined end

	if isArchiveXLActive then
		nc_delights = nc_delights or GetMod("hotscenes_portable_scene_test")
		nc_delights = nc_delights or require("hotscenes_nc_delights")
		if type(nc_delights) == 'table' and type(nc_delights.mod) == 'table' and type(nc_delights.mod.onInit) == 'function' and type(nc_delights.mod.onUpdate) == 'function' then
			local moduleName = nc_delights.modName
			local moduleVer = nc_delights.modVer
			local moduleAuthorName = nc_delights.modAuthorName
			nc_delights = nc_delights.mod
			nc_delights.sceneState = sceneState
			nc_delights.queueTask = queueTask
			nc_delights.isModDisabled = isModDisabled
			nc_delights.userSettings = userSettings
			nc_delights.isControlledByMainMod = true
			nc_delights.h1_specs = h1_specs
			nc_delights.choker_spikes = choker_spikes
			nc_delights.startEyesClosed = startEyesClosed
			nc_delights.startOpenEyes = startOpenEyes
			nc_delights.startOpenEyesByTime = startOpenEyesByTime
			nc_delights.killEyesClosed = killEyesClosed
			nc_delights.setIsNewRepeat = function(newState) if type(newState) ~= 'boolean' then return end newRepeat = newState end
			nc_delights.defaultPerformerSceneSupport = defaultPerformerSceneSupport
			nc_delights.isHotscenesAllowed = isHotscenesAllowed
			nc_delights.getIsPreGame = function() return isPreGameState end
			nc_delights.isAnyGamePausingScreen = isAnyGamePausingScreen
			nc_delights.getIsMainModDisabled = function() return isModDisabled end
			nc_delights.getIsMainModInitialized = function() return isModInitialized end
			nc_delights.getIsMainArchiveDetected = function() return isArchiveDetected end
			nc_delights.getIsOverrideArchiveDetected = function() return isOverridesArchiveDetected end
			nc_delights.getIsUnsupportedOverrideArchiveDetected = function() return isUnsupportedOverridesArchiveDetected end
			print(modInfoPrefix, 'module found:', moduleName, moduleVer, 'by', moduleAuthorName)
			if nc_delights.ncdApi then
				nc_delights.ncdApi.modName = modName
				nc_delights.ncdApi.modVer = modVer
				nc_delights.ncdApi.modAuthorName = modAuthorName
				print(modInfoPrefix, moduleName, "API found, version:", nc_delights.ncdApi.apiVer)
			end
			nc_delights.onInit()
			if nc_delights.isInitialized then
				nc_delights.updateSettings()
			else
				print(moduleName, moduleVer, 'could not initialize. This module is disabled now.')
				nc_delights = nil
			end
		else
			nc_delights = nil
		end
	end
	local nui = GetMod("hotscenes_ui_test")
	if not nui then nui = require("hotscenes_native_ui") else print("! DEBUG --> hotscenes_ui_test mod loaded") end
	if type(nui) == 'table' and type(nui.nativeUI) == 'table' and type(nui.modName) == 'string' and type(nui.nativeUI.updateUI) == 'function' and type(nui.nativeUI.onInit) == 'function' then
		print(modInfoPrefix, 'module found:', nui.modName, nui.modVer, 'by', nui.modAuthorName)
		nativeUI = nui.nativeUI
		nativeUI.femaleScenes = femaleScenes
		nativeUI.femaleScenesIndex = femaleScenesIndex
		nativeUI.femaleScenesCount = femaleScenesCount
		nativeUI.maleScenes = maleScenes
		nativeUI.maleScenesIndex = maleScenesIndex
		nativeUI.maleScenesCount = maleScenesCount
		nativeUI.totalScenesCount = totalScenesCount
		nativeUI.femalePerformers = femalePerformers
		nativeUI.femalePerformersCount = femalePerformersCount
		nativeUI.malePerformers = malePerformers
		nativeUI.malePerformersCount = malePerformersCount
		nativeUI.totalPerformersCount = totalPerformersCount
		nativeUI.getPanelLogic = getPanelLogic
		nativeUI.userSettings = userSettings
		nativeUI.defaultUserSettings = defaultUserSettings
		nativeUI.mq055_hangouts_interaction = mq055_hangouts_interaction
		nativeUI.is_mq055_hangouts_interaction_activated = is_mq055_hangouts_interaction_activated
		nativeUI.sceneState = sceneState
		nativeUI.playback = playback
		nativeUI.queueTask = queueTask
		nativeUI.hotscenesLoadAndVerify = hotscenesLoadAndVerify
		nativeUI.updatePerformers = updatePerformers
		nativeUI.updateSceneState = updateSceneState
		nativeUI.verifyCustomSceneLocationData = verifyCustomSceneLocationData
		nativeUI.getOverridesArchiveState = function() return isOverridesArchiveDetected, isUnsupportedOverridesArchiveDetected, isOverridesArchiveSupportingSceneAvailabilityOverride end
		nativeUI.isHotscenesAvailable = function() return isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride) end
		nativeUI.isHotscenesAllowed = isHotscenesAllowed
		nativeUI.isPlaybackAllowed = function() return not isAnyGamePausingScreen() end
		nativeUI.isAddOnEnabled = function() return isOverridesArchiveDetected and userSettings.enableHotscenesAddon end
		nativeUI.isModDisabled = isModDisabled
		nativeUI.isNudityCensored = isNudityCensored
		nativeUI.isCustomTriggerQuestActive = isCustomTriggerQuestActive
		nativeUI.saveUserSettings = saveUserSettings
		nativeUI.nc_delights = nc_delights
		nativeUI.forceUpdateScenePerformersByPanelLogic = forceUpdateScenePerformersByPanelLogic
		nativeUI.setCinematicMode = setCinematicMode
		nativeUI.getCinematicMode = getCinematicMode
		nativeUI.getPerformerDataForPreview = getPerformerDataForPreview
		pcall(function() addCharacterPerformerPreviewSupport() end)
		nativeUI.isPerformerPreviewSetupDone = isPerformerPreviewSetupDone
		nativeUI.updateSpycamParameters = updateSpycamParameters
		nativeUI.onInit()
		nativeUI.isActive = nativeUI.isInitialized
		if uiDefaultStrings.nuiUiStrings and nativeUI.nativeUiDefaultUiStrings and nativeUI.nativeUiDefaultUiStrings.nuiUiStrings then
			local isAppended = false
			if uiDefaultStrings.nuiUiStrings.onscreenWarnings then
				if nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.exportOrder and uiDefaultStrings.nuiUiStrings.exportOrder then
					for i = 1, #uiDefaultStrings.nuiUiStrings.exportOrder do
						local shouldAppendThisKey = true
						for ii = 1, #nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.exportOrder do
							if nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.exportOrder[ii] == uiDefaultStrings.nuiUiStrings.exportOrder[i] then shouldAppendThisKey = false break end
						end
						if shouldAppendThisKey then tableInsert(nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.exportOrder, uiDefaultStrings.nuiUiStrings.exportOrder[i]) end
					end
				end
				if not nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings then
					nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings = uiDefaultStrings.nuiUiStrings.onscreenWarnings
				else
					if nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings.exportOrder and uiDefaultStrings.nuiUiStrings.onscreenWarnings.exportOrder then
						for i = 1, #uiDefaultStrings.nuiUiStrings.onscreenWarnings.exportOrder do
							local shouldAppendThisKey = true
							for ii = 1, #nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings.exportOrder do
								if nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings.exportOrder[ii] == uiDefaultStrings.nuiUiStrings.onscreenWarnings.exportOrder[i] then shouldAppendThisKey = false break end
							end
							if shouldAppendThisKey then tableInsert(nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings.exportOrder, uiDefaultStrings.nuiUiStrings.onscreenWarnings.exportOrder[i]) end
						end
					end
					for k, v in pairs(uiDefaultStrings.nuiUiStrings.onscreenWarnings) do
						if k ~= 'exportOrder' then
							nativeUI.nativeUiDefaultUiStrings.nuiUiStrings.onscreenWarnings[k] = v
							isAppended = true
						end
					end
				end
			end
			if isAppended then nativeUI.updateUiStrings() end
		end

		local exportTable = {}
		exportTable.exportOrder = {'fileHeader', 'uiStrings'}
		exportTable.fileHeader = exportedStringsFileHeader
		exportTable.uiStrings = nativeUI.nativeUiDefaultUiStrings.nuiUiStrings
		pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
		if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/nuiUiStrings.json") end

		if type(uiDefaultStrings.fullPerformerNames) == 'table' then
			local exportTable = {}
			exportTable.exportOrder = {'fileHeader', 'uiStrings'}
			exportTable.fileHeader = exportedStringsFileHeader
			exportTable.uiStrings = uiDefaultStrings.fullPerformerNames
			pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
			if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/performerStrings.json") end
		end

		if type(uiDefaultStrings.destinationNames) == 'table' then
			local exportTable = {}
			exportTable.exportOrder = {'fileHeader', 'uiStrings'}
			exportTable.fileHeader = exportedStringsFileHeader
			exportTable.uiStrings = uiDefaultStrings.destinationNames
			pcall(function() jsonDump = dumpTableToJson(exportTable, true, true) end)
			if type(jsonDump) == 'string' then saveTextFile(jsonDump, "language/en-us_template/destinationStrings.json") end
		end
	end
	local nativeSettings = GetMod("nativeSettings")
	if nativeSettings then
		print(modInfoPrefix, 'nativeSettings found: version', nativeSettings.version, 'by (c)keanuWheeze')
	end

	local lastlanguageSelected = userSettings.lastLanguageSelected
	loadLocalizedStrings(true, true)
	if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
	updatePerformers()

	isModInitialized = true
	print(modName, modVer, 'is initialized.')
	print("--------------------------------------------------------------------------")
end)

registerForEvent('onShutdown', function()
	if nc_delights and type(nc_delights.onShutdown) == 'function' then nc_delights.onShutdown() end
	if not nativeUI.onShutdown then return end
	nativeUI.onShutdown()
end)

if cetVer >= 1.26 then
	registerInput('openNativeUImenu', uiStrings.cetUiStrings.cetKeyBindings.openNativeUImenu, function(down)
		if not down then return end
		if not nativeUI.isInitialized then return end
		nativeUI.launchMainMenu()
	end)
end

registerInput('nanoDroneSpawn', uiStrings.cetUiStrings.cetKeyBindings.nanoDroneSpawn, function(down)
	if not down then return end
	if not GetPlayer then return end
	local player = GetPlayer()
	if not player then return end
	if not spycam then return end
	if not spycam.drone then return end
	if not sceneState.isSpycamAllowed then if not (sceneAvailabilityOverride or isDebug) then return end end

	if not spycam.drone.spawned then
		if questsSystem:GetFactStr("mod_hotscenes_spycam_activation_not_allowed") > 0 then return end
		if isAnyGamePausingScreen() then return end

		spycam.input.invertMouseVertically = userSettings.invertMouseVertically

		local limitByRaycast = true
		local traceTarget = true
		if traceTarget then spycam.drone.traceTarget = true else spycam.drone.traceTarget = false end

		spycam.drone.trackedEntityID = nil
		spycam.drone.traceTargetIsObject = true
		local yaw = nil
		if sceneState.performerEntID then
			local performerObj = GameFindEntityByID(sceneState.performerEntID)
			if performerObj then
				spycam.drone.trackedEntityID = sceneState.performerEntID
				local playerPos = player:GetWorldPosition()
				local performerPos = performerObj:GetWorldPosition()
				if vectorDistanceSquared2D(playerPos, performerPos) > 0 then
					local playerToPerformerRotation = Vector4.new(playerPos.x - performerPos.x, playerPos.y - performerPos.y, 0, 0):ToRotation()
					yaw = playerToPerformerRotation.yaw + 180
				end
			end
		elseif not (sceneAvailabilityOverride or isDebug) then return end
		spycam.spawnDroneKeyHandler(down, nil, yaw, limitByRaycast)
	elseif spycam.drone.fullySpawned then
		if questsSystem:GetFactStr("mod_hotscenes_spycam_deactivation_not_allowed") > 0 then return end
		spycam.drone:despawn()
		local payload = function() if GetPlayer() then toggleHudMainWindow(true) end end
		queueTask(payload, false, 2)
	end
end)

registerInput('nanoDroneW', uiStrings.cetUiStrings.cetKeyBindings.nanoDroneW, function(down)
	if not spycam then return end
	spycam.forwardKeyHandler(down)
end)

registerInput('nanoDroneS', uiStrings.cetUiStrings.cetKeyBindings.nanoDroneS, function(down)
	if not spycam then return end
	spycam.backwardKeyHandler(down)
end)

registerInput('nanoDroneA', uiStrings.cetUiStrings.cetKeyBindings.nanoDroneA, function(down)
	if not spycam then return end
	spycam.leftKeyHandler(down)
end)

registerInput('nanoDroneD', uiStrings.cetUiStrings.cetKeyBindings.nanoDroneD, function(down)
	if not spycam then return end
	spycam.rightKeyHandler(down)
end)

registerInput('hotscenesSlowMoToggle', uiStrings.cetUiStrings.cetKeyBindings.hotscenesSlowMoToggle, function(down)
	if not down then return end
	if (not sceneState.isSpycamAllowed) or (not sceneState.performerEntID) then print('Hotscenes Slow Motion playback outside the hotscenes is not allowed.') if not sceneAvailabilityOverride then return end end

	local isSlowMo = timeSystem:IsTimeDilationActive(slowMoParams.cNameSlowMoUserReason) or timeSystem:IsTimeDilationActive(slowMoParams.cNameSlowMoSpycamReason)
	if isSlowMo then
		timeSystem:UnsetTimeDilation(slowMoParams.cNameSlowMoUserReason, slowMoParams.cNameSlowMoEaseOutCurve)
		timeSystem:UnsetTimeDilation(slowMoParams.cNameSlowMoSpycamReason, slowMoParams.cNameSlowMoEaseOutCurve)
	else
		timeSystem:SetTimeDilation(slowMoParams.cNameSlowMoUserReason, slowMoParams.slowMoSpeedFactor, slowMoParams.slowMoDuration, slowMoParams.cNameSlowMoEaseInCurve, slowMoParams.cNameSlowMoEaseOutCurve)
	end
	audioSystem:PlayLootAllSound()
end)

function updateSpycamParameters()
	if not spycam then return end
	spycam.drone.orbitPitchWithMouse = userSettings.spycamOrbitPitchWithMouse
	spycam.drone.enableSpycamFreezeFrameToggleMode = userSettings.enableSpycamFreezeFrameToggleMode or isDebug
	spycam.input.invertMouseVertically = userSettings.invertMouseVertically
end

local nextUpdateTime, unfreezeEngineTimeTimeout, backOnGroundEngineTimeTimeout = 0, 0, 0
local unfreezeTimeFlag, shouldUnFreezeNow, isBackOnGround = false, false, false

local function restoreHud()
	if not GetPlayer() then return end
	toggleHudMainWindow(true)
end

local function updateNCD(delta)
	if not isModInitialized then return end
	if not nc_delights then return end
	nc_delights.onUpdate(delta)
	if not spycam then return end
	if not spycam.drone.fullySpawned then return end
	if sceneState.isNCDelightsScenePlaying then return end
	if not sceneState.nc_delightsDespawnSpycamRequest then return end
	if os.clock() >= sceneState.nc_delightsDespawnSpycamRequest then return end
	sceneState.nc_delightsDespawnSpycamRequest = nil
	spycam.drone:despawn()
	queueTask(restoreHud, false, 1)
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

local lastSceneSetupProgress = false
registerForEvent('onUpdate', function(delta)
	if not GetPlayer then return end

	processTaskQueue()
	updateNCD(delta)

	if spycam then spycam.update(delta) end
	if (not unfreezeTimeFlag) and (not lastSceneSetupProgress) and (not sceneState.isPlayerInScene) and (not isLookingForLastModSave) and (not shouldCleanupFromFileLookup) and (not sceneState.isNCDelightsScenePlaying) then return end

	local currTime = os.clock()
	if currTime > nextUpdateTime then nextUpdateTime = currTime + 0.5 else return end

	if sceneState.isPerformerPaid then
		if not sceneState.isPlayerInHotscene then nextUpdateTime = 0 end
	end

	if isLookingForLastModSave or shouldCleanupFromFileLookup then
		isLookingForLastModSave = lookForLastModFileName(isLookingForLastModSave)
	end

	if unfreezeTimeFlag then
		local currEngineTime = GameGetEngineTime():ToFloat()
		shouldUnFreezeNow = false
		if unfreezeEngineTimeTimeout < 1 then isBackOnGround = false unfreezeEngineTimeTimeout = currEngineTime + 15 backOnGroundEngineTimeTimeout = 0
		elseif currEngineTime > unfreezeEngineTimeTimeout then
			shouldUnFreezeNow = true
		else
			if not isBackOnGround then isBackOnGround = navigationSystem:IsOnGround(GetPlayer()) end
			if isBackOnGround then
				if sceneState.isLongDistanceTravel then
					if backOnGroundEngineTimeTimeout < 1 then
						backOnGroundEngineTimeTimeout = currEngineTime + 2.5
					else
						shouldUnFreezeNow = currEngineTime > backOnGroundEngineTimeTimeout
					end
					nextUpdateTime = 0
				else
					shouldUnFreezeNow = true
				end
			end
		end
		if shouldUnFreezeNow then
			unfreezeTimeFlag = false
			unfreezeEngineTimeTimeout = 0
			isBackOnGround = false
			backOnGroundEngineTimeTimeout = 0
			setFreezePlayer(false)
			shouldUnFreezeNow = false
		end
	elseif lastSceneSetupProgress then
		lastSceneSetupProgress = setAndProcessScenes(lastSceneSetupProgress)
	end

	sceneState.performerEntID = identifyHotscenePerformer(sceneState.isRomanceScene)
	extendHotsceneSequence(true)

	if not userSettings.isGenderSwitchFeatureEnabled then return end
	if not sceneState.shouldChangeGender then return end

	if currTime >= sceneState.changeGenderTime then
		if (not spycam.drone.spawnRequested) and (not spycam.drone.despawnRequested) then
			if sceneState.isPlayerInHotscene or sceneState.isOutro then
				-- placeholder
			else
				if type(playerGenderSettings.playerGenderOnPlaybackName) == 'string' then
					switchPlayerGenderRecordsTo(playerGenderSettings.playerGenderOnPlaybackName)
				end
			end
			sceneState.shouldChangeGender = false
		end
	end
end)

knownConflictingOtherMods = require("knownConflictingOtherModsWarnings")
if type(knownConflictingOtherMods) == 'table' and type(knownConflictingOtherMods.knownConflictingOtherMods) == 'table' then print("knownConflictingOtherMods loaded.") knownConflictingOtherMods = knownConflictingOtherMods.knownConflictingOtherMods end

local function printPotentiallyConflictingModsWarning()
	if not knownConflictingOtherMods then return end
	local outputStr = ""
	local isAnythingFound
	pcall(function()
		for i, knownConflictingModInfo in ipairs(knownConflictingOtherMods) do
			if type(knownConflictingModInfo.modArchiveFileName) == 'string' and ModArchiveExists(knownConflictingModInfo.modArchiveFileName) then
				isAnythingFound = true
				outputStr = outputStr.."\n"..knownConflictingModInfo.modTitle.."\tby "..knownConflictingModInfo.modAuthor
				if knownConflictingModInfo.alternativeModTitle then outputStr = outputStr.."\nand/or:".."\n"..knownConflictingModInfo.alternativeModTitle.."\tby "..knownConflictingModInfo.modAuthor end
				outputStr = outputStr.."\n\tReason:\t"..knownConflictingModInfo.reason
				if knownConflictingModInfo.modArchiveFileName then
					outputStr = outputStr.."\n\tArchive file location:\tarchive\\pc\\mod\\"..knownConflictingModInfo.modArchiveFileName
					if knownConflictingModInfo.hasMultipleAssociatedArchiveFiles then outputStr = outputStr.."\n\t\tRelated files note:\tthere may be more mod files associated with this archive file." end
				end
				if knownConflictingModInfo.modCetFolderName then outputStr = outputStr.."\n\tCET folder location:\tbin\\x64\\plugins\\cyber_engine_tweaks\\mods\\"..knownConflictingModInfo.modCetFolderName end
				if knownConflictingModInfo.disableFeatureNote then outputStr = outputStr.."\n\tDisabled features note:\t"..knownConflictingModInfo.disableFeatureNote end
			end
		end
	end)
	if not isAnythingFound then return end
	outputStr = modName.." "..modVer.."\nWarning: Potentially conflicting mods detected:"..outputStr
	outputStr = outputStr.."\n\n \nPlease note that this is just a warning - this mod does not disable the listed mods, nor do these mods disable this one (unless stated otherwise in the details above).\nIt\'s entirely up to you what to do about it: whether to ignore it, remove this/these mods, or update/replace them with ones that don't cause issues."
	outputStr = outputStr.."\nAdditionally, please note that the names of these mods may have changed."
	print("------------------------------------------------------------------------------------")
	print("\n ")
	print(outputStr, "\n ")
	print("------------------------------------------------------------------------------------")
	spdlog.warning(outputStr.."\n")
end

function quickGetVersionInfo(forceNew)
	getBaseAchiveVersionInfo(forceNew)
	getAddonAchiveVersionInfo(forceNew)
end

archiveCheckTimeout = 5
isBaseArchiveCheckRequested = false
getBaseAchiveVersionInfoTimeout = 0
function getBaseAchiveVersionInfo(forceNew)
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isArchiveDetected") then
		isArchiveDetected = true
		print(modInfoPrefix, 'Base archive file detected. Basic functionality is available.')
		queueTask(printPotentiallyConflictingModsWarning, false, 0.1)
		return true
	end

	if forceNew then isBaseArchiveCheckRequested = false end
	if not isBaseArchiveCheckRequested then
		local a = inkImage.new()
		a:SetAtlasResource(ResRef.FromName('base\\hotscenes\\version_info.inkatlas'))
		isBaseArchiveCheckRequested = true
		getBaseAchiveVersionInfoTimeout = os.clock() + archiveCheckTimeout or 5
		queueTask(getBaseAchiveVersionInfo, false, 0.1, 0.01, false)
		return true
	end

	local isTimeout = getBaseAchiveVersionInfoTimeout > 0 and os.clock() >= getBaseAchiveVersionInfoTimeout
	if not isArchiveDetected then
		for i = 1, #supportedArchiveVersionsInfo do
			if isKnownName(supportedArchiveVersionsInfo[i]) then isArchiveDetected = true break end
		end
		if isArchiveDetected then
			TweakDB:SetFlat("mod_hotscenes_next_gen_isArchiveDetected", true, 'Bool')
			isModDisabled = false
			nativeUI.isModDisabled = isModDisabled
			if nc_delights then nc_delights.isModDisabled = isModDisabled end
			print(modInfoPrefix, 'Base archive file detected. Basic functionality is available.')
			queueTask(printPotentiallyConflictingModsWarning, false, 0.1)
			return true
		else
			if not isTimeout then return end
			isModDisabled = true
			nativeUI.isModDisabled = isModDisabled
			if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
			if nc_delights then nc_delights.isModDisabled = isModDisabled end
			if spycam then
				spycam.disable()
				spycam = nil
			end
			if is_mq055_hangouts_interaction_activated() then mq055_hangouts_interaction.disableCustomChoices() end
			if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
			printError(modInfoPrefix, 'could not detect its mandatory archive file. This mod is disabled now.')
			printError('Please verify the file: \"...\\Cyberpunk 2077\\archive\\pc\\mod\\hotscenes_archive.stage.archive\"')
			return true
		end
	end
	if isTimeout then return true end
end

local isAddOnArchiveCheckRequested = false
local getAddonAchiveVersionInfoTimeout = 0
function getAddonAchiveVersionInfo(forceNew)
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isOverridesArchiveDetected") then isOverridesArchiveDetected = true end
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isOverridesArchiveSupportingSceneAvailaibilityOverride") then isOverridesArchiveSupportingSceneAvailabilityOverride = true end
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isUnsupportedOverridesArchiveDetected") then isUnsupportedOverridesArchiveDetected = true end
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isPerformerReplacingPlayerSupported") then isPerformerReplacingPlayerSupported = true end
	if isOverridesArchiveDetected then
		if isGameV21 then
			print(modInfoPrefix, 'Add-on archive file detected. Additional functionality is available.')
			printAddOnDetails()
			return true
		else
			print(modInfoPrefix, 'Add-on archive file detected but it\'s not supported on this game version. Additional functionality is not available.')
			isOverridesArchiveDetected = false
			TweakDB:SetFlat("mod_hotscenes_next_gen_isOverridesArchiveDetected", false, 'Bool')
			return true
		end
	end

	if forceNew then isAddOnArchiveCheckRequested = false end

	if not isAddOnArchiveCheckRequested then
		local a = inkImage.new()
		a:SetAtlasResource(ResRef.FromName('base\\hotscenes_overrides\\version_info.inkatlas'))
		isAddOnArchiveCheckRequested = true
		getAddonAchiveVersionInfoTimeout = os.clock() + archiveCheckTimeout or 5
		queueTask(getAddonAchiveVersionInfo, false, 0.1, 0.01, false)
		return true
	end

	local isTimeout = getAddonAchiveVersionInfoTimeout > 0 and os.clock() >= getAddonAchiveVersionInfoTimeout
	if not isOverridesArchiveDetected then
		local addonFileVersion
		for i = #supportedOverridesArchiveVersionsInfo, 1, -1 do
			if isKnownName(supportedOverridesArchiveVersionsInfo[i]) then addonFileVersion = supportedOverridesArchiveVersionsInfo[i] isOverridesArchiveDetected = true break end
		end
		if isOverridesArchiveDetected then
			if isGameV21 then
				TweakDB:SetFlat("mod_hotscenes_next_gen_isOverridesArchiveDetected", true, 'Bool')
				isOverridesArchiveSupportingSceneAvailabilityOverride = isKnownName("Hotscenes_overrides_mod_scene_availability_override_supported")
				if isKnownName("mod_hotscenes_player_performer_support_available") then
					isPerformerReplacingPlayerSupported = true
					TweakDB:SetFlat("mod_hotscenes_next_gen_isPerformerReplacingPlayerSupported", true, 'Bool')
				end
				if isOverridesArchiveSupportingSceneAvailabilityOverride then TweakDB:SetFlat("mod_hotscenes_next_gen_isOverridesArchiveSupportingSceneAvailaibilityOverride", true, 'Bool') end
				print(modInfoPrefix, 'Add-on archive file detected. Additional functionality is available.')
				printAddOnDetails(addonFileVersion)
				if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
				return true
			else
				print(modInfoPrefix, 'Add-on archive file detected but it\'s not supported on this game version. Additional functionality is not available.')
				isOverridesArchiveDetected = false
				TweakDB:SetFlat("mod_hotscenes_next_gen_isOverridesArchiveDetected", false, 'Bool')
				if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
				return true
			end
		else
			local isKnownUnsupportedVersion
			for i = #unsupportedOverridesArchiveVersionsInfo, 1, -1 do
				if isKnownName(unsupportedOverridesArchiveVersionsInfo[i]) then isKnownUnsupportedVersion = true break end
			end
			if isKnownUnsupportedVersion or ModArchiveExists("! hotscenes_add_on.archive") then
				isUnsupportedOverridesArchiveDetected = true
				TweakDB:SetFlat("mod_hotscenes_next_gen_isUnsupportedOverridesArchiveDetected", true, 'Bool')
				print(modInfoPrefix, 'Unsupported add-on archive file detected. Additional functionality is not available.\nPlease update your add-on:')
				print(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink)
				if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
				return true
			else
				if not isTimeout then return end
				print(modInfoPrefix, 'Add-on archive file not detected. Please consider installing the add-on to enable additional functionality:')
				print(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink)
				if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
				return true
			end
		end
	end
	if isTimeout then
		if nativeUI.setupNativeSettings then nativeUI.setupNativeSettings(true) end
		return true
	end
end

function printAddOnDetails(addonFileVersion)
	if type(addonFileVersion) ~= 'string' then
		for i = #supportedOverridesArchiveVersionsInfo, 1, -1 do
			if isKnownName(supportedOverridesArchiveVersionsInfo[i]) then addonFileVersion = supportedOverridesArchiveVersionsInfo[i] break end
		end
		if type(addonFileVersion) ~= 'string' then return end
	end
	pcall(function()
		addonFileVersion = stringGsub(addonFileVersion, "Hotscenes_overrides_mod_version_info_", "")
		local minor = stringGsub(addonFileVersion, "^[0-9]", "")
		local major = stringGsub(addonFileVersion, minor.."$", "")
		if stringLen(minor) > 2 then
			local middle = minor
			if tonumber(major) >= 5 then middle = stringGsub(minor, "[0-9][0-9]$", "") else middle = stringGsub(minor, "[0-9]$", "") end
			minor = stringGsub(minor, "^"..middle, "")
			if stringLen(minor) > 1 then minor = stringGsub(minor, "^0", "") end
			minor = middle.."."..minor
		end
		print("Add-on version:",  major.."."..minor)
		if not isArchiveXLActive then printError("Warning: Archive-XL not found. Add-on functionality is limited. Please install Archive-XL to enable full functionality.") end
	end)
end

local isQuestTriggerDeactivating
function deactivateAddon(force)
	if isQuestTriggerDeactivating and (not force) then print(modName..": The Add-on deactivation is in progress, Please wait...", os.clock()) return end
	if not isArchiveXLActive then print(modName..": Archive XL is not active.") return end
	if not isOverridesArchiveDetected then print(modName..": The Add-on is not found.") return end
	if not isKnownName("mod_hotscenes_custom_trigger_quest_available") then print(modName..": Game not loaded yet or this Add-on does support quest launcher.") return end
	if (not force) and (not isInGameSession()) then print(modName..": Your game is not loaded yet. Please try again once loaded.") return end
	if isGamePaused() then print(modName..": Game is paused. Please unpause the game to allow deactivation.") end
	if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then print(modName..": The Add-on is not activated.") return end
	print(modName..": Proceeding to deactivate the Add-on. Please wait...", os.clock())
	local timeout = os.clock() + 60
	local checkCountDown = 25
	questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_deactive", 0)
	local payload = function()
		if os.clock() > timeout then print(modName..": Deactivation timeout.", os.clock()) isQuestTriggerDeactivating = false questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_deactive", 0) return true end
		local isLauncherActive = questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") > 0
		if (not isLauncherActive) and (not isGamePaused()) then checkCountDown = checkCountDown - 1 end
		if checkCountDown <= 0 then
			print(modName..": The Add-on quest launcher is inactive now.", os.clock())
			isQuestTriggerDeactivating = false
			questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_deactive", 0)
			if nc_delights then
				local oldValue = userSettings.enableNCDelightsFeature
				userSettings.enableNCDelightsFeature = false
				nc_delights.updateSettings()
				userSettings.enableNCDelightsFeature = oldValue
			end
			return true
		end
		isQuestTriggerDeactivating = true
		questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_deactive", 1)
	end
	isQuestTriggerDeactivating = true
	queueTask(payload, false, 0.01, 0.005, false)
end

local gameLoadDeactivationTimeout = 0
function deactivateRedundantActivators(longer)
	if not isKnownName("mod_hotscenes_redundant_activators_deactivator_available") then return end
	gameLoadDeactivationTimeout = os.clock() + 0.25
	local payload = function() questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_active", 0) end
	payload()
	if not longer then return end
	queueTask(payload, false, 0.05)
	queueTask(payload, false, 0.1)
	queueTask(payload, false, 0.15)
end

local ep1PrerequisiteFacts = {'q301_02_done', 'q301_03_done', 'q302_done'}

function getDataFromPlugin(fullFilePath)
	if not stringMatch(fullFilePath, '%.json$') then return end
	local dataTable = loadJsonTable(fullFilePath)
	if type(dataTable) ~= 'table' then return end
	if type(dataTable.femalePerformers) ~= 'table' and type(dataTable.malePerformers) ~= 'table' and type(dataTable.enviroment) ~= 'table' then return end
	return dataTable
end

function collectFiles(path, output, level, maxLevel)
	path = path or "."
	output = output or {}
	level = level or 0
	if maxLevel and level > maxLevel then return output end
	local entries = dir(path)
	if not entries then return output end
	for i = 1, #entries do
		if entries[i].type == 'directory' then
			level = level + 1
			output = collectFiles(path.."/"..entries[i].name, output, level, maxLevel)
		else
			tableInsert(output, {filePath = path, fileName = entries[i].name, fullFilePath = path.."/"..entries[i].name, level = level})
		end
	end
	return output
end

function collectCharactersFromPlugins()
	local path = "plugins"

	local collectedFiles = collectFiles(path, output, level, 3)
	if not (type(collectedFiles) == 'table' and #collectedFiles > 1) then return end

	local collectedFilesLookup = {}
	local translations = {}
	local translationsCount = 0
	for i = #collectedFiles, 1, -1 do
		local pluginData = getDataFromPlugin(collectedFiles[i].fullFilePath)
		if type(pluginData) == 'table' then
			local fileId = stringGsub(collectedFiles[i].fullFilePath, '%.json$', "")
			fileId = stringGsub(fileId, path.."/", "")
			fileId = stringGsub(fileId, "/", "|")
			collectedFiles[i].fileId = fileId
			collectedFilesLookup[fileId] = collectedFiles[i]
			if type(pluginData.isTranslation) == 'boolean' and pluginData.isTranslation and type(pluginData.translatedFileName) == 'string' and stringFind(pluginData.translatedFileName, '.+%.json$') then
				collectedFiles[i].filePerformersData = {femalePerformers = {}, malePerformers = {}}
				collectedFiles[i].fileEnviromentData = {}
				collectedFiles[i].isTranslation = true
				collectedFiles[i].translatedFileFullPath = collectedFiles[i].filePath.."/"..pluginData.translatedFileName
				local translatedFileId = stringGsub(collectedFiles[i].translatedFileFullPath, '%.json$', "")
				translatedFileId = stringGsub(translatedFileId, path.."/", "")
				translatedFileId = stringGsub(translatedFileId, "/", "|")
				collectedFiles[i].translatedFileId = translatedFileId
				tableInsert(translations, {fileData = collectedFiles[i], pluginData = pluginData})
				translationsCount = #translations
			else
				collectedFiles[i].filePerformersData = {femalePerformers = pluginData.femalePerformers, malePerformers = pluginData.malePerformers}
				if type(collectedFiles[i].filePerformersData.femalePerformers) ~= 'table' then collectedFiles[i].filePerformersData.femalePerformers = {} end
				if type(collectedFiles[i].filePerformersData.malePerformers) ~= 'table' then collectedFiles[i].filePerformersData.malePerformers = {} end
				collectedFiles[i].fileEnviromentData = pluginData.enviroment
				if type(collectedFiles[i].fileEnviromentData) ~= 'table' then collectedFiles[i].fileEnviromentData = {} end
			end
		else
			tableRemove(collectedFiles, i)
		end
	end

	if translationsCount > 0 then
		for i = 1, translationsCount do
			local lookedFileId = translations[i].fileData.translatedFileId
			local lookedFile = collectedFilesLookup[lookedFileId]
			if lookedFile then
				local translationData = translations[i].pluginData
				local translationFilePerformersData = {femalePerformers = translationData.femalePerformers, malePerformers = translationData.malePerformers}
				for performersGroup, performers in pairs(translationFilePerformersData) do
					if type(performers) == 'table' then
						for performerId, performerData in pairs(performers) do
							if type(performerData) == 'table' and type(performerData.performerFullNameTranslations) then
								local lookedPerformerData = false
								if type(lookedFile.filePerformersData[performersGroup]) == 'table' then lookedPerformerData = lookedFile.filePerformersData[performersGroup][performerId] end
								if type(lookedPerformerData) == 'table' then
									if type(lookedPerformerData.performerFullNameTranslations) == 'table' then
										for lang, translation in pairs(performerData.performerFullNameTranslations) do
											local lookedTranslationForLang = lookedPerformerData.performerFullNameTranslations[lang]
											if type(lookedTranslationForLang) == 'table' then
												for uiType, translatedUiString in pairs(translation) do
													if type(translatedUiString) == 'string' and stringLen(translatedUiString) > 0 then lookedTranslationForLang[uiType] = translatedUiString end
												end
											else
												lookedPerformerData.performerFullNameTranslations[lang] = cloneTable(performerData.performerFullNameTranslations[lang])
											end
										end
									else
										lookedPerformerData.performerFullNameTranslations = cloneTable(performerData.performerFullNameTranslations)
									end
								end
							end
						end
					end
				end
			end
		end

		for i = #collectedFiles, 1, -1 do
			if collectedFiles[i].isTranslation then tableRemove(collectedFiles, i) end
		end
	end

	return collectedFiles
end

local collectedPluginCharacters = collectCharactersFromPlugins()

function appendPluginCharacters()
	shouldAppendCustomPerformers = false

	local loadedData = collectedPluginCharacters
	if type(loadedData) ~= 'table' then return end
	if #loadedData < 1 then return end

	local genders = {'female', 'male'}
	local counts = {female = 0, male = 0}
	local sourceScenes = {hotscenesData.femaleScenes, hotscenesData.maleScenes}
	local loadedScenes = {femaleScenes, maleScenes}

	isEp1Allowed = isStringValid(rootFolderEp1) and journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry') and TweakDB:GetRecord("Character.bella")
	isEp1Allowed = isEp1Allowed ~= nil
	local shouldAllowPerformer = true

	tableSort(loadedData, function(a, b) -- psiberx hint
		return a.fileId > b.fileId
	end)

	local loadedPerformers = {femalePerformers, malePerformers}

	for i, fileData in ipairs(loadedData) do
		local fileId = fileData.fileId
		if not fileData.filePerformersData.femalePerformers then fileData.filePerformersData.femalePerformers = {} end
		if not fileData.filePerformersData.malePerformers then fileData.filePerformersData.malePerformers = {} end
		local sourcePerformers = {fileData.filePerformersData.femalePerformers, fileData.filePerformersData.malePerformers}
		for s = 1, #sourcePerformers do
			if sourceScenes[s] and sourcePerformers[s] then
				local gender = genders[s]
				if type(loadedScenes[s].uniquePerformerFullNames) ~= 'table' then loadedScenes[s].uniquePerformerFullNames = {} end
				local uniquePerformerFullNames = loadedScenes[s].uniquePerformerFullNames
				for performer, performerData in pairs(sourcePerformers[s]) do
					if type(performerData) ~= 'table' then
						sourcePerformers[s][performer] = nil
					elseif stringMatch(fileId, "anygoodname_mods") and stringMatch(performer, "_no_fishnets") then
						sourcePerformers[s][performer] = nil
					else
						if (not sourcePerformers[s][performer].sceneSupport) and stringMatch(fileId, "little_china_tourists") and stringMatch(fileId, "anygoodname_mods") then
							sourcePerformers[s][performer].sceneSupport = "default"
						end
						if not performerData.isArchiveVerified then
							if type(performerData.archiveFilesRequired) ~= 'table' or #performerData.archiveFilesRequired < 1 then
								performerData.isDisabled = true
							else
								local cnt = 0
								for i = 1, #performerData.archiveFilesRequired do
									local fileName = performerData.archiveFilesRequired[i]
									if type(fileName) == 'string' then
										if fileName == 'game_files' or ModArchiveExists(fileName) then cnt = cnt + 1 else break end
									end
								end
								if cnt < 1 or cnt ~= #performerData.archiveFilesRequired then performerData.isDisabled = true end
							end
							performerData.isArchiveVerified = true
						end
						if performerData.isDisabled then
							sourcePerformers[s][performer] = nil
						elseif type(performerData.scenes) == 'table' then
							if type(performerData.fileInfo) == 'string' then
								if not performerData.fileInfoIsVerified then
									if stringFind(performerData.fileInfo, "fileinfo%.inkatlas$") then
										if isKnownName(performerData.fileInfo) then
											performerData.fileInfoIsVerified = true
										else
											local performerRec = performerData
											local payload = function()
												local resRef = ResRef.FromName(performerRec.fileInfo)
												local lookedId = stringGsub(tostring(resRef.resource.hash), "ULL$", "")
												local a = inkImage.new() a:SetAtlasResource(resRef)
												local payload = function()
													if type(performerRec) ~= 'table' then return end
													if performerRec.isDisabled then return end
													if isKnownName(lookedId) then
														performerRec.fileInfoIsVerified = true
													else
														performerRec.isDisabled = true
													end
													if performerRec.isDisabled then updatePerformers() end
												end
												queueTask(payload, false, 3)
											end
											queueTask(payload, false, 3)
										end
									else
										performerData.isDisabled = true
									end
								end
							end
							if (not performerData.isDisabled) and type(performerData.gender) == 'string' then
								shouldAllowPerformer = true
								if (not isGameV2) and (not performerData.isLegacyDataType) then shouldAllowPerformer = false end
								if shouldAllowPerformer and performerData.gender == gender and type(performerData.performerFullName) == 'string' then
									local entitiesVerified = false
									if uniquePerformerFullNames[performerData.performerFullName] then
										shouldAllowPerformer = false
										print(modInfoPrefix, 'Performer', performer, performerData.performerFullName, 'already exists. Trying to rename duplicated entry...')
										local duplicateIndex
										for i = 1, 99 do
											duplicateIndex = i
											local newPerformerFullName = performerData.performerFullName.." (".. stringFormat("%02d", i) ..")"
											if not uniquePerformerFullNames[newPerformerFullName] then performerData.performerFullName = newPerformerFullName shouldAllowPerformer = true break end
										end
										if shouldAllowPerformer then
											performerData.duplicateIndex = duplicateIndex
										else print("Could not rename", performerData.performerFullName, "Skipping the entry.") end
									end
									if shouldAllowPerformer then
										for scene, sceneData in pairs(sourceScenes[s]) do
											local entityPath = nil
											if performerData.scenes[scene] and performerData.scenes[scene].fullPerformerEntPath then
												if type(performerData.scenes[scene].fullPerformerEntPath) == 'string' then
													if stringMatch(performerData.scenes[scene].fullPerformerEntPath, '%.ent$') then 
														entityPath = performerData.scenes[scene].fullPerformerEntPath
													end
												end
												if type(entityPath) == 'string' and stringLen(entityPath) > 4 and (not stringFind(entityPath, " ")) then
													entitiesVerified = true
													local missingOnTheList = true
													for p = 1, #loadedScenes[s][scene].performersIndex do if loadedScenes[s][scene].performersIndex[p] == performer then missingOnTheList = false break end end
													if missingOnTheList then
														tableInsert(loadedScenes[s][scene].performersIndex, performer)
														tableInsert(loadedScenes[s][scene].allScenePerformersIndex, scene)
													end
													uniquePerformerFullNames[performerData.performerFullName] = true
													loadedScenes[s].uniquePerformerFullNames = uniquePerformerFullNames
												end
											end
										end
									end
									if entitiesVerified then
										local newPerformerId = fileId.."|"..performer
										performerData.isPlugin = true
										loadedPerformers[s][newPerformerId] = performerData
										counts[gender] = counts[gender] + 1
									end
								end
							end
						end
					end
				end
			end
		end

		femalePerformersCount = femalePerformersCount + counts.female
		malePerformersCount = malePerformersCount + counts.male
	end
end

function hotscenesLoadAndVerify(isUpdate, forceUpdate)
	if isUpdate then
		if not isHotscenesDataLoaded then return false end
		if (not forceUpdate) and (not shouldKeepUpdatingEp1Performers) then return end
		femaleScenes = {} femaleScenesIndex = {} femaleScenesCount = 0
		maleScenes = {} maleScenesIndex = {} maleScenesCount = 0
		totalScenesCount = 0
		femalePerformers = {} femalePerformersCount = 0
		malePerformers = {} malePerformersCount = 0
		totalPerformersCount = 0
		nativeUI.totalPerformersCount = 0
		shouldAppendCustomPerformers = true
	else
		isHotscenesDataLoaded = false
		rootFolder = nil
		rootFolderEp1 = nil
		femaleScenes = {} femaleScenesIndex = {} femaleScenesCount = 0
		maleScenes = {} maleScenesIndex = {} maleScenesCount = 0
		totalScenesCount = 0
		femalePerformers = {} femalePerformersCount = 0
		malePerformers = {} malePerformersCount = 0
		totalPerformersCount = 0
		nativeUI.totalPerformersCount = 0
		shouldAppendCustomPerformers = true
		if gameVer < 1 then gameVer = tonumber(GameGetSystemRequestsHandler():GetGameVersion()) end
		if gameVer < 1.5 then
			gvs = false
			print(modInfoPrefix, 'Unsupported game version detected. The mod is disabled now.')
			spdlog.error(modName..' '..modVer..': Unsupported game version detected. The mod is disabled now.')
			return false
		end

		if not hotscenesData.isFileLoaded then
			hotscenesData = require('hotscenes')
			if type(hotscenesData) ~= 'table' then return false end
			if type(hotscenesData.datasetVer) ~= 'number' then return false end
			hotscenesData.isFileLoaded = true
		end

		local isCharacterDatasetSupported = false
		for i = #supportedCharacterDatasetVersions, 1, -1 do
			if hotscenesData.datasetVer == supportedCharacterDatasetVersions[i] then isCharacterDatasetSupported = true break end
		end
		if not isCharacterDatasetSupported then return false end
	end

	nativeUI.femaleScenes = femaleScenes
	nativeUI.femaleScenesIndex = femaleScenesIndex
	nativeUI.femaleScenesCount = femaleScenesCount
	nativeUI.maleScenes = maleScenes
	nativeUI.maleScenesIndex = maleScenesIndex
	nativeUI.maleScenesCount = maleScenesCount
	nativeUI.totalScenesCount = totalScenesCount
	nativeUI.femalePerformers = femalePerformers
	nativeUI.femalePerformersCount = femalePerformersCount
	nativeUI.malePerformers = malePerformers
	nativeUI.malePerformersCount = malePerformersCount
	nativeUI.totalPerformersCount = totalPerformersCount

	local fullPerformerNames = nil
	if hotscenesData.rootFolder then
		if isUpdate then
			shouldKeepUpdatingEp1Performers = false
		else
			rootFolder = hotscenesData.rootFolder
			rootFolderEp1 = hotscenesData.rootFolderEp1
			isEp1Allowed = isStringValid(rootFolderEp1) and journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry') and TweakDB:GetRecord("Character.bella")
			isEp1Allowed = isEp1Allowed ~= nil
		end

		local shouldAllowPerformer = true

		if isUpdate or (type(rootFolder) == 'string' and stringLen(rootFolder) > 3) then
			local genders = {'female', 'male'}
			local counts = {female = 0, male = 0}

			local sourceScenes = {hotscenesData.femaleScenes, hotscenesData.maleScenes}
			local loadedScenes = {femaleScenes, maleScenes}
			local sceneIndexes = {femaleScenesIndex, maleScenesIndex}

			for s, sceneSource in ipairs(sourceScenes) do
				local gender = genders[s]
				for scene, sceneData in pairs(sceneSource) do
					if type(sceneData.tdbidPath) == 'string' and stringMatch(sceneData.tdbidPath, '^Character.*entityTemplatePath$') then
						sceneData.characterTdbidHash = TweakDBID.new(sceneData.characterTdbidPath).hash
						loadedScenes[s][scene] = sceneData
						counts[gender] = counts[gender] + 1 
						if isUpdate or (not loadedScenes[s][scene].performersIndex) then
							loadedScenes[s][scene].performersIndex = {}
							loadedScenes[s][scene].allScenePerformersIndex = {}
						end
						tableInsert(loadedScenes[s][scene].performersIndex, scene)
						tableInsert(loadedScenes[s][scene].allScenePerformersIndex, scene)
						tableInsert(sceneIndexes[s], scene)
					end
				end
			end

			femaleScenesCount = counts.female
			maleScenesCount = counts.male
			totalScenesCount = femaleScenesCount + maleScenesCount
			nativeUI.femaleScenesCount = femaleScenesCount
			nativeUI.maleScenesCount = maleScenesCount

			if totalScenesCount > 0 then
				counts = {female = 0, male = 0}
				local sourcePerformers = {hotscenesData.femalePerformers, hotscenesData.malePerformers}
				local loadedPerformers = {femalePerformers, malePerformers}
				fullPerformerNames = {}
				for s = 1, #sourcePerformers do
					if sourceScenes[s] and sourcePerformers[s] then
						local gender = genders[s]
						if type(loadedScenes[s].uniquePerformerFullNames) ~= 'table' then loadedScenes[s].uniquePerformerFullNames = {} end
						local uniquePerformerFullNames = loadedScenes[s].uniquePerformerFullNames
						fullPerformerNames[gender] = {}
						for performer, performerData in pairs(sourcePerformers[s]) do
							if performerData.scenes then
								if performerData.gender then
									fullPerformerNames[gender][performer] = performerData.performerFullName or performer
									shouldAllowPerformer = true
									if shouldAllowPerformer and performerData.gender == gender and type(performerData.performerFullName) == 'string' then
										local entitiesVerified = false
										if uniquePerformerFullNames[performerData.performerFullName] then
											shouldAllowPerformer = false
											print(modInfoPrefix, 'Performer', performer, performerData.performerFullName, 'already exists. Trying to rename duplicated entry...')
											local duplicateIndex
											for i = 1, 99 do
												duplicateIndex = i
												local newPerformerFullName = performerData.performerFullName.." (".. stringFormat("%02d", i) ..")"
												if not uniquePerformerFullNames[newPerformerFullName] then performerData.performerFullName = newPerformerFullName shouldAllowPerformer = true break end
											end
											if shouldAllowPerformer then
												performerData.duplicateIndex = duplicateIndex
												fullPerformerNames[gender][performer] = performerData.performerFullName
												print("New performer name:", performerData.performerFullName)
											else print("Could not rename", performerData.performerFullName, "Skipping the entry.") end
										end
										if shouldAllowPerformer then
											for scene, sceneData in pairs(sourceScenes[s]) do
												local performerSceneData = performerData.scenes[scene]
												if performerSceneData then
													local isPlayer = performerData.isPlayer
													local entityPath = performerSceneData.performerEntPath
													if (not isPlayer) and type(entityPath) == 'string' and stringMatch(entityPath, '.+ent$') then
														if performerData.isEp1 or stringMatch(performer, "_ep1$") then
															entityPath = rootFolderEp1..scene..'\\'..entityPath
														else
															entityPath = rootFolder..scene..'\\'..entityPath
														end
													else
														entityPath = nil
													end

													if isPlayer or (entityPath and stringLen(entityPath) > 4 and (not stringFind(entityPath, " "))) then
														entitiesVerified = true
														local missingOnTheList = true
														for p = 1, #loadedScenes[s][scene].performersIndex do if loadedScenes[s][scene].performersIndex[p] == performer then missingOnTheList = false break end end
														if missingOnTheList then
															tableInsert(loadedScenes[s][scene].performersIndex, performer)
															tableInsert(loadedScenes[s][scene].allScenePerformersIndex, scene)
														end
														uniquePerformerFullNames[performerData.performerFullName] = true
														loadedScenes[s].uniquePerformerFullNames = uniquePerformerFullNames
													end
												end
											end
										end
										if entitiesVerified then
											loadedPerformers[s][performer] = performerData
											counts[gender] = counts[gender] + 1
											isHotscenesDataLoaded = true
										end
									end
								end
							end
						end
					end
				end
				femalePerformersCount = counts.female
				malePerformersCount = counts.male
			end
		end
	end

	if not isHotscenesDataLoaded then return false end

	totalPerformersCount = femalePerformersCount + malePerformersCount

	if totalPerformersCount > 0 and type(uiDefaultStrings.fullPerformerNames) ~= 'table' then
		uiDefaultStrings.fullPerformerNames = {female = {}, male = {}}
		if type(fullPerformerNames.female) == 'table' then
			for key, v in pairs(fullPerformerNames.female) do
				uiDefaultStrings.fullPerformerNames.female[key] = {cetUi = v, nativeUi = v}
			end
		end
		if type(fullPerformerNames.male) == 'table' then
			for key, v in pairs(fullPerformerNames.male) do
				uiDefaultStrings.fullPerformerNames.male[key] = {cetUi = v, nativeUi = v}
			end
		end
	end

	if femaleScenesIndex then tableSort(femaleScenesIndex) end
	if maleScenesIndex then tableSort(maleScenesIndex) end

	if shouldAppendCustomPerformers then appendPluginCharacters() end

	nativeUI.femaleScenes = femaleScenes
	nativeUI.femaleScenesIndex = femaleScenesIndex
	nativeUI.femaleScenesCount = femaleScenesCount
	nativeUI.maleScenes = maleScenes
	nativeUI.maleScenesIndex = maleScenesIndex
	nativeUI.maleScenesCount = maleScenesCount
	nativeUI.totalScenesCount = totalScenesCount
	nativeUI.femalePerformers = femalePerformers
	nativeUI.femalePerformersCount = femalePerformersCount
	nativeUI.malePerformers = malePerformers
	nativeUI.malePerformersCount = malePerformersCount
	nativeUI.totalPerformersCount = totalPerformersCount

	updatePerformers()

	return isHotscenesDataLoaded
end

function updatePerformers()
	if isModDisabled then return end
	if not isHotscenesDataLoaded then return end
	if not GetPlayer then return end
	if not GetPlayer() then return end

	local shouldApplyPerformerFiltering = (not isPreGame(true)) and isInGameSession()
	local shouldAllowPerformer = true

	local scenes = {femaleScenes, maleScenes}
	local loadedPerformers = {femalePerformers, malePerformers}
	local genders = {'female', 'male'}
	local counts = {female = 0, male = 0}
	for s, sceneScene in ipairs(scenes) do
		local gender = genders[s]
		local performer = nil
		for sceneName, sceneData in pairs(sceneScene) do
			if sceneData.allScenePerformersIndex and #sceneData.allScenePerformersIndex > 0 then
				local newPerformersFullNameIndex = {}
				local newPerformersFullNameIndexCetUi = {}
				local newPerformersFullNameIndexNativeUi = {}
				local newPerformersPersonalRecords = {}
				sceneData.performersFullNameIndex = {}
				sceneData.performersFullNameIndexCetUi = {}
				sceneData.performersFullNameIndexNativeUi = {}
				local scenePerformers = loadedPerformers[s]

				sceneData.performersIndex = {}
				for performer, performerData in pairs(scenePerformers) do
					shouldAllowPerformer = true
					if performerData.isDisabled then
						shouldAllowPerformer = false
					elseif shouldApplyPerformerFiltering then
						if performerData.isPlayer then
							if userSettings.enableHotscenesAddon then
								if userSettings[gender] then
									shouldAllowPerformer = userSettings[gender][sceneName].enableFastTrackPlayback or sceneData.isAvailableOnlyInOverrideMode
								end
								if userSettings.isPlayerPerformerDiscovered then
									if performer == 'player_incognito' then shouldAllowPerformer = false end
								else
									if performer == 'player' then shouldAllowPerformer = false end
								end
								if shouldAllowPerformer then
									shouldAllowPerformer = isPerformerReplacingPlayerSupported and ((isPlayerMale and gender == 'male') or ((not isPlayerMale) and gender == 'female'))
								end
								shouldKeepUpdatingEp1Performers = true
							else
								shouldAllowPerformer = false
							end
						elseif performerData.isEp1 or stringMatch(performer, "_ep1$") then
							if not isEp1Allowed then
								shouldAllowPerformer = false
							else
								local prerequisiteFacts = performerData.prerequisiteFacts
								if not (type(prerequisiteFacts) == 'table' and #prerequisiteFacts > 0) then prerequisiteFacts = ep1PrerequisiteFacts end
								shouldAllowPerformer = false
								for i = 1, #prerequisiteFacts do
									if questsSystem:GetFactStr(prerequisiteFacts[i]) > 0 then
										shouldAllowPerformer = true
										break
									end
								end
								if not shouldAllowPerformer then shouldKeepUpdatingEp1Performers = true end
							end
						end
						if shouldAllowPerformer then
							if type(performerData.prerequisiteFacts) == 'table' and #performerData.prerequisiteFacts > 0 then
								shouldAllowPerformer = false
								for i = 1, #performerData.prerequisiteFacts do
									if questsSystem:GetFactStr(performerData.prerequisiteFacts[i]) > 0 then
										shouldAllowPerformer = true
										break
									end
								end
								if not shouldAllowPerformer then shouldKeepUpdatingEp1Performers = true end
							end
						end
					end

					if shouldAllowPerformer then
						tableInsert(sceneData.performersIndex, performer)
						counts[gender] = #sceneData.performersIndex
						
						local performerPersonalRecord = {performer = performer}
						performerPersonalRecord.performerFullName = scenePerformers[performer].performerFullName or performer
						performerPersonalRecord.performerFullNameCetUi = performerPersonalRecord.performerFullName
						performerPersonalRecord.performerFullNameNativeUi = performerPersonalRecord.performerFullName
						if scenePerformers[performer].isPlugin then
							if scenePerformers[performer].performerFullNameTranslations then
								local translation = scenePerformers[performer].performerFullNameTranslations[currentUiLanguage]
								local duplicateIndex = scenePerformers[performer].duplicateIndex
								if translation then
									if isStringValid(translation.cetUi) then
										performerPersonalRecord.performerFullNameCetUi = translation.cetUi
										if duplicateIndex then performerPersonalRecord.performerFullNameCetUi = performerPersonalRecord.performerFullNameCetUi.." ("..tostring(duplicateIndex)..")" end
									end
									if isStringValid(translation.nativeUi) then
										performerPersonalRecord.performerFullNameNativeUi = GetLocalizedText(translation.nativeUi)
										if duplicateIndex then performerPersonalRecord.performerFullNameNativeUi = performerPersonalRecord.performerFullNameNativeUi.." ("..tostring(duplicateIndex)..")" end
									end
								end
							end
						else
							if uiStrings.fullPerformerNames and uiStrings.fullPerformerNames[gender] then
								local result, data = pcall(function()
									local duplicateIndex = scenePerformers[performer].duplicateIndex
									local translatedName = uiStrings.fullPerformerNames[gender][performer].cetUi
									if isStringValid(translatedName) then
										performerPersonalRecord.performerFullNameCetUi = translatedName
										if duplicateIndex then performerPersonalRecord.performerFullNameCetUi = performerPersonalRecord.performerFullNameCetUi.." ("..tostring(duplicateIndex)..")" end
									end
									local translatedName = GetLocalizedText(uiStrings.fullPerformerNames[gender][performer].nativeUi)
									if isStringValid(translatedName) then
										performerPersonalRecord.performerFullNameNativeUi = translatedName
										if duplicateIndex then performerPersonalRecord.performerFullNameCetUi = performerPersonalRecord.performerFullNameCetUi.." ("..tostring(duplicateIndex)..")" end
									end
								end)
								if not result then spdlog.error(data) end
							end
						end
						tableInsert(newPerformersPersonalRecords, performerPersonalRecord)
					end
				end

				if #newPerformersPersonalRecords > 0 then
					if userSettings.sortByDisplayName then
						tableSort(newPerformersPersonalRecords, function(a, b) -- psiberx hint
							return (a.performerFullNameNativeUi or a.performerFullNameCetUi or a.performerFullName) < (b.performerFullNameNativeUi or a.performerFullNameCetUi or b.performerFullName)
						end)
					else
						tableSort(newPerformersPersonalRecords, function(a, b) -- psiberx hint
							return a.performerFullName < b.performerFullName
						end)
					end
					local newPerformersIndex = {}
					for i = 1, #newPerformersPersonalRecords do
						tableInsert(newPerformersIndex, newPerformersPersonalRecords[i].performer)
						tableInsert(newPerformersFullNameIndex, newPerformersPersonalRecords[i].performerFullName)
						tableInsert(newPerformersFullNameIndexCetUi, newPerformersPersonalRecords[i].performerFullNameCetUi)
						tableInsert(newPerformersFullNameIndexNativeUi, newPerformersPersonalRecords[i].performerFullNameNativeUi)
					end
					if #newPerformersIndex == #sceneData.performersIndex then
						sceneData.performersIndex = newPerformersIndex
						sceneData.performersFullNameIndex = newPerformersFullNameIndex
						sceneData.performersFullNameIndexCetUi = newPerformersFullNameIndexCetUi
						sceneData.performersFullNameIndexNativeUi = newPerformersFullNameIndexNativeUi
					end
				end
			end
		end
	end

	femalePerformersCount = counts.female
	malePerformersCount = counts.male
	totalPerformersCount = femalePerformersCount + malePerformersCount

	nativeUI.femaleScenes = femaleScenes
	nativeUI.femaleScenesIndex = femaleScenesIndex
	nativeUI.femaleScenesCount = femaleScenesCount
	nativeUI.maleScenes = maleScenes
	nativeUI.maleScenesIndex = maleScenesIndex
	nativeUI.maleScenesCount = maleScenesCount
	nativeUI.totalScenesCount = totalScenesCount
	nativeUI.femalePerformers = femalePerformers
	nativeUI.femalePerformersCount = femalePerformersCount
	nativeUI.malePerformers = malePerformers
	nativeUI.malePerformersCount = malePerformersCount
	nativeUI.totalPerformersCount = totalPerformersCount
end

function restorePlayerGenderRecords()
	if not userSettings.isGenderSwitchFeatureEnabled then return true, true end
	local femaleRestored, maleRestored = false, false
	if TweakDB:GetFlat(gamePlayerGendersDefaults.female.recordPathStr).hash == gamePlayerGendersDefaults.male.valueHashInt then femaleRestored = true TweakDB:SetFlat(gamePlayerGendersDefaults.female.recordPathStr, TweakDBID.new(gamePlayerGendersDefaults.female.valueStr)) end
	if TweakDB:GetFlat(gamePlayerGendersDefaults.male.recordPathStr).hash == gamePlayerGendersDefaults.female.valueHashInt then maleRestored = true TweakDB:SetFlat(gamePlayerGendersDefaults.male.recordPathStr, TweakDBID.new(gamePlayerGendersDefaults.male.valueStr)) end

	if isInGameSession() then playerGenderSettings.playerSessionGenderName = GetPlayer():GetResolvedGenderName() else playerGenderSettings.playerSessionGenderName = nil end
	if playerGenderSettings.playerSessionGenderName then if playerGenderSettings.playerSessionGenderName.value then playerGenderSettings.playerSessionGenderName = playerGenderSettings.playerSessionGenderName.value end end

	return femaleRestored or maleRestored
end

function switchPlayerGenderRecordsTo(targetGender)
	if not userSettings.isGenderSwitchFeatureEnabled then return false end
	if type(targetGender) ~= 'string' then return false end
	restorePlayerGenderRecords()
	if type(playerGenderSettings.playerSessionGenderName) ~= 'string' then return false end
	if targetGender == 'Female' then
		if playerGenderSettings.playerSessionGenderName == 'Female' then
			-- placeholder
		elseif playerGenderSettings.playerSessionGenderName == 'Male' then
			TweakDB:SetFlat(gamePlayerGendersDefaults.male.recordPathStr, TweakDBID.new(gamePlayerGendersDefaults.female.valueStr))
		else
			return false
		end
	elseif targetGender == 'Male' then
		if playerGenderSettings.playerSessionGenderName == 'Female' then
			TweakDB:SetFlat(gamePlayerGendersDefaults.female.recordPathStr, TweakDBID.new(gamePlayerGendersDefaults.male.valueStr))
		elseif playerGenderSettings.playerSessionGenderName == 'Male' then
			-- placeholder
		else
			return false
		end
	else
		return false
	end

	return true
end

function selectPlayerTargetGenderForPlayback(scenePerformerGender)
	restorePlayerGenderRecords()
	playerGenderSettings.playerGenderOnPlaybackName = nil
	if type(playerGenderSettings.playerSessionGenderName) ~= 'string' then return false end

	if playerGenderSettings.playerSessionGenderName ~= 'Female' and playerGenderSettings.playerSessionGenderName ~= 'Male' then return false end
	local targetGenderSelected = playerGenderSettings.playerSessionGenderName
	playerGenderSettings.playerGenderOnPlaybackName = targetGenderSelected

	if userSettings.playerGenderOnPlayback == 1 then
		-- placeholder
	elseif userSettings.playerGenderOnPlayback == 2 then
		targetGenderSelected = 'Female'
	elseif userSettings.playerGenderOnPlayback == 3 then
		targetGenderSelected = 'Male'
	elseif userSettings.playerGenderOnPlayback == 4 then
		if playerGenderSettings.playerSessionGenderName == 'Female' then targetGenderSelected = 'Male'
		elseif playerGenderSettings.playerSessionGenderName == 'Male' then targetGenderSelected = 'Female'
		end
	elseif userSettings.playerGenderOnPlayback == 5 then
		if type(scenePerformerGender) ~= 'string' then return end
		if scenePerformerGender == 'Female' then targetGenderSelected = 'Female'
		elseif scenePerformerGender == 'Male' then targetGenderSelected = 'Male'
		end
	elseif userSettings.playerGenderOnPlayback == 6 then
		if type(scenePerformerGender) ~= 'string' then return end
		if scenePerformerGender == 'Female' then targetGenderSelected = 'Male'
		elseif scenePerformerGender == 'Male' then targetGenderSelected = 'Female'
		end
	elseif userSettings.playerGenderOnPlayback == 7 then
		math.randomseed(mathFloor(os.clock() * 10))
		local r = mathFloor(math.random() * 2)
		if r == 0 then targetGenderSelected = 'Female' else targetGenderSelected = 'Male' end
	else
		userSettings.playerGenderOnPlayback = 1
	end

	playerGenderSettings.playerGenderOnPlaybackName = targetGenderSelected
	return targetGenderSelected
end

function forceAutosave()
	questsSystem:SetFactStr("mod_hotscenes_last_game_save_attempt", mathFloor(GameGetEngineTime():ToFloat()))
	questsSystem:SetFactStr("mod_hotscenes_last_game_save_type", 2)
	if type(autoSaveSystem.RequestForcedCheckpoint) == 'function' then
		autoSaveSystem:RequestForcedCheckpoint()
	else
		autoSaveSystem:RequestForcedAutoSave()
	end
	return true
end

function gameSave(fileName)
	if not isInGameSession() then return false end
	if type(fileName) ~= 'string' then fileName = 'ManualSave-' end
	questsSystem:SetFactStr("mod_hotscenes_last_game_save_attempt", mathFloor(GameGetEngineTime():ToFloat()))
	questsSystem:SetFactStr("mod_hotscenes_last_game_save_type", 3)
	GameGetSystemRequestsHandler():ManualSave(fileName)
	return true
end

function gameReload()
	print(modName, "Requesting a game reload.", os.clock())
	GameGetSystemRequestsHandler():LoadLastCheckpoint(true)
	return true
end

function getLastSavesInfo()
	GameGetSystemRequestsHandler():RequestSavesForLoad()
	GameGetSystemRequestsHandler():RequestSavesForSave()
	return GameGetSystemRequestsHandler():RequestSavesCountSync(), GameGetSystemRequestsHandler():GetLatestSaveMetadata()
end

function isSameSaveMetadata(old, new)
	if not old then return false end
	if not new then return false end
	local oldType = type(old)
	local newType = type(new)
	if oldType ~= 'table' and not (oldType == 'userdata' and IsDefinedNS(old)) then return false end
	if newType ~= 'table' and not (newType == 'userdata' and IsDefinedNS(new)) then return false end
	if (
			tostring(old.playTime)			== tostring(new.playTime) and
			tostring(old.playthroughTime)	== tostring(new.playthroughTime) and
			tostring(old.locationName)		== tostring(new.locationName) and
			tostring(old.lifePath)			== tostring(new.lifePath) and
			tostring(old.gameVersion)		== tostring(new.gameVersion)
		)
	then return true end
	return false
end

function saveLastKnownSaveMetadata(lastKnownSaveMetadata)
	if not IsDefinedNS(lastKnownSaveMetadata) then return end
	if type(userSettings.lastKnownSaveMetadata) ~= 'table' then userSettings.lastKnownSaveMetadata = {} end
	userSettings.lastKnownSaveMetadata.playTime			= tostring(lastKnownSaveMetadata.playTime)
	userSettings.lastKnownSaveMetadata.playthroughTime	= tostring(lastKnownSaveMetadata.playthroughTime)
	userSettings.lastKnownSaveMetadata.locationName		= tostring(lastKnownSaveMetadata.locationName)
	userSettings.lastKnownSaveMetadata.trackedQuest		= tostring(lastKnownSaveMetadata.trackedQuest)
	userSettings.lastKnownSaveMetadata.lifePath			= tostring(lastKnownSaveMetadata.lifePath)
	userSettings.lastKnownSaveMetadata.gameVersion		= tostring(lastKnownSaveMetadata.gameVersion)

	saveUserSettings()
end

function fetchLastModSaveFilename(timeout)
	isLookingForLastModSave = true
	lastModSaveIndex = 0
	lookForLastModFileName(isLookingForLastModSave, timeout, true)
end

function lookForLastModFileName(isLookingForLastModSave, timeout, newRun)
	if not IsDefinedNS(idleMenuHandle) then
		isLookingForLastModSaveTimeout = 0
		isSilentPauseMenuRequested = false
		shouldCleanupFromFileLookup = false
		if type(lastModSaveFileName) ~= 'string' then lastModSaveFileName = 'unknown' end
		return false
	end

	local isPaused = isGamePaused()

	if newRun then
		isLookingForLastModSave = true
		if type(timeout) ~= number then timeout = 10 elseif timeout < 5 then timeout = 5 end
		isLookingForLastModSaveTimeout = os.clock() + timeout
		lastModSaveIndex = 0
		isSilentPauseMenuRequested = false
		if not isPaused then idleMenuHandle:SwitchToScenario(cNamePauseMenuScenario, nil) isSilentPauseMenuRequested = true end
	end

	if (isLookingForLastModSaveTimeout < 1) or ((not isLookingForLastModSave) and (not shouldCleanupFromFileLookup)) then
		isLookingForLastModSaveTimeout = 0
		isSilentPauseMenuRequested = false
		shouldCleanupFromFileLookup = false
		if type(lastModSaveFileName) ~= 'string' then lastModSaveFileName = 'unknown' end
		return false
	end

	if (not isLookingForLastModSave) or (isLookingForLastModSaveTimeout > 0 and os.clock() >= isLookingForLastModSaveTimeout) then
		isLookingForLastModSaveTimeout = 0
		if shouldCleanupFromFileLookup then
			if isPaused then
				if IsDefinedNS(pauseMenuHandle) then
					if isSilentPauseMenuRequested then
						pauseMenuHandle:GotoIdleState()
						isSilentPauseMenuRequested = false
					else
						if IsDefinedNS(idleMenuHandle) then idleMenuHandle:SwitchToScenario(cNamePauseMenuScenario, nil) else pauseMenuHandle:GotoIdleState() end
					end
				else
					GameGetSystemRequestsHandler():UnpauseGame()
				end
			end
			shouldCleanupFromFileLookup = false
		end

		isLookingForLastModSave = false
		if lastModSaveIndex > 0 then return false end
		lastModSaveIndex = 0
		lastModSaveFileName = 'unknown'
		return false
	end

	if not isPaused then return isLookingForLastModSave end

	if IsDefinedNS(pauseMenuHandle) then
		if not pauseMenuHandle:GetMenusState():IsMenuOpened(n_save_game) then
			shouldCleanupFromFileLookup = true
			pauseMenuHandle:SwitchMenu(n_save_game)
		end
	end

	return isLookingForLastModSave
end

function isWorldStreaming();
	local globalRef = ResolveNodeRef(CreateEntityReference("#q001_mp_vroom_stash", {}).reference, GlobalNodeID.GetRoot());
	local success, transform = GameGetNodeTransform(globalRef);
	return success;
end;

function getNodeTransformByNodeRef(nodeRef, checkOnly);
	if type(nodeRef) ~= 'string' then return end;
	if not stringMatch(nodeRef, "^#") then return end
	local globalRef = ResolveNodeRef(CreateEntityReference(nodeRef, {}).reference, GlobalNodeID.GetRoot()); -- (c) psiberx
	local success, transform = GameGetNodeTransform(globalRef); -- (c) psiberx
	if not success then return end;
	if checkOnly then return success end
	local nodeTransform = WorldTransform.new();
	nodeTransform:SetPosition(transform.position);
	nodeTransform:SetOrientation(transform.orientation);
	return transform:GetPosition(), transform:ToEulerAngles(), nodeTransform;
end;

function getQuestEntryState(hashOrEntry)
	if type(hashOrEntry) == 'number' then
		if hashOrEntry < 0 then hashOrEntry = hashOrEntry + 4294967296 end -- (c)psiberx fix
		local journalEntry = journalManager:GetEntry(hashOrEntry)
		if not journalEntry then return end;
		return journalManager:GetEntryState(journalEntry);
	end
	if type(hashOrEntry) ~= 'userdata' or (not IsDefined(hashOrEntry)) or (not hashOrEntry:IsA('gameJournalEntry')) then return end
	return journalManager:GetEntryState(hashOrEntry);
end

local partnerHangoutObjectives = {3753461090, 1207149997, 106697448, 3806144830, }
function isAnyHangoutQuestActive();
	if not enable_mq055_hangouts_support then return false end;
	local entryState = getQuestEntryState(1364674146);
	if not entryState then return false end;
	if entryState ~= gameJournalEntryState.Active then return false end
	for _, entryHash in ipairs(partnerHangoutObjectives) do
		entryState = getQuestEntryState(entryHash);
		if entryState and entryState == gameJournalEntryState.Active then return entryHash end
	end
	return false;
end;

local mq055_02_factsAndSceneData = {
	mq055_02_megabuilding_active = {name = "megabuilding", factName = "mq055_02_megabuilding_active", mapPin = "#mq055_mp_megabuilding_apartment", districtNames = "LittleChina_Apartment", sceneBreakTeleportTo = function() GameGetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(-1396.3628, 1309.0495, 115.082, 1), EulerAngles.new(0, 0, 173.04)) return true end},
	mq055_02_northside_active = {name = "northside", factName = "mq055_02_northside_active", mapPin = "#mq055_mp_northside_apartment", districtNames = "Northside_Apartment", sceneBreakTeleportTo = function() GameGetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(-1448.9534, 2257.1914, 18.2, 1), EulerAngles.new(0, 0, -168.35)) return true end},
	mq055_02_japantown_active = {name = "downtown", factName = "mq055_02_japantown_active", mapPin = "#mq055_mp_japantown_apartment", districtNames = "JapanTown_Apartment", sceneBreakTeleportTo = function() GameGetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(-808.8606, 977.9882, 12.027, 1), EulerAngles.new(0, 0, -90.39)) return true end},
	mq055_02_heywood_active = {name = "heywood", factName = "mq055_02_heywood_active", mapPin = "#mq055_mp_heywood_apartment", districtNames = "Glen_Apartment", sceneBreakTeleportTo = function() GameGetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(-1578.2911, -993.6033, 70.43163, 1), EulerAngles.new(0, 0, -85.4)) return true end},
	mq055_02_downtown_active = {name = "downtown", factName = "mq055_02_downtown_active", mapPin = "#mq055_mp_downtown_apartment", districtNames = "DowntownCityCenterCorpoPlaza_Apartment", sceneBreakTeleportTo = function() GameGetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(-1598.8113, 317.3217, 8.192, 1), EulerAngles.new(0, 0, 3.16)) return true end},
}

local isRogueHangoutsModDetected
function isRogueHangoutModAround()
	if type(isRogueHangoutsModDetected) == 'boolean' then return isRogueHangoutsModDetected end
	isRogueHangoutsModDetected = isKnownName("{a3_hangout_romances_camera}") or getNodeTransformByNodeRef("#a3_hangout_romances_camera", true) ~= nil
	return isRogueHangoutsModDetected
end
function isRogueHangoutModActive(isDeepCheck)
	if (not isDeepCheck) and questsSystem:GetFactStr("a3_hangout_romances_running") < 1 then return false end
	if isRogueHangoutModAround() then return true end
	return false
end
local isRogueHangoutsHandlerDetected
function isRogueHangoutsHandlerAvailable()
	if type(isRogueHangoutsHandlerDetected) == 'boolean' then return isRogueHangoutsHandlerDetected end
	isRogueHangoutsHandlerDetected = isKnownName("rogue_01_support_available") or isKnownName("rogue_rq_01_mod_hs_is_available")
	return isRogueHangoutsHandlerDetected
end
function isRogueHangoutLoopBreakerActive()
	return questsSystem:GetFactStr("is_rogue_lb_01_ticking_mod_hs") > 0
end
function isRogueHangoutRestartActive()
	return questsSystem:GetFactStr("is_rogue_rq_01_ticking_mod_hs") > 0
end
function resetRogueHangoutsDetection()
	questsSystem:SetFactStr("is_rogue_lb_01_ticking_mod_hs", 0)
	questsSystem:SetFactStr("is_rogue_rq_01_ticking_mod_hs", 0)
end
function resetRogueHangoutsHandler()
	if isPreGameState then return end
	questsSystem:SetFactStr("mod_hotscenes_requesting_default_setup", 0)
	questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0)
	questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_active", 0)
	questsSystem:SetFactStr("should_activate_rogue_lb_01_mod_hs", 0)
	questsSystem:SetFactStr("restart_rogue_rq_01_mod_hs", 0)
	resetRogueHangoutsDetection()
end

function getActiveHangoutSceneData();
	if not enable_mq055_hangouts_support then return end;
	if not isAnyHangoutQuestActive() then return end;
	for	fact, data in pairs(mq055_02_factsAndSceneData) do;
		if questsSystem:GetFactStr(fact) > 0 then return fact, data end;
	end;
end;

local romanceScenesFemale, romanceScenesMale
local isRomanceScenesRecordCreated = false
function createRomanceScenes()
	if isRomanceScenesRecordCreated then return end

	if not TweakDB:GetRecord("Character.Judy_mod_hotscenes") then TweakDB:CloneRecord("Character.Judy_mod_hotscenes", "Character.Judy") end
	romanceScenesFemale = {
		['sq030']	= {
			displayName = "Lake Hut", gender = 'female', priceTag = 0, approachLocation = {pos = Vector4.new(1110.5513, -3462.9148, 180.44951, 1), yaw = 83.92946}, journalPathHash = 3869593594, journalMappins = {},
			tdbidPath = 'Character.Judy_mod_hotscenes.entityTemplatePath', performerFullName = 'Judy Alvarez', onscreenTitle = 'LocKey#34480', performerEntPath = 'base\\quest\\secondary_characters\\judy.ent',
			performers = {
				judy = 'base\\quest\\secondary_characters\\judy.ent',
				judy_v2 = 'base\\hotscenes\\performers\\judy_v2\\judy_v2.ent',
				judy_no_tatts_v2 = 'base\\hotscenes\\performers\\judy_no_tatts_v2\\judy_no_tatts_v2.ent',
			},
			performerPriorityList = {'judy_v2', 'judy_no_tatts_v2', 'judy'},
			performerPriorityList_prefer_vanilla = {'judy', 'judy_no_tatts_v2', 'judy_v2'},
			clipFactStr = '', isAvailable = false,
			isRomanceScene = true, isAddonProvidedScene = true,
			characterTdbidPath = 'Character.Judy_mod_hotscenes', characterTdbidHash = TweakDBID.new('Character.Judy_mod_hotscenes').hash,
			prerequisiteFacts = {'judy_romanceable', 'sq030_11_romance', 'sq030_sex_done'}, alreadyMetFact = 'sq030_sex_done', sceneStartupWsLocation = Vector4.new(1118.7151, -3477.0781, 181.2515, 1)
		},
	}

	if not TweakDB:GetRecord("Character.Sobchak_mod_hotscenes") then TweakDB:CloneRecord("Character.Sobchak_mod_hotscenes", "Character.Sobchak") end
	romanceScenesMale = {
		['sq029']	= {
			displayName = "Trailer Park", gender = 'male', priceTag = 0, approachLocation = {pos = Vector4.new(1220.2324, -488.4995, 35.46, 1), yaw = -107.65}, journalPathHash = 3014665228, journalMappins = {},
			tdbidPath = 'Character.Sobchak_mod_hotscenes.entityTemplatePath', performerFullName = 'River Ward', onscreenTitle = 'LocKey#34419', performerEntPath = 'base\\quest\\primary_characters\\sobchak.ent',
			performers = {
				river = 'base\\quest\\primary_characters\\sobchak.ent',
				river_v2 = 'base\\hotscenes\\performers\\river_v2\\sobchak_v2.ent',
				river_v2_mq055 = 'base\\hotscenes\\performers\\river_v2_mq055\\sobchak_v2.ent',
			},
			performerPriorityList = {'river_v2_mq055', 'river_v2'},
			performerPriorityList_prefer_vanilla = {'river_v2_mq055', 'river_v2'},
			clipFactStr = '', isAvailable = false,
			isRomanceScene = true, isAddonProvidedScene = true,
			characterTdbidPath = 'Character.Sobchak_mod_hotscenes', characterTdbidHash = TweakDBID.new('Character.Sobchak_mod_hotscenes').hash,
			prerequisiteFacts = {'river_romanceable', 'sq029_river_had_sex', 'sq029_river_lover'}, alreadyMetFact = 'sq029_river_had_sex', sceneStartupWsLocation = Vector4.new(1236.1973, -516.7607, 37.3608, 1)
		},
	}
	isRomanceScenesRecordCreated = true
end

local isCustomLocationDataVerified = false
local customSceneLocations = {
	female = {
		['sq030'] = {
			sq030 = {keyName = 'sq030', desc = "Pyrmid Song", isCustom = true, isEnabled = true, isRomanceScene = true, isSceneLocationAlwaysAvailable = true, checkNodeRef = "#sq030_09_sm_pier", checkLocationAvailabilityName = "mod_hotscenes_hangouts_sq030_f__default_available", setCustomLocationFact = "mod_hotscenes_hangouts_sq030_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hangouts_sq030_f__to_default", sceneSupportFacts = {},
						specialSceneConditionsSetup = function()
							if not isCetNpcBodyModActive then return end
							questsSystem:SetFactStr("mod_hotscenes_hangouts_sq030_f__enable_spawn_protection", 1)
							return true
						end,
						isAllowedByQuestConditions = function(partnerName)
							if type(partnerName) ~= 'string' or partnerName ~= 'judy' then return end
							if not GetPlayer then return end
							local player = GetPlayer()
							if not player then return end
							if player:GetResolvedGenderName().value ~= "Female" then return end
							if questsSystem:GetFactStr("judy_romanceable") < 1 then return end
							if questsSystem:GetFactStr("sq030_11_romance") < 1 then return end
							if questsSystem:GetFactStr("sq030_sex_done") < 1 then return end
							return true
						end
					},
			exportOrder = {'sq030'},
		},
		['Glen'] = {
			default = {keyName = 'default', desc = "Dark Matter (default)", isCustom = false, isEnabled = true, isValid = true, isAvailable = true,
				customSceneAlternative = {isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__default_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_default"}
			},
			aph10 = {keyName = 'aph10', desc = "V\'s Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_apH10_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__apH10_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_apH10", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, lockFacts = {"mq055_02_megabuilding_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_cuddle_start") > 0 and questsSystem:GetFactStr("mq055_02_megabuilding_active") > 0 end},
			dollhouse = {keyName = 'dollhouse', desc = "Clouds", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_dollhouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__dollhouse_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_dollhouse", sceneSupportFacts = nil, unlockFacts = {"sq026_04_done", "sq030_done", "sq030_active", "sq030_09_pier_done"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.lightning_a_dollhouse_mod_hotscenes") then TweakDB:CloneRecord("Props.lightning_a_dollhouse_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.lightning_a_dollhouse_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\gameplay\\devices\\lighting\\dollhouse\\lightning_02.ent'); if not TweakDB:GetRecord("Props.poor_mattress_a_duvet_a_mod_hotscenes") then TweakDB:CloneRecord("Props.poor_mattress_a_duvet_a_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.poor_mattress_a_duvet_a_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\poor_mattress\\poor_mattress_a_duvet_a.ent'); end},
			kerry_villa = {keyName = 'kerry_villa', desc = "Kerry\'s Mansion", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_kerry_villa_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__kerry_villa_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_kerry_villa", sceneSupportFacts = {kerry_default_on = 0, apartment_on = 0}, unlockFacts = {"sq011_totentanz_quest_cleanup", "holo_v_calls_kerry_end_count"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes") then TweakDB:CloneRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.rich_mattress_a_duvet_a_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\rich_mattress\\rich_mattress_a_duvet_a_01.ent') if not TweakDB:GetRecord("Props.accessories_01_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_01_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights.ent') if not TweakDB:GetRecord("Props.accessories_02_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_02_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights_02.ent') end},
			cct_dtn_apt_01 = {keyName = 'cct_dtn_apt_01', desc = "Corpo Plaza Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__cct_dtn_apt_01_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_cct_dtn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_05_downtown_activities_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_cct_dtn_purchased"}, lockFacts = {"mq055_02_downtown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_05_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_downtown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent'); end},
			apart_hey_gle = {keyName = 'apart_hey_gle', desc = "Glen Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_apart_hey_gle_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__apart_hey_gle_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_apart_hey_gle", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_hey_gle_purchased"}, lockFacts = {"mq055_02_heywood_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_04_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_heywood_active") > 0 end},
			wbr_jpn_apt_01 = {keyName = 'wbr_jpn_apt_01', desc = "Japantown Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__wbr_jpn_apt_01_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_wbr_jpn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_wbr_jpn_purchased"}, lockFacts = {"mq055_02_japantown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_03_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_japantown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent'); end},
			cct_dtn_05 = {keyName = 'cct_dtn_05', desc = "Gold Beach Marina", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_05_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__cct_dtn_05_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_cct_dtn_05", 
				sceneSupportFacts = nil, unlockFacts = {"dtn_05_cleanup"}, specialSceneConditionsSetup = function() 
							if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
							if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
							if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
				end},
			arasaka_hotel = {keyName = 'arasaka_hotel', desc = "Konpeki Plaza", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_arasaka_hotel_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__arasaka_hotel_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_arasaka_hotel", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}},
			q203_penthouse = {keyName = 'q203_penthouse', desc = "Path of Glory", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_q203_penthouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_f__q203_penthouse_available", setCustomLocationFact = "mod_hotscenes_hey_gle_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_f__to_q203_penthouse", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}, specialSceneConditionsSetup = function() if not isMansionDLCModActive then return end isMansionDLCModActive.runtimeData.inGame = false end},
			exportOrder = {'default', 'aph10', 'kerry_villa', 'cct_dtn_apt_01', 'apart_hey_gle', 'wbr_jpn_apt_01', 'cct_dtn_05', 'dollhouse', 'arasaka_hotel', 'q203_penthouse'},
		},
		['Japantown'] = {
			default = {keyName = 'default', desc = "Jig-Jig St (default)", isCustom = false, isEnabled = true, isValid = true, isAvailable = true,
				customSceneAlternative = {isCustom = true, isEnabled = true, checkNodeRef = "#wbr_sm_jpn_prostitute_sex", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__default_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_default"}
			},
			aph10 = {keyName = 'aph10', desc = "V\'s Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_apH10_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__apH10_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_apH10", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, lockFacts = {"mq055_02_megabuilding_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_cuddle_start") > 0 and questsSystem:GetFactStr("mq055_02_megabuilding_active") > 0 end},
			dollhouse = {keyName = 'dollhouse', desc = "Clouds", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_dollhouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__dollhouse_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_dollhouse", sceneSupportFacts = nil, unlockFacts = {"sq026_04_done", "sq030_done", "sq030_active", "sq030_09_pier_done"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.lightning_a_dollhouse_mod_hotscenes") then TweakDB:CloneRecord("Props.lightning_a_dollhouse_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.lightning_a_dollhouse_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\gameplay\\devices\\lighting\\dollhouse\\lightning_02.ent'); if not TweakDB:GetRecord("Props.dollhouse_bar_longue_section_mod_hotscenes") then TweakDB:CloneRecord("Props.dollhouse_bar_longue_section_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.dollhouse_bar_longue_section_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\furniture\\restaurant\\bar_longue_section.ent'); if not TweakDB:GetRecord("Props.poor_mattress_a_duvet_a_mod_hotscenes") then TweakDB:CloneRecord("Props.poor_mattress_a_duvet_a_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.poor_mattress_a_duvet_a_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\poor_mattress\\poor_mattress_a_duvet_a.ent'); end},
			kerry_villa = {keyName = 'kerry_villa', desc = "Kerry\'s Mansion", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_kerry_villa_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__kerry_villa_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_kerry_villa", sceneSupportFacts = {kerry_default_on = 0, apartment_on = 0}, unlockFacts = {"sq011_totentanz_quest_cleanup", "holo_v_calls_kerry_end_count"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes") then TweakDB:CloneRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.rich_mattress_a_duvet_a_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\rich_mattress\\rich_mattress_a_duvet_a_01.ent') if not TweakDB:GetRecord("Props.accessories_01_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_01_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights.ent') if not TweakDB:GetRecord("Props.accessories_02_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_02_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights_02.ent') end},
			cct_dtn_apt_01 = {keyName = 'cct_dtn_apt_01', desc = "Corpo Plaza Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__cct_dtn_apt_01_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_cct_dtn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_05_downtown_activities_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_cct_dtn_purchased"}, lockFacts = {"mq055_02_downtown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_05_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_downtown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent'); end},
			apart_hey_gle = {keyName = 'apart_hey_gle', desc = "Glen Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_apart_hey_gle_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__apart_hey_gle_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_apart_hey_gle", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_hey_gle_purchased"}, lockFacts = {"mq055_02_heywood_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_04_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_heywood_active") > 0 end},
			wbr_jpn_apt_01 = {keyName = 'wbr_jpn_apt_01', desc = "Japantown Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__wbr_jpn_apt_01_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_wbr_jpn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_wbr_jpn_purchased"}, lockFacts = {"mq055_02_japantown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_03_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_japantown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\mq005_table_01.ent'); if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent'); end},
			cct_dtn_05 = {keyName = 'cct_dtn_05', desc = "Gold Beach Marina", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_05_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__cct_dtn_05_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_cct_dtn_05", 
				sceneSupportFacts = nil, unlockFacts = {"dtn_05_cleanup"}, specialSceneConditionsSetup = function() 
							if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
							if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
							if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
				end},
			arasaka_hotel = {keyName = 'arasaka_hotel', desc = "Konpeki Plaza", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_arasaka_hotel_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__arasaka_hotel_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_arasaka_hotel", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}},
			q203_penthouse = {keyName = 'q203_penthouse', desc = "Path of Glory", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_q203_penthouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_f__q203_penthouse_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_f__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_f__to_q203_penthouse", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}, specialSceneConditionsSetup = function() if not isMansionDLCModActive then return end isMansionDLCModActive.runtimeData.inGame = false end},
			exportOrder = {'default', 'aph10', 'kerry_villa', 'cct_dtn_apt_01', 'apart_hey_gle', 'wbr_jpn_apt_01', 'cct_dtn_05', 'dollhouse', 'arasaka_hotel', 'q203_penthouse'},
		},
	},
	male = {
		['sq029'] = {
			sq029 = {keyName = 'sq029', desc = "Following The River", isCustom = true, isEnabled = true, isRomanceScene = true, isSceneLocationAlwaysAvailable = true, checkNodeRef = "#sq029_04a_sm_river_trailer_park", checkLocationAvailabilityName = "mod_hotscenes_hangouts_sq029_m__default_available", setCustomLocationFact = "mod_hotscenes_hangouts_sq029_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hangouts_sq029_m__to_default", sceneSupportFacts = {sobchak_default_on = 0, apartment_on = 0},
						isAllowedByQuestConditions = function(partnerName)
							if type(partnerName) ~= 'string' or partnerName ~= 'river' then return end
							if not GetPlayer then return end
							local player = GetPlayer()
							if not player then return end
							if player:GetResolvedGenderName().value ~= "Female" then return end
							if questsSystem:GetFactStr("river_romanceable") < 1 then return end
							if questsSystem:GetFactStr("sq029_river_had_sex") < 1 then return end
							if questsSystem:GetFactStr("sq029_river_lover") < 1 then return end
							return true
						end
					},
			exportOrder = {'sq029'},
		},
		['Glen'] = {
			default = {keyName = 'default', desc = "Dark Matter (default)", isCustom = false, isEnabled = true, isValid = true, isAvailable = true,
				customSceneAlternative = {isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__default_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_default"}
			},
			aph10 = {keyName = 'aph10', desc = "V\'s Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_apH10_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__apH10_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_apH10", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, lockFacts = {"mq055_02_megabuilding_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_cuddle_start") > 0 and questsSystem:GetFactStr("mq055_02_megabuilding_active") > 0 end},
			dollhouse = {keyName = 'dollhouse', desc = "Clouds", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_dollhouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__dollhouse_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_dollhouse", sceneSupportFacts = nil, unlockFacts = {"sq026_04_done", "sq030_done", "sq030_active", "sq030_09_pier_done"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.lightning_a_dollhouse_mod_hotscenes") then TweakDB:CloneRecord("Props.lightning_a_dollhouse_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.lightning_a_dollhouse_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\gameplay\\devices\\lighting\\dollhouse\\lightning_02.ent'); end},
			kerry_villa = {keyName = 'kerry_villa', desc = "Kerry\'s Mansion", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_kerry_villa_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__kerry_villa_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_kerry_villa", sceneSupportFacts = {kerry_default_on = 0, apartment_on = 0}, unlockFacts = {"sq011_totentanz_quest_cleanup", "holo_v_calls_kerry_end_count"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes") then TweakDB:CloneRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.rich_mattress_a_duvet_a_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\rich_mattress\\rich_mattress_a_duvet_a_01.ent') if not TweakDB:GetRecord("Props.accessories_01_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_01_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights.ent') if not TweakDB:GetRecord("Props.accessories_02_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_02_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights_02.ent') end},
			cct_dtn_apt_01 = {keyName = 'cct_dtn_apt_01', desc = "Corpo Plaza Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__cct_dtn_apt_01_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_cct_dtn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_05_downtown_activities_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_cct_dtn_purchased"}, lockFacts = {"mq055_02_downtown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_05_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_downtown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent'); end},
			apart_hey_gle = {keyName = 'apart_hey_gle', desc = "Glen Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_apart_hey_gle_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__apart_hey_gle_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_apart_hey_gle", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_hey_gle_purchased"}, lockFacts = {"mq055_02_heywood_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_04_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_heywood_active") > 0 end},
			wbr_jpn_apt_01 = {keyName = 'wbr_jpn_apt_01', desc = "Japantown Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__wbr_jpn_apt_01_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_wbr_jpn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_wbr_jpn_purchased"}, lockFacts = {"mq055_02_japantown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_03_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_japantown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent'); end},
			cct_dtn_05 = {keyName = 'cct_dtn_05', desc = "Gold Beach Marina", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_05_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__cct_dtn_05_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_cct_dtn_05", 
				sceneSupportFacts = nil, unlockFacts = {"dtn_05_cleanup"}, specialSceneConditionsSetup = function() 
							if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
							if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
							if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
				end},
			arasaka_hotel = {keyName = 'arasaka_hotel', desc = "Konpeki Plaza", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_arasaka_hotel_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__arasaka_hotel_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_arasaka_hotel", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}},
			q203_penthouse = {keyName = 'q203_penthouse', desc = "Path of Glory", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_q203_penthouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_hey_gle_m__q203_penthouse_available", setCustomLocationFact = "mod_hotscenes_hey_gle_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_hey_gle_m__to_q203_penthouse", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}, specialSceneConditionsSetup = function() if not isMansionDLCModActive then return end isMansionDLCModActive.runtimeData.inGame = false end},
			exportOrder = {'default', 'aph10', 'kerry_villa', 'cct_dtn_apt_01', 'apart_hey_gle', 'wbr_jpn_apt_01', 'cct_dtn_05', 'dollhouse', 'arasaka_hotel', 'q203_penthouse'},
		},
		['Japantown'] = {
			default = {keyName = 'default', desc = "Jig-Jig St (default)", isCustom = false, isEnabled = true, isValid = true, isAvailable = true,
				customSceneAlternative = {isCustom = true, isEnabled = true, checkNodeRef = "#wbr_sm_jpn_prostitute_sex", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__default_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_default"}
			},
			aph10 = {keyName = 'aph10', desc = "V\'s Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_apH10_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__apH10_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_apH10", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, lockFacts = {"mq055_02_megabuilding_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_cuddle_start") > 0 and questsSystem:GetFactStr("mq055_02_megabuilding_active") > 0 end},
			dollhouse = {keyName = 'dollhouse', desc = "Clouds", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_male_intro_dollhouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__dollhouse_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_dollhouse", sceneSupportFacts = nil, unlockFacts = {"sq026_04_done", "sq030_done", "sq030_active", "sq030_09_pier_done"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.lightning_a_dollhouse_mod_hotscenes") then TweakDB:CloneRecord("Props.lightning_a_dollhouse_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.lightning_a_dollhouse_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\gameplay\\devices\\lighting\\dollhouse\\lightning_02.ent'); end},
			kerry_villa = {keyName = 'kerry_villa', desc = "Kerry\'s Mansion", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_male_intro_kerry_villa_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__kerry_villa_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_kerry_villa", sceneSupportFacts = {kerry_default_on = 0, apartment_on = 0}, unlockFacts = {"sq011_totentanz_quest_cleanup", "holo_v_calls_kerry_end_count"}, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes") then TweakDB:CloneRecord("Props.rich_mattress_a_duvet_a_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.rich_mattress_a_duvet_a_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\environment\\decoration\\textiles\\bedding\\rich_mattress\\rich_mattress_a_duvet_a_01.ent') if not TweakDB:GetRecord("Props.accessories_01_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_01_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights.ent') if not TweakDB:GetRecord("Props.accessories_02_kerry_villa_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_kerry_villa_mod_hotscenes", "Props.mq019_champagne_glass_prop") end TweakDB:SetFlat("Props.accessories_02_kerry_villa_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\archive_xl\\scenes\\joytoys\\hey_gle\\scene_support\\kerry_villa_character_lights_02.ent') end},
			cct_dtn_apt_01 = {keyName = 'cct_dtn_apt_01', desc = "Corpo Plaza Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__cct_dtn_apt_01_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_cct_dtn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_05_downtown_activities_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_cct_dtn_purchased"}, lockFacts = {"mq055_02_downtown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_05_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_downtown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent'); end},
			apart_hey_gle = {keyName = 'apart_hey_gle', desc = "Glen Apartment", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_override_landing_apart_hey_gle_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__apart_hey_gle_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_apart_hey_gle", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_hey_gle_purchased"}, lockFacts = {"mq055_02_heywood_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_04_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_heywood_active") > 0 end},
			wbr_jpn_apt_01 = {keyName = 'wbr_jpn_apt_01', desc = "Japantown Apartment", isCustom = true, isEnabled = true, minCetVerRequired = 1.29, checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_apt_01_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__wbr_jpn_apt_01_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_wbr_jpn_apt_01", sceneSupportFacts = {q001_apartment_bed_disabled = 1, mq055_apt_interactions_off = 1, apartment_on = 0}, unlockFacts = {"dlc6_apart_wbr_jpn_purchased"}, lockFacts = {"mq055_02_japantown_active"}, shouldOverrideSceneLock = function() return is_mq055_hangouts_interaction_activated() and questsSystem:GetFactStr("mq055_03_intimate_action_on") > 0 and questsSystem:GetFactStr("mq055_02_japantown_active") > 0 end, specialSceneConditionsSetup = function() if not TweakDB:GetRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\mq005_table_01.ent'); if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end; TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent'); end},
			cct_dtn_05 = {keyName = 'cct_dtn_05', desc = "Gold Beach Marina", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_05_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__cct_dtn_05_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_cct_dtn_05", 
				sceneSupportFacts = nil, unlockFacts = {"dtn_05_cleanup"}, specialSceneConditionsSetup = function() 
							if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
							if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
							if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
							TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
				end},
			arasaka_hotel = {keyName = 'arasaka_hotel', desc = "Konpeki Plaza", isCustom = true, isEnabled = true, checkNodeRef = "#wbr_jpn_prostitute_male_intro_arasaka_hotel_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__arasaka_hotel_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_arasaka_hotel", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}},
			q203_penthouse = {keyName = 'q203_penthouse', desc = "Path of Glory", isCustom = true, isEnabled = true, checkNodeRef = "#hey_gle_prostitute_override_landing_q203_penthouse_mod_hotscenes", checkLocationAvailabilityName = "mod_hotscenes_wbr_jpn_m__q203_penthouse_available", setCustomLocationFact = "mod_hotscenes_wbr_jpn_m__requesting_custom_locations", setDestinationFact = "mod_hotscenes_wbr_jpn_m__to_q203_penthouse", sceneSupportFacts = nil, unlockFacts = {"q101_enable_side_content"}, specialSceneConditionsSetup = function() if not isMansionDLCModActive then return end isMansionDLCModActive.runtimeData.inGame = false end},
			exportOrder = {'default', 'aph10', 'kerry_villa', 'cct_dtn_apt_01', 'apart_hey_gle', 'wbr_jpn_apt_01', 'cct_dtn_05', 'dollhouse', 'arasaka_hotel', 'q203_penthouse'},
		},
	}
}

uiDefaultStrings.destinationNames = {}
for sceneName, sceneData in pairs(customSceneLocations.female) do
	local isAnythingAdded = false
	if sceneName == "Glen" or sceneName == "Japantown" then
		for i = 1, #sceneData.exportOrder do
			local destination = sceneData.exportOrder[i]
			if sceneData[destination] then
				local destinationName = sceneData[destination].desc
				if destination == 'default' then destination = destination..sceneName end
				if destinationName then uiDefaultStrings.destinationNames[destination] = {cetUi = destinationName, nativeUi = destinationName} isAnythingAdded = true end
			end
		end
	end
end
for sceneName, sceneData in pairs(customSceneLocations.male) do
	local isAnythingAdded = false
	if sceneName == "Glen" or sceneName == "Japantown" then
		for i = 1, #sceneData.exportOrder do
			local destination = sceneData.exportOrder[i]
			if sceneData[destination] then
				local destinationName = sceneData[destination].desc
				if destination == 'default' then destination = destination..sceneName end
				if destinationName then uiDefaultStrings.destinationNames[destination] = {cetUi = destinationName, nativeUi = destinationName} isAnythingAdded = true end
			end
		end
	end
end

function verifyCustomSceneLocationData(force)
	if (not force) and isCustomLocationDataVerified then return true end
	if not GetPlayer() then return end
	if not isArchiveXLActive then return end
	if not isWorldStreaming() then return end

	createRomanceScenes()
	for gender, genderScenes in pairs(customSceneLocations) do
		for sceneName, sceneData in pairs(genderScenes) do
			for customLocation, customLocationData in pairs(sceneData) do
				if customLocation == 'exportOrder' then
					for i = #customLocationData, 1, -1 do
						if type(customLocationData[i]) ~= 'string' or type(sceneData[customLocationData[i]]) ~= 'table' then tableRemove(customLocationData, i) end
					end
					if #customLocationData < 1 then customLocationData = nil end
				else
					if customLocationData.isCustom then
						customLocationData.isValid = false
						customLocationData.isAvailable = false
						if customLocationData.isSceneLocationAlwaysAvailable or getNodeTransformByNodeRef(customLocationData.checkNodeRef, true) then
							customLocationData.isValid = true
							customLocationData.isAvailable = isStringValid(NameToString(customLocationData.checkLocationAvailabilityName))
							if customLocationData.isAvailable and type(customLocationData.minCetVerRequired) == 'number' then customLocationData.isAvailable = cetVer >= customLocationData.minCetVerRequired end
						end
					elseif type(customLocationData.customSceneAlternative) == 'table' and customLocationData.customSceneAlternative.isCustom then
						if getNodeTransformByNodeRef(customLocationData.customSceneAlternative.checkNodeRef, true) then
							customLocationData.customSceneAlternative.isValid = true
							customLocationData.customSceneAlternative.isAvailable = isStringValid(NameToString(customLocationData.customSceneAlternative.checkLocationAvailabilityName))
							customLocationData.isCustomSceneAlternative = true
							if customLocationData.customSceneAlternative.isEnabled and customLocationData.customSceneAlternative.isAvailable then
								customLocationData.isCustom = true
								customLocationData.isValid = customLocationData.customSceneAlternative.isValid
								customLocationData.isAvailable = customLocationData.customSceneAlternative.isAvailable
								customLocationData.isSceneLocationAlwaysAvailable = customLocationData.customSceneAlternative.isSceneLocationAlwaysAvailable
								customLocationData.checkNodeRef = customLocationData.customSceneAlternative.checkNodeRef
								customLocationData.checkLocationAvailabilityName = customLocationData.customSceneAlternative.checkLocationAvailabilityName
								customLocationData.setCustomLocationFact = customLocationData.customSceneAlternative.setCustomLocationFact
								customLocationData.setDestinationFact = customLocationData.customSceneAlternative.setDestinationFact
								customLocationData.sceneSupportFacts = customLocationData.customSceneAlternative.sceneSupportFacts
								customLocationData.unlockFacts = customLocationData.customSceneAlternative.unlockFacts
								customLocationData.lockFacts = customLocationData.customSceneAlternative.lockFacts
								customLocationData.specialSceneConditionsSetup = customLocationData.customSceneAlternative.specialSceneConditionsSetup
							end
						end
					end
				end
			end
		end
	end
	isCustomLocationDataVerified = true
	return true
end

function getCustomLocationsListsForScene(gender, sceneName, includeRomanceScenes)
	if not verifyCustomSceneLocationData() then return end
	if not customSceneLocations[gender] then return end
	local customLocations = customSceneLocations[gender][sceneName]
	if not customLocations then return end
	local validLocations = {}
	local validLocationsIndex = {}
	local validLocationsDescriptions = {}
	local isAnyCustomLocationIncluded = false
	if customLocations.exportOrder then
		for i = 1, #customLocations.exportOrder do
			local customLocation = customLocations.exportOrder[i]
			local customLocationData = customLocations[customLocation]
			if customLocationData.isAvailable and customLocationData.isEnabled and (not customLocationData.isRomanceScene or (customLocationData.isRomanceScene and includeRomanceScenes)) then
				local isLocked = false
				if type(customLocationData.lockFacts) == 'table' and #customLocationData.lockFacts > 0 then
					local shouldOverrideSceneLock = type(customLocationData.shouldOverrideSceneLock) == 'function' and customLocationData.shouldOverrideSceneLock()
					if not shouldOverrideSceneLock then
						for _, fact in ipairs(customLocationData.lockFacts) do
							if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
								isLocked = true
								break
							end
						end
					end
				end
				local isUnlocked = false
				if not isLocked then
					if type(customLocationData.unlockFacts) == 'table' and #customLocationData.unlockFacts > 0 then
						for _, fact in ipairs(customLocationData.unlockFacts) do
							if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
								isUnlocked = true
								break
							end
						end
					else
						isUnlocked = true
					end
				end
				if isUnlocked then
					if customLocationData.isCustom then isAnyCustomLocationIncluded = true end
					tableInsert(validLocations, customLocationData)
					tableInsert(validLocationsIndex, customLocation)
				end
			end
		end

		local destinationNamesDefault, destinationNamesCetUi, destinationNamesNativeUi = {}, {}, {}
		for i = 1, #validLocations do
			local validLocation = validLocations[i]
			local translationRec = {default = validLocation.desc, cetUi = validLocation.desc, nativeUi = validLocation.desc}
			if type(uiStrings.destinationNames) == 'table' then
				local keyName = validLocation.keyName
				if keyName == 'default' then keyName = keyName..sceneName end
				if uiStrings.destinationNames[keyName] then
					if uiStrings.destinationNames[keyName].cetUi then translationRec.cetUi = uiStrings.destinationNames[keyName].cetUi end
					if uiStrings.destinationNames[keyName].nativeUi then translationRec.nativeUi = GetLocalizedText(uiStrings.destinationNames[keyName].nativeUi) end
				end
			end
			tableInsert(destinationNamesDefault, translationRec.default)
			tableInsert(destinationNamesCetUi, translationRec.cetUi)
			tableInsert(destinationNamesNativeUi, translationRec.nativeUi)
		end
		validLocationsDescriptions = {default = destinationNamesDefault, cetUi = destinationNamesCetUi, nativeUi = destinationNamesNativeUi}
		return validLocations, validLocationsIndex, validLocationsDescriptions, isAnyCustomLocationIncluded
	end

	for customLocation, customLocationData in pairs(customLocations) do
		if customLocation ~= 'exportOrder' then
			if customLocationData.isAvailable and customLocationData.isEnabled then
				local isLocked = false
				if type(customLocationData.lockFacts) == 'table' and #customLocationData.lockFacts > 0 then
					local shouldOverrideSceneLock = type(customLocationData.shouldOverrideSceneLock) == 'function' and customLocationData.shouldOverrideSceneLock()
					if not shouldOverrideSceneLock then
						for _, fact in ipairs(customLocationData.lockFacts) do
							if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
								isLocked = true
								break
							end
						end
					end
				end
				local isUnlocked = false
				if not isLocked then
					if type(customLocationData.unlockFacts) == 'table' and #customLocationData.unlockFacts > 0 then
						for _, fact in ipairs(customLocationData.unlockFacts) do
							if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
								isUnlocked = true
								break
							end
						end
					else
						isUnlocked = true
					end
				end
				if isUnlocked then
					if customLocationData.isCustom then isAnyCustomLocationIncluded = true end
					tableInsert(validLocations, customLocationData)
					tableInsert(validLocationsIndex, customLocation)
				end
			end
		end
	end

	local destinationNamesDefault, destinationNamesCetUi, destinationNamesNativeUi = {}, {}, {}
	for i = 1, #validLocations do
		local validLocation = validLocations[i]
		local translationRec = {default = validLocation.desc, cetUi = validLocation.desc, nativeUi = validLocation.desc}
		if type(uiStrings.destinationNames) == 'table' then
			local keyName = validLocation.keyName
			if keyName == 'default' then keyName = keyName..sceneName end
			if uiStrings.destinationNames[keyName] then
				if uiStrings.destinationNames[keyName].cetUi then translationRec.cetUi = uiStrings.destinationNames[keyName].cetUi end
				if uiStrings.destinationNames[keyName].nativeUi then translationRec.nativeUi = GetLocalizedText(uiStrings.destinationNames[keyName].nativeUi) end
			end
		end
		tableInsert(destinationNamesDefault, translationRec.default)
		tableInsert(destinationNamesCetUi, translationRec.cetUi)
		tableInsert(destinationNamesNativeUi, translationRec.nativeUi)
	end
	validLocationsDescriptions = {default = destinationNamesDefault, cetUi = destinationNamesCetUi, nativeUi = destinationNamesNativeUi}
	return validLocations, validLocationsIndex, validLocationsDescriptions, isAnyCustomLocationIncluded
end

function getCustomLocationData(gender, sceneName, location)
	if not isCustomLocationDataVerified then return end
	if not customSceneLocations[gender] then return end
	if not customSceneLocations[gender][sceneName] then return end
	local customSceneLocation = customSceneLocations[gender][sceneName][location]
	if not customSceneLocation then return end
	if not customSceneLocation.isCustom then return end
	if not customSceneLocation.isValid then return end
	if not customSceneLocation.isEnabled then return end
	if not customSceneLocation.isAvailable then return end
	return customSceneLocation
end

function isCustomLocationAvailableForPlayback(gender, sceneName, location)
	return getCustomLocationData(gender, sceneName, location)
end

function getCustomLocationFacts(gender, sceneName, location)
	local customSceneLocation = getCustomLocationData(gender, sceneName, location)
	if not customSceneLocation then return end
	return customSceneLocation.setCustomLocationFact, customSceneLocation.setDestinationFact, customSceneLocation.sceneSupportFacts
end

function setCustomLocationFacts(gender, sceneName, location)
	local setCustomLocationFact, setDestinationFact, sceneSupportFacts = getCustomLocationFacts(gender, sceneName, location)
	if type(setCustomLocationFact) ~= 'string' then return end
	if type(setDestinationFact) ~= 'string' then return end

	local undoFacts = {setCustomLocationFact, setDestinationFact}
	questsSystem:SetFactStr(setCustomLocationFact, 1)
	questsSystem:SetFactStr(setDestinationFact, 1)

	if type(sceneSupportFacts) == 'table' then
		for fact, value in pairs(sceneSupportFacts) do
			if type(fact) == 'string' and type(value) == 'number' then
				local currentFactValue = questsSystem:GetFactStr(fact)
				if currentFactValue ~= value then
					if not undoFacts then undoFacts = {} end
					undoFacts[fact] = currentFactValue
					questsSystem:SetFactStr(fact, value)
				end
			end
		end
	end
	return undoFacts, sceneSupportFacts
end

function performCustomLocationSceneConditionsSetup(gender, sceneName, location)
	local customSceneLocation = getCustomLocationData(gender, sceneName, location)
	if not customSceneLocation then return end
	if type(customSceneLocation.specialSceneConditionsSetup) ~= 'function' then return end
	local result, data = pcall(function() return customSceneLocation.specialSceneConditionsSetup() end)
	if not result then printError(data) return end
	return data
end

function cleanupCustomLocationFacts()
	for gender, genderScenes in pairs(customSceneLocations) do
		for sceneName, sceneData in pairs(genderScenes) do
			for customLocation, customLocationData in pairs(sceneData) do
				if type(customLocationData.setCustomLocationFact) == 'string' then questsSystem:SetFactStr(customLocationData.setCustomLocationFact, 0) end
				if type(customLocationData.setDestinationFact) == 'string' then questsSystem:SetFactStr(customLocationData.setDestinationFact, 0) end
			end
		end
	end
end

function resetCustomLocationFacts(force)
	if type(sceneState.undoCustomLocationFacts) ~= 'table' then return end
	for fact, value in pairs(sceneState.undoCustomLocationFacts) do
		if type(fact) == 'string' and type(value) == 'number' then
			local currentFactValue = questsSystem:GetFactStr(fact)
			if currentFactValue ~= value then
				questsSystem:SetFactStr(fact, value)
			end
		end
	end
	sceneState.undoCustomLocationFacts = nil
end

function isCustomTriggerQuestActive()
	if not GetPlayer then return end
	if not isKnownName("mod_hotscenes_custom_trigger_quest_available") then return end
	return questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") > 0
end

local fastTrackPlaybackFactSets = {
	factsUpdatedFactName = 'mod_hotscenes_scene_playback_facts_updated',
	femaleScenes = {
		['Glen']		= {startFactName = 'mod_hotscenes_hey_gle_f__ftplay_start', playingFactName = 'mod_hotscenes_hey_gle_f__ftplay_playing', stopFactName = 'mod_hotscenes_hey_gle_f__ftplay_stop', cutThroughFactName = 'mod_hotscenes_hey_gle_f__ftplay_cut_through', overrideFactName = 'mod_hotscenes_hey_gle_f__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_hey_gle_f_scene_playback_facts_updated'},
		['Japantown']	= {startFactName = 'mod_hotscenes_wbr_jpn_f__ftplay_start', playingFactName = 'mod_hotscenes_wbr_jpn_f__ftplay_playing', stopFactName = 'mod_hotscenes_wbr_jpn_f__ftplay_stop', cutThroughFactName = 'mod_hotscenes_wbr_jpn_f__ftplay_cut_through', overrideFactName = 'mod_hotscenes_wbr_jpn_f__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_wbr_jpn_f_scene_playback_facts_updated'},
		['sq030']		= {startFactName = 'mod_hotscenes_hangouts_sq030_f__ftplay_start', playingFactName = 'mod_hotscenes_hangouts_sq030_f__ftplay_playing', stopFactName = 'mod_hotscenes_hangouts_sq030_f__ftplay_stop', cutThroughFactName = 'mod_hotscenes_hangouts_sq030_f__ftplay_cut_through', overrideFactName = 'mod_hotscenes_hangouts_sq030_f__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_hangouts_sq030_f_scene_playback_facts_updated', isRomanceScene = true},
	},
	maleScenes = {
		['Glen']		= {startFactName = 'mod_hotscenes_hey_gle_m__ftplay_start', playingFactName = 'mod_hotscenes_hey_gle_m__ftplay_playing', stopFactName = 'mod_hotscenes_hey_gle_m__ftplay_stop', cutThroughFactName = 'mod_hotscenes_hey_gle_m__ftplay_cut_through', overrideFactName = 'mod_hotscenes_hey_gle_m__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_hey_gle_m_scene_playback_facts_updated'},
		['Japantown']	= {startFactName = 'mod_hotscenes_wbr_jpn_m__ftplay_start', playingFactName = 'mod_hotscenes_wbr_jpn_m__ftplay_playing', stopFactName = 'mod_hotscenes_wbr_jpn_m__ftplay_stop', cutThroughFactName = 'mod_hotscenes_wbr_jpn_m__ftplay_cut_through', overrideFactName = 'mod_hotscenes_wbr_jpn_m__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_wbr_jpn_m_scene_playback_facts_updated'},
		['sq029']		= {startFactName = 'mod_hotscenes_hangouts_sq029_m__ftplay_start', playingFactName = 'mod_hotscenes_hangouts_sq029_m__ftplay_playing', stopFactName = 'mod_hotscenes_hangouts_sq029_m__ftplay_stop', cutThroughFactName = 'mod_hotscenes_hangouts_sq029_m__ftplay_cut_through', overrideFactName = 'mod_hotscenes_hangouts_sq029_m__ftplay_override', factsUpdatedFactName = 'mod_hotscenes_hangouts_sq029_m_scene_playback_facts_updated', isRomanceScene = true},
	}
}

function resetFastTrackStates(preserveNoReloadFlag)
	questsSystem:SetFactStr(fastTrackPlaybackFactSets.factsUpdatedFactName, 0)
	questsSystem:SetFactStr("mod_hotscenes_requesting_default_setup", 0)
	questsSystem:SetFactStr("mod_hotscenes_preserve_performer_appearance", 0)
	if not preserveNoReloadFlag then questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0) end

	for _, scene in ipairs({fastTrackPlaybackFactSets.femaleScenes, fastTrackPlaybackFactSets.maleScenes}) do
		for _, sceneLocation in pairs(scene) do
			for _, factName in pairs(sceneLocation) do
				questsSystem:SetFactStr(factName, 0)
			end
		end
	end
end

function isSceneFastTrackPlaybackAvaliable(gender, sceneName);
	if type(gender) ~= 'string' then return end
	if type(sceneName) ~= 'string' then return end
	local scenes
	if gender == 'female' then scenes = fastTrackPlaybackFactSets.femaleScenes elseif gender == 'male' then maleScenes = fastTrackPlaybackFactSets.femaleScenes end
	if not scenes then return end
	local scene = scenes[sceneName]
	if not scene then return end
	if type(scene.factsUpdatedFactName) ~= 'string' then return end
	return isKnownName(scene.factsUpdatedFactName);
end;

local fastTrackPlaybackAvaliabilityName
function isFastTrackPlaybackAvaliable();
	if not fastTrackPlaybackAvaliabilityName then fastTrackPlaybackAvaliabilityName = n"mod_hotscenes_scene_playback_facts_updated" end
	return fastTrackPlaybackAvaliabilityName.value == "mod_hotscenes_scene_playback_facts_updated";
end;

local sceneOverrideModePlaybackRestrictions = {"GameplayRestriction.NoPhone", "GameplayRestriction.PhoneNoCalling", "GameplayRestriction.PhoneNoTexting", "GameplayRestriction.NoWorldInteractions"}

function setSceneOverrideModePlaybackRestrictions(player)
	if not player then player = GetPlayer() end
	if not player then return end
	local appliedRestrictions = nil
	for i = 1, #sceneOverrideModePlaybackRestrictions do
		local restriction = t(sceneOverrideModePlaybackRestrictions[i])
		if not StatusEffectSystem.ObjectHasStatusEffect(player, restriction) then
			StatusEffectHelper.ApplyStatusEffect(player, restriction);
			if not appliedRestrictions then appliedRestrictions = {} end
			tableInsert(appliedRestrictions, restriction)
		end
	end
	return appliedRestrictions
end

function removeAppliedSceneOverrideModePlaybackRestrictions(player)
	if type(sceneState.appliedRestrictions) ~= 'table' then return end
	if not player then player = GetPlayer() end
	if not player then return end
	for i = 1, #sceneState.appliedRestrictions do
		StatusEffectHelper.RemoveStatusEffect(player, sceneState.appliedRestrictions[i]);
	end
	sceneState.appliedRestrictions = nil
end

function setSceneAvaliabilityOverrideFacts(overrideFacts)
	if type(overrideFacts) ~= 'table' then return end
	local undoFacts = nil
	for _, fact in pairs(overrideFacts) do
		if type(fact) == 'string' then
			if questsSystem:GetFactStr(fact) < 1 then
				if not undoFacts then undoFacts = {} end
				tableInsert(undoFacts, fact)
				questsSystem:SetFactStr(fact, 1)
			end
		end
	end
	return undoFacts
end

function resetSceneAvaliabilityOverrideFacts()
	if type(sceneState.undoSceneAvailiabilityOverrideFacts) ~= 'table' then return end
	for _, fact in pairs(sceneState.undoSceneAvailiabilityOverrideFacts) do
		questsSystem:SetFactStr(fact, 0)
	end
	sceneState.undoSceneAvailiabilityOverrideFacts = nil
end

function isQuestAvaliabilityOverrideAvaliable();
	return isKnownName("mod_hotscenes_prostitutes_quest_override_available");
end;

local questAvailabilityOverrideFacts = {
	femaleScenes = {
		['Glen']		= {'mod_hotscenes_wbr_jpn_scene_availability_override', 'mod_hotscenes_hey_gle_scene_availability_override'},
		['Japantown']	= {'mod_hotscenes_wbr_jpn_scene_availability_override'},
	},
	maleScenes = {
		['Glen']		= {'mod_hotscenes_wbr_jpn_scene_availability_override', 'mod_hotscenes_hey_gle_scene_availability_override'},
		['Japantown']	= {'mod_hotscenes_wbr_jpn_scene_availability_override'},
	}
}

function setQuestAvaliabilityOverrideFacts(overrideFacts)
	if type(overrideFacts) ~= 'table' then return end
	if questsSystem:GetFactStr("mod_hotscenes_no_game_reload") > 0 then return end
	local undoFacts = nil
	for _, fact in ipairs(overrideFacts) do
		if type(fact) == 'string' then
			if not undoFacts then undoFacts = {} end
			tableInsert(undoFacts, fact)
			questsSystem:SetFactStr(fact, 1)
		end
	end
	return undoFacts
end

function resetQuestAvaliabilityOverrideFacts()
	if type(sceneState.undoQuestAvailiabilityOverrideFacts) ~= 'table' then return end
	for _, fact in ipairs(sceneState.undoQuestAvailiabilityOverrideFacts) do
		questsSystem:SetFactStr(fact, 0)
	end
	sceneState.undoQuestAvailiabilityOverrideFacts = nil
end

function isInDefaultInteractiveSceneArea(gender, sceneName)
	if type(sceneName) ~= 'string' or type(gender) ~= 'string' then return end
	local player = GetPlayer()
	if not player then return end
	if sceneName == 'Japantown' then
		if gender == 'female' then
			return vectorDistance(player:GetWorldPosition(), ToVector4{ x = -650.5292, y = 841.6667, z = 19.35, w = 1 } ) < 101
		elseif gender == 'male' then
			return vectorDistance(player:GetWorldPosition(), ToVector4{ x = -659.8824, y = 850.0991, z = 19.586, w = 1 } ) < 101
		end
	elseif sceneName == 'Glen' then
		if gender == 'female' then
			return vectorDistance(player:GetWorldPosition(), ToVector4{ x = -331.0360, y = 232.1392, z = 188.9, w = 1 } ) < 151
		elseif gender == 'male' then
			return vectorDistance(player:GetWorldPosition(), ToVector4{ x = -317.9271, y = 237.2739, z = 188.91, w = 1 } ) < 151
		end
	end
end

function getDefaultInteractiveSceneSetup(gender, sceneName)
	if not userSettings.enableHotscenesAddon then return end
	if not isArchiveXLActive then return end
	if not isOverridesArchiveDetected then return end
	if type(sceneName) ~= 'string' or type(gender) ~= 'string' then return end
	if not isCustomTriggerQuestActive() then return end
	if not isKnownName("mod_hotscenes_interactive_default_setups_available") then return end
	local id = 0
	if sceneName == 'Japantown' then
		if gender == 'female' then
			id = 1
		elseif gender == 'male' then
			id = 2
		end
	elseif sceneName == 'Glen' then
		if gender == 'female' then
			id = 3
		elseif gender == 'male' then
			id = 4
		end
	end
	if id < 1 then return end
	return true, function()
		questsSystem:SetFactStr("mod_hotscenes_requesting_default_setup", id)
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1)
	end
end
local setPerformerSceneSupport = function() end
function playScene(sceneName, gender, request_mq055_custom_scene_playback, isRomanceScene)
	sceneState.lastSelectedPerformerData = nil
	if type(request_mq055_custom_scene_playback) ~= 'number' then request_mq055_custom_scene_playback = 0 end
	local currentEngineTime = GameGetEngineTime():ToFloat()
	local isHangoutsScenePlaybackRequest
	if request_mq055_custom_scene_playback > currentEngineTime then
		is_mq055_custom_scene_playback_requested = request_mq055_custom_scene_playback
		isHangoutsScenePlaybackRequest = true
	else
		is_mq055_custom_scene_playback_requested = 0
	end

	if userSettings.reuseSaves and request_mq055_custom_scene_playback < currentEngineTime then
		lastModSaveFileName = nil
	end

	math.randomseed(os.time())
	resetFastTrackStates()
	questsSystem:SetFactStr("prostitutes_play_all_anims", 0)
	local updatePerformerReplacingPlayerSelection
	if isPerformerReplacingPlayerSupported and isPerformerReplicatingPlayer(sceneName, gender) then
		questsSystem:SetFactStr("mod_hotscenes_preserve_performer_appearance", 1)
		userSettings.isPlayerPerformerDiscovered = true
		updatePerformerReplacingPlayerSelection = true
		updateCetUi = os.clock() + 0.1
	end
	lastSceneSetupProgress = {sceneName = sceneName, gender = gender, step = 1, isRomanceScene = isRomanceScene}
	lastSceneSetupProgress = setAndProcessScenes(lastSceneSetupProgress)
	local thisSceneData
	for sceneNameSrc, sceneData in pairs(femaleScenes) do
		if gender == 'male' then sceneData.scenePlaybackProgress = playback.idle
		elseif gender == 'female' then
			if sceneNameSrc ~= sceneName then
				sceneData.scenePlaybackProgress = playback.idle
			else
				thisSceneData = sceneData
			end
		end
		if updatePerformerReplacingPlayerSelection then
			if sceneData.lastSelectedPerformer == "player_incognito" then sceneData.lastSelectedPerformer = "player" end
			if sceneData.lastUnknownSelectedPerformer == "player_incognito" then sceneData.lastUnknownSelectedPerformer = "player" end
		end
	end
	for sceneNameSrc, sceneData in pairs(maleScenes) do
		if gender == 'female' then sceneData.scenePlaybackProgress = playback.idle
		elseif gender == 'male' then
			if sceneNameSrc ~= sceneName then
				sceneData.scenePlaybackProgress = playback.idle
			else
				thisSceneData = sceneData
			end
		end
		if updatePerformerReplacingPlayerSelection then
			if sceneData.lastSelectedPerformer == "player_incognito" then sceneData.lastSelectedPerformer = "player" end
			if sceneData.lastUnknownSelectedPerformer == "player_incognito" then sceneData.lastUnknownSelectedPerformer = "player" end
		end
	end

	if romanceScenesFemale then
		for sceneNameSrc, sceneData in pairs(femaleScenes) do
			if gender == 'male' then sceneData.scenePlaybackProgress = playback.idle
			elseif gender == 'female' then
				if sceneNameSrc ~= sceneName then
					sceneData.scenePlaybackProgress = playback.idle
				else
					thisSceneData = sceneData
				end
			end
		end
	end
	if romanceScenesMale then
		for sceneNameSrc, sceneData in pairs(maleScenes) do
			if gender == 'female' then sceneData.scenePlaybackProgress = playback.idle
			elseif gender == 'male' then
				if sceneNameSrc ~= sceneName then
					sceneData.scenePlaybackProgress = playback.idle
				else
					thisSceneData = sceneData
				end
			end
		end
	end
	if (not isHangoutsScenePlaybackRequest) and (not isRomanceScene) and thisSceneData then setPerformerSceneSupport(thisSceneData.lastSelectedPerformer, sceneName, gender) end
	if type(lastSceneSetupProgress) == 'table' then return true end
end

function reloadGameAndClearPlaybackStates()
	if gameReload() then
		for _, sceneData in pairs(femaleScenes) do sceneData.scenePlaybackProgress = playback.idle end
		for _, sceneData in pairs(maleScenes) do sceneData.scenePlaybackProgress = playback.idle end
		updateSceneState(true)
	end
end
function clearPlaybackStatesNoGameReload()
	for _, sceneData in pairs(femaleScenes) do sceneData.scenePlaybackProgress = playback.idle end
	for _, sceneData in pairs(maleScenes) do sceneData.scenePlaybackProgress = playback.idle end
	updateSceneState(true)
end

function setCinematicMode(enable, highTier, force) -- based on toggleHUD() by (c)keanuWheeze from SitAnywhere mod.
	local player = GetPlayer()
	if not player then return end
	if enable then
		if type(highTier) ~= 'number' then highTier = 3 end
		highTier = mathMax(mathMin(highTier, 5), 3)
		if (not force) and player:GetSceneTier() >= highTier then return true end
		local blackboardPSM = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefs.PlayerStateMachine)
		blackboardPSM:SetInt(allBlackboardDefs.PlayerStateMachine.SceneTier, highTier, true)
		return true
	else
		local blackboardPSM = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefs.PlayerStateMachine);
		blackboardPSM:SetInt(allBlackboardDefs.PlayerStateMachine.SceneTier, 1, true);
		return true
	end
end

function getCinematicMode() -- based on toggleHUD() by (c)keanuWheeze from SitAnywhere mod.
	local player = GetPlayer()
	if not player then return 0 end
	local blackboardPSM = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefs.PlayerStateMachine);
	return blackboardPSM:GetInt(allBlackboardDefs.PlayerStateMachine.SceneTier);
end

local lastHudController = nil
local inkSystem = nil
function toggleHudMainWindow(state)
	if type(state) ~= 'boolean' then return end
	if IsDefinedNS(mainHudWindowWidget) then
		mainHudWindowWidget:SetVisible(state)
		return true
	end

	if isCodewareActive then
		if not inkSystem then inkSystem = RefWeak(Game.GetInkSystem()) end
		if inkSystem then
			local inkHUDLayer = inkSystem:GetLayer("inkHUDLayer")
			if inkHUDLayer then
				local topWidget = inkHUDLayer:GetVirtualWindow() -- provided by psiberx and by djkovrik tip.
				if topWidget and topWidget.name.value == 'Base Window' then
					mainHudWindowWidget = RefWeak(topWidget)
				else
					getHudMainWindowWidgetByController(lastHudController)
				end
			else
				getHudMainWindowWidgetByController(lastHudController)
			end
		else
			getHudMainWindowWidgetByController(lastHudController)
		end
	else
		getHudMainWindowWidgetByController(lastHudController)
	end

	if not IsDefinedNS(mainHudWindowWidget) then return end
	mainHudWindowWidget:SetVisible(state);
	return true
end

function setFreezePlayer(freeze, startFx)
	local player = GetPlayer()
	if freeze then
		if startFx then GameObjectEffectHelper.StartEffectEvent(player, n_eyes_closing_instant_open_slow) end
		timeSystem:SetTimeDilation(n_FreezePlayer, 0.00001) -- (c)keanuWheeze trick
		return
	end
	timeSystem:UnsetTimeDilation(n_FreezePlayer, n_Linear) -- (c)keanuWheeze trick
	GameObjectEffectHelper.StopEffectEvent(player, n_eyes_closing_instant_open_slow)

	if sceneState.isOverrideSceneAvailabilityModePlaybackRequested or sceneState.isFastTrackPlaybackNoInviteMode then
		GameObjectEffectHelper.StartEffectEvent(player, n_eyes_opening_05s)
		return
	end
	GameObjectEffectHelper.StopEffectEvent(player, n_eyes_opening_05s)
end

local timeout, hardTimeout = 0, 0
function setAndProcessScenes(lastSceneSetupProgress, forceFileNameLookup)
	if type(lastSceneSetupProgress) ~= 'table' then return false end
	local sceneName = lastSceneSetupProgress.sceneName
	local gender = lastSceneSetupProgress.gender
	local step = lastSceneSetupProgress.step

	local sceneData
	if lastSceneSetupProgress.isRomanceScene then
		if gender == 'female' and romanceScenesFemale then sceneData = romanceScenesFemale[sceneName] elseif gender == 'male' and romanceScenesMale then sceneData = romanceScenesMale[sceneName] else return false end
	else
		if gender == 'female' then sceneData = femaleScenes[sceneName] elseif gender == 'male' then sceneData = maleScenes[sceneName] else return false end
	end
	if not sceneData then return false end

	if step == 1 then
		unfreezeTimeFlag = false
		local scenePlaybackProgress = playback.idle
		scenePlaybackProgress = sceneData.scenePlaybackProgress
		if scenePlaybackProgress == playback.idle then return false end

		sceneState.sceneName = sceneName
		sceneState.isRomanceScene = lastSceneSetupProgress.isRomanceScene
		sceneState.isSoundMuted = false
		sceneState.isReadyToTeleport = false
		sceneState.undoSceneAvailiabilityOverrideFacts = nil
		sceneState.undoCustomLocationFacts = nil
		sceneState.appliedRestrictions = nil
		sceneState.isCustomLocationPlayback = nil
		sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
		sceneState.shouldUseCustomTriggerQuest = false
		sceneState.shouldReloadGameOnFinished = false
		sceneState.playerReturnToPos = nil
		sceneState.playerReturnToYaw = nil
		sceneState.canSkipGameReload = false

		if not sceneData.scenePlaybackMode then sceneData.scenePlaybackMode = scenePlaybackMode.interactive end
		if not sceneData.sceneTargetLocation then sceneData.sceneTargetLocation = 'default' end

		if is_mq055_hangouts_interaction_activated() and mq055_hangouts_interaction.isCustomChoiceOnScreen() then
			if timeout < 1 then
				local timeoutBase = 10
				timeout = GameGetEngineTime():ToFloat() + timeoutBase
				hardTimeout = os.clock() + timeoutBase + 90
			end
			local isTimeout = timeout > 0 and (GameGetEngineTime():ToFloat() > timeout or os.clock() > hardTimeout)
			if isTimeout then
				sceneData.scenePlaybackProgress = playback.idle
				printError(modName..' '..modVer..': Hotscene playback startup timed out while waiting for Hangouts interaction to close in scene:', hangoutsSceneFact, isAnyHangoutQuestActive())
				sendWarningMessage(uiStrings.nuiUiStrings.onscreenWarnings.playback.timeout or "Hotscene playback could not be started.")
				return false
			end
			nextUpdateTime = os.clock() + 0.001
			return lastSceneSetupProgress
		end

		timeout = 0
		hardTimeout = 0

		local isSafeToStart = isInGameSession() and (not isAnyGamePausingScreen())
		local isGameSaved = false

		if isSafeToStart then
			if not sceneState.isStartupShardSoundPlayed then
				math.randomseed(os.clock() * 1000)
				if math.random(0, 1) == 0 then GetPlayer():PlaySoundEvent("q001_sc_03a_v_puts_in_shard") else GetPlayer():PlaySoundEvent("sq012_sc_01a_v_puts_shard_in_bd_set") end
				sceneState.isStartupShardSoundPlayed = true;
				nextUpdateTime = os.clock() + 0.35
				return lastSceneSetupProgress
			end
			if not sceneState.isStartupShardGlitchPlayed then
				GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "personal_link_glitch");
				sceneState.isStartupShardGlitchPlayed = true;
				nextUpdateTime = os.clock() + 0.5
				return lastSceneSetupProgress
			end
			sceneState.isStartupShardSoundPlayed = nil
			sceneState.isStartupShardGlitchPlayed = nil
			if is_mq055_custom_scene_playback_requested > 0 then
				local hrq = isRogueHangoutModActive(isRogueHangoutsHandlerAvailable()) and isRogueHangoutRestartActive()
				if hrq and isRogueHangoutLoopBreakerActive() then
					questsSystem:SetFactStr("should_activate_rogue_lb_01_mod_hs", 1)
					questsSystem:SetFactStr("last_activated_rogue_lb_01_mod_hs", mathFloor(GameGetEngineTime():ToFloat()))
					if not lastSceneSetupProgress.abortDeadline then lastSceneSetupProgress.lastUpdateTime = os.clock() lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout end
					if type(lastSceneSetupProgress.abortDeadline) == 'number' and os.clock() > lastSceneSetupProgress.abortDeadline then
						sceneData.scenePlaybackProgress = playback.idle
						is_mq055_custom_scene_playback_requested = 0
						request_mq055_custom_scene_playback = 0
						printError(modName..' '..modVer..': Hangouts scene startup timeout. Aborting scene playback.')
						lastSceneSetupProgress.abortDeadline = false
						return false
					end
					nextUpdateTime = os.clock() + 0.25
					return lastSceneSetupProgress
				elseif hrq and type(rqPayload) == 'function' then
					questsSystem:SetFactStr("last_activated_rogue_lb_01_mod_hs", mathFloor(GameGetEngineTime():ToFloat()))
				end
				getLastSavesInfo()
			elseif userSettings.reuseSaves then
				if type(lastModSaveFileName) ~= 'string' then
					getLastSavesInfo()
					lastSceneSetupProgress.lastUpdateTime = os.clock()
					lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout
					fetchLastModSaveFilename(15)
					return lastSceneSetupProgress
				end
			end
			print(modName, "Requesting a game save...", os.clock())
			local oldSavesCount, oldSaveMetadata = getLastSavesInfo()
			lastSceneSetupProgress.oldSavesCount = oldSavesCount
			lastSceneSetupProgress.oldSaveMetadata = oldSaveMetadata
			if is_mq055_custom_scene_playback_requested > 0 then
				isGameSaved = forceAutosave()
			else
				isGameSaved = gameSave(lastModSaveFileName)
			end
		else
			if not lastSceneSetupProgress.abortDeadline then
				lastSceneSetupProgress.lastUpdateTime = os.clock()
				lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout
			end
		end

		if isGameSaved then
			print(modName, "Game save requested. Can continue with scene playback initiation.", os.clock())
			local player = GetPlayer()
			player:PlaySoundEvent(n_global_menu_phone_open)
			sceneState.isSoundMuted = true
			sceneState.playerStartupPos = player:GetWorldPosition()
			sceneState.playerStartupYaw = player:GetWorldYaw()
			sceneState.isLongDistanceTravel = false
			if sceneData.sceneStartupWsLocation then sceneState.isLongDistanceTravel = vectorDistanceSquared(sceneState.playerStartupPos, sceneData.sceneStartupWsLocation) > 8100 end
			nextUpdateTime = os.clock() + 1
			lastSceneSetupProgress.step = lastSceneSetupProgress.step + 1
			lastSceneSetupProgress.lastUpdateTime = os.clock()
			lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout
			return lastSceneSetupProgress
		else
			if type(lastSceneSetupProgress.abortDeadline) == 'number' and lastSceneSetupProgress.abortDeadline > 0 then
				if os.clock() > lastSceneSetupProgress.abortDeadline then
					GetPlayer():PlaySoundEvent(n_global_menu_phone_close)
					sceneState.isSoundMuted = false
					sceneData.scenePlaybackProgress = playback.idle
					lastSceneSetupProgress.abortDeadline = false
					if unfreezeTimeFlag then setFreezePlayer(false) end
					printError(modName, 'Game save init timed out. Aborting scene playback.', os.clock())
					return false
				end
			else
				GetPlayer():PlaySoundEvent(n_global_menu_phone_close)
				sceneState.isSoundMuted = false
				printError(modName, 'Invalid game save init timeout. Aborting scene playback.', os.clock())
				return false
			end
			return lastSceneSetupProgress
		end
	end

	if step == 2 then
		scenePlaybackProgress = sceneData.scenePlaybackProgress
		if scenePlaybackProgress == playback.idle then return false end

		if lastSceneSetupProgress.oldSavesCount then
			local newSavesCount, newSaveMetadata = getLastSavesInfo()
			if newSavesCount == lastSceneSetupProgress.oldSavesCount then
				local keepWaiting = true
				if isSameSaveMetadata(lastSceneSetupProgress.oldSaveMetadata, newSaveMetadata) then
					keepWaiting = true
				else
					keepWaiting = false
					print(modName, "Found new game save.", os.clock())
				end
				if keepWaiting then
					if type(lastSceneSetupProgress.abortDeadline) == 'number' and lastSceneSetupProgress.abortDeadline > 0 then
						if os.clock() > lastSceneSetupProgress.abortDeadline then
							sceneData.scenePlaybackProgress = playback.idle
							is_mq055_custom_scene_playback_requested = 0
							request_mq055_custom_scene_playback = 0
							local warningMsg = modName..' '..modVer..': Game save timeout. Aborting scene playback.\n\tTime elapsed while waiting for a new save: '..tostring(os.clock() - lastSceneSetupProgress.abortDeadline)..' vs. time allowed: '.. tostring(lastSceneSetupProgresstTimeout)
							print(warningMsg)
							lastSceneSetupProgress.abortDeadline = false
							spdlog.warning(warningMsg)
							return false
						end
					else
						local warningMsg = modName..' '..modVer..': Invalid gamesave timeout value. Aborting scene playback.'
						print(warningMsg)
						spdlog.error(warningMsg)
						return false
					end
					return lastSceneSetupProgress
				end
			else
				print(modName, "Found new game save.", os.clock())
			end
		end

		local canSkipGameReload = false

		sceneData.hasDefaultInteractiveSceneSetup = false
		sceneData.defaultInteractiveSceneSetup = nil
		if sceneData.scenePlaybackMode then
			if sceneData.scenePlaybackMode == scenePlaybackMode.interactive then
				sceneData.hasDefaultInteractiveSceneSetup, sceneData.defaultInteractiveSceneSetup = getDefaultInteractiveSceneSetup(gender, sceneName)
				if sceneData.hasDefaultInteractiveSceneSetup and type(sceneData.defaultInteractiveSceneSetup) == 'function' then
					canSkipGameReload = true
				else
					sceneData.hasDefaultInteractiveSceneSetup = false
				end
			end

			if (sceneData.scenePlaybackMode == scenePlaybackMode.fastPlayback or sceneData.scenePlaybackMode == scenePlaybackMode.overrideSceneAvaliability) then
				if isCustomTriggerQuestActive() or isQuestAvaliabilityOverrideAvaliable() then
					if type(sceneData.sceneTargetLocation) == 'string' and isCustomLocationAvailableForPlayback(gender, sceneName, sceneData.sceneTargetLocation) then canSkipGameReload = true end
				end
			end
		end
		sceneState.canSkipGameReload = canSkipGameReload

		if canSkipGameReload or gameReload() then
			if canSkipGameReload and sceneState.isSoundMuted then GetPlayer():PlaySoundEvent(n_global_menu_phone_close) sceneState.isSoundMuted = false end
			lastKnownSavesCount, lastKnownSaveMetadata = getLastSavesInfo()
			
			if is_mq055_custom_scene_playback_requested < 1 then pcall(function() saveLastKnownSaveMetadata(lastKnownSaveMetadata) end) end
			lastSceneSetupProgress.step = lastSceneSetupProgress.step + 1
			lastSceneSetupProgress.lastUpdateTime = os.clock()
			lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout
			return lastSceneSetupProgress
		else
			if type(lastSceneSetupProgress.abortDeadline) == 'number' and lastSceneSetupProgress.abortDeadline > 0 then
				if os.clock() > lastSceneSetupProgress.abortDeadline then
					sceneData.scenePlaybackProgress = playback.idle
					lastSceneSetupProgress.abortDeadline = false
					if unfreezeTimeFlag then setFreezePlayer(false) end
					unfreezeTimeFlag = false
					local warningMsg = modName..' '..modVer..': Game load timed out. Aborting scene playback.'
					print(warningMsg)
					spdlog.warning(warningMsg)
					return false
				end
			else
				local warningMsg = modName..' '..modVer..': Invalid game load timeout. Aborting scene playback.'
				print(warningMsg)
				spdlog.error(warningMsg)
				return false
			end
			return lastSceneSetupProgress
		end
	end

	if step == 3 then
		if isInGameSession() then
			if scenePlaybackProgress == playback.idle then return false end
			local pos, yaw = nil, nil
			sceneData.scenePlaybackProgress = playback.playing
			scenePlaybackProgress = sceneData.scenePlaybackProgress
			if sceneData.approachLocation then
				pos = sceneData.approachLocation.pos
				yaw = sceneData.approachLocation.yaw
			end
			if not stringFind(tostring(pos), 'Vector4') then return false end
			if type(yaw) ~= 'number' then return false end

			if scenePlaybackProgress == playback.idle then return false end

			if isArchiveXLActive and isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.noGameReloads and isCustomTriggerQuestActive() and isKnownName("mod_hotscenes_no_game_reload_support_available") and is_mq055_custom_scene_playback_requested < 1 and (not isAnyHangoutQuestActive()) then
				if questsSystem:GetFactStr("mod_hotscenes_no_game_reload") > 0 then
					local player = GetPlayer()
					sceneState.playerReturnToPos = player:GetWorldPosition()
					sceneState.playerReturnToYaw = player:GetWorldYaw()
				else
					questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 1)
				end
			else
				questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0)
			end

			if sceneData.hasDefaultInteractiveSceneSetup then sceneState.isReadyToTeleport = true end

			if not sceneState.isReadyToTeleport then
				sceneState.isReadyToTeleport = true
				GameObjectEffectHelper.StartEffectEvent(GetPlayer(), n_eyes_closing_instant_open_slow)
				nextUpdateTime = os.clock() + 0.25
				sceneState.shouldUseCustomTriggerQuest = false
				local result, data = pcall(function()
					if not sceneData.scenePlaybackMode then return end
					if not (sceneData.scenePlaybackMode == scenePlaybackMode.fastPlayback or sceneData.scenePlaybackMode == scenePlaybackMode.overrideSceneAvaliability) then return end
					if not isOverridesArchiveDetected then return end
					if not userSettings.enableHotscenesAddon then return end
					if lastSceneSetupProgress.fastTrackPlaybackInitialized then return end
					sceneState.fastTrackFactsSet = nil
					sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
					local fastTrackFactsSet
					if gender == 'female' then
						fastTrackFactsSet = fastTrackPlaybackFactSets.femaleScenes[sceneName]
						sceneState.questAvailabilityOverrideFacts = questAvailabilityOverrideFacts.femaleScenes[sceneName]
					elseif gender == 'male' then
						fastTrackFactsSet = fastTrackPlaybackFactSets.maleScenes[sceneName]
						sceneState.questAvailabilityOverrideFacts = questAvailabilityOverrideFacts.maleScenes[sceneName]
					end
					if type(fastTrackFactsSet) == 'table' then
						sceneState.fastTrackFactsSet = fastTrackFactsSet
						sceneState.isFastTrackPlaybackNoInviteMode = false
						local isSceneOverrideAvaliable = isSceneAvailableInOverrideMode(gender, sceneName, lastSceneSetupProgress.isRomanceScene)
						if sceneData.scenePlaybackMode == scenePlaybackMode.overrideSceneAvaliability and isOverridesArchiveSupportingSceneAvailabilityOverride and (userSettings.enableSceneAvaliabilityOverride or is_mq055_custom_scene_playback_requested > GameGetEngineTime():ToFloat()) then
							questsSystem:SetFactStr(sceneState.fastTrackFactsSet.startFactName, 1)
							questsSystem:SetFactStr(sceneState.fastTrackFactsSet.cutThroughFactName, 1)
							questsSystem:SetFactStr(sceneState.fastTrackFactsSet.overrideFactName, 1)
							if isQuestAvaliabilityOverrideAvaliable() and type(sceneState.questAvailabilityOverrideFacts) == 'table' then
								sceneState.undoQuestAvailiabilityOverrideFacts = setQuestAvaliabilityOverrideFacts(sceneState.questAvailabilityOverrideFacts)
							else
								sceneState.undoSceneAvailiabilityOverrideFacts = setSceneAvaliabilityOverrideFacts(sceneData.overrideFacts)
							end
							sceneState.isFastTrackPlaybackRequested = true
							sceneState.isOverrideSceneAvailabilityModePlaybackRequested = true
						elseif sceneData.scenePlaybackMode == scenePlaybackMode.fastPlayback and (lastSceneSetupProgress.isRomanceScene or userSettings[gender][sceneName].enableFastTrackPlayback) and (isSceneOverrideAvaliable or isScenePerfomerMet(gender, sceneName, lastSceneSetupProgress.isRomanceScene)) then
							if isSceneOverrideAvaliable then
								questsSystem:SetFactStr(sceneState.fastTrackFactsSet.overrideFactName, 1)
								if isQuestAvaliabilityOverrideAvaliable() and type(sceneState.questAvailabilityOverrideFacts) == 'table' then
									sceneState.undoQuestAvailiabilityOverrideFacts = setQuestAvaliabilityOverrideFacts(sceneState.questAvailabilityOverrideFacts)
								else
									sceneState.undoSceneAvailiabilityOverrideFacts = setSceneAvaliabilityOverrideFacts(sceneData.overrideFacts)
								end
								sceneState.isOverrideSceneAvailabilityModePlaybackRequested = true
							end
							questsSystem:SetFactStr(sceneState.fastTrackFactsSet.startFactName, 1)
							questsSystem:SetFactStr(sceneState.fastTrackFactsSet.cutThroughFactName, 1)
							if isOverridesArchiveSupportingSceneAvailabilityOverride then sceneState.isFastTrackPlaybackNoInviteMode = true questsSystem:SetFactStr(sceneState.fastTrackFactsSet.overrideFactName, 1) end
							sceneState.isFastTrackPlaybackRequested = true
						end
						local isBreakSignal = false
						if sceneData.sceneTargetLocation and isCustomLocationAvailableForPlayback(gender, sceneName, sceneData.sceneTargetLocation) then
							local sceneSupportFacts
							sceneState.undoCustomLocationFacts, sceneSupportFacts = setCustomLocationFacts(gender, sceneName, sceneData.sceneTargetLocation)
							sceneState.isCustomLocationPlayback = true
							performCustomLocationSceneConditionsSetup(gender, sceneName, sceneData.sceneTargetLocation)
							if isCustomTriggerQuestActive() then
								local player = GetPlayer()
								if isAnyHangoutQuestActive() and workspotSystem:IsActorInWorkspot(player) then
									local hangoutsSceneFact, hangoutsSceneData = getActiveHangoutSceneData()
									if type(hangoutsSceneData) == 'table' and type(hangoutsSceneData.sceneBreakTeleportTo) == 'function' then
										sceneState.isFastTrackPlaybackRequested = true
										sceneState.shouldUseCustomTriggerQuest = true
										GameObjectEffectHelper.StartEffectEvent(player, n_eyes_closing_fast)
										player:PlaySoundEvent(n_global_menu_phone_open)
										sceneState.isSoundMuted = true
										player:SetInvisible(true)
										setCinematicMode(true, 5)
										player:StartCooldown("mod_hotscenes_keep_hud_hidden", 5)
										local hideHudPayload = function()
											if not GetPlayer then return true end
											local player = GetPlayer()
											if not player then return true end
											if isBreakSignal then player:RemoveCooldown("mod_hotscenes_keep_hud_hidden") return true end
											if not player:IsCooldownActive('mod_hotscenes_keep_hud_hidden') then return true end
											if spycam and (spycam.drone.spawnRequested or spycam.drone.fullySpawned) then return true end
											if isInMenu(true) then return end
											toggleHudMainWindow(false)
										end
										queueTask(hideHudPayload, false, 0.25, 0.01, false)
										local startPos = player:GetWorldPosition()
										local startYaw = player:GetWorldYaw()
										player:StartCooldown("mod_hotscenes_keep_notifications_quiet", 45)
										local taskId = queueTask(hangoutsSceneData.sceneBreakTeleportTo, false, 0.5)

										local timeoutBase = 45
										local timeout = GameGetEngineTime():ToFloat() + timeoutBase
										local hardTimeout = os.clock() + timeoutBase + 90
										local currentEngineTime
										local nextFxTime = 0
										local payload = function()
											if not GetPlayer then return true end
											local player = GetPlayer()
											if not player then return true end
											if not isAnyHangoutQuestActive() then
												local payload = function()
													if not GetPlayer then return end
													if not GetPlayer() then return end
													if isBreakSignal then return end
													GetPlayer():PlaySoundEvent(n_global_menu_phone_close)
													GetPlayer():SetInvisible(false)
													sceneState.isSoundMuted = false
												end
												queueTask(payload, false, 0.1)
												GameObjectEffectHelper.StartEffectEvent(player, n_eyes_opening_05s)
												GameObjectEffectHelper.StopEffectEvent(player, n_eyes_closing_fast)
												questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0)
												questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1)
												local hudTimeout = GameGetEngineTime():ToFloat() + 25
												local hudHardTimeout = os.clock() + 120
												local payload = function()
													if not GetPlayer then return true end
													if not GetPlayer() then return true end
													if spycam and (spycam.drone.spawnRequested or spycam.drone.fullySpawned) then toggleHudMainWindow(true) return true end
													if (GameGetEngineTime():ToFloat() > hudTimeout or os.clock() > hudHardTimeout) then toggleHudMainWindow(true) return true end
												end
												queueTask(payload, false, 3, 0.1, false)
												return true
											end
											local isTimeout = false
											if not sceneState.isFastTrackPlaybackRequested then isTimeout = true printError("isFastTrackPlaybackRequested timeout") end
											if not isTimeout then if sceneState.isIntro or sceneState.isPlayerInHotscene or sceneState.isOutro then isTimeout = true printError("isIntro or isPlayerInHotscene or isOutro timeout:", tostring(sceneState.isIntro), tostring(sceneState.isPlayerInHotscene), tostring(sceneState.isOutro)) end end
											if not isTimeout then
												currentEngineTime = GameGetEngineTime():ToFloat()
												isTimeout = os.clock() > hardTimeout or currentEngineTime > timeout
												if isTimeout then printError("timeout or hardTimeout") end
											end
											if isTimeout then
												isBreakSignal = true
												setCinematicMode(false)
												toggleHudMainWindow(true)
												player:PlaySoundEvent(n_global_menu_phone_close)
												player:RemoveCooldown("mod_hotscenes_keep_notifications_quiet")
												GameObjectEffectHelper.StopEffectEvent(player, n_eyes_closing_fast)
												sceneState.isSoundMuted = false
												player:SetInvisible(false)
												removeAppliedSceneOverrideModePlaybackRestrictions()
												removeQueuedTaskById(taskId)
												resetSceneAvaliabilityOverrideFacts()
												resetQuestAvaliabilityOverrideFacts()
												sceneData.scenePlaybackProgress = playback.idle
												is_mq055_custom_scene_playback_requested = 0
												request_mq055_custom_scene_playback = 0
												GameGetTeleportationFacility():Teleport(player, startPos, EulerAngles.new(0 , 0, startYaw))
												printError(modName..' '..modVer..': Hotscene playback startup timed out while waiting for the game to complete current scene:', hangoutsSceneFact, isAnyHangoutQuestActive())
												queueTask(function() sendWarningMessage(uiStrings.nuiUiStrings.onscreenWarnings.playback.timeout or "Hotscene playback could not be started.") end, false, 3)
												return true
											end
										end
										queueTask(payload, false, 0.1, 0.01, false)
									end
								else
									sceneState.shouldUseCustomTriggerQuest = true
									questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
								end
							end

							if sceneSupportFacts then
								local timeoutBase = 60
								if sceneState.shouldUseCustomTriggerQuest then timeoutBase = 30 end
								local timeout = GameGetEngineTime():ToFloat() + timeoutBase
								local hardTimeout = os.clock() + timeoutBase + 90
								if sceneSupportFacts then
									local payload = function()
										if not GetPlayer then return true end
										if not GetPlayer() then return true end
										if isBreakSignal then
											resetCustomLocationFacts()
											return true
										end
										if os.clock() > hardTimeout then return true end
										if GameGetEngineTime():ToFloat() > timeout then return true end
										if not sceneState.isFastTrackPlaybackRequested then return true end
										if sceneData.scenePlaybackProgress == playback.idle then return true end
										if sceneState.isPlayerInHotscene then return true end
										for fact, value in pairs(sceneSupportFacts) do questsSystem:SetFactStr(fact, value) end
									end
									queueTask(payload, false, 0.1, 0.1, false)
								end
							end
						end
						if sceneState.isFastTrackPlaybackRequested or sceneState.isOverrideSceneAvailabilityModePlaybackRequested then
							sceneState.appliedRestrictions = setSceneOverrideModePlaybackRestrictions()
							setCinematicMode(true, 5)
							if not GetPlayer():IsCooldownActive('mod_hotscenes_keep_hud_hidden') then
								local hideHudTimeout = os.clock() + 5
								GetPlayer():StartCooldown("mod_hotscenes_keep_hud_hidden", 5)
								local hideHudPayload = function()
									if not GetPlayer then return true end
									local player = GetPlayer()
									if not player then return true end
									if isBreakSignal then player:RemoveCooldown("mod_hotscenes_keep_hud_hidden") return true end
									if not player:IsCooldownActive('mod_hotscenes_keep_hud_hidden') then return true end
									if spycam and (spycam.drone.spawnRequested or spycam.drone.fullySpawned) then return true end
									if isInMenu(true) then return end
									toggleHudMainWindow(false)
								end
								queueTask(hideHudPayload, false, 0.25, 0.01, false)
							end
							sceneState.shouldReloadGameOnFinished = true
						end
						lastSceneSetupProgress.fastTrackPlaybackInitialized = true
					end
				end)
				if not result then print(data) spdlog.error(data) end
				return lastSceneSetupProgress
			end

			lastSceneSetupProgress.loadingScreenProgressBarControllerTime = 0
			if sceneData.hasDefaultInteractiveSceneSetup then
				nextUpdateTime = os.clock() + 1
				sceneData.defaultInteractiveSceneSetup()
				sceneData.hasDefaultInteractiveSceneSetup = false
				sceneData.defaultInteractiveSceneSetup = nil
				return false
			elseif sceneState.shouldUseCustomTriggerQuest then
				nextUpdateTime = os.clock() + 0.001
			else
				GameGetTeleportationFacility():Teleport(GetPlayer(), pos, EulerAngles.new(0 , 0, yaw))
				nextUpdateTime = os.clock() + 1
			end

			if not isKnownName("mod_hotscenes_no_game_reload_support_available") then
				unfreezeTimeFlag = true
				setFreezePlayer(true)
			else
				if questsSystem:GetFactStr("mod_hotscenes_no_game_reload") < 1 then
					unfreezeTimeFlag = true
					setFreezePlayer(true)
				else
					unfreezeTimeFlag = false
					setFreezePlayer(false)
				end
			end
			return false
		else
			if type(lastSceneSetupProgress.abortDeadline) == 'number' and lastSceneSetupProgress.abortDeadline > 0 then
				if os.clock() > lastSceneSetupProgress.abortDeadline then
					resetSceneAvaliabilityOverrideFacts()
					resetQuestAvaliabilityOverrideFacts()
					resetCustomLocationFacts()
					removeAppliedSceneOverrideModePlaybackRestrictions()
					sceneData.scenePlaybackProgress = playback.idle
					lastSceneSetupProgress.abortDeadline = false
					if unfreezeTimeFlag then setFreezePlayer(false) end
					unfreezeTimeFlag = false
					local warningMsg = modName..' '..modVer..': Init teleport to scene timed out. Aborting scene playback. '..tostring(os.clock())..'\nLast loading bar timestamp: '..tostring(lastSceneSetupProgress.loadingScreenProgressBarControllerTime)..'\nisInGameSession: '..tostring(isInGameSession())
					print(warningMsg)
					spdlog.warning(warningMsg)
					if sceneState.isOverrideSceneAvailabilityModePlaybackRequested or sceneState.isCustomLocationPlayback then
						sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
						sceneState.isCustomLocationPlayback = nil
						sceneState.shouldReloadGameOnFinished = false
						reloadGameAndClearPlaybackStates()
						return
					end
					return false
				end
			else
				resetSceneAvaliabilityOverrideFacts()
				resetQuestAvaliabilityOverrideFacts()
				resetCustomLocationFacts()
				removeAppliedSceneOverrideModePlaybackRestrictions()
				local warningMsg = modName..' '..modVer..': Invalid init teleport to scene timeout. Aborting scene playback.'
				print(warningMsg)
				spdlog.error(warningMsg)
				if sceneState.isOverrideSceneAvailabilityModePlaybackRequested or sceneState.isCustomLocationPlayback then
					sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
					sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
					sceneState.shouldReloadGameOnFinished = false
					reloadGameAndClearPlaybackStates()
					return
				end
				return false
			end
			return lastSceneSetupProgress
		end
	end

	return false
end

local function isInCustomScenePlaybackMode(tier)
	if not sceneState then return end
	tier = tier or GetPlayer():GetSceneTier()
	if tier < 3 then return end
	if sceneState.isCustomLocationPlayback then return true end
	if sceneState.isIntro then return true end
	if sceneState.isOutro then return true end
	if sceneState.isPlayerInHotscene then return true end
	if sceneState.isNCDelightsScenePlaying then return true end
end
local sceneOngoingPlaybackFacts = {
	'mod_hotscenes_hey_gle_f__ftplay_playing',
	'mod_hotscenes_wbr_jpn_f__ftplay_playing',
	'mod_hotscenes_hey_gle_m__ftplay_playing',
	'mod_hotscenes_wbr_jpn_m__ftplay_playing',
}
local function isAnyScenePlayingByFacts()
	for i, fact in pairs(sceneOngoingPlaybackFacts) do if questsSystem:GetFactStr(fact) > 0 then return true end end
end
local function isPlayerInManagedScene(player, tier);
	player = player or GetPlayer();
	if not player then return end;
	if isInCustomScenePlaybackMode(tier) then return true end
	if isAnyScenePlayingByFacts() then return true end

	local effects = statusEffectSystem:GetAppliedEffectsWithTag(player:GetEntityID(), n_NoMovement);
	if not effects then return end;
	for i = 1, #effects do;
		local sources = effects[i].sourcesData
		if sources then;
			for ii = 1, #sources do;
				if stringMatch(sources[ii].name.value, "_prostit") then;
					return true;
				end;
			end;
		end;
	end;
end;

function updateSceneState(isReset)
	if not GetPlayer then return end

	sceneState.isSpycamAllowed = false
	if reset then sceneState = {sceneTier = 0, sceneName = '', scenePerformerGender = '', isPlayerInHotscene = false, isPerformerPaid = false, isPlayerUndressed = false, lastSceneUndressPlayerRequest = 0, clipFactStr = '', stopFactStr = '', isIntro = false, isClip = false, isOutro = false, performerEntID = nil, isSpycamAllowed = false, isGenderSwitchMode = false, shouldChangeGender = false, changeGenderTime = 0} return end

	local player = GetPlayer()
	if player and sceneState.sceneTier < 3 then sceneState.sceneTier = mathMax(sceneState.sceneTier, player:GetSceneTier()) end
	
	if sceneState.sceneTier > 2 then
		if sceneState.isNCDelightsScenePlaying then sceneState.isSpycamAllowed = true return end

		if not isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride) then
			lastQuestRelatedPaidActionStarted = false
			sceneState.isPerformerPaid = false
			sceneState.isIntro = false
			sceneState.isOutro = false
			sceneState.isPlayerInHotscene = false
			sceneState.isSpycamAllowed = false
			sceneState.performerEntID = nil
			sceneState.isGenderSwitchMode = false
			sceneState.shouldChangeGender = false
			sceneState.wasPlayerNakedOnUndress = false
			sceneState.wasPlayerLegsNakedOnUndress = false
			sceneState.isFastTrackPlaybackRequested = false
			sceneState.isFastTrackPlaybackPerformed = false
			sceneState.isOverrideSceneAvailabilityModePlaybackRequested = false
			sceneState.undoSceneAvailiabilityOverrideFacts = nil
			sceneState.undoQuestAvailiabilityOverrideFacts = nil
			sceneState.appliedRestrictions = nil
			sceneState.undoCustomLocationFacts = nil
			sceneState.isCustomLocationPlayback = nil
			sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
			newRepeat = true
			return false
		end

		resetSceneAvaliabilityOverrideFacts()
		resetQuestAvaliabilityOverrideFacts()

		if sceneState.isFastTrackPlaybackPerformed then
			is_mq055_custom_scene_playback_requested = 0
			sceneState.performerEntID = identifyHotscenePerformer(sceneState.isRomanceScene)
			if sceneState.performerEntID and (not sceneState.isPerformerPaid) then
				lastQuestRelatedPaidActionStarted = false
				sceneState.isPerformerPaid = true
				local hotscenePerformerDetected = false
				if sceneState.scenePerformerGender == 'female' then hotscenePerformerDetected = 'Female' elseif sceneState.scenePerformerGender == 'male' then hotscenePerformerDetected = 'Male' end
				if hotscenePerformerDetected then
					sceneState.isPlayerInScene = true
					sceneState.isIntro = true
					sceneState.isOutro = false
					sceneState.isPlayerInHotscene = false
					sceneState.isSpycamAllowed = true
					sceneState.isGenderSwitchMode = false
					if userSettings.isGenderSwitchFeatureEnabled then
						local playerGenderSelected = selectPlayerTargetGenderForPlayback(hotscenePerformerDetected)
						if type(playerGenderSelected) == 'string' then
							sceneState.isGenderSwitchMode = true
							sceneState.shouldChangeGender = true
							sceneState.changeGenderTime = os.clock() + 10
						end
					end
					sceneState.wasPlayerNakedOnUndress = false
					sceneState.wasPlayerLegsNakedOnUndress = false
				end
			end
		elseif lastQuestRelatedPaidActionStarted then
			if type(lastQuestRelatedPaidActionStarted) == 'number' then
				if os.clock() - lastQuestRelatedPaidActionStarted > 15 then
					lastQuestRelatedPaidActionStarted = false
					sceneState.isPerformerPaid = false
				else
					lastQuestRelatedPaidActionStarted = false
					sceneState.isPerformerPaid = true

					local hotscenePerformerDetected = false
					if isGameV2 then
						for _, sceneData in pairs(femaleScenes) do
							if not hotscenePerformerDetected then
								if sceneData.onscreenTitle == keyDialogTitleLocKey or (type(sceneData.onscreenTitle) == 'string' and GetLocalizedText(sceneData.onscreenTitle) == keyDialogTitleLocKey) then hotscenePerformerDetected = 'Female' break end
							end
						end
						if not hotscenePerformerDetected then
							for _, sceneData in pairs(maleScenes) do
								if not hotscenePerformerDetected then
									if sceneData.onscreenTitle == keyDialogTitleLocKey or (type(sceneData.onscreenTitle) == 'string' and GetLocalizedText(sceneData.onscreenTitle) == keyDialogTitleLocKey) then hotscenePerformerDetected = 'Male' break end
								end
							end
						end
					else
						for _, sceneData in pairs(femaleScenes) do if not hotscenePerformerDetected then if sceneData.onscreenTitle == keyDialogTitleLocKey then hotscenePerformerDetected = 'Female' break end end end
						if not hotscenePerformerDetected then
							for _, sceneData in pairs(maleScenes) do if not hotscenePerformerDetected then if sceneData.onscreenTitle == keyDialogTitleLocKey then hotscenePerformerDetected = 'Male' break end end end
						end
					end

					if hotscenePerformerDetected then
						sceneState.isPlayerInScene = true
						sceneState.isIntro = true
						sceneState.isOutro = false
						sceneState.isPlayerInHotscene = false
						sceneState.isSpycamAllowed = true
						sceneState.performerEntID = identifyHotscenePerformer(sceneState.isRomanceScene)
						sceneState.isGenderSwitchMode = false
						if userSettings.isGenderSwitchFeatureEnabled then
							local playerGenderSelected = selectPlayerTargetGenderForPlayback(hotscenePerformerDetected)
							if type(playerGenderSelected) == 'string' then
								sceneState.isGenderSwitchMode = true
								sceneState.shouldChangeGender = true
								sceneState.changeGenderTime = os.clock() + 10
							end
						end
						sceneState.wasPlayerNakedOnUndress = false
						sceneState.wasPlayerLegsNakedOnUndress = false
					end
				end
			else
				lastQuestRelatedPaidActionStarted = false
			end
		end

		if sceneState.isPlayerUndressed then
			is_mq055_custom_scene_playback_requested = 0
			sceneState.isPlayerInScene = true
			sceneState.isOutro = false
			sceneState.isSpycamAllowed = true
			sceneState.performerEntID = identifyHotscenePerformer(sceneState.isRomanceScene)
			lastQuestRelatedPaidActionStarted = false
			if sceneState.isPlayerInHotscene then
				if sceneState.isIntro then
					sceneState.isIntro = false
					restorePlayerGenderRecords()
					sceneState.shouldChangeGender = false
				end
			end
		else
			sceneState.isPlayerInScene = isPlayerInManagedScene(player, sceneState.sceneTier)
			if sceneState.isPlayerInHotscene then
				is_mq055_custom_scene_playback_requested = 0
				sceneState.isIntro = false
				sceneState.isOutro = true
				sceneState.performerEntID = identifyHotscenePerformer(sceneState.isRomanceScene)
				restorePlayerGenderRecords()
				sceneState.shouldChangeGender = false
				sceneState.wasPlayerNakedOnUndress = false
				sceneState.wasPlayerLegsNakedOnUndress = false
			end
			if (sceneState.isIntro or sceneState.isPlayerInHotscene or sceneState.isOutro) then sceneState.isSpycamAllowed = true end
			sceneState.isPlayerInHotscene = false
			newRepeat = true
		end
	else
		if not is_mq055_custom_scene_playback_requested or is_mq055_custom_scene_playback_requested < GameGetEngineTime():ToFloat() then
			is_mq055_custom_scene_playback_requested = 0
			if sceneState.isPlayerInScene then
				if sceneState.isIntro or sceneState.isOutro then
					restorePlayerGenderRecords()
					sceneState.isIntro = false
					sceneState.isOutro = false
				end
				if spycam then
					spycam.drone:despawn()
					local payload = function() if GetPlayer() then toggleHudMainWindow(true) end end
					queueTask(payload, false, 2)
				end

				if sceneState.isFastTrackPlaybackPerformed then
					sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
					sceneState.isCustomLocationPlayback = nil
					if player and (not player:IsCooldownActive("mod_hotscenes_game_reload_requested")) then
						sceneState.shouldReloadGameOnFinished = false
						if isArchiveXLActive and isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.noGameReloads and isCustomTriggerQuestActive() and isKnownName("mod_hotscenes_no_game_reload_support_available") and questsSystem:GetFactStr("mod_hotscenes_no_game_reload") > 1 then
							-- placeholder
						else
							this:StartCooldown("mod_hotscenes_game_reload_requested", 0.5)
							reloadGameAndClearPlaybackStates()
						end
					end
				end
				sceneState.isFastTrackPlaybackRequested = false
				sceneState.isFastTrackPlaybackPerformed = false
				sceneState.fastTrackFactsSet = nil
				sceneState.playerStartupPos = nil
				sceneState.playerStartupYaw = nil
				sceneState.isPlayerMovedBackToOrigin = false
				resetSceneAvaliabilityOverrideFacts()
				resetQuestAvaliabilityOverrideFacts()
				resetCustomLocationFacts()
				removeAppliedSceneOverrideModePlaybackRestrictions()
				sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
			end
			sceneState.isPlayerInScene = false
			lastQuestRelatedPaidActionStarted = false
			sceneState.isPerformerPaid = false
			sceneState.isPlayerInHotscene = false
			sceneState.isSpycamAllowed = false
			sceneState.performerEntID = nil
			sceneState.isGenderSwitchMode = false
			sceneState.shouldChangeGender = false
			sceneState.wasPlayerNakedOnUndress = false
			sceneState.wasPlayerLegsNakedOnUndress = false
			newRepeat = true
		end
	end
end

local clipStep = 0
local isFemaleScene = false

function extendHotsceneSequence(force)
	if (not sceneState.isPlayerInScene) and (not sceneState.isNCDelightsScenePlaying) then return end
	if not GetPlayer() then return end

	clipStep = 0
	if femaleScenes then
		for scene, sceneData in pairs(femaleScenes) do
			if sceneData.isAvailable or sceneData.isAvailableOnlyInOverrideMode or sceneState.isNCDelightsScenePlaying then
				if force or sceneData.scenePlaybackProgress ~= playback.idle then
					if type(sceneData.clipFactStr) == 'string' then
						clipStep = questsSystem:GetFactStr(sceneData.clipFactStr)
						if clipStep > 0 then
							sceneState.clipFactStr = sceneData.clipFactStr
							sceneState.sceneName = scene
							if not sceneState.performerEntID then sceneState.scenePerformerGender = 'female' end
							break
						end
					end
				end
			end
		end
	end

	if clipStep == 0 then
		if maleScenes then
			for scene, sceneData in pairs(maleScenes) do
				if sceneData.isAvailable or sceneData.isAvailableOnlyInOverrideMode or sceneState.isNCDelightsScenePlaying then
					if force or sceneData.scenePlaybackProgress ~= playback.idle then
						if type(sceneData.clipFactStr) == 'string' then
							clipStep = questsSystem:GetFactStr(sceneData.clipFactStr)
							if clipStep > 0 then
								sceneState.clipFactStr = sceneData.clipFactStr
								sceneState.sceneName = scene
								if not sceneState.performerEntID then sceneState.scenePerformerGender = 'male' end
								break
							end
						end
					end
				end
			end
		end
	end

	sceneState.isNewHotsceneTick = false
	if clipStep < 1 then return end
	if not sceneState.isPlayerInHotscene then
		sceneState.isPlayerInHotscene = true
		if clipStep < 2 then
			sceneState.isNewHotsceneTick = true
			if sceneState.isSoundMuted then
				GetPlayer():PlaySoundEvent(n_global_menu_phone_close)
				sceneState.isSoundMuted = false
			end
		end
		updateSceneState()
	end

	if not userSettings.extendHotscenes then return end

	if newRepeat then
		clipStepRepeatCounter = maxClipStepsRepeat + mathFloor(math.random() * 4)
		newRepeat = false
		clipStepRepeatCounter = clipStepRepeatCounter + 1
	end

	if clipStep > 2 and clipStepRepeatCounter > 0 then
		clipStepRepeatCounter = clipStepRepeatCounter - 1
		questsSystem:SetFactStr(sceneState.clipFactStr, 2)
	end
end

defaultPerformerSceneSupport = {}
defaultPerformerSceneSupport.female = {}
defaultPerformerSceneSupport.male = {}
defaultPerformerSceneSupport.female.defaultGlenSetup = {facts = {{factName = "mod_hotscenes_aux01_mode", value = 1}}}
defaultPerformerSceneSupport.female.defaultJapantownSetup = {facts = {{factName = "mod_hotscenes_aux01_mode", value = 1}}}
defaultPerformerSceneSupport.female.default = {Glen = defaultPerformerSceneSupport.female.defaultGlenSetup, Japantown = defaultPerformerSceneSupport.female.defaultJapantownSetup}
defaultPerformerSceneSupport.female.Glen = {Glen = defaultPerformerSceneSupport.female.defaultGlenSetup}
defaultPerformerSceneSupport.female.Japantown = {Japantown = defaultPerformerSceneSupport.female.defaultJapantownSetup}
defaultPerformerSceneSupport.female.judy = {
	Glen = defaultPerformerSceneSupport.female.defaultGlenSetup,
	aux01_support = function(this)
		local sh = this:FindComponentByName("s1_074_wa_shoe__platform_shoe8766")
		if not sh then return end;
		local bd = this:FindComponentByName("t0_001_wa_body__judy5216")
		if not bd then return end;
		if bd.chunkMask ~= 18446744073709529497ULL then return end;
		sh.chunkMask = 0ULL;
		bd.chunkMask = 18446744073709546973ULL
		sh:Toggle(false)
		bd:Toggle(false)
		bd:Toggle(true)
	end
}
defaultPerformerSceneSupport.female.judy_v2 = defaultPerformerSceneSupport.female.judy
defaultPerformerSceneSupport.female.judy_no_tatts_v2 = defaultPerformerSceneSupport.female.judy

setPerformerSceneSupport = function(performerName, sceneName, gender, performerData)
	questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 0)
	if (not isPlayerMale) and (not isKnownName("3581108883135097242")) then return end
	if not isStringValid(performerName) then return end
	if not isStringValid(sceneName) then return end
	if type(performerData) ~= 'table' then
		if not isStringValid(gender) then return end
		local performers
		if gender == 'female' then
			if femalePerformersCount < 1 then return end
			performers = femalePerformers
		elseif gender == 'male' then
			if malePerformersCount < 1 then return end
			performers = malePerformers
		else return end
		if type(performers) ~= 'table' then return end
		performerData = performers[performerName]
		if type(performerData) ~= 'table' then return end
	end
	gender = gender or performerData.gender
	if not isStringValid(gender) then return end
	local sceneSupport
	if isStringValid(performerData.sceneSupport) then
		if type(defaultPerformerSceneSupport[gender]) ~= 'table' then return end
		sceneSupport = defaultPerformerSceneSupport[gender][performerData.sceneSupport]
		if type(sceneSupport) == 'table' then sceneSupport = sceneSupport[sceneName] else sceneSupport = nil end
	elseif type(performerData.sceneSupport) == 'table' then
		sceneSupport = performerData.sceneSupport
		if type(sceneSupport) == 'table' then sceneSupport = sceneSupport[sceneName] else sceneSupport = nil end
	end
	if not sceneSupport then
		local activeSceneSupport = defaultPerformerSceneSupport[gender][stringLower(performerName)]
		if type(activeSceneSupport) == 'table' then
			local sceneSupport = activeSceneSupport[sceneName]
			if type(sceneSupport) == 'table' then
				performerData.activeSceneSupport = activeSceneSupport
				sceneState.lastSelectedPerformerData = performerData
			else
				sceneSupport = nil
			end
		end
	end
	if type(sceneSupport) ~= 'table' then return end
	if type(sceneSupport.facts) ~= 'table' then return end
	for i, entry in pairs(sceneSupport.facts) do
		if isStringValid(entry.factName) and type(entry.value) == 'number' then
			questsSystem:SetFactStr(entry.factName, entry.value)
		end
	end
end

function setRomancePerformerToScene(performerName, sceneName, gender)
	local sceneData
	if gender == 'female' and romanceScenesFemale then sceneData = romanceScenesFemale elseif gender == 'male' and romanceScenesMale then sceneData = romanceScenesMale end
	if not sceneData then return end
	sceneData = sceneData[sceneName]
	if not sceneData then return end
	if not sceneData.performers then return end
	local entPath = sceneData.performers[stringLower(performerName)]
	if type(entPath) ~= 'string' then return end
	clearPerformerReplicatingPlayer(sceneName, gender)
	TweakDB:SetFlat(sceneData.tdbidPath, entPath)
	return true
end

function setPerformerToScene(performerName, sceneName, gender, isRomanceScene)
	if not isHotscenesDataLoaded then return false end
	if type(performerName) ~= 'string' then return false end
	if type(sceneName) ~= 'string' then return false end
	if type(gender) ~= 'string' then return false end
	if isRomanceScene then return setRomancePerformerToScene(performerName, sceneName, gender) end

	local scenes, performers = nil, nil
	if gender == 'female' then
		if femaleScenesCount < 1 then return false end
		if femalePerformersCount < 1 then return false end
		scenes = femaleScenes
		performers = femalePerformers
	elseif gender == 'male' then
		if maleScenesCount < 1 then return false end
		if malePerformersCount < 1 then return false end
		scenes = maleScenes
		performers = malePerformers
	else return false end

	if type(scenes) ~= 'table' then return false end
	if type(performers) ~= 'table' then return false end

	if not scenes[sceneName] then return end

	local performerData = performers[performerName]
	if not performerData then return end

	if isPerformerReplacingPlayerSupported then
		local isPlayer = performerData.scenes and performerData.scenes[sceneName].isPlayer
		if isPlayer and setPerformerReplicatingPlayer(sceneName) then return true end
	end

	if performerData.isEp1 and (not isEp1Allowed) then return false end

	local sceneTdbidPath, performerEntPath = nil, nil
	local isFullEntPath = false

	sceneTdbidPath = scenes[sceneName].tdbidPath
	if type(sceneTdbidPath) ~= 'string' then return false end

	performerEntPath = performerData.scenes[sceneName].performerEntPath
	if not performerEntPath then
		performerEntPath = performerData.scenes[sceneName].fullPerformerEntPath
		if performerEntPath then isFullEntPath = true end
	end

	if type(performerEntPath) == 'string' then
		if not isFullEntPath then
			if performerData.isEp1 then
				performerEntPath = hotscenesData.rootFolderEp1..performerName..'\\'..performerEntPath
			else
				performerEntPath = hotscenesData.rootFolder..performerName..'\\'..performerEntPath
			end
		end
	else
		performerEntPath = scenes[sceneName].performerEntPath
	end
	if type(performerEntPath) ~= 'string' then return false end

	if isKnownName("Hotscenes_mod_shouldUseLowerCasePaths") then performerEntPath = stringLower(performerEntPath) end

	clearPerformerReplicatingPlayer(sceneName, gender)
	TweakDB:SetFlat(sceneTdbidPath, performerEntPath)
	setPerformerSceneSupport(performerName, sceneName, gender, performerData)

	return true
end

function getPerformerDataForPreview(performerName, sceneName, gender)
	if not isHotscenesDataLoaded then return end
	if type(performerName) ~= 'string' then return end
	if type(sceneName) ~= 'string' then return end
	if type(gender) ~= 'string' then return end

	local scenes, performers
	if gender == 'female' then
		if femaleScenesCount < 1 then return end
		if femalePerformersCount < 1 then return end
		scenes = femaleScenes
		performers = femalePerformers
	elseif gender == 'male' then
		if maleScenesCount < 1 then return end
		if malePerformersCount < 1 then return end
		scenes = maleScenes
		performers = malePerformers
	else return end

	if type(scenes) ~= 'table' then return end
	if type(performers) ~= 'table' then return end

	if not scenes[sceneName] then return end

	local performerData = performers[performerName]
	if not performerData then return end

	local isPlayer, isPlayerIncognito
	if isPerformerReplacingPlayerSupported then
		isPlayer = performerData.scenes and performerData.scenes[sceneName].isPlayer
		if isPlayer then isPlayerIncognito = not userSettings.isPlayerPerformerDiscovered end
	end

	if performerData.isEp1 and (not isEp1Allowed) then return end

	local sceneTdbidPath, performerEntPath
	local isFullEntPath = false

	performerEntPath = performerData.scenes[sceneName].performerEntPath
	if not performerEntPath then
		performerEntPath = performerData.scenes[sceneName].fullPerformerEntPath
		if performerEntPath then isFullEntPath = true end
	end

	if type(performerEntPath) == 'string' then
		if not isFullEntPath then
			if performerData.isEp1 then
				performerEntPath = hotscenesData.rootFolderEp1..performerName..'\\'..performerEntPath
			else
				performerEntPath = hotscenesData.rootFolder..performerName..'\\'..performerEntPath
			end
		end
	else
		performerEntPath = scenes[sceneName].performerEntPath
	end
	if type(performerEntPath) ~= 'string' then return end

	if isKnownName("Hotscenes_mod_shouldUseLowerCasePaths") then performerEntPath = stringLower(performerEntPath) end
	return performerEntPath, isPlayer, isPlayerIncognito
end

local defaultPerformers = {
	female = {
		Glen = {
			appearanceName = {id = "Character.hey_gle_prostitute_female.appearanceName", val = "None"},
			attachmentSlots = {id = "Character.hey_gle_prostitute_female.attachmentSlots", getVal = function() return TweakDBID:GetFlat("Character.hey_gle_prostitute_female_backup_mod_hotscenes.attachmentSlots") end},
			entPath = {id = "Character.hey_gle_prostitute_female.entityTemplatePath", baseEntPath = 3346656707293453061ULL, ep1EntPath = 3346656707293453061ULL},
			genders = {id = "Character.hey_gle_prostitute_female.genders", val = {}},
		},
		Japantown = {
			appearanceName = {id = "Character.wbr_jpn_prostitute_female.appearanceName", val = "None"},
			attachmentSlots = {id = "Character.wbr_jpn_prostitute_female.attachmentSlots", getVal = function() return TweakDBID:GetFlat("Character.wbr_jpn_prostitute_female_backup_mod_hotscenes.attachmentSlots") end},
			entPath = {id = "Character.wbr_jpn_prostitute_female.entityTemplatePath", baseEntPath = 17024060685192978184ULL, ep1EntPath = 17024060685192978184ULL},
			genders = {id = "Character.wbr_jpn_prostitute_female.genders", val = {}},
		},
	},
	male = {
		Glen = {
			appearanceName = {id = "Character.hey_gle_prostitute_male.appearanceName", val = "None"},
			attachmentSlots = {id = "Character.hey_gle_prostitute_male.attachmentSlots", getVal = function() return TweakDBID:GetFlat("Character.hey_gle_prostitute_male_backup_mod_hotscenes.attachmentSlots") end},
			entPath = {id = "Character.hey_gle_prostitute_male.entityTemplatePath", baseEntPath = 11917578689493647784ULL, ep1EntPath = 11917578689493647784ULL},
			genders = {id = "Character.hey_gle_prostitute_male.genders", val = {}},
		},
		Japantown = {
			appearanceName = {id = "Character.wbr_jpn_prostitute_male.appearanceName", val = "None"},
			attachmentSlots = {id = "Character.wbr_jpn_prostitute_male.attachmentSlots", getVal = function() return TweakDBID:GetFlat("Character.wbr_jpn_prostitute_male_backup_mod_hotscenes.attachmentSlots") end},
			entPath = {id = "Character.wbr_jpn_prostitute_male.entityTemplatePath", baseEntPath = 14933202360280190969ULL, ep1EntPath = 14933202360280190969ULL},
			genders = {id = "Character.wbr_jpn_prostitute_male.genders", val = {}},
		},
	}
}

function restorePerformerRecord(data)
	if type(data) ~= 'table' then return end
	if data.entPath and data.entPath.id and TweakDB:GetFlat(data.entPath.id) then
		if isEp1Allowed then
			if type(data.entPath.ep1EntPath) == 'cdata' then TweakDB:SetFlat(data.entPath.id, ResRef.FromHash(data.entPath.ep1EntPath).resource) end
		else
			if type(data.entPath.baseEntPath) == 'cdata' then TweakDB:SetFlat(data.entPath.id, ResRef.FromHash(data.entPath.baseEntPath).resource) end
		end
	end
	if data.genders and data.genders.id and type(data.genders.val) == 'table' and TweakDB:GetFlat(data.genders.id) then TweakDB:SetFlat(data.genders.id, data.genders.val) end
	if data.appearanceName and data.appearanceName.id and type(data.appearanceName.val) == 'string' and TweakDB:GetFlat(data.appearanceName.id) then TweakDB:SetFlat(data.appearanceName.id, CName.new(data.appearanceName.val)) end
	if data.attachmentSlots and data.attachmentSlots.id and type(data.attachmentSlots.getVal) == 'function' then TweakDB:SetFlat(data.attachmentSlots.id, data.attachmentSlots.getVal()) end
end
function restoreOriginalScenePerformer(sceneName, gender)
	if type(sceneName) ~= 'string' then return false end
	if type(gender) ~= 'string' then return false end
	local data = defaultPerformers[gender]
	if not data then return end
	data = data[sceneName]
	restorePerformerRecord(data)
end

function getPlayerBodyGender()
	if isPreGameState then return false end
	local customizationState = Game.GetCharacterCustomizationSystem():GetState();
	if customizationState:IsBodyGenderMale() then return true, "male" end
	return true, "female"
end
function setPerformerReplicatingPlayer(sceneName)
	if isPreGameState then print("Game is not loaded yet. Aborting.", os.clock()) return end
	if type(sceneName) ~= 'string' then return end
	local isValid, playerGender = getPlayerBodyGender()
	if not isValid then return end
	if type(playerGender) ~= 'string' then return end
	local data = defaultPerformers[playerGender]
	if not data then return end
	data = data[sceneName]
	if not data then return end
	if not data.entPath then return end
	if not data.entPath.id then return end
	if not data.genders then return end
	if not data.genders.id then return end
	if not data.appearanceName then return end
	if not data.appearanceName.id then return end
	if not data.attachmentSlots then return end
	if not data.attachmentSlots.id then return end
	if playerGender == 'female' then
		TweakDB:SetFlat(data.entPath.id, TweakDB:GetFlat("Character.TPP_Player_Cutscene_Female.entityTemplatePath"))
		TweakDB:SetFlat(data.genders.id, {t"Character.TPP_Player_Cutscene_Female_inline0"})
		TweakDB:SetFlat(data.appearanceName.id, "TPP_Body")
		TweakDB:SetFlat(data.attachmentSlots.id, TweakDB:GetFlat("Character.TPP_Player_Cutscene_Female.attachmentSlots"))
		return true
	end
	TweakDB:SetFlat(data.entPath.id, TweakDB:GetFlat("Character.TPP_Player_Cutscene_Male.entityTemplatePath"))
	TweakDB:SetFlat(data.genders.id, {t"Character.TPP_Player_Cutscene_Male_inline0"})
	TweakDB:SetFlat(data.appearanceName.id, "TPP_Body")
	TweakDB:SetFlat(data.attachmentSlots.id, TweakDB:GetFlat("Character.TPP_Player_Cutscene_Male.attachmentSlots"))
	return true
end
function clearPerformerReplicatingPlayer(sceneName, genders)
	if type(sceneName) ~= 'string' then return end
	if type(genders) == 'string' then
		genders = {stringLower(genders)}
	elseif type(genders) ~= 'table' then
		genders = {"female", "male"}
	end
	local result
	for _, gender in pairs(genders) do
		if type(gender) == 'string' then
			local data = defaultPerformers[gender]
			if data then data = data[sceneName] end
			if data and data.genders and data.genders.id then
				local currentGenders = TweakDB:GetFlat(data.genders.id)
				if type(currentGenders) == 'table' and  #currentGenders > 0 then
					restorePerformerRecord(data)
					result = true
				end
			end
		end
	end
	return result
end
function cleanupPerformersByPlayerGender(playerGender)
	if isPreGameState then return end
	if type(playerGender) ~= 'string' then
		local isValid, playerGenderStr = getPlayerBodyGender()
		if not isValid then return end
		playerGender = playerGenderStr
	end
	if playerGender == 'female' then
		clearPerformerReplicatingPlayer('Glen', 'male')
		clearPerformerReplicatingPlayer('Japantown', 'male')
	elseif playerGender == 'male' then
		clearPerformerReplicatingPlayer('Glen', 'female')
		clearPerformerReplicatingPlayer('Japantown', 'female')
	end
end
function isPerformerReplicatingPlayer(sceneName, gender)
	if type(sceneName) ~= 'string' then return end
	if type(gender) ~= 'string' then return end
	local data = defaultPerformers[gender]
	if not data then return end
	data = data[sceneName]
	if not data then return end
	if not data.genders then return end
	if not data.genders.id then return end
	local genders = TweakDB:GetFlat(data.genders.id)
	if type(genders) ~= "table" then return end
	if #genders < 1 then return end
	local female = t"Character.TPP_Player_Cutscene_Female_inline0"
	local male = t"Character.TPP_Player_Cutscene_Male_inline0"
	for i, entry in pairs(genders) do
		if entry == female or entry == male then return true end
	end
end

function identifyHotscenePerformer(isRomanceScene)
	if not sceneState then return nil end
	if not sceneState.isPlayerInScene then return nil end
	local player = GetPlayer()
	if not player then sceneState.performerEntID = nil return end
	if sceneState.performerEntID then return sceneState.performerEntID end
	local this = targetingSystem:GetLookAtObject(player,false,false)

	local scenePool
	if isRomanceScene then
		scenePool = {}
		if romanceScenesFemale then tableInsert(scenePool, romanceScenesFemale) end
		if romanceScenesMale then tableInsert(scenePool, romanceScenesMale) end
	else
		scenePool = {femaleScenes, maleScenes}
	end
	if not scenePool or #scenePool < 1 then return end

	if this and this:IsA('ScriptedPuppet') then
		local thisTDBID = this:GetTDBID()
		local thisIdHash = thisTDBID.hash
		if thisIdHash > 1 then
			for _, scenes in ipairs(scenePool) do
				if scenes then
					for scene, sceneData in pairs(scenes) do
						if sceneData.characterTdbidHash == thisIdHash then
							sceneState.performerEntID = this:GetEntityID()
							sceneState.scenePerformerGender = sceneData.gender
							if isPerformerReplacingPlayerSupported and isPerformerReplicatingPlayer(sceneName, sceneData.gender) then
								userSettings.isPlayerPerformerDiscovered = true
								if sceneData.lastSelectedPerformer == "player_incognito" then sceneData.lastSelectedPerformer = "player" updateCetUi = os.clock() + 0.1 end
								if sceneData.lastUnknownSelectedPerformer == "player_incognito" then sceneData.lastUnknownSelectedPerformer = "player" end
							end
							return sceneState.performerEntID
						end
					end
				end
			end
		end
	end

	local hudManager
	if not pcall(function() hudManager = player:GetHudManager() end) then return nil end

	local targets = {hudManager.currentTarget, hudManager.lastTarget}

	for _, target in pairs(targets) do
		if target and target.type == HUDActorTypePUPPET then
			local targetObject = GameFindEntityByID(target.entityID)
			if targetObject then
				local targetObjectTDBID = targetObject:GetRecordID()
				if targetObjectTDBID.hash > 1 then
					for _, scenes in ipairs(scenePool) do
						if scenes then
							for scene, sceneData in pairs(scenes) do
								if sceneData.characterTdbidHash == targetObjectTDBID.hash then
									sceneState.performerEntID = target.entityID
									sceneState.scenePerformerGender = sceneData.gender
									if isPerformerReplacingPlayerSupported and isPerformerReplicatingPlayer(sceneName, sceneData.gender) then
										userSettings.isPlayerPerformerDiscovered = true
										if sceneData.lastSelectedPerformer == "player_incognito" then sceneData.lastSelectedPerformer = "player" updateCetUi = os.clock() + 0.1 end
										if sceneData.lastUnknownSelectedPerformer == "player_incognito" then sceneData.lastUnknownSelectedPerformer = "player" end
									end
									return target.entityID
								end
							end
						end
					end
				end
			end
		end
	end
end

function isAreaRestrictedOrDangerous(verifyArea, player)
	player = player or GetPlayer()
	local securityZoneData = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefs.PlayerStateMachine):GetVariant(allBlackboardDefs.PlayerStateMachine.SecurityZoneData)
	if not securityZoneData then return false end
	local securityZoneData = FromVariant(securityZoneData)
	if not securityZoneData then return false end
	local securityAreaPS = securityZoneData.securityArea
	if not securityAreaPS then return false end
	local securityAreaType = securityZoneData.securityAreaType
	local enumInt = EnumInt(securityAreaType)
	if enumInt < 2 then return false end
	if not verifyArea then return true end
	local securityArea = securityAreaPS:GetOwnerEntityWeak()
	if not securityArea then return false end
	local entities = securityArea.area:GetOverlappingEntities()
	for i, entity in pairs(entities) do
		if IsDefinedNS(entity) and entity:IsNPC() and (entity:IsCharacterGanger() or entity:IsCharacterCyberpsycho()) then
			if entity:IsAggressive() or entity:IsEnemy() then return true end
		end
	end
	if enumInt == 3 then return false end
	if enumInt == 2 then
		local securitySystem = securityAreaPS:GetSecuritySystem()
		if not securitySystem then return false end
		return securitySystem:IsEntityBlacklisted(player)
	end
	return true
end

function isPlayerScanning()
	local scannerMode = false
	pcall(function() scannerMode = FromVariant(gameBlackBoardSystem:Get(allBlackboardDefs.UI_Scanner):GetVariant(allBlackboardDefs.UI_Scanner.ScannerMode)) end)
	if scannerMode then if scannerMode.mode then if scannerMode.mode ~= gameScanningMode.Inactive then return true end end end
	return false
end

function isPlayerInBraindance()
	return gameBlackBoardSystem:Get(allBlackboardDefs.Braindance):GetBool(allBlackboardDefs.Braindance.IsActive)
end

function isPlayerInCall(player)
	local infoVariant = gameBlackBoardSystem:Get(GetAllBlackboardDefs().UI_ComDevice):GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation);
	if not infoVariant then return end
	local lastPhoneCallInformation = FromVariant(infoVariant);
	if not lastPhoneCallInformation then return end
	local callPhase = lastPhoneCallInformation.callPhase
	local callMode = lastPhoneCallInformation.callMode
	if callPhase == questPhoneCallPhase.EndCall and callMode == questPhoneCallMode.Video then return end
	if callPhase == questPhoneCallPhase.StartCall and callMode == questPhoneCallMode.Video then return true end
	if callPhase == questPhoneCallPhase.IncomingCall then return true end
	if callMode == questPhoneCallMode.Audio then return true end
end

function isPlayerInFastTravel()
	if gameBlackBoardSystem:Get(allBlackboardDefs.FastTRavelSystem):GetBool(allBlackboardDefs.FastTRavelSystem.FastTravelLoadingScreenFinished) then return false end
	if not FromVariant(gameBlackBoardSystem:Get(allBlackboardDefs.FastTRavelSystem):GetVariant(allBlackboardDefs.FastTRavelSystem.DestinationPoint)) then return false end
	return true
end

function isComputerControl()
	local isUIZoomDevice = false
	pcall(function() isUIZoomDevice = gameBlackBoardSystem:GetLocalInstanced(GetPlayer():GetEntityID(), allBlackboardDefs.PlayerStateMachine):GetBool(allBlackboardDefs.PlayerStateMachine.IsUIZoomDevice) end)
	if isUIZoomDevice then return true end
	return false
end

function isPlayerInVehicle(player)
	player = player or GetPlayer()
	return GetMountedVehicle(player)
end

function isPreGame(skipPreCheck)
	if skipPreCheck then return GameGetSystemRequestsHandler():IsPreGame() end
	if not GetPlayer then return true end
	if not GetPlayer() then return true end
	return GameGetSystemRequestsHandler():IsPreGame()
end

function isGamePaused()
	return GameGetSystemRequestsHandler():IsGamePaused()
end

function isPlayerDetached(player)
	player = player or GetPlayer()
	if not player then return true end
	local streetCred = statsSystem:GetStatValue(player:GetEntityID(), 'StreetCred') --(c)psiberx)
	if not streetCred then return true end
	return streetCred < 1
end

function isRadialWheel()
	if timeSystem:IsTimeDilationActive('radial') then return true end -- (c)psiberx hint
	return false
end

function isPhotoMode()
	local isActive = false
	pcall(function() isActive = gameBlackBoardSystem:Get(allBlackboardDefs.PhotoMode):GetBool(allBlackboardDefs.PhotoMode.IsActive) end)
	if isActive then return true end
	return false
end

function isInMenu(skipPreCheck)
	if not skipPreCheck then
		if isModDisabled then return true end
		if not GetPlayer then return true end
		if not GetPlayer() then return true end
	end
	local result, blackboardSystem = pcall(function() return gameBlackBoardSystem:Get(allBlackboardDefs.UI_System) end)
	if not blackboardSystem then return true end
	if blackboardSystem:GetBool(allBlackboardDefs.UI_System.IsInMenu) then return true end
	return false
end

function isAnyGamePausingScreen()
	if isModDisabled then return true end
	local result, blackboardSystem = pcall(function() return gameBlackBoardSystem:Get(allBlackboardDefs.UI_System) end)
	if not blackboardSystem then return true end
	if blackboardSystem:GetBool(allBlackboardDefs.UI_System.IsInMenu) then return true end
	if isPreGame() then return true end
	if isGamePaused() then return true end
	if not isInGameSession() then return false end
	if isRadialWheel() then return true end
	if isPhotoMode() then return true end
	return false
end

function isInGameSession(player)
	player = player or GetPlayer()
	if not player then return end
	if isPlayerDetached(player) then return false end
	return player:GetSceneTier() > 0
end

function isCensored()
	return not Game.GetCharacterCustomizationSystem():IsNudityAllowed()
end

local isHotscenesAvailableBool = false
local isHotscenesAllowedBool = false
local isPlaybackAllowedBool = false

local function isEndingActive()
	if isEnding then return true end

	if questsSystem:GetFactStr('q115_point_of_no_return') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q115_00b_johnny_angry') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q115_hanako_sitting') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q307_point_of_no_return') > 0 then isEnding = true return true end
	return false
end

function isHotscenesAvailable(force, overrideAvaliabilityByFacts)
	if isNudityCensored then return false, 'isCensored' end
	if not force and isEndingActive() then return false, 'isEnding' end

	local isAnyPerformerAvailable = false
	for _, scenes in ipairs({femaleScenes, maleScenes}) do
		for sceneName, sceneData in pairs(scenes) do
			if sceneData then
				sceneData.isAvailable = false
				sceneData.isAvailableOnlyInOverrideMode = false
				if force then sceneData.isAvailable = true else
					if not sceneData.isAvailable then
						if type(sceneData.prerequisiteFacts) == 'table' and #sceneData.prerequisiteFacts > 0 then
							for i = 1, #sceneData.prerequisiteFacts do
								if not sceneData.isAvailable then
									if type(sceneData.prerequisiteFacts[i]) == 'string' then
										if questsSystem:GetFactStr(sceneData.prerequisiteFacts[i]) > 0 then sceneData.isAvailable = true end
										if sceneData.isAvailable then isAnyPerformerAvailable = true end
									end
								end
							end
						end
					end

					if not sceneData.isAvailable and overrideAvaliabilityByFacts and isOverridesArchiveSupportingSceneAvailabilityOverride then
						if type(sceneData.sceneOverrideAvaliabilityFacts) == 'table' and #sceneData.sceneOverrideAvaliabilityFacts > 0 and type(sceneData.overrideFacts) == 'table' and #sceneData.overrideFacts > 0 then
							for _, fact in ipairs(sceneData.sceneOverrideAvaliabilityFacts) do
								if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
									sceneData.isAvailableOnlyInOverrideMode = true
									isAnyPerformerAvailable = true
									break
								end
							end
						end
					end
				end
			end
		end
	end

	if force then return true, 'legacyForcedSceneAvailability' end
	return isAnyPerformerAvailable, 'isAnyPerformerAvailable'
end

function isSceneAvailableInOverrideMode(gender, sceneName, isRomanceScene, force)
	if not isOverridesArchiveSupportingSceneAvailabilityOverride then return end
	if isNudityCensored then return false end
	if not force and isEndingActive() then return false end

	local sceneData
	if isRomanceScene then
		if gender == 'female' and romanceScenesFemale then sceneData = romanceScenesFemale[sceneName] elseif gender == 'male' and romanceScenesMale then sceneData = romanceScenesMale[sceneName] end
	else
		if gender == 'female' then sceneData = femaleScenes[sceneName] elseif gender == 'male' then sceneData = maleScenes[sceneName] else return false end
	end
	if not sceneData then return end

	if type(sceneData.isValidSceneOverrideAvaliabilityFacts) ~= 'boolean' then sceneData.isValidSceneOverrideAvaliabilityFacts = type(sceneData.sceneOverrideAvaliabilityFacts) == 'table' and #sceneData.sceneOverrideAvaliabilityFacts > 0 and type(sceneData.overrideFacts) == 'table' and #sceneData.overrideFacts > 0 end

	if sceneData.isValidSceneOverrideAvaliabilityFacts then
		for _, fact in ipairs(sceneData.sceneOverrideAvaliabilityFacts) do
			if type(fact) == 'string' and questsSystem:GetFactStr(fact) > 0 then
				return true
			end
		end
	end
end

function isScenePerfomerMet(gender, sceneName, isRomanceScene)
	if isRomanceScene then return true end
	if gender == 'female' then
		return questsSystem:GetFactStr(femaleScenes[sceneName].alreadyMetFact) > 0
	elseif gender == 'male' then
		return questsSystem:GetFactStr(maleScenes[sceneName].alreadyMetFact) > 0
	end
end

function isOutsideSceneActiveArea(gender, sceneName)
	return not isInDefaultInteractiveSceneArea(gender, sceneName)
end

local statusEffectTags
function isHotscenesAllowed()
	if isModDisabled then return false, 'isModDisabled' end
	local player = GetPlayer()
	if not isInGameSession(player) then return false, 'notInGameSession' end
	if player:GetSceneTier() >= 3 then return false, 'inScene' end
	if player:IsCooldownActive("hotscenes_mod_pay_workspot_interaction_cooldown") then return false, 'isHangoutsScene' end
	if player:IsCooldownActive("hotscenes_mod_nc_delights_scene_playback_start_cooldown") then return false, 'isHangoutsScene' end
	if GameIsSavingLocked() then return false, 'isSavingLocked' end
	if isPlayerInVehicle(player) then return false, 'inVehicle' end
	if workspotSystem:IsActorInWorkspot(player) then return false, 'inWorkspot' end
	if player:IsInCombat() then return false, 'inCombat' end
	if isAreaRestrictedOrDangerous(true, player) then return false, 'inRestrictedArea' end
	if isPlayerScanning() then return false, 'isScanning' end
	if isPlayerInCall(player) then return false, 'isInCall' end
	if isPlayerInBraindance() then return false, 'isBraindance' end
	if isComputerControl() then return false, 'isInDeviceControl' end
	if isPlayerInFastTravel() then return false, 'isFastTravel' end
	if player:IsJohnnyReplacer() then return false, 'isJohnnyReplacer' end
	if questsSystem:GetFactStr('isPlayerPossessedByJohnny') > 0 then return false, 'isPlayerPossessedByJohnny' end
	if GameGetScriptableSystemsContainer():Get(n_PreventionSystem):GetHeatStage() ~= EPreventionHeatStageHeat_0 then return false, 'isWanted' end

	statusEffectTags = statusEffectTags or {n"Unconscious", n"Defeated", n"Cyberspace", n"CyberspacePresence", n"NoPhone", n"BlockFastTravel", n"PhoneNoCalling", n"BlockAllHubMenu", n"NoTimeDisplay"}
	if enable_mq055_hangouts_support then
		local reason = 'isRestrictedState'
		local isNotAllowed = StatusEffectSystem.ObjectHasStatusEffectWithTags(player, statusEffectTags)
		if isNotAllowed and isAnyHangoutQuestActive() then isNotAllowed = false reason = 'isHangoutsScene' end
		if isNotAllowed then return false, reason end
	else
		if StatusEffectSystem.ObjectHasStatusEffectWithTags(player, statusEffectTags) then return false, 'isRestrictedState' end
	end

	return true, 'isAllowed'
end

function isKnownName(inputString)
	return CName.new(inputString).value == inputString
end

local function setupSettingsForSave(gender, genderBasedScenes)
	for sceneName, sceneData in pairs(genderBasedScenes) do
		if sceneName == "uniquePerformerFullNames" then
			if userSettings[gender][sceneName] then userSettings[gender][sceneName] = nil end
		else
			if not userSettings[gender] then userSettings[gender] = {} end
			if not userSettings[gender][sceneName] then userSettings[gender][sceneName] = {} end
			if isStringValid(sceneData.lastUnknownSelectedPerformer) then
				local lastUnknownSelectedPerformer = sceneData.lastUnknownSelectedPerformer
				if lastUnknownSelectedPerformer == 'player_incognito' and userSettings.isPlayerPerformerDiscovered then lastUnknownSelectedPerformer = 'player' end
				userSettings[gender][sceneName].lastSelectedPerformer = lastUnknownSelectedPerformer
			else
				local lastSelectedPerformer = sceneData.lastSelectedPerformer
				if lastSelectedPerformer == 'player_incognito' and userSettings.isPlayerPerformerDiscovered then lastSelectedPerformer = 'player' end
				userSettings[gender][sceneName].lastSelectedPerformer = lastSelectedPerformer
			end
			if isStringValid(sceneData.lastUnknownSelectedCustomLocation) then
				userSettings[gender][sceneName].lastSelectedCustomLocation = sceneData.lastUnknownSelectedCustomLocation
			else
				userSettings[gender][sceneName].lastSelectedCustomLocation = sceneData.lastSelectedCustomLocation
			end
		end
	end
end

function saveUserSettings()
	setupSettingsForSave('female', femaleScenes)
	setupSettingsForSave('male', maleScenes)
	local jString = dumpTableToJson(userSettings, true, true)
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
	local result = true
	local isAnyPerformerFound = false
	if file then
		local jString = file:read("*a")
		file:close()

		if type(jString) == 'string' then
			local decodeResult, settings = pcall(function() return json.decode(jString) end)
			if type(settings) == 'table' then
				if type(settings.reuseSaves) == 'boolean' then userSettings.reuseSaves = settings.reuseSaves end
				if type(settings.extendHotscenes) == 'boolean' then userSettings.extendHotscenes = settings.extendHotscenes end
				if type(settings.hideNpcSpecs) == 'boolean' then userSettings.hideNpcSpecs = settings.hideNpcSpecs end
				if type(settings.hideNpcFishnetTights) == 'boolean' then userSettings.hideNpcFishnetTights = settings.hideNpcFishnetTights end
				if type(settings.ncDelightsHideFishnetTights) == 'boolean' then userSettings.hideNpcFishnetTights = settings.ncDelightsHideFishnetTights or settings.hideNpcFishnetTights userSettings.ncDelightsHideFishnetTights = nil end
				if type(settings.hideNpcSpikedChokers) == 'boolean' then userSettings.hideNpcSpikedChokers = settings.hideNpcSpikedChokers end
				if type(settings.sortByDisplayName) == 'boolean' then userSettings.sortByDisplayName = settings.sortByDisplayName end
				if type(settings.enablePerformerPreviewSupport) == 'boolean' then userSettings.enablePerformerPreviewSupport = settings.enablePerformerPreviewSupport end
				if type(settings.keepShowingPerformerPreview) == 'boolean' then userSettings.keepShowingPerformerPreview = settings.keepShowingPerformerPreview end

				if type(settings.lastKnownSaveMetadata) == 'table' then userSettings.lastKnownSaveMetadata = settings.lastKnownSaveMetadata end

				if type(settings.playerGenderOnPlayback) == 'number' then userSettings.playerGenderOnPlayback = settings.playerGenderOnPlayback end
				userSettings.playerGenderOnPlayback = mathCeil(userSettings.playerGenderOnPlayback)
				if userSettings.playerGenderOnPlayback < 1 then userSettings.playerGenderOnPlayback = 1 end

				if type(settings.screenScale) == 'number' then userSettings.screenScale = settings.screenScale end
				userSettings.screenScale = mathCeil(userSettings.screenScale)
				if userSettings.screenScale < 1 then userSettings.screenScale = 1 end
				if userSettings.screenScale > 4 then userSettings.screenScale = 4 end

				if type(settings.spycamOrbitPitchWithMouse) == 'boolean' then userSettings.spycamOrbitPitchWithMouse = settings.spycamOrbitPitchWithMouse end
				if type(settings.enableSpycamFreezeFrameToggleMode) == 'boolean' then userSettings.enableSpycamFreezeFrameToggleMode = settings.enableSpycamFreezeFrameToggleMode end
				if type(settings.enableHotscenesButtonInHubMenu) == 'boolean' then userSettings.enableHotscenesButtonInHubMenu = settings.enableHotscenesButtonInHubMenu end
				if type(settings.enableNativeSettingsIntegration) == 'boolean' then userSettings.enableNativeSettingsIntegration = settings.enableNativeSettingsIntegration end

				if type(settings.defaultTimeout) == 'number' and settings.defaultTimeout > sceneProgressDefaultTimeout then
					userSettings.defaultTimeout = settings.defaultTimeout
					lastSceneSetupProgresstTimeout = userSettings.defaultTimeout
				end

				if type(settings.enableHotscenesAddon) == 'boolean' then userSettings.enableHotscenesAddon = settings.enableHotscenesAddon end
				if type(settings.enableSceneAvaliabilityOverride) == 'boolean' then userSettings.enableSceneAvaliabilityOverride = settings.enableSceneAvaliabilityOverride end
				if type(settings.enable_mq055_integration) == 'boolean' then userSettings.enable_mq055_integration = settings.enable_mq055_integration end
				if type(settings.mq055_integration_prefer_vanilla_appearances) == 'boolean' then userSettings.mq055_integration_prefer_vanilla_appearances = settings.mq055_integration_prefer_vanilla_appearances end
				if type(settings.enableNCDelightsFeature) == 'boolean' then userSettings.enableNCDelightsFeature = settings.enableNCDelightsFeature end
				if type(settings.enableNCDelightsDynamicMappins) == 'boolean' then userSettings.enableNCDelightsDynamicMappins = settings.enableNCDelightsDynamicMappins end
				if type(settings.enableNcSceneExtensions) == 'boolean' then userSettings.enableNcSceneExtensions = settings.enableNcSceneExtensions end
				if type(settings.restoreNpcDefaults) == 'boolean' then userSettings.restoreNpcDefaults = settings.restoreNpcDefaults else end
				if type(settings.noGameReloads) == 'boolean' then userSettings.noGameReloads = settings.noGameReloads end
				if type(settings.isPlayerPerformerDiscovered) == 'boolean' then userSettings.isPlayerPerformerDiscovered = settings.isPlayerPerformerDiscovered end
				if type(settings.lastLanguageSelected) == 'string' then userSettings.lastLanguageSelected = settings.lastLanguageSelected else userSettings.lastLanguageSelected = "en-us" end
				if type(settings.invertMouseVertically) == 'boolean' then userSettings.invertMouseVertically = settings.invertMouseVertically end
				if type(settings.isGenderSwitchFeatureEnabled) == 'boolean' then userSettings.isGenderSwitchFeatureEnabled = settings.isGenderSwitchFeatureEnabled end

				local function loadSceneSettings(settingsSource, gender, genderBasedScenes)
					if not settingsSource then return end
					if not genderBasedScenes then return end
					for sceneName, sceneData in pairs(genderBasedScenes) do
						for settingsSceneName, settingsData in pairs(settingsSource) do
							if settingsSceneName == sceneName then
								if not userSettings[gender] then userSettings[gender] = {} end
								if not userSettings[gender][sceneName] then userSettings[gender][sceneName] = {} end
								if type(settingsData.lastSelectedPerformer) == 'string' then
									if settings.isPlayerPerformerDiscovered then
										if settingsData.lastSelectedPerformer == "player_incognito" then settingsData.lastSelectedPerformer = "player" end
									else
										if settingsData.lastSelectedPerformer == "player" then settingsData.lastSelectedPerformer = "player_incognito" end
									end
									for i = 1, #sceneData.performersIndex do
										if sceneData.performersIndex[i] == settingsData.lastSelectedPerformer then
											userSettings[gender][sceneName].lastSelectedPerformer = settingsData.lastSelectedPerformer
											userSettings[gender][sceneName].lastChanged = settingsData.lastChanged
											genderBasedScenes[sceneName].lastSelectedPerformer = settingsData.lastSelectedPerformer
											isAnyPerformerFound = true
										end
									end
								end
								if type(settingsData.lastSelectedCustomLocation) == 'string' then
									userSettings[gender][sceneName].lastSelectedCustomLocation = settingsData.lastSelectedCustomLocation
									userSettings[gender][sceneName].lastChanged = settingsData.lastChanged
									genderBasedScenes[sceneName].lastSelectedCustomLocation = settingsData.lastSelectedCustomLocation
								end
								if type(settingsData.enableFastTrackPlayback) == 'boolean' then
									userSettings[gender][sceneName].enableFastTrackPlayback = settingsData.enableFastTrackPlayback
								else
									userSettings[gender][sceneName].enableFastTrackPlayback = false
								end
							end
						end
					end
				end
				loadSceneSettings(settings.female, 'female', femaleScenes)
				loadSceneSettings(settings.male, 'male', maleScenes)
			else
				result = false
			end
		else
			result = false
		end
	else
		result = false
	end
	if not result then print(modName..': Info: Some settings not found. Missing settings are substituted with default values.') end
end

function isPlayerControllingDevice()
	local isControllingDevice = false
	pcall(function() isControllingDevice = gameBlackBoardSystem:GetLocalInstanced(GetPlayer():GetEntityID(), allBlackboardDefs.PlayerStateMachine):GetBool(allBlackboardDefs.PlayerStateMachine.IsControllingDevice) end)
	if isControllingDevice then return true end
	return false
end

function sendWarningMessage(message, showTime, ignoreCooldown)
	if type(message) ~= 'string' then return end
	if not isStringValid(message) then return end
	if not ignoreCooldown and GetPlayer():IsCooldownActive("mod_hotscenes_warningMessageCooldown") then return end
	if type(showTime) ~= 'number' then showTime = 5 end
	showTime = ClampF(showTime, 1, 10)
	if not ignoreCooldown then GetPlayer():StartCooldown("mod_hotscenes_warningMessageCooldown", showTime, false) end
	PreventionSystem.ShowMessage(message, showTime)
end
nativeUI.sendWarningMessage = sendWarningMessage

function spawnEntity(pathOrID, spawnTransform, appName, tags)
	local id = spawnWithCodeware(pathOrID, spawnTransform, appName, tags);
	if id then return id end;
	return spawnWithCet(pathOrID, spawnTransform, appName, tags);
end;

function spawnWithCodeware(pathOrID, spawnTransform, appName, tags);
	if not Codeware then return end;
	local entitySystem = Game.GetDynamicEntitySystem();
	if not entitySystem then return end;
	if type(pathOrID) ~= 'string' then return end;
	if not isStringValid(pathOrID) then return end;
	local isRecord, isValid = false, false;
	if TweakDB:GetRecord(pathOrID) then isRecord = true isValid = true end;
	if (not isRecord) and stringMatch(pathOrID, '%.ent$') then isValid = true end;
	if not isValid then return end;
	local entSpec = DynamicEntitySpec.new();
	if isRecord then entSpec.recordID = pathOrID else entSpec.templatePath = pathOrID end;
	if type(appName) == 'string' then entSpec.appearanceName = appName end;
	if spawnTransform then;
		entSpec.position = spawnTransform:GetWorldPosition():ToVector4();
		entSpec.orientation = spawnTransform:GetOrientation();
	end;
	entSpec.alwaysSpawned = true;
	entSpec.spawnInView = true;
	entSpec.active = true;
	if type(tags) == 'table' then entSpec.tags = tags end;
	return entitySystem:CreateEntity(entSpec);
end;

function spawnWithCet(pathOrID, spawnTransform, appName);
	if type(pathOrID) ~= 'string' then return end;
	if not isStringValid(pathOrID) then return end;
	local isRecord, isValid = false, false;
	if TweakDB:GetRecord(pathOrID) then isRecord = true isValid = true end;
	if (not isRecord) and stringMatch(pathOrID, '%.ent$') then isValid = true end;
	if not isValid then return end;
	if isRecord then;
		return exEntitySpawner.SpawnRecord(pathOrID, spawnTransform, appName);
	else;
		return exEntitySpawner.Spawn(pathOrID, spawnTransform, appName);
	end;
end;

local windowSettings = {}
local isUsingCustomFontSize = false
local px, vspacing = 1, 1
local initMainWindowOnOverlayOpen = false
local forceUpdateUnknowPerformer = false
local is_no_game_reload_support_available
local is_enable_performer_previewSupport_available
local shouldShowAddOnDeactivationPrompt
local addOnDeactivationPromptTimeout = 0
local isOverlayOpened

registerForEvent("onOverlayOpen",function()
	isOverlayOpened = true
	is_nc_delights_scene_extensions_supported = is_nc_delights_scene_extensions_supported or isKnownName("Hotscenes_overrides_nc_delights_extensions_supported")
	updatePerformers()
	windowSettings.shouldShowMainWindow = true
	windowSettings.shouldShowSettingsView = false
	initMainWindowOnOverlayOpen = true
	is_no_game_reload_support_available = isKnownName("mod_hotscenes_no_game_reload_support_available")
	is_enable_performer_previewSupport_available = nativeUI and nativeUI.isPerformerPreviewSupported and isKnownName("mod_hotscenes_performer_preview_available")
	shouldShowAddOnDeactivationPrompt = false
end)

registerForEvent("onOverlayClose",function ()
	isOverlayOpened = false
	windowSettings.shouldShowMainWindow = false
	if type(nc_delights) ~= 'table' then return end
	if type(nc_delights.scheduleGameNpcRecordsVerification) ~= 'function' then return end
	nc_delights.scheduleGameNpcRecordsVerification(userSettings.restoreNpcDefaults)
end)

local currWindowTime, nextWindowStateUpdate = 0, 0
local reInitMainWindow = false
local oldValue, oldIsNewGameLoad

function updateScenePanelStateFlags()
	isHotscenesAvailableBool = isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride)
	isHotscenesAllowedBool = isHotscenesAllowed()
end

registerForEvent("onDraw", function()
	if not isOverlayOpened then return end
	if (not initMainWindowOnOverlayOpen) and (not isPreGameState) and (oldIsNewGameLoad ~= isNewGameLoad) or (updateCetUi and updateCetUi >= os.clock()) then updatePerformers() updateCetUi = nil end
	oldIsNewGameLoad = isNewGameLoad

	if initMainWindowOnOverlayOpen then initMainWindow() initMainWindowOnOverlayOpen = false end
	if isModDisabled then windowSettings.shouldShowSettingsView = false showMainWindow() return end

	currWindowTime = os.clock()
	if currWindowTime > nextWindowStateUpdate then
		nextWindowStateUpdate = currWindowTime + 0.5
		oldValue = isHotscenesAvailableBool
		isHotscenesAvailableBool = isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride)
		if isHotscenesAvailableBool ~= oldValue then reInitMainWindow = true end
		isHotscenesAllowedBool = isHotscenesAllowed()
		isPlaybackAllowedBool = not isAnyGamePausingScreen()
	end

	if reInitMainWindow and not windowSettings.shouldShowSettingsView then initMainWindow() reInitMainWindow = false end
	showMainWindow()
	forceUpdateUnknowPerformer = false
end)

function roundFloatToInt(val)
	if val >= 0 then return mathFloor(val + 0.5) end
	return mathCeil(val - 0.5)
end

function initMainWindow()
	forceUpdateUnknowPerformer = false
	if shouldKeepUpdatingEp1Performers and isModInitialized then hotscenesLoadAndVerify(true) forceUpdateUnknowPerformer = true end
	windowSettings.scaling = userSettings.screenScale
	if windowSettings.scaling < 1 then windowSettings.scaling = 1 end
	if windowSettings.scaling > 4 then windowSettings.scaling = 4 end

	px = 1
	vspacing = 1

	windowSettings.normalTextHeight = ImGui.GetTextLineHeight()
	local frameHeight = ImGui.GetFrameHeight()
	local frameHeightWithSpacing = ImGui.GetFrameHeightWithSpacing()
	local itemSpacing = frameHeightWithSpacing - frameHeight

	windowSettings.scaling = userSettings.screenScale
	windowSettings.fontScaling = userSettings.screenScale
	windowSettings.buttonHeight = windowSettings.normalTextHeight + 5

	if userSettings.screenScale > 1 then
		if userSettings.screenScale == 2 then
			px = 2
			vspacing = 2
			windowSettings.buttonHeight = windowSettings.buttonHeight - 2
		elseif userSettings.screenScale == 3 then
			px = 3
			vspacing = 3
			windowSettings.buttonHeight = windowSettings.buttonHeight - 3
		elseif userSettings.screenScale == 4 then
			px = 4
			vspacing = 4
			windowSettings.buttonHeight = windowSettings.buttonHeight - 3.5
		end
	else
		windowSettings.buttonHeight = windowSettings.buttonHeight + 1
	end

	windowSettings.windowFlags = ImGuiWindowFlags.AlwaysAutoResize

	local x, y = ImGui.CalcTextSize('abcdefghijklmnoprstuwxyz /_.,ABCDEFGHIJKLMNOPRSTUWXYZ')
	windowSettings.windowWidth = roundFloatToInt(x * 1.36)
	windowSettings.windowHeight = frameHeight

	windowSettings.col1Width = roundFloatToInt(windowSettings.windowWidth * 0.35)
	windowSettings.col2Width = windowSettings.windowWidth - windowSettings.col1Width
	windowSettings.comboBoxWidth = roundFloatToInt(2 * windowSettings.col2Width / 3)
	windowSettings.comboBoxHalfWidth = roundFloatToInt(windowSettings.comboBoxWidth * 0.5)

	local padding, y2 = ImGui.GetWindowContentRegionMin()
	windowSettings.settingsConfirmButtonWidth = roundFloatToInt(windowSettings.windowWidth * 0.35)
	windowSettings.settingsCancelButtonWidth = roundFloatToInt(windowSettings.windowWidth * 0.35)
	windowSettings.settingsButtonsInnerMargin = 10
	windowSettings.settingsButtonsLeftMargin = windowSettings.windowWidth - 6 * padding - windowSettings.settingsButtonsInnerMargin - windowSettings.settingsConfirmButtonWidth - windowSettings.settingsCancelButtonWidth
	windowSettings.settingsButtonsLeftMargin = windowSettings.settingsButtonsLeftMargin * 0.5

	local femalePanels = 0
	local malePanels = 0
	if (femaleScenesCount > 0) and (femalePerformersCount > 0) then
		for _, sceneData in pairs(femaleScenes) do if (sceneData.isAvailable or sceneData.isAvailableOnlyInOverrideMode) then femalePanels = femalePanels + 1 end end
	end
	if (maleScenesCount > 0) and (malePerformersCount > 0) then
		for _, sceneData in pairs(maleScenes) do if (sceneData.isAvailable or sceneData.isAvailableOnlyInOverrideMode) then malePanels = malePanels + 1 end end
	end

	local totalPanels = femalePanels + malePanels

	windowSettings.femalePanels = femalePanels
	windowSettings.malePanels = malePanels
	windowSettings.totalPanels = totalPanels

	windowSettings.windowWidth = roundFloatToInt(windowSettings.windowWidth * px)
	windowSettings.col1Width = roundFloatToInt(windowSettings.col1Width * px)
	windowSettings.col2Width = roundFloatToInt(windowSettings.col2Width * px)
	windowSettings.comboBoxWidth = roundFloatToInt(windowSettings.comboBoxWidth * px)
	windowSettings.buttonHeight = roundFloatToInt(windowSettings.buttonHeight * px)

	windowSettings.settingsConfirmButtonWidth = roundFloatToInt(windowSettings.settingsConfirmButtonWidth * px)
	windowSettings.settingsCancelButtonWidth = roundFloatToInt(windowSettings.settingsCancelButtonWidth * px)
	windowSettings.settingsButtonsLeftMargin = roundFloatToInt(windowSettings.settingsButtonsLeftMargin * px)
end

local footer = modName..' '..modVer
function showMainWindow()
	if not windowSettings.shouldShowMainWindow then return end
	local stateChanged, isClicked, screenScale

	ImGui.SetNextWindowPos(50, 50, ImGuiCond.FirstUseEver)
	if windowSettings.shouldShowSettingsView then
		if ImGui.Begin(uiStrings.cetUiStrings.cetWindowName, true, windowSettings.windowFlags) then
			if ImGui.IsWindowCollapsed() then ImGui.End() return end
			pcall(function()
				ImGui.SetWindowFontScale(windowSettings.fontScaling)
				ImGui.Separator()
				ImGui.Text(uiStrings.cetUiStrings.cetWindowSettingsView.headerLeft)
				showSettingsToggleButton()
				ImGui.Separator()
				for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end

				userSettings.extendHotscenes, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.extendHotscenes.title, userSettings.extendHotscenes)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.extendHotscenes.tooltips)
				end
				if stateChanged then
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('extendHotscenes', userSettings.extendHotscenes, true) end
				end

				userSettings.sortByDisplayName, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.sortByDisplayName.title, userSettings.sortByDisplayName)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.sortByDisplayName.tooltips)
				end
				if stateChanged then
					forceUpdateScenePerformersByPanelLogic()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('sortByDisplayName', userSettings.sortByDisplayName) end
				end

				userSettings.hideNpcSpecs, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcSpecs.title, userSettings.hideNpcSpecs)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcSpecs.tooltips)
				end
				if stateChanged then
					nc_delights.updateSettings()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('hideNpcSpecs', userSettings.hideNpcSpecs) end
				end

				userSettings.hideNpcFishnetTights, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcFishnetTights.title, userSettings.hideNpcFishnetTights)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcFishnetTights.tooltips)
				end
				if stateChanged then
					nc_delights.updateSettings()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('hideNpcFishnetTights', userSettings.hideNpcFishnetTights) end
				end

				userSettings.hideNpcSpikedChokers, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcSpikedChokers.title, userSettings.hideNpcSpikedChokers)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.hideNpcSpikedChokers.tooltips)
				end
				if stateChanged then
					nc_delights.updateSettings()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('hideNpcSpikedChokers', userSettings.hideNpcSpikedChokers) end
				end

				if nativeUI.isActive then
					userSettings.enableHotscenesButtonInHubMenu, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableHotscenesButtonInHubMenu.title, userSettings.enableHotscenesButtonInHubMenu)
					if ImGui.IsItemHovered() then
						ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableHotscenesButtonInHubMenu.tooltips)
					end
					if stateChanged then
						saveUserSettings()
						if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableHotscenesButtonInHubMenu', userSettings.enableHotscenesButtonInHubMenu, true) end
					end
				end

				if nativeUI.isActive and nativeUI.nativeSettings then
					userSettings.enableNativeSettingsIntegration, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableNativeSettingsIntegration.title, userSettings.enableNativeSettingsIntegration)
					if ImGui.IsItemHovered() then
						ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableNativeSettingsIntegration.tooltips)
					end
					if stateChanged then
						if spycam then spycam.drone.enableNativeSettingsIntegration = userSettings.enableNativeSettingsIntegration or isDebug end
						saveUserSettings()
						if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableNativeSettingsIntegration', userSettings.enableNativeSettingsIntegration, true) end
					end
				end

				if userSettings.isGenderSwitchFeatureEnabled then
					if ImGui.TreeNodeEx("##_spoiler", ImGuiTreeNodeFlags.NoTreePushOnOpen) then
						ImGui.Text(uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackCombo.title)
						ImGui.SetNextItemWidth(roundFloatToInt(windowSettings.comboBoxWidth))
						if type(userSettings.playerGenderOnPlayback) ~= 'number' or userSettings.playerGenderOnPlayback < 1 then userSettings.playerGenderOnPlayback = 1 end
						if userSettings.playerGenderOnPlayback > #uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackSelectionList then userSettings.playerGenderOnPlayback = #uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackSelectionList end
						local tableIndex = userSettings.playerGenderOnPlayback - 1
						tableIndex, isClicked = ImGui.Combo('##Player gender behavior', tableIndex, uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackSelectionList, #uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackSelectionList)
						if ImGui.IsItemHovered() then
							ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackCombo.tooltips)
						end
						if isClicked then
							userSettings.playerGenderOnPlayback = tableIndex + 1
							saveUserSettings()
						end
						ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.playerGenderOnPlaybackWarning.title)
					end
				end

				for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
				ImGui.Separator()

				for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
				userSettings.spycamOrbitPitchWithMouse, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.spycamOrbitPitchWithMouse.title, userSettings.spycamOrbitPitchWithMouse)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.spycamOrbitPitchWithMouse.tooltips)
				end
				if stateChanged then
					updateSpycamParameters()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('spycamOrbitPitchWithMouse', userSettings.spycamOrbitPitchWithMouse, true) end
				end

				userSettings.enableSpycamFreezeFrameToggleMode, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableSpycamFreezeFrameToggleMode.title, userSettings.enableSpycamFreezeFrameToggleMode)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableSpycamFreezeFrameToggleMode.tooltips)
				end
				if stateChanged then
					updateSpycamParameters()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableSpycamFreezeFrameToggleMode', userSettings.enableSpycamFreezeFrameToggleMode, true) end
				end

				userSettings.invertMouseVertically, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.invertMouseVertically.title, userSettings.invertMouseVertically)
				if ImGui.IsItemHovered() then
					ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.invertMouseVertically.tooltips)
				end
				if stateChanged then
					if spycam then spycam.input.invertMouseVertically = userSettings.invertMouseVertically end
					updateSpycamParameters()
					saveUserSettings()
					if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('invertMouseVertically', userSettings.invertMouseVertically, true) end
				end

				for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end

				if isOverridesArchiveDetected then
					ImGui.Separator()
					for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
					userSettings.enableHotscenesAddon, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableHotscenesAddon.title, userSettings.enableHotscenesAddon)
					if ImGui.IsItemHovered() then
						ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableHotscenesAddon.tooltips)
					end
					if stateChanged then
						if not userSettings.enableHotscenesAddon then
							if mq055_hangouts_interaction then
								mq055_hangouts_interaction.disableCustomChoices(true)
								mq055_hangouts_interaction.clearAndLockInteractions(0.01)
							end
						else
							verifyCustomSceneLocationData(true)
						end

						forceUpdateScenePerformersByPanelLogic()
						if nc_delights then nc_delights.updateSettings() end
						saveUserSettings()
						if nc_delights then nc_delights.shouldAllowActivity(true) end
						if nativeUI.isActive then
							if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableHotscenesAddon', userSettings.enableHotscenesAddon) end
							isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride)
							nativeUI.updateUI(true)
						end
					end
					local currTime = os.clock()
					if not isArchiveXLActive then
						for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
						ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.archiveXLNotActive.title)
						if ImGui.IsItemHovered() then ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.archiveXLNotActive.tooltips) end
						for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
					else
						if (not isPreGameState) and (not isGameLoading) and currTime > gameLoadDeactivationTimeout and isInGameSession() then
							for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
							if shouldShowAddOnDeactivationPrompt and addOnDeactivationPromptTimeout > currTime then
								ImGui.Dummy(windowSettings.settingsButtonsLeftMargin, 0)
								ImGui.SameLine()
								local buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.deactivationPrompt
								ImGui.TextWrapped(buttonText.title)
								if buttonText.tooltips and ImGui.IsItemHovered() then ImGui.SetTooltip(buttonText.tooltips) end
								for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
								ImGui.Dummy(windowSettings.settingsButtonsLeftMargin, 0)
								ImGui.SameLine()
								buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.confirmDeactivation
								if ImGui.Button(buttonText.title..'##addOnActivationButton', windowSettings.settingsConfirmButtonWidth, windowSettings.buttonHeight) then
									shouldShowAddOnDeactivationPrompt = false
									deactivateAddon()
								end
								if buttonText.tooltips and ImGui.IsItemHovered() then ImGui.SetTooltip(buttonText.tooltips) end
								ImGui.SameLine()
								ImGui.Dummy(windowSettings.settingsButtonsInnerMargin, 0)
								ImGui.SameLine()
								buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.cancelDeactivation
								if ImGui.Button(buttonText.title..'##addOnActivationButton',  windowSettings.settingsCancelButtonWidth, windowSettings.buttonHeight) then
									shouldShowAddOnDeactivationPrompt = false
								end
								if buttonText.tooltips and ImGui.IsItemHovered() then ImGui.SetTooltip(buttonText.tooltips) end
								for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
							else
								shouldShowAddOnDeactivationPrompt = false
								local buttonText
								local isAddonActivated = isCustomTriggerQuestActive()
								if isQuestTriggerDeactivating then
									if isGamePaused() then
										buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.isDeactivatingWhileGamePaused
									else
										buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.isDeactivating
									end
								elseif isAddonActivated then
									buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.isActive
								else
									buttonText = uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.isInactive
								end
								local popColors
								local isInactive = sceneState and sceneState.sceneTier and sceneState.sceneTier >= 3
								if isInactive then
									ImGui.BeginDisabled()
								else
									if (not isAddonActivated) or isQuestTriggerDeactivating then
										ImGui.PushStyleColor(ImGuiCol['Button'], 0.5, 0.5, 0.5, 0.25)
										ImGui.PushStyleColor(ImGuiCol['ButtonActive'], 0.5, 0.5, 0.5, 0.25)
										ImGui.PushStyleColor(ImGuiCol['ButtonHovered'], 0.5, 0.5, 0.5, 0.25)
										ImGui.PushStyleColor(ImGuiCol['Text'], 0.9, 0.9, 0.9, 1)
										popColors = 4
									end
								end
								if ImGui.Button(buttonText.title..'##addOnActivationButton', -1, windowSettings.buttonHeight) then
									if isAddonActivated and (not isQuestTriggerDeactivating) then shouldShowAddOnDeactivationPrompt = true addOnDeactivationPromptTimeout = os.clock() + 30 end
								end
								if isInactive then
									ImGui.EndDisabled()
								else
									if popColors then ImGui.PopStyleColor(popColors) end
									if buttonText.tooltips and ImGui.IsItemHovered() then ImGui.SetTooltip(buttonText.tooltips) end
								end
							end
						else
							for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.statusUnavailable.title)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.addOnActivationButton.statusUnavailable.tooltips)
							end
							for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
						end
					end
					if userSettings.enableHotscenesAddon then
						if isOverridesArchiveSupportingSceneAvailabilityOverride then
							for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
							userSettings.enableSceneAvaliabilityOverride, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableSceneAvaliabilityOverride.title, userSettings.enableSceneAvaliabilityOverride)
							if ImGui.IsItemHovered() then ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableSceneAvaliabilityOverride.tooltips) end
							if stateChanged then
								if userSettings.enableSceneAvaliabilityOverride then verifyCustomSceneLocationData(true) end
								saveUserSettings()
								if nativeUI.isActive then
									isHotscenesAvailable(sceneAvailabilityOverride, isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.enableSceneAvaliabilityOverride)
									nativeUI.updateUI(true)
									if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableSceneAvaliabilityOverride', userSettings.enableSceneAvaliabilityOverride, true) end
								end
								updateCetUi = os.clock() + 0.1
							end
						else
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnSceneOverrideNotSupported)
							if not uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth then
								uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth = ImGui.CalcTextSize('   '..uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink..'   ')
							end
							ImGui.SetNextItemWidth(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth)
							ImGui.InputText('##add-on_mod_link', uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink, 50, ImGuiInputTextFlags.ReadOnly)
						end

						if isArchiveXLActive and isOverridesArchiveDetected and is_enable_performer_previewSupport_available then
							userSettings.enablePerformerPreviewSupport, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enablePerformerPreviewSupport.title, userSettings.enablePerformerPreviewSupport)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enablePerformerPreviewSupport.tooltips)
							end
							if stateChanged then
								nc_delights.updateSettings()
								saveUserSettings()
								if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enablePerformerPreviewSupport', userSettings.enablePerformerPreviewSupport) end
							end
						end

						if isArchiveXLActive and isOverridesArchiveDetected and is_no_game_reload_support_available then
							userSettings.noGameReloads, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.noGameReloads.title, userSettings.noGameReloads)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.noGameReloads.tooltips)
							end
							if stateChanged then
								nc_delights.updateSettings()
								saveUserSettings()
								if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('noGameReloads', userSettings.noGameReloads) end
							end
						end

						if is_mq055_hangouts_interaction_activated() then
							userSettings.enable_mq055_integration, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enable_mq055_integration.title, userSettings.enable_mq055_integration)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enable_mq055_integration.tooltips)
							end
							if stateChanged then
								if not userSettings.enable_mq055_integration then
									mq055_hangouts_interaction.disableCustomChoices(true)
									mq055_hangouts_interaction.clearAndLockInteractions(0.01)
								else
									verifyCustomSceneLocationData(true)
								end
								saveUserSettings()
								if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enable_mq055_integration', userSettings.enable_mq055_integration) end
							end
							if userSettings.enable_mq055_integration then
								userSettings.mq055_integration_prefer_vanilla_appearances, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.mq055_integration_prefer_vanilla_appearances.title, userSettings.mq055_integration_prefer_vanilla_appearances)
								if ImGui.IsItemHovered() then
									ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.mq055_integration_prefer_vanilla_appearances.tooltips)
								end
								if stateChanged then
									saveUserSettings()
									if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('mq055_integration_prefer_vanilla_appearances', userSettings.mq055_integration_prefer_vanilla_appearances, true) end
								end
							end
						end
						if nc_delights and isArchiveXLActive and nc_delights.isModSupported() then
							for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
							userSettings.enableNCDelightsFeature, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableNCDelightsFeature.title, userSettings.enableNCDelightsFeature)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableNCDelightsFeature.tooltips)
							end
							if stateChanged then
								nc_delights.updateSettings()
								saveUserSettings()
								if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableNCDelightsFeature', userSettings.enableNCDelightsFeature) end
							end
							local isOptionDisabled = not userSettings.enableNCDelightsFeature
							if isOptionDisabled then ImGui.BeginDisabled() end
							pcall(function()
								userSettings.enableNCDelightsDynamicMappins, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableNCDelightsDynamicMappins.title, userSettings.enableNCDelightsDynamicMappins)
								if ImGui.IsItemHovered() then
									ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableNCDelightsDynamicMappins.tooltips)
								end
								if stateChanged then
									nc_delights.updateSettings()
									saveUserSettings()
									if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableNCDelightsDynamicMappins', userSettings.enableNCDelightsDynamicMappins) end
								end

								if is_nc_delights_scene_extensions_supported then
									userSettings.enableNcSceneExtensions, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.enableNcSceneExtensions.title, userSettings.enableNcSceneExtensions)
									if ImGui.IsItemHovered() then
										ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.enableNcSceneExtensions.tooltips)
									end
									if stateChanged then
										nc_delights.updateSettings()
										saveUserSettings()
										if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('enableNcSceneExtensions', userSettings.enableNcSceneExtensions) end
									end
								end

								if type(nc_delights.scheduleGameNpcRecordsVerification) == 'function' then
									userSettings.restoreNpcDefaults, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetWindowSettingsView.restoreNpcDefaults.title, userSettings.restoreNpcDefaults)
									if ImGui.IsItemHovered() then
										ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.restoreNpcDefaults.tooltips)
									end
									if stateChanged then
										nc_delights.updateSettings()
										saveUserSettings()
										if nativeUI.updateNativeSettingsOption then nativeUI.updateNativeSettingsOption('restoreNpcDefaults', userSettings.restoreNpcDefaults) end
										nc_delights.scheduleGameNpcRecordsVerification(userSettings.restoreNpcDefaults)
									end
								end
							end)
							if isOptionDisabled then ImGui.EndDisabled() end
						end
					end
					for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
				elseif isGameV21 then
					if isUnsupportedOverridesArchiveDetected then
						ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesUnsupportedAddOnDetected)
					else
						ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnNotDetected)
					end

					if not uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth then
						uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth = ImGui.CalcTextSize('   '..uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink..'   ')
					end
					ImGui.SetNextItemWidth(uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLinkWidth)
					ImGui.InputText('##add-on_mod_link', uiStrings.cetUiStrings.cetWindowSettingsView.hotscenesAddOnWebsiteLink, 50, ImGuiInputTextFlags.ReadOnly)

					for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
				end

				if gameVer >= 1.6 then
					ImGui.Separator()
					for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
					ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementDisabled)
					if not uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementWebsiteLinkWidth then
						uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementWebsiteLinkWidth = ImGui.CalcTextSize('   '..uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementWebsiteLink..'   ')
					end
					ImGui.SetNextItemWidth(uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementWebsiteLinkWidth)
					ImGui.InputText('##underwear_mod_link', uiStrings.cetUiStrings.cetWindowSettingsView.underwearManagementWebsiteLink, 50, ImGuiInputTextFlags.ReadOnly)
				end

				if not isUsingCustomFontSize then
					for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
					ImGui.Separator()
					ImGui.Text(uiStrings.cetUiStrings.cetWindowSettingsView.screenScale.title)
					ImGui.SetNextItemWidth(roundFloatToInt(windowSettings.comboBoxHalfWidth * px))
					screenScale, isClicked = ImGui.Combo('##UI scaling', userSettings.screenScale -1, {'1', '2', '3', '4'}, 4)
					if ImGui.IsItemHovered() then
						ImGui.SetTooltip(uiStrings.cetUiStrings.cetWindowSettingsView.screenScale.tooltips)
					end
					if isClicked then
						screenScale = screenScale + 1
						if screenScale < 1 then screenScale = 1 end
						if screenScale > 4 then screenScale = 4 end

						if screenScale ~= userSettings.screenScale then
							userSettings.screenScale = screenScale
							saveUserSettings()
							ImGui.SetWindowFontScale(1)
							initMainWindow()
						end
					end
				end

				for i = 1, vspacing do ImGui.Spacing() ImGui.Spacing() end
				ImGui.Separator()
				ImGui.Text(footer)

				ImGui.SetWindowFontScale(1)
			end)
			ImGui.End()
		end
	else
		if ImGui.Begin(uiStrings.cetUiStrings.cetWindowName, true, windowSettings.windowFlags) then
			pcall(function()
				ImGui.SetWindowFontScale(windowSettings.fontScaling)
				if Ref and isHotscenesDataLoaded and (not isModDisabled) then
					if isHotscenesAvailableBool and GetPlayer() then
						if totalPerformersCount > 0 then
							ImGui.Separator()
							if isOverridesArchiveDetected and userSettings.enableHotscenesAddon then
								ImGui.Text(uiStrings.cetUiStrings.cetWindowMainView.headerLeftAddOnEnabled)
							else
								ImGui.Text(uiStrings.cetUiStrings.cetWindowMainView.headerLeft)
							end
							showSettingsToggleButton()
							ImGui.Separator()
							ImGui.Columns(2)
							ImGui.SetColumnWidth(0, windowSettings.col1Width)
							ImGui.SetColumnWidth(1, windowSettings.col2Width)

							ImGui.Text(uiStrings.cetUiStrings.cetWindowMainView.panelListHeaderLeft) ImGui.NextColumn()
							ImGui.Text(uiStrings.cetUiStrings.cetWindowMainView.panelListHeaderRight) ImGui.NextColumn()

							ImGui.Separator()
							if ImGui.IsWindowCollapsed() then ImGui.End() return end

							if #femaleScenesIndex > 0 and femalePerformersCount > 0 then createScenesPanelForGender('female', windowSettings.comboBoxWidth, windowSettings.malePanels < 1) end
							if #maleScenesIndex > 0 and malePerformersCount > 0 then createScenesPanelForGender('male', windowSettings.comboBoxWidth, true) end
						else
							ImGui.Separator()
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowMainView.headerScenesNotAvailable)
							showSettingsToggleButton()
							ImGui.Separator()
						end
					else
							ImGui.Separator()
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowMainView.headerScenesNotAvailable)
							showSettingsToggleButton()
							ImGui.Separator()
							if (not isPreGameState) and (not isInGameSession()) then ImGui.TextWrapped(uiStrings.cetUiStrings.cetWindowMainView.gameIsLoading) end
					end
				else
					ImGui.Separator()
					if isModDisabled then
						if not isSupportedCet then
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(stringGsub(uiStrings.cetUiStrings.cetWarnings.unsupportedCetVersion, "##CET_VER##", cetVer))
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						elseif not autoSaveSystem then
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWarnings.autosaveSystemDamaged)
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						else
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWarnings.mandatoryArchiveFileMissing)
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						end
					else
						if not Ref then
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWarnings.mandatoryRefFileMissing)
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						elseif gvs then
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWarnings.scenesFileMissingOrCorruptedOrOutdated)
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						else
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
							ImGui.TextWrapped(uiStrings.cetUiStrings.cetWarnings.unsupportedGameVersion)
							ImGui.Text(uiStrings.cetUiStrings.cetWarnings.filler)
						end
					end
					ImGui.Separator()
					ImGui.Text(footer)
				end
				ImGui.SetWindowFontScale(1)
			end)
			ImGui.End()
		end
	end
end

local title, titleOffset, settingsButtonSize, settingsButtonOffset = '', 0, 13, 5

function showSettingsToggleButton()
	settingsButtonSize = ImGui.GetTextLineHeight()
	settingsButtonOffset = roundFloatToInt(2.2 * settingsButtonSize)

	if windowSettings.shouldShowSettingsView then
		title = uiStrings.cetUiStrings.cetWindowSettingsView.headerRight
		titleOffset = roundFloatToInt(ImGui.CalcTextSize(title) + settingsButtonSize / 2)
	else
		title = uiStrings.cetUiStrings.cetWindowMainView.headerRight
		titleOffset = roundFloatToInt(ImGui.CalcTextSize(title) + settingsButtonSize / 2)
	end
	ImGui.SameLine(windowSettings.windowWidth - (titleOffset + settingsButtonOffset))
	ImGui.Text(title)

	newMenuButtonlabel = '##SettingsButton'
	ImGui.SameLine(windowSettings.windowWidth - settingsButtonOffset)
	settingsButtonSize = settingsButtonSize
	if ImGui.Button(newMenuButtonlabel, settingsButtonSize, settingsButtonSize) then
		windowSettings.shouldShowSettingsView = not windowSettings.shouldShowSettingsView
		if not windowSettings.shouldShowSettingsView then shouldShowAddOnDeactivationPrompt = false end
	end
end

function getOppositeGender(gender)
	if gender == 'female' then return 'male' end
	if gender == 'male' then return 'female' end
	return 'unknown'
end
function getOppositeGenderScene(sceneName, gender)
	if gender == 'female' then return maleScenes[sceneName] end
	if gender == 'male' then return femaleScenes[sceneName] end
end

function getScenePanelMode(scenes, sceneName, gender)
	if not isOverridesArchiveDetected then return sceneModeIsInteractive end
	if not userSettings.enableHotscenesAddon then return sceneModeIsInteractive end

	if scenes[sceneName].isAvailableOnlyInOverrideMode then
		if userSettings.enableSceneAvaliabilityOverride then return sceneModeIsOverride end
		return sceneModeIsInteractive
	end

	local sceneData = scenes[sceneName]
	if type(sceneData.prerequisiteFacts) == 'table' and #sceneData.prerequisiteFacts > 0 then
		for i = 1, #sceneData.prerequisiteFacts do
			if type(sceneData.prerequisiteFacts[i]) == 'string' and questsSystem:GetFactStr(sceneData.prerequisiteFacts[i]) > 0 then return sceneModeIsFastPlayback end
		end
	else
		if isScenePerfomerMet(gender, sceneName) then return sceneModeIsFastPlayback end
		if isScenePerfomerMet(getOppositeGender(gender), sceneName) then return sceneModeIsFastPlayback end
	end
						
	if userSettings.enableSceneAvaliabilityOverride and isSceneAvailableInOverrideMode(gender, sceneName) then return sceneModeIsOverride end
	return sceneModeIsInteractive
end

local itemIndex = nil
local customLocationItemIndex = nil
function getPanelLogic(scenes, sceneName, gender, action, panelState, updateUnknowPerformer)
	if not panelState then
		panelState = {}
		panelState.isActive 				= false
		panelState.performersListState		= {itemIndex = false,		isActive = false}
		panelState.customLocationsList		= nil
		panelState.scenePlaybackMode		= scenePlaybackMode.interactive
		panelState.sceneTargetLocation		= 'default'
		panelState.customLocationsListState	= {itemIndex = false,		isActive = false}
		panelState.resetButtonState			= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.resetButton.inactiveButtonLabel,	isActive = false}
		panelState.playbackButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cueButton.inactiveButtonLabel,	isActive = false}
		panelState.playbackUnarmButtonState	= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cancelButton.inactiveButtonLabel,	isActive = false}
		panelState.reloadButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.reloadButton.inactiveButtonLabel,	isActive = false}
	end

	panelState.sceneMode = sceneModeIsInteractive
	panelState.isAvailableOnlyInOverrideMode = false
	panelState.isOutsideSceneActiveArea = true

	panelState.sceneMode = getScenePanelMode(scenes, sceneName, gender)
	local thisScene = scenes[sceneName]
	if type(thisScene.isAvailableOnlyInOverrideMode) == 'boolean' then panelState.isAvailableOnlyInOverrideMode = thisScene.isAvailableOnlyInOverrideMode end
	if panelState.isAvailableOnlyInOverrideMode then
		if isPreGameState and (not isInSession()) then
			panelState.isOutsideSceneActiveArea = true
		else
			panelState.isOutsideSceneActiveArea = isOutsideSceneActiveArea(gender, sceneName)
		end
	end

	panelState.customLocationsList = nil
	panelState.customLocationsListNativeUi = nil
	local validCustomLocations = nil
	local validCustomLocationsIndex = nil
	local validCustomLocationsDescriptions = nil
	local isAnyCustomLocationIncluded = nil
	if isOverridesArchiveDetected and userSettings.enableHotscenesAddon then
		validCustomLocations, validCustomLocationsIndex, validCustomLocationsDescriptions, isAnyCustomLocationIncluded = getCustomLocationsListsForScene(gender, sceneName)
		if validCustomLocations and isAnyCustomLocationIncluded then
			panelState.customLocationsList = validCustomLocationsDescriptions.cetUi
			panelState.customLocationsListNativeUi = validCustomLocationsDescriptions.nativeUi or validCustomLocationsDescriptions.cetUi
		end
	end

	if action == 'none' then
		itemIndex = nil
		local lastSelectedPerformer = thisScene.lastSelectedPerformer
		local lastUnknownSelectedPerformer = thisScene.lastUnknownSelectedPerformer
		if (forceUpdateUnknowPerformer or updateUnknowPerformer) and isStringValid(lastUnknownSelectedPerformer) then
			if lastUnknownSelectedPerformer == "player" or lastUnknownSelectedPerformer == "player_incognito" then
				for p = 1, #thisScene.performersIndex do
					if stringMatch(thisScene.performersIndex[p], "^player") then
						scenes[sceneName].lastSelectedPerformer = thisScene.performersIndex[p]
						itemIndex = p -1
						break
					end
				end
			else
				for p = 1, #thisScene.performersIndex do
					if lastUnknownSelectedPerformer == thisScene.performersIndex[p] then
						scenes[sceneName].lastSelectedPerformer = lastUnknownSelectedPerformer
						itemIndex = p -1
						break
					end
				end
			end
		end
		if not itemIndex and lastSelectedPerformer then
			if lastSelectedPerformer == "player" or lastSelectedPerformer == "player_incognito" then
				for p = 1, #thisScene.performersIndex do
					local performer = thisScene.performersIndex[p]
					if stringMatch(performer, "^player") then
						if performer ~= lastSelectedPerformer then
							lastSelectedPerformer = performer
							scenes[sceneName].lastSelectedPerformer = performer
						end
						itemIndex = p -1
						break
					end
				end
			else
				for p = 1, #thisScene.performersIndex do
					if lastSelectedPerformer == thisScene.performersIndex[p] then itemIndex = p -1 break end
				end
			end
		end
		if not itemIndex then
			if isStringValid(lastSelectedPerformer) then scenes[sceneName].lastUnknownSelectedPerformer = lastSelectedPerformer end
			for p = 1, #thisScene.performersIndex do
				if sceneName == thisScene.performersIndex[p] then
					itemIndex = p - 1
					scenes[sceneName].lastSelectedPerformer = thisScene.performersIndex[p]
					break
				end
			end
		end

		if panelState.customLocationsList then
			customLocationItemIndex = nil
			if thisScene.lastSelectedCustomLocation then
				for p = 1, #validCustomLocationsIndex do
					if thisScene.lastSelectedCustomLocation == validCustomLocationsIndex[p] then customLocationItemIndex = p -1 break end
				end
			end
			if not customLocationItemIndex then
				if isStringValid(thisScene.lastSelectedCustomLocation) then scenes[sceneName].lastUnknownSelectedCustomLocation = thisScene.lastSelectedCustomLocation end
				for p = 1, #validCustomLocationsIndex do
					if validCustomLocationsIndex[p] == 'default' then
						customLocationItemIndex = p - 1
						scenes[sceneName].lastSelectedCustomLocation = validCustomLocationsIndex[p]
						break
					end
				end
			end
		end

		if not thisScene.scenePlaybackProgress then scenes[sceneName].scenePlaybackProgress = playback.idle end
		if itemIndex then panelState.isActive = true else itemIndex = false panelState.isActive = false end
		if panelState.isActive then panelState.isActive = isHotscenesAllowedBool end

		if panelState.isActive then
			if type(thisScene.isAvailable) == 'boolean' then panelState.isActive = thisScene.isAvailable end
			if not panelState.isActive and type(thisScene.isAvailableOnlyInOverrideMode) == 'boolean' then panelState.isActive = thisScene.isAvailableOnlyInOverrideMode and isOutsideSceneActiveArea(gender, sceneName) end
		end

		if panelState.isActive then
			panelState.performersListState		= {itemIndex = itemIndex,	isActive = true}
			panelState.customLocationsListState	= {customLocationItemIndex = customLocationItemIndex,	isActive = true}
			panelState.resetButtonState			= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.resetButton.activeButtonLabel,	isActive = true}
			panelState.playbackButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cueButton.activeButtonLabel,	isActive = true}
			panelState.playbackUnarmButtonState	= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cancelButton.activeButtonLabel,	isActive = false}
			panelState.reloadButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.reloadButton.activeButtonLabel,	isActive = true}
		else
			panelState.performersListState		= {itemIndex = itemIndex,	isActive = true}
			panelState.customLocationsListState	= {customLocationItemIndex = customLocationItemIndex,	isActive = true}
			panelState.resetButtonState			= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.resetButton.inactiveButtonLabel,	isActive = false}
			panelState.playbackButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cueButton.unavailableButtonLabel,	isActive = false}
			panelState.playbackUnarmButtonState	= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.cancelButton.inactiveButtonLabel,	isActive = false}
			panelState.reloadButtonState		= {buttonLabel = uiStrings.cetUiStrings.cetScenePanel.reloadButton.inactiveButtonLabel,	isActive = false}
		end
	elseif action == 'performer changed' then
		itemIndex = panelState.performersListState.itemIndex + 1
		scenes[sceneName].lastUnknownSelectedPerformer = nil
		scenes[sceneName].lastSelectedPerformer = thisScene.performersIndex[itemIndex]
		scenes[sceneName].scenePlaybackProgress = playback.idle
		saveUserSettings()
	elseif action == 'custom location changed' then
		if validCustomLocations then
			customLocationItemIndex = panelState.customLocationsListState.customLocationItemIndex + 1
			scenes[sceneName].lastUnknownSelectedCustomLocation = nil
			scenes[sceneName].lastSelectedCustomLocation = validCustomLocationsIndex[customLocationItemIndex]
			scenes[sceneName].scenePlaybackProgress = playback.idle
			saveUserSettings()
		end
	elseif action == 'reset button clicked' then
		scenes[sceneName].lastUnknownSelectedPerformer = nil
		scenes[sceneName].lastSelectedPerformer = nil
		for p = 1, #thisScene.performersIndex do
			if sceneName == thisScene.performersIndex[p] then
				scenes[sceneName].lastSelectedPerformer = thisScene.performersIndex[p]
				restoreOriginalScenePerformer(sceneName, gender)
			end
		end
		scenes[sceneName].scenePlaybackMode 	= scenePlaybackMode.interactive
		scenes[sceneName].sceneTargetLocation	= 'default'
		if panelState.customLocationsList then scenes[sceneName].lastSelectedCustomLocation = 'default' end
		scenes[sceneName].scenePlaybackProgress = playback.idle
		restorePlayerGenderRecords()
		saveUserSettings()
	elseif action == 'playback button clicked' then
		scenes[sceneName].lastUnknownSelectedPerformer = nil
		if thisScene.scenePlaybackProgress == playback.idle then
			setPerformerToScene(thisScene.lastSelectedPerformer, sceneName, gender)
			scenes[sceneName].scenePlaybackProgress = playback.cued
		elseif thisScene.scenePlaybackProgress == playback.cued then
			scenes[sceneName].scenePlaybackProgress	= playback.playPending
			scenes[sceneName].scenePlaybackMode 	= panelState.scenePlaybackMode
			scenes[sceneName].sceneTargetLocation	= panelState.sceneTargetLocation
			restorePlayerGenderRecords()
			playScene(sceneName, gender)
		elseif thisScene.scenePlaybackProgress == playback.playing then
			reloadGameAndClearPlaybackStates()
		end
	elseif action == 'cancel button clicked' then
		thisScene.scenePlaybackProgress = playback.idle
		restorePlayerGenderRecords()
	elseif action == 'reload button clicked' then
		saveUserSettings()
		restorePlayerGenderRecords()
	end

	if panelState.isActive then
		panelState.playbackButtonState.isActive = true
		if thisScene.scenePlaybackProgress == playback.idle then
			panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.cueScene
		elseif thisScene.scenePlaybackProgress == playback.cued then
			if isPlaybackAllowedBool then
				panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.playScene
			else
				panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.playOnGameResume
			end
			panelState.playbackUnarmButtonState.isActive = true
		elseif thisScene.scenePlaybackProgress == playback.playPending then
			panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.playPending
			panelState.playbackButtonState.isActive = false
			panelState.playbackUnarmButtonState.isActive = true
		elseif thisScene.scenePlaybackProgress == playback.playing then
			panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.reloadSave
			panelState.playbackUnarmButtonState.isActive = true
		else
			panelState.playbackButtonState.buttonLabel = uiStrings.cetUiStrings.cetScenePanel.playbackButton.cueScene
		end
	end

	return(panelState)
end

function forceUpdateScenePerformersByPanelLogic(force)
	updatePerformers()
	if not force and isPreGameState then return end
	updateScenePanelStateFlags()
	getPanelLogic(femaleScenes, "Japantown", "female", 'none', _, true)
	getPanelLogic(femaleScenes, "Glen", "female", 'none', _, true)
	getPanelLogic(maleScenes, "Japantown", "male", 'none', _, true)
	getPanelLogic(maleScenes, "Glen", "male", 'none', _, true)
end

local panelState = nil
local lastItem, isClicked, newMenuButtonlabel, buttonWidth = nil, nil, nil, nil

function createScenesPanelForGender(gender, comboBoxWidth, isLastPanel)
	local scenesIndex, scenes, performers, desc, shortSceneName, fullSceneName, panelCountDown, panelsToCreate, panelsCreated
	if gender == 'female' then
		scenesIndex = femaleScenesIndex
		scenes = femaleScenes
		performers = femalePerformers
		desc = uiStrings.cetUiStrings.cetScenePanel.female
		panelCountDown = windowSettings.femalePanels
		panelsToCreate = windowSettings.femalePanels
	elseif gender == 'male' then
		scenesIndex = maleScenesIndex
		scenes = maleScenes
		performers = malePerformers
		desc = uiStrings.cetUiStrings.cetScenePanel.male
		panelCountDown = windowSettings.malePanels
		panelsToCreate = windowSettings.malePanels
	else return end
	panelsCreated = 0
	if #scenesIndex > 0 then
		for i = 1, #scenesIndex do
			local sceneName = scenesIndex[i]
			local thisScene = scenes[sceneName]
			if thisScene.isAvailable or thisScene.isAvailableOnlyInOverrideMode then
				if #thisScene.performersIndex > 0 then
					fullSceneName = nil
					if uiStrings.cetUiStrings.cetScenePanel.fullSceneNames[gender] then
						local localizedFullSceneName = uiStrings.cetUiStrings.cetScenePanel.fullSceneNames[gender][sceneName]
						if type(localizedFullSceneName) == 'string' and stringLen(localizedFullSceneName) > 0 then fullSceneName = localizedFullSceneName end
					end
					if not fullSceneName then
						if type(thisScene.displayName) == 'string' then
							fullSceneName = thisScene.displayName..' '..desc
						else
							fullSceneName = sceneName..' '..desc
						end
					end
					ImGui.Text(fullSceneName)

					local isOverrideEnabled = false
					local isOverrideModeEnabled = false
					local isSceneFastPlaybackEnabled = false
					local helpButtonWidth = ImGui.CalcTextSize("(?)")
					panelState = getPanelLogic(scenes, sceneName, gender, 'none', panelState)
					panelState.scenePlaybackMode 	= scenePlaybackMode.interactive
					panelState.sceneTargetLocation	= 'default'

					if isOverridesArchiveDetected and userSettings.enableHotscenesAddon then
						isOverrideEnabled = true
						if thisScene.isAvailableOnlyInOverrideMode or sceneState.isOverrideSceneAvailabilityModePlaybackRequested then
							ImGui.Text(uiStrings.cetUiStrings.cetScenePanel.sceneOverride.title)
							ImGui.SameLine()
							ImGui.Button('?##OverrideInfoHelpButton'..fullSceneName..tostring(i), helpButtonWidth, windowSettings.buttonHeight)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetScenePanel.sceneOverride.tooltips)
							end
							panelState.scenePlaybackMode = scenePlaybackMode.overrideSceneAvaliability
							isOverrideModeEnabled = true
						else
							local isFastTrackPlaybackAllowed = isScenePerfomerMet(gender, sceneName) or isSceneAvailableInOverrideMode(gender, sceneName)
							if not isFastTrackPlaybackAllowed then ImGui.BeginDisabled() end
							pcall(function()
								local value = false
								if isFastTrackPlaybackAllowed then value = userSettings[gender][sceneName].enableFastTrackPlayback or false end
								value, stateChanged = ImGui.Checkbox(uiStrings.cetUiStrings.cetScenePanel.fastPlayback.title..'##'..fullSceneName..tostring(i), value)
								if stateChanged then
									userSettings[gender][sceneName].enableFastTrackPlayback = value
									updatePerformers()
									panelState = getPanelLogic(scenes, sceneName, gender, 'none', panelState, true)
									saveUserSettings()
									if nativeUI.isActive then nativeUI.updateUI(true) end
								end
							end)
							if not isFastTrackPlaybackAllowed then ImGui.EndDisabled() end
							ImGui.SameLine()
							ImGui.Button('?##FastPlaybackHelpButton'..fullSceneName..tostring(i), helpButtonWidth, windowSettings.buttonHeight)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetScenePanel.fastPlayback.tooltips)
							end
							isSceneFastPlaybackEnabled = isFastTrackPlaybackAllowed and userSettings[gender][sceneName].enableFastTrackPlayback
							if isSceneFastPlaybackEnabled then panelState.scenePlaybackMode = scenePlaybackMode.fastPlayback end
						end
					end
					ImGui.NextColumn()

					local isPanelActive = panelState.isActive
					local shouldEnablePerformerSelectionInInactivePanel = false
					if not isPanelActive then
						ImGui.BeginDisabled()
						if is_mq055_hangouts_interaction_activated() then shouldEnablePerformerSelectionInInactivePanel = mq055_hangouts_interaction.isCustomChoiceOnScreen() end
					end
					pcall(function()
						if shouldEnablePerformerSelectionInInactivePanel then ImGui.EndDisabled() end
						local newComboHiddenName = '##Combo'..fullSceneName..tostring(i)
						ImGui.SetNextItemWidth(comboBoxWidth)

						lastItem = panelState.performersListState.itemIndex
						if not lastItem then lastItem = 0 end
						itemIndex, isClicked = ImGui.Combo(newComboHiddenName, lastItem, thisScene.performersFullNameIndexCetUi, #thisScene.performersIndex)
						if isClicked then
							panelState.performersListState.itemIndex = itemIndex
							panelState = getPanelLogic(scenes, sceneName, gender, 'performer changed', panelState)
							if nativeUI.isActive then nativeUI.updateUI(true) end
						end

						ImGui.SameLine()

						newMenuButtonlabel = panelState.resetButtonState.buttonLabel..'##Button'..gender..tostring(i)
						if ImGui.Button(newMenuButtonlabel, -1, windowSettings.buttonHeight) then
							panelState = getPanelLogic(scenes, sceneName, gender, 'reset button clicked', panelState)
							if nativeUI.isActive then nativeUI.updateUI(true) end
						end
						if shouldEnablePerformerSelectionInInactivePanel then ImGui.BeginDisabled() end

						if isOverrideEnabled and panelState.customLocationsList then
							local isEnabled = (isSceneFastPlaybackEnabled or isOverrideModeEnabled)
							if not isEnabled then ImGui.BeginDisabled() end
							newComboHiddenName = newComboHiddenName..'customLocation'
							ImGui.SetNextItemWidth(comboBoxWidth)
							if isEnabled then
								lastItem = panelState.customLocationsListState.customLocationItemIndex
								if not lastItem then lastItem = 0 end
								itemIndex, isClicked = ImGui.Combo(newComboHiddenName, lastItem, panelState.customLocationsList, #panelState.customLocationsList)
								local updateNativeUI = false
								if isClicked then
									panelState.customLocationsListState.customLocationItemIndex = itemIndex
									panelState = getPanelLogic(scenes, sceneName, gender, 'custom location changed', panelState)
								end
								panelState.sceneTargetLocation = thisScene.lastSelectedCustomLocation
								if isClicked and nativeUI.isActive then nativeUI.updateUI(true) end
							else
								lastItem = panelState.customLocationsListState.customLocationItemIndex
								ImGui.Combo(newComboHiddenName, 0, uiStrings.cetUiStrings.cetScenePanel.customSceneLocationCombo.defaultLocationList, #uiStrings.cetUiStrings.cetScenePanel.customSceneLocationCombo.defaultLocationList)
							end
							if not isEnabled then ImGui.EndDisabled() end
							ImGui.SameLine()
							ImGui.Button('?##'..newComboHiddenName, helpButtonWidth, windowSettings.buttonHeight)
							if ImGui.IsItemHovered() then
								ImGui.SetTooltip(uiStrings.cetUiStrings.cetScenePanel.customSceneLocationCombo.tooltips)
							end
						end

						local isPlaybackButtonActive = panelState.playbackButtonState.isActive
						if not isPlaybackButtonActive then ImGui.BeginDisabled() end
						pcall(function()
							newMenuButtonlabel = panelState.playbackButtonState.buttonLabel..'##Button'..gender..tostring(i)
							buttonWidth = -1
							if panelState.playbackUnarmButtonState.isActive then buttonWidth = comboBoxWidth - 1 end
							if ImGui.Button(newMenuButtonlabel, buttonWidth, windowSettings.buttonHeight) then
								panelState = getPanelLogic(scenes, sceneName, gender, 'playback button clicked', panelState)
								if nativeUI.isActive then nativeUI.updateUI(true) end
							end
						end)
						if not isPlaybackButtonActive then ImGui.EndDisabled() end

						if panelState.playbackUnarmButtonState.isActive then
							ImGui.SameLine()
							newMenuButtonlabel = panelState.playbackUnarmButtonState.buttonLabel..'##Button'..gender..tostring(i)
							if ImGui.Button(newMenuButtonlabel, -1, windowSettings.buttonHeight) then
								panelState = getPanelLogic(scenes, sceneName, gender, 'cancel button clicked', panelState)
								if nativeUI.isActive then nativeUI.updateUI(true) end
							end
						end
					end)
					if not isPanelActive then ImGui.EndDisabled() end
					panelCountDown = panelCountDown - 1
					if not (isLastPanel and panelCountDown < 1) then
						ImGui.Separator()
					end

					ImGui.NextColumn()
					panelsCreated = panelsCreated + 1
				end
			end
		end
		if panelsToCreate ~= panelsCreated then reInitMainWindow = true end
	end
	return panelsCreated
end

function setObservers()
	local roque_rq_on_game_load
	Observe('PlayerPuppet', 'OnGameAttached', function(this)
		isNewGameLoad = false
		if this:IsReplacer() then return end
		varSetup(true)
		queuedTasks.resetQueue = true
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if isPreGameState then isGameLoading = false else isGameLoading = true end
		isNewGameLoad = true
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
		isNudityCensored = isCensored()
		nativeUI.isNudityCensored = isNudityCensored
		if isNudityCensored and mq055_hangouts_interaction then mq055_hangouts_interaction.disableCustomChoices(true) end
		playerGenderSettings.playerSessionGenderName = nil
		restorePlayerGenderRecords()
		sceneState.sceneTier = 0
		sceneState.isPlayerUndressed = false
		sceneState.isSoundMuted = false
		lastQuestRelatedPaidActionStarted = false
		isKeyDialogOptionSelected = false
		keyDialogTitleLocKey = ''
		isEnding = false
		isEndingActive()
		is_nc_delights_scene_extensions_supported = is_nc_delights_scene_extensions_supported or isKnownName("Hotscenes_overrides_nc_delights_extensions_supported")
		roque_rq_on_game_load = nil
	end)

	ObserveBefore('inkISystemRequestsHandler', 'RequestSaveUserSettings', function (this)
		if not GameGetSystemRequestsHandler():IsPreGame() then return end
		local lastlanguageSelected = userSettings.lastLanguageSelected
		loadLocalizedStrings(true)
		if userSettings.lastLanguageSelected ~= lastlanguageSelected then saveUserSettings() end
		updatePerformers()
	end)

	local isGlenSceneEnabled
	local isPlaybackPendingOnGameLoad = false
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
		isPlaybackPendingOnGameLoad = false
		if this:IsReplacer() then return end
		isPlaybackPendingOnGameLoad = type(lastSceneSetupProgress) == 'table' and os.clock() < lastSceneSetupProgress.abortDeadline
		local isValid, playerGender = getPlayerBodyGender()
		if isValid then isPlayerMale = playerGender == "male" end
		if isPerformerReplacingPlayerSupported then
			clearPerformerReplicatingPlayer("Japantown", genders)
			clearPerformerReplicatingPlayer("Glen", genders)
			cleanupPerformersByPlayerGender(playerGender)
		end
		isGlenSceneEnabled = (not isPreGameState) and questsSystem:GetFactStr("sq017_mq028_start") > 0 and questsSystem:GetFactStr("sq017_done") > 0
		cleanupCustomLocationFacts()
		resetRogueHangoutsHandler()
		updateSceneState()
		forceUpdateScenePerformersByPanelLogic()

		local last_game_save_type = questsSystem:GetFactStr("mod_hotscenes_last_game_save_type")
		questsSystem:SetFactStr("mod_hotscenes_last_game_save_type", 0)
		if last_game_save_type ~= 2 then return end
		rqPayload = nil
		if not isAnyHangoutQuestActive() then return end
		local last_game_save_attempt = questsSystem:GetFactStr("mod_hotscenes_last_game_save_attempt")
		if last_game_save_attempt == 0 then return end
		local last_activated_rogue_lb_01 = questsSystem:GetFactStr("last_activated_rogue_lb_01_mod_hs")
		if last_activated_rogue_lb_01 == 0 then return end
		local playTime = mathFloor(GameGetEngineTime():ToFloat())
		if last_game_save_attempt > playTime then return end
		local minSaveTime = playTime - 10
		if last_game_save_attempt < minSaveTime then return end
		if last_activated_rogue_lb_01 > playTime then return end
		if last_activated_rogue_lb_01 < minSaveTime then return end
		roque_rq_on_game_load = true
	end)

	Observe('PlayerPuppet', 'OnDetach', function(this)
		if this:IsReplacer() then return end
		queuedTasks.resetQueue = true
	end)

	local gameJournalEntryStateActive = gameJournalEntryState.Active
	local function hey_gle_performer_reset(this)
		if not IsDefined(this) then return end
		if questsSystem:GetFactStr("sq017_mq028_start") > 0 and questsSystem:GetFactStr("sq017_done") > 0 then isGlenSceneEnabled = true return end
		if journalManager:GetEntryState(journalManager:GetEntry(3313083774)) ~= gameJournalEntryStateActive and journalManager:GetEntryState(journalManager:GetEntry(3313806824)) ~= gameJournalEntryStateActive then return end
		this:Dispose()
		questsSystem:SetFactStr("hey_gle_f_prostitue_met", 0)
		questsSystem:SetFactStr("hey_gle_pro_m_dreams", 0)
	end
	local hey_gle_female_id = t"Character.hey_gle_prostitute_female"
	local hey_gle_male_id = t"Character.hey_gle_prostitute_male"
	local gameScenePerformersLookup = {}
	gameScenePerformersLookup[hey_gle_female_id.hash] = hey_gle_female_id
	gameScenePerformersLookup[hey_gle_male_id.hash] = hey_gle_male_id
	local minHash = mathMin(hey_gle_female_id.hash, hey_gle_male_id.hash)
	ObserveAfter('ScriptedPuppet', 'CreateListeners', function(this)
		if isEnding then return end
		if isGlenSceneEnabled then return end
		if sceneState.isOverrideSceneAvailabilityModePlaybackRequested then return end
		if sceneState.shouldReloadGameOnFinished then return end
		if not this:IsNPC() then return end
		local id = this:GetTDBID();
		local idHash = id.hash
		if idHash < minHash then return end
		local performer = gameScenePerformersLookup[idHash]
		if not performer then return end
		if id ~= performer then return end
		local npc = RefWeak(this)
		local payload = function() hey_gle_performer_reset(npc) end
		queueTask(payload, false, 0.02)
	end)

	local gameLoadStartTime = nil
	local lastGameLoadTime = 0;
	Observe('inkISystemRequestsHandler', 'LoadLastCheckpoint', function(this) gameLoadStartTime = os.clock() end);
	Observe('inkISystemRequestsHandler', 'LoadSavedGame', function(this) gameLoadStartTime = os.clock() end);
	Observe('gameuiSaveHandlingController', 'LoadSaveInGame', function(this) gameLoadStartTime = os.clock() end);
	Observe('gameuiSaveHandlingController', 'LoadModdedSave', function(this) gameLoadStartTime = os.clock() end);

	local function getLoadTimeout()
		if not gameLoadStartTime then return end;
		gameLoadStartTime = nil;
		if lastGameLoadTime < 10 then return end
		if lastGameLoadTime > 180 then return end
		if lastGameLoadTime >= lastSceneSetupProgresstTimeout then lastSceneSetupProgresstTimeout = lastGameLoadTime + lastGameLoadTime return end
		if lastSceneSetupProgresstTimeout - lastGameLoadTime < 15 then lastSceneSetupProgresstTimeout = lastGameLoadTime + lastGameLoadTime return end
	end

	ObserveAfter('PlayerPuppet', 'OnMakePlayerVisibleAfterSpawn', function(this)
		rqPayload = nil
		getLoadTimeout()
		isPreGameState = GameGetSystemRequestsHandler():IsPreGame()
		if isPreGameState then roque_rq_on_game_load = false return end
		isGameLoading = false
		questsSystem:SetFactStr("restart_rogue_rq_01_mod_hs", 0)
		questsSystem:SetFactStr("mod_hotscenes_spycam_activation_not_allowed", 0)
		questsSystem:SetFactStr("mod_hotscenes_spycam_deactivation_not_allowed", 0)
		if isPlaybackPendingOnGameLoad then roque_rq_on_game_load = false return end
		questsSystem:SetFactStr("mod_hotscenes_preserve_performer_appearance", 0)
		questsSystem:SetFactStr("prostitutes_play_all_anims", 0)
		questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 0)
		loadUserSettings()
		updateSpycamParameters()
		hotscenesLoadAndVerify(true, true)
		verifyCustomSceneLocationData(true)
		deactivateRedundantActivators(true)
		clearPlaybackStatesNoGameReload()
		forceUpdateScenePerformersByPanelLogic(true)
		if not roque_rq_on_game_load then return end
		roque_rq_on_game_load = false
		rqPayload = function() questsSystem:SetFactStr("restart_rogue_rq_01_mod_hs", 1) end
	end)

	local function removeSpecs(this)
		local cp
		for i, specs in ipairs(h1_specs) do
			cp = this:FindComponentByName(specs)
			if cp then break end
		end
		if not cp then return end
		cp.chunkMask = 0
		cp:Toggle(false)
	end

	local n_l0_004_wa_tights__fishnet = n"l0_004_wa_tights__fishnet"
	local function removeFishNets(this)
		local cp = this:FindComponentByName(n_l0_004_wa_tights__fishnet)
		if not cp then return true end
		cp.chunkMask = 0
		cp:Toggle(false)
	end

	local n_AppearanceVisualController = n"AppearanceVisualController"
	local n_fx_woman_base = n"fx_woman_base"
	local function removeSpikedChokers(this)
		lastInstance = RefWeak(this)
		local vs = this:FindComponentByName(n_AppearanceVisualController)
		if not vs then return end
		local appearanceDependency = vs.appearanceDependency
		if #appearanceDependency < 1 then return end
		local isFemale = this:FindComponentByName(n_fx_woman_base) ~= nil
		local cp
		for i, choker in ipairs(choker_spikes) do
			local val = choker.componentName
			if val then
				cp = this:FindComponentByName(val)
				if cp then break end
			else
				val = choker.meshHash
				if val and isFemale == choker.isFemale then
					for ii, cprec in pairs(appearanceDependency) do
						if cprec.mesh.hash == val then cp = this:FindComponentByName(cprec.componentName) if cp then break end end
					end
				end
				if cp then break end
			end
		end
		if not cp then return end
		cp.chunkMask = 0
		cp:Toggle(false)
	end

	local lookedAppearances = {n"service__sexworker_wa__ow__poor_01_naked", n"service__sexworker_wa__ow__poor_01_strap", n"service__sexworker_wa__ow__luxury_01_naked", n"service__sexworker_wa__ow__luxury_01_strap", n"service__sexworker_ma__ow__luxury_01_naked", n"service__sexworker_ma__ow__poor_01_naked"}
	ObserveBefore('ScriptedPuppet', 'OnRequestComponents', function(this)
		if not sceneState.isPlayerInHotscene then return end
		if not (userSettings.hideNpcSpecs or userSettings.hideNpcSpikedChokers) then return end
		if this.isCrowd then return end
		if not this:IsNPC() then return end
		local id = this:GetTDBID()
		if not id then return end
		if id.hash < 2 then return end
		local currentAppearance = this:GetCurrentAppearanceName()
		for i, name in ipairs(lookedAppearances) do
			if name == currentAppearance then
				if userSettings.hideNpcSpecs then removeSpecs(this) end
				if userSettings.hideNpcFishnetTights then removeFishNets(this) end
				if userSettings.hideNpcSpikedChokers then removeSpikedChokers(this) end
				return
			end
		end
	end)

	Observe('GenericNotificationController', 'SetNotificationData', function(this, notificationData)
		if not GetPlayer():IsCooldownActive("mod_hotscenes_keep_notifications_quiet") then return end
		local rootWidget = this:GetRootCompoundWidget()
		if not rootWidget then return end
		notificationData.action = GenericNotificationBaseAction.new()
		notificationData.animation = CName.new()
		notificationData.soundEvent = CName.new()
		notificationData.soundAction = CName.new()
		rootWidget.visible = false
	end)

	Observe('QuestTrackerGameController', 'OnTrackedEntryChanges', function()
		hotscenesLoadAndVerify(true)
		verifyCustomSceneLocationData(true)
	end)

	local lastLoadingScreenProgressBarRootWidget
	Observe('LoadingScreenProgressBarController', 'SetProgressBarVisiblity', function(this)
		lastLoadingScreenProgressBarRootWidget = RefWeak(this.progressBarRoot.widget)
	end)

	Observe('LoadingScreenProgressBarController', 'SetProgress', function(self, progress)
		if isGameLoading and progress < 0.91 then
			if gameLoadStartTime then lastGameLoadTime = os.clock() - gameLoadStartTime end
			lastGameLoadTime = lastGameLoadTime / progress
		end
		if not lastSceneSetupProgress then return end
		if not (type(lastSceneSetupProgress.abortDeadline) == 'number' and lastSceneSetupProgress.abortDeadline > 0) then return end
		lastSceneSetupProgress.lastUpdateTime = os.clock()
		lastSceneSetupProgress.loadingScreenProgressBarControllerTime = lastSceneSetupProgress.lastUpdateTime
		lastSceneSetupProgress.abortDeadline = lastSceneSetupProgress.lastUpdateTime + lastSceneSetupProgresstTimeout
	end)

	local n_eyes_closing_instant = n"eyes_closing_instant"
	local n_eyes_closed_loop = n"eyes_closed_loop"

	local GameObjectEffectHelperStartEffectEvent = GameObjectEffectHelper.StartEffectEvent
	local GameObjectEffectHelperStopEffectEvent = GameObjectEffectHelper.StopEffectEvent
	local GameObjectEffectHelperBreakEffectLoopEvent = GameObjectEffectHelper.BreakEffectLoopEvent
	local isOpeningEyesCooldown = n"is_opening_eyes_cooldown_mod_hotscenes"
	local hasEyesClosed

	function startEyesClosed(isInstant, force)
		local player = GetPlayer()
		if not player then return end
		if player:IsCooldownActive(isOpeningEyesCooldown) then return end
		if not force and hasEyesClosed then return end;
		hasEyesClosed = true
		if isInstant then GameObjectEffectHelperStartEffectEvent(player, n_eyes_closing_instant) end
		GameObjectEffectHelperStartEffectEvent(player, n_eyes_closed_loop)
		if not isInstant then return end
		local payload = function()
			local player = GetPlayer()
			if not player then return end
			if not hasEyesClosed then return end
			if player:IsCooldownActive(isOpeningEyesCooldown) then return end
			GameObjectEffectHelperBreakEffectLoopEvent(player, n_eyes_closing_instant)
		end;
		queueTask(payload, false, 0.25)
	end;
	function startOpenEyes()
		local player = GetPlayer()
		if not player then return end
		if player:IsCooldownActive(isOpeningEyesCooldown) then return end
		if not hasEyesClosed then return end
		GameObjectEffectHelperBreakEffectLoopEvent(player, n_eyes_closed_loop)
		queueTask(payload, false, 0.01)
		local payload = function()
			local player = GetPlayer()
			if not player then return end;
			if not hasEyesClosed then return end
			if player:IsCooldownActive(isOpeningEyesCooldown) then return end
			player:StartCooldown(isOpeningEyesCooldown, 0.75)
			GameObjectEffectHelperStartEffectEvent(player, n_eyes_opening_05s)
			hasEyesClosed = false
		end
		queueTask(payload, false, 0.12)
	end;
	function startOpenEyesByTime(stopTime)
		local player = GetPlayer()
		if not player then return end
		if player:IsCooldownActive(isOpeningEyesCooldown) then return end
		if not hasEyesClosed then return end
		if type(stopTime) ~= 'number' then return startOpenEyes() end
		local curTime = os.clock()
		if curTime >= stopTime then return startOpenEyes() end
		local startTime = stopTime - 0.26
		if curTime >= startTime then return startOpenEyes() end
		queueTask(startOpenEyes, false, startTime-curTime)
	end
	function killEyesClosed()
		local player = GetPlayer()
		if not player then return end
		hasEyesClosed = false
		GameObjectEffectHelperStopEffectEvent(player, n_eyes_closed_loop)
		GameObjectEffectHelperStopEffectEvent(player, n_eyes_opening_05s)
		GameObjectEffectHelperStopEffectEvent(player, n_eyes_closing_instant)
		player:RemoveCooldown(isOpeningEyesCooldown)
	end;

	local isCommunicationEventQuestEventHandlerFixed = false
	local n_mod_hotscenes_scene_playback_facts_updated = n"mod_hotscenes_scene_playback_facts_updated"
	local n_None = CName.new()
	local n_PlayerPuppet = n"PlayerPuppet"
	ObserveAfter('ScriptedPuppet', 'OnCommunicationEvent', function(this, evt);
		local eventName = evt.name
		if eventName == n_mod_hotscenes_scene_playback_facts_updated then isCommunicationEventQuestEventHandlerFixed = true end
		if not userSettings.enableHotscenesAddon then return end
		if not sceneState then return end
		if not sceneState.fastTrackFactsSet then return end
		if not (sceneState.isFastTrackPlaybackRequested or sceneState.isOverrideSceneAvailabilityModePlaybackRequested or sceneState.shouldReloadGameOnFinished) then return end
		if not this:IsA(n_PlayerPuppet) then return end
		if isCommunicationEventQuestEventHandlerFixed then
			if evt.sender.hash ~= 1ULL then return end
			if eventName ~= n_mod_hotscenes_scene_playback_facts_updated then return end
		else
			if evt.sender.hash ~= 0 then return end
			if eventName ~= n_None then return end
		end

		if not isFastTrackPlaybackAvaliable() then return end
		if questsSystem:GetFactStr('mod_hotscenes_scene_playback_facts_updated') < 1 then return end
		questsSystem:SetFactStr('mod_hotscenes_scene_playback_facts_updated', 0)

		resetSceneAvaliabilityOverrideFacts()
		resetQuestAvaliabilityOverrideFacts()

		if questsSystem:GetFactStr(sceneState.fastTrackFactsSet.stopFactName) < 1 then
			if questsSystem:GetFactStr(sceneState.fastTrackFactsSet.playingFactName) > 0 then sceneState.isFastTrackPlaybackPerformed = true end
			updateSceneState()
			return
		end

		toggleHudMainWindow(false)
		queueTask(function() toggleHudMainWindow(true) end, false, 5)
		resetFastTrackStates(true)
		if spycam and spycam.drone.fullySpawned then
			spycam.drone:despawn()
			local payload = function() if GetPlayer() then toggleHudMainWindow(true) end end
			queueTask(payload, false, 2)
		end

		sceneState.isOverrideSceneAvailabilityModePlaybackRequested = nil
		sceneState.isCustomLocationPlayback = nil

		if not sceneState.shouldReloadGameOnFinished then return end

		if isArchiveXLActive and isOverridesArchiveDetected and userSettings.enableHotscenesAddon and userSettings.noGameReloads and isCustomTriggerQuestActive() and isKnownName("mod_hotscenes_no_game_reload_support_available") and questsSystem:GetFactStr("mod_hotscenes_no_game_reload") > 1 then
			sceneState.shouldReloadGameOnFinished = false
			if this:IsCooldownActive("mod_hotscenes_game_reload_requested") then return end
			this:StartCooldown("mod_hotscenes_game_reload_requested", 2)
			print(modName, "Finalizing the scene playback without reloading game.")
			if not sceneState.playerReturnToPos or not sceneState.playerReturnToYaw then return end
			local retPos = Vector4.new(sceneState.playerReturnToPos)
			local retRot = EulerAngles.new(0, 0, sceneState.playerReturnToYaw)
			local timeout = os.clock() + 60
			local wasLoadingScreenActive
			startEyesClosed(true, true)
			local payload = function()
				if os.clock() > timeout then killEyesClosed() questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0) return true end
				local player = GetPlayer()
				if not player then return true end
				local val = questsSystem:GetFactStr("mod_hotscenes_no_game_reload")
				if val < 2 then return true end
				if val < 3 then return end
				local currPos = player:GetWorldPosition()
				if vectorDistanceSquared(currPos, retPos) > 1 then return end
				if IsDefined(lastLoadingScreenProgressBarRootWidget) then wasLoadingScreenActive = true return end

				local stop = os.clock() + 1.25
				local isOpeningEyes
				local payload = function()
					local player = GetPlayer()
					if not player then return true end
					if not isOpeningEyes then startOpenEyesByTime(stop) isOpeningEyes = true end
					local curTime = os.clock()
					if curTime > stop then
						if hasEyesClosed then
							killEyesClosed()
						end
						questsSystem:SetFactStr("mod_hotscenes_no_game_reload", 0)
						clearPlaybackStatesNoGameReload()
						forceUpdateScenePerformersByPanelLogic()
						return true
					end
					GameGetTeleportationFacility():Teleport(player, retPos, retRot)
				end
				queueTask(payload, false, 0.1, 0.0001, false)
				return true
			end
			queueTask(payload, false, 0.01, 0.0001, false)
			return
		end
		this:StartCooldown("mod_hotscenes_keep_notifications_quiet", 5)
		if this:IsCooldownActive("mod_hotscenes_game_reload_requested") then return end
		this:StartCooldown("mod_hotscenes_game_reload_requested", 0.5)
		GameObjectEffectHelper.StartEffectEvent(this, n_eyes_closing_instant_open_slow)
		sceneState.shouldReloadGameOnFinished = false
		queueTask(reloadGameAndClearPlaybackStates, false, 0.25)
	end);

	Observe('PlayerPuppet', 'OnFactChangedEvent', function(this, evt)
		if not sceneState then return end
		if sceneState.isNCDelightsScenePlaying then return end
		if not sceneState.isPlayerInScene then return end
		if not sceneState.isIntro then return end
		if evt:GetFactName().value ~= "mod_hotscenes_main_fem_aux01_started" then return end
		local performerData = sceneState.lastSelectedPerformerData
		if not performerData then return end

		local activeSceneSupport = performerData.activeSceneSupport
		if not activeSceneSupport then return end
		if not activeSceneSupport[tostring(sceneState.sceneName)] then return end
		local aux01_support = activeSceneSupport.aux01_support
		if type(aux01_support) ~= 'function' then return end
		local npc = GameFindEntityByID(sceneState.performerEntID)
		if not npc then return end
		aux01_support(npc)
	end)

	ObserveAfter('PlayerVisionModeController', 'OnRestrictedSceneChanged', function(self, value)
		if value > 0 and isNewGameLoad then isNewGameLoad = false end
		if not (sceneState.isIntro and value > 0) then sceneState.sceneTier = value updateSceneState() end
		if not rqPayload then return end
		if value < 1 then return end
		if value > 2 then return end
		if not isRogueHangoutRestartActive() then rqPayload = nil return end
		if type(rqPayload) == 'function' then rqPayload() end
		rqPayload = nil
	end)

	ObserveAfter('InvisibleSceneStash', 'OnQuestUndressPlayer', function(self)
		if not sceneState.isPlayerInScene then return end
		sceneState.sceneTier = GetPlayer():GetSceneTier()
		sceneState.isPlayerUndressed = true
		updateSceneState()
	end)

	ObserveAfter('InvisibleSceneStash', 'OnQuestDressPlayer', function(self)
		questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 0);
		if not sceneState.isPlayerInScene then return end
		sceneState.sceneTier = GetPlayer():GetSceneTier()
		sceneState.isPlayerUndressed = false
		updateSceneState()
	end)

	local n_MenuScenario_Idle = n"MenuScenario_Idle"
	local n_MenuScenario_PauseMenu = n"MenuScenario_PauseMenu"
	Observe('inkMenuScenario', 'SwitchToScenario', function(self, name)
		if self:IsA(n_MenuScenario_Idle) then idleMenuHandle = RefWeak(self) return end
		if self:IsA(n_MenuScenario_PauseMenu) then pauseMenuHandle = RefWeak(self) return end
	end)

	Observe('inkMenuScenario', 'GetMenusState', function(self)
		if self:IsA(n_MenuScenario_Idle) then idleMenuHandle = RefWeak(self) return end
		if self:IsA(n_MenuScenario_PauseMenu) then pauseMenuHandle = RefWeak(self) return end
	end)

	Observe('MenuScenario_PauseMenu', 'OnEnterScenario', function(self)
		if self:IsA(n_MenuScenario_PauseMenu) then pauseMenuHandle = RefWeak(self) return end
	end)

	local countDown = 0
	Observe('SaveGameMenuGameController', 'SetupLoadItems', function(self, saves)
		lastGameSavesFileNames = saves
		countDown = #lastGameSavesFileNames
	end)

	Observe('SaveGameMenuGameController', 'OnSaveMetadataReady', function(self, info)
		if not IsDefinedNS(info) then return end
		if not info.saveIndex then return end
		if not isLookingForLastModSave then return end
		if countDown > 0 then
			countDown = countDown - 1
			lastModSaveIndex = 0
			if info.saveType == inkSaveType.ManualSave then
				local currentSaveMetadata = {
					playTime = info.playTime,
					playthroughTime = info.playthroughTime,
					locationName = info.locationName,
					trackedQuest = info.trackedQuest,
					lifePath = info.lifePath,
					gameVersion = info.gameVersion
					}
				if isSameSaveMetadata(userSettings.lastKnownSaveMetadata, currentSaveMetadata) then
					lastModSaveIndex = info.saveIndex + 1
					isLookingForLastModSave = false
					lastModSaveFileName = lastGameSavesFileNames[lastModSaveIndex]
					do return end
				end
			end
			if info.saveIndex + 1 >= #lastGameSavesFileNames then
				isLookingForLastModSave = false
				lastModSaveIndex = 0
				lastModSaveFileName = 'unknown'
			end
		else
			isLookingForLastModSave = false
			lastModSaveIndex = 0
			lastModSaveFileName = 'unknown'
		end
	end)

	local n_freeze_input_cooldown = n"freeze_input_cooldown"

	if enable_mq055_hangouts_support and isArchiveXLActive and hotscenesData.is_mq055_integration_supported then
		function is_mq055_hangouts_interaction_activated()
			if not mq055_hangouts_interaction then return end
			return mq055_hangouts_interaction.isActive
		end

		function sceneLaunchPayload(performer, gender, destination, isRomanceScene)
			if not is_mq055_hangouts_interaction_activated() then return end
			if isModDisabled then mq055_hangouts_interaction.disableCustomChoices(true) return end
			if not userSettings.enableHotscenesAddon then mq055_hangouts_interaction.disableCustomChoices(true) return end
			if not isOverridesArchiveDetected then mq055_hangouts_interaction.disableCustomChoices(true) return end
			if not isKnownName("Hotscenes_overrides_mod_mq055_hangouts_interaction_supported") then mq055_hangouts_interaction.disableCustomChoices(true) return end
			if type(performer) ~= 'string' then return false end
			if type(gender) ~= 'string' then return false end
			if type(destination) ~= 'string' then return false end
			if not (gender == 'female' or gender == 'male') then return false end
			if type(hotscenesData.mq055_performers[performer]) ~= 'table' then return false end
			if isRomanceScene then
				if gender == 'female' then
					if not romanceScenesFemale then return false end
				else
					if not romanceScenesMale then return false end
				end
			end

			local currEngineTime = GameGetEngineTime():ToFloat()
			if is_mq055_custom_scene_playback_requested > currEngineTime then return false end
			is_mq055_custom_scene_playback_requested = currEngineTime + 30

			local scenes
			local sceneName = "Japantown"
			if isRomanceScene then
				sceneName = destination
				if gender == 'female' then
					scenes = romanceScenesFemale
				elseif gender == 'male' then
					scenes = romanceScenesMale
				end
			else
				if gender == 'female' then
					scenes = femaleScenes
				elseif gender == 'male' then
					scenes = maleScenes
				end
				local mainScenes = hotscenesData.mq055_scenes[destination]
				if type(mainScenes) == 'table' then
					if #mainScenes == 1 then
						sceneName = mainScenes[1]
					elseif #mainScenes > 1 then
						math.randomseed(os.clock())
						local mainSceneSelector = math.random(1, #mainScenes)
						local lastPlayedMainSceneIndex = TweakDB:GetFlat("mod_hotscenes_next_gen_last_selected_mq055_mainScene_index")
						local lastPlayedMainSceneCount
						if type(lastPlayedMainSceneIndex) == 'number' and mainSceneSelector == lastPlayedMainSceneIndex then
							lastPlayedMainSceneCount = TweakDB:GetFlat("mod_hotscenes_next_gen_last_selected_mq055_mainScene_count")
							if type(lastPlayedMainSceneCount) == 'number' and lastPlayedMainSceneCount > 1 then
								mainSceneSelector = mainSceneSelector + 1
								if mainSceneSelector > #mainScenes then mainSceneSelector = 1 end
								lastPlayedMainSceneCount = 0
							end
						end
						sceneName = mainScenes[mainSceneSelector]
						lastPlayedMainSceneIndex = mainSceneSelector
						if not lastPlayedMainSceneCount then lastPlayedMainSceneCount = 0 end
						lastPlayedMainSceneCount = lastPlayedMainSceneCount + 1
						TweakDB:SetFlat("mod_hotscenes_next_gen_last_selected_mq055_mainScene_index", lastPlayedMainSceneIndex, "Int32")
						TweakDB:SetFlat("mod_hotscenes_next_gen_last_selected_mq055_mainScene_count", lastPlayedMainSceneCount, "Int32")
					end
				end
			end

			local hotscenesSelectedPerformers = {}
			if gender == 'female' then
				for _, scene in pairs(femaleScenes) do
					if type(scene.lastSelectedPerformer) == 'string' then tableInsert(hotscenesSelectedPerformers, scene.lastSelectedPerformer) end
				end
			elseif gender == 'male' then
				for _, scene in pairs(maleScenes) do
					if type(scene.lastSelectedPerformer) == 'string' then tableInsert(hotscenesSelectedPerformers, scene.lastSelectedPerformer) end
				end
			end

			local performerPriorityList = {}
			if isRomanceScene then
				performerPriorityList = scenes[sceneName].performerPriorityList
				if userSettings.mq055_integration_prefer_vanilla_appearances then performerPriorityList = scenes[sceneName].performerPriorityList_prefer_vanilla end
				if type(performerPriorityList) ~= 'table' then performerPriorityList = {} end
			else
				performerPriorityList = hotscenesData.mq055_performers[performer]
				if userSettings.mq055_integration_prefer_vanilla_appearances and type(hotscenesData.mq055_performers_prefer_vanilla) == 'table' then performerPriorityList = hotscenesData.mq055_performers_prefer_vanilla[performer] end
				if type(performerPriorityList) ~= 'table' or #performerPriorityList < 1 then is_mq055_custom_scene_playback_requested = 0 return false end
			end
			local isExpectedPerformerSelected = false
			if #hotscenesSelectedPerformers > 0 then
				for i, name in ipairs(performerPriorityList) do
					for ii = 1, #hotscenesSelectedPerformers do
						if stringLower(name) == stringLower(hotscenesSelectedPerformers[ii]) then
							performer = hotscenesSelectedPerformers[ii]
							isExpectedPerformerSelected = true
							break
						end
					end
					if isExpectedPerformerSelected then break end
				end
			end
			if not isExpectedPerformerSelected then performer = performerPriorityList[1] end

			if not setPerformerToScene(performer, sceneName, gender, isRomanceScene) then is_mq055_custom_scene_playback_requested = 0 return false end
			if stringMatch(destination, 'default') then destination = 'default' end
			scenes[sceneName].scenePlaybackProgress	= playback.playPending
			scenes[sceneName].scenePlaybackMode 	= scenePlaybackMode.overrideSceneAvaliability
			scenes[sceneName].sceneTargetLocation	= destination
			restorePlayerGenderRecords()
			GetPlayer():StartCooldown(n_freeze_input_cooldown, 3)
			playScene(sceneName, gender, is_mq055_custom_scene_playback_requested, isRomanceScene)
			return true
		end

		if not mq055_hangouts_interaction then mq055_hangouts_interaction = GetMod("hotscenes_mq055_interaction") end
		if not mq055_hangouts_interaction then mq055_hangouts_interaction = require("hotscenes_mq055_interaction") else print("! DEBUG --> hotscenes_mq055_interaction test mod loaded") end
		if mq055_hangouts_interaction then
			for key, supportedScene in pairs(mq055_hangouts_interaction.supportedScenesPool) do mq055_hangouts_interaction.supportedScenesPool[key] = false end
			if type(mq055_hangouts_interaction.disableAllDestinations) == 'function' then
				mq055_hangouts_interaction.disableAllDestinations()
			else
				for key, sceneDestination in pairs(mq055_hangouts_interaction.hotsceneDestinations) do mq055_hangouts_interaction.hotsceneDestinations[key].isEnabled = false end
			end
			mq055_hangouts_interaction.init()

			local n_SubtitlesGameController = n"SubtitlesGameController"
			local n_ChattersGameController = n"ChattersGameController"
			Observe('inkGameController', 'GetUIBlackboard', function(this);
				if this:IsA(n_SubtitlesGameController) then return end
				if this:IsA(n_ChattersGameController) then return end
				if not is_mq055_hangouts_interaction_activated() then return end
				if isModDisabled then mq055_hangouts_interaction.disableCustomChoices() return end
				if not enable_mq055_hangouts_support then mq055_hangouts_interaction.disableCustomChoices() return end
				if not isOverridesArchiveDetected then mq055_hangouts_interaction.disableCustomChoices() return end
				if not (userSettings.enableHotscenesAddon and userSettings.enable_mq055_integration) then mq055_hangouts_interaction.disableCustomChoices() return end
				if not isCustomTriggerQuestActive() then mq055_hangouts_interaction.disableCustomChoices() return end
				if not isKnownName("Hotscenes_overrides_mod_mq055_hangouts_interaction_supported") then mq055_hangouts_interaction.disableCustomChoices() return end

				local partnerEntryHash = isAnyHangoutQuestActive()
				if not partnerEntryHash then mq055_hangouts_interaction.disableCustomChoices() return end
				if isRogueHangoutModActive(isRogueHangoutsHandlerAvailable()) and (not isRogueHangoutRestartActive()) then printError(modInfoPrefix, "Some other mod affecting original game's hangout scenes compatibility detected. Hotscenes Hangouts Integration feature is disabled in a bid to prevent possibly severe issues. Please check Hotscenes log for more details.", os.clock()) enable_mq055_hangouts_support = false return end

				local currentPartnerDetails = hotscenesData.mq055_partnersByEntryHash[tostring(partnerEntryHash)]
				if type(currentPartnerDetails) ~= 'table' then mq055_hangouts_interaction.disableCustomChoices() return end
				local currentPartnerName = currentPartnerDetails.name
				if type(currentPartnerName) ~= 'string' then mq055_hangouts_interaction.disableCustomChoices() return end
				local currentPartnerGender = currentPartnerDetails.gender
				if type(currentPartnerGender) ~= 'string' then mq055_hangouts_interaction.disableCustomChoices() return end

				if mq055_hangouts_interaction.disableAllDestinations then
					mq055_hangouts_interaction.disableAllDestinations()
				else
					for key, sceneDestination in pairs(mq055_hangouts_interaction.hotsceneDestinations) do mq055_hangouts_interaction.hotsceneDestinations[key].isEnabled = false end
				end

				local isAnyDestinationEnabled = false
				local mainScenesNames = {"sq029", "sq030", "Japantown", "Glen"}

				for i, mainSceneName in ipairs(mainScenesNames) do
					local validLocations, validLocationsIndex, validLocationsDescriptions, isAnyCustomLocationIncluded = getCustomLocationsListsForScene(currentPartnerGender, mainSceneName, true)
					if validLocations then
						for _, destination in pairs(validLocationsIndex) do
							local shouldEnable = true
							if destination == 'default' then destination = destination..mainSceneName end
							if mq055_hangouts_interaction.hotsceneDestinations[destination] then
								local isRomanceScene = false
								local locationData = getCustomLocationData(currentPartnerGender, mainSceneName, destination)
								if locationData and type(locationData.isAllowedByQuestConditions) == 'function' then
									shouldEnable = locationData.isAllowedByQuestConditions(currentPartnerName)
									isRomanceScene = locationData.isRomanceScene
								end
								if shouldEnable then
									mq055_hangouts_interaction.hotsceneDestinations[destination].isEnabled = true
									mq055_hangouts_interaction.hotsceneDestinations[destination].payload = function() return sceneLaunchPayload(currentPartnerName, currentPartnerGender, destination, isRomanceScene) end
								end
								isAnyDestinationEnabled = true
							end
						end
					end
				end
				if not isAnyDestinationEnabled then mq055_hangouts_interaction.disableCustomChoices() return end

				for key, supportedScene in pairs(mq055_hangouts_interaction.supportedScenesPool) do mq055_hangouts_interaction.supportedScenesPool[key] = true end
				local entryState = getQuestEntryState(1847882645);
				if entryState and (entryState == gameJournalEntryState.Active) then mq055_hangouts_interaction.supportedScenesPool.mq055_02_northside_active = false end
				if not mq055_hangouts_interaction.isAnyChoiceCreated() then mq055_hangouts_interaction.createTopEntry() end
				if not mq055_hangouts_interaction.enableCustomChoices() then return end
			end)
		else
			function is_mq055_hangouts_interaction_activated() return false end
		end
	else
		function is_mq055_hangouts_interaction_activated() return false end
	end

	ObserveAfter('dialogWidgetGameController', 'OnDialogsSelectIndex', function(self, index)
		isKeyDialogOptionSelected = false
		isPaymentDone = false
		if index < 0 then return end
		if #self.hubControllers < 1 then return end
		local data = self.data
		if not data then return end
		local choiceHubs = data.choiceHubs
		if type(choiceHubs) ~= 'table' then return end
		for i, choice in ipairs(choiceHubs) do
			if choice and choice.activityState == gameinteractionsvisEVisualizerActivityState.Active and choice.flags == gameinteractionsvisEVisualizerDefinitionFlags.QuestImportant then
				isKeyDialogOptionSelected = true
				keyDialogTitleLocKey = choice.title
				break
			end
		end
	end)

	Observe('PaymentConditionTypeBase', 'IsPaidWhenSucceeded', function(self)
		isPaymentDone = true
		if isKeyDialogOptionSelected then lastQuestRelatedPaidActionStarted = os.clock() end
	end)

	Observe('FastTravelSystem', 'OnEnableFastTravelRequest', function(self, request)
		if sceneState.isOutro then
			if spycam then spycam.drone:despawn() end
			local payload = function() if GetPlayer() then toggleHudMainWindow(true) end end
			queueTask(payload, false, 2)
			sceneState.isSpycamAllowed = false
			sceneState.performerEntID = nil
		end
	end)

	Observe('TakeOverControlSystem', 'ToggleToMainPlayerObject', function()
		if not spycam then return end
		if not spycam.drone.spawned then return end
		if type(spycam.drone.lastReleaseControlRequest) ~= 'number' then return end
		if os.clock() - spycam.drone.lastReleaseControlRequest > 0.005 then return end
		local sceneTier = GetPlayer():GetSceneTier()
		if sceneTier < 4 then return end
		if sceneTier > 5 then return end
		toggleHudMainWindow(false)
	end)

	Observe('SurveillanceCamera', 'OnToggleTakeOverControl', function(self, evt)
		if not spycam then return end
		if not spycam.drone.spawned then return end

		if self:GetEntityID().hash == spycam.drone.handle:GetEntityID().hash then
			toggleHudMainWindow(true)
		else
			if timeSystem:IsTimeDilationActive(slowMoParams.cNameSlowMoSpycamReason) then timeSystem:UnsetTimeDilation(slowMoParams.cNameSlowMoSpycamReason) end
			if timeSystem:IsTimeDilationActive("mod_hotscenes_spycam_freeze_frame") then timeSystem:UnsetTimeDilation("mod_hotscenes_spycam_freeze_frame") end
			spycam.drone.spawnRequested = false
			spycam.drone:despawn(true)
			local payload = function() if GetPlayer() then toggleHudMainWindow(true) end end
			queueTask(payload, false, 2)
			return
		end

		if (not sceneState.isSpycamAllowed) and (not sceneAvailabilityOverride) then return end

		if userSettings.isGenderSwitchFeatureEnabled and sceneState.isGenderSwitchMode then
			if (not sceneState.isPlayerInHotscene) and (not sceneState.isOutro) then
				local isGenderRestored = restorePlayerGenderRecords()

				if sceneState.shouldChangeGender then
					local currTime = os.clock()
					local diff = sceneState.changeGenderTime - currTime
					if diff < 1 then
						sceneState.changeGenderTime = currTime + 0.5
					end
				else
					sceneState.shouldChangeGender = true
					sceneState.changeGenderTime = os.clock() + 0.5
				end
			end
		end
	end)

	Observe('TakeOverControlSystem', 'ToggleToMainPlayerObject', function(self)
		if not userSettings.isGenderSwitchFeatureEnabled then return end
		if not spycam then return end
		if not spycam.drone.spawned then return end
		if not sceneState.isGenderSwitchMode then return end
		local isGenderRestored = restorePlayerGenderRecords()
		if sceneState.shouldChangeGender then
			local currTime = os.clock()
			local diff = sceneState.changeGenderTime - currTime
			if diff < 1 then
				sceneState.changeGenderTime = currTime + 0.5
			end
		else
			sceneState.shouldChangeGender = true
			sceneState.changeGenderTime = os.clock() + 0.5
		end
	end)

	local lookedWidgetName = 'Base Window';
	local n_inkCompoundWidget = n"inkCompoundWidget"
	function getTopWiget(widget);
		if type(widget) ~= 'userdata' then return end;
		local nextTopWidget = widget;
		local loopBreaker = 20;
		while IsDefined(nextTopWidget) and nextTopWidget:IsA(n_inkCompoundWidget) do;
			loopBreaker = loopBreaker - 1
			if loopBreaker < 1 then return end;
			nextTopWidget = nextTopWidget.parentWidget;
			if nextTopWidget then widget = nextTopWidget end;
		end;
		return widget;
	end;

	local n_gameuiWidgetGameController = n"gameuiWidgetGameController"
	function getHudMainWindowWidgetByController(this, saveWidgetOnly);
		if type(this) ~= 'userdata' then return end;
		if not IsDefined(this) then return end;
		if not this:IsA(n_gameuiWidgetGameController) then return end;
		local widget = this:GetRootCompoundWidget();
		if not widget then return end;
		local topWidget = getTopWiget(widget);
		if not topWidget then return end;
		if topWidget.name.value ~= lookedWidgetName then return end;
		if not saveWidgetOnly then lastHudController = RefWeak(this) end
		mainHudWindowWidget = RefWeak(topWidget);
		return topWidget;
	end;

	if not Codeware then
		local n_gameuiHUDGameController = n"gameuiHUDGameController"
		Observe('CrouchIndicatorGameController', 'OnPlayerAttach', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		Observe('CrouchIndicatorGameController', 'OnPSMLocomotionStateChanged', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		Observe('gameuiCrosshairContainerController', 'OnSceneTierChange', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		Observe('PhoneHotkeyController', 'OnDpadActionPerformed', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		Observe('inkGameController', 'PlaySound', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		if inkHUDGameController.ToggleVisibility then
			Observe('inkHUDGameController', 'ToggleVisibility', function(this);
				if isCodewareActive then return end
				if not this:IsA(n_gameuiHUDGameController) then return end
				getHudMainWindowWidgetByController(this);
			end);
		end
		Observe('inkGameController', 'GetUIBlackboard', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
		Observe('inkGameController', 'GetPSMBlackboard', function(this);
			if isCodewareActive then return end
			if not this:IsA(n_gameuiHUDGameController) then return end
			getHudMainWindowWidgetByController(this);
		end);
	end

	if isGameV2 then
		Override("TutorialPopupGameController", "OnInitialize", function(this, wrapped)
			local result, isInScene = pcall(function() return isPlayerInManagedScene() end)
			if not result then return wrapped() end
			if not isInScene then return wrapped() end
			this:RequestVisualState();
			this.data = this:GetRootWidget():GetUserData("TutorialPopupData");
			this.data.pauseGame = false;
			this.targetPosition = this.data.position;
			if this.data.closeAtInput then this:BlockInput(true) end
			this:SetupView();
			this:GetRootWidget():SetVisible(false);
			this.animationProxy:UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
			this:PlaySound("GameMenu", "OnClose");
			this.data.token:TriggerCallback(this.data);
			if this.inputBlocked then
			  this:BlockInput(false);
			end
		end)
		ObserveAfter("TutorialPopupGameController", "OnIntro", function(this)
			local result, isInScene = pcall(function() return isPlayerInManagedScene() end)
			if not result then return end
			if not isInScene then return end
			if not this.animationProxy then
				this.animationProxy:UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
				this.animationProxy:Stop();
				this.animationProxy = nil;
			end;
			this.animationProxy = this:PlayLibraryAnimationOnAutoSelectedTargets(this.animOutro, inkWidgetRef.Get(this.targetPopup));
			this.animationProxy:RegisterToCallback(inkanimEventType.OnFinish, this, "OnOutro");
			this:PlaySound("GameMenu", "OnClose");
		end)
	end
end

function testWarningMessage(line1, line2)
	if type(line1) ~= 'string' or stringLen(line1) < 1 then print("Invalid input") return end
	if not GetPlayer then print('Cannot send messages at the moment') return end
	if not GetPlayer() then print('Cannot send messages at the moment') return end
	if not isStringValid(line1) then print("Invalid input") return end
	if isGamePaused() then print('Cannot send messages at the moment') return end
	if not isWorldStreaming() then print('Cannot send messages at the moment') return end

	if stringMatch(line1, "^playback.timeout") then sendWarningMessage(uiStrings.nuiUiStrings.onscreenWarnings.playback.timeout, 5, true) return end
	if stringMatch(line1, "^hotscenesUnavailable") then
		if stringMatch(line1, "header$") then
			sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.header, 5, true) return
		else
			for key, string in pairs(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable) do
				if key ~= "header" then
					if stringMatch(line1, key) then sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.header.."\n"..nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable[key], 5, true) return end
				end
			end
			sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.header.."\n".."Could not find this entry.", 5, true) return
		end
	end
	if line1 == 'actionUnavailable.header' then sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.header, 5, true) return end
	if stringMatch(line1, "^actionUnavailable") then
		if stringMatch(line1, "header$") then
			sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.header, 5, true) return
		else
			for key, string in pairs(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable) do
				if key ~= "header" then
					if stringMatch(line1, key) then sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.header.."\n"..nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable[key], 5, true) return end
				end
			end
			sendWarningMessage(nativeUI.uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.header.."\n".."Could not find this entry.", 5, true) return
		end
	end

	local msg = line1
	if type(line2) == 'string' and stringLen(line2) > 1 then msg = msg.."\n"..line2 end

	sendWarningMessage(msg, 5, true)
end

-------------------------------------------------------
resultByKeyNum, resultByKeyName = {}, {}
keyNum = 0 keyName = "ok" keyDesc = "OK" resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1 keyName = "feature_name_string_invalid" keyDesc = "Invalid featureName string." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -2 keyName = "scene_spec_invalid" keyDesc = "Scene specification data is missing or invalid." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -3 keyName = "appearance_name_string_invalid" keyDesc = "Scene performer appearance name string is invalid." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -4 keyName = "gender_name_string_invalid" keyDesc = "Scene performer gender name is missing or invalid" resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -5 keyName = "nude_appearance_name_string_invalid" keyDesc = "Scene performer nude appearance name string is invalid." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -6 keyName = "performer_ent_path_invalid" keyDesc = "Scene performer entity template path is missing or invalid." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -100 keyName = "player_not_found" keyDesc = "Player is currently not attached." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -101 keyName = "player_not_in_game_session" keyDesc = "Player is not in game session." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -110 keyName = "game_paused_or_in_menu" keyDesc = "Game paused or in menu." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -120 keyName = "is_prologue_or_ending" keyDesc = "Custom scene playback is not allowed in Prologue or Engings." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -130 keyName = "isSavingLocked" keyDesc = "Game saving is currently prohibited." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -131 keyName = "inWorkspot" keyDesc = "Player is in a workspot." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -132 keyName = "isInDeviceControl" keyDesc = "Player is controlling a device." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -133 keyName = "inVehicle" keyDesc = "Player is in a vehicle." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -134 keyName = "inCombat" keyDesc = "Player is in combat." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -135 keyName = "isWanted" keyDesc = "Player is pursued." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -136 keyName = "inRestrictedArea" keyDesc = "Player is in a dangerous or restricted area." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -137 keyName = "isInCall" keyDesc = "Player is a call." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -138 keyName = "isScanning" keyDesc = "Player is scanning." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -139 keyName = "isRestrictedState" keyDesc = "Player activity is limited by game restrictions." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -140 keyName = "isBraindance" keyDesc = "Player is a braindance." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -141 keyName = "isFastTravel" keyDesc = "Player is in Fast Travel." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -150 keyName = "isJohnnyReplacer" keyDesc = "Player is replaced by Johnny." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -151 keyName = "isPlayerPossessedByJohnny" keyDesc = "Player is possessed by Johhny." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -199 keyName = "unknown_gameplay_condition" keyDesc = "Some uknown game state preventing custom scene playback." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -200 keyName = "is_censored" keyDesc = "Nudity censorship is enabled in the game settings." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -300 keyName = "feature_not_found" keyDesc = "Feature not found." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -310 keyName = "feature_not_loaded" keyDesc = "Feature is currently not loaded." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -311 keyName = "feature_locked" keyDesc = "Feature is currently locked." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -320 keyName = "inScene" keyDesc = "Player is currently busy in a game scene." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -321 keyName = "is_any_hotscene_playing" keyDesc = "Hotscenes is currently busy playing a scene." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -322 keyName = "isHangoutsScene" keyDesc = "Hotscenes Add-on is currently busy playing a scene." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -400 keyName = "main_archive_not_detected" keyDesc = "Hotscenes mod archive file is not detected." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -410 keyName = "add_on_archive_not_detected" keyDesc = "Hotscenes Add-on is not detected." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -420 keyName = "custom_trigger_quest_not_detected" keyDesc = "Hotscenes custom scene playback support is not detected." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -430 keyName = "custom_trigger_quest_not_active" keyDesc = "Hotscenes custom scene playback support is not active." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -431 keyName = "ncd_trigger_quest_not_active" keyDesc = "Night City Delights custom scene playback is not active." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -900 keyName = "main_mod_not_initialized" keyDesc = "Hotscenes mod is not initialized." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -910 keyName = "nc_delights_not_initialized" keyDesc = "Night City Delights feature is not initialized." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -920 keyName = "game_framework_not_available" keyDesc = "Game framework is not available." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -998 keyName = "unknown_key_name" keyDesc = "Unhandled exception" resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1000 keyName = "isModDisabled" keyDesc = "Hotscenes mod is disabled." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1010 keyName = "unsupported_game_version" keyDesc = "Unsupported game version. Only games 2.1 or higher are supported." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1011 keyName = "archive_xl_missing" keyDesc = "Archive-XL is not avaliable." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1020 keyName = "nc_delights_missing" keyDesc = "Night City Delights feature extension module is not available." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1021 keyName = "nc_delights_is_disabled" keyDesc = "Night City Delights feature extension is disabled." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1022 keyName = "nc_delights_api_missing" keyDesc = "Night City Delights feature extension API is not avaiable." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]
keyNum = -1030 keyName = "unsupported_add_on" keyDesc = "Unsupported Hotscenes Add-on detected." resultByKeyNum[keyNum] = {keyNum = keyNum, keyName = keyName, keyDesc = keyDesc} resultByKeyName[keyName] = resultByKeyNum[keyNum]

function getResultByKeyNum(keyNum)
	if not resultByKeyNum then return -999, "Unknown exception" end
	if type(keyNum) ~= 'number' then keyNum = -998 end
	local rec = resultByKeyNum[keyNum]
	if not rec then return -999, "Unknown exception" end
	return rec.keyNum, rec.keyDesc
end

function getResultByKeyName(keyName)
	if not resultByKeyName then return -999, "Unknown exception" end
	if not isStringValid(keyName) then keyName = "unknown_key_name" end
	local rec = resultByKeyName[keyName]
	if not rec then return -999, "Unknown exception" end
	return rec.keyNum, rec.keyDesc
end

function getNcdApi()
	if not isGameV21 then return nil, getResultByKeyName("unsupported_game_version") end
	if not isArchiveDetected then return nil, getResultByKeyName("archive_xl_missing") end
	if type(nc_delights) ~= 'table' then return nil, getResultByKeyName("nc_delights_missing") end
	local ncdApi = nc_delights.ncdApi
	if type(ncdApi) ~= 'table' then return nil, getResultByKeyName("nc_delights_api_missing") end
	return ncdApi, getResultByKeyName("ok")
end
function getNCD(verbose)
	local handle, exitCode, exitDesc = getNcdApi()
	if verbose then print(modName..":", "getNCD() result:",  tostring(handle), exitCode, exitDesc) end
	return handle, exitCode, exitDesc
end

return {modName = modName, modVer = modVer, modAuthorName = modAuthorName, loadJsonTable = loadJsonTable, saveJsonTable = saveJsonTable, testWarningMessage = testWarningMessage, setCinematicMode = setCinematicMode, getCinematicMode = getCinematicMode, deactivateAddon = deactivateAddon, getNCD = getNCD}