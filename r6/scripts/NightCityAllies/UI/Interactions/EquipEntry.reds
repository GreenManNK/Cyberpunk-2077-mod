module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

// Root of: outfit, wardrobe, weapon
public class NCAEquipEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Equip();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.OpenWardrobeIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.Blueline;
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsSquad();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        let entries: array<ref<NCAInteractionEntry>>;
        ArrayPush(entries, new NCAOutfitEntry());
        ArrayPush(entries, new NCAWardrobeEntry());
        ArrayPush(entries, new NCAWeaponEntry());

        menu.OpenPage(npc.GetName(), entries);
    }
}
