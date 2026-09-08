// -----------------------------------------------------------------------------
// NCFMainSystem
// -----------------------------------------------------------------------------

module NightCityFinance.Main

import NightCityFinance.Logging.*
import NightCityFinance.Settings.*
import NightCityFinance.Core.*
import NightCityFinance.Utils.*
import NightCityFinance.Services.NCFShowMessage
import NightCityFinance.Services.NCFNotificationGate
import NightCityFinance.Phone.{NCFBankContactHash, NCFLoanSharkContactHash, NCFAmenitiesContactHash, NCFPhoneSystem}
import PhoneExtension.System.*

// Bootstrap
@wrapMethod(RadialWheelController)
protected cb func OnLateInit(evt: ref<LateInit>) -> Bool {
    let val: Bool = wrappedMethod(evt);
    NCFMainSystem.Get().OnRadialWheelLateInitDone();
    return val;
}

@wrapMethod(DeathMenuGameController)
protected cb func OnInitialize() -> Bool {
    let val: Bool = wrappedMethod();
    NCFMainSystem.Get().OnPlayerDeath();
    return val;
}

@wrapMethod(FullscreenVendorGameController)
protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.OnVendorOpened();
    }
    return wrappedMethod(userData);
}

@wrapMethod(FullscreenVendorGameController)
protected cb func OnInitialize() -> Bool {
    let result: Bool = wrappedMethod();
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.SetVendorOpen(true);
    }
    return result;
}

@wrapMethod(FullscreenVendorGameController)
protected cb func OnUninitialize() -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.OnVendorClosed();
        sys.SetVendorOpen(false);
    }
    return wrappedMethod();
}

@wrapMethod(FullscreenVendorGameController)
private final func UpdatePlayerMoney() -> Void {
    wrappedMethod();
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if !IsDefined(sys) { return; }
    let suffix: String = sys.BuildVendorMoneySuffix();
    if StrLen(suffix) == 0 { return; }

    let widget = inkTextRef.Get(this.m_playerMoney) as inkText;
    if !IsDefined(widget) { return; }

    let injected: Int32 = sys.GetInjectedCreditAmount();
    let inflated: Int32 = NCF_GetPlayerMoney();
    let real: Int32 = inflated - injected;
    if real < 0 { real = 0; }

    let baseText: String = "€$ " + ToString(real);
    let marker: String = "  |  NCF ";
    widget.SetText(baseText + marker + suffix);
}

// =============================================================================
// Ripperdoc vendor hooks (v1.0.7)
//
// RipperDocGameController is a separate controller from FullscreenVendorGameController
// — it hosts the cyberware shop UI (Viktor, Cassius, etc.) and any mod-added
// items injected into ripperdoc vendors (Dark Future, Immersive Cyberware).
// Without these wraps, NCF's credit injection and sales-tax pipeline never
// fired at ripperdocs, so:
//   1. Credit was unavailable (player saw their real, un-inflated balance)
//   2. Sales tax was not applied to cyberware purchases
//   3. The user reported "loan does not apply to the total amount on ripper vendors"
//
// We mirror the same four hook surfaces the FullscreenVendor pipeline uses:
//   OnSetUserData → inject credit before UI reads balance
//   OnInitialize  → set vendor-open flag (poll-driven sales tax engages)
//   OnUninitialize → settle credit, clear vendor-open flag
//
// We deliberately do NOT wrap an UpdatePlayerMoney equivalent on
// RipperDocGameController — the controller does not expose that method
// (no `m_playerMoney` widget reference in its RTTI). The inline "real |
// NCF Credit: +X" display only shows at FullscreenVendor screens.
// At ripperdocs, the player sees the boosted balance in the top-right HUD
// eddies counter only. Items are still buyable using injected credit;
// tax is still deducted via the poll-driven HandlePurchase path.
// =============================================================================

@wrapMethod(RipperDocGameController)
protected cb func OnSetUserData(userData: ref<IScriptable>) -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.OnVendorOpened();
    }
    return wrappedMethod(userData);
}

@wrapMethod(RipperDocGameController)
protected cb func OnInitialize() -> Bool {
    let result: Bool = wrappedMethod();
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.SetVendorOpen(true);
    }
    return result;
}

@wrapMethod(RipperDocGameController)
protected cb func OnUninitialize() -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) {
        sys.OnVendorClosed();
        sys.SetVendorOpen(false);
    }
    return wrappedMethod();
}

// Events
public class NCFPlayerDeathEvent extends CallbackSystemEvent {
    static func Create() -> ref<NCFPlayerDeathEvent> { return new NCFPlayerDeathEvent(); }
}

public class NCFFinancialReportEvent extends CallbackSystemEvent {
    let reportData: array<Int32>;
    public final func GetData() -> array<Int32> { return this.reportData; }
    static func Create(data: array<Int32>) -> ref<NCFFinancialReportEvent> {
        let self: ref<NCFFinancialReportEvent> = new NCFFinancialReportEvent();
        self.reportData = data;
        return self;
    }
}

public class NCFDeductionEvent extends CallbackSystemEvent {
    let grossAmount: Int32;
    let fixerCut: Int32;
    let incomeTax: Int32;
    let garnishment: Int32;
    let netAmount: Int32;
    static func Create(gross: Int32, fixer: Int32, tax: Int32, garn: Int32, net: Int32) -> ref<NCFDeductionEvent> {
        let self: ref<NCFDeductionEvent> = new NCFDeductionEvent();
        self.grossAmount = gross;
        self.fixerCut = fixer;
        self.incomeTax = tax;
        self.garnishment = garn;
        self.netAmount = net;
        return self;
    }
}

public class NCFSalesTaxEvent extends CallbackSystemEvent {
    let taxAmount: Int32;
    let purchaseAmount: Int32;
    static func Create(tax: Int32, purchase: Int32) -> ref<NCFSalesTaxEvent> {
        let self: ref<NCFSalesTaxEvent> = new NCFSalesTaxEvent();
        self.taxAmount = tax;
        self.purchaseAmount = purchase;
        return self;
    }
}

public class NCFDebtInterestEvent extends CallbackSystemEvent {
    let interestAmount: Int32;
    let totalDebt: Int32;
    static func Create(interest: Int32, total: Int32) -> ref<NCFDebtInterestEvent> {
        let self: ref<NCFDebtInterestEvent> = new NCFDebtInterestEvent();
        self.interestAmount = interest;
        self.totalDebt = total;
        return self;
    }
}

public class NCFDebtCreatedEvent extends CallbackSystemEvent {
    let newDebtAmount: Int32;
    let totalDebt: Int32;
    static func Create(added: Int32, total: Int32) -> ref<NCFDebtCreatedEvent> {
        let self: ref<NCFDebtCreatedEvent> = new NCFDebtCreatedEvent();
        self.newDebtAmount = added;
        self.totalDebt = total;
        return self;
    }
}

public class NCFMissedPaymentEvent extends CallbackSystemEvent {
    let source: String;
    let dueAmount: Int32;
    let paidAmount: Int32;
    let unpaidAmount: Int32;
    let penaltyApplied: Int32;
    let newOutstanding: Int32;
    static func Create(source: String, due: Int32, paid: Int32, unpaid: Int32, penalty: Int32, outstanding: Int32) -> ref<NCFMissedPaymentEvent> {
        let self: ref<NCFMissedPaymentEvent> = new NCFMissedPaymentEvent();
        self.source = source;
        self.dueAmount = due;
        self.paidAmount = paid;
        self.unpaidAmount = unpaid;
        self.penaltyApplied = penalty;
        self.newOutstanding = outstanding;
        return self;
    }
}

public class NCFMainSystem extends ScriptableSystem {
    private persistent let isInitialized: Bool;
    private persistent let lastInterestDay: Int32;

    private let player: ref<PlayerPuppet>;
    private let Settings: ref<NCFSettings>;
    private let FinanceState: ref<NCFFinanceState>;
    private let delaySystem: ref<DelaySystem>;

    private let lastKnownBalance: Int32;
    private let isVendorOpen: Bool;
    private let isTracking: Bool;
    private let ncfTvIsOn: Bool;
    private let ncfShowerIsOn: Bool;
    private let lastToiletChargeTime: Float;
    private let amenitiesChargeTick: Int32;
    private let pollCallbackId: DelayID;
    private let periodicCallbackId: DelayID;

