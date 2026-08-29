TableManager = {
    version = '1.1.1',
    activeTableID = nil,
    dealerEntIDs = {}, -- Track dealer entity IDs per table: dealerEntIDs[tableID] = entID
    dealerSpawned = {}, -- Track spawn state per table: dealerSpawned[tableID] = true/false
    tableEntities = {}, -- Track generic entities per table: tableEntities[tableID] = {entityName = entID, ...}
    tableLoaded = {}, -- Track loaded state per table: tableLoaded[tableID] = true/false
    optionalTables = {}, -- Track optional tables with dependency checks: optionalTables[tableID] = {tableData, dependencyCheck}
    tableCenterPoints = {} -- Track table center points per table: tableCenterPoints[tableID] = {x, y, z}
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local GameLocale = require("External/GameLocale.lua")

---Initializes the TableManager
function TableManager.init()
    -- TODO: Initialize table management system
end

---Loads tables from BlackjackCoordinates and creates spots for each
---@param forcedCameraOption table table containing forced camera option: {[1] = boolean}
function TableManager.LoadTables(forcedCameraOption)
    for tableID, _ in pairs(RelativeCoordinateCalulator.registeredTables) do
        TableManager.createSpotForTable(tableID, forcedCameraOption)
    end
end

---Sets the active table
---@param tableID string tableID to set as active
function TableManager.SetActiveTable(tableID)
    TableManager.activeTableID = tableID
end

---Clears the active table
function TableManager.ClearActiveTable()
    TableManager.activeTableID = nil
end

---Gets the currently active table ID
---@return string|nil active table ID or nil if no table is active
function TableManager.GetActiveTable()
    return TableManager.activeTableID
end

--- Sets the table center point for a specific table
---@param tableID string table ID
---@param centerPoint table center point: {x, y, z}
function TableManager.SetTableCenterPoint(tableID, centerPoint)
    if not tableID or not centerPoint then
        return
    end
    TableManager.tableCenterPoints[tableID] = {
        x = centerPoint.x,
        y = centerPoint.y,
        z = centerPoint.z
    }
end

--- Gets the table center point for a specific table
---@param tableID string table ID
---@return table|nil center point: {x, y, z} or nil if not set
function TableManager.GetTableCenterPoint(tableID)
    if not tableID then
        return nil
    end
    return TableManager.tableCenterPoints[tableID]
end

--- Gets the table center point for the currently active table
---@return table|nil center point: {x, y, z} or nil if no active table or center point not set
function TableManager.GetActiveTableCenterPoint()
    local activeTableID = TableManager.GetActiveTable()
    if not activeTableID then
        return nil
    end
    return TableManager.GetTableCenterPoint(activeTableID)
end

--- Spawns NPC dealer behind the blackjack table.
---@param tableID string table ID to spawn dealer at
function TableManager.spawnDealer(tableID)
    if TableManager.dealerSpawned[tableID] then
        return -- Dealer already spawned for this table
    end
    
    local dealerPosition, dealerOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'dealer_spawn_position')
    
    -- Check if coordinate calculation failed (returns nil or invalid position)
    if not dealerPosition or not dealerOrientation then
        DualPrint("Error: Failed to calculate dealer spawn position for table " .. tostring(tableID))
        return
    end
    
    -- Additional safety check: ensure position is not at origin (0,0,0) which likely indicates failure
    if dealerPosition.x == 0 and dealerPosition.y == 0 and dealerPosition.z == 0 then
        DualPrint("Error: Dealer spawn position is at origin (0,0,0) for table " .. tostring(tableID) .. ", aborting spawn")
        return
    end
    
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local spec = DynamicEntitySpec.new()
    spec.recordID = "Character.sts_wat_kab_07_croupiers"
    spec.appearanceName = "Random"
    spec.position = dealerPosition
    spec.orientation = dealerOrientation
    spec.tags = {"Blackjack","dealer"};
    local entID = dynamicEntitySystem:CreateEntity(spec)
    
    TableManager.dealerEntIDs[tableID] = entID
    TableManager.dealerSpawned[tableID] = true
