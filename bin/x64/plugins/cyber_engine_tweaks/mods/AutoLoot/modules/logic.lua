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
You may use parts of the code or any original algorithms developed for this mod in your own creations only with my prior consent and proper credit.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

-- THIS MODULE DOES NOT SUPPORT TRANSLATIONS IN IT'S CURRENT SHAPE

-- Sep 4, 2026 based on the (c)keanuWheeze original script modified by (c)anygoodname by the keanuWheeze consent
-- Uses (c)psiberx code snippets and libraries on his license.


logic = {
			modVer = 'v3.11.0',
			moduleVer = 'v3.11.0',
			modName = 'Autoloot',
			modAuthorName = 'keanuWheeze and anygoodname',
			lastLootCompletedTime = 0,
			isPlayerInWorkspot = false, isLootDialogOnScreen = false, isAnyDialogOnScreen = false, isAnyOtherInteractonOnScreen = false, cooldown = 0,
			isInitialized = false,
		}

local Ref = require('lib/Ref')
if not Ref then return end

local jmels = require('modules/jmels')
if not jmels then return end
if not jmels.isLs then return end

local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

local lastLootingController, isLootDialogOnScreen, isAnyDialogOnScreen, isAnyOtherInteractonOnScreen, cooldown
local lastPhoneMessagePopupGameController, lastLoadingScreenProgressBarController, lastTutorialMainController
local lastInteractionUIBase
local lastCursorDeviceGameController, lastTerminalInteractionActive = nil, false
local lastTakedownTarget, lastTakedownTargetPos
local lastLootedTakedownCooldownName = "mod_autoloot_last_looted_takedown_cooldown"
local objectMappins = {}
local objectMappinsCount = 0
local worldMappins = {}
local allJournalQuestEntries = {}
local allJournalQuestEntriesHashLookup
local allJournalQuestEntriesIdLookup
local customLootMappins = {}
local collectedPoiMappins
local lastDialogWidgetGameController = nil
local isGameV2 = cetVer >= 1.26
local protectKeyCards = true
local questsSystem
local n, t
local journalManager, workspotSystem, transactionSystem, gameBlackBoardSystem, allBlackboardDefs, targetingSystem, cameraSystem, spatialQueriesSystem, audioSystem, timeSystem, mappinSystem, statsSystem, aINavigationSystem
local allBlackboardDefsUI_System, allBlackboardDefsUI_SystemIsInMenu, allBlackboardDefsUIInteractions, allBlackboardDefsUIInteractionsDialogChoiceHubs
local allBlackboardDefsUI_Scanner, allBlackboardDefsUI_ScannerScannerMode, allBlackboardDefsBraindance, allBlackboardDefsBraindanceIsActive
local allBlackboardDefsFastTRavelSystem, allBlackboardDefsFastTRavelSystemFastTravelLoadingScreenFinished, allBlackboardDefsFastTRavelSystemDestinationPoint
local allBlackboardDefsPlayerStateMachine, allBlackboardDefsPlayerStateMachineIsUIZoomDevice, allBlackboardDefsPlayerStateMachineIsControllingDevice
local allBlackboardDefsPhotoMode, allBlackboardDefsPhotoModeIsActive
local gamemappinsMappinTargetTypeWorld
local lootableClasses
local n_ScriptedPuppet = "ScriptedPuppet"
local n_UI_Slots = "UI_Slots"
local n_GameplayRole = "GameplayRole"
local n_gameLootContainerBase = "gameLootContainerBase"
local n_gameContainerObjectBase = "gameContainerObjectBase"
local n_ShardCaseContainer = "ShardCaseContainer"
local n_gameItemDropObject = "gameItemDropObject"
local n_gameweaponObject = "gameweaponObject"
local n_gameJournalFolderEntry = "gameJournalFolderEntry"
local n_LootContainerObjectAnimatedByTransform = "LootContainerObjectAnimatedByTransform"
local n_NPCPuppet = "NPCPuppet"
local n_gameObject = "gameObject"
local GameFindEntityByID
local GameGetSystemRequestsHandler
local GameGetSenseManager
local RPGManagerGetItemType
local ItemIDFromTDBID
local gamedataItemTypeGen_Keycard
local lootTables
local lootResult = {
	generalFailure = -4,
	allItemsFailed = -3,
	notLootObject = -2,
	protectedObject = -1,
	nothingToLoot = 0,
	partialLoot = 1,
	allLooted = 2
	}
local n_FlareOwner
local isSameInstance
local gamedataItemTypeWea_HeavyMachineGun
local TweakDBInterfaceGetString
local TweakDBInterfaceGetItemRecord
local MatrixGetTranslation

local IsDefinedS = function(gameObj)
	local result, val
	result, val = pcall(function() return IsDefined(gameObj) end)
	if result then return val else return false end
end

local function findEntityByIdOrHashStr(idOrHashStr)
	if type(idOrHashStr) == 'userdata' then return GameFindEntityByID(idOrHashStr) end
	if type(idOrHashStr) ~= 'string' then return end
	local result, data = pcall(function() return GameFindEntityByID(entEntityID.new({ hash = loadstring('return ' .. idOrHashStr, '')() })) end)
	if not result then return end
	return data
end

local RefWeak = Ref.Weak
function logic.init()
	if logic.isInitialized then return end
	if isGameV2 then IsDefinedS = IsDefined end
	n = CName
	t = TweakDBID.new
	questsSystem = RefWeak(Game.GetQuestsSystem())
	journalManager = RefWeak(Game.GetJournalManager())
	workspotSystem = RefWeak(Game.GetWorkspotSystem())
	transactionSystem = RefWeak(Game.GetTransactionSystem())
	gameBlackBoardSystem = RefWeak(Game.GetBlackboardSystem())
	allBlackboardDefs = RefWeak(Game.GetAllBlackboardDefs())
	targetingSystem = RefWeak(Game.GetTargetingSystem())
	cameraSystem = RefWeak(Game.GetCameraSystem())
	spatialQueriesSystem = RefWeak(Game.GetSpatialQueriesSystem())
	audioSystem = RefWeak(Game.GetAudioSystem())
	timeSystem = RefWeak(Game.GetTimeSystem())
	mappinSystem = RefWeak(Game.GetMappinSystem())
	statsSystem = RefWeak(Game.GetStatsSystem())
	aINavigationSystem = RefWeak(Game.GetAINavigationSystem())
	n_ScriptedPuppet = n"ScriptedPuppet"
	n_UI_Slots = n"UI_Slots"
	n_GameplayRole = n"GameplayRole"
	lastLootedTakedownCooldownName = n(lastLootedTakedownCooldownName)
	allBlackboardDefsUI_System = allBlackboardDefs.UI_System
	allBlackboardDefsUI_SystemIsInMenu = allBlackboardDefs.UI_System.IsInMenu
	allBlackboardDefsUIInteractions = allBlackboardDefs.UIInteractions
	allBlackboardDefsUIInteractionsDialogChoiceHubs = allBlackboardDefs.UIInteractions.DialogChoiceHubs
	allBlackboardDefsUI_Scanner = allBlackboardDefs.UI_Scanner
	allBlackboardDefsUI_ScannerScannerMode = allBlackboardDefs.UI_Scanner.ScannerMode
	allBlackboardDefsBraindance = allBlackboardDefs.Braindance
	allBlackboardDefsBraindanceIsActive = allBlackboardDefs.Braindance.IsActive
	allBlackboardDefsFastTRavelSystem = allBlackboardDefs.FastTRavelSystem
	allBlackboardDefsFastTRavelSystemFastTravelLoadingScreenFinished = allBlackboardDefs.FastTRavelSystem.FastTravelLoadingScreenFinished
	allBlackboardDefsFastTRavelSystemDestinationPoint = allBlackboardDefs.FastTRavelSystem.DestinationPoint
	allBlackboardDefsPlayerStateMachine = allBlackboardDefs.PlayerStateMachine
	allBlackboardDefsPlayerStateMachineIsUIZoomDevice = allBlackboardDefs.PlayerStateMachine.IsUIZoomDevice
	allBlackboardDefsPlayerStateMachineIsControllingDevice = allBlackboardDefs.PlayerStateMachine.IsControllingDevice
	allBlackboardDefsPhotoMode = allBlackboardDefs.PhotoMode
	allBlackboardDefsPhotoModeIsActive = allBlackboardDefs.PhotoMode.IsActive
	gamemappinsMappinTargetTypeWorld = gamemappinsMappinTargetType.World
	n_gameLootContainerBase = "gameLootContainerBase"
	n_gameContainerObjectBase = n"gameContainerObjectBase"
	n_ShardCaseContainer = n"ShardCaseContainer"
	n_gameItemDropObject = n"gameItemDropObject"
	n_gameweaponObject = n"gameweaponObject"
	n_gameJournalFolderEntry = n"gameJournalFolderEntry"
	n_LootContainerObjectAnimatedByTransform = n"LootContainerObjectAnimatedByTransform"
	n_NPCPuppet = n"NPCPuppet"
	n_gameObject = n"gameObject"
	GameFindEntityByID = Game.FindEntityByID
	GameGetSystemRequestsHandler = Game.GetSystemRequestsHandler
	GameGetSenseManager = Game.GetSenseManager
	RPGManagerGetItemType = RPGManager.GetItemType
	ItemIDFromTDBID = ItemID.FromTDBID
	gamedataItemTypeGen_Keycard = gamedataItemType.Gen_Keycard
	Vector4new = Vector4.new
	gamedataItemTypeWea_HeavyMachineGun = gamedataItemType.Wea_HeavyMachineGun
	isSameInstance = Game['OperatorEqual;IScriptableIScriptable;Bool'] -- (c)keanuWheeze
	TweakDBInterfaceGetString = TweakDBInterface.GetString
	TweakDBInterfaceGetItemRecord = TweakDBInterface.GetItemRecord
	MatrixGetTranslation = Matrix.GetTranslation
	for i = 1, #lootableClasses do lootableClasses[i] = CName.new(lootableClasses[i]) end
	logic.resetVariables()
	setObservers()
	if jmels then jmels.init() end
	logic.isInitialized = true
end

function logic.resetVariables()
	lastLootingController = nil
	logic.isPlayerInWorkspot = false
	logic.isLootDialogOnScreen = false
	logic.isAnyDialogOnScreen = false
	logic.isAnyOtherInteractonOnScreen = false
	logic.cooldown = 0
	objectMappins = {}
	objectMappinsCount = 0
	customLootMappins = {}
	collectedPoiMappins = nil
	lastCursorDeviceGameController = nil
	lastTerminalInteractionActive = false
	lastTakedownTarget = nil
	lastTakedownTargetPos = nil
end

function logic.isInSettingsMenu()
	if not GetPlayer then return end
	local result, blackboardSystem = pcall(function() return gameBlackBoardSystem:Get(allBlackboardDefsUI_System) end)
	if not result then return true end
	if not IsDefinedS(blackboardSystem) then return true end
	if not blackboardSystem:GetBool(allBlackboardDefsUI_SystemIsInMenu) then return end
	return logic.isMenuScenario_Settings
end

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
local function isValidVector4(input)
	if type(input) ~= 'userdata' then return false end
	if type(input.IsZero) ~= 'function' then return false end
	if input.x ~= 0 then return true end
	if input.y ~= 0 then return true end
	if input.z ~= 0 then return true end
end
local function isValidVector34Unsafe(input)
	if input.x ~= 0 then return true end
	if input.y ~= 0 then return true end
	if input.z ~= 0 then return true end
end
local function isScriptedPuppetUnsafe(this)
	return type(this.skipDeathAnimation) == 'boolean'
end
local mathFloor = math.floor
local mathAbs = math.abs
local tableInsert = table.insert
local stringMatch = string.match
local stringFind = string.find

