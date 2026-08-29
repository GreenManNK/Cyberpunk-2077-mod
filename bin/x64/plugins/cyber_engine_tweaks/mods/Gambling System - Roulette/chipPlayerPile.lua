ChipPlayerPile = {
    version = '1.0.0'
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

-- Dependencies (will be set via Initialize)
local ChipUtils = nil
local Cron = nil
local chip_colors = nil
local chipHeight = nil
local chipRotation = nil
local RegisterEntity = nil
local DeRegisterEntity = nil
local FindEntIdByName = nil
local SetRotateEnt = nil
local DualPrint = nil
local poker_chip = nil

-- Local data
local playerPile = { --initialize player pile
    value=0,
    singleStacks={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    fullStacks={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    location = {x=0, y=0, z=0}, --need to account for rotation in the future, specifically when other tables are added, the rotation needs to be accounted for
    rotation = {x=0, y=0, z=0},
    stacksInfo = {},
    limits = {minX=-4, maxX=6, minY=-2, maxY=3, minZ=1, maxZ=6}
}
local pileQueue = {} --stores a list of chips to be added to piles.
local pileSubtractionQueue = {}

-- Initialize function to set dependencies
function ChipPlayerPile.Initialize(deps)
    ChipUtils = deps.ChipUtils
    Cron = deps.Cron
    chip_colors = deps.chip_colors
    chipHeight = deps.chipHeight
    chipRotation = deps.chipRotation
    RegisterEntity = deps.RegisterEntity
    DeRegisterEntity = deps.DeRegisterEntity
    FindEntIdByName = deps.FindEntIdByName
    SetRotateEnt = deps.SetRotateEnt
    DualPrint = deps.DualPrint
    poker_chip = deps.poker_chip
end

-- Getter functions for data
function ChipPlayerPile.GetPlayerPile()
    return playerPile
end

function ChipPlayerPile.GetPileQueue()
    return pileQueue
end

function ChipPlayerPile.GetPileSubtractionQueue()
    return pileSubtractionQueue
end

-- Clear/reset functions
function ChipPlayerPile.Clear()
    playerPile.value = 0
    playerPile.singleStacks = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    playerPile.fullStacks = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    playerPile.stacksInfo = {}
    pileQueue = {}
    pileSubtractionQueue = {}
end

function ChipPlayerPile.ChangePlayerChipValue(valueModifier) --add or subtract valueModifier to player chips. Updates visual chips, pile stack, and holographic display
    if valueModifier == 0 then
        return
    elseif valueModifier > 0 then
        ChipUtils.ValueToPileQueueSimple(playerPile, pileQueue, valueModifier, nil)
        playerPile.value = playerPile.value + valueModifier
    elseif valueModifier < 0 then
        local valueInverted = valueModifier * -1
        ChipUtils.ValueToQueueSubtraction(playerPile, valueInverted, pileQueue, pileSubtractionQueue)
        playerPile.value = playerPile.value - valueInverted
    end
    
    -- Note: HolographicValueDisplay.Update() is now called every frame in onUpdate
    -- No need to call it here since the frame-based update will handle it
end

function ChipPlayerPile.QueuedChipSubtraction() -- each tick, subtract a chip from a pile, based on pileSubtractionQueue table
    --[[    --attempted bug fix
    if next(betsPileQueue) ~= nil then --exit if any chip additions are currently queued up
        return
    end
    ]]--
    if next(pileSubtractionQueue) == nil then --exit function if no actions needed.
        return
    end

    --get pile, color, amount
    local localPile = pileSubtractionQueue[1].pile
    local localIndex = pileSubtractionQueue[1].cIndex
    local localAmount = pileSubtractionQueue[1].amount
    local locDevName = ('c' --"color"
                        ..tostring(localIndex)
                        ..'_s' --"stack#"
                        ..tostring(localPile.fullStacks[localIndex] + 1)
                        ..'_chips'
                    ) --eg "c1_s1_chips"
    local curentSingleAmount = localPile.singleStacks[localIndex]
    local newApp = curentSingleAmount - 1
    if newApp < 0 then
        if DualPrint then DualPrint('=o ERROR: newApp < 0, CODE 2374') end
        table.remove(pileSubtractionQueue, 1)
        return
    end
    if newApp == 0 then
        if localPile.fullStacks[localIndex] > 0 then
            localPile.fullStacks[localIndex] = localPile.fullStacks[localIndex] - 1
            localPile.singleStacks[localIndex] = 10
        else
            localPile.singleStacks[localIndex] = 0
        end
        ChipUtils.DeRegisterChipEntity(locDevName)
        for i, j in ipairs(localPile.stacksInfo) do
            if j.stackDevName == locDevName then
                table.remove(localPile.stacksInfo, i)
                break
            end
        end
    else
        localPile.singleStacks[localIndex] = newApp
        local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
        if entity then
            local appearanceString = (tostring(newApp)..'_'..chip_colors[localIndex])
            entity:ScheduleAppearanceChange(appearanceString) --updates entity's appearance
        end
    end

    pileSubtractionQueue[1].amount = pileSubtractionQueue[1].amount - 1

    if pileSubtractionQueue[1].amount == 0 then --if queue object amount is 0, remove it
        table.remove(pileSubtractionQueue, 1)
    end
end

function ChipPlayerPile.QueuedChipAddition() -- each tick, add a chip to a pile, based on pileQueue table
    if next(pileQueue) == nil then --exit function if no actions needed.
        return
    end

    local localPile = pileQueue[1].pile
    local localIndex = pileQueue[1].cIndex
    local locDevName = ('c' --"color"
                        ..tostring(localIndex)
                        ..'_s' --"stack#"
                        ..tostring(localPile.fullStacks[localIndex] + 1)
                        ..'_chips'
                    ) --eg "c1_s1_chips"


    if localPile.singleStacks[localIndex] == 0 then --if there is no 1-9 chip stack currently
        local newAmount = localPile.singleStacks[localIndex] + 1
        localPile.singleStacks[localIndex] = newAmount --increase stack amount in pile data

        ChipPlayerPile.FindAndSpawnStack(localPile, localIndex, 1)

    elseif localPile.singleStacks[localIndex] == ChipUtils.GetMaxStackSize() then
        --update pile info for maxed single stack to move to full stacks table
        localPile.fullStacks[localIndex] = localPile.fullStacks[localIndex] + 1 --increase full stacks count by 1
        localPile.singleStacks[localIndex] = 1 --reset single stacks count. (0 +1, since we are adding a new single stack)

        ChipPlayerPile.FindAndSpawnStack(localPile, localIndex, 1)
    else --if there is an existing 1-9 chip stack
        local newAmount = localPile.singleStacks[localIndex] + 1
        localPile.singleStacks[localIndex] = newAmount

        local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
        if entity then
            entity:ScheduleAppearanceChange((tostring(newAmount)..'_'..chip_colors[localIndex])) --updates entity's appearance
        end
    end

    pileQueue[1].amount = pileQueue[1].amount - 1

    if pileQueue[1].amount == 0 then
        table.remove(pileQueue, 1)
    end
end

function ChipPlayerPile.FindAndSpawnStack(localPile, localIndex, value) --create/spawn additional stack in a pile
    local nextHexLocation = ChipUtils.FindNextStackLayoutLocation(localPile, localIndex)
    local xOffsetIfEven = -0.02 * nextHexLocation.y + 0.02
    local locAppearance = (value..'_' .. chip_colors[localIndex])
    local nextLocationOffset = {
                            x=nextHexLocation.x * 0.04 + xOffsetIfEven,
                            y=nextHexLocation.y * 0.035,
                            z=(nextHexLocation.z-1) * 0.035
                        }
    -- Get table rotation dynamically from active table
    local tableRotation = 0 -- Default fallback
    if GetActiveTableRotation then
        local rotation = GetActiveTableRotation()
        if rotation then
            tableRotation = rotation
        else
            if DualPrint then
                DualPrint('[==e WARNING: Could not get active table rotation in FindAndSpawnStack, using 0')
            end
        end
    else
        if DualPrint then
            DualPrint('[==e ERROR: GetActiveTableRotation function not available in FindAndSpawnStack!')
        end
    end
    local stackRotation = (tableRotation + chipRotation) * math.pi / 180
    local nextLocationRotated = {
                            x=( nextLocationOffset.x * math.cos(stackRotation) ) - ( nextLocationOffset.y * math.sin(stackRotation) ),
                            y=( nextLocationOffset.y * math.cos(stackRotation) ) + ( nextLocationOffset.x * math.sin(stackRotation) ),
                            z=nextLocationOffset.z
                        }
    local nextLocation = {
                            x=localPile.location.x + nextLocationRotated.x,
                            y=localPile.location.y + nextLocationRotated.y,
                            z=localPile.location.z + nextLocationRotated.z
                        }
    local devName = ('c' --"color"
                        ..tostring(localIndex)
                        ..'_s' --"stack#"
                        ..tostring(localPile.fullStacks[localIndex] + 1)
                        ..'_chips'
                    ) --eg "c1_s1_chips"
    --n/a

    ChipUtils.RegisterChipEntity(devName, poker_chip, locAppearance, nextLocation)
    table.insert(
        localPile.stacksInfo,
        {
            stackDevName = devName,
            cIndex = localIndex,
            hexCoords = nextHexLocation
        }
    )
    local callback = function()
        SetRotateEnt(devName, {r=0, p=0, y=math.random(1,360)})
    end
    Cron.After(0.1, callback)
    ChipUtils.ResetSearchState()
end

function ChipPlayerPile.DebugPlayerPile()
    if not DualPrint then return end
    DualPrint('=  DebugPlayerPile() = DEBUG PLAYER PILE =')
    DualPrint('=  value: '..playerPile.value)
    DualPrint('=  singleStacks: {'..playerPile.singleStacks[1]..','..playerPile.singleStacks[2]..','..playerPile.singleStacks[3]..','..playerPile.singleStacks[4]..','..playerPile.singleStacks[5]..','..playerPile.singleStacks[6]..','
                                ..playerPile.singleStacks[7]..','..playerPile.singleStacks[8]..','..playerPile.singleStacks[9]..','..playerPile.singleStacks[10]..','..playerPile.singleStacks[11]..','..playerPile.singleStacks[12]..','
                                ..playerPile.singleStacks[13]..','..playerPile.singleStacks[14]..','..playerPile.singleStacks[15]..','..playerPile.singleStacks[16]..'}')
    DualPrint('=  fullStacks: {'..playerPile.fullStacks[1]..','..playerPile.fullStacks[2]..','..playerPile.fullStacks[3]..','..playerPile.fullStacks[4]..','..playerPile.fullStacks[5]..','..playerPile.fullStacks[6]..','
                                ..playerPile.fullStacks[7]..','..playerPile.fullStacks[8]..','..playerPile.fullStacks[9]..','..playerPile.fullStacks[10]..','..playerPile.fullStacks[11]..','..playerPile.fullStacks[12]..','
                                ..playerPile.fullStacks[13]..','..playerPile.fullStacks[14]..','..playerPile.fullStacks[15]..','..playerPile.fullStacks[16]..'}')
    DualPrint('=  location x: '..playerPile.location.x..' y: '..playerPile.location.y..' z: '..playerPile.location.z)
    DualPrint('=  stacksInfo = {} :')
    for i,v in ipairs(playerPile.stacksInfo) do
        DualPrint('=  i: '..i..' stackDevName: '..v.stackDevName..' cIndex: '..v.cIndex..' hexCoords: '..v.hexCoords.x..','..v.hexCoords.y..','..v.hexCoords.z)
    end
    DualPrint('=  limits x: '..playerPile.limits.minX..','..playerPile.limits.maxX..' y: '..playerPile.limits.minY..','..playerPile.limits.maxY..' z: '..playerPile.limits.minZ..','..playerPile.limits.maxZ)
end

return ChipPlayerPile

