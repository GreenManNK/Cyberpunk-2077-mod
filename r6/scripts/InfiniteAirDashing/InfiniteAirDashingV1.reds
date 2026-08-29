@replaceMethod(LocomotionTransition)
protected final const func WantsToDodge(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let disableAirDash: StateResultBool;
  let isAirDashPerkBought: Bool;
  let isInCooldown: Bool;
  let isStaminaPositive: Bool;
  if !scriptInterface.HasStatFlag(gamedataStatType.HasDodge) {
    return false;
  };
  if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HealFood3") {
    return false;
  };
  isInCooldown = StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeCooldown") || StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirCooldown");
  if isInCooldown {
    return false;
  };
  disableAirDash = stateContext.GetPermanentBoolParameter(n"disableAirDash");
  isAirDashPerkBought = PlayerDevelopmentSystem.GetInstance(scriptInterface.executionOwner).IsNewPerkBought(scriptInterface.executionOwner, gamedataNewPerkType.Reflexes_Central_Milestone_3) == 3;
  isStaminaPositive = GameInstance.GetStatPoolsSystem(scriptInterface.executionOwner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID()), gamedataStatPoolType.Stamina, true) > 0.00;
  if !this.IsTouchingGround(scriptInterface) && (!isAirDashPerkBought || !isStaminaPositive) {
    return false;
  };
  // if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
  //   return false;
  // };
  if scriptInterface.IsActionJustTapped(n"Dodge") {
    if scriptInterface.IsMoveInputConsiderable() {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", scriptInterface.GetInputHeading(), true);
      scriptInterface.localBlackboard.SetFloat(GetAllBlackboardDefs().PlayerStateMachine.DodgeTimeStamp, EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())));
      return true;
    };
    if this.GetStaticBoolParameterDefault("dodgeWithNoMovementInput", false) {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", -180.00, true);
      scriptInterface.localBlackboard.SetFloat(GetAllBlackboardDefs().PlayerStateMachine.DodgeTimeStamp, EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())));
      return true;
    };
  };
  if this.WantsToDodgeFromMovementInput(stateContext, scriptInterface) && GameplaySettingsSystem.GetMovementDodgeEnabled(scriptInterface.executionOwner) {
    return true;
  };
  return false;
}