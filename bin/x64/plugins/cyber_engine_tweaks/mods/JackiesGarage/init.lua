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

local MOD_KEY = "JackiesGarage"
local MOD_NAME = "Jackies Garage"
local MAIN_MOD_ARCHIVE = "jackiesgarage.archive"

-- Initialize randomness for math.random() usage throughout the app
math.randomseed(os.time())

JackiesGarage = {
    runtimeData = {
        inMenu = false,
        inGame = false
    },
    interactions = require("modules/interactions"), -- set ingame interactions
    variants = require("modules/variants") -- set ingame variants and settings
    -- TODO: split variants and settings to create a dedicated settings.utils
}


function JackiesGarage:new()
    registerForEvent("onInit", function()
        CName.add(MOD_KEY)

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            if not ModArchiveExists(MAIN_MOD_ARCHIVE) then
                Game.GetPlayer():SetWarningMessage("[" .. MOD_NAME .."]: Archive file is missing!")
            end

            self.runtimeData.inGame = true
            world.onSessionStart()
            self.interactions.onSessionStart()
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
        end)

        self.runtimeData.inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
        if self.runtimeData.inGame then
            world.onSessionStart()
            self.interactions.onSessionStart()
        end

        interaction.init()
        world.init()
        self.interactions.setupInteractions()
        self.interactions.init()
        self.variants.init()
    end)

    registerForEvent("onUpdate", function(delta)
        if not self.runtimeData.inMenu and self.runtimeData.inGame then
            Cron.Update(delta)
            interaction.update()
            world.update()
            self.interactions.update(delta)
        end
    end)

    return self
end

return JackiesGarage:new()