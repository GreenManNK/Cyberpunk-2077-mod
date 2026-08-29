module NightCityAllies.Npc

import NightCityAllies.*
import NightCityAllies.Settings.*
import NightCityAllies.Persistence.*
import NightCityAllies.Event.*
import NightCityAllies.UI.*
import NightCityAllies.Effect.*
import NightCityAllies.Util.*
import NightCityAllies.Location.*
import NightCityAllies.Npc.Behavior.*
import NightCityAllies.Animation.*

public class NpcHandle extends IEntityResolver {
    public let entityID: EntityID;
    public let recordID: TweakDBID;
    public let archetype: CName;
    public let rig: String; // TODO save as resref?

    public let playerProximity: Bool;
    public let currentArea: CName;

    private let m_squadWidgetController: ref<SquadMemberController>;
    private let m_aiController: ref<AIHumanComponent>;
    private let m_entity: wref<ScriptedPuppet>;
    private let m_isResolved: Bool; // resolved at least once and not despawned since - see IsResolved
    private let m_appearances: array<entTemplateAppearance>;

    private let m_companionId : Int32;

    private let m_behavior: ref<NCABehavior>;
    private let m_behaviorPaused: Bool;
    private let m_outOfRangeTime: Float;

    private let m_isSpawned: Bool;
    
// ==================================================== Init ===========================================================

    public func LoadCompanionData() -> Void {
        this.m_companionId = NCA.Persistence().GetIndex(this.recordID);
        if (this.m_companionId < 0) {
            this.m_companionId = NCA.Persistence().PushCompanionData(new CompanionModData(
                false,                              // isRegistered
                "",                                 // name
                CompanionRarity.Common,             // rarity
                CompanionType.Undefined,            // type
                this.recordID,                      // recordID
                CompanionSpawnState.Invalid,        // spawnState
                0,                                  // level
                0,                                  // exp
                0,                                  // friendship
                0,                                  // love
                -1,                                 // equippedOutfit
                n"",                                // currentLocation
                n"",                                // currentSpot
                -1                                  // currentInteractionIndex
            ));
        }
    }

    public func SpawnAt(position: Vector4, rotation: Quaternion) -> Void {
        if (this.m_isSpawned) {
            ///NCA.CETLog("WARNING Attempting to spawn companion that is already spawned: " + TDBID.ToStringDEBUG(this.recordID));
            return;
        }

        // Create spec for spawning
        let spec = new DynamicEntitySpec();
        spec.recordID = this.recordID;
        spec.position = position;
        spec.orientation = rotation;
        spec.tags = [n"NCA_Companion"];

        // Spawn
        this.entityID = GameInstance.GetDynamicEntitySystem().CreateEntity(spec);
        if !EntityID.IsDefined(this.entityID) {
            NCA.CETLog("ERROR Failed to spawn companion: " + TDBID.ToStringDEBUG(this.recordID));
            return;
        };
    
        this.m_isSpawned = true;

        // Wait for Entity to be spawned
        EntityResolver.ResolveEntityID(this, this.entityID);
    }

    public func Resolve(handle: ref<Entity>) -> Void {
        let entity = handle as ScriptedPuppet;
        this.m_entity = entity;
        this.m_isResolved = true;
        this.m_aiController = entity.GetAIControllerComponent();

        //this.name = newInst.name or entity:GetTweakDBDisplayName(true) or "NPC"

        this.SetRelaxedState();

        let player = GetPlayer(GetGameInstance());

        // Friendly attitude
        let attitudeAgent = entity.GetAttitudeAgent();
        attitudeAgent.SetAttitudeGroup(player.GetAttitudeAgent().GetAttitudeGroup());
        attitudeAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);

        this.ApplyGodMode();

        this.LoadMetadata();
        if this.m_behavior == null {
            this.DetermineBehavior();
        } else {
            this.m_behavior.Attach(this, this.m_aiController);
        }

