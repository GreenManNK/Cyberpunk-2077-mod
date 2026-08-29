module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAOutfitEntry extends NCAInteractionEntry {
    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Outfit();
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.ClothesIcon";
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsSquad() && !npc.IsMech();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        let entries: array<ref<NCAInteractionEntry>>;
        ArrayPush(entries, NCAAppearanceEntry.Create(n""));

        menu.OpenPage(npc.GetName() + "s " + NCA.Labels().Outfits(), entries);
    }
}
