SingleRoundLogic = {
    version = '1.0.4',
    deckShuffle = {},
    dealerCardCount = 0,
    dealerBoardCards = {},
    playerHands = {{}},
    bustedHands = {false,false,false,false},
    blackjackHandsPaid = {false,false,false,false},
    doubledHands = {false,false,false,false},
    activePlayerHandIndex = 1,
    dealerCardsValue = 0,
    playerCardsValue = {0,0,0,0},
    dealerHandRevealed = false,
    currentlySplit = false,
    highlightOn = false,
    highlightIndex = 0,
    highlightCardsCount = 0
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--===================

local Cron = require('External/Cron.lua')
local interactionUI = require("External/interactionUI.lua")

local topOfDeckXYZ = {x=-1041.759, y=1340.121, z=6.105}
local pFirstCardXYZ = {x=-1041.189, y=1340.711, z=6.085}
local dFirstCardXYZ = {x=-1041.247, y=1340.205, z=6.085}
local standardOri = { r = 0, p = 0, y = -90 }

--Functions
--=========

---Shuffle the deck referenced for card order
local function shuffleDeckInternal()
    local allCards = {  'As','2s','3s','4s','5s','6s','7s','8s','9s','Ts','Js','Qs','Ks',
                        'Ah','2h','3h','4h','5h','6h','7h','8h','9h','Th','Jh','Qh','Kh',
                        'Ac','2c','3c','4c','5c','6c','7c','8c','9c','Tc','Jc','Qc','Kc',
                        'Ad','2d','3d','4d','5d','6d','7d','8d','9d','Td','Jd','Qd','Kd'
                    }
    --alignment comment.
    local devRiggedIndex = {}
    --local devRiggedIndex = {14,1,9,9} --player and dealer both get BJ
    --local devRiggedIndex = {9,5,4,7,7,7} --player doubles on 11 and busts, dealer also busts.
    --local devRiggedIndex = {11,6,1} --player gets blackjack
    --local devRiggedIndex = {10,10,6,4,8,1,7} --player busts and dealer hits if game broken lmao
    --local devRiggedIndex = {5,10,4,1} --dealer gets blackjack
    --local devRiggedIndex = {8,34,20} --2 8s to player
    --local devRiggedIndex = {8,34,20,47,3,42,10} --2 8s to player
    --local devRiggedIndex = {1,48,13,46,25,47,45,37} --4 aces all split
    local newDeck = {}
    for i = 1, 52 do
        if i <= #devRiggedIndex then --the rigging stuff is just for development debugging. This should always be 0.
            local selectedCard = devRiggedIndex[i]
            newDeck[i] = allCards[selectedCard]
            table.remove(allCards, selectedCard)
        else
            local selectedCard = math.random(#allCards)
            newDeck[i] = allCards[selectedCard]
            table.remove(allCards, selectedCard)
        end
    end
    SingleRoundLogic.deckShuffle = newDeck
end

local function currentlySplitUpdate()
    if SingleRoundLogic.highlightOn and SingleRoundLogic.currentlySplit then
        --check if hand swap
        if SingleRoundLogic.highlightIndex ~= SingleRoundLogic.activePlayerHandIndex then --check if moved to next hand
            for i = 1, #SingleRoundLogic.playerHands[highlightIndex] do --for each card in previous hand:
                CardEngine.setHighlightColor('playerCard_h'..string.format("%02d", highlightIndex)..'_c'..string.format("%02d", i), 0) -- 0 = none
            end
            SingleRoundLogic.highlightIndex = SingleRoundLogic.activePlayerHandIndex
            for i = 1, #SingleRoundLogic.playerHands[activePlayerHandIndex] do --for each card in current hand:
                CardEngine.setHighlightColor('playerCard_h'..string.format("%02d", activePlayerHandIndex)..'_c'..string.format("%02d", i), 3) -- 3 = blue
            end
            SingleRoundLogic.highlightCardsCount = #SingleRoundLogic.playerHands[activePlayerHandIndex]
            return
        end
        --check if new cards in hand
        if SingleRoundLogic.highlightCardsCount ~= #SingleRoundLogic.playerHands[SingleRoundLogic.activePlayerHandIndex] then
            local newCardsCount = #SingleRoundLogic.playerHands[SingleRoundLogic.activePlayerHandIndex] - SingleRoundLogic.highlightCardsCount
            for i = 1, newCardsCount do
                local cardID = 'playerCard_h'..string.format("%02d", SingleRoundLogic.activePlayerHandIndex)
                                        ..'_c'..string.format("%02d", SingleRoundLogic.highlightCardsCount+i)
                CardEngine.setHighlightColor(cardID, 3) -- 3 = blue
            end
            SingleRoundLogic.highlightCardsCount = #SingleRoundLogic.playerHands[SingleRoundLogic.activePlayerHandIndex]
        end
    elseif SingleRoundLogic.highlightOn and not SingleRoundLogic.currentlySplit then
        --turn off highlight
        SingleRoundLogic.highlightOn = false
        for i = 1, #SingleRoundLogic.playerHands do --it just turns off glow for all player cards to be safe.
            for j = 1, #SingleRoundLogic.playerHands[i] do
                CardEngine.setHighlightColor('playerCard_h'..string.format("%02d", i)..'_c'..string.format("%02d", j), 0) -- 0 = none
            end
        end
    elseif not SingleRoundLogic.highlightOn and SingleRoundLogic.currentlySplit then
        --turn on highlight for current hand
        SingleRoundLogic.highlightOn = true
        SingleRoundLogic.highlightIndex = 1
        SingleRoundLogic.highlightCardsCount = 1 --only does 1 card to wait for 2nd card to spawn.
        local cardID = 'playerCard_h'..string.format("%02d", SingleRoundLogic.activePlayerHandIndex)..'_c1'
        CardEngine.setHighlightColor(cardID, 3) -- 3 = blue
    end

end

--- Animate first round deal.
local function dealStartOfRound()
    local pCard01app = SingleRoundLogic.deckShuffle[1]
    local pCard01cardID = CardEngine.CreateCard('playerCard_h01_c01', pCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerHands[1], pCard01app)
    local dCard01app = SingleRoundLogic.deckShuffle[1]
    local dCard01cardID = CardEngine.CreateCard('dCard01', dCard01app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard01app)
    local pCard02app = SingleRoundLogic.deckShuffle[1]
    local pCard02cardID = CardEngine.CreateCard('playerCard_h01_c02', pCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerHands[1], pCard02app)
    local dCard02app = SingleRoundLogic.deckShuffle[1]
    local dCard02cardID = CardEngine.CreateCard('dCard02', dCard02app, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), { r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.dealerBoardCards, dCard02app)
    SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 2

    --begin animation below
    Cron.After(0.1, function()
        CardEngine.MoveCard('playerCard_h01_c01', Vector4.new(pFirstCardXYZ.x, pFirstCardXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(0.5, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.0, function()
        CardEngine.MoveCard('playerCard_h01_c02', Vector4.new(pFirstCardXYZ.x-0.04, pFirstCardXYZ.y-0.06, pFirstCardXYZ.z+0.0005, 1), standardOri, 'smooth', true)
    end)
    Cron.After(1.5, function()
        CardEngine.MoveCard('dCard02', Vector4.new(dFirstCardXYZ.x-0.005, dFirstCardXYZ.y+0.004, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
end

--- Animate all cards back to the deck & delete, deletes al chips.
local function collectRoundCards()
    HandCountDisplay.DisplayEnabled(false)
    SimpleCasinoChip.despawnAllChips()
    local anyDoubled = false
    for i, j in pairs(SingleRoundLogic.doubledHands) do
        if j == true then
            anyDoubled = true
        end
    end
    local function callback()
        -- Clean up all player cards - iterate through all possible hands and cards
        for j = 1, 4 do -- Maximum possible hands (4 hands max)
            for i = 1, 10 do -- Maximum possible cards per hand
                local curCard = 'playerCard_h'..string.format("%02d", j)..'_c'..string.format("%02d", i)
                -- Check if card exists before trying to move it
                if CardEngine.cards[curCard] then
                    CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1), standardOri, 'smooth', false)
                end
            end
        end
        for i = 1, SingleRoundLogic.dealerCardCount do
            local curCard = 'dCard'..string.format("%02d", i)
            CardEngine.MoveCard(curCard, Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
        end
        Cron.After(3, function()
            -- Clean up all player cards - iterate through all possible hands and cards
            for j = 1, 4 do -- Maximum possible hands (4 hands max)
                for i = 1, 10 do -- Maximum possible cards per hand
                    local curCard = 'playerCard_h'..string.format("%02d", j)..'_c'..string.format("%02d", i)
                    -- Check if card exists before trying to delete it
                    if CardEngine.cards[curCard] then
                        CardEngine.DeleteCard(curCard)
                    end
                end
            end
            for i = 1, SingleRoundLogic.dealerCardCount do
                CardEngine.DeleteCard('dCard'..string.format("%02d", i))
            end
        end)
    end
    if anyDoubled == true then
        for i, j in pairs(SingleRoundLogic.doubledHands) do
            if j == true then
                CardEngine.FlipCard('playerCard_h'..string.format("%02d", i)..'_c03', 'facewise', 'left', true)
            end
        end
        Cron.After(2, callback)
    else
        callback()
    end
end

---Check if the 2 card board is blackjack
---@param board table 2 card table list of card faces
---@return boolean
local function isBoardBJ(board)
    if #board ~= 2 then
        return false
    end
    local twoCards = {string.sub(board[1],1,1),string.sub(board[2],1,1)}
    local totalValue = 0

    for i = 1, 2 do
        if twoCards[i] == 'T' or twoCards[i] == 'J' or twoCards[i] == 'Q' or twoCards[i] == 'K' then
            totalValue = totalValue + 10
        elseif twoCards[i] == 'A' then
            totalValue = totalValue + 11
        else
            totalValue = totalValue + tonumber(twoCards[i])
        end
    end

    if totalValue == 21 then
        return true
    else
        return false
    end
end

---Checks if the board is busted, aka over 21
---@param board table table list of card faces
---@return boolean
local function isBoardBusted(board)
    local runningTotal = 0
    for k,v in pairs(board) do
        if string.sub(v,1,1) == 'A' then
            runningTotal = runningTotal + 1
        elseif string.sub(v,1,1) == 'T' or string.sub(v,1,1) == 'J' or string.sub(v,1,1) == 'Q' or string.sub(v,1,1) == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(string.sub(v,1,1))
        end
    end

    if runningTotal > 21 then
        return true
    else
        return false
    end
end

---Checks if the board's 2 cards are splitable
---@param board table list of card faces
---@return boolean boolean true/false
local function isSplitable(board)
    if #board == 2 then
        local rank1 = string.sub(board[1],1,1)
        local rank2 = string.sub(board[2],1,1)
        if rank1 == rank2 then
            return true
        end
    end
    return false
end

---Checks if the hand is doubleable
---@param handIndex integer index of player hand to check
---@return boolean boolean true/false
local function isDoubleable(handIndex)
    if #SingleRoundLogic.playerHands[handIndex] == 2 then
        return true
    end
end

---Prompt player UI for turn action
---@param hitCallback function callback for when player hits
---@param standCallback function callback for when player stands
---@param splitCallback function callback for when player splits
---@param doubleCallback function callback for when player doubles
local function promptPlayerActionUI(handIndex, hitCallback, standCallback, splitCallback, doubleCallback)
    local allChoices = {}
    local allChoicesRef = {"Hit", "Stand"}
    allChoices[1] = interactionUI.createChoice(GameLocale.Text("Hit"), nil, gameinteractionsChoiceType.Selected) --change from Selected to AlreadyRead later
    allChoices[2] = interactionUI.createChoice(GameLocale.Text("Stand"), nil, gameinteractionsChoiceType.Selected)
    if isSplitable(SingleRoundLogic.playerHands[SingleRoundLogic.activePlayerHandIndex]) then
        if BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            table.insert(allChoices, interactionUI.createChoice(GameLocale.Text("Split"), nil, gameinteractionsChoiceType.Selected))
        else
            table.insert(allChoices, interactionUI.createChoice(GameLocale.Text("Split"), nil, gameinteractionsChoiceType.AlreadyRead))
        end
        table.insert(allChoicesRef, "Split")
    end
    if isDoubleable(SingleRoundLogic.activePlayerHandIndex) then
        if BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            table.insert(allChoices, interactionUI.createChoice(GameLocale.Text("Double"), nil, gameinteractionsChoiceType.Selected))
        else
            table.insert(allChoices, interactionUI.createChoice(GameLocale.Text("Double"), nil, gameinteractionsChoiceType.AlreadyRead))
        end
        table.insert(allChoicesRef, "Double")
    end
    --local choice4 = interactionUI.createChoice("Double", nil, gameinteractionsChoiceType.Selected)
    --local choice5 = interactionUI.createChoice("Surrender", nil, gameinteractionsChoiceType.Selected)
    --local choice6 = interactionUI.createChoice("Insurance", nil, gameinteractionsChoiceType.Selected)

    local hub = interactionUI.createHub("Hand #"..tostring(handIndex), allChoices)
    interactionUI.setupHub(hub)
    interactionUI.showHub()

    interactionUI.callbacks[1] = function()--Hit
        interactionUI.hideHub()
        hitCallback()
    end
    interactionUI.callbacks[2] = function()--Stand
        interactionUI.hideHub()
        standCallback()
    end
    interactionUI.callbacks[3] = function()
        if allChoicesRef[3] == "Split" and BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            interactionUI.hideHub()
            splitCallback()
        end
        if allChoicesRef[3] == "Double" and BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            interactionUI.hideHub()
            doubleCallback()
        end
    end
    interactionUI.callbacks[4] = function()
        if allChoicesRef[4] == "Double" and BlackjackMainMenu.playerChipsMoney >= BlackjackMainMenu.currentBet then
            interactionUI.hideHub()
            doubleCallback()
        end
    end
end

---Returns BJ game value of a set of cards
---@param board table table list of card faces
---@return number number hand value, 21, 18, etc.
local function calculateBoardScore(board)
    --board = {"7h","Ts"} example
    local runningTotal = 0
    local aceCount = 0
    local printList = ''
    for k,card in pairs(board) do
        local rank = string.sub(card,1,1)
        if rank == 'A' then
            aceCount = aceCount + 1
        elseif rank == 'T' or rank == 'J' or rank == 'Q' or rank == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(rank)
        end
        printList = printList..card..', '
    end

    for i = 1, aceCount do
        if runningTotal + 11 + (aceCount-i) <= 21 then
            runningTotal = runningTotal + 11
        else
            runningTotal = runningTotal + 1
        end
    end

    return runningTotal
end

---If the value of current cards is soft, aka using an Ace as an 11 instead of 1.
---@param board table table list of card faces
local function isBoardSoft(board)
    local runningTotal = 0
    local aceCount = 0
    local isSoft = false
    for k,card in pairs(board) do
        local rank = string.sub(card,1,1)
        if rank == 'A' then
            aceCount = aceCount + 1
        elseif rank == 'T' or rank == 'J' or rank == 'Q' or rank == 'K' then
            runningTotal = runningTotal + 10
        else
            runningTotal = runningTotal + tonumber(rank)
        end
    end

    for i = 1, aceCount do
        if runningTotal + 11 + (aceCount-i) <= 21 then
            runningTotal = runningTotal + 11
            isSoft = true
        else
            runningTotal = runningTotal + 1
        end
    end

    return isSoft
end

--- Calculates the chip world position of a bet, given the blackjack hand context.
--- @param handIndex number player hand index
--- @param leftMovement number player bet chip number for that hand. starts at 1
--- @param UpLeftMovement number same as above, diagonal up left, used for payout. starts at 1
--- @return Vector4 newXYZ world position
local function chipLocationCalc(handIndex, leftMovement, UpLeftMovement)
    local startXYZ = {pFirstCardXYZ.x-0.058,pFirstCardXYZ.y+0.142,pFirstCardXYZ.z}
    local newXYZ = {
        startXYZ[1] + (0.02 * (UpLeftMovement-1)) + (0.04 * (leftMovement-1)) + (0.18 * (handIndex-1)),
        startXYZ[2] - (0.035 * (UpLeftMovement-1)),
        startXYZ[3]
    }
    return Vector4.new(newXYZ[1], newXYZ[2], newXYZ[3], 1)
end

---After player and dealer have finished, calculate scores, determine winner hands and payout.
---@param instaBlackjack boolean if player OR dealer has instant blackjack
local function ProcessRoundResult(instaBlackjack)
    DualPrint('--End Round!--')
    SingleRoundLogic.currentlySplit = false
    local dealerScore = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    --isBoardBJ(SingleRoundLogic.dealerBoardCards)
    if instaBlackjack then
        Cron.After(1, FlipDealerTwoCards(false))
        local callback1 = function()
            local dealerBJ = isBoardBJ(SingleRoundLogic.dealerBoardCards)
            local playerBJ = isBoardBJ(SingleRoundLogic.playerHands[1])
            if dealerBJ and playerBJ then
                DualPrint('End Round: Both Blackjack. Push')
                BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
            elseif dealerBJ then
                DualPrint('End Round: Dealer Blackjack.')
                SimpleCasinoChip.despawnChip('chip_hand1_left1_up1')
            elseif playerBJ then
                DualPrint('End Round: Player Blackjack.')
                BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet * 2.5
                GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                SimpleCasinoChip.spawnChip('chip_hand1_left1_up2', BlackjackMainMenu.currentBet, chipLocationCalc(1,1,2), true)
            end
        end
        Cron.After(4, callback1)
    else--not instaBlackjack then
        for i, hand in pairs(SingleRoundLogic.playerHands) do
            local continueHandCheck = true
            if SingleRoundLogic.bustedHands[i] then
                DualPrint('End Hand #'..tostring(i)..': Player Busted.')
                SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left1_up1')
                if SingleRoundLogic.doubledHands[i] then
                    SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left2_up1')
                end
                continueHandCheck = false
            end
            if isBoardBJ(SingleRoundLogic.dealerBoardCards) and continueHandCheck then
                if isBoardBJ(hand) then
                    DualPrint('End Hand #'..tostring(i)..': Both Blackjack. Push')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                    continueHandCheck = false
                end
                DualPrint('End Hand #'..tostring(i)..': Dealer Blackjack.')
                SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left1_up1')
                if SingleRoundLogic.doubledHands[i] then
                    SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left2_up1')
                end
                continueHandCheck = false
            end
            if isBoardBJ(hand) and continueHandCheck then
                DualPrint('End Hand #'..tostring(i)..': Player Blackjack.')
                SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left1_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,1,2), true)
                if SingleRoundLogic.doubledHands[i] then
                    SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left2_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,2,2), true)
                end
                if not SingleRoundLogic.blackjackHandsPaid[i] then
                    DualPrint('playing player BJ point 5')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + (BlackjackMainMenu.currentBet * 2.5)
                    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                    hand.blackjackHandPaid = true
                end
                continueHandCheck = false
            end

            local playerScore = calculateBoardScore(hand)
            if continueHandCheck then
                if dealerScore > 21 then
                    DualPrint('End Hand #'..tostring(i)..': Dealer Busted!')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + (BlackjackMainMenu.currentBet * 2)
                    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                    SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left1_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,1,2), true)
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + (BlackjackMainMenu.currentBet * 2)
                        SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left2_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,2,2), true)
                    end
                elseif playerScore > dealerScore then
                    DualPrint('End Hand #'..tostring(i)..': Player Wins!')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + (BlackjackMainMenu.currentBet * 2)
                    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                    SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left1_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,1,2), true)
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + (BlackjackMainMenu.currentBet * 2)
                        SimpleCasinoChip.spawnChip('chip_hand'..tostring(i)..'_left2_up2', BlackjackMainMenu.currentBet, chipLocationCalc(i,2,2), true)
                    end
                elseif playerScore < dealerScore then
                    DualPrint('End Hand #'..tostring(i)..': Dealer Wins.')
                    SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left1_up1')
                    if SingleRoundLogic.doubledHands[i] then
                        SimpleCasinoChip.despawnChip('chip_hand'..tostring(i)..'_left2_up1')
                    end
                else
                    DualPrint('End Hand #'..tostring(i)..': Tie, Push.')
                    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
                    if SingleRoundLogic.doubledHands[i] then
                        BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + BlackjackMainMenu.currentBet
                    end
                end
            end
            DualPrint(' - Player score: '..tostring(playerScore)..', Dealer score: '..tostring(dealerScore))
        end
    end
    if instaBlackjack then
        Cron.After(7, collectRoundCards)
        Cron.After(11, BlackjackMainMenu.RoundEnded)
    else
        Cron.After(4, collectRoundCards)
        Cron.After(8, BlackjackMainMenu.RoundEnded)
    end
