local Events = {}

function Events.new(logger)
  local listeners = {}
  local tokenToEvent = {}
  local nextToken = 1

  local bus = {}

  function bus.subscribe(eventName, callback)
    if type(eventName) ~= "string" or eventName == "" then
      return nil, "Event name must be a non-empty string."
    end
    if type(callback) ~= "function" then
      return nil, "Event callback must be a function."
    end

    local token = nextToken
    nextToken = nextToken + 1
    listeners[eventName] = listeners[eventName] or {}
    listeners[eventName][token] = callback
    tokenToEvent[token] = eventName
    return token, nil
  end

  function bus.unsubscribe(token)
    local eventName = tokenToEvent[token]
    if eventName == nil then
      return false, "Unknown subscription token."
    end

    if listeners[eventName] ~= nil then
      listeners[eventName][token] = nil
    end
    tokenToEvent[token] = nil
    return true, nil
  end

  function bus.emit(eventName, payload)
    local eventListeners = listeners[eventName]
    if eventListeners == nil then
      return 0
    end

    local pending = {}
    for token, callback in pairs(eventListeners) do
      pending[#pending + 1] = { token = token, callback = callback }
    end

    local delivered = 0
    for _, listener in ipairs(pending) do
      if tokenToEvent[listener.token] == eventName then
        local ok, err = pcall(listener.callback, payload, eventName)
        if ok then
          delivered = delivered + 1
        elseif logger ~= nil then
          logger.warn(string.format("Event '%s' callback failed: %s", eventName, tostring(err)))
        end
      end
    end

    return delivered
  end

  function bus.clear()
    listeners = {}
    tokenToEvent = {}
  end

  return bus
end

return Events
