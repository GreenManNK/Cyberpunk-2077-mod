module NightCityAllies.Util

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Npc.Behavior.*
import NightCityAllies.Animation.*

public class NCAUtil extends ScriptableSystem {
    public func StartPreview(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(npc) {
            return;
        }
        npc.AttachBehavior(NCAPreviewBehavior.Create());
    }

    public func StopPreview(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(npc) {
            return;
        }
        npc.DetachBehavior();
    }

    public func PreviewInteractionAt(npc: ref<NpcHandle>, type: CName, position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) {
            return false;
        }

        let routine: ref<NCARoutine>;
        if !NCA.Animation().GetSoloRoutine(type, npc.rig, routine) {
            return false;
        }

        npc.AttachBehavior(NCAPreviewRoutineBehavior.Create(routine, position, rotation, null));
        return true;
    }

    public func PreviewRoutineAt(npc: ref<NpcHandle>, type: String, tag: String, position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) || !IsStringValid(type) || !IsStringValid(tag) {
            return false;
        }

        let routine = NCA.Animation().GetRoutine(StringToName(type), StringToName(tag));
        if !IsDefined(routine) {
            return false;
        }

        let partner: wref<ScriptedPuppet>;
        if IsStringValid(routine.partnerRig) {
            partner = NCA.Player();
        }

        npc.AttachBehavior(NCAPreviewRoutineBehavior.Create(routine, position, rotation, partner));
        return true;
    }

    public func PreviewAnimationAt(npc: ref<NpcHandle>, animName: String, workspot: String, actorComp: String, deviceComp: String, syncSlot: String, partnerAnimation: String,
                                   partnerForward: Float, partnerRight: Float, partnerUp: Float, partnerYaw: Float,
                                   position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) || !IsStringValid(animName) {
            return false;
        }

        let animation: NCAAnimation;
        animation.animation = animName;
        animation.partnerAnimation = partnerAnimation;

        let binding: NCAWorkspotBinding;
        binding.workspot = workspot;
        binding.actorComp = actorComp;
        binding.deviceComp = deviceComp;
        binding.syncSlot = syncSlot;

        let partner: wref<ScriptedPuppet>;
        if IsStringValid(partnerAnimation) {
            partner = NCA.Player();
        }

        npc.AttachBehavior(NCAPreviewAnimationBehavior.Create(animation, binding, binding,
            position, rotation, partner,
            partnerForward, partnerRight, partnerUp, partnerYaw));
        return true;
    }

    public func GetRig(puppet: wref<ScriptedPuppet>) -> String {
        if !IsDefined(puppet) {
            return "";
        }

        let components: array<ref<IComponent>> = puppet.GetComponents();
        let fallback: String = "";

        let i: Int32 = 0;
        while i < ArraySize(components) {
            let animComp = components[i] as AnimatedComponent;
            if IsDefined(animComp) {
                // base\characters\base_entities\man_base\man_base.rig
                let path: String = ResRef.ToString(ResourceRef.GetPath(animComp.rig));

                if Equals(components[i].GetName(), n"root") && IsStringValid(path) {
                    return path;
                }

                if !IsStringValid(fallback) {
                    fallback = path;
                }
            }
            i += 1;
        }

        return fallback;
    }

    public func GetPlayerRig() -> String {
        return this.GetRig(NCA.Player());
    }

    public func IsQuestDone(name: CName) -> Bool {
        let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());
        let isQuestFinished: Int32 = questSystem.GetFact(name);
        //NCA.CETLog(NameToString(name) + " -> " + ToString(isQuestFinished));
        return isQuestFinished > 0;
    }

    public func RaycastFromPlayerView(out result: Vector3) -> Bool {
        let player = GetPlayer(GetGameInstance());
        let cameraSystem = GameInstance.GetCameraSystem(player.GetGame());
        let spatialQueries = GameInstance.GetSpatialQueriesSystem(player.GetGame());
        let camTransform: Transform;
        if cameraSystem.GetActiveCameraWorldTransform(camTransform) {
            let rayStart = camTransform.position; 
            let rayDir = cameraSystem.GetActiveCameraForward(); 
            let rayEnd = rayStart + (rayDir * 30.0);
            let raycastResult: TraceResult;
            if spatialQueries.SyncRaycastByCollisionGroup(rayStart, rayEnd, n"Static", raycastResult, true, false) {
                //out result: TraceResult
                result = raycastResult.position;
                return true;
            }
            return false;
        }
    }

    public func StringToRarity(rarity: String) -> CompanionRarity {
        let lowerStr = StrLower(rarity);
        switch (lowerStr) {
            case "common":
                return CompanionRarity.Common;
            case "rare":
                return CompanionRarity.Rare;
            case "elite":
                return CompanionRarity.Elite;
            case "legendary":
                return CompanionRarity.Legendary;
            case "special":
                return CompanionRarity.Special;
            default:
                NCA.CETLog("ERROR Invalid rarity value: " + rarity);           
                return CompanionRarity.Common;
        }
    }

    public func StringToCompanionType(type: String) -> CompanionType {
        let lowerStr = StrLower(type);
        switch (lowerStr) {
            case "normal":
            case "regular":
                return CompanionType.Regular;
            case "merc":
            case "mercenary":
                return CompanionType.Mercenary;
            case "mech":
            case "android":
            case "robot":
                return CompanionType.Robot;
            case "undefined":
                return CompanionType.Undefined;
            default:
                NCA.CETLog("ERROR Invalid companion type: " + type);           
                return CompanionType.Undefined;
        }
    }

    public func StringToCompanionSpawnState(state: String) -> CompanionSpawnState {
        let lowerStr = StrLower(state);
        switch (lowerStr) {
            case "invalid":
                return CompanionSpawnState.Invalid;
            case "locked":
                return CompanionSpawnState.Locked;
            case "unacquired":
                return CompanionSpawnState.Unacquired;
            case "spawned":
                return CompanionSpawnState.Spawned;
            case "squad":
                return CompanionSpawnState.Squad;
            case "standby":
                return CompanionSpawnState.Standby;
            case "roaming":
                return CompanionSpawnState.Roaming;
            case "unavailable":
                return CompanionSpawnState.Unavailable;
            case "commuting":
                return CompanionSpawnState.Commuting;
            default:
                NCA.CETLog("ERROR Invalid companion spawn state: " + state);
                return CompanionSpawnState.Invalid;
        }
    }

    public func FindNavmeshPointNear(npc: wref<GameObject>, target: Vector4, snapRadius: Float, out point: Vector4) -> Bool {
        let navigationSystem = GameInstance.GetAINavigationSystem(GetGameInstance());
        if !IsDefined(navigationSystem) || !IsDefined(npc) {
            return false;
        }

        let snapped = navigationSystem.FindPointInSphereForCharacter(target, snapRadius, npc);
        if !Equals(snapped.status, worldNavigationRequestStatus.OK) {
            return false;
        }

        point = snapped.point;
        return true;
    }

    public func Now() -> Float {
        return EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
    }
}
