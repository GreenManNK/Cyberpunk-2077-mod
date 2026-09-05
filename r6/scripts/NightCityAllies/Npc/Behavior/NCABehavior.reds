module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*
import NightCityAllies.Effect.*
import NightCityAllies.Util.*
import NightCityAllies.Persistence.*
import NightCityAllies.Event.*
import NightCityAllies.UI.*

public abstract class NCABehavior extends IScriptable {
    protected let m_npcHandle: ref<NpcHandle>;
    protected let m_isHeld: Bool;
    private let m_aiController: ref<AIHumanComponent>;
    private let m_command: ref<AICommand>;

    private let m_clipActor: ref<AnimationHandle>;
    private let m_clipPartnerHandle: ref<AnimationHandle>;
    private let m_clipPartner: wref<ScriptedPuppet>;
    private let m_clipPos: Vector4;
    private let m_clipRot: Quaternion;
    private let m_clipName: String;
    private let m_pendingClip: NCAAnimation;
    private let m_clipToken: Int32;

    private let m_partnerOffsetForward: Float;
    private let m_partnerOffsetRight: Float;
    private let m_partnerOffsetUp: Float;
    private let m_partnerOffsetYaw: Float;

    private let m_clipBinding: NCAWorkspotBinding;
    private let m_clipPartnerBinding: NCAWorkspotBinding;
    private let m_clipFreeCamera: Bool;

    // Routine layer - which routine is running and where it is up to. Empty when a bare clip plays.
    private let m_routine: ref<NCARoutine>;
    private let m_routineRunning: Bool;
    private let m_routineGroup: String;     // active sub-pose; only its clips are drawn while shuffling
    private let m_clipIndex: Int32;         // Linear playback only: how far along `animations` we are
    private let m_clipNextGroup: String;    // group the playing clip hands over to; empty = stay put
    private let m_routineToken: Int32;      // guards against a scheduled advance the routine moved past
    private let m_routineStartedAt: Float;  // real sim time the ROUTINE began, for the interrupt grace
    private let m_clipStartedAt: Float;     // real sim time the clip began
    private let m_clipDuration: Float;      // the clip's own length
    private let m_clipLead: Float;          // how far before its end the next clip was asked for
    private let m_askedAt: Float;           // real sim time the pending advance was booked
    private let m_requestedDelay: Float;    // what it was booked for, so lateness can be measured
    private let m_scheduleDebt: Float;      // accumulated scheduler lateness, still to be paid back

    private static func GetClipLead(duration: Float) -> Float {
        return duration * 0.5;
    }

    public func Attach(npcHandle: ref<NpcHandle>, aiController: ref<AIHumanComponent>) -> Void {
        this.m_npcHandle = npcHandle;
        this.m_aiController = aiController;
        this.OnAttach();
    }

    public func Detach() -> Void {
        this.OnDetach();

        this.StopRoutine();
        this.StopAnimation();

        this.m_npcHandle = null;
        this.m_aiController = null;
    }

    public func Tick(deltaTime: Float) -> Void {
        this.Update(deltaTime);
    }

// ============================================== Interaction hold =====================================================

    public func SetHold(held: Bool) -> Void {
        if Equals(this.m_isHeld, held) {
            return;
        }

        this.m_isHeld = held;

        if held {
            this.OnHold();
        } else {
            this.OnRelease();
        }
    }

    protected func OnHold() -> Void {}
    protected func OnRelease() -> Void {}

    public func GetName() -> String;
    public func GetText() -> String {
        return this.GetName();
    }

// =============================================== Menu options ========================================================
    public func GetSyncedRoutines() -> array<ref<NCARoutine>> {
        let empty: array<ref<NCARoutine>>;

        if !IsDefined(this.m_npcHandle) {
            return empty;
        }

        return NCA.Animation().GetSyncedRoutines(
            NCAAnimationSystem.StandingType(),
            this.m_npcHandle.GetRig(),
            NCA.Util().GetPlayerRig()
        );
    }

    public func PlaySyncedRoutine(routine: ref<NCARoutine>) -> Bool {
        if !IsDefined(routine) || !IsDefined(this.m_npcHandle) || !this.m_npcHandle.IsValid() {
            return false;
        }

        let entity = this.m_npcHandle.GetEntity();
        let player = NCA.Player();

        return this.StartRoutine(
            routine,
            entity.GetWorldPosition(),
            entity.GetWorldOrientation(),
            player
        );
    }

