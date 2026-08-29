enum JobSelectionType{
  Random =0,
  DistanceRandom = 1,
  Distance = 2,
}

public class JobRandomizerSettings {
  @runtimeProperty("ModSettings.mod", "Job Randomizer 2.0")
  @runtimeProperty("ModSettings.displayName", "NCPD Scanner Missions")
  @runtimeProperty("ModSettings.displayValues.Random",  "Area/Full")
  @runtimeProperty("ModSettings.displayValues.DistanceRandom",  "Area/Large")
  @runtimeProperty("ModSettings.displayValues.Distance",  "Area/Near")
  @runtimeProperty("ModSettings.description", "The general map coverage of the NCPD tracker")
  private let ncpdSelectionType : JobSelectionType = JobSelectionType.Random;
  public func GetNCPDSelectionType()->JobSelectionType
  {
    return this.ncpdSelectionType;
  }
  @runtimeProperty("ModSettings.mod", "Job Randomizer 2.0")
  @runtimeProperty("ModSettings.displayName", "Gig Missions")
  @runtimeProperty("ModSettings.displayValues.Random",  "Area/Full")
  @runtimeProperty("ModSettings.displayValues.DistanceRandom",  "Area/Large")
  @runtimeProperty("ModSettings.displayValues.Distance",  "Area/Near")
  @runtimeProperty("ModSettings.description", "The general map coverage of the Gig tracker")
  private let gigSelectionType : JobSelectionType = JobSelectionType.Random;
    public func GetGigSelectionType()->JobSelectionType
  {
    return this.gigSelectionType;
  }
  @runtimeProperty("ModSettings.mod", "Job Randomizer 2.0")
  @runtimeProperty("ModSettings.displayName", "Controller Support")
  @runtimeProperty("ModSettings.description", "Enables controller support and changes the button input from press to hold")
  private let controllerSupport :Bool = false;
  public func HasControllerSupport()->Bool = this.controllerSupport;

}

