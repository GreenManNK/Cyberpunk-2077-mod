// -----------------------------------------------------------------------------
// NCFFinanceState
// -----------------------------------------------------------------------------
//
// - Single source of truth for all financial state.
// - All persistent fields survive save/load cycles.
// - Both the economy hooks and the UI read from this object.
//

module NightCityFinance.Core

import NightCityFinance.Logging.*
import NightCityFinance.Settings.*
import NightCityFinance.Utils.*

public class NCFFinanceState extends ScriptableSystem {
    // --- Debt ---
    private persistent let debt: Int32;

    // --- Lifetime Tracking (for financial report widget) ---
    private persistent let totalIncomeTaxPaid: Int32;
    private persistent let totalSalesTaxPaid: Int32;
    private persistent let totalFixerCutsPaid: Int32;
    // v2.0.4: NCPD bribery feature was never implemented; the setting and
    // RecordBribe path were removed. Field kept as save-compat ghost so
    // existing saves with this field deserialize cleanly. Always 0 in
    // current builds.
    private persistent let totalBribesPaid: Int32;
    private persistent let totalInterestPaid: Int32;
    private persistent let totalGrossIncome: Int32;

    // --- Current Period Tracking (resets every 24h game time) ---
    private persistent let periodIncomeTaxPaid: Int32;
    private persistent let periodSalesTaxPaid: Int32;
    private persistent let periodFixerCutsPaid: Int32;
    private persistent let periodGrossIncome: Int32;
    private persistent let periodNetIncome: Int32;
    private persistent let lastReportDay: Int32;

    // --- Loan Shark State (separate from card debt) ---
    private persistent let activeLoanAmount: Int32;
    private persistent let activeLoanInterestRate: Int32;
    private persistent let loanTakenOnDay: Int32;
    private persistent let loanDueOnDay: Int32;
    private persistent let hasActiveLoan: Bool;

    // --- Loan Shark Ambush (v0.16.0) ---
    // lastLoanSharkPaymentDay: set whenever player pays via phone. -999 = never paid.
    // lastLoanSharkAmbushDay: set when an ambush triggers. Cooldown gate.
    // loanSharkAmbushPending: set TRUE by Redscript daily check when threshold trips,
    //   read by CET on every poll, set FALSE by CET when the ambush successfully spawns.
    private persistent let lastLoanSharkPaymentDay: Int32;
    private persistent let lastLoanSharkAmbushDay: Int32;
    private persistent let loanSharkAmbushPending: Bool;

    // --- Daily Payment Schedule ---
    private persistent let nextCardPaymentDay: Int32;
    private persistent let nextLoanPaymentDay: Int32;

    // --- Credit Line Status ---
    private persistent let creditLineOpen: Bool;

    public final static func GetInstance(gameInstance: GameInstance) -> ref<NCFFinanceState> {
        let instance: ref<NCFFinanceState> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityFinance.Core.NCFFinanceState") as NCFFinanceState;
        return instance;
    }

    public final static func Get() -> ref<NCFFinanceState> {
        return NCFFinanceState.GetInstance(GetGameInstance());
    }

    // --- Debt Operations ---
    public final func GetDebt() -> Int32 { return this.debt; }
    public final func HasDebt() -> Bool { return this.debt > 0; }

    public final func AddDebt(amount: Int32) -> Void {
        this.debt += amount;
        if this.nextCardPaymentDay == 0 {
            this.nextCardPaymentDay = -1;
        }
        NCFLog(this, "Debt increased by " + ToString(amount) + " -> total: " + ToString(this.debt));
    }

    public final func ReduceDebt(amount: Int32) -> Int32 {
        let applied: Int32 = amount;
        if applied > this.debt { applied = this.debt; }
        this.debt -= applied;
        NCFLog(this, "Debt reduced by " + ToString(applied) + " -> remaining: " + ToString(this.debt));
        return applied;
    }

    public final func AccrueInterest(settings: ref<NCFSettings>) -> Int32 {
        if this.debt <= 0 { return 0; }
        let interest: Int32 = NCF_CalculatePercentage(this.debt, settings.debtInterestRate);
        if interest < 1 { interest = 1; }
        this.debt += interest;
        this.totalInterestPaid += interest;
        NCFLog(this, "Interest accrued: " + ToString(interest) + " -> debt: " + ToString(this.debt));
        return interest;
    }

