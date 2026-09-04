local ui = {
	baseControler = nil,
	hub = nil,
	callbacks = {},
	hubShown = false,
	suppressVanillaDialogs = false,
	vanillaDialogSeenAt = 0,
	selectedIndex = 0,
	input = false,
	initialized = false,
	vanillaSuppressPredicate = nil,
	clearingVanillaDialogs = false,
	nextSuppressionPredicateAt = 0,
	cachedPredicateSuppressed = false,
	nextForcedVanillaClearAt = 0,
	worldInteractionLockActive = false,
	nextWorldInteractionLockAt = 0
}

local function nowSeconds()
	local ok, value = pcall(function() return os.clock() end)
	if ok and value then return tonumber(value) or 0 end
	return 0
end

local WORLD_INTERACTION_LOCK_EFFECT = "GameplayRestriction.NoWorldInteractions"

local WORLD_INTERACTION_ACTIONS = {
	ChoiceApply = true,
	Choice1 = true,
	Choice2 = true,
	Open = true,
	Use = true,
	Interact = true,
	Interaction = true,
	Interactions = true,
	WorldInteract = true,
	WorldInteraction = true,
	DeviceInteract = true,
	DeviceInteraction = true,
	InteractWithDevice = true,
	ActivateDevice = true,
	OpenDoor = true,
	DoorOpen = true,
	DoorClose = true,
	ToggleDoor = true,
	ToggleOpen = true,
	DeviceOpen = true,
	DeviceToggle = true,
	ActionOpen = true,
	Activate = true,
	Accept = true,
	ContextAction = true,
	PerformInteraction = true,
	Toggle = true,
	UI_Apply = true,
	UI_Select = true,
	UI_Confirm = true,
	UI_Interaction = true,
	UI_Interact = true,
	Select = true,
	Apply = true,
	Confirm = true,
	Enter = true,
}

local function isPressed(actionType)
	local value = tostring(actionType or "")
	return value == "BUTTON_PRESSED" or value == "BUTTON_HOLD"
end

local function getActionDetails(action)
	local actionName = ""
	local actionType = ""

	pcall(function()
		actionName = Game.NameToString(action:GetName(action)) or ""
	end)

	pcall(function()
		local t = action:GetType(action)
		if t ~= nil and t.value ~= nil then
			actionType = tostring(t.value)
		end
	end)

	return tostring(actionName or ""), tostring(actionType or "")
end

local function consumeAction(action, consumer)
	pcall(function()
		if consumer and consumer.Consume then
			consumer:Consume(action)
		end
	end)

	pcall(function()
		if action and action.Consume then
			action:Consume()
		end
	end)

	pcall(function()
		if action and action.SetConsumed then
			action:SetConsumed(true)
		end
	end)
end

local function setWorldInteractionLock(active, force)
	local shouldLock = active == true
	local now = nowSeconds()

	if shouldLock and force ~= true and ui.worldInteractionLockActive == true
		and now < (tonumber(ui.nextWorldInteractionLockAt or 0) or 0) then
		return
	end

	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then
		ui.worldInteractionLockActive = shouldLock
		ui.nextWorldInteractionLockAt = 0
		return
	end

	local status = nil
	pcall(function() status = Game.GetStatusEffectSystem() end)
	if status == nil then
		ui.worldInteractionLockActive = shouldLock
		ui.nextWorldInteractionLockAt = 0
		return
	end

	if shouldLock then
		pcall(function()
			status:ApplyStatusEffect(
				player:GetEntityID(),
				WORLD_INTERACTION_LOCK_EFFECT,
				player:GetRecordID(),
				player:GetEntityID()
			)
		end)
		ui.worldInteractionLockActive = true
		ui.nextWorldInteractionLockAt = now + 0.20
	else
		if ui.worldInteractionLockActive == true or force == true then
			pcall(function() status:RemoveStatusEffect(player:GetEntityID(), WORLD_INTERACTION_LOCK_EFFECT) end)
		end
		ui.worldInteractionLockActive = false
		ui.nextWorldInteractionLockAt = 0
	end
end

local function shouldSuppressByPredicateNow()
	if type(ui.vanillaSuppressPredicate) == "function" then
		local ok, result = pcall(ui.vanillaSuppressPredicate)
		return ok == true and result == true
	end

	return false
end

local function refreshSuppressionPredicate(force)
	local now = nowSeconds()
	if force ~= true and now < (tonumber(ui.nextSuppressionPredicateAt or 0) or 0) then
		return ui.cachedPredicateSuppressed == true
	end

	ui.nextSuppressionPredicateAt = now + 0.03
	ui.cachedPredicateSuppressed = shouldSuppressByPredicateNow() == true
	return ui.cachedPredicateSuppressed == true
end

local function shouldSuppressVanillaNow()
	if ui.suppressVanillaDialogs == true then
		return true
	end

	return refreshSuppressionPredicate(false) == true
end

local function shouldBlockWorldAction(actionName, actionType)
	if not shouldSuppressVanillaNow() then
		return false
	end

	if WORLD_INTERACTION_ACTIONS[tostring(actionName or "")] ~= true then
		return false
	end

	if isPressed(actionType) then
		ui.suppressVanilla(true, true)
		return true
	end

	return false
