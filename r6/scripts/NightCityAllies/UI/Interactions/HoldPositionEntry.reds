module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Persistence.*
import NightCityAllies.Localization.*

public class NCAHoldPositionEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Wait_here();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.Solo";
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsFollowing() && npc.IsSquad() && !NCA.Context().IsInLocation();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        npc.HoldPosition();
    }
}
