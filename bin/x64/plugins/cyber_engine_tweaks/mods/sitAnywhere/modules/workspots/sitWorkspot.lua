local interaction = require("modules/interactionUI")
local world = require("modules/worldInteraction")
local Cron  = require("modules/external/Cron")
local tween = require("tween/tween") -- https://github.com/kikito/tween.lua
local utils = require("modules/workspotUtils")

local sit = {}

function sit:new(id, interactionPosition, workspotPosition, workspotRotation, devicePath, name, entryText, exitText)
	local o = {}

    -- Basic data
    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = devicePath -- ent Path
    o.name = name -- Dialog name

    -- Dialog options data
    o.entryText = entryText
    o.entryIcon = "ChoiceCaptionParts.SitIcon"
    o.exitText = exitText
    o.exitIcon = "ChoiceCaptionParts.GetUpIcon"

    -- Slide / Enter data
    o.slideTime = 1
    o.slideCameraRot = EulerAngles.new(0, 0, 0) -- Camera rot target to match animation entry
    o.slideCameraPos = Vector4.new(0, 0, 0, 0) -- Camera pos target to match animation entry

    o.entryTime = 6.5
    o.exitTime = 4

    -- Custom camera limits in workspot
    o.maxPitch = 50
    o.minPitch = -50
    o.maxYaw = 50
    o.minYaw = -50

    -- Custom camera adjustments in workspot
    o.workspotCameraRot = EulerAngles.new(0, 0, 0) -- Rot adjustment
    o.workspotCameraPos = Vector4.new(0, 0, 0, 0) -- Pos adjustment

    o.rollStatic = 0 -- Adjust default camera roll in workspot
    o.rollDynamicMult = 0 -- Adjust camera roll with yaw

    -- Sounds
    o.enterSounds = {}
    o.exitSounds = {}

    -- World interaction data
    o.detectionAngle = 80
    o.iconRange = 6.5
    o.interactionRange = 1.75
    o.iconRecord = "ChoiceIcons.SitIcon"

    -- Internal
    o.hub = nil
    o.callbacks = nil

    o.inWorkspot = false
    o.inTransition = false
    o.camTransition = nil
    o.enableCamera = false
    o.slide = nil

    o.entityID = nil
    o.mod = mod

	self.__index = self
   	return setmetatable(o, self)
end

function sit:init() -- Setup basic info, create world interaction and hub
    world.addInteraction(self.id, self.interactionPosition, self.interactionRange, self.detectionAngle, self.iconRecord, self.iconRange, nil, function(state) -- Register world interaction
        if state then -- Show
            self:setupEntry()
            interaction.showHub()
        elseif not self.inWorkspot then -- Hide
            interaction.hideHub()
        end
    end)
end

function sit:setupEntry() -- Entry situation
    -- Entry dialog UI:
    local choice = interaction.createChoice(self.entryText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.entryIcon))
    self.hub = interaction.createHub(self.name, {choice})
    interaction.setupHub(self.hub)

    -- Enter option Callback:
    interaction.callbacks[1] = function()
        interaction.hideHub()
        world.togglePin(world.interactions[self.id], false)
        world.interactions[self.id].hideIcon = true
        utils.toggleHUD(not self.mod.settings.hideUI)
        utils.applyStatus("GameplayRestriction.NoCombat")
        utils.applyStatus("GameplayRestriction.NoPhotoMode")
        utils.applyStatus("GameplayRestriction.MetroRide")
        SaveLocksManager.RequestSaveLockAdd("PersonalLink")
        GetPlayer():GetPocketRadio().isRestrictionOverwritten = true
        self.inTransition = true

        -- Set camera roll, yaw and position to match entry animation. Pitch has to be done differently
        local currentPitch = Vector4.new(-Game.GetCameraSystem():GetActiveCameraForward().x, -Game.GetCameraSystem():GetActiveCameraForward().y, -Game.GetCameraSystem():GetActiveCameraForward().z, -Game.GetCameraSystem():GetActiveCameraForward().w):ToRotation().pitch
        self.camTransition = tween.new(self.slideTime, {roll = 0, pitch = currentPitch, yaw = 0, x = 0, y = 0, z = 0}, {roll = self.slideCameraRot.roll, pitch = self.slideCameraRot.pitch, yaw = self.slideCameraRot.yaw, x = self.slideCameraPos.x, y = self.slideCameraPos.y, z = self.slideCameraPos.z}, tween.easing.inOutQuad)

        GetPlayer():GetFPPCameraComponent():ResetPitch() -- Animation doesnt like cam pitch
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(0, currentPitch, 0):ToQuat()) -- Transfer pitch to camera component

        local pos = GetPlayer():GetWorldPosition()
        local rot = GetPlayer():GetWorldOrientation():ToEulerAngles()
        local yawGoal = self.workspotRotation.yaw + 180
        if yawGoal - rot.yaw > 180 then
            yawGoal = - (360 - yawGoal)
        end
        self.slide = tween.new(self.slideTime + 0.1, {x = pos.x, y = pos.y, z = pos.z, roll = rot.roll, pitch = rot.pitch, yaw = rot.yaw}, {x = self.workspotPosition.x, y = self.workspotPosition.y, z = self.workspotPosition.z, roll = self.workspotRotation.roll, pitch = self.workspotRotation.pitch, yaw = yawGoal}, tween.easing.inOutQuad)

        local transform = WorldTransform.new()
        transform:SetPosition(self.workspotPosition)
        transform:SetOrientationEuler(self.workspotRotation)
        self.entityID = exEntitySpawner.Spawn(self.devicePath, transform) -- Spawn actual workspot

        Cron.After(self.entryTime - 2.5, function() -- Smoothly transition to cam rot / pos adjustment in workspot
            self.camTransition = tween.new(2.5, {roll = 0, pitch = 0, yaw = 0, x = 0, y = 0, z = 0}, {roll = self.workspotCameraRot.roll, pitch = self.workspotCameraRot.pitch, yaw = self.workspotCameraRot.yaw, x = self.workspotCameraPos.x, y = self.workspotCameraPos.y, z = self.workspotCameraPos.z}, tween.easing.outExpo)
        end)

        Cron.After(self.entryTime, function()
            self.enableCamera = true
            self.inWorkspot = true
            self.inTransition = false
            self:setupExit()
        end)
    end
