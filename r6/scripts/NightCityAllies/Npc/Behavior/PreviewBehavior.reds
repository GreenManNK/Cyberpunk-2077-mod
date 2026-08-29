module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class NCAPreviewBehavior extends NCABehavior {
    public func GetName() -> String = "Preview";

    public func GetText() -> String {
        return "Preview";
    }

    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.35, 0.8, 1.0, 1.0);
    }

    public func GetSyncedRoutines() -> array<ref<NCARoutine>> {
        let empty: array<ref<NCARoutine>>;
        return empty;
    }

    public static func Create() -> ref<NCAPreviewBehavior> {
        return new NCAPreviewBehavior();
    }

    public func OnAttach() -> Void {
        this.CancelCommand();
    }

    public func OnDetach() -> Void {}

    public func Update(deltaTime: Float) -> Void {}
}

public class NCAPreviewRoutineBehavior extends NCAPreviewBehavior {
    public func GetName() -> String = "PreviewRoutine";

    private let m_routine: ref<NCARoutine>;
    private let m_partner: wref<ScriptedPuppet>;
    private let m_pos: Vector4;
    private let m_rot: Quaternion;

    public func GetText() -> String {
        return "Preview: " + NameToString(this.m_routine.tag);
    }

    public static func Create(routine: ref<NCARoutine>, pos: Vector4, rot: Quaternion, partner: wref<ScriptedPuppet>) -> ref<NCAPreviewRoutineBehavior> {
        let behavior = new NCAPreviewRoutineBehavior();
        behavior.m_routine = routine;
        behavior.m_partner = partner;
        behavior.m_pos = pos;
        behavior.m_rot = rot;
        return behavior;
    }

    public func OnAttach() -> Void {
        this.StartRoutine(this.m_routine, this.m_pos, this.m_rot, this.m_partner);
    }

    // A finite routine previewed once and stopped would leave the author looking at a frozen pose,
    // which says nothing about what they are authoring. So the preview - and only the preview - runs
    // it again. An InfiniteRandomized routine never gets here, since it never finishes.
    // TODO not do this
    protected func OnRoutineFinished() -> Void {
        this.StartRoutine(this.m_routine, this.m_pos, this.m_rot, this.m_partner);
    }

    public func Update(deltaTime: Float) -> Void {}
}

public class NCAPreviewAnimationBehavior extends NCAPreviewBehavior {
    public func GetName() -> String = "PreviewAnimation";

    private let m_animation: NCAAnimation;
    private let m_partner: wref<ScriptedPuppet>;
    private let m_pos: Vector4;
    private let m_rot: Quaternion;

    private let m_partnerForward: Float;
    private let m_partnerRight: Float;
    private let m_partnerUp: Float;
    private let m_partnerYaw: Float;

    private let m_binding: NCAWorkspotBinding;
    private let m_partnerBinding: NCAWorkspotBinding;

    public func GetText() -> String {
        return "Preview: " + this.m_animation.animation;
    }

    public static func Create(animation: NCAAnimation, binding: NCAWorkspotBinding, partnerBinding: NCAWorkspotBinding,
                              pos: Vector4, rot: Quaternion, partner: wref<ScriptedPuppet>,
                              opt partnerForward: Float, opt partnerRight: Float, opt partnerUp: Float, opt partnerYaw: Float) -> ref<NCAPreviewAnimationBehavior> {
        let behavior = new NCAPreviewAnimationBehavior();
        behavior.m_animation = animation;
        behavior.m_binding = binding;
        behavior.m_partnerBinding = partnerBinding;
        behavior.m_partner = partner;
        behavior.m_pos = pos;
        behavior.m_rot = rot;
        behavior.m_partnerForward = partnerForward;
        behavior.m_partnerRight = partnerRight;
        behavior.m_partnerUp = partnerUp;
        behavior.m_partnerYaw = partnerYaw;
        return behavior;
    }

    public func OnAttach() -> Void {
        this.PlayAnimation(this.m_animation, this.m_binding, this.m_partnerBinding,
            this.m_pos, this.m_rot, this.m_partner,
            this.m_partnerForward, this.m_partnerRight, this.m_partnerUp, this.m_partnerYaw);
    }

    public func Update(deltaTime: Float) -> Void {}
}