    public func GetTextColor() -> HDRColor {
        return new HDRColor(1.0, 1.0, 1.0, 1.0); //new HDRColor(0.2, 0.7, 0.8, 1.0)
    }
    public func Update(deltaTime: Float) -> Void;
    public func OnAttach() -> Void;
    public func OnDetach() -> Void;

// =================================================== Commands ========================================================

    protected func MoveTo(pos: Vector4, opt ignoreNavigation: Bool) -> Void {
        let command: ref<AIMoveToCommand> = new AIMoveToCommand();
        let spec = new AIPositionSpec();
        let wp: WorldPosition;
        WorldPosition.SetVector4(wp, pos);
        AIPositionSpec.SetWorldPosition(spec, wp);
        command.movementTarget   = spec;
        command.movementType     = moveMovementType.Walk;
        command.useStart         = true;
        command.useStop          = true;
        command.ignoreNavigation = ignoreNavigation;

        this.SendCommand(command);
    }

    protected func FollowTarget(target: wref<GameObject>, distance: Float, tolerance: Float, opt movementType: moveMovementType, opt matchSpeed: Bool) -> Void {
        let command: ref<AIFollowTargetCommand> = new AIFollowTargetCommand();
        command.target = target;
        command.desiredDistance = distance;
        command.tolerance = tolerance;
        command.lookAtTarget = target;
        command.matchSpeed = matchSpeed;
        command.stopWhenDestinationReached = false;
        command.teleport = false;
        command.movementType = movementType;

        this.SendCommand(command);
    }

    protected func HoldPosition() -> Void {
        let command: ref<AIHoldPositionCommand> = new AIHoldPositionCommand();
        command.duration = -1.0;
        command.ignoreInCombat = false;
        command.removeAfterCombat = false;
        command.alwaysUseStealth = true;

        this.SendCommand(command);
    }

    protected func SendCommand(command: ref<AICommand>, opt once: Bool) -> Void {
        this.CancelCommand();
        if !once {
            this.m_command = command;
        }
        this.m_aiController.SendCommand(command);
    }

    protected func HasCommand() -> Bool {
        return IsDefined(this.m_command);
    }

    protected func CancelCommand() -> Void {
        if (this.HasCommand()) {
            if Equals(this.m_command.state, AICommandState.Executing) {
                this.m_aiController.StopExecutingCommand(this.m_command, true);
            } else {
                this.m_aiController.CancelCommand(this.m_command);
            }

            this.m_command = null;
        }
    }

// =================================================== Routines ========================================================
    protected func StartRoutine(routine: ref<NCARoutine>, pos: Vector4, rot: Quaternion, partner: wref<ScriptedPuppet>) -> Bool {
        if !IsDefined(routine) || !routine.IsPlayable() {
            return false;
        }

        this.StopRoutine();
        this.CancelCommand();

        this.m_routine = routine;

        routine.OffsetAnchor(pos, rot, this.m_clipPos, this.m_clipRot);

        this.m_partnerOffsetForward = routine.partnerOffsetForward;
        this.m_partnerOffsetRight = routine.partnerOffsetRight;
        this.m_partnerOffsetUp = routine.partnerOffsetUp;
        this.m_partnerOffsetYaw = routine.partnerOffsetYaw;

        this.m_clipBinding = routine.ActorBinding();
        this.m_clipPartnerBinding = routine.PartnerBinding();
        this.m_clipFreeCamera = routine.freeCamera;

        this.m_clipPartner = partner;
        this.m_routineStartedAt = NCA.Util().Now();
        if this.IsPlayerPartner() {
            NCA.Context().isInInteraction = true;
        }

        this.m_routineGroup = routine.animations[0].group;
        this.m_clipNextGroup = "";
        this.m_clipIndex = 0;

        this.TriggerRoutineEffects(routine.entryEffects);

        let animation: NCAAnimation;
        let opened: Bool;
        if Equals(routine.playback, NCARoutinePlayback.Linear) {
            opened = routine.GetClipAt(0, animation);
        } else {
            opened = routine.GetRandomClip("", this.m_routineGroup, true, animation);
        }

        if !opened {
            NCA.CETLog("WARNING Routine " + NameToString(routine.tag) + " has "
                + IntToString(ArraySize(routine.animations)) + " clips but opened none, playback "
                + NCARoutine.PlaybackToString(routine.playback));
            this.StopRoutine();
            return false;
        }

        this.m_routineRunning = true;
        this.PlayRoutineClip(animation);

        if IsDefined(this.m_npcHandle) {
            if this.BlocksReactions() {
                this.m_npcHandle.StopLookAtPlayer();
            }

            NCA.Events().OnCompanionStateChanged(this.m_npcHandle);
        }

        return true;
    }

