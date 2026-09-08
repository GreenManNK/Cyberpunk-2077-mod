//Cyberpunk 2077 Phone Extension Framework
//by r457 & gh057

/**
Your new contact must have a unique ID (hash) set up in your custom PhoneEventsListener.
The new system relies on contact ID (globally unique) and message ID (unique per contact).
The main class to display messages and process inputs is MessengerDialogViewController.
Its reference is passed to all PhoneEventsListener instances on ShowDialog.
You will probably want to save that reference to use it later for updating your dialog.

Main methods to display messages (in MessengerDialogViewController):
PushMessageCustom(messageText: String, messageType: MessageViewType, contactName: String, playSound: Bool)
PushReplyCustom(ID: Int32, messageText: String, isQuest: Bool, isSelected: Bool, hasFocus: Bool)
ClearRepliesCustom()
ClearMessagesCustom()
PlayDotsAnimationCustom(senderName: String)

When player activates a reply (click, hotkey), ActivateReply is called on your custom PhoneEventsListener.
The system passes message ID through it, so you can identify what was selected and push new messages and replies.

To push HUD new message notification you can use this method (in NewHudPhoneGameController):
PushSMSNotificationCustom(contactHash: Int32, notificationTitle: String, notificationText: String)
But it's better (easier) to access it through PhoneExtensionSystem instead.
**/

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

//---=== very clunky way to get player object globally ===---

public func GetPlayerObjectGlobal() -> ref<GameObject> {
	let inkSystem = GameInstance.GetInkSystem();
	let hudController = inkSystem.GetLayer(n"inkHUDLayer").GetGameController() as inkGameController;
	return hudController.GetPlayerControlledObject();
}

//---=== handle inserting custom contact into contact list ===---

//add new contacts to contacts tab list
@wrapMethod(JournalManager)
public final func GetContactDataArray(includeUnknown: Bool, includeNonCallable: Bool) -> array<ref<IScriptable>> {
    let contactDataArray: array<ref<IScriptable>>;
    let customContactDataArray: array<ref<IScriptable>>;
	let syst = PhoneExtensionSystem.GetInstance(GetPlayerObjectGlobal());
	
	contactDataArray = wrappedMethod(includeUnknown, includeNonCallable);
	customContactDataArray = syst.InsertCustomContacts(contactDataArray, false);
	
	return customContactDataArray;
}

//add new contact to messages tab list
@wrapMethod(MessengerUtils)
public final static func GetSimpleContactDataArray(journal: ref<JournalManager>, includeUnknown: Bool, skipEmpty: Bool, includeWithNoUnread: Bool, opt activeDataSync: wref<MessengerContactSyncData>) -> array<ref<IScriptable>> {
    let contactDataArray: array<ref<IScriptable>>;
    let customContactDataArray: array<ref<IScriptable>>;
	let syst = PhoneExtensionSystem.GetInstance(GetPlayerObjectGlobal());
	
	contactDataArray = wrappedMethod(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync);
	customContactDataArray = syst.InsertCustomContacts(contactDataArray, true);
	
	return customContactDataArray;
}

//add new contact to caller messages submenu
@wrapMethod(MessengerUtils)
public final static func GetMessageDataArrayForContact(journal: ref<JournalManager>, concactHash: Int32, includeUnknown: Bool, skipEmpty: Bool, opt activeDataSync: wref<MessengerContactSyncData>) -> array<ref<IScriptable>> {
	let syst = PhoneExtensionSystem.GetInstance(GetPlayerObjectGlobal());
	if syst.IsCustomContact(concactHash) {
		return syst.GetCustomMessageThreads(concactHash);
	} else {
		return wrappedMethod(journal, concactHash, includeUnknown, skipEmpty, activeDataSync);
	};
}

//---=== handle transferring custom contact hash for proper identification ===---

//pass custom contact hash to sms messenger window
@wrapMethod(NewHudPhoneGameController)
public final func GotoSmsMessenger(contactData: wref<ContactData>) -> Void {
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	
	if syst.IsCustomContact(contactData.hash) {
		//FTLog("GotoSmsMessenger: " + ToString(contactData.hash));
		let evt = new OpenSmsMessengerEvent();
		let customData = new CustomJournalNotificationData();
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
		//FTLog("GotoSmsMessenger: vanilla");
		wrappedMethod(contactData);
	};
}

