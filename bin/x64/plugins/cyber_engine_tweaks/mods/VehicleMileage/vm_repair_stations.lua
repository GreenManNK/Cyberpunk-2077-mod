-- VehicleMileage/vm_repair_stations.lua
-- Repair-zone detector.
-- V11
local M = {}

local opts = {
  points_path = "vm_repair_stations.json",
  radius      = 5.0,
  debug       = false,
  wait_seconds = 3.0,
  automatic_wait_seconds = 5.0,

  -- Used only when an old repair-zone record has no "price"
  default_repair_price = 500,

	-- injected from init.lua
	queueToast = nil,
	vehKeyAndLabel = nil,
	vehicleTypeForLabel = nil,
	isAutomaticRepairEnabled = nil,

  -- Called only after the repaired garage vehicle has actually spawned.
  onRepairCompleted = nil,

	-- optional ownership gate from init.lua
	-- must return true only for player-owned vehicles
	isVehicleOwned = nil,

  -- From Native Settings.
  -- 0 = normal price, -50 = 50% cheaper, +2000 = 21x price
  getRepairPriceAdjustPct = nil,

  -- Injected from init.lua.
  -- Must be read while player is still mounted because vm_hud_vehicle_cond_pct
  -- becomes -1 after exiting the vehicle.
  getVehicleConditionPct = nil,
}

local points = {}

-- state
local armedRepair = nil
local lastInsideIdx = nil
-- After one repair completes, player must leave the repair zone
-- before another repair can be armed.
local mustLeaveRepairZone = false
local mustLeaveToastShown = false
-- Active garage spawn watcher after repair.
local spawnWatch = nil
-- Currently active FX point.
-- This can be stage 1 FX or completed FX.
local activeRepairFxPoint = nil
-- QA drone should start only after repair is complete
-- and the player leaves the repair zone with the vehicle.
local pendingDroneOrbitAfterRepair = false
-- Redscript drone orbit command bridge.
-- Incrementing this fact starts the QA drone orbit system.
local droneOrbitCmd = 0
-- One-shot FX reset when approaching a repair bay.
-- Runs once per near repair bay area, then resets after leaving the near area.
local lastNearFxResetIdx = nil
local REPAIR_FX_NEAR_RADIUS = 50.0
local REPAIR_UNMOUNT_SETTLE_SECONDS = 0.4
local REPAIR_UNMOUNT_TIMEOUT_SECONDS = 2.0
local REPAIR_DESPAWN_TIMEOUT_SECONDS = 4.0
local REPAIR_SPAWN_TIMEOUT_SECONDS = 8.0
local REPAIR_MOUNT_TIMEOUT_SECONDS = 2.0
local REPAIR_SETTLE_PASSES = 4

local function cleanVehicleRecordID(s)
  s = tostring(s or "")

  -- Extract Vehicle.xxx from CET debug strings like:
  -- ToTweakDBID{ hash = ... --[[ Vehicle.v_sport1_quadra_turbo_r_player --]] }
  local veh = s:match("(Vehicle%.[%w_%.%-]+)")
  if veh and #veh > 0 then
    return veh
  end

  -- fallback: trim only
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end


local function toast(msg)
  if type(opts.queueToast) == "function" then
    opts.queueToast(msg)
  else
    print("[VehicleMileage][Repair] " .. tostring(msg))
  end
end

local function automaticRepairEnabled()
  if type(opts.isAutomaticRepairEnabled) == "function" then
    local ok, enabled = pcall(opts.isAutomaticRepairEnabled)
    if ok then
      return enabled == true
    end
  end

  return false
end

local function readFile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function writeFile(path, data)
  local f = io.open(path, "w")
  if not f then return false end
  f:write(data or "")
  f:close()
  return true
end

local function ensureFile(path)
  local raw = readFile(path)
  if raw == nil then
    writeFile(path, "[]\n")
    return "[]"
  end
  return raw
end

