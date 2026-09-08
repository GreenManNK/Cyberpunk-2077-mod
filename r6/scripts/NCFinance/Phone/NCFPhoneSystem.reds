// -----------------------------------------------------------------------------
// NCFPhoneSystem, strong-ref holder + Phone Extension registration
// -----------------------------------------------------------------------------
//
// Critical KB lessons baked in:
//
// 1. ScriptableSystem uses OnAttach (NOT OnLoad, that's ScriptableService).
//    Fields stay null forever if you use OnLoad here. The compiler accepts
//    the wrong hook with no error; the engine silently never calls it.
//
// 2. PhoneExtensionSystem.m_listeners is an array of WREFs. If we don't
//    hold strong refs ourselves, our listeners get garbage-collected
//    before they're ever used. This system's persistent strong fields
//    are the canonical solution.
//
// 3. Registration must happen AFTER PhoneExtensionSystem.Init has run.
//    Phone Extension itself wraps NewHudPhoneGameController.OnInitialize
//    to call its own Init; multiple @wrapMethod decorators chain via
//    wrappedMethod() → our wrap runs after PE's init.
//
// 4. OnInitialize fires every time V opens the phone. m_bankRegistered
//    and m_loanSharkRegistered guard against double-registration per
//    contact, and let RegisterAll re-evaluate settings on every phone
//    open so toggling Bank/Loan Shark in Mod Settings takes effect on
//    the next session.

module NightCityFinance.Phone

import PhoneExtension.Classes.*
import PhoneExtension.System.*

import NightCityFinance.Core.*
import NightCityFinance.Settings.*

public class NCFPhoneSystem extends ScriptableSystem {
    private let m_bankListener: ref<NCFBankListener>;
    private let m_loanSharkListener: ref<NCFLoanSharkListener>;
    private let m_amenitiesListener: ref<NCFAmenitiesListener>;
    private let m_aiListener: ref<NCFPropertyAIListener>;
    private let m_bankRegistered: Bool;
    private let m_loanSharkRegistered: Bool;
    private let m_amenitiesRegistered: Bool;
    private let m_aiRegistered: Bool;
    private let m_phoneEverInitialized: Bool;

    private persistent let m_bankHasNewActivity: Bool;
    private persistent let m_loanSharkHasNewActivity: Bool;
    private persistent let m_amenitiesHasNewActivity: Bool;
    private persistent let m_aiHasNewActivity: Bool;

    private persistent let m_bankFirstSeenAcked: Bool;
    private persistent let m_loanSharkFirstSeenAcked: Bool;
    private persistent let m_amenitiesFirstSeenAcked: Bool;
    private persistent let m_aiFirstSeenAcked: Bool;

    // Aria per-question cooldown sentinels — store last-fire game-hour count
    // (GameTime.Hours() returns total elapsed hours, not hour-of-day).
    // Used to gate fresh-response vs deflection. Default 0 means "never fired",
    // and any current hour count > 0 is treated as cooldown-expired on first ask.
    private persistent let m_aiLastTipHour: Int32;
    private persistent let m_aiLastQuoteHour: Int32;
    private persistent let m_aiLastAboutHour: Int32;

    // Last notification text — session-only (String cannot be persistent).
    // Empty on fresh load; populated on first daily notification that fires.
    private let m_lastBankNotificationText: String;
    private let m_lastLoanSharkNotificationText: String;
    private let m_lastAmenitiesNotificationText: String;

