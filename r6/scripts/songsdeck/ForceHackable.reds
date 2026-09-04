module SongsDeck

public func IsSongsDeckHackTarget(ps: ref<ScriptableDeviceComponentPS>) -> Bool {
  if !IsDefined(ps) {
    return false;
  }
  return IsDefined(ps as DoorControllerPS)
    || IsDefined(ps as SurveillanceCameraControllerPS)
    || IsDefined(ps as SecurityTurretControllerPS);
}

public func IsSongsDeckHackEligible(ps: ref<ScriptableDeviceComponentPS>) -> Bool {
  if !IsSongsDeckHackTarget(ps) {
    return false;
  }
  if !HasBlackwallDeck(ps.GetGameInstance()) {
    return false;
  }
  if ps.IsUnpowered() || ps.IsDisabled() {
    return false;
  }
  if !Equals(ps.GetDurabilityState(), EDeviceDurabilityState.NOMINAL) {
    return false;
  }
  return true;
}

public func EnsureSongsDeckPlaystyle(ps: ref<ScriptableDeviceComponentPS>) -> Void {
  if !IsSongsDeckHackEligible(ps) {
    return;
  }
  if !ps.HasPlaystyle(EPlaystyle.NETRUNNER) {
    ps.DetermineInitialPlaystyle();
  }
  if !ps.HasPlaystyle(EPlaystyle.NETRUNNER) {
    ps.AddPlaystyle(EPlaystyle.NETRUNNER);
  }
}

// True when this door only has a QH panel because of the deck — not because vanilla
// already exposed it (per-instance flag) or because it sits on a network backdoor.
public func IsSongsDeckForcedDoor(ps: ref<DoorControllerPS>) -> Bool {
  if !IsDefined(ps) || !IsSongsDeckHackEligible(ps) {
    return false;
  }
  if ps.IsConnectedToBackdoorDevice() {
    return false;
  }
  return !ps.SongsDeckVanillaExposeQuickHacks();
}

@addMethod(DoorControllerPS)
public const func SongsDeckVanillaExposeQuickHacks() -> Bool {
  return this.m_doorProperties.m_exposeQuickHacksIfNotConnectedToAP;
}

@addMethod(Device)
public func SongsDeckWakeForHack() -> Void {
  let ps: ref<ScriptableDeviceComponentPS> = this.GetDevicePS();
  if !IsSongsDeckHackEligible(ps) {
    return;
  }
  let hadPlaystyle: Bool = ps.HasPlaystyle(EPlaystyle.NETRUNNER);
  EnsureSongsDeckPlaystyle(ps);
  this.ForceReEvaluateGameplayRole();
  this.UpdateDeviceState(false);
  this.RefreshInteraction();
  SongsDeckLog(s"WakeForHack class=\(this.GetClassName()) playstyleWas=\(hadPlaystyle) playstyleNow=\(ps.HasPlaystyle(EPlaystyle.NETRUNNER))");
}

@wrapMethod(DeviceComponentPS)
public final const func IsQuickHacksExposed() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this as ScriptableDeviceComponentPS);
}

@wrapMethod(DoorControllerPS)
public final const func ExposeQuickHakcsIfNotConnnectedToAP() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this);
}

@wrapMethod(DoorControllerPS)
protected const func CanCreateAnyQuickHackActions() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this);
}

@wrapMethod(Device)
public const func IsQuickHackAble() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this.GetDevicePS());
}

@wrapMethod(Device)
public const func IsNetrunner() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this.GetDevicePS());
}

@wrapMethod(Device)
public const func ShouldEnableRemoteLayer() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this.GetDevicePS());
}

@wrapMethod(Device)
public const func CanRevealRemoteActionsWheel() -> Bool {
  if wrappedMethod() {
    return true;
  }
  return IsSongsDeckHackEligible(this.GetDevicePS());
}

@wrapMethod(Device)
protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Void {
  if evt.state {
    this.SongsDeckWakeForHack();
  }
  wrappedMethod(evt);
}
