module VehicleMileage.DroneOrbit

public class VM_DroneOrbitTick extends DelayCallback {
  private let system: wref<VM_DroneOrbitSystem>;

  public static func Create(system: ref<VM_DroneOrbitSystem>) -> ref<VM_DroneOrbitTick> {
    let self = new VM_DroneOrbitTick();
    self.system = system;
    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.system) {
      this.system.Tick();
    };
  }
}

public class VM_DroneOrbitCleanupTick extends DelayCallback {
  private let system: wref<VM_DroneOrbitSystem>;

  public static func Create(system: ref<VM_DroneOrbitSystem>) -> ref<VM_DroneOrbitCleanupTick> {
    let self = new VM_DroneOrbitCleanupTick();
    self.system = system;
    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.system) {
      this.system.DoCleanupDrone();
    };
  }
}

public class VM_DroneOrbitSystem extends ScriptableSystem {
  private let staticSystem: wref<StaticEntitySystem>;

  private let car: wref<VehicleObject>;
  private let drone: wref<Entity>;
  private let droneID: EntityID;

  private let hasDrone: Bool;
  private let tickArmed: Bool;
  private let cleanupRequested: Bool;

  private let active: Bool;
  private let ending: Bool;

	private let orbitAngle: Float;
	private let wobbleAngle: Float;
	private let lifeTimer: Float;
	private let liftTimer: Float;
	private let liftOffsetZ: Float;

	private let lastCommand: Int32;

	// Prevent saved quest fact value from firing the drone after save/load.
	private let commandBridgeReady: Bool;
	private let startupSyncTicks: Int32;

  private func OnAttach() -> Void {
    this.staticSystem = GameInstance.GetStaticEntitySystem();

    this.lastCommand = this.GetTuneFact(n"vm_drone_orbit_cmd");

    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Entity/Attached", this, n"OnDroneAttached")
      .AddTarget(StaticEntityTarget.Tag(n"VM_DroneOrbit.Drone"));

    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Entity/Detach", this, n"OnDroneDetached")
      .AddTarget(StaticEntityTarget.Tag(n"VM_DroneOrbit.Drone"));

    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Session/BeforeEnd", this, n"OnSessionBeforeEnd");

    // LogChannel(n"DEBUG", "[VM Drone Orbit] System attached");

    this.ArmTick();
  }

  private cb func OnDroneAttached(event: ref<EntityLifecycleEvent>) -> Void {
    if this.cleanupRequested {
      return;
    };

    this.drone = event.GetEntity();

    // LogChannel(n"DEBUG", "[VM Drone Orbit] Drone attached");
  }

  private cb func OnDroneDetached(event: ref<EntityLifecycleEvent>) -> Void {
    this.drone = null;
    this.hasDrone = false;

    // LogChannel(n"DEBUG", "[VM Drone Orbit] Drone detached");
  }

  private cb func OnSessionBeforeEnd(event: ref<GameSessionEvent>) -> Void {
    this.ClearReferencesOnly();
    // LogChannel(n"DEBUG", "[VM Drone Orbit] Session ending, references cleared");
  }

	public func Tick() -> Void {
		this.tickArmed = false;

		// On save/load, vm_drone_orbit_cmd may already contain an old saved value.
		// For the first ticks, only sync the value. Do not treat it as a new command.
		if !this.SyncCommandBridgeAfterLoad() {
			this.ArmTick();
			return;
		};

		this.CheckStartCommand();

    if this.cleanupRequested {
      return;
    };

    if !this.active {
      this.ArmTick();
      return;
    };

    if !IsDefined(this.car) {
      this.RequestCleanupDrone();
      return;
    };

    this.lifeTimer += 0.03;

    if !this.ending && this.lifeTimer >= 45.00 {
      this.ending = true;
      this.liftTimer = 0.00;
      this.liftOffsetZ = 0.00;

      // LogChannel(n"DEBUG", "[VM Drone Orbit] Observation finished, lift-away started");
    };

    if this.ending {
      this.liftTimer += 0.03;
      this.liftOffsetZ += 0.06;

      if this.liftTimer >= 2.50 {
        this.RequestCleanupDrone();
        return;
      };
    };

    if !this.hasDrone {
      this.SpawnDrone();
      this.ArmTick();
      return;
    };

    if !IsDefined(this.drone) {
      this.TryResolveDroneRef();
    };

    if !IsDefined(this.drone) {
      this.ArmTick();
      return;
    };

    this.UpdateOrbit();
    this.MoveDrone();
    this.ArmTick();
  }

