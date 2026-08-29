module NightCityAllies.Persistence

import NightCityAllies.*
import NightCityAllies.Event.*

// 
// Persistent storage for context info, fed by hooks
//

public class ContextSystem extends ScriptableSystem {
    public persistent let isInCombat: Bool;
    public persistent let isInCar: Bool;
    public persistent let isRestrictedTier: Bool;
    public persistent let district: gamedataDistrict;
    public persistent let gameplayTier: GameplayTier;
    public persistent let day: Int32;
    public persistent let hour: Int32;
    public persistent let minute: Int32;    
    public persistent let location: CName;
    public let isInMenu: Bool;
    public let isInElevator: Bool;
    public let isSessionStarted: Bool;
    public let vehicle: ref<VehicleObject>;
    public let isInInteraction: Bool; // TODO just ref the interaction?

    public func IsInLocation() -> Bool {
        return !Equals(this.location, n"");
    }
}
