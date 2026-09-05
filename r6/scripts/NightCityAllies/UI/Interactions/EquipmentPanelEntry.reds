module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

// Opens the companion equipment panel. The hub is hidden first: the panel is a blocking notification
// and vanilla's own popups refuse to show while another menu owns the screen
// (PopupsManager.CanShowExclusivePopUp).
public class NCAEquipmentPanelEntry extends NCAInteractionEntry {
    // Exactly the complement of the prompt's equipment key, so the panel is reachable one way or the
    // other and never both. That covers the prompt being off entirely as well as the key being turned
    // off.
    //
    // ...and never EITHER for a companion whose panel does not open. The way in has to disappear with
    // what it opens, which is why the same CanOpenEquipment is asked here and on the prompt side - see
    // NCAInteractionMenu.ShowsEquipmentButtonFor.
    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return !NCAInteractionMenu.ShowsEquipmentButton() && npc.CanOpenEquipment();
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Gear();
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        return gameinteractionsChoiceType.Blueline;
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.HiddenStashIcon"; //HiddenStashIcon DropBoxIcon LootIcon
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        // Opening the panel suppresses the menu, which hides it and keeps the companion held.
        // Calling HideHub here first clears the active NPC before suppression starts, dropping the
        // hold and collapsing their squad widget - they then walk away while the panel is open.
        NCA.UI().OpenEquipmentPanel(npc);
    }
}
