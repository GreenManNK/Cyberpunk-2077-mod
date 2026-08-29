SimpleCasinoChip = {
    version = '1.0.0',
    chips = {}
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local chip_values = {1,5,10,25,50,100,250,500,1000,2500,5000,10000,25000,50000,250000,1000000}
local chip_colors = {'white','yellow','red','blue','maroon','black',
                    'cyan','orange','lime','pink','purple','green',
                    'creamyYellow','royalBlue','forrestGreen','steelPink'
}

---Converts a bet number to an index for chip_values
---@param betAmount number bet to convert to index
---@return integer index index in chip_values{} for betAmount.
--- Returns 1 if no exact chip_value match.
local function betAmountToValueIndex(betAmount)
    for i = 1, #chip_values do
        if betAmount == chip_values[i] then
            return i
        end
    end
    return 1
end

---Spawn a chip at the position.
---@param betAmount integer chip value to spawn
---@param position Vector4 world position
---@param randomRotation boolean if true, random rotation. Looks more natural
---@param orientationYaw? number yaw orientation to use.
function SimpleCasinoChip.spawnChip(chipID, betAmount, position, randomRotation, orientationYaw)
    local chip_color = chip_colors[betAmountToValueIndex(betAmount)]
    local euler = EulerAngles.new(0,0,0)
    if randomRotation then
        euler = EulerAngles.new(0,0,math.random(0,360))
    else
        if orientationYaw == nil then
            DualPrint('SCC | orientationYaw is nil, error #8823')
            orientationYaw = 0
        end
        euler = EulerAngles.new(0,0,orientationYaw)
    end
    local spec = StaticEntitySpec.new()
    spec.templatePath = "boe6\\gambling_props\\boe6_poker_chip.ent"
    spec.appearanceName = "1_"..chip_color
    spec.position = position
    spec.orientation = EulerAngles.ToQuat(euler)
    spec.tags = {"SimpleCasinoChip",tostring(id)}

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    SimpleCasinoChip.chips[chipID] = { chipID = chipID, entID = entityID }
end

---Despawns a chip given their chipID
---@param chipID string chipID
function SimpleCasinoChip.despawnChip(chipID)
    if SimpleCasinoChip.chips[chipID] == nil then
        return
    end
    Game.GetStaticEntitySystem():DespawnEntity(SimpleCasinoChip.chips[chipID].entID)
end

---Despawns all chips
function SimpleCasinoChip.despawnAllChips()
    for k,v in pairs(SimpleCasinoChip.chips) do
        Game.GetStaticEntitySystem():DespawnEntity(v.entID)
    end
    SimpleCasinoChip.chips = {}
end

return SimpleCasinoChip