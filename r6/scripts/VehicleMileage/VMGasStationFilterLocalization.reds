module VehicleMileage.MapFilterLocalization

import Codeware.Localization.*

public class VehicleMileageMapFilterEnglish extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("VehicleMileage-GasStations-FilterName", "Gas Stations");
  }
}

public class VehicleMileageMapFilterLocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    return new VehicleMileageMapFilterEnglish();
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}
