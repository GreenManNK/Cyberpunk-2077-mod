module NightCityAllies.Location.Entity

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

public abstract class NCASpawn {
    public let tag: CName;

    // Lets tooling tell a fixed spawn (has pos/rot) from a roaming one without type probing
    public func IsFixed() -> Bool;

    public func Dump() -> String {
        return "NCASpawn: " + NameToString(this.tag) + ", Fixed: " + (this.IsFixed() ? "yes" : "no");
    }
}

public class NCAFixedSpawn extends NCASpawn {
    public let pos: Vector4;
    public let rot: Quaternion;

    public static func Create(tag: CName, pos: Vector4, rot: Quaternion) -> ref<NCAFixedSpawn> {
        let s = new NCAFixedSpawn();
        s.tag = tag;
        s.pos = pos;
        s.rot = rot;
        return s;
    }

    public func IsFixed() -> Bool = true;
}

public class NCARoamingSpawn extends NCASpawn {
    public static func Create(tag: CName) -> ref<NCARoamingSpawn> {
        let s = new NCARoamingSpawn();
        s.tag = tag;
        return s;
    }

    public func IsFixed() -> Bool = false;
}
