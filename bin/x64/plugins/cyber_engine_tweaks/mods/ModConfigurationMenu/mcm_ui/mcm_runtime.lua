local Layout = require("mcm_ui/mcm_layout")
local Host = require("mcm_ui/mcm_host")
local Logger = require("mcm_ui/mcm_logger")
local Localization = require("mcm_ui/mcm_localization")
local MenuIntegration = require("mcm_ui/mcm_menu_bridge")
local Preferences = require("mcm_ui/mcm_preferences")
local State = require("mcm_ui/mcm_state")
local Text = require("mcm_ui/mcm_text")

local Runtime = {}
Runtime.__index = Runtime

function Runtime.new()
  local self = setmetatable({}, Runtime)

  self.state = State.new(Preferences.load())
  self.layout = Layout
  self.localization = Localization
  self.preferences = Preferences
  self.menuIntegration = MenuIntegration
  self.text = Text
  self.menuIntegration.setLabel(self.state.menuEntryLabel)
  self.menuIntegration.setFrameworkRedirectEnabled(self.state.redirectFrameworkMenuEntries)

  return self
end

function Runtime:logError(message)
  Logger.error(message)
end

function Runtime:first(callable, ...)
  if type(callable) ~= "function" then
    return nil
  end

  return select(1, callable(...))
end

function Runtime:safe(value)
  return Text.safe(value)
end

function Runtime:t(key, values)
  return Localization.text(key, values)
end

function Runtime:setStatus(message, kind)
  if kind ~= "success" and kind ~= "error" then
    kind = "info"
  end

  self.state.status = self:safe(message)
  self.state.statusKind = kind
  return self.state.status
end

function Runtime:currentApiStatus(errorValue)
  if errorValue ~= nil then
    return self:safe(errorValue)
  end

  local api = self.state.api
  if api == nil or type(api.getStatus) ~= "function" then
    return ""
  end

  return self:safe(self:first(api.getStatus))
end

function Runtime:descriptionText(value)
  return Text.description(value, nil)
end

function Runtime:queueRender()
  self.state.renderQueued = true
end

function Runtime:updateViewport(host)
  local state = self.state
  state.viewportWidth = Layout.BASE_WIDTH
  state.viewportHeight = Layout.BASE_HEIGHT

  local ok, size = pcall(function()
    return host:GetSize()
  end)
  if
    ok
    and size ~= nil
    and tonumber(size.X) ~= nil
    and tonumber(size.Y) ~= nil
    and size.X > 0
    and size.Y > 0
  then
    state.viewportWidth = size.X
    state.viewportHeight = size.Y
  end

  state.hostLayout = Host.settings(state.viewportWidth, state.viewportHeight, state)
  state.viewportWidth = state.hostLayout.width
  state.viewportHeight = state.hostLayout.height
  local requestedUniformScale = state.hostLayout.density * state.hostLayout.requestedScale
  state.scaleX = requestedUniformScale
  state.scaleY = requestedUniformScale
  return state.hostLayout
end

function Runtime:syncResolvedLayout(controller)
  local resolved = Layout.syncFromController(controller)
  if resolved == nil then
    return false
  end

  local state = self.state
  state.resolvedLayoutProfile = Host.profileAt((resolved.profileCode or 1) + 1)
  state.uniformScale = resolved.uniformScale
  state.scaleX = resolved.uniformScale
  state.scaleY = resolved.uniformScale
  state.layoutOffsetX = resolved.offsetX
  state.layoutOffsetY = resolved.offsetY
  state.layoutCanvasWidth = resolved.canvasWidth
  state.layoutCanvasHeight = resolved.canvasHeight
  return true
end

return Runtime
