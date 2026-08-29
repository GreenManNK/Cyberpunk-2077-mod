module AutoDriveMod
import AutoDriveMod.*

// func L(const text: script_ref<String>) -> Void{ FTLog(text); }

static func WithinRange(position: Vector4, range: Float, target: Vector4) -> Bool {
    return Vector4.Distance2D(position, target) < range;
}

struct SpeedRange {
    public let max: Float;
    public let min: Float;
    public static func New(max: Float, min: Float) -> SpeedRange {
        let speed: SpeedRange;
        speed.max = max;
        speed.min = min;
        return speed;
    }
}

struct SpeedLimitArea {
    public let id: String;
    public let position: Vector4;
    public let range: Float;
    public let yaw: Float;
    public let yawDot: Float = 1.1;
    public let speed: SpeedRange;
    public static func New(id: String, position: Vector4, range: Float) -> SpeedLimitArea {
        let area: SpeedLimitArea;
        area.id = id;
        area.position = position;
        area.range = range;
        area.speed = SpeedRange.New(5.0, 2.0);
        return area;
    }
    public static func New(id: String, position: Vector4, range: Float, maxSpeed: Float, minSpeed: Float) -> SpeedLimitArea {
        let area = SpeedLimitArea.New(id, position, range);
        area.speed = SpeedRange.New(maxSpeed, minSpeed);
        return area;
    }
    public static func New(id: String, position: Vector4, range: Float, yaw: Float, yawDot: Float, maxSpeed: Float, minSpeed: Float) -> SpeedLimitArea {
        let area = SpeedLimitArea.New(id, position, range, maxSpeed, minSpeed);
        area.yaw = yaw;
        area.yawDot = yawDot;
        return area;
    }
    public static func WithinRange(self: SpeedLimitArea, target: Vector4, yaw:Float) -> Bool {
        if self.yawDot < 1.0 {
            return WithinRange(self.position, self.range, target) && EulerAngles.Dot(SpeedLimitArea.Yaw(self.yaw), SpeedLimitArea.Yaw(yaw)) > self.yawDot;
        } else {
            return WithinRange(self.position, self.range, target);
        }
    }
    public static func WithinRange(self: SpeedLimitArea, target: wref<GameObject>) -> Bool {
        return SpeedLimitArea.WithinRange(self, target.GetWorldPosition(), Quaternion.ToEulerAngles(target.GetWorldOrientation()).Yaw);
    }
    private static func Yaw(yaw: Float) -> EulerAngles {
        let a:EulerAngles;
        a.Yaw = yaw;
        return a;
    }
}

public abstract class AutoDriveSpeed {
    protected let m_component: ref<AutoDriveComponent>;
    protected let m_destination: Vector4;
    protected let m_startPoint: Vector4;

    protected func GetComponent() -> ref<AutoDriveComponent> {
        return this.m_component;
    }
    protected func GetSystem() -> ref<AutoDriveSystem> {
        return this.GetComponent().GetSystem();
    }
    protected func GetSettings() -> ref<AutoDriveSettings> {
        return this.GetComponent().GetSettings();
    }
    protected func GetVehicle() -> ref<VehicleObject> {
        return this.GetComponent().GetVehicle();
    }

    public func Init(component: ref<AutoDriveComponent>) -> ref<AutoDriveSpeed> {
        this.m_component = component;
        this.m_destination = component.GetDestination();
        this.m_startPoint = component.GetVehicle().GetWorldPosition();
        return this;
    }
    // 循環参照になってしまうので、できれば AutoDriveComponent でなくパラメータクラスを用意して、それで受け取りたい.
    public func Uninit() -> Void {
        this.m_component = null;
    }

    public func GetSpeed() -> SpeedRange;
    public func Match() -> Bool;
}

public class StartingSpeed extends AutoDriveSpeed {
    public func GetSpeed() -> SpeedRange {
        return this.GetComponent().GetStartingSpeedRange();
    }
    public func Match() -> Bool {
        return WithinRange(this.m_startPoint, this.GetComponent().GetStartingDistance(), this.GetVehicle().GetWorldPosition());
    }
}

public class StoppingSpeed extends AutoDriveSpeed {
    public func GetSpeed() -> SpeedRange {
        return this.GetComponent().GetStoppingSpeedRange();
    }
    public func Match() -> Bool {
        return WithinRange(this.m_destination, this.GetComponent().GetStoppingDistance(), this.GetVehicle().GetWorldPosition());
    }
}

public class SpeedControlAreaSpeed extends AutoDriveSpeed {
    public func GetSpeed() -> SpeedRange {
        return this.matchedArea.speed;
    }
    private let matchedArea: SpeedLimitArea;
    public func Match() -> Bool {
        return this.GetSystem().CheckSpeedLimitAreaForNormalAI(this.matchedArea);
    }
}

public class CruisingSpeed extends AutoDriveSpeed {
    public func GetSpeed() -> SpeedRange {
        return this.GetComponent().GetCruisingSpeedRange();
    }
    public func Match() -> Bool {
        return true;
    }
}

public abstract class SpeedSelector {
    public func Select() -> SpeedRange;
    public func Uninit() -> Void {}
}

public class SimpleSpeedSelector extends SpeedSelector {
    private let m_speed: SpeedRange;
    public func Init(speed: SpeedRange) -> ref<SimpleSpeedSelector> {
        this.m_speed = speed;
        return this;
    }
    public func Select() -> SpeedRange {
        return this.m_speed;
    }
}

public class NormalSpeedSelector extends SpeedSelector {
    private let speeds: array<ref<AutoDriveSpeed>>;
    private let defaultSpeed: SpeedRange;
    public func Init(component: ref<AutoDriveComponent>) -> ref<NormalSpeedSelector> {
        ArrayPush(this.speeds, new StartingSpeed().Init(component));
        ArrayPush(this.speeds, new StoppingSpeed().Init(component));
        ArrayPush(this.speeds, new SpeedControlAreaSpeed().Init(component));
        ArrayPush(this.speeds, new CruisingSpeed().Init(component));
        this.defaultSpeed = component.GetCruisingSpeedRange();
        return this;
    }
    public func Select() -> SpeedRange {
        for speed in this.speeds {
            if speed.Match() {
                return speed.GetSpeed();
            }
        }
        return this.defaultSpeed;
    }
    public func Uninit() -> Void {
        super.Uninit();
        for spd in this.speeds {
            spd.Uninit();
        }
        this.speeds = [];
    }
}

public class SyncSpeed extends AutoDriveSpeed {
    private let speedSelector: ref<SpeedSelector>;
    public func Init(component: ref<AutoDriveComponent>, speedSelector: ref<SpeedSelector>) -> ref<SyncSpeed> {
        super.Init(component);
        this.speedSelector = speedSelector;
        this.m_prevTransform = Transform.Create(this.GetVehicle().GetWorldPosition(), this.GetVehicle().GetWorldOrientation());
        return this;
    }
    public func Uninit() -> Void {
        super.Uninit();
        if IsDefined(this.speedSelector) {
            this.speedSelector.Uninit();
            this.speedSelector = null;
        }
    }

    protected func GetPlayer() -> ref<PlayerPuppet> {
        return this.GetComponent().GetPlayer();
    }

    public func GetSpeed() -> SpeedRange {
        if !this.GetSettings().syncMaxSpeed {
            return this.speedSelector.Select();
        }

        let wheelSetup = this.GetVehicle().GetRecord().VehDriveModelData().WheelSetup();
        let brakingTorque = (wheelSetup.FrontPreset().MaxBrakingTorque() + wheelSetup.BackPreset().MaxBrakingTorque()) / 2.0;
        let speedFactor = this.GetVehicle().GetCurrentSpeed() * this.GetSettings().syncMaxSpeedVehicleInFrontDistanceSpeedFactor;
        let massFactor = MaxF(this.GetVehicle().GetTotalMass() / 1000.0 * this.GetSettings().syncMaxSpeedVehicleInFrontDistanceMassFactor, 1.0);
        let brakingFactor = this.GetSettings().syncMaxSpeedVehicleInFrontDistanceBrakingTorqueFactor;
        if brakingTorque > 0.0 {
            brakingFactor = brakingFactor * ClampF(400.0 / brakingTorque, 0.70, 2.0);
        } else {
            // おそらく二輪車、ブレーキ性能低いので、1.5くらいにしておく.
            brakingFactor = 1.5;
        }

        let range = this.GetSettings().syncMaxSpeedVehicleInFrontBaseDistance + (speedFactor * massFactor * brakingFactor);
        let vehicles = this.GetVehiclesInRange(range);
        let speed = this.speedSelector.Select();
        let maxSpeed = speed.max;
        for veh in vehicles {
            let syncSpeed = maxSpeed;
            if this.CalcSyncSpeed(veh, range, syncSpeed) {
                maxSpeed = MinF(maxSpeed, syncSpeed);
            }
        }
        speed.max = ClampF(maxSpeed, 0.0, speed.max);
        speed.min = ClampF(speed.min, 0.0, speed.max);
        return speed;
    }

