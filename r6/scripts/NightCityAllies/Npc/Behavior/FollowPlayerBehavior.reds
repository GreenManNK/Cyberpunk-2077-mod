module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*

public class NCAFollowPlayerBehavior extends NCABehavior {
    public func GetName() -> String = "FollowPlayer";

    public func GetText() -> String {
        let distance = Vector4.Distance(GetPlayer(GetGameInstance()).GetWorldPosition(), this.m_npcHandle.GetEntity().GetWorldPosition());
        return ToString(FloorF(distance)) + "m";
    }
    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.75, 0.75, 0.75, 0.5);
    }

    public static func Create() -> ref<NCAFollowPlayerBehavior> {
        let behavior = new NCAFollowPlayerBehavior();
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {
    }

    public func OnAttach() -> Void {
        this.AssignFollowerRole();
    }

    public func OnDetach() -> Void {
        this.ClearRole();
    }

    protected func OnHold() -> Void {
        this.HoldPosition();
    }

    protected func OnRelease() -> Void {
        this.CancelCommand();
    }

    private func ClearRole() -> Void {
        let command: ref<AIAssignRoleCommand> = new AIAssignRoleCommand();
        command.role = new AINoRole();
        this.SendCommand(command, true);
    }

    private func AssignFollowerRole() -> Void {
        let nullArrayOfNames: array<CName>;
        let playerRef: EntityReference = CreateEntityReference("#player", nullArrayOfNames);
        let followerRole = new AIFollowerRole();
        followerRole.SetFollowerRef(playerRef);

        let command = new AIAssignRoleCommand();
        command.role = followerRole;
        this.SendCommand(command, true);
    }
}
