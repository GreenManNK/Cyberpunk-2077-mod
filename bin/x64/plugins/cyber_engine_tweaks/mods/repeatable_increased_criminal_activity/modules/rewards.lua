local Rewards = { pools = nil, stats = nil }

local qualityRanks = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5 }
local deniedFragments = {
    "quest", "debug", "dummy", "template", "placeholder", "deprecated", "test_",
    "vendor", "we_ep1_01", "we_ep1_05", "we_ep1_17",
    "raiju", "agaou", "sparky", "preset_senkoh_prototype",
    "preset_axe_agaou", "preset_tomahawk_agaou", "preset_grad_sparky",
}

local function safe(fn, fallback)
    local ok, value = pcall(fn)
    if ok and value ~= nil then return value end
    return fallback
end

local function recordID(record)
    return safe(function() return record:GetID() end,
        safe(function() return record:GetRecordID() end, nil))
end

local function pathFor(id)
    if not id then return nil end
    local value = safe(function() return id.value end, nil)
    if type(value) == "string" and value:match("^Items%.") then return value end
    return tostring(id):match("(Items%.[%w_]+)")
end

local function enumValue(record, method)
    return safe(function() return record[method](record):Type().value end, "")
end

local function hasTag(record, tag)
    return safe(function() return record:TagsContains(CName.new(tag)) == true end, false)
end

local function tierFor(record, path)
    local quality = enumValue(record, "Quality")
    if qualityRanks[quality] then return qualityRanks[quality] end
    local lower = path:lower()
    if lower:find("legendary", 1, true) then return 5 end
    if lower:find("epic", 1, true) then return 4 end
    if lower:find("rare", 1, true) then return 3 end
    if lower:find("uncommon", 1, true) then return 2 end
    if lower:find("common", 1, true) then return 1 end
    return 0
end

local function safePath(record, path)
    if hasTag(record, "Quest") or hasTag(record, "QuestItem") then return false end
    local lower = path:lower()
    for _, fragment in ipairs(deniedFragments) do
        if lower:find(fragment, 1, true) then return false end
    end
    return true
end

local function entryFor(record, source)
    local path = pathFor(recordID(record))
    if not path or not safePath(record, path) then return nil end
    local lower = path:lower()
    local itemType = enumValue(record, "ItemType")
    local iconic = hasTag(record, "Iconic") or hasTag(record, "IconicItem")
        or hasTag(record, "IconicWeapon") or lower:find("iconic", 1, true) ~= nil
    local weapon = source == "gamedataWeaponItem_Record" or itemType:match("^Wea_") ~= nil
    return {
        path = path,
        tier = tierFor(record, path),
        iconic = iconic,
        weapon = weapon,
        ammo = itemType:find("Ammo", 1, true) ~= nil or lower:find("ammo", 1, true) ~= nil,
        shard = lower:find("shard", 1, true) ~= nil
            or lower:find("skillbook", 1, true) ~= nil
            or lower:find("permareward", 1, true) ~= nil,
        scheme = lower:find("recipe", 1, true) ~= nil
            or lower:find("schematic", 1, true) ~= nil,
        attachment = lower:find("w_att_", 1, true) ~= nil or hasTag(record, "itemPart"),
        weaponMod = lower:find("weaponmod", 1, true) ~= nil
            or lower:find("genericmod", 1, true) ~= nil
            or lower:find("melee_mod", 1, true) ~= nil,
        material = lower:find("material", 1, true) ~= nil
            or lower:find("crafting", 1, true) ~= nil
            or itemType:find("Crafting", 1, true) ~= nil,
        consumable = itemType:match("^Con_") ~= nil
            or lower:find("consumable", 1, true) ~= nil
            or lower:find("inhaler", 1, true) ~= nil
            or lower:find("injector", 1, true) ~= nil,
    }
end