local savelockTimeout = 0
local isGameV23
local psilcLookup = {}
local psiLookup = {}
local psnpcsLookup  = {}
function setObservers()
	if logic.isInitialized then return end
	isGameV23 = type(mappinSystem.GetMappinEntries) == 'function'

	ObserveAfter('inkMenuScenario', 'SwitchToScenario', function(this, name)
		logic.isMenuScenario_Settings = false
		if name.value == 'MenuScenario_Settings' then logic.isMenuScenario_Settings = true end
	end)

	if isGameV2 then
		local vars = {gamedataMappinVariant.FocusClueVariant, gamedataMappinVariant.HiddenStashVariant, gamedataMappinVariant.ImportantInteractionVariant, gamedataMappinVariant.MinorActivityVariant, gamedataMappinVariant.Zzz07_PlayerStashVariant, gamedataMappinVariant.Zzz08_WardrobeVariant, gamedataMappinVariant.Zzz12_WorldEncounterVariant}
		local varLookup = {}
		for _, var in ipairs(vars) do varLookup[tostring(var):sub(-5)] = true end
		ObserveAfter("WorldMappinsContainerController", "CreateMappinUIProfile", function(this, mappin, mappinVariant, customData);
			if not (mappin:IsQuestMappin() or mappin:IsQuestImportant() or varLookup[tostring(mappinVariant):sub(-5)]) then return end;
			local position = mappin:GetWorldPosition();
			if not isValidVector34Unsafe(position) then return end
			local mappinId = tostring(position.x)..tostring(position.y)..tostring(position.z);
			collectedPoiMappins = collectedPoiMappins or {}
			local k = mathFloor(position.x)
			local entry = {mappin = RefWeak(mappin), position = position, mappinVariant = mappinVariant};
			for kn = k - 1, k + 1 do
				local slot = collectedPoiMappins[kn]
				if not slot then slot = {} collectedPoiMappins[kn] = slot end
				slot[mappinId] = entry
			end
		end);
	end

	Observe('LoadingScreenProgressBarController', 'SetProgress', function(self) lastLoadingScreenProgressBarController = RefWeak(self) end)
	Observe('TutorialMainController', 'OnInitialize', function(self) lastTutorialMainController = RefWeak(self) end)
	Observe('TutorialMainController', 'StartTutorial', function(self) lastTutorialMainController = RefWeak(self) end)
	Observe('TutorialMainController', 'UpdateTutorialStep', function(self) lastTutorialMainController = RefWeak(self) end)

	if modAutolootRedsHelper then
		local isSupportedVersion = false
		if type(modAutolootRedsHelper.GetVersion) == 'function' then
			local helperVerStr = modAutolootRedsHelper.GetVersion()
			if type(helperVerStr) == 'string' then
				local helperVer = tonumber((helperVerStr:gsub('^(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- based on psiberx code
					return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
				end)))
				if helperVer >= 3.0117 then
					logic.shouldUseRedsHelper = true
					isSupportedVersion = true
					print(logic.modName, logic.modVer, 'Redscript helper plug-in found:', helperVerStr)
				else
					print(logic.modName, logic.modVer, 'Outdated redscript helper plug-in version found:', helperVerStr, 'The plugin will not be used.')
				end
			else
				print(logic.modName, logic.modVer, 'Unknown redscript helper plug-in found. The plugin will not be used.')
			end
		else
			print(logic.modName, logic.modVer, 'Outdated redscript helper plug-in found. The plugin will not be used.')
		end
		local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
			return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
		end)))
		if cetVer >= 1.21 then
			logic.shouldUseRedsHelper = false
			if not isSupportedVersion then
				print(logic.modName, logic.modVer, 'The redscript helper plug-in is no longer needed in this game version so you can ignore the plug-in warning.')
			else
				print(logic.modName, logic.modVer, 'The redscript helper plug-in will not be used as it is no longer needed in this game version.')
			end
		end
	end
	n_FlareOwner = CName.new(2600367073, 1948017399)
	if logic.shouldUseRedsHelper then
		Observe('modAutolootRedsHelper', 'LastPhoneMessagePopupGameController;PhoneMessagePopupGameController', function(this)
			if IsDefinedS(self) then lastPhoneMessagePopupGameController = RefWeak(this) end
		end)

		Observe('modAutolootRedsHelper', 'LastDialogWidgetGameController;dialogWidgetGameControllerInt32', function(this, hubsCount)
			lastDialogWidgetGameController = RefWeak(this)
			logic.isAnyDialogOnScreen = hubsCount > 0
			if hubsCount < 1 then
				logic.lastHubCountReset = os.clock()
			end
		end)

		Observe('modAutolootRedsHelper', 'LastInteractionUIBase;InteractionUIBase', function(this)
			lastInteractionUIBase = RefWeak(this)
		end)

		Observe('modAutolootRedsHelper', 'LastCursorDeviceGameController;cursorDeviceGameControllerVariant', function(this, value)
			lastCursorDeviceGameController = RefWeak(this)
			local v = FromVariant(value)
			if not v then lastTerminalInteractionActive = false return end
			lastTerminalInteractionActive = v.terminalInteractionActive
			logic.isNativeHubLeftoverActive = false
		end)

		Observe('modAutolootRedsHelper', 'LastLootingController;LootingControllerBool', function(this, isShow)
			lastLootingController = RefWeak(this)
			logic.isLootDialogOnScreen = isShow
			if isShow then logic.isNativeHubLeftoverActive = false end
		end)

		Observe('modAutolootRedsHelper', 'AddToObjectMappins;GameObjectIScriptableBool', function(owner, mappinObjectRef, forceNew)
			addToObjectMappins(RefWeak(owner), RefWeak(mappinObjectRef), forceNew)
		end)
	else
		Observe('PhoneMessagePopupGameController', 'OnInitialize', function(self) if IsDefinedS(self) then lastPhoneMessagePopupGameController = RefWeak(self) end end)

		ObserveAfter("dialogWidgetGameController", "OnDialogsActivateHub", function(this);
			lastDialogWidgetGameController = RefWeak(this)
			logic.isAnyDialogOnScreen = this.hubAvailable
			if not this.hubAvailable then logic.lastHubCountReset = os.clock() end
		end);

		Observe('dialogWidgetGameController', 'AdjustHubsCount', function(this, evt)
			lastDialogWidgetGameController = RefWeak(this)
			logic.isAnyDialogOnScreen = evt > 0
			if evt < 1 then logic.lastHubCountReset = os.clock() end
		end)

		ObserveAfter('InteractionUIBase', 'OnInitialize', function(self);
			lastInteractionUIBase = RefWeak(self)
		end)

		ObserveAfter('InteractionUIBase', 'OnDialogsActivateHub', function(self);
			lastInteractionUIBase = RefWeak(self)
		end)

		Observe('cursorDeviceGameController', 'OnInteractionStateChange', function(this, value)
			lastCursorDeviceGameController = RefWeak(this)
			local v = FromVariant(value)
			if not v then lastTerminalInteractionActive = false return end
			lastTerminalInteractionActive = v.terminalInteractionActive
			logic.isNativeHubLeftoverActive = false
		end)

		Observe('LootingController', 'Show', function(self)
			lastLootingController = RefWeak(self)
			logic.isLootDialogOnScreen = true
			logic.isNativeHubLeftoverActive = false
		end)

		Observe('LootingController', 'Hide', function(self)
			logic.isLootDialogOnScreen = false
			lastLootingController = RefWeak(self)
		end)

		ObserveAfter('gameItemDropObject', 'OnItemEntitySpawned', function(self)
			addToObjectMappins(RefWeak(self), nil)
		end)

		Observe('GameplayRoleComponent', 'CreateRoleMappinData', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self), true)
		end)

		ObserveAfter('GameplayRoleComponent', 'OnLogicReady', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self))
		end)

		Observe('GameplayRoleComponent', 'ShowRoleMappinsByTask', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self))
		end)

		ObserveAfter('GameplayRoleComponent', 'ShowRoleMappins', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self))
		end)

		Observe('GameplayRoleComponent', 'SetForceHidden', function(self, isHidden)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self), (self.isForceHidden and not isHidden))
		end)

		ObserveAfter('GameplayRoleComponent', 'OnGameAttach', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self), true)
		end)

		ObserveAfter('GameplayRoleComponent', 'OnHUDInstruction', function(self)
			local owner = RefWeak(self:GetOwner())
			addToObjectMappins(owner, RefWeak(self), true)
		end)
	end

	ObserveAfter("gameLootContainerBase", "OnInventoryFilledEvent", function(this)
		if not this:IsA(n_gameLootContainerBase) then return end;
		addToObjectMappins(RefWeak(this), this:FindComponentByName(n_GameplayRole))
	end);
	ObserveAfter("gameLootContainerBase", "OnInventoryChangedEvent", function(this)
		if not this:IsA(n_gameLootContainerBase) then return end;
		addToObjectMappins(RefWeak(this), this:FindComponentByName(n_GameplayRole))
	end);
	Observe('gameInventoryScriptCallback', 'OnItemAdded', function()
		if not logic.isLootingTime() then return end
		hideLootMarkers()
	end)

	local lookForLeftovers = true
	Observe('PlayerPuppet', 'OnGameAttached', function(self)
		if self:IsReplacer() then return end
		questsSystem = RefWeak(Game.GetQuestsSystem())
		journalManager = RefWeak(Game.GetJournalManager())
		workspotSystem = RefWeak(Game.GetWorkspotSystem())
		transactionSystem = RefWeak(Game.GetTransactionSystem())
		gameBlackBoardSystem = RefWeak(Game.GetBlackboardSystem())
		allBlackboardDefs = RefWeak(Game.GetAllBlackboardDefs())
		targetingSystem = RefWeak(Game.GetTargetingSystem())
		cameraSystem = RefWeak(Game.GetCameraSystem())
		spatialQueriesSystem = RefWeak(Game.GetSpatialQueriesSystem())
		audioSystem = RefWeak(Game.GetAudioSystem())
		timeSystem = RefWeak(Game.GetTimeSystem())
		mappinSystem = RefWeak(Game.GetMappinSystem())
		statsSystem = RefWeak(Game.GetStatsSystem())
		aINavigationSystem = RefWeak(Game.GetAINavigationSystem())
		if logic.settings and type(logic.config) == 'table' and type(logic.config.loadConfig) == 'function' then
			local newSettings = logic.config.loadConfig("config/config.json", logic.settings)
			if type(newSettings) == 'table' then
				for k, v in pairs(newSettings) do logic.settings[k] = v end
			end
		end
		logic.isNativeHubLeftoverActive = false
		lookForLeftovers = true
		if logic.resetAutoLootStates then logic.resetAutoLootStates() end
		logic.resetVariables()
	end)

	Observe('PlayerPuppet', 'OnMakePlayerVisibleAfterSpawn', function (this)
		lookForLeftovers = false
		if type(allJournalQuestEntries) == 'table' and #allJournalQuestEntries > 0 then return end
		allJournalQuestEntries, allJournalQuestEntriesHashLookup, allJournalQuestEntriesIdLookup = jmels.getAllJournalQuestEntries(true)
	end)

	Observe('interactionWidgetGameController', 'OnUpdateInteraction', function(this, argValue);
		if not lookForLeftovers then return end
		if not this.root then return end;
		local data = FromVariant(argValue);
		if not data.active then return end;
		logic.isNativeHubLeftoverActive = true
		lookForLeftovers = false
	end)
	
	ObserveAfter('InteractionUIBase', 'OnInteractionData', function(this)
		lastInteractionUIBase = RefWeak(this)
		logic.isNativeHubLeftoverActive = false
	end)

	local takedownActions = {n"Takedown", n"TakedownNonLethal", n"TakedownNetrunner", n"TakedownMassiveTarget", n"AerialTakedown", n"BossTakedown", n"LeapToTarget"}
	ObserveAfter("gamestateMachineComponent", "OnStartTakedownEvent", function(this, startTakedownEvent)
		if not logic.settings.enableTakedownLoot then return end
		local actionName = startTakedownEvent.actionName
		for i = 1, #takedownActions do
			if actionName == takedownActions[i] then
				lastTakedownTarget = RefWeak(startTakedownEvent.target)
				return
			end
		end
	end)
	ObserveAfter("NPCPuppet", "OnAfterDeathOrDefeat", function(this, evt)
		if not logic.settings.enableTakedownLoot then return end
		if not lastTakedownTarget then return end
		if not IsDefined(lastTakedownTarget) then lastTakedownTarget = nil return end
		if not isSameInstance(this, lastTakedownTarget) then return end
		lastTakedownTarget = nil
		local player = GetPlayer()
		if isPlayerSpecialMode(player) then return end
		if isExcludedSpecialQuestCase(player) then return end
		if isTutorial() then return end
		if isPlayerInBraindance() then return end
		lootNpc(this, true)
		lastTakedownTargetPos = this:GetWorldPosition()
		player:StartCooldown(lastLootedTakedownCooldownName, 3)
	end);
	ObserveAfter("NPCPuppet", "OnIncapacitated", function(this)
		if not logic.settings.enableTakedownLoot then return end
		if not lastTakedownTarget then return end
		if not IsDefined(lastTakedownTarget) then lastTakedownTarget = nil return end
		if not isSameInstance(this, lastTakedownTarget) then return end
		lastTakedownTarget = nil
		local player = GetPlayer()
		if isPlayerSpecialMode(player) then return end
		if isExcludedSpecialQuestCase(player) then return end
		if isTutorial() then return end
		if isPlayerInBraindance() then return end
		lootNpc(this, true)
		lastTakedownTargetPos = this:GetWorldPosition()
		player:StartCooldown(lastLootedTakedownCooldownName, 3)
	end)
	if gameAutoSaveSystem and gameAutoSaveSystem.RequestCheckpoint then
		local RPGManagerGetItemDataQuality = RPGManager.GetItemDataQuality
		local gamedataQualityLegendary = gamedataQuality.Legendary
		local gamedataQualityIconic = gamedataQuality.Iconic
		local ItemIDIsValid = ItemID.IsValid
		local shouldBlockAutosave = false
		ObserveBefore("PlayerPuppet", "OnItemAddedToInventory", function(this, evt)
			shouldBlockAutosave = false
			if os.clock() > savelockTimeout then return end
			if not ItemIDIsValid(evt.itemID) then return end
			local itemQuality = RPGManagerGetItemDataQuality(evt.itemData);
			if itemQuality == gamedataQualityLegendary or itemQuality == gamedataQualityIconic then
				shouldBlockAutosave = true
			end
		end)
		Override("gameAutoSaveSystem", "RequestCheckpoint", function(this, wrapped)
			if shouldBlockAutosave then
				shouldBlockAutosave = false
				return true
			end
			return wrapped()
		end)
	end
	local psilc = {
		{position = Vector4new(3739.2185, 818.25415, 135.05168, 1)},
		{position = Vector4new(-632.92017, 773.5254, 132.27121, 1)},
		{position = Vector4new(-1741.0364, -2352.3066, 32.136505, 1)},
		{position = Vector4new(-2034.3328, -2735.4219, 36.66288, 1)},
		{position = Vector4new(-1394.0176, -2036.0061, 75.7336, 1)},
		{position = Vector4new(-1434.1599, -2030.45, 74.83998, 1)},
		{position = Vector4new(-1397.3597, -2014.2797, 72.139984, 1)},
		{position = Vector4new(-1417.3597, -2081.31, 72.14998, 1)},
		{position = Vector4new(-1372.9598, -1932.09, 71.11998, 1)},
		{position = Vector4new(-2412.8733, -2662.6848, 13.127945, 1), fnid = 1},
		{position = Vector4new(-2413.4795, -2661.944, 12.942177, 1), fnid = 1},
		{position = Vector4new(-2413.816, -2661.3318, 12.942177, 1), fnid = 1},
		{position = Vector4new(-2413.4268, -2661.377, 13.230896, 1), fnid = 1},
		{position = Vector4new(-2413.1953, -2661.8281, 13.237434, 1), fnid = 1},
		{position = Vector4new(-2417.722, -2659.966, 13.014374, 1), fnid = 1},
		{position = Vector4new(-2418.1, -2659.8289, 13.286064, 1), fnid = 1},
		{position = Vector4new(-2420.0388, -2664.5303, 11.776367, 1), fnid = 1},
		{position = Vector4new(-2417.5742, -2659.9058, 12.392654, 1), fnid = 1},
		{position = Vector4new(-478.33173, 406.93695, 132.11, 1)},
		{position = Vector4new(503.6051, -2120.0166, 28.276344, 1)},
		{position = Vector4new(-839.5167, -1211.2963, 14.8156, 1)},
		{position = Vector4new(-1456.2885, 1302.081, 120.17897, 1)},
		{position = Vector4new(4692.993, -1441.75, 138.58606, 1)},
		{position = Vector4new(-1566.2014, 649.005, 15.8389, 1)},
		{position = Vector4new(2877.8606, -1592.84985, 76.8041916, 1)},
		{position = Vector4new(675.726074, -674.349121, 16.2861958, 1)},
		{position = Vector4new(263.431, -764.591, 6.847, 1)},
		{position = Vector4new(-1039.44141, 1708.42932, 29.1216831, 1)},
		{position = Vector4new(-1215.20081, 1950.85327, 26.0003033, 1)},
		{position = Vector4new(-1136.2057, 1778.5303, 31.469421, 1)},
		{position = Vector4new(-853.639587, 1801.32666, 19.8067589, 1)},
		{position = Vector4new(-1614.04797, 1806.89551, 24.9029427, 1)},
		{position = Vector4new(-1052.67822, 2400.71777, 19.3976631, 1)},
		{position = Vector4new(406.951782, -501.693817, 11.3189335, 1)},
		{position = Vector4new(674.74884, -408.919861, 5.99905968, 1)},
		{position = Vector4new(-54.9277, -230.392532, 1.60996699, 1)},
		{position = Vector4new(-296.682068, 1413.32861, 43.238018, 1)},
		{position = Vector4new(-452.216858, 612.444092, 36.0664558, 1)},
		{position = Vector4new(-372.323364, 723.620483, 75.027359, 1)},
		{position = Vector4new(-75.4922485, 1299.09094, 102.859947, 1)},
		{position = Vector4new(287.068176, 1507.13977, 169.760101, 1)},
		{position = Vector4new(-1195.9489, 2251.608, 8.916359, 1)},
		{position = Vector4new(-1302.8248, 1189.3608, 23.1997761, 1)},
		{position = Vector4new(-1168.2101, 905.38995, 27.549995, 1)},
		{position = Vector4new(-1709.4731, 1867.5315, 19.122116, 1)},
		{position = Vector4new(-1049.4647, 1454.9124, 13.116058, 1), rsq = 2.56},
		{position = Vector4new(-493.88083, 1975.6244, 42.42269, 1)},
		{position = Vector4new(-432.9797, 2129.6667, 36.16513, 1)},
		{position = Vector4new(-625.6879, 883.1511, 42.76226, 1)},
		{position = Vector4new(-373.14087, 1203.6898, 13.989601, 1)},
		{position = Vector4new(-100.90805, -284.42267, 9.422607, 1)},
		{position = Vector4new(-1615.9851, 2150.3777, 18.202858, 1), rsq = 0.04},
		{position = Vector4new(-1615.5306, 2149.4583, 18.2237, 1), lrsq = 25},
		{position = Vector4new(-1616.2726, 2150.5352, 18.2421, 1), lrsq = 25},
		{position = Vector4new(-1616.1088, 2150.7422, 18.2421), lrsq = 25},
		{position = Vector4new(-1770.4884, -1968.1843, 44.795013, 1)},
		{position = Vector4new(-1742.949, -1906.223, 70.952484, 1)},
		{position = Vector4new(-1875.1085, -1736.5297, 48.50255, 1)},
		{position = Vector4new(-2160.1414, -2244.1128, 13.117149, 1)},
		{position = Vector4new(-1964.2059, -927.05524, 9.13205, 1)},
		{position = Vector4new(-1940.489, -135.76848, 7.459999, 1)},
		{position = Vector4new(-1669.3307, -266.78326, -19.01876, 1)},
		{position = Vector4new(-1384.91, 1267.6389, 123.04184, 1), rsq = 0.01},
		{position = Vector4new(-972.6186, 2323.036, 30.563461, 1)},
		{position = Vector4new(-1382.6523, -57.026245, 31.13182, 1)},
		{position = Vector4new(-1693.5802, -1290.635, 42.23793, 1)},
		{position = Vector4new(-1123.1104, 141.46573, 5.663925, 1)},
		{position = Vector4new(-1386.0402, 1272.2473, 123.064865, 1)},
		{position = Vector4new(-2051.4092, 403.8506, 13.510597, 1)},
		{position = Vector4new(-2261.819, 568.259, 9.223999, 1), rsq = 0.01},
		{position = Vector4new(-2415.1897, 513.8322, 12.007507, 1)},
		{position = Vector4new(-520.906, 883.6918, 44.96933, 1)},
		{position = Vector4new(-452.22247, 852.9598, -2.2963104, 1)},
		{position = Vector4new(-2148.893, -1829.3643, 0.1640, 1)},
		{position = Vector4new(-2473.812, -1733.3911, -9.3833, 1)},
		{position = Vector4new(-2446.2822, -1974.3633, 0.8422, 1)},
		{position = Vector4new(-2465.3301, -2228.7341, 0.6997, 1)},
		{position = Vector4new(-2702.5166, -2458.8582, 26.7282, 1)},
		{position = Vector4new(-2427.0669, -2619.0559, 23.3230, 1)},
		{position = Vector4new(-2117.7983, -2185.7925, 20.0141, 1)},
		{position = Vector4new(-1931.4486, -1774.9374, 13.0426, 1)},
		{position = Vector4new(-2641.4119, -501.4602, 0.4446, 1)},
		{position = Vector4new(-2576.1924, -90.3963, -0.2905, 1)},
		{position = Vector4new(-2468.8047, -46.7388, -4.4135, 1)},
		{position = Vector4new(-2362.9146, 196.0951, 6.9556, 1)},
		{position = Vector4new(-1738.8634, 1495.5095, 13.7316, 1)},
		{position = Vector4new(-1746.4476, 1789.7584, 19.3069, 1)},
		{position = Vector4new(-243.2081, -114.6698, 11.72, 1)},
		{position = Vector4new(-1127.1313, 1217.0822, 1.4876, 1)},
		{position = Vector4new(-1953.6521, 998.8262, 1.0964, 1)},
		{position = Vector4new(203.2208, 864.4576, 162.9334, 1)},
		{position = Vector4new(682.0600, -1242.8900, 32.06, 1)},
		{position = Vector4new(-2519.8911, -1016.1610, 5.7875, 1)},
		{position = Vector4new(-2319.7136, -1017.2469, 1.1156, 1)},
		{position = Vector4new(-2300.1394, -1232.2592, 8.0284, 1)},
		{position = Vector4new(-2012.0745, -1166.6040, 11.1015, 1)},
		{position = Vector4new(-2055.3052, -1120.9332, 9.1577, 1)},
		{position = Vector4new(-2204.0693, -990.3285, 36.1764, 1)},
		{position = Vector4new(-1938.7109, -1251.4283, 14.52, 1)},
		{position = Vector4new(-1995.3492, -1239.3882, 14.4842, 1)},
		{position = Vector4new(-2103.7615, -1062.9275, 8, 1)},
		{position = Vector4new(-1114.1111, 1390.1373, 17.5332, 1)},
		{position = Vector4new(-1110.2646, 1413.1554, 21.8300, 1)},
		{position = Vector4new(-1951.5614, -1492.9012, -2.6300, 1), lrsq = 64},
		{position = Vector4new(-1950.1504, -1492.2498, -2.6500, 1), lrsq = 64},
		{position = Vector4new(-1949.8606, -1493.8397, -2.6600, 1), lrsq = 64},
		{position = Vector4new(-1139.842, -764.8146, 10.180, 1)},
		{position = Vector4new(-983.8510, -795.9907, 14.340, 1)},
		{position = Vector4new(-984.7286, -796.7344, 14.3400, 1)},
		{position = Vector4new(-983.4387, -794.8438, 14.3500, 1)},
		{position = Vector4new(-456.5740, 136.8406, 22.4348, 1)},
		{position = Vector4new(-1212.5983, 1955.5787, 26.4385, 1)},
		{position = Vector4new(-1224.7292, 1986.5303, 7.9652, 1)},
		{position = Vector4new(-964.0515, 2773.6570, 31.4491, 1)},
		{position = Vector4new(-1729.8513, 2509.5032, 48.0064, 1)},
		{position = Vector4new(-1023.1191, -1293.9503, 14.9311, 1)},
		{position = Vector4new(-470.6771, -943.8080, 20.8473, 1)},
		{position = Vector4new(-2365.7539, -2533.3997, 10.7927, 1)},
		{position = Vector4new(-251.1695, 1641.29, 34.0084, 1), rsq = 0.0225},
		{position = Vector4new(-353.5625, 1851.4565, 8.1779, 1)},
		{position = Vector4new(-368.9644, 1652.0402, 43.6947, 1)},
		{position = Vector4new(-278.8501, 681.0305, 67.1237, 1)},
		{position = Vector4new(-1732.7347, -825.7261, 15.8300, 1)},
		{position = Vector4new(-620.0097, 1629.3026, 1.1537, 1)},
		{position = Vector4new(-599.2238, 1308.6552, 50.7872, 1)},
		{position = Vector4new(-471.0303, 622.4241, 34.0784, 1)},
		{position = Vector4new(-405.6201, 449.5316, 26.1612, 1)},
		{position = Vector4new(-395.1245, 250.2202, 22.5933, 1)},
		{position = Vector4new(-395.1245, 250.2202, 22.5933, 1)},
		{position = Vector4new(-799.2815, 1281.1421, 47.6512, 1), rsq = 0.866},
		{position = Vector4new(351.9596, -366.8641, 6.5418, 1)},
		{position = Vector4new(406.9518, -501.6938, 11.3189, 1)},
		{position = Vector4new(668.8688, -407.3934, 6.1563, 1)},
		{position = Vector4new(-251.0944, -1278.3436, -1.9662, 1)},
		{position = Vector4new(-493.6963, -1145.9196, 15.7987, 1)},
		{position = Vector4new(-229.2243, 377.4955, 29.2949, 1)},
		{position = Vector4new(521.0596, -2250.6299, 46.38, 1)},
		{position = Vector4new(2772.8052, 104.5999, 72.9709, 1)},
		{position = Vector4new(2560.4065, -35.7717, 85.2910, 1)},
		{position = Vector4new(2576.0515, -3.4772, 84.8989, 1)},
		{position = Vector4new(1253.4077, -596.577, 32.793, 1)},
		{position = Vector4new(287.9101, -1948.8701, -5.4, 1)},
		{position = Vector4new(149.8400, -1721.1901, -10.0833, 1)},
		{position = Vector4new(463.7786, -1659.5880, 10.5154, 1)},
		{position = Vector4new(2.7217, -1918.6611, 2.3400, 1)},
		{position = Vector4new(-1381.6539, -5111.4941, 99.9492, 1)},
		{position = Vector4new(-711.2927, -1507.2782, 7.3523, 1)},
		{position = Vector4new(-2703.4050, -2776.4692, 22.5872, 1)},
		{position = Vector4new(-2922.2900, -2727.4800, 17.3157, 1)},
		{position = Vector4new(-2838.5703, -4192.8301, 68.0081, 1)},
		{position = Vector4new(-2441.8687, -4224.1006, 68.3107, 1)},
		{position = Vector4new(-2907.1284, -5338.4458, 80.1940, 1)},
		{position = Vector4new(-2907.1284, -5338.4458, 80.1940, 1)},
		{position = Vector4new(-2797.7097, -1923.4358, 8.8454, 1), lrsq = 16},
		{position = Vector4new(-2788.8352, -1927.6388, 8.8461, 1), lrsq = 16},
		{position = Vector4new(-2240.6641, -2292.3079, 12.4525, 1)},
		{position = Vector4new(3964.7839, -1566.3849, 135.0368, 1)},
		{position = Vector4new(2286.7861, -1050.7792, 55.5045, 1)},
		{position = Vector4new(4120.9873, -364.8312, 146.2311, 1)},
		{position = Vector4new(4238.3237, -442.6692, 147.3071, 1)},
		{position = Vector4new(3965.8638, 74.5278, 121.8920, 1)},
		{position = Vector4new(134.4546, -4813.4224, 49.1579, 1)},
		{position = Vector4new(4188.7041, -2309.9063, 151.2949, 1)},
		{position = Vector4new(3483.9529, 1178.3429, 138.4675, 1)},
		{position = Vector4new(3485.1606, 1177.968, 138.106, 1)},
		{position = Vector4new(3483.566, 1177.139, 138.1836, 1)},
		{position = Vector4new(3336.5784, -1534.7571, 103.5553, 1)},
		{position = Vector4new(3457.0376, -1125.0345, 102.7553, 1)},
		{position = Vector4new(3596.9702, -1303.1710, 117.9030, 1)},
		{position = Vector4new(1310.1160, -887.9727, 43.8596, 1)},
		{position = Vector4new(2887.2317, -1140.3844, 67.4578, 1)},
		{position = Vector4new(3109.4058, -538.6667, 108.9125, 1)},
		{position = Vector4new(-1318.4723, -2863.3408, 34.8586, 1)},
		{position = Vector4new(-683.2238, -4606.7549, 63.3932, 1)},
		{position = Vector4new(-421.8760, -4252.2383, 61.0019, 1)},
		{position = Vector4new(-694.4348, -4246.9702, 58.2774, 1)},
		{position = Vector4new(-1251.7266, -3799.7520, 54.4820, 1)},
		{position = Vector4new(-2136.2310, -4901.4976, 87.1846, 1)},
		{position = Vector4new(-543.4903, -3275.4912, 39.1844, 1)},
		{position = Vector4new(-658.8330, -5386.0552, 81.0035, 1)},
		{position = Vector4new(-658.6912, -5385.6982, 80.4956, 1)},
		{position = Vector4new(-1442.9485, -5682.9746, 92.3885, 1)},
		{position = Vector4new(-1509.1835, -5797.1348, 96.3282, 1)},
		{position = Vector4new(2353.5210, -5312.6875, 86.3975, 1)},
		{position = Vector4new(-2146.9150, -5499.8516, 94.3151, 1)},
		{position = Vector4new(-1481.2433, -4170.4849, 64.3972, 1)},
		{position = Vector4new(-1246.7501, -3468.9932, 44.6116, 1)},
		{position = Vector4new(-375.1510, -4579.8286, 62.2292, 1)},
		{position = Vector4new(-611.3598, -229.4600, 7.8700, 1)},
		{position = Vector4new(-772.1359, -67.7605, 7.5100, 1)},
		{position = Vector4new(-2251.8906, -2858.0388, 108.0031, 1)},
		{position = Vector4new(-2242.3054, -2836.7864, 107.8710, 1)},
		{position = Vector4new(2086.4407, -2572.8098, 70.2100, 1)},
		{position = Vector4new(-1659.9995, -2448.0029, 70.1531, 1)},
		{position = Vector4new(-1346.4340, -2107.0049, 76.6666, 1)},
		{position = Vector4new(-946.7264, -344.0317, 14.8600, 1)},
		{position = Vector4new(-886.9225, -670.8171, 20.1212, 1)},
		{position = Vector4new(-1168.0601, -738.7361, 8.0617, 1)},
		{position = Vector4new(-1657.8798, -577.5482, 7.4000, 1)},
		{position = Vector4new(-2491.4470, -2748.6738, 29.3231, 1)},
		{position = Vector4new(-2531.4634, -2707.4863, 31.9270, 1), lrsq = 81, pdt = 0.5},
		{position = Vector4new(-2533.9602, -2707.1672, 32.0031, 1), lrsq = 81, pdt = 0.5},
		{position = Vector4new(-2536.1733, -2707.0349, 31.9437, 1), lrsq = 81, pdt = 0.5},
		{position = Vector4new(-1050.6958, 2399.6226, 18.9573, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-1051.7427, 2402.0793, 18.9501, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-1052.3682, 2401.2983, 18.9878, 1), lrsq = 25, pdt = 0.25},
		{position = Vector4new(-1460.8896, -1130.6932, 19.1200, 1)},
		{position = Vector4new(-1513.5378, -396.4450, 7.3800, 1)},
		{position = Vector4new(-1895.6516, 511.9879, 26.9824, 1)},
		{position = Vector4new(-1640.0261, 654.0023, 12.6757, 1), rsq = 1},
		{position = Vector4new(-1649.4099, -2764.1279, 107.7486, 1), lrsq = 36},
		{position = Vector4new(-2286.4109, -2872.1948, 111.9662, 1)},
		{position = Vector4new(-2108.2173, -3033.3953, 133.3000, 1), lrsq = 25},
		{position = Vector4new(-2105.3499, -3029.5513, 134.0900, 1), lrsq = 25},
		{position = Vector4new(-2104.8696, -3027.3296, 134.0665, 1), lrsq = 25},
		{position = Vector4new(-2104.3621, -3025.8428, 133.3600, 1), lrsq = 25},
		{position = Vector4new(-2220.0754, -3089.2932, 123.0700, 1)},
		{position = Vector4new(-1936.4126, 524.1611, 10.9591, 1), lrsq = 4},
		{position = Vector4new(-1001.5433, 466.5367, 37.7901, 1)},
		{position = Vector4new(-1136.1038, 373.1695, 5.0678, 1)},
		{position = Vector4new(-1138.8379, 374.1835, 5.0889, 1), rsq = 1},
		{position = Vector4new(-1239.5055, 272.8197, 6.6300, 1)},
		{position = Vector4new(-1356.4299, 444.3835, 13.0924, 1)},
		{position = Vector4new(83.0006, 1333.2323, 117.8985, 1)},
		{position = Vector4new(77.1138, 1331.1360, 118.0864, 1)},
		{position = Vector4new(81.8699, 1335.9733, 118.1546, 1)},
		{position = Vector4new(554.2794, 1205.2345, 242.0261, 1)},
		{position = Vector4new(554.2794, 1205.2345, 242.0261, 1)},
		{position = Vector4new(-1366.8198, -2612.0793, 85.0200, 1), rsq = 0.25},
		{position = Vector4new(-1368.1023, -2614.0305, 85.2581, 1), lrsq = 9, pdt = 0.5625},
		{position = Vector4new(-1366.4501, -2610.3401, 85.4400, 1), lrsq = 9, pdt = 0.5625},
		{position = Vector4new(-1368.4000, -2611.2600, 84.9500, 1), lrsq = 9, pdt = 0.5625},
		{position = Vector4new(-1368.7600, -2612.1702, 84.8200, 1), lrsq = 9, pdt = 0.5625},
		{position = Vector4new(-1368.5403, -2613.3699, 85.7500, 1), lrsq = 9, pdt = 0.5625},
		{position = Vector4new(-1960.9954, -2911.3210, 90.4100, 1)},
		{position = Vector4new(-2050.1555, -2474.6982, 24.2290, 1)},
		{position = Vector4new(-2049.4458, -2478.0161, 24.3491, 1)},
		{position = Vector4new(-2372.5042, -2651.5464, 28.4787, 1)},
		{position = Vector4new(-1107.5715, -1795.5627, 44.2513, 1), lrsq = 6.25},
		{position = Vector4new(-2416.7334, -2663.2888, 12.6967, 1)},
		{position = Vector4new(-2159.6746, -2537.599, 45.671974, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-2159.6863, -2537.682, 45.671974, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-2159.8484, -2538.0063, 45.671974, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-2159.94, -2537.7703, 45.649994, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-2160.1787, -2538.087, 45.671974, 1), lrsq = 20.25, pdt = 3},
		{position = Vector4new(-1809.0315, -2772.2754, 83.5568, 1)},
		{position = Vector4new(-1438.9207, -2291.8662, 54.7423, 1)},
		{position = Vector4new(-1540.1025, -2436.6982, 39.7600, 1)},
		{position = Vector4new(-3579.2815, 361.3495, 33.6096, 1)},
		{position = Vector4new(-3564.4553, 383.3999, 32.9180, 1)},
		{position = Vector4new(-3564.4602, 383.9299, 32.8900, 1)},
		{position = Vector4new(-3566.9714, 369.3196, 32.5296, 1)},
		{position = Vector4new(-3567.6038, 369.2779, 32.5249, 1)},
		{position = Vector4new(-3568.2163, 369.2983, 32.5297, 1)},
		{position = Vector4new(-3667.0813, 400.8246, 38.4900, 1)},
		{position = Vector4new(-3667.0730, 401.3427, 38.4900, 1)},
		{position = Vector4new(-3667.0845, 401.8513, 38.4900, 1)},
		{position = Vector4new(-1596.9449, -2879.2434, 76.9199, 1)},
		{position = Vector4new(-1595.9288, -2879.3699, 76.8753, 1)},
		{position = Vector4new(-2390.7986, -2553.3457, -70.1114, 1), lrsq = 16},
		{position = Vector4new(-2446.4475, -2564.08, -7.29422, 1), lrsq = 16},
		{position = Vector4new(-2437.37, -2585.227, -6.2343903, 1), lrsq = 9},
		{position = Vector4new(-2087.6313, -2246.0537, -193.36858, 1), lrsq = 9},
		{position = Vector4new(-2097.558, -2252.3845, -193.84975, 1), lrsq = 9},
		{position = Vector4new(-2108.1746, -2207.9873, -193.31099, 1), lrsq = 9},
		{position = Vector4new(-2157.9866, -2215.2883, -193.98903, 1), lrsq = 16},
		{position = Vector4new(-1368.6238, -1967.7689, 87.703476, 1), lrsq = 16},
		{position = Vector4new(-1446.5392, 188.26022, 326.03, 1), lrsq = 16},
		{position = Vector4new(-1440.9504, 199.67935, 325.82, 1), lrsq = 16},
		{position = Vector4new(-1398.9434, 156.95126, 291.74112, 1), lrsq = 25},
		{position = Vector4new(-1399.4784, 137.64395, 292.147, 1), lrsq = 25},
		{position = Vector4new(-1420.3622, 142.11661, 291.241, 1), lrsq = 25},
		{position = Vector4new(-1407.3611, 119.256454, 291.74237, 1), lrsq = 25},
		{position = Vector4new(-1452.89, 110.00964, 292.11, 1), lrsq = 25},
		{position = Vector4new(-1457.5757, 112.00386, 280.1025, 1), lrsq = 25},
		{position = Vector4new(-1462.5690, 75.9546, 267.9032, 1), lrsq = 25},
		{position = Vector4new(-1447.9202, 85.994, 255.79909, 1), lrsq = 25},
		{position = Vector4new(-1441.8983, 76.090164, 243.81999, 1), lrsq = 25},
		{position = Vector4new(-1469.734, 113.2068, 243.8019, 1), lrsq = 25},
		{position = Vector4new(-1456.8777, 125.11034, 244.15105, 1), lrsq = 25},
		{position = Vector4new(-1453.9929, 182.59363, 237.82886, 1), lrsq = 25},
		{position = Vector4new(-1437.4146, 171.49792, -19.851906, 1), lrsq = 25},
		{position = Vector4new(-1431.1201, 143.92082, -20.85382, 1), lrsq = 25},
		{position = Vector4new(-1423.4651, 147.30103, -20.646675, 1), lrsq = 25},
		{position = Vector4new(-1449.663, 103.937546, -25.851204, 1), lrsq = 25},
		{position = Vector4new(-1467.6855, 75.255615, -25.54515, 1), lrsq = 25},
		{position = Vector4new(-1467.799, 75.03258, -25.54515, 1), lrsq = 25},
		{position = Vector4new(-1475.0945, 83.18388, -25.710976, 1), lrsq = 25},
		{position = Vector4new(-1455.3452, 130.694, -25.549492, 1), lrsq = 25},
		{position = Vector4new(-1465.6703, 146.9049, -25.851204, 1), lrsq = 25},
		{position = Vector4new(-1436.7982, 156.3522, -25.851204, 1), lrsq = 25},
		{position = Vector4new(-1430.2484, 158.74223, -25.845985, 1), lrsq = 25},
		{position = Vector4new(-1449.8514, 166.68875, -24.851204, 1), lrsq = 25},
		{position = Vector4new(-1487.9601, 126.87207, -25.851913, 1), lrsq = 25},
		{position = Vector4new(-1449.663, 103.937546, -25.851204, 1), lrsq = 25},
		{position = Vector4new(-1473.6622, 152.01813, -25.549377, 1), lrsq = 25},
		{position = Vector4new(-1448.3958, 114.06961, -19.843338, 1), lrsq = 25},
		{position = Vector4new(-1438.8082, 113.2215, -19.851204, 1), lrsq = 25},
		{position = Vector4new(-1434.7855, 109.831894, -19.851204, 1), lrsq = 25},
		{position = Vector4new(-1487.4138, 136.67004, -25.851204, 1), lrsq = 25},
		{position = Vector4new(-1338.2788, 1208.9713, 115.45763, 1), lrsq = 25},
		{position = Vector4new(-1348.711, 1202.8079, 115.92236, 1), lrsq = 25},
		{position = Vector4new(-2467.4885, -2441.7744, 18.3927, 1)},
		{position = Vector4new(-2472.349, -2442.175, 18.398903, 1)},
		{position = Vector4new(-1845.8508, -576.12506, 8.528694, 1)},
		{position = Vector4new(-1480.7164, 59.07952, -21.543762, 1), lrsq = 25},
		{position = Vector4new(-1477.5092, 58.707382, -21.54203, 1), lrsq = 25},
		{position = Vector4new(-1480.5354, 58.649628, -25.541214, 1), lrsq = 25},
		{position = Vector4new(-1467.9102, 69.45882, -25.54515, 1), lrsq = 25},
		{position = Vector4new(-1483.4191, 52.743515, -25.85334, 1), lrsq = 25},
		{position = Vector4new(-1487.6544, 75.91623, -25.73037, 1), lrsq = 25},
		{position = Vector4new(-1500.5505, 77.24832, -24.447968, 1), lrsq = 25},
		{position = Vector4new(-1497.5835, 87.41298, -24.488075, 1), lrsq = 25},
		{position = Vector4new(-1462.0638, 88.69661, -25.530495, 1), lrsq = 25},
		{position = Vector4new(-1467.6855, 75.255615, -25.54515, 1), lrsq = 25},
		{position = Vector4new(-1467.799, 75.03258, -25.54515, 1), lrsq = 25},
		{position = Vector4new(-1310.0983, 155.0545, -25.797478, 1), lrsq = 25},
		{position = Vector4new(-1292.0504, 124.099976, -26.050003, 1), lrsq = 25},
		{position = Vector4new(-1286.3408, 152.85997, -25.739998, 1), lrsq = 25},
		{position = Vector4new(-1287.1714, 153.7099, -25.730003, 1), lrsq = 25},
		{position = Vector4new(-603.8312, -3858.6208, 72.90474, 1), lrsq = 25},
		{position = Vector4new(-1262.9728, -987.1161, 17.126968, 1), lrsq = 25},
		{position = Vector4new(-1245.7933, -1005.1548, 17.174995, 1), lrsq = 25},
		{position = Vector4new(-1250.5719, -984.37134, 17.125298, 1), lrsq = 25},
		{position = Vector4new(-1261.8671, -1006.77747, 16.4666, 1), lrsq = 25},
		{position = Vector4new(-480.69855, 379.997, 133.09378, 1), lrsq = 25},
		{position = Vector4new(-471.78433, 391.621, 132.8, 1), lrsq = 25},
		{position = Vector4new(-463.65762, 418.8195, 132.8, 1), lrsq = 25},
		{position = Vector4new(-449.23996, 422.43, 133.15, 1), lrsq = 25},
		{position = Vector4new(-449.23996, 422.43, 133.15, 1), lrsq = 25},
		{position = Vector4new(-1378.9137, 1267.9863, 123.0691, 1), lrsq = 25},
		{position = Vector4new(-1378.8682, 1276.4237, 124.55, 1), lrsq = 25},
		{position = Vector4new(-1385.8259, 1267.1083, 124.8, 1)},
		{position = Vector4new(-1421.2963, 1324.4696, 119.53, 1), lrsq = 25},
		{position = Vector4new(-1432.6416, 1338.8755, 119.515, 1), lrsq = 25},
		{position = Vector4new(-1463.2726, 1302.7075, 120.17496, 1), lrsq = 25},
		{position = Vector4new(-1442.06, 1294.3676, 28.169, 1), lrsq = 25},
		{position = Vector4new(-1539.9454, 1197.2655, 17.071503, 1), lrsq = 25},
		{position = Vector4new(-1546.3187, 1197.1781, 16.67, 1), lrsq = 25},
		{position = Vector4new(-1551.0803, 1230.1965, 12.32, 1), lrsq = 25},
		{position = Vector4new(-1542.3167, 1233.8762, 12.3, 1), lrsq = 25},
		{position = Vector4new(-1503.791, 1151.725, 19.883, 1), lrsq = 25},
		{position = Vector4new(-1177.4816, 2041.1796, 21.1856, 1), lrsq = 25},
		{position = Vector4new(-1193.1168, 1563.9089, 24.02, 1), lrsq = 25},
		{position = Vector4new(-1176.2878, 1558.9501, 23.3469, 1), lrsq = 25},
		{position = Vector4new(-1193.5204, 1559.3419, 27.384346, 1), lrsq = 25},
		{position = Vector4new(-1168.2743, 1555.0164, 27.71988, 1), lrsq = 25},
		{position = Vector4new(-1178.3082, 1580.1533, 26.917824, 1), lrsq = 25},
		{position = Vector4new(-1163.219, 1570.3152, 23.406197, 1), lrsq = 16},
		{position = Vector4new(-1172.0675, 1581.3872, 20.0, 1), lrsq = 16},
		{position = Vector4new(-1185.3444, 1579.1477, 20.0, 1), lrsq = 25},
		{position = Vector4new(-1189.9250, 1580.7938, 19.3652, 1), lrsq = 9},
		{position = Vector4new(-1035.4681, 1814.2233, 46.561577, 1), lrsq = 42.25},
		{position = Vector4new(-1033.6841, 1357.0593, 6.50753, 1), lrsq = 25},
		{position = Vector4new(-1035.4066, 1344.412, 14.102, 1), lrsq = 25},
		{position = Vector4new(-1025.9955, 1341.2365, 10.443, 1), lrsq = 25},
		{position = Vector4new(-1018.6427, 1361.3813, 6.04798, 1), lrsq = 25},
		{position = Vector4new(-1225.18, 904.43, 6, 1)},
		{position = Vector4new(-1161.0446, 2412.4753, 8.187347, 1), lrsq = 25},
		{position = Vector4new(-1154.2778, 2423.5645, 8.04, 1), lrsq = 25},
		{position = Vector4new(-1495.6562, 2932.7698, 8.381, 1), lrsq = 25},
		{position = Vector4new(-1537.7131, 2558.8809, 10.6785, 1)},
		{position = Vector4new(-1920.8102, 2764.5493, 7.93, 1), lrsq = 25},
		{position = Vector4new(-1920.8812, 2764.4746, 7.937111, 1), lrsq = 25},
		{position = Vector4new(-2046.51, 2882.5496, -8.49, 1), lrsq = 49, pdt = 2},
		{position = Vector4new(-1603.3916, 1534.2581, 18.7044, 1)},
		{position = Vector4new(-870.62244, 2195.3381, 61.79825, 1), lrsq = 25},
		{position = Vector4new(-874.9958, 2200.07, 61.459824, 1), lrsq = 25},
		{position = Vector4new(-1405.0479, 1973.8527, -24.217148, 1), lrsq = 25},
		{position = Vector4new(-1392.5304, 1960.8743, -23.848, 1), lrsq = 25},
		{position = Vector4new(-1450.3706, 996.8569, 17.2839, 1), lrsq = 25},
		{position = Vector4new(-2200.1956, 1784.8875, 163.84, 1), lrsq = 25},
		{position = Vector4new(-2211.826, 1785.4023, 163.57, 1), lrsq = 25},
		{position = Vector4new(-2214.5215, 761.32, 308.002, 1), lrsq = 25},
		{position = Vector4new(-2203.93, 1760.1244, 307.61, 1), lrsq = 25},
		{position = Vector4new(-2227.2288, 1750.2616, 308.6, 1), lrsq = 25},
		{position = Vector4new(-665.58685, 845.31366, 20.5663, 1), lrsq = 25},
		{position = Vector4new(-970.7496, -154.71333, 8.610001, 1)},
		{position = Vector4new(1714.2424, -835.42, 52.89, 1)},
		{position = Vector4new(3207.5815, 649.3523, 105.28, 1), lrsq = 16},
		{position = Vector4new(-657.1555, 2104.1331, 31.9971, 1), rsq = 1},
		{position = Vector4new(-434.1318, 2130.2009, 36.2798, 1), lrsq = 9},
		{position = Vector4new(-432.8275, 2128.8896, 36.1228, 1), lrsq = 9},
		{position = Vector4new(-1663.0699, -2207.7969, 55.5156, 1), lrsq = 16, pdt = 1},
		{position = Vector4new(-1749.6733, -2177.6775, 61.2210, 1), lrsq = 16},
		{position = Vector4new(-1362.2739, -287.3821, 7.7430, 1)},
		{position = Vector4new(-1998.4523, 598.1334, 11.2055, 1), rsq = 2.25},
		{position = Vector4new(-2002.7974, 603.77716, 10.375603, 1), lrsq = 25},
		{position = Vector4new(-726.1154, -2011.9991, 6.6462, 1), lrsq = 16},
		{position = Vector4new(-1054.9734, -1701.3489, 13.911919, 1), lrsq = 25},
		{position = Vector4new(-11.2479, 2081.3027, 100.49, 1)},
		{position = Vector4new(-150.2933, -1629.7213, 7.1723, 1), lrsq = 16, pdt = 3},
		{position = Vector4new(-492.7041, 574.4717, 27.3120, 1)},
		{position = Vector4new(1199.7400, 1317.8856, 28.0600, 1), lrsq = 20.25},
		{position = Vector4new(-1299.1766, -1929.3748, 28.359, 1)},
		{position = Vector4new(-1315.9302, -1901.963, 10.344, 1), lrsq = 16},
		{position = Vector4new(-2034.4435, -2544.4229, 40.4377, 1), pdt = 1, lrsq = 16},
		{position = Vector4new(-2030.8453, -2544.5811, 41.1016, 1), lrsq = 16},
		{position = Vector4new(-1716.1003, -2472.0105, 49.689995, 1), lrsq = 25},
		{position = Vector4new(-1644.412, -2530.11, 44.862625, 1), lrsq = 36},
		{position = Vector4new(-1642.3988, -2532.2087, 45.6025, 1), lrsq = 72.25},
		{position = Vector4new(-1642.3988, -2532.2087, 45.6025, 1), lrsq = 72.25},
		{position = Vector4new(-1644.2249, -2534.2212, 44.8572, 1), lrsq = 72.25},
		{position = Vector4new(-1646.7534, -2533.5142, 44.849457, 1), lrsq = 72.25},
		{position = Vector4new(-2119.9790, -3035.1326, 121.0043, 1)},
		{position = Vector4new(-2119.0820, -3033.8677, 121.0784, 1), lrsq = 4, pdt = 1},
		{position = Vector4new(-2217.5999, -2921.2402, 108.5800, 1)},
		{position = Vector4new(-2220.0601, -2920.4004, 109.1700, 1)},
		{position = Vector4new(-2209.3909, -2917.4067, 107.9900, 1), lrsq = 4, pdt = 1},
		{position = Vector4new(-2209.3909, -2917.4067, 107.9900, 1), lrsq = 4, pdt = 1},
		{position = Vector4new(-1983.6299, -2727.6199, 68.509995, 1), lrsq = 25},
		{position = Vector4new(-2018.5375, -2793.8574, 92.5260, 1), lrsq = 9},
		{position = Vector4new(-1457.5702, -2685.9893, 90.78, 1), lrsq = 25,  pdt = 1},
		{position = Vector4new(-1457.5702, -2685.9893, 90.78, 1), lrsq = 25,  pdt = 1},
		{position = Vector4new(-1536.9404, -2600.9902, 85.71, 1), lrsq = 25},
		{position = Vector4new(-1516.4203, -2468.34, 83.18999, 1), lrsq = 16},
		{position = Vector4new(-1519.0621, -2465.0647, 84.21709, 1), lrsq = 16},
		{position = Vector4new(-1516.5565, -2462.7822, 84.11586, 1), lrsq = 25},
		{position = Vector4new(-1913.2229, -2740.9272, 63.9050, 1), lrsq = 25},
		{position = Vector4new(-1369.0045, -1956.1155, 88.28613, 1), lrsq = 25},
		{position = Vector4new(3193.9905, -2090.7122, 118.49533, 1), lrsq = 25},
		{position = Vector4new(3194.1094, -2089.4258, 118.43974, 1), lrsq = 25},
		{position = Vector4new(3195.4158, -2091.6897, 118.49533, 1), lrsq = 25},
		{position = Vector4new(3196.122, -2090.9104, 118.50055, 1), lrsq = 25},

		{position = Vector4new(-908.324, 1855.955, 43.148, 1)},
		{position = Vector4new(-905.593, 1852.789, 42.808, 1)},
		{position = Vector4new(-896.745, 1854.101, 43.152, 1)},
		{position = Vector4new(-899.977, 1859.005, 43.350, 1)},
		{position = Vector4new(-900.784, 1852.969, 43.147, 1)},
		{position = Vector4new(-907.447, 1861.225, 43.360, 1)},
		{position = Vector4new(-904.773, 1854.303, 42.810, 1)},
		{position = Vector4new(-901.983, 1858.922, 42.895, 1)},
		{position = Vector4new(-896.931, 1861.350, 42.357, 1)},
		{position = Vector4new(-899.619, 1863.499, 43.474, 1)},
		{position = Vector4new(-907.04626, 1859.6927, 43.10479, 1)},

		{position = Vector4new(3451.4998, 364.0999, 134.213, 1)},

	}
	for i, entry in pairs(psilc) do
		if entry.position then
			if entry.lrsq then entry.pdt = entry.pdt or 0.075 entry.isLrsq = true else entry.rsq = entry.rsq or 0.36 entry.isRsq = true end
			local k = mathFloor(entry.position.x)
			for kn = k - 1, k + 1 do
				local slot = psilcLookup[kn]
				if not slot then slot = {} psilcLookup[kn] = slot end
				tableInsert(slot, entry)
			end
		end
	end

	local psiids = {
		t(3206756195, 30),
		t(2764315930, 26),
		t(4202106454, 29),
		t(1592060811, 30),
		t(878607196, 18),
		t(2017263017, 19),
		t(893995339, 41),
		t(3489266269, 26),
		t(3837660924, 30),
		t(548110164, 28),
		t(512235855, 28),
		t(3690209074, 26),
		t(4184729036, 26),
		t(2832634630, 28),
		t(199316099, 25),
		t(3667787629, 25),
		t(478428907, 25),
		t(954471400, 24),
		t(1141364746, 25),
		t(1376420827, 25),
		t(1890219803, 26),
		t(2378246525, 13),
		t(2478067914, 38),
		t(4164377182, 45),
		t(2450011926, 45),
		t(558040708, 26),
		t(2882193163, 37),
		t(3971301623, 38),
		t(2774130281, 44),
		t(1609726521, 26),
		t(1632957747, 27),
		t(3135654635, 26),
		t(1082222331, 26),
		t(252038889, 34),
		t(358154006, 23),
		t(3898155553, 29),
		t(3428269052, 31),
		t(2531886656, 31),
		t(266393594, 31),
		t(1135257469, 25),
		t(8634147, 26),
		t(3153383316, 21),
		t(1536549970, 29),
		t(1937591519, 27),
		t(2250281858, 31),
		t(2756443733, 36),
		t(3391828025, 27),
		t(2940055691, 26),
		t(894612810, 31),
		t(3053819056, 21),
		t(3781412628, 27),
		t(247021323, 22),
		t(1769928354, 22),
		t(2772862626, 27),
		t(403043309, 22),
		t(297269995, 30),
		t(3239219068, 23),
		t(3155743245, 31),
		t(3523030188, 32),
		t(1400704011, 24),
		t(3396623793, 24),
		t(1386066575, 26),
		t(3415532341, 26),
		t(3299904643, 25),
		t(2467523919, 26),
		t(600448717, 26),
		t(3982536379, 25),
		t(4156127717, 31),
		t(3505054268, 31),
		t(3885916621, 32),
		t(1461270016, 25),
		t(738543296, 25),
		t(353771873, 31),
		t(3215788932, 23),
		t(3379542136, 19),
		t(2727494123, 18),
		t(2409597793, 18),
		t(576982848, 29),
		t(4218097077, 22),
		t(3576456076, 18),
		t(3404052359, 25),
		t(619435691, 25),
		t(2755654567, 29),
		t(1026990621, 29),
		t(436355351, 32),
		t(0x6F105B4C, 35),
		t(0xCABBF1EA, 30),
		t(0x581F4F2C, 30),
		t(0xC57C6D05, 28),
		t(0x7AE203FD, 27),
		t(0x3B9727F0, 27),
		t(0x6473DA5F, 23),
		t(0xFD7A8BE5, 23),
		t(0x8A7DBB73, 23),
		t(0xFEB97B71, 26),
		t(686150830, 34),
		t(1439926190, 37),
		t(3609431056, 24),
		t(2668809881, 36),
		t(1549106133, 43),
		t(990252796, 42),
		t(2953359672, 31),
		t(1635649057, 43),
		t(2141000950, 39),
		t(1904635640, 31),
		t(2925455906, 35),
		t(2785528507, 35),
		t(3791265367, 25),
		t(703256377, 31),
		t(2631677250, 25),
		t(97871096, 25),
		t(2103309775, 29),
		t(2542202283, 31),
		t(2035647230, 25),
		t(1384104335, 25),
		t(3774376994, 25),
		t(2045853080, 25),
		t(251006222, 25),
		t(2425526445, 25),
		t(2466980414, 26),
		t(1488812923, 31),
		t(1197476455, 31),
		t(584747611, 20),
		t(1772905332, 28),
		t(1262085167, 22),
		t(1210636505, 21),
		t(2398298978, 27),
		t(1942045846, 31),
		t(2245327613, 24),
		t(484289351, 24),
		t(1642094851, 32),
		t(446358096, 31),
		t(2207495146, 31),
		t(4103373692, 31),
		t(3921358959, 31),
		t(3921358959, 31),
		t(4051939949, 19),
		t(2894998260, 32),
		t(3479250575, 25),
		t(186152825, 40),
		t(0xFF9F289C, 18),
		t(0x66967926, 18),
		t(0x119149B0, 18),
		t(0x8FF5DC13, 18),
		t(0xF8F2EC85, 18),
		t(0x61FBBD3F, 18),
		t(0x16FC8DA9, 18),
		t(0x86439038, 18),
		t(0xF144A0AE, 18),
		t(0x9183294B, 18),
		t(0xE68419DD, 18),
		t(0x7F8D4867, 18),
		t(0x088A78F1, 18),
		t(0x96EEED52, 18),
		t(2334032496, 35),
		t(2519806307, 35),
		t(1269295334, 35),
		t(1385098041, 35),
		t(3998655604, 35),
		t(868253169, 35),
		t(2383024447, 35),
		t(1402783930, 35),
		t(1961631119, 35),
		t(2843395082, 35),
		t(3017813908, 35),
		t(1853290001, 35),
		t(3552352991, 35),
		t(237650778, 35),
		t(1935230210, 35),
		t(2932841607, 35),
		t(319156297, 35),
		t(3465750988, 35),
		t(3924032761, 35),
		t(880092540, 35),
		t(3593307476, 35),
		t(196828369, 35),
		t(3060871199, 35),
		t(1810360730, 35),
		t(370238214, 35),
		t(3324419917, 35),
		t(3674811486, 35),
		t(1102288293, 35),
		t(1915432204, 35),
		t(2260707262, 35),
		t(3703338195, 35),
		t(19574102, 35),
		t(4208886373, 35),
		t(659053536, 35),
		t(2592225070, 35),
		t(1192554155, 35),
		t(979888371, 35),
		t(3891343734, 35),
		t(1513840056, 35),
		t(2276295741, 35),
		t(2698858760, 35),
		t(1741775635, 35),
		t(3125262998, 35),
		t(126735960, 35),
		t(2063519744, 35),
		t(3964647599, 35),
		t(2619690016, 35),
		t(4224492006, 35),
		t(95264389, 31),
		t(2137768016, 31),
		t(4077665482, 32),
		t(1321619460, 32),
		t(2471528833, 32),
		t(3995307993, 32),
		t(867522140, 32),
		t(2390702738, 32),
		t(3603160629, 32),
		t(1795797755, 32),
		t(3063901054, 32),
		t(3421269286, 32),
		t(377140387, 32),
		t(2880493677, 32),
		t(1982202344, 32),
		t(1364645085, 32),
		t(2361396568, 32),
		t(2522539718, 32),
		t(393097063, 41),
		t(537915212, 41),
		t(2126539560, 41),
		t(2126539560, 41),
		t(2607598579, 30),
		t(2440452404, 30),
		t(3985348864, 25),
		t(2678630288, 26),
		t(3092073655, 30),
		t(3760321910, 30),
		t(3760321910, 30),
		t(13746874, 31),
		t(2526538176, 25),
		t(3720816462, 25),
		t(1154381556, 25),
		t(868828770, 25),
		t(3272480765, 25),
		t(1510426183, 25),
		t(439513318, 20),
		t(3939736197, 31),
		t(3939736197, 31),
		t(618031392, 31),
		t(2217981693, 31),
		t(2103857676, 31),
		t(3273643651, 31),
		t(512298758, 31),
		t(3649387805, 31),
		t(3118041174, 31),
		t(2150958641, 31),
		t(2676356460, 36),
		t(575642018, 36),
		t(4292427815, 36),
		t(2192197247, 36),
		t(1597808634, 36),
		t(3807834932, 36),
		t(1063266993, 36),
		t(403767172, 36),
		t(3313903105, 36),
		t(3743206815, 36),
		t(1759671744, 36),
		t(1829061252, 45),
		t(2449766768, 36),
		t(2292093678, 36),
		t(1426606955, 36),
		t(3905038245, 36),
		t(894762528, 36),
		t(1210579064, 36),
		t(2511413757, 36),
		t(1614152608, 36),
		t(3724308334, 36),
		t(6993643, 36),
		t(2098835635, 36),
		t(2693753142, 36),
		t(491062776, 36),
		t(3235110013, 36),
		t(3886221640, 36),
		t(1104854192, 31),
		t(2028207456, 31),
		t(415189035, 31),
		t(3092944886, 31),
		t(1091531527, 31),
		t(585117197, 31),
		t(2708706345, 31),
		t(3857456150, 31),
		t(2813533275, 35),
		t(4173573893, 31),
		t(3263144179, 32),
		t(2142620733, 32),
		t(2720208312, 32),
		t(3746567136, 32),
		t(46582373, 32),
		t(3205277355, 32),
		t(1654292270, 32),
		t(3008907823, 31),
		t(3317269480, 32),
		t(2020863782, 32),
		t(2783262371, 32),
		t(3633721595, 32),
		t(83945854, 32),
		t(3100280240, 32),
		t(2971109638, 31),
		t(215868872, 31),
		t(384075901, 31),
		t(2241457929, 31),
		t(1477392012, 31),
		t(3094598050, 31),
		t(1365995048, 31),
		t(2468456925, 32),
		t(787203347, 32),
		t(4085062806, 32),
		t(2383289038, 32),
		t(1402520395, 32),
		t(347382581, 32),
		t(868513280, 32),
		t(3374480048, 32),
		t(3998396293, 32),
		t(1109467482, 32),
		t(1594790473, 32),
		t(644388578, 31),
		t(1140841003, 32),
		t(2611149356, 31),
		t(994518513, 31),
		t(3848532746, 32),
		t(1487511492, 32),
		t(2235516481, 32),
		t(4165746713, 32),
		t(635083164, 32),
		t(2551248210, 32),
		t(1166421207, 32),
		t(3210748007, 32),
		t(4103373692, 31),
		t(688020217, 31),
		t(3128901005, 31),
		t(129323331, 31),
		t(4250099187, 31),
		t(1771790858, 31),
		t(3272248089, 31),
		t(661708027, 31),
		t(4209378686, 31),
		t(3726981130, 31),
		t(2561002651, 32),
		t(628072533, 32),
		t(4177099216, 32),
		t(2240446344, 32),
		t(1478272525, 32),
		t(3856059075, 32),
		t(943723334, 32),
		t(3014396709, 31),
		t(4040639660, 28),
		t(3555769966, 31),
		t(241592299, 31),
		t(3994973215, 28),
		t(4102056795, 31),
		t(3994714309, 31),
		t(3548741653, 28),
		t(4181787928, 31),
		t(1406200843, 31),
		t(782494291, 31),
		t(1325358872, 31),
		t(3734761554, 28),
		t(1771014701, 31),
		t(2457576734, 31),
		t(1248323092, 28),
		t(800180688, 31),
		t(2830892397, 28),
		t(4010320710, 31),
		t(1680560874, 28),
		t(1273744471, 31),
		t(4129398937, 31),
		t(733444380, 31),
		t(2337449665, 31),
		t(915982863, 31),
		t(3943568266, 31),
		t(3430860479, 31),
		t(300425018, 31),
		t(4088446738, 31),
		t(2834785891, 31),
		t(838744025, 31),
		t(1190725455, 31),
		t(3966299740, 31),
		t(3741682623, 32),
		t(1657792369, 32),
		t(532472105, 32),
		t(2725678567, 32),
		t(2145408098, 32),
		t(1095468592, 31),
		t(1550071075, 31),
		t(1010335848, 31),
		t(3336473816, 31),
		t(1636699016, 31),
		t(621904823, 31),
		t(486346192, 31),
		t(2704761118, 31),
		t(2090973339, 31),
		t(2252846123, 31),
		t(2838321532, 32),
		t(350696882, 32),
		t(3379686455, 32),
		t(3020089967, 32),
		t(1771320298, 32),
		t(3562954532, 32),
		t(164136609, 32),
		t(783831956, 32),
		t(4079913489, 32),
		t(3920912783, 32),
		t(3285685346, 25),
	}
	for i, entry in pairs(psiids) do
		local k = tonumber(entry.hash)
		local slot = psiLookup[k]
		if not slot then slot = {} psiLookup[k] = slot end
		slot[tonumber(entry.length)] = entry
	end
	local psnpcs = {
		t(559568892, 17),
		t(2793039571, 32),
		t(1119903596, 22),
		t(1878025896, 27),
		t(2045015319, 15),
		t(3444547383, 25),
		t(1136692099, 25),
		t(2702411282, 34),
		t(2686265756, 27),
		t(463373439, 45),
		t(3270106657, 41),
		t(425008454, 40),
		t(2390786102, 35),
		t(529846362, 32),
		t(2121673310, 25),
		t(2334184524, 40),
		t(2715707065, 23),
		t(50361072, 25),
		t(2584290122, 25),
		t(569303688, 39),
		t(2550359673, 39),
		t(3469220641, 33),
		t(4103568647, 33),
		t(3367862250, 31),
		t(3331045138, 26),
		t(1584930907, 29),
		t(3562205375, 33),
		t(1669036927, 34),
		t(2441889593, 39),
		t(968495751, 29),
		t(1851549978, 40),
		t(1845554939, 35),
		t(0x40A03403, 32),
	}
	for i, entry in pairs(psnpcs) do
		local k = tonumber(entry.hash)
		local slot = psnpcsLookup[k]
		if not slot then slot = {} psnpcsLookup[k] = slot end
		slot[tonumber(entry.length)] = entry
	end
