local utils = require("modules/utils/utils")

local world = {
    interactions = {}
}

function world.addInteraction(id, position, interactionRange, angle, icon, iconRange, iconColor, callback) -- Add a in-world interaction with callback for hide / show, icon is optional
    local data = {
        id = id,
        pos = position,
        interactionRange = interactionRange,
        icon = icon,
        iconRange = iconRange,
        iconColor = iconColor,
        angle = angle,
        callback = callback,
        pinID = nil,
        shown = false,
        disabled = false,
        hideIcon = false
    }

    world.interactions[id] = data
    return id
end

function world.removeInteraction(id)
    if world.interactions[id] then
        if world.interactions[id].pinID then
            Game.GetMappinSystem():UnregisterMappin(world.interactions[id].pinID)
        end
        world.interactions[id] = nil
    end
end

function world.disableInteraction(id, state)
    if world.interactions[id] then
        world.interactions[id].disabled = state
    end
end

function world.init()
    ObserveAfter("BaseMappinBaseController", "UpdateRootState", function(this) -- Custom pin texture
        local mappin = this:GetMappin()
        if not mappin then return end
        local pos = mappin:GetWorldPosition()
        for _, interaction in pairs(world.interactions) do
            if Vector4.Distance(pos, interaction.pos) < 0.05 then
                local record = TweakDBInterface.GetUIIconRecord(interaction.icon)
                this.iconWidget:SetAtlasResource(record:AtlasResourcePath())
                this.iconWidget:SetTexturePart(record:AtlasPartName())
                this.iconWidget:SetTintColor(interaction.iconColor or HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 }))
            end
        end
    end)
end

function world.update()
    local showInteractions = {} -- Aggregate all callbacks, ensure only one interaction per ID is active
    local posPlayer = GetPlayer():GetWorldPosition()
    local playerForward = GetPlayer():GetWorldForward()
    posPlayer.z = posPlayer.z + 1

    for id, interaction in pairs(world.interactions) do
        local update = interaction.shown
        local interactionAngle = 360

        if not interaction.disabled and Vector4.Distance(posPlayer, interaction.pos) < interaction.interactionRange then
            interactionAngle = 180 - Vector4.GetAngleBetween(playerForward, Vector4.new(posPlayer.x - interaction.pos.x, posPlayer.y - interaction.pos.y, posPlayer.z - interaction.pos.z, 0))

            if interactionAngle < interaction.angle then
                update = true
            else
                update = false
            end
        else
            update = false
        end

        -- Quest compatibility check
        if update then
            local isQuest = false
            pcall(function()
                local questName = Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetTrackedEntry())):GetTitle(Game.GetJournalManager())
                if questName and questName == "LocKey#9308" then isQuest = true end
            end)
            if isQuest then update = false end
        end

        -- Update interaction state
        if update ~= interaction.shown then
            interaction.shown = update
            interaction.callback(interaction.shown)
        end

        -- Manage world icons
        if not interaction.disabled and interaction.icon and Vector4.Distance(posPlayer, interaction.pos) < interaction.iconRange then
            if not interaction.pinID then
                world.togglePin(interaction, true)
            end
        elseif interaction.pinID and interaction.icon then
            world.togglePin(interaction, false)
        end
    end
end

function world.togglePin(interaction, state)
    if not interaction.icon or interaction.hideIcon then return end
    if not state and interaction.pinID then
        Game.GetMappinSystem():UnregisterMappin(interaction.pinID)
        interaction.pinID = nil
        return
    elseif not interaction.pinID and state then
        local data = MappinData.new({ mappinType = 'Mappins.DefaultStaticMappin', variant = gamedataMappinVariant.UseVariant, visibleThroughWalls = false })
        interaction.pinID = Game.GetMappinSystem():RegisterMappin(data, interaction.pos)
    end
end

function world.updateInteractionPosition(id, position)
    if world.interactions[id] then
        world.interactions[id].pos = position
        if world.interactions[id].pinID then
            Game.GetMappinSystem():SetMappinPosition(world.interactions[id].pinID, position)
        end
    end
end

function world.onSessionStart() -- Save loaded, all pins are gone
    for _, interaction in pairs(world.interactions) do
        interaction.shown = false
        interaction.pinID = nil
    end
end

function world.shutdown()
    for _, interaction in pairs(world.interactions) do
        if interaction.pinID then
            Game.GetMappinSystem():UnregisterMappin(interaction.pinID)
        end
    end
    world.interactions = {}
end

--Fix to make sure all icons are visible, to fix bug where after a scene some would be missing
function world.forceIcons()
    for _, interaction in pairs(world.interactions) do
        if interaction.pinID then
            Game.GetMappinSystem():UnregisterMappin(interaction.pinID)
            local data = MappinData.new({ mappinType = 'Mappins.DefaultStaticMappin', variant = gamedataMappinVariant.UseVariant, visibleThroughWalls = false })
            interaction.pinID = Game.GetMappinSystem():RegisterMappin(data, interaction.pos)
        end
    end
end

return world