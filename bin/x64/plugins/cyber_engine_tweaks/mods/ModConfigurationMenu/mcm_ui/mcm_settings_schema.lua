local Theme = require("mcm_ui/mcm_theme")

local LocalSettings = {}

local function makeSetting(
  id,
  label,
  description,
  settingType,
  localGet,
  localSet,
  elements,
  metadata
)
  local setting = {
    id = "mcm:" .. id,
    key = id,
    label = label,
    description = description,
    type = settingType,
    supported = true,
    elements = elements,
    localGet = localGet,
    localSet = localSet,
  }

  for key, value in pairs(metadata or {}) do
    setting[key] = value
  end

  return setting
end

local function category(label)
  return { kind = "category", label = label }
end

local function setting(value)
  return { kind = "setting", setting = value }
end

function LocalSettings.categories(ctx)
  local t = ctx.text
  return {
    {
      key = "general",
      label = t("settings.section.general"),
      description = t("settings.section.general.description"),
    },
    {
      key = "layout",
      label = t("settings.section.layout"),
      description = t("settings.section.layout.description"),
    },
    {
      key = "navigation",
      label = t("settings.section.navigation"),
      description = t("settings.section.navigation.description"),
    },
    {
      key = "theme",
      label = t("settings.section.theme"),
      description = t("settings.section.theme.description"),
    },
  }
end

