ChipUtils = {
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
local Cron = nil
local tableBoardOrigin = nil
local chipRotation = nil
local chipHeight = nil
local chip_values = nil
local chip_colors = nil
local RegisterEntity = nil
local DeRegisterEntity = nil
local FindEntIdByName = nil
local SetRotateEnt = nil
local MapVar = nil
local DualPrint = nil

-- Local data
local maxStackSize = 10
local searchStepCount = 0
local stackSearchCurrent = {x=0, y=0, z=0}
local stackSearchPrevious = {x=0, y=0, z=0}
local stackSearchOld = {x=0, y=0, z=0}
local subtractionValueLoopCount = 0

-- Entity management for chips (wrappers around RegisterEntity/DeRegisterEntity)
function ChipUtils.RegisterChipEntity(devName, entSrc, appName, location, orientation, tags)
    if RegisterEntity then
        RegisterEntity(devName, entSrc, appName, location, orientation, tags)
    end
end

function ChipUtils.DeRegisterChipEntity(devName)
    if DeRegisterEntity then
        DeRegisterEntity(devName)
    end
end

-- Initialize function to set dependencies
function ChipUtils.Initialize(deps)
    Cron = deps.Cron
    tableBoardOrigin = deps.tableBoardOrigin
    chipRotation = deps.chipRotation
    chipHeight = deps.chipHeight
    chip_values = deps.chip_values
    chip_colors = deps.chip_colors
    RegisterEntity = deps.RegisterEntity
    DeRegisterEntity = deps.DeRegisterEntity
    FindEntIdByName = deps.FindEntIdByName
    SetRotateEnt = deps.SetRotateEnt
    MapVar = deps.MapVar
    DualPrint = deps.DualPrint
end

-- Update function for tableBoardOrigin (in case it gets reassigned)
function ChipUtils.UpdateTableBoardOrigin(newTableBoardOrigin)
    if newTableBoardOrigin then
        tableBoardOrigin = newTableBoardOrigin
    end
end

-- Coordinate conversion
function ChipUtils.HexToBoardCoords(hexCoords)
    if not tableBoardOrigin then
        if DualPrint then
            DualPrint('[==e ERROR: tableBoardOrigin is nil in HexToBoardCoords!')
        end
        return {x=0, y=0}
    end
    
    -- Get table rotation dynamically from active table
    local tableRotation = GetActiveTableRotation()
    if not tableRotation then
        if DualPrint then
            DualPrint('[==e ERROR: Could not get active table rotation in HexToBoardCoords!')
        end
        return {x=0, y=0}
    end
    
    local boardOriginXw = tableBoardOrigin.x
    local boardOriginYw = tableBoardOrigin.y
    local wGapY = 0.1186428571
    local localYw = boardOriginYw-wGapY*(hexCoords.x-1)
    local wXPartial3 = tableBoardOrigin.x + 0.237
    local localXw = 0
    if hexCoords.y < 3 then --<3
        localXw = boardOriginXw + 0.1185*(hexCoords.y-1)
    else
        localXw = wXPartial3 + 0.2200*(hexCoords.y-3)
    end
    local rotationAngle = (tableRotation + 89.7887983)
    local localPositionxy = RotatePoint({x=tableBoardOrigin.x, y=tableBoardOrigin.y}, {x=localXw, y=localYw}, rotationAngle )
    localXw = localPositionxy.x
    localYw = localPositionxy.y
    return {x=localXw, y=localYw}
end

-- Helper function for RotatePoint (needed by HexToBoardCoords)
function RotatePoint(center, point, angle) --rotates {x,y} point around {x,y} center by angle in degrees counterclockwise. returns {x=x,y=y}
    local rad = angle * math.pi / 180
    local x = center.x + math.cos(rad) * (point.x - center.x) - math.sin(rad) * (point.y - center.y)
    local y = center.y + math.sin(rad) * (point.x - center.x) + math.cos(rad) * (point.y - center.y)
    return {x=x,y=y}
end

-- Stack layout functions
function ChipUtils.FindNextStackLayoutLocation(localPile, cIndex) --output {x=i,y=i,z=i} based on cIndex and current pile layout

    if not ChipUtils.CheckStackLayoutCoords(localPile, {x=1, y=1, z=1}) then --if search coordinates are empty
        return {x=1, y=1, z=1}
    end
    local localcIndex = ChipUtils.CheckStackLayoutCoords(localPile, {x=1, y=1, z=1})
    searchStepCount = 0
    local stepInfo = ChipUtils.StackLocationSearchStep(localPile, {x=1, y=1, z=1}, cIndex, searchStepCount)

    while stepInfo[2] == false do
        searchStepCount = searchStepCount + 1
        if stepInfo[1].x ~= stepInfo[1].x then
            stepInfo = {{x=1, y=1, z=2}, true}
        else
            stepInfo = ChipUtils.StackLocationSearchStep(localPile, stepInfo[1], cIndex, searchStepCount)
        end
        local shouldStep = stepInfo[2]
        if stepInfo[1].x < localPile.limits.minX then
            stepInfo[1].x = localPile.limits.minX
            shouldStep = false
        end
        if stepInfo[1].x > localPile.limits.maxX then
            stepInfo[1].x = localPile.limits.maxX
            shouldStep = false
        end
        if stepInfo[1].y < localPile.limits.minY then
            stepInfo[1].y = localPile.limits.minY
            shouldStep = false
        end
        if stepInfo[1].y > localPile.limits.maxY then
            stepInfo[1].y = localPile.limits.maxY
            shouldStep = false
        end
        if stepInfo[1].z < localPile.limits.minZ then
            stepInfo[1].z = localPile.limits.minZ
            shouldStep = false
        end
        if stepInfo[1].z > localPile.limits.maxZ then
            stepInfo[1].z = localPile.limits.maxZ
            shouldStep = false
        end
        stepInfo[2] = shouldStep
    end
    if stepInfo[2] == true then
        return stepInfo[1]
    end

    if DualPrint then DualPrint('=c error end function return {x=1, y=3, z=2}, code 0925') end
    return {x=1, y=3, z=2}
end

function ChipUtils.StackLocationSearchStep(localPile, hexCoords, cIndex, stepCount) --returns {hexCoords, false} or {hexCoords, true} boolean indicates end of search

    --search stuck loop detection
    stackSearchOld = {x=stackSearchPrevious.x, y=stackSearchPrevious.y, z=stackSearchPrevious.z}
    stackSearchPrevious = {x=stackSearchCurrent.x, y=stackSearchCurrent.y, z=stackSearchCurrent.z}
    stackSearchCurrent = {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}
    if stackSearchOld.y == stackSearchCurrent.y
        and stackSearchOld.y == stackSearchCurrent.y
        and stackSearchOld.z == stackSearchCurrent.z
    then
        return ChipUtils.SearchStuckExit(localPile, stackSearchCurrent, stackSearchPrevious, stackSearchOld)
    end
    if stepCount == 25 then
        return ChipUtils.WideHexSearch(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, cIndex)
    elseif stepCount >= 50 then
        return {x=stackSearchCurrent.x, y=stackSearchCurrent.y+2, z=stackSearchCurrent.z+1}, true
    end
    --end stuck search code lol

    local onLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z})
    local onRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z})
    local topLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z})
    local topRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z})
    local bottomLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z})
    local bottomRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z})
    local center = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})

    local localStackCount = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})

    if not center then --if center empty
        return ChipUtils.CheckEmptyAndShift(localPile, hexCoords, localStackCount)
    end

    if cIndex == center then --if center stack is the same color
        if not onRight then
            return {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, false}
        elseif not onLeft then
            return {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, false}
        elseif not topRight then
            return {{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, false}
        elseif not topLeft then
            return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, false}
        elseif not bottomRight then
            return {{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, false}
        elseif not bottomLeft then
            return {{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, false}
        end
        local left2 = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z})
        local right2 = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z})

        --"near touching" stacks check
        local nearSpotsNeighbors = {
            { {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z}, {x=hexCoords.x-1, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x-2, y=hexCoords.y-1, z=hexCoords.z} }, --touchingLeft
            { {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z}, {x=hexCoords.x+2, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x+1, y=hexCoords.y-1, z=hexCoords.z} }, --touchingRight
            { {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x-1, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x, y=hexCoords.y+2, z=hexCoords.z}, {x=hexCoords.x+1, y=hexCoords.y+2, z=hexCoords.z} }, --touchingTopLeft
            { {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x+2, y=hexCoords.y+1, z=hexCoords.z}, {x=hexCoords.x+2, y=hexCoords.y+2, z=hexCoords.z}, {x=hexCoords.x+1, y=hexCoords.y+2, z=hexCoords.z} }, --touchingTopRight
            { {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, {x=hexCoords.x-2, y=hexCoords.y-1, z=hexCoords.z}, {x=hexCoords.x-2, y=hexCoords.y-2, z=hexCoords.z}, {x=hexCoords.x-1, y=hexCoords.y-2, z=hexCoords.z} }, --touchingBottomLeft
            { {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, {x=hexCoords.x+1, y=hexCoords.y-1, z=hexCoords.z}, {x=hexCoords.x, y=hexCoords.y-2, z=hexCoords.z}, {x=hexCoords.x-1, y=hexCoords.y-2, z=hexCoords.z} } --touchingBottomRight
        }
        for i,v in pairs(nearSpotsNeighbors) do
            local touchingColor = ChipUtils.CheckStackLayoutCoords(localPile, v[1])
            if touchingColor == cIndex then
                for j=1,3 do
                    local spot = v[j+1]
                    if not ChipUtils.CheckStackLayoutCoords(localPile, spot) then return {spot, true} end
                end
            end
        end

        return ChipUtils.WideHexSearch(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, cIndex)
    elseif cIndex > center then
        if localStackCount <= 7 then
            if not onRight then
                return {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, true}
            elseif not topRight then
                return {{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif not bottomRight then
                return {{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, true}
            elseif not ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z}) then
                return {{x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z}, true}
            end
        end
        return ChipUtils.WideHexSearch(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, cIndex)
    else -- cIndex < center
        if localStackCount <= 7 then
            if not onLeft then
                return {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, true}
            elseif not topLeft then
                return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif not bottomLeft then
                return {{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, true}
            elseif not ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z}) then
                return {{x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z}, true}
            end
        end
        return ChipUtils.WideHexSearch(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, cIndex)
    end
end

function ChipUtils.CheckEmptyAndShift(localPile, hexCoords, stackCount) --from an empty coordinate, check if touching neighbors and/or move towards pile center, return new search coords & true/false "{x,y,z}, true"
    if stackCount >= 2 then
        return {{x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, true}
    elseif stackCount == 1 then
        local emptyNeighborsTable = {
            {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z},{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z},{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}},--left
            {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z},{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z},{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}},--right
            --WIP here, convert below if code into a pretty for loop.
        }
        if ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}) then --left
            local upper = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z})
            local lower = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z})
            if upper >= 2 then
                return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif lower >= 2 then
                return {{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, true}
            end
        elseif ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}) then --right
            local upper = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z})
            local lower = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z})
            if upper >= 2 then
                return {{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif lower >= 2 then
                return {{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, true}
            end
        elseif ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}) then --top left
            local right = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z})
            local left = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z})
            if right >= 2 then
                return {{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif left >= 2 then
                return {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, true}
            end
        elseif ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}) then --top right
            local left = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z})
            local right = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z})
            if left >= 2 then
                return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, true}
            elseif right >= 2 then
                return {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, true}
            end
        elseif ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}) then --bottom left
            local right = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z})
            local left = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z})
            if right >= 2 then
                return {{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, true}
            elseif left >= 2 then
                return {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, true}
            end
        elseif ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}) then --bottom right
            local left = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z})
            local right = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z})
            if left >= 2 then
                return {{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, true}
            elseif right >= 2 then
                return {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, true}
            end
        end
        return {{x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, false}
    else --stackCount == 0
        if localPile.stacksInfo == {} then
            return {{x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, true}
        end
        --find average position of all stacks
        local averagePileLocation = ChipUtils.AveragePileLocationFloat(localPile)

        local neighborsTable = {
            {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z},
            {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z},
            {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z},
            {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z},
            {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z},
            {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}
        }
        local nearestNeighborSquared = 999 * 999
        for i,v in pairs(neighborsTable) do --find shortest distance
            local dx = averagePileLocation.x - v.x
            local dy = averagePileLocation.y - v.y
            local dz = averagePileLocation.z - v.z
            local distanceSquared = dx * dx + dy * dy + dz * dz
            if nearestNeighborSquared > distanceSquared then
                nearestNeighborSquared = distanceSquared
            end
        end
        for i,v in pairs(neighborsTable) do --return shortest distance
            local dx = averagePileLocation.x - v.x
            local dy = averagePileLocation.y - v.y
            local dz = averagePileLocation.z - v.z
            local distanceSquared = dx * dx + dy * dy + dz * dz
            if distanceSquared == nearestNeighborSquared then
                return {{x=v.x, y=v.y, z=v.z}, false}
            end
        end
        return {{x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z+1}, true}
    end
end

function ChipUtils.SearchStuckExit(localPile, localstackSearchCurrent, localstackSearchPrevious, localstackSearchOld) --last case, try medium search, or spit out error coordinates (z=+1)

    local mediumSearched = ChipUtils.MediumSearchAggressive(localPile, {x=localstackSearchCurrent.x, y=localstackSearchCurrent.y, z=localstackSearchCurrent.z})
    if mediumSearched[2] == true then return mediumSearched end

    local currentStackColor = ChipUtils.CheckStackLayoutCoords(localPile, {x=localstackSearchCurrent.x, y=localstackSearchCurrent.y, z=localstackSearchCurrent.z})
    local previousStackColor = ChipUtils.CheckStackLayoutCoords(localPile, {x=localstackSearchPrevious.x, y=localstackSearchPrevious.y, z=localstackSearchPrevious.z})
    local oldStackColor = ChipUtils.CheckStackLayoutCoords(localPile, {x=localstackSearchOld.x, y=localstackSearchOld.y, z=localstackSearchOld.z})

    if currentStackColor ~= oldStackColor then
        if currentStackColor == previousStackColor then
            return {x=localstackSearchCurrent.x, y=localstackSearchCurrent.y, z=localstackSearchCurrent.z+1}, true
        end
        if currentStackColor > previousStackColor then
            return {x=localstackSearchCurrent.x, y=localstackSearchCurrent.y-1, z=localstackSearchCurrent.z+1}, true
        elseif currentStackColor < previousStackColor then
            return {x=localstackSearchPrevious.x, y=localstackSearchPrevious.y+1, z=localstackSearchPrevious.z+1}, true
        end
    else
        return {x=localstackSearchCurrent.x, y=localstackSearchCurrent.y+1, z=localstackSearchCurrent.z+1}, true
    end
end

function ChipUtils.AveragePileLocationFloat(localPile) --returns the {x,y,z} of the average location of all stacks in the pile
    local averageX = 0
    local averageY = 0
    local averageZ = 0
    local stackCount = 0
    for k,v in pairs(localPile.stacksInfo) do
        averageX = averageX + v.hexCoords.x
        averageY = averageY + v.hexCoords.y
        averageZ = averageZ + v.hexCoords.z
        stackCount = stackCount + 1
    end
    averageX = averageX / stackCount
    averageY = averageY / stackCount
    averageZ = averageZ / stackCount
    return {x=averageX, y=averageY, z=averageZ}
end

function ChipUtils.MediumSearchAggressive(localPile, hexCoords) --checks for ANY empty space within 2 hex of coordinates. returns "{xyz}, true" if found
    local center = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})
    local onLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z})
    local onRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z})
    local topLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z})
    local topRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z})
    local bottomLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z})
    local bottomRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z})

    if not center then return {{x=hexCoords.x, y=hexCoords.y, z=hexCoords.z}, true} end
    if not onLeft then return {{x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z}, true} end
    if not onRight then return {{x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z}, true} end
    if not topLeft then return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, true} end
    if not topRight then return {{x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z}, true} end
    if not bottomLeft then return {{x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z}, true} end
    if not bottomRight then return {{x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z}, true} end

    local farLeftCenter = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z})
    local farRightCenter = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z})
    local farLeftUpper = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y+1, z=hexCoords.z})
    local farRightUpper = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y+1, z=hexCoords.z})
    local farLeftUnder = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y-1, z=hexCoords.z})
    local farRightUnder = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y-1, z=hexCoords.z})
    local farLeftTopUpper = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+2, z=hexCoords.z})
    local farRightTopUpper = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y+2, z=hexCoords.z})
    local farCenterUpper = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y+2, z=hexCoords.z})
    local farLeftBottomUnder = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y-2, z=hexCoords.z})
    local farRightBottomUnder = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-2, z=hexCoords.z})
    local farCenterUnder = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y-2, z=hexCoords.z})

    if not farLeftCenter then return {{x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z}, true} end
    if not farRightCenter then return {{x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z}, true} end
    if not farLeftUpper then return {{x=hexCoords.x-1, y=hexCoords.y+1, z=hexCoords.z}, true} end
    if not farRightUpper then return {{x=hexCoords.x+2, y=hexCoords.y+1, z=hexCoords.z}, true} end
    if not farLeftUnder then return {{x=hexCoords.x-2, y=hexCoords.y-1, z=hexCoords.z}, true} end
    if not farRightUnder then return {{x=hexCoords.x+1, y=hexCoords.y-1, z=hexCoords.z}, true} end
    if not farLeftTopUpper then return {{x=hexCoords.x, y=hexCoords.y+2, z=hexCoords.z}, true} end
    if not farRightTopUpper then return {{x=hexCoords.x+2, y=hexCoords.y+2, z=hexCoords.z}, true} end
    if not farCenterUpper then return {{x=hexCoords.x+1, y=hexCoords.y+2, z=hexCoords.z}, true} end
    if not farLeftBottomUnder then return {{x=hexCoords.x-2, y=hexCoords.y-2, z=hexCoords.z}, true} end
    if not farRightBottomUnder then return {{x=hexCoords.x, y=hexCoords.y-2, z=hexCoords.z}, true} end
    if not farCenterUnder then return {{x=hexCoords.x-1, y=hexCoords.y-2, z=hexCoords.z}, true} end

    --else
    return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, false}
