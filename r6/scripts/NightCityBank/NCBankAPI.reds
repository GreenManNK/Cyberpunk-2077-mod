module NightCityBank
public class NCBankAPI {

  public static func IsRuntimeReady(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };
    return qs.GetFact(n"marmur_bank_zero_engine_ready") > 0;
  }

  public static func IsAccountOpen(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };

    return qs.GetFact(n"marmur_account_open") > 0
      && qs.GetFact(n"marmur_account_ever_opened") > 0;
  }

  public static func IsAutoFinanceAvailable(gameInstance: GameInstance) -> Bool {
    return NCBankAPI.IsRuntimeReady(gameInstance)
      && NCBankAPI.IsAccountOpen(gameInstance)
      && IsDefined(NCBankAPI.GetSystem(gameInstance));
  }

  public static func GetSystem(gameInstance: GameInstance) -> ref<NCBankSystem> {
    if !NCBankAPI.IsRuntimeReady(gameInstance) {
      return null;
    };
    return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityBank.NCBankSystem") as NCBankSystem;
  }

  public static func GetBalance(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);

    if IsDefined(system) {
      system.SyncInterest(gameInstance);
      return system.GetBalance();
    };

    return 0;
  }

  public static func GetWalletBalance(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);

    if IsDefined(system) {
      return system.GetWalletBalance(gameInstance);
    };

    return 0;
  }

  public static func Deposit(gameInstance: GameInstance, amount: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);

    if IsDefined(system) {
      return system.DepositFromWallet(gameInstance, amount);
    };

    return false;
  }

  public static func Withdraw(gameInstance: GameInstance, amount: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);

    if IsDefined(system) {
      return system.WithdrawToWallet(gameInstance, amount);
    };

    return false;
  }

  public static func GetTotalDeposited(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetTotalDeposited();
    };
    return 0;
  }

  public static func GetTotalWithdrawn(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetTotalWithdrawn();
    };
    return 0;
  }

  public static func GetTotalInterestEarned(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetTotalInterestEarned();
    };
    return 0;
  }

  public static func GetTotalTaxPaid(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetTotalTaxPaid();
    };
    return 0;
  }

  public static func GetRecoveryCount(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetRecoveryCount();
    };
    return 0;
  }

  public static func GetCurrentInterestBasisPoints(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetCurrentInterestBasisPoints();
    };
    return 75;
  }

  public static func GetNetInterestBasisPoints(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetNetInterestBasisPoints();
    };
    return 64;
  }

  public static func GetInterestTaxPercent(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetInterestTaxPercent();
    };
    return 15;
  }

  public static func GetPremiumThreshold(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetPremiumThreshold();
    };
    return 2000000;
  }

  public static func GetPremiumProgress(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetPremiumProgress();
    };
    return 0;
  }

  public static func IsPremiumUnlocked(gameInstance: GameInstance) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.IsPremiumUnlocked();
    };
    return false;
  }



  public static func GetLoanOfferCount(gameInstance: GameInstance) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanOfferCount();
    };
    return 5;
  }

  public static func GetLoanPrincipalAt(gameInstance: GameInstance, index: Int32) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanPrincipalAt(index);
    };
    return 0;
  }

  public static func GetLoanRequiredStreetCredAt(gameInstance: GameInstance, index: Int32) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanRequiredStreetCredAt(index);
    };
    return 999;
  }

  public static func GetLoanInterestBasisPointsAt(gameInstance: GameInstance, index: Int32) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanInterestBasisPointsAt(index);
    };
    return 0;
  }

  public static func GetLoanTotalDueAt(gameInstance: GameInstance, index: Int32) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanTotalDueAt(index);
    };
    return 0;
  }

  public static func GetLoanInstallmentAt(gameInstance: GameInstance, index: Int32) -> Int32 {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLoanInstallmentAt(index);
    };
    return 0;
  }

  public static func HasActiveLoan(gameInstance: GameInstance) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.HasActiveLoan();
    };
    return false;
  }

  public static func RequestLoan(gameInstance: GameInstance, offerIndex: Int32, streetCredLevel: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.RequestLoan(gameInstance, offerIndex, streetCredLevel);
    };
    return false;
  }

  public static func PayLoan(gameInstance: GameInstance, amount: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.PayLoan(gameInstance, amount);
    };
    return false;
  }

  public static func PayLoanInFull(gameInstance: GameInstance) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.PayLoanInFull(gameInstance);
    };
    return false;
  }

  public static func SyncLoanPayments(gameInstance: GameInstance) -> Void {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      system.SyncLoanPayments(gameInstance);
    };
  }

  public static func TransferCheckingToExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.TransferCheckingToExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight);
    };
    return false;
  }

  public static func TransferSavingsToExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.TransferSavingsToExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight);
    };
    return false;
  }

  public static func ReceiveCheckingFromExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.ReceiveCheckingFromExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight);
    };
    return false;
  }

  public static func ReceiveSavingsFromExternalPartner(gameInstance: GameInstance, amount: Int32, partnerCode: Int32, confirmationLeft: Int32, confirmationRight: Int32) -> Bool {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.ReceiveSavingsFromExternalPartner(gameInstance, amount, partnerCode, confirmationLeft, confirmationRight);
    };
    return false;
  }
  public static func GetLanguage(gameInstance: GameInstance) -> NCBankLanguage {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLanguage();
    };
    return NCBankLanguage.English;
  }

  public static func GetLanguageCode(gameInstance: GameInstance) -> String {
    let system: ref<NCBankSystem>;
    system = NCBankAPI.GetSystem(gameInstance);
    if IsDefined(system) {
      return system.GetLanguageCode();
    };
    return "en-us";
  }
}
