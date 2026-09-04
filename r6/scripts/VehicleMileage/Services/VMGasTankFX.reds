module VehicleMileage.GasTankFX

// ============================================================================
// VehicleMileage - Gas Tank Toxic FX (safe runtime version)
// ============================================================================
//
// This version does not add native components during vehicle assembly.
//
// Instead:
// - VMRuntimeSystem enables it only while maintenance is overdue.
// - The mounted vehicle component named "gas_tank" is located.
// - Its real local position and orientation are combined with the vehicle
//   world transform.
// - Two FxInstance effects are spawned together.
// - Both use the gas_tank transform while they are active.
// - The decompression effect replays at random 10-30 second intervals.
//
// PlayerPuppet helper methods remain available for runtime control and
// diagnostics, but normal gameplay is owned by the REDscript runtime.
//
// Status:
//   print(Game.GetPlayer():VMGasTankFX_Status())
//
// Reset:
//   print(Game.GetPlayer():VMGasTankFX_ResetOffset())
//
// Parameter order:
//   X, Y, Z, Roll, Pitch, Yaw
// ============================================================================


// ============================================================================
// Tick callback
// ============================================================================

private class VMGasTankFXTick extends DelayCallback {
  private let service: wref<VMGasTankFXService>;

  public static func Create(
    service: ref<VMGasTankFXService>
  ) -> ref<VMGasTankFXTick> {
    let self = new VMGasTankFXTick();
    self.service = service;
    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.service) {
      this.service.tickArmed = false;
      this.service.Tick();
    };
  }
}


// ============================================================================
// Random decompression replay callback
// ============================================================================

private class VMGasTankFXDecompressionTick extends DelayCallback {
  private let service: wref<VMGasTankFXService>;
  private let generation: Int32;

  public static func Create(
    service: ref<VMGasTankFXService>,
    generation: Int32
  ) -> ref<VMGasTankFXDecompressionTick> {
    let self = new VMGasTankFXDecompressionTick();

    self.service = service;
    self.generation = generation;

    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.service) {
      this.service.DecompressionTick(this.generation);
    };
  }
}


// ============================================================================
// Runtime service
// ============================================================================

public class VMGasTankFXService extends IScriptable {
  public let tickArmed: Bool;

  private let tickCallback: ref<VMGasTankFXTick>;
  private let tickPeriod: Float = 0.05;

  public let decompressionTickArmed: Bool;

  private let decompressionTickCallback:
    ref<VMGasTankFXDecompressionTick>;

  private let decompressionGeneration: Int32;
  private let nextDecompressionDelay: Float;

  private let defaultsReady: Bool;
  private let enabled: Bool;

  private let offsetX: Float;
  private let offsetY: Float;
  private let offsetZ: Float;

  private let offsetRoll: Float;
  private let offsetPitch: Float;
  private let offsetYaw: Float;

  private let bikeOffsetX: Float;
  private let bikeOffsetY: Float;
  private let bikeOffsetZ: Float;

  private let bikeOffsetRoll: Float;
  private let bikeOffsetPitch: Float;
  private let bikeOffsetYaw: Float;

  private let toxicGasEffectInstance: ref<FxInstance>;
  private let decompressionEffectInstance: ref<FxInstance>;
  private let decompressionEffectStarted: Bool;

  private let activeVehicle: wref<WheeledObject>;

  private let lastStatus: String;


  // ==========================================================================
  // Defaults
  // ==========================================================================

  private func EnsureDefaults() -> Void {
    if this.defaultsReady {
      return;
    };

    this.offsetX = 1.7;
    this.offsetY = 0.0;
    this.offsetZ = 0.4;

    this.offsetRoll = 180.0;
    this.offsetPitch = 0.0;
    this.offsetYaw = 0.0;

    // Bike components are generally centered on the chassis, unlike the
    // gas_tank anchor used by cars. Keep their default correction compact.
    this.bikeOffsetX = 0.0;
    this.bikeOffsetY = 0.50;
    this.bikeOffsetZ = 0.50;

    this.bikeOffsetRoll = 180.0;
    this.bikeOffsetPitch = 0.0;
    this.bikeOffsetYaw = 0.0;

    this.lastStatus = "Ready.";
    this.defaultsReady = true;
  }


  // ==========================================================================
  // Vehicle/component lookup
  // ==========================================================================