end

function ChipUtils.WideHexSearch(localPile, hexCoords, cIndex) --from a coordinate, check area within 3 hex distance. returns new search coords & true/false
    local center = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})
    local right = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z})
    local left = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z})
    local topRight = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x+2, y=hexCoords.y+2, z=hexCoords.z})
    local topLeft = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y+2, z=hexCoords.z})
    local bottomRight = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x, y=hexCoords.y-2, z=hexCoords.z})
    local bottomLeft = ChipUtils.CountSevenHex(localPile, {x=hexCoords.x-2, y=hexCoords.y-2, z=hexCoords.z})

    local center_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})
    local right_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y, z=hexCoords.z})
    local left_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y, z=hexCoords.z})
    local topRight_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+2, y=hexCoords.y+2, z=hexCoords.z})
    local topLeft_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+2, z=hexCoords.z})
    local bottomRight_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-2, z=hexCoords.z})
    local bottomLeft_color = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-2, y=hexCoords.y-2, z=hexCoords.z})

    if center + right + left + topRight + topLeft + bottomRight + bottomLeft >= 7*7 then
        return {{x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z}, false}
    end

    local valueShift = 0
    if center_color then
        valueShift = valueShift + ((cIndex - center_color)*1)
    end
    if right_color then
        if cIndex > right_color then
            valueShift = valueShift + ((cIndex - right_color)*1)
        elseif cIndex == right_color then
            valueShift = valueShift + 1
        end
    end
    if left_color then
        if cIndex < left_color then
            valueShift = valueShift + ((cIndex - left_color)*1)
        elseif cIndex == left_color then
            valueShift = valueShift - 1
        end
    end
    if topRight_color then
        if cIndex > topRight_color then
            valueShift = valueShift + ((cIndex - topRight_color)*1)
        elseif cIndex == topRight_color then
            valueShift = valueShift + 1
        end
    end
    if topLeft_color then
        if cIndex < topLeft_color then
            valueShift = valueShift + ((cIndex - topLeft_color)*1)
        elseif cIndex == topLeft_color then
            valueShift = valueShift - 1
        end
    end
    if bottomRight_color then
        if cIndex > bottomRight_color then
            valueShift = valueShift + ((cIndex - bottomRight_color)*1)
        elseif cIndex == bottomRight_color then
            valueShift = valueShift + 1
        end
    end
    if bottomLeft_color then
        if cIndex < bottomLeft_color then
            valueShift = valueShift + ((cIndex - bottomLeft_color)*1)
        elseif cIndex == bottomLeft_color then
            valueShift = valueShift - 1
        end
    end
    --valueShift = math.floor(valueShift+0.5) --round floats
    if valueShift < -3 then valueShift = -3 end
    if valueShift > 3 then valueShift = 3 end


    --average point calc
    local spotsTable = {}
    for i=1,center do table.insert(spotsTable, {x=0, y=0, z=0}) end
    for i=1,right do table.insert(spotsTable, {x=2, y=0, z=0}) end
    for i=1,left do table.insert(spotsTable, {x=-2, y=0, z=0}) end
    for i=1,topRight do table.insert(spotsTable, {x=1, y=2, z=0}) end
    for i=1,topLeft do table.insert(spotsTable, {x=-1, y=2, z=0}) end
    for i=1,bottomRight do table.insert(spotsTable, {x=1, y=-2, z=0}) end
    for i=1,bottomLeft do table.insert(spotsTable, {x=-1, y=-2, z=0}) end
    local runningX = 0
    local runningY = 0
    local runningZ = 0
    for i,v in ipairs(spotsTable) do
        runningX = runningX + v.x
        runningY = runningY + v.y
        runningZ = runningZ + v.z
    end
    runningX = runningX / #spotsTable
    runningY = runningY / #spotsTable
    runningZ = runningZ / #spotsTable

    local averageCoords = {x=runningX, y=runningY, z=runningZ}

    local totalStacks = center + right + left + topRight + topLeft + bottomRight + bottomLeft -- 37 spots in wide search, 7 overlap
    local shiftStackCountMiddle = totalStacks - 15
    local stackAverageShift = 2
    local stackShifted = 0
    if shiftStackCountMiddle >= 0 then
        stackShifted = MapVar(shiftStackCountMiddle, 0, 22, 0, -stackAverageShift)--just changed this, have to test if widehex still spits the chip 3 spaces away
    else
        stackShifted = MapVar(shiftStackCountMiddle, 0, -15, 0, stackAverageShift)
    end

    local shiftedAverageCoords = {x=averageCoords.x*stackShifted, y=averageCoords.y*stackShifted, z=averageCoords.z*stackShifted}
    shiftedAverageCoords.y = shiftedAverageCoords.y * 2 --shift in favor of y change.
    local relativeStandardCoords = {
                                    x = shiftedAverageCoords.x + 0.5 * shiftedAverageCoords.y,
                                    y = shiftedAverageCoords.y,
                                    z = shiftedAverageCoords.z
                                }


    local relativeOutCoords = {x=relativeStandardCoords.x, y=relativeStandardCoords.y, z=relativeStandardCoords.z}

    relativeOutCoords.x = relativeOutCoords.x + valueShift

    --check how much in center, right, & left. If yes, force a Y change of +-1
    if center >=4 and right >=7 and left >=4 then
        local topCount = topRight + topLeft
        local bottomCount = bottomRight + bottomLeft
        if topCount > bottomCount then
            relativeOutCoords.y = relativeOutCoords.y - 1
        else --topCount <= bottomCount then
            relativeOutCoords.y = relativeOutCoords.y + 1
        end
        if center >=5 or left >=5 then
            relativeOutCoords.y = relativeOutCoords.y * 2
        end
    end

    local roundedOutCoords = {x=0,y=0,z=0}
    roundedOutCoords.x = math.floor(relativeOutCoords.x+0.5)
    roundedOutCoords.y = math.floor(relativeOutCoords.y+0.5)
    roundedOutCoords.z = math.floor(relativeOutCoords.z+0.5)

    if roundedOutCoords.x == 0 and roundedOutCoords.y == 0 and roundedOutCoords.z == 0 then --force a spot change if search returns center 0,0,0
        local divisorN = 1
        if relativeOutCoords.x > relativeOutCoords.y and relativeOutCoords.x > relativeOutCoords.z then
            divisorN = 1 / relativeOutCoords.x
        elseif relativeOutCoords.y > relativeOutCoords.x and relativeOutCoords.y > relativeOutCoords.z then
            divisorN = 1 / relativeOutCoords.y
        else
            divisorN = 1 / relativeOutCoords.z
        end
        if roundedOutCoords.x ~= 0 then roundedOutCoords.x = math.floor((relativeOutCoords.x*divisorN)+0.5) end
        if roundedOutCoords.y ~= 0 then roundedOutCoords.y = math.floor((relativeOutCoords.y*divisorN)+0.5) end
        if roundedOutCoords.z ~= 0 then roundedOutCoords.z = math.floor((relativeOutCoords.z*divisorN)+0.5) end
        if roundedOutCoords.x == 0 and roundedOutCoords.y == 0 and roundedOutCoords.z == 0 then --full force! hopefully never triggers
            if DualPrint then DualPrint('=e Minor chip placement error, forcing a spot change. Code: 6578') end
            roundedOutCoords.x = 1
        end
    end

    local outCoords = {x=hexCoords.x+roundedOutCoords.x, y=hexCoords.y+roundedOutCoords.y, z=hexCoords.z+roundedOutCoords.z}

    if outCoords.x < localPile.limits.minX then outCoords.x = localPile.limits.minX +1 end
    if outCoords.x > localPile.limits.maxX then outCoords.x = localPile.limits.maxX -1 end
    if outCoords.y < localPile.limits.minY then outCoords.y = localPile.limits.minY +1 end
    if outCoords.y > localPile.limits.maxY then outCoords.y = localPile.limits.maxY -1 end
    if outCoords.z < localPile.limits.minZ then outCoords.z = localPile.limits.minZ +1 end
    if outCoords.z > localPile.limits.maxZ then outCoords.z = localPile.limits.maxZ -1 end

    return {{x=outCoords.x, y=outCoords.y, z=outCoords.z}, false}