    // ----- Vendor-flow diagnostics (read by NCF_VendorDebugStatus) -----
    private let lastDelta: Int32;
    private let lastDeltaTime: Float;
    private let lastDeltaWasVendor: Bool;
    private let lastIncomeFiredAmount: Int32;
    private let lastIncomeFiredTime: Float;
    private let lastIncomeFiredTax: Int32;
    private let lastPurchaseFiredAmount: Int32;
    private let lastPurchaseFiredTime: Float;
    private let lastPurchaseFiredTax: Int32;
    private let lastDeductionEventTime: Float;
    private let lastSalesTaxEventTime: Float;
    private let vendorOpenedTime: Float;
    private let vendorClosedTime: Float;

    // ----- Per-event ring buffer (5 most recent events, newest at index 0) -----
    // Each callback/poll appends; oldest entries shift off. Format: short tag + diff.
    private let eventLog0: String;
    private let eventLog1: String;
    private let eventLog2: String;
    private let eventLog3: String;
    private let eventLog4: String;

    // ----- Vendor session accumulators (v1.0.38 architectural fix) -----
    // Gate pushes per-callback diffs into these while a vendor is open.
    // OnVendorClosed settles them by routing through HandleIncome / HandlePurchase
    // separately, so a buy of 204 + sell of 1471 produces BOTH income tax on
    // the 1471 and sales tax on the 204 — instead of being collapsed into a
    // single net delta of +1267 by the 1Hz poll (which loses the bowl's tax).
    private let pendingVendorSells: Int32;
    private let pendingVendorBuys: Int32;

    // ----- Fixer-cut gigs window (v2.0.1 fix for "fixer cut on all income") -----
    // Fixer cut should ONLY apply to actual gig payouts, not main-story rewards,
    // found money, world drops, etc. Mechanism: poll JournalManager.GetTrackedEntry()
    // alongside the money poll. When the tracked entry is a Contract-type quest
    // (gig) AND its state just transitioned to Succeeded, open a 60-second window
    // during which the next non-vendor income takes the fixer cut. After the cut
    // applies once, the window closes immediately. Outside the window: no fixer cut.
    //
    // Why poll instead of journal callback: callback signature for
    // RegisterScriptCallback varies between game patches; a 1Hz poll alongside
    // the existing money poll is patch-stable, costs nothing, and produces the
    // same observable behavior (fixer payouts always arrive >1s after the gig
    // completes — there's no race risk).
    private let fixerCutWindowEndTime: Float;
    private let lastTrackedEntryHash: Int32;
    private let lastTrackedEntryState: Int32;

    // ----- Vending machine purchase tracking (v2.0.1 fix for "no vending tax") -----
    // VendingMachine is NOT a FullscreenVendorGameController, so its purchases
    // never set isVendorOpen and the existing poll-driven HandlePurchase branch
    // (which requires isVendorOpen=true) never fires. Mechanism: wrap
    // VendingMachine.BuyItems to set a short pending window; when the gate
    // observes the matching negative money diff within that window, route it
    // straight to HandlePurchase. 3s window covers async transaction processing.
    private let vendingPurchasePendingUntil: Float;

    // ----- Scene/BD suppression (v2.0.5) -----
    // While V is in a braindance or a SceneTier3+ cinematic, every wallet
    // change is an inventory-swap artefact rather than a real player
    // transaction. Routing those through HandleIncome / HandlePurchase
    // produces the false-positive tax popups that multiple users reported
    // (Judy's BD, Johnny "tap on shoulder" sequences, act cinematics, etc.).
    //
    // Strategy: when suppression begins, snapshot the entry balance. While
    // suppressed, silently update lastKnownBalance every poll so the per-tick
    // diffs are ignored. When suppression ends, compute a single net delta
    // across the entire scene. If positive (gig payout that arrived during
    // a cinematic), route as ONE income event so the fixer-cut window and
    // income tax still apply. If zero or negative (BD inventory oscillation),
    // ignore — V didn't really gain or lose anything from the player's POV.
    private let suppressionActive: Bool;
    private let suppressionEntryBalance: Int32;

    public final static func GetInstance(gameInstance: GameInstance) -> ref<NCFMainSystem> {
        return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityFinance.Main.NCFMainSystem") as NCFMainSystem;
    }

    public final static func Get() -> ref<NCFMainSystem> {
        return NCFMainSystem.GetInstance(GetGameInstance());
    }

    public final func SetTvOn(on: Bool) -> Void {
        this.ncfTvIsOn = on;
    }

    public final func SetShowerOn(on: Bool) -> Void {
        this.ncfShowerIsOn = on;
    }

    public final func TryToiletCharge() -> Bool {
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        // 8s window: covers Flush event firing twice from engine (entity + PS),
        // plus any wrapper-cascade re-fires. Real human flushes are never <8s apart.
        if now - this.lastToiletChargeTime < 8.0 { return false; }
        this.lastToiletChargeTime = now;
        return true;
    }

    public final func SetVendorOpen(open: Bool) -> Void {
        this.isVendorOpen = open;
    }

    public final func IsVendorCurrentlyOpen() -> Bool {
        return this.isVendorOpen;
    }

    // ----- Diagnostic getters (NCF_VendorDebugStatus) -----
    public final func DiagGetLastDelta() -> Int32 { return this.lastDelta; }
    public final func DiagGetLastDeltaTime() -> Float { return this.lastDeltaTime; }
    public final func DiagGetLastDeltaWasVendor() -> Bool { return this.lastDeltaWasVendor; }
    public final func DiagGetLastIncomeAmount() -> Int32 { return this.lastIncomeFiredAmount; }
    public final func DiagGetLastIncomeTime() -> Float { return this.lastIncomeFiredTime; }
    public final func DiagGetLastIncomeTax() -> Int32 { return this.lastIncomeFiredTax; }
    public final func DiagGetLastPurchaseAmount() -> Int32 { return this.lastPurchaseFiredAmount; }
    public final func DiagGetLastPurchaseTime() -> Float { return this.lastPurchaseFiredTime; }
    public final func DiagGetLastPurchaseTax() -> Int32 { return this.lastPurchaseFiredTax; }
    public final func DiagGetLastDeductionEventTime() -> Float { return this.lastDeductionEventTime; }
    public final func DiagGetLastSalesTaxEventTime() -> Float { return this.lastSalesTaxEventTime; }
    public final func DiagGetVendorOpenedTime() -> Float { return this.vendorOpenedTime; }
    public final func DiagGetVendorClosedTime() -> Float { return this.vendorClosedTime; }

    public final func DiagLogEvent(tag: String) -> Void {
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        let entry: String = "[" + ToString(now) + "] " + tag;
        this.eventLog4 = this.eventLog3;
        this.eventLog3 = this.eventLog2;
        this.eventLog2 = this.eventLog1;
        this.eventLog1 = this.eventLog0;
        this.eventLog0 = entry;
    }
    public final func DiagGetEventLog0() -> String { return this.eventLog0; }
    public final func DiagGetEventLog1() -> String { return this.eventLog1; }
    public final func DiagGetEventLog2() -> String { return this.eventLog2; }
    public final func DiagGetEventLog3() -> String { return this.eventLog3; }
    public final func DiagGetEventLog4() -> String { return this.eventLog4; }

    // ----- Vendor session accumulator API (called from NCFNotificationGate) -----
    public final func RecordVendorSell(amount: Int32) -> Void {
        if amount <= 0 { return; }
        this.pendingVendorSells += amount;
    }
    public final func RecordVendorBuy(amount: Int32) -> Void {
        if amount <= 0 { return; }
        this.pendingVendorBuys += amount;
    }
    public final func DiagGetPendingSells() -> Int32 { return this.pendingVendorSells; }
    public final func DiagGetPendingBuys() -> Int32 { return this.pendingVendorBuys; }