    // --- Income Tracking ---
    public final func RecordIncomeTax(gross: Int32, tax: Int32) -> Void {
        this.totalIncomeTaxPaid += tax;
        this.totalGrossIncome += gross;
        this.periodIncomeTaxPaid += tax;
        this.periodGrossIncome += gross;
        this.periodNetIncome += (gross - tax);
    }

    public final func RecordSalesTax(tax: Int32) -> Void {
        this.totalSalesTaxPaid += tax;
        this.periodSalesTaxPaid += tax;
    }

    public final func RecordFixerCut(cut: Int32) -> Void {
        this.totalFixerCutsPaid += cut;
        this.periodFixerCutsPaid += cut;
    }

    // --- Period Report (for widget) ---
    public final func GetPeriodReport() -> array<Int32> {
        let report: array<Int32>;
        ArrayPush(report, this.periodGrossIncome);
        ArrayPush(report, this.periodIncomeTaxPaid);
        ArrayPush(report, this.periodSalesTaxPaid);
        ArrayPush(report, this.periodFixerCutsPaid);
        ArrayPush(report, this.periodNetIncome);
        ArrayPush(report, this.debt);
        return report;
    }

    public final func GetLifetimeReport() -> array<Int32> {
        let report: array<Int32>;
        ArrayPush(report, this.totalGrossIncome);
        ArrayPush(report, this.totalIncomeTaxPaid);
        ArrayPush(report, this.totalSalesTaxPaid);
        ArrayPush(report, this.totalFixerCutsPaid);
        ArrayPush(report, this.totalInterestPaid);
        ArrayPush(report, this.debt);
        return report;
    }

    public final func ResetPeriod(currentDay: Int32) -> Void {
        this.periodIncomeTaxPaid = 0;
        this.periodSalesTaxPaid = 0;
        this.periodFixerCutsPaid = 0;
        this.periodGrossIncome = 0;
        this.periodNetIncome = 0;
        this.lastReportDay = currentDay;
    }

    public final func GetLastReportDay() -> Int32 { return this.lastReportDay; }
    public final func SetLastReportDay(day: Int32) -> Void { this.lastReportDay = day; }

    // --- Loan Operations ---
    public final func HasActiveLoan() -> Bool { return this.hasActiveLoan; }
    public final func GetActiveLoanAmount() -> Int32 { return this.activeLoanAmount; }
    public final func GetLoanDueDay() -> Int32 { return this.loanDueOnDay; }

    public final func CanTakeNewLoan() -> Bool {
        return !this.hasActiveLoan && this.activeLoanAmount <= 0;
    }

    public final func TakeLoan(amount: Int32, interestRate: Int32, currentDay: Int32, dueDays: Int32) -> Void {
        this.activeLoanAmount = amount;
        this.activeLoanInterestRate = interestRate;
        this.loanTakenOnDay = currentDay;
        this.loanDueOnDay = currentDay + dueDays;
        this.hasActiveLoan = true;
        if this.nextLoanPaymentDay == 0 {
            this.nextLoanPaymentDay = -1;
        }
        NCFLog(this, "Loan taken: " + ToString(amount) + " at " + ToString(interestRate) + "% due day " + ToString(this.loanDueOnDay));
    }

    public final func RepayLoan() -> Void {
        NCFLog(this, "Loan repaid: " + ToString(this.activeLoanAmount));
        this.activeLoanAmount = 0;
        this.activeLoanInterestRate = 0;
        this.loanTakenOnDay = 0;
        this.loanDueOnDay = 0;
        this.hasActiveLoan = false;
    }

    public final func AccrueLoanInterest() -> Int32 {
        if !this.hasActiveLoan { return 0; }
        let interest: Int32 = NCF_CalculatePercentage(this.activeLoanAmount, this.activeLoanInterestRate);
        if interest < 1 { interest = 1; }
        this.activeLoanAmount += interest;
        return interest;
    }

    // --- Credit Status ---
    public final func GetCreditLimit(settings: ref<NCFSettings>) -> Int32 {
        let streetCred: Int32 = NCF_GetStreetCredLevel();
        return streetCred * settings.creditPerStreetCred;
    }

