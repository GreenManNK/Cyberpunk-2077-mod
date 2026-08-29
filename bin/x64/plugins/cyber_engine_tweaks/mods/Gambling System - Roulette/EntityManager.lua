EntityManager = {
    version = '1.0.0'
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

-- Private data structures
local entRecords = {} -- global live entity record
-- { name = devName, id = id }  --table format
-- entRecords[1].id             --reference format
local historicalEntRecords = {} --never deleted entRecords copy, used for despawn error correction.

-- Private dependencies (set via Initialize)
local TableManager = nil

-- Initialize function
function EntityManager.Initialize(deps)
    TableManager = deps.TableManager
end

-- Record management functions (for InitTable integration)
function EntityManager.AddToRecords(devName, id)
    -- Remove any existing entry with this name first
    for i = #entRecords, 1, -1 do
        if entRecords[i].name == devName then
            table.remove(entRecords, i)
        end
    end
    -- Add to both entRecords and historicalEntRecords
    table.insert(entRecords, { name = devName, id = id })
    table.insert(historicalEntRecords, { name = devName, id = id })
end

function EntityManager.RemoveFromRecords(devName)
    -- Remove from entRecords only (historicalEntRecords stays)
    local foundMatch = 1
    while foundMatch > 0 do
        foundMatch = 0
        for i = #entRecords, 1, -1 do
            if entRecords[i].name == devName then
                table.remove(entRecords, i)
                foundMatch = 1
                break
            end
        end
    end
end

function EntityManager.GetEntRecords()
    return entRecords  -- For debugging/verification
end

-- Function 1: Despawn
function EntityManager.Despawn(id) --despawns a codeware entity from id
    --original function code by anygoodname
    if not id then return end
    if Codeware then Game.GetDynamicEntitySystem():DeleteEntity(id) return end
end

-- Function 2: SpawnWithCodeware
function EntityManager.SpawnWithCodeware(pathOrID, appName, locationTable, orientationTable, tags) --spawns an entity with codeware
    -- original function code by anygoodname
    --todo: update this to codeware's newer static entity system (I probably wont until my next(c) project lol)
    if not Codeware then return end
    local entitySystem = Game.GetDynamicEntitySystem()
    if not entitySystem then return end
    if type(pathOrID) ~= 'string' then return end
    if not IsStringValid(pathOrID) then return end
    local isRecord, isValid = false, false
    if TweakDB:GetRecord(pathOrID) then isRecord = true isValid = true end
    if (not isRecord) and string.match(pathOrID, '%.ent$') then isValid = true end
    if not isValid then return end
    local entSpec = DynamicEntitySpec.new()
    if isRecord then entSpec.recordID = pathOrID else entSpec.templatePath = pathOrID end
    if type(appName) == 'string' then entSpec.appearanceName = appName end
    local playerTransform = Game.GetPlayer():GetWorldTransform()
    local newLocation = {}
    if locationTable then
        newLocation = {x=locationTable.x, y=locationTable.y, z=locationTable.z}
    else
        local tableCenterPoint = TableManager.GetActiveTableCenterPoint()
        if not tableCenterPoint then
            -- Fallback to player position if tableCenterPoint not available (e.g., during initialization)
            local playerPos = playerTransform:GetWorldPosition()
            newLocation = {x=playerPos:GetX(), y=playerPos:GetY(), z=playerPos:GetZ()}
        else
            newLocation = {x=tableCenterPoint.x, y=tableCenterPoint.y, z=tableCenterPoint.z}
        end
    end
    entSpec.position = Vector4.new(newLocation.x, newLocation.y, newLocation.z, 1)
    if orientationTable then
        -- orientationTable can be EulerAngles or a table with {r, p, y}
        if type(orientationTable) == "table" and orientationTable.r then
            entSpec.orientation = EulerAngles.new(orientationTable.r, orientationTable.p, orientationTable.y):ToQuat()
        elseif type(orientationTable) == "userdata" and orientationTable.ToQuat then
            entSpec.orientation = orientationTable:ToQuat()
        else
            entSpec.orientation = playerTransform:GetOrientation()
        end
    else
        entSpec.orientation = playerTransform:GetOrientation()
    end
    entSpec.alwaysSpawned = true
    entSpec.spawnInView = true
    entSpec.active = true
    if type(tags) == 'table' then entSpec.tags = tags end
    --DualPrint('[-- Spawning with Codeware; ent: '..string.sub(pathOrID,31,string.len(pathOrID))..', appearance: '..appName..', x: '..entSpec.position.x..', y: '..entSpec.position.y..', z: '..entSpec.position.z)
    return entitySystem:CreateEntity(entSpec)
end

-- Function 3: RegisterEntity
function EntityManager.RegisterEntity(devName, entSrc, appName, location, orientation, tags) -- create entity and add to local system, pass location as table = {x=0,y=0,z=0}
    for i,v in ipairs(entRecords) do --check if entity already exists
        if v.name == devName then --if exists, exit function
            do return end
        end
    end
    local newTags = {"[Boe6]","[Gambling System]","[Roulette]"}
    if tags then
        for i,v in ipairs(tags) do
            table.insert(newTags, v)
        end
    end
    local id = EntityManager.SpawnWithCodeware(entSrc, appName, location, orientation, newTags) --create entity
    table.insert(entRecords, { name = devName, id = id }) -- save entity id to entRecords w/ a devName
    table.insert(historicalEntRecords, { name = devName, id = id }) --save copy to historicalEntRecords, for error handling
end

-- Function 4: DeRegisterEntity
function EntityManager.DeRegisterEntity(devName) -- delete and remove entity from local system
    --DualPrint('[==q Ran DeRegisterEntity(), devName: '..devName)

    local entID = EntityManager.FindEntIdByName(devName)
    if not entID then
        -- Entity ID not found, just clean up entRecords
        local foundMatch = 1
        while foundMatch > 0 do
            foundMatch = 1
            for i,v in ipairs(entRecords) do
                if v.name == devName then
                    table.remove(entRecords, i)
                    foundMatch = 2
                    break
                end
            end
            if foundMatch == 1 then
                foundMatch = 0
            end
        end
        return
    end
    local entity = Game.FindEntityByID(entID)
    if entity == nil then
        --DualPrint('=q entity is nil')
        -- Remove from entRecords even if entity is nil
        local foundMatch = 1
        while foundMatch > 0 do
            foundMatch = 1
            for i,v in ipairs(entRecords) do
                if v.name == devName then
                    table.remove(entRecords, i)
                    foundMatch = 2
                    break
                end
            end
            if foundMatch == 1 then
                foundMatch = 0
            end
        end
        return
    end
    local currentPos = entity:GetWorldPosition()
    --DualPrint('=q entity pos pre  x: '..currentPos.x..' y: '..currentPos.y..' z: '..currentPos.z)
    EntityManager.Despawn(entID) -- Use the entID we already retrieved

    local foundMatch = 1
    while foundMatch > 0 do
        foundMatch = 1
        for i,v in ipairs(entRecords) do --find matching devName in entRecords & add index to 'indicesToRemove' table
            if v.name == devName then
                table.remove(entRecords, i)
                --DualPrint('=q Removed devName: '..devName..' from entRecords')
                foundMatch = 2
                break
            end
        end
        if foundMatch == 1 then
            foundMatch = 0
        end
    end
end

-- Function 5: FindEntIdByName
function EntityManager.FindEntIdByName(devName, entList) -- find devName in entRecords and return id
    -- First, check TableManager for table-specific entities (roulette_spinner, roulette_ball, roulette_spinner_frame)
    -- These entities are tracked per table, so we need to get the active table's entity
    local tableSpecificEntities = {'roulette_spinner', 'roulette_ball', 'roulette_spinner_frame'}
    local isTableSpecific = false
    for _, name in ipairs(tableSpecificEntities) do
        if devName == name then
            isTableSpecific = true
            break
        end
    end
    
    if isTableSpecific then
        local activeTableID = TableManager.GetActiveTable()
        if activeTableID then
            local entID = TableManager.getTableEntity(activeTableID, devName)
            if entID then
                return entID
            end
        end
        -- If no active table or entity not found in TableManager, fall through to entRecords
    end
    
    -- For non-table-specific entities, check entRecords
    local indicies = {}
    for i,v in ipairs(entRecords) do --find all matches
        if v.name == devName then
            table.insert(indicies, i)
        end
    end
    for i,v in ipairs(indicies) do
        return entRecords[v].id --returns first match
    end
    --in case no matches, return chips0
    for i,v in ipairs(entRecords) do
        if v.name == 'chips0' then
            -- DualPrint('=G FindEntityByID() minor error, code 3098')
                --suppressed due to user confusion.
                --TODO: print v.name to look into cause
            return v.id
        end
    end
    -- Return nil if no entity found (instead of chips0 which may not exist)
    return nil
end

-- Function 6: MoveEnt
function EntityManager.MoveEnt(idName, xyz, rpy) --move entity by xyz realative to current position
    if not xyz then xyz = {x=0, y=0, z=0} return end --set default value

    local entID = EntityManager.FindEntIdByName(idName)
    if not entID then return end -- Check for nil entity ID before calling FindEntityByID
    local entity = Game.FindEntityByID(entID)
    if entity == nil then return end
    local currentRot = entity:GetWorldOrientation()
    local currentPos = entity:GetWorldPosition()
    local newPos = Vector4.new(currentPos.x + xyz.x, currentPos.y + xyz.y, currentPos.z + xyz.z, currentPos.w)
    local localRPY = {r=0, p=0, y=0}
    if rpy then
        localRPY = {r=rpy.r, p=rpy.p, y=rpy.y}
    end
    Game.GetTeleportationFacility():Teleport(entity, newPos, EulerAngles.new(localRPY.r, localRPY.p, localRPY.y))
end

-- Function 7: SetRotateEnt
function EntityManager.SetRotateEnt(idName, rpy) --teleport an entity to specified rotation at the same location
    if not rpy then rpy = {r=0, p=0, y=0} return end --set default value

    local entID = EntityManager.FindEntIdByName(idName)
    if not entID then return end -- Check for nil entity ID before calling FindEntityByID
    local entity = Game.FindEntityByID(entID)
    if entity == nil then return end
    local currentPos = entity:GetWorldPosition()
    local newRot = EulerAngles.new(rpy.r, rpy.p, rpy.y)
    Game.GetTeleportationFacility():Teleport(entity, currentPos, newRot)
end

-- Function 8: ForceClearAllEnts
function EntityManager.ForceClearAllEnts()
    for i,v in ipairs(historicalEntRecords) do
        -- i = { name = devName, id = id }
        if v.name ~= 'chips0' then
            EntityManager.Despawn(v.id)
        end
    end
end

return EntityManager

