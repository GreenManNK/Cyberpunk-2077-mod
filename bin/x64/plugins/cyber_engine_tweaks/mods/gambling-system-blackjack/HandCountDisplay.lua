HandCountDisplay = {
    version = '1.0.3',
    displayEnabled = false,
    displays = {},
    playerActiveHands = 0,
    blinkingCounter = 0
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')

local digitEntPath = "boe6\\gamblingsystemblackjack\\boe6_number_digit_vanilla.ent"
local blinkingTimer = 12 --use even number

---Calculates the 3D origin of a hand count display
---@param isDealer boolean true/false
---@param handIndex number? hand number to display count for
---@return Vector4 origin world location for first digit of display
---@return Quaternion orientation world orientation for the display
local function calculateDisplayOrigin(isDealer, handIndex)
    local activeTableID = TableManager.GetActiveTable()
    if not activeTableID then
        DualPrint("Warning: No active table when calculating hand count display origin")
        return Vector4.new(0, 0, 0, 1), Quaternion.new(0, 0, 0, 1)
    end
    
    local basePosition, baseOrientation
    
    if isDealer then
        -- Dealer offset is relative to player base position, not table directly
        -- First get the player base position
        local playerBasePos, playerBaseOri = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'hand_count_display_base_player')
        -- Then apply dealer offset relative to player base (using table orientation for direction)
        basePosition, baseOrientation = RelativeCoordinateCalulator.calculateFromPositionWithTable(
            playerBasePos,
            activeTableID,
            'hand_count_display_base_dealer'
        )
    elseif handIndex then
        -- Use player base offset
        basePosition, baseOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'hand_count_display_base_player')
        
        -- For hands beyond the first, apply spacing offsets
        if handIndex > 1 then
            for i = 2, handIndex do
                basePosition, baseOrientation = RelativeCoordinateCalulator.calculateFromPositionWithTable(
                    basePosition,
                    activeTableID,
                    'hand_count_display_spacing_players'
                )
            end
        end
    else
        -- Default to player base offset for hand 1
        basePosition, baseOrientation = RelativeCoordinateCalulator.calculateRelativeCoordinate(activeTableID, 'hand_count_display_base_player')
    end
    
    return basePosition, baseOrientation
end

---Spawns digit entity in world. Sets HandCountDisplay.displays[id].entID
---@param digit1or2 integer 1 or 2, first or 2nd digit.
---@param displayID string id of containing display, ie "playerHand3"
---@param appName string appearance name for entity
---@param worldPosition Vector4 world position
---@param orientation Quaternion world orientation
local function spawnDigit(digit1or2, displayID, appName, worldPosition, orientation)
    local spec = StaticEntitySpec.new()
    spec.templatePath = digitEntPath
    spec.appearanceName = appName
    spec.position = worldPosition
    spec.orientation = orientation
    spec.tags = {"HandCountDisplay",tostring(id)}--marked to avoid conflicts with other scripts

    local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
    if digit1or2 == 1 then
        HandCountDisplay.displays[displayID].ent1ID = entityID
    else
        HandCountDisplay.displays[displayID].ent2ID = entityID
    end
end

