local NativeUI = {
    registered = false,
    root = "/repeatableIncreasedCriminalActivity",
}

local function save(mod) mod.saveSettings() end

local function addConfigSwitch(api, path, label, description, target, key, defaultValue, mod, changed)
    api.addSwitch(path, label, description, target[key], defaultValue, function(value)
        target[key] = value
        save(mod)
        if changed then changed(value) end
    end)
end

local function addConfigInt(api, path, label, description, target, key,
        minimum, maximum, step, defaultValue, mod, changed)
    api.addRangeInt(path, label, description, minimum, maximum, step,
        target[key], defaultValue, function(value)
            target[key] = value
            save(mod)
            if changed then changed(value) end
        end)
end

local function addConfigFloat(api, path, label, description, target, key,
        minimum, maximum, step, format, defaultValue, mod, changed)
    api.addRangeFloat(path, label, description, minimum, maximum, step, format,
        target[key], defaultValue, function(value)
            target[key] = value
            save(mod)
            if changed then changed(value) end
        end)
end

local function addSchedule(api, mod)
    local path = NativeUI.root .. "/schedule"
    api.addSubcategory(path, "Event Schedule and Cleanup")
    local schedule = mod.settings.schedule
    local changed = function() mod.applyRuntimeSettings() end

    addConfigSwitch(api, path, "Enable repeatable strongholds",
        "Turns this mod's selection and markers on or off. Disabling retires only entries activated by this mod.",
        schedule, "enabled", true, mod, changed)

    addConfigInt(api, path, "Active replay strongholds",
        "Maximum number of mod-owned stronghold markers. Engaged events are not discarded just to satisfy a lower limit.",
        schedule, "poolSize", 0, 3, 1, 1, mod, changed)

    addConfigFloat(api, path, "Hours before a cleared stronghold returns",
        "Uses in-game time. Sleeping and time skipping count. Changing this also changes waits already in progress.",
        schedule, "cooldownHours", 1.0, 720.0, 1.0, "%.0f h", 36.0, mod, changed)

    addConfigInt(api, path, "Curated enemy roster",
        "Percentage of the safe curated roster used next time a site activates. The boss is always included.",
        schedule, "rosterPercent", 25, 100, 5, 75, mod, changed)

    addConfigSwitch(api, path, "Luxor reinforcements",
        "Allows Ayo Zarin's separate netrunner and combat-drone entries on future Luxor activations.",
        schedule, "reinforcements", true, mod, changed)

    addConfigInt(api, path, "Minimum body-loot time",
        "Owned communities cannot clean up until this many in-game seconds have passed after the boss clear.",
        schedule, "cleanupSeconds", 30, 900, 30, 120, mod, changed)

    addConfigFloat(api, path, "Cleanup distance",
        "After the grace period, cleanup waits until V is farther than this distance from the site.",
        schedule, "cleanupDistance", 100.0, 500.0, 10.0, "%.0f m", 150.0, mod, changed)

    addConfigSwitch(api, path, "Purple replay markers",
        "Tints only this mod's stronghold markers purple. Reopen the map after changing the option.",
        mod.settings.general, "changeMapMarkerColor", true, mod)
end

local function addSites(api, mod)
    local path = NativeUI.root .. "/sites"
    api.addSubcategory(path, "Individual Strongholds")
    for _, site in ipairs(mod.sites.list) do
        local siteID = site.id
        local siteSettings = mod.settings.sites[siteID]
        local changed = function() mod.applyRuntimeSettings() end
        addConfigSwitch(api, path, site.name .. " enabled",
            "Allow this completed site to enter the replay pool.",
            siteSettings, "enabled", true, mod, changed)
        addConfigFloat(api, path, site.name .. " cooldown override",
            "0 uses the global cooldown; any other value is this site's in-game-hour delay.",
            siteSettings, "cooldownOverrideHours", 0.0, 720.0, 1.0, "%.0f h", 0.0, mod, changed)
    end
end

local function addDiagnostics(api, mod)
    local path = NativeUI.root .. "/diagnostics"
    api.addSubcategory(path, "Diagnostics")
    local diagnostics = mod.settings.diagnostics
    addConfigSwitch(api, path, "Write background diagnostic log",
        "Records configured and applied scheduling, all site cooldown and cleanup states, markers, boss tracking, and reward events in diagnostics.log.",
        diagnostics, "enabled", true, mod,
        function(value) mod.diagnostics.setEnabled(value) end)