end

--- Despawns the dealer for a specific table
---@param tableID string table ID to despawn dealer for
function TableManager.despawnDealer(tableID)
    if not TableManager.dealerSpawned[tableID] then
        return -- No dealer spawned for this table
    end
    
    local entID = TableManager.dealerEntIDs[tableID]
    if entID ~= nil then
        Game.GetDynamicEntitySystem():DeleteEntity(entID)
        TableManager.dealerEntIDs[tableID] = nil
    end
    TableManager.dealerSpawned[tableID] = false
end

--- Cleans up all dealers across all tables
function TableManager.cleanupAllDealers()
    for tableID, _ in pairs(TableManager.dealerSpawned) do
        TableManager.despawnDealer(tableID)
    end
end

--- Checks if a dealer is spawned for a specific table
---@param tableID string table ID to check
---@return boolean true if dealer is spawned for this table
function TableManager.isDealerSpawned(tableID)
    return TableManager.dealerSpawned[tableID] == true
end

--- Gets the dealer entity ID for a specific table
---@param tableID string table ID
---@return EntityID|nil dealer entity ID or nil if not spawned
function TableManager.getDealerEntID(tableID)
    return TableManager.dealerEntIDs[tableID]
end

--===================
-- Phase 2.1: Generic Entity Management
--===================

--- Spawns a generic entity for a specific table
---@param tableID string table ID to spawn entity at
---@param entityName string unique name identifier for the entity
---@param entPath string path to the entity file (.ent)
---@param position Vector4|nil world position (if nil, will be calculated from offsetID)
---@param orientation Quaternion|nil world orientation (if nil, will be calculated from offsetID)
---@param offsetID string|nil offset ID to calculate position/orientation from (if position/orientation are nil)
---@param tags table|nil additional tags to add to entity (default: {"[Boe6]","[Gambling System]"})
---@return EntityID|nil entity ID if spawned successfully, nil otherwise
function TableManager.spawnTableEntity(tableID, entityName, entPath, position, orientation, offsetID, tags)
    -- Initialize table entities tracking if needed
    if not TableManager.tableEntities[tableID] then
        TableManager.tableEntities[tableID] = {}
    end
    
    -- Check if entity already exists
    if TableManager.tableEntities[tableID][entityName] then
        return TableManager.tableEntities[tableID][entityName]
    end
    
    -- Calculate position/orientation from offset if not provided
    if not position or not orientation then
        if not offsetID then
            -- Try to use entityName as offsetID if no offsetID provided
            offsetID = entityName
        end
        local calculatedPos, calculatedOri = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, offsetID)
        if calculatedPos and calculatedOri then
            position = calculatedPos
            orientation = calculatedOri
        else
            -- Fallback: use table center position
            local tableData = RelativeCoordinateCalulator.registeredTables[tableID]
            if tableData then
                position = tableData.position
                orientation = tableData.orientation
            else
                return nil
            end
        end
    end
    
    -- Default tags
    local entityTags = {"[Boe6]", "[Gambling System]"}
    if tags then
        for _, tag in ipairs(tags) do
            table.insert(entityTags, tag)
        end
    end
    
    -- Check if Codeware is available (required for entity spawning)
    if not Codeware then
        DualPrint('[==e ERROR: Codeware is not available! Entity spawning requires Codeware.')
        return nil
    end
    
    -- Spawn entity using DynamicEntitySystem
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    if not dynamicEntitySystem then
        DualPrint('[==e ERROR: DynamicEntitySystem is not available!')
        return nil
    end
    
    -- Validate entPath
    if type(entPath) ~= 'string' then
        DualPrint('[==e ERROR: entPath must be a string, got: '..type(entPath))
        return nil
    end
    
    -- Check if string is valid (Codeware utility, if available)
    if IsStringValid then
        if not IsStringValid(entPath) then
            DualPrint('[==e ERROR: entPath string is not valid: '..tostring(entPath))
            return nil
        end
    end
    
    local spec = DynamicEntitySpec.new()
    
    -- Check if entPath is a record ID or template path (.ent file)
    local isRecord = false
    local isValid = false
    
    if TweakDB and TweakDB:GetRecord(entPath) then
        isRecord = true
        isValid = true
        spec.recordID = entPath
    elseif string.match(entPath, '%.ent$') then
        isValid = true
        spec.templatePath = entPath
    else
        -- Fallback: try as recordID
        spec.recordID = entPath
        isValid = true
    end
    
    if not isValid then
        DualPrint('[==e ERROR: entPath is not valid (not a record ID or .ent file): '..tostring(entPath))
        return nil
    end
    
    spec.appearanceName = "default"
    spec.position = position
    spec.orientation = orientation
    spec.alwaysSpawned = true
    spec.spawnInView = true
    spec.active = true
    spec.tags = entityTags
    
    -- Check if entPath is valid
    if type(entPath) ~= 'string' then
        DualPrint('[==e ERROR: entPath is not a string! Type: '..type(entPath))
        return nil
    end
    
    -- Check if TweakDB is available
    if not TweakDB then
        DualPrint('[==e ERROR: TweakDB is not available!')
    end
    
    -- Check if DynamicEntitySystem is available
    if not dynamicEntitySystem then
        DualPrint('[==e ERROR: DynamicEntitySystem is not available!')
        return nil
    end
    
    -- Verify record exists if using recordID
    if isRecord then
        if TweakDB and not TweakDB:GetRecord(spec.recordID) then
            DualPrint('[==e ERROR: Record does NOT exist in TweakDB: '..tostring(spec.recordID))
        end
    end
    
    -- Attempt to create entity
    local entID = dynamicEntitySystem:CreateEntity(spec)
    
    if entID then
        TableManager.tableEntities[tableID][entityName] = entID
    else
        DualPrint('[==e ERROR: Failed to spawn entity '..entityName..' for table '..tableID)
    end
    return entID
