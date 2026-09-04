module VehicleMileage.Runtime

import RedData.Json.*
import RedFileSystem.*

public class VMStorageService extends ScriptableService {
  private let storage: ref<FileSystemStorage>;

  private cb func OnLoad() -> Void {
    // RedFileSystem grants a mod's storage only once per process. Keep that
    // single owned handle here so ScriptableSystem reattachments and session
    // changes can reuse it without revoking access for the whole game session.
    this.storage = FileSystem.GetStorage("VehicleMileage");
  }

  public static func Get() -> ref<VMStorageService> {
    return GameInstance.GetScriptableServiceContainer()
      .GetService(n"VehicleMileage.Runtime.VMStorageService") as VMStorageService;
  }

  public func GetStorage() -> ref<FileSystemStorage> {
    return this.storage;
  }
}

public class VMStorage extends IScriptable {
  private let storage: ref<FileSystemStorage>;
  private let settings: ref<VMSettings>;
  private let specs: array<ref<VMVehicleSpec>>;
  private let gasPoints: array<ref<VMGasPoint>>;
  private let repairPoints: array<ref<VMRepairPoint>>;
  private let ignoredLabels: array<String>;
  private let presetNames: array<String>;
  private let presetPaths: array<String>;
  private let presetsScanned: Bool;

  public func Initialize() -> Bool {
    let service: ref<VMStorageService> = VMStorageService.Get();
    this.storage = IsDefined(service) ? service.GetStorage() : null;
    if !IsDefined(this.storage) {
      return false;
    };
    this.Reload();
    return true;
  }

  public func Reload() -> Void {
    this.settings = this.LoadSettings();
    ArrayClear(this.specs);
    this.LoadSpecsFile("vm_config_cars.json", false);
    this.LoadSpecsFile("vm_config_bikes.json", true);
    this.gasPoints = this.LoadGasPoints();
    this.repairPoints = this.LoadRepairPoints();
    this.ignoredLabels = this.LoadIgnoreList();
    this.MergeIgnoreSeeds();
    this.RefreshPresets();
  }

  public func GetSettings() -> ref<VMSettings> {
    return this.settings;
  }

  public func GetSpecs() -> array<ref<VMVehicleSpec>> {
    return this.specs;
  }

  public func GetGasPoints() -> array<ref<VMGasPoint>> {
    return this.gasPoints;
  }

  public func GetRepairPoints() -> array<ref<VMRepairPoint>> {
    return this.repairPoints;
  }

  private static func ReadFloat(object: ref<JsonObject>, key: String, fallback: Float) -> Float {
    if !IsDefined(object) || !object.HasKey(key) { return fallback; };
    let value: ref<JsonVariant> = object.GetKey(key);
    if !IsDefined(value) { return fallback; };
    if value.IsDouble() { return Cast<Float>(value.GetDouble()); };
    if value.IsInt64() { return Cast<Float>(value.GetInt64()); };
    if value.IsUint64() { return Cast<Float>(value.GetUint64()); };
    return fallback;
  }

  private static func ReadInt(object: ref<JsonObject>, key: String, fallback: Int32) -> Int32 {
    return VMMath.RoundInt(VMStorage.ReadFloat(object, key, Cast<Float>(fallback)));
  }

  private static func ReadBool(object: ref<JsonObject>, key: String, fallback: Bool) -> Bool {
    if !IsDefined(object) || !object.HasKey(key) { return fallback; };
    let value: ref<JsonVariant> = object.GetKey(key);
    return IsDefined(value) && value.IsBool() ? value.GetBool() : fallback;
  }

  private static func ReadString(object: ref<JsonObject>, key: String, fallback: String) -> String {
    if !IsDefined(object) || !object.HasKey(key) { return fallback; };
    let value: ref<JsonVariant> = object.GetKey(key);
    if !IsDefined(value) || !value.IsString() { return fallback; };
    let result: String = value.GetString();
    return StrLen(result) > 0 ? result : fallback;
  }

  private func ReadObjectFile(name: String) -> ref<JsonObject> {
    if !IsDefined(this.storage)
      || NotEquals(this.storage.IsFile(name), FileSystemStatus.True) {
      return null;
    };
    let file: ref<File> = this.storage.GetFile(name);
    return IsDefined(file) ? file.ReadAsJson() as JsonObject : null;
  }

  private func ReadArrayFile(name: String) -> ref<JsonArray> {
    if !IsDefined(this.storage)
      || NotEquals(this.storage.IsFile(name), FileSystemStatus.True) {
      return null;
    };
    let file: ref<File> = this.storage.GetFile(name);
    return IsDefined(file) ? file.ReadAsJson() as JsonArray : null;
  }

  private func WriteJson(name: String, value: ref<JsonVariant>) -> Bool {
    if !IsDefined(this.storage) || !IsDefined(value) { return false; };
    let file: ref<File> = this.storage.GetFile(name);
    return IsDefined(file) && file.WriteJson(value, "  ");
  }

  private func WriteConfigJson(name: String, value: ref<JsonObject>) -> Bool {
    let previous: ref<JsonObject> = this.ReadObjectFile(name);
    if IsDefined(previous)
      && NotEquals(previous.ToString(""), value.ToString(""))
      && !this.CreateConfigBackup(name, previous) {
      return false;
    };
    return this.WriteJson(name, value);
  }

  private func CreateConfigBackup(name: String, value: ref<JsonObject>) -> Bool {
    let stem: String;
    if Equals(name, "vm_config_cars.json") {
      stem = "vm_config_cars";
    } else if Equals(name, "vm_config_bikes.json") {
      stem = "vm_config_bikes";
    } else {
      return true;
    };

    let prefix: String = "Backups/backup_" + stem + "_";
    let indexName: String = "Backups/vm_backup_index.json";
    let newestKey: String = stem + "_newest";
    let countKey: String = stem + "_count";
    // RedFileSystem only enumerates the storage root, so keep the subfolder's
    // rotation state beside its backups instead of relying on GetFiles().
    let index: ref<JsonObject> = this.ReadObjectFile(indexName);
    if !IsDefined(index) { index = new JsonObject(); };

    let newestSequence: Int32 = Max(0, VMStorage.ReadInt(index, newestKey, 0));
    let count: Int32 = VMMath.ClampInt(
      VMStorage.ReadInt(index, countKey, 0),
      0,
      Min(10, newestSequence)
    );
    if count >= 10 {
      let oldestSequence: Int32 = newestSequence - count + 1;
      let oldestName: String = prefix + IntToString(oldestSequence) + ".json";
      let oldestStatus: FileSystemStatus = this.storage.IsFile(oldestName);
      if Equals(oldestStatus, FileSystemStatus.True) {
        if NotEquals(this.storage.DeleteFile(oldestName), FileSystemStatus.True) {
          return false;
        };
      } else if NotEquals(oldestStatus, FileSystemStatus.False) {
        return false;
      };
    };

    newestSequence += 1;
    let backupName: String = prefix + IntToString(newestSequence) + ".json";
    if !this.WriteJson(backupName, value) { return false; };
    index.SetKeyInt64(newestKey, Cast<Int64>(newestSequence));
    index.SetKeyInt64(countKey, Cast<Int64>(count < 10 ? count + 1 : 10));
    return this.WriteJson(indexName, index);
  }

