module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCASendAwayEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Send_away();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.GetInIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.AlreadyRead;
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsSquad() || npc.IsStandby();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        npc.Dismiss();
    }
}
