local bench = {}

function bench:new(id, interactionPosition, workspotPosition, workspotRotation)
	local o = {}

    o.id = id
    o.interactionPosition = interactionPosition
    o.workspotPosition = workspotPosition
    o.workspotRotation = workspotRotation

    o.devicePath = "base\\gameplay\\devices\\arcade_machines\\bench_lap.ent"
    o.name = GetLocalizedText("LocKey#38190")

    o.entryText = "[" .. GetLocalizedText("LocKey#39287") .. "]"
    o.entryIcon = "ChoiceCaptionParts.SitIcon"
    o.exitText = "[" .. GetLocalizedText("LocKey#37918") .. "]"
    o.exitIcon = "ChoiceCaptionParts.GetUpIcon"

    o.iconRange = 4
    o.interactionRange = 1.75

    o.slideTime = 1.2

    o.entryTime = 5.2
    o.exitTime = 4

    o.maxPitch = 55
    o.minPitch = -33
    o.maxYaw = 55
    o.minYaw = -40

    o.slideCameraRot = EulerAngles.new(1.2, 2, 1.05)
    o.slideCameraPos = Vector4.new(0, 0.05, 0.1, 0)

    o.workspotCameraRot = EulerAngles.new(2.55, 0, 0)
    o.workspotCameraPos = Vector4.new(0, 0, 0, 0)
    o.rollDynamicMult = -0.32 -- Adjust camera roll with yaw

    o.enterSounds = {
        {name = "sq032_sc_04_v_sits", delay = 1.7},
        {name = "q105_sc_03a_v_sit_down", delay = 1.7},
        {name = "q112_sc_01_v_sits_on_bench", delay = 1.9},
        {name = "sq029_04a_tower_v_sits_down", delay = 1.7},
    }

    o.exitSounds = {
        {name = "sq030_sc_10_bathroom_v_stands_up", delay = 0.15},
        {name = "sq030_sc_09_pier_v_stands_up", delay = 0.15},
        {name = "sq028_sc_04_v_stands", delay = 0.15}
    }

    o.workspot = nil

	self.__index = self
   	return setmetatable(o, self)
end

function bench:init()
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
    self.workspot.interactionRange = self.interactionRange
    self.workspot.rollDynamicMult = self.rollDynamicMult
    self.workspot.slideCameraRot = self.slideCameraRot
    self.workspot.slideCameraPos = self.slideCameraPos
    self.workspot.workspotCameraRot = self.workspotCameraRot
    self.workspot.workspotCameraPos = self.workspotCameraPos
    self.workspot.enterSounds = self.enterSounds
    self.workspot.exitSounds = self.exitSounds
    self.workspot:init()
end

function bench:update(dt)
    self.workspot:update(dt)
end

return bench