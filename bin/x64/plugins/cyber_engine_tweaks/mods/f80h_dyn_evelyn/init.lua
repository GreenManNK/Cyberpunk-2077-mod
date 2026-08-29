---------------------------------------------------------
-- Dynamic Evelyn Parker
-- Clean per-NPC implementation (no UI, no JSON)
---------------------------------------------------------

local DEBUG_MODE = false

local Cron        = dofile("Cron.lua")
local GameSession = dofile("GameSession.lua")
local GameUI      = dofile("GameUI.lua")

---------------------------------------------------------
-- SCRIPT STATE
---------------------------------------------------------
local scriptActive = false
local scanTimer    = 0
local scanInterval = 3.0   -- seconds

---------------------------------------------------------
-- EVELYN CONFIG (HARD-CODED)
---------------------------------------------------------
local EVELYN_MATCH      = "evelyn"
local EVELYN_APPEARANCE = "evelyn_default_nocoat"

---------------------------------------------------------
-- RUNTIME STATE
---------------------------------------------------------
local evelynEntity    = nil
local evelynReady     = false
local activationTimer = nil
local switchTimer     = nil

---------------------------------------------------------
-- DEBUG
---------------------------------------------------------
local function debug(msg)
    if DEBUG_MODE then
        print("[DynamicEvelyn] " .. msg)
    end
end

---------------------------------------------------------
-- SAFE APPEARANCE GET
---------------------------------------------------------
local function safeGetAppearance(entity)
    if not entity then return nil end
    local ok, app = pcall(function()
        local x = entity:GetCurrentAppearanceName()
        return x and x.value or nil
    end)
    return ok and app or nil
end

---------------------------------------------------------
-- QUEST FACT CHECK
---------------------------------------------------------
local function areFactsTrue()
    local qs = Game.GetQuestsSystem()
    if not qs then return false end

    local sits = tonumber(qs:GetFactStr("q004_03_player_sits") or 0)
    local done = tonumber(qs:GetFactStr("q004_done") or 0)

    return sits >= 1 and done == 0
end

---------------------------------------------------------
-- SAFE APPEARANCE SWITCH (DELAYED)
---------------------------------------------------------
local function scheduleSwitch()
    if switchTimer then return end

    switchTimer = Cron.After(0.5, function()
        if evelynEntity then
            evelynEntity:ScheduleAppearanceChange(EVELYN_APPEARANCE)
            debug("Applied Evelyn appearance")
        end
        switchTimer = nil
    end)
end

---------------------------------------------------------
-- MAIN UPDATE LOOP
---------------------------------------------------------
registerForEvent("onUpdate", function(delta)
    -- Cron must always tick
    Cron.Update(delta)

    -- Guards
    if not scriptActive then return end
    if not evelynEntity or not evelynReady then return end
    if GameSession.IsPaused() then return end
    if GameSession.IsDead() then return end
    if GameUI.IsFastTravel() then return end
    if GameUI.IsPhoto() then return end

    -- Throttle
    scanTimer = scanTimer + delta
    if scanTimer < scanInterval then return end
    scanTimer = 0

    if not areFactsTrue() then return end

    local current = safeGetAppearance(evelynEntity)
    if current and current ~= EVELYN_APPEARANCE then
        scheduleSwitch()
    end
end)

---------------------------------------------------------
-- INIT & ENTITY OBSERVERS
---------------------------------------------------------
registerForEvent("onInit", function()
    debug("Dynamic Evelyn initialized")

    -- Session guards
    GameSession.OnStart(function()
        scriptActive = true
    end)

    GameSession.OnEnd(function()
        scriptActive = false
        scanTimer = 0
    end)

    if GameSession.IsLoaded() then
        scriptActive = true
    end

    -----------------------------------------------------
    -- NPC SPAWN
    -----------------------------------------------------
    ObserveAfter("NPCPuppet", "OnGameAttached", function(self)
        local rid = self:GetRecordID()
        if not rid then return end

        if tostring(rid):lower():find(EVELYN_MATCH) then
            evelynEntity = self
            evelynReady  = false

            activationTimer = Cron.After(1.5, function()
                evelynReady = true
                activationTimer = nil
                debug("Evelyn ready")
            end)

            debug("Evelyn attached")
        end
    end)

    -----------------------------------------------------
    -- NPC DESPAWN (NO REVERT)
    -----------------------------------------------------
    ObserveAfter("NPCPuppet", "OnDetach", function(self)
        if self ~= evelynEntity then return end

        evelynEntity = nil
        evelynReady  = false

        if activationTimer then
            Cron.Halt(activationTimer)
            activationTimer = nil
        end

        if switchTimer then
            Cron.Halt(switchTimer)
            switchTimer = nil
        end

        debug("Evelyn detached → runtime cleared")
    end)
end)