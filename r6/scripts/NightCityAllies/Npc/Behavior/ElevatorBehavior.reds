module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

// Stub, kept for a later attempt at companions actually riding lifts.
//
// Getting them INTO the cabin works (the off-mesh wrap in NpcHooks makes it navigable, and the
// commented-out follow below closed them to 1m). What does not work is the ride: nothing carries an
// NPC with a moving platform, so the cabin travels straight through them. Standing in a lift while
// it moves through you is worse than not being in it, so for now they simply wait where they are and
// the commute brings them back once the player is out (NpcManager.OnFinishCommute).
//
// Restore the OnAttach body to get the boarding behavior back.
public class NCAElevatorBehavior extends NCABehavior {
    //private static func GetFollowDistance() -> Float = 1.0;
    //private static func GetTolerance() -> Float = 0.5;

    public func GetName() -> String = "Elevator";
    public func GetText() -> String = "Idle";

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.0, 0.6, 0.3, 0.5);
    }

    public static func Create() -> ref<NCAElevatorBehavior> {
        let behavior = new NCAElevatorBehavior();
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {}

    // No command on purpose: the previous behavior's OnDetach has already cleared its role, so
    // issuing nothing leaves them standing where they were.
    public func OnAttach() -> Void {
        //this.FollowTarget(GetPlayer(GetGameInstance()), NCAElevatorBehavior.GetFollowDistance(), NCAElevatorBehavior.GetTolerance());
    }

    public func OnDetach() -> Void {
        this.CancelCommand();
    }
}
