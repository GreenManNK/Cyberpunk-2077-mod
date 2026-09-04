module VehicleMileage.API

import VehicleMileage.Runtime.VMRuntimeSystem

// Public API v1 for other REDscript mods.
//
// Example:
//   import VehicleMileage.API.VehicleMileageAPI
//
//   let meters: Int32 = VehicleMileageAPI.GetMeters();
//   let drained: Float = VehicleMileageAPI.DrainFuel(2.5);
//   let added: Float = VehicleMileageAPI.Refuel(10.0);
//
// DrainFuel() and Refuel() use liters and return the amount actually changed.
// They target the currently mounted, non-ignored vehicle. They return 0.0
// while the fuel system is disabled, no supported vehicle is mounted, or the
// requested change cannot be applied. Refuel() does not charge money, consume
// items, or alter gas-station stock; the calling mod owns those side effects.

public abstract class VehicleMileageAPI {
  public static func GetVersion() -> Int32 {
    return 1;
  }

  public static func GetSystem() -> ref<VMRuntimeSystem> {
    return VMRuntimeSystem.Get();
  }

  public static func IsAvailable() -> Bool {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) && system.IsReady();
  }

  public static func HasMountedVehicle() -> Bool {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) && system.HasMountedVehicle();
  }

  public static func GetMountedVehicleLabel() -> String {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.GetMountedLabel() : "";
  }

  public static func IsFuelSystemEnabled() -> Bool {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) && system.IsFuelSystemEnabled();
  }

  public static func CanModifyFuel() -> Bool {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) && system.CanModifyFuel();
  }

  public static func GetMeters() -> Int32 {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.GetCurrentMeters() : 0;
  }

  public static func GetFuelPercent() -> Float {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.GetCurrentFuelPercent() : 0.0;
  }

  public static func GetFuelLiters() -> Float {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.GetCurrentFuelLiters() : 0.0;
  }

  public static func GetTankCapacityLiters() -> Float {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.GetCurrentTankCapacityLiters() : 0.0;
  }

  public static func DrainFuel(liters: Float) -> Float {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.DrainFuel(liters) : 0.0;
  }

  public static func Refuel(liters: Float) -> Float {
    let system: ref<VMRuntimeSystem> = VehicleMileageAPI.GetSystem();
    return IsDefined(system) ? system.Refuel(liters) : 0.0;
  }
}
