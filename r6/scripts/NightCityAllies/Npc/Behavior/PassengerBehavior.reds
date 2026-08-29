module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class PassengerBehavior extends NCABehavior {
    private let m_car: ref<VehicleObject>;
    private let m_seatName: CName;
    private let m_isInstant: Bool;

    public func GetName() -> String = "Passenger";

    public func GetText() -> String {
        return NameToString(this.m_seatName);
    }
    public func GetTextColor() -> HDRColor {
        return new HDRColor(0.8, 0.8, 0.5, 0.5);
    }

    public static func Create(car: ref<VehicleObject>, seatName: CName, opt isInstant: Bool) -> ref<PassengerBehavior> {
        let behavior = new PassengerBehavior();
        behavior.m_car = car;
        behavior.m_seatName = seatName;
        behavior.m_isInstant = isInstant;
        return behavior;
    }

    public func Update(deltaTime: Float) -> Void {
    }

    public func OnAttach() -> Void {
        let npc: ref<NPCPuppet> = this.m_npcHandle.GetEntity() as NPCPuppet;

        let mountData: ref<MountEventData> = new MountEventData();        
        mountData.mountParentEntityId = this.m_car.GetEntityID();
        mountData.isInstant = this.m_isInstant;
        mountData.slotName = this.m_seatName;
        mountData.setEntityVisibleWhenMountFinish = true;
        mountData.removePitchRollRotationOnDismount = false;
        mountData.ignoreHLS = false;
        
        let mountOptions: ref<MountEventOptions> = new MountEventOptions();
        mountOptions.silentUnmount = false;
        mountOptions.entityID = this.m_car.GetEntityID();
        mountOptions.alive = true;
        mountOptions.occupiedByNonFriendly = false;

        mountData.mountEventOptions = mountOptions;

        let command: ref<AIMountCommand> = new AIMountCommand();
        command.mountData = mountData;

        this.SendCommand(command);

        this.m_npcHandle.SetCurrentSpot(this.m_seatName);
    }

    public func OnDetach() -> Void {
        this.CancelCommand();

        // Combat takes over the behavior slot while the NPC keeps sitting, so the recorded seat
        // has to survive that swap - RespawnInVehicle reads it after a reload.
        if !this.m_npcHandle.IsMountedToVehicle() {
            this.m_npcHandle.ClearCurrentSpot();
        }
    }
}