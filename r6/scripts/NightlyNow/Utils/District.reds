module NightlyNow.Utils

// -----------------------------------------------------------------------------
// District - NightlyNow Core
// -----------------------------------------------------------------------------
// Get the top level district based on the player's current location (can return null)
public func GetCurrentTopLevelDistrict() -> wref<District_Record> {
    let currentDistrict = GetPlayer(GetGameInstance()).GetPreventionSystem().GetCurrentDistrict();
    if !IsDefined(currentDistrict) {
        return null;
    }
    return GetTopLevelDistrict(currentDistrict.GetDistrictRecord());
}

// Check if the player is currently in the Badlands
public func IsPlayerInBadlands() -> Bool {
    let topLevelDistrict = GetCurrentTopLevelDistrict();
    if !IsDefined(topLevelDistrict) {
        return false;
    }
    return Equals(topLevelDistrict.Type(), gamedataDistrict.Badlands);
}

// Walks up the district hierarchy to the top-level parent
private func GetTopLevelDistrict(districtRecord: wref<District_Record>) -> wref<District_Record> {
    let parent = districtRecord.ParentDistrict();
    if IsDefined(parent) {
        return GetTopLevelDistrict(parent);
    }
    return districtRecord;
}

