local Mappins = {
    positions = {},
    owned = {},
    discovered = 0,
    registered = 0,
    targetActive = 0,
    schedulerActive = 0,
    eligible = 0,
    tracked = 0,
    registrationFailures = 0,
    lastError = nil,
    lastSummary = nil,
}

function Mappins.discover(sites)
    Mappins.discovered = 0
    for _, site in ipairs(sites.list) do
        if site.position then
            Mappins.positions[site.id] = Vector4.new(
                site.position.x,
                site.position.y,
                site.position.z,
                1.0
            )
            Mappins.discovered = Mappins.discovered + 1
        end
    end
    return Mappins.discovered
end

local function register(position)
    local id = nil
    local ok, err = pcall(function()
        local data = NewObject("gamemappinsMappinData")
        data.mappinType = TweakDBID.new("Mappins.DefaultStaticMappin")
        data.variant = Enum.new("gamedataMappinVariant", "HuntForPsychoVariant")
        data.visibleThroughWalls = true
        id = Game.GetMappinSystem():RegisterMappin(data, position)
    end)
    if not ok then
        local message = tostring(err)
        if Mappins.lastError ~= message then
            print("[Repeatable Cyberpsychos] Map marker registration failed: " .. message)
        end
        Mappins.lastError = message
    end
    return id
end

local function unregister(id)
    if not id then return end
    pcall(function() Game.GetMappinSystem():UnregisterMappin(id) end)
end

function Mappins.sync(system, sites)
    if not system then return end
    if Mappins.discovered ~= #sites.list then Mappins.discover(sites) end
    local budget = 0
    pcall(function() budget = math.max(0, system:GetEffectivePoolSize()) end)
    Mappins.schedulerActive = 0
    Mappins.eligible = 0
    Mappins.tracked = 0
    pcall(function() Mappins.schedulerActive = math.max(0, system:GetActiveReplayCount()) end)
    pcall(function() Mappins.eligible = math.max(0, system:GetVanillaEligibleReplayCount()) end)
    pcall(function() Mappins.tracked = math.max(0, system:GetTrackedSiteCount()) end)
    Mappins.targetActive = 0
    Mappins.registrationFailures = 0
    for _, site in ipairs(sites.list) do
        local active = false
        pcall(function() active = system:GetStatus(site.id) == 1 end)
        -- A second guard at the presentation layer ensures that purple replay
        -- markers can never exceed the configured replay-marker budget.
        if active and Mappins.targetActive < budget then
            Mappins.targetActive = Mappins.targetActive + 1
        else
            active = false
        end
        if active and not Mappins.owned[site.id] then
            local marker = register(Mappins.positions[site.id])
            if marker then
                Mappins.owned[site.id] = marker
            else
                Mappins.registrationFailures = Mappins.registrationFailures + 1
            end
        elseif not active and Mappins.owned[site.id] then
            unregister(Mappins.owned[site.id])
            Mappins.owned[site.id] = nil
        end
    end
    Mappins.registered = 0
    for _ in pairs(Mappins.owned) do Mappins.registered = Mappins.registered + 1 end
    local summary = tostring(Mappins.registered) .. "/" .. tostring(budget)
        .. "; active=" .. tostring(Mappins.schedulerActive)
        .. "; eligible=" .. tostring(Mappins.eligible)
        .. "; tracked=" .. tostring(Mappins.tracked)
        .. "; failures=" .. tostring(Mappins.registrationFailures)
    if summary ~= Mappins.lastSummary then
        print("[Repeatable Cyberpsychos] Purple replay markers: " .. summary
            .. ". Original blue Regina markers are not included in this count.")
        Mappins.lastSummary = summary
    end
end

function Mappins.clear()
    for id, marker in pairs(Mappins.owned) do
        unregister(marker)
        Mappins.owned[id] = nil
    end
    Mappins.registered = 0
    Mappins.targetActive = 0
    Mappins.schedulerActive = 0
    Mappins.eligible = 0
    Mappins.tracked = 0
    Mappins.registrationFailures = 0
    Mappins.lastError = nil
    Mappins.lastSummary = nil
end

return Mappins