    public func AdvanceRoutine(token: Int32) -> Void {
        if token != this.m_routineToken || !this.m_routineRunning {
            return;
        }

        this.m_scheduleDebt += (NCA.Util().Now() - this.m_askedAt) - this.m_requestedDelay;

        if Equals(this.m_routine.playback, NCARoutinePlayback.Linear) {
            this.AdvanceLinear();
            return;
        }

        let handedOver: Bool = false;
        if IsStringValid(this.m_clipNextGroup) {
            this.m_routineGroup = this.m_clipNextGroup;
            this.m_clipNextGroup = "";
            handedOver = true;
        }

        if !handedOver
            && Equals(this.m_routine.playback, NCARoutinePlayback.LinearRandomized)
            && this.m_routine.IsTerminalGroup(this.m_routineGroup) {
            this.FinishRoutine();
            return;
        }

        this.ShuffleClip(handedOver);
    }

    private func AdvanceLinear() -> Void {
        this.m_clipIndex += 1;

        let animation: NCAAnimation;
        if !this.m_routine.GetClipAt(this.m_clipIndex, animation) {
            this.FinishRoutine();
            return;
        }

        this.PlayRoutineClip(animation);
    }

    private func FinishRoutine() -> Void {
        let remaining: Float = (this.m_clipStartedAt + this.m_clipDuration) - NCA.Util().Now();
        if remaining > NCAConstants.MinBooking() {
            this.m_routineToken += 1;
            GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(
                NCARoutineFinishDelayCallback.Create(this, this.m_routineToken),
                remaining,
                false
            );
            return;
        }

        this.EndFinishedRoutine();
    }

    public func FinishRoutineNow(token: Int32) -> Void {
        if token != this.m_routineToken || !this.m_routineRunning {
            return;
        }

        this.EndFinishedRoutine();
    }

    private func EndFinishedRoutine() -> Void {
        this.EndRoutine();
        this.RoutineEnded();
        this.OnRoutineFinished();
    }

    private func RoutineEnded() -> Void {
        this.OnRoutineEnded();

        NCA.InteractionMenu().UpdateHub();
    }

    protected func OnRoutineFinished() -> Void {}

    protected func OnRoutineEnded() -> Void {}

    private func ScheduleRoutineAdvance(delay: Float) -> Void {
        this.m_routineToken += 1;

        let corrected: Float = MaxF(delay - this.m_scheduleDebt, NCAConstants.MinBooking());
        this.m_scheduleDebt -= (delay - corrected);   // only drain what was actually applied

        this.m_askedAt = NCA.Util().Now();
        this.m_requestedDelay = corrected;

        GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(
            NCARoutineAdvanceDelayCallback.Create(this, this.m_routineToken),
            corrected,
            false
        );
    }

    protected func EndRoutine() -> Void {
        this.StopRoutine();
    }

    protected func StopRoutine() -> Void {
        if !IsDefined(this.m_routine) {
            return;
        }

        this.TriggerRoutineEffects(this.m_routine.exitEffects);

        if this.IsPlayerPartner() {
            NCA.Context().isInInteraction = false;
        }

        this.m_routine = null;
        this.m_routineRunning = false;
        this.m_routineGroup = "";
        this.m_clipIndex = 0;
        this.m_clipNextGroup = "";
        this.m_clipDuration = 0.0;
        this.m_clipLead = 0.0;
        this.m_scheduleDebt = 0.0;
        this.m_routineToken += 1;

        this.StopAnimation();

        if IsDefined(this.m_npcHandle) {
            NCA.Events().OnCompanionStateChanged(this.m_npcHandle);
        }
    }

    protected func HasRoutine() -> Bool {
        return this.m_routineRunning;
    }

