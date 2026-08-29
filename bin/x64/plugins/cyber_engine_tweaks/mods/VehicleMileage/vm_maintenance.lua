-- VehicleMileage/vm_maintenance.lua
-- Persistent per-vehicle maintenance intervals and overdue gas-tank failures.

local M = {
  opts = {},
  enabled = true,
  currentVehicleID = nil,
  currentVehicleState = nil,
  activeVehicleID = nil,
  activeVehicleState = nil,
  lastDecompressionEvent = 0,
  eventPollAcc = 0.0,
  lastForceDueCommand = 0,
  forceDuePollAcc = 0.0,
  heatWearVehicleID = nil,
  lastHeatWearMeters = nil,
  heatWearRemainder = 0.0,
}

local OVERDUE_MESSAGES = {
  "Zetatech inspection required. Proceed to a repair bay.",
  "Zetatech service interval exceeded. Visit a repair bay immediately.",
  "Vehicle compliance expired. Report to a Zetatech repair bay.",
  "Mandatory chassis inspection overdue. Repair-bay service required.",
  "Zetatech diagnostics: critical maintenance window missed.",
  "Service authorization expired. Take this vehicle to a repair bay.",
  "Inspection daemon rejected vehicle status. Maintenance required.",
  "Zetatech warning: fuel-system integrity inspection overdue.",
  "Vehicle maintenance overdue. Repair-bay inspection is mandatory.",
  "Compliance fault detected. Proceed to the nearest repair bay.",
}

local REWARD_MESSAGES = {
  "Zetatech service bonus: CHOOH2 gascan added to inventory.",
  "Maintenance reward received: 1 CHOOH2 gascan.",
  "Repair-bay loyalty reward: CHOOH2 gascan acquired.",
  "Inspection bonus issued: emergency CHOOH2 gascan.",
  "Zetatech maintenance reward transferred: 1 gascan.",
}

local SIMULATED_FAILURE_MESSAGES = {
  "Zetatech pressure fault detected. Fuel loss confirmed.",
  "Fuel-system rupture simulated: vehicle component telemetry unavailable.",
  "Zetatech warning: uncontained fuel loss detected.",
  "Inspection fault escalated. Emergency fuel venting registered.",
  "Vehicle pressure integrity failed. CHOOH2 reserves dropping.",
  "Maintenance failure pulse detected. Fuel-system loss recorded.",
}

local function clamp(value, minValue, maxValue)
  value = tonumber(value) or minValue
  if value < minValue then return minValue end
  if value > maxValue then return maxValue end
  return value
end

local function randomIntervalMeters()
  local minMeters = math.floor(tonumber(M.opts.min_interval_m) or 10000)
  local maxMeters = math.floor(tonumber(M.opts.max_interval_m) or 15000)

  if minMeters < 1 then minMeters = 1 end
  if maxMeters < minMeters then maxMeters = minMeters end

  return math.random(minMeters, maxMeters)
end

local function getFactInt(name)
  local ok, value = pcall(function()
    local questSystem = Game.GetQuestsSystem()
    if not questSystem then return 0 end
    return questSystem:GetFactStr(tostring(name))
  end)

  if ok then
    return math.max(0, math.floor(tonumber(value) or 0))
  end

  return 0
end

local function queueWarning(message)
  if type(M.opts.queueToast) == "function" then
    M.opts.queueToast(message)
    return
  end

  print("[VehicleMileage][Maintenance] " .. tostring(message))
end

local function showRewardMessage(message)
  if type(M.opts.showOnscreenMessage) == "function" then
    local ok = pcall(M.opts.showOnscreenMessage, message, 6.0)
    if ok then return end
  end

  local ok = pcall(function()
    local screenMessage = SimpleScreenMessage.new()
    screenMessage.message = tostring(message or "")
    screenMessage.isShown = true
    screenMessage.duration = 6.0

    local defs = GetAllBlackboardDefs()
    Game.GetBlackboardSystem()
      :Get(defs.UI_Notifications)
      :SetVariant(
        defs.UI_Notifications.OnscreenMessage,
        ToVariant(screenMessage),
        true
      )
  end)

  if not ok then
    print("[VehicleMileage][Maintenance] " .. tostring(message))
  end
