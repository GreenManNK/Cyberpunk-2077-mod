-- VehicleMileage/init.lua
-- ============================================================================
-- Odometer + Fuel system for Cyber Engine Tweaks (CET)
--
-- Features
-- - Distance-based fuel consumption with speed-aware multiplier and optional idle burn.
-- - Gas-station proximity refueling (via vm_gas_station) with dynamic price (€/L).
-- - Per-vehicle specs (L/100km, tank size) with inline editors in the CET window.
-- - HUD bridge using quest facts (ODO, fuel %, price plate).
-- - Optional limiter/stall at empty; different caps for cars/bikes.
-- - Configurable persistent maintenance intervals with overdue fuel-system faults.
-- - Stolen or quest-like vehicles can be ignored automatically (vm_vehicle_ignore).
-- - Native Settings tab to tweak price, toggles, HUD position and price plate offsets.
-- - Safe file IO + tiny JSON helpers (no external deps).
--
-- Files (created/used)
--   vm_settings.json            - global UI/settings (price, toggles, HUD/plate pos)
--   vm_config_cars.json         - user-editable car specs
--   vm_config_bikes.json        - user-editable bike specs
--   backup/                     - last 10 config versions per spec file
--   vm_vehicle_ignore.json      - persistent ignore list
--   vm_ignore_seeds.json        - seeds merged into ignore list at startup (optional)
--   vm_session/<key>.lua        - per-save odometer/fuel state (managed by vm_save.lua)
--
-- Requirements
--   - CET (Cyber Engine Tweaks)
--   - Optional: Native Settings UI (detected at runtime)
--
-- Tip
--   While mounted in a player-owned vehicle that already has a spec entry,
--   open CET (Insert) → “Odometer + Fuel” and edit:
--     Edit spec:  L/100km [input] Save   Tank (L) [input] Save
-- ============================================================================
VM_VERSION = "v4.13-0E"

-- 0-Engine integration
local Engine = nil
local Mod = nil


local GAS    = require("vm_gas_station")
VM_GAS_ECONOMY = require("vm_gas_economy")
VM_CONFIG_BACKUP = require("vm_config_backup")
local STOLEN = require("vm_stolen_vehicles")
local IGNORE = require("vm_vehicle_ignore")
local MARKERS = require("vm_gas_markers")
local REPAIR = require("vm_repair_stations")

VM_GASCAN = require("vm_gascan")
VM_MAINTENANCE = require("vm_maintenance")

VM_WEATHER_CONDITION = {
  temperatureC = nil,
  status = 0,
}

function VM_WEATHER_CONDITION.Refresh()
  local player = Game.GetPlayer()
  if not player then
    VM_WEATHER_CONDITION.temperatureC = nil
    VM_WEATHER_CONDITION.status = 0
    return nil
  end

  local statusOK, status = pcall(function()
    return player:VM_GetWeatherConditionStatus()
  end)
  VM_WEATHER_CONDITION.status =
    statusOK and math.floor(tonumber(status) or 0) or 0

  if VM_WEATHER_CONDITION.status ~= 2 then
    VM_WEATHER_CONDITION.temperatureC = nil
    return nil
  end

  local ok, value = pcall(function()
    return player:VM_GetWeatherConditionTemperatureC()
  end)

  value = ok and tonumber(value) or nil
  VM_WEATHER_CONDITION.temperatureC =
    value ~= nil and value > -900 and value or nil

  return VM_WEATHER_CONDITION.temperatureC
end

function VM_WEATHER_CONDITION.GetDebugText()
  if VM_WEATHER_CONDITION.status <= 0 then
    return "Weather Condition: not installed"
  end

  if VM_WEATHER_CONDITION.status == 1 then
    return "Weather Condition: installed (disabled)"
  end

  if VM_WEATHER_CONDITION.status == 3 then
    return "Weather Condition: installed (initializing)"
  end

  local temperatureC =
    tonumber(VM_WEATHER_CONDITION.temperatureC)
  if temperatureC == nil then
    return "Weather Condition: active | temperature unavailable"
  end

  local wearMultiplier = 1.0
  if temperatureC >= 37.0 then
    wearMultiplier = 2.0
  elseif temperatureC >= 34.0 then
    wearMultiplier = 1.5
  end

  return ("Weather Condition: active | %d C | maintenance wear x%.1f")
    :format(math.floor(temperatureC + 0.5), wearMultiplier)
end

if package and package.loaded then package.loaded["vm_3d_controls"] = nil end
VM3D_CONTROLS = require("vm_3d_controls")

POINTS_PATH        = "vm_gas_locations.json"
REPAIR_POINTS_PATH = "vm_repair_stations.json"


local VMCONST = {
  TRACK = {
    OWNER_ONLY        = true,
    JITTER_METERS     = 0.05,
    MAX_STEP_METERS   = 150.0,
    TELEPORT_THRESH_M = 120.0,
  },

  SPEED = {
    BASE_KMH_CAR  = 40,
    BASE_KMH_BIKE = 33,
    LINEAR_GAIN   = 0.50,
    AERO_QUAD     = 0.95,
    MIN_MULT      = 0.90,
    MAX_MULT      = 12.0,
    CLAMP_KMH     = 400,
  },

  IDLE = {
    L_PER_H_CAR   = 0.7,
    L_PER_H_BIKE  = 0.4,
		L_PER_H_AV    = 9.2,  -- AVs (DAV & any Vehicle.av_*) idle burn
    SPEED_KMH     = 1.0,
  },

  PRICE = {
    DYN_MIN_MULT   = 0.90,
    DYN_MAX_MULT   = 1.10,
    DYN_VOLATILITY = 0.25,
    DYN_MEAN_REVERT= 0.35,
  },

  REFILL = {
    KNEE            = 0.60,
    RATE_FAST       = 0.035,  -- L/s at ~60%
    RATE_SLOW_ENDS  = 0.006,  -- near 0%/100%
    CHANGE_EPS      = 0.0005,
    RATE_UPDATE_COOLDOWN = 0.25,
  },

  LIMITER = {
    MAX_KMH_CAR  = 200,
    MAX_KMH_BIKE = 200,
    HYST_KMH     = 1.0,
  },

  MISC = {
    CONFIG_RELOAD_SEC = 25.0,
    HUD_DELAY_SECONDS = 2.7,
		-- HUD Auto-Hide (VehicleMileage)
    AUTO_HIDE_DEF_SECONDS  = 20.0,  -- default delay
    AUTO_HIDE_MIN_SECONDS  = 0.0,
    AUTO_HIDE_MAX_SECONDS  = 120.0,
    AUTO_HIDE_DEF_FUEL_PCT = 25.0,  -- 25% = default "always visible when low fuel"
  },

  -- Oil temperature model (°C)
	OIL = {
		CAP_C         = 250.0,
		DAY_MIN       = 25.0,  DAY_MAX   = 34.0,
		NIGHT_MIN     = 15.0,  NIGHT_MAX = 24.0,
		JITTER_PCT    = 0.05,

		-- New rule-based rates (all are per-second factors)
		K_IDLE_TO_LO        = 0.007,

		-- <100 km/h → lo
		K_DRIVE_TO_LO_UP    = 0.010,  -- when T < lo (warming up toward lo)
		K_DRIVE_TO_LO_DOWN  = 0.0070,  -- when T > lo (cooling down toward lo)  ← slower
		K_DRIVE_TO_LO       = 0.010,  -- fallback if code doesn’t see UP/DOWN

		-- 100+ km/h → hot / above optimal max
		-- This means oil starts heating aggressively once you drive too fast.
		K_DRIVE_TO_HI_UP    = 0.020,
		K_DRIVE_TO_HI_DOWN  = 0.018,
		K_DRIVE_TO_HI       = 0.020,

		-- Fast driving threshold.
		-- Old logic started the "very fast" heat zone at 140 km/h.
		-- 115 km/h feels better for Cyberpunk driving.
		FAST_START_KMH      = 125.0,

		-- Very-fast heat behaviour
		K_FAST_TO_EXCEED_UP   = 0.055,
		K_FAST_TO_EXCEED_DOWN = 0.018,
		HI_EXCEED_PER_KMH     = 0.35,

		-- stability damper, pulls *to target*, not ambient
		K_COOL_MOV          = 0.020,

		-- unmounted cooldown
		-- Lower value = much slower cooldown while not mounted.
		K_COOL_OFF          = 0.0015,


		-- Defaults for optimal range (used if a spec has no oil fields)
		DEF_CAR_MIN   = 80.0,  DEF_CAR_MAX  = 120.0,
		DEF_BIKE_MIN  = 80.0,  DEF_BIKE_MAX = 100.0,
	},


}

-- Defaults for auto-creating a spec (now read oil defaults from VMCONST)
local DEFAULTS_CAR  = {
  l100km = 12, tank_l = 40,
  oil_opt_min = VMCONST.OIL.DEF_CAR_MIN,
  oil_opt_max = VMCONST.OIL.DEF_CAR_MAX,
}
local DEFAULTS_BIKE = {
  l100km =  6, tank_l = 18,
  oil_opt_min = VMCONST.OIL.DEF_BIKE_MIN,
  oil_opt_max = VMCONST.OIL.DEF_BIKE_MAX,
}

-- AV base defaults (used when auto-creating a spec for AVs)
local DEFAULTS_AV = {
  l100km = 6,   -- 6 L/100km
  tank_l = 120, -- 120 L tank
  -- use car oil temperature range unless you want a separate AV range
  oil_opt_min = VMCONST.OIL.DEF_CAR_MIN,
  oil_opt_max = VMCONST.OIL.DEF_CAR_MAX,
}

local FALLBACK_CAR  = {
  l100km = 12, tank_l = 40,
  oil_opt_min = VMCONST.OIL.DEF_CAR_MIN,
  oil_opt_max = VMCONST.OIL.DEF_CAR_MAX,
}
local FALLBACK_BIKE = {
  l100km =  6, tank_l = 18,
  oil_opt_min = VMCONST.OIL.DEF_BIKE_MIN,
  oil_opt_max = VMCONST.OIL.DEF_BIKE_MAX,
}


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Configuration                                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local WINDOW_TITLE     = "Odometer + Fuel"
-- Save system:
-- Runtime vehicle values are now stored in persistent quest facts.
-- vm_config_cars.json / vm_config_bikes.json only store specs + fact key names.

-- HUD bridge (quest facts read by Redscript HUD)
FACT_HUD_VISIBLE       = "vm_hud_visible"
FACT_HUD_METERS        = "vm_hud_meters"
FACT_HUD_FUEL_PERMILLE = "vm_hud_fuel_permille"
FACT_HUD_SPEED_KMH     = "vm_hud_speed_kmh"
FACT_HUD_VEH_COND_PCT  = "vm_hud_vehicle_cond_pct"
FACT_HUD_OIL_TEMP_C    = "vm_hud_oil_temp_c"
FACT_FG_TEMP_VISIBLE   = "vm_fg_temp_visible"

-- Price widget facts (for Redscript HUD)
FACT_HUD_PRICE_VISIBLE = "vm_hud_price_visible"
FACT_HUD_PRICE_CENTS   = "vm_hud_price_cents"

-- User-editable specs
local CAR_SPECS_PATH  = "vm_config_cars.json"
local BIKE_SPECS_PATH = "vm_config_bikes.json"
VM3D_PRESET_DIR = VM3D_PRESET_DIR or "3DPresets"



-- Fuel & limiter
local FUEL_ENABLED        = true
local DETECT_BIKES        = true
local LIMIT_SPEED_AT_ZERO = true
local EMPTY_SPEED_PERCENT = 0.04
local SHOW_LIMIT_MSG      = true
local SHOW_REFUEL_BUTTON  = false
local REGISTER_REFUEL_HOTKEY = false

-- Small global nozzle-speed bump (1.0 = unchanged). 1.15 ≈ +15% faster.
local REFILL_GLOBAL_SPEED = 1.0

-- Dev-only UI for adding gas stations
local add_gas_station_button = false     -- <— set to false to hide the UI
local DEV_GAS_RADIUS_STR     = "2"    -- editable radius field (string for input box)
-- Dev-only UI for adding repair stations
local add_repair_station_button = false  -- set to false to hide the UI
local DEV_REPAIR_RADIUS_STR     = "3"   -- editable radius field
local DEV_REPAIR_PRICE_STR      = "500" -- fixed repair price for this station
-- Dev-only: repair-zone world-state FX node paths
local DEV_REPAIR_FX_STR = DEV_REPAIR_FX_STR or {
  "", "", "", "", "",
  "", "", "", "", ""
}

-- Stolen cars behavior
local STOLEN_STALL_AT_ZERO = true

-- Native Settings UI
local NS_TAB            = "/VehicleMileage"
local NS_SUB_FUEL       = NS_TAB .. "/Fuel"
local NS_SUB_REPAIR     = NS_TAB .. "/Repair"
NS_SUB_MAINTENANCE      = NS_TAB .. "/Maintenance"
local DEFAULT_PRICE_EPL = 50.0 -- base slider value (€/L)
VM_MAINT_MIN_KM_DEFAULT = 10
VM_MAINT_MAX_KM_DEFAULT = 15
VM_MAINT_KM_SLIDER_MIN  = 1
VM_MAINT_KM_SLIDER_MAX  = 1000
local NS_SUB_HUD_POS    = NS_TAB .. "/HUD Position"
local NS_SUB_PLATE      = NS_TAB .. "/Price Plate"
local NS_SUB_IGNORE     = NS_TAB .. "/Ignore"
NS_BUILT = NS_BUILT or false
-- HUD widget paths
local NS_SUB_WIDGET     = NS_TAB .. "/HUD Widget"
local NS_SUB_WIDGET_FG  = NS_TAB .. "/FuelGauge Controls"
local NS_SUB_WIDGET_AUTOHIDE = NS_TAB .. "/HUD Auto-Hide"
local NS_SUB_LB         = NS_TAB .. "/Leaderboard Controls"
-- extra guard to be absolutely sure FG UI is created once
local FG_UI_BUILT       = FG_UI_BUILT or false
-- Persistent settings
local VM_SETTINGS_PATH  = "vm_settings.json"

-- Ignore list seeding
local IGNORE_SEED_PATH = "vm_ignore_seeds.json"

-- Labels likely used by quests (auto-ignore heuristics; case-insensitive)
local QUEST_LABEL_PATTERNS = {
"_quest",
".quest",
"_qst",
"^vehicle%.[ms]?q%d+",  -- matches vehicle.q000 / mq015 / sq097 …
"_quest_",
"questcar",
}


-- Optional idle burn
local IDLE_BURN_ENABLED = true


-- Config reload (dev convenience)
local DEV_OVERLAY_RELOAD_ONLY = true



-- Derived
local JITTER2  = VMCONST.TRACK.JITTER_METERS * VMCONST.TRACK.JITTER_METERS
local MAXSTEP2 = VMCONST.TRACK.MAX_STEP_METERS * VMCONST.TRACK.MAX_STEP_METERS


-- HUD red toast queue
local PENDING_TOAST = PENDING_TOAST or nil
local lastToastAt   = lastToastAt or 0.0
local TOAST_COOLDOWN = 0.75   -- seconds between toasts to avoid spam


function _now() return os.clock() end
function _canEmit() return (_now() - lastToastAt) >= TOAST_COOLDOWN end -- end function _now

function _showRed(msg)
  pcall(function()
    local ply = Game.GetPlayer()
    if ply and ply.SetWarningMessage then
      ply:SetWarningMessage(tostring(msg))
    else
      print("[VehicleOdometer] " .. tostring(msg))
    end
end)
end -- end function (anonymous)

-- --- Menu detection shim (keeps your old isInMenu if you had one) ---
function _isPaused()
  local ok, paused = pcall(function()
    local srh = Game.GetSystemRequestsHandler()
    return srh and srh:IsGamePaused() or false
  end) -- end function (anonymous)
if ok and paused then return true end -- end function _isPaused

local ts = Game.GetTimeSystem and Game.GetTimeSystem()
if ts and ts.IsPaused and ts:IsPaused() then
  return true
end
return false
end

-- Only define if not already present in your script:
isInMenu = isInMenu or function() return _isPaused() end -- end function _showRed

function queueToast(msg)
if not msg or msg == "" then return end -- end function queueToast
local inMenu = (isInMenu and isInMenu()) or false
if inMenu then
  PENDING_TOAST = msg
  return
end
if _canEmit() then
  _showRed(msg)
  lastToastAt = os.clock()
  PENDING_TOAST = nil
else
  PENDING_TOAST = msg
end
end

-- Map current fuel % (0..1) to a bell-ish refill rate (slow → fast → slow)
function refillRateForLevel(pct)
  pct = math.max(0.0, math.min(1.0, tonumber(pct or 0) or 0))
  local a
	if pct <= VMCONST.REFILL.KNEE then
		a = pct / VMCONST.REFILL.KNEE
	else
		a = 1.0 - ((pct - VMCONST.REFILL.KNEE) / (1.0 - VMCONST.REFILL.KNEE))
	end
	return VMCONST.REFILL.RATE_SLOW_ENDS
				 + (VMCONST.REFILL.RATE_FAST - VMCONST.REFILL.RATE_SLOW_ENDS) * a

end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ vm_save loader (require or dofile fallback)                               ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

function tryRequireVmSave()
  local ok, mod = pcall(function()
    if type(package) == "table" and type(package.path) == "string" then
      if not package.path:find("./?.lua", 1, true) then
        package.path = package.path .. ";./?.lua;./?/init.lua"
      end
  end
if type(require) == "function" then
  return require("vm_save")
end
return nil
end) -- end function (anonymous)
if ok and type(mod) == "table" then return mod end -- end function tryRequireVmSave

local ok2, mod2 = pcall(function() return dofile("vm_save.lua") end)
if ok2 and type(mod2) == "table" then return mod2 end -- end function (anonymous)

print("[VehicleOdometer] ERROR: cannot load vm_save.lua (" .. tostring(mod) .. ", " .. tostring(mod2) .. ")")
return nil
end

local SAVE = tryRequireVmSave()
if not SAVE then
  registerForEvent("onInit", function()
    print("[VehicleOdometer] vm_save.lua missing or failed to load. Aborting.")
  end) -- end function (anonymous)
return
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Tiny JSON + file I/O (for *spec* files only)                              ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function readFile(path)
  local f = io.open(path, "r")
if not f then return nil end -- end function readFile
local s = f:read("*a"); f:close()
return s
end

local function writeFile(path, data)
  local f = io.open(path, "w")
if not f then return false end -- end function writeFile
f:write(data or ""); f:close()
return true
end

-- Minimal JSON decoder
local function json_decode(str)
if type(str) ~= "string" then return nil end -- end function json_decode
local pos = 1

local function skip()
  local _, e = str:find("^[ \t\r\n]*", pos)
  pos = (e or pos - 1) + 1
end -- end function skip

local function parse()
  skip()
  local c = str:sub(pos, pos)

  if c == "{" then
    pos = pos + 1; skip()
    local obj = {}
  if str:sub(pos, pos) == "}" then pos = pos + 1; return obj end
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
local key = str:sub(ks, pos - 1):gsub('\"', '"'):gsub('\\\\', '\\')
pos = pos + 1; skip()
if str:sub(pos, pos) ~= ":" then return nil end
pos = pos + 1
local val = parse()
if val == nil and str:sub(pos - 4, pos - 1) ~= "null" then return nil end
obj[key] = val
skip()
local ch = str:sub(pos, pos)
if ch == "}" then
  pos = pos + 1; return obj
elseif ch == "," then
    pos = pos + 1
  else
    return nil
  end
end

elseif c == "[" then
    pos = pos + 1; skip()
    local arr = {}
  if str:sub(pos, pos) == "]" then pos = pos + 1; return arr end
  local i = 1
  while true do
    local val = parse()
  if val == nil and str:sub(pos - 4, pos - 1) ~= "null" then return nil end
  arr[i] = val; i = i + 1; skip()
  local ch = str:sub(pos, pos)
  if ch == "]" then
    pos = pos + 1; return arr
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
  s = s:gsub("\\n", "\n"):gsub('\"', '"'):gsub('\\\\', '\\')
  return s

else
  local lit = str:match("^[^,%]%}%s]+", pos)
if not lit then return nil end
pos = pos + #lit
if     lit == "true"  then return true
elseif lit == "false" then return false
  elseif lit == "null"  then return nil
    else  return tonumber(lit)
    end
end
end

return parse()
end

local function json_escape(s)
  return (tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'))
end -- end function json_escape

local function json_encode(v, indent, lvl)
  indent = indent or 0
  lvl    = lvl or 0
  local sp  = (indent > 0) and string.rep(" ", indent * lvl) or ""
  local spc = (indent > 0) and string.rep(" ", indent * (lvl + 1)) or ""
  local nl  = (indent > 0) and "\n" or ""
  local sep = (indent > 0) and ",\n" or ","

  local function enc(x)
    local t = type(x)
    if t == "nil"     then return "null"
    elseif t == "number"  then return tostring(x)
      elseif t == "boolean" then return x and "true" or "false"
        elseif t == "string"  then return '"' .. json_escape(x) .. '"'
          elseif t == "table"   then
              local isArr, n = true, 0
              for k,_ in pairs(x) do
          if type(k) ~= "number" then isArr = false; break else if k > n then n = k end end
          end
        if isArr then
          local out = {}
        for i = 1, n do out[i] = enc(x[i]) end
        return "[" .. table.concat(out, ",") .. "]"
      else
        local out = {}
        for k, v2 in pairs(x) do
          table.insert(out, (indent > 0 and spc or "") .. '"' .. json_escape(k) .. '": ' .. enc(v2))
        end
      return "{" .. nl .. table.concat(out, sep) .. nl .. (indent > 0 and sp or "") .. "}"
    end
else
  return '""'
end
end

return enc(v)
end


-- Leaderboard (LB) defaults (relative to the Price Plate center)
-- NOTE: scale uses the same convention as FuelGauge: 600 = 1.00x
local LB_DEF_DX     = -850      -- pixels, 0..7000; larger = further LEFT (matches VMHUD LB implementation)
local LB_DEF_DY     = 800      -- pixels, 0..7000; larger = further UP
local LB_DEF_SCALE  = 480      -- 0.80x (0.8 * 600) to match VMHUD default LB_SCALE=0.8

-- FuelGauge (FG) defaults (runtime fallbacks; 600 = 1.00x)
local FG_DEF_DX     = -1510     -- pixels, -7000..7000; +X=RIGHT, -X=LEFT
local FG_DEF_DY     =  275      -- pixels, -7000..7000; +Y=DOWN,  -Y=UP
local FG_DEF_SCALE  =  330      -- milli-scale (600 = 1.00x → 330 ≈ 0.55x)

-- Persistent UI settings (vm_settings.json)
local SETTINGS = {
price_epl            = DEFAULT_PRICE_EPL,
price_dyn_enable     = true,
fuel_enabled         = true,
maintenance_enabled  = true,
maintenance_min_km   = VM_MAINT_MIN_KM_DEFAULT,
maintenance_max_km   = VM_MAINT_MAX_KM_DEFAULT,

-- Floating gas-station icons shown directly in the 3D world.
-- World-map and minimap pins are not affected.
gas_pins_show_in_world = true,

-- Repair price modifier:
-- 0 = normal station price
-- -50 = 50% cheaper
-- +50 = 50% more expensive
repair_price_adjust_pct = nil,

-- Default repair-bay method requires the player to exit manually.
-- When enabled, the bay waits five seconds, dismounts, respawns, and remounts.
repair_automatic_enabled = false,

hud_x                = nil,
hud_y                = nil,  -- normalized 0..1 (bottom→top)
price_dx_px          = nil,  -- price plate offset X (px): +left / -right
price_dy_px          = nil,  -- price plate offset Y (px): +up   / -down
stolen_stall_at_zero = true,
-- NEW (widget switch + FuelGauge transforms)
widget_mode         = "fuelgauge",    -- "vmhud", "fuelgauge", or "3dwidget"


-- Shared FuelGauge + Leaderboard color theme
-- 0 = current/default
fg_theme            = 0,

fg_enabled          = nil,   -- nil ⇒ enabled
fg_temp_enabled     = nil,   -- nil ⇒ enabled (controls temperature meter visibility)
fg_dx_px            = nil,   -- -7000..7000
fg_dy_px            = nil,   -- -7000..7000
fg_scale            = nil,   -- 0..7000 (600 = 1.00x)
-- Leaderboard (written to JSON only after user changes)
lb_enabled          = nil,   -- nil = use default (enabled)
lb_dx_px            = nil,   -- 0..7000
lb_dy_px            = nil,   -- 0..7000
lb_scale            = nil,   -- 0..7000 (600=1.00x)
-- 3D World widget config.
-- Global, saved to vm_settings.json only when pressing Save in the 3D World tab.
world3d             = nil,
-- HUD Auto-Hide (Legacy Digits + Fuel Gauge)
auto_hide_enabled   = nil,   -- nil/false = off
auto_hide_seconds   = nil,   -- nil ⇒ VMCONST.MISC.AUTO_HIDE_DEF_SECONDS
auto_hide_fuel_pct  = nil,   -- nil ⇒ VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT

}
-- Shared HUD theme:
-- Used by VMFuelGauge.reds and VMHUD.reds through quest fact vm_fg_theme.
-- 0 = current/default
VM_FG_THEME_VALUES = {
  "Default",
  "Cyberpunk Yellow",
  "E3 Red",
  "Mox Pink",
  "Blue",
  "Light Blue",
  "Neon Green",
  "Silver",
  "Gold",
  "Pure Yellow",
}

function VM_ClampThemeId(v)
  v = tonumber(v) or 0
  v = math.floor(v + 0.5)

  if v < 0 then v = 0 end
  if v > 9 then v = 9 end

  return v
end

function VM_ThemeIndexFromId(themeId)
  return VM_ClampThemeId(themeId) + 1
end

function VM_ThemeIdFromIndex(index)
  return VM_ClampThemeId((tonumber(index) or 1) - 1)
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3D World global config defaults                                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

VMWORLD_FONT_OPTIONS = {
  [0]  = "Digital Readout",
  [1]  = "Raj",
  [2]  = "Raj RU",
  [3]  = "Industry",
  [4]  = "Arial",
  [5]  = "Blender",
  [6]  = "Orbitron",
  [7]  = "Nawar Arabic",
  [8]  = "Jing Xi Traditional Chinese",
  [9]  = "Mgenplus JP",
  [10] = "Nanum KOR",
  [11] = "Arame",
  [12] = "Smart Font JP",
  [13] = "Printable4U Thai",
}

VMWORLD_FONT_ORDER = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 }

VMWORLD_OBJECT_ORDER = { "lb", "aux1", "aux2", "aux3" }

VMWORLD_AUX_INDEX = {
  aux1 = 1,
  aux2 = 2,
  aux3 = 3,
}

VMWORLD_DEFAULTS = {
	lb = {
		theme = 0,
		font_index = 6,
		font_size = 28,
		brightness_milli = 1000,
		scale = 1000,
		x = 0,
		y = 0,
		hidden = false,
		border_hidden = false,
	},

	aux1 = {
		theme = 0,
		font_index = 6,
		font_size = 32,
		brightness_milli = 1000,
		scale = 1000,
		x = -360,
		y = 0,
		hidden = true,
	},

  aux2 = {
    theme = 0,
    font_index = 6,
    font_size = 32,
		brightness_milli = 1000,
    scale = 1000,
    x = 0,
    y = 0,
    hidden = true,
  },

  aux3 = {
    theme = 0,
    font_index = 6,
    font_size = 32,
		brightness_milli = 1000,
    scale = 1000,
    x = 360,
    y = 0,
    hidden = true,
  },
}

VMWORLD_STATE = VMWORLD_STATE or nil
VMWORLD_STATUS = VMWORLD_STATUS or ""

function VMWorld_ClampInt(v, minV, maxV, def)
  v = tonumber(v)

  if v == nil then
    v = def or minV or 0
  end

  if v >= 0 then
    v = math.floor(v + 0.5)
  else
    v = math.ceil(v - 0.5)
  end

  if v < minV then return minV end
  if v > maxV then return maxV end

  return v
end

function VMWorld_CopyDefault(key)
  local d = VMWORLD_DEFAULTS[key] or VMWORLD_DEFAULTS.lb

	return {
		theme = d.theme,
		font_index = d.font_index,
		font_size = d.font_size,
		brightness_milli = d.brightness_milli or 1000,
		scale = d.scale,
		x = d.x,
		y = d.y,
		hidden = d.hidden == true,
		border_hidden = d.border_hidden == true,
	}
end

function VMWorld_SanitizeObject(key, src)
  local d = VMWorld_CopyDefault(key)
  src = type(src) == "table" and src or {}

  local hidden = d.hidden == true

  if type(src.hidden) == "boolean" then
    hidden = src.hidden == true
  end

	return {
		theme = VMWorld_ClampInt(src.theme, 0, 9, d.theme),
		font_index = VMWorld_ClampInt(src.font_index, 0, 13, d.font_index),
		font_size = VMWorld_ClampInt(src.font_size, 8, 120, d.font_size),
		brightness_milli = VMWorld_ClampInt(src.brightness_milli, 0, 3000, d.brightness_milli or 1000),
		scale = VMWorld_ClampInt(src.scale, 1, 3000, d.scale),
		x = VMWorld_ClampInt(src.x, -7000, 7000, d.x),
		y = VMWorld_ClampInt(src.y, -7000, 7000, d.y),
		hidden = hidden,
		border_hidden = key == "lb" and src.border_hidden == true or false,
	}
end

function VMWorld_SanitizeSettings(src)
  src = type(src) == "table" and src or {}

  local out = {}

  for _, key in ipairs(VMWORLD_OBJECT_ORDER) do
    out[key] = VMWorld_SanitizeObject(key, src[key])
  end

  return out
end

