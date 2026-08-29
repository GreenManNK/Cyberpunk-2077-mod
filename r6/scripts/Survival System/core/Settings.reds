public class SurvivalSystemSettings {
	

	// Настройки мода

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSBigRedButtonName")
	@runtimeProperty("ModSettings.description", "SSBigRedButtonDesc")
	let bigRedButton: Bool = false;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSDisableModPriceName")
	@runtimeProperty("ModSettings.description", "SSDisableModPriceDesc")
	let disableModPrice: Bool = false;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSHorrableDeathName")
	@runtimeProperty("ModSettings.description", "SSHorrableDeathDesc")
	let horrableDeath: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSVisualEffectName")
	@runtimeProperty("ModSettings.description", "SSVisualEffectDesc")
	let visualEffect: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSSleepInCarName")
	@runtimeProperty("ModSettings.description", "SSSleepInCarDesc")
	let canSleepInCar: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSHideStaminaWidgetName")
	@runtimeProperty("ModSettings.description", "SSHideStaminaWidgetDesc")
	let hideStaminaWidget: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSShowOtherNotifyName")
	@runtimeProperty("ModSettings.description", "SSShowOtherNotifyDesc")
	let showOtherNotify: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSShowTimeNotifyName")
	@runtimeProperty("ModSettings.description", "SSShowTimeNotifyDesc")
	let showTimeNotify: Bool = true;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSNotifyDelayName")
	@runtimeProperty("ModSettings.description", "SSNotifyDelayDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "60.0")
	@runtimeProperty("ModSettings.max", "240.0")
	let notifyDelay: Float = 120.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSettingsCategory")
	@runtimeProperty("ModSettings.displayName", "SSUpdateDelayName")
	@runtimeProperty("ModSettings.description", "SSUpdateDelayDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "16.0")
	let updateDelay: Float = 8.0;


	// Настройки эффектов

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueThresholdName")
	@runtimeProperty("ModSettings.description", "SSFatigueThresholdDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "30.0")
	@runtimeProperty("ModSettings.max", "100.0")
	let fatigueThreshold: Float = 95.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSHungerThresholdName")
	@runtimeProperty("ModSettings.description", "SSHungerThresholdDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "30.0")
	@runtimeProperty("ModSettings.max", "100.0")
	let hungerThreshold: Float = 95.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSThirstThresholdName")
	@runtimeProperty("ModSettings.description", "SSThirstThresholdDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "30.0")
	@runtimeProperty("ModSettings.max", "100.0")
	let thirstThreshold: Float = 95.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueMultiplierName")
	@runtimeProperty("ModSettings.description", "SSFatigueMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "1.0")
	let fatigueMultiplier: Float = 1.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSHungerMultiplierName")
	@runtimeProperty("ModSettings.description", "SSHungerMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "1.0")
	let hungerMultiplier: Float = 1.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSEffectsCategory")
	@runtimeProperty("ModSettings.displayName", "SSThirstMultiplierName")
	@runtimeProperty("ModSettings.description", "SSThirstMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "1.0")
	let thirstMultiplier: Float = 1.0;
	

	// Настройки персонажа

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueRecoverInCarName")
	@runtimeProperty("ModSettings.description", "SSFatigueRecoverInCarDesc")
	@runtimeProperty("ModSettings.step", "0.25")
	@runtimeProperty("ModSettings.min", "0.25")
	@runtimeProperty("ModSettings.max", "30.0")
	let fatigueRecoverInCar: Float = 8.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueRecoverInBedName")
	@runtimeProperty("ModSettings.description", "SSFatigueRecoverInBedDesc")
	@runtimeProperty("ModSettings.step", "0.25")
	@runtimeProperty("ModSettings.min", "0.25")
	@runtimeProperty("ModSettings.max", "30.0")
	let fatigueRecoverInBed: Float = 3.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueLossName")
	@runtimeProperty("ModSettings.description", "SSFatigueLossDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "30.0")
	let fatigueLoss: Float = 6.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSHungerLossName")
	@runtimeProperty("ModSettings.description", "SSHungerLossDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "30.0")
	let hungerLoss: Float = 10.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSThirstLossName")
	@runtimeProperty("ModSettings.description", "SSThirstLossDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "30.0")
	let thirstLoss: Float = 4.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSFatigueNotifyName")
	@runtimeProperty("ModSettings.description", "SSFatigueNotifyDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.25")
	@runtimeProperty("ModSettings.max", "1.0")
	let fatigueNotify: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSHungerNotifyName")
	@runtimeProperty("ModSettings.description", "SSHungerNotifyDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.25")
	@runtimeProperty("ModSettings.max", "1.0")
	let hungerNotify: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSThirstNotifyName")
	@runtimeProperty("ModSettings.description", "SSThirstNotifyDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.25")
	@runtimeProperty("ModSettings.max", "1.0")
	let thirstNotify: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSStressIncreaseName")
	@runtimeProperty("ModSettings.description", "SSStressIncreaseDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "10.0")
	let stressIncrease: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSCharacterCategory")
	@runtimeProperty("ModSettings.displayName", "SSStressDecreaseName")
	@runtimeProperty("ModSettings.description", "SSStressDecreaseDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "10.0")
	let stressDecrease: Float = 1.0;

	// Настройки предметов

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodMultiplierName")
	@runtimeProperty("ModSettings.description", "SSFoodMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "5.0")
	let foodMultiplier: Float = 1.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinkMultiplierName")
	@runtimeProperty("ModSettings.description", "SSDrinkMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "5.0")
	let drinkMultiplier: Float = 1.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholMultiplierName")
	@runtimeProperty("ModSettings.description", "SSAlcoholMultiplierDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "5.0")
	let alcoholMultiplier: Float = 1.0;
	
	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholPenaltyName")
	@runtimeProperty("ModSettings.description", "SSAlcoholPenaltyDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "5.0")
	let alcoholPenalty: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodlWeightName")
	@runtimeProperty("ModSettings.description", "SSFoodlWeightDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let foodlWeight: Float = 0.8;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinklWeightName")
	@runtimeProperty("ModSettings.description", "SSDrinklWeightDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let drinklWeight: Float = 0.6;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholWeightName")
	@runtimeProperty("ModSettings.description", "SSAlcoholWeightDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let alcoholWeight: Float = 1.2;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSItemsCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrugsWeightName")
	@runtimeProperty("ModSettings.description", "SSDrugsWeightDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let drugsWeight: Float = 0.4;


	// Настройки боеприпасов

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSHideAmmoRecipeName")
	@runtimeProperty("ModSettings.description", "SSHideAmmoRecipeDesc")
	let hideAmmoRecipe: Bool = false;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSHandgunAmmoQuantityName")
	@runtimeProperty("ModSettings.description", "SSHandgunAmmoQuantityDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "4000.0")
	let handgunAmmoQuantity: Float = 400.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSShotgunAmmoQuantityName")
	@runtimeProperty("ModSettings.description", "SSShotgunAmmoQuantityDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "2000.0")
	let shotgunAmmoQuantity: Float = 200.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSRifleAmmoQuantityName")
	@runtimeProperty("ModSettings.description", "SSRifleAmmoQuantityDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10000.0")
	let rifleAmmoQuantity: Float = 1000.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSSniperAmmoQuantityName")
	@runtimeProperty("ModSettings.description", "SSSniperAmmoQuantityDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "1000.0")
	let sniperAmmoQuantity: Float = 100.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSHandgunAmmoWeightName")
	@runtimeProperty("ModSettings.description", "SSHandgunAmmoWeightDesc")
	@runtimeProperty("ModSettings.step", "0.01")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "1.0")
	let handgunAmmoWeight: Float = 0.01;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSShotgunAmmoWeightName")
	@runtimeProperty("ModSettings.description", "SSShotgunAmmoWeightDesc")
	@runtimeProperty("ModSettings.step", "0.01")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "1.0")
	let shotgunAmmoWeight: Float = 0.02;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSRifleAmmoWeightName")
	@runtimeProperty("ModSettings.description", "SSRifleAmmoWeightDesc")
	@runtimeProperty("ModSettings.step", "0.01")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "1.0")
	let rifleAmmodWeight: Float = 0.02;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSAmmoCategory")
	@runtimeProperty("ModSettings.displayName", "SSSniperAmmoWeightName")
	@runtimeProperty("ModSettings.description", "SSSniperAmmoWeightDesc")
	@runtimeProperty("ModSettings.step", "0.01")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "1.0")
	let sniperAmmoWeight: Float = 0.03;

	// Настройки спавна

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSpawnCategory")
	@runtimeProperty("ModSettings.displayName", "SSAutoLootAmmoSpawnName")
	@runtimeProperty("ModSettings.description", "SSAutoLootAmmoSpawnDesc")
	let autoLootAmmoSpawn: Bool = false;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSpawnCategory")
	@runtimeProperty("ModSettings.displayName", "SSHandgunAmmoSpawnName")
	@runtimeProperty("ModSettings.description", "SSHandgunAmmoSpawnDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "0.25")
	let handgunAmmoSpawn: Float = 0.1;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSpawnCategory")
	@runtimeProperty("ModSettings.displayName", "SSShotgunAmmoSpawnName")
	@runtimeProperty("ModSettings.description", "SSShotgunAmmoSpawnDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "0.25")
	let shotgunAmmoSpawn: Float = 0.1;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSpawnCategory")
	@runtimeProperty("ModSettings.displayName", "SSRifleAmmoSpawnName")
	@runtimeProperty("ModSettings.description", "SSRifleAmmoSpawnDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "0.25")
	let rifleAmmoSpawn: Float = 0.1;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSSpawnCategory")
	@runtimeProperty("ModSettings.displayName", "SSSniperAmmoSpawnName")
	@runtimeProperty("ModSettings.description", "SSSniperAmmoSpawnDesc")
	@runtimeProperty("ModSettings.step", "0.05")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "0.25")
	let sniperAmmoSpawn: Float = 0.1;


	// Настройки стоимости

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAmmoBasePriceName")
	@runtimeProperty("ModSettings.description", "SSAmmoBasePriceDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "2.0")
	@runtimeProperty("ModSettings.max", "20.0")
	let ammoBasePrice: Float = 16.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSHandgunAmmoPriceName")
	@runtimeProperty("ModSettings.description", "SSHandgunAmmoPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let handgunAmmoPrice: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSShotgunAmmoPriceName")
	@runtimeProperty("ModSettings.description", "SSShotgunAmmoPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let shotgunAmmoPrice: Float = 1.4;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSRifleAmmoPriceName")
	@runtimeProperty("ModSettings.description", "SSRifleAmmoPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let rifleAmmoPrice: Float = 1.4;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSSniperAmmoPriceName")
	@runtimeProperty("ModSettings.description", "SSSniperAmmoPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let sniperAmmoPrice: Float = 1.8;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSConsumableBasePriceName")
	@runtimeProperty("ModSettings.description", "SSConsumableBasePriceDesc")
	@runtimeProperty("ModSettings.step", "10.0")
	@runtimeProperty("ModSettings.min", "500.0")
	@runtimeProperty("ModSettings.max", "1000.0")
	let consumableBasePrice: Float = 500.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDamageGrenadePriceName")
	@runtimeProperty("ModSettings.description", "SSDamageGrenadePriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let damageGrenadePrice: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSEffectGrenadePriceName")
	@runtimeProperty("ModSettings.description", "SSEffectGrenadePriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.7")
	@runtimeProperty("ModSettings.max", "10.0")
	let effectGrenadePrice: Float = 0.7;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSInjectorPriceName")
	@runtimeProperty("ModSettings.description", "SSInjectorPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let injectorPrice: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSInhalerPriceName")
	@runtimeProperty("ModSettings.description", "SSInhalerPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let inhalerPrice: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrugsPriceName")
	@runtimeProperty("ModSettings.description", "SSDrugsPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.5")
	@runtimeProperty("ModSettings.max", "10.0")
	let drugsPrice: Float = 0.5;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodBasePriceName")
	@runtimeProperty("ModSettings.description", "SSFoodBasePriceDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "5.0")
	@runtimeProperty("ModSettings.max", "50.0")
	let foodBasePrice: Float = 20.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodUncommonPriceName")
	@runtimeProperty("ModSettings.description", "SSFoodUncommonPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "2.4")
	let foodUncommonPrice: Float = 2.4;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodRarePriceName")
	@runtimeProperty("ModSettings.description", "SSFoodRarePriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "2.4")
	@runtimeProperty("ModSettings.max", "5.0")
	let foodRarePrice: Float = 5.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSFoodEpicPriceName")
	@runtimeProperty("ModSettings.description", "SSFoodEpicPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "5.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let foodEpicPrice: Float = 10.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinkBasePriceName")
	@runtimeProperty("ModSettings.description", "SSDrinkBasePriceDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "10.0")
	@runtimeProperty("ModSettings.max", "100.0")
	let drinkBasePrice: Float = 40.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinkUncommonPriceName")
	@runtimeProperty("ModSettings.description", "SSDrinkUncommonPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "2.0")
	let drinkUncommonPrice: Float = 2.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinkRarePriceName")
	@runtimeProperty("ModSettings.description", "SSDrinkRarePriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "2.0")
	@runtimeProperty("ModSettings.max", "4.0")
	let drinkRarePrice: Float = 4.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSDrinkEpicPriceName")
	@runtimeProperty("ModSettings.description", "SSDrinkEpicPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "4.0")
	@runtimeProperty("ModSettings.max", "8.0")
	let drinkEpicPrice: Float = 8.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholBasePriceName")
	@runtimeProperty("ModSettings.description", "SSAlcoholBasePriceDesc")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "30.0")
	@runtimeProperty("ModSettings.max", "300.0")
	let alcoholBasePrice: Float = 120.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholUncommonPriceName")
	@runtimeProperty("ModSettings.description", "SSAlcoholUncommonPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "1.0")
	@runtimeProperty("ModSettings.max", "2.0")
	let alcoholUncommonPrice: Float = 2.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholRarePriceName")
	@runtimeProperty("ModSettings.description", "SSAlcoholRarePriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "2.0")
	@runtimeProperty("ModSettings.max", "3.0")
	let alcoholRarePrice: Float = 3.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholEpicPriceName")
	@runtimeProperty("ModSettings.description", "SSAlcoholEpicPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "3.0")
	@runtimeProperty("ModSettings.max", "5.0")
	let alcoholEpicPrice: Float = 5.0;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSPriceCategory")
	@runtimeProperty("ModSettings.displayName", "SSAlcoholLegendaryPriceName")
	@runtimeProperty("ModSettings.description", "SSAlcoholLegendaryPriceDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "5.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let alcoholLegendaryPrice: Float = 10.0;


	// Настройки Existing Consumable

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSGrenadeWeightECName")
	@runtimeProperty("ModSettings.description", "SSGrenadeWeightECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let grenadeWeightEC: Float = 1.2;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSInjectorWeightECName")
	@runtimeProperty("ModSettings.description", "SSInjectorWeightECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let injectorWeightEC: Float = 0.3;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSInhalerWeightECName")
	@runtimeProperty("ModSettings.description", "SSInhalerWeightECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "10.0")
	let inhalerWeightEC: Float = 0.3;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSDamageGrenadePriceECName")
	@runtimeProperty("ModSettings.description", "SSDamageGrenadePriceECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.2")
	@runtimeProperty("ModSettings.max", "10.0")
	let damageGrenadePriceEC: Float = 0.3;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSEffectGrenadePriceECName")
	@runtimeProperty("ModSettings.description", "SSEffectGrenadePriceECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.2")
	@runtimeProperty("ModSettings.max", "10.0")
	let effectGrenadePriceEC: Float = 0.2;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSInjectorPriceECName")
	@runtimeProperty("ModSettings.description", "SSInjectorPriceECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.2")
	@runtimeProperty("ModSettings.max", "10.0")
	let injectorPriceEC: Float = 0.2;

	@runtimeProperty("ModSettings.mod", "Survival System")
	@runtimeProperty("ModSettings.category", "SSECCategory")
	@runtimeProperty("ModSettings.displayName", "SSInhalerPriceECName")
	@runtimeProperty("ModSettings.description", "SSInhalerPriceECDesc")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.2")
	@runtimeProperty("ModSettings.max", "10.0")
	let inhalerPriceEC: Float = 0.2;
}