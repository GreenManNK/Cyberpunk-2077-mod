-- vm_gas_markers.lua
-- Drops clustered map pins for gas stations (from vm_gas_locations.json)

local M = {
  _cfg = {
    points_path         = "vm_gas_locations.json",
    cluster_radius      = 10.0,
    clampToGround       = true,
    visibleThroughWalls = true,
    trace               = false,
    title               = "CHOOH2 PUMP",
    desc                = "Pay & Refuel",
    caption             = nil,
  },
  _handles = {},
  _lastHash = 0,
  _wm_patched = false,
}

-- ─────────── logging ───────────
local function _log(level, msg)
  local ok, f = pcall(io.open, "VehicleMileage.log", "a")
  local line = string.format("%s [%s] %s", os.date("%Y-%m-%d %H:%M:%S"), level, tostring(msg))
  if ok and f then f:write(line.."\n"); f:close() end
  if level ~= "TRACE" then print("[VM GasMarkers] "..tostring(msg)) end
end
local function TRACE(fmt, ...) if M._cfg.trace then _log("TRACE", string.format(fmt, ...)) end end

-- ─────────── whitelist: show WanderingMerchant under Service Points (and All) ───────────
local function _ensureWMInServicePoints()
  if M._wm_patched then return end
  M._wm_patched = true

  local variant = TweakDBID.new('Mappins.PointOfInterest_WanderingMerchantVariant')

  local function addIfArray(groupFlat)
    local id  = TweakDBID.new(groupFlat)
    local arr = TweakDB:GetFlat(id)
    if type(arr) ~= 'table' then return false end
    local want = tostring(variant)
    for i=1,#arr do if tostring(arr[i]) == want then return true end end
    arr[#arr+1] = variant
    TweakDB:SetFlat(id, arr)
    return true
  end

  -- Ensure visibility where players expect it:
  addIfArray('WorldMap.ServicePointsFilterGroup.mappins')
  addIfArray('WorldMap.AllServicePointsFilterGroup.mappins')
  addIfArray('WorldMap.AllFilterGroup.mappins')
  addIfArray('WorldMap.CommonFilterGroup.mappins')
end

-- ─────────── tiny JSON helpers ───────────
local function _readFile(p)
  local f = io.open(p, "r"); if not f then return nil end
  local s = f:read("*a"); f:close(); return s
end

local function _json_decode(str)
  if type(str) ~= "string" then return nil end
  local pos = 1
  local function skip() local _, e = str:find("^[ \t\r\n]*", pos); pos = (e or pos-1) + 1 end
  local function parse()
    skip(); local c = str:sub(pos,pos)
    if c == "{" then
      pos=pos+1; skip(); local t={}
      if str:sub(pos,pos) == "}" then pos=pos+1; return t end
      while true do
        skip(); if str:sub(pos,pos) ~= '"' then return nil end
        pos=pos+1; local ss=pos
        while true do local ch=str:sub(pos,pos); if ch=='"' then break elseif ch=='\\' then pos=pos+1 end; pos=pos+1 end
        local key=str:sub(ss,pos-1):gsub("\\n","\n"):gsub('\\"','"'):gsub('\\\\','\\')
        pos=pos+1; skip(); if str:sub(pos,pos) ~= ":" then return nil end
        pos=pos+1; local val=parse(); if val==nil and str:sub(pos-4,pos-1)~="null" then return nil end
        t[key]=val; skip(); local ch=str:sub(pos,pos)
        if ch=="}" then pos=pos+1; return t elseif ch=="," then pos=pos+1 else return nil end
      end
    elseif c == "[" then
      pos=pos+1; skip(); local a={}
      if str:sub(pos,pos) == "]" then pos=pos+1; return a end
      local i=1
      while true do
        local v=parse(); if v==nil and str:sub(pos-4,pos-1)~="null" then return nil end
        a[i]=v; i=i+1; skip(); local ch=str:sub(pos,pos)
        if ch=="]" then pos=pos+1; return a elseif ch=="," then pos=pos+1 else return nil end
      end
    elseif c == '"' then
      pos=pos+1; local ss=pos
      while true do local ch=str:sub(pos,pos); if ch=='"' then break elseif ch=='\\' then pos=pos+1 end; pos=pos+1 end
      local s=str:sub(ss,pos-1); pos=pos+1
      return s:gsub("\\n","\n"):gsub('\\"','"'):gsub('\\\\','\\')
    else
      local lit = str:match("^[^,%]%}%s]+", pos); if not lit then return nil end
      pos = pos + #lit
      if lit=="true" then return true elseif lit=="false" then return false elseif lit=="null" then return nil end
      return tonumber(lit)
    end
  end
  return parse()
end

-- ─────────── clustering (XY only) ───────────
local function _clusterXY(points, radius)
  radius = tonumber(radius) or 0
  if radius <= 0 then return points end
  local used, out = {}, {}
  local r2 = radius * radius
  for i=1,#points do
    if not used[i] then
      local sx, sy, sz, n = points[i].x, points[i].y, points[i].z or 0, 1
      used[i] = true
      local changed = true
      while changed do
        changed = false
        local cx, cy = sx/n, sy/n
        for j=1,#points do
          if not used[j] then
            local dx = points[j].x - cx
            local dy = points[j].y - cy
            if (dx*dx + dy*dy) <= r2 then
              used[j] = true
              sx, sy, sz, n = sx + points[j].x, sy + points[j].y, sz + (points[j].z or 0), n + 1
              changed = true
            end
          end
        end
      end
      out[#out+1] = { x = sx/n, y = sy/n, z = sz/n }
    end
  end
  return out
end

-- ─────────── points + hash ───────────
local function _loadPoints(path)
  local raw = _readFile(path)
  if not raw or #raw == 0 then return {} end
  local t = _json_decode(raw)
  if type(t) ~= "table" then return {} end
  local out = {}
  for i=1,#t do
    local p = t[i]
    if type(p) == "table" and tonumber(p.x) and tonumber(p.y) then
      out[#out+1] = { x = tonumber(p.x), y = tonumber(p.y), z = tonumber(p.z) or 0 }
    end
  end
  return out
end

local function _hashPoints(pts)
  local h = 0
  for i=1,#pts do
    h = h + math.floor((pts[i].x or 0) * 1000)
          + 31  * math.floor((pts[i].y or 0) * 1000)
          + 997 * math.floor((pts[i].z or 0) * 1000)
  end
  return h
end

-- ─────────── register/unregister ───────────
local function _unregisterAll(self)
  local ms = Game.GetMappinSystem()
  if not ms then self._handles = {}; return end
  for _, h in ipairs(self._handles) do
    pcall(function() ms:UnregisterMappin(h) end)
  end
  self._handles = {}
end

-- ─────────── spawn (static + caption) ───────────
local function _spawnOne(self, pos, idx)
  local ms = Game.GetMappinSystem(); if not ms then return nil end

  local md
  pcall(function() md = NewObject('gamemappinsMappinData') end)
  if not md then md = NewObject('MappinData') end

  md.mappinType = TweakDBID.new('Mappins.DefaultStaticMappin')
  local variant = (gamemappinsMappinVariant and gamemappinsMappinVariant.WanderingMerchantVariant)
               or (gamedataMappinVariant    and gamedataMappinVariant.WanderingMerchantVariant)
  if variant then md.variant = variant end

  -- default caption (safe)
  local title = self._cfg.title
  local desc  = self._cfg.desc

  -- optional caption override
  if type(self._cfg.caption) == "function" then
    local ok, t, d = pcall(self._cfg.caption, pos, idx)
    if ok then
      if t ~= nil then title = t end
      if d ~= nil then desc  = d end
    else
      _log("WARN", "caption() failed: "..tostring(t))
    end
  end

  md.debugCaption = string.format("VM_VehicleMileage|%s|%s",
    tostring(title):gsub("|","/"),
    tostring(desc):gsub("|","/"))

  -- flags
  pcall(function() md.active = true end)
  pcall(function() md.visibleThroughWalls = self._cfg.visibleThroughWalls ~= false end)
  pcall(function() md.clampToGround      = self._cfg.clampToGround       ~= false end)

  local v4 = Vector4.new(pos.x, pos.y, pos.z or 0.0, 1.0)

  local id
  local ok = pcall(function() id = ms:RegisterMappin(md, v4) end) -- legacy
  if not ok or not id then pcall(function() id = ms:CreateMappin(md, v4, nil) end) end -- 2.0+

  if id then
    pcall(function() ms:SetMappinActive(id, true) end)
    pcall(function() ms:RevealMappin(id, true)   end)
    pcall(function() ms:RefreshMappin(id)        end)
    if self._cfg.trace then _log("TRACE", "spawned id="..tostring(id).." variant=WanderingMerchantVariant") end
    return id
  end
  return nil
end

-- ─────────── API ───────────
function M.setup(opts)
  opts = opts or {}
  for k,v in pairs(opts) do M._cfg[k] = v end
  pcall(_ensureWMInServicePoints)
  M:refresh(true)
  TRACE("using points file: %s; clamp=%s", tostring(M._cfg.points_path), tostring(M._cfg.clampToGround ~= false))
end

function M.refresh(force)
  local pts = _loadPoints(M._cfg.points_path or "vm_gas_locations.json")
  local clustered = _clusterXY(pts, M._cfg.cluster_radius or 0)
  local newHash = _hashPoints(clustered)

  if not force and newHash == M._lastHash and #M._handles > 0 then
    TRACE("refresh skipped (same hash)")
    return
  end

  _unregisterAll(M)
  M._lastHash = newHash

  local ms = Game.GetMappinSystem()
  if not ms then
    _log("WARN", "MappinSystem not available yet; will retry later.")
    return
  end

  for i=1,#clustered do
    local h = _spawnOne(M, clustered[i], i)
    if h then table.insert(M._handles, h) end
  end

  --_log("INFO", ("Gas markers: %d points → %d clusters → %d pins")
  --   :format(#pts, #clustered, #M._handles))
end

function M.shutdown()
  _unregisterAll(M)
  TRACE("shutdown done")
end

return M
