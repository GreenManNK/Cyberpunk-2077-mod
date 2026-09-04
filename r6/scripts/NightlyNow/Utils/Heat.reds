module NightlyNow.Utils

// -----------------------------------------------------------------------------
// Heat - NightlyNow Core
// -----------------------------------------------------------------------------
public func ApplyHeat(heatToApply: Int32) {
    // Current wanted level
    let ps: wref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
    if !IsDefined(ps) {
        return;
    }

    let currentWantedLevel = Cast<Int32>(ps.GetHeatStageAsInt());
    if currentWantedLevel >= heatToApply {
        // Already on or above wanted level
        return;
    }

    let setWantedLevel: ref<SetWantedLevel> = new SetWantedLevel();
    setWantedLevel.m_forcePlayerPositionAsLastCrimePoint = true;
    setWantedLevel.m_wantedLevel = GetHeatStage(heatToApply);

    ps.QueueRequest(setWantedLevel);
}

private func GetHeatStage(heatValue: Int32) -> EPreventionHeatStage {
    switch heatValue {
        case 1:
            return EPreventionHeatStage.Heat_1;
        case 2:
            return EPreventionHeatStage.Heat_2;
        case 3:
            return EPreventionHeatStage.Heat_3;
        case 4:
            return EPreventionHeatStage.Heat_4;
        case 5:
            return EPreventionHeatStage.Heat_5;
    }

    return EPreventionHeatStage.Heat_0;
}

