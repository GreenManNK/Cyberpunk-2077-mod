module MarmurBankPhone

import NightlyNow.Holo.*
import NightCityBank.*
public static func MarmurBankContactHash() -> Int32 = 76042077

public enum MarmurBankReplyID {
  AccountSummary = 1,
  RecentActivity = 2,
  ClearAlerts = 3,
  Done = 4,
  ConfirmLatestPurchase = 5,
  ReportSuspiciousPurchase = 6,
}

public class MarmurBankPhoneEventsListener extends ContactHandler {
  private let m_player: wref<PlayerPuppet>;
  private let m_messengerController: wref<MessengerDialogViewController>;
  private let m_activeFraudSource: Int32;
  private let m_activeFraudIndex: Int32;

  public func Init(player: ref<PlayerPuppet>) -> Void {
    this.m_player = player;
  }

  public func GetHash() -> Int32 = MarmurBankContactHash()

  public func GetContactLocalizedName() -> String = "Marmur Bank"


  private func SyncNightlyUnread(unread: Bool) -> Void {
    let holo: ref<HoloSystem>;
    if IsDefined(this.m_player) {
      holo = HoloSystem.Get(this.m_player);
    };
    if !IsDefined(holo) {
      return;
    };
    if unread {
      holo.MarkContactUnread(this.GetHash());
    } else {
      holo.MarkContactRead(this.GetHash());
    };
  }

  private func GetBankSystem() -> ref<NCBankSystem> {
    let system: ref<NCBankSystem>;
    if IsDefined(this.m_player) {
      system = NCBankAPI.GetSystem(this.m_player.GetGame());
    };
    return system;
  }

  private func T(key: CName) -> String {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    if IsDefined(system) {
      return system.GetLocalizedText(key);
    };
    return NCBankLocalization.Get(NCBankLanguage.English, key);
  }

  private func UsesJapaneseLanguageFont() -> Bool {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    if !IsDefined(system) {
      return false;
    };
    return Equals(system.GetLanguage(), NCBankLanguage.Japanese);
  }

  private func ApplyLanguageFont(widget: wref<inkCompoundWidget>, depth: Int32, fontFamily: String) -> Void {
    let i: Int32 = 0;
    let limit: Int32;
    let child: wref<inkWidget>;
    let textWidget: wref<inkText>;
    let childCompound: wref<inkCompoundWidget>;

    if !IsDefined(widget) || depth > 24 {
      return;
    };

    limit = widget.GetNumChildren();
    while i < limit {
      child = widget.GetWidgetByIndex(i);
      textWidget = child as inkText;
      if IsDefined(textWidget) {
        textWidget.SetFontFamily(fontFamily);
      };
      childCompound = child as inkCompoundWidget;
      if IsDefined(childCompound) {
        this.ApplyLanguageFont(childCompound, depth + 1, fontFamily);
      };
      i += 1;
    };
  }

  private func ApplyLanguageFontToDialog() -> Void {
    let system: ref<NCBankSystem>;
    let root: wref<inkCompoundWidget>;

    if !this.UsesJapaneseLanguageFont() || !IsDefined(this.m_messengerController) {
      return;
    };

    system = this.GetBankSystem();
    if !IsDefined(system) {
      return;
    };

    root = this.m_messengerController.GetRootCompoundWidget();
    this.ApplyLanguageFont(root, 0, system.GetLanguageFontFamily());
  }

  private func FormatMoney(system: ref<NCBankSystem>, value: Int32) -> String {
    if IsDefined(system) {
      return system.FormatEddies(value) + " E$";
    };
    return ToString(value) + " E$";
  }


  private func GetQuestFactSafe(factName: CName) -> Int32 {
    let qs: ref<QuestsSystem>;
    if IsDefined(this.m_player) {
      qs = GameInstance.GetQuestsSystem(this.m_player.GetGame());
      if IsDefined(qs) {
        return qs.GetFact(factName);
      };
    };
    return 0;
  }

  private func SetQuestFactSafe(factName: CName, value: Int32) -> Void {
    let qs: ref<QuestsSystem>;
    if IsDefined(this.m_player) {
      qs = GameInstance.GetQuestsSystem(this.m_player.GetGame());
      if IsDefined(qs) {
        qs.SetFact(factName, value);
      };
    };
  }

  private func HasCreatedAccount() -> Bool {
    return this.GetQuestFactSafe(n"marmur_account_ever_opened") > 0;
  }

  private func GetLoanSmsReadCount() -> Int32 {
    let count: Int32 = this.GetQuestFactSafe(n"marmur_loan_sms_read_count");
    if count < 0 { return 0; };
    return count;
  }

  private func GetWalletTxReadCount() -> Int32 {
    let count: Int32 = this.GetQuestFactSafe(n"marmur_wallet_tx_read_count");
    if count < 0 { return 0; };
    return count;
  }

  private func GetExternalUnreadCount() -> Int32 {
    let unread: Int32 = 0;
    let loanCount: Int32 = this.GetLoanSmsCount();
    let walletCount: Int32 = this.GetWalletTxRawCount();
    let loanRead: Int32 = this.GetLoanSmsReadCount();
    let walletRead: Int32 = this.GetWalletTxReadCount();

    if loanCount > loanRead {
      unread += loanCount - loanRead;
    };
    if walletCount > walletRead {
      unread += walletCount - walletRead;
    };
    return unread;
  }

  private func MarkExternalAlertsRead() -> Void {
    this.SetQuestFactSafe(n"marmur_loan_sms_read_count", this.GetLoanSmsCount());
    this.SetQuestFactSafe(n"marmur_wallet_tx_read_count", this.GetWalletTxRawCount());
  }

  private func GetLoanSmsCount() -> Int32 {
    let count: Int32 = this.GetQuestFactSafe(n"marmur_loan_sms_count");
    if count < 0 {
      return 0;
    };
    if count > 5 {
      return 5;
    };
    return count;
  }

  private func GetLoanSmsType(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_type_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_type_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_type_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_type_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_type_5"); };
    return 0;
  }

  private func GetLoanSmsAmount(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_amount_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_amount_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_amount_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_amount_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_amount_5"); };
    return 0;
  }

  private func GetLoanSmsWalletBefore(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_before_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_before_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_before_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_before_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_before_5"); };
    return 0;
  }

  private func GetLoanSmsWalletAfter(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_after_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_after_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_after_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_after_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_wallet_after_5"); };
    return 0;
  }

  private func GetLoanSmsConfirmLeft(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_left_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_left_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_left_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_left_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_left_5"); };
    return 0;
  }

  private func GetLoanSmsConfirmRight(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_right_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_right_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_right_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_right_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_conf_right_5"); };
    return 0;
  }

  private func GetLoanSmsDay(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_day_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_day_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_day_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_day_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_day_5"); };
    return 0;
  }

  private func GetLoanSmsHour(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_hour_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_hour_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_hour_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_hour_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_hour_5"); };
    return 0;
  }

  private func GetLoanSmsMinute(slot: Int32) -> Int32 {
    if Equals(slot, 1) { return this.GetQuestFactSafe(n"marmur_loan_sms_minute_1"); };
    if Equals(slot, 2) { return this.GetQuestFactSafe(n"marmur_loan_sms_minute_2"); };
    if Equals(slot, 3) { return this.GetQuestFactSafe(n"marmur_loan_sms_minute_3"); };
    if Equals(slot, 4) { return this.GetQuestFactSafe(n"marmur_loan_sms_minute_4"); };
    if Equals(slot, 5) { return this.GetQuestFactSafe(n"marmur_loan_sms_minute_5"); };
    return 0;
  }

  private func FormatClockTime(hour: Int32, minute: Int32) -> String {
    let displayHour: Int32 = hour;
    let suffix: String = "AM";
    let m: String;

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
    if minute < 10 { m = "0" + ToString(minute); } else { m = ToString(minute); };

    return ToString(displayHour) + ":" + m + " " + suffix;
  }

  private func BuildLoanSmsTimestamp(slot: Int32) -> String {
    return this.FormatClockTime(this.GetLoanSmsHour(slot), this.GetLoanSmsMinute(slot));
  }

  private func Pad4(value: Int32) -> String {
    let safe: Int32 = value % 10000;
    if safe < 0 { safe = 0; };
    if safe < 10 { return "000" + ToString(safe); };
    if safe < 100 { return "00" + ToString(safe); };
    if safe < 1000 { return "0" + ToString(safe); };
    return ToString(safe);
  }

  private func Pad6(value: Int32) -> String {
    let safe: Int32 = value % 1000000;
    if safe < 0 { safe = 0; };
    if safe < 10 { return "00000" + ToString(safe); };
    if safe < 100 { return "0000" + ToString(safe); };
    if safe < 1000 { return "000" + ToString(safe); };
    if safe < 10000 { return "00" + ToString(safe); };
    if safe < 100000 { return "0" + ToString(safe); };
    return ToString(safe);
  }

