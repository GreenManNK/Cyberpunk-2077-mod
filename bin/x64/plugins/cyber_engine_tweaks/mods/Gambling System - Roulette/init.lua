Roulette = {
    version = '1.1.3',
    initVersion = '1.1.3',
    ready = false
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
-- MAJOR CREDITS:
-- These people have helped me with significant roadblocks multiple times, and I am very grateful for their help and work in CP2077.
-- Additional details on how they've helped is further listed below because they are awesome
-- 
-- psiberx         for codeware, TweakDB, & ArchiveXL, documentation and various help using them & CET lua
-- keanuwheeze     for various scripts, advanced CET lua / scripting knowledge, & more various help
--
--===================
--Great Code Help Credits:
--anygoodname for original spawnWithCodeware() and despawn() code by on discord: https://discord.com/channels/717692382849663036/795037494106128434/1220335839448404008
--manavortex for seemlying endless wikipedia articles
--Gullii, Mozz3d, manavortex, psiberx, & anygoodname for help with solving some Vector4 issues
--psiberx for Cron.lua, & keanuwheeze for sharing an example using async/waiting
--keanuwheeze for interactionUI.lua & working example
--psiberx for codeware's awesome features and his help/support of it in discord
--keanuwheeze for their init.lua from the sitAnywhere mod. Marked in comments where used.
--psiberx for GameUI.lua, a Reactive Game UI State Observer
--keanuwheeze for helping with variable scope issues [ This one took an age, ty again keanuwheeze <3 ]
--cyswip from Roblox dev forums for AddValueCommas() function
--psiberx for GameLocale.lua, which is used for translations
--psiberx for GameSession.lua, which detects game load/save events
--===================
--REQUIREMENTS:
--Cyber Engine Tweaks
--Codeware
--RED4ext
--TweakXL
--ArchiveXL
--===================

--Imports
--=======
local Cron = require('External/Cron.lua')
local interactionUI = require("External/interactionUI.lua")
local GameUI = require("External/GameUI.lua")
local GameLocale = require("External/GameLocale.lua")
local GameSession = require('External/GameSession.lua')
local HolographicValueDisplay = require("HolographicValueDisplay.lua")
local RouletteMainMenu = require("RouletteMainMenu.lua")
local ChipUtils = require("chipUtils.lua")
local ChipBetPiles = require("chipBetPiles.lua")
local ChipPlayerPile = require("chipPlayerPile.lua")
local RouletteAnimations = require("RouletteAnimations.lua")
local RelativeCoordinateCalulator = require('RelativeCoordinateCalulator.lua')
local RouletteCoordinates = require('RouletteCoordinates.lua')
local TableManager = require('TableManager.lua')
local SpotManager = require("SpotManager.lua")
local EntityManager = require("EntityManager.lua")


--'global' variables (uncategorized)
--==================
local areaInitialized = false --defines if a roulette table is currently loaded
local cronCount = 0
local chipRotation = 315 -- defines how the player stack hex grid is aligned
local inMenu = true --libaries requirement
local inGame = false
local gameLoadDelayCount = 0
local tableLoadDistance = 20
local tableUnloadDistance = 100
local chipHeight = 0.0035
local cachedPlayerPosition = nil
local cachedPlayerPositionUpdateCounter = 0
local PLAYER_POSITION_UPDATE_INTERVAL = 15 -- Sample every 15 callbacks (~2.67 times per second at 40 callbacks/sec)
local userState = { --used by GameSession.lua
    consoleUses = 0 -- Initial state
}

-- placing bets variables
currentBets = {} --record of bets placed currently waiting for wheel spin
previousBet = {} --last currentBets table, used for repeat bets UI option
queueUIBet = {cat="Red/Black",bet="Red"} --current bet option choices during bet UI selection
previousBetAvailable = false
previousBetsCost = 0
local currentlyRepeatingBets = false
spin_results = '' --track spin results history
tableChips = 0 --track chips on table

-- multi-table support variables
-- tableCenterPoint moved to TableManager.tableCenterPoints[tableID]
-- playerPlayingPosition and tableBoardOrigin are now calculated from the coordinate system
-- They will be set when InitTable() is called for a specific table
local playerPlayingPosition = nil
local tableBoardOrigin = nil
-- Tables are now managed by RouletteCoordinates and TableManager

-- ent files used to create entities
local chip_broken = "base\\gameplay\\items\\misc\\appearances\\broken_poker_chip_junk.ent"
local chips_allin = "ep1\\quest\\main_quests\\q303\\entities\\q303_chips_all_in.ent" --unused currently
local chips_table = "ep1\\quest\\main_quests\\q303\\entities\\q303_chips_table.ent" --unused currently
local roulette_ball = "boe6\\gambling_system_roulette\\q303_roulette_ball.ent" --PL .ent, object duplicated into project custom path to remove PL dependancy
local chip_stacks = "boe6\\gambling_system_roulette\\q303_chips_stacks_edit.ent"
local poker_chip = "boe6\\gambling_props\\boe6_poker_chip.ent"
local roulette_spinner = "boe6\\gambling_system_roulette\\casino_table_roulette_spin_spinner.ent"
local roulette_spinner_frame = "boe6\\gambling_system_roulette\\casino_table_roulette_spin_spinner_frame.ent"
local high_school_usa_font = "boe6\\gambling_system_roulette\\high-school-usa-font.ent"
local playing_card = "boe6\\gambling_props\\boe6_playing_card.ent" --unused currently


-- Game value references
local roulette_slots = {
    {index = 0, label = 32, color = 'Red'},
    {index = 1, label = 0, color = 'Green'},
    {index = 2, label = 26, color = 'Black'},
    {index = 3, label = 3, color = 'Red'},
    {index = 4, label = 35, color = 'Black'},
    {index = 5, label = 12, color = 'Red'},
    {index = 6, label = 28, color = 'Black'},
    {index = 7, label = 7, color = 'Red'},
    {index = 8, label = 29, color = 'Black'},
    {index = 9, label = 18, color = 'Red'},
    {index = 10, label = 22, color = 'Black'},
    {index = 11, label = 9, color = 'Red'},
    {index = 12, label = 31, color = 'Black'},
    {index = 13, label = 14, color = 'Red'},
    {index = 14, label = 20, color = 'Black'},
    {index = 15, label = 1, color = 'Red'},
    {index = 16, label = 33, color = 'Black'},
    {index = 17, label = 16, color = 'Red'},
    {index = 18, label = 24, color = 'Black'},
    {index = 19, label = 5, color = 'Red'},
    {index = 20, label = 10, color = 'Black'},
    {index = 21, label = 23, color = 'Red'},
    {index = 22, label = 8, color = 'Black'},
    {index = 23, label = 30, color = 'Red'},
    {index = 24, label = 11, color = 'Black'},
    {index = 25, label = 36, color = 'Red'},
    {index = 26, label = 13, color = 'Black'},
    {index = 27, label = 27, color = 'Red'},
    {index = 28, label = 6, color = 'Black'},
    {index = 29, label = 34, color = 'Red'},
    {index = 30, label = 17, color = 'Black'},
    {index = 31, label = 25, color = 'Red'},
    {index = 32, label = 2, color = 'Black'},
    {index = 33, label = 21, color = 'Red'},
    {index = 34, label = 4, color = 'Black'},
    {index = 35, label = 19, color = 'Red'},
    {index = 36, label = 15, color = 'Black'}
}
local chip_colors = {
    'white',
    'yellow',
    'red',
    'blue',
    'maroon',
    'black',
    'cyan',
    'orange',
    'lime',
    'pink',
    'purple',
    'green',
    'creamyYellow',
    'royalBlue',
    'forrestGreen',
    'steelPink'
}
chip_values = {
    1,
    5,
    10,
    25,
    50,
    100,
    250,
    500,
    1000,
    2500,
    5000,
    10000,
    25000,
    50000,
    250000,
    1000000
}
betCategories = {
    'Red/Black',
    'Odd/Even',
    'High/Low',
    'Column',
    'Dozen',
    'Straight-Up',
    'Split',
    'Street',
    'Corner',
    'Line'
}
betCategoryIndexes = {
    {'Red', 'Black'},
    {'Odd', 'Even'},
    {'High', 'Low'},
    {'1st Column', '2nd Column', '3rd Column'},
    {'1-12 Dozen', '13-24 Dozen', '25-36 Dozen'},
    {'0 Green', '1 Red', '2 Black', '3 Red', '4 Black', '5 Red', '6 Black', '7 Red', '8 Black', '9 Red', '10 Black', '11 Black', '12 Red', --straight up
        '13 Black', '14 Red', '15 Black', '16 Red', '17 Black', '18 Red', '19 Red', '20 Black', '21 Red', '22 Black', '23 Red', '24 Black',
        '25 Red', '26 Black', '27 Red', '28 Black', '29 Black', '30 Red', '31 Black', '32 Red', '33 Black', '34 Red', '35 Black', '36 Red'},
    {'1-2 Split', '2-3 Split', '1-4 Split', '2-5 Split', '3-6 Split', '4-5 Split', '5-6 Split', '4-7 Split', '5-8 Split', '6-9 Split',
        '7-8 Split', '8-9 Split', '7-10 Split', '8-11 Split', '9-12 Split', '10-11 Split', '11-12 Split', '10-13 Split', '11-14 Split', '12-15 Split', --split
        '13-14 Split', '14-15 Split', '13-16 Split', '14-17 Split', '15-18 Split', '16-17 Split', '17-18 Split', '16-19 Split', '17-20 Split', '18-21 Split',
        '19-20 Split', '20-21 Split', '19-22 Split', '20-23 Split', '21-24 Split', '22-23 Split', '23-24 Split', '22-25 Split', '23-26 Split', '24-27 Split',
        '25-26 Split', '26-27 Split', '25-28 Split', '26-29 Split', '27-30 Split', '28-29 Split', '29-30 Split', '28-31 Split', '29-32 Split', '30-33 Split',
        '31-32 Split', '32-33 Split', '31-34 Split', '32-35 Split', '33-36 Split', '34-35 Split', '35-36 Split'},
    {'1,2,3 Street', '4,5,6 Street', '7,8,9 Street', '10,11,12 Street', '13,14,15 Street', '16,17,18 Street', '19,20,21 Street', '22,23,24 Street', '25,26,27 Street', --street
        '28,29,30 Street', '31,32,33 Street', '34,35,36 Street'},
    {'1/5 Corner', '2/6 Corner', '4/8 Corner', '5/9 Corner', '7/11 Corner', '8/12 Corner', '10/14 Corner', '11/15 Corner', '13/17 Corner', '14/18 Corner', '16/20 Corner', --corner
        '17/21 Corner', '19/23 Corner', '20/24 Corner', '22/26 Corner', '23/27 Corner', '25/29 Corner', '26/30 Corner', '28/32 Corner', '29/33 Corner', '31/35 Corner', '32/36 Corner'},
    {'1-6 Line', '4-9 Line', '7-12 Line', '10-15 Line', '13-18 Line', '16-21 Line', '19-24 Line', '22-27 Line', '25-30 Line', '28-33 Line', '31-36 Line'},
}
betSizingSets = {
    {1,10,25,50,100},
    {10,50,100,500,1000},
    {100,500,1000,5000,10000},
    {1000,5000,10000,50000,100000},
    {10000,25000,100000,500000,1000000}
}
betsPlacesTaken = {
    {false, false}, -- red, black
    {false, false}, -- odd, even (outside)
    {false, false}, -- High, Low (outside)
    {false, false, false}, -- 1st column, 2nd column, 3rd column (outside)
    {false, false, false}, -- 1-12, 13-24, 25-36 (outside)
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- straight up
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
     false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- Splits (Inside) - 57 total
    {false, false, false, false, false, false, false, false, false, false, false, false}, -- Streets (Inside)
    {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- Corners (Inside)
    {false, false, false, false, false, false, false, false, false, false, false} -- Lines (Inside)
}

-- Holographic value display variables
holographicDisplayActive = false
local holographicDisplayPosition = nil

--winning result holo
-- Will be recalculated in InitTable when holographicDisplayPosition is available
local holoDisplayAngle = 0
local holoDisplayAngleRad = 0
local showingHoloResult = false
local doubleDigitHoloResult = false


--Callbacks
--=========

local callback40x = function()
    cronCount = cronCount + 1
    
    local gameLoadDelayTime = 20 --Some delay needed, unsure how much. may be system dependant, could lead to bug reports. Half a second seems *fine*
    if gameLoadDelayCount < gameLoadDelayTime then -- "loading" time
        interactionUI.hideHub()
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoMovement") -- Enable player movement
        StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCombat")
        --idk if these need to be set but better safe than sorry. Loading bugs are hard to pinpoint.
        SpotManager.ClearPlayerInSpot()
    end
    
    -- Sample the shared player position from SpotManager's cache
    cachedPlayerPositionUpdateCounter = cachedPlayerPositionUpdateCounter + 1
    local playerPositionUpdated = false
    if cachedPlayerPositionUpdateCounter >= PLAYER_POSITION_UPDATE_INTERVAL then
        cachedPlayerPosition = SpotManager.GetCachedPlayerPosition()
        if cachedPlayerPosition then
            cachedPlayerPositionUpdateCounter = 0
            playerPositionUpdated = true
        end
    end
    
    -- Table proximity (only when position updates, 2-3 times per second).
    if playerPositionUpdated and gameLoadDelayCount >= gameLoadDelayTime then
        if next(RelativeCoordinateCalulator.registeredTables) == nil then
            DualPrint('[==e ERROR: No registered tables found! RelativeCoordinateCalulator.registeredTables is empty.')
        end

        TableManager.updateProximityZones(cachedPlayerPosition, tableLoadDistance, tableUnloadDistance,
            function(tableID) -- onEnter
                InitTable(tableID)
                areaInitialized = true
            end,
            function(tableID) -- onExit
                if tableID == TableManager.GetActiveTable() then
                    DespawnTable()
                else
                    TableManager.cleanupTableEntities(tableID)
                end
            end)
    end

    --MoveEnt('chips1', {x=0, y=0.01, z=0})
    if RouletteAnimations.ball_spinning then RouletteAnimations.AdvanceRouletteBall() end --check if roulette ball should be spinning
    if RouletteAnimations.roulette_spinning then RouletteAnimations.AdvanceSpinner() end --check if roulette wheel should be spinning
    gameLoadDelayCount = gameLoadDelayCount + 1


    if showingHoloResult then
        -- Recalculate angle dynamically to ensure it's correct for the current table
        local activeTableID = TableManager.GetActiveTable()
        if activeTableID then
            local holoPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'holographic_display_position')
            local playerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'player_playing_position')
            if holoPos and playerPos then
                local currentHoloDisplayAngle = ( ( math.atan2(holoPos.y - playerPos.y, holoPos.x - playerPos.x) ) * 180 / math.pi ) - 45
                EntityManager.MoveEnt('holo_result_firstDigit', {x=0, y=0, z=0.001}, {r=0, p=0, y=currentHoloDisplayAngle})
                EntityManager.MoveEnt('holo_result_colorWord', {x=0, y=0, z=0.001}, {r=0, p=0, y=currentHoloDisplayAngle})
                if doubleDigitHoloResult then
                    EntityManager.MoveEnt('holo_result_secondDigit', {x=0, y=0, z=0.001}, {r=0, p=0, y=currentHoloDisplayAngle})
                end
            end
        end
    end

    if (cronCount % 4 == 0) then --10x per second
        -- Process subtraction first to avoid conflicts
        ChipPlayerPile.QueuedChipSubtraction()
        -- Only process addition if subtraction queue is empty
        if next(ChipPlayerPile.GetPileSubtractionQueue()) == nil then
            ChipPlayerPile.QueuedChipAddition()
        end
        currentlyRepeatingBets = ChipBetPiles.QueuedBetChipAddition(currentlyRepeatingBets)
        ChipBetPiles.RemoveBetStack()
    end
    --[[
    if (cronCount % 10 == 0) then --4x per second
    end

    if (cronCount % 40 == 0) then --1x per second
    end
    ]]--

    if (cronCount == 40) then
        cronCount = 0
    end