    public func BlocksReactions() -> Bool {
        return this.m_routineRunning && IsDefined(this.m_routine) && this.m_routine.blockReactions;
    }

    private func IsPlayerPartner() -> Bool {
        return IsDefined(this.m_clipPartner)
            && this.m_clipPartner == NCA.Player();
    }

    public func IsPerformingWithPlayer() -> Bool {
        return this.m_routineRunning
            && this.IsPlayerPartner()
            && (NCA.Util().Now() - this.m_routineStartedAt) >= NCAConstants.InterruptGrace();
    }

    public func StopPerformanceWithPlayer() -> Bool {
        if !this.IsPerformingWithPlayer() {
            return false;
        }

        this.EndRoutine();
        this.RoutineEnded();
        return true;
    }

    protected func IsRoutineFinished() -> Bool {
        return !this.m_routineRunning;
    }

    protected func GetRoutine() -> ref<NCARoutine> {
        return this.m_routine;
    }

    private func ShuffleClip(avoidHandover: Bool) -> Void {
        let animation: NCAAnimation;
        if !this.m_routine.GetRandomClip(this.m_clipName, this.m_routineGroup, avoidHandover, animation)
            || Equals(animation.animation, this.m_clipName) {
            return; // nothing booked, so the workspot simply keeps looping what is already playing
        }

        this.PlayRoutineClip(animation);
    }

// ==================================================== Clips ==========================================================
    protected func PlayAnimation(animation: NCAAnimation, binding: NCAWorkspotBinding, partnerBinding: NCAWorkspotBinding,
                                 pos: Vector4, rot: Quaternion, partner: wref<ScriptedPuppet>,
                                 opt partnerForward: Float, opt partnerRight: Float, opt partnerUp: Float, opt partnerYaw: Float) -> Bool {
        if !IsStringValid(animation.animation) && !IsStringValid(binding.workspot) {
            return false;
        }

        this.CancelCommand();

        this.m_clipPos = pos;
        this.m_clipRot = rot;
        this.m_clipPartner = partner;

        this.m_partnerOffsetForward = partnerForward;
        this.m_partnerOffsetRight = partnerRight;
        this.m_partnerOffsetUp = partnerUp;
        this.m_partnerOffsetYaw = partnerYaw;

        this.m_clipBinding = binding;
        this.m_clipPartnerBinding = partnerBinding;
        this.m_clipFreeCamera = false;

        this.MoveToClip(animation);
        return true;
    }

    protected func StopAnimation() -> Void {
        if IsDefined(this.m_clipActor) {
            this.m_clipActor.Cancel();
            this.m_clipActor = null;
        }

        if IsDefined(this.m_clipPartnerHandle) {
            this.m_clipPartnerHandle.Cancel();
            this.m_clipPartnerHandle = null;
        }

        this.m_clipPartner = null;
        this.m_clipName = "";
        this.m_clipToken += 1;
    }

    protected func HasAnimation() -> Bool {
        return IsDefined(this.m_clipActor) || IsStringValid(this.m_clipName);
    }

    private func PlayRoutineClip(animation: NCAAnimation) -> Void {
        this.m_clipNextGroup = animation.nextGroup;

        let respawned: Bool = this.MoveToClip(animation);
        let startsIn: Float = respawned ? NCAConstants.WorkspotHandoverDelay() : this.m_clipLead;
        let lead: Float = NCABehavior.GetClipLead(animation.duration);
        let delay: Float = MaxF(startsIn + animation.duration - lead, NCAConstants.MinBooking());

        this.m_clipStartedAt = NCA.Util().Now() + startsIn;
        this.m_clipDuration = animation.duration;
        this.m_clipLead = lead;

        if animation.duration > 0.0 {
            this.ScheduleRoutineAdvance(delay);
        } else {
            this.m_routineToken += 1;
        }
    }

    private func MoveToClip(animation: NCAAnimation) -> Bool {
        this.m_clipName = animation.animation;

        if this.TryJumpTo(animation) {
            return false;
        }

        if IsDefined(this.m_clipActor) {
            this.m_clipActor.Cancel();
            this.m_clipActor = null;
        }

        if IsDefined(this.m_clipPartnerHandle) {
            this.m_clipPartnerHandle.Cancel();
            this.m_clipPartnerHandle = null;
        }

        this.m_clipToken += 1;
        this.m_pendingClip = animation;

        GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(
            NCASpawnClipDelayCallback.Create(this, this.m_clipToken),
            NCAConstants.WorkspotHandoverDelay(),
            false
        );

        return true;
    }

