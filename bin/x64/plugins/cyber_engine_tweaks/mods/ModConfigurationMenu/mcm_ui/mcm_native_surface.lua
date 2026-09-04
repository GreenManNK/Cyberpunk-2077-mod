local RedscriptSurface = {}
RedscriptSurface.__index = RedscriptSurface

local CUSTOM_CONTENT_BASE_HEIGHT = 400
local CUSTOM_CONTENT_PADDING = 10
local COMPACT_CUSTOM_HEIGHT_RATIO = 0.7

local function customRenderScale(setting)
  local scale = tonumber(type(setting) == "table" and setting.customRenderScale or nil) or 1
  return math.max(0.1, math.min(4, scale))
end

local function customReservedHeight(runtime, setting)
  return math.max(
    runtime.layout.metrics.settingsRowH,
    (CUSTOM_CONTENT_BASE_HEIGHT * customRenderScale(setting)) + CUSTOM_CONTENT_PADDING
  )
end

function RedscriptSurface.new(runtime)
  return setmetatable({
    runtime = runtime,
    bindings = {},
    bindingGeneration = 0,
    nextBindingId = 0,
    sidebarScrollKey = nil,
    contentScrollKey = nil,
    baseDescription = "",
    textPrompt = nil,
    pendingPromptOpen = nil,
    pendingTextInputMount = nil,
    startupModalDelay = nil,
    startupModalReady = false,
    pendingCustomMeasurements = {},
    contentMeasurementDelay = 0,
    renderScrollContext = nil,
  }, RedscriptSurface)
end

function RedscriptSurface:bind(kind, callback, setting, description, allowDuringOperation)
  self.nextBindingId = self.nextBindingId + 1
  local id = string.format("mcm_%d_%d", self.bindingGeneration, self.nextBindingId)
  self.bindings[id] = {
    kind = kind,
    callback = callback,
    setting = setting,
    description = self.runtime:safe(description),
    allowDuringOperation = allowDuringOperation == true,
  }
  return id
end

function RedscriptSurface:clearBindings()
  self.bindings = {}
  self.bindingGeneration = self.bindingGeneration + 1
  self.nextBindingId = 0
  self.runtime.state.hoveredSidebarItem = nil
  self.runtime.state.hoveredSetting = nil
end

function RedscriptSurface:invoke(callback)
  if type(callback) ~= "function" then
    return false
  end

  local controller = self.runtime.state.controller
  if IsDefined(controller) then
    controller:McmUiBeginExternalMutation()
  end
  local ok, err = pcall(callback)
  if IsDefined(controller) then
    controller:McmUiEndExternalMutation()
  end
  if not ok then
    self.runtime:setStatus("MCM action failed: " .. tostring(err), "error")
    self.runtime:logError("redscript UI action failed: " .. tostring(err))
    self.runtime:queueRender()
    return false
  end
  return true
end

function RedscriptSurface:buttonWidth(label)
  local controller = self.runtime.state.controller
  if IsDefined(controller) then
    local ok, measured = pcall(function()
      return controller:McmUiResolveActionWidth(self.runtime:safe(label))
    end)
    measured = ok and tonumber(measured) or nil
    if measured ~= nil and measured > 0 then
      return measured
    end
  end
  return tonumber(self.runtime.layout.ACTION_FALLBACK_WIDTH) or 180
end

function RedscriptSurface:descriptionHeight()
  return self.runtime.layout.metrics.descriptionH
end

function RedscriptSurface:modalMessageHeight(value)
  local modal = self.runtime.layout.MODAL
  local controller = self.runtime.state.controller
  local measured = nil
  if IsDefined(controller) then
    local ok, result = pcall(function()
      return controller:McmUiResolveWrappedTextHeight(
        self.runtime:safe(value),
        modal.messageWidth,
        modal.messageFontSize
      )
    end)
    measured = ok and tonumber(result) or nil
  end
  return math.max(modal.messageMinHeight, measured or 0)
end

function RedscriptSurface:messageRowHeight(value)
  local layout = self.runtime.layout.metrics
  local measured = nil
  local controller = self.runtime.state.controller
  if IsDefined(controller) then
    local ok, result = pcall(function()
      return controller:McmUiResolveWrappedTextHeight(
        self.runtime:safe(value),
        layout.settingsW - (layout.settingsMessagePaddingX * 2),
        layout.settingsMessageFontSize
      )
    end)
    measured = ok and tonumber(result) or nil
  end
  return math.max(layout.settingsRowH, (measured or 0) + (layout.settingsMessagePaddingY * 2))
end

function RedscriptSurface:contentRowHeight(row, rowKey)
  local runtime = self.runtime
  if row.kind == "message" then
    return self:messageRowHeight(row.label)
  end
  if
    row.kind == "setting"
    and row.setting ~= nil
    and row.setting.type == "custom"
    and row.setting.capabilities ~= nil
    and row.setting.capabilities.customRender == true
  then
    return tonumber(runtime.state.customHeights[row.setting.id])
      or customReservedHeight(runtime, row.setting)
  end
  return runtime.layout.metrics.settingsRowH
end

