module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class NCAFollowTargetBehavior extends NCABehavior {
    private let m_target: wref<GameObject>;
    private let m_distance: Float;
    private let m_tolerance: Float;

    public func GetName() -> String = "FollowTarget";
    public func GetText() -> String {
        return "Following";
    }

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.0, 0.6, 0.3, 0.5);
    }

    public static func Create(target: wref<GameObject>, distance: Float, tolerance: Float) -> ref<NCAFollowTargetBehavior> {
        let behavior = new NCAFollowTargetBehavior();
        behavior.m_target = target;
        behavior.m_distance = distance;
        behavior.m_tolerance = tolerance;
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {}

    public func OnAttach() -> Void {
        this.FollowTarget(this.m_target, this.m_distance, this.m_tolerance, moveMovementType.Walk, true);
    }

    public func OnDetach() -> Void {
        this.CancelCommand();
    }
}