end

local cfns = {"q303_05_safehouse_majesty_picked_up"}
lootableClasses = {
	"gameLootContainerBase",
	"gameLootObject",
	"gameLootBag",
	"gameweaponObject",
	"NPCPuppet",
}
local lootableClassesCount = #lootableClasses
function addToObjectMappins(owner, mappinObjectRef, forceNew)
	if type(owner) ~= 'userdata' then return end
	if not owner.GetEntityID then return end
	local isAccepted = false
	for i = 1, lootableClassesCount do
		if owner:IsA(lootableClasses[i]) then isAccepted = true break end
	end
	if not isAccepted then return end
	if owner:IsA(n_FlareOwner) then return elseif owner:IsA(n_LootContainerObjectAnimatedByTransform) then if stringMatch(owner:GetCurrentAppearanceName().value, "airdrop_") then return end end
	local entId = owner:GetEntityID()
	local ownerHash = entId.hash
	if ownerHash == 1ULL then return end
	local ownerHashStr = tostring(ownerHash)
	if not objectMappins[ownerHashStr] then
		objectMappinsCount = objectMappinsCount + 1
		objectMappins[ownerHashStr] = {isNew = true, mappinObjectRef = mappinObjectRef, entId = entId}
	else
		if forceNew then
			objectMappins[ownerHashStr] = {isNew = true, mappinObjectRef = mappinObjectRef, entId = entId}
		else
			if mappinObjectRef then objectMappins[ownerHashStr].mappinObjectRef = mappinObjectRef end
		end
	end

	if not lastTakedownTargetPos then return end
	if not owner:IsA(n_gameweaponObject) then return end
	if owner.isHeavyWeapon then return end
	local player = GetPlayer()
	if not player then return end
	if not player:IsCooldownActive(lastLootedTakedownCooldownName) then return end
	local parent = owner:GetOwner()
	if not parent then return end
	if not parent:IsA(n_gameItemDropObject) then return end
	if parent.isIconic and owner.isIconic then return end
	if vectorDistanceSquared(lastTakedownTargetPos, owner:GetWorldPosition()) > 9 then return end
	local payload = function()
		local result, data = pcall(function()
			local ownerItemData = owner:GetItemData()
			savelockTimeout = os.clock() + 0.05
			if transactionSystem:TransferAllItems(parent, player) then
				if objectMappins[ownerHashStr] then objectMappins[ownerHashStr].isNew = false end
				if ownerItemData then audioSystem:PlayItemLootedSound(ownerItemData) end
			end
		end)
		if result then return end
		print(data)
		spdlog.error(data)
	end
	player:RemoveCooldown(lastLootedTakedownCooldownName)
	logic.payload = payload
	lastTakedownTargetPos = nil
