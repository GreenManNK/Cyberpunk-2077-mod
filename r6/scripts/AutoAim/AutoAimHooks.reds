module AutoAim

@wrapMethod(AimingStateEvents)
protected func OnAimStartBegin(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let player: ref<PlayerPuppet>;

  wrappedMethod(stateContext, scriptInterface);

  player = scriptInterface.executionOwner as PlayerPuppet;
  if IsDefined(player) {
    AutoAimHelper.OnADSStart(player);
  }
}

@wrapMethod(AimingStateEvents)
protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let player: ref<PlayerPuppet>;

  wrappedMethod(timeDelta, stateContext, scriptInterface);

  player = scriptInterface.executionOwner as PlayerPuppet;
  if !IsDefined(player) {
    return;
  }

  AutoAimHelper.OnADSTick(player, timeDelta);
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  let handled: Bool;

  handled = wrappedMethod(action, consumer);

  if Equals(ListenerAction.GetName(action), n"RangedAttack") && ListenerAction.IsButtonJustPressed(action) {
    AutoAimHelper.OnFirePressed(this);
  }

  return handled;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
  let handled: Bool;

  handled = wrappedMethod(evt);

  if IsDefined(evt) && IsDefined(evt.staticData) {
    if evt.staticData.GetID() == t"BaseStatusEffect.PlayerAiming" {
      AutoAimHelper.OnADSEnd(this);
    }
  }

  return handled;
}
