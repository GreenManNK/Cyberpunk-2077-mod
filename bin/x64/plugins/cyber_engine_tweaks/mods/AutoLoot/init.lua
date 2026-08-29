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

-- DO NOT TRANSLATE THIS FILE!
-- Translation support is described in the file: "..\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\AutoLoot\language\Readme.txt"

-- Aug 15, 2026 based on the (c)keanuWheeze original script modified by (c)anygoodname by the keanuWheeze consent

-------------

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

local Ref = require('lib/Ref')
if not Ref then printError("AutoLoot: lib/Ref.lua file is not found or corrupted. This mod is disabled now.") return end

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))
local isGameV2 = cetVer >= 1.26

local autoLoot = {
	modVer = 'v3.10.5',
	moduleVer = 'v3.10.5',
	modName = 'Autoloot',
	modAuthorName = 'keanuWheeze idea and initial coding - anygoodname expansion and additional coding',

	isUIVisible = false,
	isContinuousLooting = false,
	continuousLootingInterval = 0.33,
	continuousLootingNextAction = 0,
	isBurst = false,
	uiBurstParams = {15, 60, 420},

	settings = {
		range = 20,
		spin = false,
		useDefaultActionKey = false,
		showDebugMonitorWindow = false,
		monitorType = 0,
		showMonitorWindowOnlyWhenTriggerActive = false,
		autohideMonitorWindow = false,
		lastLanguageSelected = "en-us",
		customTriggerKbdDelay = 0,
		customTriggerPadDelay = 0,
		enableTakedownLoot = false,
		enableBurstTrigger = false,
		burstTriggerCooldownTime = 60,
	},

	CPS = require("CPStyling"),
	ui = require("modules/ui_new"),
	config = require("modules/config"),
	logic = require("modules/logic")
}

if autoLoot.ui then autoLoot.ui.uiBurstParams = autoLoot.uiBurstParams end

autoLoot.defaultSettings = {}
for k, v in pairs(autoLoot.settings) do
	if k ~= "lastLanguageSelected" and k ~= "customTriggerKbdDelay" and k ~= "customTriggerPadDelay" then
		autoLoot.defaultSettings[k] = v
	end
end

if config then config.uiBurstParams = autoLoot.uiBurstParams end
local gameVer = 0
local isNewCetUI = false
local overlayModeWindowFlags = ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoFocusOnAppearing + ImGuiWindowFlags.NoBringToFrontOnFocus + ImGuiWindowFlags.NoCollapse
local normalModeWindowFlags = ImGuiWindowFlags.NoNavInputs + ImGuiWindowFlags.NoNavFocus + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoFocusOnAppearing + ImGuiWindowFlags.NoBringToFrontOnFocus + ImGuiWindowFlags.NoCollapse + ImGuiWindowFlags.NoScrollWithMouse + ImGuiWindowFlags.NoMouseInputs
local currentModeWindowFlags = 0
local prevTickTime = 0
local indicator = {last = 0, max = 4, chars = {'   ', '.  ', '.. ', '...'}}
local audioSystem, uiSystem, workspotSystem
local burstTriggerCooldownName = "autoloot_burst_trigger_cooldown"
local burstTriggerCooldownTime = 60
local burstEnterEventName = "ui_menu_perk_unlock_level"
if not isGameV2 then burstEnterEventName = "ui_menu_attributes_done" end
local burstExitEventName = "ui_menu_tutorial_close"
local minimap = "minimap"
local quest_list = "quest_list"
local worlduiEntryVisibilityForceHide
local GameGetSystemRequestsHandler

