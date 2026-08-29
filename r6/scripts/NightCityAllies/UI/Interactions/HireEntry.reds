module NightCityAllies.UI.Interactions

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*
import NightCityAllies.Localization.*

public class NCAHireEntry extends NCAInteractionEntry {
    public static func GetPlayerMoney() -> Int32 {
        return GameInstance.GetTransactionSystem(GetGameInstance())
            .GetItemQuantity(GetPlayer(GetGameInstance()), ItemID.FromTDBID(t"Items.money"));
    }

    public static func CanAfford(npc: ref<NpcHandle>) -> Bool {
        return NCAHireEntry.GetPlayerMoney() >= Cast<Int32>(npc.GetPrice());
    }

    public func GetLabel(npc: ref<NpcHandle>, index: Int32) -> String {
        return NCA.Labels().Hire() + " (" + IntToString(Cast<Int32>(npc.GetPrice())) + ")";
    }

    public func GetIcon(npc: ref<NpcHandle>, index: Int32) -> TweakDBID {
        return t"ChoiceCaptionParts.PayIcon";
    }

    public func GetChoiceType(npc: ref<NpcHandle>, index: Int32) -> gameinteractionsChoiceType {
        if NCAHireEntry.CanAfford(npc) {
            return gameinteractionsChoiceType.QuestImportant;
        }

        return gameinteractionsChoiceType.AlreadyRead;
    }

    public func IsAvailable(npc: ref<NpcHandle>) -> Bool {
        return npc.IsAcquirable();
    }

    public func Run(npc: ref<NpcHandle>, index: Int32, menu: ref<NCAInteractionMenu>) -> Void {
        if !NCAHireEntry.CanAfford(npc) {
            npc.Talk(n"bump");
            return;
        }

        GameInstance.GetTransactionSystem(GetGameInstance())
            .RemoveItem(GetPlayer(GetGameInstance()), ItemID.FromTDBID(t"Items.money"), Cast<Int32>(npc.GetPrice()));

        npc.Talk();
        npc.Acquire();
    }
}