end


--Register Events
--===============

local function RegisterRouletteSpot(tableID, mappinPos)
    if not mappinPos then
        DualPrint('[==e ERROR: Failed to calculate mappin position for roulette table '..tostring(tableID))
        return
    end

    local localeJoin = GameLocale.Text("Join Table")
    local localeHub = GameLocale.Text("Roulette")

    local spotObj = {
        spot_id = tableID,
        spot_worldPosition = mappinPos,
        spot_orientation = EulerAngles.new(0, 0, 0),
        spot_useWorkSpot = false,
        spot_showingInteractUI = false,
        disableDefaultUI = false, -- Explicitly set to false to ensure default UI shows
        callback_UIwithoutWorkspotTriggered = function()
            -- Handle joining the roulette table when player interacts
            -- Check if we're switching tables (different from current active table)
            local currentActiveTable = TableManager.GetActiveTable()
            local isSwitchingTables = currentActiveTable and currentActiveTable ~= tableID
            
            -- If switching tables, clear bets from the previous table
            if isSwitchingTables then
                -- Clean up bet chip entities from previous table
                local betsPiles = ChipBetPiles.GetBetsPiles()
                for i, v in ipairs(currentBets) do
                    local localPile = betsPiles[v.id]
                    if localPile then
                        for j, k in ipairs(localPile.stacksInfo) do
                            EntityManager.DeRegisterEntity(k.stackDevName)
                        end
                    end
                end
                -- Clear bet data
                ChipBetPiles.Clear()
                currentBets = {}
                previousBet = {}
                previousBetAvailable = false
                previousBetsCost = 0
            end
            
            -- Ensure table is initialized before joining (spawn spinner/ball if needed)
            if not TableManager.isTableLoaded(tableID) then
                TableManager.setTableLoaded(tableID, true)
                InitTable(tableID)
            else
                -- Table already initialized, but make sure active table and center point are set
                TableManager.SetActiveTable(tableID)
                local tableCenterPoint = TableManager.GetTableCenterPoint(tableID)
                if tableCenterPoint then
                    RouletteAnimations.UpdateBallCenter(tableCenterPoint)
                    -- Update chip positions for this table
                    local boardOriginPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'table_board_origin')
                    if boardOriginPos then
                        -- Update local tableBoardOrigin
                        if not tableBoardOrigin then
                            tableBoardOrigin = {x=boardOriginPos.x, y=boardOriginPos.y, z=boardOriginPos.z}
                        else
                            tableBoardOrigin.x = boardOriginPos.x
                            tableBoardOrigin.y = boardOriginPos.y
                            tableBoardOrigin.z = boardOriginPos.z
                        end
                        -- Update chip modules with new board origin
                        ChipUtils.UpdateTableBoardOrigin(tableBoardOrigin)
                        ChipBetPiles.UpdateTableBoardOrigin(tableBoardOrigin)
                    end
                    -- Update player pile position
                    local playerPilePos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'player_pile_position')
                    if playerPilePos then
                        local playerPile = ChipPlayerPile.GetPlayerPile()
                        playerPile.location = {x=playerPilePos.x, y=playerPilePos.y, z=playerPilePos.z}
                    end
                else
                    -- Table was marked as loaded but center point not set, re-initialize
                    InitTable(tableID)
                end
            end
            
            -- Ensure active table is set (InitTable sets it, but be explicit)
            TableManager.SetActiveTable(tableID)
            interactionUI.hideHub()
            StatusEffectHelper.ApplyStatusEffect(Game.GetPlayer(), "GameplayRestriction.NoMovement") -- Disable player movement
            StatusEffectHelper.ApplyStatusEffect(Game.GetPlayer(), "GameplayRestriction.NoCombat")
            
            -- Get player playing position using RelativeCoordinateCalulator
            local playerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'player_playing_position')
            -- Calculate player orientation (340 degrees + table rotation)
            local tableData = RelativeCoordinateCalulator.registeredTables[tableID]
            local tableEuler = tableData.orientation:ToEulerAngles()
            local playerYaw = 340 + tableEuler.yaw
            Game.GetTeleportationFacility():Teleport(GetPlayer(), playerPos, EulerAngles.new(0, 0, playerYaw))
            
            -- Start holographic display when player joins table
            -- Calculate positions from coordinate system
            local holoPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'holographic_display_position')
            local playerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'player_playing_position')
            
            if holoPos and playerPos and not holographicDisplayActive then
                local holoPosVec = Vector4.new(holoPos.x, holoPos.y, holoPos.z, 1)
                -- Calculate facing direction quaternion
                -- Original formula: atan2(holo.y - player.y, holo.x - player.x) * 180/pi - 90
                -- Module adds 180 degrees internally, so we subtract 180 to compensate
                local holoDisplayAngle = ((math.atan2(holoPos.y - playerPos.y, holoPos.x - playerPos.x)) * 180 / math.pi) - 90 - 180
                local facingQuaternion = EulerAngles.new(0, 0, holoDisplayAngle):ToQuat()
                HolographicValueDisplay.startDisplay(holoPosVec, facingQuaternion)
                holographicDisplayActive = true
            end
            
            RouletteMainMenu.MainMenuUI()
            SpotManager.SetPlayerInSpot(tableID)
        end,
        animation_defaultEnterTime = 0,
        callback_OnSpotEnterAfterAnimationDelayTime = 0,
        callback_OnSpotEnterAfterAnimation = function() end,
        callback_OnSpotExitAfterAnimationDelayTime = 0,
        callback_OnSpotExit = function() end,
        callback_OnSpotExitAfterAnimation = function() end,
        exit_worldPositionOffset = {x = 0, y = 0, z = 0},
        exit_orientationCorrection = {r = 0, p = 0, y = 0},
        mappin_worldPosition = mappinPos,
        mappin_interactionRange = 1.4,
        mappin_interactionAngle = 80,
        mappin_rangeMax = 6.5,
        mappin_rangeMin = 0.5,
        mappin_worldIcon = "ChoiceIcons.SitIcon",
        mappin_choiceIcon = "ChoiceCaptionParts.SitIcon",
        mappin_choiceText = localeJoin,
        mappin_hubText = localeHub,
        mappin_choiceFont = gameinteractionsChoiceType.QuestImportant,
        mappin_variant = gamedataMappinVariant.SitVariant,
        mappin_visibleThroughWalls = true,
        mappin_showWorldMappinIconSetting = true,
        mappin_visible = false,
        mappin_gameMappinID = nil,
        mappin_toggleHUD = true,
        camera_showElectroshockEffect = false
    }

    -- Hide mappin when player is in a spot
    spotObj.mappin_extraVisibilityCheck = function()
        return not SpotManager.IsPlayerInSpot()
    end

    SpotManager.AddSpot(spotObj)
