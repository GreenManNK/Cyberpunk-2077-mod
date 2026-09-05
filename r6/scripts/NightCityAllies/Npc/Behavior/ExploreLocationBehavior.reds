module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*
import NightCityAllies.Util.*
import NightCityAllies.Event.*

public class NCAExploreLocationBehavior extends NCABehavior {
    public func GetName() -> String = "ExploreLocation";

    protected let m_location: ref<NCALocation>;
    protected let m_state: Int32; // 0 = idle, 1 = moving to interaction, 2 = interacting, 3 = leaving, 4 = walking back out
    private let m_currentProp: ref<NCAProp>;
    private let m_currentInteraction: ref<NCAInteractionPoint>;
    private let m_walkTarget: Vector4; // closest found walkable point near interaction
    private let m_hasWalkTarget: Bool; // guards against walking out to an unset target, which is world origin
    private let m_approach: ref<NCAApproach>; // the walk in progress, in states 1 and 4
    private let m_pendingArea: CName;  // area the approach ends in
    private let m_timeout: Float; // the wait before the next interaction search
    private let m_interactionTime: Float;       // time spent at the current interaction point
    private let m_interactionDuration: Float;   // rolled target duration for the current interaction
    private let m_walkTimeout: Float;           // remaining walk-to-player time while idle

    public func GetText() -> String {
        let locationName = NameToString(this.m_location.tag);

        if (this.m_state == 0) {
            return locationName;
        } else if (this.m_state == 1) {
            return "-> " +  NameToString(this.m_currentProp.tag);
        } else if (this.m_state == 2 || this.m_state == 3) {
            return NameToString(this.m_currentProp.tag);
        } else if (this.m_state == 4) {
            return "<- " + NameToString(this.m_currentProp.tag);
        } else {
            return locationName + " - ?";
        }
    }

    public static func Create(location: ref<NCALocation>) -> ref<NCAExploreLocationBehavior> {
        let behavior = new NCAExploreLocationBehavior();
        behavior.m_location = location;
        behavior.m_state = 0;
        return behavior;
    }

    public func OnAttach() -> Void {
        if (!this.ResumeSavedInteraction()) {
            this.SetState(0);
            this.m_timeout = NCAConstants.LocationEntryDelay();

            if (this.m_npcHandle.IsSquad()) {
                this.FollowTarget(NCA.Player(), NCAConstants.EntryFollowDistance(), NCAConstants.EntryFollowTolerance(), moveMovementType.Walk);
            }
        }
        this.SetCurrentLocation(this.m_location.tag);
    }

    public func OnDetach() -> Void {
        this.ReleaseInteraction(true);
        this.CancelCommand();

        // Workaround to let non squad NPCS remember their last interaction spot for respawn after save and load.
        if (this.m_npcHandle.IsSquad()) {
            this.ClearCurrentLocation();
        }
    }

    protected func OnHold() -> Void {
        if (this.m_state == 0 || this.m_state == 1 || this.m_state == 4) {
            this.HoldPosition();
        }
    }

    protected func OnRelease() -> Void {
        this.Resume();
    }

    protected func OnRoutineEnded() -> Void {
        this.Resume();
    }

    public func Resume() -> Void {
        if (this.HasRoutine()) {
            return;
        }

        if ((this.m_state == 1 || this.m_state == 4) && IsDefined(this.m_approach)) {
            this.MoveTo(this.m_approach.GetTarget(), this.m_approach.IsDirect());
            return;
        }

        if (this.m_state == 0) {
            this.CancelCommand();
        }
    }

    public func Update(deltaTime: Float) -> Void {
        if ((this.m_state == 0 || this.m_state == 1) && this.HasRoutine()) {
            return;
        }

        if (this.m_isHeld) {
            return;
        }

        if (this.m_state == 0) {
            this.UpdateIdle(deltaTime);
        } else if (this.m_state == 1) {
            this.UpdateMoving(deltaTime);
        } else if (this.m_state == 2) {
            this.UpdateInteracting(deltaTime);
        } else if (this.m_state == 3) {
            this.UpdateLeaving(deltaTime);
        } else if (this.m_state == 4) {
            this.UpdateExiting(deltaTime);
        }
    }

    protected func SetCurrentSpot(propTag: CName, interactionIndex: Int32) -> Void {
        this.m_npcHandle.SetCurrentInteraction(propTag, interactionIndex);
    }

    protected func ClearCurrentSpot() -> Void {
        this.m_npcHandle.ClearCurrentSpot();
    }

    protected func SetCurrentLocation(locationTag: CName) -> Void {
        this.m_npcHandle.SetCurrentLocation(locationTag);
    }

