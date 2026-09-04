local Bridge = {}

function Bridge.system()
    local result = nil
    pcall(function()
        result = Game.GetScriptableSystemsContainer():Get(
            "RepeatableIncreasedCriminalActivitySystem"
        )
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
    if system then pcall(function() value = system:GetStatus(siteID) end) end
    return value
end

function Bridge.pendingBody(system)
    if not system then return nil, nil, "" end
    local entityID = nil
    local siteID = ""
    pcall(function()
        entityID = system:GetPendingBodyRewardEntityID()
        siteID = system:GetPendingBodyRewardSiteID()
    end)
    return Bridge.entity(entityID), entityID, siteID
end

return Bridge