end

registerForEvent( "onInit", function() --runs on file load
	GameLocale.Initialize()
    interactionUI.init()
    
    -- Initialize EntityManager
    EntityManager.Initialize({
        TableManager = TableManager
    })
    
    EntityManager.RegisterEntity('chips0', chip_broken, 'default') --insert index 1 dummy into entRecords to catch nil errors
    Cron.Every(0.025, callback40x)
    
    -- Initialize roulette coordinates FIRST (registers tables and offsets)
    RouletteCoordinates.init()
    
    -- tableBoardOrigin will be set when InitTable() is called for the actual table the player is near
    -- This ensures it's always correct for the active table, not hardcoded to a default
    
    -- Initialize chip modules
    ChipUtils.Initialize({
        Cron = Cron,
        tableBoardOrigin = tableBoardOrigin,
        chipRotation = chipRotation,
        chipHeight = chipHeight,
        chip_values = chip_values,
        chip_colors = chip_colors,
        RegisterEntity = EntityManager.RegisterEntity,
        DeRegisterEntity = EntityManager.DeRegisterEntity,
        FindEntIdByName = EntityManager.FindEntIdByName,
        SetRotateEnt = EntityManager.SetRotateEnt,
        MapVar = MapVar,
        DualPrint = DualPrint
    })
    
    ChipBetPiles.Initialize({
        ChipUtils = ChipUtils,
        Cron = Cron,
        chip_colors = chip_colors,
        chipHeight = chipHeight,
        tableBoardOrigin = tableBoardOrigin,
        RegisterEntity = EntityManager.RegisterEntity,
        DeRegisterEntity = EntityManager.DeRegisterEntity,
        FindEntIdByName = EntityManager.FindEntIdByName,
        SetRotateEnt = EntityManager.SetRotateEnt,
        DualPrint = DualPrint,
        RouletteMainMenu = RouletteMainMenu,
        poker_chip = poker_chip
    })
    
    ChipPlayerPile.Initialize({
        ChipUtils = ChipUtils,
        Cron = Cron,
        chip_colors = chip_colors,
        chipHeight = chipHeight,
        chipRotation = chipRotation,
        RegisterEntity = EntityManager.RegisterEntity,
        DeRegisterEntity = EntityManager.DeRegisterEntity,
        FindEntIdByName = EntityManager.FindEntIdByName,
        SetRotateEnt = EntityManager.SetRotateEnt,
        DualPrint = DualPrint,
        poker_chip = poker_chip
    })
    
    -- Initialize RouletteAnimations module
    -- Note: spin_results is updated via a callback function
    -- tableCenterPoint is now managed by TableManager and will be set when InitTable() is called
    RouletteAnimations.Initialize({
        SetRotateEnt = EntityManager.SetRotateEnt,
        FindEntIdByName = EntityManager.FindEntIdByName,
        ProcessSpinResult = ProcessSpinResult,
        GetPlayer = GetPlayer,
        DualPrint = DualPrint,
        UpdateSpinResults = function(result)
            spin_results = spin_results .. result .. ','
        end
    })

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
        inMenu = isInMenu
    end)

    --Setup observer and GameUI to detect inGame / inMenu
    --credit: keanuwheeze | init.lua from the sitAnywhere mod
    inGame = false
    GameUI.OnSessionStart(function()
        inGame = true
        cachedPlayerPosition = nil
        cachedPlayerPositionUpdateCounter = PLAYER_POSITION_UPDATE_INTERVAL
    end)
    GameUI.OnSessionEnd(function()
        inGame = false
        -- Reset cached player position on session end
        cachedPlayerPosition = nil
        cachedPlayerPositionUpdateCounter = 0
    end)
    inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

    SpotManager.init()

    GameSession.OnEnd(function() --GameSession init stuff, credit: psiberx code
        -- Triggered once the current game session has ended (when "Load Game" or "Exit to Main Menu" selected)
        DespawnTable()
    end)

    -- Register SpotManager interactions for all registered tables
    for tableID, _ in pairs(RelativeCoordinateCalulator.registeredTables) do
        -- Use mappin_position for the interaction position (should be at table level)
        local mappinPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'mappin_position')
        RegisterRouletteSpot(tableID, mappinPos)
    end

    Roulette.ready = true
