// Add new field for kill counter stats
@addField(StatsMainGameController)
private let m_killStatsData: array<StatViewData>;

// Add new field for DataTrackingSystem used to query kill counter stats
@addField(StatsMainGameController)
private let m_dataTrackingSystem: ref<DataTrackingSystem>;

// Add method for querying kill counter in DataTrackingSystem
@addMethod(DataTrackingSystem)
public final func GetPlayerKillStats(out statsList: array<StatViewData>)  -> Void {
	let curData: StatViewData;
	// Kills stat = All enemies killed + finished
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_killedEnemies + this.m_finishedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-KilledEnemies", "Kills");
	ArrayPush(statsList, curData);
	// Killed stat = Neutralized with lethal last hits
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_killedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-KilledEnemies", "Killed Enemies");
	ArrayPush(statsList, curData);
	// Finished stat = Executing defeated/incapacitated enemies
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_finishedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-FinishedEnemies", "Finished Enemies");
	ArrayPush(statsList, curData);
	// Defeated stat = Neutralized with non-lethal last hits, but not killed
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_defeatedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DefeatedEnemies", "Defeated Enemies");
	ArrayPush(statsList, curData);
	// Incapacitated stat = Neutralized with fists, non-lethal grapple takedowns and certain non-lethal quickhacks, but not killed
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_incapacitatedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-IncapacitatedEnemies", "Incapacitated Enemies");
	ArrayPush(statsList, curData);
	// Downed stat = All enemies killed + defeated + incapacitated (not counting finished as they were by definition defeated/incapacitated first and included in that stat)
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedEnemies;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedEnemies", "Downed Enemies");
	ArrayPush(statsList, curData);
	// Downed with melee stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithMelee;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithMelee", "Downed With Melee");
	ArrayPush(statsList, curData);
	// Downed with ranged stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithRanged;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithRanged", "Downed With Ranged");
	ArrayPush(statsList, curData);
	// Downed with quickhacks stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithQuickhacks;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithRanged", "Downed With Quickhacks");
	ArrayPush(statsList, curData);
	// Downed with lethal grapple takedown stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithTakedown;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithRanged", "Downed With Takedowns");
	ArrayPush(statsList, curData);
	// Downed with non-lethal grapple takedown stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithTakedownNonLethal;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithRanged", "Downed With Non-Lethal Takedowns");
	ArrayPush(statsList, curData);
	// Downed with other means (explosions, pressure waves etc.) stat
	curData.type = gamedataStatType.Assault;
	curData.value = this.m_downedWithOther;
	curData.statName = this.LocalizeTag("Mod-KillCounter-UI-DownedWithRanged", "Downed With Other");
	ArrayPush(statsList, curData);
}

// Helper function to add possible localication in the future, without actually adding any now
@addMethod(DataTrackingSystem)
public final func LocalizeTag(Tag: String, Default: String) -> String {
	let Result: String = GetLocalizedText(Tag);
	if NotEquals(Tag, Result) {
		return Result;
	} else {
		return Default;
	}
}

// Create button for kill counter in StatsMainGameController
@wrapMethod(StatsMainGameController)
public final func PopulateStats() -> Void {
	wrappedMethod();
	// Initialize data for kill counter
	let gameInstanace: GameInstance = this.GetPlayerControlledObject().GetGame();
	this.m_dataTrackingSystem = GameInstance.GetScriptableSystemsContainer(gameInstanace).Get(n"DataTrackingSystem") as DataTrackingSystem;
	this.m_dataTrackingSystem.GetPlayerKillStats(this.m_killStatsData);
	// Use "Assault" stat for kill counter
	this.AddStat(gamedataStatType.Assault, this.m_killStatsData);
}

// Extend StatsMainGameController to handle clicking on kill counter
@wrapMethod(StatsMainGameController)
protected cb func OnCategoryClicked(evt: ref<CategoryClickedEvent>) -> Bool {
	let detailsData: array<StatViewData>;
        this.PlaySound(n"Button", n"OnHover");
	inkWidgetRef.SetVisible(this.m_rightPanelFluff1, false);
	inkWidgetRef.SetVisible(this.m_rightPanelFluff2, false);
	switch evt.statsData.type {
		case gamedataStatType.Health:
			detailsData = this.m_healthStatsData;
			break;
		case gamedataStatType.EffectiveDPS:
			detailsData = this.m_DPSStatsData;
			break;
		case gamedataStatType.Armor:
			detailsData = this.m_armorStatsData;
			break;
		case gamedataStatType.Invalid:
			detailsData = this.m_otherStatsData;
			break;
		// Use "Assault" stat for kill counter
		case gamedataStatType.Assault:
			detailsData = this.m_killStatsData;
	};
	this.m_detailListController.SetData(evt.statsData, detailsData);
}

