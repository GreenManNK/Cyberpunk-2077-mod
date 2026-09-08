//Cyberpunk 2077 Phone Extension Framework
//by r457 & gh057

/**
This is an intentionally basic class to catch show dialog and activate reply events.
It doesn't provide any functionality to build dialog trees - you will have to do it yourself.
(you can follow the example or do something of your own)
You can use AddTypingDelay and OnDelayedTypingEnd to imitate typing.

See PhoneExtension.Overrides.reds on which methods were added and how you can use them.

Only text messages are supported for now.
**/

module PhoneExtension.Classes
import PhoneExtension.DataStructures.*
import PhoneExtension.System.*

public class PhoneEventsListener extends IScriptable {

	public func GetContactHash() -> Int32 {
		return 45705700;
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = s"Empty Contact";
		contactData.contactId = s"DefaultEmptyContact";
		contactData.id = s"DEFEMPTCNT";
		contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
		contactData.questRelated = true;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = s"Empty Preview";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		contactData.messagesCount = 1;
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
	}
	
	public func AddTypingDelay(delaySystem: wref<DelaySystem>, delay: Float, messageID: Int32) -> Void {
		delaySystem.DelayCallback(CustomTypingCallback.Create(this, messageID), delay, false);
	}
	
	private func OnDelayedTypingEnd(messageID: Int32) -> Void {
	}
}

//delayed callback for typing animation
public class CustomTypingCallback extends DelayCallback {
	let m_listener: wref<PhoneEventsListener>;
	let m_messageID: Int32;
	
	public static func Create(listener: ref<PhoneEventsListener>, messageID: Int32) -> ref<CustomTypingCallback> {
		let created: ref<CustomTypingCallback> = new CustomTypingCallback();
		created.m_listener = listener;
		created.m_messageID = messageID;
		return created;
	}
	
	public func Call() -> Void {
		this.m_listener.OnDelayedTypingEnd(this.m_messageID);
	}
}

//need to pass contact hash to identify custom contacts
public class CustomJournalNotificationData extends JournalNotificationData {
	public let contactHash: Int32;
	public let isCallable: Bool;
}

//need to pass contact hash to identify custom contacts
//public class CustomUsePhoneRequest extends UsePhoneRequest {
//	public let contactHash: Int32;
//}
//doesn't work with custom request, adding field instead
@addField(UsePhoneRequest)
public let contactHash: Int32;

//custom message action to pass custom contact hash
public class CustomOpenPhoneMessageAction extends OpenPhoneMessageAction {
	public let m_contactHash: Int32;
	public let m_messageID: Int32;
	
	public func Execute(data: ref<IScriptable>) -> Bool {
		//FTLog("CustomOpenPhoneMessageAction.Execute");
		let request: ref<UsePhoneRequest> = new UsePhoneRequest();
		request.contactHash = this.m_contactHash;
		this.m_phoneSystem.QueueRequest(request);
		return true;
	}
}
