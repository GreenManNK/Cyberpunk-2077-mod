module ExtraIconics

class EffectsFactoryMerge extends ScriptableService {
  
  private cb func OnLoad() {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnEffectFactoryLoad").AddTarget(ResourceTarget.Path(r"base\\gameplay\\game_effects\\static_effects.csv"));
  }
  
  private cb func OnEffectFactoryLoad(event: ref<ResourceEvent>) {
    let csv = event.GetResource() as C2dArray;
    ArrayPush(csv.data, ["sj_iconic_effects", "seijax\\iconic_weapons\\vfx\\sj_iconic_effects.es"]);
  }

}

@wrapMethod(DamageManager)
private final static func CanBlockBullet(hitEvent: ref<gameHitEvent>) -> Bool {
  let result: Bool = wrappedMethod(hitEvent);
  if result {
    let ownerStatsSystem: wref<StatsSystem> = GameInstance.GetStatsSystem(hitEvent.target.GetGame());
    if ownerStatsSystem.GetStatValue(Cast<StatsObjectID>(hitEvent.target.GetEntityID()), IntEnum<gamedataStatType>(EnumValueFromName(n"gamedataStatType", n"CannotBlockBullets"))) > 0.00 {
      result = false;
    };
  };
  return result;
}

@wrapMethod(AIActionHelper)
public final static func TryChangingAttitudeToHostile(owner: ref<ScriptedPuppet>, target: ref<GameObject>) -> Bool {
  let immune: Bool = GameInstance.GetStatsSystem(owner.GetGame()).GetStatValue(Cast<StatsObjectID>(owner.GetEntityID()), gamedataStatType.MemoryWipeImmunity) > 0.00;
  if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"MemoryWipe") && !immune {
    return false;
  }
  return wrappedMethod(owner, target);
}

@wrapMethod(NPCPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let gmplTags: array<CName> = evt.staticData.GameplayTags();
  if ArrayContains(gmplTags, n"SystemCollapse") {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    if IsDefined(player) {
      StatusEffectHelper.RemoveStatusEffectsWithTag(player, n"NetHoundBreachCooldown");
    };
  };
  return result;
}
