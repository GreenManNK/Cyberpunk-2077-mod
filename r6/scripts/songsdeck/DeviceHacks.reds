module SongsDeck

public func SongsDeckLog(msg: String) -> Void {
  let DEBUG: Bool = false;
  if DEBUG {
    FTLog(s"[SongsDeck] \(msg)");
  }
}

public func HasBlackwallDeck(gi: GameInstance) -> Bool {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if !IsDefined(player) {
    return false;
  }

  let equipment: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"EquipmentSystem") as EquipmentSystem;
  if !IsDefined(equipment) {
    return false;
  }

  let slot: Int32 = 0;
  while slot <= 2 {
    let itemID: ItemID = equipment.GetItemInEquipSlot(player, gamedataEquipmentArea.SystemReplacementCW, slot);
    if ItemID.IsValid(itemID) {
      let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
      if IsDefined(record) && record.TagsContains(n"BlackwallInterface") {
        return true;
      }
    }
    slot += 1;
  }

  return false;
}

public func LogActionList(label: String, actions: array<ref<DeviceAction>>) -> Void {
  SongsDeckLog(s"\(label): count=\(ArraySize(actions))");
  let i: Int32 = 0;
  while i < ArraySize(actions) {
    let sAction: ref<ScriptableDeviceAction> = actions[i] as ScriptableDeviceAction;
    if IsDefined(sAction) {
      let rec: wref<ObjectAction_Record> = sAction.GetObjectActionRecord();
      let name: CName = n"nil";
      if IsDefined(rec) {
        name = rec.ActionName();
      }
      SongsDeckLog(s"  [\(i)] class=\(sAction.GetClassName()) actionName=\(name) inactive=\(sAction.IsInactive()) reason=\(sAction.GetInactiveReason())");
    }
    i += 1;
  }
}

public func IsVanillaDoorToggleHack(sAction: ref<ScriptableDeviceAction>) -> Bool {
  if !IsDefined(sAction) {
    return false;
  }
  if IsDefined(sAction as QuickHackToggleOpen) {
    return true;
  }
  let rec: wref<ObjectAction_Record> = sAction.GetObjectActionRecord();
  if IsDefined(rec) && Equals(rec.ActionName(), n"ToggleStateClassHack") {
    return true;
  }
  return Equals(sAction.GetClassName(), n"QuickHackToggleOpen");
}

public func SongsDeckStripVanillaDoorToggle(out actions: array<ref<DeviceAction>>) -> Void {
  let i: Int32 = ArraySize(actions) - 1;
  while i >= 0 {
    if IsVanillaDoorToggleHack(actions[i] as ScriptableDeviceAction) {
      ArrayErase(actions, i);
    }
    i -= 1;
  }
}

public func ActionsContainSongsDeckHack(actions: array<ref<DeviceAction>>) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(actions) {
    let sAction: ref<ScriptableDeviceAction> = actions[i] as ScriptableDeviceAction;
    if IsDefined(sAction) {
      let rec: wref<ObjectAction_Record> = sAction.GetObjectActionRecord();
      if IsDefined(rec) {
        let name: CName = rec.ActionName();
        if Equals(name, n"SongsDeckDoorHack") || Equals(name, n"SongsDeckCameraHack") {
          return true;
        }
      }
    }
    i += 1;
  }
  return false;
}


