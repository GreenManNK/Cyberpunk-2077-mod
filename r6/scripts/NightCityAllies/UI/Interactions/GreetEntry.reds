module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAGreetEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Greet();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.TalkIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.Blueline;
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return !npc.IsMech() && (npc.IsSquad() || npc.IsAcquirable());
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        npc.Talk();
        npc.AddFriendship(5);
    }
}
