module SurvivalSystemModule


// Объект с основной логикой

public final class SurvivalSystem extends ScriptableSystem {


	// Публичные поля

	public let settings: ref<SurvivalSystemSettings>;


	// Приватные поля

	private let skippingTimeFromMenu: Bool = false;
	private let skippingTimeMenuOpen: Bool = false;

	private persistent let currentFatigue: Float = 100.0;
	private persistent let currentHunger: Float = 100.0;
	private persistent let currentThirst: Float = 100.0;
	private persistent let currentStress: Float = 1.0;

	private let conditionFatigue: Float = 1.0;
	private let conditionHunger: Float = 1.0;
	private let conditionThirst: Float = 1.0;

	private let player: ref<PlayerPuppet>;

	private let TransactionSystem: ref<TransactionSystem>;
	private let BlackboardSystem: ref<BlackboardSystem>;
	private let StatPoolsSystem: ref<StatPoolsSystem>;
	private let GodModeSystem: ref<GodModeSystem>;
	private let DelaySystem: ref<DelaySystem>;
	private let StatsSystem: ref<StatsSystem>;
	private let AudioSystem: ref<AudioSystem>;
	private let UISystem: ref<UISystem>;

	private let StateMachineBlackboard: ref<IBlackboard>;
	private let UIInteractionsBlackboard: ref<IBlackboard>;

	private let updateDelayID: DelayID;
	private let notifyDelayID: DelayID;

	private let statusEffects: array<ref<gameStatModifierData>>;
	private let statusValues: array<Float>;
	private let statusMessages: array<CName>;


	// Публичные методы

	public final static func GetInstance(gameInstance: GameInstance) -> ref<SurvivalSystem> {
		
		let system: ref<SurvivalSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"SurvivalSystemModule.SurvivalSystem") as SurvivalSystem;
		
