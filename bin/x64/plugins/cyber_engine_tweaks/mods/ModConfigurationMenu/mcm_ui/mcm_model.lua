local LocalSettings = require("mcm_ui/mcm_settings_schema")
local Host = require("mcm_ui/mcm_host")
local ModList = require("mcm_ui/mcm_mod_list")
local Routes = require("mcm_ui/mcm_routes")
local Text = require("mcm_ui/mcm_text")
local Theme = require("mcm_ui/mcm_theme")

local Model = {}
Model.__index = Model

local INITIAL_SETUP_VERSION = 3

local function findMod(mods, modKey)
  if modKey == nil then
    return nil
  end

  for _, mod in ipairs(mods or {}) do
    if mod.key == modKey then
      return mod
    end
  end

  return nil
end

local function clampScrollPosition(value)
  return math.max(0, math.min(1, tonumber(value) or 0))
end

local function rememberModSettingsScroll(state, modKey)
  modKey = modKey or state.selectedModKey
  if modKey == nil then
    return
  end

  state.modSettingsScrollPositions = state.modSettingsScrollPositions or {}
  state.modSettingsScrollPositions[modKey] =
    clampScrollPosition(state.scrollPositions and state.scrollPositions.settings_scroll)
end

local function restoreModSettingsScroll(state, modKey)
  state.scrollPositions = state.scrollPositions or {}
  state.modSettingsScrollPositions = state.modSettingsScrollPositions or {}
  state.scrollPositions.settings_scroll =
    clampScrollPosition(state.modSettingsScrollPositions[modKey])
end

function Model.new(runtime)
  return setmetatable({ runtime = runtime }, Model)
end

function Model:modHoverDescription(mod)
  return ModList.hoverDescription(mod)
end

function Model:modSortLabel()
  return ModList.sortLabel(self.runtime.state.modSortMode)
end

function Model:settingsSortLabel()
  local runtime = self.runtime
  if runtime.state.settingsSortMode == "file" then
    return runtime:t("common.original")
  end

  return ModList.settingsSortLabel(runtime.state.settingsSortMode)
end

function Model:defaultIndicatorElements()
  local runtime = self.runtime
  return { runtime:t("common.off"), "*", runtime:t("settings.default_indicator.colored") }
end

function Model:defaultIndicatorIndex()
  local mode = self.runtime.state.defaultIndicatorMode
  if mode == "off" then
    return 1
  end
  if mode == "asterisk" then
    return 2
  end

  return 3
end

