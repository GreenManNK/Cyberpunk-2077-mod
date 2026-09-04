local Menu = {}

Menu.LABEL = "MCM"
Menu.EVENT = "OnSwitchToMCM"
Menu.SETTINGS_EVENT = "OnSwitchToSettings"
Menu.NATIVE_SETTINGS_LABEL = "Mods"

local injectedForBuild = {}
local activeBuildLists = {}
local ownDataSeeds = {}
local hiddenFrameworkWidgets = {}
local activeActionListBuilds = {}
local frameworkRedirectEnabled = true
local frameworkMenuEvents = {
  OnSwitchToModSettings = true,
  OnSwitchToRCFSettings = true,
}

local function readData(target)
  if target == nil or target.GetData == nil then
    return nil
  end

  local ok, data = pcall(function()
    return target:GetData()
  end)
  if not ok then
    return nil
  end

  return data
end

local function lower(value)
  return string.lower(tostring(value or ""))
end

local function dataLabel(data)
  if data == nil then
    return ""
  end

  local label = data.label
  if type(label) == "table" and label.value ~= nil then
    label = label.value
  end
  return tostring(label or "")
end

local function eventName(data)
  if data == nil then
    return ""
  end

  local value = data.eventName
  if type(NameToString) == "function" then
    local ok, result = pcall(NameToString, value)
    if ok and result ~= nil then
      return tostring(result)
    end
  end
  if type(value) == "table" and value.value ~= nil then
    return tostring(value.value)
  end
  return tostring(value or "")
end

local function rememberOwnData(data)
  local ok, seed = pcall(CalcSeed, data)
  if ok and seed ~= nil then
    ownDataSeeds[seed] = true
  end
end

local function isOwnData(data)
  if data == nil then
    return false
  end

  local ok, seed = pcall(CalcSeed, data)
  if ok and seed ~= nil and ownDataSeeds[seed] then
    return true
  end

  return eventName(data) == Menu.EVENT
end

local function isFrameworkButton(data)
  if frameworkMenuEvents[eventName(data)] then
    return true
  end

  local label = lower(dataLabel(data))
  return label == "mods" or label == "mod settings"
end

local function isFrameworkTarget(data)
  if data == nil then
    return false
  end

  if frameworkMenuEvents[eventName(data)] then
    return true
  end

  return eventName(data) == Menu.SETTINGS_EVENT and lower(dataLabel(data)) == "mods"
end

local function widgetId(widget)
  local ok, seed = pcall(CalcSeed, widget)
  if ok and seed ~= nil then
    return seed
  end
  return nil
end

local function objectId(value)
  local ok, seed = pcall(CalcSeed, value)
  if ok and seed ~= nil then
    return tostring(seed)
  end
  return tostring(value)
end

local function readWidgetVisibility(widget)
  if widget == nil or widget.IsVisible == nil then
    return true
  end

  local ok, visible = pcall(function()
    return widget:IsVisible()
  end)
  if ok then
    return visible == true
  end
  return true
end

local function setOwnVisualLabel(widget)
  if widget == nil then
    return false
  end

  if widget.GetText ~= nil and widget.SetText ~= nil then
    local ok, text = pcall(function()
      return widget:GetText()
    end)
    if ok and tostring(text or "") == Menu.NATIVE_SETTINGS_LABEL then
      local changed = pcall(function()
        widget:SetText(Menu.LABEL)
      end)
      if changed then
        return true
      end
    end
  end

  if widget.GetNumChildren ~= nil then
    for index = 0, widget:GetNumChildren() - 1 do
      if setOwnVisualLabel(widget:GetWidgetByIndex(index)) then
        return true
      end
    end
  end
  return false
end

local function syncFrameworkButtonVisibility(widget, seenWidgets)
  if widget == nil then
    return
  end

  local id = widgetId(widget)
  if id ~= nil then
    seenWidgets[id] = true
  end

  local controller = widget:GetController()
  local data = readData(controller)
  if data ~= nil then
    if isOwnData(data) then
      setOwnVisualLabel(widget)
      if id ~= nil and hiddenFrameworkWidgets[id] ~= nil then
        local previous = hiddenFrameworkWidgets[id]
        widget:SetVisible(previous.wasVisible)
        widget:SetAffectsLayoutWhenHidden(previous.wasVisible)
        hiddenFrameworkWidgets[id] = nil
      end
    elseif frameworkRedirectEnabled and isFrameworkButton(data) then
      if id ~= nil and hiddenFrameworkWidgets[id] == nil then
        hiddenFrameworkWidgets[id] = {
          wasVisible = readWidgetVisibility(widget),
        }
      end
      widget:SetVisible(false)
      widget:SetAffectsLayoutWhenHidden(false)
    elseif id ~= nil and hiddenFrameworkWidgets[id] ~= nil then
      local previous = hiddenFrameworkWidgets[id]
      widget:SetVisible(previous.wasVisible)
      widget:SetAffectsLayoutWhenHidden(previous.wasVisible)
      hiddenFrameworkWidgets[id] = nil
    end
  end

  if widget.GetNumChildren ~= nil then
    for index = 0, widget:GetNumChildren() - 1 do
      syncFrameworkButtonVisibility(widget:GetWidgetByIndex(index), seenWidgets)
    end
  end
