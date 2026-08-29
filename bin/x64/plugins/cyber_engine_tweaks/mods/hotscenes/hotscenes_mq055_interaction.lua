-- Jun 6, 2026 by (c)anygoodname

local moduleVer = 'v2.7.6'
local moduleName = 'Hotscenes mq055 hangouts quests interaction integration module'
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
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--


local Ref = require('Ref')
if not Ref then return end

local enable_mq055_hangouts_support = false
local gameVer = 0
local isGameV2 = false
local isModuleDisabled = false

local workspotSystem, questsSystem
local interationCtl = nil
local n, t
local isInitialized = false
local topEntry = nil
local customChoices = {}
local lastCustomChoicesMenuId = 0
local isMyChoiceOnScreen = false
local mod_hotscenes_interaction_action_performed_cooldown
local mod_modscenes_mq055_integration_interaction_choiceApply_cooldown
local mod_modscenes_mq055_integration_native_interaction_request_cooldown
local choiceMergeMode = 0
local topEntryMenuId = 45
local destinationsMeduId = 55

local n_freeze_input_cooldown = "freeze_input_cooldown"

local self = {moduleVer = moduleVer, moduleName = moduleName, modAuthorName = modAuthorName, isActive = false, isCustomInteractionAllowed = false, appendOnTop = true, hotsceneDestinations = nil, preferMyNativeInteraction = false}

function self.init()
	if isInitialized  then return isInitialized end
	if not GetPlayer then return isInitialized end
	if not GetPlayer() then return isInitialized end

	if isModuleDisabled then
		self.isActive = false
		self.isCustomInteractionAllowed = false
		return false
	end

	gameVer = tonumber(Game.GetSystemRequestsHandler():GetGameVersion())
	isGameV2 = gameVer >= 2.0
	if isGameV2 then enable_mq055_hangouts_support = gameVer >= 2.1 end

	if not enable_mq055_hangouts_support then
		print(moduleName, moduleVer, 'Unsupported game version. This module is disabled now.')
		isModuleDisabled = true
		self.isActive = false
		self.isCustomInteractionAllowed = false
		return false
	end

	pcall(function()
		if ArchiveXL and ArchiveXL.Version() then isArchiveXLActive = true end
	end)

	if not isArchiveXLActive then
		print(moduleName, moduleVer, 'ArchiveXL is not found active. This module is disabled now.')
		isModuleDisabled = true
		self.isActive = false
		self.isCustomInteractionAllowed = false
		return false
	end

	n = CName
	t = TweakDBID

	mod_hotscenes_interaction_action_performed_cooldown = n"mod_hotscenes_interaction_action_performed_cooldown"
	mod_modscenes_mq055_integration_interaction_choiceApply_cooldown = n"mod_modscenes_mq055_integration_interaction_choiceApply_cooldown"
	mod_modscenes_mq055_integration_native_interaction_request_cooldown = n"mod_modscenes_mq055_integration_native_interaction_request_cooldown"

	n_freeze_input_cooldown = n"freeze_input_cooldown"

	myNativeInteractionCancelAll(true)
	self.switchToTopEntry()

	setObservers()
	isInitialized = true
	print(moduleName, moduleVer, 'is initialized')
	return true
end

function isKnownName(inputString)
	return CName.new(inputString).value == inputString
end

self.supportedScenesPool = {mq055_02_megabuilding_active = false, mq055_02_northside_active = false, mq055_02_japantown_active = false, mq055_02_heywood_active = false, mq055_02_downtown_active = false}

-- This snippet comes from the interaction.lua script example by keanuWheeze
---@param localizedName string
---@param icon gamedataChoiceCaptionIconPart_Record
---@param choiceType gameinteractionsChoiceType
---@return gameinteractionsvisListChoiceData
function self.createChoice(localizedName, icon, choiceType) -- Creates and returns a choice
    local choice = gameinteractionsvisListChoiceData.new()
    choice.localizedName = localizedName or "Choice"
    choice.inputActionName = "None"

    if icon then
        local part = gameinteractionsChoiceCaption.new()
        part:AddPartFromRecord(icon)
        choice.captionParts = part
    end

    if choiceType then
        local choiceT = gameinteractionsChoiceTypeWrapper.new()
        choiceT:SetType(choiceType)
        choice.type = choiceT
    end

    return choice
