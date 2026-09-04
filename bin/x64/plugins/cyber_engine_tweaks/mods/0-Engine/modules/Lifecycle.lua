-- Lifecycle.lua - player entity lifecycle (ready/invalidated/recreated).
-- Real session changes are driven by GameSession events; this module only catches
-- transient mid-gameplay player loss.

local Lifecycle = { version = '0.1.1' }

local lastPlayerHash = nil
local playerValid = false
local failFrames = 0
local failThreshold = 30  -- consecutive bad frames before invalidation (~0.5s at 60fps)
                          -- ForceInvalidate() handles real session teardowns; this is only a safety net
                          -- for truly bizarre mid-gameplay entity loss (streaming glitches, etc.)

local warmupFrames = 0
local warmupThreshold = 18  -- consecutive valid frames before we declare ready (~0.3s at 60fps)
                            -- the player entity can be "alive" before subsystems are stable;
                            -- this gives the engine breathing room after session load.
local warmupPlayer = nil    -- preserved player ref during warmup
local warmupHash = nil      -- preserved hash during warmup

local Events = nil
local State = nil
local Logger = nil

---Initializes the Lifecycle module
---@param events table
---@param state table
---@param logger table|nil  optional; accepted for API compat
function Lifecycle.Init(events, state, logger)
    Events = events
    State = state
    Logger = logger
end

---No-op. Retained for API compat with 0.18.x callers.
---@param frame number
function Lifecycle.SetFrame(frame)
end

local function GetPlayerHash(player)
    if not player then return nil end

    local ok, id = pcall(player.GetEntityID, player)
    if not ok or not id then return nil end

    return id.hash
end

---Updates the lifecycle state
function Lifecycle.Update()

    local ok, player = pcall(Game.GetPlayer)
    if not ok then player = nil end

    -- Defensive engine transition protection
    if player then
        local ok2, id = pcall(player.GetEntityID, player)
        if not ok2 or not id then
            player = nil
        end
    end

    local hash = GetPlayerHash(player)

    -- Transient player loss (streaming, chunk loads, menu transitions)
    -- ForceInvalidate() handles real session teardowns; this only catches mid-gameplay entity loss
    if not hash then
        -- Suppress failure accumulation during menus - player entity is temporarily inaccessible
        -- during inventory/map/crafting transitions. Without this guard, opening a menu could
        -- falsely trigger invalidation and force all mods to re-register on close.
        if State.inMenu then
            failFrames = 0
            return
        end

        -- reset warmup if player vanishes during warmup
        if warmupFrames > 0 then
            warmupFrames = 0
            warmupPlayer = nil
            warmupHash = nil
        end

        failFrames = failFrames + 1
        if playerValid and failFrames >= failThreshold then
            playerValid = false
            lastPlayerHash = nil
            failFrames = 0
            State.player:set(nil)
            Events.PlayerInvalidated:trigger()
        end
        return
    end

    failFrames = 0  -- valid frame, reset counter

    -- First acquisition - defer until warmup completes
    if not playerValid then
        -- warmup: accumulate consecutive valid frames before declaring ready
        if warmupFrames == 0 then
            warmupPlayer = player
            warmupHash = hash
        end

        -- if the hash changed mid-warmup, restart (entity got swapped out from under us)
        if hash ~= warmupHash then
            warmupFrames = 0
            warmupPlayer = player
            warmupHash = hash
        end

        warmupFrames = warmupFrames + 1

        if warmupFrames >= warmupThreshold then
            -- warmup complete - engine has had time to stabilize
            playerValid = true
            lastPlayerHash = warmupHash
            State.player:set(warmupPlayer)
            warmupFrames = 0
            warmupPlayer = nil
            warmupHash = nil
            Events.PlayerReady:trigger(player)
        end
        return
    end

    -- Player recreated
    if hash ~= lastPlayerHash then
        lastPlayerHash = hash
        State.player:set(player)
        Events.PlayerRecreated:trigger(player)
    end
end

---Checks if the player entity is currently valid
---@return boolean
function Lifecycle.IsPlayerValid()
    return playerValid
end

---Forces immediate player invalidation without calling Game.GetPlayer().
---Used when the session unloads - avoids touching potentially destroyed game objects.
function Lifecycle.ForceInvalidate()
    -- also kill any in-progress warmup
    warmupFrames = 0
    warmupPlayer = nil
    warmupHash = nil

    if not playerValid then return end
    playerValid = false
    lastPlayerHash = nil
    failFrames = 0
    State.player:set(nil)
    Events.PlayerInvalidated:trigger()
end

return Lifecycle
