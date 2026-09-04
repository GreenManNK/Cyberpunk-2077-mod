local MARMUR_ZERO_ENGINE_READY_FACT = "marmur_bank_zero_engine_ready"
local MARMUR_ZERO_ENGINE_MOD_NAME = "MarmurBank"
local marmurZeroEngineMod = nil
local marmurZeroEngineRuntimeReady = false
local marmurRuntimeTick = nil
local marmurReadyFactSyncElapsed = 0
local MARMUR_READY_FACT_SYNC_INTERVAL = 0.50

local function setMarmurZeroEngineReadyFact(value)
	if not Game or not Game.GetQuestsSystem then return end
	local ok, qs = pcall(function() return Game.GetQuestsSystem() end)
	if not ok or qs == nil then return end
	local safe = math.floor(tonumber(value) or 0)
	local readOk, current = pcall(function()
		return qs:GetFactStr(MARMUR_ZERO_ENGINE_READY_FACT)
	end)
	if readOk and math.floor(tonumber(current) or 0) == safe then return end
	pcall(function() qs:SetFactStr(MARMUR_ZERO_ENGINE_READY_FACT, safe) end)
end

local function acquireMarmurZeroEngine()
	if type(GetMod) ~= "function" then return nil end
	local ok, engine = pcall(GetMod, "0-Engine")
	if not ok or type(engine) ~= "table" or type(engine.Register) ~= "function" then
		return nil
	end
	local modOk, mod = pcall(function() return engine.Register(MARMUR_ZERO_ENGINE_MOD_NAME) end)
	if not modOk or type(mod) ~= "table" or type(mod.SetInterval) ~= "function" then
		return nil
	end
	return mod
end

local GameSettings = require("external/GameSettings")
local GameUI = require("external/GameUI")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")

local MARMUR_RUNTIME_INTERVAL = 0.05

local function registerZeroEngineInterval(modName, interval, callback)
	if marmurZeroEngineRuntimeReady then return true end

	if type(marmurZeroEngineMod) ~= "table" or type(marmurZeroEngineMod.SetInterval) ~= "function" then
		marmurZeroEngineMod = acquireMarmurZeroEngine()
	end

	local registered = false

	if type(marmurZeroEngineMod) == "table" and type(marmurZeroEngineMod.SetInterval) == "function" then
		registered = pcall(function()
			marmurZeroEngineMod.SetInterval(interval, function()
				marmurReadyFactSyncElapsed = marmurReadyFactSyncElapsed + interval
				if marmurReadyFactSyncElapsed >= MARMUR_READY_FACT_SYNC_INTERVAL then
					marmurReadyFactSyncElapsed = 0
					setMarmurZeroEngineReadyFact(1)
				end
				callback(interval)
			end)
		end) == true
	end

	if not registered then
		marmurZeroEngineRuntimeReady = false
		setMarmurZeroEngineReadyFact(0)
		print("[Marmur Bank] 0-Engine unavailable; runtime scheduler disabled.")
	else
		marmurZeroEngineRuntimeReady = true
		marmurReadyFactSyncElapsed = 0
		setMarmurZeroEngineReadyFact(1)
	end

	return registered
end

local function ensureMarmurZeroEngineRuntime()
	if marmurZeroEngineRuntimeReady then
		setMarmurZeroEngineReadyFact(1)
		return true
	end
	if type(marmurRuntimeTick) ~= "function" then
		setMarmurZeroEngineReadyFact(0)
		return false
	end

	return registerZeroEngineInterval(MARMUR_ZERO_ENGINE_MOD_NAME, MARMUR_RUNTIME_INTERVAL, marmurRuntimeTick)
end

local SPAWN = require("module/Spawn")
local BANK = require("module/Bank")
local BrowserTab = require("module/BrowserTab")

local PosData = require("data/PosData")
local NpcData = require("data/NpcData")

local isGameplayActive = false
local isInMenu = false
local lastLocale = ""
local currentTime = 0
local nextCheckTime = 0
local MARMUR_UPDATE_DELTA_MAX = 1.00
local nextSpawnTimerUpdateTime = 0
local johnnySuppressed = false
local johnnySuppressionNextPollTime = 0
local storySuppressionReleaseUntil = 0
local JOHNNY_SUPPRESSION_IDLE_INTERVAL = 0.25
local JOHNNY_SUPPRESSION_ACTIVE_INTERVAL = 0.20
local STORY_SUPPRESSION_RELEASE_GRACE = 2.0
local JOHNNY_QUEST_ENTRY_PROBES = { "GetId", "GetID", "GetPath", "GetQuestPath", "GetEntryName" }

local JOHNNY_FLASHBACK_QUEST_IDS = {
	"q101_01_firestorm",
	"q101_firestorm",
	"love_like_fire",
	"q108",
	"q108_johnny",
	"never_fade_away",
	"never_fade",
}

local MONK_MEDITATION_QUEST_IDS = {
	"mq014_zen",
	"mq014_02_second",
	"mq014_03_third",
	"mq014_04_fourth",
}

local function getQuestFact(questsSystem, factName)
	local value = 0
	if questsSystem == nil or factName == nil then return 0 end
	pcall(function() value = tonumber(questsSystem:GetFactStr(factName)) or 0 end)
	return value
end

local function containsQuestId(value, questIds)
	local text = string.lower(tostring(value or ""))
	for _, questId in ipairs(questIds or {}) do
		if string.find(text, questId, 1, true) then
			return true
		end
	end
	return false
end

local function queryTrackedQuest(questIds)
	local active = false
	pcall(function()
		local journal = Game.GetJournalManager()
		if journal == nil then return end

		local entry = journal:GetTrackedEntry()
		local depth = 0
		while entry ~= nil and depth < 8 do
			if containsQuestId(entry, questIds) then active = true return end

			for _, methodName in ipairs(JOHNNY_QUEST_ENTRY_PROBES) do
				local ok, result = pcall(function() return entry[methodName](entry) end)
				if ok and containsQuestId(result, questIds) then active = true return end
			end

			local okParent, parent = pcall(function() return journal:GetParentEntry(entry) end)
			if not okParent or parent == nil or parent == entry then break end
			entry = parent
			depth = depth + 1
		end
	end)
	return active
end

local function queryTrackedJohnnyQuest()
	return queryTrackedQuest(JOHNNY_FLASHBACK_QUEST_IDS)
end

local function queryTrackedMonkMeditation()
	return queryTrackedQuest(MONK_MEDITATION_QUEST_IDS)
end

