module NightlyNow.Utils

// -----------------------------------------------------------------------------
// Quest - NightlyNow Core
// -----------------------------------------------------------------------------
public enum GameArea {
    NightCity = 0,
    DogTown = 1,
}

public func IsAreaUnlocked(gameArea: GameArea) -> Bool {
    let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());

    // NC available
    switch gameArea {
        case GameArea.NightCity:
            let watsonFact: Int32 = questsSystem.GetFact(n"watson_prolog_lock");
            let unlockFact: Int32 = questsSystem.GetFact(n"unlock_car_hud_dpad");
            return NotEquals(watsonFact, 1) && NotEquals(unlockFact, 0);
        case GameArea.DogTown:
            let dogtownFact: Int32 = questsSystem.GetFact(n"q302_done");
            return Equals(dogtownFact, 1);
    }
    return true;
}

public func IsPlayerInDialogOrCutscene() -> Bool {
    let player = GetPlayer(GetGameInstance());
    if PlayerPuppet.GetSceneTier(player) != 1 {
        // Player is in dialog or cutscene
        return true;
    }
    return false;
}

public func IsPlayerInPhotoMode() -> Bool {
    let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().PhotoMode);
    return bb.GetBool(GetAllBlackboardDefs().PhotoMode.IsActive);
}

public func IsPlayerInMenu() -> Bool {
    let uiSystemBlackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UI_System);
    if uiSystemBlackboard.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) {
        return true;
    }
    return false;
}