    // Pure calculator. Returns the total amount HandleIncome will deduct for
    // a given gross income. Has NO side effects — does not record state, does
    // not dispatch events, does not touch debt. Safe to call from the popup
    // hook to preview the deduction before HandleIncome actually runs.
    //
    // Must stay byte-identical to HandleIncome's deduction logic. If you
    // change one, change the other.
    public final func ComputeExpectedDeduction(amount: Int32, isVendorSale: Bool) -> Int32 {
        // v2.0.5: scene/BD suppression — ComputeExpectedDeduction is called
        // from NCFNotificationGate.OnItemQuantityChanged to preview a "net"
        // amount in the yellow TRANSFER popup. During scenes the actual
        // deduction won't fire (OnMoneyPoll suppresses it), so the preview
        // must report 0 too or the player sees a tax line they never paid.
        if IsDefined(this.Settings) && this.Settings.suppressInScenes && this.IsInSuppressedContext() { return 0; }

        // v2.0.5: tax-free pickup threshold — non-vendor income below the
        // threshold is fully exempt (no tax, no fixer cut, no garnishment).
        // Vendor sells always count: the player chose to sell.
        let threshold: Int32 = IsDefined(this.Settings) ? this.Settings.incomeTaxThreshold : 0;
        if !isVendorSale && threshold > 0 && amount < threshold { return 0; }

        let fixerCut: Int32 = 0;
        // v2.0.1: fixer cut now ALSO requires an open fixer-payout window
        // (set by OnMoneyPoll's journal-tracked-entry detection when a Contract
        // quest succeeds). Without this gate, every non-vendor income >=500
        // got hit with a fixer cut — wrong for main story rewards, world
        // drops, etc.
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        let fixerWindowOpen: Bool = now < this.fixerCutWindowEndTime;
        if this.Settings.fixerCutEnabled && !isVendorSale && fixerWindowOpen && amount >= 500 && this.Settings.fixerCutDefault > 0 {
            fixerCut = NCF_CalculatePercentage(amount, this.Settings.fixerCutDefault);
        }
        let afterFixer: Int32 = amount - fixerCut;

        // v2.0.5: master toggle for income tax (independent of rate).
        let incomeTaxEnabled: Bool = !IsDefined(this.Settings) || this.Settings.incomeTaxEnabled;
        let incomeTax: Int32 = 0;
        if incomeTaxEnabled && this.Settings.incomeTaxRate > 0 {
            incomeTax = NCF_CalculatePercentage(afterFixer, this.Settings.incomeTaxRate);
        }
        let afterTax: Int32 = afterFixer - incomeTax;

        // v2.0.5: master toggle for garnishment.
        let garnishmentEnabled: Bool = !IsDefined(this.Settings) || this.Settings.garnishmentEnabled;
        let garnishment: Int32 = 0;
        if garnishmentEnabled && this.FinanceState.HasDebt() && this.Settings.debtGarnishmentRate > 0 {
            garnishment = NCF_CalculatePercentage(afterTax, this.Settings.debtGarnishmentRate);
        }

        return fixerCut + incomeTax + garnishment;
    }

    public final func GiveTaxFreeMoney(amount: Int32) -> Void {
        if amount <= 0 { return; }
        let gameInstance = GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
        if !IsDefined(player) { return; }
        let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
        if !IsDefined(transactionSystem) { return; }
        transactionSystem.GiveItem(player, MarketSystem.Money(), amount);
        this.lastKnownBalance = NCF_GetPlayerMoney();
    }

    public final func BuildVendorMoneySuffix() -> String {
        if !IsDefined(this.Settings) || !this.Settings.creditEnabled { return ""; }
        if !IsDefined(this.FinanceState) { return ""; }
        if !this.FinanceState.IsCreditLineOpen() { return ""; }

        let streetCred: Int32 = NCF_GetStreetCredLevel();
        let creditLimit: Int32 = streetCred * this.Settings.creditPerStreetCred;
        let currentDebt: Int32 = this.FinanceState.GetDebt();
        let availableCredit: Int32 = creditLimit - currentDebt;

        if creditLimit <= 0 { return ""; }

        if availableCredit <= 0 {
            return "Credit: €$ 0 / €$ " + ToString(creditLimit) + " (Debt: €$ " + ToString(currentDebt) + ")";
        }
        if currentDebt > 0 {
            return "Credit: €$ +" + ToString(availableCredit) + " (Debt: €$ " + ToString(currentDebt) + ")";
        }
        return "Credit: €$ +" + ToString(availableCredit);
    }

    private let injectedCreditAmount: Int32;
    private let balanceBeforeCredit: Int32;

    public final func GetInjectedCreditAmount() -> Int32 {
        return this.injectedCreditAmount;
    }

    // Player's spendable money MINUS any credit currently injected into
    // the wallet by the vendor-open credit injection. Use this for debt
    // repayment checks (loan shark, bank card) so injected credit can't
    // pay off the same credit line, and so credit can't be used to
    // settle a loan shark loan that should require real eddies.
    // Vendor purchases keep using raw NCF_GetPlayerMoney() because
    // credit IS spendable at vendors by design.
    public final func IsAmenitiesSuspended() -> Bool {
        if !IsDefined(this.FinanceState) { return false; }
        return this.FinanceState.IsAmenitiesSuspended();
    }

    public final func GetRealPlayerMoney() -> Int32 {
        let raw: Int32 = NCF_GetPlayerMoney();
        if this.injectedCreditAmount <= 0 { return raw; }
        let real: Int32 = raw - this.injectedCreditAmount;
        if real < 0 { return 0; }
        return real;
    }

    public final func OnVendorOpened() -> Void {
        this.vendorOpenedTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        // Reset accumulators at every open. Even if we don't inject credit
        // (creditEnabled=false or creditLine closed), the gate still pushes
        // per-event diffs — they need a clean slate per session.
        this.pendingVendorSells = 0;
        this.pendingVendorBuys = 0;
        if !IsDefined(this.Settings) || !this.Settings.creditEnabled { return; }
        if !IsDefined(this.FinanceState) { return; }
        if !this.FinanceState.IsCreditLineOpen() { return; }

        // v1.0.16 fix: guard against reentrant injection. RipperDocGameController
        // can fire OnSetUserData more than once per menu open (tab switches,
        // sub-popups, vendor data refresh). Without this guard, each call
        // injected another full credit batch on top of the previous one, but
        // injectedCreditAmount only tracked one batch — so on close, only
        // one batch was removed and the rest stayed in the wallet as a free
        // 7500-8000 €$ duplication every visit. This caused a money exploit
        // reported on Nexus where players could repeatedly visit a ripperdoc
        // with an open credit line to mint eddies.
        if this.injectedCreditAmount > 0 { return; }

        let streetCred: Int32 = NCF_GetStreetCredLevel();
        let creditLimit: Int32 = streetCred * this.Settings.creditPerStreetCred;
        let currentDebt: Int32 = this.FinanceState.GetDebt();
        let availableCredit: Int32 = creditLimit - currentDebt;
        if availableCredit <= 0 {
            return;
        }

        this.balanceBeforeCredit = NCF_GetPlayerMoney();
        this.injectedCreditAmount = availableCredit;

        let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();
        if IsDefined(gate) {
            gate.SuppressNext();
        }

        let gameInstance = GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
        let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
        transactionSystem.GiveItem(player, MarketSystem.Money(), availableCredit);

        this.lastKnownBalance = NCF_GetPlayerMoney();
    }

