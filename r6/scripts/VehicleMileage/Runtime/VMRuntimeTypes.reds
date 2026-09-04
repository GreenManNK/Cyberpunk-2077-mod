module VehicleMileage.Runtime

public abstract class VMMath {
  public static func ClampInt(value: Int32, minimum: Int32, maximum: Int32) -> Int32 {
    if value < minimum { return minimum; };
    if value > maximum { return maximum; };
    return value;
  }

  public static func ClampFloat(value: Float, minimum: Float, maximum: Float) -> Float {
    if value < minimum { return minimum; };
    if value > maximum { return maximum; };
    return value;
  }

  public static func RoundInt(value: Float) -> Int32 {
    return value >= 0.0 ? FloorF(value + 0.5) : CeilF(value - 0.5);
  }
}

public class VMFactKeys extends IScriptable {
  public let initialized: String;
  public let meters: String;
  public let fuelPermille: String;
  public let oilDeciC: String;
  public let stalled: String;
  public let limitOn: String;
  public let maintenanceDueM: String;
}

public class VM3DPlacement extends IScriptable {
  public let side: Int32;
  public let outCm: Int32;
  public let yCm: Int32;
  public let zCm: Int32;
  public let rollDeg: Int32;
  public let pitchDeg: Int32;
  public let yawDeg: Int32;
  public let scaleMilli: Int32;

  public static func Create(alternate: Bool) -> ref<VM3DPlacement> {
    let value: ref<VM3DPlacement> = new VM3DPlacement();
    value.side = alternate ? 1 : 0;
    value.scaleMilli = 600;
    return value;
  }
}

public class VM3DConfig extends IScriptable {
  public let fuelStyle: Int32;
  public let fuelAltStyle: Int32;
  public let theme: Int32;
  public let fontIndex: Int32;
  public let fontScaleMilli: Int32;
  public let emissiveEvDeci: Int32;

  public let hideFuel: Bool;
  public let hideOdo: Bool;
  public let hideOdoFrame: Bool;
  public let hideFuelAlt: Bool;
  public let hideOdoAlt: Bool;
  public let hideOdoAltFrame: Bool;

  public let fuel: ref<VM3DPlacement>;
  public let odo: ref<VM3DPlacement>;
  public let fuelAlt: ref<VM3DPlacement>;
  public let odoAlt: ref<VM3DPlacement>;

  public static func CreateDefault() -> ref<VM3DConfig> {
    let value: ref<VM3DConfig> = new VM3DConfig();
    value.fontScaleMilli = 1000;
    value.emissiveEvDeci = 60;
    value.fuel = VM3DPlacement.Create(false);
    value.odo = VM3DPlacement.Create(false);
    value.fuelAlt = VM3DPlacement.Create(true);
    value.odoAlt = VM3DPlacement.Create(true);
    return value;
  }
}

public class VMVehicleSpec extends IScriptable {
  public let label: String;
  public let isBike: Bool;
  public let l100Km: Float;
  public let tankL: Float;
  public let oilOptMin: Float;
  public let oilOptMax: Float;
  public let facts: ref<VMFactKeys>;
  public let config3D: ref<VM3DConfig>;
}

public class VMVehicleState extends IScriptable {
  public let spec: ref<VMVehicleSpec>;
  public let label: String;
  public let owned: Bool;
  public let ignored: Bool;
  public let meters: Float;
  public let fuelPct: Float;
  public let oilTempC: Float;
  public let stalled: Bool;
  public let limitOn: Bool;
  public let maintenanceDueM: Int32;
  public let hasLastPosition: Bool;
  public let lastPosition: Vector4;
  public let lastSeenAt: Float;
}

public class VMGasPoint extends IScriptable {
  public let position: Vector4;
  public let radius: Float;
  public let stationIndex: Int32;
}

public class VMGasStation extends IScriptable {
  public let position: Vector4;
  public let pointCount: Int32;
  public let capacityL: Int32;
  public let urbanity: Float;
  public let targetFill: Float;
  public let demandFraction: Float;
  public let deliveryInterval: Int32;
  public let shipmentFraction: Float;
  public let maxFact: String;
  public let availableFact: String;
  public let exactAvailableL: Float;
  public let mirroredFactL: Int32;
}

