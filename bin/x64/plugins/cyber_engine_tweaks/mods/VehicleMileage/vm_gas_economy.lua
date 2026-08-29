-- vm_gas_economy.lua
-- Virtual city-wide fuel demand, deliveries, shortages, and price pressure.
-- No NPC vehicle state is touched; NPC use is represented as hourly station
-- stock movement through vm_gas_station's synchronized API.

local M = {
  gas = nil,
  profiles = {},
  running = false,
  lastHour = nil,
  marketPrice = nil,
  priceMultiplier = 1.0,
  fillRatio = 0.0,
  shortageSeverity = 0, -- 0 normal, 1 minor, 2 severe
  shortageUntilHour = 0,
  hoursSimulated = 0,
}

local CFG = {
  density_radius_m = 1200.0,
  dense_neighbor_count = 6.0,
  max_catchup_hours = 168,

  -- Offsite -> dense city center.
  target_fill_offsite = 0.90,
  target_fill_city = 0.50,
  demand_fraction_offsite = 0.0018,
  demand_fraction_city = 0.0080,
  delivery_interval_offsite = 18,
  delivery_interval_city = 8,
  shipment_fraction_offsite = 0.14,
  shipment_fraction_city = 0.08,

  -- Normal operation settles slightly above this, so only a real network-wide
  -- shortage adds a scarcity premium.
  price_pressure_starts_below = 0.55,
}

local FACT_INITIALIZED = "vm_gas_economy_initialized"
local FACT_LAST_HOUR = "vm_gas_economy_last_hour"
local FACT_EVENT_SEVERITY = "vm_gas_economy_shortage_severity"
local FACT_EVENT_UNTIL = "vm_gas_economy_shortage_until_hour"
local FACT_FILL_PERMILLE = "vm_gas_economy_fill_permille"
local FACT_PRICE_PERMILLE = "vm_gas_economy_price_permille"

local function clamp(value, minimum, maximum)
  value = tonumber(value) or minimum
  if value < minimum then return minimum end
  if value > maximum then return maximum end
  return value
end

local function lerp(a, b, t)
  return a + ((b - a) * clamp(t, 0.0, 1.0))
end

local function round(value)
  return math.floor((tonumber(value) or 0) + 0.5)
end

local function noise01(a, b)
  local value = math.sin(
    ((tonumber(a) or 0) * 12.9898) + ((tonumber(b) or 0) * 78.233)
  ) * 43758.5453
  return value - math.floor(value)
end

local function questsSystem()
  local ok, system = pcall(function()
    return Game and Game.GetQuestsSystem and Game.GetQuestsSystem()
  end)
  return ok and system or nil
end

local function getFact(name, default)
  local qs = questsSystem()
  if not qs then return default or 0 end
  local ok, value = pcall(function() return qs:GetFactStr(name) end)
  if not ok then return default or 0 end
  return math.floor(tonumber(value) or default or 0)
end

local function setFact(name, value)
  local qs = questsSystem()
  if not qs then return false end
  value = math.floor(tonumber(value) or 0)
  return pcall(function() qs:SetFactStr(name, value) end)
end

local function gameHour()
  local ok, timeSystem = pcall(function()
    return (Game and Game.GetTimeSystem and Game.GetTimeSystem())
      or (GameInstance and GameInstance.GetTimeSystem
        and GameInstance.GetTimeSystem())
  end)
  if not ok or not timeSystem then return nil end

  local okTime, gameTime = pcall(function() return timeSystem:GetGameTime() end)
  if okTime and gameTime then
    local okDays, days = pcall(function() return gameTime:Days() end)
    local okHours, hours = pcall(function() return gameTime:Hours() end)
    if okDays and okHours and type(days) == "number"
       and type(hours) == "number" then
      return math.floor(days * 24 + hours)
    end

    local okSeconds, seconds = pcall(function() return gameTime:ToSeconds() end)
    if okSeconds and type(seconds) == "number" then
      return math.floor(seconds / 3600)
    end
  end

  local okSeconds, seconds = pcall(function()
    return timeSystem:GetGameTimeInSeconds()
  end)
  if okSeconds and type(seconds) == "number" then
    return math.floor(seconds / 3600)
  end

  return nil
end