end

function ChipUtils.CountSevenHex(localPile, hexCoords) --check each stack spot nearby, return number of stacks
    local center = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y, z=hexCoords.z})
    local onLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y, z=hexCoords.z})
    local onRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y, z=hexCoords.z})
    local topLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y+1, z=hexCoords.z})
    local topRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x+1, y=hexCoords.y+1, z=hexCoords.z})
    local bottomLeft = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x-1, y=hexCoords.y-1, z=hexCoords.z})
    local bottomRight = ChipUtils.CheckStackLayoutCoords(localPile, {x=hexCoords.x, y=hexCoords.y-1, z=hexCoords.z})

    local count = 0
    if center then count = count + 1 end --count how many slots are occupied
    if onLeft then count = count + 1 end
    if onRight then count = count + 1 end
    if topLeft then count = count + 1 end
    if topRight then count = count + 1 end
    if bottomLeft then count = count + 1 end
    if bottomRight then count = count + 1 end

    return count
end

function ChipUtils.CheckStackLayoutCoords(localPile, coords) --returns color index of stack if coords are occupied, false if empty
    --DualPrint('[==g Ran CheckStackLayoutCoords()')
    if not (coords.x >= localPile.limits.minX and
        coords.x <= localPile.limits.maxX and
        coords.y >= localPile.limits.minY and
        coords.y <= localPile.limits.maxY and
        coords.z >= localPile.limits.minZ and
        coords.z <= localPile.limits.maxZ) then
            --DualPrint('=g coords are not in bounds')
            return 16
    end
    for i,v in ipairs(localPile.stacksInfo) do
        if (v.hexCoords.x == coords.x and
            v.hexCoords.y == coords.y and
            v.hexCoords.z == coords.z) then
                return v.cIndex
        end
    end
    return false
