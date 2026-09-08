// -----------------------------------------------------------------------------
// NCFNotificationService
// -----------------------------------------------------------------------------
//
// - Shows tax deduction breakdowns via the game's native
//   SimpleScreenMessage system (same as quest reward popups).
// - v1.0.17: per-popup toggles (showTaxReportPopup, showSalesTaxPopup) and
//   global combat suppression (suppressPopupsInCombat).
// - v1.0.18: blackboard listener on PlayerStateMachine.Combat tracks combat
//   entry/exit transitions explicitly; suppression extends 10s past the
//   moment combat ends, so the bounty/loot tax popup that processes right
//   after the last enemy drops is also silenced. Suppressed popups are
//   dropped, not queued — wallet/state changes still happen.
// - v1.0.21: stealth/sniper/quickhack kills don't trip the Combat blackboard
//   (it only flips when an enemy is AWARE of and AGGRESSIVE toward V), so
//   bounty popups would still fire mid-stealth-massacre. Added NCFKillTracker
//   which wraps NPCPuppet.OnDeath and stamps a timestamp on every player-
//   caused kill. Suppression now consults BOTH signals: time-since-last-kill
//   (primary, catches everything) and combat-blackboard (secondary, catches
//   "being shot at without yet killing anything").
//

module NightCityFinance.Services

import NightCityFinance.Logging.*
import NightCityFinance.Settings.*
import NightCityFinance.Main.{
    NCFDeductionEvent,
    NCFSalesTaxEvent,
    NCFDebtInterestEvent,
    NCFDebtCreatedEvent,
    NCFMissedPaymentEvent
}

