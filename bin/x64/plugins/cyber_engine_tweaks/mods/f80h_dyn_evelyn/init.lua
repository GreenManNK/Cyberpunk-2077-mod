---------------------------------------------------------
-- Dynamic Evelyn Parker
-- Per-NPC implementation + Native Settings + JSON
---------------------------------------------------------

local DEBUG_MODE  = false
local CONFIG_PATH = "DynamicEvelyn.json"

local Cron        = dofile("Cron.lua")
local GameSession = dofile("GameSession.lua")
local GameUI      = dofile("GameUI.lua")

---------------------------------------------------------
-- SETTINGS (persisted)
---------------------------------------------------------
local settings = {
    enabled = true
}

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
-- SETTINGS SAVE / LOAD
---------------------------------------------------------
local function saveSettings()
    local data = {
        enabled = settings.enabled and true or false
    }

    local f = io.open(CONFIG_PATH, "w")
    if not f then
        print("[DynamicEvelyn] ERROR: Could not write " .. CONFIG_PATH)
        return
    end

    f:write(json.encode(data))
    f:close()
end

local function loadSettings()
    local f = io.open(CONFIG_PATH, "r")
    if not f then
        saveSettings()
        return
    end

    local content = f:read("*a")
    f:close()

    local ok, data = pcall(json.decode, content)
    if not ok or not data then
        print("[DynamicEvelyn] WARNING: Corrupted " .. CONFIG_PATH .. " - recreating")
        saveSettings()
        return
    end

    if data.enabled ~= nil then
        settings.enabled = data.enabled and true or false
    end
end

---------------------------------------------------------
-- RUNTIME RESET (used when disabling / session end)
---------------------------------------------------------
local function resetRuntime()
    evelynEntity = nil
    evelynReady  = false
    scanTimer    = 0

    if activationTimer then
        Cron.Halt(activationTimer)
        activationTimer = nil
    end

    if switchTimer then
        Cron.Halt(switchTimer)
        switchTimer = nil
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
        -- Guard again at execution time
        if not settings.enabled then
            switchTimer = nil
            return
        end

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

    -- Global enable switch
    if not settings.enabled then return end

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

    loadSettings()

    -----------------------------------------------------
    -- NATIVE SETTINGS UI
    -----------------------------------------------------
    local ns = GetMod and GetMod("nativeSettings")
    if ns then
        ns.addTab("/DynamicEvelyn", "f80h Dynamic Evelyn")

        ns.addSwitch(
            "/DynamicEvelyn",
            "Enable Dynamic Evelyn",
            "If enabled, it will remove Evelyns mantle when downstairs.",
            settings.enabled,
            true,
            function(state)
                settings.enabled = state and true or false
                saveSettings()

                -- If disabled, stop everything immediately
                if not settings.enabled then
                    resetRuntime()
                end
            end
        )
    end

    -----------------------------------------------------
    -- Session guards
    -----------------------------------------------------
    GameSession.OnStart(function()
        scriptActive = true
    end)

    GameSession.OnEnd(function()
        scriptActive = false
        resetRuntime()
    end)

    if GameSession.IsLoaded() then
        scriptActive = true
    end

    -----------------------------------------------------
    -- NPC SPAWN
    -----------------------------------------------------
    ObserveAfter("NPCPuppet", "OnGameAttached", function(self)
        if not settings.enabled then return end

        local rid = self:GetRecordID()
        if not rid then return end

        if tostring(rid):lower():find(EVELYN_MATCH) then
            evelynEntity = self
            evelynReady  = false

            if activationTimer then
                Cron.Halt(activationTimer)
                activationTimer = nil
            end

            activationTimer = Cron.After(1.5, function()
                -- Guard in case user disabled during delay
                if not settings.enabled then
                    activationTimer = nil
                    return
                end

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

        resetRuntime()
        debug("Evelyn detached → runtime cleared")
    end)
end)