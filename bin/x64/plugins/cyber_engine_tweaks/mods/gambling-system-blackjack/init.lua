GamblingSystemBlackjack = {
    version = '1.1.4',
    loaded = false,
    ready = false
}
--init.lua v1.0.10
--===================
--Copyright (c) 2025 Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
--REQUIREMENTS:
--RED4ext
--Cyber Engine Tweaks
--Codeware
--ArchiveXL
--TweakXL
--===================
--CREDITS:
-- All respective devs of all requirements and development software!
-- keanuwheeze for worldInteraction.lua & workspotUtils.lua, which I used as a guide for implementing UI and mappins into SpotManager.lua

--Modules
--=======
GameLocale = require("External/GameLocale.lua") --Psiberx's language script from 'cet-kit'github
CardEngine = require('CardEngine.lua') --Card Entity Handler
local Cron = require('External/Cron.lua') --Time handling
local interactionUI = require("External/interactionUI.lua")
local GameUI = require("External/GameUI.lua") --Reactive Game UI State Observer
local SpotManager = require('SpotManager.lua') --workspot management
local SingleRoundLogic = require('singleRoundLogic.lua') --Handles 1 round of blackjack
local BlackjackMainMenu = require("BlackjackMainMenu.lua")
local HolographicValueDisplay = require('HolographicValueDisplay.lua')
local SimpleCasinoChip = require('SimpleCasinoChip.lua')
local HandCountDisplay = require('HandCountDisplay.lua')
local GameSession = require('External/GameSession.lua') --detects game sessions and saves data to disk
local RelativeCoordinateCalulator = require('RelativeCoordinateCalulator.lua')
local BlackjackCoordinates = require('BlackjackCoordinates.lua')
local TableManager = require('TableManager.lua') 
local JsonData = require("JsonData.lua")

local inMenu = true --libaries requirement
local inGame = false
Global_temp_Counter_ent = nil
ImmersiveFirstPersonInstalled = false
DisplayHandValuesOption = {true}
ForcedCameraOption = {false} -- Default to off (no forced camera)
local state = { runtime = 0 } --GameSession runtime

-- Camera management variables (moved from SpotManager)
local blackjackCamera = {
    forcedCam = false,
    activeCam = nil,
    appliedCameraControlStatus = false
}


--Functions
--=========
--- Prints string to both CET console and local .log file
---@param string string String to print
function DualPrint(string) --prints to both CET console and local .log file
    if not string then return end
    print('[Gambling System] ' .. string) -- CET console
    spdlog.error('[Gambling System] ' .. string) -- .log
end

---Move player camera to forced position, typically above table (blackjack-specific)
---@param enable boolean to enable, or disable the forced camera perspective
---@param spotObject? table spot's animation object (required when enable is true)
local function setForcedCamera(enable, spotObject)
    blackjackCamera.forcedCam = enable
    if enable and spotObject then
        local camera = GetPlayer():GetFPPCameraComponent()
        local quatOri = spotObject.camera_OrientationOffset:ToQuat()
        -- Only apply NoCameraControl if top-down camera is enabled and ImmersiveFirstPerson is installed
        if ImmersiveFirstPersonInstalled and ForcedCameraOption[1] then
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
            blackjackCamera.appliedCameraControlStatus = true
        end
        camera:SetLocalTransform(spotObject.camera_worldPositionOffset, quatOri) --default settings
    else--reset to normal camera control
        local camera = GetPlayer():GetFPPCameraComponent()
        camera:SetLocalPosition(Vector4.new(0, 0, 0, 1))
        camera:SetLocalOrientation(EulerAngles.new(0, 0, 0):ToQuat())
        -- Only remove status effect if we applied it ourselves
        if blackjackCamera.appliedCameraControlStatus then
            StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
            blackjackCamera.appliedCameraControlStatus = false
        end
    end
end

---Update forced camera to maintain position (blackjack-specific)
local function updateForcedCamera()
    if blackjackCamera.forcedCam and blackjackCamera.activeCam ~= nil then --fixes the camera being reset by workspot animation
        local spot = SpotManager.spots[blackjackCamera.activeCam]
        if spot and spot.spotObject.camera_useForcedCamInWorkspot then
            local camera = GetPlayer():GetFPPCameraComponent()
            local o = camera:GetLocalOrientation():ToEulerAngles()
            local camRotation = spot.spotObject.camera_OrientationOffset
            local isCorrectOrientation = math.abs(o.pitch - camRotation.pitch) < 0.0001 and math.abs(o.yaw - camRotation.yaw) < 0.0001
            if not isCorrectOrientation then
                setForcedCamera(true, spot.spotObject)
            end
        end
    end
