local Config = {}

Config.defaults = {
    schemaVersion = 3,
    general = {
        changeMapMarkerColor = true,
    },
    schedule = {
        enabled = true,
        poolSize = 1,
        cooldownHours = 36.0,
        rosterPercent = 75,
        reinforcements = true,
        cleanupSeconds = 120,
        cleanupDistance = 150.0,
    },
    sites = {
        we_ep1_01 = { enabled = true, cooldownOverrideHours = 0.0 },
        we_ep1_05 = { enabled = true, cooldownOverrideHours = 0.0 },
        we_ep1_17 = { enabled = true, cooldownOverrideHours = 0.0 },
    },
    diagnostics = {
        enabled = true,
    },
    combat = {
        heightenedAwareness = true,
        regularHealth = 1.15,
        regularDamage = 1.10,
        regularArmor = 1.00,
        regularQuickhack = 1.00,
        bossHealth = 1.50,
        bossDamage = 1.25,
        bossArmor = 1.10,
        bossQuickhack = 1.10,
        growthPerClear = 0.00,
        growthCap = 20,
    },
    reward = {
        moneyMin = 5000,
        moneyMax = 10000,
        levelXP = 600,
        streetCredXP = 500,
        chanceMultiplier = 1.00,
        itemCountMultiplier = 1.00,
        quantityMultiplier = 1.00,
        tierBoost = 0,
        followPlayerTier = true,
        bodyMinTier = 1,
        bodyMaxTier = 3,
        clearMinTier = 2,
        clearMaxTier = 5,
        body = {
            weapons = { enabled = true, chance = 0.35, draws = 1 },
            iconics = { enabled = false, chance = 0.00, draws = 0 },
            shards = { enabled = true, chance = 0.08, draws = 1 },
            consumables = { enabled = true, chance = 0.45, draws = 1 },
            ammo = { enabled = true, chance = 0.75, draws = 2 },
            materials = { enabled = true, chance = 0.55, draws = 2 },
        },
        clear = {
            weapons = { enabled = true, chance = 0.75, draws = 1 },
            iconics = { enabled = false, chance = 0.00, draws = 0 },
            shards = { enabled = true, chance = 0.30, draws = 1 },
            consumables = { enabled = true, chance = 0.75, draws = 2 },
            ammo = { enabled = true, chance = 1.00, draws = 3 },
            materials = { enabled = true, chance = 1.00, draws = 4 },
            schemes = { enabled = true, chance = 0.20, draws = 1 },
            attachments = { enabled = true, chance = 0.65, draws = 1 },
            weaponMods = { enabled = true, chance = 0.50, draws = 1 },
        },
    },
}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = copy(child) end
    return result
end

local function merge(defaults, saved)
    local result = copy(defaults)
    if type(saved) ~= "table" then return result end
    for key, value in pairs(saved) do
        if defaults[key] ~= nil then
            if type(value) == "table" and type(result[key]) == "table" then
                result[key] = merge(result[key], value)
            elseif type(value) == type(defaults[key]) then
                result[key] = value
            end
        end
    end
    return result
end

local function migrate(saved)
    if type(saved) ~= "table" then return saved end
    local version = math.floor(tonumber(saved.schemaVersion) or 0)
    if version < 2 then
        -- v0.1.x displayed schedule changes made in the main menu but could not
        -- serialize them because no save-owned ScriptableSystem existed yet.
        -- Preserve the reported test profile for this upgrade; every value is
        -- still editable and will be durable from schema 2 onward.
        if type(saved.schedule) ~= "table" then
            saved.schedule = copy(Config.defaults.schedule)
            saved.schedule.poolSize = 3
            saved.schedule.cooldownHours = 1.0
        end
        if type(saved.sites) ~= "table" then
            saved.sites = copy(Config.defaults.sites)
        end
    end
    saved.schemaVersion = Config.defaults.schemaVersion
    return saved
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(maximum, value))
end

local function normalizeRule(rule)
    rule.enabled = rule.enabled == true
    rule.chance = clamp(rule.chance, 0.00, 1.00)
    rule.draws = math.floor(clamp(rule.draws, 0, 10))
