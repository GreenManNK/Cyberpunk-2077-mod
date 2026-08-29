local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local Cron  = require("modules/external/Cron")
local tween = require("tween/tween") -- https://github.com/kikito/tween.lua
local utils = require("modules/utils/workspotUtils")

local coffee = {}

function coffee:new(id, interactionPosition, workspotPosition, workspotRotation)
	local o = {}

    -- Basic data
    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = "base\\gameplay\\devices\\arcade_machines\\coffee.ent" -- ent Path
    o.name = GetLocalizedText("LocKey#2061") -- Dialog name

    -- Dialog options data
    o.entryText = "[" .. GetLocalizedText("LocKey#512") .. "]"
    o.entryIcon = "ChoiceCaptionParts.UseIcon"

    -- Slide / Enter data
    o.slideTime = 0.8
    o.slideCameraRot = EulerAngles.new(0.81, -10.735, 5.85) -- Camera rot target to match animation entry
    o.slideCameraPos = Vector4.new(0, -0.185, 0, 0) -- Camera pos target to match animation entry

    o.animationDuration = 13.5

    -- World interaction data
    o.detectionAngle = 80
    o.iconRange = 3
    o.interactionRange = 1.75
    o.iconRecord = "ChoiceIcons.UseIcon"

    -- Coffee Workspot Things
    o.machineID = 52338285ULL
    o.cupID = 1282518ULL
    o.cupAttached = false

    -- Internal
    o.hub = nil
    o.callbacks = nil

    o.inWorkspot = false
    o.camTransition = nil
    o.slide = nil

    o.entityID = nil

	self.__index = self
   	return setmetatable(o, self)
end

function coffee:init() -- Setup basic info, create world interaction and hub
    world.addInteraction(self.id, self.interactionPosition, self.interactionRange, self.detectionAngle, self.iconRecord, self.iconRange, nil, function(state) -- Register world interaction
        if state then -- Show
            self:setupEntry()
            interaction.showHub()
        elseif not self.inWorkspot then -- Hide
            interaction.hideHub()
        end
    end)
end

function coffee:setupEntry() -- Entry situation
    -- Entry dialog UI:
    local choice = interaction.createChoice(self.entryText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.entryIcon))
    self.hub = interaction.createHub(self.name, {choice})
    interaction.setupHub(self.hub)

    -- Enter option Callback:
    interaction.callbacks[1] = function()
        interaction.hideHub()
        world.togglePin(world.interactions[self.id], false)
        world.interactions[self.id].hideIcon = true
        utils.toggleHUD(false)
        utils.applyStatus("GameplayRestriction.NoCombat")
        SaveLocksManager.RequestSaveLockAdd("PersonalLink")
        self.inWorkspot = true

        -- Set camera roll, yaw and position to match entry animation. Pitch has to be done differently
        local currentPitch = Vector4.new(-Game.GetCameraSystem():GetActiveCameraForward().x, -Game.GetCameraSystem():GetActiveCameraForward().y, -Game.GetCameraSystem():GetActiveCameraForward().z, -Game.GetCameraSystem():GetActiveCameraForward().w):ToRotation().pitch
        self.camTransition = tween.new(self.slideTime, {roll = 0, pitch = currentPitch, yaw = 0, x = 0, y = 0, z = 0}, {roll = self.slideCameraRot.roll, pitch = self.slideCameraRot.pitch, yaw = self.slideCameraRot.yaw, x = self.slideCameraPos.x, y = self.slideCameraPos.y, z = self.slideCameraPos.z}, tween.easing.inOutQuad)

        Game.GetPlayer():GetFPPCameraComponent():ResetPitch() -- Animation doesnt like cam pitch
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

        Cron.After(self.animationDuration, function()
            self:animationDone()
        end)
    end
end

