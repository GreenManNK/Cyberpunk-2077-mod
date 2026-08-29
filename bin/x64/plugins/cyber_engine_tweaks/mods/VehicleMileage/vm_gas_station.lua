-- vm_gas_station.lua
-- =============================================================================
-- VehicleMileage — Gas-station proximity refuel with optional cost and
-- single-shot audio behavior.
--
-- What this module does
--   • Detects whether the player’s mounted vehicle is inside any configured
--     gas-station radius.
--   • If inside range and not full, it refuels over time (percent/second).
--   • Optionally charges the player for fuel (Eddies), with incremental billing.
--   • Plays a refuel sound ONCE when refueling begins; stops it immediately
--     when refuel ends, you leave range, or refueling is blocked.
--
-- How to use
--   M.setup(opts)
--     Configure stations, price, and behavior. Loads station locations from
--     JSON and primes module state.
--
--   M.update(dt, helpers)  -> bool inRange
--     Call every frame (after you’ve validated there’s a player + vehicle).
--     - dt: frame delta time (seconds)
--     - helpers: table with callbacks for integration:
--         ensureVehicle(id)  -> vehicle state { fuel_pct, stalled, limit_on }
--         vehKeyAndLabel(veh)-> id, label
--         getSpecs(label)    -> { tank_l = number }    (optional)
--         getMoney()         -> integer Eddies         (optional)
--         spendMoney(amount) -> bool                   (optional)
--     Returns true if the vehicle is inside a gas-station radius, else false.
--
--   Live setters (no re-setup required):
--     M.setRefillPerSec(rate)        -- L/s in percent terms (0..1 per second on tank)
--     M.setUnitPricePerLiter(price)  -- price per liter
--
-- Data files
--   • M.opts.points_path (default: "vm_gas_locations.json")
--       Format: array of { x: number, y: number, z: number, radius?: number }
--
-- Notes
--   • Audio is single-shot: we only Play once on the rising edge of “actively
--     refueling” and Stop as soon as refuel halts.
--   • Cost is accrued incrementally and billed per whole Eddie to avoid spam.
--   • If cost is enabled and “halt_when_broke” is true, refueling stops when
--     the player can’t pay.
-- =============================================================================

local M = {}

-- =============================================================================
-- Minimal JSON decode
-- =============================================================================
local function json_decode(str)
  if type(str) ~= "string" then return nil end
  local pos = 1

  local function skip()
    local _, e = str:find("^[ \t\r\n]*", pos)
    pos = (e or pos - 1) + 1
  end

  local function parse()
    skip()
    local c = str:sub(pos, pos)

    if c == "{" then
      pos = pos + 1
      skip()
      local obj = {}
      if str:sub(pos, pos) == "}" then
        pos = pos + 1
        return obj
      end
      while true do
        skip()
        if str:sub(pos, pos) ~= '"' then return nil end
        pos = pos + 1
        local ks = pos
        while true do
          local ch = str:sub(pos, pos)
          if ch == '"' then break
          elseif ch == '\\' then pos = pos + 1 end
          pos = pos + 1
        end
        local key = str:sub(ks, pos - 1):gsub('\\"', '"'):gsub('\\\\', '\\')
        pos = pos + 1
        skip()
        if str:sub(pos, pos) ~= ":" then return nil end
        pos = pos + 1
        local val = parse()
        if val == nil and str:sub(pos - 4, pos - 1) ~= "null" then return nil end
        obj[key] = val
        skip()
        local ch = str:sub(pos, pos)
        if ch == "}" then
          pos = pos + 1
          return obj
        elseif ch == "," then
          pos = pos + 1
        else
          return nil
        end
      end

    elseif c == "[" then
      pos = pos + 1
      skip()
      local arr = {}
      if str:sub(pos, pos) == "]" then
        pos = pos + 1
        return arr
      end
      local i = 1
      while true do
        local val = parse()
        if val == nil and str:sub(pos - 4, pos - 1) ~= "null" then return nil end
        arr[i] = val
        i = i + 1
        skip()
        local ch = str:sub(pos, pos)
        if ch == "]" then
          pos = pos + 1
          return arr
        elseif ch == "," then
          pos = pos + 1
        else
          return nil
        end
      end

    elseif c == '"' then
      pos = pos + 1
      local ss = pos
      while true do
        local ch = str:sub(pos, pos)
        if ch == '"' then break
        elseif ch == '\\' then pos = pos + 1 end
        pos = pos + 1
      end
      local s = str:sub(ss, pos - 1)
      pos = pos + 1
      s = s:gsub("\\n", "\n"):gsub('\\"', '"'):gsub('\\\\', '\\')
      return s

    else
      local lit = str:match("^[^,%]%}%s]+", pos)
      if not lit then return nil end
      pos = pos + #lit
      if lit == "true"  then return true
      elseif lit == "false" then return false
      elseif lit == "null"  then return nil
      else return tonumber(lit)
      end
    end
  end

  return parse()
