module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Animation.*

public class NCARoutineEntry extends NCAInteractionEntry {
    private let m_routines: array<ref<NCARoutine>>;

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return !npc.IsMech() && (npc.IsSquad() || npc.IsStandby());
    }

    public func GetRowCount(npc: ref<NpcHandle>) -> Int32 {
        this.m_routines = npc.GetRoutineOptions();

        return ArraySize(this.m_routines);
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        if index < 0 || index >= ArraySize(this.m_routines) {
            return "";
        }

        let routine: ref<NCARoutine> = this.m_routines[index];
        let label: String = NameToString(routine.label);

        if Equals(label, "") || Equals(label, "None") {
            return NameToString(routine.tag);
        }

        return label;
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        if index < 0 || index >= ArraySize(this.m_routines) {
            return t"ChoiceCaptionParts.DanceIcon";
        }

        let icon: String = this.m_routines[index].icon;

        if Equals(icon, "") {
            return t"ChoiceCaptionParts.DanceIcon";
        }

        return TDBID.Create(icon);
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.Blueline;
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        if index < 0 || index >= ArraySize(this.m_routines) {
            return;
        }

        npc.PlayRoutine(this.m_routines[index]);
    }
}
