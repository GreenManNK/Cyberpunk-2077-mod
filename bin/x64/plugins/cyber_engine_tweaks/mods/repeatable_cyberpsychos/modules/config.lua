local Config = {}

Config.defaults = {
    schemaVersion = 6,
    general = {
        changeMapMarkerColor = true,
    },
    schedule = {
        poolSize = 8,
        lockdownPoolSize = 2,
        cooldownHours = 24,
    },
    diagnostics = {
        enabled = true,
        missingBossFallback = true,
        fallbackDistance = 180.0,
        fallbackGraceSeconds = 60.0,
    },
    combat = {
        heightenedAwareness = true,
        blockStealthTakedowns = true,
        healthMultiplier = 1.25,
        damageMultiplier = 1.15,
        armorMultiplier = 1.00,
        quickhackResistanceMultiplier = 1.00,
    },
    reward = {
        completionEnabled = true,
        chanceMultiplier = 1.00,
        itemCountMultiplier = 1.00,
        quantityMultiplier = 1.00,
        tierBoost = 0,
        followPlayerTier = true,
        bodyMinTier = 1,
        bodyMaxTier = 2,
        cacheMinTier = 1,
        cacheMaxTier = 5,
        levelXP = 300,
        levelXPMultiplier = 1.00,
        streetCredXP = 200,
        streetCredMultiplier = 1.00,
        body = {
            weapons = { enabled = true, chance = 0.85, draws = 1 },
            iconics = { enabled = true, chance = 0.03, draws = 1 },
            shards = { enabled = true, chance = 0.15, draws = 1 },
            consumables = { enabled = true, chance = 0.75, draws = 2 },
            ammo = { enabled = true, chance = 1.00, draws = 3 },
        },
        cache = {
            weapons = { enabled = true, chance = 0.90, draws = 2 },
            iconics = { enabled = true, chance = 0.07, draws = 1 },
            shards = { enabled = true, chance = 0.30, draws = 1 },
            consumables = { enabled = true, chance = 0.90, draws = 2 },
            ammo = { enabled = true, chance = 1.00, draws = 3 },
            schemes = { enabled = true, chance = 0.35, draws = 1 },
            attachments = { enabled = true, chance = 0.80, draws = 2 },
            weaponMods = { enabled = true, chance = 0.65, draws = 2 },
        },
    },
}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end

local function merge(defaults, saved)
    local result = copy(defaults)
    if type(saved) ~= "table" then return result end
    for k, v in pairs(saved) do
        if defaults[k] ~= nil then
            if type(v) == "table" and type(result[k]) == "table" then
                result[k] = merge(result[k], v)
            else
                result[k] = v
            end
        end
    end
    return result
end

function Config.load(path)
    local saved = nil
    local file = io.open(path, "r")
    if file then
        local raw = file:read("*a")
        file:close()
        pcall(function() saved = json.decode(raw) end)
    end
    local settings = merge(Config.defaults, saved)
    settings.schemaVersion = Config.defaults.schemaVersion
    -- Native Settings uses an integer range in v0.4. Coerce old float saves so
    -- values such as 22.139999 no longer leak back into the scheduler.
    settings.schedule.cooldownHours = math.max(1, math.min(720,
        math.floor((tonumber(settings.schedule.cooldownHours) or 24) + 0.5)))
    return settings
end

function Config.save(path, settings)
    local file = io.open(path, "w+")
    if not file then return false end
    local ok, raw = pcall(json.encode, settings)
    if not ok then file:close(); return false end
    file:write(raw)
    file:close()
    return true
end

return Config
