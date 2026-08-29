module FpsCounter

public class FPSCounterChangeStateEvent extends Event {
    public let enabled: Bool;
}

@wrapMethod(PlayerPuppet)
protected cb func OnMakePlayerVisibleAfterSpawn(evt: ref<EndGracePeriodAfterSpawn>) -> Bool {
  wrappedMethod(evt);

  let event = new FPSCounterChangeStateEvent();
  event.enabled = true;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(event);
}

@addMethod(inkHUDGameController)
protected cb func OnChangeState(evt: ref<FPSCounterChangeStateEvent>) -> Bool {
  if this.IsA(n"gameuiFPSCounterGameController") {
    this.GetRootWidget().SetVisible(evt.enabled);
  }
}