function Rewards.scan()
    local pools = {
        weapons = {}, iconics = {}, ammo = {}, consumables = {}, shards = {},
        materials = {}, schemes = {}, attachments = {}, weaponMods = {},
    }
    local seen, scanned, denied = {}, 0, 0
    for _, source in ipairs({ "gamedataItem_Record", "gamedataWeaponItem_Record" }) do
        local records = safe(function() return TweakDB:GetRecords(source) or {} end, {})
        for _, record in ipairs(records) do
            scanned = scanned + 1
            local entry = safe(function() return entryFor(record, source) end, nil)
            if entry and not seen[entry.path] then
                seen[entry.path] = true
                if entry.weapon and not entry.iconic then pools.weapons[#pools.weapons + 1] = entry end
                if entry.weapon and entry.iconic then pools.iconics[#pools.iconics + 1] = entry end
                if entry.ammo then pools.ammo[#pools.ammo + 1] = entry end
                if entry.consumable and not entry.ammo and not entry.shard and not entry.scheme then
                    pools.consumables[#pools.consumables + 1] = entry
                end
                if entry.shard then pools.shards[#pools.shards + 1] = entry end
                if entry.material and not entry.scheme then pools.materials[#pools.materials + 1] = entry end
                if entry.scheme then pools.schemes[#pools.schemes + 1] = entry end
                if entry.attachment and not entry.weaponMod then pools.attachments[#pools.attachments + 1] = entry end
                if entry.weaponMod then pools.weaponMods[#pools.weaponMods + 1] = entry end
            elseif not entry then
                denied = denied + 1
            end
        end
    end
    Rewards.pools = pools
    Rewards.stats = { scanned = scanned, denied = denied }
    for name, list in pairs(pools) do Rewards.stats[name] = #list end
    return Rewards.stats
end

local function playerTier()
    local level = safe(function()
        return Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.Level)
    end, 1)
    return math.max(1, math.min(5, math.floor((level - 1) / 10) + 1))
end

local function bounds(settings, location)
    local minimum = settings.reward[location .. "MinTier"] or 1
    local maximum = settings.reward[location .. "MaxTier"] or 5
    if settings.reward.followPlayerTier then
        maximum = math.min(maximum, math.max(minimum, playerTier() + settings.reward.tierBoost))
    end
    return minimum, maximum
end

local function draw(pool, minimum, maximum)
    local eligible = {}
    for _, entry in ipairs(pool or {}) do
        if entry.tier == 0 or (entry.tier >= minimum and entry.tier <= maximum) then
            eligible[#eligible + 1] = entry
        end
    end
    if #eligible == 0 then return nil end
    return eligible[math.random(1, #eligible)]
end

local function give(owner, path, quantity)
    if not owner or not path then return false end
    local ok, result = pcall(function()
        return Game.GetTransactionSystem():GiveItem(
            owner, ItemID.FromTDBID(TweakDBID.new(path)), math.max(1, math.floor(quantity))
        )
    end)
    return ok and result ~= false
end

local function amountFor(category, settings)
    local base = 1
    if category == "ammo" then base = math.random(20, 60) end
    if category == "materials" then base = math.random(2, 6) end
    return math.max(1, math.floor(base * settings.reward.quantityMultiplier + 0.5))
end

local function adjustedDraws(rule, settings)
    return math.max(0, math.floor(rule.draws * settings.reward.itemCountMultiplier + 0.5))
end

local function roll(rule, settings)
    return rule.enabled and math.random() <= math.min(1.0,
        rule.chance * settings.reward.chanceMultiplier)
end

local function grantCategory(owner, category, rule, settings, location)
    if not rule or not roll(rule, settings) then return 0 end
    local count, minimum, maximum = 0, bounds(settings, location)
    for _ = 1, adjustedDraws(rule, settings) do
        local entry = draw(Rewards.pools[category], minimum, maximum)
        if entry and give(owner, entry.path, amountFor(category, settings)) then count = count + 1 end
    end
    return count
end

function Rewards.grantBody(actor, settings)
    if not actor then return false, 0 end
    if not Rewards.pools then Rewards.scan() end
    local total = 0
    for _, category in ipairs({
        "weapons", "iconics", "shards", "consumables", "ammo", "materials",
    }) do
        total = total + grantCategory(actor, category,
            settings.reward.body[category], settings, "body")
    end
    return true, total
end

local function grantXP(settings)
    local player = Game.GetPlayer()
    local data = safe(function()
        return PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player)
    end, nil)
    if not data then return end
    if settings.reward.levelXP > 0 then
        pcall(function() data:AddExperience(settings.reward.levelXP,
            gamedataProficiencyType.Level, telemetryLevelGainReason.Ignore) end)
    end
    if settings.reward.streetCredXP > 0 then
        pcall(function() data:AddExperience(settings.reward.streetCredXP,
            gamedataProficiencyType.StreetCred, telemetryLevelGainReason.Ignore) end)
    end
end

function Rewards.grantCompletion(settings)
    if not Rewards.pools then Rewards.scan() end
    local player = Game.GetPlayer()
    if not player then return false, 0, 0 end
    local money = math.random(settings.reward.moneyMin, settings.reward.moneyMax)
    if money > 0 and not give(player, "Items.money", money) then return false, 0, 0 end
    local total = 0
    for _, category in ipairs({
        "weapons", "iconics", "shards", "consumables", "ammo", "materials",
        "schemes", "attachments", "weaponMods",
    }) do
        total = total + grantCategory(player, category,
            settings.reward.clear[category], settings, "clear")
    end
    grantXP(settings)
    return true, total, money
end

return Rewards