    public final func OnVendorClosed() -> Void {
        this.vendorClosedTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));

        // v1.0.38: settle pending vendor session FIRST. The gate accumulated
        // every per-callback diff while vendor was open, separated into sells
        // and buys. Route each through the appropriate tax handler so income
        // tax fires on sells AND sales tax fires on buys, even when both
        // happened in the same poll tick (which the old poll-aggregation
        // architecture would collapse into a single net delta).
        let sells: Int32 = this.pendingVendorSells;
        let buys: Int32 = this.pendingVendorBuys;
        this.pendingVendorSells = 0;
        this.pendingVendorBuys = 0;

        // v1.0.40: route through SettleVendorSession which fires a combined
        // popup when BOTH sells and buys happened (instead of two separate
        // popups racing for the single-slot WarningMessage blackboard).
        this.SettleVendorSession(sells, buys);

        // After tax handlers ran, refresh lastKnownBalance so the post-close
        // poll doesn't re-process the deduction as a phantom purchase.
        this.lastKnownBalance = NCF_GetPlayerMoney();

        if this.injectedCreditAmount <= 0 { return; }

        let currentBalance: Int32 = NCF_GetPlayerMoney();
        let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();

        if currentBalance >= this.injectedCreditAmount {
            if IsDefined(gate) { gate.SuppressNext(); }
            NCF_RemovePlayerMoney(this.injectedCreditAmount);
        } else {
            let spent: Int32 = this.injectedCreditAmount - currentBalance;
            if currentBalance > 0 {
                if IsDefined(gate) { gate.SuppressNext(); }
                NCF_RemovePlayerMoney(currentBalance);
            }
            this.FinanceState.AddDebt(spent);
            GameInstance.GetCallbackSystem().DispatchEvent(
                NCFDebtCreatedEvent.Create(spent, this.FinanceState.GetDebt())
            );
        }

        this.lastKnownBalance = NCF_GetPlayerMoney();
        this.injectedCreditAmount = 0;
        this.balanceBeforeCredit = 0;
    }

    public final func OnRadialWheelLateInitDone() -> Void {
        let gameInstance = GetGameInstance();
        this.player = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
        if !IsDefined(this.player) { return; }

        this.Settings = NCFSettings.GetInstance(gameInstance);
        this.FinanceState = NCFFinanceState.GetInstance(gameInstance);
        this.delaySystem = GameInstance.GetDelaySystem(gameInstance);

        this.Settings.Init(this.player);

        if !this.isInitialized {
            let currentDay: Int32 = this.GetCurrentGameDay();
            this.FinanceState.ResetPeriod(currentDay);
            this.lastInterestDay = currentDay;
            this.isInitialized = true;
        }

        this.lastKnownBalance = NCF_GetPlayerMoney();
        this.isTracking = true;
        this.RegisterMoneyPoll();

        this.RegisterPeriodicCheck();
    }

    public final func RegisterMoneyPoll() -> Void {
        if !this.isTracking { return; }
        if !IsDefined(this.delaySystem) { return; }
        let pollCb: ref<NCFMoneyPollCallback> = new NCFMoneyPollCallback();
        this.pollCallbackId = this.delaySystem.DelayCallback(pollCb, 1.0, false);
    }

    public final func RegisterPeriodicCheck() -> Void {
        if !this.isTracking { return; }
        if !IsDefined(this.delaySystem) { return; }
        let periodicCb: ref<NCFPeriodicCallback> = new NCFPeriodicCallback();
        this.periodicCallbackId = this.delaySystem.DelayCallback(periodicCb, 60.0, false);
    }

    public final func OnPlayerDeath() -> Void {
        this.isTracking = false;
        if IsDefined(this.delaySystem) {
            this.delaySystem.CancelCallback(this.pollCallbackId);
            this.delaySystem.CancelCallback(this.periodicCallbackId);
        }
        GameInstance.GetCallbackSystem().DispatchEvent(NCFPlayerDeathEvent.Create());
    }

    public final func OnMoneyPoll() -> Void {
        if !this.isTracking { return; }
        if !IsDefined(this.FinanceState) { return; }
        if !IsDefined(this.player) { return; }

        // v2.0.1: detect fixer-gig completion via tracked journal entry.
        // When the currently-tracked entry is a Contract-type quest (gig)
        // and its state has just transitioned to Succeeded, open the
        // 60-second fixer-cut window. Polled here (alongside the existing
        // 1Hz money poll) instead of via journal callback to avoid the
        // patch-version risk of an unstable callback signature.
        this.CheckFixerGigCompletion();

        // v1.0.35: removed `if this.injectedCreditAmount > 0 { return; }` guard.
        // It caused a critical bug: with a credit line open, NCF skipped the
        // entire poll for every tick the vendor was open, so all buys and
        // sells happened invisibly to NCF — no sales tax, no income tax, no
        // popups for any player using the credit feature. Both OnVendorOpened
        // and OnVendorClosed already update lastKnownBalance to the post-
        // injection / post-settlement value, so between those two events the
        // raw wallet delta accurately reflects the player's real transactions
        // even while injection is active. The guard was overcautious.

        let currentBalance: Int32 = NCF_GetPlayerMoney();
        let delta: Int32 = currentBalance - this.lastKnownBalance;

        if delta != 0 {
            this.lastDelta = delta;
            this.lastDeltaTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
            this.lastDeltaWasVendor = this.isVendorOpen;
            let vTag: String = this.isVendorOpen ? "V" : "-";
            this.DiagLogEvent("POLL " + vTag + " delta=" + ToString(delta) + " bal=" + ToString(currentBalance));
        }

        // v2.0.5: scene/braindance suppression. Highest priority gate —
        // checked before the vendor-open branch because the scene check
        // overrides everything (a vendor can't be open during a Tier3+
        // scene anyway, and BDs definitionally close any open vendor).
        // See suppressionActive / suppressionEntryBalance field comment
        // for the entry/exit semantics.
        let inScene: Bool = IsDefined(this.Settings) && this.Settings.suppressInScenes && this.IsInSuppressedContext();
        if inScene {
            if !this.suppressionActive {
                this.suppressionActive = true;
                this.suppressionEntryBalance = currentBalance;
                this.DiagLogEvent("SUPPRESS START bal=" + ToString(currentBalance));
            }
            this.lastKnownBalance = currentBalance;
            // ProcessAmenitiesSuspendedFee is intentionally skipped: V
            // can't be using a workspot (shower/TV) during a cinematic.
            return;
        }
        if this.suppressionActive {
            this.suppressionActive = false;
            let sceneDelta: Int32 = currentBalance - this.suppressionEntryBalance;
            this.DiagLogEvent("SUPPRESS END delta=" + ToString(sceneDelta));
            if sceneDelta > 0 {
                // Net positive across the scene — most likely a gig payout
                // that arrived mid-cinematic (Wakako/Hands paying during
                // dialogue, etc.). Route through HandleIncome ONCE so the
                // fixer-cut window and income tax still apply on it,
                // instead of N false-positive per-poll events.
                this.HandleIncome(sceneDelta, false);
            }
            this.lastKnownBalance = NCF_GetPlayerMoney();
            this.ProcessAmenitiesSuspendedFee();
            return;
        }

        // v1.0.38: while vendor is open, the gate accumulates per-event diffs
        // and OnVendorClosed settles them. Skip poll-driven routing entirely
        // here — running HandleIncome / HandlePurchase on the aggregate would
        // double-tax. Only update lastKnownBalance so post-close polls have
        // a fresh baseline.
        if this.isVendorOpen {
            this.lastKnownBalance = NCF_GetPlayerMoney();
            this.ProcessAmenitiesSuspendedFee();
            return;
        }

        if delta > 0 {
            this.HandleIncome(delta, this.isVendorOpen);
        } else if delta < 0 && this.isVendorOpen {
            this.HandlePurchase(-delta);
        }

        this.lastKnownBalance = NCF_GetPlayerMoney();

        // Amenities suspended fee: charge per second while player is in a workspot in safe zone
        this.ProcessAmenitiesSuspendedFee();
    }

    // v2.0.5: True when V is in a braindance, scripted cinematic, or other
    // scene where wallet diffs are inventory-swap artefacts rather than
    // real player transactions. Used by OnMoneyPoll (full suppression)
    // and ComputeExpectedDeduction (preview suppression).
    //
    // Reuses the exact blackboard signals the loan-shark ambush gate
    // (NCF_PlayerIsOutdoorSafe in NCFDebugBridge) has been using since
    // v0.16.x — those are battle-tested across hundreds of player hours
    // and known to correctly distinguish "scripted scene" from "open-world
    // dialogue" (Tier1 fixer handoffs MUST still tax their gig payouts).
    //
    //   - SceneTier > 1: in a cinematic (Johnny "tap on shoulder", death
    //     dreams, act-end scenes, any camera-locked sequence).
    //   - IsInLoreAnimationScene: scripted set-piece even when SceneTier
    //     reads as gameplay (some Phantom Liberty intros).
    //   - IsInMinigame: braindances, hacking minigame, arcade machines.
    //     This is the gate that catches the Judy/Evelyn BD bug (BD entry
    //     flips IsInMinigame=true). Hacking coverage is a bonus — V can't
    //     realistically receive income mid-quickhack, and any payout
    //     queued during hacking will be taxed once on suppression-end.
    public final func IsInSuppressedContext() -> Bool {
        if !IsDefined(this.player) { return false; }
        let bb: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
        if !IsDefined(bb) { return false; }

        let sceneTier: Int32 = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier);
        if sceneTier > 1 { return true; }

        let inLoreScene: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInLoreAnimationScene);
        if inLoreScene { return true; }

        let inMinigame: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInMinigame);
        if inMinigame { return true; }

        return false;
    }

    private final func ProcessAmenitiesSuspendedFee() -> Void {
        if !IsDefined(this.Settings) || !this.Settings.amenitiesEnabled { return; }
        if !IsDefined(this.FinanceState) { return; }
        if !this.FinanceState.IsAmenitiesSubscribed() { return; }
        if !this.FinanceState.IsAmenitiesSuspended() { return; }
        let bb: ref<IBlackboard> = this.player.GetPlayerStateMachineBlackboard();
        if !IsDefined(bb) { return; }
        if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) >= 3 { return; }

        // Charge in 5-second batches instead of per-second.
        // Per-second NCF_RemovePlayerMoney calls cause the eddies HUD counter to
        // restart its tween every tick, producing visible stutter. Batching to
        // every 5th poll lets the HUD animation complete between deductions.
        // Same total cost: fee/sec * 5 charged once per 5s.
        this.amenitiesChargeTick += 1;
        if this.amenitiesChargeTick < 5 { return; }
        this.amenitiesChargeTick = 0;

        // Shower: 5x per-second fee, charged in one batch
        if this.ncfShowerIsOn && this.Settings.amenitiesSuspendedFeePerSec > 0 {
            let fee: Int32 = this.Settings.amenitiesSuspendedFeePerSec * 5;
            let wallet: Int32 = NCF_GetPlayerMoney();
            if wallet >= fee {
                NCF_RemovePlayerMoney(fee);
                this.FinanceState.PayAmenities(fee);
            } else {
                if wallet > 0 {
                    NCF_RemovePlayerMoney(wallet);
                    this.FinanceState.PayAmenities(wallet);
                }
                this.FinanceState.AddAmenitiesDebt(fee - wallet);
            }
            this.lastKnownBalance = NCF_GetPlayerMoney();
            NCFLogNoSystem("[Amenities] Shower suspended fee batch: " + ToString(fee) + " €$ charged");
        }
        // TV: 5x per-second fee, charged in one batch
        if this.ncfTvIsOn && this.Settings.amenitiesTvFeePerSec > 0 {
            let tvFee: Int32 = this.Settings.amenitiesTvFeePerSec * 5;
            let tvWallet: Int32 = NCF_GetPlayerMoney();
            if tvWallet >= tvFee {
                NCF_RemovePlayerMoney(tvFee);
                this.FinanceState.PayAmenities(tvFee);
            } else {
                if tvWallet > 0 {
                    NCF_RemovePlayerMoney(tvWallet);
                    this.FinanceState.PayAmenities(tvWallet);
                }
                this.FinanceState.AddAmenitiesDebt(tvFee - tvWallet);
            }
            this.lastKnownBalance = NCF_GetPlayerMoney();
            NCFLogNoSystem("[Amenities] TV suspended fee batch: " + ToString(tvFee) + " €$ charged");
        }
    }

    private final func HandleIncome(amount: Int32, isVendorSale: Bool) -> Void {
        this.lastIncomeFiredAmount = amount;
        this.lastIncomeFiredTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        this.DiagLogEvent("INCOME amt=" + ToString(amount) + " vendorSale=" + (isVendorSale ? "y" : "n"));

        // v2.0.5: tax-free pickup threshold — non-vendor income below the
        // threshold is fully exempt (no tax, no fixer cut, no garnishment,
        // no popup, no state recording). Mirror of ComputeExpectedDeduction.
        let threshold: Int32 = IsDefined(this.Settings) ? this.Settings.incomeTaxThreshold : 0;
        if !isVendorSale && threshold > 0 && amount < threshold {
            this.DiagLogEvent("INCOME exempt (below threshold " + ToString(threshold) + ")");
            return;
        }

        let fixerCut: Int32 = 0;
        // v2.0.1: fixer cut only applies inside an open fixer-payout window
        // (set by OnMoneyPoll when a Contract quest succeeds). Consume the
        // window after applying once so the same gig payout never gets cut twice.
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        let fixerWindowOpen: Bool = now < this.fixerCutWindowEndTime;
        if this.Settings.fixerCutEnabled && !isVendorSale && fixerWindowOpen && amount >= 500 && this.Settings.fixerCutDefault > 0 {
            fixerCut = NCF_CalculatePercentage(amount, this.Settings.fixerCutDefault);
            this.fixerCutWindowEndTime = 0.0;
            this.DiagLogEvent("FIXER CUT applied " + ToString(fixerCut) + " (window consumed)");
        }
        let afterFixer: Int32 = amount - fixerCut;

        // v2.0.5: master toggle for income tax (independent of rate slider).
        let incomeTaxEnabled: Bool = !IsDefined(this.Settings) || this.Settings.incomeTaxEnabled;
        let incomeTax: Int32 = 0;
        if incomeTaxEnabled && this.Settings.incomeTaxRate > 0 {
            incomeTax = NCF_CalculatePercentage(afterFixer, this.Settings.incomeTaxRate);
        }
        let afterTax: Int32 = afterFixer - incomeTax;

        // v2.0.5: master toggle for garnishment.
        let garnishmentEnabled: Bool = !IsDefined(this.Settings) || this.Settings.garnishmentEnabled;
        let garnishment: Int32 = 0;
        if garnishmentEnabled && this.FinanceState.HasDebt() && this.Settings.debtGarnishmentRate > 0 {
            garnishment = NCF_CalculatePercentage(afterTax, this.Settings.debtGarnishmentRate);
            if garnishment > 0 {
                this.FinanceState.ReduceDebt(garnishment);
            }
        }

        let totalDeduction: Int32 = fixerCut + incomeTax + garnishment;
        if totalDeduction <= 0 { return; }

        let netAmount: Int32 = amount - totalDeduction;

        let currentMoney: Int32 = NCF_GetPlayerMoney();
        if currentMoney >= totalDeduction {
            let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();
            if IsDefined(gate) { gate.SuppressNext(); }
            NCF_RemovePlayerMoney(totalDeduction);
        } else {
            if currentMoney > 0 {
                let gate2: ref<NCFNotificationGate> = NCFNotificationGate.Get();
                if IsDefined(gate2) { gate2.SuppressNext(); }
                NCF_RemovePlayerMoney(currentMoney);
            }
            let remainder: Int32 = totalDeduction - currentMoney;
            this.FinanceState.AddDebt(remainder);
            GameInstance.GetCallbackSystem().DispatchEvent(
                NCFDebtCreatedEvent.Create(remainder, this.FinanceState.GetDebt())
            );
        }

        this.FinanceState.RecordIncomeTax(amount, incomeTax);
        if fixerCut > 0 { this.FinanceState.RecordFixerCut(fixerCut); }

        this.lastIncomeFiredTax = incomeTax;
        this.lastDeductionEventTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));

        GameInstance.GetCallbackSystem().DispatchEvent(
            NCFDeductionEvent.Create(amount, fixerCut, incomeTax, garnishment, netAmount)
        );
    }

    // v1.0.40: Settle vendor session deductions. When BOTH sells and buys
    // happened in the same vendor visit, fires ONE combined popup with both
    // tax lines instead of two separate popups racing for the single-slot
    // WarningMessage blackboard variant. When only one side fires, routes
    // to the existing HandleIncome/HandlePurchase path (single popup, no race).
    //
    // Money side: combined path duplicates the deduction math inline (income
    // tax + garnishment for sells, sales tax for buys) so the blue popup is
    // the only popup — bypasses NCFDeductionEvent / NCFSalesTaxEvent dispatch.
    // Money state changes (debt, recordings) still happen via FinanceState calls.
    private final func SettleVendorSession(sells: Int32, buys: Int32) -> Void {
        if sells <= 0 && buys <= 0 { return; }

        // Single-side: existing path is fine, no popup race possible.
        if sells > 0 && buys <= 0 {
            this.HandleIncome(sells, true);
            return;
        }
        if buys > 0 && sells <= 0 {
            this.HandlePurchase(buys);
            return;
        }

        // Both sides — combined path. Compute everything first, deduct in one
        // RemoveItem to keep wallet update atomic, fire one popup with two lines.
        this.lastIncomeFiredAmount = sells;
        this.lastIncomeFiredTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        this.lastPurchaseFiredAmount = buys;
        this.lastPurchaseFiredTime = this.lastIncomeFiredTime;
        this.DiagLogEvent("SETTLE-COMBINED sell=" + ToString(sells) + " buy=" + ToString(buys));

        // v2.0.5: master toggles. Both sides may be off independently.
        let incomeTaxEnabled: Bool = !IsDefined(this.Settings) || this.Settings.incomeTaxEnabled;
        let salesTaxEnabled: Bool = !IsDefined(this.Settings) || this.Settings.salesTaxEnabled;
        let garnishmentEnabled: Bool = !IsDefined(this.Settings) || this.Settings.garnishmentEnabled;

        // ---- Income side (sell) — vendor sale, no fixer cut ----
        let incomeTax: Int32 = 0;
        if incomeTaxEnabled && this.Settings.incomeTaxRate > 0 {
            incomeTax = NCF_CalculatePercentage(sells, this.Settings.incomeTaxRate);
        }
        let afterTax: Int32 = sells - incomeTax;
        let garnishment: Int32 = 0;
        if garnishmentEnabled && this.FinanceState.HasDebt() && this.Settings.debtGarnishmentRate > 0 {
            garnishment = NCF_CalculatePercentage(afterTax, this.Settings.debtGarnishmentRate);
            if garnishment > 0 { this.FinanceState.ReduceDebt(garnishment); }
        }
        let incomeDeduction: Int32 = incomeTax + garnishment;

        // ---- Purchase side (buy) ----
        let salesTax: Int32 = 0;
        if salesTaxEnabled && this.Settings.salesTaxRate > 0 {
            salesTax = NCF_CalculateTaxWithFloor(buys, this.Settings.salesTaxRate);
        }

        let totalDeduction: Int32 = incomeDeduction + salesTax;
        if totalDeduction > 0 {
            let wallet: Int32 = NCF_GetPlayerMoney();
            if wallet >= totalDeduction {
                let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();
                if IsDefined(gate) { gate.SuppressNext(); }
                NCF_RemovePlayerMoney(totalDeduction);
            } else {
                if wallet > 0 {
                    let gate2: ref<NCFNotificationGate> = NCFNotificationGate.Get();
                    if IsDefined(gate2) { gate2.SuppressNext(); }
                    NCF_RemovePlayerMoney(wallet);
                }
                let remainder: Int32 = totalDeduction - wallet;
                this.FinanceState.AddDebt(remainder);
                GameInstance.GetCallbackSystem().DispatchEvent(
                    NCFDebtCreatedEvent.Create(remainder, this.FinanceState.GetDebt())
                );
            }
        }

        // Bookkeeping
        this.FinanceState.RecordIncomeTax(sells, incomeTax);
        if salesTax > 0 { this.FinanceState.RecordSalesTax(salesTax); }
        this.lastIncomeFiredTax = incomeTax;
        this.lastPurchaseFiredTax = salesTax;
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        this.lastDeductionEventTime = now;
        this.lastSalesTaxEventTime = now;

        // ---- Combined popup (skip if user disabled BOTH popup types) ----
        let showIncome: Bool = !IsDefined(this.Settings) || this.Settings.showTaxReportPopup;
        let showSales: Bool = !IsDefined(this.Settings) || this.Settings.showSalesTaxPopup;
        if !showIncome && !showSales { return; }

        let netSell: Int32 = sells - incomeDeduction;
        let netBuy: Int32 = buys + salesTax;

        let line1: String = "NCTA Sale | Gross: " + ToString(sells) + " | Tax: -" + ToString(incomeTax);
        if garnishment > 0 { line1 += " | Debt: -" + ToString(garnishment); }
        line1 += " | Net: " + ToString(netSell);
        let line2: String = "NCTA Buy | Cost: " + ToString(buys) + " | Tax: -" + ToString(salesTax) + " | Total: " + ToString(netBuy);

        let combined: String;
        if showIncome && showSales {
            combined = line1 + "\n" + line2;
        } else if showIncome {
            combined = line1;
        } else {
            combined = line2;
        }
        NCFShowMessage(combined, 6.0);
    }

    private final func HandlePurchase(purchaseAmount: Int32) -> Void {
        this.lastPurchaseFiredAmount = purchaseAmount;
        this.lastPurchaseFiredTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        this.DiagLogEvent("PURCHASE amt=" + ToString(purchaseAmount));
        // v2.0.5: master toggle for sales tax. Independent of rate slider.
        if IsDefined(this.Settings) && !this.Settings.salesTaxEnabled { return; }
        if this.Settings.salesTaxRate <= 0 { return; }
        // Use the 1-eddie floor helper so cheap purchases still show
        // (and pay) the lore-required minimum tax. Display side
        // (NCF_BuildTaxSuffix) calls the same helper so the number
        // shown in the tooltip matches the number deducted here.
        let tax: Int32 = NCF_CalculateTaxWithFloor(purchaseAmount, this.Settings.salesTaxRate);
        if tax <= 0 { return; }

        // Only suppress the yellow TRANSFER popup if we KNOW removal will fire.
        // Suppressing then no-op'ing leaks the count onto the next legit popup.
        let paid: Bool;
        if NCF_PlayerHasMoney(tax) {
            let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();
            if IsDefined(gate) { gate.SuppressNext(); }
            paid = NCF_RemovePlayerMoney(tax);
        } else {
            paid = false;
        }
        if !paid {
            this.FinanceState.AddDebt(tax);
            GameInstance.GetCallbackSystem().DispatchEvent(
                NCFDebtCreatedEvent.Create(tax, this.FinanceState.GetDebt())
            );
        }
        this.FinanceState.RecordSalesTax(tax);

        this.lastPurchaseFiredTax = tax;
        this.lastSalesTaxEventTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));

        GameInstance.GetCallbackSystem().DispatchEvent(NCFSalesTaxEvent.Create(tax, purchaseAmount));
    }

    public final func OnPeriodicUpdate() -> Void {
        if !IsDefined(this.Settings) { return; }
        if !IsDefined(this.FinanceState) { return; }

        let currentDay: Int32 = this.GetCurrentGameDay();

        // v0.16.9: legacy-save migration. For saves carried over from before
        // the ambush feature, loanTakenOnDay may be 0 — bootstrap it now.
        this.FinanceState.EnsureLoanSharkSentinelInitialized(currentDay);

        if currentDay > this.lastInterestDay {
            if this.FinanceState.HasDebt() {
                let interest: Int32 = this.FinanceState.AccrueInterest(this.Settings);
                if interest > 0 {
                    GameInstance.GetCallbackSystem().DispatchEvent(
                        NCFDebtInterestEvent.Create(interest, this.FinanceState.GetDebt())
                    );
                }
            }
            if this.FinanceState.HasActiveLoan() {
                this.FinanceState.AccrueLoanInterest();
            }
            this.FinanceState.ResolveScheduleSentinels(currentDay);
            // v0.13.12: Daily payments are now PLAYER-DRIVEN ONLY.
            // this.ProcessDailyPayments(currentDay);
            this.ProcessAmenitiesBilling(currentDay);
            this.ProcessLoanSharkAmbushCheck(currentDay);
            this.lastInterestDay = currentDay;
        }

        let lastReportDay: Int32 = this.FinanceState.GetLastReportDay();
        // v1.0.7 DIAGNOSTIC
        NCFLogNoSystem("[Periodic] tick: currentDay=" + ToString(currentDay) + " lastReportDay=" + ToString(lastReportDay));
        if currentDay > lastReportDay {
            NCFLogNoSystem("[Periodic] day-roll gate PASSED — calling PushDailyPhoneNotifications");
            // v0.16.9: only advance the report-day sentinel if the SMS push
            // actually had a chance to fire. Otherwise, on a fresh session
            // load before the player has opened the phone (m_phoneEverInitialized
            // is non-persistent and resets to false), the SMS would silently
            // fail and the day would be marked done — losing today's notification.
            // v1.0.2: Amenities reminder rides this same path now (was a
            // separate 6am gate that silently failed for some users).
            if this.PushDailyPhoneNotifications() {
                this.FinanceState.ResetPeriod(currentDay);
                NCFLogNoSystem("[Periodic] ResetPeriod called: lastReportDay advanced to " + ToString(currentDay));
            } else {
                NCFLogNoSystem("[Periodic] PushDailyPhoneNotifications returned false — sentinel NOT advanced");
            }
        }
    }

    public final func PushDailyPhoneNotifications() -> Bool {
        // v1.0.7 DIAGNOSTIC: log every gate to identify why Premium amenities
        // reminder doesn't fire. See NCF-Premium-Reminder-Bug-Handover.md.
        NCFLogNoSystem("[Daily] PushDailyPhoneNotifications ENTRY");

        let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if !IsDefined(ncfPhone) {
            NCFLogNoSystem("[Daily] EARLY-EXIT: ncfPhone is null");
            return false;
        }
        if !ncfPhone.IsPhoneReady() {
            NCFLogNoSystem("[Daily] EARLY-EXIT: phone not ready");
            return false;
        }

        let player: ref<GameObject> = GetPlayerObjectGlobal();
        if !IsDefined(player) {
            NCFLogNoSystem("[Daily] EARLY-EXIT: player is null");
            return false;
        }
        let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
        if !IsDefined(phoneExt) {
            NCFLogNoSystem("[Daily] EARLY-EXIT: phoneExt is null");
            return false;
        }

        // Bank gate
        let bankDebt: Int32 = this.FinanceState.GetCardDebt();
        let bankEnabled: Bool = this.Settings.bankEnabled;
        let bankRegistered: Bool = ncfPhone.IsBankRegistered();
        NCFLogNoSystem("[Daily] BANK gate: debt=" + ToString(bankDebt) + " enabled=" + ToString(bankEnabled) + " registered=" + ToString(bankRegistered));
        if bankDebt > 0 && bankEnabled && bankRegistered {
            let due: Int32 = this.FinanceState.CalculateCardPaymentDue(this.Settings);
            let bankMsg: String = "Daily statement: " + ToString(due) + " €$ due today.";
            ncfPhone.MarkBankActivity();
            ncfPhone.SetLastBankNotificationText(bankMsg);
            NCFLogNoSystem("[Daily] BANK firing NotifyNewMessageCustom (due=" + ToString(due) + ")");
            phoneExt.NotifyNewMessageCustom(
                NCFBankContactHash(),
                "First Bank of NC",
                bankMsg
            );
        } else {
            NCFLogNoSystem("[Daily] BANK gate FAILED — skipping");
        }

        // Loan shark gate
        let loanDebt: Int32 = this.FinanceState.GetLoanSharkDebt();
        let loanEnabled: Bool = this.Settings.loanSharkEnabled;
        let loanRegistered: Bool = ncfPhone.IsLoanSharkRegistered();
        NCFLogNoSystem("[Daily] LOAN gate: debt=" + ToString(loanDebt) + " enabled=" + ToString(loanEnabled) + " registered=" + ToString(loanRegistered));
        if loanDebt > 0 && loanEnabled && loanRegistered {
            let due: Int32 = this.FinanceState.CalculateLoanPaymentDue(this.Settings);
            let loanMsg: String = "You owe me " + ToString(due) + " €$ today, choom.";
            ncfPhone.MarkLoanSharkActivity();
            ncfPhone.SetLastLoanSharkNotificationText(loanMsg);
            NCFLogNoSystem("[Daily] LOAN firing NotifyNewMessageCustom (due=" + ToString(due) + ")");
            phoneExt.NotifyNewMessageCustom(
                NCFLoanSharkContactHash(),
                "Loan Shark",
                loanMsg
            );
        } else {
            NCFLogNoSystem("[Daily] LOAN gate FAILED — skipping");
        }

        // Amenities gate
        let amenSubscribed: Bool = this.FinanceState.IsAmenitiesSubscribed();
        let amenTier: Int32 = this.FinanceState.GetAmenitiesTier();
        let amenEnabled: Bool = this.Settings.amenitiesEnabled;
        let amenRegistered: Bool = ncfPhone.IsAmenitiesRegistered();
        NCFLogNoSystem("[Daily] AMEN gate: subscribed=" + ToString(amenSubscribed) + " tier=" + ToString(amenTier) + " enabled=" + ToString(amenEnabled) + " registered=" + ToString(amenRegistered));
        if amenSubscribed && amenEnabled && amenRegistered {
            let amenitiesPopup: String = this.BuildAmenitiesPopupText();
            let amenitiesThread: String = this.BuildAmenitiesReminderText();
            ncfPhone.MarkAmenitiesActivity();
            ncfPhone.SetLastAmenitiesNotificationText(amenitiesThread);
            NCFLogNoSystem("[Daily] AMEN firing NotifyNewMessageCustom (popupBody='" + amenitiesPopup + "' len=" + ToString(StrLen(amenitiesPopup)) + ")");
            phoneExt.NotifyNewMessageCustom(
                NCFAmenitiesContactHash(),
                "NC Amenities Corp",
                amenitiesPopup
            );
            NCFLogNoSystem("[Daily] AMEN NotifyNewMessageCustom RETURNED");
            if this.FinanceState.IsAmenitiesSuspended() {
                let warningMsg: SimpleScreenMessage;
                warningMsg.isShown = true;
                warningMsg.duration = 6.0;
                warningMsg.message = "NC AMENITIES CORP - SERVICES SUSPENDED";
                warningMsg.type = SimpleMessageType.Negative;
                GameInstance.GetBlackboardSystem(GetGameInstance())
                    .Get(GetAllBlackboardDefs().UI_Notifications)
                    .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
            }
        } else {
            NCFLogNoSystem("[Daily] AMEN gate FAILED — skipping");
        }

        NCFLogNoSystem("[Daily] PushDailyPhoneNotifications EXIT (returning true)");
        return true;
    }

    // Short HUD-toast body. Engine's SMS popup widget appears to silently
    // suppress when the body is too long — bank/loan stay under ~40 chars
    // and reliably trigger the popup, so we follow the same style.
    private final func BuildAmenitiesPopupText() -> String {
        let debt: Int32 = this.FinanceState.GetAmenitiesDebt();
        let suspended: Bool = this.FinanceState.IsAmenitiesSuspended();
        let tier: Int32 = this.FinanceState.GetAmenitiesTier();
        let rate: Int32 = tier == 1 ? this.Settings.amenitiesBasicDailyRate : this.Settings.amenitiesPremiumDailyRate;

        if suspended {
            return "SUSPENDED. Pay " + ToString(debt) + " €$ to restore.";
        }
        if debt > 0 {
            return "Bill: " + ToString(rate) + " €$. Balance: " + ToString(debt) + " €$.";
        }
        return "Bill: " + ToString(rate) + " €$ today.";
    }

    // Builds the body text for the daily amenities reminder.
    // Pulled out so PushDailyPhoneNotifications stays scannable.
    private final func BuildAmenitiesReminderText() -> String {
        let debt: Int32 = this.FinanceState.GetAmenitiesDebt();
        let suspended: Bool = this.FinanceState.IsAmenitiesSuspended();
        let grace: Int32 = this.FinanceState.GetAmenitiesGraceDaysLeft();
        let tier: Int32 = this.FinanceState.GetAmenitiesTier();
        let rate: Int32 = tier == 1 ? this.Settings.amenitiesBasicDailyRate : this.Settings.amenitiesPremiumDailyRate;

        if suspended {
            return "SERVICES SUSPENDED - Outstanding balance: " + ToString(debt)
                + " €$. Contact NC Amenities Corp to restore water, net, heating, and electricity at your current residence.";
        }
        if debt > 0 {
            let daysLeft: String = grace == 1 ? "1 day" : ToString(grace) + " days";
            return "Daily bill reminder - Today's charge: " + ToString(rate) + " €$. "
                + "Outstanding balance: " + ToString(debt) + " €$. "
                + "Services will be suspended in " + daysLeft
                + " if not paid. Contact NC Amenities Corp to settle.";
        }
        let tierLabel: String = tier == 1 ? "Basic" : "Premium";
        return "Daily bill reminder - " + tierLabel + " plan: " + ToString(rate)
            + " €$/day for water, net, heating, and electricity. "
            + "Today's charge of " + ToString(rate)
            + " €$ has been applied to your account. "
            + "Contact NC Amenities Corp to pay and avoid service interruption.";
    }

    private final func ProcessAmenitiesBilling(currentDay: Int32) -> Void {
        if !IsDefined(this.Settings) || !this.Settings.amenitiesEnabled { return; }
        if !IsDefined(this.FinanceState) { return; }
        if !this.FinanceState.IsAmenitiesSubscribed() { return; }
        let lastBilled: Int32 = this.FinanceState.GetLastAmenitiesBilledDay();
        if currentDay <= lastBilled { return; }
        this.FinanceState.BillAmenitiesDaily(this.Settings, currentDay);
    }

    // -------------------------------------------------------------------------
    // Loan Shark Ambush — daily threshold check (v0.16.0)
    //
    // Trigger: BOTH conditions true
    //   - loanSharkDebt >= settings.loanSharkAmbushDebtThreshold (default 20000)
    //   - daysSinceLastPayment >= settings.loanSharkAmbushDaysThreshold (default 5)
    // Cooldown: at least settings.loanSharkAmbushCooldownDays (default 1) since
    //   last ambush. Prevents repeat-fire on the same overdue period after V kills
    //   the goons but still hasn't paid — the intent is "one ambush per missed
    //   day cycle." User answered Q3 = one-shot per overdue period.
    //
    // We only set the PENDING flag here. The actual spawn happens from CET
    // (NightCityFinance/init.lua) once V is in a safe outdoor context.
    // -------------------------------------------------------------------------
    private final func ProcessLoanSharkAmbushCheck(currentDay: Int32) -> Void {
        if !IsDefined(this.Settings) { return; }
        if !this.Settings.loanSharkAmbushEnabled { return; }
        if !IsDefined(this.FinanceState) { return; }
        if !this.FinanceState.HasActiveLoan() { return; }

        let debt: Int32 = this.FinanceState.GetLoanSharkDebt();
        if debt < this.Settings.loanSharkAmbushDebtThreshold { return; }

        let overdue: Int32 = this.FinanceState.GetLoanSharkOverdueDays(currentDay);
        if overdue < this.Settings.loanSharkAmbushDaysThreshold { return; }

        // Don't re-arm if already pending — CET hasn't spawned yet.
        if this.FinanceState.IsLoanSharkAmbushPending() { return; }

        // Cooldown: don't fire again within N days of last ambush.
        let lastAmbush: Int32 = this.FinanceState.GetLastLoanSharkAmbushDay();
        if lastAmbush > 0 && (currentDay - lastAmbush) < this.Settings.loanSharkAmbushCooldownDays {
            return;
        }

        this.FinanceState.SetLoanSharkAmbushPending(currentDay);
        NCFLog(this, "Loan Shark ambush armed: debt=" + ToString(debt) + " overdue=" + ToString(overdue) + " day=" + ToString(currentDay));
    }

    private final func ProcessDailyPayments(currentDay: Int32) -> Void {
        let cardDue: Int32 = this.FinanceState.GetNextCardPaymentDay();
        if this.FinanceState.GetCardDebt() > 0 && cardDue > 0 && cardDue <= currentDay {
            let amountDue: Int32 = this.FinanceState.CalculateCardPaymentDue(this.Settings);
            this.SettlePayment("card", amountDue, currentDay);
            if this.FinanceState.GetCardDebt() > 0 {
                this.FinanceState.ScheduleNextCardPayment(currentDay + 1);
            } else {
                this.FinanceState.ScheduleNextCardPayment(0);
            }
        }
        let loanDue: Int32 = this.FinanceState.GetNextLoanPaymentDay();
        if this.FinanceState.GetLoanSharkDebt() > 0 && loanDue > 0 && loanDue <= currentDay {
            let amountDue: Int32 = this.FinanceState.CalculateLoanPaymentDue(this.Settings);
            this.SettlePayment("loanshark", amountDue, currentDay);
            if this.FinanceState.GetLoanSharkDebt() > 0 {
                this.FinanceState.ScheduleNextLoanPayment(currentDay + 1);
            } else {
                this.FinanceState.ScheduleNextLoanPayment(0);
            }
        }
    }

    private final func SettlePayment(source: String, amountDue: Int32, currentDay: Int32) -> Void {
        if amountDue <= 0 { return; }
        let walletBefore: Int32 = NCF_GetPlayerMoney();
        let paid: Int32 = 0;
        if walletBefore >= amountDue {
            NCF_RemovePlayerMoney(amountDue);
            paid = amountDue;
            if Equals(source, "card") {
                this.FinanceState.ReduceDebt(amountDue);
            } else {
                this.FinanceState.ReduceLoanShark(amountDue);
            }
            return;
        }
        if walletBefore > 0 {
            NCF_RemovePlayerMoney(walletBefore);
            paid = walletBefore;
            if Equals(source, "card") {
                this.FinanceState.ReduceDebt(walletBefore);
            } else {
                this.FinanceState.ReduceLoanShark(walletBefore);
            }
        }
        let unpaid: Int32 = amountDue - paid;
        let penalty: Int32 = 0;
        if Equals(source, "card") {
            penalty = this.FinanceState.AddCardPenalty(unpaid, this.Settings);
        } else {
            penalty = this.FinanceState.AddLoanPenalty(unpaid, this.Settings);
        }
        let outstanding: Int32 = Equals(source, "card")
            ? this.FinanceState.GetCardDebt()
            : this.FinanceState.GetLoanSharkDebt();
        GameInstance.GetCallbackSystem().DispatchEvent(
            NCFMissedPaymentEvent.Create(source, amountDue, paid, unpaid, penalty, outstanding)
        );
    }

    private final func GetCurrentGameDay() -> Int32 {
        let now: GameTime = GetGameInstance().GetGameTime();
        return now.Days();
    }

    // v2.0.1: Detects fixer-gig completion via the JournalManager's currently
    // tracked entry. Called once per money-poll tick (1Hz). When the tracked
    // entry's state has just transitioned to Succeeded AND the entry is a
    // Contract-type quest (gig), open a 60-second window during which the
    // next non-vendor income takes the fixer cut.
    //
    // Why tracked entry: the player typically tracks the gig they're doing.
    // Mr. Hands gigs, fixer gigs, NCPD scanners, etc. all show as quest type
    // Contract. Main story (MainQuest), side jobs (SideQuest), CyberPsychos
    // (CyberPsycho) are different types and won't trigger the cut.
    //
    // Why 60s: payouts arrive 0.5–10s after the gig flips Succeeded
    // (cinematic + delivery), so 60s is generous enough to catch the
    // payout while still narrow enough to not catch unrelated income.
    private final func CheckFixerGigCompletion() -> Void {
        let gameInstance = GetGameInstance();
        let journalManager: ref<JournalManager> = GameInstance.GetJournalManager(gameInstance);
        if !IsDefined(journalManager) { return; }

        let trackedEntry: wref<JournalEntry> = journalManager.GetTrackedEntry();
        if !IsDefined(trackedEntry) {
            this.lastTrackedEntryHash = 0;
            this.lastTrackedEntryState = 0;
            return;
        }

        let entryHash: Int32 = journalManager.GetEntryHash(trackedEntry);
        let entryState: gameJournalEntryState = journalManager.GetEntryState(trackedEntry);
        let entryStateInt: Int32 = EnumInt(entryState);

        // Same entry, same state: nothing to do.
        if entryHash == this.lastTrackedEntryHash && entryStateInt == this.lastTrackedEntryState {
            return;
        }

        let prevState: Int32 = this.lastTrackedEntryState;
        let prevHash: Int32 = this.lastTrackedEntryHash;
        this.lastTrackedEntryHash = entryHash;
        this.lastTrackedEntryState = entryStateInt;

        // Only fire on a transition INTO Succeeded (state value 3) for the SAME
        // entry. If the tracked entry just changed (different hash), the user
        // started tracking a different quest — not a completion event.
        if entryHash != prevHash { return; }
        let succeededInt: Int32 = EnumInt(gameJournalEntryState.Succeeded);
        if entryStateInt != succeededInt { return; }
        if prevState == succeededInt { return; }

        // Filter to Contract-type quests (gigs). MainQuest / SideQuest /
        // CyberPsycho / etc. don't take a fixer cut.
        let questType: gameJournalQuestType = journalManager.GetQuestType(trackedEntry);
        let contractInt: Int32 = EnumInt(gameJournalQuestType.Contract);
        if EnumInt(questType) != contractInt { return; }

        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(gameInstance));
        this.fixerCutWindowEndTime = now + 60.0;
        this.DiagLogEvent("FIXER WINDOW opened (gig succeeded, hash=" + ToString(entryHash) + ")");
    }

    // v2.0.1: Called by NCFNotificationGate when a money-removal callback
    // fires during an open vending-machine purchase window. Routes the
    // amount through HandlePurchase so sales tax applies, same as any
    // other vendor purchase. Wraps a SuppressNext call so the vanilla
    // yellow TRANSFER popup is suppressed for the tax deduction itself
    // (the original purchase popup is unaffected — that's the player
    // seeing what they paid the vendor).
    public final func RecordVendingPurchase(amount: Int32) -> Void {
        if amount <= 0 { return; }
        this.DiagLogEvent("VENDING PURCHASE routed amt=" + ToString(amount));
        this.HandlePurchase(amount);
        this.lastKnownBalance = NCF_GetPlayerMoney();
    }

    // v2.0.1: Called by the VendingMachine.BuyItems wrap below to mark
    // a 3s window during which the gate routes the next negative money
    // diff through HandlePurchase. 3s covers the asynchronous transaction
    // pipeline between the click and the money leaving the wallet.
    public final func MarkVendingPurchasePending() -> Void {
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        this.vendingPurchasePendingUntil = now + 5.0;
    }

    public final func IsVendingPurchasePending() -> Bool {
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        return now < this.vendingPurchasePendingUntil;
    }

    public final func ClearVendingPurchasePending() -> Void {
        this.vendingPurchasePendingUntil = 0.0;
    }
}