local function buildProfiles()
  M.profiles = {}
  if not M.gas or type(M.gas.getStationStatus) ~= "function" then return end

  local stations = M.gas.getStationStatus()
  local radius2 = CFG.density_radius_m * CFG.density_radius_m

  for index, station in ipairs(stations) do
    local neighbors = 0
    for otherIndex, other in ipairs(stations) do
      if otherIndex ~= index then
        local dx = (station.x or 0) - (other.x or 0)
        local dy = (station.y or 0) - (other.y or 0)
        if ((dx * dx) + (dy * dy)) <= radius2 then
          neighbors = neighbors + 1
        end
      end
    end

    local urbanity = clamp(neighbors / CFG.dense_neighbor_count, 0.0, 1.0)
    M.profiles[index] = {
      index = index,
      neighbors = neighbors,
      urbanity = urbanity,
      profile = urbanity >= 0.67 and "city_center"
        or (urbanity >= 0.34 and "outer_district" or "offsite"),
      target_fill = lerp(
        CFG.target_fill_offsite,
        CFG.target_fill_city,
        urbanity
      ),
      demand_fraction = lerp(
        CFG.demand_fraction_offsite,
        CFG.demand_fraction_city,
        urbanity
      ),
      delivery_interval = math.max(1, round(lerp(
        CFG.delivery_interval_offsite,
        CFG.delivery_interval_city,
        urbanity
      ))),
      shipment_fraction = lerp(
        CFG.shipment_fraction_offsite,
        CFG.shipment_fraction_city,
        urbanity
      ),
    }
  end
end

local function supplyFactor()
  if M.shortageSeverity == 2 then return 0.18 end
  if M.shortageSeverity == 1 then return 0.55 end
  return 1.0
end

local function updateShortageEvent(hour)
  if M.shortageSeverity > 0 and hour >= M.shortageUntilHour then
    M.shortageSeverity = 0
    M.shortageUntilHour = 0
  end

  -- One deterministic daily supply roll at 04:00.
  if M.shortageSeverity == 0 and (hour % 24) == 4 then
    local roll = noise01(hour, 991)
    if roll < 0.03 then
      M.shortageSeverity = 2
      M.shortageUntilHour = hour + 36 + round(noise01(hour, 992) * 60)
    elseif roll < 0.12 then
      M.shortageSeverity = 1
      M.shortageUntilHour = hour + 18 + round(noise01(hour, 993) * 30)
    end
  end
end

local function persistShortageEvent()
  local severityWritten = setFact(FACT_EVENT_SEVERITY, M.shortageSeverity)
  local untilWritten = setFact(FACT_EVENT_UNTIL, M.shortageUntilHour)
  return severityWritten and untilWritten
end

local function trafficMultiplier(profile, hourOfDay)
  if profile.urbanity >= 0.50 then
    if (hourOfDay >= 6 and hourOfDay <= 9)
       or (hourOfDay >= 16 and hourOfDay <= 20) then
      return 1.45
    end
    if hourOfDay >= 1 and hourOfDay <= 5 then return 0.55 end
    return 1.0
  end

  -- Freight and long-distance traffic keep offsite stations active at night.
  if hourOfDay >= 20 or hourOfDay <= 4 then return 1.15 end
  return 0.85
end

local function loadNetwork()
  local stations = M.gas.getStationStatus()
  local stocks = {}

  for index, station in ipairs(stations) do
    stocks[index] = clamp(
      station.available_l,
      0,
      math.max(0, tonumber(station.capacity_l) or 0)
    )
  end

  return stations, stocks
end

