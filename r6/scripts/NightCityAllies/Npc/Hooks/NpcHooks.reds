module NightCityAllies.Npc.Hooks

import NightCityAllies.*
import NightCityAllies.Event.*
import NightCityAllies.Npc.*

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    let npc: ref<NpcHandle>;
    if (NCA.NPC().FindByEntityID(this.GetEntityID(), npc)) {
        NCA.Events().OnCompanionDeath(npc);
    } else {
        return wrappedMethod(evt);
    }
}


@wrapMethod(ScriptedPuppet)
protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
    let result = wrappedMethod(evt);
    let hitEvent: ref<gameHitEvent> = evt.hitEvent;
    let attacker: wref<GameObject> = hitEvent.attackData.GetInstigator();

    let npc: ref<NpcHandle>;
    if (NCA.NPC().FindByEntityID(attacker.GetEntityID(), npc)) {
        NCA.Events().OnCompanionDealDamage(npc, hitEvent);
    }

    let target: wref<GameObject> = hitEvent.target;
    if (NCA.NPC().FindByEntityID(target.GetEntityID(), npc)) {
        NCA.Events().OnCompanionTakeDamage(npc, hitEvent);
    }

    return result;
}

// TODO move this .. somewhere
@wrapMethod(DamageSystem)
private final func ProcessRagdollHit(hitEvent: ref<gameHitEvent>) -> Void {
    wrappedMethod(hitEvent);
    let attacker: wref<GameObject> = hitEvent.attackData.GetInstigator();
    let npc: ref<NpcHandle>;
    if (NCA.NPC().FindByEntityID(attacker.GetEntityID(), npc)) {
	    let dmgType = hitEvent.attackComputed.GetDominatingDamageType();
        let x = Cast<Float>(npc.GetLevel()) / 100.0;
        // f(x) = 0.5 * 4^x
        // Da Redscript standardmäßig ExpF (e^x) nutzt, verwenden wir die Identität 4^x = e^(x * ln(4))
        // ln(4) ist gerundet 1.386294
        let multiplier: Float = 0.5 * ExpF(x * 1.386294);
        // 0.5 at lv0 -> 1.0 at lv 50 -> 2.0 at lv 100
        hitEvent.attackComputed.MultAttackValue(multiplier, dmgType);
        //NCA.CETLog("Applied multiplier: " + ToString(multiplier));
    }
    // TODO - defense
}

// ==================================================== Elevators ======================================================
// Lifts only ever enable the PLAYER half of their off-mesh link (LiftDevice.EnableOffMeshConnections),
// while doors enable both halves. Mirror the door behaviour so followers can path through a lift.
//@wrapMethod(LiftDevice)
//protected final func EnableOffMeshConnections() -> Void {
//    wrappedMethod();
//    if IsDefined(this.m_offMeshConnectionComponent) {
//        NCA.CETLog("Lift off-mesh: enabling NPC link");
//        this.m_offMeshConnectionComponent.EnableOffMeshConnection();
//    }
//}

//@wrapMethod(LiftDevice)
//protected final func DisableOffMeshConnections() -> Void {
//    wrappedMethod();
//    if IsDefined(this.m_offMeshConnectionComponent) {
//        this.m_offMeshConnectionComponent.DisableOffMeshConnection();
//    }
//}
