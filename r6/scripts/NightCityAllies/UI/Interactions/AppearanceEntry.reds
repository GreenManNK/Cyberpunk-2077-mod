module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*

public class NCAAppearanceEntry extends NCAInteractionEntry {
    public let tag: CName;

    private let m_appearances: array<entTemplateAppearance>;

    public static func Create(tag: CName) -> ref<NCAAppearanceEntry> {
        let entry = new NCAAppearanceEntry();
        entry.tag = tag;
        return entry;
    }

    public func GetRowCount(npc: ref<NpcHandle>) -> Int32 {
        this.m_appearances = npc.GetAppearances();

        return ArraySize(this.m_appearances);
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        if index < 0 || index >= ArraySize(this.m_appearances) {
            return "";
        }

        return NameToString(this.m_appearances[index].name);
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.ClothesIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        if index == this.GetSelected(npc) {
            return gameinteractionsChoiceType.AlreadyRead;
        }

        return gameinteractionsChoiceType.QuestImportant;
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        if index < 0 || index >= ArraySize(this.m_appearances) {
            return;
        }

        if Equals(this.tag, n"") {
            npc.ChangeAppearance(index);
        } else {
            npc.SetOutfitForTag(this.tag, index);
        }
    }

    private func GetSelected(npc: ref<NpcHandle>) -> Int32 {
        if Equals(this.tag, n"") {
            return npc.GetSelectedAppearance();
        }

        return npc.GetOutfitForTag(this.tag);
    }
}
