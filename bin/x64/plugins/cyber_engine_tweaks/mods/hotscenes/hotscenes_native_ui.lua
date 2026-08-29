-- May 22, 2026 by anygoodname
modVer='v2.19.3'
modName='Hotscenes NativeUI'
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

local Ref = require("Ref")
if not Ref then return end
local RefWeak = Ref.Weak

local stringLen = string.len
local mathFloor = math.floor

local tableInsert = table.insert
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

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

if cetVer < 1.26 then
	print(modName, modVer, "is not compatible with this game version. This module is disabled now.")
	return
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

local n, t
local gameVer, isGameV2, isGameV211andUp = 0, false, false
local isGameV22andUp

local nativeUI = {}
nativeUI.isShowtime = false
nativeUI.isMainMenu = false
nativeUI.isSelectionList = false
nativeUI.isBackToMainMenu = false
nativeUI.lastSelectionListReturn = {}
nativeUI.mainMenuController = {}
nativeUI.mainMenuPanelsWidget = nil
nativeUI.lastSelectionList = {}
nativeUI.activeInstances = {}

local lastShardPopupController = nil
local lastShardPopupNotificationData = nil
local lastShardTitleWidget = nil
local lastShardContentsWidget = nil
local lastTopBarIconWidget = nil
local lastSliderHandleWidget = nil
local lastSliderController = nil
local lastGameCursorController = nil
local lastSettingsMainGameController = nil
local lastPauseMenu = nil
local lastGameuiInGameMenuGameController = nil

local shardUiTitle = "Hotscenes Collection"
local shardUiText = "   "
local textWidthFactor = 0.5
local shardUiTitleTextWidget = nil
local windowTitle = "Hotscenes Collection"
local windowTitleWithAddOn = "Hotscenes Collection Plus"

local sceneModeIsInvalid = 0
local sceneModeIsDisabled = 1
local sceneModeIsInteractive = 2
local sceneModeIsOverride = 3
local sceneModeIsFastPlayback = 4
local sceneModeDesc = {"sceneModeIsDisabled", "sceneModeIsInteractive", "sceneModeIsOverride", "sceneModeIsFastPlayback"}

local playbackStateIsInvalid = 0
local playbackStateIsIdle = 1
local playbackStateIsCued = 2
local playbackStateIsPlayOnResume = 3
local playbackStateIsPlayPending = 4
local playbackStateIsPlaying = 5
local playbackStateIsReload = 6
local playbackStateIsActionUnavaliable = 7

local buttonDelay = 0.02
local delayedButtonActionCooldown = 0.15
local nextButtonActionAllowed = 0
local isDelayedButtonActionAllowed = true
local enableNativeSettingsIntegration = false
local switchToHotscenesSettingsMenu = 0

local currentGameUiLanguage = "en-us"
local isLeftToRightOrder = true

local isArchiveXLActive
local isPerformerPreviewSupported, isPreviewTriggerReactivatedInThisSession
local lastHudPhoneAvatarController

local godModeSystem, uiSystem, questsSystem
local isGameLoading
local isItMyShard
local isPerformerPreviewSupportEnabled

function isStringValid(input)
	if type(input) ~= 'string' then return end
	return stringLen(input) > 0
end

local isInitialized = false
nativeUI.onInit = function()
	nativeUI.isInitialized = isInitialized
	if isInitialized then return end

	n = CName
	t = TweakDBID

	isSameInstance = Game['OperatorEqual;IScriptableIScriptable;Bool'] -- (c)keanuWheeze
	n_world_map_menu_toggle_custom_filter = n"world_map_menu_toggle_custom_filter"

	gameVer = tonumber(Game.GetSystemRequestsHandler():GetGameVersion())
	isGameV2 = gameVer >= 2
	isGameV211andUp = gameVer >= 2.11
	isGameV22andUp = gameVer >= 2.2

	local lang = getSelectedGameUILanguage()
	if type(lang) == 'string' then currentGameUiLanguage = lang end

	pcall(function()
		if ArchiveXL then isArchiveXLActive = true end
	end)

	godModeSystem = Game.GetGodModeSystem()
	uiSystem = Game.GetUISystem()
	questsSystem = Game.GetQuestsSystem()
	setupNativeSettings()
	setupObservers()

	isInitialized = true
	nativeUI.isInitialized = isInitialized
	enableNativeSettingsIntegration = nativeUI.userSettings.enableNativeSettingsIntegration

	print(modName, modVer, "initialized.")
end

nativeUI.onShutdown = function()
	if not Game then return end
	if not GetPlayer then return end
	if hubMenuButtonDispose then hubMenuButtonDispose() end
	if not nativeUI.isShowtime then return end
	unregisterAllCallbacks()
	stopMenuMusic()
end

local nativeUiDefaultUiStrings = {
	nuiUiStrings = {
		exportOrder = {'nativeUiMenuView', 'nativeUiPanelView', 'nativeUiSelectionListView', 'nativeUiSettingsView', 'onscreenWarnings'},
		nativeUiMenuView = {
			exportOrder = {'menuWindowTitle', 'menuWindowTitleWithAddOn', 'buttons'},
			menuWindowTitle = "Hotscenes Collection",
			menuWindowTitleWithAddOn = "Hotscenes Collection Plus",
			buttons = {
				settings = {title = "Settings", tooltips = "Open Native Settings.'"},
			}
		},
		nativeUiPanelView = {
			exportOrder = {'fullSceneNames', 'buttons'},
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
			buttons = {
				override = {title = "(Override mode)", tooltips = ""},
				fast_playback = {title = "Fast Playback", tooltips = ""},
				reset = {title = "Reset", tooltips = ""},
				destination = {title = "scene default", tooltips = ""},
				cue = {title = "Cue scene", tooltips = ""},
				play = {title = "Play scene", tooltips = ""},
				play_on_resume = {title = "Play on game resume", tooltips = ""},
				play_pending = {title = "Play pending...", tooltips = ""},
				action_unavailable = {title = "Action unavailable", tooltips = ""},
				reload_last_save = {title = "Reload last save", tooltips = ""},
				reload_last_save_reloading = {title = "Reloading...", tooltips = ""},
				cancel = {title = "Cancel", tooltips = ""},
			},
		},
		nativeUiSelectionListView = {
			exportOrder = {'fullSceneNames', 'buttons', 'buttonHints'},
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
			buttons = {
				use_selected_item = {title = "Use selected", tooltips = ""},
				cancel = {title = "Cancel", tooltips = ""},
			},
			buttonHints = {
				showPreview = {title = "Show Preview"},
				hidePreview = {title = "Hide Preview"},
			}
		},
		nativeUiSettingsView = {
			exportOrder = {'modDisplayName', 'isModDisabledHeader', 'openModMenuHeader', 'openModMenu', 'generalSettingsHeader', 'extendHotscenes', 'sortByDisplayName', 'hideNpcSpecs', 'hideNpcFishnetTights', 'hideNpcSpikedChokers', 'spycamSettingsHeader', 'spycamOrbitPitchWithMouse', 'enableSpycamFreezeFrameToggleMode', 'invertMouseVertically', 'enableHotscenesButtonInHubMenu', 'enableNativeSettingsIntegration',
				'addonSettingsHeader', 'hotscenesAddOnNotDetected', 'hotscenesUnsupportedAddOnDetected', 'enableHotscenesAddon', 'enableSceneAvaliabilityOverride', 'enablePerformerPreviewSupport', 'noGameReloads',
				'enableSceneAvaliabilityOverrideNotSupported', 'enable_mq055_integration', 'mq055_integration_prefer_vanilla_appearances', 'enableNCDelightsFeature', 'enableNCDelightsDynamicMappins', 'enableNcSceneExtensions', 'restoreNpcDefaults',
			},

			modDisplayName = 'Hotscenes',

			isModDisabledHeader = 'This mod is disabled now. Please check the mod\'s CET window and the mod\'s log for more details.',

			openModMenuHeader = 'Open Hotscenes menu:',
			openModMenu = {title = "Open Hotscenes menu", tooltips = "Click to exit Settings menu and open the Hotscenes menu."},

			generalSettingsHeader = 'General settings:',
			extendHotscenes = {title = "Longer hotscenes playback", tooltips = "This option extends playback time and adds more variety to hotscenes."},
			hideNpcSpecs = {title = "Take off glasses.", tooltips = "When this option is enabled, engaged performers will take off glasses too.\nThis applies to the main menu scenes and the Night City Delights scenes (if Add-on is installed)."},
			hideNpcFishnetTights = {title = "Take off fishnet tights", tooltips = "When this option is enabled, engaged performers will take off fishnet tights too.\nThis applies to the main menu scenes and the Night City Delights scenes (if Add-on is installed)."},
			hideNpcSpikedChokers = {title = "Take off spiked chokers", tooltips = "When this option is enabled, engaged performers will take off spiked chokers too.\nThis applies to the main menu scenes and the Night City Delights scenes (if Add-on is installed)."},

			spycamSettingsHeader = 'Spycam settings:',
			spycamOrbitPitchWithMouse = {title = "Spycam orbit mode uses mouse for vertical control", tooltips = "In the Spycam orbit mode:\n-If enabled: use mouse up/down to control the spycam vertical position,\n use keyboard for forward/backward movement.\n-If disabled: use keyboard forward/backward to control the spycam vertical position,\n use mouse up/down for forward/backward movement."},
			enableSpycamFreezeFrameToggleMode = {title = "Spycam Freeze Frame button is a toggle", tooltips = "With this option enabled, the left mouse button toggles the Freeze Frame on and off.\nIf the option is disabled, the left mouse button freezes time only while pressed.\nNote: for safety reasons, the Freeze Frame will automatically toggle back\nin 60 seconds if you forget to switch it off."},
			invertMouseVertically = {title = "Invert Spycam mouse control vertically.", tooltips = "Inverts Spycam mouse control vertically."},
			enableHotscenesButtonInHubMenu = {title = "Enable Hotscenes Button in Hub Menu.", tooltips = "This option adds the Hotscenes button to the game\'s Hub menu, allowing you to open the Hotscenes main menu window.\nIf disabled, the Hotscenes menu is still accessible either through the CET overlay or via a keyboard shortcut, if defined in the CET Bindings window."},
			enableNativeSettingsIntegration = {title = "Enable Native Settings integration.", tooltips = "This option allows to open the mod\'s settings page in the Native Settings UI right from the mod Hotscenes Native UI menu."},

			addonSettingsHeader = 'Add-on settings:',
			hotscenesAddOnNotDetected = "Hotscenes Add-on is not detected. Extra features are not avaliable.";
			hotscenesUnsupportedAddOnDetected = "Unsupported Hotscenes Add-on is detected. Extra features are not avaliable. Please update the add-on.";

			enableHotscenesAddon = {title = "Enable Hotscenes Add-on", tooltips = "Enables extra features provided by Hotscenes Add-on.\nPlease note that the final feature set may vary depending on game versions\nand other mods that may affect the add-on."},
			enableSceneAvaliabilityOverride = {title = "Enable Hotscenes availability override", tooltips = "This feature allows playing scenes that the game has not yet made available.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough."},
			enableSceneAvaliabilityOverrideNotSupported = {title = "Hotscenes availability override (Disabled)", tooltips = "The currently installed add-on version does not support scenes availability overrides. Please update the add-on plugin."},
			enablePerformerPreviewSupport = {title = "Enable Performer Preview", tooltips = "This option enables the Performer Preview feature in the Native UI menu.\n\nPlease note that this feature requires the Add-on to be activated."},
			noGameReloads = {title = "Prefer no game reloads.", tooltips = "This option speeds up main menu scene startups and completions by skipping game reloads if the add-on is activated.\nPlease note that a recovery manual save will still be created."},
			sortByDisplayName = {title = "Sort performers by custom/translated names", tooltips = "Sort performer lists preferring custom or translated names if available.\nPlease note that results may not be accurate in non-Latin languages."},

			enable_mq055_integration = {title = "Enable Hangouts quests integration", tooltips = "This feature allows to integrate hotscenes playback with the game Hangouts quest scenes.\nNote: this feature will try to load the last game save upon scene playback completion\nto revert changes that could negatively affect your playthrough."},
			mq055_integration_prefer_vanilla_appearances = {title = "Prefer vanilla partner appearances in Hangouts", tooltips = "If this option is enabled, the mod will try to use vanilla appearances\nfor your partner if available, instead of Hotscenes exclusive appearances.\nThis option is designed to allow other mods change your partner\'s appearance."},
			enableNCDelightsFeature = {title = "Enable Night City Delights add-on", tooltips = "Enables Night City Delights scenes provided by the add-on."},
			enableNCDelightsDynamicMappins = {title = "Night City Delights: reveal nearby performers", tooltips = "When this option is enabled, nearby active performers will be indicated with markers."},
			enableNcSceneExtensions = {title = "Night City Delights: enable scene extensions", tooltips = "This option enables additional scene extensions if avaliable."},
			restoreNpcDefaults = {title = "Night City Delights: restore NPC defaults", tooltips = "This option aims to restore NPCs handled by this feature if their internal data is found affected or corrupted, possibly by other mods.\n\nFor the best results, please reload your game after enabling it.\n\nPlease note that enabling this option may prevent other mods from modifying these NPCs."},
		},
		onscreenWarnings = {
			exportOrder = {'hotscenesUnavailable', 'actionUnavailable'},
			hotscenesUnavailable = {
				header = "Hotscenes not available at the moment.",
				totalPerformersCount = "Performers not found.",
				isCensored = "The game is set to censored mode.",
				isEnding = "Not allowed in game Endings.",
				journalManagerMissing = "Code execution exception.",
				isAnyPerformerAvailable = "No active Performers found.",
				unknown = "Unknown reason.",
			},
			actionUnavailable = {
				header = "Hotscenes - Action unavailable.",
				isModDisabled = "The mod is disabled now.",
				isSavingLocked = "Game saving is currently prohibited.",
				inVehicle = "Not allowed in vehicles.",
				inWorkspot = "Not allowed in workspots.",
				inCombat = "Not allowed in Combat.",
				inRestrictedArea = "This area is restricted.",
				isJohnnyReplacer = "Not allowed as Johnny.",
				isPlayerPossessedByJohnny = "Posssesed by Johnny.",
				isWanted = "You\'re wanted by Police.",
				isHangoutsScene = "Not available in quest scenes.",
				isRestrictedState = "Prevented by game restrictions.",
				unknown = "Unknown reason.",
			}
		},
	},
}
nativeUI.nativeUiDefaultUiStrings = nativeUiDefaultUiStrings

local uiStrings = cloneTable(nativeUiDefaultUiStrings)
nativeUI.uiStrings = uiStrings

function nativeUI.updateUiStrings(newUiStrings)
	if type(newUiStrings) ~= 'table' then newUiStrings = nativeUI.nativeUiDefaultUiStrings end
	uiStrings = cloneTable(newUiStrings)
	nativeUI.uiStrings = uiStrings
end

local nativeSettings, isUsingNativeSettings, nativeSettingsIgnoreNextAction
local nativeSettingsOptions = {}
nativeUI.nativeSettingsOptions = nativeSettingsOptions
local nativeSettingsSubcategoryPaths
local modPath = '/'..modName
	
function setupNativeSettings(forceNew, showAll)
	isUsingNativeSettings = false
	nativeSettings = nativeSettings or GetMod("nativeSettings")
	nativeUI.nativeSettings = nativeSettings
	if not nativeSettings then return end
	if type(uiStrings) ~= 'table' then return end

	if not nativeSettingsSubcategoryPaths then nativeSettingsSubcategoryPaths = {mod_is_disabled = modPath.."/mod_is_disabled", open_hotscenes_menu = modPath.."/open_hotscenes_menu", general_settings = modPath.."/general_settings", spycam_settings = modPath.."/spycam_settings", addon_settings = modPath.."/addon_settings"} end
	local nativeSettingsDisplayName = uiStrings.nuiUiStrings.nativeUiSettingsView.modDisplayName

	if forceNew and nativeSettings.pathExists(modPath) then
		if type(nativeSettingsSubcategoryPaths) == 'table' then
			for _, path in pairs(nativeSettingsSubcategoryPaths) do
				nativeSettings.removeSubcategory(path)
			end
		end
		local path = modPath:gsub("/", "")
		nativeSettings.data[path] = nil
		nativeSettingsOptions = {} nativeUI.nativeSettingsOptions = nativeSettingsOptions
		nativeSettingsIgnoreNextAction = false
	end
	isUsingNativeSettings = true
	if not nativeSettings.fromMods then return end
	if not nativeSettings.pathExists(modPath) then nativeSettings.addTab(modPath, nativeSettingsDisplayName) end
	if nativeSettings.pathExists(modPath) then isUsingNativeSettings = true else isUsingNativeSettings = false return end

	local buttonTitle, buttonTooltips = '', ''

	if nativeUI.isModDisabled then
		local buttonsPath = nativeSettingsSubcategoryPaths.mod_is_disabled
		nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.isModDisabledHeader)
		return
	end

	if IsDefined(lastSettingsMainGameController) and IsDefined(lastPauseMenu) and nativeUI.isHotscenesAvailable() and nativeUI.isHotscenesAllowed() then
		local buttonsPath = nativeSettingsSubcategoryPaths.open_hotscenes_menu
		nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.openModMenuHeader)

		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.openModMenu.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.openModMenu.tooltips
		nativeSettingsOptions.openModMenu = nativeSettings.addButton(buttonsPath, buttonTitle, buttonTooltips, "Hotscenes", 48, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			if type(nativeUI.forceUpdateScenePerformersByPanelLogic) == 'function' then nativeUI.forceUpdateScenePerformersByPanelLogic() else nativeUI.updatePerformers() end
			local timeout = os.clock() + 10
			local payload = function()
				lastSettingsMainGameController:RequestClose()
				local payload = function()
					lastPauseMenu:OnClosePauseMenu()
					local payload = function()
						if os.clock() > timeout then return true end
						if Game.GetSystemRequestsHandler():IsGamePaused() then return end
						local result, blackboardSystem = pcall(function() return Game.GetBlackboardSystem():Get(Game.GetAllBlackboardDefs().UI_System) end)
						if result and IsDefined(blackboardSystem) and blackboardSystem:GetBool(Game.GetAllBlackboardDefs().UI_System.IsInMenu) then return end
						nativeUI.queueTask(launchMainMenu, false, 0.01)
						return true
					end
					nativeUI.queueTask(payload, false, 0.05, 0.001, false)
				end
				nativeUI.queueTask(payload, false, 0.01)
			end
			nativeUI.queueTask(payload, false, buttonDelay)
		end)
		if type(nativeSettingsOptions.openModMenu) == 'table' then nativeSettingsOptions.openModMenu.isOpenModMenuButton = true end
	end

	local buttonsPath = nativeSettingsSubcategoryPaths.general_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.generalSettingsHeader)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.extendHotscenes.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.extendHotscenes.tooltips
	nativeSettingsOptions.extendHotscenes = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.extendHotscenes, nativeUI.defaultUserSettings.extendHotscenes, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.extendHotscenes = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.sortByDisplayName.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.sortByDisplayName.tooltips
	nativeSettingsOptions.sortByDisplayName = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.sortByDisplayName, nativeUI.defaultUserSettings.sortByDisplayName, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.sortByDisplayName = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcSpecs.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcSpecs.tooltips
	nativeSettingsOptions.hideNpcSpecs = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.hideNpcSpecs, nativeUI.defaultUserSettings.hideNpcSpecs, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.hideNpcSpecs = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcFishnetTights.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcFishnetTights.tooltips
	nativeSettingsOptions.hideNpcFishnetTights = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.hideNpcFishnetTights, nativeUI.defaultUserSettings.hideNpcFishnetTights, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.hideNpcFishnetTights = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcSpikedChokers.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.hideNpcSpikedChokers.tooltips
	nativeSettingsOptions.hideNpcSpikedChokers = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.hideNpcSpikedChokers, nativeUI.defaultUserSettings.hideNpcSpikedChokers, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.hideNpcSpikedChokers = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableHotscenesButtonInHubMenu.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableHotscenesButtonInHubMenu.tooltips
	nativeSettingsOptions.enableHotscenesButtonInHubMenu = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableHotscenesButtonInHubMenu, nativeUI.defaultUserSettings.enableHotscenesButtonInHubMenu, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.enableHotscenesButtonInHubMenu = newState
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNativeSettingsIntegration.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNativeSettingsIntegration.tooltips
	nativeSettingsOptions.enableNativeSettingsIntegration = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableNativeSettingsIntegration, nativeUI.defaultUserSettings.enableNativeSettingsIntegration, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.enableNativeSettingsIntegration = newState
		enableNativeSettingsIntegration = nativeUI.userSettings.enableNativeSettingsIntegration
		nativeUI.saveUserSettings()
	end)

	local buttonsPath = nativeSettingsSubcategoryPaths.spycam_settings
	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.spycamSettingsHeader)
	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.spycamOrbitPitchWithMouse.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.spycamOrbitPitchWithMouse.tooltips
	nativeSettingsOptions.spycamOrbitPitchWithMouse = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.spycamOrbitPitchWithMouse, nativeUI.defaultUserSettings.spycamOrbitPitchWithMouse, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.spycamOrbitPitchWithMouse = newState
		if type(nativeUI.updateSpycamParameters) == 'function' then nativeUI.updateSpycamParameters() end
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSpycamFreezeFrameToggleMode.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSpycamFreezeFrameToggleMode.tooltips
	nativeSettingsOptions.enableSpycamFreezeFrameToggleMode = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableSpycamFreezeFrameToggleMode, nativeUI.defaultUserSettings.enableSpycamFreezeFrameToggleMode, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.enableSpycamFreezeFrameToggleMode = newState
		if type(nativeUI.updateSpycamParameters) == 'function' then nativeUI.updateSpycamParameters() end
		nativeUI.saveUserSettings()
	end)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.invertMouseVertically.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.invertMouseVertically.tooltips
	nativeSettingsOptions.invertMouseVertically = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.invertMouseVertically, nativeUI.defaultUserSettings.invertMouseVertically, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.invertMouseVertically = newState
		if type(nativeUI.updateSpycamParameters) == 'function' then nativeUI.updateSpycamParameters() end
		nativeUI.saveUserSettings()
	end)

	if (not showAll) and (not nativeUI.getOverridesArchiveState) then return end

	local buttonsPath = nativeSettingsSubcategoryPaths.addon_settings
	local isOverridesArchiveDetected, isUnsupportedOverridesArchiveDetected, isOverridesArchiveSupportingSceneAvailabilityOverride = nativeUI.getOverridesArchiveState()

	if not showAll then
		if not isOverridesArchiveDetected then
			if isUnsupportedOverridesArchiveDetected then
				nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.hotscenesUnsupportedAddOnDetected)
			else
				nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.hotscenesAddOnNotDetected)
			end
			return
		end
	end

	nativeSettings.addSubcategory(buttonsPath, uiStrings.nuiUiStrings.nativeUiSettingsView.addonSettingsHeader)

	buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableHotscenesAddon.title
	buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableHotscenesAddon.tooltips
	nativeSettingsOptions.enableHotscenesAddon = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableHotscenesAddon, nativeUI.defaultUserSettings.enableHotscenesAddon, function(newState)
		if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
		nativeUI.userSettings.enableHotscenesAddon = newState
		if type(nativeUI.forceUpdateScenePerformersByPanelLogic) == 'function' then nativeUI.forceUpdateScenePerformersByPanelLogic() else nativeUI.updatePerformers() end
		if nativeUI.nc_delights and type(nativeUI.nc_delights.shouldAllowActivity) == 'function' then nativeUI.nc_delights.shouldAllowActivity(true) end
		nativeUI.saveUserSettings()
		local payload = function() setupNativeSettings(true) end
		nativeUI.queueTask(payload, false, 0.01)
	end)

	if (not showAll) and (not nativeUI.userSettings.enableHotscenesAddon) then return end

	if showAll or isOverridesArchiveSupportingSceneAvailabilityOverride then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSceneAvaliabilityOverride.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSceneAvaliabilityOverride.tooltips
		nativeSettingsOptions.enableSceneAvaliabilityOverride = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableSceneAvaliabilityOverride, nativeUI.defaultUserSettings.enableSceneAvaliabilityOverride, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.enableSceneAvaliabilityOverride = newState
			if type(nativeUI.forceUpdateScenePerformersByPanelLogic) == 'function' then nativeUI.forceUpdateScenePerformersByPanelLogic() else nativeUI.updatePerformers() end
			nativeUI.saveUserSettings()
		end)
	else
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSceneAvaliabilityOverrideNotSupported.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableSceneAvaliabilityOverrideNotSupported.tooltips
		nativeSettingsOptions.enableSceneAvaliabilityOverrideNotSupported = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, false, false, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			if newState then
				local bounceBack = function()
					nativeSettings.setOption(nativeSettingsOptions.enableSceneAvaliabilityOverrideNotSupported, false)
				end
				nativeUI.queueTask(bounceBack, false, 0.15)
			end
			return
		end)
	end

	if showAll or (isArchiveXLActive and isOverridesArchiveDetected and isPerformerPreviewSupported and isKnownName("mod_hotscenes_performer_preview_available")) then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enablePerformerPreviewSupport.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enablePerformerPreviewSupport.tooltips
		nativeSettingsOptions.enablePerformerPreviewSupport = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enablePerformerPreviewSupport, nativeUI.defaultUserSettings.enablePerformerPreviewSupport, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.enablePerformerPreviewSupport = newState
			if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
			nativeUI.saveUserSettings()
		end)
	end

	if showAll or (isArchiveXLActive and isOverridesArchiveDetected and isKnownName("mod_hotscenes_no_game_reload_support_available")) then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.noGameReloads.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.noGameReloads.tooltips
		nativeSettingsOptions.noGameReloads = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.noGameReloads, nativeUI.defaultUserSettings.noGameReloads, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.noGameReloads = newState
			if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
			nativeUI.saveUserSettings()
		end)
	end

	if showAll or nativeUI.is_mq055_hangouts_interaction_activated() then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enable_mq055_integration.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enable_mq055_integration.tooltips
		nativeSettingsOptions.enable_mq055_integration = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enable_mq055_integration, nativeUI.defaultUserSettings.enable_mq055_integration, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.enable_mq055_integration = newState
			nativeUI.saveUserSettings()
			local payload = function() setupNativeSettings(true) end
			nativeUI.queueTask(payload, false, 0.01)
		end)

		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.mq055_integration_prefer_vanilla_appearances.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.mq055_integration_prefer_vanilla_appearances.tooltips
		nativeSettingsOptions.mq055_integration_prefer_vanilla_appearances = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.mq055_integration_prefer_vanilla_appearances, nativeUI.defaultUserSettings.mq055_integration_prefer_vanilla_appearances, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.mq055_integration_prefer_vanilla_appearances = newState
			nativeUI.saveUserSettings()
		end)
	end

	if showAll or (nativeUI.nc_delights and isArchiveXLActive and isKnownName("Hotscenes_overrides_mod_nc_delights_supported")) then
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNCDelightsFeature.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNCDelightsFeature.tooltips
		nativeSettingsOptions.enableNCDelightsFeature = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableNCDelightsFeature, nativeUI.defaultUserSettings.enableNCDelightsFeature, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.enableNCDelightsFeature = newState
			if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
			nativeUI.saveUserSettings()
		end)
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNCDelightsDynamicMappins.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNCDelightsDynamicMappins.tooltips
		nativeSettingsOptions.enableNCDelightsDynamicMappins = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableNCDelightsDynamicMappins, nativeUI.defaultUserSettings.enableNCDelightsDynamicMappins, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.enableNCDelightsDynamicMappins = newState
			if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
			nativeUI.saveUserSettings()
		end)
		if showAll or isKnownName("Hotscenes_overrides_nc_delights_extensions_supported") then
			buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNcSceneExtensions.title
			buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.enableNcSceneExtensions.tooltips
			nativeSettingsOptions.enableNcSceneExtensions = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.enableNcSceneExtensions, nativeUI.defaultUserSettings.enableNcSceneExtensions, function(newState)
				if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
				nativeUI.userSettings.enableNcSceneExtensions = newState
				if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
				nativeUI.saveUserSettings()
			end)
		end
		buttonTitle = uiStrings.nuiUiStrings.nativeUiSettingsView.restoreNpcDefaults.title
		buttonTooltips = uiStrings.nuiUiStrings.nativeUiSettingsView.restoreNpcDefaults.tooltips
		nativeSettingsOptions.restoreNpcDefaults = nativeSettings.addSwitch(buttonsPath, buttonTitle, buttonTooltips, nativeUI.userSettings.restoreNpcDefaults, nativeUI.defaultUserSettings.restoreNpcDefaults, function(newState)
			if nativeSettingsIgnoreNextAction then nativeSettingsIgnoreNextAction = false return end
			nativeUI.userSettings.restoreNpcDefaults = newState
			if nativeUI.nc_delights then nativeUI.nc_delights.updateSettings() end
			nativeUI.saveUserSettings()
			nativeUI.nc_delights.scheduleGameNpcRecordsVerification(nativeUI.userSettings.restoreNpcDefaults)
		end)
	end
