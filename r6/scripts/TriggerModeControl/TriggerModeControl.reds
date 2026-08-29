module TriggerModeControl
import TriggerModeControl.Config.*

///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponObject

// helper methods
@addMethod(WeaponObject)
protected final func HasMultipleValidTriggers() -> Bool {
  let triggerModesArray: array<wref<TriggerMode_Record>>;
  this.GetWeaponRecord().TriggerModes(triggerModesArray);
  if ArraySize(triggerModesArray) > 1 {
    let secondaryTrigger: wref<TriggerMode_Record> = this.GetWeaponRecord().SecondaryTriggerMode();
    return IsDefined(secondaryTrigger);
  };
  return false;
}

@addMethod(WeaponObject)
protected final func WeaponHasTagOnTrigger(tag: CName) -> Bool {
  if this.GetOwner().IsPlayer() {
    if this.WeaponHasTag(tag) {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(this.GetOwner(), t"BaseStatusEffect.PlayerSecondaryTrigger") {
      return this.WeaponHasTag(StringToName(NameToString(tag)+"Secondary"));
    } else {
      return this.WeaponHasTag(StringToName(NameToString(tag)+"Primary"));
    };
  };
  return false;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// EquipmentBaseTransition, UnequipCycleEvents

// check if weapon is tagged and handle manual control partecipation
@wrapMethod(EquipmentBaseTransition)
protected final const func HandleWeaponEquip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
  wrappedMethod(scriptInterface, stateContext, stateMachineInstanceData, item);
  let weaponObject: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  let isTech: Bool = Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).Evolution().Type(), gamedataWeaponEvolution.Tech);
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  if weaponObject.WeaponHasTag(n"ManualTriggerSwap") {
    stateContext.SetPermanentBoolParameter(n"isManualTriggerCtrlApplied", true, true);
  };
  if !stateContext.GetBoolParameter(n"isManualTriggerCtrlApplied", true) && weaponObject.HasMultipleValidTriggers() && ((settings.overrideOthers && !isTech) || (settings.overrideTech && isTech)) {
    stateContext.SetPermanentBoolParameter(n"isManualTriggerCtrlApplied", true, true);
    stateContext.SetPermanentBoolParameter(n"isManualTriggerCtrlOverride", true, true);
  };
  stateContext.SetPermanentBoolParameter(n"isSecondaryTriggerMode", false, true);
}

@wrapMethod(UnequipCycleEvents)
protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
  if this.IsRightHandLogic(this.stateMachineInstanceData) && Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
    stateContext.RemovePermanentBoolParameter(n"isManualTriggerCtrlApplied");
    stateContext.RemovePermanentBoolParameter(n"isManualTriggerCtrlOverride");
    stateContext.RemovePermanentBoolParameter(n"isSecondaryTriggerMode");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
  };
  wrappedMethod(stateContext, scriptInterface);
}


///////////////////////////////////////////////////////////////////////////////////////////////
// InputContextTransitionEvents

@addMethod(InputContextTransitionEvents)
private final func AddTriggerModeCtrlInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, group: CName) -> Void {
  if stateContext.GetBoolParameter(n"isManualTriggerCtrlApplied", true) {
    let weaponObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    let weaponRecord: wref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
    let primaryKey: CName = this.GetTriggerModeKey(weaponObject, weaponRecord, 1);
    let secondaryKey: CName = this.GetTriggerModeKey(weaponObject, weaponRecord, 2);
    if Equals(primaryKey, secondaryKey) {
      if weaponObject.WeaponHasTag(n"AimingBoundAttacks") {
        return;
      };
      if stateContext.GetBoolParameter(n"isSecondaryTriggerMode", true) {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Secondary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      } else {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Primary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      };
      return;
    };
    if stateContext.GetBoolParameter(n"isSecondaryTriggerMode", true) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(secondaryKey), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    } else {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(primaryKey), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    };
  };
}

