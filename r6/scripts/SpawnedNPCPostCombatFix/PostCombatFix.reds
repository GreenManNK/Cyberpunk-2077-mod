module PostCombatFix

@if(ModuleExists("RedLogger"))
import RedLogger.*

private func RetreatTagName() -> CName = n"pcf_GangerCanRetreat";

private func BoardingWaitForDistanceInSeconds(distanceInMeters: Float) -> Float =
  12.0 + distanceInMeters / 1.5;

private func MaxBoardingWalkInMeters() -> Float = 50.0;

private func RetreatDistanceInMeters() -> Float = 300.0;

private func RetreatArrivalToleranceInMeters() -> Float = 2.0;

private func RetreatMovementType() -> moveMovementType = moveMovementType.Run;

private func DriveOffVerifyDelayInSeconds() -> Float = 2.5;

private func MountRefusedAboveVehicleSpeedInMetersPerSecond() -> Float = 0.50;

private func DebugLogEnabled() -> Bool = false;

@if(ModuleExists("RedLogger"))
public func PCFWriteLog(message: String) -> Void {
  RedLog.Append("[PCF]", message);
}

@if(!ModuleExists("RedLogger"))
public func PCFWriteLog(message: String) -> Void {
  FTLog(s"[PCF] \(message)");
}

private func LogRetreat(message: String) -> Void {
  if !DebugLogEnabled() {
    return;
  }
  PCFWriteLog(message);
}

private func HighLevelStateName(state: gamedataNPCHighLevelState) -> String =
  NameToString(EnumValueToName(n"gamedataNPCHighLevelState", Cast<Int64>(EnumInt(state))));

private func PuppetTag(puppet: wref<ScriptedPuppet>) -> String =
  EntityID.ToDebugString(puppet.GetEntityID());

private func VehicleSpeed(vehicle: wref<VehicleObject>) -> Float {
  if !IsDefined(vehicle) {
    return -1.0;
  }
  let blackboard: ref<IBlackboard> = vehicle.GetBlackboard();
  if !IsDefined(blackboard) {
    return -1.0;
  }
  return blackboard.GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue);
}

public func IsRetreatingNPC(puppet: wref<ScriptedPuppet>) -> Bool =
  IsDefined(puppet) && (puppet.m_pcfRetreatOptIn || NPCManager.HasTag(puppet.GetRecordID(), RetreatTagName()));

@addField(ScriptedPuppet)
let m_pcfSawCombat: Bool;

@addField(ScriptedPuppet)
let m_pcfRetreatMountOrdered: Bool;

@addField(ScriptedPuppet)
let m_pcfRetreatDestination: Vector4;

@addField(ScriptedPuppet)
let m_pcfBoardingVehicle: EntityID;

@addField(ScriptedPuppet)
let m_pcfBoardingSlot: CName;

@addField(ScriptedPuppet)
let m_pcfPromoteOnUnmount: Bool;

@addField(ScriptedPuppet)
let m_pcfBoardingAttempt: Int32;

@addField(ScriptedPuppet)
public let m_pcfRetreatOptIn: Bool;

@wrapMethod(ScriptedPuppet)
protected cb func OnDetach() -> Bool {
  ClearBoarding(this, "despawned");
  return wrappedMethod();
}

@wrapMethod(NPCPuppet)
protected func OnIncapacitated() -> Void {
  if EntityID.IsDefined(this.m_pcfBoardingVehicle) {
    LogRetreat(s"\(PuppetTag(this)) incapacitated while boarding");
    ClearBoarding(this, "incapacitated");
    CancelRetreatCommands(this, "incapacitated");
    this.m_pcfRetreatMountOrdered = false;
  }
  wrappedMethod();
}

private func IsRetreatStillValid(puppet: wref<ScriptedPuppet>) -> Bool =
  IsDefined(puppet) && puppet.IsActive()
    && NotEquals(puppet.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat);