    public final func GetAvailableCredit(settings: ref<NCFSettings>) -> Int32 {
        let avail: Int32 = this.GetCreditLimit(settings) - this.debt;
        if avail < 0 { return 0; }
        return avail;
    }

    public final func GetCardDebt() -> Int32 { return this.debt; }
    public final func GetLoanSharkDebt() -> Int32 { return this.activeLoanAmount; }

    // --- Credit Line Open/Close ---
    public final func IsCreditLineOpen() -> Bool { return this.creditLineOpen; }

    public final func OpenCreditLine() -> Void {
        this.creditLineOpen = true;
        NCFLog(this, "Credit line opened.");
    }

    public final func CloseCreditLine() -> Bool {
        if this.debt > 0 { return false; }
        this.creditLineOpen = false;
        NCFLog(this, "Credit line closed.");
        return true;
    }

    // --- Daily Payment Schedule ---
    public final func GetNextCardPaymentDay() -> Int32 { return this.nextCardPaymentDay; }
    public final func GetNextLoanPaymentDay() -> Int32 { return this.nextLoanPaymentDay; }

    public final func ScheduleNextCardPayment(day: Int32) -> Void {
        this.nextCardPaymentDay = day;
    }

    public final func ScheduleNextLoanPayment(day: Int32) -> Void {
        this.nextLoanPaymentDay = day;
    }

    public final func ResolveScheduleSentinels(currentDay: Int32) -> Void {
        if this.nextCardPaymentDay == -1 { this.nextCardPaymentDay = currentDay + 1; }
        if this.nextLoanPaymentDay == -1 { this.nextLoanPaymentDay = currentDay + 1; }
    }

    public final func CalculateCardPaymentDue(settings: ref<NCFSettings>) -> Int32 {
        if this.debt <= 0 { return 0; }
        let pct: Int32 = NCF_CalculatePercentage(this.debt, settings.cardMinPaymentPct);
        let due: Int32 = pct;
        if due < settings.cardPaymentFloor { due = settings.cardPaymentFloor; }
        if due > this.debt { due = this.debt; }
        return due;
    }

    public final func CalculateLoanPaymentDue(settings: ref<NCFSettings>) -> Int32 {
        if this.activeLoanAmount <= 0 { return 0; }
        let pct: Int32 = NCF_CalculatePercentage(this.activeLoanAmount, settings.loanMinPaymentPct);
        let due: Int32 = pct;
        if due < settings.loanPaymentFloor { due = settings.loanPaymentFloor; }
        if due > this.activeLoanAmount { due = this.activeLoanAmount; }
        return due;
    }

    public final func ReduceLoanShark(amount: Int32) -> Int32 {
        let applied: Int32 = amount;
        if applied > this.activeLoanAmount { applied = this.activeLoanAmount; }
        this.activeLoanAmount -= applied;
        if this.activeLoanAmount <= 0 { this.hasActiveLoan = false; }
        return applied;
    }

    // --- Loan Shark Ambush state (v0.16.0) ---

    public final func GetLastLoanSharkPaymentDay() -> Int32 { return this.lastLoanSharkPaymentDay; }
    public final func GetLastLoanSharkAmbushDay() -> Int32 { return this.lastLoanSharkAmbushDay; }
    public final func IsLoanSharkAmbushPending() -> Bool { return this.loanSharkAmbushPending; }

    // Called from NCFContacts when player makes a payment via phone.
    // Behavior split (v0.16.9):
    //   - Pending ambush is ALWAYS defused — paying anything makes the goons
    //     back off for the moment.
    //   - Cooldown anchor is ALWAYS bumped — V gets a grace day after paying
    //     before fresh ambush conditions can re-evaluate.
    //   - The overdue counter (lastLoanSharkPaymentDay) is ONLY reset when
    //     the loan is fully repaid. Partial payments do NOT make V "current"
    //     for the purpose of ambush gating — a real loan shark doesn't
    //     reset the clock on a token payment toward a 20k debt.
    public final func MarkLoanSharkPayment(currentDay: Int32) -> Void {
        this.loanSharkAmbushPending = false;
        this.lastLoanSharkAmbushDay = currentDay;
        if this.activeLoanAmount <= 0 {
            this.lastLoanSharkPaymentDay = currentDay;
        }
    }

