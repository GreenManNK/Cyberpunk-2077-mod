local lang = require("modules/utils/lang")

local rail = {}

function rail:new(id, interactionPosition, workspotPosition, workspotRotation)
	local o = {}

    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = "base\\gameplay\\devices\\arcade_machines\\rail_lean.ent"
    o.name = GetLocalizedText("LocKey#37794")
    o.iconRecord = "ChoiceIcons.SitIcon"

    o.entryText = "[" .. lang.getText(lang.lean) .. "]"
    o.entryIcon = "ChoiceCaptionParts.SitIcon"
    o.exitText = "[" .. GetLocalizedText("LocKey#37918") .. "]"
    o.exitIcon = "ChoiceCaptionParts.GetUpIcon"

    o.iconRange = 3.25

    o.slideTime = 0.7
    o.slideCameraRot = EulerAngles.new(0, 0, 0)
    o.slideCameraPos = Vector4.new(0, 0, 0, 0)
    o.workspotCameraRot = EulerAngles.new(3, 0, 0)

    o.entryTime = 5
    o.exitTime = 3.8

    o.maxPitch = 55
    o.minPitch = -30
    o.maxYaw = 48
    o.minYaw = -40

    o.rollDynamicMult = -0.34

    o.enterSounds = {
        {name = "q203_sc_01_v_leans_on_railing", delay = 0.3}
    }

    o.exitSounds = {
        {name = "q203_sc_01_v_leans_off_railing", delay = 0.05}
    }

    o.workspot = nil

	self.__index = self
   	return setmetatable(o, self)
end

function rail:init()
    self.workspot = require("modules/workspots/template/sitWorkspot"):new(self.id, self.interactionPosition, self.workspotPosition, self.workspotRotation)
    self.workspot.devicePath = self.devicePath
    self.workspot.name = self.name
    self.workspot.entryText = self.entryText
    self.workspot.entryIcon = self.entryIcon
    self.workspot.exitText =self.exitText
    self.workspot.exitIcon = self.exitIcon
    self.workspot.slideTime = self.slideTime
    self.workspot.entryTime = self.entryTime
    self.workspot.exitTime = self.exitTime
    self.workspot.workspot = self.workspot
    self.workspot.maxPitch = self.maxPitch
    self.workspot.minPitch = self.minPitch
    self.workspot.maxYaw = self.maxYaw
    self.workspot.minYaw = self.minYaw
    self.workspot.iconRange = self.iconRange
    self.workspot.slideBlink = false
    self.workspot.slideCameraRot = self.slideCameraRot
    self.workspot.slideCameraPos = self.slideCameraPos
    self.workspot.workspotCameraRot = self.workspotCameraRot
    self.workspot.enterSounds = self.enterSounds
    self.workspot.exitSounds = self.exitSounds
    self.workspot.rollDynamicMult = self.rollDynamicMult
    self.workspot.iconRecord = self.iconRecord
    self.workspot:init()
end

function rail:update(dt)
    self.workspot:update(dt)
end

return rail