    public func Match() -> Bool {
        return true;
    }

    private func GetVehiclesInRange(range: Float) -> [ref<VehicleObject>] {
        return this.GetPlayer().GetAroundVehicles(range + 10.0); // 大きめに指定しないと、なぜか拾わない.
    }

    private func CalcSyncSpeed(vehicle: ref<VehicleObject>, range: Float, out speed: Float) -> Bool {
        let pp = this.GetVehicle().GetWorldPosition();
        let vp = vehicle.GetWorldPosition();
        let localPos = this.GetLocalPoint(vehicle);
        let distance = Vector4.Distance(vehicle.GetWorldPosition(), this.GetVehicle().GetWorldPosition());
        let inRange = distance < range;

        if vehicle.IsPlayerMounted()
        || !SyncSpeed.InTraffic(vehicle)
        || localPos.Y < 0.0
        || (AbsF(pp.Z - vp.Z) > 8.0 && AbsF(localPos.Z) > 3.0)
        || !inRange {
            return false;
        }

        let distance = Vector4.Distance(vehicle.GetWorldPosition(), this.GetVehicle().GetWorldPosition());
        let angle = SyncSpeed.AngleDotXY(Transform.GetForward(this.GetAdjustedTransform(this.GetVehicle())), vehicle.GetWorldPosition() - this.GetVehicle().GetWorldPosition());
        let turning = SyncSpeed.AngleDotXY(this.GetVehicle().GetLinearVelocity(), this.GetVehicle().GetWorldOrientation().GetRight());

        let collided = this.VelocityCollisionTest2D(vehicle, range);
        if collided {
            let vehicleForwardVelocity = Vector4.Dot(this.GetVehicle().GetWorldOrientation().GetForward(), vehicle.GetLinearVelocity());
            if vehicleForwardVelocity < -10.0 {
                // 多分対向車なので無視.
                if this.GetSettings().forDev.highlightSyncedVehicle {
                    vehicle.Highlight_AD(this.GetPlayer(), true, EFocusForcedHighlightType.QUEST, EFocusOutlineType.QUEST);
                }
                return false;
            } else {
                // 前方方向の速度に同期. コマンドの入れ直しが発生しないように近い値は揃える.
                speed = ClampF(SyncSpeed.Floor(vehicleForwardVelocity, 0.5) - 0.5, this.GetSettings().syncMaxSpeedApproachSpeed, speed);
            }

            if distance < this.GetSettings().syncMaxSpeedDistanceToStopApproaching && !this.GetSettings().clearTrafficOnPath {
                // 停止距離まで近づいて、同じ車線か相手が動いている場合は止める.
                if this.IsInSameLane(vehicle)
                || vehicle.GetCurrentSpeed() > 1.0 {
                    speed = 0.0;
                }
            }

            if this.GetSettings().forDev.highlightSyncedVehicle {
                vehicle.Highlight_AD(this.GetPlayer(), true, EFocusForcedHighlightType.FRIENDLY, EFocusOutlineType.FRIENDLY);
            }
            return true;
        }

        if this.GetVehicle().GetCurrentSpeed() > this.GetSettings().syncMaxSpeedApproachSpeed && AbsF(turning) > 0.1 && distance < 20.0 && angle > 0.70 {
            // 旋回中に近くに居たら徐行.
            if this.GetSettings().forDev.highlightSyncedVehicle {
                vehicle.Highlight_AD(this.GetPlayer(), true, EFocusForcedHighlightType.HOSTILE, EFocusOutlineType.HOSTILE);
            }
            speed = this.GetSettings().syncMaxSpeedApproachSpeed;
            return true;
        }
        return false;
    }

    private static func ZeroW(vec: Vector4) -> Vector4 {
        return new Vector4(vec.X, vec.Y, 0.0, vec.W);
    }

    private static func Floor(value: Float, unit: Float) -> Float {
        return Cast<Float>(FloorF(value / unit)) * unit;
    }

    private static func AngleDotXY(vec1: Vector4, vec2: Vector4) -> Float {
        return EulerAngles.Dot(Vector4.ToRotation(SyncSpeed.ZeroW(vec1)), Vector4.ToRotation(SyncSpeed.ZeroW(vec2)));
    }

    private func VelocityCollisionTest2D(vehicle: ref<VehicleObject>, range: Float) -> Bool {
        return this.CollisionTest2D(
            this.Get2DRectForCollisionTest(this.GetVehicle(), range, -this.GetVehicle().GetCurrentSpeed() / 6.0),
            this.Get2DRectForCollisionTest(vehicle,
                vehicle.GetCurrentSpeed() + 5.0,
                MaxF(5.0 - vehicle.GetCurrentSpeed() / 2.0, 0.0))
        );
    }

    private func Get2DRectForCollisionTest(vehicle: ref<VehicleObject>, forward: Float, backward: Float) -> [Vector4] {
        let trans = this.GetAdjustedTransform(vehicle);

        let l = -1.5;
        let r = 1.5;
        let f = 2.5 + forward;
        let b = -2.5 - backward;
        let result = [
            SyncSpeed.ZeroW(Transform.TransformPoint(trans, new Vector4(l, b, 0.0, 0.0))),
            SyncSpeed.ZeroW(Transform.TransformPoint(trans, new Vector4(l, f, 0.0, 0.0))),
            SyncSpeed.ZeroW(Transform.TransformPoint(trans, new Vector4(r, f, 0.0, 0.0))),
            SyncSpeed.ZeroW(Transform.TransformPoint(trans, new Vector4(r, b, 0.0, 0.0)))
        ];
        return result;
    }

    private func CollisionTest2D(rectA: [Vector4], rectB: [Vector4]) -> Bool {
        let sideDirs = [
            Vector4.Normalize(rectA[0] - rectA[1]), Vector4.Normalize(rectA[1] - rectA[2]),
            Vector4.Normalize(rectB[0] - rectB[1]), Vector4.Normalize(rectB[1] - rectB[2])
        ];
        let ui = 0;
        for u in sideDirs {
            let minA = Vector4.Dot(rectA[0], u);
            let maxA = minA;
            let minB = Vector4.Dot(rectB[0], u);
            let maxB = minB;

            let i = 1;
            while i < 4 {
                let projA = Vector4.Dot(rectA[i], u);
                minA = MinF(minA, projA);
                maxA = MaxF(maxA, projA);
                
                let projB = Vector4.Dot(rectB[i], u);
                minB = MinF(minB, projB);
                maxB = MaxF(maxB, projB);
                i += 1;
            }
            if maxB < minA || maxA < minB {
                return false;
            }
            ui += 1;
        }
        return true;
    }

    private let m_prevTransform: Transform;

    private func GetAdjustedTransform(vehicle: ref<VehicleObject>) -> Transform {
        let trans = Transform.Create(vehicle.GetWorldPosition(), vehicle.GetWorldOrientation());
        if Vector4.Dot(vehicle.GetWorldOrientation().GetForward(), vehicle.GetLinearVelocity()) > 1.0 {
            let inv = Transform.GetInverse(trans);
            let localV = Transform.TransformVector(inv, vehicle.GetLinearVelocity());
            // 移動の左右方向にはバイアスをかける.
            localV.X = localV.X * 4.0;
            let biased = Transform.TransformVector(trans, localV);
            Transform.SetOrientationFromDir(trans, biased);
            if vehicle == this.GetVehicle() {
                this.m_prevTransform = trans;
            }
        } else {
            if vehicle == this.GetVehicle() {
                trans = this.m_prevTransform;
            }
        }
        return trans;
    }

    private func IsInSameLane(vehicle: ref<VehicleObject>) -> Bool {
        let thisVehicle = this.GetVehicle();
        let localPos = this.GetLocalPoint(vehicle);
        return 
            !vehicle.IsPlayerMounted()
            && SyncSpeed.InTraffic(vehicle)
            && Vector4.Dot(this.GetVehicle().GetWorldForward(), vehicle.GetWorldForward()) > 0.75
            && AbsF(localPos.X) < 3.5
            ;
    }

    private static func InTraffic(vehicle: ref<VehicleObject>) -> Bool {
        return vehicle.IsInTrafficLane() || vehicle.GetCurrentSpeed() > 0.01;
    }

    private func GetLocalPoint(vehicle: ref<VehicleObject>) -> Vector4 {
        return WorldTransform.TransformInvPoint(this.GetVehicle().GetWorldTransform(), vehicle.GetWorldPosition());
    }
}

