local GameUI = require("modules/external/GameUI")
local config = require("modules/utils/config")
local Cron = require("modules/external/Cron")
local variantUtils = require("modules/utils/variantUtils")
local lang = require("modules/utils/lang")

local modName = "Improved Aldecaldos Camp"
local category = "LocKey#36742" -- Camp des Aldecaldos

local defaultVariantSettings = require("modules/variantSettings")

local switcher = {
    settings = defaultVariantSettings,
    defaultSettingsInSaveFormat = {}
}

local function getSettingPath()
    local path = "/" .. string.gsub(modName, " ", "_"):lower()
    local subPath = "/main"

    return path .. subPath
end

-- Custom setting behaviors DO NOT go here
local function initAutomatedMenuSettings()
    local nativeSettings = GetMod("nativeSettings")

    for _, setting in pairs(switcher.settings) do
        -- Skip settings that should not appear in the menu
        if not setting.showInMenu then goto continue end
        if setting.type == "manual" then goto continue end

        if setting.type == "boolean" then
            nativeSettings.addSwitch(getSettingPath(), lang.getText(setting.displayName), lang.getText("LocKey#17809"), setting.state, setting.state, function(state)
                setting.state = state
                switcher.save()
                variantUtils.updateVariantVisibility(setting)
            end)
        elseif setting.type == "swap" then
            nativeSettings.addSwitch(getSettingPath(), lang.getText(setting.displayName), lang.getText("LocKey#17809"), setting.state, setting.state, function(state)
                if state then
                    switcher.toggleSwapSetting(setting.variantTrue)
                else
                    switcher.toggleSwapSetting(setting.variantFalse)
                end
            end)
        elseif setting.type == "selector" then
            -- Map labels to get translations
            local variantLabels = {}
            for key, langKey in pairs(setting.variantLabels) do
                variantLabels[key] = lang.getText(langKey)
            end

            nativeSettings.addSelectorString(getSettingPath(), lang.getText(setting.displayName), lang.getText("LocKey#6890"), variantLabels, setting.state, setting.state, function(state)
                setting.state = state
                switcher.save()
                variantUtils.updateVariantVisibility(setting)
            end)
        end

        --if setting.description ~= nil then
        --    -- Parameters: path, callback, optionalIndex
        --    nativeSettings.addCustom(getSettingPath(), function(inkCompoundWidget, option)
        --        -- Add any logic you need in here, such as adding custom UI to the inkCompoundWidget
        --    end)
        --end
        ::continue::
    end
end

local function createNativeSettingsTab()
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then
        print("[" .. modName .."] Error: NativeSettings lib not found!")
        return
    end

    local path = "/" .. string.gsub(modName, " ", "_"):lower()

    -- Add tab
    if not nativeSettings.pathExists(path) then
        nativeSettings.addTab(path, modName)
    end

    -- Add section
    nativeSettings.addSubcategory(getSettingPath(), category)

    -- Add menu settings
    initAutomatedMenuSettings()

    -- TODO : Add any settings with custom behavior


    -- Add section ### Reset buttons ###
    local debugCategoryPath = path .. '/debug'
    nativeSettings.addSubcategory(debugCategoryPath, "Debug")
    -- Parameters: path, label, desc, buttonText, textSize, callback, optionalIndex
    nativeSettings.addButton(debugCategoryPath, "Improved Aldecaldos Camp", "Reset all features of the mod", "Reset all", 45, function()
        Game.GetQuestsSystem():SetFact("akiway_iac__active", 0)
    end)
    nativeSettings.addButton(debugCategoryPath, "Panzer Basilisk", "Reset Basilisk feature (the 3 days timer will start over again if quest \"Queen of the Highway\" is done, you will receive Mitch messages again)", "Reset", 45, function()
        Game.GetQuestsSystem():SetFact("akiway_iac__basilisk__reset", 0)
        Game.GetQuestsSystem():SetFact("akiway_iac__basilisk__reset", 1)
    end)
    nativeSettings.addButton(debugCategoryPath, "Panam tent - Tarp", "Reset tarp feature", "Reset", 45, function()
        Game.GetQuestsSystem():SetFact("akiway_iac__v_tent__tarp__reset", 0)
        Game.GetQuestsSystem():SetFact("akiway_iac__v_tent__tarp__reset", 1)
    end)
    nativeSettings.addButton(debugCategoryPath, "Living truck - walls color switch", "Reset walls color switch feature", "Reset", 45, function()
        Game.GetQuestsSystem():SetFact("akiway_iac__living_truck__reset", 0)
        Game.GetQuestsSystem():SetFact("akiway_iac__living_truck__reset", 1)
    end)
    nativeSettings.addButton(debugCategoryPath, "Techie truck", "Reset techie truck features", "Reset", 45, function()
        Game.GetQuestsSystem():SetFact("akiway_iac__techie_truck__reset", 0)
        Game.GetQuestsSystem():SetFact("akiway_iac__techie_truck__reset", 1)
    end)
