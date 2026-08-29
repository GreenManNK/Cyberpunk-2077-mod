module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*

public abstract class NCAInteractionEntry {
    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return true;
    }

    public func GetRowCount(npc: ref<NpcHandle>) -> Int32 {
        return 1;
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return "";
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.None";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.QuestImportant;
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void;
}
