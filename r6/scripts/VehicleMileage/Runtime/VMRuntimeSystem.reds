module VehicleMileage.Runtime

public class VMRuntimeTick extends DelayCallback {
  private let system: wref<VMRuntimeSystem>;
  private let generation: Int32;

  public static func Create(system: ref<VMRuntimeSystem>, generation: Int32) -> ref<VMRuntimeTick> {
    let result: ref<VMRuntimeTick> = new VMRuntimeTick();
    result.system = system;
    result.generation = generation;
    return result;
  }

  public func Call() -> Void {
    if IsDefined(this.system) {
      this.system.Tick(this.generation);
    };
  }
}

public class VMMaintenanceRewardMessage extends DelayCallback {
  private let player: wref<PlayerPuppet>;

  public static func Create(player: ref<PlayerPuppet>) -> ref<VMMaintenanceRewardMessage> {
    let result: ref<VMMaintenanceRewardMessage> = new VMMaintenanceRewardMessage();
    result.player = player;
    return result;
  }

  public func Call() -> Void {
    if IsDefined(this.player) {
      this.player.SetWarningMessage(
        "Maintenance reward: 1 CHOOH2 gascan.",
        SimpleMessageType.Money
      );
    };
  }
}

public class VMRuntimeSystem extends ScriptableSystem {
  private let store: ref<VMStorage>;
  private let settings: ref<VMSettings>;
  private let storageReady: Bool;
  private let sessionReady: Bool;
  private let runtimeInitialized: Bool;
  private let tickArmed: Bool;
  private let generation: Int32;
  private let tickPeriod: Float;
  private let proximityPeriod: Float;
  private let slowUpdatePeriod: Float;
  private let slowUpdateSeconds: Float;

  private let currentVehicle: wref<VehicleObject>;
  private let current: ref<VMVehicleState>;
  private let stolenStates: array<ref<VMVehicleState>>;
  private let autoIgnoreSeen: array<String>;
  private let runtimeSeconds: Float;
  private let stolenPruneSeconds: Float;
  private let lastLabel: String;
  private let mountSeconds: Float;
  private let syncSeconds: Float;
  private let leaderboardSeconds: Float;
  private let leaderboardDirty: Bool;
  private let leaderboardKm: Int32;
  private let autoHideSeconds: Float;
  private let autoHideLatched: Bool;
  private let liveSpeedKmh: Float;
  private let liveFactor: Float;
  private let liveConsumption: Float;
  private let refueling: Bool;
  private let refuelCostAcc: Float;
  private let activeStationIndex: Int32;
  private let activeGasPointIndex: Int32;
  private let gasScanSeconds: Float;
  private let repairScanSeconds: Float;
  private let cachedVehicleCondition: Int32;
  private let conditionSampleSeconds: Float;
  private let publishedFactNames: array<CName>;
  private let publishedFactValues: array<Int32>;
  private let stateSyncCacheReady: Bool;
  private let stateSyncMeters: Int32;
  private let stateSyncFuelPermille: Int32;
  private let stateSyncOilDeciC: Int32;
  private let stateSyncStalled: Int32;
  private let stateSyncLimitOn: Int32;
  private let stateSyncMaintenanceDueM: Int32;

  private let gasPoints: array<ref<VMGasPoint>>;
  private let stations: array<ref<VMGasStation>>;
  private let repairPoints: array<ref<VMRepairPoint>>;
  private let mappins: array<NewMappinID>;

  private let repairAutomatic: Bool;
  private let repairStage: Int32;
  private let repairTimer: Float;
  private let repairStepTimer: Float;
  private let repairPointIndex: Int32;
  private let repairCost: Int32;
  private let repairOldCondition: Int32;
  private let repairVehicle: wref<VehicleObject>;
  private let repairLabel: String;
  private let repairRecordID: TweakDBID;
  private let repairVehicleType: gamedataVehicleType;
  private let repairOldEntityID: EntityID;
  private let repairSpawnedEntityID: EntityID;
  private let repairOrientation: EulerAngles;
  private let repairPaid: Bool;
  private let repairSummonMode: Bool;
  private let repairSettlePasses: Int32;
  private let repairedPointLatch: Int32;
  private let repairedVehicleID: EntityID;
  private let pendingRepairDrone: Bool;
  private let pendingRepairMessage: String;
  private let pendingRepairReward: Bool;
  private let lastNearRepairPoint: Int32;

  private let maintenanceActive: Bool;
  private let maintenanceVehicleLabel: String;
  private let maintenanceLastMeters: Float;
  private let maintenanceHeatRemainder: Float;
  private let oilCooldownSeconds: Float;
  private let lastDecompressionEvent: Int32;
  private let lastForceMaintenanceCommand: Int32;
  private let lastEconomyHour: Int32;
  private let marketPrice: Float;
  private let currentPrice: Float;