end

---Check if a spot ID is a blackjack table
---@param spotID string spot ID to check
---@return boolean true if it's a blackjack table
local function isBlackjackSpot(spotID)
    return RelativeCoordinateCalulator.registeredTables[spotID] ~= nil
end

--[[    removed due to bugged. future fix.
            NPC ends up breifly T-posing before animation starts.
            My guess is the transitions aren't setup correctly
                likely the wrong .anims file linked to the .workspot file, i hope. 
                
---@param tableID string table ID for dealer workspot
local function attachedDealerToWorkspot(tableID)
    local workspotPosition, workspotOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'dealer_workspot_position')
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local foldHandsEntPath = "boe6\\gamblingsystemblackjack\\npc_handsfolded_workspot.ent"
    local spec2 = DynamicEntitySpec.new()
    spec2.templatePath = foldHandsEntPath
    spec2.position = workspotPosition
    spec2.orientation = workspotOrientation
    spec2.tags = {"Blackjack","dealerAnimation"}
    local animEntID = dynamicEntitySystem:CreateEntity(spec2)
    local function callback1()
        local npcEntity = Game.FindEntityByID(dealerEntID)
        local animEntity = Game.FindEntityByID(animEntID)
        local workspotSystem = Game.GetWorkspotSystem()
        workspotSystem:PlayInDevice(animEntity, npcEntity) --Play workspot
    end
    Cron.After(0.5, callback1)
end
]]--