end

function hideLootMarkers()
	for ownerHashStr, mappinRec in pairs(customLootMappins) do
		if mappinRec.isLootOn then
			local mappinObjectRef = mappinRec.mappin.mappinObjectRef
			if mappinObjectRef and IsDefined(mappinObjectRef) then
				local mappins = mappinObjectRef.mappins
				if mappins and #mappins > 0 then
					local owner = findEntityByIdOrHashStr(ownerHashStr)
					if owner and owner:IsNPC() then
						local hideLootMappin = false
						local result, items = transactionSystem:GetItemList(owner)
						if result and items then hideLootMappin = #items == 0 end
						if hideLootMappin then
							for i = #mappins, 1, -1 do
								if mappins[i].mappinVariant == gamedataMappinVariant.LootVariant then
									mappinObjectRef:HideRoleMappins()
									mappinRec.isLootOn = false
									break
								end
							end
						end
					end
				end
			end
		end
	end
end

local searchQuery
function logic.lootInRange(range, lootInView, lootVisible, audioFeedback)
	if not logic.isLootingTime() then return end
	if type(range) ~= 'number' then range = 20 end
	local lootInRange = range > 0
	local forceShard = true
	if not lootInRange then range = 10000 end
	lootInView = true

	local player = GetPlayer()
	local gameObj = nil
	local isAnythingLooted = false
	local result, items = false, nil

	local rangeSquared = range * range
	local playerPos = player:GetWorldPosition()

	if objectMappinsCount > 0 then
		for ownerHashStr, mappin in pairs(objectMappins) do
			if mappin and mappin.isNew then
				gameObj = findEntityByIdOrHashStr(mappin.entId or ownerHashStr)
				if isObjectOfInterest(gameObj) then
					if isNpcSafeToLoot(gameObj) then
						local hasItemsToLoot, objectHasLootItems, ownerHasLootItems = false, false, false
						result, items = transactionSystem:GetItemList(gameObj)
						if result and #items > 0 then hasItemsToLoot = true objectHasLootItems = true end
						local gameObjOwner = nil
						result = false
						pcall(function() gameObjOwner = gameObj:GetOwner() end)
						if gameObjOwner then result, items = transactionSystem:GetItemList(gameObjOwner) end
						if result and #items > 0 then hasItemsToLoot = true ownerHasLootItems = true end
						if hasItemsToLoot then
							local takeIt = true
							local gameObjPos
							if lootInRange then
								gameObjPos = gameObj:GetWorldPosition()
								takeIt = vectorDistanceSquared(playerPos, gameObjPos) <= rangeSquared
							end
							if takeIt then
								if lootInView then takeIt = cameraSystem:IsInCameraFrustum(gameObj, 0.5, 0.2) end
								if takeIt then
									if lootVisible then gameObjPos = gameObjPos or gameObj:GetWorldPosition() takeIt = isObjectVisibleToPlayer(gameObj, gameObjPos, player, playerPos, true) end
									if takeIt then
										local lootStep1Result, lootStep2Result = lootResult.nothingToLoot, lootResult.nothingToLoot
										if objectHasLootItems then
											result = lootObjectItems(gameObj, forceShard, false, true, playerPos)
											lootStep1Result = result
											if result > lootResult.nothingToLoot then
												isAnythingLooted = true
											end
										end

										if ownerHasLootItems then
											if gameObjOwner then
												gameObj = gameObjOwner
												result = lootObjectItems(gameObj, forceShard, false, false, playerPos)
												lootStep2Result = result
												if result > lootResult.nothingToLoot then
													isAnythingLooted = true
												end
											end
										end

										local shouldSetMarker = false
										if lootStep1Result == lootResult.allItemsFailed or lootStep1Result == lootResult.protectedObject or lootStep1Result == lootResult.partialLoot then shouldSetMarker = true end
										if not shouldSetMarker then
											if lootStep2Result == lootResult.allItemsFailed or lootStep2Result == lootResult.protectedObject or lootStep2Result == lootResult.partialLoot then shouldSetMarker = true end
										end
										if shouldSetMarker then
											if gameObj:IsNPC() then
												mappin.mappinObjectRef:ShowRoleMappins()
												customLootMappins[ownerHashStr] = {mappin = mappin, isLootOn = true}
											end
										end
									end
								end
							end
						end
					end
				else
					mappin.isNew = false
				end
			end
		end
	end

	logic.lastLootCompletedTime = os.clock()
	if audioFeedback and isAnythingLooted then audioSystem:PlayLootAllSound() end
