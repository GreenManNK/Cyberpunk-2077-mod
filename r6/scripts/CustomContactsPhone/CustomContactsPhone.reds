module CustomContactsPhone

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

// ============================================
// MAIKO MAEDA CONTACT
// ============================================
public class MaikoMaedaPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705800; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Maiko Maeda";
		contactData.contactId = s"maiko_maeda";
		contactData.id = s"MAIKO";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Hello, V. This is my new number.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		// Set the character in the texting system
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.MaikoMaeda;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false; // Prevent Phone Extension messenger from opening
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used when using AI chat
	}
}

// ============================================
// MICHIKO ARASAKA CONTACT
// ============================================
public class MichikoArasakaPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705801; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Michiko Arasaka";
		contactData.contactId = s"michiko_arasaka";
		contactData.id = s"MCHKO";
		contactData.avatarID = t"PhoneAvatars.Hanako";
		contactData.questRelated = false;
		contactData.isCallable = false;
		
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "V, Contact me if you need anything.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.MichikoArasaka;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// AURORE CASSEL CONTACT
// ============================================
public class AuroreCasselPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705802; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Aurore Cassel";
		contactData.contactId = s"aurore_cassel";
		contactData.id = s"AURRE";
		contactData.avatarID = t"PhoneAvatars.Lizzy_wizzy";
		contactData.questRelated = false;
		contactData.isCallable = false;
		
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Salut V! I've heard interesting things about you.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.AuroreCassel;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// PURPLE FORCE CONTACT
// ============================================
public class PurpleForcePhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705803; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Purple Force";
		contactData.contactId = s"purple_force";
		contactData.id = s"PURPL";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Thanks for helping us out the other day with Kerry! Dont be a stranger.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.PurpleForce;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}

	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// RED MENACE CONTACT
// ============================================
public class RedMenacePhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705804; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Red Menace";
		contactData.contactId = s"red_menace";
		contactData.id = s"REDMN";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Thanks for the help V. Stay for our show next time!";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.RedMenace;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// IMOGEN CONTACT
// ============================================
public class ImogenPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705805; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Imogen";
		contactData.contactId = s"imogen";
		contactData.id = s"IMOGN";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Don't think i didnt see you checking me out, come speak to me next time.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.Imogen;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}


	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// CHERI NOWLIN CONTACT
// ============================================
public class CheriNowlinPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705806; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Cheri Nowlin";
		contactData.contactId = s"cheri_nowlin";
		contactData.id = s"CHERI";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "I hope you don't mind. i took your contact details from the Clouds system.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.CheriNowlin;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// CHLOE VENDRANORD CONTACT
// ============================================
public class ChloeVendranordPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705807; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Chloe Vendranord";
		contactData.contactId = s"chloe_vendranord";
		contactData.id = s"CHLOE";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "You come in, and don't buy anything. every. damn. time.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.ChloeVendranord;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// Angelica Whelan CONTACT
// ============================================
public class AngelicaWhelanPhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
	}
	
	public func GetContactHash() -> Int32 {
		return 45705808; // Unique hash
	}
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = "Angelica Whelan";
		contactData.contactId = s"angelica_whelan";
		contactData.id = s"ANGELICA";
		contactData.avatarID = t"PhoneAvatars.Clouds";
		contactData.questRelated = false;
		contactData.isCallable = false;
		if isText {
			contactData.type = MessengerContactType.SingleThread;
			contactData.lastMesssagePreview = "Wanted to drop you my contact. Might have some work for someone with your... Skills.";
		} else {
			contactData.type = MessengerContactType.Contact;
		};
		
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		this.m_messengerController = messengerController;
		
		let textingSystem = GetTextingSystem();
		if IsDefined(textingSystem) {
			textingSystem.character = CharacterSetting.AngelicaWhelan;
			textingSystem.ToggleNpcSelected(true);
		}
		
		return false;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		// Not used
	}
}

// ============================================
// REGISTRATION WITH PHONE SYSTEM
// ============================================
@addField(NewHudPhoneGameController)
private let m_maikoMaedaContact: ref<MaikoMaedaPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_michikoArasakaContact: ref<MichikoArasakaPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_auroreCasselContact: ref<AuroreCasselPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_purpleForceContact: ref<PurpleForcePhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_redMenaceContact: ref<RedMenacePhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_imogenContact: ref<ImogenPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_cheriNowlinContact: ref<CheriNowlinPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_chloeVendranordContact: ref<ChloeVendranordPhoneEventsListener>;

