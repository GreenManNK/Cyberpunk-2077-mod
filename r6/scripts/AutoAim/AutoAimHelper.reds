module AutoAim

@addField(PlayerPuppet)
private let m_autoAimCurrentTargetID: EntityID;

@addField(PlayerPuppet)
private let m_autoAimCurrentTargetIsRevealFallback: Bool;

@addField(PlayerPuppet)
private let m_autoAimPendingTargetID: EntityID;

@addField(PlayerPuppet)
private let m_autoAimPendingTargetIsRevealFallback: Bool;

@addField(PlayerPuppet)
private let m_autoAimFinalizeFrames: Int32;

@addMethod(PlayerPuppet)
public final func GetAutoAimCurrentTargetID() -> EntityID {
  return this.m_autoAimCurrentTargetID;
}

@addMethod(PlayerPuppet)
public final func SetAutoAimCurrentTargetID(targetID: EntityID) -> Void {
  this.m_autoAimCurrentTargetID = targetID;
}

@addMethod(PlayerPuppet)
public final func GetAutoAimCurrentTargetIsRevealFallback() -> Bool {
  return this.m_autoAimCurrentTargetIsRevealFallback;
}

@addMethod(PlayerPuppet)
public final func SetAutoAimCurrentTargetIsRevealFallback(value: Bool) -> Void {
  this.m_autoAimCurrentTargetIsRevealFallback = value;
}

@addMethod(PlayerPuppet)
public final func GetAutoAimPendingTargetID() -> EntityID {
  return this.m_autoAimPendingTargetID;
}

@addMethod(PlayerPuppet)
public final func SetAutoAimPendingTargetID(targetID: EntityID) -> Void {
  this.m_autoAimPendingTargetID = targetID;
}

@addMethod(PlayerPuppet)
public final func GetAutoAimPendingTargetIsRevealFallback() -> Bool {
  return this.m_autoAimPendingTargetIsRevealFallback;
}

@addMethod(PlayerPuppet)
public final func SetAutoAimPendingTargetIsRevealFallback(value: Bool) -> Void {
  this.m_autoAimPendingTargetIsRevealFallback = value;
}

@addMethod(PlayerPuppet)
public final func GetAutoAimFinalizeFrames() -> Int32 {
  return this.m_autoAimFinalizeFrames;
}

@addMethod(PlayerPuppet)
public final func SetAutoAimFinalizeFrames(value: Int32) -> Void {
  this.m_autoAimFinalizeFrames = value;
}

