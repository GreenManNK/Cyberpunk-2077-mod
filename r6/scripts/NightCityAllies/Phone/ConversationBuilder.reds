module NightCityAllies.Phone

import NightCityAllies.*
import NightCityAllies.Settings.*
import NightCityAllies.Persistence.*
import NightCityAllies.Localization.*
import NightCityAllies.Phone.View.*

// Helper for Lua API
public class ConversationBuilder {
    public let m_conversation: ref<CustomConversationView>;
    
    public static func Create(id: Int32, companionId: TweakDBID, hash: Int32) -> ref<ConversationBuilder> {
        let obj = new ConversationBuilder();
        obj.m_conversation = new CustomConversationView();
        obj.m_conversation.Setup(id, companionId, hash);
        return obj;
    }

    public func AddNode(id: String) -> Void {
        this.m_conversation.AddNode(new ConversationNode(StringToName(id), [], []));
    }

    public func AddLine(line: String) -> Void {
        ArrayPush(
            this.m_conversation.m_nodes[ArraySize(this.m_conversation.m_nodes) - 1].textLines,
            StringToName(line)
        );
    }

    public func AddOption(text: String, nextNode: String, effect: String) -> Void {
        ArrayPush(
            this.m_conversation.m_nodes[ArraySize(this.m_conversation.m_nodes) - 1].responses,
            new ConversationNodeResponseOption(StringToName(text), StringToName(nextNode), StringToName(effect))
        );
    }
}