end

local function setGasTankFX(enabled)
  local player = Game.GetPlayer()
  if not player then return false end

  if enabled then
    local ok, result = pcall(function()
      return player:VMGasTankFX_Enable()
    end)

    if not ok then
      print("[VehicleMileage][Maintenance] Could not enable VMGasTankFX: " .. tostring(result))
    end

    return ok
  end

  local ok, result = pcall(function()
    return player:VMGasTankFX_Disable()
  end)

  if not ok then
    print("[VehicleMileage][Maintenance] Could not disable VMGasTankFX: " .. tostring(result))
  end

  return ok
end

local function markDirty(vehicleID, vehicleState, force)
  if not M.opts.save or type(vehicleState) ~= "table" then return end

  vehicleState.last = os.time()
  M.opts.save.dirty = true

  if force and M.opts.save.syncVehicle then
    M.opts.save:syncVehicle(vehicleID, true)
  end
end

local function initializeDueAt(vehicleID, vehicleState)
  if type(vehicleState) ~= "table" then return 0 end

  local dueAt = math.floor(tonumber(vehicleState.maintenance_due_m) or 0)
  if dueAt > 0 then return dueAt end

  local meters = math.max(0, math.floor(tonumber(vehicleState.meters) or 0))
  dueAt = meters + randomIntervalMeters()
  vehicleState.maintenance_due_m = dueAt
  markDirty(vehicleID, vehicleState, true)

  return dueAt
end

local function resetHeatWear()
  M.heatWearVehicleID = nil
  M.lastHeatWearMeters = nil
  M.heatWearRemainder = 0.0
end

local function applyHeatWear(
  vehicleID,
  vehicleState,
  meters,
  temperatureC
)
  if M.heatWearVehicleID ~= vehicleID then
    M.heatWearVehicleID = vehicleID
    M.lastHeatWearMeters = meters
    M.heatWearRemainder = 0.0
    return
  end

  local previousMeters = tonumber(M.lastHeatWearMeters)
  M.lastHeatWearMeters = meters

  if previousMeters == nil or meters <= previousMeters then
    if previousMeters ~= nil and meters < previousMeters then
      M.heatWearRemainder = 0.0
    end
    return
  end

  temperatureC = tonumber(temperatureC)
  if temperatureC == nil then return end

  local multiplier = 1.0
  if temperatureC >= M.opts.heat_extreme_c then
    multiplier = M.opts.heat_extreme_multiplier
  elseif temperatureC >= M.opts.heat_warm_c then
    multiplier = M.opts.heat_warm_multiplier
  end

  multiplier = math.max(1.0, tonumber(multiplier) or 1.0)
  if multiplier <= 1.0 then return end

  local extraWear =
    ((meters - previousMeters) * (multiplier - 1.0))
      + M.heatWearRemainder
  local wholeExtraMeters = math.floor(extraWear)
  M.heatWearRemainder = extraWear - wholeExtraMeters

  if wholeExtraMeters < 1 then return end

  local dueAt =
    math.floor(tonumber(vehicleState.maintenance_due_m) or 0)
  if dueAt <= meters then return end

  local adjustedDueAt = math.max(meters, dueAt - wholeExtraMeters)
  if adjustedDueAt ~= dueAt then
    vehicleState.maintenance_due_m = adjustedDueAt
    markDirty(vehicleID, vehicleState, false)
  end
end

local function applyDecompressionLoss(vehicleID, vehicleState)
  if type(vehicleState) ~= "table" then return end

  -- Fuel is stored as a 0..1 tank fraction. A loss of 0.05..0.10 therefore
  -- removes five to ten percentage points of total tank capacity.
  local loss = math.random(50, 100) / 1000.0
  vehicleState.fuel_pct = clamp(
    (tonumber(vehicleState.fuel_pct) or 0.0) - loss,
    0.0,
    1.0
  )

  if vehicleState.fuel_pct <= 0.0 then
    vehicleState.fuel_pct = 0.0
    vehicleState.stalled = true
    vehicleState.limit_on = false
  end

  markDirty(vehicleID, vehicleState, true)

  if type(M.opts.setHudFuelPermille) == "function" then
    pcall(
      M.opts.setHudFuelPermille,
      math.floor((vehicleState.fuel_pct * 1000.0) + 0.5)
    )
  end

  if M.opts.debug then
    print(("[VehicleMileage][Maintenance] Decompression fuel loss: %.1f%% (%s)")
      :format(loss * 100.0, tostring(vehicleID)))
  end
