module MarmurBankVanguardAutoPaymentSourceV2

import NightCityBank.NCBankAPI

public abstract class MarmurVanguardAutoPaymentSourceAPI {

  public static func GetVersion() -> Int32 {
    return 3;
  }

  public static func IsAvailable(gameInstance: GameInstance) -> Bool {
    return NCBankAPI.IsAutoFinanceAvailable(gameInstance);
  }

  public static func DebitSavings(gameInstance: GameInstance, amount: Int32, contractSerial: Int32, paymentMinute: Int32) -> Bool {
    if amount <= 0 || contractSerial <= 0 {
      return false;
    };

    return NCBankAPI.TransferSavingsToExternalPartner(
      gameInstance,
      amount,
      201,
      contractSerial,
      paymentMinute
    );
  }
}
