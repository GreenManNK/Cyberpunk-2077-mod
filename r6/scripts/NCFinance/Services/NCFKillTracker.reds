// -----------------------------------------------------------------------------
// NCFKillTracker
// -----------------------------------------------------------------------------
//
// - Tracks the EngineTime of the last hit V dealt to any puppet. Used by
//   NCFNotificationService to suppress popups within 10s of any offensive
//   action (the cooldown window runs from the LAST hit V dealt).
// - Replaces the v1.0.18-v1.0.20 approach of reading PlayerStateMachine.Combat
//   directly. That blackboard only flips to InCombat=1 when an enemy is
//   AWARE of and AGGRESSIVE toward V — so stealth kills, sniper kills from
//   concealment, and quickhack kills register as OutOfCombat from the
//   player's perspective and bypass the gate.
// - Earlier death-event wraps (NPCPuppet.OnDeath, ScriptedPuppet.OnDeath,
//   ScriptedPuppet.HandleDeath) caught only some kill paths — quickhack
//   kills, status-effect deaths, and indirect kills (chain explosions,
//   vehicle hits) often skip those paths entirely. ScriptedPuppet.OnHit
//   fires on every shot/strike/quickhack/grenade/DoT tick uniformly and
//   is the most reliable "V is engaged" signal available in script.
// - The blackboard combat signal is still kept as a secondary catch in
//   NCFNotificationService (covers V being shot at without yet retaliating).
//

module NightCityFinance.Services

import NightCityFinance.Logging.*

public class NCFKillTracker extends ScriptableSystem {
    private let lastKillTime: Float = 0.0;

    public final static func GetInstance(gameInstance: GameInstance) -> ref<NCFKillTracker> {
        return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"NightCityFinance.Services.NCFKillTracker") as NCFKillTracker;
    }

    public final static func Get() -> ref<NCFKillTracker> {
        return NCFKillTracker.GetInstance(GetGameInstance());
    }

    public final func StampKill() -> Void {
        this.lastKillTime = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
    }

    // Returns seconds since the last player-caused kill, or a very large
    // number if no kill has been recorded this session. Sentinel-safe:
    // unset (0.0) returns a large value because EngineTime is monotonic.
    public final func SecondsSinceLastKill() -> Float {
        if this.lastKillTime <= 0.0 { return 99999.0; }
        let now: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
        return now - this.lastKillTime;
    }
}

// Wrap ScriptedPuppet.OnHit. Fires on EVERY hit a puppet receives —
// shots, melee, quickhacks, grenades, explosions, DoT ticks. Catches kills
// too, because every kill is preceded by a hit. This is the most reliable
// "V is engaged" signal we have, far more than death events.
//
// v1.0.27 reasoning: in-game probes showed the previous OnDeath/HandleDeath
// wraps fired only on some kills. Quickhack kills, status-effect deaths,
// and indirect kills (chain explosions, vehicle hits) often skip the
// OnDeath path. OnHit catches them all because they all start with a hit.
// Stamping on every hit (not just kills) also means the cooldown window
// runs from the LAST hit V dealt, not the kill itself — perfect for the
// "10s past combat" requirement.
@wrapMethod(ScriptedPuppet)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let result: Bool = wrappedMethod(evt);

    if IsDefined(evt) && IsDefined(evt.attackData) {
        let instigator: wref<GameObject> = evt.attackData.GetInstigator();
        if IsDefined(instigator) {
            let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
            if IsDefined(player) && Equals(instigator.GetEntityID(), player.GetEntityID()) {
                let tracker: ref<NCFKillTracker> = NCFKillTracker.Get();
                if IsDefined(tracker) {
                    tracker.StampKill();
                }
            }
        }
    }

    return result;
}