end

function switcher.cleanupObsoleteVariants()
    local loadedConfig = config.loadFile("config.json") or {}
    local cleanedConfig = {}
    local hasChanges = false

    -- Create a lookup table for current valid settings (name/ref combinations)
    local validSettings = {}
    for _, setting in pairs(defaultVariantSettings) do
        validSettings[setting.name] = true
    end


    -- Filter out obsolete variants from loaded config
    for key, setting in pairs(loadedConfig) do
        local name = setting and setting.name
        if name and validSettings[name] then
            cleanedConfig[key] = setting
        else
            print("[" .. modName .. "] Info: Removing obsolete variant '" .. tostring(name) .. "'")
            hasChanges = true
        end
    end

    -- Save cleaned config if changes were made
    if hasChanges then
        switcher.save(cleanedConfig)
        print("[" .. modName .."] Info: Config cleaned up - obsolete variants removed")
    end
end


function switcher.init() -- Runs once onInit
    switcher.defaultSettingsInSaveFormat = switcher.convertToSaveFormat(defaultVariantSettings)
    config.tryCreateConfig("config.json", switcher.defaultSettingsInSaveFormat)
    -- Add new (or missing) variants
    config.backwardComp("config.json", switcher.defaultSettingsInSaveFormat)
    -- Remove old variants
    switcher.cleanupObsoleteVariants()
    -- Get updated config
    switcher.loadSettings()

    if not Codeware then
        print("Codeware not found, please install it to use this mod")
        return
    end
    
    -- Mod compatibility with https://www.nexusmods.com/cyberpunk2077/mods/24475
    if ModArchiveExists("photos_and_tab_frames_panam.archive") then
        switcher.setSettingByName("v_tent/box", true)
    end

    GameUI.OnSessionStart(function()
        -- Initialize all streaming sector variants based on saved settings or default settings
        for _, setting in pairs(switcher.settings) do
            variantUtils.updateVariantVisibility(setting)
        end
    end)

    -- Init menu settings
    createNativeSettingsTab()

    -- Time based changes
    Cron.Every(10, function()
        local currentHour = GameTime.Hours(Game.GetTimeSystem():GetGameTime())
        
        -- Is passed Midnight - 00h > 5h
        local isPassedMidnight = (currentHour < 5)
        local isPassedMidday = (currentHour >= 12 and currentHour < 22)

        -- Deceptious Night - Panam Romance Enhanced compatible - 23h > 5h
        local isDeceptiousNight = (currentHour >= 23 or currentHour < 5)
        if math.random(1, isPassedMidnight and 2 or isPassedMidday and 1 or 10) == 1 then
            switcher.setSettingByName("cassidy_tent/door", isDeceptiousNight)
        end

        -- Deceptious shower times
        local isShowerTime = (currentHour >= 5 and currentHour < 7 or currentHour >= 21 and currentHour < 23)
        
        -- Night - 22h > 6h
        local isNight = (currentHour >= 22 or currentHour < 6)
        switcher.setSettingByName("outside/tent_camo", isNight)
        switcher.setSettingByName("outside/tent_brown", isNight)
        switcher.setSettingByName("outside/hangar_basilisk", isNight)
        switcher.setSettingByName("outside/hangar", isNight)
        if math.random(1, isPassedMidnight and 2 or isPassedMidday and 1 or 10) == 1 then
            switcher.setSettingByName("showers_tent/door", isNight)
        end
        if math.random(1, isPassedMidnight and 2 or isPassedMidday and 1 or 10) == 1 then
            switcher.setSettingByName("new_tent/door", isNight)
        end
    end, nil)

    -- local listener = NewProxy({
    --     OnTimeMatch = {
    --         args = {'whandle:entEntity'},
    --         callback = function(gameTime)
    --             print("Hourra")
    --             print(GameTime.ToString(gameTime))
    --         end
    --     }
    -- })
    -- 
    -- Game.GetTimeSystem():RegisterListener(listener:Target(), listener:Function('OnTimeMatch'), GameTime.MakeGameTime(0, 4, 0, 0), 16, false)
