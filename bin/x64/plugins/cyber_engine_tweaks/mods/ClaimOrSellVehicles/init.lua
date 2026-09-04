local MOD_NAME = "ClaimOrSellVehicles"
local MOD_VERSION = "2.36a"
local MOD_DIR = "bin/x64/plugins/cyber_engine_tweaks/mods/ClaimOrSellVehicles/"

-- User-adjustable multipliers (saved to settings.json, editable via CET overlay)
local modConfig = {
    unlockFeeMultiplier = 1.0, -- 0.25 = quarter price, 2.0 = double price
    salePriceMultiplier = 1.0, -- 0.25 = quarter payout, 2.0 = double payout
    paintServiceCost = 2000,
    SETTINGS_FILE = "settings.json",
    SESSION_LOG_FILE = "cosv_session_log.txt",
    enableSettings = true, -- set to true to show price multiplier sliders in CET overlay
    enableDamageDiscount = true, -- set false if vehicle damage should not reduce sale price
    isXPReward = true, -- set false if you do not want sales to reward XP or Street Cred
    enableScannerTwintoneTabOverride = true, -- Keeps the scanner Twintone tab available on non-owned vehicles so players can inspect/copy vehicle appearances.
    enableAppearanceRefresh = true, -- debug-only appearance refresh probe for mounted foreign vehicles
    debugEnabled = true,
    enableDogtownDropoff = false,
    enableRawRecords = false, -- set true to add ALL vehicle records to garage list (not recommended)
    configurationWarningEnabled = true,
    slowUpdateInterval = 1.0,
    mapPinUpdateInterval = 2.0,
    cosvMappinDataProbeDone = false,
    cosvMappinDataAvailable = false,
    cosvMappinDataCtorError = nil,
    proximityUpdateInterval = 1.33333,
    cleanupUpdateInterval = 1.0,
    MAX_COSV_EXACT_SLOT_SCAN = 20,
    appearanceRefreshReturnDelay = 1.0,
    pendingVehicleDisposals = {},
    shopVehicleDisposalPoint = { x = -5333.950, y = 8005.013, z = 284.739, heading = 86.500 },
    vehicleDropRemoteReleaseDelay = 0.5,
    vehicleDropDespawnDelay = 3.0,
    transactionDisableRetryInterval = 1.0,
    transactionDisableRetryMaxAttempts = 3,
    doNotApplyRemoteHack = true,
    enableLastStandScaner = false,
}

local function DebugLog(...)
    if modConfig.debugEnabled ~= true then
        return
    end

    print("[COSV]", ...)
end

-- EDITING HERE IS NOT RECOMMENDED UNLESS YOU ARE COMFORTABLE

local salePricing = {
    unlockFeeMin = 2200,
    unlockFeeMax = 4400,
    defaultVehicleSalePrice = 5500,
    minimumVehicleSalePrice = 2500,
    ownedResaleBonus = 5000,
    ownedResaleBonusMinBasePrice = 10000,
    nomadBonus = 8000,
    barghestBonus = 6000, -- By the game lore all cars are armored and all Mahirs are weaponized
    wraithPriceMultiplier = 0.80,
    saleReceiptDuration = 8,
    saleXPReward = 1500,
    saleStreetCredReward = 200,
}
local function BuildFallbackMessages()
    return setmetatable({}, {
        __index = function()
            return "--*--"
        end,
    })
end

local function LoadModLuaTable(fileName, label)
    if not dofile then
        print("[COSV] failed to load " .. tostring(label))
        return nil
    end

    local candidates = {
        MOD_DIR .. fileName,
        "mods/ClaimOrSellVehicles/" .. fileName,
        fileName,
    }

    for _, path in ipairs(candidates) do
        local ok, result = pcall(dofile, path)
        if ok and type(result) == "table" then
            print("[COSV] loaded " .. tostring(label) .. " from " .. tostring(path))
            return result
        end
    end

    print("[COSV] failed to load " .. tostring(label))
    return nil
end

local function GetSettingsPathCandidates()
    return {
        MOD_DIR .. modConfig.SETTINGS_FILE,
        "mods/ClaimOrSellVehicles/" .. modConfig.SETTINGS_FILE,
        modConfig.SETTINGS_FILE,
    }
end

local function GetModFilePathCandidates(fileName)
    return {
        MOD_DIR .. fileName,
        "mods/ClaimOrSellVehicles/" .. fileName,
        fileName,
    }
end

local function SanitizeSessionLogValue(value)
    local text = tostring(value)
    text = string.gsub(text, "[\r\n]+", " ")
    text = string.gsub(text, "%s%s+", " ")
    return text
end

local function WriteSessionLogPayload(mode, payload)
    if not io or not io.open or type(payload) ~= "string" then
        return false, nil
    end

    for _, path in ipairs(GetModFilePathCandidates(modConfig.SESSION_LOG_FILE)) do
        local ok, fileHandle = pcall(io.open, path, mode)

        if ok and fileHandle then
            fileHandle:write(payload)
            fileHandle:close()
            return true, path
        end
    end

    return false, nil
end

local function ResetSessionLog(reason)
    local line = string.format(
        "[COSV] session version=%s reason=%s\n",
        SanitizeSessionLogValue(MOD_VERSION),
        SanitizeSessionLogValue(reason or "session_start")
    )

    return WriteSessionLogPayload("w", line)
end

local function AppendSessionLogLine(line)
    if type(line) ~= "string" or line == "" then
        return false, nil
    end

    return WriteSessionLogPayload("a", "[COSV] " .. SanitizeSessionLogValue(line) .. "\n")
end

local function LoadMessagesFile()
    local fallback = BuildFallbackMessages()
    local result = LoadModLuaTable("data/messages.lua", "data/messages.lua")
    if type(result) ~= "table" then
        return fallback
    end

    return result
end

local messages = LoadMessagesFile()

local function LookupMessage(key)
    if type(key) ~= "string" or key == "" then
        return "--*--"
    end

    local node = messages

    for part in string.gmatch(key, "[^%.]+") do
        if type(node) ~= "table" then
            return "--*--"
        end

        node = node[part]
        if node == nil then
            return "--*--"
        end
    end

    if type(node) ~= "string" or node == "" then
        return "--*--"
    end

    return node
end

local function Msg(key)
    return LookupMessage(key)
end

local function Fmt(key, values)
    local template = Msg(key)

    if template == "--*--" then
        return template
    end

    return string.gsub(template, "{([%w_]+)}", function(name)
        if values and values[name] ~= nil then
            return tostring(values[name])
        end

        return "--*--"
    end)
end

local function ShopText(shopKey, field)
    return Msg("shop." .. tostring(shopKey) .. "." .. tostring(field))
end

local function GetSessionLogShopName(shopOrKey)
    local shop = nil

    if type(shopOrKey) == "table" then
        shop = shopOrKey
    elseif shopOrKey ~= nil then
        shop = shopByKey and shopByKey[shopOrKey] or nil
    end

    if shop and type(shop.name) == "string" and shop.name ~= "" and shop.name ~= "--*--" then
        return shop.name
    end

    if shop and shop.key then
        return tostring(shop.key)
    end

    if shopOrKey == nil then
        return "Unknown Shop"
    end

    return tostring(shopOrKey)
end

local function LoadClaimRoutesFile()
    local fallback = {
        CLAIM_IGNORE_IDS = {},
        SALE_IGNORE_IDS = {},
        SIREN_ROUTE_RULES = {},
        CLAIM_ROUTE_RULES = {},
        DISPLAY_NAME_ROUTE_RULES = {},
    }
    local result = LoadModLuaTable("data/claim_routes.lua", "data/claim_routes.lua")
    if type(result) ~= "table" then
        return fallback
    end

    return {
        CLAIM_IGNORE_IDS = type(result.CLAIM_IGNORE_IDS) == "table" and result.CLAIM_IGNORE_IDS or {},
        SALE_IGNORE_IDS = type(result.SALE_IGNORE_IDS) == "table" and result.SALE_IGNORE_IDS or {},
        SIREN_ROUTE_RULES = type(result.SIREN_ROUTE_RULES) == "table" and result.SIREN_ROUTE_RULES or {},
        CLAIM_ROUTE_RULES = type(result.CLAIM_ROUTE_RULES) == "table" and result.CLAIM_ROUTE_RULES or {},
        DISPLAY_NAME_ROUTE_RULES = type(result.DISPLAY_NAME_ROUTE_RULES) == "table" and result.DISPLAY_NAME_ROUTE_RULES or {},
    }
end

local messageConfig = {
    transactionPrompt = Msg("prompt.transaction_leave_shop"),
    mountedZoneTransactionPrompt = Msg("prompt.mounted_zone_transaction"),
    rawRecordsClaimPrompt = Msg("prompt.raw_records_claim"),
    smugglerPaperworkPrompt = Msg("prompt.smuggler_paperwork"),
    mountedPaintPreviewPrompt = Msg("prompt.mounted_paint_preview"),
    paintPreviewFarewellMessage = Msg("notify.paint.farewell"),
    paintPreviewCancelMessage = Msg("notify.paint.canceled"),
    paintPreviewUnavailableMessage = Msg("notify.paint.unavailable"),
    vehicleSystemErrorMessage = Msg("notify.system.vehicle_system_error"),
    bikeOnlyShopRejectMessage = Msg("shop.watsonBikeBuyer.reject"),
    paintUnsupportedVehicleMessage = Msg("notify.paint.unsupported_vehicle"),
    paintClaimFailureMessage = Msg("notify.paint.claim_failure"),
    paintInsufficientFundsMessage = Msg("notify.paint.insufficient_funds"),
    garageAlterationWarning = Msg("notify.shop.garage_alteration_warning"),
}
local saleExcludedVehicleTokens = {
    -- Add lowercase full IDs or tokens here to make sell zones ignore matching vehicles.
    -- "vehicle.q000_example_quest_vehicle",
}
local alteration_detection_tokens = {
    ["Vehicle.v_standard2_villefort_cortes"] = true,
    ["Vehicle.cs_savable_villefort_cortes"] = true,
    ["Vehicle.hackable_villefort_cortes"] = true,
}
local DIRECT_SAFE_UNLOCK_IDS = {
    -- Add only fixed, garage-safe direct unlock records here when needed.
}

local function LoadCosvSlotBankFile()
    local result = LoadModLuaTable("data/cosv_slots.lua", "data/cosv_slots.lua")
    if type(result) ~= "table" then
        return {}
    end

    return result
end

local function LoadShopsFile()
    local result = LoadModLuaTable("data/shops.lua", "data/shops.lua")
    if type(result) ~= "table" then
        return {}
    end

    return result
end

local function NormalizeLoadedShop(shop)
    if type(shop) ~= "table" then
        return nil
    end

    local normalized = {}

    for key, value in pairs(shop) do
        normalized[key] = value
    end

    if normalized.name == nil and type(normalized.nameKey) == "string" and normalized.nameKey ~= "" and normalized.key then
        normalized.name = ShopText(normalized.key, normalized.nameKey)
    end

    if normalized.description == nil and type(normalized.descriptionKey) == "string" and normalized.descriptionKey ~= "" and normalized.key then
        normalized.description = ShopText(normalized.key, normalized.descriptionKey)
    end

    if normalized.rejectedVehicleMessage == nil and type(normalized.rejectedVehicleMessageKey) == "string" and normalized.rejectedVehicleMessageKey ~= "" then
        normalized.rejectedVehicleMessage = Msg(normalized.rejectedVehicleMessageKey)
    end

    normalized.nameKey = nil
    normalized.descriptionKey = nil
    normalized.rejectedVehicleMessageKey = nil

    return normalized
end

local function BuildShopsData()
    local loadedShops = LoadShopsFile()
    local normalizedShops = {}

    for _, shop in ipairs(loadedShops) do
        local normalized = NormalizeLoadedShop(shop)
        if normalized then
            table.insert(normalizedShops, normalized)
        end
    end

    return normalizedShops
end

local COSV_SLOT_BANK = LoadCosvSlotBankFile()



local claimRouteData = LoadClaimRoutesFile()
local CLAIM_IGNORE_IDS = claimRouteData.CLAIM_IGNORE_IDS or {}
local SELL_IGNORE_IDS = claimRouteData.SALE_IGNORE_IDS or {}
local SIREN_ROUTE_RULES = claimRouteData.SIREN_ROUTE_RULES or {}
local CLAIM_ROUTE_RULES = claimRouteData.CLAIM_ROUTE_RULES or {}
local DISPLAY_NAME_ROUTE_RULES = claimRouteData.DISPLAY_NAME_ROUTE_RULES or {}

local vehicleBasePrices = {
    { token = "rayfield_aerondight", price = 49000 },
    { token = "hellhound", price = 45000 },
    { token = "rayfield_caliburn", price = 39000 },
    { token = "herrera_riptide", price = 36000 },
    { token = "kaukaz_bratsk", price = 32000 },
    { token = "herrera_outlaw", price = 32000 },
    { token = "quadra_type66_nomad", price = 32000 },
    { token = "militech_behemoth", price = 30000 },
    { token = "quadra_sport_r7", price = 28000 },
    { token = "centurion", price = 26000 },
    { token = "legatus", price = 26000 },
    { token = "quadra_type66_avenger", price = 25000 },
    { token = "quadra_turbo", price = 23000 },
    { token = "quadra_type66_gt", price = 20000 },
    { token = "mib_van", price = 18000 },
    { token = "arch_", price = 18000 },
    { token = "quadra_type66_base", price = 16000 },
    { token = "merrimac", price = 16000 },
    { token = "quadra", price = 16000 },
    { token = "alvarado", price = 15000 },
    { token = "shion", price = 14000 },
    { token = "kusanagi", price = 14000 },
    { token = "cortes", price = 13000 },
    { token = "chevalier_emperor", price = 13000 },
    { token = "deleon", price = 11000 },
    { token = "mackinaw", price = 10000 },
    { token = "thrax", price = 10000 },
    { token = "colby_pickup", price = 9000 },
    { token = "apollo", price = 8000 },
    { token = "archer_", price = 8000 },
    { token = "hozuki", price = 8000 },
    { token = "columbus", price = 7500 },
    { token = "zeya", price = 7200 },
    { token = "vaquero", price = 7000 },
    { token = "colby__basic", price = 6500 },
}

local autofixerVehicleOwnership = {
    { vehicleID = "Vehicle.v_sportbike2_arch_player_02", ownedFact = "arch_02_owned" },
    { vehicleID = "Vehicle.v_sportbike2_arch_player_03", ownedFact = "arch_03_owned" },
    { vehicleID = "Vehicle.v_sportbike2_arch_player", ownedFact = "arch_owned" },
    { vehicleID = "Vehicle.v_standard2_archer_bandit_player", ownedFact = "archer_bandit_owned" },
    { vehicleID = "Vehicle.v_standard2_archer_quartz_base_player", ownedFact = "archer_quartz_base_owned" },
    { vehicleID = "Vehicle.v_standard2_archer_quartz_nomad_player_02", ownedFact = "archer_quartz_nomad_02_owned" },
    { vehicleID = "Vehicle.v_standard2_archer_quartz_nomad_player", ownedFact = "archer_quartz_nomad_owned" },
    { vehicleID = "Vehicle.v_standard2_archer_quartz_player", ownedFact = "archer_quartz_owned" },
    { vehicleID = "Vehicle.TWNC_archer_hella_combat_cab_player", ownedFact = "twnc_archer_hella_combat_cab_owned" },
    { vehicleID = "Vehicle.v_sportbike3_brennan_apollo_player_02", ownedFact = "brennan_apollo_02_owned" },
    { vehicleID = "Vehicle.v_sportbike3_brennan_apollo_player", ownedFact = "brennan_apollo_owned" },
    { vehicleID = "Vehicle.v_standard3_chevalier_emperor_player", ownedFact = "chevalier_emperor_owned" },
    { vehicleID = "Vehicle.v_utility4_chevalier_legatus_player", ownedFact = "chevalier_legatus_owned" },
    { vehicleID = "Vehicle.v_standard2_chevalier_thrax_player", ownedFact = "chevalier_thrax_owned" },
    { vehicleID = "Vehicle.TWNC_chevalier_thrax_combat_cab_player", ownedFact = "twnc_chevalier_thrax_combat_cab_owned" },
    { vehicleID = "Vehicle.delamain_taxi", ownedFact = "delamain_taxi_owned" },
    { vehicleID = "Vehicle.v_sport1_herrera_outlaw_player", ownedFact = "herrera_outlaw_owned" },
    { vehicleID = "Vehicle.v_sport1_herrera_riptide_player", ownedFact = "herrera_riptide_owned" },
    { vehicleID = "Vehicle.v_standard25_mahir_supron_gt_player", ownedFact = "mahir_supron_gt_owned" },
    { vehicleID = "Vehicle.v_standard3_mahir_supron_kurtz_player", ownedFact = "mahir_supron_kurtz_owned" },
    { vehicleID = "Vehicle.v_standard25_mahir_supron_player", ownedFact = "mahir_supron_owned" },
    { vehicleID = "Vehicle.v_standard2_makigai_maimai_player", ownedFact = "makigai_maimai_owned" },
    { vehicleID = "Vehicle.v_standard3_makigai_tanishi_player", ownedFact = "makigai_tanishi_owned" },
    { vehicleID = "Vehicle.v_standard3_militech_hellhound_player", ownedFact = "militech_hellhound_owned" },
    { vehicleID = "Vehicle.v_standard2_mizutani_hozuki_gt_player", ownedFact = "mizutani_hozuki_gt_owned" },
    { vehicleID = "Vehicle.v_standard2_mizutani_hozuki_player", ownedFact = "mizutani_hozuki_owned" },
    { vehicleID = "Vehicle.v_sport2_mizutani_shion_base_player", ownedFact = "mizutani_shion_base_owned" },
    { vehicleID = "Vehicle.v_sport2_mizutani_shion_nomad_player_missiles", ownedFact = "mizutani_shion_nomad_missiles_owned" },
    { vehicleID = "Vehicle.v_sport2_mizutani_shion_nomad_player", ownedFact = "mizutani_shion_nomad_owned" },
    { vehicleID = "Vehicle.v_sport2_mizutani_shion_player", ownedFact = "mizutani_shion_owned" },
    { vehicleID = "Vehicle.v_sport2_mizutani_shion_targa_player", ownedFact = "mizutani_shion_targa_owned" },
    { vehicleID = "Vehicle.v_sport1_quadra_sport_r7_player_02", ownedFact = "quadra_sport_r_7_02_owned" },
    { vehicleID = "Vehicle.v_sport1_quadra_sport_r7_player", ownedFact = "quadra_sport_r7_owned" },
    { vehicleID = "Vehicle.v_sport1_quadra_turbo_player", ownedFact = "quadra_turbo_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_avenger_player", ownedFact = "quadra_type66_avenger_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_base_player", ownedFact = "quadra_type66_base_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_gt_player", ownedFact = "quadra_type66_gt_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_nomad_player_03", ownedFact = "quadra_type66_nomad_03_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_nomad_player", ownedFact = "quadra_type66_nomad_owned" },
    { vehicleID = "Vehicle.v_sport2_quadra_type66_player", ownedFact = "quadra_type66_owned" },
    { vehicleID = "Vehicle.v_sport1_rayfield_aerondight_player", ownedFact = "rayfield_aerondight_owned" },
    { vehicleID = "Vehicle.v_sport1_rayfield_caliburn_player", ownedFact = "rayfield_caliburn_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_colby_gt_player", ownedFact = "thorton_colby_gt_owned" },
    { vehicleID = "Vehicle.v_standard25_thorton_colby_nomad_player_missiles", ownedFact = "thorton_colby_nomad_missiles_owned" },
    { vehicleID = "Vehicle.v_standard25_thorton_colby_nomad_player", ownedFact = "thorton_colby_nomad_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_colby_player", ownedFact = "thorton_colby_owned" },
    { vehicleID = "Vehicle.v_standard25_thorton_colby_pickup_kurtz_player", ownedFact = "thorton_colby_pickup_kurtz_owned" },
    { vehicleID = "Vehicle.v_standard25_thorton_colby_pickup_player", ownedFact = "thorton_colby_pickup_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_galena_gt_player", ownedFact = "thorton_galena_gt_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_galena_nomad_player_missiles", ownedFact = "thorton_galena_nomad_missiles_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_galena_nomad_player", ownedFact = "thorton_galena_nomad_owned" },
    { vehicleID = "Vehicle.v_standard2_thorton_galena_player", ownedFact = "thorton_galena_owned" },
    { vehicleID = "Vehicle.v_standard3_thorton_mackinaw_player", ownedFact = "thorton_mackinaw_owned" },
    { vehicleID = "Vehicle.v_standard25_thorton_merrimac_player", ownedFact = "thorton_merrimac_owned" },
    { vehicleID = "Vehicle.v_sport2_villefort_alvarado_hearse_player", ownedFact = "villefort_alvarado_hearse_owned" },
    { vehicleID = "Vehicle.v_sport2_villefort_alvarado_player", ownedFact = "villefort_alvarado_owned" },
    { vehicleID = "Vehicle.TWNC_villefort_alvarado_combat_cab_player", ownedFact = "twnc_villefort_alvarado_combat_cab_owned" },
    { vehicleID = "Vehicle.v_standard25_villefort_columbus_player", ownedFact = "villefort_columbus_owned" },
    { vehicleID = "Vehicle.v_standard2_villefort_cortes_player", ownedFact = "villefort_cortes_owned" },
    { vehicleID = "Vehicle.TWNC_villefort_cortes_combat_cab_player", ownedFact = "twnc_villefort_cortes_combat_cab_owned" },
    { vehicleID = "Vehicle.v_sport2_villefort_deleon_player", ownedFact = "villefort_deleon_owned" },
    { vehicleID = "Vehicle.v_sport2_villefort_deleon_sport_player", ownedFact = "villefort_deleon_sport_owned" },
    { vehicleID = "Vehicle.v_sportbike1_yaiba_kusanagi_player_02", ownedFact = "yaiba_kusanagi_02_owned" },
    { vehicleID = "Vehicle.v_sportbike1_yaiba_kusanagi_player_03", ownedFact = "yaiba_kusanagi_03_owned" },
    { vehicleID = "Vehicle.v_sportbike1_yaiba_kusanagi_player", ownedFact = "yaiba_kusanagi_owned" }
}

local appearancePriceClasses = {
    { key = "poor_junk", multiplier = 0.60, blocksOwnedResaleBonus = true, message = Msg("pricing.condition_low") },
    { key = "poor", multiplier = 0.70, blocksOwnedResaleBonus = true, message = Msg("pricing.condition_low") },

    { key = "maelstrom", multiplier = 0.70, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },
    { key = "sixth_street", multiplier = 0.75, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },
    { key = "6th_street", multiplier = 0.75, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },
    { key = "scav", multiplier = 0.70, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },

    { key = "mox", multiplier = 0.95, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },
    { key = "tyger", multiplier = 0.95, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },
    { key = "valentinos", multiplier = 0.95, blocksOwnedResaleBonus = true, message = Msg("pricing.gang_low") },

    { key = "barghest", multiplier = 0.980, blocksOwnedResaleBonus = true, message = Msg("pricing.parts_low") },
    { key = "police", bonus = 4000, blocksOwnedResaleBonus = true, message = Msg("pricing.police_bonus") },
    { key = "ncpd", bonus = 4000, blocksOwnedResaleBonus = true, message = Msg("pricing.police_bonus") },
    { key = "sheriff", bonus = 4000, blocksOwnedResaleBonus = true, message = Msg("pricing.police_bonus") },
    { key = "border_patrol", bonus = 4000, blocksOwnedResaleBonus = true, message = Msg("pricing.police_bonus") },
    { key = "militia", bonus = 4000, blocksOwnedResaleBonus = true, message = Msg("pricing.police_bonus") },

    { key = "arasaka", multiplier = 1.11, message = Msg("pricing.corporate_bonus") },
    { key = "militech", multiplier = 1.15, message = Msg("pricing.corporate_bonus") },
    { key = "kang", multiplier = 1.11, message = Msg("pricing.corporate_bonus") },
    { key = "netwatch", multiplier = 1.11, message = Msg("pricing.corporate_bonus") },
    { key = "zetatech", multiplier = 1.11, message = Msg("pricing.corporate_bonus") },
    { key = "trauma", multiplier = 1.11, message = Msg("pricing.corporate_bonus") },

    { key = "premium", multiplier = 1.155, message = Msg("pricing.premium_bonus") },
    { key = "luxury", multiplier = 1.155, message = Msg("pricing.premium_bonus") },
    { key = "sport", multiplier = 1.155, message = Msg("pricing.premium_bonus") },
    { key = "suburban", multiplier = 1.08, message = Msg("pricing.suburban_bonus") },
    { key = "urban", multiplier = 1.03, message = Msg("pricing.clean_condition_bonus") }
}

local shops = BuildShopsData()

local shopByKey = {}
for _, shop in ipairs(shops) do
    shopByKey[shop.key] = shop
end

local function IsShopEnabled(shop)
    if not shop then
        return false
    end

    if shop.dogtownOnly == true and modConfig.enableDogtownDropoff ~= true then
        return false
    end

    return true
end

local activeTransaction = false
local activeMode = nil
local activeShopKey = nil
local activeStartedAt = nil
local activeTransactionPayload = nil
local activeMountedZonePrompt = nil
local activeMountedZonePromptType = nil

local currentVehicle = nil
local currentRecordID = nil
local currentAppearance = nil
local currentScannerName = nil
local currentDisplayName = nil
local currentVehicleKey = nil
local currentVehicleIsPlayerVehicle = false
local isPlayerMounted = false
local lastLoggedEnteredVehicleKey = nil
local cosvSlotsAvailable = nil
local cosvSlotsDisabledReason = nil
local zeroEngine = nil
local zeroEnginePresent = false

local function DetectZeroEngine()
    if zeroEnginePresent == true then
        return true
    end

    local zeroEngineOk, zeroEngineCandidate = pcall(function()
        return GetMod("0-Engine")
    end)

    if zeroEngineOk == true
        and type(zeroEngineCandidate) == "table"
        and type(zeroEngineCandidate.GetState) == "function"
        and type(zeroEngineCandidate.GetPlayer) == "function"
        and type(zeroEngineCandidate.IsPlaying) == "function"
    then
        zeroEngine = zeroEngineCandidate
        zeroEnginePresent = true
        print("[COSV] 0-engine detected, will use 0-engine positioning.")
        return true
    end

    return false