	private func SyncCommandBridgeAfterLoad() -> Bool {
		if this.commandBridgeReady {
			return true;
		};

		// Keep syncing the saved/current fact value during startup.
		// This prevents old savegame values from being treated as fresh commands.
		this.lastCommand = this.GetTuneFact(n"vm_drone_orbit_cmd");

		this.startupSyncTicks += 1;

		// 60 ticks * 0.03 sec = about 1.8 sec.
		if this.startupSyncTicks >= 30 {
			this.commandBridgeReady = true;
			// LogChannel(n"DEBUG", "[VM Drone Orbit] Command bridge ready");
		};

		return false;
	}

  private func CheckStartCommand() -> Void {
    let cmd = this.GetTuneFact(n"vm_drone_orbit_cmd");

    if cmd <= this.lastCommand {
      return;
    };

    this.lastCommand = cmd;

    this.StartDroneOrbit();
  }

  private func StartDroneOrbit() -> Void {
    let target = this.GetBestVehicleTarget();

    if !IsDefined(target) {
      // LogChannel(n"DEBUG", "[VM Drone Orbit] Start command received, but no vehicle target found");
      return;
    };

    if this.hasDrone {
      this.DoCleanupDrone();
    };

    this.car = target;
    this.active = true;
    this.ending = false;
    this.cleanupRequested = false;

    this.orbitAngle = 0.00;
    this.lifeTimer = 0.00;
    this.liftTimer = 0.00;
    this.liftOffsetZ = 0.00;

    // LogChannel(n"DEBUG", "[VM Drone Orbit] Drone observation started");

    this.SpawnDrone();
  }

  private func GetBestVehicleTarget() -> ref<VehicleObject> {
    let mounted = this.GetMountedVehicleTarget();

    if IsDefined(mounted) {
      return mounted;
    };

    let summoned = this.GetSummonedVehicleTarget();

    if IsDefined(summoned) {
      return summoned;
    };

    return null;
  }

  private func GetMountedVehicleTarget() -> ref<VehicleObject> {
    let player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;

    if !IsDefined(player) {
      return null;
    };

    return player.GetMountedVehicle();
  }

  private func GetSummonedVehicleTarget() -> ref<VehicleObject> {
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(defs.VehicleSummonData);

    if !IsDefined(bb) {
      return null;
    };

    let entID = bb.GetEntityID(defs.VehicleSummonData.SummonedVehicleEntityID);
    let ent = GameInstance.FindEntityByID(this.GetGameInstance(), entID) as VehicleObject;

    return ent;
  }

  private func SpawnDrone() -> Void {
    if this.cleanupRequested || this.hasDrone || !IsDefined(this.car) {
      return;
    };

    let spec = new StaticEntitySpec();

    spec.templatePath = r"base\\gameplay\\air_traffic\\appearances\\air_traffic_av_zetatech_bombus_01.ent";

    let spawnPos = this.GetDroneTargetPosition();

    spec.position = spawnPos;
    spec.orientation = this.GetDroneTargetOrientation(spawnPos);
    spec.attached = true;
    spec.tags = [n"VM_DroneOrbit.Drone"];

    this.droneID = this.staticSystem.SpawnEntity(spec);
    this.hasDrone = true;

    // LogChannel(n"DEBUG", "[VM Drone Orbit] Drone spawn requested");
  }

  private func TryResolveDroneRef() -> Void {
    if IsDefined(this.drone) {
      return;
    };

    if !IsDefined(this.staticSystem) || !this.hasDrone {
      return;
    };

    if !this.staticSystem.IsSpawned(this.droneID) {
      return;
    };

    this.drone = this.staticSystem.GetEntity(this.droneID);

    if IsDefined(this.drone) {
      // LogChannel(n"DEBUG", "[VM Drone Orbit] Drone reference resolved by ID");
    };
  }