  private func LoadSettings() -> ref<VMSettings> {
    let result: ref<VMSettings> = VMSettings.CreateDefault();
    let root: ref<JsonObject> = this.ReadObjectFile("vm_settings.json");
    if !IsDefined(root) {
      this.settings = result;
      this.SaveSettings();
      return result;
    };

    result.priceEpl = VMMath.ClampFloat(VMStorage.ReadFloat(root, "price_epl", result.priceEpl), 0.0, 100000.0);
    result.dynamicPrice = VMStorage.ReadBool(root, "price_dyn_enable", result.dynamicPrice);
    result.fuelEnabled = VMStorage.ReadBool(root, "fuel_enabled", result.fuelEnabled);
    result.maintenanceEnabled = VMStorage.ReadBool(root, "maintenance_enabled", result.maintenanceEnabled);
    result.maintenanceMinKm = VMMath.ClampInt(VMStorage.ReadInt(root, "maintenance_min_km", result.maintenanceMinKm), 1, 10000);
    result.maintenanceMaxKm = VMMath.ClampInt(VMStorage.ReadInt(root, "maintenance_max_km", result.maintenanceMaxKm), result.maintenanceMinKm, 10000);
    result.gasPinsShowInWorld = VMStorage.ReadBool(root, "gas_pins_show_in_world", result.gasPinsShowInWorld);
    result.gasPinsVehicleOnly = VMStorage.ReadBool(root, "gas_pins_vehicle_only", result.gasPinsVehicleOnly);
    result.repairPriceAdjustPct = VMMath.ClampInt(VMStorage.ReadInt(root, "repair_price_adjust_pct", 0), -100, 2000);
    result.repairAutomatic = VMStorage.ReadBool(root, "repair_automatic_enabled", result.repairAutomatic);
    result.stolenStallAtZero = VMStorage.ReadBool(root, "stolen_stall_at_zero", result.stolenStallAtZero);

    let widgetMode: String = StrLower(
      VMStorage.ReadString(root, "widget_mode", result.widgetMode)
    );
    if Equals(widgetMode, "vmhud")
      || Equals(widgetMode, "fuelgauge")
      || Equals(widgetMode, "3dwidget") {
      result.widgetMode = widgetMode;
    };
    result.theme = VMMath.ClampInt(VMStorage.ReadInt(root, "fg_theme", result.theme), 0, 9);
    result.hudX = VMMath.ClampFloat(VMStorage.ReadFloat(root, "hud_x", result.hudX), 0.0, 1.0);
    result.hudY = VMMath.ClampFloat(VMStorage.ReadFloat(root, "hud_y", result.hudY), 0.0, 1.0);
    result.priceDx = VMMath.ClampFloat(VMStorage.ReadFloat(root, "price_dx_px", result.priceDx), -7000.0, 7000.0);
    result.priceDy = VMMath.ClampFloat(VMStorage.ReadFloat(root, "price_dy_px", result.priceDy), -7000.0, 7000.0);
    result.fuelGaugeEnabled = VMStorage.ReadBool(root, "fg_enabled", result.fuelGaugeEnabled);
    result.fuelGaugeTempEnabled = VMStorage.ReadBool(root, "fg_temp_enabled", result.fuelGaugeTempEnabled);
    result.fuelGaugeDx = VMMath.ClampFloat(VMStorage.ReadFloat(root, "fg_dx_px", result.fuelGaugeDx), -7000.0, 7000.0);
    result.fuelGaugeDy = VMMath.ClampFloat(VMStorage.ReadFloat(root, "fg_dy_px", result.fuelGaugeDy), -7000.0, 7000.0);
    result.fuelGaugeScale = VMMath.ClampFloat(VMStorage.ReadFloat(root, "fg_scale", result.fuelGaugeScale), 1.0, 7000.0);
    result.leaderboardEnabled = VMStorage.ReadBool(root, "lb_enabled", result.leaderboardEnabled);
    result.leaderboardDx = VMMath.ClampFloat(VMStorage.ReadFloat(root, "lb_dx_px", result.leaderboardDx), -7000.0, 7000.0);
    result.leaderboardDy = VMMath.ClampFloat(VMStorage.ReadFloat(root, "lb_dy_px", result.leaderboardDy), -7000.0, 7000.0);
    result.leaderboardScale = VMMath.ClampFloat(VMStorage.ReadFloat(root, "lb_scale", result.leaderboardScale), 1.0, 7000.0);
    result.autoHideEnabled = VMStorage.ReadBool(root, "auto_hide_enabled", result.autoHideEnabled);
    result.autoHideSeconds = VMMath.ClampFloat(VMStorage.ReadFloat(root, "auto_hide_seconds", result.autoHideSeconds), 0.0, 120.0);
    result.autoHideFuelPct = VMMath.ClampInt(VMStorage.ReadInt(root, "auto_hide_fuel_pct", result.autoHideFuelPct), 0, 100);

    let world: ref<JsonObject> = root.GetKey("world3d") as JsonObject;
    if IsDefined(world) {
      this.ReadWorldObject(world.GetKey("lb") as JsonObject, result.worldLeaderboard);
      this.ReadWorldObject(world.GetKey("aux1") as JsonObject, result.worldAux1);
      this.ReadWorldObject(world.GetKey("aux2") as JsonObject, result.worldAux2);
      this.ReadWorldObject(world.GetKey("aux3") as JsonObject, result.worldAux3);
    };
    return result;
  }

