module NightlyNow.Holo

// -----------------------------------------------------------------------------
// HoloHook - NightlyNow Core
// -----------------------------------------------------------------------------
// Original idea and concept by r457 & gh057.
// Bugfixes by DigitalVixen.
// Additional features and further bugfixes by NightlyNow.
// This is an ongoing effort mostly maintained by NightlyNow at this point.
public struct DialogEntry {
    public let content: String;
    public let viewType: MessageViewType;
    public let isQuest: Bool;
}

// ===== Contact handler =====
// Base class for modded holo contacts
public class ContactHandler extends IScriptable {
    // Override in subclass with a unique integer
    public func GetHash() -> Int32 {
        return 45705700;
    }

    // If true, contact will always be at top of the list
    public func AlwaysTop() -> Bool = false;

    // Override to provide contact metadata
    public func CreateContactData(forMessages: Bool) -> ref<ContactData> {
        let data = new ContactData();
        data.hash = this.GetHash();
        data.localizedName = s"Empty Contact";
        data.contactId = s"DefaultEmptyContact";
        data.id = s"DEFEMPTCNT";
        data.avatarID = t"PhoneAvatars.Avatar_Unknown";
        data.questRelated = true;
        data.isCallable = false;
        if forMessages {
            data.type = MessengerContactType.SingleThread;
            data.lastMesssagePreview = s"Empty Preview";
        } else {
            data.type = MessengerContactType.Contact;
        }
        data.messagesCount = 1;
        data.hasMessages = true;
        data.playerIsLastSender = false;
        return data;
    }

    // Override to populate the messenger dialog
    public func OnDialogOpen(messenger: wref<MessengerDialogViewController>) -> Bool {
        return false;
    }

    // Override to handle player choosing a reply option
    public func OnReplySelected(replyId: Int32) {
    }

    // Schedule a delayed typing animation callback
    public func QueueTypingDelay(delaySystem: wref<DelaySystem>, seconds: Float, replyId: Int32) {
        delaySystem.DelayCallback(TypingDelayTrigger.Create(this, replyId), seconds, false);
    }

    // Override to handle the end of typing animation
    public func OnTypingFinished(replyId: Int32) {
    }

    public func HasPendingMessages() -> Bool {
        let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
        if !IsDefined(holoSystem) {
            return false;
        }
        return holoSystem.HasPendingMessages(this.GetHash());
    }

    public func SetRead() {
        let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
        if !IsDefined(holoSystem) {
            return;
        }
        holoSystem.MarkContactRead(this.GetHash());
    }

    public func SetUnread() {
        let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
        if !IsDefined(holoSystem) {
            return;
        }
        holoSystem.MarkContactUnread(this.GetHash());
    }
}

// Fires after a typing delay expires
public class TypingDelayTrigger extends DelayCallback {
    let handler: wref<ContactHandler>;
    let replyId: Int32;

    public static func Create(handler: ref<ContactHandler>, replyId: Int32) -> ref<TypingDelayTrigger> {
        let trigger = new TypingDelayTrigger();
        trigger.handler = handler;
        trigger.replyId = replyId;
        return trigger;
    }

    public func Call() {
        this.handler.OnTypingFinished(this.replyId);
    }
}

// Extends journal notification to carry modded contact info
public class NotificationPayload extends JournalNotificationData {
    public let contactHash: Int32;
    public let isCallable: Bool;
}

// Inject a field onto UsePhoneRequest to pass modded contact hash
@addField(UsePhoneRequest)
public let hash: Int32;

// Marks contact data created by a modded handler
@addField(ContactData)
public let isModdedHoloContact: Bool;

// Opens a modded sms thread when notification is tapped
public class SmsOpenAction extends OpenPhoneMessageAction {
    public let targetHash: Int32;
    public let targetReplyId: Int32;