end

-- Value conversion functions
function ChipUtils.ValueToPileQueueSimple(localPile, queue, value, betsPileQueue) -- add value to pileQueue table, converts into chip denominations
    local valueRemaining = value
    local colorsSoFar = 0
    local piles = {}
    local splitSizing = 0.4
    local minChips = 6 -- minimum number of chips required to give a particular chip denomination
    local minColors = 3 -- minimum number of chip denominations required to force color variety
    local queuedChips = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    local maxChipsPerColor = 10
    if queue == betsPileQueue then
        if value >= 1000000 then
            minChips = 3
            minColors = 3
        elseif value >= 100000 then
            minChips = 3
            minColors = 2
        elseif value >= 10000 then
            minChips = 2
            minColors = 1
        else
            minChips = 1
            minColors = 1
        end
    else
        if value > 1000000 then
            minChips = 1
        elseif value > 100000 then
            minChips = 3
        end
    end
    for i, j in ipairs(chip_values) do
        local tableIndex = -i + 17
        local denomination = chip_values[tableIndex]
        if denomination * minChips <= valueRemaining or tableIndex <= 3 then
            local chipCount = 0
            Game.GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_bet")

            if colorsSoFar < minColors then
                chipCount = math.floor(valueRemaining * splitSizing / denomination)
            else
                chipCount = math.floor(valueRemaining / denomination)
            end
            if chipCount > 0 then
                colorsSoFar = colorsSoFar + 1
                valueRemaining = valueRemaining - chipCount * denomination

                queuedChips[tableIndex] = queuedChips[tableIndex] + chipCount
            end
        end
    end

    if queue == betsPileQueue then
        local loopCount = 0
        local noValuesOverMax = false
        while noValuesOverMax == false do
            noValuesOverMax = true
            loopCount = loopCount + 1
            for i, j in ipairs(queuedChips) do
                if i == 16 then
                    break
                end
                if j > maxChipsPerColor then
                    noValuesOverMax = false
                    local chipExtras = j - maxChipsPerColor
                    local extraValue = chip_values[i] * chipExtras
                    local higherChipFitCountRaw = extraValue /chip_values[i+1]
                    --potentially check if I can do 1 more chip in future, since I have 10 chips of 'padding' 'left over'
                    local higherChipFitCount = math.floor(higherChipFitCountRaw)
                    local lowerChipValue = 0
                    local lowerChipFitCount = 0
                    --check if i is divisible by i-1
                    local lowerChipIndex = 1
                    if (chip_values[i] % chip_values[i-1]) ~= 0 then
                        lowerChipIndex = 2
                    end
                    if (higherChipFitCountRaw - higherChipFitCount) > 0 then -- if there's a remainder, pay lower chip difference
                        lowerChipValue = (higherChipFitCountRaw - higherChipFitCount) * chip_values[i+1]
                        lowerChipFitCount = math.floor(lowerChipValue / chip_values[i-lowerChipIndex])
                    end
                    local higherValue = higherChipFitCount * chip_values[i+1]
                    local lowerValue = lowerChipFitCount * chip_values[i-lowerChipIndex]
                    local targetChipRemoveCount = (higherValue + lowerValue) / chip_values[i]

                    queuedChips[i] = queuedChips[i] - targetChipRemoveCount
                    queuedChips[i+1] = queuedChips[i+1] + higherChipFitCount
                    queuedChips[i-lowerChipIndex] = queuedChips[i-lowerChipIndex] + lowerChipFitCount
                end
            end
            if loopCount > 15 then
                if DualPrint then DualPrint('=M ERROR noValuesOverMax loop stuck, code 5489') end
                noValuesOverMax = true
            end
        end
    end

    if valueRemaining > 0 then --catch any extra value. Should be unnecessary, but just a safeguard
        --DualPrint('=M ERROR: valueRemaining > 0, CODE 3389')
                --supressed until I look into it. idk, its spamming my console but the game works. #TODO
                        --prints on wheel press UI trigger, and when main menu UI returns after chip payout.
        queuedChips[1] = queuedChips[1] + valueRemaining
    end

    for i, j in ipairs(queuedChips) do
        local tableIndex = -i + 17
        if queuedChips[tableIndex] > 0 then
            table.insert(queue, {pile=localPile,cIndex=tableIndex,amount=queuedChips[tableIndex]})
        end
    end
