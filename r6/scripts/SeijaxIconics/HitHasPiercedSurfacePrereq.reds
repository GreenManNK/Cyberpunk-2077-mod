
public class HitHasPiercedSurfacePrereqState extends GenericHitPrereqState {

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result = super.Evaluate(hitEvent);
    if !result {
      return false;
    };
    return hitEvent.hasPiercedTechSurface;
  }
  
}

public class HitHasPiercedSurfacePrereq extends GenericHitPrereq {
}