end)

registerForEvent('onUpdate', function(dt) --runs every frame
    if  not inMenu and inGame then
        Cron.Update(dt) -- This is required for Cron to function
        interactionUI.update()
        SpotManager.update(dt)
        
        -- Update holographic display every frame (like blackjack implementation)
        if holographicDisplayActive then
            local playerPile = ChipPlayerPile.GetPlayerPile()
            HolographicValueDisplay.Update(playerPile.value or 0)
        end
    end
    RouletteMainMenu.Update()
end)
registerForEvent('onDraw', function()
    RouletteMainMenu.Draw()
end)
--dev hotkeys
--[[
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    Game.GetPlayer():PlaySoundEvent("ono_v_effort_short")
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')

end)
registerHotkey('DevHotkey3', 'Dev Hotkey 3', function()
    DualPrint('||=3  Dev hotkey 3 Pressed =')

end)
registerHotkey('DevHotkey4', 'Dev Hotkey 4', function()
    DualPrint('||=4  Dev hotkey 4 Pressed =')

end)
registerHotkey('DevHotkey5', 'Dev Hotkey 5', function()
    DualPrint('||=5  Dev hotkey 5 Pressed =')

end)
registerHotkey('DevHotkey6', 'Dev Hotkey 6', function()
    DualPrint('||=6  Dev hotkey 6 Pressed =')

end)
registerHotkey('DevHotkey7', 'Dev Hotkey 7', function()
    DualPrint('||=7  Dev hotkey 7 Pressed =')

end)
registerHotkey('DevHotkey8', 'Dev Hotkey 8', function()
    DualPrint('||=8  Dev hotkey 8 Pressed =')

end)
registerHotkey('DevHotkey9', 'Dev Hotkey 9', function()
    DualPrint('||=9  Dev hotkey 9 Pressed =')

end)
]]--


