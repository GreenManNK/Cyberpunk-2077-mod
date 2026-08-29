-- vm_vehicle_ignore.lua
-- =============================================================================
-- VehicleMileage — Simple, persistent ignore list for vehicle labels.
--
-- Purpose
--   Stores a list of vehicle labels that should be ignored by the Odometer/Fuel
--   systems (e.g., quest cars, special-use vehicles). The list is persisted to
--   a JSON file so it survives restarts.
--
-- Storage format
--   vm_vehicle_ignore.json → ["Vehicle.Foo", "Vehicle.Bar", ...]
--
-- Public API
--   M.setup(opts)              -- Initialize; opts.path overrides default file
--   M.isIgnored(label)  -> bool
--   M.add(label)        -> (ok:boolean, msg:string)     -- adds + saves
--   M.remove(label)     -> (ok:boolean, msg:string)     -- removes + saves
--
-- Internal fields
--   M._path  : string   -- JSON file path
--   M._set   : table    -- lookup set { [label]=true }
--   M._list  : array    -- sorted array mirror (for writing)
-- =============================================================================

local M = {
  _path = "vm_vehicle_ignore.json",
  _set  = {},
  _list = {},
}

-- =============================================================================
-- File I/O (minimal, blocking)
-- =============================================================================

-- Read entire file; returns string or nil
local function r(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

-- Write entire file; returns true/false
local function w(path, data)
  local f = io.open(path, "w")
  if not f then return false end
  f:write(data or "")
  f:close()
  return true
end

-- =============================================================================
-- Minimal JSON for an array of strings (no nested structures)
-- =============================================================================

-- Encode: { "a", "b" } → '["a","b"]'
local function jenc(arr)
  local out = {}
  for i, v in ipairs(arr) do
    out[i] = '"' .. tostring(v):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
  end
  return "[" .. table.concat(out, ",") .. "]"
end

-- Decode: '["a","b"]' → { "a", "b" }
-- NOTE: This is intentionally minimal and assumes a simple array of quoted strings.
local function jdec(s)
  local t = {}
  if type(s) ~= "string" then return t end
  for v in s:gmatch('"%s*([^"]-)%s*"') do
    table.insert(t, v)
  end
  return t
end

-- =============================================================================
-- Persistence helpers
-- =============================================================================

-- Rebuild array mirror from set, sort it, and write to disk.
local function save()
  local arr = {}
  for k in pairs(M._set) do
    table.insert(arr, k)
  end
  table.sort(arr)
  M._list = arr
  w(M._path, jenc(arr))
end

-- =============================================================================
-- Public API
-- =============================================================================

-- Initialize module and load existing ignore list (or create an empty file).
--   opts = { path = "custom_path.json" }
function M.setup(opts)
  M._path = (opts and opts.path) or M._path

  local s = r(M._path)
  if not s or #s == 0 then
    -- First run: create an empty array file and clear state.
    w(M._path, "[]")
    M._set, M._list = {}, {}
    return
  end

  -- Load existing list into set + list mirrors.
  local arr = jdec(s)
  M._set = {}
  for _, v in ipairs(arr) do
    M._set[v] = true
  end
  M._list = arr
end

-- Quick lookup: is this label currently ignored?
function M.isIgnored(label)
  label = tostring(label or "")
  return M._set[label] == true
end

-- Add a label to the ignore list (idempotent). Persists to disk.
function M.add(label)
  label = tostring(label or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if label == "" then
    return false, "No vehicle label"
  end
  if M._set[label] then
    return true, ("Already ignored: %s"):format(label)
  end
  M._set[label] = true
  save()
  return true, ("Ignored vehicle: %s"):format(label)
end

-- Remove a label from the ignore list. Persists to disk.
function M.remove(label)
  label = tostring(label or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if not M._set[label] then
    return false, ("Not in ignore list: %s"):format(label)
  end
  M._set[label] = nil
  save()
  return true, ("Removed from ignore: %s"):format(label)
end

return M