    private func TryJumpTo(animation: NCAAnimation) -> Bool {
        if !IsDefined(this.m_clipActor) || !this.m_clipActor.CanJumpTo(animation) {
            return false;
        }

        let wantsPartner = IsStringValid(animation.partnerAnimation) && IsDefined(this.m_clipPartner);
        if !Equals(wantsPartner, IsDefined(this.m_clipPartnerHandle)) {
            return false;
        }

        if wantsPartner && !this.m_clipPartnerHandle.CanJumpTo(animation) {
            return false;
        }

        this.m_clipActor.JumpTo(animation.animation);

        if wantsPartner {
            this.m_clipPartnerHandle.JumpTo(animation.partnerAnimation);
        }

        return true;
    }

    public func SpawnPendingClip(token: Int32) -> Void {
        if token != this.m_clipToken || !IsDefined(this.m_npcHandle) {
            return; // superseded, or the behavior went away while we waited
        }

        let animation: NCAAnimation = this.m_pendingClip;

        this.m_clipActor = AnimationHandle.Create(this.m_npcHandle, animation.animation, this.m_clipBinding);
        this.m_clipActor.PlayAt(this.m_clipPos, this.m_clipRot);

        if !IsStringValid(animation.partnerAnimation) || !IsDefined(this.m_clipPartner) {
            return;
        }

        let partnerPos: Vector4;
        let partnerRot: Quaternion;

        NCARoutine.Place(this.m_clipPos, this.m_clipRot,
            this.m_partnerOffsetForward, this.m_partnerOffsetRight,
            this.m_partnerOffsetUp, this.m_partnerOffsetYaw,
            partnerPos, partnerRot);

        this.m_clipPartnerHandle = AnimationHandle.CreateForPartner(this.m_clipPartner, animation.partnerAnimation, this.m_clipPartnerBinding, this.m_clipFreeCamera);
        this.m_clipPartnerHandle.PlayAt(partnerPos, partnerRot);
    }

    private func TriggerRoutineEffects(effects: array<NCARoutineEffect>) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(effects) {
            NCA.Effect().Trigger(effects[i].id, this.m_npcHandle.recordID, effects[i].param);
            i += 1;
        }
    }
}

public class NCASpawnClipDelayCallback extends DelayCallback {
    let m_behavior: ref<NCABehavior>;
    let m_token: Int32;

    public static func Create(behavior: ref<NCABehavior>, token: Int32) -> ref<NCASpawnClipDelayCallback> {
        let created: ref<NCASpawnClipDelayCallback> = new NCASpawnClipDelayCallback();
        created.m_behavior = behavior;
        created.m_token = token;
        return created;
    }

    public func Call() -> Void {
        if IsDefined(this.m_behavior) {
            this.m_behavior.SpawnPendingClip(this.m_token);
        }
    }
}

public class NCARoutineFinishDelayCallback extends DelayCallback {
    let m_behavior: ref<NCABehavior>;
    let m_token: Int32;

    public static func Create(behavior: ref<NCABehavior>, token: Int32) -> ref<NCARoutineFinishDelayCallback> {
        let created: ref<NCARoutineFinishDelayCallback> = new NCARoutineFinishDelayCallback();
        created.m_behavior = behavior;
        created.m_token = token;
        return created;
    }

    public func Call() -> Void {
        if IsDefined(this.m_behavior) {
            this.m_behavior.FinishRoutineNow(this.m_token);
        }
    }
}

public class NCARoutineAdvanceDelayCallback extends DelayCallback {
    let m_behavior: ref<NCABehavior>;
    let m_token: Int32;

    public static func Create(behavior: ref<NCABehavior>, token: Int32) -> ref<NCARoutineAdvanceDelayCallback> {
        let created: ref<NCARoutineAdvanceDelayCallback> = new NCARoutineAdvanceDelayCallback();
        created.m_behavior = behavior;
        created.m_token = token;
        return created;
    }

    public func Call() -> Void {
        if IsDefined(this.m_behavior) {
            this.m_behavior.AdvanceRoutine(this.m_token);
        }
    }
}