        // outfit
        if !this.IsMech() {
            this.LoadSelectedAppearance();
        }
    }

    public func ApplyGodMode() -> Void {
        if !this.IsValid() {
            return;
        }

        let godModeSystem = GameInstance.GetGodModeSystem(GetGameInstance());
        godModeSystem.ClearGodMode(this.entityID, n"Default");
        godModeSystem.AddGodMode(this.entityID, NCA.Settings().GetCompanionGodModeType(), n"Default");
    }

    public func IsResolved() -> Bool {
        return this.m_isResolved;
    }

    // The entity is live right now. m_entity is not defined when the game despawns the entity
    public func IsValid() -> Bool {
        return IsDefined(this.m_entity);
    }

    public func Tick(deltaTime: Float) -> Void {
        if (this.IsValid() && this.HasActiveBehavior() && !this.m_behaviorPaused) {
            this.m_behavior.Tick(deltaTime);
            if (IsDefined(this.m_squadWidgetController)) {
                this.m_squadWidgetController.SetStatusText(this.m_behavior.GetTextColor(), this.m_behavior.GetText());
            }
        }

        if this.IsSquad() {
            if (this.IsResolved() && (!this.IsValid() || this.GetDistanceToPlayer() > 100.0)) {
                this.m_outOfRangeTime += deltaTime;
                if (!this.IsValid() || this.m_outOfRangeTime >= 5.0) {
                    this.Despawn(true);
                    NCA.NPC().Commute(this.GetRecordID());
                }
            } else if (this.m_outOfRangeTime > 0.0) {
                this.m_outOfRangeTime = 0.0;
            }
        }
    }

    public func SetCombatState() -> Void {
        NPCPuppet.ChangeHighLevelState(this.m_entity, gamedataNPCHighLevelState.Combat);
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Expand();
        }
    }

    public func SetAlertedState() -> Void {
        NPCPuppet.ChangeHighLevelState(this.m_entity, gamedataNPCHighLevelState.Alerted);
    }

    public func SetStealthState() -> Void {
        NPCPuppet.ChangeHighLevelState(this.m_entity, gamedataNPCHighLevelState.Stealth);
    }

    public func SetRelaxedState() -> Void {
        NPCPuppet.ChangeHighLevelState(this.m_entity, gamedataNPCHighLevelState.Relaxed);
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Collapse();
        }
    }

    public func ExpandSquadWidget() -> Void {
        if IsDefined(this.m_squadWidgetController) {
            this.m_squadWidgetController.Expand();
        }
    }

    public func CollapseSquadWidget() -> Void {
        if IsDefined(this.m_squadWidgetController) {
            this.m_squadWidgetController.Collapse();
        }
    }

    public func CommuteSquadWidget() -> Void {
        if IsDefined(this.m_squadWidgetController) {
            this.m_squadWidgetController.Commute();
            this.m_squadWidgetController.SetStatusText(new HDRColor(0.2, 0.8, 0.4, 1.0), "Commuting");
        }
    }

    public func IntroSquadWidget() -> Void {
        if IsDefined(this.m_squadWidgetController) {
            this.m_squadWidgetController.PlayIntro();
        }
    }

  //Alerted = 0,
  //Any = 1,
  //Combat = 2,
  //Dead = 3,
  //Fear = 4,
  //Relaxed = 5,
  //Stealth = 6,
  //Unconscious = 7,
  //Wounded = 8,
  //Count = 9,
  //Invalid = 10,

	public func Acquire() -> Void {
		if (!this.IsAcquirable()) {
			return;
		}

        this.JoinSquad();
        NCA.Persistence().ClearSpawnLocation(this.recordID);
	}

