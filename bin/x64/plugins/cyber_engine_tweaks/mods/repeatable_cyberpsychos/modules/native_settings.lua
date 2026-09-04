local NativeUI = {
    registered = false,
    root = "/repeatableCyberpsychoEncounters",
}

local function save(mod)
    mod.saveSettings()
end

local function addConfigSwitch(api, path, label, description, target, key, defaultValue, mod)
    api.addSwitch(path, label, description, target[key], defaultValue, function(value)
        target[key] = value
        save(mod)
    end)
end

local function addConfigInt(api, path, label, description, target, key,
        minValue, maxValue, step, defaultValue, mod)
    api.addRangeInt(path, label, description, minValue, maxValue, step,
        target[key], defaultValue, function(value)
            target[key] = value
            save(mod)
        end)
end

local function addConfigFloat(api, path, label, description, target, key,
        minValue, maxValue, step, format, defaultValue, mod)
    api.addRangeFloat(path, label, description, minValue, maxValue, step, format,
        target[key], defaultValue, function(value)
            target[key] = value
            save(mod)
        end)
end

local function updateSystem(mod, writer)
    local system = mod.bridge.system()
    if system then pcall(function() writer(system) end) end
end

local function addEncounterSettings(api, mod)
    local path = NativeUI.root .. "/encounterCycle"
    api.addSubcategory(path, "Encounter Schedule")
    local schedule = mod.settings.schedule

    api.addRangeInt(path,
        "Number of active purple replay sightings",
        "Strict limit for this mod's purple replay markers. Unfinished original blue Regina markers are separate and may appear in addition.",
        0, 17, 1, schedule.poolSize, 8, function(value)
            schedule.poolSize = value
            save(mod)
            updateSystem(mod, function(system) system:SetPoolSize(value) end)
        end)

    api.addRangeInt(path,
        "Purple replay limit during Watson lockdown",
        "Used before The Heist lockdown ends. This strict replay-marker limit is 0-5, roughly one third of the full 17-site pool.",
        0, 5, 1, schedule.lockdownPoolSize, 2, function(value)
            schedule.lockdownPoolSize = value
            save(mod)
            updateSystem(mod, function(system) system:SetLockdownPoolSize(value) end)
        end)

    api.addRangeInt(path,
        "Hours before a cleared sighting returns",
        "A site cannot become a purple replay until this many in-game hours have passed after its original completion or latest replay clear. Changing this also rebases cooldowns already in progress. After a clear, leave 120 m so the defeated body can unload before that site returns.",
        1, 720, 1, schedule.cooldownHours, 24, function(value)
            schedule.cooldownHours = math.floor(value + 0.5)
            save(mod)
            updateSystem(mod, function(system) system:SetCooldownHours(schedule.cooldownHours) end)
        end)

    addConfigSwitch(api, path,
        "Use purple replay map markers",
        "Purple distinguishes mod-owned replays from the original blue Regina sightings. Reopen the map after changing it.",
        mod.settings.general, "changeMapMarkerColor", true, mod)
end

local function addCombatSettings(api, mod)
    local path = NativeUI.root .. "/combat"
    api.addSubcategory(path, "Enemy Power")
    local combat = mod.settings.combat
    addConfigSwitch(api, path, "Vanilla-style hostile-area detection",
        "When enabled, the cyberpsycho detects and engages you immediately after you enter its hostile encounter area, like an active Regina sighting.",
        combat, "heightenedAwareness", true, mod)
    addConfigSwitch(api, path, "Cyberpsychos counter stealth takedowns",
        "Blocks lethal and nonlethal stealth takedowns on replay cyberpsychos. A grab attempt alerts the boss, turns it toward you, and starts its counterattack.",
        combat, "blockStealthTakedowns", true, mod)
    addConfigFloat(api, path, "Enemy health", "Changes replay cyberpsycho health only. 1.00x is the normal game value.",
        combat, "healthMultiplier", 0.50, 5.00, 0.05, "%.2fx", 1.25, mod)
    addConfigFloat(api, path, "Enemy damage", "Changes replay cyberpsycho damage only. 1.00x is the normal game value.",
        combat, "damageMultiplier", 0.50, 5.00, 0.05, "%.2fx", 1.15, mod)
    addConfigFloat(api, path, "Enemy armor", "Changes replay cyberpsycho armor only. 1.00x is the normal game value.",
        combat, "armorMultiplier", 0.50, 5.00, 0.05, "%.2fx", 1.00, mod)
    addConfigFloat(api, path, "Enemy quickhack resistance", "Changes replay cyberpsycho quickhack resistance only. 1.00x is the normal game value.",
        combat, "quickhackResistanceMultiplier", 0.50, 5.00, 0.05, "%.2fx", 1.00, mod)
end

