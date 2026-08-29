module NightCityAllies.Npc

import NightCityAllies.*

public struct SquadDamageStats {
    public let name: String;
    public let totalDamage: Float;
    public let lastHitDamage: Float;
    public let dps: Float;
    public let hits: Int32;
    public let damageByType: array<Float>;
}

public class DamageTrackerSystem extends ScriptableSystem {
    private let m_combatActive: Bool;
    private let m_startTime: Float;

    private let m_stats: array<SquadDamageStats>;

    public func StartCombat() -> Void {
        this.m_combatActive = true;
        this.m_startTime = EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
        ArrayClear(this.m_stats);
        //NCA.CETLog("Squad combat started");
    }

    public func StopCombat() -> Void {
        if !this.m_combatActive {
            return;
        }
        this.m_combatActive = false;
        //this.PrintSummary();
    }

    public func RecordHit(npc: ref<NpcHandle>, evt: ref<gameHitEvent>) -> Void {
        if !this.m_combatActive {
            return;
        }

        let damage: Float = this.GetDamage(evt);
        if damage <= 0.0 {
            return;
        }

        let statsId: Int32 = this.GetOrCreateStats(npc.GetName());
        this.m_stats[statsId].totalDamage += damage;
        this.m_stats[statsId].lastHitDamage = damage;
        this.m_stats[statsId].dps = this.m_stats[statsId].totalDamage / this.GetCombatDuration();
        this.m_stats[statsId].hits += 1;
    }

    public func GetDamage(evt: ref<gameHitEvent>) -> Float {
        let totalDamage: Float = 0.0;
        let i: Int32 = 0;
        if IsDefined(evt.attackComputed) {
            while i < 4 {
                totalDamage += evt.attackComputed.GetAttackValue(IntEnum<gamedataDamageType>(i));
                i += 1;
            };
        }
        return totalDamage;
    }

    public func GetTotalSquadDamage() -> Float {
        let total: Float = 0.0;
        let i: Int32 = 0;
        while i < ArraySize(this.m_stats) {
            total += this.m_stats[i].totalDamage;
            i += 1;
        }
        return total;
    }

    public func GetStats(npc: ref<NpcHandle>) -> SquadDamageStats {
        return this.m_stats[this.GetOrCreateStats(npc.GetName())];
    }

    private func GetOrCreateStats(name: String) -> Int32 {
        let i: Int32 = 0;

        while i < ArraySize(this.m_stats) {
            if Equals(this.m_stats[i].name, name) {
                return i;
            }
            i += 1;
        }

        let stats: SquadDamageStats;
        stats.name = name;
        stats.totalDamage = 0.0;
        stats.dps = 0.0;
        stats.hits = 0;

        ArrayPush(this.m_stats, stats);
        return ArraySize(this.m_stats) - 1;
    }

    private func GetCombatDuration() -> Float {
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
        return MaxF(0.1, now - this.m_startTime);
    }

    private func PrintSummary() -> Void {
        let duration: Float = this.GetCombatDuration();
        let totalSquadDamage: Float = 0.0;

        let i: Int32 = 0;

        NCA.CETLog("----- Combat Summary -----");
        while i < ArraySize(this.m_stats) {
            let stats: SquadDamageStats = this.m_stats[i];
            let dps: Float = stats.totalDamage / duration;
            totalSquadDamage += stats.totalDamage;
            NCA.CETLog(
                stats.name +
                " | Damage: " + ToString(stats.totalDamage) +
                " | DPS: " + ToString(dps)
            );
            i += 1;
        }
        NCA.CETLog("--------------------------");
        NCA.CETLog("Squad Damage: " + ToString(totalSquadDamage));
        NCA.CETLog("Squad DPS: " + ToString(totalSquadDamage / duration));
    }
}