end

function self.addCustomChoice(choice, callback)
	if type(choice) ~= 'userdata' then return end
	if type(callback) ~= 'function' then return end
	table.insert(customChoices, {choice = choice, callback = callback})
	return #customChoices
end

function self.clearCustomChoices()
	customChoices = {}
	lastCustomChoicesMenuId = 0
end

function self.hideAndLockInteractions(timeout)
	if IsDefined(interationCtl) then
		customChoices = {}
		lastCustomChoicesMenuId = 0
		interationCtl:OnDialogsData(ToVariant(DialogChoiceHubs.new()))
	end
	if type(timeout) ~= 'number' or timeout < 0 then timeout = 5 end
	timeout = ClampF(timeout, 0, 30)

	if timeout > 0 then
		if timeout > 0 then GetPlayer():StartCooldown(mod_hotscenes_interaction_action_performed_cooldown, timeout) end
	end
end

function self.clearAndLockInteractions(timeout)
	if IsDefined(interationCtl) then
		customChoices = {}
		lastCustomChoicesMenuId = 0
		interationCtl.InteractionsBlackboard:SignalVariant(interationCtl.InteractionsBBDefinition.DialogChoiceHubs)
		interationCtl.InteractionsBlackboard:SignalInt(interationCtl.InteractionsBBDefinition.SelectedIndex)
	end
	if type(timeout) ~= 'number' or timeout < 0 then timeout = 5 end
	timeout = ClampF(timeout, 0, 30)

	if timeout > 0 then
		GetPlayer():StartCooldown(mod_hotscenes_interaction_action_performed_cooldown, timeout)
	end
end

function self.enableCustomChoices()
	if isModuleDisabled then
		self.isActive = false
		self.isCustomInteractionAllowed = false
		return false
	end
	if isCensored() then self.isCustomInteractionAllowed = false return false end
	self.isCustomInteractionAllowed = true
	restoreNativeInteraction()
	return true
end

function self.disableCustomChoices(force)
	self.isCustomInteractionAllowed = false
	myNativeInteractionCancelAll(force, force)
	return true
end

function self.isEnableCustomChoices()
	return self.isCustomInteractionAllowed
end

function self.isCustomChoiceOnScreen()
	return isMyChoiceOnScreen or isMyNativeInteractionHubShown()
end