public class SongsDeckDoorHackAction extends ActionBool {
  public final func SetProperties() -> Void {
    this.actionName = n"SongsDeckDoorHack";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class SongsDeckCameraHackAction extends ActionBool {
  public final func SetProperties() -> Void {
    this.actionName = n"SongsDeckCameraHack";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}


@addMethod(DoorControllerPS)
public final func ActionSongsDeckDoorHack() -> ref<SongsDeckDoorHackAction> {
  let action: ref<SongsDeckDoorHackAction> = new SongsDeckDoorHackAction();
  action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
  action.SetUp(this);
  action.SetProperties();
  action.AddDeviceName(this.m_deviceName);
  action.CreateInteraction();
  action.SetObjectActionID(t"DeviceAction.SongsDeckDoorHack");
  action.SetExecutor(GetPlayer(this.GetGameInstance()));
  return action;
}

@addMethod(SensorDeviceControllerPS)
public final func ActionSongsDeckCameraHack() -> ref<SongsDeckCameraHackAction> {
  let action: ref<SongsDeckCameraHackAction> = new SongsDeckCameraHackAction();
  action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
  action.SetUp(this);
  action.SetProperties();
  action.AddDeviceName(this.m_deviceName);
  action.CreateInteraction();
  action.SetObjectActionID(t"DeviceAction.SongsDeckCameraHack");
  action.SetExecutor(GetPlayer(this.GetGameInstance()));
  return action;
}

// Inject AFTER vanilla so HasQuickHacksDisabled / Finalize clears cannot wipe us.
@addMethod(ScriptableDeviceComponentPS)
public final func SongsDeckInjectHackAction(out actions: array<ref<DeviceAction>>) -> Bool {
  if !IsSongsDeckHackEligible(this) {
    return false;
  }
  if ActionsContainSongsDeckHack(actions) {
    return false;
  }

  let door: ref<DoorControllerPS> = this as DoorControllerPS;
  let sensor: ref<SensorDeviceControllerPS> = this as SensorDeviceControllerPS;
  if IsDefined(door) {
    ArrayPush(actions, door.ActionSongsDeckDoorHack());
  } else if IsDefined(sensor) && (IsDefined(this as SurveillanceCameraControllerPS) || IsDefined(this as SecurityTurretControllerPS)) {
    ArrayPush(actions, sensor.ActionSongsDeckCameraHack());
  } else {
    return false;
  }

  // Do NOT call FinalizeGetQuickHackActions here — it Clears the list when
  // HasQuickHacksDisabled is true. Mark/executioner is enough for the panel match.
  this.MarkActionsAsQuickHacks(actions);
  this.SetActionsQuickHacksExecutioner(actions);
  SongsDeckLog(s"Injected deck hack (disableQH=\(this.HasQuickHacksDisabled())) count=\(ArraySize(actions))");
  return true;
}


@wrapMethod(DoorControllerPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, const context: script_ref<GetActionsContext>) -> Void {
  EnsureSongsDeckPlaystyle(this);
  SongsDeckLog(s"Door.GetQuickHackActions eligible=\(IsSongsDeckHackEligible(this)) exposeAP=\(this.ExposeQuickHakcsIfNotConnnectedToAP()) backdoor=\(this.IsConnectedToBackdoorDevice()) disableQH=\(this.HasQuickHacksDisabled()) playstyle=\(this.HasPlaystyle(EPlaystyle.NETRUNNER))");
  wrappedMethod(actions, context);
  if IsSongsDeckForcedDoor(this) {
    SongsDeckStripVanillaDoorToggle(actions);
  }
  this.SongsDeckInjectHackAction(actions);
  LogActionList("Door.GetQuickHackActions EXIT", actions);
}

@wrapMethod(SurveillanceCameraControllerPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, const context: script_ref<GetActionsContext>) -> Void {
  EnsureSongsDeckPlaystyle(this);
  SongsDeckLog(s"Camera.GetQuickHackActions eligible=\(IsSongsDeckHackEligible(this)) disableQH=\(this.HasQuickHacksDisabled()) playstyle=\(this.HasPlaystyle(EPlaystyle.NETRUNNER))");
  wrappedMethod(actions, context);
  this.SongsDeckInjectHackAction(actions);
  LogActionList("Camera.GetQuickHackActions EXIT", actions);
}

@wrapMethod(SecurityTurretControllerPS)
protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, const context: script_ref<GetActionsContext>) -> Void {
  EnsureSongsDeckPlaystyle(this);
  SongsDeckLog(s"Turret.GetQuickHackActions eligible=\(IsSongsDeckHackEligible(this)) disableQH=\(this.HasQuickHacksDisabled()) playstyle=\(this.HasPlaystyle(EPlaystyle.NETRUNNER))");
  wrappedMethod(actions, context);
  this.SongsDeckInjectHackAction(actions);
  LogActionList("Turret.GetQuickHackActions EXIT", actions);
}

@wrapMethod(ScriptableDeviceComponentPS)
public func GetRemoteActions(out outActions: array<ref<DeviceAction>>, const context: script_ref<GetActionsContext>) -> Void {
  if !IsSongsDeckHackTarget(this) {
    wrappedMethod(outActions, context);
    return;
  }
  EnsureSongsDeckPlaystyle(this);
  let kind: String = "Sensor";
  if IsDefined(this as DoorControllerPS) {
    kind = "Door";
  } else if IsDefined(this as SurveillanceCameraControllerPS) {
    kind = "Camera";
  } else if IsDefined(this as SecurityTurretControllerPS) {
    kind = "Turret";
  }
  SongsDeckLog(s"\(kind).GetRemoteActions eligible=\(IsSongsDeckHackEligible(this)) exposed=\(this.IsQuickHacksExposed()) disableQH=\(this.HasQuickHacksDisabled()) isDisabled=\(this.IsDisabled()) playstyle=\(this.HasPlaystyle(EPlaystyle.NETRUNNER))");
  wrappedMethod(outActions, context);
  let door: ref<DoorControllerPS> = this as DoorControllerPS;
  if IsDefined(door) && IsSongsDeckForcedDoor(door) {
    SongsDeckStripVanillaDoorToggle(outActions);
  }
  this.SongsDeckInjectHackAction(outActions);
  LogActionList(s"\(kind).GetRemoteActions EXIT", outActions);
}

@wrapMethod(ScriptableDeviceComponentPS)
public const func IsPotentiallyQuickHackable() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this);
}

