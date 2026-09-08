//Cyberpunk 2077 Phone Extension Framework
//by r457 & gh057

/**
Handles initialization of new contacts and adding them to the phone/messenger view.
New contacts are pushed on top of the list.
Use questRelated = true when defining contact data if you want an additional yellow highlight.

Use this method to push new phone message notification to the HUD:
NotifyNewMessageCustom(contactHash: Int32, notificationTitle: String, notificationText: String)
**/

module PhoneExtension.System
import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*

public class PhoneExtensionSystem extends ScriptableSystem {
	private let m_phoneController: wref<NewHudPhoneGameController>;
	private let m_listeners: array<wref<PhoneEventsListener>>;
	
	public static func GetInstance(obj: ref<GameObject>) -> ref<PhoneExtensionSystem> {
		let gi: GameInstance = obj.GetGame();
		let system: ref<PhoneExtensionSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"PhoneExtension.System.PhoneExtensionSystem") as PhoneExtensionSystem;
		return system;
	}
	
	public func Init(phoneController: ref<NewHudPhoneGameController>) -> Void {
		FTLog("PhoneExtensionSystem.Init");
		this.m_phoneController = phoneController;
	}
	
	public func Uninit() -> Void {
		FTLog("PhoneExtensionSystem.Uninit");
		this.m_phoneController = null;
	}
	
	public func Register(listener: ref<PhoneEventsListener>) {
		if IsDefined(listener) {
			ArrayPush(this.m_listeners, listener);
		};
	}
	
	public func Unregister(listener: ref<PhoneEventsListener>) {
		if IsDefined(listener) {
			if ArrayContains(this.m_listeners, listener) {
				ArrayRemove(this.m_listeners, listener);
			};
		};
	}
	
	public func IsCustomContact(contactHash: Int32) -> Bool {
		let listener: wref<PhoneEventsListener>;
		let listenerHash: Int32;
		
		for listener in this.m_listeners {
			listenerHash = listener.GetContactHash();
			if listenerHash == contactHash {
				return true;
			};
		};
		
		return false;
	}
	
	public func GetContactsData(isText: Bool) -> array<ref<ContactData>> {
		let listener: wref<PhoneEventsListener>;
		let contactsData: array<ref<ContactData>>;
		let contactData: ref<ContactData>;
		
		for listener in this.m_listeners {
			contactData = listener.GetContactData(isText);
			if IsDefined(contactData) {
				ArrayPush(contactsData, contactData);
			};
		};
		
		return contactsData;
	}

	public func GetContactData(contactHash: Int32, isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		let listener: wref<PhoneEventsListener>;
		let listenerHash: Int32;
		
		for listener in this.m_listeners {
			listenerHash = listener.GetContactHash();
			if listenerHash == contactHash {
				return listener.GetContactData(isText);
			};
		};
		
		return contactData;
	}
	
	public func InsertCustomContacts(contactDataArray: array<ref<IScriptable>>, isText: Bool) -> array<ref<IScriptable>> {
		let customContactDataArray: array<ref<ContactData>>;
		let contactData: ref<ContactData>;
		
		customContactDataArray = this.GetContactsData(isText);
		for contactData in customContactDataArray {
			//for some reason there's 4h time difference when trying to get current game time
			//contactData.timeStamp = GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime();
			//order doesn't matter here - contacts are sorted by quest, replies, names, time
			ArrayInsert(contactDataArray, 0, contactData);
		};
		
		return contactDataArray;
	}
	
	public func GetCustomMessageThreads(contactHash: Int32) -> array<ref<IScriptable>> {
		//build threads to display when clicking R (read) on phone contact
		//can just pass the contact itself to directly trigger the messenger
		let contactDataArray: array<ref<IScriptable>>;
		let contactData = this.GetContactData(contactHash, true);
		ArrayInsert(contactDataArray, 0, contactData);
		return contactDataArray;
	}
	
	public func GetCustomDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		let listener: wref<PhoneEventsListener>;
		let listenerHash: Int32;
		
		for listener in this.m_listeners {
			listenerHash = listener.GetContactHash();
			if listenerHash == messengerController.m_contactHash {
				return listener.ShowDialog(messengerController);
			};
		};
		
		return false;
	}
	
	public func ActivateReply(contactHash: Int32, messageID: Int32) -> Void {
		let listener: wref<PhoneEventsListener>;
		let listenerHash: Int32;
		
		for listener in this.m_listeners {
			listenerHash = listener.GetContactHash();
			if listenerHash == contactHash {
				listener.ActivateReply(messageID);
			};
		};
	}
	
	public func NotifyNewMessageCustom(contactHash: Int32, notificationTitle: String, notificationText: String) -> Void {
		this.m_phoneController.PushSMSNotificationCustom(contactHash, notificationTitle, notificationText);
	}
}

//init

@addField(NewHudPhoneGameController)
private let m_phoneExtensionSystem: ref<PhoneExtensionSystem>;

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	this.m_phoneExtensionSystem = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	this.m_phoneExtensionSystem.Init(this);
	return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	this.m_phoneExtensionSystem.Uninit();
	return ret;
}
