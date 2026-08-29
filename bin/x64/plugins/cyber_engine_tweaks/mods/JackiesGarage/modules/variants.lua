-------------------------------------------------------------------------------------------------------------------------------
-- Variants manager by Akiway with keanuWheeze help from CP2077 Modding Tools Discord.
-------------------------------------------------------------------------------------------------------------------------------

local GameUI = require("modules/external/GameUI")
local config = require("modules/utils/config")
local Cron = require("modules/external/Cron")
local variantUtils = require("modules/utils/variantUtils")

local MOD_NAME = "My Mod"
local SETTINGS_SUB_NAME = "Variants"
local defaultVariantSettings = require("modules/variantSettings")

local switcher = {
    -- Settings that needs to be saved (keep in mind that settings are not game save based, so changing a value will affect all game saves)
    permanentSettings = defaultVariantSettings.permanentVariantSettings,
    -- Settings that doesn't need to be saved
    settings = defaultVariantSettings.variantSettings
}

local function createNativeSettingsTab()
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then
        print("[" .. MOD_NAME .."] Error: NativeSettings lib not found!")
        return
    end

    local path = "/" .. string.gsub(MOD_NAME, " ", "_"):lower()
    local subPath = "/" .. string.gsub(SETTINGS_SUB_NAME, " ", "_"):lower()

    -- Add tab
    if not nativeSettings.pathExists(path) then
        nativeSettings.addTab(path, MOD_NAME)
    end

    -- Add section
    nativeSettings.addSubcategory(path .. subPath, SETTINGS_SUB_NAME)

    -- Add menu settings
    for _, setting in ipairs(switcher.permanentSettings) do
        -- Skip settings that should not appear in the menu
        if not setting.showInMenu then goto continue end

        if setting.type == "boolean" then
            nativeSettings.addSwitch(path .. subPath, setting.displayName, "Toggle the " .. setting.displayName .. " variant", setting.state, setting.state, function(state)
                setting.state = state
                switcher.save(setting)
                variantUtils.updateVariantVisibility(setting)
            end)
        elseif setting.type == "swap" then
            nativeSettings.addSwitch(path .. subPath, setting.displayName, "Toggle the " .. setting.displayName .. " variant", setting.state, setting.state, function(state)
                if state then
                    switcher.toggleSwapSetting(setting.variantTrue)
                else
                    switcher.toggleSwapSetting(setting.variantFalse)
                end
            end)
        elseif setting.type == "selector" then
            nativeSettings.addSelectorString(path .. subPath, setting.displayName, "Select the " .. setting.settingValueName .. " variant", setting.variantLabels, setting.state, setting.state, function(state)
                setting.state = state
                switcher.save(setting)
                variantUtils.updateVariantVisibility(setting)
            end)
        end
        ::continue::
    end
end