local function callStoryBoolMethod(target, methodName)
	if target == nil or methodName == nil then return false end
	local okMethod, method = pcall(function() return target[methodName] end)
	if not okMethod or type(method) ~= "function" then return false end
	local okValue, value = pcall(function() return method(target) end)
	return okValue and value == true
end

local function queryBraindanceSuppression()
	local active = false
	pcall(function()
		local defs = Game.GetAllBlackboardDefs()
		if defs == nil or defs.Braindance == nil or defs.Braindance.IsActive == nil then return end
		local board = Game.GetBlackboardSystem():Get(defs.Braindance)
		active = board ~= nil and board:GetBool(defs.Braindance.IsActive) == true
	end)
	if active then return true end

	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then return false end
	for _, methodName in ipairs({
		"IsBraindanceActive",
		"IsInBraindance",
		"IsInBraindanceEditor",
		"IsInBraindancePlayback"
	}) do
		if callStoryBoolMethod(player, methodName) then return true end
	end
	return false
end

local function queryStorySceneActive()
	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then return false end

	for _, methodName in ipairs({
		"IsInWorkspot",
		"IsAttachedToWorkspot",
		"IsInScene",
		"IsPlayingScene",
		"IsInNonInteractiveScene",
		"IsInCutscene",
		"IsInCinematic"
	}) do
		if callStoryBoolMethod(player, methodName) then return true end
	end

	local active = false
	pcall(function()
		local defs = Game.GetAllBlackboardDefs()
		local board = player:GetPlayerStateMachineBlackboard()
		active = defs ~= nil and defs.PlayerStateMachine ~= nil
			and defs.PlayerStateMachine.SceneTier ~= nil and board ~= nil
			and (tonumber(board:GetInt(defs.PlayerStateMachine.SceneTier)) or 0) >= 3
	end)
	return active
end

local function queryQuestFactJohnnySuppression()
	local active = false
	pcall(function()
		local qs = Game.GetQuestsSystem()
		if qs == nil then return end

		active =
			getQuestFact(qs, "q101_01_firestorm_active") > 0 or
			getQuestFact(qs, "q101_01_firestorm_in_progress") > 0 or
			getQuestFact(qs, "q108_active") > 0 or
			getQuestFact(qs, "q108_in_progress") > 0
	end)
	return active
end

local function queryJohnnySuppression()
	local active = queryBraindanceSuppression()

	if not active then
		active = queryTrackedMonkMeditation() and queryStorySceneActive()
	end

	if not active then
		active = queryTrackedJohnnyQuest() or queryQuestFactJohnnySuppression()
	end

	if not active then
		pcall(function()
			active = GameUI.IsJohnny() == true
		end)
	end

	if not active then
		pcall(function()
			local player = Game.GetPlayer()
			active = player ~= nil and player:IsJohnnyReplacer() == true
		end)
	end

	if not active then
		pcall(function()
			local playerSystem = Game.GetPlayerSystem()
			local questsSystem = Game.GetQuestsSystem()
			active = playerSystem ~= nil and questsSystem ~= nil
				and questsSystem:GetFactStr(playerSystem:GetPossessedByJohnnyFactName()) == 1
		end)
	end

	return active
end

local function syncJohnnySuppression(force)
	local now = os.clock()

	if force ~= true and now > 0 and now < (johnnySuppressionNextPollTime or 0) then
		return johnnySuppressed
	end

	local active = queryJohnnySuppression()
	if active then
		storySuppressionReleaseUntil = now + STORY_SUPPRESSION_RELEASE_GRACE
	elseif now > 0 and now < (storySuppressionReleaseUntil or 0) then
		active = true
	end
	if now > 0 then
		johnnySuppressionNextPollTime = now + (active and JOHNNY_SUPPRESSION_ACTIVE_INTERVAL or JOHNNY_SUPPRESSION_IDLE_INTERVAL)
	end

	if force ~= true and active == johnnySuppressed then
		return active
	end

	johnnySuppressed = active

	if BANK and BANK.setJohnnySuppressed then
		BANK:setJohnnySuppressed(active)
	end

	if BrowserTab and BrowserTab.setSuppressed then
		BrowserTab.setSuppressed(active)
	end

	if active then
		pcall(function() BANK:hideHub() end)
		pcall(function() SPAWN:hideHub(true) end)
	end

	return active
end


local function isMarmurAtmKeybindRuntimeAllowed()
	if syncJohnnySuppression(false) then
		return false
	end

	if isInMenu or not isGameplayActive then
		return false
	end

	if not SPAWN or not SPAWN.isInitialized then
		return false
	end

	if not BANK or not BANK.isInitialized then
		return false
	end

	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then
		return false
	end

	local blocked = false

	pcall(function()
		if Game.GetMountedVehicle(player) then
			blocked = true
		end
	end)

	pcall(function()
		if LiftDevice and LiftDevice.IsPlayerInsideElevator and LiftDevice.IsPlayerInsideElevator() then
			blocked = true
		end
	end)

	pcall(function()
		local state = player:GetCurrentCombatState()
		if state ~= nil and state.value == "InCombat" then
			blocked = true
		end
	end)

	return blocked ~= true
end

local function handleMarmurAtmKeybind()
	if not marmurZeroEngineRuntimeReady then
		return
	end

	if not isMarmurAtmKeybindRuntimeAllowed() then
		return
	end

	if BANK and BANK.openAtmKeypadFromKeybind then
		pcall(function()
			BANK:openAtmKeypadFromKeybind()
		end)
	end
end

local marmurAtmKeybindRegistered = false
local function registerMarmurAtmKeybind()
	if marmurAtmKeybindRegistered then
		return
	end

	local registered = false

	if type(registerInput) == "function" then
		local ok = pcall(function()
			registerInput("marmur_atm_keypad", "Marmur ATM", function(pressed)
				if pressed == true or pressed == 1 then
					handleMarmurAtmKeybind()
				end
			end)
		end)
		registered = ok == true
	end

	if not registered and type(registerHotkey) == "function" then
		local ok = pcall(function()
			registerHotkey("marmur_atm_keypad", "Marmur ATM", function()
				handleMarmurAtmKeybind()
			end)
		end)
		registered = ok == true
	end

	marmurAtmKeybindRegistered = registered == true
end

registerMarmurAtmKeybind()

local ATM_DISTANCE_DEFAULT = 1.65
local ATM_DISTANCE_OLD_DEFAULT = 1.95
local ATM_DISTANCE_PREVIOUS_DEFAULT = 1.80
local ATM_DISTANCE_MIN = 1.50
local ATM_DISTANCE_MAX = 2.5
local ATM_MAP_PIN_MATCH_DISTANCE = 5.0