@wrapMethod(ReactionManagerComponent)
protected cb func OnHighLevelStateDataEvent(evt: ref<gameHighLevelStateDataEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let puppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
  if !IsDefined(puppet) || puppet.GetEntityID() != evt.currentNPCEntityID {
    return result;
  }
  if !IsRetreatingNPC(puppet) {
    return result;
  }
  let state: gamedataNPCHighLevelState = evt.currentHighLevelState;
  let stateName: String = HighLevelStateName(state);
  if Equals(state, gamedataNPCHighLevelState.Combat)
    || Equals(state, gamedataNPCHighLevelState.Dead)
    || Equals(state, gamedataNPCHighLevelState.Unconscious) {
    ClearBoarding(puppet, stateName);
    CancelRetreatCommands(puppet, stateName);
  }
  if Equals(state, gamedataNPCHighLevelState.Combat) {
    puppet.m_pcfSawCombat = true;
    ClearDespawnCandidate(puppet);
    LogRetreat(s"\(PuppetTag(puppet)) -> \(stateName), latch set");
    return result;
  }
  if Equals(state, gamedataNPCHighLevelState.Relaxed)
    && puppet.IsActive()
    && EntityID.IsDefined(puppet.m_pcfBoardingVehicle)
    && !VehicleComponent.IsMountedToVehicle(puppet.GetGame(), puppet) {
    let mountAI: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
    if IsDefined(mountAI) && !mountAI.IsCommandActive(n"AIMountCommand") {
      ResendRetreatMountCommand(puppet);
      return result;
    }
  }
  if !puppet.m_pcfSawCombat {
    return result;
  }
  if NotEquals(state, gamedataNPCHighLevelState.Relaxed) {
    return result;
  }
  if !puppet.IsActive() {
    LogRetreat(s"\(PuppetTag(puppet)) -> \(stateName) but not active, skipped");
    return result;
  }
  LogRetreat(s"\(PuppetTag(puppet)) -> \(stateName), starting retreat");
  if RetreatSystem.Get(puppet.GetGame()).TryStartRetreat(puppet) {
    puppet.m_pcfSawCombat = false;
  }
  return result;
}

private func CancelRetreatCommand(aiComponent: ref<AIHumanComponent>, puppetTag: String, commandName: CName, reason: String) -> Void {
  if !aiComponent.IsCommandActive(commandName) {
    return;
  }
  let commandID: Int32 = aiComponent.GetActiveCommandID(commandName);
  let cancelled: Bool = aiComponent.CancelOrInterruptCommand(commandName, false, false);
  LogRetreat(s"\(puppetTag) \(NameToString(commandName)) id \(commandID) cancel (\(reason)) returned \(cancelled)");
}

private func CancelRetreatCommands(puppet: wref<ScriptedPuppet>, reason: String) -> Void {
  if !IsDefined(puppet) {
    return;
  }
  let aiComponent: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
  if !IsDefined(aiComponent) {
    return;
  }
  let puppetTag: String = PuppetTag(puppet);
  CancelRetreatCommand(aiComponent, puppetTag, n"AIMountCommand", reason);
  CancelRetreatCommand(aiComponent, puppetTag, n"AIMoveToCommand", reason);
}

private func LeaveStranded(puppet: wref<ScriptedPuppet>, reason: String) -> Bool {
  if !IsDefined(puppet) {
    return false;
  }
  let puppetTag: String = PuppetTag(puppet);
  let destination: Vector4;
  if !PickRetreatDestination(puppet, destination) {
    LogRetreat(s"\(puppetTag) stranded (\(reason)), no destination, left where he is");
    return false;
  }
  SendRetreatWalkCommand(puppet, destination);
  LogRetreat(s"\(puppetTag) stranded (\(reason)), sent away on foot, walking \(Vector4.Distance(puppet.GetWorldPosition(), destination))m");
  return true;
}

private func ClearDespawnCandidate(puppet: wref<ScriptedPuppet>) -> Void {
  if !IsDefined(puppet) {
    return;
  }
  let reactionSystem: ref<ReactionSystem> = GameInstance.GetReactionSystem(puppet.GetGame());
  if IsDefined(reactionSystem) {
    reactionSystem.UnmarkDespawnCandidate(puppet.GetEntityID());
  }
}

@addField(VehicleObject)
let m_pcfBoardersPending: Int32;

@addField(VehicleObject)
let m_pcfRetreatDriver: wref<ScriptedPuppet>;

@addField(VehicleObject)
let m_pcfPromotedDriver: wref<ScriptedPuppet>;

@addField(VehicleObject)
let m_pcfDriveOffPending: Bool;

@addField(VehicleObject)
let m_pcfDriveOffFromFreshEntry: Bool;

private func IsSeatFree(vehicle: wref<VehicleObject>, slotName: CName) -> Bool {
  if !VehicleComponent.IsSlotAvailable(vehicle.GetGame(), vehicle, slotName) {
    return false;
  }
  let vehicleAI: ref<AIVehicleAgent> = vehicle.GetAIComponent();
  if IsDefined(vehicleAI) && vehicleAI.IsSeatReserved(slotName) {
    return false;
  }
  return true;
}