end

-- =============================================================================
-- Utilities
-- =============================================================================
local function readFile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function getAudioSystem()
  local ok, sys = pcall(function()
    if GameInstance and GameInstance.GetAudioSystem then
      return GameInstance.GetAudioSystem()
    end
    if Game and Game.GetAudioSystem then
      return Game.GetAudioSystem()
    end
  end)
  return ok and sys or nil
end

local function playAudioEvent(name)
  if not name or name == "" then return end
  local sys = getAudioSystem()
  if not sys then return end
  pcall(function() sys:Play(name) end)
end

-- Try a provided stopEvent first; otherwise attempt common stop calls.
local function stopAudioEvent(name, stopEvent)
  local sys = getAudioSystem()
  if not sys then return end
  if stopEvent and stopEvent ~= "" then
    pcall(function() sys:Play(stopEvent) end)
    return
  end
  if sys.Stop           then pcall(function() sys:Stop(name) end) end
  if sys.StopByName     then pcall(function() sys:StopByName(name) end) end
  if sys.StopEvent      then pcall(function() sys:StopEvent(name) end) end
  if sys.StopEventByName then pcall(function() sys:StopEventByName(name) end) end
end

local function dist2(a, b)
  local dx = (a.x or 0) - (b.x or 0)
  local dy = (a.y or 0) - (b.y or 0)
  local dz = (a.z or 0) - (b.z or 0)
  return dx * dx + dy * dy + dz * dz
end

-- =============================================================================
-- Options / state
-- =============================================================================
M.opts = {
  points_path          = "vm_gas_locations.json",
  radius               = 5.0,
  cluster_radius       = 35.0,
  refill_per_sec       = 0.02,
  owner_only           = true,

  -- Audio (single-shot)
  sound_event          = "refuel",
  sound_stop_event     = nil,     -- optional explicit stop cue

  -- Cost
  enable_cost          = false,
  unit_price_per_liter = 5.0,
  halt_when_broke      = true,

  -- Tank fallback if no specs provided
  default_tank_l       = 50.0,

  debug                = false,
}

M.points      = {}     -- { {x, y, z, radius, r2}, ... }
M.stations    = {}
M._stationFuelExact = {}
M._stationFuelFactValue = {}
M._wasInRange = false
M._playing    = false  -- starts sound on rising edge of refueling; stop on falling edge
M._cost_acc   = 0.0
M._currentStationEmpty = false

local CAPACITY_PER_LOCATION_L = 30000
local MAX_STATION_CAPACITY_L = 380000

local function stationFact(idx, suffix)
  return string.format("vm_gas_station_%03d_%s", idx, suffix)
end

local function questsSystem()
  local ok, system = pcall(function()
    return Game and Game.GetQuestsSystem and Game.GetQuestsSystem()
  end)
  return ok and system or nil
end

local function getFact(name)
  local qs = questsSystem()
  if not qs then return 0 end
  local ok, value = pcall(function() return qs:GetFactStr(name) end)
  return ok and math.max(0, math.floor(tonumber(value) or 0)) or 0
end

local function setFact(name, value)
  local qs = questsSystem()
  if not qs then return false end
  value = math.max(0, math.floor(tonumber(value) or 0))
  return pcall(function() qs:SetFactStr(name, value) end)
end

-- Keep smooth fractional liters in memory while mirroring whole liters to the
-- quest fact. The mirror lets us distinguish our own rounded writes from a
-- manual/external fact edit and import the latter safely.
local function writeStationFuel(index, station, exactLiters)
  local capacity = tonumber(station and station.capacity_l) or 0
  exactLiters = math.max(0, math.min(capacity, tonumber(exactLiters) or 0))
  local factLiters = math.floor(exactLiters + 1e-6)

  local written = setFact(station.available_fact, factLiters)
  if written then
    M._stationFuelExact[index] = exactLiters
    M._stationFuelFactValue[index] = factLiters
  end
  return exactLiters, written
end