  private func ReadWorldObject(source: ref<JsonObject>, target: ref<VMWorldObjectSettings>) -> Void {
    if !IsDefined(source) || !IsDefined(target) { return; };
    target.theme = VMMath.ClampInt(VMStorage.ReadInt(source, "theme", target.theme), 0, 9);
    target.fontIndex = VMMath.ClampInt(VMStorage.ReadInt(source, "font_index", target.fontIndex), 0, 13);
    target.fontSize = VMMath.ClampInt(VMStorage.ReadInt(source, "font_size", target.fontSize), 8, 120);
    target.brightnessMilli = VMMath.ClampInt(VMStorage.ReadInt(source, "brightness_milli", target.brightnessMilli), 0, 3000);
    target.scaleMilli = VMMath.ClampInt(VMStorage.ReadInt(source, "scale", target.scaleMilli), 1, 3000);
    target.x = VMMath.ClampInt(VMStorage.ReadInt(source, "x", target.x), -7000, 7000);
    target.y = VMMath.ClampInt(VMStorage.ReadInt(source, "y", target.y), -7000, 7000);
    target.hidden = VMStorage.ReadBool(source, "hidden", target.hidden);
    target.borderHidden = VMStorage.ReadBool(source, "border_hidden", target.borderHidden);
  }

  public func SaveSettings() -> Bool {
    if !IsDefined(this.settings) { return false; };
    let root: ref<JsonObject> = new JsonObject();
    root.SetKeyDouble("price_epl", Cast<Double>(this.settings.priceEpl));
    root.SetKeyBool("price_dyn_enable", this.settings.dynamicPrice);
    root.SetKeyBool("fuel_enabled", this.settings.fuelEnabled);
    root.SetKeyBool("maintenance_enabled", this.settings.maintenanceEnabled);
    root.SetKeyInt64("maintenance_min_km", Cast<Int64>(this.settings.maintenanceMinKm));
    root.SetKeyInt64("maintenance_max_km", Cast<Int64>(this.settings.maintenanceMaxKm));
    root.SetKeyBool("gas_pins_show_in_world", this.settings.gasPinsShowInWorld);
    root.SetKeyBool("gas_pins_vehicle_only", this.settings.gasPinsVehicleOnly);
    root.SetKeyInt64("repair_price_adjust_pct", Cast<Int64>(this.settings.repairPriceAdjustPct));
    root.SetKeyBool("repair_automatic_enabled", this.settings.repairAutomatic);
    root.SetKeyBool("stolen_stall_at_zero", this.settings.stolenStallAtZero);
    root.SetKeyString("widget_mode", this.settings.widgetMode);
    root.SetKeyInt64("fg_theme", Cast<Int64>(this.settings.theme));
    root.SetKeyDouble("hud_x", Cast<Double>(this.settings.hudX));
    root.SetKeyDouble("hud_y", Cast<Double>(this.settings.hudY));
    root.SetKeyDouble("price_dx_px", Cast<Double>(this.settings.priceDx));
    root.SetKeyDouble("price_dy_px", Cast<Double>(this.settings.priceDy));
    root.SetKeyBool("fg_enabled", this.settings.fuelGaugeEnabled);
    root.SetKeyBool("fg_temp_enabled", this.settings.fuelGaugeTempEnabled);
    root.SetKeyDouble("fg_dx_px", Cast<Double>(this.settings.fuelGaugeDx));
    root.SetKeyDouble("fg_dy_px", Cast<Double>(this.settings.fuelGaugeDy));
    root.SetKeyDouble("fg_scale", Cast<Double>(this.settings.fuelGaugeScale));
    root.SetKeyBool("lb_enabled", this.settings.leaderboardEnabled);
    root.SetKeyDouble("lb_dx_px", Cast<Double>(this.settings.leaderboardDx));
    root.SetKeyDouble("lb_dy_px", Cast<Double>(this.settings.leaderboardDy));
    root.SetKeyDouble("lb_scale", Cast<Double>(this.settings.leaderboardScale));
    root.SetKeyBool("auto_hide_enabled", this.settings.autoHideEnabled);
    root.SetKeyDouble("auto_hide_seconds", Cast<Double>(this.settings.autoHideSeconds));
    root.SetKeyInt64("auto_hide_fuel_pct", Cast<Int64>(this.settings.autoHideFuelPct));

    let world: ref<JsonObject> = new JsonObject();
    world.SetKey("lb", this.WorldObjectToJson(this.settings.worldLeaderboard));
    world.SetKey("aux1", this.WorldObjectToJson(this.settings.worldAux1));
    world.SetKey("aux2", this.WorldObjectToJson(this.settings.worldAux2));
    world.SetKey("aux3", this.WorldObjectToJson(this.settings.worldAux3));
    root.SetKey("world3d", world);
    return this.WriteJson("vm_settings.json", root);
  }

  private func WorldObjectToJson(value: ref<VMWorldObjectSettings>) -> ref<JsonObject> {
    let result: ref<JsonObject> = new JsonObject();
    result.SetKeyInt64("theme", Cast<Int64>(value.theme));
    result.SetKeyInt64("font_index", Cast<Int64>(value.fontIndex));
    result.SetKeyInt64("font_size", Cast<Int64>(value.fontSize));
    result.SetKeyInt64("brightness_milli", Cast<Int64>(value.brightnessMilli));
    result.SetKeyInt64("scale", Cast<Int64>(value.scaleMilli));
    result.SetKeyInt64("x", Cast<Int64>(value.x));
    result.SetKeyInt64("y", Cast<Int64>(value.y));
    result.SetKeyBool("hidden", value.hidden);
    result.SetKeyBool("border_hidden", value.borderHidden);
    return result;
  }

  private func LoadSpecsFile(name: String, isBike: Bool) -> Void {
    let root: ref<JsonObject> = this.ReadObjectFile(name);
    if !IsDefined(root) { return; };
    let keys: array<String> = root.GetKeys();
    let i: Int32 = 0;
    while i < ArraySize(keys) {
      let row: ref<JsonObject> = root.GetKey(keys[i]) as JsonObject;
      if IsDefined(row) {
        let spec: ref<VMVehicleSpec> = this.ParseSpec(keys[i], row, isBike);
        if IsDefined(spec) { ArrayPush(this.specs, spec); };
      };
      i += 1;
    };
  }

  private func ParseSpec(label: String, row: ref<JsonObject>, isBike: Bool) -> ref<VMVehicleSpec> {
    let result: ref<VMVehicleSpec> = new VMVehicleSpec();
    result.label = label;
    result.isBike = isBike;
    result.l100Km = VMMath.ClampFloat(VMStorage.ReadFloat(row, "l100km", isBike ? 6.0 : 12.0), 0.1, 1000.0);
    result.tankL = VMMath.ClampFloat(VMStorage.ReadFloat(row, "tank_l", isBike ? 18.0 : 40.0), 0.1, 10000.0);
    result.oilOptMin = VMMath.ClampFloat(VMStorage.ReadFloat(row, "oil_opt_min", 80.0), -50.0, 300.0);
    result.oilOptMax = VMMath.ClampFloat(VMStorage.ReadFloat(row, "oil_opt_max", isBike ? 100.0 : 120.0), result.oilOptMin, 300.0);
    result.facts = this.ReadFactKeys(row.GetKey("vm_facts") as JsonObject, label);
    result.config3D = this.Read3DConfig(row.GetKey("vm3d") as JsonObject);
    return result;
  }