end

--- 1 Step of dealer's action. Hit/Stand
local function dealerAction()
    local score = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    local isSoft = isBoardSoft(SingleRoundLogic.dealerBoardCards)
    if score < 17 or (score == 17 and isSoft) then
        local dCardXapp = SingleRoundLogic.deckShuffle[1]
        local dCardXname = 'dCard'..string.format("%02d", SingleRoundLogic.dealerCardCount+1)
        local cardsNum = SingleRoundLogic.dealerCardCount
        table.remove(SingleRoundLogic.deckShuffle,1)
        local pCardXcardID = CardEngine.CreateCard(dCardXname,dCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
        table.insert(SingleRoundLogic.dealerBoardCards, dCardXapp)
        local newLocation = Vector4.new(dFirstCardXYZ.x+((cardsNum-1)*0.09), dFirstCardXYZ.y, dFirstCardXYZ.z, 1)
        SingleRoundLogic.dealerCardCount = SingleRoundLogic.dealerCardCount + 1
        Cron.After(0.1, CardEngine.MoveCard(dCardXname, newLocation, standardOri, 'smooth', true))
        Cron.After(1.6, function()
            dealerAction()
        end)
    else
        local seconds = SingleRoundLogic.dealerCardCount - 1
        Cron.After(seconds, function()
            ProcessRoundResult(false)
        end)
    end
end

--- animation for dealer to flip two cards
function FlipDealerTwoCards(triggerDealerAction)
    SingleRoundLogic.currentlySplit = false
    Cron.After(0.5, function()
        CardEngine.MoveCard('dCard01', Vector4.new(dFirstCardXYZ.x+0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(1.1, function()
        CardEngine.MoveCard('dCard01',Vector4.new(dFirstCardXYZ.x, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', false)
    end)
    Cron.After(1.3, function()
        CardEngine.MoveCard('dCard02',Vector4.new(dFirstCardXYZ.x-0.09, dFirstCardXYZ.y, dFirstCardXYZ.z, 1), standardOri, 'smooth', true)
    end)
    Cron.After(2.0, function()
        SingleRoundLogic.dealerHandRevealed = true
    end)
    if triggerDealerAction then
        Cron.After(3.0, function()
            dealerAction()
        end)
    end
end

--- Calculates real Vector4 coords for card, given handIndex and card num in that hand.
---@param handIndex any
---@param cardIndex any
---@param minus1Boolean any
---@return Vector4 outVector4 XYZW i think
local function cardTableLocation(handIndex, cardIndex, minus1Boolean)
    local newHandIndex = handIndex
    if minus1Boolean then
        newHandIndex = handIndex - 1
    end
    local outVector4 = Vector4.new(
        pFirstCardXYZ.x-(cardIndex*0.04)+(0.18*(newHandIndex)),
        pFirstCardXYZ.y-(cardIndex*0.06),
        pFirstCardXYZ.z+(cardIndex*0.0005),
        1
    )
    return outVector4
end

--- 1 Step of player's action after player hit.
---@param handIndex integer current player hand Index
local function playerActionHit(handIndex)
    local cardsNum = #(SingleRoundLogic.playerHands[handIndex])
    local pCardXapp = SingleRoundLogic.deckShuffle[1]
    local pCardXname = 'playerCard_h'..string.format("%02d", handIndex)..'_c'..string.format("%02d", cardsNum+1)
    table.remove(SingleRoundLogic.deckShuffle,1)
    local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
    table.insert(SingleRoundLogic.playerHands[handIndex], pCardXapp)
    local newLocation = cardTableLocation(handIndex, cardsNum, true)
    Cron.After(0.1, CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true))

    Cron.After(3, function()
        local playerScore = calculateBoardScore(SingleRoundLogic.playerHands[handIndex])
        if playerScore == 21 then
            -- 21 !
            if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
                FlipDealerTwoCards(true)
            else
                SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                PlayerAction(SingleRoundLogic.activePlayerHandIndex)
            end
        elseif isBoardBusted(SingleRoundLogic.playerHands[handIndex]) then
            --DualPrint('sRL | End Hand: Player Busted!')
            SingleRoundLogic.bustedHands[handIndex] = true
            SimpleCasinoChip.despawnChip('chip_hand'..tostring(handIndex)..'_left1_up1')
            if SingleRoundLogic.doubledHands[handIndex] then
                SimpleCasinoChip.despawnChip('chip_hand'..tostring(handIndex)..'_left1_up2')
            end
            if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
                local allBusted = true
                for i = 1, #SingleRoundLogic.playerHands do
                    if SingleRoundLogic.bustedHands[i] == false then
                        allBusted = false
                    end
                end
                if allBusted then
                    --DualPrint('sRL | All Busted!')
                    ProcessRoundResult(false)
                else
                    FlipDealerTwoCards(true)
                end
            else
                --next player hand
                SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                PlayerAction(SingleRoundLogic.activePlayerHandIndex)
            end
        else
            PlayerAction(handIndex)
        end
    end)
end

---spawn and animate new card from a split action.
---These variables are nonsense. Sorry future Boe6, I already don't remember what they do. 
local function newSplitCard(xCardHand,newCardIndex,newCardMinus1Bool)
    local pCardXapp = SingleRoundLogic.deckShuffle[1]
    local pCardXname = 'playerCard_h'..string.format("%02d", xCardHand)..'_c02'
    table.remove(SingleRoundLogic.deckShuffle,1)
    local pCardXcardID = CardEngine.CreateCard(pCardXname,pCardXapp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
    table.insert(SingleRoundLogic.playerHands[xCardHand], pCardXapp)
    local newLocation = cardTableLocation(newCardIndex, 1, newCardMinus1Bool)
    Cron.After(0.1, function()
        CardEngine.MoveCard(pCardXname, newLocation, standardOri, 'smooth', true)
    end)
end

--- stuff when player selects split
---@param handIndex integer current player hand
local function playerActionSplit(handIndex)
    SingleRoundLogic.currentlySplit = true
    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney - BlackjackMainMenu.currentBet
    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_bet")

    local curHandIndex = SingleRoundLogic.activePlayerHandIndex

    -- 2nd card jumps to closest empty hand space
    local maxHandIndex = #SingleRoundLogic.playerHands
    local cardID = 'playerCard_h'..string.format("%02d", handIndex)..'_c02'
    local cardApp = SingleRoundLogic.playerHands[handIndex][2]
    local cardPos = cardTableLocation(maxHandIndex, 0, false)
    SingleRoundLogic.playerHands[maxHandIndex+1] = {SingleRoundLogic.playerHands[curHandIndex][2]}
    CardEngine.MoveCard(cardID,cardPos,standardOri,'smooth',false)
    table.remove(SingleRoundLogic.playerHands[curHandIndex],2)
    Cron.After(0.8, function()
        local newCardID = 'playerCard_h'..string.format("%02d", maxHandIndex+1)..'_c'..string.format("%02d", 1)
        CardEngine.CreateCard(newCardID,cardApp,cardPos,standardOri)
        CardEngine.DeleteCard(cardID)
    end)
    Cron.After(1, function()
        newSplitCard(handIndex, handIndex, true)
    end)
    Cron.After(2, function()
        newSplitCard(maxHandIndex+1, maxHandIndex, false)
    end)
    Cron.After(2.5, function()
        --CHECK IF PLAYER BLACKJACK
        if isBoardBJ(SingleRoundLogic.playerHands[handIndex]) then
            SingleRoundLogic.blackjackHandsPaid[handIndex] = true
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + ( BlackjackMainMenu.currentBet * 2.5)
            GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
            SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
            PlayerAction(SingleRoundLogic.activePlayerHandIndex)
        else
            PlayerAction(handIndex)
        end
    end)
    local maxHand = #SingleRoundLogic.playerHands
    SimpleCasinoChip.spawnChip('chip_hand'..tostring(maxHand)..'_left1_up1', BlackjackMainMenu.currentBet, chipLocationCalc(maxHand,1,1), true)
end


--- stuff when player selects double
---@param handIndex integer current player hand
local function playerActionDouble(handIndex)
    SingleRoundLogic.doubledHands[handIndex] = true
    BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney - BlackjackMainMenu.currentBet
    GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_bet")

    local cardID = 'playerCard_h'..string.format("%02d", handIndex)..'_c03'
    local cardApp = SingleRoundLogic.deckShuffle[1]
    CardEngine.CreateCard(cardID,cardApp,Vector4.new(topOfDeckXYZ.x, topOfDeckXYZ.y, pFirstCardXYZ.z, 1),{ r = 0, p = 180, y = -90 })
    table.remove(SingleRoundLogic.deckShuffle,1)
    table.insert(SingleRoundLogic.playerHands[handIndex], cardApp)
    SimpleCasinoChip.spawnChip('chip_hand'..tostring(handIndex)..'_left2_up1', BlackjackMainMenu.currentBet, chipLocationCalc(handIndex,2,1), true)
    local calcLocation = cardTableLocation(handIndex, 2, true)
    local newLocation = Vector4.new(
        calcLocation.x+0.04,
        calcLocation.y,
        calcLocation.z,
        1)
    local function callback1()
        --delay move card
        CardEngine.MoveCard(cardID,newLocation,standardOri,'smooth',true)
    end
    Cron.After(2.0, callback1)
    local function callback2()
        CardEngine.FlipCard(cardID, 'facewise', 'left', true)
    end
    Cron.After(4.0, callback2)

    Cron.After(6.0, function ()
        local newHandValue = calculateBoardScore(SingleRoundLogic.playerHands[handIndex])
        if newHandValue > 21 then
            SingleRoundLogic.bustedHands[handIndex] = true
            SimpleCasinoChip.despawnChip('chip_hand'..tostring(handIndex)..'_left2_up1')
            SimpleCasinoChip.despawnChip('chip_hand'..tostring(handIndex)..'_left1_up1')
            if handIndex == #SingleRoundLogic.playerHands then
                ProcessRoundResult(false)
            else
                --next player hand
                SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                PlayerAction(SingleRoundLogic.activePlayerHandIndex)
            end
        else
            if handIndex == #SingleRoundLogic.playerHands then
                    FlipDealerTwoCards(true)
            else
                --next player hand
                    SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
                    PlayerAction(SingleRoundLogic.activePlayerHandIndex)
            end
        end
    end)
end

function SingleRoundLogic.update()
    SingleRoundLogic.dealerCardsValue = calculateBoardScore(SingleRoundLogic.dealerBoardCards)
    for i = 1, #SingleRoundLogic.playerHands do
        SingleRoundLogic.playerCardsValue[i] = calculateBoardScore(SingleRoundLogic.playerHands[i])
    end
    if SingleRoundLogic.currentlySplit then
        --currentlySplitUpdate()
    end
end

--- 1 Step of player's action. Hit/Stand/Etc
function PlayerAction(handIndex)
    --safety check if player has 21 value. Often happens after split cards.
    if calculateBoardScore(SingleRoundLogic.playerHands[handIndex]) == 21 then
        if isBoardBJ(SingleRoundLogic.playerHands[handIndex]) and SingleRoundLogic.blackjackHandsPaid[handIndex] == false then
            SingleRoundLogic.blackjackHandsPaid[handIndex] = true
            BlackjackMainMenu.playerChipsMoney = BlackjackMainMenu.playerChipsMoney + ( BlackjackMainMenu.currentBet * 2.5 )
            GetPlayer():PlaySoundEvent("q303_06a_roulette_chips_stack")
        end
        if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
            FlipDealerTwoCards(true)
        else
            --next player hand
            SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
            PlayerAction(SingleRoundLogic.activePlayerHandIndex)
        end
        return
    end
    local shouldPrompt = true
    local function hitCallback()
        playerActionHit(handIndex)
    end
    local function standCallback()
        if SingleRoundLogic.activePlayerHandIndex == #SingleRoundLogic.playerHands then
            FlipDealerTwoCards(true)
        else
            --next player hand
            SingleRoundLogic.activePlayerHandIndex = SingleRoundLogic.activePlayerHandIndex + 1
            PlayerAction(SingleRoundLogic.activePlayerHandIndex)
        end
    end
    local function splitCallback()
        playerActionSplit(handIndex)
    end
    local function doubleCallback()
        playerActionDouble(handIndex)
    end
    if shouldPrompt then
        promptPlayerActionUI(handIndex,hitCallback, standCallback, splitCallback, doubleCallback)
    end
end

---Signal the start of a round
---@param deckLocation Vector4 location of physical card deck
---@param deckRotationRPY table rotation of physical card deck in RPY form
function SingleRoundLogic.startRound(deckLocation, deckRotationRPY)
    SingleRoundLogic.dealerCardCount = 0
    SingleRoundLogic.dealerBoardCards = {}
    SingleRoundLogic.playerHands = {{}}
    SingleRoundLogic.activePlayerHandIndex = 1
    SingleRoundLogic.bustedHands = {false,false,false,false}
    SingleRoundLogic.blackjackHandsPaid = {false,false,false,false}
    SingleRoundLogic.doubledHands = {false,false,false,false}
    SingleRoundLogic.dealerHandRevealed = false

    shuffleDeckInternal()
    CardEngine.TriggerDeckShuffle()
    SimpleCasinoChip.spawnChip('chip_hand1_left1_up1', BlackjackMainMenu.currentBet, chipLocationCalc(1,1,1), true)

    Cron.After(2.1, function ()
        dealStartOfRound()
    end)

    Cron.After(4, function()
        if DisplayHandValuesOption[1] then --checks mod settings
            HandCountDisplay.DisplayEnabled(true)
        end
        if isBoardBJ(SingleRoundLogic.playerHands[1]) or isBoardBJ(SingleRoundLogic.dealerBoardCards) then
            ProcessRoundResult(true)
        else
            PlayerAction(1)
        end
    end)
end

return SingleRoundLogic