    public func Execute(data: ref<IScriptable>) -> Bool {
        let request = new UsePhoneRequest();
        request.hash = this.targetHash;
        this.m_phoneSystem.QueueRequest(request);
        return true;
    }
}

// ===== System =====
// Singleton managing all modded phone contacts
public class HoloSystem extends ScriptableSystem {
    // Persisted set of contact hashes whose thread the player has read
    public persistent let readContactHashes: array<Int32>;
    public let selectedMessageIdx: Int32;
    private let holoHud: wref<NewHudPhoneGameController>;
    private let contacts: array<wref<ContactHandler>>;

    public static func Get(obj: ref<GameObject>) -> ref<HoloSystem> {
        let gi: GameInstance = obj.GetGame();
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"NightlyNow.Holo.HoloSystem") as HoloSystem;
    }

    public func Setup(holoHud: ref<NewHudPhoneGameController>) {
        this.holoHud = holoHud;
    }

    public func Teardown() {
        this.holoHud = null;
    }

    // Register a contact handler
    public func AddContact(handler: ref<ContactHandler>) {
        if IsDefined(handler) {
            ArrayPush(this.contacts, handler);
        }
    }

    // Remove a contact handler
    public func RemoveContact(handler: ref<ContactHandler>) {
        if IsDefined(handler) && ArrayContains(this.contacts, handler) {
            ArrayRemove(this.contacts, handler);
        }
    }

    // Pending = unread = not yet in the read set
    public func HasPendingMessages(hash: Int32) -> Bool = !ArrayContains(this.readContactHashes, hash);

    // Mark a contact thread as read, it be persisted
    public func MarkContactRead(hash: Int32) {
        if !ArrayContains(this.readContactHashes, hash) {
            ArrayPush(this.readContactHashes, hash);
        }
    }

    // Mark a contact thread as unread, e.g. on a new push
    public func MarkContactUnread(hash: Int32) {
        ArrayRemove(this.readContactHashes, hash);
    }

    public func ApplyReadStateToContactData(contactData: ref<ContactData>) -> Bool {
        let wasUnread = ArraySize(contactData.unreadMessages) > 0 || contactData.playerCanReply;
        contactData.unreadMessegeCount = 0;
        ArrayClear(contactData.unreadMessages);
        if contactData.questRelated || this.HasPendingMessages(contactData.hash) {
            return false;
        }
        contactData.playerCanReply = false;
        contactData.hasQuestImportantReply = false;
        return wasUnread;
    }

    // Check if a hash belongs to a modded contact
    public func IsContact(hash: Int32) -> Bool {
        for handler in this.contacts {
            if handler.GetHash() == hash {
                return true;
            }
        }
        return false;
    }

    // Gather contact data from all registered handlers
    public func CreateAllContactData(forMessages: Bool) -> array<ref<ContactData>> {
        let result: array<ref<ContactData>>;
        for handler in this.contacts {
            let cd = handler.CreateContactData(forMessages);
            if IsDefined(cd) {
                ArrayPush(result, cd);
            }
        }
        return result;
    }

    // Find contact data by hash
    public func FindContactData(hash: Int32, forMessages: Bool) -> ref<ContactData> {
        for handler in this.contacts {
            if handler.GetHash() == hash {
                return handler.CreateContactData(forMessages);
            }
        }
        let empty: ref<ContactData>;
        return empty;
    }

    // Inject modded contacts into vanilla contact list
    public func InjectContacts(vanillaList: array<ref<IScriptable>>, forMessages: Bool) -> array<ref<IScriptable>> {
        for handler in this.contacts {
            let cd = handler.CreateContactData(forMessages);
            if IsDefined(cd) {
                cd.isModdedHoloContact = true;
                let isQuest = cd.questRelated;
                let isPending = this.HasPendingMessages(handler.GetHash());

                // In Messages, only quest or unread contacts are shown
                if !forMessages || isQuest || isPending {
                    // Render read, non-quest contacts as read (no unread badge)
                    if !isQuest && !isPending {
                        cd.unreadMessegeCount = 0;
                        ArrayClear(cd.unreadMessages);
                        cd.playerCanReply = false;
                        cd.hasQuestImportantReply = false;
                    }

                    // Pinned or unread contacts float to the top
                    if handler.AlwaysTop() || isPending {
                        ArrayInsert(vanillaList, 0, cd);
                    } else {
                        ArrayPush(vanillaList, cd);
                    }
                }
            }
        }
        return vanillaList;
    }

    // Create a single-entry thread list for the messages submenu
    public func CreateMessageThreads(hash: Int32) -> array<ref<IScriptable>> {
        let threadList: array<ref<IScriptable>>;
        let cd = this.FindContactData(hash, true);
        ArrayInsert(threadList, 0, cd);
        return threadList;
    }

    // Attempt to show a modded dialog for the given messenger view
    public func TryShowDialog(messenger: wref<MessengerDialogViewController>) -> Bool {
        for handler in this.contacts {
            if handler.GetHash() == messenger.m_contactHash {
                let shown = handler.OnDialogOpen(messenger);
                this.MarkContactRead(handler.GetHash());
                return shown;
            }
        }
        return false;
    }

    // Forward a reply selection to the matching contact handler
    public func ForwardReply(hash: Int32, replyId: Int32) {
        for handler in this.contacts {
            if handler.GetHash() == hash {
                handler.OnReplySelected(replyId);
            }
        }
    }

    // Mark contact as unread and push a HUD sms notification
    public func SendPushNotification(hash: Int32, title: String, preview: String) {
        this.MarkContactUnread(hash);
        this.holoHud.DisplayPushNotification(hash, title, preview);
    }

    // Refresh phone contacts
    public func RefreshPhoneContacts() {
        if IsDefined(this.holoHud) {
            this.holoHud.HoloRefreshContacts();
        }
    }
}

