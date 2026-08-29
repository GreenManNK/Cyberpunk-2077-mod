-- vm_stolen_vehicles.lua
-- ============================================================================
-- VehicleMileage — Ephemeral stats for non-owned (“stolen”) vehicle *types*
--
-- Purpose
--   Keeps short-lived, per-type state (NOT per individual car) for vehicles
--   the player doesn’t own. Each distinct vehicle label gets a temporary entry
--   with a believable starting odometer, partial fuel, and “abused” fuel
--   consumption. Entries expire if not seen again for a while.
--
-- Data kept per label (RAM only; no files):
--   {
--     meters     = <float>  -- odometer (meters)
--     fuel_pct   = <0..1>   -- current fuel
--     l100km     = <float>  -- effective consumption for this type
--     tank_l     = <float>  -- assumed tank size
--     last_seen  = <epoch>  -- TTL housekeeping
--     stalled    = <bool>   -- true at 0% fuel
--     limit_on   = <bool>   -- helper flag for limit feedback
--   }
--
-- Public API
--   M.setup(opts)                        -- reset cache; optional overrides:
--                                          { ttl_sec = 900, gc_sec = 5.0 }
--   M.tick(dt)                           -- call every frame (TTL pruning)
--   M.get_or_seed(label, baseSpec, isBike)
--                                       -- fetch or create entry for label
--   M.consume_and_update(e, dist_m, kmh) -- apply distance burn + odo advance
--
-- Seeding logic
--   * Odometer: draws from weighted kilometer tiers (cars vs bikes).
--   * Fuel: random between fuel_pct_min and fuel_pct_max.
--   * Consumption: scales baseSpec.l100km by a biased multiplier
--     (so “most” stolen vehicles are worse than stock), then clamps to
--     absolute min/max.
-- ============================================================================

local M = {
  -- Stolen fuel-economy shaping
  l100_mult_min = 2.0,   -- min multiplier vs base
  l100_mult_max = 4.0,   -- max multiplier vs base
  l100_bias     = 1.6,   -- >1 skews toward high end (more bad cars)
  l100_min_abs  = 10.0,  -- absolute floor after multiply
  l100_max_abs  = 70.0,  -- absolute cap after multiply

  -- Fuel & odo ranges for stolen vehicles
  fuel_pct_min  = 0.35,
  fuel_pct_max  = 0.85,
}

-- Odometer distribution (kilometers), weighted tiers — cars
M.odo_tiers_car = {
  { min =    800, max = 100000, weight = 0.80 }, -- common
  { min = 100000, max = 200000, weight = 0.18 }, -- rare
  { min = 200000, max = 400000, weight = 0.02  }, -- rarest
}

-- Bikes (independent table so you can tune later)
M.odo_tiers_bike = {
  { min =    300, max =  80000, weight = 0.80 },
  { min =  80000, max = 200000, weight = 0.18 },
  { min = 200000, max = 300000, weight = 0.01 },
}

-- Module options (RAM only)
M.opts = {
  ttl_sec = 900,   -- forget a type after 15 min of not seeing it
  gc_sec  = 5.0,   -- prune TTL every 5s
}

-- ────────────────────────────── State ────────────────────────────────────────
local CACHE = {}   -- [veh_label] = { meters, fuel_pct, l100km, tank_l, last_seen, ... }
local gcAcc = 0.0

-- ──────────────────────────── Helpers ────────────────────────────────────────
local function randf(a, b)
  return a + math.random() * (b - a)
end

local function rand_biased(a, b, bias)
  bias = tonumber(bias) or 1
  local u = math.random()
  if bias > 0 and bias ~= 1 then u = u ^ (1 / bias) end
  return a + (b - a) * u
end

