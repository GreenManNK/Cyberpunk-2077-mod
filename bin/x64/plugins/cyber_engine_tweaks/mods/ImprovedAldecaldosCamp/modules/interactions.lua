local interactionManager = require("modules/interactionManager")

local interactions = {
    workspots = {},
    modernInteractions = {},
    inRange = false,
    manager = interactionManager
}

function interactions.setupInteractions() -- Setup interactions using modern system
    --local localized = require("modules/utils/localizedText")

    -- Initialize the interaction manager
    interactions.manager.init(interactions)
    
    -- Setup all interactions from configuration
    interactions.manager.setupInteractions()

    -- Legacy workspots (commented out, now handled by manager)
    -- local bed = require("modules/workspots/sleepWorkspot"):new(4, Vector4.new(1781.99, 2231.08, 182.76, 0.0), Vector4.new(1781.88, 2231.39, 182.35, 0.0), EulerAngles.new(0, 0, 80))
    -- bed.iconRange = 1.5
    -- bed:init()
    -- table.insert(interactions.workspots, bed)

    -- local livingTruckCouch = require("modules/workspots/couchWorkspot"):new(6, Vector4.new(1782.02, 2235.00, 180.51, 0.0), Vector4.new(1782.06, 2235.06, 180.06, 0.0), EulerAngles.new(0, 0, 160))
    -- livingTruckCouch.iconRange = 1.5
    -- livingTruckCouch.name = localized.object.chair
    -- livingTruckCouch:init()
    -- table.insert(interactions.workspots, livingTruckCouch)

    -- local truckSit = require("modules/workspots/sitGroundWorkspot"):new(9, Vector4.new(1782.23, 2254.43, 184.97, 0.0), Vector4.new(1782.23, 2254.43, 184.72, 0.0), EulerAngles.new(0, 0, 90))
    -- truckSit.iconRange = 3
    -- truckSit:init()
    -- table.insert(interactions.workspots, truckSit)
end



function interactions.init() -- Runs once onInit
    -- logic.setupVariables()

    -- Cron.Every(1, function()
    --     logic.checkInRange()
    -- end)
end


function interactions.onSessionStart()
    -- On session start logic
    interactions.manager.sessionStart()
end

function interactions.onSessionEnd()
    -- On session end logic
    interactions.manager.sessionEnd()
end

function interactions.shutdown()
    -- Cleanup logic
    interactions.manager.shutdown()
end

function interactions.update(dt)
    -- Update legacy workspots
    for _, spot in pairs(interactions.workspots) do
        spot:update(dt)
    end
    
    -- Update modern interactions via manager
    interactions.manager.update()
end

return interactions