// helper method
@addMethod(InputContextTransitionEvents)
private final func GetTriggerModeKey(weaponObject: wref<WeaponObject>, weaponRecord: wref<WeaponItem_Record>, trigger: Int32) -> CName {
  let triggerStr: String;
  let triggerType: gamedataTriggerMode;
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  if Equals(trigger, 2) {
    triggerType = weaponRecord.SecondaryTriggerMode().Type();
    triggerStr = "Secondary";
  } else {
    triggerType = weaponRecord.PrimaryTriggerMode().Type();
    triggerStr = "Primary";
  };
  if settings.overrideAuto || weaponObject.WeaponHasTag(n"ForceAuto") || weaponObject.WeaponHasTag(StringToName("ForceAuto" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-FullAuto";
  };
  if weaponObject.WeaponHasTag(n"RemoveAuto") || weaponObject.WeaponHasTag(StringToName("RemoveAuto" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-SemiAuto";
  };
  if weaponObject.WeaponHasTag(n"InstantCharge") || weaponObject.WeaponHasTag(StringToName("InstantCharge" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-SemiAuto";
  };
  switch triggerType {
    case gamedataTriggerMode.FullAuto: return n"Mod-TriggerModeCtrl-FullAuto";
    case gamedataTriggerMode.Charge: return n"Mod-TriggerModeCtrl-Charge";
    case gamedataTriggerMode.Burst: return n"Mod-TriggerModeCtrl-Burst";
  };
  return n"Mod-TriggerModeCtrl-SemiAuto";
}

// add input hint
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"Ranged");
  let psmBodyCarrying: gamePSMBodyCarrying = IntEnum<gamePSMBodyCarrying>(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyCarrying));
  if Equals(psmBodyCarrying, gamePSMBodyCarrying.Carry) {
    this.ShowBodyCarryInputHints(stateContext, scriptInterface);
  };
}

// Aiming state: update input hint
@wrapMethod(AimingContextEvents)
protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"Ranged");
}

// Vehicle Combat: add input hint
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"VehicleDriverCombat");
}

// Vehicle Combat: add input hint
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatTPPInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"VehicleDriverCombatTPP");
}

// hide "Charged Shot" hint when charge is instant
@wrapMethod(DefaultTransition)
public final static func IsChargeRangedWeapon(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let result: Bool = wrappedMethod(scriptInterface);
  if result {
    let weapon: ref<WeaponObject> = GameInstance.GetTransactionSystem(scriptInterface.owner.GetGame()).GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if weapon.WeaponHasTagOnTrigger(n"InstantCharge") {
      return false;
    };
    if Equals(scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatType.ChargeTime), 0.00) {
      return false;
    };
  };
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// CycleTriggerModeDecisions and CycleTriggerModeEvents, ReadyEvents

// handle enter conditions
@replaceMethod(CycleTriggerModeDecisions)
protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let weaponObject: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
  this.EnableOnEnterCondition(weaponObject.HasMultipleValidTriggers());
}

@replaceMethod(CycleTriggerModeDecisions)  
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  if stateContext.GetBoolParameter(n"isManualTriggerCtrlApplied", true) {
    return scriptInterface.IsActionJustPressed(n"TriggerSwap");
  };
  if stateContext.IsStateActive(n"UpperBody", n"aimingState") && this.IsPrimaryTriggerModeActive(scriptInterface) {
    return true;
  };
  if !stateContext.IsStateActive(n"UpperBody", n"aimingState") && !this.IsPrimaryTriggerModeActive(scriptInterface) {
    return true;
  };
  return false;
}

@wrapMethod(CycleTriggerModeEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  switch stateContext.GetBoolParameter(n"isSecondaryTriggerMode", true) {
    case true:
      stateContext.SetPermanentBoolParameter(n"isSecondaryTriggerMode", false, true);
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
      break;
    default:
      stateContext.SetPermanentBoolParameter(n"isSecondaryTriggerMode", true, true);
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
  };
  if stateContext.GetBoolParameter(n"isManualTriggerCtrlApplied", true) {                                                          // manual swap
    this.SwitchTriggerMode(stateContext, scriptInterface);
    PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);               // refresh button hints
    GameObject.PlaySoundEvent(scriptInterface.executionOwner, n"w_gun_pistol_power_unity_trigger");                                // play sound
  };
  if weaponObject.WeaponHasTag(n"ResetChargeOnSwap") {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    if statPoolsSystem.HasActiveStatPool(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge) {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, 0.0, scriptInterface.executionOwner);
    };
  };
}

// refresh button hints
@wrapMethod(ReadyEvents)
protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);                 // refresh button hints
}


///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponTransition

// grab correct stats
@replaceMethod(WeaponTransition)
protected final const func IsPrimaryTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  return false;
}

@replaceMethod(WeaponTransition)
protected final func SetupStandardShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
  let burstCycleTimeStat: gamedataStatType = gamedataStatType.CycleTime_Burst;
  let burstNumShots: gamedataStatType = gamedataStatType.NumShotsInBurst;
  if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    burstCycleTimeStat = gamedataStatType.CycleTime_BurstSecondary;
    burstNumShots = gamedataStatType.NumShotsInBurstSecondary;
  };
  this.StartShootingSequence(stateContext, scriptInterface, statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.PreFireTime), statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), burstCycleTimeStat), Cast<Int32>(statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), burstNumShots)), false);
}