  private func GetMountedCar() -> wref<WheeledObject> {
    let player = GetPlayer(GetGameInstance());

    if !IsDefined(player) {
      return null;
    };

    return player.GetMountedVehicle() as WheeledObject;
  }

  private func FindGasTank(
    car: wref<WheeledObject>
  ) -> wref<IPlacedComponent> {
    if !IsDefined(car) {
      return null;
    };

    return car.FindComponentByName(n"gas_tank") as IPlacedComponent;
  }

  private func FindBikeComponent(
    car: wref<WheeledObject>
  ) -> wref<IPlacedComponent> {
    if !IsDefined(car) {
      return null;
    };

    let components = car.GetComponents();

    for component in components {
      if IsDefined(component) {
        let placedComponent =
          component as IPlacedComponent;

        let componentName: String =
          NameToString(component.GetName());

        if IsDefined(placedComponent)
          && (
            StrContains(componentName, "bike")
            || StrContains(componentName, "Bike")
            || StrContains(componentName, "BIKE")
          ) {

          return placedComponent;
        };
      };
    };

    return null;
  }

  private func SignalDecompressionEvent(
    mode: Int32
  ) -> Void {
    let questSystem: ref<QuestsSystem> =
      GameInstance.GetQuestsSystem(GetGameInstance());

    if !IsDefined(questSystem) {
      return;
    };

    let eventCount: Int32 =
      questSystem.GetFact(
        n"vm_maintenance_decompression_event"
      );

    // 0 = simulated/no component, 1 = gas_tank, 2 = bike component.
    questSystem.SetFact(
      n"vm_maintenance_fx_mode",
      mode
    );

    questSystem.SetFact(
      n"vm_maintenance_decompression_event",
      eventCount + 1
    );
  }


  // ==========================================================================
  // Transform helpers
  // ==========================================================================

  private func RotateVector(
    orientation: Quaternion,
    source: Vector4
  ) -> Vector4 {
    let xx: Float = orientation.i * orientation.i;
    let yy: Float = orientation.j * orientation.j;
    let zz: Float = orientation.k * orientation.k;

    let xy: Float = orientation.i * orientation.j;
    let xz: Float = orientation.i * orientation.k;
    let yz: Float = orientation.j * orientation.k;

    let rx: Float = orientation.r * orientation.i;
    let ry: Float = orientation.r * orientation.j;
    let rz: Float = orientation.r * orientation.k;

    let result: Vector4;

    result.X =
      (1.0 - 2.0 * (yy + zz)) * source.X
      + 2.0 * (xy - rz) * source.Y
      + 2.0 * (xz + ry) * source.Z;

    result.Y =
      2.0 * (xy + rz) * source.X
      + (1.0 - 2.0 * (xx + zz)) * source.Y
      + 2.0 * (yz - rx) * source.Z;

    result.Z =
      2.0 * (xz - ry) * source.X
      + 2.0 * (yz + rx) * source.Y
      + (1.0 - 2.0 * (xx + yy)) * source.Z;

    result.W = 0.0;

    return result;
  }

  private func MultiplyQuaternion(
    parent: Quaternion,
    local: Quaternion
  ) -> Quaternion {
    let result: Quaternion;

    result.i =
      parent.r * local.i
      + parent.i * local.r
      + parent.j * local.k
      - parent.k * local.j;

    result.j =
      parent.r * local.j
      - parent.i * local.k
      + parent.j * local.r
      + parent.k * local.i;

    result.k =
      parent.r * local.k
      + parent.i * local.j
      - parent.j * local.i
      + parent.k * local.r;

    result.r =
      parent.r * local.r
      - parent.i * local.i
      - parent.j * local.j
      - parent.k * local.k;

    return result;
  }

