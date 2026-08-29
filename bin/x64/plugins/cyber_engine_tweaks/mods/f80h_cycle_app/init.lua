-- Shared Variables for the Randomizer
local lastEntity = nil
local switchCount = 0

---------------------------------------------------------
-- Helper Functions
---------------------------------------------------------

local function getCurrentHour()
    local ts = Game.GetTimeSystem()
    if not ts then return -1 end
    local gt = ts:GetGameTime()
    return gt and gt:Hours() or -1
end

-- EXACT working weather detection from your script
local function getCurrentWeather()
    local ws = Game.GetWeatherSystem()
    if not ws then return "unknown" end

    local state = ws:GetWeatherState()

    -- Your original working method (no modifications)
    if state and state.name and state.name.value then
        return tostring(state.name.value)
    end

    return "unknown"
end

---------------------------------------------------------
-- HOTKEY 1: Randomize Appearance
---------------------------------------------------------

registerHotkey("RandomNPCApp", "Randomize NPC Appearance", function()
    local player = Game.GetPlayer()
    local ts = Game.GetTargetingSystem()
    local target = ts and ts:GetLookAtObject(player, false, false)

    if not target or not target:IsA("NPCPuppet") then
        print("[RandomApp] No NPC targeted.")
        return
    end

    if target ~= lastEntity then
        switchCount = 0
        lastEntity = target
    end

    local appearance = "random"
    switchCount = switchCount + 1

    target:ScheduleAppearanceChange(appearance)
    print("[RandomApp] Randomized appearance for: " .. tostring(target:GetDisplayName()))
end)

---------------------------------------------------------
-- HOTKEY 2: Debug Inspector
---------------------------------------------------------

registerHotkey("NPCDebug", "Inspect NPC", function()
    local player = Game.GetPlayer()
    local ts = Game.GetTargetingSystem()
    local target = ts and ts:GetLookAtObject(player, false, false)

    if not target or not target:IsA("NPCPuppet") then
        print("[NPCDebug] No NPC targeted.")
        return
    end

    -- Appearance & Location
    local raw = target:GetCurrentAppearanceName()
    local app = raw and raw.value and raw.value:lower() or "unknown"
    local pos = target:GetWorldPosition()

    -- Environment
    local hour = getCurrentHour()
    local weather = getCurrentWeather()

    print("--------------------------------------------------")
    print("NPC: " .. tostring(target:GetDisplayName()))
    print("Appearance: " .. tostring(app))
    print(string.format("Position: X: %.3f | Y: %.3f | Z: %.3f", pos.x, pos.y, pos.z))
    print("Time: " .. tostring(hour) .. ":00")
    print("Weather State: " .. weather)
    print("--------------------------------------------------")
end)