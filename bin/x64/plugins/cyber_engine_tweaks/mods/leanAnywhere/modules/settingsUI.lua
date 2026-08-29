local config = require("modules/config")
local utils = require("modules/workspotUtils")

settings = {}

function settings.setupNative(mod)
    local nativeSettings = GetMod("nativeSettings")
    if not nativeSettings then
        print("[LeanAnywhere] Info: NativeSettings lib not found")
        return
    end

    nativeSettings.addTab("/LeanAnywhere", "Lean Anywhere")

    nativeSettings.addSwitch("/LeanAnywhere", "Hide Exit Popup", "Enable this to hide the get up prompt while leaning, to show the promt you'll have to hold the scanning key.", mod.settings.hideExitPopup, mod.defaultSettings.hideExitPopup, function(state)
        mod.settings.hideExitPopup = state
        if state == false and (mod.logic.leanWorkspot.workspot.inWorkspot) then
            if mod.logic.leanWorkspot.workspot.inWorkspot then mod.logic.leanWorkspot.workspot:setupExit(true) end
        end
        config.saveFile("config/config.json", mod.settings)
    end)

    nativeSettings.addSwitch("/LeanAnywhere", "Hide UI while leaning", "Enable this to hide the UI while leaning", mod.settings.hideUI, mod.defaultSettings.hideUI, function(state)
        mod.settings.hideUI = state
        if mod.logic.leanWorkspot.workspot.inWorkspot or mod.logic.leanWorkspot.workspot.inTransition then
            utils.toggleHUD(not state)
        end
        config.saveFile("config/config.json", mod.settings)
    end)
end

return settings