function showMonitorWindow()
	ImGui.SetNextWindowPos(50, 50, ImGuiCond.FirstUseEver)
	ImGui.SetNextWindowSize(-1 , -1)
	local isStyleSet = nil
	if autoLoot.isContinuousLooting then
		ImGui.PushStyleColor(ImGuiCol.WindowBg, 0.7, 0.14, 0.11, 0.4)
		ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 0)
		isStyleSet = {colorChanges = 1, varChanges = 1}
		if isNewCetUI then
			ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 2)
			ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 8, 6)
			isStyleSet.varChanges = isStyleSet.varChanges + 2
		end
		local lootingStr = autoLoot.ui.uiStrings.cetUiStrings.monitor.lootingStr or 'Looting '
		local x, y = ImGui.CalcTextSize(lootingStr..indicator.chars[indicator.max])
		ImGui.SetNextWindowSizeConstraints(x + ImGui.GetFrameHeight(), y, 900, 900)
	else
		indicator.last = 1
		ImGui.PushStyleColor(ImGuiCol.WindowBg, 0.15, 0.25, 0.204, 0.4)
		ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 0)
		isStyleSet = {colorChanges = 1, varChanges = 1}
		if isNewCetUI then
			ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 2)
			ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 8, 6)
			isStyleSet.varChanges = isStyleSet.varChanges + 2
		end
		local idleStr = autoLoot.ui.uiStrings.cetUiStrings.monitor.idleStr or "Idle."
		local x, y = ImGui.CalcTextSize(idleStr)
		ImGui.SetNextWindowSizeConstraints(x + ImGui.GetFrameHeight(), y, 900, 900)
	end

	if ImGui.Begin('Autoloot Monitor', true, currentModeWindowFlags) then
		pcall(function()
			if autoLoot.isContinuousLooting then
				local chr = indicator.chars[indicator.last]
				if prevTickTime ~= autoLoot.logic.lastLootCompletedTime then
					prevTickTime = autoLoot.logic.lastLootCompletedTime
					indicator.last = indicator.last + 1
					if indicator.last > indicator.max then indicator.last = 1 end
					chr = indicator.chars[indicator.last]
				end
				local lootingStr = autoLoot.ui.uiStrings.cetUiStrings.monitor.lootingStr or 'Looting '
				ImGui.TextColored(0.15, 1, 1, 1, lootingStr..chr)
			else
				local idleStr = autoLoot.ui.uiStrings.cetUiStrings.monitor.idleStr or "Idle."
				ImGui.TextColored(0.15, 1, 1, 1, idleStr)
			end
		end)
		ImGui.End()
	end
	if type(isStyleSet) ~= 'table' then return end
	if type(isStyleSet.colorChanges) == 'number' then ImGui.PopStyleColor(isStyleSet.colorChanges) end
	if type(isStyleSet.varChanges) == 'number' then ImGui.PopStyleVar(isStyleSet.varChanges) end
end

local lastLootingActionStart = 0
local autoEventThreshold = 3
local audioEvent1 = "ui_menu_tutorial_close"
local isCetKeyPressed = false
local isDefaultActionKeyPressed = false
local lastTriggerPressedTimeout = 0
local n
local lastLootingActionState

