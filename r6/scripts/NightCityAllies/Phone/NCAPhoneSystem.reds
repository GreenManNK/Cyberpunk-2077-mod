module NightCityAllies.Phone

import NightCityAllies.*
import NightCityAllies.Settings.*
import NightCityAllies.Persistence.*
import NightCityAllies.Localization.*
import NightCityAllies.Phone.View.*
import NightCityAllies.Npc.*

public struct NCAPhoneConversationTrigger {
    public let id: CName;
    public let conversationID: Int32;
    public let probability: Float;
    public let friendship: Int32;
    public let love: Int32;
    public let isRepeatable: Bool;
    public let allowForLocked: Bool;
}

// Currently just brings all the entrypoints into one place to add custom message dialogues
public final class NCAPhoneSystem extends ScriptableSystem {
    private let m_contactHash: Int32;
    private let m_contactData: ref<ContactData>;
    private let m_phoneViews: array<ref<PhoneView>>;
    private let m_customHashCounter: Int32 = 0;
    private let m_conversationTriggers: array<NCAPhoneConversationTrigger>;
    private let m_customViewIds: array<Int32>;
    private let m_lastMessageMinute: Int32;
	private let m_phoneController: wref<NewHudPhoneGameController>;

	public func OnAttach() {
        this.m_phoneViews = [
            new MercListPhoneView(),
            new NoMercsPhoneView()
        ];
	}
	
	public func Init(phoneController: ref<NewHudPhoneGameController>) -> Void {
		this.m_phoneController = phoneController;
	}

    // Check if hash is custom contact hash.
    public func IsCustomContact(contactHash: Int32) -> Bool {
        let view: ref<PhoneView> = this.FindViewByHash(contactHash);
        return IsDefined(view);
    }
        