public class AutoAimHelper {
  public static func ApplyADSRequest(player: ref<PlayerPuppet>, aimPosition: Vector4) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    return UpdateADSControl(player, aimPosition);
  }

  public static func ResolveWarmupAimPosition(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let crosshairPos: Vector4;
    let crosshairFwd: Vector4;
    let bestComponent: wref<TargetingComponent>;
    let trackedComponent: wref<TargetingComponent>;
    let componentOwner: ref<GameObject>;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return AutoAimHelper.ResolveStableTrackAimPosition(targetObject, aimPos);
    }

    targetingSystem.GetCrosshairData(player, crosshairPos, crosshairFwd);

    bestComponent = targetingSystem.GetBestComponentOnTargetObject(crosshairPos, crosshairFwd, targetObject, TargetComponentFilterType.HeadTarget);
    if IsDefined(bestComponent) {
      aimPos = Matrix.GetTranslation(bestComponent.GetLocalToWorld());
      return true;
    }

    trackedComponent = targetingSystem.GetTrackedTargetComponent(player);
    if IsDefined(trackedComponent) {
      componentOwner = trackedComponent.GetEntity() as GameObject;
      if IsDefined(componentOwner) && componentOwner.GetEntityID() == targetObject.GetEntityID() {
        aimPos = Matrix.GetTranslation(trackedComponent.GetLocalToWorld());
        return true;
      }
    }

    return AutoAimHelper.ResolveStableTrackAimPosition(targetObject, aimPos);
  }

  public static func ResolveFinalizeAimPosition(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    if !AutoAimHelper.ResolveOpenADSPreciseAimPosition(player, targetObject, aimPos) {
      return AutoAimHelper.ResolveBestFireAimPosition(player, targetObject, aimPos);
    }

    return true;
  }

  public static func ApplyNativeOpenADSLookAt(player: ref<PlayerPuppet>, targetObject: ref<GameObject>) -> Bool {
    let warmupAimPos: Vector4;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    if !AutoAimHelper.ResolveWarmupAimPosition(player, targetObject, warmupAimPos) {
      return false;
    }

    player.SetAutoAimFinalizeFrames(3);
    return AutoAimHelper.ApplyADSRequest(player, warmupAimPos);
  }

  public static func ApplyFinalizeLookAt(player: ref<PlayerPuppet>, targetObject: ref<GameObject>) -> Bool {
    let finalizeAimPos: Vector4;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    if !AutoAimHelper.ResolveFinalizeAimPosition(player, targetObject, finalizeAimPos) {
      return false;
    }

    return AutoAimHelper.ApplyADSRequest(player, finalizeAimPos);
  }

  public static func ApplyFireCorrection(player: ref<PlayerPuppet>, targetObject: ref<GameObject>) -> Bool {
    let fireAimPos: Vector4;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    if !AutoAimHelper.ResolveBestFireAimPosition(player, targetObject, fireAimPos) {
      if !AutoAimHelper.ResolveFinalizeAimPosition(player, targetObject, fireAimPos) {
        return false;
      }
    }

    return AutoAimHelper.ApplyADSRequest(player, fireAimPos);
  }

  public static func SendADSControl(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, usePrecisePoint: Bool) -> Bool {
    let aimPosition: Vector4;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    if usePrecisePoint {
      if !AutoAimHelper.ResolveBestFireAimPosition(player, targetObject, aimPosition) {
        if !AutoAimHelper.ResolveFinalizeAimPosition(player, targetObject, aimPosition) {
          return false;
        }
      }
    } else {
      if !AutoAimHelper.ResolveStableTrackAimPosition(targetObject, aimPosition) {
        return false;
      }
    }

    return AutoAimHelper.ApplyADSRequest(player, aimPosition);
  }

  public static func ApplyTrackingCorrection(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, isRevealFallback: Bool) -> Bool {
    let dot: Float;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    dot = AutoAimHelper.GetTargetDotToCrosshair(player, targetObject);
    if AutoAimHelper.ShouldUseStrongTrackLock(player, targetObject, isRevealFallback) {
      return AutoAimHelper.ApplyFinalizeLookAt(player, targetObject);
    }

    if dot > 0.9995 {
      return false;
    }

    return AutoAimHelper.SendADSControl(player, targetObject, false);
  }

  public static func IsPlayerAiming(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    return StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.PlayerAiming");
  }

  public static func ShouldUseMousePatch(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    return player.PlayerLastUsedKBM();
  }

  public static func IsEligibleWeapon(player: ref<PlayerPuppet>) -> Bool {
    let weapon: ref<WeaponObject>;
    let weaponRecord: wref<WeaponItem_Record>;
    let itemType: gamedataItemType;
    let evolution: gamedataWeaponEvolution;

    if !IsDefined(player) {
      return false;
    }

    weapon = GameObject.GetActiveWeapon(player);
    if !IsDefined(weapon) {
      return false;
    }

    if !weapon.IsRanged() || weapon.IsMelee() || weapon.IsThrowable() {
      return false;
    }

    weaponRecord = weapon.GetWeaponRecord();
    if !IsDefined(weaponRecord) {
      return false;
    }

    evolution = weaponRecord.Evolution().Type();
    if EnumInt(evolution) == EnumInt(gamedataWeaponEvolution.Smart) {
      return false;
    }

    itemType = weaponRecord.ItemType().Type();
    if EnumInt(itemType) == EnumInt(gamedataItemType.Wea_GrenadeLauncher) {
      return false;
    }

    if EnumInt(itemType) == EnumInt(gamedataItemType.Cyb_Launcher) {
      return false;
    }

    return true;
  }

  public static func IsHostileTarget(targetObject: ref<GameObject>, player: ref<PlayerPuppet>) -> Bool {
    let attitude: EAIAttitude;

    if !IsDefined(targetObject) || !IsDefined(player) {
      return false;
    }

    if !targetObject.IsPuppet() {
      return false;
    }

    if !ScriptedPuppet.IsAlive(targetObject) || ScriptedPuppet.IsDefeated(targetObject) {
      return false;
    }

    attitude = GameObject.GetAttitudeTowards(targetObject, player);
    return EnumInt(attitude) == EnumInt(EAIAttitude.AIA_Hostile);
  }

  public static func IsRevealTarget(targetObject: ref<GameObject>, player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(targetObject) || !IsDefined(player) {
      return false;
    }

    if !targetObject.IsPuppet() {
      return false;
    }

    if !ScriptedPuppet.IsAlive(targetObject) || ScriptedPuppet.IsDefeated(targetObject) {
      return false;
    }

    return targetObject.IsObjectRevealed();
  }

  public static func GetCurrentTargetID(player: ref<PlayerPuppet>) -> EntityID {
    let emptyID: EntityID;

    if !IsDefined(player) {
      return emptyID;
    }

    return player.GetAutoAimCurrentTargetID();
  }

  public static func SetCurrentTargetID(player: ref<PlayerPuppet>, targetID: EntityID) -> Void {
    if IsDefined(player) {
      player.SetAutoAimCurrentTargetID(targetID);
    }
  }

  public static func GetCurrentTargetIsRevealFallback(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    return player.GetAutoAimCurrentTargetIsRevealFallback();
  }

  public static func SetCurrentTargetIsRevealFallback(player: ref<PlayerPuppet>, value: Bool) -> Void {
    if IsDefined(player) {
      player.SetAutoAimCurrentTargetIsRevealFallback(value);
    }
  }

  public static func SetCurrentTarget(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, isRevealFallback: Bool) -> Void {
    let emptyID: EntityID;

    if !IsDefined(player) {
      return;
    }

    if IsDefined(targetObject) {
      AutoAimHelper.SetCurrentTargetID(player, targetObject.GetEntityID());
      AutoAimHelper.SetCurrentTargetIsRevealFallback(player, isRevealFallback);
    } else {
      AutoAimHelper.SetCurrentTargetID(player, emptyID);
      AutoAimHelper.SetCurrentTargetIsRevealFallback(player, false);
    }
  }

  public static func GetCurrentTarget(player: ref<PlayerPuppet>) -> ref<GameObject> {
    let targetID: EntityID;

    if !IsDefined(player) {
      return null;
    }

    targetID = AutoAimHelper.GetCurrentTargetID(player);
    if !EntityID.IsDefined(targetID) {
      return null;
    }

    return GameInstance.FindEntityByID(player.GetGame(), targetID) as GameObject;
  }

  public static func SetPendingTarget(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, isRevealFallback: Bool) -> Void {
    let emptyID: EntityID;

    if !IsDefined(player) {
      return;
    }

    if IsDefined(targetObject) {
      player.SetAutoAimPendingTargetID(targetObject.GetEntityID());
      player.SetAutoAimPendingTargetIsRevealFallback(isRevealFallback);
    } else {
      player.SetAutoAimPendingTargetID(emptyID);
      player.SetAutoAimPendingTargetIsRevealFallback(false);
    }
  }

  public static func GetPendingTarget(player: ref<PlayerPuppet>) -> ref<GameObject> {
    let targetID: EntityID;

    if !IsDefined(player) {
      return null;
    }

    targetID = player.GetAutoAimPendingTargetID();
    if !EntityID.IsDefined(targetID) {
      return null;
    }

    return GameInstance.FindEntityByID(player.GetGame(), targetID) as GameObject;
  }

  public static func GetPendingTargetIsRevealFallback(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    return player.GetAutoAimPendingTargetIsRevealFallback();
  }

  public static func ClearNativeADS(player: ref<PlayerPuppet>) -> Void {
    let targetingSystem: ref<TargetingSystem>;

    if !IsDefined(player) {
      return;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if IsDefined(targetingSystem) {
      targetingSystem.BreakLookAt(player);
      targetingSystem.BreakAimSnap(player);
    }
  }

  public static func GetTargetDotToCrosshair(player: ref<PlayerPuppet>, targetObject: ref<GameObject>) -> Float {
    let targetingSystem: ref<TargetingSystem>;
    let aimPos: Vector4;
    let crosshairPos: Vector4;
    let crosshairFwd: Vector4;
    let toTarget: Vector4;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return -1.00;
    }

    if !AutoAimHelper.ResolveBestAimPosition(targetObject, aimPos) {
      return -1.00;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return -1.00;
    }

    targetingSystem.GetCrosshairData(player, crosshairPos, crosshairFwd);
    toTarget = Vector4.Normalize(aimPos - crosshairPos);
    return Vector4.Dot(Vector4.Normalize(crosshairFwd), toTarget);
  }

  public static func IsCurrentTargetStillValid(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, isRevealFallback: Bool) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let dot: Float;
    let minDot: Float;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());

    if isRevealFallback {
      if !AutoAimHelper.IsRevealTarget(targetObject, player) {
        return false;
      }

      if IsDefined(targetingSystem) && targetingSystem.IsVisibleTarget(player, targetObject) {
        return false;
      }

      minDot = 0.985;
    } else {
      if !AutoAimHelper.IsHostileTarget(targetObject, player) {
        return false;
      }

      if IsDefined(targetingSystem) && !targetingSystem.IsVisibleTarget(player, targetObject) {
        return false;
      }

      minDot = 0.940;
    }

    dot = AutoAimHelper.GetTargetDotToCrosshair(player, targetObject);
    return dot >= minDot;
  }

  public static func ShouldUseStrongTrackLock(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, isRevealFallback: Bool) -> Bool {
    let dot: Float;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    dot = AutoAimHelper.GetTargetDotToCrosshair(player, targetObject);
    if isRevealFallback {
      return dot < 0.996;
    }

    return dot < 0.972;
  }

  public static func TryGetVisibleMainTarget(player: ref<PlayerPuppet>, out targetObject: ref<GameObject>) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let candidate: ref<GameObject>;

    if !IsDefined(player) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return false;
    }

    candidate = targetingSystem.GetLookAtObject(player, true, true) as GameObject;
    if !IsDefined(candidate) {
      return false;
    }

    if !AutoAimHelper.IsHostileTarget(candidate, player) {
      return false;
    }

    targetObject = candidate;
    return true;
  }

  public static func TryGetRevealFallbackTarget(player: ref<PlayerPuppet>, out targetObject: ref<GameObject>) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let candidate: ref<GameObject>;

    if !IsDefined(player) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return false;
    }

    candidate = targetingSystem.GetLookAtObject(player, false) as GameObject;
    if !IsDefined(candidate) {
      return false;
    }

    if !AutoAimHelper.IsRevealTarget(candidate, player) {
      return false;
    }

    targetObject = candidate;
    return true;
  }

  public static func TryGetClosestVisibleComponentTarget(player: ref<PlayerPuppet>, out targetObject: ref<GameObject>) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let query: TargetSearchQuery;
    let targetComponent: wref<IPlacedComponent>;
    let targetingComponent: wref<TargetingComponent>;
    let candidate: ref<GameObject>;
    let angleDistance: EulerAngles;

    if !IsDefined(player) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return false;
    }

    query = TSQ_EnemyNPC();
    query.maxDistance = 100.0;
    query.filterObjectByDistance = true;
    TargetSearchQuery.SetComponentFilter(query, TargetComponentFilterType.Shooting);
    targetComponent = targetingSystem.GetComponentClosestToCrosshair(player, angleDistance, query);
    targetingComponent = targetComponent as TargetingComponent;
    if !IsDefined(targetingComponent) {
      return false;
    }

    if AbsF(angleDistance.Yaw) > 1.75 || AbsF(angleDistance.Pitch) > 1.25 {
      return false;
    }

    candidate = targetingComponent.GetEntity() as GameObject;
    if !IsDefined(candidate) {
      return false;
    }

    if !AutoAimHelper.IsHostileTarget(candidate, player) {
      return false;
    }

    if !targetingSystem.IsVisibleTarget(player, candidate) {
      return false;
    }

    targetObject = candidate;
    return true;
  }

  public static func AcquireTarget(player: ref<PlayerPuppet>) -> Bool {
    let targetObject: ref<GameObject>;

    if !IsDefined(player) {
      return false;
    }

    if !AutoAimHelper.ShouldUseMousePatch(player) || !AutoAimHelper.IsEligibleWeapon(player) {
      AutoAimHelper.SetCurrentTarget(player, null, false);
      AutoAimHelper.SetPendingTarget(player, null, false);
      return false;
    }

    if AutoAimHelper.TryGetVisibleMainTarget(player, targetObject) {
      AutoAimHelper.SetCurrentTarget(player, targetObject, false);
      AutoAimHelper.SetPendingTarget(player, null, false);
      return true;
    }

    if AutoAimHelper.TryGetRevealFallbackTarget(player, targetObject) {
      AutoAimHelper.SetCurrentTarget(player, targetObject, true);
      AutoAimHelper.SetPendingTarget(player, null, false);
      return true;
    }

    AutoAimHelper.SetCurrentTarget(player, null, false);
    AutoAimHelper.SetPendingTarget(player, null, false);
    return false;
  }

  public static func TryGetCandidateTarget(player: ref<PlayerPuppet>, out targetObject: ref<GameObject>, out isRevealFallback: Bool) -> Bool {
    if !IsDefined(player) {
      return false;
    }

    if !AutoAimHelper.ShouldUseMousePatch(player) || !AutoAimHelper.IsEligibleWeapon(player) {
      return false;
    }

    if AutoAimHelper.TryGetVisibleMainTarget(player, targetObject) {
      isRevealFallback = false;
      return true;
    }

    if AutoAimHelper.TryGetRevealFallbackTarget(player, targetObject) {
      isRevealFallback = true;
      return true;
    }

    return false;
  }

  public static func PromotePendingTarget(player: ref<PlayerPuppet>) -> Bool {
    let pendingTarget: ref<GameObject>;
    let isRevealFallback: Bool;

    if !IsDefined(player) {
      return false;
    }

    pendingTarget = AutoAimHelper.GetPendingTarget(player);
    isRevealFallback = AutoAimHelper.GetPendingTargetIsRevealFallback(player);
    if !IsDefined(pendingTarget) {
      return false;
    }

    if !AutoAimHelper.IsCurrentTargetStillValid(player, pendingTarget, isRevealFallback) {
      AutoAimHelper.SetPendingTarget(player, null, false);
      return false;
    }

    AutoAimHelper.SetCurrentTarget(player, pendingTarget, isRevealFallback);
    AutoAimHelper.SetPendingTarget(player, null, false);
    return true;
  }

  public static func UpdatePendingTarget(player: ref<PlayerPuppet>) -> Bool {
    let candidateTarget: ref<GameObject>;
    let pendingTarget: ref<GameObject>;
    let isRevealFallback: Bool;
    let dot: Float;

    if !IsDefined(player) {
      return false;
    }

    if !AutoAimHelper.TryGetCandidateTarget(player, candidateTarget, isRevealFallback) {
      AutoAimHelper.SetPendingTarget(player, null, false);
      return false;
    }

    pendingTarget = AutoAimHelper.GetPendingTarget(player);
    if IsDefined(pendingTarget) && pendingTarget.GetEntityID() == candidateTarget.GetEntityID() {
      return true;
    }

    dot = AutoAimHelper.GetTargetDotToCrosshair(player, candidateTarget);
    if dot >= 0.970 {
      AutoAimHelper.SetPendingTarget(player, candidateTarget, isRevealFallback);
      return true;
    }

    AutoAimHelper.SetPendingTarget(player, null, false);
    return false;
  }

  public static func ShouldSwitchToVisibleTarget(player: ref<PlayerPuppet>, currentTarget: ref<GameObject>, isRevealFallback: Bool) -> Bool {
    let visibleTarget: ref<GameObject>;
    let componentTarget: ref<GameObject>;
    let currentDot: Float;
    let candidateDot: Float;

    if !IsDefined(player) {
      return false;
    }

    currentDot = AutoAimHelper.GetTargetDotToCrosshair(player, currentTarget);

    if AutoAimHelper.TryGetVisibleMainTarget(player, visibleTarget) {
      if !IsDefined(currentTarget) {
        return true;
      }

      if visibleTarget.GetEntityID() != currentTarget.GetEntityID() {
        if isRevealFallback {
          return true;
        }

        candidateDot = AutoAimHelper.GetTargetDotToCrosshair(player, visibleTarget);
        return candidateDot > currentDot + 0.010 || currentDot < 0.970;
      }
    }

    if AutoAimHelper.TryGetClosestVisibleComponentTarget(player, componentTarget) {
      if !IsDefined(currentTarget) {
        return true;
      }

      if componentTarget.GetEntityID() != currentTarget.GetEntityID() {
        if isRevealFallback {
          return true;
        }

        candidateDot = AutoAimHelper.GetTargetDotToCrosshair(player, componentTarget);
        return candidateDot > currentDot + 0.005 || currentDot < 0.978;
      }
    }

    return false;
  }

  public static func OnADSStart(player: ref<PlayerPuppet>) -> Void {
    let currentTarget: ref<GameObject>;

    AutoAimHelper.AcquireTarget(player);
    if IsDefined(player) {
      player.SetAutoAimFinalizeFrames(0);
    }

    currentTarget = AutoAimHelper.GetCurrentTarget(player);
    if !IsDefined(currentTarget) {
      return;
    }

    AutoAimHelper.ApplyNativeOpenADSLookAt(player, currentTarget);
  }

  public static func OnADSTick(player: ref<PlayerPuppet>, timeDelta: Float) -> Void {
    let currentTarget: ref<GameObject>;
    let isRevealFallback: Bool;
    let finalizeFrames: Int32;

    if !IsDefined(player) {
      return;
    }

    if !AutoAimHelper.IsPlayerAiming(player) {
      AutoAimHelper.OnADSEnd(player);
      return;
    }

    if !AutoAimHelper.ShouldUseMousePatch(player) || !AutoAimHelper.IsEligibleWeapon(player) {
      AutoAimHelper.OnADSEnd(player);
      return;
    }

    currentTarget = AutoAimHelper.GetCurrentTarget(player);
    isRevealFallback = AutoAimHelper.GetCurrentTargetIsRevealFallback(player);

    finalizeFrames = player.GetAutoAimFinalizeFrames();
    if IsDefined(currentTarget) && finalizeFrames > 0 {
      if AutoAimHelper.ApplyFinalizeLookAt(player, currentTarget) {
        player.SetAutoAimFinalizeFrames(finalizeFrames - 1);
      }
      return;
    }

    if AutoAimHelper.ShouldSwitchToVisibleTarget(player, currentTarget, isRevealFallback) {
      AutoAimHelper.UpdatePendingTarget(player);
      if !AutoAimHelper.PromotePendingTarget(player) {
        if IsDefined(currentTarget) && AutoAimHelper.IsCurrentTargetStillValid(player, currentTarget, isRevealFallback) {
          AutoAimHelper.ApplyTrackingCorrection(player, currentTarget, isRevealFallback);
        } else {
          AutoAimHelper.SetPendingTarget(player, null, false);
        }
      } else {
        currentTarget = AutoAimHelper.GetCurrentTarget(player);
        if IsDefined(currentTarget) {
          AutoAimHelper.ApplyNativeOpenADSLookAt(player, currentTarget);
        }
      }
      return;
    }

    if IsDefined(currentTarget) && AutoAimHelper.IsCurrentTargetStillValid(player, currentTarget, isRevealFallback) {
      if !isRevealFallback && AutoAimHelper.GetTargetDotToCrosshair(player, currentTarget) < 0.972 {
        AutoAimHelper.SetCurrentTarget(player, null, false);
        AutoAimHelper.UpdatePendingTarget(player);
        if AutoAimHelper.PromotePendingTarget(player) {
          currentTarget = AutoAimHelper.GetCurrentTarget(player);
          if IsDefined(currentTarget) {
            AutoAimHelper.ApplyNativeOpenADSLookAt(player, currentTarget);
          }
        } else {
          AutoAimHelper.SetPendingTarget(player, null, false);
        }
        return;
      }

      AutoAimHelper.UpdatePendingTarget(player);
      AutoAimHelper.ApplyTrackingCorrection(player, currentTarget, isRevealFallback);
      return;
    }

    AutoAimHelper.SetCurrentTarget(player, null, false);
    if AutoAimHelper.UpdatePendingTarget(player) {
      if AutoAimHelper.PromotePendingTarget(player) {
        currentTarget = AutoAimHelper.GetCurrentTarget(player);
        if IsDefined(currentTarget) {
          AutoAimHelper.ApplyNativeOpenADSLookAt(player, currentTarget);
        }
      }
      return;
    }

    AutoAimHelper.SetPendingTarget(player, null, false);
  }

  public static func OnFirePressed(player: ref<PlayerPuppet>) -> Void {
    let currentTarget: ref<GameObject>;

    if !IsDefined(player) {
      return;
    }

    if !AutoAimHelper.IsPlayerAiming(player) {
      return;
    }

    if !AutoAimHelper.ShouldUseMousePatch(player) || !AutoAimHelper.IsEligibleWeapon(player) {
      return;
    }

    currentTarget = AutoAimHelper.GetCurrentTarget(player);
    if IsDefined(currentTarget) {
      AutoAimHelper.ApplyFireCorrection(player, currentTarget);
    }
  }

  public static func OnADSEnd(player: ref<PlayerPuppet>) -> Void {
    AutoAimHelper.SetCurrentTarget(player, null, false);
    AutoAimHelper.SetPendingTarget(player, null, false);
    if IsDefined(player) {
      player.SetAutoAimFinalizeFrames(0);
    }
    AutoAimHelper.ClearNativeADS(player);
  }

  public static func ResolveOpenADSPreciseAimPosition(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let crosshairPos: Vector4;
    let crosshairFwd: Vector4;
    let bestComponent: wref<TargetingComponent>;
    let trackedComponent: wref<TargetingComponent>;
    let closestComponent: wref<IPlacedComponent>;
    let closestTargetComponent: wref<TargetingComponent>;
    let angleDistance: EulerAngles;
    let query: TargetSearchQuery;
    let componentOwner: ref<GameObject>;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return AutoAimHelper.ResolveStableTrackAimPosition(targetObject, aimPos);
    }

    targetingSystem.GetCrosshairData(player, crosshairPos, crosshairFwd);

    bestComponent = targetingSystem.GetBestComponentOnTargetObject(crosshairPos, crosshairFwd, targetObject, TargetComponentFilterType.HeadTarget);
    if IsDefined(bestComponent) {
      aimPos = Matrix.GetTranslation(bestComponent.GetLocalToWorld());
      return true;
    }

    if AIActionHelper.GetTargetSlotPosition(targetObject, n"Head", aimPos) {
      return true;
    }

    trackedComponent = targetingSystem.GetTrackedTargetComponent(player);
    if IsDefined(trackedComponent) {
      componentOwner = trackedComponent.GetEntity() as GameObject;
      if IsDefined(componentOwner) && componentOwner.GetEntityID() == targetObject.GetEntityID() {
        aimPos = Matrix.GetTranslation(trackedComponent.GetLocalToWorld());
        return true;
      }
    }

    bestComponent = targetingSystem.GetBestComponentOnTargetObject(crosshairPos, crosshairFwd, targetObject, TargetComponentFilterType.Shooting);
    if IsDefined(bestComponent) {
      aimPos = Matrix.GetTranslation(bestComponent.GetLocalToWorld());
      return true;
    }

    query = TSQ_EnemyNPC();
    query.maxDistance = 100.0;
    query.filterObjectByDistance = true;
    TargetSearchQuery.SetComponentFilter(query, TargetComponentFilterType.Shooting);
    closestComponent = targetingSystem.GetComponentClosestToCrosshair(player, angleDistance, query);
    closestTargetComponent = closestComponent as TargetingComponent;
    if IsDefined(closestTargetComponent) {
      componentOwner = closestTargetComponent.GetEntity() as GameObject;
      if IsDefined(componentOwner) && componentOwner.GetEntityID() == targetObject.GetEntityID() {
        aimPos = Matrix.GetTranslation(closestTargetComponent.GetLocalToWorld());
        return true;
      }
    }

    return AutoAimHelper.ResolveBestAimPosition(targetObject, aimPos);
  }

  public static func ResolveBestFireAimPosition(player: ref<PlayerPuppet>, targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    let targetingSystem: ref<TargetingSystem>;
    let crosshairPos: Vector4;
    let crosshairFwd: Vector4;
    let bestComponent: wref<TargetingComponent>;
    let trackedComponent: wref<TargetingComponent>;
    let closestComponent: wref<IPlacedComponent>;
    let closestTargetComponent: wref<TargetingComponent>;
    let angleDistance: EulerAngles;
    let query: TargetSearchQuery;
    let componentOwner: ref<GameObject>;

    if !IsDefined(player) || !IsDefined(targetObject) {
      return false;
    }

    targetingSystem = GameInstance.GetTargetingSystem(player.GetGame());
    if !IsDefined(targetingSystem) {
      return AutoAimHelper.ResolveBestAimPosition(targetObject, aimPos);
    }

    targetingSystem.GetCrosshairData(player, crosshairPos, crosshairFwd);

    bestComponent = targetingSystem.GetBestComponentOnTargetObject(crosshairPos, crosshairFwd, targetObject, TargetComponentFilterType.HeadTarget);
    if IsDefined(bestComponent) {
      aimPos = Matrix.GetTranslation(bestComponent.GetLocalToWorld());
      return true;
    }

    bestComponent = targetingSystem.GetBestComponentOnTargetObject(crosshairPos, crosshairFwd, targetObject, TargetComponentFilterType.Shooting);
    if IsDefined(bestComponent) {
      aimPos = Matrix.GetTranslation(bestComponent.GetLocalToWorld());
      return true;
    }

    trackedComponent = targetingSystem.GetTrackedTargetComponent(player);
    if IsDefined(trackedComponent) {
      componentOwner = trackedComponent.GetEntity() as GameObject;
      if IsDefined(componentOwner) && componentOwner.GetEntityID() == targetObject.GetEntityID() {
        aimPos = Matrix.GetTranslation(trackedComponent.GetLocalToWorld());
        return true;
      }
    }

    query = TSQ_EnemyNPC();
    query.maxDistance = 100.0;
    query.filterObjectByDistance = true;
    TargetSearchQuery.SetComponentFilter(query, TargetComponentFilterType.Shooting);
    closestComponent = targetingSystem.GetComponentClosestToCrosshair(player, angleDistance, query);
    closestTargetComponent = closestComponent as TargetingComponent;
    if IsDefined(closestTargetComponent) {
      componentOwner = closestTargetComponent.GetEntity() as GameObject;
      if IsDefined(componentOwner) && componentOwner.GetEntityID() == targetObject.GetEntityID() {
        aimPos = Matrix.GetTranslation(closestTargetComponent.GetLocalToWorld());
        return true;
      }
    }

    if AIActionHelper.GetTargetSlotPosition(targetObject, n"Head", aimPos) {
      return true;
    }

    return AutoAimHelper.ResolveBestAimPosition(targetObject, aimPos);
  }

  public static func ResolveStableTrackAimPosition(targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    let headPos: Vector4;

    if !IsDefined(targetObject) {
      return false;
    }

    if AIActionHelper.GetTargetSlotPosition(targetObject, n"Head", headPos) {
      aimPos = headPos;
      return true;
    }

    return AutoAimHelper.ResolveBestAimPosition(targetObject, aimPos);
  }

  public static func ResolveBestAimPosition(targetObject: ref<GameObject>, out aimPos: Vector4) -> Bool {
    let weakspotPos: Vector4;
    let headPos: Vector4;
    let chestPos: Vector4;

    if !IsDefined(targetObject) {
      return false;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"Weakspot", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"WeakPoint", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"Core", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"Backpack", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"FuelTank", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"Battery", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AutoAimHelper.TryWeakspotSlot(targetObject, n"Generator", weakspotPos) {
      aimPos = weakspotPos;
      return true;
    }

    if AIActionHelper.GetTargetSlotPosition(targetObject, n"Head", headPos) {
      aimPos = headPos;
      return true;
    }

    if AIActionHelper.GetTargetSlotPosition(targetObject, n"Chest", chestPos) {
      aimPos = chestPos;
      return true;
    }

    aimPos = targetObject.GetWorldPosition();
    return true;
  }

  public static func TryWeakspotSlot(targetObject: ref<GameObject>, slotName: CName, out slotPos: Vector4) -> Bool {
    if !IsDefined(targetObject) {
      return false;
    }

    return AIActionHelper.GetTargetSlotPosition(targetObject, slotName, slotPos);
  }
}
