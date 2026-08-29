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
local interaction = require("modules/interactionUI")
local world = require("modules/worldInteraction")
local logger = require("modules/logger")
local config = require("modules/config")
local utils = require("modules/workspotUtils")

lean = {
    runtimeData = {
        inMenu = false,
        inGame = false,
        cetOpen = false,
        forceScan = false
    },

    settings = {},
    defaultSettings = {
        hideExitPopup = false,
        hideUI = true
    },

    settingsUI = require("modules/settingsUI"),
    yaw = 0,
    pitch = 0,
    workspots = {}
}

function lean:initWorkspots()
    self.leanWorkspot = require("modules/workspots/railWorkspot"):new(1, Vector4.new(0, 0, 0, 0), Vector4.new(0, 0, 0, 0), EulerAngles.new(0, 0, 0), self)
    self.leanWorkspot:init()
    self.logic.leanWorkspot = self.leanWorkspot
end

function lean:new()
    registerForEvent("onInit", function()
        config.tryCreateConfig("config/config.json", self.defaultSettings)
        config.backwardComp("config/config.json", self.defaultSettings)
        self.settings = config.loadFile("config/config.json")

        self.settingsUI.setupNative(self)
        self.logic = require("modules/logic"):new(self)

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
            world.onSessionStart()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.logic.sittables = {}
            self:initWorkspots()
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

        interaction.init()
        world.init()

        self:initWorkspots()
        self.logic:init()

        Observe('PlayerPuppet', 'OnAction', function(_, action) -- Custom camera controls input
            local actionName = Game.NameToString(action:GetName(action))

            if actionName == "CameraMouseX" then
                local x = action:GetValue(action)
                local sens = Game.GetSettingsSystem():GetVar("/controls/fppcameramouse", "FPP_MouseX"):GetValue() / 2.9
                self.yaw = - (x / 35) * sens
            end

            if actionName == "CameraMouseY" then
                local x = action:GetValue(action)
                local sens = Game.GetSettingsSystem():GetVar("/controls/fppcameramouse", "FPP_MouseY"):GetValue() / 2.9
                self.pitch = (x / 35) * sens
            end

            if actionName == "right_stick_x" then
                local x = action:GetValue(action)
                local sens = Game.GetSettingsSystem():GetVar("/controls/fppcamerapad", "FPP_PadX"):GetValue() / 10
                self.yaw = - x * 1.7 * sens
            end

            if actionName == "right_stick_y" then
                local x = action:GetValue(action)
                local sens = Game.GetSettingsSystem():GetVar("/controls/fppcamerapad", "FPP_PadY"):GetValue() / 10
                self.pitch = x * 1.7 * sens
            end
        end)

        Observe("NewHudPhoneGameController", "OpenSmsMessenger", function ()
            if self.logic.leanWorkspot.workspot.inWorkspot then
                utils.toggleHUD(true)
            end
        end)

        Observe("NewHudPhoneGameController", "CloseSmsMessenger", function ()
            if self.logic.leanWorkspot.workspot.inWorkspot then
                utils.toggleHUD(false)
            end
        end)

        Override("PocketRadio", "HandleRestriction", function (_, restriction, restricted, wrapped)
            if (self.logic.leanWorkspot.workspot.inWorkspot or self.logic.leanWorkspot.workspot.inTransition) and restricted then
                return
            end
            wrapped(restriction, restricted)
        end)

        Override("PocketRadio", "OnStatusEffectApplied", function (_, event, tags, wrapped)
            if self.logic.leanWorkspot.workspot.inWorkspot or self.logic.leanWorkspot.workspot.inTransition then
                return
            end
            wrapped(event, tags)
        end)
    end)

    registerForEvent("onUpdate", function(dt)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            Cron.Update(dt)
            interaction.update()
            world.update()
            self.logic:onUpdate()
            self.logic.leanWorkspot.workspot.yaw = self.yaw
            self.logic.leanWorkspot.workspot.pitch = self.pitch
            self.logic.leanWorkspot.workspot:update(dt)
        end
    end)

    registerForEvent("onOverlayOpen", function()
        self.runtimeData.cetOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        self.runtimeData.cetOpen = false
    end)

    registerForEvent("onDraw", function()
        logger.draw("leanAnywhere")
    end)

    registerHotkey("lean", "Hide", function()
        interaction.hideHub()
    end)

    registerInput("leanAnywhere", "[Optional] Hold to scan for leanable surface", function(down)
        if down then
            self.runtimeData.forceScan = true
        else
            self.runtimeData.forceScan = false
        end
    end)

    return self
end

return lean:new()