end
nativeUI.setupNativeSettings = setupNativeSettings

function updateNativeSettingsOption(optionName, newValue, updateDisplayOnly)
	if nativeUI.userSettings and type(nativeUI.userSettings.enableNativeSettingsIntegration) == 'boolean' then
		enableNativeSettingsIntegration = nativeUI.userSettings.enableNativeSettingsIntegration
		if nativeUI.mainMenuController.buttons and nativeUI.mainMenuController.buttons.settings then nativeUI.mainMenuController.buttons.settings.setVisible(isUsingNativeSettings and enableNativeSettingsIntegration) end
	end
	if not isUsingNativeSettings then return end
	if not nativeSettings.fromMods then return end
	if type(optionName) ~= 'string' then return end
	if not (type(newValue) == 'boolean' or type(newValue) == 'number') then return end
	local option = nativeSettingsOptions[optionName]
	if not option then return end
	if not IsDefined(option.controller) then return end
	nativeSettingsIgnoreNextAction = false
	if updateDisplayOnly then nativeSettingsIgnoreNextAction = true end
	local isUpValue = false
	local oldValue = option.controller.newValue
	if type(oldValue) == 'number' then isUpValue = newValue > oldValue else isUpValue = newValue end
	option.controller:AcceptValue(newValue)
	if isUpValue then
		option.controller:PlaySound(n"ButtonValueDown", n"OnPress");
	else
		option.controller:PlaySound(n"ButtonValueUp", n"OnPress");
	end
end
nativeUI.updateNativeSettingsOption = updateNativeSettingsOption