end

local function getDialogHubCount(data)
	if not data then return 0 end

	local ok, count = pcall(function()
		if data.choiceHubs then
			return #data.choiceHubs
		end
		return 0
	end)

	if ok and count then return tonumber(count) or 0 end
	return 0
end

function ui.createChoice(localizedName, icon, choiceType)
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

function ui.createHub(title, choices, activityState)
	local hub = gameinteractionsvisListChoiceHubData.new()
	hub.title = title or "Title"
	hub.choices = choices or {}
	hub.activityState = activityState or gameinteractionsvisEVisualizerActivityState.Active
	hub.hubPriority = 1
	hub.id = 69420 + math.random(99999)

	return hub
end

function ui.setupHub(hub, i)
	ui.hub = hub
	ui.selectedIndex = 0

	if i then
		ui.selectedIndex = i - 1
	end
end

function ui.showHub()
	if not ui.hub or not ui.baseControler then
		return
	end

	local data = DialogChoiceHubs.new()
	data.choiceHubs = { ui.hub }

	ui.baseControler.AreDialogsOpen = #data.choiceHubs > 0
	ui.baseControler.dialogIsScrollable = #data.choiceHubs > 1

	ui.baseControler:OnDialogsSelectIndex(ui.selectedIndex)
	ui.baseControler:UpdateDialogsData(data)
	ui.baseControler:OnInteractionsChanged()
	ui.baseControler:UpdateListBlackboard()
	ui.baseControler:OnDialogsActivateHub(ui.hub.id)

	ui.hubShown = true
end

function ui.hideHub()
	if not ui.hub or not ui.baseControler then
		ui.hubShown = false
		return
	end

	local data = DialogChoiceHubs.new()
	ui.baseControler:UpdateDialogsData(data)
	ui.baseControler:OnInteractionsChanged()
	ui.baseControler:UpdateListBlackboard()

	ui.hubShown = false
end

function ui.suppressVanilla(active, forceClear)
	local wasSuppressed = ui.suppressVanillaDialogs == true
	local requestedActive = active == true

	if requestedActive ~= true and refreshSuppressionPredicate(false) == true then
		requestedActive = true
	end

	ui.suppressVanillaDialogs = requestedActive
	setWorldInteractionLock(ui.suppressVanillaDialogs, forceClear == true)

	if not ui.baseControler then
		return
	end

	if ui.suppressVanillaDialogs then
		if ui.clearingVanillaDialogs then
			return
		end

		local now = nowSeconds()
		if wasSuppressed and forceClear ~= true and now < (tonumber(ui.nextForcedVanillaClearAt or 0) or 0) then
			return
		end
		ui.nextForcedVanillaClearAt = now + 0.03

		ui.clearingVanillaDialogs = true
		pcall(function()
			local data = DialogChoiceHubs.new()
			ui.baseControler.AreDialogsOpen = false
			ui.baseControler.dialogIsScrollable = false
			ui.baseControler:UpdateDialogsData(data)
			ui.baseControler:OnInteractionsChanged()
			ui.baseControler:UpdateListBlackboard()
		end)

		pcall(function()
			local defs = GetAllBlackboardDefs()
			local board = Game.GetBlackboardSystem():Get(defs.UIInteractions)
			board:SetInt(defs.UIInteractions.SelectedIndex, -1)
		end)
		ui.clearingVanillaDialogs = false
	else
		if wasSuppressed then
			ui.nextForcedVanillaClearAt = 0
			ui.baseControler:OnInteractionsChanged()
			ui.baseControler:UpdateListBlackboard()
		end
	end
end

function ui.forceClearVanillaPrompt()
	if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
		ui.suppressVanilla(true, true)
		return true
	end

	return false
end

function ui.setVanillaSuppressPredicate(predicate)
	if type(predicate) == "function" then
		ui.vanillaSuppressPredicate = predicate
	else
		ui.vanillaSuppressPredicate = nil
	end
	ui.nextSuppressionPredicateAt = 0
	ui.cachedPredicateSuppressed = false

	if ui.vanillaSuppressPredicate == nil then
		setWorldInteractionLock(false, true)
	end
end

function ui.maintainVanillaSuppression()
	local shouldSuppress = refreshSuppressionPredicate(false) == true

	if shouldSuppress then
		ui.suppressVanilla(true, false)
	elseif ui.suppressVanillaDialogs == true then
		ui.suppressVanilla(false)
	elseif ui.worldInteractionLockActive == true then
		setWorldInteractionLock(false, true)
	end

	return shouldSuppress
end

function ui.isVanillaDialogActive(recentSeconds)
	if ui.hubShown or shouldSuppressVanillaNow() then
		return false
	end

	if ui.baseControler then
		local ok, open = pcall(function()
			return ui.baseControler.AreDialogsOpen == true
		end)

		if ok and open == true then
			return true
		end
	end

	local recent = tonumber(recentSeconds) or 0
	local seenAt = tonumber(ui.vanillaDialogSeenAt) or 0
	return recent > 0 and seenAt > 0 and (nowSeconds() - seenAt) <= recent
