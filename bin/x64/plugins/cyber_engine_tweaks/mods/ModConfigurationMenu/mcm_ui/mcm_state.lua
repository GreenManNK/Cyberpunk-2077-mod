local State = {}

local Routes = require("mcm_ui/mcm_routes")
local Theme = require("mcm_ui/mcm_theme")
local Host = require("mcm_ui/mcm_host")

function State.new(preferences)
  preferences = preferences or {}

  return {
    active = false,
    controller = nil,
    gameplayEntry = false,
    hiddenWrapper = nil,
    hiddenSettingsBackdropWidgets = {},
    hiddenButtonHintsRoot = nil,
    hiddenButtonHintsWasVisible = nil,
    api = nil,
    onClosed = nil,
    mods = {},
    selectedModKey = nil,
    rememberedModKey = nil,
    route = Routes.new(),
    presets = {},
    collections = {},
    selectedPresetId = nil,
    selectedCollectionId = nil,
    selectedCollection = nil,
    selectedCollectionEntryId = nil,
    collectionMissingEntries = {},
    collectionCleanupPlan = nil,
    collectionImportMode = false,
    portableCollections = {},
    selectedPortableFileName = nil,
    portableCollectionPreview = nil,
    portableCollectionDirectory = nil,
    presetPreview = nil,
    collectionEntryPreview = nil,
    pendingConfirmation = nil,
    installHealthNotices = {},
    activeOperationId = nil,
    initialSetupVersion = math.max(0, math.floor(tonumber(preferences.initialSetupVersion) or 0)),
    initialSetupStep = nil,
    initialSetupDraft = nil,
    lastCollectionApply = nil,
    menuEntryLabel = preferences.menuEntryLabel == "MODS" and "MODS" or "MCM",
    gameplayShortcut = type(preferences.gameplayShortcut) == "string"
        and string.sub(preferences.gameplayShortcut, 1, 3) == "IK_"
        and preferences.gameplayShortcut ~= "IK_Escape"
        and preferences.gameplayShortcut
      or "IK_Home",
    redirectFrameworkMenuEntries = preferences.redirectFrameworkMenuEntries ~= false,
    providerFilter = preferences.providerFilter or "all",
    searchQueries = {
      sidebar = "",
      content = "",
    },
    searchDrafts = {
      sidebar = "",
      content = "",
    },
    searchPendingFrames = {
      sidebar = 0,
      content = 0,
    },
    searchInputContext = nil,
    status = "",
    statusKind = "info",
    modSortMode = preferences.modSortMode or "az",
    modSortWithProvider = preferences.modSortWithProvider == true,
    sidebarTextScrollMode = preferences.sidebarTextScrollMode == "loop" and "loop"
      or (preferences.sidebarTextScrollMode == "off" and "off" or "pingpong"),
    sidebarTextScrollActivation = preferences.sidebarTextScrollActivation == "hover" and "hover"
      or (
        preferences.sidebarTextScrollActivation == "hover_selected" and "hover_selected"
        or (
          preferences.sidebarTextScrollActivation == "selected" and "selected"
          or (preferences.sidebarTextScrollActivation == "always" and "always" or "hover_selected")
        )
      ),
    sidebarTextScrollSpeed = preferences.sidebarTextScrollSpeed == "slow" and "slow"
      or (
        preferences.sidebarTextScrollSpeed == "fast" and "fast"
        or (preferences.sidebarTextScrollSpeed == "very_fast" and "very_fast" or "normal")
      ),
    favoriteUxMode = preferences.favoriteUxMode or "both",
    favoriteModKeys = preferences.favoriteModKeys or {},
    favoriteRevision = 0,
    showModProviderPrefix = preferences.showModProviderPrefix ~= false,
    listSelectionMode = preferences.listSelectionMode == "frame" and "frame" or "text",
    settingsSortMode = preferences.settingsSortMode or "file",
    defaultIndicatorMode = preferences.defaultIndicatorMode or "colored",
    modifiedOnly = false,
    presetNonDefaultOnly = preferences.presetNonDefaultOnly == true,
    showDescriptionPanel = preferences.showDescriptionPanel ~= false,
    layoutProfile = Host.normalizeProfile(preferences.layoutProfile),
    uiScale = Host.normalizeScale(preferences.uiScale),
    resolvedLayoutProfile = "full",
    uniformScale = 1.0,
    layoutOffsetX = 0,
    layoutOffsetY = 0,
    layoutCanvasWidth = Host.BASE_WIDTH,
    layoutCanvasHeight = Host.BASE_HEIGHT,
    autoApply = preferences.autoApply == true,
    themeColors = Theme.normalize(preferences.themeColors),
    settingsCategory = "general",
    renderQueued = false,
    textMeasurementRenderQueued = false,
    pendingRefresh = 0,
    hoveredSetting = nil,
    hoveredSidebarItem = nil,
    inputModalActive = false,
    suppressResetKeyRelease = false,
    scrollPositions = {},
    modSettingsScrollPositions = {},
    customHeights = {},
    apiSubscriptions = {},
    modelSyncQueued = false,
    viewportWidth = 1920,
    viewportHeight = 1080,
    scaleX = 1.0,
    scaleY = 1.0,
    hostLayout = Host.settings(Host.BASE_WIDTH, Host.BASE_HEIGHT, preferences),
  }
end

return State
