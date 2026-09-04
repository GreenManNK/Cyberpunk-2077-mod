local Config = require("./modules/config.lua")
local Sites = require("./modules/sites.lua")
local Bridge = require("./modules/bridge.lua")
local Mappins = require("./modules/mappins.lua")
local Rewards = require("./modules/rewards.lua")
local NativeSettings = require("./modules/native_settings.lua")
local Diagnostics = require("./modules/diagnostics.lua")

local Mod = {
    version = "0.1.4-alpha",
    configPath = "config.json",
    sites = Sites,
    bridge = Bridge,
    mappins = Mappins,
    rewards = Rewards,
    nativeSettings = NativeSettings,
    diagnostics = Diagnostics,
    settings = nil,
    tickElapsed = 0.0,
    schedulerElapsed = 0.0,
    lastBodyError = nil,
    lastCompletionError = nil,
    lastSettingsError = nil,
    lastScheduleSignature = nil,
    playerAttached = false,
}

Mod.settings = Config.load(Mod.configPath)

function Mod.saveSettings()
    return Config.save(Mod.configPath, Mod.settings)
end

function Mod.applyRuntimeSettings()
    local system = Bridge.system()
    if not system then return false end
    local schedule = Mod.settings.schedule
    local combat = Mod.settings.combat
    local ok, err = pcall(function()
        system:SetPoolSize(schedule.poolSize)
        system:SetCooldownHours(schedule.cooldownHours)
        system:SetRosterPercent(schedule.rosterPercent)
        system:SetReinforcements(schedule.reinforcements)
        system:SetCleanupSeconds(schedule.cleanupSeconds)
        system:SetCleanupDistance(schedule.cleanupDistance)
        for _, site in ipairs(Sites.list) do
            local siteSettings = Mod.settings.sites[site.id]
            system:SetSiteEnabled(site.id, siteSettings.enabled)
            system:SetSiteCooldownOverride(site.id, siteSettings.cooldownOverrideHours)
        end
        system:SetEnabled(schedule.enabled)
        system:SetChangeMappinColor(Mod.settings.general.changeMapMarkerColor)
        system:SetHeightenedAwareness(combat.heightenedAwareness)
        system:SetRegularCombat(combat.regularHealth, combat.regularDamage,
            combat.regularArmor, combat.regularQuickhack)
        system:SetBossCombat(combat.bossHealth, combat.bossDamage,
            combat.bossArmor, combat.bossQuickhack)
        system:SetGrowth(combat.growthPerClear, combat.growthCap)

        if system:GetPoolSize() ~= schedule.poolSize then
            error("scheduler rejected active replay count " .. tostring(schedule.poolSize))
        end
        if math.abs(system:GetCooldownHours() - schedule.cooldownHours) > 0.01 then
            error("scheduler rejected cooldown " .. tostring(schedule.cooldownHours))
        end
    end)
    if not ok then
        local message = tostring(err)
        if Mod.lastSettingsError ~= message then
            print("[RICA] Persistent settings apply failed: " .. message)
            Diagnostics.event("settings_apply_failed", { error = message })
            Mod.lastSettingsError = message
        end
        return false
    end
    Mod.lastSettingsError = nil

    local signature = tostring(schedule.enabled) .. ":" .. tostring(schedule.poolSize)
        .. ":" .. tostring(schedule.cooldownHours) .. ":" .. tostring(schedule.rosterPercent)
        .. ":" .. tostring(schedule.reinforcements) .. ":" .. tostring(schedule.cleanupSeconds)
        .. ":" .. tostring(schedule.cleanupDistance)
    for _, site in ipairs(Sites.list) do
        local siteSettings = Mod.settings.sites[site.id]
        signature = signature .. ":" .. tostring(siteSettings.enabled)
            .. ":" .. tostring(siteSettings.cooldownOverrideHours)
    end
    if Mod.lastScheduleSignature ~= signature then
        print("[RICA] Persistent schedule applied: active=" .. tostring(schedule.poolSize)
            .. " cooldown=" .. tostring(schedule.cooldownHours) .. "h")
        Diagnostics.event("schedule_applied", {
            configured = schedule,
            applied = {
                enabled = system:GetEnabled(),
                poolSize = system:GetPoolSize(),
                effectivePoolSize = system:GetEffectivePoolSize(),
                cooldownHours = system:GetCooldownHours(),
                rosterPercent = system:GetRosterPercent(),
                reinforcements = system:GetReinforcements(),
                cleanupSeconds = system:GetCleanupSeconds(),
                cleanupDistance = system:GetCleanupDistance(),
            },
        })
        Mod.lastScheduleSignature = signature
    end
    return true
