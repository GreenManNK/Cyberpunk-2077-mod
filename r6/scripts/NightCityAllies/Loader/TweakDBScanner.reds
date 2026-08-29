module NightCityAllies.Loader

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.UI.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.Hooks.*
import NightCityAllies.Phone.*

public struct CharacterMetadata {
    public let name: CName;
    public let recordID: TweakDBID;
    public let affiliation: ref<Affiliation_Record>;
    public let affiliationName: CName;
    public let canFight: Bool;
    public let isAfterlifeMerc: Bool;
    public let isMox: Bool;
    public let isMaelstrom: Bool;
    public let archetypeName: CName;
    public let equipmentCount: Int32;
}
// WIP -> TODO use analyze in validation
public class TweakDBScanner extends ScriptableSystem {
    public func CanShootRec() -> wref<GameplayAbility_Record> = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanShoot")
    public func CanMeleeRec() -> wref<GameplayAbility_Record> = TweakDBInterface.GetGameplayAbilityRecord(t"Ability.CanCloseCombat")

    public func ProcessBatch(ids: array<TweakDBID>) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(ids) {
            let record = TweakDBInterface.GetCharacterRecord(ids[i]);
            let id: TweakDBID = ids[i];
            if IsDefined(record) && !(record.IsCrowd() || record.IsLightCrowd() || record.IsChild()) {
               let metadata = this.AnalyzeRecord(ids[i]);
                if (metadata.isAfterlifeMerc && metadata.canFight) {
                    this.DumpMetadata(metadata);
                    //NCA.Persistence().RegisterCharacter(metadata.recordID, NameToString(metadata.name));
                }   
            }
            i += 1;
        }
    }

    public func AnalyzeRecord(id: TweakDBID) -> CharacterMetadata {
        let record = TweakDBInterface.GetCharacterRecord(id);
        let affiliation: ref<Affiliation_Record> = record.Affiliation();
        let isAfterlifeMerc: Bool = Equals(affiliation.GetID(), t"Factions.AfterlifeMercs");
        let isMox: Bool = Equals(affiliation.GetID(), t"Factions.TheMox");
        let isMaelstrom: Bool = Equals(affiliation.GetID(), t"Factions.Maelstrom");
        let canFight: Bool = record.AbilitiesContains(this.CanShootRec()) || record.AbilitiesContains(this.CanMeleeRec()); // todo this method call is so stupid

        //let abilities: array<wref<GameplayAbility_Record>>;
        //record.Abilities(abilities); 

        let primaryEquipment: ref<NPCEquipmentGroup_Record> = record.PrimaryEquipment();
        let equipmentGroupEntries: [wref<NPCEquipmentGroupEntry_Record>];
        primaryEquipment.EquipmentItems(equipmentGroupEntries);
        let equipmentCount: Int32 = primaryEquipment.GetEquipmentItemsCount();
        // TODO -> Equipment group -> Weapon Slot

        let i: Int32 = 0;
        let entry: wref<NPCEquipmentGroupEntry_Record>;
        while i < equipmentCount {
            entry = primaryEquipment.GetEquipmentItemsItem(i);
            if IsDefined(entry as NPCEquipmentItem_Record) {
                let itemRecord = entry as NPCEquipmentItem_Record;
                let item: wref<Item_Record> = itemRecord.Item();
                let itemType: wref<ItemType_Record> = item.ItemType();
                let typeName: CName = itemType.Name();
                let type: gamedataItemType = itemType.Type();
                //NCA.CETLog("Equipment item: " + item.LocalizedName() + "  type: " + NameToString(typeName) + " " + ToString(type));
            }
            i += 1;
        }

        return new CharacterMetadata(
            record.DisplayName(),//entity:GetTweakDBDisplayName(true) //idk 
            id,
            affiliation,
            affiliation.EnumName(),
            equipmentCount > 0,
            isAfterlifeMerc,
            isMox,
            isMaelstrom,
            record.ArchetypeName(),
            equipmentCount
        );
    }
    
    public func DumpMetadata(metadata: CharacterMetadata) {}
}
//local ids = {}; for _, r in ipairs(TweakDB:GetRecords("gamedataCharacter_Record")) do table.insert(ids, r:GetID()) end; Game.GetScriptableSystemsContainer():Get("NightCityAllies.Loader.TweakDBScanner"):ProcessBatch(ids)
