local SettingsEntry = {}

local SYSTEM_NAME = "ModConfigurationMenu.UI.MCMSettingsEntrySystem"

local function isDefined(value)
  if value == nil then
    return false
  end
  if type(IsDefined) ~= "function" then
    return true
  end
  local ok, result = pcall(IsDefined, value)
  return ok and result == true
end

local function getSystem()
  if Game == nil or type(Game.GetScriptableSystemsContainer) ~= "function" then
    return nil, "scriptable systems are unavailable"
  end
  local ok, systemOrError = pcall(function()
    local container = Game.GetScriptableSystemsContainer()
    if not isDefined(container) then
      return nil
    end
    return container:Get(SYSTEM_NAME)
  end)
  if not ok then
    return nil, tostring(systemOrError)
  end
  if not isDefined(systemOrError) then
    return nil, "Settings entry system is unavailable"
  end
  return systemOrError, nil
end

local function getBool(definition, field)
  if definition == nil or field == nil then
    return false, nil
  end
  local ok, valueOrError = pcall(function()
    local blackboardSystem = Game.GetBlackboardSystem()
    if not isDefined(blackboardSystem) then
      error("blackboard system is unavailable")
    end
    local blackboard = blackboardSystem:Get(definition)
    if not isDefined(blackboard) then
      error("blackboard is unavailable")
    end
    return blackboard:GetBool(field)
  end)
  if not ok then
    return nil, tostring(valueOrError)
  end
  return valueOrError == true, nil
end

local function getLocalInt(player, definition, field)
  if player == nil or definition == nil or field == nil then
    return nil, nil
  end
  local ok, valueOrError = pcall(function()
    local blackboardSystem = Game.GetBlackboardSystem()
    if not isDefined(blackboardSystem) then
      error("blackboard system is unavailable")
    end
    local blackboard = blackboardSystem:GetLocalInstanced(player:GetEntityID(), definition)
    if not isDefined(blackboard) then
      error("local player blackboard is unavailable")
    end
    return blackboard:GetInt(field)
  end)
  if not ok then
    return nil, tostring(valueOrError)
  end
  return tonumber(valueOrError), nil
end

function SettingsEntry.canOpen(mcmActive)
  if mcmActive == true then
    return false, "mcm_active"
  end
  if Game == nil then
    return false, "game_unavailable"
  end

  local ok, allowedOrError, reason = pcall(function()
    local player = Game.GetPlayer()
    if not isDefined(player) or player:IsAttached() ~= true then
      return false, "player_unavailable"
    end

    local requests = Game.GetSystemRequestsHandler()
    if not isDefined(requests) or requests:IsPreGame() == true then
      return false, "pregame"
    end

    local definitions = Game.GetAllBlackboardDefs()
    if definitions == nil or definitions.UI_System == nil then
      return false, "ui_state_unavailable"
    end
    local inMenu, menuError = getBool(definitions.UI_System, definitions.UI_System.IsInMenu)
    if menuError ~= nil then
      return false, "ui_state_unavailable"
    end
    if inMenu then
      return false, "menu_open"
    end

    local photoMode =
      getBool(definitions.PhotoMode, definitions.PhotoMode and definitions.PhotoMode.IsActive)
    if photoMode == true then
      return false, "photo_mode"
    end
    local braindance =
      getBool(definitions.Braindance, definitions.Braindance and definitions.Braindance.IsActive)
    if braindance == true then
      return false, "braindance"
    end

    local sceneTier, sceneError = getLocalInt(
      player,
      definitions.PlayerStateMachine,
      definitions.PlayerStateMachine and definitions.PlayerStateMachine.SceneTier
    )
    if sceneError ~= nil then
      return false, "scene_state_unavailable"
    end
    if sceneTier ~= nil and sceneTier >= 3 then
      return false, "scene"
    end

    local fastForward = getBool(
      definitions.UI_FastForward,
      definitions.UI_FastForward and definitions.UI_FastForward.FastForwardAvailable
    )
    if fastForward == true then
      return false, "fast_forward"
    end

    local timeSystem = Game.GetTimeSystem()
    if isDefined(timeSystem) then
      if timeSystem:IsTimeDilationActive("UI_TutorialPopup") == true then
        return false, "tutorial_popup"
      end
      if
        timeSystem:IsTimeDilationActive("radial") == true
        or timeSystem:IsTimeDilationActive("radialMenu") == true
      then
        return false, "modal_popup"
      end
    end
    return true, nil
  end)
  if not ok then
    return false, "state_check_failed: " .. tostring(allowedOrError)
  end
  return allowedOrError, reason
end

function SettingsEntry.open()
  local system, systemError = getSystem()
  if system == nil then
    return false, systemError
  end
  local ok, resultOrError = pcall(function()
    return system:Open()
  end)
  if not ok then
    return false, tostring(resultOrError)
  end
  if resultOrError ~= 0 then
    return false, "the native pause-menu event channel is unavailable"
  end
  return true, nil
end

function SettingsEntry.ready()
  local system, systemError = getSystem()
  if system == nil then
    return false, systemError
  end
  local ok, resultOrError = pcall(function()
    return system:Ready()
  end)
  if not ok then
    return false, tostring(resultOrError)
  end
  if resultOrError == 0 then
    return true, nil
  end
  if resultOrError == 1 then
    return false, "the in-game menu event channel is unavailable"
  end
  return false,
    "the game returned an unknown Settings readiness result: " .. tostring(resultOrError)
end

function SettingsEntry.cancel()
  local system, systemError = getSystem()
  if system == nil then
    return false, systemError
  end
  local ok, errorOrNil = pcall(function()
    system:Cancel()
  end)
  if not ok then
    return false, tostring(errorOrNil)
  end
  return true, nil
end

function SettingsEntry.stage()
  local system = getSystem()
  if system == nil then
    return nil
  end
  local ok, stageOrError = pcall(function()
    return system:GetStage()
  end)
  if not ok then
    return nil
  end
  return stageOrError
end

function SettingsEntry.isPaused()
  if Game == nil or type(Game.GetSystemRequestsHandler) ~= "function" then
    return false
  end
  local ok, paused = pcall(function()
    local requests = Game.GetSystemRequestsHandler()
    return isDefined(requests) and requests:IsGamePaused() == true
  end)
  return ok and paused == true
end

return SettingsEntry