    protected func ClearCurrentLocation() -> Void {
        this.m_npcHandle.ClearCurrentLocation();
    }

// ============================================== Synced routines ======================================================

    private func SetState(state: Int32) -> Void {
        if this.m_state == state {
            return;
        }

        this.m_state = state;

        if IsDefined(this.m_npcHandle) {
            NCA.Events().OnCompanionStateChanged(this.m_npcHandle);
        }
    }

    public func GetCurrentInteractionType() -> CName {
        if (this.m_state != 2 || !IsDefined(this.m_currentInteraction)) {
            return n"";
        }
        return this.m_currentInteraction.type;
    }

    public func GetSyncedRoutines() -> array<ref<NCARoutine>> {
        let type = this.GetCurrentInteractionType();
        if (Equals(type, n"")) {
            return super.GetSyncedRoutines();
        }

        return NCA.Animation().GetSyncedRoutines(type, this.m_npcHandle.GetRig(), NCA.Util().GetPlayerRig());
    }

    public func PlaySyncedRoutine(routine: ref<NCARoutine>) -> Bool {
        if (Equals(this.GetCurrentInteractionType(), n"")) {
            return super.PlaySyncedRoutine(routine);
        }

        return this.StartSyncedRoutine(routine, NCA.Player());
    }

    public func StartSyncedRoutine(routine: ref<NCARoutine>, partner: wref<ScriptedPuppet>) -> Bool {
        if (this.m_state != 2 || !IsDefined(this.m_currentInteraction) || !IsDefined(routine)) {
            return false;
        }

        if (!this.StartRoutine(routine, this.m_currentInteraction.pos, this.m_currentInteraction.rot, partner)) {
            return false;
        }

        this.ResetInteractionTimer(); // the stay restarts, so a join is not cut short by an expiring timer
        return true;
    }

// =================================================== States ==========================================================

    private func UpdateIdle(deltaTime: Float) -> Void {
        if (this.m_walkTimeout > 0.0) {
            this.m_walkTimeout -= deltaTime;
            if (this.m_walkTimeout <= 0.0) {
                this.CancelCommand();
            }
        }

        this.m_timeout -= deltaTime;
        if (this.m_timeout > 0.0) {
            return;
        }

        if (!this.StartInteraction(null)) {
            this.m_timeout = NCAConstants.SearchRetryTime();
        }
    }

    private func UpdateMoving(deltaTime: Float) -> Void {
        let step = this.DriveApproach(deltaTime);

        if (Equals(step, NCAApproachStep.Move)) {
            if (this.m_approach.IsOnFinalLeg()) {
                this.m_npcHandle.currentArea = this.m_pendingArea;
            }
            return;
        }

        if (Equals(step, NCAApproachStep.Arrived)) {
            this.BeginInteraction();
            return;
        }

        if (Equals(step, NCAApproachStep.Failed)) {
           //NCA.CETLog("WARNING Failed to reach prop " + NameToString(this.m_currentProp.tag) + ", giving up and resetting state");
            this.ReleaseInteraction();
            this.EnterIdle();
        }
    }

    private func UpdateInteracting(deltaTime: Float) -> Void {
        this.m_interactionTime += deltaTime;

        if (this.IsRoutineFinished()) {
            if (!this.StartSoloRoutine()) {
                this.StartExit();
            }
            return;
        }

        if (!this.ShouldEndInteraction()) {
            return;
        }

        this.SetState(3);
        this.EndRoutine();
    }

    // Waiting out the exit clip, the companion is still physically in it.
    private func UpdateLeaving(deltaTime: Float) -> Void {
        if (!this.IsRoutineFinished()) {
            return;
        }

        this.StartExit();
    }

    private func UpdateExiting(deltaTime: Float) -> Void {
        let step = this.DriveApproach(deltaTime);

        if (Equals(step, NCAApproachStep.Arrived)) {
            this.FinishExit();
            return;
        }

        if (Equals(step, NCAApproachStep.Failed)) {
            //NCA.CETLog("WARNING Never made it out of " + NameToString(this.m_currentProp.tag) + ", still "
            //    + FloatToString(Vector4.Distance(this.m_npcHandle.GetEntity().GetWorldPosition(), this.m_walkTarget))
            //    + "m from the walk target after "
            //    + FloatToString(NCAConstants.ExitGiveUpTime()) + "s, giving up");
            this.ReleaseInteraction();
            this.EnterIdle();
        }
    }

    private func FinishExit() -> Void {
        if (this.StartInteraction(this.m_currentInteraction)) {
            return;
        }

        this.ReleaseInteraction();
        this.EnterIdle();
    }