end

function lootNpc(gameObj, skipPreCheck)
	if not skipPreCheck then
		if type(gameObj) ~= 'userdata' then return end
		if not gameObj.IsA then return end
		if not IsDefined(gameObj) then return end
	end
	if not gameObj:IsNPC() then return end
	if gameObj.isCrowd then return end
	if not isNpcSafeToLoot(gameObj, true) then return end
	local result = lootObjectItems(gameObj, false, false, true)
	isAnythingLooted = result > lootResult.nothingToLoot
	local gameplayRoleComponent = gameObj.gameplayRoleComponent
	if gameplayRoleComponent then
		if result == lootResult.allItemsFailed or result == lootResult.protectedObject or result == lootResult.partialLoot then
			gameplayRoleComponent:ShowRoleMappins()
		end
	end
	if not isAnythingLooted then return end
	audioSystem:PlayLootAllSound()
	return true
end

local angleIncrements = {0, 5, -5, 10, -10, 15, -15}
local elevationIncrements = {0, 0.33, 0.45, 0.5}
local distanceToAngleFactor = 0.003 * 360

function isObjectVisibleToPlayer(gameObj, objectPos, player, playerPos, skipPreCheck)
	if not skipPreCheck then
		if not gameObj then return end
		if not IsDefinedS(gameObj) then return end
		if not gameObj:IsA(n_gameObject) then return end
	end
	return isObjectVisibleToPlayerCore(gameObj, objectPos, player, playerPos, skipPreCheck)