--Functions
--=========

---Helper function to get active table data from RelativeCoordinateCalulator
---@return table|nil table data or nil if no active table
function GetActiveTableData()
    local activeTableID = TableManager.GetActiveTable()
    if not activeTableID then
        return nil
    end
    return RelativeCoordinateCalulator.registeredTables[activeTableID]
end

---Helper function to get active table rotation in degrees
---Extracts rotation from table orientation Quaternion
---@return number|nil rotation angle in degrees, or nil if no active table
function GetActiveTableRotation()
    local tableData = GetActiveTableData()
    if not tableData then
        return nil
    end
    local euler = tableData.orientation:ToEulerAngles()
    return euler.yaw
end

function InitTable(tableID)
    --Game.GetWorldStateSystem():DeactivateCommunity(CreateNodeRef("#kab_07_com_ground_floor_crowd"), "Clients_male") --"deactivate"/despawn guy in roulette seat, uses codeware
    -- found in RedHotTools, node ref final /xyz/    --found in community file, match Record ID = CharacterRecordID in community file, use entryName value
    -- removing this in the future and using a phycial table that doesn't need NPCs removed.

    TableManager.SetActiveTable(tableID)
    
    -- Get table center point (spinner center point) - MUST be set before spawning entities
    local spinnerCenterPos, spinnerOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'spinner_center_point')
    if not spinnerCenterPos then
        DualPrint('[==e ERROR: Failed to calculate spinner center position for table '..tostring(tableID))
        return
    end
    local tableCenterPoint = {x=spinnerCenterPos.x, y=spinnerCenterPos.y, z=spinnerCenterPos.z}
    TableManager.SetTableCenterPoint(tableID, tableCenterPoint)
    
    
    -- Update RouletteAnimations with table center point immediately
    RouletteAnimations.UpdateBallCenter(tableCenterPoint)

    -- Spawn roulette entities using TableManager
    local spinnerEntID = TableManager.spawnTableEntity(tableID, 'roulette_spinner', roulette_spinner, spinnerCenterPos, spinnerOrientation, nil, {'[Roulette]'})
    if not spinnerEntID then
        DualPrint('[==e ERROR: InitTable: Failed to spawn roulette_spinner entity')
    end
    
    local ballEntID = TableManager.spawnTableEntity(tableID, 'roulette_ball', roulette_ball, spinnerCenterPos, spinnerOrientation, nil, {'[Roulette]'})
    if not ballEntID then
        DualPrint('[==e ERROR: InitTable: Failed to spawn roulette_ball entity')
    end
    
    -- Note: Entities are now tracked per-table in TableManager.tableEntities[tableID]
    -- FindEntIdByName will retrieve them from TableManager for table-specific entities
    -- We still add to historicalEntRecords for cleanup purposes, but use table-specific names
    -- to avoid conflicts when multiple tables are loaded
    if spinnerEntID then
        local tableSpecificName = tableID .. '_roulette_spinner'
        -- Remove any existing entry with this table-specific name
        EntityManager.RemoveFromRecords(tableSpecificName)
        EntityManager.AddToRecords(tableSpecificName, spinnerEntID)
    end
    if ballEntID then
        local tableSpecificName = tableID .. '_roulette_ball'
        -- Remove any existing entry with this table-specific name
        EntityManager.RemoveFromRecords(tableSpecificName)
        EntityManager.AddToRecords(tableSpecificName, ballEntID)
    end
    
    -- Check if JSON imported table (spawn frame for JSON tables, excluding hooh and tygerclaws)
    local hardcodedTables = {'hoohbar', 'tygerclawscasino'}
    local isHardcoded = false
    for _, hardcodedID in ipairs(hardcodedTables) do
        if tableID == hardcodedID then
            isHardcoded = true
            break
        end
    end
    
    if not isHardcoded then
        -- This is a JSON imported table
        local tableIDLower = string.lower(tostring(tableID))
        local isExcluded = string.find(tableIDLower, 'hooh') ~= nil or string.find(tableIDLower, 'tygerclaws') ~= nil
        
        if not isExcluded then
            -- Spawn frame for JSON imported tables (excluding hooh and tygerclaws)
            local frameEntID = TableManager.spawnTableEntity(tableID, 'roulette_spinner_frame', roulette_spinner_frame, spinnerCenterPos, spinnerOrientation, nil, {'[Roulette]'})
            if frameEntID then
                local tableSpecificName = tableID .. '_roulette_spinner_frame'
                -- Remove any existing entry with this table-specific name
                EntityManager.RemoveFromRecords(tableSpecificName)
                EntityManager.AddToRecords(tableSpecificName, frameEntID)
            end
        end
    end

    -- Get player pile position
    local playerPilePos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'player_pile_position')
    local playerPile = ChipPlayerPile.GetPlayerPile()
    playerPile.location = {x=playerPilePos.x, y=playerPilePos.y, z=playerPilePos.z}

    -- Get player playing position
    local playerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'player_playing_position')
    playerPlayingPosition = {x=playerPos.x, y=playerPos.y, z=playerPos.z}

    -- Get holographic display position
    local holoPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'holographic_display_position')
    holographicDisplayPosition = {x=holoPos.x, y=holoPos.y, z=holoPos.z}

    -- Calculate angle from holographic display position to player position (ignoring Z coordinate)
    -- This is already in world space since positions are world coordinates, so the angle is correct
    -- The -45 offset is for the font orientation
    holoDisplayAngle = ( ( math.atan2(holographicDisplayPosition.y - playerPlayingPosition.y, holographicDisplayPosition.x - playerPlayingPosition.x) ) * 180 / math.pi ) - 45
    holoDisplayAngleRad = holoDisplayAngle * math.pi / 180

    -- Get table board origin
    local boardOriginPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'table_board_origin')
    -- Create or update tableBoardOrigin (create if nil, update if exists)
    if not tableBoardOrigin then
        tableBoardOrigin = {x=boardOriginPos.x, y=boardOriginPos.y, z=boardOriginPos.z}
    else
        tableBoardOrigin.x = boardOriginPos.x
        tableBoardOrigin.y = boardOriginPos.y
        tableBoardOrigin.z = boardOriginPos.z
    end
    
    -- Also update ChipUtils and ChipBetPiles with the new values
    ChipUtils.UpdateTableBoardOrigin(tableBoardOrigin)
    ChipBetPiles.UpdateTableBoardOrigin(tableBoardOrigin)
