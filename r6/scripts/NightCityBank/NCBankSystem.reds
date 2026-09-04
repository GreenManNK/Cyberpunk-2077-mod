module NightCityBank

public enum NCBankLanguage {
  English = 0,
  Portuguese = 1,
  French = 2,
  ChineseSimplified = 3,
  ChineseTraditional = 4,
  German = 5,
  Spanish = 6,
  SpanishMexico = 7,
  Japanese = 8,
  Korean = 9,
  Polish = 10,
  Russian = 11,
  Turkish = 12,
  Vietnamese = 13
}

public enum NCBankLanguageSetting {
  English = 0,
  Portuguese = 1,
  French = 2,
  ChineseSimplified = 3,
  ChineseTraditional = 4,
  German = 5,
  Spanish = 6,
  Korean = 7,
  Polish = 8,
  Russian = 9,
  Turkish = 10,
  Vietnamese = 11,
  Japanese = 12
}

public class NCBankModSettings extends IScriptable {
  @runtimeProperty("ModSettings.mod", "Marmur Bank")
  @runtimeProperty("ModSettings.displayName", "Language")
  @runtimeProperty("ModSettings.description", "Selects Marmur browser, branch, ATM, and phone text. Reopen the interface after changing.")
  @runtimeProperty("ModSettings.displayValues.English", "English")
  @runtimeProperty("ModSettings.displayValues.Portuguese", "Brazilian Portuguese")
  @runtimeProperty("ModSettings.displayValues.French", "French")
  @runtimeProperty("ModSettings.displayValues.ChineseSimplified", "Simplified Chinese")
  @runtimeProperty("ModSettings.displayValues.ChineseTraditional", "Traditional Chinese")
  @runtimeProperty("ModSettings.displayValues.German", "German")
  @runtimeProperty("ModSettings.displayValues.Spanish", "Spanish")
  @runtimeProperty("ModSettings.displayValues.Korean", "Korean")
  @runtimeProperty("ModSettings.displayValues.Polish", "Polish")
  @runtimeProperty("ModSettings.displayValues.Russian", "Russian")
  @runtimeProperty("ModSettings.displayValues.Turkish", "Turkish")
  @runtimeProperty("ModSettings.displayValues.Vietnamese", "Vietnamese")
  @runtimeProperty("ModSettings.displayValues.Japanese", "Japanese")
  public let language: NCBankLanguageSetting = NCBankLanguageSetting.English;

  public let premiumThreshold: Int32 = 2000000;


  @runtimeProperty("ModSettings.mod", "Marmur Bank")
  @runtimeProperty("ModSettings.displayName", "Yield Tax")
  @runtimeProperty("ModSettings.description", "Applied only to daily bank yield")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "90")
  public let interestTaxPercent: Int32 = 15;

  public func Init() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  public func Shutdown() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }

  public cb func OnModSettingsChange() -> Void {
  }
}

public class NCBankSystem extends ScriptableSystem {

  private persistent let bankBalance: Int32;
  private persistent let bankBalanceBackup: Int32;
  private persistent let initializedTime: Bool;
  private persistent let lastInterestDay: Int32;
  private persistent let lastInterestHour: Int32;
  private persistent let totalDeposited: Int32;
  private persistent let totalWithdrawn: Int32;
  private persistent let totalInterestEarned: Int32;
  private persistent let totalPrivateClientFeesPaid: Int32;
  private persistent let recoveryCounter: Int32;
  private persistent let premiumUnlocked: Bool;
  private persistent let relationshipTier: Int32;
  private persistent let relationshipTierInitialized: Bool;
  private persistent let totalTaxPaid: Int32;
  private persistent let transactionTypes: array<Int32>;
  private persistent let transactionAmounts: array<Int32>;
  private persistent let transactionTaxes: array<Int32>;
  private persistent let transactionSubjectCodes: array<Int32>;
  private persistent let transactionProvenanceCodes: array<Int32>;
  private persistent let transactionCashbackEarned: array<Int32>;
  private persistent let transactionBankBefore: array<Int32>;
  private persistent let transactionBankAfter: array<Int32>;
  private persistent let transactionWalletBefore: array<Int32>;
  private persistent let transactionWalletAfter: array<Int32>;
  private persistent let transactionDays: array<Int32>;
  private persistent let transactionHours: array<Int32>;
  private persistent let transactionMinutes: array<Int32>;
  private persistent let transactionConfirmationLeft: array<Int32>;
  private persistent let transactionConfirmationRight: array<Int32>;
  private persistent let transactionFraudStatuses: array<Int32>;
  private persistent let transactionFraudDecisionDays: array<Int32>;
  private persistent let transactionFraudDecisionHours: array<Int32>;
  private persistent let transactionFraudDecisionMinutes: array<Int32>;
  private persistent let fraudQueueVersion: Int32;
  private persistent let transactionUnreadCount: Int32;
  private persistent let transactionSequence: Int32;
  private persistent let transactionHistoryTrimmed: Bool;
  private persistent let transactionHistoryBoundaryDay: Int32;
  private persistent let latestFraudAlertStatus: Int32;
  private persistent let latestFraudAlertAmount: Int32;
  private persistent let latestFraudAlertDay: Int32;
  private persistent let latestFraudAlertHour: Int32;
  private persistent let latestFraudAlertMinute: Int32;
  private persistent let latestFraudAlertReason: Int32;
  private persistent let lastFraudAlertDay: Int32;
  private persistent let lastFraudAlertReason: Int32;
  private persistent let lastMonthlyFeeDay: Int32;
  private persistent let monthlyFeeInitialized: Bool;
  private persistent let lastPrivateClientFeeDay: Int32;
  private persistent let privateClientFeeInitialized: Bool;

  private persistent let loanActive: Bool;
  private persistent let loanOfferIndex: Int32;
  private persistent let loanPrincipal: Int32;
  private persistent let loanOriginalDue: Int32;
  private persistent let loanBalanceDue: Int32;
  private persistent let loanInstallmentAmount: Int32;
  private persistent let loanInterestBasisPoints: Int32;
  private persistent let loanTermPayments: Int32;
  private persistent let loanPaymentsMade: Int32;
  private persistent let loanStartDay: Int32;
  private persistent let loanNextDueDay: Int32;
  private persistent let loanLastPaymentDay: Int32;
  private persistent let loanMissedPayments: Int32;
  private persistent let totalLoanBorrowed: Int32;
  private persistent let totalLoanRepaid: Int32;

  private let pendingWalletDebitSuppression: Int32;
  private let settings: ref<NCBankModSettings>;

  private func EnsureSettings() -> Void {
    if !IsDefined(this.settings) {
      this.settings = new NCBankModSettings();
      this.settings.Init();
    };
  }

  private func T(key: CName) -> String {
    return NCBankLocalization.Get(this.GetLanguage(), key);
  }

  public func GetLocalizedText(key: CName) -> String {
    return this.T(key);
  }

  private func GetMoneyItemID() -> ItemID {
    return ItemID.FromTDBID(t"Items.money");
  }

  private func Pad2(value: Int32) -> String {
    if value < 10 {
      return "0" + IntToString(value);
    };
    return IntToString(value);
  }

  private func Pad3(value: Int32) -> String {
    if value < 10 {
      return "00" + IntToString(value);
    };
    if value < 100 {
      return "0" + IntToString(value);
    };
    return IntToString(value);
  }

  public func FormatEddies(value: Int32) -> String {
    let millions: Int32;
    let thousands: Int32;
    let rest: Int32;

    if value < 0 {
      return "0";
    };

    if value < 1000 {
      return IntToString(value);
    };

    if value < 1000000 {
      thousands = value / 1000;
      rest = value % 1000;
      return IntToString(thousands) + "," + this.Pad3(rest);
    };

    millions = value / 1000000;
    thousands = (value % 1000000) / 1000;
    rest = value % 1000;
    return IntToString(millions) + "," + this.Pad3(thousands) + "," + this.Pad3(rest);
  }

  private func GetExternalPartnerDisplayName(partnerCode: Int32) -> String {
    if Equals(partnerCode, 101) {
      return "ANODOS Financial";
    };
    if Equals(partnerCode, 201) {
      return "Vanguard Auto";
    };
    return "external partner";
  }

  private func GetSpendingSubjectDisplayName(subjectCode: Int32) -> String {
    if Equals(subjectCode, 1) { return "Food & Drinks"; };
    if Equals(subjectCode, 2) { return "Clothing"; };
    if Equals(subjectCode, 3) { return "Cyberware"; };
    if Equals(subjectCode, 4) { return "Weapons & Ammo"; };
    if Equals(subjectCode, 5) { return "Medical Supplies"; };
    if Equals(subjectCode, 6) { return "Quickhacks & Software"; };
    if Equals(subjectCode, 7) { return "Crafting & Upgrades"; };
    if Equals(subjectCode, 8) { return "Vehicles"; };
    if Equals(subjectCode, 9) { return "Insurance"; };
    if Equals(subjectCode, 10) { return "Real Estate"; };
    if Equals(subjectCode, 11) { return "Public Transportation"; };
    if Equals(subjectCode, 12) { return "Loan Payments"; };
    if Equals(subjectCode, 13) { return "Account Services"; };
    if Equals(subjectCode, 14) { return "Entertainment"; };
    if Equals(subjectCode, 15) { return "Other Purchases"; };
    return "Uncategorized Spending";
  }

  private func AddTransactionRecord(gameInstance: GameInstance, transactionType: Int32, amount: Int32, taxAmount: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecordWithCashback(gameInstance, transactionType, amount, taxAmount, 0, bankBefore, bankAfter, walletBefore, walletAfter);
  }