local selectionListNativeUITemplate = {
	title = "Select Performer",
	sceneData = {},
	sceneId = 0,
	selectionListAreaWidget = nil,
	isScenePanel = false,
	isSelectionList = true,
	isPerformerSelectionList = true,
	isDestinationSelectionList = false,
	isEnabled = true,
	setVisible = function() end,
	getScreenPosition = function() end,
	eventCatcher = nil,
	activeTextColor = "MainColors.Neutral",
	inactiveTextColor = "MainColors.MildBlue",
	highlightTextColor = "MainColors.White",
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
	restoreParentWidget = function() end,
	returnToMainMenu = function() end,
	onReturnToMainMenu = function() end,
	list_separator_line = {name = "list_separator_line", title = "", isEnabled = true, type = "border", widget = nil, marginTop = 2, marginBottom = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end},
	buttonsAreaWidget = nil,
	buttons = {
		scene_name = {name = "scene_name", title = "Scene Name", itemIndex = 0, isInteractiveButton = false, isEnabled = true, isActive = true, type = "text", widget = nil, isUpperCase = false, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end},
		separator_line = {name = "separator_line", title = "", itemIndex = 0, isInteractiveButton = false, isEnabled = true, isActive = true, type = "border", widget = nil, marginTop = 2, marginBottom = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end},
		selected_item = {name = "selected_item", title = "No item selected.", isInteractiveButton = false, itemIndex = 0, isEnabled = true, isActive = true, type = "text", widget = nil, isUpperCase = false, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end},
		use_selected_item = {name = "use_selected_item", title = "Use selected", isInteractiveButton = true, itemIndex = 0, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		cancel = {name = "cancel", title = "Cancel", itemIndex = 0, isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
	},
	sidePanelButtons = {'scene_name', 'separator_line', 'selected_item', 'use_selected_item', 'cancel'}	
}

function createSelectionList(thisScene, callerId, isPerformerSelectionList, inputItemList, initialSelectedItemIndex, parentWidget, thisList, listWidth, fontSize)
	nativeUI.isSelectionList = false
	if type(inputItemList) ~= 'table' then return false end
	if #inputItemList < 1 then return false end
	if not IsDefined(parentWidget) then return end

	if type(thisList) ~= 'table' then thisList = cloneTable(selectionListNativeUITemplate) end
	if not thisList then return end

	if type(thisScene) == 'table' then thisList.sceneData = thisScene end

	thisList.sceneId = thisList.sceneData.id
	thisList.callerId = callerId

	if isPerformerSelectionList then
		thisList.isPerformerSelectionList = true
		thisList.isDestinationSelectionList = false
	else
		thisList.isPerformerSelectionList = false
		thisList.isDestinationSelectionList = true
	end

	thisList.parentWidget = parentWidget
	thisList.parentContentArea = getTopWigetByName(parentWidget, 'contentArea')
	if not IsDefined(thisList.parentContentArea) then return end
	thisList.listScrollAreaWidget = thisList.parentContentArea:GetWidget('EntryScrollArea')
	if not (thisList.listScrollAreaWidget and thisList.listScrollAreaWidget:IsA('inkScrollAreaWidget')) then return end

	if type(fontSize) ~= 'number' or fontSize < 10 then fontSize = 48 end
	if type(listWidth) == 'number' and listWidth > fontSize * 10 then thisList.listWidth = listWidth end

	thisList.selectionListAreaWidget = inkVerticalPanelWidget.new()
	thisList.selectionListAreaWidget:SetName('selectionListAreaWidget') CName.add("selectionListAreaWidget")
	thisList.selectionListAreaWidget:SetAnchor(inkEAnchor.TopLeft)
	thisList.setVisible = function(show) if type(show) ~= 'boolean' then return end thisList.selectionListAreaWidget:SetVisible(show) thisList.isEnabled = show return true end
	if not thisList.isEnabled then thisList.setVisible(false) end
	thisList.getScreenPosition = function() return GetScreenPosition(thisList.selectionListAreaWidget) end

	thisList.buttonsAreaWidget = inkVerticalPanelWidget.new()
	thisList.buttonsAreaWidget:SetName('buttonsAreaWidget') CName.add("buttonsAreaWidget")

	local activeTextColor = thisList.activeTextColor
	local inactiveTextColor = thisList.inactiveTextColor

	local buttonWidthSyncGroups = {}

	thisList.listItemHeight = RoundF(fontSize * 1.75)

	local buttonAnchorPoint = {0, 0}
	local buttonSize = {thisList.listWidth, thisList.listItemHeight}

	local lastButtonIndex = #thisList.sidePanelButtons
	local buttonSpacing = mathFloor(fontSize/3)
	local isTopButton = true
	for i = 1, lastButtonIndex do
		local buttonData = thisList.buttons[thisList.sidePanelButtons[i]]
		if not buttonData.name then buttonData.name = "button_"..tostring(i) end

		local buttonArea = thisList.buttonsAreaWidget
		local finalLabelText = buttonData.title or "New Button"
		if uiStrings.nuiUiStrings.nativeUiSelectionListView.buttons[buttonData.name] then
			local localizedButtonTitle = uiStrings.nuiUiStrings.nativeUiSelectionListView.buttons[buttonData.name].title
			if type(localizedButtonTitle) == 'string' and stringLen(localizedButtonTitle) > 0 then finalLabelText = localizedButtonTitle end
		end

		buttonData.setActive = function(activate)
			if type(activate) ~= 'boolean' then return end
			if activate then
				if buttonData.isInteractiveButton then buttonData.widget:SetInteractive(true) end
				buttonData.isActive = true
				setWidgetTextLabelColor(buttonData.widgetLabel, activeTextColor)
				return true
			end
			buttonData.widget:SetInteractive(false)
			buttonData.isActive = false
			setWidgetTextLabelColor(buttonData.widgetLabel, inactiveTextColor)
			return true
		end

		local isButton = false
		if buttonData.type == 'text' then
			if buttonData.name == "scene_name" and type(thisList.sceneData.displayName) == 'string' then
				finalLabelText = thisList.sceneData.displayName
				if thisScene.gender == 'female' then finalLabelText = finalLabelText.." Female" else finalLabelText = finalLabelText.." Male" end
				if thisScene.sceneName and uiStrings.nuiUiStrings.nativeUiSelectionListView.fullSceneNames[thisScene.gender] then
					local localizedFullSceneName = uiStrings.nuiUiStrings.nativeUiSelectionListView.fullSceneNames[thisScene.gender][thisScene.sceneName]
					if type(localizedFullSceneName) == 'string' and stringLen(localizedFullSceneName) > 0 then finalLabelText = localizedFullSceneName end
				end
			end
			if not isPerformerSelectionList and buttonData.name == "list_header" then finalLabelText = buttonData.title_destination end
			buttonData.widget = createTextLabel(buttonData.name, finalLabelText, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, buttonData.isUpperCase)
			buttonData.widgetLabel = buttonData.widget
		elseif buttonData.type == 'border' then
			buttonData.widget = createBottomBorderLineWithMargin(buttonData.name, 0, buttonData.marginBottom, thisList.listWidth)
			buttonData.setVisible = function(show) if type(show) ~= 'boolean' then return end listSeparator.widget:SetVisible(show) listSeparator.isEnabled = show return true end
		else
			isButton = true
			buttonData.widget, buttonData.widgetLabel = createButton(buttonData.name, finalLabelText, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, buttonData.isUpperCase)
			if not buttonData.isInteractiveButton then SetInteractive(false) end
			if buttonData.type == 'switch' then
				buttonData.widget:GetWidget("switch_icon"):SetOpacity(1)
				buttonData.setSwitchState = function(isSwitchOn)
					if type(isSwitchOn) ~= 'boolean' then return end
					buttonData.isSwitchOn = isSwitchOn
					if isSwitchOn then buttonData.widget:GetWidget("switch_icon"):SetTexturePart('ico_device_on') return end
					buttonData.widget:GetWidget("switch_icon"):SetTexturePart('ico_device_off')
				end
				buttonData.setSwitchState(buttonData.isSwitchOn)
			end
		end
		if not buttonData.isActive then buttonData.setActive(false) end
		buttonData.itemIndex = i

		buttonData.setText = function(text) if type(text) ~= 'string' then return end if not isStringValid(text) then return end buttonData.widgetLabel:SetText(text) return true end
		buttonData.setVisible = function(show) if type(show) ~= 'boolean' then return end buttonData.widget:SetVisible(show) buttonData.isEnabled = show return true end
		if not buttonData.isEnabled then buttonData.setVisible(false) end
		buttonData.getScreenPosition = function() return GetScreenPosition(buttonData.widget) end

		if isButton and isTopButton then
			buttonData.widget:SetMargin(0, buttonSpacing, 0, buttonSpacing)
		else
			if i ~= lastButtonIndex then
				buttonData.widget:SetMargin(0, 0, 0, buttonSpacing)
			end
		end
		if isButton then isTopButton = false end

		buttonData.widget:Reparent(buttonArea, -1)
	end

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
				return true
			end
			newItem.widget:SetInteractive(false)
			newItem.isActive = false
			setWidgetTextLabelColor(newItem.widgetLabel, inactiveTextColor)
			return true
		end

		newItem.title = finalLabelText
		newItem.widget, newItem.widgetLabel = createButton(newItem.name, newItem.title, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, newItem.isUpperCase)
		if not newItem.isInteractiveButton then SetInteractive(false) end
		if not newItem.isActive then newItem.setActive(false) end

		newItem.setText = function(text, labelOnly) if type(text) ~= 'string' then return end if not isStringValid(text) then return end newItem.widgetLabel:SetText(text) if labelOnly then return end newItem.title = text return true end
		newItem.widgetLabel:SetAnchor(inkEAnchor.LeftFillVerticaly)
		newItem.widgetLabel:SetMargin(mathFloor(fontSize * 1.4), 0, 0, 0)

		newItem.setVisible = function(show) if type(show) ~= 'boolean' then return end newItem.widget:SetVisible(show) newItem.isEnabled = show return true end
		if not newItem.isEnabled then newItem.setVisible(false) end
		newItem.getScreenPosition = function() return GetScreenPosition(newItem.widget) end

		newItem.setSelected = function(isSelected)
			if not newItem.isActive then return end
			if type(isSelected) ~= 'boolean' then return end
			if isSelected then
				newItem.widget:GetWidget('fill'):SetOpacity(0.03)
				newItem.widget:GetWidget('frame'):SetOpacity(1.0)
				newItem.widget:GetWidget('bg'):SetOpacity(0.8)
				newItem.isSelected = true
				return true
			end
			newItem.widget:GetWidget('fill'):SetOpacity(0.0)
			newItem.widget:GetWidget('frame'):SetOpacity(0.0)
			newItem.widget:GetWidget('bg'):SetOpacity(0.0)
			newItem.isSelected = false
			return true
		end
		newItem.setSelected(false)

		newItem.setAccepted = function(isAccepted, isThisButtonUpdate)
			local checkMark = newItem.widget:GetWidget('check_mark_icon')
			if not checkMark then return end
			if checkMark.name.value ~= 'check_mark_icon' then return end
			newItem.isAccepted = checkMark:GetOpacity() >= 1
			local shouldUpdateAllItems = isAccepted and newItem.isAccepted ~= isAccepted
			if isAccepted then checkMark:SetOpacity(1) else checkMark:SetOpacity(0) end
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
		newItem.onReleased = function(isMouseClick)
			if isMouseClick then lastClicked = nextClicked end
			nextClicked = os.clock()
			local restoreLastPerformerPreviewShowTime = nativeUI.isPerformerPreviewShowTime
			local isSameIndex = thisList.selectedItemIndex == newItem.itemIndex

			if isSameIndex then 
				nativeUI.isPerformerPreviewShowTime = false
			end
			thisList.selectItem(newItem.itemIndex, true, false)
			nativeUI.isPerformerPreviewShowTime = restoreLastPerformerPreviewShowTime
			if not isSameIndex then return end

			if not isMouseClick then thisList.buttons.use_selected_item.onReleased() return end

			if nextClicked - lastClicked < 0.5 and isSameIndex then
				thisList.buttons.use_selected_item.onReleased()
			end
		end

		if newItem.itemIndex == 1 then
			local listSeparator = cloneTable(thisList.list_separator_line)
			listSeparator.widget = createBottomBorderLineWithMargin(listSeparator.name.."_0", 0, listSeparator.marginBottom, thisList.listWidth, "MainColors.MildRed")
			listSeparator.setVisible = function(show) if type(show) ~= 'boolean' then return end listSeparator.widget:SetVisible(show) listSeparator.isEnabled = show return true end
			if not listSeparator.isEnabled then listSeparator.setVisible(false) end
			listSeparator.widget:Reparent(thisList.selectionListAreaWidget, -1)
		end

		newItem.widget:Reparent(thisList.selectionListAreaWidget, -1)
		local listSeparator = cloneTable(thisList.list_separator_line)
		listSeparator.widget = createBottomBorderLineWithMargin(listSeparator.name.."_"..tostring(newItem.itemIndex), listSeparator.marginTop, listSeparator.marginBottom, thisList.listWidth, "MainColors.MildRed")
		listSeparator.setVisible = function(show) if type(show) ~= 'boolean' then return end listSeparator.widget:SetVisible(show) listSeparator.isEnabled = show return true end
		if not listSeparator.isEnabled then listSeparator.setVisible(false) end
		listSeparator.widget:Reparent(thisList.selectionListAreaWidget, -1)
	end
	thisList.itemCount = #thisList.items

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
		if thisList.lastSelectedObject.itemIndex == thisList.initialSelectedItemIndex then
			thisList.buttons.selected_item.setText(itemToSelect.title)
			thisList.lastSelectedObject.setAccepted(true)
		else
			thisList.buttons.selected_item.setText("• "..itemToSelect.title)
		end
		if thisList.isPerformerSelectionList then
			updatePerformerPreviewLabel(itemToSelect.title)
			if isPerformerPreviewAvailable() then
				setupPerformerPreviewCharacters(thisList.selectedItemIndex, thisList.sceneData)
				if nativeUI.userSettings.keepShowingPerformerPreview then togglePerformerPreview(true, true) end
			end
		end
		if shouldUpdateAllItems then for i = 1, #thisList.items do if i ~= itemIndex then thisList.items[i].setSelected(false) end end end
		if scrollListToItem then thisList.scrollToSelectedItem(addRowMargin, centerOnSelected) end
	end

	thisList.getSelectedItem = function()
		if thisList.selectedItemIndex < 1 then return end
		return thisList.items[thisList.selectedItemIndex]
	end

	thisList.deselectAll = function()
		for i = 1, #thisList.items do thisList.items[i].setSelected(false) end
		thisList.selectedItemIndex = 0
	end

	if IsDefined(lastSliderController) then
		thisList.listScrollAreaSliderController = lastSliderController
		for i = 0, thisList.parentContentArea:GetNumChildren() -1 do
			local child = thisList.parentContentArea:GetWidget(i)
			local childController = child:GetController()
			if IsDefined(childController) and childController:IsA('inkSliderController') then
				thisList.listScrollAreaSliderController = childController
				thisList.originalScrollAreaSliderControllerProgress = thisList.listScrollAreaSliderController:GetProgress()
				thisList.originalSlidingAreaWidgetMargin = thisList.listScrollAreaSliderController.slidingAreaWidgetRef:GetMargin()
				break
			end
		end
	end

	local parentContentWidgetMargin = thisList.parentContentArea:GetMargin()
	thisList.originalContentWidgetMargin = parentContentWidgetMargin

	thisList.restoreParentWidget = function()
		if not thisList.originalContentWidgetMargin then return end
		if not IsDefined(thisList.parentContentArea) then return end
		thisList.parentContentArea:RemoveChild(thisList.buttonsAreaWidget)
		thisList.parentContentArea:SetMargin(thisList.originalContentWidgetMargin)

		if thisList.originalScrollAreaSliderControllerProgress and IsDefined(thisList.listScrollAreaSliderController) then
			thisList.listScrollAreaSliderController.slidingAreaWidgetRef:SetVisible(false)
			local payload = function()
				thisList.listScrollAreaSliderController.slidingAreaWidgetRef:SetVisible(true)
				thisList.listScrollAreaSliderController:ChangeProgress(thisList.originalScrollAreaSliderControllerProgress)
				thisList.listScrollAreaSliderController.slidingAreaWidgetRef:SetMargin(thisList.originalSlidingAreaWidgetMargin)
			end
			nativeUI.queueTask(payload, false, 0.005)
		end
	end

	if isLeftToRightOrder then
		local leftButtonAreaMargin = thisList.listWidth + mathFloor(1.5 * parentContentWidgetMargin.left)
		local rightButtonAreaMargin = -thisList.listWidth + mathFloor(0.75 * parentContentWidgetMargin.left)
		thisList.buttonsAreaWidget:SetMargin(leftButtonAreaMargin, 0, rightButtonAreaMargin, 0)
	else
		thisList.buttonsAreaWidget:SetMargin(30, 0, 100, 0)
	end
	thisList.buttonsAreaWidget:Reparent(thisList.parentContentArea, -1)
	if isLeftToRightOrder then
		thisList.parentContentArea:SetMargin(parentContentWidgetMargin.left, parentContentWidgetMargin.top, thisList.listWidth + fontSize, parentContentWidgetMargin.bottom)
		thisList.listScrollAreaSliderController.slidingAreaWidgetRef:SetMargin(0, 0, -30, 0)
	else
		thisList.parentContentArea:SetMargin(thisList.listWidth + fontSize, parentContentWidgetMargin.top, parentContentWidgetMargin.left, parentContentWidgetMargin.bottom)
		thisList.listScrollAreaSliderController.slidingAreaWidgetRef:SetMargin(50, 0, -80, 0)
	end

	thisList.scrollToSelectedItem = function(addRowMargin, centerOnSelected)
		if thisList.selectedItemIndex < 1 then return end
		if thisList.itemCount < 1 then return end
		local selectedItem = thisList.items[thisList.selectedItemIndex]
		if not selectedItem then return end
		local scrollAreaWidget = thisList.listScrollAreaWidget
		if not IsDefined(scrollAreaWidget) then return end
		local sliderController = thisList.listScrollAreaSliderController
		if not IsDefined(sliderController) then return end
		if not sliderController:GetRootCompoundWidget():IsVisible() then return end

		local selectedItemWidgetScreenPosition = selectedItem.getScreenPosition()
		local scrollAreaWidgetScreenPosition = GetScreenPosition(scrollAreaWidget)
		local isSelectedItemWithinViewport = scrollAreaWidgetScreenPosition.Top <= selectedItemWidgetScreenPosition.Top and selectedItemWidgetScreenPosition.Bottom <= scrollAreaWidgetScreenPosition.Bottom
		if isSelectedItemWithinViewport then return end
		if selectedItemWidgetScreenPosition.Top < scrollAreaWidgetScreenPosition.Top then
			if thisList.selectedItemIndex == 1 then
				sliderController:ChangeProgress(0)
				return true
			end

			local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
			if scrollAreaWidgetViewportHeight == 0 then return end
			local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
			if selectionListAreaWidgetHeight == 0 then return end
			local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
			local rowsPerPage = scrollAreaWidgetViewportHeight/itemRowHeight
			local topRow = thisList.selectedItemIndex -1
			if centerOnSelected then
				topRow = topRow - mathFloor(rowsPerPage) + 1
			elseif addRowMargin then topRow = topRow - 1 end
			local topVisibleRowPos = itemRowHeight * topRow
			local scrollRatio = getScrollRatio(scrollAreaWidgetViewportHeight, selectionListAreaWidgetHeight, topVisibleRowPos)
			sliderController:ChangeProgress(scrollRatio)
			return true
		else
			local scrollAreaWidgetViewportHeight = scrollAreaWidget:GetViewportSize().Y
			if scrollAreaWidgetViewportHeight == 0 then return end
			local selectionListAreaWidgetHeight = thisList.selectionListAreaWidget:GetDesiredSize().Y
			if selectionListAreaWidgetHeight == 0 then return end
			local itemRowHeight = selectionListAreaWidgetHeight/thisList.itemCount
			local rowsPerPage = scrollAreaWidgetViewportHeight/itemRowHeight
			local topRow = thisList.selectedItemIndex - rowsPerPage
			if centerOnSelected then
				topRow = topRow + mathFloor(rowsPerPage) - 1
			elseif addRowMargin then topRow = topRow + 1 end
			local topVisibleRowPos = itemRowHeight * topRow
			local scrollRatio = getScrollRatio(scrollAreaWidgetViewportHeight, selectionListAreaWidgetHeight, topVisibleRowPos)
			sliderController:ChangeProgress(scrollRatio)
			return true
		end
	end

	if initialSelectedItemIndex > 0 then
		thisList.initialSelectedItemIndex = initialSelectedItemIndex
		local initialSelectedItemTitle = thisList.items[initialSelectedItemIndex].title
		thisList.buttons.selected_item.setText(initialSelectedItemTitle)
		if thisList.isPerformerSelectionList then updatePerformerPreviewLabel(initialSelectedItemTitle) end
		local payload = function()
			thisList.selectItem(initialSelectedItemIndex, true, false, true)
			if not IsDefined(lastShardNotificationController) then return end
			if not IsDefined(thisList.listScrollAreaWidget) then return end
			local selectedItem = thisList.getSelectedItem()
			if not selectedItem then return end
			local payload = function()
				local isInWidget = true
				if isInWidget then
					setCursorOverWidgetWithCursorRestore(_, selectedItem.widget, not GetPlayer():PlayerLastUsedPad())
				else
					if IsDefined(lastSliderController) then
						setCursorOverWidgetWithCursorRestore(_, lastSliderController.handleWidgetRef, true)
					else
						restoreDefaulCursor()
					end
				end
				local payload = function() lastShardPopupNotificationData.useCursor = true end
				nativeUI.queueTask(payload, false, 0.01)
			end
			nativeUI.queueTask(payload, false, 0.01)
		end
		nativeUI.queueTask(payload, false, 0.01)
	end

	thisList.moveUpOnList = function()
		if thisList.itemCount < 1 then return end
		if thisList.selectedItemIndex < 1 and thisList.lastHoveredItemIndex > 0 then thisList.selectItem(thisList.lastHoveredItemIndex, true, false) return end

		local newItemIndex = thisList.selectedItemIndex - 1
		if newItemIndex > 0 then thisList.selectItem(newItemIndex, true, false) return end

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
			if itemScreenPos.Bottom >= scrollAreaWidgetScreenPosition.Bottom then
				newItemIndex = i
				break
			end
		end
		thisList.selectItem(newItemIndex, true, false)
	end
	thisList.moveDownOnList = function()
		if thisList.itemCount < 1 then return end
		if thisList.selectedItemIndex < 1 and thisList.lastHoveredItemIndex > 0 then thisList.selectItem(thisList.lastHoveredItemIndex, true, false) return end
		if thisList.selectedItemIndex < 1 then thisList.selectItem(1, true, false) return end

		local newItemIndex = thisList.selectedItemIndex + 1
		if newItemIndex <= thisList.itemCount then thisList.selectItem(newItemIndex, true, false) return end

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
			if itemScreenPos.Top <= scrollAreaWidgetScreenPosition.Top then
				newItemIndex = i
				break
			end
		end

		thisList.selectItem(newItemIndex, true, false)
	end

	thisList.moveUpOnSidePanel = function(skipPreCheck, isInSettingsButton)
		if skipPreCheck or (thisList.lastSelectedObject and (not thisList.lastSelectedObject.isListItem)) then
			if isInSettingsButton then
				for i = #thisList.sidePanelButtons, 1, -1 do
					local nextButton = thisList.buttons[thisList.sidePanelButtons[i]]
					if nextButton.isActive and nextButton.isEnabled and nextButton.isInteractiveButton then
						thisList.lastSelectedObject = nextButton
						return
					end
				end
			end
			for i = thisList.lastSelectedObject.itemIndex - 1, 1, -1 do
				local nextButton = thisList.buttons[thisList.sidePanelButtons[i]]
				if nextButton.isActive and nextButton.isEnabled and nextButton.isInteractiveButton then
					thisList.lastSelectedObject = nextButton
					return
				end
			end
			if nativeSettings and enableNativeSettingsIntegration and nativeUI.mainMenuController.buttons.settings.isEnabled and IsDefined(nativeUI.mainMenuController.buttons.settings.widget) then
				thisList.lastSelectedObject = nativeUI.mainMenuController.buttons.settings
				return
			end
			for i = thisList.lastSelectedObject.itemIndex + 1, lastButtonIndex do
				local nextButton = thisList.buttons[thisList.sidePanelButtons[i]]
				if nextButton.isActive and nextButton.isEnabled and nextButton.isInteractiveButton then
					thisList.lastSelectedObject = nextButton
					return
				end
			end
		else
			thisList.moveUpOnList()
		end
	end
	thisList.moveDownOnSidePanel = function(skipPreCheck, isInSettingsButton)
		if skipPreCheck or (thisList.lastSelectedObject and (not thisList.lastSelectedObject.isListItem)) then
			for i = thisList.lastSelectedObject.itemIndex + 1, lastButtonIndex do
				local nextButton = thisList.buttons[thisList.sidePanelButtons[i]]
				if nextButton.isActive and nextButton.isEnabled and (nextButton.type == 'button' or nextButton.type == 'switch') then
					thisList.lastSelectedObject = nextButton
					return
				end
			end
			if nativeSettings and enableNativeSettingsIntegration and nativeUI.mainMenuController.buttons.settings.isEnabled and IsDefined(nativeUI.mainMenuController.buttons.settings.widget) then
				thisList.lastSelectedObject = nativeUI.mainMenuController.buttons.settings
				return
			end
			for i = thisList.lastSelectedObject.itemIndex - 1, 1, -1 do
				local nextButton = thisList.buttons[thisList.sidePanelButtons[i]]
				if nextButton.isActive and nextButton.isEnabled and (nextButton.type == 'button' or nextButton.type == 'switch') then
					thisList.lastSelectedObject = nextButton
					return
				end
			end
		else
			thisList.moveDownOnList()
		end
	end

	thisList.moveUp = function()
		if thisList.lastSelectedObject and (not thisList.lastSelectedObject.isListItem) then
			local result, isInside = isGameCursorWithinWidget(thisList.buttonsAreaWidget)
			local isInSettingsButton = false
			if result and (not isInside) and nativeSettings and enableNativeSettingsIntegration and nativeUI.mainMenuController.buttons.settings.isEnabled and IsDefined(nativeUI.mainMenuController.buttons.settings.widget) then
				result, isInside = isGameCursorWithinWidget(nativeUI.mainMenuController.buttons.settings.widget)
				isInSettingsButton = result and isInside
			end
			if result and isInside then thisList.moveUpOnSidePanel(true, isInSettingsButton) return end
			thisList.moveUpOnList()
		else
			thisList.moveUpOnList()
		end
	end
	thisList.moveDown = function()
		if thisList.lastSelectedObject and (not thisList.lastSelectedObject.isListItem) then
			local result, isInside = isGameCursorWithinWidget(thisList.buttonsAreaWidget)
			local isInSettingsButton = false
			if result and (not isInside) and nativeSettings and enableNativeSettingsIntegration and nativeUI.mainMenuController.buttons.settings.isEnabled and IsDefined(nativeUI.mainMenuController.buttons.settings.widget) then
				result, isInside = isGameCursorWithinWidget(nativeUI.mainMenuController.buttons.settings.widget)
				isInSettingsButton = result and isInside
			end
			if result and isInside then thisList.moveDownOnSidePanel(true, isInSettingsButton) return end
			thisList.moveDownOnList()
		else
			thisList.moveDownOnList()
		end
	end

	thisList.moveLeft = function()
		if thisList.lastSelectedObject and thisList.lastSelectedObject.isListItem then
			thisList.lastSelectedObject = thisList.buttons.use_selected_item
		else
			thisList.selectItem(thisList.selectedItemIndex, true)
		end
	end
	thisList.moveRight = function()
		if thisList.lastSelectedObject and thisList.lastSelectedObject.isListItem then
			thisList.lastSelectedObject = thisList.buttons.use_selected_item
		else
			thisList.selectItem(thisList.selectedItemIndex, true)
		end
	end

	thisList.getLastSelectedObject = function()
		return thisList.lastSelectedObject
	end

	setupSelectionListActions(thisList)
	updateSelectionListState(thisList)

	nativeUI.isMainMenu = false
	nativeUI.isSelectionList = true

	thisList.selectionListAreaWidget:Reparent(parentWidget, -1)

	return thisList
end

function setupSelectionListActions(thisList)
	thisList.returnToMainMenu = function()
		unregisterSelectionListCallbacks(thisList)
		if not IsDefined(lastShardContentsWidget) then nativeUI.lastSelectionList = {} nativeUI.isSelectionList = false return end
		thisList.restoreParentWidget()
		thisList.parentWidget:RemoveChild(thisList.selectionListAreaWidget)
		nativeUI.isSelectionList = false
		nativeUI.isBackToMainMenu = true
		if nativeUI.isPerformerPreviewShowTime then togglePerformerPreview(false) end
		nativeUI.isPerformerPreviewShowTime = false
		createMainMenu(lastShardContentsWidget)
		lastShardPopupNotificationData.useCursor = false
		thisList.onReturnToMainMenu()
		nativeUI.lastSelectionList = {}
	end
	thisList.buttons.use_selected_item.onReleased = function()
		if not isDelayedButtonActionAllowed then return end
		if nextButtonActionAllowed > os.clock() then return end
		nativeUI.lastSelectionListReturn = thisList.getSelectedItem()
		thisList.buttons.selected_item.setText(nativeUI.lastSelectionListReturn.title)
		if nativeUI.isPerformerPreviewShowTime then
			local payload = function() togglePerformerPreview(false) end
			nativeUI.queueTask(payload, false, 0.2)
		end
		nativeUI.isPerformerPreviewShowTime = false
		nativeUI.lastSelectionListReturn.setAccepted(true)
		local payload = function() thisList.returnToMainMenu() isDelayedButtonActionAllowed = true end
		nextButtonActionAllowed = os.clock() + delayedButtonActionCooldown + 0.2
		isDelayedButtonActionAllowed = false
		nativeUI.queueTask(payload, false, buttonDelay)
	end
	thisList.buttons.cancel.onReleased = function()
		if not isDelayedButtonActionAllowed then return end
		if nextButtonActionAllowed > os.clock() then return end
		nativeUI.lastSelectionListReturn = {}
		if nativeUI.isPerformerPreviewShowTime then togglePerformerPreview(false) end
		nativeUI.isPerformerPreviewShowTime = false
		local payload = function() thisList.returnToMainMenu() isDelayedButtonActionAllowed = true end
		nextButtonActionAllowed = os.clock() + delayedButtonActionCooldown + 0.2
		isDelayedButtonActionAllowed = false
		nativeUI.queueTask(payload, false, buttonDelay)
	end
	thisList.isInitialized = true
end

function updateSelectionListState(thisList, isMainModCalling)
	if type(thisList) ~= 'table' then return end
	if not thisList.isInitialized then return end
	if not thisList.isPopulated then return end
	if not thisList.sceneData then return end
	if not IsDefined(thisList.parentWidget) then return end

	local thisScene = thisList.sceneData
	local scenes
	if thisScene.gender == 'female' then scenes = nativeUI.femaleScenes elseif thisScene.gender == 'male' then scenes = nativeUI.maleScenes else return end

	local sceneName
	for key, data in pairs(scenes) do
		if data.id == thisScene.id then
			sceneName = key
			break
		end
	end
	if not sceneName then return end

	local panelState = nil
	panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', panelState)
	local expectedItemIndex = 0
	if thisList.isPerformerSelectionList then expectedItemIndex = panelState.performersListState.itemIndex + 1
	elseif thisList.isDestinationSelectionList then	expectedItemIndex = panelState.customLocationsListState.customLocationItemIndex + 1
	else return end

	local listSelectedItem = thisList.getSelectedItem()
	if not listSelectedItem then thisList.selectItem(expectedItemIndex, true, false, false) return end
	if isMainModCalling then
		thisList.initialSelectedItemIndex = expectedItemIndex
	end
	if listSelectedItem.itemIndex == expectedItemIndex then return end

	thisList.selectItem(expectedItemIndex, true, false, false)
	if not isMainModCalling then return end

	if not IsDefined(lastShardNotificationController) then return end
	if not IsDefined(thisList.selectionListAreaWidget) then return end
	if not IsDefined(thisList.listScrollAreaWidget) then return end
	local selectedItem = thisList.getSelectedItem()
	if not selectedItem then return end
	local payload = function()
		local result, isInWidget = isGameCursorWithinWidget(thisList.selectionListAreaWidget)
		if not result then isInWidget = isWidgetWithinWidgetOnScreen(selectedItem.widget, thisList.listScrollAreaWidget) end
		if isInWidget then
			setCursorOverWidgetWithCursorRestore(_, selectedItem.widget, not GetPlayer():PlayerLastUsedPad())
		else
			restoreDefaulCursor()
		end
	end
	nativeUI.queueTask(payload, false, 0.01)
end

function registerSelectionListCallbacks(thisList, isNew)
	if not IsDefined(thisList.selectionListAreaWidget) then return end
	if not thisList.isEnabled then return end
	if not IsDefined(thisList.eventCatcher) then
		thisList.eventCatcher = sampleStyleManagerGameController.new()
		tableInsert(nativeUI.activeInstances, {eventCatcher = thisList.eventCatcher, isSelectionList = true, callerData = thisList})
	end
	if IsDefined(lastShardNotificationController) then
		tableInsert(nativeUI.activeInstances, {eventCatcher = lastShardNotificationController, isSelectionList = true, callerData = thisList})
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
	for i, buttonData in pairs(thisList.buttons) do
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
	for i, buttonData in pairs(thisList.buttons) do
		if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
			buttonData.widget:UnregisterFromCallback('OnPress', thisList.eventCatcher, 'OnState1')
			buttonData.widget:UnregisterFromCallback('OnRelease', thisList.eventCatcher, 'OnState2')
			buttonData.widget:UnregisterFromCallback('OnEnter', thisList.eventCatcher, 'OnStyle1')
			buttonData.widget:UnregisterFromCallback('OnLeave', thisList.eventCatcher, 'OnStyle2')
		end
	end
	thisList.eventCatcher = nil

	for i = #nativeUI.activeInstances, 1, -1 do
		if type(nativeUI.activeInstances[i]) == 'table' and nativeUI.activeInstances[i].isSelectionList then tableRemove(nativeUI.activeInstances, i) end
	end
	return true
end

local scenePanelNativeUITemplate = {
	fullSceneName = "",
	sceneData = nil,
	sceneId = 0,
	panelId = 0,
	panelAreaWidget = nil,
	isEnabled = true,
	setVisible = function() end,
	getScreenPosition = function() end,
	panelContentsWidget = nil,
	eventCatcher = nil,
	isScenePanel = true,
	isSelectionList = false,
	lastSelectedObject = nil,
	getLastSelectedObject = function() end,
	playerUsedPad = false,
	currentSceneMode = sceneModeIsInteractive,
	setSceneInteractiveMode = function() end,
	setSceneOverrideMode = function() end,
	setSceneFastPlaybackMode = function() end,
	switchSceneMode = function() end,
	currentPlaybackState = playbackStateIsIdle,
	setPlaybackStateToIdle = function() end,
	setPlaybackStateToCued = function() end,
	setPlaybackStateToPlayOnResume = function() end,
	setPlaybackStateToPlayPending = function() end,
	setPlaybackStateToPlaying = function() end,
	setPlaybackStateToReload = function() end,
	setPlaybackStateToActionUnavaliable = function() end,
	switchPlaybackState = function() end,
	leftSideVerticalPanelWidget = nil,
	rightSideVerticalPanelWidget = nil,
	activeTextColor = "MainColors.Neutral",
	inactiveTextColor = "MainColors.MildBlue",
	highlightTextColor = "MainColors.White",
	buttons = {
		scene_name = {name = "scene_name", title = "Scene Name", isInteractiveButton = false, isEnabled = true, isActive = true, type = "text", widget = nil, isUpperCase = false, buttonWidthSyncGroup = -1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end},
		override = {name = "override", title = "(Override mode)", isInteractiveButton = false, isEnabled = false, isActive = false, type = "text", widget = nil, isUpperCase = false, buttonWidthSyncGroup = -1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end},
		fast_playback = {name = "fast_playback", title = "Fast Playback", isInteractiveButton = true, isEnabled = false, isActive = true, type = "switch", isSwitchOn = false, widget = nil, buttonWidthSyncGroup = -1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, setSwitchState = function() end, onPressed = function() end, onReleased = function() end},
		performer = {name = "performer", title = "Select performer", isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		reset = {name = "reset", title = "Reset", isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		destination = {name = "destination", title = "scene default", isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		cue = {name = "cue", title = "Cue scene", isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		play = {name = "play", title = "Play scene", isInteractiveButton = true, isEnabled = false, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		play_on_resume = {name = "play_on_resume", title = "Play on game resume", isInteractiveButton = true, isEnabled = false, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		play_pending = {name = "play_pending", title = "Play pending...", isInteractiveButton = true, isEnabled = false, isActive = false, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		action_unavailable = {name = "action_unavailable", title = "Action unavailable", isInteractiveButton = true, isEnabled = false, isActive = false, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		reload_last_save = {name = "reload_last_save", title = "Reload last save", isInteractiveButton = true, isEnabled = false, isActive = true, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 1, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
		cancel = {name = "cancel", title = "Cancel", isInteractiveButton = true, isEnabled = true, isActive = false, type = "button", widget = nil, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
	},
	leftSideButtonRows = {
		{buttonAreaWidget = nil, buttonOrder = {'scene_name'}},
		{buttonAreaWidget = nil, buttonOrder = {'override'}},
		{buttonAreaWidget = nil, buttonOrder = {'fast_playback'}},
	},
	rightSideButtonRows = {
		{buttonAreaWidget = nil, buttonOrder = {'performer', 'reset'}},
		{buttonAreaWidget = nil, buttonOrder = {'destination'}},
		{buttonAreaWidget = nil, buttonOrder = {'cue', 'play', 'play_on_resume', 'play_pending', 'action_unavailable', 'reload_last_save', 'cancel'}},
	},
	footer = {
			panel_end_bottom_border_line = {name = "bottom_border_line_list_end", title = "", isEnabled = true, type = "border", widget = nil, marginTop = 30, marginBottom = 0, setVisible = function() end, getScreenPosition = function() end, setActive = function() end},
	},
	layout = {
		rows = {
			{'performer', 'reset'},
			{'fast_playback', 'destination'},
			{'cue', 'play', 'play_on_resume', 'play_pending', 'action_unavailable', 'reload_last_save', 'cancel'},
		},
		activeRowCount = 0,
		cells = {
			{{},					{'performer'}, {'reset'}},
			{{'fast_playback'},	{'destination'}, {}},
			{{},					{'cue', 'play', 'play_on_resume', 'play_pending', 'action_unavailable', 'reload_last_save'}, {'cancel'}},
		},
		getRightSideActiveRows = function() end,
	},
}

function registerScenePanelCallbacks(thisScene, isNew)
	if not thisScene.scenePanelNativeUI then return end
	if not IsDefined(thisScene.scenePanelNativeUI.panelAreaWidget) then return end
	if not thisScene.scenePanelNativeUI.isEnabled then return end
	if not IsDefined(thisScene.scenePanelNativeUI.eventCatcher) then
		thisScene.scenePanelNativeUI.eventCatcher = sampleStyleManagerGameController.new()
		tableInsert(nativeUI.activeInstances, {eventCatcher = thisScene.scenePanelNativeUI.eventCatcher, isScenePanel = true, callerData = thisScene})
	end

	if not IsDefined(thisScene.scenePanelNativeUI.eventCatcher) then return end

	local isAnyCallbackRegistered = false
	for i, buttonData in pairs(thisScene.scenePanelNativeUI.buttons) do
		if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
			buttonData.widget:RegisterToCallback('OnPress', thisScene.scenePanelNativeUI.eventCatcher, 'OnState1')
			buttonData.widget:RegisterToCallback('OnRelease', thisScene.scenePanelNativeUI.eventCatcher, 'OnState2')
			buttonData.widget:RegisterToCallback('OnEnter', thisScene.scenePanelNativeUI.eventCatcher, 'OnStyle1')
			buttonData.widget:RegisterToCallback('OnLeave', thisScene.scenePanelNativeUI.eventCatcher, 'OnStyle2')
			isAnyCallbackRegistered = true
		end
	end

	return isAnyCallbackRegistered
end

function unregisterScenePanelCallbacks(thisScene)
	if not thisScene.scenePanelNativeUI then return end
	if not IsDefined(thisScene.scenePanelNativeUI.eventCatcher) then return end

	for i, buttonData in pairs(thisScene.scenePanelNativeUI.buttons) do
		if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
			buttonData.widget:UnregisterFromCallback('OnPress', thisScene.scenePanelNativeUI.eventCatcher, 'OnState1')
			buttonData.widget:UnregisterFromCallback('OnRelease', thisScene.scenePanelNativeUI.eventCatcher, 'OnState2')
			buttonData.widget:UnregisterFromCallback('OnEnter', thisScene.scenePanelNativeUI.eventCatcher, 'OnStyle1')
			buttonData.widget:UnregisterFromCallback('OnLeave', thisScene.scenePanelNativeUI.eventCatcher, 'OnStyle2')
		end
	end

	thisScene.scenePanelNativeUI.eventCatcher = nil
	for i = #nativeUI.activeInstances, 1, -1 do
		if type(nativeUI.activeInstances[i]) == 'table' and nativeUI.activeInstances[i].isScenePanel and nativeUI.activeInstances[i].callerData and nativeUI.activeInstances[i].callerData.id == thisScene.id then tableRemove(nativeUI.activeInstances, i) end
	end
	return true
end

function registerAllPanelsCallbacks()
	local isNew = #nativeUI.activeInstances < 1
	if type(nativeUI.femaleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.femaleScenes) do
			registerScenePanelCallbacks(sceneData, isNew)
		end
	end
	if type(nativeUI.maleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.maleScenes) do
			registerScenePanelCallbacks(sceneData, isNew)
		end
	end
end

function unregisterAllPanelsCallbacks()
	if type(nativeUI.femaleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.femaleScenes) do
			unregisterScenePanelCallbacks(sceneData)
		end
	end
	if type(nativeUI.maleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.maleScenes) do
			unregisterScenePanelCallbacks(sceneData)
		end
	end
end

function unregisterAllCallbacks()
	if type(nativeUI.femaleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.femaleScenes) do
			unregisterScenePanelCallbacks(sceneData)
		end
	end
	if type(nativeUI.maleScenes) == 'table' then
		for _, sceneData in pairs(nativeUI.maleScenes) do
			unregisterScenePanelCallbacks(sceneData)
		end
	end
	unregisterSelectionListCallbacks(nativeUI.lastSelectionList)
	unregisterMainMenuCallbacks()
	nativeUI.activeInstances = {}
end

function createScenePanel(sceneName, gender, parentWidget, fontSize)
	if type(sceneName) ~= 'string' then return false end
	if type(gender) ~= 'string' then return false end
	if not IsDefined(parentWidget) then return end

	local scenes = nil
	local currentPerformers = nil
	local genderDesc = ""
	if gender == 'female' then
		if nativeUI.femaleScenesCount < 1 then return false end
		scenes = nativeUI.femaleScenes
		currentPerformers = nativeUI.femalePerformers
		genderDesc = "Female"
	elseif gender == 'male' then
		if nativeUI.maleScenesCount < 1 then return false end
		scenes = nativeUI.maleScenes
		currentPerformers = nativeUI.malePerformers
		genderDesc = "Male"
	else return false end

	if type(scenes) ~= 'table' then return false end

	local thisScene = scenes[sceneName]
	if not thisScene then return end

	thisScene.currentPerformers = currentPerformers

	if type(thisScene.scenePanelNativeUI) ~= 'table' then thisScene.scenePanelNativeUI = cloneTable(scenePanelNativeUITemplate) end
	if not thisScene.scenePanelNativeUI then return end

	thisScene.scenePanelNativeUI.parentWidget = parentWidget

	thisScene.scenePanelNativeUI.fullSceneName = thisScene.displayName or sceneName
	thisScene.scenePanelNativeUI.fullSceneName = thisScene.scenePanelNativeUI.fullSceneName.." "..genderDesc
	if uiStrings.nuiUiStrings.nativeUiPanelView.fullSceneNames[thisScene.gender] then
		local localizedFullSceneName = uiStrings.nuiUiStrings.nativeUiPanelView.fullSceneNames[thisScene.gender][sceneName]
		if type(localizedFullSceneName) == 'string' and stringLen(localizedFullSceneName) > 0 then thisScene.scenePanelNativeUI.fullSceneName = localizedFullSceneName end
	end
	thisScene.scenePanelNativeUI.sceneData = thisScene
	thisScene.scenePanelNativeUI.sceneId = thisScene.id
	thisScene.scenePanelNativeUI.panelId = thisScene.id

	if type(fontSize) ~= 'number' or fontSize < 10 then fontSize = 48 end

	thisScene.scenePanelNativeUI.panelAreaWidget = inkVerticalPanelWidget.new()
	thisScene.scenePanelNativeUI.panelAreaWidget:SetName('panelAreaWidget') CName.add("panelAreaWidget")
	thisScene.scenePanelNativeUI.panelAreaWidget:SetAnchor(inkEAnchor.TopLeft)
	thisScene.scenePanelNativeUI.panelAreaWidget:SetPadding(0, 30, 0, 0)

	thisScene.scenePanelNativeUI.setVisible = function(show) if type(show) ~= 'boolean' then return end thisScene.scenePanelNativeUI.panelAreaWidget:SetVisible(show) thisScene.scenePanelNativeUI.isEnabled = show return true end
	if not thisScene.scenePanelNativeUI.isEnabled then thisScene.scenePanelNativeUI.setVisible(false) end
	thisScene.scenePanelNativeUI.getScreenPosition = function() return GetScreenPosition(thisScene.scenePanelNativeUI.panelAreaWidget) end

	thisScene.scenePanelNativeUI.panelContentsWidget = inkBasePanel.new()
	thisScene.scenePanelNativeUI.panelContentsWidget:SetName('panelContentsWidget') CName.add("panelContentsWidget")
	thisScene.scenePanelNativeUI.panelContentsWidget:Reparent(thisScene.scenePanelNativeUI.panelAreaWidget, -1)

	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget = inkVerticalPanelWidget.new()
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetName('leftSideVerticalPanelWidget') CName.add("leftSideVerticalPanelWidget")
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetAnchor(inkEAnchor.TopLeft)
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetMargin(0, 0, 60, 0)
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetAnchorPoint(Vector2.new({ X = 0, Y = 0 }))
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetFitToContent(false)
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:SetWidth(fontSize * 10)
	thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget:Reparent(thisScene.scenePanelNativeUI.panelContentsWidget, -1)

	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget = inkVerticalPanelWidget.new()
	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget:SetName('rightSideVerticalPanelWidget') CName.add("rightSideVerticalPanelWidget")
	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget:SetAnchor(inkEAnchor.TopRight)
	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget:SetMargin(60, 0, 0, 0)
	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget:SetAnchorPoint(Vector2.new({ X = 0, Y = 0 }))
	thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget:Reparent(thisScene.scenePanelNativeUI.panelContentsWidget, -1)

	for i = 1, #thisScene.scenePanelNativeUI.leftSideButtonRows do
		thisScene.scenePanelNativeUI.leftSideButtonRows[i].buttonAreaWidget = inkHorizontalPanelWidget.new()
		thisScene.scenePanelNativeUI.leftSideButtonRows[i].buttonAreaWidget:SetMargin(0, 2, 0, 4)
		thisScene.scenePanelNativeUI.leftSideButtonRows[i].buttonAreaWidget:Reparent(thisScene.scenePanelNativeUI.leftSideVerticalPanelWidget, -1)
	end

	for i = 1, #thisScene.scenePanelNativeUI.rightSideButtonRows do
		thisScene.scenePanelNativeUI.rightSideButtonRows[i].buttonAreaWidget = inkHorizontalPanelWidget.new()
		thisScene.scenePanelNativeUI.rightSideButtonRows[i].buttonAreaWidget:SetMargin(0, 2, 0, 4)
		thisScene.scenePanelNativeUI.rightSideButtonRows[i].buttonAreaWidget:Reparent(thisScene.scenePanelNativeUI.rightSideVerticalPanelWidget, -1)
	end

	local activeTextColor = thisScene.scenePanelNativeUI.activeTextColor
	local inactiveTextColor = thisScene.scenePanelNativeUI.inactiveTextColor

	local buttonWidthSyncGroups = {}
	local panelSidesRowData = {thisScene.scenePanelNativeUI.leftSideButtonRows, thisScene.scenePanelNativeUI.rightSideButtonRows}
	local isLeftSide = true
	for i = 1, #panelSidesRowData do
		local panelSideButtonRows = panelSidesRowData[i]
		for ii = 1, #panelSideButtonRows do
			for iii = 1, #panelSideButtonRows[ii].buttonOrder do

				local button = panelSideButtonRows[ii].buttonOrder[iii]
				local buttonData = thisScene.scenePanelNativeUI.buttons[button]
				if not buttonData.name then buttonData.name = "button_"..tostring(i) end

				local buttonArea = panelSideButtonRows[ii].buttonAreaWidget
				local finalLabelText = buttonData.title or "New Button"
				if uiStrings.nuiUiStrings.nativeUiPanelView.buttons[buttonData.name] then
					local localizedButtonTitle = uiStrings.nuiUiStrings.nativeUiPanelView.buttons[buttonData.name].title
					if type(localizedButtonTitle) == 'string' and stringLen(localizedButtonTitle) > 0 then finalLabelText = localizedButtonTitle end
				end
				local buttonWidth = 100
				if buttonData.isFixedWidth then
					if buttonData.buttonWidthSyncGroup == 1 then
						buttonWidth = mathFloor(13 * fontSize)
					elseif buttonData.buttonWidthSyncGroup == 2 then
						buttonWidth = mathFloor(6.5 * fontSize)
					end
				else
					local finalLabelTextlen = stringLen(finalLabelText)
					buttonWidth = fontSize * finalLabelTextlen * textWidthFactor + 150
				end
				buttonWidth = math.ceil(buttonWidth / 10) * 10
				buttonWidth = RoundF(buttonWidth)

				local buttonSize = {buttonWidth, RoundF(fontSize * 1.75)}
				local buttonAnchorPoint = {0, 0}
				if not isLeftSide then buttonAnchorPoint = {1, 0} end

				buttonData.setActive = function(activate)
					if type(activate) ~= 'boolean' then return end
					if activate then
						if buttonData.isInteractiveButton then buttonData.widget:SetInteractive(true) end
						buttonData.isActive = true
						setWidgetTextLabelColor(buttonData.widgetLabel, activeTextColor)
						return true
					end
					buttonData.widget:SetInteractive(false)
					buttonData.isActive = false
					setWidgetTextLabelColor(buttonData.widgetLabel, inactiveTextColor)
					return true
				end

				if buttonData.type == 'text' then
					if buttonData.name == "scene_name" then finalLabelText = thisScene.scenePanelNativeUI.fullSceneName end
					buttonData.widget = createTextLabel(buttonData.name, finalLabelText, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, buttonData.isUpperCase)
					buttonData.widgetLabel = buttonData.widget
				else
					buttonData.widget, buttonData.widgetLabel = createButton(buttonData.name, finalLabelText, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, buttonData.isUpperCase)
					if not buttonData.isInteractiveButton then SetInteractive(false) end
					if buttonData.type == 'switch' then
						buttonData.widget:GetWidget("switch_icon"):SetOpacity(1)
						buttonData.setSwitchState = function(isSwitchOn)
							if type(isSwitchOn) ~= 'boolean' then return end
							buttonData.isSwitchOn = isSwitchOn
							if isSwitchOn then buttonData.widget:GetWidget("switch_icon"):SetTexturePart('ico_device_on') return end
							buttonData.widget:GetWidget("switch_icon"):SetTexturePart('ico_device_off')
						end
						buttonData.setSwitchState(buttonData.isSwitchOn)
					end
				end
				if not buttonData.isActive then buttonData.setActive(false) end

				buttonData.setText = function(text) if type(text) ~= 'string' then return end if not isStringValid(text) then return end buttonData.widgetLabel:SetText(text) return true end
				buttonData.setVisible = function(show) if type(show) ~= 'boolean' then return end buttonData.widget:SetVisible(show) buttonData.isEnabled = show return true end
				if not buttonData.isEnabled then buttonData.setVisible(false) end
				buttonData.getScreenPosition = function() return GetScreenPosition(buttonData.widget) end

				if type(buttonData.buttonWidthSyncGroup) == 'number' and buttonData.buttonWidthSyncGroup > 0 then
					if not buttonWidthSyncGroups[tostring(buttonData.buttonWidthSyncGroup)] then buttonWidthSyncGroups[tostring(buttonData.buttonWidthSyncGroup)] = {} end
					buttonWidthSyncGroup = buttonWidthSyncGroups[tostring(buttonData.buttonWidthSyncGroup)]
					tableInsert(buttonWidthSyncGroup, buttonData.widget)
				end

				if isLeftSide then buttonData.widget:SetMargin(2, 0, 4, 0) else buttonData.widget:SetMargin(4, 0, 2, 0) end
				buttonData.widget:Reparent(buttonArea, -1)
			end
		end
		isLeftSide = false
	end

	thisScene.scenePanelNativeUI.layout.getRightSideActiveRows = function()
		local activeRowCount = 0
		local activeRowWidgetsFound = {}
		for i = 1, #thisScene.scenePanelNativeUI.rightSideButtonRows do
			rowButtons = thisScene.scenePanelNativeUI.rightSideButtonRows[i].buttonOrder
			for ii = 1, #rowButtons do
				local button = thisScene.scenePanelNativeUI.buttons[rowButtons[ii]]
				if button then
					if button.isEnabled and button.isInteractiveButton then
						activeRowCount = activeRowCount + 1
						tableInsert(activeRowWidgetsFound, {rowIndex = i, widget = button.widget.parentWidget})
						break
					end
				end
			end
		end
		thisScene.scenePanelNativeUI.layout.activeRowCount = activeRowCount
		return activeRowCount, activeRowWidgetsFound
	end

	for _, group in pairs(buttonWidthSyncGroups) do
		if type(group) == 'table' then
			local width, maxWidth = 0, 0
			for _, widget in ipairs(group) do
				width = widget:GetWidth()
				if width > maxWidth then maxWidth = width end
			end
			if maxWidth > 0 then
				for _, widget in ipairs(group) do
					widget:SetWidth(maxWidth)
				end
			end
		end
	end

	for _, footer in pairs(thisScene.scenePanelNativeUI.footer) do
		footer.widget = createBottomBorderLineWithMargin(footer.name, footer.marginTop, footer.marginBottom)
		footer.setVisible = function(show) if type(show) ~= 'boolean' then return end footer.widget:SetVisible(show) footer.isEnabled = show return true end
		if not footer.isEnabled then footer.setVisible(false) end
		footer.widget:Reparent(thisScene.scenePanelNativeUI.panelAreaWidget, -1)
	end

	local textHMargin = math.ceil(fontSize * 1.25)
	local parentSize = thisScene.scenePanelNativeUI.buttons.performer.widget:GetSize()
	parentSize.X = parentSize.X - textHMargin
	thisScene.scenePanelNativeUI.buttons.performer.widgetLabel:SetSize(parentSize)
	thisScene.scenePanelNativeUI.buttons.performer.widgetLabel:SetAnchor(inkEAnchor.Centered)
	thisScene.scenePanelNativeUI.buttons.performer.widgetLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
	thisScene.scenePanelNativeUI.buttons.performer.widgetLabel.fitToContent = false
	thisScene.scenePanelNativeUI.buttons.performer.widgetLabel.textOverflowPolicy = textOverflowPolicy.PingPongScroll

	local parentSize = thisScene.scenePanelNativeUI.buttons.destination.widget:GetSize()
	parentSize.X = parentSize.X - textHMargin
	thisScene.scenePanelNativeUI.buttons.destination.widgetLabel:SetSize(parentSize)
	thisScene.scenePanelNativeUI.buttons.destination.widgetLabel:SetAnchor(inkEAnchor.Centered)
	thisScene.scenePanelNativeUI.buttons.destination.widgetLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
	thisScene.scenePanelNativeUI.buttons.destination.widgetLabel.fitToContent = false
	thisScene.scenePanelNativeUI.buttons.destination.widgetLabel.textOverflowPolicy = textOverflowPolicy.PingPongScroll

	setupPanelActions(scenes, sceneName, thisScene)
	updateScenePanelState(scenes, sceneName, thisScene)
	thisScene.scenePanelNativeUI.panelAreaWidget:Reparent(parentWidget, -1)
	return thisScene.scenePanelNativeUI
end

function setupPanelActions(scenes, sceneName, thisScene, force)
	if (not force) and thisScene.scenePanelNativeUI.isInitialized then return end

	local thisScenePanel = thisScene.scenePanelNativeUI
	local thisScenePanelButtons = thisScenePanel.buttons

	thisScenePanel.setSceneDisabledMode = function()
		thisScenePanelButtons.override.setVisible(false)
		thisScenePanelButtons.fast_playback.setVisible(false)
		thisScenePanel.currentSceneMode = sceneModeIsDisabled
		return true
	end
	thisScenePanel.setSceneInteractiveMode = function()
		thisScenePanelButtons.override.setVisible(false)
		thisScenePanelButtons.fast_playback.setVisible(false)
		thisScenePanel.currentSceneMode = sceneModeIsInteractive
		return true
	end
	thisScenePanel.setSceneOverrideMode = function()
		thisScenePanelButtons.override.setVisible(true)
		thisScenePanelButtons.fast_playback.setVisible(false)
		thisScenePanel.currentSceneMode = sceneModeIsOverride
		return true
	end
	thisScenePanel.setSceneFastPlaybackMode = function()
		thisScenePanelButtons.override.setVisible(false)
		thisScenePanelButtons.fast_playback.setVisible(true)
		thisScenePanel.currentSceneMode = sceneModeIsFastPlayback
		return true
	end
	thisScenePanel.switchSceneMode = function(newSceneMode)
		if type(newSceneMode) ~= 'number' then return end
		if newSceneMode == sceneModeIsDisabled then thisScenePanel.setSceneDisabledMode() return true end
		if newSceneMode == sceneModeIsInteractive then thisScenePanel.setSceneInteractiveMode() return true end
		if newSceneMode == sceneModeIsOverride then thisScenePanel.setSceneOverrideMode() return true end
		if newSceneMode == sceneModeIsFastPlayback then thisScenePanel.setSceneFastPlaybackMode() return true end
	end

	thisScenePanel.setPlaybackStateToIdle = function()
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(true)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(true)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		thisScenePanelButtons.cue.setVisible(true)	thisScenePanelButtons.cue.setActive(true)
		thisScenePanelButtons.play.setVisible(false)	thisScenePanelButtons.play.setActive(true)
		thisScenePanelButtons.play_on_resume.setVisible(false) thisScenePanelButtons.play_on_resume.setActive(true)
		thisScenePanelButtons.play_pending.setVisible(false)	thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(false) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(false) thisScenePanelButtons.reload_last_save.setActive(true) thisScenePanelButtons.reload_last_save.isReloadPressed = false
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(false)
		return true
	end
	thisScenePanel.setPlaybackStateToCued = function()
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(true)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(true)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		thisScenePanelButtons.cue.setVisible(false)	thisScenePanelButtons.cue.setActive(true)
		thisScenePanelButtons.play.setVisible(true)	thisScenePanelButtons.play.setActive(true)
		thisScenePanelButtons.play_on_resume.setVisible(false) thisScenePanelButtons.play_on_resume.setActive(true)
		thisScenePanelButtons.play_pending.setVisible(false) thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(false) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(false) thisScenePanelButtons.reload_last_save.setActive(true) thisScenePanelButtons.reload_last_save.isReloadPressed = false
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(true)
		return true
	end
	thisScenePanel.setPlaybackStateToPlayOnResume = function()
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(true)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(true)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		thisScenePanelButtons.cue.setVisible(false)	thisScenePanelButtons.cue.setActive(true)
		thisScenePanelButtons.play.setVisible(false)	thisScenePanelButtons.play.setActive(true)
		thisScenePanelButtons.play_on_resume.setVisible(true) thisScenePanelButtons.play_on_resume.setActive(true)
		thisScenePanelButtons.play_pending.setVisible(false) thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(false) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(false) thisScenePanelButtons.reload_last_save.setActive(true) thisScenePanelButtons.reload_last_save.isReloadPressed = false
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(true)
		return true
	end
	thisScenePanel.setPlaybackStateToPlayPending = function()
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(true)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(true)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		thisScenePanelButtons.cue.setVisible(false)	thisScenePanelButtons.cue.setActive(true)
		thisScenePanelButtons.play.setVisible(false)	thisScenePanelButtons.play.setActive(true)
		thisScenePanelButtons.play_on_resume.setVisible(false) thisScenePanelButtons.play_on_resume.setActive(true)
		thisScenePanelButtons.play_pending.setVisible(true) thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(false) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(false) thisScenePanelButtons.reload_last_save.setActive(true) thisScenePanelButtons.reload_last_save.isReloadPressed = false
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(true)
		return true
	end
	thisScenePanel.setPlaybackStateToReload = function()
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(true)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(true)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		thisScenePanelButtons.cue.setVisible(false)	thisScenePanelButtons.cue.setActive(true)
		thisScenePanelButtons.play.setVisible(false)	thisScenePanelButtons.play.setActive(true)
		thisScenePanelButtons.play_on_resume.setVisible(false) thisScenePanelButtons.play_on_resume.setActive(true)
		thisScenePanelButtons.play_pending.setVisible(false)	thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(false) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(true)
		if thisScenePanelButtons.reload_last_save.isReloadPressed then
			thisScenePanelButtons.reload_last_save.setActive(false)
			thisScenePanelButtons.reload_last_save.setText(uiStrings.nuiUiStrings.nativeUiPanelView.buttons.reload_last_save_reloading.title)
		else
			thisScenePanelButtons.reload_last_save.setActive(true)
			thisScenePanelButtons.reload_last_save.setText(uiStrings.nuiUiStrings.nativeUiPanelView.buttons.reload_last_save.title)
		end
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(true)
		return true
	end
	thisScenePanel.setPlaybackStateToActionUnavaliable = function(hideExtraFeatures)
		thisScenePanelButtons.performer.setVisible(true) thisScenePanelButtons.performer.setActive(false)
		thisScenePanelButtons.reset.setVisible(true)	thisScenePanelButtons.reset.setActive(false)
		local shouldEnableCustomDestitations = thisScenePanel.currentSceneMode == sceneModeIsOverride or (thisScenePanel.currentSceneMode == sceneModeIsFastPlayback and thisScenePanelButtons.fast_playback.isSwitchOn)
		thisScenePanelButtons.destination.setActive(shouldEnableCustomDestitations)
		if hideExtraFeatures then thisScenePanelButtons.destination.setVisible(false) end
		thisScenePanelButtons.cue.setVisible(false)	thisScenePanelButtons.cue.setActive(false)
		thisScenePanelButtons.play.setVisible(false)	thisScenePanelButtons.play.setActive(false)
		thisScenePanelButtons.play_on_resume.setVisible(false) thisScenePanelButtons.play_on_resume.setActive(false)
		thisScenePanelButtons.play_pending.setVisible(false)	thisScenePanelButtons.play_pending.setActive(false)
		thisScenePanelButtons.action_unavailable.setVisible(true) thisScenePanelButtons.action_unavailable.setActive(false)
		thisScenePanelButtons.reload_last_save.setVisible(false) thisScenePanelButtons.reload_last_save.setActive(false) thisScenePanelButtons.reload_last_save.isReloadPressed = false
		thisScenePanelButtons.cancel.setVisible(true) thisScenePanelButtons.cancel.setActive(false)
		return true
	end
	thisScenePanel.switchPlaybackState = function(newPlaybackState, hideExtraFeatures)
		if type(newPlaybackState) ~= 'number' then return end
		if newPlaybackState == playbackStateIsIdle then thisScenePanel.setPlaybackStateToIdle() currentPlaybackState = newPlaybackState return true end
		if newPlaybackState == playbackStateIsCued then thisScenePanel.setPlaybackStateToCued() currentPlaybackState = newPlaybackState return true end
		if newPlaybackState == playbackStateIsPlayOnResume then thisScenePanel.setPlaybackStateToPlayOnResume() currentPlaybackState = newPlaybackState return true end
		if newPlaybackState == playbackStateIsPlayPending then thisScenePanel.setPlaybackStateToPlayPending() currentPlaybackState = newPlaybackState return true end
		if newPlaybackState == playbackStateIsReload then thisScenePanel.setPlaybackStateToReload() currentPlaybackState = newPlaybackState return true end
		if newPlaybackState == playbackStateIsActionUnavaliable then thisScenePanel.setPlaybackStateToActionUnavaliable(hideExtraFeatures) currentPlaybackState = newPlaybackState return true end
	end

	thisScenePanelButtons.fast_playback.onReleased = function()
		thisScenePanelButtons.destination.setActive(thisScenePanelButtons.fast_playback.isSwitchOn)
		updateScenePanelState(scenes, sceneName, thisScene, {enableFastTrackPlayback = thisScenePanelButtons.fast_playback.isSwitchOn})
	end
	thisScenePanelButtons.performer.onReleased = function()
		thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		updateScenePanelState(scenes, sceneName, thisScene, {performer = true})
	end
	thisScenePanelButtons.destination.onReleased = function()
		thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		updateScenePanelState(scenes, sceneName, thisScene, {destination = true})
	end
	thisScenePanelButtons.reset.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		updateScenePanelState(scenes, sceneName, thisScene, {reset = true})
	end
	thisScenePanelButtons.cue.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsCued)
		updateScenePanelState(scenes, sceneName, thisScene, {cue = true})
	end
	thisScenePanelButtons.play.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsPlayPending)
		local thisSceneId = thisScene.id
		for _, scene in pairs(nativeUI.femaleScenes) do
			if scene.id ~= thisSceneId then
				if scene.scenePanelNativeUI then scene.scenePanelNativeUI.switchPlaybackState(playbackStateIsIdle) end
			end
		end
		for _, scene in pairs(nativeUI.maleScenes) do
			if scene.id ~= thisSceneId then
				if scene.scenePanelNativeUI then scene.scenePanelNativeUI.switchPlaybackState(playbackStateIsIdle) end
			end
		end
		updateScenePanelState(scenes, sceneName, thisScene, {play = true})
		local payload = function()
			if IsDefined(lastShardNotificationController) then lastShardNotificationController:Close() end
		end
		nativeUI.queueTask(payload, false, 0.5)
	end
	thisScenePanelButtons.play_on_resume.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsPlayPending)
		updateScenePanelState(scenes, sceneName, thisScene, {play_on_resume = true})
		local payload = function()
			if IsDefined(lastShardNotificationController) then lastShardNotificationController:Close() end
		end
		nativeUI.queueTask(payload, false, 0.5)
	end
	thisScenePanelButtons.reload_last_save.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsPlayPending)
		thisScenePanelButtons.reload_last_save.isReloadPressed = true
		updateScenePanelState(scenes, sceneName, thisScene, {reload_last_save = true})
	end
	thisScenePanelButtons.cancel.onReleased = function()
		if nextButtonActionAllowed > os.clock() then return end
		thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		updateScenePanelState(scenes, sceneName, thisScene, {cancel = true})
	end
	thisScenePanel.isInitialized = true
end

local panelState = nil
function updateScenePanelState(scenes, sceneName, thisScene, payload)
	if not thisScene then
		thisScene = scenes[sceneName]
		if not thisScene then return end
	end

	local thisScenePanel = thisScene.scenePanelNativeUI
	if not thisScenePanel then return end
	local thisScenePanelButtons = thisScenePanel.buttons
	if not thisScenePanel.buttons then return end

	local shouldAllowThisPanel = (thisScene.isAvailable or thisScene.isAvailableOnlyInOverrideMode) and #thisScene.performersIndex > 0
	thisScenePanel.setVisible(shouldAllowThisPanel)
	if not shouldAllowThisPanel then return end

	if type(thisScenePanel.panelState) ~= 'table' then thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', thisScenePanel.panelState) end
	if type(thisScenePanel.panelState) ~= 'table' then
		thisScenePanel.switchSceneMode(sceneModeIsDisabled)
		thisScenePanel.switchPlaybackState(playbackStateIsActionUnavaliable, true)
		return
	end

	if type(payload) == 'table' then
		if payload.reset then
			thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'reset button clicked', thisScenePanel.panelState)
		elseif payload.performer then
			if IsDefined(lastShardContentsWidget) then
				if isDelayedButtonActionAllowed and os.clock() > nextButtonActionAllowed then
					local payload = function()
						unregisterAllPanelsCallbacks()
						unregisterMainMenuCallbacks(true)
						if not IsDefined(lastShardContentsWidget) then isDelayedButtonActionAllowed = true return end
						if IsDefined(nativeUI.mainMenuPanelsWidget) then lastShardContentsWidget:RemoveChild(nativeUI.mainMenuPanelsWidget) end
						thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', thisScenePanel.panelState)
						local callerId = thisScenePanelButtons.performer.name
						lastShardPopupNotificationData.useCursor = false
						local newSelectionList = createSelectionList(thisScene, callerId, true, thisScene.performersFullNameIndexNativeUi, thisScenePanel.panelState.performersListState.itemIndex + 1, lastShardContentsWidget)
						if newSelectionList then
							nativeUI.isPerformerPreviewShowTime = true
							togglePerformerPrevievButtonHint(true)
							newSelectionList.onReturnToMainMenu = function()
								if type(nativeUI.lastSelectionListReturn) == 'table' and type(nativeUI.lastSelectionListReturn.itemIndex) == 'number' and nativeUI.lastSelectionListReturn.itemIndex > 0 then
									thisScenePanel.panelState.performersListState.itemIndex = nativeUI.lastSelectionListReturn.itemIndex - 1
									thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'performer changed', thisScenePanel.panelState)
									nativeUI.isBackToMainMenu = true
									nativeUI.updateUI()
								end
							end
							registerSelectionListCallbacks(newSelectionList)
							nativeUI.lastSelectionList = newSelectionList
							nativeUI.lastSelectionList.isPopulated = true
						else
							createMainMenu(lastShardContentsWidget)
						end
						isDelayedButtonActionAllowed = true
					end
					nextButtonActionAllowed = os.clock() + delayedButtonActionCooldown
					isDelayedButtonActionAllowed = false
					nativeUI.queueTask(payload, false, buttonDelay)
					return
				end
			end
		elseif payload.destination then
			if IsDefined(lastShardContentsWidget) then
				if isDelayedButtonActionAllowed and os.clock() > nextButtonActionAllowed then
					local payload = function()
						unregisterAllPanelsCallbacks()
						unregisterMainMenuCallbacks(true)
						if not IsDefined(lastShardContentsWidget) then isDelayedButtonActionAllowed = true return end
						if IsDefined(nativeUI.mainMenuPanelsWidget) then lastShardContentsWidget:RemoveChild(nativeUI.mainMenuPanelsWidget) end
						thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', thisScenePanel.panelState)
						local callerId = thisScenePanelButtons.destination.name
						lastShardPopupNotificationData.useCursor = false
						local customLocationsList = thisScenePanel.panelState.customLocationsListNativeUi or thisScenePanel.panelState.customLocationsList
						local newSelectionList = createSelectionList(thisScene, callerId, false, customLocationsList, thisScenePanel.panelState.customLocationsListState.customLocationItemIndex + 1, lastShardContentsWidget)
						if newSelectionList then
							nativeUI.isPerformerPreviewShowTime = false
							newSelectionList.onReturnToMainMenu = function()
								if type(nativeUI.lastSelectionListReturn) == 'table' and type(nativeUI.lastSelectionListReturn.itemIndex) == 'number' and nativeUI.lastSelectionListReturn.itemIndex > 0 then
									thisScenePanel.panelState.customLocationsListState.customLocationItemIndex = nativeUI.lastSelectionListReturn.itemIndex - 1
									thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'custom location changed', thisScenePanel.panelState)
									thisScenePanel.panelState.sceneTargetLocation = scenes[sceneName].lastSelectedCustomLocation
									nativeUI.isBackToMainMenu = true
									nativeUI.updateUI()
								end
							end
							registerSelectionListCallbacks(newSelectionList)
							nativeUI.lastSelectionList = newSelectionList
							nativeUI.lastSelectionList.isPopulated = true
						else
							createMainMenu(lastShardContentsWidget)
						end
						isDelayedButtonActionAllowed = true
					end
					nextButtonActionAllowed = os.clock() + delayedButtonActionCooldown
					isDelayedButtonActionAllowed = false
					nativeUI.queueTask(payload, false, buttonDelay)
					return
				end
			end
		elseif payload.cue then
			thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'playback button clicked', thisScenePanel.panelState)
		elseif payload.play then
			thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'playback button clicked', thisScenePanel.panelState)
		elseif payload.play_on_resume then
			thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'playback button clicked', thisScenePanel.panelState)
		elseif payload.reload_last_save then
			if isDelayedButtonActionAllowed and os.clock() > nextButtonActionAllowed then
				local payload = function()
					thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'playback button clicked', thisScenePanel.panelState)
					isDelayedButtonActionAllowed = true
				end
				nextButtonActionAllowed = os.clock() + delayedButtonActionCooldown
				isDelayedButtonActionAllowed = false
				nativeUI.queueTask(payload, false, buttonDelay)
			end
		elseif payload.cancel then
			thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'cancel button clicked', thisScenePanel.panelState)
		end
	else
		payload = {}
	end

	thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', thisScenePanel.panelState)

	local isPanelActive = thisScenePanel.panelState.isActive
	local shouldEnablePerformerSelectionInInactivePanel = false
	if not isPanelActive then
		if nativeUI.is_mq055_hangouts_interaction_activated() then shouldEnablePerformerSelectionInInactivePanel = nativeUI.mq055_hangouts_interaction.isCustomChoiceOnScreen() end
	end

	if not thisScenePanel.isEnabled then return end

	local lastItem

	thisScenePanel.switchSceneMode(thisScenePanel.panelState.sceneMode)

	local sceneUserSettings = {}
	if nativeUI.userSettings[thisScene.gender] and nativeUI.userSettings[thisScene.gender][sceneName] then sceneUserSettings = nativeUI.userSettings[thisScene.gender][sceneName] end

	local enableFastTrackPlaybackFeatures = false
	if type(payload.enableFastTrackPlayback) == 'boolean' then
		enableFastTrackPlaybackFeatures = payload.enableFastTrackPlayback
		sceneUserSettings.enableFastTrackPlayback = enableFastTrackPlaybackFeatures
		nativeUI.updatePerformers()
		thisScenePanel.panelState = nativeUI.getPanelLogic(scenes, sceneName, thisScene.gender, 'none', thisScenePanel.panelState, true)
		nativeUI.saveUserSettings()
	else
		local userSettingsEnableFastTrackPlayback = sceneUserSettings.enableFastTrackPlayback
		if type(userSettingsEnableFastTrackPlayback) == 'boolean' then enableFastTrackPlaybackFeatures = userSettingsEnableFastTrackPlayback end
	end
	thisScenePanelButtons.fast_playback.setSwitchState(enableFastTrackPlaybackFeatures)

	thisScenePanel.panelState.scenePlaybackMode = thisScenePanel.panelState.sceneMode
	if thisScenePanel.panelState.sceneMode == sceneModeIsFastPlayback then
		if enableFastTrackPlaybackFeatures then
			thisScenePanel.panelState.scenePlaybackMode = sceneModeIsFastPlayback
		else
			thisScenePanel.panelState.scenePlaybackMode = sceneModeIsInteractive
		end
	end

	lastItem = thisScenePanel.panelState.performersListState.itemIndex
	if not lastItem then lastItem = 0 end
	lastItem = lastItem + 1
	local performerFullName = thisScene.performersFullNameIndexNativeUi[lastItem]
	if isStringValid(performerFullName) then thisScenePanelButtons.performer.setText(performerFullName) end

	local activateDestinations = false
	local destinationName = thisScenePanelButtons.destination.title
	local shouldShowDestinations = false
	local customLocationsList = thisScenePanel.panelState.customLocationsListNativeUi or thisScenePanel.panelState.customLocationsList
	if customLocationsList and (thisScenePanel.panelState.sceneMode == sceneModeIsFastPlayback or thisScenePanel.panelState.sceneMode == sceneModeIsOverride) then
		shouldShowDestinations = true
		lastItem = thisScenePanel.panelState.customLocationsListState.customLocationItemIndex
		if not lastItem then lastItem = 0 end
		lastItem = lastItem + 1
		local customDestinationName = customLocationsList[lastItem]
		if isStringValid(customDestinationName) then
			if thisScenePanel.panelState.sceneMode == sceneModeIsOverride then
				activateDestinations = true
				destinationName = customDestinationName
			elseif thisScenePanel.panelState.sceneMode == sceneModeIsFastPlayback and enableFastTrackPlaybackFeatures then
				activateDestinations = true
				destinationName = customDestinationName
			end
		end
	end
	if shouldShowDestinations then
		thisScenePanelButtons.destination.setActive(activateDestinations)
		if destinationName == thisScenePanelButtons.destination.title then destinationName = uiStrings.nuiUiStrings.nativeUiPanelView.buttons.destination.title end
		thisScenePanelButtons.destination.setText(destinationName)
		thisScenePanelButtons.destination.setVisible(true)
	else
		thisScenePanelButtons.destination.setVisible(false)
		thisScenePanel.panelState.sceneTargetLocation = 'default'
	end

	if activateDestinations then thisScenePanel.panelState.sceneTargetLocation = thisScene.lastSelectedCustomLocation else thisScenePanel.panelState.sceneTargetLocation = 'default' end

	local isPlaybackAllowedBool = true
	if thisScenePanel.panelState.isActive then
		if thisScene.scenePlaybackProgress == nativeUI.playback.idle then
			thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		elseif scenes[sceneName].scenePlaybackProgress == nativeUI.playback.cued then
			if isPlaybackAllowedBool then
				thisScenePanel.switchPlaybackState(playbackStateIsCued)
			else
				thisScenePanel.switchPlaybackState(playbackStateIsPlayOnResume)
			end
			thisScenePanel.panelState.playbackUnarmButtonState.isActive = true
		elseif thisScene.scenePlaybackProgress == nativeUI.playback.playPending then
			thisScenePanel.switchPlaybackState(playbackStateIsPlayPending)
		elseif thisScene.scenePlaybackProgress == nativeUI.playback.playing then
			thisScenePanel.switchPlaybackState(playbackStateIsReload)
		else
			thisScenePanel.switchPlaybackState(playbackStateIsIdle)
		end
	end