// ========================================== Getters & Setters ========================================================
    public func SetSpawned() -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState = CompanionSpawnState.Spawned;
    }

    public func SetSquad() -> Int32 {
        NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState = CompanionSpawnState.Squad;
    }

    public func SetCommuting() -> Int32 {
        NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState = CompanionSpawnState.Commuting;
    }

    public func SetAcquirable() -> Int32 {
        NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState = CompanionSpawnState.Unacquired;
    }

    public func SetStandby() -> Int32 {
        NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState = CompanionSpawnState.Standby;
    }

    public func GetSelectedAppearance() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].equippedOutfit;
    }

    public func SetSelectedAppearance(index: Int32) -> Int32 {
        NCA.Persistence().m_companionRegistry[this.m_companionId].equippedOutfit = index;
    }

    public func GetLevel() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].level;
    }

    public func GetName() -> String {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].name;
    }

    public func Effect(effect: CName) {
        NCA.Effect().Trigger(effect, this.recordID);

        // workaround because we have no idea what the effect modifies, might be a stat on the ui
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Update();
        }
    }

    public func AddFriendship(amount: Int32) -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].friendship += amount;
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Update();
        }
    }

    public func AddLove(amount: Int32) -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].love += amount;
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Update();
        }
    }

    public func GetFriendship() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].friendship;
    }

    public func GetLove() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].love;
    }

    public func GetOutfitForTag(tag: CName) -> Int32 {
        return NCA.Persistence().GetCompanionOutfit(this.recordID, tag);
    }

    public func SetOutfitForTag(tag: CName, index: Int32) -> Void {
        NCA.Persistence().ChangeCompanionOutfit(this.recordID, tag, index);
    }

    public func SetCurrentLocation(location: CName) -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentLocation = location;
    }

    public func GetCurrentLocation() -> CName {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].currentLocation;
    }

    public func ClearCurrentLocation() -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentLocation = n"";
    }

    public func HasCurrentLocation() -> Bool {
        return !Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].currentLocation, n"");
    }

    public func SetCurrentSpot(spot: CName) -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentSpot = spot;
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentInteractionIndex = -1;
    }

    // TODO redundant
    public func SetCurrentInteraction(spot: CName, interactionIndex: Int32) -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentSpot = spot;
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentInteractionIndex = interactionIndex;
    }

    public func GetCurrentSpot() -> CName {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].currentSpot;
    }

    public func GetCurrentInteractionIndex() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].currentInteractionIndex;
    }

    public func ClearCurrentSpot() -> Void {
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentSpot = n"";
        NCA.Persistence().m_companionRegistry[this.m_companionId].currentInteractionIndex = -1;
    }

    public func HasCurrentSpot() -> Bool {
        return !Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].currentSpot, n"");
    }

    public func SetEntity(entity: wref<ScriptedPuppet>) -> Void {
        this.m_entity = entity;
    }

    public func GetEntity() -> wref<ScriptedPuppet> {
        return this.m_entity;
    }

    private func LoadMetadata() -> Void {
        let record = TweakDBInterface.GetCharacterRecord(this.recordID);
        let path: ResRef = record.EntityTemplatePath();
        let token: ref<ResourceToken> = GameInstance.GetResourceDepot().LoadResource(path);
        if token.IsLoaded() {
            let template: ref<entEntityTemplate> = token.GetResource() as entEntityTemplate;
            if IsDefined(template) {
                this.m_appearances = template.appearances;
            }
        }
        
        this.rig = NCA.Util().GetRig(this.GetEntity()); // eg. base\characters\base_entities\man_base\man_base.rig
    }

    public func IsSpawned() -> Bool {
        return this.m_isSpawned;
    }

    public func IsSquad() -> Bool {
        return Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState, CompanionSpawnState.Squad);
    }

    public func IsStandby() -> Bool {
        return Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState, CompanionSpawnState.Standby);
    }

    public func IsCommuting() -> Bool {
        return Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState, CompanionSpawnState.Commuting);
    }

    public func IsAcquirable() -> Bool {
        return Equals(NCA.Persistence().m_companionRegistry[this.m_companionId].spawnState, CompanionSpawnState.Unacquired);
    }

    public func GetType() -> CompanionType {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].type;
    }

    public func GetRarity() -> CompanionRarity {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].rarity;
    }

    public func GetPrice() -> Float {
        switch (this.GetRarity()) {
            case CompanionRarity.Common:
                return 1000.0;
            case CompanionRarity.Rare:
                return 2500.0;
            case CompanionRarity.Elite:
                return 5000.0;
            case CompanionRarity.Legendary:
                return 10000.0;
            default:
                return 0.0;
        }
    }

    // Legacy name
    public func IsMerc() -> Bool {
        return this.IsSquad();
    }

    public func IsMech() -> Bool {
        return Equals(this.archetype, n"mech");
    }

    public func IsDrone() -> Bool {
        return Equals(this.archetype, n"drone");
    }

    public func GetRecordID() -> TweakDBID {
        return this.recordID;
    }

    public func GetDistanceToPlayer() -> Float {
        let distance = Vector4.Distance(GetPlayer(GetGameInstance()).GetWorldPosition(), this.m_entity.GetWorldPosition());
        return distance;
    }

    public func GetExp() -> Int32 {
        return NCA.Persistence().m_companionRegistry[this.m_companionId].exp;
    }

    public func GetExpString() -> String {
        let value: Float = ExpLogic.GetLevelProgress(NCA.Persistence().m_companionRegistry[this.m_companionId].exp) * 100.0;
        let precision: Int32 = 100;
        let integerPart: Int32 = Cast<Int32>(value);
        let fractionalPart: Int32 = Cast<Int32>((value - Cast<Float>(integerPart)) * Cast<Float>(precision) + 0.5);
        let sInt: String = integerPart < 10 ? "0" + ToString(integerPart) : ToString(integerPart);
        let sFrac: String = fractionalPart < 10 ? "0" + ToString(fractionalPart) : ToString(fractionalPart);
        return sInt + "." + sFrac + "%";
    }

    public func AddExp(amount: Int32) -> Void {
        let currentExp: Int32 = NCA.Persistence().m_companionRegistry[this.m_companionId].exp;
        currentExp += amount;

        NCA.Persistence().m_companionRegistry[this.m_companionId].level = ExpLogic.GetLevelFromExp(currentExp);
        NCA.Persistence().m_companionRegistry[this.m_companionId].exp = currentExp;

        let currentLevel: Int32 =  NCA.Persistence().m_companionRegistry[this.m_companionId].level;
        //NCA.CETLog("EXP: " + currentExp + " / " + ExpLogic.GetTotalExpForLevel(currentLevel + 1) + "    Lv" + ToString(currentLevel)); // <- the required for level is only for that level not total

        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.Update();
        }
    }

    public final func OnDealDamage(stats: SquadDamageStats) -> Void {
        if (IsDefined(this.m_squadWidgetController)) {
            this.m_squadWidgetController.ShowStats(stats);
        }
    }

    public final func OnTakeDamage(stats: SquadDamageStats) -> Void {
    }

    public func SetSquadWidgetController(squadWidgetController: ref<SquadMemberController>) -> Void {
        this.m_squadWidgetController = squadWidgetController;
    }