local function loadPoints()
  points = {}

  local path = opts.points_path or "vm_repair_stations.json"
  local raw = ensureFile(path) or "[]"

  for body in raw:gmatch("{(.-)}") do
    local x = tonumber(body:match('"x"%s*:%s*([%-%.%d]+)'))
    local y = tonumber(body:match('"y"%s*:%s*([%-%.%d]+)'))
    local z = tonumber(body:match('"z"%s*:%s*([%-%.%d]+)'))
		local r = tonumber(body:match('"radius"%s*:%s*([%-%.%d]+)'))
		local price = tonumber(body:match('"price"%s*:%s*([%-%.%d]+)'))
		local rotRoll  = tonumber(body:match('"rot_roll"%s*:%s*([%-%.%d]+)'))
		local rotPitch = tonumber(body:match('"rot_pitch"%s*:%s*([%-%.%d]+)'))
		local rotYaw   = tonumber(body:match('"rot_yaw"%s*:%s*([%-%.%d]+)'))

		if x and y and z then
			local repairPrice = math.floor((price or tonumber(opts.default_repair_price) or 500) + 0.5)
			if repairPrice < 0 then repairPrice = 0 end

			local rec = {
				x = x,
				y = y,
				z = z,
				radius = r or opts.radius or 5.0,

				-- Fixed repair price for this repair bay.
				price = repairPrice,

				-- Optional fixed facing direction for this repair bay.
				rot_roll = rotRoll,
				rot_pitch = rotPitch,
				rot_yaw = rotYaw,
			}

			for i = 1, 10 do
				local key = "fxeffect" .. tostring(i)
				local val = body:match('"' .. key .. '"%s*:%s*"(.-)"') or ""
				rec[key] = tostring(val or ""):gsub("^%s+", ""):gsub("%s+$", "")
			end

			table.insert(points, rec)
		end
  end

  if opts.debug then
    print(("[VehicleMileage][Repair] Loaded %d repair station point(s) from %s")
      :format(#points, tostring(path)))
  end
end

local function getVehicleInfo(veh)
  if not veh then return nil end

  local id, label

  -- First: use init.lua helper vehKeyAndLabel()
  if type(opts.vehKeyAndLabel) == "function" then
    local ok, a, b = pcall(opts.vehKeyAndLabel, veh)
    if ok then
      id = cleanVehicleRecordID(a)
      label = cleanVehicleRecordID(b or a)
    else
      print("[VehicleMileage][Repair] vehKeyAndLabel failed: " .. tostring(a))
    end
  end

  -- Fallback: read record directly from vehicle
  if not label or label == "" then
    local okRid, rid = pcall(function()
      return veh:GetRecordID()
    end)

    if okRid and rid then
      local okDbg, dbg = pcall(function()
        return TweakDBID.ToStringDEBUG(rid)
      end)

      if okDbg and dbg and #dbg > 0 then
        label = cleanVehicleRecordID(dbg)
        id = label
      end
    end
  end

  if not label or label == "" then
    print("[VehicleMileage][Repair] ERROR: Could not resolve vehicle label")
    return nil
  end

  local kind = "Car"
  if type(opts.vehicleTypeForLabel) == "function" then
    local okKind, k = pcall(opts.vehicleTypeForLabel, label)
    if okKind and (k == "Bike" or k == "Car") then
      kind = k
    end
  end

  return {
    id = id or label,
    label = label,
    kind = kind,
  }
end

local function isVehicleOwnedForRepair(veh, label)
  -- Best path: init.lua ownership helper
  if type(opts.isVehicleOwned) == "function" then
    local ok, owned = pcall(opts.isVehicleOwned, veh, label)
    if ok then
      return owned == true
    end
  end

  -- Fallback: vanilla IsPlayerVehicle()
  local okOwned, owned = pcall(function()
    return veh:IsPlayerVehicle()
  end)

  return okOwned and owned == true
end

local function findInsidePoint(pos)
  if not pos then return nil end

  for i = 1, #points do
    local p = points[i]
    local r = tonumber(p.radius) or opts.radius or 5.0

    -- XY only, same forgiving style as gas zones.
    local dx = (p.x or 0) - pos.x
    local dy = (p.y or 0) - pos.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist <= r then
      return i, p
    end
  end

  return nil
end

local function findNearPoint(pos, nearRadius)
  if not pos then return nil end

  local limit = tonumber(nearRadius) or REPAIR_FX_NEAR_RADIUS or 50.0

  for i = 1, #points do
    local p = points[i]

    -- XY only.
    local dx = (p.x or 0) - pos.x
    local dy = (p.y or 0) - pos.y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist <= limit then
      return i, p
    end
  end

  return nil
end

local function cleanFxNodePath(s)
  s = tostring(s or "")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function getRepairFxNode(point, index)
  if not point then return "" end
  return cleanFxNodePath(point["fxeffect" .. tostring(index)] or "")
end

local function getWorldStateSystemSafe()
  local wss = nil

  pcall(function()
    if Game and Game.GetWorldStateSystem then
      wss = Game.GetWorldStateSystem()
    end
  end)

  if not wss then
    pcall(function()
      if GameInstance and GameInstance.GetWorldStateSystem then
        wss = GameInstance.GetWorldStateSystem()
      end
    end)
  end

  return wss
end

local function toggleRepairFxNode(nodePath, state)
  nodePath = cleanFxNodePath(nodePath)
  if nodePath == "" then return false end

  local wss = getWorldStateSystemSafe()
  if not wss then
    if opts.debug then
      print("[VehicleMileage][Repair] FX toggle failed: WorldStateSystem unavailable")
    end
    return false
  end

  if not ToNodeRef then
    if opts.debug then
      print("[VehicleMileage][Repair] FX toggle failed: ToNodeRef unavailable")
    end
    return false
  end

  local ok, err = pcall(function()
    wss:ToggleNode(ToNodeRef(nodePath), state and true or false)
  end)

  if opts.debug then
    print(("[VehicleMileage][Repair] FX %s -> %s ok=%s err=%s")
      :format(nodePath, tostring(state and true or false), tostring(ok), tostring(err)))
  end

  return ok
end

local function setRepairPointFxAll(point, state)
  if not point then return end

  for i = 1, 10 do
    toggleRepairFxNode(getRepairFxNode(point, i), state)
  end
end

local function setAllRepairFx(state)
  for i = 1, #points do
    setRepairPointFxAll(points[i], state)
  end
end

local function setRepairPointFxEnter(point)
  if not point then return end

  -- Enter stage:
  -- fx1 = true
  -- fx2-10 = false
  for i = 2, 10 do
    toggleRepairFxNode(getRepairFxNode(point, i), false)
  end

  toggleRepairFxNode(getRepairFxNode(point, 1), true)
end

local function setRepairPointFxComplete(point)
  if not point then return end

  -- stage 1 done
  toggleRepairFxNode(getRepairFxNode(point, 1), false)

  -- stage 2: repair completed
  for i = 2, 10 do
    toggleRepairFxNode(getRepairFxNode(point, i), true)
  end
end

local function copyRepairFxFields(src, dst)
  dst = dst or {}

  for i = 1, 10 do
    local key = "fxeffect" .. tostring(i)
    dst[key] = cleanFxNodePath(src and src[key] or "")
  end

  return dst
end

local function clearLeaveRepairZoneLock()
  if mustLeaveRepairZone then
    mustLeaveRepairZone = false
    mustLeaveToastShown = false

    if opts.debug then
      print("[VehicleMileage][Repair] Player left repair zone. Repair can be started again.")
    end
  end
end

local function getRepairPriceFromPoint(point)
  local price = math.floor((tonumber(point and point.price) or tonumber(opts.default_repair_price) or 500) + 0.5)
  if price < 0 then price = 0 end
  return price
end

local function getPlayerMoney()
  local player = Game.GetPlayer()
  local ts = Game.GetTransactionSystem()

  if not player or not ts then
    return 0
  end

  local ok, amount = pcall(function()
    return ts:GetItemQuantity(player, MarketSystem.Money())
  end)

  if ok and tonumber(amount) then
    return tonumber(amount)
  end

  return 0
end

local function removePlayerMoney(amount)
  amount = math.floor(tonumber(amount) or 0)

  if amount <= 0 then
    return true, getPlayerMoney()
  end

  local player = Game.GetPlayer()
  local ts = Game.GetTransactionSystem()

  if not player or not ts then
    return false, 0
  end

  local before = getPlayerMoney()

  if before < amount then
    return false, before
  end

  local ok, err = pcall(function()
    ts:RemoveItem(player, MarketSystem.Money(), amount)
  end)

  if not ok then
    print("[VehicleMileage][Repair] Remove money failed: " .. tostring(err))
    return false, before
  end

  return true, before
end

local function addPlayerMoney(amount)
  amount = math.floor(tonumber(amount) or 0)

  if amount <= 0 then
    return true
  end

  local player = Game.GetPlayer()
  local ts = Game.GetTransactionSystem()

  if not player or not ts then
    return false
  end

  local ok, err = pcall(function()
    ts:GiveItem(player, MarketSystem.Money(), amount)
  end)

  if not ok then
    print("[VehicleMileage][Repair] Refund failed: " .. tostring(err))
    return false
  end

  return true
end

local function getVehicleWorldRotation(veh)
  if not veh then return nil end

  local rot = nil

  -- Best path: exact world orientation -> EulerAngles
  pcall(function()
    local q = veh:GetWorldOrientation()
    if q then
      rot = q:ToEulerAngles()
    end
  end)

  if rot then
    if opts.debug then
			print("[VehicleMileage][Repair] Captured exact vehicle rotation.")
		end
    return rot
  end

  print("[VehicleMileage][Repair] WARN: Could not capture exact vehicle rotation, using forward fallback.")
  return nil
end

local function tryMoveSpawnedVehicleToRepairPoint(entity, point, rotation, forwardX, forwardY)
  if not entity or not point then return false end

  local tf = Game.GetTeleportationFacility()
  if not tf then
    print("[VehicleMileage][Repair] Vehicle move failed: TeleportationFacility unavailable")
    return false
  end

  local pos = Vector4.new(
    tonumber(point.x) or 0.0,
    tonumber(point.y) or 0.0,
    tonumber(point.z) or 0.0,
    1.0
  )

  -- Prefer exact saved vehicle rotation.
  local rot = rotation

  -- Fallback only if exact rotation was not captured.
  if not rot then
    local fx = tonumber(forwardX) or 1.0
    local fy = tonumber(forwardY) or 0.0
    local yaw = math.deg(math.atan(fy, fx))
    rot = EulerAngles.new(0.0, 0.0, yaw)
  end

  local ok, err = pcall(function()
    tf:Teleport(entity, pos, rot)
  end)
	if opts.debug then
		print("[VehicleMileage][Repair] Move spawned vehicle to repair point=" .. tostring(ok) .. " err=" .. tostring(err))
	end
  return ok
end

local function makeGarageVehicleID(recordID)
  local gid = NewObject("vehicleGarageVehicleID")
  gid.recordID = TweakDBID.new(recordID)
  return gid
end

local function getVehicleEntityID(veh)
  if not veh then return nil end

  local entityID = nil
  pcall(function()
    entityID = veh:GetEntityID()
  end)

  return entityID
end

local function sameEntityID(a, b)
  if not a or not b then return false end
  return tostring(a) == tostring(b)
end

local function oldVehicleStillPresent(entityID)
  if not entityID then return false end

  local stillPresent = false
  pcall(function()
    stillPresent = Game.FindEntityByID(entityID) ~= nil
  end)

  return stillPresent
end

local function unmountPlayer()
  local player = Game.GetPlayer()
  local mountingFacility = Game.GetMountingFacility()

  if not player or not mountingFacility then
    return false
  end

  local ok, err = pcall(function()
    local request = gamemountingUnmountingRequest.new()
    local mountingInfo = gamemountingMountingInfo.new()
    mountingInfo.childId = player:GetEntityID()
    request.lowLevelMountingInfo = mountingInfo
    request.mountData = gameMountEventData.new()
    request.mountData.isInstant = true
    request.mountData.removePitchRollRotationOnDismount = true
    mountingFacility:Unmount(request)
  end)

  if not ok then
    print("[VehicleMileage][Repair] Automatic dismount failed: " .. tostring(err))
  end

  return ok
end

local function mountPlayer(vehicleEntityID)
  local player = Game.GetPlayer()
  local mountingFacility = Game.GetMountingFacility()

  if not player or not mountingFacility or not vehicleEntityID then
    return false
  end

  local ok, err = pcall(function()
    local mountData = NewObject("handle:gameMountEventData")
    mountData.isInstant = true
    mountData.slotName = "seat_front_left"
    mountData.mountParentEntityId = vehicleEntityID
    mountData.entryAnimName = "forcedTransition"

    local seatSlotID = NewObject("gamemountingMountingSlotId")
    seatSlotID.id = "seat_front_left"

    local mountingInfo = NewObject("gamemountingMountingInfo")
    mountingInfo.childId = player:GetEntityID()
    mountingInfo.parentId = vehicleEntityID
    mountingInfo.slotId = seatSlotID

    local request = NewObject("handle:gamemountingMountingRequest")
    request.lowLevelMountingInfo = mountingInfo
    request.mountData = mountData

    mountingFacility:Mount(request)
  end)

  if not ok then
    print("[VehicleMileage][Repair] Automatic remount failed: " .. tostring(err))
  end

  return ok
end

local function restoreSummonMode(watch)
  if not watch or not watch.summonModeActive then return end

  local vs = Game.GetVehicleSystem()
  if vs then
    pcall(function()
      vs:ToggleSummonMode()
    end)
  end

  watch.summonModeActive = false
end

local function startGarageSpawn(
  recordID,
  kind,
  point,
  rotation,
  forwardX,
  forwardY,
  vehicleID,
  vehicleConditionPct,
  oldEntityID,
  repairCost,
  autoRemount
)
  recordID = cleanVehicleRecordID(recordID)
  kind = kind or "Car"

  if not recordID or not recordID:find("^Vehicle%.") then
    print("[VehicleMileage][Repair] Garage spawn failed: invalid recordID " .. tostring(recordID))
    return false
  end

  local vs = Game.GetVehicleSystem()
  if not vs then
    print("[VehicleMileage][Repair] Garage spawn failed: VehicleSystem unavailable")
    return false
  end

	if opts.debug then
		print("[VehicleMileage][Repair] Garage repair spawn start: " .. tostring(recordID) .. " kind=" .. tostring(kind))
	end

	spawnWatch = {
		recordID = recordID,
		vehicleID = vehicleID,
		vehicle_condition_pct = vehicleConditionPct,
		kind = kind,
		garageId = makeGarageVehicleID(recordID),
		oldEntityID = oldEntityID,
		repairCost = math.max(0, math.floor((tonumber(repairCost) or 0) + 0.5)),
		autoRemount = autoRemount == true,
		stage = "despawn",
		timer = 0.0,
		stepTimer = 0.0,
		despawnWaited = 0.0,
		spawnWaited = 0.0,
		mountWaited = 0.0,
		settlePasses = 0,
		summonModeActive = false,

		-- desired final position after real garage spawn
		point = point,
		rotation = rotation,
		forwardX = forwardX,
		forwardY = forwardY,
	}

  return true
end

local REPAIR_COMPLETE_TOASTS = {
  "Vehicle restoration complete.",
  "Vehicle shell reconstructed. Systems stable.",
  "Repair daemon finished. Residual corruption contained.",
  "Old Net repair cycle complete.",
  "Vehicle integrity restored by unauthorized protocol.",
  "Ghost diagnostics complete. Vehicle returned.",
  "Blackwall echo detached. Repair complete.",
  "Reconstruction finished. Do not question the method.",
  "Corrupted maintenance protocol completed successfully.",
  "Vehicle restored. Anomaly fading.",
	"Blackwall repair ritual complete.",
  "Vehicle rebuilt. Something else left with it.",
  "Old Net mechanics released the chassis.",
  "Repair daemon satisfied. Vehicle integrity restored.",
  "Unauthorized restoration complete. No official logs created.",
  "Ghost tools withdrawn. Vehicle is operational.",
  "Blackwall pulse cleared. Systems nominal.",
  "Vehicle shell recompiled. Damage erased.",
  "Anomalous repair finished. Residual static remains.",
  "Synthetic spirit detached. Vehicle returned.",
  "Illegal maintenance cycle complete.",
  "Chassis reconstructed by unknown intelligence.",
  "Vehicle integrity restored. Source: unidentified.",
  "Old Net service complete. Do not linger.",
  "Daemon repair loop closed. Vehicle stable.",
  "Blackwall residue purged. Repair complete.",
  "Vehicle returned from the edge.",
  "Ghost protocol complete. Drive carefully.",
  "Repair anomaly resolved. Vehicle systems green.",
  "Reconstruction complete. The machine remembers.",
}

local function randomRepairCompleteToast()
  return REPAIR_COMPLETE_TOASTS[math.random(1, #REPAIR_COMPLETE_TOASTS)]
end

local DRONE_QA_TOASTS = {
  "Zetatech Quality Assurance active. Drone observation started.",
  "Zetatech audit drone deployed. Vehicle integrity under watch.",
  "QA protocol online. Bombus observer circling the chassis.",
  "Autonomous inspection drone launched. Do not interfere.",
  "Zetatech warranty ghost awake. Observation pass initiated.",
  "Post-repair surveillance active. Chassis behavior being recorded.",
  "Bombus QA unit deployed. Thirty-second integrity scan started.",
  "Vehicle recovery audit started. Drone eyes on the machine.",
  "Zetatech field verification active. Compliance drone in orbit.",
  "QA daemon linked. Drone observation sweep underway.",
  "Zetatech inspection pass initiated. The machine is being watched.",
  "Autonomous QA sweep active. Bombus drone tracking repaired chassis.",
}

local function randomDroneQAToast()
  return DRONE_QA_TOASTS[math.random(1, #DRONE_QA_TOASTS)]
end

local function triggerDroneOrbitQA()
  local qs = Game.GetQuestsSystem()

  if qs then
    local current = droneOrbitCmd

    -- Best effort: continue from current quest fact value.
    pcall(function()
      current = tonumber(qs:GetFactStr("vm_drone_orbit_cmd")) or current
    end)

    droneOrbitCmd = current + 1

    local ok, err = pcall(function()
      qs:SetFactStr("vm_drone_orbit_cmd", droneOrbitCmd)
    end)

    if opts.debug then
      print(("[VehicleMileage][Repair] Drone orbit command=%s ok=%s err=%s")
        :format(tostring(droneOrbitCmd), tostring(ok), tostring(err)))
    end
  end

  toast(randomDroneQAToast())
end

local function failSpawnWatch(reason, refundPayment)
  local watch = spawnWatch
  if not watch then return false end

  restoreSummonMode(watch)

  print("[VehicleMileage][Repair] " .. tostring(reason or "Garage respawn failed."))

  if refundPayment and (tonumber(watch.repairCost) or 0) > 0 then
    if addPlayerMoney(watch.repairCost) then
      print("[VehicleMileage][Repair] Refunded repair payment after respawn failure.")
    end
  end

  if watch.point then
    setRepairPointFxAll(watch.point, false)
  end

  activeRepairFxPoint = nil
  spawnWatch = nil
  toast("Vehicle repair failed")
  return false
end

local function findSummonedVehicle(watch)
  local okBB, vehicleEntityID = pcall(function()
    local def = Game.GetAllBlackboardDefs().VehicleSummonData
    local bb = Game.GetBlackboardSystem():Get(def)
    if not bb then return nil end
    return bb:GetEntityID(def.SummonedVehicleEntityID)
  end)

  if not okBB or not vehicleEntityID then
    return nil, nil, nil
  end

  -- The summon blackboard can briefly retain the vehicle being replaced.
  if sameEntityID(vehicleEntityID, watch.oldEntityID) then
    return nil, nil, nil
  end

  local entity = Game.FindEntityByID(vehicleEntityID)
  if not entity then
    return nil, nil, nil
  end

  local info = getVehicleInfo(entity)
  if not info then
    return nil, nil, nil
  end

  if cleanVehicleRecordID(info.label) ~= cleanVehicleRecordID(watch.recordID) then
    return nil, nil, nil
  end

  return entity, vehicleEntityID, info
end

local function completeSpawnWatch(watch, remountResult)
  if not watch then return false end

  local want = cleanVehicleRecordID(watch.recordID)
  local info = watch.spawnedInfo or {}

  -- Stage 2 FX remains active until the player drives out of the bay.
  activeRepairFxPoint = watch.point
  setRepairPointFxComplete(activeRepairFxPoint)

  local completeMessage = randomRepairCompleteToast()
  if remountResult == false then
    completeMessage = completeMessage .. " Automatic remount failed."
  end
  toast(completeMessage)

  if type(opts.onRepairCompleted) == "function" then
    local okCallback, callbackErr = pcall(
      opts.onRepairCompleted,
      watch.vehicleID or info.id or want,
      want,
      watch.vehicle_condition_pct
    )

    if not okCallback then
      print("[VehicleMileage][Repair] Completion callback failed: "
        .. tostring(callbackErr))
    end
  end

  -- Wait until the repaired vehicle leaves the bay before starting QA.
  pendingDroneOrbitAfterRepair = true
  spawnWatch = nil
  return true
end

local function tickSpawnWatch(dt)
  if not spawnWatch then return false end

  dt = tonumber(dt or 0.0) or 0.0
  local watch = spawnWatch
  watch.timer = (watch.timer or 0.0) + dt
  watch.stepTimer = (watch.stepTimer or 0.0) - dt

  if watch.stage == "wait_despawn" then
    watch.despawnWaited = (watch.despawnWaited or 0.0) + dt
  elseif watch.stage == "wait_spawn" then
    watch.spawnWaited = (watch.spawnWaited or 0.0) + dt
  elseif watch.stage == "mount" then
    watch.mountWaited = (watch.mountWaited or 0.0) + dt
  end

  if watch.stepTimer > 0.0 then
    return true
  end

  if watch.stage == "despawn" then
    local vs = Game.GetVehicleSystem()
    if not vs then
      return failSpawnWatch("Garage respawn failed: VehicleSystem unavailable.", true)
    end

    local okToggle, toggleErr = pcall(function()
      vs:ToggleSummonMode()
    end)
    if not okToggle then
      return failSpawnWatch("Garage respawn failed while enabling summon mode: "
        .. tostring(toggleErr), true)
    end
    watch.summonModeActive = true

    local okDespawn, despawnErr = pcall(function()
      vs:DespawnPlayerVehicle(watch.garageId)
    end)
    if not okDespawn then
      return failSpawnWatch("Garage respawn failed while despawning the old vehicle: "
        .. tostring(despawnErr), true)
    end

    if opts.debug then
      print("[VehicleMileage][Repair] Old garage vehicle despawn requested.")
    end

    watch.stage = "wait_despawn"
    watch.stepTimer = 0.6
    return true
  end

  if watch.stage == "wait_despawn" then
    if oldVehicleStillPresent(watch.oldEntityID) then
      if watch.despawnWaited >= REPAIR_DESPAWN_TIMEOUT_SECONDS then
        return failSpawnWatch(
          "Garage respawn stopped because the old vehicle did not despawn.",
          true
        )
      end

      watch.stepTimer = 0.1
      return true
    end

    watch.stage = "summon"
    watch.stepTimer = 0.0
  end

  if watch.stage == "summon" then
    local vs = Game.GetVehicleSystem()
    if not vs then
      return failSpawnWatch("Garage respawn failed: VehicleSystem unavailable.", true)
    end

    local okSpawn, spawnErr = pcall(function()
      vs:SpawnPlayerVehicle(watch.kind, TweakDBID.new(watch.recordID), false)
    end)
    restoreSummonMode(watch)

    if not okSpawn then
      return failSpawnWatch("Garage respawn failed while spawning the repaired vehicle: "
        .. tostring(spawnErr), true)
    end

    if opts.debug then
      print("[VehicleMileage][Repair] Repaired garage vehicle summon requested.")
    end

    watch.stage = "wait_spawn"
    watch.stepTimer = 0.4
    watch.spawnWaited = 0.0
    return true
  end

  if watch.stage == "wait_spawn" then
    local entity, vehicleEntityID, info = findSummonedVehicle(watch)

    if not entity then
      if watch.spawnWaited >= REPAIR_SPAWN_TIMEOUT_SECONDS then
        return failSpawnWatch(
          "Garage respawn timed out while waiting for the repaired vehicle.",
          false
        )
      end

      watch.stepTimer = 0.1
      return true
    end

    if opts.debug then
      print("[VehicleMileage][Repair] Repaired garage vehicle spawned and was detected: "
        .. tostring(watch.recordID))
    end

    watch.spawnedEntity = entity
    watch.spawnedEntityID = vehicleEntityID
    watch.spawnedInfo = info

    -- Put the replacement in the bay before seating the player.
    tryMoveSpawnedVehicleToRepairPoint(
      entity,
      watch.point,
      watch.rotation,
      watch.forwardX,
      watch.forwardY
    )

    -- The default/manual method leaves the player outside the repaired vehicle,
    -- matching the original repair-bay behavior.
    if not watch.autoRemount then
      return completeSpawnWatch(watch, nil)
    end

    mountPlayer(vehicleEntityID)
    watch.stage = "mount"
    watch.stepTimer = 0.15
    watch.mountWaited = 0.0
    return true
  end

  if watch.stage == "mount" then
    local player = Game.GetPlayer()
    local mountedVehicle = player and player:GetMountedVehicle() or nil

    if mountedVehicle
      and sameEntityID(getVehicleEntityID(mountedVehicle), watch.spawnedEntityID)
    then
      watch.stage = "settle"
      watch.stepTimer = 0.15
      watch.settlePasses = 0
      return true
    end

    if watch.mountWaited >= REPAIR_MOUNT_TIMEOUT_SECONDS then
      print("[VehicleMileage][Repair] Repaired vehicle spawned, but automatic remount timed out.")
      return completeSpawnWatch(watch, false)
    end

    -- Retry the instant seat request while the spawned entity finishes settling.
    mountPlayer(watch.spawnedEntityID)
    watch.stepTimer = 0.25
    return true
  end

  if watch.stage == "settle" then
    local player = Game.GetPlayer()

    if player then
      -- The summon system can keep moving a fresh entity for several frames.
      -- Reapplying the transform while seated keeps player and vehicle together.
      tryMoveSpawnedVehicleToRepairPoint(
        player,
        watch.point,
        watch.rotation,
        watch.forwardX,
        watch.forwardY
      )
    end

    watch.settlePasses = (watch.settlePasses or 0) + 1
    if watch.settlePasses < REPAIR_SETTLE_PASSES then
      watch.stepTimer = 0.15
      return true
    end

    return completeSpawnWatch(watch, true)
  end

  return failSpawnWatch("Garage respawn entered an unknown state: "
    .. tostring(watch.stage), true)
end

local function clampVehicleConditionPct(pct)
  pct = tonumber(pct)

  if pct == nil then
    return -1
  end

  pct = math.floor(pct + 0.5)

  if pct < 0 then
    return -1
  end

  if pct > 100 then
    pct = 100
  end

  return pct
end

local function getCurrentVehicleConditionPct(veh)
  if type(opts.getVehicleConditionPct) == "function" then
    local ok, pct = pcall(opts.getVehicleConditionPct, veh)

    if ok then
      return clampVehicleConditionPct(pct)
    end
  end

  -- Fallback: read the bridge fact directly.
  -- This only works while mounted; after exit it may already be -1.
  local qs = Game.GetQuestsSystem()

  if qs then
    local ok, value = pcall(function()
      return qs:GetFactStr("vm_hud_vehicle_cond_pct")
    end)

    if ok then
      return clampVehicleConditionPct(value)
    end
  end

  return -1
end

local function repairPriceFactorFromCondition(conditionPct)
  conditionPct = clampVehicleConditionPct(conditionPct)

  -- Unknown condition = full price.
  -- Safer than accidentally giving free repairs.
  if conditionPct < 0 then
    return 1.0
  end

  -- Perfect condition = free.
  if conditionPct >= 100 then
    return 0.0
  end

  -- Very damaged = full configured price.
  if conditionPct <= 10 then
    return 1.0
  end

  -- Linear scaling between 10% and 100%.
  -- 10%  -> 1.0
  -- 100% -> 0.0
  return (100.0 - conditionPct) / 90.0
end

local function getRepairPriceAdjustPct()
  if type(opts.getRepairPriceAdjustPct) == "function" then
    local ok, v = pcall(opts.getRepairPriceAdjustPct)
		if ok then
			v = tonumber(v) or 0
			if v < -100 then v = -100 elseif v > 2000 then v = 2000 end
			return v
		end
  end

  return 0
end

local function applyRepairPriceModifier(basePrice, conditionPct)
  basePrice = math.max(0, tonumber(basePrice) or 0)

  local adjustPct = getRepairPriceAdjustPct()
  local multiplier = 1.0 + (adjustPct / 100.0)

  local adjustedPrice = basePrice * multiplier
  local conditionFactor = repairPriceFactorFromCondition(conditionPct)

  local finalPrice = math.floor((adjustedPrice * conditionFactor) + 0.5)

  if finalPrice < 0 then
    finalPrice = 0
  end

  return finalPrice, multiplier, adjustPct, conditionFactor, clampVehicleConditionPct(conditionPct), adjustedPrice
end

local function getFinalRepairPriceFromPoint(point, conditionPct)
  local basePrice = getRepairPriceFromPoint(point)

  local finalPrice, multiplier, adjustPct, conditionFactor, cleanConditionPct, adjustedPrice =
    applyRepairPriceModifier(basePrice, conditionPct)

  return finalPrice, basePrice, multiplier, adjustPct, conditionFactor, cleanConditionPct, adjustedPrice
end

local function respawnVehicle(repair)
  if not repair or not repair.label then
    return false
  end

	local recordID = cleanVehicleRecordID(repair.label)
	local kind = repair.kind or "Car"

	local repairCost = tonumber(repair.point and repair.point.final_price)
	local baseRepairCost = tonumber(repair.point and repair.point.base_price)
	local repairMultiplier = tonumber(repair.point and repair.point.price_multiplier)
	local repairAdjustPct = tonumber(repair.point and repair.point.price_adjust_pct)

	-- Fallback for older armed repairs / hot reloads
	if repairCost == nil or baseRepairCost == nil then
		repairCost, baseRepairCost, repairMultiplier, repairAdjustPct =
			getFinalRepairPriceFromPoint(
				repair.point,
				repair.vehicle_condition_pct or repair.point.vehicle_condition_pct
			)
	end

	repairCost = math.floor((tonumber(repairCost) or 0) + 0.5)
	baseRepairCost = math.floor((tonumber(baseRepairCost) or 0) + 0.5)
	repairAdjustPct = tonumber(repairAdjustPct) or 0
	repairMultiplier = tonumber(repairMultiplier) or (1.0 + (repairAdjustPct / 100.0))

	local walletBefore = getPlayerMoney()

	if opts.debug then
		print(("[VehicleMileage][Repair] Repair price base=%d modifier=%+d%% final=%d wallet=%d vehicle=%s")
			:format(
				baseRepairCost,
				repairAdjustPct,
				repairCost,
				tonumber(walletBefore) or 0,
				tostring(recordID)
			))
	end
	if walletBefore < repairCost then
		print(("[VehicleMileage][Repair] Not enough eddies. Need %d, have %d.")
			:format(tonumber(repairCost) or 0, tonumber(walletBefore) or 0))

		setRepairPointFxAll(repair.point, false)
		toast(("Not enough eddies for repair: €$%d"):format(tonumber(repairCost) or 0))
		return false
	end

	local paid, beforePay = removePlayerMoney(repairCost)

	if not paid then
		print("[VehicleMileage][Repair] ERROR: Could not remove repair cost.")
		setRepairPointFxAll(repair.point, false)
		toast("Vehicle repair payment failed")
		return false
	end
	if opts.debug then
		print(("[VehicleMileage][Repair] Repair paid: €$%d walletBefore=%d walletAfter=%d")
			:format(
				tonumber(repairCost) or 0,
				tonumber(beforePay) or 0,
				tonumber(getPlayerMoney()) or 0
			))
	end
	--toast(("Vehicle repair paid: €$%d"):format(tonumber(repairCost) or 0))

	if opts.debug then
		print("[VehicleMileage][Repair] Repair complete. Spawning real garage vehicle: " .. tostring(recordID))
	end

	local zoneRotation = nil

	if repair.point
		and repair.point.rot_roll ~= nil
		and repair.point.rot_pitch ~= nil
		and repair.point.rot_yaw ~= nil
	then
		zoneRotation = EulerAngles.new(
			tonumber(repair.point.rot_roll) or 0.0,
			tonumber(repair.point.rot_pitch) or 0.0,
			tonumber(repair.point.rot_yaw) or 0.0
		)
		if opts.debug then
		print(("[VehicleMileage][Repair] Using repair-zone rotation: roll=%.2f pitch=%.2f yaw=%.2f")
			:format(
				tonumber(repair.point.rot_roll) or 0.0,
				tonumber(repair.point.rot_pitch) or 0.0,
				tonumber(repair.point.rot_yaw) or 0.0
			))
		end
	else
		zoneRotation = repair.rotation
		if opts.debug then
			print("[VehicleMileage][Repair] Repair zone has no stored rotation, using parked vehicle rotation fallback.")
    end
	end

	local ok = startGarageSpawn(
		recordID,
		kind,
		repair.point,
		zoneRotation,
		repair.forwardX,
		repair.forwardY,
		repair.id,
		repair.vehicle_condition_pct,
		repair.oldEntityID,
		repairCost,
		repair.automatic == true
	)

	if not ok then
		print("[VehicleMileage][Repair] ERROR: real garage vehicle spawn failed.")

		if repairCost and repairCost > 0 then
			addPlayerMoney(repairCost)
			print("[VehicleMileage][Repair] Refunded repair payment after spawn failure.")
		end

		setRepairPointFxAll(repair.point, false)
		toast("Vehicle repair failed")
		return false
	end

  return true
end

local REPAIR_ENTER_TOASTS = {
  "Blackwall diagnostics synced.",
  "Unauthorized auto-repair daemon detected.",
  "Rogue maintenance protocol armed.",
  "Blackwall repair ritual primed.",
  "Vehicle engram scan complete.",
  "Anomalous repair signal locked.",
  "Old Net restoration protocol active.",
  "Blackwall echo attached to vehicle systems.",
  "Corrupted service daemon ready.",
  "Ghost repair protocol waiting.",
	"Blackwall anomaly has claimed your vehicle.",
  "Unauthorized repair shard injected.",
  "Vehicle damage pattern uploaded to the Old Net.",
  "Rogue auto-doc daemon awake.",
  "Blackwall pulse detected in vehicle frame.",
  "Synthetic maintenance ghost linked.",
  "Illegal repair protocol seeded.",
  "Vehicle soulprint captured.",
  "Old Net mechanics are listening.",
  "Corruption-assisted repair ready.",
}

local function randomRepairEnterToast(price, conditionPct, automatic)
  local msg = REPAIR_ENTER_TOASTS[math.random(1, #REPAIR_ENTER_TOASTS)]

  if automatic then
    local waitSeconds = tonumber(opts.automatic_wait_seconds) or 5.0
    msg = ("%s Stay in the vehicle; automatic service starts in %.0f seconds.")
      :format(msg, waitSeconds)
  else
    msg = msg .. " Exit the vehicle to begin restoration."
  end

  conditionPct = clampVehicleConditionPct(conditionPct)

  if conditionPct >= 0 then
    return ("%s Condition: %d%% | Cost: €$%d")
      :format(msg, conditionPct, tonumber(price) or 0)
  end

  return ("%s Cost: €$%d"):format(msg, tonumber(price) or 0)
end

local function beginAutomaticRepair()
  local repair = armedRepair
  if not repair then return false end

  local repairCost = tonumber(repair.point and repair.point.final_price)
  if repairCost == nil then
    repairCost = getFinalRepairPriceFromPoint(
      repair.point,
      repair.vehicle_condition_pct or (repair.point and repair.point.vehicle_condition_pct)
    )
  end
  repairCost = math.max(0, math.floor((tonumber(repairCost) or 0) + 0.5))

  -- Check before forcing the player out. respawnVehicle() repeats this check
  -- immediately before charging in case the wallet changes during dismount.
  if getPlayerMoney() < repairCost then
    armedRepair = nil
    lastInsideIdx = nil
    respawnVehicle(repair)
    mustLeaveRepairZone = true
    mustLeaveToastShown = false
    return true
  end

  local player = Game.GetPlayer()
  local mountedVehicle = player and player:GetMountedVehicle() or nil

  if mountedVehicle and not unmountPlayer() then
    print("[VehicleMileage][Repair] Automatic repair cancelled because the player could not be dismounted.")
    setRepairPointFxAll(repair.point, false)
    activeRepairFxPoint = nil
    armedRepair = nil
    lastInsideIdx = nil
    mustLeaveRepairZone = true
    mustLeaveToastShown = false
    toast("Automatic vehicle repair could not start")
    return false
  end

  repair.state = "unmounting"
  repair.timer = 0.0

  if opts.debug then
    print("[VehicleMileage][Repair] Five-second bay timer complete. Automatic dismount requested.")
  end

  return true
end


function M.setup(o)
  o = o or {}
  for k, v in pairs(o) do
    opts[k] = v
  end

	restoreSummonMode(spawnWatch)
	spawnWatch = nil
	loadPoints()

	-- Default initial state: all repair-bay FX nodes off.
	setAllRepairFx(false)
	activeRepairFxPoint = nil
	lastNearFxResetIdx = nil
	armedRepair = nil
	lastInsideIdx = nil
	mustLeaveRepairZone = false
	mustLeaveToastShown = false
	pendingDroneOrbitAfterRepair = false
end

function M.reload()
  loadPoints()
  setAllRepairFx(false)
	activeRepairFxPoint = nil
	lastNearFxResetIdx = nil
end

function M.reset()
  if activeRepairFxPoint then
    setRepairPointFxAll(activeRepairFxPoint, false)
  end

	activeRepairFxPoint = nil
	lastNearFxResetIdx = nil
	armedRepair = nil
	restoreSummonMode(spawnWatch)
	spawnWatch = nil
  lastInsideIdx = nil
  mustLeaveRepairZone = false
  mustLeaveToastShown = false
	pendingDroneOrbitAfterRepair = false
end

function M.update(dt)
  dt = tonumber(dt or 0.0) or 0.0

  local player = Game.GetPlayer()
  if not player then
    M.reset()
    return false
  end

	local veh = player:GetMountedVehicle()

	-- Keep normal bay detection paused while the old vehicle is being replaced.
	-- This avoids treating the temporary summon position as leaving the bay.
	if spawnWatch then
		tickSpawnWatch(dt)
		return true
	end

	-- Authentic Shift pattern: allow the instant dismount to settle before
	-- despawning the vehicle, and never despawn it underneath the player.
	if armedRepair and armedRepair.state == "unmounting" then
		armedRepair.timer = (armedRepair.timer or 0.0) + dt

		if armedRepair.timer < REPAIR_UNMOUNT_SETTLE_SECONDS then
			return true
		end

		if veh then
			if armedRepair.timer < REPAIR_UNMOUNT_TIMEOUT_SECONDS then
				return true
			end

			print("[VehicleMileage][Repair] Automatic repair cancelled because the dismount did not complete.")
			setRepairPointFxAll(armedRepair.point, false)
			activeRepairFxPoint = nil
			armedRepair = nil
			lastInsideIdx = nil
			mustLeaveRepairZone = true
			mustLeaveToastShown = false
			toast("Automatic vehicle repair could not dismount the player")
			return false
		end

		local finished = armedRepair
		armedRepair = nil
		lastInsideIdx = nil

		respawnVehicle(finished)

		-- Require the repaired vehicle to leave before this bay can arm again.
		mustLeaveRepairZone = true
		mustLeaveToastShown = false
		return true
	end

	-- Player is mounted: only arm repair when vehicle is inside repair zone.
	if veh then
		local pos = nil
		pcall(function()
			pos = veh:GetWorldPosition()
		end)

		local insideIdx, point = findInsidePoint(pos)
		local nearIdx, nearPoint = findNearPoint(pos, REPAIR_FX_NEAR_RADIUS)

		local info = getVehicleInfo(veh)
		if not info then return false end

		local ownedForRepair = isVehicleOwnedForRepair(veh, info.label)

		if not insideIdx then
			-- One-shot safety reset when approaching a repair bay.
			-- Only runs while mounted in a player-owned vehicle,
			-- near a repair bay, but NOT inside the repair zone.
			if ownedForRepair and nearIdx and lastNearFxResetIdx ~= nearIdx then
				setAllRepairFx(false)
				lastNearFxResetIdx = nearIdx

				if opts.debug then
					print(("[VehicleMileage][Repair] Near repair bay #%d: all FX forced OFF")
						:format(nearIdx))
				end
			end

			-- If we are far away from every repair bay,
			-- allow the near-reset to run again later.
			if not nearIdx then
				lastNearFxResetIdx = nil
			end
			-- Mounted leave zone:
			-- always turn OFF the currently active FX stage.
			if activeRepairFxPoint then
				setRepairPointFxAll(activeRepairFxPoint, false)
				activeRepairFxPoint = nil
			elseif armedRepair and armedRepair.point then
				setRepairPointFxAll(armedRepair.point, false)
			end

			-- Player/vehicle left all repair zones after a completed repair:
			-- start the QA drone now, while the player is mounted in the repaired vehicle.
			if pendingDroneOrbitAfterRepair and mustLeaveRepairZone and ownedForRepair then
				pendingDroneOrbitAfterRepair = false
				triggerDroneOrbitQA()
			end

			-- Player/vehicle left all repair zones:
			-- allow next repair again.
			clearLeaveRepairZoneLock()

			-- If player drives out again, cancel the pending repair.
			armedRepair = nil
			lastInsideIdx = nil
			return false
		end

		-- Repair just completed earlier.
		-- Do not arm another repair until player leaves the repair zone first.
		if mustLeaveRepairZone then
			armedRepair = nil
			lastInsideIdx = nil

			--if not mustLeaveToastShown then
			--	toast("Leave the repair zone before starting another repair")
			--	mustLeaveToastShown = true
			--end

			return false
		end

		-- Ignore non-owned vehicles completely.
		if not ownedForRepair then
			if activeRepairFxPoint then
				setRepairPointFxAll(activeRepairFxPoint, false)
				activeRepairFxPoint = nil
			end

			armedRepair = nil
			lastInsideIdx = nil
			return false
		end

    -- New zone entry or different vehicle.
    if (not armedRepair)
      or armedRepair.label ~= info.label
      or lastInsideIdx ~= insideIdx
    then
    local forwardX, forwardY = 1.0, 0.0

			pcall(function()
				local fwd = veh:GetWorldForward()
				if fwd then
					forwardX = tonumber(fwd.x) or 1.0
					forwardY = tonumber(fwd.y) or 0.0
				end
			end)

			-- Important:
			-- Read vehicle condition NOW while still mounted.
			-- After the player exits, vm_hud_vehicle_cond_pct becomes -1.
			local vehicleConditionPct = getCurrentVehicleConditionPct(veh)

			local finalRepairCost,
			      baseRepairCost,
			      repairMultiplier,
			      repairAdjustPct,
			      conditionPriceFactor,
			      cleanConditionPct,
			      adjustedRepairPrice =
				getFinalRepairPriceFromPoint(point, vehicleConditionPct)

			local repairPoint = copyRepairFxFields(point, {
				x = point.x,
				y = point.y,
				z = point.z,
				radius = point.radius,
				price = baseRepairCost,

				-- Base fixed repair-zone price before global modifier
				base_price = baseRepairCost,

				-- Price after Native Settings modifier and vehicle condition reduction
				final_price = finalRepairCost,

				-- Native Settings modifier info
				price_adjust_pct = repairAdjustPct,
				price_multiplier = repairMultiplier,

				-- Condition price info
				vehicle_condition_pct = cleanConditionPct,
				condition_price_factor = conditionPriceFactor,
				adjusted_price_before_condition = adjustedRepairPrice,

				rot_roll = point.rot_roll,
				rot_pitch = point.rot_pitch,
				rot_yaw = point.rot_yaw,
			})

			-- Snapshot the selected method for this visit. Changing Native
			-- Settings while already in the bay applies on the next entry.
			local useAutomaticRepair = automaticRepairEnabled()

			armedRepair = {
				state = useAutomaticRepair and "waiting" or "armed",
				automatic = useAutomaticRepair,
				timer = 0.0,
				id = info.id,
				label = info.label,
				kind = info.kind,

				-- Stored while still mounted.
				-- Used after exit because vm_hud_vehicle_cond_pct becomes -1.
				vehicle_condition_pct = cleanConditionPct,

				-- The despawn is asynchronous; wait for this exact entity to vanish.
				oldEntityID = getVehicleEntityID(veh),

				-- Keep old vehicle direction for the fresh spawn.
				forwardX = forwardX,
				forwardY = forwardY,

				-- Exact parked direction before repair.
				rotation = getVehicleWorldRotation(veh),

				-- Spawn at the exact repair-zone point.
				point = repairPoint,
			}

			-- Stage 1 FX: owned vehicle entered the repair zone.
			-- Clear previous active FX first, then activate fx1 only.
			if activeRepairFxPoint and activeRepairFxPoint ~= armedRepair.point then
				setRepairPointFxAll(activeRepairFxPoint, false)
			end

			activeRepairFxPoint = armedRepair.point
			setRepairPointFxEnter(activeRepairFxPoint)

			lastInsideIdx = insideIdx
			toast(randomRepairEnterToast(
				finalRepairCost,
				cleanConditionPct,
				useAutomaticRepair
			))

      if opts.debug then
        print(("[VehicleMileage][Repair] Armed repair zone #%d for %s")
          :format(insideIdx, tostring(info.label)))
      end
    end

		if armedRepair
			and armedRepair.automatic
			and armedRepair.state == "waiting"
		then
			armedRepair.timer = (armedRepair.timer or 0.0) + dt

			if armedRepair.timer >= (opts.automatic_wait_seconds or 5.0) then
				beginAutomaticRepair()
			end
		end

    return true
  end

  -- Default/manual method: leaving the vehicle starts the original delay.
  if armedRepair and armedRepair.state == "armed" then
    armedRepair.state = "waiting"
    armedRepair.timer = 0.0

    if opts.debug then
      print("[VehicleMileage][Repair] Player left vehicle. Manual repair timer started.")
    end
  end

  -- An early manual exit in automatic mode is also supported; its five-second
  -- countdown began at bay entry and continues from the elapsed time.
  if armedRepair and armedRepair.state == "waiting" then
    armedRepair.timer = (armedRepair.timer or 0.0) + dt

		local waitSeconds = armedRepair.automatic
			and (opts.automatic_wait_seconds or 5.0)
			or (opts.wait_seconds or 3.0)

		if armedRepair.timer >= waitSeconds then
			if armedRepair.automatic then
				beginAutomaticRepair()
			else
				local finished = armedRepair
				armedRepair = nil
				lastInsideIdx = nil

				respawnVehicle(finished)

				-- Require player to leave the repair zone before another repair.
				mustLeaveRepairZone = true
				mustLeaveToastShown = false
			end

			return true
		end
  end

  return false
end


return M
