SpotManager = {
    version = '1.1.18',
    spots = {},
    activeSpotID = nil, -- Tracks which spot the player is currently in (nil = not in any spot)
    -- Performance optimization variables
    uiUpdateTimer = nil,
    playerCacheTimer = nil,
    cachedPlayer = nil,
    cachedPlayerPosition = nil,
    -- Callback system for external mods to hook into spot events
    callbacks = {
        onSpotEnter = {}, -- Array of functions: function(spotID, spotObject)
        onSpotEnterAfterAnimation = {}, -- Array of functions: function(spotID, spotObject)
        onSpotExit = {}, -- Array of functions: function(spotID, spotObject)
        onSpotExitAfterAnimation = {} -- Array of functions: function(spotID, spotObject)
    }
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================
-- HUGE Credit and thank you to keanuwheeze for worldInteraction.lua, which I referenced heavily for this script.

local Cron = require('External/Cron.lua')
local GameUI = require("External/GameUI.lua")
local interactionUI = require("External/interactionUI.lua")-- by keanuwheeze

local inMenu = true --libaries requirement
local inGame = false

--[[
local spotTemplate = {                                         --Use this as reference when creating new spot
    spot_id = 'default',                                                                                        --REQUIRED | string, unique name. NO REPEATS. DO NOT LEAVE AS 'default'
    spot_worldPosition = Vector4.new(0, 0, 0, 1),  ---------------------------------------------------------------REQUIRED | Vector4, center reference for spot's position in the world. Used for rotation!
    spot_orientation = EulerAngles.new(0,0,0),                                                                  --OPTIONAL | EulerAngles, spot facing direction, used to face entities and to calculate spot rotations
    spot_entWorkspotPath = nil,   --------------------------------------------------------------------------------OPTIONAL | string, relative path to workspot entity, required for workspot animation features
    spot_useWorkSpot = false,                                                                                   --OPTIONAL | boolean, use workspot animation, or only UI features.s
    spot_showingInteractUI = false, ------------------------------------------------------------------------------UNNEEDED | internal boolean, if interaction UI is currently displayed
    animation_defaultName = nil,                                                                                --OPTIONAL | string, animation to return to, when alt animations finish playing, required for workspot animation features
    animation_defaultEnterTime = 2, ------------------------------------------------------------------------------OPTIONAL | number, time(seconds) to wait before triggering return to default animation
    callback_UIwithoutWorkspotTriggered = function()                                                            --OPTIONAL | function, called when interaction UI is triggered without using workspot animation
        --pass
    end,
    callback_OnSpotEnter = function ()  --------------------------------------------------------------------------OPTIONAL | function, called when player first enters spot
        --pass
    end,
    callback_OnSpotEnterAfterAnimationDelayTime = nil,                                                          --OPTIONAL | number, time(seconds) to wait before triggering callback_OnSpotEnterAfterAnimation. Allows for animation time to finish before performing game.
    callback_OnSpotEnterAfterAnimation = function ()    ----------------------------------------------------------OPTIONAL | function, called when player entering spot animation finishes.
        --pass
    end,
    callback_OnSpotExitAfterAnimationDelayTime = nil,                                                           --OPTIONAL | number, time(seconds) to wait after exit before triggering callback_OnSpotExitAfterAnimation. found via trial and error, its Aproximate.
    callback_OnSpotExit = function()    --------------------------------------------------------------------------OPTIONAL | function, called when player first exits spot
        --pass
    end,
    callback_OnSpotExitAfterAnimation = function()                                                              --OPTIONAL | function, called when player exiting spot animation finishes
        --pass
    end,
    exit_orientationCorrection = {r=0,p=0,y=0}, ------------------------------------------------------------------OPTIONAL | {x,y,z}, player orientation adjustment on spot exit.
    exit_worldPositionOffset = {x=0,y=0,z=0},                                                                   --OPTIONAL | {x,y,z}, player position adjustment on spot exit. Location the player exits the spot to.
    exit_animationName = nil,   ----------------------------------------------------------------------------------OPTIONAL | string, animation to trigger on spot exit. transition animation needed. required for workspot animation features
    mappin_worldPosition = Vector4.new(0, 0, 0, 1),                                                             --REQUIRED | Vector4, center reference for mappin's position in the world
    mappin_interactionRange = 2,    ------------------------------------------------------------------------------REQUIRED | number, mappin interaction distance range from player
    mappin_interactionAngle = 80,                                                                               --REQUIRED | number, mappin interaction angle distance allowed from player's looking direction.
    mappin_rangeMax = 8,    --------------------------------------------------------------------------------------REQUIRED | number, mappin range max distance from player position
    mappin_rangeMin = 0,                                                                                        --REQUIRED | number, mappin range min distance from player position
    mappin_color = HDRColor.new({ Red = 0.1582999, Green = 1.3033000, Blue = 1.4141999, Alpha = 1.0 }), ----------OPTIONAL | HDRColor, mappin color tint after viewed by player. default is light blue
    mappin_worldIcon = "ChoiceIcons.SitIcon",                                                                   --REQUIRED | Tweak string, mappin world icon. default is the sit icon
    mappin_hubText = "Hub Text",    ------------------------------------------------------------------------------REQUIRED | string, mappin left UI side hub text. GameLocale recommended. (psiberx github cet-kit)
    mappin_choiceText = "Interact Text",                                                                        --REQUIRED | string, mappin right UI side choice text. see above GameLocale
    mappin_choiceIcon = "ChoiceCaptionParts.SitIcon",   ----------------------------------------------------------REQUIRED | Tweak string, icon used in the UI interaction popup with hub and choice texts
    mappin_choiceFont = gameinteractionsChoiceType.QuestImportant,                                              --REQUIRED | gameinteractionsChoiceType, controls font color used in the UI interaction popup
    mappin_gameMappinID = nil,  ----------------------------------------------------------------------------------UNNEEDED | internal, game mappin id returned from RegisterMappin(). Used to unregister mappin on exit.
    mappin_visible = false,                                                                                     --UNNEEDED | internal boolean, Controls if mappin is currently visible. Used for settings option.
    mappin_variant = gamedataMappinVariant.SitVariant,  ----------------------------------------------------------REQUIRED | gamedataMappinVariant, mappin variant. default is sit. idk which icon in-game this controls tbh. lmk if you know lol
    mappin_showWorldMappinIconSetting = true,                                                                   --OPTIONAL | boolean, If world mappin icon displays at all. This should be controlled by user settings (link to settingsUI DIY)
    mappin_reShowHubBehavior = nil,  -----------------------------------------------------------------------------OPTIONAL | string, sets if the interaction UI should be re-shown after exiting the spot, and in which display manner.
    mappin_visibleThroughWalls = nil,                                                                           --OPTIONAL | boolean, if mappin should be visible through walls. This seems to not work atm? idk lol
    camera_worldPositionOffset = Vector4.new(0, 0, 0, 1),   ------------------------------------------------------OPTIONAL | Vector4, forced camera position offset from player workspot position
    camera_OrientationOffset = EulerAngles.new(0, 0, 0),                                                        --OPTIONAL | EulerAngles, forced camera orientation offset
    camera_showElectroshockEffect = true,   ----------------------------------------------------------------------OPTIONAL | boolean, show electroshock effect on workspot enter. Especially helpful to cover forcedCam glitchyness.
    camera_useForcedCamInWorkspot = nil                                                                         --OPTIONAL | boolean, if forcedCam should be used in workspot animation.
}]]--

--Functions
--=========
-- Performance optimization: Cache player data to avoid expensive calls every frame
local function getCachedPlayerData()
    return SpotManager.cachedPlayer, SpotManager.cachedPlayerPosition
end

-- Update player cache using Cron
local function updatePlayerCache()
    SpotManager.cachedPlayer = GetPlayer()
    if SpotManager.cachedPlayer then
        SpotManager.cachedPlayerPosition = SpotManager.cachedPlayer:GetWorldPosition()
    end
end

local function toggleHUD(state)
    local player = GetPlayer()
    if not player then
        return
    end
    local blackboardDefs = Game.GetAllBlackboardDefs()
    local blackboardPSM = Game.GetBlackboardSystem():GetLocalInstanced(player:GetEntityID(), blackboardDefs.PlayerStateMachine)
    if not blackboardPSM then
        return
    end
    if state then
        blackboardPSM:SetInt(blackboardDefs.PlayerStateMachine.SceneTier, 1, true)
    else
        blackboardPSM:SetInt(blackboardDefs.PlayerStateMachine.SceneTier, 3, true)
    end
end

local function handleHUDToggle(spotObj, state)
    if not spotObj.mappin_toggleHUD then
        return
    end
    if spotObj.mappin_hudVisible == state then
        return
    end
    toggleHUD(state)
    spotObj.mappin_hudVisible = state
end
--- Display Basic UI interaction prompt
---@param spotTable table same as spotObject structure
local function basicInteractionUIPrompt(spotTable) --Display interactionUI menu
    local spotObj = spotTable.spotObject
    local callback = function()
        if spotObj.spot_useWorkSpot then --if using workspot or only UI prompt
            TriggeredSpot(spotTable.spotObject)
        else
            spotTable.spotObject.callback_UIwithoutWorkspotTriggered()
        end
    end
    local choiceText = (type(spotObj.mappin_choiceText) == 'function') and spotObj.mappin_choiceText() or spotObj.mappin_choiceText
    local reShowHubBehavior = spotObj.mappin_reShowHubBehavior
    local choice = interactionUI.createChoice(choiceText, TweakDBInterface.GetChoiceCaptionIconPartRecord(spotObj.mappin_choiceIcon), spotObj.mappin_choiceFont)
    local hub = interactionUI.createHub(spotObj.mappin_hubText, {choice})
    --show UI
    interactionUI.setupHub(hub)
    interactionUI.showHub()
    interactionUI.callbacks[1] = function()
        if reShowHubBehavior == 'hide' or reShowHubBehavior == nil or not reShowHubBehavior then
            interactionUI.hideHub()
        elseif reShowHubBehavior or reShowHubBehavior == 'instantReshow' then
            interactionUI.hideHub()
            basicInteractionUIPrompt(spotTable)
        elseif reShowHubBehavior == 'keep' then
            --no change
        end
        callback()
    end
end
--- Animate player entering spot
---@param spotObject table spots information object
local function animateEnteringSpot(spotObject) --Triggers workspot animation
    local player = GetPlayer()
    local dynamicEntitySystem = Game.GetDynamicEntitySystem()
    local workspotSystem = Game.GetWorkspotSystem()
    local spec = DynamicEntitySpec.new()
    spec.templatePath = spotObject.spot_entWorkspotPath
    spec.position = spotObject.spot_worldPosition
    spec.orientation = spotObject.spot_orientation:ToQuat()
    spec.tags = {"SpotManager"}
    local entID = dynamicEntitySystem:CreateEntity(spec)-- Spawn entity
    spotObject.entID = entID

    Cron.After(1, function() --some delay required, so game can process the new entity
        local entity = Game.FindEntityByID(entID)
        workspotSystem:PlayInDevice(entity, player) --Play workspot
    end)
end

-- Camera management removed - moved to blackjack init.lua

--- Modify existing spot data
---@param spotID string spotID unique; example 'hooh'
---@param changesObject table same as spotObject structure. only include values to change.
local function modifySpot(spotObject, changesObject)
    for k,v in pairs(changesObject) do
        spotObject[k] = v
    end
end

local function exitSpotTeleport(spotObj)
    local player = GetPlayer()
    local playerTransform = player:GetWorldTransform()
    local position = playerTransform:GetWorldPosition()
    local teleportPosition = Vector4.new(
        position:GetX() + spotObj.exit_worldPositionOffset.x,
        position:GetY() + spotObj.exit_worldPositionOffset.y,
        position:GetZ() + spotObj.exit_worldPositionOffset.z,1)
    local baseOri = spotObj.spot_orientation
    local offOri = spotObj.exit_orientationCorrection
    local localEuler = EulerAngles.new( baseOri.roll+offOri.r, baseOri.pitch+offOri.p, baseOri.yaw+offOri.y )
    Game.GetTeleportationFacility():Teleport(player, teleportPosition, localEuler)--150 hardcoded..?
    Game.GetWorkspotSystem():SendFastExitSignal(player)
end

-- Camera update removed - moved to blackjack init.lua

local function interactionUIUpdate(spotTable)
    local spotObj = spotTable.spotObject
    local player, position = getCachedPlayerData()
    
    -- Early exit if player data is invalid
    if not player or not position then
        return
    end
    
    
    local mapping_pos = spotObj.mappin_worldPosition
    local player2mappinDistance = Vector4.Distance(position, mapping_pos)

    -- Early exit if too far away (most common case)
    if player2mappinDistance >= spotObj.mappin_interactionRange then
        if spotObj.spot_showingInteractUI then
            spotObj.spot_showingInteractUI = false
            if not spotObj.disableDefaultUI then
                interactionUI.hideHub()
            end
            if spotObj.callback_OnVisibilityChange then
                spotObj.callback_OnVisibilityChange(false)
            end
        end
        return
    end

    -- Skip all UI looking direction updates if player is already in a spot
    -- Looking direction checks should only apply to the "Join" prompt
    if SpotManager.IsPlayerInSpot() then
        return
    end

    local shouldShowUI = true --start shouldShowUI logic
    local vector4difference = Vector4.new(position.x - mapping_pos.x, position.y - mapping_pos.y, position.z - mapping_pos.z, 0)
    local forwardVector = player:GetWorldForward()
    local angleBetween = Vector4.GetAngleBetween(forwardVector, vector4difference)
    
    -- Check interaction angle
    if not ( 180 - angleBetween < spotObj.mappin_interactionAngle ) then
        shouldShowUI = false
    end
    
    -- Only check pitch if angle check passed (expensive camera call)
    if shouldShowUI then
        local pitch = Game.GetCameraSystem():GetActiveCameraData().rotation:ToEulerAngles().pitch
        local min, max = -75, -10
        if not (min < pitch and pitch < max) then -- check looking pitch_angle, if looking too far up or down
            shouldShowUI = false
        end
    end

    if shouldShowUI ~= spotObj.spot_showingInteractUI then --show or hide the "join" dialog UI
        spotTable.spotObject.spot_showingInteractUI = shouldShowUI
        if shouldShowUI then
            if not spotObj.disableDefaultUI then
                basicInteractionUIPrompt(spotTable)
            end
            -- Always call callback when UI should show (for custom UI systems)
            if spotObj.callback_OnVisibilityChange then
                spotObj.callback_OnVisibilityChange(true)
            end
        else
            if not spotObj.disableDefaultUI then
                interactionUI.hideHub()
            end
            -- Always call callback when UI should hide
            if spotObj.callback_OnVisibilityChange then
                spotObj.callback_OnVisibilityChange(false)
            end
        end
    end
end

local function mappinUIUpdate(spotTable)
    local spotObj = spotTable.spotObject
    local player, position = getCachedPlayerData()
    
    -- Early exit if player data is invalid
    if not player or not position then
        return
    end
    
    local mapping_pos = spotObj.mappin_worldPosition
    local player2mappinDistance = Vector4.Distance(position, mapping_pos)

    local shouldShowIcon = true --start shouldShowIcon logic
    local currentlyShowingIcon = spotObj.mappin_visible

    -- Early exit conditions - check most restrictive first
    if spotObj.mappin_showWorldMappinIconSetting == false then
        shouldShowIcon = false
    elseif player2mappinDistance > spotObj.mappin_rangeMax then
        shouldShowIcon = false
    elseif player2mappinDistance < spotObj.mappin_rangeMin then
        shouldShowIcon = false
    elseif spotObj.mappin_extraVisibilityCheck and not spotObj.mappin_extraVisibilityCheck() then
        shouldShowIcon = false
    end

    if shouldShowIcon ~= currentlyShowingIcon then -- show or hide the mappin
        if shouldShowIcon then
            spotTable.spotObject.mappin_visible = true
            local mappin_data = MappinData.new({ mappinType = 'Mappins.DefaultStaticMappin', variant = spotObj.mappin_variant, visibleThroughWalls = spotTable.spotObject.mappin_visibleThroughWalls })
            spotTable.spotObject.mappin_gameMappinID = Game.GetMappinSystem():RegisterMappin(mappin_data, spotTable.spotObject.mappin_worldPosition)
            -- Only set HUD to visible state when mappin appears (don't toggle it off when it disappears)
            handleHUDToggle(spotObj, true)
        else
            spotTable.spotObject.mappin_visible = false
            Game.GetMappinSystem():UnregisterMappin(spotTable.spotObject.mappin_gameMappinID)
            spotTable.spotObject.mappin_gameMappinID = nil
            -- Don't toggle HUD off when mappin disappears - leave UI visible
        end
    end
end

---Triggered on interactionUI choice to enter workspot
---@param spotObject table spots information object
function TriggeredSpot(spotObject)
    animateEnteringSpot(spotObject)
    SpotManager.activeSpotID = spotObject.spot_id
    
    -- Call spot's own callback
    spotObject.callback_OnSpotEnter()
    
    -- Call registered callbacks
    for _, callback in ipairs(SpotManager.callbacks.onSpotEnter) do
        callback(spotObject.spot_id, spotObject)
    end
    
    local enterCallback = function()
        if spotObject.camera_showElectroshockEffect then
            StatusEffectHelper.ApplyStatusEffect(GetPlayer(), "BaseStatusEffect.FatalElectrocutedParticleStatus")
        end
        -- Camera management moved to callbacks in init.lua
    end
    Cron.After(spotObject.animation_defaultEnterTime, enterCallback)
    
    -- Call spot's own callback after animation delay
    Cron.After(spotObject.callback_OnSpotEnterAfterAnimationDelayTime, function()
        spotObject.callback_OnSpotEnterAfterAnimation()
        -- Call registered callbacks
        for _, callback in ipairs(SpotManager.callbacks.onSpotEnterAfterAnimation) do
            callback(spotObject.spot_id, spotObject)
        end
    end)
end

--Register Events (passed from parent)
--===============
function SpotManager.init() --runs on game launch

    -- Performance optimization: Set up Cron timers for UI updates
    SpotManager.playerCacheTimer = Cron.Every(0.05, updatePlayerCache) -- Update player cache every 50ms
    SpotManager.uiUpdateTimer = Cron.Every(0.1, function() -- Update UI elements every 100ms
        if not inMenu and inGame then
            for _, spotTable in pairs(SpotManager.spots) do
                interactionUIUpdate(spotTable)
                mappinUIUpdate(spotTable)
            end
        end
    end)

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu, credit: keanuwheeze | init.lua from the sitAnywhere mod
        inMenu = isInMenu
    end)

    ObserveAfter("BaseMappinBaseController", "UpdateRootState", function(this) -- Custom mappin texture
        local mappin = this:GetMappin()
        if not mappin then
            return
        end
        local worldPosition = mappin:GetWorldPosition()
        for i, spotTable in pairs(SpotManager.spots) do
            local spotObj = spotTable.spotObject
            if Vector4.Distance(worldPosition, spotObj.mappin_worldPosition) < 0.05 and spotObj.spot_showingInteractUI then
                local record = TweakDBInterface.GetUIIconRecord(spotObj.mappin_worldIcon)
                this.iconWidget:SetAtlasResource(record:AtlasResourcePath())
                this.iconWidget:SetTexturePart(record:AtlasPartName())
                this.iconWidget:SetTintColor(spotObj.mappin_color or HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 }))
            end
        end
    end)

    inGame = false          --Setup observer and GameUI to detect inGame / inMenu
    GameUI.OnSessionStart(function() --  credit: keanuwheeze | init.lua from the sitAnywhere mod
        inGame = true

        for i, spotTable in pairs(SpotManager.spots) do
            spotTable.spotObject.spot_showingInteractUI = false
            spotTable.spotObject.mappin_visible = false
            spotTable.spotObject.mappin_gameMappinID = nil
        end
        
        -- Restart the Cron timers that were halted during session end
        if not SpotManager.playerCacheTimer then
            SpotManager.playerCacheTimer = Cron.Every(0.05, updatePlayerCache)
        end
        if not SpotManager.uiUpdateTimer then
            SpotManager.uiUpdateTimer = Cron.Every(0.1, function()
                if not inMenu and inGame then
                    for _, spotTable in pairs(SpotManager.spots) do
                        interactionUIUpdate(spotTable)
                        mappinUIUpdate(spotTable)
                    end
                end
            end)
        end
        
    end)
    GameUI.OnSessionEnd(function()
        inGame = false
        -- Clean up performance optimization timers
        if SpotManager.playerCacheTimer then
            Cron.Halt(SpotManager.playerCacheTimer)
            SpotManager.playerCacheTimer = nil
        end
        if SpotManager.uiUpdateTimer then
            Cron.Halt(SpotManager.uiUpdateTimer)
            SpotManager.uiUpdateTimer = nil
        end
    end)
    inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods

