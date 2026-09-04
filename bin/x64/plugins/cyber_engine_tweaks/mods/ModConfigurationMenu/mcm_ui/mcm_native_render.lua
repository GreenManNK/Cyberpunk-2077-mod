local Input = require("mcm_ui/mcm_input_tags")
local ModList = require("mcm_ui/mcm_mod_list")
local Routes = require("mcm_ui/mcm_routes")
local CollectionsView = require("mcm_ui/views/mcm_collections_view")
local ModPresetsView = require("mcm_ui/views/mcm_presets_view")

local SurfaceRender = {}

-- Standard actions can join the interface only after a route, selection, or
-- confirmation changes. Resolve them during the transactional first paint so
-- a later screen never exposes the conservative fallback width for one frame.
local STANDARD_ACTION_KEYS = {
  "action.refresh",
  "action.mods",
  "action.presets",
  "action.collections",
  "action.settings",
  "action.back",
  "action.revert",
  "action.apply",
  "action.defaults",
  "action.confirm",
  "action.cancel",
  "action.ok",
  "action.on",
  "action.off",
  "action.create",
  "action.rename",
  "action.delete",
  "action.favorite_add",
  "action.favorite_remove",
  "presets.action.new",
  "presets.action.duplicate",
  "presets.update",
  "collections.action.new",
  "collections.quick_baseline",
  "collections.add_current",
  "collections.update_from_current",
  "collections.clean_missing",
  "collections.remove_entry",
  "collections.rollback",
  "collections.import",
  "collections.export",
  "collections.apply_compatible",
  "onboarding.apply_mode.staged",
  "onboarding.apply_mode.immediate",
  "onboarding.list_selection.frame",
  "onboarding.list_selection.text",
}

local function deferStartupModal(surface, state)
  if surface.startupModalReady then
    return false
  end
  if surface.startupModalDelay == nil then
    -- Give Ink two complete update passes to lay out and paint the ordinary
    -- MCM tree before attaching any automatic startup overlay.
    surface.startupModalDelay = 2
  end
  state.inputModalActive = false
  return true
end