  private func BuildEffectTransform(
    car: wref<WheeledObject>,
    anchor: wref<IPlacedComponent>,
    useBikeOffset: Bool
  ) -> WorldTransform {
    let transform: WorldTransform;

    let vehiclePosition: Vector4 = car.GetWorldPosition();
    let vehicleOrientation: Quaternion = car.GetWorldOrientation();

    let tankLocalPosition: Vector4 = anchor.GetLocalPosition();
    let tankLocalOrientation: Quaternion = anchor.GetLocalOrientation();

    let tankOffsetFromVehicle: Vector4 =
      this.RotateVector(
        vehicleOrientation,
        tankLocalPosition
      );

    let tankWorldPosition: Vector4;

    tankWorldPosition.X =
      vehiclePosition.X + tankOffsetFromVehicle.X;

    tankWorldPosition.Y =
      vehiclePosition.Y + tankOffsetFromVehicle.Y;

    tankWorldPosition.Z =
      vehiclePosition.Z + tankOffsetFromVehicle.Z;

    tankWorldPosition.W = 1.0;

    let tankWorldOrientation: Quaternion =
      this.MultiplyQuaternion(
        vehicleOrientation,
        tankLocalOrientation
      );

    let localOffset: Vector4;

    localOffset.X =
      useBikeOffset ? this.bikeOffsetX : this.offsetX;

    localOffset.Y =
      useBikeOffset ? this.bikeOffsetY : this.offsetY;

    localOffset.Z =
      useBikeOffset ? this.bikeOffsetZ : this.offsetZ;

    localOffset.W = 0.0;

    let worldOffset: Vector4 =
      this.RotateVector(
        tankWorldOrientation,
        localOffset
      );

    let effectPosition: Vector4;

    effectPosition.X = tankWorldPosition.X + worldOffset.X;
    effectPosition.Y = tankWorldPosition.Y + worldOffset.Y;
    effectPosition.Z = tankWorldPosition.Z + worldOffset.Z;
    effectPosition.W = 1.0;

    let offsetEuler: EulerAngles;

    offsetEuler.Roll =
      useBikeOffset ? this.bikeOffsetRoll : this.offsetRoll;

    offsetEuler.Pitch =
      useBikeOffset ? this.bikeOffsetPitch : this.offsetPitch;

    offsetEuler.Yaw =
      useBikeOffset ? this.bikeOffsetYaw : this.offsetYaw;

    let offsetOrientation: Quaternion =
      EulerAngles.ToQuat(offsetEuler);

    let effectOrientation: Quaternion =
      this.MultiplyQuaternion(
        tankWorldOrientation,
        offsetOrientation
      );

    WorldTransform.SetPosition(
      transform,
      effectPosition
    );

    WorldTransform.SetOrientation(
      transform,
      effectOrientation
    );

    return transform;
  }


  // ==========================================================================
  // Effect lifecycle
  // ==========================================================================

  private func StopEffect() -> Void {
    if IsDefined(this.toxicGasEffectInstance) {
      this.toxicGasEffectInstance.BreakLoop();
      this.toxicGasEffectInstance.Kill();
    };

    if IsDefined(this.decompressionEffectInstance) {
      this.decompressionEffectInstance.BreakLoop();
      this.decompressionEffectInstance.Kill();
    };

    this.toxicGasEffectInstance = null;
    this.decompressionEffectInstance = null;
    this.decompressionEffectStarted = false;

    this.activeVehicle = null;
  }

  private func PlayDecompressionEffect() -> Bool {
    let car = this.GetMountedCar();

    if !IsDefined(car) {
      this.lastStatus =
        "Decompression skipped: player is not mounted.";
      return false;
    };

    let anchor = this.FindGasTank(car);
    let useBikeOffset: Bool = false;
    let effectMode: Int32 = 1;

    if !IsDefined(anchor) {
      anchor = this.FindBikeComponent(car);
      useBikeOffset = IsDefined(anchor);
      effectMode = useBikeOffset ? 2 : 0;
    };

    if !IsDefined(anchor) {
      // Keep the maintenance cadence alive even when a vehicle exposes no
      // usable component. VMRuntimeSystem turns this event into persistent
      // fuel loss and a simulated-failure warning.
      this.decompressionEffectStarted = true;
      this.SignalDecompressionEvent(0);
      this.lastStatus =
        "Simulated decompression: no gas_tank or bike component found.";
      return true;
    };

    let transform: WorldTransform =
      this.BuildEffectTransform(
        car,
        anchor,
        useBikeOffset
      );

    // Stop the previous instance before replaying the one-shot effect.
    if IsDefined(this.decompressionEffectInstance) {
      this.decompressionEffectInstance.BreakLoop();
      this.decompressionEffectInstance.Kill();
    };

    this.decompressionEffectInstance = null;

    let decompressionResource: FxResource;
    ResourceAsyncRef.SetPath(
      decompressionResource.effect,
      r"base\\fx\\quest\\q203\\cosmos\\q207_decompresion.effect"
    );

    this.decompressionEffectInstance =
      GameInstance
        .GetFxSystem(GetGameInstance())
        .SpawnEffect(
          decompressionResource,
          transform,
          false
        );

    if !IsDefined(this.decompressionEffectInstance) {
      this.decompressionEffectStarted = false;
      this.lastStatus =
        "Failed: decompression effect could not be spawned.";
      return false;
    };

    this.decompressionEffectStarted = true;
    this.SignalDecompressionEvent(effectMode);

    return true;
  }