end

local mathSin = math.sin
local mathCos = math.cos
local mathRad = math.rad
function isObjectVisibleToPlayerCore(gameObj, objectPos, player, playerPos, skipPreCheck)
	player = player or GetPlayer()
	playerPos = playerPos or player:GetWorldPosition()
	objectPos = objectPos or gameObj:GetWorldPosition()

	local senseManager = GameGetSenseManager()
	local isVisble = senseManager:IsObjectVisible(player:GetEntity(), gameObj:GetEntity())
	if isVisble then return true, true, playerPos, objectPos end

	local playerEyesPos, forward = targetingSystem:GetCrosshairData(player)
	local playerToEyesDist2D = vectorDistance2D(playerPos, playerEyesPos) + 0.02
	playerEyesPos.z = playerEyesPos.z + 0.02
	local playerToObjectAngle = Vector4new(objectPos.x - playerEyesPos.x, objectPos.y - playerEyesPos.y, 0, 0):ToRotation().yaw + 90
	playerEyesPos = Vector4new(playerPos.x + playerToEyesDist2D * mathCos(mathRad(playerToObjectAngle)), playerPos.y + playerToEyesDist2D * mathSin(mathRad(playerToObjectAngle)), playerEyesPos.z, 1)

	isVisble = senseManager:IsPositionVisible(playerEyesPos, objectPos)
	if isVisble then return true, true, playerEyesPos, objectPos end

	local uiSlotsPos
	if not isScriptedPuppetUnsafe(gameObj) then
		local uiSlots = gameObj:FindComponentByName(n_UI_Slots)
		if uiSlots and type(uiSlots.GetLocalPosition) == 'function' and isValidVector34Unsafe(uiSlots:GetLocalPosition()) then
			uiSlotsPos = MatrixGetTranslation(uiSlots:GetLocalToWorld());
		end
	end

	isVisble = uiSlotsPos and senseManager:IsPositionVisible(playerEyesPos, uiSlotsPos)
	if isVisble then return true, true, playerEyesPos, uiSlotsPos end

	local eyesToObjectDist2D = vectorDistance2D(playerEyesPos, objectPos)
	if eyesToObjectDist2D ~= 0 then
		local objectToPlayerEyesAngle = Vector4new(playerEyesPos.x - objectPos.x, playerEyesPos.y - objectPos.y, 0, 0):ToRotation().yaw + 90
		local angleShiftFactor = distanceToAngleFactor / eyesToObjectDist2D

		local newPlayerEyesPos = Vector4new(playerEyesPos)
		for _, angleShift in ipairs(angleIncrements) do
			if angleShift ~= 0 then
				angleShift = angleShift * angleShiftFactor
				local newAngleRad = mathRad(objectToPlayerEyesAngle+angleShift)
				newPlayerEyesPos = Vector4new(objectPos.x + eyesToObjectDist2D * mathCos(newAngleRad), objectPos.y + eyesToObjectDist2D * mathSin(newAngleRad), playerEyesPos.z, 1)
			end
			if uiSlotsPos then
				isVisble = senseManager:IsPositionVisible(newPlayerEyesPos, uiSlotsPos)
				if isVisble then return true, true, newPlayerEyesPos, uiSlotsPos end
			end

			local elevatedObjectPos = Vector4new(objectPos)
			for _, elevationIncrement in ipairs(elevationIncrements) do
				elevatedObjectPos.z = elevatedObjectPos.z + elevationIncrement

				isVisble = senseManager:IsPositionVisible(newPlayerEyesPos, elevatedObjectPos)
				if isVisble then return true, true, newPlayerEyesPos, elevatedObjectPos end
			end
		end
	end

	local hitPoint, hitPoints = getHitPointFromTo(playerEyesPos, objectPos)
	if not hitPoint then return true end

	if not hitPoints then hitPoints = {} end
	local objectDist = vectorDistance(playerPos, objectPos)
	local hitPointDist = vectorDistance(playerPos, hitPoint)
	local dif = objectDist - hitPointDist

	if hitPointDist > objectDist then
		return
	elseif (#hitPoints > 0 and (stringFind(hitPoints[#hitPoints].materials, 'concrete') or stringFind(hitPoints[#hitPoints].materials, 'asphalt'))) then
		return
	elseif dif < 0.33 then
		return true
	elseif (dif < 1 and aINavigationSystem:IsPointOnNavmesh(gameObj, hitPoint, Vector4new(0.3, 0.3, 0.3, 1))) then
		return true
	end
end

function isObjectOfInterest(gameObj)
	if type(gameObj) ~= 'userdata' then return false end
	if not IsDefined(gameObj) then return false end
	if not gameObj:IsA(n_gameObject) then return false end
	if gameObj.isCrowd then return false end
	local isAccepted = false
	for i = 1, lootableClassesCount do
		if gameObj:IsA(lootableClasses[i]) then isAccepted = true break end
	end
	if not isAccepted then return end

	if gameObj:IsA(n_gameItemDropObject) then
		local itemObject = gameObj:GetItemObject()
		if itemObject and itemObject:IsA(n_gameweaponObject) and itemObject.isHeavyWeapon then return false end
	end
	return true
end

function isProtectedNpc(gameObj)
	if type(psnpcsLookup) ~= 'table' then return end
	local id = gameObj:GetTDBID()
	local hs = tonumber(id.hash)
	if hs == 0 then return end
	local entry = psnpcsLookup[hs]
	if not entry then return end
	return entry[tonumber(id.length)]
end

function isNpcSafeToLoot(gameObj, isNPC)
	if (not isNPC) and (not gameObj:IsNPC()) then return true end
	if isProtectedNpc(gameObj) then return end
	if gameObj:IsDead() then return true end
	if not (gameObj:GetKiller() == nil) then return true end
	if gameObj:IsDefeated() then return true end
end

function isObjectLootable(gameObj, gameObjEntityIdHashStr, isClassicScan)
	local isAccepted = false
	for i = 1, lootableClassesCount do
		if gameObj:IsA(lootableClasses[i]) then isAccepted = true break end
	end
	if not isAccepted then return end
	if isScriptedPuppetUnsafe(gameObj) and gameObj:IsHuman() and (not isProtectedNpc(gameObj)) then return true end
	if isClassicScan then return true end
	if objectMappinsCount == 0 then return false end
	if not gameObjEntityIdHashStr then gameObjEntityIdHashStr = tostring(gameObj:GetEntityID().hash) end
	local objectMappinsRecord = objectMappins[gameObjEntityIdHashStr]
	if not objectMappinsRecord then return false end
	local mappinObjectRef = objectMappinsRecord.mappinObjectRef
	if not mappinObjectRef then return false end
	if not IsDefinedS(mappinObjectRef) then return false end
	local mappins = mappinObjectRef.mappins
	if not mappins then return false end
	if #mappins < 1 then return false end
	return true
end

local stringLen = string.len
local function isStringValid(input)
	if type(input) ~= 'string' then return end
	return stringLen(input) > 0
end

function lootObjectItems(gameObj, forceShard, fqa, skipPreCheck, playerPos)
	if not skipPreCheck then
		if not isObjectOfInterest(gameObj) then return lootResult.notLootObject end
		if not isNpcSafeToLoot(gameObj) then return lootResult.notLootObject end
	end
	local protectQuestObject = true
	if forceShard and stringFind(gameObj:ToString(), 'Shard') then protectQuestObject = false end
	local player = GetPlayer()
	if gameObj:IsA(n_gameContainerObjectBase) then
		if gameObj:IsA(n_ShardCaseContainer) then
			if protectKeyCards and gameObj.itemTDBID and RPGManagerGetItemType(ItemIDFromTDBID(gameObj.itemTDBID)) == gamedataItemTypeGen_Keycard then return lootResult.protectedObject end
		else
			if gameObj:IsLocked(player) then return lootResult.protectedObject end
		end
	end
	local objectPosition
	if not fqa then
		if protectQuestObject and gameObj:IsQuest() then return lootResult.protectedObject end
		objectPosition = gameObj:GetWorldPosition()
		if isObjectAtQuestSite(objectPosition, true) then return lootResult.protectedObject end
	end
	if gameObj:IsA(n_gameItemDropObject) then
		local isObjectWeaponGradeProtected
		local itemObject = gameObj:GetItemObject()
		if itemObject and itemObject:IsA(n_gameweaponObject) then
			if isGameV2 then
				if gameObj.isIconic and itemObject.isIconic then
					isObjectWeaponGradeProtected = true
				end
			else
				if itemObject.isIconic then
					isObjectWeaponGradeProtected = true
				end
			end
		end
		if isObjectWeaponGradeProtected then return lootResult.protectedObject end
	end
	objectPosition = objectPosition or gameObj:GetWorldPosition()
	if isValidVector4(objectPosition) then
		local posXInt
		if type(psilcLookup) == 'table' then
			posXInt = mathFloor(objectPosition.x)
			local psilc = psilcLookup[posXInt]
			if psilc then
				playerPos = playerPos or player:GetWorldPosition()
				for i, entry in ipairs(psilc) do
					if entry.isRsq then
						if vectorDistanceSquared(objectPosition, entry.position) < entry.rsq then
							if entry.fnid then
								local fn = cfns[entry.fnid]
								if not fn then return lootResult.protectedObject end
								if questsSystem:GetFactStr(fn) < 1 then
									return lootResult.protectedObject
								end
							else
								return lootResult.protectedObject
							end
						end
					elseif entry.isLrsq then
						local entryPos = entry.position
						local pdt = entry.pdt
						local isObjectClose = mathAbs(entryPos.x - objectPosition.x) < pdt and mathAbs(entryPos.y - objectPosition.y) < pdt and mathAbs(entryPos.z - objectPosition.z) < pdt
						if isObjectClose and vectorDistanceSquared(objectPosition, playerPos) > entry.lrsq then
							return lootResult.protectedObject
						end
					end
				end
			end
		end
		if type(collectedPoiMappins) == 'table' then
			posXInt = posXInt or mathFloor(objectPosition.x)
			local mappins = collectedPoiMappins[posXInt]
			if mappins then
				for id, mappinData in pairs(mappins) do
					if not IsDefinedS(mappinData.mappin) then mappins[id] = nil
					elseif mappinData.position then
						if vectorDistanceSquared(objectPosition, mappinData.position) < 0.1225 then

							return lootResult.protectedObject
						end
					end
				end
			end
		end
	end
	local result, items = transactionSystem:GetItemList(gameObj)
	if not result then return lootResult.nothingToLoot end
	if #items < 1 then return lootResult.nothingToLoot end
	local lootedItems, totalItems = 0, #items
	for i, item in ipairs(items) do
		if IsDefinedS(item) then
			local isItemQuestProtected = false
			local itemId = item:GetID()
			local itemIdid = itemId.id
			local itemRecord
			if not fqa then itemRecord = TweakDBInterfaceGetItemRecord(itemIdid) end
			if itemRecord then
				local itemSecondaryAction = itemRecord:ItemSecondaryAction()
				if itemSecondaryAction then
					local appendedTweakDBID = t(itemSecondaryAction:GetID(), ".journalEntry")
					local journalPath = TweakDBInterfaceGetString(appendedTweakDBID, "")
					local journalEntry
					if isStringValid(journalPath) then journalEntry = journalManager:GetEntryByString(journalPath, "gameJournalOnscreen") end
					if journalEntry then
						local level = 0
						while (journalEntry and (not journalEntry:IsA(n_gameJournalFolderEntry)) and level < 10) do
							journalEntry = journalManager:GetParentEntry(journalEntry)
							level = level + 1
						end
						if journalEntry then
							if #allJournalQuestEntries == 0 then
								allJournalQuestEntries, allJournalQuestEntriesHashLookup, allJournalQuestEntriesIdLookup = jmels.getAllJournalQuestEntries(true)
								allJournalQuestEntries = allJournalQuestEntries or {}
							end
							if allJournalQuestEntriesIdLookup then
								isItemQuestProtected = allJournalQuestEntriesIdLookup[journalEntry.id] ~= nil
							else
								for ii, qe in ipairs(allJournalQuestEntries) do
									if journalEntry.id == qe.id then isItemQuestProtected = true break end
								end
							end
						end
					end
				end
			end

			if not isItemQuestProtected then
				local entry = psiLookup[tonumber(itemIdid.hash)]
				if entry then
					entry = entry[tonumber(itemIdid.length)]
					if entry then
						isItemQuestProtected = true
					end
				end
			end
			local isHeavyWeaponItem, isItemWeaponGradeProtected
			local itemType = item:GetItemType()
			isHeavyWeaponItem = itemType == gamedataItemTypeWea_HeavyMachineGun
			if itemType and (not isHeavyWeaponItem) and stringFind(itemType.value, 'Wea_') then
				isItemWeaponGradeProtected = item:GetStatValueByType(gamedataStatType.IsItemIconic) > 0
			end

			if (not isHeavyWeaponItem) and (not isItemWeaponGradeProtected) and (not isItemQuestProtected) then
				savelockTimeout = os.clock() + 0.05
				if transactionSystem:TransferItem(gameObj, player, itemId, item:GetQuantity()) then
					lootedItems = lootedItems + 1
				end
			end
		end
	end
	if lootedItems < 1 then return lootResult.allItemsFailed end
	if gameObj:IsA(n_gameContainerObjectBase) or gameObj:IsA(n_ShardCaseContainer) then
		if not gameObj.wasOpened and gameObj.OpenContainerWithTransformAnimation then
			pcall(function() gameObj:OpenContainerWithTransformAnimation() end)
			gameObj.wasOpened = true
		end
	end
	if logic.isLootDialogOnScreen and lastLootingController and IsDefinedS(lastLootingController) then lastLootingController:Hide() end
	if lootedItems == totalItems then return lootResult.allLooted end
	return lootResult.partialLoot
end

function isObjectAtQuestSite(objectPos, skipPreCheck)
	if isWorldMapPinOfTypeInRange(objectPos, 0.5, 'Quest', false, skipPreCheck) then return true end
	if isQuestMapPinInRangeByJournal(objectPos, 0.5, skipPreCheck) then return true end
end

function isQuestMapPinInRangeByJournal(objectPos, range, skipPreCheck)
	if not skipPreCheck then
		if not objectPos then return false end
		if not range then range = 0.5 end
		if type(range) ~= 'number' then range = 0.5 end
	end

	local capturedQuestMappins = jmels.getActiveQuestsMappins()
	if not capturedQuestMappins then return false end

	if #capturedQuestMappins < 1 then return false end

	local closeMappins = {}
	for _, mappin in ipairs(capturedQuestMappins) do
		local pos = mappin.pos
		if mathAbs(pos.x - objectPos.x) <= range then
			if mathAbs(pos.y - objectPos.y) <= range then
				if mathAbs(pos.z - objectPos.z) <= range then
					tableInsert(closeMappins, mappin)
				end
			end
		end
	end

	local size = #closeMappins
	if size == 0 then return false end
	if size == 1 then return closeMappins[1] end

	lowestDistanceIndex = 0
	lowestDistanceSquared = 1000000000

	for i = 1, size do
		local distSquared = vectorDistanceSquared(objectPos, closeMappins[i].pos)
		if distSquared < lowestDistanceSquared then
			lowestDistanceSquared = distSquared
			lowestDistanceIndex = i
		end
	end

	if lowestDistanceIndex > 0 and lowestDistanceSquared <= range * range then
		return closeMappins[lowestDistanceIndex]
	end
end

local function isPlayerInWorkspot(player)
	player = player or GetPlayer()
	if not player then return end
	return player.mountedVehicle or workspotSystem:IsActorInWorkspot(player)
end

function isWorldMapPinOfTypeInRange(objectPos, range, typeFilterStr1, typeFilterStr2, skipPreCheck)
	if not skipPreCheck then
		if not objectPos then return false end
		if not range then range = 0.5 end
		if type(range) ~= 'number' then range = 0.5 end
		if type(typeFilterStr1) ~= 'string' then typeFilterStr1 = false end
		if type(typeFilterStr2) ~= 'string' then typeFilterStr2 = false end
	end
	local noTypeFilters = not typeFilterStr1 and not typeFilterStr2

	if not worldMappins then worldMappins = {} end
	if isGameV23 then worldMappins = mappinSystem:GetMappinEntries(gamemappinsMappinTargetTypeWorld) else worldMappins = mappinSystem:GetMappins(gamemappinsMappinTargetTypeWorld) end

	if not worldMappins then return false end
	if #worldMappins < 1 then return false end

	local closeMappins = {}
	local worldPosition
	for _, mappin in ipairs(worldMappins) do
		worldPosition = mappin.worldPosition
		if mathAbs(worldPosition.x - objectPos.x) <= range then
			if mathAbs(worldPosition.y - objectPos.y) <= range then
				if mathAbs(worldPosition.z - objectPos.z) <= range then
					local takeIt = false
					if noTypeFilters then
						takeIt = true
					else
						if typeFilterStr1 and stringFind(mappin.type.value, typeFilterStr1) then takeIt = true end
						if takeIt ~= true and typeFilterStr2 and stringFind(mappin.type.value, typeFilterStr2) then takeIt = true end
					end
					if takeIt then tableInsert(closeMappins, mappin) end
				end
			end
		end
	end

	local size = #closeMappins
	if size == 0 then return false end
	if size == 1 then return closeMappins[1] end

	lowestDistanceIndex = 0
	lowestDistanceSquared = 1000000000

	for i = 1, size do
		local distSquared = vectorDistanceSquared(objectPos, closeMappins[i].worldPosition)
		if distSquared < lowestDistanceSquared then
			lowestDistanceSquared = distSquared
			lowestDistanceIndex = i
		end
	end

	if lowestDistanceIndex > 0 and lowestDistanceSquared <= range * range then
		return closeMappins[lowestDistanceIndex]
	end
end

function logic.couldStartNewLootingCycle(player)
	player = player or GetPlayer()
	logic.isPlayerInWorkspot = isPlayerInWorkspot(player)
	if logic.isPlayerInWorkspot then return false end
	if isAnyGamePausingScreen(player) then return false end
	if isPlayerSpecialMode(player) then return false end
	if isMessagePopupOnScreen() then return false end
	if isPlayerInComputerControl(player) then return end
	if isPlayerControllingDevice(player) then return end
	if isPlayerInFastTravel() then return false end
	if isPlayerInBraindance() then return false end
	if isExcludedSpecialQuestCase(player) then return false end
	return true
end

function logic.isLootingTime(isBurstMode, player)
	player = player or GetPlayer()
	logic.isPlayerInWorkspot = isPlayerInWorkspot(player)

	if type(logic.cooldown) == 'number' then if os.clock() > logic.cooldown then logic.cooldown = 0 end else logic.cooldown = 0 end
	if logic.cooldown > 0 then return end

	logic.isAnyDialogOnScreen = isDialogOpen()
	logic.isAnyOtherInteractonOnScreen = isInteractionsOpen()
	
	if lastTerminalInteractionActive then
		if lastCursorDeviceGameController then
			if IsDefinedS(lastCursorDeviceGameController) then
				if not lastCursorDeviceGameController.cursorDevice:IsVisible() then
					lastTerminalInteractionActive = false
				end
			else
				lastTerminalInteractionActive = false
			end
		else
			lastTerminalInteractionActive = false
		end
	end
	if not logic.isAnyOtherInteractonOnScreen then logic.isAnyOtherInteractonOnScreen = lastTerminalInteractionActive end
	if not logic.isLootDialogOnScreen then
		if logic.isAnyDialogOnScreen then
			if not isBurstMode then logic.cooldown = os.clock() + 0.75 end
			return
		end
		if logic.isAnyOtherInteractonOnScreen then
			if not isBurstMode then logic.cooldown = os.clock() + 0.25 end
			return
		end
	end

	if logic.isPlayerInWorkspot then return false end
	if isAnyGamePausingScreen(player) then return false end
	if isPlayerSpecialMode(player) then return false end
	if isMessagePopupOnScreen() then return false end
	if (not isBurstMode) and isPlayerScanning(player) then return false end
	if isPlayerInComputerControl(player) then return end
	if isPlayerControllingDevice(player) then return end
	if isPlayerInFastTravel() then return false end
	if isPlayerInBraindance() then return false end
	if isExcludedSpecialQuestCase(player) then return false end

	logic.cooldown = 0
	return true
end

local questCaseLookup = {}
questCaseLookup['1460153075'] = true
questCaseLookup['1414086225'] = true

questCaseLookup['3328820332'] = true
questCaseLookup['1168297061'] = true
questCaseLookup['154249429'] = true
questCaseLookup['1250604633'] = true
questCaseLookup['4108023166'] = true
questCaseLookup['1835019893'] = true
questCaseLookup['1398556930'] = true
questCaseLookup['3419664323'] = true
questCaseLookup['2132897075'] = true
questCaseLookup['1132732560'] = true
questCaseLookup['2174942521'] = true
questCaseLookup['3371346292'] = true
questCaseLookup['484372288'] = true
questCaseLookup['2468090174'] = true
questCaseLookup['2708428634'] = true
questCaseLookup['3643888599'] = true

local refPos
local function isInRange(player)
	player = player or GetPlayer()
	if not player then return end
	refPos = refPos or Vector4new(-1455.15, 1312, 119.1, 1)
	return vectorDistanceSquared(player:GetWorldPosition(), refPos) < 3025
end
questCaseLookup['694730282'] = isInRange
questCaseLookup['751325220'] = isInRange
questCaseLookup['2957282811'] = true
questCaseLookup['3556076006'] = true

function isExcludedSpecialQuestCase(player)
	if questsSystem:GetFactStr("q307_point_of_no_return") > 0 then return true end
	local objective = journalManager:GetTrackedEntry()
	if not objective then return false end
	local hash = journalManager:GetEntryHash(objective)
	if hash < 0 then hash = hash + 4294967296 end
	local result = questCaseLookup[tostring(hash)]
	if type(result) ~= 'function' then return result end
	return result(player)
end

function isMessagePopupOnScreen()
	if not lastPhoneMessagePopupGameController then return false end
	if not IsDefinedS(lastPhoneMessagePopupGameController) then return end
	if not isGameV2 then return true end
	return lastPhoneMessagePopupGameController.isFocused
end

function isDialogOnScreen()
	local dialogChoiceHubs = FromVariant(gameBlackBoardSystem:Get(allBlackboardDefsUIInteractions):GetVariant(allBlackboardDefsUIInteractionsDialogChoiceHubs))
	if dialogChoiceHubs then return #dialogChoiceHubs.choiceHubs > 0 end
end

function isDialogOpen()
	if isDialogOnScreen() then return true end
	if lastDialogWidgetGameController and IsDefined(lastDialogWidgetGameController) and lastDialogWidgetGameController.hubAvailable then return true end
	if lastInteractionUIBase and IsDefined(lastInteractionUIBase) then
		local rootWidget = lastInteractionUIBase:GetRootWidget()
		if rootWidget then
			local numChildren = rootWidget:GetNumChildren()
			if numChildren > 1 then
				local hubWidget = rootWidget:GetWidgetByPathName(CName.new('hub'))
				if hubWidget and hubWidget:GetNumChildren() > 1 then return true end
			end
		end
	end
	if type(logic.lastHubCountReset) == 'number' and os.clock() - logic.lastHubCountReset < 0.5 then return true end
end

function isLootingOpen()
	if not lastLootingController then return false end
	if not IsDefinedS(lastLootingController) then return false end
	return lastLootingController:IsShown()
end

function isInteractionsOpen()
	if logic.isNativeHubLeftoverActive then return true end
	if not lastInteractionUIBase then return false end
	if not IsDefinedS(lastInteractionUIBase) then return false end
	if not lastInteractionUIBase.AreInteractionsOpen then return false end
	return true
end

function isPlayerInVehicle(player)
	player = player or GetPlayer()
	if not player then return end
	return GetMountedVehicle(player)
end

function isPlayerScanning()
	local scannerMode = FromVariant(gameBlackBoardSystem:Get(allBlackboardDefsUI_Scanner):GetVariant(allBlackboardDefsUI_ScannerScannerMode))
	if not scannerMode then return end
	local mode = scannerMode.mode
	if not mode then return end
	return mode ~= gameScanningMode.Inactive
end

function isPlayerInBraindance()
	return gameBlackBoardSystem:Get(allBlackboardDefsBraindance):GetBool(allBlackboardDefsBraindanceIsActive)
end

function isPlayerInFastTravel()
	if gameBlackBoardSystem:Get(allBlackboardDefsFastTRavelSystem):GetBool(allBlackboardDefsFastTRavelSystemFastTravelLoadingScreenFinished) then return false end	
	if not FromVariant(gameBlackBoardSystem:Get(allBlackboardDefsFastTRavelSystem):GetVariant(allBlackboardDefsFastTRavelSystemDestinationPoint)) then return false end
	return true
end

function isPlayerInComputerControl(player)
	player = player or GetPlayer()
	if not player then return true end
	local isUIZoomDevice = false
	pcall(function() isUIZoomDevice = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefsPlayerStateMachine):GetBool(allBlackboardDefsPlayerStateMachineIsUIZoomDevice) end)
	return isUIZoomDevice