end

--- Despawns a specific entity for a table
---@param tableID string table ID
---@param entityName string entity name to despawn
function TableManager.despawnTableEntity(tableID, entityName)
    if not TableManager.tableEntities[tableID] then
        return
    end
    
    local entID = TableManager.tableEntities[tableID][entityName]
    if entID then
        Game.GetDynamicEntitySystem():DeleteEntity(entID)
        TableManager.tableEntities[tableID][entityName] = nil
    end
end

--- Cleans up all entities for a specific table
---@param tableID string table ID to clean up
function TableManager.cleanupTableEntities(tableID)
    if not TableManager.tableEntities[tableID] then
        return
    end
    
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    for entityName, entID in pairs(TableManager.tableEntities[tableID]) do
        if entID then
            dynamicEntitySystem:DeleteEntity(entID)
        end
    end
    
    TableManager.tableEntities[tableID] = nil
end

--- Gets an entity ID for a specific table entity
---@param tableID string table ID
---@param entityName string entity name
---@return EntityID|nil entity ID or nil if not found
function TableManager.getTableEntity(tableID, entityName)
    if not TableManager.tableEntities[tableID] then
        return nil
    end
    return TableManager.tableEntities[tableID][entityName]
end

--===================
-- Phase 2.2: Game-Specific Callbacks
--===================

