ChipBetPiles = {
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
local tableBoardOrigin = nil
local RegisterEntity = nil
local DeRegisterEntity = nil
local FindEntIdByName = nil
local SetRotateEnt = nil
local DualPrint = nil
local RouletteMainMenu = nil
local poker_chip = nil

-- Local data
local betsPileQueue = {}
local betsPiles = {}
local betsPilesToRemove = {}

-- Initialize function to set dependencies
function ChipBetPiles.Initialize(deps)
    ChipUtils = deps.ChipUtils
    Cron = deps.Cron
    chip_colors = deps.chip_colors
    chipHeight = deps.chipHeight
    tableBoardOrigin = deps.tableBoardOrigin
    RegisterEntity = deps.RegisterEntity
    DeRegisterEntity = deps.DeRegisterEntity
    FindEntIdByName = deps.FindEntIdByName
    SetRotateEnt = deps.SetRotateEnt
    DualPrint = deps.DualPrint
    RouletteMainMenu = deps.RouletteMainMenu
    poker_chip = deps.poker_chip
end

-- Update function for tableBoardOrigin (in case it gets reassigned)
function ChipBetPiles.UpdateTableBoardOrigin(newTableBoardOrigin)
    if newTableBoardOrigin then
        tableBoardOrigin = newTableBoardOrigin
    end
end

-- Getter functions for data
function ChipBetPiles.GetBetsPiles()
    return betsPiles
end

function ChipBetPiles.GetBetsPileQueue()
    return betsPileQueue
end

function ChipBetPiles.GetBetsPilesToRemove()
    return betsPilesToRemove
end

-- Clear/reset functions
function ChipBetPiles.Clear()
    betsPileQueue = {}
    betsPiles = {}
    betsPilesToRemove = {}
end

function ChipBetPiles.CreateBetStack(betObject)
    --xyz
    local betCategory = betObject.cat
    local betChoice = betObject.bet
    local betValue = betObject.value
    local betID = betObject.id
    local betWorldLocation = {x=0,y=0}
    --DualPrint('[==w Ran CreateBetStack(); betCategory: '..betCategory..' betChoice: '..betChoice..' betValue: '..betValue..' betID: '..betID)
    if betCategory == "Red/Black" then
        if betChoice == "Red" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=9, y=1.5})
        elseif betChoice == "Black" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=7, y=1.5})
        end
    elseif betCategory == "Straight-Up" then
        local digit1 = string.sub(betChoice, 1, 1)
        local digit2 = string.sub(betChoice, 2, 2)
        local betNum = 0
        if digit2 == " " then
            betNum = betNum + tonumber(digit1)
        else
            betNum = betNum + tonumber(digit1..digit2)
        end
        if betNum ~= 0 then
            local xOffset = math.floor(betNum/3 - 1/3)
            local yOffset = (betNum-1) %3
            betWorldLocation = ChipUtils.HexToBoardCoords({x=13.5-xOffset, y=5.5-yOffset})
        else
            betWorldLocation = ChipUtils.HexToBoardCoords({x=14.5, y=4.5})
        end
    elseif betCategory == "Odd/Even" then
        if betChoice == "Odd" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=11, y=1.5})
        elseif betChoice == "Even" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=5, y=1.5})
        end
    elseif betCategory == "High/Low" then
        if betChoice == "High" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=13, y=1.5})
        elseif betChoice == "Low" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=3, y=1.5})
        end
    elseif betCategory == "Column" then
        if betChoice == "1st Column" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=1.5, y=5.5})
        elseif betChoice == "2nd Column" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=1.5, y=4.5})
        elseif betChoice == "3rd Column" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=1.5, y=3.5})
        end
    elseif betCategory == "Dozen" then
        if betChoice == "1-12 Dozen" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=12, y=2.5})
        elseif betChoice == "13-24 Dozen" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=8, y=2.5})
        elseif betChoice == "25-36 Dozen" then
            betWorldLocation = ChipUtils.HexToBoardCoords({x=4, y=2.5})
        end
    elseif betCategory == "Split" then
        local digit1 = string.sub(betChoice, 1, 1)
        local digit2 = string.sub(betChoice, 2, 2)
        local digit3 = string.sub(betChoice, 3, 3)
        local digit4 = string.sub(betChoice, 4, 4)
        local digit5 = string.sub(betChoice, 5, 5)
        local doubleDigitFirstNumber = false
        if digit3 == "-" then
            doubleDigitFirstNumber = true
        end
        local firstNumber = 0
        local secondNumber = 0
        if doubleDigitFirstNumber == true then
            firstNumber = tonumber(digit1..digit2)
            secondNumber = tonumber(digit4..digit5)
        else
            firstNumber = tonumber(digit1)
            secondNumber = tonumber(digit3..digit4)
        end
        local coords = {x=0, y=0}
        local mod3 = firstNumber % 3
        local row = 0
        local column = 0
        if mod3 == 0 then
            row = firstNumber / 3
            column = 3
        elseif mod3 == 1 then
            row = (firstNumber+2) / 3
            column = 1
        else
            row = (firstNumber+1) / 3
            column = 2
        end
        if secondNumber - firstNumber == 1 then --Row Split
            if mod3 == 1 then
                coords.y = 5
            else
                coords.y = 4
            end
            coords.x = (-row + 13) + 1.5
        else --Column Split
            coords.y = (-column + 4) + 2.5
            coords.x = (-row + 13) + 1
        end
        betWorldLocation = ChipUtils.HexToBoardCoords({x=coords.x, y=coords.y})
    elseif betCategory == "Street" then
        local row = 0
        if string.sub(betChoice, 2, 2) == "," then
            row = tonumber(string.sub(betChoice, 5, 5))/3
        else
            row = tonumber(string.sub(betChoice, 7, 8))/3
        end
        betWorldLocation = ChipUtils.HexToBoardCoords({x=(-row+13)+1.5, y=3})
    elseif betCategory == "Corner" then
        local firstNumber = 0
        if string.sub(betChoice, 2, 2) == "/" then
            firstNumber = tonumber(string.sub(betChoice, 1, 1))
        else
            firstNumber = tonumber(string.sub(betChoice, 1, 2))
        end
        local mod3 = firstNumber % 3
        local coords = {x=0, y=0}
        local row = 0
        local column = 0
        if mod3 == 0 then
            row = firstNumber / 3
            column = 3
        elseif mod3 == 1 then
            row = (firstNumber+2) / 3
            column = 1
        else
            row = (firstNumber+1) / 3
            column = 2
        end
        -- Corner bets are positioned at the intersection of four numbers
        -- For straight-up bets: x = 13.5 - xOffset, y = 5.5 - yOffset
        -- where xOffset = floor(betNum/3 - 1/3), yOffset = (betNum-1) % 3
        -- Corner bets span two columns and two rows:
        -- - If mod3 == 1 (column 1): corner is between columns 1-2, rows 1-2 (left side)
        -- - If mod3 == 2 (column 2): corner is between columns 2-3, rows 1-2 (right side)
        -- x position: between the two rows (same for both left and right corners in same row)
        coords.x = (-row + 13) + 1
        -- y position: between the two columns
        -- For left side (columns 1-2): y = 5 (midpoint between y=5.5 and y=4.5)
        -- For right side (columns 2-3): y = 4 (midpoint between y=4.5 and y=3.5)
        if mod3 == 1 then
            -- Left side corner (between columns 1 and 2)
            coords.y = 5
        else
            -- Right side corner (between columns 2 and 3)
            coords.y = 4
        end
        betWorldLocation = ChipUtils.HexToBoardCoords({x=coords.x, y=coords.y})
    elseif betCategory == "Line" then
        local firstNumber = 0
        if string.sub(betChoice, 2, 2) == "-" then
            firstNumber = tonumber(string.sub(betChoice, 1, 1))
        else
            firstNumber = tonumber(string.sub(betChoice, 1, 2))
        end
        -- Line bets span two rows, so calculate the midpoint
        -- Row of first number: ceil(firstNumber / 3)
        -- Row of last number: ceil((firstNumber+5) / 3) since line bets span 6 numbers
        -- Midpoint: (row1 + row2) / 2
        local row1 = math.ceil(firstNumber / 3)
        local row2 = math.ceil((firstNumber + 5) / 3)
        local row = (row1 + row2) / 2
        betWorldLocation = ChipUtils.HexToBoardCoords({x=(-row + 13) + 1.5, y=3})
    end

    betsPiles[betID] = {
        value=0,
        chipCount=0,
        id = betID,
        singleStacks={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        fullStacks={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        location = {x=betWorldLocation.x, y=betWorldLocation.y, z=tableBoardOrigin.z},
        rotation = {x=0, y=0, z=0},
        stacksInfo = {},
        limits = {minX=-2, maxX=2, minY=-2, maxY=2, minZ=1, maxZ=10} -- Limits for bet pile stack layout (smaller than player pile since bets are single locations)
    }

    ChipUtils.ValueToPileQueueSimple(betsPiles[betID], betsPileQueue, betValue, betsPileQueue)
end

function ChipBetPiles.QueuedBetChipAddition(currentlyRepeatingBets) -- each tick, add a chip to a pile, based on pileQueue table
    if next(betsPileQueue) == nil then --exit function if no actions needed.
        return currentlyRepeatingBets
    end
    local queueCount = 0
    for i, j in ipairs(betsPileQueue) do
        queueCount = queueCount + 1
    end
    local localPile = betsPileQueue[1].pile
    local localIndex = betsPileQueue[1].cIndex
    local betID = localPile.id
    local locDevName = (betID
                        ..'_c' --"color"
                        ..tostring(localIndex)
                        ..'_s'
                        ..localPile.fullStacks[localIndex]
                        ..'_chips'
                    ) --eg "c1_s1_chips"
    local chipCount = localPile.chipCount
    local pileLocation = localPile.location
    if localPile.singleStacks[localIndex] == 0 then --if there is no 1-9 chip stack currently
        local newAmount = localPile.singleStacks[localIndex] + 1
        localPile.singleStacks[localIndex] = newAmount --increase stack amount in pile data

        local spawnHeight = pileLocation.z + chipHeight*chipCount
        local locAppearance = (tostring(newAmount)..'_'..chip_colors[localIndex])
        RegisterEntity(locDevName, poker_chip, locAppearance, {x=pileLocation.x, y=pileLocation.y, z=spawnHeight}) --add random rotation after spawn w/ cron delay, similar to hologram rotation logic. (could apply to regular chip stacks too actually)
        
        table.insert(
            localPile.stacksInfo,
            {
                stackDevName = locDevName,
                cIndex = localIndex
            }
        )
        local callback = function()
            SetRotateEnt(locDevName, {r=0, p=0, y=math.random(1,360)})
        end
        Cron.After(0.1, callback)
    elseif localPile.singleStacks[localIndex] < 10 then
        local newAmount = localPile.singleStacks[localIndex] + 1
        localPile.singleStacks[localIndex] = newAmount --increase stack amount in pile data
        local newApperance = (tostring(newAmount)..'_'..chip_colors[localIndex])

        --update entity appearance +1
        local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
        if entity then
            entity:ScheduleAppearanceChange(newApperance) --updates entity's appearance
        end
    end
    if localPile.singleStacks[localIndex] == 10 then
        localPile.fullStacks[localIndex] = localPile.fullStacks[localIndex] + 1 --increase stack count in pile data
        localPile.singleStacks[localIndex] = 0
    end

    localPile.chipCount = localPile.chipCount + 1
    betsPileQueue[1].amount = betsPileQueue[1].amount - 1
    if betsPileQueue[1].amount == 0 then
        table.remove(betsPileQueue, 1)
    end
    if currentlyRepeatingBets == true then
        if next(betsPileQueue) == nil then --if used repeat bet function & reached end of queue, display main menu UI
            local callback = function()
                if RouletteMainMenu then
                    RouletteMainMenu.MainMenuUI()
                end
            end
            Cron.After(0.2, callback)
            return false -- Signal that repeating bets is done
        end
    end
    return currentlyRepeatingBets -- Return current state
end

function ChipBetPiles.RemoveBetStack()
    if next(betsPilesToRemove) == nil then --exit function if no actions needed.
        return
    end

    local idToRemove = {}
    local indexCount = 0
    for i, v in ipairs(betsPilesToRemove) do
        if v == nil then
            --uhh why is it nil   --its not, below line is
            if DualPrint then DualPrint('=w ERROR! v is nil, index: '..i..' v: '..v..' indexCount: '..indexCount..', error code: 0046') end
        end
        local localPile = betsPiles[v]
        if localPile == nil then
            table.insert(idToRemove, v)
            indexCount = indexCount + 1
        elseif next(localPile.stacksInfo) == nil then --if pile is empty
            betsPiles[v] = nil
            table.insert(idToRemove, v)
            indexCount = indexCount + 1
        else
            -- Find which color/index has chips to remove (find highest index with chips)
            local localIndex = nil
            for cIndex = 16, 1, -1 do
                if localPile.singleStacks[cIndex] > 0 or localPile.fullStacks[cIndex] > 0 then
                    localIndex = cIndex
                    break
                end
            end
            
            if localIndex == nil then
                -- No chips found, mark for removal
                betsPiles[v] = nil
                table.insert(idToRemove, v)
                indexCount = indexCount + 1
            else
                -- Find the stack in stacksInfo that matches the color we want to remove from
                -- Calculate expected devName using same logic as addition
                local betID = localPile.id
                local expectedDevName = (betID
                                    ..'_c' --"color"
                                    ..tostring(localIndex)
                                    ..'_s'
                                    ..localPile.fullStacks[localIndex]
                                    ..'_chips'
                                )
                
                -- Find matching stack in stacksInfo
                local foundStack = nil
                local foundStackIndex = nil
                for j, k in ipairs(localPile.stacksInfo) do
                    if k.cIndex == localIndex and k.stackDevName == expectedDevName then
                        foundStack = k
                        foundStackIndex = j
                        break
                    end
                end
                
                -- If exact match not found, find any stack of this color (fallback)
                if not foundStack then
                    for j, k in ipairs(localPile.stacksInfo) do
                        if k.cIndex == localIndex then
                            foundStack = k
                            foundStackIndex = j
                            -- Use the actual devName from the stack
                            expectedDevName = k.stackDevName
                            break
                        end
                    end
                end
                
                if not foundStack then
                    -- Stack not found in stacksInfo, mark pile for removal
                    betsPiles[v] = nil
                    table.insert(idToRemove, v)
                    indexCount = indexCount + 1
                else
                    local locDevName = expectedDevName
                    local currentSingleAmount = localPile.singleStacks[localIndex]
                    local newApp = currentSingleAmount - 1
                    
                    if newApp < 0 then
                        -- Need to move from fullStacks to singleStacks
                        if localPile.fullStacks[localIndex] > 0 then
                            localPile.fullStacks[localIndex] = localPile.fullStacks[localIndex] - 1
                            localPile.singleStacks[localIndex] = 9
                            -- Recalculate devName for the new fullStacks value
                            locDevName = (betID..'_c'..tostring(localIndex)..'_s'..localPile.fullStacks[localIndex]..'_chips')
                            -- Update the entity appearance
                            local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
                            if entity then
                                local appearance = (tostring(9)..'_'..chip_colors[localIndex])
                                entity:ScheduleAppearanceChange(appearance)
                            end
                        else
                            -- No more chips of this color, remove the stack
                            ChipUtils.DeRegisterChipEntity(locDevName)
                            table.remove(localPile.stacksInfo, foundStackIndex)
                            localPile.singleStacks[localIndex] = 0
                        end
                    elseif newApp == 0 then
                        -- Stack is now empty, remove it
                        if localPile.fullStacks[localIndex] > 0 then
                            -- Move to next full stack
                            localPile.fullStacks[localIndex] = localPile.fullStacks[localIndex] - 1
                            localPile.singleStacks[localIndex] = 10
                            -- Recalculate devName for the new fullStacks value
                            locDevName = (betID..'_c'..tostring(localIndex)..'_s'..localPile.fullStacks[localIndex]..'_chips')
                            -- Update entity to show 10 chips
                            local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
                            if entity then
                                local appearance = (tostring(10)..'_'..chip_colors[localIndex])
                                entity:ScheduleAppearanceChange(appearance)
                            end
                        else
                            -- No more stacks of this color, remove entity
                            ChipUtils.DeRegisterChipEntity(locDevName)
                            table.remove(localPile.stacksInfo, foundStackIndex)
                            localPile.singleStacks[localIndex] = 0
                        end
                    else
                        -- Just decrement the count
                        localPile.singleStacks[localIndex] = newApp
                        local appearance = (tostring(newApp)..'_'..chip_colors[localIndex])
                        local entity = Game.FindEntityByID(FindEntIdByName(locDevName))
                        if entity then
                            entity:ScheduleAppearanceChange(appearance) --updates entity's appearance
                        end
                    end
                    
                    localPile.chipCount = localPile.chipCount - 1
                end
            end
        end
    end
    for i, v in ipairs(idToRemove) do
        local matchIndex = nil
        for j, k in ipairs(betsPilesToRemove) do
            if v == k then
                matchIndex = j
                break
            end
        end
        --local flipIndex = -i+indexCount+1 --nice code to flip index in a loop, I'll use it a lot, likely
        if matchIndex then
            table.remove(betsPilesToRemove, matchIndex)
        end
    end
end

return ChipBetPiles