  private func GetLoanSmsPrefix(eventType: Int32) -> String {
    if Equals(eventType, 1) { return "APP"; };
    if Equals(eventType, 2) { return "PAY"; };
    if Equals(eventType, 3) { return "AUT"; };
    if Equals(eventType, 4) { return "MIS"; };
    if Equals(eventType, 5) { return "REQ"; };
    if Equals(eventType, 6) { return "DEN"; };
    if Equals(eventType, 7) { return "APR"; };
    if Equals(eventType, 8) { return "SIG"; };
    if Equals(eventType, 9) { return "FUL"; };
    if Equals(eventType, 10) { return "REM"; };
    if Equals(eventType, 11) { return "AOP"; };
    if Equals(eventType, 12) { return "ARB"; };
    if Equals(eventType, 13) { return "BON"; };
    if Equals(eventType, 14) { return "CBK"; };
    if Equals(eventType, 15) { return "AAL"; };
    if Equals(eventType, 16) { return "APY"; };
    if Equals(eventType, 17) { return "AFU"; };
    if Equals(eventType, 18) { return "ADE"; };
    if Equals(eventType, 19) { return "LQD"; };
    if Equals(eventType, 20) { return "VCN"; };
    if Equals(eventType, 21) { return "VCD"; };
    return "LN";
  }

  private func GetAutoLoanFrequencyLabel(encoded: Int32) -> String {
    let frequency: Int32;
    if encoded >= 100000 {
      frequency = (encoded / 10) % 10;
    } else {
      frequency = encoded % 10;
    };
    if Equals(frequency, 1) { return "weekly"; };
    if Equals(frequency, 2) { return "bi-weekly"; };
    return "monthly";
  }

  private func GetAutoLoanTermMonths(encoded: Int32) -> Int32 {
    let term: Int32;
    if encoded >= 100000 {
      term = (encoded - 100000) / 100;
    } else {
      term = encoded / 10;
    };
    if term <= 0 { return 60; };
    return term;
  }

  private func GetAutoLoanAutoPayApprovalText(encoded: Int32) -> String {
    let requestCode: Int32;
    let frequency: String = this.GetAutoLoanFrequencyLabel(encoded);
    if encoded < 100000 {
      return " Auto-Pay request status was unavailable from this Vanguard version. Review the loan in Marmur Bank.";
    };

    requestCode = encoded % 10;
    if Equals(requestCode, 2) {
      return " Auto-Pay request received: ON. Marmur Bank will service the " + frequency + " schedule automatically.";
    };
    if Equals(requestCode, 1) {
      return " Auto-Pay request received: OFF. The " + frequency + " schedule remains available for manual approval.";
    };
    return " Auto-Pay request status was unavailable. Review the loan in Marmur Bank.";
  }

  private func GetVanguardCoverageVehicleName(contractIndex: Int32) -> String {
    return "the financed Vanguard Auto vehicle";
  }

  private func BuildLoanSmsConfirmation(eventType: Int32, slot: Int32) -> String {
    return "MB-" + this.GetLoanSmsPrefix(eventType) + "-" + this.Pad4(this.GetLoanSmsConfirmLeft(slot)) + "-" + this.Pad6(this.GetLoanSmsConfirmRight(slot));
  }

