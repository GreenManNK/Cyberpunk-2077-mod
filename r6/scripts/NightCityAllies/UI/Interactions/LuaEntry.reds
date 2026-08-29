module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Event.*

public class NCALuaInteractionEntry extends NCAInteractionEntry {
    public let id: Int32;
    public let label: String;
    public let icon: TweakDBID;
    public let choiceType: gameinteractionsChoiceType;

    public static func Create(id: Int32, label: String, icon: TweakDBID, choiceType: gameinteractionsChoiceType) -> ref<NCALuaInteractionEntry> {
        let entry = new NCALuaInteractionEntry();
        entry.id = id;
        entry.label = label;
        entry.icon = icon;
        entry.choiceType = choiceType;
        return entry;
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return this.label;
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return this.icon;
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return this.choiceType;
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        NCA.Events().OnLuaInteractionSelected(npc, this.id);
    }
}
