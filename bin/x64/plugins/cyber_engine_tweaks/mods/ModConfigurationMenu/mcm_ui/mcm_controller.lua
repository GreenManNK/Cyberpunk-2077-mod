local Routes = require("mcm_ui/mcm_routes")
local InstallHealth = require("mcm_ui/mcm_install_health")

local Controller = {}
Controller.__index = Controller

local function syncOperation(runtime, operation)
  if operation == nil then
    return
  end

  local state = runtime.state
  local result = operation.result
  local requiresConfirmation = operation.kind == "apply_collection"
    and operation.state == "completed"
    and result ~= nil
    and result.requiresConfirmation == true
  if
    operation.kind == "apply_collection"
    and (operation.state == "completed" or operation.state == "failed")
    and not requiresConfirmation
  then
    state.lastCollectionApply = operation
  elseif operation.kind == "rollback_collection" and operation.state == "completed" then
    state.lastCollectionApply = nil
  end

  state.activeOperationId = operation.id
  runtime:setStatus(
    (operation.state == "failed" and (operation.error or operation.message))
      or operation.message
      or operation.error
      or runtime:currentApiStatus(),
    operation.state == "failed" and "error"
      or (operation.state == "completed" and "success" or "info")
  )
  if
    operation.state == "completed"
    or operation.state == "failed"
    or operation.state == "cancelled"
  then
    state.activeOperationId = nil
    if state.route.view == "collections" then
      runtime.model:refreshCollections()
    end
    if requiresConfirmation then
      runtime.model:requestCollectionApplyConfirmation(operation)
    elseif
      operation.kind == "apply_collection"
      and operation.state == "completed"
      and result ~= nil
      and result.compatibility ~= nil
      and (result.compatibility.skippedMods > 0 or result.compatibility.skippedSettings > 0)
    then
      local summary = result.compatibility
      local key = summary.compatibleSettings > 0 and "collections.compatibility_result"
        or "collections.compatibility_none"
      runtime:setStatus(
        runtime:t(key, {
          mods = #result.applied,
          settings = summary.compatibleSettings,
          skippedMods = summary.skippedMods,
          skippedSettings = summary.skippedSettings,
        }),
        summary.compatibleSettings > 0 and "success" or "warning"
      )
    end
  end
end

function Controller.new(runtime)
  return setmetatable({ runtime = runtime }, Controller)
end