@addField(SecurityTurret)
let blackwallDownlinkActive: Bool = false;

@addMethod(SecurityTurret)
public func SetBlackwallDownlinkActive(active: Bool) {
  this.blackwallDownlinkActive = active;
}

@addMethod(SecurityTurret)
public func IsBlackwallDownlinkActive() -> Bool {
  return this.blackwallDownlinkActive;
}

// Pairwise Hostile so FriendlyTurret senses can see the NPC, then quest-follow
// to force RecognizeTarget(..., true) without waiting on detection rise.
@addMethod(SecurityTurret)
public func SongsDeckMarkHostile(target: wref<GameObject>) -> Void {
  if !this.blackwallDownlinkActive || !IsDefined(target) {
    return;
  }
  let targetAgent: ref<AttitudeAgent> = target.GetAttitudeAgent();
  if !IsDefined(targetAgent) || !IsDefined(this.GetAttitudeAgent()) {
    return;
  }
  this.GetAttitudeAgent().SetAttitudeTowardsAgentGroup(
    targetAgent,
    this.GetAttitudeAgent(),
    EAIAttitude.AIA_Hostile
  );
}

@addMethod(SecurityTurret)
public func SongsDeckForceEngageTarget(target: wref<GameObject>) -> Void {
  if !this.blackwallDownlinkActive || !IsDefined(target) {
    return;
  }

  this.SongsDeckMarkHostile(target);

  let ps: ref<SensorDeviceControllerPS> = this.GetDevicePS();
  if !IsDefined(ps) {
    return;
  }

  let follow: ref<QuestFollowTarget> = new QuestFollowTarget();
  follow.clearanceLevel = 99;
  follow.SetUp(ps);
  follow.SetProperties();
  follow.m_ForcedTarget = target.GetEntityID();
  ps.ExecutePSAction(follow);
  SongsDeckLog(s"ForceEngage \(target.GetClassName())");
}

// Combat-threat path (narrow). Broader EnemyNPC arming is done from CET via TSQ.
@addMethod(SecurityTurret)
public func SongsDeckAcquirePlayerHostiles() -> Void {
  if !this.blackwallDownlinkActive {
    return;
  }

  this.SetHostileTowardsPlayerHostiles(true);
  this.ReevaluateTargets();
  SongsDeckLog("AcquirePlayerHostiles + ReevaluateTargets");
}

private func SongsDeckIsHijackedTurret(device: ref<SensorDevice>) -> Bool {
  let turret: ref<SecurityTurret> = device as SecurityTurret;
  return IsDefined(turret) && turret.IsBlackwallDownlinkActive();
}