  private func ReadFactKeys(source: ref<JsonObject>, label: String) -> ref<VMFactKeys> {
    let result: ref<VMFactKeys> = this.MakeFactKeys(label);
    if !IsDefined(source) { return result; };
    result.initialized = VMStorage.ReadString(source, "initialized", result.initialized);
    result.meters = VMStorage.ReadString(source, "meters", result.meters);
    result.fuelPermille = VMStorage.ReadString(source, "fuel_permille", result.fuelPermille);
    result.oilDeciC = VMStorage.ReadString(source, "oil_deci_c", result.oilDeciC);
    result.stalled = VMStorage.ReadString(source, "stalled", result.stalled);
    result.limitOn = VMStorage.ReadString(source, "limit_on", result.limitOn);
    result.maintenanceDueM = VMStorage.ReadString(source, "maintenance_due_m", result.maintenanceDueM);
    return result;
  }

  private func MakeFactKeys(label: String) -> ref<VMFactKeys> {
    // Keep the exact legacy DJB2 naming contract. This is intentionally
    // derived instead of relying only on the imported config files: a mod
    // manager may remove those files during an upgrade, while the quest facts
    // themselves are still present in the save.
    let hash: Uint32 = 5381u;
    let i: Int32 = 0;
    while i < StrLen(label) {
      hash = hash * 33u + Cast<Uint32>(VMStorage.AsciiByte(StrMid(label, i, 1)));
      i += 1;
    };
    let prefix: String = "vmv_" + VMStorage.Hex8(hash);
    let result: ref<VMFactKeys> = new VMFactKeys();
    result.initialized = prefix + "_i";
    result.meters = prefix + "_m";
    result.fuelPermille = prefix + "_f";
    result.oilDeciC = prefix + "_o";
    result.stalled = prefix + "_s";
    result.limitOn = prefix + "_l";
    result.maintenanceDueM = prefix + "_d";
    return result;
  }

  public static func AsciiByte(character: String) -> Int32 {
    // TweakDB vehicle labels are ASCII. StrChar keeps this independent from
    // Codeware or any external hashing helper.
    let value: Int32 = 0;
    while value <= 127 {
      if Equals(character, StrChar(value)) { return value; };
      value += 1;
    };
    return 0;
  }

  private static func Hex8(value: Uint32) -> String {
    let remaining: Uint32 = value;
    let result: String = "";
    let i: Int32 = 0;
    while i < 8 {
      let digit: Int32 = Cast<Int32>(remaining % 16u);
      result = StrChar(digit < 10 ? digit + 48 : digit + 87) + result;
      remaining /= 16u;
      i += 1;
    };
    return result;
  }

  public func FindSpec(label: String) -> ref<VMVehicleSpec> {
    let i: Int32 = 0;
    while i < ArraySize(this.specs) {
      if Equals(this.specs[i].label, label) { return this.specs[i]; };
      i += 1;
    };
    return null;
  }

  public func EnsureSpec(label: String, isBike: Bool) -> ref<VMVehicleSpec> {
    let existing: ref<VMVehicleSpec> = this.FindSpec(label);
    if IsDefined(existing) { return existing; };
    let result: ref<VMVehicleSpec> = new VMVehicleSpec();
    let lower: String = StrLower(label);
    let isAV: Bool = StrContains(lower, "vehicle.av_")
      || StrContains(lower, ".av_")
      || StrContains(lower, "_dav");
    result.label = label;
    result.isBike = isBike;
    result.l100Km = isBike ? 6.0 : isAV ? 6.0 : 12.0;
    result.tankL = isBike ? 18.0 : isAV ? 120.0 : 40.0;
    result.oilOptMin = 80.0;
    result.oilOptMax = isBike ? 100.0 : 120.0;
    result.facts = this.MakeFactKeys(label);
    result.config3D = VM3DConfig.CreateDefault();
    ArrayPush(this.specs, result);
    this.SaveSpecs();
    return result;
  }

  public func SaveSpecs() -> Bool {
    let cars: ref<JsonObject> = new JsonObject();
    let bikes: ref<JsonObject> = new JsonObject();
    let i: Int32 = 0;
    while i < ArraySize(this.specs) {
      if this.specs[i].isBike {
        bikes.SetKey(this.specs[i].label, this.SpecToJson(this.specs[i]));
      } else {
        cars.SetKey(this.specs[i].label, this.SpecToJson(this.specs[i]));
      };
      i += 1;
    };
    let carsOK: Bool = this.WriteConfigJson("vm_config_cars.json", cars);
    let bikesOK: Bool = this.WriteConfigJson("vm_config_bikes.json", bikes);
    return carsOK && bikesOK;
  }

  private func SpecToJson(spec: ref<VMVehicleSpec>) -> ref<JsonObject> {
    let row: ref<JsonObject> = new JsonObject();
    row.SetKeyDouble("l100km", Cast<Double>(spec.l100Km));
    row.SetKeyDouble("tank_l", Cast<Double>(spec.tankL));
    row.SetKeyDouble("oil_opt_min", Cast<Double>(spec.oilOptMin));
    row.SetKeyDouble("oil_opt_max", Cast<Double>(spec.oilOptMax));
    let facts: ref<JsonObject> = new JsonObject();
    facts.SetKeyString("initialized", spec.facts.initialized);
    facts.SetKeyString("meters", spec.facts.meters);
    facts.SetKeyString("fuel_permille", spec.facts.fuelPermille);
    facts.SetKeyString("oil_deci_c", spec.facts.oilDeciC);
    facts.SetKeyString("stalled", spec.facts.stalled);
    facts.SetKeyString("limit_on", spec.facts.limitOn);
    facts.SetKeyString("maintenance_due_m", spec.facts.maintenanceDueM);
    row.SetKey("vm_facts", facts);
    row.SetKey("vm3d", this.Config3DToJson(spec.config3D));
    return row;
  }