end
function SpotManager.update(dt) --runs every frame
    -- Camera updates moved to blackjack init.lua
end

--Methods
--=======
--- Animate player leaving spot
--- @param id any identification id
function SpotManager.ExitSpot(id) --Exit spot
    local spot = SpotManager.spots[id]
    local spotObj = spot.spotObject
    
    -- Call registered callbacks before exit
    for _, callback in ipairs(SpotManager.callbacks.onSpotExit) do
        callback(id, spotObj)
    end
    
    -- Call spot's own callback
    spot.spotObject.callback_OnSpotExit()
    
    SpotManager.ChangeAnimation(spot.spotObject.exit_animationName, spot.spotObject.callback_OnSpotExitAfterAnimationDelayTime + 3, spot.spotObject.animation_defaultName)

    Cron.After(spotObj.callback_OnSpotExitAfterAnimationDelayTime, function() -- Wait for animation to finish
        exitSpotTeleport(spotObj)
        
        -- Call spot's own callback
        spot.spotObject.callback_OnSpotExitAfterAnimation()
        
        -- Call registered callbacks
        for _, callback in ipairs(SpotManager.callbacks.onSpotExitAfterAnimation) do
            callback(id, spotObj)
        end
        
        -- Clear active spot after all callbacks
        SpotManager.activeSpotID = nil
    end)