--- Creates a spot for a specific table with game-specific callbacks
---@param tableID string table ID to create spot for
---@param forcedCameraOption table table containing forced camera option: {[1] = boolean}
---@param gameType string|nil game type ('blackjack' | 'roulette'), defaults to 'blackjack' for backward compatibility
---@param callbacks table|nil game-specific callbacks: {onEnter, onEnterAfterAnimation, onExit, onExitAfterAnimation}
function TableManager.createSpotForTable(tableID, forcedCameraOption, gameType, callbacks)
    gameType = gameType or 'blackjack' -- Default to blackjack for backward compatibility
    callbacks = callbacks or {}
    
    local spotID = tableID  -- Capture spot_id in local variable for use in closures
    local spotObj = {
        spot_id = spotID,
        spot_worldPosition = nil,  -- Will be calculated below
        spot_orientation = nil,    -- Will be calculated below
        spot_entWorkspotPath = "boe6\\gamblingsystemblackjack\\sit_workspot.ent",
        spot_useWorkSpot = true,
        spot_showingInteractUI = false,
        animation_defaultName = "sit_chair_table_lean0__2h_on_table__01",
        animation_defaultEnterTime = 2,
        callback_UIwithoutWorkspotTriggered = function()
            --pass
        end,
        callback_OnSpotEnter = function ()
            TableManager.SetActiveTable(spotID)
            
            -- Call game-specific onEnter callback if provided
            if callbacks.onEnter then
                callbacks.onEnter(spotID)
            elseif gameType == 'blackjack' then
                -- Default blackjack behavior
                if forcedCameraOption[1] then
                    local adjustedPosition, adjustedOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(spotID, 'top_down_holo_display')
                    HolographicValueDisplay.startDisplay(adjustedPosition, adjustedOrientation)
                else
                    local adjustedPosition, adjustedOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(spotID, 'standard_holo_display')
                    HolographicValueDisplay.startDisplay(adjustedPosition, adjustedOrientation)
                end
                local deckPosition, deckOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(spotID, 'deck_position')
                CardEngine.BuildVisualDeck(deckPosition, deckOrientation)
            end
        end,
        callback_OnSpotEnterAfterAnimationDelayTime = 3.5,
        callback_OnSpotEnterAfterAnimation = function ()
            -- Call game-specific onEnterAfterAnimation callback if provided
            if callbacks.onEnterAfterAnimation then
                callbacks.onEnterAfterAnimation(spotID)
            elseif gameType == 'blackjack' then
                -- Default blackjack behavior
                BlackjackMainMenu.playerChipsMoney = 0
                BlackjackMainMenu.playerChipsHalfDollar = false
                BlackjackMainMenu.previousBet = nil
                BlackjackMainMenu.currentBet = nil
                BlackjackMainMenu.StartMainMenu()
            end
        end,
        callback_OnSpotExitAfterAnimationDelayTime = 2.5,
        callback_OnSpotExit = function()
            TableManager.ClearActiveTable()
            
            -- Call game-specific onExit callback if provided
            if callbacks.onExit then
                callbacks.onExit(spotID)
            elseif gameType == 'blackjack' then
                -- Default blackjack behavior
                HolographicValueDisplay.stopDisplay()
                SingleRoundLogic.cleanupRound()
            end
        end,
        callback_OnSpotExitAfterAnimation = function()
            -- Call game-specific onExitAfterAnimation callback if provided
            if callbacks.onExitAfterAnimation then
                callbacks.onExitAfterAnimation(spotID)
            elseif gameType == 'blackjack' then
                -- Default blackjack behavior
                CardEngine.RemoveVisualDeck()
                CardEngine.clearEntityCache()
            end
        end,
        exit_orientationCorrection = {r=0,p=0,y=150},
        exit_worldPositionOffset = {x=0.5,y=0,z=0},
        exit_animationName = "sit_chair_table_lean0__2h_on_table__01__to__stand__2h_on_sides__01__turn0l__01",
        mappin_worldPosition = nil,  -- Will be calculated below
        mappin_interactionRange = 1.4,
        mappin_interactionAngle = 80,
        mappin_rangeMax = 6.5,
        mappin_rangeMin = 0.5,
        mappin_color = nil,
        mappin_worldIcon = "ChoiceIcons.SitIcon",
        mappin_hubText = GameLocale.Text(gameType == 'roulette' and "Roulette" or "Blackjack"),
        mappin_choiceText = GameLocale.Text("Join Table"),
        mappin_choiceIcon = "ChoiceCaptionParts.SitIcon",
        mappin_choiceFont = gameinteractionsChoiceType.QuestImportant,
        mappin_gameMappinID = nil,
        mappin_visible = false,
        mappin_variant = gamedataMappinVariant.SitVariant,
        camera_worldPositionOffset = nil,  -- Will be calculated below
        camera_OrientationOffset = EulerAngles.new(0, -60, 0),
        camera_showElectroshockEffect = true,
        camera_useForcedCamInWorkspot = forcedCameraOption[1]
    }
    -- Calculate all positions using relative coordinate system
    local spotPosition, spotOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(spotID, 'spot_position')
    
    -- Check if spot position/orientation calculation failed
    if not spotPosition or not spotOrientation then
        DualPrint('[==e ERROR: Failed to calculate spot_position for table '..tostring(spotID)..'. Skipping spot creation.')
        return
    end
    
    spotObj.spot_worldPosition = spotPosition
    spotObj.spot_orientation = spotOrientation:ToEulerAngles()
    
    local mappinPosition, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(spotID, 'mappin_position')
    spotObj.mappin_worldPosition = mappinPosition
    
    -- Calculate camera offset relative to spot position
    local cameraOffset = RelativeCoordinateCalulator.registeredOffsets['camera_position_offset']
    if cameraOffset then
        local cameraOffsetVector = Vector4.new(cameraOffset.position.x, cameraOffset.position.y, cameraOffset.position.z, 0)
        local cameraWorldPosition, _ = RelativeCoordinateCalulator.calculateFromPosition(spotPosition, spotOrientation, cameraOffsetVector)
        if cameraWorldPosition then
            spotObj.camera_worldPositionOffset = Vector4.new(
                cameraWorldPosition.x - spotPosition.x,
                cameraWorldPosition.y - spotPosition.y,
                cameraWorldPosition.z - spotPosition.z,
                1
            )
        end
    end
    
    SpotManager.AddSpot(spotObj)
