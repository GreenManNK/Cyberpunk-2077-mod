public class StayHealthySettings {

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Show Notification")
	@runtimeProperty("ModSettings.description", "ON (default): Show a notification on screen whenever auto consuming feature is activated. OFF: Hide notifications.")
	public let showNotification: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Hydrated - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Hydrated by automatically consuming drink in inventory. OFF: Do nothing.")
	public let stayHydrated: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Hydrated - Combat Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when combat start then help maintaining the effect. OFF: Always help maintaining the effect.")
	public let stayHydratedCombatOnly: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Nourished - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Nourished by automatically consuming food in inventory. OFF: Do nothing.")
	public let stayNourished: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Nourished - Combat Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when combat start then help maintaining the effect. OFF: Always help maintaining the effect.")
	public let stayNourishedCombatOnly: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Stamina Boosted - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Stamina Boosted by automatically consuming drink in inventory. OFF: Do nothing.")
	public let stayStaminaBoosted: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Stamina Boosted - Combat Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when combat start then help maintaining the effect. OFF: Always help maintaining the effect.")
	public let stayStaminaBoostedCombatOnly: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Health Boosted - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Health Boosted by automatically consuming drink in inventory. OFF: Do nothing.")
	public let stayHealthBoosted: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Health Boosted - Combat Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when combat start then help maintaining the effect. OFF: Always help maintaining the effect.")
	public let stayHealthBoostedCombatOnly: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Memory Boosted - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Memory Boosted by automatically consuming drink in inventory. OFF: Do nothing.")
	public let stayMemoryBoosted: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Memory Boosted - Combat Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when combat start then help maintaining the effect. OFF: Always help maintaining the effect.")
	public let stayMemoryBoostedCombatOnly: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Carry Capacity Boosted - Activate")
	@runtimeProperty("ModSettings.description", "ON: Help V stay Carry Capacity Boosted by automatically consuming drink in inventory. OFF: Do nothing.")
	public let stayCarryCapacityBoosted: Bool = true;

	@runtimeProperty("ModSettings.mod", "Stay Healthy")
	@runtimeProperty("ModSettings.displayName", "Stay Carry Capacity Boosted - Encumbered Only")
	@runtimeProperty("ModSettings.description", "ON: Automatically consuming when is Encumbered. OFF: Always help maintaining the effect.")
	public let stayCarryCapacityBoostedEncumberedOnly: Bool = true;

}

// Tracks the next free display slot so simultaneous triggers queue instead of overwriting each other.
@addField(PlayerPuppet)
  public let m_stayHealthyNextNotificationSlot: Float;

@addMethod(PlayerPuppet)
  public final func StayHealthyShowNotification(message: String) -> Void {
	let settings = new StayHealthySettings();
	if !settings.showNotification {
		return;
	}
	let stagger: Float = 5.0;
	let now: Float = EngineTime.ToFloat(GameInstance.GetTimeSystem(this.GetGame()).GetSimTime());
	let slot: Float = now;
	if this.m_stayHealthyNextNotificationSlot > now {
		slot = this.m_stayHealthyNextNotificationSlot;
	}
	this.m_stayHealthyNextNotificationSlot = slot + stagger;
	let delay: Float = slot - now;
	if delay <= 0.00 {
		this.StayHealthyDisplayNotification(message);
	} else {
		let delayed: ref<StayHealthyNotificationDelay> = new StayHealthyNotificationDelay();
		delayed.m_player = this;
		delayed.m_message = message;
		GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(delayed, delay, false);
	};
  }

@addMethod(PlayerPuppet)
  public final func StayHealthyDisplayNotification(message: String) -> Void {
	this.SetWarningMessage(message);
  }

public class StayHealthyNotificationDelay extends DelayCallback {
	public let m_player: wref<PlayerPuppet>;
	public let m_message: String;
	public func Call() -> Void {
		if IsDefined(this.m_player) {
			this.m_player.StayHealthyDisplayNotification(this.m_message);
		};
	}
}

@wrapMethod(PlayerPuppet)
  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let gameplayTags: array<CName> = evt.staticData.GameplayTags();
    if ArrayContains(gameplayTags, n"StayHealthy_Encumbered") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_CarryCapacityBooster") {
	  let settings = new StayHealthySettings();
	  if settings.stayCarryCapacityBoosted {
		let transactionSystem : ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
		let tags: array<CName>;
		let excludedTags: array<CName>;
		let itemList: array<wref<gameItemData>>;
		ArrayPush(tags, n"StayHealthy_CarryCapacityBoosterItem");
		if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
			ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Carry Capacity Boost Restored");
		};
	  };
    };
    wrappedMethod(evt);
  }

