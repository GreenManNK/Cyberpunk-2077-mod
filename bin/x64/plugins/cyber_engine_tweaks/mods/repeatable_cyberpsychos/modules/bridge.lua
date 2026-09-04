local Bridge = {}

function Bridge.system()
    local result = nil
    pcall(function()
        result = Game.GetScriptableSystemsContainer():Get("RepeatableCyberpsychosSystem")
    end)
    return result
end

function Bridge.entity(entityID)
    if not entityID then return nil end
    local result = nil
    pcall(function() result = Game.FindEntityByID(entityID) end)
    if not result then
        pcall(function() result = Game.GetDynamicEntitySystem():GetEntity(entityID) end)
    end
    return result
end

function Bridge.status(system, siteID)
    local value = -1
    pcall(function() value = system:GetStatus(siteID) end)
    return value
end

function Bridge.boss(system, siteID)
    local needs = false
    pcall(function() needs = system:NeedsBodyReward(siteID) end)
    if not needs then return nil end
    local entityID = nil
    pcall(function() entityID = system:GetBossEntityID(siteID) end)
    return Bridge.entity(entityID)
end

return Bridge
