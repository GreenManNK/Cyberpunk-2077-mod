module RABlueMoon.ApartmentWaypoint

@addMethod(BaseMappinBaseController)
protected final func __raBMIsBlueMoonPin() -> Bool {
  let markerLabel: String = this.GetMappin().GetDisplayName();
  let markerParts: array<String> = StrSplit(markerLabel, "|");
  return ArraySize(markerParts) >= 3 && Equals(markerParts[0], "RABlueMoon");
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);
  let markerLabel: String = Deref(data).mappin.GetDisplayName();
  let markerParts: array<String> = StrSplit(markerLabel, "|");
  if ArraySize(markerParts) >= 3 && Equals(markerParts[0], "RABlueMoon") {
    inkTextRef.SetText(this.m_titleText, markerParts[1]);
    inkTextRef.SetText(this.m_descText, markerParts[2]);
  };
}

public class RABlueMoonWaypointTick extends Event {}

// H10 mirror leave teleport nudge.
public class RABlueMoonH10TeleportPollEvent extends Event {}
public class RABlueMoonH10TeleportStartEvent extends Event {}
public class RABlueMoonH10TeleportReturnEvent extends Event {}

@addField(PlayerPuppet)
private let raBMWaypointID: NewMappinID;

@addField(PlayerPuppet)
private let raBMWaypointVisible: Bool;

@addField(PlayerPuppet)
private let raBMWaypointDestination: Int32;

@addField(PlayerPuppet)
private let raBMNGPlusBridgeTicks: Int32;

@addField(PlayerPuppet)
private let raBMH10TeleportWaiting: Bool;

@addField(PlayerPuppet)
private let raBMH10TeleportReturning: Bool;

@addField(PlayerPuppet)
private let raBMH10ReturnPosition: Vector4;

@addField(PlayerPuppet)
private let raBMH10ReturnRotation: EulerAngles;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  if !this.IsReplacer() && !this.IsJohnnyReplacer() {
    this.raBMNGPlusBridgeTicks = 0;
    this.raBMH10TeleportWaiting = false;
    this.raBMH10TeleportReturning = false;
    this.RABMScheduleWaypointTick(1.00);
    this.RABMScheduleH10TeleportPoll(0.05);
  };
  return result;
}

@addMethod(PlayerPuppet)
private final func RABMScheduleWaypointTick(delay: Float) -> Void {
  let evt: ref<RABlueMoonWaypointTick> = new RABlueMoonWaypointTick();
  GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, delay, false);
}

@addMethod(PlayerPuppet)
protected cb func OnRABlueMoonWaypointTick(evt: ref<RABlueMoonWaypointTick>) -> Bool {
  this.RABMRefreshNGPlusBridge();
  this.RABMRefreshApartmentWaypoint();
  this.RABMScheduleWaypointTick(1.00);
  return true;
}

@addMethod(PlayerPuppet)
private final func RABMScheduleH10TeleportPoll(delay: Float) -> Void {
  let evt: ref<RABlueMoonH10TeleportPollEvent> = new RABlueMoonH10TeleportPollEvent();
  GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, delay, false);
}

@addMethod(PlayerPuppet)
protected cb func OnRABlueMoonH10TeleportPollEvent(evt: ref<RABlueMoonH10TeleportPollEvent>) -> Bool {
  let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());

  if IsDefined(qs) && !this.raBMH10TeleportWaiting && !this.raBMH10TeleportReturning {
    if qs.GetFact(n"ra_bm_h10_smart_mirror_off") > 0 {
      // Consume the same helper facts the old Lua watcher consumed.
      qs.SetFact(n"ra_bm_h10_smart_mirror_off", 0);
      qs.SetFact(n"ra_bm_h10_capture_mirror", 0);
      this.raBMH10TeleportWaiting = true;

      let startEvt: ref<RABlueMoonH10TeleportStartEvent> = new RABlueMoonH10TeleportStartEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, startEvt, 3.80, false);
    };
  };

  this.RABMScheduleH10TeleportPoll(0.05);
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnRABlueMoonH10TeleportStartEvent(evt: ref<RABlueMoonH10TeleportStartEvent>) -> Bool {
  let startPos: Vector4 = this.GetWorldPosition();
  let forward: Vector4 = this.GetWorldForward();
  let targetPos: Vector4 = startPos;
  let horizontalLength: Float = SqrtF((forward.X * forward.X) + (forward.Y * forward.Y));

  this.raBMH10TeleportWaiting = false;

  if horizontalLength < 0.001 {
    return true;
  };

  this.raBMH10ReturnPosition = startPos;
  this.raBMH10ReturnRotation = Quaternion.ToEulerAngles(this.GetWorldOrientation());

  // Exactly 5 metres forward on the horizontal plane.
  targetPos.X += (forward.X / horizontalLength) * 5.00;
  targetPos.Y += (forward.Y / horizontalLength) * 5.00;
  targetPos.Z = startPos.Z;
  targetPos.W = startPos.W;

  GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(this, targetPos, this.raBMH10ReturnRotation);
  this.raBMH10TeleportReturning = true;

  let returnEvt: ref<RABlueMoonH10TeleportReturnEvent> = new RABlueMoonH10TeleportReturnEvent();
  GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, returnEvt, 0.02, false);
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnRABlueMoonH10TeleportReturnEvent(evt: ref<RABlueMoonH10TeleportReturnEvent>) -> Bool {
  if this.raBMH10TeleportReturning {
    GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(this, this.raBMH10ReturnPosition, this.raBMH10ReturnRotation);
    this.raBMH10TeleportReturning = false;
  };
  return true;
}