  private func UpdateEffect() -> Bool {
    let car = this.GetMountedCar();

    if !IsDefined(car) {
      this.lastStatus =
        "Stopped: player is not mounted in a wheeled vehicle.";
      return false;
    };

    if IsDefined(this.activeVehicle)
      && NotEquals(
        this.activeVehicle.GetEntityID(),
        car.GetEntityID()
      ) {

      this.StopEffect();
    };

    let anchor = this.FindGasTank(car);
    let useBikeOffset: Bool = false;

    if !IsDefined(anchor) {
      anchor = this.FindBikeComponent(car);
      useBikeOffset = IsDefined(anchor);
    };

    if !IsDefined(anchor) {
      // Remove visual instances left from a previous anchor, but do not stop
      // the scheduler. PlayDecompressionEffect() supplies a virtual event.
      if IsDefined(this.toxicGasEffectInstance) {
        this.toxicGasEffectInstance.BreakLoop();
        this.toxicGasEffectInstance.Kill();
      };

      if IsDefined(this.decompressionEffectInstance) {
        this.decompressionEffectInstance.BreakLoop();
        this.decompressionEffectInstance.Kill();
      };

      this.toxicGasEffectInstance = null;
      this.decompressionEffectInstance = null;

      if !this.decompressionEffectStarted {
        if !this.PlayDecompressionEffect() {
          return false;
        };
      };

      this.activeVehicle = car;
      this.lastStatus =
        "Simulation active: no gas_tank or bike component found.";

      return true;
    };

    let transform: WorldTransform =
      this.BuildEffectTransform(
        car,
        anchor,
        useBikeOffset
      );

    // ------------------------------------------------------------------------
    // Effect 1: toxic gas
    // ------------------------------------------------------------------------
    if IsDefined(this.toxicGasEffectInstance)
      && this.toxicGasEffectInstance.IsValid() {

      this.toxicGasEffectInstance.UpdateTransform(transform);
    } else {
      let toxicGasResource: FxResource;
      ResourceAsyncRef.SetPath(
        toxicGasResource.effect,
        r"base\\fx\\devices\\sprinkler\\d_sprinkler_toxic_gas.effect"
      );

      this.toxicGasEffectInstance =
        GameInstance
          .GetFxSystem(GetGameInstance())
          .SpawnEffect(
            toxicGasResource,
            transform,
            false
          );

      if !IsDefined(this.toxicGasEffectInstance) {
        this.lastStatus =
          "Failed: toxic gas effect could not be spawned.";
        return false;
      };
    };

    // ------------------------------------------------------------------------
    // Effect 2: decompression
    //
    // It plays immediately on Enable(). A separate delayed callback replays
    // it at a newly randomized interval between 10 and 30 seconds.
    // ------------------------------------------------------------------------
    if !this.decompressionEffectStarted {
      if !this.PlayDecompressionEffect() {
        return false;
      };
    } else {
      if IsDefined(this.decompressionEffectInstance)
        && this.decompressionEffectInstance.IsValid() {

        this.decompressionEffectInstance.UpdateTransform(transform);
      };
    };

    this.activeVehicle = car;
    this.lastStatus = useBikeOffset
      ? "Both effects enabled and following a bike component."
      : "Both effects enabled and following component 'gas_tank'.";

    return true;
  }


  // ==========================================================================
  // Tick
  // ==========================================================================

  public func Tick() -> Void {
    if !this.enabled {
      return;
    };

    if !this.UpdateEffect() {
      this.enabled = false;
      this.CancelDecompressionTick();
      this.StopEffect();
      return;
    };

    this.ArmTick();
  }