private func FindFreeSeat(vehicle: wref<VehicleObject>, out slotName: CName) -> Bool {
  let seats: array<wref<VehicleSeat_Record>>;
  if !VehicleComponent.GetSeats(vehicle.GetGame(), vehicle, seats) {
    return false;
  }
  let driverSlot: CName = VehicleComponent.GetDriverSlotName();
  let index: Int32 = 0;
  while index < ArraySize(seats) {
    let candidate: CName = seats[index].SeatName();
    if NotEquals(candidate, driverSlot) && IsSeatFree(vehicle, candidate) {
      slotName = candidate;
      return true;
    }
    index += 1;
  }
  if IsSeatFree(vehicle, driverSlot) {
    slotName = driverSlot;
    return true;
  }
  return false;
}

private func SendRetreatMountCommand(puppet: wref<ScriptedPuppet>, vehicle: wref<VehicleObject>, slotName: CName, opt alreadyRegistered: Bool) -> Bool {
  let puppetTag: String = PuppetTag(puppet);
  let vehicleAI: ref<AIVehicleAgent> = vehicle.GetAIComponent();
  let aiComponent: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
  if !IsDefined(vehicleAI) || !IsDefined(aiComponent) {
    LogRetreat(s"\(puppetTag) mount aborted, no AI component on \(EntityID.ToDebugString(vehicle.GetEntityID()))");
    return false;
  }
  let reservedSlot: CName = vehicleAI.TryReserveSeatOrFirstAvailable(puppet.GetEntityID(), slotName);
  if !IsNameValid(reservedSlot) {
    LogRetreat(s"\(puppetTag) no seat reservable on \(EntityID.ToDebugString(vehicle.GetEntityID()))");
    return false;
  }
  if NotEquals(reservedSlot, slotName) {
    LogRetreat(s"\(puppetTag) asked for \(NameToString(slotName)), engine reserved \(NameToString(reservedSlot))");
  }
  aiComponent.OnSeatReserved(vehicle.GetEntityID());
  CancelRetreatCommands(puppet, "superseded by mount");
  let mountData: ref<MountEventData> = new MountEventData();
  mountData.slotName = reservedSlot;
  mountData.mountParentEntityId = vehicle.GetEntityID();
  mountData.isInstant = false;
  mountData.ignoreHLS = true;
  let command: ref<AIMountCommand> = new AIMountCommand();
  command.mountData = mountData;
  AIComponent.SendCommand(puppet, command);
  puppet.m_pcfRetreatMountOrdered = true;
  puppet.m_pcfBoardingSlot = reservedSlot;
  if !alreadyRegistered {
    puppet.m_pcfBoardingVehicle = vehicle.GetEntityID();
    vehicle.m_pcfBoardersPending += 1;
  }
  puppet.m_pcfBoardingAttempt += 1;
  let distanceInMeters: Float =
    Vector4.Distance(puppet.GetWorldPosition(), vehicle.GetWorldPosition());
  let waitInSeconds: Float = BoardingWaitForDistanceInSeconds(distanceInMeters);
  let giveUp: ref<GiveUpBoardingCommand> = new GiveUpBoardingCommand();
  giveUp.boarder = puppet;
  giveUp.attempt = puppet.m_pcfBoardingAttempt;
  GameInstance.GetDelaySystem(puppet.GetGame()).DelayCallback(giveUp, waitInSeconds);
  LogRetreat(s"\(puppetTag) mount sent, vehicle \(EntityID.ToDebugString(vehicle.GetEntityID())) slot \(NameToString(reservedSlot)), \(distanceInMeters)m to walk, ceiling \(waitInSeconds)s, vehicle speed \(VehicleSpeed(vehicle)), \(vehicle.m_pcfBoardersPending) boarder(s) out");
  return true;
}

private func ResendRetreatMountCommand(puppet: wref<ScriptedPuppet>) -> Void {
  let vehicle: wref<VehicleObject> =
    GameInstance.FindEntityByID(puppet.GetGame(), puppet.m_pcfBoardingVehicle) as VehicleObject;
  if !IsDefined(vehicle) {
    ClearBoarding(puppet, "vehicle gone before re-command");
    return;
  }
  LogRetreat(s"\(PuppetTag(puppet)) relaxed again with a mount outstanding, re-commanding to \(EntityID.ToDebugString(vehicle.GetEntityID())) slot \(NameToString(puppet.m_pcfBoardingSlot))");
  if !SendRetreatMountCommand(puppet, vehicle, puppet.m_pcfBoardingSlot, true) {
    ClearBoarding(puppet, "re-command refused");
    LeaveStranded(puppet, "re-command refused");
  }
}

