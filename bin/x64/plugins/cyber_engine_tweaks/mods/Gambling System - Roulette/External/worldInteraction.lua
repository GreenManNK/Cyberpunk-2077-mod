--=========================
-- worldInteraction.lua by keanuwheeze
-- a few line edits by Boe6, marked 
--=========================
local world = {
    interactions = {}
}

local utils = require("External/workspotUtils.lua")

--added iconRangeMin by boe6
function world.addInteraction(id, position, interactionRange, angle, icon, iconRange, iconRangeMin, iconColor, callback) -- Add a in-world interaction with callback for hide / show, icon is optional
    world.interactions[id] = {pos = position, interactionRange = interactionRange, icon = icon, iconRange = iconRange, iconRangeMin = iconRangeMin, iconColor = iconColor, angle = angle, callback = callback, pinID = nil, shown = false, hideIcon = false}
end

function world.init()
    ObserveAfter("BaseMappinBaseController", "UpdateRootState", function(this) -- Custom pin texture
        local mappin = this:GetMappin()
        if not mappin then return end
        local pos = mappin:GetWorldPosition()
        for _, interaction in pairs(world.interactions) do
            if Vector4.Distance(pos, interaction.pos) < 0.05 and interaction.shown then
                local record = TweakDBInterface.GetUIIconRecord(interaction.icon)
                this.iconWidget:SetAtlasResource(record:AtlasResourcePath())
                this.iconWidget:SetTexturePart(record:AtlasPartName())
                this.iconWidget:SetTintColor(interaction.iconColor or HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 }))
            end
        end
    end)
end

function world.update()
    local showKeys = {} -- Show callbacks later, avoid interactionUI getting overriden

    local posPlayer = Game.GetPlayer():GetWorldPosition()
    posPlayer.z = posPlayer.z + 1
    local playerForward = GetPlayer():GetWorldForward()
    for key, interaction in pairs(world.interactions) do
        local update = interaction.shown
        if Vector4.Distance(posPlayer, interaction.pos) < interaction.interactionRange then -- Custom callback when in range and look at
            if 180 - Vector4.GetAngleBetween(playerForward, Vector4.new(posPlayer.x - interaction.pos.x, posPlayer.y - interaction.pos.y, posPlayer.z - interaction.pos.z, 0)) < interaction.angle then
                update = true
            else
                update = false
            end
        else
            update = false
        end

        if update ~= interaction.shown then -- Call callback
            if update == true then
                table.insert(showKeys, key)
            else
                interaction.shown = update
                interaction.callback(interaction.shown)
            end
        end

        --modified dist, iconRangeMin, & InRouletteTable by Boe6
        local dist = Vector4.Distance(posPlayer, interaction.pos)
        if interaction.icon and ( dist < interaction.iconRange and dist > interaction.iconRangeMin ) then -- Hide / show optional icon
            if not InRouletteTable then
                world.togglePin(interaction, true)
                utils.toggleHUD(true)
            end
        elseif interaction.icon then
            world.togglePin(interaction, false)
        end
    end

    for _, key in pairs(showKeys) do
        world.interactions[key].shown = true
        world.interactions[key].callback(world.interactions[key].shown)
    end
end

function world.togglePin(interaction, state)
    if not interaction.icon or interaction.hideIcon then return end
    if not state and interaction.pinID then
        Game.GetMappinSystem():UnregisterMappin(interaction.pinID)
        interaction.pinID = nil
        return
    elseif not interaction.pinID and state then
        local data = MappinData.new({ mappinType = 'Mappins.DefaultStaticMappin', variant = gamedataMappinVariant.SitVariant, visibleThroughWalls = true })
        interaction.pinID = Game.GetMappinSystem():RegisterMappin(data, interaction.pos)
    end
end

function world.onSessionStart() -- Save loaded, all pins are gone
    for _, interaction in pairs(world.interactions) do
        interaction.shown = false
        interaction.pinID = nil
    end
end

return world