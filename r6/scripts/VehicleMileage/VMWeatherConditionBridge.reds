module VehicleMileage.WeatherConditionBridge

@if(ModuleExists("Exposure.System"))
import Exposure.Config.ExposureConfig
@if(ModuleExists("Exposure.System"))
import Exposure.District.ExposureDistrict
@if(ModuleExists("Exposure.System"))
import Exposure.Settings.WeatherConditionSettings

public abstract class VMWeatherConditionBridge {

  @if(ModuleExists("Exposure.System"))
  public static func GetStatus(game: GameInstance) -> Int32 {
    let settings: ref<WeatherConditionSettings> =
      WeatherConditionSettings.Get(game);

    if !IsDefined(settings) {
      return 3;
    };

    return settings.modEnabled ? 2 : 1;
  }

  @if(!ModuleExists("Exposure.System"))
  public static func GetStatus(game: GameInstance) -> Int32 {
    return 0;
  }

  @if(ModuleExists("Exposure.System"))
  public static func GetTemperatureC(game: GameInstance) -> Int32 {
    let settings: ref<WeatherConditionSettings> =
      WeatherConditionSettings.Get(game);
    let weatherSystem: ref<WeatherSystem> =
      GameInstance.GetWeatherSystem(game);
    let timeSystem: ref<TimeSystem> =
      GameInstance.GetTimeSystem(game);

    if !IsDefined(settings)
      || !settings.modEnabled
      || !IsDefined(weatherSystem)
      || !IsDefined(timeSystem) {
      return -999;
    };

    let weatherState = weatherSystem.GetWeatherState();
    if !IsDefined(weatherState) {
      return -999;
    };

    let weather: String =
      ToString(weatherState.name);
    let hour: Int32 =
      GameTime.Hours(timeSystem.GetGameTime());
    let effectiveTemp: Int32 =
      ExposureConfig.WeatherContributionClamped(
        weather,
        hour
      )
      + ExposureConfig.TimeContribution(hour)
      + ExposureDistrict.GetDistrictModifier(game, hour);
    let hotCap: Int32 =
      ExposureDistrict.IsInBadlands(game) ? 6 : 5;

    if effectiveTemp > hotCap {
      effectiveTemp = hotCap;
    };

    return ExposureConfig.TemperatureInCelsius(
      effectiveTemp
    );
  }

  @if(!ModuleExists("Exposure.System"))
  public static func GetTemperatureC(game: GameInstance) -> Int32 {
    return -999;
  }
}

@addMethod(PlayerPuppet)
public func VM_GetWeatherConditionTemperatureC() -> Int32 {
  return VMWeatherConditionBridge.GetTemperatureC(
    GetGameInstance()
  );
}

@addMethod(PlayerPuppet)
public func VM_GetWeatherConditionStatus() -> Int32 {
  return VMWeatherConditionBridge.GetStatus(
    GetGameInstance()
  );
}