private func TryPromotePassenger(vehicle: wref<VehicleObject>, passenger: wref<ScriptedPuppet>) -> Void {
  if !IsDefined(vehicle) || !IsRetreatStillValid(passenger) {
    return;
  }
  let passengerTag: String = PuppetTag(passenger);
  if vehicle.m_pcfBoardersPending > 0 {
    return;
  }
  if IsRetreatStillValid(vehicle.m_pcfPromotedDriver) {
    LogRetreat(s"\(passengerTag) promotion already in flight for \(PuppetTag(vehicle.m_pcfPromotedDriver)), left seated");
    return;
  }
  if VehicleComponent.HasActiveDriverMounted(vehicle.GetGame(), vehicle.GetEntityID()) {
    LogRetreat(s"\(passengerTag) driver present, nothing to do");
    return;
  }
  if !IsSeatFree(vehicle, VehicleComponent.GetDriverSlotName()) {
    LogRetreat(s"\(passengerTag) driver seat taken or reserved, left seated");
    return;
  }
  let blackboard: ref<IBlackboard> = passenger.GetPuppetStateBlackboard();
  if IsDefined(blackboard) && blackboard.GetBool(GetAllBlackboardDefs().PuppetState.WorkspotAnimationInProgress) {
    LogRetreat(s"\(passengerTag) animating, promotion skipped");
    return;
  }
  passenger.m_pcfPromoteOnUnmount = true;
  vehicle.m_pcfPromotedDriver = passenger;
  passenger.QueueEvent(AIEvents.ExitVehicleEvent());
  LogRetreat(s"\(passengerTag) no driver coming, sent out to take the wheel");
}

private func PromoteAnySeatedPassenger(vehicle: wref<VehicleObject>) -> Void {
  let passengers: array<wref<GameObject>>;
  VehicleComponent.GetAllPassengers(vehicle.GetGame(), vehicle.GetEntityID(), false, passengers);
  let index: Int32 = 0;
  while index < ArraySize(passengers) {
    let occupant: wref<ScriptedPuppet> = passengers[index] as ScriptedPuppet;
    if IsRetreatingNPC(occupant) && IsRetreatStillValid(occupant) {
      TryPromotePassenger(vehicle, occupant);
      return;
    }
    index += 1;
  }
}

private func ClearBoarding(puppet: wref<ScriptedPuppet>, reason: String) -> Void {
  if !IsDefined(puppet) || !EntityID.IsDefined(puppet.m_pcfBoardingVehicle) {
    return;
  }
  let vehicleID: EntityID = puppet.m_pcfBoardingVehicle;
  let cleared: EntityID;
  puppet.m_pcfBoardingVehicle = cleared;
  let vehicle: wref<VehicleObject> =
    GameInstance.FindEntityByID(puppet.GetGame(), vehicleID) as VehicleObject;
  if !IsDefined(vehicle) {
    return;
  }
  let aiComponent: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
  if IsDefined(aiComponent) {
    aiComponent.ReleaseReservedSeat();
  }
  let clearedSlot: CName;
  puppet.m_pcfBoardingSlot = clearedSlot;
  vehicle.m_pcfBoardersPending = Max(0, vehicle.m_pcfBoardersPending - 1);
  LogRetreat(s"\(PuppetTag(puppet)) off the boarding list for \(EntityID.ToDebugString(vehicleID)) (\(reason)), \(vehicle.m_pcfBoardersPending) still coming");
  if vehicle.m_pcfBoardersPending != 0 {
    return;
  }
  TryDriveOff(vehicle);
  PromoteAnySeatedPassenger(vehicle);
}

private func ArmDriveOff(vehicle: wref<VehicleObject>, driver: wref<ScriptedPuppet>, driverJustEntered: Bool) -> Void {
  if vehicle.HasTrafficSlot() {
    LogRetreat(s"\(EntityID.ToDebugString(vehicle.GetEntityID())) driver seated, traffic slot held, left to the crowd system");
    return;
  }
  if vehicle.m_pcfDriveOffPending {
    LogRetreat(s"\(EntityID.ToDebugString(vehicle.GetEntityID())) drive-off already sent and not yet verified, re-arm skipped");
    return;
  }
  vehicle.m_pcfRetreatDriver = driver;
  vehicle.m_pcfDriveOffFromFreshEntry = driverJustEntered;
  TryDriveOff(vehicle);
}

