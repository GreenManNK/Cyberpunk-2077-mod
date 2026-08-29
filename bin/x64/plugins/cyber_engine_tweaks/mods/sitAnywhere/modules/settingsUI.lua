local config = require("modules/config")
local utils = require("modules/workspotUtils")

settings = {}

function settings.setupNative(mod)
    local nativeSettings = GetMod("nativeSettings")
    if not nativeSettings then
        print("[SitAnywhere] Info: NativeSettings lib not found")
        return
    end

    nativeSettings.addTab("/SitAnywhere", "Sit Anywhere")

    local list = {[1] = "Choose Automatically", [2] = "Hands On Lap", [3] = "Right Hand On Backrest"}
    nativeSettings.addSelectorString("/SitAnywhere", "Sit Animation", "Select a prefered sit animation, or let the mod choose", list, mod.settings.sitAnimation, mod.defaultSettings.sitAnimation, function(value)
        mod.settings.sitAnimation = value
        config.saveFile("config/config.json", mod.settings)
    end)

    nativeSettings.addSwitch("/SitAnywhere", "Hide Exit Popup", "Enable this to hide the stand up prompt while sitting down, to show the promt you'll have to hold the scanning key.", mod.settings.hideExitPopup, mod.defaultSettings.hideExitPopup, function(state)
        mod.settings.hideExitPopup = state
        if state == false and (mod.logic.sittables[0].workspot.inWorkspot or mod.logic.sittables[1].workspot.inWorkspot) then
            if mod.logic.sittables[0].workspot.inWorkspot then mod.logic.sittables[0].workspot:setupExit(true) end
            if mod.logic.sittables[1].workspot.inWorkspot then mod.logic.sittables[1].workspot:setupExit(true) end
        end
        config.saveFile("config/config.json", mod.settings)
    end)

    nativeSettings.addSwitch("/SitAnywhere", "Hide UI while sitting", "Enable this to hide the UI while sitting", mod.settings.hideUI, mod.defaultSettings.hideUI, function(state)
        mod.settings.hideUI = state
        if mod.logic:inWorkspot() or mod.logic:inTransition() then
            utils.toggleHUD(not state)
        end
        config.saveFile("config/config.json", mod.settings)
    end)
end

return settings