end

--- Add spot to SpotManager's managed list of spots
---@param spotObject table spot information object
function SpotManager.AddSpot(spotObject) --Create spot
    SpotManager.spots[spotObject.spot_id] = {spotObject = spotObject}
end

--- Change Animation for set time, then return to 'default' animation position
---@param animName string Animation to trigger
---@param duration number Duration of animation
---@param returnAnimName string Animation to reset to as default
function SpotManager.ChangeAnimation(animName, duration, returnAnimName)
    local player = Game.GetPlayer()
    local workspotSystem = Game.GetWorkspotSystem()
    workspotSystem:SendJumpToAnimEnt(player, animName, true)
    Cron.After(duration, function()
        workspotSystem:SendJumpToAnimEnt(player, returnAnimName, true)
    end)
end

--- Change 1 or all spot's values
---@param isAllSpots boolean 
---@param changesObject table same as spotObject structure. only include values to change.
---@param spotID? string Optional if not isAllSpots, required to provide a single spotID
function SpotManager.changeSpotData(isAllSpots, changesObject, spotID)
    if isAllSpots then
        for _, spotTable in pairs(SpotManager.spots) do
            modifySpot(spotTable.spotObject, changesObject)
        end
    else
        modifySpot(SpotManager.spots[spotID].spotObject, changesObject)
    end
