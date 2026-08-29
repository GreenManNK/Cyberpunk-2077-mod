local Cron  = require("modules/external/Cron")

local utils = {}

function utils.toggleHUD(state)
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

function utils.playAudio(name, delay)
    Cron.After(delay or 0, function()
        Game.GetPlayer():QueueEvent(SoundPlayEvent.new({soundName = name}))
    end)
end

function utils.showEffect(name, delay, obj)
    Cron.After(delay or 0, function()
        GameObjectEffectHelper.StartEffectEvent(obj or GetPlayer(), name, true, worldEffectBlackboard.new())
    end)
end

function utils.applyStatus(effect)
    Game.GetStatusEffectSystem():ApplyStatusEffect(GetPlayer():GetEntityID(), effect, GetPlayer():GetRecordID(), GetPlayer():GetEntityID())
end

function utils.removeStatus(effect)
    Game.GetStatusEffectSystem():RemoveStatusEffect(GetPlayer():GetEntityID(), effect)
end

return utils