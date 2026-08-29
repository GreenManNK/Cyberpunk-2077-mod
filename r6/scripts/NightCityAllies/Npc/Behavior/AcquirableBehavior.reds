module NightCityAllies.Npc.Behavior

import NightCityAllies.Npc.*
import NightCityAllies.*
import NightCityAllies.Location.*
import NightCityAllies.Location.Entity.*
import NightCityAllies.Animation.*

public class AcquirableBehavior extends NCAExploreLocationBehavior {
    public func GetName() -> String = "Acquirable";

    public static func Create(location: ref<NCALocation>) -> ref<AcquirableBehavior> {
        let behavior = new AcquirableBehavior();
        behavior.m_location = location;
        behavior.m_state = 0;
        return behavior;
    }

    public func OnAttach() -> Void {
        this.m_npcHandle.AddHireIcon();
        super.OnAttach();
    }

    public func OnDetach() -> Void {
        this.m_npcHandle.RemoveHireIcon();
        super.OnDetach();
    }

    protected func SetCurrentSpot(propTag: CName, interactionIndex: Int32) -> Void {}
    protected func ClearCurrentSpot() -> Void {}
    protected func SetCurrentLocation(locationTag: CName) -> Void {}
    protected func ClearCurrentLocation() -> Void {}
}