-- vm_save.lua
-- ============================================================================
-- VehicleMileage — Fact-backed save module
--
-- New save model:
-- • No vm_session files.
-- • Per-vehicle runtime values are stored in persistent quest facts.
-- • vm_config_cars.json / vm_config_bikes.json only store vehicle specs
--   and stable fact key names.
--
-- Saved values:
-- • meters        -> integer meters
-- • fuel_pct      -> stored as permille 0..1000
-- • oil_temp      -> stored as deci °C, example 825 = 82.5 °C
-- • stalled       -> 0/1
-- • limit_on      -> 0/1
-- • maintenance_due_m -> absolute odometer meters for the next inspection
--
-- Compatibility:
-- • Keeps the old public API names used by init.lua.
-- • readKey/writeKey/mintKey/restoreByKey are harmless no-ops now.
-- ============================================================================

local CONFIG_BACKUP = require("vm_config_backup")

local VM_SAVE = {
  key             = 1,
  data            = { vehicles = {} },
  dirty           = false,

  warn            = { noSessionDir = false },

  cars_cfg_path   = "vm_config_cars.json",
  bikes_cfg_path  = "vm_config_bikes.json",

  _cars_map       = {},
  _bikes_map      = {},
  _lastSnap       = {},
  _syncAcc        = 0.0,
  _syncInterval   = 2.00,
  _sessionReady   = false,

  -- Maximum number of old vm_session/*.lua files to keep on disk.
  -- Files beyond this cap (oldest by numeric key) are deleted at startup.
  -- Set to 0 to delete ALL legacy session files.
  MAX_SESSION_FILES = 5,
}

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ File helpers                                                              ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local IO_OK = (type(io) == "table") and (type(io.open) == "function")

local function readFile(path)
  if not IO_OK then return nil end
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Tiny JSON                                                                 ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function json_escape(s)
  return tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
end

local function json_encode(v, indent, lvl)
  indent = indent or 0
  lvl = lvl or 0

  local sp  = (indent > 0) and string.rep(" ", indent * lvl) or ""
  local spc = (indent > 0) and string.rep(" ", indent * (lvl + 1)) or ""
  local nl  = (indent > 0) and "\n" or ""
  local sep = (indent > 0) and ",\n" or ","

  local function enc(x, depth)
    local t = type(x)

    if t == "nil" then
      return "null"

    elseif t == "number" then
      return tostring(x)

    elseif t == "boolean" then
      return x and "true" or "false"

    elseif t == "string" then
      return '"' .. json_escape(x) .. '"'

    elseif t == "table" then
      local isArr = true
      local n = 0

      for k, _ in pairs(x) do
        if type(k) ~= "number" then
          isArr = false
          break
        end
        if k > n then n = k end
      end

      if isArr then
        local out = {}
        for i = 1, n do
          out[#out + 1] = enc(x[i], depth + 1)
        end
        return "[" .. table.concat(out, ",") .. "]"
      end

      local out = {}
      local innerSpc = (indent > 0) and string.rep(" ", indent * (depth + 1)) or ""
      local closeSp  = (indent > 0) and string.rep(" ", indent * depth) or ""

      for k, v2 in pairs(x) do
        out[#out + 1] = innerSpc .. '"' .. json_escape(k) .. '": ' .. enc(v2, depth + 1)
      end

      return "{" .. nl .. table.concat(out, sep) .. nl .. closeSp .. "}"
    end

    return '""'
  end

  return enc(v, lvl)
end

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
          if ch == '"' then break end
          if ch == "\\" then pos = pos + 1 end
          pos = pos + 1
        end

        local key = str:sub(ks, pos - 1)
          :gsub("\\n", "\n")
          :gsub('\\"', '"')
          :gsub("\\\\", "\\")

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

      while true do
        local val = parse()
        if val == nil and str:sub(pos - 4, pos - 1) ~= "null" then return nil end

        arr[#arr + 1] = val
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
        if ch == '"' then break end
        if ch == "\\" then pos = pos + 1 end
        pos = pos + 1
      end

      local s = str:sub(ss, pos - 1)
      pos = pos + 1

      return s:gsub("\\n", "\n"):gsub('\\"', '"'):gsub("\\\\", "\\")

    else
      local lit = str:match("^[^,%]%}%s]+", pos)
      if not lit then return nil end

      pos = pos + #lit

      if lit == "true" then return true end
      if lit == "false" then return false end
      if lit == "null" then return nil end

      return tonumber(lit)
    end
  end

  return parse()
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Helpers                                                                   ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

local function clamp(x, lo, hi)
  x = tonumber(x) or 0
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

local function toInt(x)
  x = tonumber(x) or 0
  if x >= 0 then return math.floor(x + 0.5) end
  return math.ceil(x - 0.5)
end

local function cleanKey(k)
  if type(k) ~= "string" then return nil end

  local inner = k:match("%-%-%[%[%s*([^%]]-)%s*%]%]")
  if inner and #inner > 0 then k = inner end

  local veh = k:match("(Vehicle%.[%w_%.%-]+)")
  if veh then k = veh end

  k = k:gsub("^%s+", ""):gsub("%s+$", "")
  if k == "" then return nil end

  return k
end

local function looksLikeBike(label)
  local s = string.lower(tostring(label or ""))
  return (s:find("bike") or s:find("yaiba") or s:find("arch")) ~= nil
end

local function hash32(s)
  s = tostring(s or "")
  local h = 5381

  for i = 1, #s do
    h = ((h * 33) + string.byte(s, i)) % 4294967296
  end

  return math.floor(h)
end

local function makeFactKeys(label)
  local h = string.format("%08x", hash32(label))

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

local function cname(name)
  if CName and CName.new then return CName.new(name) end
  if CName then return CName(name) end
  return name
end

local function getFactInt(name)
  local qs = Game and Game.GetQuestsSystem and Game.GetQuestsSystem()
  if not qs then return 0, false end

  -- Preferred for dynamic/custom fact names.
  local okStr, valStr = pcall(function()
    return qs:GetFactStr(name)
  end)

  if okStr and valStr ~= nil then
    return toInt(valStr), true
  end

  -- Fallback for runtimes that expose GetFact with a CName.
  local ok, val = pcall(function()
    return qs:GetFact(CName.new(name))
  end)

  if ok and type(val) == "number" then
    return toInt(val), true
  end

  -- A failed read is not the same as a real fact value of 0.
  return 0, false
end

local function setFactInt(name, value)
  local qs = Game and Game.GetQuestsSystem and Game.GetQuestsSystem()
  if not qs then return false end

  value = toInt(value)

  -- Preferred for dynamic/custom fact names.
  local okStr = pcall(function()
    qs:SetFactStr(tostring(name), value)
  end)

  if okStr then
    return true
  end

  -- Fallback for regular CName facts.
  local ok = pcall(function()
    qs:SetFact(cname(name), value)
  end)

  return ok
end

local function readMap(path)
  local raw = readFile(path)
  if not raw or #raw == 0 then return {}, raw end

  local t = json_decode(raw)
  if type(t) ~= "table" then return {}, raw end

  return t, raw
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Fact-backed vehicle state                                                 ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

function VM_SAVE:_ensureFactKeys(label, rec)
  if type(rec) ~= "table" then return false end

  local changed = false
  local generated = makeFactKeys(label)

  if type(rec.vm_facts) ~= "table" then
    rec.vm_facts = {}
    changed = true
  end

  for k, v in pairs(generated) do
    if type(rec.vm_facts[k]) ~= "string" or rec.vm_facts[k] == "" then
      rec.vm_facts[k] = v
      changed = true
    end
  end

  return changed
end

function VM_SAVE:_saveConfig(which)
  if which == "bike" then
    local raw = json_encode(self._bikes_map or {}, 2)
    return CONFIG_BACKUP.write(self.bikes_cfg_path, raw)
  end

  local raw = json_encode(self._cars_map or {}, 2)
  return CONFIG_BACKUP.write(self.cars_cfg_path, raw)
end

function VM_SAVE:_readVehicleFromFacts(id, facts)
  if self._sessionReady ~= true then
    return nil
  end

  facts = facts or makeFactKeys(id)

  local initialized, initializedOK = getFactInt(facts.initialized)

  -- Never turn a failed or premature quest-fact read into default values.
  if not initializedOK then
    return nil
  end

  local meters
  local fuelPermille
  local oilDeciC
  local stalledInt
  local limitOnInt
  local maintenanceDueM

  if initialized <= 0 then
    meters       = 0
    fuelPermille = 1000
    oilDeciC     = 200
    stalledInt   = 0
    limitOnInt   = 0
    maintenanceDueM = 0

    -- Write data first and the initialized marker last. If a write fails,
    -- initialization can be retried safely on the next valid session start.
    local writesOK = true
    writesOK = setFactInt(facts.meters, meters) and writesOK
    writesOK = setFactInt(facts.fuel_permille, fuelPermille) and writesOK
    writesOK = setFactInt(facts.oil_deci_c, oilDeciC) and writesOK
    writesOK = setFactInt(facts.stalled, stalledInt) and writesOK
    writesOK = setFactInt(facts.limit_on, limitOnInt) and writesOK
    writesOK = setFactInt(facts.maintenance_due_m, maintenanceDueM) and writesOK
    writesOK = setFactInt(facts.initialized, 1) and writesOK

    if not writesOK then
      return nil
    end
  else
    local metersOK
    local fuelOK
    local oilOK
    local stalledOK
    local limitOnOK
    local maintenanceDueOK

    meters,       metersOK  = getFactInt(facts.meters)
    fuelPermille, fuelOK    = getFactInt(facts.fuel_permille)
    oilDeciC,     oilOK     = getFactInt(facts.oil_deci_c)
    stalledInt,   stalledOK = getFactInt(facts.stalled)
    limitOnInt,   limitOnOK = getFactInt(facts.limit_on)
    maintenanceDueM, maintenanceDueOK = getFactInt(facts.maintenance_due_m)

    if not (metersOK and fuelOK and oilOK and stalledOK and limitOnOK and maintenanceDueOK) then
      return nil
    end
  end

  local v = {
    meters   = math.max(0, meters),
    fuel_pct = clamp(fuelPermille, 0, 1000) / 1000.0,
    oil_temp = clamp(oilDeciC, -500, 3000) / 10.0,
    stalled  = stalledInt > 0,
    limit_on = limitOnInt > 0,
    maintenance_due_m = math.max(0, maintenanceDueM),
    last     = os.time(),

    -- internal helper fields
    _facts   = facts,
    _id      = id,
  }

  self._lastSnap[id] = self:_makeSnap(v)
  return v
end

function VM_SAVE:_makeSnap(v)
  if type(v) ~= "table" then return "" end

  local meters = math.max(0, toInt(v.meters or 0))
  local fuel   = clamp((tonumber(v.fuel_pct) or 1.0) * 1000.0, 0, 1000)
  local oil    = clamp((tonumber(v.oil_temp) or 20.0) * 10.0, -500, 3000)
  local stalled = v.stalled and 1 or 0
  local limitOn = v.limit_on and 1 or 0
  local maintenanceDueM = math.max(0, toInt(v.maintenance_due_m or 0))

  return table.concat({
    tostring(toInt(meters)),
    tostring(toInt(fuel)),
    tostring(toInt(oil)),
    tostring(stalled),
    tostring(limitOn),
    tostring(maintenanceDueM),
  }, "|")
end

function VM_SAVE:_writeVehicleFacts(id, v, force)
  if type(v) ~= "table" then return false end

  local facts = v._facts
  if type(facts) ~= "table" then
    local rec = self:_getOrCreateSpec(id)
    facts = rec and rec.vm_facts or makeFactKeys(id)
    v._facts = facts
  end

  local snap = self:_makeSnap(v)
  if not force and self._lastSnap[id] == snap then
    return true
  end

  local meters = math.max(0, toInt(v.meters or 0))
  local fuel   = clamp((tonumber(v.fuel_pct) or 1.0) * 1000.0, 0, 1000)
  local oil    = clamp((tonumber(v.oil_temp) or 20.0) * 10.0, -500, 3000)
  local maintenanceDueM = math.max(0, toInt(v.maintenance_due_m or 0))

  setFactInt(facts.initialized, 1)
  setFactInt(facts.meters, meters)
  setFactInt(facts.fuel_permille, toInt(fuel))
  setFactInt(facts.oil_deci_c, toInt(oil))
  setFactInt(facts.stalled, v.stalled and 1 or 0)
  setFactInt(facts.limit_on, v.limit_on and 1 or 0)
  setFactInt(facts.maintenance_due_m, maintenanceDueM)

  self._lastSnap[id] = snap
  return true
end

--- Delete old vm_session/*.lua files beyond MAX_SESSION_FILES.
--- CET's Lua sandbox does not provide io.popen, so we cannot enumerate files
--- with 'dir'. Instead we probe sequential numeric keys with io.open, then
--- use _last_key.txt (written by the old save system) to identify which key
--- is the most recently saved — matching the logic in VM_LegacySessionCandidates.
function VM_SAVE:pruneSessionFiles()
  if not IO_OK then return end

  local max   = tonumber(self.MAX_SESSION_FILES) or 5
  local dir   = "vm_session"
  local sep   = package and package.config and package.config:sub(1,1) or "\\"
  local files = {}

  -- Read _last_key.txt to find the most recently written session file.
  -- (Same source VM_LegacySessionCandidates relies on in init.lua.)
  local newestKey = nil
  do
    local f = io.open(dir .. sep .. "_last_key.txt", "r")
    if f then
      local raw = f:read("*a")
      f:close()
      newestKey = tonumber(raw)
    end
  end

  -- Probe keys 1..200; stop after 10 consecutive misses to avoid wasting time.
  local misses = 0
  for key = 1, 200 do
    local path = dir .. sep .. tostring(key) .. ".lua"
    local f = io.open(path, "r")
    if f then
      f:close()
      misses = 0
      files[#files + 1] = { key = key, path = path }
    else
      misses = misses + 1
      if misses >= 10 then break end
    end
  end

  if #files == 0 then return end

  -- Sort: the key from _last_key.txt is definitively newest → goes first.
  -- All other files fall back to key-descending order as a best-effort guess.
  table.sort(files, function(a, b)
    if a.key == newestKey then return true  end
    if b.key == newestKey then return false end
    return a.key > b.key
  end)

  local kept, removed = 0, 0
  for _, f in ipairs(files) do
    if kept < max then
      kept = kept + 1
    else
      local rok = pcall(os.remove, f.path)
      if rok then removed = removed + 1 end
    end
  end

  if removed > 0 then
    print(("[VehicleMileage] Pruned %d old session file(s) from %s%s (kept %d)"):format(
      removed, dir, sep, kept))
  end
end

function VM_SAVE:_loadAllConfiguredVehicles()
  self.data.vehicles = self.data.vehicles or {}

  local changedCars = false
  local changedBikes = false

  self._cars_map = self._cars_map or {}
  self._bikes_map = self._bikes_map or {}

  for rawLabel, rec in pairs(self._cars_map) do
    local id = cleanKey(rawLabel)
    if id and type(rec) == "table" and tonumber(rec.l100km) and tonumber(rec.tank_l) then
      if self:_ensureFactKeys(id, rec) then changedCars = true end
      self.data.vehicles[id] = self:_readVehicleFromFacts(id, rec.vm_facts)
    end
  end

  for rawLabel, rec in pairs(self._bikes_map) do
    local id = cleanKey(rawLabel)
    if id and type(rec) == "table" and tonumber(rec.l100km) and tonumber(rec.tank_l) then
      if self:_ensureFactKeys(id, rec) then changedBikes = true end
      self.data.vehicles[id] = self:_readVehicleFromFacts(id, rec.vm_facts)
    end
  end

  if changedCars then self:_saveConfig("car") end
  if changedBikes then self:_saveConfig("bike") end
end

function VM_SAVE:_reloadConfigMaps(loadFacts)
  self._cars_map = select(1, readMap(self.cars_cfg_path))
  self._bikes_map = select(1, readMap(self.bikes_cfg_path))

  if loadFacts == nil then
    loadFacts = self._sessionReady == true
  end

  if loadFacts then
    self:_loadAllConfiguredVehicles()
  end
end

function VM_SAVE:_getOrCreateSpec(id)
  id = cleanKey(id) or tostring(id or "")
  if id == "" then return nil end

  local isBike = looksLikeBike(id)
  local map = isBike and self._bikes_map or self._cars_map
  local which = isBike and "bike" or "car"

  map = map or {}
  if isBike then
    self._bikes_map = map
  else
    self._cars_map = map
  end

  local rec = map[id]
  local changed = false

  if type(rec) ~= "table" then
    rec = {
      l100km = isBike and 6 or 12,
      tank_l = isBike and 18 or 40,
      oil_opt_min = 80,
      oil_opt_max = isBike and 100 or 120,
    }

    map[id] = rec
    changed = true
  end

  if self:_ensureFactKeys(id, rec) then
    changed = true
  end

  if changed then
    self:_saveConfig(which)
  end

  return rec
end

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ Public API                                                                ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

function VM_SAVE.setup(opts)
  opts = opts or {}

  if type(opts.cars_cfg_path) == "string" and #opts.cars_cfg_path > 0 then
    VM_SAVE.cars_cfg_path = opts.cars_cfg_path
  end

  if type(opts.bikes_cfg_path) == "string" and #opts.bikes_cfg_path > 0 then
    VM_SAVE.bikes_cfg_path = opts.bikes_cfg_path
  end

  VM_SAVE:resetRuntime()

  -- CET onInit can run before a savegame is active. Load only the JSON maps
  -- here; vehicle quest facts are loaded after 0-Engine reports PlayerReady.
  VM_SAVE:_reloadConfigMaps(false)
end

function VM_SAVE:onSessionStart()
  self.key = 1
  self.data = { vehicles = {} }
  self.dirty = false
  self._lastSnap = {}
  self._syncAcc = 0.0
  self._sessionReady = true
  self:_reloadConfigMaps(true)
end

function VM_SAVE:onSessionEnd()
  self:resetRuntime()
end

-- Compatibility alias for older callers.
function VM_SAVE:onPlayerControl()
  self:onSessionStart()
end

function VM_SAVE:onUpdate(dt)
  if self._sessionReady ~= true then
    return
  end
  self._syncAcc = (self._syncAcc or 0.0) + (dt or 0.0)

  if self._syncAcc < (self._syncInterval or 0.20) then
    return
  end

  self._syncAcc = 0.0

  if self.dirty then
    self:syncAll(false)
    self.dirty = false
  end
end

function VM_SAVE:ensureVehicle(id)
  if self._sessionReady ~= true then
    return nil
  end

  id = cleanKey(id) or tostring(id or "")

  if id == "" then
    return nil
  end

  local rec = self:_getOrCreateSpec(id)
  if not rec then return nil end

  local v = self.data.vehicles[id]

  if type(v) ~= "table" then
    v = self:_readVehicleFromFacts(id, rec.vm_facts)
    self.data.vehicles[id] = v
  else
    v._facts = rec.vm_facts
    v._id = id

    v.fuel_pct = clamp(tonumber(v.fuel_pct) or 1.0, 0, 1)

    if v.oil_temp == nil then
      v.oil_temp = 20.0
    end

    if v.meters == nil then
      v.meters = 0
    end

    if v.maintenance_due_m == nil then
      v.maintenance_due_m = 0
    end
  end

  return v
end

function VM_SAVE:syncVehicle(id, force)
  if self._sessionReady ~= true then
    return false
  end

  id = cleanKey(id) or tostring(id or "")
  if id == "" then return false end

  local v = self.data.vehicles[id]
  if type(v) ~= "table" then return false end

  return self:_writeVehicleFacts(id, v, force == true)
end

function VM_SAVE:syncAll(force)
  if self._sessionReady ~= true then
    return false
  end

  local ok = true

  for id, _ in pairs(self.data.vehicles or {}) do
    if not self:syncVehicle(id, force == true) then
      ok = false
    end
  end

  self.dirty = false
  return ok
end

function VM_SAVE:persistCurrent()
  return self:syncAll(true)
end

function VM_SAVE:onSavingComplete(successLike)
  local ok = (type(successLike) == "boolean") and successLike or (successLike ~= false)
  if not ok then return end

  self:syncAll(true)
end

function VM_SAVE:resetRuntime()
  self.key = 1
  self.data = { vehicles = {} }
  self.dirty = false
  self._lastSnap = {}
  self._syncAcc = 0.0
  self._sessionReady = false
end

-- Old session-key API, kept only so init.lua does not break.
function VM_SAVE:readKey()
  return 1
end

function VM_SAVE:writeKey(_)
  return true
end

function VM_SAVE:mintKey()
  return 1
end

function VM_SAVE:restoreByKey(_)
  self:onSessionStart()
  return true
end

function VM_SAVE:ensureCategoryConfigs(_, fallbackCar, fallbackBike)
  self.CFG = self.CFG or {}
  self.CFG.car = fallbackCar or { tank_l = 40, l100km = 12 }
  self.CFG.bike = fallbackBike or { tank_l = 18, l100km = 6 }
  return self.CFG
end

return VM_SAVE
