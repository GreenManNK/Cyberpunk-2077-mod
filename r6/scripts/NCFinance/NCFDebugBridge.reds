// -----------------------------------------------------------------------------
// NCFDebugBridge, CET-callable test functions
// -----------------------------------------------------------------------------
//
// Lives at global scope (NO `module` declaration) so CET's Game.<n>
// proxy can find these functions in the flat RTTI namespace.
//
// Usage from CET console:
//   Game.NCF_PushBankStatus()
//   Game.NCF_PushLoanSharkStatus()
//   Game.NCF_AddCardDebt(2500)
//   Game.NCF_AddLoanSharkDebt(5000)
//   Game.NCF_ScheduleNextPayment(1)
//   Game.NCF_ClearAllDebt()

import NightCityFinance.Core.*
import NightCityFinance.Main.*
import NightCityFinance.Settings.*
import NightCityFinance.Phone.*
import PhoneExtension.System.*

public static func NCF_PushBankStatus() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(state) || !IsDefined(settings) { return false; }

    let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
    if !IsDefined(ncfPhone) || !ncfPhone.IsPhoneReady() { return false; }

    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }

    let cardDebt: Int32 = state.GetCardDebt();
    let body: String = "";
    if cardDebt > 0 {
        let due: Int32 = state.CalculateCardPaymentDue(settings);
        body = "Daily statement: " + ToString(due) + " €$ due today.";
    } else {
        body = "Account in good standing. 0 €$ owed.";
    }
    ncfPhone.MarkBankActivity();
    phoneExt.NotifyNewMessageCustom(NCFBankContactHash(), "First Bank of NC", body);
    return true;
}

public static func NCF_PushLoanSharkStatus() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(state) || !IsDefined(settings) { return false; }

    let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
    if !IsDefined(ncfPhone) || !ncfPhone.IsPhoneReady() { return false; }

    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }

    let loanDebt: Int32 = state.GetLoanSharkDebt();
    let body: String = "";
    if loanDebt > 0 {
        let due: Int32 = state.CalculateLoanPaymentDue(settings);
        body = "You owe me " + ToString(due) + " €$ today, choom.";
    } else {
        body = "Don't be a stranger.";
    }
    ncfPhone.MarkLoanSharkActivity();
    phoneExt.NotifyNewMessageCustom(NCFLoanSharkContactHash(), "Loan Shark", body);
    return true;
}

public static func NCF_AddCardDebt(amount: Int32) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    state.AddDebt(amount);
    if state.GetNextCardPaymentDay() == 0 {
        state.ScheduleNextCardPayment(1);
    }
    return true;
}

public static func NCF_AddLoanSharkDebt(amount: Int32) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(state) || !IsDefined(settings) { return false; }
    state.TakeLoan(amount, settings.loanInterestRate, 0, 7);
    if state.GetNextLoanPaymentDay() == 0 {
        state.ScheduleNextLoanPayment(1);
    }
    return true;
}

public static func NCF_ScheduleNextPayment(daysFromNow: Int32) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    if state.GetCardDebt() > 0 { state.ScheduleNextCardPayment(daysFromNow); }
    if state.GetLoanSharkDebt() > 0 { state.ScheduleNextLoanPayment(daysFromNow); }
    return true;
}

public static func NCF_ClearAllDebt() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    state.ReduceDebt(state.GetCardDebt());
    state.ReduceLoanShark(state.GetLoanSharkDebt());
    state.ScheduleNextCardPayment(0);
    state.ScheduleNextLoanPayment(0);
    return true;
}

// Amenities debug helpers
public static func NCF_SubscribeAmenities(tier: Int32) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
    state.SubscribeAmenities(tier, currentDay);
    return true;
}

public static func NCF_UnsubscribeAmenities() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    state.UnsubscribeAmenities();
    return true;
}

public static func NCF_AddAmenitiesDebt(amount: Int32) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    // Simulate a missed payment by directly billing
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(settings) { return false; }
    let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
    state.BillAmenitiesDaily(settings, currentDay);
    return true;
}