// Lifecycle hooks for the modded phone system
@addField(NewHudPhoneGameController)
private let holoSystem: ref<HoloSystem>;

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    this.holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(this.holoSystem) {
        return ret;
    }
    this.holoSystem.Setup(this);
    return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    this.holoSystem.Teardown();
    return ret;
}

@addMethod(NewHudPhoneGameController)
public func HoloRefreshContacts() {
    if !IsDefined(this.m_contactListLogicController) {
        return;
    }
    this.SetScreenType(this.m_screenType);
}

// ===== Vanilla method hooks =====
// Resolve player object from HUD layer
public func ResolvePlayerFromHud() -> ref<GameObject> {
    let inkSystem = GameInstance.GetInkSystem();
    let hud = inkSystem.GetLayer(n"inkHUDLayer").GetGameController() as inkGameController;
    return hud.GetPlayerControlledObject();
}

// Inject modded contacts into the contacts tab
@wrapMethod(JournalManager)
public final func GetContactDataArray(includeUnknown: Bool, includeNonCallable: Bool) -> array<ref<IScriptable>> {
    let vanillaList = wrappedMethod(includeUnknown, includeNonCallable);
    let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
    if !IsDefined(holoSystem) {
        return vanillaList;
    }
    return holoSystem.InjectContacts(vanillaList, false);
}

// Rank modded contacts alongside callable ones so they sort in by name
@replaceMethod(DialerContactDataView)
private final func SortByName(leftData: wref<ContactData>, rightData: wref<ContactData>) -> Bool {
    return this
        .m_compareBuilder
        .BoolTrue(leftData.questRelated, rightData.questRelated)
        .BoolTrue(leftData.hasQuestImportantReply, rightData.hasQuestImportantReply)
        .BoolTrue(
            leftData.isCallable || leftData.isModdedHoloContact,
            rightData.isCallable || rightData.isModdedHoloContact
        )
        .UnicodeStringAsc(
            GetLocalizedText(leftData.localizedName),
            GetLocalizedText(rightData.localizedName)
        )
        .GetBool();
}

