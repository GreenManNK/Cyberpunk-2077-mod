module NightCityAllies.Spawn

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Phone.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*


public abstract class SpawnRule {
    protected let m_locationTag: CName;

    public abstract func CheckSpawnCondition(
        companion: CompanionModData,
        location: ref<NCALocation>,
        point: ref<NCASpawn>
    ) -> Float;

    // Human readable summary, the same idea as NCALocationTrigger.Describe: the editor reads rules
    // back as these rather than reaching into the private fields of each subclass.
    public func Describe() -> String;

    public func GetLocationTag() -> CName {
        return this.m_locationTag;
    }

    // A rule keeps its own copy of the tag rather than a reference to the location, so a rename has
    // to be followed here too - see LocationSystem.RenameLocation.
    public func Retag(newTag: CName) -> Void {
        this.m_locationTag = newTag;
    }
}

public class AffiliationSpawnRule extends SpawnRule {
    private let m_affiliation: TweakDBID;
    private let m_spawnChance: Float;

    public static func Create(affiliation: TweakDBID, spawnChance: Float, locationTag: CName) -> ref<AffiliationSpawnRule> {
        let rule = new AffiliationSpawnRule();
        rule.m_affiliation = affiliation;
        rule.m_spawnChance = spawnChance;
        rule.m_locationTag = locationTag;
        return rule;
    }

    public func CheckSpawnCondition(companion: CompanionModData, location: ref<NCALocation>, point: ref<NCASpawn>) -> Float {
        let record = TweakDBInterface.GetCharacterRecord(companion.recordID);
        let affiliation: ref<Affiliation_Record> = record.Affiliation();

        if !Equals(location.tag, this.m_locationTag) || !Equals(affiliation.GetID(), this.m_affiliation) {
            return 1.0;
        }

        return this.m_spawnChance;
    }

    public func Describe() -> String {
        return "affiliation:" + TDBID.ToStringDEBUG(this.m_affiliation) + ","
            + FloatToString(this.m_spawnChance);
    }
}

public class NotAffiliationSpawnRule extends SpawnRule {
    private let m_affiliation: TweakDBID;
    private let m_spawnChance: Float;

    public static func Create(affiliation: TweakDBID, spawnChance: Float, locationTag: CName) -> ref<NotAffiliationSpawnRule> {
        let rule = new NotAffiliationSpawnRule();
        rule.m_affiliation = affiliation;
        rule.m_spawnChance = spawnChance;
        rule.m_locationTag = locationTag;
        return rule;
    }

    public func CheckSpawnCondition(companion: CompanionModData, location: ref<NCALocation>, point: ref<NCASpawn>) -> Float {
        let record = TweakDBInterface.GetCharacterRecord(companion.recordID);
        let affiliation: ref<Affiliation_Record> = record.Affiliation();

        if !Equals(location.tag, this.m_locationTag) || Equals(affiliation.GetID(), this.m_affiliation) {
            return 1.0;
        }

        return this.m_spawnChance;
    }

    public func Describe() -> String {
        return "notaffiliation:" + TDBID.ToStringDEBUG(this.m_affiliation) + ","
            + FloatToString(this.m_spawnChance);
    }
}

// Manages random spawn encounters
public class SpawnSystem extends ScriptableSystem {
    private let m_spawnRules: array<ref<SpawnRule>>;

    public func RegisterSpawnRule(rule: ref<SpawnRule>) -> Void {
        ArrayPush(this.m_spawnRules, rule);
    }

    public func RegisterAffiliationSpawnRule(locationTag: CName, affiliation: TweakDBID, spawnChance: Float) -> Void {
        //NCA.CETLog("Registering affiliation spawn rule for location " + NameToString(locationTag) + " and affiliation " + TDBID.ToStringDEBUG(affiliation) + " with spawn chance " + ToString(spawnChance));
        this.RegisterSpawnRule(AffiliationSpawnRule.Create(affiliation, spawnChance, locationTag));
    }

    public func RegisterNotAffiliationSpawnRule(locationTag: CName, affiliation: TweakDBID, spawnChance: Float) -> Void {
        //NCA.CETLog("Registering not affiliation spawn rule for location " + NameToString(locationTag) + " and affiliation " + TDBID.ToStringDEBUG(affiliation) + " with spawn chance " + ToString(spawnChance));
        this.RegisterSpawnRule(NotAffiliationSpawnRule.Create(affiliation, spawnChance, locationTag));
    }

