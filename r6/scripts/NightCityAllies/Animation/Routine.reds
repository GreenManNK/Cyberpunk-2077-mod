module NightCityAllies.Animation

import NightCityAllies.*
import NightCityAllies.Persistence.*

// TODO generalize
public struct NCARoutineEffect {
    public let id: CName;
    public let param: String;
}

enum NCARoutinePlayback {
    InfiniteRandomized = 0, // infinitely shuffle between groups
    LinearRandomized = 1,   // shuffle groups but transition sequantially
    Linear = 2,             // play through the list with no randomization
}

public struct NCAWorkspotBinding {
    public let workspot: String;
    public let actorComp: String;
    public let deviceComp: String;
    public let syncSlot: String;
}

public struct NCAAnimation {
    public let animation: String;
    public let duration: Float;
    public let partnerAnimation: String;
    public let group: String; // eg. "sitting"
    public let nextGroup: String; // eg. "sitting_eating"
}

public class NCAWorkspotDefaults {
    public static func Workspot() -> String = "nca\\workspot\\nca_workspot.ent";
    public static func ActorComp() -> CName = n"nca_workspot_base";
    public static func DeviceComp() -> CName = n"workspot";
}

public class NCARoutine {
    public let type: CName;
    public let tag: CName;
    public let rig: String;
    public let partnerRig: String;
    public let label: CName;
    public let icon: String;
    public let entryEffects: array<NCARoutineEffect>;
    public let exitEffects: array<NCARoutineEffect>;
    public let animations: array<NCAAnimation>;

    public let workspot: String;
    public let actorComp: String;
    public let deviceComp: String;
    public let syncSlot: String;
    public let partnerWorkspot: String;
    public let partnerActorComp: String;
    public let partnerDeviceComp: String;
    public let partnerSyncSlot: String;

    public let offsetForward: Float;
    public let offsetRight: Float;
    public let offsetUp: Float;
    public let offsetYaw: Float;
    public let partnerOffsetForward: Float;
    public let partnerOffsetRight: Float;
    public let partnerOffsetUp: Float;
    public let partnerOffsetYaw: Float;
    public let playback: NCARoutinePlayback;
    public let freeCamera: Bool;
    public let blockReactions: Bool;

    public static func Create(tag: CName, rig: String, partnerRig: String, label: CName, icon: String) -> ref<NCARoutine> {
        let routine = new NCARoutine();
        routine.tag = tag;
        routine.rig = rig;
        routine.partnerRig = partnerRig;
        routine.label = label;
        routine.icon = icon;
        return routine;
    }

    public static func PlaybackFromString(name: String) -> NCARoutinePlayback {
        switch name {
            case "linear": return NCARoutinePlayback.Linear;
            case "linear_randomized": return NCARoutinePlayback.LinearRandomized;
            case "infinite_randomized": return NCARoutinePlayback.InfiniteRandomized;
        };
        return NCARoutinePlayback.InfiniteRandomized;
    }

    public static func PlaybackToString(playback: NCARoutinePlayback) -> String {
        switch playback {
            case NCARoutinePlayback.Linear: return "linear";
            case NCARoutinePlayback.LinearRandomized: return "linear_randomized";
        };
        return "infinite_randomized";
    }

    public func IsFinite() -> Bool {
        return !Equals(this.playback, NCARoutinePlayback.InfiniteRandomized);
    }

    public func SetOffset(forward: Float, right: Float, up: Float, yaw: Float) -> Void {
        this.offsetForward = forward;
        this.offsetRight = right;
        this.offsetUp = up;
        this.offsetYaw = yaw;
    }

    public func SetWorkspot(workspot: String, actorComp: String, deviceComp: String, syncSlot: String) -> Void {
        this.workspot = workspot;
        this.actorComp = actorComp;
        this.deviceComp = deviceComp;
        this.syncSlot = syncSlot;
    }

    public func SetPartnerWorkspot(workspot: String, actorComp: String, deviceComp: String, syncSlot: String) -> Void {
        this.partnerWorkspot = workspot;
        this.partnerActorComp = actorComp;
        this.partnerDeviceComp = deviceComp;
        this.partnerSyncSlot = syncSlot;
    }

    public func ActorBinding() -> NCAWorkspotBinding {
        let binding: NCAWorkspotBinding;
        binding.workspot = this.workspot;
        binding.actorComp = this.actorComp;
        binding.deviceComp = this.deviceComp;
        binding.syncSlot = this.syncSlot;
        return binding;
    }

    public func PartnerBinding() -> NCAWorkspotBinding {
        let binding: NCAWorkspotBinding;

        if IsStringValid(this.partnerWorkspot) {
            binding.workspot = this.partnerWorkspot;
            binding.actorComp = this.partnerActorComp;
            binding.deviceComp = this.partnerDeviceComp;
        } else {
            binding.workspot = this.workspot;
            binding.actorComp = this.actorComp;
            binding.deviceComp = this.deviceComp;
        }

        binding.syncSlot = this.partnerSyncSlot;
        return binding;
    }

    public func HasWorkspot() -> Bool {
        return IsStringValid(this.workspot)
            || IsStringValid(this.syncSlot)
            || IsStringValid(this.partnerWorkspot)
            || IsStringValid(this.partnerSyncSlot);
    }