  private func BuildLoanSmsLine(slot: Int32) -> String {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let eventType: Int32 = this.GetLoanSmsType(slot);
    let amount: Int32 = this.GetLoanSmsAmount(slot);
    let walletBefore: Int32 = this.GetLoanSmsWalletBefore(slot);
    let walletAfter: Int32 = this.GetLoanSmsWalletAfter(slot);
    let time: String = this.BuildLoanSmsTimestamp(slot);
    let code: String = this.BuildLoanSmsConfirmation(eventType, slot);
    let contractIndex: Int32;
    let noticeNumber: Int32;
    let vehicleName: String;

    if eventType <= 0 {
      return "";
    };

    if Equals(eventType, 1) {
      return "Marmur Bank loan funded — principal deposited for " + this.FormatMoney(system, amount) + ". Confirmation No. " + code + ". Time " + time + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(eventType, 2) {
      return "Marmur Bank loan payment confirmed — manual repayment received for " + this.FormatMoney(system, amount) + ". Confirmation No. " + code + ". Time " + time + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(eventType, 3) {
      return "Marmur Bank loan payment confirmed — scheduled auto-debit processed for " + this.FormatMoney(system, amount) + ". Confirmation No. " + code + ". Time " + time + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(eventType, 4) {
      return "Marmur Bank loan notice — scheduled payment issue posted. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 5) {
      return "Marmur Bank loan request received — underwriting started for " + this.FormatMoney(system, amount) + ". Decision window: 2-4 business hours. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 6) {
      return "Marmur Bank personal loan denied — approval risk was too high for the requested amount. Requested amount: " + this.FormatMoney(system, amount) + ". Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 7) {
      return "Marmur Bank loan approved — terms ready for " + this.FormatMoney(system, amount) + ". Sign the agreement to release funds. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 8) {
      return "Marmur Bank loan agreement signed — funds posted immediately. Amount: " + this.FormatMoney(system, amount) + ". Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 9) {
      return "Marmur Bank loan paid in full — thank you for your early repayment. Your loan is fully settled, and we appreciate you as a valued customer. We are here whenever you need us. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 10) {
      return "Marmur Bank loan reminder — your scheduled auto-debit of " + this.FormatMoney(system, amount) + " is due tomorrow. Please keep enough funds in checking. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 11) {
      return "Welcome to Marmur Bank. Your account has been successfully opened with an initial deposit of " + this.FormatMoney(system, amount) + ". This secure message thread is your official channel for account activity notices, transaction confirmations, payment and loan updates, and fraud or theft-protection alerts. To manage your account online, open the computer browser and select the Marmur Bank tab. From there, you can review balances and activity, transfer funds, manage loans, and update account settings. Your welcome credit will remain pending for 72 hours and will be reversed if the account is closed within 30 days. Thank you again for choosing Marmur Bank. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 12) {
      return "Welcome back to Marmur Bank. Your new account has been successfully opened with an initial deposit of " + this.FormatMoney(system, amount) + ". A new account number has been assigned. This secure message thread is your official channel for account activity notices, transaction confirmations, payment and loan updates, and fraud or theft-protection alerts. To manage your account online, open the computer browser and select the Marmur Bank tab. From there, you can review balances and activity, transfer funds, manage loans, and update account settings. Thank you again for choosing Marmur Bank. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 13) {
      return "Marmur Bank welcome credit paid — " + this.FormatMoney(system, amount) + " posted after the 72-hour account hold. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 14) {
      return "Marmur Bank welcome credit reversal — " + this.FormatMoney(system, amount) + " charged as an early account closure fee. Confirmation No. " + code + ". Time " + time + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(eventType, 15) {
      return "Marmur Bank Auto Lending: Vanguard Auto financing approved." + this.GetAutoLoanAutoPayApprovalText(walletAfter) + " Balance: " + this.FormatMoney(system, amount) + ". Scheduled payment: " + this.FormatMoney(system, walletBefore) + " " + this.GetAutoLoanFrequencyLabel(walletAfter) + " for " + ToString(this.GetAutoLoanTermMonths(walletAfter)) + " months. Open Marmur Bank > Loans to review Auto-Pay, make payments, pay extra, or pay in full. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 16) {
      return "Marmur Bank auto-loan payment confirmed — " + this.FormatMoney(system, amount) + " posted to the Vanguard Auto loan. Confirmation No. " + code + ". Time " + time + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(eventType, 17) {
      return "Congratulations — your Vanguard Auto loan has been paid in full. Marmur Bank has released the title lien, and Vanguard Garage should now show the vehicle as owned. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 18) {
      if walletBefore == 3 {
        return "Marmur Bank Auto Lending: Vanguard Auto financing was not approved. Active auto-loan limit reached. Pay off an existing auto loan before applying again. Confirmation No. " + code + ". Time " + time + ".";
      };
      if walletBefore == 2 {
        if walletAfter > 0 {
          return "Marmur Bank Auto Lending: Vanguard Auto financing was not approved. Required due-today funds were not available. Minimum approval down target: " + this.FormatMoney(system, walletAfter) + ". Adjust the deal or build checking balance and try again. Confirmation No. " + code + ". Time " + time + ".";
        };
        return "Marmur Bank Auto Lending: Vanguard Auto financing was not approved. Required due-today funds were not available. Adjust the deal or build checking balance and try again. Confirmation No. " + code + ". Time " + time + ".";
      };
      if walletAfter > 0 {
        return "Marmur Bank Auto Lending: Vanguard Auto financing was not approved. Minimum approval down target: " + this.FormatMoney(system, walletAfter) + ". If that is above the selector cap, build Street Cred or choose a lower price. Confirmation No. " + code + ". Time " + time + ".";
      };
      return "Marmur Bank Auto Lending: Vanguard Auto financing was not approved. Improve your credit standing or choose a lower-priced vehicle and try again. Confirmation No. " + code + ". Time " + time + ".";
    };



    if Equals(eventType, 19) {
      return "Marmur Bank default recovery posted - customer-owned Vanguard vehicle liquidation credited " + this.FormatMoney(system, amount) + " toward the defaulted personal loan. Financed vehicles, stash items, and weapons were excluded. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 20) {
      contractIndex = walletAfter / 10;
      noticeNumber = walletAfter % 10;
      if contractIndex <= 0 {
        noticeNumber = walletAfter;
      };
      if noticeNumber <= 0 {
        noticeNumber = 1;
      };
      vehicleName = this.GetVanguardCoverageVehicleName(contractIndex);
      return "Marmur Bank Coverage Compliance: " + vehicleName + " must carry lender-compliant Vanguard Coverage while financed by Marmur. Deductible limit: " + this.FormatMoney(system, amount) + ". Notice " + ToString(noticeNumber) + "/3. " + ToString(walletBefore) + " day(s) remain before default review. Confirmation No. " + code + ". Time " + time + ".";
    };

    if Equals(eventType, 21) {
      vehicleName = this.GetVanguardCoverageVehicleName(walletAfter);
      return "Marmur Bank Coverage Default: " + vehicleName + " remained outside lender-compliant coverage. Marmur has repossessed the vehicle. Access has been revoked. Time " + time + ".";
    };

    return this.T(n"mb_loc_001") + code + ". Time " + time + ".";
  }

  private func GetLatestLoanSmsPreview() -> String {
    let count: Int32 = this.GetLoanSmsCount();
    if count <= 0 {
      return this.T(n"mb_loc_002");
    };
    return this.BuildLoanSmsLine(count);
  }

  private func GetWalletTxCapacity() -> Int32 {
    return 128;
  }

  private func GetWalletTxFact(field: String, slot: Int32) -> Int32 {
    let factName: CName;

    if slot <= 0 || slot > this.GetWalletTxCapacity() {
      return 0;
    };

    factName = StringToName("marmur_wallet_tx_" + field + "_" + ToString(slot));
    return this.GetQuestFactSafe(factName);
  }

  private func SetWalletTxFact(field: String, slot: Int32, value: Int32) -> Void {
    let factName: CName;

    if slot <= 0 || slot > this.GetWalletTxCapacity() {
      return;
    };

    factName = StringToName("marmur_wallet_tx_" + field + "_" + ToString(slot));
    this.SetQuestFactSafe(factName, value);
  }

  private func GetWalletTxRawCount() -> Int32 {
    let count: Int32 = this.GetQuestFactSafe(n"marmur_wallet_tx_count");
    if count < 0 { return 0; };
    return count;
  }

  private func GetWalletTxStoredCount() -> Int32 {
    let slot: Int32 = 1;
    let count: Int32 = 0;

    while slot <= this.GetWalletTxCapacity() {
      if this.GetWalletTxType(slot) > 0 || this.GetWalletTxSeq(slot) > 0 {
        count += 1;
      };
      slot += 1;
    };
    return count;
  }

  private func GetLatestWalletTxSlot() -> Int32 {
    let slot: Int32 = 1;
    let bestSlot: Int32 = 0;
    let bestSeq: Int32 = -1;
    let seq: Int32;

    while slot <= this.GetWalletTxCapacity() {
      if this.GetWalletTxType(slot) > 0 {
        seq = this.GetWalletTxSeq(slot);
        if seq <= 0 {
          seq = slot;
        };
        if seq > bestSeq {
          bestSeq = seq;
          bestSlot = slot;
        };
      };
      slot += 1;
    };
    return bestSlot;
  }

  private func GetWalletTxSeq(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("seq", slot);
  }

  private func GetWalletTxType(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("type", slot);
  }

  private func GetWalletTxAmount(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("amount", slot);
  }

  private func GetWalletTxWalletBefore(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("wallet_before", slot);
  }

  private func GetWalletTxWalletAfter(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("wallet_after", slot);
  }

  private func GetWalletTxDay(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("day", slot);
  }

  private func GetWalletTxHour(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("hour", slot);
  }

  private func GetWalletTxMinute(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("minute", slot);
  }

  private func GetWalletTxReviewDay(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("review_day", slot);
  }

  private func GetWalletTxReviewHour(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("review_hour", slot);
  }

  private func GetWalletTxReviewMinute(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("review_minute", slot);
  }

  private func GetWalletTxFraudReason(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("fraud_reason", slot);
  }

  private func GetWalletTxDispute(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("dispute", slot);
  }

  private func GetWalletTxCashback(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("cashback", slot);
  }

  private func GetWalletTxSubject(slot: Int32) -> Int32 {
    return this.GetWalletTxFact("subject", slot);
  }

  private func BuildWalletTxTimestamp(slot: Int32) -> String {
    return this.FormatClockTime(this.GetWalletTxHour(slot), this.GetWalletTxMinute(slot));
  }

  private func GetDisputeReasonLabel(reason: Int32) -> String {
    if Equals(reason, 1) { return "unrecognized transaction"; };
    if Equals(reason, 2) { return "duplicate charge"; };
    if Equals(reason, 3) { return "incorrect amount"; };
    if Equals(reason, 4) { return "item or service not received"; };
    if Equals(reason, 5) { return "item or service not as described"; };
    if Equals(reason, 6) { return "canceled or returned, no credit received"; };
    if Equals(reason, 7) { return "purchase made in error"; };
    return "transaction review requested";
  }

  private func GetSpendingSubjectLabel(subjectCode: Int32) -> String {
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
    return "Purchase";
  }

  private func GetOldestPendingFallbackFraudSlot() -> Int32 {
    let slot: Int32 = 1;
    let bestSlot: Int32 = 0;
    let bestSeq: Int32 = -1;
    let seq: Int32;

    while slot <= this.GetWalletTxCapacity() {
      if Equals(this.GetWalletTxType(slot), 10) && this.GetWalletTxDispute(slot) <= 0 {
        seq = this.GetWalletTxSeq(slot);
        if seq <= 0 {
          seq = slot;
        };
        if bestSlot <= 0 || seq < bestSeq {
          bestSeq = seq;
          bestSlot = slot;
        };
      };
      slot += 1;
    };
    return bestSlot;
  }

  private func GetPendingFallbackFraudCount() -> Int32 {
    let slot: Int32 = 1;
    let count: Int32 = 0;

    while slot <= this.GetWalletTxCapacity() {
      if Equals(this.GetWalletTxType(slot), 10) && this.GetWalletTxDispute(slot) <= 0 {
        count += 1;
      };
      slot += 1;
    };
    return count;
  }

  private func GetFallbackFraudSubject(alertSlot: Int32) -> Int32 {
    let directSubject: Int32 = this.GetWalletTxSubject(alertSlot);
    let alertSeq: Int32 = this.GetWalletTxSeq(alertSlot);
    let alertAmount: Int32 = this.GetWalletTxAmount(alertSlot);
    let alertDay: Int32 = this.GetWalletTxDay(alertSlot);
    let alertHour: Int32 = this.GetWalletTxHour(alertSlot);
    let alertMinute: Int32 = this.GetWalletTxMinute(alertSlot);
    let slot: Int32 = 1;
    let seq: Int32;
    let bestSubject: Int32 = 0;
    let bestSeq: Int32 = -1;

    if directSubject > 0 {
      return directSubject;
    };

    while slot <= this.GetWalletTxCapacity() {
      seq = this.GetWalletTxSeq(slot);
      if Equals(this.GetWalletTxType(slot), 4) && this.GetWalletTxAmount(slot) == alertAmount && (alertSeq <= 0 || seq < alertSeq) && this.GetWalletTxDay(slot) == alertDay && this.GetWalletTxHour(slot) == alertHour && this.GetWalletTxMinute(slot) == alertMinute && seq > bestSeq {
        bestSeq = seq;
        bestSubject = this.GetWalletTxSubject(slot);
      };
      slot += 1;
    };
    return bestSubject;
  }

  private func BuildWalletTxLine(slot: Int32) -> String {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let txType: Int32 = this.GetWalletTxType(slot);
    let amount: Int32 = this.GetWalletTxAmount(slot);
    let walletBefore: Int32 = this.GetWalletTxWalletBefore(slot);
    let walletAfter: Int32 = this.GetWalletTxWalletAfter(slot);
    let dispute: Int32 = this.GetWalletTxDispute(slot);
    let reason: Int32 = this.GetWalletTxFraudReason(slot);
    let cashback: Int32 = this.GetWalletTxCashback(slot);
    let timestamp: String = this.BuildWalletTxTimestamp(slot);
    let cashbackSuffix: String = "";
    let fraudSubject: Int32 = 0;
    let fraudCategorySuffix: String = "";

    if txType <= 0 { return ""; };

    if cashback > 0 {
      cashbackSuffix = " Cashback earned: " + this.FormatMoney(system, cashback) + " pending weekly payout.";
    };

    if Equals(txType, 1) {
      return "Marmur Bank website deposit posted — " + this.FormatMoney(system, amount) + " at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(txType, 2) {
      return "Marmur Bank website withdrawal posted — " + this.FormatMoney(system, amount) + " at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(txType, 15) {
      return "Marmur Bank Theft Protection Guarantee — we detected unusual activity related to theft. The affected credit chip was deactivated, a replacement chip has been issued, and " + this.FormatMoney(system, amount) + " has been fully restored. Thank you for being a valued customer.";
    };

    if Equals(txType, 10) {
      fraudSubject = this.GetFallbackFraudSubject(slot);
      if fraudSubject > 0 {
        fraudCategorySuffix = " Category: " + this.GetSpendingSubjectLabel(fraudSubject) + ".";
      };
      if Equals(dispute, 2) {
        return "Marmur Bank security check resolved — transaction confirmed authorized." + fraudCategorySuffix + " Amount: " + this.FormatMoney(system, amount) + ". Posted: " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". No further action is required.";
      };
      if Equals(dispute, 3) {
        return "Marmur Bank security check escalated — transaction reported as suspicious." + fraudCategorySuffix + " Amount: " + this.FormatMoney(system, amount) + ". Posted: " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". Open Activity on the Marmur Bank website to file the dispute.";
      };
      return "Marmur Bank security alert — please verify this transaction." + fraudCategorySuffix + " Amount: " + this.FormatMoney(system, amount) + ". Posted: " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". Did you authorize this purchase?";
    };

    if Equals(txType, 13) {
      return "Your dispute for " + this.FormatMoney(system, amount) + " has been received. Marmur Bank Claims will review the transaction and notify you once a decision is made. Reason: " + this.GetDisputeReasonLabel(reason) + ". Time " + timestamp + ".";
    };

    if Equals(txType, 16) {
      return "Your dispute for " + this.FormatMoney(system, amount) + " has been approved. A credit for " + this.FormatMoney(system, amount) + " has been posted to checking. Thank you for your patience. Time " + timestamp + ".";
    };

    if Equals(txType, 17) {
      return "After review, your dispute for " + this.FormatMoney(system, amount) + " was not approved. No credit has been issued. Reason reviewed: " + this.GetDisputeReasonLabel(reason) + ". Time " + timestamp + ".";
    };

    if Equals(txType, 18) {
      return "Your account has been temporarily flagged due to recent dispute activity. Disputes are unavailable for 7 days. All other account functions remain operational.";
    };

    if Equals(txType, 19) {
      return "Your account review is complete. Disputes are available again, and all account functions remain operational.";
    };

    if Equals(txType, 14) {
      return "Marmur Bank account closure fee — welcome credit reversal for " + this.FormatMoney(system, amount) + " at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(txType, 20) {
      if Equals(dispute, 2) {
        return "Marmur Bank weekly cashback payout — " + this.FormatMoney(system, amount) + " credited to savings at " + timestamp + ". Rewards post every 7 days at 3:00 PM from eligible spend and loan payments.";
      };
      return "Marmur Bank weekly cashback payout — " + this.FormatMoney(system, amount) + " credited to checking at " + timestamp + ". Rewards post every 7 days at 3:00 PM from eligible spend and loan payments.";
    };

    if Equals(txType, 25) {
      return "Marmur Bank insurance settlement — Vanguard Auto settlement proceeds of " + this.FormatMoney(system, amount) + " were received into checking at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
    };

    if Equals(txType, 26) {
      return "Marmur Bank insurance loan payoff — Vanguard Auto settlement proceeds of " + this.FormatMoney(system, amount) + " were applied to the financed auto loan at " + timestamp + ". Insurance-paid loan payoffs are not cashback eligible.";
    };

    if Equals(txType, 21) && Equals(reason, 201) {
      return "Marmur Bank Vanguard Auto payment — " + this.FormatMoney(system, amount) + " posted from checking at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + "." + cashbackSuffix;
    };

    if Equals(txType, 4) || Equals(txType, 21) || Equals(txType, 22) || Equals(txType, 27) {
      if Equals(dispute, 3) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatMoney(system, amount) + " posted at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". Status: dispute submitted for review." + cashbackSuffix;
      };
      if Equals(dispute, 4) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatMoney(system, amount) + " posted at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". Status: dispute approved and credited." + cashbackSuffix;
      };
      if Equals(dispute, 5) {
        return "Marmur Bank purchase notice — a purchase of " + this.FormatMoney(system, amount) + " posted at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". Status: dispute denied after review." + cashbackSuffix;
      };
      return "Marmur Bank purchase notice — a purchase of " + this.FormatMoney(system, amount) + " posted at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ". No reply is required." + cashbackSuffix;
    };

    return "Marmur Bank account activity — " + this.FormatMoney(system, amount) + " posted at " + timestamp + ". Checking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter) + ".";
  }

  private func GetLatestWalletTxPreview() -> String {
    let slot: Int32 = this.GetLatestWalletTxSlot();
    if slot <= 0 {
      return this.T(n"mb_loc_002");
    };
    return this.BuildWalletTxLine(slot);
  }

  private func SetWalletTxDispute(slot: Int32, value: Int32) -> Void {
    this.SetWalletTxFact("dispute", slot, value);
  }

  private func MarkFallbackFraudAlert(slot: Int32, authorized: Bool) -> Bool {
    let timeSystem: ref<TimeSystem>;
    let gameTime: GameTime;

    if slot <= 0 || slot > this.GetWalletTxCapacity() {
      return false;
    };
    if !Equals(this.GetWalletTxType(slot), 10) || this.GetWalletTxDispute(slot) > 0 {
      return false;
    };

    if authorized {
      this.SetWalletTxDispute(slot, 2);
    } else {
      this.SetWalletTxDispute(slot, 3);
    };

    if IsDefined(this.m_player) {
      timeSystem = GameInstance.GetTimeSystem(this.m_player.GetGame());
      if IsDefined(timeSystem) {
        gameTime = timeSystem.GetGameTime();
        this.SetWalletTxFact("review_day", slot, GameTime.Days(gameTime));
        this.SetWalletTxFact("review_hour", slot, GameTime.Hours(gameTime));
        this.SetWalletTxFact("review_minute", slot, GameTime.Minutes(gameTime));
      };
    };
    return true;
  }

  private func GetSystemFraudSubject(system: ref<NCBankSystem>, alertIndex: Int32) -> Int32 {
    let subjectCode: Int32;
    let index: Int32;
    let amount: Int32;
    let day: Int32;
    let hour: Int32;
    let minute: Int32;

    if !IsDefined(system) || alertIndex < 0 {
      return 0;
    };

    subjectCode = system.GetTransactionSubjectAt(alertIndex);
    if subjectCode > 0 {
      return subjectCode;
    };

    amount = system.GetTransactionAmountAt(alertIndex);
    day = system.GetTransactionDayAt(alertIndex);
    hour = system.GetTransactionHourAt(alertIndex);
    minute = system.GetTransactionMinuteAt(alertIndex);
    index = alertIndex - 1;

    while index >= 0 {
      if Equals(system.GetTransactionTypeAt(index), 4) && system.GetTransactionAmountAt(index) == amount && system.GetTransactionDayAt(index) == day && system.GetTransactionHourAt(index) == hour && system.GetTransactionMinuteAt(index) == minute {
        return system.GetTransactionSubjectAt(index);
      };
      index -= 1;
    };
    return 0;
  }

  private func ClearActiveFraudAlert() -> Void {
    this.m_activeFraudSource = 0;
    this.m_activeFraudIndex = -1;
  }

  private func GetTotalPendingFraudCount() -> Int32 {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let count: Int32 = this.GetPendingFallbackFraudCount();
    if IsDefined(system) {
      count += system.GetPendingFraudAlertCount();
    };
    return count;
  }

  private func IsActiveFraudAlertPending() -> Bool {
    let system: ref<NCBankSystem>;

    if Equals(this.m_activeFraudSource, 1) {
      system = this.GetBankSystem();
      return IsDefined(system) && this.m_activeFraudIndex >= 0 && Equals(system.GetTransactionFraudStatusAt(this.m_activeFraudIndex), 0);
    };

    if Equals(this.m_activeFraudSource, 2) {
      return this.m_activeFraudIndex > 0 && Equals(this.GetWalletTxType(this.m_activeFraudIndex), 10) && this.GetWalletTxDispute(this.m_activeFraudIndex) <= 0;
    };

    return false;
  }

  private func SelectNextPendingFraudAlert() -> Bool {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let systemIndex: Int32 = -1;
    let fallbackSlot: Int32 = this.GetOldestPendingFallbackFraudSlot();
    let systemKey: Int32;
    let fallbackKey: Int32;

    this.ClearActiveFraudAlert();
    if IsDefined(system) {
      systemIndex = system.GetOldestPendingFraudAlertIndex();
    };

    if systemIndex < 0 && fallbackSlot <= 0 {
      return false;
    };

    if systemIndex >= 0 && fallbackSlot > 0 {
      systemKey = this.BuildThreadSortKey(
        system.GetTransactionDayAt(systemIndex),
        system.GetTransactionHourAt(systemIndex),
        system.GetTransactionMinuteAt(systemIndex)
      );
      fallbackKey = this.BuildThreadSortKey(
        this.GetWalletTxDay(fallbackSlot),
        this.GetWalletTxHour(fallbackSlot),
        this.GetWalletTxMinute(fallbackSlot)
      );

      if systemKey <= fallbackKey {
        this.m_activeFraudSource = 1;
        this.m_activeFraudIndex = systemIndex;
      } else {
        this.m_activeFraudSource = 2;
        this.m_activeFraudIndex = fallbackSlot;
      };
      return true;
    };

    if systemIndex >= 0 {
      this.m_activeFraudSource = 1;
      this.m_activeFraudIndex = systemIndex;
      return true;
    };

    this.m_activeFraudSource = 2;
    this.m_activeFraudIndex = fallbackSlot;
    return true;
  }

  private func GetActiveFraudAmount() -> Int32 {
    let system: ref<NCBankSystem>;
    if Equals(this.m_activeFraudSource, 1) {
      system = this.GetBankSystem();
      if IsDefined(system) {
        return system.GetTransactionAmountAt(this.m_activeFraudIndex);
      };
    };
    if Equals(this.m_activeFraudSource, 2) {
      return this.GetWalletTxAmount(this.m_activeFraudIndex);
    };
    return 0;
  }

  private func GetActiveFraudSubject() -> Int32 {
    let system: ref<NCBankSystem>;
    if Equals(this.m_activeFraudSource, 1) {
      system = this.GetBankSystem();
      if IsDefined(system) {
        return this.GetSystemFraudSubject(system, this.m_activeFraudIndex);
      };
    };
    if Equals(this.m_activeFraudSource, 2) {
      return this.GetFallbackFraudSubject(this.m_activeFraudIndex);
    };
    return 0;
  }

  private func BuildFraudReplyText(amount: Int32, authorized: Bool) -> String {
    let system: ref<NCBankSystem> = this.GetBankSystem();

    if amount > 0 {
      if authorized {
        return "Yes, I authorized the " + this.FormatMoney(system, amount) + " purchase";
      };
      return "No, I did not authorize the " + this.FormatMoney(system, amount) + " purchase";
    };

    if authorized {
      return "Yes, I authorized this purchase";
    };
    return this.T(n"mb_loc_005");
  }

  private func BuildFraudResolutionText(system: ref<NCBankSystem>, amount: Int32, subjectCode: Int32, authorized: Bool) -> String {
    let categorySuffix: String = "";

    if subjectCode > 0 {
      categorySuffix = " " + this.GetSpendingSubjectLabel(subjectCode);
    };

    if authorized {
      return "Thank you. Marmur Bank marked the " + this.FormatMoney(system, amount) + categorySuffix + " purchase as authorized. No further action is required.";
    };
    return "Report received. Marmur Bank marked the " + this.FormatMoney(system, amount) + categorySuffix + " purchase as suspicious. Open the Marmur Bank website, go to Activity, and file a dispute on the matching transaction for review.";
  }

  private func BuildActiveFraudReplyText(authorized: Bool) -> String {
    return this.BuildFraudReplyText(this.GetActiveFraudAmount(), authorized);
  }

  private func BuildSecurityCheckPrompt(system: ref<NCBankSystem>, amount: Int32, subjectCode: Int32, timestamp: String, walletBefore: Int32, walletAfter: Int32, pendingCount: Int32) -> String {
    let text: String = "Marmur Bank security alert";

    if pendingCount > 1 {
      text += "\n\n" + IntToString(pendingCount) + " transactions require review. They will be presented oldest to newest.";
    };
    text += "\n\nPlease verify this transaction:";
    text += "\nTransaction: " + this.GetSpendingSubjectLabel(subjectCode);
    text += "\nAmount: " + this.FormatMoney(system, amount);
    if NotEquals(timestamp, "") {
      text += "\nPosted: " + timestamp;
    };
    if walletBefore > 0 || walletAfter > 0 {
      text += "\nChecking: " + this.FormatMoney(system, walletBefore) + " → " + this.FormatMoney(system, walletAfter);
    };
    text += "\n\nDid you authorize this purchase?";
    return text;
  }

  private func BuildPendingSecurityCheckPrompt() -> String {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let amount: Int32;
    let subjectCode: Int32;
    let timestamp: String = "";
    let walletBefore: Int32;
    let walletAfter: Int32;

    if !this.IsActiveFraudAlertPending() && !this.SelectNextPendingFraudAlert() {
      return this.T(n"mb_loc_004");
    };

    amount = this.GetActiveFraudAmount();
    subjectCode = this.GetActiveFraudSubject();

    if Equals(this.m_activeFraudSource, 1) && IsDefined(system) {
      timestamp = this.FormatClockTime(system.GetTransactionHourAt(this.m_activeFraudIndex), system.GetTransactionMinuteAt(this.m_activeFraudIndex));
      walletBefore = system.GetTransactionWalletBeforeAt(this.m_activeFraudIndex);
      walletAfter = system.GetTransactionWalletAfterAt(this.m_activeFraudIndex);
    } else {
      if Equals(this.m_activeFraudSource, 2) {
        timestamp = this.BuildWalletTxTimestamp(this.m_activeFraudIndex);
        walletBefore = this.GetWalletTxWalletBefore(this.m_activeFraudIndex);
        walletAfter = this.GetWalletTxWalletAfter(this.m_activeFraudIndex);
      };
    };

    return this.BuildSecurityCheckPrompt(system, amount, subjectCode, timestamp, walletBefore, walletAfter, this.GetTotalPendingFraudCount());
  }

  private func PushNextPendingSecurityCheck(playSound: Bool) -> Bool {
    this.ClearActiveFraudAlert();
    if !this.SelectNextPendingFraudAlert() {
      return false;
    };
    this.PushBotMessage(this.BuildPendingSecurityCheckPrompt(), playSound);
    return true;
  }

  private func GetLatestThreadPreview(system: ref<NCBankSystem>) -> String {
    let preview: String = this.T(n"mb_loc_002");
    let bestKey: Int32 = -1;
    let key: Int32;
    let count: Int32;
    let idx: Int32;
    let slot: Int32;
    let line: String;
    let fraudStatus: Int32;
    let amount: Int32;
    let subjectCode: Int32;

    if IsDefined(system) {
      count = system.GetTransactionLogCount();
      if count > 0 {
        line = system.GetTransactionLogAt(count - 1);
        if NotEquals(line, "") {
          preview = line;
          bestKey = this.BuildThreadSortKey(
            system.GetTransactionDayAt(count - 1),
            system.GetTransactionHourAt(count - 1),
            system.GetTransactionMinuteAt(count - 1)
          );
        };
      };

      idx = 0;
      while idx < count {
        if Equals(system.GetTransactionTypeAt(idx), 10) {
          fraudStatus = system.GetTransactionFraudStatusAt(idx);
          if Equals(fraudStatus, 1) || Equals(fraudStatus, 2) {
            key = this.GetSystemFraudDecisionSortKey(system, idx);
            if key >= bestKey {
              amount = system.GetTransactionAmountAt(idx);
              subjectCode = this.GetSystemFraudSubject(system, idx);
              preview = this.BuildFraudResolutionText(system, amount, subjectCode, Equals(fraudStatus, 1));
              bestKey = key;
            };
          };
        };
        idx += 1;
      };
    };

    slot = this.GetLatestWalletTxSlot();
    if slot > 0 {
      line = this.BuildWalletTxLine(slot);
      key = this.BuildThreadSortKey(
        this.GetWalletTxDay(slot),
        this.GetWalletTxHour(slot),
        this.GetWalletTxMinute(slot)
      );
      if NotEquals(line, "") && key >= bestKey {
        preview = line;
        bestKey = key;
      };
    };

    slot = 1;
    while slot <= this.GetWalletTxCapacity() {
      if Equals(this.GetWalletTxType(slot), 10) {
        fraudStatus = this.GetWalletTxDispute(slot);
        if Equals(fraudStatus, 2) || Equals(fraudStatus, 3) {
          key = this.GetFallbackFraudDecisionSortKey(slot);
          if key >= bestKey {
            amount = this.GetWalletTxAmount(slot);
            subjectCode = this.GetFallbackFraudSubject(slot);
            preview = this.BuildFraudResolutionText(system, amount, subjectCode, Equals(fraudStatus, 2));
            bestKey = key;
          };
        };
      };
      slot += 1;
    };

    count = this.GetLoanSmsCount();
    if count > 0 {
      line = this.BuildLoanSmsLine(count);
      key = this.BuildThreadSortKey(
        this.GetLoanSmsDay(count),
        this.GetLoanSmsHour(count),
        this.GetLoanSmsMinute(count)
      );
      if NotEquals(line, "") && key >= bestKey {
        preview = line;
      };
    };

    return preview;
  }

  private func GetResolvedSecurityReviewExtraMessageCount() -> Int32 {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let extra: Int32 = 0;
    let count: Int32;
    let idx: Int32;
    let slot: Int32 = 1;
    let status: Int32;

    if IsDefined(system) {
      count = system.GetTransactionLogCount();
      idx = 0;
      while idx < count {
        if Equals(system.GetTransactionTypeAt(idx), 10) {
          status = system.GetTransactionFraudStatusAt(idx);
          if Equals(status, 1) || Equals(status, 2) {
            extra += 2;
          };
        };
        idx += 1;
      };
    };

    while slot <= this.GetWalletTxCapacity() {
      if Equals(this.GetWalletTxType(slot), 10) {
        status = this.GetWalletTxDispute(slot);
        if Equals(status, 2) || Equals(status, 3) {
          extra += 2;
        };
      };
      slot += 1;
    };

    return extra;
  }

  public func CreateContactData(forMessages: Bool) -> ref<ContactData> {
    let contactData: ref<ContactData>;
    let system: ref<NCBankSystem>;
    let unread: Int32;
    let count: Int32;
    let loanSmsCount: Int32;
    let walletTxCount: Int32;
    let displayUnread: Int32;

    contactData = new ContactData();
    contactData.hash = this.GetHash();
    contactData.localizedName = this.GetContactLocalizedName();
    contactData.contactId = s"MarmurBankAlerts";
    contactData.id = s"MARMUR_BANK_ALERTS";
    contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
    contactData.questRelated = false;
    contactData.hasQuestImportantReply = false;
    contactData.isCallable = false;

    system = this.GetBankSystem();
    loanSmsCount = this.GetLoanSmsCount();
    walletTxCount = this.GetWalletTxStoredCount();
    if IsDefined(system) {
      unread = system.GetTransactionUnreadCount() + this.GetExternalUnreadCount();
      count = system.GetTransactionLogCount() + loanSmsCount + walletTxCount;
    } else {
      unread = this.GetExternalUnreadCount();
      count = loanSmsCount + walletTxCount;
    };
    contactData.lastMesssagePreview = this.GetLatestThreadPreview(system);

    if forMessages {
      contactData.type = MessengerContactType.SingleThread;
    } else {
      contactData.type = MessengerContactType.Contact;
    };

    contactData.messagesCount = count + this.GetResolvedSecurityReviewExtraMessageCount() + 1;

    if unread > 0 {
      displayUnread = 1;
    } else {
      displayUnread = 0;
    };

    contactData.unreadMessegeCount = displayUnread;
    if displayUnread > 0 {
      ArrayInsert(contactData.unreadMessages, 0, 1);
      this.SyncNightlyUnread(true);
    } else {
      this.SyncNightlyUnread(false);
    };
    contactData.hasMessages = true;
    contactData.playerIsLastSender = false;
    contactData.playerCanReply = this.GetTotalPendingFraudCount() > 0;
    return contactData;
  }

  public func OnDialogOpen(messengerController: wref<MessengerDialogViewController>) -> Bool {
    let system: ref<NCBankSystem>;
    let loanSmsCount: Int32;
    let walletTxCount: Int32;

    if !this.HasCreatedAccount() {
      return false;
    };

    this.m_messengerController = messengerController;
    if !IsDefined(this.m_messengerController) {
      return false;
    };
    this.m_messengerController.ClearMessages();
    this.m_messengerController.ClearReplies();
    this.ClearActiveFraudAlert();
    system = this.GetBankSystem();
    loanSmsCount = this.GetLoanSmsCount();
    walletTxCount = this.GetWalletTxStoredCount();

    if (!IsDefined(system) || system.GetTransactionLogCount() <= 0) && loanSmsCount <= 0 && walletTxCount <= 0 {
      this.PushBotMessage("Welcome to Marmur Bank. Your account is active. This secure message thread is your official channel for account activity notices, transaction confirmations, payment and loan updates, and fraud or theft-protection alerts. To manage your account online, open the computer browser and select the Marmur Bank tab. From there, you can review balances and activity, transfer funds, manage loans, and update account settings. Thank you again for choosing Marmur Bank.", false);
    } else {
      this.PushChronologicalHistory(10, 5, 5, false);
      this.PushNextPendingSecurityCheck(false);
      if IsDefined(system) {
        system.ClearTransactionUnread();
      };
      this.MarkExternalAlertsRead();
      this.SyncNightlyUnread(false);
    };

    this.MarkExternalAlertsRead();
    this.SyncNightlyUnread(false);
    this.OpenRootReplies();
    return true;
  }

  public func OnReplySelected(messageID: Int32) -> Void {
    if !IsDefined(this.m_messengerController) {
      return;
    };

    this.m_messengerController.ClearReplies();




    if Equals(messageID, EnumInt(MarmurBankReplyID.ConfirmLatestPurchase)) {
      this.PushPlayerMessage(this.BuildActiveFraudReplyText(true));
      this.HandleFraudConfirmation(true);
      return;
    };

    if Equals(messageID, EnumInt(MarmurBankReplyID.ReportSuspiciousPurchase)) {
      this.PushPlayerMessage(this.BuildActiveFraudReplyText(false));
      this.HandleFraudConfirmation(false);
      return;
    };


    this.OpenRootReplies();
  }

  private func HandleAccountSummary() -> Void {
    let system: ref<NCBankSystem>;
    let game: GameInstance;
    let text: String;

    system = this.GetBankSystem();
    if !IsDefined(system) || !IsDefined(this.m_player) {
      this.PushBotMessage(this.T(n"mb_loc_006"), true);
      this.OpenRootReplies();
      return;
    };

    game = this.m_player.GetGame();
    system.SyncInterest(game);

    text = this.T(n"mb_loc_007");
    text += "\nBank balance: " + this.FormatMoney(system, system.GetBalance());
    text += "\nWallet balance: " + this.FormatMoney(system, system.GetWalletBalance(game));
    text += "\nTotal deposited: " + this.FormatMoney(system, system.GetTotalDeposited());
    text += "\nTotal withdrawn: " + this.FormatMoney(system, system.GetTotalWithdrawn());
    text += "\nInterest earned: " + this.FormatMoney(system, system.GetTotalInterestEarned());
    text += "\nYield tax paid: " + this.FormatMoney(system, system.GetTotalTaxPaid());

    this.PushBotMessage(text, true);
    this.OpenRootReplies();
  }

  private func BuildThreadSortKey(day: Int32, hour: Int32, minute: Int32) -> Int32 {
    let safeDay: Int32 = day;
    let safeHour: Int32 = hour;
    let safeMinute: Int32 = minute;

    if safeDay <= 0 {
      return 0;
    };
    if safeHour < 0 {
      safeHour = 0;
    };
    if safeHour > 23 {
      safeHour = 23;
    };
    if safeMinute < 0 {
      safeMinute = 0;
    };
    if safeMinute > 59 {
      safeMinute = 59;
    };

    return (safeDay * 1440) + (safeHour * 60) + safeMinute;
  }

  private func GetSystemFraudDecisionSortKey(system: ref<NCBankSystem>, index: Int32) -> Int32 {
    let alertKey: Int32;
    let decisionKey: Int32;

    if !IsDefined(system) {
      return 0;
    };

    alertKey = this.BuildThreadSortKey(
      system.GetTransactionDayAt(index),
      system.GetTransactionHourAt(index),
      system.GetTransactionMinuteAt(index)
    );
    decisionKey = this.BuildThreadSortKey(
      system.GetTransactionFraudDecisionDayAt(index),
      system.GetTransactionFraudDecisionHourAt(index),
      system.GetTransactionFraudDecisionMinuteAt(index)
    );

    if decisionKey < alertKey {
      return alertKey;
    };
    return decisionKey;
  }

  private func GetFallbackFraudDecisionSortKey(slot: Int32) -> Int32 {
    let alertKey: Int32 = this.BuildThreadSortKey(
      this.GetWalletTxDay(slot),
      this.GetWalletTxHour(slot),
      this.GetWalletTxMinute(slot)
    );
    let decisionKey: Int32 = this.BuildThreadSortKey(
      this.GetWalletTxReviewDay(slot),
      this.GetWalletTxReviewHour(slot),
      this.GetWalletTxReviewMinute(slot)
    );

    if decisionKey < alertKey {
      return alertKey;
    };
    return decisionKey;
  }

  private func PushChronologicalHistory(transactionLimit: Int32, walletLimit: Int32, loanLimit: Int32, playSound: Bool) -> Void {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let messages: array<String>;
    let messageTypes: array<Int32>;
    let sortKeys: array<Int32>;
    let walletSlots: array<Int32>;
    let walletSeqs: array<Int32>;
    let count: Int32;
    let start: Int32;
    let idx: Int32;
    let slot: Int32;
    let seq: Int32;
    let i: Int32;
    let j: Int32;
    let line: String;
    let tempLine: String;
    let tempKey: Int32;
    let tempType: Int32;
    let tempSlot: Int32;
    let txType: Int32;
    let fraudStatus: Int32;
    let amount: Int32;
    let subjectCode: Int32;
    let decisionKey: Int32;
    let timestamp: String;
    let soundUsed: Bool = false;

    if IsDefined(system) {
      count = system.GetTransactionLogCount();
      start = count - transactionLimit;
      if start < 0 {
        start = 0;
      };
      if start > count {
        start = count;
      };

      idx = 0;
      while idx < count {
        txType = system.GetTransactionTypeAt(idx);
        if idx >= start || Equals(txType, 10) {
          if Equals(txType, 10) {
            fraudStatus = system.GetTransactionFraudStatusAt(idx);
            if Equals(fraudStatus, 1) || Equals(fraudStatus, 2) {
              amount = system.GetTransactionAmountAt(idx);
              subjectCode = this.GetSystemFraudSubject(system, idx);
              timestamp = this.FormatClockTime(system.GetTransactionHourAt(idx), system.GetTransactionMinuteAt(idx));
              decisionKey = this.GetSystemFraudDecisionSortKey(system, idx);

              ArrayPush(messages, this.BuildSecurityCheckPrompt(
                system,
                amount,
                subjectCode,
                timestamp,
                system.GetTransactionWalletBeforeAt(idx),
                system.GetTransactionWalletAfterAt(idx),
                1
              ));
              ArrayPush(messageTypes, 0);
              ArrayPush(sortKeys, decisionKey);

              ArrayPush(messages, this.BuildFraudReplyText(amount, Equals(fraudStatus, 1)));
              ArrayPush(messageTypes, 1);
              ArrayPush(sortKeys, decisionKey);

              ArrayPush(messages, this.BuildFraudResolutionText(system, amount, subjectCode, Equals(fraudStatus, 1)));
              ArrayPush(messageTypes, 0);
              ArrayPush(sortKeys, decisionKey);
            } else {
              if fraudStatus < 0 {
                line = system.GetTransactionLogAt(idx);
                if NotEquals(line, "") {
                  ArrayPush(messages, line);
                  ArrayPush(messageTypes, 0);
                  ArrayPush(sortKeys, this.BuildThreadSortKey(
                    system.GetTransactionDayAt(idx),
                    system.GetTransactionHourAt(idx),
                    system.GetTransactionMinuteAt(idx)
                  ));
                };
              };
            };
          } else {
            line = system.GetTransactionLogAt(idx);
            if NotEquals(line, "") {
              ArrayPush(messages, line);
              ArrayPush(messageTypes, 0);
              ArrayPush(sortKeys, this.BuildThreadSortKey(
                system.GetTransactionDayAt(idx),
                system.GetTransactionHourAt(idx),
                system.GetTransactionMinuteAt(idx)
              ));
            };
          };
        };
        idx += 1;
      };
    };

    slot = 1;
    while slot <= this.GetWalletTxCapacity() {
      if this.GetWalletTxType(slot) > 0 {
        seq = this.GetWalletTxSeq(slot);
        if seq <= 0 {
          seq = slot;
        };
        ArrayPush(walletSlots, slot);
        ArrayPush(walletSeqs, seq);
      };
      slot += 1;
    };

    i = 1;
    while i < ArraySize(walletSeqs) {
      j = i;
      while j > 0 && walletSeqs[j] < walletSeqs[j - 1] {
        tempKey = walletSeqs[j - 1];
        walletSeqs[j - 1] = walletSeqs[j];
        walletSeqs[j] = tempKey;

        tempSlot = walletSlots[j - 1];
        walletSlots[j - 1] = walletSlots[j];
        walletSlots[j] = tempSlot;
        j -= 1;
      };
      i += 1;
    };

    count = walletLimit;
    if count > ArraySize(walletSlots) {
      count = ArraySize(walletSlots);
    };
    if count < 0 {
      count = 0;
    };

    start = ArraySize(walletSlots) - count;
    idx = 0;
    while idx < ArraySize(walletSlots) {
      slot = walletSlots[idx];
      txType = this.GetWalletTxType(slot);
      if idx >= start || Equals(txType, 10) {
        if Equals(txType, 10) {
          fraudStatus = this.GetWalletTxDispute(slot);
          if Equals(fraudStatus, 2) || Equals(fraudStatus, 3) {
            amount = this.GetWalletTxAmount(slot);
            subjectCode = this.GetFallbackFraudSubject(slot);
            decisionKey = this.GetFallbackFraudDecisionSortKey(slot);

            ArrayPush(messages, this.BuildSecurityCheckPrompt(
              system,
              amount,
              subjectCode,
              this.BuildWalletTxTimestamp(slot),
              this.GetWalletTxWalletBefore(slot),
              this.GetWalletTxWalletAfter(slot),
              1
            ));
            ArrayPush(messageTypes, 0);
            ArrayPush(sortKeys, decisionKey);

            ArrayPush(messages, this.BuildFraudReplyText(amount, Equals(fraudStatus, 2)));
            ArrayPush(messageTypes, 1);
            ArrayPush(sortKeys, decisionKey);

            ArrayPush(messages, this.BuildFraudResolutionText(system, amount, subjectCode, Equals(fraudStatus, 2)));
            ArrayPush(messageTypes, 0);
            ArrayPush(sortKeys, decisionKey);
          } else {
            if fraudStatus > 0 {
              line = this.BuildWalletTxLine(slot);
              if NotEquals(line, "") {
                ArrayPush(messages, line);
                ArrayPush(messageTypes, 0);
                ArrayPush(sortKeys, this.BuildThreadSortKey(
                  this.GetWalletTxDay(slot),
                  this.GetWalletTxHour(slot),
                  this.GetWalletTxMinute(slot)
                ));
              };
            };
          };
        } else {
          line = this.BuildWalletTxLine(slot);
          if NotEquals(line, "") {
            ArrayPush(messages, line);
            ArrayPush(messageTypes, 0);
            ArrayPush(sortKeys, this.BuildThreadSortKey(
              this.GetWalletTxDay(slot),
              this.GetWalletTxHour(slot),
              this.GetWalletTxMinute(slot)
            ));
          };
        };
      };
      idx += 1;
    };

    count = this.GetLoanSmsCount();
    if loanLimit < count {
      start = count - loanLimit;
    } else {
      start = 0;
    };
    if start < 0 {
      start = 0;
    };
    if start > count {
      start = count;
    };

    idx = start + 1;
    while idx <= count {
      line = this.BuildLoanSmsLine(idx);
      if NotEquals(line, "") {
        ArrayPush(messages, line);
        ArrayPush(messageTypes, 0);
        ArrayPush(sortKeys, this.BuildThreadSortKey(
          this.GetLoanSmsDay(idx),
          this.GetLoanSmsHour(idx),
          this.GetLoanSmsMinute(idx)
        ));
      };
      idx += 1;
    };

    i = 1;
    while i < ArraySize(sortKeys) {
      j = i;
      while j > 0 && sortKeys[j] < sortKeys[j - 1] {
        tempKey = sortKeys[j - 1];
        sortKeys[j - 1] = sortKeys[j];
        sortKeys[j] = tempKey;

        tempLine = messages[j - 1];
        messages[j - 1] = messages[j];
        messages[j] = tempLine;

        tempType = messageTypes[j - 1];
        messageTypes[j - 1] = messageTypes[j];
        messageTypes[j] = tempType;
        j -= 1;
      };
      i += 1;
    };

    idx = 0;
    while idx < ArraySize(messages) {
      if Equals(messageTypes[idx], 1) {
        this.PushPlayerMessage(messages[idx]);
      } else {
        this.PushBotMessage(messages[idx], playSound && !soundUsed);
        soundUsed = true;
      };
      idx += 1;
    };
  }

  private func PushRecentTransactions(limit: Int32, playSound: Bool) -> Void {
    let system: ref<NCBankSystem>;
    let count: Int32;
    let start: Int32;
    let idx: Int32;
    let line: String;
    let soundUsed: Bool;

    system = this.GetBankSystem();
    if !IsDefined(system) {
      if this.GetLoanSmsCount() <= 0 {
        this.PushBotMessage("Marmur Bank transaction history is unavailable right now.", playSound);
      };
      return;
    };

    count = system.GetTransactionLogCount();
    if count <= 0 {
      if this.GetLoanSmsCount() <= 0 {
        this.PushBotMessage("No account notifications are on file yet.", playSound);
      };
      return;
    };

    start = count - limit;
    if start < 0 {
      start = 0;
    };

    soundUsed = false;

    idx = start;
    while idx < count {
      line = system.GetTransactionLogAt(idx);
      if NotEquals(line, "") {
        this.PushBotMessage(line, playSound && !soundUsed);
        soundUsed = true;
      };
      idx += 1;
    };
  }

  private func PushLoanSmsHistory(limit: Int32, playSound: Bool) -> Void {
    let count: Int32;
    let start: Int32;
    let idx: Int32;
    let line: String;
    let soundUsed: Bool;

    count = this.GetLoanSmsCount();
    if count <= 0 {
      return;
    };

    start = count - limit;
    if start < 0 {
      start = 0;
    };

    soundUsed = false;

    idx = start + 1;
    while idx <= count {
      line = this.BuildLoanSmsLine(idx);
      if NotEquals(line, "") {
        this.PushBotMessage(line, playSound && !soundUsed);
        soundUsed = true;
      };
      idx += 1;
    };
  }

  private func PushWalletTxHistory(limit: Int32, playSound: Bool) -> Void {
    let slots: array<Int32>;
    let seqs: array<Int32>;
    let count: Int32;
    let start: Int32;
    let idx: Int32;
    let slot: Int32 = 1;
    let seq: Int32;
    let i: Int32;
    let j: Int32;
    let tempKey: Int32;
    let tempSlot: Int32;
    let line: String;
    let soundUsed: Bool = false;

    while slot <= this.GetWalletTxCapacity() {
      if this.GetWalletTxType(slot) > 0 {
        seq = this.GetWalletTxSeq(slot);
        if seq <= 0 {
          seq = slot;
        };
        ArrayPush(slots, slot);
        ArrayPush(seqs, seq);
      };
      slot += 1;
    };

    if ArraySize(slots) <= 0 {
      return;
    };

    i = 1;
    while i < ArraySize(seqs) {
      j = i;
      while j > 0 && seqs[j] < seqs[j - 1] {
        tempKey = seqs[j - 1];
        seqs[j - 1] = seqs[j];
        seqs[j] = tempKey;

        tempSlot = slots[j - 1];
        slots[j - 1] = slots[j];
        slots[j] = tempSlot;
        j -= 1;
      };
      i += 1;
    };

    count = limit;
    if count > ArraySize(slots) {
      count = ArraySize(slots);
    };
    if count < 0 {
      count = 0;
    };

    start = ArraySize(slots) - count;
    idx = start;
    while idx < ArraySize(slots) {
      line = this.BuildWalletTxLine(slots[idx]);
      if NotEquals(line, "") {
        this.PushBotMessage(line, playSound && !soundUsed);
        soundUsed = true;
      };
      idx += 1;
    };
  }

  private func HandleFraudConfirmation(authorized: Bool) -> Void {
    let system: ref<NCBankSystem> = this.GetBankSystem();
    let response: String;
    let pendingAmount: Int32 = 0;
    let subjectCode: Int32 = 0;
    let categorySuffix: String = "";

    if !this.IsActiveFraudAlertPending() && !this.SelectNextPendingFraudAlert() {
      if authorized {
        response = "No purchase security check is currently waiting for authorization.";
      } else {
        response = "No pending purchase security check was found. Open Activity on the Marmur Bank website if you need to dispute a transaction.";
      };
    } else {
      pendingAmount = this.GetActiveFraudAmount();
      subjectCode = this.GetActiveFraudSubject();
      if subjectCode > 0 {
        categorySuffix = " " + this.GetSpendingSubjectLabel(subjectCode);
      };

      if Equals(this.m_activeFraudSource, 1) && IsDefined(system) {
        if authorized {
          if IsDefined(this.m_player) {
            response = system.ConfirmFraudAlertAtWithTime(this.m_player.GetGame(), this.m_activeFraudIndex);
          } else {
            response = system.ConfirmFraudAlertAt(this.m_activeFraudIndex);
          };
        } else {
          if IsDefined(this.m_player) {
            response = system.FlagFraudAlertAtWithTime(this.m_player.GetGame(), this.m_activeFraudIndex);
          } else {
            response = system.FlagFraudAlertAt(this.m_activeFraudIndex);
          };
        };
      } else {
        if Equals(this.m_activeFraudSource, 2) && this.MarkFallbackFraudAlert(this.m_activeFraudIndex, authorized) {
          if authorized {
            response = "Thank you. Marmur Bank marked the " + this.FormatMoney(system, pendingAmount) + categorySuffix + " purchase as authorized. No further action is required.";
          } else {
            response = "Report received. Marmur Bank marked the " + this.FormatMoney(system, pendingAmount) + categorySuffix + " purchase as suspicious. Open the Marmur Bank website, go to Activity, and file a dispute on the matching purchase record for review.";
          };
        } else {
          if authorized {
            response = "No purchase security check is currently waiting for authorization.";
          } else {
            response = "No pending purchase security check was found. Open Activity on the Marmur Bank website if you need to dispute a transaction.";
          };
        };
      };
    };

    this.ClearActiveFraudAlert();
    this.MarkExternalAlertsRead();
    this.PushBotMessage(response, true);

    this.PushNextPendingSecurityCheck(false);
    this.OpenRootReplies();
  }

  private func HandleClearAlerts() -> Void {
    let system: ref<NCBankSystem>;
    system = this.GetBankSystem();
    if IsDefined(system) {
      system.ClearTransactionUnread();
    };
    this.MarkExternalAlertsRead();
    this.SyncNightlyUnread(false);
    this.PushBotMessage("Done. I cleared the unread indicator. Transaction history stays on file.", true);
    this.OpenRootReplies();
  }

  private func OpenRootReplies() -> Void {
    this.m_messengerController.ClearReplies();

    if !this.IsActiveFraudAlertPending() && this.GetTotalPendingFraudCount() > 0 {
      this.PushNextPendingSecurityCheck(false);
    };

    if this.IsActiveFraudAlertPending() {
      this.PushReply(EnumInt(MarmurBankReplyID.ConfirmLatestPurchase), "Yes, I authorized this purchase", true);
      this.PushReply(EnumInt(MarmurBankReplyID.ReportSuspiciousPurchase), this.T(n"mb_loc_005"), false);
    };
    this.ScrollToBottom();
  }

  private func PushReply(id: Int32, text: String, isSelected: Bool) -> Void {
    this.m_messengerController.AddReply(id, text, false, isSelected, this.m_messengerController.m_hasFocus);
    this.ApplyLanguageFontToDialog();
  }

  private func PushBotMessage(text: String, playSound: Bool) -> Void {
    this.m_messengerController.AddMessage(text, MessageViewType.Received, this.GetContactLocalizedName(), playSound);
    this.ApplyLanguageFontToDialog();
  }

  private func PushPlayerMessage(text: String) -> Void {
    this.m_messengerController.AddMessage(text, MessageViewType.Sent, this.GetContactLocalizedName(), false);
    this.ApplyLanguageFontToDialog();
  }

  private func ScrollToBottom() -> Void {
    let delaySystem: ref<DelaySystem>;
    let callback: ref<MarmurBankPhoneScrollCallback>;

    if !IsDefined(this.m_messengerController) {
      return;
    };

    this.OnDeferredScrollToBottom();

    if !IsDefined(this.m_player) {
      return;
    };

    delaySystem = GameInstance.GetDelaySystem(this.m_player.GetGame());
    if !IsDefined(delaySystem) {
      return;
    };

    callback = new MarmurBankPhoneScrollCallback();
    callback.listener = this;
    delaySystem.DelayCallback(callback, 0.10);
  }

  public func OnDeferredScrollToBottom() -> Void {
    if IsDefined(this.m_messengerController) && IsDefined(this.m_messengerController.m_scrollController) {
      this.m_messengerController.m_scrollController.SetScrollPosition(1.00);
    };
  }
}

public class MarmurBankPhoneScrollCallback extends DelayCallback {
  public let listener: wref<MarmurBankPhoneEventsListener>;

  public func Call() -> Void {
    if IsDefined(this.listener) {
      this.listener.OnDeferredScrollToBottom();
    };
  }
}


public class MarmurBankPhoneGateSystem extends ScriptableSystem {
  private let m_contact: ref<MarmurBankPhoneEventsListener>;
  private let m_registered: Bool;
  private let m_retryScheduled: Bool;

  private func IsJohnnySuppressed(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };
    return qs.GetFact(n"marmur_mod_suppressed_johnny") > 0;
  }

  private func IsRuntimeReady(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };
    return qs.GetFact(n"marmur_bank_zero_engine_ready") > 0;
  }
  private func HasCreatedAccount(gameInstance: GameInstance) -> Bool {
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) {
      return false;
    };
    return qs.GetFact(n"marmur_account_ever_opened") > 0;
  }

