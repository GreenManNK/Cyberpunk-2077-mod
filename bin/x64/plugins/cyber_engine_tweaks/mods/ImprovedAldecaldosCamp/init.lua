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
local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")

-- Initialize randomness for math.random() usage throughout the app
math.randomseed(os.time())

iac = {
    runtimeData = {
        inMenu = false,
        inGame = false
    },
    interactionManager = require("modules/interactionManager"),
    variants = require("modules/variants")
}


function iac:new()
    registerForEvent("onInit", function()
        CName.add("ImprovedAldecaldosCamp")

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            if not ModArchiveExists("nativeInteractions.archive") then
                Game.GetPlayer():SetWarningMessage("[Improved Aldecaldos Camp] Missing dependency: Native Interactions Framework")
            end
            if not ModArchiveExists("Improved Aldecaldos Camp.archive") then
                Game.GetPlayer():SetWarningMessage("[Improved Aldecaldos Camp] Missing archive file")
            end

            self.runtimeData.inGame = true
            world.onSessionStart()
            self.interactionManager.sessionStart()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.interactionManager.sessionEnd()
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        if self.runtimeData.inGame then
            world.onSessionStart()
            self.interactionManager.sessionStart()
        end

        interaction.init()
        world.init()

        -- Initialize and setup interactions via manager
        self.interactionManager.init(self)
        self.interactionManager.setupInteractions()

        self.variants.init()
    end)

    registerForEvent("onUpdate", function(delta)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            Cron.Update(delta)
            interaction.update()
            world.update()
            self.interactionManager.update(delta)
        end
    end)

    registerForEvent("onShutdown", function()
        self.interactionManager.shutdown()
        world.shutdown()
    end)

    return self
end

return iac:new()
