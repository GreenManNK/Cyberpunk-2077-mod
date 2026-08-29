module NightCityAllies.Phone.Hooks

import NightCityAllies.*
import NightCityAllies.Phone.*

// Insert custom contacts in the phone list (message list also counts as contact list but with different styling)
//@if(!ModuleExists("PhoneExtension.Classes")) // <- disabled so we just inject our own contact always
@wrapMethod(MessengerUtils)
public final static func GetSimpleContactDataArray(journal: ref<JournalManager>, includeUnknown: Bool, skipEmpty: Bool, includeWithNoUnread: Bool, opt activeDataSync: wref<MessengerContactSyncData>) -> array<ref<IScriptable>> {
    let contactDataArray: array<ref<IScriptable>> = wrappedMethod(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync);
    return NCA.Phone().OnGetContacts(contactDataArray); // Hook
}

// =============================== This stuff is for creating the sms view message history =============================
// Create a received message
@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func PushMessageCustom(messageText: String, messageType: MessageViewType, contactName: String, playSound: Bool) -> Void {
	let messageWidget = this.SpawnFromLocal(inkCompoundRef.Get(this.m_messagesList), n"Message");
	let messageRenderer = messageWidget.GetControllerByType(n"MessangerItemRenderer") as MessangerItemRenderer;
	messageRenderer.SetMessageView(messageText, messageType, contactName);
	if playSound {
		this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Left);
		this.m_audioSystem.Play(n"ui_messenger_recieved");
	};
}

