module NightCityFinance.Amenities

import NightCityFinance.Core.NCFFinanceState
import NightCityFinance.Settings.NCFSettings
import NightCityFinance.Utils.*
import NightCityFinance.Main.NCFMainSystem

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

private func NCF_IsSuspendedInApartment(gi: GameInstance) -> Bool {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return false; }
    if !state.IsAmenitiesSubscribed() || !state.IsAmenitiesSuspended() { return false; }
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) { return false; }
    let bb: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
    if !IsDefined(bb) { return false; }
    return bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) < 3;
}

private func NCF_ChargeFlatFee(gi: GameInstance, fee: Int32, label: String) -> Void {
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return; }
    let wallet: Int32 = NCF_GetPlayerMoney();
    if wallet >= fee {
        NCF_RemovePlayerMoney(fee);
        state.PayAmenities(fee);
    } else {
        if wallet > 0 {
            NCF_RemovePlayerMoney(wallet);
            state.PayAmenities(wallet);
        }
        state.AddAmenitiesDebt(fee - wallet);
    }
    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 4.0;
    msg.message = "NC AMENITIES CORP — Illegal " + label + " use. Charged " + ToString(fee) + " €$.";
    msg.type = SimpleMessageType.Negative;
    GameInstance.GetBlackboardSystem(gi)
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
}

// ---------------------------------------------------------------------------
// Shower — warning popup on workspot entry when suspended.
// Actual per-second deduction runs in NCFMainSystem.ProcessAmenitiesSuspendedFee().
// ---------------------------------------------------------------------------

@wrapMethod(PlayerPuppet)
protected cb func OnWorkspotStartedEvent(evt: ref<WorkspotStartedEvent>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) { sys.SetShowerOn(true); }
    let state: ref<NCFFinanceState> = NCFFinanceState.Get();
    if !IsDefined(state) { return result; }
    if !state.IsAmenitiesSubscribed() || !state.IsAmenitiesSuspended() { return result; }
    let bb: ref<IBlackboard> = this.GetPlayerStateMachineBlackboard();
    if !IsDefined(bb) { return result; }
    if bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones) >= 3 { return result; }
    let settings: ref<NCFSettings> = NCFSettings.Get();
    let fee: Int32 = IsDefined(settings) ? settings.amenitiesSuspendedFeePerSec : 25;
    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 5.0;
    msg.message = "NC AMENITIES CORP — SERVICES SUSPENDED. Illegal use detected. You are being charged " + ToString(fee) + " €$/sec.";
    msg.type = SimpleMessageType.Negative;
    GameInstance.GetBlackboardSystem(this.GetGame())
        .Get(GetAllBlackboardDefs().UI_Notifications)
        .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
    return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnWorkspotFinishedEvent(evt: ref<WorkspotFinishedEvent>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) { sys.SetShowerOn(false); }
    return result;
}

// ---------------------------------------------------------------------------
// Toilet — flat 100 €$ on flush when suspended
// ---------------------------------------------------------------------------

@wrapMethod(Toilet)
protected cb func OnFlush(evt: ref<Flush>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if NCF_IsSuspendedInApartment(this.GetGame()) && IsDefined(sys) && sys.TryToiletCharge() {
        NCF_ChargeFlatFee(this.GetGame(), 100, "toilet");
    }
    return result;
}

// ---------------------------------------------------------------------------
// TV — warning popup on toggle-on + per-second fee via main system loop.
// Lore: cable TV is on the grid, billed as a utility like water/power.
// ---------------------------------------------------------------------------

@wrapMethod(TV)
protected cb func OnToggleON(evt: ref<ToggleON>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let gi: GameInstance = this.GetGame();
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) { sys.SetTvOn(true); }
    if NCF_IsSuspendedInApartment(gi) {
        let settings: ref<NCFSettings> = NCFSettings.Get();
        let fee: Int32 = IsDefined(settings) ? settings.amenitiesTvFeePerSec : 15;
        let msg: SimpleScreenMessage;
        msg.isShown = true;
        msg.duration = 5.0;
        msg.message = "NC AMENITIES CORP — SERVICES SUSPENDED. Illegal use detected. You are being charged " + ToString(fee) + " €$/sec.";
        msg.type = SimpleMessageType.Negative;
        GameInstance.GetBlackboardSystem(gi)
            .Get(GetAllBlackboardDefs().UI_Notifications)
            .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
    }
    return result;
}

@wrapMethod(TV)
protected cb func OnTogglePower(evt: ref<TogglePower>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    // TV toggled off — clear billing flag
    let sys: ref<NCFMainSystem> = NCFMainSystem.Get();
    if IsDefined(sys) { sys.SetTvOn(false); }
    return result;
}