-- ───────────────────── Debug: FG settings I/O & dump (console-callable via hotkey) ─────────────────────
function VM_DebugCheckSettingsIO()
  local path = VM_SETTINGS_PATH or "vm_settings.json"
  local raw = readFile(path)
  if raw and #raw > 0 then
    print(("[VehicleMileage] READ_OK: %s (LEN=%d)"):format(path, #raw))
  elseif raw == "" then
    print(("[VehicleMileage] READ_OK_EMPTY: %s (LEN=0)"):format(path))
  else
    print(("[VehicleMileage] READ_FAIL: %s (missing/permissions?)"):format(path))
  end
  local ok = writeFile("vm_write_test.tmp", "ok")
  print(ok and "[VehicleMileage] WRITE_OK: vm_write_test.tmp" or "[VehicleMileage] WRITE_FAIL: vm_write_test.tmp")
end

function VM_DebugDumpFG()
  local dx = SETTINGS and SETTINGS.fg_dx_px or nil
  local dy = SETTINGS and SETTINGS.fg_dy_px or nil
  local sc = SETTINGS and SETTINGS.fg_scale or nil
  print(("[VehicleMileage] FG SETTINGS → dx=%s dy=%s scale=%s (600=1.00x)")
    :format(tostring(dx), tostring(dy), tostring(sc)))
end

-- ─────────────────────────────────────────────────────────────────────────────────────────────


local function loadSettings()
  local raw = readFile(VM_SETTINGS_PATH)
  if raw and #raw > 0 then
    local t = json_decode(raw)
    if type(t) == "table" then
    local pdx = tonumber(t.price_dx_px); if pdx ~= nil then SETTINGS.price_dx_px = pdx end
		-- NEW: widget selector and FuelGauge transforms
		local wm = tostring(t.widget_mode or ""):lower()
		if wm == "vmhud" or wm == "fuelgauge" or wm == "3dwidget" then
			SETTINGS.widget_mode = wm
		end
		local th = tonumber(t.fg_theme)
		if th ~= nil then
			SETTINGS.fg_theme = VM_ClampThemeId(th)
		end
		if type(t.world3d) == "table" then
			SETTINGS.world3d = VMWorld_SanitizeSettings(t.world3d)
		end
		local fgdx = tonumber(t.fg_dx_px); if fgdx ~= nil then SETTINGS.fg_dx_px = math.floor(fgdx) end
		local fgdy = tonumber(t.fg_dy_px); if fgdy ~= nil then SETTINGS.fg_dy_px = math.floor(fgdy) end
		local fgs  = tonumber(t.fg_scale); if fgs  ~= nil then SETTINGS.fg_scale = fgs end
		
		if SETTINGS.fg_dx_px ~= nil or SETTINGS.fg_dy_px ~= nil or SETTINGS.fg_scale ~= nil then
			print(("[VehicleMileage] Loaded FG from JSON: dx=%s dy=%s scale=%s")
			:format(tostring(SETTINGS.fg_dx_px), tostring(SETTINGS.fg_dy_px), tostring(SETTINGS.fg_scale)))
		else
			print("[VehicleMileage] FG keys absent in JSON → using runtime defaults")
		end

		      -- Fuel Gauge (optional keys; adopt if present)
      if type(t.fg_enabled) == "boolean" then SETTINGS.fg_enabled = t.fg_enabled end
      if type(t.fg_temp_enabled) == "boolean" then SETTINGS.fg_temp_enabled = t.fg_temp_enabled end


      local gdx = tonumber(t.fg_dx_px)
      if gdx ~= nil then
        if gdx < -7000 then gdx = -7000 elseif gdx > 7000 then gdx = 7000 end
        SETTINGS.fg_dx_px = math.floor(gdx)
      end

      local gdy = tonumber(t.fg_dy_px)
      if gdy ~= nil then
        if gdy < -7000 then gdy = -7000 elseif gdy > 7000 then gdy = 7000 end
        SETTINGS.fg_dy_px = math.floor(gdy)
      end

      local gsc = tonumber(t.fg_scale)
      if gsc ~= nil then
        if gsc < 0 then gsc = 0 elseif gsc > 7000 then gsc = 7000 end
        SETTINGS.fg_scale = math.floor(gsc)
      end

		
      -- Leaderboard (only adopt if the file actually has them)
    if type(t.lb_enabled) == "boolean" then SETTINGS.lb_enabled = t.lb_enabled end

		local ldx = tonumber(t.lb_dx_px)
		if ldx ~= nil then
			if ldx < -7000 then ldx = -7000 end
			if ldx >  7000 then ldx =  7000 end
			SETTINGS.lb_dx_px = math.floor(ldx)
		end

		local ldy = tonumber(t.lb_dy_px)
		if ldy ~= nil then
			if ldy < -7000 then ldy = -7000 end
			if ldy >  7000 then ldy =  7000 end
			SETTINGS.lb_dy_px = math.floor(ldy)
		end


    local lsc = tonumber(t.lb_scale)
    if lsc ~= nil then
      if lsc < 0   then lsc = 0   end
      if lsc > 7000 then lsc = 7000 end
      SETTINGS.lb_scale = lsc
    end


  local pdy = tonumber(t.price_dy_px); if pdy ~= nil then SETTINGS.price_dy_px = pdy end
local hx  = tonumber(t.hud_x); if hx and hx >= 0 and hx <= 1 then SETTINGS.hud_x = hx end
local hy  = tonumber(t.hud_y); if hy and hy >= 0 and hy <= 1 then SETTINGS.hud_y = hy end
local v   = tonumber(t.price_epl or t.unit_price_per_liter or t.price)
if v and v >= 0 then SETTINGS.price_epl = v end
if type(t.price_dyn_enable) == "boolean" then SETTINGS.price_dyn_enable = t.price_dyn_enable end
if type(t.fuel_enabled)     == "boolean" then SETTINGS.fuel_enabled     = t.fuel_enabled     end
if type(t.maintenance_enabled) == "boolean" then
  SETTINGS.maintenance_enabled = t.maintenance_enabled
end
local maintenanceMinKm = tonumber(t.maintenance_min_km)
if maintenanceMinKm ~= nil then
  maintenanceMinKm = math.floor(maintenanceMinKm + 0.5)
  maintenanceMinKm = math.max(
    VM_MAINT_KM_SLIDER_MIN,
    math.min(VM_MAINT_KM_SLIDER_MAX, maintenanceMinKm)
  )
  SETTINGS.maintenance_min_km = maintenanceMinKm
end
local maintenanceMaxKm = tonumber(t.maintenance_max_km)
if maintenanceMaxKm ~= nil then
  maintenanceMaxKm = math.floor(maintenanceMaxKm + 0.5)
  maintenanceMaxKm = math.max(
    VM_MAINT_KM_SLIDER_MIN,
    math.min(VM_MAINT_KM_SLIDER_MAX, maintenanceMaxKm)
  )
  SETTINGS.maintenance_max_km = maintenanceMaxKm
end
if SETTINGS.maintenance_max_km < SETTINGS.maintenance_min_km then
  SETTINGS.maintenance_max_km = SETTINGS.maintenance_min_km
end
if type(t.gas_pins_show_in_world) == "boolean" then
  SETTINGS.gas_pins_show_in_world = t.gas_pins_show_in_world
end
if type(t.stolen_stall_at_zero) == "boolean" then SETTINGS.stolen_stall_at_zero = t.stolen_stall_at_zero end

local rpa = tonumber(t.repair_price_adjust_pct)
if rpa ~= nil then
  if rpa < -100 then rpa = -100 elseif rpa > 2000 then rpa = 2000 end
  SETTINGS.repair_price_adjust_pct = math.floor(rpa + 0.5)
end
if type(t.repair_automatic_enabled) == "boolean" then
  SETTINGS.repair_automatic_enabled = t.repair_automatic_enabled
end

      -- HUD Auto-Hide
      if type(t.auto_hide_enabled) == "boolean" then
        SETTINGS.auto_hide_enabled = t.auto_hide_enabled
      end

      local ahs = tonumber(t.auto_hide_seconds)
      if ahs ~= nil then
        local minS = VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0.0
        local maxS = VMCONST.MISC.AUTO_HIDE_MAX_SECONDS or 120.0
        if ahs < minS then ahs = minS elseif ahs > maxS then ahs = maxS end
        SETTINGS.auto_hide_seconds = ahs
      end

      local ahp = tonumber(t.auto_hide_fuel_pct)
      if ahp ~= nil then
        if ahp < 0 then ahp = 0 elseif ahp > 100 then ahp = 100 end
        SETTINGS.auto_hide_fuel_pct = ahp
      end

end
end
end -- end function loadSettings

local function saveSettings()
  local data = {
    price_epl            = tonumber(SETTINGS.price_epl) or DEFAULT_PRICE_EPL,
    price_dx_px          = SETTINGS.price_dx_px,
    price_dy_px          = SETTINGS.price_dy_px,
    hud_x                = (type(SETTINGS.hud_x) == "number") and SETTINGS.hud_x or nil,
    hud_y                = (type(SETTINGS.hud_y) == "number") and SETTINGS.hud_y or nil,
    price_dyn_enable       = SETTINGS.price_dyn_enable and true or false,
    fuel_enabled           = SETTINGS.fuel_enabled and true or false,
    maintenance_enabled    = SETTINGS.maintenance_enabled ~= false,
    maintenance_min_km     = tonumber(SETTINGS.maintenance_min_km)
      or VM_MAINT_MIN_KM_DEFAULT,
    maintenance_max_km     = tonumber(SETTINGS.maintenance_max_km)
      or VM_MAINT_MAX_KM_DEFAULT,
    gas_pins_show_in_world = SETTINGS.gas_pins_show_in_world ~= false,
    stolen_stall_at_zero   = SETTINGS.stolen_stall_at_zero and true or false,
    repair_automatic_enabled = SETTINGS.repair_automatic_enabled == true,
		widget_mode          = SETTINGS.widget_mode or "fuelgauge",
		fg_theme             = VM_ClampThemeId(SETTINGS.fg_theme),
		
  }

  -- Repair price modifier
  if SETTINGS.repair_price_adjust_pct ~= nil then
    data.repair_price_adjust_pct = SETTINGS.repair_price_adjust_pct
  end

  -- HUD Auto-Hide (write only if user touched them)
  if SETTINGS.auto_hide_enabled ~= nil then
    data.auto_hide_enabled = SETTINGS.auto_hide_enabled and true or false
  end
  if SETTINGS.auto_hide_seconds ~= nil then
    data.auto_hide_seconds = SETTINGS.auto_hide_seconds
  end
  if SETTINGS.auto_hide_fuel_pct ~= nil then
    data.auto_hide_fuel_pct = SETTINGS.auto_hide_fuel_pct
  end

  -- Only include Fuel Gauge keys if user touched them (nil-on-first-run)
  if SETTINGS.fg_enabled ~= nil then data.fg_enabled = SETTINGS.fg_enabled end
	if SETTINGS.fg_temp_enabled ~= nil then data.fg_temp_enabled = SETTINGS.fg_temp_enabled end
  if SETTINGS.fg_dx_px  ~= nil then data.fg_dx_px  = SETTINGS.fg_dx_px  end
  if SETTINGS.fg_dy_px  ~= nil then data.fg_dy_px  = SETTINGS.fg_dy_px  end
  if SETTINGS.fg_scale  ~= nil then data.fg_scale  = SETTINGS.fg_scale  end

  -- Only include LB keys if user has ever changed them (stay invisible on first run)
  if SETTINGS.lb_enabled ~= nil then data.lb_enabled = SETTINGS.lb_enabled end
  if SETTINGS.lb_dx_px  ~= nil then data.lb_dx_px  = SETTINGS.lb_dx_px  end
  if SETTINGS.lb_dy_px  ~= nil then data.lb_dy_px  = SETTINGS.lb_dy_px  end
  if SETTINGS.lb_scale  ~= nil then data.lb_scale  = SETTINGS.lb_scale  end
	
	-- 3D World global config.
	-- Written only after the user presses Save in the CET "3D World" tab.
	if type(SETTINGS.world3d) == "table" then
		data.world3d = VMWorld_SanitizeSettings(SETTINGS.world3d)
	end

  local ok = writeFile(VM_SETTINGS_PATH, json_encode(data, 2))
  if not ok then print("[VehicleOdometer] ERROR writing " .. VM_SETTINGS_PATH) end
  return ok
end

-- Apply the saved world-marker visibility without changing the YAML file.
-- These are global functions to avoid adding more top-level locals to init.lua.
function VM_ApplyGasPinsShowInWorld(refreshPins)
  if MARKERS and MARKERS.setShowInWorld then
    local ok, applied = pcall(function()
      return MARKERS.setShowInWorld(
        SETTINGS.gas_pins_show_in_world ~= false,
        refreshPins ~= false
      )
    end)

    if not ok or applied == false then
      print(
        "[VehicleMileage] Could not apply gas-station world-marker setting: "
        .. tostring(applied)
      )
      return false
    end

    return true
  end

  return false
end

function VM_SetGasPinsShowInWorld(state)
  SETTINGS.gas_pins_show_in_world = state and true or false
  saveSettings()
  VM_ApplyGasPinsShowInWorld(true)
end

function VM_SetMaintenanceEnabled(state)
  SETTINGS.maintenance_enabled = state and true or false
  saveSettings()

  if VM_MAINTENANCE and VM_MAINTENANCE.setEnabled then
    VM_MAINTENANCE.setEnabled(SETTINGS.maintenance_enabled)
  end
end

function VM_ApplyMaintenanceIntervalSettings()
  local minKm = math.max(
    VM_MAINT_KM_SLIDER_MIN,
    math.min(
      VM_MAINT_KM_SLIDER_MAX,
      math.floor(
        tonumber(SETTINGS.maintenance_min_km) or VM_MAINT_MIN_KM_DEFAULT
      )
    )
  )
  local maxKm = math.max(
    minKm,
    math.min(
      VM_MAINT_KM_SLIDER_MAX,
      math.floor(
        tonumber(SETTINGS.maintenance_max_km) or VM_MAINT_MAX_KM_DEFAULT
      )
    )
  )

  SETTINGS.maintenance_min_km = minKm
  SETTINGS.maintenance_max_km = maxKm

  if VM_MAINTENANCE and VM_MAINTENANCE.setIntervalRange then
    VM_MAINTENANCE.setIntervalRange(minKm * 1000, maxKm * 1000)
  end
end

local function _gasLocPath()
if GAS_OPTS_REF and GAS_OPTS_REF.points_path then return GAS_OPTS_REF.points_path end -- end function _gasLocPath
return "vm_gas_locations.json"
end

-- Append current (vehicle or player) position to vm_gas_locations.json and reload GAS
local function appendGasLocationHere(radius)
  local player = Game.GetPlayer()
if not player then print("[VehicleOdometer] No player") return false end -- end function appendGasLocationHere

local pos
local veh = player:GetMountedVehicle()
if veh and veh.GetWorldPosition then
  pos = veh:GetWorldPosition()
else
  pos = player.GetWorldPosition and player:GetWorldPosition() or nil
end
if not pos then print("[VehicleOdometer] Cannot get world position") return false end

if type(radius) == "string" then radius = radius:gsub(",", ".") end
local r = tonumber(radius) or 5.0
if r <= 0 then r = 5.0 end

local entry = string.format('{ "x": %.6f, "y": %.6f, "z": %.6f, "radius": %.3f }', pos.x, pos.y, pos.z, r)
local path  = _gasLocPath()

-- Load (or seed) file text, keep valid JSON array structure
local txt = readFile(path) or "[]"
txt = txt:gsub("%s+$", "")
if not txt:match("^%s*%[") then txt = "[]" end

local replaced
local out, replaced = txt:gsub("(%s*})%s*%]%s*$", "%1,\n  " .. entry .. "\n]")
if replaced == 0 then
  -- fallback for unusual formatting
  out = txt:gsub("%]%s*$", ",\n  " .. entry .. "\n]")
end

local ok = writeFile(path, out)
if not ok then
  print("[VehicleOdometer] ERROR writing " .. tostring(path))
  return false
end

-- Hot-reload GAS points so it works immediately
if GAS and GAS.setup and GAS_OPTS_REF then pcall(GAS.setup, GAS_OPTS_REF) end

-- Nice feedback
queueToast(("Added gas at (%.1f, %.1f, %.1f) r=%.1f"):format(pos.x, pos.y, pos.z, r))
print(("[VehicleOdometer] Added gas point -> %s"):format(entry))
return true
end

-- 1) Old-style writer (must be ABOVE the remover)
local function encodeGasListOldStyle(arr)
  if type(arr) ~= "table" or #arr == 0 then return "[]\n" end
  local buf = { "[" }
  for i = 1, #arr do
    local p = arr[i] or {}
    local line = string.format(
      '  { "x": %.6f, "y": %.6f, "z": %.6f, "radius": %.3f }%s',
      tonumber(p.x) or 0, tonumber(p.y) or 0, tonumber(p.z) or 0, tonumber(p.radius) or 5.0,
      (i < #arr) and "," or ""
    )
    buf[#buf+1] = line
  end
  buf[#buf+1] = "]"
  return table.concat(buf, "\n")
end

-- 2) Remove nearest gas point using ONLY a fixed XY search radius
local function removeGasLocationNearby(maxDist)
  local limit = tonumber(maxDist) or 5.0

  local player = Game.GetPlayer()
  if not player then print("[VehicleOdometer] No player") return false end

  local pos
  local veh = player:GetMountedVehicle()
  if veh and veh.GetWorldPosition then
    pos = veh:GetWorldPosition()
  else
    pos = player.GetWorldPosition and player:GetWorldPosition() or nil
  end
  if not pos then print("[VehicleOdometer] Cannot get world position") return false end

  local path = _gasLocPath()
  local raw  = readFile(path) or "[]"
  local t    = json_decode(raw)
  if type(t) ~= "table" or #t == 0 then
    local msg = "Gas locations file is empty or malformed."
    print("[VehicleOdometer] " .. msg); queueToast(msg)
    return false
  end

  -- find nearest by XY
  local bestIdx, bestDist
  for i = 1, #t do
    local p = t[i]
    local x, y = tonumber(p and p.x), tonumber(p and p.y)
    if x and y then
      local dx, dy = x - pos.x, y - pos.y
      local d = math.sqrt(dx*dx + dy*dy)
      if not bestDist or d < bestDist then bestDist, bestIdx = d, i end
    end
  end

  if not bestIdx or bestDist > limit then
    local msg = ("No gas station within %.1f m (nearest %.1f m)"):format(limit, bestDist or math.huge)
    print("[VehicleOdometer] " .. msg); queueToast(msg)
    return false
  end

  local removed = table.remove(t, bestIdx)
  local ok = writeFile(path, encodeGasListOldStyle(t))
  if not ok then print("[VehicleOdometer] ERROR writing " .. tostring(path)); return false end

  -- Hot-reload so changes apply immediately
  pcall(function() if MARKERS and MARKERS.refresh then MARKERS.refresh(true) end end)
  if GAS and GAS.setup and GAS_OPTS_REF then pcall(GAS.setup, GAS_OPTS_REF) end

  local msg = string.format(
    "Removed gas at (%.1f, %.1f, %.1f) [idx %d]",
    tonumber(removed.x) or 0, tonumber(removed.y) or 0, tonumber(removed.z) or 0, bestIdx
  )
  print("[VehicleOdometer] " .. msg)
  queueToast(msg)
  return true
end

-- Repair station location path
local function _repairLocPath()
  if REPAIR_OPTS_REF and REPAIR_OPTS_REF.points_path then
    return REPAIR_OPTS_REF.points_path
  end
  return REPAIR_POINTS_PATH or "vm_repair_stations.json"
end

local function getPlayerRotationForRepairZone()
  local player = Game.GetPlayer()
  if not player then
    return 0.0, 0.0, 0.0
  end

  local roll, pitch, yaw = 0.0, 0.0, 0.0

  pcall(function()
    local q = player:GetWorldOrientation()
    if q then
      local e = q:ToEulerAngles()
      if e then
        roll  = tonumber(e.roll)  or 0.0
        pitch = tonumber(e.pitch) or 0.0
        yaw   = tonumber(e.yaw)   or 0.0
      end
    end
  end)

  print(("[VehicleMileage][Repair] Stored repair-zone player rotation: roll=%.2f pitch=%.2f yaw=%.2f")
    :format(roll, pitch, yaw))

  return roll, pitch, yaw
end

-- Append current vehicle/player position to vm_repair_stations.json
local function appendRepairLocationHere(radius, price, fxEffects)
  local player = Game.GetPlayer()
  if not player then print("[VehicleOdometer] No player") return false end

  local pos
  local veh = player:GetMountedVehicle()
  if veh and veh.GetWorldPosition then
    pos = veh:GetWorldPosition()
  else
    pos = player.GetWorldPosition and player:GetWorldPosition() or nil
  end

  if not pos then
    print("[VehicleOdometer] Cannot get world position")
    return false
  end

	if type(radius) == "string" then radius = radius:gsub(",", ".") end
	local r = tonumber(radius) or 5.0
	if r <= 0 then r = 5.0 end

	if type(price) == "string" then price = price:gsub(",", ".") end
	local repairPrice = math.floor((tonumber(price) or 500) + 0.5)
	if repairPrice < 0 then repairPrice = 0 end

	local rr, rp, ry = getPlayerRotationForRepairZone()

	local fx = {}
	for i = 1, 10 do
		local v = ""
		if type(fxEffects) == "table" then
			v = tostring(fxEffects[i] or "")
		end
		v = v:gsub("^%s+", ""):gsub("%s+$", "")
		fx[i] = v
	end

	local parts = {
		string.format('"x": %.6f', pos.x),
		string.format('"y": %.6f', pos.y),
		string.format('"z": %.6f', pos.z),
		string.format('"radius": %.3f', r),
		string.format('"price": %d', repairPrice),
	}

	for i = 1, 10 do
		parts[#parts + 1] = string.format(
			'"fxeffect%d": "%s"',
			i,
			json_escape(fx[i])
		)
	end

	parts[#parts + 1] = string.format('"rot_roll": %.6f', rr)
	parts[#parts + 1] = string.format('"rot_pitch": %.6f', rp)
	parts[#parts + 1] = string.format('"rot_yaw": %.6f', ry)

	local entry = "{ " .. table.concat(parts, ", ") .. " }"

  local path = _repairLocPath()

  local txt = readFile(path) or "[]"
  txt = txt:gsub("%s+$", "")
  if not txt:match("^%s*%[") then txt = "[]" end

  local out, replaced = txt:gsub("(%s*})%s*%]%s*$", "%1,\n  " .. entry .. "\n]")
  if replaced == 0 then
    out = txt:gsub("%]%s*$", ",\n  " .. entry .. "\n]")
  end

  -- Special case: empty []
  if txt:match("^%s*%[%s*%]%s*$") then
    out = "[\n  " .. entry .. "\n]"
  end

  local ok = writeFile(path, out)
  if not ok then
    print("[VehicleOdometer] ERROR writing " .. tostring(path))
    return false
  end

  if REPAIR and REPAIR.setup and REPAIR_OPTS_REF then
    pcall(REPAIR.setup, REPAIR_OPTS_REF)
  end

	queueToast(("Added repair zone at (%.1f, %.1f, %.1f) r=%.1f price=€$%d"):format(pos.x, pos.y, pos.z, r, repairPrice))
  print(("[VehicleOdometer] Added repair point -> %s"):format(entry))
  return true
end

local function encodeRepairListOldStyle(arr)
  if type(arr) ~= "table" or #arr == 0 then return "[]\n" end

  local buf = { "[" }

  for i = 1, #arr do
    local p = arr[i] or {}

    local x = tonumber(p.x) or 0
    local y = tonumber(p.y) or 0
    local z = tonumber(p.z) or 0
    local r = tonumber(p.radius) or 5.0
    local price = math.floor((tonumber(p.price) or 500) + 0.5)
    if price < 0 then price = 0 end

    local parts = {
      string.format('"x": %.6f', x),
      string.format('"y": %.6f', y),
      string.format('"z": %.6f', z),
      string.format('"radius": %.3f', r),
      string.format('"price": %d', price),
    }

    for n = 1, 10 do
      local key = "fxeffect" .. tostring(n)
      local val = tostring(p[key] or "")
      parts[#parts + 1] = string.format(
        '"%s": "%s"',
        key,
        json_escape(val)
      )
    end

    local rr = tonumber(p.rot_roll)
    local rp = tonumber(p.rot_pitch)
    local ry = tonumber(p.rot_yaw)

    if rr ~= nil and rp ~= nil and ry ~= nil then
      parts[#parts + 1] = string.format('"rot_roll": %.6f', rr)
      parts[#parts + 1] = string.format('"rot_pitch": %.6f', rp)
      parts[#parts + 1] = string.format('"rot_yaw": %.6f', ry)
    end

    local line = "  { " .. table.concat(parts, ", ") .. " }"
    if i < #arr then line = line .. "," end
    buf[#buf + 1] = line
  end

  buf[#buf + 1] = "]"
  return table.concat(buf, "\n")
end

local function removeRepairLocationNearby(maxDist)
  local limit = tonumber(maxDist) or 5.0

  local player = Game.GetPlayer()
  if not player then print("[VehicleOdometer] No player") return false end

  local pos
  local veh = player:GetMountedVehicle()
  if veh and veh.GetWorldPosition then
    pos = veh:GetWorldPosition()
  else
    pos = player.GetWorldPosition and player:GetWorldPosition() or nil
  end

  if not pos then
    print("[VehicleOdometer] Cannot get world position")
    return false
  end

  local path = _repairLocPath()
  local raw  = readFile(path) or "[]"
  local t    = json_decode(raw)

  if type(t) ~= "table" or #t == 0 then
    local msg = "Repair stations file is empty or malformed."
    print("[VehicleOdometer] " .. msg)
    queueToast(msg)
    return false
  end

  local bestIdx, bestDist

  for i = 1, #t do
    local p = t[i]
    local x, y = tonumber(p and p.x), tonumber(p and p.y)
    if x and y then
      local dx, dy = x - pos.x, y - pos.y
      local d = math.sqrt(dx * dx + dy * dy)
      if not bestDist or d < bestDist then
        bestDist, bestIdx = d, i
      end
    end
  end

  if not bestIdx or bestDist > limit then
    local msg = ("No repair station within %.1f m (nearest %.1f m)"):format(limit, bestDist or math.huge)
    print("[VehicleOdometer] " .. msg)
    queueToast(msg)
    return false
  end

  local removed = table.remove(t, bestIdx)
  local ok = writeFile(path, encodeRepairListOldStyle(t))
  if not ok then
    print("[VehicleOdometer] ERROR writing " .. tostring(path))
    return false
  end

  if REPAIR and REPAIR.setup and REPAIR_OPTS_REF then
    pcall(REPAIR.setup, REPAIR_OPTS_REF)
  end

  local msg = string.format(
    "Removed repair zone at (%.1f, %.1f, %.1f) [idx %d]",
    tonumber(removed.x) or 0,
    tonumber(removed.y) or 0,
    tonumber(removed.z) or 0,
    bestIdx
  )

  print("[VehicleOdometer] " .. msg)
  queueToast(msg)
  return true
end


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Spec maps (load/save + sanitization)                                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local CAR_SPECS  = {}
local BIKE_SPECS = {}

local function cleanKey(k)
if type(k) ~= "string" then return nil end -- end function cleanKey
local inner = k:match("%-%-%[%[%s*([^%]]-)%s*%]%]")  -- dev annotations
if inner and #inner > 0 then k = inner end
local veh = k:match("(Vehicle%.[%w_%.%-]+)")         -- canonical form
if veh then k = veh end
k = k:gsub("^%s+", ""):gsub("%s+$", "")              -- trim
return k
end

local function canonicalLabel(s)
  local k = cleanKey(tostring(s or ""))
  return (k and #k > 0) and k or tostring(s or "")
end -- end function canonicalLabel


-- ========== OWNERSHIP via base-game unlocked list (works for DAV AVs) ==========
local function __canonVehName(s)
  s = tostring(s or "")
  local inner = s:match("%-%-%[%[%s*([^%]]-)%s*%]%]") or s
  local veh  = inner:match("(Vehicle%.[%w_%.%-]+)") or inner
  return (veh:gsub("^%s+",""):gsub("%s+$",""))
end

local function isOwnedViaUnlockedList(label)
  local vs = Game.GetVehicleSystem()
  if not vs then return false end
  local ok, list = pcall(function() return vs:GetPlayerUnlockedVehicles() end)
  if not ok or not list then return false end

  local want = __canonVehName(label)
  if #want == 0 then return false end

  for i=1,#list do
    local rec = list[i] and list[i].recordID
    local s = nil
    if rec then
      local okv, v = pcall(function() return rec.value end); if okv and v then s = v end
      if not s then
        local okd, d = pcall(function() return TweakDBID.ToStringDEBUG(rec) end); if okd and d then s = d end
      end
    end
    if s then
      local got = __canonVehName(s):gsub("_dummy$", "")
      if got == want then return true end
    end
  end
  return false
end
-- ==============================================================================


local function ignoreAdd(label)    return IGNORE.add(canonicalLabel(label))    end
local function ignoreRemove(label) return IGNORE.remove(canonicalLabel(label)) end -- end function ignoreAdd
local function ignoreIs(label)
if not (IGNORE and IGNORE.isIgnored) then return false end -- end function ignoreIs
return IGNORE.isIgnored(canonicalLabel(label))
end

-- Merge any new labels from vm_ignore_seeds.json into vm_vehicle_ignore.json.
local function mergeSeedsIntoIgnore()
  local raw = readFile(IGNORE_SEED_PATH)
if not raw or #raw == 0 then return 0 end -- end function mergeSeedsIntoIgnore

local t = json_decode(raw)
if type(t) ~= "table" then
  print("[VehicleOdometer] Seed file malformed (not a table).")
  return 0
end

local seeds = {}
if #t > 0 then
  for _, v in ipairs(t) do
  if type(v) == "string" and #v > 0 then table.insert(seeds, v) end
end
else
  for k, v in pairs(t) do
  if type(k) == "string" and (v == true or v == 1) then table.insert(seeds, k) end
end
end

local added = 0
for _, label in ipairs(seeds) do
  local key = cleanKey(label) or tostring(label)
  if key and #key > 0 then
    if not ignoreIs(key) then
      local okCall, okAdd = pcall(ignoreAdd, key)
    if okCall and okAdd then added = added + 1 end
  end
end
end

if added > 0 then
  print(("[VehicleOdometer] Ignore seeds merged: +%d new entr%s")
  :format(added, added == 1 and "y" or "ies"))
end
return added
end

local LOG_QUESTISH_MATCHES = false
local function isQuestishLabel(label)
if type(label) ~= "string" or label == "" then return false end -- end function isQuestishLabel
local s = string.lower(label)
for _, p in ipairs(QUEST_LABEL_PATTERNS) do
  local looksPattern = p:find("^%p") or p:find("%%")
  if looksPattern then
    local m = s:find(p)
    if m then
      if LOG_QUESTISH_MATCHES then
        print(("[VM] quest-match (pattern '%s') on '%s'"):format(p, label))
      end
    return true
  end
else
  local m = s:find(p, 1, true)
  if m then
    if LOG_QUESTISH_MATCHES then
      print(("[VM] quest-match (substr '%s') on '%s'"):format(p, label))
    end
  return true
end
end
end
return false
end

local _AUTO_IGNORE_SEEN = {}
local function autoIgnoreQuestMaybe(label)
  local key = canonicalLabel(label)
if not key or _AUTO_IGNORE_SEEN[key] then return false end -- end function autoIgnoreQuestMaybe
_AUTO_IGNORE_SEEN[key] = true
if isQuestishLabel(key) then
  if not ignoreIs(key) then
    local ok, msg = ignoreAdd(key)
    if ok then
      print(("[VehicleOdometer] Auto-ignored quest-like vehicle: %s"):format(key))
      return true
    else
      print(("[VehicleOdometer] Auto-ignore add failed for '%s': %s"):format(key, tostring(msg)))
    end
end
end
return false
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3D widget per-vehicle config helpers                                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Important:
-- Do NOT make these local. init.lua is already close to CET's local-variable limit.

VM3D_FIELD_ORDER = {
  "side",
  "out_cm",
  "y_cm",
  "z_cm",
  "roll_deg",
  "pitch_deg",
  "yaw_deg",
  "scale_milli",
}

VM3D_FIELDS = {
  fuel = {
    side        = { fact = "vm_3d_fuel_side",        min = 0,    max = 3,    default = 0 },
    out_cm      = { fact = "vm_3d_fuel_out_cm",      min = -300, max = 300,  default = 0 },
    y_cm        = { fact = "vm_3d_fuel_y_cm",        min = -300, max = 300,  default = 0 },
    z_cm        = { fact = "vm_3d_fuel_z_cm",        min = -200, max = 300,  default = 0 },
    roll_deg    = { fact = "vm_3d_fuel_roll_deg",    min = -180, max = 180,  default = 0 },
    pitch_deg   = { fact = "vm_3d_fuel_pitch_deg",   min = -180, max = 180,  default = 0 },
    yaw_deg     = { fact = "vm_3d_fuel_yaw_deg",     min = -180, max = 180,  default = 0 },
    scale_milli = { fact = "vm_3d_fuel_scale_milli", min = 10,  max = 2000, default = 600 },
  },

  odo = {
    side        = { fact = "vm_3d_odo_side",        min = 0,    max = 3,    default = 0 },
    out_cm      = { fact = "vm_3d_odo_out_cm",      min = -300, max = 300,  default = 0 },
    y_cm        = { fact = "vm_3d_odo_y_cm",        min = -300, max = 300,  default = 0 },
    z_cm        = { fact = "vm_3d_odo_z_cm",        min = -200, max = 300,  default = 0 },
    roll_deg    = { fact = "vm_3d_odo_roll_deg",    min = -180, max = 180,  default = 0 },
    pitch_deg   = { fact = "vm_3d_odo_pitch_deg",   min = -180, max = 180,  default = 0 },
    yaw_deg     = { fact = "vm_3d_odo_yaw_deg",     min = -180, max = 180,  default = 0 },
    scale_milli = { fact = "vm_3d_odo_scale_milli", min = 10,  max = 2000, default = 600 },
  },
	
	  fuel_alt = {
    side        = { fact = "vm_3d_fuel_alt_side",        min = 0,    max = 3,    default = 1 },
    out_cm      = { fact = "vm_3d_fuel_alt_out_cm",      min = -300, max = 300,  default = 0 },
    y_cm        = { fact = "vm_3d_fuel_alt_y_cm",        min = -300, max = 300,  default = 0 },
    z_cm        = { fact = "vm_3d_fuel_alt_z_cm",        min = -200, max = 300,  default = 0 },
    roll_deg    = { fact = "vm_3d_fuel_alt_roll_deg",    min = -180, max = 180,  default = 0 },
    pitch_deg   = { fact = "vm_3d_fuel_alt_pitch_deg",   min = -180, max = 180,  default = 0 },
    yaw_deg     = { fact = "vm_3d_fuel_alt_yaw_deg",     min = -180, max = 180,  default = 0 },
    scale_milli = { fact = "vm_3d_fuel_alt_scale_milli", min = 10,  max = 2000, default = 600 },
  },

  odo_alt = {
    side        = { fact = "vm_3d_odo_alt_side",        min = 0,    max = 3,    default = 1 },
    out_cm      = { fact = "vm_3d_odo_alt_out_cm",      min = -300, max = 300,  default = 0 },
    y_cm        = { fact = "vm_3d_odo_alt_y_cm",        min = -300, max = 300,  default = 0 },
    z_cm        = { fact = "vm_3d_odo_alt_z_cm",        min = -200, max = 300,  default = 0 },
    roll_deg    = { fact = "vm_3d_odo_alt_roll_deg",    min = -180, max = 180,  default = 0 },
    pitch_deg   = { fact = "vm_3d_odo_alt_pitch_deg",   min = -180, max = 180,  default = 0 },
    yaw_deg     = { fact = "vm_3d_odo_alt_yaw_deg",     min = -180, max = 180,  default = 0 },
    scale_milli = { fact = "vm_3d_odo_alt_scale_milli", min = 10,  max = 2000, default = 600 },
  },
}

function VM3D_ToInt(v)
  v = tonumber(v) or 0

  if v >= 0 then
    return math.floor(v + 0.5)
  end

  return math.ceil(v - 0.5)
end

function VM3D_Clamp(v, minV, maxV, def)
  v = tonumber(v)

  if v == nil then
    v = def
  end

  v = VM3D_ToInt(v)

  if v < minV then return minV end
  if v > maxV then return maxV end

  return v
end

function VM3D_Defaults()
  local out = {
    fuel_style = 0,
		fuel_alt_style = 0,
    theme = 0,
    font_index = 0,
    font_scale_milli = 1000,
		emissive_ev_deci = 60,

    hide_fuel = false,
    hide_odo = false,
    hide_odo_frame = false,

    hide_fuel_alt = false,
    hide_odo_alt = false,
    hide_odo_alt_frame = false,

    fuel = {},
    odo = {},
    fuel_alt = {},
    odo_alt = {},
  }

  for groupKey, fields in pairs(VM3D_FIELDS) do
    for _, key in ipairs(VM3D_FIELD_ORDER) do
      out[groupKey][key] = fields[key].default
    end
  end

  return out
end

function VM3D_SanitizeConfig(src)
  if type(src) ~= "table" then
    return nil
  end

  local out = VM3D_Defaults()

	out.fuel_style = VM3D_Clamp(src.fuel_style, 0, 5, 0)
	out.fuel_alt_style = VM3D_Clamp(src.fuel_alt_style, 0, 5, 0)
	out.theme = VM3D_Clamp(src.theme, 0, 9, 0)
	out.font_index = VM3D_Clamp(src.font_index, 0, 13, 0)
	out.font_scale_milli = VM3D_Clamp(src.font_scale_milli, 500, 2000, 1000)
	out.emissive_ev_deci = VM3D_Clamp(src.emissive_ev_deci, 0, 120, 60)

  out.hide_fuel = src.hide_fuel == true
  out.hide_odo = src.hide_odo == true
  out.hide_odo_frame = src.hide_odo_frame == true
	
	out.hide_fuel_alt = src.hide_fuel_alt == true
  out.hide_odo_alt = src.hide_odo_alt == true
  out.hide_odo_alt_frame = src.hide_odo_alt_frame == true

  for groupKey, fields in pairs(VM3D_FIELDS) do
    local srcGroup = type(src[groupKey]) == "table" and src[groupKey] or {}

    for _, key in ipairs(VM3D_FIELD_ORDER) do
      local f = fields[key]
      out[groupKey][key] = VM3D_Clamp(srcGroup[key], f.min, f.max, f.default)
    end
  end

  return out
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Fact-backed save keys                                                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- These keys are stored in vm_config_cars.json / vm_config_bikes.json.
-- The actual values are stored in quest facts per savegame.

local VMFS_FACT_FIELDS = {
  "initialized",
  "meters",
  "fuel_permille",
  "oil_deci_c",
  "stalled",
  "limit_on",
  "maintenance_due_m",
}

function VMFS_Hash32(s)
  s = tostring(s or "")
  local h = 5381

  for i = 1, #s do
    h = ((h * 33) + string.byte(s, i)) % 4294967296
  end

  return math.floor(h)
end

function VMFS_MakeFactKeys(label)
  local h = string.format("%08x", VMFS_Hash32(label))

  return {
    initialized   = "vmv_" .. h .. "_i",
    meters        = "vmv_" .. h .. "_m",
    fuel_permille = "vmv_" .. h .. "_f",
    oil_deci_c    = "vmv_" .. h .. "_o",
    stalled       = "vmv_" .. h .. "_s",
    limit_on      = "vmv_" .. h .. "_l",
    maintenance_due_m = "vmv_" .. h .. "_d",
  }
end

function VMFS_SanitizeFactKeys(src)
  if type(src) ~= "table" then
    return nil
  end

  local out = {}
  local any = false

  for _, key in ipairs(VMFS_FACT_FIELDS) do
    local v = src[key]

    if type(v) == "string" and v ~= "" then
      out[key] = v
      any = true
    end
  end

  return any and out or nil
end

function VMFS_EnsureFactKeys(label, rec)
  if type(rec) ~= "table" then
    return false
  end

  local changed = false
  local generated = VMFS_MakeFactKeys(label)

  if type(rec.vm_facts) ~= "table" then
    rec.vm_facts = {}
    changed = true
  end

  for _, key in ipairs(VMFS_FACT_FIELDS) do
    if type(rec.vm_facts[key]) ~= "string" or rec.vm_facts[key] == "" then
      rec.vm_facts[key] = generated[key]
      changed = true
    end
  end

  return changed
end

local function pruneSpecMap(m)
  local out, changed = {}, false
  for k, v in pairs(m or {}) do
    local kk = cleanKey(k)
    if kk and type(v) == "table" and tonumber(v.l100km) and tonumber(v.tank_l) then
      if not out[kk] then
        out[kk] = {
          l100km = tonumber(v.l100km),
          tank_l = tonumber(v.tank_l),
        }
      end
      -- keep oil optimal range if present (clamped sane)
      local lo = tonumber(v.oil_opt_min)
      local hi = tonumber(v.oil_opt_max)
      if lo then out[kk].oil_opt_min = math.max(0, math.min(300, lo)) end
			if hi then out[kk].oil_opt_max = math.max(0, math.min(300, hi)) end

			-- Preserve optional fact-backed save keys.
			local vmfacts = VMFS_SanitizeFactKeys(v.vm_facts)
			if vmfacts then
				out[kk].vm_facts = vmfacts
			end

			if VMFS_EnsureFactKeys(kk, out[kk]) then
				changed = true
			end

			-- Preserve optional per-vehicle 3D widget config.
			local vm3d = VM3D_SanitizeConfig(v.vm3d)
			if vm3d then
				out[kk].vm3d = vm3d
			end

			if kk ~= k then changed = true end
    else
      changed = true
    end
  end
  return out, changed
end


local function loadSpecMap(path)
  local raw = readFile(path)
if not raw or #raw == 0 then return {} end -- end function loadSpecMap
local t = json_decode(raw)
if type(t) ~= "table" then return {} end
local pruned, changed = pruneSpecMap(t)
if changed then
  if VM_CONFIG_BACKUP.write(path, json_encode(pruned, 2)) then
    print("[VehicleOdometer] Cleaned invalid entries from " .. path)
  else
    print("[VehicleOdometer] ERROR: could not safely clean " .. tostring(path))
  end
end
return pruned
end

local function saveSpecMap(path, map)
  local pruned = select(1, pruneSpecMap(map))
  local ok = VM_CONFIG_BACKUP.write(path, json_encode(pruned, 2))
if not ok then print("[VehicleOdometer] ERROR writing " .. tostring(path)) end -- end function saveSpecMap
return ok
end

local function _backfillOil(map, isBike, path)
  local changed = false
  for k, v in pairs(map or {}) do
    if type(v) == "table" then
      if v.oil_opt_min == nil then
        v.oil_opt_min = isBike and VMCONST.OIL.DEF_BIKE_MIN or VMCONST.OIL.DEF_CAR_MIN
        changed = true
      end
      if v.oil_opt_max == nil then
        v.oil_opt_max = isBike and VMCONST.OIL.DEF_BIKE_MAX or VMCONST.OIL.DEF_CAR_MAX
        changed = true
      end
    end
  end
  if changed then saveSpecMap(path, map) end
end

local function reloadSpecFiles()
  CAR_SPECS  = loadSpecMap(CAR_SPECS_PATH)
  BIKE_SPECS = loadSpecMap(BIKE_SPECS_PATH)
  -- NEW: backfill missing oil ranges and persist
  _backfillOil(CAR_SPECS,  false, CAR_SPECS_PATH)
  _backfillOil(BIKE_SPECS, true,  BIKE_SPECS_PATH)
end

-- Forward-declare so ensureSpecForLabel can call it
local looksLikeAV  -- defined later (see "Treat DAV aircraft..." helper)

local function ensureSpecForLabel(label, isBike)
  local key = cleanKey(label)
if not key then return end -- end function ensureSpecForLabel
if isBike then
  if not BIKE_SPECS[key] then
		BIKE_SPECS[key] = {
			l100km = DEFAULTS_BIKE.l100km,
			tank_l = DEFAULTS_BIKE.tank_l,
			oil_opt_min = DEFAULTS_BIKE.oil_opt_min,
			oil_opt_max = DEFAULTS_BIKE.oil_opt_max,
			vm_facts = VMFS_MakeFactKeys(key),
		}
    if saveSpecMap(BIKE_SPECS_PATH, BIKE_SPECS) then
      print(("[VehicleOdometer] Added bike spec '%s' {l100km=%s, tank_l=%s}")
      :format(key, tostring(DEFAULTS_BIKE.l100km), tostring(DEFAULTS_BIKE.tank_l)))
    else
      BIKE_SPECS[key] = nil
    end
  end
else
  if not CAR_SPECS[key] then
    -- If it's an AV, use AV defaults; otherwise use car defaults
    local def = looksLikeAV(label) and DEFAULTS_AV or DEFAULTS_CAR
		CAR_SPECS[key] = {
			l100km = def.l100km,
			tank_l = def.tank_l,
			oil_opt_min = def.oil_opt_min,
			oil_opt_max = def.oil_opt_max,
			vm_facts = VMFS_MakeFactKeys(key),
		}
    if saveSpecMap(CAR_SPECS_PATH, CAR_SPECS) then
      print(("[VehicleOdometer] Added %s spec '%s' {l100km=%s, tank_l=%s}")
        :format(looksLikeAV(label) and "av" or "car", key, tostring(def.l100km), tostring(def.tank_l)))
    else
      CAR_SPECS[key] = nil
    end
  end
end
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Helpers (facts, identity, bikes, speed, limiter)                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function setFactInt(name, val)
local qs = Game.GetQuestsSystem(); if not qs then return false end -- end function setFactInt
local ok = pcall(function()
  local cn = (CName and CName.new and CName.new(name)) or (CName and CName(name)) or name
  qs:SetFact(cn, val)
end) -- end function (anonymous)
return ok
end

function VM_GetFactInt(name, def)
  local qs = Game.GetQuestsSystem()
  if not qs then
    return def or 0
  end

  local ok, value = pcall(function()
    return qs:GetFactStr(name)
  end)

  if ok then
    local n = tonumber(value)
    if n ~= nil then
      return n
    end
  end

  return def or 0
end

-- Cached fact writes for high-frequency 3D visibility facts.
-- Prevents SetFact spam when the value is already the same.
VM_FACT_CACHE = VM_FACT_CACHE or {}

function VM_SetFactIntCached(name, val)
  name = tostring(name or "")
  val = math.floor(tonumber(val) or 0)

  if name == "" then
    return false
  end

  if VM_FACT_CACHE[name] == val then
    return true
  end

  local ok = setFactInt(name, val)

  if ok then
    VM_FACT_CACHE[name] = val
  end

  return ok
end

function VM3D_SetHiddenFacts(fuelHidden, odoHidden, fuelAltHidden, odoAltHidden)
  VM_SetFactIntCached("vm_3d_fuel_hidden", fuelHidden and 1 or 0)
  VM_SetFactIntCached("vm_3d_odo_hidden", odoHidden and 1 or 0)
  VM_SetFactIntCached("vm_3d_fuel_alt_hidden", fuelAltHidden and 1 or 0)
  VM_SetFactIntCached("vm_3d_odo_alt_hidden", odoAltHidden and 1 or 0)
end

local function applyThemeRuntime(themeId)
  themeId = VM_ClampThemeId(themeId)

  SETTINGS.fg_theme = themeId

  -- 2D FuelGauge / Leaderboard theme only.
  -- 3D theme is per vehicle and is handled by VM3D_ApplyConfigToFacts().
  setFactInt("vm_fg_theme", themeId)

  print(("[VehicleMileage] HUD theme set to %d: %s")
    :format(themeId, tostring(VM_FG_THEME_VALUES[themeId + 1] or "Default")))
end

local function vehKeyAndLabel(veh)
local okRid, rid = pcall(function() return veh:GetRecordID() end) -- end function vehKeyAndLabel
if okRid and rid then
local okDbg, dbg = pcall(function() return TweakDBID.ToStringDEBUG(rid) end)
if okDbg and dbg and #dbg > 0 then
  local pretty = cleanKey(dbg) or dbg
  return pretty, pretty
end
local okTo, s = pcall(function() return tostring(rid) end) -- end function (anonymous)
if okTo and s and #s > 0 then return s, s end -- end function (anonymous)
end
local h = tostring(veh:GetEntityID().hash)
return h, h
end -- end function (anonymous)

local function looksLikeBike(recStr)
if not DETECT_BIKES then return false end -- end function looksLikeBike
recStr = string.lower(tostring(recStr or ""))
return (recStr:find("bike") or recStr:find("yaiba") or recStr:find("arch")) ~= nil
end

-- Treat DAV aircraft (and any "Vehicle.av_*") as AVs
function looksLikeAV(recStr)  -- assign the forward-declared local (no 'local' here)
  recStr = string.lower(tostring(recStr or ""))
  -- common patterns:
  --   Vehicle.av_rayfield_excalibur_dav
  --   Vehicle.av_*_dav_dummy  (unlocked list)
  return (recStr:find("vehicle%.av_") or recStr:find("%.av_") or recStr:find("_dav")) ~= nil
end


local function specsFor(label)
  local isBike = looksLikeBike(label)
  local key    = cleanKey(label) or label
if isBike then return (BIKE_SPECS[key]) or FALLBACK_BIKE end -- end function specsFor
return (CAR_SPECS[key]) or FALLBACK_CAR
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Top 10 ODO printer (prints once when refueling starts)
-- Uses the current runtime session state (SAVE.data.vehicles).
-- Labels are canonicalized (e.g., "Vehicle.v_standard2_thorton_colby_poor").
-- Prints: "1. <VehicleLabel> - 00000 km" style lines.

-- ─────────────────────────────────────────────────────────────────────────────
-- Vehicle display-name resolver 
-- Tries the exact Vehicle.* record, then a *_call fallback. Caches results.
local __vehNameCache = {}

local function vmHumanizeVehicleLabel(label)
  local s = cleanKey(label) or tostring(label or "")

  s = s:gsub("^Vehicle%.", "")
  s = s:gsub("_dummy$", "")
  s = s:gsub("_player$", "")
  s = s:gsub("_purchasable$", "")
  s = s:gsub("_call$", "")

  -- Remove vehicle class prefix, example:
  -- v_sport2_quadra_type66_nomad -> quadra_type66_nomad
  s = s:gsub("^v_[%w]+_", "")

  s = s:gsub("_", " ")
  s = s:gsub("%s+", " ")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")

  if s == "" then
    return tostring(label or "Current vehicle")
  end

  s = s:gsub("(%a)([%w']*)", function(a, b)
    return string.upper(a) .. string.lower(b)
  end)

  s = s:gsub("Type(%d+)", "Type-%1")

  return s
end

local function vmResolveVehicleDisplayName(label)
  if not label or label == "" then return "Unknown vehicle" end
  -- If it's not a Vehicle.* key, just show the label we have.
  if not string.find(label, "Vehicle.", 1, true) then
    return label
  end

  local cached = __vehNameCache[label]
  if cached then return cached end

  local function localizeFromRecord(rec)
    if not rec then return nil end
    local k = rec:DisplayName()
    local s = Game.GetLocalizedTextByKey(k)
    if not s or s == "" then s = Game.GetLocalizedText(k) end
    if s and s ~= "" then return s end
    return nil
  end

  -- 1) Try exact record
  local rec = TweakDBInterface.GetVehicleRecord(TweakDBID.new(label))
  local name = localizeFromRecord(rec)

  -- 2) Try common garage/call variants if not found
  if not name then
    local variants = {
      label:gsub("_purchasable$", "_call"),
      label:gsub("_player$", "_call"),
      label .. "_call",
    }

    for _, alt in ipairs(variants) do
      if not name and alt ~= label then
        rec = TweakDBInterface.GetVehicleRecord(TweakDBID.new(alt))
        name = localizeFromRecord(rec)
      end
    end
  end

  -- Final fallback:
  -- Do not show ugly Vehicle.* IDs in user-facing toasts.
  if not name then
    name = vmHumanizeVehicleLabel(label)
  end

  __vehNameCache[label] = name
  return name
end
-- ─────────────────────────────────────────────────────────────────────────────

local vmPushTop10HUD  -- forward declaration (assigned later, after _callUI)

local function vmPrintTop10Odo()
  -- Defensive: make sure SAVE and its table are available
  local vehicles = (SAVE and SAVE.data and SAVE.data.vehicles) or {}
  local arr = {}

  -- Collect entries (label + meters + fuel%)  -- only keep >=1 km
  for id, v in pairs(vehicles) do
    local meters = tonumber(v and v.meters) or 0
    local km     = math.floor((meters / 1000) + 0.5) -- round to nearest km
    local label  = canonicalLabel(id) or tostring(id)

    -- fuel is kept as-is (not used for filtering)
    local fuel = tonumber(v and v.fuel_pct)
    if fuel then
      if fuel < 0 then fuel = 0 end
      if fuel > 100 then fuel = 100 end
    else
      fuel = -1
    end

    -- NEW: ignore entries under 1 km
    if km >= 1 then
      table.insert(arr, { label = label, km = km, meters = meters, fuel = fuel })
    end
  end



  -- Sort by meters descending
  table.sort(arr, function(a, b) return (a.meters or 0) > (b.meters or 0) end)

  -- Header + lines
  -- print("[VehicleOdometer] Top 10 ODO (km)")
  if #arr == 0 then
    print("No odometer data yet.")
    return
  end

  --[[ local n = math.min(10, #arr)
  for i = 1, n do
    local e = arr[i]
    -- Zero-pad to 5 digits as in your example ("00000 km"). Longer values will expand naturally.
    local kmStr = string.format("%05d km", tonumber(e.km) or 0)
    local nice = vmResolveVehicleDisplayName(e.label)
		print(string.format("%d. %s - %s", i, nice, kmStr))
  end --]]
	-- Also push to HUD widget (ODO TOP 10)
  vmPushTop10HUD(arr)
end
-- ─────────────────────────────────────────────────────────────────────────────


-- === Refuel tank scaling (bigger tanks take longer) =========================
-- Baselines keep your current timing unchanged for a ~40 L car / 18 L bike.
local REFILL_BASE_TANKL_CAR  = FALLBACK_CAR.tank_l   -- 40
local REFILL_BASE_TANKL_BIKE = FALLBACK_BIKE.tank_l  -- 18

-- Optional safety clamp so extremes don't get silly
local REFILL_SCALE_MIN, REFILL_SCALE_MAX = 0.25, 3.5

local function tankScaleForLabel(label)
  local isBike = looksLikeBike(label)
  local spec   = specsFor(label)
  local tank   = tonumber(spec and spec.tank_l) or (isBike and REFILL_BASE_TANKL_BIKE or REFILL_BASE_TANKL_CAR)
  local base   = isBike and REFILL_BASE_TANKL_BIKE or REFILL_BASE_TANKL_CAR
  local s      = base / math.max(1.0, tank)  -- 80L tank → ~0.5× rate, 20L → ~2× rate

  if s < REFILL_SCALE_MIN then s = REFILL_SCALE_MIN
  elseif s > REFILL_SCALE_MAX then s = REFILL_SCALE_MAX end
  return s
end
-- ============================================================================


local function targetLimitKmh(isBike)
  local cap = EMPTY_SPEED_PERCENT * (isBike and VMCONST.LIMITER.MAX_KMH_BIKE or VMCONST.LIMITER.MAX_KMH_CAR)
if cap < 1.0 then cap = 1.0 end -- end function targetLimitKmh
return cap
end

local function getSpeedKmh(veh, dt, lastPos, curPos)
local ok, vel = pcall(function() return veh:GetVelocity() end) -- end function getSpeedKmh
if ok and vel then
  local mps = math.sqrt((vel.x or 0)^2 + (vel.y or 0)^2 + (vel.z or 0)^2)
  return mps * 3.6
end
if lastPos and curPos and dt and dt > 0 then
  local dx = curPos.x - lastPos.x
  local dy = curPos.y - lastPos.y
  local dz = curPos.z - lastPos.z
  local d2 = dx*dx + dy*dy + dz*dz
  if d2 <= MAXSTEP2 then
    local d = math.sqrt(d2)
  if d > VMCONST.TRACK.JITTER_METERS then return (d / dt) * 3.6 end
end
end
return 0.0
end -- end function (anonymous)

local function forceBrakeTick(veh, seconds)
pcall(function() veh:ForceBrakesFor(seconds or 0.12) end) -- end function forceBrakeTick
end -- end function (anonymous)

local function speedConsumptionFactor(kmh, isBike)
  kmh = math.max(0, math.min(VMCONST.SPEED.CLAMP_KMH, tonumber(kmh or 0) or 0))
  local base = isBike and VMCONST.SPEED.BASE_KMH_BIKE or VMCONST.SPEED.BASE_KMH_CAR
if base <= 0 then return 1.0 end -- end function speedConsumptionFactor
local r = kmh / base
if r <= 1.0 then
  return VMCONST.SPEED.MIN_MULT + (1.0 - VMCONST.SPEED.MIN_MULT) * r
else
  local x = r - 1.0
  local f = 1.0 + (VMCONST.SPEED.LINEAR_GAIN * x) + (VMCONST.SPEED.AERO_QUAD * x * x)
if f > VMCONST.SPEED.MAX_MULT then f = VMCONST.SPEED.MAX_MULT end
return f
end
end

-- Version-agnostic “in a menu?” check
local function isInMenu()
  local paused = false
  pcall(function()
    local srh = Game.GetSystemRequestsHandler()
  if srh and srh.IsGamePaused then paused = srh:IsGamePaused() end -- end function (anonymous)
end)
return paused
end -- end function isInMenu

local wasInMenu = isInMenu()



-- Vehicle overall condition in percent (0..100), nil if unknown
local function vehicleCondPct(veh)
  if not veh then return nil end
  local okE, ent = pcall(function() return veh:GetEntityID() end); if not okE or not ent then return nil end
  local sps, sts = Game.GetStatPoolsSystem(), Game.GetStatsSystem()
  if not sps or not sts then return nil end
  local okC, cur = pcall(function() return sps:GetStatPoolValue(ent, gamedataStatPoolType.Health, false) end)
  local okM, max = pcall(function() return sts:GetStatValue(ent, gamedataStatType.Health) end)
  if not okC or not okM or not max or max <= 0 then return nil end
  local pct = math.floor(((cur / max) * 100) + 0.5)
  if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
  return pct
end



-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Runtime state                                                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local lastPos   = nil
local lastVehId = nil
local cfgAcc    = 0.0
local lastHourSeen = -1

-- HUD delay tracking
local wasOwned = false
local hudAcc   = 0.0

-- HUD Auto-Hide timer
local autoHideTimer = 0.0
local autoHideLatched = false  -- true = already hidden by Auto-Hide; keep hidden until remount / low fuel / toggle off

-- CET overlay gate
local isOverlayVisible = false
registerForEvent('onOverlayClose', function() isOverlayVisible = false end)
registerForEvent('onOverlayOpen',  function() isOverlayVisible = true  end) -- end function (anonymous)

-- Live preview (debug window)
local LIVE = { kmh = 0.0, factor = 1.0, inst_l100 = 0.0, idle_lph = 0.0, mode = "stop" }

-- Widget-mode reassert on startup / player control (prevents “both HUDs”)
local _wm_reassert_left   = 0.0  -- seconds left to keep reasserting
local _wm_reassert_period = 0.25 -- how often to reassert
local _wm_reassert_acc    = 0.0

-- ── Mount state + per-vehicle frame cache ──────────────────────────────────
-- vm.isMounted: true between VehicleMount and VehicleUnmount events.
-- Allows onUpdate to exit immediately when the player is on foot,
-- eliminating GetPlayer()/GetMountedVehicle() raw-API cost every frame.
local vm = { isMounted = false }
local vmMountFallbackWarned = false

local lastIsBike       = nil   -- bool, invalidated on vehicle change
local lastSpec         = nil   -- table, invalidated on vehicle change
local lastVehData      = nil   -- table, invalidated on vehicle change
local isIgnoredCache   = nil   -- bool, invalidated on vehicle change
local lastAutoIgnoreId = nil   -- vehicle id we already ran the quest heuristic on
local lastSpeedPushed  = -1    -- int km/h: avoids redundant speed fact writes

-- Forward declaration: assigned in onInit once Mod is available.
-- Called from onVehicleUnmount to start the self-stopping oil cooldown interval.
local _startOilCooldown = nil


-- Price + refuel rate management
local currentPrice      = DEFAULT_PRICE_EPL
local GAS_OPTS_REF      = nil
local REPAIR_OPTS_REF   = nil
local priceVisibleLast  = false
local lastRefillPerSec  = -1
local rateCooldown       = 0.0
local refuelingPrev      = false


local function applyRefillRateLps(newRate, opts)
  newRate = math.max(0.0, tonumber(newRate) or 0.0)
if math.abs(newRate - lastRefillPerSec) < VMCONST.REFILL.CHANGE_EPS then return end -- end function applyRefillRateLps

local hasSetter = (type(GAS.setRefillPerSec) == "function")
if hasSetter then
  pcall(GAS.setRefillPerSec, newRate)
  lastRefillPerSec = newRate
  return
end

local inRefuel = opts and opts.in_refuel
if GAS_OPTS_REF then
  if inRefuel then
    local se, sse = GAS_OPTS_REF.sound_event, GAS_OPTS_REF.sound_stop_event
    GAS_OPTS_REF.sound_event, GAS_OPTS_REF.sound_stop_event = nil, nil
    GAS_OPTS_REF.refill_per_sec = newRate
    pcall(GAS.setup, GAS_OPTS_REF)
    GAS_OPTS_REF.sound_event, GAS_OPTS_REF.sound_stop_event = se, sse
  else
    GAS_OPTS_REF.refill_per_sec = newRate
    pcall(GAS.setup, GAS_OPTS_REF)
  end
lastRefillPerSec = newRate
end
end

-- HUD price fact throttling
local priceReassertTimer = 0.0
local FACT_PUSH_INTERVAL_BASE   = 0.5
local FACT_PUSH_INTERVAL_REFUEL = 0.05
local factPushInterval          = FACT_PUSH_INTERVAL_BASE
local factAcc                   = 0.0
local lastHUDVisible            = -1
local lastMetersPushed          = -1
local lastFuelPermillePushed    = -1
local lastVehCondPctPushed 			= -1
local lastOilTempPushed = -9999
-- NEW: cache the last pushed temp-meter visibility (−1 unknown, 0 hidden, 1 shown)
local lastTempVisible           = -1

-- Price fact cache
local lastPriceCentsPushed = -1
local function pushPriceFact(force)
  local p = tonumber(currentPrice) or tonumber(SETTINGS.price_epl) or DEFAULT_PRICE_EPL or 0
  local cents = math.max(0, math.floor(p * 100 + 0.5))
  if force or cents ~= lastPriceCentsPushed then
    setFactInt(FACT_HUD_PRICE_CENTS, cents)
    lastPriceCentsPushed = cents
  end
end -- end function pushPriceFact

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ TEMP: legacy vm_session meters import                                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Temporary migration helper:
-- Reads the newest old vm_session/*.lua file and imports ONLY meters.
-- Safe behaviour: it will not lower existing fact meters. It keeps the higher value.

local VM_IMPORT_MANUAL_METERS_STR = VM_IMPORT_MANUAL_METERS_STR or ""

local function VM_LegacyExtractLabel(rawKey)
  local s = tostring(rawKey or "")

  -- Old vm_session keys usually look like:
  -- ToTweakDBID{ ... --[[ Vehicle.some_vehicle_label --]] }
  local fromComment = s:match("%-%-%[%[%s*(Vehicle%.[^%]]-)%s*%]%]")

  return cleanKey(fromComment or s)
end

local function VM_LegacySessionCandidates()
  local dir = "vm_session"
  local out = {}
  local seen = {}

  local function addCandidate(line)
    local name = tostring(line or ""):match("([^/\\]+)$")
    local key = tonumber(name and name:match("^(%d+)%.lua$") or nil)

    if key and not seen[key] then
      seen[key] = true
      out[#out + 1] = {
        key = key,
        path = dir .. "/" .. tostring(key) .. ".lua",
      }
    end
  end

  -- Windows CET path. This should work for most users.
  if io and io.popen then
    local commands = {
      'dir /b "vm_session\\*.lua" 2>nul',
      'ls "vm_session"/*.lua 2>/dev/null',
    }

    for _, cmd in ipairs(commands) do
      local ok, pipe = pcall(io.popen, cmd)

      if ok and pipe then
        for line in pipe:lines() do
          addCandidate(line)
        end
        pipe:close()
      end
    end
  end

  -- Fallback from the old save system.
  do
    local lastRaw = readFile(dir .. "/_last_key.txt")
    local lastKey = tonumber(lastRaw)

    if lastKey and not seen[lastKey] then
      seen[lastKey] = true
      out[#out + 1] = {
        key = lastKey,
        path = dir .. "/" .. tostring(lastKey) .. ".lua",
      }
    end
  end

  table.sort(out, function(a, b)
    return (tonumber(a.key) or 0) > (tonumber(b.key) or 0)
  end)

  return out
end

local function VM_LegacyLoadNewestSession()
  local candidates = VM_LegacySessionCandidates()

  for _, c in ipairs(candidates) do
    local chunk = loadfile(c.path)

    if type(chunk) == "function" then
      local ok, data = pcall(chunk)

      if ok and type(data) == "table" and type(data.vehicles) == "table" and next(data.vehicles) ~= nil then
        return data, c.path, c.key
      end
    end
  end

  return nil, nil, nil
end

local function VM_FindSpecByLegacyLabel(label)
  local base = cleanKey(label)
  if not base then return nil end

  local candidates = {}
  local used = {}

  local function add(v)
    v = cleanKey(v)
    if v and not used[v] then
      used[v] = true
      candidates[#candidates + 1] = v
    end
  end

  add(base)

  -- Common garage / mod vehicle variants.
  add(base:gsub("_dummy$", ""))
  add(base:gsub("_player$", ""))
  add(base:gsub("_purchasable$", ""))
  add(base:gsub("_call$", ""))
  add(base:gsub("_player$", "_call"))
  add(base:gsub("_purchasable$", "_call"))

  for _, key in ipairs(candidates) do
    if CAR_SPECS[key] then
      return CAR_SPECS, CAR_SPECS_PATH, key, false
    end

    if BIKE_SPECS[key] then
      return BIKE_SPECS, BIKE_SPECS_PATH, key, true
    end
  end

  return nil
end

local function VM_ImportLegacyMetersLatest()
  reloadSpecFiles()

  local legacy, path = VM_LegacyLoadNewestSession()

  if not legacy then
    local msg = "Legacy import failed: no usable vm_session/*.lua file found."
    print("[VehicleMileage] " .. msg)
    queueToast(msg)
    return false
  end

  local matched = {}
  local scanned = 0
  local skipped = 0

  for rawKey, oldRec in pairs(legacy.vehicles or {}) do
    scanned = scanned + 1

    local label = VM_LegacyExtractLabel(rawKey)
    local meters = tonumber(oldRec and oldRec.meters)

    if label and meters and meters >= 0 then
      local map, cfgPath, key, isBike = VM_FindSpecByLegacyLabel(label)

      if map and key then
        local prev = matched[key]

        -- If duplicate legacy labels exist, keep the highest ODO.
        if not prev or meters > prev.meters then
          matched[key] = {
            meters = meters,
            map = map,
            cfgPath = cfgPath,
            isBike = isBike,
          }
        end
      else
        skipped = skipped + 1
      end
    else
      skipped = skipped + 1
    end
  end

  local carChanged = false
  local bikeChanged = false

  for key, item in pairs(matched) do
    if VMFS_EnsureFactKeys(key, item.map[key]) then
      if item.isBike then
        bikeChanged = true
      else
        carChanged = true
      end
    end
  end

  if carChanged then saveSpecMap(CAR_SPECS_PATH, CAR_SPECS) end
  if bikeChanged then saveSpecMap(BIKE_SPECS_PATH, BIKE_SPECS) end

  reloadSpecFiles()

  -- Refresh vm_save internal config cache after we touched spec JSON.
  if SAVE and SAVE._reloadConfigMaps then
    pcall(function()
      SAVE:_reloadConfigMaps()
    end)
  end

  local imported = 0
  local unchanged = 0

  for key, item in pairs(matched) do
    local v = SAVE and SAVE.ensureVehicle and SAVE:ensureVehicle(key) or nil

    if v then
      local oldMeters = math.max(0, tonumber(item.meters) or 0)
      local curMeters = math.max(0, tonumber(v.meters) or 0)
      local newMeters = math.max(curMeters, oldMeters)

      if math.floor(newMeters + 0.5) ~= math.floor(curMeters + 0.5) then
        v.meters = newMeters
        SAVE.dirty = true

        if SAVE.syncVehicle then
          SAVE:syncVehicle(key, true)
        end

        imported = imported + 1
      else
        unchanged = unchanged + 1
      end
    end
  end

  local msg = ("Legacy import done: %d updated, %d unchanged, %d skipped."):format(imported, unchanged, skipped)

  print("[VehicleMileage] " .. msg)
  print("[VehicleMileage] Legacy source: " .. tostring(path))
  queueToast(msg)

  return true
end

local function VM_OverwriteCurrentVehicleMeters(meters)
  meters = tonumber(meters)

  if not meters then
    queueToast("Manual meters overwrite failed: invalid number.")
    return false
  end

  meters = math.max(0, meters)

  local player = Game.GetPlayer()
  local veh = player and player:GetMountedVehicle() or nil

  if not veh then
    queueToast("Manual meters overwrite failed: not mounted.")
    return false
  end

  local id, label = vehKeyAndLabel(veh)
  local isBike = looksLikeBike(label) and true or false

  ensureSpecForLabel(label, isBike)
  reloadSpecFiles()

  if SAVE and SAVE._reloadConfigMaps then
    pcall(function()
      SAVE:_reloadConfigMaps()
    end)
  end

  local v = SAVE and SAVE.ensureVehicle and SAVE:ensureVehicle(id) or nil

  if not v then
    queueToast("Manual meters overwrite failed: no vehicle state.")
    return false
  end

  v.meters = meters
  SAVE.dirty = true

  if SAVE.syncVehicle then
    SAVE:syncVehicle(id, true)
  end

  setFactInt(FACT_HUD_METERS, math.floor(meters + 0.5))
  lastMetersPushed = math.floor(meters + 0.5)

  local msg = ("Meters overwritten: %.0f m"):format(meters)
  print("[VehicleMileage] " .. msg .. " for " .. tostring(label))
  queueToast(msg)

  return true
end

-- Inline editor state (per vehicle)
local UI_EDIT = {}

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Dynamic pricing                                                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function getInGameHour()
  local okTS, ts = pcall(function()
    return (Game and Game.GetTimeSystem and Game.GetTimeSystem())
    or (GameInstance and GameInstance.GetTimeSystem and GameInstance.GetTimeSystem())
  end) -- end function (anonymous)
if not okTS or not ts then return nil end -- end function getInGameHour

local okGT, GT = pcall(function() return ts:GetGameTime() end)
if okGT and GT then
local okH,  H  = pcall(function() return GT:Hours() end); if okH  and type(H)  == "number" then return H  end -- end function (anonymous)
local okH2, H2 = pcall(function() return GT:Hour()  end); if okH2 and type(H2) == "number" then return H2 end -- end function (anonymous)
local okS,  S  = pcall(function() return GT:ToSeconds() end)
if okS and type(S) == "number" then return math.floor((S / 3600) % 24) end -- end function (anonymous)
end

local okS2, S2 = pcall(function() return ts:GetGameTimeInSeconds() end) -- end function (anonymous)
if okS2 and type(S2) == "number" then return math.floor((S2 / 3600) % 24) end -- end function (anonymous)

return nil
end

-- ─────────── Oil helpers ───────────
local OIL_TRIP_WARMED = {}  -- id -> bool (not persisted)

local function oilRangeFor(spec, isBike)
  local lo = tonumber(spec and spec.oil_opt_min)
  local hi = tonumber(spec and spec.oil_opt_max)

  -- safe defaults (fallback to 80/120 even if constants are missing)
  local defLo = (isBike and VMCONST.OIL.DEF_BIKE_MIN or VMCONST.OIL.DEF_CAR_MIN) or 80.0
  local defHi = (isBike and VMCONST.OIL.DEF_BIKE_MAX or VMCONST.OIL.DEF_CAR_MAX) or 120.0

  lo = lo or defLo
  hi = hi or defHi

  if lo > hi then lo, hi = hi, lo end
  return lo, hi
end


-- Bitwise helpers for Lua 5.1 (CET)
-- Avoid rawget(_G, ...) because _G can be nil in CET.
local _bit = (type(bit32) == "table" and bit32)
          or (type(bit)   == "table" and bit)
if not _bit then
  -- Fallback: slow but fine for tiny strings
  local function _tobit(x) return x % 4294967296 end
  local function _bxor(a,b)
    local r, p = 0, 1
    while a > 0 or b > 0 do
      local aa, bb = a % 2, b % 2
      if aa ~= bb then r = r + p end
      a = (a - aa) / 2; b = (b - bb) / 2; p = p * 2
    end
    return r
  end
  _bit = { bxor = _bxor, tobit = _tobit }
end


local function _hash32(s)
  local h = 5381
  for i = 1, #s do
    -- use CET-safe bit ops
    h = _bit.tobit(_bit.bxor(h * 33, string.byte(s, i)))
  end
  return h
end


local function norm01_from_label(label, salt)
  local h = _hash32((label or "veh") .. "|" .. (salt or ""))
  return (h % 10000) / 10000.0
end

local function ambientColdNow(label)
  local hour = getInGameHour() or 12
  local day  = (hour >= 8 and hour < 20)
	local lo   = day and VMCONST.OIL.DAY_MIN   or VMCONST.OIL.NIGHT_MIN
	local hi   = day and VMCONST.OIL.DAY_MAX   or VMCONST.OIL.NIGHT_MAX
  local base = lo + (hi - lo) * norm01_from_label(label, "base")
  local jit  = 1.0 + ((norm01_from_label(label, "jit") * 2.0 - 1.0) * VMCONST.OIL.JITTER_PCT)
  local t    = base * jit
  if t < 0 then t = 0 end
  return t
end

local function tickOilTemp(v, kmh, dt, isBike, spec, vehLabel, vehId, mounted)
  if not v then return end
  dt  = tonumber(dt or 0) or 0
  kmh = math.max(0.0, tonumber(kmh or 0) or 0)

  local amb   = ambientColdNow(vehLabel or tostring(vehId or "veh"))
  local lo,hi = oilRangeFor(spec, isBike)
  local T     = tonumber(v.oil_temp) or amb

  local function pullToward(curr, target, k)
    return curr + (target - curr) * k * dt
  end

  if not mounted then
    -- Unmounted: cool to ambient
    T = pullToward(T, amb, VMCONST.OIL.K_COOL_OFF)

  else
    -- Mounted: pick a target by speed
    local idleSpd = (VMCONST.IDLE and VMCONST.IDLE.SPEED_KMH) or 2.0
    local target, k

    if kmh < idleSpd then
      -- Idle: heat only up to lo (and bleed back down to lo if above)
      target, k = lo, VMCONST.OIL.K_IDLE_TO_LO

		elseif kmh < (VMCONST.OIL.FAST_START_KMH or 100.0) then
			-- Normal driving below fast threshold:
			-- keep oil around the lower optimal value.
			target = lo
			local up   = VMCONST.OIL.K_DRIVE_TO_LO_UP   or VMCONST.OIL.K_DRIVE_TO_LO
			local down = VMCONST.OIL.K_DRIVE_TO_LO_DOWN or VMCONST.OIL.K_DRIVE_TO_LO
			k = (T < lo) and up or down

    else
      -- Too fast:
      -- from 100+ km/h, oil can exceed the optimal max.
      local fastStart = VMCONST.OIL.FAST_START_KMH or 100.0
      local extra = (kmh - fastStart) * (VMCONST.OIL.HI_EXCEED_PER_KMH or 0.35)
      target = hi + math.max(0.0, extra)

      local up   = VMCONST.OIL.K_FAST_TO_EXCEED_UP
                or VMCONST.OIL.K_DRIVE_TO_HI_UP
                or VMCONST.OIL.K_DRIVE_TO_HI

      local down = VMCONST.OIL.K_FAST_TO_EXCEED_DOWN
                or VMCONST.OIL.K_DRIVE_TO_HI_DOWN
                or VMCONST.OIL.K_DRIVE_TO_HI

      k = (T < target) and up or down
    end

    -- Main pull to speed-defined target
    T = pullToward(T, target, k)

		-- Stability damper:
		-- only if we are above the current target.
		-- This prevents crazy spikes but never cools below the speed-defined target.
		if kmh >= (VMCONST.OIL.FAST_START_KMH or 100.0) and T > target then
			local spdFr = math.min(kmh / 180.0, 1.0)
			local kcool = VMCONST.OIL.K_COOL_MOV * (0.30 + 0.70 * spdFr)
			T = pullToward(T, target, kcool)
		end


	
  end

	 -- Clamp
	if T > VMCONST.OIL.CAP_C then T = VMCONST.OIL.CAP_C end
	if T < -50.0 then T = -50.0 end

	-- Always update the value so the CET overlay changes every frame
	local prev = v.oil_temp or T
	v.oil_temp = T

	-- Only flag the save occasionally (to avoid spamming tiny diffs)
	v._last_persist_oil = v._last_persist_oil or prev
	if math.abs(v._last_persist_oil - T) >= 0.5 then
		v._last_persist_oil = T
		SAVE.dirty = true
	end
end


-- ─────────────────────────────────────────────────────────────────────────────



local function randn()
local u1 = math.random(); if u1 < 1e-12 then u1 = 1e-12 end -- end function randn
local u2 = math.random()
return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
end

local function nextDynamicPrice(base, prev)
  base = tonumber(base) or DEFAULT_PRICE_EPL
  prev = tonumber(prev) or base
	local shock   = randn() * VMCONST.PRICE.DYN_VOLATILITY
	local drift   = (base - prev) * VMCONST.PRICE.DYN_MEAN_REVERT
	local rawP    = prev + drift + shock
	local minP    = math.max(0.0, base * VMCONST.PRICE.DYN_MIN_MULT)
	local maxP    = math.max(minP, base * VMCONST.PRICE.DYN_MAX_MULT)
	local clamped = math.max(minP, math.min(maxP, rawP))
  return math.floor(clamped * 100 + 0.5) / 100.0
end -- end function nextDynamicPrice

local function applyFuelPrice(newPrice, opts)
  opts = opts or {}
  local persistBase = opts.persist_base == true
  local requestedPrice = tonumber(newPrice) or currentPrice or DEFAULT_PRICE_EPL
  if requestedPrice < 0 then requestedPrice = 0 end

  local economyMultiplier = 1.0
  if VM_GAS_ECONOMY and VM_GAS_ECONOMY.getPriceMultiplier then
    economyMultiplier = VM_GAS_ECONOMY.getPriceMultiplier()
  end
  if VM_GAS_ECONOMY and VM_GAS_ECONOMY.setMarketPrice then
    VM_GAS_ECONOMY.setMarketPrice(requestedPrice)
  end

  -- The economy can at most double the configured base price. This remains a
  -- strict +100% ceiling even when the optional hourly market fluctuation is on.
  local configuredBase = persistBase and requestedPrice
    or tonumber(SETTINGS.price_epl) or requestedPrice
  newPrice = math.min(
    requestedPrice * math.max(1.0, math.min(2.0, economyMultiplier)),
    math.max(0, configuredBase * 2.0)
  )

  if not currentPrice or math.abs(newPrice - currentPrice) >= 0.0005 then
    currentPrice = newPrice
    setFactInt(FACT_HUD_PRICE_CENTS, math.floor((currentPrice * 100) + 0.5))

    if type(GAS.setUnitPricePerLiter) == "function" then
      pcall(GAS.setUnitPricePerLiter, currentPrice)
    elseif GAS_OPTS_REF then
      GAS_OPTS_REF.unit_price_per_liter = currentPrice
      pcall(GAS.setup, GAS_OPTS_REF)
    end
    pushPriceFact(true)

    if not persistBase then
      print(("[VehicleOdometer] Runtime price: %.2f Eddies/L"):format(currentPrice))
    end
  end

  -- Persist the user's unmodified base price even when the resulting runtime
  -- price happens to be unchanged after the economy multiplier is applied.
  if persistBase then
    SETTINGS.price_epl = requestedPrice
    saveSettings()
    print(("[VehicleOdometer] Base price updated by user: %.2f Eddies/L")
      :format(requestedPrice))
  end
end

-- Ignore helpers (NS actions)
local function ignoreCurrentVehicle()
local player = Game.GetPlayer(); if not player then print("[VehicleOdometer] No player") return end -- end function ignoreCurrentVehicle
local veh = player:GetMountedVehicle(); if not veh then print("[VehicleOdometer] Not mounted") return end
local _, label = vehKeyAndLabel(veh)
local ok, msg = ignoreAdd(label)
print("[VehicleOdometer] " .. tostring(msg))
if ok then
  setFactInt(FACT_HUD_VISIBLE, 0)
  setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
  queueToast(("Ignored vehicle: %s"):format(label))
else
  queueToast(msg or "Already ignored")
end
end

local function unignoreCurrentVehicle()
local player = Game.GetPlayer(); if not player then print("[VehicleOdometer] No player") return end -- end function unignoreCurrentVehicle
local veh = player:GetMountedVehicle(); if not veh then print("[VehicleOdometer] Not mounted") return end
local _, label = vehKeyAndLabel(veh)
local ok, msg = ignoreRemove(label)
print("[VehicleOdometer] " .. tostring(msg))
if ok then
  queueToast(("Unignored vehicle: %s"):format(label))
else
  queueToast(msg or "Was not ignored")
end
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Native Settings UI                                                        ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function addMomentarySwitch(ns, path, title, desc, cb)
  local id
  local labelDesc = (desc or "") .. "\n(Press to run; auto-resets.)"

  local function handler(state)
  if not state then return end -- end function handler
  local ok, err = pcall(cb)
if not ok then print("[VehicleOdometer] NS action error: " .. tostring(err)) end
if type(ns.setOption) == "function" and id then pcall(ns.setOption, id, false) end
end

local ok6, ret6 = pcall(function()
  return ns.addSwitch(path, title, labelDesc, false, false, handler)
end) -- end function (anonymous)
if ok6 and ret6 then id = ret6; return id end -- end function addMomentarySwitch

local ok5, ret5 = pcall(function()
  return ns.addSwitch(path, title, labelDesc, false, handler)
end) -- end function (anonymous)
if ok5 and ret5 then id = ret5; return id end

pcall(function()
  ns.addAction(path, title, desc or "", function()
    local ok, err = pcall(cb)
  if not ok then print("[VehicleOdometer] NS action error: " .. tostring(err)) end -- end function (anonymous)
end)
end) -- end function (anonymous)
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Widget runtime glue (legacy VMHUD vs new FuelGauge)                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- --- UI readiness + hard-off helpers ----------------------------------------
local function _ui()
  local ok, u = pcall(Game.GetUISystem)
  return ok and u or nil
end

local function uiTogglesReady()
  local ui = _ui(); if not ui then return false end
  if not (ui.VM_EnableLegacyHUD and ui.FG_EnableFuelGauge) then return false end
  if not (ui.VM_HaveLegacySlot and ui.FG_HavePlace) then return false end
  return ui:VM_HaveLegacySlot() and ui:FG_HavePlace()
end

local function uiTransformsReady()
  local ui = _ui(); if not ui then return false end
  if not (ui.FG_SetOffset and ui.FG_SetScale and ui.FG_HavePlace) then return false end
  return ui:FG_HavePlace()
end

-- ----------------------------------------------------------------------------

-- Try multiple method names to be version-safe with your Redscript side.
--  method  = string name of the UI function to call (e.g. "VM_LB_SetRow")
--  ...     = ANY extra args you want to pass through to that function
--            (row index, texts, offsets, etc.). This is Lua's "varargs".
local function _callUI(method, ...)
  local ui = _ui()
  if not ui then
    -- No UISystem yet (or UI not ready) → just fail quietly.
    return false
  end

  -- Look up the method on the UISystem object: ui[method]
  local ok, fn = pcall(function()
    return ui[method]
  end)

  if ok and type(fn) == "function" then
    -- Call ui[method](ui, ...) and forward all extra parameters via "..."
    local ok2, err = pcall(fn, ui, ...)
    if not ok2 then
      print("[VehicleOdometer] UI call error [" .. tostring(method) .. "]: " .. tostring(err))
    end
    return ok2
  end

  -- Method not found or not callable
  return false
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3D World runtime apply                                                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

function VMWorld_ResetDraftFromSettings()
  VMWORLD_STATE = VMWorld_SanitizeSettings(SETTINGS.world3d)
end

function VMWorld_GetDraftObject(key)
  if type(VMWORLD_STATE) ~= "table" then
    VMWorld_ResetDraftFromSettings()
  end

  VMWORLD_STATE[key] = VMWorld_SanitizeObject(key, VMWORLD_STATE[key])
  return VMWORLD_STATE[key]
end

function VMWorld_ApplyOne(key, source)
  -- Wake the world widget into fast refresh mode while using sliders/buttons.
  -- 20 ticks * 0.25 sec = about 5 seconds of smooth live preview.
  _callUI("VM_World_RequestFastTicks", 20)

  local cfg = source or VMWORLD_STATE or VMWorld_SanitizeSettings(SETTINGS.world3d)
  local o = VMWorld_SanitizeObject(key, cfg[key])

  if key == "lb" then
		_callUI(
			"VM_WorldLB_SetStyle",
			o.theme,
			o.font_index,
			o.font_size,
			o.hidden == true,
			o.brightness_milli or 1000,
			o.border_hidden == true
		)
    _callUI("VM_WorldLB_SetTransform", o.x + 0.0, o.y + 0.0, o.scale)
    return
  end

  local auxIndex = VMWORLD_AUX_INDEX[key]

	if auxIndex then
		local shown = (o.hidden ~= true)

		_callUI(
			"VM_WorldAux_SetConfig",
			auxIndex,
			o.theme,
			o.font_index,
			o.font_size,
			o.x + 0.0,
			o.y + 0.0,
			o.scale,
			shown,
			o.brightness_milli or 1000
		)
	end
end

function VMWorld_ApplyAll(source)
  if type(VMWORLD_STATE) ~= "table" then
    VMWorld_ResetDraftFromSettings()
  end

  local cfg = source or VMWORLD_STATE

  for _, key in ipairs(VMWORLD_OBJECT_ORDER) do
    VMWorld_ApplyOne(key, cfg)
  end
end

function VMWorld_ResetObject(key)
  if type(VMWORLD_STATE) ~= "table" then
    VMWorld_ResetDraftFromSettings()
  end

  VMWORLD_STATE[key] = VMWorld_CopyDefault(key)
  VMWorld_ApplyOne(key)
end

function VMWorld_SaveDraft()
  if type(VMWORLD_STATE) ~= "table" then
    VMWorld_ResetDraftFromSettings()
  end

  SETTINGS.world3d = VMWorld_SanitizeSettings(VMWORLD_STATE)

  local ok = saveSettings()

  if ok then
    VMWORLD_STATUS = "Saved 3D World settings to vm_settings.json."
    queueToast("Saved 3D World settings.")
  else
    VMWORLD_STATUS = "Save failed. Could not write vm_settings.json."
  end

  VMWorld_ApplyAll()
  return ok
end

-- Helper: hard-stop refuel state (sound + price plate + internal flag)
local function _forceStopRefuel()
  -- NEW: give vm_gas_station one "stop" tick so it can shut down its looped audio
  if refuelingPrev and GAS and GAS.update then
    pcall(GAS.update, 0.0, {
      -- dummy helpers so update() can safely call them if it wants
      ensureVehicle  = function(_) return nil end,
      vehKeyAndLabel = function(_) return "", "" end,
      getSpecs       = function(_) return FALLBACK_CAR end,
      hard_stop      = true,   -- optional flag; ignored by older versions
    })
  end

  -- reset GAS refill rate if we're using the options table
  if type(GAS.setRefillPerSec) ~= "function" and GAS_OPTS_REF then
    GAS_OPTS_REF.refill_per_sec = VMCONST.REFILL.RATE_FAST
    pcall(GAS.setup, GAS_OPTS_REF)
    lastRefillPerSec = GAS_OPTS_REF.refill_per_sec
  end
  rateCooldown  = 0.0
  refuelingPrev = false

  -- kill price plate + leaderboard immediately
  setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
  _callUI("VM_LB_ForceHide")
  _callUI("VM_ForceHidePricePlate")

  -- extra safety: also tell GAS (if it exposes a stop API in future)
  if type(GAS.stopNow) == "function" then
    pcall(GAS.stopNow)
  end

  priceVisibleLast = false
end


-- -- Push the current Top-10 snapshot into the HUD ("ODO TOP 10" plate)
-- local function vmPushTop10HUD(arr)
  -- -- clear existing
  -- _callUI("VM_LB_Clear")
  -- -- feed up to 10
  -- local n = math.min(10, #arr)
  -- for i = 1, n do
    -- local e = arr[i]
    -- local nice  = vmResolveVehicleDisplayName(e.label)
    -- local kmStr = string.format("%05d km", tonumber(e.km) or 0)
    -- _callUI("VM_LB_SetRow", i, nice, kmStr)
  -- end
  -- -- make sure the LB is enabled on the UI side (still gated by price plate visibility)
  -- _callUI("VM_LB_SetEnabled", true)
-- end

-- Push the current Top-10 snapshot into the HUD ("ODO TOP 10" plate)
vmPushTop10HUD = function(arr)
  -- clear existing 2D price-plate leaderboard
  _callUI("VM_LB_Clear")

  -- clear world/entity leaderboard
  _callUI("VM_WorldLB_Clear")

  local n = math.min(10, #arr)

  for i = 1, n do
    local e = arr[i]
    local nice  = vmResolveVehicleDisplayName(e.label)
    local kmStr = string.format("%05d km", tonumber(e.km) or 0)

    -- existing 2D HUD leaderboard
    _callUI("VM_LB_SetRow", i, nice, kmStr)

    -- new world/entity leaderboard
    _callUI("VM_WorldLB_SetRow", i, nice, kmStr)
  end
end

VM_WORLD_LB_ACC = VM_WORLD_LB_ACC or 0.0
VM_WORLD_LB_INTERVAL = VM_WORLD_LB_INTERVAL or 5.0

function VM_WorldLB_PushTop10FromFactConfigs()
  local arr = {}
  local seen = {}

  local function addFromSpecMap(map)
    for label, rec in pairs(map or {}) do
      local key = cleanKey(label) or tostring(label or "")
      local facts = type(rec) == "table" and rec.vm_facts or nil
      local metersFact = type(facts) == "table" and facts.meters or nil

      if key ~= "" and type(metersFact) == "string" and metersFact ~= "" and not seen[key] then
        local meters = VM_GetFactInt(metersFact, 0)
        local km = math.floor((meters / 1000.0) + 0.5)

        if km >= 1 then
          seen[key] = true

          table.insert(arr, {
            label = key,
            meters = meters,
            km = km,
          })
        end
      end
    end
  end

  addFromSpecMap(CAR_SPECS)
  addFromSpecMap(BIKE_SPECS)

  table.sort(arr, function(a, b)
    return (a.meters or 0) > (b.meters or 0)
  end)

  _callUI("VM_WorldLB_Clear")

  local n = math.min(10, #arr)

  if n <= 0 then
    _callUI("VM_WorldLB_SetRow", 1, "No odometer data yet", "00000 km")
    return
  end

  for i = 1, n do
    local e = arr[i]
    local nice = vmResolveVehicleDisplayName(e.label)
    local kmStr = string.format("%05d km", tonumber(e.km) or 0)

    _callUI("VM_WorldLB_SetRow", i, nice, kmStr)
  end
end

local function forceAllWidgetsOff()
  _callUI("VM_EnableLegacyHUD", false)
  _callUI("FG_EnableFuelGauge", false)
  setFactInt("vm_fg_enabled", 0)

  -- Also hard-disable the vehicle-bound 3D widget.
	VM_SetFactIntCached("vm_3d_enabled", 0)
	VM3D_SetHiddenFacts(true, true, true, true)
  VM3D_LAST_LOADED_ID = nil
end

local function applyFuelGaugeTransforms(dx, dy, scale)
  -- Use nil-friendly fallbacks to your code defaults
  dx    = math.floor(tonumber(dx) or SETTINGS.fg_dx_px or FG_DEF_DX)
  dy    = math.floor(tonumber(dy) or SETTINGS.fg_dy_px or FG_DEF_DY)
  scale = math.floor(tonumber(scale) or SETTINGS.fg_scale or FG_DEF_SCALE)

  -- Clamp to wide-screen ranges
  if dx < -7000 then dx = -7000 elseif dx > 7000 then dx = 7000 end
  if dy < -7000 then dy = -7000 elseif dy > 7000 then dy = 7000 end
  if scale < 0 then scale = 0 elseif scale > 7000 then scale = 7000 end

  -- Gauge API uses 600 = 1.00x (handled inside FG_SetScale); sign: +X=RIGHT, +Y=DOWN
  _callUI("FG_SetOffset", dx, dy)
  _callUI("FG_SetScale",  scale)
	  -- NEW: keep per-save facts identical to whatever we just applied
  setFactInt("vm_gauge_dx",           dx)
  setFactInt("vm_gauge_dy",           dy)
  setFactInt("vm_gauge_scale_milli",  scale)
end

function VM_DebugForceReapplyFG()
  applyFuelGaugeTransforms(SETTINGS.fg_dx_px, SETTINGS.fg_dy_px, SETTINGS.fg_scale)
end


local function applyLegacyHUDTransforms()
  local hx = tonumber(SETTINGS.hud_x)
  local hy = tonumber(SETTINGS.hud_y)
  if hx then _callUI("VM_SetHUDPosX", hx) end
  if hy then _callUI("VM_SetHUDPosY", hy) end
end

local function apply3DWidgetRuntime(is3D)
  -- Master fact for future Redscript checks
  VM_SetFactIntCached("vm_3d_enabled", is3D and 1 or 0)

  if is3D then
    -- Vehicle-specific 3D config is loaded by VM3D_LoadForMountedVehicle().
  else
    -- Hard-hide 3D widget while another HUD widget is active.
    if VM3D_ForceHidden then
      VM3D_ForceHidden()
    else
      setFactInt("vm_3d_fuel_hidden", 1)
      setFactInt("vm_3d_odo_hidden", 1)
    end
  end
end

local function applyWidgetModeRuntime(mode)
  mode = tostring(mode or SETTINGS.widget_mode or "fuelgauge"):lower()

  local isLegacy = (mode == "vmhud")
  local isFG     = (mode == "fuelgauge")
  local is3D     = (mode == "3dwidget")

  _callUI("VM_SetWidgetMode", mode)

  -- Classic 2D legacy HUD
  _callUI("VM_EnableLegacyHUD", isLegacy)

  -- Digital 2D FuelGauge
  local fgOK = isFG and ((SETTINGS.fg_enabled ~= false) and true or false)
  _callUI("FG_EnableFuelGauge", fgOK)
  setFactInt("vm_fg_enabled", fgOK and 1 or 0)

  -- 2D FuelGauge temp meter only when 2D FuelGauge is active
  setFactInt(FACT_FG_TEMP_VISIBLE, (isFG and fgOK and (SETTINGS.fg_temp_enabled ~= false)) and 1 or 0)

  -- 3D widget visibility
  apply3DWidgetRuntime(is3D)

  -- Reapply transforms for the chosen 2D widget only
  if isFG then
    applyFuelGaugeTransforms(SETTINGS.fg_dx_px, SETTINGS.fg_dy_px, SETTINGS.fg_scale)
  elseif isLegacy then
    applyLegacyHUDTransforms()
  end
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3D widget vehicle config runtime                                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

VM3D_LAST_LOADED_ID = VM3D_LAST_LOADED_ID or nil

function VM3D_IsActiveMode()
  return tostring(SETTINGS and SETTINGS.widget_mode or ""):lower() == "3dwidget"
end

function VM3D_ForceHidden()
  VM_SetFactIntCached("vm_3d_enabled", 0)
  VM3D_SetHiddenFacts(true, true, true, true)
	

  -- Important: force reload when switching back to 3D Widget later.
  VM3D_LAST_LOADED_ID = nil

  if VM3D_CONTROLS and VM3D_CONTROLS.reloadFromFacts then
    pcall(VM3D_CONTROLS.reloadFromFacts)
  end
end

function VM3D_ReadFactInt(name, def)
  local qs = Game.GetQuestsSystem()
  if not qs then return def or 0 end

  local ok, value = pcall(function()
    return qs:GetFactStr(name)
  end)

  if ok then
    return VM3D_ToInt(value)
  end

  return def or 0
end

function VM3D_ApplyConfigToFacts(cfg)
  local c = VM3D_SanitizeConfig(cfg) or VM3D_Defaults()

  for groupKey, fields in pairs(VM3D_FIELDS) do
    for _, key in ipairs(VM3D_FIELD_ORDER) do
      setFactInt(fields[key].fact, c[groupKey][key])
    end
  end

	setFactInt("vm_3d_fuel_style", c.fuel_style)
	setFactInt("vm_3d_fuel_alt_style", c.fuel_alt_style)
	setFactInt("vm_3d_theme", c.theme)
	setFactInt("vm_3d_font_index", c.font_index)
	setFactInt("vm_3d_font_scale_milli", c.font_scale_milli)
	setFactInt("vm_3d_emissive_ev_deci", c.emissive_ev_deci)

	VM3D_SetHiddenFacts(
		c.hide_fuel == true,
		c.hide_odo == true,
		c.hide_fuel_alt == true,
		c.hide_odo_alt == true
	)

  setFactInt("vm_3d_odo_hide_frame", c.hide_odo_frame and 1 or 0)
  setFactInt("vm_3d_odo_alt_hide_frame", c.hide_odo_alt_frame and 1 or 0)

  if VM3D_CONTROLS and VM3D_CONTROLS.reloadFromFacts then
    pcall(VM3D_CONTROLS.reloadFromFacts)
  end
end

function VM3D_SnapshotFromFacts()
  local out = VM3D_Defaults()

  for groupKey, fields in pairs(VM3D_FIELDS) do
    for _, key in ipairs(VM3D_FIELD_ORDER) do
      local f = fields[key]
      out[groupKey][key] = VM3D_Clamp(VM3D_ReadFactInt(f.fact, f.default), f.min, f.max, f.default)
    end
  end

	out.fuel_style = VM3D_Clamp(VM3D_ReadFactInt("vm_3d_fuel_style", 0), 0, 5, 0)
	out.fuel_alt_style = VM3D_Clamp(VM3D_ReadFactInt("vm_3d_fuel_alt_style", 0), 0, 5, 0)
	out.theme = VM3D_Clamp(VM3D_ReadFactInt("vm_3d_theme", 0), 0, 9, 0)
	out.font_index = VM3D_Clamp(VM3D_ReadFactInt("vm_3d_font_index", 0), 0, 13, 0)

  local fs = VM3D_ReadFactInt("vm_3d_font_scale_milli", 1000)
  if fs <= 0 then fs = 1000 end
  out.font_scale_milli = VM3D_Clamp(fs, 500, 2000, 1000)
	out.emissive_ev_deci = VM3D_Clamp(VM3D_ReadFactInt("vm_3d_emissive_ev_deci", 60), 0, 120, 60)

  out.hide_fuel = VM3D_ReadFactInt("vm_3d_fuel_hidden", 0) > 0
  out.hide_odo = VM3D_ReadFactInt("vm_3d_odo_hidden", 0) > 0
  out.hide_odo_frame = VM3D_ReadFactInt("vm_3d_odo_hide_frame", 0) > 0
	
	out.hide_fuel_alt = VM3D_ReadFactInt("vm_3d_fuel_alt_hidden", 0) > 0
  out.hide_odo_alt = VM3D_ReadFactInt("vm_3d_odo_alt_hidden", 0) > 0
  out.hide_odo_alt_frame = VM3D_ReadFactInt("vm_3d_odo_alt_hide_frame", 0) > 0

  return out
end

function VM3D_GetMountedOwnedContext()
  local player = Game.GetPlayer()

  if not player then
    return nil, "No player found."
  end

  local veh = player:GetMountedVehicle()

  if not veh then
    return nil, "Not mounted in a vehicle."
  end

  local id, label = vehKeyAndLabel(veh)

  local owned = false
  pcall(function()
    owned = veh:IsPlayerVehicle()
  end)

  if not owned then
    owned = isOwnedViaUnlockedList(label)
  end

  if not owned then
    return nil, "Current vehicle is not player-owned."
  end

  if ignoreIs(label) then
    return nil, "Current vehicle is ignored by VehicleMileage."
  end

  return {
    id = id,
    label = label,
    name = vmResolveVehicleDisplayName(label),
    isBike = looksLikeBike(label) and true or false,
  }, nil
end

function VM3D_TargetMapFor(ctx)
  local key = cleanKey(ctx.label) or ctx.label
  local map = ctx.isBike and BIKE_SPECS or CAR_SPECS
  local path = ctx.isBike and BIKE_SPECS_PATH or CAR_SPECS_PATH

  return map, path, key
end

function VM3D_LoadForMountedVehicle(force)
  -- Critical:
  -- Never load/apply per-vehicle 3D facts while another HUD mode is selected.
  if not VM3D_IsActiveMode() then
    VM3D_ForceHidden()
    return false, "3D Widget mode is not active."
  end

  local ctx, reason = VM3D_GetMountedOwnedContext()

  if not ctx then
    VM3D_LAST_LOADED_ID = nil

    -- Safety: no owned vehicle = disable/hide 3D widgets.
    VM_SetFactIntCached("vm_3d_enabled", 0)
    VM3D_SetHiddenFacts(true, true, true, true)

    return false, reason
  end

  -- We are mounted in a valid owned vehicle and 3D mode is active.
  -- Re-enable the 3D widget before applying saved vehicle config.
  VM_SetFactIntCached("vm_3d_enabled", 1)

  if not force and VM3D_LAST_LOADED_ID == ctx.id then
    return true
  end

  ensureSpecForLabel(ctx.label, ctx.isBike)

  local map, _, key = VM3D_TargetMapFor(ctx)
  local rec = map and map[key] or nil

  -- Always try vehicle config first.
  -- If missing, apply defaults.
  if rec and type(rec.vm3d) == "table" then
    VM3D_ApplyConfigToFacts(rec.vm3d)
  else
    VM3D_ApplyConfigToFacts(nil)
  end

  VM3D_LAST_LOADED_ID = ctx.id
  return true
end

function VM3D_SaveMountedVehicle()
  local ctx, reason = VM3D_GetMountedOwnedContext()

  if not ctx then
    queueToast("3D setup save failed: " .. tostring(reason))
    return false
  end

  ensureSpecForLabel(ctx.label, ctx.isBike)

  local map, path, key = VM3D_TargetMapFor(ctx)

  if not map[key] then
    reloadSpecFiles()
    map, path, key = VM3D_TargetMapFor(ctx)
  end

  if not map[key] then
    queueToast("3D setup save failed: missing spec for " .. tostring(ctx.name))
    return false
  end

  map[key].vm3d = VM3D_SnapshotFromFacts()

  local ok = saveSpecMap(path, map)

  if ok then
    reloadSpecFiles()
    queueToast("Saved 3D setup for " .. tostring(ctx.name))
    print("[VehicleMileage] Saved 3D setup for " .. tostring(ctx.label))
  else
    queueToast("3D setup save failed for " .. tostring(ctx.name))
  end

  return ok
end

function VM3D_ResetMountedVehicle()
  local ctx, reason = VM3D_GetMountedOwnedContext()

  if not ctx then
    queueToast("3D setup reset failed: " .. tostring(reason))
    return false
  end

  ensureSpecForLabel(ctx.label, ctx.isBike)

  local map, path, key = VM3D_TargetMapFor(ctx)

  if map[key] then
    map[key].vm3d = nil
  end

  local ok = saveSpecMap(path, map)

  VM3D_ApplyConfigToFacts(nil)
  VM3D_LAST_LOADED_ID = ctx.id

  if ok then
    reloadSpecFiles()
    queueToast("Reset 3D setup for " .. tostring(ctx.name))
    print("[VehicleMileage] Reset 3D setup for " .. tostring(ctx.label))
  else
    queueToast("3D setup reset failed for " .. tostring(ctx.name))
  end

  return ok
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3D widget preset save/load                                                ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- IMPORTANT:
-- Do not use local functions here.
-- init.lua is close to Lua/CET's 200 local variable limit.

function VM3D_EnsurePresetDir()
  local testPath = VM3D_PRESET_DIR .. "/.__vm3d_test.tmp"

  local f = io.open(testPath, "w")
  if f then
    f:write("ok")
    f:close()
    pcall(os.remove, testPath)
    return true
  end

  if os and os.execute then
    pcall(function()
      os.execute('mkdir "' .. VM3D_PRESET_DIR .. '" >nul 2>nul')
    end)
  end

  f = io.open(testPath, "w")
  if f then
    f:write("ok")
    f:close()
    pcall(os.remove, testPath)
    return true
  end

  return false
end

function VM3D_SafePresetBaseName(name)
  local s = tostring(name or "Vehicle")

  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s == "" then
    s = "Vehicle"
  end

  -- User requested: whitespace becomes "_"
  s = s:gsub("%s+", "_")

  -- Windows-invalid filename chars
  s = s:gsub('[<>:"/\\|%?%*]', "_")

  -- Extra cleanup
  s = s:gsub("[\r\n\t]", "_")
  s = s:gsub("_+", "_")
  s = s:gsub("^_+", ""):gsub("_+$", "")

  if s == "" then
    s = "Vehicle"
  end

  return s
end

function VM3D_PresetNameFromValue(value)
  if type(value) == "table" then
    if type(value.file) == "string" and value.file ~= "" then
      local file = value.file:match("([^/\\]+)$") or value.file
      return file:gsub("%.json$", "")
    end

    if type(value.filename) == "string" and value.filename ~= "" then
      local file = value.filename:match("([^/\\]+)$") or value.filename
      return file:gsub("%.json$", "")
    end

    if type(value.base) == "string" and value.base ~= "" then
      return value.base:gsub("%.json$", "")
    end

    if type(value.name) == "string" and value.name ~= "" then
      return value.name
    end

    return ""
  end

  return tostring(value or "")
end

function VM3D_PresetPathFromName(name)
  local presetName = VM3D_PresetNameFromValue(name)
  local base = VM3D_SafePresetBaseName(presetName)

  return VM3D_PRESET_DIR .. "/" .. base .. ".json", base
end

function VM3D_NextFreePresetPathFromName(name)
  local displayBase = tostring(name or "Vehicle")

  displayBase = displayBase:gsub("^%s+", ""):gsub("%s+$", "")
  if displayBase == "" then
    displayBase = "Vehicle"
  end

  local fileBase = VM3D_SafePresetBaseName(displayBase)
  local suffix = 0

  while suffix < 1000 do
    local fileName = fileBase
    local displayName = displayBase

    if suffix > 0 then
      fileName = fileBase .. "_V" .. tostring(suffix)
      displayName = displayBase .. " V" .. tostring(suffix)
    end

    local path = VM3D_PRESET_DIR .. "/" .. fileName .. ".json"
    local f = io.open(path, "r")

    if f then
      f:close()
      suffix = suffix + 1
    else
      return path, fileName, displayName
    end
  end

  local fallbackFile = fileBase .. "_V" .. tostring(os.time())
  local fallbackName = displayBase .. " V" .. tostring(os.time())

  return VM3D_PRESET_DIR .. "/" .. fallbackFile .. ".json", fallbackFile, fallbackName
end

function VM3D_ListPresetNames()
  VM3D_EnsurePresetDir()

  local out = {}
  local seen = {}

  local function addPresetFile(fileName)
    fileName = VM3D_NormalizePresetFileName(fileName)

    if fileName == "" then return end
    if fileName == "_index.json" then return end
    if seen[fileName] then return end

    local path = VM3D_PRESET_DIR .. "/" .. fileName
    local raw = readFile(path)

    if not raw or raw == "" then
      return
    end

    local decoded = json_decode(raw)

    if type(decoded) ~= "table" then
      print("[VehicleMileage] Preset skipped invalid JSON: " .. tostring(path))
      return
    end

    local displayName = VM3D_PresetDisplayNameFromData(decoded, fileName)

    seen[fileName] = true
    out[#out + 1] = {
      file_name = fileName,
      name = displayName,
    }
  end

  if type(dir) == "function" then
    local scanDirs = {
      VM3D_PRESET_DIR,
      "./" .. VM3D_PRESET_DIR,
    }

    for _, scanDir in ipairs(scanDirs) do
      local ok, files = pcall(dir, scanDir)

      if ok and type(files) == "table" then
        for _, file in ipairs(files) do
          local fileName = nil

          if type(file) == "table" then
            fileName = file.name
          else
            fileName = tostring(file or "")
          end

          if type(fileName) == "string" and fileName:match("%.json$") then
            addPresetFile(fileName)
          end
        end
      end
    end
  end

function VM3D_RefreshPresetList()
  local list = VM3D_ListPresetNames()
  local msg = ("Preset list refreshed: %d found."):format(#list)

  print("[VehicleMileage] " .. msg)
  return true, msg
end


  table.sort(out, function(a, b)
    return tostring(a.name or ""):lower() < tostring(b.name or ""):lower()
  end)

  return out
end

function VM3D_NormalizePresetFileName(fileName)
  local s = tostring(fileName or "")
  s = s:match("([^/\\]+)$") or s
  s = s:gsub("^%s+", ""):gsub("%s+$", "")

  if s == "" then
    return ""
  end

  if not s:match("%.json$") then
    s = s .. ".json"
  end

  return s
end

function VM3D_PresetRefToFileName(presetRef)
  if type(presetRef) == "table" then
    return VM3D_NormalizePresetFileName(
      presetRef.file_name or presetRef.filename or presetRef.name
    )
  end

  return VM3D_NormalizePresetFileName(presetRef)
end

function VM3D_PresetDisplayNameFromData(data, fallback)
  if type(data) == "table" then
    if type(data.name) == "string" and data.name ~= "" then
      return data.name
    end

    if type(data._preset) == "table" then
      if type(data._preset.name) == "string" and data._preset.name ~= "" then
        return data._preset.name
      end

      if type(data._preset.vehicle_name) == "string" and data._preset.vehicle_name ~= "" then
        return data._preset.vehicle_name
      end
    end
  end

  local s = tostring(fallback or "Preset")
  s = s:gsub("%.json$", "")
  s = s:gsub("_", " ")

  return s
end

function VM3D_SavePresetForMountedVehicle()
  local ctx, reason = VM3D_GetMountedOwnedContext()

  if not ctx then
    local msg = "3D preset save failed: " .. tostring(reason)
    queueToast(msg)
    return false, msg
  end

  if not VM3D_EnsurePresetDir() then
    local msg = "3D preset save failed: could not create/read 3DPresets directory."
    queueToast(msg)
    print("[VehicleMileage] " .. msg)
    return false, msg
  end

	local path, base, displayName = VM3D_NextFreePresetPathFromName(ctx.name or ctx.label)
	local cfg = VM3D_SnapshotFromFacts()

	cfg.name = displayName

	cfg._preset = {
		preset_version = 1,
		vehicle_name = ctx.name,
		vehicle_label = ctx.label,
		saved_at = os.date("%Y-%m-%d %H:%M:%S"),
	}

	local ok = writeFile(path, json_encode(cfg, 2))

	if ok then
		local msg = "Saved 3D preset: " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg .. " -> " .. tostring(path))
    return true, msg
  end

  local msg = "3D preset save failed: could not write " .. tostring(path)
  queueToast(msg)
  print("[VehicleMileage] " .. msg)
  return false, msg
end

function VM3D_LoadPresetToFacts(presetName)
  local ctx, reason = VM3D_GetMountedOwnedContext()

  if not ctx then
    local msg = "3D preset load failed: " .. tostring(reason)
    queueToast(msg)
    return false, msg
  end

	local fileName = VM3D_PresetRefToFileName(presetName)
	local base = fileName:gsub("%.json$", "")
	local path = VM3D_PRESET_DIR .. "/" .. fileName
	local raw = readFile(path)

  if not raw or raw == "" then
    local msg = "3D preset load failed: missing preset " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg .. " -> " .. tostring(path))
    return false, msg
  end

  local decoded = json_decode(raw)

  if type(decoded) ~= "table" then
    local msg = "3D preset load failed: invalid JSON in " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg)
    return false, msg
  end

  local cfg = VM3D_SanitizeConfig(decoded.vm3d or decoded)

  if not cfg then
    local msg = "3D preset load failed: invalid 3D config in " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg)
    return false, msg
  end

  -- Live preview only.
  -- User must still press "Save vehicle" to persist it to vm_config_cars/bikes.json.
  VM3D_ApplyConfigToFacts(cfg)

  -- Prevent onUpdate from instantly restoring the old saved vehicle config.
  VM3D_LAST_LOADED_ID = ctx.id

  local msg = "Loaded 3D preset preview: " .. tostring(base)
  queueToast(msg)
  print("[VehicleMileage] " .. msg .. " for " .. tostring(ctx.label))

  return true, msg
end

function VM3D_DeletePreset(presetName)
  local name = VM3D_PresetNameFromValue(presetName)

  if name == "" then
    local msg = "Preset delete failed: no preset selected."
    queueToast(msg)
    return false, msg
  end

  local path, base = VM3D_PresetPathFromName(name)

  if not path or path == "" then
    local msg = "Preset delete failed: invalid preset name."
    queueToast(msg)
    return false, msg
  end

  local raw = readFile(path)
  if not raw or raw == "" then
    local msg = "Preset delete failed: file not found: " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg .. " -> " .. tostring(path))
    return false, msg
  end

  if not os or type(os.remove) ~= "function" then
    local msg = "Preset delete failed: os.remove is not available."
    queueToast(msg)
    print("[VehicleMileage] " .. msg)
    return false, msg
  end

  local ok, err = pcall(os.remove, path)

  if ok then
    local msg = "Deleted 3D preset: " .. tostring(base)
    queueToast(msg)
    print("[VehicleMileage] " .. msg .. " -> " .. tostring(path))
    return true, msg
  end

  local msg = "Preset delete failed: " .. tostring(err)
  queueToast(msg)
  print("[VehicleMileage] " .. msg)
  return false, msg
end

local function buildNSUI()
  if NS_BUILT then return end
  NS_BUILT = true  -- set immediately to prevent double-builds
  local ok, ns = pcall(GetMod, "nativeSettings")
  if not ok or not ns then return end-- end function buildNSUI
	
	  -- === Compat helpers (must be above FG controls) ===========================
  local function addRangeFloatCompat(path, title, desc, min, max, step, fmt, value, default, cb)
    -- Prefer the “fmt” signature (most reliable on recent NS builds)
    local ok, id = pcall(function()
      return GetMod("nativeSettings").addRangeFloat(path, title, desc, min, max, step, fmt or "%.3f", value, default, cb)
    end)
    if ok and id then return id end

    -- No-fmt signature
    ok, id = pcall(function()
      return GetMod("nativeSettings").addRangeFloat(path, title, desc, min, max, step, value, default, cb)
    end)
    if ok and id then return id end

    -- Very old signature (no default)
    ok, id = pcall(function()
      return GetMod("nativeSettings").addRangeFloat(path, title, desc, min, max, step, value, cb)
    end)
    if ok and id then return id end

    pcall(function()
      GetMod("nativeSettings").addText(path, "Native Settings incompatible", "Update Native Settings UI; sliders could not be created.")
    end)
    return nil
  end

  local function addRangeIntCompat(path, title, desc, min, max, step, value, default, cb)
    local ok, id = pcall(function()
      return ns.addRangeInt(path, title, desc, min, max, step, value, default, cb)
    end)
    if ok then return id end
    ok, id = pcall(function()
      return ns.addRangeInt(path, title, desc, min, max, step, value, cb)
    end)
    if ok then return id end
    pcall(function()
      ns.addText(path, "Native Settings incompatible", "Update NS UI; int sliders could not be created.")
    end)
    return nil
  end
  -- ==========================================================================

	
	  -- ---- FuelGauge controls (simple: always visible, build once) ------------
local function buildFuelGaugeControls()
  if FG_UI_BUILT then return end
  FG_UI_BUILT = true
  ns.addSubcategory(NS_SUB_WIDGET_FG, "Fuel Gauge Controls")

  -- signed clamp helper matching Leaderboard
  local function clampSigned7000(x)
    x = tonumber(x) or 0
    if     x < -7000 then x = -7000
    elseif x >  7000 then x =  7000 end
    return math.floor(x + 0.5)
  end

  -- safe getters (nil ⇒ defaults)
  local function fgGetEn() return (SETTINGS.fg_enabled ~= false) end  -- nil ⇒ true
  local function fgGetDx() return (type(SETTINGS.fg_dx_px) == "number") and SETTINGS.fg_dx_px or FG_DEF_DX end
  local function fgGetDy() return (type(SETTINGS.fg_dy_px) == "number") and SETTINGS.fg_dy_px or FG_DEF_DY end
  local function fgGetSc() return (type(SETTINGS.fg_scale)  == "number") and SETTINGS.fg_scale  or FG_DEF_SCALE end


  -- Toggle (master)
  local fgEnId = nil
  do
    local function onFgEnable(state)
      SETTINGS.fg_enabled = (state and true or false)
      saveSettings()
      local isFG = tostring(SETTINGS.widget_mode or "fuelgauge"):lower() == "fuelgauge"
      local fgOK = isFG and (SETTINGS.fg_enabled ~= false)
      _callUI("FG_EnableFuelGauge", fgOK)
      setFactInt("vm_fg_enabled", fgOK and 1 or 0)
    end
    local ok, id = pcall(GetMod("nativeSettings").addSwitch,
      NS_SUB_WIDGET_FG,
      "Fuel Gauge Enabled",
      "Master toggle. Only shows when Widget Mode = Fuel Gauge.",
      fgGetEn(), true, onFgEnable)
    if ok and id then fgEnId = id end
  end

  -- Temperature Meter (sub-toggle)
  do
    local function onTempEnable(state)
      SETTINGS.fg_temp_enabled = (state and true or false)
      saveSettings()
      -- push the fact now; onUpdate will still enforce stolen/owned gating
      setFactInt(FACT_FG_TEMP_VISIBLE, (SETTINGS.fg_temp_enabled ~= false) and 1 or 0)
    end
    local ok, _ = pcall(GetMod("nativeSettings").addSwitch,
      NS_SUB_WIDGET_FG,
      "Temperature Meter Enabled",
      "Show the oil temperature arc/marker on the FuelGauge.\nHidden automatically on non-owned (stolen/quest) vehicles.",
      (SETTINGS.fg_temp_enabled ~= false),  -- nil ⇒ true
      true,
      onTempEnable
    )
  end


  -- X offset  (−7000..7000)  (+X = RIGHT)
  local fgDxId = addRangeIntCompat(
    NS_SUB_WIDGET_FG, "Gauge X (px)",
    "−7000..7000. Positive = RIGHT, Negative = LEFT.",
    -7000, 7000, 10,
    fgGetDx(), FG_DEF_DX,
    function(v)
      v = clampSigned7000(v)
      SETTINGS.fg_dx_px = v; saveSettings()
      _callUI("FG_SetOffset", v, fgGetDy())
			-- NEW: keep per-save facts in lock-step
      setFactInt("vm_gauge_dx", v)
    end
  )

  -- Y offset  (−7000..7000)  (+Y = DOWN)
  local fgDyId = addRangeIntCompat(
    NS_SUB_WIDGET_FG, "Gauge Y (px)",
    "−7000..7000. Positive = DOWN, Negative = UP.",
    -7000, 7000, 10,
    fgGetDy(), FG_DEF_DY,
    function(v)
      v = clampSigned7000(v)
      SETTINGS.fg_dy_px = v; saveSettings()
      _callUI("FG_SetOffset", fgGetDx(), v)
			setFactInt("vm_gauge_dy", v)
    end
  )

  -- Scale  (0..7000)   600 = 1.00x
  local fgScId = addRangeIntCompat(
    NS_SUB_WIDGET_FG, "Gauge Scale (600 = 1.00x)",
    "0..7000. Baseline 600 = 1.00x. Default 330.",
    0, 7000, 10,
    fgGetSc(), FG_DEF_SCALE,
    function(v)
      v = math.max(0, math.min(7000, math.floor(tonumber(v) or 330)))
      SETTINGS.fg_scale = v; saveSettings()
      _callUI("FG_SetScale", v)
			setFactInt("vm_gauge_scale_milli", v) -- facts store milli directly
    end
  )

-- hook into “Restore Defaults”: mirror the Leaderboard behavior
	if GetMod("nativeSettings").registerRestoreDefaultsCallback then
		local nsMod = GetMod("nativeSettings")
		local cb = function()
			-- revert FG to first-run (no JSON keys)
			SETTINGS.fg_enabled = nil
			SETTINGS.fg_temp_enabled = nil
			SETTINGS.fg_dx_px   = nil
			SETTINGS.fg_dy_px   = nil
			SETTINGS.fg_scale   = nil
			saveSettings()

			-- apply runtime defaults (NO write) and update UI if possible
			local isFG = tostring(SETTINGS.widget_mode or "fuelgauge"):lower() == "fuelgauge"
			local fgOK = isFG and true
			_callUI("FG_EnableFuelGauge", fgOK)
			setFactInt("vm_fg_enabled", fgOK and 1 or 0)
			applyFuelGaugeTransforms(-1510, 275, 330)

			if type(nsMod.setOption) == "function" then
				pcall(nsMod.setOption, fgEnId, true)
				pcall(nsMod.setOption, fgDxId, -1510)
				pcall(nsMod.setOption, fgDyId,  275)
				pcall(nsMod.setOption, fgScId,  330)
			end
		end
		-- Try (path, immediate, cb) → (path, cb) → (cb)
  local ok = pcall(ns.registerRestoreDefaultsCallback, NS_TAB, false, cb)
  if not ok then ok = pcall(ns.registerRestoreDefaultsCallback, NS_TAB, cb) end
  if not ok then       pcall(ns.registerRestoreDefaultsCallback, cb) end
end

end


-- --- Compatibility helpers for selector + visibility ---
local function addSelectorCompat(path, title, desc, values, currentIndex, defaultIndex, cb)
  -- 1) Modern builds
  local ok, id = pcall(function()
    return ns.addSelectorString(path, title, desc, values, currentIndex, defaultIndex, cb)
  end)
  if ok and id then return id end

  -- 2) Older builds
  ok, id = pcall(function()
    return ns.addSelector(path, title, desc, values, currentIndex, cb)
  end)
  if ok and id then return id end

  -- 3) Rock-solid fallback: two actions (visible on every build)
  pcall(function() ns.addText(path, title, desc or "") end)
  for i, label in ipairs(values) do
    pcall(function()
      ns.addAction(path, ("Set: "..label), "", function() cb(i) end)
    end)
  end
  return nil
end -- end selectorcompat



ns.addTab(NS_TAB, "Odometer + Fuel")

-- Gas-station floating world markers.
-- World-map and minimap pins remain enabled.
ns.addSubcategory(NS_TAB .. "/Map Markers", "Map Markers")

do
  local okA = pcall(function()
    ns.addSwitch(
      NS_TAB .. "/Map Markers",
      "Show Gas Station World Markers",
      "Show floating gas-station icons in the 3D game world. World-map pins remain available.",
      SETTINGS.gas_pins_show_in_world ~= false,
      true,
      VM_SetGasPinsShowInWorld
    )
  end)

  if not okA then
    pcall(function()
      ns.addSwitch(
        NS_TAB .. "/Map Markers",
        "Show Gas Station World Markers",
        "Show floating gas-station icons in the 3D game world. World-map pins remain available.",
        SETTINGS.gas_pins_show_in_world ~= false,
        VM_SetGasPinsShowInWorld
      )
    end)
  end
end

ns.addSubcategory(NS_SUB_FUEL, "Fuel & Costs")

-- Base price (€/L) — snapped to 0.5 increments
local function snap05(x) return math.floor((tonumber(x) or 0) / 0.5 + 0.5) * 0.5 end
ns.addRangeFloat(
NS_SUB_FUEL, "Price per liter (base)",
"€$ per liter used as the center of dynamic pricing.",
0.00, 10000.00, 0.5, "%.1f",
snap05(SETTINGS.price_epl or DEFAULT_PRICE_EPL),
snap05(DEFAULT_PRICE_EPL),
function(v) v = snap05(v); applyFuelPrice(v, { persist_base = true }) end -- end function snap05
)

-- Dynamic hourly price toggle
local function onDynToggle(state)
  SETTINGS.price_dyn_enable = state and true or false
  saveSettings()
  local base = SETTINGS.price_epl or DEFAULT_PRICE_EPL
  if SETTINGS.price_dyn_enable then
    applyFuelPrice(nextDynamicPrice(base, base), { persist_base = false })
  else
    applyFuelPrice(base, { persist_base = false })
  end
pushPriceFact(true)
priceReassertTimer = 1.0
end

-- Fuel master switch (two common NS versions)
local function onFuelToggle(state)
  FUEL_ENABLED = state and true or false
  SETTINGS.fuel_enabled = FUEL_ENABLED
  saveSettings()
  if not FUEL_ENABLED then
    pcall(function()
    local player = Game.GetPlayer(); if not player then return end -- end function (anonymous)
  local veh = player:GetMountedVehicle(); if not veh then return end
  local id = select(1, vehKeyAndLabel(veh))
  local v = SAVE:ensureVehicle(id)
  v.stalled  = false
  v.limit_on = false
end)
end
end -- end function onFuelToggle

do
  local okA = pcall(function()
    ns.addSwitch(
    NS_SUB_FUEL,
    "Fuel system enabled",
    "Toggle the entire fuel system (consumption, stalling, limiter). Turning it off = cheating",
    (SETTINGS.fuel_enabled ~= false),
    true,
    onFuelToggle
    )
  end) -- end function (anonymous)
if not okA then
  pcall(function()
    ns.addSwitch(
    NS_SUB_FUEL,
    "Fuel system enabled",
    "Toggle the entire fuel system (consumption, stalling, limiter). Turning it off = cheating",
    (SETTINGS.fuel_enabled ~= false),
    onFuelToggle
    )
  end) -- end function (anonymous)
end
end

do
  local okA = pcall(function()
    ns.addSwitch(
    NS_SUB_FUEL,
    "Dynamic hourly price",
    "Every in-game hour, the fuel price moves randomly around your base (with realistic mean reversion).",
    (SETTINGS.price_dyn_enable ~= false),
    true,
    onDynToggle
    )
  end) -- end function (anonymous)
if not okA then
  pcall(function()
    ns.addSwitch(
    NS_SUB_FUEL,
    "Dynamic hourly price",
    "Every in-game hour, the fuel price moves randomly around your base (with realistic mean reversion).",
    SETTINGS.price_dyn_enable ~= false,
    onDynToggle
    )
  end) -- end function (anonymous)
end
end

-- Repair settings
ns.addSubcategory(NS_SUB_REPAIR, "Repair")

local repairAutomaticId = nil

do
  local function onRepairAutomaticToggle(state)
    SETTINGS.repair_automatic_enabled = state and true or false
    saveSettings()

    print("[VehicleMileage][Repair] Automatic repair process "
      .. (SETTINGS.repair_automatic_enabled and "enabled" or "disabled"))
  end

  local okA, idA = pcall(function()
    return ns.addSwitch(
      NS_SUB_REPAIR,
      "Automatic Repair Process",
      "Off (default): exit the vehicle manually, then wait 3 seconds.\n"
        .. "On: remain seated; after 5 seconds the bay dismounts, repairs, and remounts you.\n"
        .. "Changes apply on the next repair-bay entry.",
      SETTINGS.repair_automatic_enabled == true,
      false,
      onRepairAutomaticToggle
    )
  end)
  if okA and idA then
    repairAutomaticId = idA
  end

  if not okA then
    local okB, idB = pcall(function()
      return ns.addSwitch(
        NS_SUB_REPAIR,
        "Automatic Repair Process",
        "Off (default): exit the vehicle manually, then wait 3 seconds.\n"
          .. "On: remain seated; after 5 seconds the bay dismounts, repairs, and remounts you.\n"
          .. "Changes apply on the next repair-bay entry.",
        SETTINGS.repair_automatic_enabled == true,
        onRepairAutomaticToggle
      )
    end)
    if okB and idB then
      repairAutomaticId = idB
    end
  end
end

-- Repair price modifier
local repairAdjustId = nil

local function getRepairAdjustPct()
  return (type(SETTINGS.repair_price_adjust_pct) == "number")
    and SETTINGS.repair_price_adjust_pct
    or 0
end

repairAdjustId = addRangeIntCompat(
  NS_SUB_REPAIR,
  "Repair Price Modifier (%)",
  "Changes the final repair price globally.\nExample: -50 = half price, 0 = normal, +2000 = 21x price.",
  -100, 2000, 5,
  getRepairAdjustPct(), 0,
  function(v)
    v = tonumber(v) or 0
    if v < -100 then v = -100 elseif v > 2000 then v = 2000 end

    SETTINGS.repair_price_adjust_pct = math.floor(v + 0.5)
    saveSettings()

    print(("[VehicleMileage][Repair] Repair price modifier set to %+d%%")
      :format(SETTINGS.repair_price_adjust_pct))
  end
)

-- Persistent per-vehicle maintenance
ns.addSubcategory(NS_SUB_MAINTENANCE, "Vehicle Maintenance")

local maintenanceMinKmId = nil
local maintenanceMaxKmId = nil

do
  local okA = pcall(function()
    ns.addSwitch(
      NS_SUB_MAINTENANCE,
      "Vehicle maintenance enabled",
      "Require each owned vehicle to visit a repair bay using the distance range below. Overdue vehicles leak fuel.",
      SETTINGS.maintenance_enabled ~= false,
      true,
      VM_SetMaintenanceEnabled
    )
  end)

  if not okA then
    pcall(function()
      ns.addSwitch(
        NS_SUB_MAINTENANCE,
        "Vehicle maintenance enabled",
        "Require each owned vehicle to visit a repair bay using the distance range below. Overdue vehicles leak fuel.",
        SETTINGS.maintenance_enabled ~= false,
        VM_SetMaintenanceEnabled
      )
    end)
  end
end

local function maintenanceSliderKm(value, fallback)
  value = math.floor(tonumber(value) or fallback)
  return math.max(
    VM_MAINT_KM_SLIDER_MIN,
    math.min(VM_MAINT_KM_SLIDER_MAX, value)
  )
end

maintenanceMinKmId = addRangeIntCompat(
  NS_SUB_MAINTENANCE,
  "Minimum maintenance distance (km)",
  "Minimum distance before the next maintenance is due. Existing vehicle deadlines are preserved.",
  VM_MAINT_KM_SLIDER_MIN, VM_MAINT_KM_SLIDER_MAX, 1,
  maintenanceSliderKm(
    SETTINGS.maintenance_min_km,
    VM_MAINT_MIN_KM_DEFAULT
  ),
  VM_MAINT_MIN_KM_DEFAULT,
  function(value)
    local minKm = maintenanceSliderKm(value, VM_MAINT_MIN_KM_DEFAULT)
    SETTINGS.maintenance_min_km = minKm

    local maxKm = maintenanceSliderKm(
      SETTINGS.maintenance_max_km,
      VM_MAINT_MAX_KM_DEFAULT
    )
    if maxKm < minKm then
      SETTINGS.maintenance_max_km = minKm
      if type(ns.setOption) == "function" and maintenanceMaxKmId then
        pcall(ns.setOption, maintenanceMaxKmId, minKm)
      end
    end

    VM_ApplyMaintenanceIntervalSettings()
    saveSettings()
  end
)

maintenanceMaxKmId = addRangeIntCompat(
  NS_SUB_MAINTENANCE,
  "Maximum maintenance distance (km)",
  "Maximum distance before the next maintenance is due. Existing vehicle deadlines are preserved.",
  VM_MAINT_KM_SLIDER_MIN, VM_MAINT_KM_SLIDER_MAX, 1,
  maintenanceSliderKm(
    SETTINGS.maintenance_max_km,
    VM_MAINT_MAX_KM_DEFAULT
  ),
  VM_MAINT_MAX_KM_DEFAULT,
  function(value)
    local maxKm = maintenanceSliderKm(value, VM_MAINT_MAX_KM_DEFAULT)
    SETTINGS.maintenance_max_km = maxKm

    local minKm = maintenanceSliderKm(
      SETTINGS.maintenance_min_km,
      VM_MAINT_MIN_KM_DEFAULT
    )
    if minKm > maxKm then
      SETTINGS.maintenance_min_km = maxKm
      if type(ns.setOption) == "function" and maintenanceMinKmId then
        pcall(ns.setOption, maintenanceMinKmId, maxKm)
      end
    end

    VM_ApplyMaintenanceIntervalSettings()
    saveSettings()
  end
)

-- HUD Widget selector
ns.addSubcategory(NS_SUB_WIDGET, "HUD Widget")

local widgetValues = { "Legacy Digits", "Digital GaugeV1", "3D Widget" }

local currentIndex = 2
if SETTINGS.widget_mode == "vmhud" then
  currentIndex = 1
elseif SETTINGS.widget_mode == "3dwidget" then
  currentIndex = 3
end

local selWidgetId = addSelectorCompat(NS_SUB_WIDGET, "Active HUD Widget", "Choose the HUD", widgetValues, currentIndex, 2, function(index)
  if index == 1 then
    SETTINGS.widget_mode = "vmhud"
  elseif index == 3 then
    SETTINGS.widget_mode = "3dwidget"
  else
    SETTINGS.widget_mode = "fuelgauge"
  end

	saveSettings()
	applyWidgetModeRuntime(SETTINGS.widget_mode)

	-- When switching from Digital Gauge V1 to 3D Widget while already mounted,
	-- immediately load the current vehicle's 3D config.
	-- Otherwise the hidden facts can stay from the previous mode until the next update pass.
	if SETTINGS.widget_mode == "3dwidget" then
		VM3D_LoadForMountedVehicle(true)
	end
end)
buildFuelGaugeControls()

-- Shared theme selector
ns.addSubcategory(NS_TAB .. "/Theme", "Theme")

VM_THEME_SEL_ID = addSelectorCompat(
  NS_TAB .. "/Theme",
  "Fuel Gauge / Leaderboard Theme",
  "Shared color theme for the 2D Fuel Gauge and 2D Leaderboard.",
  VM_FG_THEME_VALUES,
  VM_ThemeIndexFromId(SETTINGS.fg_theme),
  1,
  function(index)
    local themeId = VM_ThemeIdFromIndex(index)
    SETTINGS.fg_theme = themeId
    saveSettings()
    applyThemeRuntime(themeId)
  end
)
-- ── HUD Auto-Hide (Legacy Digits + Fuel Gauge) ──────────────────────────────
ns.addSubcategory(NS_SUB_WIDGET_AUTOHIDE, "HUD Auto-Hide")

do
  local function ahGetEnabled()
    return SETTINGS.auto_hide_enabled == true
  end

  local function ahGetSeconds()
    local def = VMCONST.MISC.AUTO_HIDE_DEF_SECONDS or 20
    -- IMPORTANT:
    --  nil  -> use default
    --  0    -> keep 0 (instant hide mode)
    local raw = SETTINGS.auto_hide_seconds
    local v   = tonumber(raw)

    if v == nil then
      v = def
    end

    local minS = VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0
    local maxS = VMCONST.MISC.AUTO_HIDE_MAX_SECONDS or 120
    if v < minS then v = minS elseif v > maxS then v = maxS end
    return math.floor(v + 0.5)
  end

  local function ahGetFuelPct()
    local def = VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT or 25
    local v   = tonumber(SETTINGS.auto_hide_fuel_pct)
    if v == nil then v = def end
    if v < 0 then v = 0 elseif v > 100 then v = 100 end
    return math.floor(v + 0.5)
  end

  -- Enable Auto-Hide
  do
    local function onAutoHideToggle(state)
      SETTINGS.auto_hide_enabled = (state and true or false)
      saveSettings()
      autoHideTimer   = 0.0
      autoHideLatched = false

      -- Turning OFF: immediately restore HUD if we’re in a vehicle
      if not state then
        local player = Game.GetPlayer()
        if player then
          local veh = player:GetMountedVehicle()
          if veh then
            setFactInt(FACT_HUD_VISIBLE, 1)
            lastHUDVisible = 1
            -- treat as "already past entry delay"
            hudAcc = VMCONST.MISC.HUD_DELAY_SECONDS
          end
        end
      end
    end


    local okA = pcall(function()
      ns.addSwitch(
        NS_SUB_WIDGET_AUTOHIDE,
        "Enable Auto-Hide",
        "Shows the HUD on vehicle entry, then hides it after the delay while fuel is above the low-fuel threshold.",
        ahGetEnabled(),
        true,
        onAutoHideToggle
      )
    end)
    if not okA then
      pcall(function()
        ns.addSwitch(
          NS_SUB_WIDGET_AUTOHIDE,
          "Enable Auto-Hide",
          "Shows the HUD on vehicle entry, then hides it after the delay while fuel is above the low-fuel threshold.",
          ahGetEnabled(),
          onAutoHideToggle
        )
      end)
    end
  end

  -- Delay (seconds)
  addRangeIntCompat(
    NS_SUB_WIDGET_AUTOHIDE, "Auto-Hide Delay (sec)",
    "Seconds the HUD stays visible after entering a vehicle.\nOnly used while fuel is above the low-fuel threshold.",
    math.floor(VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0),
    math.floor(VMCONST.MISC.AUTO_HIDE_MAX_SECONDS or 120),
    1,
    ahGetSeconds(),
    math.floor(VMCONST.MISC.AUTO_HIDE_DEF_SECONDS or 20),
    function(v)
      local minS = VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0
      local maxS = VMCONST.MISC.AUTO_HIDE_MAX_SECONDS or 120
      v = tonumber(v) or (VMCONST.MISC.AUTO_HIDE_DEF_SECONDS or 20)
      if v < minS then v = minS elseif v > maxS then v = maxS end
      SETTINGS.auto_hide_seconds = v
      saveSettings()
    end
  )

  -- Low fuel threshold
  addRangeIntCompat(
    NS_SUB_WIDGET_AUTOHIDE, "Low Fuel Threshold (%)",
    "When fuel is at or below this value, the HUD stays visible permanently.\nSet to 0% to disable this behaviour.",
    0, 100, 1,
    ahGetFuelPct(),
    math.floor(VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT or 25),
    function(v)
      v = tonumber(v) or (VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT or 25)
      if v < 0 then v = 0 elseif v > 100 then v = 100 end
      SETTINGS.auto_hide_fuel_pct = v
      saveSettings()
    end
  )
end





-- HUD position (global)
ns.addSubcategory(NS_SUB_HUD_POS, "HUD (Legacy Digits) Position (Global)")
local defX, defY = 280.0/3840.0, 443.0/2160.0

local function safeGetX()
local okX, v = pcall(function() return Game.GetUISystem():VM_GetHUDPosX() end) -- end function safeGetX
return (okX and type(v) == "number") and v or (tonumber(SETTINGS.hud_x) or defX)
end -- end function (anonymous)
local function safeGetY()
local okY, v = pcall(function() return Game.GetUISystem():VM_GetHUDPosY() end) -- end function safeGetY
return (okY and type(v) == "number") and v or (tonumber(SETTINGS.hud_y) or defY)
end -- end function (anonymous)
local function setX(v)
  v = tonumber(v) or defX
  pcall(function()
    local ui = Game.GetUISystem()
    ui:VM_SetHUDPosX(v)
  if ui and ui.vmHUD then ui.vmHUD:Refresh() end -- end function (anonymous)
end)
SETTINGS.hud_x = v; saveSettings()
end -- end function setX
local function setY(v)
  v = tonumber(v) or defY
  pcall(function()
    local ui = Game.GetUISystem()
    ui:VM_SetHUDPosY(v)
  if ui and ui.vmHUD then ui.vmHUD:Refresh() end -- end function (anonymous)
end)
SETTINGS.hud_y = v; saveSettings()
end -- end function setY


local optX = addRangeFloatCompat(NS_SUB_HUD_POS, "X (Left → Right)", "Normalized horizontal position (0.000–1.000).",
0.0, 1.0, 0.001, "%.3f", safeGetX(), defX, function(v) setX(v) end) -- end function onDynToggle
local optY = addRangeFloatCompat(NS_SUB_HUD_POS, "Y (Bottom ↑ Top)", "Normalized vertical position (0.000–1.000).",
0.0, 1.0, 0.001, "%.3f", safeGetY(), defY, function(v) setY(v) end) -- end function (anonymous)






-- Price plate (global offsets)
ns.addSubcategory(NS_SUB_PLATE, "Price Sign (Global)")
local function safeGetDx()
local okDx, v = pcall(function() return Game.GetUISystem():VM_GetPriceDx() end) -- end function safeGetDx
if okDx and type(v) == "number" then return v end -- end function (anonymous)
return (type(SETTINGS.price_dx_px) == "number") and SETTINGS.price_dx_px or 0.0
end
local function safeGetDy()
local okDy, v = pcall(function() return Game.GetUISystem():VM_GetPriceDy() end) -- end function safeGetDy
if okDy and type(v) == "number" then return v end -- end function (anonymous)
return (type(SETTINGS.price_dy_px) == "number") and SETTINGS.price_dy_px or 350.0
end
local function setDx(v)
  v = math.floor(tonumber(v) or 0)
  pcall(function()
    local ui = Game.GetUISystem()
    ui:VM_SetPriceDx(v)
  if ui and ui.vmHUD then ui.vmHUD:Refresh() end -- end function (anonymous)
end)
SETTINGS.price_dx_px = v; saveSettings()
end -- end function setDx
local function setDy(v)
  v = math.floor(tonumber(v) or 0)
  pcall(function()
    local ui = Game.GetUISystem()
    ui:VM_SetPriceDy(v)
  if ui and ui.vmHUD then ui.vmHUD:Refresh() end -- end function (anonymous)
end)
SETTINGS.price_dy_px = v; saveSettings()
end -- end function setDy

local optDx = addRangeFloatCompat(NS_SUB_PLATE, "Plate X offset (px)", "Positive moves LEFT; negative moves RIGHT.",
-7000.0, 7000.0, 1.0, "%.0f", safeGetDx(), 0.0, function(v) setDx(v) end) -- end function (anonymous)
local optDy = addRangeFloatCompat(NS_SUB_PLATE, "Plate Y offset (px)", "Positive moves UP; negative moves DOWN.",
-7000.0, 7000.0, 1.0, "%.0f", safeGetDy(), 350.0, function(v) setDy(v) end) -- end function (anonymous)

-- ────────────────────────────────────────────────────────────────────────────
-- Leaderboard Controls (0..7000 wide-screen support)
-- ────────────────────────────────────────────────────────────────────────────
ns.addSubcategory(NS_SUB_LB, "2D Leaderboard Controls")

-- capture option IDs so restore-defaults can update UI visually (if available)
local lbEnId, lbDxId, lbDyId, lbScId = nil, nil, nil, nil

local function clampSigned7000(x)
  x = tonumber(x) or 0
  if x < -7000 then x = -7000 elseif x > 7000 then x = 7000 end
  return math.floor(x + 0.5)
end


local function safeLBGetDx() return (type(SETTINGS.lb_dx_px) == "number") and SETTINGS.lb_dx_px or LB_DEF_DX end
local function safeLBGetDy() return (type(SETTINGS.lb_dy_px) == "number") and SETTINGS.lb_dy_px or LB_DEF_DY end
local function safeLBGetSc() return (type(SETTINGS.lb_scale) == "number") and SETTINGS.lb_scale or LB_DEF_SCALE end
local function safeLBGetEn() return (SETTINGS.lb_enabled ~= false) end  -- nil => enabled

-- Toggle
do
  local function onLBEnable(state)
    SETTINGS.lb_enabled = (state and true or false)
    saveSettings()
    _callUI("VM_LB_SetEnabled", SETTINGS.lb_enabled)
  end

  local okA, retA = pcall(function()
    return ns.addSwitch(NS_SUB_LB,
      "Leaderboard Enabled",
      "Master toggle (still gated by the Price Plate visibility).",
      safeLBGetEn(), true, onLBEnable)
  end)
  if okA and retA then lbEnId = retA end
end

-- X offset (0..7000) – larger moves further LEFT (VMHUD applies negative translation internally)
lbDxId = addRangeIntCompat(
  NS_SUB_LB, "Leaderboard X (px)",
  "-7000..7000. Positive = LEFT, Negative = RIGHT (relative to the Price Plate).",
  -7000, 7000, 10,
  safeLBGetDx(), LB_DEF_DX,
  function(v)
    v = clampSigned7000(v)
    SETTINGS.lb_dx_px = v; saveSettings()
    _callUI("VM_LB_SetOffset", v, safeLBGetDy())
  end
)

-- Y offset (0..7000) – larger moves further UP
lbDyId = addRangeIntCompat(
  NS_SUB_LB, "Leaderboard Y (px)",
  "-7000..7000. Positive = UP, Negative = DOWN (relative to the Price Plate).",
  -7000, 7000, 10,
  safeLBGetDy(), LB_DEF_DY,
  function(v)
    v = clampSigned7000(v)
    SETTINGS.lb_dy_px = v; saveSettings()
    _callUI("VM_LB_SetOffset", safeLBGetDx(), v)
  end
)

-- Scale (0..7000) where 600 = 1.00x
lbScId = addRangeIntCompat(
  NS_SUB_LB, "Leaderboard Scale (600 = 1.00x)",
  "0..7000. 600 = 1.00x. Default is 480 (0.80x) to match VMHUD.",
  0, 7000, 10,
  safeLBGetSc(), LB_DEF_SCALE,
  function(v)
    v = math.max(0, math.min(7000, math.floor(tonumber(v) or LB_DEF_SCALE)))
    SETTINGS.lb_scale = v; saveSettings()
    _callUI("VM_LB_SetScale", v)
  end
)





-- Restore Defaults: HUD pos + price plate + FuelGauge transforms
if ns.registerRestoreDefaultsCallback then
  ns.registerRestoreDefaultsCallback(NS_TAB, false, function()
    local ui = Game.GetUISystem()

    -- Maintenance defaults.
    SETTINGS.maintenance_enabled = true
    SETTINGS.maintenance_min_km = VM_MAINT_MIN_KM_DEFAULT
    SETTINGS.maintenance_max_km = VM_MAINT_MAX_KM_DEFAULT
    if VM_MAINTENANCE and VM_MAINTENANCE.setEnabled then
      VM_MAINTENANCE.setEnabled(true)
    end
    VM_ApplyMaintenanceIntervalSettings()
    if type(ns.setOption) == "function" then
      if maintenanceMinKmId then
        pcall(ns.setOption, maintenanceMinKmId, VM_MAINT_MIN_KM_DEFAULT)
      end
      if maintenanceMaxKmId then
        pcall(ns.setOption, maintenanceMaxKmId, VM_MAINT_MAX_KM_DEFAULT)
      end
    end

    -- Repair method default: manual exit.
    SETTINGS.repair_automatic_enabled = false
    if type(ns.setOption) == "function" and repairAutomaticId then
      pcall(ns.setOption, repairAutomaticId, false)
    end

    -- Legacy VMHUD position
    SETTINGS.hud_x, SETTINGS.hud_y = defX, defY
    saveSettings()
    if ui and ui.VM_ResetHUDPos then ui:VM_ResetHUDPos() end
    if type(ns.setOption) == "function" then
      if optX then pcall(ns.setOption, optX, defX) end
      if optY then pcall(ns.setOption, optY, defY) end
    end
    if ui and ui.vmHUD then ui.vmHUD:Refresh() end

    -- Price plate offsets
    SETTINGS.price_dx_px, SETTINGS.price_dy_px = 0.0, 350.0
    saveSettings()
    if ui and ui.VM_SetPriceDx then ui:VM_SetPriceDx(0.0) end
    if ui and ui.VM_SetPriceDy then ui:VM_SetPriceDy(350.0) end
    if type(ns.setOption) == "function" then
      if optDx then pcall(ns.setOption, optDx, 0.0) end
      if optDy then pcall(ns.setOption, optDy, 350.0) end
    end

		-- FuelGauge defaults
		SETTINGS.fg_dx_px = FG_DEF_DX
		SETTINGS.fg_dy_px = FG_DEF_DY
		SETTINGS.fg_scale = FG_DEF_SCALE
		SETTINGS.widget_mode = "fuelgauge"
		SETTINGS.fg_theme = 0
		saveSettings()
		applyFuelGaugeTransforms(FG_DEF_DX, FG_DEF_DY, FG_DEF_SCALE)
		
		-- NEW: keep per-save facts equal to defaults
    setFactInt("vm_gauge_dx",           FG_DEF_DX)
    setFactInt("vm_gauge_dy",           FG_DEF_DY)
    setFactInt("vm_gauge_scale_milli",  FG_DEF_SCALE)

		if type(ns.setOption) == "function" then
			if fgDxId then pcall(ns.setOption, fgDxId, FG_DEF_DX) end
			if fgDyId then pcall(ns.setOption, fgDyId, FG_DEF_DY) end
			if fgScId then pcall(ns.setOption, fgScId, FG_DEF_SCALE) end
			if VM_THEME_SEL_ID then pcall(ns.setOption, VM_THEME_SEL_ID, 1) end
		end


	    -- Leaderboard defaults (revert to “first-run” behavior and apply runtime)
    SETTINGS.lb_enabled = nil         -- nil => enabled by default
    SETTINGS.lb_dx_px   = nil         -- not written to JSON until user changes
    SETTINGS.lb_dy_px   = nil
    SETTINGS.lb_scale   = nil
    saveSettings()

    -- Apply runtime defaults without creating JSON keys
    _callUI("VM_LB_SetEnabled", true)
    _callUI("VM_LB_SetOffset", LB_DEF_DX, LB_DEF_DY)
    _callUI("VM_LB_SetScale",  LB_DEF_SCALE)

    -- Update NS UI controls visually if supported
    if type(ns.setOption) == "function" then
      if lbEnId then pcall(ns.setOption, lbEnId, true) end
      if lbDxId then pcall(ns.setOption, lbDxId, LB_DEF_DX) end
      if lbDyId then pcall(ns.setOption, lbDyId, LB_DEF_DY) end
      if lbScId then pcall(ns.setOption, lbScId, LB_DEF_SCALE) end
    end

		-- Auto-Hide: revert to first-run (disabled, defaults)
    SETTINGS.auto_hide_enabled  = nil
    SETTINGS.auto_hide_seconds  = nil
    SETTINGS.auto_hide_fuel_pct = nil

    -- Gas-station world markers default to visible.
    SETTINGS.gas_pins_show_in_world = true
    VM_ApplyGasPinsShowInWorld(true)

    saveSettings()
    autoHideTimer = 0.0
  end)
end


-- Ignore vehicles (actions)
pcall(function() ns.addSubcategory(NS_SUB_IGNORE, "Ignore Vehicles") end) -- end function (anonymous)
addMomentarySwitch(ns, NS_SUB_IGNORE, "Ignore current vehicle",
"Adds the currently mounted vehicle to vm_vehicle_ignore.json.\nNo ODO/fuel logic will run for ignored vehicles.",
ignoreCurrentVehicle)
addMomentarySwitch(ns, NS_SUB_IGNORE, "Unignore current vehicle",
"Removes the currently mounted vehicle from vm_vehicle_ignore.json.",
unignoreCurrentVehicle)
end -- end function (anonymous)

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 0-Engine mount / unmount handlers                                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- Called by 0-Engine when the player mounts a vehicle.
-- Resets all per-vehicle caches so onUpdate can use the fast cached paths
-- from the very first frame, and ensures a fresh HUD state for the new vehicle.
local function onVehicleMount(veh)
  if not veh then return end
  vm.isMounted = true
  VM_WEATHER_CONDITION.Refresh()
  -- Fresh mount must never reuse previous position/id.
  lastPos = nil
  lastVehId = nil

  local id, label = vehKeyAndLabel(veh)

  -- Reset HUD fact caches for the new vehicle
  lastHUDVisible, lastMetersPushed, lastFuelPermillePushed = -1, -1, -1
  lastSpeedPushed  = -1
  factAcc          = 0.0
  hudAcc           = 0.0
  autoHideTimer    = 0.0
  autoHideLatched  = false

  -- Invalidate per-vehicle frame caches
  lastIsBike       = nil
  lastSpec         = nil
  lastVehData      = nil
  isIgnoredCache   = nil
  lastAutoIgnoreId = nil

  -- Force 3D config reload on this mount.
  -- Important when user changed 3D setup without pressing Save.
  VM3D_LAST_LOADED_ID = nil

  -- If 3D Widget mode is active, re-enable the 3D widget after being on foot.
  if VM3D_IsActiveMode and VM3D_IsActiveMode() then
    VM_SetFactIntCached("vm_3d_enabled", 1)
  end

  -- Ensure spec entry exists (noop if already present)
  local isBike = looksLikeBike(label)
  ensureSpecForLabel(label, isBike)
end

-- Called by 0-Engine when the player unmounts (or session ends / vehicle destroyed).
-- Clears the isMounted flag so subsequent onUpdate frames exit early,
-- and resets all HUD facts to their hidden/default state.
local function onVehicleUnmount()
  vm.isMounted = false
  VM_WEATHER_CONDITION.temperatureC = nil
	vmMountFallbackWarned = false

  -- Force-stop any active refueling session
  _forceStopRefuel()

  if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
    VM_MAINTENANCE.resetMounted()
  end

  -- 3D widget is vehicle-bound.
  -- Disable it while on foot for performance / clean state.
  VM3D_LAST_LOADED_ID = nil
  VM_SetFactIntCached("vm_3d_enabled", 0)
  VM3D_SetHiddenFacts(true, true, true, true)

  -- Clear HUD facts
  setFactInt(FACT_HUD_VISIBLE, 0)
  setFactInt(FACT_FG_TEMP_VISIBLE, 0)
  lastHUDVisible  = 0
  lastTempVisible = 0

  if lastVehCondPctPushed ~= -1 then
    setFactInt(FACT_HUD_VEH_COND_PCT, -1)
    lastVehCondPctPushed = -1
  end

  lastPos, lastVehId  = nil, nil
  isIgnoredCache      = nil
  lastIsBike          = nil
  lastSpec            = nil
  lastVehData         = nil
  wasOwned, hudAcc    = false, 0.0
  autoHideTimer       = 0.0
  autoHideLatched     = false
  LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph, LIVE.mode = 0, 1, 0, 0, "stop"
  -- Restart the self-stopping oil cooldown interval
  if _startOilCooldown then _startOilCooldown() end
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Init + observers                                                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

registerForEvent("onInit", function()
  -- 0-Engine integration (safe: nil-guarded so mod still works without額 ㄓㄒˋ it)
  Engine = GetMod("0-Engine")
  if Engine then
    Mod = Engine.Register("VehicleMileage")
  else
    print("[VehicleMileage] WARNING: 0-Engine not found — running without event optimizations")
  end

  if Mod then
    -- Subscribe to 0-Engine vehicle + session events
    Mod.Subscribe("VehicleMount",   onVehicleMount)
    Mod.Subscribe("VehicleUnmount", onVehicleUnmount)

    -- MenuClose: process a consumed gascan and flush its queued toast.
    Mod.Subscribe("MenuClose", function()
        VM_GASCAN.OnMenuClose()

        if PENDING_TOAST and PENDING_TOAST ~= "" and _canEmit() then
            _showRed(PENDING_TOAST)
            lastToastAt = os.clock()
            PENDING_TOAST = nil
        end
    end)
  end
  VM_FACT_CACHE = {}
  
  setFactInt(FACT_HUD_VISIBLE, 0)
		setFactInt(FACT_HUD_METERS, 0)
		setFactInt(FACT_HUD_FUEL_PERMILLE, 0)
		setFactInt(FACT_HUD_SPEED_KMH, 0)
		setFactInt(FACT_HUD_OIL_TEMP_C, -1)
  math.randomseed(os.time())

  -- reset HUD fact caches
  lastHUDVisible, lastMetersPushed, lastFuelPermillePushed = -1, -1, -1
  factAcc = 0.0
  factPushInterval = FACT_PUSH_INTERVAL_BASE
	autoHideTimer   = 0.0
  autoHideLatched = false

	-- settings + ignore list
	loadSettings()
	applyThemeRuntime(SETTINGS.fg_theme)

	STOLEN_STALL_AT_ZERO = (SETTINGS.stolen_stall_at_zero ~= false)
	FUEL_ENABLED         = (SETTINGS.fuel_enabled ~= false)

  IGNORE.setup({ path = "vm_vehicle_ignore.json" })
  pcall(mergeSeedsIntoIgnore)

  -- seed price plate offsets
  do
    local ui = Game.GetUISystem()
    if ui and ui.VM_SetPriceDx then
      ui:VM_SetPriceDx(tonumber(SETTINGS.price_dx_px) or 0.0)
      ui:VM_SetPriceDy(tonumber(SETTINGS.price_dy_px) or 350.0)
    end
end


-- Apply the selected HUD widget and its transforms at startup (robust)
forceAllWidgetsOff()  -- start from a known state to avoid "both on"
applyWidgetModeRuntime(SETTINGS.widget_mode)
-- Leaderboard runtime apply (honor JSON if present; otherwise defaults; NO write)
_callUI("VM_LB_SetEnabled", (SETTINGS.lb_enabled ~= false))
_callUI("VM_LB_SetOffset", tonumber(SETTINGS.lb_dx_px) or LB_DEF_DX,
                              tonumber(SETTINGS.lb_dy_px) or LB_DEF_DY)
_callUI("VM_LB_SetScale",  tonumber(SETTINGS.lb_scale)  or LB_DEF_SCALE)
-- 3D World runtime apply.
-- This reads vm_settings.json -> SETTINGS.world3d.
-- It does not write anything.
VMWorld_ResetDraftFromSettings()
VMWorld_ApplyAll()
-- Reassert longer; some rigs build UI late
_wm_reassert_left, _wm_reassert_acc, _wm_reassert_period = 8.0, 0.0, 0.25

if SETTINGS.widget_mode == "fuelgauge" then
  applyFuelGaugeTransforms(SETTINGS.fg_dx_px, SETTINGS.fg_dy_px, SETTINGS.fg_scale)
else
  applyLegacyHUDTransforms()
end


-- seed vehicle condition
setFactInt(FACT_HUD_VEH_COND_PCT, -1)


-- seed HUD position (normalized)
local defX, defY = 280.0/3840.0, 443.0/2160.0
local ui = Game.GetUISystem()
if ui and ui.VM_SetHUDPosX then
  ui:VM_SetHUDPosX(tonumber(SETTINGS.hud_x) or defX)
  ui:VM_SetHUDPosY(tonumber(SETTINGS.hud_y) or defY)
end

-- seed price once
currentPrice = SETTINGS.price_epl or DEFAULT_PRICE_EPL
pushPriceFact(true)
setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
setFactInt(FACT_HUD_PRICE_CENTS, math.floor(((tonumber(currentPrice) or DEFAULT_PRICE_EPL) * 100) + 0.5))

-- seed temp-meter visibility from settings + widget-mode (no vehicle yet, just the user's choice)
do
  local isFG   = tostring(SETTINGS.widget_mode or "fuelgauge"):lower() == "fuelgauge"
  local fgOK   = (SETTINGS.fg_enabled       ~= false)
  local tempOK = (SETTINGS.fg_temp_enabled  ~= false)  -- nil ⇒ true
  local seed   = (isFG and fgOK and tempOK) and 1 or 0
  setFactInt(FACT_FG_TEMP_VISIBLE, seed)
  lastTempVisible = seed  -- NEW
end


-- save system
SAVE.setup({
  cars_cfg_path  = CAR_SPECS_PATH,
  bikes_cfg_path = BIKE_SPECS_PATH,
})


VM_GASCAN.setup({
  pending_fact           = "elm_chooh2_gascan_pending",
  item_id                = "Items.chooh2_gascan",
  liters_per_item        = 10.0,
  sound_event            = "gascan_refuel",
  save                   = SAVE,
  queueToast             = queueToast,
  vehKeyAndLabel         = vehKeyAndLabel,
  getSpecs               = specsFor,
  isOwnedViaUnlockedList = isOwnedViaUnlockedList,
  isIgnored              = ignoreIs,
  setFactInt             = setFactInt,
  hud_fuel_fact          = FACT_HUD_FUEL_PERMILLE,
})

VM_MAINTENANCE.setup({
  enabled              = SETTINGS.maintenance_enabled ~= false,
  min_interval_m       = (
    tonumber(SETTINGS.maintenance_min_km) or VM_MAINT_MIN_KM_DEFAULT
  ) * 1000,
  max_interval_m       = (
    tonumber(SETTINGS.maintenance_max_km) or VM_MAINT_MAX_KM_DEFAULT
  ) * 1000,
  reward_chance        = 0.25,
  reward_count         = 1,
  reward_item_id       = "Items.chooh2_gascan",
  critical_condition_pct = 20.0,
  heat_warm_c          = 34.0,
  heat_extreme_c       = 37.0,
  heat_warm_multiplier = 1.5,
  heat_extreme_multiplier = 2.0,
  decompression_fact   = "vm_maintenance_decompression_event",
  force_due_fact       = "vm_maintenance_force_due_cmd",
  fx_mode_fact         = "vm_maintenance_fx_mode",
  save                 = SAVE,
  queueToast           = queueToast,
  setHudFuelPermille   = function(permille)
    setFactInt(FACT_HUD_FUEL_PERMILLE, permille)
    lastFuelPermillePushed = permille
  end,
  debug                = false,
})

-- Clean up old vm_session/*.lua files left over from pre-v4 save model
SAVE:pruneSessionFiles()


reloadSpecFiles()

-- gas module
local GAS_OPTS = {
points_path          = "vm_gas_locations.json",
radius               = 5.0,
cluster_radius       = 35.0,
refill_per_sec       = VMCONST.REFILL.RATE_FAST,
sound_event          = "refuel",
sound_stop_event     = nil,
owner_only           = VMCONST.TRACK.OWNER_ONLY,
enable_cost          = true,
unit_price_per_liter = currentPrice,
full_stop_on_100     = true,
full_hysteresis      = 0.999,
full_resume_below    = 0.985,
debug                = false,
}
GAS_OPTS_REF = GAS_OPTS
GAS.setup(GAS_OPTS)
VM_GAS_ECONOMY.setup({ gas = GAS })

-- repair station module
local REPAIR_OPTS = {
  points_path   = REPAIR_POINTS_PATH,
  radius        = 5.0,
  debug         = false,
  wait_seconds  = 3.0,
  automatic_wait_seconds = 5.0,

  -- Used only for old repair-zone records without "price"
  default_repair_price = 500,

  isAutomaticRepairEnabled = function()
    return SETTINGS.repair_automatic_enabled == true
  end,

  getRepairPriceAdjustPct = function()
    return tonumber(SETTINGS.repair_price_adjust_pct) or 0
  end,

  onRepairCompleted = function(vehicleID, vehicleLabel, conditionPct)
    if VM_MAINTENANCE and VM_MAINTENANCE.completeService then
      VM_MAINTENANCE.completeService(vehicleID, vehicleLabel, conditionPct)
    end
  end,

  -- Read condition while still mounted.
  -- Important: vm_hud_vehicle_cond_pct becomes -1 after exit,
  -- so vm_repair_stations.lua stores the calculated price when repair is armed.
  getVehicleConditionPct = function(veh)
    local pct = vehicleCondPct(veh)

    if pct ~= nil then
      return pct
    end

    return VM_GetFactInt(FACT_HUD_VEH_COND_PCT, -1)
  end,

  -- let the module use your existing toast + vehicle helpers
  queueToast = queueToast,

  vehKeyAndLabel = vehKeyAndLabel,

	vehicleTypeForLabel = function(label)
		return looksLikeBike(label) and "Bike" or "Car"
	end,

	isVehicleOwned = function(veh, label)
		local okOwned, owned = pcall(function()
			return veh:IsPlayerVehicle()
		end)

		if okOwned and owned then
			return true
		end

		-- fallback for DAV / garage vehicles where IsPlayerVehicle can be unreliable
		return isOwnedViaUnlockedList(label)
	end,
}
REPAIR_OPTS_REF = REPAIR_OPTS
REPAIR.setup(REPAIR_OPTS)

-- Map markers setup
local ok_MARKERS, MARKERS = pcall(require, "vm_gas_markers")
if not ok_MARKERS or type(MARKERS) ~= "table" then
  print("[VehicleOdometer] ERROR loading vm_gas_markers.lua: " .. tostring(MARKERS))
else
  MARKERS.setup({
    points_path         = POINTS_PATH,   -- same file as GAS
    cluster_radius      = 35.0,
    clampToGround       = true,
    visibleThroughWalls = true,
    showInWorld         = SETTINGS.gas_pins_show_in_world ~= false,
    trace               = false,

    -- tooltip text (title, desc) per pin:
    caption = function(pos, idx)
      local title = ("CHOOH2 PUMP #%d"):format(idx)
      return title, "Pay & Refuel"
    end,
  })
end


buildNSUI()

if REGISTER_REFUEL_HOTKEY and type(registerHotkey) == "function" then
  registerHotkey("VM_Refuel", "VehicleOdometer: Refuel", function()
  local player = Game.GetPlayer(); if not player then return end -- end function (anonymous)
local veh = player:GetMountedVehicle(); if not veh then return end
local id = select(1, vehKeyAndLabel(veh))
local v = SAVE:ensureVehicle(id)
v.fuel_pct = 1.0
v.stalled = false
v.limit_on = false
SAVE.dirty = true

--if SAVE and SAVE.syncVehicle then
--  SAVE:syncVehicle(id, true)
--end

setFactInt(FACT_HUD_FUEL_PERMILLE, 1000)
end)
end

if type(Observe) == "function" then
  Observe('gameuiInGameMenuGameController', 'OnSavingComplete', function(_, success)
    SAVE:onSavingComplete(success)
  end) -- end function (anonymous)
end

-- 0-Engine already owns the game-session lifecycle. Use its public PlayerReady /
-- PlayerInvalidated API instead of loading a second private GameUI.lua copy.
local vmSessionActive = false

local function VM_OnSessionStart(player)
  if vmSessionActive then
    return
  end

  player = player or (Mod and Mod.GetPlayer and Mod.GetPlayer()) or Game.GetPlayer()
  if not player then
    return
  end

  if player.IsReplacer and player:IsReplacer() then
    return
  end

  vmSessionActive = true
  VM_WEATHER_CONDITION.Refresh()
  VM_FACT_CACHE = {}

  lastHUDVisible, lastMetersPushed, lastFuelPermillePushed = -1, -1, -1
  factAcc = 0.0
  factPushInterval = FACT_PUSH_INTERVAL_BASE

  lastPos, lastVehId = nil, nil
  wasOwned, hudAcc   = false, 0.0
  autoHideTimer      = 0.0
  autoHideLatched    = false

  -- Invalidate 0-Engine per-vehicle caches from the previous session.
  vm.isMounted       = false
  vmMountFallbackWarned = false
  lastIsBike         = nil
  lastSpec           = nil
  lastVehData        = nil
  isIgnoredCache     = nil
  lastAutoIgnoreId   = nil
  lastSpeedPushed    = -1

  pcall(function() if MARKERS and MARKERS.refresh then MARKERS.refresh(true) end end)
  setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
  priceVisibleLast = false

		-- This is the first point where vehicle save facts may be read or initialized.
		SAVE:onSessionStart()
		VM_GASCAN.OnSessionStart()

		-- Give ourselves a few seconds to re-attach if timing is weird on some rigs.
  _vm_attachWatchLeft = 8.0
  _vm_attachCooldown  = 0.0
  loadSettings()
  VM_ApplyMaintenanceIntervalSettings()
  if VM_MAINTENANCE and VM_MAINTENANCE.onSessionStart then
    VM_MAINTENANCE.onSessionStart(SETTINGS.maintenance_enabled ~= false)
  end
  VM_ApplyGasPinsShowInWorld(true)
  applyThemeRuntime(SETTINGS.fg_theme)

  forceAllWidgetsOff()
  applyWidgetModeRuntime(SETTINGS.widget_mode)
  applyFuelGaugeTransforms(SETTINGS.fg_dx_px, SETTINGS.fg_dy_px, SETTINGS.fg_scale)

  -- Re-apply Leaderboard at session start, like the other widgets.
  _callUI("VM_LB_SetEnabled", (SETTINGS.lb_enabled ~= false))
  _callUI("VM_LB_SetOffset", tonumber(SETTINGS.lb_dx_px) or LB_DEF_DX,
                                tonumber(SETTINGS.lb_dy_px) or LB_DEF_DY)
  _callUI("VM_LB_SetScale",  tonumber(SETTINGS.lb_scale)  or LB_DEF_SCALE)

  -- Re-apply global 3D World config at session start.
  VMWorld_ResetDraftFromSettings()
  VMWorld_ApplyAll()

  _wm_reassert_left   = 8.0
  _wm_reassert_acc    = 0.0
  _wm_reassert_period = 0.25

  STOLEN_STALL_AT_ZERO = (SETTINGS.stolen_stall_at_zero ~= false)

  if VM_GAS_ECONOMY and VM_GAS_ECONOMY.start then
    VM_GAS_ECONOMY.start()
  end

  local base = SETTINGS.price_epl or DEFAULT_PRICE_EPL
  applyFuelPrice(base, { persist_base = false })
  if SETTINGS.price_dyn_enable then
    applyFuelPrice(nextDynamicPrice(base, base), { persist_base = false })
  end
  pushPriceFact(true)
  priceReassertTimer = 1.0
end

local function VM_OnSessionEnd()
  if not vmSessionActive then
    return
  end

  vmSessionActive = false
  VM_FACT_CACHE = {}

  vm.isMounted = false
  vmMountFallbackWarned = false
  lastPos, lastVehId = nil, nil
  lastIsBike = nil
  lastSpec = nil
  lastVehData = nil
  isIgnoredCache = nil
  lastAutoIgnoreId = nil
  lastSpeedPushed = -1
  wasOwned, hudAcc = false, 0.0
  autoHideTimer = 0.0
  autoHideLatched = false

  if VM_MAINTENANCE and VM_MAINTENANCE.onSessionEnd then
    VM_MAINTENANCE.onSessionEnd()
  end

  if SAVE and SAVE.onSessionEnd then
    SAVE:onSessionEnd()
  elseif SAVE and SAVE.resetRuntime then
    SAVE:resetRuntime()
  end

  if VM_GAS_ECONOMY and VM_GAS_ECONOMY.stop then
    VM_GAS_ECONOMY.stop()
  end

  setFactInt(FACT_HUD_VISIBLE, 0)
  setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
  priceVisibleLast = false
end

if Mod then
  -- WhenReady waits for a stable player after the savegame is loaded. It also
  -- handles CET "Reload all mods" and player recreation without OnTakeControl.
  Mod.WhenReady(function(player)
    VM_OnSessionStart(player)
  end, 3)

  Mod.Subscribe("PlayerInvalidated", function()
    VM_OnSessionEnd()
  end)
else
  print("[VehicleMileage] ERROR: 0-Engine lifecycle unavailable; save facts will not initialize.")
end

  -- ────────────────────────────────────────────────────────────────────────
  -- 0-Engine intervals (replaces per-frame polling in onUpdate)
  -- Only registered when Mod handle is available (0-Engine loaded).
  -- ────────────────────────────────────────────────────────────────────────
  if Mod then

  -- Optional Weather Condition bridge: every 5 seconds while mounted.
  -- Maintenance and the CET overlay only read the cached result.
  Mod.SetInterval(5.0, function()
    if vmSessionActive and vm.isMounted then
      VM_WEATHER_CONDITION.Refresh()
    end
  end)

  -- Save sync: every 2 seconds (SAVE internally batched at same rate)
  Mod.SetInterval(2.0, function()
    if SAVE and SAVE.dirty then
      SAVE:syncAll(false)
      SAVE.dirty = false
    end
  end)

  -- Widget reassert: every 0.25s, self-stops when UI is ready (max 12s)
  do
    local reassertHandle
    reassertHandle = Mod.SetInterval(0.25, function()
      if _wm_reassert_left <= 0.0 then
        if reassertHandle and reassertHandle.Cancel then reassertHandle:Cancel()
        elseif Mod.ClearTimer then Mod.ClearTimer(reassertHandle) end
        return
      end
      _wm_reassert_left = math.max(0.0, _wm_reassert_left - 0.25)
      local haveToggles = uiTogglesReady()
      local haveTfms    = (SETTINGS.widget_mode ~= "fuelgauge") or uiTransformsReady()
      applyWidgetModeRuntime(SETTINGS.widget_mode)
      if not (haveToggles and haveTfms) then
        _wm_reassert_left = math.min(12.0, _wm_reassert_left + 0.5)
      end
    end)
  end

  -- Stolen vehicle GC: every 5 seconds
  Mod.SetInterval(5.0, function()
    if STOLEN and STOLEN.tick then STOLEN.tick(5.0) end
  end)

  -- Gas economy + price tick: every 30 real seconds (checks in-game hour).
  Mod.SetInterval(30.0, function()
    if not vmSessionActive then return end

    local economyChanged = false
    if VM_GAS_ECONOMY and VM_GAS_ECONOMY.update then
      local economyStatus = VM_GAS_ECONOMY.getStatus()
      if economyStatus.running then
        economyChanged = select(1, VM_GAS_ECONOMY.update()) == true
      else
        economyChanged = VM_GAS_ECONOMY.start() == true
      end
    end

    local h = getInGameHour()
    if h == nil then return end
    if lastHourSeen < 0 then
      lastHourSeen = h
    elseif h ~= lastHourSeen or economyChanged then
      lastHourSeen = h
      local base = SETTINGS.price_epl or DEFAULT_PRICE_EPL
      local previousMarket = VM_GAS_ECONOMY.getMarketPrice(base)
      local np = SETTINGS.price_dyn_enable
        and nextDynamicPrice(base, previousMarket) or base
      applyFuelPrice(np, { persist_base = false })
      pushPriceFact(true)
      priceReassertTimer = 1.0
    end
  end)

  -- Config reload: every 25 seconds (dev convenience)
  Mod.SetInterval(VMCONST.MISC.CONFIG_RELOAD_SEC, function()
    if DEV_OVERLAY_RELOAD_ONLY and not isOverlayVisible then return end
    reloadSpecFiles()
    pushPriceFact(false)
  end)

  -- 3D World leaderboard refresh: every 5 seconds
  -- Reads persistent per-vehicle meters facts from vm_config_cars/bikes.
  Mod.SetInterval(VM_WORLD_LB_INTERVAL or 5.0, function()
    if VM_WorldLB_PushTop10FromFactConfigs then
      VM_WorldLB_PushTop10FromFactConfigs()
    end
  end)

  -- Oil cooldown for unmounted vehicles.
  -- Uses vm.isMounted (set by VehicleMount/VehicleUnmount events) instead of
  -- polling GetPlayer()/GetMountedVehicle() every 2 seconds.
  -- Self-stops when all vehicles cool to ambient; restarts on next unmount.
  local _oilCoolHandle = nil
  _startOilCooldown = function()
    if _oilCoolHandle then return end  -- already running
    _oilCoolHandle = Mod.SetInterval(2.0, function()
      if vm.isMounted then return end  -- mounted = onUpdate handles oil
      local vs = (SAVE and SAVE.data and SAVE.data.vehicles) or {}
      local anyWarm = false
      for vid, rec in pairs(vs) do
        if rec and rec.oil_temp and rec.oil_temp > 30 then
          anyWarm = true
          tickOilTemp(rec, 0.0, 2.0, false, nil, tostring(vid), vid, false)
        end
      end
      -- All vehicles at ambient — pause the timer until next unmount
      if not anyWarm and _oilCoolHandle then
        if _oilCoolHandle.Cancel then
          _oilCoolHandle:Cancel()
        elseif Mod.ClearTimer then
          Mod.ClearTimer(_oilCoolHandle)
        end
        _oilCoolHandle = nil
      end
    end)
  end

  end -- end if Mod


end) -- end OnInit -- end function (anonymous)

-- CET ImGui return-shape helper: return whichever arg is the string
local function _takeStr(a, b, fallback)
if type(a) == "string" then return a end -- end function _takeStr
if type(b) == "string" then return b end
return fallback
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ CET Overlay: 3D World tab helpers                                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

function VMWorld_TakeSliderInt(label, value, minV, maxV)
  local a, b = ImGui.SliderInt(label, value, minV, maxV)

  if type(a) == "number" and type(b) == "boolean" then
    return b, VMWorld_ClampInt(a, minV, maxV, value)
  end

  if type(a) == "boolean" and type(b) == "number" then
    return a, VMWorld_ClampInt(b, minV, maxV, value)
  end

  return false, value
end

function VMWorld_TakeCheckbox(label, value)
  local checked, changed = ImGui.Checkbox(label, value)

  if type(checked) == "boolean" and type(changed) == "boolean" then
    return changed, checked
  end

  return false, value
end

function VMWorld_DrawThemeCombo(key, obj)
  local label = VM_FG_THEME_VALUES[(obj.theme or 0) + 1] or "Default"

  if ImGui.BeginCombo("Color##vmworld_color_" .. key, label) then
    for i, name in ipairs(VM_FG_THEME_VALUES) do
      local themeId = i - 1
      local selected = obj.theme == themeId

      if ImGui.Selectable(name .. "##vmworld_color_" .. key .. "_" .. tostring(themeId), selected) then
        obj.theme = themeId
        VMWorld_ApplyOne(key)
      end
    end

    ImGui.EndCombo()
  end
end

function VMWorld_DrawFontCombo(key, obj)
  local label = VMWORLD_FONT_OPTIONS[obj.font_index or 6] or VMWORLD_FONT_OPTIONS[6]

  if ImGui.BeginCombo("Font##vmworld_font_" .. key, label) then
    for _, idx in ipairs(VMWORLD_FONT_ORDER) do
      local name = VMWORLD_FONT_OPTIONS[idx]
      local selected = obj.font_index == idx

      if ImGui.Selectable(name .. "##vmworld_font_" .. key .. "_" .. tostring(idx), selected) then
        obj.font_index = idx
        VMWorld_ApplyOne(key)
      end
    end

    ImGui.EndCombo()
  end
end

function VMWorld_DrawObjectControls(key, title)
  local obj = VMWorld_GetDraftObject(key)

  ImGui.Text(title)

  VMWorld_DrawThemeCombo(key, obj)
  VMWorld_DrawFontCombo(key, obj)

  local changed = false
  local v = 0

  changed, v = VMWorld_TakeSliderInt(
    "Font Size##vmworld_fontsize_" .. key,
    obj.font_size or 28,
    8,
    120
  )

  if changed then
    obj.font_size = v
    VMWorld_ApplyOne(key)
  end

	changed, v = VMWorld_TakeSliderInt(
		"Brightness##vmworld_brightness_" .. key,
		obj.brightness_milli or 1000,
		0,
		3000
	)

	if changed then
		obj.brightness_milli = v
		VMWorld_ApplyOne(key)
	end

  changed, v = VMWorld_TakeSliderInt(
    "Scale##vmworld_scale_" .. key,
    obj.scale or 1000,
    1,
    3000
  )

  if changed then
    obj.scale = v
    VMWorld_ApplyOne(key)
  end

  changed, v = VMWorld_TakeSliderInt(
    "X##vmworld_x_" .. key,
    obj.x or 0,
    -7000,
    7000
  )

  if changed then
    obj.x = v
    VMWorld_ApplyOne(key)
  end

  changed, v = VMWorld_TakeSliderInt(
    "Y##vmworld_y_" .. key,
    obj.y or 0,
    -7000,
    7000
  )

  if changed then
    obj.y = v
    VMWorld_ApplyOne(key)
  end

	if key == "lb" then
		local checkedChanged, checked = VMWorld_TakeCheckbox(
			"Hide##vmworld_hide_" .. key,
			obj.hidden == true
		)

		if checkedChanged then
			obj.hidden = checked == true
			VMWorld_ApplyOne(key)
		end

		local borderChanged, borderChecked = VMWorld_TakeCheckbox(
			"Hide Border##vmworld_hide_border_" .. key,
			obj.border_hidden == true
		)

		if borderChanged then
			obj.border_hidden = borderChecked == true
			VMWorld_ApplyOne(key)
		end
	else
		local checkedChanged, checked = VMWorld_TakeCheckbox(
			"Show##vmworld_show_" .. key,
			obj.hidden ~= true
		)

		if checkedChanged then
			obj.hidden = not (checked == true)
			VMWorld_ApplyOne(key)
		end
	end

  if ImGui.Button("Reset##vmworld_reset_" .. key) then
    VMWorld_ResetObject(key)
  end
end

function VMWorld_DrawTab()
  if type(VMWORLD_STATE) ~= "table" then
    VMWorld_ResetDraftFromSettings()
    VMWorld_ApplyAll()
  end

  ImGui.Text("3D World")
  ImGui.TextDisabled("Live preview. Press Save at the bottom to write vm_settings.json.")

  ImGui.Separator()
  VMWorld_DrawObjectControls("lb", "Leaderboard")

  -- Aux controls are disabled for now.
  -- Keep the code/runtime data because we may use aux1-3 later again.
  --[[
  ImGui.Separator()
  VMWorld_DrawObjectControls("aux1", "aux1")

  ImGui.Separator()
  VMWorld_DrawObjectControls("aux2", "aux2")

  ImGui.Separator()
  VMWorld_DrawObjectControls("aux3", "aux3")
  --]]

  ImGui.Separator()

  if ImGui.Button("Save##vmworld_save_all") then
    VMWorld_SaveDraft()
  end

  ImGui.SameLine()

  if ImGui.Button("Reload saved##vmworld_reload_saved") then
    VMWorld_ResetDraftFromSettings()
    VMWorld_ApplyAll()
    VMWORLD_STATUS = "Reloaded saved 3D World settings."
  end

  if VMWORLD_STATUS and VMWORLD_STATUS ~= "" then
    ImGui.TextDisabled(VMWORLD_STATUS)
  end
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Debug UI (CET overlay)                                                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

registerForEvent("onDraw", function()
if not isOverlayVisible then return end -- end function (anonymous)

local condFirst = (ImGuiCond and ImGuiCond.FirstUseEver) or 1
if ImGui.SetNextWindowCollapsed then ImGui.SetNextWindowCollapsed(true, condFirst) end
if not ImGui.Begin(WINDOW_TITLE) then ImGui.End(); return end

if ImGui.BeginTabBar("VM_Main_Window_Tabs") then
  if ImGui.BeginTabItem("Main") then

ImGui.Text("Save System: quest facts")
ImGui.Text(("Fuel price: %.2f Eddies/L%s"):format(currentPrice, (SETTINGS.price_dyn_enable and " (dynamic)") or ""))

local player  = Game.GetPlayer()
local mounted = player and player:GetMountedVehicle() or nil
if mounted then
  local id, name = vehKeyAndLabel(mounted)
  local spec     = specsFor(name)
  local tank     = spec.tank_l or FALLBACK_CAR.tank_l
  local l100     = spec.l100km or FALLBACK_CAR.l100km
  local v        = SAVE:ensureVehicle(id)
  local fuelL    = (v.fuel_pct or 0) * tank
  local range_km = (l100 > 0) and ((fuelL / l100) * 100.0) or 0

  ImGui.Separator()
  ImGui.Text(("Vehicle: %s"):format(name))
  ImGui.Text(("ODO (this save): %.2f km"):format((v.meters or 0) / 1000.0))
	ImGui.Text(("Fuel: %.1f / %.1f L (%.0f%%)"):format(fuelL, tank, (v.fuel_pct or 0) * 100))
	pcall(function() ImGui.ProgressBar(v.fuel_pct or 0, ImGui.GetContentRegionAvail(), "") end)
	ImGui.Text(("Base Consumption: %.1f L/100km | Est. range: %.0f km"):format(l100, range_km))

-- NEW: Current Oil Temperature
local shownOil = tonumber(v.oil_temp or ambientColdNow(name)) or 0
ImGui.Text(("Current Oil Temperature: %.1f °C"):format(shownOil))

-- Inline editors (player-owned + existing spec only)
local owned = false
pcall(function() owned = mounted:IsPlayerVehicle() end) -- end function (anonymous)
if not owned then
  -- DAV/unlocked fallback: consider purchased AVs (and mod vehicles) as owned
  owned = isOwnedViaUnlockedList(name)
end

local keyStr  = cleanKey(name) or name
local isBike  = looksLikeBike(name) and true or false
local map     = isBike and BIKE_SPECS or CAR_SPECS
local path    = isBike and BIKE_SPECS_PATH or CAR_SPECS_PATH
local hasSpec = map[keyStr] ~= nil

-- NEW: ensure a spec exists for player-owned vehicles (so Save won't be a no-op)
if owned and not hasSpec then
  ensureSpecForLabel(name, isBike)
  reloadSpecFiles()
  map     = isBike and BIKE_SPECS or CAR_SPECS
  path    = isBike and BIKE_SPECS_PATH or CAR_SPECS_PATH
  hasSpec = map[keyStr] ~= nil
end


UI_EDIT[keyStr] = UI_EDIT[keyStr] or {
l100_str = hasSpec and string.format("%.2f", tonumber(map[keyStr].l100km) or 0.0) or "",
tank_str = hasSpec and string.format("%.1f", tonumber(map[keyStr].tank_l)  or 0.0) or "",
}
local s = UI_EDIT[keyStr]

local function parseNumber(str)
  str = tostring(str or ""):gsub(",", "."):gsub("^%s+", ""):gsub("%s+$", "")
  return tonumber(str)
end -- end function parseNumber

--if owned and hasSpec then
--  ImGui.Separator()
--  ImGui.Text("Edit spec:")
--  ImGui.SameLine()
--  ImGui.PushID(keyStr)

if owned and hasSpec then
--[[
  ImGui.Separator()
  ImGui.Text("Temporary migration tools")
  ImGui.TextDisabled("These controls are only for migrating old vm_session data.")

  if ImGui.Button("Import from legacy save##vm_import_legacy") then
    VM_ImportLegacyMetersLatest()
  end
  ImGui.Text("Manual meters overwrite")
  ImGui.SameLine()
  ImGui.SetNextItemWidth(150)

  do
    local r1, r2

    if ImGui.InputTextWithHint then
      r1, r2 = ImGui.InputTextWithHint(
        "##vm_manual_meters_fact",
        "meters",
        VM_IMPORT_MANUAL_METERS_STR,
        32
      )
    else
      r1, r2 = ImGui.InputText(
        "##vm_manual_meters_fact",
        VM_IMPORT_MANUAL_METERS_STR,
        32
      )
    end

    VM_IMPORT_MANUAL_METERS_STR = _takeStr(r1, r2, VM_IMPORT_MANUAL_METERS_STR)
  end

  ImGui.SameLine()

  if ImGui.Button("Overwrite Current Meters Fact##vm_overwrite_meters") then
    local meters = parseNumber(VM_IMPORT_MANUAL_METERS_STR)
    VM_OverwriteCurrentVehicleMeters(meters)
  end
  ]]
  ImGui.Separator()
  ImGui.Text("Edit spec:")
  ImGui.SameLine()
  ImGui.PushID(keyStr)

  -- L/100km
  ImGui.Text("L/100km")
  ImGui.SameLine()
  ImGui.SetNextItemWidth(110)
  do
    local r1, r2
    if ImGui.InputTextWithHint then
      r1, r2 = ImGui.InputTextWithHint("##vm_l100_txt", "e.g. 12.5", s.l100_str, 64)
    else
      r1, r2 = ImGui.InputText("##vm_l100_txt", s.l100_str, 64)
    end
  s.l100_str = _takeStr(r1, r2, s.l100_str)
end
ImGui.SameLine()
if ImGui.Button("Save##l100_inline") then
  local vnum = tonumber((s.l100_str or ""):gsub(",", "."):match("^%s*(.-)%s*$"))
  if vnum then
    vnum = math.max(0.0, math.min(10000.0, vnum))
    map[keyStr].l100km = vnum
    local ok = saveSpecMap(path, map)
    if ok then
      reloadSpecFiles()
      s.l100_str = string.format("%.2f", vnum)
      print(("[VehicleOdometer] Updated '%s' l/100km = %.2f"):format(keyStr, vnum))
    else
      print("[VehicleOdometer] ERROR: write failed for " .. tostring(path))
    end
else
  print("[VehicleOdometer] Invalid l/100km: " .. tostring(s.l100_str))
end
end

-- spacing
ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()

-- Tank (L)
ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
ImGui.Text("Tank (L)")
ImGui.SameLine()
ImGui.SetNextItemWidth(110)
do
  local r1, r2
  if ImGui.InputTextWithHint then
    r1, r2 = ImGui.InputTextWithHint("##vm_tank_txt", "e.g. 50", s.tank_str, 64)
  else
    r1, r2 = ImGui.InputText("##vm_tank_txt", s.tank_str, 64)
  end
s.tank_str = _takeStr(r1, r2, s.tank_str)
end
ImGui.SameLine()
if ImGui.Button("Save##tank_inline") then
  local vnum = tonumber((s.tank_str or ""):gsub(",", "."):match("^%s*(.-)%s*$"))
  if vnum then
    vnum = math.max(1.0, math.min(100000.0, vnum))
    map[keyStr].tank_l = vnum
    local ok = saveSpecMap(path, map)
    if ok then
      reloadSpecFiles()
      s.tank_str = string.format("%.1f", vnum)
      print(("[VehicleOdometer] Updated '%s' tank_l = %.1f"):format(keyStr, vnum))
    else
      print("[VehicleOdometer] ERROR: write failed for " .. tostring(path))
    end
else
  print("[VehicleOdometer] Invalid tank size: " .. tostring(s.tank_str))
end
end

-- NEW: Oil optimal range editors
do
  -- Seed UI cache
  if not s.oil_lo_str or not s.oil_hi_str then
		local curLo = tonumber(map[keyStr].oil_opt_min)
								 or (isBike and VMCONST.OIL.DEF_BIKE_MIN or VMCONST.OIL.DEF_CAR_MIN)
		local curHi = tonumber(map[keyStr].oil_opt_max) or 120
		s.oil_lo_str = string.format("%.0f", curLo)
    s.oil_hi_str = string.format("%.0f", curHi)
  end

  ImGui.Separator()
  ImGui.Text("Oil optimal (°C)")
  -- Min
  ImGui.Text("Min"); ImGui.SameLine()
  ImGui.SetNextItemWidth(90)
  do
    local r1, r2 = ImGui.InputTextWithHint and ImGui.InputTextWithHint("##vm_oil_lo", "e.g. 80", s.oil_lo_str, 32)
                   or ImGui.InputText("##vm_oil_lo", s.oil_lo_str, 32)
    s.oil_lo_str = (type(r1)=="string" and r1) or (type(r2)=="string" and r2) or s.oil_lo_str
  end
  ImGui.SameLine()
  -- Max
  ImGui.Text("Max"); ImGui.SameLine()
  ImGui.SetNextItemWidth(90)
  do
    local r1, r2 = ImGui.InputTextWithHint and ImGui.InputTextWithHint("##vm_oil_hi", "e.g. 120", s.oil_hi_str, 32)
                   or ImGui.InputText("##vm_oil_hi", s.oil_hi_str, 32)
    s.oil_hi_str = (type(r1)=="string" and r1) or (type(r2)=="string" and r2) or s.oil_hi_str
  end
  ImGui.SameLine()
  if ImGui.Button("Save##oil_range") then
	local lo = tonumber( ({ (s.oil_lo_str or ""):gsub(",", ".") })[1] )
	local hi = tonumber( ({ (s.oil_hi_str or ""):gsub(",", ".") })[1] )
    if lo and hi then
      if lo > hi then lo, hi = hi, lo end
      lo = math.max(0, math.min(300, lo))
      hi = math.max(0, math.min(300, hi))
      map[keyStr].oil_opt_min = lo
      map[keyStr].oil_opt_max = hi
      if saveSpecMap(path, map) then
        reloadSpecFiles()
        s.oil_lo_str = string.format("%.0f", lo)
        s.oil_hi_str = string.format("%.0f", hi)
        print(("[VehicleOdometer] Updated '%s' oil_opt_min/max = %.0f/%.0f °C"):format(keyStr, lo, hi))
      else
        print("[VehicleOdometer] ERROR: write failed for " .. tostring(path))
      end
    else
      print("[VehicleOdometer] Invalid oil range: "..tostring(s.oil_lo_str)..", "..tostring(s.oil_hi_str))
    end
  end
end



ImGui.PopID()
end
ImGui.Separator()
ImGui.Text(("Speed: %.1f km/h | Multiplier: x%.2f"):format(LIVE.kmh or 0, LIVE.factor or 1))
if LIVE.mode == "move" then
  ImGui.Text(("Instant Usage: %.1f L/100km"):format(LIVE.inst_l100 or 0))
elseif LIVE.mode == "idle" then
    ImGui.Text(("Idle Usage: %.2f L/h"):format(LIVE.idle_lph or 0))
  else
    ImGui.Text("Instant Usage: 0.0 L/100km (stopped)")
  end
  ImGui.Text(VM_WEATHER_CONDITION.GetDebugText())
else
  ImGui.Separator()
  ImGui.Text("Not in a vehicle.")
end

-- Dev-only: Add Gas Station UI
if add_gas_station_button then
  ImGui.Separator()
  ImGui.Text("Dev: Add Gas Station")
  ImGui.SameLine()

  -- Radius input (kept as string, parsed on click)
  ImGui.SetNextItemWidth(90)
  do
    local r1, r2
    if ImGui.InputTextWithHint then
      r1, r2 = ImGui.InputTextWithHint("##vm_gas_radius", "radius (m)", DEV_GAS_RADIUS_STR, 32)
    else
      r1, r2 = ImGui.InputText("##vm_gas_radius", DEV_GAS_RADIUS_STR, 32)
    end
    DEV_GAS_RADIUS_STR = _takeStr(r1, r2, DEV_GAS_RADIUS_STR)
  end

  ImGui.SameLine()
  if ImGui.Button("Add Gas Station##vm_add_gas_btn") then
    local rad = tonumber(({(DEV_GAS_RADIUS_STR or ""):gsub(",", ".")})[1]) or 5.0
    if rad <= 0 then rad = 5.0 end
    appendGasLocationHere(rad)
  end

  ImGui.SameLine()
  if ImGui.Button("Remove Gas Station##vm_del_gas_btn") then
    removeGasLocationNearby(5.0)
  end
end

-- Dev-only: Add Repair Station UI
if add_repair_station_button then
  ImGui.Separator()
  ImGui.Text("Dev: Add Repair Zone")
  ImGui.SameLine()

	ImGui.SetNextItemWidth(90)
	do
		local r1, r2
		if ImGui.InputTextWithHint then
			r1, r2 = ImGui.InputTextWithHint("##vm_repair_radius", "radius (m)", DEV_REPAIR_RADIUS_STR, 32)
		else
			r1, r2 = ImGui.InputText("##vm_repair_radius", DEV_REPAIR_RADIUS_STR, 32)
		end
		DEV_REPAIR_RADIUS_STR = _takeStr(r1, r2, DEV_REPAIR_RADIUS_STR)
	end

	ImGui.SameLine()
	ImGui.SetNextItemWidth(110)
	do
		local p1, p2
		if ImGui.InputTextWithHint then
			p1, p2 = ImGui.InputTextWithHint("##vm_repair_price", "price €$", DEV_REPAIR_PRICE_STR, 32)
		else
			p1, p2 = ImGui.InputText("##vm_repair_price", DEV_REPAIR_PRICE_STR, 32)
		end
		DEV_REPAIR_PRICE_STR = _takeStr(p1, p2, DEV_REPAIR_PRICE_STR)
	end

	ImGui.Text("Repair FX world nodes:")

	for i = 1, 10 do
		ImGui.Text(("FX %d"):format(i))
		ImGui.SameLine()
		ImGui.SetNextItemWidth(620)

		local r1, r2
		local key = "##vm_repair_fxeffect" .. tostring(i)
		local hint = ("$/mod/repair_h10garage/#pump_h10garage_fxeffect%d"):format(i)

		if ImGui.InputTextWithHint then
			r1, r2 = ImGui.InputTextWithHint(key, hint, DEV_REPAIR_FX_STR[i] or "", 256)
		else
			r1, r2 = ImGui.InputText(key, DEV_REPAIR_FX_STR[i] or "", 256)
		end

		DEV_REPAIR_FX_STR[i] = _takeStr(r1, r2, DEV_REPAIR_FX_STR[i] or "")
	end

	if ImGui.Button("Add Repair Zone##vm_add_repair_btn") then
		local rad = tonumber(({(DEV_REPAIR_RADIUS_STR or ""):gsub(",", ".")})[1]) or 5.0
		if rad <= 0 then rad = 5.0 end

		local priceStr = tostring(DEV_REPAIR_PRICE_STR or "500"):gsub(",", ".")
		local price = math.floor((tonumber(priceStr) or 500) + 0.5)
		if price < 0 then price = 0 end

		appendRepairLocationHere(rad, price, DEV_REPAIR_FX_STR)
	end

  ImGui.SameLine()
  if ImGui.Button("Remove Repair Zone##vm_del_repair_btn") then
    removeRepairLocationNearby(5.0)
  end
end
-- 3D controls moved to the "3D Setup" tab below.
--[[
ImGui.Separator()
ImGui.Text("Debug Functions")
ImGui.Separator()
-- [NEW] Footer debug buttons (left-aligned). Short labels to keep them tiny.
do
  local pushed = false

  if ImGui.Button("FG Dump##vm_fg_dump") then
    if VM_DebugDumpFG then VM_DebugDumpFG() else print("[VehicleMileage] VM_DebugDumpFG missing") end
  end
  ImGui.SameLine()
  if ImGui.Button("FG I/O##vm_fg_io") then
    if VM_DebugCheckSettingsIO then VM_DebugCheckSettingsIO() else print("[VehicleMileage] VM_DebugCheckSettingsIO missing") end
  end
  ImGui.SameLine()
  if ImGui.Button("FG Reapply##vm_fg_reapply") then
    if VM_DebugForceReapplyFG then VM_DebugForceReapplyFG() else print("[VehicleMileage] VM_DebugForceReapplyFG missing") end
  end
	ImGui.SameLine()
	if ImGui.Button("Clear FG facts##vm_fg_clearfacts") then
		Game.GetQuestsSystem():SetFactStr("vm_gauge_scale_milli",0)
		Game.GetQuestsSystem():SetFactStr("vm_gauge_dx",0)
		Game.GetQuestsSystem():SetFactStr("vm_gauge_dy",0)
		print("[VehicleMileage] Cleared vm_gauge_* facts to 0")
	end
	ImGui.SameLine()
  if ImGui.Button("VM Facts##vm_print_facts") then
    local qs = Game.GetQuestsSystem()
    if not qs then
      print("[VehicleMileage] QuestsSystem unavailable")
    else
      local keys = {
        "vm_gauge_scale_milli","vm_gauge_dx","vm_gauge_dy","vm_fg_boot_ok","vm_fg_enabled","vm_fg_temp_visible",
        "vm_hud_visible","vm_hud_meters","vm_hud_fuel_permille","vm_hud_speed_kmh","vm_hud_vehicle_cond_pct",
        "vm_hud_oil_temp_c","vm_hud_price_visible","vm_hud_price_cents",
        "VM_SetHUDPosX","VM_SetHUDPosY"
      }
      print("[VehicleMileage] ---- VM quest facts ----")
      for i = 1, #keys do
        local k = keys[i]
        local v = qs:GetFactStr(k)
        print(k .. "=" .. tostring(v))
      end
    end
  end
end
--]]


do
  local label = VM_VERSION
  -- width of the text
  local tw = select(1, ImGui.CalcTextSize(label))
  -- available width in the current line (window content region)
  local ok, availW = pcall(ImGui.GetWindowContentRegionWidth)
  if ok and type(availW) == "number" then
    -- move cursor so the text lands flush-right
    ImGui.SetCursorPosX(ImGui.GetCursorPosX() + math.max(0, availW - tw))
  end
  -- slightly dimmed if available; otherwise normal text
  if ImGui.TextDisabled then
    ImGui.TextDisabled(label)
  else
    ImGui.Text(label)
  end
end
-- ----------------------------------------------

    ImGui.EndTabItem()
  end

if ImGui.BeginTabItem("3D Setup") then
  if tostring(SETTINGS.widget_mode or ""):lower() == "3dwidget" then
    if VM3D_CONTROLS and VM3D_CONTROLS.drawIfActive then
			VM3D_CONTROLS.drawIfActive({
				getContext = VM3D_GetMountedOwnedContext,
				setFactInt = setFactInt,
				saveVehicle = VM3D_SaveMountedVehicle,
				resetVehicle = VM3D_ResetMountedVehicle,

				-- 3D preset support
				listPresets = VM3D_ListPresetNames,
				savePreset = VM3D_SavePresetForMountedVehicle,
				loadPreset = VM3D_LoadPresetToFacts,
				refreshPresets = VM3D_RefreshPresetList,
				deletePreset = VM3D_DeletePreset,
			})
    end
  else
    ImGui.Text("3D controls are hidden.")
    ImGui.Text("Go to Native Settings -> VehicleMileage -> HUD Widget.")
    ImGui.Text("Set Active HUD Widget to: 3D Widget")
  end

  ImGui.EndTabItem()
end

if ImGui.BeginTabItem("3D World") then
  VMWorld_DrawTab()
  ImGui.EndTabItem()
end

  ImGui.EndTabBar()
else
  ImGui.Text("Could not create CET tabs.")
end

ImGui.End()
end)

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Main update (price dynamics, refuel, HUD, odo/fuel)                       ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

registerForEvent("onUpdate", function(dt)
  -- [0-Engine] SAVE sync, widget reassert, STOLEN GC, dynamic price,
  -- config reload all moved to Mod.SetInterval in onInit.
  -- SAVE:onUpdate(dt) intentionally NOT called here; sync handled by
  -- Mod.SetInterval(2.0) in onInit (0E design — avoids per-frame dirty check).

  -- ── Compute pause state once per frame (avoids 4× raw-API calls) ─────────
  -- [0-Engine] VM_WORLD leaderboard refresh moved to Mod.SetInterval(5.0) in onInit.
  local paused = (isInMenu and isInMenu()) or false

  -- Price reassert runs regardless of mount state (needed right after load)
  if priceReassertTimer > 0.0 then
    priceReassertTimer = priceReassertTimer - (dt or 0)
    pushPriceFact(true)
  end

  -- Toast flush on menu-close edge.
  -- Mod.Subscribe("MenuClose") is the primary path; wasInMenu is a fallback.
  if wasInMenu and not paused then
    if PENDING_TOAST and PENDING_TOAST ~= "" and _canEmit() then
      _showRed(PENDING_TOAST)
      lastToastAt = os.clock()
      PENDING_TOAST = nil
    end
  end
  if not paused and PENDING_TOAST and PENDING_TOAST ~= "" and _canEmit() then
    _showRed(PENDING_TOAST)
    lastToastAt = os.clock()
    PENDING_TOAST = nil
  end
  wasInMenu = paused

  if not vm.isMounted then
    -- Safety fallback:
    -- 0-Engine can miss mount state after reload / already-seated save.
    -- We do one cheap recovery check only while the mod thinks we are on foot.
    local p = Game.GetPlayer()
    local mountedVeh = p and p:GetMountedVehicle() or nil

		if mountedVeh then
			if not vmMountFallbackWarned then
				print("[VehicleMileage] Mount fallback recovered mounted vehicle. 0-Engine VehicleMount was probably missed.")
				vmMountFallbackWarned = true
			end

			onVehicleMount(mountedVeh)
		else
      if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
        VM_MAINTENANCE.resetMounted()
      end

      if REPAIR and REPAIR.update then
        REPAIR.update(dt)
      end

      return
    end
  end

-- Start if not player

local player = Game.GetPlayer()
if not player then
  if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
    VM_MAINTENANCE.resetMounted()
  end

  if lastHUDVisible ~= 0 then
    setFactInt(FACT_HUD_VISIBLE, 0)
		setFactInt(FACT_FG_TEMP_VISIBLE, 0)
    lastHUDVisible = 0
  end
	-- NEW: keep cache in sync so we can raise it again later
	if lastTempVisible ~= 0 then lastTempVisible = 0 end
	factAcc = 0.0
	factPushInterval = FACT_PUSH_INTERVAL_BASE
	if priceVisibleLast then setFactInt(FACT_HUD_PRICE_VISIBLE, 0); priceVisibleLast = false end

	if lastVehCondPctPushed ~= -1 then		
		setFactInt(FACT_HUD_VEH_COND_PCT, -1)
		lastVehCondPctPushed = -1
	end
-- end before return not player
	autoHideTimer = 0.0
	autoHideLatched = false
	return
end




local veh = player:GetMountedVehicle()
if not veh then
  if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
    VM_MAINTENANCE.resetMounted()
  end

  -- Fallback: VehicleUnmount event was missed (vehicle destroyed mid-frame).
  -- onVehicleUnmount() already handles the clean path; here we do a compact
  -- reset so that vm.isMounted becomes false and subsequent frames exit early.
  if vm.isMounted then
    vm.isMounted = false
    if priceVisibleLast or refuelingPrev then _forceStopRefuel() end
    if lastHUDVisible ~= 0 then
      setFactInt(FACT_HUD_VISIBLE, 0)
      setFactInt(FACT_FG_TEMP_VISIBLE, 0)
      lastHUDVisible = 0
    end
    if lastTempVisible ~= 0 then lastTempVisible = 0 end
    VM3D_LAST_LOADED_ID = nil
    VM_SetFactIntCached("vm_3d_enabled", 0)
    VM3D_SetHiddenFacts(true, true, true, true)
    if lastVehCondPctPushed ~= -1 then
      setFactInt(FACT_HUD_VEH_COND_PCT, -1)
      lastVehCondPctPushed = -1
    end
    factAcc = 0.0; factPushInterval = FACT_PUSH_INTERVAL_BASE
    lastPos, lastVehId  = nil, nil
    wasOwned, hudAcc    = false, 0.0
    autoHideTimer       = 0.0
    autoHideLatched     = false
    isIgnoredCache      = nil
    lastIsBike          = nil
    lastSpec            = nil
    lastVehData         = nil
    LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph, LIVE.mode = 0, 1, 0, 0, "stop"
  end
  -- Repair cooldown still ticks while the player stands outside
  if REPAIR and REPAIR.update then REPAIR.update(dt) end
  return
end

-- Ignore: auto-add quest-ish labels (once per mount), then enforce ignore
do
  local id, label = vehKeyAndLabel(veh)
  -- Run quest heuristic only when the vehicle changes — avoids pattern-matching every frame
  if id ~= lastAutoIgnoreId then
    autoIgnoreQuestMaybe(label)
    lastAutoIgnoreId = id
    isIgnoredCache   = ignoreIs(label)
  end

	if isIgnoredCache then
		if REPAIR and REPAIR.reset then REPAIR.reset() end
    if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
      VM_MAINTENANCE.resetMounted()
    end

		-- Ignored / quest-like vehicles must never show 3D widgets.
		VM3D_SetHiddenFacts(true, true, true, true)
		VM3D_LAST_LOADED_ID = nil

		if lastHUDVisible ~= 0 then
      setFactInt(FACT_HUD_VISIBLE, 0)
			setFactInt(FACT_FG_TEMP_VISIBLE, 0)
      lastHUDVisible = 0
    end
		if lastTempVisible ~= 0 then lastTempVisible = 0 end  -- NEW
    if priceVisibleLast or refuelingPrev then
      _forceStopRefuel()
    end

    lastPos, lastVehId = nil, nil
    wasOwned, hudAcc   = false, 0.0
    LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph, LIVE.mode = 0, 1, 0, 0, "stop"

    -- NEW: vehicle health -> HUD fact (-1 while hidden)
		if lastVehCondPctPushed ~= -1 then
			setFactInt(FACT_HUD_VEH_COND_PCT, -1)
			lastVehCondPctPushed = -1
		end

		-- [0-Engine] oil cooldown + save sync handled by intervals
		
		autoHideTimer = 0.0
		autoHideLatched = false
		return

  end
end


-- Non-owned (stolen) vehicles
local ownedOK = true
if VMCONST.TRACK.OWNER_ONLY then
  local okOwned, owned = pcall(function()
    return veh:IsPlayerVehicle()
  end)

  if okOwned and owned then
    ownedOK = true
  else
    local _, labelNow = vehKeyAndLabel(veh)

    -- Fallback: DAV AVs / mod garage vehicles can be owned
    -- even when IsPlayerVehicle() is not reliable immediately.
    ownedOK = isOwnedViaUnlockedList(labelNow)
  end
end
if not ownedOK then
	if REPAIR and REPAIR.reset then REPAIR.reset() end
  if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
    VM_MAINTENANCE.resetMounted()
  end

  -- Stolen / non-owned vehicles must never show 3D widgets.
  -- Important: do NOT call VM3D_ForceHidden() here, because it disables vm_3d_enabled.
	VM3D_SetHiddenFacts(true, true, true, true)
  VM3D_LAST_LOADED_ID = nil

	autoHideTimer = 0.0
	setFactInt(FACT_FG_TEMP_VISIBLE, 0)
	if lastTempVisible ~= 0 then lastTempVisible = 0 end  -- NEW
  -- hide price plate; standard HUD delay on mount
  factPushInterval = FACT_PUSH_INTERVAL_BASE
if priceVisibleLast then setFactInt(FACT_HUD_PRICE_VISIBLE, 0); priceVisibleLast = false end



local desiredVisible = (hudAcc >= VMCONST.MISC.HUD_DELAY_SECONDS) and 1 or 0

if not paused then
  hudAcc = hudAcc + (dt or 0)
end
wasOwned = false

local pos = veh:GetWorldPosition()
if not pos then
if lastHUDVisible ~= 0 then setFactInt(FACT_HUD_VISIBLE, 0); lastHUDVisible = 0 end
factAcc = 0.0
factPushInterval = FACT_PUSH_INTERVAL_BASE
lastPos, lastVehId = nil, nil
LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph, LIVE.mode = 0,1,0,0,"stop"
autoHideTimer   = 0.0
autoHideLatched = false
return
end

local cur = { x = pos.x, y = pos.y, z = pos.z }
local id, label = vehKeyAndLabel(veh)
local isBike = looksLikeBike(label) and true or false
local spec   = specsFor(label)

local e = STOLEN.get_or_seed(label, spec, isBike)

local kmh = getSpeedKmh(veh, dt, lastPos, cur)
local dist_m = 0.0
if lastPos and lastVehId == id then
  local dx,dy,dz = cur.x - lastPos.x, cur.y - lastPos.y, cur.z - lastPos.z
  local d2 = dx*dx + dy*dy + dz*dz
  if d2 > JITTER2 and d2 <= MAXSTEP2 then
    local d = math.sqrt(d2)
  if d <= VMCONST.TRACK.TELEPORT_THRESH_M then dist_m = d end
end
end

if dist_m > 0 then
  if FUEL_ENABLED then
    STOLEN.consume_and_update(e, dist_m, kmh)
  else
    e.meters    = (e.meters or 0) + dist_m
    e.last_seen = os.time()
    e.stalled   = false
    e.limit_on  = false
  end
end


if FUEL_ENABLED and STOLEN_STALL_AT_ZERO then
  if (e.fuel_pct or 0) <= 0 then
    e.fuel_pct = 0
    e.stalled  = true
    e.limit_on = false
  else
    e.stalled  = false
    e.limit_on = false
  end

if LIMIT_SPEED_AT_ZERO and e.stalled then
  local sp  = kmh or getSpeedKmh(veh, dt, lastPos, cur)
  local cap = targetLimitKmh(isBike)
  if sp > (cap + VMCONST.LIMITER.HYST_KMH) then
    local dur = math.min(0.25, math.max(0.08, (dt or 0.016) * 8))
    forceBrakeTick(veh, dur)
    e.limit_on = true
  end
end
else
  e.stalled  = false
  e.limit_on = false
end

-- NEW: update oil temp for non-owned mounted vehicles
do
  local label = label  -- already defined by your outer scope
  local spec  = specsFor(label)
  if e and not e.oil_temp then e.oil_temp = ambientColdNow(label) end
  tickOilTemp(e, kmh or 0, dt or 0.016, looksLikeBike(label), spec, label, id, true)
end


factPushInterval = FACT_PUSH_INTERVAL_BASE
factAcc = factAcc + (dt or 0)
if factAcc >= factPushInterval then
  factAcc = 0.0
  if desiredVisible ~= lastHUDVisible then
    setFactInt(FACT_HUD_VISIBLE, desiredVisible)
    lastHUDVisible = desiredVisible
  end
local metersInt = math.floor((e.meters or 0) + 0.5)
if metersInt ~= lastMetersPushed then
  setFactInt(FACT_HUD_METERS, metersInt)
  lastMetersPushed = metersInt
end
  -- Push speed once per cadence
  do
    local spInt = math.max(0, math.min(400, math.floor((kmh or 0) + 0.5)))
    setFactInt(FACT_HUD_SPEED_KMH, spInt)
  end
local permille = math.max(0, math.min(1000, math.floor(((e.fuel_pct or 0) * 1000) + 0.5)))
if permille ~= lastFuelPermillePushed then
  setFactInt(FACT_HUD_FUEL_PERMILLE, permille)
  lastFuelPermillePushed = permille	
	end
end

-- NEW: Oil °C (rounded)
local oilC = e and tonumber(e.oil_temp)
if oilC then
  local oilInt = math.floor(oilC + 0.5)
  if oilInt < -50 then oilInt = -50 end
  if oilInt > 300 then oilInt = 300 end
  if oilInt ~= (lastOilTempPushed or -9999) then
    setFactInt(FACT_HUD_OIL_TEMP_C, oilInt)
    lastOilTempPushed = oilInt
  end
end


-- NEW: vehicle health -> HUD fact (0..100; -1 if unknown)
do
  local cond = vehicleCondPct(veh)
  cond = (cond ~= nil) and cond or -1
  if cond ~= lastVehCondPctPushed then
    setFactInt(FACT_HUD_VEH_COND_PCT, cond)
    lastVehCondPctPushed = cond
  end

LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph, LIVE.mode =
kmh, 1.0, e.l100km or 0, 0.0, (kmh < 1.0 and "stop" or "move")

lastPos   = cur
lastVehId = id
-- [0-Engine] oil cooldown handled by interval

return
end
end -- end of non-owned vehicles branch

-- Repair module runs only after ignore + ownership checks.
-- Non-owned/stolen vehicles already returned above, so they are ignored here.
if REPAIR and REPAIR.update then
  REPAIR.update(dt)
end

-- Re-assert temp-meter visibility for OWNED vehicles (honors widget + toggles)
do
  local isFG   = tostring(SETTINGS.widget_mode or "fuelgauge"):lower() == "fuelgauge"
  local fgOK   = (SETTINGS.fg_enabled      ~= false)
  local tempOK = (SETTINGS.fg_temp_enabled ~= false)   -- nil ⇒ true
  local want   = (isFG and fgOK and tempOK) and 1 or 0
  if want ~= lastTempVisible then
    setFactInt(FACT_FG_TEMP_VISIBLE, want)
    lastTempVisible = want
  end
end

-- Owned vehicles: cached id / spec / vehicle data
local id, name = vehKeyAndLabel(veh)

-- Trip latch reset when switching vehicles
if lastVehId ~= id then OIL_TRIP_WARMED[id] = false end

-- isBike and spec: cached per vehicle to avoid repeated string/table ops every frame
local isBike = (id == lastVehId and lastIsBike ~= nil) and lastIsBike or (looksLikeBike(name) and true or false)
lastIsBike = isBike
local spec = (id == lastVehId and lastSpec ~= nil) and lastSpec or specsFor(name)
lastSpec = spec

-- ensureSpecForLabel only when the vehicle changes (onVehicleMount is the primary path;
-- this is a safety fallback for mounts that bypass the event)
if id ~= lastVehId then
  ensureSpecForLabel(name, isBike)
end

-- Load vehicle-specific 3D setup only when 3D Widget mode is active.
-- Otherwise keep the 3D widget hard-hidden.
if VM3D_IsActiveMode() then
  VM3D_LoadForMountedVehicle(false)
else
  VM3D_ForceHidden()
end

-- Ensure vehicle entry exists (cached per vehicle — avoids repeated fact lookups)
-- Must be declared before GAS.update so the ensureVehicle closure can return v.
local v = (id == lastVehId and lastVehData ~= nil) and lastVehData or SAVE:ensureVehicle(id)
lastVehData = v
if not v then
  if VM_MAINTENANCE and VM_MAINTENANCE.resetMounted then
    VM_MAINTENANCE.resetMounted()
  end
  return
end

if VM_MAINTENANCE and VM_MAINTENANCE.update then
  VM_MAINTENANCE.update(dt, {
    id = id,
    label = name,
    vehicle = veh,
    state = v,
    condition_pct = vehicleCondPct(veh),
    temperature_c = VM_WEATHER_CONDITION.temperatureC,
  })
end

-- Gas module update (refuel + money + audio)
-- Pass cached id, name, v, spec so GAS.update never calls SAVE:ensureVehicle
-- or specsFor() itself — both are already resolved above.
local refuelingNow = GAS.update(dt, {
  ensureVehicle  = function(_) return v end,
  vehKeyAndLabel = function(_) return id, name end,
  getSpecs       = function(_) return spec end,
})

VM_SetFactIntCached(
  "vm_hud_station_empty",
  GAS.isCurrentStationEmpty() and 1 or 0
)

-- HUD fact cadence: faster while refueling
do
  local newInterval = refuelingNow and FACT_PUSH_INTERVAL_REFUEL or FACT_PUSH_INTERVAL_BASE
  if newInterval ~= factPushInterval then
    factPushInterval = newInterval
    factAcc = 0.0
  end
end

-- Dynamic refuel speed (with one-shot start)
if refuelingNow and not refuelingPrev then
	vmPrintTop10Odo()  -- NEW: print Top 10 ODO once when refueling starts
  if v and v.fuel_pct then
    local scale = tankScaleForLabel(name)
		applyRefillRateLps(refillRateForLevel(v.fuel_pct) * scale * REFILL_GLOBAL_SPEED, { in_refuel = true })
    rateCooldown = VMCONST.REFILL.RATE_UPDATE_COOLDOWN
  end
end

if refuelingNow then
  rateCooldown = rateCooldown - (dt or 0)
  if rateCooldown <= 0.0 then
    if v and v.fuel_pct then
      local scale = tankScaleForLabel(name)
      applyRefillRateLps(refillRateForLevel(v.fuel_pct) * scale * REFILL_GLOBAL_SPEED, { in_refuel = true })
    end
    rateCooldown = VMCONST.REFILL.RATE_UPDATE_COOLDOWN
  end
end

if (not refuelingNow) and refuelingPrev then
  if type(GAS.setRefillPerSec) ~= "function" and GAS_OPTS_REF then
    GAS_OPTS_REF.refill_per_sec = VMCONST.REFILL.RATE_FAST
    pcall(GAS.setup, GAS_OPTS_REF)
    lastRefillPerSec = GAS_OPTS_REF.refill_per_sec
  end
rateCooldown = 0.0
end
refuelingPrev = refuelingNow

-- Price plate visibility
if refuelingNow ~= priceVisibleLast then
  if refuelingNow then
    -- RISING EDGE (about to start refuel)
    -- 1) Pre-clear everything so no stale frame can show
    _callUI("VM_LB_ForceHide")
    _callUI("VM_ForceHidePricePlate")
    -- 2) Now raise the fact (VMHUD will prep LB → then reveal)
    setFactInt(FACT_HUD_PRICE_VISIBLE, 1)
  else
    -- FALLING EDGE (just stopped refuel)
    -- 1) Lower the fact first
    setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
    -- 2) Hard-hide to avoid any lingering frame
    _callUI("VM_LB_ForceHide")
    _callUI("VM_ForceHidePricePlate")
  end

  priceVisibleLast = refuelingNow
end



-- HUD entry delay
local desiredVisible = 0
if not wasOwned then
  hudAcc = 0.0
  desiredVisible = 0
else
  desiredVisible = (hudAcc >= VMCONST.MISC.HUD_DELAY_SECONDS) and 1 or 0
end
-- Do not advance HUD entry delay while the game is paused/loading
if not paused then
  hudAcc = hudAcc + (dt or 0)
end
wasOwned = true

local pos = veh:GetWorldPosition(); if not pos then return end
local cur = { x = pos.x, y = pos.y, z = pos.z }

-- ── HUD Auto-Hide (optional) ────────────────────────────────────────────────
do
  local autoOn = (SETTINGS.auto_hide_enabled == true)
  local secs   = tonumber(SETTINGS.auto_hide_seconds)
  if secs == nil then
    secs = VMCONST.MISC.AUTO_HIDE_DEF_SECONDS or 20.0
  end
  local thresh = tonumber(SETTINGS.auto_hide_fuel_pct)
                    or (VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT or 25.0)

  -- Clamp inputs
  local minS = VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0.0
  local maxS = VMCONST.MISC.AUTO_HIDE_MAX_SECONDS or 120.0
  if secs   < minS then secs   = minS elseif secs   > maxS then secs   = maxS end
  if thresh < 0    then thresh = 0    elseif thresh > 100  then thresh = 100  end

  -- PAUSE / LOADING GUARD:
  -- While the game is paused (including loading screens / menus),
  -- we don't want the Auto-Hide countdown or latch to run.
	if paused then
			-- Special-case: "instant hide" (delay == 0) should *stay* hidden
			-- across pause/unpause, except for low-fuel override.
			local instantHide = (SETTINGS.auto_hide_enabled == true)
													and (secs <= (VMCONST.MISC.AUTO_HIDE_MIN_SECONDS or 0))

			if instantHide then
				-- v.fuel_pct is 0..1; convert to %
				local fuelPct = math.max(0, math.min(100, (tonumber(v.fuel_pct) or 0) * 100.0))
				local thresh  = tonumber(SETTINGS.auto_hide_fuel_pct)
													or (VMCONST.MISC.AUTO_HIDE_DEF_FUEL_PCT or 25.0)
				if thresh < 0 then thresh = 0 elseif thresh > 100 then thresh = 100 end
				local lowFuel = (thresh > 0) and (fuelPct <= thresh) or false

				-- Above threshold: force HUD hidden even while paused
				if not lowFuel then
					desiredVisible = 0
					autoHideLatched = true
				else
					-- Low fuel: behave like normal (HUD can stay visible)
					autoHideLatched = false
				end

				autoHideTimer = 0.0
			else
				-- Old behaviour for "normal" Auto-Hide delays (> 0) or when disabled
				autoHideTimer   = 0.0
				autoHideLatched = false
				-- Do NOT touch desiredVisible here; HUD visibility will be handled
				-- normally once the game is unpaused.
			end
		else
    -- REFUEL OVERRIDE:
    -- While refueling we always show the HUD immediately, regardless of
    -- entry delay / Auto-Hide / low fuel. After refueling stops, Auto-Hide
    -- resumes normally.
    if refuelingNow then
      desiredVisible  = 1
      autoHideTimer   = 0.0
      autoHideLatched = false
      -- IMPORTANT: no early return → onUpdate continues,
      -- so HUD facts keep updating while refueling.
    else
      if not autoOn then
        -- feature disabled → behave as before
        autoHideTimer   = 0.0
        autoHideLatched = false
      else
        -- v.fuel_pct is 0..1; convert to %
        local fuelPct = math.max(0, math.min(100, (tonumber(v.fuel_pct) or 0) * 100.0))
        local lowFuel = (thresh > 0) and (fuelPct <= thresh) or false

        if secs <= 0 then
          -- “instant hide” mode:
          --  • HUD always hidden while fuel > threshold (except refueling).
          --  • HUD behaves normally when fuel <= threshold.
          if lowFuel then
            -- LOW FUEL: keep HUD logic as usual, just clear latches
            autoHideTimer   = 0.0
            autoHideLatched = false
          else
            -- ABOVE THRESHOLD: force hidden
            desiredVisible  = 0
            autoHideTimer   = 0.0
            autoHideLatched = true
          end

        else
          -- Normal Auto-Hide behaviour (secs > 0)
          if lowFuel then
            -- LOW FUEL:
            --  • Do NOT override entry delay → keep desiredVisible as computed above.
            --  • Just disable Auto-Hide and clear any latch.
            autoHideTimer   = 0.0
            autoHideLatched = false

          elseif autoHideLatched then
            -- already hidden by Auto-Hide → keep hidden until remount / low fuel / toggle off
            desiredVisible = 0
            autoHideTimer  = secs

          else
            -- Auto-Hide only after the HUD actually became visible
            if desiredVisible == 1 then
              -- rising edge: first frame we became visible
              if lastHUDVisible ~= 1 then
                autoHideTimer = 0.0
              end
              autoHideTimer = autoHideTimer + (dt or 0)
              if autoHideTimer >= secs then
                desiredVisible  = 0
                autoHideLatched = true
                autoHideTimer   = secs
              end
            else
              -- still in entry delay or currently hidden → keep timer at 0
              autoHideTimer = 0.0
            end
          end
        end
      end
    end
  end
end



-- fii 3


-- Throttled quest facts (visible, meters, permille)
factAcc = factAcc + (dt or 0)
if factAcc >= factPushInterval then
  factAcc = 0.0

  if desiredVisible ~= lastHUDVisible then
    setFactInt(FACT_HUD_VISIBLE, desiredVisible)
    lastHUDVisible = desiredVisible
  end

local metersInt = math.floor((v.meters or 0) + 0.5)
if metersInt ~= lastMetersPushed then
  setFactInt(FACT_HUD_METERS, metersInt)
  lastMetersPushed = metersInt
end

-- Push speed (same cadence, only when value changes)
do
  local kmh_now = getSpeedKmh(veh, dt, lastPos, cur)
  local spInt = math.max(0, math.min(400, math.floor((kmh_now or 0) + 0.5)))
  if spInt ~= lastSpeedPushed then
    setFactInt(FACT_HUD_SPEED_KMH, spInt)
    lastSpeedPushed = spInt
  end
end

local permille = math.max(0, math.min(1000, math.floor(((v.fuel_pct or 0) * 1000) + 0.5)))
if permille ~= lastFuelPermillePushed then
  setFactInt(FACT_HUD_FUEL_PERMILLE, permille)
  lastFuelPermillePushed = permille
end

-- NEW: vehicle health -> HUD fact (0..100; -1 if unknown)
do
  local cond = vehicleCondPct(veh)
  cond = (cond ~= nil) and cond or -1
  if cond ~= lastVehCondPctPushed then
    setFactInt(FACT_HUD_VEH_COND_PCT, cond)
    lastVehCondPctPushed = cond
  end
end

end

-- Live preview (debug UI)
local kmh_preview = getSpeedKmh(veh, dt, lastPos, cur)
local spec        = specsFor(name)
local l100_base   = spec.l100km or FALLBACK_CAR.l100km
local factor_prev = speedConsumptionFactor(kmh_preview, isBike)

-- NEW: ensure oil_temp exists and tick it
do
  if v and not v.oil_temp then v.oil_temp = ambientColdNow(name) end
  tickOilTemp(v, kmh_preview or 0, dt or 0.016, isBike, spec, name, id, true)

  -- NEW: push oil temperature fact (°C) for HUD
  local oilC = v and tonumber(v.oil_temp)
  if oilC ~= nil then
    local oilInt = math.floor(oilC + 0.5)
    if oilInt < -50 then oilInt = -50 end
    if oilInt > 300 then oilInt = 300 end
    if oilInt ~= (lastOilTempPushed or -9999) then
      setFactInt(FACT_HUD_OIL_TEMP_C, oilInt)
      lastOilTempPushed = oilInt
    end
  end
end


if kmh_preview < VMCONST.IDLE.SPEED_KMH then
  if IDLE_BURN_ENABLED then
    LIVE.mode      = "idle"
    LIVE.kmh       = kmh_preview
    LIVE.factor    = 1.0
    LIVE.inst_l100 = 0.0
    do
      local idleLph = isBike and VMCONST.IDLE.L_PER_H_BIKE or VMCONST.IDLE.L_PER_H_CAR
      if name and looksLikeAV and looksLikeAV(name) then idleLph = VMCONST.IDLE.L_PER_H_AV end
      LIVE.idle_lph = idleLph
    end
  else
    LIVE.mode, LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph = "stop", kmh_preview, 1.0, 0.0, 0.0
  end
else
  LIVE.mode      = "move"
  LIVE.kmh       = kmh_preview
  LIVE.factor    = factor_prev
  LIVE.inst_l100 = (l100_base or 0) * factor_prev
  LIVE.idle_lph  = 0.0
end

-- Authoritative distance/fuel update
if lastPos and lastVehId == id then
  local dx = cur.x - lastPos.x
  local dy = cur.y - lastPos.y
  local dz = cur.z - lastPos.z
  local d2 = dx*dx + dy*dy + dz*dz

  if d2 > JITTER2 and d2 <= MAXSTEP2 then
    local d = math.sqrt(d2)
    if d <= VMCONST.TRACK.TELEPORT_THRESH_M then
      v.meters = (v.meters or 0) + d
      if FUEL_ENABLED and not v.stalled then
        local tank  = (spec.tank_l or (isBike and FALLBACK_BIKE.tank_l or FALLBACK_CAR.tank_l))
        local l100  = l100_base
        local cur_l = (v.fuel_pct or 1.0) * tank

        local kmh    = getSpeedKmh(veh, dt, lastPos, cur)
        local factor = speedConsumptionFactor(kmh, isBike)
				local used = 0.0
				if kmh >= VMCONST.IDLE.SPEED_KMH then
					-- moving: distance-based usage only
					used = (d / 100000.0) * l100 * factor
				elseif IDLE_BURN_ENABLED then
					-- idle: per-second L/h only
					local idleLph = isBike and VMCONST.IDLE.L_PER_H_BIKE or VMCONST.IDLE.L_PER_H_CAR
					if name and looksLikeAV and looksLikeAV(name) then
						idleLph = VMCONST.IDLE.L_PER_H_AV
					end
					used = (idleLph / 3600.0) * (dt or 0)
				end



      local new_l = math.max(0, math.min(tank, cur_l - used))
      v.fuel_pct  = (tank > 0) and (new_l / tank) or 0

      if LIMIT_SPEED_AT_ZERO and v.fuel_pct <= 0 then
        v.fuel_pct = 0; v.stalled = true; v.limit_on = false
      end

    if kmh >= VMCONST.IDLE.SPEED_KMH then
      LIVE.mode      = "move"
      LIVE.kmh       = kmh
      LIVE.factor    = factor
      LIVE.inst_l100 = (l100 or 0) * factor
      LIVE.idle_lph  = 0.0
    else
      if IDLE_BURN_ENABLED then
        LIVE.mode, LIVE.kmh, LIVE.factor, LIVE.inst_l100 = "idle", kmh, 1.0, 0.0
        do
					local idleLph = isBike and VMCONST.IDLE.L_PER_H_BIKE or VMCONST.IDLE.L_PER_H_CAR
					if name and looksLikeAV and looksLikeAV(name) then idleLph = VMCONST.IDLE.L_PER_H_AV end
					LIVE.idle_lph = idleLph
				end
      else
        LIVE.mode, LIVE.kmh, LIVE.factor, LIVE.inst_l100, LIVE.idle_lph = "stop", kmh, 1.0, 0.0, 0.0
      end
  end
end

v.last = os.time()
SAVE.dirty = true
end
end

if LIMIT_SPEED_AT_ZERO and v and v.stalled then
  local sp  = getSpeedKmh(veh, dt, lastPos, cur)
  local cap = targetLimitKmh(isBike)
  if sp > (cap + VMCONST.LIMITER.HYST_KMH) then
    local dur = math.min(0.25, math.max(0.08, (dt or 0.016) * 8))
    forceBrakeTick(veh, dur)
    v.limit_on = true
  end
end
end

--if SAVE and SAVE.syncVehicle then
--  SAVE:syncVehicle(id, false)
--end

lastPos   = cur
lastVehId = id
end)

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Shutdown                                                                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

registerForEvent("onShutdown", function()
  setFactInt(FACT_HUD_VISIBLE, 0)
	if REPAIR and REPAIR.reset then REPAIR.reset() end
  if VM_GAS_ECONOMY and VM_GAS_ECONOMY.stop then VM_GAS_ECONOMY.stop() end
  MARKERS.shutdown()
  if SAVE and SAVE.resetRuntime then SAVE:resetRuntime() end
  if priceVisibleLast then
    setFactInt(FACT_HUD_PRICE_VISIBLE, 0)
    priceVisibleLast = false
  end
end) -- end function (anonymous)

-- Public CET API. A table literal avoids another top-level local in this file,
-- which is already at Lua's 200-local limit.
return {
  AddFuelToAllStations = function(liters)
    local amount = math.max(0, math.floor(tonumber(liters) or 10000))
    local count = GAS.addFuelToAllStations(amount)
    print(("[VehicleOdometer] Added %d L to each of %d gas stations.")
      :format(amount, count))
    return count
  end,

  SetStationFuel = function(index, liters)
    local ok, available, capacity = GAS.setStationFuel(index, liters)
    if not ok then
      print(("[VehicleOdometer] Cannot set station %s: %s")
        :format(tostring(index), tostring(available)))
      return false
    end

    print(("[VehicleOdometer] Station %03d set to %d / %d L.")
      :format(math.floor(tonumber(index)), available, capacity))
    return true
  end,

  PrintGasStations = function()
    local stations = GAS.getStationStatus()

    print("+-----+-----------+----------------+----------------+")
    print("| IDX | LOCATIONS | AVAILABLE (L)  | CAPACITY (L)   |")
    print("+-----+-----------+----------------+----------------+")

    for _, station in ipairs(stations) do
      print(("| %03d | %9d | %14d | %14d |"):format(
        station.index,
        station.locations,
        station.available_l,
        station.capacity_l
      ))
    end

    print("+-----+-----------+----------------+----------------+")
    print(("Total stations: %d"):format(#stations))
    return #stations
  end,

  PrintGasEconomy = function(detailed)
    local status = VM_GAS_ECONOMY.getStatus()
    local severity = status.shortage_severity == 2 and "SEVERE"
      or (status.shortage_severity == 1 and "MINOR" or "NORMAL")
    local counts = { city_center = 0, outer_district = 0, offsite = 0 }

    for _, profile in ipairs(status.profiles or {}) do
      counts[profile.profile] = (counts[profile.profile] or 0) + 1
    end

    local supplyText = ("%s (%d h remaining)"):format(
      severity, status.shortage_hours_remaining or 0
    )
    local profileText = ("city=%d / outer=%d / offsite=%d"):format(
      counts.city_center or 0,
      counts.outer_district or 0,
      counts.offsite or 0
    )

    print("+------------------------+-------------------------------+")
    print(("| %-22s | %-29s |"):format("GAS ECONOMY", "VALUE"))
    print("+------------------------+-------------------------------+")
    print(("| %-22s | %-29s |"):format(
      "Network fill", ("%.1f%%"):format((status.fill_ratio or 0) * 100)
    ))
    print(("| %-22s | %-29s |"):format(
      "Fuel-pressure premium",
      ("%+.1f%%"):format(((status.price_multiplier or 1) - 1) * 100)
    ))
    print(("| %-22s | %-29s |"):format("Supply state", supplyText))
    print(("| %-22s | %-29s |"):format("Station profiles", profileText))
    print("+------------------------+-------------------------------+")

    if detailed then
      print("+-----+----------------+--------+--------+---------+")
      print("| IDX | PROFILE        | URBAN% | TARGET | DELIV.  |")
      print("+-----+----------------+--------+--------+---------+")
      for _, profile in ipairs(status.profiles or {}) do
        print(("| %03d | %-14s | %5.0f%% | %5.0f%% | %5d h |"):format(
          profile.index,
          profile.profile,
          profile.urbanity * 100,
          profile.target_fill * 100,
          profile.delivery_interval
        ))
      end
      print("+-----+----------------+--------+--------+---------+")
    end

    return status
  end,

  TriggerGasShortage = function(severity, hours)
    local ok, level, untilHour = VM_GAS_ECONOMY.triggerShortage(severity, hours)
    if not ok then
      print("[VehicleOdometer] Could not persist the gas supply state.")
      return false
    end
    local label = level == 2 and "SEVERE" or (level == 1 and "MINOR" or "NORMAL")
    print(("[VehicleOdometer] Gas supply state: %s; until economy hour %d.")
      :format(label, untilHour))
    return level
  end,

  SimulateGasEconomyHours = function(hours)
    local processed = VM_GAS_ECONOMY.simulateHours(hours)
    if processed <= 0 then
      print("[VehicleOdometer] No gas-economy hours were simulated.")
      return 0
    end
    local base = SETTINGS.price_epl or DEFAULT_PRICE_EPL
    local previousMarket = VM_GAS_ECONOMY.getMarketPrice(base)
    local market = SETTINGS.price_dyn_enable
      and nextDynamicPrice(base, previousMarket) or base
    applyFuelPrice(market, { persist_base = false })
    pushPriceFact(true)
    print(("[VehicleOdometer] Simulated %d gas-economy hours."):format(processed))
    return processed
  end
}