registerForEvent("onInit", function()
	isNewCetUI = false
	gameVer = tonumber(Game.GetSystemRequestsHandler():GetGameVersion())
	if gameVer >= 1.61 then isNewCetUI = true end

	if (not autoLoot.ui) or (not autoLoot.ui.uiStrings) or (not autoLoot.config) or (not autoLoot.logic) or (not autoLoot.ui.onInit) then
		print(autoLoot.modName, autoLoot.modVer, 'failed to initialize as some mod files are corrupted or missing.')
		if autoLoot.ui then autoLoot.ui.isInitialized = false end
		return
	end

	n = CName
	GameGetSystemRequestsHandler = Game.GetSystemRequestsHandler

	burstTriggerCooldownName = CName.new(burstTriggerCooldownName)
	burstEnterEventName = CName.new(burstEnterEventName)
	burstExitEventName = CName.new(burstExitEventName)
	minimap = CName.new(minimap)
	quest_list = CName.new(quest_list)

	audioSystem = Ref.Weak(Game.GetAudioSystem())
	uiSystem = Ref.Weak(Game.GetUISystem())
	workspotSystem = Ref.Weak(Game.GetWorkspotSystem())
	worlduiEntryVisibilityForceHide = worlduiEntryVisibility.ForceHide

	currentModeWindowFlags = normalModeWindowFlags

	resetAutoLootStates()
	autoLoot.logic.resetAutoLootStates = resetAutoLootStates
	autoLoot.logic.init()
	
	if not autoLoot.logic.isInitialized then
		print(autoLoot.modName, autoLoot.modVer, 'logic.lua module failed to initialize. Possibly corrupted file.')
		if autoLoot.ui then autoLoot.ui.isInitialized = false end
		return
	end

	autoLoot.ui.logic = autoLoot.logic
	autoLoot.ui.settings = autoLoot.settings
	autoLoot.ui.defaultSettings = autoLoot.defaultSettings
	logic.config = autoLoot.config
	logic.settings = autoLoot.settings
	autoLoot.config.settings = autoLoot.settings

	local newSettings = logic.config.loadConfig("config/config.json", autoLoot.settings)
	if type(newSettings) == 'table' then for k, v in pairs(newSettings) do autoLoot.settings[k] = v end end

	audioEvent1 = CName.new(audioEvent1)
	local lastActionName
	local isKBM, isPad
	local n_Pause = n"Pause"
	local n_OpenPauseMenu = n"OpenPauseMenu"
	local n_OpenMapMenu = n"OpenMapMenu"
	local n_OpenCraftingMenu = n"OpenCraftingMenu"
	local n_OpenJournalMenu = n"OpenJournalMenu"
	local n_OpenPerksMenu = n"OpenPerksMenu"
	local n_OpenInventoryMenu = n"OpenInventoryMenu"
	local n_OpenHubMenu = n"OpenHubMenu"
	local n_TogglePhotoMode = n"TogglePhotoMode"
	local n_MeleeAttack = n"MeleeAttack"
	local n_Ping = n"Ping"
	local n_UI_DPadWeapons = n"UI_DPadWeapons"

	local nextNativeClicked = 0
	local lastNativeClicked = 0
	local lastNativeClickedCooldown = 0
	local function isNativeDoubleClick()
		lastNativeClicked = nextNativeClicked
		nextNativeClicked = os.clock()
		if lastNativeClickedCooldown < nextNativeClicked and nextNativeClicked - lastNativeClicked < 0.5 then lastNativeClickedCooldown = nextNativeClicked + 0.6 return true end
	end
	local function handleButtonPressed(this, action)
		lastActionName = action:GetName(action)
		if lastActionName == n_Pause or lastActionName == n_OpenPauseMenu or lastActionName == n_OpenMapMenu or lastActionName == n_OpenCraftingMenu or lastActionName == n_OpenJournalMenu or lastActionName == n_OpenPerksMenu or lastActionName == n_OpenInventoryMenu or lastActionName == n_OpenHubMenu or lastActionName == n_TogglePhotoMode then
			autoLoot.isContinuousLooting = false return
		end
		if not action:IsAction(action, 'UI_Apply') then return end
		if not autoLoot.logic.couldStartNewLootingCycle() then return end
		if not autoLoot.isContinuousLooting then
			if autoLoot.logic.isLootDialogOnScreen then
				if autoLoot.settings.customTriggerKbdDelay > 0.6 then
					autoLoot.continuousLootingNextAction = os.clock() + autoLoot.settings.customTriggerKbdDelay
				else
					autoLoot.continuousLootingNextAction = os.clock() + 0.6
				end
			else
				if this:PlayerLastUsedPad() then
					local playerWeapon = this:GetActiveWeapon()
					if playerWeapon and playerWeapon:CanReload() then
						if autoLoot.settings.customTriggerPadDelay > 0.25 then
							autoLoot.continuousLootingNextAction = os.clock() + autoLoot.settings.customTriggerPadDelay
						else
							autoLoot.continuousLootingNextAction = os.clock() + 0.25
						end
					else
						if autoLoot.settings.customTriggerPadDelay > 0.01 then
							autoLoot.continuousLootingNextAction = os.clock() + autoLoot.settings.customTriggerPadDelay
						else
							autoLoot.continuousLootingNextAction = os.clock() + 0.01
						end
					end
				else
					if autoLoot.settings.customTriggerKbdDelay > 0 then
						autoLoot.continuousLootingNextAction = os.clock() + autoLoot.settings.customTriggerKbdDelay
					else
						autoLoot.continuousLootingNextAction = 0
					end
				end
			end
		end
		autoLoot.isContinuousLooting = true
		isDefaultActionKeyPressed = true
		lastTriggerPressedTimeout = os.clock() + 0.5
		if not (autoLoot.settings.enableBurstTrigger and isNativeDoubleClick() and (not this:IsInCombat()) and logic.isLootingTime(_, this)) then return end
		autoLoot.isBurst = not autoLoot.isBurst
		if autoLoot.isBurst then
			audioSystem:Play(burstEnterEventName)
			this:RemoveCooldown(burstTriggerCooldownName) this:StartCooldown(burstTriggerCooldownName, autoLoot.settings.burstTriggerCooldownTime or burstTriggerCooldownTime)
		else
			audioSystem:Play(burstExitEventName)
			audioSystem:Play(burstExitEventName)
			autoLoot.isContinuousLooting = false
			lastLootingActionStart = 0
			lastLootingActionState = false
		end
	end
	local function handleButtonReleased(this, action)
		if not autoLoot.isContinuousLooting then return end
		isPad = this:PlayerLastUsedPad() isKBM = not isPad
		if not (action:IsAction(action, 'UI_Apply') or action:IsAction(action, 'Choice1') or action:IsAction(action, 'click') or (isPad and (action:IsAction(action, 'Ping')))) then return end
		if
			lastActionName ~= n_Ping and lastActionName ~= n_MeleeAttack
				or
			(lastActionName == n_Ping and (action:IsAction(action, 'UI_Apply') or action:IsAction(action, 'click') or (isPad and action:IsAction(action, 'Choice1'))))
				or
			(lastActionName == n_MeleeAttack and (action:IsAction(action, 'UI_Apply') or action:IsAction(action, 'Choice1') or (isPad and action:IsAction(action, 'click'))))
		then
			if
				isKBM
					or
				(isPad and not (lastActionName == n_UI_DPadWeapons))
					or
				(isPad and lastActionName == n_UI_DPadWeapons and action:IsAction(action, 'UI_Apply'))
			then
				if action:IsAction(action, 'Forward') then return end
				if action:IsAction(action, 'Back') then return end
				if action:IsAction(action, 'Left') then return end
				if action:IsAction(action, 'Right') then return end
				if action:IsAction(action, 'Jump') then return end
				if action:IsAction(action, 'ToggleCrouch') then return end
				if (not isCetKeyPressed) and (not autoLoot.isBurst) then autoLoot.isContinuousLooting = false end
				isDefaultActionKeyPressed = false
			end
		end
	end

	local gameinputActionTypeBUTTON_PRESSED = gameinputActionType.BUTTON_PRESSED
	local gameinputActionTypeBUTTON_RELEASED = gameinputActionType.BUTTON_RELEASED
	local actionType
	Observe('PlayerPuppet', 'OnAction', function(this, action)
		if not autoLoot.settings.useDefaultActionKey then return end
		actionType = action:GetType(action)
		if actionType == gameinputActionTypeBUTTON_PRESSED then handleButtonPressed(this, action) return end
		if actionType == gameinputActionTypeBUTTON_RELEASED then handleButtonReleased(this, action) return end
	end)

	autoLoot.ui.onInit()
	autoLoot.ui.isInitialized = true
	autoLoot.ui.modName = autoLoot.modName
	autoLoot.ui.modVer = autoLoot.modVer
	autoLoot.logic.modName = autoLoot.modName
	autoLoot.logic.modVer = autoLoot.modVer
	print(autoLoot.modName, autoLoot.modVer, 'initialized.')
end)

