module NightCityAllies.Animation

import NightCityAllies.*
import NightCityAllies.Persistence.*

// All routines registered under one interaction type. The type is what an interaction point names,
// so this is the level a location's content addresses; routines below it are the variants.
public class NCAAnimationSet {
    public let type: CName;
    public let routines: array<ref<NCARoutine>>;

    public static func Create(type: CName) -> ref<NCAAnimationSet> {
        let animSet = new NCAAnimationSet();
        animSet.type = type;
        return animSet;
    }

    public func AddRoutine(routine: ref<NCARoutine>) -> Void {
        ArrayPush(this.routines, routine);
    }

    public func GetRoutine(tag: CName) -> ref<NCARoutine> {
        let i: Int32 = 0;
        while i < ArraySize(this.routines) {
            if Equals(this.routines[i].tag, tag) {
                return this.routines[i];
            }
            i += 1;
        }
        return null;
    }

    public func ClearRoutines() -> Void {
        ArrayClear(this.routines);
    }

    public func HasSoloRoutineForRig(rig: String) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.routines) {
            if this.routines[i].IsSolo() && Equals(this.routines[i].rig, rig) && this.routines[i].IsPlayable() {
                return true;
            }
            i += 1;
        }
        return false;
    }

    // What a companion picks for itself on arriving at an interaction point.
    public func GetRandomSoloRoutineForRig(rig: String, out routine: ref<NCARoutine>) -> Bool {
        let candidates: array<ref<NCARoutine>>;

        let i: Int32 = 0;
        while i < ArraySize(this.routines) {
            if this.routines[i].IsSolo() && Equals(this.routines[i].rig, rig) && this.routines[i].IsPlayable() {
                ArrayPush(candidates, this.routines[i]);
            }
            i += 1;
        }

        if ArraySize(candidates) == 0 {
            return false;
        }

        routine = candidates[RandRange(0, ArraySize(candidates))];
        return true;
    }

    // What the interaction menu offers while a companion is using this set. Both rigs have to match:
    // a join only exists as an animation for one specific pairing, so offering it to the wrong pair
    // would play a clip the actor has no skeleton for.
    public func GetSyncedRoutinesForRigs(rig: String, partnerRig: String) -> array<ref<NCARoutine>> {
        let result: array<ref<NCARoutine>>;

        let i: Int32 = 0;
        while i < ArraySize(this.routines) {
            if this.routines[i].IsSynced()
                && Equals(this.routines[i].rig, rig)
                && Equals(this.routines[i].partnerRig, partnerRig)
                && this.routines[i].IsPlayable() {
                ArrayPush(result, this.routines[i]);
            }
            i += 1;
        }

        return result;
    }

    public func GetRigs() -> array<String> {
        let result: array<String>;

        let i: Int32 = 0;
        while i < ArraySize(this.routines) {
            let known: Bool = false;
            let j: Int32 = 0;
            while j < ArraySize(result) {
                if Equals(result[j], this.routines[i].rig) {
                    known = true;
                }
                j += 1;
            }
            if !known {
                ArrayPush(result, this.routines[i].rig);
            }
            i += 1;
        }

        return result;
    }
}
