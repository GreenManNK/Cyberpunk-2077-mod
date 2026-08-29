RelativeCoordinateCalulator = {
    version = '1.0.1',
    registeredTables = {},
    registeredOffsets = {},
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

---Registers a table with the RelativeCoordinateCalulator
---@param tableID string tableID
---@param tablePosition Vector4 table position
---@param tableOrientation Quaternion table orientation
function RelativeCoordinateCalulator.registerTable(tableID, tablePosition, tableOrientation)
    RelativeCoordinateCalulator.registeredTables[tableID] = {
        position = tablePosition,
        orientation = tableOrientation,
    }
end

---Registers an offset with the RelativeCoordinateCalulator
---@param offsetID string offsetID
---@param offsetPosition Vector4 offset position
---@param offsetOrientation Quaternion offset orientation
function RelativeCoordinateCalulator.registerOffset(offsetID, offsetPosition, offsetOrientation)
    RelativeCoordinateCalulator.registeredOffsets[offsetID] = {
        position = offsetPosition,
        orientation = offsetOrientation,
    }
end

---Calculates position relative to a base position, using table orientation for direction
---Use this for chaining cards: "right" always means table-right, not card-right
---@param basePosition Vector4 world position of the base entity (e.g., previous card)
---@param tableID string tableID to use for orientation reference
---@param relativeOffset Vector4|string offset position (Vector4) or registered offsetID (string) in table's local space
---@param relativeOrientation? Quaternion offset orientation (defaults to identity or offset's orientation if using offsetID)
---@return Vector4 worldPosition resulting world position
---@return Quaternion worldOrientation resulting world orientation
function RelativeCoordinateCalulator.calculateFromPositionWithTable(basePosition, tableID, relativeOffset, relativeOrientation)
    local table = RelativeCoordinateCalulator.registeredTables[tableID]
    if not table then
        DualPrint("Table '" .. tableID .. "' not found")
        return basePosition, Quaternion.new(0, 0, 0, 1)
    end
    
    -- Resolve offset: can be Vector4 or offsetID string
    local offsetPos, offsetOri
    if type(relativeOffset) == "string" then
        local offset = RelativeCoordinateCalulator.registeredOffsets[relativeOffset]
        if not offset then
            DualPrint("Offset '" .. relativeOffset .. "' not found")
            return basePosition, Quaternion.new(0, 0, 0, 1)
        end
        offsetPos = offset.position
        offsetOri = relativeOrientation or offset.orientation
    else
        offsetPos = relativeOffset
        offsetOri = relativeOrientation or Quaternion.new(0, 0, 0, 1)
    end
    
    -- Transform the relative offset by the TABLE's rotation
    local offsetPositionVector = Vector4.new(offsetPos.x, offsetPos.y, offsetPos.z, 0)
    local transformedOffsetPosition = table.orientation:Transform(offsetPositionVector)
    
    -- Add transformed offset to base position
    local worldPosition = Vector4.new(
        basePosition.x + transformedOffsetPosition.x,
        basePosition.y + transformedOffsetPosition.y,
        basePosition.z + transformedOffsetPosition.z,
        basePosition.w
    )
    
    -- Compose rotations: get basis vectors from relative orientation, transform by TABLE rotation
    local relativeForward = offsetOri:GetForward()
    local relativeUp = offsetOri:GetUp()
    
    -- Transform relative basis vectors by TABLE rotation
    local transformedForward = table.orientation:Transform(relativeForward)
    local transformedUp = table.orientation:Transform(relativeUp)
    
    -- Build the composed quaternion
    local worldOrientation = Quaternion.BuildFromDirectionVector(transformedForward, transformedUp)
    
    return worldPosition, worldOrientation
end

---Calculates position relative to a base position/orientation
---Use this when directions should be relative to the base entity itself
---@param basePosition Vector4 world position of the base entity
---@param baseOrientation Quaternion world orientation of the base entity
---@param relativeOffset Vector4 offset position in base's local space
---@param relativeOrientation? Quaternion offset orientation (defaults to identity)
---@return Vector4 worldPosition resulting world position
---@return Quaternion worldOrientation resulting world orientation
function RelativeCoordinateCalulator.calculateFromPosition(basePosition, baseOrientation, relativeOffset, relativeOrientation)
    local offsetOri = relativeOrientation or Quaternion.new(0, 0, 0, 1)
    
    -- Transform the relative offset by the base's rotation
    local offsetPositionVector = Vector4.new(relativeOffset.x, relativeOffset.y, relativeOffset.z, 0)
    local transformedOffsetPosition = baseOrientation:Transform(offsetPositionVector)
    
    -- Add transformed offset to base position
    local worldPosition = Vector4.new(
        basePosition.x + transformedOffsetPosition.x,
        basePosition.y + transformedOffsetPosition.y,
        basePosition.z + transformedOffsetPosition.z,
        basePosition.w
    )
    
    -- Compose rotations: get basis vectors from relative orientation, transform by base rotation
    local relativeForward = offsetOri:GetForward()
    local relativeUp = offsetOri:GetUp()
    
    -- Transform relative basis vectors by base rotation
    local transformedForward = baseOrientation:Transform(relativeForward)
    local transformedUp = baseOrientation:Transform(relativeUp)
    
    -- Build the composed quaternion
    local worldOrientation = Quaternion.BuildFromDirectionVector(transformedForward, transformedUp)
    
    return worldPosition, worldOrientation
end

---Calculates the relative coordinate and rotation of an entity relative to a table
---@param tableID string tableID
---@param offsetID string offsetID
---@return Vector4 relativePosition world position
---@return Quaternion relativeOrientation world orientation
function RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, offsetID)
    local table = RelativeCoordinateCalulator.registeredTables[tableID]
    if not table then
        DualPrint('[==e ERROR: Table '..tostring(tableID)..' not found in registeredTables')
        return nil, nil
    end
    
    local offset = RelativeCoordinateCalulator.registeredOffsets[offsetID]
    if not offset then
        -- spinner_center_point is optional (only needed for roulette, not blackjack)
        -- Don't spam error messages for optional offsets
        if offsetID ~= 'spinner_center_point' then
            DualPrint('[==e ERROR: Offset '..tostring(offsetID)..' not found in registeredOffsets')
        end
        return nil, nil
    end
    
    local offsetPositionVector = Vector4.new(offset.position.x, offset.position.y, offset.position.z, 0)
    local transformedOffsetPosition
    local basePosition
    local baseOrientation
    
    -- spinner_center_point is an offset in the table's local space
    -- It should be rotated by table orientation to get world-space offset
    -- The registered offset value was measured from hooh table in world space, but represents
    -- the local-space relationship (spinner position relative to table in table's coordinate system)
    if offsetID == 'spinner_center_point' then
        -- Rotate the offset by table orientation (it's in table's local space)
        transformedOffsetPosition = table.orientation:Transform(offsetPositionVector)
        basePosition = table.position
        baseOrientation = table.orientation
    else
        -- For all other offsets, try to use spinner_center_point if available (roulette)
        -- Otherwise, fall back to table position (blackjack)
        local spinnerCenterPos, spinnerCenterOri = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'spinner_center_point')
        if spinnerCenterPos then
            -- Roulette: offsets are relative to spinner_center_point
            transformedOffsetPosition = table.orientation:Transform(offsetPositionVector)
            basePosition = spinnerCenterPos
            baseOrientation = spinnerCenterOri
        else
            -- Blackjack: offsets are relative to table position directly
            -- (spinner_center_point not registered, which is fine for blackjack)
            transformedOffsetPosition = table.orientation:Transform(offsetPositionVector)
            basePosition = table.position
            baseOrientation = table.orientation
        end
    end
    
    -- Calculate final position
    local relativePosition = Vector4.new(
        basePosition.x + transformedOffsetPosition.x,
        basePosition.y + transformedOffsetPosition.y,
        basePosition.z + transformedOffsetPosition.z,
        basePosition.w
    )
    
    -- Compose rotations properly: get basis vectors from offset, transform by table rotation
    -- This applies offset rotation first, then table rotation (equivalent to table * offset)
    local offsetForward = offset.orientation:GetForward()
    local offsetUp = offset.orientation:GetUp()
    
    -- Transform the offset's basis vectors by the table's rotation
    local transformedForward = table.orientation:Transform(offsetForward)
    local transformedUp = table.orientation:Transform(offsetUp)
    
    -- Build the composed quaternion from the transformed vectors
    local relativeOrientation = Quaternion.BuildFromDirectionVector(transformedForward, transformedUp)
    
    return relativePosition, relativeOrientation
end

return RelativeCoordinateCalulator