local Rewards = { pools = nil, stats = nil }

local qualityRanks = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5 }

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
    local rendered = tostring(id)
    return rendered:match("(Items%.[%w_]+)")
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
    local lower = path:lower()
    if hasTag(record, "Quest") or hasTag(record, "QuestItem") then return false end
    return not lower:find("quest", 1, true)
        and not lower:find("debug", 1, true)
        and not lower:find("dummy", 1, true)
        and not lower:find("template", 1, true)
        and not lower:find("placeholder", 1, true)
end

local function entryFor(record, source)
    local path = pathFor(recordID(record))
    if not path or not safePath(record, path) then return nil end
    local lower = path:lower()
    local itemType = enumValue(record, "ItemType")
    local iconic = hasTag(record, "Iconic") or hasTag(record, "IconicItem")
        or hasTag(record, "IconicWeapon") or lower:find("iconic", 1, true) ~= nil
    local weapon = source == "gamedataWeaponItem_Record"
        or itemType:match("^Wea_") ~= nil
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
        attachment = lower:find("w_att_", 1, true) ~= nil
            or hasTag(record, "itemPart"),
        weaponMod = lower:find("weaponmod", 1, true) ~= nil
            or lower:find("genericmod", 1, true) ~= nil
            or lower:find("melee_mod", 1, true) ~= nil,
        consumable = itemType:match("^Con_") ~= nil
            or lower:find("consumable", 1, true) ~= nil
            or lower:find("inhaler", 1, true) ~= nil
            or lower:find("injector", 1, true) ~= nil,
    }
end