public static func NCF_ClearAmenitiesDebt() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    state.PayAmenities(state.GetAmenitiesDebt());
    return true;
}

public static func NCF_AmenitiesStatus() -> String {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return "state unavailable"; }
    return "tier=" + ToString(state.GetAmenitiesTier())
        + " debt=" + ToString(state.GetAmenitiesDebt())
        + " grace=" + ToString(state.GetAmenitiesGraceDaysLeft())
        + " suspended=" + ToString(state.IsAmenitiesSuspended());
}


// Diagnose why amenities blocking might not be firing
public static func NCF_TestBlockAmenities() -> String {
    let player: ref<PlayerPuppet> = GameInstance
        .GetPlayerSystem(GetGameInstance())
        .GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) { return "FAIL: no player"; }
    let bb: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(bb) { return "FAIL: no blackboard"; }
    let zone: Int32 = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones);
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return "FAIL: no state"; }
    let subscribed: Bool = state.IsAmenitiesSubscribed();
    let suspended: Bool = state.IsAmenitiesSuspended();
    return "zone=" + ToString(zone)
        + " subscribed=" + ToString(subscribed)
        + " suspended=" + ToString(suspended)
        + " wouldBlock=" + ToString(zone < 3 && subscribed && suspended);
}

// -----------------------------------------------------------------------------
// Loan Shark Ambush bridge (v0.16.0)
// Called from bin/x64/plugins/cyber_engine_tweaks/mods/NightCityFinance/init.lua
// -----------------------------------------------------------------------------

// Returns true if the daily check has armed an ambush that hasn't fired yet.
public static func NCF_LoanSharkAmbushPending() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    return state.IsLoanSharkAmbushPending();
}

// Called by CET after a successful spawn to clear the pending flag.
public static func NCF_LoanSharkAmbushFired() -> Void {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if IsDefined(state) { state.ClearLoanSharkAmbushPending(); }
}

// Returns 1 if safe to spawn an ambush, 0 otherwise. CET checks this.
//
// "Safe to spawn" means:
//   - Not in a cinematic/scene (SceneTier <= 1 = gameplay, >=2 = scene)
//   - Not in a lore animation scene (IsInLoreAnimationScene = scripted set-piece
//     even when SceneTier reads as gameplay; e.g. some Phantom Liberty intros)
//   - Not mounted in a vehicle
//   - Not in a workspot (sitting/showering/etc.)
//   - Not in a minigame (hacking, BD, etc.)
//   - Not carrying a body (V is locked into a slow walk; ambush would soft-lock)
//
// We deliberately do NOT check Zones (security zone) — that's a different
// concept (SAFE/RESTRICTED/DANGEROUS zones for crime). Most of Night City
// is "outdoor" in the player sense regardless of security zone.
public static func NCF_PlayerIsOutdoorSafe() -> Int32 {
    let player: ref<PlayerPuppet> = GameInstance
        .GetPlayerSystem(GetGameInstance())
        .GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) { return 0; }
    let bb: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(bb) { return 0; }

    // SceneTier > 1 = in a cinematic. Don't ambush mid-scene.
    let sceneTier: Int32 = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier);
    if sceneTier > 1 { return 0; }

    // Scripted lore animation (some scenes leave SceneTier at 1 but lock the
    // player into a set-piece animation). Hard-block.
    let inLoreScene: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInLoreAnimationScene);
    if inLoreScene { return 0; }

    // Mounted in a vehicle.
    let mounted: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
    if mounted { return 0; }

    // In a workspot (toilet, shower, sitting, etc.).
    let workspot: Int32 = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot);
    if workspot > 0 { return 0; }

    // In a minigame (hacking, BD, arcade).
    let minigame: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInMinigame);
    if minigame { return 0; }

    // Carrying a body (locked slow-walk; an ambush would soft-lock V).
    let carrying: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
    if carrying { return 0; }

    return 1;
}

