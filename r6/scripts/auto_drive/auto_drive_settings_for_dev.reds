module AutoDriveMod

public class AutoDriveSettingsForDev {
    // ***** To Translators ******
    // Please do not translate this file.
    // Changes frequently and  Identity is required for explanatory purposes

    // For dev.
    // Workarounds.
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "Workaround for the issue of moving on its own after getting off the car")
    @runtimeProperty("ModSettings.description", "Workaround for the issue of moving on its own after getting off the car. but vehicle stops when jump out of the car")
    @runtimeProperty("ModSettings.category", "[For Dev] Workaround")
    @runtimeProperty("ModSettings.category.order", "1000")
    public let enableWorkaroundForIssueOfMovingOnItsOwn: Bool = true;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "Workaround for stolen car issue.")
    @runtimeProperty("ModSettings.description", "Workaround for stolen car issue.")
    @runtimeProperty("ModSettings.category", "[For Dev] Workaround")
    @runtimeProperty("ModSettings.category.order", "1000")
    public let enableWorkaroundForIssueOfStolenCar: Bool = true;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "TrafficAI crash workaround command restart distance.")
    @runtimeProperty("ModSettings.description", "TrafficAI crash workaround command restart distance.")
    @runtimeProperty("ModSettings.category", "[For Dev] Workaround")
    @runtimeProperty("ModSettings.category.order", "1000")
    @runtimeProperty("ModSettings.step", "1000.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "20000.0")
    public let trafficAICrashWorkaroundCommandRestartDistance: Float = 0.0;

    // Normal AI
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "useKinematic")
    @runtimeProperty("ModSettings.description", "useKinematic")
    @runtimeProperty("ModSettings.category", "[For Dev] Normal AI")
    @runtimeProperty("ModSettings.category.order", "1010")
    public let useKinematic: Bool = true;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "driveDownTheRoadIndefinitely")
    @runtimeProperty("ModSettings.description", "driveDownTheRoadIndefinitely")
    @runtimeProperty("ModSettings.category", "[For Dev] Normal AI")
    @runtimeProperty("ModSettings.category.order", "1010")
    public let driveDownTheRoadIndefinitely: Bool = false;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "minimumDistanceToTarget")
    @runtimeProperty("ModSettings.description", "minimumDistanceToTarget")
    @runtimeProperty("ModSettings.category", "[For Dev] Normal AI")
    @runtimeProperty("ModSettings.category.order", "1010")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "100.0")
    public let minimumDistanceToTarget: Float = 0.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    @runtimeProperty("ModSettings.displayName", "highlightSyncedVehicle")
    @runtimeProperty("ModSettings.description", "highlightSyncedVehicle")
    @runtimeProperty("ModSettings.category", "[For Dev] Normal AI")
    @runtimeProperty("ModSettings.category.order", "1010")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "100.0")
    public let highlightSyncedVehicle: Bool = false;

    // Traffic AI
    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Secure Timeout")
    // @runtimeProperty("ModSettings.description", "Secure Timeout")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SecureTimeout-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SecureTimeout-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "[For Dev] TrafficAI")
    @runtimeProperty("ModSettings.category.order", "1020")
    @runtimeProperty("ModSettings.step", "10.0")
    @runtimeProperty("ModSettings.min", "10.0")
    @runtimeProperty("ModSettings.max", "3600.0")
    public let secureTimeOut: Float = 1200.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Use Traffic")
    // @runtimeProperty("ModSettings.description", "Use Traffic")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-UseTraffic-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-UseTraffic-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "[For Dev] TrafficAI")
    @runtimeProperty("ModSettings.category.order", "1020")
    public let useTraffic: Bool = true;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Speed In Traffic")
    // @runtimeProperty("ModSettings.description", "Speed In Traffic")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-SpeedInTraffic-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-SpeedInTraffic-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "[For Dev] TrafficAI")
    @runtimeProperty("ModSettings.category.order", "1020")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "200.0")
    public let speedInTraffic: Float = 60.0;

    @runtimeProperty("ModSettings.mod", "Auto Drive")
    // @runtimeProperty("ModSettings.displayName", "Force Green Lights")
    // @runtimeProperty("ModSettings.description", "Force Green Lights")
    @runtimeProperty("ModSettings.displayName", "UI-AutoDriveMod-Settings-ForceGreenLights-label")
    @runtimeProperty("ModSettings.description", "UI-AutoDriveMod-Settings-ForceGreenLights-desc")
    // @runtimeProperty("ModSettings.category", "Traffic AI")
    @runtimeProperty("ModSettings.category", "[For Dev] TrafficAI")
    @runtimeProperty("ModSettings.category.order", "1020")
    public let forceGreenLights: Bool = true;

}