    public func SetPartnerOffset(forward: Float, right: Float, up: Float, yaw: Float) -> Void {
        this.partnerOffsetForward = forward;
        this.partnerOffsetRight = right;
        this.partnerOffsetUp = up;
        this.partnerOffsetYaw = yaw;
    }

    public func HasOffset() -> Bool {
        return this.offsetForward != 0.0
            || this.offsetRight != 0.0
            || this.offsetUp != 0.0
            || this.offsetYaw != 0.0
            || this.partnerOffsetForward != 0.0
            || this.partnerOffsetRight != 0.0
            || this.partnerOffsetUp != 0.0
            || this.partnerOffsetYaw != 0.0;
    }

    public static func Place(anchorPos: Vector4, anchorRot: Quaternion, forward: Float, right: Float, up: Float, yaw: Float,
                              out pos: Vector4, out rot: Quaternion) -> Void {
        pos = anchorPos
            + Quaternion.GetForward(anchorRot) * forward
            + Quaternion.GetRight(anchorRot) * right
            + Quaternion.GetUp(anchorRot) * up;

        let angles: EulerAngles = anchorRot.ToEulerAngles();
        angles.Yaw = angles.Yaw + yaw;
        rot = EulerAngles.ToQuat(angles);
    }

    // Move to where the routine actually wants to be performed
    public func OffsetAnchor(anchorPos: Vector4, anchorRot: Quaternion, out pos: Vector4, out rot: Quaternion) -> Void {
        NCARoutine.Place(anchorPos, anchorRot,
            this.offsetForward, this.offsetRight, this.offsetUp, this.offsetYaw,
            pos, rot);
    }

    public func AddAnimation(animation: NCAAnimation) -> Void {
        ArrayPush(this.animations, animation);
    }

    public func AddEntryEffect(effect: NCARoutineEffect) -> Void {
        ArrayPush(this.entryEffects, effect);
    }

    public func AddExitEffect(effect: NCARoutineEffect) -> Void {
        ArrayPush(this.exitEffects, effect);
    }

    public func ClearAnimations() -> Void {
        ArrayClear(this.animations);
    }

    public func IsSolo() -> Bool {
        return !IsStringValid(this.partnerRig);
    }

    public func IsSynced() -> Bool {
        return IsStringValid(this.partnerRig);
    }

    public func IsPlayable() -> Bool {
        return ArraySize(this.animations) > 0;
    }

    public func IsTerminalGroup(group: String) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.animations) {
            if Equals(this.animations[i].group, group)
                && IsStringValid(this.animations[i].nextGroup) {
                return false;
            }
            i += 1;
        };
        return true;
    }

    // TODO naming / check if orphaned
    public func GetClipAt(index: Int32, out animation: NCAAnimation) -> Bool {
        if index < 0 || index >= ArraySize(this.animations) {
            return false;
        }

        animation = this.animations[index];
        return true;
    }

    public func GetRandomClip(exclude: String, group: String, avoidHandover: Bool, out animation: NCAAnimation) -> Bool {
        let pool: array<Int32> = this.CollectForGroup(group);

        if ArraySize(pool) == 0 {
            pool = this.CollectAll();
        }

        if ArraySize(pool) == 0 {
            return false;
        }

        pool = this.Prefer(pool, exclude, avoidHandover);

        animation = this.animations[pool[RandRange(0, ArraySize(pool))]];
        return true;
    }

    private func Prefer(pool: array<Int32>, exclude: String, avoidHandover: Bool) -> array<Int32> {
        let result: array<Int32> = pool;

        // not the clip already playing
        let notCurrent: array<Int32>;
        let i: Int32 = 0;
        while i < ArraySize(result) {
            if !Equals(this.animations[result[i]].animation, exclude) {
                ArrayPush(notCurrent, result[i]);
            }
            i += 1;
        }
        if ArraySize(notCurrent) > 0 {
            result = notCurrent;
        }

        if !avoidHandover {
            return result;
        }

        // not a clip that would leave this group again straight away
        let staying: array<Int32>;
        i = 0;
        while i < ArraySize(result) {
            if !IsStringValid(this.animations[result[i]].nextGroup) {
                ArrayPush(staying, result[i]);
            }
            i += 1;
        }
        if ArraySize(staying) > 0 {
            result = staying;
        }

        return result;
    }

    private func CollectForGroup(group: String) -> array<Int32> {
        let result: array<Int32>;
        let i: Int32 = 0;
        while i < ArraySize(this.animations) {
            if Equals(this.animations[i].group, group) {
                ArrayPush(result, i);
            }
            i += 1;
        }
        return result;
    }

    private func CollectAll() -> array<Int32> {
        let result: array<Int32>;
        let i: Int32 = 0;
        while i < ArraySize(this.animations) {
            ArrayPush(result, i);
            i += 1;
        }
        return result;
    }

    public func GetGroups() -> array<String> {
        let result: array<String>;

        let i: Int32 = 0;
        while i < ArraySize(this.animations) {
            let names: array<String>;
            ArrayPush(names, this.animations[i].group);
            ArrayPush(names, this.animations[i].nextGroup);

            let j: Int32 = 0;
            while j < ArraySize(names) {
                if IsStringValid(names[j]) && !ArrayContains(result, names[j]) {
                    ArrayPush(result, names[j]);
                }
                j += 1;
            }
            i += 1;
        }

        return result;
    }
}
