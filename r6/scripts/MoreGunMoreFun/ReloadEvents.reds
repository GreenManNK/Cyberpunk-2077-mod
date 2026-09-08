@replaceMethod(ReloadEvents)
  protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let reloadTime: Float;
    let timeDilationDurationCoolPerk: Float;
    let timeDilationStrengthCoolPerk: Float;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    stateContext.SetPermanentBoolParameter(n"FinishedReload", false, true);
    this.m_animReloadData.emptyReload = !this.m_weaponHasAutoLoader && weapon.IsMagazineEmpty();
    if NotEquals(this.m_lastReloadWasEmpty, this.m_animReloadData.emptyReload) {
      this.m_lastReloadWasEmpty = this.m_animReloadData.emptyReload;
      this.m_animReloadDataDirty = true;
    };
    this.ShowAttackPreview(false, weapon, scriptInterface, stateContext);
    this.m_uninteruptibleSet = false;
    this.SetUninteruptibleReloadParams(stateContext, true);
    if this.m_animReloadData.emptyReload {
      reloadTime = weapon.StartReload(this.m_animReloadData.emptyDuration);
    } else {
      reloadTime = weapon.StartReload(this.m_animReloadData.loopDuration);
    };
    this.SetBlackboardFloatVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LatestWeaponReloadTime, reloadTime);
    this.RefreshReloadPermanentFloats(stateContext);
    this.OnEnterNonChargeState(weapon, stateContext, scriptInterface);
    this.EndShootingSequence(weapon, stateContext, scriptInterface);
    scriptInterface.TEMP_WeaponStopFiring();
    stateContext.SetConditionBoolParameter(n"ReloadInputPressed", false, true);
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
    if !this.m_canReloadWhileSprinting {
      stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    };
    if !IsDefined(this.m_randomSync) {
      this.m_randomSync = new AnimFeature_SelectRandomAnimSync();
      this.m_randomSync.value = -1;
    };
    this.m_randomSync.value = RandDifferent(this.m_randomSync.value, 3);
    if IsDefined(this.m_randomSync) {
      scriptInterface.SetAnimationParameterFeature(n"RandomSync", this.m_randomSync);
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"DeadeyeQuickReloadSE") {
      // if this.IsCoolFirearmWeaponType(WeaponObject.GetWeaponType(weapon.GetItemID())) {	
      if true {
        timeDilationStrengthCoolPerk = TweakDBInterface.GetFloat(t"NewPerks.Cool_Left_Perk_3_2.timeDilationStrength", 0.70);
        timeDilationDurationCoolPerk = TweakDBInterface.GetFloat(t"NewPerks.Cool_Left_Perk_3_2.timeDilationDuration", 2.00);
        scriptInterface.GetTimeSystem().SetTimeDilation(n"coolReloadPerkDilation", 1.00 - timeDilationStrengthCoolPerk, timeDilationDurationCoolPerk, n"MeleeHitEaseIn", n"MeleeHitEaseOut");
        GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, n"cool_perk_focused_state_fullscreen");
        GameObject.PlaySoundEvent(scriptInterface.executionOwner, n"time_dilation_focused_enter");
        this.m_isCoolPerkReload = true;
        StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DeadeyeQuickReloadSE");
      };
    };
    this.ActivateReloadAnimData(stateContext, scriptInterface);
    WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.EnterReload);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, 2);
    this.WeaponTransistionRemoveWeaponTriggerEffects(GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()));
    GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()).AddTriggerEffectIfPlayerNotInVehicleDriverSeat(scriptInterface.executionOwner, n"te_off", n"PSM_ReloadOnEnter_OFF");
  }