  private func ArmTick() -> Void {
    if !this.enabled || this.tickArmed {
      return;
    };

    let delaySystem =
      GameInstance.GetDelaySystem(
        GetGameInstance()
      );

    if !IsDefined(delaySystem) {
      this.enabled = false;
      this.StopEffect();
      this.lastStatus =
        "Stopped: DelaySystem is unavailable.";
      return;
    };

    this.tickCallback =
      VMGasTankFXTick.Create(this);

    this.tickArmed = true;

    delaySystem.DelayCallback(
      this.tickCallback,
      this.tickPeriod,
      false
    );
  }


  // ==========================================================================
  // Random decompression replay scheduler
  // ==========================================================================

  private func CancelDecompressionTick() -> Void {
    this.decompressionGeneration += 1;
    this.decompressionTickArmed = false;
    this.nextDecompressionDelay = 0.0;
  }

  private func ArmDecompressionTick() -> Void {
    if !this.enabled || this.decompressionTickArmed {
      return;
    };

    let delaySystem =
      GameInstance.GetDelaySystem(
        GetGameInstance()
      );

    if !IsDefined(delaySystem) {
      this.lastStatus =
        "Decompression scheduler unavailable: DelaySystem is missing.";
      return;
    };

    // RandRange uses integer bounds. This selects 10 through 30 seconds.
    this.nextDecompressionDelay =
      Cast<Float>(RandRange(10, 30));

    this.decompressionTickCallback =
      VMGasTankFXDecompressionTick.Create(
        this,
        this.decompressionGeneration
      );

    this.decompressionTickArmed = true;

    delaySystem.DelayCallback(
      this.decompressionTickCallback,
      this.nextDecompressionDelay,
      false
    );
  }

  public func DecompressionTick(
    generation: Int32
  ) -> Void {
    // Ignore callbacks left over from a previous Enable/Disable cycle.
    if generation != this.decompressionGeneration {
      return;
    };

    this.decompressionTickArmed = false;

    if !this.enabled {
      return;
    };

    if this.PlayDecompressionEffect() {
      this.lastStatus =
        "Decompression effect replayed.";
    };

    // Every replay gets a newly randomized delay.
    this.ArmDecompressionTick();
  }


  // ==========================================================================
  // Runtime-facing service methods
  // ==========================================================================

  public func Enable() -> String {
    this.EnsureDefaults();

    // Restart both effects and begin a fresh random replay schedule.
    this.CancelDecompressionTick();
    this.StopEffect();
    this.enabled = true;

    if !this.UpdateEffect() {
      this.enabled = false;
      this.CancelDecompressionTick();
      this.StopEffect();
      return this.lastStatus;
    };

    this.ArmTick();
    this.ArmDecompressionTick();

    return "Gas tank effects enabled. Decompression repeats every 10-30 seconds.";
  }

  public func Disable() -> String {
    this.enabled = false;
    this.CancelDecompressionTick();
    this.StopEffect();
    this.lastStatus = "Disabled.";

    return "Gas tank toxic gas and decompression effects disabled.";
  }

  public func SetOffset(
    x: Float,
    y: Float,
    z: Float,
    roll: Float,
    pitch: Float,
    yaw: Float
  ) -> String {
    this.EnsureDefaults();

    this.offsetX = x;
    this.offsetY = y;
    this.offsetZ = z;

    this.offsetRoll = roll;
    this.offsetPitch = pitch;
    this.offsetYaw = yaw;

    if this.enabled {
      if !this.UpdateEffect() {
        this.enabled = false;
        this.CancelDecompressionTick();
        this.StopEffect();
        return this.lastStatus;
      };
    };

    return "Gas tank FX offset updated.";
  }

  public func ResetOffset() -> String {
    return this.SetOffset(
      1.7,
      0.0,
      0.4,
      180.0,
      0.0,
      0.0
    );
  }

  public func SetBikeOffset(
    x: Float,
    y: Float,
    z: Float,
    roll: Float,
    pitch: Float,
    yaw: Float
  ) -> String {
    this.EnsureDefaults();

    this.bikeOffsetX = x;
    this.bikeOffsetY = y;
    this.bikeOffsetZ = z;

    this.bikeOffsetRoll = roll;
    this.bikeOffsetPitch = pitch;
    this.bikeOffsetYaw = yaw;

    if this.enabled {
      if !this.UpdateEffect() {
        this.enabled = false;
        this.CancelDecompressionTick();
        this.StopEffect();
        return this.lastStatus;
      };
    };

    return "Bike component FX offset updated.";
  }