// Inject modded contacts into the messages tab
@wrapMethod(MessengerUtils)
public final static func GetSimpleContactDataArray(
    journal: ref<JournalManager>,
    includeUnknown: Bool,
    skipEmpty: Bool,
    includeWithNoUnread: Bool,
    opt activeDataSync: wref<MessengerContactSyncData>
) -> array<ref<IScriptable>> {
    let vanillaList = wrappedMethod(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync);
    let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
    if !IsDefined(holoSystem) {
        return vanillaList;
    }
    return holoSystem.InjectContacts(vanillaList, true);
}

// Intercept message thread data for modded contacts
@wrapMethod(MessengerUtils)
public final static func GetMessageDataArrayForContact(
    journal: ref<JournalManager>,
    concactHash: Int32,
    includeUnknown: Bool,
    skipEmpty: Bool,
    opt activeDataSync: wref<MessengerContactSyncData>
) -> array<ref<IScriptable>> {
    let holoSystem = HoloSystem.Get(ResolvePlayerFromHud());
    if !IsDefined(holoSystem) {
        return wrappedMethod(journal, concactHash, includeUnknown, skipEmpty, activeDataSync);
    }
    if holoSystem.IsContact(concactHash) {
        return holoSystem.CreateMessageThreads(concactHash);
    }
    return wrappedMethod(journal, concactHash, includeUnknown, skipEmpty, activeDataSync);
}

// Route modded contacts to custom sms messenger flow
@wrapMethod(NewHudPhoneGameController)
public final func GotoSmsMessenger(contactData: wref<ContactData>) {
    let holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(holoSystem) {
        wrappedMethod(contactData);
        return;
    }
    if holoSystem.IsContact(contactData.hash) {
        let evt = new OpenSmsMessengerEvent();
        let payload = new NotificationPayload();
        payload.type = contactData.type;
        payload.contactNameLocKey = StringToName(contactData.localizedName);
        payload.mode = JournalNotificationMode.HUD;
        payload.openedFromPhone = true;
        payload.source = this.m_screenType;
        payload.contactHash = contactData.hash;
        payload.isCallable = contactData.isCallable;
        evt.m_data = payload;
        this.QueueEvent(evt);
    } else {
        wrappedMethod(contactData);
    }
}

// Route modded contacts during messenger refresh
@wrapMethod(NewHudPhoneGameController)
public final func RefreshSmsMessager(contactData: wref<ContactData>) {
    let holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(holoSystem) {
        wrappedMethod(contactData);
        return;
    }
    if holoSystem.IsContact(contactData.hash) {
        let evt = new RefreshSmsMessagerEvent();
        let payload = new NotificationPayload();
        payload.type = contactData.type;
        payload.contactNameLocKey = StringToName(contactData.localizedName);
        payload.mode = JournalNotificationMode.HUD;
        payload.openedFromPhone = true;
        payload.source = this.m_screenType;
        payload.contactHash = contactData.hash;
        payload.isCallable = contactData.isCallable;
        evt.m_data = payload;
        this.QueueEvent(evt);
    } else {
        wrappedMethod(contactData);
    }
}

@wrapMethod(NewHudPhoneGameController)
public final func RefreshReplies(contactData: ref<ContactData>) -> Bool {
    let holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(holoSystem) || !holoSystem.IsContact(contactData.hash) {
        return wrappedMethod(contactData);
    }
    return holoSystem.ApplyReadStateToContactData(contactData);
}

// ===== Contacts tab read state =====
@addMethod(PhoneContactItemVirtualController)
private final func IsModdedHoloContactItem(contactData: wref<ContactData>) -> Bool = IsDefined(contactData)
    && contactData.isModdedHoloContact
    && Equals(contactData.type, MessengerContactType.Contact);

