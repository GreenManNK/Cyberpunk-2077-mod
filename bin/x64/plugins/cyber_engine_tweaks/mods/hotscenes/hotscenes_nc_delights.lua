-- Jul 8, 2026 by anygoodname

local modVer='v1.32.1'
local modName='Hotscenes Night City Delights'
local modAuthorName='anygoodname'

--[[
	Credits: for game research, code snippets and support: (c)psiberx, (c)keanuWheeze
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
You may use parts of the code or any original algorithms developed for this mod in your own creations only with my prior consent and proper credit.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

local Ref = require("Ref")
if not Ref then return end
local RefWeak = Ref.Weak

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

if cetVer < 1.29 then
	print(modName, modVer..":", "is not compatible with this game version. This module is disabled now.")
	return
end
local isGame2 = cetVer >= 1.26
local isGame212 = cetVer >= 1.31

local interaction = require("hotscenes_adhoc_interactionUI")
if not interaction then print(modName, modVer..":", "file hotscenes_adhoc_interactionUI.lua is not found or is corrupted. This module is disabled now.") return end

local n, t
local isModuleDisabled = false
local thisMod = {isModDisabled = false, isControlledByMainMod = false, sceneState = {}}
thisMod.userSettings = {enableHotscenesAddon = true, enableNCDelightsFeature = true, enableNCDelightsDynamicMappins = true}
local lastPaymentExpected = 0
local lastPayWorkspot = {}
local workspotSystem, cameraSystem, questsSystem, mappinSystem, transactionSystem, statusEffectSystem, aINavigationSystem, spatialQueriesSystem, fastTravelSystem
local GameGetScriptableSystemsContainer
local GameGetTeleportationFacility
local GameGetNodeTransform
local GlobalNodeIDGetRoot
local GameFindEntityByID
local journalManager, targetingSystem, gameBlackboardSystem, allBlackboardDefs, allBlackboardDefsPlayerStateMachine
local lastInteractionOwner
local isActivityAllowed = true
local lastScannerNpcNameChanged = 0
local isNudityCensored = true
local isNotPrologue = false
local isEnding = false
local isEp1Installed = false
local myStaticMappins = {}
local myEntityDynamicMappins
local shouldShowCustomDynamicMappins = false
local substituteVariantAppearancesWithKnownParents = true
local currentActiveScene
local currentActiveSceneLocations
local selectedScenePerformer = {}
local disengageTargetDistanceSquared = 25
local engageTargetDistanceSquared = 9
local dynamicMappinRangeSquared = 1225
local lookedSecurityAreas = {};
local hotscenes_mod_pay_workspot_interaction_cooldown_cname
local hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname
local hotscenes_mod_freeze_selected_scene_cooldown_cname
local allowIdleNpcs = true
local AppearanceProxyMesh = 'AppearanceProxyMesh'
local l0_004_wa_tights__fishnet = "l0_004_wa_tights__fishnet"
local interactionRestrictionTags = {"NoPhone", "PhoneNoCalling", "PhoneNoTexting", "NoWorldInteractions", "NoMovement", "BlockFastTravel", "BlockAllHubMenu"}
local n_NoMovement = "NoMovement"
local n_PreventionSystem = "PreventionSystem"
local n_PlayerPuppet = "PlayerPuppet"
local n_FastTravelSystem = "FastTravelSystem"
local EPreventionHeatStageHeat_0
local isUsingWorkspotNodeRef
local canCombineWatsonAreas, canCombineWestbrookAreas, canCombineArroyoAreas
local Vector4ToRotation
local Vector4GetAngleDegAroundAxis
local isSameInstance

local isEntityDataIntegrityAffected = false

local lookedCharacterTypes = {}
lookedCharacterTypes["Character.DollFemale"]			= {idStr = "Character.DollFemale", gender = "Female", isFemale = true, baseEntPath = 17412789336333140685ULL, ep1EntPath = 17412789336333140685ULL}
lookedCharacterTypes["Character.DollMale"]				= {idStr = "Character.DollMale", gender = "Male", baseEntPath = 14255243121097138103ULL, ep1EntPath = 14255243121097138103ULL}
lookedCharacterTypes["Character.SexworkerFemale"]		= {idStr = "Character.SexworkerFemale", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.SexworkerFemaleDE"]		= {idStr = "Character.SexworkerFemaleDE", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.SexworkerFemaleDoll"]	= {idStr = "Character.SexworkerFemaleDoll", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.q105_jigjig_prostitute_f_scanning"] = {idStr = "Character.q105_jigjig_prostitute_f_scanning", gender = "Female", isFemale = true, baseEntPath = 4322428336937603418ULL, ep1EntPath = 4322428336937603418ULL, checkAvaliabilityName = "Hotscenes_overrides_mod_q105_jigjig_prostitute_f_scanning_supported"}
lookedCharacterTypes["Character.SexworkerMale"]			= {idStr = "Character.SexworkerMale", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.SexworkerMaleDE"]		= {idStr = "Character.SexworkerMaleDE", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.SexworkerMaleDoll"]		= {idStr = "Character.SexworkerMaleDoll", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.ProstituteFemale"]		= {idStr = "Character.ProstituteFemale", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.ProstituteFemaleDE"]	= {idStr = "Character.ProstituteFemaleDE", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.ProstituteMale"]		= {idStr = "Character.ProstituteMale", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.ProstituteMaleDE"]		= {idStr = "Character.ProstituteMaleDE", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.q105_jigjig_prostitute_m_scanning"] = {idStr = "Character.q105_jigjig_prostitute_m_scanning", gender = "Male", baseEntPath = 13621896409861006609ULL, ep1EntPath = 13621896409861006609ULL, checkAvaliabilityName = "Hotscenes_overrides_mod_q105_jigjig_prostitute_m_scanning_supported"}

lookedCharacterTypes["Character.sts_ep1_06_sexworker_crowd_wa"]	= {idStr = "Character.sts_ep1_06_sexworker_crowd_wa", gender = "Female", isFemale = true, baseEntPath = 3018883856103306275ULL, ep1EntPath = 3018883856103306275ULL, isCombatZone = true}
lookedCharacterTypes["Character.sts_ep1_06_sexworker_city_wa"]	= {idStr = "Character.SexworkerFemale", gender = "Female", isFemale = true, baseEntPath = 13051781759087773013ULL, ep1EntPath = 368045031105002719ULL}
lookedCharacterTypes["Character.ep1_combat_zone_service_sexworker_wa"]	= {idStr = "Character.ep1_combat_zone_service_sexworker_wa", gender = "Female", isFemale = true, baseEntPath = 3018883856103306275ULL, ep1EntPath = 3018883856103306275ULL, isCombatZone = true}
lookedCharacterTypes["Character.sts_ep1_06_sexworker_crowd_ma"]	= {idStr = "Character.sts_ep1_06_sexworker_crowd_ma", gender = "Male", baseEntPath = 3778249100674482345ULL, ep1EntPath = 3778249100674482345ULL, ltd = 3778249100674482345ULL, isCombatZone = true}
lookedCharacterTypes["Character.sts_ep1_06_sexworker_city_ma"]	= {idStr = "Character.SexworkerMale", gender = "Male", baseEntPath = 4530233927708058735ULL, ep1EntPath = 13520257471097300901ULL}
lookedCharacterTypes["Character.ep1_combat_zone_service_sexworker_ma"]	= {idStr = "Character.ep1_combat_zone_service_sexworker_ma", gender = "Male", baseEntPath = 3778249100674482345ULL, ep1EntPath = 3778249100674482345ULL, ltd = 3778249100674482345ULL, isCombatZone = true}

local lookedCharacterTypesByTemplatePath = {}
local lookedCharacterTypesByIdHash = {}
local supportedLocations = {}

local sq031_driver_cases = {
	{base = "prostitute_wa_06"},
	{base = "prostitute_wa_04"},
	{base = "prostitute_wa_07"},
	{base = "prostitute_wa_05"},
	{base = "prostitute_wa_09", replaceSuffix = "_no_coat"},
	{base = "prostitute_wa_03", replaceSuffix = "_no_coat"},
	{base = "prostitute_poor_08", replaceSuffix = "_no_coat"},
	{base = "prostitute_poor_04", replaceSuffix = "_no_coat"},
	{base = "doll_08"},
	{base = "doll_02"},
	{base = "doll_04"},
	{base = "doll_01"},
	{base = "doll_06"},
	{base = "doll_09"},
	{base = "doll_03"},
	{base = "doll_05"},
	{base = "_q105__prostitute_02", replaceSuffix = "_no_coat"},
	{base = "_q105__prostitute_06"},
	{base = "_q105__prostitute_09"},
	{base = "_q105__prostitute_10"},
	{base = "_q105__prostitute_09_no_coat"},
}

local useNoCoatSubstitute = {service__sexworker_wa_prostitute_poor_08 = true}

local stringLen = string.len
local stringMatch = string.match
local stringGsub = string.gsub
local stringLower = string.lower

local function isStringValid(input)
	if type(input) ~= 'string' then return end
	return stringLen(input) > 0
end
local mathAbs = math.abs
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

local tableInsert = table.insert
local tableRemove = table.remove
local osClock = os.clock
local mathRandom = math.random
local mathRandomseed = math.randomseed

local isSeeded
local function getRandomSceneIndex(maxIndex)
	if type(maxIndex) ~= "number" or maxIndex < 1 then maxIndex = 1 end
	if not isSeeded then mathRandomseed(osClock()) isSeeded = true end
	return mathRandom(0, maxIndex)
end

local setPerformerSceneSupport = function() end

local function IsDefinedNS(gameObj)
	if not gameObj then return false end
	local result, val = pcall(function() return IsDefinedNS(gameObj) end)
	if result then return val else return false end
end

local ncdApi = {}
ncdApi.apiVer = "v1.0.0"
ncdApi.featureName = modName
ncdApi.featureVer = modVer
ncdApi.featureAuthorName = modAuthorName
thisMod.ncdApi = ncdApi
local ncdApiFeatures = {}

local watsonCommonArea, westbrookCommonArea, arroyoWestCommonArea
local setUpFemaleInserts, isFastTravelPointAvaliable, createDefaultSceneLocationMappinData, resetSceneControls, getNodeTransformByNodeRef, setCinematicMode, setMappinToPosition, resetScenePlaybackStateFacts, isKnownName, isObjectInSimpleArea
local function dataSetup()
	if not TweakDB:GetRecord("Character.nc_delighs_hey_gle_prostitute_male_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delighs_hey_gle_prostitute_male_mod_hotscenes", "Character.hey_gle_prostitute_male") end;
	if not TweakDB:GetRecord("Character.nc_delighs_prostitute_female_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delighs_prostitute_female_mod_hotscenes", "Character.hey_gle_prostitute_female") end;
	if not TweakDB:GetRecord("Character.nc_delighs_prostitute_male_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delighs_prostitute_male_mod_hotscenes", "Character.hey_gle_prostitute_male") end;
	if not TweakDB:GetRecord("Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes", "Character.hey_gle_prostitute_female") end;
	if not TweakDB:GetRecord("Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes", "Character.hey_gle_prostitute_male") end;
	if not TweakDB:GetRecord("Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes", "Character.wbr_jpn_prostitute_female") end;
	if not TweakDB:GetRecord("Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes") then TweakDB:CloneRecord("Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes", "Character.wbr_jpn_prostitute_male") end;
----------------------------------------------
	local thisScene = {} thisScene.keyName = 'watson_common_area'
	thisScene.simpleAreas = {
		{x = {min = -2335.83, max = -960},	y = {min = 900, max = 1706.35}},
	}
	thisScene.triangularAreas = {
		{a = {x = -2335.83, y = 1706.35}, b = {x = -1136.9, y = 2424.837}, c = {x = -720, y = 1706.35}},
	}
	for i = 1, #thisScene.triangularAreas do
		thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
		local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
		for ii = 1, #vertices do
			thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
			thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
			thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
			thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	watsonCommonArea = thisScene
----------------------------------------------
	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'littleChina_01' thisScene.altFeatureName = "Gomorrah"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_lch_dataterm_05"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_little_china_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__little_china_01_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#21257").." – ".."Gomorrah".." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#21257").." – ".."Gomorrah"
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function() return true end
	thisScene.isUnlockedInNcdApi = function() return true end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "2986727937902347804ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		if isAnyAreaActive then return false end

		objectPos = objectPos or object:GetWorldPosition()
		local x = objectPos.x
		if x < -1667.6340 then return false end
		if x > -1485.056 then return false end
		local y = objectPos.y
		if y < 1100.4786 then return false end
		if y > 1293.2736 then return false end
		return true
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
		local zOffset = 3
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1570.8496, 1208.8907, 16.9942 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1587.6526, 1237.1379, 17.4580 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1544.5900, 1178.1958, 16.9886 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1557.6361, 1119.7746, 17.1793 + zOffset, 1)})
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delighs_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female" -- old record id
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_little_china_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_little_china_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_little_china_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\little_china_01\\environment\\decoration\\poor_room_little_china_01.ent');
		if not TweakDB:GetRecord("Props.nc_delights_poor_mattress_a_little_china_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_mattress_a_little_china_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_mattress_a_little_china_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\little_china_01\\environment\\decoration\\poor_mattress_a_little_china_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__little_china_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_little_china_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delighs_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male" -- old record id
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_little_china_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_little_china_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_little_china_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\little_china_01\\environment\\decoration\\poor_room_little_china_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_little_china_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'kabukiRoundabout_01' thisScene.altFeatureName = "Kabuki Roundabout"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_kab_dataterm_01"
	thisScene.fastTravelPointFactName = "mod_hotscenes_wat_kab_dataterm_01_enabled"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_kabuki_roundabout_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__kabuki_roundabout_01_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#21239").." – "..GetLocalizedText("LocKey#39926").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#21239").." – "..GetLocalizedText("LocKey#39926")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr(thisScene.fastTravelPointFactName) > 0 then return true end
		if not isFastTravelPointAvaliable(thisScene.fastTravelPoint) then return end
		questsSystem:SetFactStr(thisScene.fastTravelPointFactName, 1)
		return true
	end
	thisScene.isUnlockedInNcdApi = function() return true end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "8188172457222631479ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		if isAnyAreaActive then return false end

		objectPos = objectPos or object:GetWorldPosition()
		local x = objectPos.x
		if x < -1319.3 then return false end
		if x > -1090.9 then return false end
		local y = objectPos.y
		if y < 1936.3 then return false end
		if y > 2119.0 then return false end
		return true
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
		local zOffset = 3
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1271.4054, 2067.7951, 11.9669 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1240.4780, 2073.8681, 11.9957 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1233.9952, 2086.9306, 11.9983 + zOffset, 1)})
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delighs_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female" -- old record id
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_roundabout_01\\environment\\decoration\\poor_bedding_b_no_duvet_kabuki_roundabout_01.ent');
		if not TweakDB:GetRecord("Props.nc_delights_poor_mattress_b_kabuki_roundabout_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_mattress_b_kabuki_roundabout_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_mattress_b_kabuki_roundabout_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_roundabout_01\\environment\\decoration\\poor_mattress_b_kabuki_roundabout_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__kabuki_roundabout_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_kabuki_roundabout_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delighs_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male" -- old record id
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_bedding_kabuki_roundabout_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_roundabout_01\\environment\\decoration\\poor_bedding_b_no_duvet_kabuki_roundabout_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_kabuki_roundabout_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'kabukiNoTell_Motell_01' thisScene.altFeatureName = "No-Tell Motel"
	thisScene.isSupportedInNcdApi = true
	thisScene.isWatsonCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_kab_dataterm_04"
	thisScene.fastTravelPointFactName = "mod_hotscenes_wat_kab_dataterm_04"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_kabuki_ntm_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__kabuki_ntm_01_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#44387").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#44387")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr(thisScene.fastTravelPointFactName) > 0 then return true end
		if not isFastTravelPointAvaliable(thisScene.fastTravelPoint) then return end
		questsSystem:SetFactStr(thisScene.fastTravelPointFactName, 1)
		return true
	end
	thisScene.isUnlockedInNcdApi = function() return true end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "3048227170600227837ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isWatsonCommonArea and canCombineWatsonAreas then return watsonCommonArea.isObjectWithinArea(object, objectPos) end
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end

		objectPos = objectPos or object:GetWorldPosition()
		local x = objectPos.x
		if x < -1296.8 then return false end
		if x > -918.8 then return false end
		local y = objectPos.y
		if y < 1126.9 then return false end
		if y > 1346.9 then return false end
		return true
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
	thisScene.isJapantownFemaleScene = true
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.accessories_kabuki_ntm_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_kabuki_ntm_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.accessories_kabuki_ntm_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_ntm_01\\environment\\decoration\\accessories_kabuki_ntm_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__kabuki_ntm_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_kabuki_ntm_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
	thisScene.isJapantownMaleScene = true
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.accessories_kabuki_ntm_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_kabuki_ntm_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.accessories_kabuki_ntm_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_ntm_01\\environment\\decoration\\accessories_kabuki_ntm_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_kabuki_ntm_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'kabukiHotel_01' thisScene.altFeatureName = "Hotel Raito"
	thisScene.isSupportedInNcdApi = true
	thisScene.isWatsonCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_kab_dataterm_04"
	thisScene.fastTravelPointFactName = "mod_hotscenes_wat_kab_dataterm_04"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_kabuki_hotel_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__kabuki_hotel_01_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		local s = GetLocalizedText("LocKey#13775");
		if not isStringValid(s) then return end
		s = s.gsub(s, "：.*", ""); s = s.gsub(s, ",.*", ""); s = s.gsub(s, "%).*", ")");
		s = s.gsub(s, "-.*", ""); s = s.gsub(s, "–.*", ""); s = s.gsub(s, "—.*", "");
		s = s.gsub(s, "\194\160", " "); s = s.gsub(s, "^%s+", ""); s = s.gsub(s, "%s+$", "");
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return s.." ("..GetLocalizedText("LocKey#13699")..")" end
		return s
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr(thisScene.fastTravelPointFactName) > 0 then return true end
		if not isFastTravelPointAvaliable(thisScene.fastTravelPoint) then return end
		questsSystem:SetFactStr(thisScene.fastTravelPointFactName, 1)
		return true
	end
	thisScene.isUnlockedInNcdApi = function() return true end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isWatsonCommonArea and canCombineWatsonAreas then return watsonCommonArea.isObjectWithinArea(object, objectPos) end
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local x = objectPos.x
		if x < -1296.8 then return false end
		if x > -918.8 then return false end
		local y = objectPos.y
		if y < 1126.9 then return false end
		if y > 1845.1 then return false end
		return true
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delighs_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female" -- old record id
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_hotel_01\\environment\\decoration\\hotel_room_kabuki_hotel_01.ent');
		if not TweakDB:GetRecord("Props.nc_delights_poor_mattress_a_kabuki_hotel_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_mattress_a_kabuki_hotel_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_mattress_a_kabuki_hotel_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_hotel_01\\environment\\decoration\\rich_mattress_a_kabuki_hotel_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__kabuki_hotel_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_kabuki_hotel_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delighs_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male" -- old record id
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_kabuki_hotel_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\kabuki_hotel_01\\environment\\decoration\\hotel_room_kabuki_hotel_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_kabuki_hotel_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'wat_nid_dock_market_01' thisScene.altFeatureName = "Cargo Bay"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_nid_dataterm_02"
	thisScene.fastTravelPointFactName = "mod_hotscenes_wat_nid_dataterm_02"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_wat_nid_dock_market_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__wat_nid_dock_market_01_available'
	thisScene.priceTag = 50
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr(thisScene.fastTravelPointFactName) > 0 then return true end
		if not isFastTravelPointAvaliable(thisScene.fastTravelPoint) then return end
		questsSystem:SetFactStr(thisScene.fastTravelPointFactName, 1)
		return true
	end
	thisScene.isUnlockedInNcdApi = function() return true end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "15556975366449185961ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		if isAnyAreaActive then return false end

		objectPos = objectPos or object:GetWorldPosition()
		local x = objectPos.x
		if x < -1976.7 then return false end
		if x > -1809.6 then return false end
		local y = objectPos.y
		if y < 2668.5 then return false end
		if y > 2784.9 then return false end
		return true
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
		local zOffset = 3
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1883.5803, 2714.3623, 7.2045 + zOffset, 1)})
		tableInsert(thisScene.sceneLocationMappins, {pos = Vector4.new(-1914.1017, 2753.3379, 7.2045 + zOffset, 1)})
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delighs_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female" -- old record id
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wat_nid_dock_market_01\\environment\\decoration\\poor_bedding_b_no_duvet_wat_nid_dock_market_01.ent');
		if not TweakDB:GetRecord("Props.nc_delights_poor_mattress_b_wat_nid_dock_market_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_mattress_b_wat_nid_dock_market_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_mattress_b_wat_nid_dock_market_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wat_nid_dock_market_01\\environment\\decoration\\poor_mattress_b_wat_nid_dock_market_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wat_nid_dock_market_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delighs_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male" -- old record id
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_bedding_wat_nid_dock_market_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wat_nid_dock_market_01\\environment\\decoration\\poor_bedding_b_no_duvet_wat_nid_dock_market_01.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wat_nid_dock_market_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'jig_jig_02' thisScene.altFeatureName = "Bliss Bar"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_jj_02_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__wbr_jpn_jj_02_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		return GetLocalizedText("LocKey#79214").." "..GetLocalizedText("LocKey#49613").." – "..GetLocalizedText("LocKey#39744")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		return questsSystem:GetFactStr("q101_enable_side_content") > 0
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "9327938355541730482ULL"}, {id = "5467157865170794381ULL"}, {id = "11904713169839272195ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_jj_02\\environment\\decoration\\cabin_wbr_jpn_jj_01_new_02.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__wbr_jpn_jj_02_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wbr_jpn_jj_02", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delighs_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		if not TweakDB:GetRecord("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes") then TweakDB:CloneRecord("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
		TweakDB:SetFlat("Props.nc_delights_poor_room_wbr_jpn_jj_02_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_jj_02\\environment\\decoration\\cabin_wbr_jpn_jj_01_new_02.ent');
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wbr_jpn_jj_02", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'jig_jig_01' thisScene.altFeatureName = "Jig-Jig Street JoyToy Room"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#wbr_sm_jpn_prostitute_sex"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__jj_01_available'
	thisScene.priceTag = 100
	thisScene.getInteractionCaptionText = function()
		return GetLocalizedText("LocKey#79214").." – "..GetLocalizedText("LocKey#39250")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		return questsSystem:GetFactStr("q101_enable_side_content") > 0
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "11904713169839272195ULL"}, {id = "9327938355541730482ULL"}, {id = "5467157865170794381ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
	thisScene.isJapantownFemaleScene = true
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
		end
		resetSceneControls() resetScenePlaybackStateFacts()
		setUpFemaleInserts("mod_hotscenes_nc_delights_f__jj_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
		setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_jj_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
	thisScene.isJapantownMaleScene = true
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
		if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
			TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
		else
			if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
			else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
		end
		resetSceneControls() resetScenePlaybackStateFacts()
		setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_jj_01", 1);
		questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
	end
----------------------------------------------
	local thisScene = {} thisScene.keyName = 'westbrook_common_area'
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -793.0, max = -285.9},	y = {min = 1457.2, max = 1689.1}},
			{x = {min = -915.4, max = -200.0},	y = {min = 454.0, max = 1457.2}},
			{x = {min = -742.3, max = -235.0},	y = {min = 288.5, max = 454.0}},
		}
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -742.3, y = 288.5}, b = {x = -235.0, y = 288.5}, c = {x = -430.66, y = -86.65}},
			{a = {x = -596.81, y = 59.00}, b = {x = 368.01, y = -643.38}, c = {x = 502.85, y = -82.96}},
			{a = {x = -596.81, y = 59.00}, b = {x = -254.86, y = 575.28}, c = {x = 502.85, y = -82.96}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	westbrookCommonArea = thisScene
----------------------------------------------
	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'wbr_jpn_apt_01' thisScene.altFeatureName = "Japantown Apartment"
	thisScene.isSupportedInNcdApi = true
	thisScene.isWestbrookCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_wbr_jpn_apt_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__wbr_jpn_apt_01_available'
	thisScene.priceTag = 200
	thisScene.getInteractionCaptionText = function() return GetLocalizedText("LocKey#80749").." ("..GetLocalizedText("LocKey#13699")..")" end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.minCetVerRequired = 1.29
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr("dlc6_apart_wbr_jpn_purchased") < 1 then return false end
		return questsSystem:GetFactStr("mq055_02_japantown_active") < 1
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -793.0, max = -285.9},	y = {min = 1457.2, max = 1689.1}},
			{x = {min = -915.4, max = -200.0},	y = {min = 454.0, max = 1457.2}},
			{x = {min = -742.3, max = -235.0},	y = {min = 288.5, max = 454.0}},
		}
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -742.3, y = 288.5}, b = {x = -235.0, y = 288.5}, c = {x = -430.66, y = -86.65}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isWestbrookCommonArea and canCombineWestbrookAreas then return westbrookCommonArea.isObjectWithinArea(object, objectPos) end
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\mq005_table_01.ent');
			if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__wbr_jpn_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wbr_jpn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wbr_jpn_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__wbr_jpn_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wbr_jpn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wbr_jpn_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\mq005_table_00.ent');
			if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wbr_jpn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wbr_jpn_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_wbr_jpn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\wbr_jpn_apt_01\\entities\\bedroom_accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wbr_jpn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wbr_jpn_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'hey_gle_dm_02' thisScene.altFeatureName = "Dark Matter JoyToy Room"
	thisScene.isSupportedInNcdApi = true
	thisScene.isCoveringArroyoWestCommonArea = true
	thisScene.isWestbrookCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wbr_jpn_dataterm_11"
	thisScene.fastTravelPointFactName = "mod_hotscenes_wbr_jpn_dataterm_11_enabled"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_hey_gle_dm_02_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__hey_gle_dm_02_available'
	thisScene.priceTag = 300
	thisScene.getInteractionCaptionText = function() return GetLocalizedText("LocKey#44405").." ("..GetLocalizedText("LocKey#13699")..")" end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.minCetVerRequired = 1.29
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr("q101_enable_side_content") < 1 then return false end
		if questsSystem:GetFactStr("sq017_mq028_start") > 0 then return true end
		if questsSystem:GetFactStr("hey_gle_f_prostitue_met") > 0 then return true end
		if questsSystem:GetFactStr("hey_gle_pro_m_dreams") > 0 then return true end
		if not thisMod.userSettings.enableSceneAvaliabilityOverride then return end
		if questsSystem:GetFactStr(thisScene.fastTravelPointFactName) > 0 then return true end
		if isFastTravelPointAvaliable(thisScene.fastTravelPoint) then questsSystem:SetFactStr(thisScene.fastTravelPointFactName, 1) return true end
		return false
	end
	thisScene.isUnlockedInNcdApi = function()
		return questsSystem:GetFactStr("q101_enable_side_content") > 0
	end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -596.81, y = 59.00}, b = {x = 368.01, y = -643.38}, c = {x = 502.85, y = -82.96}},
			{a = {x = -596.81, y = 59.00}, b = {x = -254.86, y = 575.28}, c = {x = 502.85, y = -82.96}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isCoveringArroyoWestCommonArea and arroyoWestCommonArea.isObjectWithinArea(object, objectPos) then return true end
		if thisScene.isWestbrookCommonArea and canCombineWestbrookAreas then return westbrookCommonArea.isObjectWithinArea(object, objectPos) end
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		thisScene.femaleSceneSelected = 1
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		thisScene.femaleSceneSelected = 1
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__hey_gle_dm_02_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_dm_02", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_dm_02g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__hey_gle_dm_02_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_dm_02", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_dm_02g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		thisScene.maleSceneSelected = 1
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		thisScene.maleSceneSelected = 1
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_dm_02", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_dm_02g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_dm_02", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_dm_02g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'wat_lch_aph10' thisScene.altFeatureName = "V's Apartment"
	thisScene.isSupportedInNcdApi = true
	thisScene.isWatsonCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.fastTravelPoint = t"FastTravelPoints.wat_lch_dataterm_10"
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_apH10_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__wat_lch_aph10_available'
	thisScene.priceTag = 200
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#44392").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#44392")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		return questsSystem:GetFactStr("mq055_02_megabuilding_active") < 1
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -2020.9, max = -1221.6},	y = {min = 1731.3, max = 1874.0}},
			{x = {min = -2150.6, max = -1217.6},	y = {min = 1641.3, max = 1731.3}},
			{x = {min = -2209.09, max = -1236.8},	y = {min = 908.7, max = 1641.3}},
		}
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isWatsonCommonArea and canCombineWatsonAreas then return watsonCommonArea.isObjectWithinArea(object, objectPos) end
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__wat_lch_aph10_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wat_lch_aph10", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wat_lch_aph10g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__wat_lch_aph10_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wat_lch_aph10", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_wat_lch_aph10g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wat_lch_aph10", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wat_lch_aph10g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wat_lch_aph10", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_wat_lch_aph10g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'cct_dtn_apt_01' thisScene.altFeatureName = "Corpo Plaza Apartment"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_apt_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__cct_dtn_apt_01_available'
	thisScene.priceTag = 300
	thisScene.getInteractionCaptionText = function() return GetLocalizedText("LocKey#80746").." ("..GetLocalizedText("LocKey#13699")..")" end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.minCetVerRequired = 1.29
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr("dlc6_apart_cct_dtn_purchased") < 1 then return false end
		return questsSystem:GetFactStr("mq055_02_downtown_active") < 1
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -2535.2, max = -1196.3},	y = {min = -1405.5, max = 787.0}},
		}
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -1196.3, y = -1405.5}, b = {x = -396.9, y = -184.3}, c = {x = -1196.3, y = 787.0}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__cct_dtn_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__cct_dtn_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_apt_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_apt_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_apt_01\\entities\\accessories.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'cct_dtn_05' thisScene.altFeatureName = "Gold Beach Marina"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_cct_dtn_05_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__cct_dtn_05_available'
	thisScene.priceTag = 300
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#44473").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#44473")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		return questsSystem:GetFactStr("dtn_05_cleanup") > 0
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -2535.2, max = -1196.3},	y = {min = -1405.5, max = 787.0}},
		}
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -1196.3, y = -1405.5}, b = {x = -396.9, y = -184.3}, c = {x = -1196.3, y = 787.0}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
			if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__cct_dtn_05_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_05", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_05g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
			if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__cct_dtn_05_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_05", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_cct_dtn_05g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
			if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_05", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_05g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\static\\base\\gameplay\\devices\\doors\\double_door\\appearances\\custom_konpeki_glass_static.ent');
			if not TweakDB:GetRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_cct_dtn_05_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_cct_dtn_05_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\cct_dtn_05\\entities\\accessories_02.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_05", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_cct_dtn_05g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