// Create a sent message
@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func PushReplyCustom(messageText: String, isQuest: Bool, isSelected: Bool) -> Void {
	let replyWidget = this.SpawnFromLocal(inkCompoundRef.Get(this.m_choicesList), n"Reply");
	let replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
	replyRenderer.SetReplyViewCustom(messageText, isQuest, isSelected, this.m_hasFocus);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func ClearRepliesCustom() -> Void {
	inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessangerReplyItemRenderer)
public func SetReplyViewCustom(txt: String, isQuest: Bool, isSelected: Bool, isActive: Bool) -> Void {
	inkTextRef.SetText(this.m_labelPathRef, txt);
	this.m_isQuestImportant = isQuest;
	this.m_selectedState = isSelected;
	this.m_isActive = isActive;
	this.AnimateSelection();
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func PlayDotsAnimationCustom(senderName: String) -> Void {
	this.m_typingIndicatorController.SetName(senderName);
	this.PlayDotsAnimation();
}

// ======== This stuff makes sure we remember the contact id and show the dialogue only when its that contact ==========
// Fires each time I open any contacts message
//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(MessengerDialogViewController)
public final func UpdateData(animateLastMessage: Bool, setVisited: Bool) -> Void {
    if (NCA.Phone().IsCustomContact(this.m_contactHash)) {
        NCA.Phone().OnOpenMessage(this);
    } else {
		wrappedMethod(animateLastMessage, setVisited);
    }	
}

//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(PhoneMessagePopupGameController)
private final func SetFocus(isFocused: Bool) -> Void {
	if NotEquals(this.m_isFocused, isFocused) {
		let customData = this.m_data as NcaJournalNotificationData;
		if IsDefined(customData) && NCA.Phone().IsCustomContact(customData.contactHash) {
			if !isFocused {
				this.m_dialogViewController.ClearDialogCustom();
			} else {
				this.m_dialogViewController.ShowDialogCustom(customData.contactHash);
				inkWidgetRef.SetVisible(this.m_hintCall, customData.isCallable);
			};
		};
	};
	wrappedMethod(isFocused);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public final func ShowDialogCustom(entryHash: Int32) -> Void {
    this.m_contactHash = entryHash;
	//this.m_parentHash = entryHash;
    this.m_singleThreadMode = true;
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.UpdateData(false, true);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public final func ClearDialogCustom() -> Void {
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
	this.m_messagesListController.Clear();
	this.m_choicesListController.Clear();
	inkCompoundRef.RemoveAllChildren(this.m_messagesList);
	inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

// need to pass contact hash to identify custom contacts
//@if(!ModuleExists("PhoneExtension.Classes"))
public class NcaJournalNotificationData extends JournalNotificationData {
	public let contactHash: Int32;
	public let isCallable: Bool;
}

// pass custom contact hash to sms messenger window
//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(NewHudPhoneGameController)
public final func GotoSmsMessenger(contactData: wref<ContactData>) -> Void {	
	if NCA.Phone().IsCustomContact(contactData.hash) {
		let evt = new OpenSmsMessengerEvent();
		let customData = new NcaJournalNotificationData();
		customData.type = contactData.type;
		customData.contactNameLocKey = StringToName(contactData.localizedName);
		customData.mode = JournalNotificationMode.HUD;
		customData.openedFromPhone = true;
		customData.source = this.m_screenType;
		customData.contactHash = contactData.hash;
		customData.isCallable = contactData.isCallable;
		evt.m_data = customData;
		this.QueueEvent(evt);
	} else {
		wrappedMethod(contactData);
	};
}

//pass custom contact hash to sms messenger window on refresh
//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(NewHudPhoneGameController)
public final func RefreshSmsMessager(contactData: wref<ContactData>) -> Void {
	if NCA.Phone().IsCustomContact(contactData.hash) {
		let evt = new RefreshSmsMessagerEvent();
		let customData = new NcaJournalNotificationData();
		customData.type = contactData.type;
		customData.contactNameLocKey = StringToName(contactData.localizedName);
		customData.mode = JournalNotificationMode.HUD;
		customData.openedFromPhone = true;
		customData.source = this.m_screenType;
		customData.contactHash = contactData.hash;
		customData.isCallable = contactData.isCallable;
		evt.m_data = customData;
		this.QueueEvent(evt);
	} else {
		wrappedMethod(contactData);
	};
}

// ===================== This stuff allows scrolling the responses and selecting one ===================================
//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(MessengerDialogViewController)
public final func NavigateReplyOptions(isUp: Bool) -> Void {
	if NCA.Phone().IsCustomContact(this.m_contactHash) {
		this.m_choicesListController.NavigateListCustom(isUp);
	} else {	
		wrappedMethod(isUp);
	};
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(JournalEntriesListController)
public func NavigateListCustom(isUp: Bool) -> Void {
	let replyWidget: wref<inkWidget>;
	let replyRenderer: wref<MessangerReplyItemRenderer>;
	let root = this.GetRootCompoundWidget();
	let size = root.GetNumChildren();
	let selectedIndex = this.GetSelectedIndexCustom();
	if selectedIndex > -1 {
		let newSelectedIndex = Clamp(selectedIndex + (isUp ? -1 : 1), 0, size - 1);
		if newSelectedIndex != selectedIndex {
			replyWidget = root.GetWidgetByIndex(selectedIndex);
			replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
			replyRenderer.UpdateSelectionCustom(false);
			replyWidget = root.GetWidgetByIndex(newSelectedIndex);
			replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
			replyRenderer.UpdateSelectionCustom(true);
		};
	};
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessangerReplyItemRenderer)
public func UpdateSelectionCustom(isSelected: Bool) -> Void {
	this.m_selectedState = isSelected;
	this.AnimateSelection();
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(JournalEntriesListController)
public func GetSelectedIndexCustom() -> Int32 {
	let root = this.GetRootCompoundWidget();
	let size = root.GetNumChildren();
	let i: Int32 = 0;
	let replyWidget: wref<inkWidget>;
	let replyRenderer: wref<MessangerReplyItemRenderer>;
	while i < size {
		replyWidget = root.GetWidgetByIndex(i);
		replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
		if IsDefined(replyRenderer) && replyRenderer.m_selectedState {
			return i;
		};
		i += 1;
	};
	return -1;
}

//@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(PhoneMessagePopupGameController)
private final func TryActivateChoice() -> Void {
    if !this.m_phoneSystem.IsTextingEnabled() {
      this.ShowActionBlockedNotification();
      return;
    };
	let customData = this.m_data as NcaJournalNotificationData;
	if IsDefined(customData) && NCA.Phone().IsCustomContact(customData.contactHash) {
		this.m_dialogViewController.ActivateSelectedReplyOptionCustomNCA();
	} else {
		wrappedMethod();
	};
}

//@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public final func ActivateSelectedReplyOptionCustomNCA() -> Void {
	if inkCompoundRef.GetNumChildren(this.m_choicesList) > 0 {
		let selectedIndex = this.m_choicesListController.GetSelectedIndexCustom();
		if selectedIndex > -1 {
			let replyWidget = inkCompoundRef.GetWidgetByIndex(this.m_choicesList, selectedIndex);
			let replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
			if IsDefined(replyRenderer) {
		        this.ClearRepliesCustom();
                NCA.Phone().OnSelectReply(this, selectedIndex); // Hook
				this.m_audioSystem.Play(n"ui_messenger_select");
				this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
			};
		};
	};
}
