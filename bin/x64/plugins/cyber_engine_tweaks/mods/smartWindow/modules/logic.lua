local catcher = require("modules/eventCatcher")
local Cron = require("modules/external/Cron")

logic = {
    controllers = {},
    windowIDs = {},
    windowData = {}
}

function logic.init()
    catcher.init()

    ObserveAfter("SmartWindowInkGameController", "OnInitialize", function(this)
        local data = this:GetOwner():FindComponentByName("e3_smart_window")
        if not data then return end
        if logic.controllers[this:GetOwner():GetEntityID().hash] then return end

        -- Property mappings (e3_smart_window component):
        --      debugExposeQuickHacks: acceptDismemberment
        --      locationName: visibilityAnimationParam
        --      radioID: renderingPlaneAnimationParam
        --      shutterIDs: tags

        local windowData = {
            noBG = data.acceptDismemberment,
            locationName = data.visibilityAnimationParam.value,
            radioID = 0,
            shutterIDs = {}
        }

        if data.renderingPlaneAnimationParam.value ~= "None" then
            windowData.radioID = loadstring("return " .. data.renderingPlaneAnimationParam.value .. "ULL", "")()
        end

        for _, entry in pairs(data.tags.tags) do
            if entry.value ~= "None" then
                table.insert(windowData.shutterIDs, loadstring("return " .. entry.value .. "ULL", "")())
            end
        end

        local controller = require("modules/smartWindow"):new(this, catcher, windowData.shutterIDs, windowData.radioID, windowData.locationName, windowData.noBG)
        controller:initialize()

        logic.controllers[this:GetOwner():GetEntityID().hash] = controller
    end)

    Override("WindowBlindersControllerPS", "IsNonInteractive", function(this, wrapped)
        for _, controller in pairs(logic.controllers) do
            for _, id in pairs(controller.shutterIDs) do
                if this:GetMyEntityID().hash == id then
                    return true
                end
            end
        end

        return wrapped()
    end)
end

return logic