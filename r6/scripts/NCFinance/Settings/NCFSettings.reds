// -----------------------------------------------------------------------------
// NCFSettings
// -----------------------------------------------------------------------------
//
// - Mod Settings integration. The public fields below are scanned by Mod
//   Settings via @runtimeProperty annotations (documented at the Mod
//   Settings Nexus page).
// - Consumers read settings directly from this system on demand; no
//   change-detection layer is needed because the values are read fresh
//   at every use-site.
//

module NightCityFinance.Settings

import NightCityFinance.Logging.*

// Mod Settings registration — guarded so the mod compiles and runs even
// if Mod Settings is not installed. This @if(ModuleExists(...)) pattern
// is the documented Mod Settings integration approach.
@if(ModuleExists("ModSettingsModule"))
public func RegisterNCFSettingsListener(listener: ref<IScriptable>) {
    ModSettings.RegisterListenerToClass(listener);
    ModSettings.RegisterListenerToModifications(listener);
}
@if(ModuleExists("ModSettingsModule"))
public func UnregisterNCFSettingsListener(listener: ref<IScriptable>) {
    ModSettings.UnregisterListenerToClass(listener);
    ModSettings.UnregisterListenerToModifications(listener);
}
@if(!ModuleExists("ModSettingsModule"))
public func RegisterNCFSettingsListener(listener: ref<IScriptable>) {}
@if(!ModuleExists("ModSettingsModule"))
public func UnregisterNCFSettingsListener(listener: ref<IScriptable>) {}

public class NCFSettings extends ScriptableSystem {
    private let debugEnabled: Bool = true;

    public final static func GetInstance(gameInstance: GameInstance) -> ref<NCFSettings> {
        return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityFinance.Settings.NCFSettings") as NCFSettings;
    }
    public final static func Get() -> ref<NCFSettings> {
        return NCFSettings.GetInstance(GetGameInstance());
    }
    private func OnDetach() -> Void { UnregisterNCFSettingsListener(this); }

    public func Init(attachedPlayer: ref<PlayerPuppet>) -> Void {
        RegisterNCFSettingsListener(this);
    }

    // Mod Settings invokes this on any value change. We don't introspect
    // which value changed — consumers re-read on demand. Settings flagged
    // [reload required] in the UI are read at registration time and won't
    // pick up live edits without a save reload, by design.
    public func OnModSettingsChange() -> Void {}

    // -------------------------------------------------------------------------
    // Notifications (v1.0.17)
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Notifications")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "Show Tax Report Popup")
    @runtimeProperty("ModSettings.description", "Show the income tax breakdown popup. Wallet still updates when off.")
    public let showTaxReportPopup: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Notifications")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "Show Sales Tax Popup")
    @runtimeProperty("ModSettings.description", "Show the sales tax popup after vendor purchases. Tax still applies when off.")
    public let showSalesTaxPopup: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Notifications")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "Suppress Popups During Combat")
    @runtimeProperty("ModSettings.description", "Hide all NCF popups during combat and for 10 seconds after.")
    public let suppressPopupsInCombat: Bool = true;

    // v2.0.5: master switch to skip income/purchase routing while V is in
    // a braindance, scripted cutscene, or any other scene where wallet
    // changes come from inventory swaps rather than real player transactions
    // (Judy's BD in "The Information", the Johnny "tap on shoulder" sequences,
    // act-end cinematics, etc.). Default ON because every reported false-positive
    // tax popup traced to one of these contexts.
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Notifications")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "Skip Tax in Braindances and Cutscenes")
    @runtimeProperty("ModSettings.description", "Don't apply income or sales tax during braindances or cinematic scenes (camera locked, V can't act normally). Money that arrives across a scene is still taxed once when the scene ends. Recommended ON.")
    public let suppressInScenes: Bool = true;