registerForEvent("onShutdown", function()
	if not Game then return end
	if not Game.GetSystemRequestsHandler then return end
	if not Game.GetSystemRequestsHandler() then return end
	if type(autoLoot.ui.onShutdown) == 'function' then autoLoot.ui.onShutdown() end
end)

local function handleBursts()
	if not autoLoot.isBurst then return end
	local player = GetPlayer()
	if player then
		if player:IsInCombat() or (not player:IsCooldownActive(burstTriggerCooldownName)) or (not logic.couldStartNewLootingCycle(player)) then
			autoLoot.isBurst = false
			player:RemoveCooldown(burstTriggerCooldownName)
			if (not isDefaultActionKeyPressed) and (not isCetKeyPressed) then
				audioSystem:Play(burstExitEventName)
				audioSystem:Play(burstExitEventName)
				autoLoot.isContinuousLooting = false
				lastLootingActionStart = 0
				lastLootingActionState = false
				return true
			end
		end
		return
	end
	autoLoot.isBurst = false
	autoLoot.isContinuousLooting = false
	lastLootingActionStart = 0
	lastLootingActionState = false
	return true
end
local currTime = 0
local function handleTriggers()
	if not autoLoot.isContinuousLooting then
		if not lastLootingActionState then return end
		if lastLootingActionStart > 0 and os.clock() - lastLootingActionStart  > autoEventThreshold then audioSystem:Play(audioEvent1) end
		lastLootingActionStart = 0
		lastLootingActionState = false
		return
	end
	currTime = os.clock()
	if currTime > autoLoot.continuousLootingNextAction then
		if not lastLootingActionState then lastLootingActionStart = currTime end
		autoLoot.continuousLootingNextAction = currTime + autoLoot.continuousLootingInterval
		autoLoot.logic.lootInRange(autoLoot.settings.range, not autoLoot.settings.spin, true, true)
		lastLootingActionState = true
	end
	if autoLoot.logic.isPlayerInWorkspot then
		autoLoot.isContinuousLooting = false
		if isCetKeyPressed or isDefaultActionKeyPressed then
			lastLootingActionStart = 1
		end
		isDefaultActionKeyPressed = false
	end