end

function launchMainMenu()
	if nativeUI.isModDisabled then return end
	if not nativeUI.isInitialized then return end

	if nativeUI.isShowtime and not IsDefined(shardUiTitleTextWidget) then nativeUI.isShowtime = false end
	if nativeUI.isShowtime then print(modName, modVer, "Menu is already opened.") return end
	local warningText = uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.header
	if nativeUI.totalPerformersCount < 1 then sendWarningMessage(warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.totalPerformersCount) return end

	local result, reason = nativeUI.isHotscenesAvailable()
	if not result then
		if reason then
			if reason == 'isCensored' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.isCensored
			elseif reason == 'isEnding' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.isEnding
			elseif reason == 'journalManagerMissing' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.journalManagerMissing
			elseif reason == 'isAnyPerformerAvailable' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.isAnyPerformerAvailable
			else
				warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.unknown
			end
		else
			warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.hotscenesUnavailable.unknown
		end
		sendWarningMessage(warningText)
		return
	end

	warningText = uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.header
	result, reason = nativeUI.isHotscenesAllowed()
	if not result then
		if reason then
			if reason == 'isModDisabled' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isModDisabled
			elseif reason == 'isSavingLocked' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isSavingLocked
			elseif reason == 'notInGameSession' then return
			elseif reason == 'inVehicle' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.inVehicle
			elseif reason == 'inWorkspot' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.inWorkspot
			elseif reason == 'inCombat' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.inCombat
			elseif reason == 'inScene' then if GetPlayer():GetSceneTier() > 3 then return else warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isHangoutsScene end
			elseif reason == 'inRestrictedArea' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.inRestrictedArea
			elseif reason == 'isScanning' then return
			elseif reason == 'isInCall' then return
			elseif reason == 'isBraindance' then return
			elseif reason == 'isInDeviceControl' then return
			elseif reason == 'isFastTravel' then return
			elseif reason == 'isJohnnyReplacer' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isJohnnyReplacer
			elseif reason == 'isPlayerPossessedByJohnny' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isPlayerPossessedByJohnny
			elseif reason == 'isWanted' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isWanted
			elseif reason == 'isHangoutsScene' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isHangoutsScene
			elseif reason == 'isRestrictedState' then warningText = warningText.."\n"..uiStrings.nuiUiStrings.onscreenWarnings.actionUnavailable.isRestrictedState
			else
				warningText = warningText.."\n".."\nUnknown reason."
			end
		else
			warningText = warningText.."\n".."\nUnknown reason."
		end
		sendWarningMessage(warningText)
		return
	end

	if not nativeUI.isPlaybackAllowed() then print(modName, modVer, "Playback is not allowed at the moment.") return end
	nativeUI.isBackToMainMenu = false
	if (not isPreviewTriggerReactivatedInThisSession) and isKnownName("mod_hotscenes_performer_preview_available") then
		questsSystem:SetFactStr("mod_hotscenes_custom_trigger_quest_active", 0)
		isPreviewTriggerReactivatedInThisSession = true
	end

	if isGameLoading then print(modName, modVer, "Playback is currently unavailable as the new game load has not yet completed.") return end
	isItMyShard = false
	if type(nativeUI.updateSceneState) == 'function' then nativeUI.updateSceneState() end
	if type(nativeUI.forceUpdateScenePerformersByPanelLogic) == 'function' then nativeUI.forceUpdateScenePerformersByPanelLogic() end
	toggleLockIncomingCalls(true)
	uiSystem:QueueEvent(NotifyShardRead.new({title = shardUiTitle, text = shardUiText}))
	local payload = function() if not isItMyShard then toggleLockIncomingCalls(false) end end
	nativeUI.queueTask(payload, false, 1)