  public func Activate(gameInstance: GameInstance) -> Bool {
    let player: ref<PlayerPuppet>;
    let syst: ref<HoloSystem>;

    if !this.IsRuntimeReady(gameInstance) {
      this.Deactivate(gameInstance);
      return false;
    };

    if this.IsJohnnySuppressed(gameInstance) {
      this.Deactivate(gameInstance);
      return false;
    };

    if !this.HasCreatedAccount(gameInstance) {
      return false;
    };

    player = GetPlayer(gameInstance);
    if !IsDefined(player) {
      return false;
    };

    syst = HoloSystem.Get(player);
    if !IsDefined(syst) {
      return false;
    };

    if !IsDefined(this.m_contact) {
      this.m_contact = new MarmurBankPhoneEventsListener();
    };
    this.m_contact.Init(player);

    syst.AddContact(this.m_contact);
    this.m_registered = true;

    return true;
  }

  public func EnsureActive(gameInstance: GameInstance) -> Bool {
    if !this.IsRuntimeReady(gameInstance) {
      this.Deactivate(gameInstance);
      this.ScheduleActivationRetry(gameInstance);
      return false;
    };

    if this.IsJohnnySuppressed(gameInstance) {
      this.Deactivate(gameInstance);
      return false;
    };
    if !this.HasCreatedAccount(gameInstance) {
      this.Deactivate(gameInstance);
      return false;
    };
    if this.Activate(gameInstance) {
      return true;
    };
    this.ScheduleActivationRetry(gameInstance);
    return false;
  }

