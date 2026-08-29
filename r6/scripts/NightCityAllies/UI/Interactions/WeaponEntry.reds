module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAWeaponEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Weapon();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.DrawWeaponIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.Blueline;
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsSquad() && !npc.IsMech();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        let entries: array<ref<NCAInteractionEntry>>;
        ArrayPush(entries, NCAWeaponActionEntry.Create(0));
        ArrayPush(entries, NCAWeaponActionEntry.Create(1));
        ArrayPush(entries, NCAWeaponActionEntry.Create(2));

        menu.OpenPage(npc.GetName() + "s " + NCA.Labels().Gear(), entries);
    }
}