@wrapMethod(PhoneContactItemVirtualController)
protected cb func OnDataChanged(value: Variant) -> Bool {
    let contactData = FromVariant<ref<IScriptable>>(value) as ContactData;
    if !this.IsModdedHoloContactItem(contactData) {
        return wrappedMethod(value);
    }
    contactData.type = MessengerContactType.SingleThread;
    let result = wrappedMethod(value);
    contactData.type = MessengerContactType.Contact;
    return result;
}

@wrapMethod(PhoneContactItemVirtualController)
protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    if !this.IsModdedHoloContactItem(this.m_contactData) {
        return wrappedMethod(itemController, discreteNav);
    }
    this.m_contactData.type = MessengerContactType.SingleThread;
    let result = wrappedMethod(itemController, discreteNav);
    this.m_contactData.type = MessengerContactType.Contact;
    return result;
}

@wrapMethod(PhoneContactItemVirtualController)
protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    if !this.IsModdedHoloContactItem(this.m_contactData) {
        return wrappedMethod(itemController);
    }
    this.m_contactData.type = MessengerContactType.SingleThread;
    let result = wrappedMethod(itemController);
    this.m_contactData.type = MessengerContactType.Contact;
    return result;
}

// ===== Dialog view hooks =====
// Open a modded dialog in the messenger
@addMethod(MessengerDialogViewController)
public final func OpenDialog(hash: Int32) {
    this.m_contactHash = hash;
    this.m_singleThreadMode = true;
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.UpdateData(false, true);
}

// Intercept UpdateData to show modded dialog when applicable
@wrapMethod(MessengerDialogViewController)
public final func UpdateData(animateLastMessage: Bool, setVisited: Bool) {
    let holoSystem = HoloSystem.Get(this.m_playerObject);
    if !IsDefined(holoSystem) {
        wrappedMethod(animateLastMessage, setVisited);
        return;
    }
    if !holoSystem.TryShowDialog(this) {
        wrappedMethod(animateLastMessage, setVisited);
    }
}

// Tear down the modded dialog view
@addMethod(MessengerDialogViewController)
public final func CloseDialog() {
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.m_messagesListController.Clear();
    this.m_choicesListController.Clear();
    inkCompoundRef.RemoveAllChildren(this.m_messagesList);
    inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

// Handle focus changes for modded contacts
@wrapMethod(PhoneMessagePopupGameController)
private final func SetFocus(isFocused: Bool) {
    let holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(holoSystem) {
        wrappedMethod(isFocused);
        return;
    }
    if NotEquals(this.m_isFocused, isFocused) {
        let payload = this.m_data as NotificationPayload;
        if IsDefined(payload) && holoSystem.IsContact(payload.contactHash) {
            if !isFocused {
                this.m_dialogViewController.CloseDialog();
            } else {
                this.m_dialogViewController.OpenDialog(payload.contactHash);
                inkWidgetRef.SetVisible(this.m_hintCall, payload.isCallable);
            }
        }
    }
    wrappedMethod(isFocused);
}

@wrapMethod(PhoneMessagePopupGameController)
private final func ClosePopup() {
    wrappedMethod();

    // This takes care of game fucking up by opening the phone on the very same contact that sent push notif until next load
    // bb caches it
    GameInstance
        .GetBlackboardSystem(GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_ComDevice)
        .SetInt(GetAllBlackboardDefs().UI_ComDevice.MessageToOpenHash, 0, true);
}

// ===== Message & reply methods =====
// Spawn a message bubble in the dialog
@addMethod(MessengerDialogViewController)
public func AddMessage(text: String, msgType: MessageViewType, sender: String, withSound: Bool) {
    let widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_messagesList), n"Message");
    let renderer = widget.GetControllerByType(n"MessangerItemRenderer") as MessangerItemRenderer;
    renderer.SetMessageView(text, msgType, sender);
    if withSound {
        this
            .PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Left);
        this.m_audioSystem.Play(n"ui_messenger_recieved");
    }
}