self.hotsceneDestinations = {
	sq029 =				{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#12274", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_sq029_choice", payload = function() print('payload:', 'sq020', os.clock()) end},
	sq030 =				{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#12315", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_sq030_choice", payload = function() print('payload:', 'sq030', os.clock()) end},
	aph10 =				{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#44392", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_aph10_choice", payload = function() print('payload:', 'aph10', os.clock()) end},
	kerry_villa =		{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#37094", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_kerry_villa_choice", payload = function() print('payload:', 'kerry_villa', os.clock()) end},
	cct_dtn_apt_01 =	{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#80746", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_cct_dtn_apt_01_choice", payload = function() print('payload:', 'cct_dtn_apt_01', os.clock()) end},
	apart_hey_gle =		{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#80747", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_apart_hey_gle_choice", payload = function() print('payload:', 'apart_hey_gle', os.clock()) end},
	wbr_jpn_apt_01 =	{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#80749", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_wbr_jpn_apt_01_choice", payload = function() print('payload:', 'wbr_jpn_apt_01', os.clock()) end},
	q203_penthouse =	{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#9308", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_q203_penthouse_choice", payload = function() print('payload:', 'q203_penthouse', os.clock()) end},
	cct_dtn_05 =		{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#44473", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_cct_dtn_05_choice", payload = function() print('payload:', 'cct_dtn_05', os.clock()) end},
	dollhouse =			{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#44401", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_dollhouse_choice", payload = function() print('payload:', 'dollhouse', os.clock()) end},
	arasaka_hotel =		{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#44385", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_arasaka_hotel_choice", payload = function() print('payload:', 'arasaka_hotel', os.clock()) end},
	defaultJapantown =	{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#79214", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_defaultJapantown_choice", payload = function() print('payload:', 'defaultJapantown', os.clock()) end},
	defaultGlen =		{entryName = nil, isEnabled = false, hubText = "LocKey#16330", optionText = "LocKey#44405", enableNativeInteractionFact = "mod_hotscenes_mq055_interaction_show_defaultGlen_choice", payload = function() print('payload:', 'defaultGlen', os.clock()) end},
}

-- Warning: with the native interaction introduced in v3.18.2, this choice order is hardcoded in the scene file so do not change it here or choice callbacks will get out of sync with the native interaction:
local hotsceneDestinationsOrdered = {
	self.hotsceneDestinations.sq029,
	self.hotsceneDestinations.sq030,
	self.hotsceneDestinations.aph10,
	self.hotsceneDestinations.kerry_villa,
	self.hotsceneDestinations.cct_dtn_apt_01,
	self.hotsceneDestinations.apart_hey_gle,
	self.hotsceneDestinations.wbr_jpn_apt_01,
	self.hotsceneDestinations.q203_penthouse,
	self.hotsceneDestinations.cct_dtn_05,
	self.hotsceneDestinations.dollhouse,
	self.hotsceneDestinations.arasaka_hotel,
	self.hotsceneDestinations.defaultJapantown,
	self.hotsceneDestinations.defaultGlen,
}

function self.disableAllDestinations()
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	for keyName, destination in pairs(self.hotsceneDestinations) do;
		destination.isEnabled = false
		questsSystem:SetFactStr(destination.enableNativeInteractionFact, 0);
	end;
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_skip_top_entry_hub", 0);
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice", 0);
end

function restoreNativeInteraction()
	if not isMyChoiceOnScreen then return end
	if choiceMergeMode ~= 2 then return end
	if not isMyNativeInteractionActive() then return end
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	if questsSystem:GetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice") > 0 then return end
	local isAnyDestinationEnabled = false
	for keyName, destination in pairs(self.hotsceneDestinations) do;
		if destination.isEnabled then questsSystem:SetFactStr(destination.enableNativeInteractionFact, 1) isAnyDestinationEnabled = true end
	end;
	if isAnyDestinationEnabled then questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice", 1) end
end

function self.isAnyChoiceCreated()
	return #customChoices > 0
end

function self.createTopEntry()
	customChoices = {}
	lastCustomChoicesMenuId = 0

	local isAnyDestinationEnabled = false
	for keyName, destination in pairs(self.hotsceneDestinations) do
		if destination.isEnabled then isAnyDestinationEnabled = true break end
	end

	if not isAnyDestinationEnabled then return end

	if not topEntry then
		topEntry = {}
		topEntry.hubText = "LocKey#16330"
		topEntry.optionText = "LocKey#18463"
		topEntry.choice = self.createChoice(GetLocalizedText(topEntry.optionText), TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.ProstituteIcon"), gameinteractionsChoiceType.QuestImportant)
		topEntry.callback = function()
			if IsDefined(interationCtl) then
				self.createDestinations()
				interationCtl.InteractionsBlackboard:SignalVariant(interationCtl.InteractionsBBDefinition.DialogChoiceHubs)
				return true
			end
			return false
		end
	end

	self.addCustomChoice(topEntry.choice, topEntry.callback)
	lastCustomChoicesMenuId = topEntryMenuId
end

self.switchToTopEntry = self.createTopEntry

function self.createDestinations()
	local isAnyDestinationEnabled = false
	for keyName, destination in pairs(self.hotsceneDestinations) do
		if destination.isEnabled then isAnyDestinationEnabled = true break end
	end
	if not isAnyDestinationEnabled then return end

	customChoices = {}
	lastCustomChoicesMenuId = 0
	for i, hotsceneDestination in ipairs(hotsceneDestinationsOrdered) do
		if hotsceneDestination.isEnabled then
			if not hotsceneDestination.entryName then hotsceneDestination.entryName = "["..GetLocalizedText(hotsceneDestination.hubText).."]"..GetLocalizedText(hotsceneDestination.optionText) end
			self.addCustomChoice(self.createChoice(hotsceneDestination.entryName, TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.ProstituteIcon"), gameinteractionsChoiceType.QuestImportant), function()
				if type(hotsceneDestination.payload) == 'function' then
					local result, data = pcall(function() return hotsceneDestination.payload() end)
					if not result then
						print(data)
						spdlog.error(data)
						return result
					end
					self.clearAndLockInteractions()
					return true
				else
					self.switchToTopEntry()
					if IsDefined(interationCtl) then interationCtl.InteractionsBlackboard:SignalVariant(interationCtl.InteractionsBBDefinition.DialogChoiceHubs) end
				end
			end)
			lastCustomChoicesMenuId = destinationsMeduId
		end
	end
end

function isCensored()
	return not Game.GetCharacterCustomizationSystem():IsNudityAllowed()
end

function isMyNativeInteractionAvailable();
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;;
	return isKnownName("mod_hotscenes_mq055_native_interaction_available")
end;
function isMyNativeInteractionActive();
	if not isMyNativeInteractionAvailable() then return false end;
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;;
	return questsSystem:GetFactStr("mod_hotscenes_mq055_interaction_is_active") > 0;
end;
function isMyNativeInteractionHubShown(skipPreCheck);
	if (not skipPrecheck) and (not isMyNativeInteractionAvailable()) then return end;
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	return questsSystem:GetFactStr("mod_hotscenes_mq055_interaction_is_showtime") > 1;
end;
self.isMyNativeInteractionHubShown = isMyNativeInteractionHubShown
function isMyNativeInteractionFirstEntryShown(skipPreCheck);
	if (not skipPrecheck) and (not isMyNativeInteractionAvailable()) then return end;
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	return questsSystem:GetFactStr("mod_hotscenes_mq055_interaction_is_showtime") == topEntryMenuId
end;
function isMyNativeInteractionDestinationsShown(skipPreCheck);
	if (not skipPrecheck) and (not isMyNativeInteractionAvailable()) then return end;
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	return questsSystem:GetFactStr("mod_hotscenes_mq055_interaction_is_showtime") == destinationsMeduId
end;
function myNativeInteractionShowSequence(skipPreCheck);
	if (not skipPrecheck) and (not isMyNativeInteractionActive()) then return end;
	if GetPlayer():IsCooldownActive(mod_modscenes_mq055_integration_native_interaction_request_cooldown) then
		return
	end
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	local isAnyDestinationEnabled = false;
	for keyName, destination in pairs(self.hotsceneDestinations) do;
		if destination.isEnabled then;
			questsSystem:SetFactStr(destination.enableNativeInteractionFact, 1);
			isAnyDestinationEnabled = true;
		else;
			questsSystem:SetFactStr(destination.enableNativeInteractionFact, 0);
		end;
	end;
	if not isAnyDestinationEnabled then return end;
	GetPlayer():StartCooldown(mod_modscenes_mq055_integration_native_interaction_request_cooldown, 0.25)
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice", 1);
	return true;
end;
function myNativeInteractionShowDestinationsOnly(skipPreCheck);
	if (not skipPrecheck) and (not isMyNativeInteractionActive()) then return end;
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	local isAnyDestinationEnabled = false
	for keyName, destination in pairs(self.hotsceneDestinations) do
		if destination.isEnabled then
			questsSystem:SetFactStr(destination.enableNativeInteractionFact, 1)
			isAnyDestinationEnabled = true
		else
			questsSystem:SetFactStr(destination.enableNativeInteractionFact, 0)
		end
	end
	if not isAnyDestinationEnabled then return end
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_skip_top_entry_hub", 1);
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice", 1);
	return true
end;
function myNativeInteractionCancelAll(force, skipPreCheck);
	if (not force) and (not isMyNativeInteractionHubShown()) then return end
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_skip_top_entry_hub", 0);
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_show_prostitute_choice", 0);
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_is_showtime", 0);
	if (not skipPrecheck) and (not isMyNativeInteractionAvailable()) then return end;
	questsSystem:SetFactStr("mod_hotscenes_mq055_interaction_cancel_interaction", 1);
end;


local mq055_OnSofaConditionFacts = {
	mq055_02_megabuilding_active = {"mq055_02_megabuilding_active", "mq055_cuddle_start", "mq055_apt_interactions_off", "mq055_megabuilding_partner_on_sofa", "mq055_v_sits_sofa", "mq055_cuddle_loop_finished"},
	mq055_02_northside_active = {"mq055_02_northside_active", "mq055_02_intimate_action_on", "mq055_02_player_sits", "mq055_02_cuddleloop_done", partnerSitOptions = {"mq055_02_judy_sits", "mq055_02_kerry_sits", "mq055_02_panam_sits", "mq055_02_river_sits"}},
	mq055_02_japantown_active = {"mq055_02_japantown_active", "mq055_03_intimate_action_on", "mq055_03_player_sits", partnerCuddleOptions = {"mq055_03_judy_cuddleloop_done", "mq055_03_kerry_cuddleloop_done", "mq055_03_panam_cuddleloop_done", "mq055_03_river_cuddleloop_done"}, partnerSitOptions = {"mq055_03_judy_sits", "mq055_03_kerry_sits", "mq055_03_panam_sits", "mq055_03_river_sits"}},
	mq055_02_heywood_active = {"mq055_02_heywood_active", "mq055_04_intimate_action_on", "mq055_04_player_sits", partnerCuddleOptions = {"mq055_04_judy_cuddleloop_done", "mq055_04_kerry_cuddleloop_done", "mq055_04_panam_cuddleloop_done", "mq055_04_river_cuddleloop_done"}, partnerSitOptions = {"mq055_04_judy_sits", "mq055_04_kerry_sits", "mq055_04_panam_sits", "mq055_04_river_sits"}},
	mq055_02_downtown_active = {"mq055_02_downtown_active", "mq055_05_intimate_action_on", "mq055_05_player_sits", "mq055_cuddle_loop_finished", "mq055_05_npc_sits", "mq055_05_sofa_sit_active"},
}

function mq055_IsOnCouchSceneActive(player);
	if not player then player = GetPlayer() end;
	if player:GetMountedVehicle() then return end
	if not workspotSystem then workspotSystem = Ref.Weak(Game.GetWorkspotSystem()) end
	if not workspotSystem:IsActorInWorkspot(player) then return end
	if not questsSystem then questsSystem = Ref.Weak(Game.GetQuestsSystem()) end;
	for factSetName, factSet in pairs(mq055_OnSofaConditionFacts) do;
		local isFactSetActive = false;
		if type(factSet) == 'table' and self.supportedScenesPool[factSetName] then;
			for _, factData in pairs(factSet) do;
				isFactSetActive = true
				local factType = type(factData)
				if factType == 'string'then
					isFactSetActive = questsSystem:GetFactStr(factData) > 0
					if not isFactSetActive then break end
				elseif factType == 'table' then
					local isAnythingMatching = false;
					for moreFactsSet, moreFactData in pairs(factData) do
						if type(moreFactData) == 'string' and questsSystem:GetFactStr(moreFactData) > 0 then isAnythingMatching = true break end;
					end
					if not isAnythingMatching then isFactSetActive = false break end;
				else
					isFactSetActive = false;
				end;
			end;
		end;
		if isFactSetActive then return factSetName end;
	end
	return false;
end;

local gameNativeInteractionHubIndex = -1
local gameNativeInteractionHubId = -1
local isGameNativeInteractionSingleChoiceType = false
local myNativeInteractionHubIndex = -1
local myNativeInteractionHubId = -1

function isItLookedInteraction(this, inputData)
	gameNativeInteractionHubIndex = -1
	gameNativeInteractionHubId = -1
	myNativeInteractionHubIndex = -1
	myNativeInteractionHubId = -1
	if not this then return end

	inputData = inputData or this.data;
	if type(inputData.choiceHubs) ~= 'table' then return end
	if not mq055_IsOnCouchSceneActive() then return end;

	local hubsCount = #inputData.choiceHubs
	if hubsCount < 1 or hubsCount > 2 then return end;

	for i = 1, hubsCount do
		local choiceHub = inputData.choiceHubs[i]
		if GetLocalizedText(choiceHub.title) == GetLocalizedText("LocKey#46134") then return end
		if choiceHub.title == "LocKey#16330" then
			myNativeInteractionHubIndex = i
			myNativeInteractionHubId = choiceHub.id
		else
			local choices = choiceHub.choices
			if choices and #choices > 0 then
				local captionParts = choices[1].captionParts
				if captionParts then
					parts = captionParts.parts
					if parts and #parts > 0 then
						local part = parts[1]
						if part:GetType() == gamedataChoiceCaptionPartType.Icon and
							part.iconRecord and
							part.iconRecord:EnumName().value == "GetUp"
						then
							gameNativeInteractionHubIndex = i
							gameNativeInteractionHubId = choiceHub.id
						end
					end
				end
			end
		end
	end
	return (gameNativeInteractionHubIndex > 0 or myNativeInteractionHubIndex > 0)
end

local originalIteractionChoiceFirstIndex = -1
local originalIteractionChoiceLastIndex = -1
local myIteractionChoiceFirstIndex = -1
local myIteractionChoiceLastIndex = -1
local combinedIteractionChoiceLastIndex = -1
local currentCombinedIteractionChoiceIndex = -1
local lastKeyPress = 0
	
function setObservers()
	if isModuleDisabled then return end
	if isInitialized then return end

	ObserveAfter("PlayerPuppet", "OnGameAttached", function(this);
		if this:IsReplacer() then return end
		myNativeInteractionCancelAll(true)
		self.switchToTopEntry()
	end)

	function appendCustomChoices(this, inputData)
		inputData = inputData or this.data;
		if gameNativeInteractionHubIndex < 0 then return end
		if gameNativeInteractionHubIndex > #inputData.choiceHubs then return end
		local lookedChoiceHub = inputData.choiceHubs[gameNativeInteractionHubIndex]
		if not lookedChoiceHub then return end

		if #lookedChoiceHub.choices ~= 1 then return end

		local choices = lookedChoiceHub.choices;
		local newChoices = {}
		if self.appendOnTop then
			for i = 1, #customChoices do
				table.insert(newChoices, customChoices[i].choice)
			end
			table.insert(newChoices, choices[1])
		else
			table.insert(newChoices, choices[1])
			for i = 1, #customChoices do
				table.insert(newChoices, customChoices[i].choice)
			end
		end
		lookedChoiceHub.choices = newChoices;
		inputData.choiceHubs = {lookedChoiceHub};
		return inputData
	end

	Override("InteractionUIBase", "OnDialogsData", function(this, value, wrapped);
		isMyChoiceOnScreen = false
		choiceMergeMode = 0
		if isModuleDisabled then return wrapped(value) end
		local result, output = pcall(function()
			interationCtl = Ref.Weak(this);
			if not self.isCustomInteractionAllowed then return wrapped(value) end;
			if #customChoices < 1 then return wrapped(value) end;
			if isCensored() then return wrapped(value) end;

			local inputData = FromVariant(value);
			local shouldUseThisInteraction = isItLookedInteraction(this, inputData)

			if not shouldUseThisInteraction then
				myNativeInteractionCancelAll()
				return wrapped(value)
			end;

			if myNativeInteractionHubIndex >= 0 and gameNativeInteractionHubIndex >= 0 then
				choiceMergeMode = 2
				isMyChoiceOnScreen = true
				return wrapped(value);
			else
				if myNativeInteractionHubIndex >= 0 then
					myNativeInteractionCancelAll(true, true)
					return false
				elseif gameNativeInteractionHubIndex >= 0 then
					local choices = inputData.choiceHubs[1].choices
					local choicesCount = #choices
					isGameNativeInteractionSingleChoiceType = choicesCount == 1
					if not isGameNativeInteractionSingleChoiceType then
						local choicesCount = #choices
						if choicesCount - #customChoices == 1 then
							for i = 1, choicesCount do
								if inputData.choiceHubs[1].choices[i].localizedName == customChoices[1].choice.localizedName then
									isGameNativeInteractionSingleChoiceType = true
									break
								end
							end
						end
					end

					local shouldUseMyNativeInteraction = self.preferMyNativeInteraction and isMyNativeInteractionActive()

					if (not shouldUseMyNativeInteraction) and isGameNativeInteractionSingleChoiceType then
						inputData = appendCustomChoices(this, inputData);
						if inputData then
							choicesCount = #inputData.choiceHubs[1].choices
							currentCombinedIteractionChoiceIndex = 0
							combinedIteractionChoiceLastIndex = choicesCount - 1
							if self.appendOnTop then
								originalIteractionChoiceFirstIndex = choicesCount - 1
								originalIteractionChoiceLastIndex = originalIteractionChoiceFirstIndex
								myIteractionChoiceFirstIndex = 0
								myIteractionChoiceLastIndex = originalIteractionChoiceFirstIndex - 1
							else
								originalIteractionChoiceFirstIndex = 0
								originalIteractionChoiceLastIndex = 0
								myIteractionChoiceFirstIndex = 1
								myIteractionChoiceLastIndex = choicesCount -1
							end
							value = ToVariant(inputData)
							choiceMergeMode = 1
							isMyChoiceOnScreen = true
							return wrapped(value);
						end
					else
						local test = isMyNativeInteractionHubShown()
						if isMyNativeInteractionHubShown() then
							choiceMergeMode = 2
							isMyChoiceOnScreen = true
							return wrapped(value);
						elseif myNativeInteractionShowSequence() then
							choiceMergeMode = 2
							isMyChoiceOnScreen = true
							return wrapped(value);
						end
					end
				end
			end
			return wrapped(value);
		end)

		if result then return output end
		print(output)
		spdlog.error(output)
		return wrapped(value);
	end)

	local isLockInteractionsCooldownActive = false
	Observe('PlayerPuppet', 'OnAction', function(this, action, consumer)
		if isModuleDisabled then return end
		if not self.isCustomInteractionAllowed then return end
		if not IsDefined(interationCtl) then return end
		isLockInteractionsCooldownActive = this:IsCooldownActive(mod_hotscenes_interaction_action_performed_cooldown)
		if this:IsCooldownActive(n_freeze_input_cooldown) then consumer.Consume(consumer) return end
		if (not isMyChoiceOnScreen) and (not isLockInteractionsCooldownActive) then return end
		if choiceMergeMode < 1 then return end
		if choiceMergeMode == 1 then return handleSingleOptionGameInteractionAction(this, action, consumer) end
		if choiceMergeMode == 2 then return handleMyNativeInteractionAction(this, action, consumer) end
	end)

	function handleMyNativeInteractionAction(this, action, consumer)
        if action:IsAction('ChoiceScrollUp') then
			return
		elseif action:IsAction('ChoiceScrollDown') then
			return
		elseif action:IsAction('ChoiceApply') then
			if myNativeInteractionHubIndex < 0 then return end
			if myNativeInteractionHubId < 0 then return end
			local activeChoiceHubID = interationCtl.InteractionsBlackboard:GetInt(interationCtl.InteractionsBBDefinition.ActiveChoiceHubID)
			if activeChoiceHubID ~= myNativeInteractionHubId then return end
			local dialogChoiceHubs = FromVariant(interationCtl.InteractionsBlackboard:GetVariant(interationCtl.InteractionsBBDefinition.DialogChoiceHubs))
			if not dialogChoiceHubs then return end
			if type(dialogChoiceHubs.choiceHubs) ~= 'table' then return end
			if myNativeInteractionHubIndex > #dialogChoiceHubs.choiceHubs then return end
			local myNativeHub = dialogChoiceHubs.choiceHubs[myNativeInteractionHubIndex]
			if not myNativeHub then return end
			if myNativeHub.id ~= activeChoiceHubID then return end
			local selectedIndex = interationCtl.InteractionsBlackboard:GetInt(interationCtl.InteractionsBBDefinition.SelectedIndex)

			if isMyNativeInteractionFirstEntryShown(true) then return end
			if not isMyNativeInteractionDestinationsShown(true) then return end

			self.createDestinations()

			local choiceDataIndex = selectedIndex + 1
			if choiceDataIndex > 0 and choiceDataIndex <= #customChoices then callback = customChoices[choiceDataIndex].callback else self.switchToTopEntry() return end

			if type(callback) == 'function' then
				local result, data = pcall(function() return callback() end)
				if result then
					myNativeInteractionCancelAll(true, true)
					this:StartCooldown(mod_modscenes_mq055_integration_interaction_choiceApply_cooldown, 0.5);
				else
					print(data);
					spdlog.error(data)
				end
			end
			return
        end
	end

	-- Warning: this appended custom choice navigation handler supports only game's native single choice interactions.
	-- Multiple choice interactions have to be handled differently.
	-- DO NOT try to modify it to handle game's native multiple choice interactions as this code is not suitable for that.

	function handleSingleOptionGameInteractionAction(this, action, consumer)
        if action:IsAction('ChoiceScrollUp') then
			if isLockInteractionsCooldownActive then consumer.Consume(consumer) return end
			local actionType = action:GetType(action).value
            if actionType ~= 'BUTTON_PRESSED'then return end
			local isSameKeyAction = os.clock() - lastKeyPress < 0.002
			lastKeyPress = os.clock()
			consumer.Consume(consumer)
			if isSameKeyAction then return end

			currentCombinedIteractionChoiceIndex = currentCombinedIteractionChoiceIndex - 1
			if currentCombinedIteractionChoiceIndex < 0 then currentCombinedIteractionChoiceIndex = combinedIteractionChoiceLastIndex end
			interationCtl:OnDialogsSelectIndex(currentCombinedIteractionChoiceIndex);
			return
		elseif action:IsAction('ChoiceScrollDown') then
			if isLockInteractionsCooldownActive then consumer.Consume(consumer) return end
			local actionType = action:GetType(action).value
			if actionType ~= 'BUTTON_PRESSED'then return end
			local isSameKeyAction = os.clock() - lastKeyPress < 0.002
			lastKeyPress = os.clock()
			consumer.Consume(consumer)
			if isSameKeyAction then return end

			currentCombinedIteractionChoiceIndex = currentCombinedIteractionChoiceIndex + 1
			if currentCombinedIteractionChoiceIndex > combinedIteractionChoiceLastIndex then currentCombinedIteractionChoiceIndex = 0 end
			interationCtl:OnDialogsSelectIndex(currentCombinedIteractionChoiceIndex);
			return
		elseif action:IsAction('ChoiceApply') then
			if isLockInteractionsCooldownActive then consumer.Consume(consumer) return end
			if this:IsCooldownActive(mod_modscenes_mq055_integration_interaction_choiceApply_cooldown) then consumer.Consume(consumer) return end
			local isSameKeyAction = os.clock() - lastKeyPress < 0.002
			lastKeyPress = os.clock()
			if isSameKeyAction then return end

			if currentCombinedIteractionChoiceIndex == originalIteractionChoiceFirstIndex then self.switchToTopEntry() return end
			consumer.Consume(consumer)
			local callback
			local choiceDataIndex = currentCombinedIteractionChoiceIndex - myIteractionChoiceFirstIndex + 1
			if choiceDataIndex > 0 and choiceDataIndex <= #customChoices then callback = customChoices[choiceDataIndex].callback else self.switchToTopEntry() return end
			consumer.Consume(consumer)
			if type(callback) == 'function' then
				local result, data = pcall(function() return callback() end)
				if result then
					this:StartCooldown(mod_modscenes_mq055_integration_interaction_choiceApply_cooldown, 0.5);
				else
					print(data);
					spdlog.error(data)
				end
			end
			return
        end
	end

	self.isActive = true
end

function isStringValid(input)
	if type(input) ~= 'string' then return end
	return string.len(input) > 0
end

function sendWarningMessage(message, showTime)
	if type(message) ~= 'string' then return end
	if not isStringValid(message) then return end
	if Game.GetPlayer():IsCooldownActive(n"mod_hotscenes_warningMessageCooldown") then return end
	if type(showTime) ~= 'number' then showTime = 5 end
	showTime = ClampF(showTime, 1, 10)
	GetPlayer():StartCooldown(n"mod_hotscenes_warningMessageCooldown", showTime, false)
	PreventionSystem.ShowMessage(message, showTime)
end

return self