  public func ResetBikeOffset() -> String {
    return this.SetBikeOffset(
      0.0,
      0.50,
      0.50,
      180.0,
      0.0,
      0.0
    );
  }

  public func Status() -> String {
    this.EnsureDefaults();

    let car = this.GetMountedCar();

    let mounted: String =
      IsDefined(car) ? "YES" : "NO";

    let hasGasTank: String = "NO";
    let hasBikeComponent: String = "NO";

    if IsDefined(car)
      && IsDefined(this.FindGasTank(car)) {

      hasGasTank = "YES";
    };

    if IsDefined(car)
      && IsDefined(this.FindBikeComponent(car)) {

      hasBikeComponent = "YES";
    };

    return "Mounted=" + mounted
      + " | gas_tank=" + hasGasTank
      + " | bike_component=" + hasBikeComponent
      + " | Active=" + ToString(this.enabled)
      + " | XYZ=("
      + ToString(this.offsetX) + ", "
      + ToString(this.offsetY) + ", "
      + ToString(this.offsetZ) + ")"
      + " | ToxicGas="
      + ToString(
        IsDefined(this.toxicGasEffectInstance)
        && this.toxicGasEffectInstance.IsValid()
      )
      + " | DecompressionStarted="
      + ToString(this.decompressionEffectStarted)
      + " | NextDecompression="
      + ToString(this.nextDecompressionDelay)
      + "s"
      + " | RPY=("
      + ToString(this.offsetRoll) + ", "
      + ToString(this.offsetPitch) + ", "
      + ToString(this.offsetYaw) + ")"
      + " | BikeXYZ=("
      + ToString(this.bikeOffsetX) + ", "
      + ToString(this.bikeOffsetY) + ", "
      + ToString(this.bikeOffsetZ) + ")"
      + " | BikeRPY=("
      + ToString(this.bikeOffsetRoll) + ", "
      + ToString(this.bikeOffsetPitch) + ", "
      + ToString(this.bikeOffsetYaw) + ")"
      + " | " + this.lastStatus;
  }
}


// ============================================================================
// PlayerPuppet runtime methods
// ============================================================================

@addField(PlayerPuppet)
private let vmGasTankFXService: ref<VMGasTankFXService>;

@addMethod(PlayerPuppet)
private func VMGasTankFX_GetService() -> ref<VMGasTankFXService> {
  if !IsDefined(this.vmGasTankFXService) {
    this.vmGasTankFXService =
      new VMGasTankFXService();
  };

  return this.vmGasTankFXService;
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_Enable() -> String {
  return this.VMGasTankFX_GetService().Enable();
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_Disable() -> String {
  return this.VMGasTankFX_GetService().Disable();
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_SetOffset(
  x: Float,
  y: Float,
  z: Float,
  roll: Float,
  pitch: Float,
  yaw: Float
) -> String {
  return this.VMGasTankFX_GetService().SetOffset(
    x,
    y,
    z,
    roll,
    pitch,
    yaw
  );
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_ResetOffset() -> String {
  return this.VMGasTankFX_GetService().ResetOffset();
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_SetBikeOffset(
  x: Float,
  y: Float,
  z: Float,
  roll: Float,
  pitch: Float,
  yaw: Float
) -> String {
  return this.VMGasTankFX_GetService().SetBikeOffset(
    x,
    y,
    z,
    roll,
    pitch,
    yaw
  );
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_ResetBikeOffset() -> String {
  return this.VMGasTankFX_GetService().ResetBikeOffset();
}

@addMethod(PlayerPuppet)
public func VMGasTankFX_Status() -> String {
  return this.VMGasTankFX_GetService().Status();
}

// ============================================================================
// Maintenance diagnostic command
// ============================================================================

@addMethod(PlayerPuppet)
public func VM_ForceMaintenanceDue() -> String {
  if !IsDefined(this.GetMountedVehicle()) {
    return "Maintenance request failed: mount an owned vehicle first.";
  };

  let questSystem: ref<QuestsSystem> =
    GameInstance.GetQuestsSystem(GetGameInstance());

  if !IsDefined(questSystem) {
    return "Maintenance request failed: QuestsSystem unavailable.";
  };

  let command: Int32 =
    questSystem.GetFact(n"vm_maintenance_force_due_cmd");

  questSystem.SetFact(
    n"vm_maintenance_force_due_cmd",
    command + 1
  );

  return "Maintenance due request queued for the mounted owned vehicle.";
}