// Spawn a reply option in the dialog
@addMethod(MessengerDialogViewController)
public func AddReply(replyId: Int32, text: String, isQuestReply: Bool, selected: Bool, focused: Bool) {
    let widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_choicesList), n"Reply");
    let renderer = widget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
    renderer.ApplyReply(replyId, text, isQuestReply, selected, focused);
}

// Remove all reply options
@addMethod(MessengerDialogViewController)
public func ClearReplies() {
    inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

// Remove all messages
@addMethod(MessengerDialogViewController)
public func ClearMessages() {
    inkCompoundRef.RemoveAllChildren(this.m_messagesList);
}

// Show typing dots with a sender name
@addMethod(MessengerDialogViewController)
public func ShowTypingDots(sender: String) {
    this.m_typingIndicatorController.SetName(sender);
    this.PlayDotsAnimation();
}

// ===== Reply navigation =====
// Intercept reply navigation for modded contacts
@wrapMethod(MessengerDialogViewController)
public final func NavigateReplyOptions(isUp: Bool) {
    let holoSystem = HoloSystem.Get(this.m_playerObject);
    if !IsDefined(holoSystem) {
        wrappedMethod(isUp);
        return;
    }
    if holoSystem.IsContact(this.m_contactHash) {
        this.m_choicesListController.NavigateList(isUp);
    } else {
        wrappedMethod(isUp);
    }
}

// Move selection up/down in modded reply list
@addMethod(JournalEntriesListController)
public func NavigateList(isUp: Bool) {
    let root = this.GetRootCompoundWidget();
    let count = root.GetNumChildren();
    let current = this.GetSelectedIndex();
    if current < 0 {
        return;
    }

    let next = Clamp(current + (isUp ? -1 : 1), 0, count - 1);
    if next != current {
        let oldWidget = root.GetWidgetByIndex(current);
        let oldRenderer = oldWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
        oldRenderer.SetSelected(false);
        let newWidget = root.GetWidgetByIndex(next);
        let newRenderer = newWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
        newRenderer.SetSelected(true);
    }
}

// Find which reply option is currently selected
@addMethod(JournalEntriesListController)
public func GetSelectedIndex() -> Int32 {
    let root = this.GetRootCompoundWidget();
    let count = root.GetNumChildren();
    let i: Int32 = 0;
    while i < count {
        let widget = root.GetWidgetByIndex(i);
        let renderer = widget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
        if IsDefined(renderer) && renderer.m_selectedState {
            return i;
        }
        i += 1;
    }
    return -1;
}

// Intercept reply activation for modded contacts
@wrapMethod(PhoneMessagePopupGameController)
private final func TryActivateChoice() {
    if !this.m_phoneSystem.IsTextingEnabled() {
        this.ShowActionBlockedNotification();
        return;
    }
    let holoSystem = HoloSystem.Get(this.GetPlayerControlledObject());
    if !IsDefined(holoSystem) {
        wrappedMethod();
        return;
    }
    let payload = this.m_data as NotificationPayload;
    if IsDefined(payload) && holoSystem.IsContact(payload.contactHash) {
        this.m_dialogViewController.TriggerSelectedReply();
    } else {
        wrappedMethod();
    }
}

// Find selected reply and forward it to the system
@addMethod(MessengerDialogViewController)
public final func TriggerSelectedReply() {
    if inkCompoundRef.GetNumChildren(this.m_choicesList) <= 0 {
        return;
    }
    let idx = this.m_choicesListController.GetSelectedIndex();
    if idx < 0 {
        return;
    }
    let widget = inkCompoundRef.GetWidgetByIndex(this.m_choicesList, idx);
    let renderer = widget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
    if IsDefined(renderer) {
        let holoSystem = HoloSystem.Get(this.m_playerObject);
        if !IsDefined(holoSystem) {
            return;
        }
        holoSystem.ForwardReply(this.m_contactHash, renderer.replyId);
        this.m_audioSystem.Play(n"ui_messenger_select");
        this
            .PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
    }
}

// ===== Reply renderer extensions =====
// Stores the modded reply ID on each reply widget
@addField(MessangerReplyItemRenderer)
public let replyId: Int32;

// Configure a reply widget for modded use
@addMethod(MessangerReplyItemRenderer)
public func ApplyReply(replyId: Int32, label: String, isQuestReply: Bool, selected: Bool, active: Bool) {
    inkTextRef.SetText(this.m_labelPathRef, label);
    this.replyId = replyId;
    this.m_isQuestImportant = isQuestReply;
    this.m_selectedState = selected;
    this.m_isActive = active;
    this.AnimateSelection();
}

// Toggle selection state on a modded reply widget
@addMethod(MessangerReplyItemRenderer)
public func SetSelected(selected: Bool) {
    this.m_selectedState = selected;
    this.AnimateSelection();
}

// ===== Scroll hint fix =====
// Sync scroll hint visibility after data setup
@wrapMethod(PhoneMessagePopupGameController)
private final func SetupData() {
    wrappedMethod();
    inkWidgetRef
        .SetVisible(
            this.m_scrollReply,
            this.m_player.PlayerLastUsedKBM() && inkWidgetRef.IsVisible(this.m_scrollSlider)
        );
}

// Sync scroll hint visibility after input actions
@wrapMethod(PhoneMessagePopupGameController)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    wrappedMethod(action, consumer);
    inkWidgetRef
        .SetVisible(
            this.m_scrollReply,
            this.m_player.PlayerLastUsedKBM() && inkWidgetRef.IsVisible(this.m_scrollSlider)
        );
}

