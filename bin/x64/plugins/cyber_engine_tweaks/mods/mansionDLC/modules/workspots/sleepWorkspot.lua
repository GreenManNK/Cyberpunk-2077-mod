local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local Cron  = require("modules/external/Cron")
local tween = require("tween/tween") -- https://github.com/kikito/tween.lua
local utils = require("modules/utils/workspotUtils")

local sleep = {}

function sleep:new(id, interactionPosition, workspotPosition, workspotRotation)
	local o = {}

    -- Needs data
    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = "base\\gameplay\\devices\\arcade_machines\\bed.ent"
    o.name = GetLocalizedText("LocKey#37974")

    o.entryText = "[" .. GetLocalizedText("LocKey#8602") .. "]"
    o.entryIcon = "ChoiceCaptionParts.SitIcon"
    o.exitText = "[" .. GetLocalizedText("LocKey#12334") .. "]"
    o.exitIcon = "ChoiceCaptionParts.GetUpIcon"
    o.sleepText = "[" .. GetLocalizedText("LocKey#8537") .. "]"
    o.sleepIcon = "ChoiceCaptionParts.WaitIcon"

    o.slideTime = 1

    o.slideCameraRot = EulerAngles.new(-0.5, -45.3, -2) -- Camera rot target to match animation entry
    o.slideCameraPos = Vector4.new(-0.02, -0.125, -0.05, 0) -- Camera pos target to match animation entry

    o.entryTime = 9.5
    o.exitTime = 9.4

    o.maxPitch = 25 -- Custom camera limits in workspot
    o.minPitch = -20
    o.maxYaw = 40
    o.minYaw = 0

    o.workspotCameraRot = EulerAngles.new(0, 0, 0) -- Static camera rot adjustment in workspot
    o.workspotCameraPos = Vector4.new(0, 0, 0, 0) -- Static camera pos adjustment in workspot

    -- Defaults
    o.detectionAngle = 80
    o.iconRange = 5
    o.interactionRange = 1.75
    o.iconRecord = "ChoiceIcons.SitIcon"

    -- Internal
    o.hub = nil
    o.callbacks = nil

    o.inWorkspot = false
    o.camTransition = nil
    o.enableCamera = false
    o.slide = nil

    o.entityID = nil

	self.__index = self
   	return setmetatable(o, self)
end

local function openTimeSkip()
    local menuEvent = inkMenuInstance_SpawnEvent.new()
    menuEvent:Init("OnOpenTimeSkip")
    Game.GetUISystem():QueueEvent(menuEvent)
end

function sleep:init() -- Setup basic info, create world interaction and hub
    world.addInteraction(self.id, self.interactionPosition, self.interactionRange, self.detectionAngle, self.iconRecord, self.iconRange, nil, function(state) -- Register world interaction
        if state then -- Show
            self:setupEntry()
            interaction.showHub()
        elseif not self.inWorkspot then -- Hide
            interaction.hideHub()
        end
    end)

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
end

function sleep:setupEntry() -- Entry situation
    -- Entry dialog UI:
    local choice = interaction.createChoice(self.entryText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.entryIcon))
    self.hub = interaction.createHub(self.name, {choice})
    interaction.setupHub(self.hub)

    -- Enter option Callback:
    interaction.callbacks[1] = function()
        interaction.hideHub()
        world.togglePin(world.interactions[self.id], false)
        world.interactions[self.id].hideIcon = true
        self.inWorkspot = true
        utils.toggleHUD(false)
        SaveLocksManager.RequestSaveLockAdd("PersonalLink")

        -- Set camera roll, yaw and position to match entry animation. Pitch has to be done differently
        local currentPitch = Vector4.new(-Game.GetCameraSystem():GetActiveCameraForward().x, -Game.GetCameraSystem():GetActiveCameraForward().y, -Game.GetCameraSystem():GetActiveCameraForward().z, -Game.GetCameraSystem():GetActiveCameraForward().w):ToRotation().pitch
        self.camTransition = tween.new(self.slideTime, {roll = 0, pitch = currentPitch, yaw = 0, x = 0, y = 0, z = 0}, {roll = self.slideCameraRot.roll, pitch = self.slideCameraRot.pitch, yaw = self.slideCameraRot.yaw, x = self.slideCameraPos.x, y = self.slideCameraPos.y, z = self.slideCameraPos.z}, tween.easing.inOutQuad)

        Game.GetPlayer():GetFPPCameraComponent():ResetPitch() -- Animation doesnt like cam pitch
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(0, currentPitch, 0):ToQuat()) -- Transfer pitch to camera component

        -- Move / rotate player into workspot position
        local pos = GetPlayer():GetWorldPosition()
        local rot = GetPlayer():GetWorldOrientation():ToEulerAngles()
        local yawGoal = self.workspotRotation.yaw + 180
        if yawGoal - rot.yaw > 180 then
            yawGoal = - (360 - yawGoal)
        end
        self.slide = tween.new(self.slideTime + 0.1, {x = pos.x, y = pos.y, z = pos.z, roll = rot.roll, pitch = rot.pitch, yaw = rot.yaw}, {x = self.workspotPosition.x, y = self.workspotPosition.y, z = self.workspotPosition.z, roll = self.workspotRotation.roll, pitch = self.workspotRotation.pitch, yaw = yawGoal}, tween.easing.inOutQuad)

        -- Smoothly transition to static cam rot / pos adjustment in workspot
        Cron.After(self.entryTime - 1.5, function()
            self.camTransition = tween.new(1, {roll = 0, pitch = 0, yaw = 0, x = 0, y = 0, z = 0}, {roll = self.workspotCameraRot.roll, pitch = self.workspotCameraRot.pitch, yaw = self.workspotCameraRot.yaw, x = self.workspotCameraPos.x, y = self.workspotCameraPos.y, z = self.workspotCameraPos.z}, tween.easing.outExpo)
        end)

        -- Spawn actual workspot
        local transform = WorldTransform.new()
        transform:SetPosition(self.workspotPosition)
        transform:SetOrientationEuler(self.workspotRotation)
        self.entityID = exEntitySpawner.Spawn(self.devicePath, transform)

        Cron.After(self.entryTime, function()
            self.enableCamera = true
            self:setupExit()
        end)

        -- Blink
        Cron.After(self.slideTime + 0.65, function()
            GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "blink_slow", true, worldEffectBlackboard.new())
        end)
    end