// Test trigger for development. Forces the pending flag without conditions.
public static func NCF_DebugForceLoanSharkAmbush() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    let day: Int32 = GameInstance.GetGameTime(GetGameInstance()).Days();
    state.SetLoanSharkAmbushPending(day);
    return true;
}

// Diagnostic: push the current ambush gating state to a screen message so the
// user can see at a glance which condition (if any) is blocking the ambush.
// Usage from CET: Game.NCF_LoanSharkAmbushStatus()
public static func NCF_LoanSharkAmbushStatus() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(state) || !IsDefined(settings) { return false; }

    let currentDay: Int32 = GameInstance.GetGameTime(GetGameInstance()).Days();
    let debt: Int32 = state.GetLoanSharkDebt();
    let overdue: Int32 = state.GetLoanSharkOverdueDays(currentDay);
    let lastAmbush: Int32 = state.GetLastLoanSharkAmbushDay();
    let lastPaid: Int32 = state.GetLastLoanSharkPaymentDay();
    let pending: Bool = state.IsLoanSharkAmbushPending();
    let hasLoan: Bool = state.HasActiveLoan();

    let line: String = "Ambush state: enabled=" + ToString(settings.loanSharkAmbushEnabled)
        + " hasLoan=" + ToString(hasLoan)
        + " debt=" + ToString(debt) + "/" + ToString(settings.loanSharkAmbushDebtThreshold)
        + " overdue=" + ToString(overdue) + "/" + ToString(settings.loanSharkAmbushDaysThreshold)
        + " day=" + ToString(currentDay) + " lastPaid=" + ToString(lastPaid)
        + " lastAmbush=" + ToString(lastAmbush) + " pending=" + ToString(pending);

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 12.0;
    msg.message = line;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
            ToVariant(msg), true);
    return true;
}

// v1.0.6: force-fire today's daily phone notifications (bank + loan +
// amenities). Calls the same push path as the daily tick, immediately,
// regardless of whether the day-rollover sentinel has tripped. Use
// when testing reminder text or popup behavior — no need to wait for
// in-game midnight to roll over.
//
// Returns true if the push had a chance to fire (phone ready, etc.).
// Whether the *amenities* line specifically fired depends on the
// subscription state at call time — check NCF_AmenitiesPopupStatus
// first if uncertain.
public static func NCF_ForceAmenitiesReminder() -> Bool {
    let mainSys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if !IsDefined(mainSys) { return false; }
    return mainSys.PushDailyPhoneNotifications();
}

// v1.0.6: also rewind the day-sentinel so the next OnPeriodicUpdate
// (60s) re-fires the daily push naturally. Use when the immediate
// force-fire above produced no popup and you suspect a phone-readiness
// race — this lets the polling tick catch up on its own schedule.
public static func NCF_RewindDailyReportSentinel() -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    let now: GameTime = GetGameInstance().GetGameTime();
    let currentDay: Int32 = now.Days();
    state.SetLastReportDay(currentDay - 1);
    return true;
}

// v1.0.5 — popup diagnostic suite. The amenities reminder lands in the
// thread but no HUD toast fires. These probes isolate where the popup
// pipeline breaks. Run all four from CET console and report which pop:
//
//   Game.NCF_PopupProbeBank()       -> uses bank hash + bank title
//   Game.NCF_PopupProbeLoan()       -> uses loan hash + loan title
//   Game.NCF_PopupProbeAmenities()  -> uses amenities hash + amenities title
//   Game.NCF_PopupProbeAmenitiesViaBank() -> amenities title PUSHED THROUGH
//                                            the bank hash. If THIS pops but
//                                            NCF_PopupProbeAmenities does not,
//                                            the amenities hash is the bug.
//
// All four return Bool: true = call dispatched, false = phoneExt was null.
// Returning true does NOT prove the popup rendered — the user has to watch
// the screen.

public static func NCF_PopupProbeBank() -> Bool {
    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }
    phoneExt.NotifyNewMessageCustom(NCFBankContactHash(), "First Bank of NC", "PROBE: bank popup test.");
    return true;
}

