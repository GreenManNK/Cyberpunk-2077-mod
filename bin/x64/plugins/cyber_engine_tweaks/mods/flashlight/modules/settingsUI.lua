local config = require("modules/utils/config")

local settings = {
    nativeOptions = {},
    nativeSettings = nil,

    strength = 200,
    intensity = 200,
    radius = 60,
    inner = 40,
    outer = 55,
    changedFromPreset = false
}

function settings.setupNative(flashlight)
    local nativeSettings = GetMod("nativeSettings")
    settings.nativeSettings = nativeSettings
    if not nativeSettings then
        print("[Flashlight] Error: NativeSettings lib not found!")
        return
    end

    local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- <-- This has been made by psiberx, all credits to him
        return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
    end)))

    if cetVer < 1.18 then
        print("[Flashlight] Error: CET version below recommended!")
        return
    end

    nativeSettings.addTab("/flashlight", "Flashlight")
    nativeSettings.addSubcategory("/flashlight/gen", "General Settings")
    nativeSettings.addSubcategory("/flashlight/size", "Size and range")
    nativeSettings.addSubcategory("/flashlight/color", "Color")

    settings.nativeOptions["brightness"] = nativeSettings.addRangeInt("/flashlight/gen", "Brightness", "Controls the brightness of the flashlight", 1, 100, 1, flashlight.settings.brightness, flashlight.defaultSettings.brightness, function(value)
        flashlight.settings.brightness = value
        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["fade"] = nativeSettings.addRangeFloat("/flashlight/gen", "Turn On / Off Time", "Controls how longe the fade in / out duration is, when toggling the flashlight", 0, 1, 0.01, "%.2f", flashlight.settings.fadeTime, flashlight.defaultSettings.fadeTime, function(value)
        flashlight.settings.fadeTime = value
        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["offset"] = nativeSettings.addRangeFloat("/flashlight/gen", "Forward Offset", "Changes the flashlight's forward offset, to prevent it from shining on the weapons barrel", 0, 1, 0.05, "%.2f", flashlight.settings.offset, flashlight.defaultSettings.offset, function(value)
        flashlight.settings.offset = value
        config.saveFile("config.json", flashlight.settings)
    end)

    nativeSettings.addSwitch("/flashlight/gen", "Controller Support", "Disables / Enables the controller support", flashlight.settings.controllerMode, flashlight.defaultSettings.controllerMode, function(state)
        flashlight.settings.controllerMode = state
        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["angle"] = nativeSettings.addRangeInt("/flashlight/size", "Size", "Changes how big the flashlight's \"circle\" is", 15, 140, 1, flashlight.settings.angle, flashlight.defaultSettings.angle, function(value)
        flashlight.settings.angle = value
        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["falloff"] = nativeSettings.addRangeInt("/flashlight/size", "Falloff", "Changes how softly the flashlight's beam fades off to the edges", 0, 140, 1, flashlight.settings.falloff, flashlight.defaultSettings.falloff, function(value)
        flashlight.settings.falloff = value
        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["range"] = nativeSettings.addRangeInt("/flashlight/size", "Range", "Changes how far the flashlight lights up the environment", 1, 200, 1, flashlight.settings.range, flashlight.defaultSettings.range, function(value)
        flashlight.settings.range = value
        config.saveFile("config.json", flashlight.settings)
    end)

    local list = {
        [1] = "Custom",
        [2] = "White",
        [3] = "Warm White",
        [4] = "Red",
        [5] = "Green",
        [6] = "Blue",
        [7] = "Orange",
        [8] = "Aqua",
        [9] = "Yellow"
    }

    settings.nativeOptions["color"] = nativeSettings.addSelectorString("/flashlight/color", "Color Preset", "Select from one of the color presets, or create your own color", list, flashlight.settings.color, flashlight.defaultSettings.color, function(value)
        flashlight.settings.color = value

        if value ~= 1 then
            settings.changedFromPreset = true
            flashlight.settings.red = flashlight.logic.colors[flashlight.settings.color - 1].Red * 255
            flashlight.settings.green = flashlight.logic.colors[flashlight.settings.color - 1].Green * 255
            flashlight.settings.blue = flashlight.logic.colors[flashlight.settings.color - 1].Blue * 255

            flashlight.settings.red  = math.floor(flashlight.settings.red)
            flashlight.settings.green = math.floor(flashlight.settings.green)
            flashlight.settings.blue = math.floor(flashlight.settings.blue)

            settings.nativeSettings.setOption(settings.nativeOptions["red"], flashlight.settings.red)
            settings.nativeSettings.setOption(settings.nativeOptions["green"], flashlight.settings.green)
            settings.nativeSettings.setOption(settings.nativeOptions["blue"], flashlight.settings.blue)

            flashlight.logic.setColorText(flashlight)

            settings.changedFromPreset = false
        end

        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["red"] = nativeSettings.addRangeInt("/flashlight/color", "Red", "The amount of red", 0, 255, 1, flashlight.settings.red, flashlight.defaultSettings.red, function(value)
        flashlight.settings.red = value

        if not settings.changedFromPreset and flashlight.settings.color ~= 1 then
            flashlight.settings.color = 1
            settings.nativeSettings.setOption(settings.nativeOptions["color"], 1)
        end

        flashlight.logic.setColorText(flashlight)

        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["green"] = nativeSettings.addRangeInt("/flashlight/color", "Green", "The amount of green", 0, 255, 1, flashlight.settings.green, flashlight.defaultSettings.green, function(value)
        flashlight.settings.green = value

        if not settings.changedFromPreset and flashlight.settings.color ~= 1 then
            flashlight.settings.color = 1
            settings.nativeSettings.setOption(settings.nativeOptions["color"], 1)
        end

        flashlight.logic.setColorText(flashlight)

        config.saveFile("config.json", flashlight.settings)
    end)

    settings.nativeOptions["blue"] = nativeSettings.addRangeInt("/flashlight/color", "Blue", "The amount of blue", 0, 255, 1, flashlight.settings.blue, flashlight.defaultSettings.blue, function(value)
        flashlight.settings.blue = value

        if not settings.changedFromPreset and flashlight.settings.color ~= 1 then
            flashlight.settings.color = 1
            settings.nativeSettings.setOption(settings.nativeOptions["color"], 1)
        end

        flashlight.logic.setColorText(flashlight)

        config.saveFile("config.json", flashlight.settings)
    end)
end

return settings