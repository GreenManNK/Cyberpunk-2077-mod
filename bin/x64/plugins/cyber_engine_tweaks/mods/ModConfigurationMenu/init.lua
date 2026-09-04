if type(package) == "table" and type(package.loaded) == "table" then
  local loadedUiModules = {}
  for moduleName in pairs(package.loaded) do
    if moduleName == "mcm_ui" or string.sub(moduleName, 1, 7) == "mcm_ui/" then
      loadedUiModules[#loadedUiModules + 1] = moduleName
    end
  end
  for _, moduleName in ipairs(loadedUiModules) do
    package.loaded[moduleName] = nil
  end
end

local Logger = require("mcm_ui/mcm_logger")
local SettingsEntry = require("mcm_ui/mcm_settings_entry")
local MenuIntegration = require("mcm_ui/mcm_menu_bridge")
local nativeSettingsState = { captured = false, value = nil, closing = false }
local actionListGuardInstalled = false
local actionListGuardAttempted = false
local rawInputListener = nil
local gameplayState = {
  requested = false,
  opening = false,
  controllerAttached = false,
  timeoutFrames = 0,
  hotkeyHeld = false,
}

local okScreen, Screen = pcall(require, "mcm_ui/init")
if not okScreen then
  Logger.error("failed to load renderer: " .. tostring(Screen))
  Screen = nil
end

local function logError(message)
  pcall(Logger.error, message)

  local line = "[ModConfigurationMenu] [ERROR] " .. tostring(message)
  if type(spdlog) == "table" and type(spdlog.error) == "function" then
    pcall(spdlog.error, line)
  elseif type(print) == "function" then
    pcall(print, line)
  end
end

local function logGameplay(message)
  local line = "[ModConfigurationMenu] [GAMEPLAY] " .. tostring(message)
  if type(spdlog) == "table" and type(spdlog.info) == "function" then
    local ok = pcall(spdlog.info, line)
    if ok then
      return
    end
  end
  if type(print) == "function" then
    pcall(print, line)
  end
end

local function getApi()
  if type(GetMod) == "function" then
    local api = GetMod("ModConfigurationMenuAPI")
    if type(api) == "table" then
      return api
    end
  end
  return nil
end

local function getNativeSettings()
  if type(GetMod) ~= "function" then
    return nil
  end

  return GetMod("nativeSettings")
end

local function enterNativeSettingsMode()
  local nativeSettings = getNativeSettings()
  if nativeSettings == nil then
    return
  end

  if not nativeSettingsState.captured then
    nativeSettingsState.captured = true
    nativeSettingsState.value = nativeSettings.fromMods
  end
  nativeSettings.fromMods = false
end

local function leaveNativeSettingsMode()
  if not nativeSettingsState.captured then
    return
  end
  if nativeSettingsState.closing then
    return
  end

  local nativeSettings = getNativeSettings()
  if nativeSettings ~= nil then
    nativeSettings.fromMods = nativeSettingsState.value
  end
  nativeSettingsState.captured = false
  nativeSettingsState.value = nil
end

local function beginNativeSettingsClose()
  if not nativeSettingsState.captured then
    return
  end

  local nativeSettings = getNativeSettings()
  if nativeSettings ~= nil then
    nativeSettings.fromMods = true
    nativeSettingsState.closing = true
  end
end

local function finishNativeSettingsClose()
  if not nativeSettingsState.closing then
    return
  end

  nativeSettingsState.closing = false
  leaveNativeSettingsMode()
end

local function processMenu(controller)
  MenuIntegration.process(controller)
end

local function isMcmActive()
  return Screen ~= nil and type(Screen.isActive) == "function" and Screen.isActive() == true
end

local function isGameplayMcmActive()
  return isMcmActive()
    and type(Screen.isGameplayEntry) == "function"
    and Screen.isGameplayEntry() == true
end

local function prepareApi(source)
  local api = getApi()
  if api ~= nil and type(api.prepareProviders) == "function" then
    local ok, resultOrError, prepareError = pcall(api.prepareProviders, source)
    if not ok then
      logError("provider preparation before MCM transition failed: " .. tostring(resultOrError))
    elseif prepareError ~= nil then
      logError("provider preparation before MCM transition reported: " .. tostring(prepareError))
    end
  end
  return api
end

local function resetGameplayOpen()
  gameplayState.requested = false
  gameplayState.opening = false
  gameplayState.controllerAttached = false
  gameplayState.timeoutFrames = 0
end

local function abortGameplayOpen(reason)
  resetGameplayOpen()
  gameplayState.hotkeyHeld = false
  pcall(SettingsEntry.cancel)
  if reason ~= nil then
    logError(reason)
  end
  if isMcmActive() and Screen ~= nil and type(Screen.abort) == "function" then
    local ok = pcall(Screen.abort, reason or "Gameplay Settings transition failed.")
    if ok then
      return
    end
  end
  leaveNativeSettingsMode()
end

local function performGameplayOpen()
  gameplayState.requested = false
  if gameplayState.opening or isMcmActive() or Screen == nil then
    pcall(SettingsEntry.cancel)
    return
  end

  local accepted, reason = SettingsEntry.canOpen(false)
  if not accepted then
    logGameplay("open request declined before transition: " .. tostring(reason))
    return
  end

  logGameplay("open request accepted")

  gameplayState.opening = true
  gameplayState.controllerAttached = false
  gameplayState.timeoutFrames = 360
  local api = prepareApi("gameplay_shortcut")
  logGameplay("providers prepared")
  enterNativeSettingsMode()
  logGameplay("Native Settings lifecycle prepared")
  Screen.activate(api, leaveNativeSettingsMode, { gameplayEntry = true })
  logGameplay("MCM state prepared")

  local ready, readyError = SettingsEntry.ready()
  if not ready then
    abortGameplayOpen(
      "failed to prepare the Settings-hosted gameplay MCM: " .. tostring(readyError)
    )
    return
  end

  local opened, openError = SettingsEntry.open()
  if not opened then
    abortGameplayOpen("failed to request the native pause host: " .. tostring(openError))
    return
  end
  logGameplay("native OnOpenPauseMenu transition queued")
end

local function requestGameplayOpen()
  if gameplayState.requested or gameplayState.opening or isMcmActive() or Screen == nil then
    return
  end
  gameplayState.requested = true
  logGameplay("open request queued for the next update")
end

local function handleRawKeyInput(event)
  local ok, key, action = pcall(function()
    return event:GetKey().value, event:GetAction().value
  end)
  if not ok then
    return
  end
  local expectedKey = "IK_Home"
  if Screen ~= nil and type(Screen.getGameplayShortcut) == "function" then
    expectedKey = Screen.getGameplayShortcut() or expectedKey
  end
  if key == expectedKey and action == "IACT_Release" then
    gameplayState.hotkeyHeld = false
  elseif key == expectedKey and action == "IACT_Press" and not gameplayState.hotkeyHeld then
    gameplayState.hotkeyHeld = true
    if isMcmActive() then
      return
    end
    local accepted = false
    local reason = "renderer_unavailable"
    if Screen ~= nil then
      accepted, reason = SettingsEntry.canOpen(false)
    end
    if accepted then
      logGameplay("shortcut input received: " .. tostring(key))
      requestGameplayOpen()
    else
      logGameplay("open request declined: " .. tostring(reason))
    end
    return
  end
  if isMcmActive() and Screen ~= nil and type(Screen.handleKeyInput) == "function" then
    Screen.handleKeyInput(key, action)
  end
end

local function registerRawInputListener()
  if rawInputListener ~= nil then
    return
  end
  if type(NewProxy) ~= "function" then
    logError("failed to register the MCM key listener: NewProxy is unavailable")
    return
  end

  local ok, listenerOrError = pcall(function()
    local listener = NewProxy({
      OnKeyInput = {
        args = { "handle:KeyInputEvent" },
        callback = handleRawKeyInput,
      },
    })
    Game.GetCallbackSystem()
      :RegisterCallback("Input/Key", listener:Target(), listener:Function("OnKeyInput"), true)
    return listener
  end)
  if ok then
    rawInputListener = listenerOrError
    logGameplay("configurable gameplay shortcut listener registered")
  else
    logError("failed to register the MCM key listener: " .. tostring(listenerOrError))
  end
end

local function beginMenuBuild(controller)
  MenuIntegration.beginBuild(controller)
end

local function handleMenuActivation(source, target)
  if not MenuIntegration.isActivationTarget(target) then
    return
  end

  if Screen and Screen.activate then
    local api = prepareApi("menu_transition")
    enterNativeSettingsMode()
    Screen.activate(api, leaveNativeSettingsMode)
  else
    leaveNativeSettingsMode()
    logError("renderer is unavailable; cannot open MCM.")
  end
end

local function forwardMenuActivation(source, index, target, wrapped)
  if not MenuIntegration.isActivationTarget(target) then
    return wrapped(index, target)
  end

  handleMenuActivation(source, target)
  local forwarded, result = MenuIntegration.forwardToSettings(target, function()
    return wrapped(index, target)
  end)
  enterNativeSettingsMode()
  if not forwarded then
    logError("failed to forward the MCM menu item to the Settings screen.")
  end
  return result
end

local function installActionListGuard()
  if actionListGuardInstalled or actionListGuardAttempted then
    return
  end
  actionListGuardAttempted = true

  local ok, err = pcall(
    Override,
    "SingleplayerMenuGameController",
    "ShowActionsList",
    function(this, wrapped)
      local _, result = MenuIntegration.runActionListBuild(this, function()
        return wrapped()
      end)
      return result
    end
  )
  if ok then
    actionListGuardInstalled = true
  else
    logError("failed to guard main-menu action-list rebuilds: " .. tostring(err))
  end
end

registerForEvent("onInit", function()
  local listenerOk, listenerError = pcall(registerRawInputListener)
  if not listenerOk then
    logError("failed to initialize the MCM key listener: " .. tostring(listenerError))
  end

  local loggerOk, loggerError = pcall(Logger.initialize)
  if not loggerOk then
    logError("dedicated logger initialization failed: " .. tostring(loggerError))
  end

  local guardOk, guardError = pcall(installActionListGuard)
  if not guardOk then
    logError("failed to initialize the menu action-list guard: " .. tostring(guardError))
  end

  local okPushObserver, pushObserverError = pcall(
    ObserveAfter,
    "ListController",
    "PushData",
    function(this, data)
      MenuIntegration.onDataPushed(this, data)
    end
  )
  if not okPushObserver then
    logError("failed to observe ListController.PushData: " .. tostring(pushObserverError))
  end

  Observe("SingleplayerMenuGameController", "PopulateMenuItemList", beginMenuBuild)

  Observe("PauseMenuGameController", "PopulateMenuItemList", beginMenuBuild)

  Observe("DeathMenuGameController", "PopulateMenuItemList", beginMenuBuild)

  ObserveAfter("SingleplayerMenuGameController", "PopulateMenuItemList", function(this)
    if IsDefined(this) and IsDefined(this.menuListController) then
      processMenu(this)
    end
  end)

  ObserveAfter("PauseMenuGameController", "PopulateMenuItemList", function(this)
    if IsDefined(this) and IsDefined(this.menuListController) then
      processMenu(this)
    end
  end)

  ObserveAfter("DeathMenuGameController", "PopulateMenuItemList", function(this)
    if IsDefined(this) and IsDefined(this.menuListController) then
      processMenu(this)
    end
  end)

  Override(
    "gameuiMenuItemListGameController",
    "OnMenuItemActivated",
    function(_, index, target, wrapped)
      return forwardMenuActivation("gameuiMenuItemListGameController", index, target, wrapped)
    end
  )

  Override("PauseMenuGameController", "OnMenuItemActivated", function(_, index, target, wrapped)
    return forwardMenuActivation("PauseMenuGameController", index, target, wrapped)
  end)

  ObserveAfter("SettingsMainGameController", "OnInitialize", function(this)
    if isMcmActive() and Screen.onInitialize then
      local gameplayEntry = gameplayState.opening
      local gameplayStage = gameplayEntry and SettingsEntry.stage() or nil
      if gameplayEntry then
        gameplayState.controllerAttached = true
        logGameplay("Settings controller attached; entry stage: " .. tostring(gameplayStage))
      end
      enterNativeSettingsMode()
      Screen.onInitialize(this)
    end
  end)

  ObserveAfter("SettingsMainGameController", "PopulateHints", function(this)
    if isMcmActive() and Screen.removeRestoreDefaultsHint then
      Screen.removeRestoreDefaultsHint(this)
    end
  end)

  ObserveAfter("SettingsMainGameController", "OnLocalizationChanged", function(this)
    if isMcmActive() and Screen.onLocalizationChanged then
      Screen.onLocalizationChanged(this)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitAction", function(_, id)
    if isMcmActive() and Screen.handleUiAction then
      Screen.handleUiAction(id)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitStep", function(_, id, forward)
    if isMcmActive() and Screen.handleUiStep then
      Screen.handleUiStep(id, forward)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitNumber", function(_, id, value)
    if isMcmActive() and Screen.handleUiNumber then
      Screen.handleUiNumber(id, value)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitKey", function(_, id, value)
    if isMcmActive() and Screen.handleUiKey then
      Screen.handleUiKey(id, value)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitKeyListening", function(_, id, active)
    if isMcmActive() and Screen.handleUiKeyListening then
      Screen.handleUiKeyListening(id, active)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitHover", function(_, id, description, hovered)
    if isMcmActive() and Screen.handleUiHover then
      Screen.handleUiHover(id, description, hovered)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitReset", function(_, id)
    if isMcmActive() and Screen.handleUiReset then
      Screen.handleUiReset(id)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitSearch", function(_, context, value)
    if isMcmActive() and Screen.handleUiSearch then
      Screen.handleUiSearch(context, value)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitSearchFocus", function(_, context, focused)
    if isMcmActive() and Screen.handleUiSearchFocus then
      Screen.handleUiSearchFocus(context, focused)
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitTextMeasurementsReady", function()
    if isMcmActive() and Screen.onTextMeasurementsReady then
      Screen.onTextMeasurementsReady()
    end
  end)

  Observe("SettingsMainGameController", "McmUiEmitClosing", function()
    if isMcmActive() then
      if Screen.handleClosing then
        Screen.handleClosing(beginNativeSettingsClose)
      else
        beginNativeSettingsClose()
      end
    end
  end)

  Observe("SettingsMainGameController", "RequestClose", function()
    if isMcmActive() then
      gameplayState.hotkeyHeld = false
      if isGameplayMcmActive() then
        logGameplay("Settings close lifecycle received")
      end
      Screen.close()
    end
  end)

  ObserveAfter("SettingsMainGameController", "RequestClose", function()
    finishNativeSettingsClose()
  end)
end)

registerForEvent("onUpdate", function()
  if gameplayState.requested then
    local ok, err = pcall(performGameplayOpen)
    if not ok then
      abortGameplayOpen("gameplay MCM preparation failed unexpectedly: " .. tostring(err))
    end
  end
  if gameplayState.opening then
    local stage = type(SettingsEntry.stage) == "function" and SettingsEntry.stage() or nil
    local paused = type(SettingsEntry.isPaused) == "function" and SettingsEntry.isPaused() == true
    if gameplayState.controllerAttached and paused then
      resetGameplayOpen()
      logGameplay("Settings entry attached inside the active native pause host")
    else
      gameplayState.timeoutFrames = gameplayState.timeoutFrames - 1
    end
    if gameplayState.opening and gameplayState.timeoutFrames <= 0 then
      abortGameplayOpen(
        "gameplay Settings transition did not attach before the open request timed out; stage: "
          .. tostring(stage)
          .. ", paused: "
          .. tostring(paused)
      )
    end
  end
  if
    isMcmActive()
    and (not gameplayState.opening or gameplayState.controllerAttached)
    and Screen.update
  then
    local ok, err = pcall(Screen.update)
    if not ok then
      logError("renderer update failed: " .. tostring(err))
      if Screen.abort then
        pcall(Screen.abort, "Renderer update failed: " .. tostring(err))
      elseif Screen.close then
        pcall(Screen.close)
      end
      leaveNativeSettingsMode()
    end
  end
  pcall(Logger.flush)
end)

registerForEvent("onShutdown", function()
  nativeSettingsState.closing = false
  if Screen and Screen.close then
    Screen.close()
  end
  resetGameplayOpen()
  gameplayState.hotkeyHeld = false
  pcall(SettingsEntry.cancel)
  leaveNativeSettingsMode()
  Logger.flush()
end)
