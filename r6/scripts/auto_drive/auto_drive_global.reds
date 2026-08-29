// base\gameplay\ai\behaviors\vehicle\default_vehicle.behavior.
public class AIVehicleDriveToPointCommand extends AIVehicleDriveToPointAutonomousCommand {
    public let secureTimeOut: Float;
    public let useTraffic: Bool;
    public let speedInTraffic: Float;
    public let forceGreenLights: Bool;
    public let portals: ref<vehiclePortalsList>;
    public let trafficTryNeighborsForStart: Bool;
    public let trafficTryNeighborsForEnd: Bool;
}

@addMethod(AIDriveCommandsDelegate)
public final func DoStartDriveToPoint(context: ScriptExecutionContext) -> Bool {
    let cmd = this.m_driveToPointAutonomousCommand as AIVehicleDriveToPointCommand;
    this.targetPosition = cmd.targetPosition;

    this.secureTimeOut = cmd.secureTimeOut;
    this.useTraffic = cmd.useTraffic;
    this.speedInTraffic = cmd.speedInTraffic;
    this.forceGreenLights = cmd.forceGreenLights;
    this.portals = cmd.portals;
    this.trafficTryNeighborsForStart = cmd.trafficTryNeighborsForStart;
    this.trafficTryNeighborsForEnd = cmd.trafficTryNeighborsForEnd;

    return true;
}

@addMethod(AIDriveCommandsDelegate)
public final func DoUpdateDriveToPoint(context: ScriptExecutionContext) -> Bool {
    if !IsDefined(this.m_driveToPointAutonomousCommand) {
        return false;
    };
    return true;
}

@addMethod(AIDriveCommandsDelegate)
public final static func DoEndDriveToPoint(context: ScriptExecutionContext) -> Bool {
    return true;
}

@addMethod(AIDriveCommandsDelegate)
public final func DoStopDriveToPoint(context: ScriptExecutionContext) -> Bool {
    if IsDefined(this.m_driveToPointAutonomousCommand) {
        this.m_driveToPointAutonomousCommand = null;
    };
    return true;
}
