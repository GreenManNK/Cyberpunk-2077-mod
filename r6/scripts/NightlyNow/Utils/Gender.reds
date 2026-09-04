module NightlyNow.Utils

// -----------------------------------------------------------------------------
// Gender - NightlyNow Core
// -----------------------------------------------------------------------------
public func IsPlayerFemale() -> Bool = Equals(GetPlayer(GetGameInstance()).GetResolvedGenderName(), n"Female");

