
public class HitIsTargetBreachedPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let prereq: ref<HitIsTargetBreachedPrereq> = this.GetPrereq() as HitIsTargetBreachedPrereq;
    let i: Int32 = 0;
    while i < ArraySize(prereq.m_conditions) {
      if !prereq.m_conditions[i].Evaluate(hitEvent) {
        return false;
      };
      i += 1;
    };
    if prereq.m_ignoreSelfInflictedPressureWave {
      if hitEvent.target.IsPlayer() && hitEvent.attackData.GetInstigator().IsPlayer() && Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.PressureWave) {
        return false;
      };
    };
    let checkPassed: Bool;
    let target: wref<GameObject> = hitEvent.target as GameObject;
    if IsDefined(target) {
      checkPassed = target.IsBreached();
      if prereq.m_invert {
        checkPassed = !checkPassed;
      };
      return checkPassed;
    };
    return false;
  }
}

public class HitIsTargetBreachedPrereq extends GenericHitPrereq {

  public let m_invert: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    super.Initialize(recordID);
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
  }
}