end

local function processBodyRewards(system)
    local processed = 0
    while processed < 64 do
        local actor, actorID, siteID = Bridge.pendingBody(system)
        if not actor or not actorID then break end
        local ok, granted, count = pcall(Rewards.grantBody, actor, Mod.settings)
        if not ok or granted ~= true then
            local message = tostring(granted)
            if Mod.lastBodyError ~= message then
                print("[RICA] Body reward failed: " .. message)
                Diagnostics.event("body_reward_failed", {
                    site = siteID,
                    error = message,
                })
                Mod.lastBodyError = message
            end
            break
        end
        pcall(function() system:MarkBodyRewarded(actorID) end)
        Diagnostics.event("body_reward_granted", {
            site = siteID,
            itemCount = count,
        })
        Mod.lastBodyError = nil
        processed = processed + 1
    end
end

local function processCompletionRewards(system)
    local processed = 0
    while processed < 5 do
        local serial, siteID, cycle = 0, "", 0
        pcall(function()
            serial = system:GetPendingRewardSerial()
            siteID = system:GetPendingRewardSiteID()
            cycle = system:GetPendingRewardCycle()
        end)
        if serial <= 0 then break end
        local ok, granted, count, money = pcall(Rewards.grantCompletion, Mod.settings)
        if not ok or granted ~= true then
            local message = tostring(granted)
            if Mod.lastCompletionError ~= message then
                print("[RICA] Clear reward failed for serial " .. tostring(serial) .. ": " .. message)
                Diagnostics.event("completion_reward_failed", {
                    serial = serial,
                    site = siteID,
                    cycle = cycle,
                    error = message,
                })
                Mod.lastCompletionError = message
            end
            break
        end
        pcall(function() system:AcknowledgeCompletionReward(serial) end)
        print("[RICA] Clear reward " .. tostring(serial) .. " delivered for " .. siteID
            .. " cycle " .. tostring(cycle) .. ": " .. tostring(money)
            .. " eurodollars and " .. tostring(count) .. " item draws.")
        Diagnostics.event("completion_reward_granted", {
            serial = serial,
            site = siteID,
            cycle = cycle,
            money = money,
            itemCount = count,
        })
        Mod.lastCompletionError = nil
        processed = processed + 1
    end
end

local function runtimeTick()
    local system = Bridge.system()
    if not system or not Game.GetPlayer() then
        if Mod.playerAttached then
            Diagnostics.event("save_detached", {})
            Mod.playerAttached = false
        end
        return
    end
    Diagnostics.setEnabled(Mod.settings.diagnostics.enabled)
    Diagnostics.configuration(Mod.settings)
    Mod.applyRuntimeSettings()
    if not Mod.playerAttached then
        Mod.playerAttached = true
        Diagnostics.event("save_attached", {
            configuredPoolSize = Mod.settings.schedule.poolSize,
            appliedPoolSize = system:GetPoolSize(),
            configuredCooldownHours = Mod.settings.schedule.cooldownHours,
            appliedCooldownHours = system:GetCooldownHours(),
        })
    end
    processBodyRewards(system)
    processCompletionRewards(system)
    Mappins.sync(system, Sites)
    Diagnostics.snapshot(system, Sites, Mod.settings, Mappins)
end

function Mod.dumpState()
    local system = Bridge.system()
    if not system then print("[RICA] System is not available."); return false end
    local now, enabled, pool, active, eligible, tracked, pending, clears =
        0, false, 0, 0, 0, 0, 0, 0
    pcall(function()
        now = system:GetNowSeconds()
        enabled = system:GetEnabled()
        pool = system:GetEffectivePoolSize()
        active = system:GetActiveReplayCount()
        eligible = system:GetVanillaEligibleReplayCount()
        tracked = system:GetTrackedSiteCount()
        pending = system:GetPendingRewardCount()
        clears = system:GetTotalClears()
    end)
    print("[RICA] v" .. Mod.version .. " enabled=" .. tostring(enabled)
        .. " active=" .. tostring(active) .. "/" .. tostring(pool)
        .. " eligible=" .. tostring(eligible) .. " tracked=" .. tostring(tracked)
        .. " pendingRewards=" .. tostring(pending)
        .. " totalClears=" .. tostring(clears))
    for _, site in ipairs(Sites.list) do
        local status, eligible, cycle, nextAt, siteEnabled = -1, false, 0, 0, false
        pcall(function()
            status = system:GetStatus(site.id)
            eligible = system:IsVanillaEligible(site.id)
            cycle = system:GetCycle(site.id)
            nextAt = system:GetNextEligibleAt(site.id)
            siteEnabled = system:GetSiteEnabled(site.id)
        end)
        print("[RICA] " .. site.id .. " enabled=" .. tostring(siteEnabled)
            .. " vanillaFinished=" .. tostring(eligible) .. " status=" .. tostring(status)
            .. " cycle=" .. tostring(cycle) .. " waitSeconds=" .. tostring(math.max(0, nextAt - now)))
    end
    Diagnostics.event("console_dump_state", {})
    Diagnostics.snapshot(system, Sites, Mod.settings, Mappins, true)
    return true
