module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAJoinSquadEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Join_me();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.HandshakeIcon";
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsStandby();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        npc.JoinSquad();
    }
}
