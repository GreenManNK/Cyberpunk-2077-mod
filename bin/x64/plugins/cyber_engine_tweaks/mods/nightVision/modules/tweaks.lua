local item = require("modules/item_data")
local utils = require("modules/utils")
local items = {
    "Items.AdvancedKiroshiOpticsBare",
    "Items.AdvancedKiroshiOpticsCombined",
    "Items.AdvancedKiroshiOpticsHunter",
    "Items.AdvancedKiroshiOpticsPiercing",
    "Items.AdvancedKiroshiOpticsSensor",
    "Items.AdvancedKiroshiOpticsWallhack",
    "Items.AdvancedKiroshiOpticsTutorial",
    "Items.AdvancedKiroshiOptics",
    "Items.Iconic_AdvancedKiroshiOpticsBare"
}

local rarities = {
    "Rare",
    "RarePlus",
    "Epic",
    "EpicPlus",
    "Legendary",
    "LegendaryPlus",
    "LegendaryPlusPlus",
}

local tweaks = {
    itemNames = {}
}

local function buildNames()
    tweaks.itemNames = {}
    for _, item in pairs(items) do
        for _, rarity in pairs(rarities) do
            tweaks.itemNames[item .. rarity] = item .. rarity
        end
    end

    local records = {
        "gamedataItem_Record",
        "gamedataClothing_Record"
    }

    for _, record in pairs(records) do
        for _, entry in pairs(TweakDB:GetRecords(record)) do
            if entry:TagsContains("NVSupport") then
                tweaks.itemNames[entry:GetID().value] = entry:GetID().value
            end
        end
    end
end

function tweaks.applyTweaks(mod)
    buildNames()
    local text = tweaks.getDescription(mod)

    TweakDB:CreateRecord("Items.nv_gameplay", "gamedataGameplayLogicPackage_Record")
    TweakDB:CreateRecord("Items.nv_ui", "gamedataGameplayLogicPackageUIData_Record")

    TweakDB:SetFlat("Items.nv_gameplay.UIData", "Items.nv_ui")
    TweakDB:SetFlat("Items.nv_ui.localizedDescription", text)

    for _, item in pairs(tweaks.itemNames) do
        tweaks.addToList(item .. ".OnEquip", "Items.nv_gameplay")
    end
end

function tweaks.getDescription(mod)
    local keys = " "

    if not GetPlayer():PlayerLastUsedPad() then
        for i = 1, mod.settings.keyboard.mkbBinding_keys do
            local key = mod.settings.keyboard["mkbBinding_" .. i]
            local hold = mod.settings.keyboard["mkbBinding_hold_" .. i] and "Show" or "Hide"

            keys = keys .. "<Input key=\"" .. key .. "\" device=\"keyboard\" hold=\"".. hold .. "\"></>"
            if mod.settings.keyboard.mkbBinding_keys ~= 1 and i ~= mod.settings.keyboard.mkbBinding_keys then
                keys = keys .. " + "
            end
        end
    else
        for i = 1, mod.settings.pad.padBinding_keys do
            local key = mod.settings.pad["padBinding_" .. i]
            local hold = mod.settings.pad["padBinding_hold_" .. i] and "Show" or "Hide"

            keys = keys .. "<Input key=\"" .. key .. "\" device=\"durango\" hold=\"".. hold .. "\"></>"
            if mod.settings.pad.padBinding_keys ~= 1 and i ~= mod.settings.pad.padBinding_keys then
                keys = keys .. " + "
            end
        end
    end

    return "<Rich color=\"#905FD4\">" .. item.description .. "</>" .. keys
end

function tweaks.addToList(list, record) --- Credits to scissors
	local recordhash = TweakDBID.new(record)
	local templist = TweakDB:GetFlat(list)
	if TweakDB:GetFlat(list) == nil then
		return
	end
	if not utils.has_value(templist, recordhash) then
		table.insert(templist, record)
		TweakDB:SetFlat(list, templist)
	end
end

function tweaks.onInit(mod)
    tweaks.applyTweaks(mod)
end

return tweaks