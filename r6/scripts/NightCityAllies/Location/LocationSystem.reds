module NightCityAllies.Location

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*
import NightCityAllies.Location.Trigger.*
import NightCityAllies.Location.Entity.*

public class NCALocation {
    public let tag: CName;

    private let m_triggers: array<ref<NCALocationTrigger>>;
    private let m_props: array<ref<NCAProp>>;
    private let m_spawns: array<ref<NCASpawn>>;
    private let m_paths: array<ref<NCAPath>>;

    public static func Create(tag: CName) -> ref<NCALocation> {
        let location = new NCALocation();
        location.tag = tag;
        return location;
    }

    public func Load() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_props) {
            this.m_props[i].Spawn();
            i += 1;
        };
    }

    public func Unload() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_props) {
            this.m_props[i].Despawn();
            i += 1;
        };
    }

    public func AddSpawn(spawn: ref<NCASpawn>) -> Void {
        ArrayPush(this.m_spawns, spawn);
    }

    public func AddProp(prop: ref<NCAProp>) -> Void {
        ArrayPush(this.m_props, prop);
    }

    public func GetPropByTag(tag: CName, out prop: ref<NCAProp>) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_props) {
            if Equals(this.m_props[i].tag, tag) {
                prop = this.m_props[i];
                return true;
            };
            i += 1;
        };

        return false;
    }

    public func GetSpawnByTag(tag: CName, out spawn: ref<NCASpawn>) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_spawns) {
            if Equals(this.m_spawns[i].tag, tag) {
                spawn = this.m_spawns[i];
                return true;
            };
            i += 1;
        };

        return false;
    }

    public func ClearSpawns() -> Void {
        ArrayClear(this.m_spawns);
    }

    public func ClearProps() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_props) {
            this.m_props[i].Despawn();
            i += 1;
        };
        ArrayClear(this.m_props);
    }

    public func GetSpawns() -> array<ref<NCASpawn>> {
        return this.m_spawns;
    }

    public func GetProps() -> array<ref<NCAProp>> {
        return this.m_props;
    }

    public func GetSpawn(tag: CName) -> ref<NCASpawn> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_spawns) {
            if (Equals(this.m_spawns[i].tag, tag)) {
                return this.m_spawns[i];
            };
            i += 1;
        };

        return null;
    }

    public func GetProp(tag: CName) -> ref<NCAProp> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_props) {
            if (Equals(this.m_props[i].tag, tag)) {
                return this.m_props[i];
            };
            i += 1;
        };

        return null;
    }
    
    public func AddPath(path: ref<NCAPath>) -> Void {
        ArrayPush(this.m_paths, path);
    }

    public func GetPath(areaFrom: CName, areaTo: CName) -> ref<NCAPath> {
        let i: Int32 = 0;
        while i < ArraySize(this.m_paths) {
            if Equals(this.m_paths[i].areaFrom, areaFrom) && Equals(this.m_paths[i].areaTo, areaTo) {
                return this.m_paths[i];
            };
            i += 1;
        };

        return null;
    }

    public func GetPaths() -> array<ref<NCAPath>> {
        return this.m_paths;
    }

    public func ClearPaths() -> Void {
        ArrayClear(this.m_paths);
    }

    public func AddTrigger(trigger: ref<NCALocationTrigger>) -> Void {
        ArrayPush(this.m_triggers, trigger);
    }

    public func ClearTriggers() -> Void {
        ArrayClear(this.m_triggers);
    }

    public func GetTriggerDescriptions() -> array<String> {
        let result: array<String>;
        let i: Int32 = 0;
        while i < ArraySize(this.m_triggers) {
            ArrayPush(result, this.m_triggers[i].Describe());
            i += 1;
        };
        return result;
    }
    
    public func RestoreTriggers() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_triggers) {
            this.m_triggers[i].Restore();
            i += 1;
        };
    }

    public func CheckAnyTrigger() -> Bool {
        let i: Int32 = 0;
    
        while i < ArraySize(this.m_triggers) {
            if (this.m_triggers[i].Check()) {
                return true;
            };
            i += 1;
        };
        return false;
    }
}




