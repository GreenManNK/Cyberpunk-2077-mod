module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class NCAHoldPositionBehavior extends NCABehavior {
    public func GetName() -> String = "HoldPosition";
    public func GetText() -> String = "Idle";

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.0, 0.6, 0.3, 0.5);
    }

    public static func Create() -> ref<NCAHoldPositionBehavior> {
        let behavior = new NCAHoldPositionBehavior();
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {}

    public func OnAttach() -> Void {
        this.HoldPosition();
    }

    public func OnDetach() -> Void {
        this.CancelCommand();
    }
}