//pass custom contact hash to sms messenger window on refresh
@wrapMethod(NewHudPhoneGameController)
public final func RefreshSmsMessager(contactData: wref<ContactData>) -> Void {
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	
	if syst.IsCustomContact(contactData.hash) {
		//FTLog("RefreshSmsMessager: " + ToString(contactData.hash));
		let evt = new RefreshSmsMessagerEvent();
		let customData = new CustomJournalNotificationData();
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
		//FTLog("RefreshSmsMessager: vanilla");
		wrappedMethod(contactData);
	};
}
//---=== handle showing and cleaning up custom dialog window ===---

@addMethod(MessengerDialogViewController)
public final func ShowDialogCustom(entryHash: Int32) -> Void {
    this.m_contactHash = entryHash;
	//this.m_parentHash = entryHash;
    this.m_singleThreadMode = true;
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
    this.UpdateData(false, true);
}

@wrapMethod(MessengerDialogViewController)
public final func UpdateData(animateLastMessage: Bool, setVisited: Bool) -> Void {
	let syst = PhoneExtensionSystem.GetInstance(this.m_playerObject);
	if !syst.GetCustomDialog(this) {
		wrappedMethod(animateLastMessage, setVisited);
	};
}

@addMethod(MessengerDialogViewController)
public final func ClearDialogCustom() -> Void {
    ArrayClear(this.m_replyOptions);
    ArrayClear(this.m_messages);
	this.m_messagesListController.Clear();
	this.m_choicesListController.Clear();
	inkCompoundRef.RemoveAllChildren(this.m_messagesList);
	inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

@wrapMethod(PhoneMessagePopupGameController)
private final func SetFocus(isFocused: Bool) -> Void {
	if NotEquals(this.m_isFocused, isFocused) {
		let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
		let customData = this.m_data as CustomJournalNotificationData;
		if IsDefined(customData) && syst.IsCustomContact(customData.contactHash) {
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

//---=== handle adding and cleaning up custom messages and replies ===---

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

@addMethod(MessengerDialogViewController)
public func PushReplyCustom(ID: Int32, messageText: String, isQuest: Bool, isSelected: Bool, hasFocus: Bool) -> Void {
	let replyWidget = this.SpawnFromLocal(inkCompoundRef.Get(this.m_choicesList), n"Reply");
	let replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
	replyRenderer.SetReplyViewCustom(ID, messageText, isQuest, isSelected, hasFocus);
}

@addMethod(MessengerDialogViewController)
public func ClearRepliesCustom() -> Void {
	inkCompoundRef.RemoveAllChildren(this.m_choicesList);
}

@addMethod(MessengerDialogViewController)
public func ClearMessagesCustom() -> Void {
	inkCompoundRef.RemoveAllChildren(this.m_messagesList);
}

@addMethod(MessengerDialogViewController)
public func PlayDotsAnimationCustom(senderName: String) -> Void {
	this.m_typingIndicatorController.SetName(senderName);
	this.PlayDotsAnimation();
}

//---=== handle custom replies navigation and activation ===---

@wrapMethod(MessengerDialogViewController)
public final func NavigateReplyOptions(isUp: Bool) -> Void {
	let syst = PhoneExtensionSystem.GetInstance(this.m_playerObject);
	if syst.IsCustomContact(this.m_contactHash) {
		this.m_choicesListController.NavigateListCustom(isUp);
	} else {	
		wrappedMethod(isUp);
	};
}

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

@wrapMethod(PhoneMessagePopupGameController)
private final func TryActivateChoice() -> Void {
	//FTLog("TryActivateChoice");
    if !this.m_phoneSystem.IsTextingEnabled() {
      this.ShowActionBlockedNotification();
      return;
    };
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	let customData = this.m_data as CustomJournalNotificationData;
	if IsDefined(customData) && syst.IsCustomContact(customData.contactHash) {
		this.m_dialogViewController.ActivateSelectedReplyOptionCustom();
	} else {
		wrappedMethod();
	};
}

@addMethod(MessengerDialogViewController)
public final func ActivateSelectedReplyOptionCustom() -> Void {
	if inkCompoundRef.GetNumChildren(this.m_choicesList) > 0 {
		let selectedIndex = this.m_choicesListController.GetSelectedIndexCustom();
		if selectedIndex > -1 {
			let replyWidget = inkCompoundRef.GetWidgetByIndex(this.m_choicesList, selectedIndex);
			let replyRenderer = replyWidget.GetControllerByType(n"MessangerReplyItemRenderer") as MessangerReplyItemRenderer;
			if IsDefined(replyRenderer) {
				let syst = PhoneExtensionSystem.GetInstance(this.m_playerObject);
				syst.ActivateReply(this.m_contactHash, replyRenderer.m_IdCustom);
				this.m_audioSystem.Play(n"ui_messenger_select");
				this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
			};
		};
	};
}

//---=== new methods to set up custom reply text and selection status ===---

@addField(MessangerReplyItemRenderer)
private let m_IdCustom: Int32;

@addMethod(MessangerReplyItemRenderer)
public func SetReplyViewCustom(ID: Int32, txt: String, isQuest: Bool, isSelected: Bool, isActive: Bool) -> Void {
	inkTextRef.SetText(this.m_labelPathRef, txt);
	this.m_IdCustom = ID;
	this.m_isQuestImportant = isQuest;
	this.m_selectedState = isSelected;
	this.m_isActive = isActive;
	this.AnimateSelection();
}

@addMethod(MessangerReplyItemRenderer)
public func UpdateSelectionCustom(isSelected: Bool) -> Void {
	this.m_selectedState = isSelected;
	this.AnimateSelection();
}

//---=== little details ===---

//handle scroll button hints: doesn't fix vanilla problem of hints appearing only after an action
@wrapMethod(PhoneMessagePopupGameController)
private final func SetupData() -> Void {
	wrappedMethod();
	inkWidgetRef.SetVisible(this.m_scrollReply, this.m_player.PlayerLastUsedKBM() && inkWidgetRef.IsVisible(this.m_scrollSlider));
}

//handle scroll button hints: doesn't fix vanilla problem of hints appearing only after an action
@wrapMethod(PhoneMessagePopupGameController)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
	//FTLog("OnAction: " + ToString(ListenerAction.GetName(action)));
	//let isPressed: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_PRESSED);
	//let isAxis: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.AXIS_CHANGE);
	//let isRelative: Bool = Equals(ListenerAction.GetType(action), gameinputActionType.RELATIVE_CHANGE);
	//FTLog("OnAction: isPressed = " + ToString(isPressed) + "; isAxis = " + ToString(isAxis) + "; isRelative = " + ToString(isRelative));
	wrappedMethod(action, consumer);
	inkWidgetRef.SetVisible(this.m_scrollReply, this.m_player.PlayerLastUsedKBM() && inkWidgetRef.IsVisible(this.m_scrollSlider));
}

//---=== new message notification ===---

@addMethod(NewHudPhoneGameController)
public func PushSMSNotificationCustom(contactHash: Int32, notificationTitle: String, notificationText: String) -> Void {
	//setup our new custom action
	let action: ref<CustomOpenPhoneMessageAction>;
	action = new CustomOpenPhoneMessageAction();
	action.m_phoneSystem = this.m_PhoneSystem;
	action.m_contactHash = contactHash;
	
	//push UI notification
	let notificationData: gameuiGenericNotificationData;
	let userData: ref<PhoneMessageNotificationViewData> = new PhoneMessageNotificationViewData();
	userData.contactHash = contactHash;
	userData.title = notificationTitle;
	userData.SMSText = notificationText;
	userData.action = action;
	userData.animation = n"notification_phone_MSG";
	userData.soundEvent = n"PhoneSmsPopup";
	userData.soundAction = n"OnOpen";
	notificationData.time = 6.70;
	notificationData.widgetLibraryItemName = n"notification_message";
	notificationData.notificationData = userData;
	this.AddNewNotificationData(notificationData);
	
	//let entry = this.m_journalMgr.GetEntry(45705701u);
	//if IsDefined(entry) {
	//	FTLog("Testing if journal entry exists: " + ToString(entry.GetId()));
	//};
}

@wrapMethod(PhoneSystem)
private final func OnUsePhone(request: ref<UsePhoneRequest>) -> Void {
	//FTLog("PhoneSystem.OnUsePhone");
	let player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
	let system = PhoneExtensionSystem.GetInstance(player);
	if system.IsCustomContact(request.contactHash) {
		//repeating vanilla checks for phone being already opened...
		if this.IsPhoneOpened() {
			return;
		};
		//...or disabled
		if !this.IsPhoneEnabled() {
			GameInstance.GetUISystem(player.GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
			let notificationEvent = new UIInGameNotificationEvent();
			notificationEvent.m_notificationType = UIInGameNotificationType.CombatRestriction;
			GameInstance.GetUISystem(player.GetGame()).QueueEvent(notificationEvent);
			return;
		};
		//passing contact hash as message hash triggers the proper method chain to show the messenger window
		//(kinda the same trick as with GetMessageDataArrayForContact)
		if !this.m_ContactsOpen {
			this.m_Blackboard.SetInt(GetAllBlackboardDefs().UI_ComDevice.MessageToOpenHash, request.contactHash, true);
			this.ToggleContacts(true);
			return;
		};
	} else {
		wrappedMethod(request);
	};
}

//---=== debug stuff ===---

//@wrapMethod(PhoneMessagePopupGameController)
//protected cb func OnGotFocus(evt: ref<FocusSmsMessagerEvent>) -> Bool {
//m_messageToOpenHash
//FocusSmsMessenger
//	FTLog("PhoneMessagePopupGameController.OnGotFocus");
//	wrappedMethod(evt);
//}

//@wrapMethod(NewHudPhoneGameController)
//private final func FindMessageToSelect() -> Void {
//	FTLog("FindMessageToSelect");
//	wrappedMethod();
//}
//
//@wrapMethod(NewHudPhoneGameController)
//protected cb func OnSmsMessageGotFocus(evt: ref<FocusSmsMessagerEvent>) -> Bool {
//	FTLog("OnSmsMessageGotFocus");
//	wrappedMethod(evt);
//}
//
//@wrapMethod(NewHudPhoneGameController)
//public final func ExecuteAction() -> Void {
//	FTLog("ExecuteAction");
//	wrappedMethod();
//}
//
//@wrapMethod(NewHudPhoneGameController)
//public final func ShowSelectedContactMessages(contactData: wref<ContactData>) -> Void {
//	FTLog("ShowSelectedContactMessages");
//	wrappedMethod(contactData);
//}
//
//@wrapMethod(NewHudPhoneGameController)
//protected cb func OnContactListAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
//	FTLog("OnContactListAction");
//	wrappedMethod(action, consumer);
//}

//go to messenger from phone contacts tab
//@wrapMethod(PhoneDialerGameController)
//private final func GotoMessengerMenu() -> Void {
//	FTLog("GotoMessengerMenu");
//	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
//	let item = this.m_listController.GetSelectedItem() as PhoneContactItemVirtualController;
//	let contactData = item.GetContactData();
//	
//	if syst.IsCustomContact(contactData.hash) {
//	} else {
//		wrappedMethod();
//	};
//}

//pass custom contact hash on setup data for message view
//@wrapMethod(PhoneMessagePopupGameController)
//private final func SetupData() -> Void {
//	wrappedMethod();
//	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
//	let customData = this.m_data as CustomJournalNotificationData;
//	if IsDefined(customData) && syst.IsCustomContact(customData.contactHash) {
//		FTLog("SetupData: " + ToString(customData.contactHash));
//		//this.m_dialogViewController.ShowDialogCustom(customData.contactHash);
//	} else {
//		FTLog("SetupData: vanilla");
//	};
//}

//@wrapMethod(PhoneMessagePopupGameController)
//protected cb func OnChoiceEntryStateChanged(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
//	FTLog("PhoneMessagePopupGameController.OnChoiceEntryStateChanged: " + ToString(entryHash));
//	if entryHash == 45705701u {
//	} else {
//		wrappedMethod(entryHash, className, notifyOption, changeType);
//	};
//}

//@wrapMethod(MessengerGameController)
//protected cb func OnContactActivated(evt: ref<MessengerContactSelectedEvent>) -> Bool {
//	FTLog("MessengerGameController.OnContactActivated: " + ToString(evt.m_entryHash));
//	if evt.m_entryHash == 45705701 {
//		//FTLog("LifeInsuranceSystem text messenger setup");
//        //this.SyncActiveData(evt);
//        //this.m_dialogController.ShowDialogCustom(evt.m_entryHash);
//	} else {
//		wrappedMethod(evt);
//	};
//}

//@wrapMethod(MessengerDialogViewController)
//public final func SetFocus(focused: Bool) -> Void {
//	wrappedMethod(focused);
//	let syst = PhoneExtensionSystem.GetInstance(this.m_playerObject);
//	if !focused && syst.IsCustomContact(this.m_contactHash) {
//		inkCompoundRef.RemoveAllChildren(this.m_messagesList);
//		inkCompoundRef.RemoveAllChildren(this.m_choicesList);
//	};
//}

//@wrapMethod(PhoneMessagePopupGameController)
//protected cb func OnRefresh(evt: ref<RefreshSmsMessagerEvent>) -> Bool {
//	if NotEquals(this.m_data, evt.m_data) {
//		inkCompoundRef.RemoveAllChildren(this.m_dialogViewController.m_messagesList);
//		inkCompoundRef.RemoveAllChildren(this.m_dialogViewController.m_choicesList);
//	};
//	wrappedMethod(evt);
//}
