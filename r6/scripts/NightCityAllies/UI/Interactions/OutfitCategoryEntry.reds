module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAOutfitCategoryEntry extends NCAInteractionEntry {
    public static func GetTag(index: Int32) -> CName {
        switch index {
            case 0: return n"casual";
            case 1: return n"mission";
            case 2: return n"home";
            case 3: return n"shower";
            case 4: return n"bed";
        }

        return n"";
    }

    public func GetRowCount(npc: ref<NpcHandle>) -> Int32 {
        return 5;
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        switch index {
            case 0: return NCA.Labels().Casual();
            case 1: return NCA.Labels().Mission();
            case 2: return NCA.Labels().Home();
            case 3: return NCA.Labels().Shower();
            case 4: return NCA.Labels().Bed();
        }

        return "";
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        let entries: array<ref<NCAInteractionEntry>>;
        ArrayPush(entries, NCAAppearanceEntry.Create(NCAOutfitCategoryEntry.GetTag(index)));

        menu.OpenPage(npc.GetName() + "s " + NCA.Labels().Outfits(), entries);
    }
}