end
nativeUI.launchMainMenu = launchMainMenu

function sendWarningMessage(message, showTime)
	if type(message) ~= 'string' then return end
	if not isStringValid(message) then return end
	if GetPlayer():IsCooldownActive(n"mod_hotscenes_warningMessageCooldown") then return end
	if type(showTime) ~= 'number' then showTime = 5 end
	showTime = ClampF(showTime, 1, 10)
	GetPlayer():StartCooldown(n"mod_hotscenes_warningMessageCooldown", showTime, false)
	PreventionSystem.ShowMessage(message, showTime)
end

function createMainMenuPanels(parentWidget, isUpdate, isMainModCalling)
	nativeUI.isShowtime = false
	nativeUI.isMainMenu = false
	nativeUI.isPerformerPreviewShowTime = false

	if not IsDefined(parentWidget) then return end
	if not parentWidget:IsA('inkCompoundWidget') then return end

	local parentContentArea = getTopWigetByName(parentWidget, 'contentArea')
	if not parentContentArea then return end
	local scrollAreaWidget = parentContentArea:GetWidget('EntryScrollArea')
	if not (scrollAreaWidget and scrollAreaWidget:IsA('inkScrollAreaWidget')) then return end
	nativeUI.mainMenuController.scrollAreaWidget = scrollAreaWidget

	local isUpdatingPanels = false
	local oldMainMenuPanelsWidget = nil
	if isUpdate and IsDefined(nativeUI.mainMenuPanelsWidget) then
		oldMainMenuPanelsWidget = nativeUI.mainMenuPanelsWidget
		isUpdatingPanels = true
	end
	unregisterAllCallbacks()

	nativeUI.mainMenuPanelsWidget = inkVerticalPanelWidget.new()
	nativeUI.mainMenuPanelsWidget:SetName("hotscenes_main_menu_panels") CName.add("hotscenes_main_menu_panels")
	nativeUI.mainMenuPanelsWidget:SetAnchor(inkEAnchor.TopLeft)

	local lastSceneData = nil
	local lastEnabledPanelData = nil
	local lastPanelWidget = nil
	local panelsCreated = 0
	local panelsEnabled = 0
	local sceneData = nativeUI.femaleScenes
	local returnToPanel = nil
	if type(nativeUI.femaleScenesIndex) == 'table' then scenes = nativeUI.femaleScenesIndex end

	isLeftToRightOrder = true
	if type(currentGameUiLanguage) == 'string' and currentGameUiLanguage == 'ar-ar' then isLeftToRightOrder = false end

	for _, sceneName in ipairs(scenes) do
		lastSceneData = sceneData[sceneName]
		local panelData = createScenePanel(sceneName, sceneData[sceneName].gender, nativeUI.mainMenuPanelsWidget)
		if panelData then
			lastPanelWidget = panelData.panelAreaWidget
			panelsCreated = panelsCreated + 1
			if panelData.isEnabled then
				panelsEnabled = panelsEnabled + 1
				if panelsEnabled == 1 then panelData.panelAreaWidget:SetPadding(0, 0, 0, 0) end
				if not isLeftToRightOrder then
					local padding = panelData.panelAreaWidget:GetPadding()
					padding.left = 10
					panelData.panelAreaWidget:SetPadding(padding)
				end
				tableInsert(nativeUI.mainMenuController.activePanels, panelData)
				panelData.panelIndex = #nativeUI.mainMenuController.activePanels
				lastEnabledPanelData = panelData
			end
		end
		if nativeUI.isBackToMainMenu and (not returnToPanel) and panelData.isEnabled and type(nativeUI.lastSelectionList.sceneId) == 'number' then
			if lastSceneData.id == nativeUI.lastSelectionList.sceneId then returnToPanel = panelData end
		end
	end
	local sceneData = nativeUI.maleScenes
	if type(nativeUI.maleScenesIndex) == 'table' then scenes = nativeUI.maleScenesIndex end
	for _, sceneName in ipairs(scenes) do
		lastSceneData = sceneData[sceneName]
		local panelData = createScenePanel(sceneName, sceneData[sceneName].gender, nativeUI.mainMenuPanelsWidget)
		if panelData then
			lastPanelWidget = panelData.panelAreaWidget
			panelsCreated = panelsCreated + 1
			if panelData.isEnabled then
				panelsEnabled = panelsEnabled + 1
				if panelsEnabled == 1 then panelData.panelAreaWidget:SetPadding(0, 0, 0, 0) end
				if not isLeftToRightOrder then
					local padding = panelData.panelAreaWidget:GetPadding()
					padding.left = 10
					panelData.panelAreaWidget:SetPadding(padding)
				end
				tableInsert(nativeUI.mainMenuController.activePanels, panelData)
				panelData.panelIndex = #nativeUI.mainMenuController.activePanels
				lastEnabledPanelData = panelData
			end
		end
		if nativeUI.isBackToMainMenu and (not returnToPanel) and panelData.isEnabled and type(nativeUI.lastSelectionList.sceneId) == 'number' then
			if lastSceneData.id == nativeUI.lastSelectionList.sceneId then returnToPanel = panelData end
		end
	end

	if isUpdatingPanels then
		local oldParent = oldMainMenuPanelsWidget.parentWidget
		if oldParent then oldParent:RemoveChild(oldMainMenuPanelsWidget) end
	end

	registerAllPanelsCallbacks()
	nativeUI.isShowtime = true
	nativeUI.isMainMenu = true
	nativeUI.isSelectionList = false
	nativeUI.mainMenuPanelsWidget:Reparent(parentWidget, -1)

	if nativeUI.isBackToMainMenu then
		if IsDefined(lastShardNotificationController) and IsDefined(lastGameCursorController) and IsDefined(lastSliderController) then
			local lastListCallerId = nativeUI.lastSelectionList.callerId
			local lastListIsPerformerSelectionList = nativeUI.lastSelectionList.isPerformerSelectionList
			local lastListIsDestinationSelectionList = nativeUI.lastSelectionList.isDestinationSelectionList
			local payload = function()
				local initialTargetWidget = lastSliderController.handleWidgetRef
				if returnToPanel and type(lastListCallerId) == 'string' then
					local returnToButton = nil
					if lastListIsPerformerSelectionList then returnToButton = returnToPanel.buttons.performer
					elseif lastListIsDestinationSelectionList then returnToButton = returnToPanel.buttons.destination
					end
					if type(returnToButton) == 'table' and returnToButton.name == lastListCallerId and IsDefined(returnToButton.widget) and returnToButton.isActive and returnToButton.isEnabled then
						initialTargetWidget = returnToButton.widget
						nativeUI.mainMenuController.lastSelectedObject = returnToButton
					end
				end
				local player = GetPlayer()
				if not player:PlayerLastUsedPad() then restoreDefaulCursor() end
				setCursorOverWidgetWithCursorRestore(_, initialTargetWidget, not player:PlayerLastUsedPad())
				local payload = function() lastShardPopupNotificationData.useCursor = true end
				nativeUI.queueTask(payload, false, 0.01)
			end
			if lastSliderController:GetProgress() > 0.001 then nativeUI.queueTask(payload, false, 0.05) else payload() end
		end
	else
		if IsDefined(lastShardNotificationController) and IsDefined(lastGameCursorController) and IsDefined(lastSliderController) then
			local initialTargetWidget = lastSliderController.handleWidgetRef
			local payload = function()
				setCursorOverWidgetWithCursorRestore(_, initialTargetWidget, true)
			end
			nativeUI.queueTask(payload, false, 0.01)
		end
	end
	nativeUI.isBackToMainMenu = false

	if IsDefined(lastSliderController) and lastSliderController.slidingAreaWidgetRef then
		lastSliderController.slidingAreaWidgetRef:SetInteractive(true)
	end

	return nativeUI.mainMenuPanelsWidget
end

local mainMenuControllerTemplate = {
	activePanels = {},
	eventCatcher = nil,
	activeTextColor = "MainColors.Neutral",
	inactiveTextColor = "MainColors.MildBlue",
	highlightTextColor = "MainColors.White",
	lastSelectedObject = nil,
	getLastSelectedObject = function() end,
	shouldSelectObject = function() end,
	moveUp = function() end,
	moveDown = function() end,
	moveLeft = function() end,
	moveRight = function() end,
	buttons = {
		settings = {name = "settings", title = "Settings", isMainMenuButton = true, isInteractiveButton = true, isEnabled = true, isActive = true, type = "button", widget = nil, fontSize = 42, isFixedWidth = true, buttonWidthSyncGroup = 2, setVisible = function() end, getScreenPosition = function() end, setActive = function() end, setText = function() end, onPressed = function() end, onReleased = function() end},
	},
}

function createMainMenu(parentWidget, isUpdate, isMainModCalling)
	togglePerformerPrevievButtonHint(false)
	if nativeUI.isPerformerPreviewShowTime then togglePerformerPreview(false) end
	nativeUI.isPerformerPreviewShowTime = false
	if not isUpdate then nativeUI.mainMenuController = cloneTable(mainMenuControllerTemplate) end
	local thisMainMenu = nativeUI.mainMenuController
	nativeUI.mainMenuController.isInitialized = false
	nativeUI.mainMenuController.activePanels = {}
	nativeUI.mainMenuController.lastSelectedObject = nil
	createMainMenuPanels(parentWidget, isUpdate, isMainModCalling)
	if #nativeUI.mainMenuController.activePanels < 1 then return end

	if nativeSettings and thisMainMenu.buttons then
		local parentWidget = getTopWigetByName(parentWidget, 'vertical_organizer')
		if parentWidget then thisMainMenu.topBarWidget = parentWidget:GetWidget("topBar") end
		if IsDefined(thisMainMenu.topBarWidget) and thisMainMenu.topBarWidget.name.value == "topBar" then
			local activeTextColor = thisMainMenu.activeTextColor
			local inactiveTextColor = thisMainMenu.inactiveTextColor

			if type(thisMainMenu.buttons.settings) == 'table' and thisMainMenu.buttons.settings.isInteractiveButton then
				local buttonData = thisMainMenu.buttons.settings

				local fontSize = 48
				if type(buttonData.fontSize) == 'number' and buttonData.fontSize >= 10 then fontSize = buttonData.fontSize end

				local buttonArea = thisMainMenu.buttonsAreaWidget
				local finalLabelText = buttonData.title or "New Button"
				if uiStrings.nuiUiStrings.nativeUiMenuView.buttons[buttonData.name] then
					local localizedButtonTitle = uiStrings.nuiUiStrings.nativeUiMenuView.buttons[buttonData.name].title
					if type(localizedButtonTitle) == 'string' and stringLen(localizedButtonTitle) > 0 then finalLabelText = localizedButtonTitle end
				end

				buttonData.setActive = function(activate)
					if type(activate) ~= 'boolean' then return end
					if activate then
						if buttonData.isInteractiveButton then buttonData.widget:SetInteractive(true) end
						buttonData.isActive = true
						setWidgetTextLabelColor(buttonData.widgetLabel, activeTextColor)
						return true
					end
					buttonData.widget:SetInteractive(false)
					buttonData.isActive = false
					setWidgetTextLabelColor(buttonData.widgetLabel, inactiveTextColor)
					return true
				end

				local buttonWidth = 100
				if buttonData.isFixedWidth then
					if buttonData.buttonWidthSyncGroup == 1 then
						buttonWidth = mathFloor(13 * fontSize)
					elseif buttonData.buttonWidthSyncGroup == 2 then
						buttonWidth = mathFloor(6.5 * fontSize)
					end
				else
					local finalLabelTextlen = stringLen(finalLabelText)
					buttonWidth = fontSize * finalLabelTextlen * textWidthFactor + 150
				end
				buttonWidth = math.ceil(buttonWidth / 10) * 10
				buttonWidth = RoundF(buttonWidth)

				local buttonSize = {buttonWidth, RoundF(fontSize * 1.75)}
				local buttonAnchorPoint = {0, 0}

				buttonData.widget, buttonData.widgetLabel = createButton(buttonData.name, finalLabelText, fontSize, buttonSize, buttonAnchorPoint, activeTextColor, buttonData.isUpperCase)
				buttonData.widget:SetHAlign(inkEHorizontalAlign.Right)
				buttonData.widget:SetVAlign(inkEVerticalAlign.Center)
				buttonData.widget:SetMargin(0, 30, 100, 0)

				if not buttonData.isActive then buttonData.setActive(false) end
				buttonData.itemIndex = 0

				buttonData.setText = function(text) if type(text) ~= 'string' then return end if not isStringValid(text) then return end buttonData.widgetLabel:SetText(text) return true end
				buttonData.setVisible = function(show) if type(show) ~= 'boolean' then return end buttonData.widget:SetVisible(show) buttonData.isEnabled = show return true end
				if nativeUI.userSettings and type(nativeUI.userSettings.enableNativeSettingsIntegration) == 'boolean' then enableNativeSettingsIntegration = nativeUI.userSettings.enableNativeSettingsIntegration end
				buttonData.isEnabled = isUsingNativeSettings and enableNativeSettingsIntegration
				if not buttonData.isEnabled then buttonData.setVisible(false) end
				buttonData.getScreenPosition = function() return GetScreenPosition(buttonData.widget) end

				buttonData.widget:Reparent(thisMainMenu.topBarWidget, -1)
			end
		end
	end

	setupMainMenuActions(nativeUI.mainMenuController)
	registerMainMenuCallbacks(nativeUI.mainMenuController)
	nativeUI.mainMenuController.isInitialized = true
	return nativeUI.mainMenuController
end