    private func StartExit() -> Void {
        if (!this.m_hasWalkTarget) {
            this.FinishExit();
            return;
        }

        // back to entry point
        let approach = NCAApproach.Create();
        approach.AddLeg(this.m_walkTarget, true,
            NCAConstants.ExitArrivalDistance(),
            NCAConstants.ExitGiveUpTime());

        this.SetState(4);
        this.StartApproach(approach);
    }

    private func ShouldEndInteraction() -> Bool {
        return this.m_interactionTime >= this.m_interactionDuration;
    }

// ================================================= Transitions =======================================================

    private func StartInteraction(exclude: ref<NCAInteractionPoint>) -> Bool {
        let prop: ref<NCAProp>;
        let interaction: ref<NCAInteractionPoint>;
        let approach: ref<NCAApproach>;
        let walkTarget: Vector4;

        if (!this.PickInteraction(exclude, prop, interaction, approach, walkTarget)) {
            return false;
        }

        this.ReleaseInteraction();

        prop.OccupyInteractionPoint(interaction);
        this.m_currentProp = prop;
        this.m_currentInteraction = interaction;

        this.SetState(1);
        this.m_walkTarget = walkTarget;
        this.m_hasWalkTarget = true;
        this.m_pendingArea = prop.area;
        this.StartApproach(approach);

        // remember for respawn after save and load by index
        this.SetCurrentSpot(prop.tag, prop.GetInteractionIndex(interaction));

        return true;
    }

    private func StartApproach(approach: ref<NCAApproach>) -> Void {
        this.m_approach = approach;
        this.DriveApproach(0.0);
    }

    private func DriveApproach(deltaTime: Float) -> NCAApproachStep {
        let step = this.m_approach.Update(this.m_npcHandle.GetEntity().GetWorldPosition(), deltaTime);

        if (Equals(step, NCAApproachStep.Move)) {
            this.MoveTo(this.m_approach.GetTarget(), this.m_approach.IsDirect());
        }

        return step;
    }

    private func ResumeSavedInteraction() -> Bool {
        let index: Int32 = this.m_npcHandle.GetCurrentInteractionIndex();
        if (index < 0) {
            return false;
        }

        let prop: ref<NCAProp>;
        if (!this.m_location.GetPropByTag(this.m_npcHandle.GetCurrentSpot(), prop)) {
            return false;
        }

        // gone or taken: a module reordered the points, or someone else got there first
        let interaction = prop.GetInteractionAt(index);
        if (!IsDefined(interaction) || !prop.IsInteractionPointFree(interaction)) {
            return false;
        }

        this.m_currentProp = prop;
        this.m_currentInteraction = interaction;
        this.m_npcHandle.currentArea = prop.area;

        if (!this.StartSoloRoutine()) {
            this.m_currentProp = null;
            this.m_currentInteraction = null;
            return false;
        }

        prop.OccupyInteractionPoint(interaction);
        this.SetCurrentSpot(prop.tag, index);

        this.m_hasWalkTarget = NCA.Util().FindNavmeshPointNear(this.m_npcHandle.GetEntity(), interaction.pos, NCAConstants.NavmeshSnapRadius(), this.m_walkTarget);
        this.SetState(2);
        this.ResetInteractionTimer();
        return true;
    }

    private func BeginInteraction() -> Void {
        this.CancelCommand();
        this.m_approach = null;

        if (!this.StartSoloRoutine()) {
            //NCA.CETLog("WARNING No routine for this interaction point, releasing it"); // PickInteraction should have caught this
            this.ReleaseInteraction();
            this.EnterIdle();
            return;
        }

        this.SetState(2);
        this.ResetInteractionTimer();
    }

    private func StartSoloRoutine() -> Bool {
        if (!IsDefined(this.m_currentInteraction)) {
            return false;
        }

        let routine: ref<NCARoutine>;
        if (!NCA.Animation().GetSoloRoutine(this.m_currentInteraction.type, this.m_npcHandle.GetRig(), routine)) {
            return false;
        }

        if (!this.StartRoutine(routine, this.m_currentInteraction.pos, this.m_currentInteraction.rot, null)) {
            return false;
        }

        return true;
    }

    private func EnterIdle() -> Void {
        this.m_approach = null;
        this.SetState(0);
        this.m_timeout = NCAConstants.SearchRetryTime();
        this.m_walkTimeout = NCAConstants.WalkToRandomPropTime(); // for exit move command
    }