end



--===================
-- Phase 2.3: Table Loading/Unloading
--===================

--- Checks if player is nearby a table and loads it if within distance
---@param tableID string table ID to check
---@param distance number distance threshold to load table (default: 20)
---@param playerPosition Vector4|nil player position (if nil, will be retrieved)
---@return boolean true if table was loaded or already loaded, false otherwise
---Counts the number of registered tables (for debugging)
---@return number count of registered tables
function TableManager.countRegisteredTables()
    local count = 0
    for _ in pairs(RelativeCoordinateCalulator.registeredTables) do
        count = count + 1
    end
    return count
end

function TableManager.loadTableIfNearby(tableID, distance, playerPosition)
    distance = distance or 20
    
    -- Check if already loaded
    if TableManager.tableLoaded[tableID] then
        return true
    end
    
    -- Get player position if not provided
    if not playerPosition then
        local player = GetPlayer()
        if not player then
            DualPrint('[==e ERROR: loadTableIfNearby: GetPlayer() returned nil')
            return false
        end
        playerPosition = player:GetWorldPosition()
    end
    
    -- Get table center position
    local tableCenterPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'spinner_center_point')
    if not tableCenterPos then
        -- Fallback to table position
        local tableData = RelativeCoordinateCalulator.registeredTables[tableID]
        if not tableData then
            DualPrint('[==e ERROR: loadTableIfNearby: Table '..tostring(tableID)..' not found in registeredTables')
            return false
        end
        tableCenterPos = tableData.position
    end
    
    -- Calculate distance (2D distance, ignoring Z)
    local dx = playerPosition.x - tableCenterPos.x
    local dy = playerPosition.y - tableCenterPos.y
    local distanceSquared = dx * dx + dy * dy
    
    if distanceSquared < (distance * distance) then
        -- NOTE: Do NOT set tableLoaded here - that should be done by the caller after InitTable is called
        return true
    end
    
    return false
end

