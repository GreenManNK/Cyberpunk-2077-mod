local Mappins = {
    positions = {},
    owned = {},
    discovered = 0,
    registered = 0,
    schedulerActive = 0,
    target = 0,
    eligible = 0,
    tracked = 0,
    registrationFailures = 0,
    lastError = nil,
    lastSummary = nil,
}

function Mappins.discover(sites)
    Mappins.discovered = 0
    for _, site in ipairs(sites.list) do
        Mappins.positions[site.id] = Vector4.new(
            site.position.x, site.position.y, site.position.z, 1.0
        )
        Mappins.discovered = Mappins.discovered + 1
    end
    return Mappins.discovered
end

local function register(position)
    local id = nil
    local ok, err = pcall(function()
        local data = NewObject("gamemappinsMappinData")
        data.mappinType = TweakDBID.new("Mappins.DefaultStaticMappin")
        data.variant = Enum.new("gamedataMappinVariant", "Zzz12_WorldEncounterVariant")
        data.visibleThroughWalls = true
        id = Game.GetMappinSystem():RegisterMappin(data, position)
    end)
    if not ok then
        Mappins.registrationFailures = Mappins.registrationFailures + 1
        local message = tostring(err)
        if Mappins.lastError ~= message then
            print("[RICA] Map marker registration failed: " .. message)
        end
        Mappins.lastError = message
    end
    return id
end

local function unregister(id)
    if id then pcall(function() Game.GetMappinSystem():UnregisterMappin(id) end) end
end

function Mappins.sync(system, sites)
    if not system then return end
    if Mappins.discovered ~= #sites.list then Mappins.discover(sites) end
    local active = 0
    for _, site in ipairs(sites.list) do
        local shouldExist = false
        pcall(function() shouldExist = system:GetStatus(site.id) == 1 end)
        if shouldExist then active = active + 1 end
        if shouldExist and not Mappins.owned[site.id] then
            local marker = register(Mappins.positions[site.id])
            if marker then Mappins.owned[site.id] = marker end
        elseif not shouldExist and Mappins.owned[site.id] then
            unregister(Mappins.owned[site.id])
            Mappins.owned[site.id] = nil
        end
    end
    Mappins.registered = 0
    for _ in pairs(Mappins.owned) do Mappins.registered = Mappins.registered + 1 end
    local target, eligible, tracked = 0, 0, 0
    pcall(function()
        target = system:GetEffectivePoolSize()
        eligible = system:GetVanillaEligibleReplayCount()
        tracked = system:GetTrackedSiteCount()
    end)
    Mappins.schedulerActive = active
    Mappins.target = target
    Mappins.eligible = eligible
    Mappins.tracked = tracked
    local summary = tostring(Mappins.registered) .. "/" .. tostring(active)
        .. " active; target=" .. tostring(target)
        .. " eligible=" .. tostring(eligible)
        .. " tracked=" .. tostring(tracked)
    if summary ~= Mappins.lastSummary then
        print("[RICA] Replay stronghold markers: " .. summary)
        Mappins.lastSummary = summary
    end
end

function Mappins.clear()
    for siteID, marker in pairs(Mappins.owned) do
        unregister(marker)
        Mappins.owned[siteID] = nil
    end
    Mappins.registered = 0
    Mappins.schedulerActive = 0
    Mappins.target = 0
    Mappins.eligible = 0
    Mappins.tracked = 0
    Mappins.lastError = nil
    Mappins.lastSummary = nil
end

return Mappins