end

function switcher.getSettingByName(name)
    for _, setting in pairs(switcher.settings) do
        if setting.name == name then
            return setting
        end
    end
    print("[" .. modName .."] Warning: No setting found for name '" .. name .. "'")
    return nil -- Retourn nil if no settings found
end

function switcher.setSettingByName(name, value)
    local setting = switcher.getSettingByName(name)

    -- Update only if state changed
    if setting == nil or setting.state == value then return end

    print("[" .. modName .."] Info: setting " .. setting.name .. " to " .. tostring(value))
    setting.state = value
    variantUtils.updateVariantVisibility(setting)

    switcher.save()
end

function switcher.getSettingByVariant(variantName) -- Does not work for selector
    for _, setting in pairs(switcher.settings) do
        if setting.type == "boolean" and setting.variant == variantName then
            return setting
        elseif setting.type == "swap" and (setting.variantTrue == variantName or setting.variantFalse == variantName) then
            return setting
        end
    end
    print("[" .. modName .."] Warning: No setting found for variant '" .. variantName .. "'")
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
        print("[" .. modName .."] Warning: No swap setting found for variant '" .. variant .. "'")
        return
    end

    -- Define desired state based on variant passed as argument
    --      variantTrue => true
    --      variantFalse => false
    setting.state = (variant == setting.variantTrue)
    variantUtils.updateVariantVisibility(setting)
    switcher.save()
end

function switcher.convertToSaveFormat(settings)
    local settingsToSave = {}
    for _, setting in ipairs(settings or {}) do
        if setting and setting.name ~= nil then
            settingsToSave[#settingsToSave + 1] = {
                name = setting.name,
                state = setting.state
            }
        end
    end
    return settingsToSave
end


---@param settings any List of settings to save, default to switcher.settings
function switcher.save(settings)
    local settingsToSave = switcher.convertToSaveFormat(settings or switcher.settings)
    config.saveFile("config.json", settingsToSave)
end

function switcher.loadSettings()
  local savedSettings = config.loadFile("config.json") or {}

  -- Index des savedSettings par name pour merge rapide
  local savedByName = {}
  for _, s in ipairs(savedSettings) do
    if s and s.name ~= nil then
      savedByName[s.name] = s
    end
  end

  local settings = {}
  for _, def in ipairs(defaultVariantSettings) do
    local saved = savedByName[def.name]

    -- Copie de toutes les propriétés de defaultVariantSettings
    local merged = {}
    for k, v in pairs(def) do
      merged[k] = v
    end

    -- Surcharge avec name/state venant du savedSettings (si présent)
    if saved ~= nil then
      merged.name = saved.name
      if saved.state ~= nil then
        merged.state = saved.state
      end
    end

    table.insert(settings, merged)
  end

  switcher.settings = settings
end


return switcher