--- Checks if player is far from a table and unloads it if beyond distance
---@param tableID string table ID to check
---@param distance number distance threshold to unload table (default: 100)
---@param playerPosition Vector4|nil player position (if nil, will be retrieved)
---@return boolean true if table was unloaded, false otherwise
function TableManager.unloadTableIfFar(tableID, distance, playerPosition)
    distance = distance or 100
    
    -- Check if not loaded
    if not TableManager.tableLoaded[tableID] then
        return false
    end
    
    -- Get player position if not provided
    if not playerPosition then
        local player = GetPlayer()
        if not player then
            return false
        end
        playerPosition = player:GetWorldPosition()
    end
    
    -- Get table center position
    local tableCenterPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'spinner_center_point')
    if not tableCenterPos then
        -- Fallback to table position
        local tableData = RelativeCoordinateCalulator.registeredTables[tableID]
        if not tableData then
            return false
        end
        tableCenterPos = tableData.position
    end
    
    -- Calculate distance (2D distance, ignoring Z)
    local dx = playerPosition.x - tableCenterPos.x
    local dy = playerPosition.y - tableCenterPos.y
    local distanceSquared = dx * dx + dy * dy
    
    if distanceSquared > (distance * distance) then
        TableManager.tableLoaded[tableID] = false
        -- Clean up entities when unloading
        TableManager.cleanupTableEntities(tableID)
        return true
    end
    
    return false
end

--- Checks if a table is currently loaded
---@param tableID string table ID to check
---@return boolean true if table is loaded
function TableManager.isTableLoaded(tableID)
    return TableManager.tableLoaded[tableID] == true
end

--- Manually sets the loaded state of a table
---@param tableID string table ID
---@param loaded boolean loaded state
function TableManager.setTableLoaded(tableID, loaded)
    TableManager.tableLoaded[tableID] = loaded
end

--===================
-- Phase 2.4: Optional Table Support
--===================

--- Registers an optional table with dependency check
---@param tableData table table data: {id, position (Vector4), orientation (Quaternion), ...}
---@param dependencyCheck string|function mod name to check or function that returns boolean
---@return boolean true if table was registered, false if dependency not met
function TableManager.registerOptionalTable(tableData, dependencyCheck)
    if not tableData or not tableData.id then
        return false
    end
    
    -- Check dependency
    local dependencyMet = false
    if type(dependencyCheck) == "function" then
        dependencyMet = dependencyCheck()
    elseif type(dependencyCheck) == "string" then
        dependencyMet = GetMod(dependencyCheck) ~= nil
    else
        return false
    end
    
    if not dependencyMet then
        -- Store for later checking if dependency becomes available
        TableManager.optionalTables[tableData.id] = {
            tableData = tableData,
            dependencyCheck = dependencyCheck
        }
        return false
    end
    
    -- Register the table
    if tableData.position and tableData.orientation then
        RelativeCoordinateCalulator.registerTable(
            tableData.id,
            tableData.position,
            tableData.orientation
        )
        
        -- Remove from optional tables tracking since it's now registered
        TableManager.optionalTables[tableData.id] = nil
        return true
    end
    
    return false
end

--- Rechecks all optional tables and registers them if dependencies are now met
--- This can be called after mods are loaded to register previously unavailable tables
function TableManager.recheckOptionalTables()
    for tableID, optionalData in pairs(TableManager.optionalTables) do
        -- Skip if already registered
        if RelativeCoordinateCalulator.registeredTables[tableID] then
            TableManager.optionalTables[tableID] = nil
        else
            -- Recheck dependency
            local dependencyMet = false
            if type(optionalData.dependencyCheck) == "function" then
                dependencyMet = optionalData.dependencyCheck()
            elseif type(optionalData.dependencyCheck) == "string" then
                dependencyMet = GetMod(optionalData.dependencyCheck) ~= nil
            end
            
            if dependencyMet then
                -- Register the table
                if optionalData.tableData.position and optionalData.tableData.orientation then
                    RelativeCoordinateCalulator.registerTable(
                        optionalData.tableData.id,
                        optionalData.tableData.position,
                        optionalData.tableData.orientation
                    )
                    TableManager.optionalTables[tableID] = nil
                end
            end
        end
    end
end

return TableManager