end

function sleep:setupExit() -- Exit situation
    -- Exit dialog UI:
    local sleep = interaction.createChoice(self.sleepText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.sleepIcon))
    local getUp = interaction.createChoice(self.exitText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.exitIcon))
    self.hub = interaction.createHub(self.name, {sleep, getUp})
    interaction.setupHub(self.hub)
    interaction.showHub()

    -- Timeskip option Callback:
    interaction.callbacks[1] = function()
        interaction.hideHub()
        GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "blink_slow", true, worldEffectBlackboard.new())
        Cron.After(0.7, function()
            openTimeSkip()
            Cron.After(1.5, function()
                interaction.showHub()
            end)
        end)
    end

    -- Exit option Callback:
    interaction.callbacks[2] = function()
        interaction.hideHub()
        self.enableCamera = false
        self.inWorkspot = false

        -- Remove any custom cam pos / rot
        local rot = GetPlayer():GetFPPCameraComponent():GetLocalOrientation():ToEulerAngles()
        local pos = GetPlayer():GetFPPCameraComponent():GetLocalPosition()
        self.camTransition = tween.new(0.8, {roll = rot.roll, pitch = rot.pitch, yaw = rot.yaw, x = pos.x, y = pos.y, z = pos.z}, {roll = 0, pitch = 0, yaw = 0, x = 0, y = 0, z = 0}, tween.easing.inOutCubic) -- Smoothly remove custom camera rotation

        GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "blink_slow", true, worldEffectBlackboard.new())

        -- Wait until screen is black
        Cron.After(0.55, function ()
            local device = Game.FindEntityByID(self.entityID)
            Game.GetWorkspotSystem():PlayInDevice(device, GetPlayer(), "lockedCamera", "exitWorkspot", "", "", 0)

            utils.playAudio("q001_sc_01_wakeup_v_bedsitup", 1.1)
            utils.playAudio("q001_sc_01_v_stands_up", 4.1)

            -- Adjust player position for exit animation
            Cron.After(0.1, function()
                local pos = GetPlayer():GetWorldPosition()
                local rot = GetPlayer():GetWorldOrientation():ToEulerAngles()
                Game.GetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(pos.x - 0.5, pos.y, pos.z, 0), rot)
            end)

            Cron.After(self.exitTime, function()
                utils.applyStatus("HousingStatusEffect.Rested")
                utils.removeStatus("GameplayRestriction.NoCombat")
                SaveLocksManager.RequestSaveLockRemove("PersonalLink")
                world.interactions[self.id].hideIcon = false
                self:setupEntry()
                exEntitySpawner.Despawn(Game.FindEntityByID(self.entityID))
                utils.toggleHUD(true)
            end)
        end)
    end
end

function sleep:slideDoneCallback() -- Gets called when the slide is done / the actual workspot gets entered
    GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(0, 0, 0):ToQuat()) -- Reset cam rot, animation takes over
    GetPlayer():GetFPPCameraComponent():SetLocalPosition(Vector4.new(0, 0, 0, 0)) -- Reset cam pos, animation takes over
    local device = Game.FindEntityByID(self.entityID)
    Game.GetWorkspotSystem():PlayInDevice(device, GetPlayer(), "lockedCamera", "mainWorkspot", "", "", 0) -- Enter workspot
    self.slide = nil
    self.camTransition = nil
    utils.playAudio("q001_sc_01_v_wakes_up", 0.51)
end

function sleep:update(dt)
    if self.enableCamera then -- Apply custom camera rotation
        local rot = GetPlayer():GetFPPCameraComponent():GetLocalOrientation():ToEulerAngles()
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(self.workspotCameraRot.roll, math.min(self.maxPitch, math.max(self.minPitch, rot.pitch + self.pitch)), math.max(self.minYaw, math.min(self.maxYaw, rot.yaw + self.yaw))):ToQuat())
    end

    if self.camTransition then -- Do custom camera transitions
        local done = self.camTransition:update(dt)
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(self.camTransition.subject.roll, self.camTransition.subject.pitch, self.camTransition.subject.yaw):ToQuat()) -- Custom camera transition rot
        GetPlayer():GetFPPCameraComponent():SetLocalPosition(Vector4.new(self.camTransition.subject.x, self.camTransition.subject.y, self.camTransition.subject.z, 0)) -- Custom camera transition pos
        if done then
            self.camTransition = nil
        end
    end

    if self.slide then -- Slide into workspot pos / rot
        local done = self.slide:update(dt)
        if done then
            self:slideDoneCallback()
        else
            Game.GetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(self.slide.subject.x, self.slide.subject.y, self.slide.subject.z, 0), EulerAngles.new(self.slide.subject.roll, self.slide.subject.pitch, self.slide.subject.yaw)) -- Adjust player position
        end
    end
end

return sleep