end

local function addCombat(api, mod)
    local regularPath = NativeUI.root .. "/regularCombat"
    local bossPath = NativeUI.root .. "/bossCombat"
    local combat = mod.settings.combat
    local changed = function() mod.applyRuntimeSettings() end

    api.addSubcategory(regularPath, "Regular Replay Enemies")
    addConfigSwitch(api, regularPath, "Heightened initial awareness",
        "Clears stale threat data and makes tracked replay actors hostile without starting a quest.",
        combat, "heightenedAwareness", true, mod, changed)
    addConfigFloat(api, regularPath, "Health", "Regular replay-enemy health multiplier.",
        combat, "regularHealth", 0.50, 5.00, 0.05, "%.2fx", 1.15, mod, changed)
    addConfigFloat(api, regularPath, "Damage", "Regular replay-enemy damage multiplier.",
        combat, "regularDamage", 0.50, 5.00, 0.05, "%.2fx", 1.10, mod, changed)
    addConfigFloat(api, regularPath, "Armor", "Regular replay-enemy armor multiplier.",
        combat, "regularArmor", 0.50, 5.00, 0.05, "%.2fx", 1.00, mod, changed)
    addConfigFloat(api, regularPath, "Quickhack resistance", "Regular replay-enemy quickhack-resistance multiplier.",
        combat, "regularQuickhack", 0.50, 5.00, 0.05, "%.2fx", 1.00, mod, changed)

    api.addSubcategory(bossPath, "Replay Bosses and Cycle Growth")
    addConfigFloat(api, bossPath, "Boss health", "Replay-boss health multiplier.",
        combat, "bossHealth", 0.50, 10.00, 0.05, "%.2fx", 1.50, mod, changed)
    addConfigFloat(api, bossPath, "Boss damage", "Replay-boss damage multiplier.",
        combat, "bossDamage", 0.50, 5.00, 0.05, "%.2fx", 1.25, mod, changed)
    addConfigFloat(api, bossPath, "Boss armor", "Replay-boss armor multiplier.",
        combat, "bossArmor", 0.50, 5.00, 0.05, "%.2fx", 1.10, mod, changed)
    addConfigFloat(api, bossPath, "Boss quickhack resistance", "Replay-boss quickhack-resistance multiplier.",
        combat, "bossQuickhack", 0.50, 5.00, 0.05, "%.2fx", 1.10, mod, changed)
    addConfigFloat(api, bossPath, "Power growth per clear",
        "Additional multiplicative enemy power for each prior clear at that site. 0 disables growth.",
        combat, "growthPerClear", 0.00, 0.10, 0.005, "%.3f", 0.00, mod, changed)
    addConfigInt(api, bossPath, "Growth cycle cap", "Maximum prior clears counted by growth.",
        combat, "growthCap", 0, 100, 1, 20, mod, changed)
end

local function addRewardAmounts(api, mod)
    local path = NativeUI.root .. "/rewardAmounts"
    local reward = mod.settings.reward
    api.addSubcategory(path, "Clear Bonus and Global Scaling")
    addConfigInt(api, path, "Money minimum", "Minimum eurodollars granted on a boss clear.",
        reward, "moneyMin", 0, 100000, 500, 5000, mod)
    addConfigInt(api, path, "Money maximum", "Maximum eurodollars granted on a boss clear.",
        reward, "moneyMax", 0, 100000, 500, 10000, mod)
    addConfigInt(api, path, "Level XP", "Level XP granted directly on a boss clear.",
        reward, "levelXP", 0, 10000, 50, 600, mod)
    addConfigInt(api, path, "Street Cred XP", "Street Cred XP granted directly on a boss clear.",
        reward, "streetCredXP", 0, 10000, 50, 500, mod)
    addConfigFloat(api, path, "Overall item chance", "Multiplier applied to every category chance.",
        reward, "chanceMultiplier", 0.00, 5.00, 0.05, "%.2fx", 1.00, mod)
    addConfigFloat(api, path, "Item draw count", "Multiplier applied to the configured number of item draws.",
        reward, "itemCountMultiplier", 0.00, 5.00, 0.05, "%.2fx", 1.00, mod)
    addConfigFloat(api, path, "Stack quantity", "Multiplier for ammunition and crafting-material quantities.",
        reward, "quantityMultiplier", 0.25, 10.00, 0.25, "%.2fx", 1.00, mod)
    addConfigSwitch(api, path, "Cap items by player tier",
        "Prevents generated rewards exceeding V's approximate tier before the boost.",
        reward, "followPlayerTier", true, mod)
    addConfigInt(api, path, "Extra item tiers", "Raises the player-tier cap for generated rewards.",
        reward, "tierBoost", 0, 4, 1, 0, mod)
    addConfigInt(api, path, "Body loot minimum tier", "Minimum tier for generated body loot.",
        reward, "bodyMinTier", 1, 5, 1, 1, mod)
    addConfigInt(api, path, "Body loot maximum tier", "Maximum tier for generated body loot.",
        reward, "bodyMaxTier", 1, 5, 1, 3, mod)
    addConfigInt(api, path, "Clear reward minimum tier", "Minimum tier for direct clear items.",
        reward, "clearMinTier", 1, 5, 1, 2, mod)
    addConfigInt(api, path, "Clear reward maximum tier", "Maximum tier for direct clear items.",
        reward, "clearMaxTier", 1, 5, 1, 5, mod)