function LocalSettings.rows(ctx, categoryKey)
  local state = ctx.state
  local t = ctx.text

  local function updatePrefixVisibility(value)
    state.showModProviderPrefix = value == true
    ctx.setStatus(
      t(state.showModProviderPrefix and "status.prefix_visible" or "status.prefix_hidden")
    )
    ctx.persistPreferences()
    ctx.queueRender()
  end

  local function updateProviderAwareSorting(value)
    state.modSortWithProvider = value == true
    state.scrollPositions.mods_scroll = 0
    ctx.setStatus(
      t(state.modSortWithProvider and "status.sort_prefix_on" or "status.sort_prefix_off")
    )
    ctx.persistPreferences()
    ctx.queueRender()
  end

  local function updatePresetFilter(value)
    state.presetNonDefaultOnly = value == true
    ctx.setStatus(
      t(
        state.presetNonDefaultOnly and "status.preset_non_default_on"
          or "status.preset_non_default_off"
      )
    )
    ctx.persistPreferences()
    ctx.queueRender()
  end

  local function updateDescriptionVisibility(value)
    state.showDescriptionPanel = value == true
    ctx.setStatus(
      t(state.showDescriptionPanel and "status.description_visible" or "status.description_hidden")
    )
    ctx.persistPreferences()
    ctx.queueRender()
  end

  if categoryKey == "layout" then
    return {
      category(t("settings.category.layout")),
      setting(
        makeSetting(
          "layout_profile",
          t("settings.layout_profile.label"),
          t("settings.layout_profile.description"),
          "select",
          ctx.layoutProfileIndex,
          ctx.setLayoutProfileIndex,
          ctx.layoutProfileElements(),
          { defaultValue = 1 }
        )
      ),
      setting(
        makeSetting(
          "ui_scale",
          t("settings.ui_scale.label"),
          t("settings.ui_scale.description"),
          "select",
          ctx.uiScaleIndex,
          ctx.setUiScaleIndex,
          ctx.uiScaleElements(),
          { defaultValue = 3 }
        )
      ),
      category(t("settings.category.display")),
      setting(
        makeSetting(
          "show_description_panel",
          t("settings.description_panel.label"),
          t("settings.description_panel.description"),
          "bool",
          function()
            return state.showDescriptionPanel
          end,
          updateDescriptionVisibility,
          nil,
          { defaultValue = true }
        )
      ),
      setting(
        makeSetting(
          "list_selection",
          t("settings.list_selection.label"),
          t("settings.list_selection.description"),
          "select",
          ctx.listSelectionIndex,
          ctx.setListSelectionIndex,
          ctx.listSelectionElements(),
          { defaultValue = 2 }
        )
      ),
      setting(
        makeSetting(
          "default_value_indicator",
          t("settings.default_indicator.label"),
          t("settings.default_indicator.description"),
          "select",
          ctx.defaultIndicatorIndex,
          ctx.setDefaultIndicatorIndex,
          ctx.defaultIndicatorElements(),
          { defaultValue = 3 }
        )
      ),
    }
  end

  if categoryKey == "navigation" then
    return {
      category(t("settings.category.mod_list")),
      setting(
        makeSetting(
          "provider_filter",
          t("settings.provider_filter.label"),
          t("settings.provider_filter.description"),
          "select",
          ctx.providerFilterIndex,
          ctx.setProviderFilterIndex,
          ctx.providerFilterElements(),
          { defaultValue = 1 }
        )
      ),
      setting(
        makeSetting(
          "show_provider_prefix",
          t("settings.show_prefix.label"),
          t("settings.show_prefix.description"),
          "bool",
          function()
            return state.showModProviderPrefix
          end,
          updatePrefixVisibility,
          nil,
          { defaultValue = true }
        )
      ),
      setting(
        makeSetting(
          "favorites_ux",
          t("settings.favorites.label"),
          t("settings.favorites.description"),
          "select",
          ctx.favoriteUxIndex,
          ctx.setFavoriteUxIndex,
          ctx.favoriteUxElements(),
          { defaultValue = 4 }
        )
      ),
      category(t("settings.category.sidebar_scroll")),
      setting(
        makeSetting(
          "sidebar_text_scroll",
          t("settings.sidebar_scroll.label"),
          t("settings.sidebar_scroll.description"),
          "select",
          ctx.sidebarTextScrollIndex,
          ctx.setSidebarTextScrollIndex,
          ctx.sidebarTextScrollElements(),
          { defaultValue = 3 }
        )
      ),
      setting(
        makeSetting(
          "sidebar_text_scroll_activation",
          t("settings.sidebar_scroll_activation.label"),
          t("settings.sidebar_scroll_activation.description"),
          "select",
          ctx.sidebarTextScrollActivationIndex,
          ctx.setSidebarTextScrollActivationIndex,
          ctx.sidebarTextScrollActivationElements(),
          { defaultValue = 3 }
        )
      ),
      setting(
        makeSetting(
          "sidebar_text_scroll_speed",
          t("settings.sidebar_scroll_speed.label"),
          t("settings.sidebar_scroll_speed.description"),
          "select",
          ctx.sidebarTextScrollSpeedIndex,
          ctx.setSidebarTextScrollSpeedIndex,
          ctx.sidebarTextScrollSpeedElements(),
          { defaultValue = 2 }
        )
      ),
      category(t("settings.category.sorting")),
      setting(
        makeSetting(
          "mod_sort",
          t("settings.mod_sort.label"),
          t("settings.mod_sort.description"),
          "select",
          ctx.modSortIndex,
          ctx.setModSortIndex,
          { "A-Z", "Z-A" },
          { defaultValue = 1 }
        )
      ),
      setting(
        makeSetting(
          "mod_sort_with_provider",
          t("settings.sort_prefix.label"),
          t("settings.sort_prefix.description"),
          "bool",
          function()
            return state.modSortWithProvider
          end,
          updateProviderAwareSorting,
          nil,
          { defaultValue = false }
        )
      ),
      setting(
        makeSetting(
          "settings_sort",
          t("settings.settings_order.label"),
          t("settings.settings_order.description"),
          "select",
          ctx.settingsSortIndex,
          ctx.setSettingsSortIndex,
          { t("common.original"), "A-Z", "Z-A" },
          { defaultValue = 1 }
        )
      ),
    }
  end

  if categoryKey == "theme" then
    local rows = { category(t("settings.category.theme")) }
    local themeElements = ctx.themeColorElements()
    for _, role in ipairs(ctx.themeRoles()) do
      local roleKey = role.key
      local roleLabel = t(role.labelKey)
      rows[#rows + 1] = setting(
        makeSetting(
          "theme_" .. roleKey,
          roleLabel,
          t("settings.theme.color.description", { role = roleLabel }),
          "select",
          function()
            return ctx.themeColorIndex(roleKey)
          end,
          function(value)
            ctx.setThemeColorIndex(roleKey, value)
          end,
          themeElements,
          { defaultValue = Theme.indexOf(role.default) or 1 }
        )
      )
    end
    return rows
  end

  local rows = {
    category(t("settings.category.menu")),
    setting(
      makeSetting(
        "menu_entry_label",
        t("settings.menu_entry.label"),
        t("settings.menu_entry.description"),
        "select",
        ctx.menuEntryLabelIndex,
        ctx.setMenuEntryLabelIndex,
        { "MCM", "Mods" },
        { defaultValue = 1 }
      )
    ),
    setting(
      makeSetting(
        "gameplay_shortcut",
        t("settings.gameplay_shortcut.label"),
        t("settings.gameplay_shortcut.description"),
        "key",
        function()
          return state.gameplayShortcut
        end,
        ctx.setGameplayShortcut,
        nil,
        { defaultValue = "IK_Home" }
      )
    ),
    setting(
      makeSetting(
        "redirect_framework_menu_entries",
        t("settings.framework_menu_redirect.label"),
        t("settings.framework_menu_redirect.description"),
        "bool",
        function()
          return state.redirectFrameworkMenuEntries
        end,
        ctx.setFrameworkMenuRedirect,
        nil,
        { defaultValue = true }
      )
    ),
  }
  rows[#rows + 1] = category(t("settings.category.editing"))
  rows[#rows + 1] = setting(
    makeSetting(
      "auto_apply",
      t("settings.auto_apply.label"),
      t("settings.auto_apply.description"),
      "bool",
      function()
        return state.autoApply
      end,
      ctx.setAutoApply,
      nil,
      { defaultValue = false }
    )
  )
  rows[#rows + 1] = category(t("settings.category.comparison"))
  rows[#rows + 1] = setting(
    makeSetting(
      "preset_non_default_only",
      t("settings.preset_non_default.label"),
      t("settings.preset_non_default.description"),
      "bool",
      function()
        return state.presetNonDefaultOnly
      end,
      updatePresetFilter,
      nil,
      { defaultValue = false }
    )
  )
  return rows
end

return LocalSettings