function switcher.init() -- Runs once onInit
    config.tryCreateConfig("config.json", defaultVariantSettings.permanentVariantSettings)
    config.backwardComp("config.json", defaultVariantSettings.permanentVariantSettings)
    switcher.permanentSettings = config.loadFile("config.json")

    if not Codeware then
        print("Codeware not found, please install it to use this mod")
        return
    end

    GameUI.OnSessionStart(function()
        -- Initialize all streaming sector variants based on saved settings or default settings
        for _, setting in pairs(switcher.permanentSettings) do
            variantUtils.updateVariantVisibility(setting)
        end
    end)

    -- Init menu settings
    --   keanuWheeze's "Native Settings" mod compatibility
    createNativeSettingsTab()
    -- TODO: add Jack Humbert's "Mod settings" mod compatibility

    -- Time based changes
    Cron.Every(10, function()
        local currentHour = GameTime.Hours(Game.GetTimeSystem():GetGameTime())
        
        -- Is passed Midnight - 00h > 5h
        local isPassedMidnight = (currentHour < 5)
        -- Is passed Midday - 12h > 21h (From mid day, to night)
        local isPassedMidday = (currentHour >= 12 and currentHour < 22)

        -- Deceptious Night - Panam Romance Enhanced compatible - 23h > 5h
        local isDeceptiousNight = (currentHour >= 23 or currentHour < 5)

        -- Deceptious shower times
        local isShowerTime = (currentHour >= 5 and currentHour < 7 or currentHour >= 21 and currentHour < 23)
        
        -- Night - 22h > 6h
        local isNight = (currentHour >= 22 or currentHour < 6)


        -- Example of simple usage
        --   when in the correct time phase, the setting is set to true
        --
        -- switcher.setSettingByName("my_setting_name", isNight)


        -- Example of simple randomized probabillity usage
        --   if you have multiple things to trigger at the same time, you might not want to see everything changes all of a sudden, this will randomly delay some of the triggers to get a more organic and realistic feel.
        --   usefull in some situations, but might not fit your needs
        --   in this example it have 10% chance to get triggered at night every time the cron run (every 10 seconds)
        --
        -- if math.random(1, 10) == 1 then
        --     switcher.setSettingByName("my_setting_name", isNight)
        -- end


        -- Example of multiple conditions randomized probabillity usage
        --   same as before, but in this case we add a condition that will change the trigger probabillity
        --   in this example it have 10% chance to get triggered at night every time the cron run (every 10 seconds), but if we pass midnight, then it is garuanted to get triggered
        --
        -- if math.random(1, isPassedMidnight and 1 or 10) == 1 then
        --     switcher.setSettingByName("my_setting_name", isNight)
        -- end
    end, nil)
end

function switcher.getSettingByName(name)
    for _, setting in pairs(switcher.permanentSettings) do
        if setting.name == name then
            return setting
        end
    end
    for _, setting in pairs(switcher.settings) do
        if setting.name == name then
            return setting
        end
    end
    print("[" .. MOD_NAME .."] Warning: No setting found for name '" .. name .. "'")
    return nil -- Retourn nil if no settings found
end

function switcher.setSettingByName(name, value)
    local setting = switcher.getSettingByName(name)

    -- Update only if state changed
    if setting == nil or setting.state == value then return end

    print("[" .. MOD_NAME .."] Info: setting " .. setting.name .. " to " .. tostring(value))
    setting.state = value
    variantUtils.updateVariantVisibility(setting)

    switcher.save(setting)
end

function switcher.getSettingByVariant(variantName) -- Does not work for selector
    for _, setting in pairs(switcher.permanentSettings) do
        if setting.type == "boolean" and setting.variant == variantName then
            return setting
        elseif setting.type == "swap" and (setting.variantTrue == variantName or setting.variantFalse == variantName) then
            return setting
        end
    end
    for _, setting in pairs(switcher.settings) do
        if setting.type == "boolean" and setting.variant == variantName then
            return setting
        elseif setting.type == "swap" and (setting.variantTrue == variantName or setting.variantFalse == variantName) then
            return setting
        end
    end
    print("[" .. MOD_NAME .."] Warning: No setting found for variant '" .. variantName .. "'")
    return nil -- Retourn nil if no settings found
end

---@param variantsWithValue any Map of variant:value
function switcher.setMultipleVariants(variantsWithValue)
    for variant, value in pairs(variantsWithValue) do
        local setting = switcher.getSettingByVariant(variant)
        if setting and setting.state ~= value then
            setting.state = value
            variantUtils.updateVariantVisibility(setting)
        end
    end

    switcher.save()
end

function switcher.toggleSwapSetting(variant)
    local setting = switcher.getSettingByVariant(variant)
    if not setting or setting.type ~= "swap" then
        print("[" .. MOD_NAME .."] Warning: No swap setting found for variant '" .. variant .. "'")
        return
    end

    -- Define desired state based on variant passed as argument
    --      variantTrue => true
    --      variantFalse => false
    setting.state = (variant == setting.variantTrue)
    variantUtils.updateVariantVisibility(setting)
    switcher.save(setting)
end

---@param setting ? any Setting to check if isPermanent, to limit useless saveFile on non-permanent setting changes. (Default: will save if no setting provided)
function switcher.save(setting)
    if setting == nil or setting.isPermanent then
        config.saveFile("config.json", switcher.permanentSettings)
    end
end

return switcher