----------------------------------------------
	local thisScene = {} thisScene.keyName = 'arroyo_west_common_area'
	thisScene.triangularAreas = {
		{a = {x = -444.287, y = -105.622}, b = {x = 119.568, y = -612.36}, c = {x = -895.765, y = -1942.154}},
		{a = {x = -444.287, y = -105.622}, b = {x = -1379.974, y = -1453.521}, c = {x = -895.765, y = -1942.154}},
	}
	for i = 1, #thisScene.triangularAreas do
		thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
		local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
		for ii = 1, #vertices do
			thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
			thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
			thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
			thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	arroyoWestCommonArea = thisScene
----------------------------------------------
	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'hey_gle_apt_01' thisScene.altFeatureName = "Glen Apartment"
	thisScene.isSupportedInNcdApi = true
	thisScene.isCoveringArroyoWestCommonArea = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_apart_hey_gle_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__hey_gle_apt_01_available'
	thisScene.priceTag = 200
	thisScene.getInteractionCaptionText = function() return GetLocalizedText("LocKey#80747").." ("..GetLocalizedText("LocKey#13699")..")" end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if questsSystem:GetFactStr("dlc6_apart_hey_gle_purchased") < 1 then return false end
		return questsSystem:GetFactStr("mq055_02_heywood_active") < 1
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = -2535.2, max = -1196.3},	y = {min = -1405.5, max = 787.0}},
		}
	end
	if not thisScene.triangularAreas then
		thisScene.triangularAreas = {
			{a = {x = -1196.3, y = -1405.5}, b = {x = -396.9, y = -184.3}, c = {x = -1196.3, y = 787.0}},
		}
		for i = 1, #thisScene.triangularAreas do
			thisScene.triangularAreas[i].bounds = {x = {min = 99999, max = -99999}, y = {min = 99999, max = -99999}}
			local vertices = {thisScene.triangularAreas[i].a, thisScene.triangularAreas[i].b, thisScene.triangularAreas[i].c}
			for ii = 1, #vertices do
				thisScene.triangularAreas[i].bounds.x.min = mathMin(thisScene.triangularAreas[i].bounds.x.min, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.x.max = mathMax(thisScene.triangularAreas[i].bounds.x.max, vertices[ii].x)
				thisScene.triangularAreas[i].bounds.y.min = mathMin(thisScene.triangularAreas[i].bounds.y.min, vertices[ii].y)
				thisScene.triangularAreas[i].bounds.y.max = mathMax(thisScene.triangularAreas[i].bounds.y.max, vertices[ii].y)
			end
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if thisScene.isCoveringArroyoWestCommonArea and arroyoWestCommonArea.isObjectWithinArea(object, objectPos) then return true end
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		local triangularAreas = thisScene.triangularAreas for i = 1, #triangularAreas do local triangularArea = triangularAreas[i] if isObjectInSimpleArea(objectPos, triangularArea.bounds) and isPointInTriangle(objectPos, triangularArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__hey_gle_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setUpFemaleInserts("mod_hotscenes_nc_delights_f__hey_gle_apt_01_insert_01_available", thisScene.checkNodeRef, isNcdApiCall, ncdApiSceneSpec)
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hey_gle_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_apt_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_apt_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hey_gle_apt_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'bls_ina_se1_roadhouse_01' thisScene.altFeatureName = "Sunset Motel"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_bls_ina_se1_roadhouse_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__bls_ina_se1_roadhouse_01_available'
	thisScene.priceTag = 50
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#44635").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#44635")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		return questsSystem:GetFactStr("q101_enable_side_content") > 0
	end
	thisScene.isUnlockedInNcdApi = thisScene.isUnlocked
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = nil
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	if not thisScene.simpleAreas then
		thisScene.simpleAreas = {
			{x = {min = 1548.76, max = 1751.83},	y = {min = -816.01, max = -646.94}},
			{x = {min = 2361.71, max = 2501.62},	y = {min = -840.89, max = -662.58}},
		}
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		objectPos = objectPos or object:GetWorldPosition()
		local simpleAreas = thisScene.simpleAreas for i = 1, #simpleAreas do local simpleArea = simpleAreas[i] if isObjectInSimpleArea(objectPos, simpleArea) then return true end end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_23.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_bls_ina_se1_roadhouse_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_bls_ina_se1_roadhouse_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_23.ent');
			if not TweakDB:GetRecord("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_01.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_bls_ina_se1_roadhouse_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_bls_ina_se1_roadhouse_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_23.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_bls_ina_se1_roadhouse_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_bls_ina_se1_roadhouse_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
				else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
			end
			if not TweakDB:GetRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_023_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_23.ent');
			if not TweakDB:GetRecord("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_bls_ina_se1_roadhouse_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\bls_ina_se1_roadhouse_01\\entities\\accessories_01.ent');
			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_bls_ina_se1_roadhouse_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_bls_ina_se1_roadhouse_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	local thisScene = {} tableInsert(supportedLocations, thisScene) thisScene.keyName = 'hh_01' thisScene.altFeatureName = "Heavy Hearts"
	thisScene.isSupportedInNcdApi = true
	thisScene.requiredArchiveFileNames = {'! hotscenes_add_on.archive'}
	thisScene.checkNodeRef = "#hey_gle_prostitute_sex_hh_01_mod_hotscenes"
	thisScene.checkLocationAvailabilityName = 'mod_hotscenes_nc_delights_f__hh_01_available'
	thisScene.priceTag = 300
	thisScene.getInteractionCaptionText = function()
		local scenePos = getNodeTransformByNodeRef(thisScene.checkNodeRef)
		if scenePos and vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) > 14400 then return GetLocalizedText("LocKey#86295").." ("..GetLocalizedText("LocKey#13699")..")" end
		return GetLocalizedText("LocKey#86295")
	end
	thisScene.isQuestActivated = function() if not isKnownName(thisScene.checkLocationAvailabilityName) then return false end return true end
	thisScene.isUnlocked = function()
		if not isEp1Installed then return false end
		if not isGame212 then return false end
		return questsSystem:GetFactStr("codex_q303_heavy_hearts") > 0
	end
	thisScene.isUnlockedInNcdApi = function()
		if not isEp1Installed then return false end
		if not isGame212 then return false end
		return questsSystem:GetFactStr("q302_done") > 0
	end
	thisScene.isSceneWorldDataAvailable = function()
		if thisScene.isSceneNodeRefAvailable then return true end
		if not getNodeTransformByNodeRef(thisScene.checkNodeRef, true) then return false end
		thisScene.isSceneNodeRefAvailable = true
		return true
	end
	thisScene.securityAreas = {{id = "11552590477053451138ULL"}, {id = "13292390905176887251ULL"}}
	thisScene.registerSecurityAreas = function()
		if type(thisScene.securityAreas) ~= 'table' then return end
		for i = 1, #thisScene.securityAreas do
			local id = thisScene.securityAreas[i].id
			if not lookedSecurityAreas[id] then lookedSecurityAreas[id] = {} end
			thisScene.securityAreas[i].data = lookedSecurityAreas[id]
		end
	end
	thisScene.isObjectWithinArea = function(object, objectPos)
		if not object then return false end
		local isAnyAreaActive = false
		if thisScene.securityAreas then
			for i = 1, #thisScene.securityAreas do
				local handle = thisScene.securityAreas[i].data.handle
				if handle then
					if IsDefinedNS(handle) then
						isAnyAreaActive = true
						if handle.area:IsEntityOverlapping(object) then return true end
					else
						thisScene.securityAreas[i].data.handle = nil
					end
				end
			end
		end
		return false
	end
	thisScene.isActive = function(player, playerPos)
		if not thisScene.isUnlocked() then return false end
		if not player then player = GetPlayer() end
		if not player then return false end
		if not playerPos then playerPos = player:GetWorldPosition() end
		if not thisScene.isObjectWithinArea(player, playerPos) then return false end
		if not thisScene.isQuestActivated() then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if player:IsA(n_PlayerPuppet) and player:GetSceneTier() == 2 then setCinematicMode(false, _, _, player) end
		return true
	end
	thisScene.createSceneLocationMappinData = function()
		if thisScene.sceneLocationMappinData then return end
		thisScene.sceneLocationMappinData = createDefaultSceneLocationMappinData()
	end
	thisScene.noSceneLocationMappins = true
	thisScene.shouldShowSceneLocationMappin = function()
		if thisScene.noSceneLocationMappins then return false end
		if not thisScene.isUnlocked() then return false end
		if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
		if not thisScene.isSceneWorldDataAvailable() then return false end
		if not thisScene.isQuestActivated() then return false end
		return true
	end
	thisScene.createSceneLocationMappins = function()
		if thisScene.noSceneLocationMappins then return end
		if type(thisScene.sceneLocationMappins) == 'table' then return end
		thisScene.sceneLocationMappins = {}
	end
	thisScene.toggleSceneLocationMappins = function(showMappin, forceRemoval)
		if thisScene.noSceneLocationMappins then return end
		thisScene.createSceneLocationMappins()
		for i = 1, #thisScene.sceneLocationMappins do
			local mappinId = thisScene.sceneLocationMappins[i].id
			if showMappin then
				if not mappinId then
					thisScene.createSceneLocationMappinData()
					local mappinPos = thisScene.sceneLocationMappins[i].pos
					thisScene.sceneLocationMappins[i].id = setMappinToPosition(thisScene.sceneLocationMappinData, mappinPos)
				end
			else
				if mappinId then
					mappinSystem:UnregisterMappin(mappinId)
					thisScene.sceneLocationMappins[i].id = nil
				end
			end
		end
	end
	thisScene.updateSceneLocationMappins = function(forceRemoval) thisScene.toggleSceneLocationMappins(thisScene.shouldShowSceneLocationMappin(), forceRemoval) end
	thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes"
	thisScene.femaleSceneSelected = getRandomSceneIndex() -1
	thisScene.getFemalePerformerIdStr = function()
		thisScene.femaleSceneSelected = thisScene.femaleSceneSelected + 1 if thisScene.femaleSceneSelected > 1 then thisScene.femaleSceneSelected = 0 end
		if not getNodeTransformByNodeRef("#wbr_sm_jpn_prostitute_sex_intro_hh_01_mod_hotscenes", true) then thisScene.femaleSceneSelected = 1 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = true
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.isJapantownFemaleScene = false
		end
		return thisScene.femalePerformerIdStr, thisScene.isJapantownFemaleScene
	end
	thisScene.startFemaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.femaleSceneSelected or thisScene.femaleSceneSelected < 0 then thisScene.femaleSceneSelected = 0 end
		if not getNodeTransformByNodeRef("#wbr_sm_jpn_prostitute_sex_intro_hh_01_mod_hotscenes", true) then thisScene.femaleSceneSelected = 1 end
		if thisScene.femaleSceneSelected == 0 then
			thisScene.femalePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_female"
			thisScene.isJapantownFemaleScene = true
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isCombatZone then
					if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_wa_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_wa_uncensored.ent'); end;
				else
					if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
				end
			end
			if not TweakDB:GetRecord("Props.accessories_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories_b.ent');
			if not TweakDB:GetRecord("Props.accessories_01_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories01.ent');
			if not TweakDB:GetRecord("Props.accessories_02_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories02.ent');
			if not TweakDB:GetRecord("Props.accessories_03_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_03_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_03_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories03.ent');
			if not TweakDB:GetRecord("Props.accessories_04_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_04_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_04_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories04.ent');

			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("female", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hh_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hh_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.femalePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_female_mod_hotscenes" thisScene.sourceFemaleCharacterRecordIdStr = "Character.hey_gle_prostitute_female"
			thisScene.isJapantownFemaleScene = false
			if not TweakDB:GetRecord(thisScene.femalePerformerIdStr) then TweakDB:CloneRecord(thisScene.femalePerformerIdStr, thisScene.sourceFemaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isCombatZone then
					if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_wa_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_wa_uncensored.ent'); end;
				else
					if isVariant then TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.femalePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_wa_uncensored.ent'); end;
				end
			end
			if not TweakDB:GetRecord("Props.accessories_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories01.ent');
			if not TweakDB:GetRecord("Props.accessories_02_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories02.ent');
			if not TweakDB:GetRecord("Props.accessories_03_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_03_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_03_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories03.ent');
			if not TweakDB:GetRecord("Props.accessories_04_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_04_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_04_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories04.ent');

			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("female", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hh_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_f__to_hh_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end
	thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes"
	thisScene.maleSceneSelected = getRandomSceneIndex() -1
	thisScene.getMalePerformerIdStr = function()
		thisScene.maleSceneSelected = thisScene.maleSceneSelected + 1 if thisScene.maleSceneSelected > 1 then thisScene.maleSceneSelected = 0 end
		if not getNodeTransformByNodeRef("#wbr_sm_jpn_prostitute_sex_intro_hh_01_mod_hotscenes", true) then thisScene.maleSceneSelected = 1 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = true
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.isJapantownMaleScene = false
		end
		return thisScene.malePerformerIdStr, thisScene.isJapantownMaleScene
	end
	thisScene.startMaleScene = function(isVariant, isCombatZone, isNcdApiCall, ncdApiSceneSpec)
		if not thisScene.maleSceneSelected or thisScene.maleSceneSelected < 0 then thisScene.maleSceneSelected = 0 end
		if not getNodeTransformByNodeRef("#wbr_sm_jpn_prostitute_sex_intro_hh_01_mod_hotscenes", true) then thisScene.maleSceneSelected = 1 end
		if thisScene.maleSceneSelected == 0 then
			thisScene.malePerformerIdStr = "Character.nc_delights_wbr_jpn_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.wbr_jpn_prostitute_male"
			thisScene.isJapantownMaleScene = true
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isCombatZone then
					if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_ma_variant_uncensored_ltd.ent');
					else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_ma_uncensored_ltd.ent'); end;
				else
					if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
				end
			end
			if not TweakDB:GetRecord("Props.accessories_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories_b.ent');
			if not TweakDB:GetRecord("Props.accessories_01_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories01.ent');
			if not TweakDB:GetRecord("Props.accessories_02_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories02.ent');
			if not TweakDB:GetRecord("Props.accessories_03_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_03_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_03_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories03.ent');
			if not TweakDB:GetRecord("Props.accessories_04_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_04_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_04_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories04.ent');

			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Japantown", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hh_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hh_01g", 0);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		else
			thisScene.malePerformerIdStr = "Character.nc_delights_hey_gle_prostitute_male_mod_hotscenes" thisScene.sourceMaleCharacterRecordIdStr = "Character.hey_gle_prostitute_male"
			thisScene.isJapantownMaleScene = false
			if not TweakDB:GetRecord(thisScene.malePerformerIdStr) then TweakDB:CloneRecord(thisScene.malePerformerIdStr, thisScene.sourceMaleCharacterRecordIdStr) end;
			if isNcdApiCall and ncdApiSceneSpec and ncdApiSceneSpec.performerEntPath then
				TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", ncdApiSceneSpec.performerEntPath);
			else
				if isCombatZone then
					if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_ma_variant_uncensored_ltd.ent');
					else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\ep1\\common_characters\\entities\\service\\service__ep1_combat_zone_sexworker_ma_uncensored_ltd.ent'); end;
				else
					if isVariant then TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_variant_uncensored.ent');
					else TweakDB:SetFlat(thisScene.malePerformerIdStr..".entityTemplatePath", 'base\\hotscenes_overrides\\base\\common_characters\\entities\\service\\service__sexworker_ma_uncensored.ent'); end;
				end
			end
			if not TweakDB:GetRecord("Props.accessories_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories.ent');
			if not TweakDB:GetRecord("Props.accessories_01_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_01_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_01_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories01.ent');
			if not TweakDB:GetRecord("Props.accessories_02_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_02_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_02_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories02.ent');
			if not TweakDB:GetRecord("Props.accessories_03_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_03_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_03_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories03.ent');
			if not TweakDB:GetRecord("Props.accessories_04_hh_01_mod_hotscenes") then TweakDB:CloneRecord("Props.accessories_04_hh_01_mod_hotscenes", "Props.mq019_champagne_glass_prop") end;
			TweakDB:SetFlat("Props.accessories_04_hh_01_mod_hotscenes.entityTemplatePath", 'base\\hotscenes_overrides\\nc_delights\\hh_01\\accessories04.ent');

			resetSceneControls() resetScenePlaybackStateFacts()
			setPerformerSceneSupport("male", "Glen", isNcdApiCall, ncdApiSceneSpec)
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__ftplay_start", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__requesting_custom_locations", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hh_01", 1);
			questsSystem:SetFactStr("mod_hotscenes_nc_delights_m__to_hh_01g", 1);
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 1);
		end
	end

	for i = 1, #supportedLocations do
		supportedLocation = supportedLocations[i]
		if supportedLocation.isSupportedInNcdApi and isStringValid(supportedLocation.keyName) and type(supportedLocation.isUnlockedInNcdApi) == 'function' then
			ncdApiFeatures[stringLower(supportedLocation.keyName)] = supportedLocation
			if isStringValid(supportedLocation.altFeatureName) then ncdApiFeatures[stringLower(supportedLocation.altFeatureName)] = supportedLocation end
		end
	end
end

local function isAnyHotscenePlaying()
	return thisMod.sceneState.isPlayerInScene or thisMod.sceneState.isNCDelightsScenePlaying
end

local function isGropingAllowed(appearanceName)
	if type(appearanceName) ~= 'string' then return end
	for _, appearanceCase in ipairs(sq031_driver_cases) do
		if stringMatch(appearanceName, appearanceCase.base) then
			if not appearanceCase.replaceSuffix then return end
			return true, appearanceCase.replaceSuffix
		end
	end
	return true
end

local femInserts01 = {"mod_hotscenes_fem_insert_01_01", "mod_hotscenes_fem_insert_01_02", "mod_hotscenes_fem_insert_01_03", "mod_hotscenes_fem_insert_01_04", "mod_hotscenes_fem_insert_01_05"}
local femInserts01Exceptions = {
	mod_hotscenes_fem_insert_01_03 = {any = true, facts = {q004_done = 1, q004_judy_met = 1, q004_evelyn_ended_walk = 1, ep1_standalone = 1}}
}
local EntityGameInterfaceGetEntity
local function runtimePatch03(this, evt)
	if this:GetEntityID().hash ~= 13219497725107200488ULL then return end
	local entity = EntityGameInterfaceGetEntity(evt.activator)
	if not entity:IsNPC() then return end
	local pos = entity:GetWorldPosition()
	if mathAbs(-1173.399 - pos.x) > 0.05 then return end
	if mathAbs(1572.067 - pos.y) > 0.05 then return end
	if mathAbs(23.115 - pos.z) > 0.1 then return end
	entity:Dispose()
	return true
end
local getPlaybackHistory, updatePlaybackHistory
local maxPlaybackHistory = 5
setUpFemaleInserts = function(sceneAvailabilityIdentifier, sceneRefPos, isNcdApiCall, ncdApiSceneSpec)
	selectedScenePerformer.lastSelectedInsertName = nil
	selectedScenePerformer.runtimePatch03 = nil
	local isNcdApiOverride
	if isNcdApiCall and ncdApiSceneSpec then
		if not ncdApiSceneSpec.allowLeadIns then return end
		isNcdApiOverride = true
	end
	if not isNcdApiOverride then
		if not thisMod.userSettings.enableNcSceneExtensions then return end
		if type(sceneRefPos) ~= "string" then return end
		if type(sceneAvailabilityIdentifier) ~= "string" then return end
		if not isKnownName(sceneAvailabilityIdentifier) then return end
		local scenePos = getNodeTransformByNodeRef(sceneRefPos)
		if not scenePos then return end
		if vectorDistanceSquared2D(GetPlayer():GetWorldPosition(), scenePos) < 22500 then return end
	end

	questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_on", 1)
	if isNcdApiOverride then
		if ncdApiSceneSpec.allowLeadInsGroping then questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_groping", 1) end
	else
		local canGrop, appsuffix = isGropingAllowed(selectedScenePerformer.performerAppearanceNameStr)
		if canGrop then
			if appsuffix then
				-- placeholder
			else
				questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_groping", 1)
			end
		end
	end
	local insertsAvailable = {}
	for i, name in ipairs(femInserts01) do
		if isKnownName(name) then
			local isAllowed = true
			local exceptions = femInserts01Exceptions[name]
			if exceptions then
				if type(exceptions.isAllowed) == 'function' then
					isAllowed = exceptions.isAllowed()
				else
					if exceptions.any then isAllowed = false end
					for factName, factValue in pairs(exceptions.facts) do
						local isTrue = questsSystem:GetFactStr(factName) == factValue
						if exceptions.any then
							if isTrue then isAllowed = true break end
						else
							if not isTrue then isAllowed = false break end
						end
					end
				end
			end
			if isAllowed then tableInsert(insertsAvailable, {name = name, count = 0, id = i}) end
		end
	end
	local maxInserts = #insertsAvailable
	if maxInserts > 1 then
		local playbackHistory = getPlaybackHistory("mod_hotscenes_fem_insert_01")
		local lastPlayed = playbackHistory[1] or -1
		local lastPlayedTwice = lastPlayed >= 0 and playbackHistory[2] and playbackHistory[2] == lastPlayed
		mathRandomseed(osClock()*10)
		local selector = 1
		local maxCaseCount = 10
		if maxInserts < 3 then
			local lastPlayedTwice = lastPlayed >= 0 and playbackHistory[2] and playbackHistory[2] == lastPlayed
			selector = mathRandom(1, maxInserts)
			if insertsAvailable[selector].id == lastPlayed and lastPlayedTwice then
				selector = selector + 1 if selector > maxInserts then selector = 1 end
			end
		else
			maxPlaybackHistory = maxInserts * 2 - 1
			for i = 1, maxInserts do
				for ii = 1, mathMin(#playbackHistory, 5) do
					if insertsAvailable[i].id == playbackHistory[ii] then insertsAvailable[i].count = insertsAvailable[i].count + 1 end
				end
			end
			local maxCountInSequence = 1
			local noSecondaryRepeats = maxInserts > 3 and playbackHistory[2] and playbackHistory[2] > -1
			local isSelected = false
			local loopBreaker = mathMin(maxInserts * maxCaseCount, 100)
			while not isSelected do
				loopBreaker = loopBreaker - 1
				if loopBreaker < 0 then isSelected = true break end
				selector = mathRandom(1, maxInserts)
				isSelected = true
				local insertSelected = insertsAvailable[selector]
				if insertSelected.id == lastPlayed then isSelected = false end
				if insertSelected.count > 1 then isSelected = false end
				if noSecondaryRepeats and playbackHistory[2] == insertSelected.id then isSelected = false end
			end
		end
		local insertSelected = insertsAvailable[selector].id
		selectedScenePerformer.lastSelectedInsertName = insertsAvailable[selector].name
		if selectedScenePerformer.lastSelectedInsertName == "mod_hotscenes_fem_insert_01_03" then selectedScenePerformer.runtimePatch03 = runtimePatch03 end
		questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_on", insertSelected)
		updatePlaybackHistory("mod_hotscenes_fem_insert_01", playbackHistory, insertSelected)
	end
	return true
end

getPlaybackHistory = function(baseName)
	local newPlaybackHistoryBuffer = {}
	for i = 1, maxPlaybackHistory do
		local newValue = TweakDB:GetFlat(baseName.."_playback_history_"..tostring(i))
		if type(newValue) == 'number' and newValue >= 0 then tableInsert(newPlaybackHistoryBuffer, newValue) else break end
	end
	return newPlaybackHistoryBuffer
end
updatePlaybackHistory = function(baseName, playbackHistoryBuffer, newValue)
	if type(newValue) == 'number' and newValue > 0 then
		if type(playbackHistoryBuffer) == 'table' and #playbackHistoryBuffer > 0 then
			local maxCount = #playbackHistoryBuffer
			local newPlaybackHistoryBuffer = {}
			for i = maxCount, 1, -1 do tableInsert(newPlaybackHistoryBuffer, playbackHistoryBuffer[i]) end
			tableInsert(newPlaybackHistoryBuffer, newValue)
			maxCount = #newPlaybackHistoryBuffer
			playbackHistoryBuffer = {}
			local cnt = 0
			for i = maxCount, 1, -1 do
				if cnt >= maxPlaybackHistory then break end
				cnt = cnt + 1
				tableInsert(playbackHistoryBuffer, newPlaybackHistoryBuffer[i])
			end
		else
			playbackHistoryBuffer = {newValue}
		end
		for i = 1, maxPlaybackHistory do
			TweakDB:SetFlat(baseName.."_playback_history_"..tostring(i), playbackHistoryBuffer[i] or -1, "Int32")
		end
		return playbackHistoryBuffer
	elseif type(playbackHistoryBuffer) == 'table' and #playbackHistoryBuffer > 0 then
		for i = 1, maxPlaybackHistory do
			TweakDB:SetFlat(baseName.."_playback_history_"..tostring(i), playbackHistoryBuffer[i] or -1, "Int32")
		end
		return playbackHistoryBuffer
	end
end

isFastTravelPointAvaliable = function(id)
	if not id then return end
	if not IsDefinedNS(fastTravelSystem) then fastTravelSystem = RefWeak(Game.GetScriptableSystemsContainer():Get(n_FastTravelSystem)) end
	local points = fastTravelSystem.fastTravelNodes;
	if not points then return end
	for i, point in pairs(points) do;
		if point.pointRecord == id then return true end;
	end;
end

local hasNoRecoveryWarningBeenPrinted
local function verifyGameNpcRecords(fixCorruptedData, verbose)
	local dataAffectedCount, dataFixedCount = 0, 0
	for name, data in pairs(lookedCharacterTypes) do
		if not data.entPathStr then lookedCharacterTypes[name].entPathStr = data.idStr..".entityTemplatePath" end
		if not data.entPathId then lookedCharacterTypes[name].entPathId = TweakDBID.new(data.entPathStr) end
		local lookedPathHash
		local entPath = TweakDB:GetFlat(data.entPathId)
		if entPath then
			if isEp1Installed then lookedPathHash = data.ep1EntPath else lookedPathHash = data.baseEntPath end
			if entPath.hash ~= lookedPathHash then
				dataAffectedCount = dataAffectedCount + 1
				isEntityDataIntegrityAffected = true
				if fixCorruptedData then
					if not data.entPathResRef then lookedCharacterTypes[name].entPathResRef = ResRef.FromHash(lookedPathHash) end
					TweakDB:SetFlat(data.entPathId, data.entPathResRef)
					dataFixedCount = dataFixedCount + 1
				end
			end
		end
	end
	if verbose and dataAffectedCount > 0 then
		if dataAffectedCount == dataFixedCount then
			print(modName..": Some NPCs\' fundamental data was found to be affected, possibly by other mods. This has been amended.")
			hasNoRecoveryWarningBeenPrinted = false
		elseif not hasNoRecoveryWarningBeenPrinted then
			print(modName..":\n\tSome NPCs\' fundamental data was found to be affected, possibly by other mods.\n\tThese charactes cannot be used with this feature in their current state.\n\tHowever, you may try enabling the option to restore NPC defaults in the mod\'s settings to fix it.")
			hasNoRecoveryWarningBeenPrinted = true
		end
	end
end

local function scheduleGameNpcRecordsVerification(fixCorruptedData)
	local payload = function() verifyGameNpcRecords(fixCorruptedData, true) end
	thisMod.queueTask(payload, false, 0.001)
	if not fixCorruptedData then return end
	local payload = function() verifyGameNpcRecords(true) end
	thisMod.queueTask(payload, false, 0.010)
end
thisMod.scheduleGameNpcRecordsVerification = scheduleGameNpcRecordsVerification

local setObservers, shouldAllowActivity, isArchiveXLActive
local isInitialized = false
thisMod.onInit = function()
	if isInitialized then thisMod.isInitialized = true return end
	thisMod.isInitialized = false
	if type(thisMod.queueTask) ~= 'function' then
		print(modName, modVer..":", "could not find required API resources. This module is disabled now.")
		thisMod.isInitialized = false
		return
	end
	isArchiveXLActive = ArchiveXL ~= nil
	n = CName
	t = TweakDBID

	isSameInstance = Game['OperatorEqual;IScriptableIScriptable;Bool']

	isNudityCensored = isCensored()

	Vector4ToRotation = Vector4.ToRotation
	Vector4GetAngleDegAroundAxis = Vector4.GetAngleDegAroundAxis

	workspotSystem = RefWeak(Game.GetWorkspotSystem())
	cameraSystem = RefWeak(Game.GetCameraSystem())
	questsSystem = RefWeak(Game.GetQuestsSystem())
	mappinSystem = RefWeak(Game.GetMappinSystem())
	fastTravelSystem = RefWeak(Game.GetScriptableSystemsContainer():Get("FastTravelSystem"))
	EntityGameInterfaceGetEntity = EntityGameInterface.GetEntity
	GameGetScriptableSystemsContainer = Game.GetScriptableSystemsContainer
	GameGetTeleportationFacility = Game.GetTeleportationFacility
	transactionSystem = Game.GetTransactionSystem
	GameGetNodeTransform = Game.GetNodeTransform
	GlobalNodeIDGetRoot = GlobalNodeID.GetRoot
	statusEffectSystem = RefWeak(Game.GetStatusEffectSystem())
	aINavigationSystem = RefWeak(Game.GetAINavigationSystem())
	spatialQueriesSystem = RefWeak(Game.GetSpatialQueriesSystem())
	GameFindEntityByID = Game.FindEntityByID
	journalManager = RefWeak(Game.GetJournalManager())
	targetingSystem = RefWeak(Game.GetTargetingSystem())
	gameBlackBoardSystem = RefWeak(Game.GetBlackboardSystem())
	allBlackboardDefs = RefWeak(Game.GetAllBlackboardDefs())
	allBlackboardDefsPlayerStateMachine = allBlackboardDefs.PlayerStateMachine

	if not ModArchiveExists("! hotscenes_add_on.archive") then
		print(modName, modVer..":", "could not find mandatory add-on archive file. This module is disabled now.")
		thisMod.isInitialized = false
		return
	end

	if isGameV2 then IsDefinedNS = IsDefined end

	dataSetup()
	local cnt = 0
	for s = #supportedLocations, 1, -1 do
		local sceneLocationData = supportedLocations[s]
		local shouldAllowThislocation = true
		for i = 1, #sceneLocationData.requiredArchiveFileNames do
			if not ModArchiveExists(sceneLocationData.requiredArchiveFileNames[i]) then shouldAllowThislocation = false break end
			if type(sceneLocationData.minCetVerRequired) == 'number' and sceneLocationData.minCetVerRequired > cetVer then shouldAllowThislocation = false break end
		end
		if shouldAllowThislocation then
			cnt = cnt + 1
			if type(sceneLocationData.registerSecurityAreas) == 'function' then sceneLocationData.registerSecurityAreas() end
		else
			print(sceneLocationData.keyName, 'cannot be used due to missing archive file or CET version requirement')
			tableRemove(supportedLocations, s)
		end
	end
	if cnt < 1 then
		print(modName, modVer..":", "could not find mandatory scene archive files. This module is disabled now.")
		isModuleDisabled = true
		return
	end

	lastInteractionOwner = nil

	local payload = function()
		for i, v in pairs(lookedCharacterTypes) do
			if v.checkAvaliabilityName and (not isKnownName(v.checkAvaliabilityName)) then
				lookedCharacterTypes[i] = nil
			else
				if v.baseEntPath then
					local path = tostring(v.baseEntPath)
					if lookedCharacterTypesByTemplatePath[path] then tableInsert(lookedCharacterTypesByTemplatePath[path], v) else lookedCharacterTypesByTemplatePath[path] = {v} end
				end
				if v.ep1EntPath then
					local path = tostring(v.ep1EntPath)
					if lookedCharacterTypesByTemplatePath[path] then tableInsert(lookedCharacterTypesByTemplatePath[path], v) else lookedCharacterTypesByTemplatePath[path] = {v} end
				end
			end
		end

		for character, _ in pairs(lookedCharacterTypes) do
			local id = TweakDBID.new(character)
			lookedCharacterTypes[character].id = id
			lookedCharacterTypesByIdHash[tostring(id.hash)] = lookedCharacterTypes[character]
		end
	end
	if isKnownName("Hotscenes_overrides_mod_nc_delights_supported") then
		payload()
	else
		local a = inkImage.new()
		a:SetAtlasResource(ResRef.FromName('base\\hotscenes_overrides\\version_info.inkatlas'))
		thisMod.queueTask(payload, false, 0.001)
	end

	if not isEp1Installed then isEp1Installed = journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry') and TweakDB:GetRecord("Character.bella") end

	scheduleGameNpcRecordsVerification(thisMod.userSettings and thisMod.userSettings.restoreNpcDefaults)

	hotscenes_mod_pay_workspot_interaction_cooldown_cname = n"hotscenes_mod_pay_workspot_interaction_cooldown"
	hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname = n"hotscenes_mod_nc_delights_scene_playback_start_cooldown"
	hotscenes_mod_freeze_selected_scene_cooldown_cname = n"hotscenes_mod_freeze_selected_scene_cooldown"
	AppearanceProxyMesh = n"AppearanceProxyMesh"
	l0_004_wa_tights__fishnet = n"l0_004_wa_tights__fishnet"
	n_NoMovement = n"NoMovement"
	n_PreventionSystem = n"PreventionSystem"
	EPreventionHeatStageHeat_0 = EPreventionHeatStage.Heat_0
	n_PlayerPuppet = n"PlayerPuppet"
	n_FastTravelSystem = n"FastTravelSystem"

	setObservers()
	isInitialized = true
	thisMod.isInitialized = true
	print(modName, modVer, "initialized.")
end

local isNcdApiPlayback
local manageInteractions, isInteractionAllowedByGameState, createAdHocInteraction, isActiveInWorkspotOrIdle, isPlayerInHotscene
thisMod.onUpdate = function (delta)
	if isModuleDisabled then return end
	if not isInitialized then return end

	interaction.update()
	manageInteractions()

	if (not isActivityAllowed) and (not isNcdApiPlayback) then return end
	if not thisMod.sceneState.isNCDelightsScenePlaying then return end
	if type(thisMod.sceneState.lastNCDelightsSceneStartTime) ~= 'number' then thisMod.sceneState.isNCDelightsScenePlaying = false return end
	if osClock() <= thisMod.sceneState.lastNCDelightsSceneStartTime then return end
	local player = GetPlayer()
	if not player then return end
	if not isPlayerInHotscene(player) then
		thisMod.sceneState.isNCDelightsScenePlaying = false
		if isKnownName("mod_hotscenes_nc_delights_f__little_china_01_insert_01_available") and (not isKnownName("mod_hotscenes_nc_delights_autodispose")) then
			if IsDefinedNS(selectedScenePerformer.performer) then
				selectedScenePerformer.performer:Dispose()
			else
				local performer = GameFindEntityByID(thisMod.sceneState.performerEntID)
				if performer and performer:IsNPC() then performer:Dispose() end
			end
		end
		local ncdApiPlaybackCallback
		if isNcdApiPlayback and selectedScenePerformer.isNcdApiCall and selectedScenePerformer.ncdApiSceneSpec and type(selectedScenePerformer.ncdApiSceneSpec.onSceneCompleted) == 'function' then
			ncdApiPlaybackCallback = selectedScenePerformer.ncdApiSceneSpec.onSceneCompleted
		end
		isNcdApiPlayback = false
		selectedScenePerformer.isNcdApiCall = nil
		selectedScenePerformer.ncdApiSceneSpec = nil
		selectedScenePerformer.performerId = nil
		selectedScenePerformer.performer = nil
		thisMod.sceneState.performerEntID = nil
		thisMod.sceneState.isSpycamAllowed = false
		thisMod.sceneState.nc_delightsDespawnSpycamRequest = osClock() + 1
		if not ncdApiPlaybackCallback then return end
		local result, data = pcall(function() ncdApiPlaybackCallback() end)
		if not result then print(modName, modVer..":", data) spdlog.error(modName.." "..modVer..":"..tostring(data)) end
		return
	end
	if not thisMod.sceneState.performerEntID and IsDefinedNS(selectedScenePerformer.performer) then thisMod.sceneState.performerEntID = selectedScenePerformer.performer:GetEntityID() end
	if thisMod.sceneState.performerEntID then thisMod.sceneState.isSpycamAllowed = true end
	if not isNcdApiPlayback then return end
	if not selectedScenePerformer.isNcdApiCall then return end
	if not selectedScenePerformer.ncdApiSceneSpec then return end
	if not selectedScenePerformer.ncdApiSceneSpec.onSceneStarted then return end
	local result, data = pcall(function() selectedScenePerformer.ncdApiSceneSpec.onSceneStarted() end)
	if not result then print(modName, modVer..":", data) spdlog.error(modName.." "..modVer..":"..tostring(data)) end
	selectedScenePerformer.ncdApiSceneSpec.onSceneStarted = nil
end

local removeAllMappins, removeAllDynamicMappins
thisMod.onShutdown = function()
	if isModuleDisabled then return end
	if not Game then return end
	if not GetPlayer then return end
	if not Game.GetMappinSystem then return end
	removeAllMappins()
end
createDefaultSceneLocationMappinData = function()
	if not TweakDB:GetRecord("Mappins.HotscenesNcDelightsSceneLocation") then
		TweakDB:CloneRecord("Mappins.HotscenesNcDelightsSceneLocation", "Mappins.StaticPointOfInterestMappinDefinition") -- by (c)keanuWheeze hint :)
		TweakDB:SetFlat("Mappins.HotscenesNcDelightsSceneLocation.showInWorld", false) -- by (c)keanuWheeze hint :)
		TweakDB:SetFlat("Mappins.HotscenesNcDelightsSceneLocation.showOnMinimap", true)
	end
	local pinData = MappinData.new() -- by (c)keanuWheeze hint :)
	pinData.mappinType = t"Mappins.HotscenesNcDelightsSceneLocation" -- by (c)keanuWheeze hint :)
	pinData.variant = gamedataMappinVariant.ServicePointProstituteVariant -- by (c)keanuWheeze hint :)
	pinData.visibleThroughWalls = true
	return pinData
end
resetSceneControls = function()
	questsSystem:SetFactStr("prostitutes_play_all_anims", 0);
	questsSystem:SetFactStr("hey_gle_prostittute_female_stop_rumble", 0);
	questsSystem:SetFactStr("hey_gle_prostittute_male_stop_rumble", 0);
	questsSystem:SetFactStr("wbr_sm_jpn_prostitute_female_stop_rumble", 0);
	questsSystem:SetFactStr("wbr_sm_jpn_prostitute_male_stop_rumble", 0);
	questsSystem:SetFactStr("hey_gle_female_rich_sex_clip", 0)
	questsSystem:SetFactStr("hey_gle_male_rich_sex_clip", 0)
	questsSystem:SetFactStr("wbr_jpn_female_poor_sex_clip", 0)
	questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_is_active", 0);
	questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_on", 0);
	questsSystem:SetFactStr("mod_hotscenes_nc_delights_f_insert_01_groping", 0);
	questsSystem:SetFactStr("mod_hotscenes_nc_delights_prefer_original_appearance", 0);
	questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 0);
end
local specialAppearanceSceneSupportCases = {
	female = {
		service__sexworker_wa__q105__prostitute_04 = "none",
		service__sexworker_wa_prostitute_poor_05 = {sceneSupport = "default", aux01Components = {{name = "s1_024_wa_boot__cowboy7657", value = false}}},
		service__sexworker_wa_prostitute_01 = "none",
		service__sexworker_wa_prostitute_01_1 = "none",
		service__sexworker_wa_prostitute_01_2 = "none",
		service__sexworker_wa_prostitute_07 = "none",
		service__sexworker_wa_prostitute_07_1 = "none",
		service__sexworker_wa_prostitute_07_2 = "none",
	},
	male = {}
}
setPerformerSceneSupport = function(gender, sceneName, isNcdApiCall, ncdApiSceneSpec)
	if isNcdApiCall and ncdApiSceneSpec.enableSceneSupport then questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 1) return end
	questsSystem:SetFactStr("mod_hotscenes_aux01_mode", 0)
	selectedScenePerformer.aux01Components = nil
	if (not isPlayerMale) and (not isKnownName("3581108883135097242")) then return end
	if type(thisMod.defaultPerformerSceneSupport) ~= 'table' then return end
	if type(selectedScenePerformer) ~= 'table' then return end
	if not isStringValid(selectedScenePerformer.performerAppearanceNameStr) then return end
	if not isStringValid(gender) then return end
	if type(thisMod.defaultPerformerSceneSupport[gender]) ~= 'table' then return end
	if not isStringValid(sceneName) then return end
	local sceneSupport = specialAppearanceSceneSupportCases[gender][selectedScenePerformer.performerAppearanceNameStr] or "default"
	local aux01Components
	if type(sceneSupport) == 'table' then aux01Components = sceneSupport.aux01Components sceneSupport = sceneSupport.sceneSupport end
	if sceneSupport == "none" then return end
	sceneSupport = thisMod.defaultPerformerSceneSupport[gender][sceneSupport]
	if type(sceneSupport) ~= 'table' then return end
	sceneSupport = sceneSupport[sceneName]
	if type(sceneSupport) ~= 'table' then return end
	if type(sceneSupport.facts) ~= 'table' then return end
	selectedScenePerformer.aux01Components = aux01Components
	for i, entry in pairs(sceneSupport.facts) do
		if isStringValid(entry.factName) and type(entry.value) == 'number' then
			questsSystem:SetFactStr(entry.factName, entry.value)
		end
	end
end

isObjectInSimpleArea = function(objectPos, simpleArea)
	local x = objectPos.x
	local simpleAreaX = simpleArea.x
	if x < simpleAreaX.min then return false end
	if x > simpleAreaX.max then return false end
	local y = objectPos.y
	local simpleAreaY = simpleArea.y
	if y < simpleAreaY.min then return false end
	if y > simpleAreaY.max then return false end
	return true
end

local function sign(x1, y1, x2, y2, x3, y3);
	return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
end;
function isPointInTriangle(point, triangle);
	local pointX = point.x
	local pointY = point.y
	local triangleAX = triangle.a.x
	local triangleAY = triangle.a.y
	local triangleBX = triangle.b.x
	local triangleBY = triangle.b.y
	local triangleCX = triangle.c.x
	local triangleCY = triangle.c.y
	local d1 = sign(pointX, pointY, triangleAX, triangleAY, triangleBX, triangleBY);
	local d2 = sign(pointX, pointY, triangleBX, triangleBY, triangleCX, triangleCY);
	local d3 = sign(pointX, pointY, triangleCX, triangleCY, triangleAX, triangleAY);
	local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0);
	local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0);
	return not (has_neg and has_pos);
end;

function isCensored()
	return not Game.GetCharacterCustomizationSystem():IsNudityAllowed()
end

isNCDelightsLauncherActivated = function()
	if questsSystem:GetFactStr("mod_hotscenes_nc_delights_f__active") < 1 then return false end
	if questsSystem:GetFactStr("mod_hotscenes_nc_delights_m__active") < 1 then return false end
	return true
end

local function isPrologueOrWarmupActive()
	if isNotPrologue then return false end
	if questsSystem:GetFactStr('q001_ripperdoc_done') > 0 then isNotPrologue = true return false end
	return true
end

local function isEndingActive()
	if isEnding then return true end
	if questsSystem:GetFactStr('q115_point_of_no_return') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q307_point_of_no_return') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q115_00b_johnny_angry') > 0 then isEnding = true return true end
	if questsSystem:GetFactStr('q115_hanako_sitting') > 0 then isEnding = true return true end
	return false
end

thisMod.updateSettings = function()
	if isModuleDisabled then return end

	shouldAllowActivity(true)

	local isFeatureEnabled = true
	shouldShowCustomDynamicMappins = false

	if thisMod.isModDisabled then isFeatureEnabled = false end
	if isNudityCensored then isFeatureEnabled = false end
	if not thisMod.userSettings.enableHotscenesAddon then isFeatureEnabled = false end
	if not thisMod.userSettings.enableNCDelightsFeature then isFeatureEnabled = false end

	if isFeatureEnabled then
		shouldShowCustomDynamicMappins = thisMod.userSettings.enableNCDelightsDynamicMappins
		if not shouldShowCustomDynamicMappins then removeAllDynamicMappins() end
	else
		shouldShowCustomDynamicMappins = false
		for i, sceneLocationData in ipairs(supportedLocations) do
			if type(sceneLocationData) == 'table' and type(sceneLocationData.toggleSceneLocationMappins) == 'function' then
				sceneLocationData.toggleSceneLocationMappins(false)
			end
		end
		removeAllMappins()
	end
end
thisMod.setIsFeatureEnabled = thisMod.updateSettings

local isModSupported = nil
thisMod.isModSupported = function()
	if isModuleDisabled then return false end
	if type(isModSupported) == 'boolean' then return isModSupported end
	if isKnownName("Hotscenes_overrides_mod_nc_delights_supported") then isModSupported = true return true end
	if TweakDB:GetFlat("mod_hotscenes_next_gen_isOverridesArchiveDetected") and (not isKnownName("Hotscenes_overrides_mod_nc_delights_supported")) then isModSupported = false return false end
	return isKnownName("Hotscenes_overrides_mod_nc_delights_supported")
end

local nextCheckAllowed = 0
shouldAllowActivity = function(force)
	if isModuleDisabled then isActivityAllowed = false currentActiveScene = nil return false end
	if thisMod.isModDisabled then isActivityAllowed = false currentActiveScene = nil return false end
	if isNudityCensored then isActivityAllowed = false currentActiveScene = nil return false end
	if not thisMod.userSettings.enableHotscenesAddon then isActivityAllowed = false currentActiveScene = nil return false end
	if not thisMod.userSettings.enableNCDelightsFeature then isActivityAllowed = false currentActiveScene = nil return false end
	local curTime = osClock()
	if not force and nextCheckAllowed > curTime then return isActivityAllowed end
	nextCheckAllowed = curTime + 0.2
	if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then currentActiveScene = nil return false end
	if not thisMod.isModSupported() then isActivityAllowed = false currentActiveScene = nil return false end
	local player = GetPlayer()
	if not player then isActivityAllowed = false currentActiveScene = nil return false end
	if not isNCDelightsLauncherActivated() then isActivityAllowed = false currentActiveScene = nil return false end
	if (isPrologueOrWarmupActive() or isEndingActive()) then isActivityAllowed = false currentActiveScene = nil return false end

	if type(canCombineWatsonAreas) ~= 'boolean' then canCombineWatsonAreas = isKnownName("Hotscenes_overrides_nc_delights_can_combine_watson_areas") end
	if type(canCombineWestbrookAreas) ~= 'boolean' then canCombineWestbrookAreas = isKnownName("Hotscenes_overrides_mod_version_info_51200") end

	local isAnyLocationActive = false
	local playerPos = player:GetWorldPosition()
	for i = 1, #supportedLocations do
		local sceneLocationData = supportedLocations[i]
		if sceneLocationData.isActive(player, playerPos) then
			isAnyLocationActive = true
			if (not currentActiveScene) or (not interaction.hubShown) or (not IsDefinedNS(lastInteractionOwner)) then
				if not player:IsCooldownActive(hotscenes_mod_freeze_selected_scene_cooldown_cname) then currentActiveScene = sceneLocationData end
			end
			break
		end
	end
	if not isAnyLocationActive then isActivityAllowed = false currentActiveScene = nil return false end
	isActivityAllowed = true
	return true
end
thisMod.shouldAllowActivity = shouldAllowActivity

local isPlayerFacingNpc
manageInteractions = function()
	if not lastInteractionOwner then return end
	if not isActivityAllowed then
		lastInteractionOwner = nil
		if interaction.hubShown then interaction.hideHub() end
		return
	end
	if not IsDefinedNS(lastInteractionOwner) then
		lastInteractionOwner = nil
		if interaction.hubShown then interaction.hideHub() end
		return
	end

	if not isActiveInWorkspotOrIdle(lastInteractionOwner, allowIdleNpcs) then
		lastInteractionOwner = nil
		interaction.hideHub()
		return
	end

	local player = GetPlayer()
	if not player then return end

	if not isInteractionAllowedByGameState(player) then
		lastInteractionOwner = nil
		interaction.hideHub()
		return
	end

	local playerPos = player:GetWorldPosition()
	local lastInteractionOwnerPos = lastInteractionOwner:GetWorldPosition()
	local distanceSquared = vectorDistanceSquared(lastInteractionOwnerPos, playerPos)
	if distanceSquared > disengageTargetDistanceSquared then
		lastInteractionOwner = nil
		interaction.hideHub()
		return
	elseif distanceSquared > engageTargetDistanceSquared then
		interaction.hideHub()
		return
	end

	if not isPlayerFacingNpc(player, lastInteractionOwner, 30, 85, playerPos, lastInteractionOwnerPos) then
		interaction.hideHub()
		return
	end
	if not interaction.hubShown then return createAdHocInteraction(lastInteractionOwner) end
	if osClock() > lastScannerNpcNameChanged then return end
	lastScannerNpcNameChanged = 0
	interaction.hideHub()
	createAdHocInteraction(lastInteractionOwner)
end

local isTargetInFrontOfOwner
local function getFinalWorkspotPlacement(player, playerPos, npcPos)
	if not player then player = GetPlayer() end
	if not playerPos then playerPos = player:GetWorldPosition() end
	local workspotPos = playerPos
	local workspotYaw = player:GetWorldYaw()
	if (not npcPos) and IsDefinedNS(lastInteractionOwner) then npcPos = lastInteractionOwner:GetWorldPosition() end
	if npcPos then
		local direction = Vector4.new(npcPos.x - playerPos.x, npcPos.y - playerPos.y , npcPos.z - playerPos.z, 1)
		local newWorkspotYaw = Vector4ToRotation(direction).yaw
		if not isTargetInFrontOfOwner(lastInteractionOwner, player, 15, npcPos, playerPos) then
			workspotYaw = newWorkspotYaw
		end
	end
	return workspotPos, workspotYaw
end

isInteractionAllowedByGameState = function(player)
	player = player or GetPlayer()
	local sceneTier = player:GetSceneTier()
	if sceneTier >= 3 or sceneTier < 1 then return end
	if StatusEffectSystem.ObjectHasStatusEffectWithTags(player, interactionRestrictionTags) then return end
	if GameGetScriptableSystemsContainer():Get(n_PreventionSystem):GetHeatStage() ~= EPreventionHeatStageHeat_0 then return end
	return true
end

local createSceneStartInteraction
createAdHocInteraction = function(targetNpc, npcCharacterData)
	if not isActivityAllowed then return end
	if not IsDefinedNS(interaction.baseControler) then return end
	if interaction.hubShown then return end
	if IsDefinedNS(lastInteractionWidgetGameController) and lastInteractionWidgetGameController.root:IsVisible() then return end
	local player = GetPlayer()
	if player:IsCooldownActive(hotscenes_mod_pay_workspot_interaction_cooldown_cname) then return end
	if player:IsCooldownActive(hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname) then return end
	if player:IsCooldownActive(hotscenes_mod_freeze_selected_scene_cooldown_cname) then return end
	if not isInteractionAllowedByGameState(player) then return end
	local isQuestActivated = currentActiveScene and currentActiveScene.isQuestActivated()
	if currentActiveScene and IsDefinedNS(targetNpc) then
		currentActiveSceneLocations = nil
		local isNpcInAnyActiveScene = false
		for i, sceneLocationData in ipairs(supportedLocations) do
			if sceneLocationData.isActive(targetNpc) then
				isNpcInAnyActiveScene = true
				if not currentActiveSceneLocations then
					currentActiveScene = sceneLocationData
					currentActiveSceneLocations = {}
				end
				tableInsert(currentActiveSceneLocations, sceneLocationData)
			end
		end
		if not isNpcInAnyActiveScene then return end
	end
	if isQuestActivated then return createSceneStartInteraction(targetNpc, npcCharacterData) end
end

local function getInteractionChoiceForScene(thisScene, targetNpc, npcCharacterData)
	local captionText
	if thisScene and type(thisScene.getInteractionCaptionText) == 'function' then
		captionText = thisScene.getInteractionCaptionText(targetNpc, npcCharacterData)
		if type(captionText) ~= 'string' or (not isStringValid(captionText)) then captionText = nil end
	end
	if not captionText then
		captionText = GetLocalizedText("LocKey#3537")
		captionText = stringGsub(captionText, "{COST.*STATUS}", "")
		captionText = stringGsub(captionText, ":", "")
		captionText = stringGsub(captionText, "^[ ]+", "")
		captionText = stringGsub(captionText, "[ ]+$", "")
	end
	local price = 50
	if thisScene and type(thisScene.priceTag) == 'number' then price = math.floor(mathMax(price, thisScene.priceTag)) end
	return interaction.createChoice("["..tostring(price).."]"..captionText, TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.PayIcon"), gameinteractionsChoiceType.QuestImportant)
end

local spawnEntity
local function getInteractionChoiceCallbackForScene(thisScene)
	return function()
		GetPlayer():StartCooldown(hotscenes_mod_freeze_selected_scene_cooldown_cname, 10)
		currentActiveScene = thisScene
		interaction.hideHub()
		if IsDefinedNS(lastPayWorkspot.handle) then
			local newWorkspotPos, newWorkspotYaw = getFinalWorkspotPlacement()
			GameGetTeleportationFacility():Teleport(lastPayWorkspot.handle, newWorkspotPos, EulerAngles.new(0, 0, newWorkspotYaw))
			lastPaymentExpected = osClock() + 1
			lastPayWorkspot.handle:QueueEvent(SetLogicReadyEvent.new())
			return
		end
		lastPayWorkspot = {}
		local newWorkspotPos, newWorkspotYaw = getFinalWorkspotPlacement()
		local spawnTransform = WorldTransform.new()
		WorldTransform.SetPosition(spawnTransform, newWorkspotPos)
		WorldTransform.SetOrientationEuler(spawnTransform, EulerAngles.new(0, 0, newWorkspotYaw))
		isUsingWorkspotNodeRef = false
		local pwsId = entEntityID.new({hash = 15477895835623691285ULL})
		local pws = GameFindEntityByID(pwsId)
		if pws and pws:FindComponentByName("stand__2h_on_sides__01__rh_flick_pay__01.workspot") then
			isUsingWorkspotNodeRef = true
			lastPayWorkspot.id = pwsId
			lastPayWorkspot.handle = RefWeak(pws)
			pws:QueueEvent(SetLogicReadyEvent.new())
		else
			lastPayWorkspot.id = spawnEntity('base\\hotscenes_overrides\\base\\cinematics\\workspots\\player\\stand__2h_on_sides__01__rh_flick_pay__01.ent', spawnTransform);
		end
		if lastPayWorkspot.id then lastPaymentExpected = osClock() + 1 end
	end
end

createSceneStartInteraction = function(targetNpc, npcCharacterData)
	local interactionTargetName = GetLocalizedText("LocKey#79112")
	if IsDefinedNS(targetNpc) then
		local npcName = targetNpc:GetTweakDBFullDisplayName(true)
		if isStringValid(npcName) then interactionTargetName = npcName end
		if type(npcCharacterData) ~= 'table' then
			local characterId = targetNpc:GetTDBID()
			local lookedCharacterData = nil
			for character, characterData in pairs(lookedCharacterTypes) do
				if characterId == characterData.id then lookedCharacterData = characterData break end
			end
			npcCharacterData = lookedCharacterData
		end
		if type(npcCharacterData) == 'table' then
			if npcCharacterData.isFemale then
				interactionTargetName = interactionTargetName.." ("..GetLocalizedText("LocKey#1231")..")"
			else
				interactionTargetName = interactionTargetName.." ("..GetLocalizedText("LocKey#1230")..")"
			end
		end
	end

	local choices, callbacks = {}, {}
	if type(currentActiveSceneLocations) == 'table'then
		for i = 1, #currentActiveSceneLocations do
			tableInsert(choices, getInteractionChoiceForScene(currentActiveSceneLocations[i], targetNpc, npcCharacterData))
			tableInsert(callbacks, getInteractionChoiceCallbackForScene(currentActiveSceneLocations[i]))
		end
	else
		tableInsert(choices, getInteractionChoiceForScene(currentActiveScene, targetNpc, npcCharacterData))
		tableInsert(callbacks, getInteractionChoiceCallbackForScene(currentActiveScene))
	end

	if #choices < 1 then return end
	if #choices ~= #callbacks then return end

	local hub = interaction.createHub(interactionTargetName, choices)
	interaction.setupHub(hub)
	interaction.callbacks = callbacks

	interaction.showHub()
	if not interaction.hubShown then return end
	return true
end

local getParentAppearanceName
local function startCharacterInteraction(owner, verifiedCharacterId, caller)
	if not owner then return end
	if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false end
	if not isActiveInWorkspotOrIdle(owner, allowIdleNpcs) then return end
	if not verifiedCharacterId then
		verifiedCharacterId = owner:GetTDBID()
		if not verifiedCharacterId or verifiedCharacterId.hash == 0 then return end
	end
	local lookedCharacterData = nil
	for character, characterData in pairs(lookedCharacterTypes) do
		if verifiedCharacterId == characterData.id then lookedCharacterData = characterData break end
	end
	if not lookedCharacterData then return end

	local isParent, parentAppearanceName, variantAppearanceNameStr = getParentAppearanceName(owner)
	if not parentAppearanceName then return end
	if lookedCharacterData.ltd then
		if not isKnownName(parentAppearanceName.."_naked_ltd") then return end
	else
		if not isKnownName(parentAppearanceName.."_naked") then return end
	end
	if not isParent and (not substituteVariantAppearancesWithKnownParents) then return end

	if IsDefinedNS(lastInteractionOwner) and lastInteractionOwner:GetEntityID().hash ~= owner:GetEntityID().hash then
		if interaction.hubShown and isPlayerFacingNpc(_, lastInteractionOwner, 15 , 89) then return end
		lastInteractionOwner = nil
		lastInteractionOwner = nil
		interaction.hideHub()
	end
	if createAdHocInteraction(owner, lookedCharacterData) then lastInteractionOwner = RefWeak(owner) return true end
end

local moneyItem
local function spendMoney(amount)
	if type(amount) ~= 'number' then return end
	amount = math.ceil(amount)
	if amount < 1 then return end
	if not moneyItem then moneyItem = gameItemID.FromTDBID(t"Items.money") end
	transactionSystem():RemoveItem(GetPlayer(), moneyItem, amount)
end

local spawnWithCodeware, spawnWithCet
spawnEntity = function(pathOrID, spawnTransform, appName, tags)
	if not spawnTransform then spawnTransform = GetPlayer():GetWorldTransform() end
	local id = spawnWithCodeware(pathOrID, spawnTransform, appName, tags)
	if id then return id end
	return spawnWithCet(pathOrID, spawnTransform, appName)
end

spawnWithCodeware = function(pathOrID, spawnTransform, appName, tags);
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

spawnWithCet = function(pathOrID, spawnTransform, appName);
	if type(pathOrID) ~= 'string' then return end;
	if not isStringValid(pathOrID) then return end;
	local isRecord, isValid = false, false;
	if TweakDB:GetRecord(pathOrID) then isRecord = true isValid = true end;
	if (not isRecord) and stringMatch(pathOrID, '%.ent$') then isValid = true end;
	if not isValid then return end;
	if isRecord then;
		id = exEntitySpawner.SpawnRecord(pathOrID, spawnTransform, appName);
	else
		id = exEntitySpawner.Spawn(pathOrID, spawnTransform, appName);
	end
	return id
end;

local function isSamePosition(a, b)
	if mathAbs(a.z - b.z) > 0.0001 then return false end
	if mathAbs(a.y - b.y) > 0.0001 then return false end
	if mathAbs(a.x - b.x) > 0.0001 then return false end
	return true
end

isActiveInWorkspotOrIdle = function(this, allowIdleState)
	if not this then return end
	local workspotInfo = workspotSystem:GetExtendedInfo(this)
	if workspotInfo.entering then return end
	if workspotInfo.exiting then return end
	if workspotInfo.isActive then return true end
	if allowIdleState and this:GetVelocity():IsXYZZero() then return true end
end

isTargetInFrontOfOwner = function(owner, target, frontAngle, ownerPos, targetPos)
	local direction = Vector4.new()
	ownerPos = ownerPos or owner:GetWorldPosition();
	targetPos = targetPos or target:GetWorldPosition();
	if type(frontAngle) ~= 'number' or frontAngle == 0.00 then frontAngle = 90.00 end

	direction.x = ownerPos.x - targetPos.x
	direction.y = ownerPos.y - targetPos.y
	direction.z = ownerPos.z - targetPos.z
	local angleToTarget = Vector4GetAngleDegAroundAxis(direction, target:GetWorldForward(), target:GetWorldUp());
	if mathAbs(angleToTarget) < frontAngle then
		return true;
	end
	return false;
end

isPlayerFacingNpc = function(player, npc, playerFrontAngle, npcFrontAngle, playerPos, npcPos)
	if not npc then return end
	if not player then player = GetPlayer() end
	if type(playerFrontAngle) ~= 'number' or playerFrontAngle < 0.0001 then playerFrontAngle = 90.00 end
	if type(npcFrontAngle) ~= 'number' or npcFrontAngle < 0.0001 then npcFrontAngle = 90.00 end

	playerPos = playerPos or player:GetWorldPosition()
	npcPos = npcPos or npc:GetWorldPosition()
	local direction = Vector4.new()
	direction.x = npcPos.x - playerPos.x
	direction.y = npcPos.y - playerPos.y
	direction.z = npcPos.z - playerPos.z
	local worldUp = Vector4.new(0, 0, 1, 0)
	local angleToTarget = Vector4GetAngleDegAroundAxis(direction, player:GetWorldForward(), worldUp);
	if mathAbs(angleToTarget) > playerFrontAngle then return false end
	direction.x = playerPos.x - npcPos.x
	direction.y = playerPos.y - npcPos.y
	direction.z = playerPos.z - npcPos.z
	local angleToTarget = Vector4GetAngleDegAroundAxis(direction, npc:GetWorldForward(), worldUp);
	if mathAbs(angleToTarget) > npcFrontAngle then return false end
	return true
end

getNodeTransformByNodeRef = function(nodeRef, checkOnly);
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

function isKnownName(inputString)
	return CName.new(inputString).value == inputString
end

local function isParentAppearance(npc)
	local npcParentAppearanceNameStr = npc:GetCurrentAppearanceName().value
	local apm = npc:FindComponentByName(AppearanceProxyMesh)
	if not apm then return true, npcParentAppearanceNameStr end
	local variantAppearanceSuffixStr = apm.meshAppearance.value
	if variantAppearanceSuffixStr == 'default' then return true, npcParentAppearanceNameStr end
	return false, npcParentAppearanceNameStr, variantAppearanceSuffixStr
end

getParentAppearanceName = function(npc)
	if not npc then return end
	local isParent, currentAppearanceNameStr, variantAppearanceSuffixStr = isParentAppearance(npc)
	if isParent then return true, currentAppearanceNameStr end
	local baseAppearanceNameStr = stringGsub(variantAppearanceSuffixStr, "_[0-9]+$", "")
	if not isKnownName(baseAppearanceNameStr) then return false, currentAppearanceNameStr end
	if not stringMatch(currentAppearanceNameStr, baseAppearanceNameStr.."$") then return false, currentAppearanceNameStr end
	local variantAppearanceNameStr = stringGsub(currentAppearanceNameStr, baseAppearanceNameStr.."$", variantAppearanceSuffixStr)
	if isKnownName(variantAppearanceNameStr) then return false, currentAppearanceNameStr, variantAppearanceNameStr end
	return false, currentAppearanceNameStr
end

local sceneOngoingPlaybackFacts = {
	'mod_hotscenes_hey_gle_f__ftplay_playing',
	'mod_hotscenes_wbr_jpn_f__ftplay_playing',
	'mod_hotscenes_hey_gle_m__ftplay_playing',
	'mod_hotscenes_wbr_jpn_m__ftplay_playing',
}

resetScenePlaybackStateFacts = function()
	for i, fact in pairs(sceneOngoingPlaybackFacts) do questsSystem:SetFactStr(fact, 0) end
end

local function isAnyScenePlayingByFacts()
	for i, fact in pairs(sceneOngoingPlaybackFacts) do if questsSystem:GetFactStr(fact) > 0 then return true end end
end

isPlayerInHotscene = function(player);
	player = player or GetPlayer();
	if not player then return end;

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

setMappinToPosition = function(pinData, pos)
	if type(pinData) ~= 'userdata' then return end
	if type(pos) ~= 'userdata' then return end
	local id = mappinSystem:RegisterMappin(pinData, pos)
	if not id then return end
	tableInsert(myStaticMappins, id)
	return id
end

local nextSceneMappinsUpdateAllowed = 0
local function updateAllScenesLocationMappins(force)
	if thisMod.isModDisabled then return end
	if thisMod.isNudityCensored then return end
	if not thisMod.userSettings.enableHotscenesAddon then return end
	if not thisMod.userSettings.enableNCDelightsFeature then return end
	local currTime = osClock()
	if (not force) and nextSceneMappinsUpdateAllowed > currTime then return end
	nextSceneMappinsUpdateAllowed = currTime + 1
	if not thisMod.isModSupported() then return end
	if isPrologueOrWarmupActive() then return end
	if isEndingActive() then return end
	for i = 1, #supportedLocations do
		local sceneLocationData = supportedLocations[i]
		if type(sceneLocationData) == 'table' and type(sceneLocationData.updateSceneLocationMappins) == 'function' then
			sceneLocationData.updateSceneLocationMappins()
		end
	end
end

local function setUpCustomDynamicPointOfInterestMappinDefinition()
	if TweakDB:GetRecord("Mappins.DynamicPointOfInterestMappinDefinitionHotscenes_mod") then return end
	TweakDB:CloneRecord("Mappins.DynamicPointOfInterestMappinDefinitionHotscenes_mod", "Mappins.DynamicPointOfInterestMappinDefinition")
	TweakDB:SetFlat("Mappins.DynamicPointOfInterestMappinDefinitionHotscenes_mod.showOnMap", true)
	TweakDB:SetFlat("Mappins.DynamicPointOfInterestMappinDefinitionHotscenes_mod.showOnMinimap", true)
end

local function attachDynamicMappinToNpc(owner, player, ownerPos, playerPos, distanceSquared, isScanning)
	if not shouldShowCustomDynamicMappins then return end
	if not IsDefinedNS(owner) then return end
	if not owner:IsNPC() then return end
	if not isActiveInWorkspotOrIdle(owner, allowIdleNpcs) then return end

	local entityId = owner:GetEntityID()
	local ownerEntIdHashStr = tostring(entityId.hash)
	if myEntityDynamicMappins then
		if myEntityDynamicMappins[ownerEntIdHashStr] and myEntityDynamicMappins[ownerEntIdHashStr].id then return end
	end

	player = player or GetPlayer()
	playerPos = playerPos or player:GetWorldPosition()
	ownerPos = ownerPos or owner:GetWorldPosition()
	distanceSquared = distanceSquared or vectorDistanceSquared(playerPos, ownerPos)
	if distanceSquared > dynamicMappinRangeSquared then return end

	local closestActiveScene
	for i, sceneLocationData in ipairs(supportedLocations) do
		if sceneLocationData.isObjectWithinArea(owner, ownerPos) and sceneLocationData.isQuestActivated() and sceneLocationData.isSceneWorldDataAvailable() then
			closestActiveScene = sceneLocationData
			break
		end
	end
	if not closestActiveScene then return end

	local path = aINavigationSystem:CalculatePathForCharacter(playerPos, ownerPos, 0.05, player)
	if not path then 
		if (not isScanning) and distanceSquared >= disengageTargetDistanceSquared then return end
		playerPos.z = playerPos.z + 0.5
		ownerPos.z = ownerPos.z + 0.5
		local hit, traceResult = spatialQueriesSystem:SyncRaycastByCollisionGroup(playerPos, ownerPos, "Static", raycastTrace)
		if hit and TraceResult.IsValid(traceResult) then return end
	else
		if path:CalculateLength() > 87.5 then return end
	end

	setUpCustomDynamicPointOfInterestMappinDefinition()
	local pinData = MappinData.new({ mappinType = 'Mappins.DynamicPointOfInterestMappinDefinitionHotscenes_mod', variant = gamedataMappinVariant.ServicePointProstituteVariant, visibleThroughWalls = true })
	local id = mappinSystem:RegisterMappinWithObject(pinData, owner, "head_above", Vector3.new(0, 0, 0.15))
	if not id then return end
	if type(myEntityDynamicMappins) ~= 'table' then myEntityDynamicMappins = {} end
	myEntityDynamicMappins[ownerEntIdHashStr] = {id = id, owner = RefWeak(owner), entityId = entityId, appearanceNameStr = owner:GetCurrentAppearanceName().value}
end

local function removeDynamicMappinFromObject(owner, caller)
	if not myEntityDynamicMappins then return end
	if not IsDefinedNS(owner) then return end
	local entityIdHashStr = tostring(owner:GetEntityID().hash)
	local mappinRec = myEntityDynamicMappins[entityIdHashStr]
	if not mappinRec then return end
	if mappinRec.id then mappinSystem:UnregisterMappin(mappinRec.id) end
	myEntityDynamicMappins[entityIdHashStr] = nil
end

local nextMappinsUpdateAllowed = 0
local function updateDynamicMappins(player, playerPos)
	if not myEntityDynamicMappins then return end
	local curTime = osClock()
	if nextMappinsUpdateAllowed > curTime then return end
	nextMappinsUpdateAllowed = curTime + 0.5
	player = player or GetPlayer()
	if not player then return end
	playerPos = playerPos or player:GetWorldPosition()
	local count = 0
	for entIdHashStr, mappinRec in pairs(myEntityDynamicMappins) do
		count = count + 1
		if mappinRec.id then
			local shouldRemoveMappin = true
			local isRestored = false
			if (not IsDefinedNS(mappinRec.owner)) and mappinRec.entityId then
				mappinRec.owner = GameFindEntityByID(mappinRec.entityId)
				isRestored = true
			end
			if mappinRec.owner then
				shouldRemoveMappin = vectorDistanceSquared(playerPos, mappinRec.owner:GetWorldPosition()) >= dynamicMappinRangeSquared
				if (not shouldRemoveMappin) and (not isActiveInWorkspotOrIdle(mappinRec.owner, allowIdleNpcs)) then shouldRemoveMappin = true end
				if isRestored and (not shouldRemoveMappin) then mappinRec.owner = RefWeak(mappinRec.owner) end
			end
			if shouldRemoveMappin then
				mappinSystem:UnregisterMappin(mappinRec.id)
				myEntityDynamicMappins[entIdHashStr] = nil
			end
		else
			myEntityDynamicMappins[entIdHashStr] = nil
		end
	end
	if count < 1 then myEntityDynamicMappins = nil end
end

removeAllDynamicMappins = function()
	if not myEntityDynamicMappins then return end
	for i, mappinRec in pairs(myEntityDynamicMappins) do
		if mappinRec.id then mappinSystem:UnregisterMappin(mappinRec.id) end
	end
	myEntityDynamicMappins = nil
end

removeAllMappins = function()
	if type(myStaticMappins) == 'table' and #myStaticMappins > 0 then
		for i = #myStaticMappins, 1, -1 do
			mappinSystem:UnregisterMappin(myStaticMappins[i])
		end
	end
	myStaticMappins = {}

	if type(myEntityDynamicMappins) ~= 'table' then return end
	for i, mappinRec in pairs(myEntityDynamicMappins) do
		if mappinRec.id then mappinSystem:UnregisterMappin(mappinRec.id) end
	end
	myEntityDynamicMappins = nil
end

setCinematicMode = function(enable, highTier, force, player) -- based on toggleHUD() by (c)keanuWheeze from SitAnywhere mod.
	if enable then
		if type(highTier) ~= 'number' then highTier = 3 end
		highTier = mathMax(mathMin(highTier, 5), 3)
		player = player or GetPlayer()
		if (not force) and player:GetSceneTier() >= highTier then return true end
		local blackboardPSM = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefsPlayerStateMachine)
		if not blackboardPSM then return end
		blackboardPSM:SetInt(allBlackboardDefsPlayerStateMachine.SceneTier, highTier, true)
		return true
	else
		player = player or GetPlayer()
		local blackboardPSM = gameBlackBoardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefsPlayerStateMachine);
		if not blackboardPSM then return end
		blackboardPSM:SetInt(allBlackboardDefsPlayerStateMachine.SceneTier, 1, true);
		return true
	end
end

setObservers = function()
	interaction.init()

	local function isNpcDeadOrDefeated(this)
		if this:IsDead() or (not this:IsAlive()) then return true end
		if this:GetKiller() then return true end
		if this:IsDefeated() then return true end
		return false
	end
	local n_Head = n"Head"
	local n_WeaponLeft = n"WeaponLeft"
	local n_WeaponRight = n"WeaponRight"
	local function shouldLeaveItAlone(this, pos)
		local attachementSlots = this.slotComponent
		if not attachementSlots then return end
		local result, headSlotTransform = attachementSlots:GetSlotTransform(n_Head);
		if not result then return end
		local headSlotPos = headSlotTransform.Position:ToVector4()
		pos = pos or this:GetWorldPosition()
		diff = headSlotPos.z-pos.z;
		if diff > 1 then return end
		if diff < 0.3 then return true end
		local headSlotPosRot = headSlotTransform.Orientation:ToEulerAngles()
		if headSlotPosRot.pitch < 30 then return end
		if headSlotPosRot.pitch > 50 then return true end
		local result, weaponLeftSlotTransform = attachementSlots:GetSlotTransform(n_WeaponLeft);
		if not result then return end
		local result, weaponRightSlotTransform = attachementSlots:GetSlotTransform(n_WeaponRight);
		if not result then return end
		local weaponLeftSlotPos = weaponLeftSlotTransform.Position:ToVector4()
		local weaponRightSlotPos = weaponRightSlotTransform.Position:ToVector4()
		if vectorDistance(headSlotPos, weaponRightSlotPos) < 0.25 then return true end
		if vectorDistance(weaponLeftSlotPos, weaponRightSlotPos) < 0.22 then return true end
	end

	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
		if this:IsReplacer() then return end
		workspotSystem = RefWeak(Game.GetWorkspotSystem())
		cameraSystem = RefWeak(Game.GetCameraSystem())
		questsSystem = RefWeak(Game.GetQuestsSystem())
		mappinSystem = RefWeak(Game.GetMappinSystem())
		interaction.hideHub()
		isNcdApiPlayback = false
		lastInteractionOwner = nil
		lastPaymentExpected = 0
		lastPayWorkspot = {}
		if type(selectedScenePerformer) == 'table' then for k, v in pairs(selectedScenePerformer) do selectedScenePerformer[k] = nil end end
		selectedScenePerformer = {}
		currentActiveSceneLocations = nil
		if thisMod.sceneState and thisMod.sceneState.isNCDelightsScenePlaying then
			thisMod.sceneState.performerEntID = nil
			thisMod.sceneState.isSpycamAllowed = false
			thisMod.sceneState.isNCDelightsScenePlaying = false
		end
		isNudityCensored = isCensored()
		isNotPrologue = false
		isPrologueOrWarmupActive()
		isEnding = false
		isEndingActive()
		canCombineWatsonAreas = isKnownName("Hotscenes_overrides_nc_delights_can_combine_watson_areas")
		for i, sceneLocationData in ipairs(supportedLocations) do
			if type(sceneLocationData) == 'table' and type(sceneLocationData.toggleSceneLocationMappins) == 'function' then
				sceneLocationData.toggleSceneLocationMappins(false, true)
			end
		end
		removeAllDynamicMappins()
		thisMod.updateSettings()
		if not isEp1Installed then isEp1Installed = journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry') and TweakDB:GetRecord("Character.bella") end
		scheduleGameNpcRecordsVerification(thisMod.userSettings and thisMod.userSettings.restoreNpcDefaults)
	end)
	ObserveAfter('PlayerPuppet', 'OnMakePlayerVisibleAfterSpawn', function(this)
		updateAllScenesLocationMappins(true)
	end)
	Observe('PlayerPuppet', 'OnFactChangedEvent', function(this, evt)
		if not thisMod.sceneState then return end
		if not thisMod.sceneState.isNCDelightsScenePlaying then return end
		if not selectedScenePerformer then return end
		if type(selectedScenePerformer.aux01Components) ~= 'table' then return end
		if evt:GetFactName().value ~= "mod_hotscenes_main_fem_aux01_started" then return end
		local npc = selectedScenePerformer.performer
		if not IsDefinedNS(npc) then return end
		for i, c in pairs(selectedScenePerformer.aux01Components) do
			local cp = npc:FindComponentByName(c.name)
			if cp then cp:Toggle(c.value) end
		end
		selectedScenePerformer.aux01Components = nil
	end)
	Observe('LoadingScreenProgressBarController', 'OnInitialize', function()
		removeAllDynamicMappins()
	end)
	local n_hotscenes_mod_security_area = n"hotscenes_mod_security_area"
	Observe("SecurityArea", "OnGameAttached", function(this);
		local entIdHashStr = tostring(this:GetEntityID().hash)
		if not lookedSecurityAreas[entIdHashStr] then return end;
		if not this:FindComponentByName(n_hotscenes_mod_security_area) then return end
		lookedSecurityAreas[entIdHashStr].handle = RefWeak(this)
	end);
	ObserveBefore("SecurityArea", "OnDetach", function(this);
		local entIdHashStr = tostring(this:GetEntityID().hash)
		if not lookedSecurityAreas[entIdHashStr] then return end;
		if not this:FindComponentByName(n_hotscenes_mod_security_area) then return end
		lookedSecurityAreas[entIdHashStr].handle = nil
	end);
	local function applyRuntimePatches(this, evt)
		if not selectedScenePerformer.runtimePatch03 then return end
		if type(selectedScenePerformer.runtimePatch03) == 'function' then
			if not selectedScenePerformer.runtimePatch03(this, evt) then return end
		end
		selectedScenePerformer.runtimePatch03 = nil
	end
	ObserveAfter("SecurityArea", "OnAreaEnter", function(this, evt)
		if thisMod.sceneState.isNCDelightsScenePlaying then applyRuntimePatches(this, evt) return end
		local entIdHashStr = tostring(this:GetEntityID().hash)
		if lookedSecurityAreas[entIdHashStr] and (not lookedSecurityAreas[entIdHashStr].handle) then lookedSecurityAreas[entIdHashStr].handle = RefWeak(this) end
		updateDynamicMappins()
		shouldAllowActivity()
	end)
	ObserveAfter('InteractiveMasterDevice', 'OnGameAttached', function(this)
		if not isActivityAllowed then return end
		if isUsingWorkspotNodeRef then return end
		if osClock() > lastPaymentExpected then return end
		local cp = this:FindComponentByName("stand__2h_on_sides__01__rh_flick_pay__01.workspot")
		if not cp then return end
		lastPayWorkspot.handle = RefWeak(this)
		this:QueueEvent(SetLogicReadyEvent.new())
	end)
	local n_SecurityArea = n"SecurityArea"
	ObserveAfter("InteractiveMasterDevice", "OnLogicReady", function(this, evt)
		if this:IsA(n_SecurityArea) then
			local entIdHashStr = tostring(this:GetEntityID().hash)
			if not lookedSecurityAreas[entIdHashStr] then return end
			lookedSecurityAreas[entIdHashStr].handle = RefWeak(this)
		end
		if not isActivityAllowed then return end
		if evt.isReady then return end
		if not lastPayWorkspot.handle then return end
		if osClock() > lastPaymentExpected then return end
		if not IsDefinedNS(lastPayWorkspot.handle) then lastPayWorkspot.handle = nil return end
		if not isSameInstance(this, lastPayWorkspot.handle) then return end
		local player = GetPlayer()
		local workspotPos = this:GetWorldPosition()
		local playerPos = player:GetWorldPosition()
		if not isSamePosition(workspotPos, playerPos) then
			lastPayWorkspot.isNewSpawn = false
			local newWorkspotPos, newWorkspotYaw = getFinalWorkspotPlacement(player, playerPos)
			GameGetTeleportationFacility():Teleport(lastPayWorkspot.handle, newWorkspotPos, EulerAngles.new(0, 0, newWorkspotYaw))
			this:QueueEvent(SetLogicReadyEvent.new())
			return
		end
		lastPaymentExpected = 0
		interaction.hideHub()

		if not IsDefinedNS(lastInteractionOwner) then return end
		if not isActiveInWorkspotOrIdle(lastInteractionOwner, allowIdleNpcs) then return end

		player:StartCooldown(hotscenes_mod_pay_workspot_interaction_cooldown_cname, 10)
		workspotSystem:PlayInDeviceSimple(lastPayWorkspot.handle, player, true, "stand__2h_on_sides__01__rh_flick_pay__01.workspot", "", "", 0.6)
		lastInteractionOwner.reactionComponent:TriggerFacialLookAtReaction(false, true)
		selectedScenePerformer.performerSource = lastInteractionOwner
		local payload = function()
			if not IsDefinedNS(selectedScenePerformer.performerSource) then selectedScenePerformer = {} return end
			if (not GetPlayer():IsCooldownActive(hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname)) and (not isActiveInWorkspotOrIdle(selectedScenePerformer.performerSource, allowIdleNpcs)) then selectedScenePerformer = {} return end
			GameObjectEffectHelper.StartEffectEvent(lastInteractionOwner, "eye_glow_blue")
			local npc = RefWeak(lastInteractionOwner)
			local payload = function() if not IsDefinedNS(npc) then return end GameObjectEffectHelper.StopEffectEvent(npc, "eye_glow_blue") end
			thisMod.queueTask(payload, false, 3)
			spendMoney(currentActiveScene.priceTag)
		end
		thisMod.queueTask(payload, false, 2)
	end)
	ObserveAfter('InteractiveMasterDevice', 'OnWorkspotFinished', function(this, componentName)
		if not isActivityAllowed then return end
		if not lastPayWorkspot.handle then return end
		if not IsDefinedNS(lastPayWorkspot.handle) then lastPayWorkspot.handle = nil return end
		if not isSameInstance(this, lastPayWorkspot.handle) then return end
		if componentName.value ~= "stand__2h_on_sides__01__rh_flick_pay__01.workspot" then return end

		if not currentActiveScene then return end
		if not selectedScenePerformer.performerSource then return end
		if not IsDefinedNS(selectedScenePerformer.performerSource) then selectedScenePerformer = {} return end

		local characterId = selectedScenePerformer.performerSource:GetTDBID()
		local npcCharacterData = nil
		for character, characterData in pairs(lookedCharacterTypes) do
			if characterId == characterData.id then npcCharacterData = characterData break end
		end
		if type(npcCharacterData) ~= 'table' then selectedScenePerformer = {} return end

		local isLtd = npcCharacterData.ltd
		selectedScenePerformer.performerId = nil
		selectedScenePerformer.shouldUseNoCoatAppearance = false

		local shouldUseVariantAppearance = false
		local isParent, parentAppearanceName, variantAppearanceNameStr = getParentAppearanceName(selectedScenePerformer.performerSource)
		if isParent then
			selectedScenePerformer.performerAppearanceNameStr = parentAppearanceName
		else
			if variantAppearanceNameStr and variantAppearanceNameStr ~= parentAppearanceName and (isLtd and isKnownName(parentAppearanceName.."_naked_ltd") or isKnownName(parentAppearanceName.."_naked")) then selectedScenePerformer.performerAppearanceNameStr = variantAppearanceNameStr shouldUseVariantAppearance = true end
		end
		if (not selectedScenePerformer.performerAppearanceNameStr) and parentAppearanceName and (isLtd and isKnownName(parentAppearanceName.."_naked_ltd") or isKnownName(parentAppearanceName.."_naked")) then
			selectedScenePerformer.performerAppearanceNameStr = parentAppearanceName
			shouldUseVariantAppearance = (not isParent) and stringMatch(selectedScenePerformer.performerAppearanceNameStr, "_[0-9]+_[0-9]+$")
		end

		local payload
		local selectedScene = currentActiveScene
		isNcdApiPlayback = false
		selectedScenePerformer.isNcdApiCall = nil
		selectedScenePerformer.ncdApiSceneSpec = nil
		if npcCharacterData.isFemale then
			selectedScenePerformer.isFemale = true
			selectedScenePerformer.performerGender = "Female"
			if type(selectedScene.getFemalePerformerIdStr) == 'function' then selectedScenePerformer.performerIdStr = selectedScene.getFemalePerformerIdStr() else selectedScenePerformer.performerIdStr = selectedScene.femalePerformerIdStr end
			selectedScenePerformer.performerId = t(selectedScenePerformer.performerIdStr)
			selectedScenePerformer.shouldUseNoCoatAppearance = selectedScene.isJapantownFemaleScene
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 0);
			selectedScenePerformer.ltd = nil
			if isLtd then selectedScenePerformer.ltd = "_ltd" end
			payload = function() selectedScene.startFemaleScene(shouldUseVariantAppearance, npcCharacterData.isCombatZone) end
		else
			selectedScenePerformer.isFemale = false
			selectedScenePerformer.performerGender = "Male"
			if type(selectedScene.getMalePerformerIdStr) == 'function' then selectedScenePerformer.performerIdStr = selectedScene.getMalePerformerIdStr() else selectedScenePerformer.performerIdStr = selectedScene.malePerformerIdStr end
			selectedScenePerformer.performerId = t(selectedScenePerformer.performerIdStr)
			questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 0);
			selectedScenePerformer.ltd = nil
			if isLtd then selectedScenePerformer.ltd = "_ltd" end
			payload = function() selectedScene.startMaleScene(shouldUseVariantAppearance, npcCharacterData.isCombatZone) end
		end
		if not payload then return end

		GetPlayer():StartCooldown(hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname, 10)
		thisMod.queueTask(payload, false, 2.5)
	end)
	function addMappinToOwner(owner, isScanning, caller)
		local characterId = owner:GetTDBID()
		if not characterId or characterId.hash == 0 then return end
		local currentAppearanceNameStr, characterIdHashStr
		if thisMod.userSettings.allowUnknownCustomCharacterData then
			characterIdHashStr = tostring(characterId.hash)
			if not lookedCharacterTypesByIdHash[characterIdHashStr] then return end
			currentAppearanceNameStr = owner:GetCurrentAppearanceName().value
			if not isKnownName(currentAppearanceNameStr.."_naked") then return end
		else
			local templatePath = TweakDB:GetFlat(TweakDBID.new(characterId, '.entityTemplatePath'))
			if not templatePath then return end
			if not lookedCharacterTypesByTemplatePath[tostring(templatePath.hash)] then return end
		end
		characterIdHashStr = characterIdHashStr or tostring(characterId.hash)
		local characterData = lookedCharacterTypesByIdHash[characterIdHashStr]
		if not characterData then return end
		if characterData.ltd then
			currentAppearanceNameStr = currentAppearanceNameStr or owner:GetCurrentAppearanceName().value
			if (not isKnownName(currentAppearanceNameStr.."_naked_ltd")) then return end
		end
		attachDynamicMappinToNpc(owner, _, _, _, _, isScanning)
	end
	function processComponentOwner(this, caller)
		local owner = this:GetOwner()
		local characterId = owner:GetTDBID()
		if not characterId or characterId.hash == 0 then return end
		local currentAppearanceNameStr, characterIdHashStr
		if thisMod.userSettings.allowUnknownCustomCharacterData then
			characterIdHashStr = tostring(characterId.hash)
			if not lookedCharacterTypesByIdHash[characterIdHashStr] then return end
			currentAppearanceNameStr = owner:GetCurrentAppearanceName().value
			if not isKnownName(currentAppearanceNameStr.."_naked") then return end
		else
			local templatePath = TweakDB:GetFlat(TweakDBID.new(characterId, '.entityTemplatePath'))
			if not templatePath then return end
			if not lookedCharacterTypesByTemplatePath[tostring(templatePath.hash)] then return end
		end
		characterIdHashStr = characterIdHashStr or tostring(characterId.hash)
		local characterData = lookedCharacterTypesByIdHash[characterIdHashStr]
		if not characterData then return end
		if characterData.ltd then
			currentAppearanceNameStr = currentAppearanceNameStr or owner:GetCurrentAppearanceName().value
			if (not isKnownName(currentAppearanceNameStr.."_naked_ltd")) then return end
		end
		if isNpcDeadOrDefeated(owner) then return end
		local ownerPos = owner:GetWorldPosition()
		if characterData.isFemale and shouldLeaveItAlone(owner, ownerPos) then return end
		local player = GetPlayer()
		local playerPos = player:GetWorldPosition()
		local distanceSquared = vectorDistanceSquared(ownerPos, playerPos)
		attachDynamicMappinToNpc(owner, player, ownerPos, playerPos, distanceSquared)
		if distanceSquared > engageTargetDistanceSquared then return end
		if not isPlayerFacingNpc(player, owner, 30, 85, playerPos, ownerPos) then return end
		local path = aINavigationSystem:CalculatePathForCharacter(playerPos, ownerPos, 0.05, player)
		if not path then 
			playerPos.z = playerPos.z + 0.5
			ownerPos.z = ownerPos.z + 0.5
			local hit, traceResult = spatialQueriesSystem:SyncRaycastByCollisionGroup(playerPos, ownerPos, "Static", raycastTrace)
			if hit and TraceResult.IsValid(traceResult) then return end
		else
			if path:CalculateLength() > 11 then return end
		end
		local result = startCharacterInteraction(owner, characterId, caller)
	end
	Observe('ScriptedPuppet', 'OnWorkspotFinishedEvent', function(this)
		if not this:IsNPC() then return end
		removeDynamicMappinFromObject(this, 'OnWorkspotFinishedEvent')
	end)
	ObserveAfter("ReactionManagerComponent", "OnLookedAtEvent", function(this, evt)
		if thisMod.sceneState.isNCDelightsScenePlaying then return end
		updateDynamicMappins()
		shouldAllowActivity()
		if not isActivityAllowed then return end
		processComponentOwner(this, 'ReactionManagerComponent:OnLookedAtEvent')
	end)
	ObserveAfter("ReactionManagerComponent", "OnPlayerProximityStartEvent", function(this, evt)
		if thisMod.sceneState.isNCDelightsScenePlaying then return end
		updateDynamicMappins()
		shouldAllowActivity()
		if not isActivityAllowed then return end
		processComponentOwner(this, 'ReactionManagerComponent:OnPlayerProximityStartEvent')
	end)
	ObserveAfter("ReactionManagerComponent", "OnProximityLookatEvent", function(this, evt)
		if thisMod.sceneState.isNCDelightsScenePlaying then return end
		updateDynamicMappins()
		if not isActivityAllowed then return end
		processComponentOwner(this, 'ReactionManagerComponent:OnProximityLookatEvent')
	end)
	ObserveAfter("ReactionManagerComponent", "OnRepeatLookatEvent", function(this, evt)
		if thisMod.sceneState.isNCDelightsScenePlaying then return end
		updateDynamicMappins()
		if not isActivityAllowed then return end
		processComponentOwner(this, 'ReactionManagerComponent:OnRepeatLookatEvent')
	end)
	local searchQuery = TargetSearchQuery.new()
	searchQuery.filterObjectByDistance = true
	searchQuery.testedSet = gameTargetingSet.Frustum
	searchQuery.maxDistance = 35
	searchQuery.includeSecondaryTargets = false
	searchQuery.ignoreInstigator = true
	ObserveAfter("scannerGameController", "OnStateChanged", function(this, val)
		if not isActivityAllowed then return end
		if thisMod.sceneState.isNCDelightsScenePlaying then return end
		local newState = FromVariant(val)
		if newState ~= gameScanningState.Started then return end
		local targets = {}
		local _, targets = targetingSystem:GetTargetParts(GetPlayer(), searchQuery)
		for i, target in ipairs(targets) do
			local gameObj = TS_TargetPartInfo.GetComponent(target):GetEntity()
			addMappinToOwner(gameObj, true)
		end
	end)
	ObserveAfter("ScannerNPCHeaderGameController", "OnNameChanged", function(this, value);
		if not isActivityAllowed then return end
		if not lastInteractionOwner then return end
		if not interaction.hubShown then return end
		local target = FromVariant(value)
		if not target then return end
		local newNpcName = target:GetDisplayName()
		if not isStringValid(newNpcName) then return end
		lastScannerNpcNameChanged = osClock() + 0.5
	end);
	Observe('interactionWidgetGameController', 'OnUpdateInteraction', function(this, argValue);
		if not isActivityAllowed then return end
		lastInteractionWidgetGameController = RefWeak(this)
		if not interaction.hubShown then return end
		local data = FromVariant(argValue);
		if not data.active then return end;
		interaction.hideHub()
	end);
	local n_InteractionUIBase = n"InteractionUIBase"
	ObserveAfter('dialogWidgetGameController', 'OnInteractionsChanged', function(this);
		if interaction.baseControler then return end
		if not this:IsA(n_InteractionUIBase) then return end
		interaction.baseControler = RefWeak(this)
	end);

	local function handleNcdApiPerformerAppearance(this)
		if not selectedScenePerformer.shouldUseNoCoatAppearance then this:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerAppearanceName) return end
		if questsSystem:GetFactStr("mod_hotscenes_nc_delights_prefer_original_appearance") > 0 then this:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerAppearanceName) return end
		this:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerNoCoatAppearanceName)
	end
	ObserveAfter('ScriptedPuppet', 'CreateListeners', function(this);
		if not isActivityAllowed then return end
		if not this:IsNPC() then return end;
		if not currentActiveScene then return end
		if not selectedScenePerformer.performerId then return end
		local id = this:GetTDBID();
		if id.hash < 2 then return end;
		if id ~= selectedScenePerformer.performerId then return end
		selectedScenePerformer.performer = RefWeak(this)
		thisMod.sceneState.performerEntID = this:GetEntityID()
		thisMod.sceneState.isNCDelightsScenePlaying = true
		thisMod.sceneState.lastNCDelightsSceneStartTime = osClock() + 0.01
		if selectedScenePerformer.isNcdApiCall and selectedScenePerformer.ncdApiSceneSpec then
			handleNcdApiPerformerAppearance(this)
			if not isNcdApiPlayback then return end
			if not selectedScenePerformer.isNcdApiCall then return end
			if not selectedScenePerformer.ncdApiSceneSpec then return end
			if not selectedScenePerformer.ncdApiSceneSpec then return end
			if not selectedScenePerformer.ncdApiSceneSpec.onSceneStarted then return end
			local result, data = pcall(function() selectedScenePerformer.ncdApiSceneSpec.onSceneStarted() end)
			if not result then print(modName, modVer..":", data) spdlog.error(modName.." "..modVer..":"..tostring(data)) end
			selectedScenePerformer.ncdApiSceneSpec.onSceneStarted = nil
			return
		end
		if isKnownName(selectedScenePerformer.performerAppearanceNameStr.."_no_coat") then
			if useNoCoatSubstitute[selectedScenePerformer.performerAppearanceNameStr] then
				this:ScheduleAppearanceChange(selectedScenePerformer.performerAppearanceNameStr.."_no_coat")
				return
			end
			if selectedScenePerformer.shouldUseNoCoatAppearance and questsSystem:GetFactStr("mod_hotscenes_nc_delights_prefer_original_appearance") < 1 then
				this:ScheduleAppearanceChange(selectedScenePerformer.performerAppearanceNameStr.."_no_coat")
				return
			end
		end
		this:ScheduleAppearanceChange(selectedScenePerformer.performerAppearanceNameStr)
	end);

	local function removeFishNets(this)
		if not (thisMod.userSettings.hideNpcFishnetTights or thisMod.userSettings.ncDelightsHideFishnetTights) then return end
		if not l0_004_wa_tights__fishnet then return end
		local performer = RefWeak(this)
		local timeout = osClock() + 1
		local payload = function()
			if not IsDefinedNS(performer) then return true end
			if osClock() > timeout then return true end
			if not stringMatch(performer:GetCurrentAppearanceName().value, "_naked$") then return end
			local cp = selectedScenePerformer.performer:FindComponentByName(l0_004_wa_tights__fishnet)
			if not cp then return true end
			cp.chunkMask = 0
			cp:Toggle(false)
			return true
		end
		thisMod.queueTask(payload, false, 0, 0.001, false)
	end

	local removeSpecs = function() end
	local h1_specs = thisMod.h1_specs
	if h1_specs then
		removeSpecs = function(this)
			if not thisMod.userSettings.hideNpcSpecs then return end
			local timeout = osClock() + 1
			local payload = function()
				if not IsDefinedNS(this) then return true end
				if osClock() > timeout then return true end
				if not stringMatch(this:GetCurrentAppearanceName().value, "_naked$") then return end
				for i, specs in ipairs(h1_specs) do
					local cp = this:FindComponentByName(specs)
					if cp then
						cp.chunkMask = 0
						cp:Toggle(false)
						return true
					end
				end
				return true
			end
			thisMod.queueTask(payload, false, 0, 0.001, false)
		end
	end

	local n_AppearanceVisualController = n"AppearanceVisualController"
	local n_fx_woman_base = n"fx_woman_base"
	local removeSpikedChokers = function() end
	local choker_spikes = thisMod.choker_spikes
	if choker_spikes then
		removeSpikedChokers = function(this)
			if not thisMod.userSettings.hideNpcSpikedChokers then return end
			local timeout = osClock() + 1
			local payload = function()
				if not IsDefinedNS(this) then return true end
				if osClock() > timeout then return true end
				if not stringMatch(this:GetCurrentAppearanceName().value, "_naked$") then return end
				lastInstance = RefWeak(this)
				local vs = this:FindComponentByName(n_AppearanceVisualController)
				if not vs then return true end
				local appearanceDependency = vs.appearanceDependency
				if #appearanceDependency < 1 then return true end
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
				if not cp then return true end
				cp.chunkMask = 0
				cp:Toggle(false)
				return true
			end
			thisMod.queueTask(payload, false, 0, 0.001, false)
		end
	end

	local function handleNcdApiPerformerAppearance(this)
		if questsSystem:GetFactStr("mod_hotscenes_wbr_jpn_f__ftplay_playing") < 1 and questsSystem:GetFactStr("mod_hotscenes_wbr_jpn_m__ftplay_playing") < 1 then
			selectedScenePerformer.performer:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerNudeAppearanceName)
			removeFishNets(selectedScenePerformer.performer)
			removeSpecs(selectedScenePerformer.performer)
			removeSpikedChokers(selectedScenePerformer.performer)
			return
		end
		local payload = function()
			if not thisMod.sceneState.isNCDelightsScenePlaying then return true end
			if not GetPlayer() then return true end
			if not IsDefinedNS(selectedScenePerformer.performer) then return true end
			if questsSystem:GetFactStr("wbr_sm_jpn_prostitute_female_stop_rumble") > 0 or questsSystem:GetFactStr("wbr_sm_jpn_prostitute_male_stop_rumble") > 0 then return true end
			if questsSystem:GetFactStr("wbr_jpn_female_poor_sex_clip") < 1 then return false end
			selectedScenePerformer.performer:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerNudeAppearanceName)
			removeFishNets(selectedScenePerformer.performer)
			removeSpecs(selectedScenePerformer.performer)
			removeSpikedChokers(selectedScenePerformer.performer)
			return true
		end
		thisMod.queueTask(payload, false, 1, 0.001, false)
	end
	ObserveAfter('InvisibleSceneStash', 'OnQuestUndressPlayer', function(this)
		if not thisMod.sceneState.isNCDelightsScenePlaying then return end
		if not selectedScenePerformer.performerId then return end
		if not selectedScenePerformer.performer then return end
		if not IsDefinedNS(selectedScenePerformer.performer) then
			selectedScenePerformer.performerId = nil
			selectedScenePerformer.performer = nil
			return
		end
		local player = GetPlayer()
		if player:GetSceneTier() < 4 then return end;
		if selectedScenePerformer.isNcdApiCall and selectedScenePerformer.ncdApiSceneSpec then handleNcdApiPerformerAppearance(this) return end
		if questsSystem:GetFactStr("mod_hotscenes_wbr_jpn_f__ftplay_playing") < 1 and questsSystem:GetFactStr("mod_hotscenes_wbr_jpn_m__ftplay_playing") < 1 then
			local newAppearanceNameStr = selectedScenePerformer.performerAppearanceNameStr.."_naked"
			if selectedScenePerformer.ltd then newAppearanceNameStr = newAppearanceNameStr.."_ltd" end
			selectedScenePerformer.performer:ScheduleAppearanceChange(newAppearanceNameStr)
			removeFishNets(selectedScenePerformer.performer)
			removeSpecs(selectedScenePerformer.performer)
			removeSpikedChokers(selectedScenePerformer.performer)
			return
		end
		local payload = function()
			if not thisMod.sceneState.isNCDelightsScenePlaying then return true end
			if not GetPlayer() then return true end
			if not IsDefinedNS(selectedScenePerformer.performer) then return true end
			if questsSystem:GetFactStr("wbr_sm_jpn_prostitute_female_stop_rumble") > 0 or questsSystem:GetFactStr("wbr_sm_jpn_prostitute_male_stop_rumble") > 0 then return true end
			if questsSystem:GetFactStr("wbr_jpn_female_poor_sex_clip") < 1 then return false end
			local newAppearanceNameStr = selectedScenePerformer.performerAppearanceNameStr.."_naked"
			if selectedScenePerformer.ltd then newAppearanceNameStr = newAppearanceNameStr.."_ltd" end
			selectedScenePerformer.performer:ScheduleAppearanceChange(newAppearanceNameStr)
			removeFishNets(selectedScenePerformer.performer)
			removeSpecs(selectedScenePerformer.performer)
			removeSpikedChokers(selectedScenePerformer.performer)
			return true
		end
		thisMod.queueTask(payload, false, 1, 0.001, false)
	end)
	ObserveAfter('InvisibleSceneStash', 'OnQuestDressPlayer', function(this)
		if not thisMod.sceneState.isNCDelightsScenePlaying then return end
		if not selectedScenePerformer.performerId then return end
		if not selectedScenePerformer.performer then return end
		if not IsDefinedNS(selectedScenePerformer.performer) then
			selectedScenePerformer.performerId = nil
			selectedScenePerformer.performer = nil
			return
		end
		local player = GetPlayer()
		if player:GetSceneTier() < 4 then return end;
		if selectedScenePerformer.isNcdApiCall and selectedScenePerformer.ncdApiSceneSpec then selectedScenePerformer.performer:ScheduleAppearanceChange(selectedScenePerformer.ncdApiSceneSpec.performerAppearanceName) return end
		selectedScenePerformer.performer:ScheduleAppearanceChange(selectedScenePerformer.performerAppearanceNameStr)
	end)
	ObserveBefore('gameuiWorldMapMenuGameController', 'OnInitialize', function(this)
		updateAllScenesLocationMappins(true)
	end)
	ObserveBefore('MenuScenario_Idle', 'OnOpenPauseMenu', function(this)
		updateAllScenesLocationMappins(true)
	end)
	local n_JournalNotification = n"JournalNotification"
	ObserveAfter('JournalNotification', 'SetNotificationData', function(this)
		if not this:IsA(n_JournalNotification) then return end
		updateAllScenesLocationMappins()
	end)
	local mappinProfilePoiResRef = ResRef.FromString("base\\gameplay\\gui\\widgets\\minimap\\minimap_poi_mappin.inkwidget")
	local mappinProfileShortRange = t"MappinUISpawnProfile.ShortRange"
	local mappinProfileGameplayRole = t"MinimapMappinUIProfile.GameplayRole"
	local gamedataMappinVariantServicePointProstituteVariant = gamedataMappinVariant.ServicePointProstituteVariant
	local MappinUIProfileCreate = MappinUIProfile.Create
	Override("MinimapContainerController", "CreateMappinUIProfile", function(this, mappin, mappinVariant, customData, wrappedMethod)
		local result = wrappedMethod(mappin, mappinVariant, customData)
		if not shouldShowCustomDynamicMappins then return result end
		if mappinVariant == gamedataMappinVariantServicePointProstituteVariant and result.widgetResource.resource.hash == 0 then
			return MappinUIProfileCreate(mappinProfilePoiResRef, mappinProfileShortRange, mappinProfileGameplayRole)
		end
		return result
	end)
end

------------------------------------------------------------------------------------------
ncdApi.getSupportedFeatureNames = function(verbose)
	if thisMod.isModDisabled then return end
	local output1, output2 = {}, {}
	for i = 1, #supportedLocations do
		local supportedLocation = supportedLocations[i]
		if supportedLocation.isSupportedInNcdApi and isStringValid(supportedLocation.keyName) and type(supportedLocation.isUnlockedInNcdApi) == 'function' then
			local names = {keyName = supportedLocation.keyName}
			if isStringValid(supportedLocation.altFeatureName) then
				names.altFeatureName = supportedLocation.altFeatureName
			end
			if verbose then print(i, "keyName:", supportedLocation.keyName, "\talternativeSceneName:", supportedLocation.altFeatureName) end
			tableInsert(output1, names.keyName)
			tableInsert(output2, names)
		end
	end
	return output1, output2
end
local function checkPersistentState()
	if thisMod.getIsMainModDisabled() then return false, getResultByKeyName("isModDisabled") end
	if not isArchiveXLActive then return false, getResultByKeyName("archive_xl_missing") end
	if thisMod.isModuleDisabled then return false, getResultByKeyName("nc_delights_is_disabled") end
	return true, getResultByKeyName("ok")
end
local function checkRuntimeState()
	if not GetPlayer then return false, getResultByKeyName("game_framework_not_available") end
	if not thisMod.isInitialized then return false, getResultByKeyName("nc_delights_not_initialized") end
	if not thisMod.getIsMainModInitialized() then return false, getResultByKeyName("main_mod_not_initialized") end
	if not GetPlayer() then return false, getResultByKeyName("player_not_found") end
	if thisMod.getIsPreGame() then return false, getResultByKeyName("player_not_in_game_session") end
	if thisMod.isAnyGamePausingScreen() then return false, getResultByKeyName("game_paused_or_in_menu") end
	if isNudityCensored then return false, getResultByKeyName("is_censored") end
	return true, getResultByKeyName("ok")
end
local function checkResourcesState()
	if not thisMod.getIsMainArchiveDetected() then return false, getResultByKeyName("main_archive_not_detected") end
	if not thisMod.getIsOverrideArchiveDetected() then return false, getResultByKeyName("add_on_archive_not_detected") end
	if thisMod.getIsUnsupportedOverrideArchiveDetected() then return false, getResultByKeyName("unsupported_add_on") end
	if not isKnownName("mod_hotscenes_custom_trigger_quest_available") then return false, getResultByKeyName("custom_trigger_quest_not_detected") end
	if questsSystem:GetFactStr("mod_hotscenes_custom_trigger_quest_active") < 1 then return false, getResultByKeyName("custom_trigger_quest_not_active") end
	if not isNCDelightsLauncherActivated() then return false, getResultByKeyName("ncd_trigger_quest_not_active") end
	return true, getResultByKeyName("ok")
end
local function checkGameplayState()
	if isAnyHotscenePlaying() then return false, getResultByKeyName("is_any_hotscene_playing") end
	local result, exitDesc = thisMod.isHotscenesAllowed() if not result then return false, getResultByKeyName(exitDesc) end
	if (isPrologueOrWarmupActive() or isEndingActive()) then return false, getResultByKeyName("is_prologue_or_ending") end
	if GetPlayer():IsCooldownActive(hotscenes_mod_freeze_selected_scene_cooldown_cname) then return false, getResultByKeyName("isHangoutsScene") end
	return true, getResultByKeyName("ok")
end
local function isScenePlaybackAvailable()
	local result, exitCode, exitDesc = checkPersistentState() if not result then return result, exitCode, exitDesc end
	result, exitCode, exitDesc = checkRuntimeState() if not result then return result, exitCode, exitDesc end
	result, exitCode, exitDesc = checkResourcesState() if not result then return result, exitCode, exitDesc end
	result, exitCode, exitDesc = checkGameplayState() if not result then return result, exitCode, exitDesc end
	return true, getResultByKeyName("ok")
end
local function getFeature(featureName, quick)
	if not isStringValid(featureName) then return false, getResultByKeyName("feature_name_string_invalid") end
	local feature = ncdApiFeatures[stringLower(featureName)]
	if not feature then return false, getResultByKeyName("feature_not_found") end
	if quick then return feature, getResultByKeyName("ok") end
	local result, exitCode, exitDesc = isScenePlaybackAvailable() if not result then return result, exitCode, exitDesc end
	if not feature.isSceneWorldDataAvailable() then return false, getResultByKeyName("feature_not_loaded") end
	if not feature.isUnlockedInNcdApi() then return false, getResultByKeyName("feature_locked") end
	return feature, getResultByKeyName("ok")
end
ncdApi.isSceneAvaliable = function(featureName)
	local result, exitCode, exitDesc = getFeature(featureName)
	return type(result) == 'table', exitCode, exitDesc
end
ncdApi.playScene = function(featureName, ncdApiSceneSpec, delay, verbose)
	local feature, exitCode, exitDesc = getFeature(featureName, true)
	if not feature then return false, exitCode, exitDesc end
	if type(ncdApiSceneSpec) ~= 'table' then return false, getResultByKeyName("scene_spec_invalid") end
	if not isStringValid(ncdApiSceneSpec.performerGender) then return false, getResultByKeyName("gender_name_string_invalid") end
	local performerGender = stringLower(ncdApiSceneSpec.performerGender)
	local isFemale
	if performerGender == "female" then performerGender = "Female" isFemale = true elseif performerGender == "male" then performerGender = "Male" else return false, getResultByKeyName("gender_name_string_invalid") end
	local performerEntPath = ncdApiSceneSpec.performerEntPath
	if not performerEntPath then return false, getResultByKeyName("performer_ent_path_invalid") end
	if type(performerEntPath) == 'string' and stringLen(performerEntPath) > 4 and stringMatch(performerEntPath, '%.ent$') then
		performerEntPath = ResRef.FromString(performerEntPath).resource
	elseif (type(performerEntPath) == 'cdata' and stringMatch(tostring(performerEntPath), "ULL$") and type(tonumber(performerEntPath)) == 'number' and performerEntPath > 1ULL) then
		performerEntPath = ResRef.FromHash(performerEntPath).resource
	else return false, getResultByKeyName("performer_ent_path_invalid") end
	if not isStringValid(ncdApiSceneSpec.performerAppearanceName) then return false, getResultByKeyName("appearance_name_string_invalid") end
	local performerAppearanceName = ncdApiSceneSpec.performerAppearanceName
	if not isStringValid(ncdApiSceneSpec.performerNudeAppearanceName) then return false, getResultByKeyName("nude_appearance_name_string_invalid") end
	local performerNudeAppearanceName = ncdApiSceneSpec.performerNudeAppearanceName
	local performerNoCoatAppearanceName = performerAppearanceName
	if isStringValid(ncdApiSceneSpec.performerNoCoatAppearanceName) then performerNoCoatAppearanceName = ncdApiSceneSpec.performerNoCoatAppearanceName end
	local allowLeadIns = false
	if type(ncdApiSceneSpec.allowLeadIns) == 'boolean' then allowLeadIns = ncdApiSceneSpec.allowLeadIns end
	local allowLeadInsGroping = false
	if allowLeadIns and type(ncdApiSceneSpec.allowLeadInsGroping) == 'boolean' then allowLeadInsGroping = ncdApiSceneSpec.allowLeadInsGroping end
	local canUseSlimLegAnimations = false
	if type(ncdApiSceneSpec.canUseSlimLegAnimations) == 'boolean' then canUseSlimLegAnimations = ncdApiSceneSpec.canUseSlimLegAnimations end
	local onSceneStarted
	if type(ncdApiSceneSpec.onSceneStarted) == 'function' then onSceneStarted = ncdApiSceneSpec.onSceneStarted end
	local onSceneCompleted
	if type(ncdApiSceneSpec.onSceneCompleted) == 'function' then onSceneCompleted = ncdApiSceneSpec.onSceneCompleted end
	if verbose then
		print(" featureName:", tostring(ncdApiSceneSpec.featureName), "\n",
		"performerGender:", tostring(ncdApiSceneSpec.performerGender), "\n",
		"performerEntPath:", tostring(ncdApiSceneSpec.performerEntPath), "\n",
		"performerAppearanceName:", tostring(ncdApiSceneSpec.performerAppearanceName), "\n",
		"performerNudeAppearanceName:", tostring(ncdApiSceneSpec.performerNudeAppearanceName), "\n",
		"performerNoCoatAppearanceName:", tostring(ncdApiSceneSpec.performerNoCoatAppearanceName), "\n",
		"canUseSlimLegAnimations:", tostring(ncdApiSceneSpec.canUseSlimLegAnimations), "\n",
		"allowLeadIns:", tostring(ncdApiSceneSpec.allowLeadIns), "\n",
		"allowLeadInsGroping:", tostring(ncdApiSceneSpec.allowLeadInsGroping), "\n",
		"onSceneStarted:", tostring(ncdApiSceneSpec.onSceneStarted), "\n",
		"onSceneCompleted:", tostring(ncdApiSceneSpec.onSceneCompleted), "\n",
		"delay:", tostring(delay)
		)
	end
	local result, exitCode, exitDesc = isScenePlaybackAvailable() if not result then return result, exitCode, exitDesc end
	if not feature.isSceneWorldDataAvailable() then return false, getResultByKeyName("feature_not_loaded") end
	if not feature.isUnlockedInNcdApi() then return false, getResultByKeyName("feature_locked") end
	local newNcdApiSceneSetupData = {
		performerGender = performerGender,
		performerEntPath = performerEntPath,
		performerAppearanceName = performerAppearanceName,
		performerNoCoatAppearanceName = performerNoCoatAppearanceName,
		performerNudeAppearanceName = performerNudeAppearanceName,
		allowLeadIns = allowLeadIns,
		allowLeadInsGroping = allowLeadInsGroping,
		enableSceneSupport = canUseSlimLegAnimations,
		onSceneStarted = onSceneStarted,
		onSceneCompleted = onSceneCompleted
	}
	local launchScene
	local selectedScene = feature
	isNcdApiPlayback = false
	selectedScenePerformer.isNcdApiCall = nil
	selectedScenePerformer.ncdApiSceneSpec = nil
	selectedScenePerformer.ltd = nil
	questsSystem:SetFactStr("mod_hotscenes_requesting_custom_location_playback", 0);
	if isFemale then
		selectedScenePerformer.isFemale = true
		selectedScenePerformer.performerGender = "Female"
		if type(selectedScene.getFemalePerformerIdStr) == 'function' then selectedScenePerformer.performerIdStr = selectedScene.getFemalePerformerIdStr() else selectedScenePerformer.performerIdStr = selectedScene.femalePerformerIdStr end
		selectedScenePerformer.performerId = t(selectedScenePerformer.performerIdStr)
		selectedScenePerformer.shouldUseNoCoatAppearance = selectedScene.isJapantownFemaleScene
		launchScene = function() isNcdApiPlayback = true selectedScene.startFemaleScene(false, false, true, newNcdApiSceneSetupData) end
	else
		selectedScenePerformer.isFemale = false
		selectedScenePerformer.performerGender = "Male"
		if type(selectedScene.getMalePerformerIdStr) == 'function' then selectedScenePerformer.performerIdStr = selectedScene.getMalePerformerIdStr() else selectedScenePerformer.performerIdStr = selectedScene.malePerformerIdStr end
		selectedScenePerformer.performerId = t(selectedScenePerformer.performerIdStr)
		launchScene = function() isNcdApiPlayback = true selectedScene.startMaleScene(false, false, true, newNcdApiSceneSetupData) end
	end
	if not launchScene then return false, getResultByKeyName("api_scene_launch_failed") end
	selectedScenePerformer.isNcdApiCall = true
	selectedScenePerformer.ncdApiSceneSpec = newNcdApiSceneSetupData
	local cooldown = 10
	if type(delay) == 'number' and delay > 0 then cooldown = math.max(cooldown, delay) + 1 else delay = nil end
	GetPlayer():StartCooldown(hotscenes_mod_nc_delights_scene_playback_start_cooldown_cname, cooldown)
	if delay then thisMod.queueTask(launchScene, false, delay) return selectedScenePerformer, getResultByKeyName("ok") end
	launchScene()
	return selectedScenePerformer, getResultByKeyName("ok")
end

return {modName = modName, modVer = modVer, modAuthorName = modAuthorName, mod = thisMod}