@wrapMethod(PlayerPuppet)
  protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
    let inCombat: Bool = newState == 1;
	let transactionSystem : ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
	let tags: array<CName>;
	let excludedTags: array<CName>;
	let itemList: array<wref<gameItemData>>;
	let settings = new StayHealthySettings();
    if inCombat {
	  if !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_Drink") && settings.stayHydrated && settings.stayHydratedCombatOnly {
	    ArrayClear(tags);
		ArrayClear(excludedTags);
		ArrayClear(itemList);
	    ArrayPush(excludedTags, n"IllegalFood");
	    ArrayPush(excludedTags, n"Alcohol");
		ArrayPush(tags, n"Drink");
	    if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		    ItemActionsHelper.DrinkItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Hydration Restored");
	    };
	  };
	  if !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_Food") && settings.stayNourished && settings.stayNourishedCombatOnly {
	    ArrayClear(tags);
		ArrayClear(excludedTags);
		ArrayClear(itemList);
	    ArrayPush(excludedTags, n"IllegalFood");
		ArrayPush(tags, n"Food");
	    if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		    ItemActionsHelper.EatItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Nourishment Restored");
	    };
	  };
	  if !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_HealthBooster") && settings.stayHealthBoosted && settings.stayHealthBoostedCombatOnly {
	    ArrayClear(tags);
		ArrayClear(itemList);
	    ArrayPush(tags, n"StayHealthy_HealthBoosterItem");
	    if transactionSystem.GetItemListByTags(this, tags, itemList) {
		    ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Health Boost Restored");
	    };
	  };
	  if !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_MemoryBooster") && settings.stayMemoryBoosted && settings.stayMemoryBoostedCombatOnly {
	    ArrayClear(tags);
		ArrayClear(itemList);
	    ArrayPush(tags, n"StayHealthy_MemoryBoosterItem");
	    if transactionSystem.GetItemListByTags(this, tags, itemList) {
		    ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Memory Boost Restored");
	    };
	  };
	  if !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_StaminaBooster") && settings.stayStaminaBoosted && settings.stayStaminaBoostedCombatOnly {
	    ArrayClear(tags);
		ArrayClear(itemList);
	    ArrayPush(tags, n"StayHealthy_StaminaBoosterItem");
	    if transactionSystem.GetItemListByTags(this, tags, itemList) {
		    ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Stamina Boost Restored");
	    };
	  };
	};
	wrappedMethod(newState);
  }

@addMethod(PlayerPuppet)
  public final func StayHealthyConsumeFood(evt: ref<RemoveStatusEffect>) -> Void {
    let gameplayTags: array<CName> = evt.staticData.GameplayTags();
    if !ArrayContains(gameplayTags, n"StayHealthy_Food") && !ArrayContains(gameplayTags, n"StayHealthy_Drink") && !ArrayContains(gameplayTags, n"StayHealthy_CarryCapacityBooster") && !ArrayContains(gameplayTags, n"StayHealthy_HealthBooster") && !ArrayContains(gameplayTags, n"StayHealthy_MemoryBooster") && !ArrayContains(gameplayTags, n"StayHealthy_StaminaBooster") {
		return;
	};
	let transactionSystem : ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
	let tags: array<CName>;
	let excludedTags: array<CName>;
	let itemList: array<wref<gameItemData>>;
	let settings = new StayHealthySettings();
    if ArrayContains(gameplayTags, n"StayHealthy_Food") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_Food") && settings.stayNourished && (!settings.stayNourishedCombatOnly || (settings.stayNourishedCombatOnly && this.m_inCombat)) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"Food");
	  ArrayPush(excludedTags, n"IllegalFood");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.EatItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Nourishment Restored");
		  return;
	  };
    };
    if ArrayContains(gameplayTags, n"StayHealthy_Drink") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_Drink") && settings.stayHydrated && (!settings.stayHydratedCombatOnly || (settings.stayHydratedCombatOnly && this.m_inCombat)) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"Drink");
	  ArrayPush(excludedTags, n"IllegalFood");
	  ArrayPush(excludedTags, n"Alcohol");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.DrinkItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Hydration Restored");
		  return;
	  };
    };
    if ArrayContains(gameplayTags, n"StayHealthy_CarryCapacityBooster") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_CarryCapacityBooster") && settings.stayCarryCapacityBoosted && (!settings.stayCarryCapacityBoostedEncumberedOnly || (settings.stayCarryCapacityBoostedEncumberedOnly && StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_Encumbered"))) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"StayHealthy_CarryCapacityBoosterItem");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Carry Capacity Boost Restored");
		  return;
	  };
    };
    if ArrayContains(gameplayTags, n"StayHealthy_HealthBooster") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_HealthBooster") && settings.stayHealthBoosted && (!settings.stayHealthBoostedCombatOnly || (settings.stayHealthBoostedCombatOnly && this.m_inCombat)) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"StayHealthy_HealthBoosterItem");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Health Boost Restored");
		  return;
	  };
    };
    if ArrayContains(gameplayTags, n"StayHealthy_MemoryBooster") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_MemoryBooster") && settings.stayMemoryBoosted && (!settings.stayMemoryBoostedCombatOnly || (settings.stayMemoryBoostedCombatOnly && this.m_inCombat)) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"StayHealthy_MemoryBoosterItem");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Memory Boost Restored");
		  return;
	  };
    };
    if ArrayContains(gameplayTags, n"StayHealthy_StaminaBooster") && !StatusEffectHelper.HasStatusEffectWithTagConst(this, n"StayHealthy_StaminaBooster") && settings.stayStaminaBoosted && (!settings.stayStaminaBoostedCombatOnly || (settings.stayStaminaBoostedCombatOnly && this.m_inCombat)) {
	  ArrayClear(tags);
	  ArrayClear(excludedTags);
	  ArrayClear(itemList);
	  ArrayPush(tags, n"StayHealthy_StaminaBoosterItem");
	  if transactionSystem.GetItemListFilteredByTags(this, tags, excludedTags, itemList) {
		  ItemActionsHelper.ConsumeItem(this, itemList[ArraySize(itemList) - 1].GetID(), true);
			this.StayHealthyShowNotification("Stay Healthy - Stamina Boost Restored");
		  return;
	  };
    };
  }

@wrapMethod(PlayerPuppet)
  protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
	this.StayHealthyConsumeFood(evt);
	wrappedMethod(evt);
  }
