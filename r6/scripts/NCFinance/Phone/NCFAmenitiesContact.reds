// -----------------------------------------------------------------------------
// NCFAmenitiesContact — NC Amenities Corp phone listener
// -----------------------------------------------------------------------------
//
// NC Amenities Corp is the fictional megabuilding services bundler that
// handles water, net connection, heating, and electricity for V's apartment.
// The contact voice is corporate-bland with passive-aggressive subtext —
// the kind of automated "customer success" tone that was already dystopian
// in 2024 and has gotten worse.
//
// Reply ID range: 30–49  (clear of Bank 10–16, Loan Shark 20–28)
//
// States:
//   Not subscribed  → offer Basic or Premium
//   Subscribed, no debt → show status, offer cancel, offer upgrade/downgrade
//   Subscribed, debt, grace > 0 → show bill + grace countdown, offer pay
//   Subscribed, SUSPENDED (debt > 0 && grace == 0) → show suspension notice, offer pay
//
// Tier names:
//   1 = "Basic"   — limited usage, standard services
//   2 = "Premium" — unlimited usage, priority services, bonus amenities
// -----------------------------------------------------------------------------

module NightCityFinance.Phone

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

import NightCityFinance.Core.*
import NightCityFinance.Main.*
import NightCityFinance.Settings.*
import NightCityFinance.Utils.*

public func NCFAmenitiesContactHash() -> Int32 = 1380451234  // "NCAC"

// Contact hash must be imported into NCFMainSystem for the notification push.
// NCFMainSystem already imports NightCityFinance.Phone.*, so this free
// function is visible there automatically.

