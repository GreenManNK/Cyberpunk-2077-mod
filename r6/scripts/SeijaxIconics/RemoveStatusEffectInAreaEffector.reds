
public class RemoveStatusEffectInAreaEffector extends Effector {

  public let m_tags: array<CName>;

  public let m_range: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_tags = TDB.GetCNameArray(record + t".tags");
    this.m_range = TDB.GetFloat(record + t".range");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let targets: array<ref<NPCPuppet>>;
    if !IsDefined(owner) || ArraySize(this.m_tags) == 0 {
      return;
    };
    targets = this.GetNPCsAroundObject(owner, this.m_range);
    this.RemoveStatusEffects(owner, targets);
  }

  private final func RemoveStatusEffects(owner: ref<GameObject>, targets: array<ref<NPCPuppet>>) -> Void {
    let appliedEffects: array<ref<StatusEffect>>;
    let foundAllTags: Bool;
    let j: Int32;
    let k: Int32;
    let record: ref<StatusEffect_Record>;
    let tags: array<CName>;
    let target: ref<NPCPuppet>;
    let statusEffectSystem: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(owner.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(targets) {
      target = targets[i];
      ArrayClear(appliedEffects);
      statusEffectSystem.GetAppliedEffects(target.GetEntityID(), appliedEffects);
      if ArraySize(appliedEffects) == 0 {
      } else {
        j = 0;
        while j < ArraySize(appliedEffects) {
          record = appliedEffects[j].GetRecord();
          tags = record.GameplayTags();
          foundAllTags = true;
          k = 0;
          while k < ArraySize(this.m_tags) {
            if !ArrayContains(tags, this.m_tags[k]) {
              foundAllTags = false;
              break;
            };
            k += 1;
          };
          if foundAllTags {
            statusEffectSystem.RemoveStatusEffect(target.GetEntityID(), record.GetID());
            break;
          };
          j += 1;
        };
      };
      i += 1;
    };
  }

  public final func GetNPCsAroundObject(owner: ref<GameObject>, opt range: Float) -> array<ref<NPCPuppet>> {
    let i: Int32;
    let searchQuery: TargetSearchQuery;
    let target: ref<NPCPuppet>;
    let targetParts: array<TS_TargetPartInfo>;
    let targetingComponent: ref<TargetingComponent>;
    let targets: array<ref<NPCPuppet>>;
    searchQuery.testedSet = TargetingSet.Complete;
  //searchQuery.searchFilter = TSF_And(TSF_All(TSFMV.Obj_Puppet), TSF_Not(TSFMV.Obj_Player), TSF_Not(TSFMV.Att_Friendly));
    searchQuery.searchFilter = TSF_And(TSF_All(TSFMV.Obj_Puppet), TSF_Not(TSFMV.Obj_Player));
    searchQuery.maxDistance = range > 0.0 ? range : 0.0;
    searchQuery.filterObjectByDistance = true;
    searchQuery.includeSecondaryTargets = false;
    searchQuery.ignoreInstigator = true;
    GameInstance.GetTargetingSystem(owner.GetGame()).GetTargetParts(owner, searchQuery, targetParts);
    i = 0;
    while i < ArraySize(targetParts) {
      targetingComponent = TS_TargetPartInfo.GetComponent(targetParts[i]);
      if IsDefined(targetingComponent) {
        target = targetingComponent.GetEntity() as NPCPuppet;
        if IsDefined(target) {
          if !ArrayContains(targets, target) {
            ArrayPush(targets, target);
          };
        };
      };
      i += 1;
    };
    return targets;
  }
  
}