end

local function consumeDecompressionEvents(force)
  if not force and M.eventPollAcc < 0.10 then
    return
  end

  M.eventPollAcc = 0.0
  local current = getFactInt(M.opts.decompression_fact)
  local previous = math.max(0, math.floor(tonumber(M.lastDecompressionEvent) or 0))

  -- A quest fact may be reset by a new game/session. Re-baseline without
  -- inventing an effect event.
  if current < previous then
    M.lastDecompressionEvent = current
    return
  end

  local count = current - previous
  M.lastDecompressionEvent = current

  if count <= 0 or not M.activeVehicleID or not M.activeVehicleState then
    return
  end

  local effectMode = getFactInt(M.opts.fx_mode_fact)

  for _ = 1, count do
    applyDecompressionLoss(M.activeVehicleID, M.activeVehicleState)

    if effectMode <= 0 then
      queueWarning(
        SIMULATED_FAILURE_MESSAGES[
          math.random(1, #SIMULATED_FAILURE_MESSAGES)
        ]
      )
    end
  end
end

local function addGascanReward()
  local count = math.max(1, math.floor(tonumber(M.opts.reward_count) or 1))
  local itemID = tostring(M.opts.reward_item_id or "Items.chooh2_gascan")

  local ok = pcall(function()
    Game.AddToInventory(itemID, count)
  end)

  if not ok then
    ok = pcall(function()
      local player = Game.GetPlayer()
      local transactionSystem = Game.GetTransactionSystem()
      local tweakID = TweakDBID.new(itemID)
      transactionSystem:GiveItem(
        player,
        ItemID.FromTDBID(tweakID),
        count
      )
    end)
  end

  return ok
end

function M.setIntervalRange(minMeters, maxMeters)
  minMeters = math.max(
    1,
    math.floor(tonumber(minMeters) or tonumber(M.opts.min_interval_m) or 10000)
  )
  maxMeters = math.max(
    minMeters,
    math.floor(tonumber(maxMeters) or tonumber(M.opts.max_interval_m) or 15000)
  )

  M.opts.min_interval_m = minMeters
  M.opts.max_interval_m = maxMeters

  return minMeters, maxMeters
end

function M.setup(opts)
  M.opts = opts or {}
  M.setIntervalRange(M.opts.min_interval_m, M.opts.max_interval_m)
  M.opts.reward_chance = tonumber(M.opts.reward_chance) or 0.25
  M.opts.critical_condition_pct =
    tonumber(M.opts.critical_condition_pct) or 20.0
  M.opts.heat_warm_c = tonumber(M.opts.heat_warm_c) or 34.0
  M.opts.heat_extreme_c = tonumber(M.opts.heat_extreme_c) or 37.0
  M.opts.heat_warm_multiplier =
    tonumber(M.opts.heat_warm_multiplier) or 1.5
  M.opts.heat_extreme_multiplier =
    tonumber(M.opts.heat_extreme_multiplier) or 2.0
  M.opts.reward_count = tonumber(M.opts.reward_count) or 1
  M.opts.reward_item_id = M.opts.reward_item_id or "Items.chooh2_gascan"
  M.opts.decompression_fact =
    M.opts.decompression_fact or "vm_maintenance_decompression_event"
  M.opts.force_due_fact =
    M.opts.force_due_fact or "vm_maintenance_force_due_cmd"
  M.opts.fx_mode_fact =
    M.opts.fx_mode_fact or "vm_maintenance_fx_mode"

  M.enabled = M.opts.enabled ~= false
  M.currentVehicleID = nil
  M.currentVehicleState = nil
  M.activeVehicleID = nil
  M.activeVehicleState = nil
  M.lastDecompressionEvent = getFactInt(M.opts.decompression_fact)
  M.eventPollAcc = 0.0
  M.lastForceDueCommand = getFactInt(M.opts.force_due_fact)
  M.forceDuePollAcc = 0.0
  resetHeatWear()
end

function M.onSessionStart(enabled)
  M.enabled = enabled ~= false
  M.currentVehicleID = nil
  M.currentVehicleState = nil
  M.activeVehicleID = nil
  M.activeVehicleState = nil
  M.lastDecompressionEvent = getFactInt(M.opts.decompression_fact)
  M.eventPollAcc = 0.0
  M.lastForceDueCommand = getFactInt(M.opts.force_due_fact)
  M.forceDuePollAcc = 0.0
  resetHeatWear()
  setGasTankFX(false)
end

function M.resetMounted()
  if M.activeVehicleID then
    -- Capture an effect event that may have fired since the last 0.10 s poll
    -- before clearing the vehicle association.
    consumeDecompressionEvents(true)
    setGasTankFX(false)
  end

  M.currentVehicleID = nil
  M.currentVehicleState = nil
  M.activeVehicleID = nil
  M.activeVehicleState = nil
  M.lastDecompressionEvent = getFactInt(M.opts.decompression_fact)
  M.eventPollAcc = 0.0
  M.lastForceDueCommand = getFactInt(M.opts.force_due_fact)
  M.forceDuePollAcc = 0.0
  resetHeatWear()
end

function M.onSessionEnd()
  M.resetMounted()
end

function M.setEnabled(enabled)
  M.enabled = enabled ~= false

  if not M.enabled then
    M.resetMounted()
  end
end

function M.update(dt, context)
  if not M.enabled then
    if M.activeVehicleID then M.resetMounted() end
    return false
  end

  context = context or {}

  local vehicleID = tostring(context.id or "")
  local vehicleState = context.state
  if vehicleID == "" or type(vehicleState) ~= "table" then
    M.resetMounted()
    return false
  end

  M.currentVehicleID = vehicleID
  M.currentVehicleState = vehicleState

  M.forceDuePollAcc =
    M.forceDuePollAcc + math.max(0.0, tonumber(dt) or 0.0)

  if M.forceDuePollAcc >= 0.10 then
    M.forceDuePollAcc = 0.0

    local forceCommand = getFactInt(M.opts.force_due_fact)

    if forceCommand < M.lastForceDueCommand then
      M.lastForceDueCommand = forceCommand
    elseif forceCommand > M.lastForceDueCommand then
      M.lastForceDueCommand = forceCommand
      M.forceCurrentDue()
    end
  end

  local dueAt = initializeDueAt(vehicleID, vehicleState)
  local meters = math.max(0, math.floor(tonumber(vehicleState.meters) or 0))
  applyHeatWear(
    vehicleID,
    vehicleState,
    meters,
    context.temperature_c
  )
  dueAt =
    math.floor(tonumber(vehicleState.maintenance_due_m) or dueAt)
  local conditionPct = tonumber(context.condition_pct)
  local criticalConditionPct =
    clamp(M.opts.critical_condition_pct, 0.0, 100.0)
  local criticalCondition =
    conditionPct ~= nil
      and conditionPct >= 0.0
      and conditionPct < criticalConditionPct
  local intervalOverdue = dueAt > 0 and meters >= dueAt

  if criticalCondition and not intervalOverdue then
    -- Zero marks an uninitialized deadline, so use 1 m for vehicles whose
    -- odometer is still at zero. The condition check below still activates
    -- maintenance immediately in that edge case.
    local forcedDueAt = math.max(1, meters)

    if dueAt ~= forcedDueAt then
      vehicleState.maintenance_due_m = forcedDueAt
      dueAt = forcedDueAt
      markDirty(vehicleID, vehicleState, true)
    end
  end

  local overdue =
    criticalCondition or (dueAt > 0 and meters >= dueAt)

  if not overdue then
    if M.activeVehicleID then M.resetMounted() end
    return false
  end

  if M.activeVehicleID ~= vehicleID then
    if M.activeVehicleID then
      -- Do not let a pending event from the previous vehicle get charged to
      -- the newly mounted one.
      consumeDecompressionEvents(true)
      setGasTankFX(false)
    end

    M.activeVehicleID = vehicleID
    M.activeVehicleState = vehicleState

    -- Ignore unrelated/manual VMGasTankFX uses that happened while no
    -- maintenance fault was associated with a vehicle.
    M.lastDecompressionEvent = getFactInt(M.opts.decompression_fact)
    M.eventPollAcc = 0.0

    setGasTankFX(true)
    queueWarning(OVERDUE_MESSAGES[math.random(1, #OVERDUE_MESSAGES)])

    -- Enable() plays decompression immediately, so consume its event in the
    -- same frame instead of waiting for the next update.
    consumeDecompressionEvents(true)
  else
    M.activeVehicleState = vehicleState
    M.eventPollAcc = M.eventPollAcc + math.max(0.0, tonumber(dt) or 0.0)
    consumeDecompressionEvents(false)
  end

  return true
end

function M.forceCurrentDue()
  if not M.enabled then
    return false, "Vehicle maintenance is disabled in Native Settings."
  end

  local vehicleID = M.currentVehicleID
  local vehicleState = M.currentVehicleState

  if not vehicleID or type(vehicleState) ~= "table" then
    return false, "Mount an owned vehicle, wait a moment, then run the command again."
  end

  local meters = math.max(0, math.floor(tonumber(vehicleState.meters) or 0))

  -- Zero is reserved for an uninitialized interval, so a brand-new vehicle
  -- with a 0 m odometer becomes due after its first meter.
  vehicleState.maintenance_due_m = math.max(1, meters)
  markDirty(vehicleID, vehicleState, true)

  if meters <= 0 then
    return true, "Maintenance forced. Drive at least 1 meter to trigger it."
  end

  return true, "Maintenance forced for " .. tostring(vehicleID) .. "."
end

function M.completeService(vehicleID, vehicleLabel, conditionPct)
  if not M.enabled or not M.opts.save then
    return false
  end

  vehicleID = tostring(vehicleID or vehicleLabel or "")
  if vehicleID == "" then return false end

  local vehicleState = M.opts.save:ensureVehicle(vehicleID)
  if not vehicleState then
    print("[VehicleMileage][Maintenance] Service completed, but vehicle state was unavailable: "
      .. tostring(vehicleID))
    return false
  end

  local meters = math.max(0, math.floor(tonumber(vehicleState.meters) or 0))
  local previousDueAt =
    math.max(0, math.floor(tonumber(vehicleState.maintenance_due_m) or 0))
  local criticalConditionPct =
    clamp(M.opts.critical_condition_pct, 0.0, 100.0)
  local criticalCondition =
    tonumber(conditionPct) ~= nil
      and tonumber(conditionPct) >= 0.0
      and tonumber(conditionPct) < criticalConditionPct
  local wasMaintenanceDue =
    criticalCondition
      or (previousDueAt > 0 and meters >= previousDueAt)

  vehicleState.maintenance_due_m = meters + randomIntervalMeters()
  markDirty(vehicleID, vehicleState, true)

  if M.activeVehicleID == vehicleID then
    M.resetMounted()
  end

  if wasMaintenanceDue then
    local rewardChance = clamp(M.opts.reward_chance, 0.0, 1.0)
    if math.random() < rewardChance and addGascanReward() then
      showRewardMessage(REWARD_MESSAGES[math.random(1, #REWARD_MESSAGES)])
    end
  end

  if M.opts.debug then
    print(("[VehicleMileage][Maintenance] Next service for %s at %.1f km")
      :format(
        tostring(vehicleLabel or vehicleID),
        vehicleState.maintenance_due_m / 1000.0
      ))
  end

  return true
end

function M.getStatus(vehicleState)
  local dueAt = math.floor(tonumber(
    vehicleState and vehicleState.maintenance_due_m
  ) or 0)

  return {
    enabled = M.enabled,
    active_vehicle_id = M.activeVehicleID,
    due_m = dueAt,
    overdue = dueAt > 0
      and math.floor(tonumber(vehicleState and vehicleState.meters) or 0) >= dueAt,
  }
end

return M
