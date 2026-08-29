module NightCityAllies.Phone.View

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Effect.*
import NightCityAllies.Settings.*
import NightCityAllies.Event.*

public class CustomConversationView extends ConversationPhoneView {
    public let m_nodes: array<ConversationNode>;
    private let m_id: Int32;
    private let m_companionRecordID: TweakDBID;
    private let m_hash: Int32;
    private let m_isImportant: Bool;

    public func PositionSetting() -> NCAPhoneEntryPosition = NCA.Settings().phoneConversationsPosition;
    public func GetColor() -> HDRColor = new HDRColor(0.2, 1.3, 0.1, 0.9);
    public func GetTime() -> GameTime = GameTime.MakeGameTime(
        NCA.Persistence().m_conversationRegistry[this.m_id].day,
        NCA.Persistence().m_conversationRegistry[this.m_id].hour,
        NCA.Persistence().m_conversationRegistry[this.m_id].minute
    );
    public func GetId() -> String = "DEFNCACNT" + NameToString(this.GetConversationId());
    public func GetConversationId() -> CName = NCA.Persistence().m_conversationRegistry[this.m_id].id;
    public func IsImportant() -> Bool = this.m_isImportant; // TODO variable <- unlocks are important

    // For InvalidateConversations
    public func SetConversationIndex(index: Int32) -> Void {
        this.m_id = index;
    }

    public func SetImportant(value: Bool) -> Void {
        this.m_isImportant = value;
    }    

    public func GetName() -> String {
        let companionID: Int32 = NCA.Persistence().GetIndex(this.m_companionRecordID);
        if (companionID < 0) {
            return NCA.Labels().Unknown();
        } else {
            return NCA.Persistence().m_companionRegistry[companionID].name;
        }
    }

    public func GetCurrentNode() -> CName {
        return NCA.Persistence().m_conversationRegistry[this.m_id].node;
    }

    public func SetCurrentNode(node: CName) -> Void {
        let time: GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();

        NCA.Persistence().m_conversationRegistry[this.m_id].node = node;
        NCA.Persistence().m_conversationRegistry[this.m_id].day = GameTime.Days(time);
        NCA.Persistence().m_conversationRegistry[this.m_id].hour = GameTime.Hours(time);
        NCA.Persistence().m_conversationRegistry[this.m_id].minute = GameTime.Minutes(time);
    }

    public func GetHash() -> Int32 {
        return this.m_hash;
    }

    public func IsActive() -> Bool {
        return !NCA.Context().isRestrictedTier
            && Equals(NCA.Persistence().m_conversationRegistry[this.m_id].status, ConversationProgressionState.Active)
            && !NCA.NPC().IsCompanion(this.m_companionRecordID);  // Dont show convo when companion is currently with us
    }
 
    protected abstract func ResolveEffect(effect: CName) -> Void {
        NCA.Effect().Trigger(effect, this.m_companionRecordID);
    }

    protected func OnEnd() -> Void {
        NCA.Persistence().m_conversationRegistry[this.m_id].status = ConversationProgressionState.Finished;
        NCA.Events().OnConversationFinished(this.GetConversationId());
    }

    public func Setup(id: Int32, recordID: TweakDBID, hash: Int32) -> Void {
        this.m_id = id;
        this.m_companionRecordID = recordID;
        this.m_hash = hash;
        this.m_nodes = [];
    }

    public func AddNode(node: ConversationNode) {
        ArrayPush(this.m_nodes, node);
    }

    public func GetCompanionRecordID() -> TweakDBID {
        return this.m_companionRecordID;
    }

    protected func GetNodes() -> array<ConversationNode> {
        return this.m_nodes;
    }
}