end

function DespawnTable() --despawns ents and resets script variables
    local activeTableID = TableManager.GetActiveTable()
    
    -- Use TableManager to cleanup roulette entities
    if activeTableID then
        TableManager.cleanupTableEntities(activeTableID)
    end
    
    -- Also remove from local entRecords for consistency
    -- (TableManager already despawned them, but we need to clean up our tracking)
    -- Remove table-specific entity names for this table
    if activeTableID then
        local tableSpecificNames = {
            activeTableID .. '_roulette_spinner',
            activeTableID .. '_roulette_spinner_frame',
            activeTableID .. '_roulette_ball'
        }
        for _, devName in ipairs(tableSpecificNames) do
            EntityManager.RemoveFromRecords(devName)
        end
    end
    
    -- Stop holographic display if active (this will despawn the stand entity)
    if holographicDisplayActive then
        HolographicValueDisplay.stopDisplay()
        holographicDisplayActive = false
    end

    -- Clean up bet chip entities (these are still managed by the local system)
    local betsPiles = ChipBetPiles.GetBetsPiles()
    for i, v in ipairs(currentBets) do
        local localPile = betsPiles[v.id]
        if localPile then
            for j, k in ipairs(localPile.stacksInfo) do
                EntityManager.DeRegisterEntity(k.stackDevName)
            end
        end
    end

    StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoMovement") -- Enable player movement
    StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCombat") -- Enable weapon draw
    interactionUI.hideHub()

    areaInitialized = false -- Clear the table-loaded flag synchronously so the next location check re-runs InitTable().
    if activeTableID then
        TableManager.setTableLoaded(activeTableID, false)
        TableManager.SetActiveTable(nil)
    end

    local callbackResetVariables = function() --force reset almost every variable. save/load bugs are a PITA.
        gameLoadDelayCount = 0
        ChipPlayerPile.Clear()
        ChipBetPiles.Clear()
        previousBetAvailable = false
        SpotManager.ClearPlayerInSpot()
        RouletteAnimations.Reset()
        gameLoadDelayCount = 0
        cronCount = 0
        cachedPlayerPositionUpdateCounter = 0
        currentBets = {}
        previousBet = {}
        previousBetsCost = 0
        currentlyRepeatingBets = false
        -- Animation variables are now managed by RouletteAnimations.Reset()
        -- searchStepCount, stackSearchCurrent, stackSearchPrevious, stackSearchOld are now managed by ChipPlayerPile
        -- pileQueue and pileSubtractionQueue are now managed by ChipPlayerPile.Clear()
        tableChips = 0
        spin_results = ''
        betsPlacesTaken = {
            {false, false}, -- red, black
            {false, false}, -- odd, even (outside)
            {false, false}, -- High, Low (outside)
            {false, false, false}, -- 1st column, 2nd column, 3rd column (outside)
            {false, false, false}, -- 1-12, 13-24, 25-36 (outside)
            {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- straight up
            {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
             false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- Splits (Inside) - 57 total
            {false, false, false, false, false, false, false, false, false, false, false, false}, -- Streets (Inside)
            {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}, -- Corners (Inside)
            {false, false, false, false, false, false, false, false, false, false, false} -- Lines (Inside)
        }
        holographicDisplayActive = false
        holographicDisplayPosition = nil
        RouletteMainMenu.ResetCustomInput()
    end
    Cron.After(0.2, callbackResetVariables)

    EntityManager.ForceClearAllEnts() --force clear all entities via historicalEntRecords table, in case of despawn bets error/bug
end

-- Entity management functions moved to EntityManager.lua

function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string)
    spdlog.error('[Gambling System] ' .. string)
end

function ShowHoloResult(number, color)
    showingHoloResult = true
    
    -- Recalculate angle dynamically to ensure it's correct for the current table
    local activeTableID = TableManager.GetActiveTable()
    if not activeTableID then
        DualPrint('[==e ERROR: ShowHoloResult: No active table')
        return
    end
    
    -- Get current positions for the active table
    local holoPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'holographic_display_position')
    local playerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'player_playing_position')
    if not holoPos or not playerPos then
        DualPrint('[==e ERROR: ShowHoloResult: Failed to get positions for active table')
        return
    end
    
    -- Calculate angle from holographic display position to player position (in world space)
    -- The -45 offset is for the font orientation
    local currentHoloDisplayAngle = ( ( math.atan2(holoPos.y - playerPos.y, holoPos.x - playerPos.x) ) * 180 / math.pi ) - 45
    local currentHoloDisplayAngleRad = currentHoloDisplayAngle * math.pi / 180
    
    local kerning = 0.013845
    local doubleSpace = 0.03
    local numberWidth = 0.0758
    local greenWidth = 0.404
    local redWidth = 0.239
    local blackWidth = 0.411
    local colorWordWidth = 0
    local stringPhysicalWidth = numberWidth + kerning + doubleSpace
    if number >= 10 then
        doubleDigitHoloResult = true
        stringPhysicalWidth = stringPhysicalWidth + numberWidth + kerning
    else
        doubleDigitHoloResult = false
    end
    if color == 'Black' then
        stringPhysicalWidth = stringPhysicalWidth + blackWidth
        colorWordWidth = blackWidth
    elseif color == 'Red' then
        stringPhysicalWidth = stringPhysicalWidth + redWidth
        colorWordWidth = redWidth
    elseif color == 'Green' then
        stringPhysicalWidth = stringPhysicalWidth + greenWidth
        colorWordWidth = greenWidth
    else
        DualPrint('=C FATAL ERROR: color ~= Green|Red|Black, CODE 0954')
    end
    local widthMiddle =  stringPhysicalWidth / 2

    local firstDigitLinePos = numberWidth / 2
    local secondDigitLinePos = numberWidth + kerning + (numberWidth / 2)
    local colorWordLinePos = numberWidth + kerning + doubleSpace + (colorWordWidth / 2)
    if doubleDigitHoloResult then
        colorWordLinePos = colorWordLinePos + numberWidth + kerning
    end


    local firstDigitRelativeX = ( firstDigitLinePos - widthMiddle ) * math.cos(currentHoloDisplayAngleRad)
    local firstDigitRelativeY = ( firstDigitLinePos - widthMiddle ) * math.sin(currentHoloDisplayAngleRad)
    local secondDigitRelativeX = ( secondDigitLinePos - widthMiddle ) * math.cos(currentHoloDisplayAngleRad)
    local secondDigitRelativeY = ( secondDigitLinePos - widthMiddle ) * math.sin(currentHoloDisplayAngleRad)
    local colorWordRelativeX = ( colorWordLinePos - widthMiddle ) * math.cos(currentHoloDisplayAngleRad)
    local colorWordRelativeY = ( colorWordLinePos - widthMiddle ) * math.sin(currentHoloDisplayAngleRad)

    local tableCenterPoint = TableManager.GetActiveTableCenterPoint()
    if not tableCenterPoint then
        DualPrint('[==e ERROR: ShowHoloResult: tableCenterPoint not available for active table')
        return
    end

    local firstDigitPos = {
        x=tableCenterPoint.x + firstDigitRelativeX,
        y=tableCenterPoint.y + firstDigitRelativeY,
        z=tableCenterPoint.z + 0.3
    }
    local secondDigitPos = {
        x=tableCenterPoint.x + secondDigitRelativeX,
        y=tableCenterPoint.y + secondDigitRelativeY,
        z=tableCenterPoint.z + 0.3
    }
    local colorWordPos = {
        x=tableCenterPoint.x + colorWordRelativeX,
        y=tableCenterPoint.y + colorWordRelativeY,
        z=tableCenterPoint.z + 0.3
    }

    local numberString = tostring(number)
    local firstDigit = string.sub(numberString, 1, 1)
    local secondDigit = ""
    if doubleDigitHoloResult then
        secondDigit = string.sub(numberString, 2, 2)
    end

    -- Set initial orientation to face the player (accounting for table rotation)
    local initialOrientation = {r=0, p=0, y=currentHoloDisplayAngle}

    EntityManager.RegisterEntity('holo_result_firstDigit', high_school_usa_font, firstDigit, {x=firstDigitPos.x, y=firstDigitPos.y, z=firstDigitPos.z}, initialOrientation)
    EntityManager.RegisterEntity('holo_result_colorWord', high_school_usa_font, color, {x=colorWordPos.x, y=colorWordPos.y, z=colorWordPos.z}, initialOrientation)
    if doubleDigitHoloResult then
        EntityManager.RegisterEntity('holo_result_secondDigit', high_school_usa_font, secondDigit, {x=secondDigitPos.x, y=secondDigitPos.y, z=secondDigitPos.z}, initialOrientation)
    end


    local callback = function()
        showingHoloResult = false
        EntityManager.DeRegisterEntity('holo_result_firstDigit')
        EntityManager.DeRegisterEntity('holo_result_colorWord')
        if doubleDigitHoloResult then
            EntityManager.DeRegisterEntity('holo_result_secondDigit')
        end
    end
    Cron.After(5, callback)

