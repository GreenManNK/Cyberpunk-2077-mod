module NightCityAllies.Npc.Behavior

import NightCityAllies.*

enum NCAApproachStep {
    Move = 0,
    Walking = 1,
    Arrived = 2,
    Failed = 3,
}

public class NCAApproach {
    private let m_targets: array<Vector4>;
    private let m_direct: array<Bool>;
    private let m_arrivalDistance: array<Float>;
    private let m_giveUpTime: array<Float>;

    private let m_index: Int32;
    private let m_started: Bool;
    private let m_legTime: Float;

    public static func Create() -> ref<NCAApproach> {
        return new NCAApproach();
    }

    public func AddLeg(target: Vector4, direct: Bool, arrivalDistance: Float, giveUpTime: Float) -> Void {
        ArrayPush(this.m_targets, target);
        ArrayPush(this.m_direct, direct);
        ArrayPush(this.m_arrivalDistance, arrivalDistance);
        ArrayPush(this.m_giveUpTime, giveUpTime);
    }

    public func AddPathNodes(nodes: array<Vector4>, arrivalDistance: Float, giveUpTime: Float) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(nodes) {
            this.AddLeg(nodes[i], i > 0, arrivalDistance, giveUpTime);
            i += 1;
        };
    }

    public func GetTarget() -> Vector4 {
        return this.m_targets[this.m_index];
    }

    public func IsDirect() -> Bool {
        return this.m_direct[this.m_index];
    }

    public func IsOnFinalLeg() -> Bool {
        return this.m_index == ArraySize(this.m_targets) - 1;
    }

    public func Update(npcPos: Vector4, deltaTime: Float) -> NCAApproachStep {
        if ArraySize(this.m_targets) == 0 {
            return NCAApproachStep.Arrived;
        };

        if !this.m_started {
            this.m_started = true;
            return this.OpenLeg(0);
        };

        if Vector4.Distance(npcPos, this.m_targets[this.m_index]) < this.m_arrivalDistance[this.m_index] {
            if this.IsOnFinalLeg() {
                return NCAApproachStep.Arrived;
            };

            return this.OpenLeg(this.m_index + 1);
        };

        this.m_legTime += deltaTime;
        if this.m_legTime >= this.m_giveUpTime[this.m_index] {
            return NCAApproachStep.Failed;
        };

        return NCAApproachStep.Walking;
    }

    private func OpenLeg(index: Int32) -> NCAApproachStep {
        this.m_index = index;
        this.m_legTime = 0.0;
        return NCAApproachStep.Move;
    }
}
