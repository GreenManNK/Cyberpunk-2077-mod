module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAWeaponActionEntry extends NCAInteractionEntry {
    public let action: Int32;

    public static func Create(action: Int32) -> ref<NCAWeaponActionEntry> {
        let entry = new NCAWeaponActionEntry();
        entry.action = action;
        return entry;
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        switch this.action {
            case 0: return NCA.Labels().Equip_primary();
            case 1: return NCA.Labels().Equip_secondary();
            case 2: return NCA.Labels().Stow_weapon();
        }

        return "";
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        if this.action == 2 {
            return t"ChoiceCaptionParts.HideWeaponIcon";
        }

        return t"ChoiceCaptionParts.GunIcon";
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        switch this.action {
            case 0:
                npc.EquipPrimaryWeapon();
                break;
            case 1:
                npc.EquipSecondaryWeapon();
                break;
            case 2:
                npc.UnEquipWeapon();
                break;
        }
    }
}