private func SendPanicDrive(vehicle: wref<VehicleObject>, driver: wref<ScriptedPuppet>, attemptLabel: String, useInitCmd: Bool) -> Void {
  let game: GameInstance = vehicle.GetGame();
  let vehicleTag: String = EntityID.ToDebugString(vehicle.GetEntityID());
  let vehicleAI: ref<AIVehicleAgent> = vehicle.GetAIComponent();
  if !IsDefined(vehicleAI) {
    LogRetreat(s"\(vehicleTag) drive-off ready but no vehicle AI component, dropped");
    return;
  }
  let anyCommandBefore: Bool = VehicleComponent.IsExecutingAnyCommand(game, vehicle);
  let initCommandWasSet: Bool = IsDefined(vehicleAI.GetInitCmd());
  vehicleAI.CancelOrInterruptCommand(n"AIVehicleDriveToPointAutonomousCommand", false, true);
  vehicleAI.CancelOrInterruptCommand(n"AIVehicleChaseCommand", false, true);
  LogRetreat(s"\(vehicleTag) drive commands interrupted, anyCommand \(anyCommandBefore) -> \(VehicleComponent.IsExecutingAnyCommand(game, vehicle)), init command was set \(initCommandWasSet)");
  let command: ref<AIVehiclePanicCommand> = new AIVehiclePanicCommand();
  command.needDriver = false;
  command.allowSimplifiedMovement = true;
  command.ignoreTickets = true;
  command.useSpeedBasedLookupRange = true;
  command.tryDriveAwayFromPlayer = false;
  if useInitCmd {
    vehicleAI.SetInitCmd(command);
  }
  let accepted: Bool = vehicleAI.SendCommand(command);
  LogRetreat(s"\(vehicleTag) panic drive (\(attemptLabel)) accepted \(accepted), initCmd used \(useInitCmd), executing \(vehicleAI.IsCommandExecuting(n"AIVehiclePanicCommand", false)), waiting \(vehicleAI.IsCommandWaiting(n"AIVehiclePanicCommand", false)), anyCommand \(VehicleComponent.IsExecutingAnyCommand(game, vehicle)), speed \(VehicleSpeed(vehicle)), canBeDriven \(VehicleComponent.CanBeDriven(game, vehicle))");
  vehicle.m_pcfDriveOffPending = true;
  let verify: ref<VerifyDriveOffCommand> = new VerifyDriveOffCommand();
  verify.vehicle = vehicle;
  verify.driver = driver;
  verify.attemptLabel = attemptLabel;
  verify.useInitCmd = useInitCmd;
  GameInstance.GetDelaySystem(game).DelayCallback(verify, DriveOffVerifyDelayInSeconds());
}

public class VerifyDriveOffCommand extends DelayCallback {

  public let vehicle: wref<VehicleObject>;

  public let driver: wref<ScriptedPuppet>;

  public let attemptLabel: String;

  public let useInitCmd: Bool;

  public func Call() -> Void {
    if !IsDefined(this.vehicle) {
      return;
    }
    this.vehicle.m_pcfDriveOffPending = false;
    let game: GameInstance = this.vehicle.GetGame();
    let vehicleTag: String = EntityID.ToDebugString(this.vehicle.GetEntityID());
    let vehicleAI: ref<AIVehicleAgent> = this.vehicle.GetAIComponent();
    if !IsDefined(vehicleAI) {
      LogRetreat(s"\(vehicleTag) drive-off check (\(this.attemptLabel)): vehicle AI gone");
      return;
    }
    let executing: Bool = vehicleAI.IsCommandExecuting(n"AIVehiclePanicCommand", false);
    let speedInMetersPerSecond: Float = VehicleSpeed(this.vehicle);
    LogRetreat(s"\(vehicleTag) drive-off check (\(this.attemptLabel)): panic executing \(executing), waiting \(vehicleAI.IsCommandWaiting(n"AIVehiclePanicCommand", false)), anyCommand \(VehicleComponent.IsExecutingAnyCommand(game, this.vehicle)), speed \(speedInMetersPerSecond), driver mounted \(VehicleComponent.HasActiveDriverMounted(game, this.vehicle.GetEntityID()))");
    if executing || speedInMetersPerSecond > MountRefusedAboveVehicleSpeedInMetersPerSecond() {
      return;
    }
    if NotEquals(this.attemptLabel, "first") {
      LogRetreat(s"\(vehicleTag) drive-off still not executing after the retry, left alone");
      return;
    }
    if !IsRetreatStillValid(this.driver)
      || !VehicleComponent.HasActiveDriverMounted(game, this.vehicle.GetEntityID()) {
      LogRetreat(s"\(vehicleTag) drive-off did not take and the driver is gone, dropped");
      return;
    }
    LogRetreat(s"\(vehicleTag) drive-off did not take, sending again");
    SendPanicDrive(this.vehicle, this.driver, "retry", this.useInitCmd);
  }
}

