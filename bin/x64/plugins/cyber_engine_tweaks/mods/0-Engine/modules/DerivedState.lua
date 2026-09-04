-- DerivedState.lua - engine-call state cache (weapon, time, district, cover, etc.)
-- CET-native version: all state polled directly via CET calls, no RedScript dependency.
-- 0.18.0: throttled expensive polls (hasWeapon, isInWorkspot, isDead, cover) to every 6 frames

local Logger = require('modules/Logger')
local DerivedState = { version = '0.5.0-CET' }

local cached = {
    weaponType = "None",
    timeOfDay = 0,
    isDead = false,
    isLoading = false,
    district = "Unknown",
    lookPitch = 0,
    hasWeapon = false,
    isInWorkspot = false,
    cover = {
        direction = "None",
        isLeaning = false
    }
}

-- Internal cache for optimization
local lastWeaponRecordId = nil
local districtCheckInterval = 30
local districtFrameCounter = 0
local lastDistrict = nil
local Events = nil

-- throttle interval for expensive system polls (hasWeapon, isInWorkspot, isDead, cover)
-- 6 frames = ~10Hz at 60fps - fast enough for gameplay, saves 5 pcall+system calls on most frames
local pollThrottle = 6
local pollFrameCounter = 0

-- Cached TweakDB ID (avoid per-frame allocation)
local weaponSlotID = nil

---Resolves the current district name via PreventionSystem
---@return string
local function resolveDistrict()
    local ok, result = pcall(function()
        local container = Game.GetScriptableSystemsContainer()
        if not container then return nil end

        local preventionSystem = container:Get("PreventionSystem")
        if not preventionSystem then return nil end

        local districtManager = preventionSystem.districtManager
        if not districtManager then return nil end

        local currentDistrict = districtManager:GetCurrentDistrict()
        if not currentDistrict then return nil end

        local record = currentDistrict:GetDistrictRecord()
        if not record then return nil end

        return record:EnumName()
    end)

    if ok and result then
        return tostring(result)
    end
    return nil
end

---@param player userdata
---@return string
local function resolveWeaponType(player)
    local ok, result = pcall(function()
        local weapon = player:GetActiveWeapon()
        if not weapon then
            lastWeaponRecordId = nil
            return "None"
        end

        local record = weapon:GetWeaponRecord()
        if not record then
            lastWeaponRecordId = nil
            return "Unknown"
        end

        -- Optimization: avoid tostring / method calls if record hasn't changed
        local recordId = record:GetID()
        local recordKey = tostring(recordId)

        if lastWeaponRecordId == recordKey then
            return cached.weaponType
        end

        lastWeaponRecordId = recordKey

        -- Prefer WeaponType if available, otherwise fall back to ItemType (best effort).
        local weaponTypeFn = record.WeaponType
        if type(weaponTypeFn) == "function" then
            local ok2, res = pcall(function()
                return record:WeaponType()
            end)

            if ok2 and res and res.value ~= nil then
                return tostring(res.value)
            end
        end

        local itemTypeFn = record.ItemType
        if type(itemTypeFn) == "function" then
            local ok2, res = pcall(function()
                return record:ItemType()
            end)

            if ok2 and res and res.value ~= nil then
                return tostring(res.value)
            end
        end

        return "Unknown"
    end)

    if ok then return result end
    lastWeaponRecordId = nil
    return "None"
end

---Resolves the camera look pitch in degrees (inner, for pcall)
local function resolveLookPitchInner()
    local camSys = Game.GetCameraSystem()
    if not camSys then return 0 end
    local fwd = camSys:GetActiveCameraForward()
    if not fwd then return 0 end
    local clamped = math.max(-1.0, math.min(1.0, fwd.z))
    return math.deg(math.asin(clamped))
end

---Resolves the camera look pitch in degrees
---@return number pitch in degrees (negative = looking down)
local function resolveLookPitch()
    local ok, result = pcall(resolveLookPitchInner)
    return ok and result or 0
end

---Checks if the player has a weapon in the right hand slot
---@param player userdata
---@return boolean
local function resolveHasWeapon(player)
    local ok, result = pcall(function()
        if not weaponSlotID then
            weaponSlotID = TweakDBID.new("AttachmentSlots.WeaponRight")
        end
        local ts = Game.GetTransactionSystem()
        if not ts then return false end
        return ts:GetItemInSlot(player, weaponSlotID) ~= nil
    end)
    return ok and result or false
