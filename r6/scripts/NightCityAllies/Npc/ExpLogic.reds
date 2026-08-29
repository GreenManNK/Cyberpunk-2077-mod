module NightCityAllies.Npc

import NightCityAllies.*

public class ExpLogic {
    private static func GetBaseXP() -> Float = 400.0;
    private static func GetGrowth() -> Float = 1.10;
    private static func GetOnHitExpRate() -> Float = 2.0;
    private static func GetSharedExpRate() -> Float = 30.0;

    public static func GetTotalExpForLevel(level: Int32) -> Int32 {
        if level <= 0 {
            return 0;
        }

        let base: Float = ExpLogic.GetBaseXP();
        let growth: Float = ExpLogic.GetGrowth();
        let lvl: Float = Cast<Float>(level);

        let total: Float = base * (PowF(growth, lvl) - 1.0) / (growth - 1.0);
        return FloorF(total);
    }

    public static func GetLevelFromExp(totalExp: Int32) -> Int32 {
        if totalExp <= 0 {
            return 0;
        }

        let base: Float = ExpLogic.GetBaseXP();
        let growth: Float = ExpLogic.GetGrowth();
        let exp: Float = Cast<Float>(totalExp);

        let inside: Float = (exp * (growth - 1.0) / base) + 1.0;
        let levelFloat: Float = LogF(inside) / LogF(growth);

        return FloorF(levelFloat);
    }

    public static func GetLevelProgress(totalExp: Int32) -> Float {
        let exp: Float = Cast<Float>(totalExp);

        let level: Int32 = ExpLogic.GetLevelFromExp(totalExp);
        let expStart: Float = Cast<Float>(ExpLogic.GetTotalExpForLevel(level));
        let expNext: Float = Cast<Float>(ExpLogic.GetTotalExpForLevel(level + 1));

        if expNext <= expStart {
            return 0.0;
        }

        return (exp - expStart) / (expNext - expStart);
    }
}