// select correct attack
@replaceMethod(WeaponTransition)
protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
  let attackRecord: ref<Attack_Record>;
  let isSecondary: Bool = stateContext.GetBoolParameter(n"isSecondaryTriggerMode", true);
  let magazine: InnerItemData;
  let rangedAttack: ref<RangedAttack_Record>;
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let weaponCharge: Float;
  let chargeReadyPercentage: Float = GameInstance.GetStatsSystem(weaponObject.GetGame()).GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.ChargeReadyPercentage);
  this.m_rangedAttackPackage = weaponObject.GetCurrentRangedAttack();
  weaponObject.GetItemData().GetItemPart(magazine, t"AttachmentSlots.DamageMod");
  if this.m_magazineID != ItemID.GetTDBID(InnerItemData.GetItemID(magazine)) {
    this.m_magazineID = ItemID.GetTDBID(InnerItemData.GetItemID(magazine));
    if TDBID.IsValid(this.m_magazineID) {
      this.m_magazineAttack = TDBID.Create(TweakDBInterface.GetString(this.m_magazineID + t".overrideAttack", ""));
      this.m_rangedAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord(this.m_magazineAttack);
    } else {
      this.m_magazineAttack = t"NewPerks.Intelligence_Left_Milestone_2.preventInQueueAgain";
    };
  };
  
  if weaponObject.WeaponHasTag(n"AimingBoundAttacks") || stateContext.GetBoolParameter(n"isManualTriggerCtrlOverride", true) {
    isSecondary = stateContext.IsStateActive(n"UpperBody", n"aimingState");
  };
  
  if chargeReadyPercentage <= 0.0 {
    chargeReadyPercentage = 1.0;
  };
  weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
  rangedAttack = weaponCharge >= chargeReadyPercentage ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
  if scriptInterface.GetTimeSystem().IsTimeDilationActive() {
    if isSecondary {
      attackRecord = rangedAttack.SecondaryPlayerTimeDilated();
    };
    if !IsDefined(attackRecord) {
      attackRecord = rangedAttack.PlayerTimeDilated();
    };
  };
  if !IsDefined(attackRecord) && isSecondary {
    attackRecord = rangedAttack.SecondaryPlayerAttack();
  };
  if !IsDefined(attackRecord) {
    attackRecord = rangedAttack.PlayerAttack();
  };
  return attackRecord;
}

// ForceAuto
@wrapMethod(WeaponTransition)
protected final const func CanHoldToShoot(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weaponObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  if weaponObject.WeaponHasTagOnTrigger(n"ForceAuto") {
    return true;
  };
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  let result: Bool = wrappedMethod(scriptInterface);
  if settings.overrideAuto {
    result = true;
  };
  if result && settings.overrideHoldCharge {
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge) && scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID()), gamedataStatType.CanControlFullyChargedWeapon) > 0.0 {
      result = false;
    };
  };
  return result;
}

// RemoveAuto
@wrapMethod(WeaponTransition)
protected final const func IsFullAutoAction(weaponObject: ref<WeaponObject>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let result: Bool = wrappedMethod(weaponObject, stateContext, scriptInterface);
  if weaponObject.WeaponHasTagOnTrigger(n"RemoveAuto") {
    return scriptInterface.IsActionJustPressed(n"RangedAttack");
  };
  return result;
}

// NoAutomaticReload
@wrapMethod(NoAmmoDecisions)
protected final const func ToReload(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let result: Bool = wrappedMethod(stateContext, scriptInterface);
  if this.GetWeaponObject(scriptInterface).WeaponHasTag(n"NoAutomaticReload") {
    if !scriptInterface.IsActionJustPressed(n"RangedAttack") && !scriptInterface.IsActionJustPressed(n"Reload") {
      return false;
    };
  };
  return result;
}

// PartialChargeFire
@replaceMethod(ChargeDecisions)
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let lastShotTime: Double;
  let actionPressCount: Uint32 = scriptInterface.GetActionPressCount(n"RangedAttack");
  let lastChargePressCount: StateResultInt = stateContext.GetPermanentIntParameter(n"LastChargePressCount");
  if lastChargePressCount.valid && lastChargePressCount.value == Cast<Int32>(actionPressCount) {
    if !this.CanHoldToShoot(scriptInterface) {
      this.EnableOnEnterCondition(false);
      return false;
    };
    lastShotTime = stateContext.GetDoubleParameter(n"LastShotTime", true);
    if EngineTime.ToDouble(GameInstance.GetSimTime(scriptInterface.GetGame())) < lastShotTime + 0.00d {
      return false;
    };
  };
  let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let uncharged: Bool = scriptInterface.GetStatPoolsSystem().GetStatPoolValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge) <= this.GetWeaponChargeMinValue(scriptInterface) || weapon.WeaponHasTag(n"PartialChargeFire");
  return !weapon.IsMagazineEmpty() && uncharged;
}