function setupMainMenuActions(thisMainMenu)
	thisMainMenu.shouldSelectObject = function(object)
		if not object then return end
		if not IsDefined(object.widget) then return end
		if not object.widget:IsVisible() then return end
		if not object.isInteractiveButton then return end
		if not object.isActive then return end
		if not object.widget:IsInteractive() then return end
		return true
	end

	if nativeSettings then
		thisMainMenu.buttons.settings.onReleased = function()
			switchToHotscenesSettingsMenu = 0
			local payload = function()
				if not IsDefined(lastShardNotificationController) then return end
				lastShardNotificationController:Close()
				local payload = function()
					if not IsDefined(lastGameuiInGameMenuGameController) then return end
					switchToHotscenesSettingsMenu = os.clock() + 1
					lastGameuiInGameMenuGameController:SpawnMenuInstanceEvent(n"OnOpenPauseMenu")
				end
				nativeUI.queueTask(payload, false, 0.001)
			end
			nativeUI.queueTask(payload, false, 0.5)
		end
	end

	thisMainMenu.getLastSelectedObject = function()
		if not thisMainMenu.shouldSelectObject(thisMainMenu.lastSelectedObject) then return end
		return thisMainMenu.lastSelectedObject
	end

	local alignTopToTop = 1
	local alignBottomToBottom = 2
	local alignMiddleToMiddle = 3

	thisMainMenu.scrollAreaToButton = function(button, alignment)
		if not IsDefined(lastSliderController) then return end
		if not IsDefined(thisMainMenu.scrollAreaWidget) then return end
		if not IsDefined(button.widget) then return end

		if isWidgetWithinWidgetOnScreen(button.widget, thisMainMenu.scrollAreaWidget) then return true end
		if type(alignment) ~= 'number' then alignment = alignBottomToBottom end

		if alignment == alignBottomToBottom then
			local buttonRect = button.getScreenPosition()
			local menuWidgetRect = GetScreenPosition(nativeUI.mainMenuPanelsWidget)
			local scrollAreaRect = GetScreenPosition(thisMainMenu.scrollAreaWidget)
			local viewPortLenght = scrollAreaRect.Bottom - scrollAreaRect.Top
			local desiredBottomPos = buttonRect.Bottom - menuWidgetRect.Top - viewPortLenght
			lastSliderController:ChangeProgress(getScrollRatio(viewPortLenght, menuWidgetRect.Bottom - menuWidgetRect.Top, desiredBottomPos))
			return true
		end
		if alignment == alignTopToTop then
			local buttonRect = button.getScreenPosition()
			local menuWidgetRect = GetScreenPosition(nativeUI.mainMenuPanelsWidget)
			local scrollAreaRect = GetScreenPosition(thisMainMenu.scrollAreaWidget)
			local viewPortLenght = scrollAreaRect.Bottom - scrollAreaRect.Top
			local desiredTopPos = buttonRect.Top - menuWidgetRect.Top
			lastSliderController:ChangeProgress(getScrollRatio(viewPortLenght, menuWidgetRect.Bottom - menuWidgetRect.Top, desiredTopPos))
			return true
		end
		if alignment == alignMiddleToMiddle then
			local buttonRect = button.getScreenPosition()
			local menuWidgetRect = GetScreenPosition(nativeUI.mainMenuPanelsWidget)
			local scrollAreaRect = GetScreenPosition(thisMainMenu.scrollAreaWidget)
			local viewPortLenght = scrollAreaRect.Bottom - scrollAreaRect.Top
			local desiredTopPos = buttonRect.Top - menuWidgetRect.Top - viewPortLenght * 0.5 - (buttonRect.Top - buttonRect.Bottom) * 0.5
			lastSliderController:ChangeProgress(getScrollRatio(viewPortLenght, menuWidgetRect.Bottom - menuWidgetRect.Top, desiredTopPos))
			return true
		end
	end

	thisMainMenu.getMenuSectionPosition = function()
		local menuSectionData = {isInMenu = false, isInSettingsButton = false, panelIndex = 0, row = 0, column = 0, panelId = 0, panelData = nil}
		local result, isInWidget, x, y = isGameCursorWithinWidget(thisMainMenu.scrollAreaWidget)
		if not result then return menuSectionData, x, y end
		if (not isInWidget) and nativeSettings and enableNativeSettingsIntegration and IsDefined(thisMainMenu.buttons.settings.widget) then
			result, isInSettingsButton, x, y = isGameCursorWithinWidget(thisMainMenu.buttons.settings.widget)
			if result and isInSettingsButton then
				menuSectionData.isInSettingsButton = true
				return menuSectionData, x, y
			end
		end
		if isInWidget then
			local thisPanel = nil
			local thisPanelIndex = 0
			for i, panel in ipairs(thisMainMenu.activePanels) do
				if isXYWithinWidgetOnScreen(x, y, panel.panelAreaWidget) then
					menuSectionData.isInMenu = true
					menuSectionData.panelIndex = i
					menuSectionData.panelData = panel
					menuSectionData.panelId = panel.panelId

					local activeRowsCount, activeRowsData = panel.layout.getRightSideActiveRows()
					if activeRowsCount < 1 then return menuSectionData, x, y end
					local row = 0
					local lastRowRect, lastRowIndex
					for ii = 1, activeRowsCount do
						lastRowRect = GetScreenPosition(activeRowsData[ii].widget)
						lastRowIndex = activeRowsData[ii].rowIndex
						if ii == 1 and y <= lastRowRect.Bottom then row = lastRowIndex break end
						if ii == activeRowsCount and y >= lastRowRect.Top then row = lastRowIndex break end
						if y >= lastRowRect.Top and y <= lastRowRect.Bottom then row = lastRowIndex break end
					end
					local performerButtonPos = panel.buttons.performer.getScreenPosition()
					local column = 1
					if x >= performerButtonPos.Left - 2 then column = 2 end
					if x > performerButtonPos.Right + 2 then column = 3 end
					menuSectionData.column = column
					menuSectionData.row = row
					return menuSectionData, x, y
				end
			end
		end
		return menuSectionData, x, y
	end

	local function getTopPanelPerformerButton(menuRect)
		if not menuRect then menuRect = GetScreenPosition(thisMainMenu.scrollAreaWidget) end
		for i = 1, #thisMainMenu.activePanels do
			local button = thisMainMenu.activePanels[i].buttons.performer
			if button then
				local buttonRect = button.getScreenPosition()
				if buttonRect.Top >= menuRect.Top then return button, i end
			end
		end
	end
	local function getBottomPanelPerformerButton(menuRect)
		if not menuRect then menuRect = GetScreenPosition(thisMainMenu.scrollAreaWidget) end
		for i = #thisMainMenu.activePanels, 1, -1 do
			local button = thisMainMenu.activePanels[i].buttons.performer
			if button then
				local buttonRect = button.getScreenPosition()
				if buttonRect.Bottom <= menuRect.Bottom then return button, i end
			end
		end
	end
	local function getBottomPanelCancelButton(menuRect)
		if not menuRect then menuRect = GetScreenPosition(thisMainMenu.scrollAreaWidget) end
		for i = #thisMainMenu.activePanels, 1, -1 do
			local button = thisMainMenu.activePanels[i].buttons.cancel
			if button then
				local buttonRect = button.getScreenPosition()
				if buttonRect.Bottom <= menuRect.Bottom then return button, i end
			end
		end
	end

	local function moveBackToMenu(x, y)
		if not x then return end
		if not y then return end
		local menuRect = GetScreenPosition(thisMainMenu.scrollAreaWidget)
		local isOnLeft = x <= menuRect.Left
		local isOnRight = x >= menuRect.Right
		local isAbove = y <= menuRect.Top
		local isBelow = y >= menuRect.Bottom
		local isWithinVerticalSpace = (not isAbove) and (not isBelow)
		local isWithinHorizontalSpace = (not isOnLeft) and (not isOnRight)

		local function getPerformerButtonByCursorProximity()
			for i = 1, #thisMainMenu.activePanels do
				local button = thisMainMenu.activePanels[i].buttons.performer
				if button then
					local buttonRect = button.getScreenPosition()
					local isButtonInVieport = buttonRect.Top >= menuRect.Top and buttonRect.Bottom <= menuRect.Bottom
					if isButtonInVieport then
						if y <= buttonRect.Bottom then return button end
					end
				end
			end
			return getBottomPanelPerformerButton(menuRect)
		end

		if isOnLeft and isAbove then
			local button = getTopPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isOnLeft and isWithinVerticalSpace then
			local button = getPerformerButtonByCursorProximity()
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isOnLeft and isBelow then
			local button = getBottomPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isOnRight and isAbove then
			local button = getTopPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isOnRight and isWithinVerticalSpace then
			local button = getPerformerButtonByCursorProximity()
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isOnRight and isBelow then
			local button = getBottomPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isWithinHorizontalSpace and isAbove then
			local button = getTopPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isWithinHorizontalSpace and isBelow then
			local button = getBottomPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		elseif isWithinHorizontalSpace and isWithinVerticalSpace then
			local button = getBottomPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button end
			return
		end
		local button = thisMainMenu.activePanels[1].buttons.performer
		if button then thisMainMenu.lastSelectedObject = button end
	end

	thisMainMenu.moveUp = function()
		if not IsDefined(nativeUI.mainMenuPanelsWidget) then return end
		local thisMenuSection, x, y = thisMainMenu.getMenuSectionPosition()
		if thisMenuSection.isInMenu then
			local currentPanel = thisMenuSection.panelIndex
			local currentPanelData = thisMenuSection.panelData
			local currentColumn = thisMenuSection.column
			local currentRowInThisPanel = thisMenuSection.row - 1
			local lastRowInThisPanel = #currentPanelData.layout.cells
			local lastPanel = #thisMainMenu.activePanels
			for i = 1, lastPanel do
				if currentPanelData.isEnabled and currentRowInThisPanel > 0 then
					for ii = currentRowInThisPanel, 1, - 1 do
						local buttonsInCell = currentPanelData.layout.cells[ii][currentColumn]
						local buttonCount = #buttonsInCell
						if buttonCount > 0 then
							for iii = 1, buttonCount do
								local button = currentPanelData.buttons[buttonsInCell[iii]]
								if thisMainMenu.shouldSelectObject(button) then
									thisMainMenu.lastSelectedObject = button
									thisMainMenu.scrollAreaToButton(button, alignBottomToBottom)
									return true
								end
							end
						end
						currentRowInThisPanel = ii
					end
				end
				currentPanel = currentPanel - 1
				if currentPanel < 1 then
					if nativeSettings and enableNativeSettingsIntegration and IsDefined(thisMainMenu.buttons.settings.widget) and thisMainMenu.lastSelectedObject and thisMainMenu.lastSelectedObject.name ~= thisMainMenu.buttons.settings.name then thisMainMenu.lastSelectedObject = thisMainMenu.buttons.settings return true end
					local _, nextPanelIndex = getBottomPanelCancelButton()
					if nextPanelIndex then
						currentPanel = nextPanelIndex
					else
						currentPanel = lastPanel
					end
				end
				currentPanelData = thisMainMenu.activePanels[currentPanel]
				currentRowInThisPanel = #currentPanelData.layout.cells
			end
			thisMainMenu.moveLeft()
		elseif thisMenuSection.isInSettingsButton then
			local menuRect = GetScreenPosition(thisMainMenu.scrollAreaWidget)
			local button = getBottomPanelPerformerButton(menuRect)
			if button then thisMainMenu.lastSelectedObject = button return end
			moveBackToMenu(x, y)
		else
			moveBackToMenu(x, y)
		end
	end
	thisMainMenu.moveDown = function()
		if not IsDefined(nativeUI.mainMenuPanelsWidget) then return end
		local thisMenuSection, x, y = thisMainMenu.getMenuSectionPosition()
		if thisMenuSection.isInMenu then
			local currentPanel = thisMenuSection.panelIndex
			local currentPanelData = thisMenuSection.panelData
			local currentColumn = thisMenuSection.column
			local currentRowInThisPanel = thisMenuSection.row + 1
			local lastRowInThisPanel = #currentPanelData.layout.cells
			local lastPanel = #thisMainMenu.activePanels
			for i = 1, lastPanel do
				if currentPanelData.isEnabled and currentRowInThisPanel > 0 then
					for ii = currentRowInThisPanel, lastRowInThisPanel do
						local buttonsInCell = currentPanelData.layout.cells[ii][currentColumn]
						local buttonCount = #buttonsInCell
						if buttonCount > 0 then
							for iii = 1, buttonCount do
								local button = currentPanelData.buttons[buttonsInCell[iii]]
								if thisMainMenu.shouldSelectObject(button) then
									thisMainMenu.lastSelectedObject = button
									thisMainMenu.scrollAreaToButton(button, alignBottomToBottom)
									return true
								end
							end
						end
						currentRowInThisPanel = ii
					end
				end
				currentPanel = currentPanel + 1
				if currentPanel > lastPanel then
					if nativeSettings and enableNativeSettingsIntegration and IsDefined(thisMainMenu.buttons.settings.widget) and thisMainMenu.lastSelectedObject and thisMainMenu.lastSelectedObject.name ~= thisMainMenu.buttons.settings.name then thisMainMenu.lastSelectedObject = thisMainMenu.buttons.settings return true end
					local _, nextPanelIndex = getTopPanelPerformerButton()
					if nextPanelIndex then
						currentPanel = nextPanelIndex
					else
						currentPanel = 1
					end
				end
				currentPanelData = thisMainMenu.activePanels[currentPanel]
				currentRowInThisPanel = 1
			end
			thisMainMenu.moveRight()
		else
			moveBackToMenu(x, y)
		end
	end
	thisMainMenu.moveLeft = function()
		if not IsDefined(nativeUI.mainMenuPanelsWidget) then return end
		local thisMenuSection, x, y = thisMainMenu.getMenuSectionPosition()
		if thisMenuSection.isInMenu then
			local currentRow = thisMenuSection.row
			local lastRow = #thisMenuSection.panelData.layout.cells
			local lastCellInRow = 3
			local nextCellInRow = thisMenuSection.column - 1
			for i = 1, lastRow do
				local cellsInRow = thisMenuSection.panelData.layout.cells[currentRow]
				lastCellInRow = #cellsInRow
				for ii = nextCellInRow, 1, -1 do
					if nextCellInRow < 1 then break end
					local buttonsInCell = cellsInRow[nextCellInRow]
					local buttonCount = #buttonsInCell
					if buttonCount > 0 then
						for iii = 1, buttonCount do
							local button = thisMenuSection.panelData.buttons[buttonsInCell[iii]]
							if thisMainMenu.shouldSelectObject(button) then
								thisMainMenu.lastSelectedObject = button
								thisMainMenu.scrollAreaToButton(button, alignTopToTop)
								return true
							end
						end
					end
					nextCellInRow = nextCellInRow - 1
				end
				currentRow = currentRow - 1
				if currentRow < 1 then currentRow = lastRow end
				nextCellInRow = lastCellInRow
			end
		else
			moveBackToMenu(x, y)
		end
	end
	thisMainMenu.moveRight = function()
		if not IsDefined(nativeUI.mainMenuPanelsWidget) then return end
		local thisMenuSection, x, y = thisMainMenu.getMenuSectionPosition()
		if thisMenuSection.isInMenu then
			local currentRow = thisMenuSection.row
			local lastRow = #thisMenuSection.panelData.layout.cells
			local lastCellInRow = 3
			local nextCellInRow = thisMenuSection.column + 1
			for i = 1, lastRow do
				local cellsInRow = thisMenuSection.panelData.layout.cells[currentRow]
				lastCellInRow = #cellsInRow
				for ii = nextCellInRow, lastCellInRow do
					if nextCellInRow > lastCellInRow then break end
					local buttonsInCell = cellsInRow[nextCellInRow]
					local buttonCount = #buttonsInCell
					if buttonCount > 0 then
						for iii = 1, buttonCount do
							local button = thisMenuSection.panelData.buttons[buttonsInCell[iii]]
							if thisMainMenu.shouldSelectObject(button) then
								thisMainMenu.lastSelectedObject = button
								thisMainMenu.scrollAreaToButton(button, alignBottomToBottom)
								return true
							end
						end
					end
					nextCellInRow = nextCellInRow + 1
				end
				currentRow = currentRow + 1
				if currentRow > lastRow then currentRow = 1 end
				nextCellInRow = 1
			end
		else
			moveBackToMenu(x, y)
		end
	end
end

function registerMainMenuCallbacks(thisMenuController)
	if not thisMenuController then thisMenuController = nativeUI.mainMenuController end
	if not IsDefined(nativeUI.mainMenuPanelsWidget) then return end
	if not IsDefined(lastShardNotificationController) then return end
	if nativeSettings and IsDefined(thisMenuController.buttons.settings.widget) then
		if not IsDefined(thisMenuController.eventCatcher) then
			thisMenuController.eventCatcher = sampleStyleManagerGameController.new()
			tableInsert(nativeUI.activeInstances, {eventCatcher = thisMenuController.eventCatcher, isMainMenu = true, keepAlive = true, callerData = thisMenuController})
		end
		for i, buttonData in pairs(thisMenuController.buttons) do
			if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
				buttonData.widget:RegisterToCallback('OnPress', thisMenuController.eventCatcher, 'OnState1')
				buttonData.widget:RegisterToCallback('OnRelease', thisMenuController.eventCatcher, 'OnState2')
				buttonData.widget:RegisterToCallback('OnEnter', thisMenuController.eventCatcher, 'OnStyle1')
				buttonData.widget:RegisterToCallback('OnLeave', thisMenuController.eventCatcher, 'OnStyle2')
			end
		end
	end
	tableInsert(nativeUI.activeInstances, {eventCatcher = lastShardNotificationController, isMainMenu = true, callerData = thisMenuController})

	return true
end

function unregisterMainMenuCallbacks(keepSettingsButtonAlive)
	local thisMenuController = nativeUI.mainMenuController
	if type(thisMenuController.buttons) == 'table' and (not keepSettingsButtonAlive) then
		for i, buttonData in pairs(thisMenuController.buttons) do
			if IsDefined(buttonData.widget) and (buttonData.type == 'button' or buttonData.type == 'switch') then
				buttonData.widget:UnregisterFromCallback('OnPress', thisMenuController.eventCatcher, 'OnState1')
				buttonData.widget:UnregisterFromCallback('OnRelease', thisMenuController.eventCatcher, 'OnState2')
				buttonData.widget:UnregisterFromCallback('OnEnter', thisMenuController.eventCatcher, 'OnStyle1')
				buttonData.widget:UnregisterFromCallback('OnLeave', thisMenuController.eventCatcher, 'OnStyle2')
			end
		end
		thisMenuController.eventCatcher = nil
	end
	for i = #nativeUI.activeInstances, 1, -1 do
		if type(nativeUI.activeInstances[i]) == 'table' and nativeUI.activeInstances[i].isMainMenu then
			if nativeUI.activeInstances[i].keepAlive then
				if not keepSettingsButtonAlive then tableRemove(nativeUI.activeInstances, i) end
			else
				tableRemove(nativeUI.activeInstances, i)
			end
		end
	end
	return true
end

function nativeUI.updateUI(isMainModCalling)
	enableNativeSettingsIntegration = nativeUI.userSettings.enableNativeSettingsIntegration
	local result, data = pcall(function()
		if not nativeUI.isShowtime then return end
		if isMainModCalling then
			local shardWindowTitle = uiStrings.nuiUiStrings.nativeUiMenuView.menuWindowTitle or windowTitle
			if nativeUI.isAddOnEnabled() then shardWindowTitle = uiStrings.nuiUiStrings.nativeUiMenuView.menuWindowTitleWithAddOn or windowTitleWithAddOn end
			shardUiTitleTextWidget:SetText(shardWindowTitle)
		end
		if nativeUI.isMainMenu then createMainMenu(lastShardContentsWidget, true, isMainModCalling) return end
		if nativeUI.isSelectionList then updateSelectionListState(nativeUI.lastSelectionList, isMainModCalling) return end
	end)
	if not result then printError(data) end
end

function startMenuMusic()
	if not nativeUI.isShowtime then return end
	GetPlayer():PlaySoundEvent("mus_stout_sexcs_01_START")
end

function stopMenuMusic()
	GetPlayer():StopSoundEvent("mus_stout_sexcs_01_START")
end

