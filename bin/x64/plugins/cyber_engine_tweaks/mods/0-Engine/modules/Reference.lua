-- Reference.lua - callable value holder (ref() returns value, ref:set(v) stores)

local Reference = { version = '0.0.2' }
Reference.__index = Reference

---Makes the instance callable to get the value
---@return any
Reference.__call = function(self)
    return self.value
end

---Sets the value of the reference
---@param value any
function Reference:set(value)
    self.value = value
end

---Gets the value of the reference
---@return any
function Reference:get()
    return self.value
end

---Creates a new Reference instance
---@param initialValue any
---@return table
local function new(initialValue)
    local self = setmetatable({}, Reference)
    self.value = initialValue
    return self
end

return new