    public static func Get() -> ref<NCFPhoneSystem> {
        let gi: GameInstance = GetGameInstance();
        let sys: ref<NCFPhoneSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"NightCityFinance.Phone.NCFPhoneSystem") as NCFPhoneSystem;
        return sys;
    }

    private func OnAttach() -> Void {
        this.m_bankListener = new NCFBankListener();
        this.m_loanSharkListener = new NCFLoanSharkListener();
        this.m_amenitiesListener = new NCFAmenitiesListener();
        this.m_aiListener = new NCFPropertyAIListener();
        this.m_bankRegistered = false;
        this.m_loanSharkRegistered = false;
        this.m_amenitiesRegistered = false;
        this.m_aiRegistered = false;
        this.m_phoneEverInitialized = false;
    }

    public func MarkPhoneInitialized() -> Void {
        this.m_phoneEverInitialized = true;
    }

    public func IsPhoneReady() -> Bool {
        return this.m_phoneEverInitialized;
    }

    public func HasBankActivity() -> Bool { return this.m_bankHasNewActivity; }
    public func HasLoanSharkActivity() -> Bool { return this.m_loanSharkHasNewActivity; }
    public func HasAmenitiesActivity() -> Bool { return this.m_amenitiesHasNewActivity; }
    public func HasAIActivity() -> Bool { return this.m_aiHasNewActivity; }
    public func MarkBankActivity() -> Void { this.m_bankHasNewActivity = true; }
    public func MarkLoanSharkActivity() -> Void { this.m_loanSharkHasNewActivity = true; }
    public func MarkAmenitiesActivity() -> Void { this.m_amenitiesHasNewActivity = true; }
    public func MarkAIActivity() -> Void { this.m_aiHasNewActivity = true; }
    public func ClearBankActivity() -> Void { this.m_bankHasNewActivity = false; }
    public func ClearLoanSharkActivity() -> Void { this.m_loanSharkHasNewActivity = false; }
    public func ClearAmenitiesActivity() -> Void { this.m_amenitiesHasNewActivity = false; }
    public func ClearAIActivity() -> Void { this.m_aiHasNewActivity = false; }

    public func IsBankFirstSeenPending() -> Bool { return !this.m_bankFirstSeenAcked; }
    public func IsLoanSharkFirstSeenPending() -> Bool { return !this.m_loanSharkFirstSeenAcked; }
    public func IsAmenitiesFirstSeenPending() -> Bool { return !this.m_amenitiesFirstSeenAcked; }
    public func IsAIFirstSeenPending() -> Bool { return !this.m_aiFirstSeenAcked; }
    public func AckBankFirstSeen() -> Void { this.m_bankFirstSeenAcked = true; }
    public func AckLoanSharkFirstSeen() -> Void { this.m_loanSharkFirstSeenAcked = true; }
    public func AckAmenitiesFirstSeen() -> Void { this.m_amenitiesFirstSeenAcked = true; }
    public func AckAIFirstSeen() -> Void { this.m_aiFirstSeenAcked = true; }

    // Aria cooldown accessors. Hour-of-fire is total elapsed game hours.
    public func GetAILastTipHour() -> Int32 { return this.m_aiLastTipHour; }
    public func GetAILastQuoteHour() -> Int32 { return this.m_aiLastQuoteHour; }
    public func GetAILastAboutHour() -> Int32 { return this.m_aiLastAboutHour; }
    public func SetAILastTipHour(h: Int32) -> Void { this.m_aiLastTipHour = h; }
    public func SetAILastQuoteHour(h: Int32) -> Void { this.m_aiLastQuoteHour = h; }
    public func SetAILastAboutHour(h: Int32) -> Void { this.m_aiLastAboutHour = h; }

    public func GetLastBankNotificationText() -> String { return this.m_lastBankNotificationText; }
    public func GetLastLoanSharkNotificationText() -> String { return this.m_lastLoanSharkNotificationText; }
    public func GetLastAmenitiesNotificationText() -> String { return this.m_lastAmenitiesNotificationText; }
    public func SetLastBankNotificationText(text: String) -> Void { this.m_lastBankNotificationText = text; }
    public func SetLastLoanSharkNotificationText(text: String) -> Void { this.m_lastLoanSharkNotificationText = text; }
    public func SetLastAmenitiesNotificationText(text: String) -> Void { this.m_lastAmenitiesNotificationText = text; }

    public func RegisterAll(phoneExt: ref<PhoneExtensionSystem>) -> Void {
        if !IsDefined(phoneExt) { return; }
        let settings: ref<NCFSettings> = NCFSettings.Get();
        let bankWanted: Bool = !IsDefined(settings) || settings.bankEnabled;
        let loanWanted: Bool = !IsDefined(settings) || settings.loanSharkEnabled;
        let amenitiesWanted: Bool = !IsDefined(settings) || settings.amenitiesEnabled;
        // Property AI is a Premium-only perk: register only when Amenities
        // is enabled AND the player has an active Premium subscription.
        let financeState: ref<NCFFinanceState> = NCFFinanceState.Get();
        let aiWanted: Bool = amenitiesWanted
            && IsDefined(financeState)
            && financeState.IsAmenitiesPremium();

        // Defensive lazy-init. If the system was attached before the AI
        // listener field existed (mid-session script reload, save migration
        // edge cases), m_aiListener may be null even though OnAttach was
        // expected to populate it. Build it on first need.
        if !IsDefined(this.m_aiListener) {
            this.m_aiListener = new NCFPropertyAIListener();
        }

        if IsDefined(this.m_bankListener) {
            if bankWanted && !this.m_bankRegistered {
                phoneExt.Register(this.m_bankListener);
                this.m_bankRegistered = true;
            } else if !bankWanted && this.m_bankRegistered {
                phoneExt.Unregister(this.m_bankListener);
                this.m_bankRegistered = false;
            }
        }
        if IsDefined(this.m_loanSharkListener) {
            if loanWanted && !this.m_loanSharkRegistered {
                phoneExt.Register(this.m_loanSharkListener);
                this.m_loanSharkRegistered = true;
            } else if !loanWanted && this.m_loanSharkRegistered {
                phoneExt.Unregister(this.m_loanSharkListener);
                this.m_loanSharkRegistered = false;
            }
        }
        if IsDefined(this.m_amenitiesListener) {
            if amenitiesWanted && !this.m_amenitiesRegistered {
                phoneExt.Register(this.m_amenitiesListener);
                this.m_amenitiesRegistered = true;
            } else if !amenitiesWanted && this.m_amenitiesRegistered {
                phoneExt.Unregister(this.m_amenitiesListener);
                this.m_amenitiesRegistered = false;
            }
        }
        if IsDefined(this.m_aiListener) {
            if aiWanted && !this.m_aiRegistered {
                phoneExt.Register(this.m_aiListener);
                this.m_aiRegistered = true;
            } else if !aiWanted && this.m_aiRegistered {
                phoneExt.Unregister(this.m_aiListener);
                this.m_aiRegistered = false;
            }
        }
    }

    // Re-evaluate Aria registration immediately. Called from the amenities
    // contact when V subscribes, upgrades, downgrades, or cancels — so the
    // contact appears/disappears without waiting for the next phone open.
    public func RefreshAIRegistration() -> Void {
        let player: ref<GameObject> = GetPlayerObjectGlobal();
        if !IsDefined(player) { return; }
        let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
        if !IsDefined(phoneExt) { return; }
        this.RegisterAll(phoneExt);
    }

    public func UnregisterAll(phoneExt: ref<PhoneExtensionSystem>) -> Void {
        if !IsDefined(phoneExt) { return; }
        if IsDefined(this.m_bankListener) && this.m_bankRegistered {
            phoneExt.Unregister(this.m_bankListener);
            this.m_bankRegistered = false;
        }
        if IsDefined(this.m_loanSharkListener) && this.m_loanSharkRegistered {
            phoneExt.Unregister(this.m_loanSharkListener);
            this.m_loanSharkRegistered = false;
        }
        if IsDefined(this.m_amenitiesListener) && this.m_amenitiesRegistered {
            phoneExt.Unregister(this.m_amenitiesListener);
            this.m_amenitiesRegistered = false;
        }
        if IsDefined(this.m_aiListener) && this.m_aiRegistered {
            phoneExt.Unregister(this.m_aiListener);
            this.m_aiRegistered = false;
        }
    }

    public func IsBankRegistered() -> Bool { return this.m_bankRegistered; }
    public func IsLoanSharkRegistered() -> Bool { return this.m_loanSharkRegistered; }
    public func IsAmenitiesRegistered() -> Bool { return this.m_amenitiesRegistered; }
    public func IsAIRegistered() -> Bool { return this.m_aiRegistered; }
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
    let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
    if IsDefined(phoneExt) && IsDefined(ncfPhone) {
        ncfPhone.RegisterAll(phoneExt);
        ncfPhone.MarkPhoneInitialized();
    }
    return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
    let phoneExt: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
    let ncfPhone: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
    if IsDefined(phoneExt) && IsDefined(ncfPhone) {
        ncfPhone.UnregisterAll(phoneExt);
    }
    return wrappedMethod();
}
