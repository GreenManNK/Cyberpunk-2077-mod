local config = require("modules/config")
local utils = require("modules/utils")
local tweaks = require("modules/tweaks")

local settings = {}

function settings.addKeybinds(mod)
    -- Keyboard
    local info = mod.inputManager.createBindingInfo()
    info.keybindLabel = "Key"
    info.keybindDescription = "Bind a key that is part of the hotkey"
    info.isHoldLabel = "Is Hold"
    info.supportsHold = false
    info.id = "mkbBinding"
    info.maxKeys = 2
    info.maxKeysLabel = "Hotkey Keys Amount"
    info.maxKeysDescription = "Changes how many keys this hotkey has, all of them have to pressed for the hotkey to be activated"
    info.nativeSettingsPath = "/nightVision/hotkeyMKB"
    info.defaultOptions = mod.defaultSettings.keyboard
    info.savedOptions = mod.settings.keyboard
    info.saveCallback = function(name, value)
        mod.settings.keyboard[name] = value
        config.saveFile("config/config.json", mod.settings)
        tweaks.applyTweaks(mod)
    end
    info.callback = function()
        mod:toggleNV()
    end
    mod.inputManager.addNativeSettingsBinding(info)

    -- Gamepad
    info = utils.deepcopy(info)
    info.supportsHold = true
    info.isHoldDescription = "Controls whether the bound key below needs to be held down for some time to be activated"
    info.id = "padBinding"
    info.maxKeys = 3
    info.maxKeysLabel = "Hotkey Keys Amount"
    info.maxKeysDescription = "Changes how many keys this hotkey has, all of them have to pressed for the hotkey to be activated"
    info.nativeSettingsPath = "/nightVision/hotkeyPad"
    info.defaultOptions = mod.defaultSettings.pad
    info.savedOptions = mod.settings.pad
    info.saveCallback = function(name, value)
        mod.settings.pad[name] = value
        config.saveFile("config/config.json", mod.settings)
        tweaks.applyTweaks(mod)
    end
    mod.inputManager.addNativeSettingsBinding(info)
end

function settings.setupNative(mod)
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then
        print("[NightVision] Info: NativeSettings lib not found!")
        return
    end

    local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- <-- This has been made by psiberx, all credits to him
        return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
    end)))

    if cetVer < 1.18 then
        print("[NightVision] Error: CET version below recommended!")
        return
    end

    nativeSettings.addTab("/nightVision", "Night Vision CW")
    nativeSettings.addSubcategory("/nightVision/hotkeyMKB", "Keyboard Hotkey")
    nativeSettings.addSubcategory("/nightVision/hotkeyPad", "Controller Hotkey")

    settings.addKeybinds(mod)
end

return settings