end

function ui.registerChoiceCallback(choiceIndex, callback)
	ui.callbacks[choiceIndex] = callback
end

function ui.clearCallbacks()
	ui.callbacks = {}
end

function ui.init()
	if ui.initialized then
		return
	end

	ui.initialized = true

	Observe("InteractionUIBase", "OnDialogsData", function(this)
		ui.baseControler = this
		if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
			ui.suppressVanilla(true, true)
		end
	end)

	Observe("InteractionUIBase", "OnInitialize", function(this)
		ui.baseControler = this
		if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
			ui.suppressVanilla(true, true)
		end
	end)

	local worldActionOverrideOk = pcall(function()
		Override("PlayerPuppet", "OnAction", function(_, action, consumer, wrappedMethod)
			local wrapped = wrappedMethod
			local wrappedConsumer = consumer

			if wrapped == nil then
				wrapped = consumer
				wrappedConsumer = nil
			end

			if action then
				local actionName, actionType = getActionDetails(action)
				if shouldBlockWorldAction(actionName, actionType) then
					consumeAction(action, wrappedConsumer)
					ui.input = true
					return true
				end
			end

			if wrapped then
				if wrappedConsumer ~= nil then
					return wrapped(action, wrappedConsumer)
				end
				return wrapped(action)
			end

			return false
		end)
	end)

	Observe('PlayerPuppet', 'OnAction', function(_, action)
		if shouldBlockWorldAction(getActionDetails(action)) then
			ui.input = true
			return
		end

		if ui.input or not ui.hubShown then
			return
		end

		local actionName = Game.NameToString(action:GetName(action))
		local actionType = action:GetType(action).value

		if actionName == 'ChoiceScrollUp' then
			if actionType == 'BUTTON_PRESSED' then
				ui.selectedIndex = ui.selectedIndex - 1

				if ui.selectedIndex < 0 then
					ui.selectedIndex = #ui.hub.choices - 1
				end

				Game.GetAudioSystem():Play('ui_elevator_select')
				ui.input = true
			end
		elseif actionName == 'ChoiceScrollDown' then
			if actionType == 'BUTTON_PRESSED' then
				ui.selectedIndex = ui.selectedIndex + 1

				if ui.selectedIndex > #ui.hub.choices - 1 then
					ui.selectedIndex = 0
				end

				Game.GetAudioSystem():Play('ui_elevator_select')
				ui.input = true
			end
		elseif actionName == 'ChoiceApply' then
			if actionType == 'BUTTON_PRESSED' then
				if ui.callbacks[ui.selectedIndex + 1] then
					ui.callbacks[ui.selectedIndex + 1]()
				end

				ui.input = true
			end
		end
	end)

	Override("InteractionUIBase", "OnDialogsSelectIndex", function(_, idx, wrapped)
		if ui.hubShown then
			if idx ~= ui.selectedIndex then
				return
			end
		end

		wrapped(idx)
	end)

	Override("InteractionUIBase", "OnDialogsData", function(_, value, wrapped)
		if ui.hubShown or ui.clearingVanillaDialogs then
			return
		end

		if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
			ui.suppressVanilla(true, true)
			return
		end

		if getDialogHubCount(value) > 0 then
			ui.vanillaDialogSeenAt = nowSeconds()
		else
			ui.vanillaDialogSeenAt = 0
		end

		wrapped(value)
	end)

	pcall(function()
		Override("InteractionUIBase", "OnInteractionsChanged", function(_, wrapped)
			if ui.clearingVanillaDialogs then
				return
			end

			if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
				ui.suppressVanilla(true, true)
				return
			end

			wrapped()
		end)
	end)

	pcall(function()
		Override("InteractionUIBase", "UpdateListBlackboard", function(_, wrapped)
			if ui.clearingVanillaDialogs then
				return
			end

			if refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true then
				return
			end

			wrapped()
		end)
	end)

	pcall(function()
		Override("InteractionUIBase", "OnDialogsActivateHub", function(_, id, wrapped)
			if ui.hubShown and id ~= ui.hub.id then
				return
			end

			if not ui.hubShown and (refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true) then
				ui.suppressVanilla(true, true)
				return
			end

			wrapped(id)
		end)
	end)

	Override("dialogWidgetGameController", "OnDialogsActivateHub", function(_, id, wrapped)
		if ui.hubShown and id ~= ui.hub.id then
			return
		end

		if not ui.hubShown and (refreshSuppressionPredicate(true) == true or ui.suppressVanillaDialogs == true) then
			ui.suppressVanilla(true, true)
			return
		end

		wrapped(id)
	end)
end

function ui.update()
	local suppressed = false
	if ui.maintainVanillaSuppression then
		suppressed = ui.maintainVanillaSuppression() == true
	end

	if suppressed and ui.forceClearVanillaPrompt then
		ui.forceClearVanillaPrompt()
	end

	if ui.hubShown then
		Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UIInteractions):SetInt(GetAllBlackboardDefs().UIInteractions.SelectedIndex, ui.selectedIndex)
	end

	ui.input = false
end

return ui