		return system;
	}

	public final func ValidateSystemStatus() -> Void {

		this.settings = new SurvivalSystemSettings();

		this.CalculateInventoryWeight();
		this.UpdateAllNeeds();
		this.ValidatePlayerStatus();

		this.UISystem.QueueEvent(new UpdateSettingsEvent());
	}

	public final func UpdateFromTime() -> Void {
		
		if !this.settings.bigRedButton {
			
			if this.IsUpdatePossible() {

				this.ChangeFatigue(-this.GetFatigueLoss() * this.GetStressCurrent());
				this.ChangeHunger(-this.GetHungerLoss() * this.GetStressCurrent());
				this.ChangeThirst(-this.GetThirstLoss() * this.GetStressCurrent());
				this.ChangeStress(-this.GetStressLoss() * this.GetStressCurrent());

				this.ValidatePlayerStatus();
			};
		};

		this.RegisterUpdateCallback();
	}

	public final func UpdateFromSkip(paramVector: Vector4) -> Void {

		if !this.settings.bigRedButton {

			this.SetFatigue(paramVector.X);
			this.SetHunger(paramVector.Y);
			this.SetThirst(paramVector.Z);
			this.SetStress(paramVector.W);

			this.ValidatePlayerStatus();
		};
	}

	public final func UpdateFromItems(itemData: wref<gameItemData>) -> Void {
		
		if !this.settings.bigRedButton {

			let nutritionVector: Vector3 = GetNutritionVector(itemData);

			let fatigue: Float = nutritionVector.X;
			let hunger: Float = nutritionVector.Y;
			let thirst: Float = nutritionVector.Z;

			if fatigue != 0.0 {
				
				this.ChangeFatigue(fatigue);
			};

			if hunger != 0.0 {
				
				this.ChangeHunger(hunger);
			};

			if thirst != 0.0 {
				
				this.ChangeThirst(thirst);
			};

			this.ValidatePlayerStatus();
			this.ForceNotification();
		};
	}

	public final func UpdateFromEffects(effectID: TweakDBID) -> Void {
		
		if !this.settings.bigRedButton {

			switch effectID {

				case t"BaseStatusEffect.WellFed":

					this.ChangeHunger(2.0 * this.settings.foodMultiplier);
				break;

				case t"BaseStatusEffect.Sated":

					this.ChangeThirst(4.0 * this.settings.drinkMultiplier);
				break;

				case t"BaseStatusEffect.Drunk":

					this.ChangeFatigue(-6.0 * this.settings.alcoholPenalty);
					this.ChangeThirst(2.0 * this.settings.drinkMultiplier);
				break;
			};

			this.ValidatePlayerStatus();
			this.ForceNotification();
		};
	}

	public final func ShowNotification() -> Void {

		if this.settings.showTimeNotify && ArraySize(this.statusMessages) == 0 {

			this.AddNotification();
		};

		if ArraySize(this.statusMessages) > 0 {

			let message: CName = ArrayPop(this.statusMessages);

			if Equals(message, n"SSStatusMessage") && this.GetCurrentCondition() < 0.25 {

				this.player.SetWarningMessage(GetLocalizedTextByKey(message));
			};

			if Equals(message, n"SSFatigueMessage") && this.conditionFatigue < this.settings.fatigueNotify {

				this.player.SetWarningMessage(GetLocalizedTextByKey(message));
			};

			if Equals(message, n"SSHungerMessage") && this.conditionHunger < this.settings.hungerNotify {

				this.player.SetWarningMessage(GetLocalizedTextByKey(message));
			};

			if Equals(message, n"SSThirstMessage") && this.conditionThirst < this.settings.thirstNotify {

				this.player.SetWarningMessage(GetLocalizedTextByKey(message));
			};

			if ArraySize(this.statusMessages) > 0 {

				this.RegisterNotifyCallback(12.0);

			} else {

				this.RegisterNotifyCallback();
			};

		} else {

			this.RegisterNotifyCallback();
		};
	}

	public final func ForceNotification() -> Void {

		if this.settings.showOtherNotify {

			ArrayClear(this.statusMessages);
		
			this.AddNotification();
			this.UnregisterNotifyCallback();
			this.RegisterNotifyCallback(4.0);
		};
	}

	public final func AddNotification() -> Void {

		if !this.settings.bigRedButton {

			if this.conditionThirst < this.settings.thirstNotify {

				if !ArrayContains(this.statusMessages, n"SSThirstMessage") {

					ArrayPush(this.statusMessages, n"SSThirstMessage");
				};
			};

			if this.conditionHunger < this.settings.hungerNotify {

				if !ArrayContains(this.statusMessages, n"SSHungerMessage") {

					ArrayPush(this.statusMessages, n"SSHungerMessage");
				};
			};

			if this.conditionFatigue < this.settings.fatigueNotify {

				if !ArrayContains(this.statusMessages, n"SSFatigueMessage") {

					ArrayPush(this.statusMessages, n"SSFatigueMessage");
				};
			};

			if this.GetCurrentCondition() < 0.25 {

				if !ArrayContains(this.statusMessages, n"SSStatusMessage") {

					ArrayPush(this.statusMessages, n"SSStatusMessage");
				};
			};
		};
	}

	public final func AplayVisualEffect() -> Void {

		if this.IsGlitchRequired() && this.settings.visualEffect {
			
			this.AudioSystem.NotifyGameTone(n"InLowHealth");
			GameObjectEffectHelper.StartEffectEvent(this.player, n"fx_health_low", false, null, true);

		} else {

			if this.IsPlayerGoodHealth() {
				
				this.AudioSystem.NotifyGameTone(n"InNormalHealth");
				GameObjectEffectHelper.BreakEffectLoopEvent(this.player, n"fx_health_low");
			};
		};
	}

	public final func ChangeFatigue(value: Float) -> Float {

		this.currentFatigue = ClampF(this.currentFatigue + value, 0.0, 100.0);
		this.UpdateFatigue();

		return this.currentFatigue;
	}

	public final func SetFatigue(value: Float) -> Float {

		this.currentFatigue = ClampF(value, 0.0, 100.0);
		this.UpdateFatigue();

		return this.currentFatigue;
	}

	public final func ChangeHunger(value: Float) -> Float {
		
		this.currentHunger = ClampF(this.currentHunger + value, 0.0, 100.0);
		this.UpdateHunger();

		return this.currentHunger;
	}
	
	public final func SetHunger(value: Float) -> Float {
		
		this.currentHunger = ClampF(value, 0.0, 100.0);
		this.UpdateHunger();

		return this.currentHunger;
	}

	public final func ChangeThirst(value: Float) -> Float {

		this.currentThirst = ClampF(this.currentThirst + value, 0.0, 100.0);
		this.UpdateThirst();

		return this.currentThirst;
	}

	public final func SetThirst(value: Float) -> Float {

		this.currentThirst = ClampF(value, 0.0, 100.0);
		this.UpdateThirst();

		return this.currentThirst;
	}

	public final func ChangeStress(value: Float) -> Float {

		if value > 0.0 {

			this.currentStress += value * 0.0001 * this.settings.stressIncrease;

		} else {

			if value < 0.0 {

				this.currentStress += value * 0.01 * this.settings.stressDecrease;

				if this.currentStress < 1.0 {

					this.currentStress = 1.0;
				};
			};
		};

		this.UpdateStress();

		return this.currentStress;
	}

	public final func SetStress(value: Float) -> Float {

		this.currentStress = value < 1.0 ? 1.0 : value;
		this.UpdateStress();

		return this.currentStress;
	}

	public final func GetFatigueCurrent() -> Float {
		
		return this.currentFatigue;
	}

	public final func GetFatigueRecoverInCar() -> Float {
		
		return 100.0 / (this.settings.fatigueRecoverInCar * 24.0) / 6.0;
	}

	public final func GetFatigueRecoverInBed() -> Float {
		
		return 100.0 / (this.settings.fatigueRecoverInBed * 24.0) / 6.0;
	}

	public final func GetFatigueLoss() -> Float {
		
		return 100.0 / (this.settings.fatigueLoss * 24.0) / 6.0;
	}
	
	public final func GetFatigueThreshold() -> Float {
		
		return this.settings.fatigueThreshold;
	}

	public final func GetFatigueMultiplier() -> Float {
		
		return this.settings.fatigueMultiplier;
	}

	public final func GetHungerCurrent() -> Float {
		
		return this.currentHunger;
	}

	public final func GetHungerLoss() -> Float {
		
		return 100.0 / (this.settings.hungerLoss * 24.0) / 6.0;
	}
	
	public final func GetHungerThreshold() -> Float {
		
		return this.settings.hungerThreshold;
	}

	public final func GetHungerMultiplier() -> Float {
		
		return this.settings.hungerMultiplier;
	}

	public final func GetThirstCurrent() -> Float {
		
		return this.currentThirst;
	}

	public final func GetThirstLoss() -> Float {
		
		return 100.0 / (this.settings.thirstLoss * 24.0) / 6.0;
	}

	public final func GetThirstThreshold() -> Float {
		
		return this.settings.thirstThreshold;
	}

	public final func GetThirstMultiplier() -> Float {
		
		return this.settings.thirstMultiplier;
	}

	public final func GetCurrentCondition() -> Float {
		
		return this.conditionFatigue * this.conditionHunger * this.conditionThirst;
	}

	public final func GetStressCurrent() -> Float {
		
		return this.currentStress;
	}

	public final func GetStressLoss() -> Float {

		return this.GetFatigueLoss() + this.GetHungerLoss() + this.GetThirstLoss();
	}

	public final func GetStatusValues() -> array<Float> {

		return this.statusValues;
	}

	public final func GetCalculatedParameters() -> array<Vector4> {

		let calculatedParameters: array<Vector4>;
		let calculatedFatigue: Float = this.GetFatigueCurrent();
		let calculatedHunger: Float = this.GetHungerCurrent();
		let calculatedThirst: Float = this.GetThirstCurrent();
		let calculatedStress: Float = this.GetStressCurrent();

		let sleepInCar: Bool = this.IsPlayerSleepInCar();
		let sleepInBed: Bool = this.IsPlayerSleepInBed();

		let i: Int32 = 0;

		while i < 25 {
			
			let paramVector: Vector4;

			if i == 0 {

				paramVector = new Vector4(0.0, 0.0, 0.0, 0.0);
				paramVector.X = calculatedFatigue;
				paramVector.Y = calculatedHunger;
				paramVector.Z = calculatedThirst;
				paramVector.W = calculatedStress;

				ArrayPush(calculatedParameters, paramVector);

			} else {

				let j: Int32 = 0;

				while j < 6 {

					let fatigueTemp: Float = -this.GetFatigueLoss() * calculatedStress;
					let tungerTemp: Float = -this.GetHungerLoss() * calculatedStress;
					let thirstTemp: Float = -this.GetThirstLoss() * calculatedStress;
					let stressTemp: Float = -this.GetStressLoss() * calculatedStress * 0.01 * this.settings.stressDecrease;

					if sleepInCar {

						fatigueTemp = this.GetFatigueRecoverInCar();
					};

					if sleepInBed {

						fatigueTemp = this.GetFatigueRecoverInBed();
					};

					calculatedFatigue += fatigueTemp;
					calculatedHunger += tungerTemp;
					calculatedThirst += thirstTemp;
					calculatedStress += stressTemp;

					calculatedFatigue = ClampF(calculatedFatigue, 0.0, 100.0);
					calculatedHunger = ClampF(calculatedHunger, 0.0, 100.0);
					calculatedThirst = ClampF(calculatedThirst, 0.0, 100.0);
					calculatedStress = calculatedStress < 1.0 ? 1.0 : calculatedStress;

					j += 1;
				};

				paramVector = new Vector4(0.0, 0.0, 0.0, 0.0);
				paramVector.X = calculatedFatigue;
				paramVector.Y = calculatedHunger;
				paramVector.Z = calculatedThirst;
				paramVector.W = calculatedStress;

				ArrayPush(calculatedParameters, paramVector);
			};

			i += 1;
		};

		return calculatedParameters;
	}

	public final func IsUpdatePossible() -> Bool {

		let sceneTier: GameplayTier = IntEnum<GameplayTier>(this.StateMachineBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier));

		if NotEquals(sceneTier, GameplayTier.Tier1_FullGameplay) && NotEquals(sceneTier, GameplayTier.Tier2_StagedGameplay) {

			return false;
		};

		return true;
	}

	public final func IsGlitchRequired() -> Bool {

		return this.IsPlayerGoodHealth() && this.GetCurrentCondition() < 0.25;
	}

	public final func IsPlayerGoodHealth() -> Bool {

		let health: Float = this.StatPoolsSystem.GetStatPoolValue(Cast<StatsObjectID>(this.player.GetEntityID()), gamedataStatPoolType.Health, true);

		return health > PlayerPuppet.GetLowHealthThreshold();
	}

	public final func IsPlayerSleepInCar() -> Bool {
		
		if this.settings.canSleepInCar && VehicleComponent.IsMountedToVehicle(this.player.GetGame(), this.player) {

			let vehicle: wref<VehicleObject>;

			VehicleComponent.GetVehicle(this.player.GetGame(), this.player, vehicle);
			
			let isMotorcycle: Bool = VehicleComponent.CheckVehicleDesiredTag(vehicle, n"Motorcycle");
			let isPlayerVehicle: Bool = vehicle.IsPlayerVehicle();

			return !isMotorcycle && isPlayerVehicle;
		};

		return false;
	}

	public final func IsPlayerSleepInBed() -> Bool {

		if !this.skippingTimeFromMenu && this.skippingTimeMenuOpen {

			return true;

		} else {

			return false;
		};
	}

	private final func IsPlayerStimulated() -> Bool {
		
		let effects: array<TweakDBID> = [

			t"BaseStatusEffect.SSStimulatorBuff",
			t"BaseStatusEffect.SSStimulatorBuffRare",
			t"BaseStatusEffect.SSStimulatorBuffEpic"
		];

		for effect in effects {

			if StatusEffectSystem.ObjectHasStatusEffect(this.player, effect) {

				return true;
			};
		};

		return false;
	}

	public final func IsBiomonitorInstalled() -> Bool {

		let equipmentSystem: ref<EquipmentSystem> = EquipmentSystem.GetInstance(this.player);

		let biomonitors: array<TweakDBID> = [

			t"Items.AdvancedBiomonitorCommon",
			t"Items.AdvancedBiomonitorCommonPlus",
			t"Items.AdvancedBiomonitorUncommon",
			t"Items.AdvancedBiomonitorUncommonPlus",
			t"Items.AdvancedBiomonitorRare",
			t"Items.AdvancedBiomonitorRarePlus",
			t"Items.AdvancedBiomonitorEpic",
			t"Items.AdvancedBiomonitorEpicPlus",
			t"Items.AdvancedBiomonitorLegendary",
			t"Items.AdvancedBiomonitorLegendaryPlus",
			t"Items.AdvancedBiomonitorLegendaryPlusPlus"
		];

		for biomonitor in biomonitors {

			if equipmentSystem.IsEquipped(this.player, ItemID.CreateQuery(biomonitor)) {

				return true;
			};
		};

		return false;
	}

	public final func SetSkippingTimeFromMenu(value: Bool) -> Void {

		this.skippingTimeFromMenu = value;
	}

	public final func SetSkippingTimeMenuOpen(value: Bool) -> Void {
		
		this.skippingTimeMenuOpen = value;
	}

	// Приватные методы

	private final func RegisterUpdateCallback() -> Void {

		let callback: ref<UpdateDelayCallback> = new UpdateDelayCallback();

		callback.SurvivalSystem = this;

		this.updateDelayID = this.DelaySystem.DelayCallback(callback, 600.0 / this.settings.updateDelay, true);
	}

	private final func RegisterNotifyCallback(opt delay: Float) -> Void {

		let callback: ref<NotifyDelayCallback> = new NotifyDelayCallback();

		callback.SurvivalSystem = this;

		this.notifyDelayID = this.DelaySystem.DelayCallback(callback, delay == 0.0 ? this.settings.notifyDelay : delay, true);
	}

	private final func UnregisterUpdateCallback() -> Void {

		if this.updateDelayID != GetInvalidDelayID() {

			this.DelaySystem.CancelCallback(this.updateDelayID);
			this.updateDelayID = GetInvalidDelayID();
		};
	}

	private final func UnregisterNotifyCallback() -> Void {

		if this.notifyDelayID != GetInvalidDelayID() {

			this.DelaySystem.CancelCallback(this.notifyDelayID);
			this.notifyDelayID = GetInvalidDelayID();
		};
	}

	private final func CalculateInventoryWeight() -> Void {

		let items: array<wref<gameItemData>>;

		this.TransactionSystem.GetItemList(this.player, items);
		this.player.m_curInventoryWeight = 0.0;

		for item in items {

			if !ItemID.HasFlag(item.GetID(), gameEItemIDFlag.Preview) {

				this.player.m_curInventoryWeight += RPGManager.GetItemStackWeight(this.player, item);
			};
		};
	}

	private final func UpdateAllNeeds() -> Void {
		
		this.UpdateFatigue();
		this.UpdateHunger();
		this.UpdateThirst();
	}

	private final func UpdateFatigue() -> Void {
		
		let evtFatigue: ref<UpdateFatigueEvent> = new UpdateFatigueEvent();
		evtFatigue.current = this.GetFatigueCurrent();
		
		this.UISystem.QueueEvent(evtFatigue);
	}

	private final func UpdateHunger() -> Void {
		
		let evtHunger: ref<UpdateHungerEvent> = new UpdateHungerEvent();
		evtHunger.current = this.GetHungerCurrent();
		
		this.UISystem.QueueEvent(evtHunger);
	}

	private final func UpdateThirst() -> Void {
		
		let evtThirst: ref<UpdateThirstEvent> = new UpdateThirstEvent();
		evtThirst.current = this.GetThirstCurrent();
		
		this.UISystem.QueueEvent(evtThirst);
	}

	private final func UpdateStress() -> Void {
		
		let evtStress: ref<UpdateStressEvent> = new UpdateStressEvent();
		evtStress.current = this.GetStressCurrent();
		
		this.UISystem.QueueEvent(evtStress);
	}

	private final func ValidatePlayerStatus() -> Void {
		
		let statsObjectID: StatsObjectID = Cast<StatsObjectID>(this.player.GetEntityID());
		let playerStimulated: Bool = this.IsPlayerStimulated();

		for statusEffect in this.statusEffects {

  			this.StatsSystem.RemoveModifier(statsObjectID, statusEffect);
		};

		this.conditionFatigue = playerStimulated ? 1.0 : ClampF(this.GetFatigueCurrent() / this.GetFatigueThreshold(), 0.0, 1.0);
		this.conditionHunger = playerStimulated ? 1.0 : ClampF(this.GetHungerCurrent() / this.GetHungerThreshold(), 0.0, 1.0);
		this.conditionThirst = playerStimulated ? 1.0 : ClampF(this.GetThirstCurrent() / this.GetThirstThreshold(), 0.0, 1.0);

		this.AplayVisualEffect();

		if !this.settings.bigRedButton {
			
			this.AplayHorrableDeath();

			let fatigueMult: Float = playerStimulated ? 1.0 : LerpF(this.conditionFatigue, this.GetFatigueMultiplier() * -1.0 + 1.0, 1.0);
			let hungerMult: Float = playerStimulated ? 1.0 : LerpF(this.conditionHunger, this.GetHungerMultiplier() * -1.0 + 1.0, 1.0);
			let thirstMult: Float = playerStimulated ? 1.0 : LerpF(this.conditionThirst, this.GetThirstMultiplier() * -1.0 + 1.0, 1.0);

			let healthMult: Float = LerpF(fatigueMult * hungerMult * thirstMult, 0.1, 1.0, true);
			let healthRegenMult: Float = ClampF(fatigueMult * hungerMult * thirstMult * 2.0 - 1.0, 0.0, 1.0);
			let staminaMult: Float = LerpF(fatigueMult * hungerMult * thirstMult, 0.1, 1.0, true);
			let staminaRegenMult: Float = ClampF(fatigueMult * hungerMult * thirstMult * 2.0 - 1.0, 0.01, 1.0);
			let memoryMult: Float = LerpF(fatigueMult, 0.1, 1.0, true);
			let memoryRegenMult: Float = LerpF(fatigueMult, 0.01, 1.0, true);
			let capacityMult: Float = LerpF(hungerMult, 0.1, 1.0, true);
			let jumpMult: Float = LerpF(hungerMult, 0.2, 1.0, true);
			let speedMult: Float = LerpF(thirstMult, 0.5, 1.0, true);

			this.statusEffects = [

				RPGManager.CreateStatModifier(gamedataStatType.Health, gameStatModifierType.Multiplier, healthMult),
				RPGManager.CreateStatModifier(gamedataStatType.HealthInCombatRegenRate, gameStatModifierType.Multiplier, healthRegenMult),
				RPGManager.CreateStatModifier(gamedataStatType.HealthOutOfCombatRegenRate, gameStatModifierType.Multiplier, healthRegenMult),
				RPGManager.CreateStatModifier(gamedataStatType.Stamina, gameStatModifierType.Multiplier, staminaMult),
				RPGManager.CreateStatModifier(gamedataStatType.StaminaRegenRate, gameStatModifierType.Multiplier, staminaRegenMult),
				RPGManager.CreateStatModifier(gamedataStatType.Memory, gameStatModifierType.Multiplier, memoryMult),
				RPGManager.CreateStatModifier(gamedataStatType.MemoryRegenRate, gameStatModifierType.Multiplier, memoryRegenMult),
				RPGManager.CreateStatModifier(gamedataStatType.CarryCapacity, gameStatModifierType.Multiplier, capacityMult),
				RPGManager.CreateStatModifier(gamedataStatType.JumpHeight, gameStatModifierType.Multiplier, jumpMult),
				RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Multiplier, speedMult)
			];

			this.statusValues = [

				100.0 - healthMult * 100.0,
				100.0 - healthRegenMult * 100.0,
				100.0 - staminaMult * 100.0,
				100.0 - staminaRegenMult * 100.0,
				100.0 - memoryMult * 100.0,
				100.0 - memoryRegenMult * 100.0,
				100.0 - capacityMult * 100.0,
				100.0 - jumpMult * 100.0,
				100.0 - speedMult * 100.0
			];

			for statusEffect in this.statusEffects {

				this.StatsSystem.AddModifier(statsObjectID, statusEffect);
			};
		};
	}

	private final func AplayHorrableDeath() -> Void {

		if this.settings.horrableDeath && this.GetCurrentCondition() <= 0.0 {

			StatusEffectHelper.ApplyStatusEffect(this.player, t"BaseStatusEffect.ForceKill", this.player.GetEntityID());
		};
	}


	// Эвенты и прочее

	protected cb func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
		
		let player: ref<PlayerPuppet> = request.owner as PlayerPuppet;
		
		if IsDefined(player) {

			this.player = player;

			this.TransactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
			this.BlackboardSystem = GameInstance.GetBlackboardSystem(player.GetGame());
			this.StatPoolsSystem = GameInstance.GetStatPoolsSystem(player.GetGame());
			this.GodModeSystem = GameInstance.GetGodModeSystem(player.GetGame());
			this.DelaySystem = GameInstance.GetDelaySystem(player.GetGame());
			this.StatsSystem = GameInstance.GetStatsSystem(player.GetGame());
			this.AudioSystem = GameInstance.GetAudioSystem(player.GetGame());
			this.UISystem = GameInstance.GetUISystem(player.GetGame());

			this.StateMachineBlackboard = this.BlackboardSystem.GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
			this.UIInteractionsBlackboard = this.BlackboardSystem.Get(GetAllBlackboardDefs().UIInteractions);

			this.ValidateSystemStatus();
			this.RegisterUpdateCallback();
			this.RegisterNotifyCallback();
		};
	}

	protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {

		this.UnregisterUpdateCallback();
		this.UnregisterNotifyCallback();
	}
}


