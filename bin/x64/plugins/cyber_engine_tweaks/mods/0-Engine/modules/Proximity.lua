-- Proximity.lua - distance queries and managed enter/exit zones

local Logger = require('modules/Logger')

local Proximity = { version = '0.2.0' }

local zones = {}
local zoneCounter = 0
local playerPos = nil

local function getSourceLabel(fn)
    if type(fn) ~= "function" then return "unknown" end
    if not debug or not debug.getinfo then return "unknown" end
    local ok, info = pcall(debug.getinfo, fn, "S")
    if not ok or not info or not info.source then return "unknown" end
    local modName = info.source:match("[/\\]mods[/\\]([^/\\]+)")
    if modName then return modName end
    return info.short_src or "unknown"
end

---Sets the current player position (called by Engine each frame)
---@param pos Vector4
function Proximity.SetPlayerPos(pos)
    playerPos = pos
end

---Computes squared distance between player and a point (avoids sqrt)
---@param x number
---@param y number
---@param z number
---@return number|nil squared distance, or nil if no player position
local function distanceSq(x, y, z)
    if not playerPos then return nil end
    local dx = playerPos.x - x
    local dy = playerPos.y - y
    local dz = playerPos.z - z
    return dx * dx + dy * dy + dz * dz
end

---Returns the distance from the player to a world point
---@param x number
---@param y number
---@param z number
---@return number distance in meters, or -1 if player position unavailable
function Proximity.DistanceTo(x, y, z)
    local sq = distanceSq(x, y, z)
    if not sq then return -1 end
    return math.sqrt(sq)
end

---Returns whether the player is within radius of a world point
---@param x number
---@param y number
---@param z number
---@param radius number
---@return boolean
function Proximity.IsNear(x, y, z, radius)
    local sq = distanceSq(x, y, z)
    if not sq then return false end
    return sq <= (radius * radius)
end

---Registers a proximity zone
---@param config table { id, x, y, z, radius, onEnter, onExit, onTick, throttle, source }
---@return table handle with unregister method
function Proximity.RegisterZone(config)
    if type(config) ~= "table" then return { unregister = function() end } end

    zoneCounter = zoneCounter + 1
    local zoneId = config.id or ("zone_" .. zoneCounter)
    local throttle = config.throttle or 5

    local zone = {
        id = zoneId,
        x = config.x or 0,
        y = config.y or 0,
        z = config.z or 0,
        radius = config.radius or 10,
        radiusSq = (config.radius or 10) * (config.radius or 10),
        onEnter = config.onEnter,
        onExit = config.onExit,
        onTick = config.onTick,
        throttle = throttle,
        isInside = false,
        internalId = zoneCounter,
        source = config.source or getSourceLabel(config.onEnter or config.onExit or config.onTick)
    }

    zones[zoneCounter] = zone

    local capturedId = zoneCounter
    return {
        id = zoneId,
        unregister = function()
            zones[capturedId] = nil
        end
    }
end

---Updates all registered zones (called from Engine frame loop)
---@param frame number current frame count
function Proximity.Update(frame)
    if not playerPos then return end

    for _, zone in pairs(zones) do
        if frame % zone.throttle == 0 then
            local sq = distanceSq(zone.x, zone.y, zone.z)
            if sq then
                local inside = sq <= zone.radiusSq

                if inside and not zone.isInside then
                    zone.isInside = true
                    if zone.onEnter then
                        local ok, err = pcall(zone.onEnter, math.sqrt(sq))
                        if not ok then
                            Logger.Log("0-Engine", "Proximity: onEnter error for zone '" .. zone.id .. "': " .. tostring(err), "error")
                        end
                    end
                elseif not inside and zone.isInside then
                    zone.isInside = false
                    if zone.onExit then
                        local ok, err = pcall(zone.onExit, math.sqrt(sq))
                        if not ok then
                            Logger.Log("0-Engine", "Proximity: onExit error for zone '" .. zone.id .. "': " .. tostring(err), "error")
                        end
                    end
                end

                if inside and zone.onTick then
                    local ok, err = pcall(zone.onTick, math.sqrt(sq))
                    if not ok then
                        Logger.Log("0-Engine", "Proximity: onTick error for zone '" .. zone.id .. "': " .. tostring(err), "error")
                    end
                end
            end
        end
    end
end

---Returns the number of registered zones
---@return number
function Proximity.GetZoneCount()
    local count = 0
    for _ in pairs(zones) do count = count + 1 end
    return count
end

---Returns info about registered zones for debug display
---@return table[] { id, radius, isInside, source }
function Proximity.GetZones()
    local info = {}
    for _, zone in pairs(zones) do
        table.insert(info, { id = zone.id, radius = zone.radius, isInside = zone.isInside, source = zone.source })
    end
    return info
end

---Resets all zones (called on player invalidation)
function Proximity.Reset()
    playerPos = nil
    for _, zone in pairs(zones) do
        zone.isInside = false
    end
end

return Proximity