local function syncStationFuelFromFact(index, station)
  local factLiters = math.min(
    tonumber(station.capacity_l) or 0,
    getFact(station.available_fact)
  )

  if M._stationFuelFactValue[index] == nil
     or factLiters ~= M._stationFuelFactValue[index] then
    -- Something outside this module changed the persistent fact.
    M._stationFuelExact[index] = factLiters
    M._stationFuelFactValue[index] = factLiters
  end

  return tonumber(M._stationFuelExact[index]) or factLiters
end

-- Same algorithm and input order as vm_gas_markers.lua. Raw pump positions
-- retain their cluster index so proximity is checked at the actual pumps.
local function clusterPoints(points, radius)
  radius = tonumber(radius) or 0
  local used, stations = {}, {}
  local r2 = radius * radius

  if radius <= 0 then
    for i, point in ipairs(points) do
      point.station_idx = i
      stations[i] = { x = point.x, y = point.y, z = point.z, count = 1 }
    end
    return stations
  end

  for i = 1, #points do
    if not used[i] then
      local sx, sy, sz, n = points[i].x, points[i].y, points[i].z or 0, 1
      local members = { i }
      used[i] = true
      local changed = true

      while changed do
        changed = false
        local cx, cy = sx / n, sy / n
        for j = 1, #points do
          if not used[j] then
            local dx, dy = points[j].x - cx, points[j].y - cy
            if (dx * dx + dy * dy) <= r2 then
              used[j] = true
              sx, sy, sz, n = sx + points[j].x, sy + points[j].y,
                sz + (points[j].z or 0), n + 1
              members[#members + 1] = j
              changed = true
            end
          end
        end
      end

      local idx = #stations + 1
      stations[idx] = { x = sx / n, y = sy / n, z = sz / n, count = n }
      for _, memberIdx in ipairs(members) do
        points[memberIdx].station_idx = idx
      end
    end
  end

  return stations
end

local function initializeStationFacts()
  M._stationFuelExact = {}
  M._stationFuelFactValue = {}
  for idx, station in ipairs(M.stations) do
    station.capacity_l = math.min(
      MAX_STATION_CAPACITY_L,
      CAPACITY_PER_LOCATION_L * math.max(1, station.count or 1)
    )
    station.max_fact = stationFact(idx, "max_capacity_l")
    station.available_fact = stationFact(idx, "available_fuel_l")
    setFact(station.max_fact, station.capacity_l)

    -- New quest facts default to zero; existing values persist with the save.
    local available = math.min(station.capacity_l, getFact(station.available_fact))
    writeStationFuel(idx, station, available)
  end
end

function M.addFuelToAllStations(liters)
  liters = math.max(0, math.floor(tonumber(liters) or 0))
  if liters <= 0 then return 0 end

  for idx, station in ipairs(M.stations) do
    -- The quest fact is authoritative here so external/debug fact edits are
    -- imported instead of being overwritten by an older runtime cache value.
    local current = getFact(station.available_fact)
    local available = math.min(station.capacity_l, current + liters)
    writeStationFuel(idx, station, available)
  end
  return #M.stations
end

function M.setStationFuel(index, liters)
  index = math.floor(tonumber(index) or 0)
  local station = M.stations[index]
  if not station then return false, "unknown station index" end

  liters = math.max(0, math.floor(tonumber(liters) or 0))
  local available = math.min(station.capacity_l, liters)
  local _, written = writeStationFuel(index, station, available)
  if not written then return false, "quest fact write failed" end
  return true, available, station.capacity_l
end

function M.getStationStatus()
  local result = {}
  for index, station in ipairs(M.stations) do
    result[#result + 1] = {
      index = index,
      locations = station.count or 1,
      x = station.x or 0,
      y = station.y or 0,
      z = station.z or 0,
      available_l = getFact(station.available_fact),
      capacity_l = station.capacity_l or 0,
    }
  end
  return result
end

-- =============================================================================
-- Money helpers
-- =============================================================================
local MONEY_TDBID = nil

local function moneyTDBID()
  if MONEY_TDBID ~= nil then return MONEY_TDBID end
  local tid
  if type(t) == "function" then
    local ok, v = pcall(function() return t("Items.money") end)
    if ok and v then tid = v end
  end
  if not tid and TweakDBID and TweakDBID.new then
    local ok, v = pcall(function() return TweakDBID.new("Items.money") end)
    if ok and v then tid = v end
  end
  MONEY_TDBID = tid
  return MONEY_TDBID
end

local function ts()
  local ok, v = pcall(function()
    return (Game and Game.GetTransactionSystem and Game.GetTransactionSystem())
        or (GameInstance and GameInstance.GetTransactionSystem and GameInstance.GetTransactionSystem())
  end)
  return ok and v or nil
end

local function itemID_from_tdbid(tdbid)
  if not tdbid then return nil end
  if ItemID and ItemID.FromTDBID then
    local ok, iid = pcall(function() return ItemID.FromTDBID(tdbid) end)
    if ok and iid then return iid end
  end
  return nil
end

local function _get_money()
  local sys = ts()
  if not sys then return nil end
  local player = Game.GetPlayer()
  if not player then return nil end

  local tid = moneyTDBID()
  if tid and sys.GetItemQuantityByTDBID then
    local ok, qty = pcall(function() return sys:GetItemQuantityByTDBID(player, tid) end)
    if ok and type(qty) == "number" then return qty end
  end

  local iid = itemID_from_tdbid(tid)
  if iid and sys.GetItemQuantity then
    local ok, qty = pcall(function() return sys:GetItemQuantity(player, iid) end)
    if ok and type(qty) == "number" then return qty end
  end

  return nil
end

local function _take_money(amount)
  amount = math.floor(tonumber(amount) or 0)
  if amount <= 0 then return true end

  local sys = ts()
  if not sys then return false end
  local player = Game.GetPlayer()
  if not player then return false end

  local tid = moneyTDBID()
  if tid and sys.RemoveItemByTDBID then
    local ok = pcall(function() sys:RemoveItemByTDBID(player, tid, amount) end)
    return ok and true or false
  end

  local iid = itemID_from_tdbid(tid)
  if iid and sys.RemoveItem then
    local ok = pcall(function() sys:RemoveItem(player, iid, amount) end)
    return ok and true or false
  end

  return false
end

-- =============================================================================
-- Setup
-- =============================================================================
function M.setup(opts)
  if type(opts) == "table" then
    for k, v in pairs(opts) do
      M.opts[k] = v
    end
  end

  -- Load stations
  M.points = {}
  local raw = readFile(M.opts.points_path or "vm_gas_locations.json")
  if raw then
    local t = json_decode(raw)
    if type(t) == "table" then
      for _, p in ipairs(t) do
        if type(p) == "table" then
          local x = tonumber(p.x)
          local y = tonumber(p.y)
          local z = tonumber(p.z)
          if x and y and z then
            local r = tonumber(p.radius) or M.opts.radius or 5.0
            if r <= 0 then r = M.opts.radius or 5.0 end
            table.insert(M.points, { x = x, y = y, z = z, radius = r, r2 = r * r })
          end
        end
      end
    end
  end

  M.stations = clusterPoints(M.points, M.opts.cluster_radius)
  initializeStationFacts()

  -- Reset runtime flags (do NOT touch _playing so mid-session setup won't retrigger SFX)
  M._wasInRange = false
  -- keep _cost_acc as-is (carryover is fine)
end

-- =============================================================================
-- Update
-- =============================================================================
-- Call once per frame.
--   helpers:
--     ensureVehicle(id)            -> vehicle table (fuel_pct, stalled, limit_on)
--     vehKeyAndLabel(veh)          -> id, label
--     getSpecs(label)              -> { tank_l = number } (optional)
--     getMoney() / spendMoney(n)   -> optional overrides for money I/O
--
-- Returns: true if inside any gas-station radius, else false.
function M.update(dt, helpers)
  M._currentStationEmpty = false

  local player = Game.GetPlayer()
  if not player then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = false
    return false
  end

  local veh = player:GetMountedVehicle()
  if not veh then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = false
    return false
  end

  local pos = veh:GetWorldPosition()
  if not pos then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = false
    return false
  end

  local vpos = { x = pos.x, y = pos.y, z = pos.z }

  local inRange = false
  local stationIdx = nil
  for i = 1, #M.points do
    local s = M.points[i]
    if dist2(vpos, s) <= s.r2 then
      inRange = true
      stationIdx = s.station_idx
      break
    end
  end

  if not inRange then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = false
    return false
  end

  local activeStation = stationIdx and M.stations[stationIdx] or nil
  local activeAvailable = activeStation
    and syncStationFuelFromFact(stationIdx, activeStation) or 0
  M._currentStationEmpty = activeStation ~= nil and activeAvailable <= 1e-6

  -- Need helpers to refuel
  if not helpers
     or type(helpers.ensureVehicle) ~= "function"
     or type(helpers.vehKeyAndLabel) ~= "function" then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = true
    return true
  end

  -- Vehicle entry + specs
  local id, label = helpers.vehKeyAndLabel(veh)
  local v = helpers.ensureVehicle(id)
  if not v then
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = true
    return true
  end

  local tankL = M.opts.default_tank_l or 50.0
  if type(helpers.getSpecs) == "function" then
    local spec = helpers.getSpecs(label)
    if type(spec) == "table" and type(spec.tank_l) == "number" and spec.tank_l > 0 then
      tankL = spec.tank_l
    end
  end

  -- Already full? ensure stopped
  local f = tonumber(v.fuel_pct or 0) or 0
  if f >= 1.0 then
    v.fuel_pct = 1.0
    v.stalled  = false
    v.limit_on = false
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
    M._wasInRange = true
    return true
  end

  -- Decide if we can refuel this frame (cost gate if enabled)
  local rpsec  = M.opts.refill_per_sec or 0.02
  local df     = math.max(0, rpsec * (dt or 0))
  local willF  = math.min(1.0, f + df)
  local deltaF = willF - f

  local station = activeStation
  local availableL = activeAvailable
  local requestedL = deltaF * tankL
  local suppliedL = math.min(requestedL, math.max(0, availableL))
  deltaF = tankL > 0 and (suppliedL / tankL) or 0
  willF = math.min(1.0, f + deltaF)

  local moneyOK = true
  if M.opts.enable_cost and M.opts.halt_when_broke then
    local wallet
    if type(helpers.getMoney) == "function" then
      local ok, val = pcall(helpers.getMoney)
      if ok then wallet = val end
    else
      wallet = _get_money()
    end
    if type(wallet) == "number" and wallet <= 0 then
      moneyOK = false
    end
  end

  local activeRefuel = (deltaF > 0) and moneyOK

  -- AUDIO: rising/falling edge control
  if activeRefuel then
    if not M._playing and M.opts.sound_event and M.opts.sound_event ~= "" then
      playAudioEvent(M.opts.sound_event)
      M._playing = true
    end
  else
    if M._playing then
      stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
      M._playing = false
    end
  end

  if not activeRefuel then
    M._wasInRange = true
    return true
  end

  -- Cost handling (only when we’re truly adding fuel)
  if M.opts.enable_cost then
    local liters   = deltaF * tankL
    local price    = (M.opts.unit_price_per_liter or 5.0) * liters
    M._cost_acc    = M._cost_acc + price
    local toCharge = math.floor(M._cost_acc + 1e-6)

    if toCharge >= 1 then
      local chargedOK = true
      if type(helpers.spendMoney) == "function" then
        chargedOK = helpers.spendMoney(toCharge)
      else
        chargedOK = _take_money(toCharge)
      end

      if chargedOK then
        M._cost_acc = M._cost_acc - toCharge
      else
        -- couldn’t pay now; halt if asked
        if M.opts.halt_when_broke then
          if M._playing then
            stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
            M._playing = false
          end
          M._wasInRange = true
          return true
        end
      end
    end
  end

  -- Apply refuel
  v.fuel_pct = willF
  if station and suppliedL > 0 then
    availableL = math.max(0, availableL - suppliedL)
    writeStationFuel(stationIdx, station, availableL)
  end
  if v.fuel_pct > 0 then
    v.stalled  = false
    v.limit_on = false
  end

  -- Hit full this frame? stop immediately.
  if v.fuel_pct >= 1.0 and M._playing then
    stopAudioEvent(M.opts.sound_event, M.opts.sound_stop_event)
    M._playing = false
  end

  M._wasInRange = true
  return true
end

function M.isCurrentStationEmpty()
  return M._currentStationEmpty == true
end

-- =============================================================================
-- Live setters (avoid re-setup during refuel)
-- =============================================================================
function M.setRefillPerSec(rate)
  rate = tonumber(rate) or 0
  if rate < 0 then rate = 0 end
  local cur = tonumber(M.opts.refill_per_sec) or 0
  if math.abs(rate - cur) < 1e-6 then return false end
  M.opts.refill_per_sec = rate
  return true
end

function M.setUnitPricePerLiter(price)
  price = tonumber(price) or 0
  if price < 0 then price = 0 end
  local cur = tonumber(M.opts.unit_price_per_liter) or 0
  if math.abs(price - cur) < 1e-6 then return false end
  M.opts.unit_price_per_liter = price
  return true
end

return M
