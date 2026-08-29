module NightCityAllies.Npc.Hooks

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

public class ProximityHooks {
    public static func Resolve(puppet: ref<ScriptedPuppet>, profile: CName, out npc: ref<NpcHandle>) -> Bool {
        if !IsDefined(puppet) || NotEquals(profile, n"Crowds") {
            return false;
        }

        return NCA.NPC().FindByEntityID(puppet.GetEntityID(), npc);
    }
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnPlayerProximityStartEvent(evt: ref<PlayerProximityStartEvent>) -> Bool {
    let result = wrappedMethod(evt);

    let npc: ref<NpcHandle>;

    if ProximityHooks.Resolve(this.GetOwnerPuppet(), evt.profile, npc) {
        NCA.Events().OnCompanionEnterProximity(npc);
    }

    return result;
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnPlayerProximityStopEvent(evt: ref<PlayerProximityStopEvent>) -> Bool {
    let result = wrappedMethod(evt);

    let npc: ref<NpcHandle>;

    if ProximityHooks.Resolve(this.GetOwnerPuppet(), evt.profile, npc) {
        NCA.Events().OnCompanionExitProximity(npc);
    }

    return result;
}