    // Migration helper (v0.16.9): for saves carried over from before the
    // ambush feature shipped, loanTakenOnDay can be 0 even though there's
    // an active loan. Called from the daily tick to bootstrap the sentinel
    // so the overdue clock starts now rather than returning 0 forever.
    public final func EnsureLoanSharkSentinelInitialized(currentDay: Int32) -> Void {
        if this.activeLoanAmount > 0 && this.loanTakenOnDay == 0 {
            this.loanTakenOnDay = currentDay;
        }
    }

    // Called from NCFMainSystem daily check when threshold trips.
    public final func SetLoanSharkAmbushPending(currentDay: Int32) -> Void {
        this.loanSharkAmbushPending = true;
        this.lastLoanSharkAmbushDay = currentDay;
    }

    // Called from CET via bridge after a successful spawn.
    public final func ClearLoanSharkAmbushPending() -> Void {
        this.loanSharkAmbushPending = false;
    }

    // Days since the last payment. Returns very large number if never paid AND debt exists.
    public final func GetLoanSharkOverdueDays(currentDay: Int32) -> Int32 {
        if this.activeLoanAmount <= 0 { return 0; }
        if this.lastLoanSharkPaymentDay == 0 {
            // Never paid yet. Use loanTakenOnDay as the reference start point.
            if this.loanTakenOnDay == 0 { return 0; }
            return currentDay - this.loanTakenOnDay;
        }
        return currentDay - this.lastLoanSharkPaymentDay;
    }

    public final func AddCardPenalty(unpaidAmount: Int32, settings: ref<NCFSettings>) -> Int32 {
        let penalty: Int32 = NCF_CalculatePercentage(unpaidAmount, settings.missedPaymentPenaltyPct);
        if penalty < 1 { penalty = 1; }
        this.debt += penalty;
        return penalty;
    }

    public final func AddLoanPenalty(unpaidAmount: Int32, settings: ref<NCFSettings>) -> Int32 {
        let penalty: Int32 = NCF_CalculatePercentage(unpaidAmount, settings.missedPaymentPenaltyPct);
        if penalty < 1 { penalty = 1; }
        this.activeLoanAmount += penalty;
        return penalty;
    }

    // -------------------------------------------------------------------------
    // Amenities State
    // Tier: 0 = not subscribed, 1 = Basic, 2 = Premium
    // Grace: counts DOWN from 3 when a daily bill is missed. Suspended when 0
    // and debt > 0. Reset to 3 when bill is paid in full.
    // -------------------------------------------------------------------------
    private persistent let amenitiesTier: Int32;
    private persistent let amenitiesDebt: Int32;
    private persistent let amenitiesGraceDaysLeft: Int32;
    private persistent let lastAmenitiesBilledDay: Int32;
    private persistent let lastAmenitiesNotifiedDay: Int32;

    // v2.1: schedule fields for tunable billing cycles.
    //
    // nextAmenitiesBillDay — in-game day on which the next bill lands. On
    //   that day the period's worth of daily rate is added to debt, and
    //   this sentinel advances by `amenitiesBillingPeriodDays`. 0 = unset
    //   (legacy save or never subscribed); migrated on first periodic
    //   tick from `lastAmenitiesBilledDay + period`.
    //
    // amenitiesPrepaidDays — in-game days V has paid in advance via the
    //   phone "Pre-pay N periods" option. When a bill day arrives, prepaid
    //   days offset the charge: if prepaid >= period, no debt is added and
    //   prepaid decrements by period; otherwise the uncovered remainder
    //   bills as normal and prepaid resets to 0 (partial prepay never
    //   carries forward — it would over-complicate the math for no UX
    //   benefit since the player chose discrete period bundles).
    private persistent let nextAmenitiesBillDay: Int32;
    private persistent let amenitiesPrepaidDays: Int32;