// Объект для настройки TweakDB

class SurvivalSystemTweak extends ScriptableTweak {

	protected cb func OnApply() -> Void {
		
		let settings: ref<SurvivalSystemSettings> = new SurvivalSystemSettings();


		// Спавн боеприпасов

		TweakDBManager.SetFlat(t"Ammo.AmmoLootTable_inline0.dropChance", settings.handgunAmmoSpawn);
		TweakDBManager.UpdateRecord(t"Ammo.AmmoLootTable_inline0");

		TweakDBManager.SetFlat(t"Ammo.AmmoLootTable_inline1.dropChance", settings.shotgunAmmoSpawn);
		TweakDBManager.UpdateRecord(t"Ammo.AmmoLootTable_inline1");

		TweakDBManager.SetFlat(t"Ammo.AmmoLootTable_inline2.dropChance", settings.rifleAmmoSpawn);
		TweakDBManager.UpdateRecord(t"Ammo.AmmoLootTable_inline2");

		TweakDBManager.SetFlat(t"Ammo.AmmoLootTable_inline3.dropChance", settings.sniperAmmoSpawn);
		TweakDBManager.UpdateRecord(t"Ammo.AmmoLootTable_inline3");


		// Количество боеприпасов у торговцев

		TweakDBManager.SetFlat(t"Vendors.HandgunAmmoQuantity.value", settings.handgunAmmoQuantity);
		TweakDBManager.UpdateRecord(t"Vendors.HandgunAmmoQuantity");

		TweakDBManager.SetFlat(t"Vendors.ShotgunAmmoQuantity.value", settings.shotgunAmmoQuantity);
		TweakDBManager.UpdateRecord(t"Vendors.ShotgunAmmoQuantity");

		TweakDBManager.SetFlat(t"Vendors.RifleAmmoQuantity.value", settings.rifleAmmoQuantity);
		TweakDBManager.UpdateRecord(t"Vendors.RifleAmmoQuantity");

		TweakDBManager.SetFlat(t"Vendors.SniperAmmoQuantity.value", settings.sniperAmmoQuantity);
		TweakDBManager.UpdateRecord(t"Vendors.SniperAmmoQuantity");

		// Настройки цен в магазинах

		if !settings.disableModPrice {


			// Стоимость боеприпасов в магазинах

			TweakDBManager.SetFlat(t"Price.Ammo.value", settings.ammoBasePrice);
			TweakDBManager.UpdateRecord(t"Price.Ammo");

			TweakDBManager.SetFlat(t"Price.HandgunAmmoMultiplier.value", settings.handgunAmmoPrice);
			TweakDBManager.UpdateRecord(t"Price.HandgunAmmoMultiplier");

			TweakDBManager.SetFlat(t"Price.ShotgunAmmoMultiplier.value", settings.shotgunAmmoPrice);
			TweakDBManager.UpdateRecord(t"Price.ShotgunAmmoMultiplier");

			TweakDBManager.SetFlat(t"Price.RifleAmmoMultiplier.value", settings.rifleAmmoPrice);
			TweakDBManager.UpdateRecord(t"Price.RifleAmmoMultiplier");

			TweakDBManager.SetFlat(t"Price.SniperAmmoMultiplier.value", settings.sniperAmmoPrice);
			TweakDBManager.UpdateRecord(t"Price.SniperAmmoMultiplier");


			// Стоимость расходников в магазинах

			TweakDBManager.SetFlat(t"Price.ConsumableBasePrice.value", settings.consumableBasePrice);
			TweakDBManager.UpdateRecord(t"Price.ConsumableBasePrice");

			if ExistingConsumableModule() {

				TweakDBManager.SetFlat(t"Price.DamageGrenade.value", settings.damageGrenadePriceEC);
				TweakDBManager.UpdateRecord(t"Price.DamageGrenade");

				TweakDBManager.SetFlat(t"Price.EffectGrenade.value", settings.effectGrenadePriceEC);
				TweakDBManager.UpdateRecord(t"Price.EffectGrenade");

				TweakDBManager.SetFlat(t"Price.Injector.value", settings.injectorPriceEC);
				TweakDBManager.UpdateRecord(t"Price.Injector");

				TweakDBManager.SetFlat(t"Price.Inhaler.value", settings.inhalerPriceEC);
				TweakDBManager.UpdateRecord(t"Price.Inhaler");

			} else {

				TweakDBManager.SetFlat(t"Price.DamageGrenade.value", settings.damageGrenadePrice);
				TweakDBManager.UpdateRecord(t"Price.DamageGrenade");

				TweakDBManager.SetFlat(t"Price.EffectGrenade.value", settings.effectGrenadePrice);
				TweakDBManager.UpdateRecord(t"Price.EffectGrenade");

				TweakDBManager.SetFlat(t"Price.Injector.value", settings.injectorPrice);
				TweakDBManager.UpdateRecord(t"Price.Injector");

				TweakDBManager.SetFlat(t"Price.Inhaler.value", settings.inhalerPrice);
				TweakDBManager.UpdateRecord(t"Price.Inhaler");
			};

			TweakDBManager.SetFlat(t"Price.LongLastingConsumable.value", settings.drugsPrice);
			TweakDBManager.UpdateRecord(t"Price.LongLastingConsumable");


			// Стоимость продуктов в магазинах

			TweakDBManager.SetFlat(t"Price.Food.value", settings.foodBasePrice);
			TweakDBManager.UpdateRecord(t"Price.Food");

			TweakDBManager.SetFlat(t"Price.LowQualityFood.value", settings.foodUncommonPrice);
			TweakDBManager.UpdateRecord(t"Price.LowQualityFood");

			TweakDBManager.SetFlat(t"Price.MediumQualityFood.value", settings.foodRarePrice);
			TweakDBManager.UpdateRecord(t"Price.MediumQualityFood");

			TweakDBManager.SetFlat(t"Price.GoodQualityFood.value", settings.foodEpicPrice);
			TweakDBManager.UpdateRecord(t"Price.GoodQualityFood");


			// Стоимость напитков в магазинах

			TweakDBManager.SetFlat(t"Price.Drink.value", settings.drinkBasePrice);
			TweakDBManager.UpdateRecord(t"Price.Drink");

			TweakDBManager.SetFlat(t"Price.LowQualityDrink.value", settings.drinkUncommonPrice);
			TweakDBManager.UpdateRecord(t"Price.LowQualityDrink");

			TweakDBManager.SetFlat(t"Price.MediumQualityDrink.value", settings.drinkRarePrice);
			TweakDBManager.UpdateRecord(t"Price.MediumQualityDrink");

			TweakDBManager.SetFlat(t"Price.GoodQualityDrink.value", settings.drinkEpicPrice);
			TweakDBManager.UpdateRecord(t"Price.GoodQualityDrink");


			// Стоимость алкоголя в магазинах

			TweakDBManager.SetFlat(t"Price.Alcohol.value", settings.alcoholBasePrice);
			TweakDBManager.UpdateRecord(t"Price.Alcohol");

			TweakDBManager.SetFlat(t"Price.LowQualityAlcohol.value", settings.alcoholUncommonPrice);
			TweakDBManager.UpdateRecord(t"Price.LowQualityAlcohol");

			TweakDBManager.SetFlat(t"Price.MediumQualityAlcohol.value", settings.alcoholRarePrice);
			TweakDBManager.UpdateRecord(t"Price.MediumQualityAlcohol");

			TweakDBManager.SetFlat(t"Price.GoodQualityAlcohol.value", settings.alcoholEpicPrice);
			TweakDBManager.UpdateRecord(t"Price.GoodQualityAlcohol");

			TweakDBManager.SetFlat(t"Price.TopQualityAlcohol.value", settings.alcoholLegendaryPrice);
			TweakDBManager.UpdateRecord(t"Price.TopQualityAlcohol");
		};
	}
}