function Rewards.scan()
    local pools = {
        weapons = {}, iconics = {}, ammo = {}, consumables = {}, shards = {},
        schemes = {}, attachments = {}, weaponMods = {},
    }
    local seen, scanned = {}, 0
    for _, source in ipairs({ "gamedataItem_Record", "gamedataWeaponItem_Record" }) do
        local records = safe(function() return TweakDB:GetRecords(source) or {} end, {})
        for _, record in ipairs(records) do
            scanned = scanned + 1
            local entry = safe(function() return entryFor(record, source) end, nil)
            if entry and not seen[entry.path] then
                seen[entry.path] = true
                if entry.weapon then pools.weapons[#pools.weapons + 1] = entry end
                if entry.weapon and entry.iconic then pools.iconics[#pools.iconics + 1] = entry end
                if entry.ammo then pools.ammo[#pools.ammo + 1] = entry end
                if entry.consumable and not entry.ammo and not entry.shard and not entry.scheme then
                    pools.consumables[#pools.consumables + 1] = entry
                end
                if entry.shard then pools.shards[#pools.shards + 1] = entry end
                if entry.scheme then pools.schemes[#pools.schemes + 1] = entry end
                if entry.attachment and not entry.weaponMod then pools.attachments[#pools.attachments + 1] = entry end
                if entry.weaponMod then pools.weaponMods[#pools.weaponMods + 1] = entry end
            end
        end
    end
    Rewards.pools = pools
    Rewards.stats = { scanned = scanned }
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
    local minTier = settings.reward[location .. "MinTier"] or 1
    local maxTier = settings.reward[location .. "MaxTier"] or 5
    if settings.reward.followPlayerTier then
        maxTier = math.min(maxTier, math.max(minTier, playerTier() + settings.reward.tierBoost))
    end
    return minTier, maxTier
end

local function draw(pool, minTier, maxTier)
    local eligible = {}
    for _, entry in ipairs(pool or {}) do
        if entry.tier == 0 or (entry.tier >= minTier and entry.tier <= maxTier) then
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
    return math.max(1, math.floor(base * settings.reward.quantityMultiplier + 0.5))
end

local function adjustedDraws(rule, settings)
    return math.max(0, math.floor(rule.draws * settings.reward.itemCountMultiplier + 0.5))
end

local function roll(rule, settings)
    return rule.enabled and math.random() <= math.min(1.0,
        rule.chance * settings.reward.chanceMultiplier)
end

local function tryCyberwareScheme()
    local success = false
    pcall(function()
        local mod = GetMod("cyberware_schemes")
        if mod and mod.api and mod.api.learnRandomUnknownScheme then
            success = mod.api.learnRandomUnknownScheme() == true
        end
    end)
    return success
end

local function grantCategory(owner, category, rule, settings, location)
    if not roll(rule, settings) then return 0 end
    local count, minTier, maxTier = 0, bounds(settings, location)
    for _ = 1, adjustedDraws(rule, settings) do
        if category == "schemes" and tryCyberwareScheme() then
            count = count + 1
        else
            local entry = draw(Rewards.pools[category], minTier, maxTier)
            if entry and give(owner, entry.path, amountFor(category, settings)) then
                count = count + 1
            end
        end
    end
    return count
end

local function applyMultiplier(stats, objectID, statType, multiplier)
    if math.abs(multiplier - 1.0) < 0.001 or not statType then return end
    pcall(function()
        stats:AddSavedModifier(objectID,
            RPGManager.CreateStatModifier(statType, gameStatModifierType.Multiplier, multiplier))
    end)
end

function Rewards.applyCombat(boss, settings)
    if not boss then return end
    local objectID = safe(function() return boss:GetEntityID() end, nil)
    if not objectID then return end
    local stats = Game.GetStatsSystem()
    applyMultiplier(stats, objectID, gamedataStatType.Health, settings.combat.healthMultiplier)
    applyMultiplier(stats, objectID, gamedataStatType.DamagePerHit, settings.combat.damageMultiplier)
    applyMultiplier(stats, objectID, gamedataStatType.Armor, settings.combat.armorMultiplier)
    applyMultiplier(stats, objectID, gamedataStatType.HackingResistance,
        settings.combat.quickhackResistanceMultiplier)
end

function Rewards.grantBody(boss, settings)
    if not Rewards.pools then Rewards.scan() end
    local total = 0
    for _, category in ipairs({ "weapons", "iconics", "shards", "consumables", "ammo" }) do
        total = total + grantCategory(boss, category, settings.reward.body[category], settings, "body")
    end
    return total
end

local function anyRuleEnabled(rules, categories)
    for _, category in ipairs(categories) do
        if rules[category] and rules[category].enabled then return true end
    end
    return false
end

local function grantRules(owner, rules, categories, settings, location)
    local total = 0
    for _, category in ipairs(categories) do
        local rule = rules[category]
        if rule then
            total = total + grantCategory(owner, category, rule, settings, location)
        end
    end
    return total
end

local function grantXP(settings)
    local data = safe(function()
        local player = Game.GetPlayer()
        return PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player)
    end, nil)
    if not data then return end
    local levelXP = math.max(0, math.floor(settings.reward.levelXP
        * settings.reward.levelXPMultiplier + 0.5))
    local credXP = math.max(0, math.floor(settings.reward.streetCredXP
        * settings.reward.streetCredMultiplier + 0.5))
    if levelXP > 0 then
        pcall(function() data:AddExperience(levelXP, gamedataProficiencyType.Level,
            telemetryLevelGainReason.Ignore) end)
    end
    if credXP > 0 then
        pcall(function() data:AddExperience(credXP, gamedataProficiencyType.StreetCred,
            telemetryLevelGainReason.Ignore) end)
    end
end

function Rewards.grantCompletion(settings)
    if not Rewards.pools then Rewards.scan() end
    local player = Game.GetPlayer()
    if not player then return false, 0 end
    if settings.reward.completionEnabled == false then return true, 0, "disabled" end
    local cacheCategories = {
        "weapons", "iconics", "shards", "consumables", "ammo",
        "schemes", "attachments", "weaponMods",
    }
    local bodyCategories = { "weapons", "iconics", "shards", "consumables", "ammo" }
    local total, source
    if anyRuleEnabled(settings.reward.cache, cacheCategories) then
        total = grantRules(player, settings.reward.cache, cacheCategories, settings, "cache")
        source = "clearBonus"
    else
        -- A master switch that says "delivered to player" must not silently
        -- produce no items merely because its secondary category page is all
        -- off. Mirror the user's enabled body rules in that situation.
        total = grantRules(player, settings.reward.body, bodyCategories, settings, "body")
        source = "bodyRulesFallback"
    end
    grantXP(settings)
    return true, total, source
end

return Rewards