-- Register Events
--================
registerForEvent( "onInit", function() 
    SpotManager.init()
    CardEngine.init()
    interactionUI.init()
	GameLocale.Initialize()
    HandCountDisplay.init()

    GameSession.StoreInDir('sessions')
    GameSession.Persist(DisplayHandValuesOption)
    GameSession.Persist(ForcedCameraOption)
    GameSession.OnLoad(function()
        -- This state is not reset when the mod is reloaded
        --DualPrint('data loaded; enabled card value: '..tostring(DisplayHandValuesOption[1]))
        --DualPrint('data loaded; forced camera: '..tostring(ForcedCameraOption[1]))
    end)
    GameSession.TryLoad()

    local currentHandValueSetting = DisplayHandValuesOption[1]
    local currentForcedCameraSetting = ForcedCameraOption[1]

    BlackjackCoordinates.init() --initializes the ALL blackjack coordinates
    
    -- Initialize table center points for all registered tables (cached for performance)
    for tableID, tableData in pairs(RelativeCoordinateCalulator.registeredTables) do
        -- Try to get center point from offset, fallback to table position
        local centerPos, _ = RelativeCoordinateCalulator.calculateRelativeCoordinate(tableID, 'spinner_center_point')
        
        if centerPos then
            TableManager.SetTableCenterPoint(tableID, {
                x = centerPos.x,
                y = centerPos.y,
                z = centerPos.z
            })
        else
            -- Fallback: use table's registered position as center
            TableManager.SetTableCenterPoint(tableID, {
                x = tableData.position.x,
                y = tableData.position.y,
                z = tableData.position.z
            })
        end
    end
    
    -- Load all tables and create spots for each
    TableManager.LoadTables(ForcedCameraOption)

    -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
        inMenu = isInMenu
    end)
    --Setup observer and GameUI to detect inGame / inMenu
    --credit: keanuwheeze | init.lua from the sitAnywhere mod
    inGame = false
    GameUI.OnSessionStart(function()
        inGame = true
    end)
    GameUI.OnSessionEnd(function()
        inGame = false
    end)
    inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

    -- Save and Load detection, coutesy of psiberx; available in #cet-snippets in discord
    local isLoaded = GetPlayer() and GetPlayer():IsAttached() and not Game.GetSystemRequestsHandler():IsPreGame()
    Observe('QuestTrackerGameController', 'OnInitialize', function()
        if not isLoaded then
            --DualPrint('Game Session Started')
            isLoaded = true

            --reset all variables to default to avoid save/load bugs
            SingleRoundLogic.dealerCardCount = 0
            SingleRoundLogic.dealerBoardCards = {}
            SingleRoundLogic.playerHands = {{}}
            SingleRoundLogic.activePlayerHandIndex = 1
            SingleRoundLogic.bustedHands = {false,false,false,false}
            SingleRoundLogic.blackjackHandsPaid = {false,false,false,false}
            SingleRoundLogic.doubledHands = {false,false,false,false}
            SingleRoundLogic.dealerHandRevealed = false
            blackjackCamera.forcedCam = false
            blackjackCamera.activeCam = nil
            if blackjackCamera.appliedCameraControlStatus then
                StatusEffectHelper.RemoveStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
                blackjackCamera.appliedCameraControlStatus = false
            end
            --GetMod("ImmersiveFirstPerson").api.Enable()

            interactionUI.hideHub()
        end
    end)
    Observe('QuestTrackerGameController', 'OnUninitialize', function()
        if GetPlayer() == nil then
            --loading new save initiated
            --print('Game Session Ended')
            isLoaded = false

            TableManager.cleanupAllDealers()
        end
    end)

    -- Check if ImmersiveFirstPerson mod is installed and set compatibility variable
    local immersiveFirstPerson = GetMod("ImmersiveFirstPerson")
    if immersiveFirstPerson == nil then
        ImmersiveFirstPersonInstalled = false
    else
        DualPrint('ImmersiveFirstPerson mod found. Applying known workarounds, expect some visual bugs.')
        ImmersiveFirstPersonInstalled = true
    end
    
    -- Register camera management callbacks for blackjack spots only
    SpotManager.RegisterOnSpotEnter(function(spotID, spotObject)
        -- Only handle camera for blackjack spots
        if not isBlackjackSpot(spotID) then
            return
        end
        
        -- Only apply NoCameraControl if top-down camera is enabled
        if ImmersiveFirstPersonInstalled and ForcedCameraOption[1] and spotObject.camera_useForcedCamInWorkspot then
            --disables camera control. User movement input + Immersive First Person causes visual bug
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "GameplayRestriction.NoCameraControl")
            blackjackCamera.appliedCameraControlStatus = true
        end
    end)
    
    SpotManager.RegisterOnSpotEnterAfterAnimation(function(spotID, spotObject)
        -- Only handle camera for blackjack spots
        if not isBlackjackSpot(spotID) then
            return
        end
        
        blackjackCamera.activeCam = spotID
        if spotObject.camera_useForcedCamInWorkspot then
            setForcedCamera(true, spotObject)
        end
    end)
    
    SpotManager.RegisterOnSpotExit(function(spotID, spotObject)
        -- Only handle camera for blackjack spots
        if not isBlackjackSpot(spotID) then
            return
        end
        
        setForcedCamera(false) --disable forced camera perspective
        blackjackCamera.activeCam = nil
    end)

    --native settings UI
    local nativeSettings = GetMod("nativeSettings")
    if (not nativeSettings.pathExists("/gamblingSystem")) then
        nativeSettings.addTab("/gamblingSystem", GameLocale.Text("Gambling System")) -- Add a tab (path, label, callback)
    end
    nativeSettings.addSubcategory("/gamblingSystem/blackjack", GameLocale.Text("Blackjack Settings")) -- Add a subcategory (path, label, optionalIndex)
     -- Parameters: path, label, desc, currentValue, defaultValue, callback, optionalIndex
    nativeSettings.addSwitch("/gamblingSystem/blackjack", GameLocale.Text("Show Hand Values"), 
            GameLocale.Text("Enable/Disable the automatic calculator for hand values, 21, etc."), currentHandValueSetting, true, function(state)
        -- save the changes to session
        DisplayHandValuesOption[1] = state
    end)
    nativeSettings.addSwitch("/gamblingSystem/blackjack", GameLocale.Text("Top-Down Camera"), 
            GameLocale.Text("Enable Top-Down camera view while sitting at the table. (Recommended) (Causes flashing when used with ImmersiveFirstPerson mod)"), currentForcedCameraSetting, false, function(state)
        -- save the changes to session
        ForcedCameraOption[1] = state
        -- update the spot configuration for all tables
        for tableID, _ in pairs(RelativeCoordinateCalulator.registeredTables) do
            SpotManager.changeSpotData(false, {camera_useForcedCamInWorkspot = state}, tableID)
        end
    end)