@addField(NewHudPhoneGameController)
private let m_angelicaWhelanContact: ref<AngelicaWhelanPhoneEventsListener>;

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	
	// Register Maiko Maeda
	if !IsDefined(this.m_maikoMaedaContact) {
		this.m_maikoMaedaContact = new MaikoMaedaPhoneEventsListener();
		this.m_maikoMaedaContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_maikoMaedaContact);
	
	// Register Michiko Arasaka
	if !IsDefined(this.m_michikoArasakaContact) {
		this.m_michikoArasakaContact = new MichikoArasakaPhoneEventsListener();
		this.m_michikoArasakaContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_michikoArasakaContact);
	
	// Register Aurore Cassel
	if !IsDefined(this.m_auroreCasselContact) {
		this.m_auroreCasselContact = new AuroreCasselPhoneEventsListener();
		this.m_auroreCasselContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_auroreCasselContact);

	// Register Purple Force
	if !IsDefined(this.m_purpleForceContact) {
		this.m_purpleForceContact = new PurpleForcePhoneEventsListener();
		this.m_purpleForceContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_purpleForceContact);
	
	// Register Red Menace
	if !IsDefined(this.m_redMenaceContact) {
		this.m_redMenaceContact = new RedMenacePhoneEventsListener();
		this.m_redMenaceContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_redMenaceContact);
	
	// Register Imogen
	if !IsDefined(this.m_imogenContact) {
		this.m_imogenContact = new ImogenPhoneEventsListener();
		this.m_imogenContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_imogenContact);
	
	// Register Cheri Nowlin
	if !IsDefined(this.m_cheriNowlinContact) {
		this.m_cheriNowlinContact = new CheriNowlinPhoneEventsListener();
		this.m_cheriNowlinContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_cheriNowlinContact);
	
	// Register Chloe Vendranord
	if !IsDefined(this.m_chloeVendranordContact) {
		this.m_chloeVendranordContact = new ChloeVendranordPhoneEventsListener();
		this.m_chloeVendranordContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_chloeVendranordContact);

	// Register Angelica Whelan
	if !IsDefined(this.m_angelicaWhelanContact) {
		this.m_angelicaWhelanContact = new AngelicaWhelanPhoneEventsListener();
		this.m_angelicaWhelanContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_angelicaWhelanContact);
	
	return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	
	syst.Unregister(this.m_maikoMaedaContact);
	syst.Unregister(this.m_michikoArasakaContact);
	syst.Unregister(this.m_auroreCasselContact);
	syst.Unregister(this.m_purpleForceContact);
	syst.Unregister(this.m_redMenaceContact);
	syst.Unregister(this.m_imogenContact);
	syst.Unregister(this.m_cheriNowlinContact);
	syst.Unregister(this.m_chloeVendranordContact);
	syst.Unregister(this.m_angelicaWhelanContact);
	
	return ret;
}

// ============================================
// BRIDGE: Intercept contact selection
// ============================================
@wrapMethod(NewHudPhoneGameController)
public final func GotoSmsMessenger(contactData: wref<ContactData>) -> Void {
    ConsoleLog("[CustomContacts] GotoSmsMessenger called");
    
    // Check if this is one of our custom contacts
    if IsDefined(contactData) {
        ConsoleLog(s"[CustomContacts] Contact hash: \(contactData.hash)");
        
        let textingSystem = GetTextingSystem();
        if IsDefined(textingSystem) {
            if contactData.hash == 45705800 { // Maiko
                ConsoleLog("[CustomContacts] Setting character to Maiko Maeda");
                textingSystem.character = CharacterSetting.MaikoMaeda;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705801 { // Michiko
                ConsoleLog("[CustomContacts] Setting character to Michiko Arasaka");
                textingSystem.character = CharacterSetting.MichikoArasaka;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705802 { // Aurore
                ConsoleLog("[CustomContacts] Setting character to Aurore Cassel");
                textingSystem.character = CharacterSetting.AuroreCassel;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705803 { // Purple Force
                ConsoleLog("[CustomContacts] Setting character to Purple Force");
                textingSystem.character = CharacterSetting.PurpleForce;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705804 { // Red Menace
                ConsoleLog("[CustomContacts] Setting character to Red Menace");
                textingSystem.character = CharacterSetting.RedMenace;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705805 { // Imogen
                ConsoleLog("[CustomContacts] Setting character to Imogen");
                textingSystem.character = CharacterSetting.Imogen;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705806 { // Cheri Nowlin
                ConsoleLog("[CustomContacts] Setting character to Cheri Nowlin");
                textingSystem.character = CharacterSetting.CheriNowlin;
                textingSystem.ToggleNpcSelected(true);
            } else if contactData.hash == 45705807 { // Chloe Vendranord
                ConsoleLog("[CustomContacts] Setting character to Chloe Vendranord");
                textingSystem.character = CharacterSetting.ChloeVendranord;
                textingSystem.ToggleNpcSelected(true);
			} else if contactData.hash == 45705808 { // Angelica Whelan
                ConsoleLog("[CustomContacts] Setting character to Angelica Whelan");
                textingSystem.character = CharacterSetting.AngelicaWhelan;
                textingSystem.ToggleNpcSelected(true);			
			}	
        } else {
            ConsoleLog("[CustomContacts] ERROR: TextingSystem not defined!");
        }
    }
    
    // Always call the original method
    wrappedMethod(contactData);
}

// Note: Contact selection is already handled in GotoSmsMessenger above
// The OnContactActivated hook was removed due to incompatibility with PhoneDialerGameController