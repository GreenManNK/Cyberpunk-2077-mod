module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class NCACatchUpToPlayerBehavior extends NCABehavior {
    public func GetName() -> String = "CatchUpToPlayer";

    let m_timeout: Float;
    let m_retryCount: Int32;

    public func GetText() -> String {
        return ">>>";
    }

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.0, 0.6, 0.3, 0.5);
    }

    public static func Create() -> ref<NCACatchUpToPlayerBehavior> {
        let behavior = new NCACatchUpToPlayerBehavior();
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {
        let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
        if !IsDefined(player) {
            NCA.CETLog("ERROR Player not found, cannot catch up");
            return;
        };

        let npcPos = this.m_npcHandle.GetEntity().GetWorldPosition();
        let playerPos = player.GetWorldPosition();
        let distance = Vector4.Distance(npcPos, playerPos);
        if (distance < 5.0) {
            this.m_npcHandle.Talk(n"greeting");
            this.m_npcHandle.DetermineBehavior();
        } else {
            // retry movement if stuck
            this.m_timeout -= deltaTime;
            if (this.m_timeout <= 0.0) {
                this.FollowTarget(player, NCAConstants.CatchUpApproachDistance(), NCAConstants.CatchUpApproachTolerance(), moveMovementType.Walk);
                this.m_retryCount += 1;
                this.m_timeout = 10.0;
                //NCA.CETLog("Retrying movement to player, attempt " + IntToString(this.m_retryCount) + ", timeout set to " + FloatToString(this.m_timeout) + " seconds");
            }
            
            if (this.m_retryCount > 2) {
                //NCA.CETLog("Failed to reach player after " + IntToString(this.m_retryCount) + " attempts, giving up and resetting state");
                this.m_retryCount = 0;
                this.m_npcHandle.DetermineBehavior(); // NOTE Triggers OnDetach, so the behavior ends here
            }
        }
    }

    public func OnAttach() -> Void {
        this.m_retryCount = 0;
        let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;
        if (!IsDefined(player)) {
            NCA.CETLog("ERROR Player not found, cannot catch up");
            return;
        };
        this.FollowTarget(player, NCAConstants.CatchUpApproachDistance(), NCAConstants.CatchUpApproachTolerance(), moveMovementType.Walk);
        this.m_timeout = 10.0;
    }

    public func OnDetach() -> Void {
        this.CancelCommand();
    }
}