end)
registerForEvent('onUpdate', function(dt)
    if  not inMenu and inGame then
        Cron.Update(dt) -- First update (maintains 2x speed behavior)
        Cron.Update(dt) -- Second update (compensates for removed call in SpotManager.update)
        SpotManager.update(dt)
        updateForcedCamera() -- Update blackjack camera
        CardEngine.update(dt)
        interactionUI.update()
        local chips = BlackjackMainMenu.getCurrentChips()
        HolographicValueDisplay.Update(chips)
        BlackjackMainMenu.Update()
        HandCountDisplay.update()
        SingleRoundLogic.update()
        
        -- Distance-based dealer spawning/despawning
        local player = GetPlayer()
        if player and player:IsAttached() then
            local playerPosition = player:GetWorldPosition()
            local spawnDistance = 20.0  -- Spawn dealers when player is within 20 units
            local despawnDistance = 30.0  -- Despawn dealers when player is beyond 30 units
            
            for tableID, tableData in pairs(RelativeCoordinateCalulator.registeredTables) do
                -- Use cached center point if available, fallback to table position
                local centerPoint = TableManager.GetTableCenterPoint(tableID)
                local tablePosition
                if centerPoint then
                    tablePosition = Vector4.new(centerPoint.x, centerPoint.y, centerPoint.z, 1)
                else
                    tablePosition = tableData.position
                end
                
                local dx = playerPosition.x - tablePosition.x
                local dy = playerPosition.y - tablePosition.y
                local dz = playerPosition.z - tablePosition.z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
                
                local isSpawned = TableManager.isDealerSpawned(tableID)
                
                if distance <= spawnDistance and not isSpawned then
                    -- Spawn dealer when player is close enough
                    TableManager.spawnDealer(tableID)
                elseif distance > despawnDistance and isSpawned then
                    -- Despawn dealer when player is far enough
                    TableManager.despawnDealer(tableID)
                end
            end
        end
    end
end)
registerForEvent('onShutdown', function()
    GameSession.TrySave()
end)

--[[
registerHotkey('DevHotkey1', 'Dev Hotkey 1', function()
    DualPrint('||=1  Dev hotkey 1 Pressed =')

    local activeTableID = TableManager.GetActiveTable()
    if activeTableID then
        SpotManager.ExitSpot(activeTableID)
    end
    BlackjackMainMenu.playerChipsMoney = 0
end)
registerHotkey('DevHotkey2', 'Dev Hotkey 2', function()
    DualPrint('||=2  Dev hotkey 2 Pressed =')

    DualPrint('DisplayHandValuesOption[1]: '..tostring(DisplayHandValuesOption[1]))

    DualPrint('immersiveFirstPerson.API.IsEnabled(): '..tostring(GetMod("ImmersiveFirstPerson").api.IsEnabled()))
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


--[[ animations tested
very nice 2 palms down:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__2h_flick__01", 1.7, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__describe_front__01", 1.7, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__describe_front__02", 1.0, "sit_chair_table_lean0__2h_on_table__01") --tiny offer forward
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__lh_flick__03", 1.5, "sit_chair_table_lean0__2h_on_table__01") --offer forward
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__talk__02", 1.9, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__talk__05", 3.1, "sit_chair_table_lean0__2h_on_table__01") --drink cup
camera movement glitchy:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__drink__01", 4.5, "sit_chair_table_lean0__2h_on_table__01")
other arm weirdly jerks forward:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__rh_flick__03", 1.5, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__yes__01", 1.9, "sit_chair_table_lean0__2h_on_table__01")
animaiton fucked:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__04", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__03", 1.9, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__personal_link_plugged__01__to__sit_chair_table_lean0__2h_on_table__01", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__to__sit_chair_table_lean0__personal_link_plugged__01", 3.0333, "sit_chair_table_lean0__personal_link_plugged__01")
one palm up:
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__describe_right__01", 2.3666, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__rh_flick__04", 1.6, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__stop__angry__01", 2.4333, "sit_chair_table_lean0__2h_on_table__01")
    SpotManager.ChangeAnimation("sit_chair_table_lean0__2h_on_table__01__yes__01", 2.4, "sit_chair_table_lean0__2h_on_table__01")
]]--

--Methods
--=======


--End of File
--===========
return GamblingSystemBlackjack