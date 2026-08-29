local couch = {}

function couch:new(id, interactionPosition, workspotPosition, workspotRotation)
	local o = {}

    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = "base\\gameplay\\devices\\arcade_machines\\couch_rh.ent"
    o.name = GetLocalizedText("LocKey#39254")

    o.entryText = "[" .. GetLocalizedText("LocKey#39287") .. "]"
    o.entryIcon = "ChoiceCaptionParts.SitIcon"
    o.exitText = "[" .. GetLocalizedText("LocKey#37918") .. "]"
    o.exitIcon = "ChoiceCaptionParts.GetUpIcon"

    o.iconRange = 4

    o.slideTime = 1.2
    o.slideCameraRot = EulerAngles.new(1.5, -37, -0.14)
    o.slideCameraPos = Vector4.new(0, -0.17, 0, 0)
    o.workspotCameraRot = EulerAngles.new(2.5, 0, 0)

    o.entryTime = 6.75
    o.exitTime = 3.3

    o.maxPitch = 55
    o.minPitch = -33
    o.maxYaw = 55
    o.minYaw = -40

    o.enterSounds = {
        {name = "sq021_sc_05_v_sits", delay = 0.1},
        {name = "q005_sc_02_v_sits", delay = 1.85}
    }

    o.exitSounds = {
        {name = "sq030_sc_10_bathroom_v_stands_up", delay = 0.2},
        {name = "sq032_sc_07_v_stands_up_02", delay = 0.2},
        {name = "sq030_sc_09_pier_v_stands_up", delay = 0.2},
        {name = "sq028_sc_04_v_stands", delay = 0.2},
    }

    o.workspot = nil

	self.__index = self
   	return setmetatable(o, self)
end

function couch:init()
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
    self.workspot.slideCameraRot = self.slideCameraRot
    self.workspot.slideCameraPos = self.slideCameraPos
    self.workspot.workspotCameraRot = self.workspotCameraRot
    self.workspot.enterSounds = self.enterSounds
    self.workspot.exitSounds = self.exitSounds
    self.workspot:init()
end

function couch:update(dt)
    self.workspot:update(dt)
end

return couch