  public static func Get() -> ref<VMRuntimeSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance())
      .Get(n"VehicleMileage.Runtime.VMRuntimeSystem") as VMRuntimeSystem;
  }

  private func OnAttach() -> Void {
    this.tickPeriod = 0.10;
    this.proximityPeriod = 0.25;
    this.slowUpdatePeriod = 0.50;
    this.activeStationIndex = -1;
    this.activeGasPointIndex = -1;
    this.cachedVehicleCondition = -1;
    this.repairPointIndex = -1;
    this.repairedPointLatch = -1;
    this.lastNearRepairPoint = -1;
    this.store = new VMStorage();
    this.storageReady = this.store.Initialize();
    if this.storageReady {
      this.settings = this.store.GetSettings();
    };

    let callbacks: wref<CallbackSystem> = GameInstance.GetCallbackSystem();
    if IsDefined(callbacks) {
      callbacks.RegisterCallback(n"Session/Ready", this, n"OnSessionReady")
        .SetLifetime(CallbackLifetime.Forever);
      callbacks.RegisterCallback(n"Session/BeforeEnd", this, n"OnSessionBeforeEnd")
        .SetLifetime(CallbackLifetime.Forever);
    };
  }

  private cb func OnSessionReady(event: ref<GameSessionEvent>) -> Void {
    this.generation += 1;
    this.sessionReady = true;
    this.runtimeInitialized = false;
    this.tickArmed = false;
    this.ResetRuntimeReferences();
    this.InitializeSessionRuntime();
    this.ArmTick();
  }

  private cb func OnSessionBeforeEnd(event: ref<GameSessionEvent>) -> Void {
    this.SyncCurrentState();
    this.StopRefueling();
    this.SetHUDInactive();
    this.DisableMaintenanceFX();
    this.UnregisterGasMappins();
    this.sessionReady = false;
    this.runtimeInitialized = false;
    this.generation += 1;
    this.tickArmed = false;
    this.ResetRuntimeReferences();
  }

  private func InitializeSessionRuntime() -> Bool {
    if this.runtimeInitialized { return true; };
    if !this.storageReady {
      this.storageReady = this.store.Initialize();
      if !this.storageReady { return false; };
    } else {
      this.store.Reload();
    };

    this.settings = this.store.GetSettings();
    this.gasPoints = this.store.GetGasPoints();
    this.repairPoints = this.store.GetRepairPoints();
    this.DisableAllRepairFX();
    this.BuildStations();
    this.InitializeEconomy();
    this.ApplySettingsRuntime();
    this.RegisterGasMappins();
    this.lastDecompressionEvent = this.GetFact(n"vm_maintenance_decompression_event");
    this.lastForceMaintenanceCommand = this.GetFact(n"vm_maintenance_force_due_cmd");
    this.runtimeInitialized = true;
    return true;
  }

  private func ResetRuntimeReferences() -> Void {
    let emptyEntityID: EntityID;
    let emptyRecordID: TweakDBID;
    let emptyOrientation: EulerAngles;
    this.currentVehicle = null;
    this.current = null;
    this.lastLabel = "";
    this.mountSeconds = 0.0;
    this.syncSeconds = 0.0;
    this.leaderboardSeconds = 0.0;
    this.leaderboardDirty = true;
    this.leaderboardKm = -1;
    this.autoHideSeconds = 0.0;
    this.autoHideLatched = false;
    this.liveSpeedKmh = 0.0;
    this.liveFactor = 1.0;
    this.liveConsumption = 0.0;
    this.refueling = false;
    this.refuelCostAcc = 0.0;
    this.activeStationIndex = -1;
    this.activeGasPointIndex = -1;
    this.gasScanSeconds = this.proximityPeriod;
    this.repairScanSeconds = this.proximityPeriod;
    this.cachedVehicleCondition = -1;
    this.conditionSampleSeconds = 0.0;
    this.slowUpdateSeconds = this.slowUpdatePeriod;
    this.stateSyncCacheReady = false;
    this.repairAutomatic = false;
    this.repairStage = 0;
    this.repairTimer = 0.0;
    this.repairStepTimer = 0.0;
    this.repairPointIndex = -1;
    this.repairCost = 0;
    this.repairOldCondition = -1;
    this.repairVehicle = null;
    this.repairLabel = "";
    this.repairRecordID = emptyRecordID;
    this.repairOldEntityID = emptyEntityID;
    this.repairSpawnedEntityID = emptyEntityID;
    this.repairOrientation = emptyOrientation;
    this.repairPaid = false;
    this.repairSummonMode = false;
    this.repairSettlePasses = 0;
    this.repairedPointLatch = -1;
    this.repairedVehicleID = emptyEntityID;
    this.pendingRepairDrone = false;
    this.pendingRepairMessage = "";
    this.pendingRepairReward = false;
    this.lastNearRepairPoint = -1;
    this.maintenanceActive = false;
    this.maintenanceVehicleLabel = "";
    this.maintenanceLastMeters = 0.0;
    this.maintenanceHeatRemainder = 0.0;
    this.oilCooldownSeconds = 0.0;
    this.runtimeSeconds = 0.0;
    this.stolenPruneSeconds = 0.0;
    ArrayClear(this.publishedFactNames);
    ArrayClear(this.publishedFactValues);
    ArrayClear(this.stolenStates);
  }

  private func ArmTick() -> Void {
    if !this.sessionReady || this.tickArmed { return; };
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGameInstance());
    if !IsDefined(delaySystem) { return; };
    this.tickArmed = true;
    delaySystem.DelayCallback(VMRuntimeTick.Create(this, this.generation), this.tickPeriod, false);
  }

  public func Tick(generation: Int32) -> Void {
    if generation != this.generation { return; };
    this.tickArmed = false;
    if !this.sessionReady {
      return;
    };
    if !this.InitializeSessionRuntime() {
      this.ArmTick();
      return;
    };
    this.runtimeSeconds += this.tickPeriod;
    this.slowUpdateSeconds += this.tickPeriod;
    let runSlowUpdates: Bool = false;
    if this.slowUpdateSeconds >= this.slowUpdatePeriod {
      this.slowUpdateSeconds = 0.0;
      runSlowUpdates = true;
    };
    if IsDefined(this.current) && !this.current.owned {
      this.current.lastSeenAt = this.runtimeSeconds;
    };
    this.PruneStolenStates();

    let player: ref<PlayerPuppet> = this.GetPlayer();
    let vehicle: ref<VehicleObject> = IsDefined(player)
      ? player.GetMountedVehicle() as VehicleObject
      : null;

    if !IsDefined(vehicle) {
      this.HandleNoMountedVehicle(player, runSlowUpdates);
      this.ArmTick();
      return;
    };

    if !IsDefined(this.currentVehicle)
      || !Equals(vehicle.GetEntityID(), this.currentVehicle.GetEntityID()) {
      this.ChangeMountedVehicle(vehicle);
    };

    if !IsDefined(this.current) || this.current.ignored {
      this.SetHUDInactive();
      this.UpdateRepair(player, vehicle);
      this.ArmTick();
      return;
    };

    this.mountSeconds += this.tickPeriod;
    this.UpdateVehicleState(player, vehicle, this.tickPeriod);
    this.UpdateVehicleCondition(vehicle);
    if runSlowUpdates { this.ProcessGascan(player); };
    this.UpdateRefueling(player, vehicle, this.tickPeriod);
    if runSlowUpdates { this.UpdateMaintenance(player); };
    this.UpdateRepair(player, vehicle);
    this.UpdateHUD(vehicle);
    if runSlowUpdates { this.UpdateEconomy(); };

    this.syncSeconds += this.tickPeriod;
    if this.syncSeconds >= 0.50 {
      this.syncSeconds = 0.0;
      this.SyncCurrentState();
    };

    this.leaderboardSeconds += this.tickPeriod;
    if this.leaderboardSeconds >= 2.0 {
      this.leaderboardSeconds = 0.0;
      if this.leaderboardDirty { this.PushLeaderboards(); };
    };
    this.ArmTick();
  }

  private func GetPlayer() -> ref<PlayerPuppet> {
    let playerSystem: ref<PlayerSystem> = GameInstance.GetPlayerSystem(this.GetGameInstance());
    return IsDefined(playerSystem)
      ? playerSystem.GetLocalPlayerMainGameObject() as PlayerPuppet
      : null;
  }

  private func ChangeMountedVehicle(vehicle: ref<VehicleObject>) -> Void {
    this.SyncCurrentState();
    this.stateSyncCacheReady = false;
    this.StopRefueling();
    this.DisableMaintenanceFX();
    this.currentVehicle = vehicle;
    this.RefreshGasPinsForMountState();
    this.lastLabel = TDBID.ToStringDEBUG(vehicle.GetRecordID());
    this.mountSeconds = 0.0;
    this.autoHideSeconds = 0.0;
    this.autoHideLatched = false;
    this.syncSeconds = 0.0;
    this.leaderboardDirty = true;
    this.leaderboardKm = -1;
    this.activeStationIndex = -1;
    this.activeGasPointIndex = -1;
    this.gasScanSeconds = this.proximityPeriod;
    this.repairScanSeconds = this.proximityPeriod;
    this.cachedVehicleCondition = -1;
    this.conditionSampleSeconds = 0.0;
    this.slowUpdateSeconds = this.slowUpdatePeriod;

    let isBike: Bool = this.IsBikeLabel(this.lastLabel);
    let owned: Bool = this.IsOwnedVehicle(vehicle);
    let ignored: Bool = this.ResolveIgnored(this.lastLabel);
    if owned {
      let spec: ref<VMVehicleSpec> = this.store.EnsureSpec(this.lastLabel, isBike);
      this.current = this.LoadOwnedState(spec);
      if IsDefined(this.current) {
        this.current.owned = true;
        this.current.ignored = ignored;
        this.Apply3DConfig(spec.config3D);
      };
    } else {
      this.current = this.SeedStolenState(this.lastLabel, isBike);
      this.current.ignored = ignored;
      this.Hide3D();
    };
    if IsDefined(this.current) {
      this.current.lastPosition = vehicle.GetWorldPosition();
      this.current.hasLastPosition = true;
      this.leaderboardKm = VMMath.RoundInt(this.current.meters / 1000.0);
    };
  }

  private func HandleNoMountedVehicle(player: ref<PlayerPuppet>, runSlowUpdates: Bool) -> Void {
    if IsDefined(this.currentVehicle) || IsDefined(this.current) {
      this.SyncCurrentState();
      this.StopRefueling();
      this.DisableMaintenanceFX();
      this.currentVehicle = null;
      this.RefreshGasPinsForMountState();
      this.current = null;
      this.lastLabel = "";
      this.mountSeconds = 0.0;
      this.liveSpeedKmh = 0.0;
      this.liveConsumption = 0.0;
      this.activeStationIndex = -1;
      this.activeGasPointIndex = -1;
      this.gasScanSeconds = this.proximityPeriod;
      this.repairScanSeconds = this.proximityPeriod;
      this.cachedVehicleCondition = -1;
      this.conditionSampleSeconds = 0.0;
      this.stateSyncCacheReady = false;
      this.SetHUDInactive();
      this.Hide3D();
    };
    if runSlowUpdates { this.ProcessGascan(player); };
    this.UpdateOilCooldown(this.tickPeriod);
    this.UpdateRepair(player, null);
    if runSlowUpdates { this.UpdateEconomy(); };
  }

  private func IsBikeLabel(label: String) -> Bool {
    let lower: String = StrLower(label);
    return StrContains(lower, "bike")
      || StrContains(lower, "yaiba")
      || StrContains(lower, "arch");
  }

  private func IsAVLabel(label: String) -> Bool {
    let lower: String = StrLower(label);
    return StrContains(lower, "vehicle.av_")
      || StrContains(lower, ".av_")
      || StrContains(lower, "_dav");
  }

  private func IsOwnedVehicle(vehicle: ref<VehicleObject>) -> Bool {
    if vehicle.IsPlayerVehicle() { return true; };
    let vehicleSystem: ref<VehicleSystem> = GameInstance.GetVehicleSystem(this.GetGameInstance());
    if !IsDefined(vehicleSystem) { return false; };
    let unlocked: array<PlayerVehicle>;
    vehicleSystem.GetPlayerUnlockedVehicles(unlocked);
    let wanted: String = TDBID.ToStringDEBUG(vehicle.GetRecordID());
    let i: Int32 = 0;
    while i < ArraySize(unlocked) {
      if Equals(unlocked[i].recordID, vehicle.GetRecordID()) { return true; };
      let unlockedLabel: String = TDBID.ToStringDEBUG(unlocked[i].recordID);
      if StrEndsWith(unlockedLabel, "_dummy") {
        unlockedLabel = StrLeft(unlockedLabel, StrLen(unlockedLabel) - 6);
      };
      if Equals(unlockedLabel, wanted) { return true; };
      i += 1;
    };
    return false;
  }

  private func IsQuestLikeLabel(label: String) -> Bool {
    let lower: String = StrLower(label);
    return StrContains(lower, "_quest")
      || StrContains(lower, ".quest")
      || StrContains(lower, "_qst")
      || StrContains(lower, "questcar")
      || this.IsNumericQuestPrefix(lower, "vehicle.q")
      || this.IsNumericQuestPrefix(lower, "vehicle.mq")
      || this.IsNumericQuestPrefix(lower, "vehicle.sq");
  }

  private func IsNumericQuestPrefix(label: String, prefix: String) -> Bool {
    if !StrBeginsWith(label, prefix) || StrLen(label) <= StrLen(prefix) {
      return false;
    };
    let character: Int32 = VMStorage.AsciiByte(
      StrMid(label, StrLen(prefix), 1)
    );
    return character >= 48 && character <= 57;
  }

  private func ResolveIgnored(label: String) -> Bool {
    let ignored: Bool = this.store.IsIgnored(label);
    let i: Int32 = 0;
    while i < ArraySize(this.autoIgnoreSeen) {
      if Equals(this.autoIgnoreSeen[i], label) { return ignored; };
      i += 1;
    };
    ArrayPush(this.autoIgnoreSeen, label);
    if !ignored && this.IsQuestLikeLabel(label) {
      return this.store.SetIgnored(label, true);
    };
    return ignored;
  }

  private func LoadOwnedState(spec: ref<VMVehicleSpec>) -> ref<VMVehicleState> {
    if !IsDefined(spec) || !IsDefined(spec.facts) { return null; };
    let state: ref<VMVehicleState> = new VMVehicleState();
    state.spec = spec;
    state.label = spec.label;
    let initialized: Int32 = this.GetFactByString(spec.facts.initialized);
    if initialized <= 0 {
      state.meters = 0.0;
      state.fuelPct = 1.0;
      state.oilTempC = 20.0;
      state.stalled = false;
      state.limitOn = false;
      state.maintenanceDueM = 0;
      this.SetFactByString(spec.facts.meters, 0);
      this.SetFactByString(spec.facts.fuelPermille, 1000);
      this.SetFactByString(spec.facts.oilDeciC, 200);
      this.SetFactByString(spec.facts.stalled, 0);
      this.SetFactByString(spec.facts.limitOn, 0);
      this.SetFactByString(spec.facts.maintenanceDueM, 0);
      this.SetFactByString(spec.facts.initialized, 1);
    } else {
      state.meters = Cast<Float>(Max(0, this.GetFactByString(spec.facts.meters)));
      state.fuelPct = Cast<Float>(VMMath.ClampInt(this.GetFactByString(spec.facts.fuelPermille), 0, 1000)) / 1000.0;
      state.oilTempC = Cast<Float>(VMMath.ClampInt(this.GetFactByString(spec.facts.oilDeciC), -500, 3000)) / 10.0;
      state.stalled = this.GetFactByString(spec.facts.stalled) > 0;
      state.limitOn = this.GetFactByString(spec.facts.limitOn) > 0;
      state.maintenanceDueM = Max(0, this.GetFactByString(spec.facts.maintenanceDueM));
    };
    return state;
  }

  private func SeedStolenState(label: String, isBike: Bool) -> ref<VMVehicleState> {
    let cachedIndex: Int32 = 0;
    while cachedIndex < ArraySize(this.stolenStates) {
      if Equals(this.stolenStates[cachedIndex].label, label) {
        this.stolenStates[cachedIndex].lastSeenAt = this.runtimeSeconds;
        return this.stolenStates[cachedIndex];
      };
      cachedIndex += 1;
    };

    let state: ref<VMVehicleState> = new VMVehicleState();
    let spec: ref<VMVehicleSpec> = new VMVehicleSpec();
    let configured: ref<VMVehicleSpec> = this.store.FindSpec(label);
    spec.label = label;
    spec.isBike = isBike;
    spec.tankL = IsDefined(configured)
      ? configured.tankL
      : isBike ? 18.0 : this.IsAVLabel(label) ? 120.0 : 35.0;
    let baseConsumption: Float = IsDefined(configured)
      ? configured.l100Km
      : isBike ? 6.0 : this.IsAVLabel(label) ? 6.0 : 12.0;
    let biasedMultiplier: Float = 2.0 + PowF(RandF(), 1.0 / 1.6) * 2.0;
    spec.l100Km = VMMath.ClampFloat(baseConsumption * biasedMultiplier, 10.0, 70.0);
    spec.oilOptMin = IsDefined(configured) ? configured.oilOptMin : 80.0;
    spec.oilOptMax = IsDefined(configured) ? configured.oilOptMax : isBike ? 100.0 : 120.0;
    spec.config3D = VM3DConfig.CreateDefault();
    state.spec = spec;
    state.label = label;
    state.owned = false;
    let tierRoll: Float = RandF() * (isBike ? 0.99 : 1.0);
    if isBike {
      state.meters = (tierRoll <= 0.80
        ? 300.0 + RandF() * 79700.0
        : tierRoll <= 0.98
          ? 80000.0 + RandF() * 120000.0
          : 200000.0 + RandF() * 100000.0) * 1000.0;
    } else {
      state.meters = (tierRoll <= 0.80
        ? 800.0 + RandF() * 99200.0
        : tierRoll <= 0.98
          ? 100000.0 + RandF() * 100000.0
          : 200000.0 + RandF() * 200000.0) * 1000.0;
    };
    state.fuelPct = 0.35 + RandF() * 0.50;
    state.oilTempC = this.OilAmbientTemperature(label);
    state.lastSeenAt = this.runtimeSeconds;
    ArrayPush(this.stolenStates, state);
    return state;
  }

  private func PruneStolenStates() -> Void {
    this.stolenPruneSeconds += this.tickPeriod;
    if this.stolenPruneSeconds < 5.0 { return; };
    this.stolenPruneSeconds = 0.0;
    let i: Int32 = ArraySize(this.stolenStates) - 1;
    while i >= 0 {
      if this.runtimeSeconds - this.stolenStates[i].lastSeenAt > 900.0 {
        ArrayErase(this.stolenStates, i);
      };
      i -= 1;
    };
  }

  private func SyncCurrentState() -> Void {
    if !IsDefined(this.current)
      || !this.current.owned
      || !IsDefined(this.current.spec)
      || !IsDefined(this.current.spec.facts) {
      return;
    };
    let facts: ref<VMFactKeys> = this.current.spec.facts;
    let meters: Int32 = Max(0, VMMath.RoundInt(this.current.meters));
    let fuelPermille: Int32 = VMMath.ClampInt(VMMath.RoundInt(this.current.fuelPct * 1000.0), 0, 1000);
    let oilDeciC: Int32 = VMMath.ClampInt(VMMath.RoundInt(this.current.oilTempC * 10.0), -500, 3000);
    let stalled: Int32 = this.current.stalled ? 1 : 0;
    let limitOn: Int32 = this.current.limitOn ? 1 : 0;
    let maintenanceDueM: Int32 = Max(0, this.current.maintenanceDueM);
    if !this.stateSyncCacheReady {
      this.SetFactByString(facts.initialized, 1);
    };
    if !this.stateSyncCacheReady || meters != this.stateSyncMeters {
      this.SetFactByString(facts.meters, meters);
    };
    if !this.stateSyncCacheReady || fuelPermille != this.stateSyncFuelPermille {
      this.SetFactByString(facts.fuelPermille, fuelPermille);
    };
    if !this.stateSyncCacheReady || oilDeciC != this.stateSyncOilDeciC {
      this.SetFactByString(facts.oilDeciC, oilDeciC);
    };
    if !this.stateSyncCacheReady || stalled != this.stateSyncStalled {
      this.SetFactByString(facts.stalled, stalled);
    };
    if !this.stateSyncCacheReady || limitOn != this.stateSyncLimitOn {
      this.SetFactByString(facts.limitOn, limitOn);
    };
    if !this.stateSyncCacheReady || maintenanceDueM != this.stateSyncMaintenanceDueM {
      this.SetFactByString(facts.maintenanceDueM, maintenanceDueM);
    };
    this.stateSyncMeters = meters;
    this.stateSyncFuelPermille = fuelPermille;
    this.stateSyncOilDeciC = oilDeciC;
    this.stateSyncStalled = stalled;
    this.stateSyncLimitOn = limitOn;
    this.stateSyncMaintenanceDueM = maintenanceDueM;
    this.stateSyncCacheReady = true;
  }

  private func UpdateVehicleState(player: ref<PlayerPuppet>, vehicle: ref<VehicleObject>, dt: Float) -> Void {
    let position: Vector4 = vehicle.GetWorldPosition();
    this.liveSpeedKmh = VMMath.ClampFloat(Vector4.Length(vehicle.GetLinearVelocity()) * 3.6, 0.0, 400.0);
    this.liveFactor = this.SpeedConsumptionFactor(this.liveSpeedKmh, this.current.spec.isBike);
    this.liveConsumption = this.liveSpeedKmh >= 1.0
      ? this.current.spec.l100Km * this.liveFactor
      : 0.0;

    if this.current.hasLastPosition {
      let rawDistance: Float = Vector4.Distance(position, this.current.lastPosition);
      let velocityDistance: Float = this.liveSpeedKmh >= 1.0
        ? (this.liveSpeedKmh / 3.6) * dt
        : 0.0;
      let distance: Float = 0.0;

      // World position is normally the most accurate source. Some mounted
      // vehicle implementations expose a live velocity while their sampled
      // world position stays unchanged or advances in very small chunks. In
      // that case, integrate the verified velocity so odometer and fuel do not
      // freeze. Large position jumps remain rejected as teleports.
      if rawDistance <= 120.0 {
        if velocityDistance > 0.0 && rawDistance < velocityDistance * 0.25 {
          distance = velocityDistance;
        } else if rawDistance > 0.01 {
          distance = rawDistance;
        };
      };

      if distance > 0.0 { this.current.meters += distance; };
			let currentKm: Int32 = VMMath.RoundInt(this.current.meters / 1000.0);
			if currentKm != this.leaderboardKm {
				this.leaderboardKm = currentKm;
				this.leaderboardDirty = true;
			};

      if this.settings.fuelEnabled && !this.current.stalled && !this.refueling {
        let usedL: Float = 0.0;
        if this.liveSpeedKmh >= 1.0 && distance > 0.0 {
          usedL = (distance / 100000.0) * this.current.spec.l100Km * this.liveFactor;
        } else if this.liveSpeedKmh < 1.0 {
          let idleLph: Float = this.IsAVLabel(this.current.label)
            ? 9.2
            : this.current.spec.isBike ? 0.4 : 0.7;
          usedL = (idleLph / 3600.0) * dt;
        };
        this.current.fuelPct = VMMath.ClampFloat(
          this.current.fuelPct - (usedL / this.current.spec.tankL),
          0.0,
          1.0
        );
        if this.current.fuelPct <= 0.0 {
          this.current.fuelPct = 0.0;
          this.current.stalled = this.current.owned || this.settings.stolenStallAtZero;
          this.current.limitOn = false;
        };
      };
    };
    this.current.lastPosition = position;
    this.current.hasLastPosition = true;
    this.UpdateOilTemperature(dt);

    // Match the legacy empty-tank limiter: 4% of the former 200 km/h
    // reference cap, plus 1 km/h hysteresis before applying the brakes.
    if this.current.stalled && this.liveSpeedKmh > 9.0 {
      vehicle.ForceBrakesFor(0.25);
      this.current.limitOn = true;
    } else if this.current.stalled {
      this.current.limitOn = false;
    };
  }

  private func SpeedConsumptionFactor(kmh: Float, isBike: Bool) -> Float {
    let base: Float = isBike ? 33.0 : 40.0;
    let ratio: Float = kmh / base;
    if ratio <= 1.0 {
      return 0.90 + 0.10 * ratio;
    };
    let excess: Float = ratio - 1.0;
    return MinF(12.0, 1.0 + 0.50 * excess + 0.95 * excess * excess);
  }

  private func UpdateOilTemperature(dt: Float) -> Void {
    let target: Float;
    let rate: Float;
    if this.liveSpeedKmh < 1.0 {
      target = this.current.spec.oilOptMin;
      rate = 0.007;
    } else if this.liveSpeedKmh < 125.0 {
      target = this.current.spec.oilOptMin;
      rate = this.current.oilTempC < target ? 0.010 : 0.007;
    } else {
      target = this.current.spec.oilOptMax
        + MaxF(0.0, this.liveSpeedKmh - 125.0) * 0.35;
      rate = this.current.oilTempC < target ? 0.055 : 0.018;
    };

    this.current.oilTempC += (target - this.current.oilTempC) * rate * dt;
    if this.liveSpeedKmh >= 125.0 && this.current.oilTempC > target {
      let speedFraction: Float = MinF(this.liveSpeedKmh / 180.0, 1.0);
      let coolingRate: Float = 0.020 * (0.30 + 0.70 * speedFraction);
      this.current.oilTempC += (target - this.current.oilTempC) * coolingRate * dt;
    };
    this.current.oilTempC = VMMath.ClampFloat(this.current.oilTempC, -50.0, 250.0);
  }

  private func GetAmbientTemperature(player: ref<PlayerPuppet>) -> Float {
    if IsDefined(player) {
      let external: Int32 = player.VM_GetWeatherConditionTemperatureC();
      if external > -100 { return Cast<Float>(external); };
    };
    let hour: Int32 = GameTime.Hours(GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime());
    return hour >= 7 && hour < 20 ? 29.0 : 20.0;
  }

  private func OilHash32(value: String) -> Uint32 {
    let hash: Uint32 = 5381u;
    let i: Int32 = 0;
    while i < StrLen(value) {
      hash = (hash * 33u)
        ^ Cast<Uint32>(VMStorage.AsciiByte(StrMid(value, i, 1)));
      i += 1;
    };
    return hash;
  }

  private func OilNoise01(label: String, salt: String) -> Float {
    return Cast<Float>(this.OilHash32(label + "|" + salt) % 10000u) / 10000.0;
  }

  private func OilAmbientTemperature(label: String) -> Float {
    let hour: Int32 = GameTime.Hours(
      GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime()
    );
    let daytime: Bool = hour >= 8 && hour < 20;
    let minimum: Float = daytime ? 25.0 : 15.0;
    let maximum: Float = daytime ? 34.0 : 24.0;
    let base: Float = minimum
      + (maximum - minimum) * this.OilNoise01(label, "base");
    let jitter: Float = 1.0
      + (this.OilNoise01(label, "jit") * 2.0 - 1.0) * 0.05;
    return MaxF(0.0, base * jitter);
  }

  private func UpdateOilCooldown(dt: Float) -> Void {
    this.oilCooldownSeconds += dt;
    if this.oilCooldownSeconds < 5.0 || !IsDefined(this.store) { return; };
    let elapsed: Float = this.oilCooldownSeconds;
    this.oilCooldownSeconds = 0.0;
    let specs: array<ref<VMVehicleSpec>> = this.store.GetSpecs();
    let i: Int32 = 0;
    while i < ArraySize(specs) {
      let spec: ref<VMVehicleSpec> = specs[i];
      if IsDefined(spec)
        && IsDefined(spec.facts)
        && this.GetFactByString(spec.facts.initialized) > 0 {
        let oilDeciC: Int32 = this.GetFactByString(spec.facts.oilDeciC);
        if oilDeciC > 300 {
          let temperature: Float = Cast<Float>(oilDeciC) / 10.0;
          let ambient: Float = this.OilAmbientTemperature(spec.label);
          temperature += (ambient - temperature) * 0.0015 * elapsed;
          this.SetFactByString(
            spec.facts.oilDeciC,
            VMMath.ClampInt(VMMath.RoundInt(temperature * 10.0), -500, 3000)
          );
        };
      };
      i += 1;
    };
  }

  private func UpdateHUD(vehicle: ref<VehicleObject>) -> Void {
    let visible: Bool = this.refueling || this.mountSeconds >= 2.70;
    if this.settings.autoHideEnabled && visible && !this.refueling {
      let lowFuel: Bool = this.current.fuelPct * 100.0 <= Cast<Float>(this.settings.autoHideFuelPct);
      if lowFuel {
        this.autoHideSeconds = 0.0;
        this.autoHideLatched = false;
      } else if !this.autoHideLatched {
        this.autoHideSeconds += this.tickPeriod;
        if this.autoHideSeconds >= this.settings.autoHideSeconds {
          this.autoHideLatched = true;
        };
      };
    } else {
      this.autoHideSeconds = 0.0;
      this.autoHideLatched = false;
    };

    if this.cachedVehicleCondition < 0 {
      this.cachedVehicleCondition = this.VehicleConditionPercent(vehicle);
      this.conditionSampleSeconds = 0.0;
    };
    this.PublishFact(n"vm_hud_visible", visible && !this.autoHideLatched ? 1 : 0);
    this.PublishFact(n"vm_hud_meters", Max(0, VMMath.RoundInt(this.current.meters)));
    this.PublishFact(n"vm_hud_fuel_permille", VMMath.ClampInt(VMMath.RoundInt(this.current.fuelPct * 1000.0), 0, 1000));
    this.PublishFact(n"vm_hud_speed_kmh", VMMath.ClampInt(VMMath.RoundInt(this.liveSpeedKmh), 0, 400));
    this.PublishFact(n"vm_hud_oil_temp_c", VMMath.ClampInt(VMMath.RoundInt(this.current.oilTempC), -50, 300));
    this.PublishFact(n"vm_hud_vehicle_cond_pct", this.cachedVehicleCondition);
    let fuelGaugeActive: Bool = this.current.owned
      && Equals(this.settings.widgetMode, "fuelgauge")
      && this.settings.fuelGaugeEnabled
      && this.settings.fuelGaugeTempEnabled;
    this.PublishFact(n"vm_fg_temp_visible", fuelGaugeActive ? 1 : 0);
  }

  private func SetHUDInactive() -> Void {
    this.PublishFact(n"vm_hud_visible", 0);
    this.PublishFact(n"vm_hud_price_visible", 0);
    this.PublishFact(n"vm_hud_vehicle_cond_pct", -1);
    this.PublishFact(n"vm_fg_temp_visible", 0);
  }

  private func VehicleConditionPercent(vehicle: ref<VehicleObject>) -> Int32 {
    if !IsDefined(vehicle) { return -1; };
    let pools: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGameInstance());
    if !IsDefined(pools) { return -1; };
    let value: Float = pools.GetStatPoolValue(
      Cast<StatsObjectID>(vehicle.GetEntityID()),
      gamedataStatPoolType.Health,
      true
    );
    return VMMath.ClampInt(VMMath.RoundInt(value), 0, 100);
  }

  private func UpdateVehicleCondition(vehicle: ref<VehicleObject>) -> Void {
    this.conditionSampleSeconds += this.tickPeriod;
    if this.cachedVehicleCondition >= 0
      && this.conditionSampleSeconds < this.slowUpdatePeriod {
      return;
    };
    this.conditionSampleSeconds = 0.0;
    this.cachedVehicleCondition = this.VehicleConditionPercent(vehicle);
  }

  private func GetFact(name: CName) -> Int32 {
    let quests: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    return IsDefined(quests) ? quests.GetFact(name) : 0;
  }

  private func SetFact(name: CName, value: Int32) -> Void {
    let quests: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if IsDefined(quests) { quests.SetFact(name, value); };
  }

  private func PublishFact(name: CName, value: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.publishedFactNames) {
      if Equals(this.publishedFactNames[i], name) {
        if this.publishedFactValues[i] == value { return; };
        this.publishedFactValues[i] = value;
        this.SetFact(name, value);
        return;
      };
      i += 1;
    };
    ArrayPush(this.publishedFactNames, name);
    ArrayPush(this.publishedFactValues, value);
    this.SetFact(name, value);
  }

  private func GetFactByString(name: String) -> Int32 {
    return this.GetFact(StringToName(name));
  }

  private func SetFactByString(name: String, value: Int32) -> Void {
    this.SetFact(StringToName(name), value);
  }

  private func ShowMessage(text: String) -> Void {
    if StrLen(text) == 0 { return; };
    let message: SimpleScreenMessage;
    message.isShown = true;
    message.duration = 5.0;
    message.message = text;
    let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance())
      .Get(GetAllBlackboardDefs().UI_Notifications);
    if IsDefined(board) {
      board.SetVariant(
        GetAllBlackboardDefs().UI_Notifications.WarningMessage,
        ToVariant(message),
        true
      );
    };
  }

  private func PlayAudio(eventName: CName) -> Void {
    let audio: ref<AudioSystem> = GameInstance.GetAudioSystem(this.GetGameInstance());
    if IsDefined(audio) { audio.Play(eventName); };
  }

  private func StopAudio(eventName: CName) -> Void {
    let audio: ref<AudioSystem> = GameInstance.GetAudioSystem(this.GetGameInstance());
    if IsDefined(audio) { audio.Stop(eventName); };
  }

  private func BuildStations() -> Void {
    ArrayClear(this.stations);
    let used: array<Bool>;
    ArrayResize(used, ArraySize(this.gasPoints));
    let i: Int32 = 0;
    while i < ArraySize(this.gasPoints) {
      if !used[i] {
        let sumX: Float = this.gasPoints[i].position.X;
        let sumY: Float = this.gasPoints[i].position.Y;
        let sumZ: Float = this.gasPoints[i].position.Z;
        let count: Int32 = 1;
        let members: array<Int32>;
        ArrayPush(members, i);
        used[i] = true;
        let changed: Bool = true;
        while changed {
          changed = false;
          let centerX: Float = sumX / Cast<Float>(count);
          let centerY: Float = sumY / Cast<Float>(count);
          let j: Int32 = 0;
          while j < ArraySize(this.gasPoints) {
            if !used[j] {
              let dx: Float = this.gasPoints[j].position.X - centerX;
              let dy: Float = this.gasPoints[j].position.Y - centerY;
              if dx * dx + dy * dy <= 1225.0 {
                used[j] = true;
                sumX += this.gasPoints[j].position.X;
                sumY += this.gasPoints[j].position.Y;
                sumZ += this.gasPoints[j].position.Z;
                count += 1;
                ArrayPush(members, j);
                changed = true;
              };
            };
            j += 1;
          };
        };

        let station: ref<VMGasStation> = new VMGasStation();
        station.position.X = sumX / Cast<Float>(count);
        station.position.Y = sumY / Cast<Float>(count);
        station.position.Z = sumZ / Cast<Float>(count);
        station.position.W = 1.0;
        station.pointCount = count;
        station.capacityL = Min(380000, 30000 * Max(1, count));
        let stationNumber: Int32 = ArraySize(this.stations) + 1;
        station.maxFact = "vm_gas_station_" + this.Pad3(stationNumber) + "_max_capacity_l";
        station.availableFact = "vm_gas_station_" + this.Pad3(stationNumber) + "_available_fuel_l";
        this.SetFactByString(station.maxFact, station.capacityL);
        station.mirroredFactL = VMMath.ClampInt(
          this.GetFactByString(station.availableFact),
          0,
          station.capacityL
        );
        station.exactAvailableL = Cast<Float>(station.mirroredFactL);
        let stationIndex: Int32 = ArraySize(this.stations);
        let memberIndex: Int32 = 0;
        while memberIndex < ArraySize(members) {
          this.gasPoints[members[memberIndex]].stationIndex = stationIndex;
          memberIndex += 1;
        };
        ArrayPush(this.stations, station);
      };
      i += 1;
    };
    this.BuildEconomyProfiles();
  }

  private func BuildEconomyProfiles() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.stations) {
      let neighbors: Int32 = 0;
      let j: Int32 = 0;
      while j < ArraySize(this.stations) {
        if i != j {
          let dx: Float = this.stations[i].position.X - this.stations[j].position.X;
          let dy: Float = this.stations[i].position.Y - this.stations[j].position.Y;
          if dx * dx + dy * dy <= 1440000.0 { neighbors += 1; };
        };
        j += 1;
      };
      let urbanity: Float = VMMath.ClampFloat(Cast<Float>(neighbors) / 6.0, 0.0, 1.0);
      this.stations[i].urbanity = urbanity;
      this.stations[i].targetFill = 0.90 + (0.50 - 0.90) * urbanity;
      this.stations[i].demandFraction = 0.0018 + (0.0080 - 0.0018) * urbanity;
      this.stations[i].deliveryInterval = Max(1, VMMath.RoundInt(18.0 + (8.0 - 18.0) * urbanity));
      this.stations[i].shipmentFraction = 0.14 + (0.08 - 0.14) * urbanity;
      i += 1;
    };
  }

  private func Pad3(value: Int32) -> String {
    if value < 10 { return "00" + IntToString(value); };
    if value < 100 { return "0" + IntToString(value); };
    return IntToString(value);
  }

  private func SyncStationFromFact(index: Int32) -> Float {
    if index < 0 || index >= ArraySize(this.stations) { return 0.0; };
    let station: ref<VMGasStation> = this.stations[index];
    let factValue: Int32 = VMMath.ClampInt(
      this.GetFactByString(station.availableFact),
      0,
      station.capacityL
    );
    if factValue != station.mirroredFactL {
      station.mirroredFactL = factValue;
      station.exactAvailableL = Cast<Float>(factValue);
    };
    return station.exactAvailableL;
  }

  private func WriteStationFuel(index: Int32, liters: Float) -> Void {
    if index < 0 || index >= ArraySize(this.stations) { return; };
    let station: ref<VMGasStation> = this.stations[index];
    station.exactAvailableL = VMMath.ClampFloat(liters, 0.0, Cast<Float>(station.capacityL));
    station.mirroredFactL = Max(0, FloorF(station.exactAvailableL + 0.000001));
    this.SetFactByString(station.availableFact, station.mirroredFactL);
  }

  private func InitializeEconomy() -> Void {
    if ArraySize(this.stations) == 0 { return; };
    let currentHour: Int32 = this.CurrentGameHour();
    let severity: Int32 = VMMath.ClampInt(this.GetFact(n"vm_gas_economy_shortage_severity"), 0, 2);
    let untilHour: Int32 = Max(0, this.GetFact(n"vm_gas_economy_shortage_until_hour"));
    if severity > 0 && currentHour >= untilHour {
      this.SetFact(n"vm_gas_economy_shortage_severity", 0);
      this.SetFact(n"vm_gas_economy_shortage_until_hour", 0);
    };
    let initialized: Int32 = this.GetFact(n"vm_gas_economy_initialized");
    if initialized <= 0 {
      let i: Int32 = 0;
      while i < ArraySize(this.stations) {
        if this.SyncStationFromFact(i) <= 0.0 {
          let variation: Float = 0.92 + this.Noise01(currentHour, (i + 1) * 43) * 0.12;
          this.WriteStationFuel(
            i,
            Cast<Float>(this.stations[i].capacityL)
              * this.stations[i].targetFill
              * variation
          );
        };
        i += 1;
      };
      this.SetFact(n"vm_gas_economy_initialized", 1);
      this.SetFact(n"vm_gas_economy_shortage_severity", 0);
      this.SetFact(n"vm_gas_economy_shortage_until_hour", 0);
      this.SetFact(n"vm_gas_economy_price_permille", 1000);
    };
    this.lastEconomyHour = currentHour;
    let persistedHour: Int32 = this.GetFact(n"vm_gas_economy_last_hour");
    if persistedHour <= 0 || persistedHour > this.lastEconomyHour {
      this.SetFact(n"vm_gas_economy_last_hour", this.lastEconomyHour);
    };
    this.marketPrice = this.settings.dynamicPrice
      ? this.NextDynamicPrice(this.settings.priceEpl, this.settings.priceEpl)
      : this.settings.priceEpl;
    this.UpdateEconomyMetrics();
    this.RefreshRuntimePrice();
  }

  private func CurrentGameHour() -> Int32 {
    let time: GameTime = GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime();
    return GameTime.Days(time) * 24 + GameTime.Hours(time);
  }

  private func Noise01(a: Int32, b: Int32) -> Float {
    let value: Float = SinF(Cast<Float>(a) * 12.9898 + Cast<Float>(b) * 78.233)
      * 43758.5453;
    return value - Cast<Float>(FloorF(value));
  }

  private func TrafficMultiplier(station: ref<VMGasStation>, hourOfDay: Int32) -> Float {
    if station.urbanity >= 0.50 {
      if hourOfDay >= 6 && hourOfDay <= 9
        || hourOfDay >= 16 && hourOfDay <= 20 {
        return 1.45;
      };
      if hourOfDay >= 1 && hourOfDay <= 5 { return 0.55; };
      return 1.0;
    };
    return hourOfDay >= 20 || hourOfDay <= 4 ? 1.15 : 0.85;
  }

  private func UpdateShortageEvent(hour: Int32) -> Void {
    let severity: Int32 = VMMath.ClampInt(this.GetFact(n"vm_gas_economy_shortage_severity"), 0, 2);
    let untilHour: Int32 = Max(0, this.GetFact(n"vm_gas_economy_shortage_until_hour"));
    if severity > 0 && hour >= untilHour {
      this.SetFact(n"vm_gas_economy_shortage_severity", 0);
      this.SetFact(n"vm_gas_economy_shortage_until_hour", 0);
    } else if severity == 0 && hour % 24 == 4 {
      let roll: Float = this.Noise01(hour, 991);
      if roll < 0.03 {
        this.SetFact(n"vm_gas_economy_shortage_severity", 2);
        this.SetFact(
          n"vm_gas_economy_shortage_until_hour",
          hour + 36 + VMMath.RoundInt(this.Noise01(hour, 992) * 60.0)
        );
      } else if roll < 0.12 {
        this.SetFact(n"vm_gas_economy_shortage_severity", 1);
        this.SetFact(
          n"vm_gas_economy_shortage_until_hour",
          hour + 18 + VMMath.RoundInt(this.Noise01(hour, 993) * 30.0)
        );
      };
    };
  }

  private func SimulateEconomyHour(hour: Int32) -> Void {
    this.UpdateShortageEvent(hour);
    let severity: Int32 = VMMath.ClampInt(this.GetFact(n"vm_gas_economy_shortage_severity"), 0, 2);
    let supply: Float = severity == 2 ? 0.18 : severity == 1 ? 0.55 : 1.0;
    let hourOfDay: Int32 = hour % 24;
    let i: Int32 = 0;
    while i < ArraySize(this.stations) {
      let station: ref<VMGasStation> = this.stations[i];
      let available: Float = this.SyncStationFromFact(i);
      let demandVariation: Float = 0.75 + this.Noise01(hour, (i + 1) * 17) * 0.50;
      let demand: Float = Cast<Float>(VMMath.RoundInt(
        Cast<Float>(station.capacityL)
          * station.demandFraction
          * this.TrafficMultiplier(station, hourOfDay)
          * demandVariation
      ));
      available = MaxF(0.0, available - demand);
      let offset: Int32 = (i + 1) % station.deliveryInterval;
      if (hour + offset) % station.deliveryInterval == 0 {
        let target: Float = Cast<Float>(VMMath.RoundInt(
          Cast<Float>(station.capacityL) * station.targetFill
        ));
        if available < target {
          let shipmentVariation: Float = 0.85 + this.Noise01(hour, (i + 1) * 29) * 0.30;
          let shipment: Float = Cast<Float>(VMMath.RoundInt(
            Cast<Float>(station.capacityL)
              * station.shipmentFraction
              * supply
              * shipmentVariation
          ));
          available = MinF(target, available + shipment);
        };
      };
      this.WriteStationFuel(i, available);
      i += 1;
    };
  }

  private func NextDynamicPrice(base: Float, previous: Float) -> Float {
    let u1: Float = MaxF(0.000001, RandF());
    let gaussian: Float = SqrtF(-2.0 * LogF(u1)) * CosF(6.2831853 * RandF());
    let raw: Float = previous + (base - previous) * 0.35 + gaussian * 0.25;
    let minimum: Float = MaxF(0.0, base * 0.90);
    let maximum: Float = MaxF(minimum, base * 1.10);
    return Cast<Float>(VMMath.RoundInt(VMMath.ClampFloat(raw, minimum, maximum) * 100.0))
      / 100.0;
  }

  private func RefreshRuntimePrice() -> Void {
    let multiplier: Float = Cast<Float>(
      VMMath.ClampInt(this.GetFact(n"vm_gas_economy_price_permille"), 1000, 2000)
    ) / 1000.0;
    this.currentPrice = MinF(
      MaxF(0.0, this.settings.priceEpl * 2.0),
      MaxF(0.0, this.marketPrice) * multiplier
    );
    this.PublishFact(n"vm_hud_price_cents", Max(0, VMMath.RoundInt(this.currentPrice * 100.0)));
  }

  private func UpdateEconomy() -> Void {
    if ArraySize(this.stations) == 0 { return; };
    let currentHour: Int32 = this.CurrentGameHour();
    let lastHour: Int32 = this.GetFact(n"vm_gas_economy_last_hour");
    if lastHour <= 0 || currentHour < lastHour {
      this.SetFact(n"vm_gas_economy_last_hour", currentHour);
      this.lastEconomyHour = currentHour;
      return;
    };
    let elapsed: Int32 = Min(168, currentHour - lastHour);
    if elapsed <= 0 { return; };

    let hour: Int32 = currentHour - elapsed + 1;
    while hour <= currentHour {
      this.SimulateEconomyHour(hour);
      hour += 1;
    };
    this.SetFact(n"vm_gas_economy_last_hour", currentHour);
    this.lastEconomyHour = currentHour;
    this.UpdateEconomyMetrics();
    this.marketPrice = this.settings.dynamicPrice
      ? this.NextDynamicPrice(this.settings.priceEpl, this.marketPrice)
      : this.settings.priceEpl;
    this.RefreshRuntimePrice();
  }

  private func UpdateEconomyMetrics() -> Void {
    if ArraySize(this.stations) == 0 { return; };
    let totalAvailable: Float = 0.0;
    let totalCapacity: Float = 0.0;
    let i: Int32 = 0;
    while i < ArraySize(this.stations) {
      totalAvailable += this.SyncStationFromFact(i);
      totalCapacity += Cast<Float>(this.stations[i].capacityL);
      i += 1;
    };
    let average: Float = totalCapacity > 0.0 ? totalAvailable / totalCapacity : 0.0;
    let priceMultiplier: Float = average >= 0.55
      ? 1.0
      : 1.0 + (0.55 - average) / 0.55;
    this.SetFact(n"vm_gas_economy_fill_permille", VMMath.ClampInt(VMMath.RoundInt(average * 1000.0), 0, 1000));
    this.SetFact(n"vm_gas_economy_price_permille", VMMath.ClampInt(VMMath.RoundInt(priceMultiplier * 1000.0), 1000, 2000));
  }

  private func GasDistanceSquared(position: Vector4, target: Vector4) -> Float {
    let dx: Float = position.X - target.X;
    let dy: Float = position.Y - target.Y;
    let dz: Float = position.Z - target.Z;
    return dx * dx + dy * dy + dz * dz;
  }

  private func IsInsideGasPoint(position: Vector4, pointIndex: Int32) -> Bool {
    if pointIndex < 0 || pointIndex >= ArraySize(this.gasPoints) { return false; };
    let radius: Float = this.gasPoints[pointIndex].radius;
    return this.GasDistanceSquared(position, this.gasPoints[pointIndex].position)
      <= radius * radius;
  }

  private func FindGasPoint(position: Vector4) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.gasPoints) {
      if this.IsInsideGasPoint(position, i) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private func UpdateRefueling(player: ref<PlayerPuppet>, vehicle: ref<VehicleObject>, dt: Float) -> Void {
    if !this.current.owned {
      this.PublishFact(n"vm_hud_price_visible", 0);
      this.PublishFact(n"vm_hud_station_empty", 0);
      this.StopRefueling();
      return;
    };
    let position: Vector4 = vehicle.GetWorldPosition();
    if this.activeGasPointIndex >= 0
      && !this.IsInsideGasPoint(position, this.activeGasPointIndex) {
      this.activeGasPointIndex = -1;
      // Scan immediately after leaving one point so adjacent pumps remain seamless.
      this.gasScanSeconds = this.proximityPeriod;
    };
    if this.activeGasPointIndex < 0 {
      this.gasScanSeconds += dt;
      if this.gasScanSeconds >= this.proximityPeriod {
        this.gasScanSeconds = 0.0;
        this.activeGasPointIndex = this.FindGasPoint(position);
      };
    };
    let stationIndex: Int32 = this.activeGasPointIndex >= 0
      ? this.gasPoints[this.activeGasPointIndex].stationIndex
      : -1;
    this.activeStationIndex = stationIndex;
    if stationIndex < 0 {
      this.PublishFact(n"vm_hud_price_visible", 0);
      this.PublishFact(n"vm_hud_station_empty", 0);
      this.StopRefueling();
      return;
    };

    let pricePerLiter: Float = MaxF(0.0, this.currentPrice);
    this.PublishFact(n"vm_hud_price_visible", 1);
    this.PublishFact(n"vm_hud_price_cents", Max(0, VMMath.RoundInt(pricePerLiter * 100.0)));

    let available: Float = this.SyncStationFromFact(stationIndex);
    this.PublishFact(n"vm_hud_station_empty", available <= 0.001 ? 1 : 0);
    if !this.settings.fuelEnabled
      || available <= 0.001
      || this.current.fuelPct >= 0.9999 {
      this.StopRefueling();
      return;
    };

    let level: Float = this.current.fuelPct;
    let shape: Float = level <= 0.60
      ? level / 0.60
      : 1.0 - ((level - 0.60) / 0.40);
    let percentPerSecond: Float = 0.006 + (0.035 - 0.006) * VMMath.ClampFloat(shape, 0.0, 1.0);
    let baseTank: Float = this.current.spec.isBike ? 18.0 : 40.0;
    let tankScale: Float = VMMath.ClampFloat(baseTank / MaxF(1.0, this.current.spec.tankL), 0.25, 3.50);
    let missingL: Float = (1.0 - this.current.fuelPct) * this.current.spec.tankL;
    let addL: Float = MinF(
      MinF(percentPerSecond * tankScale * this.current.spec.tankL * dt, missingL),
      available
    );
    if addL <= 0.0 {
      this.StopRefueling();
      return;
    };

    let projectedCost: Float = this.refuelCostAcc + addL * pricePerLiter;
    let charge: Int32 = FloorF(projectedCost);
    if charge > 0 && !this.TrySpendMoney(player, charge) {
      this.StopRefueling();
      this.ShowMessage("Refueling stopped: not enough eddies.");
      return;
    };
    this.refuelCostAcc = projectedCost - Cast<Float>(charge);
    this.current.fuelPct = VMMath.ClampFloat(
      this.current.fuelPct + addL / this.current.spec.tankL,
      0.0,
      1.0
    );
    this.current.stalled = false;
    this.current.limitOn = false;
    this.WriteStationFuel(stationIndex, available - addL);
    if !this.refueling {
      this.refueling = true;
      this.autoHideLatched = false;
      this.autoHideSeconds = 0.0;
      this.PlayAudio(n"refuel");
      this.PushLeaderboards();
      let ui: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
      if IsDefined(ui) {
        ui.VM_World_RequestFastTicks(30);
        ui.VM_PriceSign_RequestFastTicks(30);
      };
    };
  }

  private func StopRefueling() -> Void {
    if this.refueling {
      this.StopAudio(n"refuel");
    };
    this.refueling = false;
    this.refuelCostAcc = 0.0;
  }

  private func TrySpendMoney(player: ref<PlayerPuppet>, amount: Int32) -> Bool {
    if amount <= 0 { return true; };
    let transaction: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    if !IsDefined(transaction) || !IsDefined(player) { return false; };
    let money: ItemID = MarketSystem.Money();
    if transaction.GetItemQuantity(player, money) < amount { return false; };
    return transaction.RemoveItem(player, money, amount);
  }

  private func ProcessGascan(player: ref<PlayerPuppet>) -> Void {
    let pending: Int32 = this.GetFact(n"elm_chooh2_gascan_pending");
    if pending <= 0 { return; };
    this.SetFact(n"elm_chooh2_gascan_pending", 0);
    let transaction: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    let gascan: ItemID = ItemID.FromTDBID(t"Items.chooh2_gascan");
    if !IsDefined(player)
      || !IsDefined(this.current)
      || !this.current.owned
      || this.current.ignored
      || !IsDefined(this.current.spec) {
      if IsDefined(transaction) && IsDefined(player) {
        transaction.GiveItem(player, gascan, pending);
      };
      this.ShowMessage("CHOOH2 gascan returned: mount an owned configured vehicle.");
      return;
    };

    let missingL: Float = (1.0 - this.current.fuelPct) * this.current.spec.tankL;
    if missingL <= 0.001 {
      if IsDefined(transaction) { transaction.GiveItem(player, gascan, pending); };
      this.ShowMessage("CHOOH2 gascan returned: the fuel tank is already full.");
      return;
    };
    let needed: Int32 = CeilF(missingL / 10.0);
    let consumed: Int32 = Min(pending, Max(1, needed));
    let returned: Int32 = pending - consumed;
    if returned > 0 && IsDefined(transaction) {
      transaction.GiveItem(player, gascan, returned);
    };
    let addedL: Float = MinF(missingL, Cast<Float>(consumed) * 10.0);
    this.current.fuelPct = VMMath.ClampFloat(
      this.current.fuelPct + addedL / this.current.spec.tankL,
      0.0,
      1.0
    );
    this.current.stalled = false;
    this.current.limitOn = false;
    this.SyncCurrentState();
    this.PlayAudio(n"gascan_refuel");
    this.ShowMessage("CHOOH2 gascan refueled " + FloatToString(addedL) + " L.");
  }

  private func RegisterGasMappins() -> Void {
    this.UnregisterGasMappins();
    let mappinSystem: ref<MappinSystem> = GameInstance.GetMappinSystem(this.GetGameInstance());
    if !IsDefined(mappinSystem) { return; };
    let i: Int32 = 0;
    while i < ArraySize(this.stations) {
      let data: MappinData;
      data.mappinType = t"Mappins.VehicleMileageGasStationMappinDefinition";
      data.variant = gamedataMappinVariant.CPO_PingGoHereVariant;
      data.active = true;
      data.visibleThroughWalls = true;
      data.debugCaption = "VM_VehicleMileage|CHOOH2 PUMP #" + IntToString(i + 1) + "|Pay & Refuel";
      let id: NewMappinID = mappinSystem.RegisterMappin(data, this.stations[i].position);
      mappinSystem.SetMappinActive(id, true);
      ArrayPush(this.mappins, id);
      i += 1;
    };
  }

  private func UnregisterGasMappins() -> Void {
    let mappinSystem: ref<MappinSystem> = GameInstance.GetMappinSystem(this.GetGameInstance());
    if IsDefined(mappinSystem) {
      let i: Int32 = 0;
      while i < ArraySize(this.mappins) {
        mappinSystem.UnregisterMappin(this.mappins[i]);
        i += 1;
      };
    };
    ArrayClear(this.mappins);
  }

  private func UpdateMaintenance(player: ref<PlayerPuppet>) -> Void {
    if !IsDefined(this.current) || !this.current.owned {
      this.DisableMaintenanceFX();
      this.maintenanceVehicleLabel = "";
      this.maintenanceLastMeters = 0.0;
      this.maintenanceHeatRemainder = 0.0;
      return;
    };
    if !this.settings.maintenanceEnabled {
      this.DisableMaintenanceFX();
      this.maintenanceVehicleLabel = "";
      this.maintenanceLastMeters = 0.0;
      this.maintenanceHeatRemainder = 0.0;
      return;
    };
    if this.current.maintenanceDueM <= 0 {
      this.current.maintenanceDueM = VMMath.RoundInt(this.current.meters)
        + RandRange(this.settings.maintenanceMinKm, this.settings.maintenanceMaxKm + 1) * 1000;
    };

    let forceCommand: Int32 = this.GetFact(n"vm_maintenance_force_due_cmd");
    if forceCommand < this.lastForceMaintenanceCommand {
      this.lastForceMaintenanceCommand = forceCommand;
    } else if forceCommand > this.lastForceMaintenanceCommand {
      this.lastForceMaintenanceCommand = forceCommand;
      this.current.maintenanceDueM = Max(1, VMMath.RoundInt(this.current.meters));
    };

    if NotEquals(this.maintenanceVehicleLabel, this.current.label) {
      this.maintenanceVehicleLabel = this.current.label;
      this.maintenanceLastMeters = this.current.meters;
      this.maintenanceHeatRemainder = 0.0;
    } else {
      let previousMeters: Float = this.maintenanceLastMeters;
      let traveled: Float = this.current.meters - previousMeters;
      this.maintenanceLastMeters = this.current.meters;
      if traveled < 0.0 {
        this.maintenanceHeatRemainder = 0.0;
      } else if traveled > 0.0 {
        let temperature: Float = this.GetAmbientTemperature(player);
        let multiplier: Float = temperature >= 37.0
          ? 2.0
          : temperature >= 34.0 ? 1.5 : 1.0;
        if multiplier > 1.0 && this.current.maintenanceDueM > VMMath.RoundInt(this.current.meters) {
          let extraWear: Float = traveled * (multiplier - 1.0)
            + this.maintenanceHeatRemainder;
          let wholeExtraMeters: Int32 = FloorF(extraWear);
          this.maintenanceHeatRemainder = extraWear - Cast<Float>(wholeExtraMeters);
          if wholeExtraMeters > 0 {
            this.current.maintenanceDueM = Max(
              VMMath.RoundInt(this.current.meters),
              this.current.maintenanceDueM - wholeExtraMeters
            );
          };
        };
      };
    };

    let condition: Int32 = this.cachedVehicleCondition >= 0
      ? this.cachedVehicleCondition
      : 100;
    let due: Bool = condition >= 0 && condition < 20
      || this.current.maintenanceDueM > 0
        && VMMath.RoundInt(this.current.meters) >= this.current.maintenanceDueM;
    if !due {
      this.DisableMaintenanceFX();
      return;
    };

    if !this.maintenanceActive {
      this.maintenanceActive = true;
      this.lastDecompressionEvent = this.GetFact(n"vm_maintenance_decompression_event");
      if IsDefined(player) { player.VMGasTankFX_Enable(); };
      this.ShowMessage("Vehicle maintenance overdue. Fuel-system integrity is unstable.");
    };

    let eventCount: Int32 = this.GetFact(n"vm_maintenance_decompression_event");
    if eventCount > this.lastDecompressionEvent {
      let events: Int32 = eventCount - this.lastDecompressionEvent;
      let i: Int32 = 0;
      while i < events {
        this.current.fuelPct = MaxF(
          0.0,
          this.current.fuelPct - (0.05 + RandF() * 0.05)
        );
        if this.GetFact(n"vm_maintenance_fx_mode") <= 0 {
          this.ShowMessage("Fuel-system decompression: CHOOH2 lost.");
        };
        i += 1;
      };
      if this.current.fuelPct <= 0.0 {
        this.current.stalled = true;
        this.current.limitOn = false;
      };
      this.SyncCurrentState();
    };
    this.lastDecompressionEvent = eventCount;
  }

  private func DisableMaintenanceFX() -> Void {
    if !this.maintenanceActive { return; };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    if IsDefined(player) { player.VMGasTankFX_Disable(); };
    this.maintenanceActive = false;
    this.maintenanceVehicleLabel = "";
    this.maintenanceLastMeters = 0.0;
    this.maintenanceHeatRemainder = 0.0;
  }

  private func CompleteMaintenanceFor(label: String, condition: Int32) -> Bool {
    if !this.settings.maintenanceEnabled { return false; };
    let spec: ref<VMVehicleSpec> = this.store.FindSpec(label);
    if !IsDefined(spec) { return false; };
    let state: ref<VMVehicleState> = IsDefined(this.current) && Equals(this.current.label, label)
      ? this.current
      : this.LoadOwnedState(spec);
    if !IsDefined(state) { return false; };
    let wasDue: Bool = state.maintenanceDueM > 0
      && VMMath.RoundInt(state.meters) >= state.maintenanceDueM
      || condition >= 0 && condition < 20;
    state.maintenanceDueM = VMMath.RoundInt(state.meters)
      + RandRange(this.settings.maintenanceMinKm, this.settings.maintenanceMaxKm + 1) * 1000;
    this.SetFactByString(spec.facts.maintenanceDueM, state.maintenanceDueM);
    let rewarded: Bool = false;
    if wasDue && RandF() < 0.65 {
      let player: ref<PlayerPuppet> = this.GetPlayer();
      let transaction: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
      if IsDefined(player) && IsDefined(transaction) {
        transaction.GiveItem(player, ItemID.FromTDBID(t"Items.chooh2_gascan"), 1);
        rewarded = true;
      };
    };
    this.DisableMaintenanceFX();
    return rewarded;
  }

  private func RepairDistanceSquared2D(a: Vector4, b: Vector4) -> Float {
    let dx: Float = a.X - b.X;
    let dy: Float = a.Y - b.Y;
    return dx * dx + dy * dy;
  }

  private func IsInsideRepairPoint(position: Vector4, pointIndex: Int32) -> Bool {
    if pointIndex < 0 || pointIndex >= ArraySize(this.repairPoints) { return false; };
    let radius: Float = this.repairPoints[pointIndex].radius;
    return this.RepairDistanceSquared2D(position, this.repairPoints[pointIndex].position)
      <= radius * radius;
  }

  private func FindRepairPoint(position: Vector4) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.repairPoints) {
      if this.IsInsideRepairPoint(position, i) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private func FindNearRepairPoint(position: Vector4) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.repairPoints) {
      if this.RepairDistanceSquared2D(position, this.repairPoints[i].position) <= 2500.0 {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  private func SetRepairPointFX(pointIndex: Int32, stage: Int32) -> Void {
    if !this.sessionReady || pointIndex < 0 || pointIndex >= ArraySize(this.repairPoints) {
      return;
    };
    let worldState: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
    if !IsDefined(worldState) { return; };
    let point: ref<VMRepairPoint> = this.repairPoints[pointIndex];
    let i: Int32 = 0;
    while i < ArraySize(point.fx) {
      if StrLen(point.fx[i]) > 0 {
        let enabled: Bool = stage == 1 && i == 0 || stage == 2 && i > 0;
        worldState.ToggleNode(ToNodeRef(point.fx[i]), enabled);
      };
      i += 1;
    };
  }

  private func DisableAllRepairFX() -> Void {
    if !this.sessionReady { return; };
    let i: Int32 = 0;
    while i < ArraySize(this.repairPoints) {
      this.SetRepairPointFX(i, 0);
      i += 1;
    };
  }

  private func ClearActiveRepair() -> Void {
    let emptyEntityID: EntityID;
    let emptyRecordID: TweakDBID;
    let emptyOrientation: EulerAngles;
    this.repairAutomatic = false;
    this.repairStage = 0;
    this.repairTimer = 0.0;
    this.repairStepTimer = 0.0;
    this.repairPointIndex = -1;
    this.repairCost = 0;
    this.repairOldCondition = -1;
    this.repairVehicle = null;
    this.repairLabel = "";
    this.repairRecordID = emptyRecordID;
    this.repairOldEntityID = emptyEntityID;
    this.repairSpawnedEntityID = emptyEntityID;
    this.repairOrientation = emptyOrientation;
    this.repairPaid = false;
    this.repairSummonMode = false;
    this.repairSettlePasses = 0;
  }

  private func RestoreRepairSummonMode() -> Void {
    if !this.repairSummonMode { return; };
    let vehicleSystem: ref<VehicleSystem> = GameInstance.GetVehicleSystem(this.GetGameInstance());
    if IsDefined(vehicleSystem) { vehicleSystem.ToggleSummonMode(); };
    this.repairSummonMode = false;
  }

  private func RefundRepair() -> Void {
    if !this.repairPaid || this.repairCost <= 0 { return; };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    let transaction: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    if IsDefined(player) && IsDefined(transaction) {
      transaction.GiveItem(player, MarketSystem.Money(), this.repairCost);
    };
    this.repairPaid = false;
  }

  private func LockRepairPoint(
    vehicleID: EntityID,
    triggerDrone: Bool,
    repairMessage: String,
    rewardGascan: Bool
  ) -> Void {
    this.repairedPointLatch = this.repairPointIndex;
    this.repairedVehicleID = vehicleID;
    this.pendingRepairDrone = triggerDrone;
    this.pendingRepairMessage = repairMessage;
    this.pendingRepairReward = rewardGascan;
  }

  private func QueueMaintenanceRewardMessage() -> Void {
    let player: ref<PlayerPuppet> = this.GetPlayer();
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGameInstance());
    if !IsDefined(player) || !IsDefined(delaySystem) { return; };
    delaySystem.DelayCallback(VMMaintenanceRewardMessage.Create(player), 5.25, false);
  }

  private func FailRepair(message: String, refund: Bool, lockPoint: Bool) -> Void {
    let oldVehicleID: EntityID = this.repairOldEntityID;
    let pointIndex: Int32 = this.repairPointIndex;
    // LogChannel(n"DEBUG", "[VehicleMileage.Runtime] Repair failed | " + message);
    this.RestoreRepairSummonMode();
    if refund { this.RefundRepair(); };
    if pointIndex >= 0 { this.SetRepairPointFX(pointIndex, 0); };
    if lockPoint { this.LockRepairPoint(oldVehicleID, false, "", false); };
    this.ClearActiveRepair();
    this.ShowMessage(message);
  }

  private func CancelRepair() -> Void {
    if this.repairPointIndex >= 0 { this.SetRepairPointFX(this.repairPointIndex, 0); };
    this.RestoreRepairSummonMode();
    this.ClearActiveRepair();
  }

  private func HasRepairMoney(player: ref<PlayerPuppet>) -> Bool {
    if this.repairCost <= 0 { return true; };
    let transaction: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
    return IsDefined(player)
      && IsDefined(transaction)
      && transaction.GetItemQuantity(player, MarketSystem.Money()) >= this.repairCost;
  }

  private func UnmountRepairPlayer(player: ref<PlayerPuppet>) -> Bool {
    if !IsDefined(player) { return false; };
    let mounting: ref<IMountingFacility> = GameInstance.GetMountingFacility(this.GetGameInstance());
    if !IsDefined(mounting) { return false; };
    let info: MountingInfo = mounting.GetMountingInfoSingleWithObjects(player);
    if !IMountingFacility.InfoIsComplete(info) { return false; };
    let request: ref<UnmountingRequest> = new UnmountingRequest();
    request.lowLevelMountingInfo = info;
    request.mountData = new MountEventData();
    request.mountData.isInstant = true;
    request.mountData.removePitchRollRotationOnDismount = true;
    mounting.Unmount(request);
    return true;
  }

  private func MountRepairPlayer(player: ref<PlayerPuppet>, vehicleID: EntityID) -> Bool {
    if !IsDefined(player) || !EntityID.IsDefined(vehicleID) { return false; };
    let mounting: ref<IMountingFacility> = GameInstance.GetMountingFacility(this.GetGameInstance());
    if !IsDefined(mounting) { return false; };
    let info: MountingInfo;
    info.childId = player.GetEntityID();
    info.parentId = vehicleID;
    info.slotId.id = n"seat_front_left";
    let request: ref<MountingRequest> = new MountingRequest();
    request.lowLevelMountingInfo = info;
    request.mountData = new MountEventData();
    request.mountData.isInstant = true;
    request.mountData.slotName = n"seat_front_left";
    request.mountData.mountParentEntityId = vehicleID;
    request.mountData.entryAnimName = n"forcedTransition";
    mounting.Mount(request);
    return true;
  }

  private func MoveRepairEntity(entity: ref<GameObject>) -> Bool {
    if !IsDefined(entity)
      || this.repairPointIndex < 0
      || this.repairPointIndex >= ArraySize(this.repairPoints) {
      return false;
    };
    let teleport: ref<TeleportationFacility> = GameInstance.GetTeleportationFacility(this.GetGameInstance());
    if !IsDefined(teleport) { return false; };
    teleport.Teleport(
      entity,
      this.repairPoints[this.repairPointIndex].position,
      this.repairOrientation
    );
    return true;
  }

  private func BeginRepairSpawn(player: ref<PlayerPuppet>) -> Void {
    if !IsDefined(player) || !this.HasRepairMoney(player) {
      this.FailRepair("Vehicle repair cancelled: not enough eddies.", false, true);
      return;
    };
    if !this.TrySpendMoney(player, this.repairCost) {
      this.FailRepair("Vehicle repair payment failed.", false, true);
      return;
    };
    this.repairPaid = true;
    this.SyncCurrentState();
    let vehicleSystem: ref<VehicleSystem> = GameInstance.GetVehicleSystem(this.GetGameInstance());
    if !IsDefined(vehicleSystem) {
      this.FailRepair("Vehicle repair failed: vehicle system unavailable.", true, true);
      return;
    };
    vehicleSystem.ToggleSummonMode();
    this.repairSummonMode = true;
    let garageVehicleID: GarageVehicleID;
    garageVehicleID.recordID = this.repairRecordID;
    vehicleSystem.DespawnPlayerVehicle(garageVehicleID);
    this.repairStage = 3;
    this.repairTimer = 0.0;
    this.repairStepTimer = 0.60;
  }

  private func GetSummonedRepairVehicle() -> ref<VehicleObject> {
    if EntityID.IsDefined(this.repairSpawnedEntityID) {
      let knownVehicle: ref<VehicleObject> = GameInstance.FindEntityByID(
        this.GetGameInstance(),
        this.repairSpawnedEntityID
      ) as VehicleObject;
      if IsDefined(knownVehicle) && Equals(knownVehicle.GetRecordID(), this.repairRecordID) {
        return knownVehicle;
      };
    };
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
    if !IsDefined(blackboardSystem) { return null; };
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().VehicleSummonData);
    if !IsDefined(blackboard) { return null; };
    let entityID: EntityID = blackboard.GetEntityID(
      GetAllBlackboardDefs().VehicleSummonData.SummonedVehicleEntityID
    );
    if !EntityID.IsDefined(entityID) || entityID == this.repairOldEntityID { return null; };
    let vehicle: ref<VehicleObject> = GameInstance.FindEntityByID(
      this.GetGameInstance(),
      entityID
    ) as VehicleObject;
    if !IsDefined(vehicle) || NotEquals(vehicle.GetRecordID(), this.repairRecordID) {
      return null;
    };
    return vehicle;
  }

  private func CompleteRepair(spawned: ref<VehicleObject>, remountFailed: Bool) -> Void {
    if !IsDefined(spawned) {
      this.FailRepair("Vehicle repair failed: replacement vehicle unavailable.", false, false);
      return;
    };
    let pointIndex: Int32 = this.repairPointIndex;
    let label: String = this.repairLabel;
    let oldCondition: Int32 = this.repairOldCondition;
    let spawnedID: EntityID = spawned.GetEntityID();
    let repairMessage: String = remountFailed
      ? "Vehicle repair complete. Automatic remount failed."
      : "Vehicle restoration complete.";
    let rewardGascan: Bool = this.CompleteMaintenanceFor(label, oldCondition);
    this.SetRepairPointFX(pointIndex, 2);
    this.LockRepairPoint(spawnedID, true, repairMessage, rewardGascan);
    this.repairPaid = false;
    this.ClearActiveRepair();
    this.ShowMessage(repairMessage);
  }

  private func UpdateRepairSpawn(player: ref<PlayerPuppet>, mounted: ref<VehicleObject>) -> Void {
    this.repairTimer += this.tickPeriod;
    this.repairStepTimer -= this.tickPeriod;

    if this.repairStage == 3 {
      if this.repairStepTimer > 0.0 { return; };
      let oldVehicle: ref<VehicleObject> = EntityID.IsDefined(this.repairOldEntityID)
        ? GameInstance.FindEntityByID(this.GetGameInstance(), this.repairOldEntityID) as VehicleObject
        : null;
      if IsDefined(oldVehicle) {
        if this.repairTimer >= 4.0 {
          this.FailRepair("Vehicle repair failed: old vehicle did not despawn.", true, true);
        } else {
          this.repairStepTimer = 0.10;
        };
        return;
      };

      let vehicleSystem: ref<VehicleSystem> = GameInstance.GetVehicleSystem(this.GetGameInstance());
      if !IsDefined(vehicleSystem) {
        this.FailRepair("Vehicle repair failed: vehicle system unavailable.", true, false);
        return;
      };
      let requestResult: Bool = vehicleSystem.SpawnPlayerVehicle(
        this.repairVehicleType,
        this.repairRecordID,
        false
      );
      this.RestoreRepairSummonMode();
      // SpawnPlayerVehicle's native Bool is not a reliable completion signal for
      // this garage replacement path. The legacy CET implementation correctly
      // treated a successful invocation as asynchronous and verified the fresh
      // entity through VehicleSummonData instead.
      // LogChannel(
      //   n"DEBUG",
      //   "[VehicleMileage.Runtime] Repair summon requested | nativeResult="
      //     + BoolToString(requestResult)
      //     + " | record=" + TDBID.ToStringDEBUG(this.repairRecordID)
      // );
      this.repairStage = 4;
      this.repairTimer = 0.0;
      this.repairStepTimer = 0.40;
      return;
    };

    if this.repairStage == 4 {
      if this.repairStepTimer > 0.0 { return; };
      let spawnedVehicle: ref<VehicleObject> = this.GetSummonedRepairVehicle();
      if !IsDefined(spawnedVehicle) {
        if this.repairTimer >= 8.0 {
          this.FailRepair("Vehicle repair failed: replacement summon timed out.", false, false);
        } else {
          this.repairStepTimer = 0.10;
        };
        return;
      };
      this.repairSpawnedEntityID = spawnedVehicle.GetEntityID();
      let movedToBay: Bool = this.MoveRepairEntity(spawnedVehicle);
      // LogChannel(
      //   n"DEBUG",
      //   "[VehicleMileage.Runtime] Repair replacement detected | movedToBay="
      //     + BoolToString(movedToBay)
      //     + " | record=" + TDBID.ToStringDEBUG(this.repairRecordID)
      // );
      if !this.repairAutomatic {
        this.CompleteRepair(spawnedVehicle, false);
        return;
      };
      this.MountRepairPlayer(player, this.repairSpawnedEntityID);
      this.repairStage = 5;
      this.repairTimer = 0.0;
      this.repairStepTimer = 0.15;
      return;
    };

    if this.repairStage == 5 {
      if IsDefined(mounted) && mounted.GetEntityID() == this.repairSpawnedEntityID {
        this.repairStage = 6;
        this.repairTimer = 0.0;
        this.repairStepTimer = 0.15;
        this.repairSettlePasses = 0;
        return;
      };
      if this.repairTimer >= 2.0 {
        this.CompleteRepair(this.GetSummonedRepairVehicle(), true);
        return;
      };
      if this.repairStepTimer <= 0.0 {
        this.MountRepairPlayer(player, this.repairSpawnedEntityID);
        this.repairStepTimer = 0.25;
      };
      return;
    };

    if this.repairStage == 6 && this.repairStepTimer <= 0.0 {
      this.MoveRepairEntity(player);
      this.repairSettlePasses += 1;
      if this.repairSettlePasses >= 4 {
        this.CompleteRepair(this.GetSummonedRepairVehicle(), false);
      } else {
        this.repairStepTimer = 0.15;
      };
    };
  }

  private func UpdateRepair(player: ref<PlayerPuppet>, mounted: ref<VehicleObject>) -> Void {
    if this.repairedPointLatch >= 0
      && this.repairedPointLatch < ArraySize(this.repairPoints)
      && IsDefined(mounted)
      && EntityID.IsDefined(this.repairedVehicleID)
      && mounted.GetEntityID() == this.repairedVehicleID
      && !this.IsInsideRepairPoint(mounted.GetWorldPosition(), this.repairedPointLatch) {
      let completedPoint: Int32 = this.repairedPointLatch;
      let triggerDrone: Bool = this.pendingRepairDrone;
      let repairMessage: String = this.pendingRepairMessage;
      let rewardGascan: Bool = this.pendingRepairReward;
      let emptyEntityID: EntityID;
      this.SetRepairPointFX(completedPoint, 0);
      this.repairedPointLatch = -1;
      this.repairedVehicleID = emptyEntityID;
      this.pendingRepairDrone = false;
      this.pendingRepairMessage = "";
      this.pendingRepairReward = false;
      if triggerDrone {
        this.SetFact(n"vm_drone_orbit_cmd", this.GetFact(n"vm_drone_orbit_cmd") + 1);
        this.ShowMessage(
          (StrLen(repairMessage) > 0 ? repairMessage + " " : "")
            + "Zetatech quality-assurance drone deployed."
        );
      };
      if rewardGascan { this.QueueMaintenanceRewardMessage(); };
    };

    if this.repairStage >= 3 {
      this.UpdateRepairSpawn(player, mounted);
      return;
    };

    if this.repairStage == 2 {
      this.repairTimer += this.tickPeriod;
      if IsDefined(mounted) && mounted.GetEntityID() == this.repairOldEntityID {
        if this.repairTimer >= 2.0 {
          this.FailRepair("Automatic vehicle repair could not dismount the player.", false, true);
        };
        return;
      };
      if IsDefined(mounted) {
        this.FailRepair("Automatic vehicle repair cancelled after mounting another vehicle.", false, true);
        return;
      };
      if this.repairTimer >= 0.40 { this.BeginRepairSpawn(player); };
      return;
    };

    if this.repairStage == 1 {
      if !IsDefined(this.repairVehicle)
        || !this.IsInsideRepairPoint(
          this.repairVehicle.GetWorldPosition(),
          this.repairPointIndex
        ) {
        this.CancelRepair();
        return;
      };
      if IsDefined(mounted) && mounted.GetEntityID() != this.repairOldEntityID {
        this.CancelRepair();
        return;
      };

      if this.repairAutomatic {
        this.repairTimer += this.tickPeriod;
        if this.repairTimer >= 5.0 {
          if !this.HasRepairMoney(player) {
            this.FailRepair("Vehicle repair cancelled: not enough eddies.", false, true);
          } else if IsDefined(mounted) {
            if this.UnmountRepairPlayer(player) {
              this.repairStage = 2;
              this.repairTimer = 0.0;
            } else {
              this.FailRepair("Automatic vehicle repair could not dismount the player.", false, true);
            };
          } else {
            this.BeginRepairSpawn(player);
          };
        };
      } else if !IsDefined(mounted) {
        this.repairTimer += this.tickPeriod;
        if this.repairTimer >= 3.0 { this.BeginRepairSpawn(player); };
      };
      return;
    };

    if !IsDefined(mounted)
      || !IsDefined(this.current)
      || !this.current.owned
      || this.current.ignored {
      return;
    };

    this.repairScanSeconds += this.tickPeriod;
    if this.repairScanSeconds < this.proximityPeriod { return; };
    this.repairScanSeconds = 0.0;
    let pointIndex: Int32 = this.FindRepairPoint(mounted.GetWorldPosition());
    let nearPointIndex: Int32 = this.FindNearRepairPoint(mounted.GetWorldPosition());
    if pointIndex < 0 {
      if nearPointIndex >= 0 && nearPointIndex != this.lastNearRepairPoint {
        this.DisableAllRepairFX();
        this.lastNearRepairPoint = nearPointIndex;
      } else if nearPointIndex < 0 {
        this.lastNearRepairPoint = -1;
      };
      return;
    };
    if pointIndex == this.repairedPointLatch { return; };

    let condition: Int32 = this.VehicleConditionPercent(mounted);
    let conditionFactor: Float = condition < 0
      ? 1.0
      : VMMath.ClampFloat((100.0 - Cast<Float>(condition)) / 90.0, 0.0, 1.0);
    let priceMultiplier: Float = MaxF(
      0.0,
      1.0 + Cast<Float>(this.settings.repairPriceAdjustPct) / 100.0
    );
    this.repairCost = Max(
      0,
      VMMath.RoundInt(Cast<Float>(this.repairPoints[pointIndex].price) * conditionFactor * priceMultiplier)
    );
    this.repairAutomatic = this.settings.repairAutomatic;
    this.repairStage = 1;
    this.repairTimer = 0.0;
    this.repairStepTimer = 0.0;
    this.repairPointIndex = pointIndex;
    this.repairOldCondition = condition;
    this.repairVehicle = mounted;
    this.repairLabel = this.current.label;
    this.repairRecordID = mounted.GetRecordID();
    this.repairVehicleType = this.current.spec.isBike
      ? gamedataVehicleType.Bike
      : gamedataVehicleType.Car;
    this.repairOldEntityID = mounted.GetEntityID();
    if this.repairPoints[pointIndex].hasRotation {
      this.repairOrientation.Roll = this.repairPoints[pointIndex].roll;
      this.repairOrientation.Pitch = this.repairPoints[pointIndex].pitch;
      this.repairOrientation.Yaw = this.repairPoints[pointIndex].yaw;
    } else {
      this.repairOrientation = Quaternion.ToEulerAngles(mounted.GetWorldOrientation());
    };
    this.SetRepairPointFX(pointIndex, 1);
    this.ShowMessage(
      this.repairAutomatic
        ? "Automatic repair armed: E$" + IntToString(this.repairCost) + ". Hold position for 5 seconds."
        : "Repair armed: E$" + IntToString(this.repairCost) + ". Exit the vehicle and wait 3 seconds."
    );
  }

  private func ApplyGasPinsWorldVisibility() -> Void {
    if !IsDefined(this.settings) { return; };
    let showInWorld: Bool = this.settings.gasPinsShowInWorld
      && (!this.settings.gasPinsVehicleOnly || IsDefined(this.currentVehicle));
    TweakDBManager.SetFlat(
      t"Mappins.VehicleMileageGasStationMappinDefinition.showInWorld",
      showInWorld
    );
    // Existing mappins cache this definition. Settings changes and effective
    // vehicle-only visibility transitions re-register them after this update.
    TweakDBManager.UpdateRecord(t"Mappins.VehicleMileageGasStationMappinDefinition");
  }

  private func RefreshGasPinsForMountState() -> Void {
    this.ApplyGasPinsWorldVisibility();
    if this.sessionReady
      && IsDefined(this.settings)
      && this.settings.gasPinsShowInWorld
      && this.settings.gasPinsVehicleOnly {
      this.RegisterGasMappins();
    };
  }

  private func ApplySettingsRuntime() -> Void {
    if !IsDefined(this.settings) { return; };
    let ui: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    if IsDefined(ui) {
      ui.VM_SetHUDPosX(this.settings.hudX);
      ui.VM_SetHUDPosY(this.settings.hudY);
      ui.VM_SetPriceDx(this.settings.priceDx);
      ui.VM_SetPriceDy(this.settings.priceDy);
      ui.FG_SetOffset(this.settings.fuelGaugeDx, this.settings.fuelGaugeDy);
      ui.FG_SetScale(this.settings.fuelGaugeScale);
      ui.VM_LB_SetEnabled(this.settings.leaderboardEnabled);
      ui.VM_LB_SetOffset(this.settings.leaderboardDx, this.settings.leaderboardDy);
      ui.VM_LB_SetScale(this.settings.leaderboardScale);
      ui.VM_SetWidgetMode(this.settings.widgetMode);
      ui.VM_EnableLegacyHUD(Equals(this.settings.widgetMode, "vmhud"));
      ui.FG_EnableFuelGauge(
        Equals(this.settings.widgetMode, "fuelgauge")
          && this.settings.fuelGaugeEnabled
      );
      ui.VM_WorldLB_SetTransform(
        Cast<Float>(this.settings.worldLeaderboard.x),
        Cast<Float>(this.settings.worldLeaderboard.y),
        this.settings.worldLeaderboard.scaleMilli
      );
      ui.VM_WorldLB_SetStyle(
        this.settings.worldLeaderboard.theme,
        this.settings.worldLeaderboard.fontIndex,
        this.settings.worldLeaderboard.fontSize,
        this.settings.worldLeaderboard.hidden,
        this.settings.worldLeaderboard.brightnessMilli,
        this.settings.worldLeaderboard.borderHidden
      );
      this.ApplyWorldAux(ui, 1, this.settings.worldAux1);
      this.ApplyWorldAux(ui, 2, this.settings.worldAux2);
      this.ApplyWorldAux(ui, 3, this.settings.worldAux3);
      ui.VM_World_RequestFastTicks(30);
      ui.VM_PriceSign_RequestFastTicks(30);
    };
    this.SetFact(n"vm_fg_theme", this.settings.theme);
    // Preserve the old UI mirror facts as well as applying the transform
    // directly. VMFuelGauge uses these during world/UI reconstruction.
    this.SetFact(n"vm_gauge_dx", VMMath.RoundInt(this.settings.fuelGaugeDx));
    this.SetFact(n"vm_gauge_dy", VMMath.RoundInt(this.settings.fuelGaugeDy));
    this.SetFact(
      n"vm_gauge_scale_milli",
      VMMath.RoundInt(this.settings.fuelGaugeScale)
    );
    this.SetFact(
      n"vm_fg_enabled",
      Equals(this.settings.widgetMode, "fuelgauge") && this.settings.fuelGaugeEnabled ? 1 : 0
    );
    this.SetFact(n"vm_3d_enabled", Equals(this.settings.widgetMode, "3dwidget") ? 1 : 0);
    this.ApplyGasPinsWorldVisibility();
  }

  private func ApplyWorldAux(
    ui: ref<UISystem>,
    index: Int32,
    value: ref<VMWorldObjectSettings>
  ) -> Void {
    ui.VM_WorldAux_SetConfig(
      index,
      value.theme,
      value.fontIndex,
      value.fontSize,
      Cast<Float>(value.x),
      Cast<Float>(value.y),
      value.scaleMilli,
      !value.hidden,
      value.brightnessMilli
    );
  }

  private func PushLeaderboards() -> Void {
    if !IsDefined(this.store) { return; };
    let specs: array<ref<VMVehicleSpec>> = this.store.GetSpecs();
    let topLabels: array<String>;
    let topMeters: array<Int32>;
    let i: Int32 = 0;
    while i < ArraySize(specs) {
      if IsDefined(specs[i])
        && IsDefined(specs[i].facts)
        && this.GetFactByString(specs[i].facts.initialized) > 0 {
        let meters: Int32 = Max(0, this.GetFactByString(specs[i].facts.meters));
        if meters >= 500 {
          let insertAt: Int32 = ArraySize(topMeters);
          if insertAt < 10 {
            ArrayPush(topMeters, meters);
            ArrayPush(topLabels, specs[i].label);
          } else if meters > topMeters[9] {
            insertAt = 9;
            topMeters[9] = meters;
            topLabels[9] = specs[i].label;
          } else {
            insertAt = -1;
          };
          if insertAt >= 0 {
            while insertAt > 0 && topMeters[insertAt] > topMeters[insertAt - 1] {
              let swapMeters: Int32 = topMeters[insertAt - 1];
              let swapLabel: String = topLabels[insertAt - 1];
              topMeters[insertAt - 1] = topMeters[insertAt];
              topLabels[insertAt - 1] = topLabels[insertAt];
              topMeters[insertAt] = swapMeters;
              topLabels[insertAt] = swapLabel;
              insertAt -= 1;
            };
          };
        };
      };
      i += 1;
    };
    let ui: ref<UISystem> = GameInstance.GetUISystem(this.GetGameInstance());
    if !IsDefined(ui) { return; };
    ui.VM_LB_Clear();
    ui.VM_WorldLB_Clear();
    i = 0;
    while i < ArraySize(topMeters) {
      let name: String = this.HumanizeVehicleLabel(topLabels[i]);
      let distance: String = IntToString(
        VMMath.RoundInt(Cast<Float>(topMeters[i]) / 1000.0)
      ) + " km";
      ui.VM_LB_SetRow(i + 1, name, distance);
      ui.VM_WorldLB_SetRow(i + 1, name, distance);
      i += 1;
    };
    this.leaderboardDirty = false;
  }

  private func HumanizeVehicleLabel(label: String) -> String {
    let record = TweakDBInterface.GetVehicleRecord(TDBID.Create(label));
    if IsDefined(record) {
      let localized: String = GetLocalizedTextByKey(record.DisplayName());
      if StrLen(localized) > 0 { return localized; };
    };
    let value: String = StrBeginsWith(label, "Vehicle.")
      ? StrAfterFirst(label, "Vehicle.")
      : label;
    value = StrReplaceAll(value, "_dummy", "");
    value = StrReplaceAll(value, "_player", "");
    value = StrReplaceAll(value, "_purchasable", "");
    value = StrReplaceAll(value, "_call", "");
    value = StrReplaceAll(value, "_", " ");
    return value;
  }

  private func Apply3DPlacement(prefix: String, value: ref<VM3DPlacement>) -> Void {
    this.SetFactByString(prefix + "_side", value.side);
    this.SetFactByString(prefix + "_out_cm", value.outCm);
    this.SetFactByString(prefix + "_y_cm", value.yCm);
    this.SetFactByString(prefix + "_z_cm", value.zCm);
    this.SetFactByString(prefix + "_roll_deg", value.rollDeg);
    this.SetFactByString(prefix + "_pitch_deg", value.pitchDeg);
    this.SetFactByString(prefix + "_yaw_deg", value.yawDeg);
    this.SetFactByString(prefix + "_scale_milli", value.scaleMilli);
  }

  private func Apply3DConfig(value: ref<VM3DConfig>) -> Void {
    let config: ref<VM3DConfig> = IsDefined(value) ? value : VM3DConfig.CreateDefault();
    this.Apply3DPlacement("vm_3d_fuel", config.fuel);
    this.Apply3DPlacement("vm_3d_odo", config.odo);
    this.Apply3DPlacement("vm_3d_fuel_alt", config.fuelAlt);
    this.Apply3DPlacement("vm_3d_odo_alt", config.odoAlt);
    this.SetFact(n"vm_3d_fuel_style", config.fuelStyle);
    this.SetFact(n"vm_3d_fuel_alt_style", config.fuelAltStyle);
    this.SetFact(n"vm_3d_theme", config.theme);
    this.SetFact(n"vm_3d_font_index", config.fontIndex);
    this.SetFact(n"vm_3d_font_scale_milli", config.fontScaleMilli);
    this.SetFact(n"vm_3d_emissive_ev_deci", config.emissiveEvDeci);
    this.SetFact(n"vm_3d_fuel_hidden", config.hideFuel ? 1 : 0);
    this.SetFact(n"vm_3d_odo_hidden", config.hideOdo ? 1 : 0);
    this.SetFact(n"vm_3d_odo_hide_frame", config.hideOdoFrame ? 1 : 0);
    this.SetFact(n"vm_3d_fuel_alt_hidden", config.hideFuelAlt ? 1 : 0);
    this.SetFact(n"vm_3d_odo_alt_hidden", config.hideOdoAlt ? 1 : 0);
    this.SetFact(n"vm_3d_odo_alt_hide_frame", config.hideOdoAltFrame ? 1 : 0);
    this.SetFact(n"vm_3d_enabled", Equals(this.settings.widgetMode, "3dwidget") ? 1 : 0);
  }

  private func Hide3D() -> Void {
    this.SetFact(n"vm_3d_enabled", 0);
    this.SetFact(n"vm_3d_fuel_hidden", 1);
    this.SetFact(n"vm_3d_odo_hidden", 1);
    this.SetFact(n"vm_3d_fuel_alt_hidden", 1);
    this.SetFact(n"vm_3d_odo_alt_hidden", 1);
  }

  private func Snapshot3D() -> ref<VM3DConfig> {
    let result: ref<VM3DConfig> = VM3DConfig.CreateDefault();
    result.fuelStyle = this.GetFact(n"vm_3d_fuel_style");
    result.fuelAltStyle = this.GetFact(n"vm_3d_fuel_alt_style");
    result.theme = this.GetFact(n"vm_3d_theme");
    result.fontIndex = this.GetFact(n"vm_3d_font_index");
    result.fontScaleMilli = this.GetFact(n"vm_3d_font_scale_milli");
    result.emissiveEvDeci = this.GetFact(n"vm_3d_emissive_ev_deci");
    result.hideFuel = this.GetFact(n"vm_3d_fuel_hidden") > 0;
    result.hideOdo = this.GetFact(n"vm_3d_odo_hidden") > 0;
    result.hideOdoFrame = this.GetFact(n"vm_3d_odo_hide_frame") > 0;
    result.hideFuelAlt = this.GetFact(n"vm_3d_fuel_alt_hidden") > 0;
    result.hideOdoAlt = this.GetFact(n"vm_3d_odo_alt_hidden") > 0;
    result.hideOdoAltFrame = this.GetFact(n"vm_3d_odo_alt_hide_frame") > 0;
    this.SnapshotPlacement("vm_3d_fuel", result.fuel);
    this.SnapshotPlacement("vm_3d_odo", result.odo);
    this.SnapshotPlacement("vm_3d_fuel_alt", result.fuelAlt);
    this.SnapshotPlacement("vm_3d_odo_alt", result.odoAlt);
    return result;
  }

  private func SnapshotPlacement(prefix: String, value: ref<VM3DPlacement>) -> Void {
    value.side = this.GetFactByString(prefix + "_side");
    value.outCm = this.GetFactByString(prefix + "_out_cm");
    value.yCm = this.GetFactByString(prefix + "_y_cm");
    value.zCm = this.GetFactByString(prefix + "_z_cm");
    value.rollDeg = this.GetFactByString(prefix + "_roll_deg");
    value.pitchDeg = this.GetFactByString(prefix + "_pitch_deg");
    value.yawDeg = this.GetFactByString(prefix + "_yaw_deg");
    value.scaleMilli = this.GetFactByString(prefix + "_scale_milli");
  }

  public func IsReady() -> Bool {
    return this.storageReady;
  }

  public func GetStatus() -> String {
    if !this.storageReady {
      return "REDscript runtime: RedFileSystem storage unavailable.";
    };
    if !this.sessionReady {
      return "REDscript runtime ready; waiting for a game session.";
    };
    if !IsDefined(this.current) {
      return "REDscript runtime active; no mounted vehicle | fuel E$"
        + FloatToString(this.currentPrice) + "/L";
    };
    return "REDscript runtime active | "
      + (this.current.owned ? "owned" : "stolen")
      + (this.current.ignored ? " | ignored" : "")
      + (this.refueling ? " | refueling" : "");
  }

  public func GetMountedLabel() -> String {
    return this.lastLabel;
  }

  public func IsMountedOwned() -> Bool {
    return IsDefined(this.current) && this.current.owned;
  }

  public func IsMountedIgnored() -> Bool {
    return IsDefined(this.current) && this.current.ignored;
  }

  private func ReloadDeveloperGasLocations(seedPointIndex: Int32) -> Void {
    this.activeStationIndex = -1;
    this.activeGasPointIndex = -1;
    this.gasScanSeconds = this.proximityPeriod;
    this.gasPoints = this.store.GetGasPoints();
    this.BuildStations();
    if seedPointIndex >= 0 && seedPointIndex < ArraySize(this.gasPoints) {
      let stationIndex: Int32 = this.gasPoints[seedPointIndex].stationIndex;
      if stationIndex >= 0
        && stationIndex < ArraySize(this.stations)
        && this.SyncStationFromFact(stationIndex) <= 0.0 {
        this.WriteStationFuel(
          stationIndex,
          Cast<Float>(this.stations[stationIndex].capacityL)
            * this.stations[stationIndex].targetFill
        );
      };
    };
    this.InitializeEconomy();
    this.ApplyGasPinsWorldVisibility();
    this.RegisterGasMappins();
  }

  private func ReloadDeveloperRepairLocations() -> Void {
    this.repairPoints = this.store.GetRepairPoints();
    this.repairPointIndex = -1;
    this.repairedPointLatch = -1;
    this.lastNearRepairPoint = -1;
    this.repairScanSeconds = this.proximityPeriod;
  }

  private func FindNearestGasLocation(position: Vector4, maxDistance: Float) -> Int32 {
    let result: Int32 = -1;
    let bestDistanceSquared: Float = maxDistance * maxDistance;
    let i: Int32 = 0;
    while i < ArraySize(this.gasPoints) {
      let distanceSquared: Float = this.RepairDistanceSquared2D(
        position,
        this.gasPoints[i].position
      );
      if distanceSquared <= bestDistanceSquared {
        bestDistanceSquared = distanceSquared;
        result = i;
      };
      i += 1;
    };
    return result;
  }

  private func FindNearestRepairLocation(position: Vector4, maxDistance: Float) -> Int32 {
    let result: Int32 = -1;
    let bestDistanceSquared: Float = maxDistance * maxDistance;
    let i: Int32 = 0;
    while i < ArraySize(this.repairPoints) {
      let distanceSquared: Float = this.RepairDistanceSquared2D(
        position,
        this.repairPoints[i].position
      );
      if distanceSquared <= bestDistanceSquared {
        bestDistanceSquared = distanceSquared;
        result = i;
      };
      i += 1;
    };
    return result;
  }

  public func GetGasPointCount() -> Int32 {
    return ArraySize(this.gasPoints);
  }

  public func GetGasStationCount() -> Int32 {
    return ArraySize(this.stations);
  }

  public func GetRepairPointCount() -> Int32 {
    return ArraySize(this.repairPoints);
  }

  public func DevAddGasLocation(radius: Float) -> String {
    if !this.storageReady || !this.sessionReady || !IsDefined(this.store) {
      return "Start or load a game session first.";
    };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    if !IsDefined(player) { return "Player position is unavailable."; };
    let vehicle: ref<VehicleObject> = player.GetMountedVehicle() as VehicleObject;
    let position: Vector4 = IsDefined(vehicle)
      ? vehicle.GetWorldPosition()
      : player.GetWorldPosition();
    radius = VMMath.ClampFloat(radius, 0.1, 100.0);
    this.StopRefueling();
    if !this.store.AddGasPoint(position, radius) {
      return "Could not write vm_gas_locations.json.";
    };
    this.ReloadDeveloperGasLocations(this.store.GetGasPointCount() - 1);
    return "Gas point added at "
      + FloatToString(position.X) + ", "
      + FloatToString(position.Y) + ", "
      + FloatToString(position.Z) + " (radius "
      + FloatToString(radius) + " m).";
  }

  public func DevRemoveGasLocation(maxDistance: Float) -> String {
    if !this.storageReady || !this.sessionReady || !IsDefined(this.store) {
      return "Start or load a game session first.";
    };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    if !IsDefined(player) { return "Player position is unavailable."; };
    let vehicle: ref<VehicleObject> = player.GetMountedVehicle() as VehicleObject;
    let position: Vector4 = IsDefined(vehicle)
      ? vehicle.GetWorldPosition()
      : player.GetWorldPosition();
    maxDistance = VMMath.ClampFloat(maxDistance, 0.1, 100.0);
    let index: Int32 = this.FindNearestGasLocation(position, maxDistance);
    if index < 0 {
      return "No gas point found within " + FloatToString(maxDistance) + " m.";
    };
    this.StopRefueling();
    if !this.store.RemoveGasPoint(index) {
      return "Could not write vm_gas_locations.json.";
    };
    this.ReloadDeveloperGasLocations(-1);
    return "Nearest gas point removed.";
  }

  public func DevAddRepairLocation(
    radius: Float,
    price: Int32,
    fx1: String,
    fx2: String,
    fx3: String,
    fx4: String,
    fx5: String,
    fx6: String,
    fx7: String,
    fx8: String,
    fx9: String,
    fx10: String
  ) -> String {
    if !this.storageReady || !this.sessionReady || !IsDefined(this.store) {
      return "Start or load a game session first.";
    };
    if this.repairStage > 0 {
      return "Finish the active repair before editing repair locations.";
    };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    if !IsDefined(player) { return "Player position is unavailable."; };
    let vehicle: ref<VehicleObject> = player.GetMountedVehicle() as VehicleObject;
    let position: Vector4 = IsDefined(vehicle)
      ? vehicle.GetWorldPosition()
      : player.GetWorldPosition();
    let rotation: EulerAngles = Quaternion.ToEulerAngles(player.GetWorldOrientation());
    let fx: array<String>;
    ArrayPush(fx, fx1);
    ArrayPush(fx, fx2);
    ArrayPush(fx, fx3);
    ArrayPush(fx, fx4);
    ArrayPush(fx, fx5);
    ArrayPush(fx, fx6);
    ArrayPush(fx, fx7);
    ArrayPush(fx, fx8);
    ArrayPush(fx, fx9);
    ArrayPush(fx, fx10);
    radius = VMMath.ClampFloat(radius, 0.1, 100.0);
    price = Max(0, price);
    this.DisableAllRepairFX();
    if !this.store.AddRepairPoint(position, radius, price, rotation, fx) {
      return "Could not write vm_repair_stations.json.";
    };
    this.ReloadDeveloperRepairLocations();
    return "Repair zone added at "
      + FloatToString(position.X) + ", "
      + FloatToString(position.Y) + ", "
      + FloatToString(position.Z) + " (radius "
      + FloatToString(radius) + " m, E$" + IntToString(price) + ").";
  }

  public func DevRemoveRepairLocation(maxDistance: Float) -> String {
    if !this.storageReady || !this.sessionReady || !IsDefined(this.store) {
      return "Start or load a game session first.";
    };
    if this.repairStage > 0 {
      return "Finish the active repair before editing repair locations.";
    };
    let player: ref<PlayerPuppet> = this.GetPlayer();
    if !IsDefined(player) { return "Player position is unavailable."; };
    let vehicle: ref<VehicleObject> = player.GetMountedVehicle() as VehicleObject;
    let position: Vector4 = IsDefined(vehicle)
      ? vehicle.GetWorldPosition()
      : player.GetWorldPosition();
    maxDistance = VMMath.ClampFloat(maxDistance, 0.1, 100.0);
    let index: Int32 = this.FindNearestRepairLocation(position, maxDistance);
    if index < 0 {
      return "No repair zone found within " + FloatToString(maxDistance) + " m.";
    };
    this.DisableAllRepairFX();
    if !this.store.RemoveRepairPoint(index) {
      return "Could not write vm_repair_stations.json.";
    };
    this.ReloadDeveloperRepairLocations();
    return "Nearest repair zone removed.";
  }

  // Public API v1 -----------------------------------------------------------
  // Fuel mutation amounts and return values are liters. Mutations target the
  // currently mounted, non-ignored vehicle and return the amount actually
  // removed or added after clamping to empty/full.

  public func HasMountedVehicle() -> Bool {
    return this.sessionReady
      && IsDefined(this.currentVehicle)
      && IsDefined(this.current)
      && IsDefined(this.current.spec);
  }

  public func IsFuelSystemEnabled() -> Bool {
    return IsDefined(this.settings) && this.settings.fuelEnabled;
  }

  public func CanModifyFuel() -> Bool {
    return this.storageReady
      && this.HasMountedVehicle()
      && !this.current.ignored
      && this.IsFuelSystemEnabled()
      && this.current.spec.tankL > 0.0;
  }

  public func GetCurrentFuelPercent() -> Float {
    return this.HasMountedVehicle()
      ? VMMath.ClampFloat(this.current.fuelPct * 100.0, 0.0, 100.0)
      : 0.0;
  }

  public func GetCurrentTankCapacityLiters() -> Float {
    return this.HasMountedVehicle() ? MaxF(0.0, this.current.spec.tankL) : 0.0;
  }

  public func GetCurrentFuelLiters() -> Float {
    return this.HasMountedVehicle()
      ? VMMath.ClampFloat(this.current.fuelPct, 0.0, 1.0)
        * this.GetCurrentTankCapacityLiters()
      : 0.0;
  }

  private func FinalizePublicFuelChange() -> Void {
    if this.current.fuelPct <= 0.0 {
      this.current.fuelPct = 0.0;
      this.current.stalled = this.current.owned || this.settings.stolenStallAtZero;
      this.current.limitOn = false;
    } else {
      this.current.stalled = false;
      this.current.limitOn = false;
    };
    this.SyncCurrentState();
    this.PublishFact(
      n"vm_hud_fuel_permille",
      VMMath.ClampInt(VMMath.RoundInt(this.current.fuelPct * 1000.0), 0, 1000)
    );
  }

  public func DrainFuel(liters: Float) -> Float {
    if !(liters > 0.0) || !this.CanModifyFuel() { return 0.0; };
    let beforeLiters: Float = this.GetCurrentFuelLiters();
    let drainedLiters: Float = MinF(liters, beforeLiters);
    if drainedLiters <= 0.0 { return 0.0; };
    this.current.fuelPct = VMMath.ClampFloat(
      (beforeLiters - drainedLiters) / this.current.spec.tankL,
      0.0,
      1.0
    );
    this.FinalizePublicFuelChange();
    return drainedLiters;
  }

  public func Refuel(liters: Float) -> Float {
    if !(liters > 0.0) || !this.CanModifyFuel() { return 0.0; };
    let capacityLiters: Float = this.GetCurrentTankCapacityLiters();
    let beforeLiters: Float = this.GetCurrentFuelLiters();
    let addedLiters: Float = MinF(liters, MaxF(0.0, capacityLiters - beforeLiters));
    if addedLiters <= 0.0 { return 0.0; };
    this.current.fuelPct = VMMath.ClampFloat(
      (beforeLiters + addedLiters) / capacityLiters,
      0.0,
      1.0
    );
    this.FinalizePublicFuelChange();
    return addedLiters;
  }

  public func GetCurrentMeters() -> Int32 {
    return IsDefined(this.current) ? Max(0, VMMath.RoundInt(this.current.meters)) : 0;
  }

  public func SetCurrentMeters(value: Int32) -> Bool {
    if !IsDefined(this.current) || !this.current.owned { return false; };
    this.current.meters = Cast<Float>(Max(0, value));
    this.leaderboardKm = VMMath.RoundInt(this.current.meters / 1000.0);
    this.leaderboardDirty = true;
    this.SyncCurrentState();
    this.UpdateHUD(this.currentVehicle);
    return true;
  }

  public func GetCurrentFuelPermille() -> Int32 {
    return IsDefined(this.current)
      ? VMMath.ClampInt(VMMath.RoundInt(this.current.fuelPct * 1000.0), 0, 1000)
      : 0;
  }

  public func SetCurrentFuelPermille(value: Int32) -> Bool {
    if !IsDefined(this.current) || !this.current.owned { return false; };
    this.current.fuelPct = Cast<Float>(VMMath.ClampInt(value, 0, 1000)) / 1000.0;
    if this.current.fuelPct > 0.0 {
      this.current.stalled = false;
      this.current.limitOn = false;
    };
    this.SyncCurrentState();
    return true;
  }

  public func GetCurrentOilTempC() -> Float {
    return IsDefined(this.current) ? this.current.oilTempC : 0.0;
  }

  public func GetLiveSpeedKmh() -> Float {
    return this.liveSpeedKmh;
  }

  public func GetLiveConsumption() -> Float {
    return this.liveConsumption;
  }

  public func GetSpecL100Km() -> Float {
    return IsDefined(this.current) && IsDefined(this.current.spec)
      ? this.current.spec.l100Km
      : 0.0;
  }

  public func GetSpecTankL() -> Float {
    return IsDefined(this.current) && IsDefined(this.current.spec)
      ? this.current.spec.tankL
      : 0.0;
  }

  public func GetSpecOilMinC() -> Float {
    return IsDefined(this.current) && IsDefined(this.current.spec)
      ? this.current.spec.oilOptMin
      : 0.0;
  }

  public func GetSpecOilMaxC() -> Float {
    return IsDefined(this.current) && IsDefined(this.current.spec)
      ? this.current.spec.oilOptMax
      : 0.0;
  }

  public func SaveCurrentSpec(l100Km: Float, tankL: Float, oilMinC: Float, oilMaxC: Float) -> String {
    if !IsDefined(this.current) || !this.current.owned || !IsDefined(this.current.spec) {
      return "Mount an owned vehicle first.";
    };
    this.current.spec.l100Km = VMMath.ClampFloat(l100Km, 0.1, 1000.0);
    this.current.spec.tankL = VMMath.ClampFloat(tankL, 0.1, 10000.0);
    this.current.spec.oilOptMin = VMMath.ClampFloat(oilMinC, -50.0, 300.0);
    this.current.spec.oilOptMax = VMMath.ClampFloat(oilMaxC, this.current.spec.oilOptMin, 300.0);
    return this.store.SaveSpecs()
      ? "Vehicle specification saved by RedFileSystem."
      : "Could not save the vehicle specification.";
  }

  public func SetCurrentIgnored(ignored: Bool) -> String {
    if !IsDefined(this.current) || StrLen(this.current.label) == 0 {
      return "Mount a vehicle first.";
    };
    if !this.store.SetIgnored(this.current.label, ignored) {
      return "Could not update vm_vehicle_ignore.json.";
    };
    this.current.ignored = ignored;
    if ignored {
      this.SetHUDInactive();
      this.Hide3D();
    } else if IsDefined(this.current.spec) {
      this.Apply3DConfig(this.current.spec.config3D);
    };
    return ignored ? "Vehicle ignored." : "Vehicle removed from ignore list.";
  }

  public func GetSettingBool(key: String) -> Bool {
    if !IsDefined(this.settings) { return false; };
    if Equals(key, "dynamic_price") { return this.settings.dynamicPrice; };
    if Equals(key, "fuel_enabled") { return this.settings.fuelEnabled; };
    if Equals(key, "maintenance_enabled") { return this.settings.maintenanceEnabled; };
    if Equals(key, "gas_pins_world") { return this.settings.gasPinsShowInWorld; };
    if Equals(key, "gas_pins_vehicle_only") { return this.settings.gasPinsVehicleOnly; };
    if Equals(key, "repair_automatic") { return this.settings.repairAutomatic; };
    if Equals(key, "stolen_stall") { return this.settings.stolenStallAtZero; };
    if Equals(key, "fg_enabled") { return this.settings.fuelGaugeEnabled; };
    if Equals(key, "fg_temp_enabled") { return this.settings.fuelGaugeTempEnabled; };
    if Equals(key, "lb_enabled") { return this.settings.leaderboardEnabled; };
    if Equals(key, "auto_hide") { return this.settings.autoHideEnabled; };
    return false;
  }

  public func SetSettingBool(key: String, value: Bool) -> Bool {
    if !IsDefined(this.settings) { return false; };
    if Equals(key, "dynamic_price") {
      this.settings.dynamicPrice = value;
      this.marketPrice = value
        ? this.NextDynamicPrice(this.settings.priceEpl, this.settings.priceEpl)
        : this.settings.priceEpl;
      this.RefreshRuntimePrice();
    }
    else if Equals(key, "fuel_enabled") { this.settings.fuelEnabled = value; }
    else if Equals(key, "maintenance_enabled") { this.settings.maintenanceEnabled = value; }
    else if Equals(key, "gas_pins_world") { this.settings.gasPinsShowInWorld = value; }
    else if Equals(key, "gas_pins_vehicle_only") { this.settings.gasPinsVehicleOnly = value; }
    else if Equals(key, "repair_automatic") { this.settings.repairAutomatic = value; }
    else if Equals(key, "stolen_stall") { this.settings.stolenStallAtZero = value; }
    else if Equals(key, "fg_enabled") { this.settings.fuelGaugeEnabled = value; }
    else if Equals(key, "fg_temp_enabled") { this.settings.fuelGaugeTempEnabled = value; }
    else if Equals(key, "lb_enabled") { this.settings.leaderboardEnabled = value; }
    else if Equals(key, "auto_hide") { this.settings.autoHideEnabled = value; }
    else { return false; };
    this.ApplySettingsRuntime();
    if this.sessionReady
      && (Equals(key, "gas_pins_world") || Equals(key, "gas_pins_vehicle_only")) {
      // Existing mappins retain their definition state. Re-register them after
      // changing showInWorld, matching the legacy marker refresh behavior.
      this.RegisterGasMappins();
    };
    return true;
  }

  public func GetSettingInt(key: String) -> Int32 {
    if !IsDefined(this.settings) { return 0; };
    if Equals(key, "maintenance_min_km") { return this.settings.maintenanceMinKm; };
    if Equals(key, "maintenance_max_km") { return this.settings.maintenanceMaxKm; };
    if Equals(key, "repair_price_adjust_pct") { return this.settings.repairPriceAdjustPct; };
    if Equals(key, "theme") { return this.settings.theme; };
    if Equals(key, "auto_hide_fuel_pct") { return this.settings.autoHideFuelPct; };
    return 0;
  }

  public func SetSettingInt(key: String, value: Int32) -> Bool {
    if !IsDefined(this.settings) { return false; };
    if Equals(key, "maintenance_min_km") {
      this.settings.maintenanceMinKm = VMMath.ClampInt(value, 1, this.settings.maintenanceMaxKm);
    } else if Equals(key, "maintenance_max_km") {
      this.settings.maintenanceMaxKm = VMMath.ClampInt(value, this.settings.maintenanceMinKm, 10000);
    } else if Equals(key, "repair_price_adjust_pct") {
      this.settings.repairPriceAdjustPct = VMMath.ClampInt(value, -100, 2000);
    } else if Equals(key, "theme") {
      this.settings.theme = VMMath.ClampInt(value, 0, 9);
    } else if Equals(key, "auto_hide_fuel_pct") {
      this.settings.autoHideFuelPct = VMMath.ClampInt(value, 0, 100);
    } else {
      return false;
    };
    this.ApplySettingsRuntime();
    return true;
  }

  public func GetSettingFloat(key: String) -> Float {
    if !IsDefined(this.settings) { return 0.0; };
    if Equals(key, "price_epl") { return this.settings.priceEpl; };
    if Equals(key, "hud_x") { return this.settings.hudX; };
    if Equals(key, "hud_y") { return this.settings.hudY; };
    if Equals(key, "price_dx") { return this.settings.priceDx; };
    if Equals(key, "price_dy") { return this.settings.priceDy; };
    if Equals(key, "fg_dx") { return this.settings.fuelGaugeDx; };
    if Equals(key, "fg_dy") { return this.settings.fuelGaugeDy; };
    if Equals(key, "fg_scale") { return this.settings.fuelGaugeScale; };
    if Equals(key, "lb_dx") { return this.settings.leaderboardDx; };
    if Equals(key, "lb_dy") { return this.settings.leaderboardDy; };
    if Equals(key, "lb_scale") { return this.settings.leaderboardScale; };
    if Equals(key, "auto_hide_seconds") { return this.settings.autoHideSeconds; };
    return 0.0;
  }

  public func SetSettingFloat(key: String, value: Float) -> Bool {
    if !IsDefined(this.settings) { return false; };
    if Equals(key, "price_epl") {
      this.settings.priceEpl = VMMath.ClampFloat(value, 0.0, 100000.0);
      this.marketPrice = this.settings.priceEpl;
      this.RefreshRuntimePrice();
    }
    else if Equals(key, "hud_x") { this.settings.hudX = VMMath.ClampFloat(value, 0.0, 1.0); }
    else if Equals(key, "hud_y") { this.settings.hudY = VMMath.ClampFloat(value, 0.0, 1.0); }
    else if Equals(key, "price_dx") { this.settings.priceDx = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "price_dy") { this.settings.priceDy = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "fg_dx") { this.settings.fuelGaugeDx = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "fg_dy") { this.settings.fuelGaugeDy = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "fg_scale") { this.settings.fuelGaugeScale = VMMath.ClampFloat(value, 1.0, 7000.0); }
    else if Equals(key, "lb_dx") { this.settings.leaderboardDx = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "lb_dy") { this.settings.leaderboardDy = VMMath.ClampFloat(value, -7000.0, 7000.0); }
    else if Equals(key, "lb_scale") { this.settings.leaderboardScale = VMMath.ClampFloat(value, 1.0, 7000.0); }
    else if Equals(key, "auto_hide_seconds") { this.settings.autoHideSeconds = VMMath.ClampFloat(value, 0.0, 120.0); }
    else { return false; };
    this.ApplySettingsRuntime();
    return true;
  }

  public func GetWidgetMode() -> String {
    return IsDefined(this.settings) ? this.settings.widgetMode : "fuelgauge";
  }

  public func SetWidgetMode(value: String) -> Bool {
    if !IsDefined(this.settings) { return false; };
    let normalized: String = StrLower(value);
    if !Equals(normalized, "vmhud")
      && !Equals(normalized, "fuelgauge")
      && !Equals(normalized, "3dwidget") {
      return false;
    };
    this.settings.widgetMode = normalized;
    this.ApplySettingsRuntime();
    if IsDefined(this.current) && this.current.owned {
      this.Apply3DConfig(this.current.spec.config3D);
    };
    return true;
  }

  private func GetWorldObject(name: String) -> ref<VMWorldObjectSettings> {
    if !IsDefined(this.settings) { return null; };
    if Equals(name, "lb") { return this.settings.worldLeaderboard; };
    if Equals(name, "aux1") { return this.settings.worldAux1; };
    if Equals(name, "aux2") { return this.settings.worldAux2; };
    if Equals(name, "aux3") { return this.settings.worldAux3; };
    return null;
  }

  public func GetWorldInt(objectName: String, key: String) -> Int32 {
    let object: ref<VMWorldObjectSettings> = this.GetWorldObject(objectName);
    if !IsDefined(object) { return 0; };
    if Equals(key, "theme") { return object.theme; };
    if Equals(key, "font") { return object.fontIndex; };
    if Equals(key, "font_size") { return object.fontSize; };
    if Equals(key, "brightness") { return object.brightnessMilli; };
    if Equals(key, "scale") { return object.scaleMilli; };
    if Equals(key, "x") { return object.x; };
    if Equals(key, "y") { return object.y; };
    return 0;
  }

  public func SetWorldInt(objectName: String, key: String, value: Int32) -> Bool {
    let object: ref<VMWorldObjectSettings> = this.GetWorldObject(objectName);
    if !IsDefined(object) { return false; };
    if Equals(key, "theme") { object.theme = VMMath.ClampInt(value, 0, 9); }
    else if Equals(key, "font") { object.fontIndex = VMMath.ClampInt(value, 0, 13); }
    else if Equals(key, "font_size") { object.fontSize = VMMath.ClampInt(value, 8, 120); }
    else if Equals(key, "brightness") { object.brightnessMilli = VMMath.ClampInt(value, 0, 3000); }
    else if Equals(key, "scale") { object.scaleMilli = VMMath.ClampInt(value, 1, 3000); }
    else if Equals(key, "x") { object.x = VMMath.ClampInt(value, -7000, 7000); }
    else if Equals(key, "y") { object.y = VMMath.ClampInt(value, -7000, 7000); }
    else { return false; };
    this.ApplySettingsRuntime();
    return true;
  }

  public func GetWorldBool(objectName: String, key: String) -> Bool {
    let object: ref<VMWorldObjectSettings> = this.GetWorldObject(objectName);
    if !IsDefined(object) { return false; };
    return Equals(key, "hidden") ? object.hidden : Equals(key, "border_hidden") && object.borderHidden;
  }

  public func SetWorldBool(objectName: String, key: String, value: Bool) -> Bool {
    let object: ref<VMWorldObjectSettings> = this.GetWorldObject(objectName);
    if !IsDefined(object) { return false; };
    if Equals(key, "hidden") { object.hidden = value; }
    else if Equals(key, "border_hidden") { object.borderHidden = value; }
    else { return false; };
    this.ApplySettingsRuntime();
    return true;
  }

  public func SaveSettingsFromOverlay() -> String {
    if !this.store.SaveSettings() {
      return "Could not write vm_settings.json through RedFileSystem.";
    };
    this.ApplySettingsRuntime();
    if this.sessionReady { this.RegisterGasMappins(); };
    return "Settings saved by RedFileSystem.";
  }

  private func Is3DKey(key: String) -> Bool {
    return Equals(key, "fuel_style")
      || Equals(key, "fuel_alt_style")
      || Equals(key, "theme")
      || Equals(key, "font_index")
      || Equals(key, "font_scale_milli")
      || Equals(key, "emissive_ev_deci")
      || Equals(key, "hide_fuel")
      || Equals(key, "hide_odo")
      || Equals(key, "hide_odo_frame")
      || Equals(key, "hide_fuel_alt")
      || Equals(key, "hide_odo_alt")
      || Equals(key, "hide_odo_alt_frame")
      || StrBeginsWith(key, "fuel.")
      || StrBeginsWith(key, "odo.")
      || StrBeginsWith(key, "fuel_alt.")
      || StrBeginsWith(key, "odo_alt.");
  }

  private func ThreeDFactName(key: String) -> String {
    if Equals(key, "hide_fuel") { return "vm_3d_fuel_hidden"; };
    if Equals(key, "hide_odo") { return "vm_3d_odo_hidden"; };
    if Equals(key, "hide_odo_frame") { return "vm_3d_odo_hide_frame"; };
    if Equals(key, "hide_fuel_alt") { return "vm_3d_fuel_alt_hidden"; };
    if Equals(key, "hide_odo_alt") { return "vm_3d_odo_alt_hidden"; };
    if Equals(key, "hide_odo_alt_frame") { return "vm_3d_odo_alt_hide_frame"; };
    return "vm_3d_" + StrReplaceAll(key, ".", "_");
  }

  public func Get3DInt(key: String) -> Int32 {
    return this.Is3DKey(key) ? this.GetFactByString(this.ThreeDFactName(key)) : 0;
  }

  public func Set3DInt(key: String, value: Int32) -> Bool {
    if !this.Is3DKey(key) || !IsDefined(this.current) || !this.current.owned {
      return false;
    };
    if Equals(key, "fuel_style") || Equals(key, "fuel_alt_style") {
      value = VMMath.ClampInt(value, 0, 5);
    } else if Equals(key, "theme") {
      value = VMMath.ClampInt(value, 0, 9);
    } else if Equals(key, "font_index") {
      value = VMMath.ClampInt(value, 0, 13);
    } else if Equals(key, "font_scale_milli") {
      value = VMMath.ClampInt(value, 500, 2000);
    } else if Equals(key, "emissive_ev_deci") {
      value = VMMath.ClampInt(value, 0, 120);
    } else if StrContains(key, ".side") {
      value = VMMath.ClampInt(value, 0, 3);
    } else if StrContains(key, ".z_cm") {
      value = VMMath.ClampInt(value, -200, 300);
    } else if StrContains(key, ".out_cm") || StrContains(key, ".y_cm") {
      value = VMMath.ClampInt(value, -300, 300);
    } else if StrContains(key, "_deg") {
      value = VMMath.ClampInt(value, -180, 180);
    } else if StrContains(key, ".scale_milli") {
      value = VMMath.ClampInt(value, 10, 2000);
    } else if StrBeginsWith(key, "hide_") {
      value = value > 0 ? 1 : 0;
    };
    this.SetFactByString(this.ThreeDFactName(key), value);
    this.SetFact(n"vm_3d_enabled", Equals(this.settings.widgetMode, "3dwidget") ? 1 : 0);
    return true;
  }

  public func SaveCurrent3D() -> String {
    if !IsDefined(this.current) || !this.current.owned || !IsDefined(this.current.spec) {
      return "Mount an owned vehicle first.";
    };
    this.current.spec.config3D = this.Snapshot3D();
    return this.store.SaveSpecs()
      ? "Vehicle 3D setup saved by RedFileSystem."
      : "Could not save the vehicle 3D setup.";
  }

  public func ResetCurrent3DPreview() -> String {
    if !IsDefined(this.current) || !this.current.owned {
      return "Mount an owned vehicle first.";
    };
    this.Apply3DConfig(VM3DConfig.CreateDefault());
    return "Default 3D setup applied as a live preview.";
  }

  public func ReloadCurrent3D() -> String {
    if !IsDefined(this.current) || !this.current.owned {
      return "Mount an owned vehicle first.";
    };
    this.Apply3DConfig(this.current.spec.config3D);
    return "Saved vehicle 3D setup reloaded.";
  }

  public func GetPresetNames() -> String {
    return this.store.GetPresetNames();
  }

  public func Refresh3DPresets() -> Int32 {
    return IsDefined(this.store) ? this.store.RefreshPresets() : 0;
  }

  public func Save3DPreset(name: String) -> String {
    if !IsDefined(this.current) || !this.current.owned {
      return "Mount an owned vehicle first.";
    };
    return this.store.SavePreset(name, this.Snapshot3D())
      ? "3D preset saved to r6\\storages\\VehicleMileage."
      : "Could not save the 3D preset.";
  }

  public func Load3DPreset(name: String) -> String {
    let preset: ref<VM3DConfig> = this.store.LoadPreset(name);
    if !IsDefined(preset) { return "3D preset not found."; };
    if !IsDefined(this.current) || !this.current.owned {
      return "Mount an owned vehicle first.";
    };
    this.Apply3DConfig(preset);
    this.ShowMessage(
      "3D preset preview loaded. Select Save vehicle 3D setup to make it persistent for this vehicle."
    );
    return "3D preset applied as a live preview.";
  }

  public func Delete3DPreset(name: String) -> String {
    return this.store.DeletePreset(name) ? "3D preset deleted." : "Could not delete the 3D preset.";
  }

  public func NeedsLegacyImport() -> Bool {
    return IsDefined(this.store) && this.store.NeedsLegacyImport();
  }

  public func NeedsLegacyPresetImport() -> Bool {
    return IsDefined(this.store) && this.store.NeedsLegacyPresetImport();
  }

  public func ImportLegacyJson(name: String, raw: String) -> Bool {
    return IsDefined(this.store) && this.store.ImportLegacyJson(name, raw);
  }

  public func FinishLegacyImport() -> Bool {
    if !IsDefined(this.store) || !this.store.FinishLegacyImport() { return false; };
    this.settings = this.store.GetSettings();
    this.gasPoints = this.store.GetGasPoints();
    this.repairPoints = this.store.GetRepairPoints();
    if this.sessionReady {
      this.SyncCurrentState();
      this.BuildStations();
      this.InitializeEconomy();
      this.ApplySettingsRuntime();
      this.RegisterGasMappins();
      this.currentVehicle = null;
      this.current = null;
    };
    return true;
  }

  public func FinishLegacyPresetImport() -> Bool {
    return IsDefined(this.store) && this.store.FinishLegacyPresetImport();
  }
}
