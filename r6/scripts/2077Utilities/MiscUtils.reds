module Utils2077.MiscUtils

public class DelayDaemon extends DelayCallback {

    let gi: GameInstance;

    let delayID: DelayID;

    let isActive: Bool = false;

    let delay: Float = 1.00;

    let isAffectedByTimeDilation: Bool = false;

    func Start(gi: GameInstance, delay: Float, opt isAffectedByTimeDilation: Bool) -> Void {
        if this.IsActive() {
            return;
        };

        this.gi = gi;
        this.delay = delay;
        this.isAffectedByTimeDilation = isAffectedByTimeDilation;
        let delaySys = GameInstance.GetDelaySystem(gi);
        let cback_ID = delaySys.DelayCallback(this,
                                              delay,
                                              isAffectedByTimeDilation);
        this.delayID = cback_ID;
        this.isActive = true;
    };

    func Stop() -> Void {
        if !this.IsActive() {
            return;
        };

        let delaySys = GameInstance.GetDelaySystem(this.gi);
        delaySys.CancelCallback(this.delayID);
        this.isActive = false;
    };

    func IsActive() -> Bool {
        return this.isActive;
    };

    func Repeat() -> Void {
        if !this.IsActive() {
            return;
        };
        let delaySys = GameInstance.GetDelaySystem(this.gi);
        this.delayID = delaySys.DelayCallback(this,
                                              this.delay,
                                              this.isAffectedByTimeDilation);
    };
}

@addMethod(Vector4)
public static func Vector4To2(v4: Vector4) -> Vector2 {
    return new Vector2(v4.X, v4.Y);
};

@addMethod(Vector4)
public static func Vector3To2(v3: Vector3) -> Vector2 {
    return new Vector2(v3.X, v3.Y);
};

