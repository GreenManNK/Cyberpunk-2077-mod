// -----------------------------------------------------------------------------
// NCFContacts, Phone listeners for First Bank of NC + Loan Shark
// -----------------------------------------------------------------------------

module NightCityFinance.Phone

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

import NightCityFinance.Core.*
import NightCityFinance.Main.*
import NightCityFinance.Settings.*
import NightCityFinance.Utils.*

public func NCFBankContactHash() -> Int32 = 1178948164      // "FBNC"
public func NCFLoanSharkContactHash() -> Int32 = 1280267598 // "LOAN"

// ---------------------------------------------------------------------------
// Loan Shark name resolver
// ---------------------------------------------------------------------------
// Lore-flavor (settings.useCroyleNaming, default true):
//   - Pre-gig (Croyle alive): contact name is "Blake Croyle". V is dealing
//     with the predatory loan shark from "Shark in the Water" (Kabuki).
//     Voice: polished, smiling predator. Pretends to be a friend doing
//     V a favor. Calls V "choom" and "friend" as bait. Threats arrive
//     wrapped in fake concern, never raises his voice, that's the
//     point. He's the trap, not the muscle. The Animals are the muscle.
//   - Post-gig (Croyle dead per QuestsSystem fact `sts_wat_kab_06` >= 2):
//     contact swaps to "The Animals", the brutish enforcers Croyle
//     used to hire. Now they run the book directly. Voice: short,
//     barked, gym-rat thug. No charm, no pretense.
//   - Setting off: always "Loan Shark" (legacy generic).
public func NCF_LoanSharkSpeaker() -> String {
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(settings) || !settings.useCroyleNaming {
        return "Loan Shark";
    }
    if NCF_IsCroyleDead() {
        return "The Animals";
    }
    return "Blake Croyle";
}

// True when V should hear "Blake Croyle" voice lines (alive + opt-in).
public func NCF_UsingCroyleVoice() -> Bool {
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(settings) || !settings.useCroyleNaming { return false; }
    return !NCF_IsCroyleDead();
}

// True when V should hear the generic-Animals-replacement voice
// (after the gig has been completed and naming is opt-in).
public func NCF_UsingAnimalsReplacementVoice() -> Bool {
    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(settings) || !settings.useCroyleNaming { return false; }
    return NCF_IsCroyleDead();
}

// ---------------------------------------------------------------------------
// Status text builders
// ---------------------------------------------------------------------------