local function addRewardScaling(api, mod)
    local path = NativeUI.root .. "/rewardScaling"
    api.addSubcategory(path, "Reward Amounts")
    local reward = mod.settings.reward
    addConfigSwitch(api, path, "Clear bonus delivered to player",
        "Master switch for direct-to-player item, Level XP, and Street Cred rewards. If every Clear Bonus item category is disabled, the enabled Body Loot item rules are mirrored to the player so this switch never silently grants zero items.",
        reward, "completionEnabled", true, mod)
    addConfigFloat(api, path, "Overall reward chance", "1.00x uses each category's listed chance; higher values make rewards more likely.",
        reward, "chanceMultiplier", 0.00, 5.00, 0.05, "%.2fx", 1.00, mod)
    addConfigFloat(api, path, "Number of reward items", "1.00x uses each category's listed item count; higher values add more attempts.",
        reward, "itemCountMultiplier", 0.00, 5.00, 0.05, "%.2fx", 1.00, mod)
    addConfigFloat(api, path, "Ammunition and stack amount", "Changes the amount inside ammunition and other stacked rewards.",
        reward, "quantityMultiplier", 0.25, 10.00, 0.25, "%.2fx", 1.00, mod)
    addConfigInt(api, path, "Extra item tiers", "Raises generated reward tiers after matching them to the player.",
        reward, "tierBoost", 0, 4, 1, 0, mod)
    addConfigSwitch(api, path, "Cap rewards by player tier",
        "Prevents generated rewards from exceeding the player's current tier before the configured boost.",
        reward, "followPlayerTier", true, mod)
    addConfigInt(api, path, "Body minimum tier", "Minimum replay-boss body-loot tier.",
        reward, "bodyMinTier", 1, 5, 1, 1, mod)
    addConfigInt(api, path, "Body maximum tier", "Maximum replay-boss body-loot tier.",
        reward, "bodyMaxTier", 1, 5, 1, 2, mod)
    addConfigInt(api, path, "Completion reward minimum tier", "Minimum direct completion-reward tier.",
        reward, "cacheMinTier", 1, 5, 1, 1, mod)
    addConfigInt(api, path, "Completion reward maximum tier", "Maximum direct completion-reward tier.",
        reward, "cacheMaxTier", 1, 5, 1, 5, mod)
    addConfigInt(api, path, "Level XP", "Base level XP granted after a replay clear.",
        reward, "levelXP", 0, 10000, 50, 300, mod)
    addConfigFloat(api, path, "Level XP amount", "Changes the configured level XP. 1.00x uses the listed amount.",
        reward, "levelXPMultiplier", 0.00, 10.00, 0.10, "%.2fx", 1.00, mod)
    addConfigInt(api, path, "Street Cred XP", "Base Street Cred XP granted after a replay clear.",
        reward, "streetCredXP", 0, 10000, 50, 200, mod)
    addConfigFloat(api, path, "Street Cred XP amount", "Changes the configured Street Cred XP. 1.00x uses the listed amount.",
        reward, "streetCredMultiplier", 0.00, 10.00, 0.10, "%.2fx", 1.00, mod)
end

local function addDiagnosticSettings(api, mod)
    local path = NativeUI.root .. "/diagnostics"
    api.addSubcategory(path, "Diagnostics and Recovery")
    local diagnostics = mod.settings.diagnostics
    addConfigSwitch(api, path, "Write background diagnostic log",
        "Records scheduler, cooldown, marker, exact boss, fallback, and reward events in diagnostics.log for bug reports.",
        diagnostics, "enabled", true, mod)
    addConfigSwitch(api, path, "Recover a missing cyberpsycho",
        "Near an active marker, wait for the original community to stream; if its exact boss record is still absent, spawn and track that exact cyberpsycho at the vanilla boss workspot.",
        diagnostics, "missingBossFallback", true, mod)
end

local function addRewardRule(api, path, label, rule, defaultRule, mod)
    addConfigSwitch(api, path, label .. " enabled", "Allow this reward category.",
        rule, "enabled", defaultRule.enabled, mod)
    addConfigFloat(api, path, label .. " chance", "Base chance per draw before the global multiplier.",
        rule, "chance", 0.00, 1.00, 0.01, "%.2f", defaultRule.chance, mod)
    addConfigInt(api, path, label .. " draws", "Base number of draws before the item-count multiplier.",
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
        print("[Repeatable Cyberpsychos] Native Settings UI not found. Encounters still run automatically, but configuration is unavailable.")
        return false
    end

    api.addTab(NativeUI.root, "Repeatable Cyberpsycho Encounters", function()
        save(mod)
    end)

    addEncounterSettings(api, mod)
    addCombatSettings(api, mod)
    addDiagnosticSettings(api, mod)
    addRewardScaling(api, mod)
    addRewardRules(api, mod, "body", "Cyberpsycho Body Loot", {
        { key = "weapons", label = "Weapons", default = { enabled = true, chance = 0.85, draws = 1 } },
        { key = "iconics", label = "Iconic weapons", default = { enabled = true, chance = 0.03, draws = 1 } },
        { key = "shards", label = "Map-findable shards", default = { enabled = true, chance = 0.15, draws = 1 } },
        { key = "consumables", label = "Consumables", default = { enabled = true, chance = 0.75, draws = 2 } },
        { key = "ammo", label = "Ammunition", default = { enabled = true, chance = 1.00, draws = 3 } },
    })
    addRewardRules(api, mod, "cache", "Clear Bonus (Delivered to Player)", {
        { key = "weapons", label = "Weapons", default = { enabled = true, chance = 0.90, draws = 2 } },
        { key = "iconics", label = "Iconic weapons", default = { enabled = true, chance = 0.07, draws = 1 } },
        { key = "shards", label = "Map-findable shards", default = { enabled = true, chance = 0.30, draws = 1 } },
        { key = "consumables", label = "Consumables", default = { enabled = true, chance = 0.90, draws = 2 } },
        { key = "ammo", label = "Ammunition", default = { enabled = true, chance = 1.00, draws = 3 } },
        { key = "schemes", label = "Schemes and recipes", default = { enabled = true, chance = 0.35, draws = 1 } },
        { key = "attachments", label = "Attachments", default = { enabled = true, chance = 0.80, draws = 2 } },
        { key = "weaponMods", label = "Weapon mods", default = { enabled = true, chance = 0.65, draws = 2 } },
    })

    NativeUI.registered = true
    print("[Repeatable Cyberpsychos] Native Settings UI registered.")
    return true
end

return NativeUI