// Extend StatsViewController to handle displaying kill counter button
@wrapMethod(StatsViewController)
public final func Setup(const stat: script_ref<StatViewData>) -> Void {
	wrappedMethod(stat);
      switch Deref(stat).type {
		// Use "Assault" stat for kill counter
		case gamedataStatType.Assault:
			inkImageRef.SetTexturePart(this.m_icon, n"melee");
	}
}

@wrapMethod(StatsDetailListController)
  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetVisible(true);
  }

@wrapMethod(StatsDetailListController)
  public final func SetData(const categoryData: script_ref<StatViewData>, const detailsData: script_ref<array<StatViewData>>) -> Void {
    let i: Int32;
    let statView: wref<StatsDetailViewController>;
    let statViewWidget: wref<inkWidget>;
    this.GetRootWidget().SetVisible(true);
    inkTextRef.SetText(this.m_StatLabelRef, Deref(categoryData).statName);
    inkCompoundRef.RemoveAllChildren(this.m_statsList);
    i = 0;
    while i < ArraySize(Deref(detailsData)) {
        statViewWidget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsList), n"statDetailView");
        statView = statViewWidget.GetControllerByType(n"StatsDetailViewController") as StatsDetailViewController;
        statView.Setup(Deref(detailsData)[i]);
        i += 1;
    };
  }

@addMethod(NPCPuppet)
  public const func IsJohnnyReplacer() -> Bool {
    return this.GetRecord().GetID() == t"Character.johnny_replacer";
  }

@wrapMethod(NPCPuppet)
  private final func SendDataTrackingEvent(defeated: Bool, nonLethal: Bool) -> Void {
    let mainObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let controlledObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let controlledObjRecordID: TweakDBID = controlledObj.GetRecordID();
    switch controlledObjRecordID {
      case t"Character.johnny_replacer":
        return;
        break;
      case t"Character.q000_vr_replacer":
        return;
        break;
      case t"Character.Player_Puppet_Base":
    let damageHistory: DamageHistoryEntry;
    let dataTrackingEvent: ref<NPCKillDataTrackingRequest> = new NPCKillDataTrackingRequest();
    if !this.GetValidAttackFromDamageHistory(damageHistory) {
      return;
    };
    if !IsDefined(damageHistory.source) {
      return;
    };
    dataTrackingEvent.damageEntry = damageHistory;
    dataTrackingEvent.isDownedRecorded = this.m_sentDownedEvent;
    if defeated && nonLethal {
      dataTrackingEvent.eventType = EDownedType.Unconscious;
    } else {
      if defeated {
        dataTrackingEvent.eventType = EDownedType.Defeated;
      } else {
        if ScriptedPuppet.IsDefeated(this) {
          dataTrackingEvent.eventType = EDownedType.Finished;
        } else {
          dataTrackingEvent.eventType = EDownedType.Killed;
        };
      };
    };
    GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem").QueueRequest(dataTrackingEvent);
    this.m_sentDownedEvent = true;
    };
}

@addField(DataTrackingSystem)
protected persistent let m_downedWithQuickhacks: Int32;

@addField(DataTrackingSystem)
protected persistent let m_downedWithOther: Int32;

