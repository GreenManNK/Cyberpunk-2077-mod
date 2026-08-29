local baseInteraction = require("modules/classes/baseInteraction")

---Base class for device interactions
---@class deviceInteraction : baseInteraction
---@field device any
local deviceInteraction = setmetatable({}, { __index = baseInteraction })

function deviceInteraction:new()
    local o = baseInteraction.new(self)

    o.interactionType = "Device"
    o.device = nil

    setmetatable(o, { __index = self })
    return o
end

function deviceInteraction:init()
    -- Initialize the actual device implementation
    self:createDevice()
    if self.device then
        self.device:init()
    end
    
    -- Initialize world interaction
    baseInteraction.init(self)
end

function deviceInteraction:createDevice()
    -- Override in child classes to create specific device types
end

function deviceInteraction:update(dt)
    -- Most devices don't need update - they handle interaction callbacks
    -- Only call update if the device actually implements it
    if self.device and type(self.device.update) == "function" then
        self.device:update(dt)
    end
end

function deviceInteraction:remove()
    baseInteraction.remove(self)
    if self.device then
        -- Clean up device resources if needed
    end
end

function deviceInteraction:load(data)
    -- Call parent load first
    baseInteraction.load(self, data)
end

function deviceInteraction:save()
    local data = baseInteraction.save(self)
    return data
end

return deviceInteraction