  private func ScheduleActivationRetry(gameInstance: GameInstance) -> Void {
    let delaySystem: ref<DelaySystem>;
    let callback: ref<MarmurBankPhoneGateRetryCallback>;

    if this.IsJohnnySuppressed(gameInstance) || this.m_retryScheduled {
      return;
    };

    delaySystem = GameInstance.GetDelaySystem(gameInstance);
    if !IsDefined(delaySystem) {
      return;
    };

    callback = new MarmurBankPhoneGateRetryCallback();
    callback.gameInstance = gameInstance;
    this.m_retryScheduled = true;
    delaySystem.DelayCallback(callback, 1.00);
  }
  public func OnActivationRetry(gameInstance: GameInstance) -> Void {
    this.m_retryScheduled = false;
    if !this.IsRuntimeReady(gameInstance) {
      this.Deactivate(gameInstance);
      this.ScheduleActivationRetry(gameInstance);
      return;
    };
    if this.IsJohnnySuppressed(gameInstance) {
      this.Deactivate(gameInstance);
      return;
    };
    if !this.Activate(gameInstance) {
      this.ScheduleActivationRetry(gameInstance);
    };
  }

  public func Deactivate(gameInstance: GameInstance) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
    let syst: ref<HoloSystem>;

    if IsDefined(player) {
      syst = HoloSystem.Get(player);
    };

