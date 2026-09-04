local Host = {}

Host.BASE_WIDTH = 1920
Host.BASE_HEIGHT = 1080
Host.DEFAULT_PROFILE = "auto"
Host.DEFAULT_SCALE = 1.0

Host.PROFILES = {
  auto = 0,
  full = 1,
  medium = 2,
  compact = 3,
}

Host.PROFILE_ORDER = { "auto", "full", "medium", "compact" }
Host.SCALE_VALUES = { 0.75, 0.85, 1.0, 1.15, 1.25 }

local function finitePositive(value, fallback)
  value = tonumber(value)
  if value == nil or value <= 0 or value ~= value or value == math.huge then
    return fallback
  end
  return value
end

local function nonNegative(value)
  value = tonumber(value) or 0
  if value < 0 or value ~= value or value == math.huge then
    return 0
  end
  return value
end

function Host.normalizeProfile(value)
  return Host.PROFILES[value] ~= nil and value or Host.DEFAULT_PROFILE
end

function Host.profileCode(value)
  return Host.PROFILES[Host.normalizeProfile(value)]
end

function Host.profileAt(index)
  index = math.max(1, math.min(#Host.PROFILE_ORDER, math.floor(tonumber(index) or 1)))
  return Host.PROFILE_ORDER[index]
end

function Host.profileIndex(value)
  value = Host.normalizeProfile(value)
  for index, profile in ipairs(Host.PROFILE_ORDER) do
    if profile == value then
      return index
    end
  end
  return 1
end

function Host.normalizeScale(value)
  value = finitePositive(value, Host.DEFAULT_SCALE)
  local result = Host.DEFAULT_SCALE
  local distance = math.huge
  for _, candidate in ipairs(Host.SCALE_VALUES) do
    local candidateDistance = math.abs(candidate - value)
    if candidateDistance < distance then
      distance = candidateDistance
      result = candidate
    end
  end
  return result
end

function Host.scaleAt(index)
  index = math.max(1, math.min(#Host.SCALE_VALUES, math.floor(tonumber(index) or 3)))
  return Host.SCALE_VALUES[index]
end

function Host.scaleIndex(value)
  value = Host.normalizeScale(value)
  for index, scale in ipairs(Host.SCALE_VALUES) do
    if scale == value then
      return index
    end
  end
  return 3
end

function Host.describe(options)
  options = type(options) == "table" and options or {}
  local width = finitePositive(options.width, Host.BASE_WIDTH)
  local height = finitePositive(options.height, Host.BASE_HEIGHT)
  local safeLeft = nonNegative(options.safeLeft)
  local safeTop = nonNegative(options.safeTop)
  local safeRight = nonNegative(options.safeRight)
  local safeBottom = nonNegative(options.safeBottom)
  if safeLeft + safeRight >= width then
    safeLeft = 0
    safeRight = 0
  end
  if safeTop + safeBottom >= height then
    safeTop = 0
    safeBottom = 0
  end

  return {
    width = width,
    height = height,
    safeLeft = safeLeft,
    safeTop = safeTop,
    safeRight = safeRight,
    safeBottom = safeBottom,
    density = finitePositive(options.density, 1.0),
    requestedScale = Host.normalizeScale(options.requestedScale),
    requestedProfile = Host.normalizeProfile(options.requestedProfile),
    requestedProfileCode = Host.profileCode(options.requestedProfile),
  }
end

function Host.settings(width, height, state)
  width = finitePositive(width, Host.BASE_WIDTH)
  height = finitePositive(height, Host.BASE_HEIGHT)
  state = type(state) == "table" and state or {}
  local requestedProfile = Host.normalizeProfile(state.layoutProfile)
  if requestedProfile == "auto" then
    requestedProfile = state.gameplayEntry == true and "compact" or "full"
  end
  return Host.describe({
    width = width,
    height = height,
    density = math.min(width / Host.BASE_WIDTH, height / Host.BASE_HEIGHT),
    requestedScale = state.uiScale,
    requestedProfile = requestedProfile,
  })
end

return Host
