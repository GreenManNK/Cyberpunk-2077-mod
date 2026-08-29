local Cron  = require("modules/external/Cron")
local utils = require("modules/utils/utils")

local workspotUtils = {}

function workspotUtils.toggleHUD(state)
    if state then
        local blackboardDefs = Game.GetAllBlackboardDefs();
        local blackboardPSM = Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), blackboardDefs.PlayerStateMachine);
        blackboardPSM:SetInt(blackboardDefs.PlayerStateMachine.SceneTier, 1, true);
    else
        local blackboardDefs = Game.GetAllBlackboardDefs()
        local blackboardPSM = Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), blackboardDefs.PlayerStateMachine)
        blackboardPSM:SetInt(blackboardDefs.PlayerStateMachine.SceneTier, 4, true)
    end
end

---@param name string Name of the audio to play
---@param delay ? number Delay to apply before playing the audio (default 0)
---@param seekTime ? number Starting time code. Negative number won't have effect (default 0)
---@param intensity ? number Integer indicates number of time the audio will be played to increase intensity (default 1). If set to 0, the sound wont play
function workspotUtils.playAudio(name, delay, seekTime, intensity)
    Cron.After(delay or 0, function()
        utils.playSound(name, Game.GetPlayer(), intensity, seekTime)
    end, nil)
end

---@param name string|CName Name of the effect to play
---@param delay ? number Delay to apply before playing the effect (default 0)
---@param obj ? gameObject Target of the effect (default to PlayerPuppet)
function workspotUtils.showEffect(name, delay, obj)
    Cron.After(delay or 0, function()
        GameObjectEffectHelper.StartEffectEvent(obj or GetPlayer(), name, true, worldEffectBlackboard.new())
    end, nil)
end

function workspotUtils.applyStatus(effect)
    Game.GetStatusEffectSystem():ApplyStatusEffect(GetPlayer():GetEntityID(), effect, GetPlayer():GetRecordID(), GetPlayer():GetEntityID())
end

function workspotUtils.removeStatus(effect)
    Game.GetStatusEffectSystem():RemoveStatusEffect(GetPlayer():GetEntityID(), effect)
end

return workspotUtils