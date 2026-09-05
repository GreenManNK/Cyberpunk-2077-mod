module NightCityAllies.Metadata

import NightCityAllies.*

public class CompanionMetadata {
    public let recordID: TweakDBID;
    public let rarity: gamedataNPCRarity;
    public let rarityValue: Float;
    public let archetype: gamedataArchetypeType;
    public let archetypeName: CName;
    public let characterType: gamedataNPCType;
    public let affiliation: TweakDBID;
    public let affiliationName: String;
    public let affiliationIcon: CName;
    public let isCrowd: Bool;
    public let isLightCrowd: Bool;
    public let isChild: Bool;
    public let isValidRecord: Bool;

// ============================================ Filled in later ========================================================

    public let entityTemplatePath: ResRef;
    public let appearances: array<entTemplateAppearance>;
    public let rig: String; // eg. base\characters\base_entities\man_base\man_base.rig

    public func TakeAppearances(template: ref<entEntityTemplate>) -> Void {
        if IsDefined(template) {
            this.appearances = template.appearances;
        }
    }

    public func TakeRig(rig: String) -> Void {
        if IsStringValid(rig) {
            this.rig = rig;
        }
    }

    public func HasAppearances() -> Bool {
        return ArraySize(this.appearances) > 0;
    }

    public static func Create(recordID: TweakDBID) -> ref<CompanionMetadata> {
        let metadata = new CompanionMetadata();
        metadata.recordID = recordID;

        let record: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(recordID);
        if !IsDefined(record) {
            metadata.rarity = gamedataNPCRarity.Invalid;
            metadata.archetype = gamedataArchetypeType.Invalid;
            metadata.characterType = gamedataNPCType.Invalid;
            return metadata;
        }

        metadata.isValidRecord = true;
        metadata.archetypeName = record.ArchetypeName();
        metadata.entityTemplatePath = record.EntityTemplatePath();

        metadata.isCrowd = record.IsCrowd();
        metadata.isLightCrowd = record.IsLightCrowd();
        metadata.isChild = record.IsChild();

        metadata.rarity = gamedataNPCRarity.Invalid;
        let rarity: wref<NPCRarity_Record> = record.Rarity();
        if IsDefined(rarity) {
            metadata.rarity = rarity.Type();
            metadata.rarityValue = rarity.RarityValue();
        }

        // (orphans.swift:26822, :34912).
        metadata.archetype = gamedataArchetypeType.Invalid;
        let archetype: wref<ArchetypeData_Record> = record.ArchetypeData();
        if IsDefined(archetype) && IsDefined(archetype.Type()) {
            metadata.archetype = archetype.Type().Type();
        }

        metadata.characterType = gamedataNPCType.Invalid;
        let characterType: wref<NPCType_Record> = record.CharacterType();
        if IsDefined(characterType) {
            metadata.characterType = characterType.Type();
        }

        let affiliation: wref<Affiliation_Record> = record.Affiliation();
        if IsDefined(affiliation) {
            metadata.affiliation = affiliation.GetID();
            metadata.affiliationIcon = affiliation.IconPath();

            let localized: String = GetLocalizedTextByKey(affiliation.LocalizedName());
            metadata.affiliationName = IsStringValid(localized)
                ? localized
                : NameToString(affiliation.EnumName());
        }

        return metadata;
    }
}