//GameInstance.GetSpatialQueriesSystem(sourceObject.GetGame()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Static", fitTestOvelap);
public class LocationSystem extends ScriptableSystem {
    public let locations: array<ref<NCALocation>>;
    private let m_checkOnLocationChangeLocations: array<ref<NCALocation>>;
    private let m_checkOnTickLocations: array<ref<NCALocation>>;
    private let m_activeLocation: ref<NCALocation>;
    
    public func RestoreLocationAfterLoad() -> Void {
        let location = this.GetLocation(NCA.Context().location);
        if (IsDefined(location)) {
            location.RestoreTriggers();
            this.m_activeLocation = location;
            location.Load();
            NCA.Events().OnEnterLocation(location);
            return;
        };

        // location not found (eg uninstalled) fall back to trigger detection
        this.CheckOnTick();
        this.CheckLocationChange();
    }
    
    public func CheckLocationChange() -> Void {
        if (!NCA.Context().isSessionStarted) {
            return;
        }

        if (this.m_activeLocation != null && this.m_activeLocation.CheckAnyTrigger()) {
            return;
        };

        let i: Int32 = 0;
        while i < ArraySize(this.m_checkOnLocationChangeLocations) {
            if (this.m_checkOnLocationChangeLocations[i].CheckAnyTrigger()) {
                if (!Equals(this.m_activeLocation, this.m_checkOnLocationChangeLocations[i])) {
                    this.m_activeLocation = this.m_checkOnLocationChangeLocations[i];
                    this.m_activeLocation.Load();
                    NCA.Events().OnEnterLocation(this.m_activeLocation);
                };
                return;
            };
            i += 1;
        };

        if (!IsDefined(this.m_activeLocation)) {
            return;
        };

        NCA.Events().OnExitLocation(this.m_activeLocation);
        this.m_activeLocation.Unload();
        this.m_activeLocation = null;
    }

    public func CheckOnTick() -> Void {
        if (!NCA.Context().isSessionStarted) {
            return;
        }

        if (this.m_activeLocation != null && this.m_activeLocation.CheckAnyTrigger()) {
            return;
        };

        let i: Int32 = 0;
        while i < ArraySize(this.m_checkOnTickLocations) {
            if (this.m_checkOnTickLocations[i].CheckAnyTrigger()) {
                if (!Equals(this.m_activeLocation, this.m_checkOnTickLocations[i])) {
                    this.m_activeLocation = this.m_checkOnTickLocations[i];
                    this.m_activeLocation.Load();
                    NCA.Events().OnEnterLocation(this.m_activeLocation);
                };
                return;
            };
            i += 1;
        };

        if (!IsDefined(this.m_activeLocation)) {
            return;
        };

        NCA.Events().OnExitLocation(this.m_activeLocation);
        this.m_activeLocation.Unload();
        this.m_activeLocation = null;
    }

    public func GetLocation(tag: CName) -> ref<NCALocation> {
        let i: Int32 = 0;
        while i < ArraySize(this.locations) {
            if (Equals(this.locations[i].tag, tag)) {
                return this.locations[i];
            };
            i += 1;
        };

        return null;
    }

    public func GetSpawn(locationTag: CName, spawnTag: CName) -> ref<NCASpawn> {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return null;
        };

        let spawn = location.GetSpawn(spawnTag);
        if (spawn == null) {
            NCA.CETLog("ERROR Spawn not found by tag: " + NameToString(spawnTag));
            return null;
        };

