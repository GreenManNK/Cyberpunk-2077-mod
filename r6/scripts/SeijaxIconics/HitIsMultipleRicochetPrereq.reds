
public class HitIsMultipleRicochetPrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result = super.Evaluate(hitEvent);
    if !result {
      return false;
    };
    let prereq: ref<HitIsMultipleRicochetPrereq> = this.GetPrereq() as HitIsMultipleRicochetPrereq;
    let nBounces: Int32 = hitEvent.attackData.GetNumRicochetBounces();
    if prereq.m_maxBounces > 0 {
      return nBounces >= prereq.m_minBounces && nBounces <= prereq.m_maxBounces;
    };
    return nBounces >= prereq.m_minBounces;
  }
}

public class HitIsMultipleRicochetPrereq extends GenericHitPrereq {

  public let m_minBounces: Int32;
  public let m_maxBounces: Int32;

  protected func Initialize(recordID: TweakDBID) -> Void {
    super.Initialize(recordID);
  /*
    this.m_minBounces = TweakDBInterface.GetInt(recordID + t".minBounces", 1);
    this.m_maxBounces = TweakDBInterface.GetInt(recordID + t".maxBounces", 0);
  */
    this.m_minBounces = 2;
    this.m_maxBounces = 0;
  }
}