public class SyncSpeedSelector extends SpeedSelector {
    private let syncSpeed: ref<SyncSpeed>;
    public func Init(component: ref<AutoDriveComponent>, baseSpeedSelector: ref<SpeedSelector>) -> ref<SyncSpeedSelector> {
        this.syncSpeed = new SyncSpeed().Init(component, baseSpeedSelector);
        return this;
    }
    public func Uninit() -> Void {
        super.Uninit();
        if IsDefined(this.syncSpeed) {
            this.syncSpeed.Uninit();
            this.syncSpeed = null;
        }
    }
    public func Select() -> SpeedRange {
        return this.syncSpeed.GetSpeed();
    }
}

public abstract class AICommandFactory {
    protected let m_component: ref<AutoDriveComponent>;
    protected let m_destination: Vector4;
    protected let m_settings: ref<AutoDriveSettings>;
    public func Init(component: ref<AutoDriveComponent>) -> ref<AICommandFactory> {
        this.m_component = component;
        this.m_settings = component.GetSettings();
        this.m_destination = component.GetDestination();
        return this;
    }
    public func Uninit() -> Void {
        this.m_component = null;
        this.m_settings = null;
    }
    public func Create() -> ref<AIVehicleDriveToPointAutonomousCommand>;
    public func Update(ticks: Uint32) -> Bool;
}

public class NormalAICommandFactory extends AICommandFactory {

    private let m_speedSelector: ref<SpeedSelector>;
    private let m_speed: SpeedRange;

    public func Init(component: ref<AutoDriveComponent>) -> ref<AICommandFactory> {
        super.Init(component);
        this.m_speedSelector = new SyncSpeedSelector().Init(component, new NormalSpeedSelector().Init(component));
        return this;
    }
    public func Uninit() -> Void {
        super.Uninit();
        this.m_speedSelector.Uninit();
        this.m_speedSelector = null;
    }
    public func Update(ticks: Uint32) -> Bool {
        let speed = this.m_speedSelector.Select();
        let updated = NotEquals(this.m_speed, speed);
        this.m_speed = speed;
        return updated;
    }
    public func Create() -> ref<AIVehicleDriveToPointAutonomousCommand> {
        let cmd = new AIVehicleDriveToPointAutonomousCommand();
        cmd.clearTrafficOnPath = this.m_settings.clearTrafficOnPath;
        cmd.driveDownTheRoadIndefinitely = this.m_settings.forDev.driveDownTheRoadIndefinitely;
        cmd.useKinematic = this.m_settings.forDev.useKinematic;
        cmd.minimumDistanceToTarget = this.m_settings.forDev.minimumDistanceToTarget;
        cmd.maxSpeed = this.m_speed.max;
        cmd.minSpeed = this.m_speed.min;
        cmd.targetPosition = Vector4.Vector4To3(this.m_destination);
        return cmd;
    }
}

public class TrafficAICommandFactory extends AICommandFactory {

    private let m_init: Bool = false;    
    private let m_enteredStoppingRange: Bool = false;
    private let m_matchedArea: SpeedLimitArea;
    private let m_limitAreaMatch: Bool;
    private let m_speedSum: Float;
    private let m_speedSumTicks: Uint32;

    public func Update(ticks: Uint32) -> Bool {
        if !this.m_init {
            this.m_init = true;
            this.m_speedSum = 0.0;
            return true;
        }
        if !this.m_enteredStoppingRange {
            this.m_enteredStoppingRange = WithinRange(this.m_destination, this.m_settings.stoppingDistanceForTrafficAI, this.m_component.GetVehicle().GetWorldPosition());
        }
        if this.m_enteredStoppingRange {
            this.m_speedSum = 0.0;
            return true;
        }
        if NotEquals(this.m_limitAreaMatch, this.m_component.GetSystem().CheckSpeedLimitAreaForTrafficAI(this.m_matchedArea)) {
            this.m_limitAreaMatch = !this.m_limitAreaMatch;
            this.m_speedSum = 0.0;
            return true;
        }
        // 一定距離走ったら、コマンド入れ直しテスト.
        this.m_speedSum += this.m_component.GetVehicle().GetCurrentSpeed() * Cast<Float>(ticks - this.m_speedSumTicks);
        this.m_speedSumTicks = ticks;
        if this.m_settings.forDev.trafficAICrashWorkaroundCommandRestartDistance > 0.0 && this.m_speedSum > this.m_settings.forDev.trafficAICrashWorkaroundCommandRestartDistance {
            this.m_speedSum = 0.0;
            return true;
        }
        return false;
    }
    public func Create() -> ref<AIVehicleDriveToPointAutonomousCommand> {
        if this.m_enteredStoppingRange {
            return null;
        }
        let cmd: ref<AIVehicleDriveToPointAutonomousCommand>;
        if this.m_limitAreaMatch {
            cmd = new AIVehicleDriveToPointAutonomousCommand();
            cmd.maxSpeed = this.m_matchedArea.speed.max;
            cmd.minSpeed = this.m_matchedArea.speed.min;
        } else {
            let tpCmd = new AIVehicleDriveToPointCommand();
            tpCmd.secureTimeOut = this.m_settings.forDev.secureTimeOut;
            tpCmd.useTraffic = this.m_settings.forDev.useTraffic;
            tpCmd.speedInTraffic = this.m_settings.forDev.speedInTraffic;
            tpCmd.forceGreenLights = this.m_settings.forDev.forceGreenLights;
            tpCmd.trafficTryNeighborsForStart = this.m_settings.trafficTryNeighborsForStart;
            tpCmd.trafficTryNeighborsForEnd = this.m_settings.trafficTryNeighborsForEnd;
            cmd = tpCmd;
        }
        cmd.targetPosition = Vector4.Vector4To3(this.m_destination);
        return cmd;
    }
}

public abstract class AutoDriveCommandHandler {
    protected let m_component: ref<AutoDriveComponent>;
    protected let m_settings: ref<AutoDriveSettings>;

    protected func Init(component: ref<AutoDriveComponent>) -> ref<AutoDriveCommandHandler> {
        this.m_component = component;
        this.m_settings = component.GetSettings();
        return this;
    }
    public func Uninit() -> Void {
        this.m_component = null;
        this.m_settings = null;
        this.m_command = null;
    }

    protected func GetTickRate() -> Uint32 { return 15u; }

    protected func GetVehicle() -> ref<VehicleObject> {
        return this.m_component.GetVehicle();
    }

    protected let m_command: ref<AIVehicleCommand>;

    protected func QueueAICommand() -> Void {
        let cmd = this.CreateAICommand();
        if IsDefined(cmd) {
            let evt = new AICommandEvent();
            evt.command = cmd;
            this.m_command = cmd;
            this.GetVehicle().QueueEvent(evt);
            this.GetVehicle().GetAIComponent().SetInitCmd(cmd);
        } else {
            this.StopAICommand();
        }
    }

    protected func StopAICommand() -> Void {
        if !IsDefined(this.m_command) {
            return;
        }
        this.GetVehicle().GetAIComponent().CancelCommand(this.m_command);
        this.GetVehicle().GetAIComponent().StopExecutingCommand(this.m_command, true);
        this.m_command = null;
    }

    public func Requeue() -> Void {
        this.StopAICommand();
        this.QueueAICommand();
    }

    public func Stop() -> Void {
        this.StopAICommand();
    }

    public func Tick(ticks: Uint32) -> Bool {
        if ticks % this.GetTickRate() != 0u {
            return false;
        }
        let updated = this.Update(ticks);
        if updated {
            this.Requeue();
        } else {
            if IsDefined(this.m_command) && this.IsCompleted() {
                this.StopAICommand();
            }
        }
        return true;
    }

    public func IsCompleted() -> Bool {
        if !IsDefined(this.m_command) {
            return true;
        }
        return Equals(this.m_command.state, AICommandState.Cancelled)
            || Equals(this.m_command.state, AICommandState.Interrupted)
            || Equals(this.m_command.state, AICommandState.Success)
            || Equals(this.m_command.state, AICommandState.Failure);
    }

    protected func Update(ticks: Uint32) -> Bool;
    protected func CreateAICommand() -> ref<AIVehicleCommand>;
}

public abstract class AutoDriveToPointCommandHandler extends AutoDriveCommandHandler {
    protected let m_normalAICommandFactory: ref<AICommandFactory>;
    protected let m_trafficAICommandFactory: ref<AICommandFactory>;

    protected func Init(component: ref<AutoDriveComponent>) -> ref<AutoDriveToPointCommandHandler> {
        super.Init(component);
        this.m_normalAICommandFactory = new NormalAICommandFactory().Init(component);
        this.m_trafficAICommandFactory = new TrafficAICommandFactory().Init(component);
        return this;
    }
    public func Uninit() -> Void {
        super.Uninit();
        if IsDefined(this.m_normalAICommandFactory) {
            this.m_normalAICommandFactory.Uninit();
            this.m_normalAICommandFactory = null;
        }
        if IsDefined(this.m_trafficAICommandFactory) {
            this.m_trafficAICommandFactory.Uninit();
            this.m_trafficAICommandFactory = null;
        }
    }
    protected func GetAICommandFactory() -> ref<AICommandFactory> {
        if Equals(this.m_settings.aiCommandType, AICommandType.Normal) {
            return this.m_normalAICommandFactory;
        } else if Equals(this.m_settings.aiCommandType, AICommandType.Traffic) {
            return this.m_trafficAICommandFactory;
        }
        return this.m_normalAICommandFactory;
    }
}