@wrapMethod(DataTrackingSystem)
private final func OnNPCKillDataTrackingRequest(request: ref<NPCKillDataTrackingRequest>) -> Void {
  let attackRecord: ref<Attack_GameEffect_Record> = request.damageEntry.hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
  let npc: ref<NPCPuppet> = request.damageEntry.target as NPCPuppet;
  if !request.isDownedRecorded && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
    this.m_downedEnemies += 1;
    if this.CheckTimeDilationSources() && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
      this.m_downedInTimeDilatation += 1;
      this.m_dilationProgress += 1;
      if this.m_dilationProgress >= 2 {
        this.SetAchievementProgress(gamedataAchievement.MaxPain, this.m_downedInTimeDilatation);
        this.m_dilationProgress = 0;
      };
    };
    if (AttackData.IsMelee(request.damageEntry.hitEvent.attackData.GetAttackType()) || AttackData.IsThrown(request.damageEntry.hitEvent.attackData.GetAttackType()) || request.damageEntry.hitEvent.attackData.GetWeapon().IsBlade() || AttackData.IsWhip(request.damageEntry.hitEvent.attackData.GetAttackType())) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
      this.m_downedWithMelee += 1;
      this.m_meleeProgress += 1;
      if this.m_meleeProgress >= 4 {
        this.SetAchievementProgress(gamedataAchievement.TrueWarrior, this.m_downedWithMelee);
        this.m_meleeProgress = 0;
      };
    } else {
      if (AttackData.IsRangedOrDirect(request.damageEntry.hitEvent.attackData.GetAttackType()) || AttackData.IsReflect(request.damageEntry.hitEvent.attackData.GetAttackType()) || (AttackData.IsEffect(request.damageEntry.hitEvent.attackData.GetAttackType()) && !request.damageEntry.hitEvent.attackData.HasFlag(hitFlag.QuickHack))) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
        this.m_downedWithRanged += 1;
        this.m_rangedProgress += 1;
        if this.m_rangedProgress >= 5 {
          this.SetAchievementProgress(gamedataAchievement.TrueSoldier, this.m_downedWithRanged);
          this.m_rangedProgress = 0;
        };
        this.ProcessTwoHeadsOneBulletAchievement(request);
        this.ProcessGunKataAchievement(request);
      } else {
        if (AttackData.IsHack(request.damageEntry.hitEvent.attackData.GetAttackType()) || (AttackData.IsEffect(request.damageEntry.hitEvent.attackData.GetAttackType()) && request.damageEntry.hitEvent.attackData.HasFlag(hitFlag.QuickHack))) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
          this.m_downedWithQuickhacks += 1;
        } else {
          if AttackData.IsAreaOfEffect(request.damageEntry.hitEvent.attackData.GetAttackType()) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
            this.m_downedWithOther += 1;
            };
          };
        };
      };
      if Equals(attackRecord.EffectName(), n"superheroLanding") && StatusEffectSystem.ObjectHasStatusEffectWithTag(request.damageEntry.hitEvent.attackData.GetInstigator(), n"BerserkBuff") {
        this.ProcessHardForKneesAchievement();
      };
      if request.damageEntry.hitEvent.attackData.HasFlag(hitFlag.GrenadeQuickhackExplosion) {
        this.ProcessNotTheMobileAchievement(request.damageEntry);
      };
    };
    switch request.eventType {
      case EDownedType.Killed:
        if this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) && !Equals(npc.GetNPCType(), gamedataNPCType.Android) && !Equals(npc.GetNPCType(), gamedataNPCType.Drone) && !Equals(npc.GetNPCType(), gamedataNPCType.Mech) && !Equals(npc.GetNPCType(), gamedataNPCType.Chimera) {
          this.m_killedEnemies += 1;
          SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
          GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetKilledReqDelayID);
          this.m_resetKilledReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCKilledDelayedRequest(), 1.00);
        } else {
          if this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) && (Equals(npc.GetNPCType(), gamedataNPCType.Android) || Equals(npc.GetNPCType(), gamedataNPCType.Drone) || Equals(npc.GetNPCType(), gamedataNPCType.Mech) || Equals(npc.GetNPCType(), gamedataNPCType.Chimera)) {
            this.m_defeatedEnemies += 1;
            SetFactValue(this.GetGameInstance(), n"gmpl_npc_defeated_by_player", 1);
            GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetDefeatedReqDelayID);
            this.m_resetDefeatedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCDefeatedDelayedRequest(), 1.00);
          };
        }
        break;
      case EDownedType.Finished:
        if this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
          this.m_finishedEnemies += 1;
          SetFactValue(this.GetGameInstance(), n"gmpl_npc_finished_by_player", 1);
          GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetFinishedReqDelayID);
          this.m_resetFinishedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCFinishedDelayedRequest(), 1.00);
        }
        break;
      case EDownedType.Defeated:
        if this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
          this.m_defeatedEnemies += 1;
          SetFactValue(this.GetGameInstance(), n"gmpl_npc_defeated_by_player", 1);
          GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetDefeatedReqDelayID);
          this.m_resetDefeatedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCDefeatedDelayedRequest(), 1.00);
        }
        break;
      case EDownedType.Unconscious:
        if this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
          this.m_incapacitatedEnemies += 1;
          SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
          GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetIncapacitatedReqDelayID);
          this.m_resetIncapacitatedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCIncapacitatedDelayedRequest(), 1.00);
        }
      };
    GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetDownedReqDelayID);
    this.m_resetDownedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCDownedDelayedRequest(), 1.00);
    this.ProcessDataTrackingFacts();
}