private func SongsDeckIsPlayerTarget(device: ref<SensorDevice>, target: wref<GameObject>) -> Bool {
  if !IsDefined(target) {
    return false;
  }
  if target.IsPlayer() {
    return true;
  }
  let player: ref<PlayerPuppet> = GetPlayer(device.GetGame());
  return IsDefined(player) && Equals(target.GetEntityID(), player.GetEntityID());
}

// Wrap SensorDevice (where the method lives) so ReevaluateTargets / RecognizeTarget
// actually hit this — wrapping only SecurityTurret can miss parent call sites.
@wrapMethod(SensorDevice)
public func SetAsIntrestingTarget(target: wref<GameObject>) -> Bool {
  if !SongsDeckIsHijackedTurret(this) {
    return wrappedMethod(target);
  }

  let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
  if !IsDefined(player) || !IsDefined(target) {
    return false;
  }

  if SongsDeckIsPlayerTarget(this, target) {
    SongsDeckLog("turret interesting? PLAYER -> false");
    return false;
  }

  // Prefer pairwise hostility from TSQ arming; also player-hostile combat threats.
  if Equals(GameObject.GetAttitudeTowards(this, target), EAIAttitude.AIA_Hostile) {
    SongsDeckLog(s"turret interesting? \(target.GetClassName()) turretHostile=true");
    return true;
  }
  if Equals(GameObject.GetAttitudeTowards(player, target), EAIAttitude.AIA_Hostile) {
    SongsDeckLog(s"turret interesting? \(target.GetClassName()) playerHostile=true");
    return true;
  }
  SongsDeckLog(s"turret interesting? \(target.GetClassName()) -> false");
  return false;
}

// SS "support" path: AddTarget(player, interesting=true) + ForcedLookAt — bypasses SetAsIntrestingTarget.
@wrapMethod(SensorDevice)
protected cb func OnSecuritySystemSupport(evt: ref<SecuritySystemSupport>) -> Bool {
  if SongsDeckIsHijackedTurret(this) {
    SongsDeckLog("blocked OnSecuritySystemSupport (hijacked turret)");
    return false;
  }
  return wrappedMethod(evt);
}

// Player detection rise calls RecognizeTarget(player, questForcedInteresting=true),
// which forces interesting=true even when SetAsIntrestingTarget returns false.
@wrapMethod(SensorDevice)
protected cb func OnDetectionRiseEvent(evt: ref<DetectionRiseEvent>) -> Bool {
  if SongsDeckIsHijackedTurret(this) && SongsDeckIsPlayerTarget(this, evt.target) {
    SongsDeckLog("blocked OnDetectionRiseEvent on PLAYER (hijacked turret)");
    return false;
  }
  return wrappedMethod(evt);
}

// SS COMBAT/ALERTED locking once something is already current target.
@wrapMethod(SensorDevice)
public func OnCurrentTargetAppears(target: wref<GameObject>) -> Void {
  if SongsDeckIsHijackedTurret(this) && SongsDeckIsPlayerTarget(this, target) {
    SongsDeckLog("blocked OnCurrentTargetAppears on PLAYER (hijacked turret)");
    return;
  }
  wrappedMethod(target);
}

// SS can slap its attitude group back onto the turret.
@wrapMethod(SensorDevice)
protected cb func OnSecuritySystemForceAttitudeChange(evt: ref<SecuritySystemForceAttitudeChange>) -> Bool {
  if SongsDeckIsHijackedTurret(this) {
    SongsDeckLog("blocked OnSecuritySystemForceAttitudeChange (hijacked turret)");
    return false;
  }
  return wrappedMethod(evt);
}

@wrapMethod(SensorDevice)
protected cb func OnSecuritySystemEnabled(evt: ref<SecuritySystemEnabled>) -> Bool {
  if SongsDeckIsHijackedTurret(this) {
    SongsDeckLog("blocked OnSecuritySystemEnabled attitude grab (hijacked turret)");
    return false;
  }
  return wrappedMethod(evt);
}

@wrapMethod(SensorDevice)
protected cb func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> Bool {
  if SongsDeckIsHijackedTurret(this) {
    SongsDeckLog("blocked OnTargetAssessmentRequest (hijacked turret)");
    return false;
  }
  return wrappedMethod(evt);
}