end

function ProcessSpinResult(resultIndex) --takes resultIndex for roulette_slots (from wheel being spun) and processes bets/winners
    local resultLabel = roulette_slots[resultIndex].label
    local resultColor = roulette_slots[resultIndex].color
    local winnerIDs = {}
    local loserIDs = {}
    local wonValue = 0
    ShowHoloResult(resultLabel, resultColor)

    for i, v in ipairs(currentBets) do
        if v.cat == "Red/Black" then
            if resultColor == v.bet then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*2)
                wonValue = wonValue + v.value*2
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Straight-Up" then
            local bet = v.bet
            local digit1 = string.sub(bet, 1, 1)
            local digit2 = string.sub(bet, 2, 2)
            local betNum = 0
            if digit2 == " " then
                betNum = tonumber(digit1)
            else
                betNum = tonumber(digit1..digit2)
            end
            if resultLabel == betNum then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*36)
                wonValue = wonValue + v.value*36
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Odd/Even" then
            local betOdd = true
            local resultOdd = true
            if resultLabel%2 == 0 then
                resultOdd = false
            end
            if v.bet == "Even" then
                betOdd = false
            end
            if betOdd ~= resultOdd or resultLabel == 0 then
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            else
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*2)
                wonValue = wonValue + v.value*2
                table.insert(winnerIDs, v.id)
            end
        elseif v.cat == "High/Low" then
            local betHigh = ( resultLabel >= 19 )
            local resultHigh = ( v.bet == "High" )
            if betHigh ~= resultHigh or resultLabel == 0 then
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            else
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*2)
                wonValue = wonValue + v.value*2
                table.insert(winnerIDs, v.id)
            end
        elseif v.cat == "Column" then
            local mod3 = resultLabel % 3
            local winner = false
            if mod3 == 0 and v.bet == "3rd Column" then
                winner = true
            elseif mod3 == 1 and v.bet == "1st Column" then
                winner = true
            elseif mod3 == 2 and v.bet == "2nd Column" then
                winner = true
            end
            if resultLabel == 0 then
                winner = false
            end
            if winner then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*3)
                wonValue = wonValue + v.value*3
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Dozen" then
            local dozen = math.floor((resultLabel-1) / 12)+1
            local winner = false
            if dozen == 1 and v.bet == "1-12 Dozen" then
                winner = true
            elseif dozen == 2 and v.bet == "13-24 Dozen" then
                winner = true
            elseif dozen == 3 and v.bet == "25-36 Dozen" then
                winner = true
            end
            if resultLabel == 0 then
                winner = false
            end
            if winner then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*3)
                wonValue = wonValue + v.value*3
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Split" then
            local firstNumber = 0
            local secondNumber = 0
            if string.sub(v.bet, 2, 2) == "-" then
                firstNumber = tonumber(string.sub(v.bet, 1, 1))
                secondNumber = tonumber(string.sub(v.bet, 3, 4))
            else
                firstNumber = tonumber(string.sub(v.bet, 1, 2))
                secondNumber = tonumber(string.sub(v.bet, 4, 5))
            end
            if resultLabel == firstNumber or resultLabel == secondNumber then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*18)
                wonValue = wonValue + v.value*18
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Street" then
            local firstNumber = 0
            local secondNumber = 0
            local thirdNumber = 0
            if string.sub(v.bet, 2, 2) == "," then
                firstNumber = tonumber(string.sub(v.bet, 1, 1))
                secondNumber = tonumber(string.sub(v.bet, 3, 3))
                thirdNumber = tonumber(string.sub(v.bet, 5, 5))
            else
                firstNumber = tonumber(string.sub(v.bet, 1, 2))
                secondNumber = tonumber(string.sub(v.bet, 4, 5))
                thirdNumber = tonumber(string.sub(v.bet, 7, 8))
            end
            if resultLabel == firstNumber or resultLabel == secondNumber or resultLabel == thirdNumber then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*12)
                wonValue = wonValue + v.value*12
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Corner" then
            local firstNumber = 0
            local secondNumber = 0
            if string.sub(v.bet, 2, 2) == "/" then
                firstNumber = tonumber(string.sub(v.bet, 1, 1))
                secondNumber = tonumber(string.sub(v.bet, 3, 4))
            else
                firstNumber = tonumber(string.sub(v.bet, 1, 2))
                secondNumber = tonumber(string.sub(v.bet, 4, 5))
            end
            local thirdNumber = firstNumber+1
            local fourthNumber = secondNumber-1
            if resultLabel == firstNumber or resultLabel == secondNumber or resultLabel == thirdNumber or resultLabel == fourthNumber then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*9)
                wonValue = wonValue + v.value*9
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        elseif v.cat == "Line" then
            local firstNumber = 0
            local secondNumber = 0
            if string.sub(v.bet, 2, 2) == "-" then
                firstNumber = tonumber(string.sub(v.bet, 1, 1))
                secondNumber = tonumber(string.sub(v.bet, 3, 4))
            else
                firstNumber = tonumber(string.sub(v.bet, 1, 2))
                secondNumber = tonumber(string.sub(v.bet, 4, 5))
            end
            if resultLabel >= firstNumber and resultLabel <= secondNumber then
                DualPrint('Winner! Bet on '..v.cat..'; '..v.bet..'! Payout: '..v.value*6)
                wonValue = wonValue + v.value*6
                table.insert(winnerIDs, v.id)
            else
                DualPrint('Loser! Bet on '..v.cat..'; '..v.bet)
                table.insert(loserIDs, v.id)
            end
        else
            DualPrint('ERROR: Unknown bet category: '..v.cat..' CODE 2640')
        end
    end

    local betsPilesToRemove = ChipBetPiles.GetBetsPilesToRemove()
    for i, v in ipairs(loserIDs) do
        local callback = function()
            table.insert(betsPilesToRemove, v)
        end
        Cron.After(2, callback)
    end
    local holoEnts = {}
    local betsPiles = ChipBetPiles.GetBetsPiles()
    for i, v in ipairs(winnerIDs) do
        local betsPile = betsPiles[v]
        if betsPile and betsPile.stacksInfo and betsPile.stacksInfo[1] then
            local entDevName = betsPile.stacksInfo[1].stackDevName
            --get ent location position
            local entID = EntityManager.FindEntIdByName(entDevName)
            if not entID then
                DualPrint('[==e ERROR: Could not find entity ID for '..entDevName..' for winner bet '..v)
            else
                local entity = Game.FindEntityByID(entID)
                if entity then
                    local pos = entity:GetWorldPosition()
                    local holoDevName = entDevName..'_holo'
                    table.insert(holoEnts, holoDevName)
                    EntityManager.RegisterEntity(holoDevName, chip_stacks, 'default', {x=pos.x,y=pos.y,z=pos.z-0.02})
                else
                    DualPrint('[==e ERROR: Could not find entity '..entDevName..' for winner bet '..v)
                end
            end
        else
            DualPrint('[==e ERROR: betsPile or stacksInfo missing for winner bet '..v)
        end

        local callback = function()
            table.insert(betsPilesToRemove, v)
        end
        Cron.After(4, callback)
    end

    for i,v in ipairs(betsPlacesTaken) do --reset betsPlacesTaken table
        for j,k in ipairs(v) do
            betsPlacesTaken[i][j] = false
        end
    end

    local callback5 = function()
        ChipPlayerPile.ChangePlayerChipValue(wonValue)
        if currentBets[1] then
            previousBetsCost = 0
            for i, v in ipairs(currentBets) do
                previousBetsCost = previousBetsCost + v.value
            end
            previousBet = currentBets
            currentBets = {}
            previousBetAvailable = true
        end
        RouletteMainMenu.MainMenuUI()
    end
    Cron.After(5, callback5)
    local callback6 = function()
        for i, v in ipairs(holoEnts) do
            EntityManager.DeRegisterEntity(v)
        end
    end
    Cron.After(6, callback6)