end

DetectZeroEngine()

local settingsDirty = false
local nextSettingsSaveAt = nil
local settingsSaveDebounceSeconds = 5.0

local soldVehicleKeys = {}
local handledVehicleKeys = {}
local mapPins = {}
local shopPinsByHandle = {}
local selectedMapPin = nil
local selectedMapPinPosition = nil
local mapPinsSpawned = false

local pendingAppearanceRefreshes = {}
local shopCooldownUntil = {}
local nextShopCooldownRefreshAt = nil
local vehicleListPrimed = false
local claimedAppearanceRecordsPath = "bin/x64/plugins/cyber_engine_tweaks/mods/ClaimOrSellVehicles/claimed_appearance_records.txt"
local claimedAppearanceRecords = {}
local claimedAppearanceRecordsLoaded = false
local supportedVehicleAppearanceCache = {}
local nextSlowUpdateAt = nil
local nextMapPinUpdateAt = nil
local nextProximityUpdateAt = nil
local nextCleanupUpdateAt = nil
local pendingPostLoadVehicleRefresh = true
local postLoadVehicleRefreshDone = false
local wasPlayerReadyLastUpdate = false
local shopPinBootstrapDuration = 15.0
local shopPinBootstrapEndsAt = nil
local shopPinBootstrapActive = true
local overlayOpen = false
local declaredCOSVSlotLookup = nil
local declaredCOSVFamilyAppearanceLookup = nil
local paintPreviewStartDelaySeconds = 3.0
local paintPreviewIntervalSeconds = 10.0
local cosvGameplaySessionActive = false
local paintPreviewState = {
    active = false,
    manualMode = false,
    shopKey = nil,
    family = nil,
    vehicleID = nil,
    recordID = nil,
    vehicleKey = nil,
    originalAppearance = nil,
    selectedAppearance = nil,
    selectedFamily = nil,
    candidates = nil,
    candidateFamilies = nil,
    candidateIndex = 0,
    nextPreviewAt = nil,
}
local garageBackupState = {
    manualFileName = "cosv_manual_backup.json",
    lastTransactionFileName = "cosv_last_transaction_backup.json",
    lastActionMessage = nil,
    lastActionDetail = nil,
    lastManualCount = 0,
    lastTransactionCount = 0,
    lastRestoreCount = 0,
}
local pendingPaintPreviewUnavailable = nil
local lastPaintPreviewStartBlockedKey = nil
local lastPaintPreviewUnavailableNotifyKey = nil
local proximityState = {
    playerPosition = nil,
    currentShop = nil,
}
local alterationWarningShopKey = nil
local pendingConfigurationAlert = nil
local configurationAlertEndsAt = nil


function SafeCall(label, callback)
    local ok, result = pcall(callback)

    if not ok then
        print("[" .. MOD_NAME .. "] " .. tostring(label) .. " failed: " .. tostring(result))

        if label == "ProcessActiveTransaction"
            and activeTransaction == true
            and activeMode == "paint"
            and type(activeTransactionPayload) == "table"
            and activeTransactionPayload.paintCommitted == true
        then
            DebugLog("paint_commit_fail_safe garage=" .. tostring(activeTransactionPayload.committedGarageID) .. " reason=post_commit_exception")
            ResetVehicleContext()
        end
    end

    return ok, result
end

function GetEventOtherObject(evt)
    local ok, otherObject = pcall(function()
        return evt and evt.relationship and evt.relationship.otherObject or nil
    end)

    if ok then
        return otherObject
    end

    return nil
end

function GetScannedVehicleRecordIDValue(obj)
    local ok, id = pcall(function()
        if not obj or not obj:IsVehicle() then
            return nil
        end

        local record = obj:GetRecord()
        if not record then
            return nil
        end

        local tweakID = record:GetID()
        if tweakID and tweakID.value then
            return tweakID.value
        end

        local recordID = record:GetRecordID()
        if recordID and recordID.value then
            return recordID.value
        end

        return nil
    end)

    if ok then
        return id
    end

    return nil
end

function GetMapPinWorldPosition(pin)
    local ok, pos = pcall(function()
        if not pin or not pin.GetWorldPosition then
            return nil
        end

        return ToVector4(pin:GetWorldPosition())
    end)

    if ok then
        return pos
    end

    return nil
end

function DistanceBetween(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function GetPlayerPositionDirect()
    local player = Game.GetPlayer()
    if not player then
        return nil
    end

    local ok, pos = pcall(function()
        return player:GetWorldTransform():GetWorldPosition():ToVector4()
    end)

    if ok and pos then
        return pos
    end

    ok, pos = pcall(function()
        return player:GetWorldPosition()
    end)

    if ok and pos then
        return pos
    end

    return nil
end

function GetPlayerPositionZeroEngine()
    local ok, pos = pcall(function()
        if zeroEngine.IsPlaying() ~= true or not zeroEngine.GetPlayer() then
            return nil
        end

        local state = zeroEngine.GetState()
        return state and state.pos or nil
    end)

    if ok then
        return pos
    end

    return nil
end

function GetPlayerPosition()
    if zeroEnginePresent == true then
        return GetPlayerPositionZeroEngine()
    end

    return GetPlayerPositionDirect()
end

function Notify(message, duration, messageType, visible)
    local text = SimpleScreenMessage.new()
    text.duration = duration
    text.message = message
    text.isInstant = true
    text.isShown = visible
    text.type = messageType
    Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_Notifications):SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(text), true)
end

function HideMountedZonePrompt()
    if not activeMountedZonePrompt then
        return
    end

    Notify(activeMountedZonePrompt, 5, activeMountedZonePromptType or gameSimpleMessageType.Relic, false)
    activeMountedZonePrompt = nil
    activeMountedZonePromptType = nil
end

function ShowMountedZonePrompt(message, messageType)
    if not message or message == "" then
        HideMountedZonePrompt()
        return
    end

    messageType = messageType or gameSimpleMessageType.Relic

    if activeMountedZonePrompt == message and activeMountedZonePromptType == messageType then
        return
    end

    HideMountedZonePrompt()
    Notify(message, 5, messageType, true)
    activeMountedZonePrompt = message
    activeMountedZonePromptType = messageType
end

function IsPlayerReady()
    return Game.GetPlayer() ~= nil and Game.GetVehicleSystem() ~= nil
end

function IsGamePaused()
    return Game.GetSystemRequestsHandler() and Game.GetSystemRequestsHandler():IsGamePaused()
end

function GetGameTimeSeconds()
    if not Game.GetTimeSystem then
        return nil
    end

    local ok, gameTime = pcall(function()
        local timeSystem = Game.GetTimeSystem()
        if not timeSystem then
            return nil
        end

        return timeSystem:GetGameTime()
    end)

    if not ok or not gameTime then
        return nil
    end

    local okSeconds, seconds = pcall(function()
        return gameTime.seconds
    end)

    if okSeconds and seconds ~= nil then
        return tonumber(seconds)
    end

    local text = tostring(gameTime)
    local parsedSeconds = string.match(text, "seconds:%s*(%d+)")

    if parsedSeconds then
        return tonumber(parsedSeconds)
    end

    return nil
end

function UpdateNextShopCooldownRefresh()
    local now = GetGameTimeSeconds()
    local nextAt = nil

    for _, shop in ipairs(shops) do
        if IsShopEnabled(shop) then
            local untilTime = shopCooldownUntil[shop.key]

            if shop.cooldownGameSeconds and untilTime and (not now or untilTime > now) then
                if not nextAt or untilTime < nextAt then
                    nextAt = untilTime
                end
            end
        end
    end

    nextShopCooldownRefreshAt = nextAt
end

function IsShopOnCooldown(shop)
    if not shop or not shop.cooldownGameSeconds then
        return false
    end

    local now = GetGameTimeSeconds()
    local untilTime = shopCooldownUntil[shop.key]

    if not now or not untilTime then
        return false
    end

    if now >= untilTime then
        shopCooldownUntil[shop.key] = nil
        UpdateNextShopCooldownRefresh()
        return false
    end

    return true
end

function StartShopCooldown(shop)
    if not shop or not shop.cooldownGameSeconds then
        return false
    end

    local now = GetGameTimeSeconds()
    if not now then
        return false
    end

    shopCooldownUntil[shop.key] = now + shop.cooldownGameSeconds
    UpdateNextShopCooldownRefresh()
    return true
end

function RefreshExpiredShopCooldowns()
    if not nextShopCooldownRefreshAt then
        return
    end

    local now = GetGameTimeSeconds()
    if not now or now < nextShopCooldownRefreshAt then
        return
    end

    local expired = false

    for key, untilTime in pairs(shopCooldownUntil) do
        if untilTime and now >= untilTime then
            shopCooldownUntil[key] = nil
            expired = true
        end
    end

    UpdateNextShopCooldownRefresh()

    if expired then
        ClearMapPins()
    end
end

function GetVehicleRecordText(vehicle)
    if not vehicle then
        return nil
    end

    local ok, recordID = pcall(function()
        return vehicle:GetRecord():GetID()
    end)

    if ok and recordID then
        return tostring(recordID.value)
    end

    return nil
end

function GetVehicleAppearanceText(vehicle)
    if not vehicle then
        return nil
    end

    local ok, appearance = pcall(function()
        return vehicle:GetCurrentAppearanceName()
    end)

    if ok and appearance then
        local text = ExtractGameNameText(appearance)

        if text and text ~= "" and text ~= "None" then
            return text
        end
    end

    return nil
end

function ExtractGameNameText(value)
    if not value then
        return nil
    end

    local okValue, rawValue = pcall(function()
        return value.value
    end)

    local text = nil

    if okValue and rawValue then
        text = tostring(rawValue)
    else
        text = tostring(value)
    end

    if not text or text == "" then
        return nil
    end

    local begin1, end1 = string.find(text, "%-%-%[%[ ")
    local begin2, end2 = string.find(text, " %-%-%]%]")

    if end1 and begin2 then
        return string.sub(text, end1 + 1, begin2 - 1)
    end

    return text
end

function GetVehicleAppearancePriceText(vehicle)
    if not vehicle then
        return nil
    end

    local ok, appearance = pcall(function()
        return vehicle:GetCurrentAppearanceName()
    end)

    if not ok or not appearance then
        return nil
    end

    return ExtractGameNameText(appearance)
end

function HasTweakDBRecord(recordID)
    if not recordID or not TweakDB or not TweakDB.GetRecord then
        return false
    end

    local ok, record = pcall(function()
        return TweakDB:GetRecord(recordID)
    end)

    return ok == true and record ~= nil
end

function GetSupportedVehicleAppearances(recordID)
    if type(recordID) ~= "string" or recordID == "" then
        return {}
    end

    local cached = supportedVehicleAppearanceCache[recordID]
    if cached then
        return cached
    end

    local results = {}
    local seen = {}

    local ok, err = pcall(function()
        if not TweakDB or not TweakDB.GetFlat or not Game.GetResourceDepot then
            return
        end

        local templatePath = TweakDB:GetFlat(recordID .. ".entityTemplatePath")

        if not templatePath and TweakDBID and TweakDBID.new then
            templatePath = TweakDB:GetFlat(TweakDBID.new(recordID .. ".entityTemplatePath"))
        end

        if not templatePath then
            return
        end

        -- CET may return entityTemplatePath as userdata ResourcePath, not a Lua string.
        -- Game.GetResourceDepot():LoadResource(...) accepts that userdata directly.
        -- Do not reject it by type.
        local token = Game.GetResourceDepot():LoadResource(templatePath)
        if not token then
            return
        end

        local template = token:GetResource()
        if not template or not template.appearances then
            return
        end

        for _, appearance in ipairs(template.appearances) do
            local appName = nil
            local okName, rawName = pcall(function()
                return NameToString(appearance.name)
            end)

            if okName and rawName then
                appName = tostring(rawName)
            else
                appName = ExtractGameNameText(appearance and appearance.name or nil)
            end

            if IsUsefulAppearanceName(appName) then
                local normalized = NormalizeAppearanceName(appName)
                if normalized and not seen[normalized] then
                    seen[normalized] = true
                    table.insert(results, appName)
                end
            end
        end
    end)

    if ok ~= true then
        if modConfig.debugEnabled == true then
            DebugLog("GetSupportedVehicleAppearances failed: record=" .. tostring(recordID) .. " err=" .. tostring(err))
        end
        results = {}
    end

    if #results > 0 then
        supportedVehicleAppearanceCache[recordID] = results
    end

    return results
end

-- GetVehicleDisplayName: reads .displayName flat from TweakDB, resolves LocKey if present.
-- Returns the localized human-readable vehicle name, or nil on any failure.
-- Used for scanner-identity probing and potential future display-name-based routing.
function GetVehicleDisplayName(recordIDStr)
    if not recordIDStr or recordIDStr == "" then
        return nil
    end

    if not TweakDB or not TweakDB.GetFlat then
        return nil
    end

    local okFlat, flat = pcall(function()
        return TweakDB:GetFlat(recordIDStr .. ".displayName")
    end)

    if not okFlat or flat == nil then
        return nil
    end

    local flatStr = tostring(flat)

    if flatStr == "" or flatStr == "nil" then
        return nil
    end

    -- Flat value may arrive as "LocKey#12345" or wrapped as "LocKey(#12345)" etc.
    -- Extract the raw digit sequence and rebuild a canonical LocKey string.
    local digits = string.match(flatStr, "(%d+)")

    if digits then
        local locKey = "LocKey#" .. digits
        local okLoc, localized = pcall(function()
            return Game.GetLocalizedText(locKey)
        end)

        if okLoc and type(localized) == "string" and localized ~= "" and localized ~= locKey then
            return localized
        end
    end

    -- Fallback: return raw flat string if it looks like plain text (no LocKey digits found).
    if not string.match(flatStr, "^%d+$") then
        return flatStr
    end

    return nil
end

local function NormalizeVehicleDisplayName(displayName)
    local text = tostring(displayName or "")

    if text == "" or text == "nil" then
        return nil
    end

    text = string.gsub(text, "\194\160", " ")
    text = string.gsub(text, "\226\128\156", "\"")
    text = string.gsub(text, "\226\128\157", "\"")
    text = string.gsub(text, "\226\128\152", "'")
    text = string.gsub(text, "\226\128\153", "'")
    text = string.gsub(text, "\195\128", "a")
    text = string.gsub(text, "\195\129", "a")
    text = string.gsub(text, "\195\130", "a")
    text = string.gsub(text, "\195\131", "a")
    text = string.gsub(text, "\195\132", "a")
    text = string.gsub(text, "\195\133", "a")
    text = string.gsub(text, "\195\168", "e")
    text = string.gsub(text, "\195\169", "e")
    text = string.gsub(text, "\195\170", "e")
    text = string.gsub(text, "\195\171", "e")
    text = string.gsub(text, "\195\172", "i")
    text = string.gsub(text, "\195\173", "i")
    text = string.gsub(text, "\195\174", "i")
    text = string.gsub(text, "\195\175", "i")
    text = string.gsub(text, "\195\178", "o")
    text = string.gsub(text, "\195\179", "o")
    text = string.gsub(text, "\195\180", "o")
    text = string.gsub(text, "\195\181", "o")
    text = string.gsub(text, "\195\182", "o")
    text = string.gsub(text, "\195\185", "u")
    text = string.gsub(text, "\195\186", "u")
    text = string.gsub(text, "\195\187", "u")
    text = string.gsub(text, "\195\188", "u")
    text = string.gsub(text, "\195\177", "n")
    text = string.gsub(text, "\195\167", "c")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    text = string.gsub(text, "%s+", " ")
    text = string.lower(text)

    if text == "" then
        return nil
    end

    return text
end

