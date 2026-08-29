local Cron = require("modules/external/Cron")

local logic = {
    lightID = nil,
    lightPath = "base\\flashlight\\light.ent",
    active = false,
    cronTimer = nil,
    brightnessOverride = nil,
    colorText = nil,
    callState = nil
}

function logic.initColors()
    local color = require("modules/utils/color")

    logic.colors = {
        color.white,
        color.new(255, 230, 230),
        color.new(255, 0, 0),
        color.new(0, 255, 0),
        color.new(0, 0, 255),
        color.orange,
        color.aqua,
        color.new(255, 255, 0),
    }
end

function logic.addObserver(flashlight)
    Observe('SettingsMainGameController', 'PopulateCategorySettingsOptions', function()
        if not GetMod("nativeSettings").fromMods then return end
        Cron.After(0.2, function()
            logic.setColorText(flashlight)
        end)
    end)

    Observe('SettingsMainGameController', 'RequestClose', function()
        logic.colorText = nil
	end)

    Observe("PopupsManager", "OnShardRead", function ()
		flashlight.runtimeData.inMenu = true
	end)

	Observe("PopupsManager", "OnShardReadClosed", function ()
		flashlight.runtimeData.inMenu = false
	end)

    ObserveAfter("HudPhoneGameController", "OnTriggerCall", function(this)
        logic.callState = this.CurrentCallInformation.callPhase
    end)
end

function logic.setColorText(flashlight)
    if not GetMod("nativeSettings").settingsMainController then return end
    logic.colorText = GetMod("nativeSettings").settingsMainController:GetRootCompoundWidget():GetWidgetByPathName(StringToName("wrapper/wrapper/MainScrollingArea/scroll_area/settings_option_list/color/layout/inkCanvasWidget4/label"))
    logic.colorText:SetTintColor(color.new(flashlight.settings.red * 2, flashlight.settings.green * 2, flashlight.settings.blue * 2))
end

function logic.run(flashlight)
    if logic.lightID and Game.FindEntityByID(logic.lightID) then
        logic.updatePosition(flashlight)
        logic.updateSettings(flashlight)
    end
end

function logic.toggle(flashlight)
    if logic.cronTimer then return end

    local time = flashlight.settings.fadeTime

    if logic.active then
        if not logic.getComponent() then
            logic.active = false
        else
            Cron.Every(0.01, { tick = 0 }, function(timer)
                if timer.tick < time then
                    logic.brightnessOverride = flashlight.settings.brightness * ((time - timer.tick) / time)
                    timer.tick = timer.tick + 0.01
                else
                    logic.despawn()
                    logic.active = false
                    timer:Halt()
                    logic.brightnessOverride = nil
                end
            end)
        end
    else
        logic.spawn()
        logic.active = true

        Cron.Every(0.01, { tick = 0 }, function(timer)
            if timer.tick < time then
                logic.brightnessOverride = flashlight.settings.brightness * (timer.tick / time)
                timer.tick = timer.tick + 0.01
            else
                timer:Halt()
                logic.brightnessOverride = nil
            end
        end)
    end
end

function logic.spawn()
    local transform = Game.GetPlayer():GetWorldTransform()
	local pos = Game.GetPlayer():GetWorldPosition()

	pos.x = pos.x - Game.GetCameraSystem():GetActiveCameraForward().x * 2
	pos.y = pos.y - Game.GetCameraSystem():GetActiveCameraForward().y * 2
	pos.z = pos.z - Game.GetCameraSystem():GetActiveCameraForward().z * 2
	pos.z = pos.z + 1.45

	transform:SetPosition(pos)

	local path = logic.lightPath

	logic.lightID = WorldFunctionalTests.SpawnEntity(path, transform, '')
end

function logic.despawn()
    if logic.lightID and Game.FindEntityByID(logic.lightID) then
        WorldFunctionalTests.DespawnEntity(Game.FindEntityByID(logic.lightID))
    end
end

function logic.updatePosition(flashlight)
    local pos = Game.GetPlayer():GetWorldPosition()

	pos.z = pos.z + 1.8 -- Little bit up

	pos.x = pos.x + Game.GetCameraSystem():GetActiveCameraForward().x * (0.1 + flashlight.settings.offset) -- Little bit forward to avoid shadows from player
	pos.y = pos.y + Game.GetCameraSystem():GetActiveCameraForward().y * (0.1 + flashlight.settings.offset)

	local vec = Vector4.new(-Game.GetCameraSystem():GetActiveCameraForward().x, -Game.GetCameraSystem():GetActiveCameraForward().y, -Game.GetCameraSystem():GetActiveCameraForward().z, -Game.GetCameraSystem():GetActiveCameraForward().w)
    local euler = vec:ToRotation()
	local rot = EulerAngles.new(0, euler.pitch, Game.GetPlayer():GetWorldOrientation():ToEulerAngles().yaw)

	Game.GetTeleportationFacility():Teleport(Game.FindEntityByID(logic.lightID), pos, rot)
end

function logic.getComponent()
    if not logic.lightID or not Game.FindEntityByID(logic.lightID) then return end

    local light = Game.FindEntityByID(logic.lightID):FindComponentByName("Light5520")

    return light
end

function logic.updateSettings(flashlight)
    if logic.cronTimer then return end

    local l = logic.getComponent()
    if l then
        local b = logic.brightnessOverride or flashlight.settings.brightness
        l:SetStrength(b / 15)
        l:SetRadius(flashlight.settings.range)
        l:SetColor(Color.new({Red = flashlight.settings.red, Green = flashlight.settings.green, Blue = flashlight.settings.blue}))
        l:SetAngles(flashlight.settings.angle, math.min(140, flashlight.settings.angle + flashlight.settings.falloff))
    end
end

return logic