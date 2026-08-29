module NightCityAllies.Npc

import NightCityAllies.*
import NightCityAllies.Settings.*
import NightCityAllies.Phone.*
import NightCityAllies.Persistence.*
import NightCityAllies.UI.*
import NightCityAllies.Event.*
import NightCityAllies.Timer.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*

// 
// Manages spawning and despawning NPCs
//

public class NpcManager extends ScriptableSystem {
    private let m_npcs: array<ref<NpcHandle>>; // All companions that are currently managed

    public func Tick(deltaTime: Float) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            this.m_npcs[i].Tick(deltaTime);
            i += 1;
        }
    }

    public func GetSquad() -> array<ref<NpcHandle>> {
        let squad: array<ref<NpcHandle>>;
        
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if this.m_npcs[i].IsSquad() {
                ArrayPush(squad, this.m_npcs[i]);
            }
            i += 1;
        }
        
        return squad;
    }

    public func GetSpawnedNear(position: Vector4, radius: Float) -> array<ref<NpcHandle>> {
        let result: array<ref<NpcHandle>>;

        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            let npc: ref<NpcHandle> = this.m_npcs[i];

            if npc.IsSpawned() && IsDefined(npc.GetEntity())
                && Vector4.Distance(position, npc.GetEntity().GetWorldPosition()) <= radius {
                ArrayPush(result, npc);
            }

            i += 1;
        }

        return result;
    }

    public func RefreshGodMode() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            this.m_npcs[i].ApplyGodMode();
            i += 1;
        }
    }

    public func GetSquadSize() -> Int32 {
        let squad: array<ref<NpcHandle>> = this.GetSquad();
        return ArraySize(squad);
    }

    public func GetCommutingCount() -> Int32 {
        let count: Int32 = 0;

        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if this.m_npcs[i].IsCommuting() {
                count += 1;
            }
            i += 1;
        }

        return count;
    }

    // TODO calculate by actual distance
    public func CalculateCommuteDuration() -> Int32 {
        return this.GetCommutingCount() + 1;
    }

    public func FindByEntityID(entityID: EntityID, out result: ref<NpcHandle>) -> Bool {
        let index = this.GetIndexByEntityID(entityID);

        if (index >= 0) {
            result = this.m_npcs[index];
            return true;
        }

        return false;
    }

    public func GetIndex(recordID: TweakDBID) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if this.m_npcs[i].recordID == recordID {
                return i;
            }
            i += 1;
        }
        //NCA.CETLog("No handle found for recordID: " + TDBID.ToStringDEBUG(recordID));
        return -1;
    }

    public func GetHandle(recordID: TweakDBID) -> ref<NpcHandle> {
        let index = this.GetIndex(recordID);
        if (index >= 0) {
            return this.m_npcs[index];
        }

        let handle = new NpcHandle();
        handle.recordID = recordID;
        handle.archetype = TweakDBInterface.GetCharacterRecord(recordID).ArchetypeName();
        handle.LoadCompanionData();

        ArrayPush(this.m_npcs, handle);

        return handle;
    }

    public func Commute(recordID: TweakDBID, opt minutes: Int32) -> ref<NpcHandle> {
        let present = this.FindHandle(recordID);
        if IsDefined(present) && present.IsSpawned() && present.IsValid() {
            if !present.IsSquad() {
                present.JoinSquad();
                present.IntroSquadWidget();
            }
            return present;
        }

        if NCA.Settings().skipCommute {
            let npc = this.Spawn(recordID);
            if IsDefined(npc) {
                npc.SetSquad();
                npc.SetCatchUpToPlayerBehavior();
                npc.IntroSquadWidget();
                NCA.Events().OnCompanionJoinSquad(npc);
            }
            return npc;
        }

        let index = NCA.Persistence().GetIndex(recordID);
        if index < 0 {
            NCA.CETLog("WARNING Attempting to start commute for a companion that doenst exist: " + TDBID.ToStringDEBUG(recordID));
            return null;
        }

        if Equals(NCA.Persistence().m_companionRegistry[index].spawnState, CompanionSpawnState.Commuting) {
            NCA.CETLog("WARNING Attempting to start commute for a companion that is already commuting: " + TDBID.ToStringDEBUG(recordID));
            return null;
        }

        if (minutes <= 0) {
            minutes = this.CalculateCommuteDuration();
        }

        let name = NCA.Persistence().GetCompanionName(recordID);
        let handle = this.GetHandle(recordID);

        NCA.UI().AddSquadMemberWidget(handle);

        handle.SetCommuting();
        handle.CommuteSquadWidget();
        NCA.Timer().StartTimer(StringToName(name + "_commute_timer"), 0, 0, minutes, n"commute_complete", recordID);

        //NCA.CETLog("Commute started for " + name + ": " + IntToString(minutes) + " min");

        return handle;
    }

    public func OnFinishCommute(recordID: TweakDBID) -> Void {
        let name = NCA.Persistence().GetCompanionName(recordID);

        if NCA.Context().isInCar || NCA.Context().isInElevator {
            //NCA.CETLog("Player is in a car or elevator, delaying commute completion for recordID: " + TDBID.ToStringDEBUG(recordID));
            NCA.Timer().StartTimer(StringToName(name + "_commute_timer"), 0, 0, 1, n"commute_complete", recordID);
            return;
        }

        let npc = this.SpawnInCrowd(recordID); // falls back to SpawnBehindPlayer when nothing is found
        npc.SetSquad();
        npc.SetCatchUpToPlayerBehavior();
        npc.IntroSquadWidget();
        NCA.Events().OnCompanionJoinSquad(npc);

        //NCA.CETLog("Finished commute for " + name);
    }

    public func SpawnFromRecordString(record: String) -> ref<NpcHandle> {
        return this.Spawn(TDBID.Create(record));
    }

    // Null if not found
    public func FindHandleString(record: String) -> ref<NpcHandle> {
        return this.FindHandle(TDBID.Create(record));
    }

    public func FindHandle(recordID: TweakDBID) -> ref<NpcHandle> {
        let index = this.GetIndex(recordID);
        if (index < 0) {
            return null;
        }
        return this.m_npcs[index];
    }

    public func Spawn(recordID: TweakDBID) -> ref<NpcHandle> {
        let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;

        if !IsDefined(player) {
            return null;
        };

        // Get a randomized position in front of the player
        let pos = player.GetWorldPosition();
        let forward = player.GetWorldForward();
        let right = Vector4.Cross(forward, new Vector4(0.0, 0.0, 1.0, 0.0));
        let finalPos = pos + forward * 2.5 + right * RandRangeF(-0.75, 0.75);
        let rot = GetPlayer(GetGameInstance()).GetWorldOrientation();

        return this.SpawnAt(recordID, finalPos, rot);
    }

    public func SpawnBehindPlayer(recordID: TweakDBID) -> ref<NpcHandle> {
        let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;

        if !IsDefined(player) {
            return null;
        };

        // Get a randomized position behind the player
        let pos = player.GetWorldPosition();
        let forward = player.GetWorldForward();
        let right = Vector4.Cross(forward, new Vector4(0.0, 0.0, 1.0, 0.0));
        let finalPos = pos + forward * -1.5 + right * RandRangeF(-0.75, 0.75);
        let rot = GetPlayer(GetGameInstance()).GetWorldOrientation();

        return this.SpawnAt(recordID, finalPos, rot);
    }

    // try spawn 1. navmesh 2. on existing crowd npc 3. behind player
    public func SpawnInCrowd(recordID: TweakDBID) -> ref<NpcHandle> {
        let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject() as ScriptedPuppet;

        if !IsDefined(player) {
            return null;
        };

        let pos: Vector4;
        let strategy: CName = this.FindCrowdSpawnPoint(player, pos);

        if Equals(strategy, n"") {
            return this.SpawnBehindPlayer(recordID);
        }

        // Face the player, so they read as someone who was already walking towards us
        let toPlayer = player.GetWorldPosition() - pos;
        let rot = Quaternion.BuildFromDirectionVector(Vector4.Normalize(toPlayer));

        return this.SpawnAt(recordID, pos, rot);
    }

    // Empty CName when nothing was found and the caller should fall back.
    private func FindCrowdSpawnPoint(player: ref<ScriptedPuppet>, out pos: Vector4) -> CName {
        if this.FindNavmeshPointAround(player, pos) {
            return n"navmesh";
        }

        if this.FindCrowdMemberPosition(player, pos) {
            return n"crowd";
        }

        return n"";
    }

    // TODO move to util
    private func FindNavmeshPointAround(player: ref<ScriptedPuppet>, out pos: Vector4) -> Bool {
        let navigationSystem = GameInstance.GetAINavigationSystem(GetGameInstance());
        if !IsDefined(navigationSystem) {
            return false;
        }

        let playerPos = player.GetWorldPosition();

        let attempt: Int32 = 0;
        while attempt < NpcManager.GetSpawnMaxAttempts() {
            let angle = Deg2Rad(RandRangeF(0.0, 360.0));
            let distance = RandRangeF(NpcManager.GetSpawnMinDistance(), NpcManager.GetSpawnMaxDistance());
            let probe = playerPos + new Vector4(CosF(angle) * distance, SinF(angle) * distance, 0.0, 0.0);

            let result = navigationSystem.FindPointInSphereForCharacter(probe, 5.0, player);
            if Equals(result.status, worldNavigationRequestStatus.OK)
            && AINavigationSystem.HasPathFromAtoB(player, GetGameInstance(), playerPos, result.point) {
                pos = result.point;
                return true;
            }

            attempt += 1;
        }

        return false;
    }

    private static func GetSpawnMinDistance() -> Float = 15.0;
    private static func GetSpawnMaxDistance() -> Float = 30.0;
    private static func GetSpawnMaxAttempts() -> Int32 = 12;

    // TODO move to util
    private func FindCrowdMemberPosition(player: ref<ScriptedPuppet>, out pos: Vector4) -> Bool {
        let npcs: array<ref<NPCPuppet>> = player.GetNPCsAroundObject(NpcManager.GetSpawnMaxDistance());
        let playerPos = player.GetWorldPosition();
        let candidates: array<Vector4>;

        let i: Int32 = 0;
        while i < ArraySize(npcs) {
            let npc = npcs[i];
            if IsDefined(npc) && IsDefined(npc.GetCrowdMemberComponent()) {
                // Far enough that they are not appearing in our face.
                if Vector4.Distance(playerPos, npc.GetWorldPosition()) > NpcManager.GetSpawnMinDistance() {
                    ArrayPush(candidates, npc.GetWorldPosition());
                }
            }
            i += 1;
        }

        if ArraySize(candidates) <= 0 {
            return false;
        }

        pos = candidates[RandRange(0, ArraySize(candidates))];
        return true;
    }

    public func SpawnAt(recordID: TweakDBID, position: Vector4, rotation: Quaternion) -> ref<NpcHandle> {
        //NCA.CETLog("Spawning NPC with recordID: " + TDBID.ToStringDEBUG(recordID));
        let handle = this.GetHandle(recordID);
        handle.SpawnAt(position, rotation);

        if (!handle.IsAcquirable()) {
            NCA.UI().AddSquadMemberWidget(handle);
        }

        return handle;
    }

    public func SpawnLocationCharacters(location: ref<NCALocation>) -> Void {
        let locationCompanions: array<CompanionModData> = NCA.Persistence().GetCompanionsByLocation(location.tag);
        let j: Int32 = 0;
        while j < ArraySize(locationCompanions) {
            let companion: CompanionModData = locationCompanions[j];
            NCA.NPC().SpawnAtLocation(companion.recordID, location);
            j += 1;
        };
    }

    public func DespawnLocationCharacters(location: ref<NCALocation>) -> Void {
        let locationCompanions: array<CompanionModData> = NCA.Persistence().GetCompanionsByLocation(location.tag);
        let j: Int32 = 0;
        while j < ArraySize(locationCompanions) {
            let companion: CompanionModData = locationCompanions[j];
            let handle = this.GetHandle(companion.recordID);
            handle.Despawn();
            //NCA.CETLog("Despawning companion " + TDBID.ToStringDEBUG(companion.recordID) + " at location " + NameToString(location.tag));
            j += 1;
        };
    }

    public func SpawnAtLocation(recordID: TweakDBID, location: ref<NCALocation>) -> ref<NpcHandle> {
        let index = this.GetIndex(recordID);
        if (index >= 0 && this.m_npcs[index].IsSpawned()) {
            //NCA.CETLog("WARNING Skipped spawn companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " - the companion is already spawned");
            return null;
        }

        let handle = this.GetHandle(recordID);
        let spot = handle.GetCurrentSpot();
        let loc = handle.GetCurrentLocation();

        if !Equals(loc, location.tag) {
            //NCA.CETLog("WARNING Skipped spawn companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " - the companion is at " + NameToString(handle.GetCurrentLocation()));
            return null;
        }

        // spawn on spawnpoint or prop
        let spawn: ref<NCASpawn>;
        let prop: ref<NCAProp>;
        if location.GetSpawnByTag(spot, spawn) {
            if !spawn.IsFixed() {
                //NCA.CETLog("WARNING Skipped spawn companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " - the spawn is not fixed");
                return null;
            }
            
            let spawn1: ref<NCAFixedSpawn> = spawn as NCAFixedSpawn;
            let pos = spawn1.pos;
            let rot = spawn1.rot;
            handle.SpawnAt(pos, rot);
            handle.DetermineBehavior();
            //NCA.CETLog("Spawning companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " at spawn " + ToString(pos));
            return handle;
        } else if (location.GetPropByTag(spot, prop)) {
            let pos = prop.pos;
            let rot = GetPlayer(GetGameInstance()).GetWorldOrientation();
            handle.SpawnAt(pos, rot);
            handle.DetermineBehavior();
            //NCA.CETLog("Spawning companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " at position " + ToString(pos));
            return handle;
        }


        // spawn random if no matching prop is found
        let props = location.GetProps();
        if (ArraySize(props) > 0) {
            let randIndex = RandRange(0, ArraySize(props));
            prop = props[randIndex];

            let pos = prop.pos;
            let rot = GetPlayer(GetGameInstance()).GetWorldOrientation();
            handle.SpawnAt(pos, rot);
            handle.DetermineBehavior();
            //handle.SetExploreLocationBehavior(location);

            //NCA.CETLog("Spawning companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " at random prop " + ToString(pos));
            return handle;
        }

        // TODO spawn behind player as last resort? should only happen in locations with no props or not enough props and lots of companions with no current spot...

        //NCA.CETLog("WARNING Skipped spawn companion " + TDBID.ToStringDEBUG(recordID) + " at location " + NameToString(location.tag) + " - the prop is not found");
        return null;
    }

    public func AddToSquad(npc: ref<NpcHandle>) -> Void {
        NCA.UI().AddSquadMemberWidget(npc);
        npc.SetSquad();
        NCA.Events().OnCompanionJoinSquad(npc);    
    }

    public func RemoveFromSquad(npc: ref<NpcHandle>) -> Void {
        NCA.UI().RemoveAllSquadMemberWidgets(); // Because there is no single remove widget atm
        npc.SetStandby();
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if (this.m_npcs[i].IsSquad() || this.m_npcs[i].IsCommuting()) {
                NCA.UI().AddSquadMemberWidget(this.m_npcs[i]);
            }
            i += 1;
        }
        NCA.Events().OnCompanionLeaveSquad(npc);
    }

    public func StopPerformanceWithPlayer() -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if this.m_npcs[i].StopPerformanceWithPlayer() {
                return true;
            }
            i += 1;
        };
        return false;
    }

    public func RemoveHandle(handle: ref<NpcHandle>) -> Void {
        NCA.UI().RemoveAllSquadMemberWidgets(); // Because there is no single remove widget atm
        let i: Int32 = ArraySize(this.m_npcs) - 1;
        while i >= 0 {
            if Equals(this.m_npcs[i].recordID, handle.recordID) {
                ArrayErase(this.m_npcs, i);
            } else {
                if (this.m_npcs[i].IsSquad() || this.m_npcs[i].IsCommuting()) {
                    NCA.UI().AddSquadMemberWidget(this.m_npcs[i]);
                }

                if (this.m_npcs[i].IsCommuting()) {
                    this.m_npcs[i].CommuteSquadWidget();
                } else if (this.m_npcs[i].IsSquad()) {
                    this.m_npcs[i].CollapseSquadWidget();
                }
            }
            i -= 1;
        }
    }

    public func DespawnSquad() -> Void {
        NCA.UI().RemoveAllSquadMemberWidgets();
        let i: Int32 = ArraySize(this.m_npcs) - 1;
        while i >= 0 {
            if this.m_npcs[i].IsSquad() {
                this.m_npcs[i].Despawn();
            }
            i -= 1;
        }
    }

    public final func IsCompanion(recordID: TweakDBID) -> Bool {
        return this.GetIndex(recordID) >= 0;
    }

    public final func IsCompanion(id: EntityID) -> Bool {
        return this.GetIndexByEntityID(id) >= 0;
    }

    public final func IsSquad(id: EntityID) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if Equals(this.m_npcs[i].entityID, id) {
                return this.m_npcs[i].IsSquad();
            }
            i += 1;
        }
        return false;
    }

    public func DespawnAll() -> Void {
        this.DespawnAll(false);
    }

    public func DespawnAll(isTemporary: Bool) -> Void {
        NCA.UI().RemoveAllSquadMemberWidgets();

        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if (!isTemporary) {
                let npc = this.m_npcs[i];
                if (npc.IsSquad()) {
                    npc.SetStandby();
                } else {
                    npc.SetAcquirable();
                }
            }
            GameInstance.GetDynamicEntitySystem().DeleteEntity(this.m_npcs[i].entityID);
            i += 1;
        }
        ArrayClear(this.m_npcs);
    }

    public func RespawnAll() -> Void {
        let i: Int32 = 0;
        let companions = NCA.Persistence().m_companionRegistry;
        while i < ArraySize(companions) {
            if Equals(companions[i].spawnState, CompanionSpawnState.Squad) {
                let npc = this.Spawn(companions[i].recordID);
                this.AddToSquad(npc);
            };

            if Equals(companions[i].spawnState, CompanionSpawnState.Commuting) {
                let npc = this.GetHandle(companions[i].recordID);
                NCA.UI().AddSquadMemberWidget(npc);
            };
            i += 1;
        };
    }

    public func RespawnInVehicle() -> Void {
        let vehicle = NCA.Context().vehicle;
        let i: Int32 = 0;
        let companions = NCA.Persistence().m_companionRegistry;
        while i < ArraySize(companions) {
            if Equals(companions[i].spawnState, CompanionSpawnState.Squad) {
                if (!Equals(companions[i].currentSpot, n"")) {
                    let npc = this.Spawn(companions[i].recordID);
                    this.AddToSquad(npc);
                    npc.SetPassengerBehavior(vehicle, companions[i].currentSpot, true); // instant
                }
            };
            i += 1;
        }
    }

    public func EnterVehicle(vehicle: ref<VehicleObject>) -> Void {
        let squad: array<ref<NpcHandle>> = this.GetSquad();
        let seats: array<wref<VehicleSeat_Record>>;
		let isBike = vehicle == (vehicle as BikeObject);

        let i: Int32 = 0;
        let seat: Int32 = 0;
        if VehicleComponent.GetSeats(GetGameInstance(), vehicle, seats) && !isBike {
            while seat < ArraySize(seats) && i < ArraySize(squad) {
                if Equals(seats[seat].SeatName(), n"seat_front_left") { // NOTE: If seat_front_left is the last element, seats[seat] is past the end on the next line. -> fine because seat front left is always first
                    ArrayErase(seats, seat);
                }
                if (!squad[i].IsMech() && !squad[i].IsDrone()) {
                    squad[i].SetPassengerBehavior(vehicle, seats[seat].SeatName());
                    seat += 1;
                } else {
                    squad[i].DismissForDrive();
                }
                i += 1;
            };
        };

        // Squad that exceeds the seats is dismissed too
        while i < ArraySize(squad) {
            squad[i].DismissForDrive();
            i += 1;
        };
    }

    public func ExitVehicle(vehicle: ref<VehicleObject>) -> Void {
        let squad: array<ref<NpcHandle>> = this.GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].DetermineBehavior();
            //NCA.CETLog("Companion " + TDBID.ToStringDEBUG(squad[i].recordID) + " exited vehicle and is determining behavior");
            i += 1;
        };
    }

    private func GetIndexByEntityID(entityID: EntityID) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_npcs) {
            if Equals(this.m_npcs[i].entityID, entityID) {
                return i;
            }
            i += 1;
        }
        return -1;
    }
}