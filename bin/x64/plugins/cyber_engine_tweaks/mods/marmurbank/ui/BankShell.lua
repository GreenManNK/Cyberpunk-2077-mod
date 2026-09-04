local ink = require("ui/helpers/inkops")
local color = require("ui/helpers/palette")
local relay = require("ui/helpers/inputrelay")
local utils = require("ui/helpers/utils")
local Bank = require("module/Bank")
local Calendar = require("module/Calendar")
local Cron = require("external/Cron")

local shell = {}
local ATLAS = "base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas"

function shell:new(browserController)
    local o = {}
    o.browserController = browserController
    o.activePage = "login"
    o.confirmMode = nil
    o.lastAmount = 0
    o.lastOpeningBonus = 0
    o.lastConfirmationNumber = ""
    o.localSubscribers = {}
    o.contentCanvas = nil
    o.isLoggedIn = false
    o.loginUsernameFilled = false
    o.loginPasswordFilled = false
    o.loginSequenceToken = nil
    o.loginUsernameToken = nil
    o.loginPasswordToken = nil
    o.loginWidgets = {}
    o.loanSignatureFilled = false
    o.loanSignatureToken = nil
    o.loanSignatureWidgets = {}
    o.accountSignatureFilled = false
    o.accountSignatureToken = nil
    o.accountSignatureWidgets = {}
    o.accountClosureBlocked = false
    o.customAmounts = { deposit = "", withdraw = "", autodeposit = "", loanrequest = "", loanpay = "", autoloanpay = "", openaccount = "" }
    o.depositKeypadTarget = "deposit"
    o.autoDepositDraftActive = false
    o.disclosureSelectedIndex = 1
    o.transferErrors = { deposit = "", withdraw = "", autodeposit = "", loanrequest = "", loanpay = "", loans = "", loanapply = "", autoloanpay = "", openaccount = "", closeaccount = "" }
    o.autoLoanSelectedIndex = 1
    o.autoLoanPage = 1
    o.autoLoanPageSize = 2
    o.lastAutoLoanMessage = ""
    o.autoLoanPaymentKeypadOpen = false
    o.loanSelectedOffer = 0
    o.autoDepositIntervalDays = 7
    o.autoDepositIntervalDirty = false
    o.loanPaymentFrequency = "monthly"
    o.loanTermMonths = 36
    o.loanWasPaidOff = false
    o.pendingLoanPayment = nil
    o.pendingAutoLoanPayment = nil
    o.pendingAutoLoanAutoPay = nil
    o.lastPaymentBreakdown = nil
    o.transactionPage = 1
    o.transactionPageSize = 4
    o.transactionSortMode = "recent"
    o.insightsPeriodDays = 30
    o.insightsPeriodOffset = 0
    o.insightsCategoryPage = 1
    o.insightsRefreshToken = nil
    o.insightsSnapshotRevision = ""
    o.homeGraphToken = nil
    o.homeGraphGeneration = 0
    o.disputeTarget = nil
    o.disputeSelectedReason = 0
    o.disputeSubmitError = ""
    o.lastDisputeCase = nil
    o.afterFlagNoticePage = nil
    self.__index = self
    return setmetatable(o, self)
end

function shell:startup()
    self:renderPage("login")
end

function shell:uninitialize()
    self:clearLoginTimers()
    self:clearLoanSignatureTimer()
    self:clearAccountSignatureTimer()
    self:clearInsightsRefreshTimer()
    self:clearHomeGraphTimer()
    for _, sub in ipairs(self.localSubscribers) do
        relay.removeSubscriber(sub)
    end
    self.localSubscribers = {}
    pcall(function()
        if self.browserController and self.browserController.currentPage then
            self.browserController.currentPage:RemoveAllChildren()
        end
    end)
end

function shell:getRootSize()
    local okRoot, root = pcall(function() return self.browserController:GetRootWidget() end)
    if not okRoot or not root then return nil, nil end
    local okSize, size = pcall(function() return root:GetSize() end)
    if not okSize or not size then return nil, nil end
    local w = size.X or size.x or size.width
    local h = size.Y or size.y or size.height
    return w, h
end

function shell:getContentOriginX()
    local w = select(1, self:getRootSize())
    if not w or w <= 0 then return 120 end
    local x = math.floor((w / 2) - 1480)
    if x < 0 then x = 0 end
    return x
end

function shell:getContentOriginY()
    return -85
end

function shell:getPageAddress()
    if self.activePage == "login" then
        return "NETDIR://MARMUR.BANK/LOGIN"
    elseif self.activePage == "signup" then
        return "NETDIR://MARMUR.BANK/OPEN-ACCOUNT"
    elseif self.activePage == "accountfound" then
        return "NETDIR://MARMUR.BANK/ACCOUNT-FOUND"
    elseif self.activePage == "disclosures" then
        return "NETDIR://MARMUR.BANK/DISCLOSURES"
    elseif self.activePage == "closeaccount" then
        return "NETDIR://MARMUR.BANK/CLOSE-ACCOUNT"
    elseif self.activePage == "deposit" then
        return "NETDIR://MARMUR.BANK/DEPOSIT"
    elseif self.activePage == "withdraw" then
        return "NETDIR://MARMUR.BANK/WITHDRAW"
    elseif self.activePage == "transactions" then
        return "NETDIR://MARMUR.BANK/TRANSACTIONS"
    elseif self.activePage == "insights" then
        return "NETDIR://MARMUR.BANK/ANALYTICS"
    elseif self.activePage == "dispute" then
        return "NETDIR://MARMUR.BANK/DISPUTE-CENTER"
    elseif self.activePage == "disputeconfirm" then
        return "NETDIR://MARMUR.BANK/DISPUTE-SUBMITTED"
    elseif self.activePage == "flagnotice" then
        return "NETDIR://MARMUR.BANK/ACCOUNT-NOTICE"
    elseif self.activePage == "loans" or self.activePage == "loanpay" or self.activePage == "loanapply" or self.activePage == "autoloanpay" then
        return "NETDIR://MARMUR.BANK/LOANS"
    elseif self.activePage == "services" then
        return "NETDIR://MARMUR.BANK/ACCOUNT-TIERS"
    elseif self.activePage == "confirm" then
        return "NETDIR://MARMUR.BANK/CONFIRM"
    end
    return "NETDIR://MARMUR.BANK/HOME"
end

function shell:applyAddressBar()
    pcall(function()
        inkTextRef.SetText(self.browserController.addressText, self:getPageAddress())
    end)
end

function shell:clearLoginTimers()
    if self.loginSequenceToken then Cron.Halt(self.loginSequenceToken) end
    if self.loginUsernameToken then Cron.Halt(self.loginUsernameToken) end
    if self.loginPasswordToken then Cron.Halt(self.loginPasswordToken) end
    self.loginSequenceToken = nil
    self.loginUsernameToken = nil
    self.loginPasswordToken = nil
end

function shell:clearLoanSignatureTimer()
    if self.loanSignatureToken then Cron.Halt(self.loanSignatureToken) end
    self.loanSignatureToken = nil
end

function shell:clearAccountSignatureTimer()
    if self.accountSignatureToken then Cron.Halt(self.accountSignatureToken) end
    self.accountSignatureToken = nil
end

function shell:clearInsightsRefreshTimer()
    if self.insightsRefreshToken then Cron.Halt(self.insightsRefreshToken) end
    self.insightsRefreshToken = nil
end

function shell:clearHomeGraphTimer()
    if self.homeGraphToken then Cron.Halt(self.homeGraphToken) end
    self.homeGraphToken = nil
end

function shell:getPlayerSignatureName()
    local name = "V"
    pcall(function()
        local player = GetPlayer and GetPlayer() or nil
        if player and player.GetGender then
            local gender = player:GetGender()
            local value = gender and gender.value or ""
            if value == "Male" then
                name = "Vincent"
            elseif value == "Female" then
                name = "Valerie"
            end
        end
    end)
    return name
end

function shell:logout()
    self:clearLoginTimers()
    self.isLoggedIn = false
    self.loginUsernameFilled = false
    self.loginPasswordFilled = false
    self.loginWidgets = {}
    self.loanSignatureFilled = false
    self.loanSignatureWidgets = {}
    self.accountSignatureFilled = false
    self.accountSignatureWidgets = {}
    self:clearLoanSignatureTimer()
    self:clearAccountSignatureTimer()
    self.confirmMode = nil
    self.lastAmount = 0
    self.lastOpeningBonus = 0
    self.lastConfirmationNumber = ""
    self.autoLoanPaymentKeypadOpen = false
    self.loanWasPaidOff = false
    self.pendingLoanPayment = nil
    self.pendingAutoLoanPayment = nil
    self.pendingAutoLoanAutoPay = nil
    self.lastPaymentBreakdown = nil
    self.disputeTarget = nil
    self.disputeSelectedReason = 0
    self.disputeSubmitError = ""
    self.lastDisputeCase = nil
    self.afterFlagNoticePage = nil
    self.depositKeypadTarget = "deposit"
    self.autoDepositDraftActive = false
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage("login")
end

function shell:renderPage(page)
    local requestedPage = page or self.activePage
    self:clearInsightsRefreshTimer()
    self:clearHomeGraphTimer()
    self.homeGraphGeneration = math.floor(tonumber(self.homeGraphGeneration or 0) or 0) + 1
    if requestedPage == "transactions" and self.activePage ~= "transactions" then
        self.transactionPage = 1
    end
    if requestedPage == "insights" and self.activePage ~= "insights" then
        self.insightsPeriodOffset = 0
        self.insightsCategoryPage = 1
    end
    self.activePage = requestedPage

    if self.isLoggedIn == true and self.activePage == "home" then
        local deepLinkLoans = false
        pcall(function() deepLinkLoans = Bank:consumeExternalLoanDeepLink() == true end)
        if deepLinkLoans then
            pcall(function() self.autoLoanSelectedIndex = Bank:getVanguardAutoLoanDeepLinkIndex() or 1 end)
            self.autoLoanPage = math.max(1, math.ceil((tonumber(self.autoLoanSelectedIndex or 1) or 1) / math.max(tonumber(self.autoLoanPageSize or 2) or 2, 1)))
            self.activePage = "loans"
        end
    end

    local publicPage = self.activePage == "login" or self.activePage == "signup" or self.activePage == "accountfound" or self.activePage == "disclosures"
    local closureConfirm = self.activePage == "confirm" and self.confirmMode == "closeaccount"
    local openingConfirm = self.activePage == "confirm" and self.confirmMode == "openaccount"

    if not publicPage and self.isLoggedIn ~= true and not openingConfirm and not closureConfirm then
        self.activePage = "login"
        publicPage = true
    end

    if self.isLoggedIn == true and not publicPage and not openingConfirm and not closureConfirm then
        local open = false
        pcall(function() open = Bank:isAccountOpen() end)
        if not open then
            self.isLoggedIn = false
            self.activePage = "login"
            publicPage = true
        end
    end

    if self.isLoggedIn == true and not publicPage and not openingConfirm and not closureConfirm and self.activePage ~= "flagnotice" then
        local showFlagNotice = false
        pcall(function() showFlagNotice = Bank:shouldShowDisputeFlagNotice() == true end)
        if showFlagNotice == true then
            self.afterFlagNoticePage = self.activePage
            self.activePage = "flagnotice"
        end
    end

    for _, sub in ipairs(self.localSubscribers) do
        relay.removeSubscriber(sub)
    end
    self.localSubscribers = {}
    self:clearLoginTimers()
    if self.activePage ~= "loans" and self.activePage ~= "loanapply" and self.activePage ~= "autoloanpay" then
        self.loanSignatureFilled = false
    end
    if self.activePage ~= "signup" and self.activePage ~= "closeaccount" then
        self.accountSignatureFilled = false
    end
    if self.activePage ~= "autoloanpay" then
        self.autoLoanPaymentKeypadOpen = false
    end
    if self.activePage ~= "transactions" then
    end
    self:clearLoanSignatureTimer()
    self:clearAccountSignatureTimer()
    self.loginWidgets = {}
    self.loanSignatureWidgets = {}
    self.accountSignatureWidgets = {}

    pcall(function()
        self.browserController.currentPage:RemoveAllChildren()
    end)

    self.contentCanvas = ink.canvas(self:getContentOriginX(), self:getContentOriginY(), inkEAnchor.TopLeft)
    self.contentCanvas:Reparent(self.browserController.currentPage, -1)

    if self.activePage == "login" then
        self:buildLoginPage()
    elseif self.activePage == "signup" then
        self:buildSignupPage()
    elseif self.activePage == "accountfound" then
        self:buildAccountFoundPage()
    elseif self.activePage == "disclosures" then
        if self.isLoggedIn == true then
            self:buildFrame()
            self:buildNavbar()
            self:buildDisclosuresPage(true)
        else
            self:buildDisclosuresPage(false)
        end
    else
        if self.activePage == "home" then
            self:buildHomeFrame()
            self:buildHomePage()
        elseif self.activePage == "flagnotice" then
            self:buildFrame()
            self:buildFlagNoticePage()
        else
            self:buildFrame()
            self:buildNavbar()

            if self.activePage == "deposit" then
                self:buildTransferPage("deposit")
            elseif self.activePage == "withdraw" then
                self:buildTransferPage("withdraw")
            elseif self.activePage == "transactions" then
                self:buildTransactionsPage()
            elseif self.activePage == "insights" then
                self:buildInsightsPage()
            elseif self.activePage == "dispute" then
                self:buildDisputePage()
            elseif self.activePage == "disputeconfirm" then
                self:buildDisputeSubmittedPage()
            elseif self.activePage == "loans" or self.activePage == "loanpay" or self.activePage == "loanapply" or self.activePage == "autoloanpay" then
                self:buildLoansPage()
            elseif self.activePage == "services" then
                self:buildServicesPage()
            elseif self.activePage == "closeaccount" then
                self:buildCloseAccountPage()
            elseif self.activePage == "confirm" then
                self:buildConfirmPage()
            end
        end
    end

    self:applyAddressBar()
end

function shell:addSubscriber(widget, callbacks)
    local entry = {
        eventCatcher = sampleStyleManagerGameController.new(),
        hoverInCallback = callbacks.hoverIn or function() end,
        hoverOutCallback = callbacks.hoverOut or function() end,
        clickCallback = callbacks.click or function() end,
    }
    pcall(function() widget:SetInteractive(true) end)
    widget:RegisterToCallback("OnPress", entry.eventCatcher, "OnState1")
    widget:RegisterToCallback("OnEnter", entry.eventCatcher, "OnStyle1")
    widget:RegisterToCallback("OnLeave", entry.eventCatcher, "OnStyle2")
    table.insert(relay.subscribers, entry)
    table.insert(self.localSubscribers, entry)
    return entry
end

function shell:makePanel(parent, x, y, w, h)
    local panel = ink.canvas(x, y, inkEAnchor.TopLeft)
    panel:SetSize(Vector2.new({ X = w, Y = h }))
    panel:Reparent(parent, -1)

    local bg = ink.image(w/2, h/2, w, h, ATLAS, "cell_bg", color.panel)
    bg.image.useNineSliceScale = true
    bg.image:SetOpacity(0.28)
    bg.pos:Reparent(panel, -1)

    local top = ink.rect(0, 0, w, 2, color.brandRed or color.red)
    top:SetOpacity(0.32)
    top:Reparent(panel, -1)

    local bottom = ink.rect(0, h - 2, w, 2, color.brandWhite or color.white)
    bottom:SetOpacity(0.07)
    bottom:Reparent(panel, -1)

    return panel
end

function shell:createButton(parent, label, x, y, w, h, callback, opts)
    opts = opts or {}
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local baseColor = opts.textColor or opts.fgColor or color.white
    local hoverColor = opts.hoverColor or color.brandRedBright or color.red
    local activeColor = opts.activeColor or opts.fgColor or color.brandRedBright or color.red
    local active = opts.active == true
    local disabled = callback == nil
    local labelColor = disabled and (opts.textColor or color.dim) or (active and activeColor or baseColor)

    local readablePage = ink.getFontScale and ink.getFontScale() > 1.15
    local textY = readablePage and (h / 2 - 5) or (h / 2 - 3)
    local textW = readablePage and (w - 12) or w
    local textH = readablePage and (h + 24) or (h + 16)
    local text = ink.text(label, w / 2, textY, opts.fontSize or 40, labelColor)
    text:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    text:SetSize(Vector2.new({ X = textW, Y = textH }))
    text:Reparent(holder, -1)

    local underlineW = math.max(math.floor(w * 0.34), 72)
    if underlineW > w - 28 then underlineW = w - 28 end
    local underline = ink.rect((w - underlineW) / 2, h - 10, underlineW, 3, active and activeColor or hoverColor)
    underline:SetOpacity(active and 0.84 or 0.0)
    underline:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if callback and not disabled then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                text:SetTintColor(hoverColor)
                underline:SetTintColor(hoverColor)
                underline:SetOpacity(0.92)
            end,
            hoverOut = function()
                text:SetTintColor(active and activeColor or baseColor)
                underline:SetTintColor(active and activeColor or hoverColor)
                underline:SetOpacity(active and 0.84 or 0.0)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    else
        text:SetTintColor(color.dim)
        underline:SetOpacity(0.0)
    end

    return holder
end

function shell:drawKV(parent, label, value, x, y, valueColor, width, valueFontSize, labelFontSize)
    width = math.floor(tonumber(width) or 420)
    valueFontSize = math.floor(tonumber(valueFontSize) or 44)
    labelFontSize = math.floor(tonumber(labelFontSize) or 30)
    local readablePage = ink.getFontScale and ink.getFontScale() > 1.15
    local labelHeight = labelFontSize + (readablePage and 16 or 8)
    local valueOffset = labelFontSize + (readablePage and 10 or 6)
    local valueHeight = math.max(valueFontSize + (readablePage and 38 or 30), readablePage and 78 or 70)
    local lab = ink.text(label, x, y, labelFontSize, color.dim)
    lab:SetSize(Vector2.new({ X = width, Y = labelHeight }))
    lab:Reparent(parent, -1)
    local val = ink.text(value, x, y + valueOffset, valueFontSize, valueColor or color.white)
    val:SetWrapping(true)
    val:SetSize(Vector2.new({ X = width, Y = valueHeight }))
    val:Reparent(parent, -1)
end

function shell:drawHeaderStat(parent, label, value, x, y, valueColor, width, labelFontSize, valueFontSize)
    width = math.floor(tonumber(width) or 420)
    labelFontSize = math.floor(tonumber(labelFontSize) or 26)
    valueFontSize = math.floor(tonumber(valueFontSize) or 38)
    local readablePage = ink.getFontScale and ink.getFontScale() > 1.15
    local labelHeight = labelFontSize + (readablePage and 16 or 10)
    local valueOffset = labelFontSize + (readablePage and 10 or 8)
    local valueHeight = valueFontSize + (readablePage and 36 or 28)

    local lab = ink.text(label, x, y, labelFontSize, color.dim)
    lab:SetSize(Vector2.new({ X = width, Y = labelHeight }))
    lab:Reparent(parent, -1)

    local val = ink.text(value, x, y + valueOffset, valueFontSize, valueColor or color.white)
    val:SetWrapping(true)
    val:SetSize(Vector2.new({ X = width, Y = valueHeight }))
    val:Reparent(parent, -1)
end

function shell:drawPolishedRow(parent, label, value, y, opts)
    opts = opts or {}
    local x = math.floor(tonumber(opts.x) or 28)
    local width = math.floor(tonumber(opts.width) or 1000)
    local labelWidth = math.floor(tonumber(opts.labelWidth) or math.min(520, width * 0.46))
    local rowHeight = math.floor(tonumber(opts.rowHeight) or 54)
    local labelFont = math.floor(tonumber(opts.labelFontSize) or 25)
    local valueFont = math.floor(tonumber(opts.valueFontSize) or 29)

    local labelWidget = ink.text(label, x, y, labelFont, opts.labelColor or color.dim)
    labelWidget:SetWrapping(true)
    labelWidget:SetSize(Vector2.new({ X = labelWidth, Y = rowHeight - 8 }))
    labelWidget:Reparent(parent, -1)

    local valueWidget = ink.text(value, x + width, y - 2, valueFont, opts.valueColor or color.white)
    valueWidget:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    valueWidget:SetWrapping(true)
    valueWidget:SetSize(Vector2.new({ X = math.max(width - labelWidth - 24, 260), Y = rowHeight }))
    valueWidget:Reparent(parent, -1)

    if opts.drawLine ~= false then
        local divider = ink.rect(x, y + rowHeight - 6, width, 1, color.brandWhite or color.white)
        divider:SetOpacity(tonumber(opts.lineOpacity) or 0.10)
        divider:Reparent(parent, -1)
    end

    return valueWidget
end

function shell:formatLoanClockTime(stamp)
    local value = math.floor(tonumber(stamp) or 0)
    if value <= 0 then return "Not recorded" end
    return Calendar.formatMinuteStamp(value, Calendar.getContext(), true)
end

function shell:formatLoanDueCountdown(loan, data)
    local nextDue = math.floor(tonumber((loan and loan.nextDueDay) or 0) or 0)
    if nextDue <= 0 then
        return "Not scheduled"
    end
    local today = math.floor(tonumber((data and data.currentDay) or 0) or 0)
    if today <= 0 then
        pcall(function() today = Bank:_getCurrentGameDay() or 0 end)
        today = math.floor(tonumber(today) or 0)
    end
    local dueDate = Calendar.formatEngineDay(nextDue, Calendar.getContext(), true)
    local remaining = nextDue - today
    if remaining <= 0 then
        return dueDate .. " • DUE NOW"
    end
    if remaining == 1 then
        return dueDate .. " • Tomorrow"
    end
    return dueDate .. " • in " .. tostring(remaining) .. " days"
end


function shell:calculatePrivateClientService(balance, totalFeesPaid, loyalty)
    balance = math.max(math.floor(tonumber(balance) or 0), 0)
    local profile = type(loyalty) == "table" and loyalty or nil
    if not profile then
        pcall(function()
            if Bank and Bank.getLoyaltySummary then profile = Bank:getLoyaltySummary(balance) end
        end)
    end

    local tierIndex = profile and math.floor(tonumber(profile.activeTier) or 0) or nil
    if tierIndex == nil then
        if balance >= 1000000 then tierIndex = 4
        elseif balance >= 250000 then tierIndex = 3
        elseif balance >= 100000 then tierIndex = 2
        elseif balance >= 25000 then tierIndex = 1
        else tierIndex = 0 end
    end
    if tierIndex < 0 then tierIndex = 0 end
    if tierIndex > 4 then tierIndex = 4 end

    local tiers = {
        [0] = { tier = "Standard", cashbackPercent = 1, cashbackBp = 100, interestBp = 1, basis = "1% cashback. Build a seven-day savings history to advance." },
        [1] = { tier = "Preferred", cashbackPercent = 2, cashbackBp = 200, interestBp = 2, basis = "2% cashback. Earned through a qualifying seven-day average." },
        [2] = { tier = "Premier", cashbackPercent = 3, cashbackBp = 300, interestBp = 3, basis = "3% cashback. Earned relationship benefits remain protected." },
        [3] = { tier = "Private Client", cashbackPercent = 4, cashbackBp = 400, interestBp = 4, basis = "4% cashback. Private Client status follows the loyalty ledger." },
        [4] = { tier = "Obsidian Client", cashbackPercent = 5, cashbackBp = 500, interestBp = 5, basis = "5% cashback. Marmur's highest earned relationship level." },
    }
    local selected = tiers[tierIndex] or tiers[0]
    return {
        tier = tostring((profile and profile.tier) or selected.tier),
        tierIndex = tierIndex,
        fee = 0,
        cashbackPercent = selected.cashbackPercent,
        cashbackBp = selected.cashbackBp,
        interestBp = math.floor(tonumber((profile and profile.interestBp) or selected.interestBp) or selected.interestBp),
        cycle = "loyalty reward",
        basis = selected.basis,
        totalFeesPaid = math.floor(tonumber(totalFeesPaid) or 0),
        loyalty = profile,
    }
end

function shell:getHomeCustodyBasisDisplay(value)
    local text = tostring(value or "1% cashback. Build a seven-day savings history to advance.")
    if #text > 34 then
        local splitAt = 34
        for i = math.min(#text, 34), 18, -1 do
            if text:sub(i, i) == " " then
                splitAt = i
                break
            end
        end
        return text:sub(1, splitAt - 1) .. "\n" .. text:sub(splitAt + 1)
    end
    return text
end

function shell:getAccountTierRows()
    return {
        { index = 0, min = 0, floor = 0, range = "Default", name = "Standard", cashback = "1%", rateBp = 100, interestBp = 1, note = "Build 7-day history" },
        { index = 1, min = 25000, floor = 18750, range = "E$25K+", name = "Preferred", cashback = "2%", rateBp = 200, interestBp = 2, note = "Protect at E$18.75K avg" },
        { index = 2, min = 100000, floor = 75000, range = "E$100K+", name = "Premier", cashback = "3%", rateBp = 300, interestBp = 3, note = "Protect at E$75K avg" },
        { index = 3, min = 250000, floor = 187500, range = "E$250K+", name = "Private Client", cashback = "4%", rateBp = 400, interestBp = 4, note = "Protect at E$187.5K avg" },
        { index = 4, min = 1000000, floor = 750000, range = "E$1M+", name = "Obsidian Client", cashback = "5%", rateBp = 500, interestBp = 5, note = "Protect at E$750K avg" },
    }
end

function shell:getNextAccountTier(averageBalance, activeTier)
    local amount = math.max(math.floor(tonumber(averageBalance) or 0), 0)
    local rows = self:getAccountTierRows()
    local current = tonumber(activeTier)
    if current == nil then
        current = 0
        for _, tier in ipairs(rows) do
            if amount >= (tonumber(tier.min) or 0) then current = tonumber(tier.index) or current end
        end
    end
    current = math.max(0, math.min(math.floor(current), 4))
    local nextTier = rows[current + 2]
    if not nextTier then return nil, 0 end
    return nextTier, math.max((tonumber(nextTier.min) or 0) - amount, 0)
end

function shell:formatCashbackRate(rateBp, fallbackPercent)
    local bp = tonumber(rateBp) or 0
    if bp <= 0 then
        local pct = tonumber(fallbackPercent) or 0
        return string.format("%.2f%%", pct)
    end
    return string.format("%.2f%%", bp / 100.0)
end

function shell:getManagedInterestPercent(balance)
    local bp = 1
    pcall(function()
        if Bank and Bank.getManagedInterestBasisPoints then
            bp = tonumber(Bank:getManagedInterestBasisPoints(balance)) or bp
        end
    end)
    return bp / 100.0
end

function shell:getMinimumOpeningDeposit()
    local minDeposit = 250
    pcall(function()
        if Bank and Bank.getMinimumOpeningDeposit then
            minDeposit = tonumber(Bank:getMinimumOpeningDeposit()) or minDeposit
        end
    end)
    return math.floor(minDeposit)
end

function shell:getOpeningIncentiveAmount(amount)
    amount = math.floor(tonumber(amount) or 0)
    local bonus = 0
    pcall(function()
        if Bank and Bank.getOpeningIncentiveAmount then
            bonus = tonumber(Bank:getOpeningIncentiveAmount(amount)) or 0
        end
    end)
    if bonus <= 0 then
        local minDeposit = self:getMinimumOpeningDeposit()
        if amount >= 50000000 then bonus = 1500000
        elseif amount >= 10000000 then bonus = 500000
        elseif amount >= 1000000 then bonus = 100000
        elseif amount >= 500000 then bonus = 50000
        elseif amount >= 100000 then bonus = 20000
        elseif amount >= 25000 then bonus = 7500
        elseif amount >= 5000 then bonus = 3000
        elseif amount >= 1000 then bonus = 1500
        elseif amount >= minDeposit then bonus = 500 end
    end
    return math.floor(bonus)
end

function shell:getOpeningIncentiveTierLabel(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount >= 50000000 then return "Executive Welcome" end
    if amount >= 10000000 then return "Obsidian Welcome" end
    if amount >= 1000000 then return "Private Welcome" end
    if amount >= 500000 then return "Preferred Plus" end
    if amount >= 100000 then return "Preferred" end
    if amount >= 25000 then return "Starter Plus" end
    if amount >= 5000 then return "Starter" end
    if amount >= 1000 then return "Intro Plus" end
    if amount >= self:getMinimumOpeningDeposit() then return "Intro Welcome" end
    if amount > 0 then return "Minimum E$250 required" end
    return "Pending deposit"
end

function shell:getProjectedOpenAccountData(data)
    local snapshot = data or self:getBankData()
    local amount = self:getCustomAmount("openaccount")
    local bonus = self:getOpeningIncentiveAmount(amount)
    local openingFee = 0
    local projectedSavings = math.floor((tonumber(snapshot.bank) or 0) + (tonumber(amount) or 0) - openingFee)
    if projectedSavings < 0 then projectedSavings = 0 end

    local qualificationTarget = "Standard"
    pcall(function()
        if Bank and Bank.getPotentialAccountLevelName then
            qualificationTarget = tostring(Bank:getPotentialAccountLevelName(projectedSavings) or qualificationTarget)
        end
    end)
    local startingLoyalty = { activeTier = 0, tier = "Standard", interestBp = 1, cashbackBp = 100 }
    local projectedService = self:calculatePrivateClientService(projectedSavings, 0, startingLoyalty)
    local projectedInterest = (tonumber(projectedService.interestBp) or 1) / 100.0
    local tax = tonumber(snapshot.yieldTax) or 15.0
    return {
        amount = math.floor(tonumber(amount) or 0),
        bonus = bonus,
        openingFee = openingFee,
        bonusTier = self:getOpeningIncentiveTierLabel(amount),
        projectedSavings = projectedSavings,
        projectedChecking = math.max(math.floor((tonumber(snapshot.wallet) or 0) - (tonumber(amount) or 0)), 0),
        service = projectedService,
        qualificationTarget = qualificationTarget,
        interest = projectedInterest,
        netYield = projectedInterest * ((100.0 - tax) / 100.0),
        yieldTax = tax,
    }
end

function shell:getBankData()
    local wallet = 0
    local bank = 0
    pcall(function() wallet = Bank:getWalletBalance() or 0 end)
    pcall(function() bank = Bank:getUnifiedBalance() or 0 end)

    local loyalty = {
        activeTier = 0,
        tier = "Standard",
        currentBalance = bank,
        averageBalance = bank,
        minimumBalance = bank,
        sampleCount = 0,
        daysTracked = 0,
        daysUntilReview = 7,
        windowDays = 7,
        historyReady = false,
        retentionPercent = 75,
        retentionFloor = 0,
        graceDays = 3,
        atRisk = false,
        graceDaysRemaining = 0,
        nextTierName = "Preferred",
        nextThreshold = 25000,
        nextNeeded = math.max(25000 - bank, 0),
        cashbackBp = 100,
        interestBp = 1,
        statusCode = "building_history",
        statusLabel = "Building history",
        statusText = "Build a seven-day savings history to earn the next account level.",
    }
    pcall(function()
        local profile = Bank:getLoyaltySummary(bank)
        if type(profile) == "table" then loyalty = profile end
    end)

    local interest = (tonumber(loyalty.interestBp) or 1) / 100.0
    local yieldTax = 15.0
    local streetCred = 0
    local loan = nil
    local currentDay = 0
    local totalPrivateFeesPaid = 0
    local accountOpen = false
    local system = nil
    pcall(function() system = Bank:getUnifiedSystem() end)
    if system then
        pcall(function()
            local bp = tonumber(system:GetCurrentInterestBasisPoints()) or 0
            if bp > 0 then interest = bp / 100.0 end
        end)
        pcall(function() yieldTax = tonumber(system:GetInterestTaxPercent()) or yieldTax end)
        pcall(function() totalPrivateFeesPaid = tonumber(system:GetTotalPrivateClientFeesPaid()) or 0 end)
    end
    local service = self:calculatePrivateClientService(bank, totalPrivateFeesPaid, loyalty)
    local accountNumber = "MB-2077-00000000"
    local incentiveStatus = "None"
    local pendingIncentive = 0
    local paidIncentive = 0
    local chargeback = 0
    local cashback = { destination = "checking", destinationLabel = "Checking", rateBp = 100, ratePercent = 1.00, tier = "Standard", loyalty = loyalty, totalEarned = 0, totalSpend = 0, pendingEarned = 0, pendingSpend = 0, nextPayoutLabel = "Not scheduled", daysLeftLabel = "Not scheduled", payoutTimeLabel = "3:00 PM", lastEarned = 0, lastSpend = 0, lastRateBp = 0, lastDestination = "Checking" }
    pcall(function() accountOpen = Bank:isAccountOpen() == true end)
    pcall(function() accountNumber = Bank:getAccountNumberText() or accountNumber end)
    pcall(function() incentiveStatus = Bank:getOpeningIncentiveStatusText() or incentiveStatus end)
    pcall(function() pendingIncentive = tonumber(Bank:getPendingOpeningIncentiveAmount()) or 0 end)
    pcall(function() paidIncentive = tonumber(Bank:getPaidOpeningIncentiveAmount()) or 0 end)
    pcall(function() chargeback = tonumber(Bank:getOpeningIncentiveChargebackAmount()) or 0 end)
    pcall(function() streetCred = Bank:getStreetCredLevel() or 0 end)
    pcall(function() currentDay = Bank:_getCurrentGameDay() or 0 end)
    pcall(function()
        local cb = Bank:getCashbackSummary()
        if type(cb) == "table" then cashback = cb end
    end)
    if type(cashback.loyalty) == "table" then loyalty = cashback.loyalty end
    pcall(function() loan = Bank:getLoanData() end)
    if not loan then loan = { active = false, balanceDue = 0, installment = 0, nextDueDay = 0 } end
    local autoLoans = {}
    pcall(function() autoLoans = Bank:getAutoLoans() or {} end)
    return {
        wallet = wallet,
        bank = bank,
        total = wallet + bank,
        interest = interest,
        yieldTax = yieldTax,
        netYield = interest * ((100.0 - yieldTax) / 100.0),
        goal = 2000000,
        accountNumber = accountNumber,
        accountType = accountOpen and "Marmur Savings" or "No Active Account",
        incentiveStatus = incentiveStatus,
        pendingIncentive = pendingIncentive,
        paidIncentive = paidIncentive,
        closingChargeback = chargeback,
        accountOpen = accountOpen,
        streetCred = streetCred,
        currentDay = currentDay,
        loan = loan,
        autoLoans = autoLoans,
        service = service,
        cashback = cashback,
        loyalty = loyalty,
    }
end

function shell:normalizeAmountString(raw)
    local cleaned = tostring(raw or ""):gsub("%D", "")
    if cleaned == "" then
        return ""
    end
    cleaned = cleaned:gsub("^0+", "")
    if cleaned == "" then
        cleaned = "0"
    end
    if #cleaned > 12 then
        cleaned = cleaned:sub(1, 12)
    end
    return cleaned
end

function shell:getCustomAmountString(mode)
    self.customAmounts = self.customAmounts or {}
    return self.customAmounts[mode] or ""
end

function shell:setCustomAmountString(mode, value)
    self.customAmounts = self.customAmounts or {}
    self.customAmounts[mode] = self:normalizeAmountString(value)
end

function shell:getCustomAmount(mode)
    local raw = self:getCustomAmountString(mode)
    if raw == "" then
        return 0
    end
    return tonumber(raw) or 0
end

function shell:getCustomAmountLabel(mode)
    local amount = self:getCustomAmount(mode)
    return "E$ " .. utils.formatNumber(amount)
end

function shell:clearTransferError(mode)
    self.transferErrors = self.transferErrors or {}
    self.transferErrors[mode] = ""
end

function shell:setTransferError(mode, message)
    self.transferErrors = self.transferErrors or {}
    self.transferErrors[mode] = message or ""
end

function shell:getTransferError(mode)
    self.transferErrors = self.transferErrors or {}
    return self.transferErrors[mode] or ""
end

function shell:getAmountRenderPage(mode)
    if mode == "loanrequest" then
        return self.activePage == "loanapply" and "loanapply" or "loans"
    end
    if mode == "openaccount" then return "signup" end
    if mode == "autoloanpay" then return "autoloanpay" end
    if mode == "autodeposit" then return "deposit" end
    return mode
end

function shell:getSavedAutoDepositAmount()
    local auto = nil
    pcall(function() auto = Bank:getAutoDepositSettings() end)
    if type(auto) == "table" and auto.active == true then
        return math.max(math.floor(tonumber(auto.amount) or 0), 0)
    end
    return 0
end

function shell:appendCustomAmount(mode, digits)
    self:clearTransferError(mode)
    if mode == "autodeposit" then
        self.depositKeypadTarget = "autodeposit"
        if self.autoDepositDraftActive ~= true then
            self:setCustomAmountString("autodeposit", "")
            self.autoDepositDraftActive = true
        end
    elseif mode == "deposit" then
        self.depositKeypadTarget = "deposit"
    end
    local current = self:getCustomAmountString(mode)
    self:setCustomAmountString(mode, current .. tostring(digits or ""))
    self:renderPage(self:getAmountRenderPage(mode))
end

function shell:backspaceCustomAmount(mode)
    self:clearTransferError(mode)
    if mode == "autodeposit" then
        self.depositKeypadTarget = "autodeposit"
        if self.autoDepositDraftActive ~= true then
            self:setCustomAmountString("autodeposit", tostring(self:getSavedAutoDepositAmount()))
            self.autoDepositDraftActive = true
        end
    elseif mode == "deposit" then
        self.depositKeypadTarget = "deposit"
    end
    local current = self:getCustomAmountString(mode)
    self:setCustomAmountString(mode, current:sub(1, math.max(#current - 1, 0)))
    self:renderPage(self:getAmountRenderPage(mode))
end

function shell:clearCustomAmount(mode)
    self:clearTransferError(mode)
    if mode == "autodeposit" then
        self.depositKeypadTarget = "autodeposit"
        self.autoDepositDraftActive = true
    elseif mode == "deposit" then
        self.depositKeypadTarget = "deposit"
    end
    self:setCustomAmountString(mode, "")
    self:renderPage(self:getAmountRenderPage(mode))
end

function shell:getTransferSourceAmount(mode, data)
    local snapshot = data or self:getBankData()
    if mode == "deposit" or mode == "autodeposit" or mode == "openaccount" then
        return snapshot.wallet or 0
    elseif mode == "loanpay" then
        local due = 0
        if snapshot.loan then due = self:getLoanEarlyPayoffAmountFromData(snapshot.loan) end
        return math.min(snapshot.wallet or 0, due)
    elseif mode == "autoloanpay" then
        local due = 0
        local autoLoans = snapshot.autoLoans or {}
        local selected = self:getSelectedAutoLoan(autoLoans)
        if selected then due = math.max(math.floor(tonumber(selected.balanceDue) or 0), 0) end
        return math.min(snapshot.wallet or 0, due)
    end
    return snapshot.bank or 0
end

function shell:fillMaxCustomAmount(mode, data)
    self:clearTransferError(mode)
    if mode == "autodeposit" then
        self.depositKeypadTarget = "autodeposit"
        self.autoDepositDraftActive = true
    elseif mode == "deposit" then
        self.depositKeypadTarget = "deposit"
    end
    self:setCustomAmountString(mode, tostring(math.floor(self:getTransferSourceAmount(mode, data))))
    self:renderPage(self:getAmountRenderPage(mode))
end

function shell:submitCustomAmount(mode, data)
    local amount = self:getCustomAmount(mode)
    local sourceAmount = self:getTransferSourceAmount(mode, data)

    if mode == "openaccount" then
        self:submitOpenAccount(amount, data)
        return
    end

    if mode == "loanpay" then
        self:submitLoanPayment(amount, data)
        return
    end

    if mode == "loanrequest" then
        self:submitLoanRequest(amount, data)
        return
    end

    if mode == "autoloanpay" then
        self:submitAutoLoanCustomPayment(amount, data)
        return
    end

    if amount <= 0 then
        self:setTransferError(mode, "Enter an amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(mode)
        return
    end

    if amount > sourceAmount then
        self:setTransferError(mode, "Amount exceeds available funds.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(mode)
        return
    end

    self:clearTransferError(mode)
    self:performTransfer(mode, amount)
end


function shell:createLoginField(parent, x, y, w, h, kind, fillText)
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local border = ink.rect(0, 0, w, h, color.dim)
    border:Reparent(holder, -1)
    local fill = ink.rect(3, 3, w - 6, h - 6, color.brandPanel2)
    fill:Reparent(holder, -1)

    local text = ink.text("", w / 2, h / 2 - 10, 68, color.white)
    text:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    text:Reparent(holder, -1)

    local tokenKey = kind == "username" and "loginUsernameToken" or "loginPasswordToken"
    local flagKey = kind == "username" and "loginUsernameFilled" or "loginPasswordFilled"

    self:addSubscriber(fill, {
        hoverIn = function()
            border:SetTintColor(color.white)
        end,
        hoverOut = function()
            border:SetTintColor(color.dim)
        end,
        click = function()
            if self[tokenKey] or self[flagKey] then return end
            local chars = {}
            for i = 1, #fillText do
                chars[i] = fillText:sub(i, i)
            end
            self[tokenKey] = Cron.Every(0.075, function(timer)
                local tick = timer.tick or 1
                if tick <= #chars then
                    text:SetText(text:GetText() .. chars[tick])
                    timer.tick = tick + 1
                else
                    Cron.Halt(timer)
                    self[tokenKey] = nil
                    self[flagKey] = true
                    self:updateLoginButtonState()
                end
            end, { tick = 1 })
        end,
    })

    return { canvas = holder, border = border, fill = fill, text = text }
end

function shell:updateLoginButtonState()
    if not self.loginWidgets.loginBorder or not self.loginWidgets.loginFill then return end
    if self.loginUsernameFilled and self.loginPasswordFilled then
        self.loginWidgets.loginBorder:SetTintColor(color.brandRedBright or color.red)
        self.loginWidgets.loginBorder:SetOpacity(0.84)
        self.loginWidgets.loginLabel:SetTintColor(color.white)
    else
        self.loginWidgets.loginBorder:SetTintColor(color.gold)
        self.loginWidgets.loginBorder:SetOpacity(0.0)
        self.loginWidgets.loginLabel:SetTintColor(color.dim)
    end
end

function shell:startLoginSequence()
    if self.loginSequenceToken or not self.loginUsernameFilled or not self.loginPasswordFilled then return end
    local accountOpen = false
    pcall(function() accountOpen = Bank:isAccountOpen() == true end)
    if not accountOpen then
        if self.loginWidgets and self.loginWidgets.fluff then
            self.loginWidgets.fluff:SetText(ink.translate("No active Marmur account found. Open a new account to continue."))
            self.loginWidgets.fluff:SetTintColor(color.gold)
        end
        utils.playSound("ui_menu_onpress", 1)
        return
    end

    local lines = {
        "Validating Marmur credentials...",
        "Account holder confirmed.",
        "Netwatch relay secured.",
        "Opening account console...",
    }

    self.loginWidgets.fluff:SetText("")
    self.loginSequenceToken = Cron.Every(0.085, function(timer)
        local tick = timer.tick or 1
        if tick <= #lines then
            local current = self.loginWidgets.fluff:GetText() or ""
            if current == "" then
                self.loginWidgets.fluff:SetText(ink.translate(lines[tick]))
            else
                self.loginWidgets.fluff:SetText(ink.translate(current .. "\n" .. lines[tick]))
            end
            timer.tick = tick + 1
        else
            Cron.Halt(timer)
            self.loginSequenceToken = nil
            self.isLoggedIn = true
            local deepLinkLoans = false
            pcall(function() deepLinkLoans = Bank:consumeExternalLoanDeepLink() == true end)
            if deepLinkLoans then
                pcall(function() self.autoLoanSelectedIndex = Bank:getVanguardAutoLoanDeepLinkIndex() or 1 end)
            self.autoLoanPage = math.max(1, math.ceil((tonumber(self.autoLoanSelectedIndex or 1) or 1) / math.max(tonumber(self.autoLoanPageSize or 2) or 2, 1)))
                self:renderPage("loans")
            else
                self:renderPage("home")
            end
        end
    end, { tick = 1 })
end

function shell:buildLoginPage()
    self.loginUsernameFilled = false
    self.loginPasswordFilled = false

    local page = ink.canvas(0, 180, inkEAnchor.TopLeft)
    page:SetSize(Vector2.new({ X = 2960, Y = 1180 }))
    page:Reparent(self.contentCanvas, -1)

    local root = ink.rect(0, 0, 2960, 1180, color.panel)
    root:SetOpacity(0.98)
    root:Reparent(page, -1)

    local topLogo = ink.text("MARMUR BANK", 160, 56, 76, color.gold)
    topLogo:SetSize(Vector2.new({ X = 820, Y = 92 }))
    topLogo:Reparent(page, -1)
    local topSub = ink.text("Private banking portal", 164, 132, 30, color.dim)
    topSub:SetSize(Vector2.new({ X = 760, Y = 40 }))
    topSub:Reparent(page, -1)

    local safety = ink.text("Protected by Netwatch encrypted banking relay", 1820, 78, 28, color.dim)
    safety:SetSize(Vector2.new({ X = 940, Y = 44 }))
    safety:Reparent(page, -1)
    local safetyLine = ink.rect(1818, 126, 740, 4, color.cyan)
    safetyLine:SetOpacity(0.42)
    safetyLine:Reparent(page, -1)

    local card = self:makePanel(page, 160, 220, 960, 840)
    local greeting = ink.text("Good afternoon", 54, 44, 68, color.white)
    greeting:SetSize(Vector2.new({ X = 820, Y = 84 }))
    greeting:Reparent(card, -1)
    local greetingSub = ink.text("Sign on to manage your accounts.", 58, 128, 34, color.dim)
    greetingSub:SetSize(Vector2.new({ X = 820, Y = 46 }))
    greetingSub:Reparent(card, -1)

    local usernameLabel = ink.text("Username", 58, 220, 34, color.dim)
    usernameLabel:SetSize(Vector2.new({ X = 680, Y = 44 }))
    usernameLabel:Reparent(card, -1)
    local username = "V"
    pcall(function()
        local player = Game.GetPlayer()
        if player and player.GetGender and player:GetGender().value == "Male" then username = "Vincent" else username = "Valerie" end
    end)
    self.loginWidgets.username = self:createLoginField(card, 58, 264, 820, 86, "username", username)

    local passwordLabel = ink.text("Password", 58, 384, 34, color.dim)
    passwordLabel:SetSize(Vector2.new({ X = 500, Y = 44 }))
    passwordLabel:Reparent(card, -1)
    self.loginWidgets.password = self:createLoginField(card, 58, 428, 820, 86, "password", "************")
    local loginHolder = ink.canvas(58, 548, inkEAnchor.TopLeft)
    loginHolder:SetSize(Vector2.new({ X = 820, Y = 92 }))
    loginHolder:Reparent(card, -1)
    local loginLabel = ink.text("Sign In", 410, 44, 48, color.dim)
    loginLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    loginLabel:SetSize(Vector2.new({ X = 800, Y = 76 }))
    loginLabel:Reparent(loginHolder, -1)
    local loginUnderline = ink.rect(210, 80, 400, 4, color.brandRedBright or color.red)
    loginUnderline:SetOpacity(0.0)
    loginUnderline:Reparent(loginHolder, -1)
    local loginHotspot = ink.rect(0, 0, 820, 92, color.white)
    loginHotspot:SetOpacity(0.01)
    loginHotspot:Reparent(loginHolder, -1)
    self.loginWidgets.loginBorder = loginUnderline
    self.loginWidgets.loginFill = loginHotspot
    self.loginWidgets.loginLabel = loginLabel
    self:addSubscriber(loginHotspot, {
        hoverIn = function()
            loginLabel:SetTintColor(color.brandRedBright or color.red)
            loginUnderline:SetTintColor(color.brandRedBright or color.red)
            loginUnderline:SetOpacity(0.92)
        end,
        hoverOut = function() self:updateLoginButtonState() end,
        click = function() self:startLoginSequence() end,
    })
    self:updateLoginButtonState()

    local linksBg = ink.rect(0, 742, 960, 98, color.white)
    linksBg:SetOpacity(0.035)
    linksBg:Reparent(card, -1)
    local link1 = ink.text("Forgot username or password?", 58, 762, 28, color.white)
    link1:SetSize(Vector2.new({ X = 680, Y = 38 }))
    link1:Reparent(card, -1)
    local link2 = ink.text("Privacy, Legal, and Account Disclosures", 58, 802, 26, color.dim)
    link2:SetSize(Vector2.new({ X = 760, Y = 36 }))
    link2:Reparent(card, -1)
    local disclosureHotspot = ink.rect(54, 796, 770, 40, color.white)
    disclosureHotspot:SetOpacity(0.01)
    disclosureHotspot:Reparent(card, -1)
    self:addSubscriber(disclosureHotspot, {
        hoverIn = function() link2:SetTintColor(color.cyan) end,
        hoverOut = function() link2:SetTintColor(color.dim) end,
        click = function() self:renderPage("disclosures") end,
    })

    self.loginWidgets.fluff = ink.text("", 58, 668, 25, color.cyan)
    self.loginWidgets.fluff:SetWrapping(true)
    self.loginWidgets.fluff:SetSize(Vector2.new({ X = 820, Y = 36 }))
    self.loginWidgets.fluff:Reparent(card, -1)

    local promo = ink.canvas(1260, 240, inkEAnchor.TopLeft)
    promo:SetSize(Vector2.new({ X = 1480, Y = 760 }))
    promo:Reparent(page, -1)

    local promoRule = ink.rect(0, 0, 760, 5, color.gold)
    promoRule:SetOpacity(0.92)
    promoRule:Reparent(promo, -1)
    local promoSmall = ink.text("WELCOME OFFER", 0, 52, 34, color.gold)
    promoSmall:SetSize(Vector2.new({ X = 700, Y = 44 }))
    promoSmall:Reparent(promo, -1)
    local promoHead = ink.text("Open a Marmur account", 0, 118, 86, color.white)
    promoHead:SetSize(Vector2.new({ X = 1320, Y = 110 }))
    promoHead:Reparent(promo, -1)
    local promoCash = ink.text("Opening credit available", 0, 232, 84, color.gold)
    promoCash:SetSize(Vector2.new({ X = 1320, Y = 110 }))
    promoCash:Reparent(promo, -1)
    local promoBody = ink.text("Start with E$250 or more. Your estimated opening credit appears during setup before you sign.", 0, 366, 38, color.white)
    promoBody:SetWrapping(true)
    promoBody:SetSize(Vector2.new({ X = 1040, Y = 112 }))
    promoBody:Reparent(promo, -1)

    self:createButton(promo, "Open an account", 0, 522, 460, 84, function() self:renderPage("signup") end, { fgColor = color.green, hoverColor = color.white, fontSize = 42 })

    local fine = ink.text("Credit requires the account to remain open for 72 hours. Closing within 30 days may trigger an Early Closure Fee.", 0, 632, 27, color.dim)
    fine:SetWrapping(true)
    fine:SetSize(Vector2.new({ X = 1080, Y = 70 }))
    fine:Reparent(promo, -1)

    local terms = ink.canvas(0, 704, inkEAnchor.TopLeft)
    terms:SetSize(Vector2.new({ X = 1320, Y = 74 }))
    terms:Reparent(promo, -1)
    local termBg = ink.rect(0, 0, 1320, 74, color.white)
    termBg:SetOpacity(0.035)
    termBg:Reparent(terms, -1)
    local termText = ink.text("Minimum deposit E$250    •    Estimate before signing    •    Credit after 72 hours    •    Early closure rules apply", 28, 20, 27, color.dim)
    termText:SetSize(Vector2.new({ X = 1260, Y = 38 }))
    termText:Reparent(terms, -1)
end

function shell:buildAccountFoundPage()
    local page = ink.canvas(0, 180, inkEAnchor.TopLeft)
    page:SetSize(Vector2.new({ X = 2960, Y = 1180 }))
    page:Reparent(self.contentCanvas, -1)
    local root = ink.rect(0, 0, 2960, 1180, color.panel)
    root:SetOpacity(0.98)
    root:Reparent(page, -1)

    local heroTitle = ink.text("MARMUR BANK", 1480, 70, 76, color.gold)
    heroTitle:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    heroTitle:SetSize(Vector2.new({ X = 900, Y = 92 }))
    heroTitle:Reparent(page, -1)

    local card = self:makePanel(page, 640, 292, 1680, 610)
    local topGlow = ink.rect(50, 38, 1580, 2, color.cyan)
    topGlow:SetOpacity(0.55)
    topGlow:Reparent(card, -1)
    local badge = ink.text("ACCOUNT FOUND", 840, 112, 32, color.cyan)
    badge:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    badge:SetSize(Vector2.new({ X = 520, Y = 44 }))
    badge:Reparent(card, -1)
    local head = ink.text("We already found an account for you", 840, 190, 64, color.white)
    head:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    head:SetSize(Vector2.new({ X = 1420, Y = 88 }))
    head:Reparent(card, -1)
    local line1 = ink.text("A current Marmur profile is already active on this terminal.", 840, 320, 34, color.dim)
    line1:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    line1:SetSize(Vector2.new({ X = 1280, Y = 44 }))
    line1:Reparent(card, -1)
    local line2 = ink.text("Sign in to manage your savings ledger, activity, private services, and loan servicing.", 840, 366, 34, color.dim)
    line2:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    line2:SetSize(Vector2.new({ X = 1280, Y = 44 }))
    line2:Reparent(card, -1)
    self:createButton(card, "Back to Sign In", 540, 500, 600, 92, function()
        self.isLoggedIn = false
        self:renderPage("login")
    end, { fgColor = color.cyan, fontSize = 42 })
end

function shell:updateAccountSignatureButtonState()
    if not self.accountSignatureWidgets or not self.accountSignatureWidgets.signBorder then return end
    if self.accountSignatureFilled == true then
        self.accountSignatureWidgets.signBorder:SetTintColor(color.green)
        self.accountSignatureWidgets.signBorder:SetOpacity(0.84)
        self.accountSignatureWidgets.signLabel:SetTintColor(color.green)
        if self.accountSignatureWidgets.helper then
            self.accountSignatureWidgets.helper:SetText(ink.translate("Signature captured. Final submission unlocked."))
            self.accountSignatureWidgets.helper:SetTintColor(color.green)
        end
    else
        self.accountSignatureWidgets.signBorder:SetTintColor(color.gold)
        self.accountSignatureWidgets.signBorder:SetOpacity(0.0)
        self.accountSignatureWidgets.signLabel:SetTintColor(color.dim)
        if self.accountSignatureWidgets.helper then
            self.accountSignatureWidgets.helper:SetText(ink.translate("Select the signature field to auto-fill your legal name."))
            self.accountSignatureWidgets.helper:SetTintColor(color.dim)
        end
    end
end

function shell:createAccountSignatureField(parent, x, y, w, h)
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)
    local border = ink.rect(0, 0, w, h, color.dim)
    border:Reparent(holder, -1)
    local fill = ink.rect(3, 3, w - 6, h - 6, color.brandPanel2)
    fill:Reparent(holder, -1)
    local compactSignature = h < 110
    local label = ink.text("DIGITAL SIGNATURE", 28, compactSignature and 10 or 14, compactSignature and 21 or 25, color.dim)
    label:Reparent(holder, -1)
    local value = ink.text(self.accountSignatureFilled and self:getPlayerSignatureName() or "", 28, compactSignature and 40 or 52, compactSignature and 42 or 56, color.white)
    value:SetSize(Vector2.new({ X = w - 56, Y = compactSignature and 48 or 64 }))
    value:Reparent(holder, -1)
    local hint = ink.text(self.accountSignatureFilled and "Signature verified" or "Click to sign", w - 260, compactSignature and 15 or 20, compactSignature and 24 or 28, self.accountSignatureFilled and color.green or color.gold)
    hint:SetSize(Vector2.new({ X = 230, Y = 40 }))
    hint:Reparent(holder, -1)
    self:addSubscriber(fill, {
        hoverIn = function() border:SetTintColor(color.white) end,
        hoverOut = function() border:SetTintColor(self.accountSignatureFilled and color.green or color.dim) end,
        click = function()
            if self.accountSignatureToken or self.accountSignatureFilled then return end
            utils.playSound("ui_menu_onpress", 1)
            local fillText = self:getPlayerSignatureName()
            local chars = {}
            for i = 1, #fillText do chars[i] = fillText:sub(i, i) end
            value:SetText("")
            hint:SetText(ink.translate("Signing..."))
            hint:SetTintColor(color.cyan)
            border:SetTintColor(color.cyan)
            self.accountSignatureToken = Cron.Every(0.075, function(timer)
                local tick = timer.tick or 1
                if tick <= #chars then
                    value:SetText((value:GetText() or "") .. chars[tick])
                    timer.tick = tick + 1
                else
                    Cron.Halt(timer)
                    self.accountSignatureToken = nil
                    self.accountSignatureFilled = true
                    hint:SetText(ink.translate("Signature verified"))
                    hint:SetTintColor(color.green)
                    self:updateAccountSignatureButtonState()
                end
            end, { tick = 1 })
        end,
    })
    return { canvas = holder, border = border, fill = fill, text = value, hint = hint }
end

function shell:submitOpenAccount(amount, data)
    local snapshot = data or self:getBankData()
    amount = math.floor(tonumber(amount) or 0)
    if self.accountSignatureFilled ~= true then
        self:setTransferError("openaccount", "Digital signature required before account opening.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("signup")
        return
    end
    local accountOpen = false
    pcall(function() accountOpen = Bank:isAccountOpen() == true end)
    if accountOpen then
        self:renderPage("accountfound")
        return
    end
    if amount <= 0 then
        self:setTransferError("openaccount", "Enter an opening deposit of at least E$ 250.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("signup")
        return
    end
    if amount < self:getMinimumOpeningDeposit() then
        self:setTransferError("openaccount", "Minimum opening deposit is E$ 250.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("signup")
        return
    end
    if amount > (snapshot.wallet or 0) then
        self:setTransferError("openaccount", "Opening deposit exceeds available checking funds.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("signup")
        return
    end
    local ok = false
    local reason = ""
    local posted = 0
    local bonus = 0
    local accountNumber = ""
    local reopening = false
    pcall(function() ok, reason, posted, bonus, accountNumber, reopening = Bank:openAccountWithDeposit(amount) end)
    if ok then
        self.isLoggedIn = true
        self.confirmMode = "openaccount"
        self.lastAmount = amount
        self.lastOpeningBonus = math.floor(tonumber(bonus) or self:getOpeningIncentiveAmount(amount))
        self.lastAccountNumber = tostring(accountNumber or "")
        self.lastAccountReopened = reopening == true
        self:setCustomAmountString("openaccount", "")
        self:setTransferError("openaccount", "")
        self.accountSignatureFilled = false
        self.accountSignatureWidgets = {}
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        local msg = "Account opening could not be completed."
        if reason == "existing" then msg = "An active Marmur account already exists. Please sign in."
        elseif reason == "amount" then msg = "Enter an opening deposit of at least E$ 250."
        elseif reason == "minimum" then msg = "Minimum opening deposit is E$ 250."
        elseif reason == "funds" then msg = "Opening deposit exceeds available checking funds."
        elseif reason == "deposit" then msg = "Opening deposit failed during secure posting." end
        self:setTransferError("openaccount", msg)
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("signup")
    end
end

function shell:buildSignupPage()
    local accountOpen = false
    pcall(function() accountOpen = Bank:isAccountOpen() == true end)
    if accountOpen then
        self:buildAccountFoundPage()
        return
    end

    local data = self:getBankData()
    local amountLabel = self:getCustomAmountLabel("openaccount")
    local projected = self:getProjectedOpenAccountData(data)
    local errorText = self:getTransferError("openaccount")
    local entryFontSize = (#amountLabel >= 18) and 54 or 72

    local page = ink.canvas(0, 180, inkEAnchor.TopLeft)
    page:SetSize(Vector2.new({ X = 2960, Y = 1180 }))
    page:Reparent(self.contentCanvas, -1)
    local root = ink.rect(0, 0, 2960, 1180, color.panel)
    root:SetOpacity(0.98)
    root:Reparent(page, -1)

    local heroTitle = ink.text("MARMUR BANK", 1480, 34, 78, color.gold)
    heroTitle:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    heroTitle:SetSize(Vector2.new({ X = 980, Y = 92 }))
    heroTitle:Reparent(page, -1)
    local heroSub = ink.text("OPEN A PRIVATE SAVINGS LEDGER", 1480, 116, 31, color.dim)
    heroSub:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    heroSub:SetSize(Vector2.new({ X = 1180, Y = 42 }))
    heroSub:Reparent(page, -1)

    local strip = self:makePanel(page, 220, 178, 2520, 160)
    local title = ink.text("NEW ACCOUNT APPLICATION", 44, 30, 58, color.white)
    title:Reparent(strip, -1)
    local sub = ink.text("Set opening deposit, review estimate, sign, and activate profile.", 46, 96, 27, color.dim)
    sub:SetWrapping(true)
    sub:SetSize(Vector2.new({ X = 1360, Y = 54 }))
    sub:Reparent(strip, -1)
    self:drawKV(strip, "Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 1940, 34, color.cyan, 470, 46)

    local left = self:makePanel(page, 220, 370, 1200, 725)
    local lh = ink.text("OPENING DEPOSIT", 50, 34, 48, color.cyan)
    lh:Reparent(left, -1)
    local entry = self:makePanel(left, 50, 108, 1100, 170)
    local el = ink.text("AMOUNT TO MOVE INTO SAVINGS", 32, 22, 27, color.dim)
    el:Reparent(entry, -1)
    local ev = ink.text(amountLabel, 32, 68, entryFontSize, color.gold)
    ev:SetSize(Vector2.new({ X = 1020, Y = 80 }))
    ev:Reparent(entry, -1)

    local x1, x2, x3, x4 = 50, 310, 570, 830
    local y1, y2, y3, y4 = 322, 412, 502, 592
    local bw, bh = 220, 70
    self:createButton(left, "1", x1, y1, bw, bh, function() self:appendCustomAmount("openaccount", "1") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "2", x2, y1, bw, bh, function() self:appendCustomAmount("openaccount", "2") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "3", x3, y1, bw, bh, function() self:appendCustomAmount("openaccount", "3") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "Back", x4, y1, 320, bh, function() self:backspaceCustomAmount("openaccount") end, { fgColor = color.gold, fontSize = 29 })
    self:createButton(left, "4", x1, y2, bw, bh, function() self:appendCustomAmount("openaccount", "4") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "5", x2, y2, bw, bh, function() self:appendCustomAmount("openaccount", "5") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "6", x3, y2, bw, bh, function() self:appendCustomAmount("openaccount", "6") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "Clear", x4, y2, 320, bh, function() self:clearCustomAmount("openaccount") end, { fgColor = color.gold, fontSize = 29 })
    self:createButton(left, "7", x1, y3, bw, bh, function() self:appendCustomAmount("openaccount", "7") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "8", x2, y3, bw, bh, function() self:appendCustomAmount("openaccount", "8") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "9", x3, y3, bw, bh, function() self:appendCustomAmount("openaccount", "9") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "Max", x4, y3, 320, bh, function() self:fillMaxCustomAmount("openaccount", data) end, { fgColor = color.green, fontSize = 29 })
    self:createButton(left, "0", x1, y4, bw, bh, function() self:appendCustomAmount("openaccount", "0") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "00", x2, y4, bw, bh, function() self:appendCustomAmount("openaccount", "00") end, { fgColor = color.gold, fontSize = 34 })
    self:createButton(left, "000", x3, y4, bw, bh, function() self:appendCustomAmount("openaccount", "000") end, { fgColor = color.gold, fontSize = 34 })

    local right = self:makePanel(page, 1460, 370, 1280, 725)
    local rh = ink.text("OPENING SUMMARY", 50, 34, 48, color.white)
    rh:Reparent(right, -1)

    local previewNote = ink.text("Minimum E$250. Every account begins at Standard; maintain a qualifying 7-day average to advance. Opening credit stays pending for 72 hours.", 52, 96, 24, color.dim)
    previewNote:SetWrapping(true)
    previewNote:SetSize(Vector2.new({ X = 980, Y = 62 }))
    previewNote:Reparent(right, -1)

    self:drawKV(right, "Initial Deposit", "E$ " .. utils.formatNumber(projected.amount or 0), 52, 158, color.white, 340, 38)
    self:drawKV(right, "Pending Credit", "E$ " .. utils.formatNumber(projected.bonus or 0), 455, 158, (projected.bonus or 0) > 0 and color.green or color.dim, 340, 38)
    self:drawKV(right, "Savings After", "E$ " .. utils.formatNumber(projected.projectedSavings or 0), 858, 158, color.gold, 340, 38)

    self:drawKV(right, "Starting Level", tostring(projected.service.tier or "Standard"), 52, 258, color.green, 340, 36)
    self:drawKV(right, "7-Day Target", tostring(projected.qualificationTarget or "Standard"), 455, 258, color.gold, 340, 36)
    self:drawKV(right, "Opening Fee", "E$ " .. utils.formatNumber(projected.openingFee or 0), 858, 258, color.green, 340, 36)

    self:drawKV(right, "Starting Rate", string.format("%.2f%%", projected.interest or 0), 52, 358, color.green, 340, 34)
    self:drawKV(right, "Net Yield", string.format("%.3f%%", projected.netYield or 0), 455, 358, color.green, 340, 34)
    self:drawKV(right, "Credit Status", (projected.bonus or 0) > 0 and "Pending 72 hrs" or "Pending deposit", 858, 358, (projected.bonus or 0) > 0 and color.gold or color.dim, 340, 34)

    local rb = ink.text("By signing, you authorize Marmur Bank to open a savings ledger, debit checking for the deposit, and apply posted account terms.", 52, 452, 21, color.dim)
    rb:SetWrapping(true)
    rb:SetSize(Vector2.new({ X = 980, Y = 58 }))
    rb:Reparent(right, -1)
    self.accountSignatureWidgets.signature = self:createAccountSignatureField(right, 50, 520, 1180, 86)
    local helper = ink.text("Select the signature field to auto-fill your legal name.", 52, 614, 23, color.dim)
    helper:SetWrapping(true)
    helper:SetSize(Vector2.new({ X = 680, Y = 32 }))
    helper:Reparent(right, -1)
    self.accountSignatureWidgets.helper = helper
    local signHolder = ink.canvas(770, 610, inkEAnchor.TopLeft)
    signHolder:SetSize(Vector2.new({ X = 460, Y = 62 }))
    signHolder:Reparent(right, -1)
    local signLabel = ink.text("Open My Account", 230, 28, 30, self.accountSignatureFilled and color.green or color.dim)
    signLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    signLabel:SetSize(Vector2.new({ X = 430, Y = 46 }))
    signLabel:Reparent(signHolder, -1)
    local signBorder = ink.rect(90, 56, 280, 3, color.gold)
    signBorder:SetOpacity(self.accountSignatureFilled and 0.84 or 0.0)
    signBorder:Reparent(signHolder, -1)
    local signHotspot = ink.rect(0, 0, 460, 62, color.white)
    signHotspot:SetOpacity(0.01)
    signHotspot:Reparent(signHolder, -1)
    self.accountSignatureWidgets.signBorder = signBorder
    self.accountSignatureWidgets.signLabel = signLabel
    self:addSubscriber(signHotspot, {
        hoverIn = function()
            signLabel:SetTintColor(color.green)
            signBorder:SetTintColor(color.green)
            signBorder:SetOpacity(0.92)
        end,
        hoverOut = function() self:updateAccountSignatureButtonState() end,
        click = function() self:submitCustomAmount("openaccount", data) end,
    })
    self:updateAccountSignatureButtonState()

    local errColor = (#errorText > 0) and color.gold or color.dim
    local msg = (#errorText > 0) and errorText or "Deposit posts after verification. Opening credit remains pending until eligible."
    local err = ink.text(msg, 52, 662, 22, errColor)
    err:SetWrapping(true)
    err:SetSize(Vector2.new({ X = 800, Y = 42 }))
    err:Reparent(right, -1)

    self:createButton(page, "Back to Login", 1180, 1112, 600, 60, function() self:renderPage("login") end, { fgColor = color.cyan, fontSize = 32 })
end

function shell:getFlagNoticeSummary()
    local summary = {
        show = false,
        active = false,
        remainingMinutes = 0,
        remainingText = "7 days",
        statusText = "Dispute cooldown active",
        reasonText = "Recent dispute activity requires a temporary account review.",
    }
    pcall(function()
        local bankSummary = Bank:getDisputeFlagNoticeSummary()
        if type(bankSummary) == "table" then summary = bankSummary end
    end)
    return summary
end

function shell:acknowledgeFlagNotice()
    pcall(function() Bank:acknowledgeDisputeFlagNotice() end)
    local nextPage = tostring(self.afterFlagNoticePage or "home")
    if nextPage == "" or nextPage == "flagnotice" or nextPage == "login" or nextPage == "signup" or nextPage == "accountfound" then
        nextPage = "home"
    end
    self.afterFlagNoticePage = nil
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage(nextPage)
end

function shell:buildFlagNoticeCard(parent, title, body, x, y, w, h, bodyColor, bodyFontSize)
    local card = self:makePanel(parent, x, y, w, h)
    local t = ink.text(title, 28, 22, 26, color.dim)
    t:SetWrapping(true)
    t:SetSize(Vector2.new({ X = w - 56, Y = 34 }))
    t:Reparent(card, -1)

    local b = ink.text(body, 28, 66, bodyFontSize or 32, bodyColor or color.white)
    b:SetWrapping(true)
    b:SetSize(Vector2.new({ X = w - 56, Y = h - 78 }))
    b:Reparent(card, -1)
    return card
end

function shell:buildFlagNoticePage()
    local summary = self:getFlagNoticeSummary()
    local remainingMinutes = math.max(math.floor(tonumber(summary.remainingMinutes or 0) or 0), 0)
    local remainingText = tostring(summary.remainingText or "7 days")
    if remainingMinutes >= 1440 then
        local days = math.ceil(remainingMinutes / 1440)
        remainingText = tostring(days) .. (days == 1 and " day" or " days")
    elseif remainingText == "" or remainingMinutes <= 0 then
        remainingText = "7 days"
    end
    local reasonText = tostring(summary.reasonText or "Recent dispute activity requires a temporary account review.")

    local strip = self:makePanel(self.contentCanvas, 80, 440, 2700, 150)
    local t1 = ink.text("ACCOUNT NOTICE", 40, 26, 56, color.red)
    t1:SetSize(Vector2.new({ X = 900, Y = 70 }))
    t1:Reparent(strip, -1)
    local t2 = ink.text("Marmur Bank account review notification", 42, 88, 32, color.dim)
    t2:SetWrapping(true)
    t2:SetSize(Vector2.new({ X = 1500, Y = 44 }))
    t2:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Status", "Temporarily Flagged", 1808, 34, color.red, 430, 26, 36)
    self:drawHeaderStat(strip, "Disputes", "Unavailable", 2260, 34, color.gold, 400, 26, 36)

    local main = self:makePanel(self.contentCanvas, 80, 620, 2700, 640)
    local header = ink.text("YOUR ACCOUNT HAS BEEN FLAGGED", 40, 34, 50, color.red)
    header:SetSize(Vector2.new({ X = 1800, Y = 66 }))
    header:Reparent(main, -1)

    local bodyMessage = "Marmur Bank has temporarily flagged this account due to recent dispute activity. During this review period, new disputes cannot be submitted."
    local body = ink.text(bodyMessage, 40, 104, 36, color.white)
    body:SetWrapping(true)
    body:SetSize(Vector2.new({ X = 2520, Y = 96 }))
    body:Reparent(main, -1)

    local divider = ink.rect(40, 212, 2620, 3, color.red)
    divider:SetOpacity(0.28)
    divider:Reparent(main, -1)

    self:buildFlagNoticeCard(main, "Reason", reasonText, 40, 246, 1230, 168, color.white, 30)
    self:buildFlagNoticeCard(main, "Dispute access", "Unavailable for " .. remainingText .. ".", 1320, 246, 600, 168, color.gold, 34)
    self:buildFlagNoticeCard(main, "Other services", "Deposits, withdrawals, loans, and other account functions remain available.", 1980, 246, 640, 168, color.green, 30)

    local foot = ink.text("Select Acknowledge to continue to your account. This notice will not appear again during the current review period.", 40, 458, 32, color.dim)
    foot:SetWrapping(true)
    foot:SetSize(Vector2.new({ X = 2420, Y = 82 }))
    foot:Reparent(main, -1)

    self:makePanel(main, 990, 532, 720, 90)
    self:createButton(main, "Acknowledge", 990, 542, 720, 70, function() self:acknowledgeFlagNotice() end, { bgColor = color.brandPanel2, fgColor = color.cyan, hoverColor = color.white, fontSize = 40, active = true })
end

function shell:getDisclosureSections()
    return {
        {
            title = "Deposit Account Agreement",
            short = "Account Terms",
            intro = "Core terms for opening, maintaining, closing, and reopening a Marmur savings relationship.",
            bullets = {
                "Minimum opening deposit is E$250.",
                "New and reopened profiles receive a new account number.",
                "Checking mirrors the player's spendable balance; Savings represents the Marmur ledger.",
                "Unsupported or inconsistent activity may be reviewed, delayed, reversed, or denied.",
                "Closed profiles may be reopened later through the sign-in page."
            }
        },
        {
            title = "Electronic Banking Authorization",
            short = "Digital Authorization",
            intro = "Rules governing keypad entries, digital signatures, confirmations, and secure portal instructions.",
            bullets = {
                "Keypad entries and digital signatures are treated as binding customer instructions.",
                "Confirmation pages and Activity records serve as the official transaction receipt.",
                "Security and servicing notices may appear in the browser or Marmur message thread.",
                "Portal access requires authentication through the Netwatch relay.",
                "Customers should review Activity after completing a transaction."
            }
        },
        {
            title = "Funds Availability & Transfers",
            short = "Transfers",
            intro = "Posting rules for deposits, withdrawals, scheduled transfers, reversals, and interrupted sessions.",
            bullets = {
                "Approved deposits and withdrawals normally post immediately.",
                "Scheduled auto-deposits move the selected amount from Checking to Savings when due.",
                "Large or unusual activity may require additional review.",
                "Interrupted sessions may delay a confirmation even when the transaction later posts.",
                "Detected ledger errors may be corrected through reversal or account credit."
            }
        },
        {
            title = "Account Levels, Interest & Yield",
            short = "Levels & Yield",
            intro = "How the seven-day average determines relationship level, cashback rate, interest, and downgrade protection.",
            bullets = {
                "Account levels use the rolling seven-day Savings average.",
                "An earned level remains protected down to 75% of its qualification threshold.",
                "Three full days below the protection floor may lower the account level.",
                "Interest and cashback follow the active relationship level.",
                "Tax may reduce gross interest before the net credit posts."
            }
        },
        {
            title = "Opening Credit & Early Closure",
            short = "Opening Credit",
            intro = "Conditions attached to opening incentives, the 72-hour hold, forfeiture, and early account closure.",
            bullets = {
                "Opening credit is calculated from the qualifying initial deposit.",
                "Eligible opening credit remains pending for 72 hours.",
                "Pending opening credit is forfeited when the account closes before payout.",
                "Closing within the protected period may trigger an Early Closure Fee.",
                "Remaining eligible Savings funds return to Checking when closure completes."
            }
        },
        {
            title = "Loan Servicing, Default & Recovery",
            short = "Loan Servicing",
            intro = "Payment review, past-due restrictions, default recovery, and Vanguard vehicle-liquidation boundaries.",
            bullets = {
                "Every manual loan payment requires review and confirmation before posting.",
                "Past-due manual payments include the required scheduled amount and applicable late fee.",
                "A past-due personal loan restricts portal access to the repayment path.",
                "Default recovery may liquidate eligible customer-owned Vanguard Garage vehicles.",
                "Financed vehicles, stash items, weapons, and unrelated property are excluded."
            }
        }
    }
end

function shell:selectDisclosure(index)
    local sections = self:getDisclosureSections()
    local selected = math.max(1, math.min(math.floor(tonumber(index) or 1), #sections))
    self.disclosureSelectedIndex = selected
    self:renderPage("disclosures")
end

function shell:buildDisclosuresPage(loggedIn)
    local publicMode = loggedIn ~= true
    local pageRoot = self.contentCanvas
    local baseX = 80
    local baseY = 480
    local totalW = 2800

    if publicMode then
        local page = ink.canvas(0, 180, inkEAnchor.TopLeft)
        page:SetSize(Vector2.new({ X = 2960, Y = 1180 }))
        page:Reparent(self.contentCanvas, -1)
        local root = ink.rect(0, 0, 2960, 1180, color.brandBlack or color.panel)
        root:SetOpacity(0.995)
        root:Reparent(page, -1)

        local brand = ink.text("MARMUR BANK", 120, 50, 70, color.brandWhite or color.white)
        brand:Reparent(page, -1)
        local sub = ink.text("Privacy, legal, and account disclosures", 124, 122, 29, color.dim)
        sub:SetSize(Vector2.new({ X = 980, Y = 42 }))
        sub:Reparent(page, -1)
        local address = ink.text("NETDIR://MARMUR.BANK/DISCLOSURES", 1640, 72, 31, color.brandRedBright or color.red)
        address:SetSize(Vector2.new({ X = 1060, Y = 42 }))
        address:Reparent(page, -1)
        local divider = ink.rect(120, 184, 2720, 3, color.brandRed or color.red)
        divider:SetOpacity(0.62)
        divider:Reparent(page, -1)

        pageRoot = page
        baseX = 120
        baseY = 216
        totalW = 2720
    end

    local sections = self:getDisclosureSections()
    local selectedIndex = math.max(1, math.min(math.floor(tonumber(self.disclosureSelectedIndex) or 1), #sections))
    self.disclosureSelectedIndex = selectedIndex
    local selected = sections[selectedIndex]

    local header = self:makePanel(pageRoot, baseX, baseY, totalW, 148)
    local title = ink.text("ACCOUNT DISCLOSURES", 34, 18, 50, color.brandWhite or color.white)
    title:SetSize(Vector2.new({ X = 1080, Y = 70 }))
    title:Reparent(header, -1)
    local subtitle = ink.text("Choose one topic at a time. The selected disclosure appears in full on the right.", 36, 86, 27, color.dim)
    subtitle:SetSize(Vector2.new({ X = 1540, Y = 46 }))
    subtitle:Reparent(header, -1)
    self:drawHeaderStat(header, "Effective", "2077-01-01", totalW - 690, 26, color.white, 300, 23, 32)
    self:drawHeaderStat(header, "Version", "MBK-LEGAL-14", totalW - 360, 26, color.brandRedBright or color.red, 320, 23, 30)

    local mainY = baseY + 168
    local leftW = publicMode and 730 or 760
    local gap = 36
    local rightW = totalW - leftW - gap
    local left = self:makePanel(pageRoot, baseX, mainY, leftW, 748)
    local right = self:makePanel(pageRoot, baseX + leftW + gap, mainY, rightW, 748)

    local indexHead = ink.text("DISCLOSURE INDEX", 28, 20, 36, color.cyan)
    indexHead:Reparent(left, -1)
    local indexSub = ink.text("Select a section", 30, 62, 23, color.dim)
    indexSub:Reparent(left, -1)

    local buttonY = 104
    for i, section in ipairs(sections) do
        local targetIndex = i
        local active = i == selectedIndex
        self:createTransferKey(left, tostring(i) .. ".  " .. section.short, 26, buttonY, leftW - 52, 76, function()
            self:selectDisclosure(targetIndex)
        end, {
            borderColor = active and (color.brandRedBright or color.red) or color.dim,
            textColor = active and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 25,
            fillOpacity = active and 0.72 or 0.42,
        })
        buttonY = buttonY + 86
    end

    local indexNote = ink.text("The Activity ledger and transaction confirmation screens remain the controlling record for completed banking actions.", 30, 630, 22, color.dim)
    indexNote:SetWrapping(true)
    indexNote:SetSize(Vector2.new({ X = leftW - 60, Y = 82 }))
    indexNote:Reparent(left, -1)

    local detailTitle = ink.text(tostring(selectedIndex) .. ". " .. selected.title, 34, 22, 42, color.brandWhite or color.white)
    detailTitle:SetWrapping(true)
    detailTitle:SetSize(Vector2.new({ X = rightW - 68, Y = 72 }))
    detailTitle:Reparent(right, -1)
    local intro = ink.text(selected.intro, 36, 94, 27, color.dim)
    intro:SetWrapping(true)
    intro:SetSize(Vector2.new({ X = rightW - 72, Y = 78 }))
    intro:Reparent(right, -1)
    local rule = ink.rect(36, 178, rightW - 72, 2, color.brandRed or color.red)
    rule:SetOpacity(0.38)
    rule:Reparent(right, -1)

    local bulletY = 198
    for i, body in ipairs(selected.bullets) do
        local number = ink.text(string.format("%02d", i), 38, bulletY, 24, color.brandRedBright or color.red)
        number:SetSize(Vector2.new({ X = 54, Y = 38 }))
        number:Reparent(right, -1)
        local bullet = ink.text(body, 104, bulletY - 2, 27, color.brandWhiteSoft or color.white)
        bullet:SetWrapping(true)
        bullet:SetSize(Vector2.new({ X = rightW - 146, Y = 70 }))
        bullet:Reparent(right, -1)
        local bulletLine = ink.rect(104, bulletY + 62, rightW - 142, 1, color.brandWhite or color.white)
        bulletLine:SetOpacity(0.07)
        bulletLine:Reparent(right, -1)
        bulletY = bulletY + 86
    end

    local legal = ink.text("Marmur Bank service disclosure. This interface is a Night City banking simulation and does not provide real-world financial, tax, or legal advice.", 36, 616, 22, color.dim)
    legal:SetWrapping(true)
    legal:SetSize(Vector2.new({ X = rightW - 72, Y = 62 }))
    legal:Reparent(right, -1)

    local previousIndex = selectedIndex > 1 and (selectedIndex - 1) or nil
    local nextIndex = selectedIndex < #sections and (selectedIndex + 1) or nil
    self:createTransferKey(right, "PREVIOUS", rightW - 680, 686, 200, 56, previousIndex and function() self:selectDisclosure(previousIndex) end or nil, {
        borderColor = color.dim,
        textColor = previousIndex and color.brandWhite or color.dim,
        fontSize = 22,
        fillOpacity = 0.42,
    })
    self:createTransferKey(right, "NEXT", rightW - 460, 686, 190, 56, nextIndex and function() self:selectDisclosure(nextIndex) end or nil, {
        borderColor = color.dim,
        textColor = nextIndex and color.brandWhite or color.dim,
        fontSize = 22,
        fillOpacity = 0.42,
    })
    self:createTransferKey(right, publicMode and "BACK TO SIGN IN" or "BACK TO HOME", rightW - 250, 686, 220, 56, function()
        self:renderPage(publicMode and "login" or "home")
    end, {
        borderColor = color.brandRed or color.red,
        textColor = color.brandRedBright or color.red,
        hoverColor = color.brandWhite or color.white,
        fontSize = 21,
        fillOpacity = 0.48,
    })
end

function shell:makeHomePanel(parent, x, y, w, h, opts)
    opts = opts or {}
    local panel = ink.canvas(x, y, inkEAnchor.TopLeft)
    panel:SetSize(Vector2.new({ X = w, Y = h }))
    panel:Reparent(parent, -1)

    local bg = ink.image(w / 2, h / 2, w, h, ATLAS, "cell_bg", opts.bgColor or color.brandPanel2 or color.panel)
    bg.image.useNineSliceScale = true
    bg.image:SetOpacity(opts.opacity or 0.46)
    bg.pos:Reparent(panel, -1)

    local borderColor = opts.borderColor or color.brandRed or color.red
    local borderOpacity = opts.borderOpacity or 0.34
    local top = ink.rect(0, 0, w, 2, borderColor)
    top:SetOpacity(borderOpacity)
    top:Reparent(panel, -1)
    local bottom = ink.rect(0, h - 2, w, 2, borderColor)
    bottom:SetOpacity(borderOpacity * 0.72)
    bottom:Reparent(panel, -1)
    local left = ink.rect(0, 0, 2, h, borderColor)
    left:SetOpacity(borderOpacity * 0.72)
    left:Reparent(panel, -1)
    local right = ink.rect(w - 2, 0, 2, h, borderColor)
    right:SetOpacity(borderOpacity * 0.72)
    right:Reparent(panel, -1)

    return panel
end

function shell:createHomeSidebarItem(parent, labelText, y, callback, active)
    local w = 338
    local homeLayout = tostring(self.activePage or "") == "home"
    local h = homeLayout and 68 or 72
    local holder = ink.canvas(10, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local fill = ink.image(w / 2, h / 2, w, h, ATLAS, "cell_bg", color.brandRed or color.red)
    fill.image.useNineSliceScale = true
    fill.image:SetOpacity(active and 0.30 or 0.02)
    fill.pos:Reparent(holder, -1)

    local accent = ink.rect(0, 0, active and 6 or 2, h, color.brandRedBright or color.red)
    accent:SetOpacity(active and 0.95 or 0.18)
    accent:Reparent(holder, -1)

    local markerY = homeLayout and 28 or 30
    local marker = ink.rect(34, markerY, 12, 12, active and (color.brandWhite or color.white) or (color.brandRed or color.red))
    marker:SetOpacity(active and 0.95 or 0.54)
    marker:Reparent(holder, -1)

    local textY = homeLayout and 13 or 10
    local textSize = homeLayout and 39 or 42
    local textHeight = homeLayout and 46 or 54
    local text = ink.text(labelText, 68, textY, textSize, active and (color.brandWhite or color.white) or color.dim)
    text:SetSize(Vector2.new({ X = homeLayout and 246 or 250, Y = textHeight }))
    text:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)
    self:addSubscriber(hotspot, {
        hoverIn = function()
            fill.image:SetOpacity(active and 0.36 or 0.16)
            accent:SetOpacity(0.95)
            marker:SetTintColor(color.brandWhite or color.white)
            text:SetTintColor(color.brandWhite or color.white)
        end,
        hoverOut = function()
            fill.image:SetOpacity(active and 0.30 or 0.02)
            accent:SetOpacity(active and 0.95 or 0.18)
            marker:SetTintColor(active and (color.brandWhite or color.white) or (color.brandRed or color.red))
            text:SetTintColor(active and (color.brandWhite or color.white) or color.dim)
        end,
        click = function()
            utils.playSound("ui_menu_onpress", 1)
            callback()
        end,
    })
    return holder
end

function shell:buildHomeFrame()
    local W, H = 2960, 1180
    local bg = ink.rect(0, 150, W, H, color.brandBlack or color.panel)
    bg:SetOpacity(0.995)
    bg:Reparent(self.contentCanvas, -1)

    for i = 0, 10 do
        local line = ink.rect(0, 150 + (i * 112), W, 1, color.brandWhite or color.white)
        line:SetOpacity(0.022)
        line:Reparent(self.contentCanvas, -1)
    end

    local header = ink.rect(0, 150, W, 150, color.brandPanel or color.panel)
    header:SetOpacity(0.92)
    header:Reparent(self.contentCanvas, -1)
    local headerTop = ink.rect(0, 150, W, 3, color.brandRed or color.red)
    headerTop:SetOpacity(0.78)
    headerTop:Reparent(self.contentCanvas, -1)
    local headerBottom = ink.rect(0, 298, W, 2, color.brandWhite or color.white)
    headerBottom:SetOpacity(0.12)
    headerBottom:Reparent(self.contentCanvas, -1)

    local logoMark = ink.text("◇", 48, 164, 96, color.brandRedBright or color.red)
    logoMark:SetSize(Vector2.new({ X = 100, Y = 112 }))
    logoMark:Reparent(self.contentCanvas, -1)
    local brand = ink.text("MARMUR BANK", 146, 170, 70, color.brandWhite or color.white)
    brand:SetSize(Vector2.new({ X = 720, Y = 78 }))
    brand:Reparent(self.contentCanvas, -1)
    local slogan = ink.text("Trusted Banking. Always Secured.", 150, 242, 29, color.dim)
    slogan:SetSize(Vector2.new({ X = 690, Y = 36 }))
    slogan:Reparent(self.contentCanvas, -1)

    local address = ink.text("NETDIR://MARMUR.BANK/HOME", 930, 192, 34, color.brandRedBright or color.red)
    address:SetSize(Vector2.new({ X = 760, Y = 44 }))
    address:Reparent(self.contentCanvas, -1)
    local addressLine = ink.rect(900, 258, 1050, 2, color.brandRed or color.red)
    addressLine:SetOpacity(0.28)
    addressLine:Reparent(self.contentCanvas, -1)

    local powered = ink.text("POWERED BY NETWATCH", 2800, 188, 28, color.dim)
    powered:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    powered:SetSize(Vector2.new({ X = 520, Y = 42 }))
    powered:Reparent(self.contentCanvas, -1)

    local calendarContext = Calendar.getContext()
    local dateTime = ink.text(Calendar.formatCurrentDateTime(calendarContext, true), 2800, 236, 31, color.brandWhiteSoft or color.white)
    dateTime:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    dateTime:SetSize(Vector2.new({ X = 760, Y = 42 }))
    dateTime:Reparent(self.contentCanvas, -1)

    local sidebar = ink.canvas(0, 300, inkEAnchor.TopLeft)
    sidebar:SetSize(Vector2.new({ X = 360, Y = 1030 }))
    sidebar:Reparent(self.contentCanvas, -1)
    local sidebarBg = ink.rect(0, 0, 360, 1030, color.brandPanel or color.panel)
    sidebarBg:SetOpacity(0.86)
    sidebarBg:Reparent(sidebar, -1)
    local divider = ink.rect(358, 0, 2, 1030, color.brandRed or color.red)
    divider:SetOpacity(0.34)
    divider:Reparent(sidebar, -1)

    local navY = 34
    local step = 82
    self:createHomeSidebarItem(sidebar, "Home", navY + (step * 0), function() self:renderPage("home") end, true)
    self:createHomeSidebarItem(sidebar, "Analytics", navY + (step * 1), function() self:renderPage("insights") end, false)
    self:createHomeSidebarItem(sidebar, "Services", navY + (step * 2), function() self:renderPage("services") end, false)
    self:createHomeSidebarItem(sidebar, "Disclosures", navY + (step * 3), function() self:renderPage("disclosures") end, false)
    self:createHomeSidebarItem(sidebar, "Logout", navY + (step * 4), function() self:logout() end, false)

end

function shell:formatCompactEddies(value)
    local n = math.max(tonumber(value) or 0, 0)
    if n >= 1000000000 then return string.format("E$ %.1fB", n / 1000000000) end
    if n >= 1000000 then return string.format("E$ %.1fM", n / 1000000) end
    if n >= 1000 then return string.format("E$ %.1fK", n / 1000) end
    return "E$ " .. utils.formatNumber(n)
end

function shell:drawHomeBalanceChart(parent, width, height, history)
    history = history or {}
    local series = history.points or {}
    if #series == 0 then
        local empty = ink.text("BALANCE HISTORY UNAVAILABLE", 40, 108, 30, color.dim)
        empty:SetSize(Vector2.new({ X = width - 80, Y = 48 }))
        empty:Reparent(parent, -1)
        return
    end

    local lo = 0
    local hi = 100000000

    local leftPad = 126
    local rightPad = 28
    local topPad = 58
    local bottomPad = 54
    local plotW = width - leftPad - rightPad
    local plotH = height - topPad - bottomPad

    for i = 0, 6 do
        local gx = leftPad + math.floor(plotW * (i / 6))
        local line = ink.rect(gx, topPad, 1, plotH, color.brandWhiteSoft or color.white)
        line:SetOpacity((i == 0 or i == 6) and 0.16 or 0.07)
        line:Reparent(parent, -1)
    end
    for i = 0, 4 do
        local gy = topPad + math.floor(plotH * (i / 4))
        local line = ink.rect(leftPad, gy, plotW, 1, color.brandWhiteSoft or color.white)
        line:SetOpacity((i == 0 or i == 4) and 0.16 or 0.08)
        line:Reparent(parent, -1)
        local value = hi - ((hi - lo) * (i / 4))
        local yLabel = ink.text(self:formatCompactEddies(value), 2, gy - 14, 24, color.dim)
        yLabel:SetSize(Vector2.new({ X = 118, Y = 34 }))
        yLabel:Reparent(parent, -1)
    end

    local change = tonumber(history.changePercent) or 0
    local changeLabel = history.changeAvailable == true and string.format("%+.2f%%", change) or "0.00%"
    local changeColor = color.dim
    if history.changeAvailable == true then
        if change > 0 then
            changeColor = color.riskGreen or color.green
        elseif change < 0 then
            changeColor = color.brandRedBright or color.red
        else
            changeColor = color.brandWhiteSoft or color.white
        end
    end
    local changeText = ink.text(changeLabel, width - 14, 0, 42, changeColor)
    changeText:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    changeText:SetSize(Vector2.new({ X = 280, Y = 46 }))
    changeText:Reparent(parent, -1)
    local coveredDays = math.max(math.floor(tonumber(history.daysCovered) or #series), 1)
    local comparison = "CHANGE OVER " .. tostring(coveredDays) .. " DAYS"
    if coveredDays <= 1 then comparison = "CURRENT BALANCE" end
    local compareText = ink.text(comparison, width - 14, 42, 24, color.dim)
    compareText:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    compareText:SetSize(Vector2.new({ X = 360, Y = 30 }))
    compareText:Reparent(parent, -1)

    if history.partial == true then
        local partial = ink.text("AVAILABLE BALANCE HISTORY", leftPad, 6, 23, color.dim)
        partial:SetSize(Vector2.new({ X = 420, Y = 28 }))
        partial:Reparent(parent, -1)
    else
        local period = ink.text("30-DAY COMBINED BALANCE", leftPad, 6, 23, color.dim)
        period:SetSize(Vector2.new({ X = 360, Y = 28 }))
        period:Reparent(parent, -1)
    end

    local plotted = {}
    for i, point in ipairs(series) do
        local px = leftPad
        if #series > 1 then px = leftPad + (((i - 1) / (#series - 1)) * plotW) end
        local normalized = ((tonumber(point.value) or 0) - lo) / math.max(hi - lo, 0.001)
        if normalized < 0 then normalized = 0 end
        if normalized > 1 then normalized = 1 end
        local py = topPad + ((1 - normalized) * plotH)
        plotted[i] = { x = px, y = py, day = point.day, value = point.value }

        local fillWidth = math.max(math.floor(plotW / math.max(#series, 1)), 2)
        local fill = ink.rect(px - (fillWidth / 2), py, fillWidth, math.max((topPad + plotH) - py, 1), color.brandRed or color.red)
        fill:SetOpacity(0.025)
        fill:Reparent(parent, -1)
    end

    for i = 1, #plotted - 1 do
        local ghost = ink.line(plotted[i].x, plotted[i].y, plotted[i + 1].x, plotted[i + 1].y, color.brandRed or color.red, 8)
        ghost:SetOpacity(0.13)
        ghost:Reparent(parent, -1)
    end
    for i = 1, #plotted - 1 do
        local line = ink.line(plotted[i].x, plotted[i].y, plotted[i + 1].x, plotted[i + 1].y, color.brandRedBright or color.red, 4)
        line:SetOpacity(0.96)
        line:Reparent(parent, -1)
    end

    for i, point in ipairs(plotted) do
        if i == 1 or i == #plotted or i % math.max(math.floor(#plotted / 8), 1) == 0 then
            local marker = ink.rect(point.x - 4, point.y - 4, 8, 8, color.brandRedBright or color.red)
            marker:SetOpacity(i == #plotted and 1.0 or 0.72)
            marker:Reparent(parent, -1)
        end
    end

    local calendarContext = Calendar.getContext()
    local labelIndexes = { 1, math.max(1, math.floor((#plotted + 2) / 3)), math.max(1, math.floor(((#plotted + 2) * 2) / 3)), #plotted }
    local seen = {}
    for _, index in ipairs(labelIndexes) do
        if plotted[index] and not seen[index] then
            seen[index] = true
            local dateLabel = Calendar.formatEngineDay(plotted[index].day or 0, calendarContext, true)
            local anchorX = 0.5
            if index == 1 then anchorX = 0.0 end
            if index == #plotted then anchorX = 1.0 end
            local label = ink.text(dateLabel, plotted[index].x, topPad + plotH + 12, 23, color.dim)
            label:SetAnchorPoint(Vector2.new({ X = anchorX, Y = 0.0 }))
            label:SetSize(Vector2.new({ X = 260, Y = 34 }))
            pcall(function() label:SetHorizontalAlignment(textHorizontalAlignment.Center) end)
            label:Reparent(parent, -1)
        end
    end
end

function shell:scheduleHomeBalanceChart(graphHost, width, height, data)
    local generation = math.floor(tonumber(self.homeGraphGeneration or 0) or 0)
    self.homeGraphToken = Cron.NextTick(function()
        self.homeGraphToken = nil
        if self.activePage ~= "home" or generation ~= math.floor(tonumber(self.homeGraphGeneration or 0) or 0) then return end

        local history = nil
        local okHistory = pcall(function()
            history = Bank:getHomeBalanceHistory(30, data.wallet or 0, data.bank or 0)
        end)
        pcall(function() graphHost:RemoveAllChildren() end)
        if okHistory and type(history) == "table" then
            local okDraw = pcall(function() self:drawHomeBalanceChart(graphHost, width, height, history) end)
            if okDraw then return end
        end
        local fallback = ink.text("BALANCE HISTORY UNAVAILABLE", 70, 112, 28, color.dim)
        fallback:SetSize(Vector2.new({ X = width - 140, Y = 44 }))
        fallback:Reparent(graphHost, -1)
    end)
end

function shell:createHomeActionButton(parent, iconText, labelText, x, y, w, h, callback)
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local bg = ink.image(w / 2, h / 2, w, h, ATLAS, "cell_bg", color.brandPanel2 or color.panel)
    bg.image.useNineSliceScale = true
    bg.image:SetOpacity(0.56)
    bg.pos:Reparent(holder, -1)
    local top = ink.rect(0, 0, w, 2, color.brandRed or color.red)
    top:SetOpacity(0.30)
    top:Reparent(holder, -1)
    local bottom = ink.rect(0, h - 2, w, 2, color.brandRed or color.red)
    bottom:SetOpacity(0.24)
    bottom:Reparent(holder, -1)

    local label = ink.text(labelText, w / 2, h / 2, 46, color.brandWhite or color.white)
    label:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    label:SetSize(Vector2.new({ X = w - 44, Y = h - 24 }))
    pcall(function() label:SetHorizontalAlignment(textHorizontalAlignment.Center) end)
    pcall(function() label:SetVerticalAlignment(textVerticalAlignment.Center) end)
    label:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)
    self:addSubscriber(hotspot, {
        hoverIn = function()
            bg.image:SetOpacity(0.76)
            top:SetOpacity(0.92)
            bottom:SetOpacity(0.64)
            label:SetTintColor(color.brandRedBright or color.red)
        end,
        hoverOut = function()
            bg.image:SetOpacity(0.56)
            top:SetOpacity(0.30)
            bottom:SetOpacity(0.24)
            label:SetTintColor(color.brandWhite or color.white)
        end,
        click = function()
            utils.playSound("ui_menu_onpress", 1)
            if callback then callback() end
        end,
    })
    return holder
end

function shell:drawHomeCircularProgress(parent, cx, cy, radius, percent, displayText, options)
    options = options or {}
    local segments = math.max(math.floor(tonumber(options.segments) or 64), 24)
    local backgroundThickness = tonumber(options.backgroundThickness) or 11
    local activeThickness = tonumber(options.activeThickness) or 14
    local backgroundTint = options.backgroundTint or color.brandWhiteSoft or color.white
    local activeTint = options.activeTint or color.brandRedBright or color.red
    local clamped = math.max(0, math.min(tonumber(percent) or 0, 100))

    local function drawArcSegment(index, tint, thickness, opacity)
        local a1 = ((index - 1) / segments) * math.pi * 2.0 - (math.pi / 2.0)
        local a2 = (index / segments) * math.pi * 2.0 - (math.pi / 2.0)
        local segment = ink.line(
            cx + (math.cos(a1) * radius),
            cy + (math.sin(a1) * radius),
            cx + (math.cos(a2) * radius),
            cy + (math.sin(a2) * radius),
            tint,
            thickness
        )
        segment:SetOpacity(opacity)
        segment:Reparent(parent, -1)
    end

    for i = 1, segments do
        drawArcSegment(i, backgroundTint, backgroundThickness, 0.16)
    end

    local activeCount = math.floor((segments * clamped / 100.0) + 0.5)
    for i = 1, activeCount do
        drawArcSegment(i, activeTint, activeThickness, 0.92)
    end

    local centerText = ink.text(displayText or string.format("%.0f%%", clamped), cx, cy, tonumber(options.fontSize) or 27, options.textTint or color.brandWhite or color.white)
    centerText:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    centerText:SetSize(Vector2.new({ X = radius * 1.55, Y = 58 }))
    pcall(function() centerText:SetHorizontalAlignment(textHorizontalAlignment.Center) end)
    pcall(function() centerText:SetVerticalAlignment(textVerticalAlignment.Center) end)
    centerText:Reparent(parent, -1)
end

function shell:drawHomeSecurityRow(parent, labelText, statusText, y)
    local marker = ink.text("+", 214, y - 2, 34, color.riskGreen or color.green)
    marker:SetSize(Vector2.new({ X = 40, Y = 40 }))
    marker:Reparent(parent, -1)
    local label = ink.text(labelText, 258, y, 30, color.dim)
    label:SetSize(Vector2.new({ X = 320, Y = 36 }))
    label:Reparent(parent, -1)
    local status = ink.text(statusText, 760, y, 30, color.riskGreen or color.green)
    status:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    status:SetSize(Vector2.new({ X = 180, Y = 36 }))
    status:Reparent(parent, -1)
end

function shell:buildHomePage()
    local data = self:getBankData()
    local cashback = data.cashback or {}
    local firstName = self:getPlayerSignatureName()
    local cashbackRate = self:formatCashbackRate(cashback.rateBp, cashback.ratePercent)
    local cashbackAmount = math.max(math.floor(tonumber(cashback.pendingEarned) or 0), 0)
    local destination = tostring(cashback.destinationLabel or "Checking")
    local daysLeft = tostring(cashback.daysLeftLabel or cashback.nextPayoutLabel or "Not scheduled")
    local calendarContext = Calendar.getContext()
    local nextPayoutDateTime = "Not scheduled"
    if math.floor(tonumber(cashback.nextPayoutStamp) or 0) > 0 then
        nextPayoutDateTime = Calendar.formatMinuteStamp(cashback.nextPayoutStamp, calendarContext, true)
    end

    local mainX = 410
    local mainW = 2460

    local welcome = ink.text("WELCOME BACK, " .. string.upper(firstName), mainX, 320, 66, color.brandWhite or color.white)
    welcome:SetSize(Vector2.new({ X = 1300, Y = 74 }))
    welcome:Reparent(self.contentCanvas, -1)
    local welcomeSub = ink.text("Good to see you again.", mainX + mainW - 720, 314, 29, color.dim)
    welcomeSub:SetSize(Vector2.new({ X = 720, Y = 38 }))
    pcall(function() welcomeSub:SetHorizontalAlignment(textHorizontalAlignment.Right) end)
    pcall(function() welcomeSub:SetVerticalAlignment(textVerticalAlignment.Center) end)
    welcomeSub:Reparent(self.contentCanvas, -1)
    local secureSession = ink.text("SECURE SESSION", mainX + mainW - 510, 354, 27, color.dim)
    secureSession:SetSize(Vector2.new({ X = 210, Y = 34 }))
    secureSession:Reparent(self.contentCanvas, -1)

    local secureDot = ink.rect(mainX + mainW - 284, 365, 10, 10, color.riskGreen or color.green)
    secureDot:SetOpacity(0.95)
    secureDot:Reparent(self.contentCanvas, -1)

    local operational = ink.text("ALL SYSTEMS OPERATIONAL", mainX + mainW - 258, 354, 27, color.dim)
    operational:SetSize(Vector2.new({ X = 258, Y = 34 }))
    operational:Reparent(self.contentCanvas, -1)

    local hero = self:makeHomePanel(self.contentCanvas, mainX, 430, mainW, 320, { opacity = 0.50, borderOpacity = 0.42 })
    local totalLabel = ink.text("TOTAL BALANCE", 56, 38, 34, color.dim)
    totalLabel:SetSize(Vector2.new({ X = 620, Y = 42 }))
    totalLabel:Reparent(hero, -1)
    local total = ink.text("E$ " .. utils.formatNumber(data.total or 0), 56, 82, 90, color.brandWhite or color.white)
    total:SetSize(Vector2.new({ X = 720, Y = 104 }))
    total:Reparent(hero, -1)
    local combined = ink.text("Checking + Savings", 58, 198, 31, color.dim)
    combined:SetSize(Vector2.new({ X = 520, Y = 38 }))
    combined:Reparent(hero, -1)
    local visible = ink.text("◉", 470, 194, 32, color.dim)
    visible:SetSize(Vector2.new({ X = 44, Y = 44 }))
    visible:Reparent(hero, -1)

    local graphHost = ink.canvas(780, 12, inkEAnchor.TopLeft)
    graphHost:SetSize(Vector2.new({ X = 1640, Y = 294 }))
    graphHost:Reparent(hero, -1)
    local loading = ink.text("LOADING BALANCE HISTORY...", 590, 128, 28, color.dim)
    loading:SetSize(Vector2.new({ X = 500, Y = 36 }))
    loading:Reparent(graphHost, -1)
    self:scheduleHomeBalanceChart(graphHost, 1640, 294, data)

    local actionY = 774
    local actionGap = 24
    local actionW = math.floor((mainW - (actionGap * 3)) / 4)
    self:createHomeActionButton(self.contentCanvas, "", "Deposit Funds", mainX, actionY, actionW, 132, function() self:renderPage("deposit") end)
    self:createHomeActionButton(self.contentCanvas, "", "Withdraw Funds", mainX + actionW + actionGap, actionY, actionW, 132, function() self:renderPage("withdraw") end)
    self:createHomeActionButton(self.contentCanvas, "", "Activity", mainX + ((actionW + actionGap) * 2), actionY, actionW, 132, function() self:renderPage("transactions") end)
    self:createHomeActionButton(self.contentCanvas, "", "View Loans", mainX + ((actionW + actionGap) * 3), actionY, actionW, 132, function() self:renderPage("loans") end)

    local lowerY = 930
    local lowerH = 322
    local leftW = 760
    local centerW = 850
    local rightW = mainW - leftW - centerW - 48

    local account = self:makeHomePanel(self.contentCanvas, mainX, lowerY, leftW, lowerH, { opacity = 0.52, borderOpacity = 0.34 })
    local accountTitle = ink.text("ACCOUNT OVERVIEW", 36, 20, 33, color.dim)
    accountTitle:SetSize(Vector2.new({ X = 520, Y = 40 }))
    accountTitle:Reparent(account, -1)
    local savingsShare = 0
    if (tonumber(data.total) or 0) > 0 then savingsShare = ((tonumber(data.bank) or 0) / (tonumber(data.total) or 1)) * 100 end
    self:drawHomeCircularProgress(account, 150, 160, 78, savingsShare, string.format("%.0f%%", savingsShare), {
        fontSize = 32,
        backgroundThickness = 12,
        activeThickness = 15,
    })
    local shareLabel = ink.text("SAVINGS SHARE", 150, 252, 24, color.dim)
    shareLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    shareLabel:SetSize(Vector2.new({ X = 240, Y = 32 }))
    pcall(function() shareLabel:SetHorizontalAlignment(textHorizontalAlignment.Center) end)
    shareLabel:Reparent(account, -1)
    local function drawHomeAccountMetric(labelText, valueText, rowY, valueTint)
        local labelWidget = ink.text(labelText, 320, rowY, 25, color.dim)
        labelWidget:SetSize(Vector2.new({ X = 390, Y = 32 }))
        pcall(function() labelWidget:SetHorizontalAlignment(textHorizontalAlignment.Left) end)
        pcall(function() labelWidget:SetVerticalAlignment(textVerticalAlignment.Center) end)
        labelWidget:Reparent(account, -1)

        local valueWidget = ink.text(valueText, 320, rowY + 36, 34, valueTint or color.brandWhite or color.white, nil, "Medium")
        valueWidget:SetSize(Vector2.new({ X = 390, Y = 48 }))
        pcall(function() valueWidget:SetWrapping(false) end)
        pcall(function() valueWidget:SetHorizontalAlignment(textHorizontalAlignment.Left) end)
        pcall(function() valueWidget:SetVerticalAlignment(textVerticalAlignment.Center) end)
        valueWidget:Reparent(account, -1)
    end

    drawHomeAccountMetric("Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 62, color.brandWhite or color.white)
    drawHomeAccountMetric("Savings", "E$ " .. utils.formatNumber(data.bank or 0), 146, color.brandWhite or color.white)
    drawHomeAccountMetric("Total", "E$ " .. utils.formatNumber(data.total or 0), 230, color.brandRedBright or color.red)

    local cashbackPanel = self:makeHomePanel(self.contentCanvas, mainX + leftW + 24, lowerY, centerW, lowerH, { opacity = 0.52, borderOpacity = 0.34 })
    local cbTitle = ink.text("CASHBACK STATUS", 36, 20, 33, color.dim)
    cbTitle:SetSize(Vector2.new({ X = 400, Y = 40 }))
    cbTitle:Reparent(cashbackPanel, -1)
    local rate = ink.text(cashbackRate, 36, 62, 66, color.brandRedBright or color.red)
    rate:SetSize(Vector2.new({ X = 330, Y = 76 }))
    rate:Reparent(cashbackPanel, -1)
    local weekly = ink.text("Weekly rewards paid to " .. destination, 38, 132, 31, color.dim)
    weekly:SetSize(Vector2.new({ X = 430, Y = 40 }))
    weekly:Reparent(cashbackPanel, -1)
    local cashbackPercentValue = tonumber(cashback.ratePercent)
    if cashbackPercentValue == nil then cashbackPercentValue = (tonumber(cashback.rateBp) or 0) / 100.0 end
    self:drawHomeCircularProgress(cashbackPanel, 712, 108, 62, cashbackPercentValue, cashbackRate, {
        fontSize = 25,
        backgroundThickness = 10,
        activeThickness = 13,
        textTint = color.brandRedBright or color.red,
    })
    local cbRule = ink.rect(36, 176, 778, 2, color.brandWhite or color.white)
    cbRule:SetOpacity(0.10)
    cbRule:Reparent(cashbackPanel, -1)
    self:drawKV(cashbackPanel, "Cashback Balance", "E$ " .. utils.formatNumber(cashbackAmount), 36, 190, color.brandWhite or color.white, 360, 38, 31)
    self:drawKV(cashbackPanel, "Pays to", destination, 520, 190, color.brandWhite or color.white, 280, 38, 31)
    local payout = ink.text("NEXT PAYOUT  " .. nextPayoutDateTime, 388, 282, 25, color.dim)
    payout:SetSize(Vector2.new({ X = 430, Y = 34 }))
    payout:Reparent(cashbackPanel, -1)
    local remaining = ink.text(daysLeft, 36, 282, 26, color.brandRedBright or color.red)
    remaining:SetSize(Vector2.new({ X = 330, Y = 34 }))
    remaining:Reparent(cashbackPanel, -1)

    local security = self:makeHomePanel(self.contentCanvas, mainX + leftW + centerW + 48, lowerY, rightW, lowerH, { opacity = 0.52, borderOpacity = 0.34 })
    local securityTitle = ink.text("SECURITY STATUS", 36, 20, 33, color.dim)
    securityTitle:SetSize(Vector2.new({ X = 500, Y = 40 }))
    securityTitle:Reparent(security, -1)
    local shield = ink.text("◇", 36, 72, 126, color.brandRedBright or color.red)
    shield:SetSize(Vector2.new({ X = 150, Y = 150 }))
    shield:Reparent(security, -1)
    local lock = ink.text("SECURED", 54, 138, 29, color.brandWhite or color.white)
    lock:SetSize(Vector2.new({ X = 120, Y = 34 }))
    lock:Reparent(security, -1)
    self:drawHomeSecurityRow(security, "Login Security", "Active", 76)
    self:drawHomeSecurityRow(security, "Device Status", "Active", 130)
    self:drawHomeSecurityRow(security, "Account Protection", "Active", 184)
    self:drawHomeSecurityRow(security, "All Systems", "Secure", 238)

    local footer = ink.text("© 2077 MARMUR BANK. ALL RIGHTS RESERVED.", mainX + (mainW / 2), 1280, 24, color.dim)
    footer:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.0 }))
    footer:SetSize(Vector2.new({ X = 760, Y = 30 }))
    footer:Reparent(self.contentCanvas, -1)
end


function shell:getSpendSubjectLabel(subjectCode)
    local labels = {
        [0] = "Uncategorized Purchase",
        [1] = "Food & Drinks",
        [2] = "Clothing",
        [3] = "Cyberware",
        [4] = "Weapons & Ammo",
        [5] = "Medical Supplies",
        [6] = "Quickhacks & Software",
        [7] = "Crafting & Upgrades",
        [8] = "Vehicles",
        [9] = "Insurance",
        [10] = "Real Estate",
        [11] = "Public Transportation",
        [12] = "Loan Payment",
        [13] = "Account Service",
        [14] = "Entertainment",
        [15] = "Other Purchase",
    }
    return labels[math.max(0, math.min(math.floor(tonumber(subjectCode) or 0), 15))] or labels[0]
end

function shell:getTransactionLabel(txType, subjectCode)
    txType = tonumber(txType) or 0
    if txType == 4 or txType == 27 then return self:getSpendSubjectLabel(subjectCode) end
    local labels = {
        [1] = "Deposit",
        [2] = "Withdrawal",
        [3] = "Interest Credit",
        [4] = "Checking Purchase",
        [5] = "Ledger Sync",
        [6] = "Loan Approval",
        [7] = "Loan Payment",
        [8] = "Auto Loan Debit",
        [9] = "Missed Loan Payment",
        [10] = "Fraud Alert",
        [12] = "Checking Fee",
        [13] = "Dispute Claim",
        [14] = "Private Client Fee",
        [15] = "Theft Protection",
        [16] = "Dispute Credit",
        [17] = "Dispute Denial",
        [18] = "Dispute Cooldown",
        [19] = "Review Complete",
        [20] = "Cashback Payout",
        [21] = "Partner Transfer Out",
        [22] = "Partner Transfer Out",
        [23] = "Partner Transfer In",
        [24] = "Partner Transfer In",
    }
    return labels[txType] or "Transaction"
end

function shell:getTransactionColor(txType, disputeStatus)
    txType = tonumber(txType) or 0
    if txType == 1 or txType == 3 or txType == 6 or txType == 16 or txType == 19 or txType == 20 or txType == 23 or txType == 24 then return color.green end
    if txType == 2 or txType == 7 or txType == 8 or txType == 12 or txType == 14 or txType == 21 or txType == 22 or txType == 27 then return color.gold end
    if txType == 15 then return color.green end
    if txType == 4 then
        local dispute = tonumber(disputeStatus) or 0
        if dispute == 3 then return color.gold end
        if dispute == 4 then return color.green end
        if dispute == 5 then return color.red end
        return color.white
    end
    if txType == 10 or txType == 13 or txType == 17 or txType == 18 then return color.red end
    return color.cyan
end

function shell:getTransactionAmountColor(txType, disputeStatus)
    txType = tonumber(txType) or 0
    if txType == 1 or txType == 3 or txType == 6 or txType == 16 or txType == 20 or txType == 23 or txType == 24 then return color.green end
    if txType == 18 or txType == 19 then return color.dim end
    if txType == 4 then return color.white end
    if txType == 15 then return color.green end
    if txType == 10 or txType == 13 or txType == 17 then return color.red end
    if txType == 2 or txType == 7 or txType == 8 or txType == 12 or txType == 14 or txType == 21 or txType == 22 or txType == 27 then return color.white end
    return self:getTransactionColor(txType, disputeStatus)
end

function shell:shortenTransactionText(text)
    local s = tostring(text or "")
    s = s:gsub("Marmur Bank ", "")
    s = s:gsub("confirmation — ", "")
    s = s:gsub("alert — ", "")
    s = s:gsub("account notice — ", "")
    if #s > 96 then
        s = s:sub(1, 93) .. "..."
    end
    return s
end

function shell:getTransactionChannel(txType, source)
    txType = tonumber(txType) or 0
    local src = tostring(source or "")
    if txType == 15 then return "Security" end
    if txType == 20 then return "Rewards" end
    if txType == 21 or txType == 22 or txType == 23 or txType == 24 then return "Partners" end
    if txType == 27 then return "External" end
    if src == "wallet_fallback" or txType == 4 or txType == 10 then return "Checking" end
    if txType == 1 or txType == 2 then return "Website" end
    if txType == 6 or txType == 7 or txType == 8 or txType == 9 then return "Loans" end
    if txType == 13 or txType == 16 or txType == 17 or txType == 18 or txType == 19 then return "Claims" end
    if txType == 14 then return "Services" end
    return "Savings"
end

function shell:getTransactionSignedAmount(txType, amount)
    txType = tonumber(txType) or 0
    amount = tonumber(amount) or 0
    local formatted = "E$ " .. utils.formatNumber(amount)
    if txType == 18 or txType == 19 then return "—" end
    if txType == 1 or txType == 3 or txType == 6 or txType == 16 or txType == 20 or txType == 23 or txType == 24 then return "+" .. formatted end
    if txType == 15 then return "+" .. formatted end
    if txType == 4 or txType == 7 or txType == 8 or txType == 12 or txType == 14 or txType == 21 or txType == 22 or txType == 27 then return "-" .. formatted end
    if txType == 2 then return "±" .. formatted end
    if txType == 9 or txType == 10 or txType == 13 or txType == 17 then return formatted end
    return formatted
end

function shell:getTransactionStatus(txType, row)
    txType = tonumber(txType) or 0
    if txType == 4 then
        local dispute = tonumber(row.disputeStatus) or 0
        if dispute == 3 then return "IN REVIEW" end
        if dispute == 4 then return "CREDITED" end
        if dispute == 5 then return "DENIED" end
        if row.disputeHiddenByCooldown == true then return "PAUSED" end
        if row.disputable == true then return "DISPUTABLE" end
        return "CLEARED"
    end
    if txType == 10 then return "ALERT" end
    if txType == 15 then return "RESTORED" end
    if txType == 13 then return "SUBMITTED" end
    if txType == 16 then return "APPROVED" end
    if txType == 17 then return "DENIED" end
    if txType == 18 then return "COOLDOWN" end
    if txType == 19 then return "AVAILABLE" end
    if txType == 20 then return "REWARDED" end
    if txType == 21 or txType == 22 or txType == 23 or txType == 24 then return "TRANSFER" end
    if txType == 9 then return "MISSED" end
    return "POSTED"
end

function shell:getTransactionCashbackAmount(row)
    return math.max(math.floor(tonumber((row or {}).cashbackEarned) or 0), 0)
end

function shell:getTransactionCashbackSuffix(row)
    local reward = self:getTransactionCashbackAmount(row)
    if reward <= 0 then return "" end
    return " Cashback earned: E$ " .. utils.formatNumber(reward) .. "."
end

function shell:getTransactionActivitySummary(row)
    row = row or {}
    local txType = tonumber(row.type) or 0
    if txType == 4 then
        local dispute = tonumber(row.disputeStatus) or 0
        if dispute == 3 then return "Claim submitted for review." end
        if dispute == 4 then return "Claim approved; checking credited." end
        if dispute == 5 then return "Claim denied; no credit issued." end
        if tonumber(row.fragmentCount or 0) > 1 then return "Combined checking debits." end
        local subject = math.max(0, math.min(math.floor(tonumber(row.subject) or 0), 15))
        if subject <= 0 then return "Purchase source unavailable." end
        return self:getSpendSubjectLabel(subject) .. " purchase."
    end
    if txType == 7 then return "Manual loan repayment posted." end
    if txType == 8 then return "Scheduled loan payment posted." end
    return self:getTransactionSummary(row)
end

function shell:getTransactionSummary(row)
    local txType = tonumber(row.type) or 0
    if txType == 1 then return "Website deposit moved checking funds into savings." end
    if txType == 2 then return "Website withdrawal moved savings funds back to checking." end
    if txType == 3 then return "Daily account yield credited after tax." end
    if txType == 4 then
        local dispute = tonumber(row.disputeStatus) or 0
        if dispute == 3 then return "Claim submitted; Marmur Bank Claims is reviewing it." .. self:getTransactionCashbackSuffix(row) end
        if dispute == 4 then return "Claim approved and credited back to checking." .. self:getTransactionCashbackSuffix(row) end
        if dispute == 5 then return "Claim denied after review; no credit issued." .. self:getTransactionCashbackSuffix(row) end
        if tonumber(row.fragmentCount or 0) > 1 then return "Combined checking debits." .. self:getTransactionCashbackSuffix(row) end
        local subject = math.max(0, math.min(math.floor(tonumber(row.subject) or 0), 15))
        if subject <= 0 then return "Purchase source unavailable." .. self:getTransactionCashbackSuffix(row) end
        return self:getSpendSubjectLabel(subject) .. " purchase." .. self:getTransactionCashbackSuffix(row)
    end
    if txType == 5 then return "Existing Marmur balance imported into the secure ledger." end
    if txType == 6 then return "Loan principal disbursed to checking." end
    if txType == 7 then return "Manual loan repayment posted." .. self:getTransactionCashbackSuffix(row) end
    if txType == 8 then return "Scheduled loan payment auto-debited." .. self:getTransactionCashbackSuffix(row) end
    if txType == 9 then return "Scheduled loan payment missed due to funds." end
    if txType == 10 then return "High-value checking activity flagged for review." end
    if txType == 12 then return "Checking monthly fee charged." end
    if txType == 13 then return "Dispute received and queued for claims review." end
    if txType == 14 then return "Private client custody and account monitoring fee posted." end
    if txType == 15 then return "Theft detected; account holder notified before stolen funds are restored." end
    if txType == 16 then return "Approved dispute credited back to checking." end
    if txType == 17 then return "Dispute closed without a credit." end
    if txType == 18 then return "Temporary dispute cooldown applied; other services remain active." end
    if txType == 19 then return "Cooldown lifted; disputes are available again." end
    if txType == 20 then return "Weekly cashback payout credited from eligible spending and loan payments." end
    if txType == 21 then return "Checking funds moved to an external partner account." end
    if txType == 22 then return "Savings funds moved to an external partner account." end
    if txType == 23 then return "External partner funds posted to checking." end
    if txType == 24 then return "External partner funds posted to savings." end
    if txType == 27 then return self:getSpendSubjectLabel(row.subject) .. " expense posted from a linked account." end
    return self:shortenTransactionText(row.text)
end

function shell:setTransactionPage(delta, maxPage)
    self.transactionPage = math.max(1, math.min((tonumber(self.transactionPage) or 1) + delta, math.max(1, tonumber(maxPage) or 1)))
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage("transactions")
end

function shell:normalizeTransactionSortMode(mode)
    mode = tostring(mode or "recent"):lower()
    if mode == "highest" or mode == "lowest" or mode == "oldest" or mode == "recent" then
        return mode
    end
    return "recent"
end

function shell:getTransactionSortLabel(mode)
    mode = self:normalizeTransactionSortMode(mode or self.transactionSortMode)
    if mode == "highest" then return "Highest First" end
    if mode == "lowest" then return "Lowest First" end
    if mode == "oldest" then return "Oldest First" end
    return "Most Recent"
end

function shell:getTransactionSortButtonLabel(mode)
    mode = self:normalizeTransactionSortMode(mode or self.transactionSortMode)
    if mode == "highest" then return "Highest" end
    if mode == "lowest" then return "Lowest" end
    if mode == "oldest" then return "Oldest" end
    return "Most Recent"
end

function shell:setTransactionSortMode(mode)
    self.transactionSortMode = self:normalizeTransactionSortMode(mode)
    self.transactionPage = 1
    self:renderPage("transactions")
end

function shell:cycleTransactionSortMode()
    local current = self:normalizeTransactionSortMode(self.transactionSortMode)
    if current == "recent" then
        self:setTransactionSortMode("highest")
    elseif current == "highest" then
        self:setTransactionSortMode("lowest")
    elseif current == "lowest" then
        self:setTransactionSortMode("oldest")
    else
        self:setTransactionSortMode("recent")
    end
end

function shell:cloneDisputeIndex(index)
    if type(index) == "table" then
        local copy = {}
        for _, value in ipairs(index) do table.insert(copy, value) end
        return copy
    end
    return index
end

function shell:beginDispute(row)
    row = row or {}
    local cooldown = self:getDisputeCooldownSummary()
    if cooldown.active == true then
        self.disputeTarget = nil
        self.disputeSelectedReason = 0
        self.disputeSubmitError = tostring(cooldown.text or "Disputes are temporarily unavailable.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("transactions")
        return
    end
    self.disputeTarget = {
        index = self:cloneDisputeIndex(row.index),
        amount = math.floor(tonumber(row.amount) or 0),
        timestamp = tostring(row.timestamp or ""),
        day = math.floor(tonumber(row.day) or -1),
        hour = math.floor(tonumber(row.hour) or 0),
        minute = math.floor(tonumber(row.minute) or 0),
        label = self:getTransactionLabel(row.type, row.subject),
        summary = self:getTransactionSummary(row),
        channel = self:getTransactionChannel(row.type, row.source),
    }
    self.disputeSelectedReason = 0
    self.disputeSubmitError = ""
    self.lastDisputeCase = nil
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage("dispute")
end

function shell:selectDisputeReason(reasonCode)
    self.disputeSelectedReason = math.floor(tonumber(reasonCode) or 0)
    self.disputeSubmitError = ""
    self:renderPage("dispute")
end

function shell:submitDisputeFlow()
    local target = self.disputeTarget or {}
    local cooldown = self:getDisputeCooldownSummary()
    if cooldown.active == true then
        self.disputeSubmitError = tostring(cooldown.text or "Disputes are temporarily unavailable.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("dispute")
        return
    end
    local reasonCode = math.floor(tonumber(self.disputeSelectedReason) or 0)
    if reasonCode <= 0 then
        self.disputeSubmitError = "Select the reason that best matches this dispute."
        self:renderPage("dispute")
        return
    end

    local result = nil
    pcall(function()
        result = Bank:submitDisputeClaim(target.index, reasonCode, target.amount)
    end)

    if type(result) == "table" and result.ok == true then
        self.lastDisputeCase = result
        self.disputeSubmitError = ""
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("disputeconfirm")
        return
    end

    if type(result) == "table" and result.message then
        self.disputeSubmitError = tostring(result.message)
    else
        self.disputeSubmitError = "Marmur Bank could not submit this dispute. Review the transaction and try again."
    end
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage("dispute")
end

function shell:getDisputeCooldownSummary()
    local summary = { active = false, text = "Disputes available", remainingMinutes = 0 }
    pcall(function()
        summary = Bank:getDisputeStatusSummary() or summary
    end)
    return summary
end

function shell:buildDisputePage()
    local target = self.disputeTarget
    local data = self:getBankData()
    local cooldown = self:getDisputeCooldownSummary()

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local title = ink.text("DISPUTE A TRANSACTION", 40, 24, 50, color.brandRedBright or color.red)
    title:Reparent(strip, -1)
    local subtitle = ink.text("Review the posted purchase, select one reason, and submit it to Marmur Claims.", 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 1880, 30, color.white, 390, 24, 36)
    self:drawHeaderStat(strip, "Claim Access", cooldown.active == true and "TEMPORARILY PAUSED" or "AVAILABLE", 2290, 30, cooldown.active == true and color.red or (color.riskGreen or color.white), 470, 22, 32)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1740, 680)
    local right = self:makePanel(self.contentCanvas, 1850, 650, 1030, 680)

    if cooldown.active == true then
        local lh = ink.text("CLAIM ACCESS PAUSED", 38, 24, 43, color.gold)
        lh:Reparent(left, -1)
        local copy = ink.text("Recent dispute activity placed this account into a temporary review period. Deposits, withdrawals, loans, and all other banking services remain available.", 40, 88, 29, color.white)
        copy:SetWrapping(true)
        copy:SetSize(Vector2.new({ X = 1640, Y = 118 }))
        copy:Reparent(left, -1)
        self:drawPolishedRow(left, "Current Status", "New claims unavailable", 238, { x = 40, width = 1640, labelWidth = 500, valueColor = color.red })
        self:drawPolishedRow(left, "Review Period", tostring(cooldown.text or "Temporarily unavailable"), 304, { x = 40, width = 1640, labelWidth = 500, valueColor = color.gold })
        self:drawPolishedRow(left, "Existing Claims", "Continue through secure messages", 370, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white })
        local note = self:makePanel(left, 40, 472, 1640, 142)
        local noteText = ink.text("The dispute button will return automatically when the review period expires. No loan or account-level penalty is applied by this claim cooldown.", 26, 20, 27, color.dim)
        noteText:SetWrapping(true)
        noteText:SetSize(Vector2.new({ X = 1580, Y = 96 }))
        noteText:Reparent(note, -1)

        local rh = ink.text("NEXT ACTION", 38, 24, 43, color.cyan)
        rh:Reparent(right, -1)
        local rcopy = ink.text("Return to Activity to review the transaction ledger or continue banking from Home.", 40, 88, 28, color.dim)
        rcopy:SetWrapping(true)
        rcopy:SetSize(Vector2.new({ X = 930, Y = 100 }))
        rcopy:Reparent(right, -1)
        self:createTransferAction(right, "BACK TO ACTIVITY", 40, 236, 950, 92, function() self:renderPage("transactions") end, true)
        self:createTransferKey(right, "BACK TO HOME", 40, 366, 950, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        self:createTransferKey(right, "OPEN SECURE MESSAGES", 40, 482, 950, 78, nil, { static = false, borderColor = color.dim, textColor = color.dim, fontSize = 27 })
        return
    end

    if not target or not target.index then
        local lh = ink.text("NO TRANSACTION SELECTED", 38, 24, 43, color.gold)
        lh:Reparent(left, -1)
        local copy = ink.text("Choose an eligible purchase from Activity before opening the Dispute Center.", 40, 94, 31, color.white)
        copy:SetWrapping(true)
        copy:SetSize(Vector2.new({ X = 1600, Y = 96 }))
        copy:Reparent(left, -1)
        self:drawPolishedRow(left, "Required Step", "Activity → Select Purchase → Dispute", 244, { x = 40, width = 1640, labelWidth = 460, valueColor = color.cyan, drawLine = false })

        local rh = ink.text("NEXT ACTION", 38, 24, 43, color.cyan)
        rh:Reparent(right, -1)
        self:createTransferAction(right, "OPEN ACTIVITY", 40, 150, 950, 92, function() self:renderPage("transactions") end, true)
        self:createTransferKey(right, "BACK TO HOME", 40, 282, 950, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        return
    end

    local postedDateTime = Calendar.formatEngineDateTime(target.day, target.hour, target.minute, Calendar.getContext(), true)
    if math.floor(tonumber(target.day) or -1) < 0 then postedDateTime = tostring(target.timestamp or "Date unavailable") end

    local lh = ink.text("TRANSACTION UNDER REVIEW", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    self:drawPolishedRow(left, "Disputed Amount", "E$ " .. utils.formatNumber(target.amount or 0), 92, { x = 40, width = 1640, labelWidth = 500, valueColor = color.gold, valueFontSize = 34 })
    self:drawPolishedRow(left, "Description", tostring(target.label or "Checking Purchase"), 158, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white })
    self:drawPolishedRow(left, "Posted", postedDateTime, 224, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white, valueFontSize = 27 })
    self:drawPolishedRow(left, "Channel", tostring(target.channel or "Checking"), 290, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white })
    self:drawPolishedRow(left, "Eligibility", "AVAILABLE FOR REVIEW", 356, { x = 40, width = 1640, labelWidth = 500, valueColor = color.riskGreen or color.white })

    local reasons = {}
    pcall(function() reasons = Bank:getDisputeReasons() or {} end)
    local selected = math.floor(tonumber(self.disputeSelectedReason) or 0)
    local selectedDetail = "Select the reason that most accurately describes the problem."
    local selectedLabel = "No reason selected"
    for _, reason in ipairs(reasons) do
        if selected == math.floor(tonumber(reason.code) or 0) then
            selectedDetail = tostring(reason.detail or selectedDetail)
            selectedLabel = tostring(reason.label or selectedLabel)
            break
        end
    end

    local selectedPanel = self:makePanel(left, 40, 454, 1640, 166)
    local selectedHead = ink.text("SELECTED REASON", 26, 16, 23, color.dim)
    selectedHead:Reparent(selectedPanel, -1)
    local selectedName = ink.text(selectedLabel, 26, 50, 30, selected > 0 and color.brandRedBright or color.dim)
    selectedName:SetWrapping(true)
    selectedName:SetSize(Vector2.new({ X = 1580, Y = 42 }))
    selectedName:Reparent(selectedPanel, -1)
    local selectedCopy = ink.text(selectedDetail, 26, 94, 24, selected > 0 and color.white or color.dim)
    selectedCopy:SetWrapping(true)
    selectedCopy:SetSize(Vector2.new({ X = 1580, Y = 60 }))
    selectedCopy:Reparent(selectedPanel, -1)

    local rh = ink.text("SELECT A REASON", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    local startY = 78
    for i, reason in ipairs(reasons) do
        local active = selected == math.floor(tonumber(reason.code) or 0)
        self:createTransferKey(right, tostring(reason.label or "Reason"), 40, startY + ((i - 1) * 62), 950, 52, function() self:selectDisputeReason(reason.code) end, {
            borderColor = active and (color.brandRedBright or color.red) or color.dim,
            textColor = active and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 22,
            fillOpacity = active and 0.72 or 0.44,
        })
    end

    local errorText = tostring(self.disputeSubmitError or "")
    if #errorText > 0 then
        local err = ink.text(errorText, 40, 520, 23, color.red)
        err:SetWrapping(true)
        err:SetSize(Vector2.new({ X = 950, Y = 48 }))
        err:Reparent(right, -1)
    end

    self:createTransferKey(right, "BACK", 40, 598, 280, 58, function() self:renderPage("transactions") end, { borderColor = color.dim, textColor = color.white, fontSize = 25 })
    self:createTransferAction(right, "SUBMIT CLAIM", 340, 598, 650, 58, function() self:submitDisputeFlow() end, selected > 0)
end

function shell:buildDisputeSubmittedPage()
    local target = self.disputeTarget or {}
    local result = self.lastDisputeCase or {}
    local amount = tonumber(result.amount or target.amount or 0) or 0
    local reasonLabel = tostring(result.reasonLabel or "Transaction review requested")
    local caseId = tostring(result.caseId or "Pending")
    local decisionDateTime = tostring(result.dueText or "Within 24 hours")
    if math.floor(tonumber(result.dueStamp) or 0) > 0 then
        decisionDateTime = Calendar.formatMinuteStamp(result.dueStamp, Calendar.getContext(), true)
    end

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local title = ink.text("CLAIM SUBMITTED", 40, 24, 50, color.riskGreen or color.white)
    title:Reparent(strip, -1)
    local subtitle = ink.text("Marmur Claims received the dispute and added the case to secure messages.", 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Amount", "E$ " .. utils.formatNumber(amount), 1940, 30, color.gold, 390, 24, 36)
    self:drawHeaderStat(strip, "Status", "UNDER REVIEW", 2360, 30, color.cyan, 390, 24, 34)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1740, 650)
    local right = self:makePanel(self.contentCanvas, 1850, 650, 1030, 650)

    local lh = ink.text("CLAIM RECEIPT", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    self:drawPolishedRow(left, "Case ID", caseId, 94, { x = 40, width = 1640, labelWidth = 500, valueColor = color.cyan })
    self:drawPolishedRow(left, "Disputed Amount", "E$ " .. utils.formatNumber(amount), 160, { x = 40, width = 1640, labelWidth = 500, valueColor = color.gold, valueFontSize = 34 })
    self:drawPolishedRow(left, "Reason", reasonLabel, 226, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white, valueFontSize = 27 })
    self:drawPolishedRow(left, "Claim Status", "UNDER REVIEW", 292, { x = 40, width = 1640, labelWidth = 500, valueColor = color.riskGreen or color.white })
    self:drawPolishedRow(left, "Expected Decision", decisionDateTime, 358, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white, valueFontSize = 27 })
    self:drawPolishedRow(left, "Approved Credit", "Posts to Checking", 424, { x = 40, width = 1640, labelWidth = 500, valueColor = color.white })

    local note = self:makePanel(left, 40, 512, 1640, 102)
    local noteText = "No provisional credit is issued while the case is under review. Marmur will post an approved credit automatically and record the final decision in Activity."
    if result.flagged == true then
        noteText = noteText .. " New disputes are temporarily paused; all other account services remain available."
    end
    local nt = ink.text(noteText, 26, 16, 24, color.dim)
    nt:SetWrapping(true)
    nt:SetSize(Vector2.new({ X = 1580, Y = 72 }))
    nt:Reparent(note, -1)

    local rh = ink.text("NEXT ACTION", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    local copy = ink.text("The claim is now in review. Continue to Activity or return to the account overview.", 40, 88, 28, color.dim)
    copy:SetWrapping(true)
    copy:SetSize(Vector2.new({ X = 930, Y = 94 }))
    copy:Reparent(right, -1)
    self:createTransferAction(right, "BACK TO ACTIVITY", 40, 220, 950, 92, function() self:renderPage("transactions") end, true)
    self:createTransferKey(right, "BACK TO HOME", 40, 350, 950, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
    self:createTransferKey(right, "OPEN SERVICES", 40, 466, 950, 78, function() self:renderPage("services") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
end

function shell:cycleInsightsPeriod()
    local days = tonumber(self.insightsPeriodDays) or 30
    if days == 7 then
        days = 30
    elseif days == 30 then
        days = 90
    else
        days = 7
    end
    self.insightsPeriodDays = days
    self.insightsPeriodOffset = 0
    self.insightsCategoryPage = 1
    self:renderPage("insights")
end

function shell:setInsightsPeriodOffset(delta, maxPeriods)
    local maxOffset = math.max((tonumber(maxPeriods) or 1) - 1, 0)
    self.insightsPeriodOffset = math.max(0, math.min((tonumber(self.insightsPeriodOffset) or 0) + (tonumber(delta) or 0), maxOffset))
    self.insightsCategoryPage = 1
    self:renderPage("insights")
end

function shell:setInsightsCategoryPage(delta, maxPages)
    local pageCount = math.max(math.floor(tonumber(maxPages) or 1), 1)
    self.insightsCategoryPage = math.max(1, math.min((tonumber(self.insightsCategoryPage) or 1) + (tonumber(delta) or 0), pageCount))
    self:renderPage("insights")
end

function shell:getInsightsDeltaColor(delta)
    local direction = tostring((delta or {}).direction or "flat")
    if direction == "down" then return color.riskGreen or color.green end
    if direction == "up" or direction == "new" then return color.brandRedBright or color.red end
    return color.dim
end

function shell:formatInsightsDelta(delta, compact, periodDays)
    delta = delta or {}
    local direction = tostring(delta.direction or "flat")
    local label = tostring(delta.label or "--")
    local marker = delta.partial == true and "*" or ""
    if delta.partial == true then
        return compact == true and "--*" or "Comparison unavailable*"
    end
    if compact == true then
        if direction == "up" then return "+" .. label .. marker end
        if direction == "down" then return "-" .. label .. marker end
        return label .. marker
    end

    local suffix = " vs previous " .. tostring(tonumber(periodDays) or 30) .. " days"
    if delta.partial == true then suffix = suffix .. " (partial history)" end
    if direction == "up" then return "+" .. label .. suffix end
    if direction == "down" then return "-" .. label .. suffix end
    if direction == "new" then return "NEW" .. suffix end
    return "No change" .. suffix
end

function shell:scheduleInsightsRefresh()
    self:clearInsightsRefreshTimer()
    if self.activePage ~= "insights" or self.isLoggedIn ~= true then return end
    self.insightsRefreshToken = Cron.After(2.0, function()
        self.insightsRefreshToken = nil
        if self.activePage ~= "insights" or self.isLoggedIn ~= true then return end
        local revision = nil
        local ok = pcall(function()
            revision = Bank:getAnalyticsRevision()
        end)
        if ok == true and revision ~= nil and tostring(revision) ~= tostring(self.insightsSnapshotRevision or "") then
            self:renderPage("insights")
            return
        end
        self:scheduleInsightsRefresh()
    end)
end

function shell:buildInsightsPage()
    local data = nil
    local insightsOk, insightsError = pcall(function()
        data = Bank:getSpendingInsights(self.insightsPeriodDays, self.insightsPeriodOffset)
    end)
    if insightsOk ~= true then
        print("[Marmur Bank] Analytics unavailable: " .. tostring(insightsError or "unknown error"))
    end
    if type(data) ~= "table" then
        data = {
            periodDays = tonumber(self.insightsPeriodDays) or 30,
            periodOffset = 0,
            maxPeriods = 1,
            rangeLabel = "Posted history unavailable",
            total = 0,
            previousTotal = 0,
            totalDelta = { direction = "flat", label = "--" },
            transactionCount = 0,
            categories = {},
            historyUnavailable = true,
        }
    end

    self.insightsPeriodDays = tonumber(data.periodDays) or 30
    self.insightsPeriodOffset = tonumber(data.periodOffset) or 0
    self.insightsSnapshotRevision = tostring(data.revision or "")

    local function text(parent, value, x, y, size, tint, width, height, wrapping)
        local widget = ink.text(tostring(value or ""), x, y, size, tint or color.white)
        if width then widget:SetSize(Vector2.new({ X = width, Y = height or (size + 20) })) end
        if wrapping == true then widget:SetWrapping(true) end
        widget:Reparent(parent, -1)
        return widget
    end

    local function divider(parent, x, y, width, opacity)
        local line = ink.rect(x, y, width, 2, color.brandWhite or color.white)
        line:SetOpacity(opacity or 0.12)
        line:Reparent(parent, -1)
        return line
    end

    local intro = self:makePanel(self.contentCanvas, 80, 470, 1640, 176)
    text(intro, "SPENDING ANALYTICS", 34, 16, 50, color.brandWhite or color.white, 620, 62)
    text(intro, "Understand where your money goes.", 36, 88, 28, color.dim, 620, 46)

    text(intro, "REPORTING PERIOD", 720, 18, 24, color.brandRedBright or color.red, 400, 34)
    local periodLabel = self.insightsPeriodOffset == 0
        and ("Last " .. tostring(self.insightsPeriodDays) .. " Days")
        or (tostring(self.insightsPeriodDays) .. "-Day Period")
    self:createButton(intro, periodLabel, 680, 58, 430, 72, function() self:cycleInsightsPeriod() end, { fgColor = color.white, hoverColor = color.brandRedBright or color.red, fontSize = 32 })

    text(intro, "TRACKED RANGE", 1160, 18, 24, color.brandRedBright or color.red, 420, 34)
    text(intro, data.rangeLabel or "", 1160, 56, 34, color.white, 430, 44)
    local rangeStatus = "Posted transaction history"
    local rangeStatusColor = color.dim
    if data.historyUnavailable == true then
        rangeStatus = "History unavailable"
        rangeStatusColor = color.brandRedBright or color.red
    elseif data.partial == true then
        rangeStatus = "Partial history: earlier outflows may be excluded"
        rangeStatusColor = color.gold or color.red
    elseif data.comparisonPartial == true then
        rangeStatus = "More history is needed for comparison"
        rangeStatusColor = color.gold or color.red
    elseif data.historyLimited == true then
        rangeStatus = "Older transaction history is limited"
        rangeStatusColor = color.gold or color.red
    end
    text(intro, rangeStatus, 1160, 110, 22, rangeStatusColor, 430, 52, true)

    local left = self:makePanel(self.contentCanvas, 80, 666, 1640, 600)
    text(left, data.partial == true and "RECORDED SPENDING" or "TOTAL SPENDING", 34, 20, 28, color.brandRedBright or color.red, 620, 36)
    local totalLabel = "E$ " .. utils.formatNumber(data.total or 0)
    text(left, totalLabel, 34, 58, 64, color.brandWhite or color.white, 800, 94)
    local outflowLabel = tostring(data.transactionCount or 0) .. " recorded outflows"
    text(left, outflowLabel, 1030, 76, 28, color.dim, 520, 44)
    local comparisonReady = data.partial ~= true and data.comparisonPartial ~= true and data.historyUnavailable ~= true
    local totalComparison = comparisonReady
        and self:formatInsightsDelta(data.totalDelta, false, data.periodDays)
        or "More history is needed for comparison."
    text(left, totalComparison, 34, 140, 27, comparisonReady and self:getInsightsDeltaColor(data.totalDelta) or (color.gold or color.dim), 920, 38)
    divider(left, 30, 186, 1580, 0.16)
    text(left, "SPENDING BREAKDOWN", 34, 206, 30, color.brandRedBright or color.red, 650, 40)
    text(left, "AMOUNT", 1080, 210, 23, color.dim, 260, 30)
    text(left, data.partial == true and "% RECORDED" or "% OF TOTAL", 1430, 210, 22, color.dim, 180, 30)

    local categories = data.categories or {}
    local categoryPageSize = 4
    local categoryPageCount = math.max(math.ceil(#categories / categoryPageSize), 1)
    self.insightsCategoryPage = math.max(1, math.min(math.floor(tonumber(self.insightsCategoryPage) or 1), categoryPageCount))
    local firstCategory = ((self.insightsCategoryPage - 1) * categoryPageSize) + 1
    local lastCategory = math.min(firstCategory + categoryPageSize - 1, #categories)
    local visibleCategories = {}
    for index = firstCategory, lastCategory do
        table.insert(visibleCategories, categories[index])
    end

    local rowY = 252
    local barX = 410
    local barWidth = 620
    for _, category in ipairs(visibleCategories) do
        category = category or {}
        local amount = math.max(math.floor(tonumber(category.amount) or 0), 0)
        local percent = math.max(0, math.min(math.floor(tonumber(category.percent) or 0), 100))
        text(left, category.label or "Other Spending", 34, rowY, 29, amount > 0 and color.white or color.dim, 350, 44)

        local track = ink.rect(barX, rowY + 15, barWidth, 17, color.brandPanel3 or color.panel2)
        track:SetOpacity(0.90)
        track:Reparent(left, -1)
        if amount > 0 and percent > 0 then
            local fillWidth = math.max(math.floor(barWidth * (percent / 100.0)), 5)
            local fill = ink.rect(barX, rowY + 15, fillWidth, 17, color.brandRedBright or color.red)
            fill:SetOpacity(0.90)
            fill:Reparent(left, -1)
        end

        text(left, "E$ " .. utils.formatNumber(amount), 1080, rowY, 29, amount > 0 and color.white or color.dim, 330, 44)
        text(left, tostring(percent) .. "%", 1450, rowY, 29, amount > 0 and color.white or color.dim, 130, 44)
        rowY = rowY + 62
    end

    local previousCategoryCallback = nil
    local nextCategoryCallback = nil
    if self.insightsCategoryPage > 1 then
        previousCategoryCallback = function() self:setInsightsCategoryPage(-1, categoryPageCount) end
    end
    if self.insightsCategoryPage < categoryPageCount then
        nextCategoryCallback = function() self:setInsightsCategoryPage(1, categoryPageCount) end
    end
    self:createButton(left, "Previous Categories", 34, 530, 390, 56, previousCategoryCallback, { fgColor = previousCategoryCallback and color.cyan or color.dim, fontSize = 24 })
    text(left, "Categories " .. tostring(self.insightsCategoryPage) .. " of " .. tostring(categoryPageCount), 680, 546, 25, color.white, 300, 34)
    self:createButton(left, "Next Categories", 1210, 530, 390, 56, nextCategoryCallback, { fgColor = nextCategoryCallback and color.cyan or color.dim, fontSize = 24 })

    local right = self:makePanel(self.contentCanvas, 1740, 470, 1040, 780)
    local top = data.topCategory
    text(right, "TOP CATEGORY", 30, 20, 27, color.brandRedBright or color.red, 760, 34)
    text(right, top and top.label or "No recorded spending", 30, 58, 41, top and color.white or color.dim, 760, 64)
    local topDetail = top and ("E$ " .. utils.formatNumber(top.amount or 0) .. "  |  " .. tostring(top.percent or 0) .. (data.partial == true and "% of recorded" or "% of total")) or "No eligible outflows in this period"
    text(right, topDetail, 30, 108, 27, color.dim, 720, 36)
    if top and comparisonReady then
        text(right, self:formatInsightsDelta(top.delta, true, data.periodDays), 800, 72, 29, self:getInsightsDeltaColor(top.delta), 210, 38)
    end
    divider(right, 20, 150, 1000, 0.13)

    local largest = data.largest
    text(right, "LARGEST OUTFLOW", 30, 170, 27, color.brandRedBright or color.red, 800, 34)
    text(right, largest and largest.label or "No purchase in this period", 30, 208, 39, largest and color.white or color.dim, 900, 64)
    text(right, largest and ("E$ " .. utils.formatNumber(largest.amount or 0)) or "E$ 0", 30, 256, 36, largest and (color.brandRedBright or color.red) or color.dim, 390, 44)
    local largestDateTime = ""
    if largest then
        if math.floor(tonumber(largest.day) or -1) >= 0 then
            largestDateTime = Calendar.formatEngineDateTime(largest.day, largest.hour, largest.minute, Calendar.getContext(), true)
        else
            largestDateTime = tostring(largest.timestamp or "Date unavailable")
        end
    end
    text(right, largestDateTime, 430, 264, 28, color.dim, 580, 36)
    divider(right, 20, 310, 1000, 0.13)

    local frequent = data.frequentCategory
    text(right, "MOST FREQUENT CATEGORY", 30, 330, 27, color.brandRedBright or color.red, 820, 34)
    text(right, frequent and frequent.label or "No spending category yet", 30, 368, 39, frequent and color.white or color.dim, 900, 64)
    local frequentDetail = frequent and (tostring(frequent.count or 0) .. " transactions  |  E$ " .. utils.formatNumber(frequent.amount or 0)) or "0 transactions"
    text(right, frequentDetail, 30, 416, 27, color.dim, 820, 36)
    divider(right, 20, 462, 1000, 0.13)

    text(right, "CHANGE FROM PREVIOUS PERIOD", 30, 482, 26, color.brandRedBright or color.red, 850, 34)
    if comparisonReady then
        local trendY = 526
        for _, category in ipairs(visibleCategories) do
            category = category or {}
            local trendAmount = math.max(math.floor(tonumber(category.amount) or 0), 0)
            text(right, category.label or "Other Spending", 30, trendY, 26, trendAmount > 0 and color.white or color.dim, 420, 34)
            text(right, "E$ " .. utils.formatNumber(trendAmount), 470, trendY, 25, color.dim, 260, 34)
            text(right, self:formatInsightsDelta(category.delta, true, data.periodDays), 800, trendY, 27, self:getInsightsDeltaColor(category.delta), 210, 34)
            trendY = trendY + 46
        end
    else
        text(right, "More history is needed for period comparisons.", 30, 530, 29, color.gold or color.dim, 900, 76, true)
        text(right, "Current category totals remain available on the left.", 30, 612, 25, color.dim, 900, 60, true)
    end

    local previousCallback = nil
    local nextCallback = nil
    if self.insightsPeriodOffset < math.max((tonumber(data.maxPeriods) or 1) - 1, 0) then
        previousCallback = function() self:setInsightsPeriodOffset(1, data.maxPeriods) end
    end
    if self.insightsPeriodOffset > 0 then
        nextCallback = function() self:setInsightsPeriodOffset(-1, data.maxPeriods) end
    end

    local footerNote = "Detailed subjects appear when an exact item or service source is available. Earlier Checking-only records remain Uncategorized. Percentages are rounded."
    text(self.contentCanvas, footerNote, 92, 1272, 22, color.dim, 1600, 58, true)
    self:createButton(self.contentCanvas, "Previous Period", 1770, 1264, 380, 64, previousCallback, { fgColor = previousCallback and color.cyan or color.dim, fontSize = 28 })
    text(self.contentCanvas, tostring(self.insightsPeriodOffset + 1) .. " of " .. tostring(data.maxPeriods or 1), 2190, 1284, 28, color.white, 180, 36)
    self:createButton(self.contentCanvas, "Next Period", 2380, 1264, 360, 64, nextCallback, { fgColor = nextCallback and color.cyan or color.dim, fontSize = 28 })
    self:scheduleInsightsRefresh()
end

function shell:buildTransactionsPage()
    local data = self:getBankData()
    local calendarContext = Calendar.getContext()
    local totalRows = 0
    local pageSize = tonumber(self.transactionPageSize) or 4
    if pageSize < 1 then pageSize = 4 end

    self.transactionPage = math.max(1, tonumber(self.transactionPage) or 1)
    local offset = (self.transactionPage - 1) * pageSize
    local rows = {}

    local function fetchTransactionPage()
        rows = {}
        local fetchedTotal = 0
        pcall(function()
            local pageRows, total = Bank:getTransactionPage(pageSize, offset, self:normalizeTransactionSortMode(self.transactionSortMode))
            if type(pageRows) == "table" then rows = pageRows end
            fetchedTotal = tonumber(total) or #rows
        end)
        totalRows = fetchedTotal
    end

    fetchTransactionPage()
    local maxPage = math.max(1, math.ceil(totalRows / pageSize))
    local clampedPage = math.max(1, math.min(self.transactionPage, maxPage))
    if clampedPage ~= self.transactionPage then
        self.transactionPage = clampedPage
        offset = (self.transactionPage - 1) * pageSize
        fetchTransactionPage()
        maxPage = math.max(1, math.ceil(totalRows / pageSize))
    end

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2700, 170)
    local t1 = ink.text("ACTIVITY", 40, 16, 60, color.cyan)
    t1:Reparent(strip, -1)
    local t2 = ink.text("All account records with their actual posting date and time.", 42, 104, 32, color.dim)
    t2:SetWrapping(true)
    t2:SetSize(Vector2.new({ X = 1480, Y = 50 }))
    t2:Reparent(strip, -1)

    self:drawHeaderStat(strip, "Checking", "E$ " .. utils.formatNumber(data.wallet), 1808, 30, color.white, 390, 28, 42)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(data.bank), 2228, 30, color.gold, 450, 28, 42)

    local main = self:makePanel(self.contentCanvas, 80, 670, 2700, 690)
    local header = ink.text("TRANSACTION HISTORY", 40, 18, 52, color.cyan)
    header:Reparent(main, -1)

    local cooldown = self:getDisputeCooldownSummary()
    local claimStatus = ink.text(tostring(cooldown.text or "Disputes available"), 1530, 94, 30, cooldown.active and color.red or color.green)
    claimStatus:SetSize(Vector2.new({ X = 620, Y = 42 }))
    claimStatus:Reparent(main, -1)

    local countText = ink.text(string.format("Page %d of %d  •  %d records", self.transactionPage, maxPage, totalRows), 1160, 34, 34, color.white)
    countText:SetSize(Vector2.new({ X = 650, Y = 48 }))
    countText:Reparent(main, -1)

    local prevCb = nil
    local nextCb = nil
    if self.transactionPage > 1 then prevCb = function() self:setTransactionPage(-1, maxPage) end end
    if self.transactionPage < maxPage then nextCb = function() self:setTransactionPage(1, maxPage) end end
    local filterMode = self:normalizeTransactionSortMode(self.transactionSortMode)
    local filterHighlighted = filterMode ~= "recent"
    local filterLabel = "Filter: " .. self:getTransactionSortButtonLabel(filterMode)
    self:createButton(main, filterLabel, 2200, 24, 440, 74, function() self:cycleTransactionSortMode() end, { bgColor = color.brandPanel2, fgColor = filterHighlighted and color.gold or color.cyan, hoverColor = color.white, active = filterHighlighted, fontSize = 30 })

    if totalRows <= 0 or #rows <= 0 then
        local emptyPanel = self:makePanel(main, 40, 132, 2620, 320)
        local emptyTitle = ink.text("No activity yet", 40, 46, 50, color.white)
        emptyTitle:Reparent(emptyPanel, -1)
        local empty = ink.text("Deposits, withdrawals, loan events, fees, interest, disputes, purchases, and theft-protection notices will appear here once posted.", 40, 116, 36, color.dim)
        empty:SetWrapping(true)
        empty:SetSize(Vector2.new({ X = 2420, Y = 126 }))
        empty:Reparent(emptyPanel, -1)
        return
    end

    local oldestDay = nil
    local newestDay = nil
    for _, row in ipairs(rows) do
        local rowDay = math.floor(tonumber(row.day) or -1)
        if rowDay >= 0 then
            if oldestDay == nil or rowDay < oldestDay then oldestDay = rowDay end
            if newestDay == nil or rowDay > newestDay then newestDay = rowDay end
        end
    end
    local displayedRange = "Displayed records: date unavailable"
    if oldestDay ~= nil and newestDay ~= nil then
        local oldestDate = Calendar.formatEngineDay(oldestDay, calendarContext, true)
        local newestDate = Calendar.formatEngineDay(newestDay, calendarContext, true)
        displayedRange = oldestDate == newestDate and ("Displayed records: " .. newestDate) or ("Displayed records: " .. oldestDate .. " — " .. newestDate)
    end
    local rangeText = ink.text(displayedRange, 40, 104, 28, color.dim)
    rangeText:SetSize(Vector2.new({ X = 1260, Y = 40 }))
    rangeText:Reparent(main, -1)

    local y = 148
    local rowNumber = 0
    for _, row in ipairs(rows) do
        rowNumber = rowNumber + 1
        local rowPanel = self:makePanel(main, 40, y, 2620, 104)
        local txType = tonumber(row.type) or 0
        local accent = self:getTransactionColor(txType, row.disputeStatus)
        local label = self:getTransactionLabel(txType, row.subject)
        local amount = self:getTransactionSignedAmount(txType, row.amount or 0)
        local status = self:getTransactionStatus(txType, row)
        local channel = self:getTransactionChannel(txType, row.source)
        local cashbackEarned = self:getTransactionCashbackAmount(row)
        local summary = cashbackEarned > 0 and self:getTransactionActivitySummary(row) or self:getTransactionSummary(row)

        if rowNumber % 2 == 0 then
            local shade = ink.rect(2, 2, 2616, 100, color.black)
            shade:SetOpacity(0.12)
            shade:Reparent(rowPanel, -1)
        end

        local rowDay = math.floor(tonumber(row.day) or -1)
        local dateLabel = rowDay >= 0 and Calendar.formatEngineDay(rowDay, calendarContext, true) or "DATE UNAVAILABLE"
        local timeLabel = rowDay >= 0
            and Calendar.formatTime(row.hour, row.minute, calendarContext.use12Hour, false, 0)
            or tostring(row.timestamp or "Time unavailable")
        local dateText = ink.text(dateLabel, 24, 8, 30, color.white)
        dateText:SetSize(Vector2.new({ X = 310, Y = 46 }))
        dateText:Reparent(rowPanel, -1)
        local timeText = ink.text(timeLabel, 24, 56, 27, color.dim)
        timeText:SetSize(Vector2.new({ X = 300, Y = 42 }))
        timeText:Reparent(rowPanel, -1)

        local labelText = ink.text(label, 350, 8, 36, accent)
        labelText:SetSize(Vector2.new({ X = 540, Y = 54 }))
        labelText:Reparent(rowPanel, -1)

        local descWidth = cashbackEarned > 0 and 470 or 900
        local descFontSize = cashbackEarned > 0 and 26 or 28
        local desc = ink.text(summary, 350, 56, descFontSize, color.dim)
        desc:SetWrapping(true)
        desc:SetSize(Vector2.new({ X = descWidth, Y = 44 }))
        desc:Reparent(rowPanel, -1)

        if cashbackEarned > 0 then
            local cashbackLabel = "CASHBACK EARNED  +E$ " .. utils.formatNumber(cashbackEarned)
            local cashbackText = ink.text(cashbackLabel, 830, 56, 28, color.cashbackGreen, nil, "Medium")
            cashbackText:SetWrapping(false)
            cashbackText:SetSize(Vector2.new({ X = 450, Y = 44 }))
            cashbackText:Reparent(rowPanel, -1)
        end

        local channelLab = ink.text("Channel", 1320, 10, 25, color.dim)
        channelLab:Reparent(rowPanel, -1)
        local channelText = ink.text(channel, 1320, 48, 31, color.white)
        channelText:SetSize(Vector2.new({ X = 260, Y = 48 }))
        channelText:Reparent(rowPanel, -1)

        local statusLab = ink.text("Status", 1600, 10, 25, color.dim)
        statusLab:Reparent(rowPanel, -1)
        local statusText = ink.text(status, 1600, 48, 31, accent)
        statusText:SetSize(Vector2.new({ X = 280, Y = 48 }))
        statusText:Reparent(rowPanel, -1)

        local amountText = ink.text(amount, 2180, 52, 38, self:getTransactionAmountColor(txType, row.disputeStatus))
        amountText:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.5 }))
        amountText:SetSize(Vector2.new({ X = 320, Y = 58 }))
        amountText:Reparent(rowPanel, -1)

        if row.disputable == true and cooldown.active ~= true then
            self:createButton(rowPanel, "Dispute", 2250, 22, 320, 62, function() self:beginDispute(row) end, { bgColor = color.brandPanel2, fgColor = color.red, fontSize = 31 })
        elseif row.disputeHiddenByCooldown == true then
        elseif txType == 4 and tonumber(row.disputeStatus) == 3 then
            local d = ink.text("In Review", 2405, 52, 31, color.gold)
            d:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
            d:SetSize(Vector2.new({ X = 300, Y = 50 }))
            d:Reparent(rowPanel, -1)
        elseif txType == 4 and tonumber(row.disputeStatus) == 4 then
            local d = ink.text("Credited", 2405, 52, 31, color.green)
            d:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
            d:SetSize(Vector2.new({ X = 300, Y = 50 }))
            d:Reparent(rowPanel, -1)
        elseif txType == 4 and tonumber(row.disputeStatus) == 5 then
            local d = ink.text("Denied", 2405, 52, 31, color.red)
            d:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
            d:SetSize(Vector2.new({ X = 300, Y = 50 }))
            d:Reparent(rowPanel, -1)
        else
            local posted = ink.text("Posted", 2405, 52, 30, color.dim)
            posted:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
            posted:SetSize(Vector2.new({ X = 300, Y = 48 }))
            posted:Reparent(rowPanel, -1)
        end

        y = y + 108
    end

    local bottomNavY = 620
    self:createButton(main, "Previous", 1690, bottomNavY, 260, 54, prevCb, { bgColor = color.brandPanel2, fgColor = self.transactionPage > 1 and color.cyan or color.dim, textColor = self.transactionPage > 1 and color.white or color.dim, fontSize = 27 })
    self:createButton(main, "Next", 1960, bottomNavY, 240, 54, nextCb, { bgColor = color.brandPanel2, fgColor = self.transactionPage < maxPage and color.cyan or color.dim, textColor = self.transactionPage < maxPage and color.white or color.dim, fontSize = 27 })
end

function shell:getAutoDepositIntervalDays()
    local days = math.floor(tonumber(self.autoDepositIntervalDays) or 7)
    if days < 1 then days = 1 end
    if days > 30 then days = 30 end
    self.autoDepositIntervalDays = days
    return days
end

function shell:performTransfer(mode, amount)
    local ok = false
    self:clearTransferError(mode)

    if mode == "deposit" then
        ok = Bank:depositMoney(amount)
    else
        ok = Bank:withdrawMoney(amount)
    end

    if ok then
        pcall(function() Bank.lastUnifiedBalance = Bank:getUnifiedBalance() end)
        self.confirmMode = mode
        self.lastAmount = amount
        self:setCustomAmountString(mode, "")
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setTransferError(mode, "Transfer could not be completed.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(mode)
    end
end

function shell:createTransferKey(parent, label, x, y, w, h, callback, opts)
    opts = opts or {}
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local borderColor = opts.borderColor or color.dim
    local fillColor = opts.fillColor or color.brandPanel2
    local textColor = opts.textColor or color.brandWhite
    local hoverColor = opts.hoverColor or color.brandRedBright

    local border = ink.rect(0, 0, w, h, borderColor)
    border:SetOpacity(opts.borderOpacity or 0.36)
    border:Reparent(holder, -1)

    local fill = ink.rect(2, 2, w - 4, h - 4, fillColor)
    fill:SetOpacity(opts.fillOpacity or 0.90)
    fill:Reparent(holder, -1)

    local textWidget = ink.text(label, w / 2, h / 2 - 5, opts.fontSize or 34, textColor)
    textWidget:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    textWidget:SetSize(Vector2.new({ X = w - 20, Y = h + 22 }))
    textWidget:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if callback then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(hoverColor)
                border:SetOpacity(0.88)
                fill:SetTintColor(color.brandPanel3 or color.panel2)
                textWidget:SetTintColor(hoverColor)
            end,
            hoverOut = function()
                border:SetTintColor(borderColor)
                border:SetOpacity(opts.borderOpacity or 0.36)
                fill:SetTintColor(fillColor)
                textWidget:SetTintColor(textColor)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    elseif opts.static ~= true then
        border:SetOpacity(0.16)
        fill:SetOpacity(0.42)
        textWidget:SetTintColor(color.dim)
    end

    return holder
end

function shell:createTransferAction(parent, label, x, y, w, h, callback, enabled)
    local isEnabled = enabled == true and callback ~= nil
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local outerColor = isEnabled and (color.brandRedBright or color.red) or color.dim
    local fillColor = isEnabled and (color.brandRed or color.red) or (color.brandPanel2 or color.panel2)
    local textColor = isEnabled and (color.brandWhite or color.white) or color.dim

    local border = ink.rect(0, 0, w, h, outerColor)
    border:SetOpacity(isEnabled and 0.78 or 0.18)
    border:Reparent(holder, -1)

    local fill = ink.rect(3, 3, w - 6, h - 6, fillColor)
    fill:SetOpacity(isEnabled and 0.72 or 0.36)
    fill:Reparent(holder, -1)

    local textWidget = ink.text(label, w / 2, h / 2 - 6, 35, textColor)
    textWidget:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    textWidget:SetSize(Vector2.new({ X = w - 24, Y = h + 24 }))
    textWidget:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if isEnabled then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(color.brandWhite or color.white)
                border:SetOpacity(0.92)
                fill:SetTintColor(color.brandRedBright or color.red)
                fill:SetOpacity(0.86)
            end,
            hoverOut = function()
                border:SetTintColor(outerColor)
                border:SetOpacity(0.78)
                fill:SetTintColor(fillColor)
                fill:SetOpacity(0.72)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    end

    return holder
end

function shell:drawTransferReviewRow(parent, label, value, y, valueColor, drawLine)
    local labelWidget = ink.text(label, 30, y, 28, color.dim)
    labelWidget:SetSize(Vector2.new({ X = 570, Y = 46 }))
    labelWidget:Reparent(parent, -1)

    local valueWidget = ink.text(value, 1288, y - 2, 32, valueColor or color.white)
    valueWidget:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    valueWidget:SetWrapping(true)
    valueWidget:SetSize(Vector2.new({ X = 700, Y = 50 }))
    valueWidget:Reparent(parent, -1)

    if drawLine ~= false then
        local line = ink.rect(30, y + 50, 1258, 1, color.brandWhite or color.white)
        line:SetOpacity(0.09)
        line:Reparent(parent, -1)
    end
end

function shell:buildAmountKeypad(parent, mode, accent, opts)
    opts = opts or {}
    local keyW = tonumber(opts.keyW) or 288
    local keyH = tonumber(opts.keyH) or 66
    local gapX = tonumber(opts.gapX) or 18
    local gapY = tonumber(opts.gapY) or 10
    local x1 = tonumber(opts.x) or 40
    local x2 = x1 + keyW + gapX
    local x3 = x2 + keyW + gapX
    local x4 = x3 + keyW + gapX
    local y1 = tonumber(opts.y) or 318
    local y2 = y1 + keyH + gapY
    local y3 = y2 + keyH + gapY
    local y4 = y3 + keyH + gapY

    local numberOpts = {
        borderColor = color.dim,
        hoverColor = accent,
        fontSize = tonumber(opts.numberFontSize) or 34,
        fillOpacity = tonumber(opts.fillOpacity) or 0.90,
    }
    local controlOpts = {
        borderColor = color.brandRed or color.red,
        hoverColor = color.brandWhite or color.white,
        textColor = color.brandRedBright or color.red,
        fontSize = tonumber(opts.controlFontSize) or 27,
        fillOpacity = tonumber(opts.fillOpacity) or 0.90,
    }

    self:createTransferKey(parent, "1", x1, y1, keyW, keyH, function() self:appendCustomAmount(mode, "1") end, numberOpts)
    self:createTransferKey(parent, "2", x2, y1, keyW, keyH, function() self:appendCustomAmount(mode, "2") end, numberOpts)
    self:createTransferKey(parent, "3", x3, y1, keyW, keyH, function() self:appendCustomAmount(mode, "3") end, numberOpts)
    self:createTransferKey(parent, "BACK", x4, y1, keyW, keyH, function() self:backspaceCustomAmount(mode) end, controlOpts)

    self:createTransferKey(parent, "4", x1, y2, keyW, keyH, function() self:appendCustomAmount(mode, "4") end, numberOpts)
    self:createTransferKey(parent, "5", x2, y2, keyW, keyH, function() self:appendCustomAmount(mode, "5") end, numberOpts)
    self:createTransferKey(parent, "6", x3, y2, keyW, keyH, function() self:appendCustomAmount(mode, "6") end, numberOpts)
    self:createTransferKey(parent, "CLEAR", x4, y2, keyW, keyH, function() self:clearCustomAmount(mode) end, controlOpts)

    self:createTransferKey(parent, "7", x1, y3, keyW, keyH, function() self:appendCustomAmount(mode, "7") end, numberOpts)
    self:createTransferKey(parent, "8", x2, y3, keyW, keyH, function() self:appendCustomAmount(mode, "8") end, numberOpts)
    self:createTransferKey(parent, "9", x3, y3, keyW, keyH, function() self:appendCustomAmount(mode, "9") end, numberOpts)
    self:createTransferKey(parent, "MAX", x4, y3, keyW, keyH, function() self:fillMaxCustomAmount(mode) end, controlOpts)

    self:createTransferKey(parent, "0", x1, y4, keyW, keyH, function() self:appendCustomAmount(mode, "0") end, numberOpts)
    self:createTransferKey(parent, "00", x2, y4, keyW, keyH, function() self:appendCustomAmount(mode, "00") end, numberOpts)
    self:createTransferKey(parent, "000", x3, y4, keyW, keyH, function() self:appendCustomAmount(mode, "000") end, numberOpts)
end

function shell:drawCompactTransferReviewRow(parent, label, value, y, valueColor, drawLine)
    local labelWidget = ink.text(label, 24, y, 23, color.dim)
    labelWidget:SetSize(Vector2.new({ X = 560, Y = 40 }))
    labelWidget:Reparent(parent, -1)

    local valueWidget = ink.text(value, 1310, y - 1, 27, valueColor or color.white)
    valueWidget:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    valueWidget:SetWrapping(true)
    valueWidget:SetSize(Vector2.new({ X = 720, Y = 42 }))
    valueWidget:Reparent(parent, -1)

    if drawLine ~= false then
        local line = ink.rect(24, y + 38, 1286, 1, color.brandWhite or color.white)
        line:SetOpacity(0.09)
        line:Reparent(parent, -1)
    end
end

function shell:getAutoDepositPresetLabel(days)
    local value = math.max(1, math.min(30, math.floor(tonumber(days) or 7)))
    if value == 7 then return "Weekly" end
    if value == 14 then return "Biweekly" end
    if value == 30 then return "Monthly" end
    return "Every " .. tostring(value) .. " days"
end

function shell:getDepositKeypadTarget()
    if self.depositKeypadTarget == "autodeposit" then return "autodeposit" end
    self.depositKeypadTarget = "deposit"
    return "deposit"
end

function shell:getInlineAutoDepositAmount(auto)
    if self.autoDepositDraftActive == true then
        return self:getCustomAmount("autodeposit")
    end
    if type(auto) == "table" and auto.active == true then
        return math.max(math.floor(tonumber(auto.amount) or 0), 0)
    end
    return 0
end

function shell:primeInlineAutoDepositAmount(auto)
    return self:getInlineAutoDepositAmount(auto)
end

function shell:getInlineAutoDepositNextStamp(auto, selectedDays)
    local settings = type(auto) == "table" and auto or {}
    local days = math.max(1, math.min(30, math.floor(tonumber(selectedDays) or 7)))
    local savedStamp = math.floor(tonumber(settings.nextStamp) or 0)
    if settings.active == true and self.autoDepositDraftActive ~= true and self.autoDepositIntervalDirty ~= true and savedStamp > 0 then
        return savedStamp
    end
    local nextStamp = 0
    pcall(function() nextStamp = math.floor(tonumber(Bank:_buildAutoDepositNextStamp(days)) or 0) end)
    return nextStamp
end

function shell:selectDepositKeypadTarget(mode)
    local target = mode == "autodeposit" and "autodeposit" or "deposit"
    self.depositKeypadTarget = target
    self:clearTransferError(target)
    self:renderPage("deposit")
end

function shell:selectInlineAutoDepositFrequency(days)
    local value = math.max(1, math.min(30, math.floor(tonumber(days) or 7)))
    self.autoDepositIntervalDays = value
    self.autoDepositIntervalDirty = true
    self.depositKeypadTarget = "autodeposit"
    self:clearTransferError("autodeposit")
    self:renderPage("deposit")
end

function shell:saveInlineAutoDeposit(amount)
    local transferAmount = math.floor(tonumber(amount) or 0)
    if transferAmount <= 0 then
        self:setTransferError("autodeposit", "Enter the recurring deposit amount with the keypad.")
        self.depositKeypadTarget = "autodeposit"
        self.autoDepositDraftActive = true
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("deposit")
        return
    end

    local ok = false
    local reason = ""
    pcall(function() ok, reason = Bank:setAutoDepositSchedule(transferAmount, self:getAutoDepositIntervalDays()) end)
    if ok then
        self:clearTransferError("autodeposit")
        self:setCustomAmountString("autodeposit", "")
        self.autoDepositDraftActive = false
        self.autoDepositIntervalDirty = false
        self.depositKeypadTarget = "deposit"
        utils.playSound("ui_jingle_quest_update", 1)
    else
        local message = "Automatic deposit schedule could not be saved."
        if reason == "no_account" then
            message = "Open a Marmur account before scheduling automatic deposits."
        elseif reason == "amount" then
            message = "Enter the recurring deposit amount with the keypad."
        end
        self:setTransferError("autodeposit", message)
        self.depositKeypadTarget = "autodeposit"
        self.autoDepositDraftActive = true
        utils.playSound("ui_menu_onpress", 1)
    end
    self:renderPage("deposit")
end

function shell:cancelInlineAutoDeposit()
    pcall(function() Bank:cancelAutoDeposit(false) end)
    self.autoDepositIntervalDirty = false
    self.autoDepositIntervalDays = 7
    self.depositKeypadTarget = "deposit"
    self.autoDepositDraftActive = false
    self:clearTransferError("autodeposit")
    self:setCustomAmountString("autodeposit", "")
    utils.playSound("ui_menu_onpress", 1)
    self:renderPage("deposit")
end

function shell:buildInlineDepositPage()
    local data = self:getBankData()
    local accent = color.brandRedBright or color.gold
    local auto = nil
    pcall(function() auto = Bank:getAutoDepositSettings() end)
    auto = auto or { active = false, amount = 0, intervalDays = 7, frequencyLabel = "Every 7 days", nextLabel = "Not scheduled", nextStamp = 0 }

    if self.autoDepositIntervalDirty ~= true then
        local savedDays = auto.active == true and math.floor(tonumber(auto.intervalDays) or 7) or 7
        if savedDays < 1 then savedDays = 1 end
        if savedDays > 30 then savedDays = 30 end
        self.autoDepositIntervalDays = savedDays
    end

    local target = self:getDepositKeypadTarget()
    local amountMode = target == "autodeposit" and "autodeposit" or "deposit"
    local sourceAmount = math.max(math.floor(tonumber(data.wallet) or 0), 0)
    local savingsAmount = math.max(math.floor(tonumber(data.bank) or 0), 0)
    local depositAmount = self:getCustomAmount("deposit")
    local scheduledAmount = self:getInlineAutoDepositAmount(auto)
    local activeAmount = amountMode == "autodeposit" and scheduledAmount or depositAmount
    local activeError = self:getTransferError(amountMode)
    local autoError = self:getTransferError("autodeposit")
    local exceedsFunds = amountMode == "deposit" and activeAmount > sourceAmount
    local validDeposit = depositAmount > 0 and depositAmount <= sourceAmount
    local selectedDays = self:getAutoDepositIntervalDays()
    local previewStamp = self:getInlineAutoDepositNextStamp(auto, selectedDays)
    local nextDebitText = previewStamp > 0 and Calendar.formatMinuteStamp(previewStamp, Calendar.getContext(), true) or "After schedule is saved"

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 150)
    local titleWidget = ink.text("DEPOSIT FUNDS", 40, 18, 50, accent)
    titleWidget:Reparent(strip, -1)
    local subtitleWidget = ink.text("Move funds from Checking into Marmur Bank Savings or schedule the transfer to repeat automatically.", 42, 84, 27, color.dim)
    subtitleWidget:SetWrapping(true)
    subtitleWidget:SetSize(Vector2.new({ X = 1420, Y = 48 }))
    subtitleWidget:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Checking / Wallet", "E$ " .. utils.formatNumber(sourceAmount), 1570, 28, color.white, 560, 24, 36)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(savingsAmount), 2180, 28, accent, 560, 24, 36)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1340, 540)
    local right = self:makePanel(self.contentCanvas, 1460, 650, 1420, 540)

    local leftHead = ink.text("1. DEPOSIT SETUP", 40, 16, 40, color.cyan)
    leftHead:Reparent(left, -1)
    local leftNoteText = amountMode == "autodeposit"
        and "The keypad is editing the scheduled amount. Your one-time deposit amount remains unchanged."
        or "The keypad is editing the one-time deposit amount. Your scheduled amount remains unchanged."
    local leftNoteColor = color.dim
    if #activeError > 0 then
        leftNoteText = activeError
        leftNoteColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        leftNoteText = "The one-time deposit exceeds the available Checking balance."
        leftNoteColor = color.brandRedBright or color.red
    end
    local leftNote = ink.text(leftNoteText, 42, 74, 23, leftNoteColor)
    leftNote:SetWrapping(true)
    leftNote:SetSize(Vector2.new({ X = 1240, Y = 44 }))
    leftNote:Reparent(left, -1)

    local function amountField(label, value, x, mode, selected, valueColor)
        local w, h = 610, 104
        local holder = ink.canvas(x, 122, inkEAnchor.TopLeft)
        holder:SetSize(Vector2.new({ X = w, Y = h }))
        holder:Reparent(left, -1)
        local border = ink.rect(0, 0, w, h, selected and (color.brandRedBright or color.red) or color.dim)
        border:SetOpacity(selected and 0.86 or 0.34)
        border:Reparent(holder, -1)
        local fill = ink.rect(2, 2, w - 4, h - 4, color.brandPanel2 or color.panel2)
        fill:SetOpacity(selected and 0.82 or 0.54)
        fill:Reparent(holder, -1)
        local lab = ink.text(label, 22, 12, 21, selected and (color.brandWhite or color.white) or color.dim)
        lab:SetSize(Vector2.new({ X = w - 44, Y = 32 }))
        lab:Reparent(holder, -1)
        local valueFont = #tostring(value) >= 18 and 38 or 44
        local val = ink.text(value, 22, 44, valueFont, valueColor)
        val:SetSize(Vector2.new({ X = w - 44, Y = 64 }))
        val:Reparent(holder, -1)
        local hotspot = ink.rect(0, 0, w, h, color.white)
        hotspot:SetOpacity(0.01)
        hotspot:Reparent(holder, -1)
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(color.brandWhite or color.white)
                border:SetOpacity(0.90)
                fill:SetOpacity(0.88)
            end,
            hoverOut = function()
                border:SetTintColor(selected and (color.brandRedBright or color.red) or color.dim)
                border:SetOpacity(selected and 0.86 or 0.34)
                fill:SetOpacity(selected and 0.82 or 0.54)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                self:selectDepositKeypadTarget(mode)
            end,
        })
    end

    local depositDisplayColor = depositAmount > sourceAmount and (color.brandRedBright or color.red) or (amountMode == "deposit" and accent or color.white)
    amountField("ONE-TIME DEPOSIT", "E$ " .. utils.formatNumber(depositAmount), 40, "deposit", amountMode == "deposit", depositDisplayColor)
    amountField("SCHEDULED AUTO-DEPOSIT", "E$ " .. utils.formatNumber(scheduledAmount), 690, "autodeposit", amountMode == "autodeposit", amountMode == "autodeposit" and accent or color.white)

    local keypadHead = ink.text("NUMERIC KEYPAD  •  " .. (amountMode == "autodeposit" and "SCHEDULED AMOUNT" or "ONE-TIME AMOUNT"), 40, 236, 25, color.dim)
    keypadHead:SetSize(Vector2.new({ X = 1240, Y = 36 }))
    keypadHead:Reparent(left, -1)
    self:buildAmountKeypad(left, amountMode, accent, {
        y = 278,
        keyH = 52,
        gapY = 7,
        numberFontSize = 30,
        controlFontSize = 24,
        fillOpacity = 0.78,
    })

    local rightHead = ink.text(amountMode == "autodeposit" and "2. SCHEDULE REVIEW" or "2. REVIEW & CONFIRM", 40, 16, 40, color.cyan)
    rightHead:Reparent(right, -1)
    local rightNote = ink.text(amountMode == "autodeposit"
        and "Review the scheduled transfer. Save it in the Auto-Deposit section below."
        or "Review the one-time transfer before it posts.", 42, 74, 24, color.dim)
    rightNote:SetWrapping(true)
    rightNote:SetSize(Vector2.new({ X = 1300, Y = 44 }))
    rightNote:Reparent(right, -1)

    local review = self:makePanel(right, 40, 122, 1340, 286)
    if amountMode == "autodeposit" then
        self:drawCompactTransferReviewRow(review, "From", "Checking", 10, color.white, true)
        self:drawCompactTransferReviewRow(review, "To", "Savings", 54, accent, true)
        self:drawCompactTransferReviewRow(review, "Scheduled Amount", "E$ " .. utils.formatNumber(scheduledAmount), 98, accent, true)
        self:drawCompactTransferReviewRow(review, "Frequency", self:getAutoDepositPresetLabel(selectedDays), 142, color.white, true)
        self:drawCompactTransferReviewRow(review, "Next Debit", nextDebitText, 186, color.white, true)
        self:drawCompactTransferReviewRow(review, "Current Status", auto.active == true and "ACTIVE" or "NOT SCHEDULED", 230, auto.active == true and color.white or color.dim, false)
    else
        local checkingAfter = sourceAmount - depositAmount
        local savingsAfter = savingsAmount + depositAmount
        self:drawCompactTransferReviewRow(review, "From", "Checking", 10, color.white, true)
        self:drawCompactTransferReviewRow(review, "To", "Savings", 54, accent, true)
        self:drawCompactTransferReviewRow(review, "Deposit Amount", "E$ " .. utils.formatNumber(depositAmount), 98, depositDisplayColor, true)
        self:drawCompactTransferReviewRow(review, "Transfer Fee", "E$ 0", 142, color.white, true)
        self:drawCompactTransferReviewRow(review, "New Checking Balance", "E$ " .. utils.formatNumber(checkingAfter), 186, checkingAfter < 0 and (color.brandRedBright or color.red) or color.white, true)
        self:drawCompactTransferReviewRow(review, "New Savings Balance", "E$ " .. utils.formatNumber(savingsAfter), 230, accent, false)
    end

    local statusPanel = self:makePanel(right, 40, 420, 1340, 50)
    local statusText = amountMode == "autodeposit" and "Enter the recurring amount, choose a frequency below, then save the schedule." or "Enter an amount to enable confirmation."
    local statusColor = color.dim
    if #activeError > 0 then
        statusText = activeError
        statusColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        statusText = "Amount exceeds available Checking funds."
        statusColor = color.brandRedBright or color.red
    elseif amountMode == "autodeposit" and scheduledAmount > 0 then
        statusText = "Scheduled amount ready. Confirm the frequency in Section 3."
        statusColor = color.white
    elseif validDeposit then
        statusText = "Ready to post immediately to the Activity ledger."
        statusColor = color.white
    end
    local status = ink.text(statusText, 20, 10, 23, statusColor)
    status:SetSize(Vector2.new({ X = 1290, Y = 34 }))
    status:Reparent(statusPanel, -1)

    if amountMode == "autodeposit" then
        self:createTransferKey(right, "RETURN TO ONE-TIME DEPOSIT", 40, 482, 1340, 58, function() self:selectDepositKeypadTarget("deposit") end, {
            borderColor = color.brandRed or color.red,
            textColor = color.brandRedBright or color.red,
            hoverColor = color.brandWhite or color.white,
            fontSize = 27,
            fillOpacity = 0.50,
        })
    else
        local confirmCallback = validDeposit and function() self:submitCustomAmount("deposit", data) end or nil
        self:createTransferAction(right, "CONFIRM DEPOSIT", 40, 482, 1340, 58, confirmCallback, validDeposit)
    end

    local schedule = self:makePanel(self.contentCanvas, 80, 1205, 2800, 225)
    local scheduleHead = ink.text("3. SCHEDULED AUTO-DEPOSIT", 30, 12, 36, color.cyan)
    scheduleHead:Reparent(schedule, -1)
    local scheduleSub = ink.text("Automatically move the selected amount from Checking to Savings on a recurring schedule.", 32, 62, 22, color.dim)
    scheduleSub:SetSize(Vector2.new({ X = 1480, Y = 36 }))
    scheduleSub:Reparent(schedule, -1)

    local scheduleStatusText = auto.active == true
        and ("ACTIVE  •  " .. self:getAutoDepositPresetLabel(auto.intervalDays) .. "  •  E$ " .. utils.formatNumber(auto.amount or 0))
        or "NOT SCHEDULED"
    local scheduleStatus = ink.text(scheduleStatusText, 2750, 20, 25, auto.active == true and color.white or color.dim)
    scheduleStatus:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    scheduleStatus:SetSize(Vector2.new({ X = 920, Y = 34 }))
    scheduleStatus:Reparent(schedule, -1)
    if #autoError > 0 then
        local autoErrorWidget = ink.text(autoError, 2750, 56, 21, color.brandRedBright or color.red)
        autoErrorWidget:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
        autoErrorWidget:SetSize(Vector2.new({ X = 980, Y = 30 }))
        autoErrorWidget:Reparent(schedule, -1)
    elseif auto.active == true then
        local nextCurrent = tostring(auto.nextLabel or "Scheduled")
        local savedStamp = math.floor(tonumber(auto.nextStamp) or 0)
        if savedStamp > 0 then nextCurrent = Calendar.formatMinuteStamp(savedStamp, Calendar.getContext(), true) end
        local nextStatus = ink.text("Next debit: " .. nextCurrent, 2750, 56, 21, color.dim)
        nextStatus:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
        nextStatus:SetSize(Vector2.new({ X = 980, Y = 30 }))
        nextStatus:Reparent(schedule, -1)
    end

    local fieldY = 130
    local labelY = 98
    local function fieldLabel(textValue, x, w)
        local widget = ink.text(textValue, x, labelY, 20, color.dim)
        widget:SetSize(Vector2.new({ X = w, Y = 30 }))
        widget:Reparent(schedule, -1)
    end

    fieldLabel("SOURCE", 30, 260)
    self:createTransferKey(schedule, "Checking", 30, fieldY, 280, 64, nil, { static = true, fontSize = 25, fillOpacity = 0.52 })
    fieldLabel("DESTINATION", 330, 290)
    self:createTransferKey(schedule, "Savings", 330, fieldY, 280, 64, nil, { static = true, fontSize = 25, fillOpacity = 0.52 })

    fieldLabel("FREQUENCY", 630, 590)
    local function frequencyButton(label, days, x)
        local selected = selectedDays == days
        self:createTransferKey(schedule, label, x, fieldY, 180, 64, function() self:selectInlineAutoDepositFrequency(days) end, {
            borderColor = selected and (color.brandRedBright or color.red) or color.dim,
            textColor = selected and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 23,
            fillOpacity = selected and 0.70 or 0.46,
        })
    end
    frequencyButton("Weekly", 7, 630)
    frequencyButton("Biweekly", 14, 822)
    frequencyButton("Monthly", 30, 1014)

    fieldLabel("NEXT DEBIT", 1218, 440)
    self:createTransferKey(schedule, nextDebitText, 1218, fieldY, 430, 64, nil, { static = true, fontSize = 22, fillOpacity = 0.52 })

    local autoSelected = amountMode == "autodeposit"
    fieldLabel("AMOUNT", 1668, 360)
    self:createTransferKey(schedule, "E$ " .. utils.formatNumber(scheduledAmount), 1668, fieldY, 350, 64, function() self:selectDepositKeypadTarget("autodeposit") end, {
        borderColor = autoSelected and (color.brandRedBright or color.red) or color.dim,
        textColor = autoSelected and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = autoSelected and 0.70 or 0.52,
    })

    local saveEnabled = scheduledAmount > 0
    local saveLabel = auto.active == true and "REPLACE SCHEDULE" or "SET UP AUTO-DEPOSIT"
    local saveCallback = saveEnabled and function() self:saveInlineAutoDeposit(scheduledAmount) end or nil
    self:createTransferAction(schedule, saveLabel, 2038, fieldY, 450, 64, saveCallback, saveEnabled)

    self:createTransferKey(schedule, "CANCEL", 2508, fieldY, 262, 64, auto.active == true and function() self:cancelInlineAutoDeposit() end or nil, {
        borderColor = color.brandRed or color.red,
        textColor = auto.active == true and (color.brandRedBright or color.red) or color.dim,
        hoverColor = color.brandWhite or color.white,
        fontSize = 23,
        fillOpacity = 0.44,
    })
end

function shell:buildTransferPage(mode)
    if mode == "deposit" then
        self:buildInlineDepositPage()
        return
    end

    local data = self:getBankData()
    local accent = color.brandRedBright or color.gold
    local sourceAmount = math.max(math.floor(tonumber(data.bank) or 0), 0)
    local destinationAmount = math.max(math.floor(tonumber(data.wallet) or 0), 0)
    local amount = self:getCustomAmount("withdraw")
    local customLabel = self:getCustomAmountLabel("withdraw")
    local errorText = self:getTransferError("withdraw")
    local validAmount = amount > 0 and amount <= sourceAmount
    local exceedsFunds = amount > sourceAmount
    local checkingAfter = destinationAmount + amount
    local savingsAfter = sourceAmount - amount

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 160)
    local titleWidget = ink.text("WITHDRAW FUNDS", 40, 18, 50, accent)
    titleWidget:Reparent(strip, -1)
    local subtitleWidget = ink.text("Move funds from Savings back to Checking.", 42, 92, 29, color.dim)
    subtitleWidget:SetWrapping(true)
    subtitleWidget:SetSize(Vector2.new({ X = 1180, Y = 48 }))
    subtitleWidget:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Savings Balance", "E$ " .. utils.formatNumber(sourceAmount), 1388, 34, accent, 660, 26, 38)
    self:drawHeaderStat(strip, "Checking Balance", "E$ " .. utils.formatNumber(destinationAmount), 2098, 34, color.white, 660, 26, 38)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1340, 700)
    local right = self:makePanel(self.contentCanvas, 1460, 650, 1420, 700)

    local leftHead = ink.text("TRANSFER SETUP", 44, 24, 44, color.cyan)
    leftHead:Reparent(left, -1)
    local leftNoteText = "Use the keypad to enter the exact amount."
    local leftNoteColor = color.dim
    if #errorText > 0 then
        leftNoteText = errorText
        leftNoteColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        leftNoteText = "The entered amount exceeds your available Savings balance."
        leftNoteColor = color.brandRedBright or color.red
    end
    local leftNote = ink.text(leftNoteText, 46, 88, 28, leftNoteColor)
    leftNote:SetWrapping(true)
    leftNote:SetSize(Vector2.new({ X = 1230, Y = 50 }))
    leftNote:Reparent(left, -1)

    local amountPanel = self:makePanel(left, 40, 148, 1260, 142)
    local amountHead = ink.text("EXACT AMOUNT", 30, 18, 27, color.dim)
    amountHead:Reparent(amountPanel, -1)
    local amountFontSize = (#customLabel >= 18) and 48 or 62
    local amountColor = exceedsFunds and (color.brandRedBright or color.red) or accent
    local amountValue = ink.text(customLabel, 30, 53, amountFontSize, amountColor)
    amountValue:SetSize(Vector2.new({ X = 720, Y = 92 }))
    amountValue:Reparent(amountPanel, -1)
    local availableLabel = ink.text("AVAILABLE SAVINGS", 820, 22, 24, color.dim)
    availableLabel:SetSize(Vector2.new({ X = 390, Y = 34 }))
    availableLabel:Reparent(amountPanel, -1)
    local availableValue = ink.text("E$ " .. utils.formatNumber(sourceAmount), 820, 60, 34, color.white)
    availableValue:SetSize(Vector2.new({ X = 390, Y = 54 }))
    availableValue:Reparent(amountPanel, -1)

    local keypadHead = ink.text("NUMERIC KEYPAD", 44, 306, 31, color.dim)
    keypadHead:Reparent(left, -1)
    self:buildAmountKeypad(left, "withdraw", accent, { y = 348, keyH = 68, gapY = 10, numberFontSize = 34, controlFontSize = 27 })

    local rightHead = ink.text("REVIEW & CONFIRM", 44, 24, 44, color.cyan)
    rightHead:Reparent(right, -1)
    local rightNote = ink.text("Review the transfer details before posting.", 46, 88, 28, color.dim)
    rightNote:SetWrapping(true)
    rightNote:SetSize(Vector2.new({ X = 1290, Y = 50 }))
    rightNote:Reparent(right, -1)

    local review = self:makePanel(right, 40, 148, 1340, 392)
    self:drawTransferReviewRow(review, "From", "Savings  •  E$ " .. utils.formatNumber(sourceAmount), 18, accent, true)
    self:drawTransferReviewRow(review, "To", "Checking  •  E$ " .. utils.formatNumber(destinationAmount), 78, color.white, true)
    self:drawTransferReviewRow(review, "Transfer Amount", "E$ " .. utils.formatNumber(amount), 138, amountColor, true)
    self:drawTransferReviewRow(review, "Transfer Fee", "E$ 0", 198, color.white, true)
    self:drawTransferReviewRow(review, "New Checking Balance", "E$ " .. utils.formatNumber(checkingAfter), 260, color.white, true)
    self:drawTransferReviewRow(review, "New Savings Balance", "E$ " .. utils.formatNumber(savingsAfter), 322, savingsAfter < 0 and (color.brandRedBright or color.red) or accent, false)

    local statusPanel = self:makePanel(right, 40, 552, 1340, 60)
    local statusText = "Enter an amount to enable confirmation."
    local statusColor = color.dim
    if #errorText > 0 then
        statusText = errorText
        statusColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        statusText = "Amount exceeds available Savings funds."
        statusColor = color.brandRedBright or color.red
    elseif validAmount then
        statusText = "Ready to post immediately to the Activity ledger."
        statusColor = color.brandWhite or color.white
    end
    local status = ink.text(statusText, 22, 14, 26, statusColor)
    status:SetSize(Vector2.new({ X = 1288, Y = 42 }))
    status:Reparent(statusPanel, -1)

    local confirmCallback = validAmount and function() self:submitCustomAmount("withdraw", data) end or nil
    self:createTransferAction(right, "CONFIRM WITHDRAWAL", 40, 624, 1340, 66, confirmCallback, validAmount)
end

function shell:loanRateLabel(basisPoints)
    return string.format("%.2f%%", (tonumber(basisPoints) or 0) / 100.0)
end

function shell:getLoanEarlyPayoffAmountFromData(loan)
    local data = loan or {}
    local amount = math.floor(tonumber(data.earlyPayoffAmount) or 0)
    if amount > 0 then return amount end
    local principal = math.floor(tonumber(data.principal) or 0)
    local originalDue = math.floor(tonumber(data.originalDue) or 0)
    local balanceDue = math.floor(tonumber(data.balanceDue) or 0)
    if balanceDue <= 0 then return 0 end
    if principal <= 0 then return balanceDue end
    if originalDue <= principal then return math.min(balanceDue, principal) end
    amount = math.ceil((principal * balanceDue) / originalDue)
    if amount < 0 then amount = 0 end
    if amount > balanceDue then amount = balanceDue end
    return amount
end

function shell:setLoanError(message)
    self:setTransferError("loanpay", message or "")
    self:setTransferError("loanrequest", message or "")
end

function shell:getLoanError()
    local requestError = self:getTransferError("loanrequest")
    if requestError ~= nil and requestError ~= "" then return requestError end
    return self:getTransferError("loanpay")
end

function shell:updateLastLoanConfirmationNumber()
    local code = ""
    pcall(function() code = Bank:getLastLoanConfirmationCode() or "" end)
    if code == nil or code == "" then
        code = "MB-PENDING"
    end
    self.lastConfirmationNumber = code
end

function shell:performLoanApplication(offer)
    if not offer then return end

    local currentLoan = nil
    pcall(function() currentLoan = Bank:getLoanData() end)
    if currentLoan and (currentLoan.active or currentLoan.reviewActive or currentLoan.reviewPending or currentLoan.reviewApprovalReady or currentLoan.reviewFundingPending) then
        self:setLoanError("Application denied. One Marmur loan request is already open.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loans")
        return
    end

    local principal = math.floor(tonumber(offer.principal) or 0)
    local termMonths = math.floor(tonumber(offer.termMonths or offer.termPayments) or self:getLoanTermMonths())
    if termMonths <= 0 then termMonths = self:getLoanTermMonths() end

    local ok = false
    pcall(function() ok = Bank:submitManualLoanApplication(principal, "monthly", termMonths) end)
    if ok then
        self.confirmMode = "loanreview"
        self.lastAmount = principal
        self.loanSelectedOffer = offer.index or 0
        self:updateLastLoanConfirmationNumber()
        self:setLoanError("")
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError("Application could not be submitted. Check credit standing, active loans, and session state.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loans")
    end
end

function shell:getLoanPaymentFrequency()
    local freq = tostring(self.loanPaymentFrequency or "monthly")
    if freq ~= "weekly" and freq ~= "biweekly" and freq ~= "monthly" then
        freq = "monthly"
    end
    return freq
end

function shell:getLoanPaymentFrequencyLabel(freq)
    local value = tostring(freq or self:getLoanPaymentFrequency())
    if value == "weekly" then return "Weekly" end
    if value == "biweekly" then return "Biweekly" end
    return "Monthly"
end

function shell:setLoanPaymentFrequency(freq)
    self.loanPaymentFrequency = tostring(freq or "monthly")
    self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans")
end

function shell:buildLoanFrequencyButton(parent, label, freq, x, y, w, h)
    local selected = self:getLoanPaymentFrequency() == tostring(freq or "monthly")
    self:createButton(parent, label, x, y, w, h, function() self:setLoanPaymentFrequency(freq) end, {
        fgColor = selected and color.gold or color.cyan,
        bgColor = selected and color.brandPanel3 or color.brandPanel2,
        fontSize = 28,
        active = selected
    })
end

function shell:getLoanTermMonths()
    local months = math.floor(tonumber(self.loanTermMonths) or 36)
    if months < 12 then months = 12 end
    if months > 84 then months = 84 end
    return months
end

function shell:setLoanTermMonths(months)
    self.loanTermMonths = math.floor(tonumber(months) or 36)
    if self.loanTermMonths < 12 then self.loanTermMonths = 12 end
    if self.loanTermMonths > 84 then self.loanTermMonths = 84 end
    self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans")
end

function shell:adjustLoanTermMonths(delta)
    self:setLoanTermMonths(self:getLoanTermMonths() + math.floor(tonumber(delta) or 0))
end

function shell:buildLoanTermButton(parent, months, x, y, w, h)
    local selected = self:getLoanTermMonths() == math.floor(tonumber(months) or 36)
    local label = tostring(months) .. " mo"
    self:createButton(parent, label, x, y, w, h, function() self:setLoanTermMonths(months) end, {
        fgColor = selected and color.gold or color.cyan,
        bgColor = selected and color.brandPanel3 or color.brandPanel2,
        fontSize = 24,
        active = selected
    })
end

function shell:updateLoanSignatureButtonState()
    if not self.loanSignatureWidgets or not self.loanSignatureWidgets.signBorder then return end
    if self.loanSignatureFilled == true then
        self.loanSignatureWidgets.signBorder:SetTintColor(color.green)
        self.loanSignatureWidgets.signBorder:SetOpacity(0.84)
        self.loanSignatureWidgets.signLabel:SetTintColor(color.green)
        if self.loanSignatureWidgets.helper then
            self.loanSignatureWidgets.helper:SetText(ink.translate("Signature captured. Acceptance unlocked."))
            self.loanSignatureWidgets.helper:SetTintColor(color.green)
        end
    else
        self.loanSignatureWidgets.signBorder:SetTintColor(color.gold)
        self.loanSignatureWidgets.signBorder:SetOpacity(0.0)
        self.loanSignatureWidgets.signLabel:SetTintColor(color.dim)
        if self.loanSignatureWidgets.helper then
            self.loanSignatureWidgets.helper:SetText(ink.translate("Select the signature field to auto-fill your name."))
            self.loanSignatureWidgets.helper:SetTintColor(color.dim)
        end
    end
end

function shell:createLoanSignatureField(parent, x, y, w, h)
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local border = ink.rect(0, 0, w, h, color.dim)
    border:Reparent(holder, -1)
    local fill = ink.rect(3, 3, w - 6, h - 6, color.brandPanel2)
    fill:Reparent(holder, -1)

    local label = ink.text("DIGITAL SIGNATURE", 28, 14, 25, color.dim)
    label:Reparent(holder, -1)

    local value = ink.text(self.loanSignatureFilled and self:getPlayerSignatureName() or "", 28, 52, 56, color.white)
    value:SetSize(Vector2.new({ X = w - 56, Y = 64 }))
    value:Reparent(holder, -1)

    local hint = ink.text(self.loanSignatureFilled and "Signature verified" or "Click to sign", w - 260, 20, 28, self.loanSignatureFilled and color.green or color.gold)
    hint:SetSize(Vector2.new({ X = 230, Y = 40 }))
    hint:Reparent(holder, -1)

    self:addSubscriber(fill, {
        hoverIn = function()
            border:SetTintColor(color.white)
        end,
        hoverOut = function()
            border:SetTintColor(self.loanSignatureFilled and color.green or color.dim)
        end,
        click = function()
            if self.loanSignatureToken or self.loanSignatureFilled then return end
            utils.playSound("ui_menu_onpress", 1)
            local fillText = self:getPlayerSignatureName()
            local chars = {}
            for i = 1, #fillText do
                chars[i] = fillText:sub(i, i)
            end
            value:SetText("")
            hint:SetText(ink.translate("Signing..."))
            hint:SetTintColor(color.cyan)
            border:SetTintColor(color.cyan)
            self.loanSignatureToken = Cron.Every(0.075, function(timer)
                local tick = timer.tick or 1
                if tick <= #chars then
                    value:SetText((value:GetText() or "") .. chars[tick])
                    timer.tick = tick + 1
                else
                    Cron.Halt(timer)
                    self.loanSignatureToken = nil
                    self.loanSignatureFilled = true
                    hint:SetText(ink.translate("Signature verified"))
                    hint:SetTintColor(color.green)
                    self:updateLoanSignatureButtonState()
                end
            end, { tick = 1 })
        end,
    })

    return { canvas = holder, border = border, fill = fill, text = value, hint = hint }
end

function shell:acceptApprovedLoanTerms(data)
    if self.loanSignatureFilled ~= true then
        self:setLoanError("Signature required before funds release.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loans")
        return
    end

    local ok = false
    pcall(function() ok = Bank:acceptApprovedManualLoan() end)
    if ok then
        self.confirmMode = "loansign"
        self.loanWasPaidOff = false
        local amount = self.lastAmount or 0
        pcall(function()
            local loan = Bank:getLoanData() or {}
            amount = loan.reviewAmount or amount
        end)
        self.lastAmount = amount
        self.loanSignatureFilled = false
        self.loanSignatureWidgets = {}
        self:updateLastLoanConfirmationNumber()
        self:setLoanError("")
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError("Agreement could not be signed. Refresh loan status and try again.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loans")
    end
end

function shell:cancelLoanProcess()
    self.loanSignatureFilled = false
    self.loanSignatureWidgets = {}
    self:clearLoanSignatureTimer()
    local ok = false
    pcall(function() ok = Bank:cancelManualLoanProcess() end)
    if ok then
        self:setLoanError("")
        utils.playSound("ui_menu_onpress", 1)
    else
        self:setLoanError("Loan request could not be canceled from this status.")
    end
    self:renderPage("loans")
end

function shell:submitLoanRequest(amount, data)
    local snapshot = data or self:getBankData()
    local loan = snapshot.loan or {}
    local returnPage = self.activePage == "loanapply" and "loanapply" or "loans"
    amount = math.floor(tonumber(amount) or 0)

    if loan.active then
        self:setLoanError("Application denied. One active Marmur loan is already open.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(returnPage)
        return
    end

    if loan.reviewActive then
        self:setLoanError("Application already has a pending status. Check the loan page for the current decision or funding window.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(returnPage)
        return
    end

    if amount <= 0 then
        self:setLoanError("Enter a requested loan amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(returnPage)
        return
    end

    local maxPrincipal = 100000000
    pcall(function() maxPrincipal = Bank:getManualLoanMaxPrincipal() or maxPrincipal end)
    if amount > maxPrincipal then
        self:setLoanError("Maximum single loan request is E$ " .. utils.formatNumber(maxPrincipal) .. ".")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(returnPage)
        return
    end

    local ok = false
    pcall(function() ok = Bank:submitManualLoanApplication(amount, self:getLoanPaymentFrequency(), self:getLoanTermMonths()) end)
    if ok then
        self.loanSignatureFilled = false
        self.loanSignatureWidgets = {}
        self:clearLoanSignatureTimer()
        self.confirmMode = "loanreview"
        self.loanWasPaidOff = false
        self.lastAmount = amount
        self.loanSignatureFilled = false
        self.loanSignatureWidgets = {}
        self:updateLastLoanConfirmationNumber()
        self:setCustomAmountString("loanrequest", "")
        self:setLoanError("")
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError("Application could not be submitted. Check active loan status and session state.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(returnPage)
    end
end

function shell:submitLoanPayment(amount, data)
    local snapshot = data or self:getBankData()
    local loan = snapshot.loan or {}
    amount = tonumber(amount) or 0

    if not loan.active then
        self:setLoanError("No active loan is available for repayment.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end

    if amount <= 0 then
        self:setLoanError("Enter a repayment amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end

    if amount > (snapshot.wallet or 0) then
        self:setLoanError("Repayment exceeds checking balance.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end

    local earlyPayoff = self:getLoanEarlyPayoffAmountFromData(loan)
    if earlyPayoff <= 0 then earlyPayoff = loan.balanceDue or 0 end
    if amount > earlyPayoff then
        self:setLoanError("Repayment exceeds the current early payoff amount.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end

    local beforeDue = loan.balanceDue or 0
    local ok = false
    local payoffAttempt = earlyPayoff > 0 and amount >= earlyPayoff
    if payoffAttempt then
        pcall(function() ok = Bank:payLoanInFull() end)
    else
        pcall(function() ok = Bank:payLoan(amount) end)
    end
    if ok then
        local afterDue = 0
        pcall(function() afterDue = Bank:getLoanData().balanceDue or 0 end)
        self.confirmMode = "loanpay"
        self.loanWasPaidOff = payoffAttempt or afterDue <= 0
        self.lastAmount = payoffAttempt and earlyPayoff or math.max(beforeDue - afterDue, 0)
        self:updateLastLoanConfirmationNumber()
        self:setCustomAmountString("loanpay", "")
        self:setLoanError("")
        pcall(function() Bank.lastLoanBalance = afterDue end)
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError("Repayment could not be completed.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
    end
end

function shell:payLoanFull(data)
    local snapshot = data or self:getBankData()
    local loan = snapshot.loan or {}
    if not loan.active then
        self:setLoanError("No active loan is available for payoff.")
        self:renderPage("loanpay")
        return
    end

    local earlyPayoff = self:getLoanEarlyPayoffAmountFromData(loan)
    if earlyPayoff <= 0 then earlyPayoff = loan.balanceDue or 0 end
    if (snapshot.wallet or 0) < earlyPayoff then
        self:setLoanError("Checking balance is too low for the current early payoff amount. Use manual payment instead.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end

    local ok = false
    pcall(function() ok = Bank:payLoanInFull() end)
    if ok then
        self.confirmMode = "loanpay"
        self.loanWasPaidOff = true
        self.lastAmount = earlyPayoff
        self:updateLastLoanConfirmationNumber()
        self:setCustomAmountString("loanpay", "")
        self:setLoanError("")
        pcall(function() Bank.lastLoanBalance = 0 end)
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError("Full payoff could not be completed.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
    end
end

function shell:buildLoanOfferRow(parent, offer, y, streetCred, activeLoan)
    local eligible = streetCred >= (offer.requiredStreetCred or 0)
    local accent = eligible and color.green or color.gold
    local row = self:makePanel(parent, 40, y, 1820, 86)

    local name = ink.text("TIER " .. tostring(offer.index or 0), 24, 22, 31, accent)
    name:SetSize(Vector2.new({ X = 170, Y = 42 }))
    name:Reparent(row, -1)

    local principal = ink.text("E$ " .. utils.formatNumber(offer.principal or 0), 220, 22, 32, color.white)
    principal:SetSize(Vector2.new({ X = 280, Y = 42 }))
    principal:Reparent(row, -1)

    local rate = ink.text(self:loanRateLabel(offer.interestBasisPoints) .. " APR", 520, 23, 29, color.green)
    rate:SetSize(Vector2.new({ X = 220, Y = 40 }))
    rate:Reparent(row, -1)

    local term = ink.text(tostring(offer.termPayments or 6) .. " x " .. tostring(offer.intervalDays or 30) .. "d", 770, 23, 29, color.dim)
    term:SetSize(Vector2.new({ X = 190, Y = 40 }))
    term:Reparent(row, -1)

    local pay = ink.text("Due: E$ " .. utils.formatNumber(offer.installment or 0), 1000, 23, 29, color.cyan)
    pay:SetSize(Vector2.new({ X = 310, Y = 40 }))
    pay:Reparent(row, -1)

    local req = ink.text("Credit level " .. tostring(offer.requiredStreetCred or 0), 1345, 23, 25, eligible and color.green or color.gold)
    req:SetSize(Vector2.new({ X = 140, Y = 40 }))
    req:Reparent(row, -1)

    local label = "Apply"
    if activeLoan then
        label = "ACTIVE"
    elseif not eligible then
        label = "LOCKED"
    end

    self:createButton(row, label, 1535, 14, 250, 58, function() self:performLoanApplication(offer) end, { fgColor = accent, fontSize = 26 })
end


function shell:submitCloseAccount(data)
    local snapshot = data or self:getBankData()
    local loan = snapshot.loan or {}
    local autoLoans = snapshot.autoLoans or {}
    if loan.active == true or loan.reviewActive == true or loan.reviewPending == true or loan.reviewApprovalReady == true or loan.reviewFundingPending == true or #autoLoans > 0 then
        self:setTransferError("closeaccount", "Account closure blocked. Pay off or cancel all loan obligations first.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("closeaccount")
        return
    end
    if self.accountSignatureFilled ~= true then
        self:setTransferError("closeaccount", "Digital signature required before account closure.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("closeaccount")
        return
    end

    local ok = false
    local reason = ""
    local returned = 0
    local chargeback = 0
    pcall(function() ok, reason, returned, chargeback = Bank:closeAccount() end)
    if ok then
        self.confirmMode = "closeaccount"
        self.lastAmount = math.floor(tonumber(returned) or 0)
        self.lastClosureChargeback = math.floor(tonumber(chargeback) or 0)
        self:setTransferError("closeaccount", "")
        self.accountSignatureFilled = false
        self.accountSignatureWidgets = {}
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        local msg = "Account closure could not be completed."
        if reason == "loan" then msg = "Account closure blocked. Pay off or cancel all loan obligations first."
        elseif reason == "no_account" then msg = "No active account is available to close."
        elseif reason == "fee_funds" then msg = "Closing requires enough checking/savings to cover the early closure fee."
        elseif reason == "withdraw" then msg = "Final balance return failed. Try again after refreshing account balances." end
        self:setTransferError("closeaccount", msg)
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("closeaccount")
    end
end

function shell:buildCloseAccountPage()
    local data = self:getBankData()
    local loan = data.loan or {}
    local autoLoans = data.autoLoans or {}
    local errorText = self:getTransferError("closeaccount")
    local loanReviewActive = loan.reviewActive == true or loan.reviewPending == true or loan.reviewApprovalReady == true or loan.reviewFundingPending == true
    local blocked = loan.active == true or loanReviewActive or #autoLoans > 0
    local closingBalance = math.max(math.floor(tonumber(data.bank) or 0), 0)
    local chargeback = math.max(math.floor(tonumber(data.closingChargeback) or 0), 0)
    local pendingForfeit = math.max(math.floor(tonumber(data.pendingIncentive) or 0), 0)
    local checkingAfter = math.max(math.floor((tonumber(data.wallet) or 0) + closingBalance - chargeback), 0)

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local titleText = blocked and "ACCOUNT CLOSURE UNAVAILABLE" or "CLOSE MARMUR ACCOUNT"
    local titleColor = blocked and color.gold or color.red
    local title = ink.text(titleText, 40, 24, 50, titleColor)
    title:Reparent(strip, -1)
    local subtitleText = blocked and "All active and pending loan obligations must be resolved before the account can close." or "Review the final settlement and sign the digital closure authorization."
    local subtitle = ink.text(subtitleText, 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Savings Return", "E$ " .. utils.formatNumber(closingBalance), 1660, 30, blocked and color.dim or color.gold, 340, 22, 34)
    self:drawHeaderStat(strip, "Closure Fee", "E$ " .. utils.formatNumber(chargeback), 2030, 30, chargeback > 0 and color.red or color.white, 330, 22, 34)
    self:drawHeaderStat(strip, "Checking After", "E$ " .. utils.formatNumber(checkingAfter), 2390, 30, blocked and color.dim or color.cyan, 370, 22, 34)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1740, 680)
    local right = self:makePanel(self.contentCanvas, 1850, 650, 1030, 680)

    if blocked then
        local lh = ink.text("REQUIRED BEFORE CLOSURE", 38, 24, 43, color.gold)
        lh:Reparent(left, -1)
        local reason = loanReviewActive and "A personal-loan request is still under review, approved but unsigned, or waiting for funding." or "One or more active loans remain attached to this account."
        if #autoLoans > 0 and loan.active ~= true and loanReviewActive ~= true then
            reason = "One or more Vanguard Auto financing contracts remain attached to this account."
        elseif #autoLoans > 0 then
            reason = reason .. " Vanguard Auto financing is also still active."
        end
        local copy = ink.text(reason, 40, 88, 29, color.white)
        copy:SetWrapping(true)
        copy:SetSize(Vector2.new({ X = 1640, Y = 104 }))
        copy:Reparent(left, -1)
        self:drawPolishedRow(left, "Personal Loan", loanReviewActive and "PENDING REVIEW" or (loan.active == true and "ACTIVE" or "CLEAR"), 216, { x = 40, width = 1640, labelWidth = 500, valueColor = (loan.active == true or loanReviewActive) and color.red or (color.riskGreen or color.white) })
        self:drawPolishedRow(left, "Personal Loan Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 282, { x = 40, width = 1640, labelWidth = 500, valueColor = (tonumber(loan.balanceDue) or 0) > 0 and color.gold or color.white })
        self:drawPolishedRow(left, "Vanguard Auto Loans", tostring(#autoLoans) .. (#autoLoans == 1 and " active contract" or " active contracts"), 348, { x = 40, width = 1640, labelWidth = 500, valueColor = #autoLoans > 0 and color.red or color.white })
        self:drawPolishedRow(left, "Closure Status", "LOCKED", 414, { x = 40, width = 1640, labelWidth = 500, valueColor = color.red })
        local note = self:makePanel(left, 40, 506, 1640, 118)
        local noteCopy = (#errorText > 0) and errorText or "Pay off active balances or cancel an unresolved personal-loan request. Closure becomes available as soon as the Loans page shows no active or pending obligations."
        local nt = ink.text(noteCopy, 26, 18, 25, (#errorText > 0) and color.red or color.dim)
        nt:SetWrapping(true)
        nt:SetSize(Vector2.new({ X = 1580, Y = 82 }))
        nt:Reparent(note, -1)

        local rh = ink.text("RESOLVE OBLIGATIONS", 38, 24, 43, color.cyan)
        rh:Reparent(right, -1)
        local rcopy = ink.text("Open Loans to review every personal and automobile balance connected to this account.", 40, 88, 28, color.dim)
        rcopy:SetWrapping(true)
        rcopy:SetSize(Vector2.new({ X = 930, Y = 96 }))
        rcopy:Reparent(right, -1)
        self:createTransferAction(right, "OPEN LOANS", 40, 230, 950, 92, function() self:renderPage("loans") end, true)
        self:createTransferKey(right, "BACK TO SERVICES", 40, 362, 950, 78, function() self:renderPage("services") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        self:createTransferKey(right, "BACK TO HOME", 40, 478, 950, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        return
    end

    local lh = ink.text("FINAL SETTLEMENT", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    self:drawPolishedRow(left, "Current Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 94, { x = 40, width = 1640, labelWidth = 510, valueColor = color.white })
    self:drawPolishedRow(left, "Savings Returned", "E$ " .. utils.formatNumber(closingBalance), 160, { x = 40, width = 1640, labelWidth = 510, valueColor = color.gold })
    self:drawPolishedRow(left, "Early Closure Fee", "E$ " .. utils.formatNumber(chargeback), 226, { x = 40, width = 1640, labelWidth = 510, valueColor = chargeback > 0 and color.red or color.white })
    self:drawPolishedRow(left, "Final Checking Balance", "E$ " .. utils.formatNumber(checkingAfter), 292, { x = 40, width = 1640, labelWidth = 510, valueColor = color.cyan, valueFontSize = 34 })
    self:drawPolishedRow(left, "Loan Obligations", "CLEAR", 358, { x = 40, width = 1640, labelWidth = 510, valueColor = color.riskGreen or color.white })
    self:drawPolishedRow(left, "Account Status After", "CLOSED", 424, { x = 40, width = 1640, labelWidth = 510, valueColor = color.red })

    local noteText = "Savings return to Checking immediately. Any applicable Early Closure Fee is included in the final balance shown above."
    if pendingForfeit > 0 and chargeback <= 0 then
        noteText = "The pending opening credit is forfeited because the account is closing before the 72-hour payout hold ends."
    end
    local note = self:makePanel(left, 40, 516, 1640, 108)
    local nt = ink.text(noteText, 26, 18, 25, color.dim)
    nt:SetWrapping(true)
    nt:SetSize(Vector2.new({ X = 1580, Y = 72 }))
    nt:Reparent(note, -1)

    local rh = ink.text("DIGITAL AUTHORIZATION", 38, 24, 43, color.red)
    rh:Reparent(right, -1)
    local rcopy = ink.text("Signing authorizes Marmur Bank to close the Savings ledger, return eligible funds to Checking, and apply the displayed fee.", 40, 82, 25, color.dim)
    rcopy:SetWrapping(true)
    rcopy:SetSize(Vector2.new({ X = 930, Y = 92 }))
    rcopy:Reparent(right, -1)

    self.accountSignatureWidgets.signature = self:createAccountSignatureField(right, 40, 186, 950, 110)
    local helper = ink.text("Select the signature field to auto-fill your legal name.", 40, 310, 23, color.dim)
    helper:SetWrapping(true)
    helper:SetSize(Vector2.new({ X = 930, Y = 38 }))
    helper:Reparent(right, -1)
    self.accountSignatureWidgets.helper = helper

    local signHolder = ink.canvas(40, 374, inkEAnchor.TopLeft)
    signHolder:SetSize(Vector2.new({ X = 950, Y = 84 }))
    signHolder:Reparent(right, -1)
    local staticBorder = ink.rect(0, 0, 950, 84, color.brandRed or color.red)
    staticBorder:SetOpacity(0.24)
    staticBorder:Reparent(signHolder, -1)
    local signBorder = ink.rect(2, 2, 946, 80, color.red)
    signBorder:SetOpacity(self.accountSignatureFilled and 0.84 or 0.0)
    signBorder:Reparent(signHolder, -1)
    local signLabel = ink.text("CONFIRM ACCOUNT CLOSURE", 475, 38, 31, self.accountSignatureFilled and color.red or color.dim)
    signLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    signLabel:SetSize(Vector2.new({ X = 910, Y = 56 }))
    signLabel:Reparent(signHolder, -1)
    local signHotspot = ink.rect(0, 0, 950, 84, color.white)
    signHotspot:SetOpacity(0.01)
    signHotspot:Reparent(signHolder, -1)
    self.accountSignatureWidgets.signBorder = signBorder
    self.accountSignatureWidgets.signLabel = signLabel
    self:addSubscriber(signHotspot, {
        hoverIn = function()
            signLabel:SetTintColor(color.red)
            signBorder:SetTintColor(color.red)
            signBorder:SetOpacity(0.92)
        end,
        hoverOut = function() self:updateAccountSignatureButtonState() end,
        click = function() self:submitCloseAccount(data) end,
    })
    self:updateAccountSignatureButtonState()

    self:createTransferKey(right, "BACK TO SERVICES", 40, 486, 950, 66, function() self:renderPage("services") end, { borderColor = color.dim, textColor = color.white, fontSize = 27 })
    local msg = (#errorText > 0) and errorText or "Closure is immediate. A new Marmur account can be opened later from Sign In."
    local err = ink.text(msg, 40, 580, 22, (#errorText > 0) and color.red or color.dim)
    err:SetWrapping(true)
    err:SetSize(Vector2.new({ X = 930, Y = 58 }))
    err:Reparent(right, -1)
end

function shell:buildServicesPage()
    local data = self:getBankData()
    local loyalty = data.loyalty or {}
    local svc = data.service or self:calculatePrivateClientService(data.bank, 0, loyalty)
    local cashback = data.cashback or {}
    local tierName = tostring(loyalty.tier or cashback.tier or svc.tier or "Standard")
    local destination = tostring(cashback.destinationLabel or "Checking")
    local cashbackRate = self:formatCashbackRate(cashback.rateBp, cashback.ratePercent or svc.cashbackPercent)
    local averageBalance = math.max(math.floor(tonumber(loyalty.averageBalance) or 0), 0)
    local activeTier = math.max(0, math.min(math.floor(tonumber(loyalty.activeTier) or 0), 4))
    local nextTier, nextNeeded = self:getNextAccountTier(averageBalance, activeTier)
    local nextMilestone = nextTier and ("E$ " .. utils.formatNumber(nextNeeded) .. " to " .. tostring(nextTier.name)) or "Highest level active"
    local context = Calendar.getContext()
    local nextPayout = "Not scheduled"
    if math.floor(tonumber(cashback.nextPayoutStamp) or 0) > 0 then
        nextPayout = Calendar.formatMinuteStamp(cashback.nextPayoutStamp, context, true)
    end
    local auto = nil
    pcall(function() auto = Bank:getAutoDepositSettings() end)
    auto = auto or { active = false, amount = 0, intervalDays = 7, nextStamp = 0 }

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 150)
    local title = ink.text("ACCOUNT SERVICES", 40, 18, 50, color.brandWhite or color.white)
    title:Reparent(strip, -1)
    local subtitle = ink.text("Manage your account level, cashback destination, and core banking settings.", 42, 84, 27, color.dim)
    subtitle:SetSize(Vector2.new({ X = 1480, Y = 46 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Account Level", tierName, 1570, 28, color.brandRedBright or color.red, 390, 24, 34)
    self:drawHeaderStat(strip, "Cashback", cashbackRate, 1990, 28, color.cashbackGreen or color.white, 330, 24, 36)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(data.bank or 0), 2350, 28, color.white, 410, 24, 34)

    local levelPanel = self:makePanel(self.contentCanvas, 80, 650, 1340, 570)
    local levelHead = ink.text("ACCOUNT LEVEL", 38, 16, 40, color.cyan)
    levelHead:Reparent(levelPanel, -1)
    local levelSub = ink.text("Based on your rolling seven-day Savings average.", 40, 70, 24, color.dim)
    levelSub:SetSize(Vector2.new({ X = 1180, Y = 34 }))
    levelSub:Reparent(levelPanel, -1)

    self:drawHeaderStat(levelPanel, "Current Level", tierName, 40, 112, color.brandRedBright or color.red, 380, 23, 38)
    self:drawHeaderStat(levelPanel, "7-Day Average", "E$ " .. utils.formatNumber(averageBalance), 450, 112, color.white, 390, 23, 34)
    self:drawHeaderStat(levelPanel, "Next Milestone", nextMilestone, 870, 112, nextTier and color.white or color.brandRedBright, 410, 23, 29)

    local tableTop = 224
    local tableRule = ink.rect(38, tableTop - 12, 1264, 2, color.brandRed or color.red)
    tableRule:SetOpacity(0.32)
    tableRule:Reparent(levelPanel, -1)
    local rowY = tableTop
    for _, tier in ipairs(self:getAccountTierRows()) do
        local active = math.floor(tonumber(tier.index) or 0) == activeTier
        if active then
            local activeBg = ink.rect(30, rowY - 4, 1276, 54, color.brandRed or color.red)
            activeBg:SetOpacity(0.15)
            activeBg:Reparent(levelPanel, -1)
            local activeBar = ink.rect(30, rowY - 4, 5, 54, color.brandRedBright or color.red)
            activeBar:SetOpacity(0.92)
            activeBar:Reparent(levelPanel, -1)
        end
        local range = ink.text(tier.range, 52, rowY + 4, 24, active and color.white or color.dim)
        range:SetSize(Vector2.new({ X = 230, Y = 34 }))
        range:Reparent(levelPanel, -1)
        local name = ink.text(tier.name, 320, rowY + 2, 27, active and color.brandRedBright or color.white)
        name:SetSize(Vector2.new({ X = 420, Y = 36 }))
        name:Reparent(levelPanel, -1)
        local reward = ink.text(tier.cashback .. " cashback", 800, rowY + 4, 24, active and (color.cashbackGreen or color.white) or color.dim)
        reward:SetSize(Vector2.new({ X = 260, Y = 34 }))
        reward:Reparent(levelPanel, -1)
        local status = ink.text(active and "CURRENT" or "", 1260, rowY + 4, 22, color.brandRedBright or color.red)
        status:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
        status:SetSize(Vector2.new({ X = 170, Y = 32 }))
        status:Reparent(levelPanel, -1)
        rowY = rowY + 58
    end
    local levelNote = ink.text("Earned levels remain protected to 75% of their threshold. Three full days below that floor may lower the level.", 40, 526, 22, color.dim)
    levelNote:SetSize(Vector2.new({ X = 1240, Y = 40 }))
    levelNote:Reparent(levelPanel, -1)

    local cashbackPanel = self:makePanel(self.contentCanvas, 1460, 650, 1420, 570)
    local cbHead = ink.text("CASHBACK REWARDS", 38, 16, 40, color.cyan)
    cbHead:Reparent(cashbackPanel, -1)
    local cbSub = ink.text("Rewards post every seven days at 3:00 PM.", 40, 70, 24, color.dim)
    cbSub:SetSize(Vector2.new({ X = 1180, Y = 34 }))
    cbSub:Reparent(cashbackPanel, -1)

    self:drawHeaderStat(cashbackPanel, "Current Rate", cashbackRate, 40, 112, color.cashbackGreen or color.white, 330, 23, 42)
    self:drawHeaderStat(cashbackPanel, "Pending", "E$ " .. utils.formatNumber(cashback.pendingEarned or 0), 410, 112, color.brandRedBright or color.red, 380, 23, 36)
    self:drawHeaderStat(cashbackPanel, "Total Paid", "E$ " .. utils.formatNumber(cashback.totalEarned or 0), 820, 112, color.white, 360, 23, 36)

    local destinationLabel = ink.text("REWARD DESTINATION", 40, 220, 23, color.dim)
    destinationLabel:Reparent(cashbackPanel, -1)
    self:createTransferKey(cashbackPanel, "CHECKING", 40, 258, 620, 68, function()
        pcall(function() Bank:setCashbackDestination("checking") end)
        self:renderPage("services")
    end, {
        borderColor = destination == "Checking" and (color.brandRedBright or color.red) or color.dim,
        textColor = destination == "Checking" and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = destination == "Checking" and 0.72 or 0.42,
    })
    self:createTransferKey(cashbackPanel, "SAVINGS", 690, 258, 620, 68, function()
        pcall(function() Bank:setCashbackDestination("savings") end)
        self:renderPage("services")
    end, {
        borderColor = destination == "Savings" and (color.brandRedBright or color.red) or color.dim,
        textColor = destination == "Savings" and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = destination == "Savings" and 0.72 or 0.42,
    })

    self:drawPolishedRow(cashbackPanel, "Next Payout", nextPayout, 354, { x = 40, width = 1270, labelWidth = 360, valueColor = color.white, valueFontSize = 26 })
    self:drawPolishedRow(cashbackPanel, "Reward Base", "E$ " .. utils.formatNumber(cashback.totalSpend or 0), 414, { x = 40, width = 1270, labelWidth = 360, valueColor = color.white, valueFontSize = 28 })
    local lastText = (tonumber(cashback.lastEarned) or 0) > 0
        and ("Last payout: E$ " .. utils.formatNumber(cashback.lastEarned or 0))
        or "No cashback payout has posted yet."
    self:drawPolishedRow(cashbackPanel, "Most Recent", lastText, 474, { x = 40, width = 1270, labelWidth = 360, valueColor = color.dim, valueFontSize = 24, drawLine = false })

    local management = self:makePanel(self.contentCanvas, 80, 1235, 2800, 195)
    local managementHead = ink.text("ACCOUNT MANAGEMENT", 30, 14, 35, color.cyan)
    managementHead:Reparent(management, -1)
    local accountLabel = tostring(data.accountNumber or "MB-2077-00000000")
    self:drawHeaderStat(management, "Account Number", accountLabel, 30, 64, color.white, 470, 20, 28)
    self:drawHeaderStat(management, "Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 520, 64, color.white, 390, 20, 29)
    self:drawHeaderStat(management, "Savings", "E$ " .. utils.formatNumber(data.bank or 0), 930, 64, color.brandRedBright or color.red, 390, 20, 29)
    self:drawHeaderStat(management, "Auto-Deposit", auto.active == true and (self:getAutoDepositPresetLabel(auto.intervalDays) .. " • E$ " .. utils.formatNumber(auto.amount or 0)) or "Not Scheduled", 1340, 64, auto.active == true and color.white or color.dim, 500, 20, 25)

    self:createTransferKey(management, "VIEW ACTIVITY", 1870, 82, 270, 66, function() self:renderPage("transactions") end, {
        borderColor = color.dim, textColor = color.white, fontSize = 23, fillOpacity = 0.42,
    })
    self:createTransferKey(management, "DISCLOSURES", 2160, 82, 270, 66, function() self:renderPage("disclosures") end, {
        borderColor = color.dim, textColor = color.white, fontSize = 23, fillOpacity = 0.42,
    })
    self:createTransferKey(management, "CLOSE ACCOUNT", 2450, 82, 320, 66, function() self:renderPage("closeaccount") end, {
        borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, hoverColor = color.brandWhite or color.white, fontSize = 23, fillOpacity = 0.50,
    })

    local statusCopy = ink.text(tostring(loyalty.statusText or "Marmur Bank recognizes financial growth and account loyalty."), 30, 158, 22, loyalty.atRisk == true and (color.brandRedBright or color.red) or color.dim)
    statusCopy:SetWrapping(true)
    statusCopy:SetSize(Vector2.new({ X = 1760, Y = 34 }))
    statusCopy:Reparent(management, -1)
end

function shell:getCreditTierLabel(streetCred)
    streetCred = tonumber(streetCred) or 0
    if streetCred >= 35 then return "GREAT" end
    if streetCred >= 20 then return "BETTER" end
    if streetCred >= 10 then return "GOOD" end
    return "BAD"
end

function shell:getCreditTierColor(tierLabel)
    if tierLabel == "GREAT" then return color.green end
    if tierLabel == "BETTER" then return color.cyan end
    if tierLabel == "GOOD" then return color.orange or color.gold end
    return color.red
end

function shell:getCreditTierRequiredLabel(requiredStreetCred)
    requiredStreetCred = tonumber(requiredStreetCred) or 1
    if requiredStreetCred >= 35 then return "GREAT" end
    if requiredStreetCred >= 20 then return "BETTER" end
    if requiredStreetCred >= 10 then return "GOOD" end
    return "BAD"
end

function shell:getApprovalRiskColor(risk)
    local label = string.upper(tostring(risk or "HIGH"))
    if label == "LOW" then return color.riskGreen or color.green end
    if label == "MEDIUM" then return color.riskOrange or color.gold end
    return color.riskRed or color.red
end

function shell:getSelectedAutoLoan(autoLoans)
    autoLoans = autoLoans or {}
    if #autoLoans <= 0 then return nil end
    local idx = math.floor(tonumber(self.autoLoanSelectedIndex or 1) or 1)
    if idx < 1 then idx = 1 end
    if idx > #autoLoans then idx = #autoLoans end
    self.autoLoanSelectedIndex = idx
    return autoLoans[idx]
end

function shell:buildAutoLoansOverview(data, autoLoans, personalLoan)
    autoLoans = autoLoans or {}
    personalLoan = personalLoan or {}
    local message = tostring(self.lastAutoLoanMessage or "")
    local activeItems = {}
    local autoBalance = 0

    local personalActive = personalLoan and personalLoan.active == true and (tonumber(personalLoan.balanceDue) or 0) > 0
    if personalActive then
        local missed = math.max(math.floor(tonumber(personalLoan.missedPayments) or 0), 0)
        local paidToDate = math.max((tonumber(personalLoan.originalDue) or 0) - (tonumber(personalLoan.balanceDue) or 0), 0)
        table.insert(activeItems, {
            kind = "personal",
            title = "Marmur Personal Loan",
            status = missed > 0 and "PAST DUE" or "ACTIVE",
            statusColor = missed > 0 and (color.orange or color.gold) or color.green,
            balanceDue = math.max(math.floor(tonumber(personalLoan.balanceDue) or 0), 0),
            scheduledPayment = math.max(math.floor(tonumber(personalLoan.installment) or 0), 0),
            frequencyLabel = "Installment",
            nextDueText = self:formatLoanDueCountdown(personalLoan, data),
            paidToDate = paidToDate,
            aprLabel = self:loanRateLabel(personalLoan.interestBasisPoints or 0),
            manage = function()
                self.lastAutoLoanMessage = ""
                self:renderPage("loanpay")
            end,
        })
    end

    for i, loan in ipairs(autoLoans) do
        if loan then
            local scheduledAmount = tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0
            local frequencyLabel = tostring(loan.frequencyLabel or "Monthly")
            local autoIndex = tonumber(loan.index) or i
            local autoBalanceDue = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
            local autoPayStatus
            local autoPayStatusColor
            local submittedRequest = loan.autoPayRequestKnown == true and (loan.autoPayRequested == true and "ON" or "OFF") or "?"
            if loan.repossessed then
                autoPayStatus = "REPOSSESSED"
                autoPayStatusColor = color.red
            elseif loan.autoPaySupported == true then
                autoPayStatus = "REQUEST " .. submittedRequest .. " / STATUS " .. (loan.autoPayEnabled == true and "ON" or "OFF")
                autoPayStatusColor = loan.autoPayEnabled == true and color.green or color.gold
            else
                autoPayStatus = "REQUEST " .. submittedRequest .. " / UPDATE REQUIRED"
                autoPayStatusColor = color.red
            end
            autoBalance = autoBalance + autoBalanceDue
            table.insert(activeItems, {
                kind = "auto",
                index = autoIndex,
                title = tostring(loan.title or "Vanguard Auto Loan"),
                status = autoPayStatus,
                statusColor = autoPayStatusColor,
                balanceDue = autoBalanceDue,
                scheduledPayment = math.max(math.floor(tonumber(scheduledAmount) or 0), 0),
                frequencyLabel = frequencyLabel,
                nextDueText = tostring(loan.nextDueText or "—"),
                repossessed = loan.repossessed == true,
                manage = function()
                    self.autoLoanSelectedIndex = autoIndex
                    self.autoLoanPage = self.autoLoanPage or 1
                    self.lastAutoLoanMessage = ""
                    self.autoLoanPaymentKeypadOpen = false
                    self:renderPage("autoloanpay")
                end,
            })
        end
    end

    local totalLoans = #activeItems
    local pageSize = math.floor(tonumber(self.autoLoanPageSize or 2) or 2)
    if pageSize < 1 then pageSize = 2 end
    if pageSize > 2 then pageSize = 2 end

    local totalPages = math.max(1, math.ceil(totalLoans / pageSize))
    local page = math.floor(tonumber(self.autoLoanPage or 1) or 1)
    if page < 1 then page = 1 end
    if page > totalPages then page = totalPages end

    self.autoLoanPage = page

    local left = self:makePanel(self.contentCanvas, 80, 650, 1520, 670)
    local right = self:makePanel(self.contentCanvas, 1630, 650, 1250, 670)

    local h1 = ink.text("ACTIVE LOAN OVERVIEW", 40, 28, 46, color.cyan)
    h1:Reparent(left, -1)
    local desc = ink.text("All active Marmur personal loans and Vanguard Auto liens serviced through this account.", 42, 82, 26, color.dim)
    desc:SetWrapping(true)
    desc:SetSize(Vector2.new({ X = 1320, Y = 56 }))
    desc:Reparent(left, -1)

    if #message > 0 then
        local msg = ink.text(message, 42, 128, 24, color.gold)
        msg:SetWrapping(true)
        msg:SetSize(Vector2.new({ X = 1320, Y = 42 }))
        msg:Reparent(left, -1)
    end

    self:createButton(left, "Refresh", 1050, 34, 180, 48, function() self:renderPage("loans") end, { fgColor = color.cyan, fontSize = 24 })
    self:createButton(left, "Home", 1250, 34, 190, 48, function() self:renderPage("home") end, { fgColor = color.green, fontSize = 24 })

    if totalLoans <= 0 then
        local empty = self:makePanel(left, 40, 172, 1440, 208)
        local emptyTitle = ink.text("No Active Loans", 34, 28, 40, color.gold)
        emptyTitle:Reparent(empty, -1)
        local emptyCopy = ink.text("Open auto loans and funded personal loans will appear here together once Marmur is servicing them.", 36, 92, 27, color.dim)
        emptyCopy:SetWrapping(true)
        emptyCopy:SetSize(Vector2.new({ X = 1260, Y = 70 }))
        emptyCopy:Reparent(empty, -1)
    end

    local startIndex = ((page - 1) * pageSize) + 1
    local endIndex = math.min(startIndex + pageSize - 1, totalLoans)
    local y = (#message > 0) and 178 or 152

    for i = startIndex, endIndex do
        local item = activeItems[i]
        if item then
            local card = self:makePanel(left, 40, y, 1440, 168)
            local kindLabel = item.kind == "personal" and "PERSONAL LOAN" or "AUTO LOAN"
            local kindText = ink.text(kindLabel, 30, 14, 22, item.kind == "personal" and color.gold or color.cyan)
            kindText:SetSize(Vector2.new({ X = 320, Y = 28 }))
            kindText:Reparent(card, -1)
            local name = ink.text(tostring(item.title or "Active Loan"), 30, 42, 32, color.gold)
            name:SetSize(Vector2.new({ X = 780, Y = 42 }))
            name:Reparent(card, -1)
            local statusFont = item.kind == "auto" and 19 or 28
            local status = ink.text(tostring(item.status or "ACTIVE"), 960, 24, statusFont, item.statusColor or color.green)
            status:SetSize(Vector2.new({ X = 400, Y = 36 }))
            status:Reparent(card, -1)
            self:drawKV(card, "Balance", "E$ " .. utils.formatNumber(item.balanceDue or 0), 30, 88, color.gold, 300, 38)
            self:drawKV(card, tostring(item.frequencyLabel or "Payment"), "E$ " .. utils.formatNumber(item.scheduledPayment or 0), 372, 88, color.green, 290, 38)
            self:drawKV(card, "Next Due", tostring(item.nextDueText or "—"), 706, 88, color.cyan, 300, 38)
            self:createButton(card, "Manage", 1110, 82, 280, 52, item.manage, { fgColor = color.green, fontSize = 27 })
            y = y + 172
        end
    end

    if totalPages > 1 then
        local prevCb = nil
        local nextCb = nil
        if page > 1 then
            prevCb = function()
                self.autoLoanPage = math.max(1, page - 1)
                self.lastAutoLoanMessage = ""
                self:renderPage("loans")
            end
        end
        if page < totalPages then
            nextCb = function()
                self.autoLoanPage = math.min(totalPages, page + 1)
                self.lastAutoLoanMessage = ""
                self:renderPage("loans")
            end
        end
        local pageText = ink.text("Page " .. tostring(page) .. " / " .. tostring(totalPages), 628, 610, 26, color.dim)
        pageText:SetSize(Vector2.new({ X = 260, Y = 34 }))
        pageText:Reparent(left, -1)
        self:createButton(left, "Previous", 332, 594, 250, 58, prevCb, { fgColor = color.cyan, fontSize = 28 })
        self:createButton(left, "Next", 916, 594, 250, 58, nextCb, { fgColor = color.cyan, fontSize = 28 })
    end

    local h2 = ink.text("LOAN SNAPSHOT", 40, 28, 46, color.cyan)
    h2:Reparent(right, -1)
    local summary = ink.text("Marmur shows every active obligation in one place while keeping the correct servicing rules for each loan type.", 42, 84, 26, color.dim)
    summary:SetWrapping(true)
    summary:SetSize(Vector2.new({ X = 1080, Y = 70 }))
    summary:Reparent(right, -1)

    local personalBalance = personalActive and math.max(tonumber(personalLoan.balanceDue) or 0, 0) or 0
    local totalBalance = autoBalance + personalBalance

    self:drawKV(right, "Active Loans", tostring(totalLoans), 40, 190, color.white)
    self:drawKV(right, "Total Balance", "E$ " .. utils.formatNumber(totalBalance), 650, 190, color.gold)
    self:drawKV(right, "Auto Balance", "E$ " .. utils.formatNumber(autoBalance), 40, 312, autoBalance > 0 and color.cyan or color.dim)
    self:drawKV(right, "Personal Balance", "E$ " .. utils.formatNumber(personalBalance), 650, 312, personalBalance > 0 and color.gold or color.dim)

    local note = self:makePanel(right, 40, 428, 1170, 104)
    local noteText = ink.text("Use Manage on any row to review payment terms, submit a manual payment, or pay the selected loan in full.", 28, 18, 24, color.white)
    noteText:SetWrapping(true)
    noteText:SetSize(Vector2.new({ X = 1080, Y = 68 }))
    noteText:Reparent(note, -1)

    local personalBusy = personalLoan and (personalLoan.active == true or personalLoan.reviewActive == true or personalLoan.reviewPending == true or personalLoan.reviewApprovalReady == true or personalLoan.reviewFundingPending == true)
    local personalTitle = ink.text("PERSONAL LOANS", 40, 552, 28, color.cyan)
    personalTitle:Reparent(right, -1)
    local personalCopyText = personalBusy and "Open your Marmur personal loan status." or "Need cash separately from auto loans? Apply here."
    local personalCopy = ink.text(personalCopyText, 40, 584, 22, color.dim)
    personalCopy:SetWrapping(true)
    personalCopy:SetSize(Vector2.new({ X = 560, Y = 34 }))
    personalCopy:Reparent(right, -1)
    local personalButtonLabel = personalBusy and "Open Personal Loan" or "Apply Personal Loan"
    local personalTarget = personalLoan and personalLoan.active == true and "loanpay" or "loanapply"
    self:createButton(right, personalButtonLabel, 650, 558, 520, 66, function() self:renderPage(personalTarget) end, { fgColor = personalBusy and color.gold or color.green, fontSize = 29 })
end

function shell:buildAutoLoanDetailsPage(data, autoLoans)
    autoLoans = autoLoans or {}
    local loan = self:getSelectedAutoLoan(autoLoans)
    if not loan then
        self.lastAutoLoanMessage = "No active Vanguard Auto loans found."
        self:renderPage("loans")
        return
    end

    local left = self:makePanel(self.contentCanvas, 80, 650, 1520, 670)
    local right = self:makePanel(self.contentCanvas, 1630, 650, 1250, 670)

    local h1 = ink.text("AUTO LOAN DETAILS", 40, 28, 46, color.cyan)
    h1:Reparent(left, -1)
    local autoPaySupported = loan.autoPaySupported == true
    local autoPayEnabled = loan.autoPayEnabled == true
    local paymentSourceSupported = loan.paymentSourceSupported == true
    local paymentSource = math.floor(tonumber(loan.paymentSource) or 1) == 2 and 2 or 1
    local submittedRequest = loan.autoPayRequestKnown == true and (loan.autoPayRequested == true and "ON" or "OFF") or "NOT RECORDED"
    local autoPayStatusText = autoPaySupported and ("VANGUARD REQUEST: " .. submittedRequest .. " / STATUS: " .. (autoPayEnabled and "ON" or "OFF")) or ("VANGUARD REQUEST: " .. submittedRequest .. " / UPDATE REQUIRED")
    local autoPayStatusColor = autoPaySupported and (autoPayEnabled and color.green or color.gold) or color.red
    local autoPayBadge = ink.text(autoPayStatusText, 890, 36, autoPaySupported and 19 or 17, autoPayStatusColor)
    autoPayBadge:SetSize(Vector2.new({ X = 500, Y = 34 }))
    autoPayBadge:Reparent(left, -1)
    local name = ink.text(tostring(loan.title or "Vanguard Auto Loan"), 42, 84, 42, color.gold)
    name:SetSize(Vector2.new({ X = 1320, Y = 54 }))
    name:Reparent(left, -1)

    local scheduledAmount = tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0
    local frequencyLabel = tostring(loan.frequencyLabel or "Monthly")
    self:drawKV(left, "Status", tostring(loan.status or "ACTIVE LIEN"), 40, 156, loan.repossessed and color.red or color.green, 520, 36)
    self:drawKV(left, "Remaining Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 650, 156, color.gold, 560, 36)
    self:drawKV(left, frequencyLabel .. " Payment", "E$ " .. utils.formatNumber(scheduledAmount), 40, 264, color.green, 520, 36)
    self:drawKV(left, "Next Due", tostring(loan.nextDueText or "—"), 650, 264, color.cyan, 560, 36)
    self:drawKV(left, "APR", self:loanRateLabel(loan.interestBasisPoints or 0), 40, 372, color.white, 520, 36)
    self:drawKV(left, "Term / Frequency", tostring(loan.termMonths or 0) .. " mo / " .. frequencyLabel, 650, 372, color.white, 560, 34)
    self:drawKV(left, "Cash Down", "E$ " .. utils.formatNumber(loan.downPayment or 0), 40, 480, color.gold, 520, 34)
    self:drawKV(left, "Total Contract", "E$ " .. utils.formatNumber(loan.totalDue or 0), 650, 480, color.white, 560, 34)

    local message = tostring(self.lastAutoLoanMessage or "")
    local note = self:makePanel(left, 40, 592, 1390, 58)
    local defaultNote = autoPaySupported and ("Vanguard request " .. submittedRequest .. " received. Current Auto-Pay status is " .. (autoPayEnabled and "ON" or "OFF") .. "; payoff releases the title lien.") or "Automobile Auto-Pay controls require an updated Vanguard Auto installation; manual loan payments remain available."
    local noteText = ink.text((#message > 0) and message or defaultNote, 22, 12, 22, (#message > 0) and color.gold or color.white)
    noteText:SetWrapping(true)
    noteText:SetSize(Vector2.new({ X = 1280, Y = 34 }))
    noteText:Reparent(note, -1)

    local h2 = ink.text("PAYMENT ACTIONS", 40, 28, 46, color.cyan)
    h2:Reparent(right, -1)
    local descText = self.autoLoanPaymentKeypadOpen and "Choose the scheduled payment or enter a custom amount toward the loan." or "Review payments and automobile Auto-Pay here. Sell unlocks only after payoff."
    local desc = ink.text(descText, 42, 86, 26, color.dim)
    desc:SetWrapping(true)
    desc:SetSize(Vector2.new({ X = 1080, Y = 66 }))
    desc:Reparent(right, -1)

    if self.autoLoanPaymentKeypadOpen == true then
        local customLabel = self:getCustomAmountLabel("autoloanpay")
        local entryPanel = self:makePanel(right, 40, 166, 1170, 112)
        local entryHead = ink.text("CUSTOM PAYMENT AMOUNT", 28, 12, 26, color.dim)
        entryHead:Reparent(entryPanel, -1)
        local entryValue = ink.text(customLabel, 28, 42, (#customLabel >= 18) and 40 or 50, color.green)
        entryValue:SetSize(Vector2.new({ X = 1040, Y = 54 }))
        entryValue:Reparent(entryPanel, -1)

        local numBW = 210
        local ctrlBW = 260
        local bh = 66
        local rowGap = 10
        local x1 = 40
        local x2 = x1 + numBW + rowGap
        local x3 = x2 + numBW + rowGap
        local x4 = x3 + numBW + rowGap
        local sideX = 985
        local sideW = 225
        local y1 = 304
        local y2 = y1 + bh + rowGap
        local y3 = y2 + bh + rowGap
        local y4 = y3 + bh + rowGap

        self:createButton(right, "1", x1, y1, numBW, bh, function() self:appendCustomAmount("autoloanpay", "1") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "2", x2, y1, numBW, bh, function() self:appendCustomAmount("autoloanpay", "2") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "3", x3, y1, numBW, bh, function() self:appendCustomAmount("autoloanpay", "3") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "Back", x4, y1, ctrlBW, bh, function() self:backspaceCustomAmount("autoloanpay") end, { fgColor = color.gold, fontSize = 28 })
        self:createButton(right, "Normal Pay", sideX, y1, sideW, bh, function() self:submitAutoLoanScheduledPayment() end, { fgColor = color.green, fontSize = 23 })

        self:createButton(right, "4", x1, y2, numBW, bh, function() self:appendCustomAmount("autoloanpay", "4") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "5", x2, y2, numBW, bh, function() self:appendCustomAmount("autoloanpay", "5") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "6", x3, y2, numBW, bh, function() self:appendCustomAmount("autoloanpay", "6") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "Clear", x4, y2, ctrlBW, bh, function() self:clearCustomAmount("autoloanpay") end, { fgColor = color.gold, fontSize = 28 })
        self:createButton(right, "Pay in Full", sideX, y2, sideW, bh, function() self:submitAutoLoanFullPayment() end, { fgColor = color.gold, fontSize = 23 })

        self:createButton(right, "7", x1, y3, numBW, bh, function() self:appendCustomAmount("autoloanpay", "7") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "8", x2, y3, numBW, bh, function() self:appendCustomAmount("autoloanpay", "8") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "9", x3, y3, numBW, bh, function() self:appendCustomAmount("autoloanpay", "9") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "Max", x4, y3, ctrlBW, bh, function() self:fillMaxCustomAmount("autoloanpay", data) end, { fgColor = color.green, fontSize = 28 })
        self:createButton(right, "Hide", sideX, y3, sideW, bh, function() self.autoLoanPaymentKeypadOpen = false; self:clearTransferError("autoloanpay"); self:setCustomAmountString("autoloanpay", ""); self:renderPage("autoloanpay") end, { fgColor = color.cyan, fontSize = 24 })

        self:createButton(right, "0", x1, y4, numBW, bh, function() self:appendCustomAmount("autoloanpay", "0") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "00", x2, y4, numBW, bh, function() self:appendCustomAmount("autoloanpay", "00") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "000", x3, y4, numBW, bh, function() self:appendCustomAmount("autoloanpay", "000") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "Submit", x4, y4, ctrlBW, bh, function() self:submitCustomAmount("autoloanpay", data) end, { fgColor = color.green, bgColor = color.brandPanel2, fontSize = 28, active = true })
        self:createButton(right, "Back Loans", sideX, y4, sideW, bh, function() self.autoLoanPaymentKeypadOpen = false; self.lastAutoLoanMessage = ""; self:clearTransferError("autoloanpay"); self:setCustomAmountString("autoloanpay", ""); self:renderPage("loans") end, { fgColor = color.cyan, fontSize = 23 })

        local errText = self:getTransferError("autoloanpay")
        if errText ~= nil and errText ~= "" then
            local err = ink.text(errText, 42, 622, 24, color.gold)
            err:SetWrapping(true)
            err:SetSize(Vector2.new({ X = 1120, Y = 34 }))
            err:Reparent(right, -1)
        end
    else
        self:createButton(right, "Make Payment", 40, 190, 540, 82, function() self.autoLoanPaymentKeypadOpen = true; self:clearTransferError("autoloanpay"); self:setCustomAmountString("autoloanpay", ""); self:renderPage("autoloanpay") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(right, "Pay in Full", 640, 190, 540, 82, function() self:submitAutoLoanFullPayment() end, { fgColor = color.gold, fontSize = 34 })
        local autoPayButtonLabel = autoPaySupported and (autoPayEnabled and "Review Turning Auto-Pay Off" or "Review Turning Auto-Pay On") or "Auto-Pay Requires Vanguard Update"
        local autoPayButtonAction = nil
        if autoPaySupported and loan.repossessed ~= true then
            autoPayButtonAction = function() self:stageAutoLoanAutoPayReview(data) end
        end
        self:createButton(right, autoPayButtonLabel, 40, 300, 1140, 82, autoPayButtonAction, { fgColor = autoPaySupported and color.cyan or color.dim, fontSize = autoPaySupported and 30 or 26 })
        local sourceTitle = ink.text("AUTO-PAY PAYMENT ACCOUNT", 42, 402, 25, paymentSourceSupported and color.cyan or color.dim)
        sourceTitle:Reparent(right, -1)
        local sourceAction = paymentSourceSupported and loan.repossessed ~= true
        self:createButton(right, paymentSource == 1 and "CHECKING - SELECTED" or "Checking", 40, 438, 540, 72, sourceAction and function() self:setAutoLoanPaymentSource(1, loan.index, loan.contractSerial) end or nil, { fgColor = paymentSource == 1 and color.green or color.cyan, fontSize = 28 })
        self:createButton(right, paymentSource == 2 and "SAVINGS - SELECTED" or "Savings", 640, 438, 540, 72, sourceAction and function() self:setAutoLoanPaymentSource(2, loan.index, loan.contractSerial) end or nil, { fgColor = paymentSource == 2 and color.green or color.cyan, fontSize = 28 })
        self:createButton(right, "Back to Loans", 40, 548, 1140, 72, function() self.autoLoanPaymentKeypadOpen = false; self.lastAutoLoanMessage = ""; self:clearTransferError("autoloanpay"); self:setCustomAmountString("autoloanpay", ""); self:renderPage("loans") end, { fgColor = color.gold, fontSize = 32 })
    end
end

function shell:setAutoLoanPaymentSource(paymentSource, contractIndex, contractSerial)
    local idx = math.floor(tonumber(contractIndex or self.autoLoanSelectedIndex or 1) or 1)
    local callOk, result, detail = pcall(function()
        return Bank:setVanguardAutoLoanPaymentSource(idx, paymentSource, contractSerial)
    end)
    if callOk == true and result == true then
        self.lastAutoLoanMessage = type(detail) == "string" and detail or "Auto-Pay account updated."
        utils.playSound("ui_jingle_quest_update", 1)
    else
        self.lastAutoLoanMessage = (callOk == true and type(detail) == "string" and detail ~= "") and detail or "Auto-Pay account could not be changed."
        utils.playSound("ui_menu_onpress", 1)
    end
    self:renderPage("autoloanpay")
end

function shell:submitAutoLoanScheduledPayment()
    local idx = math.floor(tonumber(self.autoLoanSelectedIndex or 1) or 1)
    local ok = false
    pcall(function() ok = Bank:payVanguardAutoLoanScheduled(idx) == true end)
    if ok then
        self.lastAutoLoanMessage = "Normal auto-loan payment posted."
        self:setCustomAmountString("autoloanpay", "")
        self:clearTransferError("autoloanpay")
    else
        self.lastAutoLoanMessage = "Payment failed. Check the Checking balance, repossession status, or Vanguard Auto installation."
    end
    self.autoLoanPaymentKeypadOpen = true
    self:renderPage("autoloanpay")
end

function shell:submitAutoLoanCustomPayment(amount, data)
    local snapshot = data or self:getBankData()
    local autoLoans = snapshot.autoLoans or {}
    local loan = self:getSelectedAutoLoan(autoLoans)
    amount = math.floor(tonumber(amount) or 0)

    if not loan then
        self:setTransferError("autoloanpay", "No active auto loan is available for payment.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end

    local balance = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
    if amount <= 0 then
        self:setTransferError("autoloanpay", "Enter a payment amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end

    if amount > (snapshot.wallet or 0) then
        self:setTransferError("autoloanpay", "Payment exceeds checking balance.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end

    if amount > balance then
        self:setTransferError("autoloanpay", "Payment exceeds current payoff balance.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end

    local idx = math.floor(tonumber(self.autoLoanSelectedIndex or 1) or 1)
    local ok = false
    local reason = "Custom payment failed. Check the Checking balance or update Vanguard Auto compatibility."
    local callOk, result, message = pcall(function() return Bank:payVanguardAutoLoanCustom(idx, amount) end)
    if callOk then
        ok = result == true
        if type(message) == "string" and message ~= "" then reason = message end
    end
    if ok then
        self.lastAutoLoanMessage = "Auto-loan payment posted: E$ " .. utils.formatNumber(amount) .. "."
        self:setCustomAmountString("autoloanpay", "")
        self:clearTransferError("autoloanpay")
        utils.playSound("ui_jingle_quest_update", 1)
    else
        self:setTransferError("autoloanpay", reason)
        self.lastAutoLoanMessage = reason
        utils.playSound("ui_menu_onpress", 1)
    end
    self.autoLoanPaymentKeypadOpen = true
    self:renderPage("autoloanpay")
end

function shell:submitAutoLoanFullPayment()
    local idx = math.floor(tonumber(self.autoLoanSelectedIndex or 1) or 1)
    local ok = false
    pcall(function() ok = Bank:payVanguardAutoLoanInFull(idx) == true end)
    if ok then
        self.lastAutoLoanMessage = "Auto loan paid in full. Vanguard title lien released."
        self:setCustomAmountString("autoloanpay", "")
        self:clearTransferError("autoloanpay")
        self.autoLoanPaymentKeypadOpen = false
    else
        self.lastAutoLoanMessage = "Pay in full failed. Check the Checking balance, repossession status, or Vanguard Auto installation."
        self.autoLoanPaymentKeypadOpen = true
    end
    self:renderPage("autoloanpay")
end

function shell:buildLoansPage()
    local data = self:getBankData()
    local loan = data.loan or {}
    local autoLoans = data.autoLoans or {}
    local streetCred = data.streetCred or 0
    local errorText = self:getLoanError()
    local calendarContext = Calendar.getContext()
    local reviewDecisionDateTime = "Pending"
    if math.floor(tonumber(loan.reviewDecisionMinute) or 0) > 0 then
        reviewDecisionDateTime = Calendar.formatMinuteStamp(loan.reviewDecisionMinute, calendarContext, true)
    end
    local fundingDateTime = "Processing"
    if math.floor(tonumber(loan.reviewFundingDueMinute) or 0) > 0 then
        fundingDateTime = Calendar.formatMinuteStamp(loan.reviewFundingDueMinute, calendarContext, true)
    end

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 155)
    local pendingLoanStatus = loan.reviewActive == true
    local title = "LOAN SERVICES"
    local subtitle = "Request a custom amount for credit-based underwriting."
    if self.activePage == "loanapply" then
        title = "PERSONAL LOAN REQUEST"
        subtitle = "Apply for a Marmur personal loan. Auto loans remain serviced alongside every active obligation."
    elseif self.activePage == "autoloanpay" and #autoLoans > 0 then
        title = "AUTO LOAN DETAILS"
        subtitle = "Vanguard Auto title lien serviced by Marmur Bank."
    elseif self.activePage == "loanpay" and loan.active then
        title = "LOAN DETAILS"
        subtitle = "Selected loan servicing with extra payment and early payoff options."
    elseif #autoLoans > 0 or loan.active then
        title = "MY LOANS"
        subtitle = "Active Loan Overview lists all funded personal loans and auto loans in one place."
    elseif loan.reviewFundingPending then
        title = "FUNDING IN PROGRESS"
        subtitle = "Agreement signed. Expected deposit: " .. fundingDateTime .. "."
    elseif loan.reviewApprovalReady then
        title = "LOAN APPROVED"
        subtitle = "Review the final terms and sign before funds are released."
    elseif loan.reviewPending then
        title = "LOAN UNDER REVIEW"
        subtitle = "Application submitted. Expected decision: " .. reviewDecisionDateTime .. "."
    end
    local t1 = ink.text(title, 40, 20, 50, (loan.active or pendingLoanStatus) and color.gold or color.green)
    t1:Reparent(strip, -1)
    local t2 = ink.text(subtitle, 42, 88, 28, color.dim)
    t2:SetWrapping(true)
    t2:SetSize(Vector2.new({ X = 1280, Y = 54 }))
    t2:Reparent(strip, -1)

    self:drawHeaderStat(strip, "Credit Level", tostring(streetCred), 1328, 34, color.green, 420, 26, 38)

    local walletLabel = loan.reviewActive and "Requested Amount" or "Checking"
    local walletDisplay = loan.reviewActive and ("E$ " .. utils.formatNumber(loan.reviewAmount or 0)) or ("E$ " .. utils.formatNumber(data.wallet))
    local walletColor = loan.reviewActive and color.gold or color.white
    self:drawHeaderStat(strip, walletLabel, walletDisplay, 1788, 34, walletColor, 470, 26, loan.reviewActive and 32 or 38)

    local autoLoanBalance = 0
    for _, autoLoan in ipairs(autoLoans) do
        autoLoanBalance = autoLoanBalance + math.max(tonumber(autoLoan.balanceDue) or 0, 0)
    end
    local personalLoanBalance = loan.active and math.max(tonumber(loan.balanceDue) or 0, 0) or 0
    local activeLoanBalance = autoLoanBalance + personalLoanBalance
    local hasActiveLoans = (#autoLoans > 0) or loan.active == true
    local loanDisplay = hasActiveLoans and ("E$ " .. utils.formatNumber(activeLoanBalance)) or (loan.reviewActive and ("Pending E$ " .. utils.formatNumber(loan.reviewAmount or 0)) or ("E$ " .. utils.formatNumber(loan.balanceDue or 0)))
    local loanLabel = hasActiveLoans and "Active Loan Balance" or (loan.reviewActive and "Loan Review" or "Loan Balance")
    self:drawHeaderStat(strip, loanLabel, loanDisplay, 2298, 34, (loan.active or pendingLoanStatus or #autoLoans > 0) and color.gold or color.dim, 460, 26, (loan.reviewActive or hasActiveLoans) and 30 or 38)

    if self.activePage == "autoloanpay" then
        self:buildAutoLoanDetailsPage(data, autoLoans)
        return
    end

    if (#autoLoans > 0 or loan.active == true) and self.activePage ~= "loanpay" and self.activePage ~= "loanapply" then
        self:buildAutoLoansOverview(data, autoLoans, loan)
        return
    end

    if loan.active and self.activePage ~= "loanpay" then
        local paidToDate = math.max((loan.originalDue or 0) - (loan.balanceDue or 0), 0)
        local left = self:makePanel(self.contentCanvas, 80, 650, 1520, 670)
        local right = self:makePanel(self.contentCanvas, 1630, 650, 1250, 670)

        local h1 = ink.text("ACTIVE LOANS", 40, 28, 46, color.cyan)
        h1:Reparent(left, -1)
        local desc = ink.text("Open the active loan to view terms, pay extra, or settle early.", 42, 82, 26, color.dim)
        desc:SetWrapping(true)
        desc:SetSize(Vector2.new({ X = 1300, Y = 54 }))
        desc:Reparent(left, -1)

        local card = self:makePanel(left, 40, 164, 1440, 310)
        local name = ink.text("Marmur Personal Loan", 36, 24, 42, color.gold)
        name:SetSize(Vector2.new({ X = 760, Y = 52 }))
        name:Reparent(card, -1)
        local status = ink.text("ACTIVE", 1190, 30, 34, color.green)
        status:SetSize(Vector2.new({ X = 200, Y = 42 }))
        status:Reparent(card, -1)

        self:drawKV(card, "Original Amount", "E$ " .. utils.formatNumber(loan.principal or 0), 36, 102, color.white)
        self:drawKV(card, "Paid So Far", "E$ " .. utils.formatNumber(paidToDate), 500, 102, color.green)
        self:drawKV(card, "Remaining Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 960, 102, color.gold)
        self:drawKV(card, "Locked APR", self:loanRateLabel(loan.interestBasisPoints or 0), 36, 210, color.green)
        self:drawKV(card, "Next Auto-Debit", self:formatLoanDueCountdown(loan, data), 500, 210, color.cyan)
        self:drawKV(card, "Term", tostring(loan.termMonths or 0) .. " months", 960, 210, color.white)

        self:createButton(left, "View Loan Details", 40, 520, 680, 92, function() self:renderPage("loanpay") end, { fgColor = color.green, fontSize = 36 })
        self:createButton(left, "Back to Home", 760, 520, 680, 92, function() self:renderPage("home") end, { fgColor = color.cyan, fontSize = 36 })

        local h2 = ink.text("ACCOUNT SUMMARY", 40, 28, 46, color.cyan)
        h2:Reparent(right, -1)
        local summary = ink.text("Current loan status and payment progress. Open details before extra payments or early payoff.", 42, 84, 26, color.dim)
        summary:SetWrapping(true)
        summary:SetSize(Vector2.new({ X = 1080, Y = 62 }))
        summary:Reparent(right, -1)

        self:drawKV(right, "Current Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 40, 190, color.gold)
        self:drawKV(right, "Installment", "E$ " .. utils.formatNumber(loan.installment or 0), 650, 190, color.green)
        self:drawKV(right, "Payments Made", tostring(loan.paymentsMade or 0), 40, 312, color.white)
        self:drawKV(right, "Missed Payments", tostring(loan.missedPayments or 0), 650, 312, color.white)

        local note = self:makePanel(right, 40, 448, 1170, 132)
        local noteText = ink.text("Extra payments reduce the balance immediately. Auto-debit continues until the loan is paid in full.", 28, 20, 26, color.white)
        noteText:SetWrapping(true)
        noteText:SetSize(Vector2.new({ X = 1080, Y = 84 }))
        noteText:Reparent(note, -1)
        return
    end

    if not loan.active then
        local left = self:makePanel(self.contentCanvas, 80, 650, 1470, 720)
        local right = self:makePanel(self.contentCanvas, 1580, 650, 1300, 720)

        if loan.reviewActive then
            if loan.reviewFundingPending then
                local h1 = ink.text("FUNDING IN PROGRESS", 44, 28, 46, color.gold)
                h1:Reparent(left, -1)
                local desc = ink.text("Signed agreement processing. The scheduled deposit time is shown below.", 46, 82, 25, color.dim)
                desc:SetWrapping(true)
                desc:SetSize(Vector2.new({ X = 1320, Y = 56 }))
                desc:Reparent(left, -1)

                self:drawKV(left, "Approved Amount", "E$ " .. utils.formatNumber(loan.reviewAmount or 0), 40, 170, color.white)
                self:drawKV(left, "Expected Deposit", fundingDateTime, 650, 170, color.gold, 650, 34, 27)
                self:drawKV(left, "Payment Frequency", tostring(loan.reviewFrequencyLabel or "Monthly"), 40, 292, color.cyan)
                self:drawKV(left, "Term", tostring(loan.reviewTermMonths or 0) .. " months", 650, 292, color.green)
                self:drawKV(left, "Locked APR", self:loanRateLabel(loan.reviewInterestBasisPoints or 0), 40, 414, color.green)
                self:drawKV(left, "Total Due", "E$ " .. utils.formatNumber(loan.reviewTotalDue or 0), 650, 414, color.gold)

                local note = self:makePanel(left, 40, 542, 1390, 88)
                local noteText = ink.text("Status: signed. Payment schedule starts after the deposit posts at " .. fundingDateTime .. ".", 26, 18, 27, color.white)
                noteText:SetWrapping(true)
                noteText:SetSize(Vector2.new({ X = 1330, Y = 58 }))
                noteText:Reparent(note, -1)

                local h2 = ink.text("NEXT STEPS", 40, 28, 46, color.cyan)
                h2:Reparent(right, -1)
                local rows = {
                    { "1", "Agreement signed", color.green },
                    { "2", "Expected deposit: " .. fundingDateTime, color.gold },
                    { "3", "Auto-debit activates after funding", color.cyan },
                    { "4", "Payments follow selected frequency", color.green },
                }
                local y = 110
                for _, rowData in ipairs(rows) do
                    local row = self:makePanel(right, 40, y, 1220, 78)
                    local num = ink.text(rowData[1], 28, 18, 34, rowData[3])
                    num:SetSize(Vector2.new({ X = 60, Y = 40 }))
                    num:Reparent(row, -1)
                    local label = ink.text(rowData[2], 110, 20, 28, color.white)
                    label:SetSize(Vector2.new({ X = 1000, Y = 42 }))
                    label:Reparent(row, -1)
                    y = y + 92
                end
                self:createButton(right, "Refresh Status", 40, 512, 580, 90, function() self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans") end, { fgColor = color.cyan, fontSize = 34 })
                self:createButton(right, "Back to Home", 680, 512, 580, 90, function() self:renderPage("home") end, { fgColor = color.green, fontSize = 32 })
                return
            elseif loan.reviewApprovalReady then
                local h1 = ink.text("APPROVED TERMS READY", 44, 28, 46, color.green)
                h1:Reparent(left, -1)
                local desc = ink.text("Request approved. Review and sign to release funds.", 46, 82, 25, color.dim)
                desc:SetWrapping(true)
                desc:SetSize(Vector2.new({ X = 1260, Y = 60 }))
                desc:Reparent(left, -1)

                self:drawKV(left, "Approved Amount", "E$ " .. utils.formatNumber(loan.reviewAmount or 0), 40, 170, color.white)
                self:drawKV(left, "Locked APR", self:loanRateLabel(loan.reviewInterestBasisPoints or 0), 650, 170, color.green)
                self:drawKV(left, "Payment Frequency", tostring(loan.reviewFrequencyLabel or "Monthly"), 40, 292, color.cyan)
                self:drawKV(left, "Auto-Debit", tostring(loan.reviewInstallment or 0) == "0" and "Pending" or ("E$ " .. utils.formatNumber(loan.reviewInstallment or 0)), 650, 292, color.gold)
                self:drawKV(left, "Term", tostring(loan.reviewTermMonths or 0) .. " months", 40, 414, color.white)
                self:drawKV(left, "Total Due", "E$ " .. utils.formatNumber(loan.reviewTotalDue or 0), 650, 414, color.gold)

                local disclosure = self:makePanel(left, 40, 542, 1390, 88)
                local disclosureText = ink.text("Signing authorizes auto-debit. Funds release after acceptance.", 26, 18, 24, color.white)
                disclosureText:SetWrapping(true)
                disclosureText:SetSize(Vector2.new({ X = 1260, Y = 54 }))
                disclosureText:Reparent(disclosure, -1)

                local h2 = ink.text("SIGN AGREEMENT", 40, 28, 46, color.cyan)
                h2:Reparent(right, -1)
                local detail = ink.text("Select the signature field, then accept the final terms.", 42, 86, 26, color.dim)
                detail:SetWrapping(true)
                detail:SetSize(Vector2.new({ X = 1100, Y = 62 }))
                detail:Reparent(right, -1)

                self.loanSignatureWidgets.field = self:createLoanSignatureField(right, 40, 176, 1220, 122)

                local signatureHelperText = self.loanSignatureFilled and "Signature captured. Acceptance unlocked." or "Select the signature field to auto-fill your name."
                local signatureHelperColor = self.loanSignatureFilled and color.green or color.dim
                if errorText ~= nil and errorText ~= "" then
                    signatureHelperText = errorText
                    signatureHelperColor = color.gold
                end
                local helper = ink.text(signatureHelperText, 44, 318, 23, signatureHelperColor)
                helper:SetWrapping(true)
                helper:SetSize(Vector2.new({ X = 1100, Y = 34 }))
                helper:Reparent(right, -1)
                self.loanSignatureWidgets.helper = helper

                local signHolder = ink.canvas(40, 370, inkEAnchor.TopLeft)
                signHolder:SetSize(Vector2.new({ X = 1220, Y = 86 }))
                signHolder:Reparent(right, -1)
                local signLabel = ink.text("Accept Signed Terms", 610, 38, 34, self.loanSignatureFilled and color.green or color.dim)
                signLabel:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
                signLabel:SetSize(Vector2.new({ X = 1220, Y = 48 }))
                signLabel:Reparent(signHolder, -1)
                local signUnderline = ink.rect(360, 68, 500, 3, self.loanSignatureFilled and color.green or color.gold)
                signUnderline:SetOpacity(self.loanSignatureFilled and 0.84 or 0.0)
                signUnderline:Reparent(signHolder, -1)
                local signHotspot = ink.rect(0, 0, 1220, 86, color.white)
                signHotspot:SetOpacity(0.01)
                signHotspot:Reparent(signHolder, -1)
                self.loanSignatureWidgets.signBorder = signUnderline
                self.loanSignatureWidgets.signFill = signHotspot
                self.loanSignatureWidgets.signLabel = signLabel
                self:addSubscriber(signHotspot, {
                    hoverIn = function()
                        signLabel:SetTintColor(color.gold)
                        signUnderline:SetTintColor(color.gold)
                        signUnderline:SetOpacity(0.92)
                    end,
                    hoverOut = function()
                        signLabel:SetTintColor(self.loanSignatureFilled and color.green or color.dim)
                        signUnderline:SetTintColor(self.loanSignatureFilled and color.green or color.gold)
                        signUnderline:SetOpacity(self.loanSignatureFilled and 0.84 or 0.0)
                    end,
                    click = function()
                        if self.loanSignatureFilled ~= true then
                            self:setLoanError("Signature required before funds release.")
                            if self.loanSignatureWidgets and self.loanSignatureWidgets.helper then
                                self.loanSignatureWidgets.helper:SetText(ink.translate("Signature required before funds release."))
                                self.loanSignatureWidgets.helper:SetTintColor(color.gold)
                            end
                            utils.playSound("ui_menu_onpress", 1)
                            return
                        end
                        utils.playSound("ui_menu_onpress", 1)
                        self:acceptApprovedLoanTerms(data)
                    end,
                })
                self:updateLoanSignatureButtonState()

                self:createButton(right, "Decline Terms", 40, 486, 580, 72, function() self:cancelLoanProcess() end, { fgColor = color.gold, fontSize = 30 })
                self:createButton(right, "Back to Home", 680, 486, 580, 72, function() self:renderPage("home") end, { fgColor = color.cyan, fontSize = 30 })
                self:createButton(right, "Refresh Status", 40, 576, 1220, 64, function() self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans") end, { fgColor = color.cyan, fontSize = 30 })
                return
            end

            local h1 = ink.text("LOAN REVIEW CHECK", 44, 28, 46, color.gold)
            h1:Reparent(left, -1)
            local expectedDecision = "Pending"
            if math.floor(tonumber(loan.reviewDecisionMinute) or 0) > 0 then
                expectedDecision = Calendar.formatMinuteStamp(loan.reviewDecisionMinute, Calendar.getContext(), true)
            end
            local desc = ink.text("Underwriting uses the shared Marmur credit profile. The expected decision time is shown below.", 46, 82, 28, color.dim)
            desc:SetWrapping(true)
            desc:SetSize(Vector2.new({ X = 1260, Y = 60 }))
            desc:Reparent(left, -1)

            self:drawKV(left, "Requested Amount", "E$ " .. utils.formatNumber(loan.reviewAmount or 0), 40, 170, color.white)
            self:drawKV(left, "Submitted", self:formatLoanClockTime(loan.reviewSubmitMinute or 0), 650, 170, color.dim)
            local reviewRiskLabel = tostring(loan.reviewApprovalRiskLabel or "HIGH")
            if reviewRiskLabel == "" then reviewRiskLabel = "HIGH" end
            local reviewRiskColor = self:getApprovalRiskColor(reviewRiskLabel)
            local reviewChance = math.floor(tonumber(loan.reviewApprovalChance or 0) or 0)
            self:drawKV(left, "Expected Decision", expectedDecision, 40, 292, color.gold, 560, 34, 27)
            self:drawKV(left, "Payment Frequency", tostring(loan.reviewFrequencyLabel or "Monthly") .. " / " .. tostring(loan.reviewTermMonths or 0) .. " mo", 650, 292, color.cyan)
            self:drawKV(left, "Locked APR", self:loanRateLabel(loan.reviewInterestBasisPoints or 0), 40, 414, color.green)
            self:drawKV(left, "Approval Risk", reviewRiskLabel .. " / " .. tostring(reviewChance) .. "%", 650, 414, reviewRiskColor)

            local pendingNote = self:makePanel(left, 40, 536, 1390, 104)
            local pendingText = ink.text("Status: under review. APR and risk snapshot are locked from the submitted personal-loan quote.", 26, 18, 27, color.white)
            pendingText:SetWrapping(true)
            pendingText:SetSize(Vector2.new({ X = 1260, Y = 58 }))
            pendingText:Reparent(pendingNote, -1)

            local h2 = ink.text("REVIEW WINDOW", 40, 28, 46, color.cyan)
            h2:Reparent(right, -1)
            local rows = {
                { "1", "Request submitted", color.green },
                { "2", "Approval risk checked against submitted quote", color.gold },
                { "3", "Expected decision: " .. expectedDecision, color.cyan },
                { "4", "Signature required before funding", color.green },
            }
            local y = 110
            for _, rowData in ipairs(rows) do
                local row = self:makePanel(right, 40, y, 1220, 78)
                local num = ink.text(rowData[1], 28, 18, 34, rowData[3])
                num:SetSize(Vector2.new({ X = 60, Y = 40 }))
                num:Reparent(row, -1)
                local label = ink.text(rowData[2], 110, 20, 28, color.white)
                label:SetWrapping(true)
                label:SetSize(Vector2.new({ X = 1000, Y = 46 }))
                label:Reparent(row, -1)
                y = y + 92
            end
            self:createButton(right, "Refresh Status", 40, 512, 580, 90, function() self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans") end, { fgColor = color.cyan, fontSize = 34 })
            self:createButton(right, "Back to Home", 680, 512, 580, 90, function() self:renderPage("home") end, { fgColor = color.green, fontSize = 32 })
            return
        end

        local h1 = ink.text("REQUEST A LOAN", 44, 20, 44, color.cyan)
        h1:Reparent(left, -1)
        local desc = ink.text("Enter the amount you want to borrow. Marmur reviews credit profile, loan status, and account standing.", 46, 84, 24, color.dim)
        desc:SetWrapping(true)
        desc:SetSize(Vector2.new({ X = 1320, Y = 56 }))
        desc:Reparent(left, -1)

        local customLabel = self:getCustomAmountLabel("loanrequest")
        local requestedAmount = self:getCustomAmount("loanrequest")
        local selectedFrequency = self:getLoanPaymentFrequency()
        local selectedTermMonths = self:getLoanTermMonths()
        local quote = nil
        pcall(function() quote = Bank:getManualLoanQuote(requestedAmount, selectedFrequency, selectedTermMonths) end)
        if not quote then quote = { requiredStreetCred = 1, interestBasisPoints = 2400, approvalChance = 0, approvalRiskLabel = "HIGH", approvalRiskCode = 3, termPayments = 12, termMonths = selectedTermMonths, intervalDays = 30, frequencyLabel = "Monthly", totalDue = 0, installment = 0 } end
        local currentMax = 0
        pcall(function() currentMax = Bank:getLoanMaxForStreetCred(streetCred) or 0 end)
        local absoluteMax = 100000000
        pcall(function() absoluteMax = Bank:getManualLoanMaxPrincipal() or absoluteMax end)

        local entryPanel = self:makePanel(left, 40, 148, 1390, 112)
        local entryHead = ink.text("REQUESTED LOAN AMOUNT", 28, 14, 26, color.dim)
        entryHead:Reparent(entryPanel, -1)
        local entryValue = ink.text(customLabel, 28, 48, (#customLabel >= 18) and 40 or 48, color.green)
        entryValue:SetSize(Vector2.new({ X = 700, Y = 66 }))
        entryValue:Reparent(entryPanel, -1)
        local limit = ink.text("Credit ceiling: E$ " .. utils.formatNumber(currentMax), 780, 28, 23, color.dim)
        limit:SetWrapping(true)
        limit:SetSize(Vector2.new({ X = 540, Y = 60 }))
        limit:Reparent(entryPanel, -1)

        local freqHead = ink.text("PAYMENT FREQUENCY", 40, 274, 28, color.dim)
        freqHead:Reparent(left, -1)
        self:buildLoanFrequencyButton(left, "Weekly", "weekly", 40, 310, 420, 54)
        self:buildLoanFrequencyButton(left, "Biweekly", "biweekly", 500, 310, 420, 54)
        self:buildLoanFrequencyButton(left, "Monthly", "monthly", 960, 310, 420, 54)

        local termHead = ink.text("TERM LENGTH", 40, 378, 26, color.dim)
        termHead:Reparent(left, -1)
        local termY = 410
        self:buildLoanTermButton(left, 12, 40, termY, 170, 44)
        self:createButton(left, "-12", 230, termY, 150, 44, function() self:adjustLoanTermMonths(-12) end, { fgColor = color.cyan, fontSize = 23 })
        self:createButton(left, "-1", 398, termY, 130, 44, function() self:adjustLoanTermMonths(-1) end, { fgColor = color.cyan, fontSize = 23 })
        local termDisplay = self:makePanel(left, 548, termY, 300, 44)
        local termDisplayText = ink.text(tostring(selectedTermMonths) .. " months", 150, 22, 25, color.gold)
        termDisplayText:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
        termDisplayText:SetSize(Vector2.new({ X = 280, Y = 40 }))
        termDisplayText:Reparent(termDisplay, -1)
        self:createButton(left, "+1", 868, termY, 130, 44, function() self:adjustLoanTermMonths(1) end, { fgColor = color.cyan, fontSize = 23 })
        self:createButton(left, "+12", 1018, termY, 150, 44, function() self:adjustLoanTermMonths(12) end, { fgColor = color.cyan, fontSize = 23 })
        self:buildLoanTermButton(left, 84, 1188, termY, 190, 44)

        local numBW = 250
        local ctrlBW = 360
        local bh = 48
        local rowGap = 7
        local x1 = 40
        local x2 = x1 + numBW + rowGap
        local x3 = x2 + numBW + rowGap
        local x4 = x3 + numBW + rowGap
        local y1 = 470
        local y2 = y1 + bh + rowGap
        local y3 = y2 + bh + rowGap
        local y4 = y3 + bh + rowGap

        self:createButton(left, "1", x1, y1, numBW, bh, function() self:appendCustomAmount("loanrequest", "1") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "2", x2, y1, numBW, bh, function() self:appendCustomAmount("loanrequest", "2") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "3", x3, y1, numBW, bh, function() self:appendCustomAmount("loanrequest", "3") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "Back", x4, y1, ctrlBW, bh, function() self:backspaceCustomAmount("loanrequest") end, { fgColor = color.gold, fontSize = 26 })
        self:createButton(left, "4", x1, y2, numBW, bh, function() self:appendCustomAmount("loanrequest", "4") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "5", x2, y2, numBW, bh, function() self:appendCustomAmount("loanrequest", "5") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "6", x3, y2, numBW, bh, function() self:appendCustomAmount("loanrequest", "6") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "Clear", x4, y2, ctrlBW, bh, function() self:clearCustomAmount("loanrequest") end, { fgColor = color.gold, fontSize = 26 })
        self:createButton(left, "7", x1, y3, numBW, bh, function() self:appendCustomAmount("loanrequest", "7") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "8", x2, y3, numBW, bh, function() self:appendCustomAmount("loanrequest", "8") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "9", x3, y3, numBW, bh, function() self:appendCustomAmount("loanrequest", "9") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "Max", x4, y3, ctrlBW, bh, function() local fill = currentMax > 0 and currentMax or absoluteMax; self:setCustomAmountString("loanrequest", tostring(math.floor(fill))); self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans") end, { fgColor = color.green, fontSize = 26 })
        self:createButton(left, "0", x1, y4, numBW, bh, function() self:appendCustomAmount("loanrequest", "0") end, { fgColor = color.green, fontSize = 32 })
        self:createButton(left, "00", x2, y4, numBW, bh, function() self:appendCustomAmount("loanrequest", "00") end, { fgColor = color.green, fontSize = 34 })
        self:createButton(left, "000", x3, y4, numBW, bh, function() self:appendCustomAmount("loanrequest", "000") end, { fgColor = color.green, fontSize = 34 })

        local errColor = (#errorText > 0) and color.gold or color.dim
        local msg = (#errorText > 0) and errorText or "APR locks when you submit. Decision posts in 2-4 business hours using the personal-loan risk model."
        local err = ink.text(msg, 40, 688, 21, errColor)
        err:SetWrapping(true)
        err:SetSize(Vector2.new({ X = 1360, Y = 34 }))
        err:Reparent(left, -1)

        local approvalStatus = "ENTER AMOUNT"
        local approvalDetail = "Enter a request amount to preview before submitting."
        local approvalColor = color.dim
        local approvalRisk = tostring(quote.approvalRiskLabel or "HIGH")
        local approvalRiskColor = self:getApprovalRiskColor(approvalRisk)
        local approvalChance = math.floor(tonumber(quote.approvalChance) or 0)
        local requiredStreetCred = tonumber(quote.requiredStreetCred) or 1
        local financeCharge = math.max((quote.totalDue or 0) - (quote.principal or 0), 0)
        if requestedAmount <= 0 then
            approvalStatus = "ENTER AMOUNT"
            approvalDetail = "Enter a request amount to view APR, approval risk, and payment estimate."
            approvalRisk = "--"
            approvalRiskColor = color.dim
            approvalColor = color.dim
        elseif requestedAmount > absoluteMax then
            approvalStatus = "ABOVE LOAN CAP"
            approvalDetail = "Maximum personal-loan request: E$ " .. utils.formatNumber(absoluteMax) .. "."
            approvalRisk = "HIGH"
            approvalRiskColor = color.red
            approvalChance = 0
            approvalColor = color.white
        elseif approvalChance <= 0 then
            approvalStatus = "HIGH RISK"
            approvalDetail = "Credit is below the favor line for this request. Required level: " .. tostring(requiredStreetCred) .. "."
            approvalRisk = "HIGH"
            approvalRiskColor = color.red
            approvalColor = color.white
        else
            approvalStatus = "REVIEW READY"
            approvalDetail = "Estimated approval chance: " .. tostring(approvalChance) .. "%  •  Required credit: " .. tostring(requiredStreetCred) .. "."
            approvalColor = color.white
        end

        local h2 = ink.text("LOAN ESTIMATE & ELIGIBILITY", 40, 20, 40, color.cyan)
        h2:Reparent(right, -1)
        local h2note = ink.text("Terms update as amount, frequency, and term length change. Review before submitting.", 42, 82, 24, color.dim)
        h2note:SetWrapping(true)
        h2note:SetSize(Vector2.new({ X = 1180, Y = 52 }))
        h2note:Reparent(right, -1)

        local statusPanel = self:makePanel(right, 40, 142, 1220, 110)
        local statusLabel = ink.text(approvalStatus, 26, 14, 30, approvalColor)
        statusLabel:SetSize(Vector2.new({ X = 390, Y = 46 }))
        statusLabel:Reparent(statusPanel, -1)
        local statusDesc = ink.text(approvalDetail, 430, 16, 22, color.white)
        statusDesc:SetWrapping(true)
        statusDesc:SetSize(Vector2.new({ X = 760, Y = 72 }))
        statusDesc:Reparent(statusPanel, -1)

        local cardW = 585
        local cardH = 120
        local c1 = self:makePanel(right, 40, 270, cardW, cardH)
        local c1a = ink.text("REQUESTED", 24, 16, 25, color.dim)
        c1a:Reparent(c1, -1)
        local c1b = ink.text("E$ " .. utils.formatNumber(requestedAmount), 24, 52, 42, color.white)
        c1b:SetSize(Vector2.new({ X = 520, Y = 48 }))
        c1b:Reparent(c1, -1)

        local c2 = self:makePanel(right, 675, 270, cardW, cardH)
        local c2a = ink.text("APPROVAL RISK", 24, 16, 25, color.dim)
        c2a:SetSize(Vector2.new({ X = 535, Y = 32 }))
        c2a:Reparent(c2, -1)
        local c2b = ink.text(approvalRisk, cardW / 2, 74, (#approvalRisk >= 6) and 50 or 58, approvalRiskColor)
        c2b:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
        c2b:SetSize(Vector2.new({ X = 555, Y = 92 }))
        c2b:Reparent(c2, -1)

        local terms = self:makePanel(right, 40, 414, 1220, 190)
        local termsHead = ink.text("PROJECTED TERMS", 24, 14, 30, color.dim)
        termsHead:Reparent(terms, -1)
        local apr = ink.text("Locked APR\n" .. self:loanRateLabel(quote.interestBasisPoints or 0), 24, 62, 30, color.green)
        apr:SetSize(Vector2.new({ X = 210, Y = 100 }))
        apr:Reparent(terms, -1)
        local term = ink.text("Term\n" .. tostring(quote.termMonths or selectedTermMonths) .. " months", 250, 62, 30, color.white)
        term:SetSize(Vector2.new({ X = 210, Y = 100 }))
        term:Reparent(terms, -1)
        local schedule = ink.text("Schedule\n" .. tostring(quote.frequencyLabel or self:getLoanPaymentFrequencyLabel(selectedFrequency)) .. " / " .. tostring(quote.termPayments or 0) .. " payments", 475, 62, 27, color.white)
        schedule:SetWrapping(true)
        schedule:SetSize(Vector2.new({ X = 285, Y = 104 }))
        schedule:Reparent(terms, -1)
        local installment = ink.text("Est. Payment\nE$ " .. utils.formatNumber(quote.installment or 0), 760, 62, 29, color.cyan)
        installment:SetSize(Vector2.new({ X = 230, Y = 100 }))
        installment:Reparent(terms, -1)
        local total = ink.text("Est. Total Due\nE$ " .. utils.formatNumber(quote.totalDue or 0), 998, 62, 27, color.gold)
        total:SetWrapping(true)
        total:SetSize(Vector2.new({ X = 210, Y = 104 }))
        total:Reparent(terms, -1)

        local finePanel = self:makePanel(right, 40, 620, 820, 64)
        local fine = ink.text("APR locks on submit. Finance charge: E$ " .. utils.formatNumber(financeCharge) .. ". Auto-debit required.", 22, 10, 20, (requestedAmount > 0) and color.dim or color.gold)
        fine:SetWrapping(true)
        fine:SetSize(Vector2.new({ X = 760, Y = 44 }))
        fine:Reparent(finePanel, -1)

        self:createButton(right, "Submit", 900, 616, 360, 70, function() self:submitCustomAmount("loanrequest", data) end, { fgColor = color.green, bgColor = color.brandPanel2, fontSize = 30, active = true })
        return
    end

    local left = self:makePanel(self.contentCanvas, 80, 650, 1300, 670)
    local right = self:makePanel(self.contentCanvas, 1410, 650, 1470, 670)

    local h1 = ink.text("SELECTED LOAN DETAILS", 40, 28, 46, color.cyan)
    h1:Reparent(left, -1)
    local paidToDate = math.max((loan.originalDue or 0) - (loan.balanceDue or 0), 0)
    local earlyPayoff = self:getLoanEarlyPayoffAmountFromData(loan)
    local interestWaived = math.max((loan.balanceDue or 0) - earlyPayoff, 0)
    self:drawKV(left, "Original Amount", "E$ " .. utils.formatNumber(loan.principal or 0), 40, 104, color.white)
    self:drawKV(left, "Original Total Due", "E$ " .. utils.formatNumber(loan.originalDue or 0), 650, 104, color.gold)
    self:drawKV(left, "Paid So Far", "E$ " .. utils.formatNumber(paidToDate), 40, 226, color.green)
    self:drawKV(left, "Remaining Total Due", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 650, 226, color.gold)
    self:drawKV(left, "Early Payoff Today", "E$ " .. utils.formatNumber(earlyPayoff), 40, 348, color.green)
    self:drawKV(left, "Future Interest Waived", "E$ " .. utils.formatNumber(interestWaived), 650, 348, color.cyan)
    self:drawKV(left, "Next Auto-Debit", self:formatLoanDueCountdown(loan, data), 40, 456, color.cyan)
    self:drawKV(left, "Term", tostring(loan.termMonths or 0) .. " months", 650, 456, color.white)
    self:createButton(left, "Pay Remaining Principal in Full", 40, 552, 1220, 90, function() self:payLoanFull(data) end, { fgColor = color.gold, fontSize = 36 })

    local h2 = ink.text("PAY EXTRA TOWARD LOAN", 40, 28, 46, color.cyan)
    h2:Reparent(right, -1)
    local customLabel = self:getCustomAmountLabel("loanpay")
    local entryPanel = self:makePanel(right, 40, 98, 1410, 122)
    local entryHead = ink.text("EXTRA PAYMENT AMOUNT", 28, 14, 26, color.dim)
    entryHead:Reparent(entryPanel, -1)
    local entryValue = ink.text(customLabel, 28, 52, (#customLabel >= 18) and 42 or 54, color.green)
    entryValue:SetSize(Vector2.new({ X = 720, Y = 62 }))
    entryValue:Reparent(entryPanel, -1)
    local limit = ink.text("Early payoff available: E$ " .. utils.formatNumber(self:getTransferSourceAmount("loanpay", data)), 820, 58, 27, color.dim)
    limit:SetSize(Vector2.new({ X = 540, Y = 36 }))
    limit:Reparent(entryPanel, -1)

    local numBW = 260
    local ctrlBW = 380
    local bh = 54
    local rowGap = 12
    local x1 = 40
    local x2 = x1 + numBW + rowGap
    local x3 = x2 + numBW + rowGap
    local x4 = x3 + numBW + rowGap
    local y1 = 300
    local y2 = y1 + bh + rowGap
    local y3 = y2 + bh + rowGap
    local y4 = y3 + bh + rowGap

    self:createButton(right, "1", x1, y1, numBW, bh, function() self:appendCustomAmount("loanpay", "1") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "2", x2, y1, numBW, bh, function() self:appendCustomAmount("loanpay", "2") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "3", x3, y1, numBW, bh, function() self:appendCustomAmount("loanpay", "3") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "Back", x4, y1, ctrlBW, bh, function() self:backspaceCustomAmount("loanpay") end, { fgColor = color.gold, fontSize = 25 })
    self:createButton(right, "4", x1, y2, numBW, bh, function() self:appendCustomAmount("loanpay", "4") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "5", x2, y2, numBW, bh, function() self:appendCustomAmount("loanpay", "5") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "6", x3, y2, numBW, bh, function() self:appendCustomAmount("loanpay", "6") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "Clear", x4, y2, ctrlBW, bh, function() self:clearCustomAmount("loanpay") end, { fgColor = color.gold, fontSize = 25 })
    self:createButton(right, "7", x1, y3, numBW, bh, function() self:appendCustomAmount("loanpay", "7") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "8", x2, y3, numBW, bh, function() self:appendCustomAmount("loanpay", "8") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "9", x3, y3, numBW, bh, function() self:appendCustomAmount("loanpay", "9") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "Max", x4, y3, ctrlBW, bh, function() self:fillMaxCustomAmount("loanpay", data) end, { fgColor = color.green, fontSize = 25 })
    self:createButton(right, "0", x1, y4, numBW, bh, function() self:appendCustomAmount("loanpay", "0") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "00", x2, y4, numBW, bh, function() self:appendCustomAmount("loanpay", "00") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "000", x3, y4, numBW, bh, function() self:appendCustomAmount("loanpay", "000") end, { fgColor = color.green, fontSize = 30 })
    self:createButton(right, "Submit Extra Payment", x4, y4, ctrlBW, bh, function() self:submitCustomAmount("loanpay", data) end, { fgColor = color.green, bgColor = color.brandPanel2, fontSize = 20, active = true })

    local errColor = (#errorText > 0) and color.gold or color.dim
    local msg = (#errorText > 0) and errorText or "Extra payments reduce the loan balance immediately. Paying the early payoff amount settles remaining principal and waives future interest."
    local err = ink.text(msg, 40, 600, 26, errColor)
    err:SetWrapping(true)
    err:SetSize(Vector2.new({ X = 1400, Y = 40 }))
    err:Reparent(right, -1)
end

function shell:buildConfirmPage()
    local data = self:getBankData()
    local mode = tostring(self.confirmMode or "deposit")
    local breakdown = self.lastPaymentBreakdown or {}
    local isDeposit = mode == "deposit"
    local isWithdraw = mode == "withdraw"
    local isLoanApply = mode == "loanapply"
    local isLoanReview = mode == "loanreview"
    local isLoanSign = mode == "loansign"
    local isLoanPay = mode == "loanpay"
    local isAutoLoanPay = mode == "autoloanpay"
    local isOpenAccount = mode == "openaccount"
    local isCloseAccount = mode == "closeaccount"
    local isLoanPayoff = isLoanPay and self.loanWasPaidOff == true
    local isAutoLoanPayoff = isAutoLoanPay and breakdown.payoff == true

    local accent = color.riskGreen or color.white
    local title = "TRANSACTION CONFIRMED"
    local subtitle = "The transaction posted successfully and the updated account details appear below."
    local orderLabel = "Transaction"

    if isDeposit then
        title = "DEPOSIT CONFIRMED"
        orderLabel = "Deposit"
    elseif isWithdraw then
        title = "WITHDRAWAL CONFIRMED"
        orderLabel = "Withdrawal"
        accent = color.brandRedBright or color.red
    elseif isOpenAccount then
        title = "ACCOUNT OPENED"
        subtitle = "The opening deposit posted and Marmur banking services are active."
        orderLabel = "Account Opening"
    elseif isCloseAccount then
        title = "ACCOUNT CLOSED"
        subtitle = "The Savings ledger closed and eligible funds returned to Checking."
        orderLabel = "Account Closure"
        accent = color.red
    elseif isLoanApply then
        title = "LOAN APPROVED"
        subtitle = "The personal-loan principal posted to Checking and the repayment plan is active."
        orderLabel = "Loan Approval"
    elseif isLoanReview then
        title = "LOAN REQUEST SUBMITTED"
        subtitle = "Underwriting received the request. The expected decision time appears on the receipt."
        orderLabel = "Loan Request"
        accent = color.gold
    elseif isLoanSign then
        title = "LOAN AGREEMENT SIGNED"
        subtitle = "The signed personal-loan agreement funded immediately to Checking."
        orderLabel = "Loan Agreement"
    elseif isLoanPay then
        title = isLoanPayoff and "LOAN PAID OFF" or "LOAN PAYMENT CONFIRMED"
        subtitle = isLoanPayoff and "The remaining personal-loan balance is fully settled." or "The reviewed personal-loan payment posted successfully."
        orderLabel = isLoanPayoff and "Personal Loan Payoff" or "Personal Loan Payment"
    elseif isAutoLoanPay then
        title = isAutoLoanPayoff and "AUTO LOAN PAID OFF" or "AUTO LOAN PAYMENT CONFIRMED"
        subtitle = isAutoLoanPayoff and "The Vanguard title lien was released after full payoff." or "The payment posted to the selected Vanguard Auto contract."
        orderLabel = isAutoLoanPayoff and "Auto Loan Payoff" or "Auto Loan Payment"
    end

    local amount = math.max(math.floor(tonumber(self.lastAmount) or 0), 0)
    local showConfirmation = isLoanApply or isLoanReview or isLoanSign or isLoanPay or isAutoLoanPay
    local confirmationNumber = tostring(self.lastConfirmationNumber or "MB-PENDING")

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local heading = ink.text(title, 40, 24, 50, accent)
    heading:Reparent(strip, -1)
    local sub = ink.text(subtitle, 42, 82, 27, color.dim)
    sub:SetWrapping(true)
    sub:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    sub:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Amount", "E$ " .. utils.formatNumber(amount), 1900, 30, accent, 390, 23, 36)
    self:drawHeaderStat(strip, showConfirmation and "Confirmation No." or "Status", showConfirmation and confirmationNumber or "POSTED", 2320, 30, showConfirmation and color.cyan or (color.riskGreen or color.white), 440, 22, showConfirmation and 28 or 34)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1760, 680)
    local right = self:makePanel(self.contentCanvas, 1870, 650, 1010, 680)
    local lh = ink.text("TRANSACTION RECEIPT", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    local posted = ink.text("POSTED  " .. Calendar.formatCurrentDateTime(Calendar.getContext(), true), 1700, 30, 22, color.dim)
    posted:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    posted:SetSize(Vector2.new({ X = 660, Y = 32 }))
    posted:Reparent(left, -1)

    local rows = {}
    local function addRow(label, value, valueColor, valueFont)
        table.insert(rows, { label = label, value = tostring(value or "—"), valueColor = valueColor or color.white, valueFont = valueFont })
    end

    addRow("Transaction", orderLabel, accent)
    addRow("Amount", "E$ " .. utils.formatNumber(amount), color.white, 32)

    local statusText = "Transaction completed successfully."
    if isDeposit then
        addRow("From", "Checking", color.white)
        addRow("To", "Savings", color.white)
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Savings Balance", "E$ " .. utils.formatNumber(data.bank or 0), color.gold)
        statusText = "Funds moved from Checking to Savings and were added to the Activity ledger."
    elseif isWithdraw then
        addRow("From", "Savings", color.white)
        addRow("To", "Checking", color.white)
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Savings Balance", "E$ " .. utils.formatNumber(data.bank or 0), color.gold)
        statusText = "Funds moved from Savings to Checking and were added to the Activity ledger."
    elseif isOpenAccount then
        addRow("Opening Deposit", "E$ " .. utils.formatNumber(amount), color.white)
        addRow("Savings Balance", "E$ " .. utils.formatNumber(data.bank or amount), color.gold)
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Account Number", tostring(self.lastAccountNumber or data.accountNumber or "MB-2077-00000000"), color.cyan, 26)
        local bonus = math.max(math.floor(tonumber(self.lastOpeningBonus) or 0), 0)
        addRow("Pending Opening Credit", "E$ " .. utils.formatNumber(bonus), bonus > 0 and color.gold or color.dim)
        statusText = "Marmur portal access is active. Eligible opening credit remains pending for the required 72-hour hold."
    elseif isCloseAccount then
        addRow("Savings Returned", "E$ " .. utils.formatNumber(amount), color.gold)
        addRow("Early Closure Fee", "E$ " .. utils.formatNumber(self.lastClosureChargeback or 0), (self.lastClosureChargeback or 0) > 0 and color.red or color.white)
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Savings Status", "CLOSED", color.red)
        statusText = "The Savings ledger is closed. Sign in again or open a new account to restore Marmur services."
    elseif isLoanReview then
        local loan = data.loan or {}
        local expectedDecision = "Pending"
        if math.floor(tonumber(loan.reviewDecisionMinute) or 0) > 0 then
            expectedDecision = Calendar.formatMinuteStamp(loan.reviewDecisionMinute, Calendar.getContext(), true)
        end
        addRow("Confirmation No.", confirmationNumber, color.cyan, 27)
        addRow("Review Status", "PENDING", color.gold)
        addRow("Expected Decision", expectedDecision, color.white, 26)
        addRow("Payment Schedule", tostring(loan.reviewFrequencyLabel or "Monthly") .. " / " .. tostring(loan.reviewTermMonths or 0) .. " months", color.white)
        statusText = "Underwriting will post its decision automatically. No principal is available until the request is approved and signed."
    elseif isLoanApply or isLoanSign or isLoanPay then
        local loan = data.loan or {}
        addRow("Confirmation No.", confirmationNumber, color.cyan, 27)
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Loan Balance", "E$ " .. utils.formatNumber(loan.balanceDue or breakdown.balanceAfter or 0), isLoanPayoff and (color.riskGreen or color.white) or color.gold)
        addRow("Loan Status", isLoanPayoff and "PAID OFF" or "ACTIVE", isLoanPayoff and (color.riskGreen or color.white) or color.cyan)
        if not isLoanPayoff then
            addRow("Next Auto-Debit", loan.active and self:formatLoanDueCountdown(loan, data) or "Pending", color.white, 26)
        else
            addRow("Remaining Principal", "E$ 0", color.riskGreen or color.white)
        end
        if isLoanApply or isLoanSign then
            statusText = "Personal-loan funding posted to Checking. Auto-debit follows the selected payment schedule."
        elseif isLoanPayoff then
            statusText = "The personal loan is fully settled and no further scheduled debits are due."
        else
            statusText = "The payment posted immediately and the updated balance is available in Loans."
        end
    elseif isAutoLoanPay then
        addRow("Confirmation No.", confirmationNumber, color.cyan, 27)
        addRow("Vehicle", tostring(breakdown.title or "Vanguard Auto Loan"), color.gold, 26)
        addRow("Balance Before", "E$ " .. utils.formatNumber(breakdown.balanceBefore or 0), color.white)
        addRow("Balance After", "E$ " .. utils.formatNumber(breakdown.balanceAfter or 0), isAutoLoanPayoff and (color.riskGreen or color.white) or color.white)
        addRow("Title Status", isAutoLoanPayoff and "LIEN RELEASED" or "BANK LIEN ACTIVE", isAutoLoanPayoff and (color.riskGreen or color.white) or color.gold)
        statusText = isAutoLoanPayoff and "The automobile contract is settled. Vanguard Garage should now reflect customer ownership." or "The automobile payment posted and the remaining contract balance is available in Loans."
    else
        addRow("Checking Balance", "E$ " .. utils.formatNumber(data.wallet or 0), color.white)
        addRow("Savings Balance", "E$ " .. utils.formatNumber(data.bank or 0), color.gold)
        addRow("Status", "POSTED", color.riskGreen or color.white)
    end

    local rowY = 88
    for i, row in ipairs(rows) do
        if i > 7 then break end
        self:drawPolishedRow(left, row.label, row.value, rowY, {
            x = 40,
            width = 1660,
            labelWidth = 500,
            valueColor = row.valueColor,
            valueFontSize = row.valueFont or 29,
            rowHeight = 56,
        })
        rowY = rowY + 58
    end

    local statusPanel = self:makePanel(left, 40, 520, 1660, 118)
    local statusHead = ink.text("STATUS", 24, 14, 22, color.dim)
    statusHead:Reparent(statusPanel, -1)
    local status = ink.text(statusText, 24, 48, 25, color.white)
    status:SetWrapping(true)
    status:SetSize(Vector2.new({ X = 1600, Y = 62 }))
    status:Reparent(statusPanel, -1)

    local rh = ink.text("NEXT ACTION", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)

    if isCloseAccount then
        self:createTransferAction(right, "RETURN TO SIGN IN", 40, 126, 930, 92, function()
            self.isLoggedIn = false
            self:renderPage("login")
        end, true)
        self:createTransferKey(right, "OPEN NEW ACCOUNT", 40, 256, 930, 78, function()
            self.isLoggedIn = false
            self:renderPage("signup")
        end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
    elseif isOpenAccount then
        self:createTransferAction(right, "GO TO HOME", 40, 126, 930, 92, function() self:renderPage("home") end, true)
        self:createTransferKey(right, "OPEN DEPOSIT", 40, 256, 930, 78, function() self:renderPage("deposit") end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
        self:createTransferKey(right, "REVIEW ACTIVITY", 40, 372, 930, 78, function() self:renderPage("transactions") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
    elseif isLoanApply or isLoanReview or isLoanSign or isLoanPay or isAutoLoanPay then
        self:createTransferAction(right, "OPEN LOANS", 40, 126, 930, 92, function() self:renderPage("loans") end, true)
        self:createTransferKey(right, "BACK TO HOME", 40, 256, 930, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        self:createTransferKey(right, "OPEN DEPOSIT", 40, 372, 930, 78, function() self:renderPage("deposit") end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
    else
        local anotherLabel = isDeposit and "MAKE ANOTHER DEPOSIT" or "MAKE ANOTHER WITHDRAWAL"
        self:createTransferAction(right, anotherLabel, 40, 126, 930, 92, function() self:renderPage(isDeposit and "deposit" or "withdraw") end, true)
        self:createTransferKey(right, "BACK TO HOME", 40, 256, 930, 78, function() self:renderPage("home") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
        self:createTransferKey(right, isDeposit and "OPEN WITHDRAW" or "OPEN DEPOSIT", 40, 372, 930, 78, function() self:renderPage(isDeposit and "withdraw" or "deposit") end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
    end
end

local _marmurOriginalGetPageAddress = shell.getPageAddress
function shell:getPageAddress()
    if self.activePage == "loanlockout" then
        return "NETDIR://MARMUR.BANK/PAST-DUE-REPAYMENT"
    elseif self.activePage == "loanpaymentreview" then
        return "NETDIR://MARMUR.BANK/LOAN-PAYMENT-REVIEW"
    elseif self.activePage == "autoloanpaymentreview" then
        return "NETDIR://MARMUR.BANK/AUTO-PAYMENT-REVIEW"
    elseif self.activePage == "autoloanautopayreview" then
        return "NETDIR://MARMUR.BANK/AUTOMOBILE-AUTO-PAY-REVIEW"
    end
    return _marmurOriginalGetPageAddress(self)
end

function shell:isLoanSpecialPage(page)
    return page == "loanlockout" or page == "loanpaymentreview" or page == "autoloanpaymentreview" or page == "autoloanautopayreview"
end

function shell:isLoanLockoutAllowedPage(page)
    if page == "loanlockout" or page == "loanpaymentreview" then return true end
    if page == "confirm" and self.confirmMode == "loanpay" then return true end
    if page == "login" then return true end
    return false
end

function shell:cleanupForSpecialLoanPage()
    for _, sub in ipairs(self.localSubscribers) do
        relay.removeSubscriber(sub)
    end
    self.localSubscribers = {}
    self:clearLoginTimers()
    self:clearLoanSignatureTimer()
    self:clearAccountSignatureTimer()
    self.loginWidgets = {}
    self.loanSignatureWidgets = {}
    self.accountSignatureWidgets = {}
    pcall(function()
        self.browserController.currentPage:RemoveAllChildren()
    end)
    self.contentCanvas = ink.canvas(self:getContentOriginX(), self:getContentOriginY(), inkEAnchor.TopLeft)
    self.contentCanvas:Reparent(self.browserController.currentPage, -1)
end

function shell:renderSpecialLoanPage(page)
    self.activePage = page
    self:cleanupForSpecialLoanPage()
    self:buildFrame()
    local locked = false
    pcall(function() locked = Bank:shouldForceLoanLockout() == true end)
    if self.activePage == "loanlockout" then
        self:buildLoanLockoutPage()
    else
        if not (self.activePage == "loanpaymentreview" and locked == true) then
            self:buildNavbar()
        end
        if self.activePage == "loanpaymentreview" then
            self:buildLoanPaymentReviewPage()
        elseif self.activePage == "autoloanpaymentreview" then
            self:buildAutoLoanPaymentReviewPage()
        elseif self.activePage == "autoloanautopayreview" then
            self:buildAutoLoanAutoPayReviewPage()
        end
    end
    self:applyAddressBar()
end

local _marmurOriginalRenderPage = shell.renderPage
function shell:renderPage(page)
    local requestedPage = page or self.activePage
    self:clearInsightsRefreshTimer()
    if self.isLoggedIn == true then
        local locked = false
        pcall(function() locked = Bank:shouldForceLoanLockout() == true end)
        if locked == true and not self:isLoanLockoutAllowedPage(requestedPage) then
            requestedPage = "loanlockout"
        end
    end
    if self:isLoanSpecialPage(requestedPage) then
        self:clearHomeGraphTimer()
        self.homeGraphGeneration = math.floor(tonumber(self.homeGraphGeneration or 0) or 0) + 1
        if self.isLoggedIn ~= true then
            _marmurOriginalRenderPage(self, "login")
            return
        end
        local open = false
        pcall(function() open = Bank:isAccountOpen() == true end)
        if not open then
            self.isLoggedIn = false
            _marmurOriginalRenderPage(self, "login")
            return
        end
        self:renderSpecialLoanPage(requestedPage)
        return
    end
    _marmurOriginalRenderPage(self, requestedPage)
end

function shell:getPastDueSummary(data)
    local summary = nil
    pcall(function() summary = Bank:getPersonalLoanPastDueSummary((data or {}).loan) end)
    if type(summary) ~= "table" then
        summary = { pastDue = false, missedPayments = 0, requiredPayment = 0, lateFee = 0, totalToCure = 0, defaultThreshold = 3, defaultEligible = false }
    end
    return summary
end

local _marmurOriginalSubmitCustomAmount = shell.submitCustomAmount
function shell:submitCustomAmount(mode, data)
    local amount = self:getCustomAmount(mode)
    if mode == "loanpay" then
        self:stageLoanPaymentReview(amount, data, false)
        return
    end
    if mode == "autoloanpay" then
        self:stageAutoLoanPaymentReview("custom", amount, data)
        return
    end
    _marmurOriginalSubmitCustomAmount(self, mode, data)
end

local _marmurOriginalSubmitLoanRequest = shell.submitLoanRequest
function shell:submitLoanRequest(amount, data)
    local daysLeft = 0
    local blocked = false
    pcall(function()
        blocked = Bank:isLoanDefaultCooldownActive() == true
        daysLeft = Bank:getLoanDefaultCooldownDaysLeft() or 0
    end)
    if blocked == true then
        self:setLoanError("New personal loans are temporarily disabled after default recovery. Days remaining: " .. tostring(daysLeft) .. ".")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(self.activePage == "loanapply" and "loanapply" or "loans")
        return
    end
    _marmurOriginalSubmitLoanRequest(self, amount, data)
end

local _marmurOriginalPerformLoanApplication = shell.performLoanApplication
function shell:performLoanApplication(offer)
    local daysLeft = 0
    local blocked = false
    pcall(function()
        blocked = Bank:isLoanDefaultCooldownActive() == true
        daysLeft = Bank:getLoanDefaultCooldownDaysLeft() or 0
    end)
    if blocked == true then
        self:setLoanError("New personal loans are temporarily disabled after default recovery. Days remaining: " .. tostring(daysLeft) .. ".")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loans")
        return
    end
    _marmurOriginalPerformLoanApplication(self, offer)
end

function shell:stageLoanPaymentReview(amount, data, payoffMode)
    local snapshot = data or self:getBankData()
    local loan = snapshot.loan or {}
    local preview = nil
    amount = math.floor(tonumber(amount) or 0)
    if payoffMode == true then
        amount = self:getLoanEarlyPayoffAmountFromData(loan)
        if amount <= 0 then amount = math.floor(tonumber(loan.balanceDue) or 0) end
    end
    pcall(function() preview = Bank:getManualLoanPaymentPreview(amount, payoffMode == true) end)
    if type(preview) ~= "table" or preview.active ~= true then
        self:setLoanError("No active loan is available for repayment.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanpay")
        return
    end
    if preview.paymentAmount <= 0 then
        self:setLoanError("Enter a repayment amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(preview.pastDue and "loanlockout" or "loanpay")
        return
    end
    if preview.pastDue == true and preview.payoff ~= true and preview.paymentAmount < (preview.requiredPayment or 0) then
        self:setLoanError("Past-due payment must include the missed scheduled amount: E$ " .. utils.formatNumber(preview.requiredPayment or 0) .. ".")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("loanlockout")
        return
    end
    if preview.totalDebit > (preview.wallet or snapshot.wallet or 0) then
        self:setLoanError("Checking balance is too low for payment plus late fee: E$ " .. utils.formatNumber(preview.totalDebit or 0) .. ".")
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage(preview.pastDue and "loanlockout" or "loanpay")
        return
    end
    self.pendingLoanPayment = preview
    self:setLoanError("")
    self:renderPage("loanpaymentreview")
end

function shell:confirmLoanPaymentReview()
    local pending = self.pendingLoanPayment
    if type(pending) ~= "table" then
        self:setLoanError("No reviewed payment is pending.")
        self:renderPage("loanpay")
        return
    end
    local ok = false
    local message = "Repayment could not be completed."
    local posted = pending
    local callOk, result, msg, preview = pcall(function()
        return Bank:postReviewedManualLoanPayment(pending.paymentAmount, pending.payoff == true)
    end)
    if callOk then
        ok = result == true
        if type(msg) == "string" and msg ~= "" then message = msg end
        if type(preview) == "table" then posted = preview end
    end
    if ok then
        self.confirmMode = "loanpay"
        self.loanWasPaidOff = (posted.balanceAfter or 0) <= 0 or pending.payoff == true
        self.lastAmount = math.floor(tonumber(posted.totalDebit) or 0)
        self.lastPaymentBreakdown = posted
        self:updateLastLoanConfirmationNumber()
        self.pendingLoanPayment = nil
        self:setCustomAmountString("loanpay", "")
        self:setLoanError("")
        pcall(function() Bank.lastLoanBalance = posted.balanceAfter or 0 end)
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setLoanError(message)
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage((pending.pastDue == true) and "loanlockout" or "loanpaymentreview")
    end
end

function shell:payLoanFull(data)
    self:stageLoanPaymentReview(0, data, true)
end

function shell:buildLoanLockoutPage()
    local recoveryOk = false
    local recoveryStatus = ""
    local recoveryPayload = nil
    pcall(function()
        recoveryOk, recoveryStatus, recoveryPayload = Bank:processPersonalLoanDefaultLiquidation(false)
    end)
    local data = self:getBankData()
    local loan = data.loan or {}
    local summary = self:getPastDueSummary(data)
    local recovery = {}
    pcall(function() recovery = Bank:getPersonalLoanDefaultRecoveryStatus() or {} end)
    local errorText = tostring(self:getLoanError() or "")

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local titleText = summary.pastDue and "ACCOUNT ACCESS RESTRICTED" or "RESTRICTION CLEARED"
    local titleColor = summary.pastDue and color.red or (color.riskGreen or color.white)
    local title = ink.text(titleText, 40, 24, 50, titleColor)
    title:Reparent(strip, -1)
    local subtitleText = summary.pastDue and "A past-due personal loan limits the portal to the repayment path until the required amount posts." or "The personal loan is current and normal banking access can resume."
    local subtitle = ink.text(subtitleText, 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Checking Available", "E$ " .. utils.formatNumber(data.wallet or 0), 1880, 30, color.white, 420, 23, 35)
    self:drawHeaderStat(strip, "Loan Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 2320, 30, color.gold, 440, 23, 35)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1760, 680)
    local right = self:makePanel(self.contentCanvas, 1870, 650, 1010, 680)

    local lh = ink.text(summary.pastDue and "PAYMENT REQUIRED" or "ACCOUNT CURRENT", 38, 24, 43, titleColor)
    lh:Reparent(left, -1)
    self:drawPolishedRow(left, "Loan Status", summary.pastDue and "PAST DUE" or "CURRENT", 92, { x = 40, width = 1660, labelWidth = 520, valueColor = titleColor })
    self:drawPolishedRow(left, "Missed Payments", tostring(summary.missedPayments or 0), 152, { x = 40, width = 1660, labelWidth = 520, valueColor = (summary.missedPayments or 0) > 0 and color.red or color.white })
    self:drawPolishedRow(left, "Past-Due Principal", "E$ " .. utils.formatNumber(summary.requiredPayment or 0), 212, { x = 40, width = 1660, labelWidth = 520, valueColor = color.gold })
    self:drawPolishedRow(left, "Manual Late Fee", "E$ " .. utils.formatNumber(summary.lateFee or 0), 272, { x = 40, width = 1660, labelWidth = 520, valueColor = (summary.lateFee or 0) > 0 and color.red or color.dim })
    self:drawPolishedRow(left, "Required To Restore", "E$ " .. utils.formatNumber(summary.totalToCure or 0), 332, { x = 40, width = 1660, labelWidth = 520, valueColor = color.riskGreen or color.white, valueFontSize = 33 })
    self:drawPolishedRow(left, "Default Threshold", tostring(summary.defaultThreshold or 3) .. " missed payments", 392, { x = 40, width = 1660, labelWidth = 520, valueColor = color.white })
    self:drawPolishedRow(left, "Portal Access", summary.pastDue and "REPAYMENT ONLY" or "RESTORED", 452, { x = 40, width = 1660, labelWidth = 520, valueColor = summary.pastDue and color.red or (color.riskGreen or color.white) })

    local noticeText = "Manual late fees apply only after a scheduled payment is missed. A successful scheduled auto-payment does not receive this fee."
    if recoveryStatus == "no_eligible_vehicles" then
        noticeText = "Default recovery reached Vanguard, but no eligible customer-owned vehicles were available. Financed vehicles remain excluded."
    elseif recoveryStatus == "liquidation_api_unavailable" then
        noticeText = "Default recovery found possible Vanguard assets, but no compatible liquidation bridge responded. Update the Vanguard/PVL integration."
    elseif recoveryOk == true then
        noticeText = "Default recovery posted: " .. tostring((recoveryPayload or {}).vehicleCount or recovery.lastVehicles or 0) .. " vehicle(s), E$ " .. utils.formatNumber((recoveryPayload or {}).recovered or recovery.lastRecovery or 0) .. " credited."
    end
    local notice = self:makePanel(left, 40, 540, 1660, 96)
    local nt = ink.text(noticeText, 24, 14, 23, recoveryOk and (color.riskGreen or color.white) or color.dim)
    nt:SetWrapping(true)
    nt:SetSize(Vector2.new({ X = 1610, Y = 68 }))
    nt:Reparent(notice, -1)

    local rh = ink.text("REPAYMENT OPTIONS", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    local actionCopy = ink.text(summary.pastDue and "Review the required catch-up payment or settle the remaining balance in full. Payment uses available Checking funds." or "The restriction is cleared. Return to Home or open Loans to review the current account status.", 40, 88, 27, color.dim)
    actionCopy:SetWrapping(true)
    actionCopy:SetSize(Vector2.new({ X = 920, Y = 110 }))
    actionCopy:Reparent(right, -1)

    if summary.pastDue then
        self:createTransferAction(right, "REVIEW REQUIRED PAYMENT", 40, 224, 930, 92, function() self:stageLoanPaymentReview(summary.requiredPayment or 0, data, false) end, true)
        self:createTransferKey(right, "REVIEW FULL PAYOFF", 40, 354, 930, 78, function() self:stageLoanPaymentReview(0, data, true) end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 28 })
        self:createTransferKey(right, "EXIT SECURE SESSION", 40, 470, 930, 78, function() self:logout() end, { borderColor = color.dim, textColor = color.white, fontSize = 27 })
    else
        self:createTransferAction(right, "RETURN TO HOME", 40, 236, 930, 92, function() self:renderPage("home") end, true)
        self:createTransferKey(right, "OPEN LOANS", 40, 368, 930, 78, function() self:renderPage("loans") end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
    end

    if #errorText > 0 then
        local err = ink.text(errorText, 40, 580, 23, color.red)
        err:SetWrapping(true)
        err:SetSize(Vector2.new({ X = 930, Y = 56 }))
        err:Reparent(right, -1)
    end
end

function shell:buildLoanPaymentReviewPage()
    local pending = self.pendingLoanPayment
    if type(pending) ~= "table" then
        local data = self:getBankData()
        local summary = self:getPastDueSummary(data)
        if summary.pastDue then
            self.pendingLoanPayment = nil
            self:buildLoanLockoutPage()
            return
        end
        self:renderPage("loanpay")
        return
    end

    local locked = false
    pcall(function() locked = Bank:shouldForceLoanLockout() == true end)
    local paymentType = pending.payoff and "FULL PAYOFF" or (pending.pastDue and "PAST-DUE CURE" or "MANUAL PAYMENT")

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local title = ink.text("REVIEW PERSONAL LOAN PAYMENT", 40, 24, 50, pending.pastDue and color.gold or color.cyan)
    title:Reparent(strip, -1)
    local subtitle = ink.text("Confirm the debit, fee, and projected balance before Marmur posts the payment.", 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Total From Checking", "E$ " .. utils.formatNumber(pending.totalDebit or 0), 1840, 30, color.gold, 440, 22, 35)
    self:drawHeaderStat(strip, "Loan Balance After", "E$ " .. utils.formatNumber(pending.balanceAfter or 0), 2310, 30, (pending.balanceAfter or 0) <= 0 and (color.riskGreen or color.white) or color.white, 450, 22, 35)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1760, 680)
    local right = self:makePanel(self.contentCanvas, 1870, 650, 1010, 680)
    local lh = ink.text("PAYMENT SUMMARY", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    self:drawPolishedRow(left, "Payment Type", paymentType, 92, { x = 40, width = 1660, labelWidth = 540, valueColor = color.cyan })
    self:drawPolishedRow(left, "Loan Payment", "E$ " .. utils.formatNumber(pending.paymentAmount or 0), 152, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Past-Due Late Fee", "E$ " .. utils.formatNumber(pending.lateFee or 0), 212, { x = 40, width = 1660, labelWidth = 540, valueColor = (pending.lateFee or 0) > 0 and color.red or color.dim })
    self:drawPolishedRow(left, "Total From Checking", "E$ " .. utils.formatNumber(pending.totalDebit or 0), 272, { x = 40, width = 1660, labelWidth = 540, valueColor = color.gold, valueFontSize = 33 })
    self:drawPolishedRow(left, "Loan Balance Before", "E$ " .. utils.formatNumber(pending.balanceBefore or 0), 332, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Loan Balance After", "E$ " .. utils.formatNumber(pending.balanceAfter or 0), 392, { x = 40, width = 1660, labelWidth = 540, valueColor = (pending.balanceAfter or 0) <= 0 and (color.riskGreen or color.white) or color.white })
    self:drawPolishedRow(left, "Checking Available", "E$ " .. utils.formatNumber(pending.wallet or 0), 452, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Access After Payment", pending.clearsPastDue and "RESTORED" or "UNCHANGED", 512, { x = 40, width = 1660, labelWidth = 540, valueColor = pending.clearsPastDue and (color.riskGreen or color.white) or color.gold })
    local note = self:makePanel(left, 40, 586, 1660, 54)
    local nt = ink.text("A manual late fee appears only after a scheduled payment was missed.", 24, 13, 22, color.dim)
    nt:SetSize(Vector2.new({ X = 1600, Y = 32 }))
    nt:Reparent(note, -1)

    local rh = ink.text("CONFIRM PAYMENT", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    local copy = ink.text("Submitting posts this reviewed amount immediately. The next screen provides the official confirmation number.", 40, 88, 27, color.dim)
    copy:SetWrapping(true)
    copy:SetSize(Vector2.new({ X = 920, Y = 110 }))
    copy:Reparent(right, -1)
    self:createTransferAction(right, "SUBMIT PAYMENT", 40, 224, 930, 92, function() self:confirmLoanPaymentReview() end, true)
    self:createTransferKey(right, "BACK / EDIT", 40, 354, 930, 78, function()
        self.pendingLoanPayment = nil
        self:renderPage(locked and "loanlockout" or "loanpay")
    end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
    self:createTransferKey(right, locked and "EXIT SECURE SESSION" or "CANCEL", 40, 470, 930, 78, function()
        if locked then
            self:logout()
        else
            self.pendingLoanPayment = nil
            self:renderPage("loans")
        end
    end, { borderColor = color.dim, textColor = color.white, fontSize = 27 })
end

function shell:resolveReviewedAutoLoan(pending)
    if type(pending) ~= "table" then return nil end
    local loans = {}
    local refreshed = pcall(function()
        loans = Bank:getAutoLoans(true) or {}
    end)
    if refreshed ~= true then return nil end

    local serial = math.floor(tonumber(pending.contractSerial) or 0)
    local fallbackIndex = math.floor(tonumber(pending.index) or 0)
    local fallbackTitle = tostring(pending.title or "")
    for _, loan in ipairs(loans) do
        local loanSerial = math.floor(tonumber(loan.contractSerial) or 0)
        if serial > 0 and loanSerial == serial then
            return loan
        end
        if serial <= 0
            and math.floor(tonumber(loan.index) or 0) == fallbackIndex
            and tostring(loan.title or "") == fallbackTitle then
            return loan
        end
    end
    return nil
end

function shell:stageAutoLoanPaymentReview(kind, amount, data)
    local snapshot = data or self:getBankData()
    local autoLoans = snapshot.autoLoans or {}
    local loan = self:getSelectedAutoLoan(autoLoans)
    if not loan then
        self:setTransferError("autoloanpay", "No active auto loan is available for payment.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end
    local balance = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
    local paymentAmount = math.floor(tonumber(amount) or 0)
    local paymentKind = tostring(kind or "custom")
    if paymentKind == "scheduled" then
        paymentAmount = math.min(math.max(math.floor(tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0), 0), balance)
    elseif paymentKind == "full" then
        paymentAmount = balance
    end
    if paymentAmount <= 0 then
        self:setTransferError("autoloanpay", "Enter a payment amount greater than E$ 0.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end
    if paymentAmount > (snapshot.wallet or 0) then
        self:setTransferError("autoloanpay", "Payment exceeds checking balance.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end
    if paymentAmount > balance then
        self:setTransferError("autoloanpay", "Payment exceeds current payoff balance.")
        utils.playSound("ui_menu_onpress", 1)
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
        return
    end
    self.pendingAutoLoanPayment = {
        index = math.floor(tonumber(self.autoLoanSelectedIndex or loan.index or 1) or 1),
        contractSerial = math.floor(tonumber(loan.contractSerial) or 0),
        title = tostring(loan.title or "Vanguard Auto Loan"),
        paymentKind = paymentKind,
        paymentAmount = paymentAmount,
        totalDebit = paymentAmount,
        balanceBefore = balance,
        balanceAfter = math.max(balance - paymentAmount, 0),
        wallet = snapshot.wallet or 0,
        payoff = paymentKind == "full" or paymentAmount >= balance,
    }
    self:clearTransferError("autoloanpay")
    self.lastAutoLoanMessage = ""
    self:renderPage("autoloanpaymentreview")
end

function shell:submitAutoLoanScheduledPayment()
    self:stageAutoLoanPaymentReview("scheduled", 0, nil)
end

function shell:submitAutoLoanCustomPayment(amount, data)
    self:stageAutoLoanPaymentReview("custom", amount, data)
end

function shell:submitAutoLoanFullPayment()
    self:stageAutoLoanPaymentReview("full", 0, nil)
end

function shell:confirmAutoLoanPaymentReview()
    local pending = self.pendingAutoLoanPayment
    if type(pending) ~= "table" then
        self:setTransferError("autoloanpay", "No reviewed auto-loan payment is pending.")
        self:renderPage("autoloanpay")
        return
    end
    local currentLoan = self:resolveReviewedAutoLoan(pending)
    if not currentLoan
        or currentLoan.repossessed == true
        or math.max(math.floor(tonumber(currentLoan.balanceDue) or 0), 0) ~= math.max(math.floor(tonumber(pending.balanceBefore) or 0), 0)
        or (pending.paymentKind == "scheduled"
            and math.max(math.floor(tonumber(currentLoan.scheduledPayment or currentLoan.monthlyPayment) or 0), 0)
                ~= math.max(math.floor(tonumber(pending.paymentAmount) or 0), 0)) then
        local staleReason = "The selected automobile loan changed after review. Return to the loan, refresh the amounts, and review the payment again."
        self:setTransferError("autoloanpay", staleReason)
        self.lastAutoLoanMessage = staleReason
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("autoloanpaymentreview")
        return
    end
    pending.index = math.floor(tonumber(currentLoan.index) or pending.index or 0)
    local ok = false
    local reason = "Auto-loan payment failed. Check the Checking balance, repossession status, or Vanguard Auto installation."
    if pending.paymentKind == "scheduled" then
        pcall(function() ok = Bank:payVanguardAutoLoanScheduled(pending.index) == true end)
    elseif pending.paymentKind == "full" then
        pcall(function() ok = Bank:payVanguardAutoLoanInFull(pending.index) == true end)
    else
        local callOk, result, message = pcall(function() return Bank:payVanguardAutoLoanCustom(pending.index, pending.paymentAmount) end)
        if callOk then
            ok = result == true
            if type(message) == "string" and message ~= "" then reason = message end
        end
    end
    if ok then
        self.confirmMode = "autoloanpay"
        self.loanWasPaidOff = pending.payoff == true
        self.lastAmount = pending.totalDebit or pending.paymentAmount or 0
        self.lastPaymentBreakdown = pending
        self:updateLastLoanConfirmationNumber()
        self.pendingAutoLoanPayment = nil
        self:setCustomAmountString("autoloanpay", "")
        self:clearTransferError("autoloanpay")
        self.lastAutoLoanMessage = pending.payoff and "Auto loan paid in full. Vanguard title lien released." or "Auto-loan payment posted."
        self.autoLoanPaymentKeypadOpen = false
        utils.playSound("ui_jingle_quest_update", 1)
        self:renderPage("confirm")
    else
        self:setTransferError("autoloanpay", reason)
        self.lastAutoLoanMessage = reason
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("autoloanpaymentreview")
    end
end

function shell:buildAutoLoanPaymentReviewPage()
    local pending = self.pendingAutoLoanPayment
    if type(pending) ~= "table" then
        self:renderPage("autoloanpay")
        return
    end

    local paymentType = pending.payoff and "FULL PAYOFF" or string.upper(tostring(pending.paymentKind or "CUSTOM PAYMENT"))
    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local title = ink.text("REVIEW AUTO LOAN PAYMENT", 40, 24, 50, color.cyan)
    title:Reparent(strip, -1)
    local subtitle = ink.text("Confirm the selected Vanguard Auto payment before Marmur posts it against the vehicle lien.", 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1500, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Total From Checking", "E$ " .. utils.formatNumber(pending.totalDebit or 0), 1840, 30, color.gold, 440, 22, 35)
    self:drawHeaderStat(strip, "Loan Balance After", "E$ " .. utils.formatNumber(pending.balanceAfter or 0), 2310, 30, (pending.balanceAfter or 0) <= 0 and (color.riskGreen or color.white) or color.white, 450, 22, 35)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1760, 680)
    local right = self:makePanel(self.contentCanvas, 1870, 650, 1010, 680)
    local lh = ink.text("AUTOMOBILE PAYMENT SUMMARY", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    local vehicle = ink.text(tostring(pending.title or "Vanguard Auto Loan"), 40, 80, 31, color.gold)
    vehicle:SetWrapping(true)
    vehicle:SetSize(Vector2.new({ X = 1660, Y = 54 }))
    vehicle:Reparent(left, -1)
    self:drawPolishedRow(left, "Payment Type", paymentType, 148, { x = 40, width = 1660, labelWidth = 540, valueColor = color.cyan })
    self:drawPolishedRow(left, "Payment Amount", "E$ " .. utils.formatNumber(pending.paymentAmount or 0), 208, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Late Fee", "E$ 0", 268, { x = 40, width = 1660, labelWidth = 540, valueColor = color.dim })
    self:drawPolishedRow(left, "Total From Checking", "E$ " .. utils.formatNumber(pending.totalDebit or 0), 328, { x = 40, width = 1660, labelWidth = 540, valueColor = color.gold, valueFontSize = 33 })
    self:drawPolishedRow(left, "Loan Balance Before", "E$ " .. utils.formatNumber(pending.balanceBefore or 0), 388, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Loan Balance After", "E$ " .. utils.formatNumber(pending.balanceAfter or 0), 448, { x = 40, width = 1660, labelWidth = 540, valueColor = (pending.balanceAfter or 0) <= 0 and (color.riskGreen or color.white) or color.white })
    self:drawPolishedRow(left, "Title Status After", pending.payoff and "LIEN RELEASED" or "BANK LIEN ACTIVE", 508, { x = 40, width = 1660, labelWidth = 540, valueColor = pending.payoff and (color.riskGreen or color.white) or color.gold })
    local note = self:makePanel(left, 40, 584, 1660, 56)
    local nt = ink.text("Financed vehicles remain bank-owned until the full payoff posts.", 24, 13, 22, color.dim)
    nt:SetSize(Vector2.new({ X = 1600, Y = 32 }))
    nt:Reparent(note, -1)

    local rh = ink.text("CONFIRM PAYMENT", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    local copy = ink.text("Submitting posts immediately to this automobile contract and generates a Marmur confirmation number.", 40, 88, 27, color.dim)
    copy:SetWrapping(true)
    copy:SetSize(Vector2.new({ X = 920, Y = 110 }))
    copy:Reparent(right, -1)
    self:createTransferAction(right, "SUBMIT AUTO PAYMENT", 40, 224, 930, 92, function() self:confirmAutoLoanPaymentReview() end, true)
    self:createTransferKey(right, "BACK / EDIT", 40, 354, 930, 78, function()
        self.pendingAutoLoanPayment = nil
        self.autoLoanPaymentKeypadOpen = true
        self:renderPage("autoloanpay")
    end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 29 })
    self:createTransferKey(right, "CANCEL", 40, 470, 930, 78, function()
        self.pendingAutoLoanPayment = nil
        self:renderPage("loans")
    end, { borderColor = color.dim, textColor = color.white, fontSize = 27 })
end

function shell:stageAutoLoanAutoPayReview(data)
    local snapshot = data or self:getBankData()
    local loan = self:getSelectedAutoLoan(snapshot.autoLoans or {})
    if not loan then
        self.lastAutoLoanMessage = "No active automobile loan is available."
        self.pendingAutoLoanAutoPay = nil
        self:renderPage("loans")
        return
    end
    if loan.autoPaySupported ~= true then
        self.lastAutoLoanMessage = "Automobile Auto-Pay controls require an updated Vanguard Auto installation. Manual payments remain available."
        self.pendingAutoLoanAutoPay = nil
        self:renderPage("autoloanpay")
        return
    end
    if loan.repossessed == true then
        self.lastAutoLoanMessage = "Automobile Auto-Pay cannot be changed after repossession."
        self.pendingAutoLoanAutoPay = nil
        self:renderPage("autoloanpay")
        return
    end

    self.pendingAutoLoanAutoPay = {
        index = math.floor(tonumber(loan.index or self.autoLoanSelectedIndex or 1) or 1),
        contractSerial = math.floor(tonumber(loan.contractSerial) or 0),
        title = tostring(loan.title or "Vanguard Auto Loan"),
        balanceBefore = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0),
        currentEnabled = loan.autoPayEnabled == true,
        requestedEnabled = loan.autoPayEnabled ~= true,
        scheduledPayment = math.max(math.floor(tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0), 0),
        frequencyLabel = tostring(loan.frequencyLabel or "Monthly"),
        nextDueText = tostring(loan.nextDueText or "—"),
        applied = false,
        error = "",
    }
    self.lastAutoLoanMessage = ""
    self:renderPage("autoloanautopayreview")
end

function shell:confirmAutoLoanAutoPayReview()
    local pending = self.pendingAutoLoanAutoPay
    if type(pending) ~= "table" or pending.applied == true then
        self.lastAutoLoanMessage = "No reviewed automobile Auto-Pay change is pending."
        self:renderPage("autoloanpay")
        return
    end
    local currentLoan = self:resolveReviewedAutoLoan(pending)
    if not currentLoan
        or currentLoan.repossessed == true
        or currentLoan.autoPaySupported ~= true
        or currentLoan.autoPayEnabled ~= pending.currentEnabled
        or math.max(math.floor(tonumber(currentLoan.balanceDue) or 0), 0) ~= math.max(math.floor(tonumber(pending.balanceBefore) or 0), 0) then
        pending.error = "The selected automobile loan changed after review. Return to the loan and review the current servicing status again."
        self.lastAutoLoanMessage = pending.error
        utils.playSound("ui_menu_onpress", 1)
        self:renderPage("autoloanautopayreview")
        return
    end
    pending.index = math.floor(tonumber(currentLoan.index) or pending.index or 0)

    local callOk, result, detail = pcall(function()
        return Bank:setVanguardAutoLoanAutoPay(pending.index, pending.requestedEnabled == true)
    end)
    if callOk == true and result == true then
        pending.applied = true
        pending.currentEnabled = pending.requestedEnabled == true
        pending.error = ""
        pending.message = type(detail) == "string" and detail or (pending.currentEnabled and "Automobile Auto-Pay enabled." or "Automobile Auto-Pay disabled.")
        self.lastAutoLoanMessage = pending.message
        utils.playSound("ui_jingle_quest_update", 1)
    else
        pending.error = (callOk == true and type(detail) == "string" and detail ~= "") and detail or "Automobile Auto-Pay could not be changed. Update Vanguard Auto or refresh the loan record."
        self.lastAutoLoanMessage = pending.error
        utils.playSound("ui_menu_onpress", 1)
    end
    self:renderPage("autoloanautopayreview")
end

function shell:buildAutoLoanAutoPayReviewPage()
    local pending = self.pendingAutoLoanAutoPay
    if type(pending) ~= "table" then
        self:renderPage("autoloanpay")
        return
    end

    local completed = pending.applied == true
    local currentLabel = pending.currentEnabled == true and "ON" or "OFF"
    local requestedLabel = pending.requestedEnabled == true and "ON" or "OFF"
    local accent = completed and (color.riskGreen or color.white) or color.cyan
    local titleText = completed and (pending.currentEnabled and "AUTO LOAN AUTO-PAY ENABLED" or "AUTO LOAN AUTO-PAY DISABLED") or "REVIEW AUTO LOAN AUTO-PAY"
    local subtitleText = completed and tostring(pending.message or "The automobile servicing preference was updated.") or "Review the selected automobile contract before Marmur changes its scheduled-payment preference."

    local strip = self:makePanel(self.contentCanvas, 80, 480, 2800, 145)
    local title = ink.text(titleText, 40, 24, 48, accent)
    title:Reparent(strip, -1)
    local subtitle = ink.text(subtitleText, 42, 82, 27, color.dim)
    subtitle:SetWrapping(true)
    subtitle:SetSize(Vector2.new({ X = 1540, Y = 42 }))
    subtitle:Reparent(strip, -1)
    self:drawHeaderStat(strip, "Current Status", currentLabel, 2030, 30, pending.currentEnabled and (color.riskGreen or color.white) or color.gold, 340, 22, 35)
    self:drawHeaderStat(strip, completed and "Result" or "Requested Status", completed and "CONFIRMED" or requestedLabel, 2400, 30, completed and (color.riskGreen or color.white) or color.cyan, 360, 22, 33)

    local left = self:makePanel(self.contentCanvas, 80, 650, 1760, 680)
    local right = self:makePanel(self.contentCanvas, 1870, 650, 1010, 680)
    local lh = ink.text("AUTOMOBILE SERVICING", 38, 24, 43, color.cyan)
    lh:Reparent(left, -1)
    local vehicle = ink.text(tostring(pending.title or "Vanguard Auto Loan"), 40, 80, 31, color.gold)
    vehicle:SetWrapping(true)
    vehicle:SetSize(Vector2.new({ X = 1660, Y = 54 }))
    vehicle:Reparent(left, -1)
    self:drawPolishedRow(left, "Current Auto-Pay", currentLabel, 148, { x = 40, width = 1660, labelWidth = 540, valueColor = pending.currentEnabled and (color.riskGreen or color.white) or color.gold })
    self:drawPolishedRow(left, completed and "Confirmed Status" or "Requested Change", completed and currentLabel or requestedLabel, 208, { x = 40, width = 1660, labelWidth = 540, valueColor = completed and (color.riskGreen or color.white) or color.cyan })
    self:drawPolishedRow(left, tostring(pending.frequencyLabel or "Scheduled") .. " Payment", "E$ " .. utils.formatNumber(pending.scheduledPayment or 0), 268, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Next Due", tostring(pending.nextDueText or "—"), 328, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Insurance Auto-Pay", "UNCHANGED", 388, { x = 40, width = 1660, labelWidth = 540, valueColor = color.white })
    self:drawPolishedRow(left, "Servicing Owner", "MARMUR BANK", 448, { x = 40, width = 1660, labelWidth = 540, valueColor = color.cyan })

    local noteCopy = completed and tostring(pending.message or "Automobile Auto-Pay updated.") or "This authorization changes only the selected automobile loan. Vanguard insurance Auto-Pay remains separate and is not modified."
    if type(pending.error) == "string" and pending.error ~= "" then noteCopy = pending.error end
    local note = self:makePanel(left, 40, 532, 1660, 108)
    local nt = ink.text(noteCopy, 24, 16, 24, (pending.error or "") ~= "" and color.red or color.dim)
    nt:SetWrapping(true)
    nt:SetSize(Vector2.new({ X = 1610, Y = 76 }))
    nt:Reparent(note, -1)

    local rh = ink.text(completed and "CONFIRMATION" or "AUTHORIZATION", 38, 24, 43, color.cyan)
    rh:Reparent(right, -1)
    if completed then
        local copy = ink.text("The automobile loan record now reflects the confirmed servicing preference.", 40, 88, 27, color.dim)
        copy:SetWrapping(true)
        copy:SetSize(Vector2.new({ X = 920, Y = 94 }))
        copy:Reparent(right, -1)
        self:createTransferAction(right, "RETURN TO AUTO LOAN", 40, 224, 930, 92, function()
            self.pendingAutoLoanAutoPay = nil
            self:renderPage("autoloanpay")
        end, true)
        self:createTransferKey(right, "OPEN LOANS", 40, 354, 930, 78, function()
            self.pendingAutoLoanAutoPay = nil
            self:renderPage("loans")
        end, { borderColor = color.dim, textColor = color.white, fontSize = 29 })
    else
        local actionText = pending.requestedEnabled and "ENABLE AUTO-PAY" or "DISABLE AUTO-PAY"
        local copy = ink.text("Submitting changes the scheduled-payment preference only after this review is confirmed.", 40, 88, 27, color.dim)
        copy:SetWrapping(true)
        copy:SetSize(Vector2.new({ X = 920, Y = 94 }))
        copy:Reparent(right, -1)
        self:createTransferAction(right, actionText, 40, 224, 930, 92, function() self:confirmAutoLoanAutoPayReview() end, true)
        self:createTransferKey(right, "BACK / KEEP CURRENT", 40, 354, 930, 78, function()
            self.pendingAutoLoanAutoPay = nil
            self:renderPage("autoloanpay")
        end, { borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red, fontSize = 27 })
        self:createTransferKey(right, "CANCEL", 40, 470, 930, 78, function()
            self.pendingAutoLoanAutoPay = nil
            self:renderPage("loans")
        end, { borderColor = color.dim, textColor = color.white, fontSize = 27 })
    end
end

local MARMUR_BASE_FONT_SCALE = 1.10
local MARMUR_DEFAULT_PAGE_FONT_SCALE = 1.34
local MARMUR_READABLE_PAGE_FONT_SCALE = 1.36
local MARMUR_SPACIOUS_PAGE_FONT_SCALE = 1.38
local MARMUR_DENSE_PAGE_FONT_SCALE = 1.30
local MARMUR_PAGE_LANE_X = 360
local MARMUR_PAGE_LANE_Y = -100
local MARMUR_PAGE_LANE_SCALE_X = 0.90
local MARMUR_PAGE_LANE_SCALE_Y = 1.00

function shell:getAuthenticatedPageFontScale()
    local page = tostring(self.activePage or "home")
    if page == "withdraw" then
        return MARMUR_SPACIOUS_PAGE_FONT_SCALE
    elseif page == "transactions" or page == "insights" then
        return MARMUR_READABLE_PAGE_FONT_SCALE
    elseif page == "deposit" or page == "services" or page == "disclosures" then
        return MARMUR_DEFAULT_PAGE_FONT_SCALE
    elseif page == "loans" or page == "loanpay" or page == "loanapply" or page == "autoloanpay"
        or page == "loanlockout" or page == "loanpaymentreview" or page == "autoloanpaymentreview"
        or page == "autoloanautopayreview" or page == "confirm" or page == "dispute"
        or page == "disputeconfirm" or page == "closeaccount" or page == "flagnotice" then
        return MARMUR_DENSE_PAGE_FONT_SCALE
    end
    return MARMUR_DEFAULT_PAGE_FONT_SCALE
end

function shell:getSidebarSection()
    local page = tostring(self.activePage or "home")
    if page == "transactions" or page == "dispute" or page == "disputeconfirm" then
        return "activity"
    elseif page == "insights" then
        return "analytics"
    elseif page == "deposit" then
        return "deposit"
    elseif page == "withdraw" then
        return "withdraw"
    elseif page == "loans" or page == "loanpay" or page == "loanapply" or page == "autoloanpay"
        or page == "loanlockout" or page == "loanpaymentreview" or page == "autoloanpaymentreview"
        or page == "autoloanautopayreview" then
        return "loans"
    elseif page == "services" or page == "closeaccount" then
        return "services"
    elseif page == "disclosures" then
        return "disclosures"
    elseif page == "confirm" then
        local mode = tostring(self.confirmMode or "")
        if mode == "deposit" then return "deposit" end
        if mode == "withdraw" then return "withdraw" end
        if mode == "loanapply" or mode == "loanreview" or mode == "loansign" or mode == "loanpay" or mode == "autoloanpay" then
            return "loans"
        end
        if mode == "closeaccount" then return "services" end
    end
    return "home"
end

function shell:buildAuthenticatedSidebar()
    local sidebar = ink.canvas(0, 300, inkEAnchor.TopLeft)
    sidebar:SetSize(Vector2.new({ X = 360, Y = 1030 }))
    sidebar:Reparent(self.contentCanvas, -1)

    local sidebarBg = ink.rect(0, 0, 360, 1030, color.brandPanel or color.panel)
    sidebarBg:SetOpacity(0.88)
    sidebarBg:Reparent(sidebar, -1)

    local divider = ink.rect(358, 0, 2, 1030, color.brandRed or color.red)
    divider:SetOpacity(0.34)
    divider:Reparent(sidebar, -1)

    local active = self:getSidebarSection()
    local navY = 24
    local step = 78
    self:createHomeSidebarItem(sidebar, "Home",        navY + (step * 0), function() self:renderPage("home") end, active == "home")
    self:createHomeSidebarItem(sidebar, "Activity",    navY + (step * 1), function() self:renderPage("transactions") end, active == "activity")
    self:createHomeSidebarItem(sidebar, "Analytics",   navY + (step * 2), function() self:renderPage("insights") end, active == "analytics")
    self:createHomeSidebarItem(sidebar, "Deposit",     navY + (step * 3), function() self:renderPage("deposit") end, active == "deposit")
    self:createHomeSidebarItem(sidebar, "Withdraw",    navY + (step * 4), function() self:renderPage("withdraw") end, active == "withdraw")
    self:createHomeSidebarItem(sidebar, "Loans",       navY + (step * 5), function() self:renderPage("loans") end, active == "loans")
    self:createHomeSidebarItem(sidebar, "Services",    navY + (step * 6), function() self:renderPage("services") end, active == "services")
    self:createHomeSidebarItem(sidebar, "Disclosures", navY + (step * 7), function() self:renderPage("disclosures") end, active == "disclosures")
    self:createHomeSidebarItem(sidebar, "Logout",      navY + (step * 8), function() self:logout() end, false)

    local footerLine = ink.rect(28, 910, 304, 2, color.brandWhite or color.white)
    footerLine:SetOpacity(0.08)
    footerLine:Reparent(sidebar, -1)

    local copyright = ink.text("© 2077 MARMUR BANK\nALL RIGHTS RESERVED.", 38, 938, 23, color.dim)
    copyright:SetWrapping(true)
    copyright:SetSize(Vector2.new({ X = 280, Y = 72 }))
    copyright:Reparent(sidebar, -1)
end

function shell:buildFrame()
    local W, H = 2960, 1180
    local bg = ink.rect(0, 150, W, H, color.brandBlack or color.panel)
    bg:SetOpacity(0.995)
    bg:Reparent(self.contentCanvas, -1)

    for i = 0, 10 do
        local line = ink.rect(0, 150 + (i * 112), W, 1, color.brandWhite or color.white)
        line:SetOpacity(0.022)
        line:Reparent(self.contentCanvas, -1)
    end

    local header = ink.rect(0, 150, W, 150, color.brandPanel or color.panel)
    header:SetOpacity(0.92)
    header:Reparent(self.contentCanvas, -1)

    local headerTop = ink.rect(0, 150, W, 3, color.brandRed or color.red)
    headerTop:SetOpacity(0.78)
    headerTop:Reparent(self.contentCanvas, -1)

    local headerBottom = ink.rect(0, 298, W, 2, color.brandWhite or color.white)
    headerBottom:SetOpacity(0.12)
    headerBottom:Reparent(self.contentCanvas, -1)

    local logoMark = ink.text("◇", 48, 164, 96, color.brandRedBright or color.red)
    logoMark:SetSize(Vector2.new({ X = 100, Y = 112 }))
    logoMark:Reparent(self.contentCanvas, -1)

    local brand = ink.text("MARMUR BANK", 146, 166, 74, color.brandWhite or color.white)
    brand:SetSize(Vector2.new({ X = 760, Y = 88 }))
    brand:Reparent(self.contentCanvas, -1)

    local slogan = ink.text("Trusted Banking. Always Secured.", 150, 248, 31, color.dim)
    slogan:SetSize(Vector2.new({ X = 740, Y = 42 }))
    slogan:Reparent(self.contentCanvas, -1)

    local address = ink.text(self:getPageAddress(), 930, 190, 38, color.brandRedBright or color.red)
    address:SetSize(Vector2.new({ X = 1120, Y = 50 }))
    address:Reparent(self.contentCanvas, -1)

    local addressLine = ink.rect(900, 258, 1050, 2, color.brandRed or color.red)
    addressLine:SetOpacity(0.28)
    addressLine:Reparent(self.contentCanvas, -1)

    local powered = ink.text("POWERED BY NETWATCH", 2800, 186, 30, color.dim)
    powered:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    powered:SetSize(Vector2.new({ X = 540, Y = 46 }))
    powered:Reparent(self.contentCanvas, -1)

    local dateTime = ink.text(Calendar.formatCurrentDateTime(Calendar.getContext(), true), 2800, 234, 34, color.brandWhiteSoft or color.white)
    dateTime:SetAnchorPoint(Vector2.new({ X = 1.0, Y = 0.0 }))
    dateTime:SetSize(Vector2.new({ X = 800, Y = 48 }))
    dateTime:Reparent(self.contentCanvas, -1)

    self:buildAuthenticatedSidebar()
end

function shell:activateSidebarContentLane()
    if self._marmurSidebarLaneActive == true then return end
    local frameCanvas = self.contentCanvas
    if not frameCanvas then return end

    local lane = ink.canvas(MARMUR_PAGE_LANE_X, MARMUR_PAGE_LANE_Y, inkEAnchor.TopLeft)
    lane:SetSize(Vector2.new({ X = 2960, Y = 1450 }))
    pcall(function()
        lane:SetRenderTransformPivot(Vector2.new({ X = 0.0, Y = 0.0 }))
    end)
    pcall(function()
        lane:SetScale(Vector2.new({ X = MARMUR_PAGE_LANE_SCALE_X, Y = MARMUR_PAGE_LANE_SCALE_Y }))
    end)
    lane:Reparent(frameCanvas, -1)

    self._marmurFrameCanvas = frameCanvas
    self.contentCanvas = lane
    self._marmurSidebarLaneActive = true
    if ink.setFontScale then ink.setFontScale(self:getAuthenticatedPageFontScale()) end
end

function shell:buildNavbar()
    self:activateSidebarContentLane()
end

local _marmurSidebarOriginalBuildFlagNoticePage = shell.buildFlagNoticePage
function shell:buildFlagNoticePage()
    self:activateSidebarContentLane()
    return _marmurSidebarOriginalBuildFlagNoticePage(self)
end

local _marmurSidebarOriginalBuildLoanLockoutPage = shell.buildLoanLockoutPage
function shell:buildLoanLockoutPage()
    self:activateSidebarContentLane()
    return _marmurSidebarOriginalBuildLoanLockoutPage(self)
end

local _marmurSidebarOriginalBuildLoanPaymentReviewPage = shell.buildLoanPaymentReviewPage
function shell:buildLoanPaymentReviewPage()
    self:activateSidebarContentLane()
    return _marmurSidebarOriginalBuildLoanPaymentReviewPage(self)
end

local _marmurSidebarOriginalBuildAutoLoanPaymentReviewPage = shell.buildAutoLoanPaymentReviewPage
function shell:buildAutoLoanPaymentReviewPage()
    self:activateSidebarContentLane()
    return _marmurSidebarOriginalBuildAutoLoanPaymentReviewPage(self)
end

local _marmurSidebarOriginalBuildAutoLoanAutoPayReviewPage = shell.buildAutoLoanAutoPayReviewPage
function shell:buildAutoLoanAutoPayReviewPage()
    self:activateSidebarContentLane()
    return _marmurSidebarOriginalBuildAutoLoanAutoPayReviewPage(self)
end

local _marmurSidebarOriginalRenderPage = shell.renderPage
function shell:renderPage(page)
    local requestedPage = tostring(page or self.activePage or "")
    if requestedPage == "autodeposit" then
        requestedPage = "deposit"
    end
    local previousPage = tostring(self.activePage or "")
    if requestedPage == "deposit" and previousPage ~= "deposit" then
        self.depositKeypadTarget = "deposit"
    end
    self._marmurSidebarLaneActive = false
    self._marmurFrameCanvas = nil
    if ink.setFontScale then ink.setFontScale(MARMUR_BASE_FONT_SCALE) end
    return _marmurSidebarOriginalRenderPage(self, requestedPage)
end


local function marmurAlign(widget, horizontal, vertical)
    if horizontal then
        pcall(function() widget:SetHorizontalAlignment(horizontal) end)
    end
    if vertical then
        pcall(function() widget:SetVerticalAlignment(vertical) end)
    end
    return widget
end

local function marmurText(parent, value, x, y, width, height, fontSize, tint, horizontal, vertical, wrapping, fontStyle)
    local widget = ink.text(tostring(value or ""), x, y, fontSize, tint or color.white, nil, fontStyle)
    widget:SetSize(Vector2.new({ X = width, Y = height }))
    if wrapping == true then widget:SetWrapping(true) end
    marmurAlign(widget, horizontal or textHorizontalAlignment.Left, vertical or textVerticalAlignment.Center)
    widget:Reparent(parent, -1)
    return widget
end

local function marmurCenteredText(parent, value, x, y, width, height, fontSize, tint, wrapping, fontStyle)
    return marmurText(parent, value, x, y, width, height, fontSize, tint,
        textHorizontalAlignment.Center, textVerticalAlignment.Center, wrapping, fontStyle)
end

local function marmurRightText(parent, value, x, y, width, height, fontSize, tint, wrapping, fontStyle)
    return marmurText(parent, value, x, y, width, height, fontSize, tint,
        textHorizontalAlignment.Right, textVerticalAlignment.Center, wrapping, fontStyle)
end

function shell:createButton(parent, label, x, y, w, h, callback, opts)
    opts = opts or {}
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local baseColor = opts.textColor or opts.fgColor or color.white
    local hoverColor = opts.hoverColor or color.brandRedBright or color.red
    local activeColor = opts.activeColor or opts.fgColor or color.brandRedBright or color.red
    local active = opts.active == true
    local disabled = callback == nil
    local labelColor = disabled and (opts.textColor or color.dim) or (active and activeColor or baseColor)

    local text = marmurCenteredText(holder, label, 12, 4, math.max(w - 24, 20), math.max(h - 14, 20), opts.fontSize or 40, labelColor, true)

    local underlineW = math.max(math.floor(w * 0.34), 72)
    if underlineW > w - 28 then underlineW = w - 28 end
    local underline = ink.rect((w - underlineW) / 2, h - 8, underlineW, 3, active and activeColor or hoverColor)
    underline:SetOpacity(active and 0.84 or 0.0)
    underline:Reparent(holder, -1)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if callback and not disabled then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                text:SetTintColor(hoverColor)
                underline:SetTintColor(hoverColor)
                underline:SetOpacity(0.92)
            end,
            hoverOut = function()
                text:SetTintColor(active and activeColor or baseColor)
                underline:SetTintColor(active and activeColor or hoverColor)
                underline:SetOpacity(active and 0.84 or 0.0)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    else
        text:SetTintColor(color.dim)
        underline:SetOpacity(0.0)
    end

    return holder
end

function shell:createTransferKey(parent, label, x, y, w, h, callback, opts)
    opts = opts or {}
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local borderColor = opts.borderColor or color.dim
    local fillColor = opts.fillColor or color.brandPanel2
    local textColor = opts.textColor or color.brandWhite
    local hoverColor = opts.hoverColor or color.brandRedBright

    local border = ink.rect(0, 0, w, h, borderColor)
    border:SetOpacity(opts.borderOpacity or 0.36)
    border:Reparent(holder, -1)

    local fill = ink.rect(2, 2, math.max(w - 4, 2), math.max(h - 4, 2), fillColor)
    fill:SetOpacity(opts.fillOpacity or 0.90)
    fill:Reparent(holder, -1)

    local textWidget = marmurCenteredText(holder, label, 10, 5, math.max(w - 20, 20), math.max(h - 10, 20), opts.fontSize or 34, textColor, true)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if callback then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(hoverColor)
                border:SetOpacity(0.88)
                fill:SetTintColor(color.brandPanel3 or color.panel2)
                textWidget:SetTintColor(hoverColor)
            end,
            hoverOut = function()
                border:SetTintColor(borderColor)
                border:SetOpacity(opts.borderOpacity or 0.36)
                fill:SetTintColor(fillColor)
                textWidget:SetTintColor(textColor)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    elseif opts.static ~= true then
        border:SetOpacity(0.16)
        fill:SetOpacity(0.42)
        textWidget:SetTintColor(color.dim)
    end

    return holder
end

function shell:createTransferAction(parent, label, x, y, w, h, callback, enabled)
    local isEnabled = enabled == true and callback ~= nil
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local outerColor = isEnabled and (color.brandRedBright or color.red) or color.dim
    local fillColor = isEnabled and (color.brandRed or color.red) or (color.brandPanel2 or color.panel2)
    local textColor = isEnabled and (color.brandWhite or color.white) or color.dim

    local border = ink.rect(0, 0, w, h, outerColor)
    border:SetOpacity(isEnabled and 0.78 or 0.18)
    border:Reparent(holder, -1)

    local fill = ink.rect(3, 3, math.max(w - 6, 2), math.max(h - 6, 2), fillColor)
    fill:SetOpacity(isEnabled and 0.72 or 0.36)
    fill:Reparent(holder, -1)

    local textWidget = marmurCenteredText(holder, label, 12, 6, math.max(w - 24, 20), math.max(h - 12, 20), 35, textColor, true)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if isEnabled then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(color.brandWhite or color.white)
                border:SetOpacity(0.92)
                fill:SetTintColor(color.brandRedBright or color.red)
                fill:SetOpacity(0.86)
            end,
            hoverOut = function()
                border:SetTintColor(outerColor)
                border:SetOpacity(0.78)
                fill:SetTintColor(fillColor)
                fill:SetOpacity(0.72)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    end

    return holder
end

function shell:drawHeaderStat(parent, label, value, x, y, valueColor, width, labelFontSize, valueFontSize)
    width = math.floor(tonumber(width) or 420)
    labelFontSize = math.floor(tonumber(labelFontSize) or 26)
    valueFontSize = math.floor(tonumber(valueFontSize) or 38)
    local labelHeight = labelFontSize + 18
    local valueHeight = valueFontSize + 28
    marmurText(parent, label, x, y, width, labelHeight, labelFontSize, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(parent, value, x, y + labelHeight + 1, width, valueHeight, valueFontSize, valueColor or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
end

function shell:drawKV(parent, label, value, x, y, valueColor, width, valueFontSize, labelFontSize)
    width = math.floor(tonumber(width) or 420)
    valueFontSize = math.floor(tonumber(valueFontSize) or 44)
    labelFontSize = math.floor(tonumber(labelFontSize) or 30)
    local labelHeight = labelFontSize + 18
    local valueHeight = valueFontSize + 32
    marmurText(parent, label, x, y, width, labelHeight, labelFontSize, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(parent, value, x, y + labelHeight + 1, width, valueHeight, valueFontSize, valueColor or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
end

function shell:drawPolishedRow(parent, label, value, y, opts)
    opts = opts or {}
    local x = math.floor(tonumber(opts.x) or 28)
    local width = math.floor(tonumber(opts.width) or 1000)
    local labelWidth = math.floor(tonumber(opts.labelWidth) or math.min(520, width * 0.46))
    local rowHeight = math.floor(tonumber(opts.rowHeight) or 58)
    local labelFont = math.floor(tonumber(opts.labelFontSize) or 25)
    local valueFont = math.floor(tonumber(opts.valueFontSize) or 29)

    marmurText(parent, label, x, y, labelWidth, rowHeight - 6, labelFont, opts.labelColor or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    local valueWidth = math.max(width - labelWidth - 24, 260)
    marmurText(parent, value, x + labelWidth + 24, y, valueWidth, rowHeight - 6, valueFont, opts.valueColor or color.white,
        textHorizontalAlignment.Right, textVerticalAlignment.Center, true)

    if opts.drawLine ~= false then
        local divider = ink.rect(x, y + rowHeight - 3, width, 1, color.brandWhite or color.white)
        divider:SetOpacity(tonumber(opts.lineOpacity) or 0.10)
        divider:Reparent(parent, -1)
    end
end

function shell:drawTransferReviewRow(parent, label, value, y, valueColor, drawLine)
    local rowHeight = 64
    marmurText(parent, label, 30, y, 540, rowHeight - 4, 28, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    marmurText(parent, value, 590, y, 698, rowHeight - 4, 32, valueColor or color.white,
        textHorizontalAlignment.Right, textVerticalAlignment.Center, true)
    if drawLine ~= false then
        local line = ink.rect(30, y + rowHeight - 2, 1258, 1, color.brandWhite or color.white)
        line:SetOpacity(0.09)
        line:Reparent(parent, -1)
    end
end

function shell:drawCompactTransferReviewRow(parent, label, value, y, valueColor, drawLine)
    local rowHeight = 52
    marmurText(parent, label, 24, y, 560, rowHeight - 4, 24, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    marmurText(parent, value, 600, y, 710, rowHeight - 4, 28, valueColor or color.white,
        textHorizontalAlignment.Right, textVerticalAlignment.Center, true)
    if drawLine ~= false then
        local line = ink.rect(24, y + rowHeight - 2, 1286, 1, color.brandWhite or color.white)
        line:SetOpacity(0.09)
        line:Reparent(parent, -1)
    end
end

function shell:createHomeSidebarItem(parent, labelText, y, callback, active)
    local w = 338
    local homeLayout = tostring(self.activePage or "") == "home"
    local h = homeLayout and 68 or 72
    local holder = ink.canvas(10, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local fill = ink.image(w / 2, h / 2, w, h, ATLAS, "cell_bg", color.brandRed or color.red)
    fill.image.useNineSliceScale = true
    fill.image:SetOpacity(active and 0.30 or 0.02)
    fill.pos:Reparent(holder, -1)

    local accent = ink.rect(0, 0, active and 6 or 2, h, color.brandRedBright or color.red)
    accent:SetOpacity(active and 0.95 or 0.18)
    accent:Reparent(holder, -1)

    local marker = ink.rect(34, (h - 12) / 2, 12, 12, active and (color.brandWhite or color.white) or (color.brandRed or color.red))
    marker:SetOpacity(active and 0.95 or 0.54)
    marker:Reparent(holder, -1)

    local text = marmurText(holder, labelText, 68, 0, 250, h, homeLayout and 39 or 42,
        active and (color.brandWhite or color.white) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)
    self:addSubscriber(hotspot, {
        hoverIn = function()
            fill.image:SetOpacity(active and 0.36 or 0.16)
            accent:SetOpacity(0.95)
            marker:SetTintColor(color.brandWhite or color.white)
            text:SetTintColor(color.brandWhite or color.white)
        end,
        hoverOut = function()
            fill.image:SetOpacity(active and 0.30 or 0.02)
            accent:SetOpacity(active and 0.95 or 0.18)
            marker:SetTintColor(active and (color.brandWhite or color.white) or (color.brandRed or color.red))
            text:SetTintColor(active and (color.brandWhite or color.white) or color.dim)
        end,
        click = function()
            utils.playSound("ui_menu_onpress", 1)
            callback()
        end,
    })
    return holder
end

local _marmurV216OriginalGetTransferSourceAmount = shell.getTransferSourceAmount
function shell:getTransferSourceAmount(mode, data)
    if mode == "loanrequest" then
        local snapshot = data or self:getBankData()
        local maxAmount = 0
        pcall(function() maxAmount = Bank:getLoanMaxForStreetCred(snapshot.streetCred or 0) or 0 end)
        local absoluteMax = 100000000
        pcall(function() absoluteMax = Bank:getManualLoanMaxPrincipal() or absoluteMax end)
        if maxAmount <= 0 then maxAmount = absoluteMax end
        return math.max(0, math.min(math.floor(tonumber(maxAmount) or 0), math.floor(tonumber(absoluteMax) or 100000000)))
    end
    return _marmurV216OriginalGetTransferSourceAmount(self, mode, data)
end

function shell:createHeaderPartnerButton(parent, x, y, w, h)
    local teaserOpen = tostring(self.activePage or "") == "anodosteaser"
    local label = teaserOpen and "RETURN TO MARMUR" or "GO TO ANODOS"
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local border = ink.rect(0, 0, w, h, color.brandRedBright or color.red)
    border:SetOpacity(0.54)
    border:Reparent(holder, -1)
    local fill = ink.rect(2, 2, w - 4, h - 4, color.brandPanel2 or color.panel2)
    fill:SetOpacity(0.72)
    fill:Reparent(holder, -1)
    local text = marmurCenteredText(holder, label, 10, 5, w - 20, h - 10, 29, color.brandRedBright or color.red, true, "Medium")

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)
    self:addSubscriber(hotspot, {
        hoverIn = function()
            border:SetTintColor(color.brandWhite or color.white)
            border:SetOpacity(0.92)
            fill:SetOpacity(0.90)
            text:SetTintColor(color.brandWhite or color.white)
        end,
        hoverOut = function()
            border:SetTintColor(color.brandRedBright or color.red)
            border:SetOpacity(0.54)
            fill:SetOpacity(0.72)
            text:SetTintColor(color.brandRedBright or color.red)
        end,
        click = function()
            utils.playSound("ui_menu_onpress", 1)
            if teaserOpen then
                self:renderPage("home")
            else
                self:openAnodosPartnerPortal()
            end
        end,
    })
    return holder
end

function shell:activateSidebarContentLane()
    if self._marmurSidebarLaneActive == true then return end
    local frameCanvas = self.contentCanvas
    if not frameCanvas then return end

    local lane = ink.canvas(360, -160, inkEAnchor.TopLeft)
    lane:SetSize(Vector2.new({ X = 2960, Y = 1490 }))
    pcall(function() lane:SetRenderTransformPivot(Vector2.new({ X = 0.0, Y = 0.0 })) end)
    pcall(function() lane:SetScale(Vector2.new({ X = 0.90, Y = 1.00 })) end)
    lane:Reparent(frameCanvas, -1)

    self._marmurFrameCanvas = frameCanvas
    self.contentCanvas = lane
    self._marmurSidebarLaneActive = true
    if ink.setFontScale then ink.setFontScale(self:getAuthenticatedPageFontScale()) end
end

function shell:buildFrame()
    local W, H = 2960, 1180
    local bg = ink.rect(0, 150, W, H, color.brandBlack or color.panel)
    bg:SetOpacity(0.995)
    bg:Reparent(self.contentCanvas, -1)

    for i = 0, 10 do
        local line = ink.rect(0, 150 + (i * 112), W, 1, color.brandWhite or color.white)
        line:SetOpacity(0.022)
        line:Reparent(self.contentCanvas, -1)
    end

    local header = ink.rect(0, 150, W, 150, color.brandPanel or color.panel)
    header:SetOpacity(0.92)
    header:Reparent(self.contentCanvas, -1)
    local headerTop = ink.rect(0, 150, W, 3, color.brandRed or color.red)
    headerTop:SetOpacity(0.78)
    headerTop:Reparent(self.contentCanvas, -1)
    local headerBottom = ink.rect(0, 298, W, 2, color.brandWhite or color.white)
    headerBottom:SetOpacity(0.12)
    headerBottom:Reparent(self.contentCanvas, -1)

    marmurCenteredText(self.contentCanvas, "◇", 40, 160, 100, 118, 96, color.brandRedBright or color.red)
    marmurText(self.contentCanvas, "MARMUR BANK", 146, 158, 720, 92, 74, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(self.contentCanvas, "Trusted Banking. Always Secured.", 150, 242, 700, 45, 31, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)

    marmurText(self.contentCanvas, self:getPageAddress(), 900, 174, 870, 70, 38, color.brandRedBright or color.red,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    local addressLine = ink.rect(900, 258, 850, 2, color.brandRed or color.red)
    addressLine:SetOpacity(0.28)
    addressLine:Reparent(self.contentCanvas, -1)

    marmurRightText(self.contentCanvas, "POWERED BY NETWATCH", 2290, 174, 510, 48, 29, color.dim, false)
    marmurRightText(self.contentCanvas, Calendar.formatCurrentDateTime(Calendar.getContext(), true), 2260, 222, 540, 54, 33,
        color.brandWhiteSoft or color.white, false)

    self:buildAuthenticatedSidebar()
end

local _marmurV216OriginalGetPageAddress = shell.getPageAddress
function shell:getPageAddress()
    if tostring(self.activePage or "") == "anodosteaser" then
        return "NETDIR://ANODOS.FINANCIAL/MAINTENANCE"
    end
    return _marmurV216OriginalGetPageAddress(self)
end

local ANODOS_MAINTENANCE_MESSAGE = "Anodos Financial is currently undergoing maintenance.\nPlease check back later."
local ANODOS_ENTRY_PAGE = "Overview"

local function marmurFindAnodosMod()
    local globalApi = nil
    if type(_G) == "table" then
        local ok, api = pcall(rawget, _G, "ANODOS_FINANCIAL_API")
        if ok then globalApi = api end
    end
    if type(globalApi) == "table" then
        local available = true
        if type(globalApi.isAvailable) == "function" then
            local ok, result = pcall(globalApi.isAvailable)
            available = ok and result == true
        end
        if available then return globalApi, "api" end
        return nil
    end
    if type(GetMod) ~= "function" then return nil end

    for _, modName in ipairs({ "ANODOSFinancial", "anodos_financial", "anodosfinancial" }) do
        local ok, mod = pcall(GetMod, modName)
        if ok and mod ~= nil then return mod, "mod" end
    end
    return nil
end

function shell:openAnodosPartnerPortal()
    local partner, partnerKind = marmurFindAnodosMod()
    if partner ~= nil then
        local okMethod, openPortal = pcall(function() return partner.openPortal end)
        if okMethod and type(openPortal) == "function" then
            local ok, result
            if partnerKind == "api" then
                ok, result = pcall(openPortal, ANODOS_ENTRY_PAGE)
            else
                ok, result = pcall(openPortal, partner, ANODOS_ENTRY_PAGE)
            end
            if ok and result ~= false then return true end
        end

        for _, methodName in ipairs({
            "openFromMarmur", "OpenFromMarmur",
            "openBrowserPortal", "OpenBrowserPortal",
        }) do
            local okLegacyMethod, method = pcall(function() return partner[methodName] end)
            if okLegacyMethod and type(method) == "function" then
                local ok, result
                if partnerKind == "api" then
                    ok, result = pcall(method, ANODOS_ENTRY_PAGE)
                else
                    ok, result = pcall(method, partner, ANODOS_ENTRY_PAGE)
                end
                if ok and result ~= false then return true end
            end
        end

        local menuName = nil
        pcall(function()
            local published = partner.browserMenuName or partner.widgetName or partner.menuName
            if published ~= nil and tostring(published) ~= "" then menuName = tostring(published) end
        end)
        if menuName ~= nil then
            local okTab, browserTab = pcall(require, "module/BrowserTab")
            local controller = okTab and browserTab and browserTab.lastComputerController or nil
            if controller ~= nil then
                local ok, result = pcall(function() return controller:ShowMenuByName(menuName) end)
                if ok and result ~= false then return true end
            end
        end
    end

    if self.isLoggedIn == true then
        self:renderAnodosTeaserPage()
    else
        self:renderPage("login")
    end
    return false
end

function shell:buildAnodosTeaserPage()
    local hero = self:makePanel(self.contentCanvas, 80, 470, 2800, 970)

    marmurCenteredText(hero, "ANODOS FINANCIAL", 140, 92, 2520, 126, 82,
        color.brandRedBright or color.red, false, "Medium")
    marmurCenteredText(hero, "PRIVATE WEALTH MANAGEMENT", 140, 224, 2520, 64, 38,
        color.brandWhite or color.white, false)
    marmurCenteredText(hero, "A MARMUR BANK PARTNER", 140, 294, 2520, 54, 30,
        color.dim, false)

    local rule = ink.rect(520, 382, 1760, 3, color.brandRed or color.red)
    rule:SetOpacity(0.56)
    rule:Reparent(hero, -1)

    local status = self:makePanel(hero, 360, 442, 2080, 286)
    marmurCenteredText(status, "PARTNER PORTAL OFFLINE", 50, 28, 1980, 62, 31,
        color.brandRedBright or color.red, false, "Medium")
    marmurCenteredText(status, ANODOS_MAINTENANCE_MESSAGE, 90, 104, 1900, 142, 42,
        color.brandWhiteSoft or color.white, true, "Medium")

    self:createTransferAction(hero, "RETURN TO MARMUR BANK", 820, 792, 1160, 104,
        function() self:renderPage("home") end, true)
end

function shell:renderAnodosTeaserPage()
    for _, sub in ipairs(self.localSubscribers or {}) do relay.removeSubscriber(sub) end
    self.localSubscribers = {}
    self:clearLoginTimers()
    self:clearLoanSignatureTimer()
    self:clearAccountSignatureTimer()
    self:clearInsightsRefreshTimer()
    self:clearHomeGraphTimer()
    pcall(function() self.browserController.currentPage:RemoveAllChildren() end)
    self.activePage = "anodosteaser"
    self._marmurSidebarLaneActive = false
    self._marmurFrameCanvas = nil
    if ink.setFontScale then ink.setFontScale(MARMUR_BASE_FONT_SCALE) end
    self.contentCanvas = ink.canvas(self:getContentOriginX(), self:getContentOriginY(), inkEAnchor.TopLeft)
    self.contentCanvas:Reparent(self.browserController.currentPage, -1)
    self:buildFrame()
    self:activateSidebarContentLane()
    self:buildAnodosTeaserPage()
    self:applyAddressBar()
end

local _marmurV216OriginalRenderPage = shell.renderPage
function shell:renderPage(page)
    if tostring(page or "") == "anodosteaser" then
        if self.isLoggedIn == true then
            self:renderAnodosTeaserPage()
        else
            _marmurV216OriginalRenderPage(self, "login")
        end
        return
    end
    return _marmurV216OriginalRenderPage(self, page)
end

function shell:buildInlineDepositPage()
    local data = self:getBankData()
    local accent = color.brandRedBright or color.gold
    local auto = nil
    pcall(function() auto = Bank:getAutoDepositSettings() end)
    auto = auto or { active = false, amount = 0, intervalDays = 7, frequencyLabel = "Every 7 days", nextLabel = "Not scheduled", nextStamp = 0 }

    if self.autoDepositIntervalDirty ~= true then
        local savedDays = auto.active == true and math.floor(tonumber(auto.intervalDays) or 7) or 7
        if savedDays < 1 then savedDays = 1 end
        if savedDays > 30 then savedDays = 30 end
        self.autoDepositIntervalDays = savedDays
    end

    local target = self:getDepositKeypadTarget()
    local amountMode = target == "autodeposit" and "autodeposit" or "deposit"
    local sourceAmount = math.max(math.floor(tonumber(data.wallet) or 0), 0)
    local savingsAmount = math.max(math.floor(tonumber(data.bank) or 0), 0)
    local depositAmount = self:getCustomAmount("deposit")
    local scheduledAmount = self:getInlineAutoDepositAmount(auto)
    local activeAmount = amountMode == "autodeposit" and scheduledAmount or depositAmount
    local activeError = self:getTransferError(amountMode)
    local autoError = self:getTransferError("autodeposit")
    local exceedsFunds = amountMode == "deposit" and activeAmount > sourceAmount
    local validDeposit = depositAmount > 0 and depositAmount <= sourceAmount
    local selectedDays = self:getAutoDepositIntervalDays()
    local previewStamp = self:getInlineAutoDepositNextStamp(auto, selectedDays)
    local nextDebitText = previewStamp > 0 and Calendar.formatMinuteStamp(previewStamp, Calendar.getContext(), true) or "After schedule is saved"

    local strip = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(strip, "DEPOSIT FUNDS", 40, 10, 1450, 70, 50, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(strip, "Move funds from Checking into Marmur Bank Savings, or schedule the transfer to repeat automatically.",
        42, 82, 1450, 70, 27, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(strip, "Checking / Wallet", "E$ " .. utils.formatNumber(sourceAmount), 1600, 28, color.white, 540, 24, 36)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(savingsAmount), 2190, 28, accent, 540, 24, 36)

    local left = self:makePanel(self.contentCanvas, 80, 660, 1340, 610)
    local right = self:makePanel(self.contentCanvas, 1460, 660, 1420, 610)

    marmurText(left, "1. DEPOSIT SETUP", 40, 10, 1240, 58, 40, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    local leftNoteText = amountMode == "autodeposit"
        and "The keypad is editing the scheduled amount. Your one-time deposit remains unchanged."
        or "The keypad is editing the one-time deposit. Your scheduled amount remains unchanged."
    local leftNoteColor = color.dim
    if #activeError > 0 then
        leftNoteText = activeError
        leftNoteColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        leftNoteText = "The one-time deposit exceeds the available Checking balance."
        leftNoteColor = color.brandRedBright or color.red
    end
    marmurText(left, leftNoteText, 42, 68, 1240, 60, 23, leftNoteColor,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local function amountField(label, value, x, mode, selected, valueColor)
        local w, h = 610, 116
        local holder = ink.canvas(x, 138, inkEAnchor.TopLeft)
        holder:SetSize(Vector2.new({ X = w, Y = h }))
        holder:Reparent(left, -1)
        local border = ink.rect(0, 0, w, h, selected and (color.brandRedBright or color.red) or color.dim)
        border:SetOpacity(selected and 0.86 or 0.34)
        border:Reparent(holder, -1)
        local fill = ink.rect(2, 2, w - 4, h - 4, color.brandPanel2 or color.panel2)
        fill:SetOpacity(selected and 0.82 or 0.54)
        fill:Reparent(holder, -1)
        marmurCenteredText(holder, label, 20, 8, w - 40, 38, 21,
            selected and (color.brandWhite or color.white) or color.dim, false)
        local valueFont = #tostring(value) >= 18 and 36 or 43
        marmurCenteredText(holder, value, 20, 43, w - 40, 67, valueFont, valueColor, true, "Medium")
        local hotspot = ink.rect(0, 0, w, h, color.white)
        hotspot:SetOpacity(0.01)
        hotspot:Reparent(holder, -1)
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(color.brandWhite or color.white)
                border:SetOpacity(0.90)
                fill:SetOpacity(0.88)
            end,
            hoverOut = function()
                border:SetTintColor(selected and (color.brandRedBright or color.red) or color.dim)
                border:SetOpacity(selected and 0.86 or 0.34)
                fill:SetOpacity(selected and 0.82 or 0.54)
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                self:selectDepositKeypadTarget(mode)
            end,
        })
    end

    local depositDisplayColor = depositAmount > sourceAmount and (color.brandRedBright or color.red) or (amountMode == "deposit" and accent or color.white)
    amountField("ONE-TIME DEPOSIT", "E$ " .. utils.formatNumber(depositAmount), 40, "deposit", amountMode == "deposit", depositDisplayColor)
    amountField("SCHEDULED AUTO-DEPOSIT", "E$ " .. utils.formatNumber(scheduledAmount), 690, "autodeposit", amountMode == "autodeposit", amountMode == "autodeposit" and accent or color.white)

    marmurText(left, "NUMERIC KEYPAD  •  " .. (amountMode == "autodeposit" and "SCHEDULED AMOUNT" or "ONE-TIME AMOUNT"),
        40, 262, 1240, 40, 25, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    self:buildAmountKeypad(left, amountMode, accent, {
        y = 310,
        keyH = 60,
        gapY = 8,
        numberFontSize = 31,
        controlFontSize = 25,
        fillOpacity = 0.78,
    })

    marmurText(right, amountMode == "autodeposit" and "2. SCHEDULE REVIEW" or "2. REVIEW & CONFIRM",
        40, 10, 1320, 58, 40, color.cyan, textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(right, amountMode == "autodeposit"
        and "Review the recurring transfer, then save it in the Auto-Deposit section below."
        or "Review the one-time transfer before it posts.",
        42, 68, 1300, 60, 24, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local review = self:makePanel(right, 40, 138, 1340, 324)
    if amountMode == "autodeposit" then
        self:drawCompactTransferReviewRow(review, "From", "Checking", 4, color.white, true)
        self:drawCompactTransferReviewRow(review, "To", "Savings", 56, accent, true)
        self:drawCompactTransferReviewRow(review, "Scheduled Amount", "E$ " .. utils.formatNumber(scheduledAmount), 108, accent, true)
        self:drawCompactTransferReviewRow(review, "Frequency", self:getAutoDepositPresetLabel(selectedDays), 160, color.white, true)
        self:drawCompactTransferReviewRow(review, "Next Debit", nextDebitText, 212, color.white, true)
        self:drawCompactTransferReviewRow(review, "Current Status", auto.active == true and "ACTIVE" or "NOT SCHEDULED", 264, auto.active == true and color.white or color.dim, false)
    else
        local checkingAfter = sourceAmount - depositAmount
        local savingsAfter = savingsAmount + depositAmount
        self:drawCompactTransferReviewRow(review, "From", "Checking", 4, color.white, true)
        self:drawCompactTransferReviewRow(review, "To", "Savings", 56, accent, true)
        self:drawCompactTransferReviewRow(review, "Deposit Amount", "E$ " .. utils.formatNumber(depositAmount), 108, depositDisplayColor, true)
        self:drawCompactTransferReviewRow(review, "Transfer Fee", "E$ 0", 160, color.white, true)
        self:drawCompactTransferReviewRow(review, "New Checking Balance", "E$ " .. utils.formatNumber(checkingAfter), 212, checkingAfter < 0 and (color.brandRedBright or color.red) or color.white, true)
        self:drawCompactTransferReviewRow(review, "New Savings Balance", "E$ " .. utils.formatNumber(savingsAfter), 264, accent, false)
    end

    local statusPanel = self:makePanel(right, 40, 476, 1340, 56)
    local statusText = amountMode == "autodeposit"
        and "Enter the recurring amount, choose a frequency below, then save the schedule."
        or "Enter an amount to enable confirmation."
    local statusColor = color.dim
    if #activeError > 0 then
        statusText = activeError
        statusColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        statusText = "Amount exceeds available Checking funds."
        statusColor = color.brandRedBright or color.red
    elseif amountMode == "autodeposit" and scheduledAmount > 0 then
        statusText = "Scheduled amount ready. Confirm the frequency in Section 3."
        statusColor = color.white
    elseif validDeposit then
        statusText = "Ready to post immediately to the Activity ledger."
        statusColor = color.white
    end
    marmurText(statusPanel, statusText, 18, 3, 1304, 50, 23, statusColor,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    if amountMode == "autodeposit" then
        self:createTransferKey(right, "RETURN TO ONE-TIME DEPOSIT", 40, 544, 1340, 58, function()
            self:selectDepositKeypadTarget("deposit")
        end, {
            borderColor = color.brandRed or color.red,
            textColor = color.brandRedBright or color.red,
            hoverColor = color.brandWhite or color.white,
            fontSize = 27,
            fillOpacity = 0.50,
        })
    else
        local confirmCallback = validDeposit and function() self:submitCustomAmount("deposit", data) end or nil
        self:createTransferAction(right, "CONFIRM DEPOSIT", 40, 544, 1340, 58, confirmCallback, validDeposit)
    end

    local schedule = self:makePanel(self.contentCanvas, 80, 1290, 2800, 200)
    marmurText(schedule, "3. SCHEDULED AUTO-DEPOSIT", 30, 4, 1200, 52, 34, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(schedule, "Automatically move the selected amount from Checking to Savings on a recurring schedule.",
        32, 52, 1480, 38, 22, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local scheduleStatusText = auto.active == true
        and ("ACTIVE  •  " .. self:getAutoDepositPresetLabel(auto.intervalDays) .. "  •  E$ " .. utils.formatNumber(auto.amount or 0))
        or "NOT SCHEDULED"
    marmurRightText(schedule, scheduleStatusText, 1780, 8, 990, 38, 25, auto.active == true and color.white or color.dim, true)
    if #autoError > 0 then
        marmurRightText(schedule, autoError, 1780, 44, 990, 36, 21, color.brandRedBright or color.red, true)
    elseif auto.active == true then
        local nextCurrent = tostring(auto.nextLabel or "Scheduled")
        local savedStamp = math.floor(tonumber(auto.nextStamp) or 0)
        if savedStamp > 0 then nextCurrent = Calendar.formatMinuteStamp(savedStamp, Calendar.getContext(), true) end
        marmurRightText(schedule, "Next debit: " .. nextCurrent, 1780, 44, 990, 36, 21, color.dim, true)
    end

    local fieldY = 122
    local labelY = 88
    local function fieldLabel(textValue, x, w)
        marmurCenteredText(schedule, textValue, x, labelY, w, 30, 20, color.dim, false)
    end

    fieldLabel("SOURCE", 30, 260)
    self:createTransferKey(schedule, "Checking", 30, fieldY, 260, 62, nil, { static = true, fontSize = 25, fillOpacity = 0.52 })
    fieldLabel("DESTINATION", 310, 260)
    self:createTransferKey(schedule, "Savings", 310, fieldY, 260, 62, nil, { static = true, fontSize = 25, fillOpacity = 0.52 })

    fieldLabel("FREQUENCY", 590, 530)
    local function frequencyButton(label, days, x)
        local selected = selectedDays == days
        self:createTransferKey(schedule, label, x, fieldY, 170, 62, function() self:selectInlineAutoDepositFrequency(days) end, {
            borderColor = selected and (color.brandRedBright or color.red) or color.dim,
            textColor = selected and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 23,
            fillOpacity = selected and 0.70 or 0.46,
        })
    end
    frequencyButton("Weekly", 7, 590)
    frequencyButton("Biweekly", 14, 770)
    frequencyButton("Monthly", 30, 950)

    fieldLabel("NEXT DEBIT", 1140, 430)
    self:createTransferKey(schedule, nextDebitText, 1140, fieldY, 430, 62, nil, { static = true, fontSize = 21, fillOpacity = 0.52 })

    local autoSelected = amountMode == "autodeposit"
    fieldLabel("AMOUNT", 1590, 330)
    self:createTransferKey(schedule, "E$ " .. utils.formatNumber(scheduledAmount), 1590, fieldY, 330, 62, function()
        self:selectDepositKeypadTarget("autodeposit")
    end, {
        borderColor = autoSelected and (color.brandRedBright or color.red) or color.dim,
        textColor = autoSelected and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 25,
        fillOpacity = autoSelected and 0.70 or 0.52,
    })

    local saveEnabled = scheduledAmount > 0
    local saveLabel = auto.active == true and "REPLACE SCHEDULE" or "SET UP AUTO-DEPOSIT"
    local saveCallback = saveEnabled and function() self:saveInlineAutoDeposit(scheduledAmount) end or nil
    self:createTransferAction(schedule, saveLabel, 1940, fieldY, 500, 62, saveCallback, saveEnabled)

    self:createTransferKey(schedule, "CANCEL", 2460, fieldY, 310, 62,
        auto.active == true and function() self:cancelInlineAutoDeposit() end or nil, {
            borderColor = color.brandRed or color.red,
            textColor = auto.active == true and (color.brandRedBright or color.red) or color.dim,
            hoverColor = color.brandWhite or color.white,
            fontSize = 23,
            fillOpacity = 0.44,
        })
end

function shell:buildTransferPage(mode)
    if mode == "deposit" then
        self:buildInlineDepositPage()
        return
    end

    local data = self:getBankData()
    local accent = color.brandRedBright or color.gold
    local sourceAmount = math.max(math.floor(tonumber(data.bank) or 0), 0)
    local destinationAmount = math.max(math.floor(tonumber(data.wallet) or 0), 0)
    local amount = self:getCustomAmount("withdraw")
    local customLabel = self:getCustomAmountLabel("withdraw")
    local errorText = self:getTransferError("withdraw")
    local validAmount = amount > 0 and amount <= sourceAmount
    local exceedsFunds = amount > sourceAmount
    local checkingAfter = destinationAmount + amount
    local savingsAfter = sourceAmount - amount

    local strip = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(strip, "WITHDRAW FUNDS", 40, 10, 1300, 70, 50, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(strip, "Move funds from Savings back to Checking.", 42, 82, 1260, 64, 29, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(strip, "Savings Balance", "E$ " .. utils.formatNumber(sourceAmount), 1450, 28, accent, 600, 26, 38)
    self:drawHeaderStat(strip, "Checking Balance", "E$ " .. utils.formatNumber(destinationAmount), 2110, 28, color.white, 600, 26, 38)

    local left = self:makePanel(self.contentCanvas, 80, 660, 1340, 780)
    local right = self:makePanel(self.contentCanvas, 1460, 660, 1420, 780)

    marmurText(left, "TRANSFER SETUP", 44, 12, 1230, 62, 44, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    local leftNoteText = "Use the keypad to enter the exact amount."
    local leftNoteColor = color.dim
    if #errorText > 0 then
        leftNoteText = errorText
        leftNoteColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        leftNoteText = "The entered amount exceeds your available Savings balance."
        leftNoteColor = color.brandRedBright or color.red
    end
    marmurText(left, leftNoteText, 46, 76, 1230, 64, 28, leftNoteColor,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local amountPanel = self:makePanel(left, 40, 150, 1260, 160)
    marmurCenteredText(amountPanel, "EXACT AMOUNT", 30, 10, 730, 44, 27, color.dim, false)
    local amountFontSize = (#customLabel >= 18) and 46 or 60
    local amountColor = exceedsFunds and (color.brandRedBright or color.red) or accent
    marmurCenteredText(amountPanel, customLabel, 30, 48, 730, 100, amountFontSize, amountColor, true, "Medium")
    marmurCenteredText(amountPanel, "AVAILABLE SAVINGS", 800, 12, 430, 42, 24, color.dim, false)
    marmurCenteredText(amountPanel, "E$ " .. utils.formatNumber(sourceAmount), 800, 54, 430, 82, 34, color.white, true)

    marmurText(left, "NUMERIC KEYPAD", 44, 318, 1240, 42, 31, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    self:buildAmountKeypad(left, "withdraw", accent, {
        y = 370,
        keyH = 78,
        gapY = 12,
        numberFontSize = 35,
        controlFontSize = 28,
        fillOpacity = 0.84,
    })

    marmurText(right, "REVIEW & CONFIRM", 44, 12, 1300, 62, 44, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(right, "Review the transfer details before posting.", 46, 76, 1290, 64, 28, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local review = self:makePanel(right, 40, 150, 1340, 430)
    self:drawTransferReviewRow(review, "From", "Savings  •  E$ " .. utils.formatNumber(sourceAmount), 10, accent, true)
    self:drawTransferReviewRow(review, "To", "Checking  •  E$ " .. utils.formatNumber(destinationAmount), 76, color.white, true)
    self:drawTransferReviewRow(review, "Transfer Amount", "E$ " .. utils.formatNumber(amount), 142, amountColor, true)
    self:drawTransferReviewRow(review, "Transfer Fee", "E$ 0", 208, color.white, true)
    self:drawTransferReviewRow(review, "New Checking Balance", "E$ " .. utils.formatNumber(checkingAfter), 274, color.white, true)
    self:drawTransferReviewRow(review, "New Savings Balance", "E$ " .. utils.formatNumber(savingsAfter), 340, savingsAfter < 0 and (color.brandRedBright or color.red) or accent, false)

    local statusPanel = self:makePanel(right, 40, 598, 1340, 68)
    local statusText = "Enter an amount to enable confirmation."
    local statusColor = color.dim
    if #errorText > 0 then
        statusText = errorText
        statusColor = color.brandRedBright or color.red
    elseif exceedsFunds then
        statusText = "Amount exceeds available Savings funds."
        statusColor = color.brandRedBright or color.red
    elseif validAmount then
        statusText = "Ready to post immediately to the Activity ledger."
        statusColor = color.brandWhite or color.white
    end
    marmurText(statusPanel, statusText, 22, 4, 1296, 60, 26, statusColor,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local confirmCallback = validAmount and function() self:submitCustomAmount("withdraw", data) end or nil
    self:createTransferAction(right, "CONFIRM WITHDRAWAL", 40, 686, 1340, 76, confirmCallback, validAmount)
end

function shell:buildServicesPage()
    local data = self:getBankData()
    local loyalty = data.loyalty or {}
    local svc = data.service or self:calculatePrivateClientService(data.bank, 0, loyalty)
    local cashback = data.cashback or {}
    local tierName = tostring(loyalty.tier or cashback.tier or svc.tier or "Standard")
    local destination = tostring(cashback.destinationLabel or "Checking")
    local cashbackRate = self:formatCashbackRate(cashback.rateBp, cashback.ratePercent or svc.cashbackPercent)
    local averageBalance = math.max(math.floor(tonumber(loyalty.averageBalance) or 0), 0)
    local activeTier = math.max(0, math.min(math.floor(tonumber(loyalty.activeTier) or 0), 4))
    local nextTier, nextNeeded = self:getNextAccountTier(averageBalance, activeTier)
    local nextMilestone = nextTier and ("E$ " .. utils.formatNumber(nextNeeded) .. " to " .. tostring(nextTier.name)) or "Highest level active"
    local context = Calendar.getContext()
    local nextPayout = "Not scheduled"
    if math.floor(tonumber(cashback.nextPayoutStamp) or 0) > 0 then
        nextPayout = Calendar.formatMinuteStamp(cashback.nextPayoutStamp, context, true)
    end
    local auto = nil
    pcall(function() auto = Bank:getAutoDepositSettings() end)
    auto = auto or { active = false, amount = 0, intervalDays = 7, nextStamp = 0 }

    local strip = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(strip, "ACCOUNT SERVICES", 40, 10, 1450, 70, 50, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(strip, "Manage your account level, cashback destination, and core banking settings.",
        42, 82, 1450, 64, 27, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(strip, "Account Level", tierName, 1580, 28, color.brandRedBright or color.red, 390, 24, 34)
    self:drawHeaderStat(strip, "Cashback", cashbackRate, 2010, 28, color.cashbackGreen or color.white, 330, 24, 36)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(data.bank or 0), 2370, 28, color.white, 390, 24, 34)

    local levelPanel = self:makePanel(self.contentCanvas, 80, 660, 1340, 620)
    marmurText(levelPanel, "ACCOUNT LEVEL", 38, 8, 1240, 58, 40, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(levelPanel, "Based on your rolling seven-day Savings average.", 40, 64, 1180, 44, 24, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    self:drawHeaderStat(levelPanel, "Current Level", tierName, 40, 112, color.brandRedBright or color.red, 380, 23, 38)
    self:drawHeaderStat(levelPanel, "7-Day Average", "E$ " .. utils.formatNumber(averageBalance), 450, 112, color.white, 390, 23, 34)
    self:drawHeaderStat(levelPanel, "Next Milestone", nextMilestone, 870, 112, nextTier and color.white or color.brandRedBright, 410, 23, 29)

    local tableTop = 236
    local tableRule = ink.rect(38, tableTop - 10, 1264, 2, color.brandRed or color.red)
    tableRule:SetOpacity(0.32)
    tableRule:Reparent(levelPanel, -1)
    local rowY = tableTop
    local rowH = 62
    for _, tier in ipairs(self:getAccountTierRows()) do
        local active = math.floor(tonumber(tier.index) or 0) == activeTier
        if active then
            local activeBg = ink.rect(30, rowY, 1276, rowH - 4, color.brandRed or color.red)
            activeBg:SetOpacity(0.15)
            activeBg:Reparent(levelPanel, -1)
            local activeBar = ink.rect(30, rowY, 5, rowH - 4, color.brandRedBright or color.red)
            activeBar:SetOpacity(0.92)
            activeBar:Reparent(levelPanel, -1)
        end
        marmurText(levelPanel, tier.range, 52, rowY, 230, rowH - 4, 24, active and color.white or color.dim,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
        marmurText(levelPanel, tier.name, 320, rowY, 420, rowH - 4, 27, active and color.brandRedBright or color.white,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
        marmurText(levelPanel, tier.cashback .. " cashback", 800, rowY, 300, rowH - 4, 24,
            active and (color.cashbackGreen or color.white) or color.dim,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
        marmurRightText(levelPanel, active and "CURRENT" or "", 1110, rowY, 160, rowH - 4, 22,
            color.brandRedBright or color.red, false)
        rowY = rowY + rowH
    end
    marmurText(levelPanel,
        "Earned levels remain protected to 75% of their threshold. Three full days below that floor may lower the level.",
        40, 554, 1240, 56, 22, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local cashbackPanel = self:makePanel(self.contentCanvas, 1460, 660, 1420, 620)
    marmurText(cashbackPanel, "CASHBACK REWARDS", 38, 8, 1320, 58, 40, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(cashbackPanel, "Rewards post every seven days at 3:00 PM.", 40, 64, 1240, 44, 24, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    self:drawHeaderStat(cashbackPanel, "Current Rate", cashbackRate, 40, 112, color.cashbackGreen or color.white, 330, 23, 42)
    self:drawHeaderStat(cashbackPanel, "Pending", "E$ " .. utils.formatNumber(cashback.pendingEarned or 0), 410, 112, color.brandRedBright or color.red, 380, 23, 36)
    self:drawHeaderStat(cashbackPanel, "Total Paid", "E$ " .. utils.formatNumber(cashback.totalEarned or 0), 820, 112, color.white, 420, 23, 36)

    marmurText(cashbackPanel, "REWARD DESTINATION", 40, 222, 1270, 38, 23, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    self:createTransferKey(cashbackPanel, "CHECKING", 40, 266, 620, 76, function()
        pcall(function() Bank:setCashbackDestination("checking") end)
        self:renderPage("services")
    end, {
        borderColor = destination == "Checking" and (color.brandRedBright or color.red) or color.dim,
        textColor = destination == "Checking" and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = destination == "Checking" and 0.72 or 0.42,
    })
    self:createTransferKey(cashbackPanel, "SAVINGS", 690, 266, 620, 76, function()
        pcall(function() Bank:setCashbackDestination("savings") end)
        self:renderPage("services")
    end, {
        borderColor = destination == "Savings" and (color.brandRedBright or color.red) or color.dim,
        textColor = destination == "Savings" and (color.brandWhite or color.white) or color.brandWhiteSoft,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = destination == "Savings" and 0.72 or 0.42,
    })

    self:drawPolishedRow(cashbackPanel, "Next Payout", nextPayout, 366, {
        x = 40, width = 1270, labelWidth = 360, rowHeight = 58, valueColor = color.white, valueFontSize = 26,
    })
    self:drawPolishedRow(cashbackPanel, "Reward Base", "E$ " .. utils.formatNumber(cashback.totalSpend or 0), 430, {
        x = 40, width = 1270, labelWidth = 360, rowHeight = 58, valueColor = color.white, valueFontSize = 28,
    })
    local lastText = (tonumber(cashback.lastEarned) or 0) > 0
        and ("Last payout: E$ " .. utils.formatNumber(cashback.lastEarned or 0))
        or "No cashback payout has posted yet."
    self:drawPolishedRow(cashbackPanel, "Most Recent", lastText, 494, {
        x = 40, width = 1270, labelWidth = 360, rowHeight = 66, valueColor = color.dim, valueFontSize = 24, drawLine = false,
    })

    local management = self:makePanel(self.contentCanvas, 80, 1300, 2800, 190)
    marmurText(management, "ACCOUNT MANAGEMENT", 30, 4, 1760, 48, 35, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    local accountLabel = tostring(data.accountNumber or "MB-2077-00000000")
    self:drawHeaderStat(management, "Account Number", accountLabel, 30, 48, color.white, 470, 20, 28)
    self:drawHeaderStat(management, "Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 520, 48, color.white, 390, 20, 29)
    self:drawHeaderStat(management, "Savings", "E$ " .. utils.formatNumber(data.bank or 0), 930, 48, color.brandRedBright or color.red, 390, 20, 29)
    self:drawHeaderStat(management, "Auto-Deposit", auto.active == true
        and (self:getAutoDepositPresetLabel(auto.intervalDays) .. " • E$ " .. utils.formatNumber(auto.amount or 0))
        or "Not Scheduled", 1340, 48, auto.active == true and color.white or color.dim, 500, 20, 25)

    self:createTransferKey(management, "VIEW ACTIVITY", 1870, 54, 270, 78, function() self:renderPage("transactions") end, {
        borderColor = color.dim, textColor = color.white, fontSize = 23, fillOpacity = 0.42,
    })
    self:createTransferKey(management, "DISCLOSURES", 2160, 54, 270, 78, function() self:renderPage("disclosures") end, {
        borderColor = color.dim, textColor = color.white, fontSize = 23, fillOpacity = 0.42,
    })
    self:createTransferKey(management, "CLOSE ACCOUNT", 2450, 54, 320, 78, function() self:renderPage("closeaccount") end, {
        borderColor = color.brandRed or color.red, textColor = color.brandRedBright or color.red,
        hoverColor = color.brandWhite or color.white, fontSize = 23, fillOpacity = 0.50,
    })

    marmurText(management, tostring(loyalty.statusText or "Marmur Bank recognizes financial growth and account loyalty."),
        30, 140, 1760, 40, 22, loyalty.atRisk == true and (color.brandRedBright or color.red) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
end

local _marmurV216OriginalBuildDisclosuresPage = shell.buildDisclosuresPage
function shell:buildDisclosuresPage(loggedIn)
    if loggedIn ~= true then
        return _marmurV216OriginalBuildDisclosuresPage(self, loggedIn)
    end

    local sections = self:getDisclosureSections()
    local selectedIndex = math.max(1, math.min(math.floor(tonumber(self.disclosureSelectedIndex) or 1), #sections))
    self.disclosureSelectedIndex = selectedIndex
    local selected = sections[selectedIndex]

    local header = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(header, "ACCOUNT DISCLOSURES", 34, 10, 1480, 70, 50, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(header, "Choose one topic at a time. The selected disclosure appears in full on the right.",
        36, 82, 1540, 64, 27, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(header, "Effective", "2077-01-01", 2110, 28, color.white, 300, 23, 32)
    self:drawHeaderStat(header, "Version", "MBK-LEGAL-14", 2440, 28, color.brandRedBright or color.red, 320, 23, 30)

    local leftW = 760
    local gap = 36
    local rightW = 2800 - leftW - gap
    local left = self:makePanel(self.contentCanvas, 80, 660, leftW, 790)
    local right = self:makePanel(self.contentCanvas, 80 + leftW + gap, 660, rightW, 790)

    marmurText(left, "DISCLOSURE INDEX", 28, 8, leftW - 56, 52, 36, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(left, "Select a section", 30, 58, leftW - 60, 38, 23, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)

    local buttonY = 104
    for i, section in ipairs(sections) do
        local targetIndex = i
        local active = i == selectedIndex
        self:createTransferKey(left, tostring(i) .. ".  " .. section.short, 26, buttonY, leftW - 52, 82, function()
            self:selectDisclosure(targetIndex)
        end, {
            borderColor = active and (color.brandRedBright or color.red) or color.dim,
            textColor = active and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 25,
            fillOpacity = active and 0.72 or 0.42,
        })
        buttonY = buttonY + 92
    end

    marmurText(left,
        "The Activity ledger and confirmation screens remain the controlling record for completed banking actions.",
        30, 660, leftW - 60, 108, 22, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    marmurText(right, tostring(selectedIndex) .. ". " .. selected.title, 34, 8, rightW - 68, 74, 42,
        color.brandWhite or color.white, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    marmurText(right, selected.intro, 36, 82, rightW - 72, 96, 27, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    local rule = ink.rect(36, 182, rightW - 72, 2, color.brandRed or color.red)
    rule:SetOpacity(0.38)
    rule:Reparent(right, -1)

    local bulletY = 194
    local bulletRowH = 92
    for i, body in ipairs(selected.bullets) do
        marmurCenteredText(right, string.format("%02d", i), 38, bulletY, 54, bulletRowH - 8, 24,
            color.brandRedBright or color.red, false)
        marmurText(right, body, 104, bulletY, rightW - 146, bulletRowH - 8, 27,
            color.brandWhiteSoft or color.white, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
        local bulletLine = ink.rect(104, bulletY + bulletRowH - 4, rightW - 142, 1, color.brandWhite or color.white)
        bulletLine:SetOpacity(0.07)
        bulletLine:Reparent(right, -1)
        bulletY = bulletY + bulletRowH
    end

    marmurText(right,
        "Marmur Bank service disclosure. This Night City banking simulation does not provide real-world financial, tax, or legal advice.",
        36, 656, rightW - 72, 54, 22, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local previousIndex = selectedIndex > 1 and (selectedIndex - 1) or nil
    local nextIndex = selectedIndex < #sections and (selectedIndex + 1) or nil
    self:createTransferKey(right, "PREVIOUS", rightW - 700, 720, 210, 60,
        previousIndex and function() self:selectDisclosure(previousIndex) end or nil, {
            borderColor = color.dim,
            textColor = previousIndex and color.brandWhite or color.dim,
            fontSize = 22,
            fillOpacity = 0.42,
        })
    self:createTransferKey(right, "NEXT", rightW - 470, 720, 200, 60,
        nextIndex and function() self:selectDisclosure(nextIndex) end or nil, {
            borderColor = color.dim,
            textColor = nextIndex and color.brandWhite or color.dim,
            fontSize = 22,
            fillOpacity = 0.42,
        })
    self:createTransferKey(right, "BACK TO HOME", rightW - 250, 720, 220, 60, function() self:renderPage("home") end, {
        borderColor = color.brandRed or color.red,
        textColor = color.brandRedBright or color.red,
        hoverColor = color.brandWhite or color.white,
        fontSize = 21,
        fillOpacity = 0.48,
    })
end

function shell:buildTransactionsPage()
    local data = self:getBankData()
    local calendarContext = Calendar.getContext()
    local totalRows = 0
    local pageSize = tonumber(self.transactionPageSize) or 4
    if pageSize < 1 then pageSize = 4 end

    self.transactionPage = math.max(1, tonumber(self.transactionPage) or 1)
    local offset = (self.transactionPage - 1) * pageSize
    local rows = {}

    local function fetchTransactionPage()
        rows = {}
        local fetchedTotal = 0
        pcall(function()
            local pageRows, total = Bank:getTransactionPage(pageSize, offset, self:normalizeTransactionSortMode(self.transactionSortMode))
            if type(pageRows) == "table" then rows = pageRows end
            fetchedTotal = tonumber(total) or #rows
        end)
        totalRows = fetchedTotal
    end

    fetchTransactionPage()
    local maxPage = math.max(1, math.ceil(totalRows / pageSize))
    local clampedPage = math.max(1, math.min(self.transactionPage, maxPage))
    if clampedPage ~= self.transactionPage then
        self.transactionPage = clampedPage
        offset = (self.transactionPage - 1) * pageSize
        fetchTransactionPage()
        maxPage = math.max(1, math.ceil(totalRows / pageSize))
    end

    local strip = self:makePanel(self.contentCanvas, 80, 470, 2700, 170)
    marmurText(strip, "ACTIVITY", 40, 8, 1450, 78, 60, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(strip, "All account records with their actual posting date and time.", 42, 88, 1450, 64, 32, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(strip, "Checking", "E$ " .. utils.formatNumber(data.wallet), 1808, 28, color.white, 390, 28, 42)
    self:drawHeaderStat(strip, "Savings", "E$ " .. utils.formatNumber(data.bank), 2228, 28, color.gold, 450, 28, 42)

    local main = self:makePanel(self.contentCanvas, 80, 660, 2700, 790)
    marmurText(main, "TRANSACTION HISTORY", 40, 8, 760, 70, 52, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurCenteredText(main, string.format("Page %d of %d  •  %d records", self.transactionPage, maxPage, totalRows),
        880, 16, 760, 58, 34, color.white, false)

    local cooldown = self:getDisputeCooldownSummary()
    marmurText(main, tostring(cooldown.text or "Disputes available"), 1460, 88, 650, 48, 30,
        cooldown.active and color.red or color.green, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local prevCb = nil
    local nextCb = nil
    if self.transactionPage > 1 then prevCb = function() self:setTransactionPage(-1, maxPage) end end
    if self.transactionPage < maxPage then nextCb = function() self:setTransactionPage(1, maxPage) end end
    local filterMode = self:normalizeTransactionSortMode(self.transactionSortMode)
    local filterHighlighted = filterMode ~= "recent"
    local filterLabel = "Filter: " .. self:getTransactionSortButtonLabel(filterMode)
    self:createButton(main, filterLabel, 2170, 12, 470, 72, function() self:cycleTransactionSortMode() end, {
        bgColor = color.brandPanel2,
        fgColor = filterHighlighted and color.gold or color.cyan,
        hoverColor = color.white,
        active = filterHighlighted,
        fontSize = 30,
    })

    if totalRows <= 0 or #rows <= 0 then
        local emptyPanel = self:makePanel(main, 40, 150, 2620, 420)
        marmurCenteredText(emptyPanel, "NO ACTIVITY YET", 80, 64, 2460, 88, 50, color.white, false)
        marmurCenteredText(emptyPanel,
            "Deposits, withdrawals, loan events, fees, interest, disputes, purchases, and theft-protection notices will appear here once posted.",
            120, 170, 2380, 150, 36, color.dim, true)
        return
    end

    local oldestDay = nil
    local newestDay = nil
    for _, row in ipairs(rows) do
        local rowDay = math.floor(tonumber(row.day) or -1)
        if rowDay >= 0 then
            if oldestDay == nil or rowDay < oldestDay then oldestDay = rowDay end
            if newestDay == nil or rowDay > newestDay then newestDay = rowDay end
        end
    end
    local displayedRange = "Displayed records: date unavailable"
    if oldestDay ~= nil and newestDay ~= nil then
        local oldestDate = Calendar.formatEngineDay(oldestDay, calendarContext, true)
        local newestDate = Calendar.formatEngineDay(newestDay, calendarContext, true)
        displayedRange = oldestDate == newestDate and ("Displayed records: " .. newestDate)
            or ("Displayed records: " .. oldestDate .. " — " .. newestDate)
    end
    marmurText(main, displayedRange, 40, 88, 1320, 48, 28, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local function formatActivitySummary(value)
        local text = tostring(value or ""):gsub("%s+", " ")
        local maxLine = 42
        local maxTotal = 84
        if #text > maxTotal then
            local clipped = text:sub(1, maxTotal - 3)
            local lastSpace = clipped:match("^.*()%s+")
            if lastSpace and lastSpace > 42 then clipped = clipped:sub(1, lastSpace - 1) end
            text = clipped .. "..."
        end
        if #text <= maxLine then return text end
        local split = maxLine
        local before = text:sub(1, maxLine)
        local lastSpace = before:match("^.*()%s+")
        if lastSpace and lastSpace > 20 then split = lastSpace - 1 end
        local first = text:sub(1, split):gsub("%s+$", "")
        local second = text:sub(split + 1):gsub("^%s+", "")
        return first .. "\n" .. second
    end

    local dateX, dateW = 24, 276
    local descriptionX, descriptionW = 330, 710
    local channelX, channelW = 1090, 270
    local statusX, statusW = 1400, 270
    local amountX, amountW = 1710, 390
    local actionX, actionW = 2180, 390

    local y = 150
    local rowNumber = 0
    local rowH = 130
    local rowStep = 136
    for _, row in ipairs(rows) do
        rowNumber = rowNumber + 1
        local rowPanel = self:makePanel(main, 40, y, 2620, rowH)
        local txType = tonumber(row.type) or 0
        local accent = self:getTransactionColor(txType, row.disputeStatus)
        local label = self:getTransactionLabel(txType, row.subject)
        local amount = self:getTransactionSignedAmount(txType, row.amount or 0)
        local status = self:getTransactionStatus(txType, row)
        local channel = self:getTransactionChannel(txType, row.source)
        local cashbackEarned = self:getTransactionCashbackAmount(row)
        local summary = cashbackEarned > 0 and self:getTransactionActivitySummary(row) or self:getTransactionSummary(row)

        if rowNumber % 2 == 0 then
            local shade = ink.rect(2, 2, 2616, rowH - 4, color.black)
            shade:SetOpacity(0.12)
            shade:Reparent(rowPanel, -1)
        end

        local rowDay = math.floor(tonumber(row.day) or -1)
        local dateLabel = rowDay >= 0 and Calendar.formatEngineDay(rowDay, calendarContext, true) or "DATE UNAVAILABLE"
        local timeLabel = rowDay >= 0
            and Calendar.formatTime(row.hour, row.minute, calendarContext.use12Hour, false, 0)
            or tostring(row.timestamp or "Time unavailable")
        marmurText(rowPanel, dateLabel, dateX, 7, dateW, 52, 26, color.white,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
        marmurText(rowPanel, timeLabel, dateX, 61, dateW, 54, 23, color.dim,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, false)

        marmurText(rowPanel, label, descriptionX, 5, descriptionW, 48, 31, accent,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
        local fittedSummary = formatActivitySummary(summary)
        if cashbackEarned > 0 then
            marmurText(rowPanel, fittedSummary, descriptionX, 49, descriptionW, 44, 22, color.dim,
                textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
            marmurText(rowPanel, "CASHBACK EARNED  +E$ " .. utils.formatNumber(cashbackEarned), descriptionX, 91, descriptionW, 30, 22,
                color.cashbackGreen, textHorizontalAlignment.Left, textVerticalAlignment.Center, false, "Medium")
        else
            marmurText(rowPanel, fittedSummary, descriptionX, 49, descriptionW, 70, 23, color.dim,
                textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
        end

        for _, dividerX in ipairs({ 1064, 1382, 1692, 2138 }) do
            local divider = ink.rect(dividerX, 12, 2, rowH - 24, color.brandWhite or color.white)
            divider:SetOpacity(0.07)
            divider:Reparent(rowPanel, -1)
        end

        marmurCenteredText(rowPanel, "CHANNEL", channelX, 8, channelW, 30, 20, color.dim, false)
        marmurCenteredText(rowPanel, channel, channelX, 38, channelW, 80, 25, color.white, false)
        marmurCenteredText(rowPanel, "STATUS", statusX, 8, statusW, 30, 20, color.dim, false)
        marmurCenteredText(rowPanel, status, statusX, 38, statusW, 80, 25, accent, false)
        marmurRightText(rowPanel, amount, amountX, 0, amountW, rowH, 31,
            self:getTransactionAmountColor(txType, row.disputeStatus), false)

        if row.disputable == true and cooldown.active ~= true then
            self:createTransferKey(rowPanel, "DISPUTE", actionX, 31, actionW, 68, function() self:beginDispute(row) end, {
                borderColor = color.brandRed or color.red,
                textColor = color.brandRedBright or color.red,
                hoverColor = color.brandWhite or color.white,
                fontSize = 24,
                fillOpacity = 0.48,
            })
        elseif row.disputeHiddenByCooldown == true then
        elseif txType == 4 and tonumber(row.disputeStatus) == 3 then
            marmurCenteredText(rowPanel, "IN REVIEW", actionX, 0, actionW, rowH, 25, color.gold, false)
        elseif txType == 4 and tonumber(row.disputeStatus) == 4 then
            marmurCenteredText(rowPanel, "CREDITED", actionX, 0, actionW, rowH, 25, color.green, false)
        elseif txType == 4 and tonumber(row.disputeStatus) == 5 then
            marmurCenteredText(rowPanel, "DENIED", actionX, 0, actionW, rowH, 25, color.red, false)
        else
            marmurCenteredText(rowPanel, "POSTED", actionX, 0, actionW, rowH, 24, color.dim, false)
        end

        y = y + rowStep
    end

    local bottomNavY = 706
    self:createButton(main, "Previous", 820, bottomNavY, 320, 70, prevCb, {
        fgColor = prevCb and color.cyan or color.dim,
        textColor = prevCb and color.white or color.dim,
        fontSize = 29,
    })
    marmurCenteredText(main, tostring(self.transactionPage) .. " of " .. tostring(maxPage), 1150, bottomNavY,
        390, 70, 29, color.white, false)
    self:createButton(main, "Next", 1550, bottomNavY, 320, 70, nextCb, {
        fgColor = nextCb and color.cyan or color.dim,
        textColor = nextCb and color.white or color.dim,
        fontSize = 29,
    })
end


local _marmurV216SidebarSectionBase = shell.getSidebarSection
function shell:getSidebarSection()
    if tostring(self.activePage or "") == "anodosteaser" then
        return "anodos"
    end
    return _marmurV216SidebarSectionBase(self)
end

function shell:buildAuthenticatedSidebar()
    local sidebar = ink.canvas(0, 300, inkEAnchor.TopLeft)
    sidebar:SetSize(Vector2.new({ X = 360, Y = 1030 }))
    sidebar:Reparent(self.contentCanvas, -1)

    local sidebarBg = ink.rect(0, 0, 360, 1030, color.brandPanel or color.panel)
    sidebarBg:SetOpacity(0.88)
    sidebarBg:Reparent(sidebar, -1)

    local divider = ink.rect(358, 0, 2, 1030, color.brandRed or color.red)
    divider:SetOpacity(0.34)
    divider:Reparent(sidebar, -1)

    local active = self:getSidebarSection()
    local navY = 18
    local step = 72
    self:createHomeSidebarItem(sidebar, "Home",        navY + (step * 0), function() self:renderPage("home") end, active == "home")
    self:createHomeSidebarItem(sidebar, "Activity",    navY + (step * 1), function() self:renderPage("transactions") end, active == "activity")
    self:createHomeSidebarItem(sidebar, "Analytics",   navY + (step * 2), function() self:renderPage("insights") end, active == "analytics")
    self:createHomeSidebarItem(sidebar, "Deposit",     navY + (step * 3), function() self:renderPage("deposit") end, active == "deposit")
    self:createHomeSidebarItem(sidebar, "Withdraw",    navY + (step * 4), function() self:renderPage("withdraw") end, active == "withdraw")
    self:createHomeSidebarItem(sidebar, "Loans",       navY + (step * 5), function() self:renderPage("loans") end, active == "loans")
    self:createHomeSidebarItem(sidebar, "Services",    navY + (step * 6), function() self:renderPage("services") end, active == "services")
    self:createHomeSidebarItem(sidebar, "Disclosures", navY + (step * 7), function() self:renderPage("disclosures") end, active == "disclosures")
    self:createHomeSidebarItem(sidebar, "Logout",      navY + (step * 8), function() self:logout() end, false)

    local partnerRule = ink.rect(28, 680, 304, 2, color.brandRed or color.red)
    partnerRule:SetOpacity(0.30)
    partnerRule:Reparent(sidebar, -1)
    marmurCenteredText(sidebar, "MARMUR PARTNER PORTAL", 24, 690, 312, 34, 20, color.dim, false)

    local teaserActive = active == "anodos"
    local partnerLabel = teaserActive and "Return to Marmur" or "Go to ANODOS"
    self:createTransferKey(sidebar, partnerLabel, 20, 730, 320, 78, function()
        if teaserActive then
            self:renderPage("home")
        else
            self:openAnodosPartnerPortal()
        end
    end, {
        borderColor = teaserActive and (color.brandWhite or color.white) or (color.brandRedBright or color.red),
        textColor = teaserActive and (color.brandWhite or color.white) or (color.brandRedBright or color.red),
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = teaserActive and 0.78 or 0.54,
        borderOpacity = teaserActive and 0.90 or 0.62,
    })

    local footerLine = ink.rect(28, 858, 304, 2, color.brandWhite or color.white)
    footerLine:SetOpacity(0.08)
    footerLine:Reparent(sidebar, -1)
    marmurText(sidebar, "© 2077 MARMUR BANK\nALL RIGHTS RESERVED.", 38, 880, 280, 92, 22, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
end

local _marmurV216OriginalBuildHomeFrame = shell.buildHomeFrame
function shell:buildHomeFrame()
    _marmurV216OriginalBuildHomeFrame(self)

    local partnerRule = ink.rect(28, 508, 304, 2, color.brandRed or color.red)
    partnerRule:SetOpacity(0.30)
    partnerRule:Reparent(self.contentCanvas, -1)
    marmurCenteredText(self.contentCanvas, "MARMUR PARTNER PORTAL", 24, 520, 312, 38, 20, color.dim, false)
    self:createTransferKey(self.contentCanvas, "Go to ANODOS", 20, 568, 320, 82, function()
        self:openAnodosPartnerPortal()
    end, {
        borderColor = color.brandRedBright or color.red,
        textColor = color.brandRedBright or color.red,
        hoverColor = color.brandWhite or color.white,
        fontSize = 27,
        fillOpacity = 0.54,
        borderOpacity = 0.62,
    })
end

local function marmurMetricCard(parent, label, value, x, y, w, h, valueColor, valueFontSize, detail, detailColor)
    local panel = ink.canvas(x, y, inkEAnchor.TopLeft)
    panel:SetSize(Vector2.new({ X = w, Y = h }))
    panel:Reparent(parent, -1)

    local border = ink.rect(0, 0, w, h, color.brandWhite or color.white)
    border:SetOpacity(0.12)
    border:Reparent(panel, -1)
    local fill = ink.rect(2, 2, math.max(w - 4, 2), math.max(h - 4, 2), color.brandPanel2 or color.panel2)
    fill:SetOpacity(0.54)
    fill:Reparent(panel, -1)

    marmurCenteredText(panel, label, 20, 8, w - 40, 30, 21, color.dim, false)
    marmurCenteredText(panel, value, 24, 40, w - 48, detail and 52 or (h - 54), valueFontSize or 38,
        valueColor or color.white, false, "Medium")
    if detail then
        marmurCenteredText(panel, detail, 24, h - 40, w - 48, 28, 19, detailColor or color.dim, false)
    end
    return panel
end

function shell:buildInsightsPage()
    local data = nil
    local insightsOk, insightsError = pcall(function()
        data = Bank:getSpendingInsights(self.insightsPeriodDays, self.insightsPeriodOffset)
    end)
    if insightsOk ~= true then
        print("[Marmur Bank] Analytics unavailable: " .. tostring(insightsError or "unknown error"))
    end
    if type(data) ~= "table" then
        data = {
            periodDays = tonumber(self.insightsPeriodDays) or 30,
            periodOffset = 0,
            maxPeriods = 1,
            rangeLabel = "Posted history unavailable",
            total = 0,
            previousTotal = 0,
            totalDelta = { direction = "flat", label = "--" },
            transactionCount = 0,
            categories = {},
            historyUnavailable = true,
        }
    end

    self.insightsPeriodDays = tonumber(data.periodDays) or 30
    self.insightsPeriodOffset = tonumber(data.periodOffset) or 0
    self.insightsSnapshotRevision = tostring(data.revision or "")

    local accent = color.brandRedBright or color.red
    local comparisonReady = data.partial ~= true and data.comparisonPartial ~= true and data.historyUnavailable ~= true
    local periodLabel = self.insightsPeriodOffset == 0
        and ("Last " .. tostring(self.insightsPeriodDays) .. " Days")
        or (tostring(self.insightsPeriodDays) .. "-Day Period")

    local rangeStatus = "Posted transaction history"
    local rangeStatusColor = color.dim
    if data.historyUnavailable == true then
        rangeStatus = "History unavailable"
        rangeStatusColor = accent
    elseif data.partial == true then
        rangeStatus = "Partial history"
        rangeStatusColor = color.gold or accent
    elseif data.comparisonPartial == true then
        rangeStatus = "Comparison history incomplete"
        rangeStatusColor = color.gold or accent
    elseif data.historyLimited == true then
        rangeStatus = "Older history is limited"
        rangeStatusColor = color.gold or accent
    end

    local header = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(header, "SPENDING ANALYTICS", 40, 10, 1080, 70, 50, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(header, "A clear breakdown of where your money went.", 42, 82, 1080, 60, 27, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    marmurCenteredText(header, "REPORTING PERIOD", 1230, 18, 430, 34, 22, accent, false)
    self:createTransferKey(header, periodLabel, 1230, 58, 430, 80, function() self:cycleInsightsPeriod() end, {
        borderColor = color.dim,
        textColor = color.brandWhite or color.white,
        hoverColor = accent,
        fontSize = 29,
        fillOpacity = 0.50,
    })

    marmurCenteredText(header, "TRACKED RANGE", 1690, 18, 650, 34, 22, accent, false)
    marmurCenteredText(header, tostring(data.rangeLabel or "Date unavailable"), 1690, 54, 650, 48, 29,
        color.brandWhite or color.white, true)
    marmurCenteredText(header, rangeStatus, 1690, 104, 650, 36, 21, rangeStatusColor, true)

    local top = data.topCategory
    marmurCenteredText(header, "TOP CATEGORY", 2370, 18, 390, 34, 22, accent, false)
    marmurCenteredText(header, top and tostring(top.label or "Other") or "No recorded spending", 2370, 54, 390, 54,
        top and 28 or 24, top and (color.brandWhite or color.white) or color.dim, true)
    local topPercent = top and (tostring(top.percent or 0) .. (data.partial == true and "% recorded" or "% total")) or "0%"
    marmurCenteredText(header, topPercent, 2370, 108, 390, 34, 22, color.dim, true)

    local left = self:makePanel(self.contentCanvas, 80, 660, 1810, 810)
    marmurText(left, data.partial == true and "RECORDED SPENDING" or "TOTAL SPENDING", 36, 12, 740, 42, 28, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(left, "E$ " .. utils.formatNumber(data.total or 0), 36, 50, 930, 88, 58,
        color.brandWhite or color.white, textHorizontalAlignment.Left, textVerticalAlignment.Center, true, "Medium")
    marmurRightText(left, tostring(data.transactionCount or 0) .. " recorded outflows", 1050, 48, 690, 52, 27, color.dim, true)

    local totalComparison = comparisonReady
        and self:formatInsightsDelta(data.totalDelta, false, data.periodDays)
        or "More history is needed for comparison."
    marmurText(left, totalComparison, 36, 132, 1680, 48, 25,
        comparisonReady and self:getInsightsDeltaColor(data.totalDelta) or (color.gold or color.dim),
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local divider = ink.rect(32, 188, 1746, 2, color.brandWhite or color.white)
    divider:SetOpacity(0.14)
    divider:Reparent(left, -1)
    marmurText(left, "SPENDING BREAKDOWN", 36, 198, 470, 48, 31, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurCenteredText(left, "AMOUNT", 1280, 202, 300, 40, 22, color.dim, false)
    marmurCenteredText(left, data.partial == true and "% RECORDED" or "% OF TOTAL", 1580, 202, 190, 40, 21, color.dim, false)

    local categories = data.categories or {}
    local categoryPageSize = 4
    local categoryPageCount = math.max(math.ceil(#categories / categoryPageSize), 1)
    self.insightsCategoryPage = math.max(1, math.min(math.floor(tonumber(self.insightsCategoryPage) or 1), categoryPageCount))
    local firstCategory = ((self.insightsCategoryPage - 1) * categoryPageSize) + 1
    local lastCategory = math.min(firstCategory + categoryPageSize - 1, #categories)
    local visibleCategories = {}
    for index = firstCategory, lastCategory do
        table.insert(visibleCategories, categories[index])
    end
    while #visibleCategories < categoryPageSize do
        table.insert(visibleCategories, { label = "No additional category", amount = 0, percent = 0 })
    end

    local rowY = 252
    local rowH = 88
    local barX = 500
    local barW = 690
    for _, category in ipairs(visibleCategories) do
        category = category or {}
        local amount = math.max(math.floor(tonumber(category.amount) or 0), 0)
        local percent = math.max(0, math.min(math.floor(tonumber(category.percent) or 0), 100))
        local rowPanel = self:makePanel(left, 32, rowY, 1746, rowH - 8)
        marmurText(rowPanel, tostring(category.label or "Other Spending"), 22, 0, 430, rowH - 8, 29,
            amount > 0 and (color.brandWhite or color.white) or color.dim,
            textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

        local track = ink.rect(barX - 32, 30, barW, 18, color.brandPanel3 or color.panel2)
        track:SetOpacity(0.90)
        track:Reparent(rowPanel, -1)
        if amount > 0 and percent > 0 then
            local fillWidth = math.max(math.floor(barW * (percent / 100.0)), 6)
            local fill = ink.rect(barX - 32, 30, fillWidth, 18, accent)
            fill:SetOpacity(0.90)
            fill:Reparent(rowPanel, -1)
        end

        marmurRightText(rowPanel, "E$ " .. utils.formatNumber(amount), 1190, 0, 350, rowH - 8, 29,
            amount > 0 and (color.brandWhite or color.white) or color.dim, true)
        marmurCenteredText(rowPanel, tostring(percent) .. "%", 1550, 0, 170, rowH - 8, 29,
            amount > 0 and (color.brandWhite or color.white) or color.dim, false)
        rowY = rowY + rowH
    end

    local previousCategoryCallback = self.insightsCategoryPage > 1
        and function() self:setInsightsCategoryPage(-1, categoryPageCount) end or nil
    local nextCategoryCallback = self.insightsCategoryPage < categoryPageCount
        and function() self:setInsightsCategoryPage(1, categoryPageCount) end or nil
    self:createTransferKey(left, "PREVIOUS CATEGORIES", 36, 624, 460, 72, previousCategoryCallback, {
        borderColor = color.dim, textColor = previousCategoryCallback and color.white or color.dim,
        hoverColor = accent, fontSize = 25, fillOpacity = 0.42,
    })
    marmurCenteredText(left, "PAGE " .. tostring(self.insightsCategoryPage) .. " OF " .. tostring(categoryPageCount),
        615, 624, 570, 72, 26, color.white, false)
    self:createTransferKey(left, "NEXT CATEGORIES", 1314, 624, 460, 72, nextCategoryCallback, {
        borderColor = color.dim, textColor = nextCategoryCallback and color.white or color.dim,
        hoverColor = accent, fontSize = 25, fillOpacity = 0.42,
    })

    marmurText(left,
        "Detailed subjects appear when an exact item or service source is available. Earlier Checking-only records remain Uncategorized.",
        40, 714, 1720, 68, 22, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local right = self:makePanel(self.contentCanvas, 1930, 660, 950, 810)
    local largest = data.largest
    local frequent = data.frequentCategory

    local topCard = self:makePanel(right, 28, 22, 894, 158)
    marmurText(topCard, "TOP CATEGORY", 26, 8, 840, 36, 23, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(topCard, top and tostring(top.label or "Other") or "No recorded spending", 26, 46, 840, 58, 35,
        top and (color.brandWhite or color.white) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    local topDetail = top and ("E$ " .. utils.formatNumber(top.amount or 0) .. "  •  " .. topPercent) or "No eligible outflows in this period"
    marmurText(topCard, topDetail, 26, 108, 840, 38, 24, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local largestCard = self:makePanel(right, 28, 194, 894, 174)
    marmurText(largestCard, "LARGEST OUTFLOW", 26, 8, 840, 36, 23, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(largestCard, largest and tostring(largest.label or "Purchase") or "No purchase in this period", 26, 44, 840, 52, 32,
        largest and (color.brandWhite or color.white) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    marmurText(largestCard, largest and ("E$ " .. utils.formatNumber(largest.amount or 0)) or "E$ 0", 26, 98, 420, 52, 34,
        largest and accent or color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true, "Medium")
    local largestDateTime = "Date unavailable"
    if largest then
        if math.floor(tonumber(largest.day) or -1) >= 0 then
            largestDateTime = Calendar.formatEngineDateTime(largest.day, largest.hour, largest.minute, Calendar.getContext(), true)
        else
            largestDateTime = tostring(largest.timestamp or "Date unavailable")
        end
    end
    marmurRightText(largestCard, largestDateTime, 430, 98, 430, 52, 23, color.dim, true)

    local frequentCard = self:makePanel(right, 28, 382, 894, 154)
    marmurText(frequentCard, "MOST FREQUENT CATEGORY", 26, 8, 840, 36, 23, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(frequentCard, frequent and tostring(frequent.label or "Other") or "No spending category yet", 26, 44, 840, 52, 32,
        frequent and (color.brandWhite or color.white) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    local frequentDetail = frequent
        and (tostring(frequent.count or 0) .. " transactions  •  E$ " .. utils.formatNumber(frequent.amount or 0))
        or "0 transactions"
    marmurText(frequentCard, frequentDetail, 26, 100, 840, 38, 24, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local comparisonCard = self:makePanel(right, 28, 550, 894, 144)
    marmurText(comparisonCard, "PERIOD COMPARISON", 26, 8, 840, 36, 23, accent,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurCenteredText(comparisonCard,
        comparisonReady and self:formatInsightsDelta(data.totalDelta, false, data.periodDays) or "MORE HISTORY NEEDED",
        28, 42, 838, 54, comparisonReady and 30 or 28,
        comparisonReady and self:getInsightsDeltaColor(data.totalDelta) or (color.gold or color.dim), true, "Medium")
    marmurCenteredText(comparisonCard,
        comparisonReady and "Compared with the previous tracked period." or "Current totals remain available while comparison history builds.",
        28, 96, 838, 34, 20, color.dim, true)

    local previousCallback = nil
    local nextCallback = nil
    if self.insightsPeriodOffset < math.max((tonumber(data.maxPeriods) or 1) - 1, 0) then
        previousCallback = function() self:setInsightsPeriodOffset(1, data.maxPeriods) end
    end
    if self.insightsPeriodOffset > 0 then
        nextCallback = function() self:setInsightsPeriodOffset(-1, data.maxPeriods) end
    end
    self:createTransferKey(right, "PREVIOUS PERIOD", 28, 716, 300, 68, previousCallback, {
        borderColor = color.dim, textColor = previousCallback and color.white or color.dim,
        hoverColor = accent, fontSize = 23, fillOpacity = 0.42,
    })
    marmurCenteredText(right, tostring(self.insightsPeriodOffset + 1) .. " OF " .. tostring(data.maxPeriods or 1),
        344, 716, 230, 68, 25, color.white, false)
    self:createTransferKey(right, "NEXT PERIOD", 590, 716, 332, 68, nextCallback, {
        borderColor = color.dim, textColor = nextCallback and color.white or color.dim,
        hoverColor = accent, fontSize = 23, fillOpacity = 0.42,
    })

    self:scheduleInsightsRefresh()
end

local _marmurV216OriginalBuildLoansPage = shell.buildLoansPage
function shell:buildLoansPage()
    local data = self:getBankData()
    local loan = data.loan or {}
    local autoLoans = data.autoLoans or {}
    local standardRequest = loan.active ~= true and loan.reviewActive ~= true and #autoLoans == 0
        and (self.activePage == "loans" or self.activePage == "loanapply")
    if standardRequest ~= true then
        return _marmurV216OriginalBuildLoansPage(self)
    end

    local accent = color.brandRedBright or color.red
    local streetCred = math.floor(tonumber(data.streetCred) or 0)
    local errorText = tostring(self:getLoanError() or "")
    local requestedAmount = self:getCustomAmount("loanrequest")
    local selectedFrequency = self:getLoanPaymentFrequency()
    local selectedTermMonths = self:getLoanTermMonths()
    local quote = nil
    pcall(function() quote = Bank:getManualLoanQuote(requestedAmount, selectedFrequency, selectedTermMonths) end)
    if type(quote) ~= "table" then
        quote = {
            requiredStreetCred = 1,
            interestBasisPoints = 2400,
            approvalChance = 0,
            approvalRiskLabel = "HIGH",
            termPayments = 12,
            termMonths = selectedTermMonths,
            intervalDays = 30,
            frequencyLabel = "Monthly",
            totalDue = 0,
            installment = 0,
            principal = requestedAmount,
        }
    end

    local currentMax = 0
    pcall(function() currentMax = Bank:getLoanMaxForStreetCred(streetCred) or 0 end)
    local absoluteMax = 100000000
    pcall(function() absoluteMax = Bank:getManualLoanMaxPrincipal() or absoluteMax end)
    if currentMax <= 0 then currentMax = absoluteMax end

    local approvalChance = math.floor(tonumber(quote.approvalChance) or 0)
    local requiredStreetCred = math.floor(tonumber(quote.requiredStreetCred) or 1)
    local approvalRisk = tostring(quote.approvalRiskLabel or "HIGH")
    local approvalRiskColor = self:getApprovalRiskColor(approvalRisk)
    local financeCharge = math.max(math.floor((tonumber(quote.totalDue) or 0) - (tonumber(quote.principal) or requestedAmount)), 0)

    local approvalStatus = "ENTER AMOUNT"
    local approvalDetail = "Enter a request amount to preview APR, risk, and payment terms."
    local approvalColor = color.dim
    local canSubmit = false
    if requestedAmount > absoluteMax then
        approvalStatus = "ABOVE LOAN CAP"
        approvalDetail = "Maximum personal-loan request: E$ " .. utils.formatNumber(absoluteMax) .. "."
        approvalRisk = "HIGH"
        approvalRiskColor = color.red
        approvalChance = 0
        approvalColor = accent
    elseif requestedAmount > 0 and approvalChance <= 0 then
        approvalStatus = "HIGH RISK"
        approvalDetail = "This request requires Credit Level " .. tostring(requiredStreetCred) .. " or stronger approval factors."
        approvalRisk = "HIGH"
        approvalRiskColor = color.red
        approvalColor = color.gold or accent
    elseif requestedAmount > 0 then
        approvalStatus = "REVIEW READY"
        approvalDetail = "Estimated approval chance: " .. tostring(approvalChance) .. "%  •  Required credit: " .. tostring(requiredStreetCred) .. "."
        approvalColor = color.brandWhite or color.white
        canSubmit = true
    end

    local strip = self:makePanel(self.contentCanvas, 80, 470, 2800, 170)
    marmurText(strip, "LOAN SERVICES", 40, 10, 1160, 70, 50, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(strip, "Request a personal loan and review the complete estimate before submitting.",
        42, 82, 1180, 60, 27, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)
    self:drawHeaderStat(strip, "Credit Level", tostring(streetCred), 1570, 28, color.white, 330, 23, 38)
    self:drawHeaderStat(strip, "Checking", "E$ " .. utils.formatNumber(data.wallet or 0), 1940, 28, color.white, 420, 23, 36)
    self:drawHeaderStat(strip, "Loan Balance", "E$ " .. utils.formatNumber(loan.balanceDue or 0), 2400, 28, color.dim, 360, 23, 36)

    local left = self:makePanel(self.contentCanvas, 80, 660, 1360, 810)
    local right = self:makePanel(self.contentCanvas, 1480, 660, 1400, 810)

    marmurText(left, "REQUEST A LOAN", 40, 8, 1280, 58, 40, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(left, "Choose the amount, payment frequency, and term. Each control has its own fixed row.",
        42, 62, 1270, 48, 23, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local amountPanel = self:makePanel(left, 40, 118, 1280, 118)
    marmurCenteredText(amountPanel, "REQUESTED LOAN AMOUNT", 22, 8, 760, 34, 22, color.dim, false)
    local customLabel = self:getCustomAmountLabel("loanrequest")
    marmurCenteredText(amountPanel, customLabel, 22, 40, 760, 66, (#customLabel >= 18) and 38 or 48,
        requestedAmount > absoluteMax and accent or (color.brandWhite or color.white), true, "Medium")
    marmurCenteredText(amountPanel, "CURRENT CREDIT CEILING", 820, 8, 420, 34, 21, color.dim, false)
    marmurCenteredText(amountPanel, "E$ " .. utils.formatNumber(currentMax), 820, 40, 420, 66, 31,
        color.brandWhite or color.white, true)

    marmurText(left, "PAYMENT FREQUENCY", 40, 246, 1280, 38, 25, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    local function frequencyButton(label, value, x)
        local selected = selectedFrequency == value
        self:createTransferKey(left, label, x, 288, 410, 70, function() self:setLoanPaymentFrequency(value) end, {
            borderColor = selected and accent or color.dim,
            textColor = selected and (color.brandWhite or color.white) or color.brandWhiteSoft,
            hoverColor = color.brandWhite or color.white,
            fontSize = 27,
            fillOpacity = selected and 0.72 or 0.46,
        })
    end
    frequencyButton("Weekly", "weekly", 40)
    frequencyButton("Biweekly", "biweekly", 475)
    frequencyButton("Monthly", "monthly", 910)

    marmurText(left, "TERM LENGTH", 40, 366, 1280, 38, 25, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    self:createTransferKey(left, "-12", 40, 408, 180, 66, function() self:adjustLoanTermMonths(-12) end, {
        borderColor = color.dim, textColor = color.white, hoverColor = accent, fontSize = 26, fillOpacity = 0.44,
    })
    self:createTransferKey(left, "-1", 240, 408, 160, 66, function() self:adjustLoanTermMonths(-1) end, {
        borderColor = color.dim, textColor = color.white, hoverColor = accent, fontSize = 26, fillOpacity = 0.44,
    })
    self:createTransferKey(left, tostring(selectedTermMonths) .. " MONTHS", 420, 408, 520, 66, nil, {
        static = true, borderColor = accent, textColor = accent, fontSize = 29, fillOpacity = 0.66,
    })
    self:createTransferKey(left, "+1", 960, 408, 160, 66, function() self:adjustLoanTermMonths(1) end, {
        borderColor = color.dim, textColor = color.white, hoverColor = accent, fontSize = 26, fillOpacity = 0.44,
    })
    self:createTransferKey(left, "+12", 1140, 408, 180, 66, function() self:adjustLoanTermMonths(12) end, {
        borderColor = color.dim, textColor = color.white, hoverColor = accent, fontSize = 26, fillOpacity = 0.44,
    })

    marmurText(left, "NUMERIC KEYPAD", 40, 482, 1280, 30, 25, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    self:buildAmountKeypad(left, "loanrequest", accent, {
        x = 40,
        y = 518,
        keyW = 295,
        keyH = 48,
        gapX = 15,
        gapY = 6,
        numberFontSize = 30,
        controlFontSize = 24,
        fillOpacity = 0.72,
    })

    local helperText = errorText ~= ""
        and errorText
        or "APR locks when the request is submitted. Decisions post in 2–4 business hours."
    marmurText(left, helperText, 40, 740, 1280, 52, 21,
        errorText ~= "" and (color.gold or accent) or color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    marmurText(right, "LOAN ESTIMATE & ELIGIBILITY", 40, 8, 1320, 58, 40, color.cyan,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    marmurText(right, "Review the quote below. Nothing posts until the request is submitted.",
        42, 62, 1300, 48, 23, color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    local statusPanel = self:makePanel(right, 40, 118, 1320, 126)
    marmurCenteredText(statusPanel, approvalStatus, 22, 12, 400, 102, 31, approvalColor, true, "Medium")
    marmurText(statusPanel, approvalDetail, 450, 12, 840, 102, 24, color.brandWhite or color.white,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, true)

    marmurMetricCard(right, "REQUESTED", "E$ " .. utils.formatNumber(requestedAmount), 40, 260, 620, 140,
        color.brandWhite or color.white, 38, "Personal loan principal", color.dim)
    marmurMetricCard(right, "APPROVAL RISK", approvalRisk, 700, 260, 660, 140,
        requestedAmount > 0 and approvalRiskColor or color.dim, approvalRisk == "MODERATE" and 34 or 42,
        requestedAmount > 0 and (tostring(approvalChance) .. "% estimated approval") or "Enter an amount", color.dim)

    local terms = self:makePanel(right, 40, 416, 1320, 220)
    marmurText(terms, "PROJECTED TERMS", 26, 8, 1268, 42, 27, color.dim,
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false)
    local columns = {
        { "LOCKED APR", self:loanRateLabel(quote.interestBasisPoints or 0), color.green or color.white },
        { "TERM", tostring(quote.termMonths or selectedTermMonths) .. " months", color.white },
        { "SCHEDULE", tostring(quote.frequencyLabel or self:getLoanPaymentFrequencyLabel(selectedFrequency)) .. " / " .. tostring(quote.termPayments or 0), color.white },
        { "EST. PAYMENT", "E$ " .. utils.formatNumber(quote.installment or 0), color.cyan or color.white },
        { "EST. TOTAL DUE", "E$ " .. utils.formatNumber(quote.totalDue or 0), accent },
    }
    local cellW = 246
    local cellGap = 10
    local cellX = 24
    for _, item in ipairs(columns) do
        marmurCenteredText(terms, item[1], cellX, 62, cellW, 38, 20, color.dim, true)
        marmurCenteredText(terms, item[2], cellX, 102, cellW, 82, 27, item[3], true, "Medium")
        cellX = cellX + cellW + cellGap
    end

    local notice = self:makePanel(right, 40, 652, 1320, 70)
    marmurCenteredText(notice,
        "Finance charge: E$ " .. utils.formatNumber(financeCharge) .. "  •  Auto-debit is required after funding.",
        20, 4, 1280, 62, 23, requestedAmount > 0 and color.dim or (color.gold or color.dim), true)

    local submitCallback = canSubmit and function() self:submitCustomAmount("loanrequest", data) end or nil
    self:createTransferAction(right, "SUBMIT LOAN REQUEST", 40, 738, 1320, 66, submitCallback, canSubmit)
end


local function marmurCreatePolishedSidebarItem(self, parent, labelText, y, callback, active, opts)
    opts = opts or {}
    local x = math.floor(tonumber(opts.x) or 18)
    local w = math.floor(tonumber(opts.width) or 324)
    local h = math.floor(tonumber(opts.height) or 62)
    local fontSize = math.floor(tonumber(opts.fontSize) or 37)

    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local borderTint = active and (color.brandRedBright or color.red) or (color.brandWhiteSoft or color.white)
    local border = ink.rect(0, 0, w, h, borderTint)
    border:SetOpacity(active and 0.66 or 0.13)
    border:Reparent(holder, -1)

    local fillTint = active and (color.brandRed or color.red) or (color.brandPanel3 or color.panel2)
    local fill = ink.rect(2, 2, math.max(w - 4, 2), math.max(h - 4, 2), fillTint)
    fill:SetOpacity(active and 0.34 or 0.48)
    fill:Reparent(holder, -1)

    local accent = ink.rect(2, 2, active and 7 or 3, math.max(h - 4, 2), color.brandRedBright or color.red)
    accent:SetOpacity(active and 0.98 or 0.34)
    accent:Reparent(holder, -1)

    local topHighlight = ink.rect(10, 2, math.max(w - 12, 2), 1, active and (color.brandRedBright or color.red) or (color.brandWhiteSoft or color.white))
    topHighlight:SetOpacity(active and 0.32 or 0.06)
    topHighlight:Reparent(holder, -1)

    local marker = ink.rect(26, math.floor((h - 12) / 2), 12, 12,
        active and (color.brandWhite or color.white) or (color.brandRedSoft or color.red))
    marker:SetOpacity(active and 1.0 or 0.72)
    marker:Reparent(holder, -1)

    local text = marmurText(holder, labelText, 56, 0, w - 76, h, fontSize,
        active and (color.brandWhite or color.white) or (color.brandWhiteSoft or color.white),
        textHorizontalAlignment.Left, textVerticalAlignment.Center, false, "Medium")

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)

    if callback then
        self:addSubscriber(hotspot, {
            hoverIn = function()
                border:SetTintColor(color.brandRedBright or color.red)
                border:SetOpacity(0.82)
                fill:SetTintColor(active and (color.brandRed or color.red) or (color.brandPanel2 or color.panel2))
                fill:SetOpacity(active and 0.42 or 0.72)
                accent:SetOpacity(1.0)
                marker:SetTintColor(color.brandWhite or color.white)
                marker:SetOpacity(1.0)
                text:SetTintColor(color.brandWhite or color.white)
            end,
            hoverOut = function()
                border:SetTintColor(borderTint)
                border:SetOpacity(active and 0.66 or 0.13)
                fill:SetTintColor(fillTint)
                fill:SetOpacity(active and 0.34 or 0.48)
                accent:SetOpacity(active and 0.98 or 0.34)
                marker:SetTintColor(active and (color.brandWhite or color.white) or (color.brandRedSoft or color.red))
                marker:SetOpacity(active and 1.0 or 0.72)
                text:SetTintColor(active and (color.brandWhite or color.white) or (color.brandWhiteSoft or color.white))
            end,
            click = function()
                utils.playSound("ui_menu_onpress", 1)
                callback()
            end,
        })
    end

    return holder
end

local function marmurCreatePolishedPartnerButton(self, parent, labelText, x, y, w, h, callback, active)
    local holder = ink.canvas(x, y, inkEAnchor.TopLeft)
    holder:SetSize(Vector2.new({ X = w, Y = h }))
    holder:Reparent(parent, -1)

    local idleBorderTint = color.brandWhiteSoft or color.white
    local idleFillTint = color.brandPanel3 or color.panel2
    local idleTextTint = color.brandWhiteSoft or color.white
    local idleAccentTint = active and (color.brandRedBright or color.red) or (color.brandWhiteSoft or color.white)

    local border = ink.rect(0, 0, w, h, idleBorderTint)
    border:SetOpacity(active and 0.30 or 0.20)
    border:Reparent(holder, -1)

    local fill = ink.rect(2, 2, math.max(w - 4, 2), math.max(h - 4, 2), idleFillTint)
    fill:SetOpacity(active and 0.74 or 0.66)
    fill:Reparent(holder, -1)

    local accent = ink.rect(2, 2, 7, math.max(h - 4, 2), idleAccentTint)
    accent:SetOpacity(active and 0.82 or 0.22)
    accent:Reparent(holder, -1)

    local labelFontSize = #tostring(labelText or "") > 18 and 23 or 31
    local text = marmurCenteredText(holder, labelText, 16, 0, math.max(w - 32, 20), h, labelFontSize,
        idleTextTint, false, "Medium")

    local hotspot = ink.rect(0, 0, w, h, color.white)
    hotspot:SetOpacity(0.01)
    hotspot:Reparent(holder, -1)
    self:addSubscriber(hotspot, {
        hoverIn = function()
            border:SetTintColor(color.brandRedBright or color.red)
            border:SetOpacity(0.92)
            fill:SetTintColor(color.brandRed or color.red)
            fill:SetOpacity(0.38)
            accent:SetTintColor(color.brandRedBright or color.red)
            accent:SetOpacity(1.0)
            text:SetTintColor(color.brandWhite or color.white)
        end,
        hoverOut = function()
            border:SetTintColor(idleBorderTint)
            border:SetOpacity(active and 0.30 or 0.20)
            fill:SetTintColor(idleFillTint)
            fill:SetOpacity(active and 0.74 or 0.66)
            accent:SetTintColor(idleAccentTint)
            accent:SetOpacity(active and 0.82 or 0.22)
            text:SetTintColor(idleTextTint)
        end,
        click = function()
            utils.playSound("ui_menu_onpress", 1)
            callback()
        end,
    })

    return holder
end

function shell:createHomeSidebarItem(parent, labelText, y, callback, active)
    local homeLayout = tostring(self.activePage or "") == "home"
    return marmurCreatePolishedSidebarItem(self, parent, labelText, y, callback, active, {
        x = 18,
        width = 324,
        height = homeLayout and 66 or 62,
        fontSize = homeLayout and 38 or 40,
    })
end

function shell:buildAuthenticatedSidebar()
    local sidebar = ink.canvas(0, 300, inkEAnchor.TopLeft)
    sidebar:SetSize(Vector2.new({ X = 360, Y = 1030 }))
    sidebar:Reparent(self.contentCanvas, -1)

    local sidebarBg = ink.rect(0, 0, 360, 1030, color.brandPanel or color.panel)
    sidebarBg:SetOpacity(0.90)
    sidebarBg:Reparent(sidebar, -1)

    local innerRule = ink.rect(16, 0, 1, 1030, color.brandWhiteSoft or color.white)
    innerRule:SetOpacity(0.035)
    innerRule:Reparent(sidebar, -1)

    local divider = ink.rect(358, 0, 2, 1030, color.brandRed or color.red)
    divider:SetOpacity(0.38)
    divider:Reparent(sidebar, -1)

    local active = self:getSidebarSection()
    local navY = 18
    local step = 68
    self:createHomeSidebarItem(sidebar, "Home",        navY + (step * 0), function() self:renderPage("home") end, active == "home")
    self:createHomeSidebarItem(sidebar, "Activity",    navY + (step * 1), function() self:renderPage("transactions") end, active == "activity")
    self:createHomeSidebarItem(sidebar, "Analytics",   navY + (step * 2), function() self:renderPage("insights") end, active == "analytics")
    self:createHomeSidebarItem(sidebar, "Deposit",     navY + (step * 3), function() self:renderPage("deposit") end, active == "deposit")
    self:createHomeSidebarItem(sidebar, "Withdraw",    navY + (step * 4), function() self:renderPage("withdraw") end, active == "withdraw")
    self:createHomeSidebarItem(sidebar, "Loans",       navY + (step * 5), function() self:renderPage("loans") end, active == "loans")
    self:createHomeSidebarItem(sidebar, "Services",    navY + (step * 6), function() self:renderPage("services") end, active == "services")
    self:createHomeSidebarItem(sidebar, "Disclosures", navY + (step * 7), function() self:renderPage("disclosures") end, active == "disclosures")
    self:createHomeSidebarItem(sidebar, "Logout",      navY + (step * 8), function() self:logout() end, false)

    local partnerRule = ink.rect(28, 650, 304, 2, color.brandRed or color.red)
    partnerRule:SetOpacity(0.34)
    partnerRule:Reparent(sidebar, -1)
    marmurCenteredText(sidebar, "MARMUR PARTNER PORTAL", 24, 664, 312, 34, 21,
        color.brandWhiteSoft or color.white, false, "Medium")

    local teaserActive = active == "anodos"
    local partnerLabel = teaserActive and "RETURN TO MARMUR" or "GO TO ANODOS FINANCIAL"
    marmurCreatePolishedPartnerButton(self, sidebar, partnerLabel, 18, 708, 324, 74, function()
        if teaserActive then
            self:renderPage("home")
        else
            self:openAnodosPartnerPortal()
        end
    end, teaserActive)

    local footerLine = ink.rect(28, 832, 304, 2, color.brandWhite or color.white)
    footerLine:SetOpacity(0.10)
    footerLine:Reparent(sidebar, -1)
    marmurText(sidebar, "© 2077 MARMUR BANK\nALL RIGHTS RESERVED.", 38, 852, 284, 110, 22,
        color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true, "Medium")
end

local _marmurV2163HomeFrameBase = _marmurV216OriginalBuildHomeFrame or shell.buildHomeFrame
function shell:buildHomeFrame()
    _marmurV2163HomeFrameBase(self)

    local partnerRule = ink.rect(28, 768, 304, 2, color.brandRed or color.red)
    partnerRule:SetOpacity(0.34)
    partnerRule:Reparent(self.contentCanvas, -1)
    marmurCenteredText(self.contentCanvas, "MARMUR PARTNER PORTAL", 24, 782, 312, 34, 21,
        color.brandWhiteSoft or color.white, false, "Medium")

    marmurCreatePolishedPartnerButton(self, self.contentCanvas, "GO TO ANODOS FINANCIAL", 18, 826, 324, 76, function()
        self:openAnodosPartnerPortal()
    end, false)

    local footerLine = ink.rect(28, 952, 304, 2, color.brandWhite or color.white)
    footerLine:SetOpacity(0.10)
    footerLine:Reparent(self.contentCanvas, -1)
    marmurText(self.contentCanvas, "© 2077 MARMUR BANK\nALL RIGHTS RESERVED.", 38, 974, 284, 106, 22,
        color.dim, textHorizontalAlignment.Left, textVerticalAlignment.Center, true, "Medium")
end

return shell
