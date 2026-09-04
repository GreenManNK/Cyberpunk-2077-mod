local Util = require("external/Util")

local UI_ACK_FACT = "marmur_bank_atm_ui_ack"
local UI_OPEN_FACT = "marmur_bank_atm_ui_open"
local UI_COMMAND_FACT = "marmur_bank_atm_ui_command"
local UI_TOKEN_FACT = "marmur_bank_atm_ui_token"
local UI_MODE_FACT = "marmur_bank_atm_ui_mode"
local UI_AMOUNT_FACT = "marmur_bank_atm_ui_amount"

local UI_COMMAND_NONE = 0
local UI_COMMAND_SUBMIT = 1
local UI_COMMAND_CANCEL = 2
local UI_MODE_DEPOSIT = 1
local UI_MODE_WITHDRAW = 2
local UI_ACK_TIMEOUT = 1.50
local ACCOUNT_OPEN_POLL_INTERVAL = 1.00
local MAX_TRANSACTION_AMOUNT = 2000000000
local MAX_BALANCE = 2147483647
local REOPEN_COOLDOWN = 0.25

local keypad = {
    initialized = false,
    active = false,
    bank = nil,
    mode = "deposit",
    sessionCounter = 0,
    session = nil,
    ackElapsed = 0,
    accountPollElapsed = 0,
    closingFromPopup = false,
    reopenBlockedUntil = 0,
}

local function getQuestsSystem()
    local quests = nil
    pcall(function() quests = Game.GetQuestsSystem() end)
    return quests
end

local function getFact(name)
    local value = 0
    local quests = getQuestsSystem()
    if quests == nil then return 0 end
    pcall(function() value = tonumber(quests:GetFactStr(name)) or 0 end)
    return math.floor(value)
end

local function setFact(name, value)
    local quests = getQuestsSystem()
    if quests == nil then return false end
    return pcall(function()
        quests:SetFactStr(name, math.floor(tonumber(value) or 0))
    end) == true
end

local function getPlayer()
    local player = nil
    pcall(function() player = Game.GetPlayer() end)
    return player
end

local function clampBalanceValue(value)
    value = math.floor(tonumber(value) or 0)
    if value < 0 then return 0 end
    if value > MAX_BALANCE then return MAX_BALANCE end
    return value
end

local function consumeCommand()
    local quests = getQuestsSystem()
    if quests == nil then return nil, "Quest system is unavailable." end

    local snapshot = {
        command = UI_COMMAND_NONE,
        token = 0,
        mode = 0,
        amount = 0,
        cleared = false,
    }

    local ok, err = pcall(function()
        snapshot.command = math.floor(tonumber(quests:GetFactStr(UI_COMMAND_FACT)) or 0)
        if snapshot.command == UI_COMMAND_NONE then return end

        snapshot.token = math.floor(tonumber(quests:GetFactStr(UI_TOKEN_FACT)) or 0)
        snapshot.mode = math.floor(tonumber(quests:GetFactStr(UI_MODE_FACT)) or 0)
        snapshot.amount = math.floor(tonumber(quests:GetFactStr(UI_AMOUNT_FACT)) or 0)
        quests:SetFactStr(UI_COMMAND_FACT, UI_COMMAND_NONE)
        snapshot.cleared = math.floor(tonumber(quests:GetFactStr(UI_COMMAND_FACT)) or -1) == UI_COMMAND_NONE
    end)

    if not ok then return nil, tostring(err) end
    if snapshot.command == UI_COMMAND_NONE then return nil, nil end
    if snapshot.cleared ~= true then return nil, "ATM command could not be consumed safely." end
    return snapshot, nil
end

local function safeFormat(value)
    local amount = math.floor(tonumber(value) or 0)
    local ok, formatted = pcall(function() return Util.formatNumber(amount) end)
    if ok and formatted ~= nil then return tostring(formatted) end
    return tostring(amount)
end

local function notify(message)
    message = tostring(message or "")
    if message == "" then return end
    print("[Marmur Bank ATM] " .. message)
    pcall(function() Util.simpleScreenMessage(message) end)
end

function keypad:init(bank)
    self.bank = bank or self.bank
    if self.initialized then return end
    self.initialized = true
    self:resetBridgeFacts()
