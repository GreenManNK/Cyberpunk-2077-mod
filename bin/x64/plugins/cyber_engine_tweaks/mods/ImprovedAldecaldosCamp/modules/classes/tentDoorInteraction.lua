local deviceInteraction = require("modules/classes/deviceInteraction")
local localized = require("modules/utils/localizedText")

---Class for tent door interaction
---@class tentDoorInteraction : deviceInteraction
---@field swapOnVariant string
---@field swapOffVariant string
local tentDoorInteraction = setmetatable({}, { __index = deviceInteraction })

function tentDoorInteraction:new()
    local o = deviceInteraction.new(self)

    o.interactionType = "Tent Door"
    o.name = localized.object.overture
    o.worldIcon = "ChoiceIcons.InteractionDoorsIcon"
    o.worldIconRange = 2.5
    o.interactionAngle = 360
    o.interactionRange = 1.5
    o.swapOnVariant = nil
    o.swapOffVariant = nil

    setmetatable(o, { __index = self })
    return o
end

function tentDoorInteraction:createDevice()
    -- Create the actual tent door device using the existing system
    self.device = require("modules/devices/tentDoorDevice"):new(
        self.id, 
        self.interactionPosition, 
        self.swapOnVariant, 
        self.swapOffVariant
    )
    
    -- Apply our settings to the device
    self.device.iconRange = self.worldIconRange
end

function tentDoorInteraction:load(data)
    -- Call parent load first
    deviceInteraction.load(self, data)
    
    -- Apply tent door specific data
    if data.swapOnVariant then
        self.swapOnVariant = data.swapOnVariant
    end
    if data.swapOffVariant then
        self.swapOffVariant = data.swapOffVariant
    end
end

function tentDoorInteraction:save()
    local data = deviceInteraction.save(self)
    data.interactionType = "TentDoor"
    data.modulePath = "classes/tentDoorInteraction"
    data.swapOnVariant = self.swapOnVariant
    data.swapOffVariant = self.swapOffVariant
    return data
end

return tentDoorInteraction