end

local function normalize(settings)
    settings.schemaVersion = Config.defaults.schemaVersion
    settings.general.changeMapMarkerColor = settings.general.changeMapMarkerColor == true
    settings.diagnostics.enabled = settings.diagnostics.enabled ~= false

    local schedule = settings.schedule
    schedule.enabled = schedule.enabled == true
    schedule.poolSize = math.floor(clamp(schedule.poolSize, 0, 3))
    schedule.cooldownHours = clamp(schedule.cooldownHours, 1.0, 720.0)
    schedule.rosterPercent = math.floor(clamp(schedule.rosterPercent, 25, 100))
    schedule.reinforcements = schedule.reinforcements == true
    schedule.cleanupSeconds = math.floor(clamp(schedule.cleanupSeconds, 30, 900))
    schedule.cleanupDistance = clamp(schedule.cleanupDistance, 100.0, 500.0)

    for _, siteID in ipairs({ "we_ep1_01", "we_ep1_05", "we_ep1_17" }) do
        local site = settings.sites[siteID]
        site.enabled = site.enabled == true
        site.cooldownOverrideHours = clamp(site.cooldownOverrideHours, 0.0, 720.0)
    end

    local combat = settings.combat
    combat.regularHealth = clamp(combat.regularHealth, 0.50, 5.00)
    combat.regularDamage = clamp(combat.regularDamage, 0.50, 5.00)
    combat.regularArmor = clamp(combat.regularArmor, 0.50, 5.00)
    combat.regularQuickhack = clamp(combat.regularQuickhack, 0.50, 5.00)
    combat.bossHealth = clamp(combat.bossHealth, 0.50, 10.00)
    combat.bossDamage = clamp(combat.bossDamage, 0.50, 5.00)
    combat.bossArmor = clamp(combat.bossArmor, 0.50, 5.00)
    combat.bossQuickhack = clamp(combat.bossQuickhack, 0.50, 5.00)
    combat.growthPerClear = clamp(combat.growthPerClear, 0.00, 0.10)
    combat.growthCap = math.floor(clamp(combat.growthCap, 0, 100))

    local reward = settings.reward
    reward.moneyMin = math.floor(clamp(reward.moneyMin, 0, 100000))
    reward.moneyMax = math.floor(clamp(reward.moneyMax, reward.moneyMin, 100000))
    reward.levelXP = math.floor(clamp(reward.levelXP, 0, 10000))
    reward.streetCredXP = math.floor(clamp(reward.streetCredXP, 0, 10000))
    reward.chanceMultiplier = clamp(reward.chanceMultiplier, 0.00, 5.00)
    reward.itemCountMultiplier = clamp(reward.itemCountMultiplier, 0.00, 5.00)
    reward.quantityMultiplier = clamp(reward.quantityMultiplier, 0.25, 10.00)
    reward.tierBoost = math.floor(clamp(reward.tierBoost, 0, 4))
    reward.bodyMinTier = math.floor(clamp(reward.bodyMinTier, 1, 5))
    reward.bodyMaxTier = math.floor(clamp(reward.bodyMaxTier, reward.bodyMinTier, 5))
    reward.clearMinTier = math.floor(clamp(reward.clearMinTier, 1, 5))
    reward.clearMaxTier = math.floor(clamp(reward.clearMaxTier, reward.clearMinTier, 5))
    for _, rules in pairs({ reward.body, reward.clear }) do
        for _, rule in pairs(rules) do normalizeRule(rule) end
    end
    return settings
end

function Config.load(path)
    local saved = nil
    local file = io.open(path, "r")
    if file then
        local raw = file:read("*a")
        file:close()
        pcall(function() saved = json.decode(raw) end)
    end
    return normalize(merge(Config.defaults, migrate(saved)))
end

function Config.save(path, settings)
    normalize(settings)
    local file = io.open(path, "w+")
    if not file then return false end
    local ok, raw = pcall(json.encode, settings)
    if not ok then file:close(); return false end
    file:write(raw)
    file:close()
    return true
end

return Config