end

---Converts spot's local coordinates to real world position
---@param spotID string
---@param xyz table local position to convert. syntax: {x=0, y=0, z=0}
---@param rpy table local direction to convert. syntax: {r=0, p=0, y=0}
function SpotManager.spotCoordsToWorldVector(spotID, xyz, rpy)
    local spot = SpotManager.spots[spotID]
    local spotCenter = spot.spotObject.spot_worldPosition   --Vector4.new()
    local spotDirection = spot.spotObject.spot_orientation  --EulerAngles.new()

    --wip
end

---Set the player as being in a spot
---@param spotID string|nil The spot ID the player is entering, or nil to clear
function SpotManager.SetPlayerInSpot(spotID)
    SpotManager.activeSpotID = spotID
end

---Check if the player is currently in any spot
---@return boolean True if player is in a spot, false otherwise
function SpotManager.IsPlayerInSpot()
    return SpotManager.activeSpotID ~= nil
end

---Get the ID of the spot the player is currently in
---@return string|nil The active spot ID, or nil if not in any spot
function SpotManager.GetActiveSpotID()
    return SpotManager.activeSpotID
end

---Clear the player from the current spot (same as SetPlayerInSpot(nil))
function SpotManager.ClearPlayerInSpot()
    SpotManager.activeSpotID = nil