end

---Checks if the player is in an active workspot
---@param player userdata
---@return boolean
local function resolveIsInWorkspot(player)
    local ok, result = pcall(function()
        local ws = Game.GetWorkspotSystem()
        if not ws then return false end
        return ws:IsActorInWorkspot(player)
    end)
    return ok and result or false
end

---Resolves the cover direction via PlayerObstacleSystem
---@param player userdata
---@return string
local function resolveCoverDirection(player)
    local ok, result = pcall(function()
        local spatialSys = Game.GetSpatialQueriesSystem()
        if not spatialSys then return "None" end
        local obstacleSys = spatialSys:GetPlayerObstacleSystem()
        if not obstacleSys then return "None" end
        local dir = obstacleSys:GetCoverDirection(player)
        local dirStr = tostring(dir and dir.value or dir)
        if dirStr == "Left" then return "Left" end
        if dirStr == "Right" then return "Right" end
        if dirStr == "Up" then return "Up" end
        return "None"
    end)
    return ok and result or "None"
end

---Initializes the DerivedState module with event bus reference
---@param events table
function DerivedState.Init(events)
    Events = events
end

---Updates the derived state cache
---@param player userdata
function DerivedState.Update(player)
    if not player then return end

    -- Camera look pitch (every frame for camera mod compatibility)
    cached.lookPitch = resolveLookPitch()

    -- throttled polls: hasWeapon, isInWorkspot, isDead, cover, weaponType
    -- these hit engine systems via pcall - expensive relative to blackboard reads.
    -- 6-frame interval = ~10Hz at 60fps, plenty fast for gameplay detection.
    pollFrameCounter = pollFrameCounter + 1
    if pollFrameCounter >= pollThrottle then
        pollFrameCounter = 0

        -- Weapon type (optimized: skips if record ID unchanged)
        cached.weaponType = resolveWeaponType(player)

        -- Player death state
        local ok, dead = pcall(player.IsDeadNoStatPool, player)
        cached.isDead = ok and dead or false

        -- Has weapon in hand
        cached.hasWeapon = resolveHasWeapon(player)

        -- In workspot
        cached.isInWorkspot = resolveIsInWorkspot(player)

        -- Cover direction
        local coverDir = resolveCoverDirection(player)
        if coverDir ~= cached.cover.direction then
            cached.cover.direction = coverDir
            cached.cover.isLeaning = (coverDir ~= "None")
            if Events and Events.CoverDirectionChanged then
                Events.CoverDirectionChanged:trigger(coverDir)
            end
        end
    end

    -- Throttled updates (every ~30 frames): timeOfDay + district
    districtFrameCounter = districtFrameCounter + 1
    if districtFrameCounter >= districtCheckInterval then
        districtFrameCounter = 0

        -- Time of day (hours as float, e.g. 14.5 = 2:30 PM)
        local todOk, tod = pcall(function()
            local timeSystem = Game.GetTimeSystem()
            if not timeSystem then return nil end
            local gameTime = timeSystem:GetGameTime()
            if not gameTime then return nil end
            return GameTime.Hours(gameTime) + (GameTime.Minutes(gameTime) / 60.0)
        end)
        if todOk and tod then
            cached.timeOfDay = tod
        end

        -- District
        local district = resolveDistrict()
        if district then
            cached.district = district
            if district ~= lastDistrict then
                lastDistrict = district
                if Events and Events.DistrictChanged then
                    Events.DistrictChanged:trigger(district)
                end
            end
        end
    end
end

---Updates loading state (called from init.lua with session info)
---@param loading boolean
function DerivedState.SetLoading(loading)
    cached.isLoading = loading == true
end

---Returns the cached state table
---@return table
function DerivedState.Get()
    return cached
end

---Resets the derived state cache
function DerivedState.Reset()
    cached.weaponType = "None"
    cached.timeOfDay = 0
    cached.isDead = false
    cached.isLoading = false
    cached.district = "Unknown"
    cached.lookPitch = 0
    cached.hasWeapon = false
    cached.isInWorkspot = false
    cached.cover.direction = "None"
    cached.cover.isLeaning = false
    lastWeaponRecordId = nil
    lastDistrict = nil
    districtFrameCounter = 0
    pollFrameCounter = 0
end

return DerivedState