end

function Mod.captureDiagnostics(note)
    local system = Bridge.system()
    Diagnostics.event("manual_capture", { note = tostring(note or "") }, true)
    Diagnostics.configuration(Mod.settings, true)
    if not system then
        print("[RICA] Diagnostic note recorded, but no loaded scheduler was available.")
        return false
    end
    Mappins.sync(system, Sites)
    Diagnostics.snapshot(system, Sites, Mod.settings, Mappins, true)
    print("[RICA] Diagnostic snapshot written to diagnostics.log.")
    return true
end

function Mod.reconcile()
    local system = Bridge.system()
    if not system then return false end
    pcall(function() system:Reconcile() end)
    Mappins.clear()
    runtimeTick()
    print("[RICA] Runtime state reconciled without writing vanilla quest state.")
    Diagnostics.event("manual_reconcile", {})
    Diagnostics.snapshot(system, Sites, Mod.settings, Mappins, true)
    return true
end

function Mod.retireOwnedEvents()
    local system = Bridge.system()
    if not system then return false end
    pcall(function() system:SetEnabled(false) end)
    Mappins.clear()
    print("[RICA] Mod-owned events retired and future selection disabled for this save.")
    Diagnostics.event("manual_retire_owned_events", {})
    return true
end

registerForEvent("onInit", function()
    math.randomseed(os.time())
    Diagnostics.init(Mod.settings, Mod.version)
    local ok, stats = pcall(Rewards.scan)
    if ok then
        print("[RICA] Reward catalog ready: " .. tostring(stats.scanned)
            .. " records scanned, " .. tostring(stats.denied) .. " rejected.")
        Diagnostics.event("reward_catalog_ready", stats)
    else
        print("[RICA] Reward catalog scan failed: " .. tostring(stats))
        Diagnostics.event("reward_catalog_failed", { error = tostring(stats) })
    end
    pcall(Mappins.discover, Sites)
    Mod.saveSettings()
    Mod.applyRuntimeSettings()
    local registered, settingsError = pcall(NativeSettings.register, Mod)
    if not registered then
        print("[RICA] Native Settings registration failed: " .. tostring(settingsError))
        Diagnostics.event("native_settings_failed", { error = tostring(settingsError) })
    end
end)

registerForEvent("onUpdate", function(delta)
    Mod.tickElapsed = Mod.tickElapsed + delta
    Mod.schedulerElapsed = Mod.schedulerElapsed + delta
    if Mod.tickElapsed >= 1.0 then
        Mod.tickElapsed = 0.0
        local ok, err = pcall(runtimeTick)
        if not ok then
            print("[RICA] Runtime tick failed: " .. tostring(err))
            Diagnostics.event("runtime_tick_failed", { error = tostring(err) })
        end
    end
    if Mod.schedulerElapsed >= 10.0 then
        Mod.schedulerElapsed = 0.0
        local system = Bridge.system()
        if system then
            local ok, err = pcall(function() system:Tick() end)
            if not ok then
                print("[RICA] Scheduler tick failed: " .. tostring(err))
                Diagnostics.event("scheduler_tick_failed", { error = tostring(err) })
            end
        end
    end
end)

registerForEvent("onShutdown", function()
    Mod.saveSettings()
    local system = Bridge.system()
    if system then Diagnostics.snapshot(system, Sites, Mod.settings, Mappins, true) end
    Mappins.clear()
    Diagnostics.shutdown()
end)

RepeatableIncreasedCriminalActivity = Mod
return Mod