end

---Register a callback for when a player enters a spot
---@param callback function function(spotID, spotObject) - called when player enters a spot
function SpotManager.RegisterOnSpotEnter(callback)
    table.insert(SpotManager.callbacks.onSpotEnter, callback)
end

---Register a callback for when a player enters a spot (after animation)
---@param callback function function(spotID, spotObject) - called when player enters a spot after animation
function SpotManager.RegisterOnSpotEnterAfterAnimation(callback)
    table.insert(SpotManager.callbacks.onSpotEnterAfterAnimation, callback)
end

---Register a callback for when a player exits a spot
---@param callback function function(spotID, spotObject) - called when player exits a spot
function SpotManager.RegisterOnSpotExit(callback)
    table.insert(SpotManager.callbacks.onSpotExit, callback)
end

---Register a callback for when a player exits a spot (after animation)
---@param callback function function(spotID, spotObject) - called when player exits a spot after animation
function SpotManager.RegisterOnSpotExitAfterAnimation(callback)
    table.insert(SpotManager.callbacks.onSpotExitAfterAnimation, callback)
end

---Get the currently active spot object (if player is in a spot)
---@return table|nil spot object or nil if not in any spot
function SpotManager.GetActiveSpotObject()
    if not SpotManager.activeSpotID then
        return nil
    end
    local spot = SpotManager.spots[SpotManager.activeSpotID]
    return spot and spot.spotObject or nil
end

return SpotManager