function RedscriptSurface:scrollContexts()
  local state = self.runtime.state
  local route = state.route or {}
  local view = tostring(route.view or "mods")
  local sidebar = view
  local content = view

  if view == "mods" then
    local modKey = tostring(state.selectedModKey or state.rememberedModKey or "")
    sidebar = table.concat({
      view,
      tostring(state.providerFilter or "all"),
      tostring(state.modSortMode or "az"),
      tostring(state.modSortWithProvider == true),
      tostring(state.favoriteUxMode or "both"),
      tostring(state.favoriteRevision or 0),
      tostring(state.searchQueries and state.searchQueries.sidebar or ""),
    }, "|")
    content = table.concat({
      view,
      modKey,
      tostring(state.settingsSortMode or "file"),
      tostring(state.searchQueries and state.searchQueries.content or ""),
    }, "|")
  elseif view == "settings" then
    local category = tostring(state.settingsCategory or "general")
    sidebar = view
    content = view .. "|" .. category
  elseif view == "mod_presets" then
    local modKey = tostring(route.modKey or state.rememberedModKey or "")
    local presetId = tostring(state.selectedPresetId or route.presetId or "")
    sidebar = table.concat({ view, modKey }, "|")
    content = table.concat({ view, modKey, presetId }, "|")
  elseif view == "collections" then
    local collectionId = tostring(state.selectedCollectionId or route.collectionId or "")
    local entryId = tostring(state.selectedCollectionEntryId or route.entryId or "")
    sidebar = view
    content = table.concat({ view, collectionId, entryId }, "|")
  end

  return {
    sidebar = sidebar,
    content = content,
  }
end

function RedscriptSurface:capturePositions(options)
  options = options or {}
  local state = self.runtime.state
  local controller = state.controller
  if not IsDefined(controller) then
    return
  end

  if options.sidebar ~= false and self.sidebarScrollKey ~= nil then
    local ok, value = pcall(function()
      return controller:McmUiGetSidebarScrollPosition()
    end)
    if ok and tonumber(value) ~= nil then
      state.scrollPositions[self.sidebarScrollKey] = tonumber(value)
    end
  end
  if options.content ~= false and self.contentScrollKey ~= nil then
    local ok, value = pcall(function()
      return controller:McmUiGetContentScrollPosition()
    end)
    if ok and tonumber(value) ~= nil then
      state.scrollPositions[self.contentScrollKey] = tonumber(value)
    end
  end
end

function RedscriptSurface:prepareScrollCapture()
  local nextContext = self:scrollContexts()
  local previousContext = self.renderScrollContext
  self:capturePositions({
    sidebar = previousContext ~= nil and previousContext.sidebar == nextContext.sidebar,
    content = previousContext ~= nil and previousContext.content == nextContext.content,
  })
  self.renderScrollContext = nextContext
end

function RedscriptSurface:removeRoot()
  self:capturePositions()
  local state = self.runtime.state
  if IsDefined(state.controller) then
    pcall(function()
      state.controller:McmUiRemove()
    end)
  end
  self.textPrompt = nil
  self.pendingPromptOpen = nil
  self.pendingTextInputMount = nil
  self.startupModalDelay = nil
  self.startupModalReady = false
  state.inputModalActive = false
  state.searchInputContext = nil
  state.searchPendingFrames = { sidebar = 0, content = 0 }
  state.searchDrafts = {
    sidebar = state.searchQueries and state.searchQueries.sidebar or "",
    content = state.searchQueries and state.searchQueries.content or "",
  }
  self.renderScrollContext = nil
  self:clearBindings()
end

function RedscriptSurface:updateContentMeasurements()
  if self.contentMeasurementDelay > 0 then
    self.contentMeasurementDelay = self.contentMeasurementDelay - 1
    return
  end
  if #self.pendingCustomMeasurements == 0 then
    return
  end

  local runtime = self.runtime
  local state = runtime.state
  local controller = state.controller
  if not IsDefined(controller) then
    self.pendingCustomMeasurements = {}
    return
  end

  local changed = false
  for _, pending in ipairs(self.pendingCustomMeasurements) do
    local nextHeight = nil
    if pending.compact then
      nextHeight =
        math.max(1, math.ceil(runtime.layout.metrics.settingsRowH * COMPACT_CUSTOM_HEIGHT_RATIO))
    else
      local ok, result = pcall(function()
        return controller:McmUiMeasureCustom(pending.host, pending.renderScale)
      end)
      local measured = ok and tonumber(result) or nil
      if measured ~= nil and measured > 0 then
        local measuredHeight = math.ceil(measured + 10)
        local fallbackHeight = tonumber(pending.fallbackHeight)
        if
          measuredHeight <= runtime.layout.metrics.settingsRowH
          and fallbackHeight ~= nil
          and fallbackHeight > runtime.layout.metrics.settingsRowH
        then
          nextHeight = fallbackHeight
        else
          nextHeight = math.max(runtime.layout.metrics.settingsRowH, measuredHeight)
        end
      end
    end
    local previous = tonumber(state.customHeights[pending.settingId])
    if nextHeight == nil and previous == nil then
      nextHeight = tonumber(pending.fallbackHeight)
    end
    if nextHeight ~= nil then
      if previous == nil or math.abs(previous - nextHeight) > 2 then
        state.customHeights[pending.settingId] = nextHeight
        changed = true
      end
    end
  end
  self.pendingCustomMeasurements = {}
  if changed then
    runtime:queueRender()
  end
end

require("mcm_ui/mcm_native_render").attach(RedscriptSurface, {
  customRenderScale = customRenderScale,
  customReservedHeight = customReservedHeight,
})
require("mcm_ui/mcm_native_input").attach(RedscriptSurface)

return RedscriptSurface
