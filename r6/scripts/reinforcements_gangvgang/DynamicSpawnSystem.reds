module Gibbon.GR

import Gibbon.GR.ReinforcementSystem.*
import Gibbon.GR.GangHandlers.*
import Gibbon.GR.Logging.*

@wrapMethod(DynamicSpawnSystem)
protected final func SpawnRequestFinished(requestResult: DSSSpawnRequestResult) -> Void {
    let i: Int32;
    let spawnedObject: ref<GameObject>;
    let puppet: ref<ScriptedPuppet>;
    let reinSystem: ref<GRReinforcementSystem> = GRReinforcementSystem.GetInstance(GetGameInstance());
    let gangHandler: ref<GRGangHandler>;
    let target: ref<NPCPuppet>;
    let targetPosition: Vector4;
    let wheeledObject: ref<WheeledObject>;
    let wheeledObjects: array<ref<WheeledObject>> = [];
    let gotModTag: Bool = false;
    let aiVehicleChaseCommand: ref<AIVehicleChaseCommand>;
    let aiVehicleMovecommand: ref<AIVehicleDriveToPointAutonomousCommand>;
    let aiCommandEvent: ref<AICommandEvent>;

    if !requestResult.success {
        return;
    }

    i = 0;
    while i < ArraySize(requestResult.spawnedObjects) {
        spawnedObject = requestResult.spawnedObjects[i];
        if !spawnedObject.IsPuppet() && spawnedObject.IsVehicle() {
            ArrayPush(wheeledObjects, spawnedObject as WheeledObject);
        } else {
            if !gotModTag {
                puppet = spawnedObject as ScriptedPuppet;
                if NPCManager.HasTag(puppet.GetRecordID(), n"GRModPuppet") {
                    gotModTag = true;
					gangHandler = reinSystem.GetFactionHandler(puppet);
                }
            }
			NPCPuppet.ChangeHighLevelState(puppet, gamedataNPCHighLevelState.Combat);
        }
        i += 1;
    }



    if !gotModTag || !IsDefined(gangHandler) {
        wrappedMethod(requestResult);
        return;
    }

	target = gangHandler.GetLastTarget();
	let usedSecondaryTarget = false;
	if !IsDefined(target) {
		// primary target (e.g. authority intervention's original caller) can die/despawn before spawning
		// finishes - fall back to the secondary target rather than the stale last-known position
		target = gangHandler.GetLastSecondaryTarget();
		usedSecondaryTarget = true;
	}
	targetPosition = gangHandler.GetLastCallerPosition();

	GRLog(s"\(gangHandler.m_affiliation), Vehicles: \(ArraySize(wheeledObjects)), Target: \(IsDefined(target)), SecondaryFallback: \(usedSecondaryTarget)");

    i = 0;
    while i < ArraySize(wheeledObjects) {
        wheeledObject = wheeledObjects[i];

		if IsDefined(target) {
            aiVehicleChaseCommand = new AIVehicleChaseCommand();
            aiVehicleChaseCommand.target = target;
            aiVehicleChaseCommand.distanceMin = TweakDBInterface.GetFloat(t"DynamicSpawnSystem.dynamic_vehicles_chase_setup.distanceMin", 10.0);
            aiVehicleChaseCommand.distanceMax = TweakDBInterface.GetFloat(t"DynamicSpawnSystem.dynamic_vehicles_chase_setup.distanceMax", 45.0);
            aiVehicleChaseCommand.forcedStartSpeed = 10.0;
            aiVehicleChaseCommand.ignoreChaseVehiclesLimit = true;
            aiVehicleChaseCommand.boostDrivingStats = true;
            aiCommandEvent = new AICommandEvent();
            aiCommandEvent.command = aiVehicleChaseCommand;
            wheeledObject.SetPoliceStrategyDestination(target.GetWorldPosition());
            wheeledObject.QueueEvent(aiCommandEvent);
            wheeledObject.GetAIComponent().SetInitCmd(aiVehicleChaseCommand);
        } else if !Vector4.IsZero(targetPosition) {
            aiVehicleMovecommand = new AIVehicleDriveToPointAutonomousCommand();
            aiVehicleMovecommand.driveDownTheRoadIndefinitely = false;
            aiVehicleMovecommand.clearTrafficOnPath = false;
            aiVehicleMovecommand.forcedStartSpeed = 10.0;
            aiVehicleMovecommand.minSpeed = 30.0;
            aiVehicleMovecommand.minimumDistanceToTarget = RandRangeF(10.0, 45.0);
            aiVehicleMovecommand.targetPosition = Vector4.Vector4To3(targetPosition);
            aiCommandEvent = new AICommandEvent();
            aiCommandEvent.command = aiVehicleMovecommand;
            wheeledObject.SetPoliceStrategyDestination(targetPosition);
            wheeledObject.QueueEvent(aiCommandEvent);
            wheeledObject.GetAIComponent().SetInitCmd(aiVehicleMovecommand);
        }

        if Equals(gangHandler.m_affiliation, gamedataAffiliation.NCPD) {
            wheeledObject.GetVehicleComponent().ToggleSiren(true, true);
        }

        i += 1;
    }
	
    gangHandler.SetLastCallAnswered(true);
    //GRLog(s"\(gangHandler.m_affiliation), veh \(ArraySize(wheeledObjects)) ");
    return;
}

