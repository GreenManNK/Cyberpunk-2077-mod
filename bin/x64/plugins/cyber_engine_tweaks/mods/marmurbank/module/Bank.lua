local GameSettings = require("external/GameSettings")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")
local Calendar = require("module/Calendar")

local VANGUARD_AUTO_FINANCE_API_VERSION = 3

MB_DEPOSIT = "bank_deposit"
MB_PREVINC = "bank_previous_income"
MB_BALANCE_BACKUP = "marmur_bank_balance_backup"
MB_BALANCE_MIGRATION_VERSION = "marmur_bank_balance_migration_version"
MB_BALANCE_MIGRATION_CURRENT = 1
MB_ACCOUNT_OPEN = "marmur_account_open"
MB_ACCOUNT_LAST_CLOSED_DAY = "marmur_account_last_closed_day"
MB_ACCOUNT_EVER_OPENED = "marmur_account_ever_opened"
MB_ACCOUNT_OPEN_MINUTE = "marmur_account_open_minute"
MB_ACCOUNT_OPEN_INCENTIVE = "marmur_account_open_incentive"
MB_ACCOUNT_INCENTIVE_PENDING = "marmur_account_incentive_pending"
MB_ACCOUNT_INCENTIVE_ELIGIBLE_MINUTE = "marmur_account_incentive_eligible_minute"
MB_ACCOUNT_INCENTIVE_PAID = "marmur_account_incentive_paid"
MB_ACCOUNT_INCENTIVE_PAID_AMOUNT = "marmur_account_incentive_paid_amount"
MB_ACCOUNT_INCENTIVE_PAID_MINUTE = "marmur_account_incentive_paid_minute"
MB_ACCOUNT_INCENTIVE_CHARGED_BACK = "marmur_account_incentive_charged_back"
MB_ACCOUNT_NUMBER_LEFT = "marmur_account_number_left"
MB_ACCOUNT_NUMBER_RIGHT = "marmur_account_number_right"
MB_ACCOUNT_WELCOME_THREAD_READY = "marmur_account_welcome_thread_ready"
MB_AUTO_DEPOSIT_ACTIVE = "marmur_auto_deposit_active"
MB_AUTO_DEPOSIT_AMOUNT = "marmur_auto_deposit_amount"
MB_AUTO_DEPOSIT_INTERVAL_DAYS = "marmur_auto_deposit_interval_days"
MB_AUTO_DEPOSIT_NEXT_STAMP = "marmur_auto_deposit_next_stamp"
MB_AUTO_DEPOSIT_LAST_STAMP = "marmur_auto_deposit_last_stamp"
MB_AUTO_DEPOSIT_LAST_STATUS = "marmur_auto_deposit_last_status"
MB_CASHBACK_DESTINATION = "marmur_cashback_destination"
MB_CASHBACK_TOTAL_EARNED = "marmur_cashback_total_earned"
MB_CASHBACK_TOTAL_SPEND = "marmur_cashback_total_spend"
MB_CASHBACK_LAST_EARNED = "marmur_cashback_last_earned"
MB_CASHBACK_LAST_SPEND = "marmur_cashback_last_spend"
MB_CASHBACK_LAST_RATE_BP = "marmur_cashback_last_rate_bp"
MB_CASHBACK_LAST_DESTINATION = "marmur_cashback_last_destination"
MB_CASHBACK_PENDING_EARNED = "marmur_cashback_pending_earned"
MB_CASHBACK_PENDING_SPEND = "marmur_cashback_pending_spend"
MB_CASHBACK_NEXT_PAYOUT_STAMP = "marmur_cashback_next_payout_stamp"
MB_CASHBACK_LAST_PAYOUT_STAMP = "marmur_cashback_last_payout_stamp"
MB_CASHBACK_LAST_PAYOUT_SPEND = "marmur_cashback_last_payout_spend"
MB_CASHBACK_PAYOUT_INTERVAL_DAYS = 7
MB_CASHBACK_PAYOUT_HOUR = 15
MB_CASHBACK_PAYOUT_MINUTE = 0

MB_LOYALTY_SCHEMA_VERSION = 1
MB_LOYALTY_WINDOW_DAYS = 7
MB_LOYALTY_RETENTION_PERCENT = 75
MB_LOYALTY_GRACE_DAYS = 3
MB_LOYALTY_VERSION_FACT = "marmur_loyalty_schema_version"
MB_LOYALTY_INITIALIZED = "marmur_loyalty_initialized"
MB_LOYALTY_ACTIVE_TIER = "marmur_loyalty_active_tier"
MB_LOYALTY_GRANDFATHERED = "marmur_loyalty_grandfathered"
MB_LOYALTY_RISK_START_DAY = "marmur_loyalty_risk_start_day"
MB_LOYALTY_LAST_CHANGE_DAY = "marmur_loyalty_last_change_day"
MB_LOYALTY_LAST_SAMPLE_DAY = "marmur_loyalty_last_sample_day"
MB_LOYALTY_LAST_BALANCE = "marmur_loyalty_last_balance"
MB_LOYALTY_SAMPLE_COUNT = "marmur_loyalty_sample_count"
MB_LOYALTY_AVERAGE_BALANCE = "marmur_loyalty_average_balance"
MB_LOYALTY_MIN_BALANCE = "marmur_loyalty_min_balance"
MB_LOYALTY_QUALIFIED_TIER = "marmur_loyalty_qualified_tier"
MB_LOYALTY_PENDING_DOWNGRADE_TIER = "marmur_loyalty_pending_downgrade_tier"
MB_LOYALTY_LAST_SYNC_DAY = "marmur_loyalty_last_sync_day"

MB_LOYALTY_TIERS = {
	{ index = 0, name = "Standard", threshold = 0, cashbackBp = 100, interestBp = 1 },
	{ index = 1, name = "Preferred", threshold = 25000, cashbackBp = 200, interestBp = 2 },
	{ index = 2, name = "Premier", threshold = 100000, cashbackBp = 300, interestBp = 3 },
	{ index = 3, name = "Private Client", threshold = 250000, cashbackBp = 400, interestBp = 4 },
	{ index = 4, name = "Obsidian Client", threshold = 1000000, cashbackBp = 500, interestBp = 5 },
}

local function loyaltySampleKey(field, slot)
	return "marmur_loyalty_sample_" .. tostring(field) .. "_" .. tostring(slot)
end

MB_WALLET_LEDGER_BASELINE = "marmur_wallet_ledger_baseline"
MB_WALLET_LEDGER_BASELINE_SET = "marmur_wallet_ledger_baseline_set"
MB_WALLET_LEDGER_BASELINE_STAMP = "marmur_wallet_ledger_baseline_stamp"
MB_WALLET_LEDGER_AUDIT_SEQ = "marmur_wallet_ledger_audit_seq"

MB_VANGUARD_SETTLEMENT_PENDING = "marmur_vanguard_settlement_pending"
MB_VANGUARD_SETTLEMENT_CLAIM = "marmur_vanguard_settlement_claim"
MB_VANGUARD_SETTLEMENT_TOTAL = "marmur_vanguard_settlement_total"
MB_VANGUARD_SETTLEMENT_BANK_PAYMENT = "marmur_vanguard_settlement_bank_payment"
MB_VANGUARD_SETTLEMENT_PLAYER_DEPOSIT = "marmur_vanguard_settlement_player_deposit"
MB_VANGUARD_SETTLEMENT_WALLET_BEFORE = "marmur_vanguard_settlement_wallet_before"
MB_VANGUARD_SETTLEMENT_WALLET_AFTER = "marmur_vanguard_settlement_wallet_after"
MB_VANGUARD_SETTLEMENT_CONTRACT = "marmur_vanguard_settlement_contract"
MB_VANGUARD_SETTLEMENT_REASON = "marmur_vanguard_settlement_reason"
MB_VANGUARD_SETTLEMENT_LAST_CLAIM = "marmur_vanguard_settlement_last_claim"
MB_ANALYTICS_VANGUARD_FINANCE_CURSOR = "marmur_analytics_vanguard_finance_cursor"
MB_ANALYTICS_CLASSIFICATION_REVISION = "marmur_analytics_classification_revision"

MB_SPEND_SUBJECT = {
	uncategorized = 0,
	food_drinks = 1,
	clothing = 2,
	cyberware = 3,
	weapons_ammo = 4,
	medical = 5,
	software = 6,
	crafting = 7,
	vehicles = 8,
	insurance = 9,
	real_estate = 10,
	transportation = 11,
	loans = 12,
	services = 13,
	entertainment = 14,
	other = 15,
}

MB_SPEND_PROVENANCE = {
	legacy = 0,
	wallet = 1,
	item = 2,
	partner = 3,
	service = 4,
	external = 5,
}

BANK_LOCATION_HOURS = {
	atm = { open = 0.0, close = 24.0 },
	banker = { open = 9.0, close = 17.5 },
	branch = { open = 9.0, close = 18.0 }
}

BANK = {}

function BANK:new()
	local o = {}
	o.SPAWN = nil
	o.hub = nil
	o.hubId = nil
	o.prevC = 1
	o.tranAmount = 2
	o.atmDistance = 1.65
	o.atmFontSize = 65
	o.interestRate = 0.01
	o.termOfIncome = 2
	o.depTbl = {}
	o.drwTbl = {}
	o.currentTime = 0
	o.nextCheckTime = 0
	o.lastUnifiedBalance = 0
	o.lastWalletSnapshot = -1
	o.lastWalletReadValid = false
	o.lastWalletReadSource = ""
	o.lastWalletUnreadableSince = 0
	o.localWalletDebitSuppressionAmount = 0
	o.walletLedgerAuditEnabled = false
	o.walletLedgerLastAuditTime = 0
	o.cachedTrustedWalletBaseline = nil
	o.cachedTrustedWalletBaselineSet = false
	o.cachedTrustedWalletBaselineStamp = 0
	o.walletSessionPrimed = false
	o.walletSessionPrimeCandidate = -1
	o.walletSessionPrimeCandidateTime = 0
	o.nextWalletSpendCheckTime = 0
	o.pendingWalletSpendAmount = 0
	o.pendingWalletSpendBefore = 0
	o.pendingWalletSpendAfter = 0
	o.pendingWalletSpendFlushTime = 0
	o.pendingWalletSpendLastChangeTime = 0
	o.lastPlayerMoneyRemovalTime = 0
	o.lastPlayerMoneyRemovalAmount = 0
	o.lastPlayerMoneyRemovalWalletAfter = -1
	o.lastPlayerMoneyRemovalSource = ""
	o.fraudBurstAmount = 0
	o.fraudBurstBefore = 0
	o.fraudBurstAfter = 0
	o.fraudBurstLastChangeTime = 0
	o.fraudBurstNotified = false
	o.lastFraudAlertScreenTime = 0
	o.lastFraudAlertScreenAmount = 0
	o.lastTheftAlertScreenTime = 0
	o.lastTheftAlertScreenAmount = 0
	o.pendingWalletSpendContext = "purchase"
	o.walletContextMenuOpen = false
	o.walletContextLastEvent = ""
	o.walletContextChangedAt = 0
	o.walletContextRecentlyClosedUntil = 0
	o.branchNpcGuardArmedCached = false
	o.branchNpcGuardArmedUntil = 0
	o.theftDetectionWindowUntil = 0
	o.theftDetectionReason = ""
	o.lastAccessType = nil
	o.lastAccessIndex = 0
	o.lastLoanBalance = 0
	o.lastKnownStreetCred = nil
	o.lastLoanConfirmationCode = ""
	o.loanConfirmationSeeded = false
	o.lastLoanReviewNoticeDay = -1
	o.nextPhoneContactCheckTime = 0
	o.nextVanguardAutoNoticeCheckTime = 0
	o.nextVanguardAutoPendingNoticeCheckTime = 0
	o.nextVanguardAutoServiceTime = 0
	o.nextVanguardSettlementCheckTime = 0
	o.nextPassiveTimerUpdateTime = 0
	o.loyaltySyncInProgress = false
	o.nextLoyaltySyncTime = 0
	o.nextDisputeTimerCheckTime = 0
	o.nextLoanReviewSyncTime = 0
	o.nextJohnnyFactCheckTime = 0
	o.nextJohnnyMaintainTime = 0
	o.cachedJohnnyFactSuppressed = false
	o._locationPosCacheReady = false
	o._atmPosCache = nil
	o._branchPosCache = nil
	o._branchFrontPosCache = nil
	o._branchInteriorSidePosCache = nil
	o._branchNpcGuardRegistered = false
	o.johnnySuppressed = false
	o.atmKeypad = nil
	o.atmKeypadDismissedIndex = 0
	o.atmKeypadKeybindName = "Marmur ATM"
	o.cachedUnifiedSystem = nil
	o.nextUnifiedSystemLookupTime = 0
	o.cachedVanguardAutoSystem = nil
	o.nextVanguardAutoSystemLookupTime = 0
	o.cachedCurrentHourValue = nil
	o.cachedCurrentHourUntil = 0
	o.cachedHalfHourBucket = nil
	o.cachedHalfHourUntil = 0
	o.cachedTransactionSystem = nil
	o.cachedQuestSystem = nil
	o.nextQuestSystemLookupTime = 0
	o.cachedMoneyTDBID = nil
	o.cachedMoneyItemID = nil
	o.cachedAccountReadyValue = nil
	o.cachedAccountReadyUntil = 0
	o.cachedAutoLoans = nil
	o.cachedAutoLoansUntil = 0
	o.cachedHomeBalanceHistory = nil
	o.cachedHomeBalanceHistoryRevision = ""
	o.cachedHomeBalanceHistoryUntil = 0
	self.__index = self
	return setmetatable(o, self)
end

function BANK:clearRuntimeCaches()
	if self.atmKeypad and self.atmKeypad.isActive and self.atmKeypad:isActive() then
		pcall(function() self.atmKeypad:hide() end)
		self.hub = nil
		self.hubId = nil
	end
	self.lastWalletSnapshot = -1
	self.lastWalletReadValid = false
	self.lastWalletReadSource = ""
	self.lastWalletUnreadableSince = 0
	self.localWalletDebitSuppressionAmount = 0
	self.cachedTrustedWalletBaseline = nil
	self.cachedTrustedWalletBaselineSet = false
	self.cachedTrustedWalletBaselineStamp = 0
	self.walletSessionPrimed = false
	self.walletSessionPrimeCandidate = -1
	self.walletSessionPrimeCandidateTime = 0
	self.nextWalletSpendCheckTime = 0
	self.pendingWalletSpendAmount = 0
	self.pendingWalletSpendBefore = 0
	self.pendingWalletSpendAfter = 0
	self.pendingWalletSpendFlushTime = 0
	self.pendingWalletSpendLastChangeTime = 0
	self.pendingWalletSpendContext = "purchase"
	self.lastPlayerMoneyRemovalTime = 0
	self.lastPlayerMoneyRemovalAmount = 0
	self.lastPlayerMoneyRemovalWalletAfter = -1
	self.lastPlayerMoneyRemovalSource = ""
	self.fraudBurstAmount = 0
	self.fraudBurstBefore = 0
	self.fraudBurstAfter = 0
	self.fraudBurstLastChangeTime = 0
	self.fraudBurstNotified = false
	self.cachedUnifiedSystem = nil
	self.nextUnifiedSystemLookupTime = 0
	self.cachedVanguardAutoSystem = nil
	self.nextVanguardAutoSystemLookupTime = 0
	self.cachedCurrentHourValue = nil
	self.cachedCurrentHourUntil = 0
	self.cachedHalfHourBucket = nil
	self.cachedHalfHourUntil = 0
	self.cachedTransactionSystem = nil
	self.cachedQuestSystem = nil
	self.nextQuestSystemLookupTime = 0
	self.cachedMoneyTDBID = nil
	self.cachedMoneyItemID = nil
	self.cachedAccountReadyValue = nil
	self.cachedAccountReadyUntil = 0
	self.cachedAutoLoans = nil
	self.cachedAutoLoansUntil = 0
	self.cachedHomeBalanceHistory = nil
	self.cachedHomeBalanceHistoryRevision = ""
	self.cachedHomeBalanceHistoryUntil = 0
	self.branchNpcGuardArmedCached = false
	self.branchNpcGuardArmedUntil = 0
	self.nextPassiveTimerUpdateTime = 0
	self.nextVanguardAutoServiceTime = 0
	self.loyaltySyncInProgress = false
	self.nextLoyaltySyncTime = 0
end

function BANK:initialize(SPAWN)
	self.SPAWN = SPAWN
	self.prevC = 1
	self.depTbl = {}
	self.drwTbl = {}
	self.currentTime = 0
	self.nextCheckTime = 0
	self.lastUnifiedBalance = 0
	self.lastWalletSnapshot = -1
	self.lastWalletReadValid = false
	self.lastWalletReadSource = ""
	self.lastWalletUnreadableSince = 0
	self.localWalletDebitSuppressionAmount = 0
	self.walletLedgerAuditEnabled = false
	self.walletLedgerLastAuditTime = 0
	self.cachedTrustedWalletBaseline = nil
	self.cachedTrustedWalletBaselineSet = false
	self.cachedTrustedWalletBaselineStamp = 0
	self.walletSessionPrimed = false
	self.walletSessionPrimeCandidate = -1
	self.walletSessionPrimeCandidateTime = 0
	self.nextWalletSpendCheckTime = 0
	self.pendingWalletSpendAmount = 0
	self.pendingWalletSpendBefore = 0
	self.pendingWalletSpendAfter = 0
	self.pendingWalletSpendFlushTime = 0
	self.pendingWalletSpendLastChangeTime = 0
	self.lastPlayerMoneyRemovalTime = 0
	self.lastPlayerMoneyRemovalAmount = 0
	self.lastPlayerMoneyRemovalWalletAfter = -1
	self.lastPlayerMoneyRemovalSource = ""
	self.fraudBurstAmount = 0
	self.fraudBurstBefore = 0
	self.fraudBurstAfter = 0
	self.fraudBurstLastChangeTime = 0
	self.fraudBurstNotified = false
	self.lastFraudAlertScreenTime = 0
	self.lastFraudAlertScreenAmount = 0
	self.lastTheftAlertScreenTime = 0
	self.lastTheftAlertScreenAmount = 0
	self.pendingWalletSpendContext = "purchase"
	self.walletContextMenuOpen = false
	self.walletContextLastEvent = ""
	self.walletContextChangedAt = 0
	self.walletContextRecentlyClosedUntil = 0
	self.branchNpcGuardArmedCached = false
	self.branchNpcGuardArmedUntil = 0
	self.theftDetectionWindowUntil = 0
	self.theftDetectionReason = ""
	self.lastAccessType = nil
	self.lastAccessIndex = 0
	self.lastLoanBalance = 0
	self.lastKnownStreetCred = nil
	self.lastLoanConfirmationCode = ""
	self.loanConfirmationSeeded = false
	self.lastLoanReviewNoticeDay = -1
	self.nextPhoneContactCheckTime = 0
	self.nextVanguardAutoNoticeCheckTime = 0
	self.nextVanguardAutoPendingNoticeCheckTime = 0
	self.nextVanguardAutoServiceTime = 0
	self.nextVanguardSettlementCheckTime = 0
	self.nextDisputeTimerCheckTime = 0
	self.nextLoanReviewSyncTime = 0
	self.nextPassiveTimerUpdateTime = 0
	self.loyaltySyncInProgress = false
	self.nextLoyaltySyncTime = 0
	self.nextJohnnyFactCheckTime = 0
	self.nextJohnnyMaintainTime = 0
	self.cachedJohnnyFactSuppressed = false
	self._locationPosCacheReady = false
	self._atmPosCache = nil
	self._branchPosCache = nil
	self._branchFrontPosCache = nil
	self._branchInteriorSidePosCache = nil
	self._branchNpcGuardRegistered = false
	self.johnnySuppressed = false
	self.atmKeypadDismissedIndex = 0
	self.atmKeypadKeybindName = "Marmur ATM"
	self.cachedUnifiedSystem = nil
	self.nextUnifiedSystemLookupTime = 0
	self.cachedVanguardAutoSystem = nil
	self.nextVanguardAutoSystemLookupTime = 0
	self.cachedCurrentHourValue = nil
	self.cachedCurrentHourUntil = 0
	self.cachedHalfHourBucket = nil
	self.cachedHalfHourUntil = 0
	self.cachedTransactionSystem = nil
	self.cachedQuestSystem = nil
	self.nextQuestSystemLookupTime = 0
	self.cachedMoneyTDBID = nil
	self.cachedMoneyItemID = nil
	self.cachedAccountReadyValue = nil
	self.cachedAccountReadyUntil = 0
	self.cachedAutoLoans = nil
	self.cachedAutoLoansUntil = 0
	self.cachedHomeBalanceHistory = nil
	self.cachedHomeBalanceHistoryRevision = ""
	self.cachedHomeBalanceHistoryUntil = 0

	pcall(function()
		if _G and _G.MARMUR_WALLET_LEDGER_AUDIT == true then
			self.walletLedgerAuditEnabled = true
		end
	end)

	self.interactionUI = require("external/interactionUI")
	self.interactionUI.init()
	if self.interactionUI and self.interactionUI.setVanillaSuppressPredicate then
		self.interactionUI.setVanillaSuppressPredicate(function()
			return self:shouldSuppressClosedBranchDoorVanilla()
		end)
	end

	local okAtmKeypad, atmKeypad = pcall(require, "ui/ATMKeypad")
	if okAtmKeypad and atmKeypad then
		self.atmKeypad = atmKeypad
		self.atmKeypad:init(self)
	end

	self:_cacheLocationPositions()
	self:_registerClosedBranchNpcGuard()

	if self.interactionUI then
		self.isInitialized = true
	end

	if self:_loadTrustedWalletBaseline() == nil then
		local wallet, readable = self:_tryReadWalletBalance()
		if readable == true then
			self:_saveTrustedWalletBaseline(wallet, "initialize")
		end
	end
	pcall(function() self:initializeVanguardAnalyticsCursor() end)
	pcall(function() self:syncLoyaltyProgram(nil, true) end)
end

function BANK:_getNow(forceRefresh)
	local now = tonumber(self.currentTime or 0) or 0
	if forceRefresh == true or now <= 0 then
		now = os.clock()
		if now > 0 then self.currentTime = now end
	end
	return now
end

function BANK:_getMoneyItemID()
	if self.cachedMoneyItemID ~= nil then
		return self.cachedMoneyItemID
	end

	local ok, itemID = pcall(function()
		self.cachedMoneyTDBID = TweakDBID.new("Items.money")
		return ItemID.new(self.cachedMoneyTDBID)
	end)
	if ok and itemID ~= nil then
		self.cachedMoneyItemID = itemID
		return itemID
	end
	return nil
end

function BANK:_getCachedTransactionSystem()
	if self.cachedTransactionSystem ~= nil then
		return self.cachedTransactionSystem
	end

	local ok, system = pcall(function() return Game.GetTransactionSystem() end)
	if ok and system ~= nil then
		self.cachedTransactionSystem = system
		return system
	end
	return nil
end

function BANK:_invalidateAutoLoansCache()
	self.cachedAutoLoans = nil
	self.cachedAutoLoansUntil = 0
end

function BANK:_refreshAutoLoanSelection(loans)
	local selected = self:getVanguardAutoLoanDeepLinkIndex()
	for _, loan in ipairs(loans or {}) do
		loan.selected = math.floor(tonumber(loan.index) or 0) == selected
	end
	return loans or {}
end

function BANK:_isWalletAccountReady(forceRefresh)
	local now = self:_getNow(false)
	if forceRefresh ~= true and self.cachedAccountReadyValue ~= nil and now > 0 and now < (tonumber(self.cachedAccountReadyUntil or 0) or 0) then
		return self.cachedAccountReadyValue == true
	end

	local ready = false
	pcall(function()
		ready = self:isAccountOpen() and self:hasAccountEverOpened()
	end)
	self.cachedAccountReadyValue = ready == true
	if now > 0 then
		self.cachedAccountReadyUntil = now + (self.cachedAccountReadyValue and 2.00 or 3.00)
	else
		self.cachedAccountReadyUntil = 0
	end
	return self.cachedAccountReadyValue == true
end

function BANK:_distanceSquared(posA, posB)
	if posA == nil or posB == nil then return 999999999 end
	local dx = (tonumber(posA.x) or 0) - (tonumber(posB.x) or 0)
	local dy = (tonumber(posA.y) or 0) - (tonumber(posB.y) or 0)
	local dz = (tonumber(posA.z) or 0) - (tonumber(posB.z) or 0)
	return (dx * dx) + (dy * dy) + (dz * dz)
end

function BANK:getGameInstance()
	local ok, gameInstance = pcall(function()
		if GetGameInstance then
			return GetGameInstance()
		end
		return nil
	end)
	if ok and gameInstance then
		return gameInstance
	end

	ok, gameInstance = pcall(function()
		local player = Game.GetPlayer()
		if player and player.GetGame then
			return player:GetGame()
		end
		return nil
	end)
	if ok and gameInstance then
		return gameInstance
	end

	return nil
end

function BANK:getUnifiedSystem()
	if self.cachedUnifiedSystem ~= nil then
		return self.cachedUnifiedSystem
	end

	local now = os.clock()
	if now < (tonumber(self.nextUnifiedSystemLookupTime or 0) or 0) then
		return nil
	end

	local ok, system = pcall(function()
		local container = Game.GetScriptableSystemsContainer()
		if not container then
			return nil
		end
		return container:Get("NightCityBank.NCBankSystem")
	end)

	if ok and system then
		self.cachedUnifiedSystem = system
		self.nextUnifiedSystemLookupTime = 0
		return system
	end

	self.nextUnifiedSystemLookupTime = now + 1.00
	return nil
end


function BANK:getVanguardAutoSystem()
	if self.cachedVanguardAutoSystem ~= nil then
		return self.cachedVanguardAutoSystem
	end

	local now = os.clock()
	if now < (tonumber(self.nextVanguardAutoSystemLookupTime or 0) or 0) then
		return nil
	end

	local ok, system = pcall(function()
		if not Game or not Game.GetScriptableSystemsContainer then return nil end
		local container = Game.GetScriptableSystemsContainer()
		if not container then return nil end
		local byCName = nil
		pcall(function()
			if CName and CName.new then
				byCName = container:Get(CName.new("CarDealer.System.PurchasableVehicleSystem"))
			end
		end)
		if byCName then return byCName end
		return container:Get("CarDealer.System.PurchasableVehicleSystem")
	end)
	if ok and system then
		self.cachedVanguardAutoSystem = system
		self.nextVanguardAutoSystemLookupTime = 0
		return system
	end

	self.nextVanguardAutoSystemLookupTime = now + 1.00
	return nil
end


function BANK:getVanguardAutoLoanDeepLinkIndex()
	local idx = math.floor(tonumber(self.vanguardAutoLoanDeepLinkIndex or 0) or 0)
	if idx <= 0 then
		idx = self:_getQuestFactInt("marmur_vanguard_selected_contract")
	end
	if idx <= 0 then idx = 1 end
	return idx
end

function BANK:consumeExternalLoanDeepLink()
	local openLoans = self:_getQuestFactInt("marmur_vanguard_open_loans")
	if openLoans <= 0 then return false end
	local idx = self:_getQuestFactInt("marmur_vanguard_selected_contract")
	if idx <= 0 then idx = 1 end
	self.vanguardAutoLoanDeepLinkIndex = idx
	self:_setQuestFactInt("marmur_vanguard_open_loans", 0)
	return true
end

function BANK:setVanguardAutoFinanceIntegrationAvailable(available, system)
	local vanguardSystem = system or self:getVanguardAutoSystem()
	if not vanguardSystem then return false end

	local accepted = false
	local called = pcall(function()
		accepted = vanguardSystem:SetMarmurBankAutoFinanceIntegrationAvailable(
			available == true,
			VANGUARD_AUTO_FINANCE_API_VERSION
		) == true
	end)
	return called == true and accepted == (available == true)
end

function BANK:maintainVanguardAutoFinanceLease()
	local now = os.clock()
	if now < (tonumber(self.nextVanguardAutoLeaseHeartbeatTime or 0) or 0) then
		return self.cachedVanguardAutoSystem
	end
	self.nextVanguardAutoLeaseHeartbeatTime = now + 0.50

	local vanguardSystem = self:getVanguardAutoSystem()
	if vanguardSystem then
		self:setVanguardAutoFinanceIntegrationAvailable(self:_isWalletAccountReady(false), vanguardSystem)
	end
	return vanguardSystem
end

function BANK:_getVanguardAutoPayState(system, contractIndex)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if not system or idx <= 0 then return false, false end

	local readable, value = pcall(function()
		return system:GetActiveFinanceAutoPayEnabledAt(idx)
	end)
	if readable ~= true or type(value) ~= "boolean" then
		return false, false
	end
	return true, value == true
end

function BANK:_getVanguardAutoPayRequestSnapshot(contractIndex)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false, false end
	local known = self:_getQuestFactInt(self:_vanguardAutoNoticeKey("autopay_request_known", idx)) > 0
	local enabled = self:_getQuestFactInt(self:_vanguardAutoNoticeKey("autopay_request_enabled", idx)) > 0
	return known, enabled
end

function BANK:_captureVanguardAutoPayRequest(system, contractIndex, allowPosted)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false, false end

	local known, enabled = self:_getVanguardAutoPayRequestSnapshot(idx)
	if known then return true, enabled end
	if allowPosted ~= true and self:_getQuestFactInt(self:_vanguardAutoNoticeKey("posted", idx)) > 0 then
		return false, false
	end

	local supported, submittedEnabled = self:_getVanguardAutoPayState(system, idx)
	if supported ~= true then return false, false end
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("autopay_request_known", idx), 1)
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("autopay_request_enabled", idx), submittedEnabled and 1 or 0)
	return true, submittedEnabled
end

function BANK:_encodeVanguardAutoApprovalTermFrequency(termMonths, paymentFrequency, requestKnown, requestedEnabled)
	local term = math.floor(tonumber(termMonths) or 0)
	if term <= 0 then term = 60 end
	local frequency = self:_normalizeVanguardAutoFrequency(paymentFrequency)
	if requestKnown ~= true then
		return (term * 10) + frequency
	end

	local requestCode = requestedEnabled == true and 2 or 1
	return 100000 + (term * 100) + (frequency * 10) + requestCode
end

function BANK:getAutoLoans(forceRefresh)
	local result = {}
	local now = self:_getNow(false)
	if forceRefresh ~= true and self.cachedAutoLoans ~= nil and now > 0 and now < (tonumber(self.cachedAutoLoansUntil or 0) or 0) then
		return self:_refreshAutoLoanSelection(self.cachedAutoLoans)
	end

	local function finish(loans)
		loans = self:_refreshAutoLoanSelection(loans or {})
		self.cachedAutoLoans = loans
		if now > 0 then
			self.cachedAutoLoansUntil = now + 2.50
		else
			self.cachedAutoLoansUntil = 0
		end
		return loans
	end

	local system = self:getVanguardAutoSystem()
	if not system then return finish(result) end

	local count = 0
	pcall(function() count = math.floor(tonumber(system:GetActiveFinanceContractCount()) or 0) end)
	if count <= 0 then return finish(result) end

	local selected = self:getVanguardAutoLoanDeepLinkIndex()
	for i = 1, count do
		local loan = {
			index = i,
			contractSerial = 0,
			title = "Vanguard Auto Loan #" .. tostring(i),
			balanceDue = 0,
			monthlyPayment = 0,
			scheduledPayment = 0,
			paymentFrequency = 3,
			frequencyLabel = "Monthly",
			termMonths = 0,
			remainingMonths = 0,
			interestBasisPoints = 0,
			totalDue = 0,
			downPayment = 0,
			paidAmount = 0,
			nextDueText = "—",
			repossessed = false,
			autoPaySupported = false,
			autoPayEnabled = false,
			paymentSourceSupported = false,
			paymentSource = 1,
			paymentSourceLabel = "Wallet",
			autoPayRequestKnown = false,
			autoPayRequested = false,
			selected = selected == i,
		}
		loan.contractSerial = self:_getVanguardAutoContractSerial(i, system)
		pcall(function() loan.title = tostring(system:GetActiveFinanceVehicleNameAt(i) or loan.title) end)
		pcall(function() loan.balanceDue = math.floor(tonumber(system:GetActiveFinanceRemainingBalanceAt(i)) or 0) end)
		pcall(function() loan.monthlyPayment = math.floor(tonumber(system:GetActiveFinanceMonthlyPaymentAt(i)) or 0) end)
		pcall(function() loan.termMonths = math.floor(tonumber(system:GetActiveFinanceTermMonthsAt(i)) or 0) end)
		pcall(function() loan.remainingMonths = math.floor(tonumber(system:GetActiveFinanceRemainingMonthsAt(i)) or 0) end)
		pcall(function() loan.interestBasisPoints = math.floor(tonumber(system:GetActiveFinanceInterestBasisPointsAt(i)) or 0) end)
		pcall(function() loan.totalDue = math.floor(tonumber(system:GetActiveFinanceTotalDueAt(i)) or 0) end)
		pcall(function() loan.downPayment = math.floor(tonumber(system:GetActiveFinanceDownPaymentAt(i)) or 0) end)
		pcall(function() loan.paidAmount = math.floor(tonumber(system:GetActiveFinancePaidAmountAt(i)) or 0) end)
		pcall(function() loan.nextDueText = tostring(system:GetActiveFinanceNextDueTextAt(i) or loan.nextDueText) end)
		pcall(function() loan.paymentFrequency = math.floor(tonumber(system:GetActiveFinancePaymentFrequencyAt(i)) or 3) end)
		loan.paymentFrequency = self:_normalizeVanguardAutoFrequency(loan.paymentFrequency)
		loan.frequencyLabel = self:_getVanguardAutoFrequencyLabel(loan.paymentFrequency)
		loan.scheduledPayment = self:_getVanguardAutoScheduledPaymentAmount(loan.monthlyPayment, loan.paymentFrequency, loan.balanceDue)
		pcall(function() loan.repossessed = system:IsActiveFinanceContractRepossessedAt(i) == true end)
		loan.autoPaySupported, loan.autoPayEnabled = self:_getVanguardAutoPayState(system, i)
		local sourceReadable = pcall(function()
			loan.paymentSource = math.floor(tonumber(system:GetActiveFinancePaymentSourceAt(i)) or 1)
		end)
		loan.paymentSourceSupported = sourceReadable == true
		if loan.paymentSource ~= 2 then loan.paymentSource = 1 end
		loan.paymentSourceLabel = loan.paymentSource == 2 and "Savings" or "Wallet"
		loan.autoPayRequestKnown, loan.autoPayRequested = self:_getVanguardAutoPayRequestSnapshot(i)
		if loan.autoPayRequestKnown ~= true then
			loan.autoPayRequestKnown, loan.autoPayRequested = self:_captureVanguardAutoPayRequest(system, i, false)
		end
		loan.autoPayRequestStatus = loan.autoPayRequestKnown and (loan.autoPayRequested and "ON" or "OFF") or "NOT RECORDED"
		loan.autoPayStatus = loan.autoPaySupported and (loan.autoPayEnabled and "ON" or "OFF") or "UPDATE REQUIRED"
		loan.autoPayRequestMatchesStatus = loan.autoPayRequestKnown
			and loan.autoPaySupported
			and loan.autoPayRequested == loan.autoPayEnabled
		loan.status = loan.repossessed and "REPOSSESSED" or "ACTIVE LIEN"
		table.insert(result, loan)
	end
	return finish(result)
end

function BANK:setVanguardAutoLoanAutoPay(contractIndex, enabled)
	local system = self:getVanguardAutoSystem()
	if not system then
		return false, "Vanguard Auto loan services are unavailable."
	end

	local idx = math.floor(tonumber(contractIndex) or 0)
	local targetEnabled = enabled == true
	if idx <= 0 then
		return false, "No active automobile loan is selected."
	end

	local supported, currentEnabled = self:_getVanguardAutoPayState(system, idx)
	if supported ~= true then
		return false, "Automobile Auto-Pay controls require an updated Vanguard Auto installation."
	end
	if currentEnabled == targetEnabled then
		return true, targetEnabled and "Automobile Auto-Pay is already enabled." or "Automobile Auto-Pay is already disabled."
	end

	local callOk, changed = pcall(function()
		return system:SetFinanceContractAutoPayByIndex(idx, targetEnabled)
	end)
	if callOk ~= true then
		return false, "Automobile Auto-Pay controls require an updated Vanguard Auto installation."
	end
	if changed ~= true then
		if targetEnabled then
			return false, "Automobile Auto-Pay could not be enabled. Bring the loan current and confirm the vehicle has not been repossessed."
		end
		return false, "Automobile Auto-Pay could not be disabled. Refresh the loan record and try again."
	end

	self:_invalidateAutoLoansCache()
	local verified, updatedEnabled = self:_getVanguardAutoPayState(system, idx)
	if verified ~= true or updatedEnabled ~= targetEnabled then
		return false, "The automobile Auto-Pay update could not be verified. Refresh the loan record before trying again."
	end

	if targetEnabled then
		return true, "Automobile Auto-Pay enabled. Scheduled payments will be serviced by Marmur Bank."
	end
	return true, "Automobile Auto-Pay disabled. Scheduled payments now require manual approval."
end

function BANK:setVanguardAutoLoanPaymentSource(contractIndex, paymentSource, expectedContractSerial)
	local system = self:getVanguardAutoSystem()
	if not system then
		return false, "Vanguard Auto loan services are unavailable."
	end

	local idx = math.floor(tonumber(contractIndex) or 0)
	local targetSource = math.floor(tonumber(paymentSource) or 0)
	if idx <= 0 then
		return false, "No active automobile loan is selected."
	end
	if targetSource ~= 1 and targetSource ~= 2 then
		return false, "Choose Wallet or Savings for automobile Auto-Pay."
	end
	local expectedSerial = math.floor(tonumber(expectedContractSerial) or 0)
	if expectedSerial > 0 and self:_getVanguardAutoContractSerial(idx, system) ~= expectedSerial then
		return false, "The selected automobile loan changed. Refresh the loan before changing its Auto-Pay account."
	end

	local callOk, changed = pcall(function()
		return system:SetActiveFinancePaymentSourceAt(idx, targetSource)
	end)
	if callOk ~= true or changed ~= true then
		return false, "The Auto-Pay account could not be changed. Refresh the loan and try again."
	end

	self:_invalidateAutoLoansCache()
	local verifiedSource = 0
	local verified = pcall(function()
		verifiedSource = math.floor(tonumber(system:GetActiveFinancePaymentSourceAt(idx)) or 0)
	end)
	if verified ~= true or verifiedSource ~= targetSource then
		return false, "The Auto-Pay account update could not be verified."
	end

	return true, targetSource == 2 and "Scheduled Auto-Pay will now use Savings." or "Scheduled Auto-Pay will now use Wallet."
end

function BANK:hasVanguardAutoLoanObligation()
	local loans = self:getAutoLoans() or {}
	for _, loan in ipairs(loans) do
		if (tonumber(loan.balanceDue) or 0) > 0 and loan.repossessed ~= true then
			return true
		end
	end
	return false
end


function BANK:_getVanguardAutoContractSerial(contractIndex, system)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return 0 end
	local vanguardSystem = system or self:getVanguardAutoSystem()
	if not vanguardSystem then return 0 end

	local serial = 0
	local readable = pcall(function()
		serial = math.floor(tonumber(vanguardSystem:GetActiveFinanceContractSerialAt(idx)) or 0)
	end)
	if readable ~= true or serial <= 0 then return 0 end
	return serial
end

function BANK:_findVanguardAutoContractIndexBySerial(contractSerial, system)
	local serial = math.floor(tonumber(contractSerial) or 0)
	local vanguardSystem = system or self:getVanguardAutoSystem()
	if serial <= 0 or not vanguardSystem then return 0 end

	local count = 0
	pcall(function()
		count = math.floor(tonumber(vanguardSystem:GetActiveFinanceContractCount()) or 0)
	end)
	for idx = 1, math.max(count, 0) do
		if self:_getVanguardAutoContractSerial(idx, vanguardSystem) == serial then
			return idx
		end
	end
	return 0
end

function BANK:_vanguardAutoNoticeKey(field, contractIndex)
	local idx = math.floor(tonumber(contractIndex) or 0)
	local serial = self:_getVanguardAutoContractSerial(idx)
	if serial > 0 then
		return self:_vanguardAutoNoticeSerialKey(field, serial)
	end
	return "marmur_vanguard_auto_notice_" .. tostring(field or "seen") .. "_" .. tostring(idx)
end

function BANK:_vanguardAutoNoticeSerialKey(field, contractSerial)
	return "marmur_vanguard_auto_notice_" .. tostring(field or "seen") .. "_serial_" .. tostring(math.floor(tonumber(contractSerial) or 0))
end

function BANK:_hasVanguardAutoApprovalNoticeSeen(contractIndex)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false end
	return self:_getQuestFactInt(self:_vanguardAutoNoticeKey("seen", idx)) > 0
end

function BANK:_markVanguardAutoApprovalNoticeSeen(contractIndex, amount, payment, termfreq)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return end
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("seen", idx), 1)
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("amount", idx), math.floor(tonumber(amount) or 0))
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("payment", idx), math.floor(tonumber(payment) or 0))
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("termfreq", idx), math.floor(tonumber(termfreq) or 0))
end

function BANK:_hasVanguardAutoApprovalNoticePosted(contractIndex, amount, payment, termfreq)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false end
	if self:_getQuestFactInt(self:_vanguardAutoNoticeKey("posted", idx)) <= 0 then return false end

	local storedPayment = self:_getQuestFactInt(self:_vanguardAutoNoticeKey("payment", idx))
	local storedTermfreq = self:_getQuestFactInt(self:_vanguardAutoNoticeKey("termfreq", idx))
	local checkPayment = math.floor(tonumber(payment) or 0)
	local checkTermfreq = math.floor(tonumber(termfreq) or 0)

	if checkPayment > 0 and storedPayment > 0 and storedPayment ~= checkPayment then return false end
	if checkTermfreq > 0 and storedTermfreq > 0 and storedTermfreq ~= checkTermfreq then return false end
	return true
end

function BANK:_markVanguardAutoApprovalNoticePosted(contractIndex, amount, payment, termfreq)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return end
	self:_markVanguardAutoApprovalNoticeSeen(idx, amount, payment, termfreq)
	self:_setQuestFactInt(self:_vanguardAutoNoticeKey("posted", idx), 1)
end

function BANK:_clearVanguardAutoApprovalNoticeSeen(contractIndex, contractSerial)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return end
	local serial = math.floor(tonumber(contractSerial) or 0)
	local function key(field)
		if serial > 0 then return self:_vanguardAutoNoticeSerialKey(field, serial) end
		return self:_vanguardAutoNoticeKey(field, idx)
	end
	self:_setQuestFactInt(key("seen"), 0)
	self:_setQuestFactInt(key("posted"), 0)
	self:_setQuestFactInt(key("amount"), 0)
	self:_setQuestFactInt(key("payment"), 0)
	self:_setQuestFactInt(key("termfreq"), 0)
	self:_setQuestFactInt(key("autopay_request_known"), 0)
	self:_setQuestFactInt(key("autopay_request_enabled"), 0)
end

function BANK:_normalizeVanguardAutoFrequency(value)
	local frequency = math.floor(tonumber(value) or 3)
	if frequency < 1 or frequency > 3 then frequency = 3 end
	return frequency
end

function BANK:_getVanguardAutoFrequencyLabel(value)
	local frequency = self:_normalizeVanguardAutoFrequency(value)
	if frequency == 1 then return "Weekly" end
	if frequency == 2 then return "Bi-weekly" end
	return "Monthly"
end

function BANK:_getVanguardAutoScheduledPaymentAmount(monthlyPayment, paymentFrequency, balanceDue)
	local monthly = math.floor(tonumber(monthlyPayment) or 0)
	local frequency = self:_normalizeVanguardAutoFrequency(paymentFrequency)
	local balance = math.floor(tonumber(balanceDue) or 0)
	local payment = monthly

	if monthly <= 0 then return 0 end
	if frequency == 1 then
		payment = math.floor(((monthly * 12) + 51) / 52)
	elseif frequency == 2 then
		payment = math.floor(((monthly * 12) + 25) / 26)
	end

	if balance > 0 and payment > balance then payment = balance end
	if payment <= 0 then return 0 end
	return math.max(1, payment)
end

function BANK:_getVanguardAutoMinimumDownPaymentForApproval(price)
	local amount = math.floor(tonumber(price) or 0)
	if amount <= 0 then return 0 end
	local system = self:getVanguardAutoSystem()
	if not system then return 0 end
	local minimumDown = 0
	pcall(function()
		minimumDown = math.floor(tonumber(system:GetFinanceMinimumDownPaymentForApproval(amount, Game.GetPlayer())) or 0)
	end)
	if minimumDown < 0 then minimumDown = 0 end
	return minimumDown
end

function BANK:_getVanguardAutoMaxDownPaymentOption(price)
	local amount = math.floor(tonumber(price) or 0)
	if amount <= 0 then return 0 end
	local system = self:getVanguardAutoSystem()
	if not system then return 0 end
	local maxDown = 0
	pcall(function()
		maxDown = math.floor(tonumber(system:GetFinanceMaxDownPaymentOption(amount)) or 0)
	end)
	if maxDown < 0 then maxDown = 0 end
	return maxDown
end

function BANK:_prepareVanguardAutoLoanThread()
	pcall(function() self:setAccountOpenFlag(true) end)
	self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
end

function BANK:ensureVanguardAutoLoanApprovalNotices()
	if self:isJohnnySuppressed() then return false end
	local now = self:_getNow(false)
	if now < (tonumber(self.nextVanguardAutoNoticeCheckTime or 0) or 0) then return false end
	self.nextVanguardAutoNoticeCheckTime = now + 8.0

	local loans = self:getAutoLoans() or {}
	local posted = false
	for _, loan in ipairs(loans) do
		local idx = math.floor(tonumber(loan.index) or 0)
		local balance = math.floor(tonumber(loan.balanceDue) or 0)
		if idx > 0 and balance > 0 and loan.repossessed ~= true then
			local payment = math.floor(tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0)
			local term = math.floor(tonumber(loan.termMonths) or 0)
			local frequency = self:_normalizeVanguardAutoFrequency(loan.paymentFrequency)
			if term <= 0 then term = 60 end
			local termfreq = self:_encodeVanguardAutoApprovalTermFrequency(
				term,
				frequency,
				loan.autoPayRequestKnown == true,
				loan.autoPayRequested == true
			)
			if not self:_hasVanguardAutoApprovalNoticePosted(idx, balance, payment, termfreq) then
				local code = self:_generateLoanConfirmationCode("AAL")
				self:_prepareVanguardAutoLoanThread()
				self:_setLastLoanConfirmationCode(code)
				self:_storeLoanSmsThreadEntry("VAA", balance, payment, termfreq, code)
				self:_markVanguardAutoApprovalNoticePosted(idx, balance, payment, termfreq)
				posted = true
			end
		end
	end

	if posted then
		self:ensureAccountPhoneThread()
	end
	return posted
end

function BANK:processVanguardAutoLoanApprovalNotice()
	local pending = self:_getQuestFactInt("marmur_vanguard_auto_sms_pending")
	if pending <= 0 then return false end

	local amount = self:_getQuestFactInt("marmur_vanguard_auto_sms_amount")
	local payment = self:_getQuestFactInt("marmur_vanguard_auto_sms_payment")
	local termfreq = self:_getQuestFactInt("marmur_vanguard_auto_sms_termfreq")
	local contractIndex = self:_getQuestFactInt("marmur_vanguard_auto_sms_contract")
	local contractSerial = self:_getQuestFactInt("marmur_vanguard_auto_sms_serial")
	if pending == 1 and contractSerial > 0 then
		local vanguardSystem = self:getVanguardAutoSystem()
		if not vanguardSystem then
			return false
		end
		local resolvedIndex = self:_findVanguardAutoContractIndexBySerial(
			contractSerial,
			vanguardSystem
		)
		if resolvedIndex <= 0 then
			self:_setQuestFactInt("marmur_vanguard_auto_sms_pending", 0)
			self:_setQuestFactInt("marmur_vanguard_auto_sms_serial", 0)
			return false
		end
		contractIndex = resolvedIndex
	end
	if contractIndex <= 0 then contractIndex = self:_getQuestFactInt("marmur_vanguard_selected_contract") end
	if amount <= 0 then amount = self:_getQuestFactInt("marmur_vanguard_selected_balance") end
	if payment <= 0 then payment = self:_getQuestFactInt("marmur_vanguard_selected_monthly") end
	if termfreq <= 0 then
		local term = self:_getQuestFactInt("marmur_vanguard_selected_term")
		if term <= 0 then term = 60 end
		termfreq = (term * 10) + 3
	end

	self:_prepareVanguardAutoLoanThread()

	if pending == 1 then
		local term = math.floor(termfreq / 10)
		local frequency = self:_normalizeVanguardAutoFrequency(termfreq % 10)
		local requestKnown, requestedEnabled = self:_getVanguardAutoPayRequestSnapshot(contractIndex)
		if requestKnown ~= true then
			requestKnown, requestedEnabled = self:_captureVanguardAutoPayRequest(
				self:getVanguardAutoSystem(),
				contractIndex,
				true
			)
		end
		local approvalTermfreq = self:_encodeVanguardAutoApprovalTermFrequency(
			term,
			frequency,
			requestKnown,
			requestedEnabled
		)
		if contractIndex <= 0 or not self:_hasVanguardAutoApprovalNoticePosted(contractIndex, amount, payment, approvalTermfreq) then
			local code = self:_generateLoanConfirmationCode("AAL")
			self:_setLastLoanConfirmationCode(code)
			self:_storeLoanSmsThreadEntry("VAA", amount, payment, approvalTermfreq, code)
		end
		self:_markVanguardAutoApprovalNoticePosted(contractIndex, amount, payment, approvalTermfreq)
	elseif pending == 2 then
		local code = self:_generateLoanConfirmationCode("ADE")
		local minimumDown = self:_getVanguardAutoMinimumDownPaymentForApproval(amount)
		local maxDown = self:_getVanguardAutoMaxDownPaymentOption(amount)
		local denialDetail = minimumDown
		if denialDetail <= 0 then denialDetail = termfreq end
		if maxDown > 0 and minimumDown > maxDown then
			denialDetail = minimumDown
		end
		self:_setLastLoanConfirmationCode(code)
		self:_storeLoanSmsThreadEntry("VAD", amount, payment, denialDetail, code)
	end

	self:_setQuestFactInt("marmur_vanguard_auto_sms_pending", 0)
	self:_setQuestFactInt("marmur_vanguard_auto_sms_serial", 0)
	self:ensureAccountPhoneThread()
	return true
end

function BANK:_clearVanguardSettlementFacts()
	local keys = {
		MB_VANGUARD_SETTLEMENT_PENDING,
		MB_VANGUARD_SETTLEMENT_CLAIM,
		MB_VANGUARD_SETTLEMENT_TOTAL,
		MB_VANGUARD_SETTLEMENT_BANK_PAYMENT,
		MB_VANGUARD_SETTLEMENT_PLAYER_DEPOSIT,
		MB_VANGUARD_SETTLEMENT_WALLET_BEFORE,
		MB_VANGUARD_SETTLEMENT_WALLET_AFTER,
		MB_VANGUARD_SETTLEMENT_CONTRACT,
		MB_VANGUARD_SETTLEMENT_REASON,
	}
	for _, key in ipairs(keys) do
		self:_setQuestFactInt(key, 0)
	end
end

function BANK:_vanguardSettlementConfirmationTail(claim, amount, salt)
	local tail = ((math.floor(tonumber(claim) or 0) * 37) + (math.floor(tonumber(amount) or 0) * 3) + (math.floor(tonumber(salt) or 0) * 911)) % 1000000
	if tail < 100000 then tail = tail + 100000 end
	return tail
end

function BANK:processVanguardInsuranceSettlementNotice()
	local pending = self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_PENDING)
	if pending <= 0 then return false end

	local claim = self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_CLAIM)
	if claim <= 0 then claim = pending end
	if claim <= 0 then
		self:_clearVanguardSettlementFacts()
		return false
	end

	if self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_LAST_CLAIM) == claim then
		self:_clearVanguardSettlementFacts()
		return false
	end

	local bankPayment = math.max(math.floor(tonumber(self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_BANK_PAYMENT)) or 0), 0)
	local playerDeposit = math.max(math.floor(tonumber(self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_PLAYER_DEPOSIT)) or 0), 0)
	local walletBefore = math.max(math.floor(tonumber(self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_WALLET_BEFORE)) or 0), 0)
	local walletAfter = math.max(math.floor(tonumber(self:_getQuestFactInt(MB_VANGUARD_SETTLEMENT_WALLET_AFTER)) or 0), 0)

	if playerDeposit > 0 and walletAfter <= 0 then
		walletAfter = walletBefore + playerDeposit
	end
	if playerDeposit > 0 and walletBefore <= 0 and walletAfter >= playerDeposit then
		walletBefore = walletAfter - playerDeposit
	end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local confirmationLeft = self:_getCurrentGameDay() % 10000
	local recorded = false

	if system and gameInstance then
		if bankPayment > 0 then
			local ok, result = pcall(function()
				if system.RecordVanguardInsuranceLoanPayoff then
					return system:RecordVanguardInsuranceLoanPayoff(gameInstance, bankPayment, claim, walletAfter, walletAfter, confirmationLeft, self:_vanguardSettlementConfirmationTail(claim, bankPayment, 26))
				end
				return false
			end)
			if ok and result == true then recorded = true end
			if not (ok and result == true) then
				self:_storeWalletTxFact(26, bankPayment, walletAfter, walletAfter, 0, 0, 0)
				recorded = true
			end
		end

		if playerDeposit > 0 then
			local ok, result = pcall(function()
				if system.RecordVanguardInsuranceSettlementDeposit then
					return system:RecordVanguardInsuranceSettlementDeposit(gameInstance, playerDeposit, claim, walletBefore, walletAfter, confirmationLeft, self:_vanguardSettlementConfirmationTail(claim, playerDeposit, 25))
				end
				return false
			end)
			if ok and result == true then recorded = true end
			if not (ok and result == true) then
				self:_storeWalletTxFact(25, playerDeposit, walletBefore, walletAfter, 0, 0, 0)
				recorded = true
			end
		end
	else
		if bankPayment > 0 then
			self:_storeWalletTxFact(26, bankPayment, walletAfter, walletAfter, 0, 0, 0)
			recorded = true
		end
		if playerDeposit > 0 then
			self:_storeWalletTxFact(25, playerDeposit, walletBefore, walletAfter, 0, 0, 0)
			recorded = true
		end
	end

	self:_setQuestFactInt(MB_VANGUARD_SETTLEMENT_LAST_CLAIM, claim)
	self:_clearVanguardSettlementFacts()
	pcall(function() self:_invalidateAutoLoansCache() end)
	pcall(function() self:_syncWalletSnapshot() end)
	self:ensureAccountPhoneThread()
	return recorded
end

function BANK:_readTransactionSequence(system)
	if not system then return nil, false end
	local sequence = nil
	local ok = pcall(function()
		sequence = math.floor(tonumber(system:GetTransactionSequence()) or -1)
	end)
	if ok ~= true or sequence == nil or sequence < 0 then return nil, false end
	return sequence, true
end

function BANK:_readTransactionCount(system)
	if not system then return nil, false end
	local count = nil
	local ok = pcall(function()
		count = math.floor(tonumber(system:GetTransactionLogCount()) or -1)
	end)
	if ok ~= true or count == nil or count < 0 then return nil, false end
	return count, true
end

function BANK:_recordVanguardAutoPaymentActivity(amount, walletBefore, walletAfter, cashbackEarned)
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	walletBefore = math.max(math.floor(tonumber(walletBefore) or 0), 0)
	walletAfter = math.max(math.floor(tonumber(walletAfter) or 0), 0)
	cashbackEarned = math.max(math.floor(tonumber(cashbackEarned) or 0), 0)
	if amount <= 0 then return false end

	local posted = false
	local bankSystem = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if bankSystem and gameInstance then
		local beforeSequence, beforeSequenceReadable = self:_readTransactionSequence(bankSystem)
		local beforeCount, beforeCountReadable = self:_readTransactionCount(bankSystem)
		local callOk, appendResult = pcall(function()
			return bankSystem:RecordVanguardAutoPaymentNotice(gameInstance, amount, cashbackEarned, walletBefore, walletAfter)
		end)
		local afterSequence, afterSequenceReadable = self:_readTransactionSequence(bankSystem)
		local afterCount, afterCountReadable = self:_readTransactionCount(bankSystem)

		posted = callOk == true and appendResult == true
		if beforeSequenceReadable and afterSequenceReadable then
			posted = afterSequence > beforeSequence
		elseif beforeCountReadable and afterCountReadable then
			posted = afterCount > beforeCount
		elseif callOk == true and appendResult ~= false then
			posted = true
		end
	end

	if not posted then
		self:_storeWalletTxFact(21, amount, walletBefore, walletAfter, 201, 0, cashbackEarned, MB_SPEND_SUBJECT.vehicles, MB_SPEND_PROVENANCE.partner)
	end
	return true
end

function BANK:_syncVanguardAnalyticsCursorToCurrent()
	local system = self:getVanguardAutoSystem()
	if not system then return false end
	local count = -1
	local ok = pcall(function()
		count = math.floor(tonumber(system:GetFinanceEventCount()) or -1)
	end)
	if ok ~= true or count < 0 then return false end
	self:_setQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR, count + 1)
	return true
end

function BANK:payVanguardAutoLoanScheduled(contractIndex)
	local system = self:getVanguardAutoSystem()
	if not system then return false end
	self:processVanguardAnalyticsEvents(true)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false end
	local paidAmount = 0
	pcall(function()
		local loans = self:getAutoLoans() or {}
		for _, loan in ipairs(loans) do
			if math.floor(tonumber(loan.index) or 0) == idx then
				paidAmount = math.floor(tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0)
			end
		end
	end)
	local walletBefore = self:getWalletBalance()
	local okPayment = false
	pcall(function()
		okPayment = system:PayFinanceContractScheduledByIndex(idx, Game.GetPlayer()) == true
	end)
	if okPayment then
		self:_invalidateAutoLoansCache()
		local walletAfter = self:getWalletBalance()
		local actualDebit = math.max(walletBefore - walletAfter, 0)
		if actualDebit > 0 then paidAmount = actualDebit end
		self:_markServicedLoanDebitHandled(walletAfter)
		local code = self:_generateLoanConfirmationCode("APY")
		self:_setLastLoanConfirmationCode(code)
		self:_storeLoanSmsThreadEntry("VAP", paidAmount, walletBefore, walletAfter, code)
		local cashbackEarned = self:_awardCashbackForLoanPayment(paidAmount, walletBefore, walletAfter, nil, nil)
		self:_recordVanguardAutoPaymentActivity(paidAmount, walletBefore, walletAfter, cashbackEarned)
		self:_syncVanguardAnalyticsCursorToCurrent()
		self:ensureAccountPhoneThread()
		pcall(function() Util.simpleScreenMessage("Marmur Bank auto-loan payment posted") end)
	end
	return okPayment
end

function BANK:payVanguardAutoLoanCustom(contractIndex, amount)
	local system = self:getVanguardAutoSystem()
	if not system then return false, "Vanguard Auto loan system unavailable." end
	self:processVanguardAnalyticsEvents(true)
	local idx = math.floor(tonumber(contractIndex) or 0)
	local paymentAmount = math.floor(tonumber(amount) or 0)
	if idx <= 0 then return false, "No active auto loan selected." end
	if paymentAmount <= 0 then return false, "Enter a payment amount greater than E$ 0." end

	local balanceDue = 0
	pcall(function()
		local loans = self:getAutoLoans() or {}
		for _, loan in ipairs(loans) do
			if math.floor(tonumber(loan.index) or 0) == idx then
				balanceDue = math.floor(tonumber(loan.balanceDue) or 0)
			end
		end
	end)
	if balanceDue <= 0 then return false, "No active balance found for this auto loan." end
	if paymentAmount > balanceDue then paymentAmount = balanceDue end

	local walletBefore = self:getWalletBalance()
	if walletBefore < paymentAmount then return false, "Payment exceeds checking balance." end

	if paymentAmount >= balanceDue then
		local paid = self:payVanguardAutoLoanInFull(idx) == true
		return paid, paid and "Auto loan paid in full." or "Payoff failed. Check loan status."
	end

	local okPayment = false
	pcall(function()
		okPayment = system:PayFinanceContractCustomByIndex(idx, paymentAmount, Game.GetPlayer()) == true
	end)

	if not okPayment then
		local scheduledAmount = 0
		pcall(function()
			local loans = self:getAutoLoans() or {}
			for _, loan in ipairs(loans) do
				if math.floor(tonumber(loan.index) or 0) == idx then
					scheduledAmount = math.floor(tonumber(loan.scheduledPayment or loan.monthlyPayment) or 0)
				end
			end
		end)
		if scheduledAmount > 0 and paymentAmount == scheduledAmount then
			local paid = self:payVanguardAutoLoanScheduled(idx) == true
			return paid, paid and "Normal auto-loan payment posted." or "Normal payment failed. Check loan status."
		end
		return false, "Custom payment support unavailable. Use Normal Pay or update Vanguard Auto."
	end

	self:_invalidateAutoLoansCache()
	local walletAfter = self:getWalletBalance()
	local paidAmount = math.max(walletBefore - walletAfter, 0)
	if paidAmount <= 0 then paidAmount = paymentAmount end
	self:_markServicedLoanDebitHandled(walletAfter)
	local code = self:_generateLoanConfirmationCode("APX")
	self:_setLastLoanConfirmationCode(code)
	self:_storeLoanSmsThreadEntry("VAP", paidAmount, walletBefore, walletAfter, code)
	local cashbackEarned = self:_awardCashbackForLoanPayment(paidAmount, walletBefore, walletAfter, nil, nil)
	self:_recordVanguardAutoPaymentActivity(paidAmount, walletBefore, walletAfter, cashbackEarned)
	self:_syncVanguardAnalyticsCursorToCurrent()
	self:ensureAccountPhoneThread()
	pcall(function() Util.simpleScreenMessage("Marmur Bank custom auto-loan payment posted") end)
	return true, "Custom auto-loan payment posted."
end

function BANK:payVanguardAutoLoanInFull(contractIndex)
	local system = self:getVanguardAutoSystem()
	if not system then return false end
	self:processVanguardAnalyticsEvents(true)
	local idx = math.floor(tonumber(contractIndex) or 0)
	if idx <= 0 then return false end
	local contractSerial = self:_getVanguardAutoContractSerial(idx, system)
	local payoffAmount = 0
	pcall(function()
		local loans = self:getAutoLoans() or {}
		for _, loan in ipairs(loans) do
			if math.floor(tonumber(loan.index) or 0) == idx then
				payoffAmount = math.floor(tonumber(loan.balanceDue) or 0)
			end
		end
	end)
	local walletBefore = self:getWalletBalance()
	local okPayment = false
	pcall(function()
		okPayment = system:PayFinanceContractFullByIndex(idx, Game.GetPlayer()) == true
	end)
	if okPayment then
		self:_invalidateAutoLoansCache()
		local walletAfter = self:getWalletBalance()
		local actualDebit = math.max(walletBefore - walletAfter, 0)
		if actualDebit > 0 then payoffAmount = actualDebit end
		self:_markServicedLoanDebitHandled(walletAfter)
		local code = self:_generateLoanConfirmationCode("AFU")
		self:_setLastLoanConfirmationCode(code)
		self:_storeLoanSmsThreadEntry("VAF", payoffAmount, walletBefore, walletAfter, code)
		local cashbackEarned = self:_awardCashbackForLoanPayment(payoffAmount, walletBefore, walletAfter, nil, nil)
		self:_recordVanguardAutoPaymentActivity(payoffAmount, walletBefore, walletAfter, cashbackEarned)
		self:_syncVanguardAnalyticsCursorToCurrent()
		self:_clearVanguardAutoApprovalNoticeSeen(idx, contractSerial)
		self:ensureAccountPhoneThread()
		pcall(function() Util.simpleScreenMessage("Marmur Bank auto-loan paid in full. Vanguard title lien released.") end)
	end
	return okPayment
end

function BANK:isJohnnySuppressed()
	if self.johnnySuppressed == true then
		return true
	end

	local now = tonumber(self.currentTime or 0) or 0
	if now <= 0 then
		pcall(function() now = os.clock() end)
	end

	if now > 0 and now < (tonumber(self.nextJohnnyFactCheckTime or 0) or 0) then
		return self.cachedJohnnyFactSuppressed == true
	end

	if now > 0 then
		self.nextJohnnyFactCheckTime = now + 0.85
	end

	local suppressed = false
	pcall(function()
		suppressed = self:_getQuestFactInt("marmur_mod_suppressed_johnny") > 0
	end)
	self.cachedJohnnyFactSuppressed = suppressed == true
	return self.cachedJohnnyFactSuppressed
end

function BANK:setJohnnySuppressed(active)
	active = active == true
	self.johnnySuppressed = active
	self.cachedJohnnyFactSuppressed = active
	self.nextJohnnyFactCheckTime = 0
	pcall(function()
		self:_setQuestFactInt("marmur_mod_suppressed_johnny", active and 1 or 0)
	end)

	local phoneGate = self:getMarmurPhoneGateSystem()
	local gameInstance = self:getGameInstance()
	if phoneGate and gameInstance then
		pcall(function()
			if active then
				phoneGate:Deactivate(gameInstance)
			elseif self:hasAccountEverOpened() then
				if phoneGate.EnsureActive then
					phoneGate:EnsureActive(gameInstance)
				else
					phoneGate:Activate(gameInstance)
				end
			end
		end)
	end

	if active then
		pcall(function() self:hideHub() end)
		if self.SPAWN then
			pcall(function() self.SPAWN:hideHub(true) end)
		end
		self:_resetPendingWalletSpend()
		self.theftDetectionWindowUntil = 0
		self.theftDetectionReason = ""
	end
end

function BANK:maintainJohnnySuppressedState()
	if not self:isJohnnySuppressed() then return end
	local now = tonumber(self.currentTime or 0) or 0
	if now <= 0 then pcall(function() now = os.clock() end) end
	if now > 0 and now < (tonumber(self.nextJohnnyMaintainTime or 0) or 0) then
		return
	end
	if now > 0 then self.nextJohnnyMaintainTime = now + 0.50 end

	self:_resetPendingWalletSpend()
	self.fraudBurstAmount = 0
	self.fraudBurstBefore = 0
	self.fraudBurstAfter = 0
	self.fraudBurstLastChangeTime = 0
	self.fraudBurstNotified = false
	self.theftDetectionWindowUntil = 0
	self.theftDetectionReason = ""
	local wallet, readable = self:_tryReadWalletBalance()
	if readable == true then
		self:_saveTrustedWalletBaseline(wallet, "johnny_suppressed")
	end
	pcall(function() self:hideHub() end)
	if self.SPAWN then
		pcall(function() self.SPAWN:hideHub(true) end)
	end
end

function BANK:getMarmurPhoneGateSystem()
	local ok, system = pcall(function()
		local container = Game.GetScriptableSystemsContainer()
		if not container then
			return nil
		end
		return container:Get("MarmurBankPhone.MarmurBankPhoneGateSystem")
	end)

	if ok and system then
		return system
	end

	return nil
end

function BANK:syncFactBalanceIntoUnifiedSystem(factBalance, system, gameInstance)
	local amount = tonumber(factBalance) or 0
	if amount <= 0 or not system or not gameInstance then
		return false
	end

	local ok, result = pcall(function()
		return system:ImportLegacyBalance(gameInstance, math.floor(amount))
	end)

	return ok and result == true
end

function BANK:forceUnifiedBalance(amount, system, gameInstance)
	local safeAmount = math.floor(tonumber(amount) or 0)
	if safeAmount < 0 then
		safeAmount = 0
	end

	self:setFactBalance(safeAmount)
	system = system or self:getUnifiedSystem()
	gameInstance = gameInstance or self:getGameInstance()

	if system then
		pcall(function()
			return system:ForceSetBalance(safeAmount)
		end)
		pcall(function()
			return system:SetSavingsBalanceFromLua(gameInstance, safeAmount)
		end)
	end

	self.lastUnifiedBalance = safeAmount
	pcall(function()
		if self.syncLoyaltyProgram then
			self:syncLoyaltyProgram(safeAmount, true)
		end
	end)
	return safeAmount
end

function BANK:getFactBalance()
	return self:_getQuestFactInt(MB_DEPOSIT)
end

function BANK:getBalanceBackupFact()
	return self:_getQuestFactInt(MB_BALANCE_BACKUP)
end

function BANK:setBalanceBackupFact(amount)
	local safeAmount = math.floor(tonumber(amount) or 0)
	if safeAmount < 0 then safeAmount = 0 end
	self:_setQuestFactInt(MB_BALANCE_BACKUP, safeAmount)
end

function BANK:setFactBalance(amount)
	local safeAmount = tonumber(amount) or 0
	if safeAmount < 0 then
		safeAmount = 0
	end
	safeAmount = math.floor(safeAmount)
	self:_setQuestFactInt(MB_DEPOSIT, safeAmount)
	self:setBalanceBackupFact(safeAmount)
	self:_setQuestFactInt(MB_BALANCE_MIGRATION_VERSION, MB_BALANCE_MIGRATION_CURRENT)
end


function BANK:getAccountOpenFlag()
	return self:_getQuestFactInt(MB_ACCOUNT_OPEN)
end

function BANK:setAccountOpenFlag(isOpen)
	self:_setQuestFactInt(MB_ACCOUNT_OPEN, isOpen == true and 1 or 0)
	self.cachedAccountReadyValue = nil
	self.cachedAccountReadyUntil = 0
end

function BANK:_getAutoDepositFrequencyMeta(intervalDays)
	local key = string.lower(tostring(intervalDays or "7"))
	key = key:gsub("%s+", "")
	key = key:gsub("%-", "")

	if key == "weekly" or key == "week" then key = "7" end
	if key == "biweekly" or key == "every2weeks" or key == "twoweeks" then key = "14" end
	if key == "monthly" or key == "month" then key = "30" end

	local days = math.floor(tonumber(key) or 7)
	if days < 1 then days = 1 end
	if days > 30 then days = 30 end

	local label = "Every " .. tostring(days) .. " days"
	if days == 1 then label = "Every day" end
	return { code = tostring(days), label = label, days = days }
end

function BANK:_buildAutoDepositNextStamp(intervalDays, fromStamp)
	local interval = math.floor(tonumber(intervalDays) or 7)
	if interval < 1 then interval = 1 end
	if interval > 30 then interval = 30 end
	local stamp = math.max(math.floor(tonumber(fromStamp) or self:_getCurrentGameMinuteStamp()), 0)
	return stamp + (interval * 1440)
end

function BANK:formatAutoDepositNextLabel(nextStamp)
	local target = math.floor(tonumber(nextStamp) or 0)
	if target <= 0 then return "Not scheduled" end
	local current = self:_getCurrentGameMinuteStamp()
	local delta = target - current
	local timeLabel = self:formatLoanTimeStamp(target)
	if delta <= 0 then return "Pending post" end
	local days = math.floor(delta / 1440)
	local hours = math.floor((delta - (days * 1440)) / 60)
	if days <= 0 then
		if hours <= 0 then return "In under 1 hour at " .. timeLabel end
		if hours == 1 then return "In 1 hour at " .. timeLabel end
		return "In " .. tostring(hours) .. " hours at " .. timeLabel
	end
	if days == 1 then return "Tomorrow at " .. timeLabel end
	return "In " .. tostring(days) .. " days at " .. timeLabel
end

function BANK:getAutoDepositSettings()
	local active = self:_getQuestFactInt(MB_AUTO_DEPOSIT_ACTIVE) == 1
	local amount = self:_getQuestFactInt(MB_AUTO_DEPOSIT_AMOUNT)
	local intervalDays = self:_getQuestFactInt(MB_AUTO_DEPOSIT_INTERVAL_DAYS)
	local meta = self:_getAutoDepositFrequencyMeta(intervalDays)
	local nextStamp = self:_getQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP)
	local lastStamp = self:_getQuestFactInt(MB_AUTO_DEPOSIT_LAST_STAMP)
	local lastStatus = self:_getQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS)

	if amount <= 0 then active = false end
	if not active then
		nextStamp = 0
	end

	return {
		active = active,
		amount = math.max(amount, 0),
		frequency = meta.code,
		frequencyLabel = meta.label,
		intervalDays = meta.days,
		nextStamp = nextStamp,
		nextLabel = self:formatAutoDepositNextLabel(nextStamp),
		lastStamp = lastStamp,
		lastStatus = lastStatus,
	}
end

function BANK:setAutoDepositSchedule(amount, intervalDays)
	if not self:isAccountOpen() then
		return false, "no_account"
	end

	local transferAmount = math.floor(tonumber(amount) or 0)
	if transferAmount <= 0 then
		return false, "amount"
	end

	local meta = self:_getAutoDepositFrequencyMeta(intervalDays)
	local nextStamp = self:_buildAutoDepositNextStamp(meta.days)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_ACTIVE, 1)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_AMOUNT, transferAmount)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_INTERVAL_DAYS, meta.days)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP, nextStamp)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS, 0)
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank automatic deposits scheduled: " .. Util.formatNumber(transferAmount) .. " E$ " .. string.lower(meta.label))
	end)
	return true, "scheduled"
end

function BANK:cancelAutoDeposit(silent)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_ACTIVE, 0)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_AMOUNT, 0)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_INTERVAL_DAYS, 0)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP, 0)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS, 0)
	if silent ~= true then
		pcall(function() Util.simpleScreenMessage("Marmur Bank automatic deposits canceled") end)
	end
	return true
end

function BANK:processAutoDepositSchedule()
	if self:_getQuestFactInt(MB_AUTO_DEPOSIT_ACTIVE) ~= 1 then return false end
	if not self:isAccountOpen() then
		self:cancelAutoDeposit(true)
		return false
	end

	local amount = self:_getQuestFactInt(MB_AUTO_DEPOSIT_AMOUNT)
	if amount <= 0 then
		self:cancelAutoDeposit(true)
		return false
	end

	local intervalDays = self:_getQuestFactInt(MB_AUTO_DEPOSIT_INTERVAL_DAYS)
	local meta = self:_getAutoDepositFrequencyMeta(intervalDays)
	local nextStamp = self:_getQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP)
	local currentStamp = self:_getCurrentGameMinuteStamp()
	if nextStamp <= 0 then
		self:_setQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP, self:_buildAutoDepositNextStamp(meta.days, currentStamp))
		return false
	end
	if currentStamp < nextStamp then return false end

	local nextScheduledStamp = self:_buildAutoDepositNextStamp(meta.days, currentStamp)
	local wallet = self:getWalletBalance()
	if wallet < amount then
		self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STAMP, currentStamp)
		self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS, 2)
		self:_setQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP, nextScheduledStamp)
		pcall(function()
			Util.simpleScreenMessage("Marmur Bank automatic deposit skipped: insufficient checking funds")
		end)
		return false
	end

	local ok = self:depositMoney(amount)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STAMP, currentStamp)
	self:_setQuestFactInt(MB_AUTO_DEPOSIT_NEXT_STAMP, nextScheduledStamp)
	if ok then
		self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS, 1)
		pcall(function()
			Util.simpleScreenMessage("Marmur Bank automatic deposit posted: " .. Util.formatNumber(amount) .. " E$")
		end)
		return true
	end

	self:_setQuestFactInt(MB_AUTO_DEPOSIT_LAST_STATUS, 3)
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank automatic deposit failed. Schedule advanced to next transfer date.")
	end)
	return false
end

function BANK:hasLoanObligation()
	local loan = nil
	local hasAutoLoan = false
	pcall(function() loan = self:getLoanData() end)
	pcall(function() hasAutoLoan = self:hasVanguardAutoLoanObligation() == true end)
	if hasAutoLoan then
		return true
	end
	loan = loan or {}
	if loan.active == true and math.floor(tonumber(loan.balanceDue) or 0) > 0 then
		return true
	end
	if loan.reviewActive == true or loan.reviewPending == true or loan.reviewApprovalReady == true or loan.reviewFundingPending == true then
		return true
	end
	return false
end

function BANK:hasAccountEverOpened()
	if self:_getQuestFactInt(MB_ACCOUNT_EVER_OPENED) > 0 then
		return true
	end

	if self:getAccountOpenFlag() > 0 then
		self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
		return true
	end

	local balance = 0
	pcall(function() balance = math.floor(tonumber(self:getUnifiedBalance()) or 0) end)
	if balance > 0 or self:_getQuestFactInt(MB_ACCOUNT_NUMBER_LEFT) > 0 or self:_getQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT) > 0 then
		self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
		if self:getAccountOpenFlag() <= 0 and balance > 0 then
			self:setAccountOpenFlag(true)
		end
		return true
	end

	return false
end

function BANK:isAccountOpen()
	local flag = self:getAccountOpenFlag()
	if flag > 0 then
		if self:_getQuestFactInt(MB_ACCOUNT_EVER_OPENED) <= 0 then
			self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
		end
		return true
	end

	local balance = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	if balance > 0 then
		self:setAccountOpenFlag(true)
		self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
		return true
	end

	local hasLoan = false
	pcall(function() hasLoan = self:hasLoanObligation() end)
	if hasLoan then
		self:setAccountOpenFlag(true)
		self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
		return true
	end

	return false
end

function BANK:_getLoyaltyTierMeta(index)
	local wanted = math.floor(tonumber(index) or 0)
	if wanted < 0 then wanted = 0 end
	if wanted > 4 then wanted = 4 end
	for _, tier in ipairs(MB_LOYALTY_TIERS) do
		if tier.index == wanted then return tier end
	end
	return MB_LOYALTY_TIERS[1]
end

function BANK:_getLoyaltyTierIndexForBalance(balance)
	local amount = math.max(math.floor(tonumber(balance) or 0), 0)
	for i = #MB_LOYALTY_TIERS, 1, -1 do
		local tier = MB_LOYALTY_TIERS[i]
		if amount >= (tonumber(tier.threshold) or 0) then
			return math.floor(tonumber(tier.index) or 0)
		end
	end
	return 0
end

function BANK:getPotentialLoyaltyTierIndex(balance)
	return self:_getLoyaltyTierIndexForBalance(balance)
end

function BANK:getPotentialAccountLevelName(balance)
	return self:_getLoyaltyTierMeta(self:_getLoyaltyTierIndexForBalance(balance)).name
end

function BANK:_getLoyaltyRetentionFloor(index)
	local tier = self:_getLoyaltyTierMeta(index)
	local threshold = math.max(math.floor(tonumber(tier.threshold) or 0), 0)
	if threshold <= 0 then return 0 end
	return math.floor(((threshold * MB_LOYALTY_RETENTION_PERCENT) + 99) / 100)
end

function BANK:_getLoyaltySampleSlot(day)
	local safeDay = math.max(math.floor(tonumber(day) or 0), 0)
	return (safeDay % MB_LOYALTY_WINDOW_DAYS) + 1
end

function BANK:_readLoyaltySample(day)
	local safeDay = math.max(math.floor(tonumber(day) or 0), 0)
	local slot = self:_getLoyaltySampleSlot(safeDay)
	local storedDay = self:_getQuestFactInt(loyaltySampleKey("day", slot)) - 1
	if storedDay ~= safeDay then return nil end
	return math.max(self:_getQuestFactInt(loyaltySampleKey("balance", slot)), 0)
end

function BANK:_writeLoyaltySample(day, balance)
	local safeDay = math.max(math.floor(tonumber(day) or 0), 0)
	local safeBalance = math.max(math.floor(tonumber(balance) or 0), 0)
	local slot = self:_getLoyaltySampleSlot(safeDay)
	self:_setQuestFactInt(loyaltySampleKey("day", slot), safeDay + 1)
	self:_setQuestFactInt(loyaltySampleKey("balance", slot), safeBalance)
	self:_setQuestFactInt(MB_LOYALTY_LAST_SAMPLE_DAY, safeDay + 1)
	self:_setQuestFactInt(MB_LOYALTY_LAST_BALANCE, safeBalance)
end

function BANK:_clearLoyaltySamples()
	for slot = 1, MB_LOYALTY_WINDOW_DAYS do
		self:_setQuestFactInt(loyaltySampleKey("day", slot), 0)
		self:_setQuestFactInt(loyaltySampleKey("balance", slot), 0)
	end
	self:_setQuestFactInt(MB_LOYALTY_LAST_SAMPLE_DAY, 0)
	self:_setQuestFactInt(MB_LOYALTY_LAST_BALANCE, 0)
	self:_setQuestFactInt(MB_LOYALTY_SAMPLE_COUNT, 0)
	self:_setQuestFactInt(MB_LOYALTY_AVERAGE_BALANCE, 0)
	self:_setQuestFactInt(MB_LOYALTY_MIN_BALANCE, 0)
	self:_setQuestFactInt(MB_LOYALTY_QUALIFIED_TIER, 0)
	self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
	self:_setQuestFactInt(MB_LOYALTY_LAST_SYNC_DAY, 0)
end

function BANK:_collectLoyaltyWindow(currentDay)
	local today = math.max(math.floor(tonumber(currentDay) or 0), 0)
	local firstDay = today - (MB_LOYALTY_WINDOW_DAYS - 1)
	local total = 0
	local minimum = nil
	local count = 0
	local samples = {}
	for day = firstDay, today do
		if day >= 0 then
			local amount = self:_readLoyaltySample(day)
			if amount ~= nil then
				count = count + 1
				total = total + amount
				if minimum == nil or amount < minimum then minimum = amount end
				table.insert(samples, { day = day, balance = amount })
			end
		end
	end
	local average = 0
	if count > 0 then average = math.floor((total / count) + 0.5) end
	if minimum == nil then minimum = 0 end
	return count, average, minimum, samples
end

function BANK:_updateLoyaltySamples(currentDay, balance)
	local today = math.max(math.floor(tonumber(currentDay) or 0), 0)
	local amount = math.max(math.floor(tonumber(balance) or 0), 0)
	local encodedLast = self:_getQuestFactInt(MB_LOYALTY_LAST_SAMPLE_DAY)
	local lastDay = encodedLast - 1
	local previousBalance = math.max(self:_getQuestFactInt(MB_LOYALTY_LAST_BALANCE), 0)

	if encodedLast <= 0 or lastDay < 0 or today < lastDay then
		self:_clearLoyaltySamples()
		self:_writeLoyaltySample(today, amount)
	elseif today == lastDay then
		self:_writeLoyaltySample(today, amount)
	else
		local firstMissingDay = lastDay + 1
		if today - firstMissingDay + 1 > MB_LOYALTY_WINDOW_DAYS then
			firstMissingDay = today - (MB_LOYALTY_WINDOW_DAYS - 1)
		end
		for day = firstMissingDay, today do
			local sampleBalance = day == today and amount or previousBalance
			self:_writeLoyaltySample(day, sampleBalance)
		end
	end

	local count, average, minimum = self:_collectLoyaltyWindow(today)
	self:_setQuestFactInt(MB_LOYALTY_SAMPLE_COUNT, count)
	self:_setQuestFactInt(MB_LOYALTY_AVERAGE_BALANCE, average)
	self:_setQuestFactInt(MB_LOYALTY_MIN_BALANCE, minimum)
	self:_setQuestFactInt(MB_LOYALTY_LAST_SYNC_DAY, today + 1)
	return count, average, minimum
end

function BANK:_getHighestQualifiedLoyaltyTier(sampleCount, average, minimum)
	if math.floor(tonumber(sampleCount) or 0) < MB_LOYALTY_WINDOW_DAYS then return 0 end
	local avg = math.max(math.floor(tonumber(average) or 0), 0)
	local minBalance = math.max(math.floor(tonumber(minimum) or 0), 0)
	for i = #MB_LOYALTY_TIERS, 2, -1 do
		local tier = MB_LOYALTY_TIERS[i]
		local threshold = math.max(math.floor(tonumber(tier.threshold) or 0), 0)
		local floor = self:_getLoyaltyRetentionFloor(tier.index)
		if avg >= threshold and minBalance >= floor then
			return tier.index
		end
	end
	return 0
end

function BANK:_mirrorLoyaltyTierToSystem(tierIndex, system)
	local tier = math.floor(tonumber(tierIndex) or 0)
	if tier < 0 then tier = 0 end
	if tier > 4 then tier = 4 end
	self:_setQuestFactInt(MB_LOYALTY_ACTIVE_TIER, tier)
	system = system or self:getUnifiedSystem()
	if system then
		pcall(function() system:SetRelationshipTierFromLua(tier) end)
	end
	return tier
end

function BANK:_notifyLoyaltyEvent(eventName, oldTierIndex, newTierIndex, floor, days)
	local oldName = self:_getLoyaltyTierMeta(oldTierIndex).name
	local newName = self:_getLoyaltyTierMeta(newTierIndex).name
	local message = nil
	if eventName == "upgrade" then
		message = "Marmur Bank loyalty upgraded: " .. tostring(newName)
	elseif eventName == "risk" then
		message = "Marmur Bank: " .. tostring(oldName) .. " protected for " .. tostring(days or MB_LOYALTY_GRACE_DAYS) .. " days. Restore the 7-day average to E$ " .. Util.formatNumber(floor or 0) .. "."
	elseif eventName == "restored" then
		message = "Marmur Bank: " .. tostring(oldName) .. " loyalty protection restored."
	elseif eventName == "downgrade" then
		message = "Marmur Bank loyalty adjusted: " .. tostring(oldName) .. " → " .. tostring(newName)
	end
	if message then pcall(function() Util.simpleScreenMessage(message) end) end
end

function BANK:_initializeLoyaltyProgram(balance, currentDay, accountOpen)
	local amount = math.max(math.floor(tonumber(balance) or 0), 0)
	local today = math.max(math.floor(tonumber(currentDay) or 0), 0)
	self:_setQuestFactInt(MB_LOYALTY_VERSION_FACT, MB_LOYALTY_SCHEMA_VERSION)
	self:_setQuestFactInt(MB_LOYALTY_INITIALIZED, 1)
	self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
	self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
	self:_clearLoyaltySamples()

	local grandfather = accountOpen == true and self:hasAccountEverOpened() == true
	local activeTier = grandfather and self:_getLoyaltyTierIndexForBalance(amount) or 0
	self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, activeTier > 0 and 1 or 0)
	self:_setQuestFactInt(MB_LOYALTY_LAST_CHANGE_DAY, today + 1)
	self:_mirrorLoyaltyTierToSystem(activeTier)
	if accountOpen == true then self:_writeLoyaltySample(today, amount) end
	return activeTier
end

function BANK:prepareLoyaltyProgramForAccountOpening()
	local today = self:_getCurrentGameDay()
	self:_setQuestFactInt(MB_LOYALTY_VERSION_FACT, MB_LOYALTY_SCHEMA_VERSION)
	self:_setQuestFactInt(MB_LOYALTY_INITIALIZED, 1)
	self:_setQuestFactInt(MB_LOYALTY_ACTIVE_TIER, 0)
	self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, 0)
	self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
	self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
	self:_setQuestFactInt(MB_LOYALTY_LAST_CHANGE_DAY, today + 1)
	self:_clearLoyaltySamples()
	self:_mirrorLoyaltyTierToSystem(0)
	return true
end

function BANK:resetLoyaltyProgram(clearHistory)
	self:_setQuestFactInt(MB_LOYALTY_ACTIVE_TIER, 0)
	self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, 0)
	self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
	self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
	if clearHistory == true then self:_clearLoyaltySamples() end
	self:_mirrorLoyaltyTierToSystem(0)
	return true
end

function BANK:syncLoyaltyProgram(balance, force)
	if self.loyaltySyncInProgress == true then return false end
	self.loyaltySyncInProgress = true

	local ok, changed = pcall(function()
		local today = self:_getCurrentGameDay()
		local amount = tonumber(balance)
		if amount == nil then amount = self:getUnifiedBalance() end
		amount = math.max(math.floor(tonumber(amount) or 0), 0)

		local accountOpen = self:getAccountOpenFlag() > 0
		if not accountOpen and amount > 0 then
			pcall(function() accountOpen = self:isAccountOpen() == true end)
		end

		if self:_getQuestFactInt(MB_LOYALTY_INITIALIZED) <= 0 then
			self:_initializeLoyaltyProgram(amount, today, accountOpen)
		end

		if accountOpen ~= true then
			local hadRelationship = self:_getQuestFactInt(MB_LOYALTY_ACTIVE_TIER) > 0 or self:_getQuestFactInt(MB_LOYALTY_SAMPLE_COUNT) > 0
			if hadRelationship then self:resetLoyaltyProgram(true) else self:_mirrorLoyaltyTierToSystem(0) end
			return hadRelationship
		end

		if force ~= true
			and self:_getQuestFactInt(MB_LOYALTY_LAST_SYNC_DAY) == today + 1
			and self:_getQuestFactInt(MB_LOYALTY_LAST_BALANCE) == amount then
			self:_mirrorLoyaltyTierToSystem(self:_getQuestFactInt(MB_LOYALTY_ACTIVE_TIER))
			return false
		end

		local count, average, minimum = self:_updateLoyaltySamples(today, amount)
		local activeTier = math.floor(tonumber(self:_getQuestFactInt(MB_LOYALTY_ACTIVE_TIER)) or 0)
		if activeTier < 0 then activeTier = 0 end
		if activeTier > 4 then activeTier = 4 end
		local oldActiveTier = activeTier
		local qualifiedTier = self:_getHighestQualifiedLoyaltyTier(count, average, minimum)
		self:_setQuestFactInt(MB_LOYALTY_QUALIFIED_TIER, qualifiedTier)

		local riskEncoded = self:_getQuestFactInt(MB_LOYALTY_RISK_START_DAY)
		local riskDay = riskEncoded - 1
		local stateChanged = false

		if qualifiedTier > activeTier then
			activeTier = qualifiedTier
			self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
			self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
			self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, 0)
			self:_setQuestFactInt(MB_LOYALTY_LAST_CHANGE_DAY, today + 1)
			self:_mirrorLoyaltyTierToSystem(activeTier)
			self:_notifyLoyaltyEvent("upgrade", oldActiveTier, activeTier)
			stateChanged = true
		elseif count >= MB_LOYALTY_WINDOW_DAYS and activeTier > 0 then
			local floor = self:_getLoyaltyRetentionFloor(activeTier)
			if average >= floor then
				if riskEncoded > 0 then
					self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
					self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
					self:_notifyLoyaltyEvent("restored", activeTier, activeTier)
					stateChanged = true
				end
			else
				local targetTier = self:_getLoyaltyTierIndexForBalance(average)
				if targetTier >= activeTier then targetTier = math.max(activeTier - 1, 0) end
				self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, targetTier)
				if riskEncoded <= 0 or riskDay < 0 or today < riskDay then
					self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, today + 1)
					self:_notifyLoyaltyEvent("risk", activeTier, targetTier, floor, MB_LOYALTY_GRACE_DAYS)
					stateChanged = true
				elseif today - riskDay >= MB_LOYALTY_GRACE_DAYS then
					local previousTier = activeTier
					activeTier = targetTier
					self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
					self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
					self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, 0)
					self:_setQuestFactInt(MB_LOYALTY_LAST_CHANGE_DAY, today + 1)
					self:_mirrorLoyaltyTierToSystem(activeTier)
					self:_notifyLoyaltyEvent("downgrade", previousTier, activeTier)
					stateChanged = true
				end
			end
		elseif activeTier <= 0 then
			self:_setQuestFactInt(MB_LOYALTY_RISK_START_DAY, 0)
			self:_setQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER, 0)
		end

		if count >= MB_LOYALTY_WINDOW_DAYS then
			self:_setQuestFactInt(MB_LOYALTY_GRANDFATHERED, 0)
		end
		self:_mirrorLoyaltyTierToSystem(activeTier)
		return stateChanged or activeTier ~= oldActiveTier
	end)

	self.loyaltySyncInProgress = false
	if ok then return changed == true end
	return false
end

function BANK:getLoyaltyTierIndex(balance)
	pcall(function() self:syncLoyaltyProgram(balance, false) end)
	local tier = self:_getQuestFactInt(MB_LOYALTY_ACTIVE_TIER)
	if tier < 0 then tier = 0 end
	if tier > 4 then tier = 4 end
	return tier
end

function BANK:getLoyaltySummary(balance)
	local amount = tonumber(balance)
	if amount == nil then amount = self:getUnifiedBalance() end
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	pcall(function() self:syncLoyaltyProgram(amount, false) end)

	local today = self:_getCurrentGameDay()
	local activeTier = self:_getQuestFactInt(MB_LOYALTY_ACTIVE_TIER)
	if activeTier < 0 then activeTier = 0 end
	if activeTier > 4 then activeTier = 4 end
	local activeMeta = self:_getLoyaltyTierMeta(activeTier)
	local count = math.max(self:_getQuestFactInt(MB_LOYALTY_SAMPLE_COUNT), 0)
	local average = math.max(self:_getQuestFactInt(MB_LOYALTY_AVERAGE_BALANCE), 0)
	local minimum = math.max(self:_getQuestFactInt(MB_LOYALTY_MIN_BALANCE), 0)
	local qualifiedTier = math.max(self:_getQuestFactInt(MB_LOYALTY_QUALIFIED_TIER), 0)
	local riskEncoded = self:_getQuestFactInt(MB_LOYALTY_RISK_START_DAY)
	local riskDay = riskEncoded - 1
	local atRisk = riskEncoded > 0 and riskDay >= 0
	local graceDaysRemaining = 0
	if atRisk then graceDaysRemaining = math.max(MB_LOYALTY_GRACE_DAYS - (today - riskDay), 0) end
	local historyReady = count >= MB_LOYALTY_WINDOW_DAYS
	local retentionFloor = self:_getLoyaltyRetentionFloor(activeTier)
	local nextMeta = activeTier < 4 and self:_getLoyaltyTierMeta(activeTier + 1) or nil
	local nextNeeded = nextMeta and math.max((nextMeta.threshold or 0) - average, 0) or 0
	local pendingTier = self:_getQuestFactInt(MB_LOYALTY_PENDING_DOWNGRADE_TIER)
	if pendingTier < 0 then pendingTier = 0 end
	if pendingTier > 4 then pendingTier = 4 end
	local statusCode = "standard"
	local statusLabel = "Standard relationship"
	local statusText = "Build a seven-day savings history to earn the next account level."

	if self:getAccountOpenFlag() <= 0 then
		statusCode = "closed"
		statusLabel = "Account closed"
		statusText = "Open an account to begin the seven-day loyalty history."
	elseif not historyReady then
		statusCode = activeTier > 0 and "grandfathered_history" or "building_history"
		statusLabel = tostring(count) .. "/" .. tostring(MB_LOYALTY_WINDOW_DAYS) .. " days tracked"
		if activeTier > 0 then
			statusText = tostring(activeMeta.name) .. " remains protected while Marmur builds the new seven-day history."
		else
			statusText = "Building seven-day history — " .. tostring(math.max(MB_LOYALTY_WINDOW_DAYS - count, 0)) .. " more day(s) before the first level review."
		end
	elseif atRisk then
		statusCode = "grace"
		statusLabel = "Protected — " .. tostring(graceDaysRemaining) .. " day(s) left"
		statusText = "Raise the seven-day average to E$ " .. Util.formatNumber(retentionFloor) .. " before the grace period ends."
	elseif activeTier > 0 and average < (activeMeta.threshold or 0) then
		statusCode = "protected"
		statusLabel = "Earned level protected"
		statusText = "The seven-day average is below the upgrade threshold but remains above the E$ " .. Util.formatNumber(retentionFloor) .. " protection floor."
	elseif activeTier > 0 then
		statusCode = "qualified"
		statusLabel = "Level fully qualified"
		statusText = "The seven-day average currently supports " .. tostring(activeMeta.name) .. "."
	else
		statusCode = "standard"
		statusLabel = "Seven-day history active"
		statusText = nextMeta and ("Average E$ " .. Util.formatNumber(nextNeeded) .. " more to reach " .. tostring(nextMeta.name) .. ".") or statusText
	end

	local _, _, _, samples = self:_collectLoyaltyWindow(today)
	return {
		activeTier = activeTier,
		tier = activeMeta.name,
		threshold = activeMeta.threshold,
		cashbackBp = activeMeta.cashbackBp,
		interestBp = activeMeta.interestBp,
		currentBalance = amount,
		averageBalance = average,
		minimumBalance = minimum,
		sampleCount = count,
		daysTracked = count,
		daysUntilReview = math.max(MB_LOYALTY_WINDOW_DAYS - count, 0),
		windowDays = MB_LOYALTY_WINDOW_DAYS,
		historyReady = historyReady,
		retentionPercent = MB_LOYALTY_RETENTION_PERCENT,
		retentionFloor = retentionFloor,
		graceDays = MB_LOYALTY_GRACE_DAYS,
		atRisk = atRisk,
		graceDaysRemaining = graceDaysRemaining,
		pendingDowngradeTier = pendingTier,
		pendingDowngradeTierName = self:_getLoyaltyTierMeta(pendingTier).name,
		qualifiedTier = qualifiedTier,
		qualifiedTierName = self:_getLoyaltyTierMeta(qualifiedTier).name,
		grandfathered = self:_getQuestFactInt(MB_LOYALTY_GRANDFATHERED) > 0,
		nextTierIndex = nextMeta and nextMeta.index or nil,
		nextTierName = nextMeta and nextMeta.name or nil,
		nextThreshold = nextMeta and nextMeta.threshold or 0,
		nextProtectionFloor = nextMeta and self:_getLoyaltyRetentionFloor(nextMeta.index) or 0,
		nextNeeded = nextNeeded,
		statusCode = statusCode,
		statusLabel = statusLabel,
		statusText = statusText,
		samples = samples,
	}
end

function BANK:getManagedInterestBasisPoints(balance)
	local tier = self:getLoyaltyTierIndex(balance)
	return math.floor(tonumber(self:_getLoyaltyTierMeta(tier).interestBp) or 1)
end

function BANK:getManagedInterestPercent(balance)
	return (tonumber(self:getManagedInterestBasisPoints(balance)) or 1) / 100.0
end

function BANK:getAccountLevelName(balance)
	return self:_getLoyaltyTierMeta(self:getLoyaltyTierIndex(balance)).name
end

function BANK:getCashbackRateBasisPoints(balance)
	local tier = self:getLoyaltyTierIndex(balance)
	return math.floor(tonumber(self:_getLoyaltyTierMeta(tier).cashbackBp) or 100)
end

function BANK:getCashbackRatePercent(balance)
	return (tonumber(self:getCashbackRateBasisPoints(balance)) or 0) / 100.0
end

function BANK:getCashbackDestinationCode()
	local code = self:_getQuestFactInt(MB_CASHBACK_DESTINATION)
	if code == 2 then return 2 end
	return 1
end

function BANK:getCashbackDestination()
	return self:getCashbackDestinationCode() == 2 and "savings" or "checking"
end

function BANK:getCashbackDestinationLabel()
	return self:getCashbackDestinationCode() == 2 and "Savings" or "Checking"
end

function BANK:setCashbackDestination(destination)
	local text = string.lower(tostring(destination or ""))
	local code = 1
	if text == "2" or text == "saving" or text == "savings" or text == "bank" then
		code = 2
	end
	self:_setQuestFactInt(MB_CASHBACK_DESTINATION, code)
	return true
end

function BANK:getCashbackPayoutIntervalDays()
	return MB_CASHBACK_PAYOUT_INTERVAL_DAYS
end

function BANK:getCashbackPayoutHour()
	return MB_CASHBACK_PAYOUT_HOUR
end

function BANK:_getCashbackPayoutMinuteOfDay()
	return (MB_CASHBACK_PAYOUT_HOUR * 60) + MB_CASHBACK_PAYOUT_MINUTE
end

function BANK:_buildFirstCashbackPayoutStamp(fromStamp)
	local stamp = math.max(math.floor(tonumber(fromStamp) or self:_getCurrentGameMinuteStamp()), 0)
	local day = math.floor(stamp / 1440) + MB_CASHBACK_PAYOUT_INTERVAL_DAYS
	return (day * 1440) + self:_getCashbackPayoutMinuteOfDay()
end

function BANK:_advanceCashbackPayoutStamp(previousStamp, currentStamp)
	local intervalMinutes = MB_CASHBACK_PAYOUT_INTERVAL_DAYS * 1440
	local now = math.max(math.floor(tonumber(currentStamp) or self:_getCurrentGameMinuteStamp()), 0)
	local nextStamp = math.floor(tonumber(previousStamp) or 0)
	if nextStamp <= 0 then
		return self:_buildFirstCashbackPayoutStamp(now)
	end
	nextStamp = nextStamp + intervalMinutes
	if nextStamp <= now then
		local missedIntervals = math.floor((now - nextStamp) / intervalMinutes) + 1
		nextStamp = nextStamp + (missedIntervals * intervalMinutes)
	end
	return nextStamp
end

function BANK:ensureCashbackPayoutSchedule(forceReset)
	if not self:isAccountOpen() then return false end
	local currentStamp = self:_getCurrentGameMinuteStamp()
	local nextStamp = self:_getQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP)
	if forceReset == true or nextStamp <= 0 then
		nextStamp = self:_buildFirstCashbackPayoutStamp(currentStamp)
		self:_setQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP, nextStamp)
		return true
	end
	return true
end

function BANK:formatCashbackPayoutNextLabel(nextStamp)
	local target = math.floor(tonumber(nextStamp) or 0)
	if target <= 0 then return "Not scheduled" end
	local current = self:_getCurrentGameMinuteStamp()
	local delta = target - current
	local timeLabel = self:formatLoanTimeStamp(target)
	if delta <= 0 then return "Pending payout" end
	local days = math.floor(delta / 1440)
	local hours = math.floor((delta - (days * 1440)) / 60)
	if days <= 0 then
		if hours <= 0 then return "Today at " .. timeLabel end
		if hours == 1 then return "In 1 hour at " .. timeLabel end
		return "In " .. tostring(hours) .. " hours at " .. timeLabel
	end
	if days == 1 then return "Tomorrow at " .. timeLabel end
	return "In " .. tostring(days) .. " days at " .. timeLabel
end

function BANK:formatCashbackPayoutDaysLeftLabel(nextStamp)
	local target = math.floor(tonumber(nextStamp) or 0)
	if target <= 0 then return "Not scheduled" end
	local current = self:_getCurrentGameMinuteStamp()
	local delta = target - current
	if delta <= 0 then return "Due now" end
	local days = math.floor(delta / 1440)
	local hours = math.floor((delta - (days * 1440)) / 60)
	local minutes = math.floor(delta - (days * 1440) - (hours * 60))
	if days > 0 then
		if hours > 0 then
			return tostring(days) .. "d " .. tostring(hours) .. "h left"
		end
		if days == 1 then return "1 day left" end
		return tostring(days) .. " days left"
	end
	if hours > 0 then
		if minutes > 0 then
			return tostring(hours) .. "h " .. tostring(minutes) .. "m left"
		end
		if hours == 1 then return "1 hour left" end
		return tostring(hours) .. " hours left"
	end
	if minutes <= 1 then return "Less than 1m left" end
	return tostring(minutes) .. "m left"
end

function BANK:resetCashbackPayoutState(silent)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_EARNED, 0)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_SPEND, 0)
	self:_setQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP, 0)
	if silent ~= true then
		pcall(function() Util.simpleScreenMessage("Marmur Bank cashback schedule reset") end)
	end
end

function BANK:processCashbackPayoutSchedule()
	if not self:isAccountOpen() or not self:hasAccountEverOpened() then return false end
	self:ensureCashbackPayoutSchedule(false)

	local currentStamp = self:_getCurrentGameMinuteStamp()
	local nextStamp = self:_getQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP)
	if nextStamp <= 0 then return false end
	if currentStamp < nextStamp then return false end

	local payout = math.max(self:_getQuestFactInt(MB_CASHBACK_PENDING_EARNED), 0)
	local eligibleSpend = math.max(self:_getQuestFactInt(MB_CASHBACK_PENDING_SPEND), 0)
	local followingStamp = self:_advanceCashbackPayoutStamp(nextStamp, currentStamp)

	if payout <= 0 then
		self:_setQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP, followingStamp)
		return false
	end

	local destinationCode = self:getCashbackDestinationCode()
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local bankBefore = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	local bankAfter = bankBefore
	local walletBefore = math.floor(tonumber(self:getWalletBalance()) or 0)
	local walletAfter = walletBefore
	local ok = false

	if destinationCode == 2 then
		bankAfter = bankBefore + payout
		self:forceUnifiedBalance(bankAfter, system, gameInstance)
		walletAfter = math.floor(tonumber(self:getWalletBalance()) or walletBefore)
		ok = true
	else
		ok = self:_addWalletMoney(payout)
		walletAfter = math.floor(tonumber(self:getWalletBalance()) or walletBefore)
		bankAfter = math.floor(tonumber(self:getUnifiedBalance()) or bankBefore)
	end

	if ok ~= true then
		return false
	end

	self:_setQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP, followingStamp)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_EARNED, 0)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_SPEND, 0)
	self:_setQuestFactInt(MB_CASHBACK_TOTAL_EARNED, self:_getQuestFactInt(MB_CASHBACK_TOTAL_EARNED) + payout)
	self:_setQuestFactInt(MB_CASHBACK_TOTAL_SPEND, self:_getQuestFactInt(MB_CASHBACK_TOTAL_SPEND) + eligibleSpend)
	self:_setQuestFactInt(MB_CASHBACK_LAST_EARNED, payout)
	self:_setQuestFactInt(MB_CASHBACK_LAST_SPEND, eligibleSpend)
	self:_setQuestFactInt(MB_CASHBACK_LAST_RATE_BP, self:getCashbackRateBasisPoints(self:getUnifiedBalance()))
	self:_setQuestFactInt(MB_CASHBACK_LAST_DESTINATION, destinationCode)
	self:_setQuestFactInt(MB_CASHBACK_LAST_PAYOUT_STAMP, currentStamp)
	self:_setQuestFactInt(MB_CASHBACK_LAST_PAYOUT_SPEND, eligibleSpend)

	self:_recordCashbackCredit(payout, destinationCode, bankBefore, bankAfter, walletBefore, walletAfter, system, gameInstance)
	self:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("New text from Marmur Bank: weekly cashback payout — " .. Util.formatNumber(payout) .. " E$ to " .. self:getCashbackDestinationLabel() .. ". Open Messages to view.")
	end)
	return true
end

function BANK:getCashbackSummary()
	pcall(function() self:updateWalletSpendMonitor(true) end)
	pcall(function() self:_flushPendingWalletSpend(false) end)
	local balance = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	local loyalty = self:getLoyaltySummary(balance)
	local rateBp = math.floor(tonumber(loyalty.cashbackBp) or self:getCashbackRateBasisPoints(balance))
	if self:isAccountOpen() then
		self:ensureCashbackPayoutSchedule(false)
	end
	local nextPayoutStamp = self:_getQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP)
	return {
		destination = self:getCashbackDestination(),
		destinationLabel = self:getCashbackDestinationLabel(),
		rateBp = rateBp,
		ratePercent = rateBp / 100.0,
		tier = tostring(loyalty.tier or self:getAccountLevelName(balance)),
		loyalty = loyalty,
		totalEarned = math.max(self:_getQuestFactInt(MB_CASHBACK_TOTAL_EARNED), 0),
		totalSpend = math.max(self:_getQuestFactInt(MB_CASHBACK_TOTAL_SPEND), 0),
		pendingEarned = math.max(self:_getQuestFactInt(MB_CASHBACK_PENDING_EARNED), 0),
		pendingSpend = math.max(self:_getQuestFactInt(MB_CASHBACK_PENDING_SPEND), 0),
		nextPayoutStamp = nextPayoutStamp,
		nextPayoutLabel = self:formatCashbackPayoutNextLabel(nextPayoutStamp),
		daysLeftLabel = self:formatCashbackPayoutDaysLeftLabel(nextPayoutStamp),
		payoutTimeLabel = nextPayoutStamp > 0 and self:formatLoanTimeStamp(nextPayoutStamp) or "3:00 PM",
		payoutIntervalDays = MB_CASHBACK_PAYOUT_INTERVAL_DAYS,
		payoutHour = MB_CASHBACK_PAYOUT_HOUR,
		lastPayoutStamp = math.max(self:_getQuestFactInt(MB_CASHBACK_LAST_PAYOUT_STAMP), 0),
		lastPayoutSpend = math.max(self:_getQuestFactInt(MB_CASHBACK_LAST_PAYOUT_SPEND), 0),
		lastEarned = math.max(self:_getQuestFactInt(MB_CASHBACK_LAST_EARNED), 0),
		lastSpend = math.max(self:_getQuestFactInt(MB_CASHBACK_LAST_SPEND), 0),
		lastRateBp = math.max(self:_getQuestFactInt(MB_CASHBACK_LAST_RATE_BP), 0),
		lastDestination = self:_getQuestFactInt(MB_CASHBACK_LAST_DESTINATION) == 2 and "Savings" or "Checking",
	}
end

function BANK:_recordCashbackCredit(amount, destinationCode, bankBefore, bankAfter, walletBefore, walletAfter, system, gameInstance)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return end
	destinationCode = destinationCode == 2 and 2 or 1
	system = system or self:getUnifiedSystem()
	gameInstance = gameInstance or self:getGameInstance()
	local recorded = false
	if system and gameInstance then
		pcall(function()
			if system.RecordCashbackCredit then
				system:RecordCashbackCredit(gameInstance, amount, destinationCode, math.floor(tonumber(bankBefore) or 0), math.floor(tonumber(bankAfter) or 0), math.floor(tonumber(walletBefore) or 0), math.floor(tonumber(walletAfter) or 0))
				recorded = true
			end
		end)
	end
	if recorded ~= true then
		self:_storeWalletTxFact(20, amount, walletBefore, walletAfter, 0, destinationCode)
	end
end

function BANK:_awardCashbackForSpend(amount, walletBefore, walletAfter, system, gameInstance)
	if not self:isAccountOpen() or not self:hasAccountEverOpened() then return 0 end
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return 0 end

	local rateBp = self:getCashbackRateBasisPoints(self:getUnifiedBalance())
	if rateBp <= 0 then return 0 end
	local reward = math.floor(((amount * rateBp) / 10000) + 0.5)
	if reward <= 0 then return 0 end

	self:ensureCashbackPayoutSchedule(false)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_EARNED, self:_getQuestFactInt(MB_CASHBACK_PENDING_EARNED) + reward)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_SPEND, self:_getQuestFactInt(MB_CASHBACK_PENDING_SPEND) + amount)
	self:_setQuestFactInt(MB_CASHBACK_LAST_RATE_BP, rateBp)
	return reward
end

function BANK:_awardCashbackForLoanPayment(amount, walletBefore, walletAfter, system, gameInstance)
	return self:_awardCashbackForSpend(amount, walletBefore, walletAfter, system, gameInstance)
end

function BANK:_markLastTransactionCashbackEarned(cashbackEarned)
	local reward = math.max(math.floor(tonumber(cashbackEarned) or 0), 0)
	if reward <= 0 then return end
	local system = self:getUnifiedSystem()
	if not system then return end
	pcall(function()
		if system.SetLastTransactionCashbackEarned then
			system:SetLastTransactionCashbackEarned(reward)
		end
	end)
end

function BANK:getMinimumOpeningDeposit()
	return 250
end

function BANK:getWelcomeIncentiveHoldMinutes()
	return 72 * 60
end

function BANK:getWelcomeIncentiveChargebackMinutes()
	return 30 * 24 * 60
end

function BANK:getOpeningIncentiveAmount(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount >= 50000000 then return 1500000 end
	if amount >= 10000000 then return 500000 end
	if amount >= 1000000 then return 100000 end
	if amount >= 500000 then return 50000 end
	if amount >= 100000 then return 20000 end
	if amount >= 25000 then return 7500 end
	if amount >= 5000 then return 3000 end
	if amount >= 1000 then return 1500 end
	if amount >= self:getMinimumOpeningDeposit() then return 500 end
	return 0
end

function BANK:hasPriorAccountHistory()
	if self:_getQuestFactInt(MB_ACCOUNT_EVER_OPENED) > 0 then return true end
	if self:_getQuestFactInt(MB_ACCOUNT_LAST_CLOSED_DAY) > 0 then return true end
	if self:_getQuestFactInt(MB_ACCOUNT_NUMBER_LEFT) > 0 or self:_getQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT) > 0 then return true end
	return false
end

function BANK:_generateAccountNumberParts()
	self:_ensureLoanConfirmationSeed()
	local day = self:_getCurrentGameDay() % 10000
	local left = 1000 + (day % 9000)
	local right = math.random(10000000, 99999999)
	return left, right
end

function BANK:_assignNewAccountNumber()
	local left, right = self:_generateAccountNumberParts()
	self:_setQuestFactInt(MB_ACCOUNT_NUMBER_LEFT, left)
	self:_setQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT, right)
	return self:getAccountNumberText()
end

function BANK:getAccountNumberText()
	local left = self:_getQuestFactInt(MB_ACCOUNT_NUMBER_LEFT)
	local right = self:_getQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT)
	if left <= 0 or right <= 0 then
		local newLeft, newRight = self:_generateAccountNumberParts()
		self:_setQuestFactInt(MB_ACCOUNT_NUMBER_LEFT, newLeft)
		self:_setQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT, newRight)
		left = self:_getQuestFactInt(MB_ACCOUNT_NUMBER_LEFT)
		right = self:_getQuestFactInt(MB_ACCOUNT_NUMBER_RIGHT)
	end
	if left <= 0 or right <= 0 then
		return "MB-2077-00000000"
	end
	return string.format("MB-%04d-%08d", left % 10000, right % 100000000)
end

function BANK:getAccountOpenMinute()
	return self:_getQuestFactInt(MB_ACCOUNT_OPEN_MINUTE)
end

function BANK:getAccountAgeMinutes()
	local opened = self:getAccountOpenMinute()
	if opened <= 0 then return 0 end
	local age = self:_getCurrentGameMinuteStamp() - opened
	if age < 0 then age = 0 end
	return age
end

function BANK:getPendingOpeningIncentiveAmount()
	if self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID) > 0 then return 0 end
	return math.max(self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING), 0)
end

function BANK:getPaidOpeningIncentiveAmount()
	if self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID) <= 0 then return 0 end
	return math.max(self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID_AMOUNT), 0)
end

function BANK:getOpeningIncentiveEligibleMinute()
	return self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_ELIGIBLE_MINUTE)
end

function BANK:getOpeningIncentiveCountdownMinutes()
	local pending = self:getPendingOpeningIncentiveAmount()
	if pending <= 0 then return 0 end
	local remaining = self:getOpeningIncentiveEligibleMinute() - self:_getCurrentGameMinuteStamp()
	if remaining < 0 then remaining = 0 end
	return remaining
end

function BANK:formatMinutesAsShortDuration(minutes)
	minutes = math.max(math.floor(tonumber(minutes) or 0), 0)
	local days = math.floor(minutes / 1440)
	local hours = math.floor((minutes % 1440) / 60)
	local mins = minutes % 60
	if days > 0 then
		return tostring(days) .. "d " .. tostring(hours) .. "h"
	end
	if hours > 0 then
		return tostring(hours) .. "h " .. tostring(mins) .. "m"
	end
	return tostring(mins) .. "m"
end

function BANK:getOpeningIncentiveStatusText()
	local paid = self:getPaidOpeningIncentiveAmount()
	if paid > 0 then
		return "Paid: E$ " .. Util.formatNumber(paid)
	end
	local pending = self:getPendingOpeningIncentiveAmount()
	if pending > 0 then
		return "Pending: E$ " .. Util.formatNumber(pending) .. " / " .. self:formatMinutesAsShortDuration(self:getOpeningIncentiveCountdownMinutes())
	end
	return "None"
end

function BANK:getOpeningIncentiveChargebackAmount()
	if not self:isAccountOpen() then return 0 end
	if self:_getQuestFactInt(MB_ACCOUNT_INCENTIVE_CHARGED_BACK) > 0 then return 0 end
	local paid = self:getPaidOpeningIncentiveAmount()
	if paid <= 0 then return 0 end
	if self:getAccountAgeMinutes() < self:getWelcomeIncentiveChargebackMinutes() then
		return paid
	end
	return 0
end

function BANK:processPendingOpeningIncentive()
	if not self:isAccountOpen() then return false end
	local pending = self:getPendingOpeningIncentiveAmount()
	if pending <= 0 then return false end
	local eligible = self:getOpeningIncentiveEligibleMinute()
	if eligible <= 0 then return false end
	if self:_getCurrentGameMinuteStamp() < eligible then return false end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local currentBalance = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	self:forceUnifiedBalance(currentBalance + pending, system, gameInstance)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID, 1)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID_AMOUNT, pending)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID_MINUTE, self:_getCurrentGameMinuteStamp())
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING, 0)
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank welcome credit paid: " .. Util.formatNumber(pending) .. " E$")
	end)
	self:_storeLoanSmsThreadEntry("BON", pending, self:getWalletBalance(), self:getWalletBalance(), self:_generateLoanConfirmationCode("BON"))
	return true
end

function BANK:_sendLoanSmsScreenNotification(kind, amount)
	if self:isJohnnySuppressed() then return end
	local textKind = tostring(kind or "")
	local label = "secure banking message posted"
	if textKind == "REQ" then label = "loan request received" end
	if textKind == "APR" then label = "loan decision ready" end
	if textKind == "DEN" then label = "loan request denied" end
	if textKind == "SIG" then label = "loan agreement signed" end
	if textKind == "APP" then label = "loan funds deposited" end
	if textKind == "PAY" then label = "loan payment confirmed" end
	if textKind == "AUT" then label = "scheduled loan payment posted" end
	if textKind == "MIS" then label = "loan payment issue posted" end
	if textKind == "FUL" then label = "loan paid in full" end
	if textKind == "REM" then label = "loan payment reminder" end
	if textKind == "AOP" then label = "welcome message" end
	if textKind == "ARB" then label = "welcome back message" end
	if textKind == "BON" then label = "welcome credit paid" end
	if textKind == "CBK" then label = "early closure fee" end
	if textKind == "VAA" then label = "auto loan approved" end
	if textKind == "VAP" then label = "auto-loan payment confirmed" end
	if textKind == "VAF" then label = "auto loan paid in full" end
	if textKind == "VAD" then label = "auto loan denied" end
	if textKind == "LQD" then label = "default recovery posted" end
	if textKind == "VCN" then label = "coverage compliance notice" end
	if textKind == "VCD" then label = "coverage default review" end

	local suffix = ""
	local safeAmount = math.floor(tonumber(amount) or 0)
	if safeAmount > 0 and Util and Util.formatNumber then
		suffix = " — " .. Util.formatNumber(safeAmount) .. " E$"
	end

	pcall(function()
		Util.simpleScreenMessage("New text from Marmur Bank: " .. label .. suffix .. ". Open Messages to view.")
	end)
end

function BANK:_hasStoredAccountWelcomeText()
	local count = self:_getQuestFactInt("marmur_loan_sms_count")
	if count < 0 then count = 0 end
	if count > 5 then count = 5 end
	for slot = 1, count do
		local eventType = self:_getQuestFactInt("marmur_loan_sms_type_" .. tostring(slot))
		if eventType == 11 or eventType == 12 then
			return true
		end
	end
	return false
end

function BANK:ensureAccountPhoneThread()
	if self:isJohnnySuppressed() then
		local phoneGate = self:getMarmurPhoneGateSystem()
		local gameInstance = self:getGameInstance()
		if phoneGate and gameInstance then
			pcall(function() phoneGate:Deactivate(gameInstance) end)
		end
		return false
	end
	if self:_getQuestFactInt(MB_ACCOUNT_EVER_OPENED) <= 0 then
		return false
	end

	if self:_getQuestFactInt(MB_ACCOUNT_WELCOME_THREAD_READY) <= 0 then
		if self:_hasStoredAccountWelcomeText() then
			self:_setQuestFactInt(MB_ACCOUNT_WELCOME_THREAD_READY, 1)
		elseif self:isAccountOpen() then
			local amount = math.max(math.floor(tonumber(self:getUnifiedBalance()) or 0), 0)
			local kind = self:_getQuestFactInt(MB_ACCOUNT_LAST_CLOSED_DAY) > 0 and "ARB" or "AOP"
			self:_storeLoanSmsThreadEntry(kind, amount, self:getWalletBalance(), self:getWalletBalance(), self:_generateLoanConfirmationCode(kind))
			self:_setQuestFactInt(MB_ACCOUNT_WELCOME_THREAD_READY, 1)
		end
	end

	local phoneGate = self:getMarmurPhoneGateSystem()
	local gameInstance = self:getGameInstance()
	if phoneGate and gameInstance then
		pcall(function()
			if phoneGate.EnsureActive then
				phoneGate:EnsureActive(gameInstance)
			else
				phoneGate:Activate(gameInstance)
			end
		end)
	end
	return true
end

function BANK:openAccountWithDeposit(amount)
	amount = math.floor(tonumber(amount) or 0)
	if self:isAccountOpen() then
		return false, "existing", 0, 0, self:getAccountNumberText()
	end
	if amount <= 0 then
		return false, "amount", 0, 0, ""
	end
	if amount < self:getMinimumOpeningDeposit() then
		return false, "minimum", 0, 0, ""
	end
	if self:getWalletBalance() < amount then
		return false, "funds", 0, 0, ""
	end

	local reopening = self:hasPriorAccountHistory()
	local openStamp = self:_getCurrentGameMinuteStamp()
	local bonus = math.floor(tonumber(self:getOpeningIncentiveAmount(amount)) or 0)

	if not reopening then
		self:_clearPreAccountActivity()
	end

	self:prepareLoyaltyProgramForAccountOpening()

	self:setAccountOpenFlag(true)
	self:_setQuestFactInt(MB_ACCOUNT_OPEN_MINUTE, openStamp)
	self:_setQuestFactInt(MB_ACCOUNT_OPEN_INCENTIVE, bonus)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING, bonus)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_ELIGIBLE_MINUTE, openStamp + self:getWelcomeIncentiveHoldMinutes())
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID, 0)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID_AMOUNT, 0)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PAID_MINUTE, 0)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_CHARGED_BACK, 0)
	self:_setQuestFactInt(MB_ACCOUNT_WELCOME_THREAD_READY, 0)
	local ok = self:depositMoney(amount)
	if not ok then
		self:setAccountOpenFlag(false)
		self:_setQuestFactInt(MB_ACCOUNT_OPEN_MINUTE, 0)
		self:_setQuestFactInt(MB_ACCOUNT_OPEN_INCENTIVE, 0)
		self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING, 0)
		self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_ELIGIBLE_MINUTE, 0)
		return false, "deposit", 0, 0, ""
	end

	self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
	local accountNumber = self:_assignNewAccountNumber()

	local codeKind = reopening and "ARB" or "AOP"
	self:_storeLoanSmsThreadEntry(codeKind, amount, self:getWalletBalance(), self:getWalletBalance(), self:_generateLoanConfirmationCode(codeKind))
	self:_setQuestFactInt(MB_ACCOUNT_WELCOME_THREAD_READY, 1)
	self:ensureCashbackPayoutSchedule(true)

	local phoneGate = self:getMarmurPhoneGateSystem()
	local gameInstance = self:getGameInstance()
	if phoneGate and gameInstance then
		pcall(function()
			if phoneGate.EnsureActive then
				phoneGate:EnsureActive(gameInstance)
			else
				phoneGate:Activate(gameInstance)
			end
		end)
	end

	pcall(function()
		local msg = "Marmur Bank account opened: " .. Util.formatNumber(amount) .. " E$ deposited"
		if bonus > 0 then msg = msg .. "; " .. Util.formatNumber(bonus) .. " E$ welcome credit pending 72 hours" end
		Util.simpleScreenMessage(msg)
	end)
	return true, "opened", amount, bonus, accountNumber, reopening
end

function BANK:closeAccount()
	if not self:isAccountOpen() then
		return false, "no_account", 0, 0
	end
	if self:hasLoanObligation() then
		return false, "loan", 0, 0
	end

	local pending = self:getPendingOpeningIncentiveAmount()
	local chargeback = self:getOpeningIncentiveChargebackAmount()
	local amount = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	local walletBefore = self:getWalletBalance()
	if chargeback > 0 and (walletBefore + amount) < chargeback then
		return false, "fee_funds", amount, chargeback
	end

	local ok = true
	if amount > 0 then
		ok = self:withdrawMoney(amount)
	end
	if not ok then
		return false, "withdraw", amount, chargeback
	end

	if chargeback > 0 then
		local feeBefore = self:getWalletBalance()
		pcall(function() Util.handlingMoney("remove", chargeback) end)
		local feeAfter = self:getWalletBalance()
		self:_storeWalletTxFact(14, chargeback, feeBefore, feeAfter, 0)
		self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_CHARGED_BACK, 1)
		self:_storeLoanSmsThreadEntry("CBK", chargeback, feeBefore, feeAfter, self:_generateLoanConfirmationCode("CBK"))
	elseif pending > 0 then
		self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING, 0)
	end

	self:cancelAutoDeposit(true)
	self:resetCashbackPayoutState(true)

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	self:forceUnifiedBalance(0, system, gameInstance)
	self:setAccountOpenFlag(false)
	self:resetLoyaltyProgram(true)
	self:_setQuestFactInt(MB_ACCOUNT_LAST_CLOSED_DAY, self:_getCurrentGameDay())
	self:_setQuestFactInt(MB_ACCOUNT_OPEN_MINUTE, 0)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_PENDING, 0)
	self:_setQuestFactInt(MB_ACCOUNT_INCENTIVE_ELIGIBLE_MINUTE, 0)
	pcall(function() self:hideHub() end)
	self:_syncWalletSnapshot()
	pcall(function()
		local msg = "Marmur Bank account closed. Returned " .. Util.formatNumber(amount) .. " E$"
		if chargeback > 0 then msg = msg .. "; early closure fee " .. Util.formatNumber(chargeback) .. " E$" end
		Util.simpleScreenMessage(msg)
	end)
	return true, "closed", amount, chargeback
end

function BANK:_repairAccountLifecycleFromBalance(balance)
	local amount = math.floor(tonumber(balance) or 0)
	if amount <= 0 then return false end
	if self:getAccountOpenFlag() <= 0 then
		self:setAccountOpenFlag(true)
	end
	if self:_getQuestFactInt(MB_ACCOUNT_EVER_OPENED) <= 0 then
		self:_setQuestFactInt(MB_ACCOUNT_EVER_OPENED, 1)
	end
	return true
end

function BANK:getUnifiedBalance()
	local factBalance = math.max(math.floor(tonumber(self:getFactBalance()) or 0), 0)
	local backupBalance = math.max(math.floor(tonumber(self:getBalanceBackupFact()) or 0), 0)
	local legacyBalance = math.max(factBalance, backupBalance)
	local migrationVersion = math.floor(tonumber(self:_getQuestFactInt(MB_BALANCE_MIGRATION_VERSION)) or 0)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local systemBalance = nil

	if legacyBalance > 0 and backupBalance ~= legacyBalance then
		self:setBalanceBackupFact(legacyBalance)
	end

	if system and gameInstance then
		local preInterestBalance = nil
		pcall(function() preInterestBalance = math.floor(tonumber(system:GetBalance()) or 0) end)
		if preInterestBalance ~= nil and self:getAccountOpenFlag() > 0 then
			pcall(function() self:syncLoyaltyProgram(preInterestBalance, false) end)
		end

		pcall(function()
			system:SyncInterest(gameInstance)
		end)

		local ok, balance = pcall(function()
			return system:GetBalance()
		end)

		if ok and balance ~= nil then
			systemBalance = math.floor(tonumber(balance) or 0)
		end
	end

	if systemBalance ~= nil then
		if migrationVersion < MB_BALANCE_MIGRATION_CURRENT and systemBalance <= 0 and legacyBalance > 0 then
			local imported = self:syncFactBalanceIntoUnifiedSystem(legacyBalance, system, gameInstance)
			local confirmedBalance = nil
			if imported then
				pcall(function()
					confirmedBalance = math.floor(tonumber(system:GetBalance()) or 0)
				end)
			end

			if confirmedBalance ~= nil and confirmedBalance > 0 then
				self:setFactBalance(confirmedBalance)
				self:_repairAccountLifecycleFromBalance(confirmedBalance)
				pcall(function() self:syncLoyaltyProgram(confirmedBalance, false) end)
				return confirmedBalance
			end

			if factBalance ~= legacyBalance then
				self:_setQuestFactInt(MB_DEPOSIT, legacyBalance)
			end
			self:setBalanceBackupFact(legacyBalance)
			self:_repairAccountLifecycleFromBalance(legacyBalance)
			pcall(function() self:syncLoyaltyProgram(legacyBalance, false) end)
			return legacyBalance
		end

		if factBalance ~= systemBalance or backupBalance ~= systemBalance or migrationVersion < MB_BALANCE_MIGRATION_CURRENT then
			self:setFactBalance(systemBalance)
		end

		self:_repairAccountLifecycleFromBalance(systemBalance)
		pcall(function() self:syncLoyaltyProgram(systemBalance, false) end)
		return systemBalance
	end

	if legacyBalance > 0 and factBalance ~= legacyBalance then
		self:_setQuestFactInt(MB_DEPOSIT, legacyBalance)
	end
	self:_repairAccountLifecycleFromBalance(legacyBalance)
	pcall(function() self:syncLoyaltyProgram(legacyBalance, false) end)
	return legacyBalance
end

function BANK:_normalizeWalletValue(value)
	if value == nil then return nil end
	local numeric = tonumber(value)
	if numeric == nil then return nil end
	numeric = math.floor(numeric)
	if numeric < 0 then return nil end
	return numeric
end

function BANK:_walletLedgerAudit(message)
	if self.walletLedgerAuditEnabled ~= true then return end
	local text = tostring(message or "")
	if text == "" then return end
	pcall(function()
		local seq = self:_getQuestFactInt(MB_WALLET_LEDGER_AUDIT_SEQ) + 1
		if seq <= 0 then seq = 1 end
		self:_setQuestFactInt(MB_WALLET_LEDGER_AUDIT_SEQ, seq)
		local file = io.open("wallet_ledger_audit.log", "a")
		if file then
			local stamp = os.date("%Y-%m-%d %H:%M:%S") or "time"
			file:write("[", stamp, "] #", tostring(seq), " ", text, "\n")
			file:close()
		end
	end)
end

function BANK:_saveTrustedWalletBaseline(value, reason)
	local wallet = self:_normalizeWalletValue(value)
	if wallet == nil then return false end

	self.lastWalletSnapshot = wallet
	self.lastWalletReadValid = true
	self.lastWalletUnreadableSince = 0

	if self.cachedTrustedWalletBaselineSet == true and self.cachedTrustedWalletBaseline == wallet then
		return true
	end

	local stamp = self:_getCurrentGameMinuteStamp()
	self.cachedTrustedWalletBaseline = wallet
	self.cachedTrustedWalletBaselineSet = true
	self.cachedTrustedWalletBaselineStamp = stamp

	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE, wallet)
	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE_SET, 1)
	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE_STAMP, stamp)
	return true
end

function BANK:_updateRuntimeWalletSnapshot(value, source)
	local wallet = self:_normalizeWalletValue(value)
	if wallet == nil then return false end
	self.lastWalletSnapshot = wallet
	self.lastWalletReadValid = true
	self.lastWalletReadSource = tostring(source or "runtime")
	self.lastWalletUnreadableSince = 0
	return true
end

function BANK:_loadTrustedWalletBaseline()
	if self.cachedTrustedWalletBaselineSet == true then
		return self.cachedTrustedWalletBaseline
	end

	if self:_getQuestFactInt(MB_WALLET_LEDGER_BASELINE_SET) <= 0 then
		self.cachedTrustedWalletBaseline = nil
		self.cachedTrustedWalletBaselineSet = false
		return nil
	end

	local wallet = self:_normalizeWalletValue(self:_getQuestFactInt(MB_WALLET_LEDGER_BASELINE))
	if wallet ~= nil then
		self.cachedTrustedWalletBaseline = wallet
		self.cachedTrustedWalletBaselineSet = true
		self.cachedTrustedWalletBaselineStamp = self:_getQuestFactInt(MB_WALLET_LEDGER_BASELINE_STAMP)
	end
	return wallet
end

function BANK:_primeWalletSessionIfNeeded(wallet)
	wallet = self:_normalizeWalletValue(wallet)
	if wallet == nil then return false end
	if self.walletSessionPrimed == true then return true end

	local now = os.clock()
	local candidate = self:_normalizeWalletValue(self.walletSessionPrimeCandidate)
	local candidateTime = tonumber(self.walletSessionPrimeCandidateTime) or 0
	if candidate ~= nil and candidate == wallet and candidateTime > 0 and now - candidateTime >= 0.45 then
		self.walletSessionPrimed = true
		self.walletSessionPrimeCandidate = wallet
		self.walletSessionPrimeCandidateTime = now
		self:_resetPendingWalletSpend()
		self:_saveTrustedWalletBaseline(wallet, "session_prime_confirmed")
		return false
	end

	self.walletSessionPrimeCandidate = wallet
	self.walletSessionPrimeCandidateTime = now
	self:_resetPendingWalletSpend()
	self:_saveTrustedWalletBaseline(wallet, "session_prime_candidate")
	return false
end

function BANK:_markWalletUnreadable(source)
	self.lastWalletReadValid = false
	self.lastWalletReadSource = tostring(source or "unreadable")
	if (tonumber(self.lastWalletUnreadableSince) or 0) <= 0 then
		self.lastWalletUnreadableSince = os.clock()
	end
end

function BANK:_tryReadWalletBalance()
	local player = nil
	local okPlayer = pcall(function()
		if Game and Game.GetPlayer then
			player = Game.GetPlayer()
		end
	end)
	if not okPlayer or player == nil then
		self:_markWalletUnreadable("player_unavailable")
		return nil, false, "player_unavailable"
	end

	local okTs, tsValue = pcall(function()
		local ts = self:_getCachedTransactionSystem()
		local moneyItemID = self:_getMoneyItemID()
		if ts and player and moneyItemID ~= nil then
			return ts:GetItemQuantity(player, moneyItemID)
		end
		return nil
	end)
	local canonical = okTs and self:_normalizeWalletValue(tsValue) or nil
	if canonical ~= nil then
		self.lastWalletReadValid = true
		self.lastWalletReadSource = "transaction_system"
		self.lastWalletUnreadableSince = 0
		return canonical, true, "transaction_system"
	end

	local okDirect, direct = pcall(function()
		return Util.handlingMoney("check", nil)
	end)
	local directValue = okDirect and self:_normalizeWalletValue(direct) or nil
	if directValue ~= nil then
		self.lastWalletReadValid = true
		self.lastWalletReadSource = "util_handling_money"
		self.lastWalletUnreadableSince = 0
		return directValue, true, "util_handling_money"
	end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		local ok, balance = pcall(function()
			return system:GetWalletBalance(gameInstance)
		end)
		local systemValue = ok and self:_normalizeWalletValue(balance) or nil
		if systemValue ~= nil then
			self.lastWalletReadValid = true
			self.lastWalletReadSource = "night_city_bank_system"
			self.lastWalletUnreadableSince = 0
			return systemValue, true, "night_city_bank_system"
		end
	end

	self:_markWalletUnreadable("no_wallet_reader")
	return nil, false, "no_wallet_reader"
end

function BANK:getWalletBalance()
	local value, readable = self:_tryReadWalletBalance()
	if readable == true then
		return value
	end

	if self.lastWalletSnapshot ~= nil and self.lastWalletSnapshot >= 0 then
		return self.lastWalletSnapshot
	end

	local saved = self:_loadTrustedWalletBaseline()
	if saved ~= nil then return saved end
	return 0
end

function BANK:_clearExternalWalletDebitSuppression()
	local system = self:getUnifiedSystem()
	if system then
		pcall(function() system:ClearExternalWalletDebitSuppression() end)
	end
	self.localWalletDebitSuppressionAmount = 0
end

function BANK:_suppressLocalWalletDebit(amount, reason)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return end
	self.localWalletDebitSuppressionAmount = math.max(0, math.floor(tonumber(self.localWalletDebitSuppressionAmount) or 0)) + amount
	if self.walletLedgerAuditEnabled == true then
		self:_walletLedgerAudit("suppress_local amount=" .. tostring(amount) .. " total=" .. tostring(self.localWalletDebitSuppressionAmount) .. " reason=" .. tostring(reason or "marmur_owned_debit"))
	end
end

function BANK:_consumeLocalWalletDebitSuppression(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return 0, 0 end
	local suppressed = math.max(0, math.floor(tonumber(self.localWalletDebitSuppressionAmount) or 0))
	if suppressed <= 0 then return amount, 0 end
	local used = math.min(amount, suppressed)
	self.localWalletDebitSuppressionAmount = suppressed - used
	if used > 0 then
		if self.walletLedgerAuditEnabled == true then
			self:_walletLedgerAudit("consume_local_suppression requested=" .. tostring(amount) .. " used=" .. tostring(used) .. " remaining=" .. tostring(self.localWalletDebitSuppressionAmount))
		end
	end
	return amount - used, used
end

function BANK:_resetPendingWalletSpend()
	self.pendingWalletSpendAmount = 0
	self.pendingWalletSpendBefore = 0
	self.pendingWalletSpendAfter = 0
	self.pendingWalletSpendFlushTime = 0
	self.pendingWalletSpendLastChangeTime = 0
	self.pendingWalletSpendContext = "purchase"
end

function BANK:notePlayerMoneyRemoval(quantity, source)
	local now = os.clock()
	local amount = math.max(math.floor(tonumber(quantity) or 0), 0)
	local walletAfter = math.max(math.floor(tonumber(self:getWalletBalance()) or 0), 0)
	local sourceText = tostring(source or "transaction_system")
	local duplicateOverload = amount > 0
		and amount == math.floor(tonumber(self.lastPlayerMoneyRemovalAmount) or 0)
		and walletAfter == math.floor(tonumber(self.lastPlayerMoneyRemovalWalletAfter) or -1)
		and sourceText ~= tostring(self.lastPlayerMoneyRemovalSource or "")
		and now - (tonumber(self.lastPlayerMoneyRemovalTime) or 0) <= 0.05
	if duplicateOverload then return false end

	local pendingAfter = math.floor(tonumber(self.pendingWalletSpendAfter) or walletAfter)
	if (tonumber(self.pendingWalletSpendAmount) or 0) > 0 and walletAfter < pendingAfter then
		self:_flushPendingWalletSpend(true)
	end
	self.lastPlayerMoneyRemovalTime = now
	self.lastPlayerMoneyRemovalAmount = amount
	self.lastPlayerMoneyRemovalWalletAfter = walletAfter
	self.lastPlayerMoneyRemovalSource = sourceText
	if self.walletLedgerAuditEnabled == true then
		self:_walletLedgerAudit("player_money_removal amount=" .. tostring(amount) .. " walletAfter=" .. tostring(walletAfter) .. " source=" .. sourceText)
	end
	return true
end

function BANK:_markServicedLoanDebitHandled(walletAfter)
	walletAfter = math.floor(tonumber(walletAfter) or self:getWalletBalance() or 0)
	self:_clearExternalWalletDebitSuppression()
	self:_resetPendingWalletSpend()
	self.fraudBurstAmount = 0
	self.fraudBurstBefore = walletAfter
	self.fraudBurstAfter = walletAfter
	self.fraudBurstLastChangeTime = 0
	self.fraudBurstNotified = false
	self:_saveTrustedWalletBaseline(walletAfter, "serviced_loan_debit")
	self.nextWalletSpendCheckTime = os.clock() + 0.75
end

function BANK:setWalletInteractionContext(isMenuOpen, eventName)
	self.walletContextMenuOpen = isMenuOpen == true
	self.walletContextLastEvent = tostring(eventName or "")
	self.walletContextChangedAt = os.clock()
	if self.walletContextMenuOpen ~= true then
		self.walletContextRecentlyClosedUntil = self.walletContextChangedAt + 2.0
	end
end

function BANK:markTheftRecoveryWindow(reason, seconds)
	if self:isJohnnySuppressed() then return end
	local duration = tonumber(seconds) or 180
	if duration < 5 then duration = 5 end
	local untilTime = os.clock() + duration
	if untilTime > (tonumber(self.theftDetectionWindowUntil) or 0) then
		self.theftDetectionWindowUntil = untilTime
	end
	self.theftDetectionReason = tostring(reason or "recovery")
end

function BANK:_isWalletDropInMenuContext()
	local now = os.clock()
	if self.walletContextMenuOpen == true then return true end
	if now < (tonumber(self.walletContextRecentlyClosedUntil) or 0) then return true end
	return false
end

function BANK:_getPlayerCombatStateText()
	local stateText = ""
	pcall(function()
		local player = Game.GetPlayer()
		if player and player.GetCurrentCombatState then
			local state = player:GetCurrentCombatState()
			if state ~= nil and state.value ~= nil then
				stateText = tostring(state.value)
			end
		end
	end)
	return stateText
end

function BANK:_isWatchYourBackSizedLoss(amount, walletBefore)
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	if amount <= 0 or walletBefore <= 0 then return false end

	if amount == 10 and walletBefore >= 10 then return true end
	local pct = (amount / walletBefore) * 100.0
	return pct >= 0.75 and pct <= 10.75
end

function BANK:_shouldClassifyWalletDropAsTheft(amount, walletBefore, walletAfter)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	local now = os.clock()
	return now <= (tonumber(self.theftDetectionWindowUntil) or 0)
end

function BANK:_getWalletDropContext(amount, walletBefore, walletAfter)
	if self:_shouldClassifyWalletDropAsTheft(amount, walletBefore, walletAfter) then
		return "theft"
	end
	return "purchase"
end

function BANK:_queueWalletSpendDelta(delta, walletBefore, walletAfter)
	delta = math.floor(tonumber(delta) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if delta <= 0 then return end

	local context = self:_getWalletDropContext(delta, walletBefore, walletAfter)
	if (tonumber(self.pendingWalletSpendAmount) or 0) <= 0 then
		self.pendingWalletSpendAmount = delta
		self.pendingWalletSpendBefore = walletBefore
		self.pendingWalletSpendContext = context
	else
		self.pendingWalletSpendAmount = (tonumber(self.pendingWalletSpendAmount) or 0) + delta
		if walletBefore > (tonumber(self.pendingWalletSpendBefore) or 0) then
			self.pendingWalletSpendBefore = walletBefore
		end
		if self.pendingWalletSpendContext ~= context then
			self.pendingWalletSpendContext = "purchase"
		end
	end

	self.pendingWalletSpendAfter = walletAfter
	self.pendingWalletSpendLastChangeTime = os.clock()
	self.pendingWalletSpendFlushTime = self.pendingWalletSpendLastChangeTime + 0.55
end

function BANK:_flushPendingWalletSpend(force)
	local amount = math.floor(tonumber(self.pendingWalletSpendAmount) or 0)
	if amount <= 0 then
		return false
	end

	local now = os.clock()
	if force ~= true and now < (tonumber(self.pendingWalletSpendFlushTime) or 0) then
		return false
	end

	local walletBefore = math.floor(tonumber(self.pendingWalletSpendBefore) or 0)
	local walletAfter = math.floor(tonumber(self.pendingWalletSpendAfter) or 0)
	if walletBefore <= walletAfter then
		walletBefore = walletAfter + amount
	end

	local context = tostring(self.pendingWalletSpendContext or "purchase")
	self:_resetPendingWalletSpend()
	if context == "theft" then
		self:recordTheftProtectionEvent(amount, walletBefore, walletAfter)
	else
		self:recordWalletSpend(amount, walletBefore, walletAfter)
	end
	return true
end

function BANK:_syncWalletSnapshot()
	self:_flushPendingWalletSpend(true)
	local wallet, readable = self:_tryReadWalletBalance()
	if readable == true then
		self:_saveTrustedWalletBaseline(wallet, "sync")
	end
	self.nextWalletSpendCheckTime = (self.currentTime or os.clock()) + 0.25
end

function BANK:depositMoney(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then
		return false
	end

	local wallet = self:getWalletBalance()
	if wallet < amount then
		return false
	end

	local balanceBefore = self:getUnifiedBalance()
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()

	if system and gameInstance then
		local ok, result = pcall(function()
			return system:DepositFromWallet(gameInstance, amount)
		end)

		if ok and result == true then
			local balanceAfter = balanceBefore + amount
			pcall(function()
				local live = tonumber(system:GetBalance())
				if live ~= nil and live >= 0 then balanceAfter = math.floor(live) end
			end)
			self:forceUnifiedBalance(balanceAfter, system, gameInstance)
			self:_clearExternalWalletDebitSuppression()
			self:_syncWalletSnapshot()
			return true
		end
	end

	self:_suppressLocalWalletDebit(amount, "wallet_to_savings_fallback")
	Util.handlingMoney("remove", amount)
	self:forceUnifiedBalance(balanceBefore + amount, system, gameInstance)
	local walletAfter = self:getWalletBalance()
	self:_storeWalletTxFact(1, amount, wallet, walletAfter, 0)
	self:_syncWalletSnapshot()
	self.localWalletDebitSuppressionAmount = 0
	return true
end

function BANK:withdrawMoney(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then
		return false
	end

	local balanceBefore = self:getUnifiedBalance()
	if balanceBefore < amount then
		return false
	end

	local finalBalance = balanceBefore - amount
	if finalBalance < 0 then finalBalance = 0 end
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()

	if system and gameInstance then
		local ok, result = pcall(function()
			return system:WithdrawToWallet(gameInstance, amount)
		end)

		if ok and result == true then
			self:forceUnifiedBalance(finalBalance, system, gameInstance)
			self:_syncWalletSnapshot()
			return true
		end
	end

	local walletBefore = self:getWalletBalance()
	Game.AddToInventory("Items.money", amount)
	self:forceUnifiedBalance(finalBalance, system, gameInstance)
	local walletAfter = self:getWalletBalance()
	self:_storeWalletTxFact(2, amount, walletBefore, walletAfter, 0)
	self:_syncWalletSnapshot()
	return true
end



function BANK:_ensureLoanConfirmationSeed()
	if self.loanConfirmationSeeded == true then return end
	local seed = 0
	pcall(function() seed = os.time() or 0 end)
	seed = seed + (self:_getCurrentGameDay() * 1009) + math.floor(tonumber(self:getWalletBalance()) or 0)
	math.randomseed(seed)
	math.random(); math.random(); math.random()
	self.loanConfirmationSeeded = true
end

function BANK:_generateLoanConfirmationCode(kind)
	self:_ensureLoanConfirmationSeed()
	local prefix = tostring(kind or "LN")
	local day = self:_getCurrentGameDay() % 10000
	local tail = math.random(100000, 999999)
	return string.format("MB-%s-%04d-%06d", prefix, day, tail)
end

function BANK:getLastLoanConfirmationCode()
	return self.lastLoanConfirmationCode or ""
end

function BANK:_setLastLoanConfirmationCode(code)
	self.lastLoanConfirmationCode = tostring(code or "")
end

function BANK:_parseLoanConfirmationCodeParts(code)
	local text = tostring(code or "")
	local left, right = string.match(text, "MB%-%a+%-(%d+)%-(%d+)")
	return math.floor(tonumber(left) or 0), math.floor(tonumber(right) or 0)
end

local MB_LOAN_SMS_COUNT = "marmur_loan_sms_count"
local MB_LOAN_SMS_MAX = 5
local function loanSmsKey(field, slot)
	return "marmur_loan_sms_" .. tostring(field) .. "_" .. tostring(slot)
end

local MB_WALLET_TX_COUNT = "marmur_wallet_tx_count"
local MB_WALLET_TX_SEQ = "marmur_wallet_tx_seq"
local MB_WALLET_TX_MAX = 128
local MB_WALLET_TX_LEGACY_MAX = 20
local MB_WALLET_TX_RETENTION_VERSION = "marmur_wallet_tx_retention_version"
local MB_WALLET_TX_HISTORY_TRIMMED = "marmur_wallet_tx_history_trimmed"
local function walletTxKey(field, slot)
	return "marmur_wallet_tx_" .. tostring(field) .. "_" .. tostring(slot)
end

local MB_DISPUTE_CLAIM_COUNT = "marmur_dispute_claim_count"
local MB_DISPUTE_CLAIM_SEQ = "marmur_dispute_claim_seq"
local MB_DISPUTE_CLAIM_MAX = 12
local MB_DISPUTE_CLAIM_INDEX_MAX = 32
local MB_DISPUTE_FLAG_UNTIL_MINUTE = "marmur_dispute_flag_until_minute"
local MB_DISPUTE_FLAG_NOTICE_ID = "marmur_dispute_flag_notice_id"
local MB_DISPUTE_FLAG_NOTICE_ACK = "marmur_dispute_flag_notice_ack"
local MB_DISPUTE_FLAG_NOTICE_CODE = "marmur_dispute_flag_notice_code"
local MB_DISPUTE_FLAG_NOTICE_REASON = "marmur_dispute_flag_notice_reason"
local MB_DISPUTE_WINDOW_START = "marmur_dispute_window_start"
local MB_DISPUTE_WINDOW_TOTAL = "marmur_dispute_window_total"
local MB_DISPUTE_WINDOW_ACCIDENTAL = "marmur_dispute_window_accidental"
local MB_DISPUTE_WINDOW_DENIED = "marmur_dispute_window_denied"
local MB_DISPUTE_WINDOW_MINUTES = 30 * 24 * 60
local MB_DISPUTE_FLAG_MINUTES = 7 * 24 * 60

local MB_DISPUTE_STATUS_NONE = 0
local MB_DISPUTE_STATUS_PENDING = 3
local MB_DISPUTE_STATUS_APPROVED = 4
local MB_DISPUTE_STATUS_DENIED = 5

local function disputeClaimKey(field, slot)
	return "marmur_dispute_claim_" .. tostring(field) .. "_" .. tostring(slot)
end

function BANK:_clearPreAccountActivity()
	self:_setQuestFactInt(MB_WALLET_TX_COUNT, 0)
	self:_setQuestFactInt(MB_WALLET_TX_SEQ, 0)
	self:_setQuestFactInt(MB_WALLET_TX_RETENTION_VERSION, 2)
	self:_setQuestFactInt(MB_WALLET_TX_HISTORY_TRIMMED, 0)
	self:_setQuestFactInt("marmur_wallet_tx_read_count", 0)
	for slot = 1, MB_WALLET_TX_MAX do
		for _, field in ipairs({ "seq", "type", "amount", "wallet_before", "wallet_after", "day", "hour", "minute", "review_day", "review_hour", "review_minute", "fraud_reason", "dispute", "cashback", "subject", "provenance" }) do
			self:_setQuestFactInt(walletTxKey(field, slot), 0)
		end
	end

	self:_setQuestFactInt(MB_DISPUTE_CLAIM_COUNT, 0)
	self:_setQuestFactInt(MB_DISPUTE_CLAIM_SEQ, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_CODE, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_REASON, 0)
	self:_resetDisputePatternWindow(0)
	for slot = 1, MB_DISPUTE_CLAIM_MAX do
		for _, field in ipairs({ "seq", "amount", "reason", "status", "created", "due", "wallet_before", "wallet_after", "case_left", "case_right", "index_count" }) do
			self:_setQuestFactInt(disputeClaimKey(field, slot), 0)
		end
		for idx = 1, MB_DISPUTE_CLAIM_INDEX_MAX do
			self:_setQuestFactInt(disputeClaimKey("index_" .. tostring(idx), slot), 0)
		end
	end

	self:_setQuestFactInt(MB_LOAN_SMS_COUNT, 0)
	self:_setQuestFactInt("marmur_loan_sms_read_count", 0)
	for slot = 1, MB_LOAN_SMS_MAX do
		for _, field in ipairs({ "type", "amount", "wallet_before", "wallet_after", "conf_left", "conf_right", "day", "hour", "minute" }) do
			self:_setQuestFactInt(loanSmsKey(field, slot), 0)
		end
	end

	self:_setQuestFactInt(MB_CASHBACK_PENDING_EARNED, 0)
	self:_setQuestFactInt(MB_CASHBACK_PENDING_SPEND, 0)
	self:_setQuestFactInt(MB_CASHBACK_NEXT_PAYOUT_STAMP, 0)
	self:_setQuestFactInt(MB_CASHBACK_LAST_PAYOUT_STAMP, 0)
	self:_setQuestFactInt(MB_CASHBACK_LAST_PAYOUT_SPEND, 0)

	local system = self:getUnifiedSystem()
	if system then
		pcall(function() system:ClearPreAccountActivity() end)
	end

	self:_resetPendingWalletSpend()
	self.fraudBurstAmount = 0
	self.fraudBurstBefore = 0
	self.fraudBurstAfter = 0
	self.fraudBurstLastChangeTime = 0
	self.fraudBurstNotified = false
	self.lastFraudAlertScreenTime = 0
	self.lastFraudAlertScreenAmount = 0
	self.lastTheftAlertScreenTime = 0
	self.lastTheftAlertScreenAmount = 0
	self.cachedTrustedWalletBaseline = nil
	self.cachedTrustedWalletBaselineSet = false
	self.cachedTrustedWalletBaselineStamp = 0
	self.walletSessionPrimed = false
	self.walletSessionPrimeCandidate = -1
	self.walletSessionPrimeCandidateTime = 0
	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE, 0)
	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE_SET, 0)
	self:_setQuestFactInt(MB_WALLET_LEDGER_BASELINE_STAMP, 0)
	local wallet, readable = self:_tryReadWalletBalance()
	if readable == true then
		self:_saveTrustedWalletBaseline(wallet, "pre_account_reset")
		self.walletSessionPrimeCandidate = wallet
		self.walletSessionPrimeCandidateTime = os.clock()
	end
end

function BANK:_shiftLoanSmsFactSlot(fromSlot, toSlot)
	self:_setQuestFactInt(loanSmsKey("type", toSlot), self:_getQuestFactInt(loanSmsKey("type", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("amount", toSlot), self:_getQuestFactInt(loanSmsKey("amount", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("wallet_before", toSlot), self:_getQuestFactInt(loanSmsKey("wallet_before", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("wallet_after", toSlot), self:_getQuestFactInt(loanSmsKey("wallet_after", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("conf_left", toSlot), self:_getQuestFactInt(loanSmsKey("conf_left", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("conf_right", toSlot), self:_getQuestFactInt(loanSmsKey("conf_right", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("day", toSlot), self:_getQuestFactInt(loanSmsKey("day", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("hour", toSlot), self:_getQuestFactInt(loanSmsKey("hour", fromSlot)))
	self:_setQuestFactInt(loanSmsKey("minute", toSlot), self:_getQuestFactInt(loanSmsKey("minute", fromSlot)))
end

function BANK:_storeLoanSmsThreadEntry(kind, amount, walletBefore, walletAfter, code)
	local textKind = tostring(kind or "PAY")
	local eventType = 2
	if textKind == "APP" then eventType = 1 end
	if textKind == "PAY" then eventType = 2 end
	if textKind == "AUT" then eventType = 3 end
	if textKind == "MIS" then eventType = 4 end
	if textKind == "REQ" then eventType = 5 end
	if textKind == "DEN" then eventType = 6 end
	if textKind == "APR" then eventType = 7 end
	if textKind == "SIG" then eventType = 8 end
	if textKind == "FUL" then eventType = 9 end
	if textKind == "REM" then eventType = 10 end
	if textKind == "AOP" then eventType = 11 end
	if textKind == "ARB" then eventType = 12 end
	if textKind == "BON" then eventType = 13 end
	if textKind == "CBK" then eventType = 14 end
	if textKind == "VAA" then eventType = 15 end
	if textKind == "VAP" then eventType = 16 end
	if textKind == "VAF" then eventType = 17 end
	if textKind == "VAD" then eventType = 18 end
	if textKind == "LQD" then eventType = 19 end
	if textKind == "VCN" then eventType = 20 end
	if textKind == "VCD" then eventType = 21 end

	local left, right = self:_parseLoanConfirmationCodeParts(code)
	if right <= 0 then
		left = self:_getCurrentGameDay() % 10000
		right = math.random(100000, 999999)
	end

	local currentCount = self:_getQuestFactInt(MB_LOAN_SMS_COUNT)
	if currentCount < 0 then currentCount = 0 end
	if currentCount > MB_LOAN_SMS_MAX then currentCount = MB_LOAN_SMS_MAX end

	if currentCount >= MB_LOAN_SMS_MAX then
		for slot = 1, MB_LOAN_SMS_MAX - 1 do
			self:_shiftLoanSmsFactSlot(slot + 1, slot)
		end
		currentCount = MB_LOAN_SMS_MAX - 1
	end

	local slot = currentCount + 1
	local _, smsHour, smsMinute = self:_getCurrentGameTimeParts()
	self:_setQuestFactInt(loanSmsKey("type", slot), eventType)
	self:_setQuestFactInt(loanSmsKey("amount", slot), math.floor(tonumber(amount) or 0))
	self:_setQuestFactInt(loanSmsKey("wallet_before", slot), math.floor(tonumber(walletBefore) or 0))
	self:_setQuestFactInt(loanSmsKey("wallet_after", slot), math.floor(tonumber(walletAfter) or 0))
	self:_setQuestFactInt(loanSmsKey("conf_left", slot), left)
	self:_setQuestFactInt(loanSmsKey("conf_right", slot), right)
	self:_setQuestFactInt(loanSmsKey("day", slot), self:_getCurrentGameDay())
	self:_setQuestFactInt(loanSmsKey("hour", slot), smsHour)
	self:_setQuestFactInt(loanSmsKey("minute", slot), smsMinute)
	self:_setQuestFactInt(MB_LOAN_SMS_COUNT, slot)

	local readCount = self:_getQuestFactInt("marmur_loan_sms_read_count")
	if readCount >= slot then
		self:_setQuestFactInt("marmur_loan_sms_read_count", math.max(slot - 1, 0))
	end

	self:_sendLoanSmsScreenNotification(textKind, amount)
end

function BANK:_setLastTransactionConfirmationCode(code)
	local system = self:getUnifiedSystem()
	if not system then return end
	local left, right = self:_parseLoanConfirmationCodeParts(code)
	if right <= 0 then return end
	pcall(function()
		system:SetLastTransactionConfirmationParts(left, right)
	end)
end

function BANK:_recordLoanApprovalText(amount, walletBefore, walletAfter, code)
	self:_storeLoanSmsThreadEntry("APP", amount, walletBefore, walletAfter, code)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system or not gameInstance then return end
	local left, right = self:_parseLoanConfirmationCodeParts(code)
	pcall(function()
		system:RecordExternalLoanApprovalNotice(gameInstance, math.floor(tonumber(amount) or 0), math.floor(tonumber(walletBefore) or 0), math.floor(tonumber(walletAfter) or 0), left, right)
	end)
end

function BANK:_recordLoanTermsReadyText(amount, code)
	self:_storeLoanSmsThreadEntry("APR", amount, self:getWalletBalance(), self:getWalletBalance(), code)
end

function BANK:_recordLoanSignedText(amount, code)
	self:_storeLoanSmsThreadEntry("SIG", amount, self:getWalletBalance(), self:getWalletBalance(), code)
end

function BANK:_recordLoanManualPaymentText(amount, walletBefore, walletAfter, code)
	self:_storeLoanSmsThreadEntry("PAY", amount, walletBefore, walletAfter, code)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system or not gameInstance then return end
	local left, right = self:_parseLoanConfirmationCodeParts(code)
	pcall(function()
		system:RecordExternalLoanManualPaymentNotice(gameInstance, math.floor(tonumber(amount) or 0), math.floor(tonumber(walletBefore) or 0), math.floor(tonumber(walletAfter) or 0), left, right)
	end)
end

function BANK:_recordLoanPayoffText(amount, walletBefore, walletAfter, code)
	self:_storeLoanSmsThreadEntry("FUL", amount, walletBefore, walletAfter, code)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system or not gameInstance then return end
	local left, right = self:_parseLoanConfirmationCodeParts(code)
	pcall(function()
		system:RecordExternalLoanManualPaymentNotice(gameInstance, math.floor(tonumber(amount) or 0), math.floor(tonumber(walletBefore) or 0), math.floor(tonumber(walletAfter) or 0), left, right)
	end)
end

function BANK:_recordLoanAutoPaymentText(amount, walletBefore, walletAfter, code)
	self:_storeLoanSmsThreadEntry("AUT", amount, walletBefore, walletAfter, code)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system or not gameInstance then return end
	local left, right = self:_parseLoanConfirmationCodeParts(code)
	pcall(function()
		system:RecordExternalLoanAutoPaymentNotice(gameInstance, math.floor(tonumber(amount) or 0), math.floor(tonumber(walletBefore) or 0), math.floor(tonumber(walletAfter) or 0), left, right)
	end)
end

function BANK:_recordLoanReminderText(amount, code)
	self:_storeLoanSmsThreadEntry("REM", amount, self:getWalletBalance(), self:getWalletBalance(), code)
end

local MB_LOAN_FALLBACK_OFFERS = {
	{ index = 1, principal = 50000, requiredStreetCred = 1, interestBasisPoints = 2400, termPayments = 12, intervalDays = 30 },
	{ index = 2, principal = 1000000, requiredStreetCred = 8, interestBasisPoints = 2122, termPayments = 24, intervalDays = 30 },
	{ index = 3, principal = 5000000, requiredStreetCred = 15, interestBasisPoints = 1843, termPayments = 36, intervalDays = 30 },
	{ index = 4, principal = 25000000, requiredStreetCred = 29, interestBasisPoints = 1286, termPayments = 60, intervalDays = 30 },
	{ index = 5, principal = 100000000, requiredStreetCred = 50, interestBasisPoints = 450, termPayments = 84, intervalDays = 30 },
}

local MB_LOAN_FACT_ACTIVE = "marmur_loan_active"
local MB_LOAN_FACT_OFFER = "marmur_loan_offer"
local MB_LOAN_FACT_PRINCIPAL = "marmur_loan_principal"
local MB_LOAN_FACT_ORIGINAL_DUE = "marmur_loan_original_due"
local MB_LOAN_FACT_BALANCE = "marmur_loan_balance_due"
local MB_LOAN_FACT_INSTALLMENT = "marmur_loan_installment"
local MB_LOAN_FACT_RATE = "marmur_loan_rate_bp"
local MB_LOAN_FACT_TERM = "marmur_loan_term"
local MB_LOAN_FACT_TERM_MONTHS = "marmur_loan_term_months"
local MB_LOAN_FACT_PAYMENTS = "marmur_loan_payments_made"
local MB_LOAN_FACT_START_DAY = "marmur_loan_start_day"
local MB_LOAN_FACT_NEXT_DUE = "marmur_loan_next_due_day"
local MB_LOAN_FACT_LAST_PAYMENT = "marmur_loan_last_payment_day"
local MB_LOAN_FACT_MISSED = "marmur_loan_missed_payments"
local MB_LOAN_FACT_TOTAL_BORROWED = "marmur_loan_total_borrowed"
local MB_LOAN_FACT_TOTAL_REPAID = "marmur_loan_total_repaid"
local MB_LOAN_FACT_LAST_REMINDER_DUE = "marmur_loan_last_reminder_due_day"

local MB_LOAN_REVIEW_ACTIVE = "marmur_loan_review_active"
local MB_LOAN_REVIEW_AMOUNT = "marmur_loan_review_amount"
local MB_LOAN_REVIEW_SUBMIT_DAY = "marmur_loan_review_submit_day"
local MB_LOAN_REVIEW_DECISION_DAY = "marmur_loan_review_decision_day"
local MB_LOAN_REVIEW_REQUIRED_SC = "marmur_loan_review_required_sc"
local MB_LOAN_REVIEW_RATE = "marmur_loan_review_rate_bp"
local MB_LOAN_REVIEW_TERM = "marmur_loan_review_term"
local MB_LOAN_REVIEW_TERM_MONTHS = "marmur_loan_review_term_months"
local MB_LOAN_REVIEW_TOTAL_DUE = "marmur_loan_review_total_due"
local MB_LOAN_REVIEW_INSTALLMENT = "marmur_loan_review_installment"
local MB_LOAN_REVIEW_SUBMIT_MINUTE = "marmur_loan_review_submit_minute"
local MB_LOAN_REVIEW_START_MINUTE = "marmur_loan_review_start_minute"
local MB_LOAN_REVIEW_DECISION_MINUTE = "marmur_loan_review_decision_minute"
local MB_LOAN_REVIEW_FREQUENCY = "marmur_loan_review_frequency"
local MB_LOAN_REVIEW_INTERVAL = "marmur_loan_review_interval"
local MB_LOAN_REVIEW_APPROVAL_CHANCE = "marmur_loan_review_approval_chance"
local MB_LOAN_REVIEW_RISK_CODE = "marmur_loan_review_risk_code"
local MB_LOAN_FUNDING_DUE_MINUTE = "marmur_loan_funding_due_minute"
local MB_LOAN_FACT_INTERVAL = "marmur_loan_payment_interval"

local MB_LOAN_STATE_NONE = 0
local MB_LOAN_STATE_UNDER_REVIEW = 1
local MB_LOAN_STATE_APPROVED_UNSIGNED = 2
local MB_LOAN_STATE_FUNDING_PENDING = 3

local MB_LOAN_BUSINESS_OPEN_MINUTE = 9 * 60
local MB_LOAN_BUSINESS_CLOSE_MINUTE = 17 * 60

local MB_LOAN_MIN_TERM_MONTHS = 12
local MB_LOAN_MAX_TERM_MONTHS = 84
local MB_LOAN_DEFAULT_TERM_MONTHS = 36

local MB_LOAN_FREQUENCY_OPTIONS = {
	weekly = { code = 1, label = "Weekly", intervalDays = 7, termMultiplier = 4 },
	biweekly = { code = 2, label = "Biweekly", intervalDays = 14, termMultiplier = 2 },
	monthly = { code = 3, label = "Monthly", intervalDays = 30, termMultiplier = 1 },
}

local MB_LOAN_MIN_PRINCIPAL = 50000
local MB_LOAN_ABSOLUTE_MAX = 100000000
local MB_LOAN_MAX_APR_BASIS_POINTS = 2400
local MB_LOAN_MIN_APR_BASIS_POINTS = 450
local MB_LOAN_PRINCIPAL_CURVE = 2.35

function BANK:_getQuestSystem()
	if self.cachedQuestSystem ~= nil then
		return self.cachedQuestSystem
	end

	local now = self:_getNow(false)
	if now > 0 and now < (tonumber(self.nextQuestSystemLookupTime or 0) or 0) then
		return nil
	end

	local ok, questsSystem = pcall(function()
		if Game and Game.GetQuestsSystem then
			return Game.GetQuestsSystem()
		end
		return nil
	end)
	if ok and questsSystem ~= nil then
		self.cachedQuestSystem = questsSystem
		self.nextQuestSystemLookupTime = 0
		return questsSystem
	end

	self.nextQuestSystemLookupTime = now + 0.50
	return nil
end

function BANK:_getQuestFactInt(key)
	local questsSystem = self:_getQuestSystem()
	if questsSystem == nil then
		return 0
	end

	local ok, value = pcall(function()
		return questsSystem:GetFactStr(key)
	end)
	if not ok or value == nil then
		return 0
	end
	return math.floor(tonumber(value) or 0)
end

function BANK:_setQuestFactInt(key, value)
	local questsSystem = self:_getQuestSystem()
	if questsSystem == nil then return end

	local safe = math.floor(tonumber(value) or 0)
	pcall(function()
		questsSystem:SetFactStr(key, safe)
	end)
end

function BANK:getManualLoanMaxPrincipal()
	return MB_LOAN_ABSOLUTE_MAX
end

function BANK:getLoanMaxForStreetCred(streetCred)
	local sc = math.floor(tonumber(streetCred) or 0)
	if sc < 1 then return 0 end
	if sc > 50 then sc = 50 end
	if sc == 50 then return MB_LOAN_ABSOLUTE_MAX end

	local ratio = (sc - 1) / 49.0
	local amount = MB_LOAN_MIN_PRINCIPAL + math.floor((MB_LOAN_ABSOLUTE_MAX - MB_LOAN_MIN_PRINCIPAL) * (ratio ^ MB_LOAN_PRINCIPAL_CURVE))
	amount = math.floor(amount / 1000) * 1000
	if amount < MB_LOAN_MIN_PRINCIPAL then amount = MB_LOAN_MIN_PRINCIPAL end
	if amount >= MB_LOAN_ABSOLUTE_MAX then amount = MB_LOAN_ABSOLUTE_MAX - 1000 end
	return amount
end

function BANK:getLoanAPRForStreetCred(streetCred)
	local sc = math.floor(tonumber(streetCred) or 0)
	if sc < 1 then return MB_LOAN_MAX_APR_BASIS_POINTS end
	if sc > 50 then sc = 50 end
	local spread = MB_LOAN_MAX_APR_BASIS_POINTS - MB_LOAN_MIN_APR_BASIS_POINTS
	local basisPoints = MB_LOAN_MAX_APR_BASIS_POINTS - math.floor(((sc - 1) * spread) / 49)
	if basisPoints < MB_LOAN_MIN_APR_BASIS_POINTS then basisPoints = MB_LOAN_MIN_APR_BASIS_POINTS end
	if basisPoints > MB_LOAN_MAX_APR_BASIS_POINTS then basisPoints = MB_LOAN_MAX_APR_BASIS_POINTS end
	return basisPoints
end

function BANK:getRequiredCreditLevelForAmount(amount)
	local principal = math.floor(tonumber(amount) or 0)
	if principal <= 0 then return 1 end
	for sc = 1, 50 do
		if principal <= self:getLoanMaxForStreetCred(sc) then
			return sc
		end
	end
	return 51
end

function BANK:getManualLoanApprovalChance(amount, streetCred)
	local principal = math.floor(tonumber(amount) or 0)
	local sc = math.floor(tonumber(streetCred) or self:getStreetCredLevel() or 0)
	if principal <= 0 or principal > MB_LOAN_ABSOLUTE_MAX then return 0 end
	if sc < 1 then return 0 end
	if sc > 50 then sc = 50 end

	local requiredLevel = self:getRequiredCreditLevelForAmount(principal)
	if requiredLevel > 50 then return 0 end
	if principal >= MB_LOAN_ABSOLUTE_MAX and sc < 50 then return 0 end

	local currentMax = math.max(self:getLoanMaxForStreetCred(sc), MB_LOAN_MIN_PRINCIPAL)
	local useRatio = principal / currentMax
	local chance = 0

	if sc < requiredLevel then
		local shortage = requiredLevel - sc
		chance = 3 + (sc * 0.30) - (shortage * 4.50)
	else
		local buffer = sc - requiredLevel
		chance = 45 + (sc * 0.50) + (buffer * 1.20) - (useRatio * 28)
		if useRatio < 0.35 then
			chance = chance + ((0.35 - useRatio) * 55)
		end
	end

	if chance < 0 then chance = 0 end
	if chance > 98 then chance = 98 end
	return math.floor(chance + 0.5)
end

function BANK:getManualLoanApprovalRiskCode(chance)
	local value = math.floor(tonumber(chance) or 0)
	if value >= 70 then return 1 end
	if value >= 35 then return 2 end
	return 3
end

function BANK:getManualLoanApprovalRiskLabel(chanceOrCode)
	local code = math.floor(tonumber(chanceOrCode) or 0)
	if code < 1 or code > 3 then
		code = self:getManualLoanApprovalRiskCode(chanceOrCode)
	end
	if code == 1 then return "LOW" end
	if code == 2 then return "MEDIUM" end
	return "HIGH"
end

function BANK:_getLoanFrequencyMeta(frequency)
	local value = frequency
	if value == nil or value == "" then value = "monthly" end
	if type(value) == "number" then
		for _, meta in pairs(MB_LOAN_FREQUENCY_OPTIONS) do
			if meta.code == math.floor(value) then
				return meta
			end
		end
	end
	local key = string.lower(tostring(value or "monthly"))
	if key == "bi-weekly" or key == "bi weekly" or key == "every two weeks" then key = "biweekly" end
	return MB_LOAN_FREQUENCY_OPTIONS[key] or MB_LOAN_FREQUENCY_OPTIONS.monthly
end

function BANK:getLoanFrequencyLabel(frequency)
	return self:_getLoanFrequencyMeta(frequency).label
end

function BANK:getLoanFrequencyCode(frequency)
	return self:_getLoanFrequencyMeta(frequency).code
end

function BANK:_clampLoanTermMonths(termMonths)
	local months = math.floor(tonumber(termMonths) or MB_LOAN_DEFAULT_TERM_MONTHS)
	if months < MB_LOAN_MIN_TERM_MONTHS then months = MB_LOAN_MIN_TERM_MONTHS end
	if months > MB_LOAN_MAX_TERM_MONTHS then months = MB_LOAN_MAX_TERM_MONTHS end
	return months
end

function BANK:_getLoanPaymentsPerYear(frequency)
	local freq = self:_getLoanFrequencyMeta(frequency)
	local label = tostring(freq.label or "Monthly")
	if label == "Weekly" then return 52 end
	if label == "Biweekly" then return 26 end
	return 12
end

function BANK:_getLoanPaymentCountForTerm(termMonths, frequency)
	local months = self:_clampLoanTermMonths(termMonths)
	local paymentsPerYear = self:_getLoanPaymentsPerYear(frequency)
	local term = math.ceil((months * paymentsPerYear) / 12)
	if term < 1 then term = 1 end
	return term
end

function BANK:_deriveLoanTermMonths(termPayments, intervalDays)
	local payments = math.max(math.floor(tonumber(termPayments) or 0), 0)
	local interval = math.max(math.floor(tonumber(intervalDays) or 30), 1)
	if payments <= 0 then return 0 end
	local months = math.floor(((payments * interval) / 30) + 0.5)
	if months < MB_LOAN_MIN_TERM_MONTHS then months = MB_LOAN_MIN_TERM_MONTHS end
	if months > MB_LOAN_MAX_TERM_MONTHS then months = MB_LOAN_MAX_TERM_MONTHS end
	return months
end

function BANK:_calculateAmortizedLoanTotal(principal, interestBasisPoints, termMonths, frequency)
	local amount = math.max(math.floor(tonumber(principal) or 0), 0)
	local rate = math.max(math.floor(tonumber(interestBasisPoints) or 0), 0)
	local months = self:_clampLoanTermMonths(termMonths)
	local term = self:_getLoanPaymentCountForTerm(months, frequency)
	if amount <= 0 then
		return 0, 0, term, months
	end
	if rate <= 0 then
		local noInterestInstallment = math.ceil(amount / math.max(term, 1))
		return noInterestInstallment * term, noInterestInstallment, term, months
	end

	local annualRate = rate / 10000.0
	local periodsPerYear = self:_getLoanPaymentsPerYear(frequency)
	local periodicRate = annualRate / math.max(periodsPerYear, 1)
	local denominator = 1.0 - ((1.0 + periodicRate) ^ (-term))
	local installment = 0
	if denominator > 0 then
		installment = math.ceil((amount * periodicRate) / denominator)
	else
		installment = math.ceil(amount / math.max(term, 1))
	end
	local totalDue = installment * term
	if totalDue < amount then totalDue = amount end
	return totalDue, installment, term, months
end

function BANK:getManualLoanQuote(amount, frequency, termMonths)
	local principal = math.floor(tonumber(amount) or 0)
	local streetCred = math.floor(tonumber(self:getStreetCredLevel()) or 0)
	local requiredLevel = self:getRequiredCreditLevelForAmount(principal)
	local rate = self:getLoanAPRForStreetCred(streetCred)
	local currentMax = self:getLoanMaxForStreetCred(streetCred)
	local approvalChance = self:getManualLoanApprovalChance(principal, streetCred)
	local riskCode = self:getManualLoanApprovalRiskCode(approvalChance)
	local freq = self:_getLoanFrequencyMeta(frequency)
	local months = self:_clampLoanTermMonths(termMonths)
	local totalDue, installment, term = self:_calculateAmortizedLoanTotal(principal, rate, months, frequency)
	return {
		principal = principal,
		requiredStreetCred = requiredLevel,
		interestBasisPoints = rate,
		interestPercent = rate / 100.0,
		aprLocked = true,
		approvalChance = approvalChance,
		approvalRiskCode = riskCode,
		approvalRiskLabel = self:getManualLoanApprovalRiskLabel(riskCode),
		termPayments = term,
		termMonths = months,
		baseTermPayments = months,
		intervalDays = math.floor(tonumber(freq.intervalDays) or 30),
		frequencyCode = math.floor(tonumber(freq.code) or 3),
		frequencyLabel = tostring(freq.label or "Monthly"),
		totalDue = totalDue,
		installment = installment,
		maxPrincipal = currentMax,
	}
end

function BANK:_getLoanFallbackOffer(index)
	index = math.floor(tonumber(index) or 0)
	for _, offer in ipairs(MB_LOAN_FALLBACK_OFFERS) do
		if offer.index == index then
			return offer
		end
	end
	return nil
end

function BANK:_getLoanFallbackTotalDue(offer)
	if not offer then return 0 end
	local principal = tonumber(offer.principal) or 0
	local rate = tonumber(offer.interestBasisPoints) or 0
	local interest = math.floor((principal * rate + 5000) / 10000)
	return principal + interest
end

function BANK:_getLoanFallbackInstallment(offer)
	if not offer then return 0 end
	local totalDue = self:_getLoanFallbackTotalDue(offer)
	local term = math.max(tonumber(offer.termPayments) or 1, 1)
	return math.ceil(totalDue / term)
end

function BANK:_getCurrentGameDay()
	local ok, day = pcall(function()
		return Game.GetTimeSystem():GetGameTime():Days()
	end)
	if ok and day ~= nil then
		return math.floor(tonumber(day) or 0)
	end
	return 0
end

function BANK:_getCurrentGameMinuteStamp()
	local day = self:_getCurrentGameDay()
	local hour = 12
	local minute = 0
	pcall(function()
		local time = Game.GetTimeSystem():GetGameTime()
		hour = math.floor(tonumber(time:Hours()) or hour)
		minute = math.floor(tonumber(time:Minutes()) or minute)
	end)
	if hour < 0 then hour = 0 end
	if hour > 23 then hour = 23 end
	if minute < 0 then minute = 0 end
	if minute > 59 then minute = 59 end
	return (day * 1440) + (hour * 60) + minute
end

function BANK:_nextLoanBusinessStartMinute(stamp)
	local value = math.max(math.floor(tonumber(stamp) or 0), 0)
	local day = math.floor(value / 1440)
	local tod = value - (day * 1440)
	if tod < MB_LOAN_BUSINESS_OPEN_MINUTE then
		return (day * 1440) + MB_LOAN_BUSINESS_OPEN_MINUTE
	end
	if tod >= MB_LOAN_BUSINESS_CLOSE_MINUTE then
		return ((day + 1) * 1440) + MB_LOAN_BUSINESS_OPEN_MINUTE
	end
	return value
end

function BANK:_addLoanBusinessMinutes(startStamp, minutes)
	local remaining = math.max(math.floor(tonumber(minutes) or 0), 0)
	local current = self:_nextLoanBusinessStartMinute(startStamp)
	local guard = 0
	while remaining > 0 and guard < 30 do
		local day = math.floor(current / 1440)
		local closeStamp = (day * 1440) + MB_LOAN_BUSINESS_CLOSE_MINUTE
		local available = closeStamp - current
		if available <= 0 then
			current = ((day + 1) * 1440) + MB_LOAN_BUSINESS_OPEN_MINUTE
		elseif remaining <= available then
			return current + remaining
		else
			remaining = remaining - available
			current = ((day + 1) * 1440) + MB_LOAN_BUSINESS_OPEN_MINUTE
		end
		guard = guard + 1
	end
	return current + remaining
end

function BANK:formatLoanTimeStamp(stamp)
	local value = math.max(math.floor(tonumber(stamp) or 0), 0)
	local day = math.floor(value / 1440)
	local tod = value - (day * 1440)
	local hour24 = math.floor(tod / 60)
	local minute = tod - (hour24 * 60)
	local suffix = hour24 >= 12 and "PM" or "AM"
	local hour12 = hour24 % 12
	if hour12 == 0 then hour12 = 12 end
	return string.format("%d:%02d %s", hour12, minute, suffix)
end

function BANK:_addWalletMoney(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	local before = self:getWalletBalance()
	pcall(function() Game.AddToInventory("Items.money", amount) end)
	local after = self:getWalletBalance()
	if after >= before + amount or after > before then
		self:_syncWalletSnapshot()
		return true
	end

	local ok = pcall(function()
		local ts = Game.GetTransactionSystem()
		local player = Game.GetPlayer()
		local itemID = ItemID.new(TweakDBID.new("Items.money"))
		if ts and player then
			ts:GiveItem(player, itemID, amount)
		end
	end)
	if ok then
		after = self:getWalletBalance()
		if after > before then self:_syncWalletSnapshot() end
		return after > before
	end

	return false
end

function BANK:_creditDisputeRefundOnce(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false, false, 0, 0 end
	local before, beforeReadable = self:_tryReadWalletBalance()
	if beforeReadable ~= true then return false, false, 0, 0 end
	before = math.floor(tonumber(before) or 0)

	local attempted = false
	local callOk = pcall(function()
		local ts = self:_getCachedTransactionSystem()
		local player = Game.GetPlayer()
		local itemID = self:_getMoneyItemID()
		if ts and player and itemID ~= nil then
			attempted = true
			ts:GiveItem(player, itemID, amount)
		end
	end)
	if callOk ~= true or attempted ~= true then return false, attempted, before, before end

	local after, afterReadable = self:_tryReadWalletBalance()
	if afterReadable ~= true then return false, true, before, before end
	after = math.floor(tonumber(after) or before)
	local credited = after - before
	if credited >= amount then
		self:_syncWalletSnapshot()
		return true, true, before, after
	end
	if credited <= 0 then
		return false, false, before, after
	end
	return false, true, before, after
end

function BANK:_removeWalletMoney(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end
	local before = self:getWalletBalance()
	if before <= 0 then return false end
	if amount > before then amount = before end

	pcall(function()
		local system = self:getUnifiedSystem()
		if system then
			system:SuppressExternalWalletDebit(amount)
		end
	end)

	pcall(function()
		local ts = Game.GetTransactionSystem()
		local player = Game.GetPlayer()
		local itemID = ItemID.new(TweakDBID.new("Items.money"))
		if ts and player then
			ts:RemoveItem(player, itemID, amount)
		else
			Util.handlingMoney("remove", amount)
		end
	end)

	local after = self:getWalletBalance()
	if after < before then
		self:_clearExternalWalletDebitSuppression()
		self:_syncWalletSnapshot()
		return true
	end
	return false
end

function BANK:_clearFallbackLoan()
	self:_setQuestFactInt(MB_LOAN_FACT_ACTIVE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_OFFER, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_PRINCIPAL, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_ORIGINAL_DUE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_INSTALLMENT, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_RATE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_TERM, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_TERM_MONTHS, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_PAYMENTS, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_START_DAY, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_MISSED, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_INTERVAL, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_REMINDER_DUE, 0)
end

function BANK:_closeFallbackLoanIfPaid()
	local balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
	if self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) > 0 and balance <= 0 then
		self:_clearFallbackLoan()
	end
end

function BANK:_fallbackLoanIsActive()
	self:_closeFallbackLoanIfPaid()
	return self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) > 0 and self:_getQuestFactInt(MB_LOAN_FACT_BALANCE) > 0
end

function BANK:_calculateEarlyPayoffAmount(principal, originalDue, balanceDue)
	local principalAmount = math.floor(tonumber(principal) or 0)
	local originalAmount = math.floor(tonumber(originalDue) or 0)
	local balanceAmount = math.floor(tonumber(balanceDue) or 0)
	if balanceAmount <= 0 then return 0 end
	if principalAmount <= 0 then return balanceAmount end
	if originalAmount <= principalAmount then return math.min(balanceAmount, principalAmount) end

	local payoff = math.ceil((principalAmount * balanceAmount) / originalAmount)
	if payoff < 0 then payoff = 0 end
	if payoff > balanceAmount then payoff = balanceAmount end
	return payoff
end

function BANK:_getFallbackLoanEarlyPayoffAmount()
	return self:_calculateEarlyPayoffAmount(
		self:_getQuestFactInt(MB_LOAN_FACT_PRINCIPAL),
		self:_getQuestFactInt(MB_LOAN_FACT_ORIGINAL_DUE),
		self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
	)
end

function BANK:_getFallbackLoanInterestWaived()
	local balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
	local payoff = self:_getFallbackLoanEarlyPayoffAmount()
	return math.max(balance - payoff, 0)
end

function BANK:getLoanEarlyPayoffAmount()
	local system = self:getUnifiedSystem()
	local amount = 0
	if system then
		pcall(function() amount = tonumber(system:GetLoanEarlyPayoffAmount()) or 0 end)
	end
	if amount > 0 then return math.floor(amount) end
	return self:_getFallbackLoanEarlyPayoffAmount()
end

function BANK:_maybeRecordFallbackLoanReminder(today, nextDue, balance)
	local dueDay = math.floor(tonumber(nextDue) or 0)
	local currentDay = math.floor(tonumber(today) or 0)
	if dueDay <= 0 then return end
	if dueDay - currentDay ~= 1 then return end
	if self:_getQuestFactInt(MB_LOAN_FACT_LAST_REMINDER_DUE) == dueDay then return end

	local dueAmount = self:_getQuestFactInt(MB_LOAN_FACT_INSTALLMENT)
	if dueAmount <= 0 then dueAmount = balance end
	if dueAmount > balance then dueAmount = balance end
	if dueAmount <= 0 then return end

	local code = self:_generateLoanConfirmationCode("REM")
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_REMINDER_DUE, dueDay)
	self:_setLastLoanConfirmationCode(code)
	self:_recordLoanReminderText(dueAmount, code)
end

function BANK:_getFallbackLoanData(skipSync)
	if not skipSync then
		self:_syncFallbackLoanPayments()
	end
	self:_closeFallbackLoanIfPaid()

	local active = self:_fallbackLoanIsActive()
	local rate = self:_getQuestFactInt(MB_LOAN_FACT_RATE)
	local storedTermMonths = self:_getQuestFactInt(MB_LOAN_FACT_TERM_MONTHS)
	if storedTermMonths <= 0 then
		storedTermMonths = self:_deriveLoanTermMonths(self:_getQuestFactInt(MB_LOAN_FACT_TERM), math.max(self:_getQuestFactInt(MB_LOAN_FACT_INTERVAL), 1))
	end
	return {
		active = active,
		offerIndex = self:_getQuestFactInt(MB_LOAN_FACT_OFFER),
		principal = self:_getQuestFactInt(MB_LOAN_FACT_PRINCIPAL),
		originalDue = self:_getQuestFactInt(MB_LOAN_FACT_ORIGINAL_DUE),
		balanceDue = active and self:_getQuestFactInt(MB_LOAN_FACT_BALANCE) or 0,
		installment = active and self:_getQuestFactInt(MB_LOAN_FACT_INSTALLMENT) or 0,
		interestBasisPoints = rate,
		interestPercent = rate / 100.0,
		termPayments = self:_getQuestFactInt(MB_LOAN_FACT_TERM),
		termMonths = storedTermMonths,
		paymentsMade = self:_getQuestFactInt(MB_LOAN_FACT_PAYMENTS),
		startDay = self:_getQuestFactInt(MB_LOAN_FACT_START_DAY),
		nextDueDay = active and self:_getQuestFactInt(MB_LOAN_FACT_NEXT_DUE) or 0,
		missedPayments = self:_getQuestFactInt(MB_LOAN_FACT_MISSED),
		earlyPayoffAmount = active and self:_getFallbackLoanEarlyPayoffAmount() or 0,
		interestWaived = active and self:_getFallbackLoanInterestWaived() or 0,
		totalBorrowed = self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_BORROWED),
		totalRepaid = self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID),
		paymentIntervalDays = math.max(self:_getQuestFactInt(MB_LOAN_FACT_INTERVAL), 1),
	}
end

function BANK:_fallbackBookLoanFromOffer(offer, confirmationCode)
	if not offer then return false end
	if self:_fallbackLoanIsActive() then return false end

	local principal = math.floor(tonumber(offer.principal) or 0)
	local totalDue = math.floor(tonumber(offer.totalDue) or 0)
	local installment = math.floor(tonumber(offer.installment) or 0)
	local rate = math.floor(tonumber(offer.interestBasisPoints) or 0)
	local term = math.max(math.floor(tonumber(offer.termPayments) or 1), 1)
	local interval = math.floor(tonumber(offer.intervalDays) or 30)
	local termMonths = math.floor(tonumber(offer.termMonths) or 0)
	if termMonths <= 0 then termMonths = self:_deriveLoanTermMonths(term, interval) end
	local currentDay = self:_getCurrentGameDay()
	local walletBefore = self:getWalletBalance()
	local code = tostring(confirmationCode or "")
	if code == "" then code = self:_generateLoanConfirmationCode("APP") end

	if totalDue <= 0 then
		local interest = math.floor((principal * rate + 5000) / 10000)
		totalDue = principal + interest
	end
	if installment <= 0 then
		installment = math.ceil(totalDue / term)
	end

	if principal <= 0 or totalDue <= 0 then return false end
	if not self:_addWalletMoney(principal) then return false end
	local walletAfter = self:getWalletBalance()

	self:_setQuestFactInt(MB_LOAN_FACT_ACTIVE, 1)
	self:_setQuestFactInt(MB_LOAN_FACT_OFFER, math.floor(tonumber(offer.index) or 0))
	self:_setQuestFactInt(MB_LOAN_FACT_PRINCIPAL, principal)
	self:_setQuestFactInt(MB_LOAN_FACT_ORIGINAL_DUE, totalDue)
	self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, totalDue)
	self:_setQuestFactInt(MB_LOAN_FACT_INSTALLMENT, installment)
	self:_setQuestFactInt(MB_LOAN_FACT_RATE, rate)
	self:_setQuestFactInt(MB_LOAN_FACT_TERM, term)
	self:_setQuestFactInt(MB_LOAN_FACT_TERM_MONTHS, termMonths)
	self:_setQuestFactInt(MB_LOAN_FACT_PAYMENTS, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_START_DAY, currentDay)
	self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, currentDay + interval)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, currentDay)
	self:_setQuestFactInt(MB_LOAN_FACT_MISSED, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_INTERVAL, interval)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_REMINDER_DUE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_TOTAL_BORROWED, self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_BORROWED) + principal)

	self.lastLoanBalance = totalDue
	self:_setLastLoanConfirmationCode(code)
	self:_recordLoanApprovalText(principal, walletBefore, walletAfter, code)
	self:_syncWalletSnapshot()
	pcall(function() Util.simpleScreenMessage("Marmur Bank loan funded: " .. Util.formatNumber(principal) .. " E$ | Conf. " .. code) end)
	return true
end

function BANK:_fallbackRequestLoan(offerIndex, confirmationCode)
	local offer = self:_getLoanFallbackOffer(offerIndex)
	if not offer then return false end

	local termMonths = self:_deriveLoanTermMonths(offer.termPayments, offer.intervalDays)
	local quoted = self:getManualLoanQuote(offer.principal, "monthly", termMonths)
	quoted.index = offer.index

	local chance = math.floor(tonumber(quoted.approvalChance) or 0)
	if chance <= 0 or chance < math.random(1, 100) then
		return false
	end

	return self:_fallbackBookLoanFromOffer(quoted, confirmationCode)
end

function BANK:_clearLoanReview()
	self:_setQuestFactInt(MB_LOAN_REVIEW_ACTIVE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_AMOUNT, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_SUBMIT_DAY, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_DECISION_DAY, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_REQUIRED_SC, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_RATE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TERM, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TERM_MONTHS, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TOTAL_DUE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_INSTALLMENT, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_SUBMIT_MINUTE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_START_MINUTE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_DECISION_MINUTE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_FREQUENCY, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_INTERVAL, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_APPROVAL_CHANCE, 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_RISK_CODE, 0)
	self:_setQuestFactInt(MB_LOAN_FUNDING_DUE_MINUTE, 0)
end

function BANK:_loanReviewIsPending()
	return self:_getQuestFactInt(MB_LOAN_REVIEW_ACTIVE) > 0 and self:_getQuestFactInt(MB_LOAN_REVIEW_AMOUNT) > 0
end

function BANK:getLoanReviewData(skipSync)
	if not skipSync then
		self:_syncLoanApplicationReview()
	end
	local state = self:_getQuestFactInt(MB_LOAN_REVIEW_ACTIVE)
	local active = state > 0 and self:_getQuestFactInt(MB_LOAN_REVIEW_AMOUNT) > 0
	local decisionMinute = active and self:_getQuestFactInt(MB_LOAN_REVIEW_DECISION_MINUTE) or 0
	local fundingMinute = active and self:_getQuestFactInt(MB_LOAN_FUNDING_DUE_MINUTE) or 0
	return {
		active = active,
		state = active and state or 0,
		pendingReview = active and state == MB_LOAN_STATE_UNDER_REVIEW,
		approvalReady = active and state == MB_LOAN_STATE_APPROVED_UNSIGNED,
		fundingPending = active and state == MB_LOAN_STATE_FUNDING_PENDING,
		amount = active and self:_getQuestFactInt(MB_LOAN_REVIEW_AMOUNT) or 0,
		submitDay = active and self:_getQuestFactInt(MB_LOAN_REVIEW_SUBMIT_DAY) or 0,
		decisionDay = active and self:_getQuestFactInt(MB_LOAN_REVIEW_DECISION_DAY) or 0,
		submitMinute = active and self:_getQuestFactInt(MB_LOAN_REVIEW_SUBMIT_MINUTE) or 0,
		startMinute = active and self:_getQuestFactInt(MB_LOAN_REVIEW_START_MINUTE) or 0,
		decisionMinute = decisionMinute,
		fundingDueMinute = fundingMinute,
		decisionLabel = active and self:formatLoanTimeStamp(decisionMinute) or "",
		fundingLabel = active and self:formatLoanTimeStamp(fundingMinute) or "",
		requiredStreetCred = active and self:_getQuestFactInt(MB_LOAN_REVIEW_REQUIRED_SC) or 0,
		interestBasisPoints = active and self:_getQuestFactInt(MB_LOAN_REVIEW_RATE) or 0,
		termPayments = active and self:_getQuestFactInt(MB_LOAN_REVIEW_TERM) or 0,
		termMonths = active and self:_getQuestFactInt(MB_LOAN_REVIEW_TERM_MONTHS) or 0,
		intervalDays = active and math.max(self:_getQuestFactInt(MB_LOAN_REVIEW_INTERVAL), 1) or 0,
		frequencyCode = active and self:_getQuestFactInt(MB_LOAN_REVIEW_FREQUENCY) or 0,
		frequencyLabel = active and self:getLoanFrequencyLabel(self:_getQuestFactInt(MB_LOAN_REVIEW_FREQUENCY)) or "",
		approvalChance = active and self:_getQuestFactInt(MB_LOAN_REVIEW_APPROVAL_CHANCE) or 0,
		approvalRiskCode = active and self:_getQuestFactInt(MB_LOAN_REVIEW_RISK_CODE) or 0,
		approvalRiskLabel = active and self:getManualLoanApprovalRiskLabel(self:_getQuestFactInt(MB_LOAN_REVIEW_RISK_CODE)) or "",
		totalDue = active and self:_getQuestFactInt(MB_LOAN_REVIEW_TOTAL_DUE) or 0,
		installment = active and self:_getQuestFactInt(MB_LOAN_REVIEW_INSTALLMENT) or 0,
	}
end

function BANK:submitManualLoanApplication(amount, frequency, termMonths)
	local principal = math.floor(tonumber(amount) or 0)
	if principal <= 0 then return false end
	if principal > MB_LOAN_ABSOLUTE_MAX then return false end
	if self:_fallbackLoanIsActive() then return false end
	if self:_loanReviewIsPending() then return false end

	local system = self:getUnifiedSystem()
	local activeSystemLoan = false
	if system then
		pcall(function() activeSystemLoan = system:HasActiveLoan() == true end)
	end
	if activeSystemLoan then return false end

	local quote = self:getManualLoanQuote(principal, frequency, termMonths)
	local nowStamp = self:_getCurrentGameMinuteStamp()
	local reviewStart = self:_nextLoanBusinessStartMinute(nowStamp)
	local decisionStamp = self:_addLoanBusinessMinutes(reviewStart, math.random(120, 240))
	local today = math.floor(nowStamp / 1440)
	local decisionDay = math.floor(decisionStamp / 1440)
	local code = self:_generateLoanConfirmationCode("REQ")

	self:_setQuestFactInt(MB_LOAN_REVIEW_ACTIVE, MB_LOAN_STATE_UNDER_REVIEW)
	self:_setQuestFactInt(MB_LOAN_REVIEW_AMOUNT, principal)
	self:_setQuestFactInt(MB_LOAN_REVIEW_SUBMIT_DAY, today)
	self:_setQuestFactInt(MB_LOAN_REVIEW_DECISION_DAY, decisionDay)
	self:_setQuestFactInt(MB_LOAN_REVIEW_SUBMIT_MINUTE, nowStamp)
	self:_setQuestFactInt(MB_LOAN_REVIEW_START_MINUTE, reviewStart)
	self:_setQuestFactInt(MB_LOAN_REVIEW_DECISION_MINUTE, decisionStamp)
	self:_setQuestFactInt(MB_LOAN_REVIEW_REQUIRED_SC, quote.requiredStreetCred or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_RATE, quote.interestBasisPoints or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TERM, quote.termPayments or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TERM_MONTHS, quote.termMonths or MB_LOAN_DEFAULT_TERM_MONTHS)
	self:_setQuestFactInt(MB_LOAN_REVIEW_TOTAL_DUE, quote.totalDue or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_INSTALLMENT, quote.installment or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_FREQUENCY, quote.frequencyCode or 3)
	self:_setQuestFactInt(MB_LOAN_REVIEW_INTERVAL, quote.intervalDays or 30)
	self:_setQuestFactInt(MB_LOAN_REVIEW_APPROVAL_CHANCE, quote.approvalChance or 0)
	self:_setQuestFactInt(MB_LOAN_REVIEW_RISK_CODE, quote.approvalRiskCode or 3)
	self:_setQuestFactInt(MB_LOAN_FUNDING_DUE_MINUTE, 0)
	self:_setLastLoanConfirmationCode(code)
	self:_storeLoanSmsThreadEntry("REQ", principal, self:getWalletBalance(), self:getWalletBalance(), code)
	self:_syncLoanApplicationReview()
	pcall(function() Util.simpleScreenMessage("Marmur Bank application submitted. Decision window: 2-4 business hours.") end)
	return true
end

function BANK:acceptApprovedManualLoan()
	if not self:_loanReviewIsPending() then return false end
	if self:_getQuestFactInt(MB_LOAN_REVIEW_ACTIVE) ~= MB_LOAN_STATE_APPROVED_UNSIGNED then return false end
	if self:_fallbackLoanIsActive() then return false end

	local system = self:getUnifiedSystem()
	local activeSystemLoan = false
	if system then
		pcall(function() activeSystemLoan = system:HasActiveLoan() == true end)
	end
	if activeSystemLoan then return false end

	local nowStamp = self:_getCurrentGameMinuteStamp()
	local fundingStamp = nowStamp
	local code = self:_generateLoanConfirmationCode("SIG")
	local principal = self:_getQuestFactInt(MB_LOAN_REVIEW_AMOUNT)

	self:_setQuestFactInt(MB_LOAN_REVIEW_ACTIVE, MB_LOAN_STATE_FUNDING_PENDING)
	self:_setQuestFactInt(MB_LOAN_FUNDING_DUE_MINUTE, fundingStamp)
	self:_setLastLoanConfirmationCode(code)
	self:_recordLoanSignedText(principal, code)
	pcall(function() Util.simpleScreenMessage("Loan agreement signed. Funds deposited immediately.") end)
	self:_syncLoanApplicationReview()
	return true
end

function BANK:cancelManualLoanProcess()
	if not self:_loanReviewIsPending() then return false end
	self:_clearLoanReview()
	pcall(function() Util.simpleScreenMessage("Marmur Bank loan request canceled") end)
	return true
end

function BANK:_syncLoanApplicationReview()
	if not self:_loanReviewIsPending() then return end

	local state = self:_getQuestFactInt(MB_LOAN_REVIEW_ACTIVE)
	local principal = self:_getQuestFactInt(MB_LOAN_REVIEW_AMOUNT)
	local nowStamp = self:_getCurrentGameMinuteStamp()
	local requiredSC = self:_getQuestFactInt(MB_LOAN_REVIEW_REQUIRED_SC)
	local streetCred = math.floor(tonumber(self:getStreetCredLevel()) or 0)
	local walletBefore = self:getWalletBalance()
	local system = self:getUnifiedSystem()
	local activeSystemLoan = false
	if system then
		pcall(function() activeSystemLoan = system:HasActiveLoan() == true end)
	end

	if state == MB_LOAN_STATE_UNDER_REVIEW then
		local decisionStamp = self:_getQuestFactInt(MB_LOAN_REVIEW_DECISION_MINUTE)
		if decisionStamp <= 0 then
			local decisionDay = self:_getQuestFactInt(MB_LOAN_REVIEW_DECISION_DAY)
			decisionStamp = (decisionDay * 1440) + MB_LOAN_BUSINESS_OPEN_MINUTE
		end
		if nowStamp < decisionStamp then return end

		local approvalChance = self:_getQuestFactInt(MB_LOAN_REVIEW_APPROVAL_CHANCE)
		local riskCode = self:_getQuestFactInt(MB_LOAN_REVIEW_RISK_CODE)
		if approvalChance <= 0 and riskCode <= 0 then
			approvalChance = self:getManualLoanApprovalChance(principal, streetCred)
		end
		local approvalRoll = math.random(1, 100)
		local approved = principal > 0 and principal <= MB_LOAN_ABSOLUTE_MAX and not activeSystemLoan and not self:_fallbackLoanIsActive() and approvalChance >= approvalRoll
		if approved then
			local code = self:_generateLoanConfirmationCode("APR")
			self:_setQuestFactInt(MB_LOAN_REVIEW_ACTIVE, MB_LOAN_STATE_APPROVED_UNSIGNED)
			self:_setLastLoanConfirmationCode(code)
			self:_recordLoanTermsReadyText(principal, code)
			pcall(function() Util.simpleScreenMessage("Marmur Bank loan approved. Review and sign terms to fund.") end)
			return
		end

		local denialCode = self:_generateLoanConfirmationCode("DEN")
		self:_setLastLoanConfirmationCode(denialCode)
		self:_storeLoanSmsThreadEntry("DEN", principal, walletBefore, walletBefore, denialCode)
		self:_clearLoanReview()
		pcall(function() Util.simpleScreenMessage("Denied: approval risk too high") end)
		return
	end

	if state == MB_LOAN_STATE_FUNDING_PENDING then
		local fundingStamp = self:_getQuestFactInt(MB_LOAN_FUNDING_DUE_MINUTE)
		if fundingStamp <= 0 or nowStamp < fundingStamp then return end
		if activeSystemLoan or self:_fallbackLoanIsActive() then return end

		local quote = {
			index = 0,
			principal = principal,
			interestBasisPoints = self:_getQuestFactInt(MB_LOAN_REVIEW_RATE),
			termPayments = self:_getQuestFactInt(MB_LOAN_REVIEW_TERM),
			intervalDays = self:_getQuestFactInt(MB_LOAN_REVIEW_INTERVAL),
			totalDue = self:_getQuestFactInt(MB_LOAN_REVIEW_TOTAL_DUE),
			installment = self:_getQuestFactInt(MB_LOAN_REVIEW_INSTALLMENT),
		}
		local code = self:_generateLoanConfirmationCode("APP")
		local ok = self:_fallbackBookLoanFromOffer(quote, code)
		if ok then
			self:_clearLoanReview()
			return
		end
	end
end

function BANK:_fallbackPayLoan(amount, confirmationCode, autoPayment)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 or not self:_fallbackLoanIsActive() then return false end

	local wallet = self:getWalletBalance()
	local walletBefore = wallet
	local balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
	local debit = math.min(amount, wallet, balance)
	local payoff = autoPayment ~= true and balance > 0 and debit >= balance
	local code = tostring(confirmationCode or "")
	if code == "" then code = self:_generateLoanConfirmationCode(autoPayment and "AUT" or (payoff and "FUL" or "PAY")) end
	if debit <= 0 then return false end
	if not self:_removeWalletMoney(debit) then return false end
	local walletAfter = self:getWalletBalance()

	self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, balance - debit)
	self:_setQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID, self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID) + debit)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, self:_getCurrentGameDay())
	self:_closeFallbackLoanIfPaid()
	self.lastLoanBalance = math.max(balance - debit, 0)
	self:_setLastLoanConfirmationCode(code)
	if autoPayment == true then
		self:_recordLoanAutoPaymentText(debit, walletBefore, walletAfter, code)
	elseif payoff then
		self:_recordLoanPayoffText(debit, walletBefore, walletAfter, code)
	else
		self:_recordLoanManualPaymentText(debit, walletBefore, walletAfter, code)
	end
	local cashbackEarned = self:_awardCashbackForLoanPayment(debit, walletBefore, walletAfter, nil, nil)
	self:_markLastTransactionCashbackEarned(cashbackEarned)
	self:_markServicedLoanDebitHandled(walletAfter)
	return true
end

function BANK:_fallbackPayLoanInFullPrincipalOnly(confirmationCode)
	if not self:_fallbackLoanIsActive() then return false end
	local payoff = self:_getFallbackLoanEarlyPayoffAmount()
	if payoff <= 0 then return false end
	local walletBefore = self:getWalletBalance()
	if walletBefore < payoff then return false end
	local code = tostring(confirmationCode or "")
	if code == "" then code = self:_generateLoanConfirmationCode("FUL") end
	if not self:_removeWalletMoney(payoff) then return false end
	local walletAfter = self:getWalletBalance()

	self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, 0)
	self:_setQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID, self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID) + payoff)
	self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, self:_getCurrentGameDay())
	self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, 0)
	self:_closeFallbackLoanIfPaid()
	self.lastLoanBalance = 0
	self:_setLastLoanConfirmationCode(code)
	self:_recordLoanPayoffText(payoff, walletBefore, walletAfter, code)
	local cashbackEarned = self:_awardCashbackForLoanPayment(payoff, walletBefore, walletAfter, nil, nil)
	self:_markLastTransactionCashbackEarned(cashbackEarned)
	self:_markServicedLoanDebitHandled(walletAfter)
	return true
end

function BANK:_syncFallbackLoanPayments()
	if self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) <= 0 then return end

	local balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
	if balance <= 0 then
		self:_clearFallbackLoan()
		return
	end

	local today = self:_getCurrentGameDay()
	local interval = math.max(self:_getQuestFactInt(MB_LOAN_FACT_INTERVAL), 1)
	local nextDue = self:_getQuestFactInt(MB_LOAN_FACT_NEXT_DUE)
	if nextDue <= 0 then
		self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, today + interval)
		return
	end
	if today < nextDue then
		self:_maybeRecordFallbackLoanReminder(today, nextDue, balance)
		return
	end

	local loopGuard = 0
	while self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) > 0 and today >= nextDue and loopGuard < 24 do
		balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
		if balance <= 0 then
			self:_clearFallbackLoan()
			return
		end

		local dueAmount = self:_getQuestFactInt(MB_LOAN_FACT_INSTALLMENT)
		if dueAmount <= 0 then dueAmount = balance end
		if dueAmount > balance then dueAmount = balance end

		local wallet = self:getWalletBalance()
		local walletBefore = wallet
		local debit = math.min(dueAmount, wallet, balance)
		local code = self:_generateLoanConfirmationCode("AUT")
		if debit > 0 and self:_removeWalletMoney(debit) then
			local walletAfter = self:getWalletBalance()
			self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, balance - debit)
			self:_setQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID, self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID) + debit)
			self:_setQuestFactInt(MB_LOAN_FACT_PAYMENTS, self:_getQuestFactInt(MB_LOAN_FACT_PAYMENTS) + 1)
			self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, nextDue)
			self:_setLastLoanConfirmationCode(code)
			self:_recordLoanAutoPaymentText(debit, walletBefore, walletAfter, code)
			local cashbackEarned = self:_awardCashbackForLoanPayment(debit, walletBefore, walletAfter, nil, nil)
			self:_markLastTransactionCashbackEarned(cashbackEarned)
			self:_syncWalletSnapshot()
			pcall(function() Util.simpleScreenMessage("Marmur Bank loan auto-debit: " .. Util.formatNumber(debit) .. " E$ | Conf. " .. code) end)
			if debit < dueAmount then
				self:_setQuestFactInt(MB_LOAN_FACT_MISSED, self:_getQuestFactInt(MB_LOAN_FACT_MISSED) + 1)
			end
		else
			self:_setQuestFactInt(MB_LOAN_FACT_MISSED, self:_getQuestFactInt(MB_LOAN_FACT_MISSED) + 1)
			pcall(function() Util.simpleScreenMessage("Marmur Bank loan payment missed") end)
		end

		self:_closeFallbackLoanIfPaid()
		if self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) > 0 then
			nextDue = nextDue + interval
			self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, nextDue)
		end
		loopGuard = loopGuard + 1
	end

	if self:_getQuestFactInt(MB_LOAN_FACT_ACTIVE) > 0 and today >= self:_getQuestFactInt(MB_LOAN_FACT_NEXT_DUE) then
		self:_setQuestFactInt(MB_LOAN_FACT_NEXT_DUE, today + interval)
	end
end

function BANK:_normalizeStreetCredCandidate(value)
	local num = tonumber(value)
	if num == nil then
		return nil
	end
	num = math.floor(num)
	if num < 0 or num > 60 then
		return nil
	end
	return num
end

function BANK:getStreetCredLevel()
	local best = nil
	local function consider(value)
		local candidate = self:_normalizeStreetCredCandidate(value)
		if candidate ~= nil and (best == nil or candidate > best) then
			best = candidate
		end
	end

	local ok, level
	ok, level = pcall(function() return Game.GetLevel("StreetCred") end)
	if ok then consider(level) end

	ok, level = pcall(function() return Game.GetLevel("StreetCredLevel") end)
	if ok then consider(level) end

	ok, level = pcall(function()
		if gamedataProficiencyType and gamedataProficiencyType.StreetCred then
			return Game.GetLevel(gamedataProficiencyType.StreetCred)
		end
		return nil
	end)
	if ok then consider(level) end

	ok, level = pcall(function()
		local player = Game.GetPlayer()
		local stats = Game.GetStatsSystem()
		if player and stats and gamedataStatType and gamedataStatType.StreetCredLevel then
			return stats:GetStatValue(player:GetEntityID(), gamedataStatType.StreetCredLevel)
		end
		return nil
	end)
	if ok then consider(level) end

	ok, level = pcall(function()
		local player = Game.GetPlayer()
		local stats = Game.GetStatsSystem()
		if player and stats and gamedataStatType and gamedataStatType.StreetCred then
			return stats:GetStatValue(player:GetEntityID(), gamedataStatType.StreetCred)
		end
		return nil
	end)
	if ok then consider(level) end

	if best ~= nil then
		self.lastKnownStreetCred = best
		return best
	end

	if self.lastKnownStreetCred ~= nil then
		return self.lastKnownStreetCred
	end

	return 0
end

function BANK:getLoanOffers()
	local offers = {}
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local count = 5
	local currentCredit = math.floor(tonumber(self:getStreetCredLevel()) or 0)

	if system and gameInstance then
		pcall(function()
			count = tonumber(system:GetLoanOfferCount()) or 5
		end)
	end

	for i = 1, count do
		local fallback = MB_LOAN_FALLBACK_OFFERS[i] or MB_LOAN_FALLBACK_OFFERS[#MB_LOAN_FALLBACK_OFFERS]
		local principal = fallback.principal
		local termPayments = fallback.termPayments
		local intervalDays = fallback.intervalDays

		if system and gameInstance then
			pcall(function() principal = tonumber(system:GetLoanPrincipalAt(i)) or principal end)
			pcall(function() termPayments = tonumber(system:GetLoanTermPaymentsAt(i)) or termPayments end)
			pcall(function() intervalDays = tonumber(system:GetLoanPaymentIntervalDays()) or intervalDays end)
		end

		local requiredStreetCred = self:getRequiredCreditLevelForAmount(principal)
		local interestBasisPoints = self:getLoanAPRForStreetCred(currentCredit)
		local termMonths = self:_deriveLoanTermMonths(termPayments, intervalDays)
		if termMonths <= 0 then termMonths = termPayments end
		local totalDue, installment, actualTermPayments = self:_calculateAmortizedLoanTotal(principal, interestBasisPoints, termMonths, "monthly")

		table.insert(offers, {
			index = i,
			principal = principal,
			requiredStreetCred = requiredStreetCred,
			interestBasisPoints = interestBasisPoints,
			interestPercent = interestBasisPoints / 100.0,
			termPayments = actualTermPayments,
			termMonths = termMonths,
			intervalDays = intervalDays,
			totalDue = totalDue,
			installment = installment,
		})
	end

	return offers
end

function BANK:getLoanData()
	self:_syncLoanApplicationReview()
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local fallbackData = self:_getFallbackLoanData(false)
	local reviewData = self:getLoanReviewData(true)
	local data = {
		active = false,
		offerIndex = 0,
		principal = 0,
		originalDue = 0,
		balanceDue = 0,
		installment = 0,
		interestBasisPoints = 0,
		interestPercent = 0,
		termPayments = 0,
		termMonths = 0,
		paymentsMade = 0,
		startDay = 0,
		nextDueDay = 0,
		missedPayments = 0,
		earlyPayoffAmount = 0,
		interestWaived = 0,
		totalBorrowed = fallbackData.totalBorrowed or 0,
		totalRepaid = fallbackData.totalRepaid or 0,
		paymentIntervalDays = 30,
		reviewActive = reviewData.active or false,
		reviewState = reviewData.state or 0,
		reviewPending = reviewData.pendingReview or false,
		reviewApprovalReady = reviewData.approvalReady or false,
		reviewFundingPending = reviewData.fundingPending or false,
		reviewAmount = reviewData.amount or 0,
		reviewSubmitDay = reviewData.submitDay or 0,
		reviewDecisionDay = reviewData.decisionDay or 0,
		reviewSubmitMinute = reviewData.submitMinute or 0,
		reviewStartMinute = reviewData.startMinute or 0,
		reviewDecisionMinute = reviewData.decisionMinute or 0,
		reviewFundingDueMinute = reviewData.fundingDueMinute or 0,
		reviewDecisionLabel = reviewData.decisionLabel or "",
		reviewFundingLabel = reviewData.fundingLabel or "",
		reviewRequiredStreetCred = reviewData.requiredStreetCred or 0,
		reviewInterestBasisPoints = reviewData.interestBasisPoints or 0,
		reviewTermPayments = reviewData.termPayments or 0,
		reviewTermMonths = reviewData.termMonths or 0,
		reviewIntervalDays = reviewData.intervalDays or 0,
		reviewFrequencyCode = reviewData.frequencyCode or 0,
		reviewFrequencyLabel = reviewData.frequencyLabel or "",
		reviewApprovalChance = reviewData.approvalChance or 0,
		reviewApprovalRiskCode = reviewData.approvalRiskCode or 0,
		reviewApprovalRiskLabel = reviewData.approvalRiskLabel or "",
		reviewTotalDue = reviewData.totalDue or 0,
		reviewInstallment = reviewData.installment or 0,
	}

	if system and gameInstance then
		pcall(function() system:SyncLoanPayments(gameInstance) end)
		pcall(function() data.active = system:HasActiveLoan() == true end)
		pcall(function() data.offerIndex = tonumber(system:GetLoanOfferIndex()) or 0 end)
		pcall(function() data.principal = tonumber(system:GetLoanPrincipal()) or 0 end)
		pcall(function() data.originalDue = tonumber(system:GetLoanOriginalDue()) or 0 end)
		pcall(function() data.balanceDue = tonumber(system:GetLoanBalanceDue()) or 0 end)
		pcall(function() data.installment = tonumber(system:GetLoanInstallmentAmount()) or 0 end)
		pcall(function() data.interestBasisPoints = tonumber(system:GetLoanInterestBasisPoints()) or 0 end)
		pcall(function() data.termPayments = tonumber(system:GetLoanTermPayments()) or 0 end)
		pcall(function() data.paymentsMade = tonumber(system:GetLoanPaymentsMade()) or 0 end)
		pcall(function() data.startDay = tonumber(system:GetLoanStartDay()) or 0 end)
		pcall(function() data.nextDueDay = tonumber(system:GetLoanNextDueDay()) or 0 end)
		pcall(function() data.missedPayments = tonumber(system:GetLoanMissedPayments()) or 0 end)
		pcall(function() data.totalBorrowed = tonumber(system:GetTotalLoanBorrowed()) or data.totalBorrowed end)
		pcall(function() data.totalRepaid = tonumber(system:GetTotalLoanRepaid()) or data.totalRepaid end)
		pcall(function() data.paymentIntervalDays = tonumber(system:GetLoanPaymentIntervalDays()) or 30 end)
		data.termMonths = self:_deriveLoanTermMonths(data.termPayments or 0, data.paymentIntervalDays or 30)
		pcall(function() data.earlyPayoffAmount = tonumber(system:GetLoanEarlyPayoffAmount()) or 0 end)
		data.interestWaived = math.max((data.balanceDue or 0) - (data.earlyPayoffAmount or 0), 0)
		data.interestPercent = (data.interestBasisPoints or 0) / 100.0
	end

	if (not data.active or (data.balanceDue or 0) <= 0) and fallbackData.active then
		fallbackData.reviewActive = reviewData.active or false
		fallbackData.reviewState = reviewData.state or 0
		fallbackData.reviewPending = reviewData.pendingReview or false
		fallbackData.reviewApprovalReady = reviewData.approvalReady or false
		fallbackData.reviewFundingPending = reviewData.fundingPending or false
		fallbackData.reviewAmount = reviewData.amount or 0
		fallbackData.reviewSubmitDay = reviewData.submitDay or 0
		fallbackData.reviewDecisionDay = reviewData.decisionDay or 0
		fallbackData.reviewSubmitMinute = reviewData.submitMinute or 0
		fallbackData.reviewStartMinute = reviewData.startMinute or 0
		fallbackData.reviewDecisionMinute = reviewData.decisionMinute or 0
		fallbackData.reviewFundingDueMinute = reviewData.fundingDueMinute or 0
		fallbackData.reviewDecisionLabel = reviewData.decisionLabel or ""
		fallbackData.reviewFundingLabel = reviewData.fundingLabel or ""
		fallbackData.reviewRequiredStreetCred = reviewData.requiredStreetCred or 0
		fallbackData.reviewInterestBasisPoints = reviewData.interestBasisPoints or 0
		fallbackData.reviewTermPayments = reviewData.termPayments or 0
		fallbackData.reviewTermMonths = reviewData.termMonths or 0
		fallbackData.reviewIntervalDays = reviewData.intervalDays or 0
		fallbackData.reviewFrequencyCode = reviewData.frequencyCode or 0
		fallbackData.reviewFrequencyLabel = reviewData.frequencyLabel or ""
		fallbackData.reviewApprovalChance = reviewData.approvalChance or 0
		fallbackData.reviewApprovalRiskCode = reviewData.approvalRiskCode or 0
		fallbackData.reviewApprovalRiskLabel = reviewData.approvalRiskLabel or ""
		fallbackData.reviewTotalDue = reviewData.totalDue or 0
		fallbackData.reviewInstallment = reviewData.installment or 0
		return fallbackData
	end

	return data
end

function BANK:requestLoan(offerIndex)
	offerIndex = tonumber(offerIndex) or 0
	if offerIndex <= 0 then
		return false
	end

	local confirmationCode = self:_generateLoanConfirmationCode("APP")
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		local streetCred = self:getStreetCredLevel()
		local ok, result = pcall(function()
			return system:RequestLoan(gameInstance, math.floor(offerIndex), math.floor(streetCred))
		end)

		if ok and result == true then
			local loanInfo = self:getLoanData() or {}
			local principal = tonumber(loanInfo.principal) or 0
			local walletAfter = self:getWalletBalance()
			self:_storeLoanSmsThreadEntry("APP", principal, walletAfter - principal, walletAfter, confirmationCode)
			self:_clearFallbackLoan()
			self:_setLastLoanConfirmationCode(confirmationCode)
			self:_setLastTransactionConfirmationCode(confirmationCode)
			self:_syncWalletSnapshot()
			return true
		end
	end

	return self:_fallbackRequestLoan(offerIndex, confirmationCode)
end

function BANK:payLoan(amount)
	amount = tonumber(amount) or 0
	if amount <= 0 then
		return false
	end

	local loanBefore = self:getLoanData() or {}
	local beforeDue = math.floor(tonumber(loanBefore.balanceDue) or 0)
	local payoffRequested = beforeDue > 0 and math.floor(amount) >= beforeDue
	local confirmationCode = self:_generateLoanConfirmationCode(payoffRequested and "FUL" or "PAY")
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		local ok, result = pcall(function()
			return system:PayLoan(gameInstance, math.floor(amount))
		end)

		if ok and result == true then
			local afterDue = 0
			pcall(function() afterDue = tonumber(system:GetLoanBalanceDue()) or 0 end)
			local paid = math.max(beforeDue - math.floor(afterDue), 0)
			if paid <= 0 then paid = math.floor(tonumber(amount) or 0) end
			local walletAfter = self:getWalletBalance()
			self:_clearExternalWalletDebitSuppression()
			self:_markServicedLoanDebitHandled(walletAfter)
			if beforeDue > 0 and afterDue <= 0 then
				self:_storeLoanSmsThreadEntry("FUL", paid, walletAfter + paid, walletAfter, confirmationCode)
			else
				self:_storeLoanSmsThreadEntry("PAY", paid, walletAfter + paid, walletAfter, confirmationCode)
			end
			local cashbackEarned = self:_awardCashbackForLoanPayment(paid, walletAfter + paid, walletAfter, system, gameInstance)
			self:_markLastTransactionCashbackEarned(cashbackEarned)
			self:_setLastLoanConfirmationCode(confirmationCode)
			self:_setLastTransactionConfirmationCode(confirmationCode)
			return true
		end
	end

	return self:_fallbackPayLoan(amount, confirmationCode, false)
end

function BANK:payLoanInFull()
	local payoff = self:getLoanEarlyPayoffAmount()
	if payoff <= 0 then return false end
	local confirmationCode = self:_generateLoanConfirmationCode("FUL")
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		local ok, result = pcall(function()
			return system:PayLoanInFull(gameInstance)
		end)
		if ok and result == true then
			local walletAfter = self:getWalletBalance()
			self:_clearExternalWalletDebitSuppression()
			self:_markServicedLoanDebitHandled(walletAfter)
			self:_storeLoanSmsThreadEntry("FUL", payoff, walletAfter + payoff, walletAfter, confirmationCode)
			local cashbackEarned = self:_awardCashbackForLoanPayment(payoff, walletAfter + payoff, walletAfter, system, gameInstance)
			self:_markLastTransactionCashbackEarned(cashbackEarned)
			self:_setLastLoanConfirmationCode(confirmationCode)
			self:_setLastTransactionConfirmationCode(confirmationCode)
			return true
		end
	end
	return self:_fallbackPayLoanInFullPrincipalOnly(confirmationCode)
end

function BANK:syncLoanPayments()
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		pcall(function()
			system:SyncLoanPayments(gameInstance)
		end)
	end
	self:_syncFallbackLoanPayments()
end

function BANK:getCurrentHourValue()
	local now = os.clock()
	if self.cachedCurrentHourValue ~= nil and now < (tonumber(self.cachedCurrentHourUntil or 0) or 0) then
		return self.cachedCurrentHourValue
	end

	local time = Game.GetTimeSystem():GetGameTime()
	local hours = time:Hours()
	local minutes = time:Minutes()
	local value = hours + (minutes / 60.0)
	self.cachedCurrentHourValue = value
	self.cachedCurrentHourUntil = now + 0.50
	return value
end

function BANK:getCurrentHalfHourBucket()
	local now = os.clock()
	if self.cachedHalfHourBucket ~= nil and now < (tonumber(self.cachedHalfHourUntil or 0) or 0) then
		return self.cachedHalfHourBucket
	end

	local time = Game.GetTimeSystem():GetGameTime()
	local hours = time:Hours()
	local minutes = time:Minutes()
	local half = 0

	if minutes >= 30 then
		half = 1
	end

	local bucket = (hours * 2) + half
	self.cachedHalfHourBucket = bucket
	self.cachedHalfHourUntil = now + 0.50
	return bucket
end


function BANK:getLocationHours(locationType)
	local key = locationType or "atm"

	if key == "branchfront" or key == "greeter" then
		key = "branch"
	end

	return BANK_LOCATION_HOURS[key] or BANK_LOCATION_HOURS.atm
end

function BANK:isLocationOpen(locationType)
	local hours = self:getLocationHours(locationType)
	if not hours then
		return true
	end

	local currentHour = self:getCurrentHourValue()
	local openHour = hours.open
	local closeHour = hours.close

	if openHour == closeHour then
		return true
	end

	if closeHour >= 24 then
		return currentHour >= openHour
	end

	if openHour < closeHour then
		return currentHour >= openHour and currentHour < closeHour
	end

	return currentHour >= openHour or currentHour < closeHour
end

function BANK:formatHour12(hour)
	if hour == nil then
		return "12:00 AM"
	end

	local normalized = hour
	while normalized >= 24 do
		normalized = normalized - 24
	end

	local whole = math.floor(normalized)
	local fraction = normalized - whole
	local minutes = 0

	if fraction >= 0.5 then
		minutes = 30
	end

	local suffix = "AM"
	local displayHour = whole

	if whole == 0 then
		displayHour = 12
		suffix = "AM"
	elseif whole < 12 then
		displayHour = whole
		suffix = "AM"
	elseif whole == 12 then
		displayHour = 12
		suffix = "PM"
	else
		displayHour = whole - 12
		suffix = "PM"
	end

	return string.format("%d:%02d %s", displayHour, minutes, suffix)
end

function BANK:getHoursText(locationType)
	local hours = self:getLocationHours(locationType)
	if not hours then
		return "Hours unavailable"
	end

	if locationType == "atm" then
		return "24 Hours"
	end

	return self:formatHour12(hours.open) .. " - " .. self:formatHour12(hours.close)
end

function BANK:getStatusText(locationType)
	if self:isLocationOpen(locationType) then
		return Lang.getText("dlg_Bank_Status_Open")
	end

	return Lang.getText("dlg_Bank_Status_Closed")
end

function BANK:getLocationDisplayName(locationType)
	if locationType == "branch" or locationType == "branchfront" then
		return Lang.getText("dlg_Bank_Location_Branch")
	elseif locationType == "banker" then
		return Lang.getText("dlg_Bank_Location_Banker")
	end

	return "ATM"
end

function BANK:getClosedBranchOverlayText(locationType)
	locationType = locationType or "branch"
	return Lang.getText("pin_bank_estate_text")
		.. ": " .. self:getLocationDisplayName(locationType)
		.. "\n" .. Lang.getText("dlg_Bank_Status") .. self:getStatusText(locationType)
		.. "\n" .. Lang.getText("dlg_Bank_Hours") .. self:getHoursText(locationType)
		.. "\n\n" .. Lang.getText("scr_Bank_Closed")
end

function BANK:getMapPinCaption(locationType)
	if locationType == "branch" or locationType == "branchfront" or locationType == "banker" then
		return self:getLocationDisplayName(locationType) .. " • " .. self:getStatusText(locationType) .. " • " .. self:getHoursText(locationType)
	end

	return Lang.getText("pin_bank_droppoint_desc")
end

function BANK:getGreeterText(isOpen)
	local status = Lang.getText("dlg_Bank_Status_Closed")
	if isOpen then
		status = Lang.getText("dlg_Bank_Status_Open")
	end

	if isOpen then
		return Lang.getText("pin_bank_estate_text") .. ": " .. self:getLocationDisplayName("branch") .. " • Welcome • " .. status .. " • " .. self:getHoursText("branch")
	end

	return Lang.getText("pin_bank_estate_text") .. ": " .. self:getLocationDisplayName("branch") .. " • " .. status .. " • " .. self:getHoursText("branch")
end

function BANK:showHoursInfo(locationType)
	local title = Lang.getText("pin_bank_estate_text")
	local text = self:getLocationDisplayName(locationType)
		.. "\n"
		.. Lang.getText("dlg_Bank_Status") .. self:getStatusText(locationType)
		.. "\n"
		.. Lang.getText("dlg_Bank_Hours") .. self:getHoursText(locationType)

	if not self:isLocationOpen(locationType) then
		text = text .. "\n\n" .. Lang.getText("scr_Bank_Closed")
	end

	Game.GetAudioSystem():Play('ui_elevator_select')
	Util.popUpShard(title, text)
end

function BANK:_getCurrentGameTimeParts()
	local day, hour, minute = 0, 0, 0
	pcall(function()
		local time = Game.GetTimeSystem():GetGameTime()
		day = math.floor(tonumber(time:Days()) or 0)
		hour = math.floor(tonumber(time:Hours()) or 0)
		minute = math.floor(tonumber(time:Minutes()) or 0)
	end)
	return day, hour, minute
end

function BANK:_walletTxSlotExists(slot)
	return self:_getQuestFactInt(walletTxKey("seq", slot)) > 0
end

function BANK:_makeWalletTxTimestamp(day, hour, minute)
	local dayValue = math.floor(tonumber(day) or -1)
	if dayValue < 0 then return "Now" end

	local hour24 = math.floor(tonumber(hour) or 0)
	while hour24 >= 24 do hour24 = hour24 - 24 end
	while hour24 < 0 do hour24 = hour24 + 24 end
	local suffix = hour24 >= 12 and "PM" or "AM"
	local hour12 = hour24 % 12
	if hour12 == 0 then hour12 = 12 end
	return string.format("%d:%02d %s", hour12, math.floor(tonumber(minute) or 0), suffix)
end

function BANK:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
	local reward = math.max(math.floor(tonumber(cashbackEarned) or 0), 0)
	if reward <= 0 then return "" end
	return " Cashback earned: " .. tostring(reward) .. " E$ pending weekly payout."
end

function BANK:_makeWalletTxText(txType, amount, walletBefore, walletAfter, fraudReason, disputeStatus, cashbackEarned)
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if tonumber(txType) == 1 then
		return "website deposit posted for " .. tostring(amount) .. " E$. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$."
	end
	if tonumber(txType) == 2 then
		return "website withdrawal posted for " .. tostring(amount) .. " E$. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$."
	end
	if tonumber(txType) == 14 then
		return "early closure fee for " .. tostring(amount) .. " E$. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$."
	end
	if tonumber(txType) == 15 then
		return "Marmur Bank Theft Protection Guarantee — we detected unusual activity related to theft. The affected credit chip was deactivated, a replacement chip has been issued, and restoration of " .. tostring(amount) .. " E$ to checking has been approved. Thank you for being a valued customer."
	end
	if tonumber(txType) == 13 then
		return "dispute claim received — your dispute for " .. tostring(amount) .. " E$ has been submitted for review. Marmur Bank Claims will send a decision when the review is complete."
	end
	if tonumber(txType) == 16 then
		return "dispute approved — your dispute for " .. tostring(amount) .. " E$ was approved. A credit has been posted to checking."
	end
	if tonumber(txType) == 17 then
		return "dispute denied — after review, your dispute for " .. tostring(amount) .. " E$ was not approved. No credit was issued."
	end
	if tonumber(txType) == 18 then
		return "account notice — your account has been temporarily flagged due to recent dispute activity. Disputes are unavailable for 7 days. All other account functions remain operational."
	end
	if tonumber(txType) == 19 then
		return "account notice — your account review is complete. Disputes are available again. All account functions remain operational."
	end
	if tonumber(txType) == 20 then
		local destination = tonumber(disputeStatus) == 2 and "savings" or "checking"
		return "weekly cashback payout — " .. tostring(amount) .. " E$ credited to " .. destination .. " from eligible spend and loan payments. Rewards post every 7 days at 3:00 PM."
	end
	if tonumber(txType) == 25 then
		return "insurance settlement — Vanguard Auto settlement proceeds of " .. tostring(amount) .. " E$ received into checking. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$."
	end
	if tonumber(txType) == 26 then
		return "insurance loan payoff — Vanguard Auto settlement proceeds of " .. tostring(amount) .. " E$ applied to the financed auto loan. Insurance-paid loan payoffs are not cashback eligible."
	end
	if tonumber(txType) == 21 and tonumber(fraudReason) == 201 then
		return "Vanguard Auto payment - " .. tostring(amount) .. " E$ posted from checking. Checking: " .. tostring(walletBefore) .. " -> " .. tostring(walletAfter) .. " E$." .. self:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
	end
	if tonumber(txType) == 10 then
		if tonumber(disputeStatus) == 2 then
			return "security check resolved — purchase confirmed authorized for " .. tostring(amount) .. " E$. No further action is required."
		end
		if tonumber(disputeStatus) == 3 then
			return "security check escalated — suspicious purchase reported for " .. tostring(amount) .. " E$. Open Activity to file the dispute."
		end
		return "security alert — a purchase of " .. tostring(amount) .. " E$ posted. Did you authorize this purchase?"
	end
	if tonumber(disputeStatus) == MB_DISPUTE_STATUS_PENDING then
		return "purchase notice — a purchase of " .. tostring(amount) .. " E$ posted. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$. Status: dispute submitted for review." .. self:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
	end
	if tonumber(disputeStatus) == MB_DISPUTE_STATUS_APPROVED then
		return "purchase notice — a purchase of " .. tostring(amount) .. " E$ posted. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$. Status: dispute approved and credited." .. self:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
	end
	if tonumber(disputeStatus) == MB_DISPUTE_STATUS_DENIED then
		return "purchase notice — a purchase of " .. tostring(amount) .. " E$ posted. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$. Status: dispute denied." .. self:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
	end
	return "purchase notice — a purchase of " .. tostring(amount) .. " E$ posted. Checking: " .. tostring(walletBefore) .. " → " .. tostring(walletAfter) .. " E$. No reply is required." .. self:_formatCashbackEarnedLedgerSuffix(cashbackEarned)
end

function BANK:_walletTxFraudReason(amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount >= self:_getWalletFraudThreshold() then return 1 end
	return 0
end

function BANK:_getWalletFraudThreshold()
	return 150000
end

function BANK:_formatEddiesForAlert(amount)
	amount = math.floor(tonumber(amount) or 0)
	if Util and Util.formatNumber then
		local ok, formatted = pcall(function() return Util.formatNumber(amount) end)
		if ok and formatted ~= nil then
			return tostring(formatted)
		end
	end
	return tostring(amount)
end

function BANK:_sendFraudAlertScreenMessage(amount)
	if self:isJohnnySuppressed() then return end
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return end

	local now = os.clock()
	if (tonumber(self.lastFraudAlertScreenAmount) or 0) == amount
		and now - (tonumber(self.lastFraudAlertScreenTime) or 0) < 8.0 then
		return
	end

	self.lastFraudAlertScreenAmount = amount
	self.lastFraudAlertScreenTime = now
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank fraud alert: " .. self:_formatEddiesForAlert(amount) .. " E$ purchase. Open Messages to confirm.")
	end)
end

function BANK:_sendTheftProtectionScreenMessage(amount)
	if self:isJohnnySuppressed() then return end
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return end
	local now = os.clock()
	if (tonumber(self.lastTheftAlertScreenAmount) or 0) == amount
		and now - (tonumber(self.lastTheftAlertScreenTime) or 0) < 8.0 then
		return
	end
	self.lastTheftAlertScreenAmount = amount
	self.lastTheftAlertScreenTime = now
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank Theft Protection Guarantee: theft detected. " .. self:_formatEddiesForAlert(amount) .. " E$ restoration approved. Replacement chip issued.")
	end)
end

function BANK:_storeWalletTheftFallback(amount, walletBefore, walletAfter)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return end
	self:_storeWalletTxFact(15, amount, walletBefore, walletAfter, 4)
	self:_sendTheftProtectionScreenMessage(amount)
end

function BANK:recordTheftProtectionEvent(amount, walletBefore, walletAfter)
	if self:isJohnnySuppressed() then return end
	if not self:isAccountOpen() or not self:hasAccountEverOpened() then
		self:_syncWalletSnapshot()
		return
	end
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if amount <= 0 then return end
	if walletBefore <= walletAfter then
		walletBefore = walletAfter + amount
	end

	local projectedRestoredWallet = walletAfter + amount
	self:_storeWalletTheftFallback(amount, walletBefore, projectedRestoredWallet)

	Cron.After(1.25, function()
		local beforeRefund = self:getWalletBalance()
		local ok = self:_addWalletMoney(amount)
		if ok ~= true then
			Cron.After(0.75, function()
				self:_addWalletMoney(amount)
			end)
			return
		end

		local afterRefund = self:getWalletBalance()
		if afterRefund <= beforeRefund then
			self:_addWalletMoney(amount)
		end
	end)
end

function BANK:_systemHasMatchingFraudAlert(system, amount, walletBefore, walletAfter)
	if not system then return false end
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)

	local count = 0
	local countOk = pcall(function()
		count = math.max(math.floor(tonumber(system:GetTransactionLogCount()) or 0), 0)
	end)
	if countOk ~= true or count <= 0 then return false end

	local first = math.max(count - 24, 0)
	for index = count - 1, first, -1 do
		local txType, txAmount, txBefore, txAfter = 0, 0, 0, 0
		local rowOk = pcall(function()
			txType = math.floor(tonumber(system:GetTransactionTypeAt(index)) or 0)
			txAmount = math.floor(tonumber(system:GetTransactionAmountAt(index)) or 0)
			txBefore = math.floor(tonumber(system:GetTransactionWalletBeforeAt(index)) or 0)
			txAfter = math.floor(tonumber(system:GetTransactionWalletAfterAt(index)) or 0)
		end)
		if rowOk == true and txType == 10 and txAmount == amount and txBefore == walletBefore and txAfter == walletAfter then
			return true
		end
	end
	return false
end

function BANK:_storeFallbackFraudAlertIfNeeded(amount, walletBefore, walletAfter, system)
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if amount < self:_getWalletFraudThreshold() then return end
	if self:_systemHasMatchingFraudAlert(system, amount, walletBefore, walletAfter) then return end

	self:_storeWalletTxFact(10, amount, walletBefore, walletAfter, self:_walletTxFraudReason(amount), 0, 0, MB_SPEND_SUBJECT.uncategorized, MB_SPEND_PROVENANCE.wallet)
end

function BANK:_trackWalletFraudBurst(amount, walletBefore, walletAfter, system, alreadyStoredFallback)
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if amount <= 0 then return end

	local threshold = self:_getWalletFraudThreshold()
	local now = os.clock()
	local lastChange = tonumber(self.fraudBurstLastChangeTime) or 0

	if lastChange <= 0 or now - lastChange > 6.0 then
		self.fraudBurstAmount = 0
		self.fraudBurstBefore = walletBefore
		self.fraudBurstAfter = walletAfter
		self.fraudBurstNotified = false
	end

	self.fraudBurstAmount = math.floor(tonumber(self.fraudBurstAmount) or 0) + amount
	if walletBefore > (tonumber(self.fraudBurstBefore) or 0) then
		self.fraudBurstBefore = walletBefore
	end
	self.fraudBurstAfter = walletAfter
	self.fraudBurstLastChangeTime = now

	local burstAmount = math.floor(tonumber(self.fraudBurstAmount) or 0)
	if amount >= threshold then
		self.fraudBurstNotified = true
		self:_sendFraudAlertScreenMessage(amount)
		if alreadyStoredFallback ~= true then
			self:_storeFallbackFraudAlertIfNeeded(amount, walletBefore, walletAfter, system)
		end
		return
	end

	if burstAmount >= threshold and self.fraudBurstNotified ~= true then
		self.fraudBurstNotified = true
		self:_sendFraudAlertScreenMessage(burstAmount)
		self:_storeFallbackFraudAlertIfNeeded(burstAmount, self.fraudBurstBefore, self.fraudBurstAfter, system)
	end
end

function BANK:_ensureWalletTxRetentionState()
	local version = self:_getQuestFactInt(MB_WALLET_TX_RETENTION_VERSION)
	if version >= 2 then return end
	local legacyCount = math.max(self:_getQuestFactInt(MB_WALLET_TX_COUNT), 0)
	if legacyCount > MB_WALLET_TX_LEGACY_MAX then
		self:_setQuestFactInt(MB_WALLET_TX_HISTORY_TRIMMED, 1)
	end
	self:_setQuestFactInt(MB_WALLET_TX_RETENTION_VERSION, 2)
end

function BANK:_storeWalletTxFact(txType, amount, walletBefore, walletAfter, fraudReason, disputeStatus, cashbackEarned, subjectCode, provenanceCode)
	self:_ensureWalletTxRetentionState()
	local seq = self:_getQuestFactInt(MB_WALLET_TX_SEQ) + 1
	if seq <= 0 then seq = 1 end
	local count = math.max(self:_getQuestFactInt(MB_WALLET_TX_COUNT), 0)
	if count >= MB_WALLET_TX_MAX then
		self:_setQuestFactInt(MB_WALLET_TX_HISTORY_TRIMMED, 1)
	end
	local slot = (count % MB_WALLET_TX_MAX) + 1
	local day, hour, minute = self:_getCurrentGameTimeParts()

	self:_setQuestFactInt(walletTxKey("seq", slot), seq)
	self:_setQuestFactInt(walletTxKey("type", slot), math.floor(tonumber(txType) or 4))
	self:_setQuestFactInt(walletTxKey("amount", slot), math.floor(tonumber(amount) or 0))
	self:_setQuestFactInt(walletTxKey("wallet_before", slot), math.floor(tonumber(walletBefore) or 0))
	self:_setQuestFactInt(walletTxKey("wallet_after", slot), math.floor(tonumber(walletAfter) or 0))
	self:_setQuestFactInt(walletTxKey("day", slot), day)
	self:_setQuestFactInt(walletTxKey("hour", slot), hour)
	self:_setQuestFactInt(walletTxKey("minute", slot), minute)
	self:_setQuestFactInt(walletTxKey("review_day", slot), 0)
	self:_setQuestFactInt(walletTxKey("review_hour", slot), 0)
	self:_setQuestFactInt(walletTxKey("review_minute", slot), 0)
	self:_setQuestFactInt(walletTxKey("fraud_reason", slot), math.floor(tonumber(fraudReason) or 0))
	self:_setQuestFactInt(walletTxKey("dispute", slot), math.floor(tonumber(disputeStatus) or 0))
	self:_setQuestFactInt(walletTxKey("cashback", slot), math.max(math.floor(tonumber(cashbackEarned) or 0), 0))
	self:_setQuestFactInt(walletTxKey("subject", slot), math.max(0, math.min(math.floor(tonumber(subjectCode) or 0), 15)))
	self:_setQuestFactInt(walletTxKey("provenance", slot), math.max(0, math.min(math.floor(tonumber(provenanceCode) or 0), 5)))
	self:_setQuestFactInt(MB_WALLET_TX_SEQ, seq)
	self:_setQuestFactInt(MB_WALLET_TX_COUNT, count + 1)
	return slot
end

function BANK:_storeWalletSpendFallback(amount, walletBefore, walletAfter, cashbackEarned)
	local reason = self:_walletTxFraudReason(amount)
	self:_storeWalletTxFact(4, amount, walletBefore, walletAfter, 0, 0, cashbackEarned, MB_SPEND_SUBJECT.uncategorized, MB_SPEND_PROVENANCE.wallet)
	if reason > 0 then
		self:_storeWalletTxFact(10, amount, walletBefore, walletAfter, reason, 0, 0, MB_SPEND_SUBJECT.uncategorized, MB_SPEND_PROVENANCE.wallet)
		self:_sendFraudAlertScreenMessage(amount)
	end
end

function BANK:_transactionSortKeyFromParts(day, hour, minute, fallback)
	local d = math.floor(tonumber(day) or -1)
	local h = math.floor(tonumber(hour) or 0)
	local m = math.floor(tonumber(minute) or 0)
	local f = math.floor(tonumber(fallback) or 0)
	if d < 0 then return f end
	if h < 0 then h = 0 end
	if h > 23 then h = 23 end
	if m < 0 then m = 0 end
	if m > 59 then m = 59 end
	return (d * 1440 * 1000) + (h * 60 * 1000) + (m * 1000) + f
end

function BANK:_getWalletTxFactRows()
	self:_ensureWalletTxRetentionState()
	local rows = {}
	local disputeActionsAvailable = self:areDisputeActionsAvailable()
	for slot = 1, MB_WALLET_TX_MAX do
		if self:_walletTxSlotExists(slot) then
			local txType = self:_getQuestFactInt(walletTxKey("type", slot))
			local amount = self:_getQuestFactInt(walletTxKey("amount", slot))
			local walletBefore = self:_getQuestFactInt(walletTxKey("wallet_before", slot))
			local walletAfter = self:_getQuestFactInt(walletTxKey("wallet_after", slot))
			local day = self:_getQuestFactInt(walletTxKey("day", slot))
			local hour = self:_getQuestFactInt(walletTxKey("hour", slot))
			local minute = self:_getQuestFactInt(walletTxKey("minute", slot))
			local reason = self:_getQuestFactInt(walletTxKey("fraud_reason", slot))
			local dispute = self:_getQuestFactInt(walletTxKey("dispute", slot))
			local cashbackEarned = math.max(self:_getQuestFactInt(walletTxKey("cashback", slot)), 0)
			local subjectCode = math.max(0, math.min(self:_getQuestFactInt(walletTxKey("subject", slot)), 15))
			local provenanceCode = math.max(0, math.min(self:_getQuestFactInt(walletTxKey("provenance", slot)), 5))
			local seq = self:_getQuestFactInt(walletTxKey("seq", slot))
			local baseDisputable = txType == 4
				and dispute <= MB_DISPUTE_STATUS_NONE
				and provenanceCode > 0
				and amount > 0
				and walletBefore >= walletAfter
				and walletBefore - walletAfter == amount
			local row = {
				index = -slot,
				type = txType,
				amount = amount,
				tax = reason,
				timestamp = self:_makeWalletTxTimestamp(day, hour, minute),
				text = self:_makeWalletTxText(txType, amount, walletBefore, walletAfter, reason, dispute, cashbackEarned),
				disputable = baseDisputable and disputeActionsAvailable == true,
				disputeHiddenByCooldown = baseDisputable and disputeActionsAvailable ~= true,
				disputeStatus = dispute,
				cashbackEarned = cashbackEarned,
				subject = subjectCode,
				provenance = provenanceCode,
				walletBefore = walletBefore,
				walletAfter = walletAfter,
				seq = seq,
				day = day,
				hour = hour,
				minute = minute,
				sortKey = self:_transactionSortKeyFromParts(day, hour, minute, seq + 500),
				source = "wallet_fallback",
			}
			table.insert(rows, row)
		end
	end
	return rows
end

function BANK:_separatePendingWalletSpendForClassifiedDebit(amount, walletAfter)
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	walletAfter = math.max(math.floor(tonumber(walletAfter) or 0), 0)
	local pending = math.max(math.floor(tonumber(self.pendingWalletSpendAmount) or 0), 0)
	if pending <= 0 then return end

	local pendingAfter = math.max(math.floor(tonumber(self.pendingWalletSpendAfter) or 0), 0)
	if pendingAfter == walletAfter and pending >= amount and amount > 0 then
		local priorAmount = pending - amount
		if priorAmount <= 0 then
			self:_resetPendingWalletSpend()
			return
		end
		self.pendingWalletSpendAmount = priorAmount
		self.pendingWalletSpendAfter = walletAfter + amount
		self.pendingWalletSpendFlushTime = 0
		self:_flushPendingWalletSpend(true)
		return
	end

	self:_flushPendingWalletSpend(true)
end

function BANK:_reclassifyRecentWalletFallbackAsVanguard(amount, walletAfter)
	local bestSlot = 0
	local bestSeq = -1
	local newestSeq = math.max(self:_getQuestFactInt(MB_WALLET_TX_SEQ), 0)
	local oldestEligibleSeq = math.max(newestSeq - 7, 1)
	for slot = 1, MB_WALLET_TX_MAX do
		if self:_walletTxSlotExists(slot)
			and self:_getQuestFactInt(walletTxKey("type", slot)) == 4
			and self:_getQuestFactInt(walletTxKey("amount", slot)) == amount
			and self:_getQuestFactInt(walletTxKey("wallet_after", slot)) == walletAfter then
			local seq = self:_getQuestFactInt(walletTxKey("seq", slot))
			if seq >= oldestEligibleSeq and seq > bestSeq then
				local existingProvenance = self:_getQuestFactInt(walletTxKey("provenance", slot))
				local existingSubject = self:_getQuestFactInt(walletTxKey("subject", slot))
				if existingProvenance <= MB_SPEND_PROVENANCE.wallet then
					bestSeq = seq
					bestSlot = slot
				elseif existingSubject == MB_SPEND_SUBJECT.vehicles then
					return true
				end
			end
		end
	end
	if bestSlot <= 0 then return false end
	self:_setQuestFactInt(walletTxKey("type", bestSlot), 21)
	self:_setQuestFactInt(walletTxKey("fraud_reason", bestSlot), 201)
	self:_setQuestFactInt(walletTxKey("dispute", bestSlot), 0)
	self:_setQuestFactInt(walletTxKey("subject", bestSlot), MB_SPEND_SUBJECT.vehicles)
	self:_setQuestFactInt(walletTxKey("provenance", bestSlot), MB_SPEND_PROVENANCE.partner)
	return true
end

function BANK:_tryReclassifyRecentVanguardSpend(amount, walletAfter)
	local system = self:getUnifiedSystem()
	local reclassified = false
	if system then
		pcall(function()
			reclassified = system:ReclassifyLatestExternalSpendAsVanguard(amount, walletAfter) == true
		end)
	end
	if reclassified then return true end
	return self:_reclassifyRecentWalletFallbackAsVanguard(amount, walletAfter)
end

function BANK:_normalizeSpendSubject(subject)
	if type(subject) == "string" then
		return math.max(0, math.min(math.floor(tonumber(MB_SPEND_SUBJECT[subject]) or 0), 15))
	end
	return math.max(0, math.min(math.floor(tonumber(subject) or 0), 15))
end

function BANK:_normalizeSpendProvenance(provenance)
	if type(provenance) == "string" then
		return math.max(0, math.min(math.floor(tonumber(MB_SPEND_PROVENANCE[provenance]) or 0), 5))
	end
	return math.max(0, math.min(math.floor(tonumber(provenance) or 0), 5))
end

function BANK:_reclassifyRecentWalletFallbackSubject(amount, walletAfter, subjectCode, provenanceCode)
	local bestSlot = 0
	local bestSeq = -1
	local newestSeq = math.max(self:_getQuestFactInt(MB_WALLET_TX_SEQ), 0)
	local oldestEligibleSeq = math.max(newestSeq - 7, 1)
	for slot = 1, MB_WALLET_TX_MAX do
		if self:_walletTxSlotExists(slot)
			and self:_getQuestFactInt(walletTxKey("type", slot)) == 4
			and self:_getQuestFactInt(walletTxKey("amount", slot)) == amount
			and self:_getQuestFactInt(walletTxKey("wallet_after", slot)) == walletAfter then
			local seq = self:_getQuestFactInt(walletTxKey("seq", slot))
			if seq >= oldestEligibleSeq and seq > bestSeq then
				local existingProvenance = self:_getQuestFactInt(walletTxKey("provenance", slot))
				local existingSubject = self:_getQuestFactInt(walletTxKey("subject", slot))
				if existingProvenance <= MB_SPEND_PROVENANCE.wallet then
					bestSeq = seq
					bestSlot = slot
				elseif existingSubject == subjectCode then
					return true
				end
			end
		end
	end
	if bestSlot <= 0 then return false end
	self:_setQuestFactInt(walletTxKey("subject", bestSlot), subjectCode)
	self:_setQuestFactInt(walletTxKey("provenance", bestSlot), provenanceCode)
	return true
end

function BANK:_tryReclassifyRecentSpendSubject(amount, walletAfter, subjectCode, provenanceCode)
	local system = self:getUnifiedSystem()
	local reclassified = false
	if system then
		pcall(function()
			reclassified = system:ReclassifyLatestExternalSpendSubject(amount, walletAfter, subjectCode, provenanceCode) == true
		end)
	end
	if reclassified then return true end
	return self:_reclassifyRecentWalletFallbackSubject(amount, walletAfter, subjectCode, provenanceCode)
end

function BANK:_recordCategorizedWalletSpend(subject, amount, walletAfter, source, provenance, baselineWalletAfter)
	local subjectCode = self:_normalizeSpendSubject(subject)
	local provenanceCode = self:_normalizeSpendProvenance(provenance or "item")
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	walletAfter = math.max(math.floor(tonumber(walletAfter) or self:getWalletBalance() or 0), 0)
	baselineWalletAfter = math.max(math.floor(tonumber(baselineWalletAfter) or walletAfter), 0)
	if amount <= 0 or not self:isAccountOpen() or not self:hasAccountEverOpened() then return false end

	self:_separatePendingWalletSpendForClassifiedDebit(amount, baselineWalletAfter)
	local reclassified = self:_tryReclassifyRecentSpendSubject(amount, walletAfter, subjectCode, provenanceCode)
	if reclassified ~= true then
		local walletBefore = walletAfter + amount
		local reward = self:_awardCashbackForSpend(amount, walletBefore, walletAfter, nil, nil)
		local system = self:getUnifiedSystem()
		local gameInstance = self:getGameInstance()
		local beforeCount, beforeCountReadable = self:_readTransactionCount(system)
		local beforeSequence, beforeSequenceReadable = self:_readTransactionSequence(system)
		local appendCallOk = false
		local appendResult = nil
		if system and gameInstance then
			appendCallOk, appendResult = pcall(function()
				return system:RecordCategorizedExternalSpendWithCashback(gameInstance, amount, walletBefore, walletAfter, reward, subjectCode, provenanceCode)
			end)
		end
		local afterCount, afterCountReadable = self:_readTransactionCount(system)
		local afterSequence, afterSequenceReadable = self:_readTransactionSequence(system)
		local appended = appendCallOk == true and appendResult == true
		if beforeSequenceReadable and afterSequenceReadable then
			appended = afterSequence > beforeSequence
		elseif beforeCountReadable and afterCountReadable then
			appended = afterCount > beforeCount
		end
		if appended ~= true then
			local reason = self:_walletTxFraudReason(amount)
			self:_storeWalletTxFact(4, amount, walletBefore, walletAfter, 0, 0, reward, subjectCode, provenanceCode)
			if reason > 0 then
				self:_storeWalletTxFact(10, amount, walletBefore, walletAfter, reason, 0, 0, subjectCode, provenanceCode)
				self:_sendFraudAlertScreenMessage(amount)
			end
		end
	end

	self:_resetPendingWalletSpend()
	self.walletSessionPrimed = true
	self.walletSessionPrimeCandidate = baselineWalletAfter
	self.walletSessionPrimeCandidateTime = os.clock()
	self:_saveTrustedWalletBaseline(baselineWalletAfter, "categorized_analytics_" .. tostring(source or "purchase"))
	self:_setQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION, self:_getQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION) + 1)
	self.nextWalletSpendCheckTime = os.clock() + 0.20
	return true
end

function BANK:recordCategorizedObservedWalletSpend(subject, source, provenance)
	local walletAfter, readable = self:_tryReadWalletBalance()
	if readable ~= true then return false end
	if self:_primeWalletSessionIfNeeded(walletAfter) ~= true then return false end
	local previous = self.lastWalletSnapshot
	if previous == nil or previous < 0 then previous = self:_loadTrustedWalletBaseline() end
	previous = math.floor(tonumber(previous) or walletAfter)
	local amount = math.max(previous - walletAfter, 0)
	if amount <= 0 then return false end
	return self:_recordCategorizedWalletSpend(subject, amount, walletAfter, source or "observed", provenance or "item")
end

function BANK:recordCategorizedWalletSpend(subject, amount, source, provenance, ledgerWalletAfter)
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	if amount <= 0 then return false end
	local actualWalletAfter = self:getWalletBalance()
	local rowWalletAfter = math.max(math.floor(tonumber(ledgerWalletAfter) or actualWalletAfter), 0)
	return self:_recordCategorizedWalletSpend(subject, amount, rowWalletAfter, source or "known_amount", provenance or "service", actualWalletAfter)
end

function BANK:recordCategorizedExternalAccountSpend(subject, amount, source, provenance)
	local subjectCode = self:_normalizeSpendSubject(subject)
	local provenanceCode = self:_normalizeSpendProvenance(provenance or "external")
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	if amount <= 0 or not self:isAccountOpen() or not self:hasAccountEverOpened() then return false end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local beforeSequence, beforeReadable = self:_readTransactionSequence(system)
	local ok, result = false, nil
	if system and gameInstance then
		ok, result = pcall(function()
			return system:RecordCategorizedExternalAccountSpend(gameInstance, amount, subjectCode, provenanceCode)
		end)
	end
	local afterSequence, afterReadable = self:_readTransactionSequence(system)
	local appended = ok == true and result == true
	if beforeReadable and afterReadable then appended = afterSequence > beforeSequence end
	if appended ~= true then
		local wallet = self:getWalletBalance()
		self:_storeWalletTxFact(27, amount, wallet, wallet, 0, 0, 0, subjectCode, provenanceCode)
	end
	self:_setQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION, self:_getQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION) + 1)
	return true
end

function BANK:_recordClassifiedVanguardSpend(amount, walletAfter, source)
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	walletAfter = math.max(math.floor(tonumber(walletAfter) or self:getWalletBalance() or 0), 0)
	if amount <= 0 or not self:isAccountOpen() or not self:hasAccountEverOpened() then return false end

	self:_separatePendingWalletSpendForClassifiedDebit(amount, walletAfter)
	local reclassified = self:_tryReclassifyRecentVanguardSpend(amount, walletAfter)
	if reclassified ~= true then
		local walletBefore = walletAfter + amount
		local cashbackEarned = self:_awardCashbackForSpend(amount, walletBefore, walletAfter, nil, nil)
		self:_recordVanguardAutoPaymentActivity(amount, walletBefore, walletAfter, cashbackEarned)
	end

	self:_resetPendingWalletSpend()
	self.walletSessionPrimed = true
	self.walletSessionPrimeCandidate = walletAfter
	self.walletSessionPrimeCandidateTime = os.clock()
	self:_saveTrustedWalletBaseline(walletAfter, "vanguard_analytics_" .. tostring(source or "spend"))
	self:_setQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION, self:_getQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION) + 1)
	self.nextWalletSpendCheckTime = os.clock() + 0.20
	return true
end

function BANK:recordVanguardCashPurchase(amount)
	amount = math.max(math.floor(tonumber(amount) or 0), 0)
	if amount <= 0 then return false end
	return self:_recordClassifiedVanguardSpend(amount, self:getWalletBalance(), "cash_purchase")
end

function BANK:recordVanguardObservedWalletSpend(source)
	local walletAfter, readable = self:_tryReadWalletBalance()
	if readable ~= true then return false end
	if self:_primeWalletSessionIfNeeded(walletAfter) ~= true then return false end
	local previous = self.lastWalletSnapshot
	if previous == nil or previous < 0 then previous = self:_loadTrustedWalletBaseline() end
	previous = math.floor(tonumber(previous) or walletAfter)
	local amount = math.max(previous - walletAfter, 0)
	if amount <= 0 then return false end
	return self:_recordClassifiedVanguardSpend(amount, walletAfter, source or "observed")
end

function BANK:initializeVanguardAnalyticsCursor()
	if self:_getQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR) > 0 then return true end
	if self:_getQuestFactInt("marmur_vanguard_auto_sms_pending") == 1 then
		self:processVanguardAnalyticsEvents(true)
		if self:_getQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR) > 0 then return true end
	end
	return self:_syncVanguardAnalyticsCursorToCurrent()
end

function BANK:processVanguardAnalyticsEvents(force)
	local system = self:getVanguardAutoSystem()
	if not system then return 0 end
	local count = -1
	local countOk = pcall(function()
		count = math.floor(tonumber(system:GetFinanceEventCount()) or -1)
	end)
	if countOk ~= true or count < 0 then return 0 end

	local encodedCursor = self:_getQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR)
	if encodedCursor <= 0 then
		local initialCursor = count
		if count > 0 and self:_getQuestFactInt("marmur_vanguard_auto_sms_pending") == 1 then
			local newestKind = 0
			pcall(function() newestKind = math.floor(tonumber(system:GetFinanceEventKindAt(count - 1)) or 0) end)
			if newestKind == 1 then
				initialCursor = count - 1
			elseif newestKind == 19 then
				initialCursor = count - 1
				if count > 1 then
					local precedingKind = 0
					pcall(function() precedingKind = math.floor(tonumber(system:GetFinanceEventKindAt(count - 2)) or 0) end)
					if precedingKind == 1 then initialCursor = count - 2 end
				end
			end
		end
		self:_setQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR, initialCursor + 1)
		if initialCursor >= count then return 0 end
		encodedCursor = initialCursor + 1
	end

	local cursor = encodedCursor - 1
	if cursor < 0 or cursor > count then
		self:_setQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR, count + 1)
		return 0
	end

	local processed = 0
	local examined = 0
	while cursor < count and examined < 64 do
		local kind = 0
		local amount = 0
		local paymentSource = 1
		local readable = pcall(function()
			kind = math.floor(tonumber(system:GetFinanceEventKindAt(cursor)) or 0)
			amount = math.max(math.floor(tonumber(system:GetFinanceEventAmountAt(cursor)) or 0), 0)
			paymentSource = math.floor(tonumber(system:GetFinanceEventPaymentSourceAt(cursor)) or 1)
		end)
		if readable ~= true then break end

		if kind == 1 and amount > 0 and (not self:isAccountOpen() or not self:hasAccountEverOpened()) then
			self:_prepareVanguardAutoLoanThread()
		end

		local savingsTransferAlreadyRecorded = paymentSource == 2 and (kind == 2 or kind == 4)
		if amount > 0 and not savingsTransferAlreadyRecorded and (kind == 1 or kind == 2 or kind == 4 or kind == 19)
			and self:isAccountOpen() and self:hasAccountEverOpened() then
			if self:_recordClassifiedVanguardSpend(amount, self:getWalletBalance(), "finance_event_" .. tostring(kind)) then
				processed = processed + 1
			end
		end

		cursor = cursor + 1
		examined = examined + 1
		self:_setQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR, cursor + 1)
	end
	return processed
end

function BANK:_disputeWalletTxFact(slot)
	slot = math.floor(tonumber(slot) or 0)
	if slot <= 0 or slot > MB_WALLET_TX_MAX then return false end
	local result = self:submitDisputeClaim(-slot, 1)
	if type(result) == "table" then
		return result.ok == true
	end
	return result == true
end

function BANK:getDisputeReasons()
	return {
		{ code = 1, label = "I don't recognize this transaction", detail = "Use this for unauthorized activity or a charge you believe was made without your approval." },
		{ code = 2, label = "Duplicate charge", detail = "Use this when the same purchase appears more than once." },
		{ code = 3, label = "Incorrect amount charged", detail = "Use this when the posted amount does not match the expected total." },
		{ code = 4, label = "Item or service not received", detail = "Use this when a delivery, pickup, or paid service never arrived." },
		{ code = 5, label = "Item or service not as described", detail = "Use this when the purchase was delivered but did not match what was promised." },
		{ code = 6, label = "Canceled or returned, no credit received", detail = "Use this when a merchant reversal should have posted but has not." },
		{ code = 7, label = "Purchase made in error", detail = "Use this for accidental purchases. Frequent accidental disputes may trigger a temporary dispute cooldown." },
	}
end

function BANK:getDisputeReasonLabel(reasonCode)
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	for _, reason in ipairs(self:getDisputeReasons()) do
		if math.floor(tonumber(reason.code) or 0) == reasonCode then
			return reason.label
		end
	end
	return "Transaction review requested"
end

function BANK:getDisputeReasonDetail(reasonCode)
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	for _, reason in ipairs(self:getDisputeReasons()) do
		if math.floor(tonumber(reason.code) or 0) == reasonCode then
			return reason.detail
		end
	end
	return "Marmur Bank Claims will review the posted transaction details."
end

function BANK:isValidDisputeReason(reasonCode)
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	for _, reason in ipairs(self:getDisputeReasons()) do
		if math.floor(tonumber(reason.code) or 0) == reasonCode then return true end
	end
	return false
end

function BANK:_resetDisputePatternWindow(startStamp)
	local stamp = math.max(math.floor(tonumber(startStamp) or 0), 0)
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_START, stamp)
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_TOTAL, 0)
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_ACCIDENTAL, 0)
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_DENIED, 0)
end

function BANK:_ensureDisputePatternWindow(nowStamp)
	local now = math.max(math.floor(tonumber(nowStamp) or self:_getCurrentGameMinuteStamp()), 0)
	local start = self:_getQuestFactInt(MB_DISPUTE_WINDOW_START)
	if start <= 0 or now < start or now - start > MB_DISPUTE_WINDOW_MINUTES then
		self:_resetDisputePatternWindow(now)
	end
end

function BANK:formatDisputeCaseId(left, right)
	left = math.floor(tonumber(left) or 0) % 10000
	right = math.floor(tonumber(right) or 0) % 1000000
	return string.format("MB-DSP-%04d-%06d", left, right)
end

function BANK:_buildDisputeCaseParts(seq, amount, reasonCode, createdStamp)
	seq = math.floor(tonumber(seq) or 0)
	amount = math.floor(tonumber(amount) or 0)
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	createdStamp = math.max(math.floor(tonumber(createdStamp) or self:_getCurrentGameMinuteStamp()), 0)
	local day = math.floor(createdStamp / 1440)
	local left = day % 10000
	local right = ((seq * 7919) + (amount * 37) + (reasonCode * 101) + (createdStamp * 13)) % 1000000
	return left, right
end

function BANK:getDisputeReviewMinutes(reasonCode)
	return 24 * 60
end

function BANK:getDisputeCooldownRemainingMinutes()
	local untilStamp = self:_getQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE)
	if untilStamp <= 0 then return 0 end
	local now = self:_getCurrentGameMinuteStamp()
	if now >= untilStamp then return 0 end
	return untilStamp - now
end

function BANK:isDisputeCooldownActive()
	return self:getDisputeCooldownRemainingMinutes() > 0
end

function BANK:areDisputeActionsAvailable()
	self:processDisputeFlagCooldown()
	return self:getDisputeCooldownRemainingMinutes() <= 0
end

function BANK:getDisputeCooldownText()
	local remaining = self:getDisputeCooldownRemainingMinutes()
	if remaining <= 0 then return "Disputes available" end
	return "Dispute cooldown active: " .. self:formatMinutesAsShortDuration(remaining) .. " remaining"
end

function BANK:getDisputeStatusSummary()
	self:processDisputeFlagCooldown()
	local remaining = self:getDisputeCooldownRemainingMinutes()
	return {
		active = remaining > 0,
		remainingMinutes = remaining,
		text = self:getDisputeCooldownText(),
	}
end

function BANK:getDisputeFlagReasonText(flagCode, reasonCode)
	flagCode = math.floor(tonumber(flagCode) or 0)
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	if flagCode == 1 then
		return "Multiple purchase-made-in-error disputes were submitted within the current 30-day review window."
	end
	if flagCode == 2 then
		return "Multiple dispute submissions were made within the current 30-day review window."
	end
	if flagCode == 3 then
		return "Multiple dispute claims were denied during the current 30-day review window."
	end
	if reasonCode > 0 then
		return "Recent dispute activity requires a temporary account review. Last submitted reason: " .. self:getDisputeReasonLabel(reasonCode) .. "."
	end
	return "Recent dispute activity requires a temporary account review."
end

function BANK:_applyDisputeFlag(triggerReason, flagCode)
	if self:isDisputeCooldownActive() then return false end
	local now = self:_getCurrentGameMinuteStamp()
	local untilStamp = now + MB_DISPUTE_FLAG_MINUTES
	self:_setQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE, untilStamp)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID, untilStamp)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_CODE, math.floor(tonumber(flagCode) or 0))
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_REASON, math.floor(tonumber(triggerReason) or 0))
	self:_resetDisputePatternWindow(now)
	local wallet = self:getWalletBalance()
	self:_storeWalletTxFact(18, 0, wallet, wallet, math.floor(tonumber(triggerReason) or 0), 0)
	self:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank: dispute cooldown active for 7 days. Other account services remain available.")
	end)
	return true
end

function BANK:processDisputeFlagCooldown()
	local untilStamp = self:_getQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE)
	if untilStamp <= 0 then return false end
	local now = self:_getCurrentGameMinuteStamp()
	if now < untilStamp then return false end
	self:_setQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_CODE, 0)
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_REASON, 0)
	self:_resetDisputePatternWindow(now)
	local wallet = self:getWalletBalance()
	self:_storeWalletTxFact(19, 0, wallet, wallet, 0, 0)
	self:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank: account review complete. Disputes are available again.")
	end)
	return true
end

function BANK:getDisputeFlagNoticeSummary()
	self:processDisputeFlagCooldown()
	local remaining = self:getDisputeCooldownRemainingMinutes()
	local noticeId = self:_getQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID)
	local acknowledged = self:_getQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK)
	local flagCode = self:_getQuestFactInt(MB_DISPUTE_FLAG_NOTICE_CODE)
	local reasonCode = self:_getQuestFactInt(MB_DISPUTE_FLAG_NOTICE_REASON)
	if remaining > 0 and noticeId <= 0 then
		noticeId = self:_getQuestFactInt(MB_DISPUTE_FLAG_UNTIL_MINUTE)
		if noticeId > 0 then
			self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID, noticeId)
			self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK, 0)
			acknowledged = 0
		end
	end
	local show = remaining > 0 and noticeId > 0 and acknowledged ~= noticeId
	return {
		show = show,
		active = remaining > 0,
		noticeId = noticeId,
		acknowledged = acknowledged,
		remainingMinutes = remaining,
		remainingText = self:formatMinutesAsShortDuration(remaining),
		statusText = self:getDisputeCooldownText(),
		flagCode = flagCode,
		reasonCode = reasonCode,
		reasonText = self:getDisputeFlagReasonText(flagCode, reasonCode),
	}
end

function BANK:shouldShowDisputeFlagNotice()
	local summary = self:getDisputeFlagNoticeSummary()
	return type(summary) == "table" and summary.show == true
end

function BANK:acknowledgeDisputeFlagNotice()
	self:processDisputeFlagCooldown()
	local noticeId = self:_getQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ID)
	if noticeId <= 0 then return false end
	self:_setQuestFactInt(MB_DISPUTE_FLAG_NOTICE_ACK, noticeId)
	return true
end

function BANK:_recordDisputeSubmissionPattern(reasonCode)
	local now = self:_getCurrentGameMinuteStamp()
	self:_ensureDisputePatternWindow(now)
	local total = self:_getQuestFactInt(MB_DISPUTE_WINDOW_TOTAL) + 1
	local accidental = self:_getQuestFactInt(MB_DISPUTE_WINDOW_ACCIDENTAL)
	if math.floor(tonumber(reasonCode) or 0) == 7 then
		accidental = accidental + 1
	end
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_TOTAL, total)
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_ACCIDENTAL, accidental)

	if accidental >= 3 then
		return self:_applyDisputeFlag(reasonCode, 1)
	end
	if total >= 6 then
		return self:_applyDisputeFlag(reasonCode, 2)
	end
	return false
end

function BANK:_recordDisputeDeniedPattern(reasonCode)
	local now = self:_getCurrentGameMinuteStamp()
	self:_ensureDisputePatternWindow(now)
	local denied = self:_getQuestFactInt(MB_DISPUTE_WINDOW_DENIED) + 1
	self:_setQuestFactInt(MB_DISPUTE_WINDOW_DENIED, denied)
	if denied >= 3 then
		return self:_applyDisputeFlag(reasonCode, 3)
	end
	return false
end

function BANK:_coerceDisputeIndexList(index)
	local list = {}
	if type(index) == "table" then
		for _, value in ipairs(index) do
			local item = tonumber(value)
			if item ~= nil then table.insert(list, math.floor(item)) end
		end
	else
		local item = tonumber(index)
		if item ~= nil then table.insert(list, math.floor(item)) end
	end
	return list
end

function BANK:_getVerifiedDebitAmount(index)
	index = math.floor(tonumber(index) or 0)
	local txType = 0
	local amount = 0
	local provenance = 0
	local walletBefore = -1
	local walletAfter = -1

	if index < 0 then
		local slot = -index
		if slot <= 0 or slot > MB_WALLET_TX_MAX or not self:_walletTxSlotExists(slot) then return 0 end
		txType = self:_getQuestFactInt(walletTxKey("type", slot))
		amount = self:_getQuestFactInt(walletTxKey("amount", slot))
		provenance = self:_getQuestFactInt(walletTxKey("provenance", slot))
		walletBefore = self:_getQuestFactInt(walletTxKey("wallet_before", slot))
		walletAfter = self:_getQuestFactInt(walletTxKey("wallet_after", slot))
	else
		local system = self:getUnifiedSystem()
		if not system then return 0 end
		local ok = pcall(function()
			txType = tonumber(system:GetTransactionTypeAt(index)) or 0
			amount = tonumber(system:GetTransactionAmountAt(index)) or 0
			provenance = tonumber(system:GetTransactionProvenanceAt(index)) or 0
			walletBefore = tonumber(system:GetTransactionWalletBeforeAt(index)) or -1
			walletAfter = tonumber(system:GetTransactionWalletAfterAt(index)) or -1
		end)
		if ok ~= true then return 0 end
	end

	txType = math.floor(tonumber(txType) or 0)
	amount = math.floor(tonumber(amount) or 0)
	provenance = math.floor(tonumber(provenance) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or -1)
	walletAfter = math.floor(tonumber(walletAfter) or -1)
	if txType ~= 4 or amount <= 0 or provenance <= 0 then return 0 end
	if walletBefore < walletAfter or walletBefore - walletAfter ~= amount then return 0 end
	return amount
end

function BANK:_getSingleTransactionDisputeStatus(index)
	index = math.floor(tonumber(index) or 0)
	if index < 0 then
		local slot = -index
		if slot <= 0 or slot > MB_WALLET_TX_MAX or not self:_walletTxSlotExists(slot) then return -1 end
		return self:_getQuestFactInt(walletTxKey("dispute", slot))
	end
	local status = -1
	local system = self:getUnifiedSystem()
	if not system then return -1 end
	local ok = pcall(function() status = tonumber(system:GetTransactionDisputeStatusAt(index)) or -1 end)
	if ok ~= true then return -1 end
	return math.floor(status)
end

function BANK:_getSingleTransactionAmount(index)
	index = math.floor(tonumber(index) or 0)
	if index < 0 then
		local slot = -index
		if slot > 0 and slot <= MB_WALLET_TX_MAX and self:_walletTxSlotExists(slot) then
			return self:_getQuestFactInt(walletTxKey("amount", slot))
		end
		return 0
	end
	local amount = 0
	local system = self:getUnifiedSystem()
	if system then
		pcall(function() amount = tonumber(system:GetTransactionAmountAt(index)) or 0 end)
	end
	return math.floor(amount)
end

function BANK:_getDisputeAmountForIndexes(indexList, amountOverride)
	local total = 0
	for _, index in ipairs(indexList or {}) do
		local verified = self:_getVerifiedDebitAmount(index)
		if verified <= 0 then return 0 end
		total = total + verified
	end
	local override = math.floor(tonumber(amountOverride) or 0)
	if override > 0 and override ~= total then return 0 end
	return math.floor(total)
end

function BANK:_isSingleTransactionDisputable(index)
	index = math.floor(tonumber(index) or 0)
	if self:_getVerifiedDebitAmount(index) <= 0 then return false end
	if index < 0 then
		local slot = -index
		if slot <= 0 or slot > MB_WALLET_TX_MAX then return false end
		if not self:_walletTxSlotExists(slot) then return false end
		return self:_getQuestFactInt(walletTxKey("dispute", slot)) <= MB_DISPUTE_STATUS_NONE
	end

	local system = self:getUnifiedSystem()
	if not system then return false end
	local ok, result = pcall(function()
		return system:GetTransactionIsDisputableAt(index)
	end)
	return ok and result == true
end

function BANK:_isDisputeIndexDisputable(indexList)
	if type(indexList) ~= "table" or #indexList <= 0 then return false end
	for _, index in ipairs(indexList) do
		if not self:_isSingleTransactionDisputable(index) then return false end
	end
	return true
end

function BANK:_setSingleTransactionDisputeStatus(index, status)
	index = math.floor(tonumber(index) or 0)
	status = math.floor(tonumber(status) or 0)
	local verified = self:_getVerifiedDebitAmount(index) > 0
	local closingUnverifiedPending = (status == MB_DISPUTE_STATUS_APPROVED or status == MB_DISPUTE_STATUS_DENIED)
		and self:_getSingleTransactionDisputeStatus(index) == MB_DISPUTE_STATUS_PENDING
	if not verified and not closingUnverifiedPending then return false end
	if index < 0 then
		local slot = -index
		if slot <= 0 or slot > MB_WALLET_TX_MAX then return false end
		if not self:_walletTxSlotExists(slot) then return false end
		self:_setQuestFactInt(walletTxKey("dispute", slot), status)
		return true
	end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system then return false end
	local ok, result = pcall(function()
		return system:SetTransactionDisputeStatusAt(index, status)
	end)
	if ok and result == true then return true end

	if status == MB_DISPUTE_STATUS_PENDING and gameInstance then
		local fallbackOk, fallbackResult = pcall(function()
			return system:DisputeTransactionAt(gameInstance, index)
		end)
		return fallbackOk and fallbackResult == true
	end
	return false
end

function BANK:_setDisputeStatusForIndexes(indexList, status)
	local updated = {}
	for _, index in ipairs(indexList or {}) do
		if self:_setSingleTransactionDisputeStatus(index, status) == true then
			table.insert(updated, index)
		else
			for _, rollbackIndex in ipairs(updated) do
				self:_setSingleTransactionDisputeStatus(rollbackIndex, MB_DISPUTE_STATUS_NONE)
			end
			return false
		end
	end
	return #updated > 0 and #updated == #(indexList or {})
end

function BANK:_storeDisputeClaim(indexList, amount, reasonCode, walletBefore, walletAfter)
	local seq = self:_getQuestFactInt(MB_DISPUTE_CLAIM_SEQ) + 1
	if seq <= 0 then seq = 1 end
	local count = self:_getQuestFactInt(MB_DISPUTE_CLAIM_COUNT)
	local slot = (count % MB_DISPUTE_CLAIM_MAX) + 1
	local created = self:_getCurrentGameMinuteStamp()
	local due = created + self:getDisputeReviewMinutes(reasonCode)
	local caseLeft, caseRight = self:_buildDisputeCaseParts(seq, amount, reasonCode, created)
	local indexCount = math.min(#(indexList or {}), MB_DISPUTE_CLAIM_INDEX_MAX)

	self:_setQuestFactInt(disputeClaimKey("seq", slot), seq)
	self:_setQuestFactInt(disputeClaimKey("amount", slot), math.floor(tonumber(amount) or 0))
	self:_setQuestFactInt(disputeClaimKey("reason", slot), math.floor(tonumber(reasonCode) or 0))
	self:_setQuestFactInt(disputeClaimKey("status", slot), 1)
	self:_setQuestFactInt(disputeClaimKey("created", slot), created)
	self:_setQuestFactInt(disputeClaimKey("due", slot), due)
	self:_setQuestFactInt(disputeClaimKey("wallet_before", slot), math.floor(tonumber(walletBefore) or 0))
	self:_setQuestFactInt(disputeClaimKey("wallet_after", slot), math.floor(tonumber(walletAfter) or 0))
	self:_setQuestFactInt(disputeClaimKey("case_left", slot), caseLeft)
	self:_setQuestFactInt(disputeClaimKey("case_right", slot), caseRight)
	self:_setQuestFactInt(disputeClaimKey("index_count", slot), indexCount)
	for idx = 1, MB_DISPUTE_CLAIM_INDEX_MAX do
		local value = 0
		if idx <= indexCount then value = math.floor(tonumber(indexList[idx]) or 0) end
		self:_setQuestFactInt(disputeClaimKey("index_" .. tostring(idx), slot), value)
	end
	self:_setQuestFactInt(MB_DISPUTE_CLAIM_SEQ, seq)
	self:_setQuestFactInt(MB_DISPUTE_CLAIM_COUNT, count + 1)

	return {
		slot = slot,
		seq = seq,
		caseId = self:formatDisputeCaseId(caseLeft, caseRight),
		dueStamp = due,
		createdStamp = created,
	}
end

function BANK:_getDisputeClaimIndexes(slot)
	local list = {}
	slot = math.floor(tonumber(slot) or 0)
	if slot <= 0 or slot > MB_DISPUTE_CLAIM_MAX then return list end
	local count = self:_getQuestFactInt(disputeClaimKey("index_count", slot))
	if count < 0 then count = 0 end
	if count > MB_DISPUTE_CLAIM_INDEX_MAX then count = MB_DISPUTE_CLAIM_INDEX_MAX end
	for idx = 1, count do
		local value = self:_getQuestFactInt(disputeClaimKey("index_" .. tostring(idx), slot))
		table.insert(list, value)
	end
	return list
end

function BANK:_calculateDisputeApproval(slot)
	slot = math.floor(tonumber(slot) or 0)
	local amount = self:_getQuestFactInt(disputeClaimKey("amount", slot))
	local reason = self:_getQuestFactInt(disputeClaimKey("reason", slot))
	local seq = self:_getQuestFactInt(disputeClaimKey("seq", slot))
	local created = self:_getQuestFactInt(disputeClaimKey("created", slot))
	local threshold = 30

	if reason == 1 then
		threshold = amount >= self:_getWalletFraudThreshold() and 92 or 62
	elseif reason == 2 then
		threshold = 68
	elseif reason == 3 then
		threshold = 42
	elseif reason == 4 then
		threshold = 56
	elseif reason == 5 then
		threshold = 38
	elseif reason == 6 then
		threshold = 50
	elseif reason == 7 then
		threshold = amount <= 500 and 32 or 8
	end

	local roll = ((seq * 37) + (amount * 13) + (reason * 17) + (created * 7)) % 100
	return roll < threshold, roll, threshold
end

function BANK:_markDisputeClaimResolved(slot, status)
	slot = math.floor(tonumber(slot) or 0)
	status = math.floor(tonumber(status) or 0)
	if slot <= 0 or slot > MB_DISPUTE_CLAIM_MAX then return false end
	self:_setQuestFactInt(disputeClaimKey("status", slot), status)
	self:_setQuestFactInt(disputeClaimKey("due", slot), 0)
	self:_setDisputeStatusForIndexes(self:_getDisputeClaimIndexes(slot), status)
	return true
end

function BANK:submitDisputeClaim(index, reasonCode, amountOverride)
	self:processDisputeFlagCooldown()
	reasonCode = math.floor(tonumber(reasonCode) or 0)
	if not self:isValidDisputeReason(reasonCode) then
		return { ok = false, code = "reason", message = "Select a dispute reason before submitting the claim." }
	end

	local remaining = self:getDisputeCooldownRemainingMinutes()
	if remaining > 0 then
		return {
			ok = false,
			code = "cooldown",
			remainingMinutes = remaining,
			message = "Disputes are temporarily unavailable. " .. self:formatMinutesAsShortDuration(remaining) .. " remaining.",
		}
	end

	local indexList = self:_coerceDisputeIndexList(index)
	if not self:_isDisputeIndexDisputable(indexList) then
		return { ok = false, code = "not_disputable", message = "This transaction is not eligible for a new dispute." }
	end

	local amount = self:_getDisputeAmountForIndexes(indexList, amountOverride)
	if amount <= 0 then
		return { ok = false, code = "amount", message = "This transaction amount could not be verified." }
	end

	local walletBefore = self:getWalletBalance()
	local walletAfter = walletBefore
	if self:_setDisputeStatusForIndexes(indexList, MB_DISPUTE_STATUS_PENDING) ~= true then
		return { ok = false, code = "status", message = "This transaction could not be locked for review. Refresh Activity and try again." }
	end
	local claim = self:_storeDisputeClaim(indexList, amount, reasonCode, walletBefore, walletAfter)
	self:_storeWalletTxFact(13, amount, walletBefore, walletAfter, reasonCode, MB_DISPUTE_STATUS_PENDING)
	local flagged = self:_recordDisputeSubmissionPattern(reasonCode)
	self:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank dispute submitted: " .. self:_formatEddiesForAlert(amount) .. " E$")
	end)

	return {
		ok = true,
		caseId = claim.caseId,
		amount = amount,
		reasonCode = reasonCode,
		reasonLabel = self:getDisputeReasonLabel(reasonCode),
		dueStamp = claim.dueStamp,
		dueText = self:formatMinutesAsShortDuration(self:getDisputeReviewMinutes(reasonCode)),
		flagged = flagged == true,
	}
end

function BANK:processPendingDisputeClaims()
	local now = self:_getCurrentGameMinuteStamp()
	for slot = 1, MB_DISPUTE_CLAIM_MAX do
		local status = self:_getQuestFactInt(disputeClaimKey("status", slot))
		local due = self:_getQuestFactInt(disputeClaimKey("due", slot))
		if status == 1 and due > 0 and now >= due then
			local amount = self:_getQuestFactInt(disputeClaimKey("amount", slot))
			local reason = self:_getQuestFactInt(disputeClaimKey("reason", slot))
			local indexes = self:_getDisputeClaimIndexes(slot)
			local verifiedAmount = self:_getDisputeAmountForIndexes(indexes, 0)
			local everyPending = #indexes > 0
			for _, index in ipairs(indexes) do
				if self:_getSingleTransactionDisputeStatus(index) ~= MB_DISPUTE_STATUS_PENDING then
					everyPending = false
					break
				end
			end
			local approved = amount > 0 and verifiedAmount == amount and everyPending and self:_calculateDisputeApproval(slot)
			if approved == true then
				self:_setQuestFactInt(disputeClaimKey("status", slot), 2)
				self:_setQuestFactInt(disputeClaimKey("due", slot), 0)
				local refundOk, ambiguousCredit, beforeRefund, afterRefund = self:_creditDisputeRefundOnce(amount)
				if refundOk == true then
					self:_markDisputeClaimResolved(slot, MB_DISPUTE_STATUS_APPROVED)
					self:_storeWalletTxFact(16, amount, beforeRefund, afterRefund, reason, MB_DISPUTE_STATUS_APPROVED)
					self:ensureAccountPhoneThread()
					pcall(function()
						Util.simpleScreenMessage("Marmur Bank dispute approved: " .. self:_formatEddiesForAlert(amount) .. " E$ credited")
					end)
				elseif ambiguousCredit == true then
					self:_markDisputeClaimResolved(slot, MB_DISPUTE_STATUS_DENIED)
					self:_storeWalletTxFact(17, amount, beforeRefund, afterRefund, reason, MB_DISPUTE_STATUS_DENIED)
					self:ensureAccountPhoneThread()
				else
					self:_setQuestFactInt(disputeClaimKey("status", slot), 1)
					self:_setQuestFactInt(disputeClaimKey("due", slot), now + 60)
				end
			else
				local wallet = self:getWalletBalance()
				self:_markDisputeClaimResolved(slot, MB_DISPUTE_STATUS_DENIED)
				self:_storeWalletTxFact(17, amount, wallet, wallet, reason, MB_DISPUTE_STATUS_DENIED)
				self:_recordDisputeDeniedPattern(reason)
				self:ensureAccountPhoneThread()
				pcall(function()
					Util.simpleScreenMessage("Marmur Bank dispute denied: " .. self:_formatEddiesForAlert(amount) .. " E$")
				end)
			end
		end
	end
end

function BANK:processDisputeTimers()
	self:processDisputeFlagCooldown()
	self:processPendingDisputeClaims()
end

function BANK:recordWalletSpend(amount, walletBefore, walletAfter)
	if self:isJohnnySuppressed() then
		self:_syncWalletSnapshot()
		return
	end
	if not self:isAccountOpen() or not self:hasAccountEverOpened() then
		self:_syncWalletSnapshot()
		return
	end
	amount = math.floor(tonumber(amount) or 0)
	walletBefore = math.floor(tonumber(walletBefore) or 0)
	walletAfter = math.floor(tonumber(walletAfter) or 0)
	if amount <= 0 then
		return
	end
	if walletBefore <= walletAfter then
		walletBefore = walletAfter + amount
	end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local beforeCount, beforeCountReadable = self:_readTransactionCount(system)
	local beforeSequence, beforeSequenceReadable = self:_readTransactionSequence(system)
	local afterCount, afterCountReadable = nil, false
	local afterSequence, afterSequenceReadable = nil, false
	local appendCallOk = false
	local appendResult = nil
	local amountToRecord = amount
	local localSuppressed = 0
	local recordWalletBefore = walletBefore

	amountToRecord, localSuppressed = self:_consumeLocalWalletDebitSuppression(amountToRecord)
	if system and amountToRecord > 0 then
		local beforeSuppression = amountToRecord
		pcall(function()
			amountToRecord = tonumber(system:ConsumeExternalWalletDebitSuppressionForLua(amountToRecord)) or amountToRecord
		end)
		if amountToRecord < beforeSuppression then
			if self.walletLedgerAuditEnabled == true then
				self:_walletLedgerAudit("consume_redscript_suppression requested=" .. tostring(beforeSuppression) .. " recorded=" .. tostring(amountToRecord))
			end
		end
	end

	if amountToRecord <= 0 then
		if self.walletLedgerAuditEnabled == true then
			self:_walletLedgerAudit("wallet_debit_suppressed amount=" .. tostring(amount) .. " local=" .. tostring(localSuppressed) .. " walletBefore=" .. tostring(walletBefore) .. " walletAfter=" .. tostring(walletAfter))
		end
		self:_resetPendingWalletSpend()
		self:_saveTrustedWalletBaseline(walletAfter, "suppressed_debit")
		return
	end

	if amountToRecord < amount then
		recordWalletBefore = walletAfter + amountToRecord
	end

	if self.walletLedgerAuditEnabled == true then
		self:_walletLedgerAudit("wallet_debit_detected raw=" .. tostring(amount) .. " record=" .. tostring(amountToRecord) .. " walletBefore=" .. tostring(recordWalletBefore) .. " walletAfter=" .. tostring(walletAfter))
	end

	local reward = self:_awardCashbackForSpend(amountToRecord, recordWalletBefore, walletAfter, system, gameInstance)
	if self.walletLedgerAuditEnabled == true then
		self:_walletLedgerAudit("cashback_awarded spend=" .. tostring(amountToRecord) .. " reward=" .. tostring(reward) .. " pendingSpend=" .. tostring(self:_getQuestFactInt(MB_CASHBACK_PENDING_SPEND)) .. " pendingEarned=" .. tostring(self:_getQuestFactInt(MB_CASHBACK_PENDING_EARNED)) .. " rateBp=" .. tostring(self:_getQuestFactInt(MB_CASHBACK_LAST_RATE_BP)))
	end

	if system and gameInstance then
		appendCallOk, appendResult = pcall(function()
			if system.RecordExternalSpendWithCashback then
				return system:RecordExternalSpendWithCashback(gameInstance, amountToRecord, recordWalletBefore, walletAfter, reward)
			else
				local result = system:RecordExternalSpend(gameInstance, amountToRecord, recordWalletBefore, walletAfter)
				if reward > 0 and system.SetLastTransactionCashbackEarned then
					system:SetLastTransactionCashbackEarned(reward)
				end
				return result
			end
		end)
		afterCount, afterCountReadable = self:_readTransactionCount(system)
		afterSequence, afterSequenceReadable = self:_readTransactionSequence(system)
	end

	local appended = appendCallOk == true and appendResult == true
	if beforeSequenceReadable and afterSequenceReadable then
		appended = afterSequence > beforeSequence
	elseif beforeCountReadable and afterCountReadable then
		appended = afterCount > beforeCount
	elseif appendCallOk == true and appendResult ~= false then
		appended = true
	end

	local usedFallback = false
	if appended ~= true then
		self:_storeWalletSpendFallback(amountToRecord, recordWalletBefore, walletAfter, reward)
		usedFallback = true
		if self.walletLedgerAuditEnabled == true then
			self:_walletLedgerAudit("wallet_debit_fallback_activity amount=" .. tostring(amountToRecord))
		end
	else
		if self.walletLedgerAuditEnabled == true then
			self:_walletLedgerAudit("wallet_debit_redscript_activity beforeSeq=" .. tostring(beforeSequence) .. " afterSeq=" .. tostring(afterSequence) .. " beforeCount=" .. tostring(beforeCount) .. " afterCount=" .. tostring(afterCount))
		end
	end

	self:_trackWalletFraudBurst(amountToRecord, recordWalletBefore, walletAfter, system, usedFallback)
	self:_saveTrustedWalletBaseline(walletAfter, "recorded_debit")
end

function BANK:updateWalletSpendMonitor(force)
	self.currentTime = self:_getNow(force == true)

	if force ~= true and self.currentTime < (tonumber(self.nextWalletSpendCheckTime or 0) or 0) then
		if (tonumber(self.pendingWalletSpendAmount or 0) or 0) > 0 then
			self:_flushPendingWalletSpend(false)
		end
		return
	end

	if self:isJohnnySuppressed() then
		self:_resetPendingWalletSpend()
		self.nextWalletSpendCheckTime = self.currentTime + 1.00
		local johnnyWallet, johnnyReadable = self:_tryReadWalletBalance()
		if johnnyReadable == true then
			self:_saveTrustedWalletBaseline(johnnyWallet, "johnny_suppressed_monitor")
		end
		return
	end

	local accountReady = self:_isWalletAccountReady(force == true)
	self.nextWalletSpendCheckTime = self.currentTime + (accountReady and 0.85 or 2.00)

	local wallet, readable, source = self:_tryReadWalletBalance()

	if not accountReady then
		self.walletSessionPrimed = false
		self.walletSessionPrimeCandidate = -1
		self.walletSessionPrimeCandidateTime = 0
		self:_resetPendingWalletSpend()
		self.fraudBurstAmount = 0
		self.fraudBurstBefore = 0
		self.fraudBurstAfter = 0
		self.fraudBurstLastChangeTime = 0
		self.fraudBurstNotified = false
		if readable == true then
			self:_saveTrustedWalletBaseline(wallet, "account_closed_or_not_ready")
		else
			local saved = self:_loadTrustedWalletBaseline()
			if saved ~= nil then self.lastWalletSnapshot = saved end
		end
		return
	end

	if readable ~= true then
		local saved = self:_loadTrustedWalletBaseline()
		if (self.lastWalletSnapshot == nil or self.lastWalletSnapshot < 0) and saved ~= nil then
			self.lastWalletSnapshot = saved
		end
		self:_flushPendingWalletSpend(false)
		return
	end

	if self:_primeWalletSessionIfNeeded(wallet) ~= true then
		return
	end

	local savedBaseline = self:_loadTrustedWalletBaseline()
	local previous = self.lastWalletSnapshot
	if previous == nil or previous < 0 then
		previous = savedBaseline
	end
	if (tonumber(self.pendingWalletSpendAmount) or 0) <= 0 and savedBaseline ~= nil and previous ~= nil and savedBaseline > previous then
		previous = savedBaseline
	end

	if previous == nil then
		self:_saveTrustedWalletBaseline(wallet, "first_read")
		return
	end

	previous = math.floor(tonumber(previous) or wallet)

	if wallet < previous then
		local delta = previous - wallet
		if delta >= 1 then
			if self.walletLedgerAuditEnabled == true then
				self:_walletLedgerAudit("monitor_delta previous=" .. tostring(previous) .. " current=" .. tostring(wallet) .. " delta=" .. tostring(delta) .. " force=" .. tostring(force == true) .. " source=" .. tostring(source or ""))
			end
			self:_queueWalletSpendDelta(delta, previous, wallet)
		end
	elseif wallet > previous then
		self:_flushPendingWalletSpend(true)
	end

	if (tonumber(self.pendingWalletSpendAmount) or 0) > 0 then
		self:_updateRuntimeWalletSnapshot(wallet, "monitor_pending")
	else
		self:_saveTrustedWalletBaseline(wallet, "monitor")
	end
	self:_flushPendingWalletSpend(false)
end

function BANK:_copyTransactionRow(row)
	local copy = {}
	for key, value in pairs(row or {}) do
		copy[key] = value
	end
	return copy
end

function BANK:_coalesceFragmentedWalletRows(rows)
	local sourceRows = rows or {}
	local hasMicroFragment = false
	for _, row in ipairs(sourceRows) do
		local txType = tonumber(row.type) or 0
		local amount = math.floor(tonumber(row.amount) or 0)
		if txType == 4 and amount > 0 and amount <= 10 then
			hasMicroFragment = true
			break
		end
	end
	if hasMicroFragment ~= true then
		return sourceRows
	end

	local passthrough = {}
	local groups = {}
	local groupOrder = {}

	for _, row in ipairs(sourceRows) do
		local txType = tonumber(row.type) or 0
		local amount = math.floor(tonumber(row.amount) or 0)
		local isMicroWalletFragment = txType == 4 and amount > 0 and amount <= 10

		if isMicroWalletFragment then
			local timeKey = tostring(row.day or "") .. ":" .. tostring(row.hour or "") .. ":" .. tostring(row.minute or "")
			local key = tostring(row.source or "") .. "|" .. timeKey .. "|" .. tostring(row.disputeStatus or 0)
			if groups[key] == nil then
				groups[key] = { rows = {}, amount = 0, cashbackEarned = 0, sortKey = tonumber(row.sortKey) or 0, source = row.source, timestamp = row.timestamp, disputeStatus = row.disputeStatus }
				table.insert(groupOrder, key)
			end
			local group = groups[key]
			table.insert(group.rows, row)
			group.amount = group.amount + amount
			group.cashbackEarned = math.max(math.floor(tonumber(group.cashbackEarned) or 0), 0) + math.max(math.floor(tonumber(row.cashbackEarned) or 0), 0)
			if (tonumber(row.sortKey) or 0) > (tonumber(group.sortKey) or 0) then
				group.sortKey = tonumber(row.sortKey) or 0
			end
		else
			table.insert(passthrough, row)
		end
	end

	local mergedRows = {}
	for _, row in ipairs(passthrough) do
		table.insert(mergedRows, row)
	end

	for _, key in ipairs(groupOrder) do
		local group = groups[key]
		if group ~= nil and #group.rows > 1 then
			local base = self:_copyTransactionRow(group.rows[1])
			local indexes = {}
			local disputable = false
			local hiddenByCooldown = false
			for _, item in ipairs(group.rows) do
				if item.index ~= nil then table.insert(indexes, item.index) end
				if item.disputable == true then disputable = true end
				if item.disputeHiddenByCooldown == true then hiddenByCooldown = true end
			end
			base.index = indexes
			base.amount = group.amount
			base.cashbackEarned = math.max(math.floor(tonumber(group.cashbackEarned) or 0), 0)
			base.sortKey = group.sortKey
			base.disputable = disputable
			base.disputeHiddenByCooldown = hiddenByCooldown and disputable ~= true
			base.text = "combined same-minute checking debits for " .. tostring(group.amount) .. " E$." .. self:_formatCashbackEarnedLedgerSuffix(base.cashbackEarned)
			base.fragmentCount = #group.rows
			table.insert(mergedRows, base)
		elseif group ~= nil and #group.rows == 1 then
			table.insert(mergedRows, group.rows[1])
		end
	end

	return mergedRows
end

function BANK:_transactionCrossSourceKey(row)
	row = row or {}
	return table.concat({
		tostring(math.floor(tonumber(row.type) or 0)),
		tostring(math.floor(tonumber(row.amount) or 0)),
		tostring(math.floor(tonumber(row.day) or -1)),
		tostring(math.floor(tonumber(row.hour) or 0)),
		tostring(math.floor(tonumber(row.minute) or 0)),
		tostring(math.floor(tonumber(row.walletBefore) or 0)),
		tostring(math.floor(tonumber(row.walletAfter) or 0)),
		tostring(math.max(math.floor(tonumber(row.cashbackEarned) or 0), 0)),
	}, "|")
end

function BANK:_dedupeCrossSourceTransactionRows(rows)
	local primary = {}
	local result = {}
	for _, row in ipairs(rows or {}) do
		if row.source == "bank_ledger" then
			if math.floor(tonumber(row.type) or 0) == 4 then
				primary[self:_transactionCrossSourceKey(row)] = row
			end
			table.insert(result, row)
		end
	end
	for _, row in ipairs(rows or {}) do
		if row.source ~= "bank_ledger" then
			local key = self:_transactionCrossSourceKey(row)
			local primaryRow = primary[key]
			if math.floor(tonumber(row.type) or 0) == 4 and primaryRow ~= nil then
				if math.floor(tonumber(row.provenance) or 0) > math.floor(tonumber(primaryRow.provenance) or 0) then
					primaryRow.subject = math.floor(tonumber(row.subject) or 0)
					primaryRow.provenance = math.floor(tonumber(row.provenance) or 0)
				end
			else
				table.insert(result, row)
			end
		end
	end
	return result
end

function BANK:_transactionSortKeyFromTimestamp(timestamp, fallback)
	local text = tostring(timestamp or "")
	local day, hour, minute = string.match(text, "Day%s+(%d+)%s+(%d+):(%d+)")
	local suffix = nil
	if hour == nil then
		hour, minute, suffix = string.match(text, "(%d+):(%d+)%s*([AP]M)")
	end
	day = tonumber(day) or 0
	hour = tonumber(hour) or 0
	minute = tonumber(minute) or 0
	if suffix == "PM" and hour < 12 then hour = hour + 12 end
	if suffix == "AM" and hour == 12 then hour = 0 end
	return (day * 1440 * 1000) + (hour * 60 * 1000) + (minute * 1000) + (tonumber(fallback) or 0)
end

function BANK:_collectTransactionRows(includeDetails)
	includeDetails = includeDetails == true
	self:processDisputeTimers()
	self:processVanguardAnalyticsEvents(true)
	self:updateWalletSpendMonitor(true)
	self:_flushPendingWalletSpend(false)
	local rows = {}
	local disputeActionsAvailable = self:areDisputeActionsAvailable()
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if system and gameInstance then
		local count = 0
		pcall(function() count = tonumber(system:GetTransactionLogCount()) or 0 end)
		if count > 0 then
			for i = count - 1, 0, -1 do
				local row = { index = i, type = 0, amount = 0, tax = 0, subject = 0, provenance = 0, day = -1, hour = 0, minute = 0, timestamp = "", text = "", disputable = false, disputeStatus = 0, sortKey = i, ledgerOrder = i, source = "bank_ledger" }
				pcall(function() row.type = tonumber(system:GetTransactionTypeAt(i)) or 0 end)
				pcall(function() row.amount = tonumber(system:GetTransactionAmountAt(i)) or 0 end)
				pcall(function() row.tax = tonumber(system:GetTransactionTaxAt(i)) or 0 end)
				pcall(function() row.subject = tonumber(system:GetTransactionSubjectAt(i)) or 0 end)
				pcall(function() row.provenance = tonumber(system:GetTransactionProvenanceAt(i)) or 0 end)
				pcall(function() row.day = tonumber(system:GetTransactionDayAt(i)) or -1 end)
				pcall(function() row.hour = tonumber(system:GetTransactionHourAt(i)) or 0 end)
				pcall(function() row.minute = tonumber(system:GetTransactionMinuteAt(i)) or 0 end)
				pcall(function() row.walletBefore = tonumber(system:GetTransactionWalletBeforeAt(i)) or 0 end)
				pcall(function() row.walletAfter = tonumber(system:GetTransactionWalletAfterAt(i)) or 0 end)
				row.timestamp = self:_makeWalletTxTimestamp(row.day, row.hour, row.minute)
				if includeDetails then
					pcall(function() row.text = tostring(system:GetTransactionLogAt(i) or "") end)
				end
				local baseDisputable = false
				pcall(function() baseDisputable = system:GetTransactionIsDisputableAt(i) == true end)
				row.disputable = baseDisputable and disputeActionsAvailable == true
				row.disputeHiddenByCooldown = baseDisputable and disputeActionsAvailable ~= true
				pcall(function() row.disputeStatus = tonumber(system:GetTransactionDisputeStatusAt(i)) or 0 end)
				pcall(function() row.cashbackEarned = math.max(math.floor(tonumber(system:GetTransactionCashbackEarnedAt(i)) or 0), 0) end)

				row.sortKey = self:_transactionSortKeyFromParts(row.day, row.hour, row.minute, i)
				row.ledgerOrder = row.sortKey
				table.insert(rows, row)
			end
		end
	end

	for _, row in ipairs(self:_getWalletTxFactRows()) do
		row.sortKey = tonumber(row.sortKey) or self:_transactionSortKeyFromParts(row.day, row.hour, row.minute, tonumber(row.seq or 0) + 500)
		row.ledgerOrder = row.sortKey
		table.insert(rows, row)
	end

	rows = self:_dedupeCrossSourceTransactionRows(rows)

	table.sort(rows, function(a, b)
		local ak = tonumber(a.sortKey) or 0
		local bk = tonumber(b.sortKey) or 0
		if ak == bk then
			return (tonumber(a.ledgerOrder) or 0) > (tonumber(b.ledgerOrder) or 0)
		end
		return ak > bk
	end)
	return rows
end

function BANK:_enrichTransactionRows(rows)
	local system = nil
	for _, row in ipairs(rows or {}) do
		if tostring(row.timestamp or "") == "" then
			row.timestamp = self:_makeWalletTxTimestamp(row.day, row.hour, row.minute)
		end

		if row.source == "bank_ledger" and (row.text == nil or row.text == "") and (tonumber(row.index) or -1) >= 0 then
			if system == nil then system = self:getUnifiedSystem() end
			if system then
				pcall(function() row.text = tostring(system:GetTransactionLogAt(row.index) or "") end)
			end
		end
	end
	return rows
end

function BANK:getHomeBalanceHistory(days, currentWallet, currentBank)
	days = math.max(2, math.min(math.floor(tonumber(days) or 30), 90))
	currentWallet = math.max(math.floor(tonumber(currentWallet) or self:getWalletBalance() or 0), 0)
	currentBank = math.max(math.floor(tonumber(currentBank) or self:getUnifiedBalance() or 0), 0)
	local currentTotal = currentWallet + currentBank
	local currentDay = 0
	pcall(function() currentDay = math.floor(tonumber(self:_getCurrentGameDay()) or 0) end)
	if currentDay < 0 then currentDay = 0 end

	pcall(function() self:updateWalletSpendMonitor(true) end)
	pcall(function() self:_flushPendingWalletSpend(false) end)

	local system = self:getUnifiedSystem()
	local count = 0
	local sequence = 0
	if system then
		pcall(function() count = math.max(math.floor(tonumber(system:GetTransactionLogCount()) or 0), 0) end)
		pcall(function() sequence = math.max(math.floor(tonumber(system:GetTransactionSequence()) or count), 0) end)
	end

	local revision = table.concat({ tostring(days), tostring(currentDay), tostring(currentTotal), tostring(sequence), tostring(count) }, ":")
	local now = os.clock()
	if self.cachedHomeBalanceHistory ~= nil
		and self.cachedHomeBalanceHistoryRevision == revision
		and now < (tonumber(self.cachedHomeBalanceHistoryUntil or 0) or 0) then
		return self.cachedHomeBalanceHistory
	end

	local requestedStartDay = currentDay - days + 1
	local startDay = math.max(requestedStartDay, 0)
	local rows = {}
	local trimmed = false
	local boundaryDay = -1
	if system and count > 0 then
		pcall(function() trimmed = system:HasTransactionHistoryTrimmed() == true end)
		pcall(function() boundaryDay = math.floor(tonumber(system:GetTransactionHistoryBoundaryDay()) or -1) end)
		for i = 0, count - 1 do
			local row = { index = i, day = -1, hour = 0, minute = 0, walletBefore = 0, walletAfter = 0, bankBefore = 0, bankAfter = 0 }
			local readable = pcall(function()
				row.day = math.floor(tonumber(system:GetTransactionDayAt(i)) or -1)
				row.hour = math.floor(tonumber(system:GetTransactionHourAt(i)) or 0)
				row.minute = math.floor(tonumber(system:GetTransactionMinuteAt(i)) or 0)
				row.walletBefore = math.max(math.floor(tonumber(system:GetTransactionWalletBeforeAt(i)) or 0), 0)
				row.walletAfter = math.max(math.floor(tonumber(system:GetTransactionWalletAfterAt(i)) or 0), 0)
				row.bankBefore = math.max(math.floor(tonumber(system:GetTransactionBankBeforeAt(i)) or 0), 0)
				row.bankAfter = math.max(math.floor(tonumber(system:GetTransactionBankAfterAt(i)) or 0), 0)
			end)
			if readable and row.day >= 0 and row.day <= currentDay then
				row.beforeTotal = row.walletBefore + row.bankBefore
				row.afterTotal = row.walletAfter + row.bankAfter
				table.insert(rows, row)
			end
		end
	end

	table.sort(rows, function(a, b)
		if a.day ~= b.day then return a.day < b.day end
		if a.hour ~= b.hour then return a.hour < b.hour end
		if a.minute ~= b.minute then return a.minute < b.minute end
		return a.index < b.index
	end)

	local lastBeforeWindow = nil
	local firstInWindow = nil
	local closeByDay = {}
	for _, row in ipairs(rows) do
		if row.day < startDay then
			lastBeforeWindow = row.afterTotal
		elseif row.day <= currentDay then
			if firstInWindow == nil then firstInWindow = row end
			closeByDay[row.day] = row.afterTotal
		end
	end

	local seriesStartDay = startDay
	local running = currentTotal
	if lastBeforeWindow ~= nil then
		running = math.max(math.floor(tonumber(lastBeforeWindow) or currentTotal), 0)
	elseif firstInWindow ~= nil then
		seriesStartDay = math.max(startDay, firstInWindow.day)
		running = math.max(math.floor(tonumber(firstInWindow.beforeTotal) or currentTotal), 0)
	end

	local points = {}
	for day = seriesStartDay, currentDay do
		if closeByDay[day] ~= nil then
			running = math.max(math.floor(tonumber(closeByDay[day]) or running), 0)
		end
		table.insert(points, { day = day, value = running })
	end

	if #points == 0 then
		table.insert(points, { day = currentDay, value = currentTotal })
	end
	points[#points].value = currentTotal

	local firstValue = math.max(math.floor(tonumber(points[1].value) or 0), 0)
	local lastValue = math.max(math.floor(tonumber(points[#points].value) or 0), 0)
	local changePercent = 0.0
	local changeAvailable = firstValue > 0 and #points > 1
	if changeAvailable then
		changePercent = ((lastValue - firstValue) / firstValue) * 100.0
	end

	local partial = startDay > requestedStartDay or seriesStartDay > startDay
	if trimmed and boundaryDay > startDay then partial = true end
	local result = {
		points = points,
		requestedDays = days,
		daysCovered = math.max(currentDay - seriesStartDay + 1, 1),
		startDay = seriesStartDay,
		endDay = currentDay,
		firstValue = firstValue,
		lastValue = lastValue,
		changePercent = changePercent,
		changeAvailable = changeAvailable,
		partial = partial,
		trimmed = trimmed,
		boundaryDay = boundaryDay,
		revision = revision,
	}

	self.cachedHomeBalanceHistory = result
	self.cachedHomeBalanceHistoryRevision = revision
	self.cachedHomeBalanceHistoryUntil = now + 2.0
	return result
end

function BANK:getTransactionRowCount()
	local rows = self:_collectTransactionRows(false)
	return #rows
end

function BANK:_normalizeTransactionSortMode(mode)
	mode = tostring(mode or "recent"):lower()
	if mode == "highest" or mode == "lowest" or mode == "oldest" or mode == "recent" then
		return mode
	end
	return "recent"
end

function BANK:_transactionAmountSortValue(row)
	return math.abs(math.floor(tonumber((row or {}).amount) or 0))
end

function BANK:_transactionChronoSortValue(row)
	return tonumber((row or {}).sortKey) or tonumber((row or {}).ledgerOrder) or 0
end

function BANK:_sortTransactionRowsByMode(rows, mode)
	mode = self:_normalizeTransactionSortMode(mode)
	if mode == "recent" then
		return rows
	end
	table.sort(rows, function(a, b)
		local ak = 0
		local bk = 0
		if mode == "highest" or mode == "lowest" then
			ak = self:_transactionAmountSortValue(a)
			bk = self:_transactionAmountSortValue(b)
			local aHasAmount = ak > 0
			local bHasAmount = bk > 0
			if aHasAmount ~= bHasAmount then
				return aHasAmount
			end
			if ak == bk then
				local at = self:_transactionChronoSortValue(a)
				local bt = self:_transactionChronoSortValue(b)
				if at == bt then
					return (tonumber((a or {}).ledgerOrder) or 0) > (tonumber((b or {}).ledgerOrder) or 0)
				end
				return at > bt
			end
			if mode == "highest" then return ak > bk end
			return ak < bk
		end

		ak = self:_transactionChronoSortValue(a)
		bk = self:_transactionChronoSortValue(b)
		if ak == bk then
			return (tonumber((a or {}).ledgerOrder) or 0) < (tonumber((b or {}).ledgerOrder) or 0)
		end
		return ak < bk
	end)
	return rows
end

function BANK:getTransactionRows(limit, offset, sortMode)
	limit = tonumber(limit) or 10
	offset = tonumber(offset) or 0
	if limit < 1 then limit = 10 end
	if offset < 0 then offset = 0 end
	local rows = self:_sortTransactionRowsByMode(self:_collectTransactionRows(false), sortMode)
	local trimmed = {}
	local first = offset + 1
	local last = math.min(offset + limit, #rows)
	for i = first, last do
		table.insert(trimmed, rows[i])
	end
	return self:_enrichTransactionRows(trimmed)
end

function BANK:getTransactionPage(limit, offset, sortMode)
	limit = tonumber(limit) or 10
	offset = tonumber(offset) or 0
	if limit < 1 then limit = 10 end
	if offset < 0 then offset = 0 end
	local rows = self:_sortTransactionRowsByMode(self:_collectTransactionRows(false), sortMode)
	local total = #rows
	local trimmed = {}
	local first = offset + 1
	local last = math.min(offset + limit, total)
	for i = first, last do
		table.insert(trimmed, rows[i])
	end
	return self:_enrichTransactionRows(trimmed), total
end

local MB_INSIGHTS_CATEGORIES = {
	{ key = "food_drinks", label = "Food & Drinks" },
	{ key = "clothing", label = "Clothing" },
	{ key = "cyberware", label = "Cyberware" },
	{ key = "weapons_ammo", label = "Weapons & Ammo" },
	{ key = "medical", label = "Medical Supplies" },
	{ key = "software", label = "Quickhacks & Software" },
	{ key = "crafting", label = "Crafting & Upgrades" },
	{ key = "vehicles", label = "Vehicles" },
	{ key = "insurance", label = "Insurance" },
	{ key = "real_estate", label = "Real Estate" },
	{ key = "transportation", label = "Public Transportation" },
	{ key = "loans", label = "Loan Payments" },
	{ key = "services", label = "Account Services" },
	{ key = "entertainment", label = "Entertainment" },
	{ key = "other", label = "Other Purchases" },
	{ key = "uncategorized", label = "Uncategorized Spending" },
}

function BANK:_normalizeInsightsPeriodDays(days)
	days = math.floor(tonumber(days) or 30)
	if days == 7 or days == 30 or days == 90 then return days end
	return 30
end

function BANK:_getInsightsCurrentDay(rows)
	local day = -1
	pcall(function()
		day = math.floor(tonumber(Game.GetTimeSystem():GetGameTime():Days()) or -1)
	end)
	if day >= 0 then return day end

	for _, row in ipairs(rows or {}) do
		local rowDay = math.floor(tonumber(row.day) or -1)
		if rowDay > day then day = rowDay end
	end
	return math.max(day, 0)
end

function BANK:_classifySpendingInsightsRow(row)
	row = row or {}
	local txType = math.floor(tonumber(row.type) or 0)
	local partnerCode = math.floor(tonumber(row.tax) or 0)
	local subjectCode = math.max(0, math.min(math.floor(tonumber(row.subject) or 0), 15))

	if txType == 4 or txType == 27 or ((txType == 21 or txType == 22) and subjectCode > 0) then
		if subjectCode == MB_SPEND_SUBJECT.food_drinks then return "food_drinks", "Food & Drinks", "Food and drink purchase" end
		if subjectCode == MB_SPEND_SUBJECT.clothing then return "clothing", "Clothing", "Clothing purchase" end
		if subjectCode == MB_SPEND_SUBJECT.cyberware then return "cyberware", "Cyberware", "Cyberware purchase" end
		if subjectCode == MB_SPEND_SUBJECT.weapons_ammo then return "weapons_ammo", "Weapons & Ammo", "Weapons and ammunition purchase" end
		if subjectCode == MB_SPEND_SUBJECT.medical then return "medical", "Medical Supplies", "Medical supply purchase" end
		if subjectCode == MB_SPEND_SUBJECT.software then return "software", "Quickhacks & Software", "Software purchase" end
		if subjectCode == MB_SPEND_SUBJECT.crafting then return "crafting", "Crafting & Upgrades", "Crafting and upgrade purchase" end
		if subjectCode == MB_SPEND_SUBJECT.vehicles then return "vehicles", "Vehicles", "Vehicle purchase or payment" end
		if subjectCode == MB_SPEND_SUBJECT.insurance then return "insurance", "Insurance", "Insurance premium or deductible" end
		if subjectCode == MB_SPEND_SUBJECT.real_estate then return "real_estate", "Real Estate", "Real estate purchase" end
		if subjectCode == MB_SPEND_SUBJECT.transportation then return "transportation", "Public Transportation", "Transportation fare" end
		if subjectCode == MB_SPEND_SUBJECT.loans then return "loans", "Loan Payments", "Loan payment" end
		if subjectCode == MB_SPEND_SUBJECT.services then return "services", "Account Services", "Account service" end
		if subjectCode == MB_SPEND_SUBJECT.entertainment then return "entertainment", "Entertainment", "Entertainment purchase" end
		if subjectCode == MB_SPEND_SUBJECT.other then return "other", "Other Purchases", "Other identified purchase" end
		return "uncategorized", "Uncategorized Spending", "Earlier unclassified purchase"
	end
	if txType == 7 then
		return "loans", "Loan Payments", "Manual loan payment"
	end
	if txType == 8 then
		return "loans", "Loan Payments", "Scheduled loan payment"
	end
	if txType == 12 then
		return "services", "Account Services", "Checking account fee"
	end
	if txType == 14 then
		return "services", "Account Services", "Private client services"
	end
	if (txType == 21 or txType == 22) and partnerCode == 201 then
		return "vehicles", "Vehicles", "Earlier Vanguard payment"
	end

	return nil
end

function BANK:_buildInsightsDelta(currentAmount, previousAmount)
	currentAmount = math.max(math.floor(tonumber(currentAmount) or 0), 0)
	previousAmount = math.max(math.floor(tonumber(previousAmount) or 0), 0)
	if previousAmount <= 0 then
		if currentAmount > 0 then
			return { direction = "new", percent = nil, label = "NEW" }
		end
		return { direction = "flat", percent = 0, label = "--" }
	end

	local raw = ((currentAmount - previousAmount) / previousAmount) * 100.0
	local rounded = math.floor(math.abs(raw) + 0.5)
	if raw > 0.0001 then
		return { direction = "up", percent = rounded, label = tostring(rounded) .. "%" }
	elseif raw < -0.0001 then
		return { direction = "down", percent = rounded, label = tostring(rounded) .. "%" }
	end
	return { direction = "flat", percent = 0, label = "--" }
end

function BANK:getAnalyticsRevision(skipReconcile)
	if skipReconcile ~= true then
		self:processVanguardAnalyticsEvents(true)
		self:updateWalletSpendMonitor(false)
		self:_flushPendingWalletSpend(false)
	end

	local system = self:getUnifiedSystem()
	local primarySequence = 0
	local primaryCount = 0
	if system then
		pcall(function() primarySequence = math.floor(tonumber(system:GetTransactionSequence()) or 0) end)
		pcall(function() primaryCount = math.floor(tonumber(system:GetTransactionLogCount()) or 0) end)
	end
	local currentDay = 0
	pcall(function() currentDay = math.floor(tonumber(Game.GetTimeSystem():GetGameTime():Days()) or 0) end)
	return table.concat({
		tostring(primarySequence),
		tostring(primaryCount),
		tostring(self:_getQuestFactInt(MB_WALLET_TX_SEQ)),
		tostring(self:_getQuestFactInt(MB_WALLET_TX_COUNT)),
		tostring(self:_getQuestFactInt(MB_ANALYTICS_VANGUARD_FINANCE_CURSOR)),
		tostring(self:_getQuestFactInt(MB_ANALYTICS_CLASSIFICATION_REVISION)),
		tostring(currentDay),
	}, "|")
end

function BANK:getSpendingInsights(periodDays, periodOffset)
	periodDays = self:_normalizeInsightsPeriodDays(periodDays)
	periodOffset = math.max(math.floor(tonumber(periodOffset) or 0), 0)

	local rows = self:_collectTransactionRows(false)
	local currentDay = self:_getInsightsCurrentDay(rows)
	local oldestSpendDay = currentDay
	local hasRetainedSpend = false
	local oldestPrimaryDay = -1
	local oldestFallbackDay = -1

	for _, row in ipairs(rows) do
		local categoryKey = self:_classifySpendingInsightsRow(row)
		local rowDay = math.floor(tonumber(row.day) or -1)
		if rowDay >= 0 and row.source == "bank_ledger" and (oldestPrimaryDay < 0 or rowDay < oldestPrimaryDay) then
			oldestPrimaryDay = rowDay
		elseif rowDay >= 0 and row.source == "wallet_fallback" and (oldestFallbackDay < 0 or rowDay < oldestFallbackDay) then
			oldestFallbackDay = rowDay
		end
		if categoryKey ~= nil and rowDay >= 0 then
			if not hasRetainedSpend or rowDay < oldestSpendDay then oldestSpendDay = rowDay end
			hasRetainedSpend = true
		end
	end

	local historySpan = hasRetainedSpend and math.max(currentDay - oldestSpendDay + 1, 1) or 1
	local maxPeriods = math.max(1, math.ceil(historySpan / periodDays))
	maxPeriods = math.min(maxPeriods, 6)
	periodOffset = math.min(periodOffset, maxPeriods - 1)

	local endDay = currentDay - (periodOffset * periodDays)
	local startDay = endDay - periodDays + 1
	local previousEndDay = startDay - 1
	local previousStartDay = previousEndDay - periodDays + 1
	local primaryLedgerCount = 0
	local primaryLedgerSequence = 0
	local primaryHistoryTrimmed = false
	local primaryHistoryBoundaryDay = -1
	local primarySystem = self:getUnifiedSystem()
	if primarySystem then
		pcall(function() primaryLedgerCount = math.floor(tonumber(primarySystem:GetTransactionLogCount()) or 0) end)
		pcall(function() primaryLedgerSequence = math.floor(tonumber(primarySystem:GetTransactionSequence()) or primaryLedgerCount) end)
		pcall(function() primaryHistoryTrimmed = primarySystem:HasTransactionHistoryTrimmed() == true end)
		pcall(function() primaryHistoryBoundaryDay = math.floor(tonumber(primarySystem:GetTransactionHistoryBoundaryDay()) or -1) end)
	end
	if primaryLedgerSequence > primaryLedgerCount then primaryHistoryTrimmed = true end
	if primaryHistoryTrimmed and primaryHistoryBoundaryDay < 0 then primaryHistoryBoundaryDay = oldestPrimaryDay end

	self:_ensureWalletTxRetentionState()
	local fallbackLedgerCount = math.max(self:_getQuestFactInt(MB_WALLET_TX_COUNT), 0)
	local fallbackHistoryTrimmed = self:_getQuestFactInt(MB_WALLET_TX_HISTORY_TRIMMED) > 0 or fallbackLedgerCount > MB_WALLET_TX_MAX
	local historyLimited = primaryHistoryTrimmed or fallbackHistoryTrimmed

	local function sourceWindowPartial(trimmed, boundaryDay, windowStartDay)
		if trimmed ~= true then return false end
		if boundaryDay == nil or boundaryDay < 0 then return true end
		return windowStartDay <= boundaryDay
	end

	local currentPartial = sourceWindowPartial(primaryHistoryTrimmed, primaryHistoryBoundaryDay, startDay)
		or sourceWindowPartial(fallbackHistoryTrimmed, oldestFallbackDay, startDay)
	local comparisonPartial = previousStartDay < 0
		or sourceWindowPartial(primaryHistoryTrimmed, primaryHistoryBoundaryDay, previousStartDay)
		or sourceWindowPartial(fallbackHistoryTrimmed, oldestFallbackDay, previousStartDay)

	local function makeBucket()
		local bucket = { total = 0, count = 0, categories = {}, largest = nil }
		for index, def in ipairs(MB_INSIGHTS_CATEGORIES) do
			bucket.categories[def.key] = {
				key = def.key,
				label = def.label,
				amount = 0,
				count = 0,
				order = index,
			}
		end
		return bucket
	end

	local current = makeBucket()
	local previous = makeBucket()

	local function addRow(bucket, row, categoryKey, categoryLabel, spendLabel)
		local amount = math.max(math.floor(tonumber(row.amount) or 0), 0)
		if amount <= 0 then return end
		local category = bucket.categories[categoryKey] or bucket.categories.other
		category.amount = category.amount + amount
		category.count = category.count + 1
		bucket.total = bucket.total + amount
		bucket.count = bucket.count + 1

		if bucket.largest == nil or amount > bucket.largest.amount then
			bucket.largest = {
				amount = amount,
				label = tostring(spendLabel or categoryLabel or "Posted spending"),
				category = tostring(categoryLabel or category.label),
				day = math.floor(tonumber(row.day) or -1),
				hour = math.floor(tonumber(row.hour) or 0),
				minute = math.floor(tonumber(row.minute) or 0),
				timestamp = tostring(row.timestamp or self:_makeWalletTxTimestamp(row.day, row.hour, row.minute)),
			}
		end
	end

	for _, row in ipairs(rows) do
		local categoryKey, categoryLabel, spendLabel = self:_classifySpendingInsightsRow(row)
		local rowDay = math.floor(tonumber(row.day) or -1)
		if categoryKey ~= nil and rowDay >= startDay and rowDay <= endDay then
			addRow(current, row, categoryKey, categoryLabel, spendLabel)
		elseif categoryKey ~= nil and rowDay >= previousStartDay and rowDay <= previousEndDay then
			addRow(previous, row, categoryKey, categoryLabel, spendLabel)
		end
	end

	local categories = {}
	for _, def in ipairs(MB_INSIGHTS_CATEGORIES) do
		local category = current.categories[def.key]
		local previousCategory = previous.categories[def.key]
		category.previousAmount = previousCategory.amount
		category.delta = self:_buildInsightsDelta(category.amount, previousCategory.amount)
		category.delta.partial = comparisonPartial
		category.percent = 0
		table.insert(categories, category)
	end
	table.sort(categories, function(a, b)
		if a.amount == b.amount then return a.order < b.order end
		return a.amount > b.amount
	end)

	if current.total > 0 then
		local percentTotal = 0
		for _, category in ipairs(categories) do
			category.percent = math.floor(((category.amount / current.total) * 100.0) + 0.5)
			percentTotal = percentTotal + category.percent
		end
		if #categories > 0 then
			categories[1].percent = math.max(0, math.min(100, categories[1].percent + (100 - percentTotal)))
		end
	end

	local topCategory = nil
	if #categories > 0 and categories[1].amount > 0 then topCategory = categories[1] end
	local frequentCategory = nil
	for _, category in ipairs(categories) do
		if category.count > 0 and (frequentCategory == nil
			or category.count > frequentCategory.count
			or (category.count == frequentCategory.count and category.amount > frequentCategory.amount)) then
			frequentCategory = category
		end
	end

	local totalDelta = self:_buildInsightsDelta(current.total, previous.total)
	totalDelta.partial = comparisonPartial

	local calendarContext = Calendar.getContext()
	local rangeStartLabel = Calendar.formatEngineDay(math.max(startDay, 0), calendarContext, true)
	local rangeEndLabel = Calendar.formatEngineDay(math.max(endDay, 0), calendarContext, true)

	return {
		revision = self:getAnalyticsRevision(true),
		periodDays = periodDays,
		periodOffset = periodOffset,
		maxPeriods = maxPeriods,
		currentDay = currentDay,
		startDay = startDay,
		endDay = endDay,
		previousStartDay = previousStartDay,
		previousEndDay = previousEndDay,
		rangeLabel = rangeStartLabel .. " - " .. rangeEndLabel,
		total = current.total,
		previousTotal = previous.total,
		totalDelta = totalDelta,
		transactionCount = current.count,
		categories = categories,
		topCategory = topCategory,
		largest = current.largest,
		frequentCategory = frequentCategory,
		oldestSpendDay = oldestSpendDay,
		partial = currentPartial,
		comparisonPartial = comparisonPartial,
		historyLimited = historyLimited,
		primaryLedgerCount = primaryLedgerCount,
		primaryLedgerSequence = primaryLedgerSequence,
		primaryHistoryTrimmed = primaryHistoryTrimmed,
		primaryHistoryBoundaryDay = primaryHistoryBoundaryDay,
		fallbackLedgerCount = fallbackLedgerCount,
		fallbackHistoryTrimmed = fallbackHistoryTrimmed,
		hasRetainedSpend = hasRetainedSpend,
		retainedRowCount = #rows,
	}
end

function BANK:disputeTransaction(index)
	local result = self:submitDisputeClaim(index, 1)
	if type(result) == "table" then
		return result.ok == true
	end
	return result == true
end

function BANK:updateTimers(dt)
	if self:isJohnnySuppressed() then return end
	self.currentTime = os.clock()
	if self.atmKeypad and self.atmKeypad.isActive and self.atmKeypad:isActive() and self.atmKeypad.update then
		pcall(function() self.atmKeypad:update(dt) end)
	end

	if self.currentTime < (tonumber(self.nextPassiveTimerUpdateTime or 0) or 0) then
		return
	end
	self.nextPassiveTimerUpdateTime = self.currentTime + 0.50

	local vanguardSystem = self:maintainVanguardAutoFinanceLease()

	if self.currentTime >= (tonumber(self.nextVanguardAutoServiceTime or 0) or 0) then
		self.nextVanguardAutoServiceTime = self.currentTime + 2.00
		if vanguardSystem then
			pcall(function()
				local accountHolder = Game.GetPlayer()
				if accountHolder then
					local serviceCalled = false
					pcall(function()
						vanguardSystem:MarmurBankServiceFinanceContracts(accountHolder)
						serviceCalled = true
					end)
					if not serviceCalled then
						pcall(function() vanguardSystem:UpdateFinanceContracts(accountHolder) end)
					end
				end
			end)
		end
	end

	self:processVanguardAnalyticsEvents()
	self:updateWalletSpendMonitor()

	if self.currentTime >= (tonumber(self.nextDisputeTimerCheckTime or 0) or 0) then
		self.nextDisputeTimerCheckTime = self.currentTime + 2.00
		self:processDisputeTimers()
	end

	if self.currentTime >= (tonumber(self.nextLoanReviewSyncTime or 0) or 0) then
		self.nextLoanReviewSyncTime = self.currentTime + 2.00
		self:_syncLoanApplicationReview()
	end

	if self.currentTime >= (tonumber(self.nextVanguardAutoPendingNoticeCheckTime or 0) or 0) then
		self.nextVanguardAutoPendingNoticeCheckTime = self.currentTime + 4.00
		self:processVanguardAutoLoanApprovalNotice()
		self:ensureVanguardAutoLoanApprovalNotices()
	end

	if self.currentTime >= (tonumber(self.nextVanguardSettlementCheckTime or 0) or 0) then
		self.nextVanguardSettlementCheckTime = self.currentTime + 1.00
		self:processVanguardInsuranceSettlementNotice()
	end

	if self.currentTime >= (self.nextPhoneContactCheckTime or 0) then
		self.nextPhoneContactCheckTime = self.currentTime + 10
		self:ensureAccountPhoneThread()
	end

	if self.currentTime <= self.nextCheckTime then
		return
	end

	self.nextCheckTime = self.currentTime + 10
	self:processPendingOpeningIncentive()
	self:processAutoDepositSchedule()
	self:processCashbackPayoutSchedule()

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()

	if system and gameInstance then
		local before = self.lastUnifiedBalance or 0
		local relationshipBalance = before
		pcall(function() relationshipBalance = math.floor(tonumber(system:GetBalance()) or relationshipBalance) end)
		pcall(function() self:syncLoyaltyProgram(relationshipBalance, false) end)
		local ok = pcall(function()
			system:SyncInterest(gameInstance)
		end)
		if ok then
			local loanBefore = tonumber(self.lastLoanBalance or 0) or 0
			local loanWalletBefore = self:getWalletBalance()
			pcall(function()
				system:SyncLoanPayments(gameInstance)
			end)

			local loanAfter = loanBefore
			pcall(function()
				loanAfter = tonumber(system:GetLoanBalanceDue()) or 0
			end)
			local loanWalletAfter = self:getWalletBalance()

			if loanBefore > 0 and loanAfter < loanBefore then
				local paid = loanBefore - loanAfter
				local cashbackEarned = self:_awardCashbackForLoanPayment(paid, loanWalletBefore, loanWalletAfter, system, gameInstance)
				self:_markLastTransactionCashbackEarned(cashbackEarned)
				if loanAfter <= 0 then
					Util.simpleScreenMessage("Marmur Bank loan paid in full: " .. Util.formatNumber(paid) .. " E$")
				else
					Util.simpleScreenMessage("Marmur Bank loan auto-debit: " .. Util.formatNumber(paid) .. " E$")
				end
			end

			self.lastLoanBalance = loanAfter

			local after = self:getUnifiedBalance()
			if before > 0 and after > before then
				Util.simpleScreenMessage(
					Lang.getText("scr_Bank_Interest") .. Util.formatNumber(after - before) .. " E$"
				)
			end
			self.lastUnifiedBalance = after
			pcall(function() self:syncLoyaltyProgram(after, false) end)
			self:_syncFallbackLoanPayments()
			return
		end
	end

	self:_syncFallbackLoanPayments()

	local today = Game.GetTimeSystem():GetGameTime():Days()
	local prevday = self:_getQuestFactInt(MB_PREVINC)

	if prevday + self.termOfIncome <= today then
		if Game.GetTimeSystem():GetGameTime():Hours() < 13 then
			return
		end

		self:_setQuestFactInt(MB_PREVINC, today)
		local deposit = self:_getQuestFactInt(MB_DEPOSIT)

		if deposit and deposit > 0 then
			local interest = math.ceil(deposit * self:getManagedInterestPercent(deposit) / 100)

			deposit = deposit + interest
			self:setFactBalance(deposit)
			Game.GetAudioSystem():Play("ui_jingle_money")
			Util.simpleScreenMessage(
				Lang.getText("scr_Bank_Interest") .. Util.formatNumber(interest) .. " E$"
			)
		end
	end

	self.lastUnifiedBalance = self:getUnifiedBalance()
	pcall(function() self:syncLoyaltyProgram(self.lastUnifiedBalance, false) end)
end

function BANK:_cacheLocationPositions()
	self._atmPosCache = {}
	for i, val in ipairs(POSData_ATMLocation or {}) do
		local ok, posdata = pcall(function() return Util.getPosDataFromText(val) end)
		if ok and posdata ~= nil and posdata.pos ~= nil then
			table.insert(self._atmPosCache, {
				index = i,
				pos = posdata.pos,
				isDropPoint = POSData_CustomATMLocation == nil or val ~= POSData_CustomATMLocation,
			})
		end
	end

	self._branchPosCache = {}
	for i, val in ipairs(POSData_NCBankLocation or {}) do
		local ok, posdata = pcall(function() return Util.getPosDataFromText(val) end)
		if ok and posdata ~= nil and posdata.pos ~= nil then
			table.insert(self._branchPosCache, { index = i, pos = posdata.pos })
		end
	end

	self._branchFrontPosCache = nil
	local frontText = POSData_BranchDoorLocation or POSData_GreeterLocation
	if frontText ~= nil then
		local ok, posdata = pcall(function() return Util.getPosDataFromText(frontText) end)
		if ok and posdata ~= nil and posdata.pos ~= nil then
			self._branchFrontPosCache = posdata.pos
		end
	end

	self._branchInteriorSidePosCache = nil
	local interiorText = POSData_GreeterLocation
	if interiorText == nil and POSData_NCBankLocation ~= nil then
		interiorText = POSData_NCBankLocation[1]
	end
	if interiorText ~= nil then
		local ok, posdata = pcall(function() return Util.getPosDataFromText(interiorText) end)
		if ok and posdata ~= nil and posdata.pos ~= nil then
			self._branchInteriorSidePosCache = posdata.pos
		end
	end

	self._locationPosCacheReady = true
end

function BANK:_ensureLocationPosCache()
	if self._locationPosCacheReady ~= true then
		self:_cacheLocationPositions()
	end
end

function BANK:isAtmMapPosition(mapPosition, matchDistance)
	if mapPosition == nil then
		return false
	end

	self:_ensureLocationPosCache()
	local distance = tonumber(matchDistance) or 5.0
	if distance <= 0 then
		return false
	end

	local distanceSquared = distance * distance
	for _, entry in ipairs(self._atmPosCache or {}) do
		if entry.isDropPoint == true and self:_distanceSquared(mapPosition, entry.pos) <= distanceSquared then
			return true
		end
	end

	return false
end

function BANK:_isPlayerOnBranchInteriorSide(playerPos)
	self:_ensureLocationPosCache()

	local doorPos = self._branchFrontPosCache
	local interiorPos = self._branchInteriorSidePosCache
	if playerPos == nil or doorPos == nil or interiorPos == nil then
		return false
	end

	local ix = (tonumber(interiorPos.x) or 0) - (tonumber(doorPos.x) or 0)
	local iy = (tonumber(interiorPos.y) or 0) - (tonumber(doorPos.y) or 0)
	local px = (tonumber(playerPos.x) or 0) - (tonumber(doorPos.x) or 0)
	local py = (tonumber(playerPos.y) or 0) - (tonumber(doorPos.y) or 0)

	return ((px * ix) + (py * iy)) > 0.35
end

function BANK:shouldSuppressClosedBranchDoorVanilla()
	if self:isJohnnySuppressed() then
		return false
	end

	if self:isLocationOpen("branch") then
		return false
	end

	local playerPos = self:_getPlayerWorldPosition()
	if playerPos == nil then
		return false
	end

	self:_ensureLocationPosCache()
	if self._branchFrontPosCache == nil then
		return false
	end

	return self:_distanceSquared(playerPos, self._branchFrontPosCache) < 36
end

function BANK:_isClosedBranchNpcGuardArmed()
	local now = os.clock()
	if now > 0 and now < (tonumber(self.branchNpcGuardArmedUntil or 0) or 0) then
		return self.branchNpcGuardArmedCached == true
	end

	local armed = false
	if not self:isJohnnySuppressed() and not self:isLocationOpen("branch") then
		self:_ensureLocationPosCache()
		if self._branchFrontPosCache ~= nil then
			local playerPos = self:_getPlayerWorldPosition()
			if playerPos ~= nil then
				armed = self:_distanceSquared(playerPos, self._branchFrontPosCache) < 22500
			end
		end
	end

	self.branchNpcGuardArmedCached = armed == true
	if now > 0 then
		self.branchNpcGuardArmedUntil = now + (armed and 0.15 or 0.50)
	end
	return self.branchNpcGuardArmedCached == true
end

function BANK:_isPositionInsideClosedBranchNpcVolume(pos)
	if pos == nil then
		return false
	end

	local x = tonumber(pos.x) or 0
	local y = tonumber(pos.y) or 0
	local z = tonumber(pos.z) or 0

	if z < 18.40 or z > 21.60 then return false end
	if x < -1497.50 or x > -1480.75 then return false end
	if y < 1189.00 or y > 1205.50 then return false end

	return true
end

function BANK:_tryDeleteClosedBranchInteriorNPC(entity)
	if entity == nil then
		return false
	end

	if not self:_isClosedBranchNpcGuardArmed() then
		return false
	end

	local pos = nil
	pcall(function() pos = entity:GetWorldPosition() end)
	if not self:_isPositionInsideClosedBranchNpcVolume(pos) then
		return false
	end

	local entityID = nil
	pcall(function() entityID = entity:GetEntityID() end)

	local removed = false
	if entityID ~= nil then
		local ok = pcall(function()
			Game.GetDynamicEntitySystem():DeleteEntity(entityID)
		end)
		removed = ok == true
	end

	if not removed then
		pcall(function() entity:Dispose() end)
	end

	return true
end

function BANK:_registerClosedBranchNpcGuard()
	if _G ~= nil and _G.MARMUR_CLOSED_BRANCH_NPC_GUARD_REGISTERED == true then
		_G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER = self
		self._branchNpcGuardRegistered = true
		return
	end

	local function handleAttachedNpc(entity)
		local bank = self
		if _G ~= nil and _G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER ~= nil then
			bank = _G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER
		end

		if bank == nil or bank._tryDeleteClosedBranchInteriorNPC == nil then
			return
		end

		local deleted = false
		pcall(function() deleted = bank:_tryDeleteClosedBranchInteriorNPC(entity) == true end)
		if deleted then
			return
		end

		local retry = false
		pcall(function() retry = bank:_isClosedBranchNpcGuardArmed() == true end)
		if retry then
			pcall(function()
				Cron.After(0.20, function()
					local owner = bank
					if _G ~= nil and _G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER ~= nil then
						owner = _G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER
					end
					if owner ~= nil and owner._tryDeleteClosedBranchInteriorNPC ~= nil then
						pcall(function() owner:_tryDeleteClosedBranchInteriorNPC(entity) end)
					end
				end)
			end)
		end
	end

	local ok = pcall(function()
		ObserveAfter('NPCPuppet', 'OnGameAttached', function(entity)
			handleAttachedNpc(entity)
		end)
	end)

	if not ok then
		ok = pcall(function()
			Observe('NPCPuppet', 'OnGameAttached', function(entity)
				handleAttachedNpc(entity)
			end)
		end)
	end

	if ok then
		self._branchNpcGuardRegistered = true
		if _G ~= nil then
			_G.MARMUR_CLOSED_BRANCH_NPC_GUARD_REGISTERED = true
			_G.MARMUR_CLOSED_BRANCH_NPC_GUARD_OWNER = self
		end
	end
end

function BANK:_getPlayerWorldPosition()
	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then return nil end
	local playerPos = nil
	pcall(function() playerPos = player:GetWorldPosition() end)
	return playerPos
end

function BANK:getAtmActivationDistance()
	local configured = tonumber(self.atmDistance) or 1.65
	local minRange = 1.50
	local maxRange = 2.5
	if configured < minRange then return minRange end
	if configured > maxRange then return maxRange end
	return configured
end


function BANK:getNearbyAtmIndex(ignoreDismissed)
	if self:isJohnnySuppressed() then
		return 0
	end

	local playerPos = self:_getPlayerWorldPosition()
	if playerPos == nil then
		return 0
	end

	self:_ensureLocationPosCache()
	local activationDistance = self:getAtmActivationDistance()
	local activationDistanceSq = activationDistance * activationDistance
	for _, entry in ipairs(self._atmPosCache or {}) do
		local i = entry.index or 0

		if self:_distanceSquared(playerPos, entry.pos) < activationDistanceSq then
			if ignoreDismissed ~= true and self.atmKeypadDismissedIndex == i then
				return 0
			end
			return i
		end
	end

	return 0
end

function BANK:canUseAtmKeypad()
	if self:isJohnnySuppressed() then
		return false
	end

	if not self:isAccountOpen() then
		if self.atmKeypad and self.atmKeypad.isActive and self.atmKeypad:isActive() then
			pcall(function() self.atmKeypad:hide() end)
		end
		return false
	end

	local player = nil
	pcall(function() player = Game.GetPlayer() end)
	if player == nil then
		return false
	end

	local blocked = false

	pcall(function()
		if Game.GetMountedVehicle(player) then
			blocked = true
		end
	end)

	pcall(function()
		if LiftDevice and LiftDevice.IsPlayerInsideElevator and LiftDevice.IsPlayerInsideElevator() then
			blocked = true
		end
	end)

	pcall(function()
		local state = player:GetCurrentCombatState()
		if state ~= nil and state.value == "InCombat" then
			blocked = true
		end
	end)

	return blocked ~= true
end

function BANK:openAtmKeypadFromKeybind()
	if self:isJohnnySuppressed() then
		return false
	end

	if not self.atmKeypad then
		return false
	end

	if not self:canUseAtmKeypad() then
		return false
	end

	local index = self:getNearbyAtmIndex(true)
	if index <= 0 then
		if self.lastAccessType == "atm" then
			self.lastAccessType = nil
			self.lastAccessIndex = 0
		end
		return false
	end

	self.lastAccessType = "atm"
	self.lastAccessIndex = index
	self.atmKeypadDismissedIndex = 0

	if self.hub then
		self.hub = nil
		pcall(function() self.interactionUI.hideHub() end)
	end

	pcall(function()
		if self.interactionUI and self.interactionUI.suppressVanilla then
			self.interactionUI.suppressVanilla(false)
		end
	end)

	if self.SPAWN and self.SPAWN.showSubTitle then
		pcall(function() self.SPAWN:showSubTitle("", self.atmFontSize, "Center") end)
	end

	self.hubId = "atm"

	local opened = false
	if self.atmKeypad.isActive and self.atmKeypad:isActive() then
		local ok, result = pcall(function() return self.atmKeypad:refresh() end)
		opened = ok and result == true
	else
		local ok, result = pcall(function() return self.atmKeypad:show(self) end)
		opened = ok and result == true
	end

	if not opened then
		pcall(function() self.atmKeypad:hide() end)
		self.hubId = nil
		return false
	end

	return true
end

function BANK:isVanillaDropboxDialogActive()
	if not self.interactionUI then
		return false
	end

	if self.interactionUI.isVanillaDialogActive then
		local ok, active = pcall(function()
			return self.interactionUI.isVanillaDialogActive(1.50)
		end)

		if ok and active == true then
			return true
		end
	end

	local controller = self.interactionUI.baseControler
	if not controller then return false end

	local ok, open = pcall(function()
		return controller.AreDialogsOpen == true
	end)

	return ok and open == true
end

function BANK:distanceListener()
	if self:isJohnnySuppressed() then
		self.lastAccessType = nil
		self.lastAccessIndex = 0
		return 0
	end

	local playerPos = self:_getPlayerWorldPosition()
	if playerPos == nil then
		self.lastAccessType = nil
		self.lastAccessIndex = 0
		return 0
	end

	self:_ensureLocationPosCache()
	local activationDistance = self:getAtmActivationDistance()
	local activationDistanceSq = activationDistance * activationDistance

	for _, entry in ipairs(self._atmPosCache or {}) do
		local i = entry.index or 0

		if self:_distanceSquared(playerPos, entry.pos) < activationDistanceSq then
			if not self:isAccountOpen() then
				self.lastAccessType = nil
				self.lastAccessIndex = 0
				if self.atmKeypad and self.atmKeypad.isActive and self.atmKeypad:isActive() then
					pcall(function() self.atmKeypad:hide() end)
				end
				return 0
			end
			self.lastAccessType = "atm"
			self.lastAccessIndex = i
			if self.atmKeypadDismissedIndex == i then
				return 0
			end
			return i
		end
	end

	self.atmKeypadDismissedIndex = 0

	if not self:isLocationOpen("branch") and self._branchFrontPosCache ~= nil then
		if self:_distanceSquared(playerPos, self._branchFrontPosCache) < 36 then
			self.lastAccessType = "branchfront"
			self.lastAccessIndex = 1
			return 1
		end
	end

	for _, entry in ipairs(self._branchPosCache or {}) do
		local i = entry.index or 0

		if self:_distanceSquared(playerPos, entry.pos) < 4 then
			self.lastAccessType = "branch"
			self.lastAccessIndex = i
			return i
		end
	end

	self.lastAccessType = nil
	self.lastAccessIndex = 0
	return 0
end

function BANK:dismissAtmKeypad()
	if self.lastAccessType == "atm" and (tonumber(self.lastAccessIndex) or 0) > 0 then
		self.atmKeypadDismissedIndex = self.lastAccessIndex
	end
end

function BANK:setSettingValues(tranAmount, atmDistance, atmFontSize, interestRate, termOfIncome)
	self.tranAmount = tranAmount
	self.atmDistance = atmDistance
	self.atmFontSize = atmFontSize
	self.interestRate = self:getManagedInterestPercent(self:getUnifiedBalance())
	self.termOfIncome = termOfIncome
end

function BANK:getText(locationType)
	locationType = locationType or self.lastAccessType or "atm"

	if (locationType == "branch" or locationType == "branchfront") and not self:isLocationOpen("branch") then
		return self:getClosedBranchOverlayText(locationType)
	end

	if locationType ~= "atm" and not self:isLocationOpen(locationType) then
		return Lang.getText("pin_bank_estate_text") .. ":   " .. self:getStatusText(locationType) .. " • " .. self:getHoursText(locationType)
	end

	local deposit = self:getUnifiedBalance()
	return Lang.getText("dlg_Bank_Balance") .. Util.formatNumber(deposit) .. " E$"
end

function BANK:getMenu(locationType)
	locationType = locationType or self.lastAccessType or "atm"

	local entry = {}
	local choice = {}
	local money = self:getWalletBalance()
	local deposit = self:getUnifiedBalance()
	local isOpen = self:isLocationOpen(locationType)

	self.depTbl = {}
	self.drwTbl = {}

	if locationType == "branchfront" then
		return choice
	elseif locationType ~= "atm" then
		if locationType == "branch" and not isOpen then
			return choice
		end

		table.insert(choice, {
			text = Lang.getText("hub_Bank_Hours"),
			menu = "hours",
			type = gameinteractionsChoiceType.QuestImportant
		})

		if not isOpen then
			return choice
		end
	end

	if self.tranAmount == 1 then
		self.depTbl["dep10"] = 1000
		self.depTbl["dep100"] = 10000
		self.drwTbl["drw10"] = 1000
		self.drwTbl["drw100"] = 10000
	elseif self.tranAmount == 2 then
		self.depTbl["dep10"] = 10000
		self.depTbl["dep100"] = 100000
		self.drwTbl["drw10"] = 10000
		self.drwTbl["drw100"] = 100000
	else
		self.depTbl["dep10"] = math.ceil(money / 10)
		self.depTbl["dep100"] = money
		self.drwTbl["drw10"] = math.ceil(deposit / 10)
		self.drwTbl["drw100"] = deposit
	end

	if self.depTbl["dep10"] < self.depTbl["dep100"] then
		entry = {
			text = Lang.getText("hub_Bank_Deposit") .. "   " .. Util.formatNumber(self.depTbl["dep10"]) .. " E$",
			menu = "dep10",
			type = gameinteractionsChoiceType.QuestImportant
		}

		if money == 0 or money < self.depTbl["dep10"] or not isOpen then
			entry.type = gameinteractionsChoiceType.Inactive
		end

		table.insert(choice, entry)
	end

	entry = {
		text = Lang.getText("hub_Bank_Deposit") .. "   " .. Util.formatNumber(self.depTbl["dep100"]) .. " E$",
		menu = "dep100",
		type = gameinteractionsChoiceType.QuestImportant
	}

	if money == 0 or money < self.depTbl["dep100"] or not isOpen then
		entry.type = gameinteractionsChoiceType.Inactive
	end

	table.insert(choice, entry)

	if self.drwTbl["drw10"] < self.drwTbl["drw100"] then
		entry = {
			text = Lang.getText("hub_Bank_Withdraw") .. "   " .. Util.formatNumber(self.drwTbl["drw10"]) .. " E$",
			menu = "drw10",
			type = gameinteractionsChoiceType.QuestImportant
		}

		if deposit == 0 or deposit < self.drwTbl["drw10"] or not isOpen then
			entry.type = gameinteractionsChoiceType.Inactive
		end

		table.insert(choice, entry)
	end

	entry = {
		text = Lang.getText("hub_Bank_Withdraw") .. "   " .. Util.formatNumber(self.drwTbl["drw100"]) .. " E$",
		menu = "drw100",
		type = gameinteractionsChoiceType.QuestImportant
	}

	if deposit == 0 or deposit < self.drwTbl["drw100"] or not isOpen then
		entry.type = gameinteractionsChoiceType.Inactive
	end

	table.insert(choice, entry)

	return choice
end

function BANK:doMenu(menu, i, locationType)
	if self:isJohnnySuppressed() then return false end
	locationType = locationType or self.lastAccessType or "atm"
	local amount = nil
	local ok = false

	if menu == "hours" then
		self:showHoursInfo(locationType)
		return false
	end

	if locationType ~= "atm" and not self:isLocationOpen(locationType) then
		Game.GetAudioSystem():Play('ui_menu_onpress')
		Util.simpleScreenMessage(Lang.getText("scr_Bank_Closed"))
		return false
	end

	if menu == "dep10" or menu == "dep100" then
		amount = self.depTbl[menu]
		ok = self:depositMoney(amount)
	elseif menu == "drw10" or menu == "drw100" then
		amount = self.drwTbl[menu]
		ok = self:withdrawMoney(amount)
	end

	if ok then
		Game.GetAudioSystem():Play('ui_jingle_quest_update')
		self.prevC = i
		self.lastUnifiedBalance = self:getUnifiedBalance()
	else
		Game.GetAudioSystem():Play('ui_menu_onpress')
	end
end

function BANK:showHub()
	if self:isJohnnySuppressed() then
		self:hideHub()
		return
	end
	local locationType = self.lastAccessType or "atm"
	local hubId = locationType
	local closedBranchInfoOnly = (locationType == "branch" or locationType == "branchfront") and not self:isLocationOpen("branch")
	local suppressClosedBranchVanilla = closedBranchInfoOnly and self:shouldSuppressClosedBranchDoorVanilla()

	if locationType == "atm" and not self:isAccountOpen() then
		self:hideHub()
		return
	end

	if locationType == "atm" and self.atmKeypad then
		if self.hubId and self.hubId == hubId and self.atmKeypad:isActive() then
			local ok, refreshed = pcall(function() return self.atmKeypad:refresh() end)
			if not ok or refreshed ~= true then
				pcall(function() self.atmKeypad:hide() end)
				self.hubId = nil
			end
			return
		end

		if self.hub then
			self.interactionUI.hideHub()
			self.hub = nil
		end

		self.SPAWN:showSubTitle("", self.atmFontSize, "Center")
		self.hubId = hubId

		local ok, opened = pcall(function() return self.atmKeypad:show(self) end)
		if not ok or opened ~= true then
			pcall(function() self.atmKeypad:hide() end)
			self.hubId = nil
		end
		return
	end

	if self.hubId and self.hubId == hubId and not closedBranchInfoOnly then
		return
	end

	if self.hub or (self.atmKeypad and self.atmKeypad:isActive()) then
		self:hideHub()
	end

	if self.interactionUI and self.interactionUI.suppressVanilla then
		self.interactionUI.suppressVanilla(suppressClosedBranchVanilla, suppressClosedBranchVanilla)
	end

	self.SPAWN:showSubTitle(
		self:getText(locationType),
		self.atmFontSize,
		"Center"
	)

	local choices = {}
	local message = self:getMenu(locationType)

	for i, val in ipairs(message) do
		local choiceAction = self.interactionUI.createChoice(
			val.text,
			TweakDBInterface.GetChoiceCaptionIconPartRecord(
				"ChoiceCaptionParts.OpenVendorIcon"
			),
			val.type
		)

		table.insert(choices, choiceAction)

		self.interactionUI.callbacks[i] = function()
			if val.type == gameinteractionsChoiceType.QuestImportant then
				self.SPAWN:showSubTitle("", self.atmFontSize, "Center")
				self:hideHub()
				self:doMenu(val.menu, i, locationType)
			end
		end
	end

	if #choices > 0 then
		local hubTitle = "ATM"
		if locationType == "banker" then
			hubTitle = Lang.getText("hub_Bank_Target")
		elseif locationType == "branch" or locationType == "branchfront" then
			hubTitle = Lang.getText("pin_bank_estate_text")
		end

		self.hub = self.interactionUI.createHub(hubTitle, choices)
		self.hubId = hubId

		if self.prevC > #choices then
			self.prevC = #choices
		end

		self.interactionUI.setupHub(self.hub, self.prevC)
		self.interactionUI.showHub()
		Game.GetStatusEffectSystem():ApplyStatusEffect(
			GetPlayer():GetEntityID(),
			"GameplayRestriction.NoHealing",
			GetPlayer():GetRecordID(),
			GetPlayer():GetEntityID()
		)
	end
end

function BANK:hideHub()
	local hadHub = self.hub ~= nil or self.hubId ~= nil

	if self.atmKeypad then
		pcall(function() self.atmKeypad:hide() end)
	end

	if self.interactionUI and self.interactionUI.suppressVanilla then
		self.interactionUI.suppressVanilla(false)
	end

	if self.hub then
		self.hub = nil
		self.interactionUI.hideHub()
	end

	self.hubId = nil

	if hadHub then
		Game.GetStatusEffectSystem():RemoveStatusEffect(
			GetPlayer():GetEntityID(),
			"GameplayRestriction.NoHealing"
		)
	end
end


local MB_LOAN_LATE_FEE_RATE_BP = 500
local MB_LOAN_LATE_FEE_MIN = 100
local MB_LOAN_LATE_FEE_MAX = 5000
local MB_LOAN_DEFAULT_MISSED_PAYMENTS = 3
local MB_LOAN_DEFAULT_COOLDOWN_DAYS = 30
local MB_LOAN_DEFAULT_COOLDOWN_UNTIL = "marmur_loan_default_cooldown_until_day"
local MB_LOAN_DEFAULT_LAST_PROCESSED_MISSED = "marmur_loan_default_last_processed_missed"
local MB_LOAN_DEFAULT_LAST_RECOVERY = "marmur_loan_default_last_recovery"
local MB_LOAN_DEFAULT_LAST_VEHICLES = "marmur_loan_default_last_vehicles"
local MB_LOAN_DEFAULT_LAST_REMAINING = "marmur_loan_default_last_remaining"
local MB_LOAN_DEFAULT_LAST_SURPLUS = "marmur_loan_default_last_surplus"
local MB_LOAN_DEFAULT_LAST_NOTICE_DAY = "marmur_loan_default_last_notice_day"

function BANK:_calculateManualLoanLateFee(pastDuePrincipal)
	local base = math.max(math.floor(tonumber(pastDuePrincipal) or 0), 0)
	if base <= 0 then return 0 end
	local fee = math.ceil((base * MB_LOAN_LATE_FEE_RATE_BP) / 10000)
	if fee < MB_LOAN_LATE_FEE_MIN then fee = MB_LOAN_LATE_FEE_MIN end
	if fee > MB_LOAN_LATE_FEE_MAX then fee = MB_LOAN_LATE_FEE_MAX end
	return fee
end

function BANK:getPersonalLoanPastDueSummary(loanData)
	local loan = loanData or self:getLoanData() or {}
	local balance = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
	local active = loan.active == true and balance > 0
	local missed = math.max(math.floor(tonumber(loan.missedPayments) or 0), 0)
	local installment = math.max(math.floor(tonumber(loan.installment) or 0), 0)
	if installment <= 0 then installment = balance end
	if installment > balance then installment = balance end
	local pastDuePrincipal = 0
	if active and missed > 0 then
		pastDuePrincipal = math.min(balance, installment * missed)
	end
	local lateFee = 0
	if pastDuePrincipal > 0 then
		lateFee = self:_calculateManualLoanLateFee(pastDuePrincipal)
	end
	return {
		active = active,
		pastDue = active and missed > 0,
		missedPayments = missed,
		defaultThreshold = MB_LOAN_DEFAULT_MISSED_PAYMENTS,
		defaultEligible = active and missed >= MB_LOAN_DEFAULT_MISSED_PAYMENTS,
		balanceDue = balance,
		installment = installment,
		requiredPayment = pastDuePrincipal,
		lateFee = lateFee,
		totalToCure = pastDuePrincipal + lateFee,
		nextDueDay = math.floor(tonumber(loan.nextDueDay) or 0),
		paymentIntervalDays = math.max(math.floor(tonumber(loan.paymentIntervalDays) or 30), 1),
	}
end

function BANK:isPersonalLoanPastDue(loanData)
	local summary = self:getPersonalLoanPastDueSummary(loanData)
	return summary.pastDue == true
end

function BANK:shouldForceLoanLockout()
	local summary = self:getPersonalLoanPastDueSummary(nil)
	return summary.pastDue == true
end

function BANK:getManualLoanPaymentPreview(amount, payoffMode)
	local loan = self:getLoanData() or {}
	local summary = self:getPersonalLoanPastDueSummary(loan)
	local balance = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
	local earlyPayoff = math.max(math.floor(tonumber(loan.earlyPayoffAmount) or 0), 0)
	if earlyPayoff <= 0 then earlyPayoff = self:getLoanEarlyPayoffAmount() end
	if earlyPayoff <= 0 then earlyPayoff = balance end
	local paymentAmount = math.max(math.floor(tonumber(amount) or 0), 0)
	local payoff = payoffMode == true
	if payoff then
		paymentAmount = math.min(earlyPayoff, balance)
	else
		if paymentAmount > balance then paymentAmount = balance end
	end
	local lateFee = summary.pastDue and summary.lateFee or 0
	local totalDebit = paymentAmount + lateFee
	local balanceAfter = payoff and 0 or math.max(balance - paymentAmount, 0)
	local clearsPastDue = balanceAfter <= 0 or (summary.pastDue and paymentAmount >= (summary.requiredPayment or 0))
	return {
		active = loan.active == true and balance > 0,
		payoff = payoff,
		pastDue = summary.pastDue == true,
		missedPayments = summary.missedPayments or 0,
		defaultEligible = summary.defaultEligible == true,
		defaultThreshold = summary.defaultThreshold or MB_LOAN_DEFAULT_MISSED_PAYMENTS,
		balanceBefore = balance,
		balanceAfter = balanceAfter,
		paymentAmount = paymentAmount,
		lateFee = lateFee,
		totalDebit = totalDebit,
		requiredPayment = summary.requiredPayment or 0,
		clearsPastDue = clearsPastDue == true,
		earlyPayoffAmount = earlyPayoff,
		wallet = self:getWalletBalance(),
	}
end

function BANK:_clearPersonalLoanMissedPayments()
	self:_setQuestFactInt(MB_LOAN_FACT_MISSED, 0)
	local system = self:getUnifiedSystem()
	if system then
		pcall(function() system:ClearLoanMissedPayments() end)
	end
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_PROCESSED_MISSED, 0)
end

function BANK:postReviewedManualLoanPayment(amount, payoffMode)
	local preview = self:getManualLoanPaymentPreview(amount, payoffMode == true)
	if preview.active ~= true or preview.paymentAmount <= 0 then
		return false, "No active loan is available for repayment.", preview
	end
	if preview.pastDue and preview.payoff ~= true and preview.paymentAmount < preview.requiredPayment then
		return false, "Past-due payments must include the missed scheduled amount before access is restored.", preview
	end
	if preview.totalDebit > preview.wallet then
		return false, "Checking balance is too low for this payment and late fee.", preview
	end

	local feeCharged = false
	if preview.lateFee > 0 then
		feeCharged = self:_removeWalletMoney(preview.lateFee)
		if not feeCharged then
			return false, "Late fee could not be collected.", preview
		end
	end

	local ok = false
	if preview.payoff == true then
		pcall(function() ok = self:payLoanInFull() == true end)
	else
		pcall(function() ok = self:payLoan(preview.paymentAmount) == true end)
	end

	if ok ~= true then
		if feeCharged then
			pcall(function() self:_addWalletMoney(preview.lateFee) end)
		end
		return false, "Repayment could not be completed.", preview
	end

	local loanAfter = self:getLoanData() or {}
	preview.balanceAfter = math.max(math.floor(tonumber(loanAfter.balanceDue) or preview.balanceAfter or 0), 0)
	preview.walletAfter = self:getWalletBalance()
	if preview.clearsPastDue == true or preview.balanceAfter <= 0 then
		self:_clearPersonalLoanMissedPayments()
	end
	if preview.lateFee > 0 then
		pcall(function() Util.simpleScreenMessage("Marmur Bank late fee collected: " .. Util.formatNumber(preview.lateFee) .. " E$") end)
	end
	return true, "Payment posted.", preview
end

function BANK:isLoanDefaultCooldownActive()
	local untilDay = self:_getQuestFactInt(MB_LOAN_DEFAULT_COOLDOWN_UNTIL)
	if untilDay <= 0 then return false end
	return self:_getCurrentGameDay() < untilDay
end

function BANK:getLoanDefaultCooldownDaysLeft()
	local untilDay = self:_getQuestFactInt(MB_LOAN_DEFAULT_COOLDOWN_UNTIL)
	local left = untilDay - self:_getCurrentGameDay()
	if left < 0 then left = 0 end
	return left
end

function BANK:_normalizeVehicleTitle(value)
	local text = tostring(value or ""):lower()
	text = text:gsub("%s+", " ")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	return text
end

function BANK:_getVanguardFinancedTitleSet()
	local set = {}
	local loans = self:getAutoLoans() or {}
	for _, loan in ipairs(loans) do
		local title = self:_normalizeVehicleTitle(loan.title)
		if title ~= "" and (tonumber(loan.balanceDue) or 0) > 0 then
			set[title] = true
		end
	end
	return set
end

function BANK:_tryVanguardMethod(system, methodNames, ...)
	if not system then return nil, false end
	local args = { ... }
	for _, name in ipairs(methodNames or {}) do
		local ok, result = pcall(function()
			local fn = system[name]
			if type(fn) == "function" then
				local unpacker = table.unpack or unpack
				return fn(system, unpacker(args))
			end
			return nil
		end)
		if ok and result ~= nil then
			return result, true
		end
	end
	return nil, false
end

function BANK:_tryVanguardNumber(system, methodNames, index, defaultValue)
	local result, ok = self:_tryVanguardMethod(system, methodNames, index)
	if ok then
		local value = math.floor(tonumber(result) or 0)
		return value
	end
	return math.floor(tonumber(defaultValue) or 0)
end

function BANK:_tryVanguardString(system, methodNames, index, defaultValue)
	local result, ok = self:_tryVanguardMethod(system, methodNames, index)
	if ok and result ~= nil then
		return tostring(result)
	end
	return tostring(defaultValue or "")
end

function BANK:_tryVanguardBool(system, methodNames, index, defaultValue)
	local result, ok = self:_tryVanguardMethod(system, methodNames, index)
	if ok then
		return result == true
	end
	return defaultValue == true
end

function BANK:getVanguardOwnedVehicleLiquidationCandidates()
	local system = self:getVanguardAutoSystem()
	local candidates = {}
	if not system then return candidates end

	local count = self:_tryVanguardNumber(system, {
		"GetOwnedVehicleCount",
		"GetGarageVehicleCount",
		"GetPlayerOwnedVehicleCount",
		"GetPurchasedVehicleCount",
		"GetUnlockedOwnedVehicleCount",
		"MarmurGetOwnedVehicleCount",
	}, nil, 0)
	if count <= 0 then return candidates end

	local financedTitles = self:_getVanguardFinancedTitleSet()
	for i = 1, count do
		local title = self:_tryVanguardString(system, {
			"GetOwnedVehicleNameAt",
			"GetGarageVehicleNameAt",
			"GetPlayerOwnedVehicleNameAt",
			"GetPurchasedVehicleNameAt",
			"MarmurGetOwnedVehicleNameAt",
		}, i, "Vanguard Vehicle #" .. tostring(i))
		local normalizedTitle = self:_normalizeVehicleTitle(title)
		local value = self:_tryVanguardNumber(system, {
			"GetOwnedVehicleLiquidationValueAt",
			"GetOwnedVehicleValueAt",
			"GetGarageVehicleValueAt",
			"GetPurchasedVehiclePriceAt",
			"GetOwnedVehiclePriceAt",
			"MarmurGetOwnedVehicleLiquidationValueAt",
		}, i, 0)
		local financed = financedTitles[normalizedTitle] == true
		if self:_tryVanguardBool(system, { "IsOwnedVehicleFinancedAt", "IsGarageVehicleFinancedAt", "IsVehicleUnderLienAt", "MarmurIsOwnedVehicleFinancedAt" }, i, false) then
			financed = true
		end
		local owned = true
		if self:_tryVanguardBool(system, { "IsOwnedVehicleAt", "IsGarageVehicleOwnedAt", "IsVehicleFullyOwnedAt", "MarmurIsOwnedVehicleEligibleAt" }, i, true) == false then
			owned = false
		end
		if owned and not financed and value > 0 then
			table.insert(candidates, { index = i, title = title, value = value })
		end
	end
	return candidates
end

function BANK:_selectVanguardLiquidationCandidates(candidates, targetBalance)
	local target = math.max(math.floor(tonumber(targetBalance) or 0), 0)
	local list = {}
	for _, c in ipairs(candidates or {}) do
		if (tonumber(c.value) or 0) > 0 then table.insert(list, c) end
	end
	if target <= 0 or #list <= 0 then return {} end

	table.sort(list, function(a, b) return (tonumber(a.value) or 0) < (tonumber(b.value) or 0) end)
	local single = nil
	for _, c in ipairs(list) do
		if (tonumber(c.value) or 0) >= target then
			single = c
			break
		end
	end
	if single then return { single } end

	table.sort(list, function(a, b) return (tonumber(a.value) or 0) > (tonumber(b.value) or 0) end)
	local picked = {}
	local total = 0
	for _, c in ipairs(list) do
		table.insert(picked, c)
		total = total + (tonumber(c.value) or 0)
		if total >= target then break end
	end
	return picked
end

function BANK:_liquidateVanguardOwnedVehicle(candidate)
	local system = self:getVanguardAutoSystem()
	if not system or not candidate then return false, 0 end
	local methods = {
		"MarmurBankLiquidateOwnedVehicleAt",
		"MarmurLiquidateOwnedVehicleAt",
		"LiquidateOwnedVehicleAt",
		"MarmurBankPermanentLossOwnedVehicleAt",
		"PermanentLossOwnedVehicleAt",
		"PermanentlyRemoveOwnedVehicleAt",
		"RemoveOwnedVehicleAt",
		"DeleteOwnedVehicleAt",
		"SellOwnedVehicleAt",
	}
	local result, ok = self:_tryVanguardMethod(system, methods, candidate.index)
	if ok then
		if type(result) == "number" then return result > 0, math.floor(result) end
		if result == true then return true, math.floor(tonumber(candidate.value) or 0) end
	end
	return false, 0
end

function BANK:_applyExternalLoanRecovery(amount)
	local recovery = math.max(math.floor(tonumber(amount) or 0), 0)
	if recovery <= 0 then return 0 end
	local loan = self:getLoanData() or {}
	local before = math.max(math.floor(tonumber(loan.balanceDue) or 0), 0)
	if before <= 0 then return 0 end
	local applied = math.min(recovery, before)
	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	local okSystem = false
	if system and gameInstance then
		pcall(function() okSystem = system:ApplyExternalLoanRecovery(gameInstance, applied) == true end)
	end
	if okSystem then
		local afterLoan = self:getLoanData() or {}
		self.lastLoanBalance = math.max(math.floor(tonumber(afterLoan.balanceDue) or 0), 0)
		return applied
	end
	if self:_fallbackLoanIsActive() then
		local balance = self:_getQuestFactInt(MB_LOAN_FACT_BALANCE)
		local credit = math.min(applied, balance)
		self:_setQuestFactInt(MB_LOAN_FACT_BALANCE, math.max(balance - credit, 0))
		self:_setQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID, self:_getQuestFactInt(MB_LOAN_FACT_TOTAL_REPAID) + credit)
		self:_setQuestFactInt(MB_LOAN_FACT_LAST_PAYMENT, self:_getCurrentGameDay())
		self:_closeFallbackLoanIfPaid()
		self.lastLoanBalance = math.max(balance - credit, 0)
		return credit
	end
	return 0
end

function BANK:processPersonalLoanDefaultLiquidation(force)
	local loan = self:getLoanData() or {}
	local summary = self:getPersonalLoanPastDueSummary(loan)
	if summary.defaultEligible ~= true then
		return false, "not_default", { summary = summary }
	end
	local missed = math.max(math.floor(tonumber(summary.missedPayments) or 0), 0)
	local already = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_PROCESSED_MISSED)
	if force ~= true and already >= missed and summary.balanceDue <= 0 then
		return false, "already_processed", { summary = summary }
	end

	local target = math.max(math.floor(tonumber(summary.balanceDue) or 0), 0)
	local candidates = self:getVanguardOwnedVehicleLiquidationCandidates()
	local picked = self:_selectVanguardLiquidationCandidates(candidates, target)
	if #picked <= 0 then
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_RECOVERY, 0)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_VEHICLES, 0)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_REMAINING, target)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_NOTICE_DAY, self:_getCurrentGameDay())
		return false, "no_eligible_vehicles", { summary = summary, candidateCount = #candidates }
	end

	local recovered = 0
	local vehicleCount = 0
	for _, candidate in ipairs(picked) do
		local ok, value = self:_liquidateVanguardOwnedVehicle(candidate)
		if ok == true then
			vehicleCount = vehicleCount + 1
			if value <= 0 then value = math.floor(tonumber(candidate.value) or 0) end
			recovered = recovered + math.max(value, 0)
		end
		if recovered >= target then break end
	end

	if recovered <= 0 or vehicleCount <= 0 then
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_RECOVERY, 0)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_VEHICLES, 0)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_REMAINING, target)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_NOTICE_DAY, self:_getCurrentGameDay())
		return false, "liquidation_api_unavailable", { summary = summary, candidateCount = #candidates }
	end

	local applied = self:_applyExternalLoanRecovery(recovered)
	local surplus = math.max(recovered - applied, 0)
	if surplus > 0 then
		pcall(function() self:_addWalletMoney(surplus) end)
	end
	local afterLoan = self:getLoanData() or {}
	local remaining = math.max(math.floor(tonumber(afterLoan.balanceDue) or 0), 0)
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_RECOVERY, applied)
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_VEHICLES, vehicleCount)
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_REMAINING, remaining)
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_SURPLUS, surplus)
	self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_NOTICE_DAY, self:_getCurrentGameDay())
	if applied > 0 then
		local code = self:_generateLoanConfirmationCode("LQD")
		self:_setLastLoanConfirmationCode(code)
		self:_storeLoanSmsThreadEntry("LQD", applied, self:getWalletBalance(), self:getWalletBalance(), code)
	end
	if remaining <= 0 then
		self:_clearPersonalLoanMissedPayments()
		self:_setQuestFactInt(MB_LOAN_DEFAULT_LAST_PROCESSED_MISSED, missed)
		self:_setQuestFactInt(MB_LOAN_DEFAULT_COOLDOWN_UNTIL, self:_getCurrentGameDay() + MB_LOAN_DEFAULT_COOLDOWN_DAYS)
	end
	pcall(function()
		Util.simpleScreenMessage("Marmur default recovery posted: " .. tostring(vehicleCount) .. " Vanguard vehicle(s), " .. Util.formatNumber(applied) .. " E$")
	end)
	return true, "recovered", { summary = summary, recovered = applied, vehicleCount = vehicleCount, remaining = remaining, surplus = surplus }
end

function BANK:getPersonalLoanDefaultRecoveryStatus()
	return {
		lastRecovery = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_RECOVERY),
		lastVehicles = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_VEHICLES),
		lastRemaining = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_REMAINING),
		lastSurplus = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_SURPLUS),
		lastNoticeDay = self:_getQuestFactInt(MB_LOAN_DEFAULT_LAST_NOTICE_DAY),
		cooldownDaysLeft = self:getLoanDefaultCooldownDaysLeft(),
	}
end

local _marmurOriginalSubmitManualLoanApplication = BANK.submitManualLoanApplication
function BANK:submitManualLoanApplication(amount, frequency, termMonths)
	if self:isLoanDefaultCooldownActive() then
		pcall(function() Util.simpleScreenMessage("Marmur Bank new loans disabled after default recovery.") end)
		return false
	end
	return _marmurOriginalSubmitManualLoanApplication(self, amount, frequency, termMonths)
end

local _marmurOriginalSyncLoanPayments = BANK.syncLoanPayments
function BANK:syncLoanPayments()
	_marmurOriginalSyncLoanPayments(self)
	pcall(function() self:processPersonalLoanDefaultLiquidation(false) end)
end

local _marmurOriginalUpdateTimers = BANK.updateTimers
function BANK:updateTimers(dt)
	_marmurOriginalUpdateTimers(self, dt)
	if self:isJohnnySuppressed() then return end
	self.currentTime = self.currentTime or os.clock()
	if self.currentTime >= (self.nextLoanDefaultLiquidationCheckTime or 0) then
		self.nextLoanDefaultLiquidationCheckTime = self.currentTime + 15
		pcall(function() self:processPersonalLoanDefaultLiquidation(false) end)
	end
end

function BANK:isExternalPartnerAccountLinked()
	return self:isAccountOpen() == true
end

function BANK:getExternalPartnerCheckingBalance()
	return math.floor(tonumber(self:getWalletBalance()) or 0)
end

function BANK:getExternalPartnerSavingsBalance()
	return math.floor(tonumber(self:getUnifiedBalance()) or 0)
end

function BANK:_postExternalPartnerRail(methodName, amount, partnerCode, confirmationLeft, confirmationRight)
	amount = math.floor(tonumber(amount) or 0)
	partnerCode = math.floor(tonumber(partnerCode) or 0)
	confirmationLeft = math.floor(tonumber(confirmationLeft) or 0)
	confirmationRight = math.floor(tonumber(confirmationRight) or 0)
	if amount <= 0 then return false, "Transfer amount must be greater than zero." end
	if self:isAccountOpen() ~= true then return false, "Marmur Bank account is not open." end

	local system = self:getUnifiedSystem()
	local gameInstance = self:getGameInstance()
	if not system or not gameInstance then return false, "Marmur Bank system is unavailable." end

	local beforeSavings = math.floor(tonumber(self:getUnifiedBalance()) or 0)
	local ok, result = false, false

	local function callDotWithoutGame()
		local f = system and system[methodName] or nil
		if not f then return nil end
		return f(amount, partnerCode, confirmationLeft, confirmationRight)
	end

	local function callColonWithoutGame()
		if methodName == "TransferCheckingToExternalPartner" then
			return system:TransferCheckingToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "TransferSavingsToExternalPartner" then
			return system:TransferSavingsToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "ReceiveCheckingFromExternalPartner" then
			return system:ReceiveCheckingFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "ReceiveSavingsFromExternalPartner" then
			return system:ReceiveSavingsFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
		end
		return nil
	end

	local function callDotWithGame()
		local f = system and system[methodName] or nil
		if not f then return nil end
		return f(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight)
	end

	local function callColonWithGame()
		if methodName == "TransferCheckingToExternalPartner" then
			return system:TransferCheckingToExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "TransferSavingsToExternalPartner" then
			return system:TransferSavingsToExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "ReceiveCheckingFromExternalPartner" then
			return system:ReceiveCheckingFromExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight)
		elseif methodName == "ReceiveSavingsFromExternalPartner" then
			return system:ReceiveSavingsFromExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight)
		end
		return nil
	end

	if methodName ~= "TransferCheckingToExternalPartner"
		and methodName ~= "TransferSavingsToExternalPartner"
		and methodName ~= "ReceiveCheckingFromExternalPartner"
		and methodName ~= "ReceiveSavingsFromExternalPartner" then
		return false, "Marmur partner rail method missing: " .. tostring(methodName)
	end

	local attempts = { callDotWithoutGame, callColonWithoutGame, callDotWithGame, callColonWithGame }
	for _, fn in ipairs(attempts) do
		ok, result = pcall(fn)
		if ok and result ~= nil then
			break
		end
	end

	if not ok or result ~= true then
		local detail = tostring(result or "")
		if detail ~= "" and detail ~= "false" then
			return false, "Marmur partner rail error: " .. detail
		end
		return false, "Marmur Bank rejected the partner transfer."
	end

	local afterSavings = beforeSavings
	pcall(function()
		if system.GetBalance then afterSavings = math.floor(tonumber(system:GetBalance()) or beforeSavings) end
	end)
	if methodName == "TransferSavingsToExternalPartner" or methodName == "ReceiveSavingsFromExternalPartner" then
		self:forceUnifiedBalance(afterSavings, system, gameInstance)
	end
	if methodName == "TransferCheckingToExternalPartner" then
		self:_clearExternalWalletDebitSuppression()
	end
	self:_syncWalletSnapshot()
	return true, "posted"
end

function BANK:transferCheckingToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return self:_postExternalPartnerRail("TransferCheckingToExternalPartner", amount, partnerCode, confirmationLeft, confirmationRight)
end

function BANK:transferSavingsToExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return self:_postExternalPartnerRail("TransferSavingsToExternalPartner", amount, partnerCode, confirmationLeft, confirmationRight)
end

function BANK:receiveCheckingFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return self:_postExternalPartnerRail("ReceiveCheckingFromExternalPartner", amount, partnerCode, confirmationLeft, confirmationRight)
end

function BANK:receiveSavingsFromExternalPartner(amount, partnerCode, confirmationLeft, confirmationRight)
	return self:_postExternalPartnerRail("ReceiveSavingsFromExternalPartner", amount, partnerCode, confirmationLeft, confirmationRight)
end

local function marmurVanguardBridgePayload(selfOrPayload, maybePayload)
	local payload = maybePayload
	if payload == nil and selfOrPayload ~= BANK then
		payload = selfOrPayload
	end
	if type(payload) ~= "table" then
		payload = {}
	end
	return payload
end

function BANK:_findActiveUnpaidVanguardLoan(payload)
	payload = payload or {}
	local requestedIndex = math.floor(tonumber(payload.contractIndex or payload.financeIndex or payload.index or 0) or 0)
	local requestedName = self:_normalizeVehicleTitle(payload.vehicleName or payload.title or "")
	local loans = self:getAutoLoans(true) or {}

	if requestedIndex > 0 then
		for _, loan in ipairs(loans) do
			local loanIndex = math.floor(tonumber(loan.index) or 0)
			local balance = math.floor(tonumber(loan.balanceDue) or 0)
			if loanIndex == requestedIndex and balance > 0 and loan.repossessed ~= true then
				if requestedName == "" or self:_normalizeVehicleTitle(loan.title) == requestedName then
					return loan
				end
			end
		end
	end

	if requestedName ~= "" then
		for _, loan in ipairs(loans) do
			local balance = math.floor(tonumber(loan.balanceDue) or 0)
			if self:_normalizeVehicleTitle(loan.title) == requestedName and balance > 0 and loan.repossessed ~= true then
				return loan
			end
		end
	end

	return nil
end

function BANK.GetVanguardAutoLoanBillingMode(selfOrPayload, maybePayload)
	local payload = marmurVanguardBridgePayload(selfOrPayload, maybePayload)
	local loan = BANK:_findActiveUnpaidVanguardLoan(payload)

	if loan then
		return math.floor(tonumber(loan.paymentFrequency) or 3)
	end

	return nil
end

function BANK.GetVanguardLoanBillingMode(selfOrPayload, maybePayload)
	return BANK.GetVanguardAutoLoanBillingMode(selfOrPayload, maybePayload)
end

function BANK.PostVanguardCoverageReminder(selfOrPayload, maybePayload)
	local payload = marmurVanguardBridgePayload(selfOrPayload, maybePayload)
	local loan = BANK:_findActiveUnpaidVanguardLoan(payload)
	if not loan then
		return false
	end
	local deductible = math.floor(tonumber(payload.requiredDeductible) or 0)
	local daysRemaining = math.floor(tonumber(payload.daysRemaining) or 0)
	local noticeNumber = math.floor(tonumber(payload.noticeNumber) or 0)
	local contractIndex = math.floor(tonumber(loan.index or payload.contractIndex or payload.financeIndex or payload.index or 0) or 0)
	local noticeCode = (contractIndex * 10) + noticeNumber
	local code = BANK:_generateLoanConfirmationCode("VCN")

	BANK:_storeLoanSmsThreadEntry("VCN", deductible, daysRemaining, noticeCode, code)
	BANK:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank: insure " .. tostring(loan.title or "the financed vehicle"))
	end)
	return true
end

function BANK.PostVanguardCoverageDefault(selfOrPayload, maybePayload)
	local payload = marmurVanguardBridgePayload(selfOrPayload, maybePayload)
	local requestedContractIndex = math.floor(tonumber(payload.contractIndex or payload.financeIndex or payload.index or 0) or 0)
	local system = BANK:getVanguardAutoSystem()
	local loan = BANK:_findActiveUnpaidVanguardLoan(payload)
	if not loan then
		if system and requestedContractIndex > 0 then
			local result, ok = BANK:_tryVanguardMethod(system, {
				"IsActiveFinanceContractRepossessedAt",
			}, requestedContractIndex)
			if ok and result == true then return true end
		end
		return false
	end
	local deductible = math.floor(tonumber(payload.requiredDeductible) or 0)
	local cureDays = math.floor(tonumber(payload.cureDays) or 0)
	local contractIndex = math.floor(tonumber(loan.index or payload.contractIndex or payload.financeIndex or payload.index or 0) or 0)
	local code = BANK:_generateLoanConfirmationCode("VCD")
	local repossessed = false

	if system and contractIndex > 0 then
		local result, ok = BANK:_tryVanguardMethod(system, {
			"MarmurBankRepossessFinancedVehicleAt",
			"MarmurRepossessFinancedVehicleAt",
			"RepossessFinancedVehicleAt",
		}, contractIndex)
		repossessed = ok and result == true
	end

	if not repossessed then
		return false
	end

	BANK:_invalidateAutoLoansCache()

	BANK:_storeLoanSmsThreadEntry("VCD", deductible, cureDays, contractIndex, code)
	BANK:ensureAccountPhoneThread()
	pcall(function()
		Util.simpleScreenMessage("Marmur Bank repossessed " .. tostring(loan.title or "the financed vehicle"))
	end)
	return true
end

pcall(function()
	_G.MARMUR_BANK_PARTNER_API = BANK
	_G.MarmurBank = BANK
end)

return BANK
