local baseInteraction = require("modules/classes/baseInteraction")

---Base class for workspot interactions
---@class workspotInteraction : baseInteraction
---@field workspotPosition Vector4
---@field workspotRotation EulerAngles
---@field workspot any
local workspotInteraction = setmetatable({}, { __index = baseInteraction })

function workspotInteraction:new()
    local o = baseInteraction.new(self)

    o.interactionType = "Workspot"
    o.workspotPosition = nil
    o.workspotRotation = nil
    o.workspot = nil

    setmetatable(o, { __index = self })
    return o
end

function workspotInteraction:init()
    -- Initialize the actual workspot implementation
    self:createWorkspot()
    if self.workspot then
        self.workspot:init()
    end
    
    -- Initialize world interaction
    baseInteraction.init(self)
end

function workspotInteraction:createWorkspot()
    -- Override in child classes to create specific workspot types
end

function workspotInteraction:update(dt)
    if self.workspot then
        self.workspot:update(dt)
    end
end

function workspotInteraction:remove()
    baseInteraction.remove(self)
    if self.workspot then
        -- Clean up workspot resources if needed
    end
end

function workspotInteraction:load(data)
    -- Call parent load first
    baseInteraction.load(self, data)
end

function workspotInteraction:save()
    local data = baseInteraction.save(self)
    return data
end

return workspotInteraction