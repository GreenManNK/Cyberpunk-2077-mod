// -----------------------------------------------------------------------------
// NCFCommon
// -----------------------------------------------------------------------------
//
// - Common utilities for Night City Finance.
// - Money helpers wrap the canonical TransactionSystem API from the
//   redmodding wiki (GetItemQuantity / RemoveItem with MarketSystem.Money()).
//

module NightCityFinance.Utils

import NightCityFinance.Logging.*

public func NCF_GetPlayer() -> ref<PlayerPuppet> {
    let gameInstance = GetGameInstance();
    return GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
}

public func NCF_IsPlayer(owner: ref<GameObject>) -> Bool {
    return IsDefined(owner as PlayerPuppet);
}

public func NCF_GetPlayerMoney() -> Int32 {
    let gameInstance = GetGameInstance();
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
    return transactionSystem.GetItemQuantity(player, MarketSystem.Money());
}

public func NCF_PlayerHasMoney(amount: Int32) -> Bool {
    return NCF_GetPlayerMoney() >= amount;
}

public func NCF_RemovePlayerMoney(amount: Int32) -> Bool {
    let gameInstance = GetGameInstance();
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
    return transactionSystem.RemoveItem(player, MarketSystem.Money(), amount);
}

public func NCF_TryToRemovePlayerMoney(amount: Int32) -> Bool {
    if NCF_PlayerHasMoney(amount) {
        return NCF_RemovePlayerMoney(amount);
    } else {
        return false;
    }
}

// Percentage calculation that avoids floating point - returns floor
public func NCF_CalculatePercentage(amount: Int32, percentWhole: Int32) -> Int32 {
    // percentWhole is 0-100, e.g. 15 = 15%
    return (amount * percentWhole) / 100;
}

// Tax with a 1-eddie floor (lore-immersive: Night City always taxes you).
// If the rate is non-zero and the base amount is non-zero, but the floored
// percentage rounds to zero (e.g. 8% of 5 €$ = 0), bump to 1 €$. Anything
// with a true rate of 0 (tax disabled) or amount of 0 still returns 0 ,
// we don't want to charge tax on transactions the player can't see.
//
// MUST be used by both the live deduction site (HandlePurchase) and the
// tooltip display site (NCF_BuildTaxSuffix), display math == deduction
// math is an architecture invariant.
public func NCF_CalculateTaxWithFloor(amount: Int32, percentWhole: Int32) -> Int32 {
    if percentWhole <= 0 { return 0; }
    if amount <= 0 { return 0; }
    let raw: Int32 = (amount * percentWhole) / 100;
    if raw <= 0 { return 1; }
    return raw;
}

// True once the gig "Shark in the Water" is closed and Blake Croyle is
// off the board. Quest fact `sts_wat_kab_06` matches the resource path
// leaf documented at wiki.redmodding.org/.../reference-quest-ids
// (StreetStory). Convention: 2 = completed.
//
// Falls back to "Croyle still alive" on any nil-system path, which keeps
// the contact functional even if the QuestsSystem is briefly unavailable.
public func NCF_IsCroyleDead() -> Bool {
    let gameInstance = GetGameInstance();
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(qs) { return false; }
    return qs.GetFact(n"sts_wat_kab_06") >= 2;
}

// Clamp Int32 to minimum 0
public func NCF_ClampMin0(value: Int32) -> Int32 {
    if value < 0 { return 0; }
    return value;
}

// Get the player's Street Cred level
public func NCF_GetStreetCredLevel() -> Int32 {
    let gameInstance = GetGameInstance();
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) { return 0; }
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    if !IsDefined(devData) { return 0; }
    return devData.GetProficiencyLevel(gamedataProficiencyType.StreetCred);
}

// Calculate the player's credit limit based on Street Cred
// NOTE: NCF_GetCreditLimit, NCF_CanAffordWithCredit, NCF_SpendWithCredit
// are implemented in NCFMainSystem.reds to avoid circular imports.
