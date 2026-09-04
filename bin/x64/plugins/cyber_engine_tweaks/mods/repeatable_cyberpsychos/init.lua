local Config = require("./modules/config.lua")
local Sites = require("./modules/sites.lua")
local Bridge = require("./modules/bridge.lua")
local Mappins = require("./modules/mappins.lua")
local Rewards = require("./modules/rewards.lua")
local NativeSettings = require("./modules/native_settings.lua")
local Diagnostics = require("./modules/diagnostics.lua")
local BossWatchdog = require("./modules/boss_watchdog.lua")

local Mod = {
    version = "0.4.2",
    configPath = "config.json",
    sites = Sites,
    bridge = Bridge,
    mappins = Mappins,
    rewards = Rewards,
    nativeSettings = NativeSettings,
    diagnostics = Diagnostics,
    bossWatchdog = BossWatchdog,
    settings = nil,
    tickElapsed = 0.0,
    schedulerElapsed = 0.0,
    playerAttached = false,
}

Mod.settings = Config.load(Mod.configPath)

function Mod.saveSettings()
    Config.save(Mod.configPath, Mod.settings)
end

local function processBodyRewards(system)
    for _, site in ipairs(Sites.list) do
        local boss = Bridge.boss(system, site.id)
        if boss then
            local ok, result = pcall(Rewards.grantBody, boss, Mod.settings)
            if not ok then
                print("[Repeatable Cyberpsychos] Body reward failed at " .. site.id .. ": " .. tostring(result))
                Diagnostics.event("body_reward_failed", { site = site.id, error = tostring(result) })
            else
                pcall(function() system:MarkBodyRewarded(site.id) end)
                Diagnostics.event("body_reward_granted", {
                    site = site.id,
                    bossRecord = site.bossRecord,
                    itemCount = result,
                })
            end
        end
    end
end

local function processCombatSetup(system)
    for _, site in ipairs(Sites.list) do
        local needs = false
        pcall(function() needs = system:NeedsCombatSetup(site.id) end)
        if needs then
            local entityID = nil
            pcall(function() entityID = system:GetBossEntityID(site.id) end)
            local boss = Bridge.entity(entityID)
            if boss then
                local ok, err = pcall(Rewards.applyCombat, boss, Mod.settings)
                if ok then
                    pcall(function() system:MarkCombatPrepared(site.id) end)
                    Diagnostics.event("combat_scaling_applied", {
                        site = site.id,
                        bossRecord = site.bossRecord,
                        combat = Mod.settings.combat,
                    })
                else
                    Diagnostics.event("combat_scaling_failed", { site = site.id, error = tostring(err) })
                end
            end
        end
    end
end

local function processCompletionRewards(system)
    local pending = 0
    pcall(function() pending = system:GetPendingCompletionRewards() end)
    local processed = 0
    while pending > 0 and processed < 5 do
        local ok, granted, itemCount, ruleSource = pcall(Rewards.grantCompletion, Mod.settings)
        if not ok or granted ~= true then break end
        pcall(function() system:AcknowledgeCompletionReward() end)
        Diagnostics.event("completion_reward_processed", {
            enabled = Mod.settings.reward.completionEnabled ~= false,
            itemCount = itemCount or 0,
            ruleSource = ruleSource or "disabled",
        })
        pending = pending - 1
        processed = processed + 1
    end
end

local function applySchedule(system)
    local schedule = Mod.settings.schedule
    pcall(function() system:SetCooldownHours(schedule.cooldownHours) end)
    pcall(function() system:SetLockdownPoolSize(schedule.lockdownPoolSize) end)
    pcall(function() system:SetPoolSize(schedule.poolSize) end)
end

local function runtimeTick()
    local system = Bridge.system()
    local player = Game.GetPlayer()
    if not system or not player then
        Mod.playerAttached = false
        return
    end
    applySchedule(system)
    if not Mod.playerAttached then
        Mod.playerAttached = true
        Diagnostics.event("save_attached_schedule_applied", {
            configured = Mod.settings.schedule,
            applied = {
                poolSize = system:GetPoolSize(),
                lockdownPoolSize = system:GetLockdownPoolSize(),
                effectivePoolSize = system:GetEffectivePoolSize(),
                cooldownHours = system:GetCooldownHours(),
            },
        })
    end
    Diagnostics.setEnabled(Mod.settings.diagnostics.enabled)
    pcall(function() system:SetChangeMappinColor(Mod.settings.general.changeMapMarkerColor) end)
    pcall(function() system:SetHeightenedAwareness(Mod.settings.combat.heightenedAwareness) end)
    pcall(function() system:SetBlockStealthTakedowns(Mod.settings.combat.blockStealthTakedowns) end)
    pcall(function() system:RuntimeTick() end)
    processCombatSetup(system)
    processBodyRewards(system)
    processCompletionRewards(system)
    BossWatchdog.sync(system, Sites, Mod.settings, 1.0)
    Mappins.sync(system, Sites)
    Diagnostics.snapshot(system, Sites, Mod.settings, Mappins)
end

registerForEvent("onInit", function()
    math.randomseed(os.time())
    Diagnostics.init(Mod.settings, Mod.version)
    BossWatchdog.init(Bridge, Diagnostics)
    local ok, stats = pcall(Rewards.scan)
    if ok then
        print("[Repeatable Cyberpsychos] Reward catalog ready: " .. tostring(stats.scanned) .. " records scanned.")
    else
        print("[Repeatable Cyberpsychos] Reward catalog scan failed: " .. tostring(stats))
    end
    pcall(Mappins.discover, Sites)
    local registered, settingsError = pcall(NativeSettings.register, Mod)
    if not registered then
        print("[Repeatable Cyberpsychos] Native Settings registration failed: " .. tostring(settingsError))
    end
end)

registerForEvent("onUpdate", function(delta)
    Mod.tickElapsed = Mod.tickElapsed + delta
    Mod.schedulerElapsed = Mod.schedulerElapsed + delta
    if Mod.tickElapsed >= 1.0 then
        Mod.tickElapsed = 0.0
        local ok, err = pcall(runtimeTick)
        if not ok then print("[Repeatable Cyberpsychos] Runtime tick failed: " .. tostring(err)) end
    end
    if Mod.schedulerElapsed >= 10.0 then
        Mod.schedulerElapsed = 0.0
        local system = Bridge.system()
        if system then pcall(function() system:Tick() end) end
    end
end)

registerForEvent("onShutdown", function()
    Mod.saveSettings()
    BossWatchdog.clear()
    Mappins.clear()
    Diagnostics.shutdown()
end)

return Mod
