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
    terminal = require("modules/fastTravelTerminal")
}

function mansion:new()
    registerForEvent("onInit", function()
        CName.add("mansion_owned")

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            if not ModArchiveExists("mansionDLC.archive") then
                Game.GetPlayer():SetWarningMessage("Mansion DLC: Archive file is missing! Make sure that \"mansionDLC.archive\" is present in your \"archive/pc/mod\" folder")
            end
            if not (ArchiveXL) then
                Game.GetPlayer():SetWarningMessage("Mansion DLC: ArchiveXL is not installed. Without it this mod won't work!")
            end

            self.runtimeData.inGame = true
            world.onSessionStart()
            self.logic.onSessionStart()
            self.terminal.onSessionStart()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.logic.onSessionEnd()
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        if self.runtimeData.inGame then
            world.onSessionStart()
            self.logic.onSessionStart()
            self.terminal.onSessionStart()
        end

        interaction.init()
        world.init()
        self.logic.setupInteractions()
        self.logic.init()
        self.terminal.init()
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