module NightlyNow.Utils

// -----------------------------------------------------------------------------
// LifePath - NightlyNow Core
// -----------------------------------------------------------------------------
public func IsCorpo() -> Bool = Equals(GetPlayerLifePath(), gamedataLifePath.Corporate);

public func IsNomad() -> Bool = Equals(GetPlayerLifePath(), gamedataLifePath.Nomad);

public func IsStreetKid() -> Bool = Equals(GetPlayerLifePath(), gamedataLifePath.StreetKid);

private func GetPlayerLifePath() -> gamedataLifePath = PlayerDevelopmentSystem.GetData(GetPlayer(GetGameInstance())).GetLifePath();

