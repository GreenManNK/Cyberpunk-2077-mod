@replaceMethod(AimingStateEvents)
  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimingCost: Float;
    let focusEventUI: ref<FocusPerkTriggerd>;
    let timeDilationFocusedPerk: Float;
    let weaponType: gamedataItemType;
    let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    super.OnEnter(stateContext, scriptInterface);
    if this.m_itemChanged {
      this.m_weapon = this.GetWeaponObject(scriptInterface);
      this.m_weaponHasPerfectAim = scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, n"PerfectAim", this.m_weapon.GetItemID());
    };
    aimingCost = GameInstance.GetStatsSystem(player.GetGame()).GetStatValue(Cast<StatsObjectID>(this.m_weapon.GetEntityID()), gamedataStatType.AimingCost);
    PlayerStaminaHelpers.ModifyStamina(player, -aimingCost);
    stateContext.SetConditionBoolParameter(n"AimingInterrupted", false, true);
    scriptInterface.SetAnimationParameterBool(n"has_scope", this.m_weapon.HasScope());
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    stateContext.SetTemporaryBoolParameter(n"InterruptSprintByAiming", true, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, 6);
    player.OnEnterAimState();
    this.PlayEffectOnHeldItems(scriptInterface, n"lightswitch");
    this.OnAimStartBegin(stateContext, scriptInterface);
    this.m_numZoomLevels = this.GetStaticIntParameterDefault("maxNumberOfZoomLevels", 1);
    if this.m_itemChanged {
      this.UpdateWeaponOffsetPosition(scriptInterface);
    };
    this.m_itemChanged = false;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"RelaxedCoolPerkSE") {
      StatusEffectHelper.RemoveStatusEffect(this.m_executionOwner, t"BaseStatusEffect.RelaxedCoolPerkSE");
    };
    if PlayerDevelopmentSystem.GetInstance(scriptInterface.executionOwner).IsNewPerkBought(scriptInterface.executionOwner, gamedataNewPerkType.Cool_Left_Milestone_2) == 2 {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FocusedCoolPerkSE") {
        if GameInstance.GetStatPoolsSystem(scriptInterface.owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.m_executionOwner.GetEntityID()), gamedataStatPoolType.Stamina) > TweakDBInterface.GetFloat(t"NewPerks.Cool_Left_Milestone_2.focusedStaminaThreshold", 90.00) {
          // weaponType = RPGManager.GetItemRecord(this.m_weapon.GetItemID()).ItemType().Type();
		  // if Equals(weaponType, gamedataItemType.Wea_Handgun) || Equals(weaponType, gamedataItemType.Wea_Revolver) || Equals(weaponType, gamedataItemType.Wea_SniperRifle) || Equals(weaponType, gamedataItemType.Wea_PrecisionRifle) {
          if this.m_weapon.IsRanged() || this.m_weapon.WeaponHasTag(n"Throwable") {
            StatusEffectHelper.ApplyStatusEffect(this.m_executionOwner, t"BaseStatusEffect.FocusedCoolPerkSE");
            focusEventUI = new FocusPerkTriggerd();
            focusEventUI.isActive = true;
            player.QueueEvent(focusEventUI);
            GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"cool_perk_focused_state_fullscreen", false);
            GameObject.PlaySoundEvent(scriptInterface.owner, n"time_dilation_focused_enter");
            if PlayerDevelopmentSystem.GetInstance(scriptInterface.executionOwner).IsNewPerkBought(scriptInterface.executionOwner, gamedataNewPerkType.Cool_Inbetween_Left_2) == 1 {
              timeDilationFocusedPerk = TweakDBInterface.GetFloat(t"NewPerks.Cool_Inbetween_Left_2.timeDilationStrength", 0.15);
			  if this.m_weapon.WeaponHasTag(n"Throwable") {
			    timeDilationFocusedPerk = 0.25; // time slow strength for throwable weapons
			  };
              GameInstance.GetTimeSystem(scriptInterface.owner.GetGame()).SetTimeDilation(n"focusedStatePerkDilation", 1.00 - timeDilationFocusedPerk, 12.00, n"MeleeHitEaseIn", n"MeleeHitEaseOut");
            };
          };
        };
      };
    };
    this.TryToActivateAirKerenzikovPerk(stateContext, scriptInterface);
  }
  
  
@replaceMethod(AimingStateEvents)
  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let focusedDelayedStaminaCost: Float;
    let relaxedStacks: Int32;
    let weapon: ref<WeaponObject>;
    super.OnExit(stateContext, scriptInterface);
    weapon = this.GetWeaponObject(scriptInterface);
    this.m_aim.SetAimState(animAimState.Unaimed);
    this.m_aim.SetZoomState(animAimState.Unaimed);
    this.m_isAiming = false;
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim, weapon);
    if !stateContext.GetBoolParameter(n"WeaponInSafe", true) {
      this.TriggerZoomExitSfx(scriptInterface);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, 0);
    scriptInterface.GetTargetingSystem().OnAimStop(scriptInterface.owner);
    this.BreakEffectLoopOnHeldItems(scriptInterface, n"lightswitch");
    broadcaster = scriptInterface.owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      this.m_aimBroadcast = false;
      broadcaster.RemoveActiveStimuliByName(scriptInterface.owner, gamedataStimType.CrowdIllegalAction);
    };
    this.NotifyWeaponObject(scriptInterface, false);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FocusedCoolPerkSE") {
      StatusEffectHelper.RemoveStatusEffect(this.m_executionOwner, t"BaseStatusEffect.FocusedCoolPerkSE");
      GameInstance.GetTimeSystem(scriptInterface.owner.GetGame()).UnsetTimeDilation(n"focusedStatePerkDilation", TweakDBInterface.GetCName(t"timeSystem.meleeHitStrong.easeOutCurve", n"None"));
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FocusedDelayedStaminaConsumptionSE") {
      StatusEffectHelper.RemoveStatusEffect(this.m_executionOwner, t"BaseStatusEffect.FocusedDelayedStaminaConsumptionSE");
      relaxedStacks = Cast<Int32>(StatusEffectHelper.GetStatusEffectByID(this.m_executionOwner, t"BaseStatusEffect.ReduceStaminaCostOfFocused").GetStackCount());
      focusedDelayedStaminaCost = Cast<Float>(TweakDBInterface.GetInt(t"NewPerks.Cool_Left_Milestone_2.focusedStaminaCost", 40) - TweakDBInterface.GetInt(t"NewPerks.Cool_Left_Perk_2_4.staminaCostReduction", 20) * relaxedStacks);
	  if this.m_weapon.WeaponHasTag(n"Throwable") {
	  focusedDelayedStaminaCost = focusedDelayedStaminaCost / 2.00; // stamina cost for throwable weapons
			  };
      StatusEffectHelper.RemoveStatusEffect(this.m_executionOwner, t"BaseStatusEffect.ReduceStaminaCostOfFocused");
      PlayerStaminaHelpers.ModifyStamina(this.m_executionOwner as PlayerPuppet, -focusedDelayedStaminaCost);
    };
    this.m_statusEffectSystem.RemoveStatusEffect(this.m_executionOwner.GetEntityID(), this.GetPlayerAimingStatusEffectID());
    this.RemoveAirKerenzikovPerk(stateContext, scriptInterface);
  }