end

local function addRewardRule(api, path, label, rule, defaultRule, mod)
    addConfigSwitch(api, path, label .. " enabled", "Allow this reward category.",
        rule, "enabled", defaultRule.enabled, mod)
    addConfigFloat(api, path, label .. " chance", "Chance per category roll before global scaling.",
        rule, "chance", 0.00, 1.00, 0.01, "%.2f", defaultRule.chance, mod)
    addConfigInt(api, path, label .. " draws", "Base draws before global item-count scaling.",
        rule, "draws", 0, 10, 1, defaultRule.draws, mod)
end

local function addRewardRules(api, mod, location, title, order)
    local path = NativeUI.root .. "/" .. location
    api.addSubcategory(path, title)
    local rules = mod.settings.reward[location]
    for _, definition in ipairs(order) do
        addRewardRule(api, path, definition.label, rules[definition.key], definition.default, mod)
    end
end

function NativeUI.register(mod)
    local api = GetMod("nativeSettings")
    if not api then
        print("[RICA] Native Settings UI not found. The mod runs with defaults, but settings are unavailable.")
        return false
    end

    api.addTab(NativeUI.root, "Repeatable Increased Criminal Activity", function() save(mod) end)
    addSchedule(api, mod)
    addSites(api, mod)
    addDiagnostics(api, mod)
    addCombat(api, mod)
    addRewardAmounts(api, mod)
    addRewardRules(api, mod, "body", "Replay Enemy Body Loot", {
        { key = "weapons", label = "Non-iconic weapons", default = { enabled = true, chance = 0.35, draws = 1 } },
        { key = "iconics", label = "Generic iconics", default = { enabled = false, chance = 0.00, draws = 0 } },
        { key = "shards", label = "Shards", default = { enabled = true, chance = 0.08, draws = 1 } },
        { key = "consumables", label = "Consumables", default = { enabled = true, chance = 0.45, draws = 1 } },
        { key = "ammo", label = "Ammunition", default = { enabled = true, chance = 0.75, draws = 2 } },
        { key = "materials", label = "Crafting materials", default = { enabled = true, chance = 0.55, draws = 2 } },
    })
    addRewardRules(api, mod, "clear", "Boss Clear Bonus (Delivered to V)", {
        { key = "weapons", label = "Non-iconic weapons", default = { enabled = true, chance = 0.75, draws = 1 } },
        { key = "iconics", label = "Generic iconics", default = { enabled = false, chance = 0.00, draws = 0 } },
        { key = "shards", label = "Shards", default = { enabled = true, chance = 0.30, draws = 1 } },
        { key = "consumables", label = "Consumables", default = { enabled = true, chance = 0.75, draws = 2 } },
        { key = "ammo", label = "Ammunition", default = { enabled = true, chance = 1.00, draws = 3 } },
        { key = "materials", label = "Crafting materials", default = { enabled = true, chance = 1.00, draws = 4 } },
        { key = "schemes", label = "Schemes and recipes", default = { enabled = true, chance = 0.20, draws = 1 } },
        { key = "attachments", label = "Attachments", default = { enabled = true, chance = 0.65, draws = 1 } },
        { key = "weaponMods", label = "Weapon mods", default = { enabled = true, chance = 0.50, draws = 1 } },
    })
    NativeUI.registered = true
    print("[RICA] Native Settings UI registered.")
    return true
end

return NativeUI
