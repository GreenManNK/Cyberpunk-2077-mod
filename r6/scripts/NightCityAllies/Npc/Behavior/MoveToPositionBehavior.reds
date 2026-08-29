module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class NCAMoveToPositionBehavior extends NCABehavior {
    private let m_targetPosition: Vector4;

    public func GetName() -> String = "MoveToPosition";
    public func GetText() -> String {
        return "Move To: " + ToString(this.m_targetPosition);
    }

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.0, 0.6, 0.3, 0.5);
    }

    public static func Create(pos: Vector4) -> ref<NCAMoveToPositionBehavior> {
        let behavior = new NCAMoveToPositionBehavior();
        behavior.m_targetPosition = pos;
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {}

    public func OnAttach() -> Void {
        let command: ref<AIMoveToCommand> = new AIMoveToCommand();
        let spec       = new AIPositionSpec();
        let wp: WorldPosition;
        WorldPosition.SetVector4(wp, this.m_targetPosition);
        AIPositionSpec.SetWorldPosition(spec, wp);
        command.movementTarget   = spec;
        command.movementType     = moveMovementType.Walk;
        command.useStart         = true;
        command.useStop          = true;
        command.ignoreNavigation = false;

        this.SendCommand(command);
    }

    public func OnDetach() -> Void {
        this.CancelCommand();
    }
}