public class GoToTrackedPointCommandHandler extends AutoDriveToPointCommandHandler {
    protected func Update(ticks: Uint32) -> Bool { return this.GetAICommandFactory().Update(ticks); }
    protected func CreateAICommand() -> ref<AIVehicleCommand> { return this.GetAICommandFactory().Create(); }
}

public class LoopPointsCommandHandler extends GoToTrackedPointCommandHandler {
    private let m_currentIndex: Int32;
    private let m_range: Float;
    private let m_points: array<Vector4>;

    public func Init(component: ref<AutoDriveComponent>, points: array<Vector4>, range: Float) -> ref<LoopPointsCommandHandler> {
        super.Init(component);
        this.m_range = range;
        this.m_points = points;
        this.m_currentIndex = 0;
        return this;
    }

    protected func Update(ticks: Uint32) -> Bool {
        let posUpdated = WithinRange(this.m_points[this.m_currentIndex], this.m_range, this.m_component.GetVehicle().GetWorldPosition());
        if posUpdated {
            this.m_currentIndex = (this.m_currentIndex + 1) % ArraySize(this.m_points);
        }
        let baseUpdated = super.Update(ticks);
        return posUpdated || baseUpdated;
    }

    protected func CreateAICommand() -> ref<AIVehicleCommand> {
        let cmd = super.CreateAICommand() as AIVehicleDriveToPointAutonomousCommand;
        if IsDefined(cmd) {
            cmd.targetPosition = Vector4.Vector4To3(this.m_points[this.m_currentIndex]);
        }
        return cmd;
    }
}

// 仮実装
public class WanderingCommandHandler extends AutoDriveCommandHandler {
    public func Init(component: ref<AutoDriveComponent>) -> ref<WanderingCommandHandler> {
        super.Init(component);
        return this;
    }
    private let m_init: Bool = false;
    private let m_lastStopped: Float;
    private let m_speedSum: Float;

    protected func Update(ticks: Uint32) -> Bool {
        if !this.m_init {
            this.m_init = true;
            this.m_speedSum = 0.0;
            return true;
        }
        let veh = this.m_component.GetVehicle();
        this.m_speedSum += veh.GetCurrentSpeed() * Cast<Float>(this.GetTickRate());
        // ISSUE: Player が乗車中に AIVehicleJoinTrafficCommand を実行すると、しばらくすると止まってしまう。
        // veh=GetPlayer():GetMountedVehicle(); cmd=AIVehicleJoinTrafficCommand.new(); evt=AICommandEvent.new(); evt.command = cmd; veh:QueueEvent(evt);
        // Player が乗車せずに AIVehicleJoinTrafficCommand を実行すると、止まらずに動作する。
        // veh=GameInstance.GetTargetingSystem():GetLookAtObject(GetPlayer(), true, true); cmd=AIVehicleJoinTrafficCommand.new(); evt=AICommandEvent.new(); evt.command = cmd; veh:QueueEvent(evt);
        // 乗車中は TrafficPath 等が正しく更新されていない？ おそらく、DriveToPoint で視界から外した前方の車が消えるのも同じ原因だと思われる。
        if veh.GetCurrentSpeed() > 12.0 && this.m_speedSum > 20000.0 {
            // コーナリング中に実行すると、いきなり別方向に曲がりだす場合があり、直進中に実行したいので速度チェック. と前回からどの程度進んだかをチェックする.
            this.m_speedSum = 0.0;
            return true;
        }
        if AbsF(veh.GetCurrentSpeed()) < 0.01 {
            if veh.GetCrowdMemberComponent().CheckIsMoving() {
                this.m_speedSum = 0.0;
                return true;
            }
            if this.m_lastStopped > 0.0 {
                // 長時間止まっている場合には、無理やり動かす.
                if this.m_component.GetSystem().Now() - this.m_lastStopped > 15.0 {
                    this.m_lastStopped = 0.0;
                    this.m_speedSum = 0.0;
                    return true;
                }
            } else {
                this.m_lastStopped = this.m_component.GetSystem().Now();
            }
        } else {
            this.m_lastStopped = 0.0;
        }
        return false;
    }
    protected func CreateAICommand() -> ref<AIVehicleCommand> {
        let panic = this.GetVehicle().GetAIComponent().GetEnqueuedOrExecutingCommand(n"AIVehiclePanicCommand", false);
        if IsDefined(panic) {
            this.GetVehicle().GetAIComponent().CancelCommand(panic);
            this.GetVehicle().GetAIComponent().StopExecutingCommand(panic, true);
        }
        let cmd = new AIVehicleJoinTrafficCommand();
        cmd.useKinematic = this.m_settings.forDev.useKinematic;
        return cmd;
    }
    protected func IsCompleted() -> Bool { return false; }
    public func Stop() -> Void {
        super.Stop();
        // ISSUE: NoDriverを送って、無理に止めるてから、"DriverReady"を送って再度活性化する.
        // できれば、InCrowdしてしまっているようなので、それを何とかする必要がある。
        this.m_component.SendEvent(n"NoDriver");
        this.m_component.SendEventDelayed(n"DriverReady", 0.5);
    }
}

public class AutoDriveSystem extends ScriptableSystem {

    private let m_settings: ref<AutoDriveSettings>;

    public func GetSettings() -> ref<AutoDriveSettings> {
        return this.m_settings;
    }

    private let m_speedLimitAreasForNormalAI: array<SpeedLimitArea>;
    private let m_speedLimitAreasForTrafficAI: array<SpeedLimitArea>;

    public static func GetInstance(game: GameInstance) -> ref<AutoDriveSystem> {
        return GameInstance.GetScriptableSystemsContainer(game).Get(n"AutoDriveMod.AutoDriveSystem") as AutoDriveSystem;
    }

    private func OnAttach() -> Void {
        this.AddSpeedLimitAreaForNormalAI(SpeedLimitArea.New("dogtown_gate", new Vector4(-2059.910400, -2319.379395, 20.799999, 1.000000), 70.0, 10.0, 5.0)); // Dogtown Gate.
        // this.AddSpeedLimitAreaForNormalAI(SpeedLimitArea.New("pacifica_tent", new Vector4(-2098.398700, -2228.858200, 18.147196, 1.000000), 30.0, 10.0, 5.0)); // Pacifica tent.

        this.AddSpeedLimitAreaForTrafficAI(SpeedLimitArea.New("dogtown_gate", new Vector4(-2059.910400, -2319.379395, 20.799999, 1.000000), 70.0, 10.0, 5.0)); // Dogtown Gate.
        this.m_settings = new AutoDriveSettings();
        this.m_settings.Initialize();
    }

    private func OnDetach() -> Void {
        this.m_settings.Uninitialize();
        this.m_settings = null;
    }

    private let minimapController: ref<MinimapContainerController>;

    public func Initialize(minimapController: ref<MinimapContainerController>) -> Void {
        this.minimapController = minimapController;
    }

    public func Uninitialize() -> Void {
        this.minimapController = null;
    }

    public func GetSpeedLimitAreasForNormalAI() -> array<SpeedLimitArea> {
        return this.m_speedLimitAreasForNormalAI;
    }
    public func AddSpeedLimitAreaForNormalAI(area: SpeedLimitArea) -> Void {
        ArrayPush(this.m_speedLimitAreasForNormalAI, area);
    }
    public func CheckSpeedLimitAreaForNormalAI(out match: SpeedLimitArea) -> Bool {
        return AutoDriveSystem.CheckSpeedLimitArea(this.m_speedLimitAreasForNormalAI, this.GetVehicle(), match);
    }

    public func GetSpeedLimitAreasForTrafficAI() -> array<SpeedLimitArea> {
        return this.m_speedLimitAreasForTrafficAI;
    }
    public func AddSpeedLimitAreaForTrafficAI(area: SpeedLimitArea) -> Void {
        ArrayPush(this.m_speedLimitAreasForTrafficAI, area);
    }
    public func CheckSpeedLimitAreaForTrafficAI(out match: SpeedLimitArea) -> Bool {
        return AutoDriveSystem.CheckSpeedLimitArea(this.m_speedLimitAreasForTrafficAI, this.GetVehicle(), match);
    }

    private static func CheckSpeedLimitArea(areas: array<SpeedLimitArea>, target: wref<GameObject>, out match: SpeedLimitArea) -> Bool {
        for area in areas {
            if SpeedLimitArea.WithinRange(area, target) {
                match = area;
                return true;
            }
        }
        return false;
    }

