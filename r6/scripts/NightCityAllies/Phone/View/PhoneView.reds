module NightCityAllies.Phone.View

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*

public abstract class PhoneView {
    public abstract func GetHash() -> Int32;
    public abstract func GetId() -> String;
    public abstract func GetPreview() -> String;
    public abstract func GetName() -> String;
    public abstract func IsActive() -> Bool;
    public abstract func PositionSetting() -> NCAPhoneEntryPosition;
    public abstract func GetColor() -> HDRColor;
    public abstract func GetTime() -> GameTime;
    public abstract func IsImportant() -> Bool;
    public abstract func Render(mdvController: ref<MessengerDialogViewController>) -> Void;
    public abstract func Select(mdvController: ref<MessengerDialogViewController>, selectedIndex: Int32) -> Void;
    public func GetContactData() -> ref<ContactData> {
	    let contactData: ref<ContactData>;
	    contactData = new ContactData();
	    contactData.hash = this.GetHash(); //unique id
	    contactData.localizedName = this.GetName();
	    contactData.contactId = s"NCA_" + this.GetId();
	    contactData.id = this.GetId();
	    contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
	    contactData.questRelated = this.IsImportant();
	    contactData.isCallable = false;
	    contactData.type = MessengerContactType.SingleThread;
	    //contactData.type = MessengerContactType.Contact; //for contact page
	    contactData.lastMesssagePreview = this.GetPreview();
		contactData.timeStamp = this.GetTime();
	    contactData.messagesCount = 1;
        contactData.unreadMessegeCount = 0;
	    contactData.hasMessages = true;
        //contactData.playerCanReply = true; // letter symbol
	    contactData.playerIsLastSender = false;
	    return contactData;
    }
}