public class NCFNotificationService extends ScriptableService {
    // v1.0.18: combat exit cooldown. Bug from first cut: a single
    // "lastInCombatTime" only got refreshed when combat ENTERED (value
    // transitions to InCombat=1), not while combat was ongoing — so the
    // timestamp was stamped at combat start, and by the time the post-kill
    // tax popup fired, > 10s had already passed and the cooldown had no
    // effect. v1.0.18a fix: track the exit moment explicitly via the
    // listener, plus a fast-path "currently in combat" flag.
    private let inCombatNow: Bool = false;
    private let combatExitedAt: Float = 0.0;
    private let combatListenerRegistered: Bool = false;
    private let combatBlackboard: wref<IBlackboard>;

    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(
            n"NightCityFinance.Main.NCFDeductionEvent",
            this,
            n"OnDeductionEvent",
            true
        );
        GameInstance.GetCallbackSystem().RegisterCallback(
            n"NightCityFinance.Main.NCFSalesTaxEvent",
            this,
            n"OnSalesTaxEvent",
            true
        );
        GameInstance.GetCallbackSystem().RegisterCallback(
            n"NightCityFinance.Main.NCFDebtInterestEvent",
            this,
            n"OnDebtInterestEvent",
            true
        );
        GameInstance.GetCallbackSystem().RegisterCallback(
            n"NightCityFinance.Main.NCFDebtCreatedEvent",
            this,
            n"OnDebtCreatedEvent",
            true
        );
        GameInstance.GetCallbackSystem().RegisterCallback(
            n"NightCityFinance.Main.NCFMissedPaymentEvent",
            this,
            n"OnMissedPaymentEvent",
            true
        );
    }

    private cb func OnDeductionEvent(event: ref<NCFDeductionEvent>) {
        this.EnsureCombatListener();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if IsDefined(settings) && !settings.showTaxReportPopup { return; }
        if this.ShouldSuppressForCombat() { return; }

        let gross: Int32 = event.grossAmount;
        let fixer: Int32 = event.fixerCut;
        let tax: Int32 = event.incomeTax;
        let garn: Int32 = event.garnishment;
        let net: Int32 = event.netAmount;

        let msg: String = "NCTA Tax Report | Gross: " + ToString(gross);

        if fixer > 0 {
            msg += " | Fixer: -" + ToString(fixer);
        }
        if tax > 0 {
            msg += " | Tax: -" + ToString(tax);
        }
        if garn > 0 {
            msg += " | Debt: -" + ToString(garn);
        }
        msg += " | Net: " + ToString(net);

        NCFShowMessage(msg, 4.0);
    }

    private cb func OnSalesTaxEvent(event: ref<NCFSalesTaxEvent>) {
        this.EnsureCombatListener();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if IsDefined(settings) && !settings.showSalesTaxPopup { return; }
        if this.ShouldSuppressForCombat() { return; }

        let tax: Int32 = event.taxAmount;
        let purchase: Int32 = event.purchaseAmount;

        let msg: String = "NCTA Sales Tax | Purchase: " + ToString(purchase) + " | Tax: -" + ToString(tax);

        NCFShowMessage(msg, 3.0);
    }

    private cb func OnDebtInterestEvent(event: ref<NCFDebtInterestEvent>) {
        this.EnsureCombatListener();
        if this.ShouldSuppressForCombat() { return; }

        let interest: Int32 = event.interestAmount;
        let total: Int32 = event.totalDebt;

        let msg: String = "NCTA Debt Notice | Interest: +" + ToString(interest) + " | Total Debt: " + ToString(total);

        NCFShowMessage(msg, 5.0);
    }

    private cb func OnDebtCreatedEvent(event: ref<NCFDebtCreatedEvent>) {
        this.EnsureCombatListener();
        if this.ShouldSuppressForCombat() { return; }

        let added: Int32 = event.newDebtAmount;
        let total: Int32 = event.totalDebt;

        let msg: String = "NCTA Warning | Insufficient funds - " + ToString(added) + " added to debt | Total: " + ToString(total);

        NCFShowMessage(msg, 5.0);
    }

    private cb func OnMissedPaymentEvent(event: ref<NCFMissedPaymentEvent>) {
        this.EnsureCombatListener();
        if this.ShouldSuppressForCombat() { return; }

        let lender: String = Equals(event.source, "loanshark") ? "LOAN SHARK" : "FBNC CARD";
        let msg: String = lender + " | MISSED PAYMENT: " + ToString(event.unpaidAmount)
            + " unpaid | Penalty: +" + ToString(event.penaltyApplied)
            + " | Balance: " + ToString(event.newOutstanding);
        NCFShowMessage(msg, 6.0);
    }

    // Lazy-register a blackboard listener on PlayerStateMachine.Combat. We
    // can't register at OnLoad time (no player yet) so we hook on the first
    // event after the player exists. After the listener is live, the
    // OnCombatChanged callback keeps lastInCombatTime fresh — including the
    // exact moment combat ends.
    private final func EnsureCombatListener() -> Void {
        if this.combatListenerRegistered { return; }

        let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
        if !IsDefined(player) { return; }

        let bb: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
        if !IsDefined(bb) { return; }

        this.combatBlackboard = bb;
        bb.RegisterListenerInt(
            GetAllBlackboardDefs().PlayerStateMachine.Combat,
            this,
            n"OnCombatChanged",
            true
        );
        this.combatListenerRegistered = true;

        // Seed the in-combat flag if we're already in combat at registration.
        // The fireIfValueExist=true flag also fires OnCombatChanged with the
        // current value, so this is belt-and-braces but harmless.
        if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat) {
            this.inCombatNow = true;
        }
    }

    protected cb func OnCombatChanged(value: Int32) -> Bool {
        // gamePSMCombat: Default=0, InCombat=1, OutOfCombat=2, Stealth=3.
        // Track entries and exits explicitly. Stamping combatExitedAt only
        // on a true transition (was-in-combat -> not-in-combat) is what
        // makes the 10s cooldown actually start when combat ends.
        let nowInCombat: Bool = value == EnumInt(gamePSMCombat.InCombat);

        if this.inCombatNow && !nowInCombat {
            this.combatExitedAt = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        }

        this.inCombatNow = nowInCombat;
    }

    // True when the player is in combat OR within 10s of combat ending OR
    // within 10s of any kill caused by V, AND the suppress-during-combat
    // setting is enabled.
    private final func ShouldSuppressForCombat() -> Bool {
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if !IsDefined(settings) { return false; }
        if !settings.suppressPopupsInCombat { return false; }

        // Primary signal: time since last player-caused kill. This catches
        // stealth kills, sniper kills, quickhack kills, and everything else
        // that the Combat blackboard misses. See NCFKillTracker.reds for
        // the full rationale.
        let tracker: ref<NCFKillTracker> = NCFKillTracker.Get();
        if IsDefined(tracker) && tracker.SecondsSinceLastKill() < 10.0 {
            return true;
        }

        // Secondary signal: in-combat / post-combat blackboard cooldown.
        // Catches "V is being shot at but hasn't killed anything yet".
        if this.combatListenerRegistered {
            if this.inCombatNow { return true; }
            if this.combatExitedAt > 0.0 {
                let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
                if (now - this.combatExitedAt) < 10.0 { return true; }
            }
            return false;
        }

        // Listener not up yet — first event call ever, fall back to a
        // direct blackboard read. No cooldown branch here because we have
        // no exit timestamp; this only matters for the very first event.
        let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
        if !IsDefined(player) { return false; }
        let bb: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
        if !IsDefined(bb) { return false; }
        return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
    }
}

public func NCFShowMessage(message: String, opt duration: Float) -> Void {
    let warningMsg: SimpleScreenMessage;
    warningMsg.isShown = true;
    if duration > 0.0 {
        warningMsg.duration = duration;
    } else {
        warningMsg.duration = 4.0;
    }
    warningMsg.message = message;
    warningMsg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
}