function setupObservers()
	local isQuestNodeExecutionAvaliable = type(questsSystem.ExecuteNode) == 'function' and type(CreateNodeRef) == 'function'
	local containerPath = BuildWidgetPath({"layout", "container"})
	local n_inkCanvasWidget = n"inkCanvasWidget"
	local n_inkTextWidget = n"inkTextWidget"
	local n_tintColor = n"tintColor"
	local n_MainColorsBlue = n"MainColors.Blue"
	local n_MainColorsNeutral = n"MainColors.Neutral"
	local fullscreen_main_colors_ResRef = ResRef.FromName("base\\gameplay\\gui\\fullscreen\\fullscreen_main_colors.inkstyle")

	local lastPreviewPerformerId, lastPreviewPerformerAppearanceNameId
	local n_Root = n"Root"
	local preformerPreviewLeftovers
		
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(self)
		if self:IsReplacer() then return end
		isGameLoading = true
		preformerPreviewLeftovers = nil
		unregisterAllCallbacks()
		nativeUI.isShowtime = false
		nativeUI.isMainMenu = false
		nativeUI.isSelectionList = false
		nativeUI.isBackToMainMenu = false
		nativeUI.lastSelectionListReturn = {}
		nativeUI.mainMenuController = {}
		nativeUI.mainMenuPanelsWidget = nil
		nativeUI.lastSelectionList = {}
		nativeUI.activeInstances = {}
		lastShardPopupController = nil
		lastShardPopupNotificationData = nil
		lastShardTitleWidget = nil
		lastShardContentsWidget = nil
		lastTopBarIconWidget = nil
		lastSliderHandleWidget = nil
		lastSliderController = nil
		lastShardNotificationController = nil
		isDelayedButtonActionAllowed = true
		isItMyShard = false
		isPerformerPreviewSupportEnabled = false
		questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support", 0)
		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview", 0)
		questsSystem:SetFactStr("mod_hotscenes_main_menu_support_activated", 0)
		toggleLockIncomingCalls(false, true)
		isPreviewTriggerReactivatedInThisSession = false
		lastPreviewPerformerId = nil
		lastPreviewPerformerAppearanceNameId = nil
		nativeUI.isPerformerPreviewShowTime = false
		local lang = getSelectedGameUILanguage()
		if type(lang) == 'string' then currentGameUiLanguage = lang end
	end)
	local GameFindEntityByID = Game.FindEntityByID
	ObserveBefore('PlayerPuppet', 'OnMakePlayerVisibleAfterSpawn', function(self)
		isGameLoading = false
		if self:IsReplacer() then return end
		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview", 0)
		despawnPreviewLeftovers()
	end)

	ObserveAfter('EquipmentSystemPlayerData', 'OnRestored', function(this)
		if not isGameLoading then return end
		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview", 0)
		resetMenuSupport()
	end)

	if nativeSettings then
		local lastNsInitTime = 0
		ObserveBefore("SettingsMainGameController", "OnInitialize", function (this)
			lastSettingsMainGameController = RefWeak(this)
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
			lastSettingsMainGameController = RefWeak(this)
			setupNativeSettings(true)
		end)
		local shouldResetSettingsPanel, shouldReloadMenu, shouldRestoreDefaultSettings
		ObserveBefore("SettingsMainGameController", "RequestRestoreDefaults", function(this)
			shouldRestoreDefaultSettings = false
			if not nativeSettings then return end
			if not nativeSettings.fromMods then return end

			local currentOption = nativeSettings.data[nativeSettings.currentTab]
			if not currentOption then return end
			if currentOption.isRedMod then return end
			if currentOption.path ~= modName then return end

			shouldRestoreDefaultSettings = true
		end)
		ObserveAfter("SettingsMainGameController", "RequestRestoreDefaults", function(this)
			if not shouldRestoreDefaultSettings then return end
			shouldRestoreDefaultSettings = false
			setupNativeSettings(true, true)
			for k, v in pairs(nativeSettingsOptions) do
				if type(v) == 'table' and (not v.isOpenModMenuButton) and type(v.callback) == 'function' and v.defaultValue ~= nil and v.defaultValue ~= v.state then v.callback(v.defaultValue) end
			end
			local shouldSaveSettings
			for k, v in pairs(nativeUI.defaultUserSettings) do
				local currentValue = nativeUI.userSettings[k]
				if type(v) == type(currentValue) and v ~= currentValue then
					nativeUI.userSettings[k] = v
					shouldSaveSettings = true
				end
			end
			if shouldSaveSettings then nativeUI.saveUserSettings() end
			setupNativeSettings(true)
		end)
		ObserveAfter('SettingsSelectorControllerBool', 'OnInitialize', function (this)
			if not nativeSettings then return end
			if not nativeSettingsOptions.openModMenu then return end
			if not IsDefined(nativeSettingsOptions.openModMenu.controller) then nativeSettingsOptions.openModMenu.isAmended = false return end
			if nativeSettingsOptions.openModMenu.isAmended then return end

			if not nativeSettings.currentTab then return end
			local currentOption = nativeSettings.data[nativeSettings.currentTab]
			if not currentOption then return end
			if currentOption.path ~= modName then return end

			local rootWidget = nativeSettingsOptions.openModMenu.controller:GetRootWidget()
			if not rootWidget then return end
			if rootWidget.name.value ~= nativeSettingsOptions.openModMenu.widgetName then return end
			local container = rootWidget:GetWidget(containerPath)
			if not container then return end
			if container.name.value ~= "container" then return end
			local border = container:GetWidget("bk_border")
			if not border then return end
			if border.name.value ~= "bk_border" then return end
			local bk_fill = container:GetWidget("bk_fill")
			if not bk_fill then return end
			if bk_fill.name.value ~= "bk_fill" then return end

			local labelParent, textLabel = nil, nil
			for i = container:GetNumChildren()-1, 0 ,-1 do
				labelParent = container:GetWidget(i)
				if labelParent:IsA(n_inkCanvasWidget) and labelParent:GetNumChildren() == 1 then
					textLabel = labelParent:GetWidget(0)
					if textLabel:IsA(n_inkTextWidget) and textLabel:GetText() == nativeSettingsOptions.openModMenu.buttonText then break else textLabel = nil end
				end
			end
			if not textLabel then return end

			local borderMargin = border:GetMargin()
			borderMargin.left = - borderMargin.right
			border:SetMargin(borderMargin)
			bk_fill:SetMargin(0, 0, 0, 0)
			textLabel:SetStyle(fullscreen_main_colors_ResRef)
			textLabel:BindProperty(n_tintColor, n_MainColorsBlue)
			textLabel:SetLetterCase(textLetterCase.UpperCase)
			local labelParentMargin = labelParent:GetMargin()
			labelParentMargin.left = 0
			labelParent:SetMargin(labelParentMargin)
			labelParent:SetAnchor(inkEAnchor.TopCenter)
			nativeSettingsOptions.openModMenu.isAmended = true
		end)

		ObserveAfter('MenuScenario_PauseMenu', 'OnEnterScenario', function(this) lastPauseMenu = RefWeak(this) end)
		ObserveAfter('MenuScenario_PauseMenu', 'OnSwitchToSettings', function(this) lastPauseMenu = RefWeak(this) end)
		ObserveAfter("MenuScenario_Idle", "OnOpenPauseMenu", function(this)
			if not isUsingNativeSettings then return end
			if not enableNativeSettingsIntegration then return end
			if os.clock() > switchToHotscenesSettingsMenu then return end
			switchToHotscenesSettingsMenu = os.clock() + 1
		end)
		ObserveAfter('PauseMenuGameController', 'PopulateMenuItemList', function(this)
			if not isUsingNativeSettings then return end
			if not enableNativeSettingsIntegration then return end
			if os.clock() > switchToHotscenesSettingsMenu then return end
			nativeSettings.fromMods = true
			this.menuEventDispatcher:SpawnEvent(n"OnSwitchToSettings")
		end)

		ObserveBefore("SettingsMainGameController", "PopulateCategories", function(this)
			if not isUsingNativeSettings then return end
			if not enableNativeSettingsIntegration then return end
			if not nativeSettings.fromMods then return end
			if os.clock() > switchToHotscenesSettingsMenu then return end
			switchToHotscenesSettingsMenu = 0
			local timeout = os.clock() + 1
			local payload = function()
				if os.clock() > timeout then return true end
				if not nativeSettings.tabSizeCache then return false end

				local pages = #nativeSettings.tabSizeCache
				local lookedPage, lookedIndex = 0, 0
				local isFound = false
				if pages < 2 then
					lookedPage = 1
					local sourceData = this.data
					for i = 1, #sourceData do
						if sourceData[i].label.value == uiStrings.nuiUiStrings.nativeUiSettingsView.modDisplayName then
							lookedIndex = i isFound = true break
						end
					end
				else
					for page, modsOnPage in ipairs(nativeSettings.tabSizeCache) do
						for i = 1, #modsOnPage do
							if modsOnPage[i] == uiStrings.nuiUiStrings.nativeUiSettingsView.modDisplayName then
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

				local currentIndex = this.selectorCtrl:GetToggledIndex()
				if not lookedPage == nativeSettings.currentPage then return true end

				lookedIndex = lookedIndex - 1
				if (not isPageSwitched) and currentIndex == lookedIndex then return true end

				local payload = function()
					this.selectorCtrl:SetToggledIndex(lookedIndex)
				end
				if isPageSwitched then nativeUI.queueTask(payload, false, 0.05) else nativeUI.queueTask(payload, false, 0.001) end
				return true
			end
			nativeUI.queueTask(payload, false, 0.001, 0.001, false)
		end)
		ObserveAfter("gameuiInGameMenuGameController", "OnInitialize", function(this) lastGameuiInGameMenuGameController = RefWeak(this) end)
		ObserveAfter("gameuiInGameMenuGameController", "OnPlayerAttach", function(this) lastGameuiInGameMenuGameController = RefWeak(this) end)
		ObserveAfter("gameuiInGameMenuGameController", "OnEquipmentChanged", function(this) lastGameuiInGameMenuGameController = RefWeak(this) end)
		ObserveAfter("gameuiInGameMenuGameController", "OnAction", function(this) lastGameuiInGameMenuGameController = RefWeak(this) end)
	end

	Observe('CursorGameController', 'OnSetCursorVisibility', function(this) lastGameCursorController = RefWeak(this) end)
	Observe('CursorGameController', 'OnSetCursorType', function(this) lastGameCursorController = RefWeak(this) end)

	local wasPerformerPreviewActivated
	ObserveAfter("ShardNotificationController", "OnInitialize", function(this);
		lastShardNotificationController = this
		isItMyShard = false
		wasPerformerPreviewActivated = false
		isPerformerPreviewSupportEnabled = false
		nativeUI.isPerformerPreviewShowTime = false
		if this.data.isCrypted then return end
		if this.data.entry then return end
		if not this.titleRef.widget then return end
		if not this.longTextHolderRef.widget then return end
		if this.data.title ~= shardUiTitle then return end
		if this.data.text ~= shardUiText then return end
		isItMyShard = true

		lastShardTitleWidget = RefWeak(this.titleRef.widget)
		lastShardContentsWidget = RefWeak(this.longTextHolderRef.widget.parentWidget)
		local lookedWidgets = {
			{name = "topBar", type = "inkFlexWidget"},
			{name = "Handle", type = "inkRectangleWidget"}
		}
		local searchResults = findWigetsInWidget(this:GetRootCompoundWidget(), lookedWidgets)
		if searchResults then
			if searchResults[1].handle then
				local topBarIconWidget = searchResults[1].handle:GetWidget("icon")
				if topBarIconWidget and topBarIconWidget.name.value == "icon" then lastTopBarIconWidget = topBarIconWidget end
			end
			if searchResults[2].handle then lastSliderHandleWidget = searchResults[2].handle end
		end
		if lastShardContentsWidget:IsA("inkScrollAreaWidget") then
			lastShardContentsWidget:RemoveAllChildren()
		elseif lastShardContentsWidget:IsA("inkCompoundWidget") then
			for i = 1, lastShardContentsWidget:GetNumChildren() - 1 do
				local widget = lastShardContentsWidget:GetWidget(i)
				if widget and (not widget:IsA("inkCompoundWidget")) then lastShardContentsWidget:RemoveChild(widget) end
			end
		end
	end)

	local cinematicTier = 4

	function isOpenPreviewAllowedBySettings()
		if not nativeUI.userSettings.enableHotscenesAddon then return end
		if not nativeUI.userSettings.enablePerformerPreviewSupport then return end
		return true
	end

	function reportPerformerPreviewAvailability(wasGameLoading)
		local msg = "Hotscenes: "
		if not isPerformerPreviewSupported then
			return msg.."Performer Preview is not available in this version of the game. Please update your game."
		elseif not isKnownName("mod_hotscenes_performer_preview_available") then
			return msg.."Performer Preview is not available because the Add-on is either not installed or outdated. Please install or update the Add-on: https://www.nexusmods.com/cyberpunk2077/mods/11772"
		elseif questsSystem:GetFactStr("mod_hotscenes_main_menu_support_activated") < 1 then
			return msg.."Performer Preview is not available because the Add-on is not activated. Please visit any of V\'s apartments to activate it."
		elseif wasGameLoading then
			return msg.."Performer Preview is not available yet as the game is still loading. Please try again shortly."
		elseif questsSystem:GetFactStr("mod_hotscenes_main_menu_support_on") < 1 then
			return msg.."Performer Preview is not available yet. Please try again later."
		end
		return msg.."Performer Preview is available."
	end

	function resetMenuSupport(delay, force)
		if (not force) and questsSystem:GetFactStr("mod_hotscenes_main_menu_support_on") < 1 then return end
		if not isKnownName("mod_hotscenes_performer_preview_reset_patched") then return end
		local payload = function()
			questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support_reset", 1)
			local payload = function() questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support_reset", 0) toggleLockGameSaving(false) end
			nativeUI.queueTask(payload, false, 1)
		end
		if type(delay) == 'number' and delay > 0 then
			nativeUI.queueTask(payload, false, delay)
		else
			payload()
		end
	end

	function toggleLockGameSaving(lockSaves)
		if lockSaves then SaveLocksManager.RequestSaveLockAdd("PersonalLink") return end
		SaveLocksManager.RequestSaveLockRemove("PersonalLink")
	end

	function isPerformerPreviewAvailable()
		if not isPerformerPreviewSupported then return end
		if not nativeUI.isPerformerPreviewSetupDone then return end
		if questsSystem:GetFactStr("mod_hotscenes_main_menu_support_activated") < 1 then return end
		if not isKnownName("mod_hotscenes_performer_preview_available") then return end
		return true
	end

	function isMenuSupportActive()
		return questsSystem:GetFactStr("mod_hotscenes_main_menu_support_on") > 0
	end

	function toggleLockIncomingCalls(lock, force)
		if (not force) and (not isPerformerPreviewAvailable()) then return end
		if lock then questsSystem:SetFactStr("holo_setup_active", 1) return end
		questsSystem:SetFactStr("holo_setup_active", 0)
	end

	CName.add("mod_hotscenes_god_mode")
	function togglePlayerVisible(setVisible, player)
		player = player or GetPlayer()
		if not player then return end
		if not setVisible then
			player:SetInvisible(true);
			godModeSystem:AddGodMode(player:GetEntityID(), gameGodModeType.Invulnerable, "mod_hotscenes_god_mode");
			return
		end
		player:SetInvisible(false);
		godModeSystem:RemoveGodMode(player:GetEntityID(), gameGodModeType.Invulnerable, "mod_hotscenes_god_mode");
	end

	local femalePlayerGendersTable = {t"Character.TPP_Player_Cutscene_Female_inline0"}
	local malePlayerGendersTable = {t"Character.TPP_Player_Cutscene_Male_inline0"}
	local hasDefaultPerformerBackup = TweakDB:GetRecord("Character.hey_gle_prostitute_female_backup_mod_hotscenes") ~= nil and TweakDB:GetRecord("Character.hey_gle_prostitute_male_backup_mod_hotscenes") ~= nil and TweakDB:GetRecord("Character.wbr_jpn_prostitute_female_backup_mod_hotscenes") ~= nil and TweakDB:GetRecord("Character.wbr_jpn_prostitute_male_backup_mod_hotscenes") ~= nil
	function setupPerformerPreviewCharacters(selectedItemIndex, sceneData)
		if type(selectedItemIndex) ~= 'number' then return end
		if type(sceneData) ~= 'table' then return end
		local performerName = sceneData.performersIndex[selectedItemIndex]
		if type(performerName) ~= 'string' then return end
		local sceneName = sceneData.sceneName
		local gender = sceneData.gender

		local path, isPlayer, isPlayerIncognito = nativeUI.getPerformerDataForPreview(performerName, sceneName, gender)
		if type(path) ~= 'string' then return end

		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview_is_male_scene", 0)
		if gender == "female" then
			if isPlayer then
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.entityTemplatePath", TweakDB:GetFlat("Character.TPP_Player_Cutscene_Female.entityTemplatePath"))
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.genders", femalePlayerGendersTable)
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.appearanceName", "TPP_Body")
				if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.TPP_Player_Cutscene_Female.attachmentSlots")) end
			elseif sceneName == "Glen" then
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.entityTemplatePath", path)
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.genders", {})
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.appearanceName", "service__sexworker_wa__ow__luxury_01")
				if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.hey_gle_prostitute_female_backup_mod_hotscenes.attachmentSlots")) end
			else
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.entityTemplatePath", path)
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.genders", {})
				TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.appearanceName", "service__sexworker_wa__ow__poor_01")
				if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.wbr_jpn_prostitute_female_backup_mod_hotscenes.attachmentSlots")) end
			end
			return
		end
		if gender ~= "male" then return end
		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview_is_male_scene", 1)
		if isPlayer then
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.entityTemplatePath", TweakDB:GetFlat("Character.TPP_Player_Cutscene_Male.entityTemplatePath"))
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.genders", malePlayerGendersTable)
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.appearanceName", "TPP_Body")
			if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.TPP_Player_Cutscene_Male.attachmentSlots")) end
		elseif sceneName == "Glen" then
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.entityTemplatePath", path)
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.genders", {})
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.appearanceName", "service__sexworker_ma__ow__luxury_01")
			if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.hey_gle_prostitute_male_backup_mod_hotscenes.attachmentSlots")) end
		else
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.entityTemplatePath", path)
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.genders", {})
			TweakDB:SetFlat("Character.preview_cc_prostitute_male_mod_hotscenes.appearanceName", "service__sexworker_ma__ow__poor_01")
			if hasDefaultPerformerBackup then TweakDB:SetFlat("Character.preview_cc_prostitute_female_mod_hotscenes.attachmentSlots", TweakDB:GetFlat("Character.wbr_jpn_prostitute_male_backup_mod_hotscenes.attachmentSlots")) end
		end
		return
	end

	local lastButtonHintWidget, lastButtonHintCtl, lastActionName
	local showCooldown = 0
	function togglePerformerPreview(show)
		if not isItMyShard then return end
		if not isMenuSupportActive() then return end
		if not isPerformerPreviewAvailable() then return end
		if show then
			if not nativeUI.isPerformerPreviewShowTime then return end
			if not isOpenPreviewAllowedBySettings() then return end
			local curTime = os.clock()
			if showCooldown > curTime then return end
			wasPerformerPreviewActivated = true
			questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview", 1);
			questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support", 1)
			showCooldown = curTime + 0.1
			local payload = function() if IsDefined(lastButtonHintCtl) and lastActionName then lastButtonHintCtl:SetInputActionLabel(lastActionName, GetLocalizedText(uiStrings.nuiUiStrings.nativeUiSelectionListView.buttonHints.hidePreview.title)) end end
			nativeUI.queueTask(payload, false, buttonDelay)
			return
		end
		if questsSystem:GetFactStr("mod_hotscenes_main_menu_support_on") < 1 then return end
		questsSystem:SetFactStr("mod_hotscenes_main_menu_request_preview", 2);
		questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support", 1)
		local payload = function() if IsDefined(lastButtonHintCtl) and lastActionName then lastButtonHintCtl:SetInputActionLabel(lastActionName, GetLocalizedText(uiStrings.nuiUiStrings.nativeUiSelectionListView.buttonHints.showPreview.title)) end end
		nativeUI.queueTask(payload, false, buttonDelay)
	end

	local lastKnownPerformerPreviewLabelStr
	function updatePerformerPreviewLabel(labelStr)
		if not nativeUI.isPerformerPreviewShowTime then return end
		if type(labelStr) ~= 'string' then return end
		lastKnownPerformerPreviewLabelStr = labelStr
		if not IsDefined(lastHudPhoneAvatarController) then return end
		lastHudPhoneAvatarController.ContactName:SetText(labelStr)
	end

	function addPrevievButtonHint(actionName, label, buttonHintRef)
		if not IsDefined(lastShardNotificationController) then return end
		if not IsDefined(buttonHintRef.widget) then return end
		if not isStringValid(label) then return end
		local widget, buttonHint, isReusingWidget
		if IsDefined(lastButtonHintWidget) and IsDefined(lastButtonHintCtl) then
			buttonHint = lastButtonHintCtl
			isReusingWidget = true
		else
			local buttonController = inkWidgetRef.GetController(buttonHintRef);
			buttonController:RegisterToCallback("OnButtonClick", lastShardNotificationController, "OnCrackClick");
			widget = lastShardNotificationController:SpawnFromExternal(inkWidgetRef.Get(buttonHintRef), ResRef.FromName("base\\gameplay\\gui\\common\\buttons\\base_buttons.inkwidget"), "inputDisplayLabelFlex");
			buttonHint = widget:GetController()
			lastButtonHintWidget = RefWeak(widget)
			lastButtonHintCtl = RefWeak(buttonHint)
		end
		lastActionName = actionName
		buttonHint:SetInputActionLabel(actionName, GetLocalizedText(label));
		if isReusingWidget then return end
		widget:SetHAlign(inkEHorizontalAlign.Center);
		widget:SetVAlign(inkEVerticalAlign.Center);
		widget:SetMargin(20, 0, 20, 0);
	end

	function togglePerformerPrevievButtonHint(show, force)
		if not isItMyShard then return end
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not IsDefined(lastShardNotificationController) then return end
		if not force then
			if not isPerformerPreviewAvailable() then  return end
			if not isMenuSupportActive() then return end
		end
		if show then
			if not nativeUI.isPerformerPreviewShowTime then return end
			if not isOpenPreviewAllowedBySettings() then return end
			inkWidgetRef.SetVisible(lastShardNotificationController.buttonHintsSecondaryManagerParentRef, true);
			addPrevievButtonHint(n"popup_goto", uiStrings.nuiUiStrings.nativeUiSelectionListView.buttonHints.showPreview.title, lastShardNotificationController.buttonHintsSecondaryManagerParentRef);
			return
		end
		inkWidgetRef.SetVisible(lastShardNotificationController.buttonHintsSecondaryManagerParentRef, false);
	end

	local n_vignette = n"vignette"
	local n_ui_menu_open = n"ui_menu_open"
	local n_global_menu_ingame_open = n"global_menu_ingame_open"
	local n_global_menu_phone_open = n"global_menu_phone_open"
	local n_global_menu_ingame_close = n"global_menu_ingame_close"
	local n_global_menu_phone_close = n"global_menu_phone_close"
	local n_inkModalPopupState = n"inkModalPopupState"

	local backgroundVignette
	local newBackgroundVignette

	local isCinematicControlAvailable = type(nativeUI.getCinematicMode) == 'function' and type(nativeUI.setCinematicMode) == 'function'

	if ShardNotificationController.PauseGameState and isCinematicControlAvailable and nativeUI.isPerformerPreviewSetupDone then
		isPerformerPreviewSupported = true
		nativeUI.isPerformerPreviewSupported = true

		local function cloneBackgroundVignetteWidget(source, oldWidget)
			if IsDefined(oldWidget) then return oldWidget end
			if not IsDefined(source) then return end
			if not source:IsA("inkImageWidget") then return end
			local newWidget = inkImageWidget.new()
			newWidget:SetVisible(false)
			newWidget:SetName(source.name)
			newWidget:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\widgets\\notifications\\vignette.inkatlas'))
			newWidget:SetActiveTextureType(source:GetActiveTextureType())
			newWidget:SetTexturePart(source:GetTexturePart())
			newWidget:SetTintColor(source:GetTintColor())
			newWidget:SetOpacity(source:GetOpacity())
			newWidget:SetAnchor(source:GetAnchor())
			newWidget:SetAnchorPoint(source:GetAnchorPoint())
			newWidget.nineSliceScale = source.nineSliceScale
			newWidget.useNineSliceScale = source.useNineSliceScale
			newWidget:SetMargin(source:GetMargin())
			newWidget:SetContentHAlign(source:GetContentHAlign())
			newWidget:SetContentVAlign(source:GetContentVAlign())
			newWidget:SetSizeRule(source:GetSizeRule())
			newWidget:SetSize(source:GetSize())
			newWidget:SetSizeCoefficient(source:GetSizeCoefficient())
			newWidget:SetScale(source:GetScale())
			newWidget:SetTranslation(source:GetTranslation())
			newWidget:SetFitToContent(source:GetFitToContent())
			return RefWeak(newWidget)
		end
		ObserveAfter("HudPhoneAvatarController", "OnInitialize", function(this);
			if not isItMyShard then return end
			if nativeUI.isModDisabled then return end
			if nativeUI.isNudityCensored then return end
			if not IsDefined(backgroundVignette) then return end
			if not isPerformerPreviewAvailable() then return end
			local root
			pcall(function() root = this:GetRootWidget().parentWidget.parentWidget.parentWidget.parentWidget.parentWidget end)
			if not root then return end
			if root.name ~= n_Root then return end
			newBackgroundVignette = cloneBackgroundVignetteWidget(backgroundVignette, newBackgroundVignette)
			if not newBackgroundVignette then return end
			backgroundVignette:SetVisible(false)
			newBackgroundVignette:Reparent(root, -1)
			newBackgroundVignette:SetVisible(true)
		end)
		ObserveAfter("HudPhoneAvatarController", "RefreshView", function(this)
			if not isItMyShard then return end
			if nativeUI.isModDisabled then return end
			if nativeUI.isNudityCensored then return end
			if not nativeUI.isPerformerPreviewShowTime then end
			if not isPerformerPreviewAvailable() then return end
			lastHudPhoneAvatarController = RefWeak(this)
			this.ContactName.widget.wrappingInfo = textWrappingInfo.new()
			this.ContactName:SetText(lastKnownPerformerPreviewLabelStr or "Hotscenes Performer")
		end)
		Override("ShardNotificationController", "PauseGameState", function(this, enable, wrappedMethod)
			if not isItMyShard then return wrappedMethod(enable) end
			if nativeUI.isModDisabled then return wrappedMethod(enable) end
			if nativeUI.isNudityCensored then return wrappedMethod(enable) end

			local wasGameLoading = isGameLoading
			local payload = function() print(reportPerformerPreviewAvailability(wasGameLoading)) end
			nativeUI.queueTask(payload, false, 0.5)
			if isGameLoading then return wrappedMethod(enable) end

			if enable and (not isOpenPreviewAllowedBySettings()) then return wrappedMethod(enable) end
			if not isPerformerPreviewAvailable() then return wrappedMethod(enable) end

			local player = GetPlayer()

			if not enable then
				player:PlaySoundEvent(n_global_menu_ingame_close)
				player:PlaySoundEvent(n_global_menu_phone_close)
				togglePlayerVisible(true, player)
				if isMenuSupportActive(player) then
					questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support", 1)
					nativeUI.setCinematicMode(false)
				end
				nativeUI.isPerformerPreviewShowTime = false
				local payload = toggleLockGameSaving(false)
				nativeUI.queueTask(payload, false, 0.1)
				return wrappedMethod(enable)
			end

			isPerformerPreviewSupportEnabled = true
			toggleLockGameSaving(true)
			togglePlayerVisible(false, player)
			player:PlaySoundEvent(n_ui_menu_open)
			player:PlaySoundEvent(n_global_menu_ingame_open)
			player:PlaySoundEvent(n_global_menu_phone_open)
			if not isMenuSupportActive(player) then
				questsSystem:SetFactStr("mod_hotscenes_request_main_menu_support", 1)
				nativeUI.setCinematicMode(true, cinematicTier, true)
			end

			local vignette = this:GetRootWidget():GetWidget(n_vignette)
			if vignette and vignette.name == n_vignette then
				backgroundVignette = RefWeak(vignette)
			end
			uiSystem:RequestNewVisualState(n_inkModalPopupState);
			PopupStateUtils.SetBackgroundBlur(this, true);
		end)
		Override("ShardNotificationController", "OnCrackClick", function(this, controller, wrappedMethod)
			if not (isItMyShard and nativeUI.isPerformerPreviewShowTime and isPerformerPreviewAvailable()) then return wrappedMethod(controller) end
			nativeUI.userSettings.keepShowingPerformerPreview = not nativeUI.userSettings.keepShowingPerformerPreview
			togglePerformerPreview(nativeUI.userSettings.keepShowingPerformerPreview, true)
			nativeUI.saveUserSettings()
			return true
		end)
	end

	local notificationsContainerRootWidgetName = "NotificationsContainer"
	local notificationsRootNotificationsWidgetName = "RootNotifications"
	local shardContentsWidgetPath = BuildWidgetPath({"container", "Panel", "vertical_organizer", "contentArea", "EntryScrollArea", "inkVerticalPanelWidget8"})
	local topIconWidgetPath = BuildWidgetPath({"container", "Panel", "vertical_organizer", "topBar", "icon"})
	local sliderHandleWidgetPath = BuildWidgetPath({"container", "Panel", "vertical_organizer", "contentArea", "Slider", "slidingArea", "Handle"})

	local isWaitingForShardWidgetEventName = n"mod_hotscenes_waiting_for_shard_widget"
	local isWaitingForShardWidgetEvent = CommunicationEvent.new()
	local isWaitingForShardWidgetEventTimeout = 0
	local showWidgetsDelay = 0
	isWaitingForShardWidgetEvent.name = isWaitingForShardWidgetEventName
	isWaitingForShardWidgetEvent.sender = entEntityID.new({hash = 1ULL})

	function queueWaitingForShardWidgetEvent(player)
		if os.clock() > isWaitingForShardWidgetEventTimeout then return end
		if not player then player = GetPlayer() end
		player:QueueEvent(isWaitingForShardWidgetEvent)
		return true
	end

	function handleWaitingForShardWidgetEvent(this, evt)
		if not IsDefined(lastShardPopupController) then return end
		if evt.name ~= isWaitingForShardWidgetEventName then return end
		local rootWidget = lastShardPopupController:GetRootWidget()
		if not rootWidget then return end
		local notificationsContainerRoot = rootWidget:GetWidget(notificationsContainerRootWidgetName)
		if not (notificationsContainerRoot and notificationsContainerRoot.name.value == notificationsContainerRootWidgetName) then return end
		local childCount =  notificationsContainerRoot:GetNumChildren()

		local notificationsRootNotificationsWidget
		local shardContentsWidget = nil
		if IsDefined(lastShardContentsWidget) then
			shardContentsWidget = lastShardContentsWidget
			notificationsRootNotificationsWidget = lastShardNotificationController:GetRootCompoundWidget()
		elseif childCount > 0 then
			for i = 0, childCount -1 do
				notificationsRootNotificationsWidget = notificationsContainerRoot:GetWidget(i)
				if notificationsRootNotificationsWidget then
					notificationsRootNotificationsWidget = notificationsRootNotificationsWidget:GetWidget(notificationsRootNotificationsWidgetName)
					if notificationsRootNotificationsWidget and notificationsRootNotificationsWidget.name.value == notificationsRootNotificationsWidgetName then break end
					notificationsRootNotificationsWidget = nil
				end
			end
			if notificationsRootNotificationsWidget then
				shardContentsWidget = notificationsRootNotificationsWidget:GetWidget(shardContentsWidgetPath)
			end
		end

		if not shardContentsWidget then
			showWidgetsDelay = os.clock() + 0.5
			return queueWaitingForShardWidgetEvent(this)
		else
			local topBarIconWidget = notificationsRootNotificationsWidget:GetWidget(topIconWidgetPath)
			if not topBarIconWidget and IsDefined(lastTopBarIconWidget) then topBarIconWidget = lastTopBarIconWidget end
			if topBarIconWidget and topBarIconWidget:IsA('inkImageWidget') then
				topBarIconWidget:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\fullscreen\\hub_menu\\hub_atlas.inkatlas'))
				topBarIconWidget:SetTexturePart('ico_hairdresser_hub')
				topBarIconWidget:BindProperty(n_tintColor, n_MainColorsBlue)
				local titleWidget = topBarIconWidget.parentWidget:GetWidget(1)
				if not titleWidget and IsDefined(lastShardTitleWidget) then titleWidget = lastShardTitleWidget end
				if titleWidget and titleWidget:IsA('inkTextWidget') then
					shardUiTitleTextWidget = RefWeak(titleWidget)
					local shardWindowTitle = uiStrings.nuiUiStrings.nativeUiMenuView.menuWindowTitle or windowTitle
					if nativeUI.isAddOnEnabled() then shardWindowTitle = uiStrings.nuiUiStrings.nativeUiMenuView.menuWindowTitleWithAddOn or windowTitleWithAddOn end
					shardUiTitleTextWidget:SetText(shardWindowTitle)
					if nativeUI.isCustomTriggerQuestActive() then setWidgetTextLabelColor(titleWidget, n_MainColorsBlue) else setWidgetTextLabelColor(titleWidget, n_MainColorsNeutral) end
				end
			end
			lastShardContentsWidget = RefWeak(shardContentsWidget)
			if os.clock() < showWidgetsDelay then return queueWaitingForShardWidgetEvent(this) end

			local numChildren = shardContentsWidget:GetNumChildren()
			for i = 0, numChildren -1 do shardContentsWidget:GetWidget(i):SetVisible(false) end
			createMainMenu(lastShardContentsWidget)

			if IsDefined(lastShardPopupNotificationData) then
				lastShardPopupNotificationData.useCursor = true
				if IsDefined(lastSliderController) and IsDefined(lastSliderController.handleWidgetRef) then
					lastSliderController.handleWidgetRef:SetInteractive(true)
				else
					local sliderHandle = notificationsRootNotificationsWidget:GetWidget(sliderHandleWidgetPath)
					if sliderHandle then sliderHandle:SetInteractive(true) end
				end
			end
			return true
		end
	end

	ObserveAfter('ScriptedPuppet', 'OnCommunicationEvent', function(this, evt)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not evt:IsA('CommunicationEvent') then return end
		if evt.sender.hash ~= this:GetEntityID().hash then return end
		handleWaitingForShardWidgetEvent(this, evt)
	end)

	Observe("inkSliderController", "OnInitialize", function(this);
		lastSliderController = RefWeak(this);
	end);
	ObserveAfter("inkSliderController", "OnRelease", function(this);
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		lastSliderController = RefWeak(this);
		if not IsDefined(lastShardContentsWidget) then return end
		this.handleWidgetRef:BindProperty(n_tintColor, n_MainColorsBlue)
	end);
	ObserveAfter("inkSliderController", "OnHoverOut", function(this);
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		lastSliderController = RefWeak(this);
		if this.isDragging then return end
		if not IsDefined(lastShardContentsWidget) then return end
		this.handleWidgetRef:BindProperty(n_tintColor, n_MainColorsBlue)
	end);
	ObserveAfter("PopupsManager", "ShowGameNotification", function(this, notificationData);
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not this.shardReadData then return end
		if this.shardReadData.entry then return end
		if this.shardReadData.isCrypted then return end
		if this.shardReadData.title ~= shardUiTitle then return end
		if this.shardReadData.text ~= shardUiText then return end
		local rootWidget = this:GetRootWidget()
		if not rootWidget then return end
		lastShardPopupController = RefWeak(this)
		lastShardPopupNotificationData = RefWeak(notificationData)
		isWaitingForShardWidgetEventTimeout = os.clock() + 2
		queueWaitingForShardWidgetEvent()
		nativeUI.updatePerformers()
		nativeUI.verifyCustomSceneLocationData(true)
	end);
	Observe("PopupsManager", "OnShardReadClosed", function(this);
		isWaitingForShardWidgetEventTimeout = 0
		stopMenuMusic()
		nativeUI.isShowtime = false
		nativeUI.isMainMenu = false
		nativeUI.isSelectionList = false
		nativeUI.isBackToMainMenu = false
	end);
	Override("ShardNotificationController", "OnIntroComplete", function(this, anim, wrapped);
		lastShardNotificationController = this
		if not isItMyShard then return wrapped(anim) end
		if not IsDefined(lastShardContentsWidget) then return wrapped(anim) end
		if os.clock() > isWaitingForShardWidgetEventTimeout then return wrapped(anim) end
		startMenuMusic()
		return false
	end)
	Observe("ShardNotificationController", "SetButtonHints", function(this);
		lastShardNotificationController = this
	end)

	local function resetStatesOnExit()
		nativeUI.isShowtime = false
		nativeUI.isMainMenu = false
		nativeUI.isSelectionList = false
		nativeUI.isBackToMainMenu = false
	end
	Override("ShardNotificationController", "Close", function(this, wrapped)
		if not isItMyShard then resetStatesOnExit() return wrapped() end
		if not nativeUI.isShowtime then resetStatesOnExit() return wrapped() end
		if not nativeUI.isSelectionList then resetStatesOnExit() return wrapped() end
		GetPlayer():PlaySoundEvent("ui_menu_onpress")
		nativeUI.lastSelectionList.buttons.cancel.onReleased()
	end)

	function despawnPreviewLeftovers()
		if not isQuestNodeExecutionAvaliable then return end
		local actions = {}
		local spsetNodeRef = CreateNodeRef("#mod_hotscenes_ui_holocall_spset")
		local nodeType = questSpawnSet_NodeType.new()
		nodeType.action = "Deactivate"
		nodeType.entryName = "preview_cc_prostitute_male_mod_hotscenes"
		nodeType.phaseName = "default_male"
		nodeType.reference = spsetNodeRef
		local actionEntry = questSpawnManagerNodeActionEntry.new()
		actionEntry.type = nodeType
		tableInsert(actions, actionEntry)
		local nodeType = questSpawnSet_NodeType.new()
		nodeType.action = "Deactivate"
		nodeType.entryName = "preview_cc_prostitute_female_mod_hotscenes"
		nodeType.phaseName = "default_female"
		nodeType.reference = spsetNodeRef
		local actionEntry = questSpawnManagerNodeActionEntry.new()
		actionEntry.type = nodeType
		tableInsert(actions, actionEntry)
		local qn = questSpawnManagerNodeDefinition.new()
		qn.actions = actions
		questsSystem:ExecuteNode(qn)
	end
	ObserveBefore("ShardNotificationController", "OnUninitialize", function();
		unregisterAllCallbacks()
		isItMyShard = false
		toggleLockIncomingCalls(false)
		if IsDefined(newBackgroundVignette) then
			newBackgroundVignette:SetVisible(false)
			resetMenuSupport()
			if not isKnownName("mod_hotscenes_performer_preview_reset_patched") then
				nativeUI.queueTask(despawnPreviewLeftovers, false, 0.75)
			end
		end
		lastButtonHintCtl = nil
		nativeUI.isPerformerPreviewShowTime = false
		nativeUI.isShowtime = false
		nativeUI.isMainMenu = false
		nativeUI.isSelectionList = false
		nativeUI.isBackToMainMenu = false
		nativeUI.lastSelectionListReturn = {}
		nativeUI.mainMenuController = {}
		nativeUI.mainMenuPanelsWidget = nil
		nativeUI.lastSelectionList = {}
		nativeUI.activeInstances = {}
		lastShardPopupController = nil
		lastShardPopupNotificationData = nil
		lastShardTitleWidget = nil
		lastShardContentsWidget = nil
		lastTopBarIconWidget = nil
		lastSliderHandleWidget = nil
		lastSliderController = nil
		lastShardNotificationController = nil
		isDelayedButtonActionAllowed = true
		isPerformerPreviewSupportEnabled = false
	end)

	local left = 1
	local up = 2
	local right = 3
	local down = 4
	local navigateTo = 0
	function handleShardButtonNavigation(this, callerInstance, navigateTo)
		local callerData = callerInstance.callerData
		if navigateTo == up then
			if callerInstance.isMainMenu then
				callerData.moveUp()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			elseif callerInstance.isSelectionList then
				callerData.moveUp()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			end
			return
		end
		if navigateTo == down then
			if callerInstance.isMainMenu then
				callerData.moveDown()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			elseif callerInstance.isSelectionList then
				callerData.moveDown()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			end
			return
		end
		if navigateTo == left then
			if callerInstance.isMainMenu then
				callerData.moveLeft()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			elseif callerInstance.isSelectionList then
				callerData.moveLeft()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			end
			return
		end
		if navigateTo == right then
			if callerInstance.isMainMenu then
				callerData.moveRight()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			elseif callerInstance.isSelectionList then
				callerData.moveRight()
				local targetObject = callerData.getLastSelectedObject()
				if not targetObject then return end
				restoreDpadCursor()
				this:SetCursorOverWidget(targetObject.widget, 0, true)
				return
			end
			return
		end
	end

	if isGameV211andUp then
		function getNavigation(evt)
			if evt:IsAction("popup_navigate_up") then return up end
			if evt:IsAction("popup_navigate_down") then return down end
			if evt:IsAction("popup_navigate_left") then return left end
			if evt:IsAction("popup_navigate_right") then return right end
		end
	else
		function getNavigation(evt)
			if evt:IsAction("popup_moveUp") then return up end
			if evt:IsAction("popup_moveDown") then return down end
			if evt:IsAction("popup_moveLeft") then return left end
			if evt:IsAction("popup_moveRight") then return right end
		end
	end

	Observe("ShardNotificationController", "OnRelease", function(this, evt);
		if not nativeUI.isShowtime then return end
		if #nativeUI.activeInstances < 1 then return end

		if isItMyShard and nativeUI.isPerformerPreviewShowTime and isPerformerPreviewAvailable() and evt:IsAction("popup_goto") then
			nativeUI.userSettings.keepShowingPerformerPreview = not nativeUI.userSettings.keepShowingPerformerPreview
			togglePerformerPreview(nativeUI.userSettings.keepShowingPerformerPreview, true)
			nativeUI.saveUserSettings()
		end

		navigateTo = getNavigation(evt)
		if not navigateTo then return end

		lastShardNotificationController = this
		local callerInstance = nil
		for i = #nativeUI.activeInstances, 1, -1 do
			if IsDefined(nativeUI.activeInstances[i].eventCatcher) and isSameInstance(this, nativeUI.activeInstances[i].eventCatcher) then
				callerInstance = nativeUI.activeInstances[i]
				break
			end
		end

		if not callerInstance then return end
		if not callerInstance.callerData then return end

		handleShardButtonNavigation(this, callerInstance, navigateTo)
	end)

	ObserveAfter('PlayerPuppet', 'OnAction', function(this, action, consumer)
		if not nativeUI.isShowtime then return end

		if not (nativeUI.isSelectionList or nativeUI.isMainMenu) then return end
		if #nativeUI.activeInstances < 1 then return end
		if not IsDefined(lastShardNotificationController) then return end
		actionType = action:GetType(action).value
		if action:GetType(action).value ~= 'REPEAT' then return end

		navigateTo = getNavigation(action)
		if not navigateTo then return end

		local callerInstance = nil
		for i = #nativeUI.activeInstances, 1, -1 do
			if IsDefined(nativeUI.activeInstances[i].eventCatcher) and isSameInstance(lastShardNotificationController, nativeUI.activeInstances[i].eventCatcher) then
				callerInstance = nativeUI.activeInstances[i]
				break
			end
		end
		if not callerInstance then return end
		if not callerInstance.callerData then return end

		handleShardButtonNavigation(lastShardNotificationController, callerInstance, navigateTo)
	end)

	Override("ShardNotificationController", "LaunchMinigame", function(this, wrapped)
		if not nativeUI.isShowtime then return wrapped() end
		if #nativeUI.activeInstances < 1 then return wrapped() end
		if not IsDefined(lastShardPopupController) then return wrapped() end
		if not IsDefined(lastShardContentsWidget) then return wrapped() end
		if ItemID.IsValid(this.data.itemID) then return wrapped() end
	end)


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
		if callerInstance.isMainMenu then
			button = callerData.buttons[buttonNameStr]
		elseif callerInstance.isScenePanel then
			button = callerData.scenePanelNativeUI.buttons[buttonNameStr]
		elseif callerInstance.isSelectionList then
			button = callerData.getItemByName(buttonNameStr)
			if not button then button = callerData.buttons[buttonNameStr] end
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
		if nativeUI.isNudityCensored then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end

		GetPlayer():PlaySoundEvent("ui_menu_hover")
		if not button.isListItem then
			if button.isActive then
				button.widget:GetWidget('fill'):SetOpacity(0.03)
				button.widget:GetWidget('frame'):SetOpacity(1.0)
				if isScenePanel then setWidgetTextLabelColor(button.widgetLabel, callerData.scenePanelNativeUI.activeTextColor) return end
				if isSelectionList then setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor) return end
				if isMainMenu then setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor) return end
			end
			return
		elseif isSelectionList then
			if button.isActive then
				button.setHovered(true)
			end
		end
	end)

	Observe('sampleStyleManagerGameController', 'OnStyle2', function(self, evt)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if not button.isListItem then
			button.widget:GetWidget('fill'):SetOpacity(0.0)
			button.widget:GetWidget('frame'):SetOpacity(0.3)
			if button.isActive then
				if isScenePanel then setWidgetTextLabelColor(button.widgetLabel, callerData.scenePanelNativeUI.activeTextColor) return end
				if isSelectionList then setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor) return end
				if isMainMenu then setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor) return end
			else
				if isScenePanel then setWidgetTextLabelColor(button.widgetLabel, callerData.scenePanelNativeUI.inactiveTextColor) return end
				if isSelectionList then setWidgetTextLabelColor(button.widgetLabel, callerData.inactiveTextColor) return end
				if isMainMenu then setWidgetTextLabelColor(button.widgetLabel, callerData.inactiveTextColor) return end
			end
			return
		else
			if button.isActive then
				setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor)
				button.setHovered(false)
				return
			else
				setWidgetTextLabelColor(button.widgetLabel, callerData.inactiveTextColor)
			end
		end
	end)

	local nextKeyPressAllowedTime = 0
	Observe('sampleStyleManagerGameController', 'OnState1', function(self, evt)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not evt:IsAction("click") then return end
		if nextKeyPressAllowedTime > os.clock() then return end
		nextKeyPressAllowedTime = os.clock() + 0.003
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end

		if isScenePanel then
			setWidgetTextLabelColor(button.widgetLabel, callerData.scenePanelNativeUI.highlightTextColor)
			button.onPressed()
			return
		elseif isSelectionList then
			setWidgetTextLabelColor(button.widgetLabel, callerData.highlightTextColor)
			button.onPressed()
			return
		elseif isMainMenu then
			setWidgetTextLabelColor(button.widgetLabel, callerData.highlightTextColor)
			button.onPressed()
		end
	end)

	local nextKeyReleaseAllowedTime = 0
	local lastClickEvent = 0
	local isMouseClick = false
	Observe('sampleStyleManagerGameController', 'OnState2', function(self, evt)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if evt:IsAction("click") then lastClickEvent = os.clock() return end
		local currTime = os.clock()
		isMouseClick = false
		if evt:IsAction("mouse_left") then isMouseClick = true end
		if (not isMouseClick) and (not evt:IsAction("proceed")) then return end
		local button, buttonNameStr, isScenePanel, isSelectionList, isMainMenu, callerData = getCaller(self, evt)
		if not button then return end
		if isScenePanel then
			setWidgetTextLabelColor(button.widgetLabel, callerData.scenePanelNativeUI.activeTextColor)
			if button.type == 'switch' then
				button.isSwitchOn = not button.isSwitchOn
				button.setSwitchState(button.isSwitchOn)
			end
			button.onReleased(isMouseClick)
			callerData.lastSelectedObject = button
			GetPlayer():PlaySoundEvent("ui_menu_onpress")
			return
		elseif isSelectionList then
			setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor)
			button.onReleased(isMouseClick)
			callerData.lastSelectedObject = button
			GetPlayer():PlaySoundEvent("ui_menu_onpress")
			return
		elseif isMainMenu then
			setWidgetTextLabelColor(button.widgetLabel, callerData.activeTextColor)
			button.onReleased(isMouseClick)
			callerData.lastSelectedObject = button
			GetPlayer():PlaySoundEvent("ui_menu_onpress")
		end
	end)

