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

mansion = {
    runtimeData = {
        inMenu = false,
        inGame = false
    },
    logic = require("modules/logic"),
}

function mansion:new()
    registerForEvent("onInit", function()
        CName.add("Rebecca_Apart_DLC_2")

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            if not ModArchiveExists("rebeccas_apartment_dlc.archive") then
                Game.GetPlayer():SetWarningMessage("rebeccas_apartment_dlc: Archive file is missing!")
            end

            self.runtimeData.inGame = true
            world.onSessionStart()
            self.logic.onSessionStart()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        if self.runtimeData.inGame then
            world.onSessionStart()
            self.logic.onSessionStart()
        end

        interaction.init()
        world.init()
        self.logic.setupInteractions()
        self.logic.init()
    end)

    registerForEvent("onUpdate", function(dt)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            Cron.Update(dt)
            interaction.update()
            world.update()
            self.logic.update(dt)
        end
    end)

    return self
end

return mansion:new()