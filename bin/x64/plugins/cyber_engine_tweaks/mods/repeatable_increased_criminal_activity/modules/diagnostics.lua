local Diagnostics = {
    path = "diagnostics.log",
    enabled = true,
    version = "unknown",
    session = nil,
    lastConfiguration = nil,
    lastSnapshot = nil,
    lastSnapshotAt = 0,
}

local function encode(value)
    local ok, raw = pcall(json.encode, value)
    if ok then return raw end
    return "{\"encodeError\":\"" .. tostring(raw):gsub('"', "'") .. "\"}"
end

local function append(record)
    local file = io.open(Diagnostics.path, "a")
    if not file then return false end
    file:write(encode(record), "\n")
    file:close()
    return true
end

local function rotateIfLarge()
    local file = io.open(Diagnostics.path, "r")
    if not file then return end
    local size = file:seek("end") or 0
    file:close()
    if size <= 2 * 1024 * 1024 then return end
    file = io.open(Diagnostics.path, "w")
    if file then
        file:write(encode({
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            event = "log_rotated",
            previousBytes = size,
        }), "\n")
        file:close()
    end
end

function Diagnostics.init(settings, version)
    Diagnostics.enabled = settings.diagnostics.enabled ~= false
    Diagnostics.version = version
    Diagnostics.session = os.date("!%Y%m%dT%H%M%SZ")
        .. "-" .. tostring(math.random(100000, 999999))
    Diagnostics.lastConfiguration = nil
    Diagnostics.lastSnapshot = nil
    Diagnostics.lastSnapshotAt = 0
    rotateIfLarge()
    Diagnostics.event("session_start", { version = version }, true)
    Diagnostics.configuration(settings, true)
end

function Diagnostics.setEnabled(value)
    Diagnostics.enabled = value ~= false
end

function Diagnostics.event(event, data, force)
    if not Diagnostics.enabled and not force then return false end
    return append({
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        session = Diagnostics.session,
        version = Diagnostics.version,
        event = event,
        data = data or {},
    })
end

function Diagnostics.configuration(settings, force)
    if not Diagnostics.enabled and not force then return end
    local payload = {
        schedule = settings.schedule,
        sites = settings.sites,
        combat = settings.combat,
        reward = settings.reward,
        diagnostics = settings.diagnostics,
    }
    local raw = encode(payload)
    if force or raw ~= Diagnostics.lastConfiguration then
        Diagnostics.event("configuration", payload, force)
        Diagnostics.lastConfiguration = raw
    end
end

local function read(system, fallback, fn)
    local value = fallback
    pcall(function() value = fn(system) end)
    return value
end

function Diagnostics.snapshot(system, sites, settings, mappins, force)
    if (not Diagnostics.enabled and not force) or not system then return false end
    local now = read(system, 0, function(value) return value:GetNowSeconds() end)
    local payload = {
        gameTimeSeconds = now,
        configuredSchedule = settings.schedule,
        configuredSites = settings.sites,
        appliedSchedule = {
            enabled = read(system, false, function(value) return value:GetEnabled() end),
            poolSize = read(system, -1, function(value) return value:GetPoolSize() end),
            effectivePoolSize = read(system, -1,
                function(value) return value:GetEffectivePoolSize() end),
            cooldownHours = read(system, -1,
                function(value) return value:GetCooldownHours() end),
            rosterPercent = read(system, -1,
                function(value) return value:GetRosterPercent() end),
            reinforcements = read(system, false,
                function(value) return value:GetReinforcements() end),
            cleanupSeconds = read(system, -1,
                function(value) return value:GetCleanupSeconds() end),
            cleanupDistance = read(system, -1,
                function(value) return value:GetCleanupDistance() end),
        },
        scheduler = {
            active = read(system, -1, function(value) return value:GetActiveReplayCount() end),
            eligible = read(system, -1,
                function(value) return value:GetVanillaEligibleReplayCount() end),
            tracked = read(system, -1, function(value) return value:GetTrackedSiteCount() end),
            pendingRewards = read(system, -1,
                function(value) return value:GetPendingRewardCount() end),
            totalClears = read(system, -1, function(value) return value:GetTotalClears() end),
        },
        markers = {
            discovered = mappins.discovered,
            registered = mappins.registered,
            schedulerActive = mappins.schedulerActive,
            target = mappins.target,
            eligible = mappins.eligible,
            tracked = mappins.tracked,
            registrationFailures = mappins.registrationFailures,
        },
        sites = {},
    }

    for _, site in ipairs(sites.list) do
        local nextEligibleAt = read(system, 0,
            function(value) return value:GetNextEligibleAt(site.id) end)
        payload.sites[#payload.sites + 1] = {
            id = site.id,
            name = site.name,
            status = read(system, -1, function(value) return value:GetStatus(site.id) end),
            enabled = read(system, false,
                function(value) return value:GetSiteEnabled(site.id) end),
            vanillaEligible = read(system, false,
                function(value) return value:IsVanillaEligible(site.id) end),
            ownedActivation = read(system, false,
                function(value) return value:IsOwnedActivation(site.id) end),
            cycle = read(system, 0, function(value) return value:GetCycle(site.id) end),
            lastClearedAt = read(system, 0,
                function(value) return value:GetLastClearedAt(site.id) end),
            nextEligibleAt = nextEligibleAt,
            remainingSeconds = math.max(0, nextEligibleAt - now),
            cleanupReadyAt = read(system, 0,
                function(value) return value:GetCleanupReadyAt(site.id) end),
            playerDistance = read(system, -1.0,
                function(value) return value:GetPlayerDistance(site.id) end),
            cooldownOverrideHours = read(system, 0.0,
                function(value) return value:GetSiteCooldownOverride(site.id) end),
            trackedActors = read(system, 0,
                function(value) return value:GetTrackedActorCount(site.id) end),
            bossLoaded = read(system, false,
                function(value) return value:IsBossLoaded(site.id) end),
            expectedBossRecord = site.bossRecord,
        }
    end

    local raw = encode(payload)
    local wall = os.time()
    if force or raw ~= Diagnostics.lastSnapshot or wall - Diagnostics.lastSnapshotAt >= 60 then
        Diagnostics.event("state_snapshot", payload, force)
        Diagnostics.lastSnapshot = raw
        Diagnostics.lastSnapshotAt = wall
        return true
    end
    return false
end

function Diagnostics.shutdown()
    Diagnostics.event("session_end", {}, true)
end

return Diagnostics
