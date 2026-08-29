module Utils2077.AIUtils

public func MountEntityToVehicle(entID: EntityID,
                                 vehID: EntityID,
                                 seat: ref<VehicleSeat_Record>,
                                 isEntityAlive: Bool,
                                 opt isInstant: Bool,
                                 opt ignoreHLS: Bool,
                                 opt occupiedByNonFriendly: Bool,
                                 opt silentUnmount: Bool,
                                 opt preservePositionAfterMounting: Bool,
                                 opt removePitchRollRotationOnDismount: Bool) -> Bool {
    let MountingFacility = GameInstance.GetMountingFacility(GetGameInstance());
    let sid = new MountingSlotId(seat.SeatName());
    let mo = new MountEventOptions();
    let md  = new MountEventData();
    let mr = new MountingRequest();
    mo.alive = isEntityAlive;
    mo.occupiedByNonFriendly = occupiedByNonFriendly;
    mo.silentUnmount = silentUnmount;
    mo.entityID = entID;

    md.isInstant = isInstant;
    md.mountEventOptions = mo;
    md.removePitchRollRotationOnDismount = removePitchRollRotationOnDismount;
    md.ignoreHLS = ignoreHLS;
    md.mountParentEntityId = vehID;

    let mi = new MountingInfo(entID, vehID, sid);
    mr.preservePositionAfterMounting = preservePositionAfterMounting;
    mr.mountData = md;
    mr.lowLevelMountingInfo = mi;
    MountingFacility.Mount(mr);
    return true;
};

public func MountEntityToVehicleWithPriority(entID: EntityID,
                                             vehID: EntityID,
                                             seatPriorityList: array<ref<VehicleSeat_Record>>,
                                             isEntityAlive: Bool,
                                             opt isInstant: Bool,
                                             opt ignoreHLS: Bool,
                                             opt occupiedByNonFriendly: Bool,
                                             opt silentUnmount: Bool,
                                             opt preservePositionAfterMounting: Bool,
                                             opt removePitchRollRotationOnDismount: Bool) -> Bool {
    let gi: GameInstance = GetGameInstance();
    let npc = GameInstance.FindEntityByID(gi, entID);
    if !IsDefined(npc) ||  ScriptedPuppet.IsDefeated((npc as ScriptedPuppet)) {
        return false;
    };

    for seat in seatPriorityList {
        if !VehicleComponent.IsSlotOccupied(gi, vehID, seat.SeatName()) {
            let success = MountEntityToVehicle(entID,
                          vehID,
                          seat,
                          isEntityAlive,
                          isInstant,
                          ignoreHLS,
                          occupiedByNonFriendly,
                          silentUnmount,
                          preservePositionAfterMounting,
                          removePitchRollRotationOnDismount);
            if success {
                return success;
            };
        };

        return false;
    };
};

public func EnterVehicle(vehID: EntityID, entID: EntityID, slot: CName) -> Bool {
    let npc = GameInstance.FindEntityByID(GetGameInstance(), entID);
    let mountData = new MountEventData();
    mountData.slotName = slot;
    mountData.mountParentEntityId = vehID;
    mountData.isInstant = false;
    mountData.ignoreHLS = true;
    let npc_HLS = (npc as ScriptedPuppet).GetHighLevelStateFromBlackboard();
    if Equals(npc_HLS,  gamedataNPCHighLevelState.Combat) {
      mountData.entrySlotName = n"combat";
    };

    let evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    npc.QueueEvent(evt);
    return true;
};