@wrapMethod(DynamicSpawnSystem)
protected final func SpawnCallback(spawnedObject: ref<GameObject>) -> Void {
    let wheeledObject: ref<WheeledObject>;
    let puppet: ref<gamePuppetBase>;

    if !IsDefined(spawnedObject) {
        return;
    }
    if spawnedObject.IsPuppet() {
        puppet = spawnedObject as gamePuppetBase;
        if NPCManager.HasTag(puppet.GetRecordID(), n"GRModPuppet") {
            // exit to avoid the default behaviour that makes the new npc hostile with the player
            return;
        }
    } else {
        if spawnedObject.IsVehicle() {
            wheeledObject = spawnedObject as WheeledObject;
            let tags = TweakDBInterface.GetVehicleRecord(wheeledObject.GetRecordID()).Tags();
            if ArrayContains(tags, n"GRModVehicle") {
                // exit to avoid the default behaviour that gives the vehicle a command to chase the player
                // we will give the vehicle a correct chase command in the request finished wrapper above
                return;
            }
        }
    }

    // if the entity was not tagged with GRModVehicle or GRModPuppet, then call the original function.
    wrappedMethod(spawnedObject);
}

/*
snippet to make vehicles drive to the player
    let playerPosition = GetPlayer(GetGameInstance()).GetWorldPosition();
	aiVehicleMovecommand = new AIVehicleDriveToPointAutonomousCommand();
	aiVehicleMovecommand.driveDownTheRoadIndefinitely = true;
	aiVehicleMovecommand.clearTrafficOnPath = false;
	aiVehicleMovecommand.forcedStartSpeed = 5.0;
	aiVehicleMovecommand.minSpeed = 10.0;
	aiVehicleMovecommand.maxSpeed = 20.0;
	aiVehicleMovecommand.minimumDistanceToTarget = 5.0;
	aiVehicleMovecommand.targetPosition = Vector4.Vector4To3(playerPosition);
	aiCommandEvent = new AICommandEvent();
	aiCommandEvent.command = aiVehicleMovecommand;
	wheeledObject.SetPoliceStrategyDestination(playerPosition);
	wheeledObject.QueueEvent(aiCommandEvent);
	wheeledObject.GetAIComponent().SetInitCmd(aiVehicleMovecommand);
*/

/*
public class GRVehicleSpawnPositionsCollector extends ScriptableSystem {
	private let m_lock: RWLock;
	
    private let m_entitySystem: ref<DynamicEntitySystem>;
    private let m_callbackSystem: wref<CallbackSystem>;
	private let m_vehiclePositions: array<Vector4>;

	public func OnAttach() {
		this.m_vehiclePositions = [];
        this.m_entitySystem = GameInstance.GetDynamicEntitySystem();
        this.m_callbackSystem = GameInstance.GetCallbackSystem();
        this.m_callbackSystem.RegisterCallback(n"Entity/Attached", this, n"OnEntityAttached").AddTarget(EntityTarget.Type(n"vehicleCarBaseObject"));
    }

	//function to get a random vehicle position that is within a range of 50-100 units from the player, and pop it from the array
	public func GetRandomVehiclePosition() -> Vector4 {
		let player = GetPlayer(GetGameInstance());
		let playerPosition = player.GetWorldPosition();
		let outputPosition: Vector4;
		let randomNumber: Int32;
		let distance: Float;
    	while Vector4.IsZero(outputPosition) {
        	randomNumber = RandRange(0, ArraySize(this.m_vehiclePositions) - 1);
			distance = Vector4.Distance(playerPosition, this.m_vehiclePositions[randomNumber]);
			if distance > 50.0 && distance < 100.0 {
				outputPosition = this.m_vehiclePositions[randomNumber];
			} else {
				ArrayPop(this.m_vehiclePositions);
			}
		}
		return outputPosition;
	}

	private cb func OnEntityAttached(evt: ref<EntityLifecycleEvent>) {
		// todo store the position of the vehicle in a rotating stack of positions
		let player = GetPlayer(GetGameInstance());
		let playerPosition = player.GetWorldPosition();
		let entity = evt.GetEntity() as Entity;
		let vehiclePosition = entity.GetWorldPosition();
		let distance = Vector4.Distance(playerPosition, vehiclePosition);
		if distance > 50.0 && distance < 100.0 {
			//RWLock.Acquire(this.m_lock);
			// add this one
			ArrayPush(this.m_vehiclePositions, vehiclePosition);
			//phill said 11 is better than 10
			if ArraySize(this.m_vehiclePositions) > 11 {
				ArrayPop(this.m_vehiclePositions);
			}
			//RWLock.Release(this.m_lock);
		}
	}
}*/