  private func PushBlankCashbackSlotsUntilSynced() -> Void {
    while ArraySize(this.transactionCashbackEarned) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionCashbackEarned, 0);
    };
  }

  private func PushBlankAnalyticsSlotsUntilSynced() -> Void {
    while ArraySize(this.transactionSubjectCodes) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionSubjectCodes, 0);
    };
    while ArraySize(this.transactionProvenanceCodes) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionProvenanceCodes, 0);
    };
  }

  private func PushBlankFraudStatusSlotsUntilSynced() -> Void {
    while ArraySize(this.transactionFraudStatuses) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionFraudStatuses, -1);
    };
    while ArraySize(this.transactionFraudDecisionDays) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionFraudDecisionDays, -1);
    };
    while ArraySize(this.transactionFraudDecisionHours) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionFraudDecisionHours, 0);
    };
    while ArraySize(this.transactionFraudDecisionMinutes) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionFraudDecisionMinutes, 0);
    };
  }

  private func FindLegacyLatestFraudAlertIndex() -> Int32 {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;
    let amountFallback: Int32 = -1;

    if this.latestFraudAlertAmount <= 0 {
      return -1;
    };

    while index >= 0 {
      if this.HasTransactionIndex(index) && Equals(this.transactionTypes[index], 10) && this.transactionAmounts[index] == this.latestFraudAlertAmount {
        if amountFallback < 0 {
          amountFallback = index;
        };
        if this.transactionDays[index] == this.latestFraudAlertDay && this.transactionHours[index] == this.latestFraudAlertHour && this.transactionMinutes[index] == this.latestFraudAlertMinute {
          return index;
        };
      };
      index -= 1;
    };

    return amountFallback;
  }

  private func EnsureFraudQueueState() -> Void {
    let legacyIndex: Int32;
    let legacyStatus: Int32;

    this.PushBlankFraudStatusSlotsUntilSynced();
    if this.fraudQueueVersion >= 1 {
      return;
    };

    legacyIndex = this.FindLegacyLatestFraudAlertIndex();
    if legacyIndex >= 0 && legacyIndex < ArraySize(this.transactionFraudStatuses) {
      legacyStatus = this.latestFraudAlertStatus;
      if legacyStatus < 0 || legacyStatus > 2 {
        legacyStatus = 0;
      };
      this.transactionFraudStatuses[legacyIndex] = legacyStatus;
    };

    this.fraudQueueVersion = 1;
  }

  private func SetLastTransactionAnalyticsMetadata(subjectCode: Int32, provenanceCode: Int32) -> Void {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;
    let safeSubject: Int32 = subjectCode;
    let safeProvenance: Int32 = provenanceCode;
    if index < 0 { return; };
    if safeSubject < 0 || safeSubject > 15 { safeSubject = 0; };
    if safeProvenance < 0 || safeProvenance > 5 { safeProvenance = 0; };
    this.PushBlankAnalyticsSlotsUntilSynced();
    if index < ArraySize(this.transactionSubjectCodes) {
      this.transactionSubjectCodes[index] = safeSubject;
    };
    if index < ArraySize(this.transactionProvenanceCodes) {
      this.transactionProvenanceCodes[index] = safeProvenance;
    };
  }

  private func AddTransactionRecordWithCashback(gameInstance: GameInstance, transactionType: Int32, amount: Int32, taxAmount: Int32, cashbackEarned: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    let timeSystem: ref<TimeSystem>;
    let gameTime: GameTime;
    let day: Int32 = -1;
    let hour: Int32 = 0;
    let minute: Int32 = 0;
    let postedCashback: Int32 = cashbackEarned;
    let fraudStatus: Int32 = -1;

    if amount <= 0 {
      return;
    };

    if postedCashback < 0 {
      postedCashback = 0;
    };

    timeSystem = GameInstance.GetTimeSystem(gameInstance);
    if IsDefined(timeSystem) {
      gameTime = timeSystem.GetGameTime();
      day = GameTime.Days(gameTime);
      hour = GameTime.Hours(gameTime);
      minute = GameTime.Minutes(gameTime);
    };

    this.EnsureFraudQueueState();
    if Equals(transactionType, 10) {
      fraudStatus = 0;
    };

    this.transactionSequence += 1;
    this.PushBlankCashbackSlotsUntilSynced();
    this.PushBlankAnalyticsSlotsUntilSynced();
    ArrayPush(this.transactionTypes, transactionType);
    ArrayPush(this.transactionAmounts, amount);
    ArrayPush(this.transactionTaxes, taxAmount);
    ArrayPush(this.transactionSubjectCodes, 0);
    ArrayPush(this.transactionProvenanceCodes, 0);
    ArrayPush(this.transactionCashbackEarned, postedCashback);
    ArrayPush(this.transactionBankBefore, bankBefore);
    ArrayPush(this.transactionBankAfter, bankAfter);
    ArrayPush(this.transactionWalletBefore, walletBefore);
    ArrayPush(this.transactionWalletAfter, walletAfter);
    ArrayPush(this.transactionDays, day);
    ArrayPush(this.transactionHours, hour);
    ArrayPush(this.transactionMinutes, minute);
    ArrayPush(this.transactionConfirmationLeft, this.BuildDefaultConfirmationLeft(day));
    ArrayPush(this.transactionConfirmationRight, this.BuildDefaultConfirmationRight(transactionType, ArraySize(this.transactionTypes) - 1, day, hour, minute));
    ArrayPush(this.transactionFraudStatuses, fraudStatus);
    ArrayPush(this.transactionFraudDecisionDays, -1);
    ArrayPush(this.transactionFraudDecisionHours, 0);
    ArrayPush(this.transactionFraudDecisionMinutes, 0);

    this.TrimTransactionLog();

    this.transactionUnreadCount += 1;
    if this.transactionUnreadCount > 40 {
      this.transactionUnreadCount = 40;
    };
  }

  private func TrimTransactionLog() -> Void {
    let trimmed: Bool = false;
    while ArraySize(this.transactionTypes) > 512 {
      trimmed = true;
      ArrayErase(this.transactionTypes, 0);
      ArrayErase(this.transactionAmounts, 0);
      ArrayErase(this.transactionTaxes, 0);
      if ArraySize(this.transactionSubjectCodes) > 0 {
        ArrayErase(this.transactionSubjectCodes, 0);
      };
      if ArraySize(this.transactionProvenanceCodes) > 0 {
        ArrayErase(this.transactionProvenanceCodes, 0);
      };
      if ArraySize(this.transactionCashbackEarned) > 0 {
        ArrayErase(this.transactionCashbackEarned, 0);
      };
      ArrayErase(this.transactionBankBefore, 0);
      ArrayErase(this.transactionBankAfter, 0);
      ArrayErase(this.transactionWalletBefore, 0);
      ArrayErase(this.transactionWalletAfter, 0);
      ArrayErase(this.transactionDays, 0);
      ArrayErase(this.transactionHours, 0);
      ArrayErase(this.transactionMinutes, 0);
      if ArraySize(this.transactionConfirmationLeft) > 0 {
        ArrayErase(this.transactionConfirmationLeft, 0);
      };
      if ArraySize(this.transactionConfirmationRight) > 0 {
        ArrayErase(this.transactionConfirmationRight, 0);
      };
      if ArraySize(this.transactionFraudStatuses) > 0 {
        ArrayErase(this.transactionFraudStatuses, 0);
      };
      if ArraySize(this.transactionFraudDecisionDays) > 0 {
        ArrayErase(this.transactionFraudDecisionDays, 0);
      };
      if ArraySize(this.transactionFraudDecisionHours) > 0 {
        ArrayErase(this.transactionFraudDecisionHours, 0);
      };
      if ArraySize(this.transactionFraudDecisionMinutes) > 0 {
        ArrayErase(this.transactionFraudDecisionMinutes, 0);
      };
    };
    if trimmed {
      this.transactionHistoryTrimmed = true;
      if ArraySize(this.transactionDays) > 0 {
        this.transactionHistoryBoundaryDay = this.transactionDays[0];
      };
    };
  }

  private func HasTransactionIndex(index: Int32) -> Bool {
    if index < 0 {
      return false;
    };
    if index >= ArraySize(this.transactionTypes) {
      return false;
    };
    if index >= ArraySize(this.transactionAmounts) {
      return false;
    };
    if index >= ArraySize(this.transactionTaxes) {
      return false;
    };
    if index >= ArraySize(this.transactionBankBefore) {
      return false;
    };
    if index >= ArraySize(this.transactionBankAfter) {
      return false;
    };
    if index >= ArraySize(this.transactionWalletBefore) {
      return false;
    };
    if index >= ArraySize(this.transactionWalletAfter) {
      return false;
    };
    if index >= ArraySize(this.transactionDays) {
      return false;
    };
    if index >= ArraySize(this.transactionHours) {
      return false;
    };
    if index >= ArraySize(this.transactionMinutes) {
      return false;
    };
    return true;
  }

  private func FormatClockTime(hour: Int32, minute: Int32) -> String {
    let displayHour: Int32 = hour;
    let suffix: String = "AM";

    if displayHour < 0 {
      displayHour = 0;
    };
    while displayHour >= 24 {
      displayHour -= 24;
    };

    if displayHour >= 12 {
      suffix = "PM";
    };
    if displayHour == 0 {
      displayHour = 12;
    } else {
      if displayHour > 12 {
        displayHour -= 12;
      };
    };

    if minute < 0 {
      minute = 0;
    };
    if minute > 59 {
      minute = minute % 60;
    };

    return IntToString(displayHour) + ":" + this.Pad2(minute) + " " + suffix;
  }

  private func GetTransactionTimestampAt(index: Int32) -> String {
    if !this.HasTransactionIndex(index) {
      return "Now";
    };

    if this.transactionDays[index] < 0 {
      return "Now";
    };

    return this.FormatClockTime(this.transactionHours[index], this.transactionMinutes[index]);
  }

  private func BuildBalanceSuffix(bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> String {
    return " Savings: " + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$. Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
  }

  private func Pad4(value: Int32) -> String {
    if value < 0 {
      value = 0;
    };
    value = value % 10000;
    if value < 10 {
      return "000" + IntToString(value);
    };
    if value < 100 {
      return "00" + IntToString(value);
    };
    if value < 1000 {
      return "0" + IntToString(value);
    };
    return IntToString(value);
  }

  private func Pad6(value: Int32) -> String {
    if value < 0 {
      value = 0;
    };
    value = value % 1000000;
    return this.Pad3(value / 1000) + this.Pad3(value % 1000);
  }

  private func GetConfirmationPrefix(transactionType: Int32) -> String {
    if Equals(transactionType, 6) {
      return "APP";
    };
    if Equals(transactionType, 7) {
      return "PAY";
    };
    if Equals(transactionType, 8) {
      return "AUT";
    };
    if Equals(transactionType, 27) {
      return "EXT";
    };

    if Equals(transactionType, 10) {
      return "FRD";
    };
    if Equals(transactionType, 4) {
      return "PUR";
    };
    if Equals(transactionType, 12) {
      return "FEE";
    };
    if Equals(transactionType, 13) {
      return "DSP";
    };
    if Equals(transactionType, 20) {
      return "CBR";
    };
    if Equals(transactionType, 25) {
      return "INS";
    };
    if Equals(transactionType, 26) {
      return "ILP";
    };
    if Equals(transactionType, 21) || Equals(transactionType, 22) || Equals(transactionType, 23) || Equals(transactionType, 24) {
      return "ANF";
    };
    return "TXN";
  }

  private func BuildDefaultConfirmationLeft(day: Int32) -> Int32 {
    if day < 0 {
      return 0;
    };
    return day % 10000;
  }

  private func BuildDefaultConfirmationRight(transactionType: Int32, index: Int32, day: Int32, hour: Int32, minute: Int32) -> Int32 {
    let right: Int32;

    if day < 0 {
      day = 0;
    };

    right = ((index + 1) * 911 + transactionType * 71 + day * 13 + hour * 5 + minute) % 1000000;
    if right < 100000 {
      right += 100000;
    };
    return right;
  }

  private func BuildConfirmationCode(transactionType: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> String {
    return "MB-" + this.GetConfirmationPrefix(transactionType) + "-" + this.Pad4(confirmationLeft) + "-" + this.Pad6(confirmationRight);
  }

  private func BuildDefaultConfirmationCode(transactionType: Int32, index: Int32, day: Int32, hour: Int32, minute: Int32) -> String {
    return this.BuildConfirmationCode(transactionType, this.BuildDefaultConfirmationLeft(day), this.BuildDefaultConfirmationRight(transactionType, index, day, hour, minute));
  }

  private func GetTransactionConfirmationCodeAt(index: Int32, transactionType: Int32) -> String {
    let confirmationLeft: Int32 = -1;
    let confirmationRight: Int32 = -1;
    let day: Int32 = 0;
    let hour: Int32 = 0;
    let minute: Int32 = 0;

    if index >= 0 && index < ArraySize(this.transactionConfirmationLeft) {
      confirmationLeft = this.transactionConfirmationLeft[index];
    };
    if index >= 0 && index < ArraySize(this.transactionConfirmationRight) {
      confirmationRight = this.transactionConfirmationRight[index];
    };

    if confirmationLeft >= 0 && confirmationRight > 0 {
      return this.BuildConfirmationCode(transactionType, confirmationLeft, confirmationRight);
    };

    if index >= 0 && index < ArraySize(this.transactionDays) {
      day = this.transactionDays[index];
    };
    if index >= 0 && index < ArraySize(this.transactionHours) {
      hour = this.transactionHours[index];
    };
    if index >= 0 && index < ArraySize(this.transactionMinutes) {
      minute = this.transactionMinutes[index];
    };

    return this.BuildDefaultConfirmationCode(transactionType, index, day, hour, minute);
  }

  private func PushBlankConfirmationSlotsUntilSynced() -> Void {
    while ArraySize(this.transactionConfirmationLeft) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionConfirmationLeft, -1);
    };
    while ArraySize(this.transactionConfirmationRight) < ArraySize(this.transactionTypes) {
      ArrayPush(this.transactionConfirmationRight, -1);
    };
  }

  public func SetLastTransactionConfirmationParts(confirmationLeft: Int32, confirmationRight: Int32) -> Void {
    let index: Int32;

    if confirmationRight <= 0 {
      return;
    };

    index = ArraySize(this.transactionTypes) - 1;
    if index < 0 {
      return;
    };

    this.PushBlankConfirmationSlotsUntilSynced();
    if index < ArraySize(this.transactionConfirmationLeft) {
      this.transactionConfirmationLeft[index] = confirmationLeft % 10000;
    };
    if index < ArraySize(this.transactionConfirmationRight) {
      this.transactionConfirmationRight[index] = confirmationRight % 1000000;
    };
  }

  public func SetLastTransactionConfirmationCode(confirmationCode: String) -> Void {
  }

  private func SuppressWalletDebit(amount: Int32) -> Void {
    if amount <= 0 {
      return;
    };
    this.pendingWalletDebitSuppression += amount;
  }

  public func SuppressExternalWalletDebit(amount: Int32) -> Void {
    this.SuppressWalletDebit(amount);
  }

  public func ClearExternalWalletDebitSuppression() -> Void {
    this.pendingWalletDebitSuppression = 0;
  }

  public func ConsumeExternalWalletDebitSuppressionForLua(amount: Int32) -> Int32 {
    return this.ConsumeSuppressedWalletDebit(amount);
  }

  private func ConsumeSuppressedWalletDebit(amount: Int32) -> Int32 {
    let ignored: Int32;

    if amount <= 0 {
      return 0;
    };

    if this.pendingWalletDebitSuppression <= 0 {
      return amount;
    };

    ignored = amount;
    if ignored > this.pendingWalletDebitSuppression {
      ignored = this.pendingWalletDebitSuppression;
    };

    this.pendingWalletDebitSuppression -= ignored;
    return amount - ignored;
  }

  private func CountRecentHighWalletSpend(currentDay: Int32, minimumAmount: Int32) -> Int32 {
    let idx: Int32 = ArraySize(this.transactionTypes) - 1;
    let count: Int32 = 0;
    let txDay: Int32;

    while idx >= 0 {
      if idx < ArraySize(this.transactionDays) {
        txDay = this.transactionDays[idx];
        if currentDay - txDay > 1 {
          return count;
        };
        if Equals(this.transactionTypes[idx], 4) && this.transactionAmounts[idx] >= minimumAmount {
          count += 1;
        };
      };
      idx -= 1;
    };

    return count;
  }

  private func GetPurchaseConfirmationThreshold() -> Int32 {
    return 150000;
  }

  private func GetFraudAlertReason(amount: Int32, currentDay: Int32) -> Int32 {
    if amount >= this.GetPurchaseConfirmationThreshold() {
      return 1;
    };

    return 0;
  }

  private func RecordFraudAlertTransaction(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, reason: Int32, subjectCode: Int32, provenanceCode: Int32) -> Void {
    let day: Int32 = this.GetCurrentDay(gameInstance);
    let hour: Int32 = this.GetCurrentHour(gameInstance);
    let minute: Int32 = this.GetCurrentMinute(gameInstance);

    if reason <= 0 {
      return;
    };

    if Equals(reason, 2) && Equals(this.lastFraudAlertDay, day) && Equals(this.lastFraudAlertReason, reason) {
      return;
    };

    this.EnsureFraudQueueState();
    this.latestFraudAlertStatus = 0;
    this.latestFraudAlertAmount = amount;
    this.latestFraudAlertDay = day;
    this.latestFraudAlertHour = hour;
    this.latestFraudAlertMinute = minute;
    this.latestFraudAlertReason = reason;
    this.lastFraudAlertDay = day;
    this.lastFraudAlertReason = reason;
    this.AddTransactionRecord(gameInstance, 10, amount, reason, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionAnalyticsMetadata(subjectCode, provenanceCode);
  }

  private func HasCreatedMarmurAccount(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };
    return qs.GetFact(n"marmur_account_open") > 0 && qs.GetFact(n"marmur_account_ever_opened") > 0;
  }

  public func ClearPreAccountActivity() -> Void {
    while ArraySize(this.transactionTypes) > 0 { ArrayErase(this.transactionTypes, 0); };
    while ArraySize(this.transactionAmounts) > 0 { ArrayErase(this.transactionAmounts, 0); };
    while ArraySize(this.transactionTaxes) > 0 { ArrayErase(this.transactionTaxes, 0); };
    while ArraySize(this.transactionSubjectCodes) > 0 { ArrayErase(this.transactionSubjectCodes, 0); };
    while ArraySize(this.transactionProvenanceCodes) > 0 { ArrayErase(this.transactionProvenanceCodes, 0); };
    while ArraySize(this.transactionCashbackEarned) > 0 { ArrayErase(this.transactionCashbackEarned, 0); };
    while ArraySize(this.transactionBankBefore) > 0 { ArrayErase(this.transactionBankBefore, 0); };
    while ArraySize(this.transactionBankAfter) > 0 { ArrayErase(this.transactionBankAfter, 0); };
    while ArraySize(this.transactionWalletBefore) > 0 { ArrayErase(this.transactionWalletBefore, 0); };
    while ArraySize(this.transactionWalletAfter) > 0 { ArrayErase(this.transactionWalletAfter, 0); };
    while ArraySize(this.transactionDays) > 0 { ArrayErase(this.transactionDays, 0); };
    while ArraySize(this.transactionHours) > 0 { ArrayErase(this.transactionHours, 0); };
    while ArraySize(this.transactionMinutes) > 0 { ArrayErase(this.transactionMinutes, 0); };
    while ArraySize(this.transactionConfirmationLeft) > 0 { ArrayErase(this.transactionConfirmationLeft, 0); };
    while ArraySize(this.transactionConfirmationRight) > 0 { ArrayErase(this.transactionConfirmationRight, 0); };
    while ArraySize(this.transactionFraudStatuses) > 0 { ArrayErase(this.transactionFraudStatuses, 0); };
    while ArraySize(this.transactionFraudDecisionDays) > 0 { ArrayErase(this.transactionFraudDecisionDays, 0); };
    while ArraySize(this.transactionFraudDecisionHours) > 0 { ArrayErase(this.transactionFraudDecisionHours, 0); };
    while ArraySize(this.transactionFraudDecisionMinutes) > 0 { ArrayErase(this.transactionFraudDecisionMinutes, 0); };
    this.fraudQueueVersion = 1;
    this.transactionUnreadCount = 0;
    this.transactionSequence = 0;
    this.transactionHistoryTrimmed = false;
    this.transactionHistoryBoundaryDay = -1;
    this.latestFraudAlertStatus = 0;
    this.latestFraudAlertAmount = 0;
    this.latestFraudAlertDay = 0;
    this.latestFraudAlertHour = 0;
    this.latestFraudAlertMinute = 0;
    this.latestFraudAlertReason = 0;
    this.lastFraudAlertDay = 0;
    this.lastFraudAlertReason = 0;
  }

  public func RecordExternalSpend(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32) -> Bool {
    return this.RecordExternalSpendWithCashback(gameInstance, amount, walletBefore, walletAfter, 0);
  }

  public func RecordExternalSpendWithCashback(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, cashbackEarned: Int32) -> Bool {
    return this.RecordCategorizedExternalSpendWithCashback(gameInstance, amount, walletBefore, walletAfter, cashbackEarned, 0, 1);
  }

  public func RecordCategorizedExternalSpendWithCashback(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, cashbackEarned: Int32, subjectCode: Int32, provenanceCode: Int32) -> Bool {
    let spendAmount: Int32;
    let currentDay: Int32;
    let reason: Int32;
    let postedCashback: Int32 = cashbackEarned;
    let sequenceBefore: Int32 = this.transactionSequence;

    if !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    if postedCashback < 0 {
      postedCashback = 0;
    };

    spendAmount = this.ConsumeSuppressedWalletDebit(amount);
    if spendAmount <= 0 {
      return false;
    };

    this.AddTransactionRecordWithCashback(gameInstance, 4, spendAmount, 0, postedCashback, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionAnalyticsMetadata(subjectCode, provenanceCode);
    currentDay = this.GetCurrentDay(gameInstance);
    reason = this.GetFraudAlertReason(spendAmount, currentDay);
    if reason > 0 {
      this.RecordFraudAlertTransaction(gameInstance, spendAmount, walletBefore, walletAfter, reason, subjectCode, provenanceCode);
    };
    return this.transactionSequence > sequenceBefore;
  }

  public func RecordCategorizedExternalAccountSpend(gameInstance: GameInstance, amount: Int32, subjectCode: Int32, provenanceCode: Int32) -> Bool {
    let walletBalance: Int32;
    let sequenceBefore: Int32 = this.transactionSequence;
    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };
    walletBalance = this.GetWalletBalance(gameInstance);
    this.AddTransactionRecord(gameInstance, 27, amount, 0, this.bankBalance, this.bankBalance, walletBalance, walletBalance);
    this.SetLastTransactionAnalyticsMetadata(subjectCode, provenanceCode);
    return this.transactionSequence > sequenceBefore;
  }

  public func RecordCashbackCredit(gameInstance: GameInstance, amount: Int32, destinationCode: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    let destination: Int32 = destinationCode;
    if amount <= 0 {
      return;
    };
    if destination != 2 {
      destination = 1;
    };
    this.AddTransactionRecord(gameInstance, 20, amount, destination, bankBefore, bankAfter, walletBefore, walletAfter);
  }

  private func RecordDepositTransaction(gameInstance: GameInstance, amount: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 1, amount, 0, bankBefore, bankAfter, walletBefore, walletAfter);
  }

  private func RecordWithdrawTransaction(gameInstance: GameInstance, amount: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 2, amount, 0, bankBefore, bankAfter, walletBefore, walletAfter);
  }

  private func RecordInterestTransaction(gameInstance: GameInstance, netAmount: Int32, taxAmount: Int32, bankBefore: Int32, bankAfter: Int32) -> Void {
    if netAmount <= 0 {
      return;
    };
    this.AddTransactionRecord(gameInstance, 3, netAmount, taxAmount, bankBefore, bankAfter, 0, 0);
  }

  private func RecordCheckingFeeTransaction(gameInstance: GameInstance, feeAmount: Int32, bankBefore: Int32, bankAfter: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    if feeAmount <= 0 {
      return;
    };
    this.AddTransactionRecord(gameInstance, 12, feeAmount, 0, bankBefore, bankAfter, walletBefore, walletAfter);
  }

  private func RecordPrivateClientFeeTransaction(gameInstance: GameInstance, feeAmount: Int32, bankBefore: Int32, bankAfter: Int32) -> Void {
    if feeAmount <= 0 {
      return;
    };
    this.AddTransactionRecord(gameInstance, 14, feeAmount, 0, bankBefore, bankAfter, 0, 0);
  }


  private func RecordLoanDisbursementTransaction(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 6, amount, 0, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
  }

  private func RecordLoanManualPaymentTransaction(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 7, amount, 0, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
  }

  private func RecordLoanAutoPaymentTransaction(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 8, amount, 0, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
  }

  private func RecordLoanMissedPaymentTransaction(gameInstance: GameInstance, amount: Int32, walletBefore: Int32) -> Void {
    this.AddTransactionRecord(gameInstance, 9, amount, 0, this.bankBalance, this.bankBalance, walletBefore, walletBefore);
  }

  public func RecordExternalLoanApprovalNotice(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Void {
    this.RecordLoanDisbursementTransaction(gameInstance, amount, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
  }

  public func RecordExternalLoanManualPaymentNotice(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Void {
    this.RecordLoanManualPaymentTransaction(gameInstance, amount, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
  }

  public func RecordExternalLoanAutoPaymentNotice(gameInstance: GameInstance, amount: Int32, walletBefore: Int32, walletAfter: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Void {
    this.RecordLoanAutoPaymentTransaction(gameInstance, amount, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
  }

  public func RecordVanguardAutoPaymentNotice(gameInstance: GameInstance, amount: Int32, cashbackEarned: Int32, walletBefore: Int32, walletAfter: Int32) -> Bool {
    let postedCashback: Int32 = cashbackEarned;
    let sequenceBefore: Int32 = this.transactionSequence;
    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };
    if postedCashback < 0 {
      postedCashback = 0;
    };
    this.AddTransactionRecordWithCashback(gameInstance, 21, amount, 201, postedCashback, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionAnalyticsMetadata(8, 3);
    return this.transactionSequence > sequenceBefore;
  }

  public func ReclassifyLatestExternalSpendAsVanguard(amount: Int32, walletAfter: Int32) -> Bool {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;
    let inspected: Int32 = 0;
    this.PushBlankAnalyticsSlotsUntilSynced();
    while index >= 0 && inspected < 8 {
      if Equals(this.transactionTypes[index], 4) && this.transactionAmounts[index] == amount && this.transactionWalletAfter[index] == walletAfter {
        if this.transactionProvenanceCodes[index] <= 1 {
          this.transactionTypes[index] = 21;
          this.transactionTaxes[index] = 201;
          this.transactionSubjectCodes[index] = 8;
          this.transactionProvenanceCodes[index] = 3;
          return true;
        };
        if this.transactionSubjectCodes[index] == 8 {
          return true;
        };
      };
      index -= 1;
      inspected += 1;
    };
    return false;
  }

  public func ReclassifyLatestExternalSpendSubject(amount: Int32, walletAfter: Int32, subjectCode: Int32, provenanceCode: Int32) -> Bool {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;
    let inspected: Int32 = 0;
    let safeSubject: Int32 = subjectCode;
    let safeProvenance: Int32 = provenanceCode;
    if safeSubject < 0 || safeSubject > 15 { safeSubject = 0; };
    if safeProvenance < 0 || safeProvenance > 5 { safeProvenance = 0; };
    this.PushBlankAnalyticsSlotsUntilSynced();
    while index >= 0 && inspected < 8 {
      if Equals(this.transactionTypes[index], 4) && this.transactionAmounts[index] == amount && this.transactionWalletAfter[index] == walletAfter {
        if this.transactionProvenanceCodes[index] <= 1 {
          this.transactionSubjectCodes[index] = safeSubject;
          this.transactionProvenanceCodes[index] = safeProvenance;
          return true;
        };
        if this.transactionSubjectCodes[index] == safeSubject {
          return true;
        };
      };
      index -= 1;
      inspected += 1;
    };
    return false;
  }


  public func TransferCheckingToExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;

    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    if walletBefore < amount {
      return false;
    };

    this.SuppressWalletDebit(amount);
    ts.GiveItem(player, this.GetMoneyItemID(), -amount);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.AddTransactionRecord(gameInstance, 21, amount, partnerCode, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func TransferSavingsToExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let bankBefore: Int32;
    let wallet: Int32;

    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    this.SyncInterest(gameInstance);
    if this.bankBalance < amount {
      return false;
    };

    bankBefore = this.bankBalance;
    wallet = this.GetWalletBalance(gameInstance);
    this.bankBalance -= amount;
    this.totalWithdrawn = this.SaturatingTransactionTotal(this.totalWithdrawn, amount);
    this.MirrorPersistentState();
    this.AddTransactionRecord(gameInstance, 22, amount, partnerCode, bankBefore, this.bankBalance, wallet, wallet);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func ReceiveCheckingFromExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;

    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    ts.GiveItem(player, this.GetMoneyItemID(), amount);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.AddTransactionRecord(gameInstance, 23, amount, partnerCode, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func ReceiveSavingsFromExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let bankBefore: Int32;
    let wallet: Int32;

    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    this.SyncInterest(gameInstance);
    bankBefore = this.bankBalance;
    wallet = this.GetWalletBalance(gameInstance);
    this.bankBalance += amount;
    this.totalDeposited = this.SaturatingTransactionTotal(this.totalDeposited, amount);
    if this.totalDeposited >= this.GetPremiumThreshold() {
      this.premiumUnlocked = true;
    };
    this.MirrorPersistentState();
    this.AddTransactionRecord(gameInstance, 24, amount, partnerCode, bankBefore, this.bankBalance, wallet, wallet);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func RecordVanguardInsuranceSettlementDeposit(gameInstance: GameInstance, amount: Int32, claimNumber: Int32, walletBefore: Int32, walletAfter: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    this.AddTransactionRecord(gameInstance, 25, amount, claimNumber, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func RecordVanguardInsuranceLoanPayoff(gameInstance: GameInstance, amount: Int32, claimNumber: Int32, walletBefore: Int32, walletAfter: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    if amount <= 0 || !this.HasCreatedMarmurAccount(gameInstance) {
      return false;
    };

    this.AddTransactionRecord(gameInstance, 26, amount, claimNumber, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    this.SetLastTransactionConfirmationParts(confirmationLeft, confirmationRight);
    return true;
  }

  public func GetTransactionLogCount() -> Int32 {
    return ArraySize(this.transactionTypes);
  }

  public func GetTransactionSequence() -> Int32 {
    return this.transactionSequence;
  }

  public func HasTransactionHistoryTrimmed() -> Bool {
    return this.transactionHistoryTrimmed || this.transactionSequence > ArraySize(this.transactionTypes);
  }

  public func GetTransactionHistoryBoundaryDay() -> Int32 {
    if this.transactionHistoryBoundaryDay > 0 {
      return this.transactionHistoryBoundaryDay;
    };
    if this.HasTransactionHistoryTrimmed() && ArraySize(this.transactionDays) > 0 {
      return this.transactionDays[0];
    };
    return -1;
  }

  public func GetTransactionLogAt(index: Int32) -> String {
    let transactionType: Int32;
    let amount: Int32;
    let taxAmount: Int32;
    let bankBefore: Int32;
    let bankAfter: Int32;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let timestamp: String;
    let confirmationCode: String;
    let cashbackEarned: Int32 = 0;
    let cashbackSuffix: String = "";
    let subjectCode: Int32 = 0;
    let subjectName: String = "Uncategorized Spending";
    let fraudStatus: Int32 = -1;
    let fraudCategorySuffix: String = "";

    if !this.HasTransactionIndex(index) {
      return "";
    };

    transactionType = this.transactionTypes[index];
    amount = this.transactionAmounts[index];
    taxAmount = this.transactionTaxes[index];
    bankBefore = this.transactionBankBefore[index];
    bankAfter = this.transactionBankAfter[index];
    walletBefore = this.transactionWalletBefore[index];
    walletAfter = this.transactionWalletAfter[index];
    timestamp = this.GetTransactionTimestampAt(index);
    confirmationCode = this.GetTransactionConfirmationCodeAt(index, transactionType);
    cashbackEarned = this.GetTransactionCashbackEarnedAt(index);
    subjectCode = this.GetTransactionSubjectAt(index);
    subjectName = this.GetSpendingSubjectDisplayName(subjectCode);
    if cashbackEarned > 0 {
      cashbackSuffix = " Cashback earned: " + this.FormatEddies(cashbackEarned) + " E$ pending weekly payout.";
    };

    if Equals(transactionType, 1) {
      return "Marmur Bank deposit notice — " + this.FormatEddies(amount) + " E$ was deposited into savings at " + timestamp + "." + this.BuildBalanceSuffix(bankBefore, bankAfter, walletBefore, walletAfter);
    };

    if Equals(transactionType, 2) {
      return "Marmur Bank withdrawal notice — " + this.FormatEddies(amount) + " E$ was withdrawn from savings at " + timestamp + "." + this.BuildBalanceSuffix(bankBefore, bankAfter, walletBefore, walletAfter);
    };

    if Equals(transactionType, 3) {
      return this.T(n"mb_loc_008") + this.FormatEddies(amount) + " E$ was deposited at " + timestamp + this.T(n"mb_loc_009") + this.FormatEddies(taxAmount) + " E$. Savings: " + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$.";
    };

    if Equals(transactionType, 4) {
      if Equals(taxAmount, 3) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatEddies(amount) + " E$ posted at " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Status: dispute submitted for review." + cashbackSuffix;
      };
      if Equals(taxAmount, 4) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatEddies(amount) + " E$ posted at " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Status: dispute approved and credited." + cashbackSuffix;
      };
      if Equals(taxAmount, 5) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatEddies(amount) + " E$ posted at " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Status: dispute denied after review." + cashbackSuffix;
      };
      return "Marmur Bank purchase notice — a purchase of " + this.FormatEddies(amount) + " E$ posted at " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. No reply is required." + cashbackSuffix;
    };

    if Equals(transactionType, 10) {
      fraudStatus = this.GetTransactionFraudStatusAt(index);
      if subjectCode > 0 {
        fraudCategorySuffix = " Category: " + subjectName + ".";
      };
      if Equals(fraudStatus, 1) {
        return "Marmur Bank security check resolved — transaction confirmed authorized." + fraudCategorySuffix + " Amount: " + this.FormatEddies(amount) + " E$. Posted: " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Alert ID " + confirmationCode + ". No further action is required.";
      };
      if Equals(fraudStatus, 2) {
        return "Marmur Bank security check escalated — transaction reported as suspicious." + fraudCategorySuffix + " Amount: " + this.FormatEddies(amount) + " E$. Posted: " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Alert ID " + confirmationCode + ". Open Activity on the Marmur Bank website to file the dispute.";
      };
      if Equals(fraudStatus, 0) {
        return "Marmur Bank security alert — please verify this transaction." + fraudCategorySuffix + " Amount: " + this.FormatEddies(amount) + " E$. Posted: " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Did you authorize this purchase? Alert ID " + confirmationCode + ".";
      };
      return "Marmur Bank archived security review." + fraudCategorySuffix + " Amount: " + this.FormatEddies(amount) + " E$. Posted: " + timestamp + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Alert ID " + confirmationCode + ".";
    };

    if Equals(transactionType, 5) {
      return "Marmur Bank ledger sync - existing savings balance imported at " + timestamp + this.T(n"mb_loc_011") + this.FormatEddies(bankBefore) + " -> " + this.FormatEddies(bankAfter) + " E$. Checking: " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 6) {
      return "Marmur Bank loan funded — principal deposited for " + this.FormatEddies(amount) + " E$ at " + timestamp + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 7) {
      return "Marmur Bank loan payment confirmed — manual repayment received for " + this.FormatEddies(amount) + " E$ at " + timestamp + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$." + cashbackSuffix;
    };

    if Equals(transactionType, 8) {
      return "Marmur Bank auto-payment notice — scheduled loan payment of " + this.FormatEddies(amount) + " E$ was automatically withdrawn at " + timestamp + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$." + cashbackSuffix;
    };

    if Equals(transactionType, 9) {
      return this.T(n"mb_loc_012") + this.FormatEddies(amount) + " E$ was missed at " + timestamp + ". Checking balance: " + this.FormatEddies(walletBefore) + " E$.";
    };

    if Equals(transactionType, 12) {
      return this.T(n"mb_loc_013") + this.FormatEddies(amount) + " E$ was automatically withdrawn at " + timestamp + ". Fee is waived when the checking balance is at least 10,000 E$. Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$. Savings: " + this.FormatEddies(bankAfter) + " E$.";
    };

    if Equals(transactionType, 14) {
      return this.T(n"mb_loc_014") + this.FormatEddies(amount) + " E$ posted at " + timestamp + this.T(n"mb_loc_011") + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$.";
    };

    if Equals(transactionType, 20) {
      if Equals(taxAmount, 2) {
        return "Marmur Bank weekly cashback payout — " + this.FormatEddies(amount) + " E$ was credited to savings at " + timestamp + ". Rewards post every 7 days at 3:00 PM from eligible spend and loan payments. Savings: " + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$.";
      };
      return "Marmur Bank weekly cashback payout — " + this.FormatEddies(amount) + " E$ was credited to checking at " + timestamp + ". Rewards post every 7 days at 3:00 PM from eligible spend and loan payments. Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 21) {
      return "Marmur Bank partner transfer — " + this.FormatEddies(amount) + " E$ moved from checking to " + this.GetExternalPartnerDisplayName(taxAmount) + " at " + timestamp + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 22) {
      return "Marmur Bank partner transfer — " + this.FormatEddies(amount) + " E$ moved from savings to " + this.GetExternalPartnerDisplayName(taxAmount) + " at " + timestamp + ". Confirmation No. " + confirmationCode + this.T(n"mb_loc_011") + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$.";
    };

    if Equals(transactionType, 23) {
      return "Marmur Bank partner transfer — " + this.FormatEddies(amount) + " E$ received from " + this.GetExternalPartnerDisplayName(taxAmount) + " into checking at " + timestamp + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 24) {
      return "Marmur Bank partner transfer — " + this.FormatEddies(amount) + " E$ received from " + this.GetExternalPartnerDisplayName(taxAmount) + " into savings at " + timestamp + ". Confirmation No. " + confirmationCode + this.T(n"mb_loc_011") + this.FormatEddies(bankBefore) + " → " + this.FormatEddies(bankAfter) + " E$.";
    };

    if Equals(transactionType, 25) {
      return "Marmur Bank insurance settlement — Vanguard Auto settlement proceeds of " + this.FormatEddies(amount) + " E$ were deposited into checking at " + timestamp + ". Claim CLM-" + IntToString(taxAmount) + ". Confirmation No. " + confirmationCode + ". Checking: " + this.FormatEddies(walletBefore) + " → " + this.FormatEddies(walletAfter) + " E$.";
    };

    if Equals(transactionType, 26) {
      return "Marmur Bank insurance loan payoff — Vanguard Auto settlement proceeds of " + this.FormatEddies(amount) + " E$ were applied to the financed auto loan at " + timestamp + ". Claim CLM-" + IntToString(taxAmount) + ". Confirmation No. " + confirmationCode + ". Insurance-paid loan payoffs are not cashback eligible.";
    };

    if Equals(transactionType, 27) {
      return "Marmur Bank external spending notice — " + subjectName + ": " + this.FormatEddies(amount) + " E$ posted at " + timestamp + ".";
    };

    if Equals(transactionType, 13) {
      return this.T(n"mb_loc_015") + this.FormatEddies(amount) + " E$ at " + timestamp + ". Case ID " + confirmationCode + ".";
    };

    return "Marmur Bank transaction posted for " + this.FormatEddies(amount) + " E$ at " + timestamp + ".";
  }


  public func GetTransactionTypeAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionTypes[index];
  }

  public func GetTransactionAmountAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionAmounts[index];
  }

  public func GetTransactionTaxAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionTaxes[index];
  }

  public func GetTransactionSubjectAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    this.PushBlankAnalyticsSlotsUntilSynced();
    if index < 0 || index >= ArraySize(this.transactionSubjectCodes) {
      return 0;
    };
    return this.transactionSubjectCodes[index];
  }

  public func GetTransactionProvenanceAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    this.PushBlankAnalyticsSlotsUntilSynced();
    if index < 0 || index >= ArraySize(this.transactionProvenanceCodes) {
      return 0;
    };
    return this.transactionProvenanceCodes[index];
  }

  public func GetTransactionCashbackEarnedAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    if index < 0 || index >= ArraySize(this.transactionCashbackEarned) {
      return 0;
    };
    return this.transactionCashbackEarned[index];
  }

  public func GetTransactionBankBeforeAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionBankBefore[index];
  }

  public func GetTransactionBankAfterAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionBankAfter[index];
  }

  public func GetTransactionWalletBeforeAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionWalletBefore[index];
  }

  public func GetTransactionWalletAfterAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionWalletAfter[index];
  }

  private func SetTransactionCashbackEarnedAt(index: Int32, amount: Int32) -> Void {
    let safeAmount: Int32 = amount;
    if index < 0 {
      return;
    };
    if index >= ArraySize(this.transactionTypes) {
      return;
    };
    if safeAmount < 0 {
      safeAmount = 0;
    };
    this.PushBlankCashbackSlotsUntilSynced();
    if index < ArraySize(this.transactionCashbackEarned) {
      this.transactionCashbackEarned[index] = safeAmount;
    };
  }

  public func SetLastTransactionCashbackEarned(amount: Int32) -> Void {
    this.SetTransactionCashbackEarnedAt(ArraySize(this.transactionTypes) - 1, amount);
  }

  public func GetTransactionTimestampForUIAt(index: Int32) -> String {
    return this.GetTransactionTimestampAt(index);
  }

  public func GetTransactionDayAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return -1;
    };
    return this.transactionDays[index];
  }

  public func GetTransactionHourAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionHours[index];
  }

  public func GetTransactionMinuteAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    return this.transactionMinutes[index];
  }

  private func HasVerifiedPurchaseDebitAt(index: Int32) -> Bool {
    if !this.HasTransactionIndex(index) {
      return false;
    };
    if !Equals(this.transactionTypes[index], 4) {
      return false;
    };
    this.PushBlankAnalyticsSlotsUntilSynced();
    if index < 0 || index >= ArraySize(this.transactionProvenanceCodes) || this.transactionProvenanceCodes[index] <= 0 {
      return false;
    };
    if this.transactionAmounts[index] <= 0 || this.transactionWalletBefore[index] < this.transactionWalletAfter[index] {
      return false;
    };
    return this.transactionWalletBefore[index] - this.transactionWalletAfter[index] == this.transactionAmounts[index];
  }

  public func GetTransactionIsDisputableAt(index: Int32) -> Bool {
    if !this.HasVerifiedPurchaseDebitAt(index) {
      return false;
    };
    if this.transactionTaxes[index] > 0 {
      return false;
    };
    return true;
  }

  public func GetTransactionDisputeStatusAt(index: Int32) -> Int32 {
    if !this.HasTransactionIndex(index) {
      return 0;
    };
    if !Equals(this.transactionTypes[index], 4) {
      return 0;
    };
    return this.transactionTaxes[index];
  }

  public func SetTransactionDisputeStatusAt(index: Int32, status: Int32) -> Bool {
    let safeStatus: Int32 = status;
    let closingUnverifiedPending: Bool = this.HasTransactionIndex(index) && Equals(this.transactionTypes[index], 4) && Equals(this.transactionTaxes[index], 3) && (Equals(safeStatus, 4) || Equals(safeStatus, 5));
    if !this.HasVerifiedPurchaseDebitAt(index) && !closingUnverifiedPending {
      return false;
    };
    if safeStatus < 0 {
      safeStatus = 0;
    };
    if safeStatus > 5 {
      safeStatus = 5;
    };
    this.transactionTaxes[index] = safeStatus;
    return true;
  }

  public func DisputeTransactionAt(gameInstance: GameInstance, index: Int32) -> Bool {
    let amount: Int32;
    let walletBefore: Int32;
    let walletAfter: Int32;

    if !this.HasVerifiedPurchaseDebitAt(index) {
      return false;
    };
    if this.transactionTaxes[index] > 0 {
      return true;
    };

    this.transactionTaxes[index] = 3;
    amount = this.transactionAmounts[index];
    walletBefore = this.transactionWalletBefore[index];
    walletAfter = this.transactionWalletAfter[index];
    this.AddTransactionRecord(gameInstance, 13, amount, index, this.bankBalance, this.bankBalance, walletBefore, walletAfter);
    return true;
  }

  private func GetLatestFraudAlertIndex() -> Int32 {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;

    this.EnsureFraudQueueState();
    while index >= 0 {
      if this.HasTransactionIndex(index) && Equals(this.transactionTypes[index], 10) {
        return index;
      };
      index -= 1;
    };
    return -1;
  }

  public func GetTransactionFraudStatusAt(index: Int32) -> Int32 {
    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) {
      return -1;
    };
    if index < 0 || index >= ArraySize(this.transactionFraudStatuses) {
      return -1;
    };
    return this.transactionFraudStatuses[index];
  }

  public func GetTransactionFraudDecisionDayAt(index: Int32) -> Int32 {
    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || index >= ArraySize(this.transactionFraudDecisionDays) {
      return -1;
    };
    return this.transactionFraudDecisionDays[index];
  }

  public func GetTransactionFraudDecisionHourAt(index: Int32) -> Int32 {
    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || index >= ArraySize(this.transactionFraudDecisionHours) {
      return 0;
    };
    return this.transactionFraudDecisionHours[index];
  }

  public func GetTransactionFraudDecisionMinuteAt(index: Int32) -> Int32 {
    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || index >= ArraySize(this.transactionFraudDecisionMinutes) {
      return 0;
    };
    return this.transactionFraudDecisionMinutes[index];
  }

  public func GetPendingFraudAlertCount() -> Int32 {
    let index: Int32 = 0;
    let count: Int32 = 0;

    this.EnsureFraudQueueState();
    while index < ArraySize(this.transactionTypes) {
      if Equals(this.transactionTypes[index], 10) && index < ArraySize(this.transactionFraudStatuses) && Equals(this.transactionFraudStatuses[index], 0) {
        count += 1;
      };
      index += 1;
    };
    return count;
  }

  public func GetOldestPendingFraudAlertIndex() -> Int32 {
    let index: Int32 = 0;

    this.EnsureFraudQueueState();
    while index < ArraySize(this.transactionTypes) {
      if Equals(this.transactionTypes[index], 10) && index < ArraySize(this.transactionFraudStatuses) && Equals(this.transactionFraudStatuses[index], 0) {
        return index;
      };
      index += 1;
    };
    return -1;
  }

  public func GetLatestPendingFraudAlertIndex() -> Int32 {
    let index: Int32 = ArraySize(this.transactionTypes) - 1;

    this.EnsureFraudQueueState();
    while index >= 0 {
      if Equals(this.transactionTypes[index], 10) && index < ArraySize(this.transactionFraudStatuses) && Equals(this.transactionFraudStatuses[index], 0) {
        return index;
      };
      index -= 1;
    };
    return -1;
  }

  private func RefreshLegacyLatestFraudAlert() -> Void {
    let index: Int32 = this.GetLatestPendingFraudAlertIndex();
    let status: Int32;

    if index < 0 {
      index = this.GetLatestFraudAlertIndex();
    };

    if index < 0 || !this.HasTransactionIndex(index) {
      this.latestFraudAlertStatus = 0;
      this.latestFraudAlertAmount = 0;
      this.latestFraudAlertDay = 0;
      this.latestFraudAlertHour = 0;
      this.latestFraudAlertMinute = 0;
      this.latestFraudAlertReason = 0;
      return;
    };

    status = this.GetTransactionFraudStatusAt(index);
    if status < 0 || status > 2 {
      status = 1;
    };
    this.latestFraudAlertStatus = status;
    this.latestFraudAlertAmount = this.transactionAmounts[index];
    this.latestFraudAlertDay = this.transactionDays[index];
    this.latestFraudAlertHour = this.transactionHours[index];
    this.latestFraudAlertMinute = this.transactionMinutes[index];
    this.latestFraudAlertReason = this.transactionTaxes[index];
  }

  public func HasPendingFraudAlert() -> Bool {
    return this.GetPendingFraudAlertCount() > 0;
  }

  public func GetLatestFraudAlertAmount() -> Int32 {
    let index: Int32 = this.GetLatestPendingFraudAlertIndex();
    if index >= 0 && this.HasTransactionIndex(index) {
      return this.transactionAmounts[index];
    };
    index = this.GetLatestFraudAlertIndex();
    if index >= 0 && this.HasTransactionIndex(index) {
      return this.transactionAmounts[index];
    };
    return this.latestFraudAlertAmount;
  }

  public func GetLatestFraudAlertStatus() -> Int32 {
    let index: Int32 = this.GetLatestPendingFraudAlertIndex();
    if index >= 0 {
      return this.GetTransactionFraudStatusAt(index);
    };
    index = this.GetLatestFraudAlertIndex();
    if index >= 0 {
      return this.GetTransactionFraudStatusAt(index);
    };
    return this.latestFraudAlertStatus;
  }

  public func GetLatestFraudAlertReason() -> Int32 {
    let index: Int32 = this.GetLatestPendingFraudAlertIndex();
    if index >= 0 && this.HasTransactionIndex(index) {
      return this.transactionTaxes[index];
    };
    index = this.GetLatestFraudAlertIndex();
    if index >= 0 && this.HasTransactionIndex(index) {
      return this.transactionTaxes[index];
    };
    return this.latestFraudAlertReason;
  }

  private func StampFraudDecisionTime(gameInstance: GameInstance, index: Int32) -> Void {
    let timeSystem: ref<TimeSystem>;
    let gameTime: GameTime;

    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) {
      return;
    };

    timeSystem = GameInstance.GetTimeSystem(gameInstance);
    if !IsDefined(timeSystem) {
      return;
    };

    gameTime = timeSystem.GetGameTime();
    this.transactionFraudDecisionDays[index] = GameTime.Days(gameTime);
    this.transactionFraudDecisionHours[index] = GameTime.Hours(gameTime);
    this.transactionFraudDecisionMinutes[index] = GameTime.Minutes(gameTime);
  }

  public func ConfirmFraudAlertAtWithTime(gameInstance: GameInstance, index: Int32) -> String {
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || !Equals(this.GetTransactionFraudStatusAt(index), 0) {
      return this.ConfirmFraudAlertAt(index);
    };
    this.StampFraudDecisionTime(gameInstance, index);
    return this.ConfirmFraudAlertAt(index);
  }

  public func FlagFraudAlertAtWithTime(gameInstance: GameInstance, index: Int32) -> String {
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || !Equals(this.GetTransactionFraudStatusAt(index), 0) {
      return this.FlagFraudAlertAt(index);
    };
    this.StampFraudDecisionTime(gameInstance, index);
    return this.FlagFraudAlertAt(index);
  }

  public func ConfirmFraudAlertAt(index: Int32) -> String {
    let subjectCode: Int32;
    let categorySuffix: String = "";

    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || !Equals(this.GetTransactionFraudStatusAt(index), 0) {
      return "No Marmur Bank fraud alert is waiting for confirmation.";
    };

    this.transactionFraudStatuses[index] = 1;
    subjectCode = this.GetTransactionSubjectAt(index);
    if subjectCode > 0 {
      categorySuffix = " " + this.GetSpendingSubjectDisplayName(subjectCode);
    };
    this.transactionUnreadCount += 1;
    if this.transactionUnreadCount > 40 {
      this.transactionUnreadCount = 40;
    };
    this.RefreshLegacyLatestFraudAlert();
    return "Thank you. Marmur Bank marked the " + this.FormatEddies(this.transactionAmounts[index]) + " E$" + categorySuffix + " purchase as authorized. No further action is required.";
  }

  public func FlagFraudAlertAt(index: Int32) -> String {
    let subjectCode: Int32;
    let categorySuffix: String = "";

    this.EnsureFraudQueueState();
    if !this.HasTransactionIndex(index) || !Equals(this.transactionTypes[index], 10) || !Equals(this.GetTransactionFraudStatusAt(index), 0) {
      return "No Marmur Bank fraud alert is waiting for review.";
    };

    this.transactionFraudStatuses[index] = 2;
    subjectCode = this.GetTransactionSubjectAt(index);
    if subjectCode > 0 {
      categorySuffix = " " + this.GetSpendingSubjectDisplayName(subjectCode);
    };
    this.transactionUnreadCount += 1;
    if this.transactionUnreadCount > 40 {
      this.transactionUnreadCount = 40;
    };
    this.RefreshLegacyLatestFraudAlert();
    return "Report received. Marmur Bank marked the " + this.FormatEddies(this.transactionAmounts[index]) + " E$" + categorySuffix + " purchase as suspicious. Open the Marmur Bank website, go to Activity, and file a dispute on the matching transaction for review.";
  }

  public func ConfirmLatestFraudAlert() -> String {
    return this.ConfirmFraudAlertAt(this.GetLatestPendingFraudAlertIndex());
  }

  public func FlagLatestFraudAlert() -> String {
    return this.FlagFraudAlertAt(this.GetLatestPendingFraudAlertIndex());
  }

  public func GetTransactionUnreadCount() -> Int32 {
    if this.transactionUnreadCount < 0 {
      this.transactionUnreadCount = 0;
    };
    return this.transactionUnreadCount;
  }

  public func ClearTransactionUnread() -> Void {
    this.transactionUnreadCount = 0;
  }

  public func GetLastTransactionPreview() -> String {
    let count: Int32;
    count = this.GetTransactionLogCount();
    if count <= 0 {
      return this.T(n"mb_loc_002");
    };
    return this.GetTransactionLogAt(count - 1);
  }

  private func MirrorPersistentState() -> Void {
    this.bankBalanceBackup = this.bankBalance;
  }

  public func ForceSetBalance(amount: Int32) -> Bool {
    if amount < 0 {
      amount = 0;
    };

    this.bankBalance = amount;
    this.bankBalanceBackup = amount;
    return true;
  }

  public func SetSavingsBalanceFromLua(gameInstance: GameInstance, amount: Int32) -> Bool {
    if amount < 0 {
      amount = 0;
    };

    this.bankBalance = amount;
    this.bankBalanceBackup = amount;
    if !this.initializedTime {
      this.lastInterestDay = this.GetCurrentDay(gameInstance);
      this.lastInterestHour = this.GetCurrentHour(gameInstance);
      this.initializedTime = true;
    };
    return true;
  }

  public func SetRelationshipTierFromLua(value: Int32) -> Bool {
    if value < 0 {
      value = 0;
    };
    if value > 4 {
      value = 4;
    };
    this.relationshipTier = value;
    this.relationshipTierInitialized = true;
    return true;
  }

  public func GetRelationshipTier() -> Int32 {
    if this.relationshipTier < 0 {
      return 0;
    };
    if this.relationshipTier > 4 {
      return 4;
    };
    return this.relationshipTier;
  }

  public func ImportLegacyBalance(gameInstance: GameInstance, amount: Int32) -> Bool {
    let bankBefore: Int32;
    let walletBalance: Int32;
    let importedAmount: Int32;

    if amount <= 0 {
      return false;
    };

    this.RecoverPersistentState();

    if amount <= this.bankBalance {
      return false;
    };

    bankBefore = this.bankBalance;
    this.bankBalance = amount;

    if this.totalDeposited < amount {
      this.totalDeposited = amount;
    };

    if this.totalDeposited >= this.GetPremiumThreshold() {
      this.premiumUnlocked = true;
    };

    if !this.initializedTime {
      this.lastInterestDay = this.GetCurrentDay(gameInstance);
      this.lastInterestHour = this.GetCurrentHour(gameInstance);
      this.initializedTime = true;
    };

    this.MirrorPersistentState();

    importedAmount = amount - bankBefore;
    if importedAmount <= 0 {
      importedAmount = amount;
    };

    walletBalance = this.GetWalletBalance(gameInstance);
    this.AddTransactionRecord(gameInstance, 5, importedAmount, 0, bankBefore, this.bankBalance, walletBalance, walletBalance);
    return true;
  }

  private func RecoverPersistentState() -> Void {
    if this.bankBalance <= 0 && this.bankBalanceBackup > 0 {
      this.bankBalance = this.bankBalanceBackup;
      this.recoveryCounter += 1;
    };

    if this.bankBalanceBackup < 0 {
      this.bankBalanceBackup = 0;
    };

    if this.bankBalance < 0 {
      this.bankBalance = 0;
    };

    if this.bankBalanceBackup != this.bankBalance {
      this.bankBalanceBackup = this.bankBalance;
    };
  }

  private func GetCurrentDay(gameInstance: GameInstance) -> Int32 {
    let timeSystem = GameInstance.GetTimeSystem(gameInstance);
    let gameTime = timeSystem.GetGameTime();
    return GameTime.Days(gameTime);
  }

  private func GetCurrentHour(gameInstance: GameInstance) -> Int32 {
    let timeSystem = GameInstance.GetTimeSystem(gameInstance);
    let gameTime = timeSystem.GetGameTime();
    return GameTime.Hours(gameTime);
  }

  private func GetCurrentMinute(gameInstance: GameInstance) -> Int32 {
    let timeSystem = GameInstance.GetTimeSystem(gameInstance);
    let gameTime = timeSystem.GetGameTime();
    return GameTime.Minutes(gameTime);
  }

  private func GetAbsoluteHours(day: Int32, hour: Int32) -> Int32 {
    return (day * 24) + hour;
  }

  private func ClampPercent(value: Int32) -> Int32 {
    if value < 0 {
      return 0;
    };
    if value > 100 {
      return 100;
    };
    return value;
  }

  private func GetBaseInterestBasisPoints() -> Int32 {
    return 1;
  }

  private func GetPremiumInterestBasisPointsInternal() -> Int32 {
    return 2;
  }

  private func GetManagedSavingsRateBasisPoints() -> Int32 {
    this.RecoverPersistentState();

    if this.relationshipTierInitialized {
      return this.GetRelationshipTier() + 1;
    };

    if this.bankBalance >= 1000000 {
      return 5;
    };
    if this.bankBalance >= 250000 {
      return 4;
    };
    if this.bankBalance >= 100000 {
      return 3;
    };
    if this.bankBalance >= 25000 {
      return 2;
    };
    if this.IsPremiumUnlocked() {
      return 2;
    };
    return 1;
  }

  public func GetInterestTaxPercent() -> Int32 {
    this.EnsureSettings();
    if !IsDefined(this.settings) {
      return 15;
    };
    return this.ClampPercent(this.settings.interestTaxPercent);
  }

  public func GetPremiumThreshold() -> Int32 {
    this.EnsureSettings();
    if !IsDefined(this.settings) || this.settings.premiumThreshold <= 0 {
      return 2000000;
    };
    return this.settings.premiumThreshold;
  }

  public func GetLanguage() -> NCBankLanguage {
    let value: Int32;

    this.EnsureSettings();
    if !IsDefined(this.settings) {
      return NCBankLanguage.English;
    };

    if Equals(this.settings.language, NCBankLanguageSetting.Japanese) {
      return NCBankLanguage.Japanese;
    };

    value = EnumInt(this.settings.language);
    if value >= EnumInt(NCBankLanguageSetting.Korean) {
      value += 2;
    };

    return IntEnum<NCBankLanguage>(value);
  }

  public func GetLanguageCode() -> String {
    let language: NCBankLanguage = this.GetLanguage();
    if Equals(language, NCBankLanguage.Portuguese) { return "pt-br"; };
    if Equals(language, NCBankLanguage.French) { return "fr-fr"; };
    if Equals(language, NCBankLanguage.ChineseSimplified) { return "zh-cn"; };
    if Equals(language, NCBankLanguage.ChineseTraditional) { return "zh-tw"; };
    if Equals(language, NCBankLanguage.German) { return "de-de"; };
    if Equals(language, NCBankLanguage.Spanish) { return "es-es"; };
    if Equals(language, NCBankLanguage.SpanishMexico) { return "es-mx"; };
    if Equals(language, NCBankLanguage.Japanese) { return "ja-jp"; };
    if Equals(language, NCBankLanguage.Korean) { return "ko-kr"; };
    if Equals(language, NCBankLanguage.Polish) { return "pl-pl"; };
    if Equals(language, NCBankLanguage.Russian) { return "ru-ru"; };
    if Equals(language, NCBankLanguage.Turkish) { return "tr-tr"; };
    if Equals(language, NCBankLanguage.Vietnamese) { return "vi-vn"; };
    return "en-us";
  }

  public func GetLanguageFontFamily() -> String {
    if Equals(this.GetLanguage(), NCBankLanguage.Japanese) {
      return "base\\gameplay\\gui\\fonts\\foreign\\japanese\\mgenplus\\mgenplus.inkfontfamily";
    };
    return "base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily";
  }

  public func IsPremiumUnlocked() -> Bool {
    if this.premiumUnlocked {
      return true;
    };
    if this.totalDeposited >= this.GetPremiumThreshold() {
      this.premiumUnlocked = true;
    };
    return this.premiumUnlocked;
  }

  public func GetCurrentInterestBasisPoints() -> Int32 {
    return this.GetManagedSavingsRateBasisPoints();
  }

  public func GetNetInterestBasisPoints() -> Int32 {
    let rate: Int32;
    let tax: Int32;
    rate = this.GetCurrentInterestBasisPoints();
    tax = this.GetInterestTaxPercent();
    return (rate * (100 - tax) + 50) / 100;
  }

  public func GetBalance() -> Int32 {
    this.RecoverPersistentState();
    return this.bankBalance;
  }

  public func GetWalletBalance(gameInstance: GameInstance) -> Int32 {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return 0;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return 0;
    };

    return ts.GetItemQuantity(player, this.GetMoneyItemID());
  }

  public func GetTotalDeposited() -> Int32 {
    return this.totalDeposited;
  }

  private func SaturatingTransactionTotal(current: Int32, amount: Int32) -> Int32 {
    if current < 0 {
      return 2147483647;
    };
    if amount <= 0 {
      return current;
    };
    if current > 2147483647 - amount {
      return 2147483647;
    };
    return current + amount;
  }

  public func GetTotalWithdrawn() -> Int32 {
    return this.totalWithdrawn;
  }

  public func GetTotalInterestEarned() -> Int32 {
    return this.totalInterestEarned;
  }

  public func GetTotalTaxPaid() -> Int32 {
    return this.totalTaxPaid;
  }

  public func GetPrivateClientServiceFeeEstimate() -> Int32 {
    this.RecoverPersistentState();
    return this.CalculatePrivateClientServiceFee(this.bankBalance);
  }

  public func GetTotalPrivateClientFeesPaid() -> Int32 {
    return this.totalPrivateClientFeesPaid;
  }

  public func GetRecoveryCount() -> Int32 {
    return this.recoveryCounter;
  }

  public func GetPremiumProgress() -> Int32 {
    let threshold: Int32;
    threshold = this.GetPremiumThreshold();
    if this.totalDeposited >= threshold {
      return threshold;
    };
    return this.totalDeposited;
  }


  public func GetLoanOfferCount() -> Int32 {
    return 5;
  }

  private func IsLoanOfferIndexValid(index: Int32) -> Bool {
    return index >= 1 && index <= this.GetLoanOfferCount();
  }

  public func GetLoanPrincipalAt(index: Int32) -> Int32 {
    if Equals(index, 1) {
      return 50000;
    };
    if Equals(index, 2) {
      return 1000000;
    };
    if Equals(index, 3) {
      return 5000000;
    };
    if Equals(index, 4) {
      return 25000000;
    };
    if Equals(index, 5) {
      return 100000000;
    };
    return 0;
  }

  public func GetLoanRequiredStreetCredAt(index: Int32) -> Int32 {
    if Equals(index, 1) {
      return 1;
    };
    if Equals(index, 2) {
      return 8;
    };
    if Equals(index, 3) {
      return 15;
    };
    if Equals(index, 4) {
      return 29;
    };
    if Equals(index, 5) {
      return 50;
    };
    return 999;
  }

  public func GetLoanInterestBasisPointsAt(index: Int32) -> Int32 {
    if Equals(index, 1) {
      return 2400;
    };
    if Equals(index, 2) {
      return 2122;
    };
    if Equals(index, 3) {
      return 1843;
    };
    if Equals(index, 4) {
      return 1286;
    };
    if Equals(index, 5) {
      return 450;
    };
    return 0;
  }

  public func GetLoanTermPaymentsAt(index: Int32) -> Int32 {
    if !this.IsLoanOfferIndexValid(index) {
      return 0;
    };
    if Equals(index, 1) {
      return 12;
    };
    if Equals(index, 2) {
      return 24;
    };
    if Equals(index, 3) {
      return 36;
    };
    if Equals(index, 4) {
      return 60;
    };
    if Equals(index, 5) {
      return 84;
    };
    return 12;
  }

  public func GetLoanPaymentIntervalDays() -> Int32 {
    return 30;
  }

  public func GetLoanTotalDueAt(index: Int32) -> Int32 {
    let principal: Int32;
    let rate: Int32;
    let interest: Int32;
    let principalFloat: Float;
    let rateFloat: Float;

    if !this.IsLoanOfferIndexValid(index) {
      return 0;
    };

    principal = this.GetLoanPrincipalAt(index);
    rate = this.GetLoanInterestBasisPointsAt(index);
    principalFloat = Cast<Float>(principal);
    rateFloat = Cast<Float>(rate);
    interest = Cast<Int32>((principalFloat * rateFloat / 10000.0) + 0.5);
    return principal + interest;
  }

  public func GetLoanInstallmentAt(index: Int32) -> Int32 {
    let totalDue: Int32;
    let term: Int32;

    if !this.IsLoanOfferIndexValid(index) {
      return 0;
    };

    totalDue = this.GetLoanTotalDueAt(index);
    term = this.GetLoanTermPaymentsAt(index);
    if term <= 0 {
      return totalDue;
    };
    return (totalDue + term - 1) / term;
  }

  private func CloseLoanIfPaid() -> Void {
    if this.loanBalanceDue <= 0 {
      this.loanActive = false;
      this.loanBalanceDue = 0;
      this.loanInstallmentAmount = 0;
      this.loanNextDueDay = 0;
    };
  }

  public func HasActiveLoan() -> Bool {
    if this.loanActive && this.loanBalanceDue <= 0 {
      this.CloseLoanIfPaid();
    };
    return this.loanActive;
  }

  public func GetLoanOfferIndex() -> Int32 {
    return this.loanOfferIndex;
  }

  public func GetLoanPrincipal() -> Int32 {
    return this.loanPrincipal;
  }

  public func GetLoanOriginalDue() -> Int32 {
    return this.loanOriginalDue;
  }

  public func GetLoanBalanceDue() -> Int32 {
    this.CloseLoanIfPaid();
    return this.loanBalanceDue;
  }

  public func GetLoanEarlyPayoffAmount() -> Int32 {
    let payoff: Int32;
    let principalFloat: Float;
    let balanceFloat: Float;
    let originalFloat: Float;

    this.CloseLoanIfPaid();
    if !this.loanActive || this.loanBalanceDue <= 0 {
      return 0;
    };
    if this.loanPrincipal <= 0 {
      return this.loanBalanceDue;
    };
    if this.loanOriginalDue <= this.loanPrincipal {
      if this.loanBalanceDue < this.loanPrincipal {
        return this.loanBalanceDue;
      };
      return this.loanPrincipal;
    };

    principalFloat = Cast<Float>(this.loanPrincipal);
    balanceFloat = Cast<Float>(this.loanBalanceDue);
    originalFloat = Cast<Float>(this.loanOriginalDue);
    payoff = Cast<Int32>((principalFloat * balanceFloat / originalFloat) + 0.999);
    if payoff < 0 {
      payoff = 0;
    };
    if payoff > this.loanBalanceDue {
      payoff = this.loanBalanceDue;
    };
    return payoff;
  }

  public func GetLoanInterestWaivedByEarlyPayoff() -> Int32 {
    let waived: Int32;
    waived = this.loanBalanceDue - this.GetLoanEarlyPayoffAmount();
    if waived < 0 { return 0; };
    return waived;
  }

  public func GetLoanInstallmentAmount() -> Int32 {
    return this.loanInstallmentAmount;
  }

  public func GetLoanInterestBasisPoints() -> Int32 {
    return this.loanInterestBasisPoints;
  }

  public func GetLoanTermPayments() -> Int32 {
    return this.loanTermPayments;
  }

  public func GetLoanPaymentsMade() -> Int32 {
    return this.loanPaymentsMade;
  }

  public func GetLoanStartDay() -> Int32 {
    return this.loanStartDay;
  }

  public func GetLoanNextDueDay() -> Int32 {
    return this.loanNextDueDay;
  }

  public func GetLoanMissedPayments() -> Int32 {
    return this.loanMissedPayments;
  }

  public func GetTotalLoanBorrowed() -> Int32 {
    return this.totalLoanBorrowed;
  }

  public func GetTotalLoanRepaid() -> Int32 {
    return this.totalLoanRepaid;
  }



  public func ClearLoanMissedPayments() -> Void {
    this.loanMissedPayments = 0;
  }

  public func ApplyExternalLoanRecovery(gameInstance: GameInstance, amount: Int32) -> Bool {
    let credit: Int32;

    this.SyncInterest(gameInstance);
    this.CloseLoanIfPaid();
    if !this.loanActive || this.loanBalanceDue <= 0 {
      return false;
    };
    if amount <= 0 {
      return false;
    };

    credit = amount;
    if credit > this.loanBalanceDue {
      credit = this.loanBalanceDue;
    };
    if credit <= 0 {
      return false;
    };

    this.loanBalanceDue -= credit;
    this.totalLoanRepaid += credit;
    this.loanLastPaymentDay = this.GetCurrentDay(gameInstance);
    this.CloseLoanIfPaid();
    if !this.loanActive {
      this.loanMissedPayments = 0;
    };
    return true;
  }

  public func RequestLoan(gameInstance: GameInstance, offerIndex: Int32, streetCredLevel: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let principal: Int32;
    let totalDue: Int32;
    let term: Int32;
    let currentDay: Int32;

    this.SyncInterest(gameInstance);
    this.SyncLoanPayments(gameInstance);

    this.CloseLoanIfPaid();
    if this.loanActive {
      return false;
    };

    if !this.IsLoanOfferIndexValid(offerIndex) {
      return false;
    };

    if this.GetLoanRequiredStreetCredAt(offerIndex) > 0 && streetCredLevel < this.GetLoanRequiredStreetCredAt(offerIndex) {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    principal = this.GetLoanPrincipalAt(offerIndex);
    totalDue = this.GetLoanTotalDueAt(offerIndex);
    term = this.GetLoanTermPaymentsAt(offerIndex);
    currentDay = this.GetCurrentDay(gameInstance);

    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    ts.GiveItem(player, this.GetMoneyItemID(), principal);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());

    this.loanActive = true;
    this.loanOfferIndex = offerIndex;
    this.loanPrincipal = principal;
    this.loanOriginalDue = totalDue;
    this.loanBalanceDue = totalDue;
    this.loanInstallmentAmount = this.GetLoanInstallmentAt(offerIndex);
    this.loanInterestBasisPoints = this.GetLoanInterestBasisPointsAt(offerIndex);
    this.loanTermPayments = term;
    this.loanPaymentsMade = 0;
    this.loanStartDay = currentDay;
    this.loanNextDueDay = currentDay + this.GetLoanPaymentIntervalDays();
    this.loanLastPaymentDay = currentDay;
    this.loanMissedPayments = 0;
    this.totalLoanBorrowed += principal;

    this.RecordLoanDisbursementTransaction(gameInstance, principal, walletBefore, walletAfter);
    return true;
  }

  public func PayLoan(gameInstance: GameInstance, amount: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let debit: Int32;

    this.SyncInterest(gameInstance);
    this.SyncLoanPayments(gameInstance);

    if !this.loanActive || this.loanBalanceDue <= 0 {
      return false;
    };

    if amount <= 0 {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    debit = amount;
    if debit > walletBefore {
      debit = walletBefore;
    };
    if debit > this.loanBalanceDue {
      debit = this.loanBalanceDue;
    };
    if debit <= 0 {
      return false;
    };

    this.SuppressWalletDebit(debit);
    ts.GiveItem(player, this.GetMoneyItemID(), -debit);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.loanBalanceDue -= debit;
    this.totalLoanRepaid += debit;
    this.loanLastPaymentDay = this.GetCurrentDay(gameInstance);
    this.RecordLoanManualPaymentTransaction(gameInstance, debit, walletBefore, walletAfter);
    this.CloseLoanIfPaid();
    return true;
  }

  public func PayLoanInFull(gameInstance: GameInstance) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let debit: Int32;

    this.SyncInterest(gameInstance);
    this.SyncLoanPayments(gameInstance);

    if !this.loanActive || this.loanBalanceDue <= 0 {
      return false;
    };

    debit = this.GetLoanEarlyPayoffAmount();
    if debit <= 0 {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    if debit > walletBefore {
      return false;
    };

    this.SuppressWalletDebit(debit);
    ts.GiveItem(player, this.GetMoneyItemID(), -debit);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.loanBalanceDue = 0;
    this.totalLoanRepaid += debit;
    this.loanLastPaymentDay = this.GetCurrentDay(gameInstance);
    this.RecordLoanManualPaymentTransaction(gameInstance, debit, walletBefore, walletAfter);
    this.CloseLoanIfPaid();
    return true;
  }

  public func SyncLoanPayments(gameInstance: GameInstance) -> Void {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let currentDay: Int32;
    let dueAmount: Int32;
    let debit: Int32;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let loopGuard: Int32 = 0;

    if !this.loanActive || this.loanBalanceDue <= 0 {
      this.CloseLoanIfPaid();
      return;
    };

    currentDay = this.GetCurrentDay(gameInstance);

    if this.loanNextDueDay <= 0 {
      this.loanNextDueDay = currentDay + this.GetLoanPaymentIntervalDays();
      return;
    };

    if currentDay < this.loanNextDueDay {
      return;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return;
    };

    while this.loanActive && currentDay >= this.loanNextDueDay && loopGuard < 24 {
      dueAmount = this.loanInstallmentAmount;
      if dueAmount <= 0 {
        dueAmount = this.loanBalanceDue;
      };
      if dueAmount > this.loanBalanceDue {
        dueAmount = this.loanBalanceDue;
      };

      walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
      debit = dueAmount;
      if debit > walletBefore {
        debit = walletBefore;
      };

      if debit > 0 {
        this.SuppressWalletDebit(debit);
        ts.GiveItem(player, this.GetMoneyItemID(), -debit);
        walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
        this.loanBalanceDue -= debit;
        this.totalLoanRepaid += debit;
        this.loanPaymentsMade += 1;
        this.loanLastPaymentDay = this.loanNextDueDay;
        this.RecordLoanAutoPaymentTransaction(gameInstance, debit, walletBefore, walletAfter);
      } else {
        walletAfter = walletBefore;
        this.RecordLoanMissedPaymentTransaction(gameInstance, dueAmount, walletBefore);
      };

      if debit < dueAmount && this.loanActive {
        this.loanMissedPayments += 1;
      };

      this.CloseLoanIfPaid();
      if this.loanActive {
        this.loanNextDueDay += this.GetLoanPaymentIntervalDays();
      };
      loopGuard += 1;
    };

    if this.loanActive && currentDay >= this.loanNextDueDay {
      this.loanNextDueDay = currentDay + this.GetLoanPaymentIntervalDays();
    };
  }


  private func CalculatePrivateClientServiceFee(balance: Int32) -> Int32 {
    return 0;
  }

  private func SyncPrivateClientServiceFee(gameInstance: GameInstance) -> Void {
    let currentDay: Int32;
    let feeAmount: Int32;
    let chargeAmount: Int32;
    let bankBefore: Int32;
    let loopGuard: Int32 = 0;

    currentDay = this.GetCurrentDay(gameInstance);
    if !this.privateClientFeeInitialized {
      this.lastPrivateClientFeeDay = currentDay;
      this.privateClientFeeInitialized = true;
      return;
    };

    while currentDay - this.lastPrivateClientFeeDay >= 30 && loopGuard < 12 {
      this.lastPrivateClientFeeDay += 30;
      feeAmount = this.CalculatePrivateClientServiceFee(this.bankBalance);
      if feeAmount > 0 && this.bankBalance > 0 {
        chargeAmount = feeAmount;
        if chargeAmount > this.bankBalance {
          chargeAmount = this.bankBalance;
        };
        if chargeAmount > 0 {
          bankBefore = this.bankBalance;
          this.bankBalance -= chargeAmount;
          this.totalPrivateClientFeesPaid += chargeAmount;
          this.RecordPrivateClientFeeTransaction(gameInstance, chargeAmount, bankBefore, this.bankBalance);
        };
      };
      loopGuard += 1;
    };
  }

  private func SyncObsidianCheckingFee(gameInstance: GameInstance) -> Void {
    let currentDay: Int32;
    let feeAmount: Int32;
    let chargeAmount: Int32;
    let bankBefore: Int32;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let loopGuard: Int32 = 0;

    currentDay = this.GetCurrentDay(gameInstance);
    if !this.monthlyFeeInitialized {
      this.lastMonthlyFeeDay = currentDay;
      this.monthlyFeeInitialized = true;
      return;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return;
    };

    while currentDay - this.lastMonthlyFeeDay >= 30 && loopGuard < 12 {
      this.lastMonthlyFeeDay += 30;
      feeAmount = 100;
      walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
      if walletBefore > 0 && walletBefore < 10000 {
        chargeAmount = feeAmount;
        if chargeAmount > walletBefore {
          chargeAmount = walletBefore;
        };
        if chargeAmount > 0 {
          bankBefore = this.bankBalance;
          this.SuppressWalletDebit(chargeAmount);
          ts.GiveItem(player, this.GetMoneyItemID(), -chargeAmount);
          walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
          this.RecordCheckingFeeTransaction(gameInstance, chargeAmount, bankBefore, this.bankBalance, walletBefore, walletAfter);
        };
      };
      loopGuard += 1;
    };
  }

  public func SyncInterest(gameInstance: GameInstance) -> Void {
    let currentDay: Int32;
    let currentHour: Int32;
    let lastAbs: Int32;
    let currentAbs: Int32;
    let passedHours: Int32;
    let passedDays: Int32;
    let idx: Int32;
    let grossProfit: Int32;
    let taxAmount: Int32;
    let netProfit: Int32;
    let bankBefore: Int32;
    let balanceFloat: Float;
    let rateFloat: Float;

    this.RecoverPersistentState();
    this.EnsureSettings();

    currentDay = this.GetCurrentDay(gameInstance);
    currentHour = this.GetCurrentHour(gameInstance);

    if !this.initializedTime {
      this.lastInterestDay = currentDay;
      this.lastInterestHour = currentHour;
      if !this.monthlyFeeInitialized {
        this.lastMonthlyFeeDay = currentDay;
        this.monthlyFeeInitialized = true;
      };
      if !this.privateClientFeeInitialized {
        this.lastPrivateClientFeeDay = currentDay;
        this.privateClientFeeInitialized = true;
      };
      this.initializedTime = true;
      this.MirrorPersistentState();
      return;
    };

    lastAbs = this.GetAbsoluteHours(this.lastInterestDay, this.lastInterestHour);
    currentAbs = this.GetAbsoluteHours(currentDay, currentHour);

    if currentAbs <= lastAbs {
      return;
    };

    passedHours = currentAbs - lastAbs;
    passedDays = passedHours / 24;

    if passedDays <= 0 {
      return;
    };

    this.SyncObsidianCheckingFee(gameInstance);
    this.SyncPrivateClientServiceFee(gameInstance);

    idx = 0;
    while idx < passedDays {
      balanceFloat = Cast<Float>(this.bankBalance);
      rateFloat = Cast<Float>(this.GetCurrentInterestBasisPoints());
      grossProfit = Cast<Int32>((balanceFloat * rateFloat / 10000.0) + 0.5);
      if grossProfit > 0 {
        taxAmount = Cast<Int32>((Cast<Float>(grossProfit) * Cast<Float>(this.GetInterestTaxPercent()) / 100.0) + 0.5);
        netProfit = grossProfit - taxAmount;
        if netProfit < 0 {
          netProfit = 0;
        };
        bankBefore = this.bankBalance;
        this.bankBalance += netProfit;
        this.totalInterestEarned += netProfit;
        this.totalTaxPaid += taxAmount;
        this.RecordInterestTransaction(gameInstance, netProfit, taxAmount, bankBefore, this.bankBalance);
      };
      idx += 1;
    };

    this.lastInterestDay = currentDay;
    this.lastInterestHour = currentHour;
    this.MirrorPersistentState();
  }

  public func DepositFromWallet(gameInstance: GameInstance, amount: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let wallet: Int32;
    let walletAfter: Int32;
    let bankBefore: Int32;

    this.SyncInterest(gameInstance);

    if amount <= 0 {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    wallet = ts.GetItemQuantity(player, this.GetMoneyItemID());
    if wallet < amount {
      return false;
    };

    bankBefore = this.bankBalance;
    this.SuppressWalletDebit(amount);
    ts.GiveItem(player, this.GetMoneyItemID(), -amount);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.bankBalance += amount;
    this.totalDeposited = this.SaturatingTransactionTotal(this.totalDeposited, amount);
    if this.totalDeposited >= this.GetPremiumThreshold() {
      this.premiumUnlocked = true;
    };
    this.MirrorPersistentState();
    this.RecordDepositTransaction(gameInstance, amount, bankBefore, this.bankBalance, wallet, walletAfter);
    return true;
  }

  public func WithdrawToWallet(gameInstance: GameInstance, amount: Int32) -> Bool {
    let player: ref<PlayerPuppet>;
    let ts: ref<TransactionSystem>;
    let walletBefore: Int32;
    let walletAfter: Int32;
    let bankBefore: Int32;

    this.SyncInterest(gameInstance);

    if amount <= 0 {
      return false;
    };

    if this.bankBalance < amount {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    ts = GameInstance.GetTransactionSystem(gameInstance);
    if !IsDefined(ts) {
      return false;
    };

    bankBefore = this.bankBalance;
    walletBefore = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.bankBalance -= amount;
    this.totalWithdrawn = this.SaturatingTransactionTotal(this.totalWithdrawn, amount);
    this.MirrorPersistentState();
    ts.GiveItem(player, this.GetMoneyItemID(), amount);
    walletAfter = ts.GetItemQuantity(player, this.GetMoneyItemID());
    this.RecordWithdrawTransaction(gameInstance, amount, bankBefore, this.bankBalance, walletBefore, walletAfter);
    this.MirrorPersistentState();
    return true;
  }
}