@wrapMethod(DisposalDeviceControllerPS)
  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let action: ref<ScriptableDeviceAction>;
    if this.IsDisabled() || this.m_isPlayerCurrentlyPerformingDisposal {
      return false;
    };
    if this.HasComputerInteraction() {
      ArrayPush(actions, this.ActionOverchargeDevice());
    };
    if this.m_distractionSetup.m_hasSimpleInteraction && !this.m_wasActivated {
      ArrayPush(actions, this.ActionToggleActivation(this.GetInteractionName()));
    };
    if !(this.IsPlayerCarrying() || this.IsEnemyGrappled()) {
      super.GetActions(actions, context);
    };
    if this.IsNPCDisposalBlockedStatusEffect() {
      return false;
    };
    if this.IsPlayerDroppingBody() {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(context.processInitiatorObject, n"NoWorldInteractions") {
      return false;
    };
    if this.IsEnemyGrappled() {
      action = this.ActionTakedownAndDisposeBody(this.GetTakedownActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
      action = this.ActionNonlethalTakedownAndDisposeBody(this.GetNonlethalTakedownActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
    };
    if this.IsPlayerCarrying() {
      action = this.ActionDisposeBody(this.GetActionName());
      action.SetInactiveWithReason(this.GetNumberOfUses() > 0, "LocKey#2115");
      ArrayPush(actions, action);
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

@wrapMethod(DisposalDevice)
  private final func TakedownAndDispose(isNonlethal: Bool) -> Void {
    let mainObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let controlledObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let controlledObjRecordID: TweakDBID = controlledObj.GetRecordID();
    switch controlledObjRecordID {
      case t"Character.johnny_replacer":
    wrappedMethod(isNonlethal);
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if isNonlethal {
      dataTrackingSystem.m_incapacitatedEnemies += 1;
      dataTrackingSystem.m_incapacitatedEnemies -= 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedEnemies -= 1;
      dataTrackingSystem.m_downedWithTakedownNonLethal += 1;
      dataTrackingSystem.m_downedWithTakedownNonLethal -= 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    } else {
      dataTrackingSystem.m_killedEnemies += 1;
      dataTrackingSystem.m_killedEnemies -= 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedEnemies -= 1;
      dataTrackingSystem.m_downedWithTakedown += 1;
      dataTrackingSystem.m_downedWithTakedown -= 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    };
        break;
      case t"Character.q000_vr_replacer":
    wrappedMethod(isNonlethal);
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if isNonlethal {
      dataTrackingSystem.m_incapacitatedEnemies += 1;
      dataTrackingSystem.m_incapacitatedEnemies -= 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedEnemies -= 1;
      dataTrackingSystem.m_downedWithTakedownNonLethal += 1;
      dataTrackingSystem.m_downedWithTakedownNonLethal -= 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    } else {
      dataTrackingSystem.m_killedEnemies += 1;
      dataTrackingSystem.m_killedEnemies -= 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedEnemies -= 1;
      dataTrackingSystem.m_downedWithTakedown += 1;
      dataTrackingSystem.m_downedWithTakedown -= 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    };
        break;
      case t"Character.Player_Puppet_Base":
    wrappedMethod(isNonlethal);
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGame()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if isNonlethal {
      dataTrackingSystem.m_incapacitatedEnemies += 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedWithTakedownNonLethal += 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    } else {
      dataTrackingSystem.m_killedEnemies += 1;
      dataTrackingSystem.m_downedEnemies += 1;
      dataTrackingSystem.m_downedWithTakedown += 1;
      this.m_npcBody.Kill(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), true, true);
    };
  };
}

@wrapMethod(DisposalDevice)
  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    this.PlayTransformAnim(n"close");
    this.m_playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.CarryingDisposal, false);
    this.m_playerStateMachineBlackboard.SetInt(GetAllBlackboardDefs().PlayerStateMachine.BodyDisposalDetailed, 0);
    NPCPuppet.SetNPCDisposedFact(this.m_npcBody);
    this.HideNPCPermanently();
    this.PlayEffect(n"freeze", n"fridge");
    this.SetTakedownCameraAnimFeature(0);
    this.GetDevicePS().SetIsPlayerCurrentlyPerformingDisposal(false);
    this.UpdateLightAppearance();
  }

@addField(DataTrackingSystem)
private persistent let m_downedWithTakedown: Int32;

@addField(DataTrackingSystem)
private persistent let m_downedWithTakedownNonLethal: Int32;

@wrapMethod(DataTrackingSystem)
private final func OnTakedownActionDataTrackingRequest(request: ref<TakedownActionDataTrackingRequest>) -> Void {
    let mainObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let controlledObj: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    let controlledObjRecordID: TweakDBID = controlledObj.GetRecordID();
    switch controlledObjRecordID {
      case t"Character.johnny_replacer":
        return;
        break;
      case t"Character.q000_vr_replacer":
        return;
        break;
      case t"Character.Player_Puppet_Base":
    switch request.eventType {
      case ETakedownActionType.Takedown:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
        this.m_killedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedown += 1;
        break;
      case ETakedownActionType.TakedownNonLethal:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedownNonLethal += 1;
        break;
      case ETakedownActionType.TakedownMassiveTarget:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedownNonLethal += 1;
        break;
      case ETakedownActionType.AerialTakedown:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedownNonLethal += 1;
        break;
      case ETakedownActionType.DisposalTakedown:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
        this.m_killedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedown += 1;
        break;
      case ETakedownActionType.DisposalTakedownNonLethal:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        this.m_downedEnemies += 1;
        this.m_downedWithTakedownNonLethal += 1;
        break;
    };
    this.ProcessDataTrackingFacts();
  };
}