end

local function updateFrameworkButtonVisibility(root)
  local seenWidgets = {}
  syncFrameworkButtonVisibility(root, seenWidgets)

  for id in pairs(hiddenFrameworkWidgets) do
    if not seenWidgets[id] then
      hiddenFrameworkWidgets[id] = nil
    end
  end
end

local function isSettingsData(data)
  if eventName(data) == Menu.SETTINGS_EVENT then
    return true
  end

  if type(GetLocalizedText) == "function" then
    local ok, label = pcall(GetLocalizedText, "UI-Labels-Settings")
    if ok and label ~= nil and dataLabel(data) == tostring(label) then
      return true
    end
  end
  return lower(dataLabel(data)) == "settings"
end

local function newMcmData()
  local data = PauseMenuListItemData.new()
  data.label = Menu.NATIVE_SETTINGS_LABEL
  data.eventName = Menu.EVENT
  data.action = PauseMenuAction.OpenSubMenu
  rememberOwnData(data)
  return data
end

local function injectMcmButton(controller)
  if controller == nil or controller.menuListController == nil then
    return false
  end
  controller.menuListController:PushData(newMcmData(), false)
  return true
end

function Menu.beginBuild(controller)
  if controller == nil then
    return
  end

  local controllerId = CalcSeed(controller)
  injectedForBuild[controllerId] = false
  if controller.menuListController ~= nil then
    activeBuildLists[CalcSeed(controller.menuListController)] = {
      controllerId = controllerId,
      inserting = false,
    }
  end
end

function Menu.onDataPushed(listController, data)
  if listController == nil or data == nil then
    return
  end

  local listId = CalcSeed(listController)
  local build = activeBuildLists[listId]
  if build == nil or build.inserting or injectedForBuild[build.controllerId] then
    return
  end
  if isOwnData(data) or not isSettingsData(data) then
    return
  end

  build.inserting = true
  listController:PushData(newMcmData(), false)
  build.inserting = false
  injectedForBuild[build.controllerId] = true
end

function Menu.process(controller)
  if controller == nil then
    return
  end

  local root = nil
  if controller.GetRootCompoundWidget ~= nil then
    root = controller:GetRootCompoundWidget()
  end
  if root then
    updateFrameworkButtonVisibility(root)
  end

  local id = CalcSeed(controller)
  if controller.menuListController ~= nil then
    activeBuildLists[CalcSeed(controller.menuListController)] = nil
  end
  if not injectedForBuild[id] then
    injectedForBuild[id] = injectMcmButton(controller)
    if injectedForBuild[id] and controller.menuListController.Refresh then
      controller.menuListController:Refresh()
    end
  end

  if controller.GetRootCompoundWidget ~= nil then
    root = controller:GetRootCompoundWidget()
  else
    root = nil
  end
  if root then
    updateFrameworkButtonVisibility(root)
  end
end

function Menu.runActionListBuild(controller, callback)
  if controller == nil or type(callback) ~= "function" then
    return false
  end

  local id = objectId(controller)
  if activeActionListBuilds[id] then
    return false
  end

  activeActionListBuilds[id] = true
  local ok, result = pcall(callback)
  activeActionListBuilds[id] = nil

  if not ok then
    error(result, 0)
  end
  return true, result
end

function Menu.setLabel(value)
  if value == "MODS" then
    Menu.LABEL = "Mods"
  else
    Menu.LABEL = "MCM"
  end
end

function Menu.getLabel()
  return Menu.LABEL
end

function Menu.setFrameworkRedirectEnabled(value)
  frameworkRedirectEnabled = value ~= false
end

function Menu.isFrameworkRedirectEnabled()
  return frameworkRedirectEnabled
end

function Menu.isMcmTarget(target)
  local data = readData(target)
  return isOwnData(data)
end

function Menu.isActivationTarget(target)
  local data = readData(target)
  return isOwnData(data) or (frameworkRedirectEnabled and isFrameworkTarget(data))
end

function Menu.forwardToSettings(target, callback)
  local data = readData(target)
  if
    (not isOwnData(data) and not (frameworkRedirectEnabled and isFrameworkTarget(data)))
    or type(callback) ~= "function"
  then
    return false
  end

  local originalEvent = data.eventName
  local originalLabel = data.label
  data.eventName = Menu.SETTINGS_EVENT
  data.label = Menu.NATIVE_SETTINGS_LABEL
  local ok, result = pcall(callback)
  data.eventName = originalEvent
  data.label = originalLabel

  if not ok then
    error(result, 0)
  end
  return true, result
end

return Menu