end
registerForEvent("onUpdate", function(delta)
	if autoLoot.ui.payload and type(autoLoot.ui.payload) == 'function' then autoLoot.ui.payload() autoLoot.ui.payload = nil end
	updateMonitors()
	if autoLoot.logic.payload and type(autoLoot.logic.payload) == 'function' then autoLoot.logic.payload() autoLoot.logic.payload = nil end
	if handleBursts() then return end
	handleTriggers()
end)

function isInGameSettingsMenu()
	if not logic.isInSettingsMenu() then return end
	if not autoLoot.ui.nativeSettings then return true end
	if not autoLoot.ui.nativeSettings.fromMods then return true end
end
if isGameV2 then
	function shouldHideHudOnCinematicState(player)
		if not Game then return end
		if GameGetSystemRequestsHandler():IsGamePaused() then return end
		if (not autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive) and uiSystem:GetHudEntryForcedVisibility(quest_list) == worlduiEntryVisibilityForceHide then return true end
		player = player or GetPlayer()
		if not player then return end
		local tier = player:GetSceneTier()
		if tier < 3 then return end
		if tier > 5 then return end
		return true
	end
else
	function shouldHideHudOnCinematicState(player)
		if not Game then return end
		if GameGetSystemRequestsHandler():IsGamePaused() then return end
		player = player or GetPlayer()
		if not player then return end
		local tier = player:GetSceneTier()
		if tier < 3 then return end
		if tier > 5 then return end
		return true
	end

end
function shouldShowMonitorWindow()
	if autoLoot.settings.showMonitorWindowOnlyWhenTriggerActive and not(autoLoot.isContinuousLooting) then return end
	if isInGameSettingsMenu() then return end
	if not autoLoot.settings.autohideMonitorWindow then return true end
	local player = GetPlayer()
	if not player then return true end
	if shouldHideHudOnCinematicState(player) then return end
	if workspotSystem:IsActorInWorkspot(player) then return end
	return true
end
local lastVal
local nextValTime = 0
function shouldShowMonitorWindowWrapper()
	local currTime = os.clock()
	local isTriggerJustPressed = lastTriggerPressedTimeout > currTime
	if (not isTriggerJustPressed) and nextValTime > currTime then return lastVal end
	nextValTime = currTime + 0.2
	if lastVal and isTriggerJustPressed then return true end
	lastVal = shouldShowMonitorWindow()
	return lastVal
end

local shouldUpdateWidgets = type(autoLoot.ui.updateMinimapMonitorWidgetText) == 'function' and type(autoLoot.ui.hideMinimapMonitorWidget) ==  'function'
local showCet, showWidget = false, false
local oldShowWidget

function updateMonitors()
	showWidget = false
	if not autoLoot.settings.showDebugMonitorWindow then
		if not shouldUpdateWidgets then return end
		autoLoot.ui.hideMinimapMonitorWidget()
		return
	end

	if shouldShowMonitorWindowWrapper() then
		if autoLoot.settings.monitorType < 1 then
			showCet = true
		elseif autoLoot.settings.monitorType == 1 then
			showWidget = true
		else
			showCet = true showWidget = true
		end
	end
	if not shouldUpdateWidgets then return end
	if not showWidget and showWidget == oldShowWidget then return end
	oldShowWidget = showWidget
	autoLoot.ui.updateMinimapMonitorWidgetText(showWidget, autoLoot.isContinuousLooting)