    public func GetPlayer() -> ref<PlayerPuppet> {
        return GetPlayer(this.GetGameInstance());
    }

    public func GetVehicle() -> ref<VehicleObject> {
        return this.GetPlayer().GetMountedVehicle();
    }

    public func GetDelaySystem() -> ref<DelaySystem> {
        return GameInstance.GetDelaySystem(this.GetGameInstance());
    }

    public func Now() -> Float {
        return EngineTime.ToFloat(GameInstance.GetPlaythroughTime(this.GetGameInstance()));
    }

    public func StartLoopDrive(points: array<Vector4>, opt range: Float, opt ticksTimeout: Float) -> Void {
        if IsDefined(this.GetVehicle()) {
            this.GetVehicle().GetAutoDriveComponent().StartLoopDrive(points, range, ticksTimeout);
        }
    }

    public func StartWanderingDrive(opt ticksTimeout: Float) -> Void {
        // AutoDriveMod_AutoDriveSystem.GetInstance():StartWanderingDrive();
        if IsDefined(this.GetVehicle()) {
            this.GetVehicle().GetAutoDriveComponent().StartWanderingDrive(ticksTimeout);
        }
    }

    public func RequestForceAutoSave() -> Void {
        GameInstance.GetAutoSaveSystem(this.GetGameInstance()).RequestForcedCheckpoint();
    }

    public func FindAllMappinControllers() -> array<wref<BaseMinimapMappinController>> {
        if !IsDefined(this.minimapController) || !IsDefined(this.minimapController.GetRootWidget()) {
            return [];
        }
        return this.FindMappinControllers(this.minimapController.GetRootWidget());
    }

    private func FindMappinControllers(w: wref<inkWidget>) -> array<wref<BaseMinimapMappinController>> {
        let controllers: array<wref<BaseMinimapMappinController>> = [];
        let controller = w.GetController() as BaseMinimapMappinController;
        if IsDefined(controller) {
            ArrayPush(controllers, controller);
        } else {
            let container = w as inkCompoundWidget;
            if IsDefined(container) {
                let i = 0;
                while i < container.GetNumChildren() {
                    let children = this.FindMappinControllers(container.GetWidget(i));
                    for c in children {
                        ArrayPush(controllers, c);
                    }
                    i = i + 1;
                }
            }
        }
        return controllers;
    }
    
    public func GetTrackedMappin() -> ref<IMappin> {
        let mappinControllers = this.FindAllMappinControllers();
        let questMappin: ref<IMappin>;
        let customMappin: ref<IMappin>;
        let normalMappin: ref<IMappin>;
        for c in mappinControllers {
            if !Vector4.IsXYZZero(c.GetMappin().GetWorldPosition()) && c.IsTracked() && c.GetMappin().IsActive() {
                if c.IsCustomPositionTracked() && !IsDefined(customMappin) {
                    customMappin = c.GetMappin();
                }
                if c.GetMappin().IsQuestPath() && !IsDefined(questMappin) {
                    questMappin = c.GetMappin();
                }
                if !c.GetMappin().IsQuestPath() && !IsDefined(normalMappin) {
                    normalMappin = c.GetMappin();
                }
            }
        }
        if IsDefined(customMappin) {
            return customMappin;
        }
        if IsDefined(normalMappin) {
            return normalMappin;
        }
        if IsDefined(questMappin) {
            return questMappin;
        }
        return null;
    }

    public func GetTrackedPoint() -> Vector4 {
        let mappin = this.GetTrackedMappin();
        if IsDefined(mappin) {
            return mappin.GetWorldPosition();
        } else {
            return Vector4.EmptyVector();
        }
    }
}

public class AutoDriveComponent {
    private let m_vehicle: ref<VehicleObject>;
    private let m_player: ref<PlayerPuppet>;
    private let m_system: ref<AutoDriveSystem>;

    public func Initialize(player: ref<PlayerPuppet>, vehicle: ref<VehicleObject>) -> Void {
        this.m_player = player;
        this.m_vehicle = vehicle;
        this.m_system = AutoDriveSystem.GetInstance(player.GetGame());
    }

    public func Uninitialize() -> Void {
        this.CancelAutoDrive(false);
        this.m_player = null;
        this.m_vehicle = null;
        this.m_system = null;
    }

    public func GetDelaySystem() -> ref<DelaySystem> {
        return GameInstance.GetDelaySystem(this.GetPlayer().GetGame());
    }

    public func GetVehicle() -> ref<VehicleObject> {
        return this.m_vehicle;
    }

    public func GetPlayer() -> ref<PlayerPuppet> {
        return this.m_player;
    }

    public func GetSystem() -> ref<AutoDriveSystem> {
        return this.m_system;
    }

    public func GetSettings() -> ref<AutoDriveSettings> {
        return this.GetSystem().GetSettings();
    }

    public func GetCruisingSpeedRange() -> SpeedRange {
        if this.GetSystem().GetSettings().autoSpeedControl {
            let minSpeed = MaxF(this.GetSteeringFactor() * 10.0, 3.0);
            let maxSpeed = MaxF(this.GetVehicleMaxSpeed() * this.GetSystem().GetSettings().autoSpeedControlMaxSpeedRatio, minSpeed);
            // L(s"AutoCruisingSpeed: max=\(maxSpeed) min=\(minSpeed)");
            return SpeedRange.New(maxSpeed, minSpeed);
        } else {
            return SpeedRange.New(this.GetSettings().cruisingMaxSpeed, this.GetSettings().cruisingMinSpeed);
        }
    }

    public func GetStartingDistance() -> Float {
        if this.GetSystem().GetSettings().autoSpeedControl {
            return 15.0;
        } else {
            return this.GetSettings().startingDistance;
        }
    }

    public func GetStartingSpeedRange() -> SpeedRange {
        if this.GetSystem().GetSettings().autoSpeedControl {
            return SpeedRange.New(10.0, 3.0);
        } else {
            return SpeedRange.New(this.GetSettings().startingMaxSpeed, this.GetSettings().startingMinSpeed);
        }
    }

    public func GetStoppingDistance() -> Float {
        if this.GetSystem().GetSettings().autoSpeedControl {
            let distance = 10.0 + (this.GetStoppingFactor() * 15.0);
            // L(s"stopping distance: \(distance)");
            return distance;
            // return 50.0;
        } else {
            return this.GetSettings().stoppingDistance;
        }
    }

    public func GetStoppingSpeedRange() -> SpeedRange {
        if this.GetSystem().GetSettings().autoSpeedControl {
            return SpeedRange.New(8.0, 3.0);
        } else {
            return SpeedRange.New(this.GetSettings().stoppingMaxSpeed, this.GetSettings().stoppingMinSpeed);
        }
    }

    public func GetStoppingFactor() -> Float {
        let wheelSetup = this.GetVehicle().GetRecord().VehDriveModelData().WheelSetup();
        let brakingTorque = (wheelSetup.FrontPreset().MaxBrakingTorque() + wheelSetup.BackPreset().MaxBrakingTorque()) / 2.0;
        let spd = this.GetSettings().forceBrakesSpeedFactor;
        let mass = this.GetSettings().forceBrakesMassFactor;
        let bt = this.GetSettings().forceBrakesBrakingTorqueFactor;
        if this.GetSystem().GetSettings().autoSpeedControl {
            spd = 1.0;
            mass = 1.0;
            bt = 1.0;
        }
        let speedFactor = spd * AbsF(this.GetVehicle().GetCurrentSpeed() / 16.0);
        let massFactor = MaxF(this.GetVehicle().GetTotalMass() / 1000.0 * mass, 1.0);
        let brakingFactor = bt;
        if brakingTorque > 0.0 {
            brakingFactor = brakingFactor * ClampF(400.0 / brakingTorque, 0.70, 2.0);
        } else {
            // おそらく二輪車、ブレーキ性能低いので、1.5くらいにしておく.
            brakingFactor = 1.5;
        }
        let stoppingFactor = speedFactor * massFactor * brakingFactor;
        // L(s"stoppingFactor: factor=\(stoppingFactor) speedFactor=\(speedFactor) massFactor=\(massFactor) brakingFactor=\(brakingFactor)");
        return stoppingFactor;
    }

    public func GetSteeringFactor() -> Float {
        // よく分からんので簡易的に。。。
        let dmd = this.GetVehicle().GetRecord().VehDriveModelData();
        if !IsDefined(dmd) {
            return 1.0;
        }
        if dmd.WheelTurnMaxAddPerSecond() + dmd.WheelTurnMaxSubPerSecond() == 0.0 {
            return 1.0;
        }
        return (dmd.WheelTurnMaxAddPerSecond() + dmd.WheelTurnMaxSubPerSecond()) / 2.0 / 100.0;
    }

    public func GetBrakingTime() -> Float {
        let baseTime = this.GetSettings().forceBrakesBaseTime;
        if this.GetSystem().GetSettings().autoSpeedControl {
            baseTime = 0.5;
        }
        let brakingTime = baseTime + this.GetStoppingFactor();
        return brakingTime;
    }