local function DescribeStringBytes(text)
    text = tostring(text or "")

    if text == "" then
        return ""
    end

    local bytes = {}

    for i = 1, #text do
        bytes[#bytes + 1] = tostring(string.byte(text, i))
    end

    return table.concat(bytes, ",")
end

local function ResolveDisplayNameRoute(rawRecordID, preferredDisplayName)
    local displayName = NormalizeVehicleDisplayName(preferredDisplayName)

    if not displayName then
        displayName = NormalizeVehicleDisplayName(GetVehicleDisplayName(rawRecordID))
    end

    if not displayName then
        return nil, nil
    end

    return FindClaimRouteByDisplayName(displayName), displayName
end

function IsUsefulAppearanceName(appearance)
    if not appearance then
        return false
    end

    local text = tostring(appearance)

    return text ~= "" and text ~= "None" and text ~= "nil"
end

local function ValidateCOSVSlotInfrastructure()
    if cosvSlotsAvailable ~= nil then
        return cosvSlotsAvailable
    end

    local sentinel = "Vehicle.v_standard2_villefort_cortes_cosv_overflow_neutral_slot01"

    if HasTweakDBRecord(sentinel) ~= true then
        cosvSlotsAvailable = false
        cosvSlotsDisabledReason = "missing_cortez_cosv_sentinel"
        DebugLog("controlled slot sentinel missing: " .. sentinel)
        DebugLog("COSV router disabled; fallback/direct only")
        return false
    end

    cosvSlotsAvailable = true
    cosvSlotsDisabledReason = nil
    DebugLog("controlled slot infrastructure loaded")
    return true
end

local function LogLifecycleBlock(title, lines)
    DebugLog(title)

    for _, line in ipairs(lines or {}) do
        DebugLog("  " .. tostring(line))
    end
end

local function LogEnteredVehicle()
    if not currentVehicle or not currentRecordID then
        return
    end

    local vehicleKey = currentVehicleKey or GetVehicleWorldKey(currentVehicle) or (tostring(currentRecordID) .. "|" .. tostring(currentAppearance))

    if lastLoggedEnteredVehicleKey == vehicleKey then
        return
    end

    lastLoggedEnteredVehicleKey = vehicleKey
    local scannerName = currentScannerName or currentDisplayName or "n/a"
    local owned = currentVehicleIsPlayerVehicle == true

    DebugLog(
        "Boarded: " .. tostring(currentRecordID)
        .. " Appearance: " .. tostring(currentAppearance)
        .. " Scanner: " .. tostring(scannerName)
        .. " Owned: " .. tostring(owned)
    )
    AppendSessionLogLine(
        "boarded source=" .. tostring(currentRecordID)
        .. " app=" .. tostring(currentAppearance)
        .. " scanner=" .. tostring(scannerName)
        .. " owned=" .. tostring(owned)
    )
end

local function LogClaimResult(claimTarget)
    local routeFamily = nil

    if claimTarget.mode == "ignore" then
        routeFamily = "ignored"
    elseif claimTarget.route and claimTarget.route.family then
        routeFamily = tostring(claimTarget.route.family)
    end

    local backendStatus = "ok"
    local slotStatus = "n/a"

    if claimTarget.status == "cosv_disabled_slots_missing" then
        backendStatus = "failed"
        slotStatus = "n/a"
    elseif claimTarget.mode == "ignore" then
        backendStatus = "n/a"
        slotStatus = "ignored"
    elseif claimTarget.controlled and claimTarget.controlled.status == "exact" then
        slotStatus = "exact"
    elseif claimTarget.controlled and claimTarget.controlled.status == "overflow" then
        slotStatus = "overflow"
    elseif claimTarget.mode == "fallback_after_cosv_miss" then
        slotStatus = "not_found"
    end

    local line = "claim source=" .. tostring(currentRecordID)
        .. " app=" .. tostring(currentAppearance)
        .. " mode=" .. tostring(claimTarget.mode)
        .. " backend=" .. backendStatus
        .. " slot=" .. slotStatus
        .. " garage=" .. tostring(claimTarget.garageID)

    if routeFamily and routeFamily ~= "" then
        line = line .. " route=" .. routeFamily
    end

    if type(claimTarget.selectedFamily) == "string" and claimTarget.selectedFamily ~= "" and claimTarget.selectedFamily ~= routeFamily then
        line = line .. " selected=" .. tostring(claimTarget.selectedFamily)
    end

    if type(claimTarget.recoveryKind) == "string" and claimTarget.recoveryKind ~= "" then
        line = line .. " recovery=" .. tostring(claimTarget.recoveryKind)
    end

    DebugLog(line)
    AppendSessionLogLine(line)
end

function NormalizeAppearanceName(appearance)
    if not IsUsefulAppearanceName(appearance) then
        return nil
    end

    local s = string.lower(tostring(appearance))
    return s
end

local function ClearPaintPreviewState()
    paintPreviewState.active = false
    paintPreviewState.manualMode = false
    paintPreviewState.shopKey = nil
    paintPreviewState.family = nil
    paintPreviewState.vehicleID = nil
    paintPreviewState.recordID = nil
    paintPreviewState.vehicleKey = nil
    paintPreviewState.originalAppearance = nil
    paintPreviewState.selectedAppearance = nil
    paintPreviewState.selectedFamily = nil
    paintPreviewState.candidates = nil
    paintPreviewState.candidateFamilies = nil
    paintPreviewState.candidateIndex = 0
    paintPreviewState.nextPreviewAt = nil
end

local function ClearPaintPreviewStartBlockedLog()
    lastPaintPreviewStartBlockedKey = nil
end

local function ClearPaintPreviewUnavailableNotify()
    lastPaintPreviewUnavailableNotifyKey = nil
end

local function ClearPendingPaintPreviewUnavailable()
    pendingPaintPreviewUnavailable = nil
end

local function QueuePendingPaintPreviewUnavailable(message, messageType)
    if type(message) ~= "string" or message == "" then
        pendingPaintPreviewUnavailable = nil
        return
    end

    pendingPaintPreviewUnavailable = {
        message = message,
        messageType = messageType or gameSimpleMessageType.Undefined,
    }
end

local function ApplyVehicleAppearance(vehicle, appearance)
    if not vehicle or IsUsefulAppearanceName(appearance) ~= true then
        return false
    end

    local ok = pcall(function()
        vehicle:PrefetchAppearanceChange(appearance)
        vehicle:ScheduleAppearanceChange(appearance)
    end)

    return ok == true
end

local function BuildDeclaredCOSVLookups()
    if declaredCOSVSlotLookup and declaredCOSVFamilyAppearanceLookup then
        return declaredCOSVSlotLookup, declaredCOSVFamilyAppearanceLookup
    end

    local slotLookup = {}
    local familyAppearanceLookup = {}

    for family, familyBank in pairs(COSV_SLOT_BANK or {}) do
        local declaredAppearances = {}

        if type(familyBank.exactTemplates) == "table" then
            for declaredAppearance, template in pairs(familyBank.exactTemplates) do
                local normalizedAppearance = NormalizeAppearanceName(declaredAppearance)

                if normalizedAppearance and not declaredAppearances[normalizedAppearance] then
                    declaredAppearances[normalizedAppearance] = declaredAppearance
                end

                if type(template) == "string" and template ~= "" then
                    for slotIndex = 1, modConfig.MAX_COSV_EXACT_SLOT_SCAN do
                        local candidateID = string.format(template, slotIndex)

                        if HasTweakDBRecord(candidateID) == true then
                            slotLookup[candidateID] = {
                                family = family,
                                vehicleID = candidateID,
                                appearance = declaredAppearance,
                                slot = slotIndex,
                                kind = "exact",
                            }
                        end
                    end
                end
            end
        end

        for _, entry in ipairs(familyBank.overflowSlots or {}) do
            if type(entry) == "table" and type(entry.vehicleID) == "string" and entry.vehicleID ~= "" then
                local normalizedAppearance = NormalizeAppearanceName(entry.appearance)

                if normalizedAppearance and not declaredAppearances[normalizedAppearance] then
                    declaredAppearances[normalizedAppearance] = entry.appearance
                end

                if HasTweakDBRecord(entry.vehicleID) == true then
                    slotLookup[entry.vehicleID] = {
                        family = family,
                        vehicleID = entry.vehicleID,
                        appearance = entry.appearance,
                        slot = entry.slot,
                        kind = "overflow",
                    }
                end
            end
        end

        familyAppearanceLookup[family] = declaredAppearances
    end

    declaredCOSVSlotLookup = slotLookup
    declaredCOSVFamilyAppearanceLookup = familyAppearanceLookup
    return declaredCOSVSlotLookup, declaredCOSVFamilyAppearanceLookup
end

local function ResolveDeclaredCOSVSlotMatch(recordID, garageID)
    local slotLookup = BuildDeclaredCOSVLookups()

    if type(recordID) == "string" and recordID ~= "" and slotLookup[recordID] then
        return slotLookup[recordID], "recordID"
    end

    if type(garageID) == "string" and garageID ~= "" and slotLookup[garageID] then
        return slotLookup[garageID], "garageID"
    end

    return nil, nil
end

local function IsPotentialCOSVPaintVehicle(vehicle, recordID)
    if not vehicle or type(recordID) ~= "string" or recordID == "" then
        return false, "invalid_context"
    end

    if string.find(recordID, "^Vehicle%.") == nil
        or string.find(string.lower(recordID), "_cosv_", 1, true) == nil
    then
        return false, "not_cosv_slot"
    end

    local playerVehicleOk, isPlayerVehicle = pcall(function()
        return vehicle:IsPlayerVehicle()
    end)

    if playerVehicleOk ~= true or isPlayerVehicle ~= true then
        return false, "not_player_vehicle"
    end

    return true, nil
end

local function ResolveCurrentCOSVPaintContext(vehicle, recordID, appearance)
    local context = {
        ok = false,
        reason = nil,
        family = nil,
        recordID = recordID,
        garageID = nil,
        currentAppearance = appearance,
        slotAppearance = nil,
        previewBaseAppearance = appearance,
        currentSlot = nil,
        currentSlotVehicleID = nil,
        matchedBy = nil,
        vehicleKey = nil,
    }

    local isPotentialCandidate, candidateReason = IsPotentialCOSVPaintVehicle(vehicle, recordID)

    if isPotentialCandidate ~= true then
        context.reason = candidateReason
        return context
    end

    context.vehicleKey = currentVehicleKey or GetVehicleWorldKey(vehicle)

    local slotEntry, matchedBy = ResolveDeclaredCOSVSlotMatch(recordID, nil)

    if not slotEntry then
        context.reason = "not_cosv_slot"
        return context
    end

    local familyBank = COSV_SLOT_BANK and COSV_SLOT_BANK[slotEntry.family] or nil
    if type(familyBank) == "table" and familyBank.paintEligible == false then
        context.reason = "not_cosv_slot"
        return context
    end

    context.ok = true
    context.family = slotEntry.family
    context.garageID = slotEntry.vehicleID
    context.currentSlot = slotEntry
    context.currentSlotVehicleID = slotEntry.vehicleID
    context.matchedBy = matchedBy

    if IsUsefulAppearanceName(slotEntry.appearance) == true then
        context.slotAppearance = slotEntry.appearance
        context.previewBaseAppearance = slotEntry.appearance
    end

    return context
end

local function IsExcludedPaintAppearance(normalizedAppearance)
    if type(normalizedAppearance) ~= "string" or normalizedAppearance == "" then
        return true
    end

    if string.find(normalizedAppearance, "burnt", 1, true) ~= nil then
        return true
    end

    if string.find(normalizedAppearance, "damage", 1, true) ~= nil then
        return true
    end

    if string.find(normalizedAppearance, "wheel", 1, true) ~= nil then
        return true
    end

    if string.find(normalizedAppearance, "disabled", 1, true) ~= nil then
        return true
    end

    return false
end

local function BuildDeclaredPaintSourceAppearances(family)
    local results = {}
    local seen = {}
    local familyBank = type(family) == "string" and COSV_SLOT_BANK and COSV_SLOT_BANK[family] or nil

    if type(familyBank) ~= "table" then
        return results
    end

    if type(familyBank.exactTemplates) == "table" then
        for declaredAppearance, _ in pairs(familyBank.exactTemplates) do
            local normalizedAppearance = NormalizeAppearanceName(declaredAppearance)

            if IsUsefulAppearanceName(declaredAppearance) == true and normalizedAppearance and not seen[normalizedAppearance] then
                seen[normalizedAppearance] = true
                table.insert(results, declaredAppearance)
            end
        end
    end

    for _, entry in ipairs(familyBank.overflowSlots or {}) do
        local declaredAppearance = type(entry) == "table" and entry.appearance or nil
        local normalizedAppearance = NormalizeAppearanceName(declaredAppearance)

        if IsUsefulAppearanceName(declaredAppearance) == true and normalizedAppearance and not seen[normalizedAppearance] then
            seen[normalizedAppearance] = true
            table.insert(results, declaredAppearance)
        end
    end

    return results
end

local function BuildScannerClusterPaintFamilies(context)
    local results = {}
    local seen = {}

    if type(context) ~= "table" then
        return results
    end

    local function addFamily(family)
        if type(family) == "string" and family ~= "" and seen[family] ~= true then
            seen[family] = true
            table.insert(results, family)
        end
    end

    addFamily(context.family)

    local displayRoute = ResolveDisplayNameRoute(context.recordID, currentDisplayName or currentScannerName)

    if type(displayRoute) == "table" and type(displayRoute.families) == "table" then
        for _, family in ipairs(displayRoute.families) do
            addFamily(family)
        end
    elseif type(displayRoute) == "table" then
        addFamily(displayRoute.family)
    end

    return results
end

local ResolveExactTemplateContract

local function BuildTokenDrivenAppearanceRefreshAppearances(family)
    local results = {}
    local seen = {}
    local familyBank = type(family) == "string" and COSV_SLOT_BANK and COSV_SLOT_BANK[family] or nil

    if type(familyBank) ~= "table" then
        return results
    end

    for _, entry in ipairs(familyBank.overflowSlots or {}) do
        local declaredAppearance = type(entry) == "table" and entry.appearance or nil
        local normalizedAppearance = NormalizeAppearanceName(declaredAppearance)

        if IsUsefulAppearanceName(declaredAppearance) == true and normalizedAppearance and not seen[normalizedAppearance] then
            seen[normalizedAppearance] = true
            table.insert(results, declaredAppearance)
        end
    end

    for _, declaredAppearance in ipairs(BuildDeclaredPaintSourceAppearances(family)) do
        local normalizedAppearance = NormalizeAppearanceName(declaredAppearance)

        if IsUsefulAppearanceName(declaredAppearance) == true and normalizedAppearance and not seen[normalizedAppearance] then
            seen[normalizedAppearance] = true
            table.insert(results, declaredAppearance)
        end
    end

    return results
end

local function ResolveAppearanceRefreshFamily(recordID)
    if type(recordID) ~= "string" or recordID == "" then
        return nil, "invalid_record"
    end

    local tokenRoute = FindSirenClaimRoute(recordID) or FindClaimRoute(recordID)

    if type(tokenRoute) == "table" and type(tokenRoute.family) == "string" and tokenRoute.family ~= "" then
        return tokenRoute.family, "token"
    end
    return nil, "no_token_family"
end

local function GetAppearanceRefreshSourceAppearances(recordID, appearance)
    local family, familySource = ResolveAppearanceRefreshFamily(recordID)

    if type(family) ~= "string" or family == "" then
        return {}, familySource or "no_family"
    end

    local declaredAppearances = BuildTokenDrivenAppearanceRefreshAppearances(family)

    if #declaredAppearances == 0 then
        return {}, "no_declared_family_appearances"
    end

    return declaredAppearances, "token_" .. tostring(familySource or "family")
end

local function BuildPaintPreviewCandidates(context)
    local result = {
        ok = false,
        reason = nil,
        candidates = {},
        candidateFamilies = {},
        families = {},
    }

    if type(context) ~= "table" or context.ok ~= true or type(context.family) ~= "string" or context.family == "" then
        result.reason = "invalid_context"
        return result
    end

    local clusterFamilies = BuildScannerClusterPaintFamilies(context)
    local declaredSeen = {}
    local declaredAppearances = {}

    if #clusterFamilies == 0 then
        result.reason = "no_declared_paint_families"
        return result
    end

    for _, family in ipairs(clusterFamilies) do
        table.insert(result.families, family)

        for _, declaredAppearance in ipairs(BuildDeclaredPaintSourceAppearances(family)) do
            local normalizedDeclared = NormalizeAppearanceName(declaredAppearance)

            if IsUsefulAppearanceName(declaredAppearance) == true and normalizedDeclared then
                if declaredSeen[normalizedDeclared] == nil then
                    declaredSeen[normalizedDeclared] = family
                    table.insert(declaredAppearances, declaredAppearance)
                end
            end
        end
    end

    if next(declaredSeen) == nil then
        result.reason = "no_declared_paint_appearances"
        return result
    end

    local sourceAppearances = declaredAppearances
    local currentNormalizedAppearance = NormalizeAppearanceName(context.previewBaseAppearance or context.currentAppearance)
    local seen = {}
    local originalCandidateAppearance = nil

    for _, candidateAppearance in ipairs(sourceAppearances) do
        local normalizedCandidate = NormalizeAppearanceName(candidateAppearance)

        if IsUsefulAppearanceName(candidateAppearance) == true
            and normalizedCandidate
            and declaredSeen[normalizedCandidate] ~= nil
            and IsExcludedPaintAppearance(normalizedCandidate) ~= true
            and not seen[normalizedCandidate]
        then
            seen[normalizedCandidate] = true
            result.candidateFamilies[normalizedCandidate] = declaredSeen[normalizedCandidate]

            if normalizedCandidate == currentNormalizedAppearance then
                originalCandidateAppearance = candidateAppearance
            else
                table.insert(result.candidates, candidateAppearance)
            end
        end
    end

    if #result.candidates == 0 then
        if IsUsefulAppearanceName(originalCandidateAppearance) ~= true then
            result.reason = "no_filtered_appearances"
            return result
        end
    end

    table.sort(result.candidates)

    if IsUsefulAppearanceName(originalCandidateAppearance) == true then
        table.insert(result.candidates, originalCandidateAppearance)
    end

    result.ok = true
    return result
end

local function SnapshotPaintPreviewState()
    if paintPreviewState.active ~= true then
        return nil
    end

    return {
        shopKey = paintPreviewState.shopKey,
        family = paintPreviewState.family,
        vehicleID = paintPreviewState.vehicleID,
        recordID = paintPreviewState.recordID,
        vehicleKey = paintPreviewState.vehicleKey,
        originalAppearance = paintPreviewState.originalAppearance,
        selectedAppearance = paintPreviewState.selectedAppearance,
        selectedFamily = paintPreviewState.selectedFamily,
    }
end

local function CancelPaintPreview(reason, restoreOriginalAppearance)
    local snapshot = SnapshotPaintPreviewState()
    local restored = false
    local hadPreviewSession = paintPreviewState.active == true
        or (snapshot and (snapshot.vehicleKey ~= nil or snapshot.originalAppearance ~= nil or snapshot.selectedAppearance ~= nil))

    if restoreOriginalAppearance == true and snapshot and currentVehicle and snapshot.vehicleKey == (currentVehicleKey or GetVehicleWorldKey(currentVehicle)) then
        restored = ApplyVehicleAppearance(currentVehicle, snapshot.originalAppearance)
    end

    if modConfig.debugEnabled == true and hadPreviewSession then
        DebugLog(
            "PaintPreviewCancel: reason=" .. tostring(reason)
            .. " restored=" .. tostring(restored == true)
            .. " selected=" .. tostring(snapshot and snapshot.selectedAppearance or "nil")
        )
    end

    ClearPaintPreviewState()
    return restored == true
end

local function DebugLogPaintPreviewStartBlockedOnce(shopKey, context, reason)
    if modConfig.debugEnabled ~= true then
        return
    end

    local vehicleKey = nil
    local recordID = nil

    if type(context) == "table" then
        vehicleKey = context.vehicleKey
        recordID = context.recordID
    end

    local blockKey = tostring(shopKey or "nil")
        .. "|" .. tostring(vehicleKey or currentVehicleKey or "nil")
        .. "|" .. tostring(recordID or currentRecordID or "nil")
        .. "|" .. tostring(reason or "nil")

    if lastPaintPreviewStartBlockedKey == blockKey then
        return
    end

    lastPaintPreviewStartBlockedKey = blockKey
    DebugLog("PaintPreviewStart blocked: reason=" .. tostring(reason))
end

local function NotifyPaintPreviewUnavailableOnce(shopKey, context, reason)
    if reason ~= "no_supported_appearances" and reason ~= "no_filtered_appearances" then
        return
    end

    local recordID = nil

    if type(context) == "table" then
        recordID = context.recordID
    end

    local notifyKey = tostring(shopKey or "nil")
        .. "|" .. tostring(recordID or currentRecordID or "nil")
        .. "|" .. tostring(reason or "nil")

    if lastPaintPreviewUnavailableNotifyKey == notifyKey then
        return
    end

    lastPaintPreviewUnavailableNotifyKey = notifyKey
    QueuePendingPaintPreviewUnavailable(messageConfig.paintPreviewUnavailableMessage, gameSimpleMessageType.Undefined)
end

local function CancelPaintPreviewWithNotify(reason, restoreOriginalAppearance, notifyMessage)
    CancelPaintPreview(reason, restoreOriginalAppearance)

    if type(notifyMessage) == "string" and notifyMessage ~= "" then
        Notify(notifyMessage, 5, gameSimpleMessageType.Undefined, true)
    end
end

local function StopPaintPreviewAutoRoulette()
    paintPreviewState.nextPreviewAt = nil
end

local function ApplyPaintPreviewSelection(candidateIndex, nextPreviewAt, source)
    if paintPreviewState.active ~= true or not currentVehicle then
        return false
    end

    local candidates = paintPreviewState.candidates or {}

    if #candidates == 0 then
        CancelPaintPreview("no_candidates", true)
        return false
    end

    local selectedAppearance = candidates[candidateIndex]
    local selectedFamily = paintPreviewState.candidateFamilies and paintPreviewState.candidateFamilies[NormalizeAppearanceName(selectedAppearance)] or paintPreviewState.family

    if ApplyVehicleAppearance(currentVehicle, selectedAppearance) ~= true then
        CancelPaintPreview("appearance_change_failed", true)
        return false
    end

    paintPreviewState.candidateIndex = candidateIndex
    paintPreviewState.selectedAppearance = selectedAppearance
    paintPreviewState.selectedFamily = selectedFamily
    paintPreviewState.nextPreviewAt = nextPreviewAt

    Notify(Fmt("notify.paint.preview_current", { appearance = selectedAppearance }), 2, gameSimpleMessageType.Undefined, true)

    if modConfig.debugEnabled == true then
        DebugLog(
            "PaintPreview" .. tostring(source or "Apply")
            .. ": index=" .. tostring(candidateIndex)
            .. "/" .. tostring(#candidates)
            .. " appearance=" .. tostring(selectedAppearance)
        )
    end

    return true
end

local function AdvancePaintPreview(now)
    if paintPreviewState.active ~= true or not currentVehicle then
        return false
    end

    local candidates = paintPreviewState.candidates or {}

    if #candidates == 0 then
        CancelPaintPreview("no_candidates", true)
        return false
    end

    local candidateIndex = (paintPreviewState.candidateIndex % #candidates) + 1
    return ApplyPaintPreviewSelection(candidateIndex, now + paintPreviewIntervalSeconds, "Advance")
end

local function StepPaintPreview(delta)
    if paintPreviewState.active ~= true then
        return false
    end

    if type(delta) ~= "number" or delta == 0 then
        return false
    end

    if isPlayerMounted ~= true or not currentVehicle or not currentRecordID then
        return false
    end

    local shop = proximityState.currentShop

    if not shop or shop.mode ~= "paint" or shop.key ~= paintPreviewState.shopKey then
        return false
    end

    if paintPreviewState.vehicleKey ~= (currentVehicleKey or GetVehicleWorldKey(currentVehicle)) then
        return false
    end

    local candidates = paintPreviewState.candidates or {}

    if #candidates == 0 then
        return false
    end

    if paintPreviewState.manualMode ~= true then
        paintPreviewState.manualMode = true
        StopPaintPreviewAutoRoulette()

        if modConfig.debugEnabled == true then
            DebugLog("PaintPreviewManualMode: started")
        end
    end

    local candidateIndex = paintPreviewState.candidateIndex + delta

    if candidateIndex > #candidates then
        candidateIndex = 1
    elseif candidateIndex < 1 then
        candidateIndex = #candidates
    end

    return ApplyPaintPreviewSelection(candidateIndex, nil, "Manual")
end

local function HasDetectedGarageAlteration()
    if modConfig.enableRawRecords == true then
        return false, nil
    end

    local okList, vehicleList = pcall(function()
        return TweakDB:GetFlat("Vehicle.vehicle_list.list")
    end)

    if okList ~= true or type(vehicleList) ~= "table" then
        return false, nil
    end

    for _, vehicleID in ipairs(vehicleList) do
        local recordID = vehicleID and vehicleID.value or nil

        if recordID and alteration_detection_tokens[tostring(recordID)] == true then
            return true, tostring(recordID)
        end
    end

    return false, nil
end

local function RefreshProximityState()
    local playerPosition = GetPlayerPosition()

    proximityState.playerPosition = playerPosition

    if playerPosition then
        proximityState.currentShop = GetShopContainingPosition(playerPosition)
    else
        proximityState.currentShop = nil
    end

    local shop = proximityState.currentShop
    local warningEligible = isPlayerMounted == true
        and shop ~= nil
        and (shop.mode == "unlock" or shop.mode == "paint")

    if warningEligible ~= true then
        alterationWarningShopKey = nil
        return
    end

    if alterationWarningShopKey == shop.key then
        return
    end

    alterationWarningShopKey = shop.key

    if modConfig.enableRawRecords == true and shop.mode == "unlock" then
        AppendSessionLogLine("You have Raw Records enabled. In this configuration, claimed vehicles are not guaranteed to retain their appearance, and only one vehicle per record may be claimable. Please do not report claim failures in this mode.")
        print("[COSV] Warning: Raw Records Enabled. Check the log file for details. Claim routing is unsupported in this mode.")

        if modConfig.configurationWarningEnabled == true then
            pendingConfigurationAlert = {
                message = messageConfig.rawRecordsClaimPrompt,
                duration = 5,
            }
        end

        return
    end

    local alterationDetected, matchedRecordID = HasDetectedGarageAlteration()

    if alterationDetected == true then
        AppendSessionLogLine("Your garage vehicle list was altered by another mod. Known incompatible mods include Make All Vehicles Unlockable, Steal Vehicles, Claim Vehicles, and Midnight Acquisition. In this configuration, claimed vehicles are not guaranteed to retain their appearance, and only one vehicle per record may be claimable. Please do not report claim failures in this mode.")
        print("[COSV] Warning: Altered Garage. Check the log file for details. Claim routing is unsupported in this mode.")

        if modConfig.configurationWarningEnabled == true then
            pendingConfigurationAlert = {
                message = messageConfig.garageAlterationWarning,
                duration = 5,
            }
        end

        DebugLog("garage alteration detected token=" .. tostring(matchedRecordID) .. " shop=" .. tostring(shop.key))
    end
end

local function ProcessConfigurationAlert(now)
    if pendingConfigurationAlert then
        local alert = pendingConfigurationAlert
        pendingConfigurationAlert = nil
        configurationAlertEndsAt = now + alert.duration
        Notify(alert.message, alert.duration, gameSimpleMessageType.Negative, true)
        return false
    end

    if configurationAlertEndsAt and now >= configurationAlertEndsAt then
        configurationAlertEndsAt = nil
        activeMountedZonePrompt = nil
        activeMountedZonePromptType = nil
        return true
    end

    return false
end

local BuildPaintPreviewIntroMessage

local function StartPaintPreview(shop, context, candidateResult, now)
    if type(shop) ~= "table" or type(context) ~= "table" or context.ok ~= true then
        return false
    end

    if type(candidateResult) ~= "table" or candidateResult.ok ~= true or #candidateResult.candidates == 0 then
        return false
    end

    ClearPendingPaintPreviewUnavailable()
    ClearPaintPreviewStartBlockedLog()
    ClearPaintPreviewUnavailableNotify()

    paintPreviewState.active = true
    paintPreviewState.manualMode = false
    paintPreviewState.shopKey = shop.key
    paintPreviewState.family = context.family
    paintPreviewState.vehicleID = context.currentSlotVehicleID
    paintPreviewState.recordID = context.recordID
    paintPreviewState.vehicleKey = context.vehicleKey
    paintPreviewState.originalAppearance = context.previewBaseAppearance or context.currentAppearance
    paintPreviewState.selectedAppearance = nil
    paintPreviewState.selectedFamily = nil
    paintPreviewState.candidates = candidateResult.candidates
    paintPreviewState.candidateFamilies = candidateResult.candidateFamilies
    paintPreviewState.candidateIndex = 0
    paintPreviewState.nextPreviewAt = now + paintPreviewStartDelaySeconds

    Notify(BuildPaintPreviewIntroMessage(), 4, gameSimpleMessageType.Undefined, true)

    if modConfig.debugEnabled == true then
        DebugLog(
            "PaintPreviewStart: shop=" .. tostring(shop.key)
            .. " family=" .. tostring(context.family)
            .. " cluster=" .. tostring(#(candidateResult.families or {}))
            .. " count=" .. tostring(#candidateResult.candidates)
            .. " delay=" .. tostring(paintPreviewStartDelaySeconds)
        )
    end

    return true
end

local function ProcessPaintPreview(now)
    if activeTransaction == true then
        if paintPreviewState.active == true then
            CancelPaintPreview("active_transaction", true)
        end
        return
    end

    if paintPreviewState.active == true then
        if isPlayerMounted ~= true or not currentVehicle or not currentRecordID then
            return
        end

        local shop = proximityState.currentShop

        if not shop or shop.mode ~= "paint" or shop.key ~= paintPreviewState.shopKey then
            CancelPaintPreviewWithNotify("left_paint_shop", true, messageConfig.paintPreviewCancelMessage)
            return
        end

        if paintPreviewState.vehicleKey ~= (currentVehicleKey or GetVehicleWorldKey(currentVehicle)) then
            CancelPaintPreview("vehicle_changed", true)
            return
        end

        if paintPreviewState.manualMode ~= true and (not paintPreviewState.nextPreviewAt or now >= paintPreviewState.nextPreviewAt) then
            AdvancePaintPreview(now)
        end

        return
    end

    if isPlayerMounted ~= true or not currentVehicle or not currentRecordID then
        return
    end

    local shop = proximityState.currentShop

    if not shop or shop.mode ~= "paint" or IsShopOnCooldown(shop) then
        return
    end

    local context = ResolveCurrentCOSVPaintContext(currentVehicle, currentRecordID, currentAppearance)

    if context.ok ~= true then
        return
    end

    local candidateResult = BuildPaintPreviewCandidates(context)

    if candidateResult.ok ~= true then
        DebugLogPaintPreviewStartBlockedOnce(shop and shop.key or nil, context, candidateResult.reason)
        NotifyPaintPreviewUnavailableOnce(shop and shop.key or nil, context, candidateResult.reason)
        return
    end

    StartPaintPreview(shop, context, candidateResult, now)
end

local function ProcessPendingPaintPreviewUnavailable()
    local pendingNotify = pendingPaintPreviewUnavailable

    if type(pendingNotify) ~= "table" or type(pendingNotify.message) ~= "string" or pendingNotify.message == "" then
        return
    end

    Notify(tostring(pendingNotify.message), 4, pendingNotify.messageType or gameSimpleMessageType.Undefined, true)
    ClearPendingPaintPreviewUnavailable()
end

local function BuildSlotPrefixFromDeclaredSlot(slotID)
    local text = tostring(slotID or "")
    return string.match(text, "^(.*_slot)%d%d$")
end

local function BuildExactSlotTemplateFromDeclaredSlot(slotID)
    local slotPrefix = BuildSlotPrefixFromDeclaredSlot(slotID)
    if not slotPrefix then
        return nil
    end

    return slotPrefix .. "%02d"
end

ResolveExactTemplateContract = function(familyBank, normalizedAppearance)
    if type(familyBank) ~= "table" or type(normalizedAppearance) ~= "string" or normalizedAppearance == "" then
        return nil
    end

    local exactTemplates = familyBank.exactTemplates
    if type(exactTemplates) == "table" then
        local directTemplate = exactTemplates[normalizedAppearance]
        if type(directTemplate) == "string" and directTemplate ~= "" then
            return {
                appearance = normalizedAppearance,
                template = directTemplate,
            }
        end

        for appearanceToken, template in pairs(exactTemplates) do
            if NormalizeAppearanceName(appearanceToken) == normalizedAppearance and type(template) == "string" and template ~= "" then
                return {
                    appearance = appearanceToken,
                    template = template,
                }
            end
        end
    end

    for _, entry in ipairs(familyBank.slots or {}) do
        if NormalizeAppearanceName(entry.appearance) == normalizedAppearance then
            return {
                appearance = entry.appearance,
                template = BuildExactSlotTemplateFromDeclaredSlot(entry.vehicleID),
                legacyVehicleID = entry.vehicleID,
            }
        end
    end

    return nil
end

function ResolveControlledClaimSlot(rawRecordID, appearance, familyOverride)
    local normalizedAppearance = NormalizeAppearanceName(appearance)
    local family = familyOverride

    if family == "chevalier_emperor_720" then
        normalizedAppearance = "chevalier_emperor__basic_police"
    end

    local result = {
        vehicleID = nil,
        family = family,
        appearance = appearance,
        normalizedAppearance = normalizedAppearance,
        slot = nil,
        status = nil,
        sourceRawRecordID = rawRecordID,
        mode = nil,
        entry = nil,
        missingRecords = {},
        exactScanStatus = nil,
    }

    if not family then
        result.status = "unrouted_record"
        return result
    end

    if not normalizedAppearance then
        result.status = "unmapped_appearance"
        return result
    end

    local familyBank = COSV_SLOT_BANK[family]

    if not familyBank then
        result.status = "unmapped_appearance"
        return result
    end

    local hadCandidate = false
    local hadExistingRecord = false
    local exactContract = ResolveExactTemplateContract(familyBank, normalizedAppearance)

    if exactContract then
        hadCandidate = true

        if type(exactContract.template) ~= "string" or exactContract.template == "" then
            result.exactScanStatus = "invalid_exact_contract"
            DebugLog("invalid exact slot template:", tostring(family), tostring(normalizedAppearance), tostring(exactContract.legacyVehicleID or exactContract.template))
        else
            local sawExistingExactRecord = false

            for i = 1, modConfig.MAX_COSV_EXACT_SLOT_SCAN do
                local candidateID = string.format(exactContract.template, i)

                if HasTweakDBRecord(candidateID) == true then
                    sawExistingExactRecord = true
                    hadExistingRecord = true

                    if IsGarageVehicleUnlocked(candidateID) == false then
                        result.vehicleID = candidateID
                        result.slot = i
                        result.status = "exact"
                        result.mode = "exact"
                        result.entry = {
                            vehicleID = candidateID,
                            appearance = exactContract.appearance,
                            slot = i,
                        }
                        result.exactScanStatus = "exact_available"
                        return result
                    end
                end
            end

            if sawExistingExactRecord == true then
                result.exactScanStatus = "exact_slots_exhausted"
            else
                result.exactScanStatus = "no_exact_records"
            end
        end
    else
        result.exactScanStatus = "no_exact_contract"
    end

    for _, entry in ipairs(familyBank.overflowSlots or {}) do
        hadCandidate = true

        if HasTweakDBRecord(entry.vehicleID) ~= true then
            table.insert(result.missingRecords, tostring(entry.vehicleID))
        else
            hadExistingRecord = true

            if IsGarageVehicleUnlocked(entry.vehicleID) == false then
                result.vehicleID = entry.vehicleID
                result.slot = entry.slot
                result.status = "overflow"
                result.mode = "overflow"
                result.entry = entry
                return result
            end
        end
    end

    if hadCandidate ~= true then
        result.status = "exhausted"
    elseif hadExistingRecord ~= true then
        result.status = "no_tweakdb_record"
    else
        result.status = "exhausted"
    end

    return result
end

local function GetClaimCOSVSlotFailureReason(controlled)
    if type(controlled) ~= "table" then
        return "slots_not_found"
    end

    if controlled.status == "unrouted_record" or controlled.status == "unmapped_appearance" then
        return "invalid_input"
    end

    if controlled.status == "no_tweakdb_record" then
        return "slots_not_found"
    end

    if controlled.status == "exhausted" then
        return "slots_full"
    end

    return "slots_not_found"
end

-- Frozen COSV slot operation: caller provides resolved family + appearance; this only activates a declared COSV slot or returns failure.
function ClaimCOSVSlot(family, appearance, options)
    options = type(options) == "table" and options or {}

    local result = {
        ok = false,
        reason = nil,
        garageID = nil,
        family = family,
        appearance = appearance,
        source = options.source,
        controlled = nil,
        ensureCalled = false,
        ensureResult = false,
        hasTargetRecord = false,
        inVehicleListBefore = false,
        inVehicleListAfter = false,
        enableOk = false,
        enableResult = nil,
        wasUnlocked = false,
        isUnlocked = false,
        disabledPrevious = false,
        disablePreviousOk = false,
        disablePreviousResult = nil,
        previousStillUnlocked = false,
        previousVehicleID = options.previousVehicleID,
        usedPreResolvedControlled = false,
    }

    if type(family) ~= "string" or family == "" or appearance == nil or tostring(appearance) == "" then
        result.reason = "invalid_input"
        return result
    end

    local controlled = nil

    if type(options.preResolvedControlled) == "table"
        and (options.preResolvedControlled.status == "exact" or options.preResolvedControlled.status == "overflow")
        and options.preResolvedControlled.vehicleID
    then
        controlled = options.preResolvedControlled
        result.usedPreResolvedControlled = true
    else
        controlled = ResolveControlledClaimSlot(nil, appearance, family)
    end

    result.controlled = controlled

    if type(controlled) ~= "table"
        or (controlled.status ~= "exact" and controlled.status ~= "overflow")
        or not controlled.vehicleID
    then
        result.reason = GetClaimCOSVSlotFailureReason(controlled)
        return result
    end

    local garageID = tostring(controlled.vehicleID)
    result.garageID = garageID
    result.hasTargetRecord = HasTweakDBRecord(garageID) == true
    result.inVehicleListBefore = IsVehicleInVehicleList(garageID) == true
    result.wasUnlocked = IsGarageVehicleUnlocked(garageID) == true
    result.ensureCalled = true
    result.ensureResult = EnsureVehicleInVehicleList(garageID) == true
    result.inVehicleListAfter = IsVehicleInVehicleList(garageID) == true

    local vehicleSystem = nil
    if Game.GetVehicleSystem then
        vehicleSystem = Game.GetVehicleSystem()
    end

    if not vehicleSystem then
        result.reason = "enable_failed"
        return result
    end

    result.enableOk, result.enableResult = pcall(function()
        return vehicleSystem:EnablePlayerVehicle(garageID, true, false)
    end)

    result.isUnlocked = IsGarageVehicleUnlocked(garageID) == true

    if result.enableOk ~= true or result.isUnlocked ~= true then
        result.reason = "enable_failed"
        return result
    end

    if options.source == "paint" and type(options.transactionPayload) == "table" then
        options.transactionPayload.paintCommitted = true
        options.transactionPayload.committedGarageID = garageID
        options.transactionPayload.paintCommitSkipLogged = false
        DebugLog("paint_commit garage=" .. tostring(garageID))
    end

    local previousVehicleID = options.previousVehicleID
    if previousVehicleID and tostring(previousVehicleID) ~= "" and tostring(previousVehicleID) ~= garageID then
        if options.previousVehicleAlreadyDisabled == true then
            result.disablePreviousOk = true
            result.disablePreviousResult = true
            result.disabledPrevious = true
            result.previousStillUnlocked = IsGarageVehicleUnlocked(previousVehicleID) == true
        else
            result.disablePreviousOk, result.disablePreviousResult = pcall(function()
                return vehicleSystem:EnablePlayerVehicle(previousVehicleID, false, false)
            end)
            result.disabledPrevious = result.disablePreviousOk == true
            result.previousStillUnlocked = IsGarageVehicleUnlocked(previousVehicleID) == true
        end
    end

    result.ok = true
    return result
end

local function GetOrCreateDisableValidationState(payload, mode, targetVehicleID)
    if type(payload) ~= "table" or type(targetVehicleID) ~= "string" or targetVehicleID == "" then
        return nil
    end

    local state = type(payload.disableValidation) == "table" and payload.disableValidation or nil

    if state
        and state.mode == mode
        and state.targetVehicleID == targetVehicleID
    then
        return state
    end

    state = {
        mode = mode,
        targetVehicleID = targetVehicleID,
        attemptsSent = 0,
        nextCheckAt = nil,
        lastDisableOk = false,
        lastDisableResult = nil,
        confirmed = false,
        failed = false,
    }

    payload.disableValidation = state
    return state
end

local function StartDisableValidationAttempt(state, now)
    local vehicleSystem = Game.GetVehicleSystem and Game.GetVehicleSystem() or nil

    if not state or not vehicleSystem or not now then
        if state then
            state.failed = true
        end
        return false
    end

    state.attemptsSent = (state.attemptsSent or 0) + 1
    state.lastDisableOk, state.lastDisableResult = pcall(function()
        return vehicleSystem:EnablePlayerVehicle(state.targetVehicleID, false, false)
    end)
    state.nextCheckAt = now + modConfig.transactionDisableRetryInterval

    return state.lastDisableOk == true
end

local function ProcessDisableValidation(payload, mode, targetVehicleID, now)
    local state = GetOrCreateDisableValidationState(payload, mode, targetVehicleID)

    if not state or not now then
        return false, nil, "disable_failed"
    end

    if state.confirmed == true then
        return true, state, nil
    end

    if state.failed == true then
        return false, state, "disable_failed"
    end

    if (state.attemptsSent or 0) == 0 then
        if StartDisableValidationAttempt(state, now) ~= true then
            state.failed = true
            return false, state, "disable_failed"
        end

        return false, state, "disable_pending"
    end

    if state.nextCheckAt and now < state.nextCheckAt then
        return false, state, "disable_pending"
    end

    if IsGarageVehicleUnlocked(targetVehicleID) ~= true then
        state.confirmed = true
        return true, state, nil
    end

    if (state.attemptsSent or 0) >= modConfig.transactionDisableRetryMaxAttempts then
        state.failed = true
        return false, state, "disable_failed"
    end

    if StartDisableValidationAttempt(state, now) ~= true then
        state.failed = true
        return false, state, "disable_failed"
    end

    return false, state, "disable_pending"
end

function IsIgnoredClaimRecord(rawRecordID)
    if not rawRecordID then
        return false
    end

    return CLAIM_IGNORE_IDS[tostring(rawRecordID)] == true
end

function IsIgnoredSellRecord(rawRecordID)
    if not rawRecordID then
        return false
    end

    return SELL_IGNORE_IDS[tostring(rawRecordID)] == true
end

function FindClaimRoute(rawRecordID)
    if not rawRecordID then
        return nil
    end

    local id = tostring(rawRecordID)

    for _, rule in ipairs(CLAIM_ROUTE_RULES or {}) do
        for _, token in ipairs(rule.tokens or {}) do
            if id == token then
                return rule
            end
        end
    end

    return nil
end

function FindSirenClaimRoute(rawRecordID)
    if not rawRecordID then
        return nil
    end

    local id = tostring(rawRecordID)
    local directRoute = SIREN_ROUTE_RULES[id]

    if directRoute then
        return directRoute
    end

    if string.find(id, "_siren", 1, true) == nil then
        return nil
    end

    return nil
end

-- FindClaimRouteByDisplayName: second-level routing via localized display name.
-- Only called when rawRecordID has no exact token match in CLAIM_ROUTE_RULES.
-- displayName must be the exact string returned by GetVehicleDisplayName().
-- Returns a synthetic route table compatible with the exact CLAIM_ROUTE_RULES shape,
-- or nil if the display name is not found in DISPLAY_NAME_ROUTE_RULES.
function FindClaimRouteByDisplayName(displayName)
    if not displayName or displayName == "" then
        return nil
    end

    local entry = DISPLAY_NAME_ROUTE_RULES[displayName]

    if not entry then
        local normalizedDisplayName = NormalizeVehicleDisplayName(displayName)

        if normalizedDisplayName then
            for candidateName, candidateEntry in pairs(DISPLAY_NAME_ROUTE_RULES or {}) do
                if NormalizeVehicleDisplayName(candidateName) == normalizedDisplayName then
                    entry = candidateEntry
                    displayName = candidateName
                    break
                end
            end
        end
    end

    local families = {}

    if type(entry) == "table" and type(entry.families) == "table" then
        for _, family in ipairs(entry.families) do
            if type(family) == "string" and family ~= "" then
                table.insert(families, family)
            end
        end
    end

    if #families == 0 and type(entry) == "table" and type(entry.family) == "string" and entry.family ~= "" then
        table.insert(families, entry.family)
    end

    if #families == 0 then
        return nil
    end

    return {
        family = families[1],
        families = families,
        convertTo = entry.convertTo or "",
        tokens = {},
        displayNameRouted = true,
        matchedDisplayName = displayName,
    }
end

local function ResolveExactControlledSlotAcrossDisplayFamilies(rawRecordID, appearance, route)
    local result = {
        status = nil,
        family = nil,
        controlled = nil,
        families = {},
        normalizedAppearance = NormalizeAppearanceName(appearance),
        strictOverflowTriedFamily = nil,
    }

    if type(route) == "table" and type(route.families) == "table" then
        for _, family in ipairs(route.families) do
            if type(family) == "string" and family ~= "" then
                table.insert(result.families, family)
            end
        end
    end

    if #result.families == 0 and type(route) == "table" and type(route.family) == "string" and route.family ~= "" then
        table.insert(result.families, route.family)
    end

    if #result.families == 0 then
        result.status = "no_display_families"
        return result
    end

    if not result.normalizedAppearance then
        result.status = "unmapped_appearance"
        return result
    end

    for _, family in ipairs(result.families) do
        local familyBank = COSV_SLOT_BANK[family]

        if type(familyBank) ~= "table" then
            DebugLog("scanner recovery family missing:", tostring(family))
        else
            local exactContract = ResolveExactTemplateContract(familyBank, result.normalizedAppearance)

            if not exactContract then
                DebugLog("scanner recovery exact-contract miss: family=" .. tostring(family)
                    .. " appearance=" .. tostring(result.normalizedAppearance))
            else
                DebugLog("scanner recovery exact-contract hit: family=" .. tostring(family)
                    .. " appearance=" .. tostring(exactContract.appearance or result.normalizedAppearance))

                local controlled = ResolveControlledClaimSlot(rawRecordID, appearance, family)
                DebugLog("scanner recovery exact resolver: family=" .. tostring(family)
                    .. " status=" .. tostring(controlled and controlled.status or "nil")
                    .. " exactScanStatus=" .. tostring(controlled and controlled.exactScanStatus or "nil")
                    .. " vehicleID=" .. tostring(controlled and controlled.vehicleID or "nil"))

                if type(controlled) == "table" and controlled.status == "exact" and controlled.vehicleID then
                    result.status = "exact"
                    result.family = family
                    result.controlled = controlled
                    return result
                end
            end
        end
    end

    for _, family in ipairs(result.families) do
        local familyBank = COSV_SLOT_BANK[family]

        if type(familyBank) ~= "table" then
            DebugLog("scanner recovery overflow family missing:", tostring(family))
        else
            local exactContract = ResolveExactTemplateContract(familyBank, result.normalizedAppearance)

            if not exactContract then
                DebugLog("scanner recovery overflow skipped: family=" .. tostring(family)
                    .. " appearance=" .. tostring(result.normalizedAppearance))
            else
                DebugLog("scanner recovery overflow contract hit: family=" .. tostring(family)
                    .. " appearance=" .. tostring(exactContract.appearance or result.normalizedAppearance))
                result.strictOverflowTriedFamily = family

                local controlled = ResolveControlledClaimSlot(rawRecordID, appearance, family)
                DebugLog("scanner recovery overflow resolver: family=" .. tostring(family)
                    .. " status=" .. tostring(controlled and controlled.status or "nil")
                    .. " exactScanStatus=" .. tostring(controlled and controlled.exactScanStatus or "nil")
                    .. " vehicleID=" .. tostring(controlled and controlled.vehicleID or "nil"))

                if type(controlled) == "table" and controlled.status == "overflow" and controlled.vehicleID then
                    result.status = "overflow"
                    result.family = family
                    result.controlled = controlled
                    return result
                end
            end
        end
    end

    result.status = "no_display_family_match"
    return result
end

local function TryLastStandExactAppearance(context)
    local result = {
        ok = false,
        status = nil,
        family = nil,
        controlled = nil,
        families = {},
        normalizedAppearance = nil,
        recoveryKind = "last_stand_exact_appearance",
        message = "Choom, we had to rewrite your car model to match our papers. Sorry, best we could do. Call your wheels from the garage",
    }

    if type(context) ~= "table" then
        result.status = "invalid_context"
        return result
    end

    local rawRecordID = context.rawRecordID or context.recordID
    local appearance = context.appearance or context.currentAppearance
    result.normalizedAppearance = NormalizeAppearanceName(appearance)

    if not result.normalizedAppearance then
        result.status = "unmapped_appearance"
        return result
    end

    local seenFamilies = {}

    for _, rule in ipairs(CLAIM_ROUTE_RULES or {}) do
        local family = type(rule) == "table" and rule.family or nil

        if type(family) == "string" and family ~= "" and seenFamilies[family] ~= true then
            seenFamilies[family] = true
            table.insert(result.families, family)
        end
    end

    local remainingFamilies = {}

    for family, _ in pairs(COSV_SLOT_BANK or {}) do
        if type(family) == "string" and family ~= "" and seenFamilies[family] ~= true then
            table.insert(remainingFamilies, family)
        end
    end

    table.sort(remainingFamilies)

    for _, family in ipairs(remainingFamilies) do
        table.insert(result.families, family)
    end

    if #result.families == 0 then
        result.status = "no_declared_families"
        return result
    end

    for _, family in ipairs(result.families) do
        local familyBank = COSV_SLOT_BANK[family]

        if type(familyBank) ~= "table" then
            DebugLog("last stand exact family missing: " .. tostring(family))
        else
            local exactContract = ResolveExactTemplateContract(familyBank, result.normalizedAppearance)

            if exactContract then
                DebugLog("last stand exact-contract hit: family=" .. tostring(family)
                    .. " appearance=" .. tostring(exactContract.appearance or result.normalizedAppearance))

                local controlled = ResolveControlledClaimSlot(rawRecordID, appearance, family)
                DebugLog("last stand exact resolver: family=" .. tostring(family)
                    .. " status=" .. tostring(controlled and controlled.status or "nil")
                    .. " exactScanStatus=" .. tostring(controlled and controlled.exactScanStatus or "nil")
                    .. " vehicleID=" .. tostring(controlled and controlled.vehicleID or "nil"))

                if type(controlled) == "table" and controlled.status == "exact" and controlled.vehicleID then
                    result.ok = true
                    result.status = "exact"
                    result.family = family
                    result.controlled = controlled
                    return result
                end
            end
        end
    end

    result.status = "no_exact_appearance_match"
    return result
end

local function TryLastStandOverflow(context)
    local result = {
        ok = false,
        status = nil,
        family = nil,
        controlled = nil,
        families = {},
        normalizedAppearance = nil,
        matchedDisplayName = nil,
        recoveryKind = "last_stand_overflow",
        message = "We scratched your ride during processing. Repainted it on us. Sorry, choom.",
    }

    if type(context) ~= "table" then
        result.status = "invalid_context"
        return result
    end

    local rawRecordID = context.rawRecordID or context.recordID
    local appearance = context.appearance or context.currentAppearance
    local preferredDisplayName = context.displayName or context.scannerDisplayName or context.currentDisplayName
    local displayRoute = context.displayRoute
    local strictOverflowTriedFamily = context.strictOverflowTriedFamily

    result.normalizedAppearance = NormalizeAppearanceName(appearance)

    if type(displayRoute) ~= "table" or displayRoute.displayNameRouted ~= true then
        displayRoute, result.matchedDisplayName = ResolveDisplayNameRoute(rawRecordID, preferredDisplayName)
    else
        result.matchedDisplayName = displayRoute.matchedDisplayName
    end

    if type(displayRoute) ~= "table" then
        result.status = "no_display_route"
        return result
    end

    if type(displayRoute.families) == "table" then
        for _, family in ipairs(displayRoute.families) do
            if type(family) == "string" and family ~= "" then
                table.insert(result.families, family)
            end
        end
    end

    if #result.families == 0 and type(displayRoute.family) == "string" and displayRoute.family ~= "" then
        table.insert(result.families, displayRoute.family)
    end

    if #result.families == 0 then
        result.status = "no_display_families"
        return result
    end

    for _, family in ipairs(result.families) do
        local familyBank = COSV_SLOT_BANK[family]

        if type(familyBank) ~= "table" then
            DebugLog("last stand overflow family missing: " .. tostring(family))
        elseif type(strictOverflowTriedFamily) == "string" and strictOverflowTriedFamily ~= "" and family == strictOverflowTriedFamily then
            DebugLog("last stand overflow skipped: strict scanner already checked family=" .. tostring(family))
        else
            local controlled = ResolveControlledClaimSlot(rawRecordID, appearance, family)
            DebugLog("last stand overflow resolver: family=" .. tostring(family)
                .. " status=" .. tostring(controlled and controlled.status or "nil")
                .. " exactScanStatus=" .. tostring(controlled and controlled.exactScanStatus or "nil")
                .. " vehicleID=" .. tostring(controlled and controlled.vehicleID or "nil"))

            if type(controlled) == "table" and controlled.status == "overflow" and controlled.vehicleID then
                result.ok = true
                result.status = "overflow"
                result.family = family
                result.controlled = controlled
                return result
            end
        end
    end

    result.status = "no_scanner_family_overflow"
    return result
end

function FallbackClaim(recordID, appearance)
    local garageID = tostring(recordID or "")

    if garageID == "" or HasTweakDBRecord(garageID) ~= true then
        return {
            ok = false,
            garageID = nil,
            mode = "fallback",
            status = "missing_exact_record",
        }
    end

    if modConfig.enableRawRecords ~= true and IsFallbackDirectSafeRecord(garageID) ~= true and IsVehicleInVehicleList(garageID) ~= true then
        return {
            ok = false,
            garageID = nil,
            mode = "fallback",
            status = "fallback_not_primeable",
        }
    end

    EnsureVehicleInVehicleList(garageID)

    return {
        ok = true,
        garageID = garageID,
        mode = "fallback",
        status = "ready",
    }
end

function ResolveClaimGarageTarget(rawRecordID, appearance)
    if IsIgnoredClaimRecord(rawRecordID) then
        return {
            ok = false,
            garageID = nil,
            mode = "ignore",
            status = "ignored_claim_record",
            route = nil,
            controlled = nil,
        }
    end

    local route = FindSirenClaimRoute(rawRecordID) or FindClaimRoute(rawRecordID)

    if route then
        if ValidateCOSVSlotInfrastructure() ~= true then
            local fallback = FallbackClaim(rawRecordID, appearance)
            fallback.mode = "fallback"
            fallback.status = "cosv_disabled_slots_missing"
            fallback.route = route
            fallback.controlled = nil
            fallback.disabledReason = cosvSlotsDisabledReason
            return fallback
        end

        local controlled = ResolveControlledClaimSlot(rawRecordID, appearance, route.family)

        if controlled.status == "exact" or controlled.status == "overflow" then
            return {
                ok = true,
                garageID = controlled.vehicleID,
                mode = "cosv",
                status = controlled.status,
                route = route,
                controlled = controlled,
                selectedFamily = route.family,
            }
        end

        if modConfig.enableLastStandScaner == true then
            local displayRoute, displayName = ResolveDisplayNameRoute(rawRecordID, currentDisplayName)
            local lastStandContext = {
                rawRecordID = rawRecordID,
                appearance = appearance,
                displayRoute = displayRoute,
                displayName = displayName,
                scannerDisplayName = currentScannerName,
                currentDisplayName = currentDisplayName,
                strictOverflowTriedFamily = route.family,
            }

            local lastStandExact = TryLastStandExactAppearance(lastStandContext)

            if lastStandExact.ok == true and type(lastStandExact.controlled) == "table" and lastStandExact.controlled.vehicleID then
                DebugLog("last stand exact selected family after token miss: " .. tostring(lastStandExact.family))
                DebugLog("last stand exact selected slot after token miss: " .. tostring(lastStandExact.controlled.vehicleID))
                return {
                    ok = true,
                    garageID = lastStandExact.controlled.vehicleID,
                    mode = "cosv",
                    status = lastStandExact.status,
                    route = route,
                    controlled = lastStandExact.controlled,
                    selectedFamily = lastStandExact.family,
                    recoveryKind = lastStandExact.recoveryKind,
                    loreMessage = lastStandExact.message,
                }
            end

            DebugLog("last stand exact miss after token miss: appearance=" .. tostring(lastStandExact.normalizedAppearance)
                .. " status=" .. tostring(lastStandExact.status))

            local lastStandOverflow = TryLastStandOverflow(lastStandContext)

            if lastStandOverflow.ok == true and type(lastStandOverflow.controlled) == "table" and lastStandOverflow.controlled.vehicleID then
                DebugLog("last stand overflow selected family after token miss: " .. tostring(lastStandOverflow.family))
                DebugLog("last stand overflow selected slot after token miss: " .. tostring(lastStandOverflow.controlled.vehicleID))
                return {
                    ok = true,
                    garageID = lastStandOverflow.controlled.vehicleID,
                    mode = "cosv",
                    status = lastStandOverflow.status,
                    route = route,
                    controlled = lastStandOverflow.controlled,
                    selectedFamily = lastStandOverflow.family,
                    recoveryKind = lastStandOverflow.recoveryKind,
                    loreMessage = lastStandOverflow.message,
                }
            end

            DebugLog("last stand overflow miss after token miss: display=" .. tostring(lastStandOverflow.matchedDisplayName or displayName)
                .. " status=" .. tostring(lastStandOverflow.status))
        end

        local fallback = FallbackClaim(rawRecordID, appearance)
        fallback.mode = "fallback_after_cosv_miss"
        fallback.status = tostring(fallback.status or ("fallback_after_" .. tostring(controlled.status)))
        fallback.route = route
        fallback.controlled = controlled
        return fallback
    end

    DebugLog("scanner recovery token miss: record=" .. tostring(rawRecordID)
        .. " appearance=" .. tostring(appearance))

    local displayRoute, displayName = ResolveDisplayNameRoute(rawRecordID, currentDisplayName)
    local displayControlled = nil

    if displayRoute then
        DebugLog("scanner recovery matched display name: " .. tostring(displayName))
        DebugLog("scanner recovery mapped families: " .. table.concat(displayRoute.families or { displayRoute.family or "" }, ", "))
    end

    if displayRoute or modConfig.enableLastStandScaner == true then
        if ValidateCOSVSlotInfrastructure() ~= true then
            local fallback = FallbackClaim(rawRecordID, appearance)
            fallback.mode = "fallback"
            fallback.status = "cosv_disabled_slots_missing"
            fallback.route = displayRoute
            fallback.controlled = nil
            fallback.disabledReason = cosvSlotsDisabledReason
            return fallback
        end
    end

    if displayRoute then
        displayControlled = ResolveExactControlledSlotAcrossDisplayFamilies(rawRecordID, appearance, displayRoute)

        if (displayControlled.status == "exact" or displayControlled.status == "overflow") and type(displayControlled.controlled) == "table" then
            DebugLog("scanner recovery selected family: " .. tostring(displayControlled.family))
            DebugLog("scanner recovery selected slot: " .. tostring(displayControlled.controlled.vehicleID)
                .. " status=" .. tostring(displayControlled.status))
            return {
                ok = true,
                garageID = displayControlled.controlled.vehicleID,
                mode = "cosv",
                status = displayControlled.status,
                route = displayRoute,
                controlled = displayControlled.controlled,
                selectedFamily = displayControlled.family,
            }
        end

        DebugLog("scanner recovery miss before fallback: display=" .. tostring(displayName)
            .. " appearance=" .. tostring(displayControlled.normalizedAppearance)
            .. " status=" .. tostring(displayControlled.status))
    end

    if modConfig.enableLastStandScaner == true then
        local lastStandContext = {
            rawRecordID = rawRecordID,
            appearance = appearance,
            displayRoute = displayRoute,
            displayName = displayName,
            scannerDisplayName = currentScannerName,
            currentDisplayName = currentDisplayName,
            strictOverflowTriedFamily = displayControlled and displayControlled.strictOverflowTriedFamily or nil,
        }

        local lastStandExact = TryLastStandExactAppearance(lastStandContext)

        if lastStandExact.ok == true and type(lastStandExact.controlled) == "table" and lastStandExact.controlled.vehicleID then
            DebugLog("last stand exact selected family: " .. tostring(lastStandExact.family))
            DebugLog("last stand exact selected slot: " .. tostring(lastStandExact.controlled.vehicleID))
            return {
                ok = true,
                garageID = lastStandExact.controlled.vehicleID,
                mode = "cosv",
                status = lastStandExact.status,
                route = displayRoute,
                controlled = lastStandExact.controlled,
                selectedFamily = lastStandExact.family,
                recoveryKind = lastStandExact.recoveryKind,
                loreMessage = lastStandExact.message,
            }
        end

        DebugLog("last stand exact miss: appearance=" .. tostring(lastStandExact.normalizedAppearance)
            .. " status=" .. tostring(lastStandExact.status))

        if displayRoute then
            local lastStandOverflow = TryLastStandOverflow(lastStandContext)

            if lastStandOverflow.ok == true and type(lastStandOverflow.controlled) == "table" and lastStandOverflow.controlled.vehicleID then
                DebugLog("last stand overflow selected family: " .. tostring(lastStandOverflow.family))
                DebugLog("last stand overflow selected slot: " .. tostring(lastStandOverflow.controlled.vehicleID))
                return {
                    ok = true,
                    garageID = lastStandOverflow.controlled.vehicleID,
                    mode = "cosv",
                    status = lastStandOverflow.status,
                    route = displayRoute,
                    controlled = lastStandOverflow.controlled,
                    selectedFamily = lastStandOverflow.family,
                    recoveryKind = lastStandOverflow.recoveryKind,
                    loreMessage = lastStandOverflow.message,
                }
            end

            DebugLog("last stand overflow miss: display=" .. tostring(lastStandOverflow.matchedDisplayName or displayName)
                .. " status=" .. tostring(lastStandOverflow.status))
        end
    end

    local fallback = FallbackClaim(rawRecordID, appearance)
    fallback.route = displayRoute
    fallback.controlled = displayControlled
    return fallback
end

function SanitizeGarageIDPart(text)
    text = tostring(text or "")
    text = string.gsub(text, "[^%w_]+", "_")
    text = string.gsub(text, "_+", "_")
    text = string.gsub(text, "^_+", "")
    text = string.gsub(text, "_+$", "")

    if text == "" then
        return nil
    end

    return string.lower(text)
end

function BuildGeneratedAppearanceGarageID(recordID, appearance)
    if not recordID or not IsUsefulAppearanceName(appearance) then
        return nil
    end

    local appearancePart = SanitizeGarageIDPart(appearance)

    if not appearancePart then
        return nil
    end

    return tostring(recordID) .. "_cosv_" .. appearancePart
end

function BuildGarageID(recordID, appearance)
    local garageID = tostring(recordID)

    if IsUsefulAppearanceName(appearance) then
        local appearanceGarageID = tostring(recordID) .. "_" .. tostring(appearance)

        if HasTweakDBRecord(appearanceGarageID) then
            return appearanceGarageID
        end

        local generatedGarageID = BuildGeneratedAppearanceGarageID(recordID, appearance)

        if generatedGarageID and HasTweakDBRecord(generatedGarageID) then
            return generatedGarageID
        end
    end

    return garageID
end

function LoadClaimedAppearanceRecords()
    if claimedAppearanceRecordsLoaded == true then
        return
    end

    claimedAppearanceRecordsLoaded = true

    local file = io and io.open and io.open(claimedAppearanceRecordsPath, "r") or nil
    if not file then
        return
    end

    for line in file:lines() do
        local garageID, recordID, appearance = string.match(line or "", "^([^|]+)|([^|]+)|(.+)$")

        if garageID and recordID and appearance then
            claimedAppearanceRecords[garageID] = {
                garageID = garageID,
                recordID = recordID,
                appearance = appearance
            }
        end
    end

    file:close()
end

function SaveClaimedAppearanceRecords()
    if not io or not io.open then
        return false
    end

    local file = io.open(claimedAppearanceRecordsPath, "w")
    if not file then
        return false
    end

    for garageID, entry in pairs(claimedAppearanceRecords) do
        if entry and entry.garageID and entry.recordID and entry.appearance then
            file:write(tostring(entry.garageID) .. "|" .. tostring(entry.recordID) .. "|" .. tostring(entry.appearance) .. "\n")
        end
    end

    file:close()
    return true
end

function RememberClaimedAppearanceRecord(garageID, recordID, appearance)
    if not garageID or not recordID or not IsUsefulAppearanceName(appearance) then
        return
    end

    claimedAppearanceRecords[garageID] = {
        garageID = garageID,
        recordID = recordID,
        appearance = appearance
    }

    SaveClaimedAppearanceRecords()
end

function EnsureAppearanceGarageRecord(recordID, appearance)
    if not recordID or not IsUsefulAppearanceName(appearance) then
        return tostring(recordID)
    end

    local vanillaAppearanceGarageID = tostring(recordID) .. "_" .. tostring(appearance)

    if HasTweakDBRecord(vanillaAppearanceGarageID) then
        return vanillaAppearanceGarageID
    end

    local generatedGarageID = BuildGeneratedAppearanceGarageID(recordID, appearance)

    if not generatedGarageID then
        return tostring(recordID)
    end

    if HasTweakDBRecord(generatedGarageID) then
        EnsureVehicleInVehicleList(generatedGarageID)
        return generatedGarageID
    end

    if not TweakDB or not TweakDB.CloneRecord or not TweakDB.SetFlat or not TweakDB.Update then
        return tostring(recordID)
    end

    local okClone = pcall(function()
        return TweakDB:CloneRecord(generatedGarageID, tostring(recordID))
    end)

    if okClone ~= true or not HasTweakDBRecord(generatedGarageID) then
        return tostring(recordID)
    end

    local okSet, setResult = pcall(function()
        return TweakDB:SetFlat(generatedGarageID .. ".appearanceName", CName.new(tostring(appearance)))
    end)

    if okSet ~= true or setResult ~= true then
        return tostring(recordID)
    end

    pcall(function()
        TweakDB:Update(generatedGarageID)
    end)

    EnsureVehicleInVehicleList(generatedGarageID)
    return generatedGarageID
end

function RestoreClaimedAppearanceRecords()
    LoadClaimedAppearanceRecords()

    for _, entry in pairs(claimedAppearanceRecords) do
        if entry and entry.garageID and entry.recordID and IsUsefulAppearanceName(entry.appearance) then
            EnsureAppearanceGarageRecord(entry.recordID, entry.appearance)
        end
    end
end

function EnsureVehicleInVehicleList(garageID)
    if not garageID or not TweakDB.GetFlat or not TweakDB.SetFlat or not TweakDB.Update then
        return false
    end

    if IsVehicleInVehicleList(garageID) == true then
        return true
    end

    local ok, vehicleList = pcall(function()
        return TweakDB:GetFlat("Vehicle.vehicle_list.list")
    end)

    if not ok or not vehicleList then
        return false
    end

    table.insert(vehicleList, TweakDBID.new(garageID))

    local okSet = pcall(function()
        TweakDB:SetFlat("Vehicle.vehicle_list.list", vehicleList)
        TweakDB:Update("Vehicle.vehicle_list.list")
    end)

    return okSet == true
end

function IsVehicleInVehicleList(garageID)
    if not garageID or not TweakDB.GetFlat then
        return false
    end

    local ok, vehicleList = pcall(function()
        return TweakDB:GetFlat("Vehicle.vehicle_list.list")
    end)

    if not ok or not vehicleList then
        return false
    end

    for _, vehicleID in ipairs(vehicleList) do
        local listID = vehicleID and vehicleID.value or nil

        if listID == garageID then
            return true
        end
    end

    return false
end

function IsFallbackDirectSafeRecord(recordID)
    if not recordID or recordID == "" then
        return false
    end

    if modConfig.enableRawRecords == true then
        return HasTweakDBRecord(recordID) == true
    end

    if DIRECT_SAFE_UNLOCK_IDS[tostring(recordID)] == true then
        return true
    end

    for _, familyBank in pairs(COSV_SLOT_BANK or {}) do
        if type(familyBank) == "table" then
            for _, entry in ipairs(familyBank.slots or {}) do
                if entry and entry.vehicleID == recordID then
                    return true
                end
            end

            for _, entry in ipairs(familyBank.overflowSlots or {}) do
                if entry and entry.vehicleID == recordID then
                    return true
                end
            end

            for _, template in pairs(familyBank.exactTemplates or {}) do
                if type(template) == "string" and template ~= "" then
                    for i = 1, modConfig.MAX_COSV_EXACT_SLOT_SCAN do
                        if string.format(template, i) == recordID then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

function ShouldSkipUnlockableVehicleRecord(recordID)
    if not recordID then
        return true
    end

    local lowerID = string.lower(recordID)

    return string.find(lowerID, "broke") ~= nil
        or string.find(lowerID, "disable") ~= nil
        or string.find(lowerID, "interact") ~= nil
        or string.find(lowerID, "vehicle.q") ~= nil
end

function PrimeVehicleListWithRawRecords()
    if vehicleListPrimed or not TweakDB.GetFlat or not TweakDB.GetRecords or not TweakDB.SetFlat or not TweakDB.Update then
        return
    end

    local okList, vehicleList = pcall(function()
        return TweakDB:GetFlat("Vehicle.vehicle_list.list")
    end)

    local okRecords, vehicleRecords = pcall(function()
        return TweakDB:GetRecords("gamedataVehicle_Record")
    end)

    if not okList or not vehicleList or not okRecords or not vehicleRecords then
        return
    end

    local existing = {}
    for _, vehicleID in ipairs(vehicleList) do
        local listID = vehicleID and vehicleID.value or nil

        if listID then
            existing[listID] = true
        end
    end

    local changed = false

    for _, vehicleRecord in ipairs(vehicleRecords) do
        local recordID = nil

        local okRecordID, rawRecordID = pcall(function()
            return vehicleRecord:GetRecordID()
        end)

        if okRecordID and rawRecordID and rawRecordID.value then
            recordID = rawRecordID.value
        else
            local okID, rawID = pcall(function()
                return vehicleRecord:GetID()
            end)

            if okID and rawID and rawID.value then
                recordID = rawID.value
            end
        end

        if recordID and existing[recordID] ~= true and ShouldSkipUnlockableVehicleRecord(recordID) == false
            and (modConfig.enableRawRecords == true or string.find(recordID, "_cosv_") ~= nil) then
            table.insert(vehicleList, TweakDBID.new(recordID))
            existing[recordID] = true
            changed = true
        end
    end

    if changed then
        pcall(function()
            TweakDB:SetFlat("Vehicle.vehicle_list.list", vehicleList)
            TweakDB:Update("Vehicle.vehicle_list.list")
        end)
    end

    vehicleListPrimed = true
end

function RoundedPositionPart(value)
    if not value then
        return "nil"
    end

    return tostring(math.floor(value + 0.5))
end

function GetVehicleWorldKey(vehicle)
    if not vehicle then
        return nil
    end

    local recordID = GetVehicleRecordText(vehicle) or "unknown"

    local ok, entityID = pcall(function()
        return vehicle:GetEntityID()
    end)

    if ok and entityID then
        local okHash, hash = pcall(function()
            return entityID.hash
        end)

        if okHash and hash then
            return recordID .. "|entity|" .. tostring(hash)
        end

        local entityText = tostring(entityID)
        if entityText and entityText ~= "" then
            return recordID .. "|entity|" .. entityText
        end
    end

    local okPos, pos = pcall(function()
        return vehicle:GetWorldTransform():GetWorldPosition():ToVector4()
    end)

    if not okPos or not pos then
        okPos, pos = pcall(function()
            return vehicle:GetWorldPosition():ToVector4()
        end)
    end

    if okPos and pos then
        return recordID .. "|pos|" .. RoundedPositionPart(pos.x) .. ":" .. RoundedPositionPart(pos.y) .. ":" .. RoundedPositionPart(pos.z)
    end

    return recordID
end

function CaptureVehicle(vehicle)
    ClearPaintPreviewStartBlockedLog()
    ClearPaintPreviewUnavailableNotify()
    ClearPendingPaintPreviewUnavailable()
    currentVehicle = vehicle
    currentRecordID = GetVehicleRecordText(vehicle)
    currentAppearance = GetVehicleAppearanceText(vehicle)
    currentScannerName = GetVehicleDisplayName(currentRecordID)
    currentDisplayName = NormalizeVehicleDisplayName(currentScannerName)
    currentVehicleKey = GetVehicleWorldKey(vehicle)
    currentVehicleIsPlayerVehicle = IsPhysicalPlayerVehicle(vehicle)

    -- Guard: reject non-vehicle records (e.g. Character.* from NPC mounts or cutscene passengers)
    if currentRecordID and not tostring(currentRecordID):find("^Vehicle%.", 1, false) then
        local displayRoute = select(1, ResolveDisplayNameRoute(currentRecordID, currentDisplayName))

        if not displayRoute then
            DebugLog("CaptureVehicle: skipped non-vehicle record=" .. tostring(currentRecordID))
            ResetVehicleContext()
            return
        end

        DebugLog("CaptureVehicle: keeping nonstandard record via display route=" .. tostring(displayRoute.family) .. " record=" .. tostring(currentRecordID))
    end

    if modConfig.debugEnabled then
        DebugLog("capture scanner=[" .. tostring(currentScannerName) .. "] normalized=[" .. tostring(currentDisplayName) .. "] record=" .. tostring(currentRecordID))
    end
end

function IsBoardedVehicleOwned(recordID, appearance, vehicle)
    if IsPhysicalPlayerVehicle(vehicle) == true then
        return true
    end

    if recordID and IsGarageVehicleUnlocked(recordID) == true then
        return true
    end

    local garageID = BuildGarageID(recordID, appearance)

    if garageID and garageID ~= "" and IsGarageVehicleUnlocked(garageID) == true then
        return true
    end

    return false
end

function QueueAppearanceRefreshRestore(vehicle, recordID, appearance)
    if not vehicle or not IsUsefulAppearanceName(appearance) or not Game.GetEngineTime then
        return false
    end

    local engineTime = Game.GetEngineTime()
    if not engineTime then
        return false
    end

    local now = engineTime:ToFloat()
    local vehicleHash = nil
    pcall(function()
        vehicleHash = tostring(vehicle:GetEntityID().hash)
    end)

    local remaining = {}
    for _, entry in ipairs(pendingAppearanceRefreshes) do
        if not vehicleHash or entry.vehicleHash ~= vehicleHash then
            table.insert(remaining, entry)
        end
    end
    pendingAppearanceRefreshes = remaining

    table.insert(pendingAppearanceRefreshes, {
        vehicle = vehicle,
        vehicleHash = vehicleHash,
        recordID = recordID,
        appearance = appearance,
        applyAt = now + modConfig.appearanceRefreshReturnDelay,
    })

    return true
end

function ProcessPendingAppearanceRefreshes(now)
    if #pendingAppearanceRefreshes == 0 then
        return
    end

    local remaining = {}

    for _, entry in ipairs(pendingAppearanceRefreshes) do
        if not now or now < (entry.applyAt or 0) then
            table.insert(remaining, entry)
        else
            local applied = false

            if entry.vehicle and IsUsefulAppearanceName(entry.appearance) then
                applied = pcall(function()
                    entry.vehicle:PrefetchAppearanceChange(entry.appearance)
                    entry.vehicle:ScheduleAppearanceChange(entry.appearance)
                end)
            end

            if modConfig.debugEnabled == true then
                DebugLog(
                    "AppearanceRefreshRestore: record=" .. tostring(entry.recordID)
                    .. " appearance=" .. tostring(entry.appearance)
                    .. " ok=" .. tostring(applied == true)
                )
            end
        end
    end

    pendingAppearanceRefreshes = remaining
end

function RefreshForeignBoardedVehicleAppearance(vehicle, recordID, appearance, isOwnedVehicle)
    local refreshResult = "skipped"
    local refreshSource = nil

    if modConfig.enableAppearanceRefresh == true and vehicle and isOwnedVehicle ~= true and IsUsefulAppearanceName(appearance) and type(recordID) == "string" and recordID ~= "" then
        local candidates, sourceStatus = GetAppearanceRefreshSourceAppearances(recordID, appearance)
        local normalizedCurrent = NormalizeAppearanceName(appearance)
        local restoreAppearance = appearance
        local normalizedRestore = normalizedCurrent
        local alternateAppearances = {}
        refreshSource = sourceStatus

        if normalizedRestore and string.find(normalizedRestore, "burnt", 1, true) ~= nil then
            for _, candidate in ipairs(candidates) do
                local normalizedCandidate = NormalizeAppearanceName(candidate)

                if IsUsefulAppearanceName(candidate)
                    and normalizedCandidate
                    and string.find(normalizedCandidate, "burnt", 1, true) == nil
                then
                    restoreAppearance = candidate
                    normalizedRestore = normalizedCandidate
                    break
                end
            end
        end

        for _, candidate in ipairs(candidates) do
            local normalizedCandidate = NormalizeAppearanceName(candidate)

            if IsUsefulAppearanceName(candidate)
                and normalizedCandidate ~= normalizedRestore
                and (not normalizedCandidate or string.find(normalizedCandidate, "burnt", 1, true) == nil)
            then
                table.insert(alternateAppearances, candidate)
            end
        end

        if #alternateAppearances > 0 then
            if QueueAppearanceRefreshRestore(vehicle, recordID, restoreAppearance) == true then
                local ok = pcall(function()
                    vehicle:ScheduleAppearanceChange("")
                end)

                if ok == true then
                    refreshResult = "true"
                else
                    refreshResult = "false"
                    pendingAppearanceRefreshes[#pendingAppearanceRefreshes] = nil
                end
            else
                refreshResult = "same_or_unqueueable"
            end
        else
            refreshResult = "no_alternate"
        end
    end

    if modConfig.debugEnabled == true then
        DebugLog(
            "AppearanceRefresh: record=" .. tostring(recordID)
            .. " appearance=" .. tostring(appearance)
            .. " owned=" .. tostring(isOwnedVehicle == true)
            .. " source=" .. tostring(refreshSource)
            .. " ok=" .. refreshResult
        )
    end

    return refreshResult == "true"
end

function RefreshMountedVehicleContext(isPostLoadRefresh)
    if isPostLoadRefresh ~= true or pendingPostLoadVehicleRefresh ~= true or not IsPlayerReady() or not Game.GetMountedVehicle or not Game.GetPlayer() then
        return false
    end

    local okMounted, mountedVehicle = pcall(function()
        return Game.GetMountedVehicle(Game.GetPlayer())
    end)

    if okMounted and mountedVehicle then
        isPlayerMounted = true
        CaptureVehicle(mountedVehicle)
        DebugLog("post-load mounted record=" .. tostring(currentRecordID))
        DebugLog("post-load mounted appearance=" .. tostring(currentAppearance))
        return true
    end

    return false
end

function ProcessPostLoadVehicleRefresh()
    if pendingPostLoadVehicleRefresh ~= true or postLoadVehicleRefreshDone == true then
        return
    end

    ResetVehicleContext()
    ClearMapPins()

    RefreshMountedVehicleContext(true)

    pendingPostLoadVehicleRefresh = false
    postLoadVehicleRefreshDone = true
end

function IsGarageVehicleUnlocked(garageID)
    if not garageID or not Game.GetVehicleSystem() then
        return false
    end

    local ok, result = pcall(function()
        return Game.GetVehicleSystem():IsVehiclePlayerUnlocked(TweakDBID.new(garageID))
    end)

    return ok and result == true
end

function SetGarageBackupActionStatus(message, detail)
    garageBackupState.lastActionMessage = message
    garageBackupState.lastActionDetail = detail
end

function IsDeclaredCOSVSlotVehicleID(vehicleID, slotLookup)
    if type(vehicleID) ~= "string" or vehicleID == "" then
        return false
    end

    if string.find(string.lower(vehicleID), "cosv", 1, true) == nil then
        return false
    end

    slotLookup = slotLookup or BuildDeclaredCOSVLookups()
    return slotLookup[vehicleID] ~= nil
end

function BuildCOSVGarageBackup()
    local slotLookup = BuildDeclaredCOSVLookups()
    local backup = {}

    for vehicleID, _ in pairs(slotLookup or {}) do
        if IsDeclaredCOSVSlotVehicleID(vehicleID, slotLookup) == true
            and IsGarageVehicleUnlocked(vehicleID) == true
        then
            backup[#backup + 1] = vehicleID
        end
    end

    table.sort(backup)
    return backup
end

function WriteCOSVGarageBackupFile(fileName, backup)
    if type(fileName) ~= "string" or fileName == "" or type(backup) ~= "table" then
        return false, nil
    end

    local lines = { "[\n" }

    for index, vehicleID in ipairs(backup) do
        local suffix = index < #backup and "," or ""
        lines[#lines + 1] = string.format('  "%s"%s\n', vehicleID, suffix)
    end

    lines[#lines + 1] = "]\n"
    local payload = table.concat(lines)

    for _, path in ipairs(GetModFilePathCandidates(fileName)) do
        local ok, fileHandle = pcall(io.open, path, "w")

        if ok and fileHandle then
            fileHandle:write(payload)
            fileHandle:close()
            return true, path
        end
    end

    return false, nil
end

function ReadCOSVGarageBackupFile(fileName)
    if type(fileName) ~= "string" or fileName == "" then
        return nil, nil
    end

    local content = nil
    local loadedPath = nil

    for _, path in ipairs(GetModFilePathCandidates(fileName)) do
        local ok, fileHandle = pcall(io.open, path, "r")

        if ok and fileHandle then
            content = fileHandle:read("*a")
            fileHandle:close()
            loadedPath = path
            break
        end
    end

    if not content or content == "" then
        return nil, loadedPath
    end

    local slotLookup = BuildDeclaredCOSVLookups()
    local backup = {}
    local seen = {}

    for vehicleID in string.gmatch(content, '"(Vehicle[^"\r\n]+)"') do
        if seen[vehicleID] ~= true
            and IsDeclaredCOSVSlotVehicleID(vehicleID, slotLookup) == true
            and HasTweakDBRecord(vehicleID) == true
        then
            seen[vehicleID] = true
            backup[#backup + 1] = vehicleID
        end
    end

    table.sort(backup)
    return backup, loadedPath
end

function SaveCOSVGarageBackup(fileName, reason)
    local backup = BuildCOSVGarageBackup()
    local ok, savedPath = WriteCOSVGarageBackupFile(fileName, backup)
    local detail = "count=" .. tostring(#backup) .. " reason=" .. tostring(reason or "manual") .. " path=" .. tostring(savedPath or "unavailable")

    if ok == true then
        DebugLog("cosv_backup_save ok " .. detail)
        return true, #backup, savedPath
    end

    DebugLog("cosv_backup_save failed " .. detail)
    return false, #backup, savedPath
end

function CaptureLastTransactionCOSVBackup(reason)
    local ok, count = SaveCOSVGarageBackup(garageBackupState.lastTransactionFileName, reason or "transaction")

    if ok == true then
        garageBackupState.lastTransactionCount = count or 0
        return true
    end

    return false
end

function RestoreCOSVGarageBackupEntries(backup)
    local result = {
        restored = 0,
        attempted = 0,
        total = type(backup) == "table" and #backup or 0,
    }

    if type(backup) ~= "table" then
        return result
    end

    local slotLookup = BuildDeclaredCOSVLookups()
    local vehicleSystem = Game.GetVehicleSystem()

    if not vehicleSystem then
        return result
    end

    for _, vehicleID in ipairs(backup) do
        if IsDeclaredCOSVSlotVehicleID(vehicleID, slotLookup) == true
            and HasTweakDBRecord(vehicleID) == true
        then
            result.attempted = result.attempted + 1

            if IsGarageVehicleUnlocked(vehicleID) ~= true then
                local ok = pcall(function()
                    vehicleSystem:EnablePlayerVehicle(vehicleID, true, false)
                end)

                if not ok then
                    pcall(function()
                        vehicleSystem:EnablePlayerVehicle(TweakDBID.new(vehicleID), true, false)
                    end)
                end
            end

            if IsGarageVehicleUnlocked(vehicleID) == true then
                result.restored = result.restored + 1
            end
        end
    end

    return result
end

function RestoreCOSVGarageBackupFile(fileName)
    local backup, loadedPath = ReadCOSVGarageBackupFile(fileName)

    if type(backup) ~= "table" then
        return {
            ok = false,
            reason = "backup_missing",
            restored = 0,
            attempted = 0,
            total = 0,
            path = loadedPath,
        }
    end

    local restoreResult = RestoreCOSVGarageBackupEntries(backup)
    restoreResult.ok = true
    restoreResult.reason = nil
    restoreResult.path = loadedPath
    return restoreResult
end

function CreateManualCOSVGarageBackup()
    local ok, count, savedPath = SaveCOSVGarageBackup(garageBackupState.manualFileName, "manual")

    if ok == true then
        garageBackupState.lastManualCount = count or 0
        SetGarageBackupActionStatus("manual backup saved", "count=" .. tostring(count or 0))
        Notify(Fmt("notify.backup.manual_saved", { count = count or 0 }), 5, gameSimpleMessageType.Undefined, true)
        DebugLog("cosv_manual_backup_saved path=" .. tostring(savedPath))
        print("[COSV] Manual garage backup saved: count=" .. tostring(count or 0) .. " path=" .. tostring(savedPath))
        return true
    end

    SetGarageBackupActionStatus("manual backup failed", "count=" .. tostring(count or 0))
    Notify(Msg("notify.backup.manual_failed"), 5, gameSimpleMessageType.Undefined, true)
    print("[COSV] Manual garage backup failed: count=" .. tostring(count or 0) .. " path=" .. tostring(savedPath))
    return false
end

function RestoreManualCOSVGarageBackup()
    local result = RestoreCOSVGarageBackupFile(garageBackupState.manualFileName)

    if result.ok == true then
        garageBackupState.lastRestoreCount = result.restored or 0
        SetGarageBackupActionStatus("manual backup restored", "restored=" .. tostring(result.restored or 0) .. "/" .. tostring(result.total or 0))
        Notify(Fmt("notify.backup.manual_restored", { restored = result.restored or 0, total = result.total or 0 }), 5, gameSimpleMessageType.Undefined, true)
        print("[COSV] Manual garage backup restored: restored=" .. tostring(result.restored or 0) .. "/" .. tostring(result.total or 0) .. " path=" .. tostring(result.path))
        return true
    end

    SetGarageBackupActionStatus("manual backup missing", tostring(result.reason or "unknown"))
    Notify(Msg("notify.backup.manual_restore_failed"), 5, gameSimpleMessageType.Undefined, true)
    print("[COSV] Manual garage backup restore failed: reason=" .. tostring(result.reason or "unknown") .. " path=" .. tostring(result.path))
    return false
end

function RestoreLastTransactionCOSVGarageState()
    local result = RestoreCOSVGarageBackupFile(garageBackupState.lastTransactionFileName)

    if result.ok == true then
        garageBackupState.lastRestoreCount = result.restored or 0
        SetGarageBackupActionStatus("last transaction restored", "restored=" .. tostring(result.restored or 0) .. "/" .. tostring(result.total or 0))
        Notify(Fmt("notify.backup.last_transaction_restored", { restored = result.restored or 0, total = result.total or 0 }), 5, gameSimpleMessageType.Undefined, true)
        print("[COSV] Last transaction garage state restored: restored=" .. tostring(result.restored or 0) .. "/" .. tostring(result.total or 0) .. " path=" .. tostring(result.path))
        return true
    end

    SetGarageBackupActionStatus("last transaction backup missing", tostring(result.reason or "unknown"))
    Notify(Msg("notify.backup.last_transaction_restore_failed"), 5, gameSimpleMessageType.Undefined, true)
    print("[COSV] Last transaction garage state restore failed: reason=" .. tostring(result.reason or "unknown") .. " path=" .. tostring(result.path))
    return false
end

function GetUnlockedVehicleListDiagnosticStatus(garageID)
    if not garageID then
        return false, "no_garage_id"
    end

    local vehicleSystem = Game.GetVehicleSystem()

    if not vehicleSystem then
        return false, "no_vehicle_system"
    end

    local ok, unlockedVehicles = pcall(function()
        return vehicleSystem:GetPlayerUnlockedVehicles()
    end)

    if not ok then
        return false, "get_unlocked_failed"
    end

    if type(unlockedVehicles) ~= "table" then
        return false, "get_unlocked_non_table:" .. tostring(unlockedVehicles)
    end

    for _, unlockedVehicleID in ipairs(unlockedVehicles) do
        local unlockedID = unlockedVehicleID and unlockedVehicleID.value or nil

        if unlockedID == garageID then
            return true, "ok"
        end
    end

    return false, "ok"
end

local function ResolveGarageVehicleSystemID(garageID)
    if type(garageID) ~= "string" or garageID == "" then
        return nil, "invalid_garage_id"
    end

    local resolvedID = nil

    if GarageVehicleID and GarageVehicleID.Resolve then
        local okResolve, value = pcall(function()
            return GarageVehicleID.Resolve(garageID)
        end)

        if okResolve and value then
            resolvedID = value
        end
    end

    if not resolvedID and TweakDBID and TweakDBID.new and Cast then
        local okCast, value = pcall(function()
            return Cast(TweakDBID.new(garageID))
        end)

        if okCast and value then
            resolvedID = value
        end
    end

    if not resolvedID then
        return nil, "resolve_failed"
    end

    return resolvedID, "ok"
end

local function RefreshSoldGarageVehicleRegistration(garageID)
    local vehicleSystem = Game.GetVehicleSystem and Game.GetVehicleSystem() or nil

    if not vehicleSystem then
        return false, "no_vehicle_system"
    end

    local garageVehicleID, resolveStatus = ResolveGarageVehicleSystemID(garageID)

    if not garageVehicleID then
        return false, resolveStatus or "resolve_failed"
    end

    local toggleOk, toggleResult = pcall(function()
        return vehicleSystem:TogglePlayerActiveVehicle(garageVehicleID, gamedataVehicleType.Car, false)
    end)

    local unregisterOk, unregisterResult = pcall(function()
        return vehicleSystem:UnregisterPlayerVehicle(garageVehicleID)
    end)

    local status = "toggleOk=" .. tostring(toggleOk == true)
        .. " toggleResult=" .. tostring(toggleResult)
        .. " unregisterOk=" .. tostring(unregisterOk == true)
        .. " unregisterResult=" .. tostring(unregisterResult)

    return unregisterOk == true, status
end

function IsPhysicalPlayerVehicle(vehicle)
    if not vehicle then
        return true
    end

    local ok, result = pcall(function()
        return vehicle:IsPlayerVehicle()
    end)

    if ok and result ~= nil then
        return result == true
    end

    return true
end

function IsSmugglerShop(shop)
    if not shop or not shop.key then
        return false
    end

    local shopKey = string.lower(tostring(shop.key))
    return string.find(shopKey, "smuggler", 1, true) ~= nil
end

local function IsChopShop(shop)
    local shopKey = shop and shop.key or nil

    return shopKey == "badlandsJunkShop"
        or shopKey == "southernBadlandsChopShop"
        or shopKey == "biotechnicaFlatsChopShop"
end

local function GetCOSVMappinIconPart(shop)
    if shop and shop.mode == "paint" then
        return "brush"
    end

    if IsChopShop(shop) then
        return "shop"
    end

    if IsSmugglerShop(shop) then
        return "mask"
    end

    if shop and shop.mode == "unlock" then
        return "unlock"
    end

    return "money"
end

local function CreateCOSVMappinScriptData(iconPart)
    local ok, cosvScriptData = pcall(function()
        return NewObject("COSVMappinData")
    end)

    if modConfig.cosvMappinDataProbeDone ~= true then
        modConfig.cosvMappinDataProbeDone = true
        modConfig.cosvMappinDataAvailable = ok == true and cosvScriptData ~= nil

        if modConfig.cosvMappinDataAvailable == true then
            modConfig.cosvMappinDataCtorError = nil
            DebugLog("cosv mappin data probe available=true")
        else
            modConfig.cosvMappinDataCtorError = tostring(cosvScriptData)
            DebugLog("cosv mappin data probe available=false error=" .. tostring(modConfig.cosvMappinDataCtorError))
        end
    end

    if ok ~= true or cosvScriptData == nil then
        return nil
    end

    local assignOk, assignErr = pcall(function()
        cosvScriptData.iconPart = CName.new(iconPart)
    end)

    if assignOk ~= true then
        DebugLog("cosv mappin data assign failed iconPart=" .. tostring(iconPart)
            .. " error=" .. tostring(assignErr))
        return nil
    end

    return cosvScriptData
end

local function BuildCOSVShopMappinData(shop)
    local iconPart = GetCOSVMappinIconPart(shop)
    local cosvScriptData = CreateCOSVMappinScriptData(iconPart)
    local payload = {
        mappinType = "Mappins.QuestDynamicMappinDefinition",
        variant = gamedataMappinVariant.QuestGiverVariant,
        visibleThroughWalls = false,
        active = true
    }

    if cosvScriptData ~= nil then
        payload.scriptData = cosvScriptData
    end

    local ok, data = pcall(function()
        return MappinData.new(payload)
    end)

    if ok == true and data ~= nil then
        return data
    end

    DebugLog("cosv mappin data ctor failed shop=" .. tostring(shop and shop.key or "nil")
        .. " iconPart=" .. tostring(iconPart)
        .. " error=" .. tostring(data))

    local fallbackOk, fallbackData = pcall(function()
        return MappinData.new({
            mappinType = "Mappins.QuestDynamicMappinDefinition",
            variant = gamedataMappinVariant.QuestGiverVariant,
            visibleThroughWalls = false,
            active = true
        })
    end)

    if fallbackOk == true then
        return fallbackData
    end

    DebugLog("cosv mappin fallback ctor failed shop=" .. tostring(shop and shop.key or "nil")
        .. " error=" .. tostring(fallbackData))
    return nil
end

local function TextMatchesAnyToken(recordText, garageText, appearanceText, tokens)
    for _, token in ipairs(tokens or {}) do
        local tokenText = string.lower(tostring(token or ""))

        if tokenText ~= "" and (
            (recordText ~= "" and string.find(recordText, tokenText, 1, true) ~= nil)
            or (garageText ~= "" and string.find(garageText, tokenText, 1, true) ~= nil)
            or (appearanceText ~= "" and string.find(appearanceText, tokenText, 1, true) ~= nil)
        ) then
            return true
        end
    end

    return false
end

function ShopAcceptsVehicle(shop, recordID, garageID, appearance)
    if not shop then
        return true
    end

    local recordText = string.lower(tostring(recordID or ""))
    local garageText = string.lower(tostring(garageID or ""))
    local appearanceText = string.lower(tostring(appearance or ""))

    if TextMatchesAnyToken(recordText, garageText, appearanceText, shop.blockedVehicleTokens) then
        return false
    end

    if shop.acceptedVehicleTokens then
        return TextMatchesAnyToken(recordText, garageText, appearanceText, shop.acceptedVehicleTokens)
    end

    return true
end

function IsVehicleExcludedFromSale(recordID, appearance)
    if IsIgnoredSellRecord(recordID) then
        return true
    end

    local recordText = string.lower(tostring(recordID or ""))
    local appearanceText = string.lower(tostring(appearance or ""))
    local garageText = recordText

    if recordID then
        garageText = string.lower(tostring(BuildGarageID(recordID, appearance) or recordID))
    end

    for _, token in ipairs(saleExcludedVehicleTokens or {}) do
        local tokenText = string.lower(tostring(token or ""))

        if tokenText ~= "" then
            if (recordText ~= "" and string.find(recordText, tokenText, 1, true) ~= nil)
                or (garageText ~= "" and string.find(garageText, tokenText, 1, true) ~= nil)
                or (appearanceText ~= "" and string.find(appearanceText, tokenText, 1, true) ~= nil) then
                return true
            end
        end
    end

    return false
end

function ResolveVehicleSaleContext(recordID, appearance, vehicle)
    local isPhysicalPlayerVehicle = IsPhysicalPlayerVehicle(vehicle)
    local garageID = BuildGarageID(recordID, appearance)
    local isOwnedGarageVehicle = isPhysicalPlayerVehicle == true

    if isOwnedGarageVehicle == true then
        garageID = GetVehicleRecordText(vehicle) or garageID
    end

    return {
        garageID = garageID,
        isPhysicalPlayerVehicle = isPhysicalPlayerVehicle,
        isOwnedGarageVehicle = isOwnedGarageVehicle,
        isOwnedSellCandidate = isOwnedGarageVehicle == true or isPhysicalPlayerVehicle == true,
        isGarageUnlocked = isOwnedGarageVehicle == true or IsGarageVehicleUnlocked(garageID),
        isSaleExcluded = IsVehicleExcludedFromSale(recordID, appearance)
    }
end

function GetPlayerMoney()
    local player = Game.GetPlayer()
    if not player or not Game.GetTransactionSystem() then
        return 0
    end

    local ok, quantity = pcall(function()
        return Game.GetTransactionSystem():GetItemQuantity(player, ItemID.new(TweakDBID.new("Items.money")))
    end)

    if ok and quantity then
        return quantity
    end

    ok, quantity = pcall(function()
        return Game.GetTransactionSystem():GetItemQuantity(player, ItemID.FromTDBID(TweakDBID.new("Items.money")))
    end)

    if ok and quantity then
        return quantity
    end

    return 0
end

function ChangePlayerMoney(amount)
    if amount < 0 and Game.GetTransactionSystem and Game.GetTransactionSystem() and Game.GetPlayer() then
        local ok = pcall(function()
            Game.GetTransactionSystem():GiveItem(Game.GetPlayer(), ItemID.new(TweakDBID.new("Items.money")), amount)
        end)

        if ok then
            return
        end
    end

    if Game.AddToInventory then
        Game.AddToInventory("Items.money", amount)
        return
    end

    if Game.GetTransactionSystem and Game.GetTransactionSystem() and Game.GetPlayer() then
        pcall(function()
            Game.GetTransactionSystem():GiveItem(Game.GetPlayer(), ItemID.FromTDBID(TweakDBID.new("Items.money")), amount)
        end)
    end
end

BuildPaintPreviewIntroMessage = function()
    return Fmt("notify.paint.preview_intro", { cost = math.floor(tonumber(modConfig.paintServiceCost) or 0) })
end

function LoadSettings()
    local content = nil

    for _, path in ipairs(GetSettingsPathCandidates()) do
        local ok, f = pcall(io.open, path, "r")
        if ok and f then
            content = f:read("*a")
            f:close()
            break
        end
    end

    if not content or content == "" then
        return
    end

    pcall(function()
        local u = tonumber(content:match('"unlockFeeMultiplier"%s*:%s*([%d%.]+)'))
        local s = tonumber(content:match('"salePriceMultiplier"%s*:%s*([%d%.]+)'))
        local p = tonumber(content:match('"paintServiceCost"%s*:%s*(%d+)'))
        if not p then
            p = tonumber(content:match('"paintPreviewCost"%s*:%s*(%d+)'))
        end
        local i = tonumber(content:match('"paintPreviewIntervalSeconds"%s*:%s*([%d%.]+)'))
        local r = content:match('"enableRawRecords"%s*:%s*(%a+)')
        local a = content:match('"enableAppearanceRefresh"%s*:%s*(%a+)')
        local d = content:match('"enableDogtownDropoff"%s*:%s*(%a+)')
        local h = content:match('"doNotApplyRemoteHack"%s*:%s*(%a+)')
        local l = content:match('"enableLastStandScaner"%s*:%s*(%a+)')
        if not d then
            d = content:match('"enableDebugShops"%s*:%s*(%a+)')
        end
        if u and u >= 0.1 and u <= 5.0 then modConfig.unlockFeeMultiplier = u end
        if s and s >= 0.1 and s <= 5.0 then modConfig.salePriceMultiplier = s end
        if p and p >= 0 and p <= 3000 then modConfig.paintServiceCost = p end
        if i and i >= 3 and i <= 15 then paintPreviewIntervalSeconds = i end
        if r == "true" then modConfig.enableRawRecords = true elseif r == "false" then modConfig.enableRawRecords = false end
        if a == "true" then modConfig.enableAppearanceRefresh = true elseif a == "false" then modConfig.enableAppearanceRefresh = false end
        if d == "true" then modConfig.enableDogtownDropoff = true elseif d == "false" then modConfig.enableDogtownDropoff = false end
        if h == "true" then modConfig.doNotApplyRemoteHack = true elseif h == "false" then modConfig.doNotApplyRemoteHack = false end
        if l == "true" then modConfig.enableLastStandScaner = true elseif l == "false" then modConfig.enableLastStandScaner = false end
    end)
end

function SaveSettings()
    local payload = string.format('{\n  "unlockFeeMultiplier": %.2f,\n  "salePriceMultiplier": %.2f,\n  "paintServiceCost": %d,\n  "paintPreviewIntervalSeconds": %.1f,\n  "enableRawRecords": %s,\n  "enableAppearanceRefresh": %s,\n  "enableDogtownDropoff": %s,\n  "doNotApplyRemoteHack": %s,\n  "enableLastStandScaner": %s\n}\n',
        modConfig.unlockFeeMultiplier,
        modConfig.salePriceMultiplier,
        modConfig.paintServiceCost,
        paintPreviewIntervalSeconds,
        modConfig.enableRawRecords and "true" or "false",
        modConfig.enableAppearanceRefresh and "true" or "false",
        modConfig.enableDogtownDropoff and "true" or "false",
        modConfig.doNotApplyRemoteHack and "true" or "false",
        modConfig.enableLastStandScaner and "true" or "false")

    for _, path in ipairs(GetSettingsPathCandidates()) do
        local ok, f = pcall(io.open, path, "w")
        if ok and f then
            f:write(payload)
            f:close()
            return
        end
    end
end

function MarkSettingsDirty()
    settingsDirty = true

    if Game.GetEngineTime then
        local engineTime = Game.GetEngineTime()
        if engineTime then
            nextSettingsSaveAt = engineTime:ToFloat() + settingsSaveDebounceSeconds
            return
        end
    end

    nextSettingsSaveAt = nil
end

function FlushPendingSettings()
    if settingsDirty ~= true then
        return false
    end

    SaveSettings()
    settingsDirty = false
    nextSettingsSaveAt = nil
    return true
end

function RollUnlockFee()
    return math.max(1, math.floor(math.random(salePricing.unlockFeeMin, salePricing.unlockFeeMax) * modConfig.unlockFeeMultiplier))
end

local function CalculateUnlockTransactionCosts(vehicle, recordID)
    local unlockFee = RollUnlockFee()
    local repairCost = 0

    if modConfig.enableDamageDiscount == true and vehicle then
        local priceText = BuildVehicleDescriptorText(recordID, vehicle)
        local basePrice = GetVehicleBasePrice(priceText)
        local healthPct = GetVehicleHealthPercent(vehicle)
        local damageFraction = 1.0 - healthPct

        if damageFraction > 0.05 then
            repairCost = math.floor(basePrice * damageFraction)
        end
    end

    return unlockFee, repairCost, unlockFee + repairCost
end

function AddSaleProgressRewards(finalPrice, xpRewardOverride, streetCredRewardOverride)
    if modConfig.isXPReward ~= true then
        return
    end

    local xpReward = xpRewardOverride

    if xpReward == nil then
        xpReward = math.floor((salePricing.saleXPReward * (finalPrice or 0)) / 100000)
    end

    local streetCredReward = streetCredRewardOverride

    if streetCredReward == nil then
        streetCredReward = salePricing.saleStreetCredReward
    end

    pcall(function()
        local player = Game.GetPlayer()
        if not player then
            return
        end

        local developmentSystem = PlayerDevelopmentSystem.GetInstance(player)
        if not developmentSystem then
            return
        end

        local developmentData = developmentSystem:GetDevelopmentData(player)
        if not developmentData then
            return
        end

        developmentData:AddExperience(xpReward, gamedataProficiencyType.Level, telemetryLevelGainReason.Gameplay)
    end)

    pcall(function()
        local player = Game.GetPlayer()
        if not player then
            return
        end

        local developmentSystem = PlayerDevelopmentSystem.GetInstance(player)
        if not developmentSystem then
            return
        end

        local developmentData = developmentSystem:GetDevelopmentData(player)
        if not developmentData then
            return
        end

        developmentData:AddExperience(streetCredReward, gamedataProficiencyType.StreetCred, telemetryLevelGainReason.Gameplay)
    end)
end

function ContainsToken(text, token)
    return string.find(text, token, 1, true) ~= nil
end

function GetVehicleBasePrice(priceText)
    for _, rule in ipairs(vehicleBasePrices) do
        if ContainsToken(priceText, rule.token) then
            return rule.price
        end
    end

    return salePricing.defaultVehicleSalePrice
end

function getBasePrice(vehicleID, vehicle)
    return GetVehicleBasePrice(BuildVehicleDescriptorText(vehicleID, vehicle))
end

function BuildVehicleDescriptorText(vehicleID, vehicle)
    local idText = tostring(vehicleID or ""):lower()
    local appearanceText = tostring(GetVehicleAppearancePriceText(vehicle) or ""):lower()

    return idText .. " " .. appearanceText
end

function IsWraithVehicle(priceText)
    return ContainsToken(priceText, "wraiths") or ContainsToken(priceText, "wraith")
end

function IsNomadVehicle(priceText)
    return ContainsToken(priceText, "nomad")
        or ContainsToken(priceText, "aldecaldo")
        or ContainsToken(priceText, "ald_ecaldo")
        or IsWraithVehicle(priceText)
end

function IsBarghestVehicle(priceText)
    return ContainsToken(priceText, "barghest")
        or ContainsToken(priceText, "kurtz")
end


function ApplyNomadPriceClass(price, priceText)
    price = price + salePricing.nomadBonus

    if IsWraithVehicle(priceText) then
        return math.floor(price * salePricing.wraithPriceMultiplier), Msg("pricing.wraith_discount"), true
    end

    return price, Msg("pricing.nomad_bonus"), false
end

function ApplyAppearancePriceClass(price, priceText)
    if IsNomadVehicle(priceText) then
        return ApplyNomadPriceClass(price, priceText)
    end

    if IsBarghestVehicle(priceText) then
        price = price + salePricing.barghestBonus
    end

    -- Emperor Militech compound: smuggler premium on top of corporate multiplier
    if ContainsToken(priceText, "chevalier_emperor") and ContainsToken(priceText, "militech") then
        return math.floor(price * 1.11) + 4000, "Smugglers Love Militech Vehicles!", false
    end

    for _, rule in ipairs(appearancePriceClasses) do
        if ContainsToken(priceText, rule.key) then
            local adjustedPrice = price

            if rule.multiplier then
                adjustedPrice = math.floor(adjustedPrice * rule.multiplier)
            end

            if rule.bonus then
                adjustedPrice = adjustedPrice + rule.bonus
            end

            return adjustedPrice, rule.message, rule.blocksOwnedResaleBonus == true
        end
    end

    return price, nil, false
end


function GetVehicleHealthPercent(vehicle)
    if not vehicle then
        return 1.0
    end

    local okEntity, entityID = pcall(function()
        return vehicle:GetEntityID()
    end)

    if not okEntity or not entityID then
        return 1.0
    end

    local okSystem, statPoolSystem = pcall(function()
        return Game.GetStatPoolsSystem()
    end)

    if not okSystem or not statPoolSystem then
        return 1.0
    end

    local healthPoolType = gamedataStatPoolType.Health

    local okHealth, health = pcall(function()
        return statPoolSystem:GetStatPoolValue(entityID, healthPoolType, false)
    end)

    local okMaxHealth, maxHealth = pcall(function()
        return statPoolSystem:GetStatPoolMaxPointValue(entityID, healthPoolType)
    end)

    if not okHealth or not okMaxHealth or not health or not maxHealth or maxHealth <= 0 then
        return 1.0
    end

    local percent = health / maxHealth

    if percent < 0 then
        return 0
    end

    if percent > 1 then
        return 1
    end

    return percent
end

function GetVehicleDamagePriceMultiplier(vehicle)
    if modConfig.enableDamageDiscount ~= true then
        return 1.0
    end

    return GetVehicleHealthPercent(vehicle)
end

function GetDamageCoeff(vehicle)
    return GetVehicleDamagePriceMultiplier(vehicle)
end

function GetVehicleSalePrice(vehicleID, isOwnedVehicle, vehicle)
    local priceText = BuildVehicleDescriptorText(vehicleID, vehicle)
    local basePrice = GetVehicleBasePrice(priceText)
    local price = basePrice + math.random(0, 999)
    local flavorMessage = nil
    local blocksOwnedResaleBonus = false

    price, flavorMessage, blocksOwnedResaleBonus = ApplyAppearancePriceClass(price, priceText)

    if isOwnedVehicle == true and blocksOwnedResaleBonus ~= true and basePrice >= salePricing.ownedResaleBonusMinBasePrice then
        price = price + salePricing.ownedResaleBonus
    end

    local priceBeforeDamageDiscount = price
    local damageMultiplier = GetVehicleDamagePriceMultiplier(vehicle)

    if damageMultiplier < 1.0 then
        price = math.floor(price * damageMultiplier)

        if damageMultiplier < 0.90 then
            local damageDeduction = math.floor(priceBeforeDamageDiscount - price)
            local damageMessage = "Damage deduction: -€$" .. tostring(damageDeduction)

            if flavorMessage and flavorMessage ~= "" then
                flavorMessage = damageMessage .. "\n" .. flavorMessage
            else
                flavorMessage = damageMessage
            end
        end
    end

    price = math.floor(price * modConfig.salePriceMultiplier)

    if price < salePricing.minimumVehicleSalePrice then
        price = salePricing.minimumVehicleSalePrice
    end

    return math.floor(price), flavorMessage, basePrice
end

local function IsDropoffShop(shop)
    return type(shop) == "table" and tostring(shop.saleProfile or "") == "dropoff"
end

local function GetDropoffVehicleSalePrice(shop, vehicleID, vehicle)
    local basePrice = getBasePrice(vehicleID, vehicle)
    local damageCoeff = GetDamageCoeff(vehicle)
    local payoutMultiplier = tonumber(shop and shop.payoutMultiplier) or 0.75
    local payout = math.floor(basePrice * damageCoeff * payoutMultiplier)
    if payout < 1500 then
        payout = 1500
    end
    return payout, nil, basePrice
end

function LockVehicleEntity(vehicle)
    if not vehicle then
        return
    end

    local ok, vehiclePS = pcall(function()
        return vehicle:GetVehiclePS()
    end)

    if ok and vehiclePS then
        pcall(function()
            vehiclePS:LockAllVehDoors()
        end)

        pcall(function()
            vehiclePS:DisableAllVehInteractions()
        end)
    end
end

function DespawnVehicleHandleDirect(vehicle)
    if not vehicle then
        return
    end

    pcall(function()
        if vehicle:IsVehicle() then
            local vehiclePS = vehicle:GetVehiclePS()
            if vehiclePS then
                vehiclePS:SetHasExploded(false)
            end
        end
    end)

    pcall(function()
        if vehicle.Dispose then
            vehicle:Dispose()
        end
    end)

    pcall(function()
        if vehicle.GetEntity then
            local entity = vehicle:GetEntity()
            if entity and entity.Destroy then
                entity:Destroy()
            end
        end
    end)
end

function TeleportVehicleToDisposalPoint(vehicle, point)
    if not vehicle then
        return false, "no_vehicle"
    end

    if type(point) ~= "table" then
        return false, "no_disposal_point"
    end

    local facility = Game.GetTeleportationFacility()
    if not facility then
        return false, "no_teleportation_facility"
    end

    local teleportOk, teleportErr = pcall(function()
        facility:Teleport(
            vehicle,
            Vector4.new(point.x, point.y, point.z, 1.0),
            EulerAngles.new(0, 0, point.heading)
        )
    end)

    if teleportOk == true then
        return true, "teleported_to_disposal"
    end

    return false, tostring(teleportErr)
end

local function IsVehicleHandleClearlyInvalid(vehicle)
    if not vehicle then
        return true
    end

    local ok = pcall(function()
        if vehicle.GetRecord then
            vehicle:GetRecord()
        elseif vehicle.GetEntityID then
            vehicle:GetEntityID()
        else
            error("no_known_vehicle_probe")
        end
    end)

    return ok ~= true
end

local function GetVehicleWorldPositionSafe(vehicle)
    if not vehicle then
        return nil
    end

    local okPos, pos = pcall(function()
        return vehicle:GetWorldTransform():GetWorldPosition():ToVector4()
    end)

    if okPos and pos then
        return pos
    end

    okPos, pos = pcall(function()
        return vehicle:GetWorldPosition():ToVector4()
    end)

    if okPos and pos then
        return pos
    end

    return nil
end

local function GetVehicleCurrentSpeedSafe(vehicle)
    if not vehicle or not vehicle.GetCurrentSpeed then
        return nil
    end

    local okSpeed, speed = pcall(function()
        return vehicle:GetCurrentSpeed()
    end)

    if okSpeed then
        return speed
    end

    return nil
end

local function DisposeVehicle(vehicle, sourceKind)
    if not vehicle then
        return false, "no_vehicle"
    end

    if IsVehicleHandleClearlyInvalid(vehicle) == true then
        return false, "invalid_vehicle_handle"
    end

    local teleportOk, teleportStatus = TeleportVehicleToDisposalPoint(vehicle, modConfig.shopVehicleDisposalPoint)
    if teleportOk ~= true then
        return false, "disposal_teleport_failed:" .. tostring(teleportStatus)
    end

    local remoteOnOk = false
    if modConfig.doNotApplyRemoteHack ~= true then
        remoteOnOk = pcall(function()
            vehicle:SetVehicleRemoteControlled(true, true, true)
        end)
    end

    local engineTime = Game.GetEngineTime()
    if not engineTime then
        return false, "no_engine_time"
    end

    local now = engineTime:ToFloat()
    table.insert(modConfig.pendingVehicleDisposals, {
        vehicle = vehicle,
        sourceKind = sourceKind,
        remoteOffAt = remoteOnOk == true and (now + modConfig.vehicleDropRemoteReleaseDelay) or nil,
        despawnAt = now + modConfig.vehicleDropDespawnDelay,
        remoteReleased = remoteOnOk ~= true,
        startedAt = now,
    })

    if remoteOnOk == true then
        return true, "vehicle_disposal_started"
    end

    return true, "vehicle_disposal_started_without_remote_pulse"
end

function ProcessPendingVehicleDisposals()
    if #modConfig.pendingVehicleDisposals == 0 or not Game.GetEngineTime() then
        return
    end

    local now = Game.GetEngineTime():ToFloat()
    local remaining = {}

    for _, item in ipairs(modConfig.pendingVehicleDisposals) do
        if item and item.vehicle then
            if IsVehicleHandleClearlyInvalid(item.vehicle) == true then
                DebugLog("[Transaction=" .. tostring(item.sourceKind) .. "] Old Vehicle Record purged.")
            else
                if item.remoteReleased ~= true and item.remoteOffAt and now >= item.remoteOffAt then
                    pcall(function()
                        item.vehicle:SetVehicleRemoteControlled(false, false, false)
                    end)
                    item.remoteReleased = true
                end

                if item.despawnAt and now >= item.despawnAt then
                    DespawnVehicleHandleDirect(item.vehicle)
                else
                    table.insert(remaining, item)
                end
            end
        end
    end

    modConfig.pendingVehicleDisposals = remaining
end

function ResetTransactionState()
    activeTransaction = false
    activeMode = nil
    activeShopKey = nil
    activeStartedAt = nil
    activeTransactionPayload = nil
end

function ResetVehicleContext()
    CancelPaintPreview("vehicle_context_reset", false)
    ClearPaintPreviewStartBlockedLog()
    ClearPaintPreviewUnavailableNotify()
    ClearPendingPaintPreviewUnavailable()
    HideMountedZonePrompt()
    currentVehicle = nil
    currentRecordID = nil
    currentAppearance = nil
    currentScannerName = nil
    currentDisplayName = nil
    currentVehicleKey = nil
    currentVehicleIsPlayerVehicle = false
    isPlayerMounted = false
    lastLoggedEnteredVehicleKey = nil
    ResetTransactionState()
end

function GetShopContainingPosition(pos)
    if not pos then
        return nil
    end

    for _, shop in ipairs(shops) do
        if IsShopEnabled(shop) and DistanceBetween(pos, ToVector4(shop.position)) <= shop.radius then
            return shop
        end
    end

    return nil
end

function IsPlayerInsideActiveShop()
    local shop = shopByKey[activeShopKey]
    local pos = GetPlayerPosition()

    if not shop or not pos then
        return false
    end

    return DistanceBetween(pos, ToVector4(shop.position)) <= shop.radius
end

local function BuildCurrentTransactionPayload()
    return {
        vehicle = currentVehicle,
        vehicleKey = currentVehicleKey,
        recordID = currentRecordID,
        appearance = currentAppearance,
        scannerName = currentScannerName,
        displayName = currentDisplayName,
        isPlayerVehicle = currentVehicleIsPlayerVehicle,
    }
end

local function ApplyTransactionVehiclePayload(payload)
    if type(payload) ~= "table" then
        return false
    end

    currentVehicle = payload.vehicle
    currentVehicleKey = payload.vehicleKey
    currentRecordID = payload.recordID
    currentAppearance = payload.appearance
    currentScannerName = payload.scannerName
    currentDisplayName = payload.displayName
    currentVehicleIsPlayerVehicle = payload.isPlayerVehicle == true

    return currentVehicle ~= nil and currentVehicleKey ~= nil and currentRecordID ~= nil
end

local function RestorePaintTransactionVehicleAppearance(payload)
    if type(payload) ~= "table" then
        return false
    end

    local vehicle = payload.vehicle
    local originalAppearance = payload.originalAppearance

    if not vehicle or IsUsefulAppearanceName(originalAppearance) ~= true then
        return false
    end

    if IsVehicleHandleClearlyInvalid(vehicle) == true then
        return false
    end

    return ApplyVehicleAppearance(vehicle, originalAppearance) == true
end

local function CancelActiveTransaction(reason)
    if activeMode == "paint" and type(activeTransactionPayload) == "table" then
        RestorePaintTransactionVehicleAppearance(activeTransactionPayload)
    end

    DebugLog("CancelActiveTransaction: reason=" .. tostring(reason) .. " mode=" .. tostring(activeMode))
    ResetTransactionState()
end

function StartTransaction(mode, shopKey, payload)
    if mode == "paint" and type(payload) == "table" then
        payload.paintCommitted = false
        payload.committedGarageID = nil
        payload.paintCommitSkipLogged = false
    end

    activeTransaction = true
    activeMode = mode
    activeShopKey = shopKey
    activeStartedAt = nil
    activeTransactionPayload = payload
end

function TryUnlockVehicleAtShop()
    if not currentRecordID or not currentVehicle or not Game.GetVehicleSystem() then
        ResetTransactionState()
        return
    end

    local unlockFee, repairCost, totalFee = CalculateUnlockTransactionCosts(currentVehicle, currentRecordID)
    local claimTarget = ResolveClaimGarageTarget(currentRecordID, currentAppearance)
    local garageID = claimTarget.garageID
    local vehicleKey = currentVehicleKey or GetVehicleWorldKey(currentVehicle)
    local vehicleToLock = currentVehicle
    local sourceVehicle = currentVehicle

    LogClaimResult(claimTarget)

    if modConfig.debugEnabled then
        local routedTo
        if claimTarget.mode == "cosv" and claimTarget.route then
            routedTo = claimTarget.route.family .. " [cosv]"
        elseif claimTarget.mode == "fallback_after_cosv_miss" then
            routedTo = (claimTarget.route and claimTarget.route.family or "?") .. " [fallback/slot miss]"
        elseif claimTarget.mode == "fallback" then
            routedTo = "fallback"
        else
            routedTo = tostring(claimTarget.mode) .. "/" .. tostring(claimTarget.status)
        end
        DebugLog("Boarded Vehicle: " .. tostring(currentRecordID) ..
            "  Appearance: " .. tostring(currentAppearance) ..
            "  Routed To: " .. routedTo)
        DebugLog("Scanner: " .. tostring(currentScannerName or "n/a") .. "  Normalized Scanner: " .. tostring(currentDisplayName or "n/a"))
    end

    if GetPlayerMoney() < totalFee then
        AppendSessionLogLine("shop mode=unlock shop=" .. tostring(GetSessionLogShopName(activeShopKey)) .. " result=blocked reason=not_enough_money")
        Notify(Msg("notify.unlock.not_enough_eddies"), 5, gameSimpleMessageType.Undefined, true)
        ResetTransactionState()
        return
    end

    if claimTarget.ok ~= true or not garageID then
        local failureReason = "claim_failed"
        if claimTarget.status == "cosv_disabled_slots_missing" then
            failureReason = "backend_failed"
        elseif claimTarget.mode == "fallback_after_cosv_miss" then
            failureReason = "slot_not_found"
        elseif claimTarget.mode == "ignore" then
            failureReason = "already_managed"
        end
        AppendSessionLogLine("shop mode=unlock shop=" .. tostring(GetSessionLogShopName(activeShopKey)) .. " result=blocked reason=" .. failureReason)

        if claimTarget.mode == "ignore" then
            Notify(Msg("notify.unlock.already_managed"), 5, gameSimpleMessageType.Undefined, true)
        else
            Notify(Msg("notify.unlock.cannot_register"), 5, gameSimpleMessageType.Undefined, true)
        end

        ResetTransactionState()
        return
    end

    local wasUnlocked = IsGarageVehicleUnlocked(garageID)
    local hasTargetRecord = HasTweakDBRecord(garageID)
    local inVehicleListBefore = IsVehicleInVehicleList(garageID)
    local inVehicleListAfter = inVehicleListBefore
    local ensureCalled = false
    local ensureResult = false
    local enableCallOk = false
    local enableCallResult = nil
    local cosvActivation = nil
    local activationFamily = claimTarget.selectedFamily or (claimTarget.route and claimTarget.route.family or nil)

    if claimTarget.mode == "cosv" and activationFamily then
        cosvActivation = ClaimCOSVSlot(activationFamily, currentAppearance, {
            source = "claim",
            preResolvedControlled = claimTarget.controlled,
        })

        if cosvActivation and cosvActivation.garageID then
            garageID = cosvActivation.garageID
        end

        if cosvActivation then
            hasTargetRecord = cosvActivation.hasTargetRecord == true
            inVehicleListBefore = cosvActivation.inVehicleListBefore == true
            ensureCalled = cosvActivation.ensureCalled == true
            ensureResult = cosvActivation.ensureResult == true
            inVehicleListAfter = cosvActivation.inVehicleListAfter == true
            enableCallOk = cosvActivation.enableOk == true
            enableCallResult = cosvActivation.enableResult
            wasUnlocked = cosvActivation.wasUnlocked == true
        end
    else
        ensureCalled = true
        ensureResult = EnsureVehicleInVehicleList(garageID)
        inVehicleListAfter = IsVehicleInVehicleList(garageID)

        enableCallOk, enableCallResult = pcall(function()
            return Game.GetVehicleSystem():EnablePlayerVehicle(garageID, true, false)
        end)
    end

    local isUnlocked = IsGarageVehicleUnlocked(garageID)
    local unlockedListHasTarget, unlockedListStatus = GetUnlockedVehicleListDiagnosticStatus(garageID)

    DebugLog("unlock_diag target=" .. tostring(garageID) ..
        " hasRecord=" .. tostring(hasTargetRecord) ..
        " inListBefore=" .. tostring(inVehicleListBefore) ..
        " ensureCalled=" .. tostring(ensureCalled) ..
        " ensureResult=" .. tostring(ensureResult) ..
        " inListAfter=" .. tostring(inVehicleListAfter) ..
        " enableOk=" .. tostring(enableCallOk) ..
        " enableResult=" .. tostring(enableCallResult) ..
        " wasUnlocked=" .. tostring(wasUnlocked) ..
        " isUnlocked=" .. tostring(isUnlocked) ..
        " unlockedListHasTarget=" .. tostring(unlockedListHasTarget) ..
        " unlockedListStatus=" .. tostring(unlockedListStatus))

    if wasUnlocked == false and isUnlocked == true then
        ChangePlayerMoney(-totalFee)
        factCheckAndRefresh()
        if IsDeclaredCOSVSlotVehicleID(garageID) == true then
            CaptureLastTransactionCOSVBackup("unlock")
        end
        handledVehicleKeys[vehicleKey] = true
        local disposeOk, disposeStatus = DisposeVehicle(sourceVehicle, "unlock")
        DebugLog("unlock_dispose ok=" .. tostring(disposeOk) .. " status=" .. tostring(disposeStatus))

        if repairCost > 0 then
            Notify(Fmt("notify.unlock.success_fee_with_repair", { fee = unlockFee, repair = repairCost, total = totalFee }), 8, gameSimpleMessageType.Money, true)
        else
            Notify(Fmt("notify.unlock.success_fee", { fee = unlockFee }), 8, gameSimpleMessageType.Money, true)
        end
        if type(claimTarget.loreMessage) == "string" and claimTarget.loreMessage ~= ""
            and type(claimTarget.recoveryKind) == "string" and claimTarget.recoveryKind ~= ""
        then
            Notify(claimTarget.loreMessage, 8, gameSimpleMessageType.Undefined, true)
        end
        if claimTarget.mode == "fallback" or claimTarget.mode == "fallback_after_cosv_miss" then
            Notify(Msg("notify.unlock.lemon_warning"), 8, gameSimpleMessageType.Undefined, true)
        end
        if StartShopCooldown(shopByKey[activeShopKey]) then
            ClearMapPins()
        end
        AppendSessionLogLine("shop mode=unlock shop=" .. tostring(GetSessionLogShopName(activeShopKey)) .. " result=ok garage=" .. tostring(garageID) .. " fee=" .. tostring(totalFee))
    else
        DebugLog("unlock_fail target=" .. tostring(garageID) ..
            " failure=protected_firmware" ..
            " hasRecord=" .. tostring(hasTargetRecord) ..
            " inListBefore=" .. tostring(inVehicleListBefore) ..
            " ensureResult=" .. tostring(ensureResult) ..
            " inListAfter=" .. tostring(inVehicleListAfter) ..
            " enableOk=" .. tostring(enableCallOk) ..
            " enableResult=" .. tostring(enableCallResult) ..
            " wasUnlocked=" .. tostring(wasUnlocked) ..
            " isUnlocked=" .. tostring(isUnlocked) ..
            " unlockedListHasTarget=" .. tostring(unlockedListHasTarget) ..
            " unlockedListStatus=" .. tostring(unlockedListStatus))
        AppendSessionLogLine("shop mode=unlock shop=" .. tostring(GetSessionLogShopName(activeShopKey)) .. " result=blocked reason=protected_firmware garage=" .. tostring(garageID))
        Notify(Msg("notify.unlock.protected_firmware"), 8, gameSimpleMessageType.Undefined, true)
    end

    ResetTransactionState()
end

-- Frozen sale operation: caller provides the shop; this sells the current vehicle or returns a clean failure.
function SellCurrentVehicleToShop(shop)
    local result = {
        ok = false,
        reason = nil,
        shopKey = shop and shop.key or nil,
        shopMode = shop and shop.mode or nil,
        recordID = currentRecordID,
        garageID = nil,
        salePrice = nil,
        basePrice = nil,
        wasOwned = false,
        removedFromGarage = false,
        rewardsGranted = nil,
        factsUpdated = false,
        factUpdateCount = nil,
        cooldownStarted = false,
        removeFromGarage = false,
        saleContext = nil,
        disableGarageOk = false,
        disableGarageResult = nil,
        garageRefreshOk = false,
        garageRefreshStatus = nil,
        autofixerReset = false,
    }

    if not currentRecordID or not currentVehicle then
        result.reason = "missing_vehicle_context"
        AppendSessionLogLine("shop mode=" .. tostring(activeMode or "sell") .. " shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=missing_vehicle_context")
        ResetTransactionState()
        return result
    end

    if not shop then
        result.reason = "missing_shop"
        AppendSessionLogLine("shop mode=" .. tostring(activeMode or "sell") .. " shop=" .. tostring(GetSessionLogShopName(nil)) .. " result=blocked reason=missing_shop")
        ResetTransactionState()
        return result
    end

    local saleContext = ResolveVehicleSaleContext(currentRecordID, currentAppearance, currentVehicle)
    local garageID = saleContext.garageID
    local vehicleKey = currentVehicleKey or GetVehicleWorldKey(currentVehicle)
    local removeFromGarage = activeMode == "sell_owned"

    result.shopKey = shop.key
    result.shopMode = shop.mode
    result.saleContext = saleContext
    result.garageID = garageID
    result.wasOwned = saleContext.isOwnedGarageVehicle == true
    result.removedFromGarage = removeFromGarage
    result.removeFromGarage = removeFromGarage

    if soldVehicleKeys[vehicleKey] == true then
        result.reason = "already_sold"
        AppendSessionLogLine("shop mode=" .. tostring(activeMode or "sell") .. " shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=already_sold")
        Notify(Msg("notify.sale.already_sold"), 8, gameSimpleMessageType.Undefined, true)
        ResetTransactionState()
        return result
    end

    if ShopAcceptsVehicle(shop, currentRecordID, garageID, currentAppearance) ~= true then
        result.reason = "vehicle_not_accepted"
        AppendSessionLogLine("shop mode=" .. tostring(activeMode or "sell") .. " shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=vehicle_not_accepted")
        Notify(tostring(shop.rejectedVehicleMessage or messageConfig.bikeOnlyShopRejectMessage), 5, gameSimpleMessageType.Undefined, true)
        ResetTransactionState()
        return result
    end

    local payload = type(activeTransactionPayload) == "table" and activeTransactionPayload or nil
    local now = Game.GetEngineTime() and Game.GetEngineTime():ToFloat() or nil

    if removeFromGarage == true then
        local disableConfirmed, disableState, disableReason = ProcessDisableValidation(payload, "sell", garageID, now)

        if disableReason == "disable_pending" then
            result.reason = "disable_pending"
            return result
        end

        if disableConfirmed ~= true then
            result.reason = "disable_failed"
            result.disableGarageOk = disableState and disableState.lastDisableOk == true
            result.disableGarageResult = disableState and disableState.lastDisableResult or nil
            return result
        end

        result.garageRefreshOk, result.garageRefreshStatus = RefreshSoldGarageVehicleRegistration(garageID)
        result.autofixerReset = TryResetAutofixerState(garageID) == true
    end

    soldVehicleKeys[vehicleKey] = true
    handledVehicleKeys[vehicleKey] = true

    local payout, flavorMessage, saleBasePrice = GetVehicleSalePrice(currentRecordID, removeFromGarage == true, currentVehicle)
    local smugglerPremiumApplied = false
    local xpRewardOverride = nil
    local streetCredRewardOverride = nil

    result.basePrice = getBasePrice(currentRecordID, currentVehicle)

    if IsDropoffShop(shop) then
        payout, flavorMessage, saleBasePrice = GetDropoffVehicleSalePrice(shop, currentRecordID, currentVehicle)
    end

    if saleBasePrice ~= nil then
        result.basePrice = saleBasePrice
    end

    if shop.fixedSalePrice then
        payout = shop.fixedSalePrice
        flavorMessage = nil
        xpRewardOverride = shop.fixedSaleXPReward
        streetCredRewardOverride = shop.fixedSaleStreetCredReward
    end

    if IsSmugglerShop(shop) and removeFromGarage == true and IsDropoffShop(shop) ~= true then
        payout = math.floor(payout * 1.10)
        smugglerPremiumApplied = true
    end

    if smugglerPremiumApplied then
        if flavorMessage and flavorMessage ~= "" then
            flavorMessage = flavorMessage .. "\n" .. Msg("notify.sale.smuggler_premium")
        else
            flavorMessage = Msg("notify.sale.smuggler_premium")
        end
    end

    ChangePlayerMoney(payout)
    AddSaleProgressRewards(payout, xpRewardOverride, streetCredRewardOverride)
    result.rewardsGranted = modConfig.isXPReward == true
    result.factsUpdated = factCheckAndRefresh() == true

    local message = Fmt("notify.sale.receipt", { payout = payout })

    if flavorMessage and flavorMessage ~= "" then
        message = message .. "\n" .. flavorMessage
    end

    Notify(message, salePricing.saleReceiptDuration, gameSimpleMessageType.Money, true)

    result.cooldownStarted = StartShopCooldown(shop) == true
    if result.cooldownStarted then
        ClearMapPins()
    end

    result.disposeOk, result.disposeStatus = DisposeVehicle(currentVehicle, "sell")
    result.salePrice = payout
    result.ok = true
    AppendSessionLogLine(
        "Sell Shop: " .. tostring(GetSessionLogShopName(shop))
        .. ". Sold " .. tostring(removeFromGarage == true and "owned" or "stolen")
        .. " transport: " .. tostring(currentRecordID)
        .. " for " .. tostring(result.salePrice)
    )

    if result.removedFromGarage == true and IsDeclaredCOSVSlotVehicleID(garageID) == true then
        CaptureLastTransactionCOSVBackup("sell")
    end

    ResetVehicleContext()
    return result
end

function PaintCurrentCOSVVehicle(payload)
    local result = {
        ok = false,
        reason = nil,
        shopKey = type(payload) == "table" and payload.shopKey or nil,
        family = type(payload) == "table" and payload.family or nil,
        previousVehicleID = type(payload) == "table" and payload.previousVehicleID or nil,
        recordID = type(payload) == "table" and payload.recordID or nil,
        garageID = nil,
        selectedAppearance = type(payload) == "table" and payload.selectedAppearance or nil,
        claimResult = nil,
    }

    if type(payload) ~= "table" then
        result.reason = "invalid_context"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=invalid_context")
        return result
    end

    if payload.paintCommitted == true then
        result.reason = "already_committed"
        result.garageID = payload.committedGarageID

        if payload.paintCommitSkipLogged ~= true then
            DebugLog("paint_commit_skip garage=" .. tostring(payload.committedGarageID) .. " reason=already_committed")
            payload.paintCommitSkipLogged = true
        end

        return result
    end

    if IsUsefulAppearanceName(payload.selectedAppearance) ~= true then
        result.reason = "invalid_input"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=invalid_input")
        return result
    end

    if type(payload.family) ~= "string" or payload.family == "" then
        result.reason = "invalid_context"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=invalid_context")
        return result
    end

    if type(payload.previousVehicleID) ~= "string" or payload.previousVehicleID == "" then
        result.reason = "invalid_context"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=invalid_context")
        return result
    end

    if GetPlayerMoney() < modConfig.paintServiceCost then
        result.reason = "insufficient_funds"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=not_enough_money")
        return result
    end

    local normalizedSelectedAppearance = NormalizeAppearanceName(payload.selectedAppearance)
    local normalizedOriginalAppearance = NormalizeAppearanceName(payload.originalAppearance)

    if not normalizedSelectedAppearance or normalizedSelectedAppearance == normalizedOriginalAppearance then
        result.reason = "invalid_input"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=invalid_input")
        return result
    end

    local now = Game.GetEngineTime() and Game.GetEngineTime():ToFloat() or nil
    local disableConfirmed, _, disableReason = ProcessDisableValidation(payload, "paint", payload.previousVehicleID, now)

    if disableReason == "disable_pending" then
        result.reason = "disable_pending"
        return result
    end

    if disableConfirmed ~= true then
        result.reason = "disable_failed"
        return result
    end

    local claimResult = ClaimCOSVSlot(payload.family, payload.selectedAppearance, {
        source = "paint",
        previousVehicleID = payload.previousVehicleID,
        previousVehicleAlreadyDisabled = true,
        transactionPayload = payload,
    })

    result.claimResult = claimResult
    result.garageID = claimResult and claimResult.garageID or nil

    if claimResult and claimResult.ok == true then
        ChangePlayerMoney(-modConfig.paintServiceCost)
        result.ok = true
        AppendSessionLogLine(
            "shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey))
            .. " result=ok"
            .. " garage=" .. tostring(result.garageID)
            .. " appearance=" .. tostring(result.selectedAppearance)
        )
        if IsDeclaredCOSVSlotVehicleID(result.garageID) == true or IsDeclaredCOSVSlotVehicleID(payload.previousVehicleID) == true then
            CaptureLastTransactionCOSVBackup("paint")
        end
    else
        result.reason = claimResult and claimResult.reason or "enable_failed"
        AppendSessionLogLine("shop mode=paint shop=" .. tostring(GetSessionLogShopName(result.shopKey)) .. " result=blocked reason=" .. tostring(result.reason))
    end

    return result
end

function ClearMapPins()
    local mappinSystem = Game.GetMappinSystem()

    if #mapPins > 0 then
        for _, mapPin in ipairs(mapPins) do
            if mapPin and mappinSystem then
                pcall(function()
                    mappinSystem:UnregisterMappin(mapPin)
                end)
            end
        end
    end

    mapPins = {}
    shopPinsByHandle = {}
    selectedMapPin = nil
    selectedMapPinPosition = nil
    mapPinsSpawned = false
end

local function FindShopByRegisteredMapPin(targetMapPin)
    if not targetMapPin then
        return nil
    end

    for _, entry in ipairs(shopPinsByHandle) do
        if entry.mapPin == targetMapPin then
            return entry.shop
        end
    end

    return nil
end

local function ResetRuntimeSessionState(reason)
    DebugLog("ResetRuntimeSessionState: reason=" .. tostring(reason))

    if reason == "session_start" then
        ResetSessionLog(reason)
    end

    ClearMapPins()
    ResetVehicleContext()
    modConfig.pendingVehicleDisposals = {}
    pendingAppearanceRefreshes = {}
    soldVehicleKeys = {}
    handledVehicleKeys = {}
    selectedMapPin = nil
    selectedMapPinPosition = nil
    mapPinsSpawned = false
    pendingPostLoadVehicleRefresh = true
    postLoadVehicleRefreshDone = false
    wasPlayerReadyLastUpdate = false
    shopPinBootstrapEndsAt = nil
    shopPinBootstrapActive = true
    nextSlowUpdateAt = nil
    nextMapPinUpdateAt = nil
    nextProximityUpdateAt = nil
    nextCleanupUpdateAt = nil
    alterationWarningShopKey = nil
    pendingConfigurationAlert = nil
    configurationAlertEndsAt = nil
end

function IsShopPinBootstrapActive(now)
    if shopPinBootstrapActive ~= true then
        return false
    end

    if not now then
        return true
    end

    if shopPinBootstrapEndsAt and now >= shopPinBootstrapEndsAt then
        shopPinBootstrapActive = false
        return false
    end

    return true
end

function CurrentVehicleMatchesBikePinTokens(recordID, garageID, appearance)
    local recordText = string.lower(tostring(recordID or ""))
    local garageText = string.lower(tostring(garageID or ""))
    local appearanceText = string.lower(tostring(appearance or ""))
    local bikeTokens = {
        "brennan_apollo",
        "sportbike2_arch",
        "arch_nemesis",
        "yaiba_kusanagi",
    }

    for _, token in ipairs(bikeTokens) do
        local tokenText = string.lower(tostring(token or ""))

        if tokenText ~= "" and (
            (recordText ~= "" and string.find(recordText, tokenText, 1, true) ~= nil)
            or (garageText ~= "" and string.find(garageText, tokenText, 1, true) ~= nil)
            or (appearanceText ~= "" and string.find(appearanceText, tokenText, 1, true) ~= nil)
        ) then
            return true
        end
    end

    return false
end

function IsMountedVehicleExactGarageRecordUnlocked(recordID)
    if not recordID or recordID == "" then
        return false
    end

    return IsGarageVehicleUnlocked(recordID)
end

function ShouldShowShopMapPin(shop, recordID, garageID, appearance, isPhysicalPlayerVehicle)
    if not shop or not shop.key then
        return false
    end

    if shop.key == "badlandsJunkShop" then
        return true
    end

    if shop.key == "southernBadlandsChopShop" or shop.key == "biotechnicaFlatsChopShop" then
        return IsShopOnCooldown(shop) ~= true
    end

    if IsSmugglerShop(shop) then
        if IsShopOnCooldown(shop) then
            return false
        end

        return currentVehicle ~= nil and isPlayerMounted == true and isPhysicalPlayerVehicle == true
    end

    if shop.key == "watsonBikeBuyer" then
        if IsShopOnCooldown(shop) then
            return false
        end

        if not currentVehicle or isPlayerMounted ~= true then
            return true
        end

        return CurrentVehicleMatchesBikePinTokens(recordID, garageID, appearance)
    end

    if shop.mode == "unlock" then
        -- cooldown always wins
        if IsShopOnCooldown(shop) then
            return false
        end
        -- not mounted: show as "shop is open" indicator
        if not currentVehicle or isPlayerMounted ~= true then
            return true
        end
        -- mounted: hide if this vehicle is already claimed/owned here
        if IsMountedVehicleExactGarageRecordUnlocked(recordID) then
            return false
        end

        return true
    end

    if shop.mode == "sell" then
        return IsShopOnCooldown(shop) ~= true
    end

    if shop.mode == "paint" then
        if IsShopOnCooldown(shop) then
            return false
        end

        if not currentVehicle or isPlayerMounted ~= true then
            return false
        end

        return ResolveDeclaredCOSVSlotMatch(recordID, garageID) ~= nil
    end

    return true
end

function SpawnShopMapPinsForCurrentVehicle(now)
    if mapPinsSpawned or not Game.GetMappinSystem() then
        return
    end

    local bootstrapActive = IsShopPinBootstrapActive(now)
    local recordID = currentRecordID
    local appearance = currentAppearance
    local garageID = nil
    local isPhysicalPlayerVehicle = currentVehicleIsPlayerVehicle
    local registeredAnyPin = false

    if currentVehicle then
        local saleContext = ResolveVehicleSaleContext(currentRecordID, currentAppearance, currentVehicle)
        garageID = saleContext.garageID
        isPhysicalPlayerVehicle = currentVehicleIsPlayerVehicle
    end


    for _, shop in ipairs(shops) do
        if IsShopEnabled(shop) then
            local isShopOnCooldown = IsShopOnCooldown(shop)
            local shouldShow = bootstrapActive

            if bootstrapActive == true and shop.mode == "paint" then
                shouldShow = ShouldShowShopMapPin(
                    shop,
                    recordID,
                    garageID,
                    appearance,
                    isPhysicalPlayerVehicle)
            elseif bootstrapActive ~= true then
                shouldShow = ShouldShowShopMapPin(
                    shop,
                    recordID,
                    garageID,
                    appearance,
                    isPhysicalPlayerVehicle)
            end

            if shouldShow then
                local pos = ToVector4(shop.position)
                local data = BuildCOSVShopMappinData(shop)
                local mapPin = nil

                if data ~= nil then
                    mapPin = Game.GetMappinSystem():RegisterMappin(data, Vector4.new(pos.x, pos.y, pos.z + 1))
                end

                if mapPin then
                    table.insert(mapPins, mapPin)
                    table.insert(shopPinsByHandle, {
                        mapPin = mapPin,
                        shop = shop
                    })
                    registeredAnyPin = true
                end
            end
        end
    end

    mapPinsSpawned = registeredAnyPin
end

function UpdateMountedZonePrompt()
    if activeTransaction or isPlayerMounted ~= true or not currentVehicle then
        HideMountedZonePrompt()
        return
    end

    local shop = proximityState.currentShop

    if not shop or IsShopOnCooldown(shop) then
        HideMountedZonePrompt()
        return
    end

    local promptMessage = messageConfig.mountedZoneTransactionPrompt
    local promptType = gameSimpleMessageType.Relic

    if shop.mode == "paint" then
        local context = ResolveCurrentCOSVPaintContext(currentVehicle, currentRecordID, currentAppearance)

        if context.ok ~= true then
            HideMountedZonePrompt()
            return
        end

        promptMessage = messageConfig.mountedPaintPreviewPrompt
    elseif shop.mode == "sell" and IsSmugglerShop(shop) and currentVehicleIsPlayerVehicle ~= true then
        promptMessage = messageConfig.smugglerPaperworkPrompt
    elseif shop.mode == "unlock" then
        local saleContext = ResolveVehicleSaleContext(currentRecordID, currentAppearance, currentVehicle)

        if saleContext.isPhysicalPlayerVehicle == true or saleContext.isGarageUnlocked == true then
            HideMountedZonePrompt()
            return
        end

    end

    ShowMountedZonePrompt(promptMessage, promptType)
end

function SetupTransactionAfterUnmount(vehicle)
    local playerPosition = GetPlayerPosition()
    local shop = GetShopContainingPosition(playerPosition)

    if shop and shop.mode == "paint" then
        local recordID = GetVehicleRecordText(vehicle)
        local isPotentialCandidate = IsPotentialCOSVPaintVehicle(vehicle, recordID)

        if isPotentialCandidate ~= true then
            ResetVehicleContext()
            Notify(messageConfig.paintUnsupportedVehicleMessage, 5, gameSimpleMessageType.Undefined, true)
            return
        end
    end

    CaptureVehicle(vehicle)

    if not currentVehicle or not currentRecordID or not currentVehicleKey or not IsPlayerReady() then
        return
    end

    local player = Game.GetPlayer()
    if not player then return end
    local okCombat, inCombat = pcall(function() return player.inCombat end)
    if okCombat and inCombat then return end

    if not shop then
        return
    end

    local paintContext = nil

    if shop.mode == "paint" then
        paintContext = ResolveCurrentCOSVPaintContext(currentVehicle, currentRecordID, currentAppearance)

        if paintContext.ok ~= true then
            Notify(messageConfig.paintUnsupportedVehicleMessage, 5, gameSimpleMessageType.Undefined, true)
            return
        end
    end

    local saleContext = ResolveVehicleSaleContext(currentRecordID, currentAppearance, currentVehicle)

    if soldVehicleKeys[currentVehicleKey] == true then
        return
    end

    if handledVehicleKeys[currentVehicleKey] == true and saleContext.isOwnedGarageVehicle ~= true then
        return
    end

    if IsShopOnCooldown(shop) then
        Notify(Fmt("notify.shop.closed", { shop = shop.name }), 5, gameSimpleMessageType.Undefined, true)
        return
    end

    if shop.mode == "paint" then
        local oldWorldVehicle = currentVehicle

        if paintPreviewState.active ~= true or paintPreviewState.shopKey ~= shop.key then
            local candidateResult = BuildPaintPreviewCandidates(paintContext)

            if candidateResult.ok ~= true then
                NotifyPaintPreviewUnavailableOnce(shop.key, paintContext, candidateResult.reason)
            end

            return
        end

        local previewSnapshot = SnapshotPaintPreviewState()
        local selectedAppearance = previewSnapshot and previewSnapshot.selectedAppearance or nil
        local originalAppearance = previewSnapshot and previewSnapshot.originalAppearance or nil

        if IsUsefulAppearanceName(selectedAppearance) ~= true then
            return
        end

        if NormalizeAppearanceName(selectedAppearance) == NormalizeAppearanceName(originalAppearance) then
            return
        end

        if GetPlayerMoney() < modConfig.paintServiceCost then
            Notify(messageConfig.paintInsufficientFundsMessage, 5, gameSimpleMessageType.Undefined, true)
            return
        end

        StartTransaction("paint", shop.key, {
            vehicle = oldWorldVehicle,
            vehicleKey = currentVehicleKey,
            recordID = currentRecordID,
            appearance = currentAppearance,
            scannerName = currentScannerName,
            displayName = currentDisplayName,
            isPlayerVehicle = currentVehicleIsPlayerVehicle,
            family = previewSnapshot and (previewSnapshot.selectedFamily or previewSnapshot.family) or nil,
            previousVehicleID = previewSnapshot and previewSnapshot.vehicleID or nil,
            selectedAppearance = selectedAppearance,
            originalAppearance = originalAppearance,
            shopKey = shop.key,
        })
        ClearPaintPreviewState()

        return
    end

    if shop.mode == "sell" then
        if saleContext.isSaleExcluded == true then
            return
        end

        if IsSmugglerShop(shop) then
            if saleContext.isOwnedGarageVehicle ~= true then
                Notify(messageConfig.smugglerPaperworkPrompt, 5, gameSimpleMessageType.Undefined, true)
                return
            end

            StartTransaction("sell_owned", shop.key, BuildCurrentTransactionPayload())
            return
        end

        if saleContext.isOwnedSellCandidate == true then
            StartTransaction("sell_owned", shop.key, BuildCurrentTransactionPayload())
        else
            StartTransaction("sell", shop.key, BuildCurrentTransactionPayload())
        end
    elseif shop.mode == "unlock" and saleContext.isPhysicalPlayerVehicle == false and saleContext.isGarageUnlocked == false then
        StartTransaction("unlock", shop.key, BuildCurrentTransactionPayload())
    end
end

function ProcessActiveTransaction()
    if not activeTransaction then
        return
    end

    if isPlayerMounted == true then
        CancelActiveTransaction("player_remounted_before_execution")
        return
    end

    if not activeStartedAt then
        Notify(messageConfig.transactionPrompt, 5, gameSimpleMessageType.Relic, true)
        activeStartedAt = Game.GetEngineTime():ToFloat()
    end

    if IsPlayerInsideActiveShop() then
        return
    end

    local payload = activeTransactionPayload
    if (activeMode == "sell" or activeMode == "sell_owned" or activeMode == "unlock") and ApplyTransactionVehiclePayload(payload) ~= true then
        ResetTransactionState()
        return
    end

    if activeMode == "sell" or activeMode == "sell_owned" then
        local shop = shopByKey[activeShopKey]
        local saleResult = SellCurrentVehicleToShop(shop)

        if saleResult and saleResult.reason == "disable_pending" then
            return
        end

        if saleResult and saleResult.reason == "disable_failed" then
            Notify(messageConfig.vehicleSystemErrorMessage, 6, gameSimpleMessageType.Negative, true)
            ResetTransactionState()
            return
        end
    elseif activeMode == "unlock" then
        TryUnlockVehicleAtShop()
    elseif activeMode == "paint" then
        local shop = shopByKey[activeShopKey]
        local paintResult = PaintCurrentCOSVVehicle(payload)

        if paintResult.ok == true then
            local disposeOk, disposeStatus = DisposeVehicle(payload and payload.vehicle or nil, "paint_replace")
            DebugLog("paint_dispose ok=" .. tostring(disposeOk) .. " status=" .. tostring(disposeStatus))

            Notify(Fmt("notify.paint.applied", { appearance = paintResult.selectedAppearance }), 8, gameSimpleMessageType.Undefined, true)
            Notify(messageConfig.paintPreviewFarewellMessage, 8, gameSimpleMessageType.Money, true)

            if shop and StartShopCooldown(shop) == true then
                ClearMapPins()
            end

            ResetVehicleContext()
        elseif paintResult.reason == "not_cosv_slot" then
            RestorePaintTransactionVehicleAppearance(payload)
            Notify(messageConfig.paintUnsupportedVehicleMessage, 8, gameSimpleMessageType.Undefined, true)
            ResetVehicleContext()
        elseif paintResult.reason == "insufficient_funds" then
            RestorePaintTransactionVehicleAppearance(payload)
            Notify(messageConfig.paintInsufficientFundsMessage, 8, gameSimpleMessageType.Undefined, true)
            ResetVehicleContext()
        elseif paintResult.reason == "disable_pending" then
            return
        elseif paintResult.reason == "disable_failed" then
            RestorePaintTransactionVehicleAppearance(payload)
            Notify(messageConfig.vehicleSystemErrorMessage, 8, gameSimpleMessageType.Negative, true)
            ResetVehicleContext()
        elseif paintResult.reason == "already_committed" then
            ResetVehicleContext()
        else
            RestorePaintTransactionVehicleAppearance(payload)
            Notify(messageConfig.paintClaimFailureMessage, 8, gameSimpleMessageType.Undefined, true)
            ResetVehicleContext()
        end
    else
        ResetTransactionState()
    end
end

function GetQuestFactValue(qs, factName)
    local ok, value = pcall(function()
        return qs:GetFactStr(factName)
    end)

    if ok and value ~= nil then
        return tonumber(value)
    end

    ok, value = pcall(function()
        return qs:GetFactStr(CName.new(factName))
    end)

    if ok and value ~= nil then
        return tonumber(value)
    end

    ok, value = pcall(function()
        return qs:GetFact(factName)
    end)

    if ok and value ~= nil then
        return tonumber(value)
    end

    ok, value = pcall(function()
        return qs:GetFact(CName.new(factName))
    end)

    if ok and value ~= nil then
        return tonumber(value)
    end

    return nil
end

function IsAutofixerVehicleEnabled(vs, vehicleID)
    local ok, result = pcall(function()
        return vs:IsVehiclePlayerUnlocked(TweakDBID.new(vehicleID))
    end)

    return ok and result == true
end

function EnableAutofixerVehicle(vs, vehicleID)
    pcall(function()
        vs:EnablePlayerVehicle(vehicleID, true, false)
    end)

    if IsAutofixerVehicleEnabled(vs, vehicleID) then
        return true
    end

    pcall(function()
        vs:EnablePlayerVehicle(TweakDBID.new(vehicleID), true, false)
    end)

    return IsAutofixerVehicleEnabled(vs, vehicleID)
end

function TrySetQuestFactValue(qs, factName, value)
    if not qs or not factName or factName == "" then
        return false
    end

    local ok = pcall(function()
        qs:SetFactStr(factName, value)
    end)

    if ok then
        return true
    end

    ok = pcall(function()
        qs:SetFactStr(CName.new(factName), value)
    end)

    if ok then
        return true
    end

    ok = pcall(function()
        qs:SetFact(factName, value)
    end)

    if ok then
        return true
    end

    ok = pcall(function()
        qs:SetFact(CName.new(factName), value)
    end)

    return ok == true
end

function FindAutofixerVehicleEntry(vehicleID)
    local idText = tostring(vehicleID or ""):lower()

    for _, entry in ipairs(autofixerVehicleOwnership or {}) do
        local entryID = tostring(entry.vehicleID or ""):lower()

        if entryID ~= "" and string.find(idText, entryID, 1, true) then
            return entry
        end
    end

    return nil
end

function TryResetAutofixerState(vehicleID)
    local entry = FindAutofixerVehicleEntry(vehicleID)

    if not entry or not entry.ownedFact then
        return false
    end

    local qs = Game.GetQuestsSystem()

    if not qs then
        print("[" .. MOD_NAME .. "] AutoFixer owned fact reset skipped: QuestSystem unavailable")
        return false
    end

    local ok = TrySetQuestFactValue(qs, entry.ownedFact, 0)

    if ok then
        print("[" .. MOD_NAME .. "] AutoFixer owned fact reset: " .. tostring(entry.ownedFact))
    else
        print("[" .. MOD_NAME .. "] AutoFixer owned fact reset failed: " .. tostring(entry.ownedFact))
    end

    return ok
end

function factCheckAndRefresh()
    local qs = Game.GetQuestsSystem()
    local vs = Game.GetVehicleSystem()

    if not qs or not vs then
        print("[" .. MOD_NAME .. "] factCheckAndRefresh skipped: system unavailable")
        return false
    end

    local checked = 0
    local activeFacts = 0
    local enabled = 0

    for _, entry in ipairs(autofixerVehicleOwnership or {}) do
        if entry and entry.vehicleID and entry.ownedFact then
            checked = checked + 1

            local value = GetQuestFactValue(qs, entry.ownedFact)

            if value and value ~= 0 then
                activeFacts = activeFacts + 1

                local ok = pcall(function()
                    vs:EnablePlayerVehicle(entry.vehicleID, true, false)
                end)

                if ok then
                    enabled = enabled + 1
                    print("[" .. MOD_NAME .. "] factCheckAndRefresh enabled " .. tostring(entry.vehicleID) .. " from " .. tostring(entry.ownedFact) .. "=" .. tostring(value))
                else
                    print("[" .. MOD_NAME .. "] factCheckAndRefresh failed to enable " .. tostring(entry.vehicleID) .. " from " .. tostring(entry.ownedFact) .. "=" .. tostring(value))
                end
            end
        end
    end

    print("[" .. MOD_NAME .. "] factCheckAndRefresh checked " .. tostring(checked) .. " facts, active " .. tostring(activeFacts) .. ", enable calls " .. tostring(enabled))
    return enabled > 0
end

function RefreshAutofixerOwnedVehiclesFromFacts()
    return factCheckAndRefresh()
end


function ClaimOrSellVehicles_factCheckAndRefresh()
    factCheckAndRefresh()
end

registerHotkey("cosv_paint_next", Msg("hotkey.paint_next"), function()
    SafeCall("cosv_paint_next", function()
        StepPaintPreview(1)
    end)
end)

registerHotkey("cosv_paint_prev", Msg("hotkey.paint_prev"), function()
    SafeCall("cosv_paint_prev", function()
        StepPaintPreview(-1)
    end)
end)

registerForEvent("onTweak", function()
    RestoreClaimedAppearanceRecords()
    LoadSettings()
    PrimeVehicleListWithRawRecords()
end)

registerForEvent("onInit", function()
    print("[" .. MOD_NAME .. "] " .. MOD_VERSION .. " loaded")
    DetectZeroEngine()

    LoadSettings()
    pendingPostLoadVehicleRefresh = true
    postLoadVehicleRefreshDone = false
    wasPlayerReadyLastUpdate = false
    shopPinBootstrapEndsAt = nil
    shopPinBootstrapActive = true
    if modConfig.enableScannerTwintoneTabOverride == true then
        Override("scannerDetailsGameController", "ShouldDisplayTwintoneTab", function(this, wrappedMethod)
            local scannedObject = this and this.scannedObject or nil
            local id = GetScannedVehicleRecordIDValue(scannedObject)

            if id and Game.GetVehicleSystem() then
                local okUnlocked, isUnlocked = pcall(function()
                    return Game.GetVehicleSystem():IsVehiclePlayerUnlocked(TweakDBID.new(id))
                end)

                if okUnlocked and isUnlocked == false then
                    pcall(function()
                        this.twintoneAvailable = true
                    end)
                    return true
                end
            end

            return wrappedMethod()
        end)
    end

    Observe("QuestTrackerGameController", "OnInitialize", function()
        if cosvGameplaySessionActive ~= true then
            cosvGameplaySessionActive = true
            ResetRuntimeSessionState("session_start")
            LoadSettings()
        end
    end)

    Observe("QuestTrackerGameController", "OnUninitialize", function()
        if Game.GetPlayer() == nil and cosvGameplaySessionActive == true then
            cosvGameplaySessionActive = false
            ResetRuntimeSessionState("session_end")
        end
    end)

    Observe("PlayerPuppet", "OnMountingEvent", function(this, evt)
        if not IsPlayerReady() then
            return
        end

        SafeCall("OnMountingEvent pre", function()
            ClearMapPins()
            ResetVehicleContext()
        end)
    end)

    ObserveAfter("PlayerPuppet", "OnMountingEvent", function(this, evt)
        if not IsPlayerReady() then
            return
        end

        SafeCall("OnMountingEvent post", function()
            isPlayerMounted = true
            ClearMapPins()
            CaptureVehicle(GetEventOtherObject(evt))
            RefreshForeignBoardedVehicleAppearance(currentVehicle, currentRecordID, currentAppearance, IsBoardedVehicleOwned(currentRecordID, currentAppearance, currentVehicle))
            LogEnteredVehicle()
        end)
    end)

    Observe("PlayerPuppet", "OnUnmountingEvent", function(this, evt)
        if not IsPlayerReady() then
            return
        end

        SafeCall("OnUnmountingEvent", function()
            HideMountedZonePrompt()
            isPlayerMounted = false
            ClearMapPins()
            SetupTransactionAfterUnmount(GetEventOtherObject(evt))
        end)
    end)

    Observe("WorldMapMenuGameController", "ShowMappinTooltip", function(this, controller)
        if not this.selectedMappin then
            return
        end

        SafeCall("ShowMappinTooltip", function()
            selectedMapPin = this.selectedMappin and this.selectedMappin.mappin or nil
            selectedMapPinPosition = GetMapPinWorldPosition(selectedMapPin)
        end)
    end)

    Observe("WorldMapTooltipBaseController", "Show", function(this)
        if not selectedMapPin then
            return
        end

        SafeCall("WorldMapTooltipBaseController.Show", function()
            if not this.titleText or not this.descText then
                return
            end

            local shop = FindShopByRegisteredMapPin(selectedMapPin)

            if not shop and selectedMapPinPosition then
                for _, candidateShop in ipairs(shops) do
                    if IsShopEnabled(candidateShop) then
                        local shopPos = ToVector4(candidateShop.position)
                        if DistanceBetween(shopPos, selectedMapPinPosition) <= 5 then
                            shop = candidateShop
                            break
                        end
                    end
                end
            end

            if not shop then
                return
            end

            this.titleText:SetText(shop.name)
            this.descText:SetText(shop.description)
        end)
    end)
end)

registerForEvent("onUpdate", function()
    local engineTime = Game.GetEngineTime()
    local playerReady = IsPlayerReady()
    local gamePaused = IsGamePaused()

    if playerReady and engineTime and not gamePaused then
        local now = engineTime:ToFloat()

        if not nextSlowUpdateAt or now >= nextSlowUpdateAt then
            nextSlowUpdateAt = now + modConfig.slowUpdateInterval
            SafeCall("RefreshExpiredShopCooldowns", RefreshExpiredShopCooldowns)
        end

        if not nextCleanupUpdateAt or now >= nextCleanupUpdateAt then
            nextCleanupUpdateAt = now + modConfig.cleanupUpdateInterval
            SafeCall("ProcessPendingVehicleDisposals", ProcessPendingVehicleDisposals)
        end

        SafeCall("ProcessPendingAppearanceRefreshes", function()
            ProcessPendingAppearanceRefreshes(now)
        end)

        if settingsDirty == true and nextSettingsSaveAt and now >= nextSettingsSaveAt then
            SafeCall("FlushPendingSettings", FlushPendingSettings)
        end
    end

    if not playerReady or not engineTime or gamePaused then
        if paintPreviewState.active == true then
            CancelPaintPreview("runtime_unavailable", true)
        end
        wasPlayerReadyLastUpdate = false
        if activeTransaction and activeStartedAt then
            SafeCall("Notify transaction prompt hide", function()
                Notify(messageConfig.transactionPrompt, 5, gameSimpleMessageType.Relic, false)
            end)
        end
        return
    end

    if wasPlayerReadyLastUpdate ~= true then
        pendingPostLoadVehicleRefresh = true
        postLoadVehicleRefreshDone = false
        wasPlayerReadyLastUpdate = true
    end

    if activeTransaction then
        HideMountedZonePrompt()
        SafeCall("ProcessActiveTransaction", ProcessActiveTransaction)
    else
        local now = engineTime:ToFloat()

        if shopPinBootstrapEndsAt == nil then
            shopPinBootstrapEndsAt = now + shopPinBootstrapDuration
        elseif shopPinBootstrapActive == true and now >= shopPinBootstrapEndsAt then
            shopPinBootstrapActive = false
            ClearMapPins()
        end

        if not nextMapPinUpdateAt or now >= nextMapPinUpdateAt then
            nextMapPinUpdateAt = now + modConfig.mapPinUpdateInterval
            if pendingPostLoadVehicleRefresh == true and postLoadVehicleRefreshDone ~= true then
                SafeCall("ProcessPostLoadVehicleRefresh", ProcessPostLoadVehicleRefresh)
            end
            SafeCall("SpawnShopMapPinsForCurrentVehicle", function()
                SpawnShopMapPinsForCurrentVehicle(now)
            end)
        end

        if not nextProximityUpdateAt or now >= nextProximityUpdateAt then
            nextProximityUpdateAt = now + modConfig.proximityUpdateInterval
            RefreshProximityState()
            SafeCall("ProcessPaintPreview", function()
                ProcessPaintPreview(now)
            end)
            SafeCall("ProcessPendingPaintPreviewUnavailable", ProcessPendingPaintPreviewUnavailable)
            SafeCall("UpdateMountedZonePrompt", UpdateMountedZonePrompt)
            SafeCall("ProcessConfigurationAlert", function()
                if ProcessConfigurationAlert(now) == true then
                    UpdateMountedZonePrompt()
                end
            end)
        end
    end
end)

registerForEvent("onOverlayOpen", function()
    overlayOpen = true
end)

registerForEvent("onOverlayClose", function()
    overlayOpen = false
    FlushPendingSettings()
end)

registerForEvent("onDraw", function()
    if not overlayOpen or not modConfig.enableSettings then return end

    ImGui.SetNextWindowSizeConstraints(400, 300, 800, 700)
    ImGui.SetNextWindowSize(580, 360, ImGuiCond.Appearing)

    local windowVisible = ImGui.Begin("Claim or Sell Vehicles")

    if windowVisible then
        local changed

        modConfig.unlockFeeMultiplier, changed = ImGui.SliderFloat(
            Msg("overlay.sliders.hack_shop_fee"),
            modConfig.unlockFeeMultiplier,
            0.25,
            3.0,
            "%.2fx"
        )
        if changed then MarkSettingsDirty() end

        modConfig.salePriceMultiplier, changed = ImGui.SliderFloat(
            Msg("overlay.sliders.vehicle_sale_payout"),
            modConfig.salePriceMultiplier,
            0.25,
            3.0,
            "%.2fx"
        )
        if changed then MarkSettingsDirty() end

        modConfig.enableAppearanceRefresh, changed = ImGui.Checkbox(
            Msg("overlay.toggles.appearance_refresh_debug"),
            modConfig.enableAppearanceRefresh
        )
        if changed then MarkSettingsDirty() end

        modConfig.enableDogtownDropoff, changed = ImGui.Checkbox(
            Msg("overlay.toggles.dogtown_dropoff"),
            modConfig.enableDogtownDropoff
        )
        if changed then
            ClearMapPins()
            MarkSettingsDirty()
        end

        modConfig.enableRawRecords, changed = ImGui.Checkbox(
            Msg("overlay.toggles.raw_records"),
            modConfig.enableRawRecords
        )
        if changed then MarkSettingsDirty() end

        local applyRemoteHack = modConfig.doNotApplyRemoteHack ~= true
        applyRemoteHack, changed = ImGui.Checkbox(
            Msg("overlay.toggles.apply_remote_hack"),
            applyRemoteHack
        )
        if changed then
            modConfig.doNotApplyRemoteHack = applyRemoteHack ~= true
            MarkSettingsDirty()
        end

        modConfig.enableLastStandScaner, changed = ImGui.Checkbox(
            Msg("overlay.toggles.enable_stubborn_claim"),
            modConfig.enableLastStandScaner
        )
        if changed then MarkSettingsDirty() end

        ImGui.Separator()

        if ImGui.Button(Msg("overlay.buttons.create_manual_backup")) then
            CreateManualCOSVGarageBackup()
        end

        if ImGui.Button(Msg("overlay.buttons.restore_manual_backup")) then
            RestoreManualCOSVGarageBackup()
        end

        if ImGui.Button(Msg("overlay.buttons.restore_last_transaction_state")) then
            RestoreLastTransactionCOSVGarageState()
        end
    end

    ImGui.End()
end)