    public final func GetAmenitiesTier() -> Int32 { return this.amenitiesTier; }
    public final func GetAmenitiesDebt() -> Int32 { return this.amenitiesDebt; }
    public final func GetAmenitiesGraceDaysLeft() -> Int32 { return this.amenitiesGraceDaysLeft; }
    public final func IsAmenitiesSubscribed() -> Bool { return this.amenitiesTier > 0; }
    public final func IsAmenitiesPremium() -> Bool { return this.amenitiesTier == 2; }
    public final func IsAmenitiesSuspended() -> Bool {
        return this.amenitiesDebt > 0 && this.amenitiesGraceDaysLeft <= 0;
    }
    public final func GetLastAmenitiesBilledDay() -> Int32 { return this.lastAmenitiesBilledDay; }
    public final func GetLastAmenitiesNotifiedDay() -> Int32 { return this.lastAmenitiesNotifiedDay; }
    public final func SetLastAmenitiesNotifiedDay(day: Int32) -> Void { this.lastAmenitiesNotifiedDay = day; }

    public final func SubscribeAmenities(tier: Int32, currentDay: Int32) -> Void {
        this.amenitiesTier = tier;
        this.amenitiesGraceDaysLeft = 3;
        this.lastAmenitiesBilledDay = currentDay;
        // v2.1: schedule the first bill one period from now. SubscribeAmenities
        // doesn't know the settings ref directly; the period is read from
        // settings at billing time, but we seed nextBillDay = currentDay + 1
        // so the legacy migration in BillAmenitiesDaily doesn't fire on a
        // fresh subscribe (the migration check is `nextBillDay == 0`).
        // Actual period spacing kicks in at the first bill day.
        this.nextAmenitiesBillDay = currentDay + 1;
        this.amenitiesPrepaidDays = 0;
        NCFLog(this, "Amenities subscribed tier=" + ToString(tier));
    }

    public final func UnsubscribeAmenities() -> Void {
        this.amenitiesTier = 0;
        // v2.1: clear schedule + prepay so re-subscribing later starts fresh
        // and doesn't accidentally back-bill from a stale nextBillDay.
        // amenitiesDebt is intentionally preserved — V still owes whatever
        // was outstanding before cancellation, can't dodge debt by cycling
        // their subscription.
        this.nextAmenitiesBillDay = 0;
        this.amenitiesPrepaidDays = 0;
        NCFLog(this, "Amenities unsubscribed");
    }

    // v2.1: period-aware billing with prepay offset + catch-up + legacy
    // migration. Function name kept ("BillAmenitiesDaily") so MainSystem's
    // ProcessAmenitiesBilling call site doesn't change — that file is over
    // the per-turn edit budget. Internal logic is fully period-aware.
    //
    // Returns the amount billed THIS call (sum across catch-up periods),
    // 0 if not subscribed or not yet due.
    //
    // Algorithm:
    //   1. Legacy migration: if nextBillDay == 0 (v2.0.x save), seed it
    //      from lastBilledDay + period. Existing subscribers get a free
    //      first period as a save-compat courtesy — better than back-billing
    //      them retroactively for days the new schedule wasn't even live.
    //   2. Catch-up loop: while currentDay >= nextBillDay, bill ONE period
    //      (with prepay offset), advance nextBillDay by period. Handles
    //      save-jump scenarios (V fast-travels and 30 days pass).
    //   3. Per-period bill: charge = period * dailyRate. Prepaid days reduce
    //      it; if prepaid covers the full period, no debt is added and the
    //      grace counter is preserved.
    //   4. Always update lastBilledDay so MainSystem's daily gate (which
    //      checks `currentDay > lastBilledDay`) keeps firing once per day.
    public final func BillAmenitiesDaily(settings: ref<NCFSettings>, currentDay: Int32) -> Int32 {
        if this.amenitiesTier <= 0 { return 0; }

        let period: Int32 = settings.amenitiesBillingPeriodDays;
        if period < 1 { period = 1; }

        // Legacy save migration: v2.0.x saves have nextAmenitiesBillDay == 0
        // because the field didn't exist yet. Seed it from the legacy
        // lastBilledDay + period, granting one free period as a courtesy.
        if this.nextAmenitiesBillDay == 0 {
            let seed: Int32 = this.lastAmenitiesBilledDay + period;
            if seed <= currentDay { seed = currentDay + period; }
            this.nextAmenitiesBillDay = seed;
            NCFLog(this, "Amenities schedule migrated: nextBillDay=" + ToString(seed));
        }

        let rate: Int32 = this.amenitiesTier == 1
            ? settings.amenitiesBasicDailyRate
            : settings.amenitiesPremiumDailyRate;

        let totalBilled: Int32 = 0;
        let safetyCounter: Int32 = 0;  // Defensive against pathological save data

        while currentDay >= this.nextAmenitiesBillDay && safetyCounter < 64 {
            safetyCounter += 1;

            let hadPriorDebt: Bool = this.amenitiesDebt > 0;

            // Apply prepay offset. If prepaid covers the FULL period, skip
            // charging entirely. If it covers some but not all (e.g. user
            // changed period setting mid-subscription, leaving stranded
            // partial prepay), credit the remaining prepaid days against
            // this bill instead of forfeiting them — more forgiving to
            // mid-game setting changes.
            if this.amenitiesPrepaidDays >= period {
                this.amenitiesPrepaidDays -= period;
                NCFLog(this, "Amenities bill skipped (prepaid): " + ToString(period) + " days consumed, " + ToString(this.amenitiesPrepaidDays) + " remain");
            } else {
                let coveredDays: Int32 = this.amenitiesPrepaidDays;
                let chargeableDays: Int32 = period - coveredDays;
                let billAmount: Int32 = rate * chargeableDays;
                this.amenitiesDebt += billAmount;
                totalBilled += billAmount;
                if hadPriorDebt && this.amenitiesGraceDaysLeft > 0 {
                    this.amenitiesGraceDaysLeft -= 1;
                }
                this.amenitiesPrepaidDays = 0;
                NCFLog(this, "Amenities billed " + ToString(billAmount) + " (period=" + ToString(period) + ", rate=" + ToString(rate) + ", prepaid offset=" + ToString(coveredDays) + ") -> debt=" + ToString(this.amenitiesDebt));
            }

            this.nextAmenitiesBillDay += period;
        }

        this.lastAmenitiesBilledDay = currentDay;
        return totalBilled;
    }