    if IsDefined(syst) && IsDefined(this.m_contact) {
      syst.RemoveContact(this.m_contact);
    };

    this.m_registered = false;
  }
}

public class MarmurBankPhoneGateRetryCallback extends DelayCallback {
  public let gameInstance: GameInstance;

  public func Call() -> Void {
    let gate: ref<MarmurBankPhoneGateSystem> = GetMarmurBankPhoneGateSystem(this.gameInstance);
    if IsDefined(gate) {
      gate.OnActivationRetry(this.gameInstance);
    };
  }
}

public static func GetMarmurBankPhoneGateSystem(gameInstance: GameInstance) -> ref<MarmurBankPhoneGateSystem> {
  return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"MarmurBankPhone.MarmurBankPhoneGateSystem") as MarmurBankPhoneGateSystem;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
  let ret: Bool = wrappedMethod();
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  let gate: ref<MarmurBankPhoneGateSystem>;

  if IsDefined(player) {
    gate = GetMarmurBankPhoneGateSystem(player.GetGame());
    if IsDefined(gate) {
      gate.EnsureActive(player.GetGame());
    };
  };

  return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  let gate: ref<MarmurBankPhoneGateSystem>;

  if IsDefined(player) {
    gate = GetMarmurBankPhoneGateSystem(player.GetGame());
    if IsDefined(gate) {
      gate.Deactivate(player.GetGame());
    };
  };

  return wrappedMethod();
}
