/**
 * NCPD RADIO On Foot
 * by beckylou 2025-03-06
 */

@replaceMethod(PoliceRadioScriptSystem)
private final static func IsPlayerInVehicle(instance: GameInstance) -> Bool {
  let heatLevel: Int32 = 0;
  let isPlayerInVehicle: Bool;
  
  let preventionSystem: ref<PreventionSystem>;
  preventionSystem = GameInstance.GetScriptableSystemsContainer(instance).Get(n"PreventionSystem") as PreventionSystem;
  
  let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(instance);
  let onFoot: Int32 = 0; // default on or 1 below HeatLevel or -1 is off
  let inVehicle: Int32 = 0; // default on or 1 below HeatLevel or -1 is off
  let zeroHeat: Int32 = 0; // default on or -1 is off
  
  if IsDefined(questsSystem) {
    onFoot = questsSystem.GetFact(n"ncpd_radio_on_foot_onfoot");
    inVehicle = questsSystem.GetFact(n"ncpd_radio_on_foot_invehicle");
    zeroHeat = questsSystem.GetFact(n"ncpd_radio_on_foot_zeroheat");
  };
  
  isPlayerInVehicle = PoliceRadioScriptSystem.IsPlayerInVehicle_Real(instance);
  let uHeatLevel = preventionSystem.GetHeatStageAsInt();
  if (uHeatLevel >= 0u && uHeatLevel <= 5u) {
    heatLevel = Cast<Int32>(uHeatLevel);
  } else {
    heatLevel = 0;
  };
  
  if (isPlayerInVehicle) {
	if (inVehicle == -1) {
		return false; // InVehicle Turned Off
	};
	if (heatLevel==0 && zeroHeat == 0) {
		return true; // Always play "NCPD Get Back On Patrol"
	};
	if (heatLevel>inVehicle) {
		return true; // Block if below required Heat Level
	};
	return false;
  } else {
	if (onFoot == -1) {
		return false; // onFoot Turned Off
	};
	if (heatLevel==0 && zeroHeat == 0) {
		return true; // Always play "NCPD Get Back On Patrol"
	};
	if (heatLevel>onFoot) {
		return true; // Allow if at or above required Heat Level
	};
	return false;
  };
  return true;
}

@addMethod(PoliceRadioScriptSystem)
private final static func IsPlayerInVehicle_Real(instance: GameInstance) -> Bool {
  return GetPlayer(instance).GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);
}

@addMethod(PoliceRadioScriptSystem)
public final static func VehicleReplacer(instance: GameInstance, inDogTown: Bool, IsStart: Bool) -> CName {
  let InVehicle: Bool;
  InVehicle = PoliceRadioScriptSystem.IsPlayerInVehicle_Real(instance);
  if inDogTown {
    if IsStart {
      if InVehicle { return n"dogtown_on_vehicle_start"; }
      else { return n"dogtown_on_foot_start"; };
	};
  } else {
    if IsStart {
      if InVehicle { return n"nc_on_vehicle_start"; }
      else { return n"nc_on_foot_start"; };
	} else {
      if InVehicle { return n"nc_on_vehicle_spotted"; };
	};
  };
  return n"None";
}

@replaceMethod(PoliceRadioScriptSystem)
public final static func UpdatePoliceRadioOnVehicleEntrance(instance: GameInstance) -> Void {
  let args: ref<PlayRadioArgs>;
  let InDogTown: Bool;
  let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(instance).Get(n"PreventionSystem") as PreventionSystem;
  InDogTown = preventionSystem.GetCurrentDistrict().IsDogTown();
  args = PlayRadioArgs.CheckPlayerIsChasedAndVehicleEntranceArgs(instance, PoliceRadioScriptSystem.VehicleReplacer(instance,InDogTown,true), 2.00);
  PoliceRadioScriptSystem.PlayRadio(args);
}

@replaceMethod(PoliceRadioScriptSystem)
public final static func UpdatePoliceRadioOnPlayerVisibilityChanged(instance: GameInstance, lastStarChangeStartTimeStamp: Float, currentHeatState: EPreventionHeatStage, currentVisibilityState: EStarState, futureVisibilityState: EStarState) -> Void {
  let args: ref<PlayRadioArgs>;
  let entry: CName;
  let preventionSystem: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(instance).Get(n"PreventionSystem") as PreventionSystem;
  let playerNotInVehicle: Bool = !PoliceRadioScriptSystem.IsPlayerInVehicle(instance);
  if playerNotInVehicle {
    return;
  };
  if EngineTime.ToFloat(GameInstance.GetSimTime(instance)) - lastStarChangeStartTimeStamp < 10.00 {
    return;
  };
  if !(Equals(currentHeatState, EPreventionHeatStage.Heat_1) || Equals(currentHeatState, EPreventionHeatStage.Heat_2) || Equals(currentHeatState, EPreventionHeatStage.Heat_3)) {
    return;
  };
  if preventionSystem.GetCurrentDistrict().IsDogTown() {
    if Equals(currentVisibilityState, EStarState.Active) && Equals(futureVisibilityState, EStarState.Searching) {
  	  entry = n"dogtown_almost_losing_player_start";
  	  if PoliceRadioScriptSystem.IsARecentEntry(instance, entry) {
  	    return;
  	  };
  	  args = PlayRadioArgs.CheckPlayerIsChasedAndVisibilityArgs(instance, entry, 3.00, futureVisibilityState);
  	  PoliceRadioScriptSystem.PlayRadio(args);
    };
  } else {
    if Equals(currentVisibilityState, EStarState.Active) && Equals(futureVisibilityState, EStarState.Searching) {
      entry = n"losing_player_start";
      if PoliceRadioScriptSystem.IsARecentEntry(instance, entry) {
        return;
      };
      args = PlayRadioArgs.CheckPlayerIsChasedAndVisibilityArgs(instance, entry, 3.00, futureVisibilityState);
      PoliceRadioScriptSystem.PlayRadio(args);
    } else {
      if (Equals(currentVisibilityState, EStarState.Searching) || Equals(currentVisibilityState, EStarState.Blinking)) && Equals(futureVisibilityState, EStarState.Active) {
        entry = PoliceRadioScriptSystem.VehicleReplacer(instance, false,false);
        if PoliceRadioScriptSystem.IsARecentEntry(instance, entry) {
          return;
        };
        args = PlayRadioArgs.CheckPlayerIsChasedAndVisibilityArgs(instance, entry, 1.00, futureVisibilityState);
        PoliceRadioScriptSystem.PlayRadio(args);
      };
    };
  };
}