function coffee:playSequence()
    Cron.After(1.277, function() -- Attach cup
        self.cupAttached = true
    end)

    Cron.After(2.314, function() -- Detach cup
        self.cupAttached = false
    end)

    Cron.After(2.44, function() -- Machine effect
        utils.showEffect("fx_coffee_pouring", 0, Game.FindEntityByID(entEntityID.new({hash = self.machineID})))
    end)

    Cron.After(2.535, function() -- Fill cup
        utils.showEffect("fx_coffee_filling_up", 0, Game.FindEntityByID(entEntityID.new({hash = self.cupID})))
    end)

    Cron.After(2.612, function() -- Steam cup
        utils.showEffect("fx_coffee_steam", 0, Game.FindEntityByID(entEntityID.new({hash = self.cupID})))
    end)

    Cron.After(5.244, function() -- Attach cup
        self.cupAttached = true
    end)

    Cron.After(6.922, function() -- Empty cup
        utils.showEffect("fx_coffee_emptying", 0, Game.FindEntityByID(entEntityID.new({hash = self.cupID})))
    end)

    Cron.After(7.56, function() -- Stop steam
        GameObjectEffectHelper.StopEffectEvent(Game.FindEntityByID(entEntityID.new({hash = self.cupID})), "fx_coffee_steam")
    end)

    Cron.After(9.324, function() -- Detach cup
        self.cupAttached = false
    end)

    utils.playAudio("q203_sc_01_v_puts_empty_cup", 1.251)
    utils.playAudio("q203_sc_01_coffee_machine_works", 2.536)
    utils.playAudio("q203_sc_01_v_grabs_coffee_cup", 5.341)
    utils.playAudio("q203_sc_01_v_drinks_coffee", 6.255)

    Cron.After(self.animationDuration - 2.6, function ()
        GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "reflex_buster", true, worldEffectBlackboard.new())
    end)

    utils.applyStatus("HousingStatusEffect.Energized")
end

function coffee:animationDone()
    -- Exit option Callback:
    interaction.hideHub()
    self.inWorkspot = false

    Game.GetWorkspotSystem():SendForwardSignal(GetPlayer())

    local rot = GetPlayer():GetFPPCameraComponent():GetLocalOrientation():ToEulerAngles()
    local pos = GetPlayer():GetFPPCameraComponent():GetLocalPosition()
    self.camTransition = tween.new(0.8, {roll = rot.roll, pitch = rot.pitch, yaw = rot.yaw, x = pos.x, y = pos.y, z = pos.z}, {roll = 0, pitch = 0, yaw = 0, x = 0, y = 0, z = 0}, tween.easing.inOutCubic) -- Smoothly remove custom camera rotation

    SaveLocksManager.RequestSaveLockRemove("PersonalLink")
    world.interactions[self.id].hideIcon = false
    world.interactions[self.id].shown = false -- Make sure the range check runs again
    self:setupEntry()
    exEntitySpawner.Despawn(Game.FindEntityByID(self.entityID))
    utils.toggleHUD(true)
    utils.removeStatus("GameplayRestriction.NoCombat")
end

function coffee:update(dt)
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
            Game.GetWorkspotSystem():PlayInDevice(device, GetPlayer(), "lockedCamera", "interactionWorkspot", "", "", 0) -- Enter workspot
            self.slide = nil
            self.camTransition = nil

            self:playSequence()
        else
            Game.GetTeleportationFacility():Teleport(GetPlayer(), Vector4.new(self.slide.subject.x, self.slide.subject.y, self.slide.subject.z, 0), EulerAngles.new(self.slide.subject.roll, self.slide.subject.pitch, self.slide.subject.yaw)) -- Adjust player position
        end
    end

    local cup = Game.FindEntityByID(entEntityID.new({hash = self.cupID}))
    if not cup then return end

    if self.cupAttached then
        local _, pos = GetPlayer():FindComponentByName("ItemAttachmentSlots"):GetSlotTransform("WeaponRight")
        Game.GetTeleportationFacility():Teleport(cup, pos:GetWorldPosition():ToVector4() , pos:GetOrientation():ToEulerAngles())
    end
end

return coffee