end

function isPlayerControllingDevice(player)
	player = player or GetPlayer()
	if not player then return true end
	local isDevice = false
	pcall(function() isDevice = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefsPlayerStateMachine):GetBool(allBlackboardDefsPlayerStateMachineIsControllingDevice) end)
	return isDevice
end

function isAnyGamePausingScreen(player)
	local result, blackboardSystem = pcall(function() return gameBlackBoardSystem:Get(allBlackboardDefsUI_System) end)
	if not blackboardSystem then return true end
	if blackboardSystem:GetBool(allBlackboardDefsUI_SystemIsInMenu) then return true end
	local systemRequestsHandler = GameGetSystemRequestsHandler()
	if isPreGame(systemRequestsHandler) then return true end
	if isGamePaused(systemRequestsHandler) then return true end
	if isPlayerDetached(player) then return true end
	if isLoadingBar() then return true end
	if isRadialWheel() then return true end
	if isPhotoMode() then return true end
	if isTutorial() then return true end
end

local restrictionTags
function isPlayerSpecialMode(player)
	player = player or GetPlayer()
	if not player then return true end
	local sceneTier = player:GetSceneTier()
	if sceneTier < 1 then return true end
	if sceneTier == 6 then return end
	if sceneTier >= 3 then return true end
	if player:IsReplacer() then return true end
	if player:IsJohnnyReplacer() then return true end
	restrictionTags = restrictionTags or {n"Defeated", n"Cyberspace", n"CyberspacePresence"}
	if StatusEffectSystem.ObjectHasStatusEffectWithTags(player, restrictionTags) then return true end
