module Gibbon.GR.GangData


public class GRAldecaldosData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> {
        switch (heat) {
            case 1: // 1 weak (bike)
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);
            case 2: // 2 weak
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad2"
                    ], 1);
            case 3: // 3 weak (weak squad + bike)
                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad2"
                    ], 1);

                let bike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);

                return ArrayMerge(weakSquad, bike);
            case 4: // 4 normal
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad3"
                    ], 1);
            case 5: // 4 normal, 1 weak (normal squad + bike)
                let normalSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad3"
                    ], 1);

                let bike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);

                return ArrayMerge(normalSquad, bike);
            case 6: // 4 normal, 2 weak (normal squad + weak squad)
                let normalSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad3"
                    ], 1);

                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad2"
                    ], 1);

                return ArrayMerge(normalSquad, weakSquad);
            case 7: // 2 rare, 1 weak (rare squad + bike)
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 1);

                let bike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);

                return ArrayMerge(rareSquad, bike);
            case 8: // 2 rare, 2 weak (rare squad + weak squad)
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 1);

                let weakSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakSquad2"
                    ], 1);

                return ArrayMerge(rareSquad, weakSquad);
            case 9: // 4 rare (2x rare squad)
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 2);
            case 10: // 4 rare, 4 normal (2x rare squad + normal squad)
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 2);

                let normalSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosNormalSquad3"
                    ], 1);

                return ArrayMerge(rareSquad, normalSquad);
            case 11: // 4 rare, 1 weak (2x rare squad + bike)
                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 2);

                let bike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);

                return ArrayMerge(rareSquad, bike);
            case 12: // 1 elite van (4 elite/rare mix)
                return [t"DynamicSpawnSystem.GRAldecaldosEliteVan1"];
            case 13: // 1 elite van, 1 weak
                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 1);

                let bike = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike1",
                        t"DynamicSpawnSystem.GRAldecaldosWeakBike2"
                    ], 1);

                return ArrayMerge(eliteVan, bike);
            case 14: // 1 elite van, 2 rare
                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 1);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 1);

                return ArrayMerge(eliteVan, rareSquad);
            case 15: // 1 elite van, 2 elite (van + elite squad)
                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 1);

                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 1);

                return ArrayMerge(eliteVan, eliteSquad);
            case 16: // 4 elite (2x elite squad)
                return GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 2);
            case 17: // 4 elite, 2 rare (2x elite squad + rare squad)
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 2);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 1);

                return ArrayMerge(eliteSquad, rareSquad);
            case 18: // 4 elite, 1 elite van
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 2);

                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 1);

                return ArrayMerge(eliteSquad, eliteVan);
            case 19: // 4 elite, 1 elite van, 2 rare
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 2);

                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 1);

                let rareSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosRareSquad4"
                    ], 1);

                return ArrayMerge(ArrayMerge(eliteSquad, eliteVan), rareSquad);
            case 20: // full convoy: 2x elite squad, 2x elite van
                let eliteSquad = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad2",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad3",
                        t"DynamicSpawnSystem.GRAldecaldosEliteSquad4"
                    ], 2);

                let eliteVan = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan1",
                        t"DynamicSpawnSystem.GRAldecaldosEliteVan2"
                    ], 2);

                return ArrayMerge(eliteSquad, eliteVan);
            default:
                return [];
        }
    }
}