  private func Read3DConfig(source: ref<JsonObject>) -> ref<VM3DConfig> {
    let result: ref<VM3DConfig> = VM3DConfig.CreateDefault();
    if !IsDefined(source) { return result; };
    result.fuelStyle = VMMath.ClampInt(VMStorage.ReadInt(source, "fuel_style", 0), 0, 5);
    result.fuelAltStyle = VMMath.ClampInt(VMStorage.ReadInt(source, "fuel_alt_style", 0), 0, 5);
    result.theme = VMMath.ClampInt(VMStorage.ReadInt(source, "theme", 0), 0, 9);
    result.fontIndex = VMMath.ClampInt(VMStorage.ReadInt(source, "font_index", 0), 0, 13);
    result.fontScaleMilli = VMMath.ClampInt(VMStorage.ReadInt(source, "font_scale_milli", 1000), 500, 2000);
    result.emissiveEvDeci = VMMath.ClampInt(VMStorage.ReadInt(source, "emissive_ev_deci", 60), 0, 120);
    result.hideFuel = VMStorage.ReadBool(source, "hide_fuel", false);
    result.hideOdo = VMStorage.ReadBool(source, "hide_odo", false);
    result.hideOdoFrame = VMStorage.ReadBool(source, "hide_odo_frame", false);
    result.hideFuelAlt = VMStorage.ReadBool(source, "hide_fuel_alt", false);
    result.hideOdoAlt = VMStorage.ReadBool(source, "hide_odo_alt", false);
    result.hideOdoAltFrame = VMStorage.ReadBool(source, "hide_odo_alt_frame", false);
    this.ReadPlacement(source.GetKey("fuel") as JsonObject, result.fuel);
    this.ReadPlacement(source.GetKey("odo") as JsonObject, result.odo);
    this.ReadPlacement(source.GetKey("fuel_alt") as JsonObject, result.fuelAlt);
    this.ReadPlacement(source.GetKey("odo_alt") as JsonObject, result.odoAlt);
    return result;
  }

  private func ReadPlacement(source: ref<JsonObject>, target: ref<VM3DPlacement>) -> Void {
    if !IsDefined(source) || !IsDefined(target) { return; };
    target.side = VMMath.ClampInt(VMStorage.ReadInt(source, "side", target.side), 0, 3);
    target.outCm = VMMath.ClampInt(VMStorage.ReadInt(source, "out_cm", target.outCm), -300, 300);
    target.yCm = VMMath.ClampInt(VMStorage.ReadInt(source, "y_cm", target.yCm), -300, 300);
    target.zCm = VMMath.ClampInt(VMStorage.ReadInt(source, "z_cm", target.zCm), -200, 300);
    target.rollDeg = VMMath.ClampInt(VMStorage.ReadInt(source, "roll_deg", target.rollDeg), -180, 180);
    target.pitchDeg = VMMath.ClampInt(VMStorage.ReadInt(source, "pitch_deg", target.pitchDeg), -180, 180);
    target.yawDeg = VMMath.ClampInt(VMStorage.ReadInt(source, "yaw_deg", target.yawDeg), -180, 180);
    target.scaleMilli = VMMath.ClampInt(VMStorage.ReadInt(source, "scale_milli", target.scaleMilli), 10, 2000);
  }

  public func Config3DToJson(value: ref<VM3DConfig>) -> ref<JsonObject> {
    let source: ref<VM3DConfig> = IsDefined(value) ? value : VM3DConfig.CreateDefault();
    let result: ref<JsonObject> = new JsonObject();
    result.SetKeyInt64("fuel_style", Cast<Int64>(source.fuelStyle));
    result.SetKeyInt64("fuel_alt_style", Cast<Int64>(source.fuelAltStyle));
    result.SetKeyInt64("theme", Cast<Int64>(source.theme));
    result.SetKeyInt64("font_index", Cast<Int64>(source.fontIndex));
    result.SetKeyInt64("font_scale_milli", Cast<Int64>(source.fontScaleMilli));
    result.SetKeyInt64("emissive_ev_deci", Cast<Int64>(source.emissiveEvDeci));
    result.SetKeyBool("hide_fuel", source.hideFuel);
    result.SetKeyBool("hide_odo", source.hideOdo);
    result.SetKeyBool("hide_odo_frame", source.hideOdoFrame);
    result.SetKeyBool("hide_fuel_alt", source.hideFuelAlt);
    result.SetKeyBool("hide_odo_alt", source.hideOdoAlt);
    result.SetKeyBool("hide_odo_alt_frame", source.hideOdoAltFrame);
    result.SetKey("fuel", this.PlacementToJson(source.fuel));
    result.SetKey("odo", this.PlacementToJson(source.odo));
    result.SetKey("fuel_alt", this.PlacementToJson(source.fuelAlt));
    result.SetKey("odo_alt", this.PlacementToJson(source.odoAlt));
    return result;
  }

  private func PlacementToJson(value: ref<VM3DPlacement>) -> ref<JsonObject> {
    let result: ref<JsonObject> = new JsonObject();
    result.SetKeyInt64("side", Cast<Int64>(value.side));
    result.SetKeyInt64("out_cm", Cast<Int64>(value.outCm));
    result.SetKeyInt64("y_cm", Cast<Int64>(value.yCm));
    result.SetKeyInt64("z_cm", Cast<Int64>(value.zCm));
    result.SetKeyInt64("roll_deg", Cast<Int64>(value.rollDeg));
    result.SetKeyInt64("pitch_deg", Cast<Int64>(value.pitchDeg));
    result.SetKeyInt64("yaw_deg", Cast<Int64>(value.yawDeg));
    result.SetKeyInt64("scale_milli", Cast<Int64>(value.scaleMilli));
    return result;
  }

  private func LoadGasPoints() -> array<ref<VMGasPoint>> {
    let result: array<ref<VMGasPoint>>;
    let root: ref<JsonArray> = this.ReadArrayFile("vm_gas_locations.json");
    if !IsDefined(root) { return result; };
    let i: Uint32 = 0u;
    while i < root.GetSize() {
      let row: ref<JsonObject> = root.GetItem(i) as JsonObject;
      if IsDefined(row) && row.HasKey("x") && row.HasKey("y") {
        let point: ref<VMGasPoint> = new VMGasPoint();
        point.position.X = VMStorage.ReadFloat(row, "x", 0.0);
        point.position.Y = VMStorage.ReadFloat(row, "y", 0.0);
        point.position.Z = VMStorage.ReadFloat(row, "z", 0.0);
        point.position.W = 1.0;
        point.radius = VMMath.ClampFloat(VMStorage.ReadFloat(row, "radius", 5.0), 0.1, 100.0);
        ArrayPush(result, point);
      };
      i += 1u;
    };
    return result;
  }

