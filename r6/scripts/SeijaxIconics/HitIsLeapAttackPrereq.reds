
public class HitIsLeapAttackPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result = super.Evaluate(hitEvent);
    if !result {
      return false;
    };
    let instigator: wref<GameObject> = hitEvent.attackData.GetInstigator();
    let attackRange: Float = GameInstance.GetStatsSystem(instigator.GetGame()).GetStatValue(Cast<StatsObjectID>(instigator.GetEntityID()), gamedataStatType.Range);
    let playerPerkDataBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(instigator.GetGame()).Get(GetAllBlackboardDefs().PlayerPerkData);
    let leapedDistance: Float = playerPerkDataBB.GetFloat(GetAllBlackboardDefs().PlayerPerkData.LeapedDistance);
    return leapedDistance > attackRange ? true : false;
  }
}

public class HitIsLeapAttackPrereq extends GenericHitPrereq {
}