private func TryDriveOff(vehicle: wref<VehicleObject>) -> Void {
  if !IsDefined(vehicle) {
    return;
  }
  let driver: wref<ScriptedPuppet> = vehicle.m_pcfRetreatDriver;
  if !IsDefined(driver) {
    return;
  }
  let game: GameInstance = vehicle.GetGame();
  let vehicleTag: String = EntityID.ToDebugString(vehicle.GetEntityID());
  if !VehicleComponent.HasActiveDriverMounted(game, vehicle.GetEntityID()) {
    LogRetreat(s"\(vehicleTag) drive-off checked but no active driver, dropped");
    vehicle.m_pcfRetreatDriver = null;
    return;
  }
  if !IsRetreatStillValid(driver) {
    LogRetreat(s"\(vehicleTag) drive-off checked but driver \(PuppetTag(driver)) no longer retreating, dropped");
    vehicle.m_pcfRetreatDriver = null;
    return;
  }
  if vehicle.m_pcfBoardersPending > 0 {
    LogRetreat(s"\(vehicleTag) holding for \(vehicle.m_pcfBoardersPending) boarder(s)");
    return;
  }
  vehicle.m_pcfRetreatDriver = null;
  vehicle.m_pcfPromotedDriver = null;
  SendPanicDrive(vehicle, driver, "first", vehicle.m_pcfDriveOffFromFreshEntry);
}

@wrapMethod(VehicleComponent)
protected cb func OnVehicleFinishedMountingEvent(evt: ref<VehicleFinishedMountingEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let puppet: ref<ScriptedPuppet> = evt.character as ScriptedPuppet;
  if !IsDefined(puppet) || (!puppet.m_pcfRetreatMountOrdered && !puppet.m_pcfPromoteOnUnmount) {
    if IsDefined(puppet) && !evt.isMounting && IsRetreatingNPC(puppet) {
      let leftVehicle: wref<VehicleObject> = this.GetVehicle();
      if IsDefined(leftVehicle) {
        LogRetreat(s"\(PuppetTag(puppet)) left slot \(NameToString(evt.slotID)) of \(EntityID.ToDebugString(leftVehicle.GetEntityID())) unprompted, state \(HighLevelStateName(puppet.GetHighLevelStateFromBlackboard()))");
      }
    }
    return result;
  }
  let puppetTag: String = PuppetTag(puppet);
  LogRetreat(s"\(puppetTag) mounting event: slot \(NameToString(evt.slotID)) isMounting \(evt.isMounting)");
  if !evt.isMounting {
    if puppet.m_pcfPromoteOnUnmount {
      puppet.m_pcfPromoteOnUnmount = false;
      let exitedVehicle: wref<VehicleObject> = this.GetVehicle();
      if !IsRetreatStillValid(puppet) {
        if IsDefined(exitedVehicle) {
          exitedVehicle.m_pcfPromotedDriver = null;
        }
        LogRetreat(s"\(puppetTag) out but no longer retreating, promotion dropped");
        return result;
      }
      if IsDefined(exitedVehicle) && !SendRetreatMountCommand(puppet, exitedVehicle, VehicleComponent.GetDriverSlotName()) {
        exitedVehicle.m_pcfPromotedDriver = null;
        LogRetreat(s"\(puppetTag) out but the wheel is gone, walking instead");
        LeaveStranded(puppet, "promotion re-mount refused");
      } else {
        LogRetreat(s"\(puppetTag) out, re-commanded to the wheel");
      }
    }
    return result;
  }
  if !VehicleComponent.IsDriverSlot(evt.slotID) {
    LogRetreat(s"\(puppetTag) seated as passenger");
    TryPromotePassenger(this.GetVehicle(), puppet);
    return result;
  }
  let seatedVehicle: wref<VehicleObject> = this.GetVehicle();
  if IsDefined(seatedVehicle) && IsDefined(seatedVehicle.m_pcfPromotedDriver)
    && seatedVehicle.m_pcfPromotedDriver.GetEntityID() == puppet.GetEntityID() {
    seatedVehicle.m_pcfPromotedDriver = null;
    LogRetreat(s"\(puppetTag) reached the wheel, promotion closed");
  }
  return result;
}