    private func GetVehicleMaxSpeed() -> Float {
        let gears: [wref<VehicleGear_Record>];
        this.GetVehicle().GetRecord().VehEngineData().Gears(gears);
        let max = 0.0;
        for gear in gears {
            max = MaxF(max, gear.MaxSpeed());
        }
        return max;
    }

    public func ToggleAutoDrive() -> Void {
        if !IsDefined(this.GetVehicle()) {
            return;
        }
        if this.IsAutoDriving() {
            this.CancelAutoDrive(true);
        } else {
            this.StartAutoDrive();
        }
    }

    public func StartLoopDrive(points: array<Vector4>, opt range: Float, opt ticksTimeout: Float) -> Void {
        if ArraySize(points) < 3 {
            return;
        }
        range = MaxF(range, 10.0);
        if ticksTimeout == 0.0 {
            this.m_ticksTimeout = 60.0 * 60.0 * 3.0; // 3 hour
        } else {
            this.m_ticksTimeout = ticksTimeout;
        }
        this.m_commandHandler = new LoopPointsCommandHandler().Init(this, points, range);
        this.StartAutoDriveInternal(false, true);
    }

    public func StartWanderingDrive(opt ticksTimeout: Float) -> Void {
        if ticksTimeout == 0.0 {
            this.m_ticksTimeout = 60.0 * 60.0 * 6.0; // 6 hour
        } else {
            this.m_ticksTimeout = ticksTimeout;
        }
        this.m_commandHandler = new WanderingCommandHandler().Init(this);
        this.StartAutoDriveInternal(false, true);
    }

    public func StartAutoDrive() -> Void {
        this.StartAutoDriveWithSound(true, this.GetSettings().autoSaveOnStartAutoDrive);
    }

    public func GetDestination() -> Vector4 {
        return this.GetSystem().GetTrackedPoint();
    }

    public func StartAutoDriveWithSound(playStartSound: Bool, opt autoSave: Bool) -> Void {
        if !this.CanAutoDrive() {
            return;
        }
        if Vector4.IsXYZZero(this.GetDestination()) {
            this.ShowNoDestinationSetNotification();
            return;
        }
        this.m_ticksTimeout = this.GetSettings().ticksTimeout;
        if playStartSound {
            this.PlayStartSound();
        }
        if autoSave {
            this.GetSystem().RequestForceAutoSave();
        }
        this.m_commandHandler = new GoToTrackedPointCommandHandler().Init(this);
        this.StartAutoDriveInternal(true, false);
    }

    private let m_commandHandler: ref<AutoDriveCommandHandler>;
    private let m_ticksTimeout: Float = 600.0;

    public func StartAutoDriveInternal(stopOnFinish: Bool, playStartSound: Bool) -> Void {
        this.InitializeAutoDrive();

        let evt = new AutoDriveTickEvent();
        this.m_tickID = this.GetDelaySystem().TickOnEvent(this.GetVehicle(), evt, this.m_ticksTimeout);
        this.m_tickEnable = true;
        this.SetAutoDriving(true);
    }

    private func InitializeAutoDrive() -> Void {
        this.m_stopOnFinish = true;
        this.GetDelaySystem().CancelTick(this.m_tickID);
        this.m_tickEnable = false;
        // this.m_commandHandler.Stop();
        this.SetAutoDriving(false);
        this.m_ticks = 0u;

        // ISSUE: 助手席から強奪した時に動作しないので DriverReady を送る.
        this.SendEvent(n"DriverReady");
    }

    private let m_tickID: DelayID;
    private let m_tickEnable: Bool;
    private let m_autoDriving: Bool = false;
    private let m_stopOnFinish: Bool = true;
    private let m_ticks: Uint32;

    public func CancelAutoDrive(stop: Bool) -> Void {
        if !this.IsAutoDriving() {
            return;
        }
        this.GetDelaySystem().CancelTick(this.m_tickID);
        this.m_tickEnable = false;
        this.m_commandHandler.Stop();
        this.m_commandHandler.Uninit();
        this.m_commandHandler = null;
        this.SetAutoDriving(false);
        if stop {
            this.GetVehicle().ForceBrakesUntilStoppedOrFor(this.GetBrakingTime());
            this.PlayCompleteSound();
        }
    }

    public func Requeue() -> Void {
        this.m_commandHandler.Requeue();
    }

    public func OnTick() -> Void {
        if this.m_tickEnable && IsDefined(this.m_commandHandler) && this.m_commandHandler.Tick(this.m_ticks) {
            this.UpdateCheat();
            if this.m_commandHandler.IsCompleted() {
                this.CancelAutoDrive(this.m_stopOnFinish);
            }
        }
        this.m_ticks = this.m_ticks + 1u;
    }

    public func PlayStartSound() -> Void {
        if this.GetSettings().honkTheHorn {
            // GameObject.PlaySoundEvent(this.GetVehicle(), n"ui_gui_inventory_cyberware_equip");
            this.HonkHorn(0.1, 0.0); this.HonkHorn(0.1, 0.2);
        }
    }

    public func PlayCompleteSound() -> Void {
        if this.GetSettings().honkTheHorn {
            // GameObject.PlaySoundEvent(this.GetVehicle(), n"ui_jingle_vehicle_arrive");
            this.HonkHorn(0.5, 0.0);
        }
    }

    public func HonkHorn(honkTime: Float, delayTime: Float) -> Void {
        let horn = new VehicleQuestDelayedHornEvent();
        horn.honkTime = honkTime;
        horn.delayTime = delayTime;
        this.GetVehicle().QueueEvent(horn);
    }

    protected func SetCheat(enable: Bool) -> Void {
        if NotEquals(this.GetVehicle().GetPreventionSystem().IsLockedHeat_AD(), enable) {
            if enable && this.GetSettings().lockHeatLevel {
                this.GetVehicle().GetPreventionSystem().LockHeat_AD(true);
            } else if !enable {
                this.GetVehicle().GetPreventionSystem().LockHeat_AD(false);
            }
        }
        let godMode = GameInstance.GetGodModeSystem(this.GetVehicle().GetGame());
        if NotEquals(godMode.HasGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Invulnerable), enable){
            if enable && this.GetSettings().noDamage {
                godMode.AddGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Invulnerable, n"Default");
            } else if !enable {
                godMode.RemoveGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Invulnerable, n"Default");
            }
        }
    }

    public func UpdateCheat() -> Void {
        // できれば、 VehicleGlassDestructionEvent, VehicleGridDestructionEvent でコールしたいが。。。
        let godMode = GameInstance.GetGodModeSystem(this.GetVehicle().GetGame());
        if this.IsAutoDriving() && this.GetSettings().noDamage && godMode.HasGodMode(this.GetVehicle().GetEntityID(), gameGodModeType.Invulnerable) {
            this.GetVehicle().DestructionResetGlass();
            this.GetVehicle().DestructionResetGrid();
        }
    }

    public func OnCombatStateChanged(inCombat: Bool) -> Void {
        if this.IsAutoDriving() && this.GetSettings().disableCheatsInCombat {
            this.SetCheat(!inCombat);
        }
    }

    protected func SetAutoDriving(autoDriving: Bool) -> Void {
        this.SetCheat(autoDriving);
        this.m_autoDriving = autoDriving;
        if autoDriving {
            this.requireWorkaroundForIssueOfMovingOnItsOwn = true;
        }
    }

    public func IsAutoDriving() -> Bool {
        return this.m_autoDriving;
    }

    public func CanAutoDrive() -> Bool {
        if !this.GetVehicle().CanAutoDrive() {
            return false;
        }
        if this.GetVehicle().RecordHasTag(n"CannotAutoDrive") {
            return false;
        }
        if this.GetSettings().restrictVehicles {
            if !this.GetVehicle().RecordHasTag(n"CanAutoDrive") {
                return false;
            }
        }
        return true;
    }

    private final func ShowNoDestinationSetNotification() -> Void {
        let uiSystem = GameInstance.GetUISystem(this.GetVehicle().GetGame());
        uiSystem.QueueEvent(new UIInGameNotificationRemoveEvent());
        let notificationEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
        notificationEvent.m_notificationType = UIInGameNotificationType.GenericNotification;
        notificationEvent.m_title = AutoDriveSettings.GetNoDestinationSetText();
        uiSystem.QueueEvent(notificationEvent);
        /*
        let warningMsg: SimpleScreenMessage;
        warningMsg.isShown = true;
        warningMsg.duration = 5.0;
        warningMsg.message = AutoDriveSettings.GetNoDestinationSetText();
        GameInstance.GetBlackboardSystem(this.GetPlayer().GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
        */
    }

    public let requireWorkaroundForIssueOfMovingOnItsOwn: Bool;

    public func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Void {
        if this.GetSettings().forDev.enableWorkaroundForIssueOfMovingOnItsOwn {
            // ISSUE: 降車時に勝手に車(特にバイク)がじりじり動き出す問題
            // 0.5秒後にプレイヤーが降車していれば、"NoDriver" を送信して、その後すぐに "DriverReady" を送信する。
            // SwitchSeatsでもここに入ってくるので要注意。
            // これで動作自体は止まるが、対症療法なのでできれば何とかしたい。。。
            this.GetSystem().GetDelaySystem().DelayCallback(new WorkaroundForIssueOfMovingOnItsOwn().Init(this), 0.5, true);
        }
    }

    public func SendEvent(eventName: CName) -> Void {
        let aiEvent = new AIEvent();
        aiEvent.name = eventName;
        this.GetVehicle().QueueEvent(aiEvent);
    }

    public func SendEventDelayed(eventName: CName, seconds: Float) -> Void {
        this.GetSystem().GetDelaySystem().DelayCallback(new DelayedSendEvent().Init(this, eventName), seconds, true);
    }
}

