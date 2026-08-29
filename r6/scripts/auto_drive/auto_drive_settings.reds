module AutoDriveMod
import AutoDriveMod.AutoDriveSettingsForDev

enum AICommandType {
    Normal = 0,
    Traffic = 1
}

public class AutoDriveSettings {
    // ***** To Translators ******
    // If possible, please use ArchiveXL to localize this mod instead of editing this file directly.
    // https://wiki.redmodding.org/cyberpunk-2077-modding/for-mod-creators/modding-guides/everything-else/how-to-translate-a-mod

    /*** General ***/
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Honk the horn on start/stop")
    // @runtimeProperty("ModSettings.description", "Honk the horn on start/stop")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-HonkOnStartStop-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-HonkOnStartStop-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-GeneralCategory-label")
    @runtimeProperty("ModSettings.category.order", "0")
    public let honkTheHorn: Bool = true;

    // Auto Save on Start Auto Drive
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Auto Save on Start Auto Drive")
    // @runtimeProperty("ModSettings.description", "Auto Save on Start Auto Drive")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-AutoSaveOnStartAutoDrive-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-AutoSaveOnStartAutoDrive-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-GeneralCategory-label")
    @runtimeProperty("ModSettings.category.order", "0")
    public let autoSaveOnStartAutoDrive: Bool = false;

    // Ticks timeout
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Ticks timeout")
    // @runtimeProperty("ModSettings.description", "Allowable time for one auto drive operation")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-TicksTimeout-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-TicksTimeout-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-GeneralCategory-label")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "10.0")
    @runtimeProperty("ModSettings.max", "3600.0")
    public let ticksTimeout: Float = 1200.0;

    // Restrict Vehicle
    // TweakXL is required
    @if(ModuleExists("TweakXL"))
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Restrict Vehicles")
    // @runtimeProperty("ModSettings.description", "Restrict to vehicles with CanAutoDrive tag (Players Delamain and Rayfield only). see auto_drive.yaml")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-RestrictVehicles-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-RestrictVehicles-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-GeneralCategory-label")
    @runtimeProperty("ModSettings.category.order", "0")
    public let restrictVehicles: Bool = false;

