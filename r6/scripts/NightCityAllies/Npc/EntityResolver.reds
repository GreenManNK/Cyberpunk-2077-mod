module NightCityAllies.Npc

import NightCityAllies.*

public class EntityResolver {
    public static func ResolveEntityID(resolver: ref<IEntityResolver>, entityID: EntityID) -> Void {
        GameInstance.GetDelaySystem(GetGameInstance())
            .DelayCallback(ResolveEntityDelayCallback.Create(entityID, resolver, 50), 0.2, false);
    }
}

public class IEntityResolver extends IScriptable {
    public func Resolve(handle: ref<Entity>) -> Void {};
}

public class ResolveEntityDelayCallback extends DelayCallback {
    let m_entityID: EntityID;
	let m_resolver: ref<IEntityResolver>;
    let m_tick: Int32;
	
	public static func Create(entityID: EntityID, resolver: ref<IEntityResolver>, tick: Int32) -> ref<ResolveEntityDelayCallback> {
		let created: ref<ResolveEntityDelayCallback> = new ResolveEntityDelayCallback();
		created.m_entityID = entityID;
        created.m_resolver = resolver;
        created.m_tick = tick == 0 ? 50 : tick;
		return created;
	}
	
	public func Call() -> Void {
        let entity: ref<Entity> = GameInstance.FindEntityByID(GetGameInstance(), this.m_entityID) as Entity;
        if IsDefined(entity) {
            this.m_resolver.Resolve(entity);
        } else {
            if (this.m_tick < 0) {
                return;
            }
            this.m_tick -= 1;
            GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(this, 0.2, false);
        }
	}
}