end

registerForEvent("onDraw", function()
	if autoLoot.isUIVisible then autoLoot.ui.draw(autoLoot) end
	if showCet then showMonitorWindow() end
	showCet = false
end)

registerForEvent("onOverlayOpen", function()
	currentModeWindowFlags = overlayModeWindowFlags
	autoLoot.ui.shouldInitWindow = true
    autoLoot.isUIVisible = true
end)

registerForEvent("onOverlayClose", function()
	currentModeWindowFlags = normalModeWindowFlags
	autoLoot.ui.shouldInitWindow = false
    autoLoot.isUIVisible = false
end)

local autolootTriggerKey = autoLoot.ui.uiStrings.cetUiStrings.cetKeyBindings.autolootTriggerKey or 'AutoLoot'

if GetVersion() == 'v1.21.0' then
	registerHotkey('AutoLoot', autolootTriggerKey, function()
		if not autoLoot.isContinuousLooting then
			if not autoLoot.logic.couldStartNewLootingCycle() then
				return
			end
			autoLoot.logic.lootInRange(autoLoot.settings.range, not autoLoot.settings.spin, true, true)
		end
	end)
else
	local nextCetClicked = 0
	local lastCetClicked = 0
	local lastCetClickedCooldown = 0
	local function isCetDoubleClick()
		lastCetClicked = nextCetClicked
		nextCetClicked = os.clock()
		if lastCetClickedCooldown < nextCetClicked and nextCetClicked - lastCetClicked < 0.5 then lastCetClickedCooldown = nextCetClicked + 0.6 return true end
	end
	registerInput('AutoLoot', autolootTriggerKey, function(isKeyDown)
		isCetKeyPressed = isKeyDown
		if not autoLoot.isContinuousLooting then autoLoot.continuousLootingNextAction = 0 end
		if isKeyDown then
			if not autoLoot.logic.couldStartNewLootingCycle() then return end
			autoLoot.isContinuousLooting = true
			lastTriggerPressedTimeout = os.clock() + 0.5
			local player = GetPlayer()
			if autoLoot.settings.enableBurstTrigger and isCetDoubleClick() and (not player:IsInCombat()) and logic.isLootingTime(_, player) then
				autoLoot.isBurst = not autoLoot.isBurst
				if autoLoot.isBurst then
					audioSystem:Play(burstEnterEventName)
					player:RemoveCooldown(burstTriggerCooldownName) player:StartCooldown(burstTriggerCooldownName, autoLoot.settings.burstTriggerCooldownTime or burstTriggerCooldownTime)
				else
					audioSystem:Play(burstExitEventName)
					audioSystem:Play(burstExitEventName)
					autoLoot.isContinuousLooting = false
					lastLootingActionStart = 0
					lastLootingActionState = false
				end
			end
		else
			if not isDefaultActionKeyPressed then
				if not autoLoot.isBurst then
					autoLoot.isContinuousLooting = false
				end
			end
		end
	end)
end

local autolootMonitorKey = autoLoot.ui.uiStrings.cetUiStrings.cetKeyBindings.autolootMonitorKey or 'AutoLoot Monitor'

registerInput('AutoLootMonitor', autolootMonitorKey, function(isKeyDown)
	if not isKeyDown then return end
	if type(autoLoot.settings.showDebugMonitorWindow) ~= 'boolean' then autoLoot.settings.showDebugMonitorWindow = false end
	autoLoot.settings.showDebugMonitorWindow = not autoLoot.settings.showDebugMonitorWindow
	autoLoot.config.saveConfig("config/config.json", autoLoot.settings)
end)

function resetAutoLootStates()
	autoLoot.isContinuousLooting = false
	lastLootingActionStart = 0
	lastLootingActionState = false
	isCetKeyPressed = false
	isDefaultActionKeyPressed = false
end

return {modName = autoLoot.modName, modVer = autoLoot.modVer, modAuthorName = autoLoot.modAuthorName}