--- Spawns 2 digits for a hand count display
---@param isDealer boolean true/false, is the dealer's hand?
---@param handIndex number? hand number to display count for
local function displayStartup(isDealer, handIndex)
    local digit1pos
    local digit2pos
    local digit1orientation
    local digit2orientation
    local digit1app = "0"
    local digit2app = "0"
    local value

    local activeTableID = TableManager.GetActiveTable()
    if not activeTableID then
        DualPrint("Warning: No active table when starting hand count display")
        return
    end
    
    if isDealer then
        digit1pos, digit1orientation = calculateDisplayOrigin(true)
        -- Calculate digit2 position relative to digit1 using the spacing offset
        digit2pos, digit2orientation = RelativeCoordinateCalulator.calculateFromPositionWithTable(
            digit1pos,
            activeTableID,
            'hand_count_display_digit2_spacing'
        )
        HandCountDisplay.displays['dealerHand'].enabled = true
        value = SingleRoundLogic.dealerCardsValue
    elseif handIndex then
        digit1pos, digit1orientation = calculateDisplayOrigin(false, handIndex)
        -- Calculate digit2 position relative to digit1 using the spacing offset
        digit2pos, digit2orientation = RelativeCoordinateCalulator.calculateFromPositionWithTable(
            digit1pos,
            activeTableID,
            'hand_count_display_digit2_spacing'
        )
        HandCountDisplay.displays['playerHand'..tostring(handIndex)].enabled = true
        value = SingleRoundLogic.playerCardsValue[handIndex]
    end

    if value ~= 0 then
        local tens = math.floor(value / 10)
        local ones = value % 10
        digit1app = tostring(tens)
        digit2app = tostring(ones)
    end

    if isDealer then
        spawnDigit(1, "dealerHand", digit1app, digit1pos, digit1orientation)
        spawnDigit(2, "dealerHand", digit2app, digit2pos, digit2orientation)
        HandCountDisplay.displays['dealerHand'].appValue = value
    elseif handIndex then
        spawnDigit(1, "playerHand"..tostring(handIndex), digit1app, digit1pos, digit1orientation)
        spawnDigit(2, "playerHand"..tostring(handIndex), digit2app, digit2pos, digit2orientation)
        HandCountDisplay.displays['playerHand'..tostring(handIndex)].appValue = value
    end
end

local function displayShutdown(isDealer, handIndex)
    local display
    if isDealer then
        display = HandCountDisplay.displays['dealerHand']
    elseif handIndex then
        display = HandCountDisplay.displays['playerHand'..tostring(handIndex)]
    else
        DualPrint('HCD | Incorrect displayShutdown() call. Error #4027')
        return
    end
    
    if not display then
        DualPrint('HCD | Display not found in displayShutdown()')
        return
    end
    
    if display.ent1ID then
        Game.GetStaticEntitySystem():DespawnEntity(display.ent1ID)
        display.ent1ID = nil
    end
    if display.ent2ID then
        Game.GetStaticEntitySystem():DespawnEntity(display.ent2ID)
        display.ent2ID = nil
    end
    display.enabled = false
end

