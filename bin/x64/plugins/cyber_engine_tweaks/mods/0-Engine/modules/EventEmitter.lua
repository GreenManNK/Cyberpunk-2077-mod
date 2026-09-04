-- EventEmitter.lua - subscribe/trigger with pcall-guarded dispatch

local Logger = require('modules/Logger')

local EventEmitter = { version = '0.0.4' }
EventEmitter.__index = EventEmitter

local function getSourceLabel(fn)
    if type(fn) ~= "function" then return "unknown" end
    if not debug or not debug.getinfo then return "unknown" end
    local ok, info = pcall(debug.getinfo, fn, "S")
    if not ok or not info or not info.source then return "unknown" end
    local modName = info.source:match("[/\\]mods[/\\]([^/\\]+)")
    if modName then return modName end
    return info.short_src or "unknown"
end

---Creates a new EventEmitter instance
---@return table
function EventEmitter.new()
    local self = setmetatable({}, EventEmitter)
    self.listeners = {}
    self.listenerSources = {}
    self._firing = false
    self._dirty = false
    return self
end

---Subscribes a callback to the event
---@param callback function
---@param source string|nil explicit source label (overrides debug.getinfo detection)
---@return table Handle with unsubscribe method
function EventEmitter:subscribe(callback, source)
    if type(callback) ~= "function" then
        Logger.Log("0-Engine", "EventEmitter: Attempted to subscribe with non-function", "warn")
        return { unsubscribe = function() end }
    end

    table.insert(self.listeners, callback)
    table.insert(self.listenerSources, source or getSourceLabel(callback))

    return {
        unsubscribe = function()
            for i, listener in ipairs(self.listeners) do
                if listener == callback then
                    if self._firing then
                        self.listeners[i] = nil
                        self.listenerSources[i] = nil
                        self._dirty = true
                    else
                        table.remove(self.listeners, i)
                        table.remove(self.listenerSources, i)
                    end
                    break
                end
            end
        end
    }
end

---Triggers the event, calling all subscribers with provided arguments
---@vararg any Arguments to pass to subscribers
function EventEmitter:trigger(...)
    local listeners = self.listeners
    local n = #listeners
    if n == 0 then return end

    self._firing = true
    for i = 1, n do
        local listener = listeners[i]
        if listener then
            local success, err = pcall(listener, ...)
            if not success then
                Logger.Log("0-Engine", "EventEmitter: Error in listener: " .. tostring(err), "error")
            end
        end
    end
    self._firing = false

    if self._dirty then
        self._dirty = false
        local sources = self.listenerSources
        local j = 0
        for i = 1, #listeners do
            if listeners[i] then
                j = j + 1
                listeners[j] = listeners[i]
                sources[j] = sources[i]
            end
        end
        for i = j + 1, #listeners do
            listeners[i] = nil
            sources[i] = nil
        end
    end
end

---Returns the number of active listeners
---@return number
function EventEmitter:getListenerCount()
    return #self.listeners
end

---Returns source labels for all active listeners
---@return string[]
function EventEmitter:getListenerSources()
    local result = {}
    for i = 1, #self.listenerSources do
        result[i] = self.listenerSources[i]
    end
    return result
end

return EventEmitter