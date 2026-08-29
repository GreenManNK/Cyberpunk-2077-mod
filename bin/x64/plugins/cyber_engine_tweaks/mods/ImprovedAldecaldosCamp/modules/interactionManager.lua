local config = require("modules/utils/config")
local utils = require("modules/utils/utils")

---@class interactionManager
---@field interactions baseInteraction[]
---@field mod any?
local manager = {
    interactions = {},
    mod = nil
}

function manager.init(mod)
    manager.mod = mod
    manager.loadConfiguration()
end

function manager.loadConfiguration()
    -- Try to load existing configuration
    local configPath = "iac_interactions.json"
    if config.fileExists(configPath) then
        local data = config.loadFile(configPath)
        manager.loadInteractionsFromData(data)
    else
        -- Create default configuration
        manager.createDefaultConfiguration()
    end
end

function manager.createDefaultConfiguration()
    local defaultInteractions = {
        { -- New tent couch
            id = 'IAC-5',
            interactionType = "Couch",
            modulePath = "classes/couchInteraction",
            worldIconPosition = {x = 1803.76, y = 2260.53, z = 180.74, w = 0.0},
            workspotPosition = {x = 1803.76, y = 2260.53, z = 180.34, w = 0.0},
            workspotRotation = {roll = 0, pitch = 0, yaw = 160},
            worldIconRange = 1.5,
            interactionAngle = 80,
            interactionRange = 1.5,
            enabled = true
        },
        { -- V tent door
            id = 'IAC-10',
            interactionType = "TentDoor",
            modulePath = "classes/tentDoorInteraction",
            worldIconPosition = {x = 1791.62, y = 2249.87, z = 182.35, w = 0.0},
            swapOnVariant = "iac_v_tent_close",
            swapOffVariant = "iac_v_tent_open",
            worldIconRange = 2.5,
            interactionAngle = 360,
            interactionRange = 1.5,
            enabled = true
        }
    }

    local configData = {
        name = "Improved Aldecaldos Camp Interactions",
        enabled = true,
        interactions = defaultInteractions
    }

    config.saveFile("iac_interactions.json", configData)
    manager.loadInteractionsFromData(configData)
end

function manager.loadInteractionsFromData(data)
    manager.interactions = {}

    if not data.interactions then return end

    for _, interactionData in pairs(data.interactions) do
        if interactionData.enabled then
            local interaction = manager.createInteraction(interactionData)
            if interaction then
                table.insert(manager.interactions, interaction)
            end
        end
    end
end

function manager.createInteraction(data)
    local success, interaction = pcall(function()
        local interaction = nil
        if data.interactionType == "Couch" then
            interaction = require("modules/classes/couchInteraction"):new()
        elseif data.interactionType == "TentDoor" then
            interaction = require("modules/classes/tentDoorInteraction"):new()
        end

        if interaction ~= nil then
            interaction:load(data)
        end

        return interaction
    end)

    if success then
        return interaction
    else
        print("[IAC] Failed to create interaction: " .. (data.name or "Unknown") .. " - " .. tostring(interaction))
        return nil
    end
end

function manager.setupInteractions()
    for _, interaction in pairs(manager.interactions) do
        interaction:init()
    end
end

function manager.update(dt)
    for _, interaction in pairs(manager.interactions) do
        interaction:update(dt)
    end
end

function manager.sessionStart()
    for _, interaction in pairs(manager.interactions) do
        if interaction.sessionStart then
            interaction:sessionStart()
        end
    end
end

function manager.sessionEnd()
    for _, interaction in pairs(manager.interactions) do
        if interaction.sessionEnd then
            interaction:sessionEnd()
        end
    end
end

function manager.shutdown()
    for _, interaction in pairs(manager.interactions) do
        interaction:remove()
    end
    manager.interactions = {}
end

---@param interaction baseInteraction
function manager.addInteraction(interaction)
    table.insert(manager.interactions, interaction)
    manager.saveConfiguration()
end

---@param interaction baseInteraction
function manager.removeInteraction(interaction)
    interaction:remove()
    utils.removeItem(manager.interactions, interaction)
    manager.saveConfiguration()
end

function manager.saveConfiguration()
    local configData = {
        name = "Improved Aldecaldos Camp Interactions",
        enabled = true,
        interactions = {}
    }

    for _, interaction in pairs(manager.interactions) do
        local data = interaction:save()
        if data then
            table.insert(configData.interactions, data)
        end
    end

    config.saveFile("iac_interactions.json", configData)
end

return manager