    // -------------------------------------------------------------------------
    // Income Tax
    // -------------------------------------------------------------------------
    // v2.0.5: master toggle. When OFF, income tax is fully skipped regardless
    // of rate. Use this if you want loans + amenities + sales tax but no
    // income tax at all (a play style multiple users asked for).
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Income Tax")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "Enable Income Tax")
    @runtimeProperty("ModSettings.description", "Master switch for income tax. When off, no tax is taken from any income regardless of the rate slider below.")
    public let incomeTaxEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Income Tax")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "Income Tax Rate (%)")
    @runtimeProperty("ModSettings.description", "Percentage taken from gig rewards and other taxable income. Applied after fixer cuts.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "50")
    public let incomeTaxRate: Int32 = 15;

    // v2.0.5: per-pickup exemption. Income below this amount is fully
    // exempt — no income tax, no fixer cut, no garnishment, no popup.
    // Default 100 €$ exempts NCPD money shards (typically 30-150),
    // small wallet drops, and other "found money" the user feedback
    // explicitly called out as immersion-breaking to tax. Set to 0 to
    // tax everything; raise to ~500 to also exempt corpse-loot drops.
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Income Tax")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "Tax-Free Pickup Threshold (€$)")
    @runtimeProperty("ModSettings.description", "Income below this amount is fully exempt (no tax, no fixer cut, no debt collection). Set to 0 to tax everything. 100 exempts most NCPD money shards. 500+ also exempts most corpse loot.")
    @runtimeProperty("ModSettings.step", "50")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5000")
    public let incomeTaxThreshold: Int32 = 100;

    // v2.0.5: master toggle for garnishment. Independent of income tax —
    // some users want tax but no auto-debt-collection, others want neither.
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Income Tax")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "Enable Debt Garnishment on Income")
    @runtimeProperty("ModSettings.description", "When you have debt, automatically deduct a percentage of incoming money to pay it down. Off = pay debt only via the bank phone contact.")
    public let garnishmentEnabled: Bool = true;

    // -------------------------------------------------------------------------
    // Sales Tax
    // -------------------------------------------------------------------------
    // v2.0.5: master toggle. When OFF, sales tax is fully skipped at vendors.
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Sales Tax")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "Enable Sales Tax")
    @runtimeProperty("ModSettings.description", "Master switch for sales tax on vendor purchases. When off, no surcharge is added regardless of the rate slider below.")
    public let salesTaxEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Sales Tax")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "Sales Tax Rate (%)")
    @runtimeProperty("ModSettings.description", "Percentage surcharge on vendor purchases.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "30")
    public let salesTaxRate: Int32 = 8;

    // -------------------------------------------------------------------------
    // Fixer Cuts
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Fixer Cuts")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "Enable Fixer Cuts")
    @runtimeProperty("ModSettings.description", "When off, no fixer cut is taken from any income — vendor sales, gig payouts, etc. The percentage slider below has no effect when disabled.")
    public let fixerCutEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Fixer Cuts")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "Default Fixer Cut (%)")
    @runtimeProperty("ModSettings.description", "Percentage taken by fixers from gig rewards (500+ eddies). Applied before income tax.")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "50")
    public let fixerCutDefault: Int32 = 20;

    // -------------------------------------------------------------------------
    // Debt & Loans
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Daily Debt Interest Rate (%)")
    @runtimeProperty("ModSettings.description", "Interest accrues daily on outstanding debt.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "25")
    public let debtInterestRate: Int32 = 5;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Debt Garnishment Rate (%)")
    @runtimeProperty("ModSettings.description", "Percentage of income automatically deducted to repay debt.")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "10")
    @runtimeProperty("ModSettings.max", "90")
    public let debtGarnishmentRate: Int32 = 50;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Enable First Bank of NC Contact [reload required]")
    @runtimeProperty("ModSettings.description", "[!] REQUIRES SAVE RELOAD TO TAKE EFFECT. Show the First Bank of NC phone contact (manage credit line, pay card debt). When off, the contact is hidden entirely. Toggle this setting from the main menu before loading a save, OR toggle in-game then reload your save.")
    public let bankEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Enable Loan Sharks [reload required]")
    @runtimeProperty("ModSettings.description", "[!] REQUIRES SAVE RELOAD TO TAKE EFFECT. Allow borrowing eddies from loan sharks, with interest and consequences. When off, the contact is hidden entirely. Toggle this setting from the main menu before loading a save, OR toggle in-game then reload your save.")
    public let loanSharkEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Use Blake Croyle as Loan Shark [reload required]")
    @runtimeProperty("ModSettings.description", "[!] REQUIRES SAVE RELOAD TO TAKE EFFECT. Lore-flavor: while Blake Croyle (the Animals enforcer from gig 'Shark in the Water') is alive, he is your loan shark contact. After the gig is completed, the contact is automatically replaced with a generic Animals collector. Disable to use the generic 'Loan Shark' contact at all times.")
    public let useCroyleNaming: Bool = true;

    // -------------------------------------------------------------------------
    // Loan Shark Ambush (v0.16.0)
    // When debt+overdue threshold trips, Animals goons spawn near V outdoors.
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Animals Ambushes")
    @runtimeProperty("ModSettings.description", "When loan shark debt is overdue past the threshold, Blake Croyle sends Animals goons to ambush V in the open city. One ambush per overdue period (paying clears the cooldown).")
    public let loanSharkAmbushEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Ambush — Debt Threshold (€$)")
    @runtimeProperty("ModSettings.description", "Loan shark debt must be at least this amount before ambushes start. Lower = goons come sooner.")
    @runtimeProperty("ModSettings.step", "1000")
    @runtimeProperty("ModSettings.min", "1000")
    @runtimeProperty("ModSettings.max", "100000")
    public let loanSharkAmbushDebtThreshold: Int32 = 20000;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Ambush — Days Overdue")
    @runtimeProperty("ModSettings.description", "Days since the last loan payment must be at least this before ambushes start.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "30")
    public let loanSharkAmbushDaysThreshold: Int32 = 5;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Ambush — Cooldown (days)")
    @runtimeProperty("ModSettings.description", "Minimum in-game days between ambushes. 1 = one ambush per overdue day.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "14")
    public let loanSharkAmbushCooldownDays: Int32 = 1;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Enable Credit Line")
    @runtimeProperty("ModSettings.description", "Allow spending beyond your balance up to a credit limit based on Street Cred.")
    public let creditEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Credit Per Street Cred Level")
    @runtimeProperty("ModSettings.description", "Credit limit = Street Cred level x this value. At SC 50 with 500/level = 25,000 credit.")
    @runtimeProperty("ModSettings.step", "100")
    @runtimeProperty("ModSettings.min", "100")
    @runtimeProperty("ModSettings.max", "5000")
    public let creditPerStreetCred: Int32 = 500;

    // -------------------------------------------------------------------------
    // Daily Payment Policy, Credit Card
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Card Min Payment (% of balance)")
    @runtimeProperty("ModSettings.description", "Daily payment is this percentage of outstanding card debt, with a floor.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let cardMinPaymentPct: Int32 = 10;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Card Payment Floor (eddies)")
    @runtimeProperty("ModSettings.description", "Minimum eddies charged daily on card debt regardless of percentage.")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "1000")
    public let cardPaymentFloor: Int32 = 50;

    // -------------------------------------------------------------------------
    // Daily Payment Policy, Loan Shark
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Min Payment (% of balance)")
    @runtimeProperty("ModSettings.description", "Loan sharks demand a much larger daily share than the card.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let loanMinPaymentPct: Int32 = 25;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Payment Floor (eddies)")
    @runtimeProperty("ModSettings.description", "Minimum eddies charged daily on loan shark debt.")
    @runtimeProperty("ModSettings.step", "50")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "5000")
    public let loanPaymentFloor: Int32 = 200;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Daily Interest (%)")
    @runtimeProperty("ModSettings.description", "Loan shark daily compound interest. Significantly higher than card debt.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "50")
    public let loanInterestRate: Int32 = 15;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Small Loan (eddies)")
    @runtimeProperty("ModSettings.description", "Amount lent for the 'small loan' option. Always available when borrowing is enabled.")
    @runtimeProperty("ModSettings.step", "500")
    @runtimeProperty("ModSettings.min", "500")
    @runtimeProperty("ModSettings.max", "20000")
    public let loanSmallAmount: Int32 = 5000;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Medium Loan (eddies)")
    @runtimeProperty("ModSettings.description", "Amount lent for the 'medium loan' option. Requires Street Cred 10+.")
    @runtimeProperty("ModSettings.step", "1000")
    @runtimeProperty("ModSettings.min", "2000")
    @runtimeProperty("ModSettings.max", "50000")
    public let loanMediumAmount: Int32 = 15000;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Loan Shark Large Loan (eddies)")
    @runtimeProperty("ModSettings.description", "Amount lent for the 'large loan' option. Requires Street Cred 30+.")
    @runtimeProperty("ModSettings.step", "5000")
    @runtimeProperty("ModSettings.min", "10000")
    @runtimeProperty("ModSettings.max", "150000")
    public let loanLargeAmount: Int32 = 40000;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Debt and Loans")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Loan Repayment Window (days)")
    @runtimeProperty("ModSettings.description", "How many in-game days until the loan is fully due. Daily payments still apply during the window.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "3")
    @runtimeProperty("ModSettings.max", "30")
    public let loanDueDays: Int32 = 7;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "Daily Payments")
    @runtimeProperty("ModSettings.category.order", "55")
    @runtimeProperty("ModSettings.displayName", "Missed Payment Penalty (%)")
    @runtimeProperty("ModSettings.description", "If the player can't cover a payment, this percentage of the unpaid amount is added back to the balance as a fee.")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    public let missedPaymentPenaltyPct: Int32 = 25;

    // -------------------------------------------------------------------------
    // NC Amenities Corp
    // -------------------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.category.order", "75")
    @runtimeProperty("ModSettings.displayName", "Enable NC Amenities Corp Contact [reload required]")
    @runtimeProperty("ModSettings.description", "[!] REQUIRES SAVE RELOAD TO TAKE EFFECT. Adds the NC Amenities Corp phone contact for managing water, net, heating and electricity subscriptions. When off, the contact is hidden and no daily billing or suspension fees apply.")
    public let amenitiesEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Basic Plan Daily Rate (€$)")
    @runtimeProperty("ModSettings.description", "Daily cost of the Basic amenities plan (limited usage, standard services).")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "50")
    @runtimeProperty("ModSettings.max", "1000")
    public let amenitiesBasicDailyRate: Int32 = 200;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Premium Plan Daily Rate (€$)")
    @runtimeProperty("ModSettings.description", "Daily cost of the Premium amenities plan (unlimited usage, priority services).")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "100")
    @runtimeProperty("ModSettings.max", "2000")
    public let amenitiesPremiumDailyRate: Int32 = 500;

    // v2.1: tunable billing cycle. Daily rate stays the same, but the bill
    // is summed across this many in-game days and charged once per cycle.
    // Common values: 1 (daily), 7 (weekly), 14 (bi-weekly), 30 (monthly).
    // At Basic 200 €$/day with period=7, V is billed 1400 €$ every 7 days.
    // Tied to real-life utility cadence and Eviction Notice mod's monthly
    // rent rhythm (user request).
    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Billing Cycle (days)")
    @runtimeProperty("ModSettings.description", "How often NC Amenities Corp bills you. Daily rate stays the same — longer cycles just bundle the charge. Common values: 1 (daily), 7 (weekly), 14 (bi-weekly), 30 (monthly). At 200 €$/day weekly = 1400 €$/week.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "30")
    public let amenitiesBillingPeriodDays: Int32 = 1;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Suspended Shower Fee (€$/sec)")
    @runtimeProperty("ModSettings.description", "Eddies charged per second when using the shower while services are suspended. Set to 0 to disable.")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "500")
    public let amenitiesSuspendedFeePerSec: Int32 = 25;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Suspended TV Fee (€$/sec)")
    @runtimeProperty("ModSettings.description", "Eddies charged per second when watching TV while services are suspended. Set to 0 to disable.")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "500")
    public let amenitiesTvFeePerSec: Int32 = 15;

    @runtimeProperty("ModSettings.mod", "NC Living Costs, Loans & Taxes")
    @runtimeProperty("ModSettings.category", "NC Amenities Corp")
    @runtimeProperty("ModSettings.displayName", "Grace Period (days)")
    @runtimeProperty("ModSettings.description", "Days of unpaid bills before services are suspended. Debt accrues throughout.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "7")
    public let amenitiesGracePeriod: Int32 = 3;
}