// ================================================== Behavior =========================================================

    public func AttachBehavior(behavior: ref<NCABehavior>) -> Void {
        this.DetachBehavior();

        this.m_behavior = behavior;
        this.m_behaviorPaused = false;

        // in case this happens before resolve, wait to attach until after resolve
        if this.IsValid() {
            this.m_behavior.Attach(this, this.m_aiController);
        }

        NCA.Events().OnCompanionStateChanged(this);
    }

    public func DetachBehavior() -> Void {
        if (IsDefined(this.m_behavior)) {
            if (this.IsValid()) {
                this.m_behavior.Detach();
            }
            this.m_behavior = null;

            NCA.Events().OnCompanionStateChanged(this);
        }
    }

    public func PauseBehavior() -> Void {
        if (IsDefined(this.m_behavior)) {
            this.m_behavior.SetHold(true);
            this.m_behaviorPaused = true;
        }
    }

    public func ResumeBehavior() -> Void {
        if (IsDefined(this.m_behavior)) {
            this.m_behavior.SetHold(false);
        }

        this.m_behaviorPaused = false;
    }

    public func SetInteractionHold(held: Bool) -> Void {
        if (held) {
            this.LookAtPlayer();
        } else {
            this.StopLookAtPlayer();
        }

        if (IsDefined(this.m_behavior)) {
            this.m_behavior.SetHold(held);
        }
    }

    public func LookAtPlayer(opt upperBody: Bool) -> Void {
        if (!this.AllowsReactions()) {
            return;
        }

        let stimComp: ref<ReactionManagerComponent> = this.GetStimComponent();

        if IsDefined(stimComp) {
            stimComp.ActivateReactionLookAt(GetPlayer(GetGameInstance()), false, false, 0.0, upperBody, false);
        }
    }

    public func AllowsReactions() -> Bool {
        return !IsDefined(this.m_behavior) || !this.m_behavior.BlocksReactions();
    }

    public func StopLookAtPlayer() -> Void {
        let stimComp: ref<ReactionManagerComponent> = this.GetStimComponent();

        if IsDefined(stimComp) {
            stimComp.DeactiveLookAt();
        }
    }

    public func DetermineBehavior() -> Void {
        if NCA.Context().IsInLocation() {
            let location = NCA.Location().GetLocation(NCA.Context().location);

            if this.IsAcquirable() {
                this.AttachBehavior(AcquirableBehavior.Create(location));
            } else {
                this.SetExploreLocationBehavior(location);
            }

            return;
        }

        if NCA.Context().isInCombat {
            this.SetCombatBehavior();
            return;
        }

        if NCA.Context().isInCar {
            let seat: CName = this.GetMountedSeat(); // TODO: careful when implementing companion vehicles in the future
            if IsNameValid(seat) && IsDefined(NCA.Context().vehicle) {
                this.SetPassengerBehavior(NCA.Context().vehicle, seat);
            }

            return; // EnterVehicle dismisses everyone who did not get a seat, so being unseated here is not expected.
        }

        this.SetFollowPlayerBehavior();
    }

    public func SetCombatBehavior() -> Void {
        this.AttachBehavior(CombatBehavior.Create());
    }

    public func SetPassengerBehavior(vehicle: ref<VehicleObject>, seatName: CName, opt isInstant: Bool) -> Void {
        this.AttachBehavior(PassengerBehavior.Create(vehicle, seatName, isInstant));
    }

    public func SetFollowPlayerBehavior() -> Void {
        this.AttachBehavior(NCAFollowPlayerBehavior.Create());
    }

    public func SetExploreLocationBehavior(location: ref<NCALocation>) -> Void {
        if (this.IsExploringLocation() && Equals(this.GetCurrentLocation(), location.tag)) {
            return;
        }

        this.AttachBehavior(NCAExploreLocationBehavior.Create(location));
    }

    public func SetCatchUpToPlayerBehavior() -> Void {
        this.AttachBehavior(NCACatchUpToPlayerBehavior.Create());
    }

    public func SetFollowTargetBehavior(target: wref<GameObject>, distance: Float, tolerance: Float) -> Void {
        this.AttachBehavior(NCAFollowTargetBehavior.Create(target, distance, tolerance));
    }

    public func SetElevatorBehavior() -> Void {
        if (this.IsActiveBehavior("Elevator")) {
            return;
        }

        this.AttachBehavior(NCAElevatorBehavior.Create());
    }

    public func SetHoldPositionBehavior() -> Void {
        this.AttachBehavior(NCAHoldPositionBehavior.Create());
    }

    public func SetMoveToPositionBehavior(pos: Vector4) -> Void {
        this.AttachBehavior(NCAMoveToPositionBehavior.Create(pos));
    }