// ---------------------------------------------------------------------------
// Status builder
// ---------------------------------------------------------------------------
public func NCFBuildAmenitiesStatusBody(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> String {
    if !IsDefined(state) || !IsDefined(settings) {
        return "Service portal temporarily unavailable. Please try again later.";
    }

    let tier: Int32 = state.GetAmenitiesTier();
    let debt: Int32 = state.GetAmenitiesDebt();
    let grace: Int32 = state.GetAmenitiesGraceDaysLeft();
    let suspended: Bool = state.IsAmenitiesSuspended();

    if tier <= 0 {
        return "Account Overview\n\nStatus: No Active Plan\n\n"
            + "You currently have no amenities contract with NC Amenities Corp. "
            + "Subscribe to a plan to ensure uninterrupted access to water, net, "
            + "heating, and electricity at your current residence.\n\n"
            + "Basic Plan: " + ToString(settings.amenitiesBasicDailyRate) + " €$/day\n"
            + "Premium Plan: " + ToString(settings.amenitiesPremiumDailyRate) + " €$/day";
    }

    let tierName: String = tier == 1 ? "Basic" : "Premium";
    let rate: Int32 = tier == 1 ? settings.amenitiesBasicDailyRate : settings.amenitiesPremiumDailyRate;

    // v2.1: surface billing cycle + next-bill timing + prepay balance.
    // Cycle line is omitted from suspended-status block to keep that
    // copy focused on the urgency.
    let period: Int32 = settings.amenitiesBillingPeriodDays;
    if period < 1 { period = 1; }
    let cycleLine: String = NCFBuildCycleLine(period, rate);
    let prepaid: Int32 = state.GetAmenitiesPrepaidDays();
    let prepaidLine: String = "";
    if prepaid > 0 {
        prepaidLine = "\nPre-paid: " + ToString(prepaid) + " day(s) — covers approx. "
            + ToString(prepaid / period) + " full billing cycle(s)";
    }
    let nextBillLine: String = NCFBuildNextBillLine(state.GetNextAmenitiesBillDay());

    if suspended {
        return "Account Overview\n\nPlan: " + tierName + "\nStatus: SUSPENDED\n"
            + "Outstanding Balance: " + ToString(debt) + " €$\n\n"
            + "Your services have been suspended due to non-payment. "
            + "Water, net, heating, and electricity at your current residence are currently "
            + "INACTIVE. Please settle your outstanding balance immediately to restore service. "
            + "NC Amenities Corp apologizes for any inconvenience this may cause.";
    }

    if debt > 0 {
        return "Account Overview\n\nPlan: " + tierName + "\nStatus: Active (Payment Due)\n"
            + cycleLine + nextBillLine + prepaidLine + "\n"
            + "Outstanding Balance: " + ToString(debt) + " €$\n"
            + "Grace Period Remaining: " + ToString(grace) + " billing cycle(s)\n\n"
            + "Please settle your outstanding balance to avoid service suspension. "
            + "Services will be suspended if payment is not received within the grace period.";
    }

    return "Account Overview\n\nPlan: " + tierName + "\nStatus: Active\n"
        + cycleLine + nextBillLine + prepaidLine + "\n"
        + "Outstanding Balance: 0 €$\n\n"
        + "All services active. Thank you for being a valued NC Amenities Corp customer.";
}

// v2.1: format the cycle line consistently. Daily reads natural ("200 €$/day,
// billed daily"); weekly+ shows the bundled cost so the player knows what
// hits their wallet next ("200 €$/day, billed weekly: 1400 €$").
public func NCFBuildCycleLine(period: Int32, dailyRate: Int32) -> String {
    let label: String;
    switch period {
        case 1:  label = "daily"; break;
        case 7:  label = "weekly"; break;
        case 14: label = "bi-weekly"; break;
        case 30: label = "monthly"; break;
        default: label = "every " + ToString(period) + " days";
    }
    if period <= 1 {
        return "Daily Rate: " + ToString(dailyRate) + " €$, billed " + label;
    }
    return "Daily Rate: " + ToString(dailyRate) + " €$, billed " + label
        + ": " + ToString(period * dailyRate) + " €$/cycle";
}

public func NCFBuildNextBillLine(nextBillDay: Int32) -> String {
    if nextBillDay <= 0 { return ""; }
    let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
    let daysUntil: Int32 = nextBillDay - currentDay;
    if daysUntil <= 0 { return "\nNext Bill: due today"; }
    if daysUntil == 1 { return "\nNext Bill: tomorrow"; }
    return "\nNext Bill: in " + ToString(daysUntil) + " day(s)";
}

// ---------------------------------------------------------------------------
// NC Amenities Corp listener
// ---------------------------------------------------------------------------
public class NCFAmenitiesListener extends PhoneEventsListener {
    private let m_messengerController: wref<MessengerDialogViewController>;
    private let m_pendingReplyText: String;
    private let m_pendingFollowUp: String;

    public func GetContactHash() -> Int32 {
        return NCFAmenitiesContactHash();
    }

    public func GetContactData(isText: Bool) -> ref<ContactData> {
        let settings: ref<NCFSettings> = NCFSettings.Get();
        if IsDefined(settings) && !settings.amenitiesEnabled { return null; }

        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let suspended: Bool = IsDefined(state) && state.IsAmenitiesSuspended();
        let preview: String = suspended
            ? "URGENT: Your services have been suspended."
            : "Manage your amenities contract.";

        let contactData: ref<ContactData> = new ContactData();
        contactData.hash = NCFAmenitiesContactHash();
        contactData.localizedName = "NC Amenities Corp";
        contactData.contactId = "NCFinance_AmenitiesCorp";
        contactData.id = "NCFNCAC";
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
        let hasActivity: Bool = IsDefined(phoneSys) && phoneSys.HasAmenitiesActivity();
        let firstSeen: Bool = IsDefined(phoneSys) && phoneSys.IsAmenitiesFirstSeenPending();
        if hasActivity || firstSeen || suspended {
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
            phoneSys.ClearAmenitiesActivity();
            phoneSys.AckAmenitiesFirstSeen();
        }

        messengerController.ClearMessagesCustom();
        messengerController.ClearRepliesCustom();

        // If there was a recent notification (daily bill, suspension alert), show it
        // as the opening message so the preview text the player saw is in the thread.
        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let lastNotif: String = IsDefined(phoneSys) ? phoneSys.GetLastAmenitiesNotificationText() : "";
        if StrLen(lastNotif) > 0 {
            messengerController.PushMessageCustom(lastNotif,
                MessageViewType.Received, "NC Amenities Corp", false);
        } else {
            // No prior notification — show the corporate intro on first open
            messengerController.PushMessageCustom(
                "Thank you for contacting NC Amenities Corp, your trusted partner for residential utility services.\n\n"
                + "We bundle water, high-speed net, heating, and electricity into one convenient monthly contract, "
                + "so you can focus on what matters and leave the infrastructure to us.\n\n"
                + "How can we assist you today?",
                MessageViewType.Received, "NC Amenities Corp", false
            );
        }
        this.RenderMainMenu();
        return true;
    }

    private func RenderMainMenu() -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        let settings: ref<NCFSettings> = NCFSettings.Get();
        let tier: Int32 = IsDefined(state) ? state.GetAmenitiesTier() : 0;
        let hasDebt: Bool = IsDefined(state) && state.GetAmenitiesDebt() > 0;
        let subscribed: Bool = tier > 0;

        let isFirst: Bool = true;

        // Status is always available
        this.m_messengerController.PushReplyCustom(30, "What's my account status?",
            false, isFirst, this.m_messengerController.m_hasFocus);
        isFirst = false;

        if hasDebt {
            this.m_messengerController.PushReplyCustom(31, "Pay my outstanding balance",
                false, isFirst, this.m_messengerController.m_hasFocus);
        }

        if !subscribed {
            let basicRate: Int32 = IsDefined(settings) ? settings.amenitiesBasicDailyRate : 200;
            let premiumRate: Int32 = IsDefined(settings) ? settings.amenitiesPremiumDailyRate : 500;
            this.m_messengerController.PushReplyCustom(32,
                "Subscribe to Basic Plan (" + ToString(basicRate) + " €$/day)",
                false, isFirst, this.m_messengerController.m_hasFocus);
            this.m_messengerController.PushReplyCustom(33,
                "Subscribe to Premium Plan (" + ToString(premiumRate) + " €$/day)",
                false, isFirst, this.m_messengerController.m_hasFocus);
        } else {
            // v2.1.1: only "Pre-pay 1 cycle" is exposed in the menu — three
            // options (1/4/12) was visual clutter per user feedback. The
            // underlying CalculatePrepayCost / ApplyPrepayment API still
            // accepts arbitrary period counts, so a power user can prepay
            // bigger chunks via CET console or by hitting this option
            // multiple times. Cost shown inline so the player can compare
            // to their wallet at a glance.
            if IsDefined(settings) && IsDefined(state) {
                let cost1: Int32 = state.CalculatePrepayCost(settings, 1);
                this.m_messengerController.PushReplyCustom(37,
                    "Pre-pay 1 cycle (" + ToString(cost1) + " €$)",
                    false, isFirst, this.m_messengerController.m_hasFocus);
            }

            // Offer upgrade/downgrade (only if no debt — prevent gaming)
            if !hasDebt {
                if tier == 1 {
                    let premiumRate: Int32 = IsDefined(settings) ? settings.amenitiesPremiumDailyRate : 500;
                    this.m_messengerController.PushReplyCustom(34,
                        "Upgrade to Premium Plan (" + ToString(premiumRate) + " €$/day)",
                        false, isFirst, this.m_messengerController.m_hasFocus);
                } else {
                    let basicRate: Int32 = IsDefined(settings) ? settings.amenitiesBasicDailyRate : 200;
                    this.m_messengerController.PushReplyCustom(35,
                        "Downgrade to Basic Plan (" + ToString(basicRate) + " €$/day)",
                        false, isFirst, this.m_messengerController.m_hasFocus);
                }
                this.m_messengerController.PushReplyCustom(36, "Cancel my contract",
                    false, isFirst, this.m_messengerController.m_hasFocus);
            }
        }

        this.m_messengerController.PushReplyCustom(39, "Goodbye",
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
            case 30:
                ctrl.PushMessageCustom("What's my account status?",
                    MessageViewType.Sent, "V", false);
                this.PushDelayedReply(NCFBuildAmenitiesStatusBody(state, settings), 1.0);
                this.RenderMainMenu();
                return;
            case 31:
                ctrl.PushMessageCustom("Pay my outstanding balance",
                    MessageViewType.Sent, "V", false);
                this.HandlePayBill(state, settings);
                return;
            case 32:
                ctrl.PushMessageCustom("Subscribe to Basic Plan (" + ToString(settings.amenitiesBasicDailyRate) + " €$/day)",
                    MessageViewType.Sent, "V", false);
                this.HandleSubscribe(state, settings, 1);
                return;
            case 33:
                ctrl.PushMessageCustom("Subscribe to Premium Plan (" + ToString(settings.amenitiesPremiumDailyRate) + " €$/day)",
                    MessageViewType.Sent, "V", false);
                this.HandleSubscribe(state, settings, 2);
                return;
            case 34:
                ctrl.PushMessageCustom("Upgrade to Premium Plan (" + ToString(settings.amenitiesPremiumDailyRate) + " €$/day)",
                    MessageViewType.Sent, "V", false);
                this.HandleChangeTier(state, settings, 2);
                return;
            case 35:
                ctrl.PushMessageCustom("Downgrade to Basic Plan (" + ToString(settings.amenitiesBasicDailyRate) + " €$/day)",
                    MessageViewType.Sent, "V", false);
                this.HandleChangeTier(state, settings, 1);
                return;
            case 36:
                ctrl.PushMessageCustom("Cancel my contract",
                    MessageViewType.Sent, "V", false);
                this.HandleCancel(state, settings);
                return;
            case 37:
                ctrl.PushMessageCustom("Pre-pay 1 cycle (" + ToString(state.CalculatePrepayCost(settings, 1)) + " €$)",
                    MessageViewType.Sent, "V", false);
                this.HandlePrepay(state, settings, 1);
                return;
            case 39:
                ctrl.PushMessageCustom("Goodbye",
                    MessageViewType.Sent, "V", false);
                ctrl.PushMessageCustom(
                    "Thank you for choosing NC Amenities Corp. Have a productive day, V.",
                    MessageViewType.Received, "NC Amenities Corp", false);
                return;
        }
    }

    // -----------------------------------------------------------------------
    // Handlers
    // -----------------------------------------------------------------------

    private func HandleSubscribe(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, tier: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if state.IsAmenitiesSubscribed() {
            this.PushDelayedReply(
                "Our records show you already have an active contract with NC Amenities Corp. "
                + "Please manage your existing plan through your account options.", 1.0);
            this.RenderMainMenu();
            return;
        }
        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.SubscribeAmenities(tier, currentDay);

        // Re-evaluate Aria registration: Premium subscribe → Aria appears,
        // Basic subscribe → no change. Without this, Aria would only appear
        // on the next phone open after subscribing.
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) { phoneSys.RefreshAIRegistration(); }

        let tierName: String = tier == 1 ? "Basic" : "Premium";
        let rate: Int32 = tier == 1 ? settings.amenitiesBasicDailyRate : settings.amenitiesPremiumDailyRate;
        let services: String = tier == 1
            ? "standard water, net access, heating, and electricity"
            : "unlimited water, priority net access, climate control, and full electricity including smart home features";

        let confirm: String = "Welcome to NC Amenities Corp, V.\n\n"
            + "Your " + tierName + " Plan is now active. You will have access to " + services + " "
            + "at your current residence, effective immediately.\n\n"
            + "Billing rate: " + ToString(rate) + " €$ per in-game day, added to your account each day. "
            + "Settle your balance by contacting us. A grace period of " + ToString(settings.amenitiesGracePeriod)
            + " day(s) applies before services are suspended for non-payment.\n\n"
            + "Thank you for choosing NC Amenities Corp.";
        let followUp: String = NCFBuildAmenitiesStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirm, followUp, 1.5);
        this.RenderMainMenu();
    }

    private func HandleChangeTier(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, newTier: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if !state.IsAmenitiesSubscribed() {
            this.PushDelayedReply("You don't currently have an active plan. Please subscribe first.", 0.8);
            this.RenderMainMenu();
            return;
        }
        if state.GetAmenitiesDebt() > 0 {
            this.PushDelayedReply(
                "Plan changes are not available while you have an outstanding balance. "
                + "Please settle your account first.", 1.0);
            this.RenderMainMenu();
            return;
        }
        let currentDay: Int32 = GetGameInstance().GetGameTime().Days();
        state.SubscribeAmenities(newTier, currentDay);   // SubscribeAmenities also resets grace

        // Re-evaluate Aria: upgrade Basic→Premium adds her, downgrade
        // Premium→Basic removes her.
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) { phoneSys.RefreshAIRegistration(); }

        let tierName: String = newTier == 1 ? "Basic" : "Premium";
        let rate: Int32 = newTier == 1 ? settings.amenitiesBasicDailyRate : settings.amenitiesPremiumDailyRate;
        let confirm: String = "Your plan has been updated to " + tierName + " (" + ToString(rate)
            + " €$/day), effective immediately. Thank you for your continued partnership with NC Amenities Corp.";
        let followUp: String = NCFBuildAmenitiesStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirm, followUp, 1.2);
        this.RenderMainMenu();
    }

    private func HandleCancel(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if !state.IsAmenitiesSubscribed() {
            this.PushDelayedReply("You don't have an active contract to cancel.", 0.8);
            this.RenderMainMenu();
            return;
        }
        if state.GetAmenitiesDebt() > 0 {
            this.PushDelayedReply(
                "Contract termination is not available while an outstanding balance exists. "
                + "Please clear your bill of " + ToString(state.GetAmenitiesDebt())
                + " €$ before requesting cancellation.", 1.0);
            this.RenderMainMenu();
            return;
        }
        state.UnsubscribeAmenities();

        // Cancellation removes Aria — she only exists for active Premium.
        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) { phoneSys.RefreshAIRegistration(); }

        let confirm: String = "Your contract with NC Amenities Corp has been terminated, effective immediately.\n\n"
            + "Please note: utility services at your current residence will remain active for 24 in-game hours "
            + "as a courtesy disconnection window. After that, all services will be suspended.\n\n"
            + "We're sorry to see you go, V. Should your circumstances change, we welcome you back any time.";
        this.PushDelayedReply(confirm, 1.5);
        this.RenderMainMenu();
    }

    private func HandlePayBill(state: ref<NCFFinanceState>, settings: ref<NCFSettings>) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let debt: Int32 = state.GetAmenitiesDebt();
        if debt <= 0 {
            this.PushDelayedReply(
                "Your account is fully up to date. There is nothing to pay at this time. "
                + "Thank you for staying current with NC Amenities Corp.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let main: ref<NCFMainSystem> = NCFMainSystem.Get();
        let walletBalance: Int32 = IsDefined(main) ? main.GetRealPlayerMoney() : NCF_GetPlayerMoney();
        if walletBalance < debt {
            this.PushDelayedReply(
                "We were unable to process your payment. Insufficient funds in your linked account ("
                + ToString(walletBalance) + " €$ available, "
                + ToString(debt) + " €$ required).\n\n"
                + "Please acquire the necessary funds and contact us again. "
                + "NC Amenities Corp appreciates your cooperation.", 1.2);
            this.RenderMainMenu();
            return;
        }
        NCF_RemovePlayerMoney(debt);
        state.PayAmenities(debt);

        let wasSuspended: Bool = state.IsAmenitiesSuspended();
        let confirm: String;
        if wasSuspended {
            confirm = "Payment of " + ToString(debt) + " €$ received. Thank you, V.\n\n"
                + "Your services have been RESTORED. Water, net, heating, and electricity "
                + "at your current residence are now active. NC Amenities Corp apologizes for "
                + "any disruption and thanks you for resolving the outstanding balance.";
        } else {
            confirm = "Payment of " + ToString(debt) + " €$ received. Your account is now fully settled. "
                + "Thank you for your prompt payment, V.";
        }
        let followUp: String = NCFBuildAmenitiesStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirm, followUp, 1.0);
        this.RenderMainMenu();
    }

    // v2.1: pre-pay N billing cycles. Each cycle is `amenitiesBillingPeriodDays`
    // long; total cost = N * period * dailyRate. Cost is deducted immediately
    // from the wallet (uses real money, not credit-line — same as bill payment).
    // Prepaid days persist across save/load and offset future bill days
    // one full cycle at a time (partial prepay forfeits, see BillAmenitiesDaily).
    private func HandlePrepay(state: ref<NCFFinanceState>, settings: ref<NCFSettings>, periodCount: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        if !state.IsAmenitiesSubscribed() {
            this.PushDelayedReply(
                "Pre-payment requires an active contract. Please subscribe to a plan first.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let cost: Int32 = state.CalculatePrepayCost(settings, periodCount);
        if cost <= 0 {
            this.PushDelayedReply("Pre-payment cost calculation failed. Please try again.", 0.8);
            this.RenderMainMenu();
            return;
        }
        let main: ref<NCFMainSystem> = NCFMainSystem.Get();
        let wallet: Int32 = IsDefined(main) ? main.GetRealPlayerMoney() : NCF_GetPlayerMoney();
        if wallet < cost {
            this.PushDelayedReply(
                "We were unable to process your pre-payment. Insufficient funds in your linked account ("
                + ToString(wallet) + " €$ available, "
                + ToString(cost) + " €$ required).\n\n"
                + "Pre-paid amounts are non-refundable and apply only to FUTURE billing cycles. "
                + "Please acquire the necessary funds and contact us again.", 1.2);
            this.RenderMainMenu();
            return;
        }
        NCF_RemovePlayerMoney(cost);
        state.ApplyPrepayment(settings, periodCount);

        let period: Int32 = settings.amenitiesBillingPeriodDays;
        if period < 1 { period = 1; }
        let coveredDays: Int32 = periodCount * period;
        let cycleWord: String = periodCount == 1 ? "cycle" : "cycles";
        let confirm: String = "Pre-payment of " + ToString(cost) + " €$ received. Thank you, V.\n\n"
            + "Your account has been credited for " + ToString(periodCount) + " billing " + cycleWord
            + " (" + ToString(coveredDays) + " in-game days). "
            + "Future bills will be automatically applied against this credit until exhausted. "
            + "Pre-paid balances are non-refundable but never expire.\n\n"
            + "NC Amenities Corp appreciates your prompt cooperation.";
        let followUp: String = NCFBuildAmenitiesStatusBody(state, settings);
        this.PushDelayedReplyWithFollowUp(confirm, followUp, 1.2);
        this.RenderMainMenu();
    }

    // -----------------------------------------------------------------------
    // Typing animation helpers (mirrors Bank + Loan Shark pattern)
    // -----------------------------------------------------------------------

    private func PushDelayedReply(text: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom("NC Amenities Corp");
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
        this.m_messengerController.PlayDotsAnimationCustom("NC Amenities Corp");
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
                MessageViewType.Received, "NC Amenities Corp", true);
            if StrLen(this.m_pendingFollowUp) > 0 {
                ctrl.PlayDotsAnimationCustom("NC Amenities Corp");
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
            MessageViewType.Received, "NC Amenities Corp", false);
        this.m_pendingFollowUp = "";
    }
}
