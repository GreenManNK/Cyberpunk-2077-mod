module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAEquipSecondaryWeaponEntry extends NCAInteractionEntry {
    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return !npc.IsMech();
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Equip_secondary();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.GunIcon";
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        npc.EquipSecondaryWeapon();
    }
}
