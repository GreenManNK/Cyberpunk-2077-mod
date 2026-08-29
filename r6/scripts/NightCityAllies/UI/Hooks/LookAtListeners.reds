module NightCityAllies.UI.Hooks

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

public class LookAtListener extends ScriptableSystem {
    private let m_npc: ref<NpcHandle>;

    public static func Get() -> ref<LookAtListener> {
        return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<LookAtListener>()) as LookAtListener;
    }

    public func LookAt(npc: ref<NpcHandle>) {
        if (this.m_npc == null) {
            NCA.Events().OnLookAtCompanion(npc);
            this.m_npc = npc;
        } else if (this.m_npc != npc) {
            NCA.Events().OnLookAtCompanionEnd(this.m_npc);
            NCA.Events().OnLookAtCompanion(npc);
            this.m_npc = npc;
        }
    }

    public func StopLookAt() {
        if (this.m_npc != null) {
            NCA.Events().OnLookAtCompanionEnd(this.m_npc);
            this.m_npc = null;
        }
    }
}

@wrapMethod(NpcNameplateGameController)
private final func SetNameplateProjectionEntity(entity: ref<Entity>) -> Void {
    wrappedMethod(entity);

    let npc: ref<NpcHandle>;
    if IsDefined(entity) && NCA.NPC().FindByEntityID(entity.GetEntityID(), npc) {
        LookAtListener.Get().LookAt(npc);
    } else {
        // method triggers with an empty entity sometimes, in case nothing is found retry by checking the look at object
        let gameObject: ref<GameObject> = GameInstance.GetTargetingSystem(GetGameInstance()).GetLookAtObject(GetPlayer(GetGameInstance()), true);
        let npcPuppet: ref<NPCPuppet> = gameObject as NPCPuppet;
        if IsDefined(npcPuppet) && NCA.NPC().FindByEntityID(npcPuppet.GetEntityID(), npc) {
            LookAtListener.Get().LookAt(npc);
        } else {
            LookAtListener.Get().StopLookAt();
        }
    }
}