local function commitNetwork(stations, stocks)
  local applied = {}

  for index, station in ipairs(stations) do
    local capacity = math.max(0, tonumber(station.capacity_l) or 0)
    local liters = round(clamp(stocks[index], 0, capacity))
    local original = math.floor(tonumber(station.available_l) or 0)
    if liters ~= original then
      local written = M.gas.setStationFuel(index, liters)
      if not written then
        for _, change in ipairs(applied) do
          M.gas.setStationFuel(change.index, change.original)
        end
        return false, {}
      end
      applied[#applied + 1] = { index = index, original = original }
    end
  end

  return true, applied
end

local function rollbackNetwork(applied)
  for _, change in ipairs(applied or {}) do
    M.gas.setStationFuel(change.index, change.original)
  end
end

local function simulateHour(hour, stations, stocks)
  local hourOfDay = hour % 24
  local supply = supplyFactor()

  for index, station in ipairs(stations) do
    local profile = M.profiles[index]
    if profile then
      local capacity = math.max(0, tonumber(station.capacity_l) or 0)
      local available = clamp(stocks[index], 0, capacity)

      -- Aggregate virtual NPC purchases. Variation is deterministic for this
      -- station/hour, so save reloads cannot reroll demand.
      local demandVariation = 0.75 + (noise01(hour, index * 17) * 0.50)
      local demand = round(
        capacity
        * profile.demand_fraction
        * trafficMultiplier(profile, hourOfDay)
        * demandVariation
      )
      available = math.max(0, available - demand)

      -- Deliveries are smaller/frequent downtown and larger/less frequent in
      -- offsite districts. Supply events reduce the shipment, not stored fuel.
      local offset = index % profile.delivery_interval
      if ((hour + offset) % profile.delivery_interval) == 0 then
        local target = round(capacity * profile.target_fill)
        if available < target then
          local shipmentVariation = 0.85 + (noise01(hour, index * 29) * 0.30)
          local shipment = round(
            capacity * profile.shipment_fraction * supply * shipmentVariation
          )
          available = math.min(target, available + shipment)
        end
      end

      stocks[index] = available
    end
  end

  M.hoursSimulated = M.hoursSimulated + 1
end

local function refreshMetrics()
  local stations = M.gas and M.gas.getStationStatus
    and M.gas.getStationStatus() or {}
  local totalAvailable, totalCapacity = 0, 0

  for _, station in ipairs(stations) do
    totalAvailable = totalAvailable + math.max(0, station.available_l or 0)
    totalCapacity = totalCapacity + math.max(0, station.capacity_l or 0)
  end

  M.fillRatio = totalCapacity > 0 and (totalAvailable / totalCapacity) or 0.0
  local threshold = CFG.price_pressure_starts_below
  local pressure = threshold > 0
    and clamp((threshold - M.fillRatio) / threshold, 0.0, 1.0) or 0.0
  M.priceMultiplier = 1.0 + pressure

  setFact(FACT_FILL_PERMILLE, round(M.fillRatio * 1000))
  setFact(FACT_PRICE_PERMILLE, round(M.priceMultiplier * 1000))
end

local function initializeStocks(hour)
  local stations = M.gas.getStationStatus()
  local initialized = true
  for index, station in ipairs(stations) do
    local profile = M.profiles[index]
    if profile and (tonumber(station.available_l) or 0) <= 0 then
      local variation = 0.92 + (noise01(hour, index * 43) * 0.12)
      local liters = round(station.capacity_l * profile.target_fill * variation)
      if not M.gas.setStationFuel(index, liters) then initialized = false end
    end
  end

  return initialized and setFact(FACT_INITIALIZED, 1)
end

function M.setup(options)
  options = options or {}
  M.gas = options.gas or M.gas
  for key, value in pairs(options.config or {}) do
    if CFG[key] ~= nil then CFG[key] = value end
  end
  buildProfiles()
end

function M.start()
  if not M.gas then return false end
  if #M.profiles == 0 then buildProfiles() end

  local now = gameHour()
  if now == nil then return false end

  M.shortageSeverity = clamp(getFact(FACT_EVENT_SEVERITY, 0), 0, 2)
  M.shortageUntilHour = math.max(0, getFact(FACT_EVENT_UNTIL, 0))
  if M.shortageSeverity > 0 and now >= M.shortageUntilHour then
    M.shortageSeverity = 0
    M.shortageUntilHour = 0
    if not persistShortageEvent() then return false end
  end

  if getFact(FACT_INITIALIZED, 0) == 0 then
    if not initializeStocks(now) then return false end
  end

  M.lastHour = getFact(FACT_LAST_HOUR, now)
  if M.lastHour <= 0 or M.lastHour > now then M.lastHour = now end
  if not setFact(FACT_LAST_HOUR, M.lastHour) then return false end
  M.running = true
  M.update()
  return true
end

function M.stop()
  M.running = false
  M.lastHour = nil
  M.marketPrice = nil
  M.priceMultiplier = 1.0
  M.fillRatio = 0.0
  M.shortageSeverity = 0
  M.shortageUntilHour = 0
  M.hoursSimulated = 0
end

function M.update()
  if not M.running or not M.gas then return false, 0 end
  local now = gameHour()
  if now == nil then return false, 0 end

  local previousMultiplier = M.priceMultiplier
  local previousSeverity = M.shortageSeverity
  local previousUntilHour = M.shortageUntilHour
  local previousHoursSimulated = M.hoursSimulated

  local fromHour = M.lastHour or now
  if fromHour > now then fromHour = now end
  if (now - fromHour) > CFG.max_catchup_hours then
    fromHour = now - CFG.max_catchup_hours
  end

  local processed = 0
  local stations, stocks
  if fromHour < now then
    stations, stocks = loadNetwork()
  end

  for hour = fromHour + 1, now do
    updateShortageEvent(hour)
    simulateHour(hour, stations, stocks)
    processed = processed + 1
  end

  if processed > 0 then
    local committed, applied = commitNetwork(stations, stocks)
    local eventWritten = committed and persistShortageEvent()
    local cursorWritten = eventWritten and setFact(FACT_LAST_HOUR, now)

    if not cursorWritten then
      rollbackNetwork(applied)
      M.shortageSeverity = previousSeverity
      M.shortageUntilHour = previousUntilHour
      M.hoursSimulated = previousHoursSimulated
      persistShortageEvent()
      refreshMetrics()
      return false, 0
    end
  end

  M.lastHour = now
  refreshMetrics()
  local metricsChanged = math.abs(M.priceMultiplier - previousMultiplier) >= 0.0005
  return processed > 0 or metricsChanged, processed
end

function M.getPriceMultiplier()
  return clamp(M.priceMultiplier, 1.0, 2.0)
end

function M.setMarketPrice(price)
  M.marketPrice = math.max(0, tonumber(price) or 0)
end

function M.getMarketPrice(fallback)
  return tonumber(M.marketPrice) or tonumber(fallback) or 0
end

function M.getStatus()
  local remaining = math.max(0, (M.shortageUntilHour or 0) - (M.lastHour or 0))
  return {
    running = M.running,
    fill_ratio = M.fillRatio,
    price_multiplier = M.getPriceMultiplier(),
    shortage_severity = M.shortageSeverity,
    shortage_hours_remaining = remaining,
    last_hour = M.lastHour,
    hours_simulated = M.hoursSimulated,
    station_count = #M.profiles,
    profiles = M.profiles,
  }
end

function M.triggerShortage(severity, hours)
  if type(severity) == "string" then
    local name = severity:lower()
    severity = name == "severe" and 2 or (name == "minor" and 1 or 0)
  end
  severity = math.floor(clamp(severity, 0, 2))
  hours = math.max(1, math.floor(tonumber(hours) or (severity == 2 and 48 or 24)))

  local previousSeverity = M.shortageSeverity
  local previousUntilHour = M.shortageUntilHour
  local now = gameHour() or M.lastHour or 0
  M.shortageSeverity = severity
  M.shortageUntilHour = severity > 0 and (now + hours) or 0
  if not persistShortageEvent() then
    M.shortageSeverity = previousSeverity
    M.shortageUntilHour = previousUntilHour
    persistShortageEvent()
    return false, previousSeverity, previousUntilHour
  end
  return true, M.shortageSeverity, M.shortageUntilHour
end

function M.simulateHours(hours)
  if not M.running then return 0 end
  hours = math.max(0, math.min(CFG.max_catchup_hours, math.floor(tonumber(hours) or 0)))
  if hours == 0 then return 0 end

  local startHour = M.lastHour or gameHour() or 0
  local previousSeverity = M.shortageSeverity
  local previousUntilHour = M.shortageUntilHour
  local previousHoursSimulated = M.hoursSimulated
  local stations, stocks = loadNetwork()
  for offset = 1, hours do
    local hour = startHour + offset
    updateShortageEvent(hour)
    simulateHour(hour, stations, stocks)
  end

  -- This is a test accelerator, not a game-clock change. Rebase any event's
  -- remaining duration onto the real economy hour instead of persisting a
  -- future last-hour value that would block normal updates.
  if M.shortageSeverity > 0 then
    local remaining = math.max(0, M.shortageUntilHour - (startHour + hours))
    if remaining > 0 then
      M.shortageUntilHour = startHour + remaining
    else
      M.shortageSeverity = 0
      M.shortageUntilHour = 0
    end
  end

  local committed, applied = commitNetwork(stations, stocks)
  local eventWritten = committed and persistShortageEvent()
  if not eventWritten then
    rollbackNetwork(applied)
    M.shortageSeverity = previousSeverity
    M.shortageUntilHour = previousUntilHour
    M.hoursSimulated = previousHoursSimulated
    persistShortageEvent()
    refreshMetrics()
    return 0
  end

  refreshMetrics()
  return hours
end

return M