// ForceInstantDischarge & GradualChargeDecay
@replaceMethod(ShootEvents)
protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
  let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  if Equals(statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.FullAutoOnFullCharge), 0.00) {
    if !weaponObject.WeaponHasTagOnTrigger(n"GradualChargeDecay") {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.GetWeaponChargeMinValue(scriptInterface), scriptInterface.executionOwner);
    };
  } else {
    if weaponObject.WeaponHasTagOnTrigger(n"ForceInstantDischarge") {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.GetWeaponChargeMinValue(scriptInterface), scriptInterface.executionOwner);
    };
  };
}

// UnslowableCharge & InstantCharge
@wrapMethod(ChargeEvents)
protected final func GetChargeValuePerSec(scriptInterface: ref<StateGameScriptInterface>) -> Float {
  let chargeTime: Float = wrappedMethod(scriptInterface);
  if chargeTime > 0.0 {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if weaponObject.WeaponHasTagOnTrigger(n"InstantCharge") {
      return chargeTime * 100.0;
    };
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    if timeSystem.IsTimeDilationActive(n"sandevistan") {
      let settings: wref<TMCSettings> = TMCSettings.GetSettings();
      if settings.overrideChargeSpeed
      || weaponObject.WeaponHasTagOnTrigger(n"UnslowableCharge") {
        chargeTime /= timeSystem.GetActiveTimeDilation(n"sandevistan");
      };
    };
  };
  return chargeTime;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// Extra

// ProtectedAttackPackage
@replaceMethod(OverrideRangedAttackPackageEffector)
protected func ActionOn(owner: ref<GameObject>) -> Void {
  let targetObject: wref<GameObject>;
  let targetWeapon: ref<WeaponObject>;
  if !this.GetApplicationTarget(owner, n"Weapon", targetObject) {
    return;
  };
  targetWeapon = targetObject as WeaponObject;
  if IsDefined(targetWeapon) && !targetWeapon.WeaponHasTag(n"ProtectedAttackPackage") {
    targetWeapon.OverrideRangedAttackPackage(this.m_attackPackage);
  };
}

@replaceMethod(OverrideRangedAttackPackageEffector)
protected func ActionOff(owner: ref<GameObject>) -> Void {
  let targetObject: wref<GameObject>;
  let targetWeapon: ref<WeaponObject>;
  if !this.GetApplicationTarget(owner, n"Weapon", targetObject) {
    return;
  };
  targetWeapon = targetObject as WeaponObject;
  if IsDefined(targetWeapon) && !targetWeapon.WeaponHasTag(n"ProtectedAttackPackage") {
    targetWeapon.DefaultRangedAttackPackage();
  };
}

// free Bolt protection
@wrapMethod(PerfectDischargePrereq)
protected final const func IsDischargePerfect(game: GameInstance, weaponObject: ref<WeaponObject>, opt state: ref<PerfectDischargePrereqState>) -> Bool {
  let result: Bool = wrappedMethod(game, weaponObject, state);
  if result {
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(player) {
      if ((weaponObject.WeaponHasTag(n"ForceAutoPrimary") || weaponObject.WeaponHasTag(n"InstantChargePrimary")) && !StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.PlayerSecondaryTrigger"))
      || ((weaponObject.WeaponHasTag(n"ForceAutoSecondary") || weaponObject.WeaponHasTag(n"InstantChargeSecondary")) && StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.PlayerSecondaryTrigger")) {
        return false;
      };
    };
  };
  return result;
}

// silenced snipers fix
@replaceMethod(GameEffectExecutor_StimOnHit)
public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
  let silentStimRadius: Float = 0.00;
  let position: Vector4 = EffectExecutionScriptContext.GetHitPosition(applierCtx);
  if Vector4.IsZero(position) {
    return false;
  };
  if GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).HasStatusEffect(EffectScriptContext.GetSource(ctx).GetEntityID(), t"BaseStatusEffect.PersonalSoundSilencerPlayerBuff") {
    return false;
  };
  if GameInstance.GetStatsSystem(EffectScriptContext.GetGameInstance(ctx)).GetStatValue(Cast<StatsObjectID>(EffectScriptContext.GetWeapon(ctx).GetEntityID()), gamedataStatType.CanSilentKill) > 0.00 {
    if IsDefined(EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet) && RPGManager.HasStatFlag(EffectScriptContext.GetInstigator(ctx) as GameObject, gamedataStatType.CanPlayerGagOnDetection) {
      silentStimRadius = 3.00;
    };
  } else {
    if !this.CreateStim(ctx, this.stimType, position) {
      return false;
    };
    silentStimRadius = 20.00;
  };
  return this.CreateStim(ctx, this.silentStimType, position, silentStimRadius);
}
