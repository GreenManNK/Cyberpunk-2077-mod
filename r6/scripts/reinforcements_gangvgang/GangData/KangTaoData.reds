module Gibbon.GR.GangData


public class GRKangTaoData extends GRGangData {
	public func GetReinforcements(heat: Int32) -> array<TweakDBID> {
        switch (heat) {
            case 1: // 1 weak car
                let ww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad1",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad2",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad3"
                    ], 1);
                return ww;
            case 2: // 1 weak car
                let ww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad1",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad2",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad3"
                    ], 1);
                return ww;
            case 3: // 1 weak/normal car
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 1);
                return nw;
            case 4: // 2 weak cars
                let ww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad1",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad2",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad3"
                    ], 2);
                return ww;
            case 5: // 1 weak car, 1 weak/normal car
                let ww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad1",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad2",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad3"
                    ], 1);

                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 1);

                return ArrayMerge(ww, nw);
            case 6: // 2 weak/normal cars
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 2);
                return nw;
            case 7: // 1 weak/normal car, 1 rare car
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 1);

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                return ArrayMerge(nw, rn);
            case 8: // 2 rare cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 2);
                return rn;
            case 9: // 1 weak car, 2 rare cars
                let ww = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad1",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad2",
                        t"DynamicSpawnSystem.GRKangTaoWeakSquad3"
                    ], 1);

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 2);

                return ArrayMerge(ww, rn);
            case 10: // 1 weak/normal car, 1 rare car, 1 elite car
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 1);

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 1);

                return ArrayMerge(ArrayMerge(nw, rn), er);
            case 11: // 2 rare cars, 1 elite car
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 2);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 1);

                return ArrayMerge(rn, er);
            case 12: // 1 rare car, 2 elite cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 2);

                return ArrayMerge(rn, er);
            case 13: // 3 rare cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 3);
                return rn;
            case 14: // 1 weak/normal car, 3 rare cars
                let nw = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad1",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad2",
                        t"DynamicSpawnSystem.GRKangTaoNormalSquad3"
                    ], 1);

                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 3);

                return ArrayMerge(nw, rn);
            case 15: // 1 rare car, 2 elite cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 2);

                return ArrayMerge(rn, er);
            case 16: // 3 elite cars
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 3);
                return er;
            case 17: // 1 rare car, 3 elite cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 3);

                return ArrayMerge(rn, er);
            case 18: // 2 rare cars, 3 elite cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 2);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 3);

                return ArrayMerge(rn, er);
            case 19: // 4 elite cars
                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 4);
                return er;
            case 20: // 1 rare car, 4 elite cars
                let rn = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoRareSquad1",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad2",
                        t"DynamicSpawnSystem.GRKangTaoRareSquad3"
                    ], 1);

                let er = GetRandomFrom(
                    [
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad1",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad2",
                        t"DynamicSpawnSystem.GRKangTaoEliteSquad3"
                    ], 4);

                return ArrayMerge(rn, er);
            default:
                return [];
        }
    }
}