public static func NCF_PopupProbeLoan() -> Bool {
    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }
    phoneExt.NotifyNewMessageCustom(NCFLoanSharkContactHash(), "Loan Shark", "PROBE: loan popup test.");
    return true;
}

public static func NCF_PopupProbeAmenities() -> Bool {
    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }
    phoneExt.NotifyNewMessageCustom(NCFAmenitiesContactHash(), "NC Amenities Corp", "PROBE: amenities popup test.");
    return true;
}

public static func NCF_PopupProbeAmenitiesViaBank() -> Bool {
    let player: ref<GameObject> = GetPlayerObjectGlobal();
    if !IsDefined(player) { return false; }
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
    if !IsDefined(phoneExt) { return false; }
    // Amenities body but routed through bank's hash — proves whether the
    // hash itself is what's blocking the popup.
    phoneExt.NotifyNewMessageCustom(NCFBankContactHash(), "NC Amenities Corp", "PROBE: amenities-via-bank.");
    return true;
}

// Status dump for amenities registration state. Prints to a screen
// message because the CET console doesn't show all redscript output
// reliably across all setups.
public static func NCF_AmenitiesPopupStatus() -> Bool {
    let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(ncfPhone) || !IsDefined(state) { return false; }

    let phoneReady: String = ncfPhone.IsPhoneReady() ? "yes" : "NO";
    let amReg: String = ncfPhone.IsAmenitiesRegistered() ? "yes" : "NO";
    let bankReg: String = ncfPhone.IsBankRegistered() ? "yes" : "NO";
    let loanReg: String = ncfPhone.IsLoanSharkRegistered() ? "yes" : "NO";
    let aiReg: String = ncfPhone.IsAIRegistered() ? "yes" : "NO";
    let tier: Int32 = state.GetAmenitiesTier();
    let debt: Int32 = state.GetAmenitiesDebt();

    let line: String = "phoneReady=" + phoneReady + " bank=" + bankReg + " loan=" + loanReg
        + " amen=" + amReg + " ai=" + aiReg
        + " tier=" + ToString(tier) + " debt=" + ToString(debt);

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 12.0;
    msg.message = line;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
            ToVariant(msg), true);
    return true;
}

// -----------------------------------------------------------------------------
// Credit-state diagnostic (v1.0.30)
//
// Helps reproduce the "credit multiplied after exiting vendor" Nexus report
// that we couldn't replicate locally. Paints a 15s SimpleScreenMessage with
// the current injection state so a player can screenshot before/after a
// suspect ripperdoc visit and post it for diagnosis.
// -----------------------------------------------------------------------------
public static func NCF_CreditDebugStatus() -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(sys) || !IsDefined(state) { return false; }

    let lineOpen: String = state.IsCreditLineOpen() ? "yes" : "no";
    let injected: Int32 = sys.GetInjectedCreditAmount();
    let real: Int32 = sys.GetRealPlayerMoney();
    let cardDebt: Int32 = state.GetCardDebt();

    let line: String = "creditOpen=" + lineOpen + " injected=" + ToString(injected)
        + " realWallet=" + ToString(real) + " cardDebt=" + ToString(cardDebt);

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 15.0;
    msg.message = line;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
            ToVariant(msg), true);
    return true;
}