	private func UpdateOrbit() -> Void {
		this.orbitAngle += 0.025;

		if this.orbitAngle > 6.28318 {
			this.orbitAngle -= 6.28318;
		};

		// Pitch wobble animation.
		// Higher value = faster head shake.
		this.wobbleAngle += 0.080;

		if this.wobbleAngle > 6.28318 {
			this.wobbleAngle -= 6.28318;
		};
	}

  private func MoveDrone() -> Void {
    let transform = this.drone.GetWorldTransform();

    let currentPos = this.drone.GetWorldPosition();
    let targetPos = this.GetDroneTargetPosition();

    let smooth: Float = 0.25;
    let nextPos = currentPos + (targetPos - currentPos) * smooth;

    WorldTransform.SetPosition(transform, nextPos);
    WorldTransform.SetOrientation(transform, this.GetDroneTargetOrientation(nextPos));

    this.drone.SetWorldTransform(transform);
  }

  private func GetTuneFact(name: CName) -> Int32 {
    let qs = GameInstance.GetQuestsSystem(this.GetGameInstance());

    if IsDefined(qs) {
      return qs.GetFact(name);
    };

    return 0;
  }

  private func GetDroneTargetPosition() -> Vector4 {
    let radius: Float = 3.00;

    // Normal orbit height + lift-away height
    let z: Float = 1.40 + this.liftOffsetZ;

    let centerX: Float = 0.00;
    let centerY: Float = 0.00;

    let x: Float = centerX + CosF(this.orbitAngle) * radius;
    let y: Float = centerY + SinF(this.orbitAngle) * radius;

    return this.car.GetWorldPosition()
      + this.car.GetWorldRight() * x
      + this.car.GetWorldForward() * y
      + new Vector4(0.00, 0.00, z, 0.00);
  }

  private func GetDroneTargetOrientation(dronePos: Vector4) -> Quaternion {
    let carPos = this.car.GetWorldPosition();

    let toCar = carPos - dronePos;
    toCar.Z = 0.00;

    let rot = Vector4.ToRotation(toCar);

		// Head wobble pitch.
		// Base pitch -15 plus animated wobble from -20 to +20.
		let pitchWobble: Float = SinF(this.wobbleAngle) * 10.00;

		rot.Roll += 0.00;
		rot.Pitch += -15.00 + pitchWobble;
		rot.Yaw += 0.00;

    return EulerAngles.ToQuat(rot);
  }

  private func ArmTick() -> Void {
    if this.tickArmed {
      return;
    };

    this.tickArmed = true;

    GameInstance.GetDelaySystem(this.GetGameInstance())
      .DelayCallback(VM_DroneOrbitTick.Create(this), 0.03, false);
  }

  private func RequestCleanupDrone() -> Void {
    if this.cleanupRequested {
      return;
    };

    this.cleanupRequested = true;
    this.active = false;
    this.tickArmed = false;
    this.car = null;

    GameInstance.GetDelaySystem(this.GetGameInstance())
      .DelayCallback(VM_DroneOrbitCleanupTick.Create(this), 0.20, false);
  }

  public func DoCleanupDrone() -> Void {
    if IsDefined(this.staticSystem) && this.hasDrone {
      // LogChannel(n"DEBUG", "[VM Drone Orbit] Delayed drone despawn");
      this.staticSystem.DespawnEntity(this.droneID);
    };

    this.ClearReferencesOnly();

    // LogChannel(n"DEBUG", "[VM Drone Orbit] Cleanup finished");

    this.ArmTick();
  }

  private func ClearReferencesOnly() -> Void {
    this.car = null;
    this.drone = null;
    this.hasDrone = false;
    this.tickArmed = false;
    this.cleanupRequested = false;
    this.active = false;
    this.ending = false;
		this.orbitAngle = 0.00;
		this.wobbleAngle = 0.00;
		this.lifeTimer = 0.00;
		this.liftTimer = 0.00;
		this.liftOffsetZ = 0.00;
  }
}