function SurfaceRender.attach(RedscriptSurface, helpers)
  local customRenderScale = helpers.customRenderScale
  local customReservedHeight = helpers.customReservedHeight

  function RedscriptSurface:closeModal()
    local state = self.runtime.state
    self.textPrompt = nil
    self.pendingPromptOpen = nil
    self.pendingTextInputMount = nil
    state.inputModalActive = false
    if IsDefined(state.controller) then
      local ok, err = pcall(function()
        state.controller:McmUiHideModal()
      end)
      if not ok then
        self.runtime:logError("failed to hide modal: " .. tostring(err))
        return
      end
    end
  end

  function RedscriptSurface:openTextPrompt(options)
    options = options or {}
    self.textPrompt = {
      context = "mcm_text_prompt",
      title = self.runtime:safe(options.title),
      message = self.runtime:safe(options.message),
      placeholder = self.runtime:safe(options.placeholder),
      value = self.runtime:safe(options.value),
      confirmLabel = self.runtime:safe(options.confirmLabel or self.runtime:t("action.confirm")),
      kind = self.runtime:safe(options.kind or "input"),
      submit = options.submit,
    }
    self.pendingTextInputMount = nil
    self.pendingPromptOpen = 2
    self.runtime.state.inputModalActive = false
  end

  function RedscriptSurface:navigate(view)
    local runtime = self.runtime
    local state = runtime.state
    if state.route ~= nil and state.route.view == view then
      return
    end
    runtime.model:resolvePendingDrafts(function()
      self:closeModal()
      state.pendingConfirmation = nil
      local ok, err = Routes.go(state, view, {
        modKey = state.selectedModKey or state.rememberedModKey,
      })
      if not ok then
        runtime:setStatus(err, "error")
        return
      end

      runtime.model:onRouteChanged()
      runtime:queueRender()
    end)
  end

  function RedscriptSurface:topActions(controller)
    local runtime = self.runtime
    local state = runtime.state
    if state.activeOperationId ~= nil then
      return
    end
    local view = state.route.view
    for _, key in ipairs(STANDARD_ACTION_KEYS) do
      self:buttonWidth(runtime:t(key))
    end
    local presetsLabel = runtime:t("action.presets")
    local actions = {
      {
        label = runtime:t("action.refresh"),
        selected = false,
        callback = function()
          runtime.model:resolvePendingDrafts(function()
            runtime:setStatus(runtime:t("status.refresh_queued"))
            state.pendingRefresh = 1
            runtime:queueRender()
          end)
        end,
      },
      {
        label = runtime:t("action.mods"),
        selected = view == "mods",
        callback = function()
          self:navigate("mods")
        end,
      },
    }
    if state.selectedModKey ~= nil then
      actions[#actions + 1] = {
        label = presetsLabel,
        selected = view == "mod_presets",
        callback = function()
          self:navigate("mod_presets")
        end,
      }
    end
    actions[#actions + 1] = {
      label = runtime:t("action.collections"),
      selected = view == "collections",
      callback = function()
        self:navigate("collections")
      end,
    }
    actions[#actions + 1] = {
      label = runtime:t("action.settings"),
      selected = view == "settings",
      callback = function()
        self:navigate("settings")
      end,
    }

    local cursorX = runtime.layout.ACTION_RIGHT_X
    local y = runtime.layout.TOP_ACTION_Y
    local actionsPerRow = math.max(1, #actions)
    local availableWidth =
      math.max(1, runtime.layout.ACTION_RIGHT_X - runtime.layout.TOP_ACTION_MIN_X)
    local maximumWidth = math.max(
      1,
      (availableWidth - ((actionsPerRow - 1) * runtime.layout.ACTION_GAP)) / actionsPerRow
    )
    for index = #actions, 1, -1 do
      local action = actions[index]
      local width =
        math.min(self:buttonWidth(action.label), runtime.layout.TOP_ACTION_MAX_WIDTH, maximumWidth)
      cursorX = cursorX - width
      local id = self:bind("action", action.callback, nil, "")
      controller:McmUiAddTopAction(id, action.label, cursorX, y, width, action.selected == true)
      cursorX = cursorX - runtime.layout.ACTION_GAP
    end
  end

  function RedscriptSurface:sidebar(controller, heading, entries, scrollKey, showProvider)
    local runtime = self.runtime
    local state = runtime.state
    local textScrollModes = { off = 0, loop = 1, pingpong = 2 }
    local textScrollMode = textScrollModes[state.sidebarTextScrollMode] or 2
    local textScrollActivations = {
      always = 0,
      hover = 1,
      hover_selected = 2,
      selected = 3,
    }
    local textScrollActivation = textScrollActivations[state.sidebarTextScrollActivation] or 2
    local textScrollSpeeds = { slow = 0.25, normal = 0.5, fast = 0.75, very_fast = 1.0 }
    local textScrollSpeed = textScrollSpeeds[state.sidebarTextScrollSpeed] or 0.5
    self.sidebarScrollKey = scrollKey
    controller:McmUiBeginSidebar(
      math.max(
        runtime.layout.metrics.leftScrollH,
        (#entries * runtime.layout.metrics.leftRowH) + 20
      ),
      tonumber(state.scrollPositions[scrollKey]) or 0
    )

    for _, entry in ipairs(entries) do
      local id = self:bind("sidebar", entry.callback, nil, entry.description)
      local favoriteId = ""
      if entry.favoriteVisible == true and type(entry.favoriteCallback) == "function" then
        favoriteId = self:bind("favorite", entry.favoriteCallback, nil, entry.favoriteDescription)
      end
      controller:McmUiAddSidebarItem(
        id,
        runtime:safe(entry.provider),
        runtime:safe(entry.label),
        runtime:safe(entry.description),
        entry.selected == true,
        showProvider == true,
        entry.favoriteVisible == true,
        entry.favoriteActive == true,
        entry.favoriteHighlight == true,
        favoriteId,
        runtime:safe(entry.favoriteDescription),
        textScrollMode,
        textScrollActivation,
        textScrollSpeed
      )
    end
  end

  function RedscriptSurface:addMessageRow(controller, value, rowKey)
    local message = self.runtime:safe(value)
    controller:McmUiAddMessage(self:bind("none"), message, self:messageRowHeight(message))
  end

  function RedscriptSurface:addSettingRow(controller, item, rowKey)
    local runtime = self.runtime
    if item.kind == "category" then
      local description = runtime:safe(item.description or item.label)
      local id = self:bind("hover", nil, nil, description)
      controller:McmUiAddCategory(
        id,
        runtime:safe(item.label),
        description,
        runtime:safe(item.frameworkId)
      )
      return
    end
    if item.kind == "message" then
      self:addMessageRow(controller, item.label, rowKey)
      return
    end
    if item.kind == "preview" then
      controller:McmUiAddPreview(
        self:bind("none"),
        runtime:safe(item.label),
        runtime:safe(item.currentValue),
        runtime:safe(item.targetValue),
        runtime:safe(item.status),
        item.nested == true
      )
      return
    end
    if item.kind == "collection_entry" then
      local entry = item.entry or {}
      local count = #(entry.settings or {})
      local summary = runtime:t("collections.entry_summary", {
        provider = runtime:safe(entry.providerId),
        count = count,
      })
      controller:McmUiAddCollectionEntry(
        self:bind("action", item.callback, nil, summary),
        runtime:safe(entry.sourceModName or entry.sourceModKey),
        summary,
        item.selected == true,
        false
      )
      return
    end
    if item.kind == "portable_entry" then
      controller:McmUiAddCollectionEntry(
        self:bind("none", nil, nil, item.description),
        runtime:safe(item.label),
        runtime:safe(item.description),
        false,
        true
      )
      return
    end

    local setting = item.setting
    if setting == nil then
      self:addMessageRow(controller, runtime:t("error.invalid_row"), rowKey)
      return
    end

    local value = runtime.model:getSettingValue(setting)
    local display = runtime.model:settingDisplay(setting)
    local description =
      runtime:safe(setting.description or setting.unsupportedReason or setting.key or setting.label)
    local id = self:bind("setting", nil, setting, description)

    if
      setting.type == "custom"
      and setting.supported
      and setting.capabilities ~= nil
      and setting.capabilities.customRender == true
    then
      local renderScale = customRenderScale(setting)
      local height = tonumber(runtime.state.customHeights[setting.id])
        or customReservedHeight(runtime, setting)
      local host = controller:McmUiAddCustom(id, height, renderScale)
      local api = runtime.state.api
      local ok, err = false, "MCM API custom renderer is unavailable."
      if api ~= nil and type(api.mountCustom) == "function" and IsDefined(host) then
        ok, err = api.mountCustom(setting.id, host)
      end
      if ok == true then
        local compact = false
        pcall(function()
          compact = controller:McmUiIsCompactCustom(host) == true
        end)
        self.pendingCustomMeasurements[#self.pendingCustomMeasurements + 1] = {
          settingId = setting.id,
          host = host,
          renderScale = renderScale,
          compact = compact,
          fallbackHeight = height,
        }
        self.contentMeasurementDelay = math.max(self.contentMeasurementDelay, 2)
      else
        if runtime.state.customHeights[setting.id] == nil then
          runtime.state.customHeights[setting.id] = height
          runtime:queueRender()
        end
        runtime:setStatus("Custom content failed: " .. runtime:safe(err), "error")
        runtime:logError(
          "custom content mount failed for "
            .. runtime:safe(setting.id)
            .. ": "
            .. runtime:safe(err)
        )
      end
      return
    end

    if setting.supported and setting.type == "bool" then
      controller:McmUiAddBool(
        id,
        display.label,
        description,
        value == true,
        display.marker or "",
        display.highlighted == true
      )
      return
    end
    if setting.supported and setting.type == "select" then
      controller:McmUiBeginSelect(
        id,
        display.label,
        description,
        math.max(0, (tonumber(value) or 1) - 1),
        display.marker or "",
        display.highlighted == true
      )
      for _, option in ipairs(setting.elements or {}) do
        controller:McmUiAddSelectOption(runtime:safe(option))
      end
      controller:McmUiEndSelect()
      return
    end
    if setting.supported and setting.type == "int" then
      controller:McmUiAddInt(
        id,
        display.label,
        description,
        math.floor(tonumber(value) or 0),
        math.floor(tonumber(setting.min) or 0),
        math.floor(tonumber(setting.max) or 100),
        math.max(1, math.floor(tonumber(setting.step) or 1)),
        display.marker or "",
        display.highlighted == true
      )
      return
    end
    if setting.supported and setting.type == "float" then
      controller:McmUiAddFloat(
        id,
        display.label,
        description,
        tonumber(value) or 0,
        tonumber(setting.min) or 0,
        tonumber(setting.max) or 100,
        tonumber(setting.step) or 0.1,
        runtime.text.floatPrecision(setting.format, setting.step),
        display.marker or "",
        display.highlighted == true
      )
      return
    end
    if setting.supported and setting.type == "key" then
      controller:McmUiAddKey(
        id,
        display.label,
        description,
        Input.keyInputTag(value, setting.isHold),
        display.marker or "",
        display.highlighted == true
      )
      return
    end
    if setting.supported and setting.type == "action" then
      local actionId = self:bind("action", function()
        runtime.model:invokeAction(setting)
      end, setting, description)
      controller:McmUiAddActionSetting(
        actionId,
        display.label,
        description,
        runtime:safe(setting.value)
      )
      return
    end

    controller:McmUiAddReadonly(
      id,
      display.label,
      description,
      runtime.model:valueLabel(setting, value)
    )
  end

  function RedscriptSurface:content(controller, rows, scrollKey)
    local runtime = self.runtime
    local state = runtime.state
    self.contentScrollKey = scrollKey
    local contentHeight = 20
    local contentReady = true
    for index, row in ipairs(rows) do
      local rowKey =
        table.concat({ scrollKey, tostring(index), runtime:safe(row.label or row.kind) }, ":")
      local rowHeight = self:contentRowHeight(row, rowKey)
      contentHeight = contentHeight + math.max(1, rowHeight)
      local setting = row.kind == "setting" and row.setting or nil
      if
        setting ~= nil
        and setting.type == "custom"
        and setting.supported == true
        and setting.capabilities ~= nil
        and setting.capabilities.customRender == true
        and state.customHeights[setting.id] == nil
      then
        contentReady = false
      end
    end

    controller:McmUiBeginContent(
      math.max(runtime.layout.metrics.settingsScrollH, contentHeight),
      tonumber(state.scrollPositions[scrollKey]) or 0,
      contentReady
    )
    for index, row in ipairs(rows) do
      local rowKey =
        table.concat({ scrollKey, tostring(index), runtime:safe(row.label or row.kind) }, ":")
      self:addSettingRow(controller, row, rowKey)
    end
  end

  function RedscriptSurface:renderActionRows(controller, actions)
    local runtime = self.runtime
    local cursorX = runtime.layout.CONTENT_ACTION_RIGHT_X
    local y = runtime.layout.metrics.bottomActionY
    local minimumX = runtime.layout.metrics.settingsX
    local visibleCount = 0
    for _, action in ipairs(actions) do
      if action.visible ~= false then
        visibleCount = visibleCount + 1
      end
    end
    local availableWidth = runtime.layout.CONTENT_ACTION_RIGHT_X - minimumX
    local maximumWidth = visibleCount > 0
        and (math.max(1, availableWidth - ((visibleCount - 1) * runtime.layout.ACTION_GAP)) / visibleCount)
      or availableWidth

    for index = #actions, 1, -1 do
      local action = actions[index]
      if action.visible ~= false then
        local width = math.min(self:buttonWidth(action.label), maximumWidth)
        cursorX = cursorX - width
        local id =
          self:bind("action", action.callback, nil, "", action.allowDuringOperation == true)
        controller:McmUiAddBottomActionAt(
          id,
          action.label,
          cursorX,
          y,
          width,
          action.active == true
        )
        cursorX = cursorX - runtime.layout.ACTION_GAP
      end
    end
  end

  function RedscriptSurface:renderActionGroups(controller, groups)
    local actions = {}
    for _, group in ipairs(groups) do
      for _, action in ipairs(group) do
        actions[#actions + 1] = action
      end
    end
    self:renderActionRows(controller, actions)
  end

  function RedscriptSurface:renderSidebarActionGrid(controller, rows)
    local runtime = self.runtime
    local gap = runtime.layout.ACTION_GAP
    local columns = 2
    local width = (runtime.layout.SIDEBAR_ACTION_WIDTH - gap) / columns
    local rowCount = #rows

    for rowIndex, actions in ipairs(rows) do
      local y = runtime.layout.metrics.bottomActionY
        - ((rowCount - rowIndex) * runtime.layout.BOTTOM_ACTION_ROW_STEP)
      for column = 1, columns do
        local action = actions[column]
        if action ~= nil and action.visible ~= false then
          local x = runtime.layout.SIDEBAR_ACTION_X + ((column - 1) * (width + gap))
          controller:McmUiAddBottomActionAt(
            self:bind("action", action.callback, nil, "", action.allowDuringOperation == true),
            action.label,
            x,
            y,
            width,
            action.active == true
          )
        end
      end
    end
  end

  function RedscriptSurface:bottomActions(controller, mod)
    if mod == nil then
      return
    end

    local runtime = self.runtime
    local actions = {}
    local hasDrafts = runtime.model:hasDrafts(mod.key)
    local coverage = runtime.model:getDefaultCoverage(mod.key)
    local resettable = type(coverage) == "table"
        and (coverage.resettableNonDefault or coverage.nonDefault)
      or 0
    local modifiedCount, comparableCount = runtime.model:modifiedSettingCount(mod)

    if hasDrafts then
      actions[#actions + 1] = {
        label = runtime:t("action.revert"),
        callback = function()
          runtime.model:revert(mod.key)
        end,
        active = false,
      }
      actions[#actions + 1] = {
        label = runtime:t("action.apply"),
        callback = function()
          runtime.model:apply(mod.key)
        end,
        active = true,
      }
    end
    if (tonumber(resettable) or 0) > 0 then
      actions[#actions + 1] = {
        label = runtime:t("action.defaults"),
        callback = function()
          runtime.model:setModToDefaults(mod.key)
        end,
        active = false,
      }
    end
    if runtime.model:favoriteButtonVisible() then
      local isFavorite = runtime.model:isFavorite(mod.key)
      actions[#actions + 1] = {
        label = runtime:t(isFavorite and "action.favorite_remove" or "action.favorite_add"),
        callback = function()
          runtime.model:toggleFavorite(mod.key)
        end,
        active = isFavorite,
      }
    end
    if comparableCount > 0 then
      actions[#actions + 1] = {
        label = runtime:t(
          runtime.state.modifiedOnly and "action.show_all" or "action.modified_only",
          { count = modifiedCount }
        ),
        callback = function()
          runtime.model:toggleModifiedOnly()
        end,
        active = runtime.state.modifiedOnly,
      }
    end

    self:renderActionRows(controller, actions)
  end

  function RedscriptSurface:renderMods(controller)
    local runtime = self.runtime
    local state = runtime.state
    local visibleMods = runtime.model:filteredMods()
    local entries = {}
    local showFavoriteStars = runtime.model:favoriteStarsVisible()
    local highlightFavoriteNames = runtime.model:favoriteNamesHighlighted()
    for _, mod in ipairs(visibleMods) do
      local isFavorite = runtime.model:isFavorite(mod.key)
      entries[#entries + 1] = {
        provider = ModList.providerPrefix(mod),
        label = mod.name,
        description = runtime.model:modHoverDescription(mod),
        selected = mod.key == state.selectedModKey,
        callback = function()
          runtime.model:selectMod(mod)
        end,
        favoriteVisible = showFavoriteStars,
        favoriteActive = isFavorite,
        favoriteHighlight = isFavorite and highlightFavoriteNames,
        favoriteDescription = runtime:t(
          isFavorite and "favorite.remove_description" or "favorite.add_description",
          { mod = runtime:safe(mod.name) }
        ),
        favoriteCallback = function()
          runtime.model:toggleFavorite(mod.key)
        end,
      }
    end
    self:sidebar(
      controller,
      runtime:t("sidebar.mods"),
      entries,
      "mods_scroll",
      state.showModProviderPrefix
    )

    local mod = runtime.model:selectedMod()
    if mod == nil then
      self.baseDescription = #visibleMods == 0 and runtime:t("empty.no_matches")
        or runtime:t("empty.select")
      self:content(controller, {}, "settings_scroll")
      return runtime:t("empty.title"), nil
    end

    self.baseDescription = runtime:safe(mod.description)
    local capabilities = mod.capabilities or {}
    controller:McmUiSetFrameworkContext(
      runtime:safe(capabilities.uiExtensionSurface),
      runtime:safe(mod.id),
      runtime:safe(mod.name)
    )
    local rows = runtime.model:flattenSettings(mod)
    if #rows == 0 then
      rows = {
        {
          kind = "message",
          label = state.searchQueries ~= nil and state.searchQueries.content ~= "" and runtime:t(
            "empty.settings_no_matches"
          ) or runtime:t("empty.settings_unavailable"),
        },
      }
    end
    self:content(controller, rows, "settings_scroll")
    self:bottomActions(controller, mod)
    return runtime:safe(mod.name), mod
  end

  function RedscriptSurface:renderSettings(controller)
    local runtime = self.runtime
    local state = runtime.state
    local categories = runtime.model:mcmSettingsCategories()
    local selectedCategory = nil
    for _, category in ipairs(categories) do
      if category.key == state.settingsCategory then
        selectedCategory = category
        break
      end
    end
    if selectedCategory == nil then
      selectedCategory = categories[1]
      state.settingsCategory = selectedCategory and selectedCategory.key or "general"
    end

    local entries = {}
    for _, category in ipairs(categories) do
      local categoryKey = category.key
      entries[#entries + 1] = {
        provider = "",
        label = category.label,
        description = category.description,
        selected = categoryKey == state.settingsCategory,
        callback = function()
          state.settingsCategory = categoryKey
          state.scrollPositions.ui_settings_scroll = 0
          runtime:queueRender()
        end,
      }
    end
    self:sidebar(controller, runtime:t("sidebar.categories"), entries, "category_scroll", false)
    self.baseDescription = selectedCategory and selectedCategory.description or ""
    self:content(controller, runtime.model:mcmSettingsRows(), "ui_settings_scroll")
    if
      selectedCategory ~= nil
      and runtime.model:mcmSettingsCategoryHasNonDefaults(selectedCategory.key)
    then
      local categoryKey = selectedCategory.key
      self:renderActionRows(controller, {
        {
          label = runtime:t("action.defaults"),
          callback = function()
            runtime.model:setMcmSettingsCategoryToDefaults(categoryKey)
          end,
          active = false,
        },
      })
    end
    return selectedCategory and selectedCategory.label or runtime:t("common.general"), nil
  end

  function RedscriptSurface:renderModal(controller)
    local runtime = self.runtime
    local state = runtime.state
    local confirmation = state.pendingConfirmation
    local initialSetup = type(runtime.model.initialSetupPrompt) == "function"
        and runtime.model:initialSetupPrompt()
      or nil
    if initialSetup ~= nil then
      if deferStartupModal(self, state) then
        return
      end
      -- The full MCM tree has already been finalized and presented before this
      -- overlay is mounted. Its callbacks only unlock the next queued render;
      -- they do not detach the emitting Ink action while its native OnRelease
      -- stack is active.
      local function deferInitialSetupModalTeardown()
        self.textPrompt = nil
        self.pendingPromptOpen = nil
        self.pendingTextInputMount = nil
        state.inputModalActive = false
      end
      local escapeId = self:bind("action", function()
        deferInitialSetupModalTeardown()
        runtime.model:cancelInitialSetup()
      end)
      local secondaryId = self:bind("action", function()
        deferInitialSetupModalTeardown()
        runtime.model:chooseInitialSetup(false)
      end)
      local primaryId = self:bind("action", function()
        deferInitialSetupModalTeardown()
        runtime.model:chooseInitialSetup(true)
      end)
      controller:McmUiShowModal(
        initialSetup.title,
        initialSetup.message,
        self:modalMessageHeight(initialSetup.message),
        false,
        initialSetup.kind
      )
      controller:McmUiSetChoiceModalActions(
        primaryId,
        initialSetup.primaryLabel,
        self:buttonWidth(initialSetup.primaryLabel),
        secondaryId,
        initialSetup.secondaryLabel,
        self:buttonWidth(initialSetup.secondaryLabel),
        escapeId
      )
      state.inputModalActive = true
      return
    end
    local installHealthNotice = type(state.installHealthNotices) == "table"
        and state.installHealthNotices[1]
      or nil
    if installHealthNotice ~= nil then
      if deferStartupModal(self, state) then
        return
      end
      local dismissId = self:bind("action", function()
        state.inputModalActive = false
        table.remove(state.installHealthNotices, 1)
        runtime:queueRender()
      end)
      local message = runtime:t(installHealthNotice.messageKey, installHealthNotice.values)
      controller:McmUiShowModal(
        runtime:t("app.title"),
        message,
        self:modalMessageHeight(message),
        false,
        "warning"
      )
      controller:McmUiSetNoticeModalAction(
        dismissId,
        runtime:t("action.ok"),
        self:buttonWidth(runtime:t("action.ok"))
      )
      state.inputModalActive = true
      return
    end
    self.startupModalDelay = nil
    self.startupModalReady = false
    if self.textPrompt ~= nil then
      local prompt = self.textPrompt
      local cancelId = self:bind("action", function()
        self:closeModal()
        runtime:queueRender()
      end)
      local confirmId = self:bind("action", function()
        local value = prompt.value
        if IsDefined(controller) then
          local ok, currentValue = pcall(function()
            return controller:McmUiGetTextInputText()
          end)
          if ok and currentValue ~= nil then
            value = runtime:safe(currentValue)
          elseif not ok then
            runtime:logError("failed to read modal text input: " .. tostring(currentValue))
          end
        end
        local submit = prompt.submit
        self:closeModal()
        if type(submit) == "function" then
          submit(value)
        end
        runtime:queueRender()
      end)
      controller:McmUiShowModal(
        prompt.title,
        prompt.message,
        self:modalMessageHeight(prompt.message),
        true,
        prompt.kind
      )
      controller:McmUiSetModalActions(
        confirmId,
        prompt.confirmLabel,
        self:buttonWidth(prompt.confirmLabel),
        cancelId,
        runtime:t("action.cancel"),
        self:buttonWidth(runtime:t("action.cancel"))
      )
      self.pendingTextInputMount = {
        prompt = prompt,
        frames = 2,
      }
      state.inputModalActive = true
      return
    end
    if confirmation ~= nil then
      local cancelId = self:bind("action", function()
        state.inputModalActive = false
        runtime.model:cancelPendingAction()
      end)
      local confirmId = self:bind("action", function()
        state.inputModalActive = false
        runtime.model:confirmPendingAction()
      end)
      local secondaryId = nil
      if type(confirmation.secondaryCallback) == "function" then
        secondaryId = self:bind("action", function()
          state.inputModalActive = false
          runtime.model:runPendingSecondaryAction()
        end)
      end
      local confirmationMessage = runtime:safe(confirmation.message)
      local confirmationTitle = runtime:safe(confirmation.title or runtime:t("action.confirm"))
      local confirmationLabel =
        runtime:safe(confirmation.confirmLabel or runtime:t("action.confirm"))
      controller:McmUiShowModal(
        confirmationTitle,
        confirmationMessage,
        self:modalMessageHeight(confirmationMessage),
        false,
        runtime:safe(confirmation.kind or "warning")
      )
      if secondaryId ~= nil then
        local secondaryLabel = runtime:safe(confirmation.secondaryLabel)
        controller:McmUiSetChoiceModalActions(
          confirmId,
          confirmationLabel,
          self:buttonWidth(confirmationLabel),
          secondaryId,
          secondaryLabel,
          self:buttonWidth(secondaryLabel),
          cancelId
        )
      else
        controller:McmUiSetModalActions(
          confirmId,
          confirmationLabel,
          self:buttonWidth(confirmationLabel),
          cancelId,
          runtime:t("action.cancel"),
          self:buttonWidth(runtime:t("action.cancel"))
        )
      end
      state.inputModalActive = true
      return
    end
    state.inputModalActive = false
  end

  function RedscriptSurface:updateModal()
    if self.startupModalDelay ~= nil then
      self.startupModalDelay = self.startupModalDelay - 1
      if self.startupModalDelay <= 0 then
        self.startupModalDelay = nil
        self.startupModalReady = true
        self.runtime:queueRender()
      end
      return
    end

    if self.pendingPromptOpen ~= nil then
      self.pendingPromptOpen = self.pendingPromptOpen - 1
      if self.pendingPromptOpen <= 0 then
        self.pendingPromptOpen = nil
        self.runtime:queueRender()
      end
      return
    end

    local pending = self.pendingTextInputMount
    if pending == nil then
      return
    end

    local state = self.runtime.state
    if
      not state.active
      or not state.inputModalActive
      or self.textPrompt == nil
      or self.textPrompt ~= pending.prompt
    then
      self.pendingTextInputMount = nil
      return
    end

    pending.frames = pending.frames - 1
    if pending.frames > 0 then
      return
    end

    local controller = state.controller
    if not IsDefined(controller) then
      self.pendingTextInputMount = nil
      self.runtime:setStatus("MCM text input controller is unavailable.", "error")
      self.runtime:logError("text input controller is unavailable.")
      return
    end

    local ok, err = pcall(function()
      controller:McmUiShowModalTextInput(pending.prompt.placeholder, pending.prompt.value)
    end)
    self.pendingTextInputMount = nil
    if not ok then
      self.runtime:setStatus("MCM text input could not be created.", "error")
      self.runtime:logError("failed to mount modal text input: " .. tostring(err))
      self:closeModal()
      self.runtime:queueRender()
      return
    end
  end

  function RedscriptSurface:render()
    local runtime = self.runtime
    local state = runtime.state
    local controller = state.controller
    if not state.active or not IsDefined(controller) then
      return
    end

    self:prepareScrollCapture()
    self:clearBindings()
    self.pendingCustomMeasurements = {}
    self.contentMeasurementDelay = 0
    runtime.layout.applyProfile(state.route.view, {
      description = state.showDescriptionPanel,
    })

    local host = controller:GetRootCompoundWidget()
    if not IsDefined(host) then
      error("Settings screen root is unavailable.")
    end
    local hostLayout = runtime:updateViewport(host)
    if IsDefined(state.hiddenWrapper) then
      state.hiddenWrapper:SetVisible(false)
    end

    local theme = state.themeColors
    controller:McmUiSetThemeColors(
      theme.background,
      theme.panel,
      theme.panelSelected,
      theme.primary,
      theme.secondary,
      theme.success,
      theme.modified,
      theme.favorite,
      theme.text,
      theme.muted
    )

    local contentTitle = state.route.view == "settings" and runtime:t("common.general")
      or runtime:t("empty.title")
    local sidebarTitle = state.route.view == "settings" and runtime:t("sidebar.categories")
      or (
        state.route.view == "mod_presets" and runtime:t("sidebar.presets")
        or (
          state.route.view == "collections" and runtime:t("sidebar.collections")
          or runtime:t("sidebar.mods")
        )
      )
    local statusKind = state.statusKind == "success" and 1
      or (state.statusKind == "error" and 2 or 0)
    local transientOwner = state.route.view == "mods" and self.runtime:safe(state.selectedModKey)
      or ""
    local showSearch = state.route.view == "mods"
    local showContentSearch = showSearch and runtime.model:selectedMod() ~= nil
    if not showSearch then
      state.searchInputContext = nil
    elseif not showContentSearch and state.searchInputContext == "content" then
      state.searchInputContext = nil
      state.searchPendingFrames.content = 0
      state.searchDrafts.content = state.searchQueries.content
    end

    controller:McmUiSetHostViewport(
      hostLayout.width,
      hostLayout.height,
      hostLayout.safeLeft,
      hostLayout.safeTop,
      hostLayout.safeRight,
      hostLayout.safeBottom
    )
    controller:McmUiConfigureLayout(
      hostLayout.density,
      hostLayout.requestedScale,
      hostLayout.requestedProfileCode,
      runtime.layout.currentProfile.description == true,
      tonumber(runtime.layout.currentProfile.bottomActionRows) or 1,
      tonumber(runtime.layout.currentProfile.sidebarActionRows) or 0
    )
    controller:McmUiBegin(
      runtime:t("app.title"),
      runtime:t("app.subtitle"),
      sidebarTitle,
      contentTitle,
      runtime:safe(state.status),
      statusKind,
      transientOwner,
      showSearch,
      showContentSearch,
      state.listSelectionMode == "text" and 1 or 0
    )
    if not runtime:syncResolvedLayout(controller) then
      error("native layout snapshot metric contract is unavailable")
    end
    if showSearch then
      local drafts = state.searchDrafts or state.searchQueries or { sidebar = "", content = "" }
      controller:McmUiShowSearchInputs(
        runtime:t("search.mods"),
        runtime:safe(drafts.sidebar),
        runtime:t("search.settings"),
        runtime:safe(drafts.content),
        showContentSearch,
        runtime:safe(state.searchInputContext)
      )
    else
      controller:McmUiHideSearchInputs()
    end
    self:topActions(controller)

    if state.route.view == "settings" then
      contentTitle = self:renderSettings(controller)
    elseif state.route.view == "mod_presets" then
      contentTitle = ModPresetsView.render(self, controller)
    elseif state.route.view == "collections" then
      contentTitle = CollectionsView.render(self, controller)
    else
      contentTitle = self:renderMods(controller)
    end

    -- McmUiBegin creates the title before lazy mod data is opened. Rebuilding here would
    -- throw away the controls, so the redscript side exposes a narrow title update.
    controller:McmUiSetContentTitle(runtime:safe(contentTitle))
    if runtime.layout.currentProfile.description == true then
      controller:McmUiSetDescription(
        runtime:descriptionText(self.baseDescription),
        self:descriptionHeight(),
        0
      )
    end
    controller:McmUiFinalizeFrameworkContext()
    self:renderModal(controller)
    local measurementOk, measurementError = pcall(function()
      controller:McmUiFinalizeTextMeasurements()
    end)
    if not measurementOk and type(runtime.logError) == "function" then
      runtime:logError(
        "native text measurement finalization failed: " .. tostring(measurementError)
      )
    end
  end
end

return SurfaceRender
