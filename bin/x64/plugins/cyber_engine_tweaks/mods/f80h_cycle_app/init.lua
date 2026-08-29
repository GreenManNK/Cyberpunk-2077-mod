local lastEntity = nil
local switchCount = 0

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

    local success = target:ScheduleAppearanceChange(appearance)
end)