public class VMRepairPoint extends IScriptable {
  public let position: Vector4;
  public let radius: Float;
  public let price: Int32;
  public let hasRotation: Bool;
  public let roll: Float;
  public let pitch: Float;
  public let yaw: Float;
  public let fx: array<String>;
}

public class VMWorldObjectSettings extends IScriptable {
  public let theme: Int32;
  public let fontIndex: Int32;
  public let fontSize: Int32;
  public let brightnessMilli: Int32;
  public let scaleMilli: Int32;
  public let x: Int32;
  public let y: Int32;
  public let hidden: Bool;
  public let borderHidden: Bool;

  public static func CreateDefault(index: Int32) -> ref<VMWorldObjectSettings> {
    let value: ref<VMWorldObjectSettings> = new VMWorldObjectSettings();
    value.fontIndex = 6;
    value.fontSize = index == 0 ? 28 : 32;
    value.brightnessMilli = 1000;
    value.scaleMilli = 1000;
    value.hidden = index > 0;
    if index == 1 { value.x = -360; };
    if index == 3 { value.x = 360; };
    return value;
  }
}

public class VMSettings extends IScriptable {
  public let priceEpl: Float;
  public let dynamicPrice: Bool;
  public let fuelEnabled: Bool;
  public let maintenanceEnabled: Bool;
  public let maintenanceMinKm: Int32;
  public let maintenanceMaxKm: Int32;
  public let gasPinsShowInWorld: Bool;
  public let gasPinsVehicleOnly: Bool;
  public let repairPriceAdjustPct: Int32;
  public let repairAutomatic: Bool;
  public let stolenStallAtZero: Bool;

  public let widgetMode: String;
  public let theme: Int32;
  public let hudX: Float;
  public let hudY: Float;
  public let priceDx: Float;
  public let priceDy: Float;
  public let fuelGaugeEnabled: Bool;
  public let fuelGaugeTempEnabled: Bool;
  public let fuelGaugeDx: Float;
  public let fuelGaugeDy: Float;
  public let fuelGaugeScale: Float;
  public let leaderboardEnabled: Bool;
  public let leaderboardDx: Float;
  public let leaderboardDy: Float;
  public let leaderboardScale: Float;
  public let autoHideEnabled: Bool;
  public let autoHideSeconds: Float;
  public let autoHideFuelPct: Int32;

  public let worldLeaderboard: ref<VMWorldObjectSettings>;
  public let worldAux1: ref<VMWorldObjectSettings>;
  public let worldAux2: ref<VMWorldObjectSettings>;
  public let worldAux3: ref<VMWorldObjectSettings>;

  public static func CreateDefault() -> ref<VMSettings> {
    let value: ref<VMSettings> = new VMSettings();
    value.priceEpl = 50.0;
    value.dynamicPrice = true;
    value.fuelEnabled = true;
    value.maintenanceEnabled = true;
    value.maintenanceMinKm = 20;
    value.maintenanceMaxKm = 30;
    value.gasPinsShowInWorld = true;
    value.gasPinsVehicleOnly = false;
    value.stolenStallAtZero = true;
    value.widgetMode = "fuelgauge";
    value.hudX = 280.0 / 3840.0;
    value.hudY = 443.0 / 2160.0;
    value.priceDy = 350.0;
    value.fuelGaugeEnabled = true;
    value.fuelGaugeTempEnabled = true;
    value.fuelGaugeDx = -1510.0;
    value.fuelGaugeDy = 275.0;
    value.fuelGaugeScale = 330.0;
    value.leaderboardEnabled = true;
    value.leaderboardDx = -850.0;
    value.leaderboardDy = 800.0;
    value.leaderboardScale = 480.0;
    value.autoHideSeconds = 20.0;
    value.autoHideFuelPct = 25;
    value.worldLeaderboard = VMWorldObjectSettings.CreateDefault(0);
    value.worldAux1 = VMWorldObjectSettings.CreateDefault(1);
    value.worldAux2 = VMWorldObjectSettings.CreateDefault(2);
    value.worldAux3 = VMWorldObjectSettings.CreateDefault(3);
    return value;
  }
}
