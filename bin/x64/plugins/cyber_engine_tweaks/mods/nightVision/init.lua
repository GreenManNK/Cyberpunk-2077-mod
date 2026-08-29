-------------------------------------------------------------------------------------------------------------------------------
-- This mod was created by keanuWheeze from CP2077 Modding Tools Discord.
--
-- You are free to use this mod as long as you follow the following license guidelines:
--    * It may not be uploaded to any other site without my express permission.
--    * Using any code contained herein in another mod requires credits / asking me.
--    * You may not fork this code and make your own competing version of this mod available for download without my permission.
-------------------------------------------------------------------------------------------------------------------------------

local GameUI = require("modules/external/GameUI")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils")
local config = require("modules/config")
local tweaks = require("modules/tweaks")

local effectExclusions = {
    "sunglass_custom"
}

local night = {
    runtimeData = {
        inMenu = false,
        inGame = false,
        needApply = false,
        lastUsedMKB = true,
        enabled = false,
    },
    settings = {},
    defaultSettings = {
        keyboard = {
            ["mkbBinding_1"] = "IK_F3",
            ["mkbBinding_2"] = "IK_F4",
            ["mkbBinding_hold_1"] = false,
            ["mkbBinding_hold_2"] = false,
            ["mkbBinding_keys"] = 1
        },
        pad = {
            ["padBinding_1"] = "IK_Pad_X_SQUARE",
            ["padBinding_2"] = "IK_Pad_LeftShoulder",
            ["padBinding_3"] = "IK_Pad_LeftThumb",
            ["padBinding_hold_1"] = false,
            ["padBinding_hold_2"] = false,
            ["padBinding_hold_3"] = false,
            ["padBinding_keys"] = 2
        }
    }
}

function night:hasNVInstalled()
    local eyeCW = Game.GetScriptableSystemsContainer():Get("EquipmentSystem").GetItemsInArea(GetPlayer(), gamedataEquipmentArea.EyesCW)
    for _, itemID in pairs(eyeCW) do
        local cwItemData = Game.GetTransactionSystem():GetItemData(GetPlayer(), itemID)
        if tweaks.itemNames[cwItemData:GetID().id.value] ~= nil then return true end
        if TweakDBInterface.GetItemRecord(cwItemData:GetID():GetTDBID()):TagsContains("NVSupport") then
            return true
        end
    end

    local eqx = EquipmentEx_OutfitSystem
    if eqx then
        for _, part in pairs(EquipmentEx_OutfitSystem.GetInstance().state:GetParts()) do
            if TweakDBInterface.GetClothingRecord(part.itemID:GetTDBID()):TagsContains("NVSupport") then
                return true
            end
        end
    end

    return false
end

function night:toggleNV()
    local hasNV = self:hasNVInstalled()
    if not hasNV then return end

    self.runtimeData.enabled = not self.runtimeData.enabled
    if self.runtimeData.enabled then
        utils.playSound("ui_gui_cyberware_tab_open", GetPlayer())
    else
        utils.playSound("ui_gui_cyberware_tab_close", GetPlayer())
    end
end

function night:checkInputDevice()
    if not GetPlayer():PlayerLastUsedKBM() and self.runtimeData.lastUsedMKB then
        self.runtimeData.lastUsedMKB = false
    elseif GetPlayer():PlayerLastUsedKBM() and not self.runtimeData.lastUsedMKB then
        self.runtimeData.lastUsedMKB = true
    end
end

function night:new()
    registerForEvent("onHook", function ()
        self.inputManager = require("modules/inputManager")
        self.inputManager.onHook()
    end)

    registerForEvent("onInit", function()
        config.tryCreateConfig("config/config.json", self.defaultSettings)
        config.backwardComp("config/config.json", self.defaultSettings)
        self.settings = config.loadFile("config/config.json")

        if not Codeware then
            print("[NightVision] Error: Missing Codeware")
        end

        self.settingsUI = require("modules/settingsUI")
        self.settingsUI.setupNative(self)

        Cron.Every(1, function()
            self:checkInputDevice()
            if self.runtimeData.enabled and not self:hasNVInstalled() then
                self.runtimeData.enabled = false
            end
        end)

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
            Cron.After(0.25, function()
                utils.addEffect("night_vision_fx", "base\\fx\\night_vision.effect")
                tweaks.onInit(self)
            end)
            self.runtimeData.needApply = false
            self.runtimeData.enabled = false
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.runtimeData.enabled = false
        end)

        Override("GameObjectEffectHelper", "StartEffectEvent", function(target, name, state, bb, notify, wrapped)
            if utils.isSameInstance(GetPlayer(), target) then
                if utils.has_value(effectExclusions, name.value) and self.runtimeData.enabled then
                    return
                end
            end
            wrapped(target, name, state, bb, notify)
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
    end)

    registerForEvent("onUpdate", function(dt)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            self.inputManager.onUpdate(dt)
            if self.runtimeData.enabled then
                GameObjectEffectHelper.StopEffectEvent(GetPlayer(), "sunglass_custom")
                GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "night_vision_fx", true, worldEffectBlackboard.new())
            else
                GameObjectEffectHelper.StopEffectEvent(GetPlayer(), "night_vision_fx")
            end
            Cron.Update(dt)
        else
            GameObjectEffectHelper.StopEffectEvent(GetPlayer(), "night_vision_fx")
        end
    end)

    return self
end

return night:new()