local settings = {
	tranAmount = 2,
	interestRate = 0.01,
	termOfIncome = 2,
	atmDistance = ATM_DISTANCE_DEFAULT,
	atmFontSize = 65,
	npcBanker = 1,
}

registerForEvent("onInit", function()
	ensureMarmurZeroEngineRuntime()

	math.randomseed(os.clock())
	registerMarmurAtmKeybind()

	Util.addToMapPin(
		"Mappins.PointOfInterest_ServicePointJunkVariant",
		"service"
	)

	ObserveAfter("WorldMapTooltipController", "SetData", function (this, data)
		if not IsDefined(this) then
			return
		end

		local okTitle, titleText = pcall(function() return this.titleText:GetText() end)
		local okDesc, descText = pcall(function() return this.descText:GetText() end)
		local title = okTitle and tostring(titleText) or ""
		local desc = okDesc and tostring(descText) or ""
		local variant = ""
		local displayName = ""

		if data ~= nil and data.mappin ~= nil then
			local okVariant, variantValue = pcall(function() return data.mappin:GetVariant() end)
			if okVariant and variantValue ~= nil then
				variant = tostring(variantValue)
			end

			local okDisplayName, displayNameValue = pcall(function() return data.mappin:GetDisplayName() end)
			if okDisplayName and displayNameValue ~= nil then
				displayName = tostring(displayNameValue)
			end
		end

		if string.find(displayName, "TSU_MarmurBank|", 1, true) == 1 then
			return
		end

		if title == GetLocalizedText("LocKey#35133") then
			this.titleText:SetText(Lang.getText("pin_bank_estate_text"))
			this.descText:SetText(Lang.getText("pin_bank_estate_desc"))
			return
		end

		local isDropPointVariant = string.find(variant, "ServicePointJunkVariant", 1, true) ~= nil
		local isDropPointTitle = title == "Drop Point"
		local isVanillaDropPointDesc = desc == "Used for selling and depositing items."
		local isAlreadyPatchedDesc = desc == Lang.getText("pin_bank_droppoint_desc")
		local isDropPoint = isDropPointVariant or (isDropPointTitle and (isVanillaDropPointDesc or isAlreadyPatchedDesc))
		local isAtmCompatible = false

		if isDropPoint and data ~= nil and data.mappin ~= nil and BANK ~= nil and type(BANK.isAtmMapPosition) == "function" then
			local okPosition, mapPosition = pcall(function() return data.mappin:GetWorldPosition() end)
			if okPosition and mapPosition ~= nil then
				local okCompatible, compatible = pcall(function()
					return BANK:isAtmMapPosition(mapPosition, ATM_MAP_PIN_MATCH_DISTANCE)
				end)
				isAtmCompatible = okCompatible and compatible == true
			end
		end

		if isDropPoint and isAtmCompatible then
			this.descText:SetText(Lang.getText("pin_bank_droppoint_desc"))
		end
	end)


	lastLocale =
		NameToString(GameSettings.Get("/language/OnScreen"))
	loadSettings()
	setupMenu()

	if SPAWN then
		SPAWN:initialize()
	end

	if BANK then
		BANK:initialize(SPAWN)
	end

	local walletReconcileQueuedUntil = 0
	local function scheduleMarmurWalletReconcile(source)
		if not BANK or not BANK.updateWalletSpendMonitor then return end
		local now = os.clock()
		if now < walletReconcileQueuedUntil then return end
		walletReconcileQueuedUntil = now + 0.75
		local function runReconcile()
			pcall(function()
				if BANK.processVanguardAnalyticsEvents then BANK:processVanguardAnalyticsEvents(true) end
				BANK:updateWalletSpendMonitor(true)
				if BANK._flushPendingWalletSpend then BANK:_flushPendingWalletSpend(false) end
			end)
		end
		pcall(function() Cron.After(0.06, runReconcile) end)
		pcall(function() Cron.After(0.70, runReconcile) end)
	end

	local function isPlayerMoneyRemoval(owner, itemID, quantity)
		if math.floor(tonumber(quantity) or 0) <= 0 then return false end
		local recordName = ""
		pcall(function()
			if itemID and itemID.tdbid and itemID.tdbid.value then
				recordName = tostring(itemID.tdbid.value)
			elseif itemID and itemID.id and itemID.id.value then
				recordName = tostring(itemID.id.value)
			elseif itemID and itemID.value then
				recordName = tostring(itemID.value)
			end
		end)
		if recordName ~= "Items.money" then return false end

		local player = nil
		pcall(function() player = Game.GetPlayer() end)
		if not player or not owner then return false end

		local sameOwner = false
		pcall(function() sameOwner = owner == player end)
		if sameOwner ~= true then
			pcall(function()
				sameOwner = tostring(owner:GetEntityID()) == tostring(player:GetEntityID())
			end)
		end
		return sameOwner == true
	end

	local pendingVendingCandidates = {}

	local function pruneVendingCandidates()
		local now = os.clock()
		for index = #pendingVendingCandidates, 1, -1 do
			if now > (tonumber(pendingVendingCandidates[index].expiresAt) or 0) then
				table.remove(pendingVendingCandidates, index)
			end
		end
	end

	local function consumeVendingCandidate(settlementMode, targetOwner)
		pruneVendingCandidates()
		if #pendingVendingCandidates <= 0 then return nil end
		local targetEntityId = ""
		pcall(function() targetEntityId = tostring(targetOwner:GetEntityID()) end)
		for index = 1, #pendingVendingCandidates do
			local candidate = pendingVendingCandidates[index]
			local modeMatches = candidate.settlementMode == settlementMode
			local ownerMatches = settlementMode ~= "transfer" or targetEntityId == "" or candidate.vendorEntityId == "" or candidate.vendorEntityId == targetEntityId
			if modeMatches and ownerMatches then
				table.remove(pendingVendingCandidates, index)
				return candidate
			end
		end
		return nil
	end

	local function recordVendingDebit(quantity, settlementMode, targetOwner)
		if #pendingVendingCandidates <= 0 then return end
		local candidate = consumeVendingCandidate(settlementMode, targetOwner)
		if not candidate or not BANK or not BANK.recordCategorizedWalletSpend then return end
		pcall(function()
			BANK:recordCategorizedWalletSpend(candidate.subject or "other", math.floor(tonumber(quantity) or 0), candidate.source or "vending_purchase", "item")
		end)
	end

	local function observeWalletMutation(className, methodName)
		pcall(function()
			ObserveAfter(className, methodName, function(_, owner, itemID, quantity, ...)
				local source = tostring(className) .. "." .. tostring(methodName)
				local playerMoney = isPlayerMoneyRemoval(owner, itemID, quantity)
				if playerMoney and BANK and BANK.notePlayerMoneyRemoval then
					BANK:notePlayerMoneyRemoval(quantity, source)
					recordVendingDebit(quantity, "remove", nil)
					scheduleMarmurWalletReconcile(source)
				end
			end)
		end)
	end

	observeWalletMutation('TransactionSystem', 'RemoveItem')
	observeWalletMutation('TransactionSystem', 'RemoveItemByTDBID')
	pcall(function()
		ObserveAfter('TransactionSystem', 'TransferItem', function(_, sourceOwner, targetOwner, itemID, quantity, ...)
			if #pendingVendingCandidates <= 0 then return end
			pruneVendingCandidates()
			if #pendingVendingCandidates <= 0 then return end
			if isPlayerMoneyRemoval(sourceOwner, itemID, quantity) ~= true then return end
			recordVendingDebit(quantity, "transfer", targetOwner)
		end)
	end)

	local purchaseSubjectCache = {}
	local pendingVendorRequests = {}

	local function enumText(value)
		if value == nil then return "" end
		local text = tostring(value)
		pcall(function()
			if value.value ~= nil then text = tostring(value.value) end
		end)
		return string.lower(text)
	end

	local function purchasedItemSubject(itemID)
		if itemID == nil then return nil end
		local tdbid = nil
		pcall(function()
			if itemID.tdbid ~= nil then
				tdbid = itemID.tdbid
			elseif itemID.id ~= nil then
				tdbid = itemID.id
			elseif itemID.GetTDBID then
				tdbid = itemID:GetTDBID()
			end
		end)
		if tdbid == nil then return nil end
		local cacheKey = enumText(tdbid)
		if purchaseSubjectCache[cacheKey] ~= nil then return purchaseSubjectCache[cacheKey] end

		local record = nil
		pcall(function() record = TweakDBInterface.GetItemRecord(tdbid) end)
		if record == nil then return nil end
		local itemType = ""
		local itemCategory = ""
		local tagText = ""
		pcall(function() itemType = enumText(record:ItemType():Type()) end)
		pcall(function() itemCategory = enumText(record:ItemCategory():Type()) end)
		pcall(function()
			for _, tag in ipairs(record:Tags() or {}) do
				tagText = tagText .. "|" .. enumText(tag)
			end
		end)

		local subject = "other"
		if string.find(itemCategory, "cyberware", 1, true) or string.find(itemType, "cyb_", 1, true) or string.find(tagText, "cyberware", 1, true) then
			subject = "cyberware"
		elseif string.find(itemCategory, "clothing", 1, true) or string.find(itemType, "clo_", 1, true) then
			subject = "clothing"
		elseif string.find(itemType, "con_inhaler", 1, true) or string.find(itemType, "con_injector", 1, true)
			or string.find(itemType, "con_longlasting", 1, true) or string.find(tagText, "medical", 1, true)
			or string.find(tagText, "healing", 1, true) then
			subject = "medical"
		elseif string.find(itemType, "con_edible", 1, true)
			or string.find(tagText, "food", 1, true) or string.find(tagText, "drink", 1, true)
			or string.find(tagText, "alcohol", 1, true) or string.find(tagText, "coffee", 1, true)
			or string.find(tagText, "nutrition", 1, true) or string.find(tagText, "hydration", 1, true) then
			subject = "food_drinks"
		elseif string.find(itemType, "prt_program", 1, true) or string.find(itemType, "con_skillbook", 1, true)
			or string.find(tagText, "quickhack", 1, true) or string.find(tagText, "program", 1, true) then
			subject = "software"
		elseif string.find(itemType, "gen_craftingmaterial", 1, true) or string.find(itemType, "prt_fragment", 1, true)
			or string.find(tagText, "crafting", 1, true) or string.find(tagText, "material", 1, true) then
			subject = "crafting"
		elseif string.find(itemCategory, "weapon", 1, true) or string.find(itemType, "wea_", 1, true)
			or string.find(itemType, "con_ammo", 1, true) or string.find(itemType, "gad_grenade", 1, true)
			or string.find(itemType, "prt_", 1, true) or string.find(tagText, "weapon", 1, true) then
			subject = "weapons_ammo"
		elseif string.find(itemType, "gen_readable", 1, true) or string.find(tagText, "braindance", 1, true)
			or string.find(tagText, "entertainment", 1, true) or string.find(tagText, "media", 1, true) then
			subject = "entertainment"
		end
		purchaseSubjectCache[cacheKey] = subject
		return subject
	end

	local function queueVendingCandidate(evt, source, lifetime, rejectFree, vendorOwner, settlementMode)
		local itemID = nil
		local isFree = false
		pcall(function()
			if evt and evt.GetItemID then itemID = evt:GetItemID() end
			if itemID == nil and evt then itemID = evt.itemID end
			if evt then isFree = evt.isFree == true end
		end)
		if rejectFree == true and isFree == true then return 0 end
		local vendorEntityId = ""
		pcall(function() vendorEntityId = tostring(vendorOwner:GetEntityID()) end)
		local itemKey = enumText(itemID)
		pruneVendingCandidates()
		local now = os.clock()
		if settlementMode == "remove" then
			for _, existing in ipairs(pendingVendingCandidates) do
				if existing.settlementMode == "remove" and existing.vendorEntityId == vendorEntityId
					and existing.itemKey == itemKey and now - (tonumber(existing.createdAt) or 0) <= 0.10 then
					return true
				end
			end
		end
		table.insert(pendingVendingCandidates, {
			subject = purchasedItemSubject(itemID) or "other",
			source = source,
			settlementMode = settlementMode,
			vendorEntityId = vendorEntityId,
			itemKey = itemKey,
			createdAt = now,
			expiresAt = now + (tonumber(lifetime) or 4.0),
		})
		while #pendingVendingCandidates > 8 do table.remove(pendingVendingCandidates, 1) end
		return true
	end

	local function observePaidVendingMachineClass(className)
		pcall(function()
			ObserveBefore(className, 'OnVendingMachineFinishedEvent', function(owner, evt)
				queueVendingCandidate(evt, string.lower(className) .. "_purchase", 1.5, true, owner, "remove")
			end)
		end)
	end
	observePaidVendingMachineClass('VendingMachine')
	observePaidVendingMachineClass('IceMachine')
	pcall(function()
		ObserveBefore('VendingTerminal', 'OnBuyItemFromVendor', function(owner, evt)
			queueVendingCandidate(evt, "vending_terminal_purchase", 4.0, false, owner, "transfer")
		end)
	end)

	local function subjectFromPurchaseEvent(evt)
		local resolved = nil
		local conflict = false
		local itemCount = 0
		local ids = nil
		pcall(function() ids = evt and evt.itemsID or nil end)
		if ids ~= nil then
			pcall(function()
				for _, itemID in ipairs(ids) do
					itemCount = itemCount + 1
					local subject = purchasedItemSubject(itemID)
					if subject ~= nil then
						if resolved == nil then resolved = subject elseif resolved ~= subject then conflict = true end
					end
				end
			end)
		end
		if conflict then return "other", itemCount end
		if resolved ~= nil then return resolved, itemCount end
		return nil, itemCount
	end

	local function recordObservedSubject(subject, source, provenance)
		if subject == nil or not BANK or not BANK.recordCategorizedObservedWalletSpend then return false end
		local recorded = false
		pcall(function() recorded = BANK:recordCategorizedObservedWalletSpend(subject, source, provenance or "service") == true end)
		return recorded
	end

	local function readExactAnalyticsWallet()
		if not BANK or not BANK._tryReadWalletBalance then return nil end
		local wallet = nil
		local readable = false
		pcall(function() wallet, readable = BANK:_tryReadWalletBalance() end)
		if readable ~= true then return nil end
		wallet = math.floor(tonumber(wallet) or -1)
		if wallet < 0 then return nil end
		return wallet
	end

	local function recordExactWalletDelta(walletBefore, subject, source, provenance)
		walletBefore = math.floor(tonumber(walletBefore) or -1)
		local walletAfter = readExactAnalyticsWallet()
		if walletBefore < 0 or walletAfter == nil or walletAfter >= walletBefore then return false end
		local amount = walletBefore - walletAfter
		if not BANK or not BANK.recordCategorizedWalletSpend then return false end
		local recorded = false
		pcall(function()
			recorded = BANK:recordCategorizedWalletSpend(subject, amount, source, provenance or "service") == true
		end)
		return recorded
	end

	local function pushWalletSnapshot(stack)
		stack[#stack + 1] = readExactAnalyticsWallet() or -1
	end

	local function popWalletSnapshot(stack)
		local index = #stack
		if index <= 0 then return -1 end
		local value = stack[index]
		table.remove(stack, index)
		return value
	end

	local function captureVendorRequest(source)
		return function(manager, itemData, amount, requestId)
			local itemID = nil
			pcall(function() itemID = itemData and itemData:GetID() or nil end)
			local quantity = math.max(math.floor(tonumber(amount) or 1), 1)
			local unitPrice = 0
			pcall(function()
				if source == "vendor_buyback" then
					unitPrice = math.max(math.floor(tonumber(manager:GetSellingPrice(itemID)) or 0), 0)
				else
					unitPrice = math.max(math.floor(tonumber(manager:GetBuyingPrice(itemID)) or 0), 0)
				end
			end)
			local requestKey = tostring(requestId or "0")
			pcall(function()
				if requestId and requestId.value ~= nil then requestKey = tostring(requestId.value) end
			end)
			table.insert(pendingVendorRequests, {
				subject = purchasedItemSubject(itemID),
				walletBefore = readExactAnalyticsWallet() or -1,
				expectedAmount = unitPrice * quantity,
				createdAt = os.clock(),
				source = source,
				requestId = requestKey,
			})
			while #pendingVendorRequests > 16 do table.remove(pendingVendorRequests, 1) end
		end
	end

	local function consumeVendorRequest(eventRequestId, resolvedSubject)
		local now = os.clock()
		for index = #pendingVendorRequests, 1, -1 do
			if now - (tonumber(pendingVendorRequests[index].createdAt) or 0) > 1.25 then
				table.remove(pendingVendorRequests, index)
			end
		end
		local eventKey = tostring(eventRequestId or "0")
		pcall(function()
			if eventRequestId and eventRequestId.value ~= nil then eventKey = tostring(eventRequestId.value) end
		end)
		if eventKey ~= "" and eventKey ~= "0" and eventKey ~= "nil" then
			for index = 1, #pendingVendorRequests do
				if pendingVendorRequests[index].requestId == eventKey then
					local candidate = pendingVendorRequests[index]
					table.remove(pendingVendorRequests, index)
					return candidate
				end
			end
			return nil
		end
		for index = 1, #pendingVendorRequests do
			local candidate = pendingVendorRequests[index]
			if resolvedSubject == nil or resolvedSubject == "other" or candidate.subject == nil or candidate.subject == resolvedSubject then
				table.remove(pendingVendorRequests, index)
				return candidate
			end
		end
		return nil
	end

	pcall(function()
		ObserveBefore('VendorDataManager', 'BuyItemFromVendor', captureVendorRequest("vendor_purchase"))
		ObserveBefore('VendorDataManager', 'BuybackItemFromVendor', captureVendorRequest("vendor_buyback"))
	end)

	local function observeVendorPurchaseSuccess(className)
		pcall(function()
			ObserveAfter(className, 'OnUIVendorItemBoughtEvent', function(_, evt)
				local eventSubject, eventItemCount = subjectFromPurchaseEvent(evt)
				local eventRequestId = nil
				pcall(function() eventRequestId = evt and evt.requestID or nil end)
				if math.floor(tonumber(eventItemCount) or 0) <= 0 then
					consumeVendorRequest(eventRequestId, nil)
					return
				end
				local request = consumeVendorRequest(eventRequestId, eventSubject)
				if request ~= nil then
					local subject = eventSubject or request.subject or "other"
					local expectedAmount = math.max(math.floor(tonumber(request.expectedAmount) or 0), 0)
					if expectedAmount > 0 and BANK and BANK.recordCategorizedWalletSpend then
						local requestWalletBefore = math.floor(tonumber(request.walletBefore) or -1)
						local ledgerWalletAfter = requestWalletBefore >= expectedAmount and (requestWalletBefore - expectedAmount) or nil
						pcall(function() BANK:recordCategorizedWalletSpend(subject, expectedAmount, request.source or (string.lower(className) .. "_purchase"), "item", ledgerWalletAfter) end)
					else
						recordExactWalletDelta(request.walletBefore, subject, request.source or (string.lower(className) .. "_purchase"), "item")
					end
				end
			end)
		end)
	end
	observeVendorPurchaseSuccess('FullscreenVendorGameController')
	observeVendorPurchaseSuccess('RipperDocGameController')

	local virtualAtelierWalletStack = {}
	pcall(function()
		ObserveBefore('VirtualAtelier.UI.VirtualStoreController', 'BuyItemFromVirtualVendor', function(...)
			pushWalletSnapshot(virtualAtelierWalletStack)
		end)
		ObserveAfter('VirtualAtelier.UI.VirtualStoreController', 'BuyItemFromVirtualVendor', function(_, inventoryItemData)
			local itemID = nil
			pcall(function() itemID = InventoryItemData.GetID(inventoryItemData) end)
			recordExactWalletDelta(popWalletSnapshot(virtualAtelierWalletStack), purchasedItemSubject(itemID) or "other", "virtual_atelier_purchase", "item")
		end)
	end)

	local ripperServiceDepth = 0
	local ripperServiceWalletBefore = -1
	pcall(function()
		ObserveBefore('RipperDocGameController', 'TransferEddiesForService', function(...)
			if ripperServiceDepth == 0 then ripperServiceWalletBefore = readExactAnalyticsWallet() or -1 end
			ripperServiceDepth = ripperServiceDepth + 1
		end)
		ObserveAfter('RipperDocGameController', 'TransferEddiesForService', function(...)
			ripperServiceDepth = math.max(ripperServiceDepth - 1, 0)
			if ripperServiceDepth == 0 then
				local before = ripperServiceWalletBefore
				ripperServiceWalletBefore = -1
				recordExactWalletDelta(before, "cyberware", "ripperdoc_service", "service")
			end
		end)
	end)

	local delamainWalletStack = {}
	pcall(function()
		ObserveBefore('DelamainTaxiSystem', 'OnPayTravelRequest', function(...)
			pushWalletSnapshot(delamainWalletStack)
		end)
		ObserveAfter('DelamainTaxiSystem', 'OnPayTravelRequest', function(...)
			recordExactWalletDelta(popWalletSnapshot(delamainWalletStack), "transportation", "delamain_fare", "service")
		end)
	end)

	local function observeAnodosInvestment(methodName, source)
		local balanceStack = {}
		pcall(function()
			ObserveBefore('NightCityEstate.NCEInvestmentSystem', methodName, function(system, gameInstance, key)
				local before = -1
				pcall(function() before = math.floor(tonumber(system:GetAnodosAccountBalance()) or -1) end)
				balanceStack[#balanceStack + 1] = before
			end)
			ObserveAfter('NightCityEstate.NCEInvestmentSystem', methodName, function(system, gameInstance, key)
				local stackIndex = #balanceStack
				local before = stackIndex > 0 and balanceStack[stackIndex] or -1
				if stackIndex > 0 then table.remove(balanceStack, stackIndex) end
				local after = -1
				pcall(function() after = math.floor(tonumber(system:GetAnodosAccountBalance()) or -1) end)
				local amount = before >= 0 and after >= 0 and math.max(before - after, 0) or 0
				if amount > 0 and BANK and BANK.recordCategorizedExternalAccountSpend then
					BANK:recordCategorizedExternalAccountSpend("real_estate", amount, source, "external")
				end
			end)
		end)
	end
	observeAnodosInvestment('Invest', "anodos_real_estate")

	local function readAnodosAccountBalance()
		local balance = -1
		pcall(function()
			local container = Game.GetScriptableSystemsContainer()
			if not container then return end
			local system = container:Get("NightCityEstate.NCEInvestmentSystem")
			if system then balance = math.floor(tonumber(system:GetAnodosAccountBalance()) or -1) end
		end)
		return balance
	end

	local zaraAccountBalanceStack = {}
	pcall(function()
		ObserveBefore('ParagonZaraPhone.ParagonZaraPhoneContact', 'HandleConfirmAccept', function(...)
			zaraAccountBalanceStack[#zaraAccountBalanceStack + 1] = readAnodosAccountBalance()
		end)
		ObserveAfter('ParagonZaraPhone.ParagonZaraPhoneContact', 'HandleConfirmAccept', function(...)
			local stackIndex = #zaraAccountBalanceStack
			local before = stackIndex > 0 and zaraAccountBalanceStack[stackIndex] or -1
			if stackIndex > 0 then table.remove(zaraAccountBalanceStack, stackIndex) end
			local after = readAnodosAccountBalance()
			local amount = before >= 0 and after >= 0 and math.max(before - after, 0) or 0
			if amount > 0 and BANK and BANK.recordCategorizedExternalAccountSpend then
				BANK:recordCategorizedExternalAccountSpend("real_estate", amount, "anodos_zara_real_estate", "external")
			end
		end)
	end)



	pcall(function()
		ObserveAfter('CarDealer.System.PurchasableVehicleSystem', 'QueuePurchaseConfirmation', function(_, vehicleID, amount, financed)
			if financed ~= true and BANK and BANK.recordVanguardCashPurchase then
				BANK:recordVanguardCashPurchase(amount)
			end
		end)
	end)
	local vanguardPolicyWalletStack = {}
	pcall(function()
		ObserveBefore('CarDealer.System.PurchasableVehicleSystem', 'ConfirmVanguardCoveragePolicyForTerm', function(...)
			pushWalletSnapshot(vanguardPolicyWalletStack)
		end)
		ObserveAfter('CarDealer.System.PurchasableVehicleSystem', 'ConfirmVanguardCoveragePolicyForTerm', function(...)
			recordExactWalletDelta(popWalletSnapshot(vanguardPolicyWalletStack), "insurance", "vanguard_policy", "service")
		end)
	end)
	pcall(function()
		Cron.After(0.50, function()
			if BANK and BANK.initializeVanguardAnalyticsCursor then BANK:initializeVanguardAnalyticsCursor() end
		end)
		Cron.After(2.00, function()
			if BANK and BANK.initializeVanguardAnalyticsCursor then BANK:initializeVanguardAnalyticsCursor() end
		end)
	end)

	local function armMarmurTheftProtection(source, seconds)
		if BANK and BANK.markTheftRecoveryWindow then
			BANK:markTheftRecoveryWindow(source, seconds or 8)
		end
	end

	pcall(function()
		Observe('WatchYourBackSystem', 'RobPlayer', function(_, moneyChance, moneyMinPercent, moneyMaxPercent, itemChance)
			armMarmurTheftProtection('watch_your_back_robbery', 10)
		end)
	end)

	pcall(function()
		Observe('WatchYourBackSystem', 'StealMoneyFromPlayer', function(_)
			armMarmurTheftProtection('watch_your_back_pickpocket', 10)
		end)
	end)

	setSettings()
	BrowserTab.initialize()
	syncJohnnySuppression(true)

	GameUI.Listen(function(state)
		local event = state.event

		syncJohnnySuppression(false)

		if event == "ScannerOpen" or event == "MenuOpen"
			or event == "PhotoModeOpen" or event == "PopupOpen"
			or event == "QuickHackOpen" or event == "ShardOpen"
			or event == "WheelOpen" or event == "TutorialOpen"
			or event == "LoadingStart" or event == "CyberspaceEnter"
			or event == "BraindancePlay" or event == "BraindanceEdit" then
			isInMenu = true
			if BANK and BANK.setWalletInteractionContext then
				BANK:setWalletInteractionContext(true, event)
			end
		elseif event == "ScannerClose" or event == "MenuClose"
			or event == "PhotoModeClose" or event == "PopupClose"
			or event == "QuickHackClose" or event == "ShardClose"
			or event == "WheelClose" or	event == "TutorialClose"
			or event == "LoadingFinish" or event == "CyberspaceExit"
			or event == "CyberspaceEnter" or event == "BraindanceExit" then
			isInMenu = false
			if BANK and BANK.setWalletInteractionContext then
				BANK:setWalletInteractionContext(false, event)
			end
			pcall(function() scheduleMarmurWalletReconcile("menu_close_" .. tostring(event or "")) end)
		end

		if state.menu == "DeathMenu" or state.event == "SessionEnd" then
			isGameplayActive = false
			pcall(function() if BANK and BANK.clearRuntimeCaches then BANK:clearRuntimeCaches() end end)
			SPAWN:clearSessionData()
		end
	end)

	GameUI.OnSessionStart(function()
		isGameplayActive = true
		ensureMarmurZeroEngineRuntime()
		pcall(function() if BANK and BANK.clearRuntimeCaches then BANK:clearRuntimeCaches() end end)
		pcall(function() scheduleMarmurWalletReconcile("session_start") end)
		pcall(function() Cron.After(2.0, function() scheduleMarmurWalletReconcile("session_start_followup") end) end)

		Cron.After(3, function()
			SPAWN:setupBanker()
		end)
	end)

	GameUI.Listen("MenuNav", function(state)
		if state.lastSubmenu ~= nil
			and state.lastSubmenu == "Settings" then
			saveSettings()

			local newLocale =
				NameToString(GameSettings.Get("/language/OnScreen"))

			if lastLocale ~= newLocale then
				lastLocale = newLocale
				setupMenu()
			end
		end
	end)

	Observe('RadialWheelController', 'OnIsInMenuChanged', function (_, radialMenuOpen)
		isInMenu = radialMenuOpen == true
		if BANK and BANK.setWalletInteractionContext then
			BANK:setWalletInteractionContext(isInMenu, isInMenu and "RadialWheelOpen" or "RadialWheelClose")
		end

		if not isInMenu then
			pcall(function() scheduleMarmurWalletReconcile("radial_menu_close") end)
			saveSettings()
			setSettings()
		end
	end)

	isGameplayActive = not GameUI.IsDetached()
end)

registerForEvent("onOverlayOpen", function()
	pcall(function()
		if BANK and BANK.atmKeypad and BANK.atmKeypad.isActive
			and BANK.atmKeypad:isActive() and BANK.hideHub then
			BANK:hideHub()
		end
	end)
end)

registerForEvent("onShutdown", function()
	pcall(function()
		if BANK and BANK.hideHub then BANK:hideHub() end
	end)
	pcall(function()
		if BANK and BANK.setVanguardAutoFinanceIntegrationAvailable then
			BANK:setVanguardAutoFinanceIntegrationAvailable(false)
		end
	end)
	marmurZeroEngineRuntimeReady = false
	marmurReadyFactSyncElapsed = 0
	setMarmurZeroEngineReadyFact(0)
	if Util and Util.clearDeferredAlerts then Util.clearDeferredAlerts() end
end)

marmurRuntimeTick = function(delta)
	delta = tonumber(delta) or 0.0
	if delta < 0.0 then delta = 0.0 end
	if delta > MARMUR_UPDATE_DELTA_MAX then delta = MARMUR_UPDATE_DELTA_MAX end

	if syncJohnnySuppression(false) then
		pcall(function()
			if BANK.maintainVanguardAutoFinanceLease then
				BANK:maintainVanguardAutoFinanceLease()
			end
			if BANK.maintainJohnnySuppressedState then
				BANK:maintainJohnnySuppressedState()
			else
				BANK:hideHub()
			end
		end)
		pcall(function() SPAWN:hideHub(true) end)
		return
	end

	if Util and Util.flushDeferredAlerts then Util.flushDeferredAlerts() end

	if BANK and BANK.updateTimers then BANK:updateTimers(delta) end
	local ui = SPAWN and SPAWN.interactionUI
	if ui and ui.update then
		local maintainingVanillaSuppression = false
		if ui.maintainVanillaSuppression then
			maintainingVanillaSuppression = ui.maintainVanillaSuppression() == true
		end
		if ui.hubShown == true or ui.input == true or ui.suppressVanillaDialogs == true or maintainingVanillaSuppression == true then
			ui.update()
		end
	end

	local frameTime = os.clock()
	if SPAWN and SPAWN.updateTimers and frameTime > nextSpawnTimerUpdateTime then
		nextSpawnTimerUpdateTime = frameTime + 0.50
		SPAWN:updateTimers(delta)
	end

	Cron.Update(delta)
end

registerForEvent("onDraw", function()
	if johnnySuppressed then
		return
	end

	if isInMenu or not isGameplayActive then
		return
	end

	if not SPAWN or not SPAWN.isInitialized then
		return
	end

	if not BANK or not BANK.isInitialized then
		return
	end

	currentTime = os.clock()

	if currentTime > nextCheckTime then
		nextCheckTime = currentTime + 1

		local player = nil
		pcall(function() player = Game.GetPlayer() end)
		if player == nil then
			BANK:hideHub()
			SPAWN:hideHub(true)
			SPAWN:checkSubTitle()
			return
		end

		local blocked = false
		pcall(function()
			if Game.GetMountedVehicle(player) then blocked = true end
		end)
		pcall(function()
			if LiftDevice and LiftDevice.IsPlayerInsideElevator and LiftDevice.IsPlayerInsideElevator() then blocked = true end
		end)
		pcall(function()
			local state = player:GetCurrentCombatState()
			if state ~= nil and state.value == "InCombat" then blocked = true end
		end)

		if blocked then
			BANK:hideHub()
			SPAWN:hideHub(true)
			SPAWN:checkSubTitle()
			return
		end

		if BANK.atmKeypad and BANK.atmKeypad.isActive and BANK.atmKeypad:isActive() then
			if BANK.atmKeypad.update then
				pcall(function() BANK.atmKeypad:update(0) end)
			end
			SPAWN:checkSubTitle()
			return
		end

		local num = BANK:distanceListener()

		if num > 0 then
			if BANK.lastAccessType == "atm" then
				BANK:hideHub()
				SPAWN:checkSubTitle()
				return
			end

			BANK:showHub()
			SPAWN:checkSubTitle()
			return
		else
			BANK:hideHub()
		end

		num = SPAWN:spawnFriend()
	
		if num > 0 then
			SPAWN:showHub(num)
		else
			SPAWN:hideHub(true)
		end

		SPAWN:checkSubTitle()
	end
end)

function loadSettings()
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
			local loadedAtmDistance = tonumber(settings.atmDistance) or ATM_DISTANCE_DEFAULT
			if math.abs(loadedAtmDistance - ATM_DISTANCE_OLD_DEFAULT) < 0.001
				or math.abs(loadedAtmDistance - ATM_DISTANCE_PREVIOUS_DEFAULT) < 0.001 then
				settings.atmDistance = ATM_DISTANCE_DEFAULT
			end
		end
	end
end

function saveSettings()
	local validJson, contents =
		pcall(function() return json.encode(settings) end)

	if validJson and contents ~= nil then
		local file = io.open("settings.json", "w+")
		file:write(contents)
		file:close()
	end
end

function setSettings()
	BANK:setSettingValues(
		settings.tranAmount,
		settings.atmDistance,
		settings.atmFontSize,
		settings.interestRate,
		settings.termOfIncome
	)
	SPAWN:setSettingValues(
		settings.atmFontSize,
		settings.npcBanker
	)
end

function setupMenu()
	local nativeSettings = GetMod("nativeSettings")

	if not nativeSettings then
		return
	end

	if not nativeSettings.pathExists("/ZAWA") then
		nativeSettings.addTab("/ZAWA", "TSU MODS")
	end

	if nativeSettings.pathExists("/ZAWA/Banker") then
		nativeSettings.removeSubcategory("/ZAWA/Banker")
	end

	nativeSettings.addSubcategory(
		"/ZAWA/Banker",
		Lang.getText("subTitleBanker")
	)

	local list = {
		[1] = Lang.getText("list1"),
		[2] = Lang.getText("list2"),
		[3] = Lang.getText("list3"),
	}

	nativeSettings.addSelectorString(
		"/ZAWA/Banker",
		Lang.getText("tranAmount"),
		Lang.getText("tranAmount_desc"),
		list,
		settings.tranAmount,
		2,
		function(state) settings.tranAmount = state end
	)


	nativeSettings.addRangeFloat(
		"/ZAWA/Banker",
		Lang.getText("termOfIncome"),
		Lang.getText("termOfIncome_desc"),
		1,
		5,
		1,
		"%.0f",
		settings.termOfIncome,
		2,
		function(value) settings.termOfIncome = value end
	)

	nativeSettings.addRangeFloat(
		"/ZAWA/Banker",
		Lang.getText("atmDistance"),
		Lang.getText("atmDistance_desc"),
		ATM_DISTANCE_MIN,
		ATM_DISTANCE_MAX,
		0.1,
		"%.1f",
		settings.atmDistance,
		ATM_DISTANCE_DEFAULT,
		function(value) settings.atmDistance = value end
	)

	nativeSettings.addRangeFloat(
		"/ZAWA/Banker",
		Lang.getText("atmFontSize"),
		Lang.getText("atmFontSize_desc"),
		0,
		80,
		5,
		"%.0f",
		settings.atmFontSize,
		65,
		function(value) settings.atmFontSize = value end
	)

	nativeSettings.addRangeFloat(
		"/ZAWA/Banker",
		Lang.getText("npcBanker"),
		Lang.getText("npcBanker_desc"),
		0,
		20,
		1,
		"%.0f",
		settings.npcBanker,
		1,
		function(value) settings.npcBanker = value end
	)

	nativeSettings.refresh()
end

local MARMUR_PUBLIC_API = {
	apiVersion = 2,
	releaseVersion = "21a",
}

function MARMUR_PUBLIC_API:isExternalPartnerAccountLinked()
	return BANK:isExternalPartnerAccountLinked()
end

function MARMUR_PUBLIC_API:getExternalPartnerCheckingBalance()
	return BANK:getExternalPartnerCheckingBalance()
end

function MARMUR_PUBLIC_API:getExternalPartnerSavingsBalance()
	return BANK:getExternalPartnerSavingsBalance()
end

function MARMUR_PUBLIC_API:transferCheckingToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return BANK:transferCheckingToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
end

function MARMUR_PUBLIC_API:transferSavingsToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return BANK:transferSavingsToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
end

function MARMUR_PUBLIC_API:receiveCheckingFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return BANK:receiveCheckingFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
end

function MARMUR_PUBLIC_API:receiveSavingsFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return BANK:receiveSavingsFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
end

function MARMUR_PUBLIC_API:recordKnownAnalyticsSpend(subject, amount, source, provenance, ledgerWalletAfter)
	return BANK:recordCategorizedWalletSpend(subject, amount, source, provenance, ledgerWalletAfter)
end

function MARMUR_PUBLIC_API:recordObservedAnalyticsSpend(subject, source, provenance)
	return BANK:recordCategorizedObservedWalletSpend(subject, source, provenance)
end

function MARMUR_PUBLIC_API:recordExternalAccountAnalyticsSpend(subject, amount, source, provenance)
	return BANK:recordCategorizedExternalAccountSpend(subject, amount, source, provenance)
end

function MARMUR_PUBLIC_API:GetVanguardAutoLoanBillingMode(payload)
	return BANK.GetVanguardAutoLoanBillingMode(BANK, payload)
end

function MARMUR_PUBLIC_API:GetVanguardLoanBillingMode(payload)
	return BANK.GetVanguardLoanBillingMode(BANK, payload)
end

function MARMUR_PUBLIC_API:PostVanguardCoverageReminder(payload)
	return BANK.PostVanguardCoverageReminder(BANK, payload)
end

function MARMUR_PUBLIC_API:PostVanguardCoverageDefault(payload)
	return BANK.PostVanguardCoverageDefault(BANK, payload)
end

return MARMUR_PUBLIC_API