@wrapMethod(EnterVehicle)
protected func Deactivate(context: ScriptExecutionContext) -> Void {
  wrappedMethod(context);
  let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
  if !IsDefined(puppet) || !puppet.m_pcfRetreatMountOrdered {
    return;
  }
  let game: GameInstance = puppet.GetGame();
  let puppetTag: String = PuppetTag(puppet);
  LogRetreat(s"\(puppetTag) entry animation finished");
  ClearBoarding(puppet, "seated");
  puppet.m_pcfRetreatMountOrdered = false;
  if !VehicleComponent.IsDriver(game, puppet) {
    return;
  }
  if !IsRetreatStillValid(puppet) {
    LogRetreat(s"\(puppetTag) entry finished but no longer retreating, drive-off dropped");
    return;
  }
  let vehicle: wref<VehicleObject>;
  if !VehicleComponent.GetVehicle(game, puppet, vehicle) || !IsDefined(vehicle) {
    LogRetreat(s"\(puppetTag) entry finished but vehicle handle null, aborted");
    return;
  }
  ArmDriveOff(vehicle, puppet, true);
}

public class GiveUpBoardingCommand extends DelayCallback {

  public let boarder: wref<ScriptedPuppet>;

  public let attempt: Int32;

  public func Call() -> Void {
    if !IsDefined(this.boarder) {
      return;
    }
    let puppetTag: String = PuppetTag(this.boarder);
    if this.attempt != this.boarder.m_pcfBoardingAttempt {
      LogRetreat(s"\(puppetTag) boarding ceiling from attempt \(this.attempt) but attempt \(this.boarder.m_pcfBoardingAttempt) is live, ignored");
      return;
    }
    if !EntityID.IsDefined(this.boarder.m_pcfBoardingVehicle) {
      return;
    }
    if VehicleComponent.IsMountedToVehicle(this.boarder.GetGame(), this.boarder) {
      LogRetreat(s"\(puppetTag) boarding ceiling reached but already in the seat, left to finish");
      return;
    }
    let remainingInMeters: Float = -1.0;
    let boardingVehicle: wref<VehicleObject> = GameInstance.FindEntityByID(
      this.boarder.GetGame(), this.boarder.m_pcfBoardingVehicle) as VehicleObject;
    if IsDefined(boardingVehicle) {
      remainingInMeters =
        Vector4.Distance(this.boarder.GetWorldPosition(), boardingVehicle.GetWorldPosition());
    }
    LogRetreat(s"\(puppetTag) boarding ceiling reached, giving up \(remainingInMeters)m short, vehicle speed \(VehicleSpeed(boardingVehicle))");
    ClearBoarding(this.boarder, "gave up walking");
    this.boarder.m_pcfRetreatMountOrdered = false;
    CancelRetreatCommands(this.boarder, "gave up walking");
    LeaveStranded(this.boarder, "never reached the vehicle");
  }
}

private func PickRetreatDestination(puppet: wref<ScriptedPuppet>, out destination: Vector4) -> Bool {
  let puppetTag: String = PuppetTag(puppet);
  if !Vector4.IsZero(puppet.m_pcfRetreatDestination) {
    destination = puppet.m_pcfRetreatDestination;
    LogRetreat(s"\(puppetTag) resuming destination, \(Vector4.Distance(puppet.GetWorldPosition(), destination))m to go");
    return true;
  }
  let player: ref<PlayerPuppet> = GetPlayer(puppet.GetGame());
  if !IsDefined(player) {
    LogRetreat(s"\(puppetTag) no player, no destination");
    return false;
  }
  let position: Vector4 = puppet.GetWorldPosition();
  let playerPosition: Vector4 = player.GetWorldPosition();
  let away: Vector4 = new Vector4(position.X - playerPosition.X, position.Y - playerPosition.Y, 0.0, 0.0);
  if Vector4.IsZero(away) {
    LogRetreat(s"\(puppetTag) no direction away from the player, no destination");
    return false;
  }
  away = Vector4.Normalize2D(away);
  destination = new Vector4(position.X + away.X * RetreatDistanceInMeters(),
                            position.Y + away.Y * RetreatDistanceInMeters(),
                            position.Z, 1.0);
  puppet.m_pcfRetreatDestination = destination;
  LogRetreat(s"\(puppetTag) destination picked, \(RetreatDistanceInMeters())m away");
  return true;
}

private func SendRetreatWalkCommand(puppet: wref<ScriptedPuppet>, destination: Vector4) -> Void {
  CancelRetreatCommands(puppet, "superseded by walk");
  ClearDespawnCandidate(puppet);
  let command: ref<AIMoveToCommand> = new AIMoveToCommand();
  let targetPosition: WorldPosition;
  WorldPosition.SetVector4(targetPosition, destination);
  AIPositionSpec.SetWorldPosition(command.movementTarget, targetPosition);
  command.movementType = RetreatMovementType();
  command.desiredDistanceFromTarget = RetreatArrivalToleranceInMeters();
  command.finishWhenDestinationReached = true;
  command.ignoreNavigation = false;
  command.useStart = true;
  command.useStop = true;
  command.rotateEntityTowardsFacingTarget = false;
  command.alwaysUseStealth = false;
  command.removeAfterCombat = true;
  command.ignoreInCombat = false;
  AIComponent.SendCommand(puppet, command);
  let aiComponent: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
  if IsDefined(aiComponent) {
    LogRetreat(s"\(PuppetTag(puppet)) walk command landed: \(aiComponent.IsCommandActive(n"AIMoveToCommand"))");
  }
}

