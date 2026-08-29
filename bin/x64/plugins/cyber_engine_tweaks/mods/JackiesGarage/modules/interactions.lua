local interactions = {
    workspots = {}
}

function interactions.setupInteractions() -- Setup workspots
    local localized = require("modules/utils/localizedText")

    local wardrobe = require("modules/devices/wardrobeDevice"):new(1, Vector4.new(-1176.22, -996.12, 14.32, 0.0))
    wardrobe.iconRange = 1
    wardrobe.interactionRange = 0.5
    wardrobe:init()
	
    local sleepBed = require("modules/workspots/sleepWorkspot"):new(2, Vector4.new(-1173.84, -996.67, 13.45, 0.0), Vector4.new(-1173.90, -996.35, 13.10, 0.0), EulerAngles.new(0, 0, 108.11))
    sleepBed.iconRange = 1.5
    sleepBed:init()
    table.insert(interactions.workspots, sleepBed)
	
end



function interactions.init() -- Runs once onInit
end


function interactions.onSessionStart() -- On session start logic
end


function interactions.update(dt)
    for _, spot in pairs(interactions.workspots) do
        spot:update(dt)
    end
end

return interactions