    private func ReleaseInteraction(opt isDetaching: Bool) -> Void {
        if (IsDefined(this.m_currentProp) && IsDefined(this.m_currentInteraction)) {
            this.m_currentProp.VacateInteractionPoint(this.m_currentInteraction);
        }

        this.m_hasWalkTarget = false; // it belonged to the interaction being let go of

        this.StopRoutine();

        this.m_currentProp = null;
        this.m_currentInteraction = null;

        // Workaround to let non squad NPCS remember their last interaction spot for respawn after save and load.
        // Squad NPCS detach when leaving with the player so they are no longer in the location
        if (!isDetaching || this.m_npcHandle.IsSquad()) {
            this.ClearCurrentSpot();
        }

        if (!isDetaching && IsDefined(this.m_npcHandle)) {
            NCA.Events().OnCompanionStateChanged(this.m_npcHandle);
        }
    }

    private func ResetInteractionTimer() -> Void {
        this.m_interactionTime = 0.0;
        this.m_interactionDuration = RandRangeF(
            NCAConstants.MinInteractionTime(),
            NCAConstants.MaxInteractionTime()
        );
    }

// =================================================== Picking =========================================================

    // Collects every free interaction point in the location and picks one at random.
    // Candidates with no solo routine for this NPCs rig or in another area with no path are dropped
    private func PickInteraction(exclude: ref<NCAInteractionPoint>, out prop: ref<NCAProp>, out interaction: ref<NCAInteractionPoint>, out approach: ref<NCAApproach>, out walkTarget: Vector4) -> Bool {
        let candidateProps: array<ref<NCAProp>>;
        let candidateInteractions: array<ref<NCAInteractionPoint>>;

        let props = this.m_location.GetProps();
        let i: Int32 = 0;
        while i < ArraySize(props) {
            let interactions = props[i].interactions;
            let j: Int32 = 0;
            while j < ArraySize(interactions) {
                if interactions[j] != exclude && props[i].IsInteractionPointFree(interactions[j]) {
                    ArrayPush(candidateProps, props[i]);
                    ArrayPush(candidateInteractions, interactions[j]);
                }
                j += 1;
            }
            i += 1;
        }

        let entity = this.m_npcHandle.GetEntity();
        let randIndex: Int32;
        while ArraySize(candidateInteractions) > 0 {
            randIndex = RandRange(0, ArraySize(candidateInteractions));

            if !NCA.Animation().HasSoloRoutineForRig(candidateInteractions[randIndex].type, this.m_npcHandle.GetRig()) {
            } else if this.BuildApproach(entity, candidateProps[randIndex], candidateInteractions[randIndex], approach, walkTarget) {
                prop = candidateProps[randIndex];
                interaction = candidateInteractions[randIndex];
                return true;
            }

            ArrayErase(candidateProps, randIndex);
            ArrayErase(candidateInteractions, randIndex);
        }

        return false;
    }

    private func BuildApproach(entity: wref<ScriptedPuppet>, prop: ref<NCAProp>, interaction: ref<NCAInteractionPoint>, out approach: ref<NCAApproach>, out walkTarget: Vector4) -> Bool {
        let from: Vector4 = entity.GetWorldPosition();
        let path: ref<NCAPath>;
        let currentArea: CName = this.m_npcHandle.currentArea;

        if !Equals(prop.area, currentArea) {
            path = this.m_location.GetPath(currentArea, prop.area);
            if !IsDefined(path) || !path.IsUsable() {
                return false;
            }
            path.GetExit(from);
        }

        let walkDirect: Bool;
        this.ResolveWalkTarget(entity, from, interaction, walkTarget, walkDirect);

        approach = NCAApproach.Create();

        if IsDefined(path) {
            approach.AddPathNodes(path.nodes,
                NCAConstants.PathNodeArrivalDistance(),
                NCAConstants.PathNodeGiveUpTime());
        }

        approach.AddLeg(walkTarget, walkDirect,
            NCAConstants.ArrivalDistance(),
            NCAConstants.MoveGiveUpTime());

        return true;
    }

    private func ResolveWalkTarget(entity: wref<ScriptedPuppet>, from: Vector4, interaction: ref<NCAInteractionPoint>, out walkTarget: Vector4, out walkDirect: Bool) -> Void {
        walkDirect = false;

        if AINavigationSystem.HasPathFromAtoB(entity, GetGameInstance(), from, interaction.pos) {
            walkTarget = interaction.pos;
            return;
        }

        if NCA.Util().FindNavmeshPointNear(entity, interaction.pos, NCAConstants.NavmeshSnapRadius(), walkTarget)
        && AINavigationSystem.HasPathFromAtoB(entity, GetGameInstance(), from, walkTarget) {
            return;
        }

        //NCA.CETLog("WARNING No path to the interaction and nothing walkable within " + FloatToString(NCAConstants.NavmeshSnapRadius()) + "m of it, going straight at it instead");
        walkTarget = interaction.pos;
        walkDirect = true;
    }
}