// =================================================== Command =========================================================
    public func FollowPlayer() -> Void {
        this.SetFollowPlayerBehavior();
    }

    public func FollowTarget(target: wref<GameObject>, distance: Float, tolerance: Float) -> Void {
        this.SetFollowTargetBehavior(target, distance, tolerance);
    }

    public func HoldPosition() -> Void {
        this.SetHoldPositionBehavior();
    }

    public func MoveTo(pos: Vector3) {
        this.MoveTo(new Vector4(pos.X, pos.Y, pos.Z, 1.0));
    }

    public func MoveTo(pos: Vector4) {
        this.SetMoveToPositionBehavior(pos);
    }

    public func EquipPrimaryWeapon() -> Void {
      let cmd: ref<AISwitchToPrimaryWeaponCommand> = new AISwitchToPrimaryWeaponCommand();
      cmd.unEquip = false;

      this.ResumeBehaviorAfterAction(cmd);
    }

    public func EquipSecondaryWeapon() -> Void {
      let cmd: ref<AISwitchToSecondaryWeaponCommand> = new AISwitchToSecondaryWeaponCommand();
      cmd.unEquip = false;

      this.ResumeBehaviorAfterAction(cmd);
    }

    public func UnEquipWeapon() -> Void {
      let cmd: ref<AISwitchToPrimaryWeaponCommand> = new AISwitchToPrimaryWeaponCommand();
      cmd.unEquip = true;

      this.ResumeBehaviorAfterAction(cmd);
    }

    public func ResumeBehaviorAfterAction(actionCommand: ref<AICommand>) -> Void {
        if this.HasActiveBehavior() {
            this.PauseBehavior();
        }

        this.m_aiController.SendCommand(actionCommand);

        if this.HasActiveBehavior() {
            GameInstance.GetDelaySystem(GetGameInstance())
                .DelayCallback(NPCResumeBehaviorDelayCallback.Create(this), 3.0, false);
        }
    }

    public func HasActiveBehavior() -> Bool {
        return IsDefined(this.m_behavior);
    }

    public func IsActiveBehavior(behaviorName: String) -> Bool {
        return this.HasActiveBehavior() && Equals(this.m_behavior.GetName(), behaviorName);
    }

    public func IsFollowing() -> Bool {
        return this.IsActiveBehavior("FollowPlayer");
    }
 
    public func IsHoldingPosition() -> Bool {
        return this.IsActiveBehavior("HoldPosition");
    }

    public func IsExploringLocation() -> Bool {
        return this.IsActiveBehavior("ExploreLocation");
    }

    public func IsMountedToVehicle() -> Bool {
        return VehicleComponent.IsMountedToVehicle(GetGameInstance(), this.entityID);
    }

    // Mounted seat from engine
    public func GetMountedSeat() -> CName {
        let info: MountingInfo = GameInstance.GetMountingFacility(GetGameInstance()).GetMountingInfoSingleWithObjects(this.m_entity);
        return info.slotId.id;
    }

    public func JoinSquad() -> Void {
        NCA.NPC().AddToSquad(this);
        this.SetFollowPlayerBehavior();
    }

    public func StayHere() -> Void { // explore location
        if !this.IsSquad() {
            NCA.CETLog("WARNING Attempting to set StayHere behavior for companion that is not in squad: " + TDBID.ToStringDEBUG(this.recordID));
            return;
        }

        if !NCA.Context().IsInLocation() {
            NCA.CETLog("WARNING Attempting to set StayHere behavior for companion that is not in a location: " + TDBID.ToStringDEBUG(this.recordID));
            return;
        }

        this.SetExploreLocationBehavior(NCA.Location().GetLocation(NCA.Context().location));

        NCA.NPC().RemoveFromSquad(this);
    }

    private static func GetCrowdHandoverTime() -> Float = 1.0;   // let the torn down workspot release the puppet
    private static func GetCrowdWalkAwayTime() -> Float = 25.0;  // how long they get to walk out of sight

    public func Dismiss() -> Void {
        if (!this.LeaveAsCrowd()) {
            this.Despawn();
        }

        this.ClearCurrentLocation();
        this.ClearCurrentSpot();
    }

    public func DismissForDrive() -> Void {
        if NCA.Settings().skipCommute {
            this.Despawn(true); // Avoid problems with skip commute cheat
            return;
        }

        let recordID: TweakDBID = this.GetRecordID();

        // TODO Walking off as crowd does not work mid fight. LeaveAsCrowd only asks for the relaxed state, and a npc
        // that still holds hostile threats goes straight back into combat and tries to enter the car
        if NCA.Context().isInCombat {
            this.Despawn(true);
        } else {
            this.Dismiss();
        }

        NCA.NPC().Commute(recordID, 3);
    }


    public func Despawn(opt isTemporary: Bool) -> Void {
        if !this.m_isSpawned {
            NCA.CETLog("WARNING Attempting to despawn companion that is not spawned: " + TDBID.ToStringDEBUG(this.recordID));
            return;
        }

        this.playerProximity = false;
        NCA.InteractionMenu().OnProximityChanged(this);
        this.DetachBehavior();

        GameInstance.GetDynamicEntitySystem().DeleteEntity(this.entityID);

        if (!isTemporary) {
            if (this.IsSquad()) {
                this.SetStandby();
            }//TODO
            NCA.NPC().RemoveHandle(this);
        } else {
            this.m_isSpawned = false;
            this.m_behavior = null;

            //this.entityID = EntityID.Invalid();
            this.m_entity = null;
            this.m_isResolved = false; // waiting on a fresh spawn again, not unloaded mid-life
            this.m_aiController = null;
            this.m_appearances = [];
        }
    }
    
