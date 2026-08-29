module NightCityAllies.Location.Entity

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

// Walk path for NPCs to get from one navmesh to another
public class NCAPath {
    public let areaFrom: CName;
    public let areaTo: CName;
    public let nodes: array<Vector4>;

    public static func Create(areaFrom: CName, areaTo: CName) -> ref<NCAPath> {
        let path = new NCAPath();
        path.areaFrom = areaFrom;
        path.areaTo = areaTo;
        return path;
    }

    public func AddNode(pos: Vector4) -> Void {
        ArrayPush(this.nodes, pos);
    }

    public func GetExit(out pos: Vector4) -> Bool {
        if ArraySize(this.nodes) == 0 {
            return false;
        }

        pos = this.nodes[ArraySize(this.nodes) - 1];
        return true;
    }

    public func IsUsable() -> Bool {
        return ArraySize(this.nodes) > 0;
    }

    public static func AreaName(area: CName) -> String {
        return IsNameValid(area) ? NameToString(area) : "default";
    }

    public func Dump() -> String {
        return "Path: " + NCAPath.AreaName(this.areaFrom) + " -> " + NCAPath.AreaName(this.areaTo)
            + ", Nodes: " + IntToString(ArraySize(this.nodes));
    }
}
