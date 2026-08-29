module NightCityAllies.Location.Trigger

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

public abstract class NCALocationTrigger {
    public func Check() -> Bool;
    public func Describe() -> String;
    public func Restore() -> Void {}
}

public class NCADistrictLocationTrigger extends NCALocationTrigger {
    public let district: gamedataDistrict;

    public func Check() -> Bool {
        return Equals(NCA.Context().district, this.district);
    }

    public func Describe() -> String {
        return "district:" + ToString(this.district);
    }
}

public class NCAAreaLocationTrigger extends NCALocationTrigger {
    public let center: Vector4;
    public let radius: Float;

    public func Check() -> Bool {
        let playerPos = NCA.Player().GetWorldPosition();
        let distance = Vector4.Distance(playerPos, this.center);
        return distance <= this.radius;
    }

    public func Describe() -> String {
        return "area:" + FloatToString(this.center.X) + "," + FloatToString(this.center.Y) + ","
            + FloatToString(this.center.Z) + "," + FloatToString(this.radius);
    }
}

public class NCAAfterlifeLocationTrigger extends NCALocationTrigger {
    private let isInside: Bool = false;

    // The game only detects the staircase as LittleChina_Afterlife
    // As a workaround, only fire the exit event when exiting on top of the stairs
    // 1047.3685 top 1037.767 bottom
    public func Check() -> Bool {
        let inside: Bool = this.isInside;
        let insideStaircase: Bool = Equals(NCA.Context().district, gamedataDistrict.LittleChina_Afterlife);
        
        if (!this.isInside && insideStaircase) {
            inside = true;
        }
        
        if (this.isInside && !insideStaircase) {
            let pos = NCA.Player().GetWorldPosition();
            if (pos.Y > 1042.50) {
                inside = false;
            }
        }
        
        this.isInside = inside;
        return inside;
    }

    public func Restore() -> Void {
        this.isInside = true;
    }

    public func Describe() -> String {
        return "afterlife";
    }
}

public class NCALizziesLocationTrigger extends NCALocationTrigger {
    private let isInside: Bool = false;

    // Some places inside Lizzies are also not recognized so make sure we're exiting out the front door
    public func Check() -> Bool {
        let inside: Bool = this.isInside;
        
        if (!this.isInside && Equals(NCA.Context().district, gamedataDistrict.Kabuki_LizziesBar)) {
            inside = true;
        }
        
        if (this.isInside && !Equals(NCA.Context().district, gamedataDistrict.Kabuki_LizziesBar)) {
            let pos = NCA.Player().GetWorldPosition();
            if (pos.X < -1197.5) {
                inside = false;
            }
        }

        this.isInside = inside;
        return inside;
    }

    public func Restore() -> Void {
        this.isInside = true;
    }

    public func Describe() -> String {
        return "lizzies";
    }
}