// =================================================== Routines ========================================================

    public func GetRoutineOptions() -> array<ref<NCARoutine>> {
        let empty: array<ref<NCARoutine>>;

        if !this.IsValid() || !this.HasActiveBehavior() {
            return empty;
        }

        return this.m_behavior.GetSyncedRoutines();
    }

    public func PlayRoutine(routine: ref<NCARoutine>) -> Bool {
        if !IsDefined(routine) || !this.IsValid() || !this.HasActiveBehavior() {
            return false;
        }

        return this.m_behavior.PlaySyncedRoutine(routine);
    }

    // Whether this companion is currently holding a pose the player is the other half of, and which
    // will not end on its own.
    public func IsPerformingWithPlayer() -> Bool {
        return this.IsValid() && this.HasActiveBehavior() && this.m_behavior.IsPerformingWithPlayer();
    }

    public func StopPerformanceWithPlayer() -> Bool {
        return this.IsPerformingWithPlayer() && this.m_behavior.StopPerformanceWithPlayer();
    }

// =================================================== Outfits =========================================================

    public func ChangeAppearance(index: Int32) -> Void {
        if (this.IsMech()) {
            return;
        }
        let appearanceName: CName = this.m_appearances[index].name;
        this.SetSelectedAppearance(index);
        this.m_entity.PrefetchAppearanceChange(appearanceName);
        this.m_entity.ScheduleAppearanceChange(appearanceName);
    }

    public func GetAppearances() -> array<entTemplateAppearance> {
        if (this.IsMech()) {
            return [];
        }
        return this.m_appearances;
    }