public class WorkaroundForIssueOfMovingOnItsOwn extends DelayCallback {
    public func Init(component: ref<AutoDriveComponent>) -> ref<WorkaroundForIssueOfMovingOnItsOwn> {
        this.m_component = component;
        return this;
    }
    private let m_component: ref<AutoDriveComponent>;
    public func Call() -> Void {
        if !this.m_component.GetPlayer().GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle)
        && this.m_component.requireWorkaroundForIssueOfMovingOnItsOwn {
            this.m_component.SendEvent(n"NoDriver");
            this.m_component.SendEventDelayed(n"DriverReady", 1.0);
            this.m_component.requireWorkaroundForIssueOfMovingOnItsOwn = false;
        }
    }
}

public class DelayedSendEvent extends DelayCallback {
    public func Init(component: ref<AutoDriveComponent>, eventName: CName) -> ref<DelayedSendEvent> {
        this.m_component = component;
        this.m_eventName = eventName;
        return this;
    }
    private let m_component: ref<AutoDriveComponent>;
    private let m_eventName: CName;
    public func Call() -> Void {
        this.m_component.SendEvent(this.m_eventName);
    }
}

@wrapMethod(VehicleObject)
protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
    let result = wrappedMethod(evt);
    this.GetAutoDriveComponent().OnUnmountingEvent(evt);
    return result;
}

@addMethod(VehicleObject)
public func CanAutoDrive() -> Bool { return true; }

@addField(VehicleObject)
protected let autoDriveComponent: ref<AutoDriveComponent>;

@addMethod(VehicleObject)
public func GetAutoDriveComponent() -> ref<AutoDriveComponent> {
    return this.autoDriveComponent;
}

public class AutoDriveTickEvent extends TickableEvent {}

@addMethod(VehicleObject)
protected cb func OnAutoDriveTickEvent(evt: ref<AutoDriveTickEvent>) -> Bool {
    if IsDefined(this.GetAutoDriveComponent()) {
        this.GetAutoDriveComponent().OnTick();
    }
}

@wrapMethod(VehicleObject)
protected cb func OnGameAttached() -> Bool {
    let result = wrappedMethod();
    this.autoDriveComponent = new AutoDriveComponent();
    this.autoDriveComponent.Initialize(GetPlayer(this.GetGame()), this);
    return result;
}

@wrapMethod(VehicleObject)
protected cb func OnDetach() -> Bool {
    let result = wrappedMethod();
    if IsDefined(this.autoDriveComponent) {
        this.autoDriveComponent.Uninitialize();
        this.autoDriveComponent = null;
    }
    return result;
}

@addMethod(DefaultTransition)
protected final func GetVehicle_AD(scriptInterface: ref<StateGameScriptInterface>) -> ref<VehicleObject> {
    let vehicle: wref<VehicleObject>;
    VehicleComponent.GetVehicle(scriptInterface.executionOwner.GetGame(), scriptInterface.executionOwner, vehicle);
    return vehicle;
}

@addMethod(DefaultTransition)
protected final func GetAutoDriveComponent(scriptInterface: ref<StateGameScriptInterface>) -> ref<AutoDriveComponent> {
    return this.GetVehicle_AD(scriptInterface).GetAutoDriveComponent();
}

@addMethod(DefaultTransition) 
protected func IsAutoDriveBlocked(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.GetAutoDriveComponent(scriptInterface).CanAutoDrive() || this.IsExitVehicleBlocked(scriptInterface);
}

@addMethod(InputContextTransitionEvents)
protected func IsAutoDriveBlocked(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return super.IsAutoDriveBlocked(scriptInterface) || !this.GetStaticBoolParameterDefault("hasOnUpdate", false);
}

@addMethod(DefaultTransition)
protected func CanHandleAutoDriveInput(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let hudManager = scriptInterface.GetScriptableSystem(n"HUDManager") as HUDManager;
    return !this.IsAutoDriveBlocked(scriptInterface) && (!IsDefined(hudManager) || !hudManager.GetUiScannerVisible());
}

@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateAutoDriveHint(n"VehicleDriver", stateContext, scriptInterface);
    wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(InputContextTransitionEvents)
protected final func RemoveVehicleDriverInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    wrappedMethod(stateContext, scriptInterface);
    this.HideAutoDriveHint(n"VehicleDriver", stateContext, scriptInterface);
}

@wrapMethod(InputContextTransitionEvents)
private final const func ShowVehicleDriverCombatInputHintsInternal(source: CName, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateAutoDriveHint(source, stateContext, scriptInterface);
    wrappedMethod(source, stateContext, scriptInterface);
}

@wrapMethod(InputContextTransitionEvents)
protected final func RemoveVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    wrappedMethod(stateContext, scriptInterface);
    this.HideAutoDriveHint(n"VehicleDriverCombat", stateContext, scriptInterface);
}

@addMethod(InputContextTransitionEvents) 
protected final const func UpdateAutoDriveHint(source: CName, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if !this.IsAutoDriveBlocked(scriptInterface) {
        this.ShowAutoDriveHint(source, stateContext, scriptInterface);
    } else {
        this.HideAutoDriveHint(source, stateContext, scriptInterface);
    }
}

@addMethod(InputContextTransitionEvents) 
protected final const func ShowAutoDriveHint(source: CName, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetAutoDriveComponent(scriptInterface).GetSettings().showToggleAutoDriveInputHint {
        let hint = AutoDriveSettings.GetAutoDriveHintLabel(this.GetAutoDriveComponent(scriptInterface).IsAutoDriving());
        this.ShowInputHint(scriptInterface, n"ToggleVehAutoDrive", source, hint);
    } else {
        this.RemoveInputHint(scriptInterface, n"ToggleVehAutoDrive", source);
    }
}

@addMethod(InputContextTransitionEvents) 
protected final const func HideAutoDriveHint(source: CName, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveInputHint(scriptInterface, n"ToggleVehAutoDrive", source);
}

@addField(InputContextTransitionEvents)
private let m_isAutoDriving: Bool = false;
@addField(InputContextTransitionEvents)
private let m_isAutoDriveBlocked: Bool = false;

@wrapMethod(VehicleDriverContextEvents)
protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_isAutoDriving = this.GetAutoDriveComponent(scriptInterface).IsAutoDriving();
    this.m_isAutoDriveBlocked = this.IsAutoDriveBlocked(scriptInterface);
    wrappedMethod(stateContext, scriptInterface);
}
@wrapMethod(VehicleDriverCombatContextEvents)
protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_isAutoDriving = this.GetAutoDriveComponent(scriptInterface).IsAutoDriving();
    this.m_isAutoDriveBlocked = this.IsAutoDriveBlocked(scriptInterface);
    wrappedMethod(stateContext, scriptInterface);
}

@addMethod(InputContextTransitionEvents)
protected final func UpdateRefleshFlag(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if NotEquals(this.m_isAutoDriving, this.GetAutoDriveComponent(scriptInterface).IsAutoDriving())
    || NotEquals(this.m_isAutoDriveBlocked, this.IsAutoDriveBlocked(scriptInterface)) {
        this.RequestRefleshHint(stateContext, scriptInterface);
        this.m_isAutoDriving = this.GetAutoDriveComponent(scriptInterface).IsAutoDriving();
        this.m_isAutoDriveBlocked = this.IsAutoDriveBlocked(scriptInterface);
    }
}

@addMethod(InputContextTransitionEvents)
protected final func RequestRefleshHint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetTemporaryBoolParameter(n"ForceRefreshInputHints", true, true);
}

@wrapMethod(VehicleDriverContextEvents)
protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateRefleshFlag(stateContext, scriptInterface);
    wrappedMethod(timeDelta, stateContext, scriptInterface);
}
@wrapMethod(VehicleDriverCombatContextEvents)
protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.UpdateRefleshFlag(stateContext, scriptInterface);
    wrappedMethod(timeDelta, stateContext, scriptInterface);
}

