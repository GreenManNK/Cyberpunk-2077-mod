module NightCityAllies.Animation

import NightCityAllies.*
import NightCityAllies.Persistence.*

public class NCAAnimationSystem extends ScriptableSystem {
    private let m_animationSets: array<ref<NCAAnimationSet>>;

    // set for synced routines that need no interaction point
    public static func StandingType() -> CName = n"standing";

    public func RegisterAnimationSet(type: CName) -> Void {
        if this.GetAnimationSetIndex(type) >= 0 {
            return;
        }
        ArrayPush(this.m_animationSets, NCAAnimationSet.Create(type));
    }

    public func GetAnimationSet(type: CName) -> ref<NCAAnimationSet> {
        let index = this.GetAnimationSetIndex(type);
        if index >= 0 {
            return this.m_animationSets[index];
        }
        return null;
    }

// ================================================ Registration =======================================================

    public func RegisterRoutine(type: CName, tag: CName, rig: String, partnerRig: String, label: CName, icon: String) -> ref<NCARoutine> {
        this.RegisterAnimationSet(type);
        let animSet = this.GetAnimationSet(type);

        let existing = animSet.GetRoutine(tag);
        if IsDefined(existing) {
            return existing;
        }

        let routine = NCARoutine.Create(tag, rig, partnerRig, label, icon);
        routine.type = type;
        animSet.AddRoutine(routine);
        return routine;
    }

    public func RegisterRoutineString(type: String, tag: String, rig: String, partnerRig: String, label: String, icon: String, freeCamera: Bool, opt blockReactions: Bool) -> Void {
        let routine = this.RegisterRoutine(StringToName(type), StringToName(tag), rig, partnerRig, StringToName(label), icon);
        routine.freeCamera = freeCamera;
        routine.blockReactions = blockReactions;
    }

    public func RegisterRoutineOffsetString(type: String, routineTag: String,
                                            forward: Float, right: Float, up: Float, yaw: Float,
                                            partnerForward: Float, partnerRight: Float, partnerUp: Float, partnerYaw: Float) -> Void {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            NCA.CETLog("ERROR Routine not found: " + routineTag + " in set " + type);
            return;
        }

        if routine.HasOffset() {
            return;
        }

        routine.SetOffset(forward, right, up, yaw);
        routine.SetPartnerOffset(partnerForward, partnerRight, partnerUp, partnerYaw);
    }

    public func RegisterRoutineWorkspotString(type: String, routineTag: String,
                                              workspot: String, actorComp: String, deviceComp: String, syncSlot: String,
                                              partnerWorkspot: String, partnerActorComp: String, partnerDeviceComp: String, partnerSyncSlot: String) -> Void {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            NCA.CETLog("ERROR Routine not found: " + routineTag + " in set " + type);
            return;
        }

        if routine.HasWorkspot() {
            return;
        }

        routine.SetWorkspot(workspot, actorComp, deviceComp, syncSlot);
        routine.SetPartnerWorkspot(partnerWorkspot, partnerActorComp, partnerDeviceComp, partnerSyncSlot);
    }

	// TODO add to register routine / check if theres any occasion where its needed seperate
    public func RegisterRoutinePlaybackString(type: String, routineTag: String, playback: String) -> Void {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            NCA.CETLog("ERROR Routine not found: " + routineTag + " in set " + type);
            return;
        }

        if routine.IsFinite() {
            return;
        }

        routine.playback = NCARoutine.PlaybackFromString(playback);
    }

    public func RegisterRoutineAnimationString(type: String, routineTag: String, animation: String, duration: Float, partnerAnimation: String, group: String, nextGroup: String) -> Void {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            NCA.CETLog("ERROR Routine not found: " + routineTag + " in set " + type);
            return;
        }

        routine.AddAnimation(NCAAnimation(
            animation,
            duration,
            partnerAnimation,
            group,
            nextGroup
        ));
    }

    public func RegisterRoutineEffectString(type: String, routineTag: String, isExit: Bool, effectId: String, param: String) -> Void {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            NCA.CETLog("ERROR Routine not found: " + routineTag + " in set " + type);
            return;
        }

        let effect: NCARoutineEffect;
        effect.id = StringToName(effectId);
        effect.param = param;

        if isExit {
            routine.AddExitEffect(effect);
        } else {
            routine.AddEntryEffect(effect);
        }
    }

