import SurvivalSystemModule.SurvivalSystem


// Базовое действие предмета

@replaceMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {

	let actionUsed: Bool = false;
	let action: ref<BaseItemAction> = ItemActionsHelper.SetupItemAction(gi, executor, itemData, actionID, fromInventory);

	if action.IsPossible(executor, TweakDBInterface.GetObjectActionRecord(actionID)) {

		if Equals(RPGManager.GetItemCategory(itemData.GetID()), gamedataItemCategory.Consumable) {

			SurvivalSystem.GetInstance(gi).UpdateFromItems(itemData);
		};

		action.ProcessRPGAction(gi);
		actionUsed = true;
	};

	return actionUsed;
}

@replaceMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool, quantity: Int32) -> Bool {

	let actionUsed: Bool = false;
	let action: ref<BaseItemAction> = ItemActionsHelper.SetupItemAction(gi, executor, itemData, actionID, fromInventory);

	action.SetRequestQuantity(quantity);

	if action.IsPossible(executor, TweakDBInterface.GetObjectActionRecord(actionID)) {

	  	if Equals(RPGManager.GetItemCategory(itemData.GetID()), gamedataItemCategory.Consumable) {

			SurvivalSystem.GetInstance(gi).UpdateFromItems(itemData);
		};

		action.ProcessRPGAction(gi);
		actionUsed = true;
	};

	return actionUsed;
}


// Меню игровой паузы

@wrapMethod(PauseMenuGameController)
protected cb func OnUninitialize() -> Bool {

	wrappedMethod();

	SurvivalSystem.GetInstance(GetGameInstance()).ValidateSystemStatus();
}


// Утилиты игрового времени

@wrapMethod(HubTimeSkipController)
protected cb func OnTimeSkipButtonPressed(e: ref<inkPointerEvent>) -> Bool {

	if e.IsAction(n"click") {

		SurvivalSystem.GetInstance(GetGameInstance()).SetSkippingTimeFromMenu(true);
	}
	
	return wrappedMethod(e);
}


// Программный объект игрока