    // When opening the phone message page (not contacts page)
    public func OnGetContacts(contactDataArray: array<ref<IScriptable>>) -> array<ref<IScriptable>> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_phoneViews) {
            if (this.m_phoneViews[i].IsActive()) {
	            ArrayInsert(contactDataArray, 0, this.m_phoneViews[i].GetContactData());
            }
            i += 1;
        };
		return contactDataArray;
    }
    
    // When opening any message with IsCustomContact true for the contact hash
    public func OnOpenMessage(mdvController: ref<MessengerDialogViewController>) -> Bool {
        let view: ref<PhoneView> = this.FindViewByHash(mdvController.GetContactHash());
        if IsDefined(view) {
            view.Render(mdvController);
            return true;
        }
        return false;
    }

    // When confirming a reply
    public func OnSelectReply(mdvController: ref<MessengerDialogViewController>, selectedIndex: Int32) -> Void {
        let view: ref<PhoneView> = this.FindViewByHash(mdvController.GetContactHash());
        if IsDefined(view) {
            view.Select(mdvController, selectedIndex);
        }
    }

    public func CreateConversationTrigger(id: CName, probability: Float, opt friendship: Int32, opt love: Int32, opt isRepeatable: Bool, opt allowForLocked: Bool) -> Int32 {
        let conversationIndex: Int32 = this.GetConversationIndexById(id); // îndex inside this classes "views"
        if (conversationIndex < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return -1;
        }

        let index: Int32 = this.GetConversationTriggerIndex(id);
        if (index >= 0) {
            this.m_conversationTriggers[index].conversationID = conversationIndex;
            this.m_conversationTriggers[index].probability = probability;
            this.m_conversationTriggers[index].friendship = friendship;
            this.m_conversationTriggers[index].love = love;
            this.m_conversationTriggers[index].isRepeatable = isRepeatable;
            this.m_conversationTriggers[index].allowForLocked = allowForLocked;
            return index;
        }

        ArrayPush(this.m_conversationTriggers, new NCAPhoneConversationTrigger(
            id,
            conversationIndex,
            probability,
            friendship,
            love,
            isRepeatable,
            allowForLocked
        ));
        
        return ArraySize(this.m_conversationTriggers) - 1;
    }

    public func SetConversationImportant(id: CName, isImportant: Bool) -> Void {
        let conversationIndex: Int32 = this.GetConversationIndexById(id); // îndex inside this classes "views"
        if (conversationIndex < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return;
        }

        let conversation: ref<CustomConversationView> = this.m_phoneViews[conversationIndex] as CustomConversationView;
        if IsDefined(conversation) {
            conversation.SetImportant(isImportant);
        }
    }

    // Maps a conversation back to the character it belongs to.
    // The companion registry has no link to conversations, the views are the only place it exists.
    public func FindCompanionForConversation(id: CName, out recordID: TweakDBID) -> Bool {
        let conversationIndex: Int32 = this.GetConversationIndexById(id);
        if (conversationIndex < 0) {
            return false;
        }

        let conversation: ref<CustomConversationView> = this.m_phoneViews[conversationIndex] as CustomConversationView;
        if !IsDefined(conversation) {
            return false;
        }

        recordID = conversation.GetCompanionRecordID();
        return true;
    }

    public func TriggerRandomConversation() -> Bool {
        if NCA.Context().isRestrictedTier || this.IsInMessageCooldown() || ArraySize(this.m_conversationTriggers) <= 0 {
            return false;
        }

        let triggerIndex: Int32 = RandRange(0, ArraySize(this.m_conversationTriggers));
        let conversationIndex: Int32 = this.m_conversationTriggers[triggerIndex].conversationID;
        let conversation: ref<CustomConversationView> = this.m_phoneViews[conversationIndex] as CustomConversationView;
        let recordID: TweakDBID = conversation.GetCompanionRecordID();
        let companionIndex: Int32 = NCA.Persistence().GetIndex(recordID);
        let random: Float = RandF();

        let isStandby: Bool = Equals(NCA.Persistence().m_companionRegistry[companionIndex].spawnState, CompanionSpawnState.Standby);
        let isLocked: Bool = Equals(NCA.Persistence().m_companionRegistry[companionIndex].spawnState, CompanionSpawnState.Locked);
        let allowLocked: Bool = this.m_conversationTriggers[triggerIndex].allowForLocked;
        let isSpawned = NCA.NPC().GetIndex(recordID) >= 0;

        if !isSpawned
        && (isStandby || (allowLocked && isLocked))
        && (NCA.Persistence().m_companionRegistry[companionIndex].friendship >= this.m_conversationTriggers[triggerIndex].friendship)
        && (NCA.Persistence().m_companionRegistry[companionIndex].love >= this.m_conversationTriggers[triggerIndex].love)
        && random <= this.m_conversationTriggers[triggerIndex].probability
        && (!this.HasOpenConversation(recordID))
        {
            if NCA.Persistence().UnlockConversation(
                this.m_conversationTriggers[triggerIndex].id,
                this.m_conversationTriggers[triggerIndex].isRepeatable
            ) {
                this.m_phoneController.PushSMSNotificationCustom(conversation.GetHash(), conversation.GetName(), conversation.GetFirstLinePreview());
                this.m_lastMessageMinute = NCAPhoneSystem.GetGameMinute();
                return true;
            }
        }

        return false;
    }

    // Game time in whole minutes
    private static func GetGameMinute() -> Int32 {
        return GameTime.GetSeconds(GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime()) / 60;
    }

    // Only random messages are held back - a conversation sent on purpose always goes through.
    private func IsInMessageCooldown() -> Bool {
        let cooldown: Int32 = NCA.Settings().messageCooldown;
        if cooldown <= 0 || this.m_lastMessageMinute <= 0 {
            return false;
        }

        let now: Int32 = NCAPhoneSystem.GetGameMinute();
        if now < this.m_lastMessageMinute { // loading an older save moves game time backwards
            this.m_lastMessageMinute = now;
            return false;
        }

        return now - this.m_lastMessageMinute < cooldown;
    }

    public func TriggerConversationString(id: String) -> Bool {
        return this.TriggerConversation(StringToName(id));
    }

    public func TriggerConversation(id: CName) -> Bool {
        let index: Int32 = this.GetConversationIndexById(id);
        if (index < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return false;
        }

        let unlocked: Bool = NCA.Persistence().UnlockConversation(id, true);
        let isActive: Bool = Equals(
            NCA.Persistence().GetConversationStatus(id),
            ConversationProgressionState.Active
        );

        if (!unlocked && !isActive) {
            return false;
        }

        this.TriggerNotification(id);
        return true;
    }

    public func TriggerNotification(id: CName) -> Void {
        let index: Int32 = this.GetConversationIndexById(id);
        if (index < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return;
        }

        let conversation: ref<ConversationPhoneView> = this.m_phoneViews[index] as ConversationPhoneView;
        this.m_phoneController.PushSMSNotificationCustom(conversation.GetHash(), conversation.GetName(), conversation.GetFirstLinePreview());
    }
    
    public func CreateConversation(id: String, record: String) -> ref<ConversationBuilder> {
        // TODO check duplicates?
        let conversation = ConversationBuilder.Create(
            NCA.Persistence().RegisterConversation(StringToName(id)),  // Progression is stored in persistence, get id
            TDBID.Create(record),                                      // companion ID or -1
            13377331 + this.m_customHashCounter                        // phone conversation hash
        );
        this.m_customHashCounter += 1;        
        ArrayPush(this.m_phoneViews, conversation.m_conversation);        
        ArrayPush(this.m_customViewIds, ArraySize(this.m_phoneViews) - 1);
        return conversation;
    }

    // --- Editor support ---------------------------------------------------------------------------
    // Read only. TODO implement live edit
    public func GetCustomConversations() -> array<ref<CustomConversationView>> {
        let result: array<ref<CustomConversationView>>;

        let i: Int32 = 0;
        while i < ArraySize(this.m_customViewIds) {
            let view: ref<CustomConversationView> = this.m_phoneViews[this.m_customViewIds[i]] as CustomConversationView;
            if IsDefined(view) {
                ArrayPush(result, view);
            }
            i += 1;
        };

        return result;
    }

    public func GetConversationTriggers() -> array<NCAPhoneConversationTrigger> {
        return this.m_conversationTriggers;
    }

    private func FindViewByHash(contactHash: Int32) -> ref<PhoneView> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_phoneViews) {
            if Equals(this.m_phoneViews[i].GetHash(), contactHash) {
                return this.m_phoneViews[i];
            };
            i += 1;
        };
        //NCA.CETLog("didnt find hash " + ToString(contactHash));
        return null;
    }

    private func GetConversationTriggerIndex(id: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_conversationTriggers) {
            if Equals(this.m_conversationTriggers[i].id, id) {
                return i;
            };
            i += 1;
        };
        return -1;
    }

    public func InvalidateConversations() -> Void {
        let views: array<ref<CustomConversationView>>;
        let ids: array<CName>;

        let i: Int32 = 0;
        while i < ArraySize(this.m_customViewIds) {
            let view: ref<CustomConversationView> = this.m_phoneViews[this.m_customViewIds[i]] as CustomConversationView;
            if IsDefined(view) {
                ArrayPush(views, view);
                ArrayPush(ids, view.GetConversationId());
            }
            i += 1;
        }

        if ArraySize(ids) <= 0 {
            NCA.CETLog("WARNING Skipped conversation cleanup - no conversations are registered");
            return;
        }

        let dropped: Int32 = NCA.Persistence().RemoveConversationsNotIn(ids);
        if dropped <= 0 {
            return;
        }

        i = 0;
        while i < ArraySize(views) {
            let moved: Int32 = NCA.Persistence().GetConversationIndex(ids[i]);
            if moved < 0 {
                // A registered conversation was erased anyway - the view can no longer read its
                // own row, which shows up as a conversation with no nodes.
                NCA.CETLog("WARNING Registered conversation " + NameToString(ids[i]) + " was dropped");
            }

            views[i].SetConversationIndex(moved);
            i += 1;
        }

        NCA.CETLog("Dropped " + IntToString(dropped) + " conversation(s) that no longer exist");
    }

    private func GetConversationIndexById(id: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_customViewIds) {
            let view: ref<CustomConversationView> = this.m_phoneViews[this.m_customViewIds[i]] as CustomConversationView;
            if IsDefined(view) && Equals(view.GetConversationId(), id) {
                return this.m_customViewIds[i];
            };
            i += 1;
        };
        return -1;
    }

    private func HasOpenConversation(recordID: TweakDBID) -> Bool {
        //NCA.CETLog("Has open " + ToString(this.GetActiveConversationIndexByRecordId(recordID) >= 0));
        return this.GetActiveConversationIndexByRecordId(recordID) >= 0;
    }

    private func GetActiveConversationIndexByRecordId(recordID: TweakDBID) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_customViewIds) {
            let view: ref<CustomConversationView> = this.m_phoneViews[this.m_customViewIds[i]] as CustomConversationView;
            if IsDefined(view) && view.IsActive() && Equals(view.GetCompanionRecordID(), recordID) {
                return this.m_customViewIds[i];
            };
            i += 1;
        };
        return -1;
    }

    // ========================================== Trigger methods in lua VM ============================================
    public func CETLog(message: String) -> Void { /* Log in CET console */ }
}