// =================================================== Lookup ==========================================================

    public func GetRoutine(type: CName, tag: CName) -> ref<NCARoutine> {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            return null;
        }
        return animSet.GetRoutine(tag);
    }

    // Whether this NPC can use an interaction point of this type at all. PickInteraction drops
    // candidates that fail this rather than walking a companion to a spot they cannot perform.
    public func HasSoloRoutineForRig(type: CName, rig: String) -> Bool {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            return false;
        }
        return animSet.HasSoloRoutineForRig(rig);
    }

    public func GetSoloRoutine(type: CName, rig: String, out routine: ref<NCARoutine>) -> Bool {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            return false;
        }
        return animSet.GetRandomSoloRoutineForRig(rig, routine);
    }

    public func GetSyncedRoutines(type: CName, rig: String, partnerRig: String) -> array<ref<NCARoutine>> {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            let empty: array<ref<NCARoutine>>;
            return empty;
        }
        return animSet.GetSyncedRoutinesForRigs(rig, partnerRig);
    }

// ============================================= Read back (tooling) ===================================================
// Strings rather than CNames throughout: a CName crossing into Lua arrives as an object and silently
// fails String comparison, which the editor would trip over. Indices are 0 based.

    public func GetAnimationTypeNames() -> array<String> {
        let result: array<String>;
        let i: Int32 = 0;
        while i < ArraySize(this.m_animationSets) {
            ArrayPush(result, NameToString(this.m_animationSets[i].type));
            i += 1;
        }
        return result;
    }

    // Only the types that can actually be performed by this rig, solo.
    public func GetAnimationTypeNamesForRig(rig: String) -> array<String> {
        let result: array<String>;
        let i: Int32 = 0;
        while i < ArraySize(this.m_animationSets) {
            if this.m_animationSets[i].HasSoloRoutineForRig(rig) {
                ArrayPush(result, NameToString(this.m_animationSets[i].type));
            }
            i += 1;
        }
        return result;
    }

    public func GetAnimationRigsForTypeString(type: String) -> array<String> {
        return this.GetAnimationRigsForType(StringToName(type));
    }

    public func GetAnimationRigsForType(type: CName) -> array<String> {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            let empty: array<String>;
            return empty;
        }
        return animSet.GetRigs();
    }

    public func GetRoutines(type: String) -> array<ref<NCARoutine>> {
        let result: array<ref<NCARoutine>>;

        let animSet = this.GetAnimationSet(StringToName(type));
        if !IsDefined(animSet) {
            return result;
        }
        return animSet.routines;
    }


    // Every group named inside one routine, so a picker can offer the ones that already exist.
    public func GetRoutineGroups(type: String, routineTag: String) -> array<String> {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            let empty: array<String>;
            return empty;
        }
        return routine.GetGroups();
    }


// =================================================== Editing =========================================================

    public func ClearAnimationSetString(type: String) -> Bool {
        return this.ClearAnimationSet(StringToName(type));
    }

    // true = did clear something
    public func ClearAnimationSet(type: CName) -> Bool {
        let animSet = this.GetAnimationSet(type);
        if !IsDefined(animSet) {
            return false;
        }
        animSet.ClearRoutines();
        return true;
    }

    public func ClearRoutineAnimationsString(type: String, routineTag: String) -> Bool {
        let routine = this.GetRoutine(StringToName(type), StringToName(routineTag));
        if !IsDefined(routine) {
            return false;
        }
        routine.ClearAnimations();
        return true;
    }

    public func RemoveAnimationSetString(type: String) -> Bool {
        return this.RemoveAnimationSet(StringToName(type));
    }

    public func RemoveAnimationSet(type: CName) -> Bool {
        let index = this.GetAnimationSetIndex(type);
        if index < 0 {
            return false;
        }
        ArrayErase(this.m_animationSets, index);
        return true;
    }

    private func GetAnimationSetIndex(type: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_animationSets) {
            if Equals(this.m_animationSets[i].type, type) {
                return i;
            }
            i += 1;
        }
        return -1;
    }
}