    // --- Editor support ---------------------------------------------------------------------
    // Registration only appends here too, so the editor reads the rules for a location back as
    // descriptions, clears them, and registers its working copy.

    public func GetSpawnRuleDescriptionsString(locationTag: String) -> array<String> {
        return this.GetSpawnRuleDescriptions(StringToName(locationTag));
    }

    public func GetSpawnRuleDescriptions(locationTag: CName) -> array<String> {
        let result: array<String>;
        let i: Int32 = 0;
        while i < ArraySize(this.m_spawnRules) {
            if Equals(this.m_spawnRules[i].GetLocationTag(), locationTag) {
                ArrayPush(result, this.m_spawnRules[i].Describe());
            }
            i += 1;
        }
        return result;
    }

    public func ClearSpawnRulesString(locationTag: String) -> Void {
        this.ClearSpawnRules(StringToName(locationTag));
    }

    // Walked backwards so erasing one does not skip the next.
    public func ClearSpawnRules(locationTag: CName) -> Void {
        let i: Int32 = ArraySize(this.m_spawnRules) - 1;
        while i >= 0 {
            if Equals(this.m_spawnRules[i].GetLocationTag(), locationTag) {
                ArrayErase(this.m_spawnRules, i);
            }
            i -= 1;
        }
    }

    // Called by LocationSystem.RenameLocation. Rules hold a copy of the tag, not a reference to the
    // location, so without this every rule for a renamed location silently stops matching.
    public func RetagSpawnRules(oldTag: CName, newTag: CName) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_spawnRules) {
            if Equals(this.m_spawnRules[i].GetLocationTag(), oldTag) {
                this.m_spawnRules[i].Retag(newTag);
            }
            i += 1;
        }
    }

    // Randomized the "current location" stored for each companion that is not already acquired
    public func Reroll() -> Void {
         //  TODO only rerolls merc spawns curerently. add logic for roaming characters
        NCA.Persistence().ClearUnacquiredSpawnLocations();
        let pool: array<CompanionModData> = NCA.Persistence().GetCompanionsBySpawnState(CompanionSpawnState.Unacquired);

        let locIndex: Int32 = 0;
        let pointIndex: Int32;
        let randIndex: Int32;
        let candidate: CompanionModData;
        let score: Float;

        let attempts: Int32;
        let maxAttempts: Int32 = 4;

        let minSpawnScore: Float = 0.001;
        while locIndex < ArraySize(NCA.Location().locations) {
            let location: ref<NCALocation> = NCA.Location().locations[locIndex];
            let spawns: array<ref<NCASpawn>> = location.GetSpawns();
            pointIndex = 0;
            while pointIndex < ArraySize(spawns) {
                if ArraySize(pool) == 0 {
                    break;
                };
                let spawn: ref<NCASpawn> = spawns[pointIndex];
                attempts = 0;
                while attempts < maxAttempts && ArraySize(pool) > 0 {
                    randIndex = RandRange(0, ArraySize(pool));
                    candidate = pool[randIndex];
                    
                    score = this.CheckSpawnCondition(candidate, location, spawn);
                    if score >= minSpawnScore {
                        NCA.Persistence().AssignSpawnLocation(candidate.recordID, location.tag, spawn.tag);
                        //spawn.SetNPC(candidate.recordID); // removed after resolving spread out spawn logic
                        ArrayErase(pool, randIndex);
                        break;
                    };
                    attempts += 1;
                };
                //if score < minSpawnScore {
                    //spawn.UnsetNPC();
                //};
                pointIndex += 1;
            };
            locIndex += 1;
        };
    }

    private func CheckSpawnCondition(companion: CompanionModData, location: ref<NCALocation>, point: ref<NCASpawn>) -> Float {
        // Spawntables
        let value = RandF(); // 0.0 - 1.0
        if value < 1.0 - (this.GetSpawnProbabilityPercent(companion.rarity) / 100.0) {
            return 0.0;
        }

        let i: Int32 = 0;
        while i < ArraySize(this.m_spawnRules) {
            let rule: ref<SpawnRule> = this.m_spawnRules[i];
            value = value * rule.CheckSpawnCondition(companion, location, point);
            i += 1;
        }

        return value;
    }

    private func GetSpawnProbabilityPercent(rarity: CompanionRarity) -> Float {
        switch (rarity) {
            case CompanionRarity.Common: return 60.0;
            case CompanionRarity.Rare: return 25.0;
            case CompanionRarity.Elite: return 10.0;
            case CompanionRarity.Legendary: return 1.5;
            case CompanionRarity.Special: return 0.0;
        }
    }
}