end

function PlaceBet(betValue,category,bet,addition) --from UI confirmation, add bet to currentBets, subtract from playerPile chips & holo, create single stack pile of chips
    local betCategory = queueUIBet.cat
    local betChoice = queueUIBet.bet
    local localAddition = 0
    if addition ~= nil then
        localAddition = addition
    end
    if category ~= nil then
        betCategory = category
    end
    if bet ~= nil then
        betChoice = bet
    end
    local betID = 'bet_'..(os.time()+localAddition)
    local betObject = {value=betValue,cat=betCategory,bet=betChoice,id=betID}
    table.insert(currentBets, {value=betValue,cat=betCategory,bet=betChoice,id=betID})
    ChipPlayerPile.ChangePlayerChipValue(-betValue)
    ChipBetPiles.CreateBetStack(betObject)
    previousBetAvailable = false

    local catIndex = -1
    local betIndex = -1
    for i,v in ipairs(betCategories) do
        if v == betCategory then
            catIndex = i
            break
        end
    end
    for i,v in ipairs(betCategoryIndexes[catIndex]) do
        if v == betChoice then
            betIndex = i
            break
        end
    end
    betsPlacesTaken[catIndex][betIndex] = true
end

-- Animation functions moved to RouletteAnimations.lua module
-- Functions: AdvanceSpinner, AdvanceRouletteBall, BallBounce, BounceRandomizer, LowerBallDistance

function MapVar(var, in_min, in_max, out_min, out_max) --maps a value from one range to another
    return ( (var - in_min) / (in_max - in_min) ) * (out_max - out_min) + out_min
end

function RepeatBets() --for each in previous bets, place bet into current bets
    previousBetAvailable = false
    currentlyRepeatingBets = true
    for i, v in pairs(previousBet) do
        PlaceBet(v.value,v.cat,v.bet,i)
    end
end

-- UI functions moved to RouletteMainMenu.lua

-- SpawnWithCodeware and Despawn moved to EntityManager.lua

--Script Initialized
--==================

--DualPrint('[log] init.lua loaded, Time: '..tostring(os.time()))
--DualPrint('-=- Welcome to Roulette by Boe6! -=- Current Unix Time: '..os.time())
return Roulette

