module NightlyNow.Utils

// -----------------------------------------------------------------------------
// LocationWithOrientation - NightlyNow Core
// -----------------------------------------------------------------------------
public class LocationWithOrientation {
    public let location: Vector4;
    public let orientation: Quaternion;

    public static func Create(location: Vector4, orientation: Quaternion) -> ref<LocationWithOrientation> {
        let loc = new LocationWithOrientation();
        loc.location = location;
        loc.orientation = orientation;
        return loc;
    }
}