@addMethod(PlayerPuppet)
private final func RABMRefreshNGPlusBridge() -> Void {
  let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
  let jm: ref<JournalManager>;
  if !IsDefined(qs) {
    return;
  };
  if qs.GetFact(n"ngplus_active") <= 0 {
    return;
  };
  if qs.GetFact(n"mq028_done") <= 0 {
    return;
  };
  if qs.GetFact(n"ra_bm_relationship_success") > 0 || qs.GetFact(n"ra_bm_relationship_failed") > 0 || qs.GetFact(n"blue_ra_done") > 0 {
    return;
  };
  if qs.GetFact(n"ra_bm_native_intro_started") > 0 {
    qs.SetFact(n"ra_bm_ngplus_bridge_done", 1);
    return;
  };
  if qs.GetFact(n"ra_bm_ngplus_bridge_done") > 0 {
    return;
  };
  this.raBMNGPlusBridgeTicks += 1;
  if this.raBMNGPlusBridgeTicks < 5 {
    return;
  };
  this.raBMNGPlusBridgeTicks = 0;
  jm = GameInstance.GetJournalManager(this.GetGame());
  if !IsDefined(jm) {
    return;
  };
  jm.ChangeEntryState("contacts/blue_moon/mq028_thanks/mq028_thanks_15_ch_continue/mq028_thanks_15a_cu", "gameJournalPhoneChoiceEntry", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
}

@addMethod(PlayerPuppet)
private final func RABMGetApartmentDestination() -> Int32 {
  let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
  if !IsDefined(qs) {
    return 0;
  };
  if qs.GetFact(n"ra_bm_02_megabuilding_active") > 0 {
    return 1;
  };
  if qs.GetFact(n"ra_bm_02_heywood_active") > 0 {
    return 2;
  };
  if qs.GetFact(n"ra_bm_02_downtown_active") > 0 {
    return 3;
  };
  if qs.GetFact(n"ra_bm_02_japantown_active") > 0 {
    return 4;
  };
  if qs.GetFact(n"ra_bm_02_northside_active") > 0 {
    return 5;
  };
  return 0;
}

@addMethod(PlayerPuppet)
private final func RABMUnregisterApartmentWaypoint() -> Void {
  if this.raBMWaypointVisible {
    GameInstance.GetMappinSystem(this.GetGame()).UnregisterMappin(this.raBMWaypointID);
    this.raBMWaypointVisible = false;
    this.raBMWaypointDestination = 0;
  };
}

@addMethod(PlayerPuppet)
private final func RABMRegisterApartmentWaypoint(destination: Int32) -> Void {
  let data: MappinData = new MappinData();
  let pos: Vector4;

  data.mappinType = t"Mappins.DefaultStaticMappin";
  data.variant = gamedataMappinVariant.DefaultQuestVariant;
  data.visibleThroughWalls = true;
  let waypointTitle: String = GetLocalizedText("LocKey#714562008");
  let waypointDescription: String = GetLocalizedText("LocKey#917171000000000126");
  data.debugCaption = "RABlueMoon|" + waypointTitle + "|" + waypointDescription;

  switch destination {
    case 1:
      pos.X = -1386.4398;
      pos.Y = 1268.1443;
      pos.Z = 123.07498;
      pos.W = 1.00;
      break;
    case 2:
      pos.X = -1528.3547;
      pos.Y = -969.1583;
      pos.Z = 86.97;
      pos.W = 1.00;
      break;
    case 3:
      pos.X = -1617.348;
      pos.Y = 357.93405;
      pos.Z = 49.200005;
      pos.W = 1.00;
      break;
    case 4:
      pos.X = -788.6465;
      pos.Y = 982.37134;
      pos.Z = 28.209541;
      pos.W = 1.00;
      break;
    case 5:
      pos.X = -1504.0516;
      pos.Y = 2227.487;
      pos.Z = 22.231918;
      pos.W = 1.00;
      break;
    default:
      return;
  };

  this.raBMWaypointID = GameInstance.GetMappinSystem(this.GetGame()).RegisterMappin(data, pos);
  this.raBMWaypointVisible = true;
  this.raBMWaypointDestination = destination;
}

@addMethod(PlayerPuppet)
private final func RABMRefreshApartmentWaypoint() -> Void {
  let destination: Int32 = this.RABMGetApartmentDestination();

  if destination == 0 {
    this.RABMUnregisterApartmentWaypoint();
    return;
  };

  if this.raBMWaypointVisible && this.raBMWaypointDestination == destination {
    return;
  };

  this.RABMUnregisterApartmentWaypoint();
  this.RABMRegisterApartmentWaypoint(destination);
}