  private func LoadRepairPoints() -> array<ref<VMRepairPoint>> {
    let result: array<ref<VMRepairPoint>>;
    let root: ref<JsonArray> = this.ReadArrayFile("vm_repair_stations.json");
    if !IsDefined(root) { return result; };
    let i: Uint32 = 0u;
    while i < root.GetSize() {
      let row: ref<JsonObject> = root.GetItem(i) as JsonObject;
      if IsDefined(row) && row.HasKey("x") && row.HasKey("y") {
        let point: ref<VMRepairPoint> = new VMRepairPoint();
        point.position.X = VMStorage.ReadFloat(row, "x", 0.0);
        point.position.Y = VMStorage.ReadFloat(row, "y", 0.0);
        point.position.Z = VMStorage.ReadFloat(row, "z", 0.0);
        point.position.W = 1.0;
        point.radius = VMMath.ClampFloat(VMStorage.ReadFloat(row, "radius", 3.0), 0.1, 100.0);
        point.price = Max(0, VMStorage.ReadInt(row, "price", 500));
        point.hasRotation = row.HasKey("rot_roll")
          && row.HasKey("rot_pitch")
          && row.HasKey("rot_yaw");
        point.roll = VMStorage.ReadFloat(row, "rot_roll", 0.0);
        point.pitch = VMStorage.ReadFloat(row, "rot_pitch", 0.0);
        point.yaw = VMStorage.ReadFloat(row, "rot_yaw", 0.0);
        let fxIndex: Int32 = 1;
        while fxIndex <= 10 {
          let fxPath: String = VMStorage.ReadString(row, "fxeffect" + IntToString(fxIndex), "");
          ArrayPush(point.fx, fxPath);
          fxIndex += 1;
        };
        ArrayPush(result, point);
      };
      i += 1u;
    };
    return result;
  }

  private func SaveGasPoints() -> Bool {
    let root: ref<JsonArray> = new JsonArray();
    let i: Int32 = 0;
    while i < ArraySize(this.gasPoints) {
      let point: ref<VMGasPoint> = this.gasPoints[i];
      let row: ref<JsonObject> = new JsonObject();
      row.SetKeyDouble("x", Cast<Double>(point.position.X));
      row.SetKeyDouble("y", Cast<Double>(point.position.Y));
      row.SetKeyDouble("z", Cast<Double>(point.position.Z));
      row.SetKeyDouble("radius", Cast<Double>(point.radius));
      root.AddItem(row);
      i += 1;
    };
    return this.WriteJson("vm_gas_locations.json", root);
  }

  private func SaveRepairPoints() -> Bool {
    let root: ref<JsonArray> = new JsonArray();
    let i: Int32 = 0;
    while i < ArraySize(this.repairPoints) {
      let point: ref<VMRepairPoint> = this.repairPoints[i];
      let row: ref<JsonObject> = new JsonObject();
      row.SetKeyDouble("x", Cast<Double>(point.position.X));
      row.SetKeyDouble("y", Cast<Double>(point.position.Y));
      row.SetKeyDouble("z", Cast<Double>(point.position.Z));
      row.SetKeyDouble("radius", Cast<Double>(point.radius));
      row.SetKeyInt64("price", Cast<Int64>(point.price));
      let fxIndex: Int32 = 0;
      while fxIndex < 10 {
        row.SetKeyString(
          "fxeffect" + IntToString(fxIndex + 1),
          fxIndex < ArraySize(point.fx) ? point.fx[fxIndex] : ""
        );
        fxIndex += 1;
      };
      if point.hasRotation {
        row.SetKeyDouble("rot_roll", Cast<Double>(point.roll));
        row.SetKeyDouble("rot_pitch", Cast<Double>(point.pitch));
        row.SetKeyDouble("rot_yaw", Cast<Double>(point.yaw));
      };
      root.AddItem(row);
      i += 1;
    };
    return this.WriteJson("vm_repair_stations.json", root);
  }

  public func GetGasPointCount() -> Int32 {
    return ArraySize(this.gasPoints);
  }

  public func GetRepairPointCount() -> Int32 {
    return ArraySize(this.repairPoints);
  }

  public func AddGasPoint(position: Vector4, radius: Float) -> Bool {
    let point: ref<VMGasPoint> = new VMGasPoint();
    point.position = position;
    point.position.W = 1.0;
    point.radius = VMMath.ClampFloat(radius, 0.1, 100.0);
    ArrayPush(this.gasPoints, point);
    if this.SaveGasPoints() { return true; };
    ArrayErase(this.gasPoints, ArraySize(this.gasPoints) - 1);
    return false;
  }

  public func RemoveGasPoint(index: Int32) -> Bool {
    if index < 0 || index >= ArraySize(this.gasPoints) { return false; };
    let removed: ref<VMGasPoint> = this.gasPoints[index];
    ArrayErase(this.gasPoints, index);
    if this.SaveGasPoints() { return true; };
    ArrayInsert(this.gasPoints, index, removed);
    return false;
  }

  public func AddRepairPoint(
    position: Vector4,
    radius: Float,
    price: Int32,
    rotation: EulerAngles,
    fx: array<String>
  ) -> Bool {
    let point: ref<VMRepairPoint> = new VMRepairPoint();
    point.position = position;
    point.position.W = 1.0;
    point.radius = VMMath.ClampFloat(radius, 0.1, 100.0);
    point.price = Max(0, price);
    point.hasRotation = true;
    point.roll = rotation.Roll;
    point.pitch = rotation.Pitch;
    point.yaw = rotation.Yaw;
    let i: Int32 = 0;
    while i < 10 {
      ArrayPush(point.fx, i < ArraySize(fx) ? fx[i] : "");
      i += 1;
    };
    ArrayPush(this.repairPoints, point);
    if this.SaveRepairPoints() { return true; };
    ArrayErase(this.repairPoints, ArraySize(this.repairPoints) - 1);
    return false;
  }

  public func RemoveRepairPoint(index: Int32) -> Bool {
    if index < 0 || index >= ArraySize(this.repairPoints) { return false; };
    let removed: ref<VMRepairPoint> = this.repairPoints[index];
    ArrayErase(this.repairPoints, index);
    if this.SaveRepairPoints() { return true; };
    ArrayInsert(this.repairPoints, index, removed);
    return false;
  }

  private func LoadIgnoreList() -> array<String> {
    let result: array<String>;
    let root: ref<JsonArray> = this.ReadArrayFile("vm_vehicle_ignore.json");
    if !IsDefined(root) { return result; };
    let i: Uint32 = 0u;
    while i < root.GetSize() {
      let value: ref<JsonVariant> = root.GetItem(i);
      if IsDefined(value) && value.IsString() { ArrayPush(result, value.GetString()); };
      i += 1u;
    };
    return result;
  }

