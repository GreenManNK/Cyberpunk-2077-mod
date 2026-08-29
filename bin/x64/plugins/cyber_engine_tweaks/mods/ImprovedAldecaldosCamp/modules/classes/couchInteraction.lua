local workspotInteraction = require("modules/classes/workspotInteraction")
local localized = require("modules/utils/localizedText")

---Class for couch interaction
---@class couchInteraction : workspotInteraction
local couchInteraction = setmetatable({}, { __index = workspotInteraction })

function couchInteraction:new()
    local o = workspotInteraction.new(self)

    -- Set couch-specific defaults
    o.interactionType = "Couch"
    o.name = localized.object.seat
    o.worldIcon = "ChoiceIcons.SitIcon"
    o.worldIconRange = 1.5
    o.interactionAngle = 80
    o.interactionRange = 1.5

    setmetatable(o, { __index = self })
    return o
end

function couchInteraction:createWorkspot()
    -- Create the actual couch workspot using the existing system
    self.workspot = require("modules/workspots/couchWorkspot"):new(
        self.id, 
        self.interactionPosition, 
        self.workspotPosition, 
        self.workspotRotation
    )
    
    -- Apply our settings to the workspot
    self.workspot.iconRange = self.worldIconRange
    self.workspot.name = self.name
end

function couchInteraction:load(data)
    -- Call parent load first
    workspotInteraction.load(self, data)
    
    -- Convert workspot position and rotation from data
    if data.workspotPosition then
        self.workspotPosition = Vector4.new(
            data.workspotPosition.x, 
            data.workspotPosition.y, 
            data.workspotPosition.z, 
            data.workspotPosition.w
        )
    end
    
    if data.workspotRotation then
        self.workspotRotation = EulerAngles.new(
            data.workspotRotation.roll,
            data.workspotRotation.pitch,
            data.workspotRotation.yaw
        )
    end
end

function couchInteraction:save()
    local data = workspotInteraction.save(self)
    data.interactionType = "Couch"
    data.modulePath = "classes/couchInteraction"
    data.workspotPosition = {
        x = self.workspotPosition.x,
        y = self.workspotPosition.y,
        z = self.workspotPosition.z,
        w = self.workspotPosition.w
    }
    data.workspotRotation = {
        roll = self.workspotRotation.roll,
        pitch = self.workspotRotation.pitch,
        yaw = self.workspotRotation.yaw
    }
    return data
end

return couchInteraction