    @if(!ModuleExists("TweakXL"))
    public let restrictVehicles: Bool = false;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "AI Command Type")
    // @runtimeProperty("ModSettings.description", "AI Command Type")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-AICommandType-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-AICommandType-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-GeneralCategory-label")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayValues.Normal", "Normal AI")
    @runtimeProperty("ModSettings.displayValues.Traffic", "Traffic AI")
    public let aiCommandType: AICommandType = AICommandType.Normal;
    private let aiCommandTypeName: CName = n"aiCommandType";

    /*** Normal AI ***/
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.description", "Clear Traffic On Path")
    // @runtimeProperty("ModSettings.displayName", "Clear Traffic On Path")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-ClearTrafficOnPath-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-ClearTrafficOnPath-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    public let clearTrafficOnPath: Bool = true;
    private let clearTrafficOnPathName: CName = n"clearTrafficOnPath";

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Auto Speed Control")
    // @runtimeProperty("ModSettings.description", "Automatically controls speed based on vehicle spec.")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-AutoSpeedControl-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-AutoSpeedControl-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    public let autoSpeedControl: Bool = true;
    private let autoSpeedControlName: CName = n"autoSpeedControl";

    // Set invisible OnRegister func. SetValue OnVarUpdated func.
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    public let autoSpeedControlInvert: Bool = false;
    private let autoSpeedControlInvertName: CName = n"autoSpeedControlInvert";

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Max Cruise Speed Ratio")
    // @runtimeProperty("ModSettings.description", "Ratio of maximum speed to maximum vehicle speed.")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-AutoSpeedControlMaxSpeedRatio-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-AutoSpeedControlMaxSpeedRatio-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControl")
    public let autoSpeedControlMaxSpeedRatio: Float = 0.7;

    // Starting
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Starting Distance")
    // @runtimeProperty("ModSettings.description", "Starting distance")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StartingDistance-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StartingDistance-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "100.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let startingDistance: Float = 15.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Starting Max Speed")
    // @runtimeProperty("ModSettings.description", "Max speed within starting distance from starting point")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StartingMaxSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StartingMaxSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "200.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let startingMaxSpeed: Float = 10.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Starting Min Speed")
    // @runtimeProperty("ModSettings.description", "Min speed within starting distance from starting point")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StartingMinSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StartingMinSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "100.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let startingMinSpeed: Float = 3.0;

    // Cruising
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Cruising Max Speed")
    // @runtimeProperty("ModSettings.description", "Max speed other than start/stop")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-CruisingMaxSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-CruisingMaxSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "200.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let cruisingMaxSpeed: Float = 30.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Cruising Min Speed")
    // @runtimeProperty("ModSettings.description", "Min speed other than start/stop")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-CruisingMinSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-CruisingMinSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "100.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let cruisingMinSpeed: Float = 10.0;

    // Stopping
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Stopping Distance")
    // @runtimeProperty("ModSettings.description", "Stopping distance")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StoppingDistance-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StoppingDistance-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "100.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let stoppingDistance: Float = 50.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Stopping Max Speed")
    // @runtimeProperty("ModSettings.description", "Max speed within stopping distance from stopping point")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StoppingMaxSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StoppingMaxSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "200.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let stoppingMaxSpeed: Float = 8.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Stopping Min Speed")
    // @runtimeProperty("ModSettings.description", "Min speed within stopping distance from stopping point")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StoppingMinSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StoppingMinSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "100.0")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let stoppingMinSpeed: Float = 3.0;

    // Brake
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Base Brake Time")
    // @runtimeProperty("ModSettings.description", "Base Brake Time when stopped 'braking time(sec) = [base] + ([speedFactor]*speed/10 * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-BrakeTimeBase-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-BrakeTimeBase-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let forceBrakesBaseTime: Float = 0.5;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Speed Factor for Brake Time")
    // @runtimeProperty("ModSettings.description", "Speed Factor for Brake Time when stopped 'braking time(sec) = [base] + ([speedFactor]*speed/10 * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-BrakeTimeSpeedFactor-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-BrakeTimeSpeedFactor-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let forceBrakesSpeedFactor: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Mass Factor for Brake Time")
    // @runtimeProperty("ModSettings.description", "Mass Factor for Brake Time when stopped 'braking time(sec) = [base] + ([speedFactor]*speed/10 * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-BrakeTimeMassFactor-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-BrakeTimeMassFactor-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let forceBrakesMassFactor: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Braking Torque Factor for Brake Time")
    // @runtimeProperty("ModSettings.description", "Braking Torque Factor for Brake Time when stopped 'braking time(sec) = [base] + ([speedFactor]*speed/10 * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-BrakeTimeBrakingTorqueFactor-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-BrakeTimeBrakingTorqueFactor-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAICategory-label")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "autoSpeedControlInvert")
    public let forceBrakesBrakingTorqueFactor: Float = 1.0;

    /*** Normal AI Sync Speed ***/
    // Sync speed.
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Sync speed with vehicle in front")
    // @runtimeProperty("ModSettings.description", "Sync speed with vehicle in front. If 'Clear Traffic On Path' is ON, overtake slowly. ")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    public let syncMaxSpeed: Bool = false;
    private let syncMaxSpeedName: CName = n"syncMaxSpeed";

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Base gap between cars in cruising")
    // @runtimeProperty("ModSettings.description", "Base gap between cars in cruising. 'gap = [base] + ([speedFactor]*speed * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedBaseGap-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedBaseGap-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "50")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedVehicleInFrontBaseDistance: Float = 20.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Speed factor of additional gap between cars in cruising")
    // @runtimeProperty("ModSettings.description", "Speed factor of additional gap between cars in cruising. 'gap = [base] + ([speedFactor]*speed * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedVehicleInFrontDistanceSpeedFactor: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Mass factor of additional gap between cars in cruising")
    // @runtimeProperty("ModSettings.description", "Mass factor of additional gap between cars in cruising. 'gap = [base] + ([speedFactor]*speed * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForMass-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForMass-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedVehicleInFrontDistanceMassFactor: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Braking torque factor of additional gap between cars in cruising")
    // @runtimeProperty("ModSettings.description", "Braking torque factor of additional gap between cars in cruising. 'gap = [base] + ([speedFactor]*speed * [massFactor]*mass/1000 * [brakingTorqueFactor]*400/brakingTorque)'")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForBrake-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedAddGapForBrake-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedVehicleInFrontDistanceBrakingTorqueFactor: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Gap between cars to stop approaching")
    // @runtimeProperty("ModSettings.description", "Gap between cars to stop approaching")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedGapForStopApproaching-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedGapForStopApproaching-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "50.0")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedDistanceToStopApproaching: Float = 15.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Approaching speed")
    // @runtimeProperty("ModSettings.description", "Approaching speed")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SyncSpeedApproachingSpeed-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SyncSpeedApproachingSpeed-desc")
    // @runtimeProperty("ModSettings.category", "Normal AI - Sync Speed")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-NormalAISyncSpeedCategory-label")
    @runtimeProperty("ModSettings.category.order", "11")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "20.0")
    @runtimeProperty("ModSettings.dependency", "syncMaxSpeed")
    public let syncMaxSpeedApproachSpeed: Float = 5.0;

    /*** Traffic AI ***/
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Traffic Try Neighbors For Start")
    // @runtimeProperty("ModSettings.description", "Traffic Try Neighbors For Start")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-TrafficTryNeighborsForStart-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-TrafficTryNeighborsForStart-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-TrafficAICategory-label")
    @runtimeProperty("ModSettings.category.order", "20")
    public let trafficTryNeighborsForStart: Bool = false;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Traffic Try Neighbors For End")
    // @runtimeProperty("ModSettings.description", "Traffic Try Neighbors For End")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-TrafficTryNeighborsForEnd-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-TrafficTryNeighborsForEnd-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-TrafficAICategory-label")
    @runtimeProperty("ModSettings.category.order", "20")
    public let trafficTryNeighborsForEnd: Bool = false;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Stopping Distance")
    // @runtimeProperty("ModSettings.description", "Stopping Distance")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-StoppingDistance-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-StoppingDistance-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-TrafficAICategory-label")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "50.0")
    public let stoppingDistanceForTrafficAI: Float = 8.0;

    /*** UI ***/
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Show Toggle Auto Drive InputHint")
    // @runtimeProperty("ModSettings.description", "Show Toggle Auto Drive InputHint")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-ShowToggleAutoDriveInputHint-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-ShowToggleAutoDriveInputHint-desc")
    // @runtimeProperty("ModSettings.category", "General")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-UICategory-label")
    @runtimeProperty("ModSettings.category.order", "30")
    public let showToggleAutoDriveInputHint: Bool = true;

    /*** Keybinds ***/
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Toggle Auto Drive")
    // @runtimeProperty("ModSettings.description", "Toggle Auto Drive")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-ToggleAutoDriveKeybind-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-ToggleAutoDriveKeybind-desc")
    // @runtimeProperty("ModSettings.category", "Keybinds")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-KeybindsCategory-label")
    @runtimeProperty("ModSettings.category.order", "40")
    public let AutoDrive_ToggleVehAutoDrive_Key: EInputKey  = EInputKey.IK_V;

    /*** Cheat ***/
    // No Damage during Auto Driving
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "No Damage during Auto Driving")
    // @runtimeProperty("ModSettings.description", "No Damage during Auto Driving")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-CheatNoDamage-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-CheatNoDamage-desc")
    // @runtimeProperty("ModSettings.category", "Auto Drive Cheat")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-CheatCategory-label")
    @runtimeProperty("ModSettings.category.order", "100")
    public let noDamage: Bool = false;

    // Lock HeatLevel during Auto Driving
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Lock HeatLevel during Auto Driving")
    // @runtimeProperty("ModSettings.description", "Lock HeatLevel during Auto Driving. Not wanted")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-CheatLockHeatLevel-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-CheatLockHeatLevel-desc")
    // @runtimeProperty("ModSettings.category", "Auto Drive Cheat")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-CheatCategory-label")
    @runtimeProperty("ModSettings.category.order", "100")
    public let lockHeatLevel: Bool = false;

    // Disable Cheats in Combat.
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Disable Cheats in Combat")
    // @runtimeProperty("ModSettings.description", "Disable Cheats in Combat")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-DisableCheatsInCombat-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-DisableCheatsInCombat-desc")
    // @runtimeProperty("ModSettings.category", "Auto Drive Cheat")
    @runtimeProperty("ModSettings.category", "UI-AutoDriveMod-Settings-CheatCategory-label")
    @runtimeProperty("ModSettings.category.order", "100")
    public let disableCheatsInCombat: Bool = false;

    public static func GetAutoDriveHintLabel(on: Bool) -> String {
        // return on ? "Stop Auto Drive" : "Start Auto Drive";    
        return GetLocalizedText(s"Gameplay-AutoDriveMod-AutoDriveHint-\(on ? "on" : "off")");
    }

    public static func GetNoDestinationSetText() -> String {
        // return "No destination set";
        return GetLocalizedText("Gameplay-AutoDriveMod-NoDestinationSet");
    }

    // There is no localized text below this point

    // separate into auto_drive_settings_for_dev.reds
    public let forDev: ref<AutoDriveSettingsForDev>;

    public func UpdateSyncMaxSpeed() -> Void {
        AutoDriveSettings.UpdateModSettingsBoolVar(this.syncMaxSpeedName, this.syncMaxSpeed);
    }

    public func UpdateClearTrafficOnPath() -> Void {
        AutoDriveSettings.UpdateModSettingsBoolVar(this.clearTrafficOnPathName, this.clearTrafficOnPath);
    }

    public func UpdateAICommandType() -> Void {
        AutoDriveSettings.UpdateModSettingsEnumVar(this.aiCommandTypeName, EnumInt(this.aiCommandType));
    }

    public func OnRegistered() -> Void {
        let var = AutoDriveSettings.GetModConfigVar(this.autoSpeedControlInvertName);
        if IsDefined(var) {
            var.SetVisible(false);
        }
    }

    public func Initialize() -> Void {
        this.forDev = new AutoDriveSettingsForDev();
        AutoDriveSettings.RegisterSettings(this);
        AutoDriveSettings.RegisterSettings(this.forDev);
        this.OnRegistered();
    }

    public func Uninitialize() -> Void {
        AutoDriveSettings.UnregisterSettings(this.forDev);
        AutoDriveSettings.UnregisterSettings(this);
    }

    @if(ModuleExists("ModSettingsModule"))
    public func OnModSettingsChange() -> Void {
        let var = AutoDriveSettings.GetModConfigVar(this.autoSpeedControlName) as ModConfigVarBool;
        let invertVar = AutoDriveSettings.GetModConfigVar(this.autoSpeedControlInvertName) as ModConfigVarBool;
        if IsDefined(var) && IsDefined(invertVar) && Equals(var.GetValue(), invertVar.GetValue()) {
            invertVar.Toggle();
        }
    }

    @if(ModuleExists("ModSettingsModule"))
    private static func RegisterSettings(obj: ref<IScriptable>) -> Void {
        ModSettings.RegisterListenerToClass(obj);
        ModSettings.RegisterListenerToModifications(obj);
    }

    @if(!ModuleExists("ModSettingsModule"))
    private static func RegisterSettings(obj: ref<IScriptable>) -> Void {}

    @if(ModuleExists("ModSettingsModule"))
    private static func UnregisterSettings(obj: ref<IScriptable>) -> Void {
        ModSettings.UnregisterListenerToClass(obj);
        ModSettings.UnregisterListenerToModifications(obj);
    }

    @if(!ModuleExists("ModSettingsModule"))
    private static func UnregisterSettings(obj: ref<IScriptable>) -> Void {}

    @if(ModuleExists("ModSettingsModule"))
    private static func UpdateModSettingsBoolVar(name: CName, value: Bool) -> Void {
        let var = AutoDriveSettings.GetModConfigVar(name);
        let visible = var.IsVisible();
        if IsDefined(var) {
            (var as ModConfigVarBool).SetValue(value);
            ModSettings.AcceptChanges();
        }
    }

    @if(!ModuleExists("ModSettingsModule"))
    private static func UpdateModSettingsBoolVar(name: CName, value: Bool) -> Void {}

    @if(ModuleExists("ModSettingsModule"))
    private static func UpdateModSettingsEnumVar(name: CName, index: Int32) -> Void {
        let var = AutoDriveSettings.GetModConfigVar(name);
        if IsDefined(var) {
            (var as ModConfigVarEnum).SetIndex(index);
            ModSettings.AcceptChanges();
        }
    }

    @if(!ModuleExists("ModSettingsModule"))
    private static func UpdateModSettingsEnumVar(name: CName, index: Int32) -> Void {}

    @if(ModuleExists("ModSettingsModule"))
    private static func GetModConfigVar(name: CName) -> ref<ConfigVar> {
        for cate in ModSettings.GetCategories(n"Auto Drive") {
            for var in ModSettings.GetVars(n"Auto Drive", cate) {
                if Equals(name, var.GetName()) {
                    return var;
                }
            }
        }
        for var in ModSettings.GetVars(n"Auto Drive", n"None") {
            if Equals(name, var.GetName()) {
                return var;
            }
        }
        return null;
    }
    @if(!ModuleExists("ModSettingsModule"))
    private static func GetModConfigVar(name: CName) -> ref<ConfigVar> { return null; }
}