@wrapMethod(DriveEvents)
public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.CanHandleAutoDriveInput(scriptInterface) {
        this.HandleAutoDriveInput(scriptInterface);
    }
    wrappedMethod(timeDelta, stateContext, scriptInterface);
}
@wrapMethod(DriverCombatEvents)
public final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.CanHandleAutoDriveInput(scriptInterface) {
        this.HandleAutoDriveInput(scriptInterface);
    }
    wrappedMethod(timeDelta, stateContext, scriptInterface);
}

@addMethod(VehicleEventsTransition)
protected func HandleAutoDriveInput(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustReleased_AD(n"ToggleVehAutoDrive", 0.5)
    && !this.IsAutoDriveBlocked(scriptInterface) {
        this.RequestToggleAutoDrive(scriptInterface);
    };
    if scriptInterface.IsActionJustPressed(n"Accelerate")
    || scriptInterface.IsActionJustPressed(n"Decelerate")
    || scriptInterface.IsActionJustPressed(n"TurnX")
    || scriptInterface.IsActionJustPressed(n"Handbrake")
    // || scriptInterface.IsActionJustPressed(n"LeanFB")
    // || scriptInterface.IsActionJustPressed(n"RockFB")
    {
        this.RequestCancelAutoDrive(scriptInterface);
    };
}

@addMethod(StateGameScriptInterface)
public final func IsActionJustReleased_AD(actionName: CName, maxHeldTime: Float) -> Bool {
    return this.IsActionJustReleased(actionName) && this.GetActionPrevStateTime(actionName) < maxHeldTime;
}

@addMethod(VehicleEventsTransition)
protected final func RequestToggleAutoDrive(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.GetAutoDriveComponent(scriptInterface).ToggleAutoDrive();
}

@addMethod(VehicleEventsTransition)
protected final func RequestCancelAutoDrive(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.GetAutoDriveComponent(scriptInterface).CancelAutoDrive(false);
}

@wrapMethod(ExitingEventsBase)
protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CancelAutoDriveOnEnterExiting(stateContext, scriptInterface);
    wrappedMethod(stateContext, scriptInterface);
}

@addMethod(ExitingEventsBase)
protected func CancelAutoDriveOnEnterExiting(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RequestCancelAutoDrive(scriptInterface);
}

@wrapMethod(MinimapContainerController)
protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
    let result = wrappedMethod(player);
    AutoDriveSystem.GetInstance(player.GetGame()).Initialize(this);
    return result;
}

@wrapMethod(MinimapContainerController)
protected cb func OnPlayerDetach(player: ref<GameObject>) -> Bool {
    let result = wrappedMethod(player);
    AutoDriveSystem.GetInstance(player.GetGame()).Uninitialize();
    return result;
}

@addMethod(GameObject)
public final func GetAroundVehicles(range: Float) -> array<ref<VehicleObject>> {
    let searchQuery: TargetSearchQuery;
    searchQuery.testedSet = TargetingSet.Complete;
    searchQuery.maxDistance = range;
    searchQuery.searchFilter = TSF_Any(TSFMV.Obj_Device);
    searchQuery.filterObjectByDistance = range > 0.0;
    searchQuery.ignoreInstigator = true;
    searchQuery.includeSecondaryTargets = false;

    let targetParts: array<TS_TargetPartInfo>;
    GameInstance.GetTargetingSystem(this.GetGame()).GetTargetParts(this, searchQuery, targetParts);

    let targets: array<ref<VehicleObject>> = [];
    for targetingPart in targetParts {
        let targetingComponent = TS_TargetPartInfo.GetComponent(targetingPart);
        if !IsDefined(targetingComponent) {
        } else {
            let target = targetingComponent.GetEntity() as VehicleObject;
            if !IsDefined(target) {
            } else {
                if !ArrayContains(targets, target) {
                    ArrayPush(targets, target);
                };
            };
        };
    };
    return targets;
}

@addMethod(PreventionSystem)
public final func LockHeat_AD(value: Bool) -> Void {
    this.m_lockHeat_AD = value;
}

@addMethod(PreventionSystem)
public final func IsLockedHeat_AD() -> Bool {
    return this.m_lockHeat_AD;
}

@addField(PreventionSystem)
private let m_lockHeat_AD: Bool = false;

@wrapMethod(PreventionSystem)
private final func HeatPipeline(heatChangeReason: String) -> Void {
    if !this.m_lockHeat_AD {
        wrappedMethod(heatChangeReason);
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
    let result = wrappedMethod(newState);
    let vehicle = this.GetMountedVehicle();
    if IsDefined(vehicle) && IsDefined(vehicle.GetAutoDriveComponent()) {
        vehicle.GetAutoDriveComponent().OnCombatStateChanged(this.IsInCombat());
    }
    return result;
}

// ==== stolen car issue ====
@replaceMethod(VehicleComponent)
private final func StealVehicle(opt slotID: MountingSlotId) -> Void {
    let stealEvent: ref<StealVehicleEvent>;
    let vehicleHijackEvent: ref<VehicleHijackEvent>;
    let vehicle: wref<VehicleObject> = this.GetVehicle();
    if !IsDefined(vehicle) {
      return;
    };
    if IsNameValid(slotID.id) {
      vehicleHijackEvent = new VehicleHijackEvent();
      vehicleHijackEvent.driverAllowedToGetAggressive = Equals(slotID.id, n"seat_front_left");
      VehicleComponent.QueueEventToPassenger(vehicle.GetGame(), vehicle, slotID, vehicleHijackEvent);
    };
    stealEvent = new StealVehicleEvent();
    let evt: ref<Event> = stealEvent;
    if AutoDriveSystem.GetInstance(vehicle.GetGame()).GetSettings().forDev.enableWorkaroundForIssueOfStolenCar {
        // ISSUE: StealVehicleEvent を QueueEvent すると、なぜか AutoDrive ができなくなるので、別の Event を経由する.
        evt = new StealVehicleWrapEvent().Init(stealEvent);
    }
    vehicle.QueueEvent(evt);
}

public class StealVehicleWrapEvent extends Event {
    public func Init(wrapped: ref<StealVehicleEvent>) -> ref<StealVehicleWrapEvent> { this.wrapped = wrapped; return this; }
    public let wrapped: ref<StealVehicleEvent>;
}

@addMethod(VehicleObject)
protected cb func OnStealVehicleWrapEvent(evt: ref<StealVehicleWrapEvent>) -> Bool {
    this.OnStealVehicleEvent(evt.wrapped);
}
// ==== stolen car issue ====


@addField(GameObject)
protected let m_highlightData: ref<FocusForcedHighlightData>;

@addField(GameObject)
protected let m_highlightCancelID: DelayID;

public class HighlightCancelEvent extends Event {}

@addMethod(GameObject)
protected cb func OnHighlightCancelEvent_AD(evt: ref<HighlightCancelEvent>) -> Void {
    this.CancelHighlight_AD();
}

@addMethod(GameObject)
protected func CancelHighlight_AD() -> Void {
    let cancelEvt = new ForceVisionApperanceEvent();
    cancelEvt.forcedHighlight = this.m_highlightData;
    cancelEvt.apply = false;
    this.QueueEvent(cancelEvt);
    this.m_highlightData = null;
}

@addMethod(GameObject)
protected func QueueHighlight_AD(source: ref<GameObject>, revealed: Bool, highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> ref<FocusForcedHighlightData> {
    let highlightEvt = new ForceVisionApperanceEvent();
    let data = new FocusForcedHighlightData();
    data.sourceID = source.GetEntityID();
    data.sourceName = source.GetClassName();
    data.highlightType = highlightType;
    data.outlineType = outlineType;
    data.priority = EPriority.High;
    data.isRevealed = revealed;
    this.m_highlightData = data;
    highlightEvt.forcedHighlight = data;
    highlightEvt.apply = true;
    this.QueueEvent(highlightEvt);
    return data;
}

@addMethod(GameObject)
public func Highlight_AD(source: ref<GameObject>, revealed: Bool, highlightType: EFocusForcedHighlightType, outlineType: EFocusOutlineType) -> Void {
    if !IsDefined(this.m_highlightData){
        this.QueueHighlight_AD(source, revealed, highlightType, outlineType);
        this.m_highlightCancelID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new HighlightCancelEvent(), 1.0);
    } else {
        GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_highlightCancelID);
        if Equals(this.m_highlightData.highlightType, highlightType) && Equals(this.m_highlightData.outlineType, outlineType) && Equals(this.m_highlightData.isRevealed, revealed) {
            this.m_highlightCancelID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new HighlightCancelEvent(), 1.0);
        } else {
            this.CancelHighlight_AD();
            this.QueueHighlight_AD(source, revealed, highlightType, outlineType);
            this.m_highlightCancelID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new HighlightCancelEvent(), 1.0);
        }
    }
}