end

function keypad:isActive()
    return self.active == true
end

function keypad:resetBridgeFacts()
    setFact(UI_ACK_FACT, 0)
    setFact(UI_OPEN_FACT, 0)
    setFact(UI_COMMAND_FACT, UI_COMMAND_NONE)
    setFact(UI_TOKEN_FACT, 0)
    setFact(UI_MODE_FACT, self.mode == "withdraw" and UI_MODE_WITHDRAW or UI_MODE_DEPOSIT)
    setFact(UI_AMOUNT_FACT, 0)
end

function keypad:getBankBalance()
    local amount = 0
    if self.bank and self.bank.getUnifiedBalance then
        pcall(function() amount = math.floor(tonumber(self.bank:getUnifiedBalance()) or 0) end)
    end
    return math.max(amount, 0)
end

function keypad:getWalletBalance()
    local amount = 0
    if self.bank and self.bank.getWalletBalance then
        pcall(function() amount = math.floor(tonumber(self.bank:getWalletBalance()) or 0) end)
    end
    return math.max(amount, 0)
end

function keypad:queueOpenEvent(session)
    local player = getPlayer()
    if player == nil then return false, "ATM session is unavailable." end

    local ok, result = pcall(function()
        return player:MarmurBankATMOpenFromCET(
            clampBalanceValue(self:getBankBalance()),
            clampBalanceValue(self:getWalletBalance()),
            session.id
        )
    end)

    if not ok then return false, tostring(result) end
    if result == false then return false, "Redscript rejected the ATM popup request." end
    return true
end

function keypad:queueResultEvent(sessionId, success, message, clearAmount)
    local player = getPlayer()
    if player == nil then return false, "ATM session is unavailable." end

    local ok, result = pcall(function()
        return player:MarmurBankATMResultFromCET(
            math.floor(tonumber(sessionId) or 0),
            success == true,
            tostring(message or ""),
            clampBalanceValue(self:getBankBalance()),
            clampBalanceValue(self:getWalletBalance()),
            clearAmount == true
        )
    end)

    if not ok then return false, tostring(result) end
    if result == false then return false, "Redscript rejected the ATM result." end
    return true
end

function keypad:queueCloseEvent(sessionId)
    local player = getPlayer()
    if player == nil then return false, "ATM session is unavailable." end

    local ok, result = pcall(function()
        return player:MarmurBankATMCloseFromCET(math.floor(tonumber(sessionId) or 0))
    end)

    if not ok then return false, tostring(result) end
    if result == false then return false, "Redscript rejected the ATM close request." end
    return true
end

function keypad:clearSession()
    self.active = false
    self.session = nil
    self.ackElapsed = 0
    self.accountPollElapsed = 0
    self:resetBridgeFacts()
end

function keypad:markReopenCooldown()
    self.reopenBlockedUntil = math.max(
        tonumber(self.reopenBlockedUntil) or 0,
        os.clock() + REOPEN_COOLDOWN
    )
end

function keypad:show(bank)
    self.bank = bank or self.bank

    if self.active == true then
        return self:refresh()
    end

    if os.clock() < (tonumber(self.reopenBlockedUntil) or 0) then return false end

    if self.bank == nil then return false end
    if self.bank.isAccountOpen then
        local ok, open = pcall(function() return self.bank:isAccountOpen() end)
        if not ok or open ~= true then return false end
    end

    self.sessionCounter = self.sessionCounter + 1
    if self.sessionCounter > MAX_TRANSACTION_AMOUNT then self.sessionCounter = 1 end

    local session = {
        id = self.sessionCounter,
        acknowledged = false,
        processing = false,
    }

    self.session = session
    self.active = true
    self.ackElapsed = 0
    self.accountPollElapsed = 0

    setFact(UI_ACK_FACT, 0)
    setFact(UI_OPEN_FACT, 0)
    setFact(UI_COMMAND_FACT, UI_COMMAND_NONE)
    setFact(UI_TOKEN_FACT, session.id)
    setFact(UI_MODE_FACT, self.mode == "withdraw" and UI_MODE_WITHDRAW or UI_MODE_DEPOSIT)
    setFact(UI_AMOUNT_FACT, 0)

    local queued, err = self:queueOpenEvent(session)
    if not queued then
        self:clearSession()
        notify("Marmur Bank ATM could not open. Verify Codeware/redscript and restart the game. " .. tostring(err or ""))
        return false
    end

    return true
