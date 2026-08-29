local catcher = require("modules/eventCatcher")
local utils = require("modules/utils/utils")
local windowPath = "base\\gameplay\\devices\\masters\\smart_house\\e3_window.ent"

logic = {
    controllers = {},
    windowIDs = {},
    windowData = {}
}

function logic.init()
    catcher.init()

    ObserveAfter("SmartWindowInkGameController", "InitializeMainLayout", function(this)
        for _, c in pairs(logic.controllers) do
            if utils.isSameInstance(this:GetOwner(), c.window) then
                return
            end
        end

        local windowData = {}
        for _, data in pairs(logic.windowData) do
            if this:GetOwner():GetWorldPosition():Distance(Vector4.new(data.pos.x, data.pos.y, data.pos.z, 0)) < 0.1 then
                windowData = data
            end
        end

        --local controller = require("modules/smartWindow"):new(this, catcher, {}, 0ULL, "", false)
        local controller = require("modules/smartWindow"):new(this, catcher, windowData.shutterIDs, windowData.radioID, windowData.locationName, windowData.noBG, windowData.pos, windowData.rot)
        controller:initialize()

        table.insert(logic.controllers, {controller = controller, window = this:GetOwner()})
    end)

    ObserveBefore("SmartWindowInkGameController", "OnUninitialize", function(this)
        for key, c in pairs(logic.controllers) do
            if utils.isSameInstance(this:GetOwner(), c.window) then
                c.controller:uninit()
                logic.controllers[key] = nil
            end
        end
    end)

    Override("WindowBlindersControllerPS", "IsNonInteractive", function(this, wrapped)
        for _, data in pairs(logic.windowData) do
            for _, id in pairs(data.shutterIDs) do
                if this:GetMyEntityID().hash == id then
                    return true
                end
            end
        end

        return wrapped()
    end)
end

function logic.sessionStart() -- Spawn windows
    for _, file in pairs(dir("windows")) do
        if file.name:match("^.+(%..+)$") == ".lua" then
            local name = file.name:match("(.+)%..+$")
            local data = require("windows/" .. name)

            local transform = Game.GetPlayer():GetWorldTransform()
            transform:SetOrientation(EulerAngles.new(data.rot.roll, data.rot.pitch, data.rot.yaw):ToQuat())
            transform:SetPosition(Vector4.new(data.pos.x, data.pos.y, data.pos.z, 0))
            local id = exEntitySpawner.Spawn(windowPath, transform)
            table.insert(logic.windowIDs, id)
            table.insert(logic.windowData, data)
        end
    end
end

function logic.sessionEnd() -- Despawn windows
    for _, id in pairs(logic.windowIDs) do
        local window = Game.FindEntityByID(id)
        if window then
            window:Dispose()
        end
    end
    logic.windowIDs = {}
    logic.windowData = {}
end

return logic