end

function ChipUtils.ValueToQueueSubtraction(localPile, value, pileQueue, pileSubtractionQueue) -- find chips in pile that add up to value, set chips to subtractionQueue
    if localPile.value < value then --catch in case of value higher then total chips
        if DualPrint then DualPrint('=p FATAL ERROR: localPile.value < value, CODE 4781') end
        return
    end

    local valueRemaining = value
    local pileQueueChips = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} --record of chip moves to send to queues

    --create table of all pile chips
    local pileChips = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} --record of current pile chips, updates internally
    for i, j in ipairs(pileChips) do --set pileChips[i] equal to total chips of that color
        pileChips[i] = localPile.singleStacks[i]
        pileChips[i] = pileChips[i] + ( localPile.fullStacks[i] * 10 )
    end

    while valueRemaining > 0 do
        subtractionValueLoopCount = subtractionValueLoopCount + 1
        --for every chip color used in localPile, from highest to lowest, check max chip count that can be removed towards value
        for i, j in ipairs(pileChips) do
            local ri = -i + 17 --reverse index to start from higher value chips
            local chipValue = chip_values[ri]
            if pileChips[ri] > 0 then
                if valueRemaining >= chipValue then
                    local fitChipCount = math.floor(valueRemaining / chipValue)
                    local chipsToUse = 0
                    if fitChipCount > pileChips[ri] then
                        chipsToUse = pileChips[ri]
                    else
                        chipsToUse = fitChipCount
                    end
                    valueRemaining = valueRemaining - (chipsToUse * chipValue)
                    pileQueueChips[ri] = pileQueueChips[ri] - chipsToUse
                    pileChips[ri] = pileChips[ri] - chipsToUse

                    subtractionValueLoopCount = 0 --?? is this the right spot? --left off here 5/20 2AM
                end
            end
        end
        if valueRemaining == 0 then
            break
        end
        --logic to split pile chips / make change
        for i, j in ipairs(pileChips) do
            local chipValue = chip_values[i] --cash value of current indexed chip
            local pastChipValue = chip_values[i-1]
            if
                i > 1  and --can't make change for 1 cent
                valueRemaining < chipValue and
                pileChips[i] > 0 --check if the pile can give a chip for change
            then
                pileQueueChips[i] = pileQueueChips[i] - 1 --remove 1 chip from pile
                pileChips[i] = pileChips[i] - 1 --remove chip to update pileChips record, used in while loop
                --new chips:
                local firstChangeChipsRaw = chipValue / pastChipValue-- how many new chips can be made, float
                local firstChangeChipsRounded = math.floor(firstChangeChipsRaw)
                local firstChangeRemainder = firstChangeChipsRaw - firstChangeChipsRounded --find what change is left, if half chip then repeat for next lower chip
                pileQueueChips[i-1] = pileQueueChips[i-1] + firstChangeChipsRounded --insert change into pile
                pileChips[i-1] = pileChips[i-1] + firstChangeChipsRounded --update pile reference
                if firstChangeRemainder > 0 and chip_values[i-2] then --if there is change and there is a chip color 2 lower
                    --new 2nd chips: (kinda a repeat of above)
                    local rawRemainderValue = firstChangeRemainder * pastChipValue
                    local oldChipValue = chip_values[i-2]
                    local secondChangeChipsRaw = rawRemainderValue / oldChipValue
                    local secondChangeChipsRounded = math.floor(secondChangeChipsRaw)
                    local secondChangeRemainder = secondChangeChipsRaw - secondChangeChipsRounded
                    pileQueueChips[i-2] = pileQueueChips[i-2] + secondChangeChipsRounded
                    pileChips[i-2] = pileChips[i-2] + secondChangeChipsRounded
                    if secondChangeRemainder > 0 then
                        if DualPrint then DualPrint('=p FATAL ERROR: secondChangeRemainder > 0, CODE 3876, secondChangeRemainder = '..secondChangeRemainder) end --remaining change after 2 colors lower? weird. try logging
                        return
                    end
                end
                break
            else
                --DualPrint('=p skipped chip, i: '..i..' valueRemaining: '..valueRemaining..' chipValue: '..chipValue..' pileChips[i]: '..pileChips[i])
            end
        end
        if subtractionValueLoopCount > 20 then
            if DualPrint then DualPrint('=p FATAL ERROR: subtractionValueLoopCount > 20, CODE 2642') end --major loop issue. log away.  I know I'll be here again...-5/20/24-1:58AM. Occur tally: 2
            return
        end
    end --end while loop

    --DualPrint('=p pileQueueChips: {'..pileQueueChips[1]..','..pileQueueChips[2]..','..pileQueueChips[3]..','..pileQueueChips[4]..','..pileQueueChips[5]..','..pileQueueChips[6]..','..pileQueueChips[7]..','..pileQueueChips[8]..','
    --                                ..pileQueueChips[9]..','..pileQueueChips[10]..','..pileQueueChips[11]..','..pileQueueChips[12]..','..pileQueueChips[13]..','..pileQueueChips[14]..','..pileQueueChips[15]..','..pileQueueChips[16]..'}')
    for i, j in ipairs(pileQueueChips) do --for every non-zero, add to pileQueue or pileSubtractionQueue
        if j > 0 then
            table.insert(pileQueue, {pile=localPile,cIndex=i,amount=j})
        elseif j < 0 then
            local valueJ = -j --invert negative for subtraction queue
            table.insert(pileSubtractionQueue, {pile=localPile,cIndex=i,amount=valueJ})
        end
    end
end

-- Getter functions for data
function ChipUtils.GetMaxStackSize()
    return maxStackSize
end

function ChipUtils.ResetSearchState()
    stackSearchOld = {x=234, y=543, z=345} --reset stack search stuck checking info
    stackSearchPrevious = {x=753, y=653, z=856}
    stackSearchCurrent = {x=427, y=148, z=993}
end

return ChipUtils