end

function keypad:refresh()
    local session = self.session
    if self.active ~= true or session == nil then return false end
    if session.processing == true or getFact(UI_COMMAND_FACT) ~= UI_COMMAND_NONE then return true end
    local sent, err = self:queueResultEvent(session.id, true, "", false)
    if sent ~= true then
        notify("ATM balance refresh failed; the popup was closed safely. " .. tostring(err or ""))
        self:hide()
        return false
    end
    return true
end

function keypad:hide()
    local session = self.session
    local shouldClosePopup = self.active == true and session ~= nil and self.closingFromPopup ~= true
    local hadSession = self.active == true and session ~= nil
    if self.active == true then
        self.mode = getFact(UI_MODE_FACT) == UI_MODE_WITHDRAW and "withdraw" or "deposit"
    end
    self:clearSession()
    if hadSession then self:markReopenCooldown() end

    if shouldClosePopup then
        self:queueCloseEvent(session.id)
    end
end

function keypad:cancel()
    local bank = self.bank
    if bank and bank.dismissAtmKeypad then
        pcall(function() bank:dismissAtmKeypad() end)
    end
    if bank and bank.hideHub then
        pcall(function() bank:hideHub() end)
    else
        self:hide()
    end
end

function keypad:handleCancelCommand(modeValue)
    local bank = self.bank
    local hadSession = self.active == true and self.session ~= nil
    modeValue = math.floor(tonumber(modeValue) or getFact(UI_MODE_FACT))
    self.mode = modeValue == UI_MODE_WITHDRAW and "withdraw" or "deposit"
    self.closingFromPopup = true
    self:clearSession()
    if hadSession then self:markReopenCooldown() end

    if bank and bank.dismissAtmKeypad then
        pcall(function() bank:dismissAtmKeypad() end)
    end

    if bank and bank.hideHub then
        pcall(function() bank:hideHub() end)
    end

    self.closingFromPopup = false
end

function keypad:sendTransactionResult(session, success, message, clearAmount)
    if self.session ~= session or self.active ~= true then return false end
    local sent, err = self:queueResultEvent(session.id, success, message, clearAmount)
    session.processing = false

    if not sent then
        notify("ATM transaction response failed; the popup was closed safely. " .. tostring(err or ""))
        self:hide()
        return false
    end

    return true
end

function keypad:handleSubmitCommand(session, snapshot)
    if session.processing == true then return end
    session.processing = true

    local amount = math.floor(tonumber(snapshot and snapshot.amount) or 0)
    local modeValue = math.floor(tonumber(snapshot and snapshot.mode) or 0)
    local mode = modeValue == UI_MODE_WITHDRAW and "withdraw" or "deposit"
    self.mode = mode

    if self.bank == nil then
        self:sendTransactionResult(session, false, "Bank service is unavailable.", false)
        self:hide()
        return
    end

    if self.bank.isAccountOpen then
        local checkOk, accountOpen = pcall(function() return self.bank:isAccountOpen() end)
        if not checkOk or accountOpen ~= true then
            self:sendTransactionResult(session, false, "Marmur Bank account is closed.", false)
            self:hide()
            return
        end
    end

    if self.bank.canUseAtmKeypad then
        local checkOk, contextSafe = pcall(function() return self.bank:canUseAtmKeypad() end)
        if not checkOk or contextSafe ~= true then
            self:sendTransactionResult(session, false, "ATM access is no longer available.", false)
            self:hide()
            return
        end
    end

    if amount <= 0 then
        self:sendTransactionResult(session, false, "Enter an amount.", false)
        return
    end

    if amount > MAX_TRANSACTION_AMOUNT then
        self:sendTransactionResult(session, false, "Amount exceeds the ATM limit.", false)
        return
    end

    local bankBalance = self:getBankBalance()
    local walletBalance = self:getWalletBalance()
    local source = mode == "withdraw" and bankBalance or walletBalance
    local destination = mode == "withdraw" and walletBalance or bankBalance
    if amount > source then
        pcall(function() Game.GetAudioSystem():Play("ui_menu_onpress") end)
        self:sendTransactionResult(session, false, "Not enough funds.", false)
        return
    end


    if destination >= MAX_BALANCE or amount > (MAX_BALANCE - destination) then
        pcall(function() Game.GetAudioSystem():Play("ui_menu_onpress") end)
        self:sendTransactionResult(session, false, "Destination balance limit reached.", false)
        return
    end

    local ok = false
    if mode == "withdraw" then
        pcall(function() ok = self.bank:withdrawMoney(amount) == true end)
    else
        pcall(function() ok = self.bank:depositMoney(amount) == true end)
    end

    if ok then
        local verb = mode == "withdraw" and "Withdraw" or "Deposit"
        local toast = verb .. " complete: E$ " .. safeFormat(amount)
        pcall(function() self.bank.lastUnifiedBalance = self.bank:getUnifiedBalance() end)
        pcall(function() Util.simpleScreenMessage(toast) end)
        pcall(function() Game.GetAudioSystem():Play("ui_jingle_quest_update") end)
        self:sendTransactionResult(session, true, verb .. " complete", true)
    else
        pcall(function() Game.GetAudioSystem():Play("ui_menu_onpress") end)
        self:sendTransactionResult(session, false, "Transaction failed.", false)
    end
