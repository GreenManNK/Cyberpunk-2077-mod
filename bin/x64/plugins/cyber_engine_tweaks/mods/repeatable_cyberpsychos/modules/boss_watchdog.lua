local Watchdog = {
    states = {},
    bridge = nil,
    diagnostics = nil,
}

local function distance2D(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function entityIDKey(id)
    if not id then return nil end
    local key = nil
    pcall(function() key = tostring(id.hash) end)
    return key or tostring(id)
end

local function deleteEntity(id)
    if not id then return end
    pcall(function() Game.GetDynamicEntitySystem():DeleteEntity(id) end)
end

local function tracked(system, siteID)
    local id = nil
    pcall(function() id = system:GetBossEntityID(siteID) end)
    if not id then return nil, nil end
    local entity = Watchdog.bridge.entity(id)
    if not entity then return id, nil end
    return id, entity
end

local function spawn(site, state)
    local spec = DynamicEntitySpec.new()
    spec.recordID = site.bossRecord
    spec.position = Vector4.new(site.position.x, site.position.y, site.position.z, 1.0)
    spec.orientation = Quaternion.new(
        site.orientation.i, site.orientation.j, site.orientation.k, site.orientation.r
    )
    spec.alwaysSpawned = true
    local id = Game.GetDynamicEntitySystem():CreateEntity(spec)
    if not id then return false end
    state.fallbackID = id
    state.spawnAge = 0.0
    state.registered = false
    Watchdog.diagnostics.event("fallback_spawn_requested", {
        site = site.id,
        bossRecord = site.bossRecord,
        position = site.position,
        entityID = entityIDKey(id),
    })
    return true
end

function Watchdog.init(bridge, diagnostics)
    Watchdog.bridge = bridge
    Watchdog.diagnostics = diagnostics
    Watchdog.states = {}
end

function Watchdog.sync(system, sites, settings, elapsed)
    if not system then return end
    local player = Game.GetPlayer()
    if not player then return end
    local playerPosition = player:GetWorldPosition()
    local enabled = settings.diagnostics.missingBossFallback ~= false
    local triggerDistance = settings.diagnostics.fallbackDistance or 180.0
    local graceSeconds = settings.diagnostics.fallbackGraceSeconds or 60.0

    for _, site in ipairs(sites.list) do
        local state = Watchdog.states[site.id] or {
            grace = 0.0, spawnAge = 0.0, fallbackID = nil,
            registered = false, cycle = -1,
        }
        Watchdog.states[site.id] = state

        local status, cycle = -1, 0
        pcall(function()
            status = system:GetStatus(site.id)
            cycle = system:GetCycle(site.id)
        end)
        if state.cycle ~= cycle then
            state.cycle = cycle
            state.grace = 0.0
            state.spawnAge = 0.0
            state.registered = false
        end

        local trackedID, trackedEntity = tracked(system, site.id)
        local pendingOriginal = false
        pcall(function() pendingOriginal = system:HasPendingBoss(site.id) == true end)
        if status == 1 then
            if state.fallbackID and trackedEntity
                and entityIDKey(state.fallbackID) ~= entityIDKey(trackedID) then
                deleteEntity(state.fallbackID)
                Watchdog.diagnostics.event("fallback_removed_for_original_boss", { site = site.id })
                state.fallbackID = nil
                state.registered = false
            end

            if trackedEntity then
                state.grace = 0.0
            elseif state.fallbackID then
                state.spawnAge = state.spawnAge + elapsed
                local fallback = Watchdog.bridge.entity(state.fallbackID)
                if fallback and not state.registered then
                    local accepted = false
                    pcall(function()
                        accepted = system:RegisterFallbackBoss(site.id, fallback:GetEntityID()) == true
                    end)
                    if accepted then
                        state.registered = true
                        Watchdog.diagnostics.event("fallback_boss_registered", {
                            site = site.id,
                            bossRecord = site.bossRecord,
                            entityID = entityIDKey(state.fallbackID),
                        })
                    end
                elseif not fallback and state.spawnAge >= 15.0 then
                    Watchdog.diagnostics.event("fallback_spawn_timeout", {
                        site = site.id,
                        bossRecord = site.bossRecord,
                    })
                    state.fallbackID = nil
                    state.spawnAge = 0.0
                    state.grace = 0.0
                end
            elseif pendingOriginal then
                -- The exact community actor exists but is still completing its
                -- engine attach. Never race it with a fallback copy.
                state.grace = 0.0
            elseif enabled and distance2D(playerPosition, site.position) <= triggerDistance then
                state.grace = state.grace + elapsed
                local siteGrace = site.dynamicBoss and 1.0 or graceSeconds
                if state.grace >= siteGrace then
                    if not spawn(site, state) then
                        Watchdog.diagnostics.event("fallback_spawn_failed", {
                            site = site.id,
                            bossRecord = site.bossRecord,
                        })
                        state.grace = 0.0
                    end
                end
            else
                state.grace = 0.0
            end
        else
            state.grace = 0.0
            if state.fallbackID then
                local fallback = Watchdog.bridge.entity(state.fallbackID)
                local farEnough = distance2D(playerPosition, site.position) > 120.0
                if status < 0 or status == 2 or not fallback or farEnough then
                    deleteEntity(state.fallbackID)
                    Watchdog.diagnostics.event("fallback_boss_cleaned", {
                        site = site.id,
                        status = status,
                        playerWasFarEnough = farEnough,
                    })
                    state.fallbackID = nil
                    state.spawnAge = 0.0
                    state.registered = false
                end
            end
        end
    end
end

function Watchdog.clear()
    for _, state in pairs(Watchdog.states) do deleteEntity(state.fallbackID) end
    Watchdog.states = {}
end

return Watchdog