// ================================================ Voice Over =========================================================

    //GameObject.PlayVoiceOver(owner, n"danger", n"Scripts:OnHighLevelStateEnter");
    //GameObject.PlayVoiceOver(owner, n"stealth_restored", n"Scripts:OnHighLevelStateEnter");
    //GameObject.PlayVoiceOver(owner, n"enemy_warning", n"Scripts:OnHighLevelStateEnter");
    public func Talk(opt vo: CName, opt category: Int32, opt idle: Int32, opt upperBody: Bool) {
        let stimComp: ref<ReactionManagerComponent> = this.m_entity.GetStimReactionComponent();
        let animComp: ref<AnimationControllerComponent> = this.m_entity.GetAnimationControllerComponent();

        if IsDefined(stimComp) && IsDefined(animComp) {
            let animFeat: ref<AnimFeature_FacialReaction> = new AnimFeature_FacialReaction();
            animFeat.category = category == 0 ? 3 : category;
            animFeat.idle = idle == 0 ? 5 : idle;

            stimComp.ActivateReactionLookAt(GetPlayer(GetGameInstance()), false, false, 1.0, upperBody, true);
            this.PlayVoiceOver(Equals(vo, n"") ? n"greeting" : vo);
            animComp.ApplyFeature(n"FacialReaction", animFeat);
        };
    }

    public func PlayVoiceOver(vo: CName) {
        GameObject.PlayVoiceOver(this.m_entity, vo, n"", 1.0, this.entityID, true);
    }

// ================================================= Mappin ===========================================================
    private let m_mappinID: NewMappinID;

    public func AddHireIcon(opt icon: Int32) {
        this.RemoveHireIcon();

        let mappinData: MappinData;

		// The mappin won't show when gameplay Tier > 1
		// Only way to prevent it is to modify the profile but the profile can't be defined here but is some wierd
 		// Logic for example cyberpunk/cyberpunk/UI/mappins/mappinsContainers.swift:45
        mappinData.mappinType = t"Mappins.InteractionMappinDefinition";
        mappinData.variant = Equals(icon, 0) ? gamedataMappinVariant.ChangeToFriendlyVariant : IntEnum<gamedataMappinVariant>(icon);
        mappinData.visibleThroughWalls = false;
        mappinData.active = true;

        let iconOffset: Vector3 = new Vector3(0.0, 0.0, 0.275); // z=height
        let mSystem: ref<MappinSystem> = GameInstance.GetMappinSystem(this.m_entity.GetGame());
        let owner: ref<GameObject> = this.m_entity;
        if IsDefined(owner) {
            this.m_mappinID = mSystem.RegisterMappinWithObject(mappinData, owner, n"Head", iconOffset);
        };
    }

    public func RemoveHireIcon() {
        let mSystem: ref<MappinSystem> = GameInstance.GetMappinSystem(this.m_entity.GetGame());
        mSystem.UnregisterMappin(this.m_mappinID);
    }

