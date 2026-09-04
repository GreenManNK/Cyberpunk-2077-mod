local Diagnostics = {
    path = "diagnostics.log",
    enabled = true,
    version = "unknown",
    session = nil,
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
    Diagnostics.session = os.date("!%Y%m%dT%H%M%SZ") .. "-" .. tostring(math.random(100000, 999999))
    Diagnostics.lastSnapshot = nil
    Diagnostics.lastSnapshotAt = 0
    rotateIfLarge()
    Diagnostics.event("session_start", {
        version = version,
        schedule = settings.schedule,
        diagnostics = settings.diagnostics,
        combat = settings.combat,
        reward = settings.reward,
    }, true)
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

local function read(system, fallback, fn)
    local value = fallback
    pcall(function() value = fn(system) end)
    return value
end

function Diagnostics.snapshot(system, sites, settings, mappins)
    if not Diagnostics.enabled or not system then return end
    local now = read(system, 0, function(s) return s:GetNowSeconds() end)
    local payload = {
        gameTimeSeconds = now,
        configuredSchedule = settings.schedule,
        appliedSchedule = {
            poolSize = read(system, -1, function(s) return s:GetPoolSize() end),
            lockdownPoolSize = read(system, -1, function(s) return s:GetLockdownPoolSize() end),
            effectivePoolSize = read(system, -1, function(s) return s:GetEffectivePoolSize() end),
            cooldownHours = read(system, -1, function(s) return s:GetCooldownHours() end),
            lockdown = read(system, false, function(s) return s:IsLockdown() end),
        },
        markerSummary = {
            registered = mappins.registered,
            schedulerActive = mappins.schedulerActive,
            eligible = mappins.eligible,
            tracked = mappins.tracked,
            failures = mappins.registrationFailures,
        },
        sites = {},
    }
    for _, site in ipairs(sites.list) do
        local nextEligibleAt = read(system, 0, function(s) return s:GetNextEligibleAt(site.id) end)
        local bossID = read(system, nil, function(s) return s:GetBossEntityID(site.id) end)
        local bossTracked = false
        if bossID then pcall(function() bossTracked = EntityID.IsDefined(bossID) end) end
        payload.sites[#payload.sites + 1] = {
            id = site.id,
            status = read(system, -1, function(s) return s:GetStatus(site.id) end),
            vanillaEligible = read(system, false, function(s) return s:IsVanillaEligible(site.id) end),
            ownedActivation = read(system, false, function(s) return s:IsOwnedActivation(site.id) end),
            cycle = read(system, 0, function(s) return s:GetCycle(site.id) end),
            nextEligibleAt = nextEligibleAt,
            remainingSeconds = math.max(0, nextEligibleAt - now),
            cleanupReadyAt = read(system, 0, function(s) return s:GetCleanupReadyAt(site.id) end),
            bossTracked = bossTracked,
            bossAttachPending = read(system, false, function(s) return s:HasPendingBoss(site.id) end),
            combatSetupPending = read(system, false, function(s) return s:NeedsCombatSetup(site.id) end),
            bodyRewardReady = read(system, false, function(s) return s:NeedsBodyReward(site.id) end),
            expectedBossRecord = site.bossRecord,
        }
    end

    local raw = encode(payload)
    local wall = os.time()
    if raw ~= Diagnostics.lastSnapshot or wall - Diagnostics.lastSnapshotAt >= 60 then
        Diagnostics.event("state_snapshot", payload)
        Diagnostics.lastSnapshot = raw
        Diagnostics.lastSnapshotAt = wall
    end
end

function Diagnostics.shutdown()
    Diagnostics.event("session_end", {}, true)
end

return Diagnostics