public func NCFBuildBankStatusBody(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> String {
    if !IsDefined(state) || !IsDefined(settings) {
        return "Account terminal unavailable.";
    }
    if !state.IsCreditLineOpen() {
        let potential: Int32 = state.GetCreditLimit(settings);
        return "Account Summary\n\nCredit Status: Not Approved\n"
            + "Pre-Approved For: " + ToString(potential) + " €$\n\n"
            + "You currently have no active credit line with First Bank of NC. "
            + "Apply for credit approval to enable spending beyond your account balance at vendors.";
    }
    let limit: Int32 = state.GetCreditLimit(settings);
    let avail: Int32 = state.GetAvailableCredit(settings);
    let cardDebt: Int32 = state.GetCardDebt();

    if cardDebt <= 0 {
        return "Account Summary\n\nCredit Status: Active\n"
            + "Credit Limit: " + ToString(limit) + " €$\n"
            + "Available: " + ToString(avail) + " €$\n"
            + "Outstanding: 0 €$\n\nAccount in excellent standing.";
    }
    let due: Int32 = state.CalculateCardPaymentDue(settings);
    return "Account Summary\n\nCredit Status: Active\n"
        + "Credit Limit: " + ToString(limit) + " €$\n"
        + "Available: " + ToString(avail) + " €$\n"
        + "Outstanding: " + ToString(cardDebt) + " €$\n"
        + "Next Payment Due: " + ToString(due) + " €$";
}

public func NCFBuildLoanSharkStatusBody(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> String {
    if !IsDefined(state) || !IsDefined(settings) {
        return "...";
    }
    let loanDebt: Int32 = state.GetLoanSharkDebt();

    // Croyle voice: polished, smiling predator. Pretends to be doing
    // V a favor. Calls V "choom" / "friend" as bait. Never raises his
    // voice, the menace is in the calm.
    if NCF_UsingCroyleVoice() {
        if loanDebt <= 0 {
            return "Hey there, choom.\n\n"
                + "Account looks good, clean as a whistle. Not a single eddie owed. "
                + "Glad we're on the same page, friend. And listen, should you ever "
                + "find yourself in a tight spot? You know who to call. Blake's always "
                + "happy to help out a friend. That's just who I am.";
        }
        let due: Int32 = state.CalculateLoanPaymentDue(settings);
        return "Hey, friend. Just checking in.\n\n"
            + "Outstanding balance: " + ToString(loanDebt) + " €$.\n"
            + "Today's friendly little payment: " + ToString(due) + " €$.\n\n"
            + "Now, I know how it goes, life gets busy, eddies get tight. "
            + "But I went out on a limb for you, choom. I'd hate to see this turn "
            + "into something it doesn't have to be. We're still friends, right?";
    }

    // Generic Animals replacement voice (post-Shark-in-the-Water).
    // Brute thug. Short, barked, gym-rat. No charm. They got tired of
    // Croyle taking the cut and now run the book themselves.
    if NCF_UsingAnimalsReplacementVoice() {
        if loanDebt <= 0 {
            return "Animals. Collections.\n\n"
                + "You owe nothing. Good for you. "
                + "Need eddies? Come to us. No more middlemen. "
                + "Same rates. Worse manners.";
        }
        let due: Int32 = state.CalculateLoanPaymentDue(settings);
        return "Listen up, twig.\n\n"
            + "Owed: " + ToString(loanDebt) + " €$.\n"
            + "Today: " + ToString(due) + " €$.\n\n"
            + "Croyle's not around to play nice anymore. "
            + "Pay or we break things. Then we break you.";
    }

    // Legacy generic loan shark voice (settings.useCroyleNaming = false).
    if loanDebt <= 0 {
        return "You don't owe me a thing right now, choom. Come back when you need cash and don't wanna deal with the bank.";
    }
    let due: Int32 = state.CalculateLoanPaymentDue(settings);
    return "Listen, gonk:\n\nYou owe me " + ToString(loanDebt) + " €$.\n"
        + "Today's cut: " + ToString(due) + " €$.\n\nDon't make me come find you.";
}

// ---------------------------------------------------------------------------
// First Bank of NC listener
// ---------------------------------------------------------------------------
public class NCFBankListener extends PhoneEventsListener {
    private let m_messengerController: wref<MessengerDialogViewController>;

    public func GetContactHash() -> Int32 {
        return NCFBankContactHash();
    }

    public func GetContactData(isText: Bool) -> ref<ContactData> {
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if IsDefined(settings) && !settings.bankEnabled { return null; }

        let contactData: ref<ContactData> = new ContactData();
        contactData.hash = NCFBankContactHash();
        contactData.localizedName = "First Bank of NC";
        contactData.contactId = "NCFinance_FirstBankNC";
        contactData.id = "NCFFBNC";
        contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
        contactData.questRelated = false;
        contactData.isCallable = false;
        if isText {
            contactData.type = MessengerContactType.SingleThread;
            contactData.lastMesssagePreview = "Manage your credit line.";
        } else {
            contactData.type = MessengerContactType.Contact;
        }
        contactData.messagesCount = 1;
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        let hasActivity: Bool = IsDefined(phoneSys) && phoneSys.HasBankActivity();
        let firstSeen: Bool = IsDefined(phoneSys) && phoneSys.IsBankFirstSeenPending();
        if hasActivity || firstSeen {
            contactData.unreadMessegeCount = 1;
            ArrayInsert(contactData.unreadMessages, 0, 1);
        } else {
            contactData.unreadMessegeCount = 0;
        }
        contactData.hasMessages = true;
        contactData.playerIsLastSender = false;
        return contactData;
    }

    public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
        if !IsDefined(messengerController) { return false; }
        this.m_messengerController = messengerController;
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) {
            phoneSys.ClearBankActivity();
            phoneSys.AckBankFirstSeen();
        }

        messengerController.ClearMessagesCustom();
        messengerController.ClearRepliesCustom();

        let lastBankNotif: String = IsDefined(phoneSys) ? phoneSys.GetLastBankNotificationText() : "";
        if StrLen(lastBankNotif) > 0 {
            messengerController.PushMessageCustom(lastBankNotif,
                MessageViewType.Received, "First Bank of NC", false);
        } else {
            messengerController.PushMessageCustom(
                "Welcome to First Bank of Night City. How can we help you today, V?",
                MessageViewType.Received, "First Bank of NC", false
            );
        }
        this.RenderMainMenu();
        return true;
    }

    private func RenderMainMenu() -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let hasDebt: Bool = IsDefined(state) && state.GetCardDebt() > 0;
        let lineOpen: Bool = IsDefined(state) && state.IsCreditLineOpen();

        let isFirst: Bool = true;
        this.m_messengerController.PushReplyCustom(10, "What's my account status?",
            false, isFirst, this.m_messengerController.m_hasFocus);
        isFirst = false;

        if hasDebt {
            this.m_messengerController.PushReplyCustom(11, "Pay the minimum",
                false, isFirst, this.m_messengerController.m_hasFocus);
            this.m_messengerController.PushReplyCustom(12, "Pay it all off",
                false, isFirst, this.m_messengerController.m_hasFocus);
            this.m_messengerController.PushReplyCustom(13, "I need a 3-day extension",
                false, isFirst, this.m_messengerController.m_hasFocus);
        }
        if !lineOpen {
            this.m_messengerController.PushReplyCustom(15, "I'd like to open a credit line",
                false, isFirst, this.m_messengerController.m_hasFocus);
        } else if !hasDebt {
            this.m_messengerController.PushReplyCustom(16, "Close my credit line",
                false, isFirst, this.m_messengerController.m_hasFocus);
        }
        this.m_messengerController.PushReplyCustom(14, "Goodbye",
            false, isFirst, this.m_messengerController.m_hasFocus);
    }

    public func ActivateReply(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.ClearRepliesCustom();

        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if !IsDefined(state) || !IsDefined(settings) { return; }

        switch messageID {
            case 10:
                ctrl.PushMessageCustom("What's my account status?",
                    MessageViewType.Sent, "V", false);
                this.PushDelayedReply(NCFBuildBankStatusBody(state, settings), 1.0);
                this.RenderMainMenu();
                return;
            case 11:
                ctrl.PushMessageCustom("Pay the minimum",
                    MessageViewType.Sent, "V", false);
                this.HandleBankPayment(state, settings, false);
                return;
            case 12:
                ctrl.PushMessageCustom("Pay it all off",
                    MessageViewType.Sent, "V", false);
                this.HandleBankPayment(state, settings, true);
                return;
            case 13:
                ctrl.PushMessageCustom("I need a 3-day extension",
                    MessageViewType.Sent, "V", false);
                this.HandleBankExtension(state, settings);
                return;
            case 14:
                ctrl.PushMessageCustom("Goodbye",
                    MessageViewType.Sent, "V", false);
                ctrl.PushMessageCustom("Thank you for banking with us, V.",
                    MessageViewType.Received, "First Bank of NC", false);
                return;
            case 15:
                ctrl.PushMessageCustom("I'd like to open a credit line",
                    MessageViewType.Sent, "V", false);
                this.HandleOpenCredit(state, settings);
                return;
            case 16:
                ctrl.PushMessageCustom("Close my credit line",
                    MessageViewType.Sent, "V", false);
                this.HandleCloseCredit(state, settings);
                return;
        }
    }

    private func HandleOpenCredit(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if state.IsCreditLineOpen() {
            this.PushDelayedReply("Your credit line is already active, V.", 0.8);
            this.RenderMainMenu();
            return;
        }
        state.OpenCreditLine();
        let limit: Int32 = state.GetCreditLimit(settings);
        let confirmText: String = "Approved. Your credit line is now active with a limit of "
            + ToString(limit) + " €$. You can spend beyond your account balance at any vendor up to this amount; "
            + "any drawn credit will accrue daily interest until repaid. Welcome aboard, V.";
        let followUp: String = NCFBuildBankStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.2);
        this.RenderMainMenu();
    }

    private func HandleCloseCredit(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if !state.IsCreditLineOpen() {
            this.PushDelayedReply("You don't currently have an open credit line, V.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let closed: Bool = state.CloseCreditLine();
        if !closed {
            this.PushDelayedReply(
                "We can't close your account while there's an outstanding balance, V. "
                + "Please settle your debt first.", 1.0);
            this.RenderMainMenu();
            return;
        }
        let confirmText: String = "Done. Your credit line has been closed. "
            + "Your account remains open for everyday banking, feel free to apply again any time.";
        let followUp: String = NCFBuildBankStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.0);
        this.RenderMainMenu();
    }

    private func HandleBankPayment(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, payInFull: Bool) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let cardDebt: Int32 = state.GetCardDebt();
        if cardDebt <= 0 {
            this.PushDelayedReply("You have no outstanding balance, V.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let amount: Int32 = payInFull ? cardDebt : state.CalculateCardPaymentDue(settings);
        // Real spendable money excludes any credit currently injected
        // into the wallet. The bank cannot accept payment for the same
        // credit line by re-spending that line's injected credit.
        let main: ref<NCFMainSystem> = NCFMainSystem.Get();
        let walletBalance: Int32 = IsDefined(main) ? main.GetRealPlayerMoney() : NCF_GetPlayerMoney();
        if walletBalance < amount {
            this.PushDelayedReply(
                "We're sorry V, the transaction was declined. Insufficient funds in your linked account ("
                + ToString(walletBalance) + " €$ available, " + ToString(amount) + " €$ required).", 1.2);
            this.RenderMainMenu();
            return;
        }
        NCF_RemovePlayerMoney(amount);
        state.ReduceDebt(amount);
        if state.GetCardDebt() <= 0 {
            state.ScheduleNextCardPayment(0);
        }
        let confirmText: String = payInFull
            ? "Payment of " + ToString(amount) + " €$ received. Your account is now paid in full. Thank you, V."
            : "Payment of " + ToString(amount) + " €$ received. Remaining balance: " + ToString(state.GetCardDebt()) + " €$.";
        let followUp: String = NCFBuildBankStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.0);
        this.RenderMainMenu();
    }

    private func HandleBankExtension(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let cardDebt: Int32 = state.GetCardDebt();
        if cardDebt <= 0 {
            this.PushDelayedReply("No active debt to extend, V.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let i: Int32 = 0;
        let totalInterest: Int32 = 0;
        while i < 3 {
            totalInterest += state.AccrueInterest(settings);
            i += 1;
        }
        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.ScheduleNextCardPayment(currentDay + 3);
        let confirmText: String = "Extension granted. Your next payment is now due in 3 days. A "
            + ToString(totalInterest) + " €$ convenience fee has been added to your balance. New outstanding: "
            + ToString(state.GetCardDebt()) + " €$.";
        let followUp: String = NCFBuildBankStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.2);
        this.RenderMainMenu();
    }

    private func PushDelayedReply(text: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom("First Bank of NC");
        this.m_pendingReplyText = text;
        this.m_pendingFollowUp = "";
        let delaySys: wref<DelaySystem> = this.m_messengerController.m_delaySystem;
        if IsDefined(delaySys) {
            this.AddTypingDelay(delaySys, delay, 0);
        } else {
            this.OnDelayedTypingEnd(0);
        }
    }

    private func PushDelayedReplyWithFollowUp(text: String, followUp: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom("First Bank of NC");
        this.m_pendingReplyText = text;
        this.m_pendingFollowUp = followUp;
        let delaySys: wref<DelaySystem> = this.m_messengerController.m_delaySystem;
        if IsDefined(delaySys) {
            this.AddTypingDelay(delaySys, delay, 0);
        } else {
            this.OnDelayedTypingEnd(0);
        }
    }

    private let m_pendingReplyText: String;
    private let m_pendingFollowUp: String;

    private func OnDelayedTypingEnd(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.StopDotsAnimation();
        if messageID == 0 {
            ctrl.PushMessageCustom(this.m_pendingReplyText,
                MessageViewType.Received, "First Bank of NC", true);
            if StrLen(this.m_pendingFollowUp) > 0 {
                ctrl.PlayDotsAnimationCustom("First Bank of NC");
                let delaySys: wref<DelaySystem> = ctrl.m_delaySystem;
                if IsDefined(delaySys) {
                    this.AddTypingDelay(delaySys, 1.4, 1);
                } else {
                    this.OnDelayedTypingEnd(1);
                }
            }
            return;
        }
        ctrl.PushMessageCustom(this.m_pendingFollowUp,
            MessageViewType.Received, "First Bank of NC", false);
        this.m_pendingFollowUp = "";
    }
}

// ---------------------------------------------------------------------------
// Loan Shark listener
// ---------------------------------------------------------------------------
public class NCFLoanSharkListener extends PhoneEventsListener {
    private let m_messengerController: wref<MessengerDialogViewController>;
    private let m_pendingReplyText: String;
    private let m_pendingFollowUp: String;
    private let m_threatCount: Int32;
    // Cached at ShowDialog so all in-thread messages use the same speaker
    // even if the player's phone sits open across the gig completion.
    // Voice flags cached likewise so the dialogue stays consistent for
    // the duration of the conversation.
    private let m_speaker: String;
    private let m_useCroyleVoice: Bool;
    private let m_useAnimalsVoice: Bool;

    public func GetContactHash() -> Int32 {
        return NCFLoanSharkContactHash();
    }

    public func GetContactData(isText: Bool) -> ref<ContactData> {
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if IsDefined(settings) && !settings.loanSharkEnabled { return null; }

        let speaker: String = NCF_LoanSharkSpeaker();
        let preview: String;
        if NCF_UsingCroyleVoice() {
            preview = "Hey there, choom.";
        } else if NCF_UsingAnimalsReplacementVoice() {
            preview = "Speak, twig.";
        } else {
            preview = "What do you want, gonk?";
        }

        let contactData: ref<ContactData> = new ContactData();
        contactData.hash = NCFLoanSharkContactHash();
        contactData.localizedName = speaker;
        contactData.contactId = "NCFinance_LoanShark";
        contactData.id = "NCFLOAN";
        contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
        contactData.questRelated = false;
        contactData.isCallable = false;
        if isText {
            contactData.type = MessengerContactType.SingleThread;
            contactData.lastMesssagePreview = preview;
        } else {
            contactData.type = MessengerContactType.Contact;
        }
        contactData.messagesCount = 1;
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        let hasActivity: Bool = IsDefined(phoneSys) && phoneSys.HasLoanSharkActivity();
        let firstSeen: Bool = IsDefined(phoneSys) && phoneSys.IsLoanSharkFirstSeenPending();
        if hasActivity || firstSeen {
            contactData.unreadMessegeCount = 1;
            ArrayInsert(contactData.unreadMessages, 0, 1);
        } else {
            contactData.unreadMessegeCount = 0;
        }
        contactData.hasMessages = true;
        contactData.playerIsLastSender = false;
        return contactData;
    }

    public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
        if !IsDefined(messengerController) { return false; }
        this.m_messengerController = messengerController;
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) {
            phoneSys.ClearLoanSharkActivity();
            phoneSys.AckLoanSharkFirstSeen();
        }
        this.m_threatCount = 0;

        // Cache speaker + voice flags ONCE per dialog open. If V somehow
        // completes the gig with the phone still mid-conversation, we
        // don't want the speaker name to flicker mid-thread. The flags
        // settle at the moment the player taps the contact.
        this.m_speaker = NCF_LoanSharkSpeaker();
        this.m_useCroyleVoice = NCF_UsingCroyleVoice();
        this.m_useAnimalsVoice = NCF_UsingAnimalsReplacementVoice();

        let greeting: String;
        if this.m_useCroyleVoice {
            greeting = "Heyyyy, choom! Good to hear from you. What can Blake do for a friend today?";
        } else if this.m_useAnimalsVoice {
            greeting = "Yeah? Talk fast, twig.";
        } else {
            greeting = "What do you want, gonk?";
        }

        messengerController.ClearMessagesCustom();
        messengerController.ClearRepliesCustom();

        let lastLoanNotif: String = IsDefined(phoneSys) ? phoneSys.GetLastLoanSharkNotificationText() : "";
        if StrLen(lastLoanNotif) > 0 {
            messengerController.PushMessageCustom(lastLoanNotif,
                MessageViewType.Received, this.m_speaker, false);
        } else {
            messengerController.PushMessageCustom(
                greeting,
                MessageViewType.Received, this.m_speaker, false
            );
        }
        this.RenderMainMenu();
        return true;
    }

    private func RenderMainMenu() -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        let hasDebt: Bool = IsDefined(state) && state.GetLoanSharkDebt() > 0;
        let canBorrow: Bool = IsDefined(state) && IsDefined(settings)
            && settings.loanSharkEnabled && state.CanTakeNewLoan();
        let streetCred: Int32 = NCF_GetStreetCredLevel();

        let isFirst: Bool = true;
        this.m_messengerController.PushReplyCustom(20, "What do I owe?",
            false, isFirst, this.m_messengerController.m_hasFocus);
        isFirst = false;

        if hasDebt {
            this.m_messengerController.PushReplyCustom(21, "Take what I have on me",
                false, isFirst, this.m_messengerController.m_hasFocus);
            this.m_messengerController.PushReplyCustom(22, "I'll pay it all off",
                false, isFirst, this.m_messengerController.m_hasFocus);
            this.m_messengerController.PushReplyCustom(23, "I need more time, choom",
                false, isFirst, this.m_messengerController.m_hasFocus);
        }
        if canBorrow {
            let small: Int32 = settings.loanSmallAmount;
            this.m_messengerController.PushReplyCustom(26,
                "I need a small loan (" + ToString(small) + " €$)",
                false, isFirst, this.m_messengerController.m_hasFocus);
            if streetCred >= 10 {
                let med: Int32 = settings.loanMediumAmount;
                this.m_messengerController.PushReplyCustom(27,
                    "I need a real loan (" + ToString(med) + " €$)",
                    false, isFirst, this.m_messengerController.m_hasFocus);
            }
            if streetCred >= 30 {
                let large: Int32 = settings.loanLargeAmount;
                this.m_messengerController.PushReplyCustom(28,
                    "I need serious money (" + ToString(large) + " €$)",
                    false, isFirst, this.m_messengerController.m_hasFocus);
            }
        }
        this.m_messengerController.PushReplyCustom(25, "Later",
            false, isFirst, this.m_messengerController.m_hasFocus);
    }

    public func ActivateReply(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.ClearRepliesCustom();

        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if !IsDefined(state) || !IsDefined(settings) { return; }

        switch messageID {
            case 20:
                ctrl.PushMessageCustom("What do I owe?",
                    MessageViewType.Sent, "V", false);
                this.PushDelayedReply(NCFBuildLoanSharkStatusBody(state, settings), 1.0);
                this.RenderMainMenu();
                return;
            case 21:
                ctrl.PushMessageCustom("Take what I have on me",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanPayment(state, settings, false);
                return;
            case 22:
                ctrl.PushMessageCustom("I'll pay it all off",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanPayment(state, settings, true);
                return;
            case 23:
                ctrl.PushMessageCustom("I need more time, choom",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanExtension(state, settings);
                return;
            case 24:
                ctrl.PushMessageCustom("F off",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanThreat(state, settings);
                return;
            case 25:
                ctrl.PushMessageCustom("Later",
                    MessageViewType.Sent, "V", false);
                ctrl.PushMessageCustom(this.GoodbyeLine(),
                    MessageViewType.Received, this.m_speaker, false);
                return;
            case 26:
                ctrl.PushMessageCustom("I need a small loan (" + ToString(settings.loanSmallAmount) + " €$)",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanBorrow(state, settings, settings.loanSmallAmount, 0);
                return;
            case 27:
                ctrl.PushMessageCustom("I need a real loan (" + ToString(settings.loanMediumAmount) + " €$)",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanBorrow(state, settings, settings.loanMediumAmount, 10);
                return;
            case 28:
                ctrl.PushMessageCustom("I need serious money (" + ToString(settings.loanLargeAmount) + " €$)",
                    MessageViewType.Sent, "V", false);
                this.HandleLoanBorrow(state, settings, settings.loanLargeAmount, 30);
                return;
        }
    }

    // Pick a string variant based on the voice cached at ShowDialog.
    // Croyle: polished smiling predator. Pretends to be a friend.
    // Animals: brute thug. Short, barked, gym-rat threats.
    // Legacy: original generic loan shark voice (settings opted out).
    private func VoiceLine(croyle: String, animals: String, legacy: String) -> String {
        if this.m_useCroyleVoice { return croyle; }
        if this.m_useAnimalsVoice { return animals; }
        return legacy;
    }

    private func GoodbyeLine() -> String {
        return this.VoiceLine(
            "Take care, friend. And remember, Blake's only ever a call away. Anything you need.",
            "Yeah. Walk.",
            "Yeah, yeah. Don't make me wait too long."
        );
    }

    private func HandleLoanPayment(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, payInFull: Bool) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let loanDebt: Int32 = state.GetLoanSharkDebt();
        if loanDebt <= 0 {
            this.PushDelayedReply(this.VoiceLine(
                "Oh, choom, your account's clean as a whistle. Nothing owed. But that's sweet of you to check in.",
                "Owe nothing. Stop wasting my time.",
                "You don't owe me anything. Yet."
            ), 0.8);
            this.RenderMainMenu();
            return;
        }
        // Real spendable money excludes any credit currently injected
        // into the wallet by the vendor-open credit-line system. Loan
        // sharks must be paid in real eddies, not borrowed credit.
        let main: ref<NCFMainSystem> = NCFMainSystem.Get();
        let walletBalance: Int32 = IsDefined(main) ? main.GetRealPlayerMoney() : NCF_GetPlayerMoney();
        let amount: Int32 = payInFull ? loanDebt : state.CalculateLoanPaymentDue(settings);
        if !payInFull && amount > walletBalance { amount = walletBalance; }
        if amount > loanDebt { amount = loanDebt; }

        if amount <= 0 {
            this.PushDelayedReply(this.VoiceLine(
                "Hey, hey, easy now, friend. You don't have a single eddie on you. We can't make magic happen out of nothing, can we? Go scrape something together. I'll wait. Patient guy, me.",
                "Pockets empty? Pathetic. Don't come back without eddies.",
                "You're broke, choom. That ain't gonna fly with me."
            ), 1.2);
            this.RenderMainMenu();
            return;
        }
        if walletBalance < amount {
            this.PushDelayedReply(this.VoiceLine(
                "Now choom, look, I know how it goes. You SAID you'd pay " + ToString(amount) + " €$. And I REALLY want to believe you. But your wallet's telling a different story. Let's not start lying to each other this early.",
                "You ain't got " + ToString(amount) + " €$. Don't lie to me, twig.",
                "Don't waste my time. You ain't got " + ToString(amount) + " €$."
            ), 1.0);
            this.RenderMainMenu();
            return;
        }
        NCF_RemovePlayerMoney(amount);
        state.ReduceLoanShark(amount);
        // v0.16.0: record payment day for ambush cooldown logic
        let payDay: Int32 = GameInstance.GetGameTime(GetGameInstance()).Days();
        state.MarkLoanSharkPayment(payDay);
        if state.GetLoanSharkDebt() <= 0 {
            state.ScheduleNextLoanPayment(0);
        }
        let confirmText: String;
        if payInFull {
            confirmText = this.VoiceLine(
                "Beautiful, choom! " + ToString(amount) + " €$, paid in full. See, this is what I love, you and me, we're on the same team. Account closed, all square. And remember, friend: my door's always open if you need a little help getting back on your feet. Always.",
                ToString(amount) + " €$ received. Clean. Don't need to see you again. Don't make me.",
                "Smart move, " + ToString(amount) + " €$ received. We're square. Don't be a stranger."
            );
        } else {
            confirmText = this.VoiceLine(
                "Got it, friend, " + ToString(amount) + " €$ received. Every little bit helps! Just " + ToString(state.GetLoanSharkDebt()) + " €$ left on the books. We'll get there together, choom. One step at a time.",
                ToString(amount) + " €$. Owe " + ToString(state.GetLoanSharkDebt()) + " €$ more. Pay faster.",
                "Got " + ToString(amount) + " €$. Still owe me " + ToString(state.GetLoanSharkDebt()) + " €$. Don't get cute."
            );
        }
        let followUp: String = NCFBuildLoanSharkStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.0);
        this.RenderMainMenu();
    }

    private func HandleLoanBorrow(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, amount: Int32, requiredStreetCred: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if !settings.loanSharkEnabled {
            this.PushDelayedReply(this.VoiceLine(
                "Sorry, choom, Blake's not lending right now. Bad timing. Try me again, friend.",
                "Closed. Walk.",
                "Boss says we ain't lendin' right now. Try again later."
            ), 1.0);
            this.RenderMainMenu();
            return;
        }
        let streetCred: Int32 = NCF_GetStreetCredLevel();
        if streetCred < requiredStreetCred {
            this.PushDelayedReply(this.VoiceLine(
                "Listen, friend, I'd love to help. Truly. But I gotta protect my investments, and you... you're still building your name out there. Come back when more people know who you are, and I'll set you up proper. Promise.",
                "Nobody knows you. Nobody lends you that much. Earn your name first.",
                "You ain't built up enough rep for that kind of cash, choom. Come back when you got a name."
            ), 1.2);
            this.RenderMainMenu();
            return;
        }
        if !state.CanTakeNewLoan() {
            this.PushDelayedReply(this.VoiceLine(
                "Whoa, choom, slow down. We've still got an open ticket between us, you and me. Settle that first, then we can talk about more. It's just good business, friend. You understand.",
                "One loan. Pay it. Then talk.",
                "One loan at a time, gonk. Pay off what you owe me first."
            ), 1.0);
            this.RenderMainMenu();
            return;
        }
        if amount <= 0 {
            this.PushDelayedReply(this.VoiceLine(
                "No worries, friend. Take your time, think it over. I'll be here.",
                "Then don't waste my time.",
                "Whatever, choom. Talk to me when you mean it."
            ), 0.8);
            this.RenderMainMenu();
            return;
        }
        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.TakeLoan(amount, settings.loanInterestRate, currentDay, settings.loanDueDays);
        let main: ref<NCFMainSystem> = NCFMainSystem.Get();
        if IsDefined(main) {
            main.GiveTaxFreeMoney(amount);
        }
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) { phoneSys.MarkLoanSharkActivity(); }

        let dailyDue: Int32 = state.CalculateLoanPaymentDue(settings);
        let confirmText: String = this.VoiceLine(
            "There you go, choom, " + ToString(amount) + " €$ wired straight to you. See? Told you Blake takes care of his friends. Now, just a few small details, nothing to lose sleep over: " + ToString(settings.loanInterestRate) + "% daily, full balance due in " + ToString(settings.loanDueDays) + " days. Daily cut's about " + ToString(dailyDue) + " €$, pocket change for someone like you. Stay in touch, friend. We'll do great things together.",
            ToString(amount) + " €$. Sent. " + ToString(settings.loanInterestRate) + "% daily. Due in " + ToString(settings.loanDueDays) + " days. Daily cut: " + ToString(dailyDue) + " €$. Miss it once. We come knocking.",
            "Done. " + ToString(amount) + " €$ in your account. " + ToString(settings.loanInterestRate) + "% daily, " + ToString(settings.loanDueDays) + " days till the whole thing's due. Daily cut starts tomorrow, about " + ToString(dailyDue) + " €$ a day. Miss a payment and we'll have a problem."
        );
        let followUp: String = NCFBuildLoanSharkStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.5);
        this.RenderMainMenu();
    }

    private func HandleLoanExtension(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let loanDebt: Int32 = state.GetLoanSharkDebt();
        if loanDebt <= 0 {
            this.PushDelayedReply(this.VoiceLine(
                "Friend, there's nothing to extend. You're all caught up. Relax!",
                "Nothing owed. Nothing to extend.",
                "Nothing to extend, choom."
            ), 0.8);
            this.RenderMainMenu();
            return;
        }
        let baseInterest: Int32 = NCF_CalculatePercentage(loanDebt, settings.loanInterestRate);
        let fee: Int32 = baseInterest * 6;
        if fee < 1 { fee = 1; }
        let appliedPenalty: Int32 = state.AddLoanPenalty(fee, settings);

        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.ScheduleNextLoanPayment(currentDay + 3);
        let confirmText: String = this.VoiceLine(
            "Of course, choom. Of course. Three more days, no problem at all. Just a small handling fee, " + ToString(appliedPenalty) + " €$, gets you breathing room. Brings the total to " + ToString(state.GetLoanSharkDebt()) + " €$. See? Blake always works it out for a friend. Always.",
            "Three days. " + ToString(appliedPenalty) + " €$ extra. Total now " + ToString(state.GetLoanSharkDebt()) + " €$. Don't ask twice.",
            "Three days. That's it. And it'll cost you " + ToString(appliedPenalty) + " €$ extra on top. New total: " + ToString(state.GetLoanSharkDebt()) + " €$. Don't make me regret this."
        );
        let followUp: String = NCFBuildLoanSharkStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.5);
        this.RenderMainMenu();
    }

    private let MAX_THREATS: Int32 = 3;

    private func HandleLoanThreat(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let loanDebt: Int32 = state.GetLoanSharkDebt();
        if loanDebt <= 0 {
            this.PushDelayedReply(this.VoiceLine(
                "Hahaha, easy, choom. Save that energy. You don't owe me anything. We're friends, remember?",
                "Big talk. No debt. Hang up.",
                "Brave words from someone who don't owe me nothin'. Try me when you do."
            ), 1.2);
            this.RenderMainMenu();
            return;
        }
        if this.m_threatCount >= this.MAX_THREATS {
            this.PushDelayedReply(this.VoiceLine(
                "Alright. Alright, choom. I tried to be civil. I really did. The Animals will be paying you a visit, purely social, you understand. Just to talk. Maybe stop by your place. Meet your family. You take care now, friend.",
                "Done talking. Boys are coming. Hope you got insurance.",
                "I'm done talkin' to you. Either pay up or hang up. My boys'll handle the rest."
            ), 1.5);
            this.RenderMainMenu();
            return;
        }
        this.m_threatCount += 1;
        let penalty: Int32 = state.AddLoanPenalty(loanDebt, settings);
        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.ScheduleNextLoanPayment(currentDay + 1);
        let warning: String = this.m_threatCount >= this.MAX_THREATS
            ? this.VoiceLine(
                " And choom, friend to friend? That's the last one. Push me one more time and I stop being so reasonable.",
                " Last warning, twig. Push again and we visit.",
                " Last warning, gonk. Push me one more time and I stop talking."
            )
            : "";
        let confirmText: String = this.VoiceLine(
            "Hahaha, oh, choom. Strong words. Strong, strong words. That little tantrum just cost you " + ToString(penalty) + " €$, call it a friendship tax. And I want everything by tomorrow. Don't make me send the boys to come find you. They get enthusiastic." + warning,
            "Cute. " + ToString(penalty) + " €$ added. Pay tomorrow. Or we visit." + warning,
            "Cute. Real cute. That little outburst just cost you " + ToString(penalty) + " €$. And I want my money tomorrow. Don't run, choom. I'll find you." + warning
        );
        let followUp: String = NCFBuildLoanSharkStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirmText, followUp, 1.8);
        this.RenderMainMenu();
    }

    private func PushDelayedReply(text: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom(this.m_speaker);
        this.m_pendingReplyText = text;
        this.m_pendingFollowUp = "";
        let delaySys: wref<DelaySystem> = this.m_messengerController.m_delaySystem;
        if IsDefined(delaySys) {
            this.AddTypingDelay(delaySys, delay, 0);
        } else {
            this.OnDelayedTypingEnd(0);
        }
    }

    private func PushDelayedReplyWithFollowUp(text: String, followUp: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom(this.m_speaker);
        this.m_pendingReplyText = text;
        this.m_pendingFollowUp = followUp;
        let delaySys: wref<DelaySystem> = this.m_messengerController.m_delaySystem;
        if IsDefined(delaySys) {
            this.AddTypingDelay(delaySys, delay, 0);
        } else {
            this.OnDelayedTypingEnd(0);
        }
    }

    private func OnDelayedTypingEnd(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.StopDotsAnimation();
        if messageID == 0 {
            ctrl.PushMessageCustom(this.m_pendingReplyText,
                MessageViewType.Received, this.m_speaker, true);
            if StrLen(this.m_pendingFollowUp) > 0 {
                ctrl.PlayDotsAnimationCustom(this.m_speaker);
                let delaySys: wref<DelaySystem> = ctrl.m_delaySystem;
                if IsDefined(delaySys) {
                    this.AddTypingDelay(delaySys, 1.4, 1);
                } else {
                    this.OnDelayedTypingEnd(1);
                }
            }
            return;
        }
        ctrl.PushMessageCustom(this.m_pendingFollowUp,
            MessageViewType.Received, this.m_speaker, false);
        this.m_pendingFollowUp = "";
    }
}
