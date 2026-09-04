local Host = require("mcm_ui/mcm_host")

local Layout = {}

Layout.BASE_WIDTH = Host.BASE_WIDTH
Layout.BASE_HEIGHT = Host.BASE_HEIGHT
Layout.ACTION_GAP = 20
Layout.BOTTOM_ACTION_ROW_STEP = 54
Layout.SIDEBAR_PROVIDER_WIDTH = 40
Layout.SIDEBAR_PROVIDER_GAP = 0
Layout.ACTION_FALLBACK_WIDTH = 180
Layout.MODAL = {
  messageFontSize = 21,
  messageMinHeight = 32,
}

local metricIds = {
  contractVersion = 0,
  profileCode = 1,
  uniformScale = 2,
  offsetX = 3,
  offsetY = 4,
  canvasWidth = 5,
  canvasHeight = 6,
  sidebarX = 10,
  sidebarWidth = 11,
  sidebarHeight = 12,
  sidebarInnerWidth = 13,
  sidebarRowHeight = 14,
  contentX = 20,
  contentWidth = 21,
  contentHeight = 22,
  contentInnerWidth = 23,
  contentRowHeight = 24,
  descriptionWidth = 25,
  descriptionHeight = 26,
  bottomActionY = 27,
  actionRightX = 28,
  modalMessageWidth = 29,
  messageInsetX = 30,
  messagePaddingY = 31,
  messageFontSize = 32,
  topActionMinX = 40,
  topActionY = 41,
  topActionMaxWidth = 42,
}

Layout.profiles = {
  mods = { sidebar = true, content = true, description = true },
  settings = { sidebar = true, content = true, description = true },
  mod_presets = {
    sidebar = true,
    content = true,
    description = false,
    bottomActionRows = 1,
  },
  collections = {
    sidebar = true,
    content = true,
    description = false,
    bottomActionRows = 1,
    sidebarActionRows = 2,
  },
}

local function copyMap(value)
  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

Layout.currentProfile = copyMap(Layout.profiles.mods)
Layout.metrics = nil
Layout.resolved = nil

function Layout.applyProfile(view, options)
  local profile = copyMap(Layout.profiles[view] or Layout.profiles.mods)
  if type(options) == "table" and options.description == false then
    profile.description = false
  end
  if type(options) == "table" and tonumber(options.bottomActionRows) ~= nil then
    profile.bottomActionRows = math.max(1, tonumber(options.bottomActionRows))
  end

  Layout.currentProfile = profile
  return profile
end

local function readMetric(controller, id)
  local ok, value = pcall(function()
    return controller:McmUiGetLayoutMetric(id)
  end)
  value = ok and tonumber(value) or nil
  if value == nil or value ~= value or value == math.huge or value == -math.huge then
    return nil
  end
  return value
end

function Layout.syncFromController(controller)
  if not IsDefined(controller) then
    return nil
  end

  local values = {}
  for key, id in pairs(metricIds) do
    values[key] = readMetric(controller, id)
    if values[key] == nil then
      return nil
    end
  end
  if
    values.contractVersion ~= 1
    or values.profileCode < Host.PROFILES.full
    or values.profileCode > Host.PROFILES.compact
    or values.uniformScale <= 0
    or values.offsetX < 0
    or values.offsetY < 0
    or values.canvasWidth <= 0
    or values.canvasHeight <= 0
    or values.sidebarX < 0
    or values.sidebarWidth <= 0
    or values.sidebarHeight <= 0
    or values.sidebarInnerWidth <= 0
    or values.sidebarRowHeight <= 0
    or values.contentX < 0
    or values.contentWidth <= 0
    or values.contentHeight <= 0
    or values.contentInnerWidth <= 0
    or values.contentRowHeight <= 0
    or values.descriptionWidth < 0
    or values.descriptionHeight <= 0
    or values.bottomActionY < 0
    or values.actionRightX <= 0
    or values.modalMessageWidth <= 0
    or values.messageInsetX < 0
    or values.messagePaddingY < 0
    or values.messageFontSize <= 0
    or values.topActionMinX < 0
    or values.topActionY < 0
    or values.topActionMaxWidth <= 0
  then
    return nil
  end

  Layout.metrics = {
    leftListW = values.sidebarInnerWidth,
    leftRowH = values.sidebarRowHeight,
    leftScrollH = values.sidebarHeight,
    settingsX = values.contentX,
    settingsW = values.contentInnerWidth,
    settingsRowH = values.contentRowHeight,
    settingsScrollH = values.contentHeight,
    settingsMessagePaddingX = values.messageInsetX,
    settingsMessagePaddingY = values.messagePaddingY,
    settingsMessageFontSize = values.messageFontSize,
    descriptionW = values.descriptionWidth,
    descriptionH = values.descriptionHeight,
    bottomActionY = values.bottomActionY,
  }
  Layout.ACTION_RIGHT_X = values.actionRightX
  Layout.CONTENT_ACTION_RIGHT_X = values.contentX + values.contentInnerWidth
  Layout.SIDEBAR_ACTION_X = values.sidebarX
  Layout.SIDEBAR_ACTION_WIDTH = values.sidebarWidth
  Layout.TOP_ACTION_MIN_X = values.topActionMinX
  Layout.TOP_ACTION_Y = values.topActionY
  Layout.TOP_ACTION_MAX_WIDTH = values.topActionMaxWidth
  Layout.MODAL.messageWidth = values.modalMessageWidth
  Layout.currentProfile.description = values.descriptionWidth > 1

  Layout.resolved = {
    profileCode = math.floor(values.profileCode),
    uniformScale = values.uniformScale,
    offsetX = values.offsetX,
    offsetY = values.offsetY,
    canvasWidth = values.canvasWidth,
    canvasHeight = values.canvasHeight,
    descriptionVisible = values.descriptionWidth > 1,
  }
  return Layout.resolved
end

function Layout.rightAlignedX(width, rightX)
  return (rightX or Layout.ACTION_RIGHT_X) - width
end

function Layout.sidebarPreset(options)
  options = options or {}
  local providerColumn = options.providerColumn == true
  local providerWidth = providerColumn and Layout.SIDEBAR_PROVIDER_WIDTH or 0
  local providerGap = providerColumn and Layout.SIDEBAR_PROVIDER_GAP or 0

  return {
    providerColumn = providerColumn,
    providerX = 0,
    providerW = providerWidth,
    labelX = providerWidth + providerGap,
    labelW = Layout.metrics.leftListW - providerWidth - providerGap,
  }
end

return Layout
