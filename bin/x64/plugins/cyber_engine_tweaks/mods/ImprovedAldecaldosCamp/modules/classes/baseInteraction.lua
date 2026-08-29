local world = require("modules/utils/worldInteraction")

---Base class for modern IAC interactions
---@class baseInteraction
---@field id number
---@field interactionPosition Vector4
---@field interactionType string
---@field name string
---@field worldIcon string
---@field worldIconRange number
---@field interactionAngle number
---@field interactionRange number
---@field worldInteractionID number?
---@field enabled boolean
local baseInteraction = {}

function baseInteraction:new()
    local o = {}

    -- Default values - will be overridden by load()
    o.id = nil
    o.interactionPosition = nil
    o.interactionType = "Base Interaction"
    o.name = "Default Interaction"
    o.worldIcon = "ChoiceIcons.SitIcon"
    o.worldIconRange = 5
    o.interactionAngle = 80
    o.interactionRange = 1.5
    o.worldInteractionID = nil
    o.enabled = true

    self.__index = self
    return setmetatable(o, self)
end

function baseInteraction:init()
    -- Base classes don't register directly with world
    -- Child classes handle their own registration via workspots/devices
end

function baseInteraction:onStart()
    -- Override in child classes
end

function baseInteraction:onStop()
    -- Override in child classes
end

function baseInteraction:update(dt)
    -- Override in child classes
end

function baseInteraction:remove()
    self.enabled = false
    if self.worldInteractionID then
        -- Disable the interaction in world system
        world.interactions[self.worldInteractionID].disabled = true
    end
end

function baseInteraction:load(data)
    -- Apply all data properties to the interaction
    for key, value in pairs(data) do
        if key == "worldIconPosition" then
            -- Convert table to Vector4
            self.interactionPosition = Vector4.new(value.x, value.y, value.z, value.w)
        else
            self[key] = value
        end
    end
end

function baseInteraction:save()
    return {
        id = self.id,
        interactionType = self.interactionType,
        name = self.name,
        worldIconPosition = {
            x = self.interactionPosition.x,
            y = self.interactionPosition.y,
            z = self.interactionPosition.z,
            w = self.interactionPosition.w
        },
        worldIconRange = self.worldIconRange,
        interactionAngle = self.interactionAngle,
        interactionRange = self.interactionRange,
        enabled = self.enabled
    }
end

function baseInteraction:sessionStart()
    -- Override in child classes if needed
end

function baseInteraction:sessionEnd()
    -- Override in child classes if needed
end

return baseInteraction