end

function isPreGame(systemRequestsHandler)
	systemRequestsHandler = systemRequestsHandler or GameGetSystemRequestsHandler()
	return systemRequestsHandler:IsPreGame()
end

function isGamePaused(systemRequestsHandler)
	systemRequestsHandler = systemRequestsHandler or GameGetSystemRequestsHandler()
	return systemRequestsHandler:IsGamePaused()
end

function isPlayerDetached(player)
	player = player or GetPlayer()
	if not player then return true end
	local streetCred = false
	pcall(function() streetCred = statsSystem:GetStatValue(player:GetEntityID(), 'StreetCred') end) --(c)psiberx)
	if not streetCred then return true end
	if streetCred < 1 then return true end
end

function isLoadingBar()
	if not lastLoadingScreenProgressBarController then return false end
	if not IsDefinedS(lastLoadingScreenProgressBarController) then return false end	
	local rootWidget = lastLoadingScreenProgressBarController.progressBarRoot
	if rootWidget then return rootWidget:IsVisible() end
end

function isRadialWheel()
	if timeSystem:IsTimeDilationActive('radial') then return true end -- (c)psiberx hint
end

function isPhotoMode()
	local isActive = false
	pcall(function() isActive = gameBlackBoardSystem:Get(allBlackboardDefsPhotoMode):GetBool(allBlackboardDefsPhotoModeIsActive) end)
	if isActive then return true end
end

function isTutorial()
	if not lastTutorialMainController then return false end
	if not IsDefinedS(lastTutorialMainController) then return false end
	if lastTutorialMainController.tutorialActive then return true end
end

-- raycast helper:

-- this part is a modified extract from TargetingHelper.lua example by (c)psiberx
--https://github.com/WolvenKit/cet-examples
local obstacles = {
	'Static',
	'Terrain',
	'PlayerBlocker'
}
local isBinaryTable
function cNameTable(array) if type(array) ~= 'table' then return end for i = 1, #array do array[i] = CName.new(array[i]) end end
function getHitPointFromTo(from, to, staticOnly)
	if not staticOnly then staticOnly = false end
	if not isBinaryTable then cNameTable(obstacles) isBinaryTable = true end
	local results = {}
	for i, filter in ipairs(obstacles) do
		local success, result = spatialQueriesSystem:SyncRaycastByCollisionGroup(from, to, filter, staticOnly, false)
		if success then
			local resultPosition = Vector4.Vector3To4(result.position)
			tableInsert(results, {
				distance = vectorDistanceSquared(from, resultPosition),
				position = resultPosition,
				material = result.material
			})
		end
	end

	if #results == 0 then return end

	local hitPoints = {}
	tableInsert(hitPoints, {position = results[1].position, materials = results[1].material.value})
	local nearest = results[1]
	for i = 2, #results do
		if results[i].distance < nearest.distance then nearest = results[i] tableInsert(hitPoints, {position = results[i].position, materials = results[i].material.value})
		elseif results[i].distance == nearest.distance then
			local resultsPosition = results[i].position
			for ii = 2, #hitPoints do
				local hitPointPosition = hitPoints[ii].position
				if hitPointPosition.x == resultsPosition.x and hitPointPosition.y == resultsPosition.y and hitPointPosition.z == resultsPosition.z then
					local hitPointMaterials = hitPoints[ii].materials
					if hitPointMaterials then
						hitPoints[ii].materials = hitPointMaterials..','..results[i].material.value
					else
						hitPoints[ii].materials = results[i].material.value
					end
				end
			end
		end
	end

	return nearest.position, hitPoints
end

return logic