function Model:setDefaultIndicatorIndex(value)
  local runtime = self.runtime
  local state = runtime.state
  local index = tonumber(value) or 3
  if index == 1 then
    state.defaultIndicatorMode = "off"
  elseif index == 2 then
    state.defaultIndicatorMode = "asterisk"
  else
    state.defaultIndicatorMode = "colored"
    index = 3
  end

  local elements = self:defaultIndicatorElements()
  runtime:setStatus(runtime:t("status.default_indicator", { value = elements[index] }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:listSelectionElements()
  local runtime = self.runtime
  return {
    runtime:t("settings.list_selection.frame"),
    runtime:t("settings.list_selection.text"),
  }
end

function Model:listSelectionIndex()
  return self.runtime.state.listSelectionMode == "text" and 2 or 1
end

function Model:setListSelectionIndex(value)
  local runtime = self.runtime
  local index = math.max(1, math.min(2, math.floor(tonumber(value) or 2)))
  runtime.state.listSelectionMode = index == 2 and "text" or "frame"
  runtime:setStatus(runtime:t("status.list_selection", {
    value = self:listSelectionElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:layoutProfileElements()
  local runtime = self.runtime
  return {
    runtime:t("settings.layout_profile.auto"),
    runtime:t("settings.layout_profile.full"),
    runtime:t("settings.layout_profile.medium"),
    runtime:t("settings.layout_profile.compact"),
  }
end

function Model:layoutProfileIndex()
  return Host.profileIndex(self.runtime.state.layoutProfile)
end

function Model:setLayoutProfileIndex(value)
  local runtime = self.runtime
  local index = math.max(1, math.min(4, math.floor(tonumber(value) or 1)))
  runtime.state.layoutProfile = Host.profileAt(index)
  runtime:setStatus(runtime:t("status.layout_profile", {
    value = self:layoutProfileElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender("layout profile changed")
end

function Model:uiScaleElements()
  local result = {}
  for index, value in ipairs(Host.SCALE_VALUES) do
    result[index] = string.format("%d%%", math.floor((value * 100) + 0.5))
  end
  return result
end

function Model:uiScaleIndex()
  return Host.scaleIndex(self.runtime.state.uiScale)
end

function Model:setUiScaleIndex(value)
  local runtime = self.runtime
  local index =
    math.max(1, math.min(#Host.SCALE_VALUES, math.floor(tonumber(value) or Host.scaleIndex(1.0))))
  runtime.state.uiScale = Host.scaleAt(index)
  runtime:setStatus(runtime:t("status.ui_scale", { value = self:uiScaleElements()[index] }))
  self:persistPreferences()
  runtime:queueRender("UI scale changed")
end

function Model:themeColorElements()
  return Theme.elements()
end

function Model:themeColorIndex(roleKey)
  local role = Theme.role(roleKey)
  if role == nil then
    return 1
  end

  local value = self.runtime.state.themeColors[roleKey]
  return Theme.indexOf(value) or Theme.indexOf(role.default) or 1
end

function Model:setThemeColorIndex(roleKey, value)
  local runtime = self.runtime
  local state = runtime.state
  local role = Theme.role(roleKey)
  if role == nil then
    return
  end

  local index = math.max(1, math.min(#Theme.PALETTE, math.floor(tonumber(value) or 1)))
  local colorKey = Theme.keyAt(index)
  state.themeColors[roleKey] = colorKey
  runtime:setStatus(runtime:t("status.theme_color", {
    role = runtime:t(role.labelKey),
    color = self:themeColorElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:persistPreferences()
  local runtime = self.runtime
  local state = runtime.state
  local ok, err = runtime.preferences.save({
    initialSetupVersion = state.initialSetupVersion,
    menuEntryLabel = state.menuEntryLabel,
    gameplayShortcut = state.gameplayShortcut,
    redirectFrameworkMenuEntries = state.redirectFrameworkMenuEntries,
    providerFilter = state.providerFilter,
    showModProviderPrefix = state.showModProviderPrefix,
    listSelectionMode = state.listSelectionMode,
    modSortMode = state.modSortMode,
    modSortWithProvider = state.modSortWithProvider,
    sidebarTextScrollMode = state.sidebarTextScrollMode,
    sidebarTextScrollActivation = state.sidebarTextScrollActivation,
    sidebarTextScrollSpeed = state.sidebarTextScrollSpeed,
    favoriteUxMode = state.favoriteUxMode,
    favoriteModKeys = state.favoriteModKeys,
    settingsSortMode = state.settingsSortMode,
    defaultIndicatorMode = state.defaultIndicatorMode,
    presetNonDefaultOnly = state.presetNonDefaultOnly,
    showDescriptionPanel = state.showDescriptionPanel,
    layoutProfile = state.layoutProfile,
    uiScale = state.uiScale,
    autoApply = state.autoApply,
    themeColors = state.themeColors,
  })
  if not ok then
    runtime:logError("failed to save renderer preferences: " .. tostring(err))
  end
end

function Model:beginInitialSetup()
  local state = self.runtime.state
  if (tonumber(state.initialSetupVersion) or 0) >= INITIAL_SETUP_VERSION then
    state.initialSetupStep = nil
    state.initialSetupDraft = nil
    return false
  end

  local setupVersion = tonumber(state.initialSetupVersion) or 0
  if setupVersion >= 2 then
    state.initialSetupStep = 5
  elseif setupVersion >= 1 then
    state.initialSetupStep = 4
  else
    state.initialSetupStep = 1
  end
  state.initialSetupDraft = {
    showModProviderPrefix = state.showModProviderPrefix ~= false,
    favoriteUxMode = state.favoriteUxMode or "both",
    autoApply = state.autoApply == true,
    sidebarTextScrollMode = state.sidebarTextScrollMode or "pingpong",
    listSelectionMode = state.listSelectionMode == "frame" and "frame" or "text",
  }
  return true
end

function Model:initialSetupPrompt()
  local runtime = self.runtime
  local step = tonumber(runtime.state.initialSetupStep)
  if step == nil or step < 1 or step > 5 then
    return nil
  end

  local prompt = {
    title = runtime:t("onboarding.title", { step = step, total = 5 }),
    kind = "setup",
  }
  if step == 1 then
    prompt.message = runtime:t("onboarding.prefixes.message")
    prompt.primaryLabel = runtime:t("action.on")
    prompt.secondaryLabel = runtime:t("action.off")
  elseif step == 2 then
    prompt.message = runtime:t("onboarding.favorites.message")
    prompt.primaryLabel = runtime:t("action.on")
    prompt.secondaryLabel = runtime:t("action.off")
  elseif step == 3 then
    prompt.message = runtime:t("onboarding.apply_mode.message")
    prompt.primaryLabel = runtime:t("onboarding.apply_mode.staged")
    prompt.secondaryLabel = runtime:t("onboarding.apply_mode.immediate")
  elseif step == 4 then
    prompt.message = runtime:t("onboarding.sidebar_scroll.message")
    prompt.primaryLabel = runtime:t("action.on")
    prompt.secondaryLabel = runtime:t("action.off")
  else
    prompt.message = runtime:t("onboarding.list_selection.message")
    prompt.primaryLabel = runtime:t("onboarding.list_selection.frame")
    prompt.secondaryLabel = runtime:t("onboarding.list_selection.text")
  end
  return prompt
end

function Model:cancelInitialSetup()
  local state = self.runtime.state
  state.initialSetupStep = nil
  state.initialSetupDraft = nil
  self.runtime:queueRender()
end

function Model:chooseInitialSetup(primaryChoice)
  local runtime = self.runtime
  local state = runtime.state
  local draft = state.initialSetupDraft
  local step = tonumber(state.initialSetupStep)
  if type(draft) ~= "table" or step == nil then
    return false
  end

  if step == 1 then
    draft.showModProviderPrefix = primaryChoice == true
    state.initialSetupStep = 2
  elseif step == 2 then
    if primaryChoice == true then
      draft.favoriteUxMode = draft.favoriteUxMode ~= "off" and draft.favoriteUxMode or "both"
    else
      draft.favoriteUxMode = "off"
    end
    state.initialSetupStep = 3
  elseif step == 3 then
    draft.autoApply = primaryChoice ~= true
    state.initialSetupStep = 4
  elseif step == 4 then
    draft.sidebarTextScrollMode = primaryChoice == true and "pingpong" or "off"
    state.initialSetupStep = 5
  elseif step == 5 then
    draft.listSelectionMode = primaryChoice == true and "frame" or "text"
    state.showModProviderPrefix = draft.showModProviderPrefix
    state.favoriteUxMode = draft.favoriteUxMode
    state.autoApply = draft.autoApply
    state.sidebarTextScrollMode = draft.sidebarTextScrollMode
    state.listSelectionMode = draft.listSelectionMode
    state.initialSetupVersion = INITIAL_SETUP_VERSION
    state.initialSetupStep = nil
    state.initialSetupDraft = nil
    state.favoriteRevision = (tonumber(state.favoriteRevision) or 0) + 1
    state.scrollPositions.mods_scroll = 0
    runtime:setStatus(runtime:t("onboarding.complete"), "success")
    self:persistPreferences()
  else
    return false
  end

  runtime:queueRender()
  return true
end

function Model:sidebarTextScrollElements()
  local runtime = self.runtime
  return {
    runtime:t("common.off"),
    runtime:t("settings.sidebar_scroll.loop"),
    runtime:t("settings.sidebar_scroll.pingpong"),
  }
end

function Model:sidebarTextScrollIndex()
  local mode = self.runtime.state.sidebarTextScrollMode
  if mode == "loop" then
    return 2
  end
  if mode == "pingpong" then
    return 3
  end
  return 1
end

function Model:setSidebarTextScrollIndex(value)
  local runtime = self.runtime
  local index = math.max(1, math.min(3, tonumber(value) or 3))
  local modes = { "off", "loop", "pingpong" }
  runtime.state.sidebarTextScrollMode = modes[index]
  runtime:setStatus(runtime:t("status.sidebar_scroll", {
    value = self:sidebarTextScrollElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:sidebarTextScrollActivationElements()
  local runtime = self.runtime
  return {
    runtime:t("settings.sidebar_scroll_activation.always"),
    runtime:t("settings.sidebar_scroll_activation.hover"),
    runtime:t("settings.sidebar_scroll_activation.hover_selected"),
    runtime:t("settings.sidebar_scroll_activation.selected"),
  }
end

function Model:sidebarTextScrollActivationIndex()
  local mode = self.runtime.state.sidebarTextScrollActivation
  if mode == "always" then
    return 1
  end
  if mode == "hover" then
    return 2
  end
  if mode == "selected" then
    return 4
  end
  return 3
end

function Model:setSidebarTextScrollActivationIndex(value)
  local runtime = self.runtime
  local index = math.max(1, math.min(4, tonumber(value) or 3))
  local modes = { "always", "hover", "hover_selected", "selected" }
  runtime.state.sidebarTextScrollActivation = modes[index]
  runtime:setStatus(runtime:t("status.sidebar_scroll_activation", {
    value = self:sidebarTextScrollActivationElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:sidebarTextScrollSpeedElements()
  local runtime = self.runtime
  return {
    runtime:t("settings.sidebar_scroll_speed.slow"),
    runtime:t("settings.sidebar_scroll_speed.normal"),
    runtime:t("settings.sidebar_scroll_speed.fast"),
    runtime:t("settings.sidebar_scroll_speed.very_fast"),
  }
end

function Model:sidebarTextScrollSpeedIndex()
  local mode = self.runtime.state.sidebarTextScrollSpeed
  if mode == "slow" then
    return 1
  end
  if mode == "fast" then
    return 3
  end
  if mode == "very_fast" then
    return 4
  end
  return 2
end

function Model:setSidebarTextScrollSpeedIndex(value)
  local runtime = self.runtime
  local index = math.max(1, math.min(4, tonumber(value) or 2))
  local modes = { "slow", "normal", "fast", "very_fast" }
  runtime.state.sidebarTextScrollSpeed = modes[index]
  runtime:setStatus(runtime:t("status.sidebar_scroll_speed", {
    value = self:sidebarTextScrollSpeedElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:favoriteUxElements()
  local runtime = self.runtime
  return {
    runtime:t("common.off"),
    runtime:t("settings.favorites.star"),
    runtime:t("settings.favorites.button"),
    runtime:t("settings.favorites.both"),
  }
end

function Model:favoriteUxIndex()
  local mode = self.runtime.state.favoriteUxMode
  if mode == "off" then
    return 1
  end
  if mode == "star" then
    return 2
  end
  if mode == "button" then
    return 3
  end
  return 4
end

function Model:setFavoriteUxIndex(value)
  local runtime = self.runtime
  local state = runtime.state
  local index = math.max(1, math.min(4, tonumber(value) or 4))
  local modes = { "off", "star", "button", "both" }
  state.favoriteUxMode = modes[index]
  state.favoriteRevision = (tonumber(state.favoriteRevision) or 0) + 1
  state.scrollPositions.mods_scroll = 0
  runtime:setStatus(runtime:t("status.favorite_ux", {
    value = self:favoriteUxElements()[index],
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:favoriteStarsVisible()
  local mode = self.runtime.state.favoriteUxMode
  return mode == "star" or mode == "both"
end

function Model:favoriteNamesHighlighted()
  return self.runtime.state.favoriteUxMode == "button"
end

function Model:favoriteButtonVisible()
  local mode = self.runtime.state.favoriteUxMode
  return mode == "button" or mode == "both"
end

function Model:isFavorite(modKey)
  return self.runtime.state.favoriteModKeys[tostring(modKey or "")] == true
end

function Model:scrollToMod(modKey)
  local runtime = self.runtime
  local state = runtime.state
  local mods = self:filteredMods()
  local targetIndex = nil
  for index, mod in ipairs(mods) do
    if mod.key == modKey then
      targetIndex = index
      break
    end
  end
  if targetIndex == nil then
    return
  end

  local rowHeight = runtime.layout.metrics.leftRowH
  local viewportHeight = runtime.layout.metrics.leftScrollH
  local contentHeight = math.max(viewportHeight, (#mods * rowHeight) + 20)
  local overflow = math.max(0, contentHeight - viewportHeight)
  if overflow > 0 then
    local rowY = (targetIndex - 1) * rowHeight
    state.scrollPositions.mods_scroll =
      math.max(0, math.min(1, (rowY - (viewportHeight * 0.35)) / overflow))
  else
    state.scrollPositions.mods_scroll = 0
  end
end

function Model:toggleFavorite(modKey)
  local runtime = self.runtime
  local state = runtime.state
  local key = tostring(modKey or "")
  if key == "" then
    return
  end

  local mod = findMod(state.mods, key)
  if mod == nil then
    return
  end
  local added = not self:isFavorite(key)
  if added then
    state.favoriteModKeys[key] = true
  else
    state.favoriteModKeys[key] = nil
  end
  state.favoriteRevision = (tonumber(state.favoriteRevision) or 0) + 1
  self:scrollToMod(key)
  runtime:setStatus(
    runtime:t(added and "status.favorite_added" or "status.favorite_removed", {
      mod = runtime:safe(mod.name),
    }),
    "success"
  )
  self:persistPreferences()
  runtime:queueRender()
end

function Model:setAutoApply(value)
  local runtime = self.runtime
  runtime.state.autoApply = value == true
  runtime:setStatus(
    runtime:t(runtime.state.autoApply and "status.auto_apply_on" or "status.auto_apply_off")
  )
  self:persistPreferences()
  runtime:queueRender()
end

function Model:menuEntryLabelIndex()
  if self.runtime.state.menuEntryLabel == "MODS" then
    return 2
  end

  return 1
end

function Model:setMenuEntryLabelIndex(value)
  local runtime = self.runtime
  local state = runtime.state
  if tonumber(value) == 2 then
    state.menuEntryLabel = "MODS"
  else
    state.menuEntryLabel = "MCM"
  end

  runtime.menuIntegration.setLabel(state.menuEntryLabel)
  runtime:setStatus(runtime:t("status.menu_entry", {
    value = state.menuEntryLabel == "MODS" and "Mods" or "MCM",
  }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:setFrameworkMenuRedirect(value)
  local runtime = self.runtime
  local state = runtime.state
  state.redirectFrameworkMenuEntries = value == true
  runtime.menuIntegration.setFrameworkRedirectEnabled(state.redirectFrameworkMenuEntries)
  runtime:setStatus(
    runtime:t(
      state.redirectFrameworkMenuEntries and "status.framework_menu_redirect_on"
        or "status.framework_menu_redirect_off"
    )
  )
  self:persistPreferences()
  runtime:queueRender()
end

function Model:setGameplayShortcut(value)
  local runtime = self.runtime
  local state = runtime.state
  local key = runtime:safe(value)
  if string.sub(key, 1, 3) ~= "IK_" or key == "IK_Escape" then
    return
  end
  state.gameplayShortcut = key
  runtime:setStatus(
    runtime:t("status.gameplay_shortcut", { value = self:valueLabel({ type = "key" }, key) })
  )
  self:persistPreferences()
  runtime:queueRender()
end

function Model:providerFilterChoices()
  local runtime = self.runtime
  local state = runtime.state
  local keys = { "all" }
  local labels = { runtime:t("common.all") }

  if state.api ~= nil and type(state.api.listProviders) == "function" then
    local providers = runtime:first(state.api.listProviders) or {}
    for _, provider in ipairs(providers) do
      keys[#keys + 1] = runtime:safe(provider.id)
      labels[#labels + 1] = runtime:safe(provider.name or provider.shortName or provider.id)
    end
  end

  return keys, labels
end

function Model:providerFilterIndex()
  local state = self.runtime.state
  local keys = self:providerFilterChoices()
  for index, key in ipairs(keys) do
    if key == state.providerFilter then
      return index
    end
  end

  state.providerFilter = "all"
  return 1
end

function Model:setProviderFilterIndex(value)
  local index = tonumber(value) or 1
  local keys = self:providerFilterChoices()
  self:setModFilter(keys[index] or "all")
end

function Model:providerFilterElements()
  local _, labels = self:providerFilterChoices()
  return labels
end

function Model:setModSortIndex(value)
  local runtime = self.runtime
  local state = runtime.state
  if tonumber(value) == 2 then
    state.modSortMode = "za"
  else
    state.modSortMode = "az"
  end

  state.scrollPositions.mods_scroll = 0
  runtime:setStatus(runtime:t("status.mod_sort", { value = self:modSortLabel() }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:modSortIndex()
  if self.runtime.state.modSortMode == "za" then
    return 2
  end

  return 1
end

function Model:setSettingsSortIndex(value)
  local runtime = self.runtime
  local state = runtime.state
  local index = tonumber(value) or 1
  if index == 2 then
    state.settingsSortMode = "az"
  elseif index == 3 then
    state.settingsSortMode = "za"
  else
    state.settingsSortMode = "file"
  end

  state.scrollPositions.settings_scroll = 0
  runtime:setStatus(runtime:t("status.settings_order", { value = self:settingsSortLabel() }))
  self:persistPreferences()
  runtime:queueRender()
end

function Model:settingsSortIndex()
  local mode = self.runtime.state.settingsSortMode
  if mode == "az" then
    return 2
  end
  if mode == "za" then
    return 3
  end

  return 1
end

function Model:filteredMods()
  local state = self.runtime.state
  return ModList.filtered(state.mods, {
    providerFilter = state.providerFilter,
    textFilter = state.searchQueries and state.searchQueries.sidebar or "",
    sortMode = state.modSortMode,
    sortWithProvider = state.modSortWithProvider,
    favoriteKeys = state.favoriteUxMode ~= "off" and state.favoriteModKeys or nil,
  })
end

function Model:setModFilter(filter)
  local runtime = self.runtime
  local state = runtime.state
  rememberModSettingsScroll(state)
  state.providerFilter = filter
  state.scrollPositions.mods_scroll = 0
  state.scrollPositions.settings_scroll = 0
  state.selectedModKey = nil

  if state.api and state.api.closeMod then
    state.api.closeMod()
  end

  self:persistPreferences()
  runtime:queueRender()
end

function Model:refreshIndex()
  local runtime = self.runtime
  local state = runtime.state
  if state.api == nil then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    return
  end

  local selectedKey = state.selectedModKey
  local _, err = state.api.refreshIndex()
  state.mods = runtime:first(state.api.listMods) or {}
  local selectedStillExists = false
  for _, mod in ipairs(state.mods) do
    if mod.key == selectedKey then
      selectedStillExists = true
      break
    end
  end

  if selectedStillExists then
    state.selectedModKey = selectedKey
  else
    state.selectedModKey = nil
  end

  local restoreError = nil
  if state.selectedModKey ~= nil then
    local _, contextError = self:restoreSelectedMod()
    restoreError = contextError
  end

  local statusError = err or restoreError
  runtime:setStatus(runtime:currentApiStatus(statusError), statusError ~= nil and "error" or "info")
end

function Model:shouldRefreshOnActivate()
  return true
end

function Model:selectedMod()
  local state = self.runtime.state
  return findMod(state.mods, state.selectedModKey)
end

function Model:ensureModOpen(modKey)
  local runtime = self.runtime
  local state = runtime.state
  local api = state.api
  if api == nil or type(api.openMod) ~= "function" then
    return false, runtime:t("error.api_unavailable")
  end
  if modKey == nil then
    return false, "No mod selected."
  end

  if type(api.getDiagnostics) == "function" then
    local diagnostics = runtime:first(api.getDiagnostics)
    if type(diagnostics) == "table" and diagnostics.activeModKey == modKey then
      return true, nil
    end
  end

  local opened, err = api.openMod(modKey)
  if opened == nil then
    return false, err or ("Unable to open mod: " .. tostring(modKey))
  end

  return true, err
end

function Model:restoreSelectedMod()
  local runtime = self.runtime
  local state = runtime.state
  local modKey = state.selectedModKey
  if modKey == nil then
    return true, nil
  end

  local mod = findMod(state.mods, modKey)
  if mod == nil then
    state.selectedModKey = nil
    return false, "The previously selected mod is no longer available."
  end

  state.rememberedModKey = modKey
  state.route.modKey = modKey
  return self:ensureModOpen(modKey)
end

function Model:selectModNow(mod)
  local runtime = self.runtime
  local state = runtime.state
  if state.api == nil or mod == nil then
    return
  end

  rememberModSettingsScroll(state)
  state.selectedModKey = mod.key
  state.rememberedModKey = mod.key
  state.route.modKey = mod.key
  restoreModSettingsScroll(state, mod.key)
  local _, err = state.api.openMod(mod.key)
  runtime:setStatus(runtime:currentApiStatus(err), err ~= nil and "error" or "info")
  runtime:queueRender()
end

function Model:selectMod(mod)
  local state = self.runtime.state
  if mod == nil or mod.key == state.selectedModKey then
    return
  end

  return self:resolvePendingDrafts(function()
    self:selectModNow(mod)
  end)
end

function Model:flattenSettings(mod)
  local runtime = self.runtime
  local state = runtime.state
  local rows = {}
  if mod == nil or state.api == nil then
    return rows
  end

  local categories, err = state.api.listCategories(mod.key)
  if err ~= nil then
    rows[#rows + 1] = { kind = "category", label = runtime:t("common.error") }
    rows[#rows + 1] = { kind = "message", label = err }
    return rows
  end

  local query = Text.casefold(state.searchQueries and state.searchQueries.content)
  for _, category in ipairs(categories or {}) do
    local categoryLabel = category.name or category.label or category.key
    local categoryHaystack =
      Text.casefold(runtime:safe(categoryLabel) .. " " .. runtime:safe(category.key))
    local categoryMatches = query == "" or string.find(categoryHaystack, query, 1, true) ~= nil
    local settings = {}
    for _, setting in ipairs(category.settings or {}) do
      settings[#settings + 1] = setting
    end

    if state.settingsSortMode ~= "file" then
      table.sort(settings, function(leftSetting, rightSetting)
        local left = string.lower(runtime:safe(leftSetting.label or leftSetting.key))
        local right = string.lower(runtime:safe(rightSetting.label or rightSetting.key))
        if left == right then
          return runtime:safe(leftSetting.id) < runtime:safe(rightSetting.id)
        end
        if state.settingsSortMode == "za" then
          return left > right
        end

        return left < right
      end)
    end

    local visibleSettings = {}
    for _, setting in ipairs(settings) do
      local settingHaystack = Text.casefold(table.concat({
        runtime:safe(setting.label),
        runtime:safe(setting.name),
        runtime:safe(setting.key),
        runtime:safe(setting.description),
      }, " "))
      local searchMatches = categoryMatches or string.find(settingHaystack, query, 1, true) ~= nil
      local modifiedMatches = not state.modifiedOnly or self:settingDefaultState(setting).modified
      if searchMatches and modifiedMatches then
        visibleSettings[#visibleSettings + 1] = setting
      end
    end

    if #visibleSettings > 0 then
      rows[#rows + 1] = {
        kind = "category",
        label = categoryLabel,
        frameworkId = runtime:safe(category.id),
      }
      for _, setting in ipairs(visibleSettings) do
        rows[#rows + 1] = { kind = "setting", setting = setting }
      end
    end
  end

  return rows
end

function Model:modifiedSettingCount(mod)
  local runtime = self.runtime
  local state = runtime.state
  mod = mod or self:selectedMod()
  if mod == nil or state.api == nil then
    return 0, 0
  end

  local categories = runtime:first(state.api.listCategories, mod.key) or {}
  local modified = 0
  local comparable = 0
  for _, category in ipairs(categories) do
    for _, setting in ipairs(category.settings or {}) do
      local defaultState = self:settingDefaultState(setting)
      if defaultState.hasDefault then
        comparable = comparable + 1
        if defaultState.modified then
          modified = modified + 1
        end
      end
    end
  end
  return modified, comparable
end

function Model:toggleModifiedOnly()
  local runtime = self.runtime
  local state = runtime.state
  state.modifiedOnly = not state.modifiedOnly
  state.scrollPositions.settings_scroll = 0
  runtime:setStatus(
    runtime:t(state.modifiedOnly and "status.modified_only_on" or "status.modified_only_off")
  )
  runtime:queueRender()
end

function Model:valueLabel(setting, value)
  local runtime = self.runtime
  if setting.type == "bool" then
    if value == true then
      return runtime:t("common.on")
    end

    return runtime:t("common.off")
  end
  if setting.type == "select" then
    return runtime:safe((setting.elements or {})[tonumber(value) or 1])
  end

  return runtime:safe(value)
end

function Model:getSettingValue(setting)
  local runtime = self.runtime
  local state = runtime.state
  if setting ~= nil and type(setting.localGet) == "function" then
    local ok, value = pcall(setting.localGet)
    if ok then
      return value
    end

    return nil
  end
  if state.api == nil or setting == nil then
    return nil
  end

  return runtime:first(state.api.getValue, setting.id)
end

function Model:settingDefaultState(setting)
  local runtime = self.runtime
  local api = runtime.state.api
  local result = {
    hasDefault = false,
    isDefault = true,
    modified = false,
  }
  if setting ~= nil and type(setting.localGet) == "function" then
    if setting.defaultValue == nil then
      return result
    end

    local ok, value = pcall(setting.localGet)
    if not ok then
      return result
    end

    result.hasDefault = true
    result.isDefault = value == setting.defaultValue
    result.modified = not result.isDefault
    return result
  end
  if setting == nil or api == nil or type(api.isDefault) ~= "function" then
    return result
  end

  local isDefault = runtime:first(api.isDefault, setting.id)
  if type(isDefault) ~= "boolean" then
    return result
  end

  result.hasDefault = true
  result.isDefault = isDefault
  result.modified = not isDefault
  return result
end

function Model:settingDisplay(setting)
  local runtime = self.runtime
  local mode = runtime.state.defaultIndicatorMode
  local defaultState = self:settingDefaultState(setting)
  local label = runtime:safe(setting and setting.label)

  return {
    label = label,
    marker = defaultState.modified and mode == "asterisk" and "*" or nil,
    isNonDefault = defaultState.modified,
    highlighted = defaultState.modified and mode == "colored",
    mode = mode,
  }
end

function Model:getDefaultCoverage(modKey)
  local runtime = self.runtime
  local api = runtime.state.api
  if api == nil or type(api.getDefaultCoverage) ~= "function" then
    return nil
  end

  return runtime:first(api.getDefaultCoverage, modKey)
end

function Model:setSettingDraft(setting, value)
  local runtime = self.runtime
  local state = runtime.state
  if setting == nil then
    return false, false
  end

  if type(setting.localSet) == "function" then
    local ok, err = pcall(setting.localSet, value)
    if not ok then
      runtime:setStatus("Setting update failed: " .. tostring(err), "error")
      return false, false
    end

    return true, false, false
  end
  if state.api == nil then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    return false, false
  end

  local modKey = setting.modKey or state.selectedModKey
  local contextReady, contextError = self:ensureModOpen(modKey)
  if not contextReady then
    runtime:setStatus(contextError or "No mod selected.", "error")
    return false, false
  end

  local dirtyBefore = runtime:first(state.api.hasDrafts, modKey) == true
  local modifiedBefore = self:settingDefaultState(setting).modified
  local ok, err = state.api.setDraft(setting.id, value)
  local autoApplied = false
  if ok == true and state.autoApply then
    ok, err = state.api.apply(modKey)
    autoApplied = ok == true
  end
  local dirtyAfter = runtime:first(state.api.hasDrafts, modKey) == true
  local modifiedAfter = self:settingDefaultState(setting).modified
  local status = runtime:currentApiStatus(err)
  if ok ~= true and err == nil then
    status = "Unable to change " .. runtime:safe(setting.label)
  end
  runtime:setStatus(status, ok == true and (autoApplied and "success" or "info") or "error")

  return ok == true, dirtyBefore ~= dirtyAfter, modifiedBefore ~= modifiedAfter
end

function Model:setSettingToDefault(setting)
  local runtime = self.runtime
  local state = runtime.state
  local api = state.api
  if setting ~= nil and type(setting.localGet) == "function" then
    local defaultState = self:settingDefaultState(setting)
    if
      not defaultState.hasDefault
      or defaultState.isDefault
      or type(setting.localSet) ~= "function"
    then
      return false
    end

    local ok, err = pcall(setting.localSet, setting.defaultValue)
    if not ok then
      runtime:setStatus("Setting reset failed: " .. tostring(err), "error")
      runtime:queueRender()
      return false
    end

    runtime:queueRender()
    return true
  end
  if setting == nil or api == nil or type(api.setDraftToDefault) ~= "function" then
    return false
  end

  local modKey = setting.modKey or state.selectedModKey
  local contextReady, contextError = self:ensureModOpen(modKey)
  if not contextReady then
    runtime:setStatus(contextError or "No mod selected.", "error")
    runtime:queueRender()
    return false
  end

  local defaultState = self:settingDefaultState(setting)
  if not defaultState.hasDefault or defaultState.isDefault then
    return false
  end

  local ok, err = api.setDraftToDefault(setting.id)
  local autoApplied = false
  if ok == true and runtime.state.autoApply then
    ok, err = api.apply(modKey)
    autoApplied = ok == true
  end
  local status = runtime:currentApiStatus(err)
  if ok ~= true and err == nil then
    status = "Unable to reset " .. runtime:safe(setting.label)
  end
  runtime:setStatus(status, ok == true and (autoApplied and "success" or "info") or "error")
  runtime:queueRender()
  return ok == true
end

function Model:setModToDefaults(modKey)
  local runtime = self.runtime
  local api = runtime.state.api
  if api == nil or type(api.setModDraftsToDefaults) ~= "function" then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    runtime:queueRender()
    return false
  end

  local contextReady, contextError = self:ensureModOpen(modKey)
  if not contextReady then
    runtime:setStatus(contextError or "No mod selected.", "error")
    runtime:queueRender()
    return false
  end

  local result, err = api.setModDraftsToDefaults(modKey)
  local autoApplied = false
  if result ~= nil and err == nil and runtime.state.autoApply then
    local applied = nil
    applied, err = api.apply(modKey)
    if applied == true then
      autoApplied = true
    else
      result = nil
    end
  end
  local status = runtime:currentApiStatus(err)
  if result == nil and err == nil then
    status = "Unable to stage default settings."
  end
  runtime:setStatus(
    status,
    result ~= nil and err == nil and (autoApplied and "success" or "info") or "error"
  )
  runtime:queueRender()
  return result ~= nil and err == nil
end

function Model:changeSetting(setting, direction)
  local runtime = self.runtime
  local state = runtime.state
  if setting == nil or not setting.supported then
    return
  end

  local value = self:getSettingValue(setting)
  local nextValue = nil
  if setting.type == "bool" then
    nextValue = value ~= true
  elseif setting.type == "select" then
    local count = #(setting.elements or {})
    if count == 0 then
      runtime:setStatus("No cycle values for " .. runtime:safe(setting.label), "error")
      runtime:queueRender()
      return
    end

    nextValue = (tonumber(value) or 1) + direction
    if nextValue < 1 then
      nextValue = count
    end
    if nextValue > count then
      nextValue = 1
    end
  elseif setting.type == "int" or setting.type == "float" then
    local defaultStep = 0.1
    if setting.type == "int" then
      defaultStep = 1
    end

    local step = tonumber(setting.step) or defaultStep
    nextValue = (tonumber(value) or 0) + step * direction
    local minimum = tonumber(setting.min)
    local maximum = tonumber(setting.max)
    if minimum ~= nil then
      nextValue = math.max(minimum, nextValue)
    end
    if maximum ~= nil then
      nextValue = math.min(maximum, nextValue)
    end
    if setting.type == "int" then
      nextValue = math.floor(nextValue)
    end
  end

  if nextValue ~= nil then
    self:setSettingDraft(setting, nextValue)
    runtime:queueRender()
  end
end

function Model:hasDrafts(modKey)
  local runtime = self.runtime
  local api = runtime.state.api
  if api == nil or type(api.hasDrafts) ~= "function" then
    return false
  end

  return runtime:first(api.hasDrafts, modKey) == true
end

function Model:apply(modKey)
  local runtime = self.runtime
  local api = runtime.state.api
  if api == nil or type(api.apply) ~= "function" then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    runtime:queueRender()
    return false
  end

  local ok, err = api.apply(modKey)
  local status = runtime:currentApiStatus(err)
  if ok ~= true and err == nil then
    status = "Unable to apply settings."
  end
  runtime:setStatus(status, ok == true and "success" or "error")
  runtime:queueRender()

  return ok == true
end

function Model:revert(modKey)
  local runtime = self.runtime
  local api = runtime.state.api
  if api == nil or type(api.revert) ~= "function" then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    runtime:queueRender()
    return false
  end

  local ok, err = api.revert(modKey)
  local status = runtime:currentApiStatus(err)
  if ok ~= true and err == nil then
    status = "Unable to revert pending changes."
  end
  runtime:setStatus(status, ok == true and "success" or "error")
  runtime:queueRender()

  return ok == true
end

function Model:invokeAction(setting)
  local runtime = self.runtime
  local api = runtime.state.api
  if setting == nil or api == nil or type(api.invokeAction) ~= "function" then
    runtime:setStatus(runtime:t("error.api_unavailable"), "error")
    runtime:queueRender()
    return false
  end

  local modKey = setting.modKey or runtime.state.selectedModKey
  local contextReady, contextError = self:ensureModOpen(modKey)
  if not contextReady then
    runtime:setStatus(contextError or "No mod selected.", "error")
    runtime:queueRender()
    return false
  end

  local ok, err, result = api.invokeAction(setting.id, {
    contentScrollPosition = tonumber(runtime.state.scrollPositions.settings_scroll) or 0,
    controller = runtime.state.controller,
  })
  local status = runtime:currentApiStatus(err)
  if ok ~= true and err == nil then
    status = "Unable to run " .. runtime:safe(setting.label)
  end
  if
    ok == true
    and type(result) == "table"
    and type(result.effects) == "table"
    and tonumber(result.effects.contentScrollPosition) ~= nil
  then
    runtime.state.scrollPositions.settings_scroll =
      math.max(0, math.min(1, tonumber(result.effects.contentScrollPosition)))
  end
  runtime:setStatus(status, ok == true and "success" or "error")
  runtime:queueRender()

  return ok == true
end

function Model:onRouteChanged()
  local runtime = self.runtime
  local state = runtime.state
  local view = state.route.view

  if view == "mod_presets" then
    local modKey = state.route.modKey or state.selectedModKey or state.rememberedModKey
    if modKey == nil then
      Routes.go(state, "mods")
      runtime:setStatus(runtime:t("error.select_mod_for_presets"), "error")
      return
    end

    state.route.modKey = modKey
    state.rememberedModKey = modKey
    if state.selectedModKey ~= modKey then
      local selected = nil
      for _, mod in ipairs(state.mods) do
        if mod.key == modKey then
          selected = mod
          break
        end
      end
      if selected ~= nil then
        self:selectMod(selected)
      end
    end
    self:refreshPresets()
  elseif view == "collections" then
    self:refreshCollections()
  elseif view == "mods" then
    runtime:setStatus(runtime:currentApiStatus())
  elseif view == "settings" then
    runtime:setStatus(runtime:t("status.renderer_settings"))
  end
end

function Model:mcmSettingsContext()
  local runtime = self.runtime
  local state = runtime.state
  return {
    state = state,
    menuEntryLabelIndex = function()
      return self:menuEntryLabelIndex()
    end,
    setMenuEntryLabelIndex = function(value)
      self:setMenuEntryLabelIndex(value)
    end,
    setFrameworkMenuRedirect = function(value)
      self:setFrameworkMenuRedirect(value)
    end,
    setGameplayShortcut = function(value)
      self:setGameplayShortcut(value)
    end,
    providerFilterIndex = function()
      return self:providerFilterIndex()
    end,
    setProviderFilterIndex = function(value)
      self:setProviderFilterIndex(value)
    end,
    providerFilterElements = function()
      return self:providerFilterElements()
    end,
    modSortIndex = function()
      return self:modSortIndex()
    end,
    setModSortIndex = function(value)
      self:setModSortIndex(value)
    end,
    favoriteUxIndex = function()
      return self:favoriteUxIndex()
    end,
    setFavoriteUxIndex = function(value)
      self:setFavoriteUxIndex(value)
    end,
    favoriteUxElements = function()
      return self:favoriteUxElements()
    end,
    listSelectionIndex = function()
      return self:listSelectionIndex()
    end,
    setListSelectionIndex = function(value)
      self:setListSelectionIndex(value)
    end,
    listSelectionElements = function()
      return self:listSelectionElements()
    end,
    layoutProfileIndex = function()
      return self:layoutProfileIndex()
    end,
    setLayoutProfileIndex = function(value)
      self:setLayoutProfileIndex(value)
    end,
    layoutProfileElements = function()
      return self:layoutProfileElements()
    end,
    uiScaleIndex = function()
      return self:uiScaleIndex()
    end,
    setUiScaleIndex = function(value)
      self:setUiScaleIndex(value)
    end,
    uiScaleElements = function()
      return self:uiScaleElements()
    end,
    sidebarTextScrollIndex = function()
      return self:sidebarTextScrollIndex()
    end,
    setSidebarTextScrollIndex = function(value)
      self:setSidebarTextScrollIndex(value)
    end,
    sidebarTextScrollElements = function()
      return self:sidebarTextScrollElements()
    end,
    sidebarTextScrollActivationIndex = function()
      return self:sidebarTextScrollActivationIndex()
    end,
    setSidebarTextScrollActivationIndex = function(value)
      self:setSidebarTextScrollActivationIndex(value)
    end,
    sidebarTextScrollActivationElements = function()
      return self:sidebarTextScrollActivationElements()
    end,
    sidebarTextScrollSpeedIndex = function()
      return self:sidebarTextScrollSpeedIndex()
    end,
    setSidebarTextScrollSpeedIndex = function(value)
      self:setSidebarTextScrollSpeedIndex(value)
    end,
    sidebarTextScrollSpeedElements = function()
      return self:sidebarTextScrollSpeedElements()
    end,
    settingsSortIndex = function()
      return self:settingsSortIndex()
    end,
    setSettingsSortIndex = function(value)
      self:setSettingsSortIndex(value)
    end,
    defaultIndicatorIndex = function()
      return self:defaultIndicatorIndex()
    end,
    setDefaultIndicatorIndex = function(value)
      self:setDefaultIndicatorIndex(value)
    end,
    defaultIndicatorElements = function()
      return self:defaultIndicatorElements()
    end,
    themeRoles = function()
      return Theme.ROLES
    end,
    themeColorElements = function()
      return self:themeColorElements()
    end,
    themeColorIndex = function(roleKey)
      return self:themeColorIndex(roleKey)
    end,
    setThemeColorIndex = function(roleKey, value)
      self:setThemeColorIndex(roleKey, value)
    end,
    setAutoApply = function(value)
      self:setAutoApply(value)
    end,
    persistPreferences = function()
      self:persistPreferences()
    end,
    text = function(key, values)
      return runtime:t(key, values)
    end,
    queueRender = function()
      runtime:queueRender()
    end,
    setStatus = function(message, kind)
      runtime:setStatus(message, kind)
    end,
  }
end

function Model:mcmSettingsRows()
  local runtime = self.runtime
  return LocalSettings.rows(self:mcmSettingsContext(), runtime.state.settingsCategory)
end

function Model:mcmSettingsHaveNonDefaults()
  local context = self:mcmSettingsContext()
  for _, category in ipairs(LocalSettings.categories(context)) do
    if self:mcmSettingsCategoryHasNonDefaults(category.key, context) then
      return true
    end
  end
  return false
end

function Model:mcmSettingsCategoryHasNonDefaults(categoryKey, context)
  context = context or self:mcmSettingsContext()
  for _, row in ipairs(LocalSettings.rows(context, categoryKey)) do
    if row.kind == "setting" and self:settingDefaultState(row.setting).modified then
      return true
    end
  end
  return false
end

function Model:setMcmSettingsCategoryToDefaults(categoryKey, context)
  context = context or self:mcmSettingsContext()
  local changed = false
  local failed = false
  for _, row in ipairs(LocalSettings.rows(context, categoryKey)) do
    local setting = row.kind == "setting" and row.setting or nil
    local defaultState = self:settingDefaultState(setting)
    if defaultState.modified and type(setting.localSet) == "function" then
      local ok, err = pcall(setting.localSet, setting.defaultValue)
      if ok then
        changed = true
      else
        failed = true
        self.runtime:logError(
          "Failed to reset MCM setting " .. tostring(setting.id) .. ": " .. tostring(err)
        )
      end
    end
  end
  self.runtime:queueRender()
  return changed and not failed
end

function Model:setMcmSettingsToDefaults()
  local context = self:mcmSettingsContext()
  local changed = false
  local failed = false
  for _, category in ipairs(LocalSettings.categories(context)) do
    if self:mcmSettingsCategoryHasNonDefaults(category.key, context) then
      if self:setMcmSettingsCategoryToDefaults(category.key, context) then
        changed = true
      else
        failed = true
      end
    end
  end
  self.runtime:queueRender()
  return changed and not failed
end

function Model:mcmSettingsCategories()
  return LocalSettings.categories({
    text = function(key, values)
      return self.runtime:t(key, values)
    end,
  })
end

function Model:syncIfQueued()
  local runtime = self.runtime
  local state = runtime.state
  if not state.modelSyncQueued or state.api == nil then
    return
  end

  state.modelSyncQueued = false
  local mods, err = state.api.listMods()
  if type(mods) ~= "table" or err ~= nil then
    local status = runtime:currentApiStatus(err)
    if err == nil then
      status = "Unable to refresh the mod list."
    end
    runtime:setStatus(status, "error")
    return
  end

  state.mods = mods
  if state.selectedModKey ~= nil then
    local selectedModExists = false
    for _, mod in ipairs(state.mods) do
      if mod.key == state.selectedModKey then
        selectedModExists = true
        break
      end
    end
    if not selectedModExists then
      state.selectedModKey = nil
    end
  end

  runtime:queueRender()
end

require("mcm_ui/mcm_presets").attach(Model)
require("mcm_ui/mcm_collections").attach(Model)

return Model