// ===== SMS notification =====
// Display an incoming sms HUD notification for a modded contact
@addMethod(NewHudPhoneGameController)
public func DisplayPushNotification(hash: Int32, title: String, preview: String) {
    let openAction = new SmsOpenAction();
    openAction.m_phoneSystem = this.m_PhoneSystem;
    openAction.targetHash = hash;

    let viewData = new PhoneMessageNotificationViewData();
    viewData.contactHash = hash;
    viewData.title = title;
    viewData.SMSText = preview;
    viewData.action = openAction;
    viewData.animation = n"notification_phone_MSG";
    viewData.soundEvent = n"PhoneSmsPopup";
    viewData.soundAction = n"OnOpen";

    let notification: gameuiGenericNotificationData;
    notification.time = 6.7;
    notification.widgetLibraryItemName = n"notification_message";
    notification.notificationData = viewData;
    this.AddNewNotificationData(notification);
}

// Intercept phone open request for modded contacts
@wrapMethod(PhoneSystem)
private final func OnUsePhone(request: ref<UsePhoneRequest>) {
    let player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
    let holoSystem = HoloSystem.Get(player);
    if !IsDefined(holoSystem) {
        wrappedMethod(request);
        return;
    }
    if holoSystem.IsContact(request.hash) {
        // Skip if phone is already open
        if this.IsPhoneOpened() {
            return;
        }
        // Show blocked notification if phone is disabled
        if !this.IsPhoneEnabled() {
            GameInstance
                .GetUISystem(player.GetGame())
                .QueueEvent(new UIInGameNotificationRemoveEvent());
            let blocked = new UIInGameNotificationEvent();
            blocked.m_notificationType = UIInGameNotificationType.CombatRestriction;
            GameInstance.GetUISystem(player.GetGame()).QueueEvent(blocked);
            return;
        }
        // Open messenger to this contact
        if !this.m_ContactsOpen {
            this
                .m_Blackboard
                .SetInt(
                    GetAllBlackboardDefs().UI_ComDevice.MessageToOpenHash,
                    request.hash,
                    true
                );
            this.ToggleContacts(true);
            return;
        }
    } else {
        wrappedMethod(request);
    }
}

