module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class CombatBehavior extends NCABehavior {
    public func GetName() -> String = "Combat";

    public static func Create() -> ref<CombatBehavior> {
        let behavior = new CombatBehavior();
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {}

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.8, 0.0, 0.0, 1.0);
    }

    public func OnAttach() -> Void {
        //this.m_npcHandle.EquipPrimaryWeapon(); // <- would cause OnDetach() and then the OnAttach() to cycle indefinitely
        this.m_npcHandle.Talk(n"enemy_warning");
        this.m_npcHandle.SetCombatState();

        // TODO Some chars wont fight without the follow role, I would prefer without so they don't stay super close all the time
        let nullArrayOfNames: array<CName>;
        let playerRef: EntityReference = CreateEntityReference("#player", nullArrayOfNames);
        let followerRole: ref<AIFollowerRole> = new AIFollowerRole();
        followerRole.SetFollowerRef(playerRef);
        let command: ref<AIAssignRoleCommand> = new AIAssignRoleCommand();
        command.role = followerRole;
        this.SendCommand(command, true);
    }

    public func OnDetach() -> Void {
        //this.m_npcHandle.UnEquipWeapon();
        //this.m_npcHandle.Talk(n"bump");
        this.m_npcHandle.SetRelaxedState();

        // TODO
        let command: ref<AIAssignRoleCommand> = new AIAssignRoleCommand();
        command.role = new AINoRole();
        this.SendCommand(command, true);
    }
}