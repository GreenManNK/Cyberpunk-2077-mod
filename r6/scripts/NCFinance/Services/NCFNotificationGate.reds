// -----------------------------------------------------------------------------
// NCFNotificationGate
// -----------------------------------------------------------------------------
//
// Controls the yellow "TRANSFER €$" eddies popup (the native item-transfer
// notification fired from CurrencyChangeInventoryCallback.OnItemQuantityChanged
// → ItemsNotificationQueue.PushCurrencyNotification(diff, total)).
//
// Two modes via two flags set just before our money operations:
//
//   1. SuppressNext()
//      The next money-change callback skips the popup entirely. Used for
//      our credit-removal RemoveItem on vendor close so the player doesn't
//      see a misleading TRANSFER €$ -7500 when settling the credit line.
//
//   2. SetPendingCustomDiff(diff)
//      The next money-change callback pushes a CUSTOM diff value to the
//      popup queue (yellow TRANSFER €$ +diff) instead of the real one. Used
//      for our credit-injection GiveItem on vendor open so the player sees
//      the credit-line amount appear as a familiar yellow popup that
//      RENDERS DURING THE MENU TRANSITION (unlike SimpleScreenMessage which
//      gets queued behind it).
//
// Architecture pattern matches EddiesNotificationFix (Nexus 16420): we
// @wrapMethod the same callback. EddiesNotificationFix's wrap REPLACES the
// behavior (only pushes for money items). Our wrap also makes its decision
// independently of wrappedMethod(), we either push our own custom value
// directly, suppress, or fall through to wrappedMethod() for normal flow.
// Result: works both with and without EddiesNotificationFix installed.

module NightCityFinance.Services

import NightCityFinance.Main.NCFMainSystem

public class NCFNotificationGate extends ScriptableSystem {
    private let m_suppressCount: Int32;
    private let m_pendingCustomDiff: Int32;

    public final static func GetInstance(gameInstance: GameInstance) -> ref<NCFNotificationGate> {
        return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityFinance.Services.NCFNotificationGate") as NCFNotificationGate;
    }

    public final static func Get() -> ref<NCFNotificationGate> {
        return NCFNotificationGate.GetInstance(GetGameInstance());
    }

    public final func SuppressNext() -> Void {
        this.m_suppressCount += 1;
    }

    public final func SetPendingCustomDiff(diff: Int32) -> Void {
        this.m_pendingCustomDiff = diff;
    }

    // 0 = pass through, 1 = suppress, 2 = custom (yields outDiff)
    public final func ConsumeIntent(out outDiff: Int32) -> Int32 {
        if this.m_pendingCustomDiff != 0 {
            outDiff = this.m_pendingCustomDiff;
            this.m_pendingCustomDiff = 0;
            if this.m_suppressCount > 0 { this.m_suppressCount -= 1; }
            return 2;
        }
        if this.m_suppressCount > 0 {
            this.m_suppressCount -= 1;
            return 1;
        }
        return 0;
    }
}

@wrapMethod(CurrencyChangeInventoryCallback)
public func OnItemQuantityChanged(item: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void {
    if !ItemID.IsOfTDBID(item, t"Items.money") {
        wrappedMethod(item, diff, total, flaggedAsSilent);
        return;
    }

    let gate: ref<NCFNotificationGate> = NCFNotificationGate.Get();
    if !IsDefined(gate) {
        wrappedMethod(item, diff, total, flaggedAsSilent);
        return;
    }

    let customDiff: Int32 = 0;
    let action: Int32 = gate.ConsumeIntent(customDiff);

    let mainSys: ref<NCFMainSystem> = NCFMainSystem.Get();

    switch action {
        case 1:
            if IsDefined(mainSys) { mainSys.DiagLogEvent("CB diff=" + ToString(diff) + " SUPPRESSED"); }
            return;
        case 2:
            if IsDefined(mainSys) { mainSys.DiagLogEvent("CB diff=" + ToString(diff) + " CUSTOM=" + ToString(customDiff)); }
            if IsDefined(this.m_notificationQueue) {
                this.m_notificationQueue.PushCurrencyNotification(customDiff, total);
            }
            return;
        default:
            // v1.0.38: when vendor is open and this is NOT one of our own
            // suppressed deductions, accumulate into the per-session vendor
            // totals. OnVendorClosed will route accumulated sells through
            // HandleIncome and accumulated buys through HandlePurchase
            // — separately, so mixed buy+sell sessions tax both sides
            // correctly instead of collapsing into a poll-aggregated net.
            if IsDefined(mainSys) && mainSys.IsVendorCurrentlyOpen() {
                if diff > 0 {
                    mainSys.RecordVendorSell(diff);
                } else if diff < 0 {
                    mainSys.RecordVendorBuy(-diff);
                }
            }
            // v2.0.1: vending machines aren't FullscreenVendorGameController,
            // so isVendorOpen stays false during their purchases. The
            // VendingMachine.BuyItems wrap sets a 3s pending flag; if a
            // negative money diff lands here while that flag is fresh,
            // route it straight to HandlePurchase so sales tax applies.
            // The vanilla TRANSFER popup still fires (wrappedMethod below)
            // so the player sees the snack price they actually paid.
            if IsDefined(mainSys) && diff < 0 && !mainSys.IsVendorCurrentlyOpen() && mainSys.IsVendingPurchasePending() {
                mainSys.DiagLogEvent("CB diff=" + ToString(diff) + " VENDING ROUTE");
                mainSys.RecordVendingPurchase(-diff);
                mainSys.ClearVendingPurchasePending();
            }
            if diff > 0 {
                let main: ref<NCFMainSystem> = NCFMainSystem.Get();
                if IsDefined(main) {
                    let isVendor: Bool = main.IsVendorCurrentlyOpen();
                    let deduction: Int32 = main.ComputeExpectedDeduction(diff, isVendor);
                    if deduction > 0 && deduction < diff {
                        let netDiff: Int32 = diff - deduction;
                        let netTotal: Uint32 = total - Cast<Uint32>(deduction);
                        main.DiagLogEvent("CB diff=" + ToString(diff) + " PREVIEW net=" + ToString(netDiff) + " ded=" + ToString(deduction));
                        if IsDefined(this.m_notificationQueue) {
                            this.m_notificationQueue.PushCurrencyNotification(netDiff, netTotal);
                        }
                        return;
                    }
                }
            }
            if IsDefined(mainSys) { mainSys.DiagLogEvent("CB diff=" + ToString(diff) + " PASS"); }
            wrappedMethod(item, diff, total, flaggedAsSilent);
            return;
    }
}