// ================================================== Private ==========================================================
    private func LeaveAsCrowd() -> Bool {
        if (!this.m_isSpawned || !this.IsValid() || !IsDefined(this.m_aiController)) {
            return false;
        }

        this.DetachBehavior();
        this.SetRelaxedState();

        let attitudeAgent = this.m_entity.GetAttitudeAgent();
        if (IsDefined(attitudeAgent)) {
            attitudeAgent.SetAttitudeTowards(GetPlayer(GetGameInstance()).GetAttitudeAgent(), EAIAttitude.AIA_Neutral);
        }

        GameInstance.GetGodModeSystem(GetGameInstance()).ClearGodMode(this.entityID, n"Default");

        let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
        delaySystem.DelayCallback(NCACrowdDismissalDelayCallback.Create(this.entityID, false), NpcHandle.GetCrowdHandoverTime(), false);
        delaySystem.DelayCallback(NCACrowdDismissalDelayCallback.Create(this.entityID, true), NpcHandle.GetCrowdWalkAwayTime(), false); // TODO I think the engine handles this anyways

        // TODO sort of duplicate code
        if (this.IsSquad()) {
            this.SetStandby();
        }
        NCA.NPC().RemoveHandle(this);

        this.m_isSpawned = false;
        this.m_behavior = null;
        this.m_entity = null;
        this.m_isResolved = false;
        this.m_aiController = null;
        this.m_appearances = [];

        return true;
    }

    private func GetStimComponent() -> ref<ReactionManagerComponent> {
        if (!this.IsValid()) {
            return null;
        }

        return this.m_entity.GetStimReactionComponent();
    }

    private func LoadSelectedAppearance() -> Void {
        let selectedAppearance = this.GetSelectedAppearance();
        if (selectedAppearance < 0) {
            this.PickAppearance();
        } else {
            this.ChangeAppearance(selectedAppearance);
        }
    }

    private func PickFirstAppearance() -> Void {
        let i = 0;
        let count = ArraySize(this.m_appearances);
        while i < count {
            let appearanceName: CName = this.m_appearances[i].name;
            let lower: String = StrLower(NameToString(appearanceName));
            if !StrContains(lower, "nude") &&
                !StrContains(lower, "naked") &&
                !StrContains(lower, "underwear") &&
                !StrContains(lower, "bikini") &&
                !StrContains(lower, "shower") &&
                !StrContains(lower, "panties") {
                this.ChangeAppearance(i);
                break;
            };
            i += 1;
        };
    }

    private func PickAppearance() -> Void {
        let randIndex: Int32;
        let pool = this.m_appearances;    
        let remaining: Int32 = ArraySize(pool);

        while remaining > 0 {
            randIndex = RandRange(0, remaining);
            let appearanceName: CName = pool[randIndex].name;
            let lower: String = StrLower(NameToString(appearanceName));
            if !StrContains(lower, "nude") &&
                !StrContains(lower, "naked") &&
                !StrContains(lower, "underwear") &&
                !StrContains(lower, "bikini") &&
                !StrContains(lower, "shower") &&
                !StrContains(lower, "panties") {
                this.ChangeAppearance(randIndex);
                break;
            };
            ArrayErase(pool, randIndex);
            remaining -= 1;
        }
    }
}


@addMethod(AIFollowerRole)
public final func SetFollowerRef(followerRef: EntityReference) -> Void {
    this.followerRef = followerRef;
}

// The two beats of a crowd dismissal: the join command waits for the workspot the behavior just tore
// down to release the puppet, and the removal waits for the walk away. Both hold the EntityID rather
// than the handle, because the handle is gone by the time either fires.
public class NCACrowdDismissalDelayCallback extends DelayCallback {
    private let m_entityID: EntityID;
    private let m_isRemoval: Bool;

    public static func Create(entityID: EntityID, isRemoval: Bool) -> ref<NCACrowdDismissalDelayCallback> {
        let cb: ref<NCACrowdDismissalDelayCallback> = new NCACrowdDismissalDelayCallback();
        cb.m_entityID = entityID;
        cb.m_isRemoval = isRemoval;
        return cb;
    }

    public func Call() -> Void {
        if (this.m_isRemoval) {
            GameInstance.GetDynamicEntitySystem().DeleteEntity(this.m_entityID);
            return;
        }

        let puppet = GameInstance.FindEntityByID(GetGameInstance(), this.m_entityID) as ScriptedPuppet;
        if (!IsDefined(puppet)) {
            return;
        }

        let aiController = puppet.GetAIControllerComponent();
        if (IsDefined(aiController)) {
            aiController.SendCommand(new AIJoinCrowdCommand());
        }
    }
}

public class NPCResumeBehaviorDelayCallback extends DelayCallback {
    private let m_owner: wref<NpcHandle>;

    public static func Create(owner: ref<NpcHandle>) -> ref<NPCResumeBehaviorDelayCallback> {
        let cb: ref<NPCResumeBehaviorDelayCallback> = new NPCResumeBehaviorDelayCallback();
        cb.m_owner = owner;
        return cb;
    }

    public func Call() -> Void {
      this.m_owner.ResumeBehavior();
    }
}
