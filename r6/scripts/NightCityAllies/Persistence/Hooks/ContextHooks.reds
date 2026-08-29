module NightCityAllies.Persistence.Hooks

import NightCityAllies.Persistence.*
import NightCityAllies.Location.*
import NightCityAllies.Event.*
import NightCityAllies.Npc.*
import NightCityAllies.*

// ===================================================== Combat ========================================================
// 1 = inCombat 
// 2 = walk 3 = sneak?
@wrapMethod(PlayerPuppet)
protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
    let context = NCA.Context();
    let isCombat = newState == 1;
    switch (true) {
        case !context.isInCombat && isCombat:
            context.isInCombat = true;
            NCA.Events().OnCombatStart();
            NCA.Events().OnContextChange(context);
            break;
        case context.isInCombat && !isCombat:
            context.isInCombat = false;
            NCA.Events().OnCombatEnd();
            NCA.Events().OnContextChange(context);
            break;        
    }
    
    // execute original method
    return wrappedMethod(newState);
}

// =================================================== District ========================================================
@wrapMethod(DistrictManager)
public final func Update(evt: ref<DistrictEnteredEvent>) -> Void {
    wrappedMethod(evt);

    let context: ref<ContextSystem> = NCA.Context();

     // to prevent context breaking while in the loading screen
    if (!context.isSessionStarted) {
        return;
    }

    let stackSize: Int32 = ArraySize(this.m_stack);
    let districtType: gamedataDistrict = gamedataDistrict.Invalid;
    let oldDistrictType: gamedataDistrict = context.district;
    let isApartment: Bool = false;

    // Detect new state
    if (stackSize > 0) {
        let district: ref<District> = this.m_stack[stackSize-1];
        districtType = district.GetDistrictRecord().Type();
    }

    // flush
    context.district = districtType;

    if !Equals(oldDistrictType, districtType) {
        NCA.Events().OnChangeDistrict(districtType);
        NCA.Events().OnContextChange(context);
    }
}

// ================================================== Fast Travel ======================================================
@wrapMethod(FastTravelSystem)
private final func OnUpdateFastTravelPointRecordRequest(evt: ref<UpdateFastTravelPointRecordRequest>) -> Void {
    NCA.Events().OnFastTravelStart();
    wrappedMethod(evt);
}

@wrapMethod(FastTravelSystem)
protected cb func OnLoadingScreenFinished(value: Bool) -> Bool {
    NCA.Events().OnFastTravelComplete();
    return wrappedMethod(value);
}

// ==================================================== Quest ==========================================================
@wrapMethod(QuestTrackerGameController)
protected cb func OnStateChanges(hash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    let isCurrentQuestUpdated: Bool = Equals(this.m_journalManager.GetTrackedEntry().GetId(), this.m_journalManager.GetEntry(hash).GetId()) && Equals(notifyOption, JournalNotifyOption.Notify);
    let isDirect: Bool = Equals(notifyOption, JournalNotifyOption.Notify) && Equals(changeType, JournalChangeType.Direct);
    let state: gameJournalEntryState;
    state = this.m_journalManager.GetEntryState(this.m_journalManager.GetEntry(hash));

    if Equals(className, n"gameJournalQuestObjective") {
        //NCA.Phone().CETLog(ToString(hash) + " | " + ToString(className) + " | " + ToString(notifyOption) + " | " +  ToString(changeType) + " | " + ToString(isCurrentQuestUpdated) + " | " + ToString(isDirect) + " | " + ToString(state));
        let context: ref<ContextSystem> = NCA.Context();
        if Equals(state, gameJournalEntryState.Active) {
            NCA.Events().OnQuestStart();
            NCA.Events().OnContextChange(context);
        }
        if Equals(state, gameJournalEntryState.Succeeded) || Equals(state, gameJournalEntryState.Failed) {
            NCA.Events().OnQuestComplete();
            NCA.Events().OnContextChange(context);
        }
    }

    return wrappedMethod(hash, className, notifyOption, changeType);
}


// ====================================================== Car ==========================================================
@wrapMethod(VehicleComponent)
protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
  wrappedMethod(evt);
  let child: ref<GameObject> = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
  if child.IsPlayer() {
    let context: ref<ContextSystem> = NCA.Context();
    context.isInCar = true;
    NCA.Events().OnEnterVehicle(this.GetVehicle());
    NCA.Events().OnContextChange(context);
  }
}

@wrapMethod(VehicleComponent)
protected cb func OnVehicleFinishedMountingEvent(evt: ref<VehicleFinishedMountingEvent>) -> Bool {
  wrappedMethod(evt);

  let npc: ref<NpcHandle>;
  if evt.isMounting && IsDefined(evt.character)
  && NCA.NPC().FindByEntityID(evt.character.GetEntityID(), npc) {
    NCA.Events().OnCompanionMounted(npc, evt.slotID);
  }
}

@wrapMethod(VehicleComponent)
protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
  wrappedMethod(evt);

  let child: ref<GameObject> = GameInstance.FindEntityByID(this.GetVehicle().GetGame(), evt.request.lowLevelMountingInfo.childId) as GameObject;
  if child.IsPlayer() {
    let context: ref<ContextSystem> = NCA.Context();
    context.isInCar = false;
    NCA.Events().OnExitVehicle(this.GetVehicle());
    NCA.Events().OnContextChange(context);
  }
}

// ================================================= Game Start / End ==================================================
@wrapMethod(QuestTrackerGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    let context: ref<ContextSystem> = NCA.Context();
    context.isSessionStarted = true;
    NCA.Events().OnSessionStart();
    NCA.Events().OnContextChange(context);
}

@wrapMethod(QuestTrackerGameController)
protected cb func OnUninitialize() -> Bool {
    wrappedMethod();
    let context: ref<ContextSystem> = NCA.Context();
    context.isSessionStarted = false;
    NCA.Events().OnSessionEnd();
    NCA.Events().OnContextChange(context);
}