public class RetreatSystem extends ScriptableSystem {

  public final static func Get(game: GameInstance) -> ref<RetreatSystem> =
    GameInstance.GetScriptableSystemsContainer(game).Get(n"PostCombatFix.RetreatSystem") as RetreatSystem;

  public final func TryStartRetreat(puppet: wref<ScriptedPuppet>) -> Bool {
    let vehicleID: EntityID;
    let vehicleSlot: MountingSlotId;
    let game: GameInstance = puppet.GetGame();
    let puppetTag: String = PuppetTag(puppet);

    if VehicleComponent.IsMountedToVehicle(game, puppet) {
      let mountedVehicle: wref<VehicleObject>;
      if !VehicleComponent.GetVehicle(game, puppet, mountedVehicle) || !IsDefined(mountedVehicle) {
        LogRetreat(s"\(puppetTag) gate mounted: vehicle handle null, skipped");
        return false;
      }
      if VehicleComponent.IsDriver(game, puppet) {
        LogRetreat(s"\(puppetTag) gate mounted: already driving, arming drive-off");
        ArmDriveOff(mountedVehicle, puppet, false);
        return true;
      }
      LogRetreat(s"\(puppetTag) gate mounted: seated as passenger");
      TryPromotePassenger(mountedVehicle, puppet);
      return true;
    }

    let aiComponent: ref<AIHumanComponent> = puppet.GetAIControllerComponent();
    if !IsDefined(aiComponent) || !aiComponent.GetAssignedVehicleData(vehicleID, vehicleSlot) {
      LogRetreat(s"\(puppetTag) gate assignment: no assigned vehicle");
      return LeaveStranded(puppet, "no assigned vehicle");
    }

    let vehicle: ref<VehicleObject> = GameInstance.FindEntityByID(game, vehicleID) as VehicleObject;
    if !IsDefined(vehicle) {
      return LeaveStranded(puppet, s"assigned vehicle \(EntityID.ToDebugString(vehicleID)) not found");
    }
    if VehicleComponent.IsDestroyed(game, vehicleID) {
      return LeaveStranded(puppet, s"vehicle \(EntityID.ToDebugString(vehicleID)) destroyed");
    }
    if vehicle.IsFlippedOver() {
      return LeaveStranded(puppet, s"vehicle \(EntityID.ToDebugString(vehicleID)) flipped");
    }
    let distanceToVehicleInMeters: Float =
      Vector4.Distance(puppet.GetWorldPosition(), vehicle.GetWorldPosition());
    if distanceToVehicleInMeters > MaxBoardingWalkInMeters() {
      return LeaveStranded(puppet, s"vehicle \(EntityID.ToDebugString(vehicleID)) \(distanceToVehicleInMeters)m away");
    }
    if NotEquals(vehicleSlot.id, VehicleComponent.GetDriverSlotName())
      && VehicleComponent.IsDriverSeatOccupiedByDeadNPC(game, vehicleID) {
      return LeaveStranded(puppet, s"driver seat of \(EntityID.ToDebugString(vehicleID)) held by a body");
    }
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(puppet, n"BlockMountVehicle") {
      LogRetreat(s"\(puppetTag) gate condition: BlockMountVehicle, skipped");
      return false;
    }

    if !IsSeatFree(vehicle, vehicleSlot.id) {
      let fallbackSlot: CName;
      if !FindFreeSeat(vehicle, fallbackSlot) {
        return LeaveStranded(puppet, s"slot \(NameToString(vehicleSlot.id)) taken and no free seat");
      }
      LogRetreat(s"\(puppetTag) slot \(NameToString(vehicleSlot.id)) taken, trying \(NameToString(fallbackSlot)) instead");
      if !SendRetreatMountCommand(puppet, vehicle, fallbackSlot) {
        return LeaveStranded(puppet, "fallback seat could not be reserved");
      }
      return true;
    }
    if !SendRetreatMountCommand(puppet, vehicle, vehicleSlot.id) {
      return LeaveStranded(puppet, "assigned seat could not be reserved");
    }
    return true;
  }

}