end

function keypad:pollCommand(session)
    local snapshot, consumeError = consumeCommand()
    if consumeError ~= nil then
        notify("ATM command bridge failed; the popup was closed safely. " .. tostring(consumeError))
        self:hide()
        return
    end
    if snapshot == nil then return end

    if snapshot.token ~= session.id then
        print(string.format(
            "[Marmur Bank ATM] Ignored stale popup command token %d (active %d).",
            snapshot.token,
            session.id
        ))
        return
    end

    if snapshot.mode == UI_MODE_WITHDRAW then
        self.mode = "withdraw"
    elseif snapshot.mode == UI_MODE_DEPOSIT then
        self.mode = "deposit"
    elseif snapshot.command == UI_COMMAND_SUBMIT then
        self:sendTransactionResult(session, false, "ATM command was invalid.", false)
        return
    end

    if snapshot.command == UI_COMMAND_SUBMIT then
        self:handleSubmitCommand(session, snapshot)
    elseif snapshot.command == UI_COMMAND_CANCEL then
        self:handleCancelCommand(snapshot.mode)
    else
        print("[Marmur Bank ATM] Ignored unknown popup command: " .. tostring(snapshot.command))
    end
end

function keypad:update(dt)
    local session = self.session
    if self.active ~= true or session == nil then return end

    local elapsed = tonumber(dt) or 0.05
    if elapsed <= 0 then elapsed = 0.05 end
    if elapsed > 0.25 then elapsed = 0.25 end

    if session.acknowledged ~= true then
        if getFact(UI_ACK_FACT) == session.id then
            session.acknowledged = true
        else
            self.ackElapsed = self.ackElapsed + elapsed
            if self.ackElapsed >= UI_ACK_TIMEOUT then
                notify("Marmur Bank ATM could not reach the popup controller. Verify Codeware/redscript and restart the game.")
                self:hide()
                return
            end
        end
    end

    self.accountPollElapsed = self.accountPollElapsed + elapsed
    if self.accountPollElapsed >= ACCOUNT_OPEN_POLL_INTERVAL then
        self.accountPollElapsed = 0
        local accountOpen = true
        if self.bank and self.bank.isAccountOpen then
            local ok, open = pcall(function() return self.bank:isAccountOpen() end)
            accountOpen = ok and open == true
            if not accountOpen then
                self:hide()
                return
            end
        end
        if accountOpen and self.bank and self.bank.canUseAtmKeypad then
            local ok, usable = pcall(function() return self.bank:canUseAtmKeypad() end)
            if not ok or usable ~= true then
                self:hide()
                return
            end
        end
    end

    if session.acknowledged == true then
        self:pollCommand(session)
    end
end

return keypad