        return spawn;
    }
    
    public func RegisterLocation(tag: CName) -> Void {
        let location: ref<NCALocation> = NCALocation.Create(tag);
        ArrayPush(this.m_checkOnLocationChangeLocations, location);
        ArrayPush(this.locations, location);
    }

    public func RegisterSpawnString(locationTag: String, tag: String, pos: Vector4, rot: Quaternion) -> Void {
        this.RegisterSpawn(StringToName(locationTag), StringToName(tag), pos, rot);
    }

    public func RegisterSpawn(locationTag: CName, tag: CName, pos: Vector4, rot: Quaternion) -> Void {
        let spawn = NCAFixedSpawn.Create(tag, pos, rot);
        this.AddSpawnToLocation(locationTag, spawn);
    }

    public func RegisterRoamingSpawnString(locationTag: String, tag: String) -> Void {
        this.RegisterRoamingSpawn(StringToName(locationTag), StringToName(tag));
    }

    public func RegisterRoamingSpawn(locationTag: CName, tag: CName) -> Void {
        let spawn = NCARoamingSpawn.Create(tag);
        this.AddSpawnToLocation(locationTag, spawn);
    }

    public func RegisterDistrictTrigger(locationTag: CName, district: gamedataDistrict) -> Void {
        let trigger = new NCADistrictLocationTrigger();
        trigger.district = district;
        this.AddTriggerToLocation(locationTag, trigger);
    }
    
    public func RegisterAreaTrigger(locationTag: CName, center: Vector4, radius: Float) -> Void {
        let trigger = new NCAAreaLocationTrigger();
        trigger.center = center;
        trigger.radius = radius;
        this.AddTriggerToLocation(locationTag, trigger);

        // area triggers need to be checked on tick, so add them to the tick check list and remove them from the location change check list
        this.AddCheckOnTickLocation(locationTag);
        this.RemoveCheckOnLocationChangeLocation(locationTag);
    }
    
    public func RegisterAfterlifeTrigger(locationTag: CName) -> Void {
        let trigger = new NCAAfterlifeLocationTrigger();
        this.AddTriggerToLocation(locationTag, trigger);
    }
    
    public func RegisterLizziesTrigger(locationTag: CName) -> Void {
        let trigger = new NCALizziesLocationTrigger();
        this.AddTriggerToLocation(locationTag, trigger);
    }
    
    public func AddTriggerToLocation(locationTag: CName, trigger: ref<NCALocationTrigger>) -> Void {
        // resolved via GetLocation, not GetIndex - a location moved to the tick list by an area
        // trigger is no longer in m_checkOnLocationChangeLocations and GetIndex would miss it
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };
        location.AddTrigger(trigger);
    }

    public func ClearLocationTriggersString(locationTag: String) -> Void {
        this.ClearLocationTriggers(StringToName(locationTag));
    }

    public func ClearLocationTriggers(locationTag: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };
        location.ClearTriggers();
    }

    public func GetLocationTriggerDescriptions(locationTag: CName) -> array<String> {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            let empty: array<String>;
            return empty;
        };
        return location.GetTriggerDescriptions();
    }

    public func RegisterPropString(locationTag: String, tag: String, pos: Vector4, rot: Quaternion) -> Void {
        this.RegisterProp(StringToName(locationTag), StringToName(tag), pos, rot, [], []);
    }

    // Registering / merge prop
    public func RegisterProp(locationTag: CName, tag: CName, pos: Vector4, rot: Quaternion, slots: array<ref<NCAInteractionSlot>>, interactions: array<ref<NCAInteractionPoint>>) -> Void {
        let location = this.GetLocation(locationTag); // GetLocation, so area-trigger locations work too
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };

        let existing = location.GetProp(tag);
        if (IsDefined(existing)) {
            existing.Merge(slots, interactions);
            return;
        };

        location.AddProp(NCAProp.Create(tag, pos, rot, slots, interactions));
    }

    private func AreaFromString(area: String) -> CName {
        return IsStringValid(area) ? StringToName(area) : n"";
    }

    public func SetPropAreaString(locationTag: String, propTag: String, area: String) -> Void {
        this.SetPropArea(StringToName(locationTag), StringToName(propTag), this.AreaFromString(area));
    }

    public func SetPropArea(locationTag: CName, propTag: CName, area: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };

        let prop = location.GetProp(propTag);
        if (prop == null) {
            NCA.CETLog("ERROR Prop not found by tag: " + NameToString(propTag));
            return;
        };

        prop.area = area;
    }

    public func RegisterPathString(locationTag: String, areaFrom: String, areaTo: String, nodes: array<Vector4>) -> Void {
        this.RegisterPath(StringToName(locationTag), this.AreaFromString(areaFrom), this.AreaFromString(areaTo), nodes);
    }

    public func RegisterPath(locationTag: CName, areaFrom: CName, areaTo: CName, nodes: array<Vector4>) -> Void {
        let path = this.GetOrCreatePath(locationTag, areaFrom, areaTo);
        if (path == null) {
            return;
        };

        let i: Int32 = 0;
        while i < ArraySize(nodes) {
            path.AddNode(nodes[i]);
            i += 1;
        };
    }

    public func RegisterPathNodeString(locationTag: String, areaFrom: String, areaTo: String, pos: Vector4) -> Void {
        this.RegisterPathNode(StringToName(locationTag), this.AreaFromString(areaFrom), this.AreaFromString(areaTo), pos);
    }

    public func RegisterPathNode(locationTag: CName, areaFrom: CName, areaTo: CName, pos: Vector4) -> Void {
        let path = this.GetOrCreatePath(locationTag, areaFrom, areaTo);
        if (path == null) {
            return;
        };

        path.AddNode(pos);
    }

    private func GetOrCreatePath(locationTag: CName, areaFrom: CName, areaTo: CName) -> ref<NCAPath> {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return null;
        };

        if Equals(areaFrom, areaTo) {
            NCA.CETLog("ERROR Path in " + NameToString(locationTag) + " starts and ends in the same area: " + NCAPath.AreaName(areaFrom));
            return null;
        };

        let existing = location.GetPath(areaFrom, areaTo);
        if (IsDefined(existing)) {
            return existing;
        };

        let path = NCAPath.Create(areaFrom, areaTo);
        location.AddPath(path);
        return path;
    }

    public func ClearLocationPathsString(locationTag: String) -> Void {
        this.ClearLocationPaths(StringToName(locationTag));
    }

    public func ClearLocationPaths(locationTag: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };
        location.ClearPaths();
    }

    public func ReserveInteractionPointString(locationTag: String, propTag: String, index: Int32) -> Bool {
        return this.ReserveInteractionPoint(StringToName(locationTag), StringToName(propTag), index);
    }

    public func ReserveInteractionPoint(locationTag: CName, propTag: CName, index: Int32) -> Bool {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            return false;
        };

        let prop = location.GetProp(propTag);
        if (prop == null) {
            return false;
        };

        if index < 0 || index >= ArraySize(prop.interactions) {
            return false;
        };

        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();

        // 1. release - detaching the explore behavior vacates whatever slots it held
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].DetachBehavior();
            i += 1;
        };

        // 2. claim
        prop.OccupyInteractionPoint(prop.interactions[index]);

        // 3. let them pick again - the reserved point now reads as occupied, so it is skipped
        i = 0;
        while i < ArraySize(squad) {
            squad[i].DetermineBehavior();
            i += 1;
        };

        return true;
    }

    public func ClearLocationSpawnsString(locationTag: String) -> Void {
        this.ClearLocationSpawns(StringToName(locationTag));
    }

    public func ClearLocationSpawns(locationTag: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };
        location.ClearSpawns();
    }

    public func ClearLocationPropsString(locationTag: String) -> Void {
        this.ClearLocationProps(StringToName(locationTag));
    }

    public func ClearLocationProps(locationTag: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };
        location.ClearProps();
    }

    public func RenameLocationString(oldTag: String, newTag: String) -> Bool {
        return this.RenameLocation(StringToName(oldTag), StringToName(newTag));
    }

    public func RenameLocation(oldTag: CName, newTag: CName) -> Bool {
        if Equals(oldTag, newTag) {
            return true;
        };

        if Equals(newTag, n"") {
            NCA.CETLog("ERROR Cannot rename a location to an empty tag");
            return false;
        };

        if this.GetLocation(newTag) != null {
            NCA.CETLog("ERROR Location already exists: " + NameToString(newTag));
            return false;
        };

        let location = this.GetLocation(oldTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(oldTag));
            return false;
        };

        location.tag = newTag;

        if Equals(NCA.Context().location, oldTag) {
            NCA.Context().location = newTag;
        };

        let registry = NCA.Persistence().m_companionRegistry;
        let i: Int32 = 0;
        while i < ArraySize(registry) {
            if Equals(registry[i].currentLocation, oldTag) {
                NCA.Persistence().m_companionRegistry[i].currentLocation = newTag;
            };
            i += 1;
        };

        return true;
    }

    public func RemoveLocationString(tag: String) -> Void {
        this.RemoveLocation(StringToName(tag));
    }

    public func RemoveLocation(tag: CName) -> Void {
        let location = this.GetLocation(tag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(tag));
            return;
        };

        if (this.m_activeLocation == location) {
            NCA.Events().OnExitLocation(location);
            location.Unload();
            this.m_activeLocation = null;
        };

        location.ClearProps();
        location.ClearPaths();

        let i: Int32 = ArraySize(this.locations) - 1;
        while i >= 0 {
            if Equals(this.locations[i].tag, tag) {
                ArrayErase(this.locations, i);
            }
            i -= 1;
        };

        i = ArraySize(this.m_checkOnLocationChangeLocations) - 1;
        while i >= 0 {
            if Equals(this.m_checkOnLocationChangeLocations[i].tag, tag) {
                ArrayErase(this.m_checkOnLocationChangeLocations, i);
            }
            i -= 1;
        };

        i = ArraySize(this.m_checkOnTickLocations) - 1;
        while i >= 0 {
            if Equals(this.m_checkOnTickLocations[i].tag, tag) {
                ArrayErase(this.m_checkOnTickLocations, i);
            }
            i -= 1;
        };
    }

    public func RegisterPropSlotString(locationTag: String, propTag: String, slotTag: String) -> Void {
        this.RegisterPropSlot(StringToName(locationTag), StringToName(propTag), StringToName(slotTag));
    }

    public func RegisterPropSlot(locationTag: CName, propTag: CName, slotTag: CName) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };

        let prop = location.GetProp(propTag);
        if (prop == null) {
            NCA.CETLog("ERROR Prop not found by tag: " + NameToString(propTag));
            return;
        };

        let slot = NCAInteractionSlot.Create(slotTag);
        ArrayPush(prop.slots, slot);
    }

    public func RegisterPropInteractionString(locationTag: String, propTag: String, type: String, slots: array<String>, pos: Vector4, rot: Quaternion) -> Void {
        let slotsAsCNames: array<CName>;
        let i: Int32 = 0;
        while i < ArraySize(slots) {
            ArrayPush(slotsAsCNames, StringToName(slots[i]));
            i += 1;
        };

        this.RegisterPropInteraction(StringToName(locationTag), StringToName(propTag), StringToName(type), slotsAsCNames, pos, rot);
    }

    public func RegisterPropInteraction(locationTag: CName, propTag: CName, type: CName, slots: array<CName>, pos: Vector4, rot: Quaternion) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + NameToString(locationTag));
            return;
        };

        let prop = location.GetProp(propTag);
        if (prop == null) {
            NCA.CETLog("ERROR Prop not found by tag: " + NameToString(propTag));
            return;
        };

        let interaction = NCAInteractionPoint.Create(type, slots, pos, rot);
        ArrayPush(prop.interactions, interaction);
    }
    
    private func AddCheckOnTickLocation(locationTag: CName) -> Void {
        let index: Int32 = this.GetIndex(locationTag);
        if index == -1 {
            NCA.CETLog("ERROR Location not found by tag: " + ToString(locationTag));
            return;
        };
        ArrayPush(this.m_checkOnTickLocations, this.m_checkOnLocationChangeLocations[index]);
    }
    
    private func AddSpawnToLocation(locationTag: CName, spawn: ref<NCASpawn>) -> Void {
        let location = this.GetLocation(locationTag);
        if (location == null) {
            NCA.CETLog("ERROR Location not found by tag: " + ToString(locationTag));
            return;
        };
        location.AddSpawn(spawn);
    }

    private func RemoveCheckOnLocationChangeLocation(locationTag: CName) -> Void {
        let index: Int32 = this.GetIndex(locationTag);
        if index == -1 {
            NCA.CETLog("ERROR Location not found by tag: " + ToString(locationTag));
            return;
        };
        ArrayErase(this.m_checkOnLocationChangeLocations, index);
    }

    private func GetIndex(locationTag: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_checkOnLocationChangeLocations) {
            if Equals(this.m_checkOnLocationChangeLocations[i].tag, locationTag) {
                return i;
            };
            i += 1;
        };

        return -1;
    }

    public func Dump() -> Void {
        let i: Int32 = 0;
        let j: Int32;

        while i < ArraySize(this.locations) {
            NCA.CETLog("Location: " + ToString(this.locations[i].tag));

            let spawns = this.locations[i].GetSpawns();
            j = 0;
            while j < ArraySize(spawns) {
                NCA.CETLog("  - " + spawns[j].Dump());
                j += 1;
            };

            let props = this.locations[i].GetProps();
            j = 0;
            while j < ArraySize(props) {
                NCA.CETLog("  - " + props[j].Dump());
                j += 1;
            };

            let paths = this.locations[i].GetPaths();
            j = 0;
            while j < ArraySize(paths) {
                NCA.CETLog("  - " + paths[j].Dump());
                j += 1;
            };

            i += 1;
        };
    }
}