// -----------------------------------------------------------------------------
// NCF_VendorDebugStatus (v1.0.34 diagnostic)
//
// Dumps the vendor-flow runtime state so we can tell at a glance which path
// is firing (or NOT firing) for a given transaction. Run AT the vendor or
// IMMEDIATELY after a transaction.
//
// Reads:
//   - isVendorOpen             — did our wraps catch the controller?
//   - secs since vendor open   — when did OnInitialize last fire?
//   - secs since vendor close  — and OnUninitialize?
//   - last delta               — last wallet change OnMoneyPoll saw
//   - secs since last delta    — when (so we know it's THIS transaction)
//   - delta-was-vendor         — was isVendorOpen set when delta was seen?
//   - last income amount/tax/secs   — did HandleIncome fire? what tax?
//   - last purchase amount/tax/secs — did HandlePurchase fire? what tax?
//   - secs since deduction event    — was the BLUE income popup dispatched?
//   - secs since salestax event     — was the BLUE sales-tax popup dispatched?
//   - tax rates                — sanity check current settings
//
// 30s window so we have time to read it all on one screenshot.
// -----------------------------------------------------------------------------
public static func NCF_VendorDebugStatus() -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(sys) || !IsDefined(settings) { return false; }

    let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
    let isOpen: String = sys.IsVendorCurrentlyOpen() ? "yes" : "no";

    let openedAt: Float = sys.DiagGetVendorOpenedTime();
    let closedAt: Float = sys.DiagGetVendorClosedTime();
    let openedAgo: String = openedAt > 0.0 ? ToString(now - openedAt) : "never";
    let closedAgo: String = closedAt > 0.0 ? ToString(now - closedAt) : "never";

    let dT: Float = sys.DiagGetLastDeltaTime();
    let deltaAgo: String = dT > 0.0 ? ToString(now - dT) : "never";
    let deltaVendor: String = sys.DiagGetLastDeltaWasVendor() ? "yes" : "no";

    let incT: Float = sys.DiagGetLastIncomeTime();
    let incAgo: String = incT > 0.0 ? ToString(now - incT) : "never";
    let purT: Float = sys.DiagGetLastPurchaseTime();
    let purAgo: String = purT > 0.0 ? ToString(now - purT) : "never";

    let dedT: Float = sys.DiagGetLastDeductionEventTime();
    let dedAgo: String = dedT > 0.0 ? ToString(now - dedT) : "never";
    let stT: Float = sys.DiagGetLastSalesTaxEventTime();
    let stAgo: String = stT > 0.0 ? ToString(now - stT) : "never";

    let line: String =
        "vendorOpen=" + isOpen + " delta=" + ToString(sys.DiagGetLastDelta()) + " deltaV=" + deltaVendor
        + "\ninc amt=" + ToString(sys.DiagGetLastIncomeAmount()) + " tax=" + ToString(sys.DiagGetLastIncomeTax()) + " ago=" + incAgo + "s"
        + "\npur amt=" + ToString(sys.DiagGetLastPurchaseAmount()) + " tax=" + ToString(sys.DiagGetLastPurchaseTax()) + " ago=" + purAgo + "s"
        + "\nrates inc=" + ToString(settings.incomeTaxRate) + "% sls=" + ToString(settings.salesTaxRate) + "%";

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 30.0;
    msg.message = line;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
            ToVariant(msg), true);
    return true;
}

// -----------------------------------------------------------------------------
// NCF_VendorEventLog (v1.0.37) — separate dump for the per-event ring buffer.
// SimpleScreenMessage hard-caps at ~4 lines, so we split the diagnostic.
// Run AFTER NCF_VendorDebugStatus to see the chronological event trace.
// -----------------------------------------------------------------------------
public static func NCF_VendorEventLog() -> Bool {
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if !IsDefined(sys) { return false; }

    // Pack 5 entries into 4 lines: newest gets its own line, then pairs.
    // Actually 4 entries per popup; show newest 3 with index labels.
    let l0: String = sys.DiagGetEventLog0();
    let l1: String = sys.DiagGetEventLog1();
    let l2: String = sys.DiagGetEventLog2();
    let l3: String = sys.DiagGetEventLog3();

    if StrLen(l0) == 0 { l0 = "(empty)"; }
    if StrLen(l1) == 0 { l1 = "(empty)"; }
    if StrLen(l2) == 0 { l2 = "(empty)"; }
    if StrLen(l3) == 0 { l3 = "(empty)"; }

    let line: String =
        "0: " + l0
        + "\n1: " + l1
        + "\n2: " + l2
        + "\n3: " + l3;

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 30.0;
    msg.message = line;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
            ToVariant(msg), true);
    return true;
}
