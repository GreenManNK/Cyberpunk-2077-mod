local utils = require("ui/helpers/utils")

local relay = {}
relay.subscribers = {}
relay.initialized = false

local function findByController(ec)
    for _, sub in ipairs(relay.subscribers) do
        if utils.isSameInstance(sub.eventCatcher, ec) then
            return sub
        end
    end
    return nil
end

function relay.init()
    if relay.initialized then return end
    relay.initialized = true
    Observe("sampleStyleManagerGameController", "OnStyle1", function(self, evt)
        local sub = findByController(self)
        if sub and sub.hoverInCallback then sub:hoverInCallback(evt:GetTarget()) end
    end)

    Observe("sampleStyleManagerGameController", "OnStyle2", function(self, evt)
        local sub = findByController(self)
        if sub and sub.hoverOutCallback then sub:hoverOutCallback(evt:GetTarget()) end
    end)

    Observe("sampleStyleManagerGameController", "OnState1", function(self, evt)
        if not evt:IsAction("click") then return end
        local sub = findByController(self)
        if sub and sub.clickCallback then sub:clickCallback(evt:GetTarget()) end
    end)
end

function relay.removeSubscriber(sub)
    utils.removeItem(relay.subscribers, sub)
end

return relay