---Update display values to match current card's hand's values
local function updateEachDisplay()
    local dealerDisplay = HandCountDisplay.displays['dealerHand']
    if dealerDisplay.enabled then
        dealerDisplay.value = SingleRoundLogic.dealerCardsValue
        if dealerDisplay.value ~= dealerDisplay.appValue then
            local tens = math.floor(dealerDisplay.value / 10)
            local ones = dealerDisplay.value % 10
            dealerDisplay.appValue = dealerDisplay.value
            local digit1Entity = Game.FindEntityByID(dealerDisplay.ent1ID)
            local digit2Entity = Game.FindEntityByID(dealerDisplay.ent2ID)
            if digit1Entity and digit2Entity then
                local function callback()
                    digit1Entity:ScheduleAppearanceChange(tostring(tens))
                    digit2Entity:ScheduleAppearanceChange(tostring(ones))
                end
                Cron.After(1.0, callback)
            end
        end
    end
    for i, hand in pairs(SingleRoundLogic.playerHands) do
        local playerDisplay = HandCountDisplay.displays['playerHand'..tostring(i)]
        local tens = math.floor(playerDisplay.value / 10)
        local ones = playerDisplay.value % 10
        local digit1Entity = nil
        local digit2Entity = nil
        if playerDisplay.ent1ID then
            digit1Entity = Game.FindEntityByID(playerDisplay.ent1ID)
        end
        if playerDisplay.ent2ID then
            digit2Entity = Game.FindEntityByID(playerDisplay.ent2ID)
        end
        if playerDisplay.enabled then
            playerDisplay.value = SingleRoundLogic.playerCardsValue[i]
            if playerDisplay.value ~= playerDisplay.appValue then
                if digit1Entity and digit2Entity then
                    local function callback()
                        playerDisplay.appValue = playerDisplay.value
                        digit1Entity:ScheduleAppearanceChange(tostring(tens))
                        digit2Entity:ScheduleAppearanceChange(tostring(ones))
                    end
                    Cron.After(1.0, callback)
                end
            elseif SingleRoundLogic.currentlySplit then
                if i == SingleRoundLogic.activePlayerHandIndex then
                    local shouldBeBlueNow = ( HandCountDisplay.blinkingCounter <= (blinkingTimer/2) )
                    local digitsAreBlueNow = HandCountDisplay.displays['playerHand'..tostring(i)].currentlyBlinkingBlue
                    if digitsAreBlueNow and not shouldBeBlueNow then
                        if digit1Entity and digit2Entity then
                            local function callback()
                                digit1Entity:ScheduleAppearanceChange(tostring(tens))
                                digit2Entity:ScheduleAppearanceChange(tostring(ones))
                            end
                            Cron.After(1.0, callback)
                        end
                        HandCountDisplay.displays['playerHand'..tostring(i)].currentlyBlinkingBlue = false
                    end
                    if not digitsAreBlueNow and shouldBeBlueNow then
                        if digit1Entity and digit2Entity then
                            local function callback()
                                digit1Entity:ScheduleAppearanceChange(tostring(tens).."b")
                                digit2Entity:ScheduleAppearanceChange(tostring(ones).."b")
                            end
                            Cron.After(1.0, callback)
                        end
                        HandCountDisplay.displays['playerHand'..tostring(i)].currentlyBlinkingBlue = true
                    end
                elseif HandCountDisplay.displays['playerHand'..tostring(i)].currentlyBlinkingBlue then
                    if digit1Entity and digit2Entity then
                        local function callback()
                            digit1Entity:ScheduleAppearanceChange(tostring(tens))
                            digit2Entity:ScheduleAppearanceChange(tostring(ones))
                        end
                        Cron.After(1.0, callback)
                    end
                    HandCountDisplay.displays['playerHand'..tostring(i)].currentlyBlinkingBlue = false
                end
            end
        end
    end
    --detect new split hands as they happen
    if HandCountDisplay.playerActiveHands ~= #SingleRoundLogic.playerHands then
        if HandCountDisplay.playerActiveHands < #SingleRoundLogic.playerHands then
            for i = HandCountDisplay.playerActiveHands+1, #SingleRoundLogic.playerHands do
                displayStartup(false, i)
            end
        end
        HandCountDisplay.playerActiveHands = #SingleRoundLogic.playerHands
    end
    --detect new dealer hand reveal
    if SingleRoundLogic.dealerHandRevealed and not HandCountDisplay.displays['dealerHand'].enabled then
        displayStartup(true)
    end
end

local function blinkingUpdate()
    HandCountDisplay.blinkingCounter = HandCountDisplay.blinkingCounter + 1
    if HandCountDisplay.blinkingCounter > blinkingTimer then
        HandCountDisplay.blinkingCounter = 0
    end
end

function HandCountDisplay.init()
    HandCountDisplay.displays['playerHand1'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil, currentlyBlinkingBlue=false}
    HandCountDisplay.displays['playerHand2'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil, currentlyBlinkingBlue=false}
    HandCountDisplay.displays['playerHand3'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil, currentlyBlinkingBlue=false}
    HandCountDisplay.displays['playerHand4'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil, currentlyBlinkingBlue=false}
    HandCountDisplay.displays['dealerHand'] = {value=0, appValue=0, enabled=false, ent1ID=nil, ent2ID=nil}
    Cron.Every(0.1, blinkingUpdate)
end
function HandCountDisplay.update()
    if HandCountDisplay.displayEnabled then
        updateEachDisplay()
    end
end

--- Enables or disables the entire display
---@param bool boolean true/false, turns display numbers on or off.
function HandCountDisplay.DisplayEnabled(bool)
    if bool then
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            displayStartup(false, i)
        end
        HandCountDisplay.displayEnabled = true
        HandCountDisplay.playerActiveHands = #SingleRoundLogic.playerHands
    else
        displayShutdown(true)
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            displayShutdown(false, i)
        end
        HandCountDisplay.displayEnabled = false
    end
end


return HandCountDisplay