local function pick_weighted_km(tiers)
  local total = 0
  for _, t in ipairs(tiers) do total = total + (t.weight or 0) end
  if total <= 0 then
    local t = tiers[1]
    return randf(t.min, t.max)
  end

  local r, acc = math.random() * total, 0
  for _, t in ipairs(tiers) do
    acc = acc + (t.weight or 0)
    if r <= acc then
      return randf(t.min, t.max)        -- uniform within chosen tier
      -- (Alternative) bias within tier:
      -- return rand_biased(t.min, t.max, 1.2)
    end
  end
  local t = tiers[#tiers]
  return randf(t.min, t.max)
end

local function pick_odo_km(isBike)
  local tiers = isBike and M.odo_tiers_bike or M.odo_tiers_car
  return pick_weighted_km(tiers)
end

local function seed_entry(label, baseSpec, isBike)
  local tank_l = (type(baseSpec) == "table" and tonumber(baseSpec.tank_l))
                 or (isBike and 18 or 35)

  -- Odometer (weighted ranges)
  local meters = pick_odo_km(isBike) * 1000.0

  -- Fuel (partial tank)
  local fuel_pct = randf(M.fuel_pct_min, M.fuel_pct_max)

  -- “Abused” consumption
  local base_l100 = (type(baseSpec) == "table" and tonumber(baseSpec.l100km))
                    or (isBike and 6 or 12)
  local mult = rand_biased(M.l100_mult_min, M.l100_mult_max, M.l100_bias)
  local l100 = base_l100 * mult
  if l100 < M.l100_min_abs then l100 = M.l100_min_abs end
  if l100 > M.l100_max_abs then l100 = M.l100_max_abs end

  return {
    meters    = meters,
    fuel_pct  = fuel_pct,
    l100km    = l100,
    tank_l    = tank_l,
    last_seen = os.time(),
    stalled   = false,
    limit_on  = false,
  }
end

local function prune_expired(now)
  local ttl = tonumber(M.opts.ttl_sec) or 900
  for label, e in pairs(CACHE) do
    if type(e) == "table" and type(e.last_seen) == "number" and (now - e.last_seen) > ttl then
      CACHE[label] = nil
    end
  end
end

-- ───────────────────────────── Public API ────────────────────────────────────
function M.setup(opts)
  if type(opts) == "table" then
    for k, v in pairs(opts) do M.opts[k] = v end
  end
  CACHE = {}
  gcAcc = 0.0
  math.randomseed(os.time())
end

-- Call every frame from init.lua
function M.tick(dt)
  gcAcc = (gcAcc or 0) + (dt or 0)
  if gcAcc >= (tonumber(M.opts.gc_sec) or 5.0) then
    prune_expired(os.time())
    gcAcc = 0.0
  end
end

-- Get (or create) the entry for a vehicle type
function M.get_or_seed(label, baseSpec, isBike)
  if type(label) ~= "string" then return nil end
  local e = CACHE[label]
  if not e then
    e = seed_entry(label, baseSpec, isBike)
    CACHE[label] = e
  end
  e.last_seen = os.time()
  return e
end

-- Apply distance-based consumption (and update odometer)
function M.consume_and_update(e, dist_m, kmh)
  if not e then return end
  dist_m = tonumber(dist_m) or 0
  if dist_m <= 0 then return end

  -- Simple speed multiplier (roughly mirrors main logic)
  kmh = math.max(0, math.min(400, tonumber(kmh or 0) or 0))
  local base = 40
  local r = kmh / base
  local mult = (r <= 1.0) and (0.9 + 0.1 * r) or (1.0 + 0.50 * (r - 1.0) + 0.95 * (r - 1.0) * (r - 1.0))
  if mult > 12.0 then mult = 12.0 end

  local l100   = e.l100km or 20
  local used_l = (dist_m / 100000.0) * l100 * mult

  local tank  = e.tank_l or 35
  local cur_l = math.max(0, math.min(tank, (e.fuel_pct or 0) * tank))
  local new_l = math.max(0, math.min(tank, cur_l - used_l))
  e.fuel_pct  = (tank > 0) and (new_l / tank) or 0

  e.meters = (e.meters or 0) + dist_m
  if (e.fuel_pct or 0) <= 0 then
    e.fuel_pct = 0
    e.stalled  = true
    e.limit_on = false
  end
  e.last_seen = os.time()
end

return M
