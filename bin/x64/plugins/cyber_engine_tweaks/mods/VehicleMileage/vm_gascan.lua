-- vm_gascan.lua
-- VehicleMileage 0-Engine - CHOOH2 Gascan inventory-consume bridge.
--
-- Redscript increments a pending quest fact when the custom item is consumed.
-- 0-Engine MenuClose processes that pending item after the inventory closes.

local M = {
  opts = {},
}

local function clamp(value, minValue, maxValue)
  value = tonumber(value) or minValue
  if value < minValue then return minValue end
  if value > maxValue then return maxValue end
  return value
end

local function getQuestSystem()
  local ok, system = pcall(function()
    return Game.GetQuestsSystem()
  end)

  return ok and system or nil
end

local function getFactInt(name)
  local system = getQuestSystem()
  if not system then return 0 end

  local ok, value = pcall(function()
    return system:GetFactStr(tostring(name))
  end)

  if ok then
    return math.max(0, math.floor(tonumber(value) or 0))
  end

  return 0
end

local function setFactInt(name, value)
  local system = getQuestSystem()
  if not system then return false end

  value = math.floor(tonumber(value) or 0)

  local ok = pcall(function()
    system:SetFactStr(tostring(name), value)
  end)

  if ok then return true end

  return pcall(function()
    local cname = (CName and CName.new and CName.new(name)) or name
    system:SetFact(cname, value)
  end)
end

local function queueToast(message)
  if M.opts.queueToast then
    M.opts.queueToast(message)
    return
  end

  print("[VehicleMileage][Gascan] " .. tostring(message))
end

local function addItemToInventory(count)
  count = math.floor(tonumber(count) or 0)
  if count <= 0 then return true end

  local ok = pcall(function()
    Game.AddToInventory(M.opts.item_id, count)
  end)

  if ok then return true end

  return pcall(function()
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    local tweakID = TweakDBID.new(M.opts.item_id)
    local itemID = ItemID.FromTDBID(tweakID)

    transactionSystem:GiveItem(player, itemID, count)
  end)
end

local function returnItems(count, message)
  addItemToInventory(count)
  queueToast(message)
end

local function playSound()
  local eventName = tostring(M.opts.sound_event or "")
  if eventName == "" then return end

  local ok, audioSystem = pcall(function()
    if GameInstance and GameInstance.GetAudioSystem then
      return GameInstance.GetAudioSystem()
    end

    if Game and Game.GetAudioSystem then
      return Game.GetAudioSystem()
    end

    return nil
  end)

  if not ok or not audioSystem then return end

  pcall(function()
    audioSystem:Play(eventName)
  end)
end

local function isOwnedVehicle(vehicle, label)
  local ok, owned = pcall(function()
    return vehicle:IsPlayerVehicle()
  end)

  if ok and owned then
    return true
  end

  if M.opts.isOwnedViaUnlockedList then
    local fallbackOK, fallbackOwned = pcall(M.opts.isOwnedViaUnlockedList, label)
    return fallbackOK and fallbackOwned == true
  end

  return false
end

local function pluralGascan(count)
  return count == 1 and "gascan" or "gascans"
end

function M.setup(opts)
  M.opts = opts or {}
  M.opts.pending_fact = M.opts.pending_fact or "elm_chooh2_gascan_pending"
  M.opts.item_id = M.opts.item_id or "Items.chooh2_gascan"
  M.opts.liters_per_item = tonumber(M.opts.liters_per_item) or 10.0
  M.opts.sound_event = M.opts.sound_event or "gascan_refuel"
end

function M.OnSessionStart()
  setFactInt(M.opts.pending_fact, 0)
end

function M.OnMenuClose()
  -- 0-Engine's MenuClose subscription used by this mod does not need a
  -- GameUI state object. The pending fact is the event guard.
  local pendingCount = getFactInt(M.opts.pending_fact)
  if pendingCount <= 0 then
    return
  end

  local player = Game.GetPlayer()
  if not player then
    return
  end

  -- Clear first so the same MenuClose cannot process the items twice.
  setFactInt(M.opts.pending_fact, 0)

  local vehicle = player:GetMountedVehicle()
  if not vehicle then
    returnItems(
      pendingCount,
      string.format(
        "CHOOH2 %s returned: enter one of your vehicles before using it.",
        pluralGascan(pendingCount)
      )
    )
    return
  end

  if not M.opts.vehKeyAndLabel or not M.opts.getSpecs or not M.opts.save then
    returnItems(pendingCount, "CHOOH2 gascan returned: VehicleMileage is not ready.")
    return
  end

  local vehicleID, vehicleLabel = M.opts.vehKeyAndLabel(vehicle)

  if not isOwnedVehicle(vehicle, vehicleLabel) then
    returnItems(
      pendingCount,
      string.format(
        "CHOOH2 %s returned: this is not a player-owned vehicle.",
        pluralGascan(pendingCount)
      )
    )
    return
  end

  if M.opts.isIgnored then
    local ignoredOK, ignored = pcall(M.opts.isIgnored, vehicleLabel)
    if ignoredOK and ignored then
      returnItems(pendingCount, "CHOOH2 gascan returned: this vehicle is ignored by VehicleMileage.")
      return
    end
  end

  local vehicleState = M.opts.save:ensureVehicle(vehicleID)
  local specs = M.opts.getSpecs(vehicleLabel)
  local tankLiters = tonumber(specs and specs.tank_l) or 0.0

  if not vehicleState or tankLiters <= 0.0 then
    returnItems(pendingCount, "CHOOH2 gascan returned: the vehicle fuel data is unavailable.")
    return
  end

  local fuelPct = clamp(vehicleState.fuel_pct, 0.0, 1.0)
  local currentLiters = fuelPct * tankLiters
  local freeLiters = math.max(0.0, tankLiters - currentLiters)

  if freeLiters <= 0.001 then
    returnItems(pendingCount, "CHOOH2 gascan returned: the fuel tank is already full.")
    return
  end

  local litersPerItem = math.max(0.001, M.opts.liters_per_item)
  local requestedLiters = litersPerItem * pendingCount
  local addedLiters = math.min(requestedLiters, freeLiters)
  local usedCount = math.max(1, math.ceil((addedLiters - 0.001) / litersPerItem))
  usedCount = math.min(pendingCount, usedCount)

  local returnedCount = pendingCount - usedCount
  local newLiters = math.min(tankLiters, currentLiters + addedLiters)
  local newFuelPct = clamp(newLiters / tankLiters, 0.0, 1.0)
  local newPermille = math.floor((newFuelPct * 1000.0) + 0.5)

  vehicleState.fuel_pct = newFuelPct
  vehicleState.stalled = false
  vehicleState.limit_on = false
  vehicleState.last = os.time()

  M.opts.save.dirty = true
  M.opts.save:syncVehicle(vehicleID, true)

  if M.opts.setFactInt and M.opts.hud_fuel_fact then
    M.opts.setFactInt(M.opts.hud_fuel_fact, newPermille)
  end

  if returnedCount > 0 then
    addItemToInventory(returnedCount)
  end

  playSound()

  local message = string.format("CHOOH2 Gascan: %.1f L added to the fuel tank.", addedLiters)

  if newFuelPct >= 0.999 then
    message = message .. " Tank is full."
  end

  if returnedCount > 0 then
    message = message .. string.format(
      " %d unused %s returned.",
      returnedCount,
      pluralGascan(returnedCount)
    )
  end

  queueToast(message)
end

return M