-----------------------------------------------------------------------------------------------
-- This part is based on RipperDeck mod code for the game v1.x by (c)psiberx thanks to psibex consent.

	local hubMenuController
	local hubMenuButtonName = 'stats'
	local hubMenuButton
	local hubMenuButtonData
	local hubMenuButtonMargin
	math.randomseed(os.time())
	local hubMenuButtonId = math.random(1000, 2000)
	local hubMenuJournalId = EnumInt(HubMenuItems.Journal)

	local function isChildAttached(parentWidget, childWidgetName)
		local child = parentWidget:GetWidget(childWidgetName)
		if child and child.name.value == childWidgetName then return true end
	end

	local btnOffset = 8
	local function modifyHubMenu()
		local characterPanel = hubMenuController.panelCharacter.widget
		local journalPanel = hubMenuController.panelJournal.widget

		hubMenuButton = characterPanel:GetWidget(hubMenuButtonName)
		if hubMenuButton.name.value ~= hubMenuButtonName then hubMenuButton = nil return end

		hubMenuButtonMargin = hubMenuButton:GetMargin()
		hubMenuButtonData = hubMenuButton.logicController.menuData

		local ripperButtonData = MenuData.new()
		ripperButtonData.label = 'Hotscenes'
		ripperButtonData.icon = 'ico_hairdresser'

		ripperButtonData.fullscreenName = 'MenuScenario_HubMenu'
		ripperButtonData.identifier = hubMenuButtonId
		ripperButtonData.parentIdentifier = hubMenuJournalId

		if hubMenuButtonData.disabled then
			hubMenuButton:SetOpacity(1)
			hubMenuButton.logicController.icon.widget:SetOpacity(1)
			hubMenuButton.logicController.label.widget:SetOpacity(1)
		end
		if nativeUI.isHotscenesAvailable() then ripperButtonData.disabled = false else ripperButtonData.disabled = true end
		hubMenuButton.logicController:Init(ripperButtonData)
		if isGameV22andUp then
			if journalPanel:GetMargin().top == -170 then
				journalPanel:UpdateMargin(0, -btnOffset, 0, 0)
				local btnCtn = journalPanel:GetNumChildren()
				for i = 0, btnCtn - 1 do journalPanel:GetWidget(i):UpdateMargin(0, btnOffset, 0, 0) end
			end
			hubMenuButton:SetMargin(0, -162, 0, 0)
		else
			hubMenuButton:SetMargin(0, 0, 0, 0)
		end
		hubMenuButton:Reparent(journalPanel)
	end

	local function restoreHubMenu()
		if hubMenuButton then
			if hubMenuButton.logicController then
				local journalPanel = hubMenuController.panelJournal.widget
				local characterPanel = hubMenuController.panelCharacter.widget

				hubMenuButton.logicController:Init(hubMenuButtonData)
				if hubMenuButtonMargin then hubMenuButton:SetMargin(hubMenuButtonMargin) end
				hubMenuButton:Reparent(characterPanel, -1)
			end

			hubMenuButton = nil
			hubMenuButtonData = nil
		end
	end

	Observe('MenuHubLogicController', 'OnInitialize', function(self) hubMenuController = self hubMenuButton = nil end);
	Observe('MenuHubLogicController', 'OnUninitialize', function() hubMenuController = nil hubMenuButton = nil end)
	Observe('MenuItemController', 'OnItemHoverOver', function(self)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not nativeUI.userSettings.enableHotscenesButtonInHubMenu then return end
		if not (hubMenuController and self.hoverPanel.widget) then return end
		if self.menuData.identifier == hubMenuJournalId and (not isChildAttached(self.hoverPanel.widget, hubMenuButtonName)) then
			modifyHubMenu()
		end
	end)
	Observe('MenuItemController', 'OnHoverPanelOver', function(self)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not nativeUI.userSettings.enableHotscenesButtonInHubMenu then return end
		if not (hubMenuController and self.hoverPanel.widget) then return end
		if self.menuData.identifier == hubMenuJournalId and (not isChildAttached(self.hoverPanel.widget, hubMenuButtonName)) then
			modifyHubMenu()
		end
	end)
	Observe('MenuItemController', 'OnMenuItemDelayedUpdate', function(self)
		if nativeUI.isModDisabled then return end
		if nativeUI.isNudityCensored then return end
		if not hubMenuController then return end
		if self.menuData.identifier == hubMenuJournalId and not self.itemHovered and not self.panelHovered then
			restoreHubMenu()
		end
	end)
	Override('MenuHubGameController', 'OnOpenMenuRequest', function(this, request, wrapped)
		if nativeUI.isModDisabled then return wrapped(request) end
		if nativeUI.isNudityCensored then return wrapped(request) end
		if not hubMenuController then return wrapped(request) end
		if request.eventData.identifier ~= hubMenuButtonId then return wrapped(request) end
		local timeout = os.clock() + 10
		if type(nativeUI.updateSceneState) == 'function' then nativeUI.updateSceneState() end
		local payload = function()
			this.currentRequest = OpenMenuRequest.new()
			this:QueueEvent(BackActionCallback.new())
			local payload = function()
				if os.clock() > timeout then return true end
				if Game.GetSystemRequestsHandler():IsGamePaused() then return end
				local result, blackboardSystem = pcall(function() return Game.GetBlackboardSystem():Get(Game.GetAllBlackboardDefs().UI_System) end)
				if result and IsDefined(blackboardSystem) and blackboardSystem:GetBool(Game.GetAllBlackboardDefs().UI_System.IsInMenu) then return end
				nativeUI.queueTask(launchMainMenu, false, 0.05)
				return true
			end
			nativeUI.queueTask(payload, false, 0.05, 0.01, false)
		end
		nativeUI.queueTask(payload, false, buttonDelay)
	end)

	function hubMenuButtonDispose()
		if hubMenuController and hubMenuController.panelJournal and hubMenuController.panelJournal.widget then
			if isChildAttached(hubMenuController.panelJournal.widget, hubMenuButtonName) then
				restoreHubMenu()
			end
		end
	end
-----------------------------------------------------------------------------------------------
end

function isKnownName(inputString)
	return CName.new(inputString).value == inputString
end

function getSelectedGameUILanguage()
	if type(Game) == 'userdata' and type(GetPlayer) == 'function' then
		local lang = "en-us";
		local settingsSystem = Game.GetSettingsSystem();
		if settingsSystem:HasGroup("/language") and settingsSystem:HasVar("/language", "OnScreen") then lang = settingsSystem:GetVar("/language", "OnScreen"):GetValue() end;
		lang = NameToString(lang)
		return lang
	end
end

function restoreDpadCursor()
	if IsDefined(lastGameCursorController) and lastGameCursorController.cursorType.value ~= 'dpad' then lastGameCursorController:OnSetCursorType("dpad") end
end

function restoreDefaulCursor()
	if IsDefined(lastGameCursorController) and lastGameCursorController.cursorType.value ~= 'default' then lastGameCursorController:OnSetCursorType("default") end
end

function showCursor(restoreToDefault, delay)
	if not IsDefined(lastShardPopupNotificationData) then return end
	if restoreToDefault then restoreDefaulCursor() end
	local payload = function() lastShardPopupNotificationData.useCursor = true end
	if type(delay) ~= 'number' or delay <=0 then payload() return end
	nativeUI.queueTask(payload, false, delay)
end

function hideCursor(restoreToDefault)
	if not IsDefined(lastShardPopupNotificationData) then return end
	if restoreToDefault then restoreDefaulCursor() end
	lastShardPopupNotificationData.useCursor = false
end

function setCursorOverWidgetWithCursorRestore(menuController, widget, restoreDefaultCursor)
	if not menuController then menuController = lastShardNotificationController end
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
	return lastGameCursorController.margin.left, lastGameCursorController.margin.top
end

function isGameCursorWithinWidget(widget)
	local x, y = getCurrentCursorPosition()
	if not x then return false end
	return true, isXYWithinWidgetOnScreen(x, y, widget), x, y
end

function isXYWithinWidgetOnScreen(x, y, widget)
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
	return math.max(0, math.min(1, desiredVisibleContentStartPosition/contentLengthBase)) -- psiberx performance tip
end

function findWigetsInWidget(root, lookedWidgets)
	if type(root) ~= 'userdata' then return end
	if type(lookedWidgets) ~= 'table' then return end

	local isInputWrapped = false
	if #lookedWidgets < 1 then
		if type(lookedWidgets.name) == 'string' and type(lookedWidgets.type) == 'string' then lookedWidgets = {lookedWidgets} isInputWrapped = true else return end
	end

	lookedWidgets.foundWidgetsCount = 0
	lookedWidgets.isAllFound = false
	local function dumpWidget(widget);
		if lookedWidgets.isAllFound then return end
		for i = 1, #lookedWidgets do
			if not lookedWidgets[i].widget and lookedWidgets[i].name == widget.name.value and lookedWidgets[i].type == widget:ToString() then
				lookedWidgets[i].widget = RefWeak(widget)
				lookedWidgets.foundWidgetsCount = lookedWidgets.foundWidgetsCount + 1
				if lookedWidgets.foundWidgetsCount >= #lookedWidgets then lookedWidgets.isAllFound = true return end
				break
			end
		end
		if widget:IsA('inkCompoundWidget') then;
			local numChildren = widget:GetNumChildren();
			for i = 0, numChildren - 1 do;
				local child = widget:GetWidget(i);
				if child then dumpWidget(child) end;
			end;
			return;
		else;
			return;
		end;
	end;
	dumpWidget(root)
	if isInputWrapped then return lookedWidgets[1] else return lookedWidgets end
end

function getTopWigetByName(widget, lookedWidgetName);
	if type(widget) ~= 'userdata' then return end;
	if type(lookedWidgetName) ~= 'string' then return end
	local nextTopWidget = widget;
	local loopBreaker = 50;
	while IsDefined(nextTopWidget) and widget:IsA('inkCompoundWidget') do;
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

function getGameColor(colorName)
	if type(colorName) ~= 'string' then return end
	local getColor = getGameMainColor[colorName]
	if type(getColor) ~= 'function' then return end
	return getColor()
end

function setWidgetTintColorByStyleName(widget, styleName)
	if not widget then return end
	if not widget.style then return end
	local dataType = type(styleName)
	if dataType == 'string' then
		if not (CName.new(styleName).value ~= "") then return end -- psiberx performance tip
	elseif dataType == 'userdata' then
		if type(styleName.value) ~= 'string' then return end
		if not isStringValid(styleName.value) then return end
	else return end

	widget:BindProperty(n"tintColor", styleName)
	return true
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

	if type(highLight) ~= 'number' then highLight = 1 else highLight = ClampF(highLight, 0, 2) end
	if highLight ~= 1 then
		labelColor.Red = labelColor.Red * highLight
		labelColor.Green = labelColor.Green * highLight
		labelColor.Blue = labelColor.Blue * highLight
	end

	label:SetTintColor(labelColor)
end

local n_tintColor
local n_MainColorsBlue
local n_MainColorsFullscreenPrimaryBackgroundDarkest
local atlas_shapes_sync_ResRef
local fullscreen_main_colors_ResRef
local atlas_scanner_ResRef
local mappin_icons_ResRef
local isWidgetSupportSetUp
local function widgetSupportSetup()
	if isWidgetSupportSetUp then return end
	n_tintColor = n"tintColor"
	n_MainColorsBlue = n"MainColors.Blue"
	n_MainColorsFullscreenPrimaryBackgroundDarkest = n"MainColors.Fullscreen_PrimaryBackgroundDarkest"
	atlas_shapes_sync_ResRef = ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas')
	fullscreen_main_colors_ResRef = ResRef.FromName("base\\gameplay\\gui\\fullscreen\\fullscreen_main_colors.inkstyle")
	atlas_scanner_ResRef = ResRef.FromName('base\\gameplay\\gui\\widgets\\scanning\\scanner_tooltip\\atlas_scanner.inkatlas')
	mappin_icons_ResRef = ResRef.FromName('base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas')
	isWidgetSupportSetUp = true
end

function createButton(name, text, fontSize, buttonSize, anchorPoint, labelTextColorStyle, isUpperCase) -- (c)psiberx
	widgetSupportSetup()
	local button = inkCanvas.new()
	button:SetName(name) CName.add(name)
	if type(buttonSize) == 'table' and type(buttonSize[1]) == 'number' and type(buttonSize[2]) == 'number' then
		local x = Clamp(mathFloor(buttonSize[1]), 100, 1000)
		local y = Clamp(mathFloor(buttonSize[2]), 50, 500)
		button:SetSize(x, y)
	else
		button:SetSize(400, 100)
	end
	if type(anchorPoint) == 'table' and type(anchorPoint[1]) == 'number' and type(anchorPoint[2]) == 'number' then
		local x = ClampF(anchorPoint[1], 0, 1)
		local y = ClampF(anchorPoint[2], 0, 1)
		button:SetAnchorPoint(Vector2.new({ X = x, Y = y }))
	else
		button:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
	end
	button:SetInteractive(true)

	local bg = inkImage.new()
	bg:SetName('bg')
	bg:SetAtlasResource(atlas_shapes_sync_ResRef)
	bg:SetTexturePart('cell_bg')
	bg:SetStyle(fullscreen_main_colors_ResRef)
	bg:BindProperty(n_tintColor, n_MainColorsFullscreenPrimaryBackgroundDarkest)
	bg:SetOpacity(0.8)
	bg:SetAnchor(inkEAnchor.Fill)
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
	fill:SetAnchor(inkEAnchor.Fill)
	fill.useNineSliceScale = true
	fill.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	fill:Reparent(button, -1)

	local checkMark = inkImage.new()
	checkMark:SetName('check_mark_icon') CName.add("check_mark_icon")
	checkMark:SetAtlasResource(mappin_icons_ResRef)
	checkMark:SetTexturePart('completed')
	checkMark:SetStyle(fullscreen_main_colors_ResRef)
	setWidgetTextLabelColor(checkMark, labelTextColorStyle)
	checkMark:SetOpacity(0.0)
	checkMark:SetAnchor(inkEAnchor.CenterLeft)
	checkMark:SetAnchorPoint(Vector2.new({ X = 0, Y = 0.5 }))
	local vsize = fontSize
	local leftMargin = mathFloor(fontSize * 0.2)
	checkMark:SetWidth(vsize)
	checkMark:SetHeight(vsize)
	checkMark:SetMargin(leftMargin , 0, leftMargin, 0)
	checkMark:Reparent(button, -1)

	local switch = inkImage.new()
	switch:SetName('switch_icon') CName.add("switch_icon")
	switch:SetAtlasResource(atlas_scanner_ResRef)
	switch:SetTexturePart('ico_device_off')
	switch:SetStyle(fullscreen_main_colors_ResRef)
	setWidgetTextLabelColor(switch, labelTextColorStyle)
	switch:SetOpacity(0.0)
	switch:SetAnchor(inkEAnchor.CenterLeft)
	switch:SetAnchorPoint(Vector2.new({ X = 0, Y = 0.5 }))
	local vsize = mathFloor(fontSize * 0.6)
	local leftMargin = mathFloor(fontSize * 0.3)
	switch:SetWidth(vsize * 2)
	switch:SetHeight(vsize)
	switch:SetMargin(leftMargin , 0, leftMargin, 0)
	switch:Reparent(button, -1)

	local frame = inkImage.new()
	frame:SetName('frame')
	frame:SetAtlasResource(atlas_shapes_sync_ResRef)
	frame:SetTexturePart('cell_fg')
	frame:SetStyle(fullscreen_main_colors_ResRef)
	frame:BindProperty(n_tintColor, n_MainColorsBlue)
	frame:SetOpacity(0.3)
	frame:SetAnchor(inkEAnchor.Fill)
	frame.useNineSliceScale = true
	frame.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	frame:Reparent(button, -1)

	local label = inkText.new()
	label:SetName('label')
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
	label:SetAnchor(inkEAnchor.Fill)
	label:SetHorizontalAlignment(textHorizontalAlignment.Center)
	label:SetVerticalAlignment(textVerticalAlignment.Center)
	label:SetText(text)
	label:Reparent(button, -1)

	return button, label
end

function createTextLabel(name, text, fontSize, buttonSize, anchorPoint, labelTextColorStyle, isUpperCase) -- based on psiberx snippets
	widgetSupportSetup()
	local label = inkText.new()
	label:SetName(name) CName.add(name)
	if type(buttonSize) == 'table' and type(buttonSize[1]) == 'number' and type(buttonSize[2]) == 'number' then
		local x = Clamp(mathFloor(buttonSize[1]), 100, 1000)
		local y = Clamp(mathFloor(buttonSize[2]), 50, 500)
		label:SetSize(x, y)
	else
		label:SetSize(400, 100)
	end
	if type(anchorPoint) == 'table' and type(anchorPoint[1]) == 'number' and type(anchorPoint[2]) == 'number' then
		local x = ClampF(anchorPoint[1], 0, 1)
		local y = ClampF(anchorPoint[2], 0, 1)
		label:SetAnchorPoint(Vector2.new({ X = x, Y = y }))
	else
		label:SetAnchorPoint(Vector2.new({ X = 0, Y = 0 }))
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
	label:SetAnchor(inkEAnchor.Fill)
	label:SetHorizontalAlignment(textHorizontalAlignment.Left)
	label:SetVerticalAlignment(textVerticalAlignment.Center)
	label:SetText(text)

	return label
end

function createBottomBorderLineWithMargin(name, marginTop, marginBottom, width, tintColorStyle) -- based on psiberx snippets
	widgetSupportSetup()
	local border = inkBorderWidget.new()
	border:SetName(name) CName.add(name)

	if type(width) == 'number' and width > 0 then border:SetSize(width, 2) else border:SetSize(1000, 2) end
	border.thickness = 2
	border:SetRenderTransformPivot(Vector2.new({ X = 0, Y = 0.5 }))

	border:SetOpacity(0.047)
	border:SetStyle(fullscreen_main_colors_ResRef)
	if not tintColorStyle then border:BindProperty(n_tintColor, n_MainColorsBlue)
	elseif type(tintColorStyle) == 'string' then border:BindProperty(n_tintColor, tintColorStyle)
	elseif type(tintColorStyle) == 'userdata' and type(tintColorStyle.value) == 'string' then border:BindProperty(n_tintColor, tintColorStyle) end

	local layout = inkWidgetLayout.new()
	layout.anchor = inkEAnchor.BottomFillHorizontaly
	if type(marginTop) ~= 'number' then marginTop = 30 end
	if type(marginBottom) ~= 'number' then marginBottom = 60 end
	layout.margin = inkMargin.new({left = 0, top = marginTop, right = 0, bottom = marginBottom})
	border:SetLayout(layout)
	return border
end

return {modName = modName, modVer = modVer, modAuthorName = modAuthorName, nativeUI = nativeUI}