    // v2.1: Pre-pay multiple billing periods up front. Each "period" is
    // `amenitiesBillingPeriodDays` long and costs `period * dailyRate`.
    // Caller is responsible for verifying wallet sufficiency and removing
    // the eddies — this method only updates state.
    //
    // Returns the total cost (so the caller can deduct it).
    public final func CalculatePrepayCost(settings: ref<NCFSettings>, periodCount: Int32) -> Int32 {
        if this.amenitiesTier <= 0 || periodCount <= 0 { return 0; }
        let period: Int32 = settings.amenitiesBillingPeriodDays;
        if period < 1 { period = 1; }
        let rate: Int32 = this.amenitiesTier == 1
            ? settings.amenitiesBasicDailyRate
            : settings.amenitiesPremiumDailyRate;
        return periodCount * period * rate;
    }

    public final func ApplyPrepayment(settings: ref<NCFSettings>, periodCount: Int32) -> Void {
        if this.amenitiesTier <= 0 || periodCount <= 0 { return; }
        let period: Int32 = settings.amenitiesBillingPeriodDays;
        if period < 1 { period = 1; }
        this.amenitiesPrepaidDays += periodCount * period;
        NCFLog(this, "Amenities prepaid " + ToString(periodCount) + " periods (+" + ToString(periodCount * period) + " days), total prepaid=" + ToString(this.amenitiesPrepaidDays));
    }

    public final func GetAmenitiesPrepaidDays() -> Int32 { return this.amenitiesPrepaidDays; }
    public final func GetNextAmenitiesBillDay() -> Int32 { return this.nextAmenitiesBillDay; }

    // Add to amenities debt directly (e.g. suspended use fee that couldn't be paid).
    public final func AddAmenitiesDebt(amount: Int32) -> Void {
        this.amenitiesDebt += amount;
    }

    // Pay amenities bill. Returns amount actually applied.
    public final func PayAmenities(amount: Int32) -> Int32 {
        let applied: Int32 = amount;
        if applied > this.amenitiesDebt { applied = this.amenitiesDebt; }
        this.amenitiesDebt -= applied;
        if this.amenitiesDebt <= 0 {
            this.amenitiesDebt = 0;
            this.amenitiesGraceDaysLeft = 3;
        }
        NCFLog(this, "Amenities paid " + ToString(applied) + " -> debt=" + ToString(this.amenitiesDebt));
        return applied;
    }
}