end

function sit:setupExit(forceShow) -- Exit situation
    if self.mod.settings.hideExitPopup and not forceShow or interaction.hubShown then return end
    -- Exit dialog UI:
    local choice = interaction.createChoice(self.exitText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.exitIcon))
    self.hub = interaction.createHub(self.name, {choice})
    interaction.setupHub(self.hub)
    interaction.showHub()

    -- Exit option Callback:
    interaction.callbacks[1] = function()
        interaction.hideHub()
        self.enableCamera = false
        self.inWorkspot = false
        self.inTransition = true

        Game.GetWorkspotSystem():SendForwardSignal(GetPlayer())

        local rot = GetPlayer():GetFPPCameraComponent():GetLocalOrientation():ToEulerAngles()
        local pos = GetPlayer():GetFPPCameraComponent():GetLocalPosition()
        self.camTransition = tween.new(0.8, {roll = rot.roll, pitch = rot.pitch, yaw = rot.yaw, x = pos.x, y = pos.y, z = pos.z}, {roll = 0, pitch = 0, yaw = 0, x = 0, y = 0, z = 0}, tween.easing.inOutCubic) -- Smoothly remove custom camera rotation

        if #self.exitSounds > 0 then
            local sound = self.exitSounds[math.random(#self.exitSounds)]
            utils.playAudio(sound.name, sound.delay)
        end

        Cron.After(self.exitTime, function()
            SaveLocksManager.RequestSaveLockRemove("PersonalLink")
            world.interactions[self.id].hideIcon = false
            world.interactions[self.id].shown = false -- Make sure the range check runs again
            self:setupEntry()
            exEntitySpawner.Despawn(Game.FindEntityByID(self.entityID))
            utils.toggleHUD(true)
            utils.removeStatus("GameplayRestriction.NoCombat")
            utils.removeStatus("GameplayRestriction.NoPhotoMode")
            utils.removeStatus("GameplayRestriction.MetroRide")
            GetPlayer():GetPocketRadio().isRestrictionOverwritten = false
            self.inTransition = false
        end)
    end
end

function sit:update(dt)
    if self.enableCamera then -- Apply custom camera rotation
        local rot = GetPlayer():GetFPPCameraComponent():GetLocalOrientation():ToEulerAngles()
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(self.rollDynamicMult * (rot.yaw) + self.workspotCameraRot.roll, math.min(self.maxPitch, math.max(self.minPitch, rot.pitch + self.pitch)), math.max(self.minYaw, math.min(self.maxYaw, rot.yaw + self.yaw))):ToQuat())
    end

    if self.camTransition then
        local done = self.camTransition:update(dt)
        GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(self.camTransition.subject.roll, self.camTransition.subject.pitch, self.camTransition.subject.yaw):ToQuat()) -- Custom camera transition rot
        GetPlayer():GetFPPCameraComponent():SetLocalPosition(Vector4.new(self.camTransition.subject.x, self.camTransition.subject.y, self.camTransition.subject.z, 0)) -- Custom camera transition pos
        if done then
            self.camTransition = nil
        end
    end

    if self.slide then
        local done = self.slide:update(dt)
        if done then
            GetPlayer():GetFPPCameraComponent():SetLocalOrientation(EulerAngles.new(0, 0, 0):ToQuat()) -- Reset cam, animation takes over
            GetPlayer():GetFPPCameraComponent():SetLocalPosition(Vector4.new(0, 0, 0, 0)) -- Reset cam, animation takes over

            local device = Game.FindEntityByID(self.entityID)
            Game.GetWorkspotSystem():PlayInDevice(device, GetPlayer(), "lockedCamera", "sitWorkspot", 0) -- Enter workspot
            self.slide = nil
            self.camTransition = nil

            if #self.enterSounds > 0 then
                local sound = self.enterSounds[math.random(#self.enterSounds)]
                utils.playAudio(sound.name, sound.delay)
            end
        else
            Game.GetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(self.slide.subject.x, self.slide.subject.y, self.slide.subject.z, 0), EulerAngles.new(self.slide.subject.roll, self.slide.subject.pitch, self.slide.subject.yaw)) -- Adjust player position
        end
    end
end

return sit