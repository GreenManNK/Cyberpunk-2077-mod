
public class ReloadStartPrereqState extends PrereqState {

  public let m_listenerWeaponInt: ref<CallbackHandle>;

  public let m_listenerActiveWeaponVariant: ref<CallbackHandle>;

  private let m_reloadingInProgress: Bool;

  protected cb func OnWeaponStateUpdate(value: Int32) -> Bool {
    if Equals(IntEnum<gamePSMRangedWeaponStates>(value), gamePSMRangedWeaponStates.Reload) {
      this.m_reloadingInProgress = true;
      this.OnChanged(true);
    } else {
      if this.m_reloadingInProgress {
        this.m_reloadingInProgress = false;
        this.OnChanged(false);
      };
    };
  }

  protected cb func OnInventoryChangeStateUpdate(value: Variant) -> Bool {
    this.m_reloadingInProgress = false;
    this.OnChanged(false);
  }
}

public class ReloadStartPrereq extends IScriptablePrereq {

  protected func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let bb: ref<IBlackboard>;
    let castedState: ref<ReloadStartPrereqState>;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      castedState = state as ReloadStartPrereqState;
      bb = player.GetPlayerStateMachineBlackboard();
      castedState.m_listenerWeaponInt = bb.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon, castedState, n"OnWeaponStateUpdate");
      bb = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
      castedState.m_listenerActiveWeaponVariant = bb.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, castedState, n"OnInventoryChangeStateUpdate");
    };
    return false;
  }

  protected func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let bb: ref<IBlackboard>;
    let castedState: ref<ReloadStartPrereqState>;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      castedState = state as ReloadStartPrereqState;
      bb = player.GetPlayerStateMachineBlackboard();
      if IsDefined(castedState.m_listenerWeaponInt) {
        bb.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon, castedState.m_listenerWeaponInt);
      };
      bb = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
      if IsDefined(castedState.m_listenerActiveWeaponVariant) {
        bb.UnregisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.WeaponRecordID, castedState.m_listenerActiveWeaponVariant);
      };
    };
  }

  protected func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<ReloadStartPrereqState>;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      castedState = state as ReloadStartPrereqState;
      castedState.OnChanged(false);
    };
  }
}
