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
--
-- Compatibility:
-- • Keeps the old public API names used by init.lua.
-- • readKey/writeKey/mintKey/restoreByKey are harmless no-ops now.
-- ============================================================================

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

local function writeFile(path, data)
  if not IO_OK then return false end
  local f = io.open(path, "w")
  if not f then return false end
  f:write(data or "")
  f:close()
  return true
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
  }
end

local function cname(name)
  if CName and CName.new then return CName.new(name) end
  if CName then return CName(name) end
  return name
end

local function getFactInt(name)
  local qs = Game and Game.GetQuestsSystem and Game.GetQuestsSystem()
  if not qs then return 0 end

  -- Preferred for dynamic/custom fact names.
  local okStr, valStr = pcall(function()
    return qs:GetFactStr(tostring(name))
  end)

  if okStr and valStr ~= nil then
    return toInt(valStr)
  end

  -- Fallback for regular CName facts.
  local ok, val = pcall(function()
    return qs:GetFact(cname(name))
  end)

  if ok and type(val) == "number" then
    return toInt(val)
  end

  return 0
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
    return writeFile(self.bikes_cfg_path, raw)
  end

  local raw = json_encode(self._cars_map or {}, 2)
  return writeFile(self.cars_cfg_path, raw)
end

function VM_SAVE:_readVehicleFromFacts(id, facts)
  facts = facts or makeFactKeys(id)

  local initialized = getFactInt(facts.initialized)

  if initialized <= 0 then
    setFactInt(facts.initialized, 1)
    setFactInt(facts.meters, 0)
    setFactInt(facts.fuel_permille, 1000)
    setFactInt(facts.oil_deci_c, 200)
    setFactInt(facts.stalled, 0)
    setFactInt(facts.limit_on, 0)
  end

  local meters = math.max(0, getFactInt(facts.meters))
  local fuel   = clamp(getFactInt(facts.fuel_permille), 0, 1000) / 1000.0
  local oil    = clamp(getFactInt(facts.oil_deci_c), -500, 3000) / 10.0

  local v = {
    meters   = meters,
    fuel_pct = fuel,
    oil_temp = oil,
    stalled  = getFactInt(facts.stalled) > 0,
    limit_on = getFactInt(facts.limit_on) > 0,
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

  return table.concat({
    tostring(toInt(meters)),
    tostring(toInt(fuel)),
    tostring(toInt(oil)),
    tostring(stalled),
    tostring(limitOn),
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

  setFactInt(facts.initialized, 1)
  setFactInt(facts.meters, meters)
  setFactInt(facts.fuel_permille, toInt(fuel))
  setFactInt(facts.oil_deci_c, toInt(oil))
  setFactInt(facts.stalled, v.stalled and 1 or 0)
  setFactInt(facts.limit_on, v.limit_on and 1 or 0)

  self._lastSnap[id] = snap
  return true
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

function VM_SAVE:_reloadConfigMaps()
  self._cars_map = select(1, readMap(self.cars_cfg_path))
  self._bikes_map = select(1, readMap(self.bikes_cfg_path))
  self:_loadAllConfiguredVehicles()
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

  VM_SAVE.key = 1
  VM_SAVE.dirty = false
  VM_SAVE:_reloadConfigMaps()
end

function VM_SAVE:onPlayerControl()
  self.key = 1
  self.dirty = false
  self:_reloadConfigMaps()
end

function VM_SAVE:onUpdate(dt)
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
  end

  return v
end

function VM_SAVE:syncVehicle(id, force)
  id = cleanKey(id) or tostring(id or "")
  if id == "" then return false end

  local v = self.data.vehicles[id]
  if type(v) ~= "table" then return false end

  return self:_writeVehicleFacts(id, v, force == true)
end

function VM_SAVE:syncAll(force)
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
  self:onPlayerControl()
  return true
end

function VM_SAVE:ensureCategoryConfigs(_, fallbackCar, fallbackBike)
  self.CFG = self.CFG or {}
  self.CFG.car = fallbackCar or { tank_l = 40, l100km = 12 }
  self.CFG.bike = fallbackBike or { tank_l = 18, l100km = 6 }
  return self.CFG
end

return VM_SAVE