function Controller:activate(api, onClosed, context)
  local runtime = self.runtime
  local state = runtime.state
  if state.active then
    state.api = api or state.api
    return
  end

  local installHealthNotices = {}
  local scanOk, scanResult = pcall(InstallHealth.scan)
  if scanOk and type(scanResult) == "table" then
    installHealthNotices = scanResult
  elseif not scanOk then
    runtime:logError("Install health scan failed: " .. tostring(scanResult))
  end

  state.active = true
  state.api = api
  state.onClosed = onClosed
  state.gameplayEntry = type(context) == "table" and context.gameplayEntry == true
  state.apiSubscriptions = {}

  if state.api ~= nil and type(state.api.subscribe) == "function" then
    local indexToken = runtime:first(state.api.subscribe, "index.changed", function()
      state.modelSyncQueued = true
    end)
    if indexToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = indexToken
    end

    local schemaToken = runtime:first(state.api.subscribe, "schema.changed", function(payload)
      if payload == nil or payload.mod == nil or payload.mod.key == state.selectedModKey then
        runtime:queueRender()
      end
    end)
    if schemaToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = schemaToken
    end

    local draftsToken = runtime:first(state.api.subscribe, "drafts.changed", function(payload)
      if payload == nil or payload.modKey == nil or payload.modKey == state.selectedModKey then
        self:syncCloseGuard()
        runtime:queueRender()
      end
    end)
    if draftsToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = draftsToken
    end

    local presetToken = runtime:first(state.api.subscribe, "presets.changed", function(payload)
      if
        state.route.view == "mod_presets"
        and (payload == nil or payload.modKey == nil or payload.modKey == state.route.modKey)
      then
        runtime.model:refreshPresets()
        runtime:queueRender()
      end
    end)
    if presetToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = presetToken
    end

    local collectionToken = runtime:first(state.api.subscribe, "collections.changed", function()
      if state.route.view == "collections" then
        runtime.model:refreshCollections()
        runtime:queueRender()
      end
    end)
    if collectionToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = collectionToken
    end

    local operationToken = runtime:first(state.api.subscribe, "operation.changed", function(payload)
      local operation = payload and payload.operation
      if operation ~= nil then
        syncOperation(runtime, operation)
        runtime:queueRender()
      end
    end)
    if operationToken ~= nil then
      state.apiSubscriptions[#state.apiSubscriptions + 1] = operationToken
    end
  end

  if
    state.activeOperationId ~= nil
    and state.api ~= nil
    and type(state.api.getOperation) == "function"
  then
    local operation = runtime:first(state.api.getOperation, state.activeOperationId)
    syncOperation(runtime, operation)
  end

  if type(runtime.model.beginInitialSetup) == "function" then
    runtime.model:beginInitialSetup()
  end
  state.installHealthNotices = installHealthNotices

  if runtime.model:shouldRefreshOnActivate() then
    runtime:setStatus(runtime:t("status.loading"))
    state.pendingRefresh = 1
  else
    local _, restoreError = runtime.model:restoreSelectedMod()
    runtime:setStatus(
      runtime:currentApiStatus(restoreError),
      restoreError ~= nil and "error" or "info"
    )
  end
end

function Controller:removeRestoreDefaultsHint(controller)
  local state = self.runtime.state
  if not state.active or not IsDefined(controller) then
    return
  end

  local hints = nil
  pcall(function()
    hints = controller.m_buttonHintsController
  end)
  if not IsDefined(hints) then
    pcall(function()
      hints = controller.buttonHintsController
    end)
  end
  if not IsDefined(hints) then
    return
  end

  local root = nil
  pcall(function()
    root = hints:GetRootWidget()
  end)
  if not IsDefined(root) then
    return
  end

  if state.hiddenButtonHintsRoot ~= root then
    local wasVisible = true
    local visibilityOk, visible = pcall(function()
      return root:IsVisible()
    end)
    if visibilityOk and type(visible) == "boolean" then
      wasVisible = visible
    end
    state.hiddenButtonHintsRoot = root
    state.hiddenButtonHintsWasVisible = wasVisible
  end

  pcall(function()
    root:SetVisible(false)
  end)
end

function Controller:restoreStockButtonHints()
  local state = self.runtime.state
  local root = state.hiddenButtonHintsRoot
  local wasVisible = state.hiddenButtonHintsWasVisible
  state.hiddenButtonHintsRoot = nil
  state.hiddenButtonHintsWasVisible = nil

  if IsDefined(root) then
    pcall(function()
      root:SetVisible(wasVisible ~= false)
    end)
  end
end

function Controller:hideGameplaySettingsBackdrop(root)
  local state = self.runtime.state
  state.hiddenSettingsBackdropWidgets = {}
  if state.gameplayEntry ~= true or not IsDefined(root) then
    return
  end

  for _, widgetName in ipairs({ "BG", "edge_fluff" }) do
    local widget = nil
    pcall(function()
      widget = root:GetWidgetByPath(BuildWidgetPath({ widgetName }))
    end)
    if IsDefined(widget) then
      local wasVisible = true
      local visibilityOk, visible = pcall(function()
        return widget:IsVisible()
      end)
      if visibilityOk and type(visible) == "boolean" then
        wasVisible = visible
      end
      state.hiddenSettingsBackdropWidgets[#state.hiddenSettingsBackdropWidgets + 1] = {
        widget = widget,
        wasVisible = wasVisible,
      }
      pcall(function()
        widget:SetVisible(false)
      end)
    end
  end
end

function Controller:syncGameplaySettingsBackdrop(root)
  local state = self.runtime.state
  self:restoreGameplaySettingsBackdrop()
  if not IsDefined(root) and IsDefined(state.controller) then
    root = state.controller:GetRootCompoundWidget()
  end
  self:hideGameplaySettingsBackdrop(root)
end

function Controller:restoreGameplaySettingsBackdrop()
  local state = self.runtime.state
  for _, hidden in ipairs(state.hiddenSettingsBackdropWidgets or {}) do
    if IsDefined(hidden.widget) then
      pcall(function()
        hidden.widget:SetVisible(hidden.wasVisible ~= false)
      end)
    end
  end
  state.hiddenSettingsBackdropWidgets = {}
end

function Controller:onLocalizationChanged(controller)
  local runtime = self.runtime
  if not runtime.state.active then
    return
  end

  runtime.localization.refresh()
  if IsDefined(controller or runtime.state.controller) then
    pcall(function()
      (controller or runtime.state.controller):McmUiClearTextMeasurementCache()
    end)
  end
  self:removeRestoreDefaultsHint(controller or runtime.state.controller)
  runtime:queueRender()
end

function Controller:onTextMeasurementsReady()
  local state = self.runtime.state
  if not state.active then
    return
  end
  state.textMeasurementRenderQueued = true
  self.runtime:queueRender()
end

function Controller:onInitialize(controller)
  local runtime = self.runtime
  local state = runtime.state
  if not state.active then
    return
  end

  runtime.localization.refresh()
  state.controller = controller
  pcall(function()
    controller:McmUiSetGameplayEntry(state.gameplayEntry == true)
  end)
  local root = controller:GetRootCompoundWidget()
  state.hiddenWrapper = nil
  if root ~= nil then
    state.hiddenWrapper = root:GetWidgetByPath(BuildWidgetPath({ "wrapper" }))
  end
  if IsDefined(state.hiddenWrapper) then
    state.hiddenWrapper:SetVisible(false)
  end
  self:syncGameplaySettingsBackdrop(root)
  self:removeRestoreDefaultsHint(controller)
  self:syncCloseGuard()

  state.renderQueued = false
  state.textMeasurementRenderQueued = false
  -- Activation always refreshes the provider catalog. Do not build a stale tree
  -- that the refresh will replace on the very next update.
  if (tonumber(state.pendingRefresh) or 0) <= 0 then
    self:renderCurrent()
  end
end

function Controller:deactivate(reason)
  local runtime = self.runtime
  local state = runtime.state
  local onClosed = state.onClosed

  self:restoreGameplaySettingsBackdrop()
  self:restoreStockButtonHints()
  runtime.screenView:removeRoot()
  if IsDefined(state.controller) then
    pcall(function()
      state.controller:McmUiSetCloseBlocked(false)
      state.controller:McmUiSetGameplayEntry(false)
    end)
  end
  if IsDefined(state.hiddenWrapper) then
    state.hiddenWrapper:SetVisible(true)
  end
  if state.api and state.api.closeMod then
    local ok, err = state.api.closeMod()
    if ok == false then
      runtime:logError("API close failed: " .. tostring(err))
    end
  end
  if state.api and type(state.api.unsubscribe) == "function" then
    for _, token in ipairs(state.apiSubscriptions) do
      state.api.unsubscribe(token)
    end
  end

  state.apiSubscriptions = {}
  state.modelSyncQueued = false
  state.active = false
  state.controller = nil
  state.gameplayEntry = false
  state.hiddenWrapper = nil
  state.hiddenSettingsBackdropWidgets = {}
  state.hiddenButtonHintsRoot = nil
  state.hiddenButtonHintsWasVisible = nil
  state.api = nil
  state.onClosed = nil
  state.renderQueued = false
  state.textMeasurementRenderQueued = false
  state.inputModalActive = false
  state.searchInputContext = nil
  state.searchPendingFrames = { sidebar = 0, content = 0 }
  state.searchDrafts = {
    sidebar = state.searchQueries and state.searchQueries.sidebar or "",
    content = state.searchQueries and state.searchQueries.content or "",
  }
  state.initialSetupStep = nil
  state.initialSetupDraft = nil
  state.suppressResetKeyRelease = false
  state.pendingConfirmation = nil
  state.installHealthNotices = {}

  if reason ~= nil then
    runtime:logError(reason)
  end
  if type(onClosed) == "function" then
    local ok, err = pcall(onClosed)
    if not ok then
      runtime:logError("close callback failed: " .. tostring(err))
    end
  end
end

function Controller:syncCloseGuard()
  local state = self.runtime.state
  if not IsDefined(state.controller) then
    return false
  end

  local model = self.runtime.model
  local blocked = model ~= nil
    and type(model.hasDrafts) == "function"
    and model:hasDrafts(state.selectedModKey)
  pcall(function()
    state.controller:McmUiSetCloseBlocked(blocked == true)
  end)
  return blocked == true
end

function Controller:handleClosing(beforeNativeClose)
  local runtime = self.runtime
  local state = runtime.state
  if not self:syncCloseGuard() then
    if type(beforeNativeClose) == "function" then
      beforeNativeClose()
    end
    return false
  end

  runtime.model:resolvePendingDrafts(function()
    local controller = state.controller
    if not IsDefined(controller) then
      runtime:setStatus(runtime:t("error.close_unavailable"), "error")
      runtime:queueRender()
      return
    end
    pcall(function()
      controller:McmUiSetCloseBlocked(false)
    end)
    if type(beforeNativeClose) == "function" then
      beforeNativeClose()
    end
    local ok, err = pcall(function()
      controller:RequestClose()
    end)
    if not ok then
      self:syncCloseGuard()
      runtime:setStatus(runtime:t("error.close_unavailable"), "error")
      runtime:logError("failed to resume native Settings close: " .. tostring(err))
      runtime:queueRender()
    end
  end)
  return true
end

function Controller:abort(reason)
  self:deactivate(reason or "Renderer aborted.")
end

function Controller:close()
  local runtime = self.runtime
  local state = runtime.state
  if
    not state.active
    and not IsDefined(state.hiddenWrapper)
    and #(state.hiddenSettingsBackdropWidgets or {}) == 0
  then
    return
  end

  self:deactivate(nil)
end

function Controller:isActive()
  return self.runtime.state.active
end

function Controller:isGameplayEntry()
  local state = self.runtime.state
  return state.active and state.gameplayEntry == true
end

function Controller:refreshIfQueued()
  local runtime = self.runtime
  local state = runtime.state
  if state.pendingRefresh <= 0 then
    return
  end

  state.pendingRefresh = state.pendingRefresh - 1
  if state.pendingRefresh > 0 then
    return
  end

  local ok, err = pcall(function()
    runtime.model:refreshIndex()
    -- refreshIndex has already copied the final catalog into UI state. The API
    -- emits index.changed while performing that same synchronous refresh, so
    -- consuming it here prevents an identical rebuild on the following frame.
    state.modelSyncQueued = false
  end)
  if not ok then
    local message = "Refresh failed: " .. tostring(err)
    runtime:setStatus(message, "error")
    runtime:logError(message)
  end
  state.renderQueued = true
end

function Controller:renderCurrent()
  local runtime = self.runtime
  local state = runtime.state
  local ok, err = pcall(function()
    runtime.screenView:render()
  end)
  if ok then
    self:syncCloseGuard()
    return true
  end

  local renderError = tostring(err)
  runtime:logError("Render failed: " .. renderError)
  if state.route ~= nil and state.route.view ~= "mods" then
    local recovered, recoveryError = pcall(function()
      runtime.screenView:removeRoot()
      Routes.go(state, "mods", {
        modKey = state.selectedModKey or state.rememberedModKey,
      })
      runtime.model:onRouteChanged()
      runtime:setStatus("The requested MCM screen could not be opened.", "error")
      runtime.screenView:render()
    end)
    if recovered then
      self:syncCloseGuard()
      return true
    end
    renderError = renderError .. "; recovery failed: " .. tostring(recoveryError)
  end

  self:abort("Render failed: " .. renderError)
  return false
end

function Controller:renderIfQueued()
  local runtime = self.runtime
  local state = runtime.state
  if not state.renderQueued then
    return
  end

  local measurementRender = state.textMeasurementRenderQueued == true
  if state.inputModalActive and not measurementRender then
    return
  end

  state.renderQueued = false
  state.textMeasurementRenderQueued = false
  self:renderCurrent()
end

function Controller:update()
  local runtime = self.runtime
  local state = runtime.state
  if not state.active then
    return
  end

  runtime.model:syncIfQueued()
  self:refreshIfQueued()
  if state.active then
    if type(runtime.screenView.updateModal) == "function" then
      runtime.screenView:updateModal()
    end
    if type(runtime.screenView.updateContentMeasurements) == "function" then
      runtime.screenView:updateContentMeasurements()
    end
    if type(runtime.screenView.updateSearch) == "function" then
      runtime.screenView:updateSearch()
    end
    self:renderIfQueued()
  end
end

function Controller:facade()
  local runtime = self.runtime
  return {
    activate = function(api, onClosed, context)
      return self:activate(api, onClosed, context)
    end,
    removeRestoreDefaultsHint = function(controller)
      return self:removeRestoreDefaultsHint(controller)
    end,
    onLocalizationChanged = function(controller)
      return self:onLocalizationChanged(controller)
    end,
    onTextMeasurementsReady = function()
      return self:onTextMeasurementsReady()
    end,
    onInitialize = function(controller)
      return self:onInitialize(controller)
    end,
    abort = function(reason)
      return self:abort(reason)
    end,
    close = function()
      return self:close()
    end,
    handleClosing = function(beforeNativeClose)
      return self:handleClosing(beforeNativeClose)
    end,
    isActive = function()
      return self:isActive()
    end,
    isGameplayEntry = function()
      return self:isGameplayEntry()
    end,
    getGameplayShortcut = function()
      return runtime.state.gameplayShortcut
    end,
    update = function()
      return self:update()
    end,
    handleKeyInput = function(key, action)
      return runtime.screenView:handleKeyInput(key, action)
    end,
    handleUiAction = function(id)
      return runtime.screenView:handleAction(id)
    end,
    handleUiStep = function(id, forward)
      return runtime.screenView:handleStep(id, forward)
    end,
    handleUiNumber = function(id, value)
      return runtime.screenView:handleNumber(id, value)
    end,
    handleUiKey = function(id, value)
      return runtime.screenView:handleKey(id, value)
    end,
    handleUiKeyListening = function(id, active)
      return runtime.screenView:handleKeyListening(id, active)
    end,
    handleUiHover = function(id, description, hovered)
      return runtime.screenView:handleHover(id, description, hovered)
    end,
    handleUiReset = function(id)
      return runtime.screenView:handleReset(id)
    end,
    handleUiText = function(context, value)
      return runtime.screenView:handleText(context, value)
    end,
    handleUiSearch = function(context, value)
      return runtime.screenView:handleSearch(context, value)
    end,
    handleUiSearchFocus = function(context, focused)
      return runtime.screenView:handleSearchFocus(context, focused)
    end,
  }
end

return Controller