  private func MergeIgnoreSeeds() -> Void {
    let root: ref<JsonArray> = this.ReadArrayFile("vm_ignore_seeds.json");
    if !IsDefined(root) { return; };
    let changed: Bool = false;
    let i: Uint32 = 0u;
    while i < root.GetSize() {
      let value: ref<JsonVariant> = root.GetItem(i);
      if IsDefined(value) && value.IsString() && !this.IsIgnored(value.GetString()) {
        ArrayPush(this.ignoredLabels, value.GetString());
        changed = true;
      };
      i += 1u;
    };
    if changed { this.SaveIgnoreList(); };
  }

  public func IsIgnored(label: String) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.ignoredLabels) {
      if Equals(this.ignoredLabels[i], label) { return true; };
      i += 1;
    };
    return false;
  }

  public func SetIgnored(label: String, ignored: Bool) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.ignoredLabels) {
      if Equals(this.ignoredLabels[i], label) {
        if ignored { return true; };
        ArrayErase(this.ignoredLabels, i);
        return this.SaveIgnoreList();
      };
      i += 1;
    };
    if !ignored { return true; };
    ArrayPush(this.ignoredLabels, label);
    return this.SaveIgnoreList();
  }

  private func SaveIgnoreList() -> Bool {
    let root: ref<JsonArray> = new JsonArray();
    let i: Int32 = 0;
    while i < ArraySize(this.ignoredLabels) {
      root.AddItemString(this.ignoredLabels[i]);
      i += 1;
    };
    return this.WriteJson("vm_vehicle_ignore.json", root);
  }

  private static func SafePresetName(name: String) -> String {
    let result: String = StrLower(name);
    result = StrReplaceAll(result, " ", "_");
    result = StrReplaceAll(result, ".", "_");
    result = StrReplaceAll(result, "/", "_");
    result = StrReplaceAll(result, "\\", "_");
    result = StrReplaceAll(result, ":", "_");
    result = StrReplaceAll(result, "|", "_");
    result = StrReplaceAll(result, "<", "_");
    result = StrReplaceAll(result, ">", "_");
    result = StrReplaceAll(result, "\"", "_");
    result = StrReplaceAll(result, "?", "_");
    result = StrReplaceAll(result, "*", "_");
    return result;
  }

  private static func PresetPath(safeName: String) -> String {
    return "vm3d_preset_" + safeName + ".json";
  }

  private static func IndexedPresetPath(safeName: String) -> String {
    return "3DPresets/" + safeName + ".json";
  }

  private func ReadPresetIndex() -> ref<JsonObject> {
    let index: ref<JsonObject> = this.ReadObjectFile("vm_3d_preset_index.json");
    if IsDefined(index) { return index; };
    return new JsonObject();
  }

  private static func PresetConfig(root: ref<JsonObject>) -> ref<JsonObject> {
    if !IsDefined(root) { return null; };
    let wrapped: ref<JsonObject> = root.GetKey("vm3d") as JsonObject;
    return IsDefined(wrapped) ? wrapped : root;
  }

  private static func IsPresetJson(root: ref<JsonObject>) -> Bool {
    let config: ref<JsonObject> = VMStorage.PresetConfig(root);
    if !IsDefined(config) { return false; };
    let hasPlacement: Bool = IsDefined(config.GetKey("fuel") as JsonObject)
      || IsDefined(config.GetKey("odo") as JsonObject)
      || IsDefined(config.GetKey("fuel_alt") as JsonObject)
      || IsDefined(config.GetKey("odo_alt") as JsonObject);
    let hasStyle: Bool = config.HasKey("fuel_style")
      || config.HasKey("fuel_alt_style")
      || config.HasKey("font_index")
      || config.HasKey("font_scale_milli")
      || config.HasKey("theme")
      || config.HasKey("_preset");
    return hasPlacement && hasStyle;
  }

  private static func PresetNameFromFilename(filename: String) -> String {
    let result: String = filename;
    if StrEndsWith(StrLower(result), ".json") {
      result = StrLeft(result, StrLen(result) - 5);
    };
    if StrBeginsWith(StrLower(result), "vm3d_preset_") {
      result = StrAfterFirst(result, "vm3d_preset_");
    };
    return result;
  }

  private func CachePreset(root: ref<JsonObject>, path: String, fallbackName: String) -> Void {
    if !VMStorage.IsPresetJson(root) { return; };
    let displayName: String = VMStorage.ReadString(root, "name", fallbackName);
    let safe: String = VMStorage.SafePresetName(displayName);
    if StrLen(safe) == 0 { return; };
    let i: Int32 = 0;
    while i < ArraySize(this.presetNames) {
      if Equals(VMStorage.SafePresetName(this.presetNames[i]), safe) { return; };
      i += 1;
    };
    ArrayPush(this.presetNames, displayName);
    ArrayPush(this.presetPaths, path);
  }

  private func MigrateIndexedPresets() -> Void {
    if !IsDefined(this.storage)
      || NotEquals(this.storage.IsFile("vm_3d_preset_index.json"), FileSystemStatus.True) {
      return;
    };
    let index: ref<JsonObject> = this.ReadPresetIndex();
    let keys: array<String> = index.GetKeys();
    let changed: Bool = false;
    let i: Int32 = 0;
    while i < ArraySize(keys) {
      let oldPath: String = VMStorage.IndexedPresetPath(keys[i]);
      let source: ref<JsonObject> = this.ReadObjectFile(oldPath);
      if !VMStorage.IsPresetJson(source) {
        index.RemoveKey(keys[i]);
        changed = true;
      } else {
        let newPath: String = VMStorage.PresetPath(keys[i]);
        let target: ref<JsonObject> = this.ReadObjectFile(newPath);
        if VMStorage.IsPresetJson(target) || this.WriteJson(newPath, source) {
          // Only remove the old indexed file after a valid root copy exists.
          let verified: ref<JsonObject> = this.ReadObjectFile(newPath);
          if VMStorage.IsPresetJson(verified) {
            this.storage.DeleteFile(oldPath);
            index.RemoveKey(keys[i]);
            changed = true;
          };
        };
      };
      i += 1;
    };
    if changed {
      let remaining: array<String> = index.GetKeys();
      if ArraySize(remaining) == 0 {
        this.storage.DeleteFile("vm_3d_preset_index.json");
      } else {
        this.WriteJson("vm_3d_preset_index.json", index);
      };
    };
  }

  private func CacheRemainingIndexedPresets() -> Void {
    let index: ref<JsonObject> = this.ReadPresetIndex();
    let keys: array<String> = index.GetKeys();
    let i: Int32 = 0;
    while i < ArraySize(keys) {
      let path: String = VMStorage.IndexedPresetPath(keys[i]);
      this.CachePreset(
        this.ReadObjectFile(path),
        path,
        VMStorage.ReadString(index, keys[i], keys[i])
      );
      i += 1;
    };
  }

  public func RefreshPresets() -> Int32 {
    ArrayClear(this.presetNames);
    ArrayClear(this.presetPaths);
    this.presetsScanned = true;
    if !IsDefined(this.storage) { return 0; };

    this.MigrateIndexedPresets();
    let files: array<ref<File>> = this.storage.GetFiles();
    let i: Int32 = 0;
    while i < ArraySize(files) {
      if IsDefined(files[i]) && Equals(StrLower(files[i].GetExtension()), ".json") {
        let filename: String = files[i].GetFilename();
        this.CachePreset(
          files[i].ReadAsJson() as JsonObject,
          filename,
          VMStorage.PresetNameFromFilename(filename)
        );
      };
      i += 1;
    };
    // Preserve access if copying an indexed subfolder preset to the root failed.
    this.CacheRemainingIndexedPresets();
    return ArraySize(this.presetNames);
  }

  private func FindPresetPath(name: String) -> String {
    if !this.presetsScanned { this.RefreshPresets(); };
    let safe: String = VMStorage.SafePresetName(name);
    let i: Int32 = 0;
    while i < ArraySize(this.presetNames) {
      if Equals(VMStorage.SafePresetName(this.presetNames[i]), safe) {
        return this.presetPaths[i];
      };
      i += 1;
    };
    return "";
  }

  public func SavePreset(name: String, config: ref<VM3DConfig>) -> Bool {
    let safe: String = VMStorage.SafePresetName(name);
    if StrLen(safe) == 0 { return false; };
    let root: ref<JsonObject> = new JsonObject();
    root.SetKeyString("name", name);
    root.SetKey("vm3d", this.Config3DToJson(config));
    if !this.WriteJson(VMStorage.PresetPath(safe), root) { return false; };
    this.RefreshPresets();
    return true;
  }

  public func LoadPreset(name: String) -> ref<VM3DConfig> {
    let path: String = this.FindPresetPath(name);
    if StrLen(path) == 0 { return null; };
    let root: ref<JsonObject> = this.ReadObjectFile(path);
    return VMStorage.IsPresetJson(root)
      ? this.Read3DConfig(VMStorage.PresetConfig(root))
      : null;
  }

  public func DeletePreset(name: String) -> Bool {
    if !IsDefined(this.storage) { return false; };
    let path: String = this.FindPresetPath(name);
    if StrLen(path) == 0
      || NotEquals(this.storage.DeleteFile(path), FileSystemStatus.True) {
      return false;
    };
    this.RefreshPresets();
    return true;
  }

  public func GetPresetNames() -> String {
    if !this.presetsScanned { this.RefreshPresets(); };
    let result: String = "";
    let i: Int32 = 0;
    while i < ArraySize(this.presetNames) {
      result += StrLen(result) > 0 ? "|" + this.presetNames[i] : this.presetNames[i];
      i += 1;
    };
    return result;
  }

  public func NeedsLegacyImport() -> Bool {
    return IsDefined(this.storage)
      && NotEquals(this.storage.IsFile("redscript_migration.json"), FileSystemStatus.True);
  }

  public func NeedsLegacyPresetImport() -> Bool {
    if !IsDefined(this.storage) { return false; };
    let marker: ref<JsonObject> = this.ReadObjectFile("redscript_migration.json");
    return !IsDefined(marker)
      || VMStorage.ReadInt(marker, "preset_root_schema", 0) < 1;
  }

  public func ImportLegacyJson(name: String, raw: String) -> Bool {
    if StrLen(raw) == 0 { return false; };
    let isPreset: Bool = StrBeginsWith(name, "preset:");
    if isPreset {
      if !this.NeedsLegacyPresetImport() { return false; };
    } else {
      if !this.NeedsLegacyImport() { return false; };
    };
    let json: ref<JsonVariant> = ParseJson(raw);
    if !IsDefined(json) { return false; };
    let target: String = "";
    if Equals(name, "vm_config_cars.json")
      || Equals(name, "vm_config_bikes.json")
      || Equals(name, "vm_settings.json")
      || Equals(name, "vm_vehicle_ignore.json")
      || Equals(name, "vm_gas_locations.json")
      || Equals(name, "vm_repair_stations.json")
      || Equals(name, "vm_ignore_seeds.json") {
      target = name;
    } else if StrBeginsWith(name, "preset:") {
      let displayName: String = StrAfterFirst(name, "preset:");
      let source: ref<JsonObject> = json as JsonObject;
      if !VMStorage.IsPresetJson(source) { return false; };
      target = VMStorage.PresetPath(VMStorage.SafePresetName(displayName));
      let existing: ref<JsonObject> = this.ReadObjectFile(target);
      if VMStorage.IsPresetJson(existing) { return true; };
      let wrapper: ref<JsonObject> = new JsonObject();
      wrapper.SetKeyString("name", displayName);
      wrapper.SetKey("vm3d", VMStorage.PresetConfig(source));
      return this.WriteJson(target, wrapper);
    };
    return StrLen(target) > 0 && this.WriteJson(target, json);
  }

  public func FinishLegacyImport() -> Bool {
    if !IsDefined(this.storage) { return false; };
    let marker: ref<JsonObject> = this.ReadObjectFile("redscript_migration.json");
    if !IsDefined(marker) { marker = new JsonObject(); };
    marker.SetKeyInt64("schema", 1l);
    marker.SetKeyString("runtime", "REDscript");
    let result: Bool = this.WriteJson("redscript_migration.json", marker);
    if result { this.Reload(); };
    return result;
  }

  public func FinishLegacyPresetImport() -> Bool {
    if !IsDefined(this.storage) { return false; };
    let marker: ref<JsonObject> = this.ReadObjectFile("redscript_migration.json");
    if !IsDefined(marker) { marker = new JsonObject(); };
    marker.SetKeyInt64("schema", 1l);
    marker.SetKeyString("runtime", "REDscript");
    marker.SetKeyInt64("preset_root_schema", 1l);
    let result: Bool = this.WriteJson("redscript_migration.json", marker);
    if result { this.RefreshPresets(); };
    return result;
  }
}