// ============================================== Compatibility stuff ==================================================
@addMethod(MessengerDialogViewController)
public func GetDelaySystem() -> wref<DelaySystem> {
    return this.m_delaySystem;
}

@addMethod(MessengerDialogViewController)
public func GetContactHash() -> Int32 {
    return this.m_contactHash;
}

@addMethod(MessengerDialogViewController)
public func AddSentMessage(messageText: String) -> Void {
    this.PushMessageCustom(messageText, MessageViewType.Sent, s"V", true);
}

@addMethod(MessengerDialogViewController)
public func AddReceivedMessage(messageText: String) -> Void {
    this.PushMessageCustom(messageText, MessageViewType.Received, s"NCA", true);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func AddDelayedReceivedMessage(delay: Float, messageText: String) -> Void {
    this.PushMessageCustom(messageText, MessageViewType.Received, s"NCA", true);
    //this.TryPushDelayedMessage(delay, messageText);
}

@if(ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func AddDelayedReceivedMessage(delay: Float, messageText: String) -> Void {
    this.PushMessageCustom(messageText, MessageViewType.Received, s"NCA", true); // TODO fix the delay later
}

@if(ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func AddReplyOption(counter: Int32, messageText: String, isQuest: Bool, isSelected: Bool) -> Void {
    this.PushReplyCustom(counter, messageText, isQuest, isSelected, this.m_hasFocus);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(MessengerDialogViewController)
public func AddReplyOption(counter: Int32, messageText: String, isQuest: Bool, isSelected: Bool) -> Void {
    this.PushReplyCustom(messageText, isQuest, isSelected);
}


@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
    NCA.Phone().Init(this);
	return wrappedMethod();
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addField(UsePhoneRequest)
public let contactHash: Int32;

@if(!ModuleExists("PhoneExtension.Classes"))
public class CustomOpenPhoneMessageAction extends OpenPhoneMessageAction {
	public let m_contactHash: Int32;
	public let m_messageID: Int32;
	public func Execute(data: ref<IScriptable>) -> Bool {
		let request: ref<UsePhoneRequest> = new UsePhoneRequest();
		request.contactHash = this.m_contactHash;
		this.m_phoneSystem.QueueRequest(request);
		return true;
	}
}

@wrapMethod(PhoneSystem)
private final func OnUsePhone(request: ref<UsePhoneRequest>) -> Void {
	let player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
	if NCA.Phone().IsCustomContact(request.contactHash) {
		if this.IsPhoneOpened() {
			return;
		};
		if !this.IsPhoneEnabled() {
			GameInstance.GetUISystem(player.GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
			let notificationEvent = new UIInGameNotificationEvent();
			notificationEvent.m_notificationType = UIInGameNotificationType.CombatRestriction;
			GameInstance.GetUISystem(player.GetGame()).QueueEvent(notificationEvent);
			return;
		};

		//passing contact hash as message hash triggers the proper method chain to show the messenger window
		if !this.m_ContactsOpen {
			this.m_Blackboard.SetInt(GetAllBlackboardDefs().UI_ComDevice.MessageToOpenHash, request.contactHash, true);
			this.ToggleContacts(true);
			return;
		};
	} else {
		wrappedMethod(request);
	};
}


@if(!ModuleExists("PhoneExtension.Classes"))
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
}


// ============================================= Styling NCA Messages ==================================================
@addMethod(PhoneContactItemVirtualController)
protected func SetNcaStyle(view: ref<PhoneView>) -> Void {
    let companionColor = view.GetColor();
    //inkWidgetRef.SetTintColor(this.m_preview, companionColor);
    //inkWidgetRef.SetTintColor(this.m_msgCount, companionColor);
    inkWidgetRef.SetTintColor(this.m_label, companionColor);
    inkWidgetRef.SetTintColor(this.m_questFlag, companionColor);
    //this.m_statusText.SetTintColor(new HDRColor(1.0, 0.6, 0.1, 1.0));
}

@wrapMethod(PhoneContactItemVirtualController)
protected cb func OnDataChanged(value: Variant) -> Bool {
    let result: Bool = wrappedMethod(value);
    let contactData: wref<ContactData> = FromVariant<ref<IScriptable>>(value) as ContactData;
	if NCA.Phone().IsCustomContact(contactData.hash) {
        let view = NCA.Phone().FindViewByHash(contactData.hash);
        this.SetNcaStyle(view);
    }
    return result;
}

@wrapMethod(PhoneContactItemVirtualController)
protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    let result: Bool = wrappedMethod(itemController);
    let contactData: wref<ContactData> = this.m_contactData;
	if NCA.Phone().IsCustomContact(contactData.hash) {
        let view = NCA.Phone().FindViewByHash(contactData.hash);
        this.SetNcaStyle(view);
    }
    return result;
}

@wrapMethod(PhoneContactItemVirtualController)  
protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    let result: Bool = wrappedMethod(itemController, discreteNav);
    let contactData: wref<ContactData> = this.m_contactData;
	if NCA.Phone().IsCustomContact(contactData.hash) {
        let view = NCA.Phone().FindViewByHash(contactData.hash);
        this.SetNcaStyle(view);
    }
    return result;
}

// Custom sorting
@wrapMethod(DialerContactDataView)
public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftData: ref<ContactData> = left as ContactData;
    let rightData: ref<ContactData> = right as ContactData;
    let leftIsNca: Bool = NCA.Phone().IsCustomContact(leftData.hash);
    let rightIsNca: Bool = NCA.Phone().IsCustomContact(rightData.hash);

    if !Equals(leftIsNca, rightIsNca) && (rightIsNca) {
        let phoneView = NCA.Phone().FindViewByHash(rightData.hash);
        let setting: NCAPhoneEntryPosition = phoneView.PositionSetting();
        
        if Equals(setting, NCAPhoneEntryPosition.Bottom) {
            return true;
        }

        if Equals(setting, NCAPhoneEntryPosition.AboveQuest) || Equals(setting, NCAPhoneEntryPosition.AboveQuestTop) {
            return wrappedMethod(left, right);
        }

        if Equals(setting, NCAPhoneEntryPosition.BelowQuest) || Equals(setting, NCAPhoneEntryPosition.BelowQuestTop) {
            return leftData.hasQuestImportantReply;
        }
    }

    if (leftIsNca && rightIsNca) {
        let leftView = NCA.Phone().FindViewByHash(leftData.hash);
        let rightView = NCA.Phone().FindViewByHash(rightData.hash);
        let leftPos = leftView.PositionSetting();
        let rightPos = rightView.PositionSetting();
        
        if !Equals(leftPos, rightPos) {
            return EnumInt(leftPos) > EnumInt(rightPos);
        }
    }
    
    return wrappedMethod(left, right);
}
