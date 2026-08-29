module NightCityAllies.Phone.View

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Effect.*

public struct ConversationNodeResponseOption {
    public let text: CName;
    public let nextNode: CName;
    public let effect: CName;
}

public struct ConversationNode {
    public let id: CName;
    public let textLines: array<CName>;
    public let responses: array<ConversationNodeResponseOption>;
}

public class ConversationMessageDelayCallback extends DelayCallback {
    private let m_owner: ref<ConversationPhoneView>;

    public static func Create(owner: ref<ConversationPhoneView>) -> ref<ConversationMessageDelayCallback> {
        let cb: ref<ConversationMessageDelayCallback> = new ConversationMessageDelayCallback();
        cb.m_owner = owner;
        return cb;
    }

    public func Call() -> Void {
        this.m_owner.PopQueue();
    }
}

public abstract class ConversationPhoneView extends PhoneView {
    private let m_queue: array<CName>;
    private let m_mdvController: wref<MessengerDialogViewController>;

    protected abstract func GetCurrentNode() -> CName;
    protected abstract func SetCurrentNode(node: CName) -> Void;

    protected abstract func GetNodes() -> array<ConversationNode>;
    protected abstract func OnEnd() -> Void;

    public func GetPreview() -> String {
        let node = this.FindNode(this.GetCurrentNode());
        let currentLines = node.textLines;
        return NCA.Labels().T(currentLines[ArraySize(currentLines) - 1]);
    }

    public func GetFirstLinePreview() -> String {
        let node = this.FindNode(this.GetCurrentNode());
        let currentLines = node.textLines;
        return NCA.Labels().T(currentLines[0]);
    }

    public func Render(mdvController: ref<MessengerDialogViewController>) -> Void {
        this.m_mdvController = mdvController;
        let node = this.FindNode(this.GetCurrentNode());
        let i: Int32 = 0;
        while i < ArraySize(node.textLines) {
            mdvController.AddReceivedMessage(NCA.Labels().T(node.textLines[i]));
            i += 1;
        };
        this.RenderReplyOptions();
    }

    public func Select(mdvController: ref<MessengerDialogViewController>, selectedIndex: Int32) -> Void {
        this.m_mdvController = mdvController;
        let node = this.FindNode(this.GetCurrentNode());
        let response = node.responses[selectedIndex];

        mdvController.AddSentMessage(NCA.Labels().T(response.text));

        this.ResolveEffect(response.effect);

        this.SetCurrentNode(response.nextNode);
        let nextNode = this.FindNode(this.GetCurrentNode());
        this.m_queue = nextNode.textLines;

        if !Equals(this.GetCurrentNode(), n"end") {
		    this.m_mdvController.PlayDotsAnimationCustom(this.GetName());
            this.m_mdvController.GetDelaySystem().DelayCallback(ConversationMessageDelayCallback.Create(this), this.CalculateTypingDuration(), false);
        } else {
            this.OnEnd();
        }
    }
    
    public func PopQueue() -> Void {
        let line: CName = this.m_queue[0];
        ArrayErase(this.m_queue, 0);

        this.m_mdvController.AddReceivedMessage(NCA.Labels().T(line));

        if ArraySize(this.m_queue) == 0 {
		    this.m_mdvController.StopDotsAnimation();
            this.RenderReplyOptions();
            return;
        };
        
        this.m_mdvController.GetDelaySystem().DelayCallback(ConversationMessageDelayCallback.Create(this), this.CalculateTypingDuration(), false);
    }

    private func CalculateTypingDuration() -> Float {
        let textStr: String = NameToString(this.m_queue[0]);
        let charCount: Int32 = StrLen(textStr);
        let secondsPerChar: Float = 0.0225;
        let baseDelay: Float = 1.5;
        
        return Cast<Float>(charCount) * secondsPerChar + baseDelay;
    }

    protected abstract func ResolveEffect(effect: CName) -> Void;

    private func RenderReplyOptions() -> Void {
        if Equals(this.GetCurrentNode(), n"end") {
            this.OnEnd();
            return;
        }

        let node = this.FindNode(this.GetCurrentNode());
        let i: Int32 = 0;
        while i < ArraySize(node.responses) {
            this.m_mdvController.AddReplyOption(i, NCA.Labels().T(node.responses[i].text), false, i == 0);
            i += 1;
        };

        if i == 0 {
            this.OnEnd();
        }
    }

    private func FindNode(id: CName) -> ConversationNode {
        let nodes = this.GetNodes();
        let i: Int32 = 0;
        while i < ArraySize(nodes) {
            if Equals(nodes[i].id, id) {
                return nodes[i];
            };
            i += 1;
        };
        //NCA.CETLog("ERROR: Conversation node not found: " + NameToString(id));
    }
}