// v2.0.3: OnBuyRequest didn't fire for vending machines (proven via
// VendorEventLog: CB DIFF=-10 PASS but no VENDING WRAP fired). Vending
// machines route through MarketSystem.OnDispenseRequest with the request's
// shouldPay flag controlling whether money leaves the wallet (paid snack
// dispense vs free quest dispense). Wrap that handler instead.
//
// Same isVendorOpen guard as before: regular vendors set the flag during
// FullscreenVendor's OnInitialize, so any OnDispenseRequest while a vendor
// is open belongs to that vendor's session and gets handled by the
// existing per-event accumulator. Only set the vending pending flag when
// !isVendorOpen AND shouldPay — that's a real vending-machine purchase.
@wrapMethod(MarketSystem)
public func OnDispenseRequest(request: ref<DispenseRequest>) -> Void {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) && IsDefined(request) && request.shouldPay && !sys.IsVendorCurrentlyOpen() {
        sys.MarkVendingPurchasePending();
        sys.DiagLogEvent("VENDING WRAP fired (OnDispenseRequest, paid)");
    }
    wrappedMethod(request);
}

public class NCFMoneyPollCallback extends DelayCallback {
    public func Call() -> Void {
        let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
        if IsDefined(sys) {
            sys.OnMoneyPoll();
            sys.RegisterMoneyPoll();
        }
    }
}

public class NCFPeriodicCallback extends DelayCallback {
    public func Call() -> Void {
        let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
        if IsDefined(sys) {
            sys.OnPeriodicUpdate();
            sys.RegisterPeriodicCheck();
        }
    }
}