@addMethod(PlayerPuppet)
public final func StatusEffectsCheck(event: ref<StatusEffectEvent>) -> Void {

	let SurvivalSystem: ref<SurvivalSystem> = SurvivalSystem.GetInstance(GetGameInstance());

	let applyEvent: ref<ApplyStatusEffectEvent> = event as ApplyStatusEffectEvent;
	let removeEvent: ref<RemoveStatusEffect> = event as RemoveStatusEffect;

	if IsDefined(applyEvent) {

		let onSpawn: Bool = applyEvent.isAppliedOnSpawn;
		let effectID: TweakDBID = applyEvent.staticData.GetID();
		let instigator: Bool = Equals(applyEvent.instigatorEntityID, this.GetEntityID());
		let wellFed: Bool = Equals(effectID, t"BaseStatusEffect.WellFed");
		let sated: Bool = Equals(effectID, t"BaseStatusEffect.Sated");
		let drunk: Bool = Equals(effectID, t"BaseStatusEffect.Drunk");

		if !onSpawn && instigator && (wellFed || sated || drunk) {

			SurvivalSystem.UpdateFromEffects(effectID);
		};
	};

	if IsDefined(removeEvent) {

		let effectID: TweakDBID = removeEvent.staticData.GetID();
		let BuffUncommon: Bool = Equals(effectID, t"BaseStatusEffect.SSStimulatorBuff");
		let BuffRare: Bool = Equals(effectID, t"BaseStatusEffect.SSStimulatorBuffRare");
		let BuffEpic: Bool = Equals(effectID, t"BaseStatusEffect.SSStimulatorBuffEpic");

		if BuffUncommon || BuffRare || BuffEpic {

			SurvivalSystem.ValidatePlayerStatus();
		};
	};
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {

	wrappedMethod(evt);

	this.StatusEffectsCheck(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {

	wrappedMethod(evt);

	this.StatusEffectsCheck(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnHealthUpdateEvent(evt: ref<HealthUpdateEvent>) -> Bool {

	let SurvivalSystem: ref<SurvivalSystem> = SurvivalSystem.GetInstance(GetGameInstance());

	if evt.value < PlayerPuppet.GetLowHealthThreshold() {

		SurvivalSystem.AplayVisualEffect();
		wrappedMethod(evt);

	} else {

		wrappedMethod(evt);
		SurvivalSystem.AplayVisualEffect();
	};
}


// Меню всплывающих подсказок

@addMethod(ItemTooltipStatController)
public final func SetData(value: String, name: String) -> Void {

	inkTextRef.SetText(this.m_statValue, value);
	inkTextRef.SetText(this.m_statName, name);

	inkWidgetRef.SetVisible(this.m_arrow, false);
	inkWidgetRef.SetVisible(this.m_statComparedValue, false);
}

@addMethod(ItemTooltipDetailsModule)
public final func ShowSurvivalStats(itemData: wref<gameItemData>) -> Void {

	let nutritionVector: Vector3 = GetNutritionVector(itemData);

	let fatigue: Float = nutritionVector.X;
	let hunger: Float = nutritionVector.Y;
	let thirst: Float = nutritionVector.Z;

	if itemData.HasTag(n"Consumable") && fatigue + hunger + thirst != 0.0 {

		inkWidgetRef.SetVisible(this.m_statsLine, true);
		inkWidgetRef.SetVisible(this.m_statsWrapper, true);

		let controller: ref<ItemTooltipStatController>;
		let widget: wref<inkWidget>;

		if fatigue != 0.0 {

			widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemDetailsStat");
			controller = widget.GetController() as ItemTooltipStatController;
			controller.SetData(s"\(fatigue > 0.0 ? "+" : "")\(FloatToStringPrec(fatigue, 1) + "%")", GetLocalizedTextByKey(n"SSItemStatFatigue"));
		};

		if hunger != 0.0 {

			widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemDetailsStat");
			controller = widget.GetController() as ItemTooltipStatController;
			controller.SetData(s"\(hunger > 0.0 ? "+" : "")\(FloatToStringPrec(hunger, 1) + "%")", GetLocalizedTextByKey(n"SSItemStatHunger"));
		};

		if thirst != 0.0 {

			widget = this.SpawnFromLocal(inkWidgetRef.Get(this.m_statsContainer), n"itemDetailsStat");
			controller = widget.GetController() as ItemTooltipStatController;
			controller.SetData(s"\(thirst > 0.0 ? "+" : "")\(FloatToStringPrec(thirst, 1) + "%")", GetLocalizedTextByKey(n"SSItemStatThirst"));
		};
	};
}

@addMethod(ItemTooltipBottomModule)
public final func CheckItemWeight(itemData: wref<gameItemData>) -> Void {

	if (ExistingConsumableModule() && itemData.HasTag(n"Grenade")) || itemData.HasTag(n"Consumable") {

		let weight: Float = RPGManager.GetItemWeight(itemData);
		let stackWeight: Float = weight * Cast<Float>(itemData.GetQuantity());

		inkTextRef.SetText(this.m_weightText, s"\(FloatToStringPrec(weight, 1)) / \(FloatToStringPrec(stackWeight, 1))");
	};

	if itemData.HasTag(n"Ammo") {

		let weight: Float = RPGManager.GetItemWeight(itemData);
		let stackWeight: Float = weight * Cast<Float>(itemData.GetQuantity());

		inkTextRef.SetText(this.m_weightText, s"\(FloatToStringPrec(weight, 2)) / \(FloatToStringPrec(stackWeight, 2))");
	};
}

@wrapMethod(ItemTooltipDetailsModule)
public final func Update(data: ref<MinimalItemTooltipData>, hasStats: Bool, hasDedicatedMods: Bool, hasMods: Bool) -> Void {

	wrappedMethod(data, hasStats, hasDedicatedMods, hasMods);

	this.ShowSurvivalStats(data.itemData);
}

@wrapMethod(ItemTooltipDetailsModule)
public final func NEW_Update(data: wref<UIInventoryItem>, m_comparisonData: wref<UIInventoryItemComparisonManager>, hasStats: Bool, hasDedicatedMods: Bool, hasMods: Bool) -> Void {

	wrappedMethod(data, m_comparisonData, hasStats, hasDedicatedMods, hasMods);

	this.ShowSurvivalStats(data.GetItemData());
}

@wrapMethod(ItemTooltipBottomModule)
public func Update(data: ref<MinimalItemTooltipData>) -> Void {

    wrappedMethod(data);

	this.CheckItemWeight(data.itemData);
}

@wrapMethod(ItemTooltipBottomModule)
public final func NEW_Update(data: wref<UIInventoryItem>, player: wref<PlayerPuppet>, m_overridePrice: Int32) -> Void {

	wrappedMethod(data, player, m_overridePrice);

	this.CheckItemWeight(data.GetItemData());
}

@replaceMethod(ItemTooltipBottomModule)
public final static func ShouldDisplayPrice(displayContext: InventoryTooltipDisplayContext, isSellable: Bool, itemData: ref<gameItemData>, itemType: gamedataItemType, opt lootItemType: LootItemType) -> Bool {

	if NotEquals(displayContext, InventoryTooltipDisplayContext.Vendor) {

		if ExistingConsumableModule() && (itemData.HasTag(n"Grenade") || itemData.HasTag(n"Injector") || itemData.HasTag(n"Inhaler")) {

			return true;
		};

		if !isSellable || Equals(itemType, gamedataItemType.Wea_Fists) || itemData.HasTag(n"Shard") || itemData.HasTag(n"Recipe") || Equals(lootItemType, LootItemType.Quest) {

			return false;
		};
	};

	return true;
}

@if(ModuleExists("ExistingConsumableModule"))
@replaceMethod(ItemTooltipBottomModule)
public final static func ShouldHideBottomModule(displayContext: InventoryTooltipDisplayContext, itemData: wref<UIInventoryItem>) -> Bool {

	if itemData.GetTweakDBID() == t"Items.money" || itemData.IsRecipe() && !itemData.IsWeapon() {

		return true;
	};

	if itemData.GetWeight() <= 0.00 {

		return !ItemTooltipBottomModule.ShouldDisplayPrice(displayContext, itemData.IsSellable(), itemData.GetItemData(), itemData.GetItemType());
	};

	return false;
}


// Инвентарь и тайник игрока

@wrapMethod(RPGManager)
public final static func GetItemWeight(itemData: ref<gameItemData>) -> Float {

	if IsDefined(itemData) {

		if (ExistingConsumableModule() && itemData.HasTag(n"Grenade")) || itemData.HasTag(n"Consumable") || itemData.HasTag(n"Ammo") {
		
			return GetItemWeight(itemData);
		};
	};

	return wrappedMethod(itemData);
}

@wrapMethod(PlayerHandicapSystem)
public const func CanDropAmmo() -> Bool
{
	let settings: ref<SurvivalSystemSettings> = new SurvivalSystemSettings();

	if !settings.autoLootAmmoSpawn {

		return false;
	};

	return wrappedMethod();
}

@wrapMethod(ItemFilterCategories)
public final static func GetLabelKey(filterType: ItemFilterCategory) -> CName {

	if Equals(filterType, ItemFilterCategory.Grenades) {

		return n"UI-Filters-Ammunition";
	};

	return wrappedMethod(filterType);
}

@wrapMethod(ItemFilterCategories)
public final static func GetIcon(filterType: ItemFilterCategory) -> String {

	if Equals(filterType, ItemFilterCategory.Grenades) {

		return "UIIcon.Filter_Ammunition";
	};

	return wrappedMethod(filterType);
}

@wrapMethod(ItemCategoryFliter)
public final static func IsOfCategoryType(filter: ItemFilterCategory, data: wref<gameItemData>) -> Bool {

	if IsDefined(data) {

		if Equals(filter, ItemFilterCategory.Grenades) {

			return data.HasTag(n"Grenade") || data.HasTag(n"Ammo");
		};
	};

	return wrappedMethod(filter, data);
}

@wrapMethod(CraftingDataView)
public func FilterItem(item: ref<IScriptable>) -> Bool {

	let itemRecord: ref<Item_Record>;
	let itemData: ref<ItemCraftingData> = item as ItemCraftingData;
	let recipeData: ref<RecipeData> = item as RecipeData;

	if IsDefined(itemData) {

		itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(itemData.inventoryItem)));

	} else {

		if IsDefined(recipeData) {

			itemRecord = recipeData.id;
		};
	};

	if Equals(this.m_itemFilterType, ItemFilterCategory.Grenades) {

		return itemRecord.TagsContains(n"Grenade") || itemRecord.TagsContains(n"Ammo");

	} else {

		if Equals(this.m_itemFilterType, ItemFilterCategory.Consumables) {
			
			return itemRecord.TagsContains(n"Consumable");
		};
	};

	return wrappedMethod(item);
}

@wrapMethod(UIInventoryItemsManager)
public final static func GetBlacklistedTags() -> array<CName> {

	let tags: array<CName> = wrappedMethod();

	if ArrayContains(tags, n"Ammo") {

		ArrayRemove(tags, n"Ammo");
	};

	return tags;
}

@wrapMethod(CraftingSystem)
private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {

	let settings: ref<SurvivalSystemSettings> = new SurvivalSystemSettings();

	this.m_playerCraftBook.HideRecipe(t"Ammo.HandgunAmmo", settings.hideAmmoRecipe);
	this.m_playerCraftBook.HideRecipe(t"Ammo.ShotgunAmmo", settings.hideAmmoRecipe);
	this.m_playerCraftBook.HideRecipe(t"Ammo.RifleAmmo", settings.hideAmmoRecipe);
	this.m_playerCraftBook.HideRecipe(t"Ammo.SniperRifleAmmo", settings.hideAmmoRecipe);

	wrappedMethod(saveVersion, gameVersion);
}

@replaceMethod(UIInventoryItem)
public final func GetWeight() -> Float {

	if Cast<Bool>(this.m_fetchedFlags & 512) {

		return this.m_data.Weight;
	};

	this.m_data.Weight = RPGManager.GetItemWeight(this.m_itemData);
	this.m_fetchedFlags |= 512;

	return this.m_data.Weight;
}

@replaceMethod(ItemQuantityPickerController)
protected final func UpdateWeight() -> Void {

	let itemData: ref<gameItemData>;

	if IsDefined(this.m_inventoryItem) {

		itemData = this.m_inventoryItem.GetItemData();
		
	} else {

		itemData = InventoryItemData.GetGameItemData(this.m_gameData);
	};

	let weight: Float = RPGManager.GetItemWeight(itemData) * Cast<Float>(this.m_choosenQuantity);

	inkTextRef.SetText(this.m_weightText, FloatToStringPrec(weight, 0));
}

@replaceMethod(MenuHubGameController)
protected cb func OnDropQueueUpdatedEvent(evt: ref<DropQueueUpdatedEvent>) -> Bool {
	
	let item: ref<gameItemData>;
	let result: Float;
	let dropQueue: array<ItemModParams> = evt.m_dropQueue;

	let i: Int32 = 0;
	
	while i < ArraySize(dropQueue) {

		item = GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemData(this.m_player, dropQueue[i].itemID);
		result += RPGManager.GetItemWeight(item) * Cast<Float>(dropQueue[i].quantity);
		
		i += 1;
	};

	this.HandlePlayerWeightUpdated(result);
}

@wrapMethod(BackpackMainGameController)
protected cb func OnItemDisplayClick(evt: ref<ItemDisplayClickEvent>) -> Bool {

	if Equals(evt.uiInventoryItem.GetItemType(), gamedataItemType.Con_Edible) && evt.actionName.IsAction(n"equip_item") {

		return false;
	};

	return wrappedMethod(evt);
}