@addMethod(PlayerPuppet)
public func COSV_IsSummonLockActive() -> Bool {
  let questSystem = GameInstance.GetQuestsSystem(this.GetGame());

  if !IsDefined(questSystem) {
    return false;
  };

  return questSystem.GetFact(n"cosv_summon_lock") > 0;
}

@addMethod(PlayerPuppet)
public func COSV_QueueSummonLockNotification() -> Void {
  let notificationEvent: ref<UIInGameNotificationEvent> = new UIInGameNotificationEvent();
  notificationEvent.m_notificationType = UIInGameNotificationType.ActionRestriction;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(notificationEvent);
}

@wrapMethod(VehicleSystem)
public final static func IsSummoningVehiclesRestricted(game: GameInstance) -> Bool {
  let player: ref<PlayerPuppet> = GetPlayer(game);

  if IsDefined(player) && player.COSV_IsSummonLockActive() {
    return true;
  };

  return wrappedMethod(game);
}

@wrapMethod(PlayerPuppet)
private final func ProcessCallVehicleAction(type: gameinputActionType) -> Void {
  if this.COSV_IsSummonLockActive() {
    this.COSV_QueueSummonLockNotification();
    return;
  };

  wrappedMethod(type);
}

@wrapMethod(VehicleWheelDecisions)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  let player: ref<PlayerPuppet>;

  if ListenerAction.IsButtonJustPressed(action) {
    player = GetPlayer(GetGameInstance());

    if IsDefined(player) && player.COSV_IsSummonLockActive() {
      player.COSV_QueueSummonLockNotification();
      return false;
    };
  };

  return wrappedMethod(action, consumer);
}
